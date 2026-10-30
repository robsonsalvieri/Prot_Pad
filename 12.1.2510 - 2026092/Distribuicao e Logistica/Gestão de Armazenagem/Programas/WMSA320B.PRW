#INCLUDE "WMSA320B.CH"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBINFO.CH"

#define WMSA320B01 "WMSA320B01"
#define WMSA320B02 "WMSA320B02"
#define WMSA320B03 "WMSA320B03"
#define WMSA320B04 "WMSA320B04"
#define WMSA320B05 "WMSA320B05"
#define WMSA320B06 "WMSA320B06"
#define WMSA320B07 "WMSA320B07"
#define WMSA320B08 "WMSA320B08"
#define WMSA320B09 "WMSA320B09"
#define WMSA320B10 "WMSA320B10"
#define WMSA320B11 "WMSA320B11"
#define WMSA320B12 "WMSA320B12"
#define WMSA320B13 "WMSA320B13"
#define WMSA320B14 "WMSA320B14"
#define WMSA320B15 "WMSA320B15"
#define WMSA320B16 "WMSA320B16"
#define WMSA320B17 "WMSA320B17"
#define WMSA320B18 "WMSA320B18"

Static oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
Static __cWmsLcEx  := SuperGetMV('MV_WMSLCEX',.F.,'') // Local de excesso
Static __cWmsEnEx  := SuperGetMV('MV_WMSENEX',.F.,"") // Endereço de excesso
Static __lWmsDtCF  := SuperGetMV('MV_WMSDTCF',.F.,.F.) // Solicita data de validade do lote se este não existe?
Static lWmsNew     := SuperGetMV("MV_WMSNEW",.F.,.F.)
Static lDtValid    := DCY->(ColumnPos("DCY_DTVAL")) > 0
Static lGerouExc   := .F.

// Esta função é só para o TDS reconhecer o fonte e poder gerar patch
Function WMSA320BDUMMY()
Return Nil

//----------------------------------------------------------
// ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel     := Nil
Local oStructDCW := FWFormStruct(1,'DCW')
Local oStructDC1 := FWFormStruct(1,'DCZ')
Local oStructDCZ := FWFormStruct(1,'DCZ')
Local oStructDCY := FWFormStruct(1,'DCY')
Local aTamSX3    := TamSx3('DCZ_PROD')
Local aColsSX3   := {}
Local bValCod    := FwBuildFeature(STRUCT_FEATURE_VALID,'WMS320VFld(A,B,C)')
Local cLocalTmp  := IIF(Type("cArmazem") != "U",cArmazem,"")
Local cIdUnitTmp := IIF(Type("cIdUnit") != "U",cIdUnit,"")



	BuscarSX3('DCZ_PROD',,@aColsSX3)
	oStructDC1:AddField(RetTitle('DCZ_PROD'),STR0009,'DCZ_CODBAR','C',aColsSX3[3],aColsSX3[4],bValCod,Nil,Nil,Nil,Nil,Nil,Nil,.T.) // Código do produto ou código de barras do mesmo.
	BuscarSX3('D14_IDUNIT',,@aColsSX3)
	oStructDC1:AddField(STR0015 ,STR0015,'DCZ_CODUNI' , 'C',aColsSX3[3],aColsSX3[4],,,,.T.,,,,.T.) // Cod Untitiz
	BuscarSX3('D14_ENDER',,@aColsSX3)
	oStructDC1:AddField(STR0016 ,STR0016,'DCZ_ENDER' , 'C',aColsSX3[3],aColsSX3[4],,,,.T.,,,,.T.) // Endereço
	BuscarSX3('B5_ECPESOE',,@aColsSX3)
	oStructDC1:AddField(STR0017 ,STR0017,'DCZ_PESO' , 'N',aColsSX3[3],aColsSX3[4],,,,.T.,,,,.T.) // Peso Unitizador
	BuscarSX3('D14_QTDEST',,@aColsSX3)
	oStructDC1:AddField(STR0018 ,STR0018,'DCZ_QTDUNI' , 'N',aColsSX3[3],aColsSX3[4],,,,.T.,,,,.T.) // Quantidade Unitizada
	BuscarSX3('DCZ_PROD',,@aColsSX3)
	oStructDC1:AddField(STR0019 ,STR0019,'DCZ_ULTPRD' , 'C',aColsSX3[3],aColsSX3[4],,,,.T.,,,,.T.) // Ultimo Produto Unitizado
	oStructDC1:AddField(STR0020 ,STR0020,'DCZ_MISTO','C',1,,,,,.T.,,,,.T.) // Unitizador Misto?
	oStructDC1:AddField(STR0040 ,STR0040,'DCZ_ALTLT','C',1,,,,,.T.,,,,.T.) // Permite alterar lote?
	aColsSX3 := {STR0021,"@E 999,999,999.99",12,2} // Quantidade Somada ao Unitizador
	oStructDCZ:AddField(STR0021 ,STR0021,'DCZ_QTSOMA','N',aColsSX3[3],aColsSX3[4],,,,.T.,,,,.T.) // Quantidade Somada ao Unitizador

	oStructDC1:SetProperty('DCZ_PROD'  , MODEL_FIELD_KEY     , .F.)
	oStructDC1:SetProperty('DCZ_LOTE'  , MODEL_FIELD_KEY     , .F.)
	oStructDC1:SetProperty('DCZ_SUBLOT', MODEL_FIELD_KEY     , .F.)
	oStructDC1:SetProperty('DCZ_QTCONF', MODEL_FIELD_KEY     , .F.)
	If lDtValid
		oStructDC1:SetProperty('DCZ_DTVAL',  MODEL_FIELD_KEY     , .F.)
	EndIf

	oStructDC1:SetProperty('DCZ_DPROD' , MODEL_FIELD_INIT    , Nil)
	oStructDC1:SetProperty('DCZ_PRDORI', MODEL_FIELD_OBRIGAT , .F.)
	oStructDC1:SetProperty('DCZ_EMBARQ', MODEL_FIELD_OBRIGAT , .F.)
	oStructDC1:SetProperty('DCZ_OPER'  , MODEL_FIELD_OBRIGAT , .F.)
	oStructDC1:SetProperty('DCZ_PROD'  , MODEL_FIELD_OBRIGAT , .F.)
	oStructDC1:SetProperty('DCZ_QTCONF', MODEL_FIELD_OBRIGAT , .F.)
	oStructDC1:SetProperty('DCZ_IDUNIT', MODEL_FIELD_OBRIGAT , .F.)
	oStructDC1:SetProperty('DCZ_CODUNI', MODEL_FIELD_OBRIGAT , .F.)
	oStructDC1:SetProperty('DCZ_ENDER' , MODEL_FIELD_OBRIGAT , .F.)
	oStructDC1:SetProperty('DCZ_LOCAL' , MODEL_FIELD_OBRIGAT , .F.)
	oStructDC1:SetProperty('DCZ_QTDUNI', MODEL_FIELD_OBRIGAT , .F.)
	oStructDC1:SetProperty('DCZ_ULTPRD', MODEL_FIELD_OBRIGAT , .F.)
	oStructDC1:SetProperty('DCZ_MISTO' , MODEL_FIELD_OBRIGAT , .F.)
	oStructDC1:SetProperty('DCZ_PESO'  , MODEL_FIELD_OBRIGAT , .F.)
	oStructDC1:SetProperty('DCZ_ALTLT' , MODEL_FIELD_OBRIGAT , .F.)
	
	oStructDCZ:SetProperty('*', MODEL_FIELD_OBRIGAT , .F.)
	
	oStructDCY:SetProperty('*', MODEL_FIELD_OBRIGAT , .F.)
	
	oStructDC1:AddField(STR0013,STR0014,'DCZ_TPPROD','C',1,0,,/*bWhen*/,{"1","2"},.F.,Nil,.F.,.F./*lNoUpd*/,.T.) //Considerar //Considerar como produto ou componente?
	
	oStructDC1:SetProperty('DCZ_LOTE'  , MODEL_FIELD_WHEN    , FwBuildFeature(STRUCT_FEATURE_WHEN,'WMS320Wfld(A,B)'))
	oStructDC1:SetProperty('DCZ_SUBLOT', MODEL_FIELD_WHEN    , FwBuildFeature(STRUCT_FEATURE_WHEN,'WMS320Wfld(A,B)'))
	oStructDC1:SetProperty('DCZ_TPPROD', MODEL_FIELD_WHEN    , FwBuildFeature(STRUCT_FEATURE_WHEN,'WMS320Wfld(A,B)'))
	If lDtValid
		oStructDC1:SetProperty('DCZ_DTVAL',  MODEL_FIELD_WHEN    , FwBuildFeature(STRUCT_FEATURE_WHEN,'WMS320Wfld(A,B)'))
	EndIf

	// AddTrigger ( <Id do campo de origem>,;
	//             < Id do campo de destino>,;
	//             <Bloco de codigo de validação da execução do gatilho>,;
	//             <Bloco de codigo de execução do gatilho> )
	oStructDC1:AddTrigger( 'DCZ_LOTE'  , 'DCZ_TPPROD', {|oModel| WMS320Wfld(oModel, 'DCZ_TPPROD') }, {|oModel| TrigTpPrd(oModel)})
	oStructDC1:AddTrigger( 'DCZ_SUBLOT', 'DCZ_TPPROD', {|oModel| WMS320Wfld(oModel, 'DCZ_TPPROD') }, {|oModel| TrigTpPrd(oModel)})
	If lDtValid
		oStructDC1:AddTrigger( 'DCZ_LOTE'  , 'DCZ_DTVAL', {|oModel| WMS320Wfld(oModel, 'DCZ_LOTE') }, {|oModel| TrigDtVal(oModel)})
		oStructDC1:AddTrigger( 'DCZ_SUBLOT', 'DCZ_DTVAL', {|oModel| WMS320Wfld(oModel, 'DCZ_SUBLOT') }, {|oModel| TrigDtVal(oModel)})
	EndIf

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New('WMSA320B', /*bPre*/,/*bPost*/,{|oModel| GravaDados(oModel)},{||CancelMdl()})
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição

	oModel:AddFields('WMSA320BDCW', Nil, oStructDCW,/*bPre*/, /*bPost*/,/*bLoad*/)
	oModel:AddFields('WMSA320BGER', 'WMSA320BDCW', oStructDC1,/*bPre*/,/*bPost*/,{ |oModel| ''} /*bLoad*/)
	oModel:SetRelation('WMSA320BGER',{{'DCZ_FILIAL',"xFilial('DCZ')"},{'DCZ_EMBARQ','DCW_EMBARQ'}}, DCZ->(IndexKey(1)))

	oModel:AddRules('WMSA320BGER', 'DCZ_LOTE'  , 'WMSA320BGER', 'DCZ_PROD', 3)
	oModel:AddRules('WMSA320BGER', 'DCZ_SUBLOT', 'WMSA320BGER', 'DCZ_PROD', 3)
	oModel:AddRules('WMSA320BGER', 'DCZ_TPPROD', 'WMSA320BGER', 'DCZ_PROD', 3)
	If lDtValid
		oModel:AddRules('WMSA320BGER', 'DCZ_DTVAL' , 'WMSA320BGER', 'DCZ_PROD', 3)
	EndIf
	
	
	aTamSX3 := TamSx3('DCZ_QTCONF')
	// Adiciona um campo para descontar o que já estava gravado em outra conferência
	oStructDCZ:AddField(RetTitle('DCZ_QTCONF'),STR0010,'DCZ_QTCFAT','N',aTamSX3[1],aTamSX3[2],Nil,Nil,Nil,Nil,{||DCZ->DCZ_QTCONF},Nil,Nil,.T.) // Quantidade conferida anterior.
	
	oModel:AddGrid( 'WMSA320BDCZ', 'WMSA320BDCW', oStructDCZ, /*bLinePre*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,/*LoadGrid*/)
	oModel:SetRelation( 'WMSA320BDCZ',{{'DCZ_FILIAL',"xFilial('DCZ')"},{'DCZ_EMBARQ','DCW_EMBARQ'},{'DCZ_OPER','__cUserID'}},"DCZ_FILIAL+DCZ_EMBARQ+DCZ_OPER")
	oModel:GetModel( 'WMSA320BDCZ' ):SetLoadFilter({{'DCZ_LOCAL' ,"{'"+cLocalTmp+"','"+__cWmsLcEx+"'}",MVC_LOADFILTER_IS_CONTAINED},{'DCZ_IDUNIT' ,"{'"+cIdUnitTmp+"','"+Space(TamSX3("DCZ_IDUNIT")[1])+"'}",MVC_LOADFILTER_IS_CONTAINED}})
	oModel:GetModel('WMSA320BDCZ'):SetNoInsertLine(.T.)
	oModel:GetModel('WMSA320BDCZ'):SetNoDeleteLine(.T.)
	oModel:GetModel('WMSA320BDCZ'):SetOptional(.T.)
	
	oModel:AddGrid( 'WMSA320BDCY', 'WMSA320BDCW', oStructDCY)
	oModel:SetRelation( 'WMSA320BDCY',{{'DCY_FILIAL',"xFilial('DCY')"},{'DCY_EMBARQ','DCW_EMBARQ'}} , DCY->( IndexKey(1) ))
	oModel:GetModel('WMSA320BDCY'):SetOptional(.T.)

	oModel:GetModel('WMSA320BDCW'):SetDescription(STR0001) // Conferência
	oModel:GetModel('WMSA320BDCW'):SetOnlyQuery(.T.)

	oModel:SetDescription('WMSA320BDCW')
	oModel:SetPrimaryKey({'DCZ_EMBARQ','DCZ_OPER','DCZ_PRDORI','DCZ_PROD','DCZ_LOTE','DCZ_SUBLOT','DCZ_LOCAL','DCZ_IDUNIT'})

	oModel:GetModel('WMSA320BGER'):SetDescription(STR0001) // Conferência
	oModel:GetModel('WMSA320BGER'):SetOnlyQuery(.T.)
	
	oModel:SetActivate({|oModel| ActiveModel(oModel)})
