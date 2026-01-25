#Include "TMSA530.ch"
#include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º  TMSA530   º Autor ºRodrigo Sartorio    º Data º 24/07/02 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±   
±±º Programa  º  Tipos de Veiculo                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   º TMSA530()                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametrosº                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   º NIL                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       º SIGATMS - Gestao de Transportes                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSA530()

Local oBrowse := Nil

Private aRotina := MenuDef()

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("DUT")
	oBrowse:SetDescription(STR0001) //"Tipos de Veiculo"
	oBrowse:Activate()

Return Nil

//-------------------------------------
/*	Modelo de Dados
@author		Jefferson Tomaz
@version	P10 R1.4
@build		7.00.101202A
@since		31/03/2011
@return		oModel Objeto do Modelo*/
//-------------------------------------
Static Function ModelDef()
Local oModel	:= Nil
Local oStruDUT	:= FWFormStruct(1,"DUT")
Local bPosValid	:= { |oMdl| TA530ExcOk(oMdl) }
Local bComValid := { |oMdl| TA530ComOk(oMdl) }

oModel:= MpFormMOdel():New("TMSA530",/*PREVAL*/, bPosValid , bComValid ,/*BCANCEL*/)
oModel:AddFields("TMSA530_DUT",Nil,oStruDUT,/*prevalid*/,,/*bCarga*/)
oModel:SetDescription(STR0001) // "Cadastro de CFOP x Segmento" --  Metodo XML
oModel:GetModel("TMSA530_DUT"):SETDESCRIPTION(STR0001) // "Cadastro de CFOP x Segmento"
oModel:SetPrimaryKey({"DUT_FILIAL","DUT_TIPVEI"})

Return ( oModel )

//---------------------------------------
/*	Exibe browser de acordo com estrutura
@author 	Jefferson Tomaz
@version	P10 R1.4
@build		7.00.101202A
@since		31/03/2011
@return		oView Objeto do View*/
//---------------------------------------
Static Function ViewDef()

Local oModel := FwLoadModel("TMSA530")
Local oView := Nil

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField("TMSA530_DUT", FWFormStruct(2,"DUT"))
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("TMSA530_DUT","TELA")

Return(oView)

//---------------------------------------
/*	MenuDef do Browser
@author		Jefferson Tomaz
@version	P10 R1.4
@build		7.00.101202A
@since		31/03/2011
@return		aRotina array com o MENUDEF*/
//---------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"         OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSA530" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSA530" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSA530" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSA530" OPERATION 5 ACCESS 0 // "Excluir"

Return ( aRotina )

//-----------------------------------------------------
/*	Valida em MVC a exclusão do registro.
@author		Jefferson Tomaz
@version	P10 R1.4
@build		7.00.101202A
@since		31/03/2011
@return		lRet Valor lógico que indica o retorno*/
//------------------------------------------------------
Function TA530ExcOk(oMdl)

Local lRet      :=.T.
Local nOperation:= 0
Local cQuery    :=""
Local cAliasTop := "DA3"
Local aAreaAnt  :=GetArea()
Local lIntGFE := SuperGetMv("MV_INTGFE",.F.,.F.)
Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")

nOperation := oMdl:GetOperation()

If nOperation == 5

	cAliasTop := GetNextAlias()
	cQuery := "SELECT DA3_COD FROM "+RetSqlName("DA3")+" "
	cQuery += "WHERE DA3_FILIAL='"+xFilial("DA3")+"' AND "
	cQuery += "DA3_TIPVEI='"+DUT->DUT_TIPVEI+"' AND D_E_L_E_T_=' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
	If !(cAliasTop)->(Eof())
		Help(" ",1,"TMSA53001",,(cAliasTop)->DA3_COD,3,1) //"O tipo de veiculo nao pode ser excluido pois esta cadastrado no tipo do veiculo"
		lRet:=.F.
	EndIf
	(cAliasTop)->(dbCloseArea())

	If lRet
		cAliasTop := GetNextAlias()
		cQuery := "SELECT DTT_TABCAR FROM "+RetSqlName("DTT")+" "
		cQuery += "WHERE DTT_FILIAL='"+xFilial("DTT")+"' AND "
		cQuery += "DTT_TIPVEI='"+DUT->DUT_TIPVEI+"' AND D_E_L_E_T_=' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
		If !(cAliasTop)->(Eof())
			Help(" ",1,"TMSA53002",,(cAliasTop)->DTT_TABCAR,3,6) //"O tipo de veiculo nao pode ser excluido pois esta cadastrado na tabela de carreteiro"
			lRet:=.F.
		EndIf
		(cAliasTop)->(dbCloseArea())
	EndIf

	If lRet
		cAliasTop := GetNextAlias()
		cQuery := "SELECT DT3_CODPAS FROM "+RetSqlName("DT3")+" "
		cQuery += "WHERE DT3_FILIAL='"+xFilial("DT3")+"' AND "
		cQuery += "DT3_TIPVEI='"+DUT->DUT_TIPVEI+"' AND D_E_L_E_T_=' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
		If !(cAliasTop)->(Eof())
			Help(" ",1,"TMSA53003",,(cAliasTop)->DT3_CODPAS,3,6) //"O tipo de veiculo esta associado a um componente de frete, exclusao nao permitida."
			lRet:=.F.
		EndIf
		(cAliasTop)->(dbCloseArea())
	EndIf	
	
	RestArea(aAreaAnt)
	
EndIf

//Integração Protheus com SIGAGFE
If lRet .And. lIntGFE == .T. .And. cIntGFE2 $ "1S"
	If !InterGV3(nOperation,.F.)
		lRet := .F.
	EndIf
		
EndIf

Return ( lRet )
//-----------------------------------------------------
/*	Valida em MVC o commit do registro.
@author Felipe Machado de Oliveira
@version P11
@since 18/04/2013
*/
//------------------------------------------------------
Function TA530ComOk(oMdl)
	Local aArea   := GetArea()
	Local lRet    := .T.
	Local nOpc    := oMdl:GetOperation()
	Local lIntGFE := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")	
	
	Begin Transaction
	If FwFormCommit(oMdl)
		//Integração Protheus com SIGAGFE
		If lIntGFE == .T. .And. cIntGFE2 $ "1"
			If !InterGV3(nOpc,.T.,oMdl)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	End Transaction
	
	TMSA530POS(nOpc)
	
	RestArea(aArea)
	
Return lRet
//-----------------------------------------------------
/*/	Integra a tabela DUT(Protheus) com GV3(SIGAGFE) a cada registro novo
@author Felipe Machado de Oliveira
@version P11
@since 18/04/2013
/*/
//------------------------------------------------------
Static Function InterGV3(nOperation,lCommit,oMdl)
	Local aAreaGV3 := GV3->( GetArea() )
	Local lRet :=  .T.
	Local oModelGV3 := FWLoadModel("GFEA045")
	Local nTpOpSetad
	Local cMsg
	Local cDUT_DESCR
	
	if lCommit
		cDUT_DESCR := oMdl:GetValue("TMSA530_DUT", "DUT_DESCRI")
	Else
		cDUT_DESCR := FwFldGet("DUT_DESCRI")
	EndIf

	dbSelectArea("GV3")
	GV3->( dbSetOrder(1) )
	GV3->( dbSeek( xFilial("GV3")+M->DUT_TIPVEI ) )
	If !GV3->( Eof() ) .And. GV3->GV3_FILIAL == xFilial("GV3");
						 .And. AllTrim(GV3->GV3_CDTPVC) == AllTrim(M->DUT_TIPVEI)

		oModelGV3:SetOperation( MODEL_OPERATION_UPDATE )			
		nTpOpSetad := MODEL_OPERATION_UPDATE
	Else	
		oModelGV3:SetOperation( MODEL_OPERATION_INSERT )
		nTpOpSetad := MODEL_OPERATION_INSERT
	EndIf
	
	oModelGV3:Activate()
	
	If nOperation <> MODEL_OPERATION_DELETE
		oModelGV3:SetValue( "GFEA045_GV3", "GV3_DSTPVC", cDUT_DESCR )
		
		If M->DUT_CATVEI $ '36'
			oModelGV3:SetValue( 'GFEA045_GV3', 'GV3_POSCOM','2' )
		Else
			oModelGV3:SetValue( 'GFEA045_GV3', 'GV3_POSCOM','1' )
		EndIf

		If nTpOpSetad == MODEL_OPERATION_UPDATE
			If nOperation == MODEL_OPERATION_INSERT
				oModelGV3:LoadValue( "GFEA045_GV3", "GV3_SIT", "1" )
			EndIf
		Else
			oModelGV3:SetValue( "GFEA045_GV3", "GV3_FILIAL", xFilial("DUT") )
			oModelGV3:SetValue( "GFEA045_GV3", "GV3_CDTPVC", M->DUT_TIPVEI )
		EndIf
	Else
		If nTpOpSetad <> MODEL_OPERATION_INSERT
			oModelGV3:LoadValue( "GFEA045_GV3", "GV3_SIT", "2" )
		EndIf
	EndIf
	
	If nOperation != MODEL_OPERATION_DELETE .Or. nTpOpSetad != MODEL_OPERATION_INSERT
		If oModelGV3:VldData()
			If lCommit
				oModelGV3:CommitData()
			EndIf
		Else
			lRet := .F.
			cMsg := STR0008+CRLF+CRLF+oModelGV3:GetErrorMessage()[6]//"Inconsistência com o Frete Embarcador (SIGAGFE): "##
		EndIf
	EndIf
	
	oModelGV3:Deactivate()
	
	If !lRet
		Help( ,, STR0007,,cMsg, 1, 0 ) //"Atenção"
	EndIf
	
	RestArea( aAreaGV3 )
	
Return lRet

/*/{Protheus.doc} TMSA530POS
	Integração com o cockpit logístico
@author siegklenes.beulke
@since 08/12/2015
@version 1.0
@param nOpc, numeric, Operação sob o registro posicionado
@example
(examples)
@see (links_or_references)
/*/
Function TMSA530POS(nOpc)
	If (nOpc == 3 .Or. nOpc == 4) .And. SuperGetMv("MV_CPLINT",.F.,"2") == "1" .And. SuperGetMv("MV_CPLTPV",.F.,"2") == "1"
		OMSXJOBCAD("DUT", 4)
	EndIf
Return