Return oModel

//----------------------------------------------------------
// ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel('WMSA320B')
Local oStructDC1 := FWFormStruct(2,'DCZ')
Local oStructDCZ := FWFormStruct(2,'DCZ')
Local oView      := FWFormView():New()
	
	oStructDC1:RemoveField('DCZ_PRDORI') // Esconde o campo produto
	oStructDC1:RemoveField('DCZ_PROD')   // Esconde o campo produto
	oStructDC1:RemoveField('DCZ_EMBARQ')
	oStructDC1:RemoveField('DCZ_OPER')
	oStructDC1:RemoveField('DCZ_NOMFUN')
	
	If !__lWmsDtCF .And. lDtValid
		oStructDC1:RemoveField('DCZ_DTVAL')
	EndIf
	
	oStructDC1:AddField('DCZ_ENDER', '02',STR0016,STR0016,Nil,'GET', '@!', Nil, /*cLookUp*/,.T., /*cFolder*/, /*cGroup*/, /*aComboValues*/, /*nMaxLenCombo*/, /*cIniBrow*/, .T.) // Endereço
	oStructDC1:AddField('DCZ_CODUNI','04',STR0015,STR0015,Nil,'GET', '@!', Nil, /*cLookUp*/,.T., /*cFolder*/, /*cGroup*/, /*aComboValues*/, /*nMaxLenCombo*/, /*cIniBrow*/, .T.) // Código Unitizador
	oStructDC1:AddField('DCZ_CODBAR','05',RetTitle('DCZ_PROD'),STR0009,Nil,'GET', '@!', Nil, /*cLookUp*/,.T., /*cFolder*/, /*cGroup*/, /*aComboValues*/, /*nMaxLenCombo*/, /*cIniBrow*/, .T.) //Código do produto ou código de barras do mesmo.	oStructDC1:SetProperty('DCZ_DPROD' ,MVC_VIEW_ORDEM,'02')	
	oStructDC1:AddField('DCZ_TPPROD','09',STR0013,STR0014,Nil,'GET',"",Nil,Nil/*cLookUp*/,.T./*lCanChange*/,Nil,Nil,{"1=Produto","2=Componente"},Nil,Nil,.T.) //Considerar //Considerar como produto ou componente?

	oStructDC1:SetProperty('DCZ_LOCAL' ,MVC_VIEW_ORDEM,'01')
	oStructDC1:SetProperty('DCZ_ENDER' ,MVC_VIEW_ORDEM,'02')
	oStructDC1:SetProperty('DCZ_IDUNIT',MVC_VIEW_ORDEM,'03')
	oStructDC1:SetProperty('DCZ_CODUNI',MVC_VIEW_ORDEM,'04')
	oStructDC1:SetProperty('DCZ_CODBAR',MVC_VIEW_ORDEM,'05')
	oStructDC1:SetProperty('DCZ_DPROD' ,MVC_VIEW_ORDEM,'06')
	oStructDC1:SetProperty('DCZ_LOTE'  ,MVC_VIEW_ORDEM,'07')
	oStructDC1:SetProperty('DCZ_SUBLOT',MVC_VIEW_ORDEM,'08')
	If __lWmsDtCF .And. lDtValid
		oStructDC1:SetProperty('DCZ_DTVAL', MVC_VIEW_ORDEM,'09')
	EndIf
	oStructDC1:SetProperty('DCZ_TPPROD',MVC_VIEW_ORDEM,'10')
	oStructDC1:SetProperty('DCZ_QTCONF',MVC_VIEW_ORDEM,'11')

	oStructDC1:SetProperty('DCZ_IDUNIT', MVC_VIEW_CANCHANGE , .F.)
	oStructDC1:SetProperty('DCZ_CODUNI', MVC_VIEW_CANCHANGE , .F.)
	oStructDC1:SetProperty('DCZ_ENDER' , MVC_VIEW_CANCHANGE , .F.)
	oStructDC1:SetProperty('DCZ_LOCAL' , MVC_VIEW_CANCHANGE , .F.)
	
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:CreateHorizontalBox( 'MASTER' , 40,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddField( 'WMSA320BGER' , oStructDC1)

	oView:CreateHorizontalBox( "DETAIL" , 60,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddGrid('WMSA320BDCZ', oStructDCZ,,,{ || RegInfCof(oModel,oView)} )
	oView:SetOnlyView('WMSA320BDCZ')

	oView:EnableTitleView("WMSA320BGER", STR0011) // Itens Conferência
	oView:EnableTitleView("WMSA320BDCZ", STR0012) // Produtos
	// Associa um View a um box
	oView:SetOwnerView('WMSA320BGER', 'MASTER')
	oView:SetOwnerView('WMSA320BDCZ', 'DETAIL')
Return oView
//----------------------------------------------------------
/*/{Protheus.doc} CancelMdl
Função chamada ao cancelar o model
@author  Amanda Rosa Vieira
@version P12
@Since   09/06/2017
/*/
//----------------------------------------------------------
Static Function CancelMdl()
Local lRet := .F.
	If !lGerouExc
		lRet := .T.
	ElseIf WmsQuestion(STR0037,WMSA320B14) //Existem conferências de excesso geradas. Confirma cancelamento?
		lGerouExc := .F.
		lRet := .T.
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} ActiveModel
Carrega campos refentes ao processo de unitização
@author  Amanda Rosa Vieira
@version P12
@Since   20/04/2017
/*/
//----------------------------------------------------------
Static Function ActiveModel(oModel)
Local oModelDC1 := oModel:GetModel('WMSA320BGER')
Local lNovo     := .F.
	oModelDC1:LoadValue('DCZ_LOCAL',  cArmazem) 
	oModelDC1:LoadValue('DCZ_ENDER',  cEndereco) 
	oModelDC1:LoadValue('DCZ_IDUNIT', cIdUnit) 
	oModelDC1:LoadValue('DCZ_CODUNI', cTipUni) 
	//Limpa variável de controle da data de validade
	oModelDC1:LoadValue("DCZ_ALTLT","2")
	
	If lUnitiza
		oMntUniItem:oUnitiz:SetArmazem(oModelDC1:GetValue('DCZ_LOCAL'))
		oMntUniItem:oUnitiz:SetEnder(oModelDC1:GetValue('DCZ_ENDER'))
		oMntUniItem:oUnitiz:SetIdUnit(oModelDC1:GetValue('DCZ_IDUNIT'))
		oMntUniItem:oUnitiz:SetTipUni(oModelDC1:GetValue('DCZ_CODUNI'))
		If !(lNovo := oMntUniItem:oUnitiz:UniHasItem())
			oMntUniItem:oUnitiz:SetDatIni(dDataBase)
			oMntUniItem:oUnitiz:SetHorIni(Time())
		EndIf
		oMntUniItem:oUnitiz:CalcOcupac()
		oMntUniItem:QtdPrdUni(.T.)
		//Posiciona no unitizador para pegar o último produto unitizado
		If !(lMisto := oMntUniItem:oUnitiz:IsMultPrd())
			D0S->(dbSetOrder(1))
			D0S->(dbSeek(xFilial('D0S')+oMntUniItem:oUnitiz:GetIdUnit()))
			oMntUniItem:SetPrdOri(D0S->D0S_PRDORI)
			oMntUniItem:SetProduto(D0S->D0S_CODPRO)
		EndIf
		//Carrega informações do unitizador
		oModelDC1:LoadValue('DCZ_MISTO', IIF(lNovo,"2",IIF(lMisto,"1","2")))
		oModelDC1:LoadValue('DCZ_ULTPRD',IIF(lNovo,"",oMntUniItem:GetProduto()))
		oModelDC1:LoadValue('DCZ_PESO',  IIF(lNovo,0,oMntUniItem:oUnitiz:GetPeso()))
		oModelDC1:LoadValue('DCZ_QTDUNI',IIF(lMisto,0,oMntUniItem:GetQuant()))
		//Limpa informações do produto
		oMntUniItem:SetPrdOri("")
		oMntUniItem:SetProduto("")
	EndIf
Return .T.
//----------------------------------------------------------------------------//
// Função responsável por validar a edição do campo
//----------------------------------------------------------------------------//
Function WMS320Wfld(oModel,cField)
Local lRet      := .T.
Local lAltDtLote:= .F.
Local cProduto  := oModel:GetValue("DCZ_PROD")

	If cField == "DCZ_LOTE"
		lRet := Rastro(oModel:GetValue('DCZ_PROD'))
	ElseIf cField == "DCZ_SUBLOT" //Não deve permitir informar sublote se o tipo da conferência é de Pré-Nota
		If	DCW->DCW_TPCONF <> "2"
			lRet := .F.
		Else
			lRet := Rastro(oModel:GetValue('DCZ_PROD'),'S')
		EndIf
	ElseIf cField == "DCZ_TPPROD"
		//Verifica se é um componente
		If lWmsNew .And. !Empty(cProduto) // !lPergunta .And. cPrdOri == cProduto
			D11->(DbSetOrder(2)) // D11_FILIAL+D11_PRDCMP
			If D11->(!DbSeek(xFilial("D11")+cProduto)) // Verifica se o produto existe como componente na D11
				lRet := .F.
			EndIf
		Else
			lRet := lWmsNew
		EndIf
	ElseIf cField == "DCZ_DTVAL"
		//Apenas permite alterar a data de validade, se a data de validade do lote ainda não existe na SB8 e na DCY
		lAltDtLote := oModel:GetValue("DCZ_ALTLT") == "1" 
		lRet := !lAltDtLote .And. Rastro(oModel:GetValue('DCZ_PROD'))
	EndIf
Return lRet
//----------------------------------------------------------------------------//
//-- Função responsável pela validação dos campos
//----------------------------------------------------------------------------//
Function WMS320VFld(oModel,cField,xValue)
Local lRet      := .T.
Local oView     := FWViewActive()
Local aProduto  := {}
Local cProduto  := ""
Local cLoteCtl  := ""
Local cSubLote  := ""
Local dDtValid  := cToD("")
Local dDtTrig   := cToD("")
Local nQtde     := 0

	If cField == "DCZ_CODBAR"
		aProduto := CBRetEtiEAN(xValue)
		If Len(aProduto) > 0
			cProduto := aProduto[1]
			If ExistBlock("CBRETEAN")
				nQtde := aProduto[2]
			EndIf
			cLoteCtl := Padr(aProduto[3],Len(SDB->DB_LOTECTL))
			If Len(aProduto) >= 4 .And. !Empty(aProduto[4]) .And. ValType(aProduto[4]) == "D"
				dDtValid := aProduto[4]
			EndIf
		Else
			aProduto := CBRetEti(xValue, '01')
			If Len(aProduto) > 0
				cProduto := aProduto[1]
				nQtde    := aProduto[2]
				cLoteCtl := Padr(aProduto[16],Len(SDB->DB_LOTECTL))
				cSubLote := Padr(aProduto[17],Len(SDB->DB_NUMLOTE))
				If Len(aProduto) >= 18 .And. !Empty(aProduto[18])  .And. ValType(aProduto[18]) == "D"
					dDtValid := aProduto[18]
				EndIf
			EndIf
		EndIf
		If Empty(cProduto)
			oModel:oFormModel:SetErrorMessage('WMSA320BGER', 'DCZ_PROD','WMSA320BGER','DCZ_PROD',,STR0001,STR0005) // Produto inválido/Informar o código do produto código de barras ou EAN do produto!
			oModel:ClearField('DCZ_CODBAR')
			oModel:ClearField('DCZ_PRDORI')
			oModel:ClearField('DCZ_PROD'  )
			oModel:ClearField('DCZ_DPROD' )
			oModel:ClearField('DCZ_LOTE'  )
			oModel:ClearField('DCZ_SUBLOT')
			oModel:ClearField('DCZ_QTCONF')
			If lDtValid
				oModel:ClearField('DCZ_DTVAL')
			EndIf
			//Limpa variável de controle da data de validade
			oModel:LoadValue("DCZ_ALTLT","2")
			oView:Refresh()
			lRet := .F.
		Else
			oModel:LoadValue('DCZ_PROD',cProduto) 
			oModel:LoadValue('DCZ_PRDORI',cProduto)
			oModel:LoadValue('DCZ_DPROD',RetField('SB1',1,xFilial('SB1')+cProduto,'SB1->B1_DESC'))
			oModel:LoadValue('DCZ_LOTE',cLoteCtl) 
			oModel:LoadValue('DCZ_SUBLOT',cSubLote)
			oModel:LoadValue('DCZ_TPPROD',TrigTpPrd(oModel))
			oModel:LoadValue('DCZ_QTCONF',nQtde)
			dDtTrig := TrigDtVal(oModel)
			If lDtValid
				If Empty(dDtTrig)
					oModel:LoadValue('DCZ_DTVAL',dDtValid) //Apenas assume o valor da etiqueta caso não exista a informação da data de validade do lote na SB8 ou DCY
				Else
					oModel:LoadValue('DCZ_DTVAL',dDtTrig)
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} TrigTpPrd
Trigger disparada para efetuar o preenchimento do campo Tipo De Produto.
Onde: 1 - Produto Normal
      2 - Produto Componente
@author  Jackson Patrick Werka
@version 12.1.17
@Since   03/0/2018
/*/
//----------------------------------------------------------
Static Function TrigTpPrd(oModel)
Local cRet      := "1"
Local cQuery    := ""
Local cAliasQry := ""
Local cProduto  := oModel:GetValue("DCZ_PROD")
Local cLoteCtl  := oModel:GetValue("DCZ_LOTE")
Local cNumLote  := oModel:GetValue("DCZ_SUBLOT")

	// Verificar se produto existe na DCY como componente
	cQuery := " SELECT DCY.DCY_PRDORI,"
	cQuery +=        " DCY.DCY_PROD,"
	cQuery +=        " DCY.DCY_LOTE,"
	cQuery +=        " DCY.DCY_SUBLOT"
	cQuery +=   " FROM "+RetSqlName('DCY')+" DCY"
	cQuery +=  " WHERE DCY.DCY_FILIAL = '"+xFilial('DCY')+"'"
	cQuery +=    " AND DCY.DCY_EMBARQ = '"+DCW->DCW_EMBARQ+"'"
	cQuery +=    " AND DCY.DCY_LOCAL  = '"+oModel:GetValue("DCZ_LOCAL")+"'"
	cQuery +=    " AND DCY.DCY_PROD   = '"+cProduto+"'"
	cQuery +=    " AND DCY.DCY_PRDORI <> DCY.DCY_PROD"
	// Trata as informações de Lote e SubLote em branco, para os casos de conferência de pré-notas
	// Pois neste caso, mesmo controlando lote, na DCY pode ser gravado em branco na montagem da conferência
	If !Empty(cLoteCtl)
		cQuery += " AND (DCY.DCY_LOTE = '"+cLoteCtl+"' OR DCY.DCY_LOTE = '"+Space(Len(DCY->DCY_LOTE))+"')"
	EndIf
	If !Empty(cNumLote)
		cQuery += " AND (DCY.DCY_SUBLOT = '"+cNumLote+"' OR DCY.DCY_SUBLOT = '"+Space(Len(DCY->DCY_SUBLOT))+"')"
	EndIf
	cQuery +=    " AND DCY.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		cRet := "2"
	EndIf
	(cAliasQry)->(dbCloseArea())

Return cRet

//----------------------------------------------------------
/*/{Protheus.doc} RegInfCof
Validação para confirmação de inclusão no grid

@author  Alexsander Burigo Corrêa
@version P11 R7
@Since   01/08/12
@obs     Validação para confirmação de inclusão no grid

/*/
//----------------------------------------------------------
Static Function RegInfCof(oModel,oView)
Local oModelDCW := oModel:GetModel('WMSA320BDCW')
Local oModelDC1 := oModel:GetModel('WMSA320BGER')
Local oModelDCZ := oModel:GetModel('WMSA320BDCZ')
Local oModelDCY := oModel:GetModel('WMSA320BDCY')
Local cPrdOri   := ""
Local cProduto  := oModelDC1:GetValue('DCZ_PROD')
Local lConfirma := .T.
Local cQuery    := ""
Local cAliasQry := ""
Local oProdComp := IIf(lWmsNew,WMSDTCProdutoComponente():New(),Nil)
Local aProdComp := {}
Local nI        := 0
Local nQtConfPai:= 0
Local cAliasDCY := Nil
Local lWmsNpCp  := SuperGetMV("MV_WMSNPCP",.F.,.F.)
Local lRastro   := Rastro(cProduto)

	// Verifica produto
	If Empty(cProduto)
		lConfirma := .F.
	EndIf
	// Verifica lote
	If lConfirma .And. lRastro .And. Empty(oModelDC1:GetValue('DCZ_LOTE'))
		WmsMessage(STR0002,WMSA320B01,2) //"Lote Inválido"
		lConfirma := .F.
	EndIf
	//Verifica sub-lote
	If lConfirma .And.DCW->DCW_TPCONF == "2" .And. Rastro(cProduto,'S') .And. Empty(oModelDC1:GetValue('DCZ_SUBLOT')) 
		WmsMessage(STR0003,WMSA320B02,2) //"Sub-Lote inválido!"
		lConfirma := .F.
	EndIf
	If lConfirma .And. lDtValid .And. __lWmsDtCF .And. lRastro .And. Empty(oModelDC1:GetValue('DCZ_DTVAL'))
		WmsMessage(STR0041,WMSA320B18,2) //"Data de validade do lote inválida!"
		lConfirma := .F.
	EndIf
	//Verifica quantidade
	If lConfirma .And. oModelDC1:GetValue('DCZ_QTCONF') <= 0
		oView:GetViewObj("WMSA320BGER")[3]:getFWEditCtrl("DCZ_QTCONF"):oCtrl:SetFocus()
		lConfirma := .F.
	EndIf
	// Preenche modelo de dados
	If lConfirma
		cProduto:= oModelDC1:GetValue('DCZ_PROD')
		cPrdOri := cProduto
		// Verifica se é o novo WMS
		If !lWmsNew
			//validação parâmetro lWmsNpCp
			If lWmsNpCp
				cAliasDCY := GetNextAlias()
				BeginSql Alias caliasDCY
					SELECT Distinct 1
					FROM %Table:DCY% DCY
					WHERE DCY.DCY_FILIAL = %xFilial:DCY%
					AND DCY.DCY_EMBARQ = %Exp:oModelDCW:GetValue('DCW_EMBARQ')%
					AND DCY.DCY_PRDORI = %Exp:cPrdOri% 
					AND DCY.DCY_PROD = %Exp:cProduto%
					AND DCY.%NotDel%
				EndSql
				If (cAliasDCY)->(Eof())
					WmsMessage(STR0039,WMSA320B17,2) //"Produto não pertence a prenota ou documento de entrada relacionado à conferência."
					lConfirma := .F.
				EndIf
				(cAliasDCY)->(dbCloseArea())
			EndIf
			If lConfirma
				aAdd(aProdComp,{oModelDC1:GetValue('DCZ_PROD'),1,oModelDC1:GetValue('DCZ_PROD')})
			EndIf
		Else
			If !oModelDC1:GetValue("DCZ_TPPROD") == "1"
				// Verificar se produto existe na DCY como produto e componente ao mesmo tempo
				cQuery := " SELECT DCY.DCY_PRDORI,"
				cQuery +=        " DCY.DCY_PROD,"
				cQuery +=        " DCY.DCY_LOTE,"
				cQuery +=        " DCY.DCY_SUBLOT"
				cQuery += " FROM "+RetSqlName('DCY')+" DCY"
				cQuery += " WHERE DCY.DCY_FILIAL = '"+xFilial('DCY')+"'"
				cQuery += " AND DCY.DCY_EMBARQ = '"+oModelDCW:GetValue('DCW_EMBARQ')+"'"
				cQuery += " AND DCY.DCY_PROD = '"+cProduto+"'"
				cQuery += " AND DCY.DCY_LOTE = '"+oModelDC1:GetValue('DCZ_LOTE')+"'"
				cQuery += " AND DCY.DCY_SUBLOT = '"+oModelDC1:GetValue('DCZ_SUBLOT')+"'"
				cQuery += " AND DCY.DCY_PRDORI <> DCY.DCY_PROD"
				cQuery += " AND DCY.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
				If (cAliasQry)->(!Eof())
					cPrdOri := (cAliasQry)->DCY_PRDORI
				EndIf
				(cAliasQry)->(dbCloseArea())
				If lWmsNew .And. cPrdOri == cProduto
					cPrdOri := WmsPrdOri(cProduto)
				EndIf
			EndIf
			oProdComp:SetPrdOri(cPrdOri)
			If oProdComp:LoadData(3)
				oProdComp:EstProduto()
				aProdComp:= oProdComp:GetArrProd()
			Else
				aAdd(aProdComp,{oModelDC1:GetValue('DCZ_PROD'),1,oModelDC1:GetValue('DCZ_PROD')})
			EndIf
		EndIf
		// Valida se o produto/quantidade é apta a ser adicionada ao unitizador	
		If lConfirma .And. lUnitiza
			oMntUniItem:SetPrdOri(cPrdOri)
			oMntUniItem:SetProduto(oModelDC1:GetValue('DCZ_PROD'))
			oMntUniItem:SetLoteCtl(oModelDC1:GetValue('DCZ_LOTE'))
			oMntUniItem:SetNumLote(oModelDC1:GetValue('DCZ_SUBLOT'))
			oMntUniItem:SetUsaD0Q(.F.)
			If !(lConfirma := oMntUniItem:VldPrdUni())
				WmsMessage(oMntUniItem:GetErro(),WMSA320B16,2)
			EndIf
			If lConfirma
				//Valida se a quantidade conferida poderá ser adicionada ao unitizador
				lConfirma := VldQtdSld(oModelDC1)
			EndIf
		EndIf

		//Valida Excesso
		If lConfirma .And. lWmsNew
			lConfirma := GeraExcesso(aProdComp,oModel,oView)
		EndIf

		If lConfirma
			//Calcula quantidade já conferida.
			nQtConfPai := CalcQtdConf(oModel,cProduto,cPrdOri)
			
			//Realiza rateio da quantidade origem das linhas da DCY e grava registros
			RateioConf(oModel,aProdComp,nQtConfPai,cPrdOri,cProduto)
		EndIf
	EndIf
	If lConfirma
		oModelDC1:ClearField('DCZ_CODBAR')
		oModelDC1:ClearField('DCZ_PRDORI')
		oModelDC1:ClearField('DCZ_PROD'  )
		oModelDC1:ClearField('DCZ_DPROD' )
		oModelDC1:ClearField('DCZ_LOTE'  )
		oModelDC1:ClearField('DCZ_SUBLOT')
		oModelDC1:ClearField('DCZ_TPPROD')
		oModelDC1:ClearField('DCZ_QTCONF')
		If lDtValid
			oModelDC1:ClearField('DCZ_DTVAL')
		EndIf
		//Limpa variável de controle da data de validade
		oModelDC1:LoadValue("DCZ_ALTLT","2")
		oView:Refresh()
	EndIf
Return .T.
/*--------------------------------------------------------------------------------
---RateioConf 
---Realiza rateio da quantidade origem e grava DCY/DCZ
---Amanda Rosa Vieira
----------------------------------------------------------------------------------*/
Static Function RateioConf(oModel,aProdComp,nQtConfPai,cPrdOri,cProduto)
Local nI        := 1
Local nQtdOri   := 0
Local nDiferenca:= 0
Local lPreNota  := DCW->DCW_TPCONF == '1'
Local lContinua := .F.
Local oModelDCW := oModel:GetModel('WMSA320BDCW')
Local oModelDC1 := oModel:GetModel('WMSA320BGER')
Local oModelDCZ := oModel:GetModel('WMSA320BDCZ')
Local oModelDCY := oModel:GetModel('WMSA320BDCY')
	
	For nI := 1 To Len(aProdComp)
		oModelDCY:GoLine(1)
		// Cria itens na DCY caso for uma conferência de pré-nota ou excesso.
		If lPreNota .And. !oModelDCY:SeekLine({{'DCY_PRDORI',aProdComp[nI][3]},;
												{'DCY_PROD'  , aProdComp[nI][1]},;
												{'DCY_LOTE'  , oModelDC1:GetValue('DCZ_LOTE')},;
												{'DCY_SUBLOT', oModelDC1:GetValue('DCZ_SUBLOT')},;
												{'DCY_LOCAL',  oModelDC1:GetValue('DCZ_LOCAL')}})
				
			//Calculo da quantidade origem
			nQtdOri := 0
			//Caso não tenha encontrado uma linha da DCY correspondente ao lote, 
			//procura sem o lote e então desconta a quantidade origem para criar uma nova linha na DCY
			If oModelDCY:SeekLine({{'DCY_PRDORI',aProdComp[nI][3]},;
										  {'DCY_PROD'  , aProdComp[nI][1]},;
										  {'DCY_LOTE'  , Space(TamSX3("DCY_LOTE")[1])},;
										  {'DCY_SUBLOT', Space(TamSX3("DCY_SUBLOT")[1])},;
										  {'DCY_LOCAL' , oModelDC1:GetValue('DCZ_LOCAL')}})
				
				oModelDCY:SetValue('DCY_QTORIG', oModelDCY:GetValue('DCY_QTORIG')- nQtConfPai*aProdComp[nI][2])
				nQtdOri    := nQtConfPai*aProdComp[nI][2] 
			EndIf				  
			
			oModelDCY:GoLine(oModelDCY:Length())
			If !oModelDCY:IsEmpty()
				oModelDCY:AddLine()
			EndIf
	
			oModelDCY:SetValue('DCY_FILIAL', xFilial('DCY'))
			oModelDCY:SetValue('DCY_EMBARQ', oModelDCZ:GetValue('DCZ_EMBARQ'))
			oModelDCY:SetValue('DCY_PRDORI', aProdComp[nI][3])
			oModelDCY:SetValue('DCY_PROD'  , aProdComp[nI][1])
			oModelDCY:SetValue('DCY_DPROD' , RetField('SB1',1,xFilial('SB1')+cPrdOri,'SB1->B1_DESC'))
			oModelDCY:SetValue('DCY_LOTE'  , oModelDC1:GetValue('DCZ_LOTE'))
			oModelDCY:SetValue('DCY_SUBLOT', oModelDC1:GetValue('DCZ_SUBLOT'))
			If lDtValid
				oModelDCY:SetValue('DCY_DTVAL',  oModelDC1:GetValue('DCZ_DTVAL'))
			EndIf
			oModelDCY:SetValue('DCY_LOCAL',  oModelDC1:GetValue('DCZ_LOCAL'))
			oModelDCY:SetValue('DCY_QTORIG', nQtdOri)
			If (cProduto == aProdComp[nI][1]) .Or. (cProduto == aProdComp[nI][3])
				oModelDCY:SetValue('DCY_QTCONF', Iif(oModelDC1:GetValue('DCZ_PROD') == aProdComp[nI][3],(oModelDC1:GetValue('DCZ_QTCONF') * aProdComp[nI][2]),oModelDC1:GetValue('DCZ_QTCONF')))
			Else
				oModelDCY:SetValue('DCY_QTCONF',0)
			EndIf
		Else  
			//Calculo da quantidade origem
			//Ao conferir pré-nota e o lote não encontra-se informado no documento, 
			//cria-se uma nova linha na DCY com o lote informado e desconta-se a quantidade origem do DCY que possui o lote em branco
			If lPreNota
				nQtdOri :=  nQtConfPai*aProdComp[nI][2]
				nQtdOri := IIF(QtdComp(nQtdOri) > QtdComp(oModelDCY:GetValue('DCY_QTORIG')),nQtdOri,oModelDCY:GetValue('DCY_QTORIG'))
				nDiferenca := IIF(nQtdOri  > oModelDCY:GetValue('DCY_QTORIG'),nQtdOri - oModelDCY:GetValue('DCY_QTORIG'),0)
				oModelDCY:SetValue('DCY_QTORIG',nQtdOri) 
			EndIf	
			If cProduto == aProdComp[nI][1] .Or. cProduto == aProdComp[nI][3]
				oModelDCY:SetValue('DCY_QTCONF', oModelDCY:GetValue('DCY_QTCONF') + (Iif(oModelDC1:GetValue('DCZ_PROD') == aProdComp[nI][3],(oModelDC1:GetValue('DCZ_QTCONF') * aProdComp[nI][2]),oModelDC1:GetValue('DCZ_QTCONF'))))
			EndIf
			If lDtValid
				oModelDCY:SetValue('DCY_DTVAL',  oModelDC1:GetValue('DCZ_DTVAL'))
			EndIf
			//Ajusta quantidade origem do lote
			//Verifica se a quantidade origem aumentou
			If QtdComp(nDiferenca) > 0  
				//Ajusta quantidade origem da linha da DCY que não possui lote informado
				If oModelDCY:SeekLine({{'DCY_PRDORI',aProdComp[nI][3]},;
											  {'DCY_PROD'  , aProdComp[nI][1]},;
											  {'DCY_LOTE'  , Space(TamSX3("DCY_LOTE")[1])},;
											  {'DCY_SUBLOT', Space(TamSX3("DCY_SUBLOT")[1])},;
											  {'DCY_LOCAL' , oModelDC1:GetValue('DCZ_LOCAL')}})
					oModelDCY:SetValue('DCY_QTORIG' , oModelDCY:GetValue('DCY_QTORIG')-nDiferenca)
				EndIf
			EndIf
		EndiF
		lContinua := .F.
		If cProduto <> cPrdOri
			If cProduto == aProdComp[nI][1]
				lContinua := .T.
			EndIf
		Else
			lContinua := .T.
		EndIf
		If lContinua
			// Atualiza itens na DCZ
			oModelDCZ:GoLine(oModelDCZ:Length())
			If oModelDCZ:IsEmpty()
				oModelDCZ:SetValue('DCZ_FILIAL', xFilial('DCZ'))
				oModelDCZ:SetValue('DCZ_EMBARQ', oModelDCW:GetValue('DCW_EMBARQ'))
				oModelDCZ:SetValue('DCZ_OPER'  , __cUserID)
				oModelDCZ:SetValue('DCZ_NOMFUN', RetField('DCD',1,xFilial('DCD')+__cUserID,'DCD->DCD_NOMFUN'))
				oModelDCZ:SetValue('DCZ_PRDORI', aProdComp[nI][3]) // Produto origem
				oModelDCZ:SetValue('DCZ_PROD'  , aProdComp[nI][1]) // Produto componente
				oModelDCZ:SetValue('DCZ_DPROD' , RetField('SB1',1,xFilial('SB1')+cProduto,'SB1->B1_DESC'))
				oModelDCZ:SetValue('DCZ_LOTE'  , oModelDC1:GetValue('DCZ_LOTE'))
				oModelDCZ:SetValue('DCZ_SUBLOT', oModelDC1:GetValue('DCZ_SUBLOT'))
				If lDtValid
					oModelDCZ:SetValue('DCZ_DTVAL' , oModelDC1:GetValue('DCZ_DTVAL'))
				EndIf
				oModelDCZ:SetValue('DCZ_QTCONF', Iif(oModelDC1:GetValue('DCZ_PROD') == aProdComp[nI][3],(oModelDC1:GetValue('DCZ_QTCONF') * aProdComp[nI][2]),oModelDC1:GetValue('DCZ_QTCONF')) )
				oModelDCZ:SetValue('DCZ_QTCFAT', 0)
				oModelDCZ:SetValue('DCZ_QTSOMA', oModelDC1:GetValue('DCZ_QTCONF'))
				oModelDCZ:SetValue('DCZ_IDUNIT', oModelDC1:GetValue('DCZ_IDUNIT'))
				oModelDCZ:SetValue('DCZ_LOCAL',  oModelDC1:GetValue('DCZ_LOCAL'))
			ElseIf oModelDCZ:SeekLine({{'DCZ_OPER'  , __cUserID},;
										{'DCZ_PRDORI', aProdComp[nI][3]},;
										{'DCZ_PROD'  , aProdComp[nI][1]},;
										{'DCZ_LOTE'  , oModelDC1:GetValue('DCZ_LOTE')},;
										{'DCZ_SUBLOT', oModelDC1:GetValue('DCZ_SUBLOT')},;
										{'DCZ_LOCAL' , oModelDC1:GetValue('DCZ_LOCAL')},;
										{'DCZ_IDUNIT', oModelDC1:GetValue('DCZ_IDUNIT')}})
				oModelDCZ:SetValue('DCZ_QTCONF', oModelDCZ:GetValue('DCZ_QTCONF') + (Iif(oModelDC1:GetValue('DCZ_PROD') == aProdComp[nI][3],(oModelDC1:GetValue('DCZ_QTCONF') * aProdComp[nI][2]),oModelDC1:GetValue('DCZ_QTCONF'))) )
				oModelDCZ:SetValue('DCZ_QTSOMA', oModelDCZ:GetValue('DCZ_QTSOMA') + (Iif(oModelDC1:GetValue('DCZ_PROD') == aProdComp[nI][3],(oModelDC1:GetValue('DCZ_QTCONF') * aProdComp[nI][2]),oModelDC1:GetValue('DCZ_QTCONF'))) )
				If lDtValid
					oModelDCZ:SetValue('DCZ_DTVAL' , oModelDC1:GetValue('DCZ_DTVAL'))
				EndIf
			Else
				oModelDCZ:SetNoInsertLine( .F. )
				oModelDCZ:AddLine()
				oModelDCZ:SetValue('DCZ_FILIAL', xFilial('DCZ'))
				oModelDCZ:SetValue('DCZ_EMBARQ', oModelDCW:GetValue('DCW_EMBARQ'))
				oModelDCZ:SetValue('DCZ_OPER'  , __cUserID)
				oModelDCZ:SetValue('DCZ_NOMFUN', RetField('DCD',1,xFilial('DCD')+__cUserID,'DCD->DCD_NOMFUN'))
				oModelDCZ:SetValue('DCZ_PRDORI', aProdComp[nI][3]) // Produto origem
				oModelDCZ:SetValue('DCZ_PROD'  , aProdComp[nI][1]) // Produto componente
				oModelDCZ:SetValue('DCZ_DPROD' , RetField('SB1',1,xFilial('SB1')+cProduto,'SB1->B1_DESC'))
				oModelDCZ:SetValue('DCZ_LOTE', oModelDC1:GetValue('DCZ_LOTE'))
				oModelDCZ:SetValue('DCZ_SUBLOT', oModelDC1:GetValue('DCZ_SUBLOT'))
				If lDtValid
					oModelDCZ:SetValue('DCZ_DTVAL' , oModelDC1:GetValue('DCZ_DTVAL'))
				EndIf
				oModelDCZ:SetValue('DCZ_QTCONF', Iif(oModelDC1:GetValue('DCZ_PROD') == aProdComp[nI][3],(oModelDC1:GetValue('DCZ_QTCONF') * aProdComp[nI][2]),oModelDC1:GetValue('DCZ_QTCONF')))
				oModelDCZ:SetValue('DCZ_QTSOMA', Iif(oModelDC1:GetValue('DCZ_PROD') == aProdComp[nI][3],(oModelDC1:GetValue('DCZ_QTCONF') * aProdComp[nI][2]),oModelDC1:GetValue('DCZ_QTCONF')))
				oModelDCZ:SetValue('DCZ_QTCFAT', 0)
				oModelDCZ:SetValue('DCZ_IDUNIT', oModelDC1:GetValue('DCZ_IDUNIT'))
				oModelDCZ:SetValue('DCZ_LOCAL',  oModelDC1:GetValue('DCZ_LOCAL'))
				oModelDCZ:SetNoInsertLine( .T. )
			EndIf
		EndIf
	Next nI
Return
//----------------------------------------------------------
/*/{Protheus.doc} GravaDados
Realiza o commit dos dados no model e atualiza as informações
na DCY e DCW

@author  Guilherme Alexandre Metzger
@version P11
@since   18/11/14
/*/
//----------------------------------------------------------
Static Function GravaDados(oModel)
Return FwFormCommit(oModel,,{|oModel,cID,cAlias| PosAtuMVC(oModel,cID)},{|oModel| bInTTSAtuMVC(oModel)})
//----------------------------------------------------------
//Bloco de código que será executado após a gravação de cada linha das tabelas que compõem o submodelo de edição.
//----------------------------------------------------------
Static Function bInTTSAtuMVC(oModel)
Local oModelAti := FWModelActive()
Return A320COFDCY(oModelAti:GetModel("WMSA320BDCW"):GetValue("DCW_EMBARQ"),.F.)
//----------------------------------------------------------
//Bloco de código que será executado ao final da transação. 
//----------------------------------------------------------
Static Function PosAtuMVC(oModel,cID)
Local lRet := .T.
	//Limpa variável
	lGerouExc := .F.
	//Gera Unitizador
	If cID == 'WMSA320BDCZ' .And. lUnitiza
		//Se alguma quantidade foi somada ao unitizador, grava D0S
		If QtdComp(oModel:GetValue('DCZ_QTSOMA')) > 0 .And. !Empty(oModel:GetValue('DCZ_IDUNIT'))
			oMntUniItem:SetQuant(oModel:GetValue('DCZ_QTSOMA'))
			oMntUniItem:SetProduto(oModel:GetValue('DCZ_PROD'))
			oMntUniItem:SetPrdOri(oModel:GetValue('DCZ_PRDORI'))
			oMntUniItem:SetLoteCtl(oModel:GetValue('DCZ_LOTE'))
			oMntUniItem:SetNumLote(oModel:GetValue('DCZ_SUBLOT'))
			oMntUniItem:oUnitiz:SetStatus('5')
			If !oMntUniItem:IsDad()
				oMntUniItem:AssignD0S()
			EndIf
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} VldQtdSld
Valida quantidade que está sendo inserida no unitizador
@author  Amanda Rosa Vieira
@version P12
@since   20/04/2017
/*/
//----------------------------------------------------------
Static Function VldQtdSld(oModel)
Local lRet      := .T.
Local nQtdNorma := 0
Local nPesoItem := 0
// Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM := SuperGetMV("MV_NTOL1UM",.F.,0)
	//Carrega tipo do unitizador
	oMntUniItem:oUnitiz:oTipUnit:LoadData()
	//Verifica se o tipo do unitizador permite unitizadores mistos
	If !oMntUniItem:oUnitiz:oTipUnit:CanUniMis() .And. ((!Empty(oModel:GetValue("DCZ_ULTPRD")) .And. oModel:GetValue("DCZ_ULTPRD") != oModel:GetValue('DCZ_PROD')) .Or. oMntUniItem:IsDad())
		WmsMessage(WmsFmtMsg(STR0038,{{"[VAR01]",oMntUniItem:oUnitiz:oTipUnit:GetTipUni()}}),WMSA320B15,2) //Tipo de unitizador [VAR01] não permite montagem de unitizador misto.
		lRet := .F.
	Endif
	//Se não for um unitizador misto e o último produto do unitizador for igual ao produto que está sendo conferido, faz as validações
	If lRet
		If oModel:GetValue("DCZ_MISTO") == "2" .And. ((!Empty(oModel:GetValue("DCZ_ULTPRD")) .And. oModel:GetValue("DCZ_ULTPRD") != oModel:GetValue('DCZ_PROD')) .Or. oMntUniItem:IsDad())
			//Se foi incluido um produto diferente ao unitizador, altera a flag de unitizador misto e grava o último produto incluído
			oModel:SetValue("DCZ_MISTO","1")
			oModel:SetValue("DCZ_ULTPRD",oModel:GetValue('DCZ_PROD')) 
		ElseIf !oMntUniItem:IsDad() .And. oModel:GetValue("DCZ_MISTO") == "2" .And. (Empty(oModel:GetValue("DCZ_ULTPRD")) .Or. oModel:GetValue("DCZ_ULTPRD") == oModel:GetValue('DCZ_PROD'))
			// Busca a norma do produto
			nQtdNorma := DLQtdNorma(oMntUniItem:GetProduto(),oMntUniItem:oUnitiz:GetArmazem(),oMntUniItem:oUnitiz:oEndereco:GetEstFis(),,.F.)
			If QtdComp(nQtdNorma) < QtdComp(oModel:GetValue("DCZ_QTDUNI")+oModel:GetValue("DCZ_QTCONF")) .And.;
				QtdComp(Abs((oModel:GetValue("DCZ_QTDUNI")+oModel:GetValue("DCZ_QTCONF"))-nQtdNorma)) > QtdComp(nToler1UM)
				
				WmsMessage(WmsFmtMsg(STR0022,{{"[VAR01]",cValtoChar(oModel:GetValue("DCZ_QTCONF"))}}),WMSA320B08,2)// Quantidade informada ([VAR01]) ultrapassa a norma do produto.
				lRet := .F.
			EndIf
		EndIf
	EndIf
	//Validações de peso
	If lRet .And. ((oMntUniItem:oUnitiz:GetCapMax() - oModel:GetValue("DCZ_PESO")) < (nPesoItem := oMntUniItem:GetPesoItem(oModel:GetValue("DCZ_QTCONF")))) 
		WmsMessage(WmsFmtMsg(STR0023,{{"[VAR01]",cValtoChar(oMntUniItem:oUnitiz:GetCapMax())}}),WMSA320B09,2) // Peso do produto ultrapassa a capacidade máxima ([VAR01]) do tipo do unitizador!
		lRet := .F.
	EndIf
	If lRet
		//Armazena peso e quantidade do produto conferido
		oModel:SetValue('DCZ_ULTPRD',oModel:GetValue('DCZ_PROD'))
		oModel:SetValue('DCZ_PESO',  oModel:GetValue('DCZ_PESO')+nPesoItem)
		oModel:SetValue('DCZ_QTDUNI',oModel:GetValue('DCZ_QTDUNI')+oModel:GetValue("DCZ_QTCONF"))
	EndIf	
Return lRet 
//----------------------------------------------------------
/*/{Protheus.doc} GeraExcesso
Valida se está sendo conferida quantidade excedente.
@author  Amanda Rosa Vieira
@version P12
@since   24/04/2017
/*/
//----------------------------------------------------------
Static Function GeraExcesso(aProdComp,oModel,oView) 
Local oModelDCW := oModel:GetModel('WMSA320BDCW')
Local oModelDC1 := oModel:GetModel('WMSA320BGER')
Local oModelDCZ := oModel:GetModel('WMSA320BDCZ')
Local oModelDCY := oModel:GetModel('WMSA320BDCY')
Local oDlg      := Nil
Local oBrw      := Nil
Local oCol      := Nil
Local nSaldoPai := oModelDC1:GetValue('DCZ_QTCONF')
Local nI        := 1
Local nQtdExc   := 0
Local nQtdConf  := 0
Local nSaldo    := 0
Local nOpc      := 0
Local nQtdExcPrd:= 0
Local nQtConfPai:= oModelDC1:GetValue('DCZ_QTCONF') 
Local nPos      := 0
Local lRet      := .T.
Local lPrimeiro := .T.
Local lRastro   := Rastro(oModelDC1:GetValue('DCZ_PROD'))
Local lArmExcUni:= WmsArmUnit(__cWmsLcEx) //Indica se armazém de excesso possui controle de unitizador.
Local lArmExcDif:= !(__cWmsLcEx == oModelDC1:GetValue('DCZ_LOCAL')) //Indica se o armazém de excesso é diferente do armazém 'normal'
Local lWmsNpCp  := SuperGetMV("MV_WMSNPCP",.F.,.F.)
Local cPicture  := ""
Local cProduto  := ""
Local cPrdConf  := oModelDC1:GetValue('DCZ_PROD') //Produto informado na conferência
Local aExcesso  := {}
Local aTamSX3   := TamSx3('DCY_QTCONF')
Local bOk       := {|| nOpc := 1, oDlg:End() }
Local bCancel   := {|| nOpc := 0, oDlg:End() }
Local cAliasDCY := Nil

	For nI := 1 To Len(aProdComp) 
		//Se o produto informado é um produto pai ou se o componente(aProdComp[nI][1]) é o mesmo produto que o informado faz os cálculos de excesso.
		If cPrdConf == aProdComp[nI][3] .Or. cPrdConf == aProdComp[nI][1]
			//Calcula quantidade saldo disponível para conferência
			nSaldo := 0 
			If oModelDCY:SeekLine({{'DCY_PRDORI', aProdComp[nI][3]},;
									{'DCY_PROD'  , aProdComp[nI][1]},;
									{'DCY_LOTE'  , oModelDC1:GetValue('DCZ_LOTE')},;
									{'DCY_SUBLOT', oModelDC1:GetValue('DCZ_SUBLOT')},;
									{'DCY_LOCAL' , oModelDC1:GetValue('DCZ_LOCAL')}})
				nSaldo := 	oModelDCY:GetValue('DCY_QTORIG') - oModelDCY:GetValue('DCY_QTCONF')
			EndIf
			If lRastro
				If oModelDCY:SeekLine({{'DCY_PRDORI', aProdComp[nI][3]},;
										{'DCY_PROD'  , aProdComp[nI][1]},;
										{'DCY_LOTE'  , Space(TamSX3("DCY_LOTE")[1])},;
										{'DCY_SUBLOT', Space(TamSX3("DCY_SUBLOT")[1])},;
										{'DCY_LOCAL' , oModelDC1:GetValue('DCZ_LOCAL')}})
					nSaldo += 	oModelDCY:GetValue('DCY_QTORIG') - oModelDCY:GetValue('DCY_QTCONF')
				EndIf
			EndIf
			//Quantidade conferida
			nQtdConf := oModelDC1:GetValue('DCZ_QTCONF')
			If cPrdConf == aProdComp[nI][3]
				nQtdConf := nQtdConf * aProdComp[nI][2]
				//Grava quantidade conferida para o produto pai, o qual será a menor quantidade conferida entre os filhos
				nSaldoFil := nSaldo / aProdComp[nI][2]
				If QtdComp(nSaldoPai) > QtdComp(nSaldoFil)
					nSaldoPai := nSaldoFil
				EndIf
			EndIf
			//Calcula quantidade do excesso
			If QtdComp(nSaldo) > 0
				If QtdComp(nSaldo) < QtdComp(nQtdConf)
					nQtdExc := nQtdConf - nSaldo
				EndIf
			Else
				//Se não encontrou quantidade na DCY, toda a quantidade será jogada em excesso
				nQtdExc := nQtdConf
			EndIf
			//Verifica se há quantidade excedente, para criar as DCY de excesso
			If QtdComp(nQtdExc) > 0
				Aadd(aExcesso,{aProdComp[nI][1],nQtdExc,cPrdConf,oModelDC1:GetValue('DCZ_LOTE'),oModelDC1:GetValue('DCZ_SUBLOT'),__cWmsLcEx}) //Produto|Quantidade|Prd. Origem|Lote|Sub-Lote|Armazém
			EndIf
		EndIf
	Next nI
	If Len(aExcesso) > 0
		// Verificar produto com excesso que não estão na nota e o parâmetro MV_WMSNPCP restrige a conferência
		If lWmsNpCp
			For nI := 1 To Len(aExcesso)
				cAliasDCY := GetNextAlias()
				BeginSql Alias caliasDCY
					SELECT Distinct 1
					FROM %Table:DCY% DCY
					WHERE DCY.DCY_FILIAL = %xFilial:DCY%
					AND DCY.DCY_EMBARQ = %Exp:oModelDCW:GetValue('DCW_EMBARQ')%
					AND DCY.DCY_PRDORI = %Exp:aExcesso[nI][3]% 
					AND DCY.DCY_PROD = %Exp:aExcesso[nI][1]%
					AND DCY.%NotDel%
				EndSql
				If (cAliasDCY)->(Eof())
					WmsMessage(STR0039,WMSA320B17,2) //"Produto não pertence a prenota ou documento de entrada relacionado à conferência."
					lRet := .F.
				EndIf
				(cAliasDCY)->(dbCloseArea())
				If !lRet
					Exit
				EndIf 
			Next nI
		EndIf 
		If lRet
			If lArmExcUni .And. lArmExcDif
			aCab  := {STR0024,STR0025,STR0026,STR0027,STR0028,STR0029} //Produto|Quantidade|Prd. Origem|Lote|Sub-Lote|Armazém
			ASize := {TamSx3("DCY_PROD")[1],TamSx3("DCY_QTCONF")[1],TamSx3("DCY_PRDORI")[1],TamSx3("DCY_LOTE")[1],TamSx3("DCY_SUBLOT")[1],TamSx3("DCY_LOCAL")[1]}
			cPicture := "@E "+Replicate("9",aTamSX3[1]); cPicture += "."+Replicate("9",aTamSX3[2])
	
				WmsMessage(STR0035,WMSA320B13,5,.T.,,STR0036) //Conferência de produto em excesso. //A quantidade excedente ficará pendente de conferência.
	
			DEFINE MSDIALOG oDlg TITLE STR0030 FROM 00,00 TO 350,650 PIXEL // Conferir Excesso
			DEFINE FWFORMBROWSE oBrw DATA ARRAY ALIAS "ARRAY" ARRAY aExcesso NO SEEK NO CONFIG NO REPORT OF oDlg
			ADD COLUMN oCol DATA {|| aExcesso[oBrw:nAT,1]} TITLE aCab[1] TYPE "C" SIZE ASize[1] OF oBrw
			ADD COLUMN oCol DATA {|| aExcesso[oBrw:nAT,2]} TITLE aCab[2] TYPE "N" SIZE ASize[2] DECIMAL aTamSX3[2] PICTURE cPicture ALIGN COLUMN_ALIGN_RIGHT OF oBrw
			ADD COLUMN oCol DATA {|| aExcesso[oBrw:nAT,3]} TITLE aCab[3] TYPE "C" SIZE ASize[3] OF oBrw
			ADD COLUMN oCol DATA {|| aExcesso[oBrw:nAT,4]} TITLE aCab[4] TYPE "C" SIZE ASize[4] OF oBrw
			ADD COLUMN oCol DATA {|| aExcesso[oBrw:nAT,5]} TITLE aCab[5] TYPE "C" SIZE ASize[5] OF oBrw
			ADD COLUMN oCol DATA {|| aExcesso[oBrw:nAT,6]} TITLE aCab[6] TYPE "C" SIZE ASize[6] OF oBrw
			ACTIVATE FWFORMBROWSE oBrw
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel,,,,,,,.F.)
			Else
				nOpc := 1
			EndIf
			If nOpc == 1 
				//Grava flag de excesso gerado
				lGerouExc := .T.
				// Cria itens na DCY
				DCY->(dbSetOrder(1))
				For nI := 1 To Len(aProdComp)
	
					cProduto := aProdComp[nI][1]
	
					// Na conf. de produto pai gera DCY de excesso para todos os componentes
					// Na conf. de produto filho "solto" gera o excesso apenas para este
					If (nPos := AScan(aExcesso,{|x| x[1]+x[3] == cProduto+cPrdConf})) <= 0
						Loop
					EndIf
	
					//Quando o armazém de excesso for unitizado grava a quantidade conferida, 
					//caso contrário o produto ficará pendente de conferência no armazém de excesso para montagem do unitizador. 
					If lArmExcUni .And. lArmExcDif
						nQtdExcPrd := 0
					Else
						nQtdExcPrd := aExcesso[nPos][2]
					EndIf
	
					//Grava excesso das partes
					If !oModelDCY:SeekLine({{'DCY_PRDORI',cPrdConf},;
											{'DCY_PROD'  ,cProduto},;
											{'DCY_LOTE'  ,oModelDC1:GetValue('DCZ_LOTE')},;
											{'DCY_SUBLOT',oModelDC1:GetValue('DCZ_SUBLOT')},;
											{'DCY_LOCAL' ,__cWmsLcEx}})
						
						//Grava quantidade conferida para o produto pai, o qual será a menor quantidade conferida entre os filhos
						nSaldoFil := nQtdExcPrd / aProdComp[nI][2]
						If QtdComp(nQtConfPai) > QtdComp(nSaldoFil)
							nQtConfPai := nSaldoFil
						EndIf
						
						oModelDCY:GoLine(oModelDCY:Length())
						If !oModelDCY:IsEmpty()
							oModelDCY:AddLine()
						EndIf
				
						oModelDCY:SetValue('DCY_FILIAL', xFilial('DCY'))
						oModelDCY:SetValue('DCY_EMBARQ', oModelDCW:GetValue('DCW_EMBARQ'))
						oModelDCY:SetValue('DCY_PRDORI', cPrdConf)
						oModelDCY:SetValue('DCY_PROD'  , cProduto)
						oModelDCY:SetValue('DCY_DPROD' , RetField('SB1',1,xFilial('SB1')+cPrdConf,'SB1->B1_DESC'))
						oModelDCY:SetValue('DCY_LOTE'  , oModelDC1:GetValue('DCZ_LOTE'))
						oModelDCY:SetValue('DCY_SUBLOT', oModelDC1:GetValue('DCZ_SUBLOT'))
						If lDtValid
							oModelDCY:SetValue('DCY_DTVAL',  oModelDC1:GetValue('DCZ_DTVAL'))
						EndIf
						oModelDCY:SetValue('DCY_LOCAL',  __cWmsLcEx)
						oModelDCY:SetValue('DCY_QTORIG', 0)
						oModelDCY:SetValue('DCY_QTCONF', nQtdExcPrd)
					ElseIf (!lArmExcUni .Or. !lArmExcDif)
						If QtdComp(nQtdExcPrd) > 0 
							oModelDCY:SetValue('DCY_QTCONF', oModelDCY:GetValue('DCY_QTCONF')+ nQtdExcPrd)
						EndIf
						If lDtValid
							oModelDCY:SetValue('DCY_DTVAL',  oModelDC1:GetValue('DCZ_DTVAL'))
						EndIf
						If lPrimeiro
							lPrimeiro  := .F.
							nQtConfPai := oModelDCY:GetValue('DCY_QTCONF')
						EndIf						
						//Grava quantidade conferida para o produto pai, o qual será a menor quantidade conferida entre os filhos
						nSaldoFil := oModelDCY:GetValue('DCY_QTCONF') / aProdComp[nI][2]
						If QtdComp(nQtConfPai) > QtdComp(nSaldoFil)
							nQtConfPai := nSaldoFil
						EndIf
					 EndIf
					 
					 // Atualiza itens na DCZ quando o armazém de excesso gravar quantidade conferida
					 If (!lArmExcUni .Or. !lArmExcDif) .And. QtdComp(nQtdExcPrd) > 0 
						oModelDCZ:GoLine(oModelDCZ:Length())
						If oModelDCZ:SeekLine({{'DCZ_OPER'  , __cUserID},;
												{'DCZ_PRDORI', cPrdConf},;
												{'DCZ_PROD'  , cProduto},;
												{'DCZ_LOTE'  , oModelDC1:GetValue('DCZ_LOTE')},;
												{'DCZ_SUBLOT', oModelDC1:GetValue('DCZ_SUBLOT')},;
												{'DCZ_LOCAL' , __cWmsLcEx},;
												{'DCZ_IDUNIT', IIf(!lArmExcDif .And. lArmExcUni,oMntUniItem:GetIdUnit(),Space(TamSX3("DCZ_IDUNIT")[1]))}})
							oModelDCZ:SetValue('DCZ_QTCONF', oModelDCZ:GetValue('DCZ_QTCONF') + nQtdExcPrd)
							oModelDCZ:SetValue('DCZ_QTSOMA', oModelDCZ:GetValue('DCZ_QTSOMA') + nQtdExcPrd)
						Else
							If !oModelDCZ:IsEmpty()
								oModelDCZ:SetNoInsertLine( .F. )
								oModelDCZ:AddLine()
							EndIf
							oModelDCZ:SetValue('DCZ_FILIAL', xFilial('DCZ'))
							oModelDCZ:SetValue('DCZ_EMBARQ', oModelDCW:GetValue('DCW_EMBARQ'))
							oModelDCZ:SetValue('DCZ_OPER'  , __cUserID)
							oModelDCZ:SetValue('DCZ_NOMFUN', RetField('DCD',1,xFilial('DCD')+__cUserID,'DCD->DCD_NOMFUN'))
							oModelDCZ:SetValue('DCZ_PRDORI', cPrdConf)
							oModelDCZ:SetValue('DCZ_PROD'  , cProduto)
							oModelDCZ:SetValue('DCZ_DPROD' , RetField('SB1',1,xFilial('SB1')+cProduto,'SB1->B1_DESC'))
							oModelDCZ:SetValue('DCZ_LOTE'  , oModelDC1:GetValue('DCZ_LOTE'))
							oModelDCZ:SetValue('DCZ_SUBLOT', oModelDC1:GetValue('DCZ_SUBLOT'))
							If lDtValid
								oModelDCZ:SetValue('DCZ_DTVAL'  , oModelDC1:GetValue('DCZ_DTVAL'))
							EndIf
							oModelDCZ:SetValue('DCZ_QTCONF', nQtdExcPrd)
							oModelDCZ:SetValue('DCZ_QTSOMA', nQtdExcPrd)
							oModelDCZ:SetValue('DCZ_QTCFAT', 0)
							oModelDCZ:SetValue('DCZ_IDUNIT', IIf(!lArmExcDif .And. lArmExcUni,oMntUniItem:GetIdUnit(),""))
							oModelDCZ:SetValue('DCZ_LOCAL' , __cWmsLcEx)
							oModelDCZ:SetNoInsertLine( .T. )
						EndIf
					EndIf
					
				Next nI
				//Calcula quantidade conferida do produto pai
				//Gera ou atualiza DCY para produto pai
				If aProdComp[1][1] <> aProdComp[1][3]
					If !oModelDCY:SeekLine({{'DCY_PRDORI',cPrdConf},;
											{'DCY_PROD'  ,cPrdConf},;
											{'DCY_LOTE'  ,oModelDC1:GetValue('DCZ_LOTE')},;
											{'DCY_SUBLOT',oModelDC1:GetValue('DCZ_SUBLOT')},;
											{'DCY_LOCAL' ,__cWmsLcEx}})
					
						oModelDCY:GoLine(oModelDCY:Length())
						If !oModelDCY:IsEmpty()
							oModelDCY:AddLine()
						EndIf
					
						oModelDCY:SetValue('DCY_FILIAL', xFilial('DCY'))
						oModelDCY:SetValue('DCY_EMBARQ', oModelDCW:GetValue('DCW_EMBARQ'))
						oModelDCY:SetValue('DCY_PRDORI', cPrdConf)
						oModelDCY:SetValue('DCY_PROD'  , cPrdConf)
						oModelDCY:SetValue('DCY_DPROD' , RetField('SB1',1,xFilial('SB1')+cPrdConf,'SB1->B1_DESC'))
						oModelDCY:SetValue('DCY_LOTE'  , oModelDC1:GetValue('DCZ_LOTE'))
						oModelDCY:SetValue('DCY_SUBLOT', oModelDC1:GetValue('DCZ_SUBLOT'))
						If lDtValid
							oModelDCY:SetValue('DCY_DTVAL', oModelDC1:GetValue('DCZ_DTVAL'))
						EndIf
						oModelDCY:SetValue('DCY_LOCAL',  __cWmsLcEx)
						oModelDCY:SetValue('DCY_QTORIG', 0)
						oModelDCY:SetValue('DCY_QTCONF', nQtConfPai)
					ElseIf (!lArmExcUni .Or. !lArmExcDif) .And. QtdComp(nQtConfPai) > 0
						oModelDCY:SetValue('DCY_QTCONF', nQtConfPai)
						If lDtValid
							oModelDCY:SetValue('DCY_DTVAL', oModelDC1:GetValue('DCZ_DTVAL'))
						EndIf
					EndIf
				EndIf
				//Verifica saldo disponível do produto pai, quanto este estiver sendo conferido
				If cPrdConf  == aProdComp[1][3]
					If QtdComp(nSaldoPai) > 0
						If QtdComp(nSaldoPai) < QtdComp(oModelDC1:GetValue('DCZ_QTCONF'))
							nQtdExc := oModelDC1:GetValue('DCZ_QTCONF') - nSaldoPai
						EndIf
					Else
						//Se não encontrou quantidade na DCY, toda a quantidade será jogada em excesso
						nQtdExc := nQtdConf
					EndIf
				EndIf
				//Ajusta quantidade que está sendo conferida, removendo o excesso
				oModelDC1:SetValue('DCZ_QTCONF',oModelDC1:GetValue('DCZ_QTCONF')-nQtdExc)
				//Ajusta a quantidade que está no unitizador, bem como o peso para o cálculo da capacidade
				oModelDC1:SetValue('DCZ_QTDUNI',oModelDC1:GetValue('DCZ_QTDUNI') - nQtdExc)
				oModelDC1:SetValue('DCZ_PESO',  oModelDC1:GetValue('DCZ_PESO') - oMntUniItem:GetPesoItem(nQtdExc))
				If QtdComp(oModelDC1:GetValue('DCZ_QTCONF')) <= 0
					oModelDC1:ClearField('DCZ_CODBAR')
					oModelDC1:ClearField('DCZ_PRDORI')
					oModelDC1:ClearField('DCZ_PROD'  )
					oModelDC1:ClearField('DCZ_DPROD' )
					oModelDC1:ClearField('DCZ_LOTE'  )
					oModelDC1:ClearField('DCZ_SUBLOT')
					oModelDC1:ClearField('DCZ_QTCONF')
					If lDtValid
						oModelDC1:ClearField('DCZ_DTVAL')
					EndIf
					//Limpa variável de controle da data de validade
					oModelDC1:LoadValue("DCZ_ALTLT","2")
					oView:Refresh()
					//Retorna falso para não realizar a conferência já que a quantidade ficará zerada
					lRet := .F.
				EndIf
			Else
				//Caso o usuário responda "não", não deve gravar a conferência.
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} CalcQtdConf
Calcula quantidade já conferida para o produto (sem a quantidade em excesso)
@author  Amanda Rosa Vieira
@version P12
@since   05/07/2017
/*/
//----------------------------------------------------------
Static Function CalcQtdConf(oModel,cProduto,cPrdOri)
Local oModelDCY := oModel:GetModel('WMSA320BDCY')
Local oModelDC1 := oModel:GetModel('WMSA320BGER')
Local nQtdConf  := oModelDC1:GetValue('DCZ_QTCONF')
Local lRastro   := Rastro(oModelDC1:GetValue('DCZ_PROD'))
Local nQtdDisp  := 0 //Quantidade disponível para a conferência, DCY_QTORIG total (linhas com e sem lote)
	
	oModelDCY:GoLine(1)
	If oModelDCY:SeekLine({{'DCY_PRDORI' ,cPrdOri},;
							{'DCY_PROD'   ,cProduto},;
							{'DCY_LOTE'   ,oModelDC1:GetValue('DCZ_LOTE')},;
							{'DCY_SUBLOT' ,oModelDC1:GetValue('DCZ_SUBLOT')},;
							{'DCY_LOCAL'  ,oModelDC1:GetValue('DCZ_LOCAL')}})
		nQtdConf += oModelDCY:GetValue('DCY_QTCONF')
		nQtdDisp := oModelDCY:GetValue('DCY_QTORIG')
	EndIf
	
	If lRastro .And. oModelDCY:SeekLine({{'DCY_PRDORI' ,cPrdOri},;
											{'DCY_PROD'   ,cProduto},;
											{'DCY_LOTE'   ,Space(TamSX3("DCY_LOTE")[1])},;
											{'DCY_SUBLOT' ,Space(TamSX3("DCY_SUBLOT")[1])},;
											{'DCY_LOCAL'  ,oModelDC1:GetValue('DCZ_LOCAL')}})
		nQtdDisp += oModelDCY:GetValue('DCY_QTORIG')
	EndIf	
	
	//Desconta quantidade em excesso que já foi gravada em outro ponto
	If nQtdConf > nQtdDisp
		nQtdConf -= (nQtdConf - nQtdDisp)
	EndIf
	
	D11->(DbSetOrder(1)) //D11_FILIAL+D11_PRODUT+D11_PRDORI+D11_PRDCMP
	If D11->(DbSeek(xFilial("D11")+cPrdOri+cPrdOri+cProduto))
		nQtdConf := nQtdConf/D11->D11_QTMULT
	EndIf
	
	//Caso o cálculo do produto pai gere um valor com decimais arredonda para cima dessa forma gera a linha do produto pai de forma coerente com a quantidade conferida para o filho
	If nQtdConf > Int(nQtdConf)
		nQtdConf := Int(nQtdConf)+1
	EndIf
Return nQtdConf
//----------------------------------------------------------
/*/{Protheus.doc} TrigDtVal
Trigger disparada para efetuar o preenchimento da data de validade do lote.
@author  amanda.vieira
@Since   21/09/2020
/*/
//----------------------------------------------------------
Static Function TrigDtVal(oModel)
Local dRet      := cToD("")
Local cAliasSB8 := ""
Local cAliasDCY := ""
Local cWhere    := ""
Local cPrdOri   := oModel:GetValue("DCZ_PRDORI")
Local cProduto  := oModel:GetValue("DCZ_PROD")
Local cLocal    := oModel:GetValue("DCZ_LOCAL")
Local cLoteCtl  := oModel:GetValue("DCZ_LOTE")
Local cNumLote  := oModel:GetValue("DCZ_SUBLOT")
Local oModelAti := FWModelActive()
Local oModelDCZ := oModelAti:GetModel('WMSA320BDCZ')
Local cEmbarque := DCW->DCW_EMBARQ
Local lComponente := oModel:GetValue("DCZ_TPPROD") == "2"

	If !Empty(cLoteCtl)
		If lComponente .And. lWmsNew .And. cPrdOri == cProduto
			cPrdOri := WmsPrdOri(cProduto)
		EndIf
		cWhere := "%"
		If !Empty(cNumLote)
			cWhere += " AND SB8.B8_NUMLOTE = '"+cNumLote+"'"
		EndIf
		cWhere += "%"
		cAliasSB8 := GetNextAlias()
		BeginSql Alias cAliasSB8
			SELECT SB8.B8_DTVALID 
			  FROM %Table:SB8% SB8
			 WHERE SB8.B8_FILIAL = %xFilial:SB8%
			   AND SB8.B8_PRODUTO = %Exp:cPrdOri%
			   AND SB8.B8_LOCAL = %Exp:cLocal%
			   AND SB8.B8_LOTECTL = %Exp:cLoteCtl%
			   AND SB8.%NotDel%
			   %Exp:cWhere%
		EndSql
		If (cAliasSB8)->(!EoF())
			dRet := SToD((cAliasSB8)->B8_DTVALID)
			//Indica que a data de validade foi preenchida com base na SB8 e não deve ser alterada
			oModel:LoadValue("DCZ_ALTLT","1")			
		EndIf
		(cAliasSB8)->(dbCloseArea())

		If Empty(dRet)
			cWhere := "%"
			If !Empty(cNumLote)
				cWhere += "AND DCY.DCY_SUBLOT = '"+cNumLote+"'"
			EndIf
			cWhere := "%"
			cAliasDCY := GetNextAlias()
			BeginSql Alias cAliasDCY
				SELECT DCY.DCY_DTVAL
				  FROM %Table:DCY% DCY
				 WHERE DCY.DCY_FILIAL = %xFilial:DCY%
				   AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
				   AND DCY.DCY_PRDORI = %Exp:cPrdOri%
				   AND DCY.DCY_LOTE = %Exp:cLoteCtl%
				   AND DCY.DCY_LOCAL = %Exp:cLocal%
				   AND DCY.%NotDel%
				   %Exp:cWhere%
			EndSql
			If (cAliasDCY)->(!EoF())
				dRet := SToD((cAliasDCY)->DCY_DTVAL)
				//Indica que a data de validade foi preenchida com base na DCY já existente e não deve ser alterada
				oModel:LoadValue("DCZ_ALTLT","1")
			EndIf
			(cAliasDCY)->(dbCloseArea())
		EndIf

		If Empty(dRet)
			If oModelDCZ:SeekLine({{'DCZ_OPER'  , __cUserID},;
								   {'DCZ_PRDORI', cPrdOri},;
								   {'DCZ_LOTE'  , cLoteCtl},;
								   {'DCZ_SUBLOT', cNumLote},;
								   {'DCZ_LOCAL' , cLocal}})
				dRet := oModelDCZ:GetValue('DCZ_DTVAL') //Sugere data de validade previamente informada
			EndIf
		EndIf

		If Empty(dRet)
			oModel:LoadValue("DCZ_ALTLT","2") //Indica que não encontrou lote para sugerir
		EndIf
	EndIf
Return dRet
//----------------------------------------------------------
/*/{Protheus.doc} WmsPrdOri
Retorna produto origem
@author  amanda.vieira
@Since   21/09/2020
/*/
//----------------------------------------------------------
Function WmsPrdOri(cProduto)
Local cPrdOri := cProduto
Local cAliasD11 := GetNextAlias()
	BeginSql Alias cAliasD11
		SELECT D11.D11_PRDORI
		  FROM %Table:D11% D11
		 WHERE D11.D11_FILIAL = %xFilial:D11%
		   AND D11.D11_PRDCMP = %Exp:cProduto%
		   AND D11.%NotDel%
	EndSql
	If (cAliasD11)->(!Eof())
		cPrdOri := (cAliasD11)->D11_PRDORI
	EndIf
	(cAliasD11)->(dbCloseArea())

Return cPrdOri
