#include "protheus.ch"
#include "fwmvcdef.ch"
#include "wmssaas501.ch"

Static __lRLoadPg := .T.
Static __lRViewPg := .T.
Static __lPresF12 := .F.
Static __nTamLote := TamSx3("D4_LOTECTL")[1]
Static __nTamSLot := TamSx3("D4_NUMLOTE")[1]
Static __nTamOpOr := TamSx3("D4_OPORIG")[1]

#define WMSSAAS50101 "WMSSAAS50101"
#define WMSSAAS50102 "WMSSAAS50102"
#define WMSSAAS50103 "WMSSAAS50103"
#define WMSSAAS50104 "WMSSAAS50104"
#define WMSSAAS50105 "WMSSAAS50105"
#define WMSSAAS50106 "WMSSAAS50106"
#define WMSSAAS50107 "WMSSAAS50107"
#define WMSSAAS50108 "WMSSAAS50108"
#define WMSSAAS50109 "WMSSAAS50109"
#define WMSSAAS50110 "WMSSAAS50110"
#define WMSSAAS50111 "WMSSAAS50111"
#define WMSSAAS50112 "WMSSAAS50112"
#define WMSSAAS50113 "WMSSAAS50113"
#define WMSSAAS50114 "WMSSAAS50114"

#define TRANSACAO_AUTOMATICA  1
#define MANUFATURA_REQUISICAO "08"

/*/{Protheus.doc} WmsSaas501
	(Geração de Requisições Empenhadas - WMS SaaS)
	Mantem a view executando ate o usuario clicar na opcao fechar/cancelar do modelo
	Caso o usuario pressione F12, a view sera encerrada e inicializada novamente
	Caso o usuario confirme a requisicao de uma op, a tela também será reiniciada
	@type  Function
	@author carlos.augusto
	@since 05/12/2024
	@see (DLOGWMSMSP-16968)
	/*/
Function WmsSaas501()
	DbSelectArea("DBX")

	SetKey(VK_F12,{||__lRViewPg := .T., WMSS501SX1()})

	While __lRLoadPg
		__lRLoadPg := .F.
		WMSS500LPg()
	EndDo

	SetKey(VK_F12,Nil)
	__lPresF12 := .F.
	__lRLoadPg := .T.
	__lRViewPg := .T.	
Return


/*/{Protheus.doc} WMSS500LPg
	Inicializa a view
	@type  Function
	@author carlos.augusto
	@since 05/12/2024
	@see (DLOGWMSMSP-16968)
	/*/
Static Function WMSS500LPg()
Local aButtons 		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	If __lRViewPg	
		If Pergunte("WMSSAAS501",__lRViewPg)
			FWExecView( STR0026, "VIEWDEF.WmsSaas501",MODEL_OPERATION_UPDATE,,{|| .T.},,,aButtons,{|| WMSS501Can() }) //"WMS SaaS "
		ElseIf __lPresF12
			FWExecView( STR0026, "VIEWDEF.WmsSaas501",MODEL_OPERATION_UPDATE,,{|| .T.},,,aButtons,{|| WMSS501Can() }) //"WMS SaaS "
		EndIf
	Else
		Pergunte("WMSSAAS501",__lRViewPg)
		FWExecView( STR0026, "VIEWDEF.WmsSaas501",MODEL_OPERATION_UPDATE,,{|| .T.},,,aButtons,{|| WMSS501Can() }) //"WMS SaaS "
	EndIf
Return


/*/{Protheus.doc} ModelDef
	Definicao do modelo de dados
	@type  Function
	@author carlos.augusto
	@since 05/12/2024
	@see (DLOGWMSMSP-16968)
	/*/
Static Function ModelDef()
local oModel as object
local oStrField as object
local oStruSC2 as object
Local oStruSD4 	:= FwFormStruct( 1, "SD4" )
Local bLoad := {|oGridModel| loadGrid(oGridModel)}

	oStrField := FWFormModelStruct():New()

	oStrField:addTable("", {"C_OCULTO"}, "X", {|| ""})
	oStrField:addField("Oculto 01", "Oculto", "C_OCULTO", "C", 15)

	oStruSC2 := FWFormStruct(1, "SC2")

	oModel := MPFormModel():New("WmsSaas501", /*<bPre >*/, /* bPos  */,  {|oModel| GrvModelo(oModel)} , /*<bCancel >*/ )

	oModel:addFields("CAB_OCULTO", /*cOwner*/, oStrField, /*bPre*/, /*bPost*/, {|oMdl| loadFldOct(oMdl)})

	oStruSC2:AddField(STR0002,STR0003,"C2_PRODESC","C",50,0,{|| .T.},{|| .F.},Nil,Nil,{|| Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_DESC")  },.F.,.T.,.T., "")//"Descrição do Produto""Desc Prod"
	oStruSD4:AddField(STR0002,STR0003,"D4_PRODESC","C",50,0,{|| .T.},{|| .F.},Nil,Nil,{|| Posicione("SB1",1,xFilial("SB1")+SD4->D4_COD,"B1_DESC")  },.F.,.T.,.T., "") //"Descrição do Produto""Desc Prod"

	oStruSD4:AddField( STR0004, STR0006, 'D4_SALDO', 'N' , TamSX3("D4_QUANT")[1] ,TamSX3("D4_QUANT")[2] , /*bValid*/, /*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/, .F./*lKey*/, /*lNoUpd*/,   /*lVirtual*/)//"Saldo Disponível"
	oStruSD4:AddField( STR0005, STR0007, 'D4_QTDREQ','N' , TamSX3("D4_QUANT")[1] ,TamSX3("D4_QUANT")[2] , /*bValid*/{|| WMSS501VSl()}, /*bWhen*/, /*aValues*/ ,/*lObrigat*/,/*bInit*/, .F./*lKey*/, /*lNoUpd*/,   /*lVirtual*/)//"Quantidade a Requisitar"

	oModel:addGrid("MdItemSC2", "CAB_OCULTO", oStruSC2, /*bLinePre*/, /*bLinePost*/, /*bLinePre */, /*bPost*/, {|oMdl| WMSS501SC2(oMdl)})
	oModel:GetModel("MdItemSC2"):SetForceLoad(.T.)
	oModel:setDescription(STR0001) //Geração de Requisições Empenhadas

	oModel:AddGrid( 'MdItemSD4', 'MdItemSC2', oStruSD4, /*bLinePre*/, , , ,bLoad)

	oModel:GetModel("MdItemSD4"):SetForceLoad(.T.)
	oModel:SetRelation( 'MdItemSD4', { { 'D4_FILIAL', 'FWxFilial( "SD4" )' }, { 'D4_OP', 'C2_OP' }},  SD4->( IndexKey( 2 )))
	oModel:GetModel('MdItemSD4'):SetUniqueLine({"D4_FILIAL","D4_COD","D4_OP","D4_TRT","D4_LOTECTL","D4_NUMLOTE","D4_LOCAL","D4_ORDEM","D4_OPORIG","D4_SEQ"})

	oModel:GetModel( "MdItemSD4"):SetOptional(.T.)

	oStruSC2:SetProperty( "*", MODEL_FIELD_OBRIGAT , .F.  )
	oStruSD4:SetProperty( "*", MODEL_FIELD_OBRIGAT , .F.  )
	oStruSC2:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )
	oStruSD4:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )
	oStruSD4:SetProperty("D4_SALDO" , MODEL_FIELD_WHEN , {|| .F. } )
	oStruSD4:SetProperty("D4_QTDREQ" , MODEL_FIELD_WHEN , {|| .T. } )

	oModel:GetModel('MdItemSC2'):SetNoDeleteLine(.T.)
	oModel:GetModel('MdItemSC2'):SetNoInsertLine(.T.)
	oModel:GetModel('MdItemSD4'):SetNoDeleteLine(.T.)
	oModel:GetModel('MdItemSD4'):SetNoInsertLine(.T.)

Return oModel


/*/{Protheus.doc} ViewDef
	Definicao da view
	@type  Function
	@author carlos.augusto
	@since 05/12/2024
	@see (DLOGWMSMSP-16968)
	/*/
Static Function ViewDef()
local oView as object
local oModel as object
local oStrCab  := FWFormViewStruct():New()
local oStruSC2 := FWFormStruct(2, 'SC2' , { |x| ALLTRIM(x)  $ 'C2_FILIAL,C2_OP,C2_PRODUTO,C2_LOCAL,C2_QUANT,C2_EMISSAO' })
Local oStruSD4 := FWFormStruct(2, 'SD4' , { |x| ALLTRIM(x)  $ 'D4_FILIAL,D4_LOCAL,D4_COD,B1_DESCRIC,D4_QTDEORI' })

	oModel := FWLoadModel("WmsSaas501")
	oView := FwFormView():New()

	oStrCab:addField("C_OCULTO", "01" , "Oculto 01", "Oculto", , "C" )

	oStruSC2:SetProperty("C2_OP" ,      MVC_VIEW_ORDEM  , "02")
	oStruSC2:SetProperty("C2_LOCAL" ,   MVC_VIEW_ORDEM  , "03")
	oStruSC2:SetProperty("C2_PRODUTO" , MVC_VIEW_ORDEM  , "04")
	oStruSC2:AddField("C2_PRODESC" ,'05' , STR0002, STR0003, {} ,"G" ,'@!', NIL, NIL, .F., NIL, NIL, NIL,	NIL, NIL, .T.) //"Descrição do Produto"
	oStruSC2:SetProperty("C2_EMISSAO" , MVC_VIEW_ORDEM  , "06")
	oStruSC2:SetProperty("C2_QUANT" ,   MVC_VIEW_ORDEM  , "07")

	oStruSD4:SetProperty("D4_COD" ,     MVC_VIEW_ORDEM  , "01")
	oStruSD4:AddField("D4_PRODESC"  ,'02' , STR0002, STR0003, {} ,"G" ,'@!', NIL, NIL, .F., NIL, NIL, NIL,	NIL, NIL, .T.)
	oStruSD4:SetProperty("D4_LOCAL" ,   MVC_VIEW_ORDEM  , "03")
	oStruSD4:SetProperty("D4_QTDEORI" , MVC_VIEW_ORDEM  , "04")
	oStruSD4:AddField("D4_SALDO", "05", STR0004, STR0006, {},"N","@E 9,999,999,999.99999",Nil,Nil,.F.,"1",Nil,Nil,Nil,Nil,.T.) //"Saldo Disponível"
	oStruSD4:AddField("D4_QTDREQ", "06", STR0005, STR0007, {},"N","@E 9,999,999,999.99999",Nil,Nil,.T.,"1",Nil,Nil,Nil,Nil,.T.) //"Quantidade a Requisitar"

	oView:AddOtherObject("BTN_REQTAR" , {|oPanel,oModel| WMSS501BTN(oPanel,oModel)}  )

	oView:setModel(oModel)
	oView:addField("CAB", oStrCab, "CAB_OCULTO")
	oView:addGrid("VIEW_SC2", oStruSC2, "MdItemSC2")

	oView:SetViewProperty('VIEW_SC2' , 'ENABLENEWGRID' )
	oView:SetViewProperty("VIEW_SC2", "GRIDFILTER", {.T.})
	oView:SetViewProperty("VIEW_SC2", "GRIDSEEK", {.T.})

	oView:AddGrid( 'VIEW_SD4', oStruSD4, 'MdItemSD4' )

	oView:createHorizontalBox("VIEW_HOR", 100 )

	oView:CreateVerticalBox( 'VIEW_VERT', 100, 'VIEW_HOR' )
	oView:CreateHorizontalBox( 'OCULTAR', 0, 'VIEW_VERT' )

	oView:CreateHorizontalBox( 'SC2_VIEW', 40, 'VIEW_VERT' )
	oView:CreateFolder('FLD_SC2','SC2_VIEW')
	oView:AddSheet('FLD_SC2','PASTA_SC2', STR0008 ) //"Ordens de Produção"
	oView:CreateHorizontalBox( 'SC2_PN', 100, , , 'FLD_SC2', 'PASTA_SC2')

	oView:CreateHorizontalBox( 'SD4_VIEW' , 60, 'VIEW_VERT'  )
	oView:CreateFolder('FLD_SD4','SD4_VIEW')
	oView:AddSheet('FLD_SD4','PASTA_SD4', STR0009 ) //"Empenhos da Ordem de Produção"
	oView:CreateHorizontalBox( 'SD4_PNCIMA', 15, , , 'FLD_SD4', 'PASTA_SD4')

	oView:CreateHorizontalBox( 'SD4_PNBAIXO',  85, , , 'FLD_SD4', 'PASTA_SD4')

	oView:setOwnerView("CAB", "OCULTAR" )
	oView:setOwnerView("VIEW_SC2", "SC2_PN")
	oView:setOwnerView("BTN_REQTAR", "SD4_PNCIMA")
	oView:setOwnerView("VIEW_SD4", "SD4_PNBAIXO")

	oView:SetProgressBar(.T.)

Return oView


/*/{Protheus.doc} GrvModelo
	Funcao de commit caso utilizem o modelo
	@type  Function
	@author carlos.augusto
	@since 05/12/2024
	@see (DLOGWMSMSP-16968)
	/*/
Static Function GrvModelo(oModel)
Local oModelSC2 := oModel:GetModel("MdItemSC2")
Local oModelSD4 := oModel:GetModel("MdItemSD4")
Local nX 		:= 1
Local lRet      := .T.
Local lGerouReq := .T. 

    //chamada de funcao para validacao do armazem de empenho que nao deve controlar SAAS 
	lRet := WMSSVArEmp(.F. )

	If lRet
		For nX := 1 To  oModelSD4:Length()
			oModelSD4:Goline( nX )
			If oModelSD4:GetValue("D4_QTDREQ") > 0
            	If !WMSSGERREQ(oModelSC2:GetDataID(oModelSC2:GetLine()), oModelSD4:GetDataID(nX), oModelSD4:GetValue("D4_QTDREQ"))
                   lGerouReq := .F. 
				EndIf
			EndIf
		Next nX
	EndIf 

	If !lRet 
		oModel:SetErrorMessage('MdItemSD4',,,,WMSSAAS50111, STR0027, STR0028) //"Os registros de requisição possuem empenho em local de estoque que controla WMS SAAS." "Não foram geradas requisições."
	ElseIf !lGerouReq
		oModel:SetErrorMessage('MdItemSD4',,,,WMSSAAS50112, STR0030, STR0031) //"Existem registros de requisição que possuem empenho em local de estoque que controlam WMS SAAS." "Para estes registros não foram geradas requisições."
	EndIf		
				
Return lRet


/*/{Protheus.doc} WMSS501SC2
	Ordens de producao que podem ser integradas
	@type  Function
	@author carlos.augusto
	@since 05/12/2024
	@see (DLOGWMSMSP-16968)
	/*/
Static Function WMSS501SC2(oModel)
Local aData     as array
Local cAliasSC2 as char
Local cWhere    as char

	cAliasSC2 := GetNextAlias()

	cWhere := "% SC2.C2_FILIAL = '" + xFilial("SC2") + "'" 

	If (!Empty(MV_PAR03) .Or. Upper(MV_PAR04) == Replicate('Z', Len(MV_PAR04))) .And. MV_PAR03 != MV_PAR04
		cWhere  += " AND SC2.C2_OP >= '"+MV_PAR03+"'"
		cWhere  += " AND SC2.C2_OP <= '"+MV_PAR04+"'"
	ElseIf MV_PAR03 == MV_PAR04
		cWhere  += " AND SC2.C2_OP = '"+MV_PAR03+"'"
	EndIf

	If (!Empty(MV_PAR05) .Or. Upper(MV_PAR06) == Replicate('Z', Len(MV_PAR06))) .And. MV_PAR05 != MV_PAR06
		cWhere  += " AND SC2.C2_PRODUTO >= '"+MV_PAR05+"'"
		cWhere  += " AND SC2.C2_PRODUTO <= '"+MV_PAR06+"'"
	ElseIf MV_PAR05 == MV_PAR06
		cWhere  += " AND SC2.C2_PRODUTO = '"+MV_PAR05+"'"
	EndIf

	If MV_PAR01 != MV_PAR02
		cWhere  += " AND SC2.C2_EMISSAO >= '"+DTOS(MV_PAR01)+"'"
		cWhere  += " AND SC2.C2_EMISSAO <= '"+DTOS(MV_PAR02)+"'"
	Else
		cWhere  += " AND SC2.C2_EMISSAO = '"+DTOS(MV_PAR01)+"'"
	EndIf

	If (!Empty(MV_PAR07) .Or. Upper(MV_PAR08) == Replicate('Z', Len(MV_PAR08))) .And. MV_PAR07 != MV_PAR08
		cWhere  += " AND SD4.D4_COD >= '"+MV_PAR07+"'"
		cWhere  += " AND SD4.D4_COD <= '"+MV_PAR08+"'"
	ElseIf MV_PAR07 == MV_PAR08
		cWhere  += " AND SD4.D4_COD = '"+MV_PAR07+"'"
	EndIf
    //filtra somente OPs firmes para fazer requisicao
	cWhere  += " AND SC2.C2_TPOP = 'F' "
	cWhere += " %"

	BeginSql Alias cAliasSC2
        SELECT DISTINCT SC2.C2_OP,
						SC2.C2_PRODUTO,
						SC2.C2_LOCAL,
						SC2.C2_QUANT,
						SC2.C2_EMISSAO,
						SC2.R_E_C_N_O_ RECNO
          FROM %Table:SC2% SC2
         INNER JOIN %Table:SD4% SD4
            ON(SD4.D4_FILIAL  = %Exp:xFilial("SD4")%
				AND SD4.D4_OP = SC2.C2_OP
				AND SD4.%NotDel%)
         INNER JOIN %Table:D1A% D1A
		    ON (D1A.D1A_FILIAL    = %Exp:xFilial("D1A")%
                AND D1A.D1A_COD   = SD4.D4_COD
                AND D1A.D1A_WSAAS = 'T'
				AND D1A.%NotDel%)
         WHERE %Exp:cWhere%
		   AND (SC2.C2_DATRF    = ' ' OR SC2.C2_DATRF IS NULL)
		   AND SC2.%NotDel%
		   AND SD4.D4_LOTECTL   = %Exp:Space(__nTamLote)%
		   AND SD4.D4_NUMLOTE   = %Exp:Space(__nTamSLot)%
		   AND SC2.C2_OP IN ( SELECT SD42.D4_OP
								FROM %Table:SD4% SD42
								LEFT JOIN %Table:DBX% DBX
  								  ON (DBX.DBX_FILIAL   = %Exp:xFilial("DBX")%
									AND DBX.DBX_COD    = SD42.D4_COD
									AND DBX.DBX_OP     = SD42.D4_OP
									AND DBX.DBX_TRT    = SD42.D4_TRT
									AND DBX.DBX_LOTECT = %Exp:Space(__nTamLote)%
									AND DBX.DBX_NUMLOT = %Exp:Space(__nTamSLot)%
									AND DBX.DBX_LOCAL  = SD42.D4_LOCAL
									AND DBX.DBX_ORDEM  = SD42.D4_ORDEM
									AND DBX.DBX_OPORIG = SD42.D4_OPORIG
									AND DBX.DBX_SEQ    = SD42.D4_SEQ
									AND (DBX.DBX_STATUS = %Exp:WMSSaasManufaturaControleRequisicao():getStatusGerada()% OR DBX.DBX_STATUS = %Exp:WMSSaasManufaturaControleRequisicao():getStatusConcluida()%)
									AND DBX.%NotDel%)
								WHERE SD42.D4_FILIAL = %Exp:xFilial("SD4")%
								  AND SD42.D4_COD = SD4.D4_COD
								  AND SD42.D4_OP  = SD4.D4_OP
								  AND SD42.D4_OPORIG = %Exp:Space(__nTamOpOr)%
								  AND SD42.%NotDel%
								GROUP BY SD42.D4_QTDEORI, SD42.D4_QUANT, SD42.D4_OP, SD42.D4_COD
							   HAVING (SUM(DBX.DBX_QUANT) IS NULL OR SUM(DBX.DBX_QUANT) IS NOT NULL
								  AND ((SD42.D4_QTDEORI - (SD42.D4_QTDEORI - SD42.D4_QUANT)) - SUM(DBX.DBX_QUANT)) > 0) 
							)
	EndSql
	aData := FwLoadByAlias(oModel, cAliasSC2, "SC2", "RECNO", /*lCopy*/, .T.)
	(cAliasSC2)->(DBCloseArea())
Return aData

/*/{Protheus.doc} loadGrid
	SD4 que podem ser requisitadas
	@type  Function
	@author carlos.augusto/fagner.barreto
	@since 20/12/2024
	@see (DLOGWMSMSP-16974)
	/*/
Static Function loadGrid(oModel)
Local cOp       := oModel:GetModel("MdItemSC2"):GetModel("MdItemSC2"):GetValue("C2_OP")
Local cAliasSD4 := GetNextAlias()
Local aData     := {}
Local cWhere    := "% "

	cWhere += " SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
	cWhere += " AND SD4.D4_OP = '"+cOp+"'"

	If (!Empty(MV_PAR07) .Or. Upper(MV_PAR08) == Replicate('Z', Len(MV_PAR08))) .And. MV_PAR07 != MV_PAR08
		cWhere  += " AND SD4.D4_COD >= '"+MV_PAR07+"'"
		cWhere  += " AND SD4.D4_COD <= '"+MV_PAR08+"'"
	ElseIf MV_PAR07 == MV_PAR08
		cWhere  += " AND SD4.D4_COD = '"+MV_PAR07+"'"
	EndIf

	cWhere    += " %"

	BeginSql Alias cAliasSD4
 		SELECT  D4_FILIAL,
				D4_LOCAL,
				D4_COD,
				D4_QTDEORI,
				SD4.R_E_C_N_O_ RECNO,
	  			(SD4.D4_QTDEORI - (SD4.D4_QTDEORI - SD4.D4_QUANT)) - 
				CASE 
					WHEN SUM(DBX.DBX_QUANT) IS NULL THEN 0
					ELSE SUM(DBX.DBX_QUANT)
				END AS D4_SALDO,
				(SD4.D4_QTDEORI - (SD4.D4_QTDEORI - SD4.D4_QUANT)) - 
				CASE 
					WHEN SUM(DBX.DBX_QUANT) IS NULL	THEN 0
					ELSE SUM(DBX.DBX_QUANT)
				END AS D4_QTDREQ
		  FROM %Table:SD4% SD4
		  LEFT JOIN %Table:DBX% DBX 
			ON (DBX.DBX_FILIAL     = %Exp:xFilial("DBX")%
				AND DBX.DBX_COD    = SD4.D4_COD
				AND DBX.DBX_OP     = SD4.D4_OP
				AND DBX.DBX_TRT    = SD4.D4_TRT
				AND DBX.DBX_LOTECT = SD4.D4_LOTECTL
				AND DBX.DBX_NUMLOT = SD4.D4_NUMLOTE
				AND DBX.DBX_LOCAL  = SD4.D4_LOCAL
				AND DBX.DBX_ORDEM  = SD4.D4_ORDEM
				AND DBX.DBX_OPORIG = SD4.D4_OPORIG
				AND DBX.DBX_SEQ    = SD4.D4_SEQ
				AND (DBX.DBX_STATUS = %Exp:WMSSaasManufaturaControleRequisicao():getStatusGerada()% OR DBX.DBX_STATUS = %Exp:WMSSaasManufaturaControleRequisicao():getStatusConcluida()%)
				AND DBX.%NotDel%)
		 INNER JOIN %Table:D1A% D1A 
			ON (D1A.D1A_FILIAL = %Exp:xFilial("D1A")%
				AND D1A.D1A_COD    = SD4.D4_COD
				AND D1A.D1A_WSAAS  = 'T'
				AND D1A.%NotDel%)
		 WHERE %Exp:cWhere%
		   AND SD4.D4_LOTECTL = %Exp:Space(__nTamLote)%
		   AND SD4.D4_NUMLOTE = %Exp:Space(__nTamSLot)%
		   AND SD4.D4_OPORIG  = %Exp:Space(__nTamOpOr)%
		   AND SD4.%NotDel%
		 GROUP BY D4_FILIAL,D4_LOCAL,D4_COD,D4_QTDEORI,SD4.R_E_C_N_O_,SD4.D4_QTDEORI,SD4.D4_QUANT
		HAVING (SUM(DBX.DBX_QUANT) IS NULL
			OR SUM(DBX.DBX_QUANT) IS NOT NULL AND ((SD4.D4_QTDEORI - (SD4.D4_QTDEORI - SD4.D4_QUANT)) - SUM(DBX.DBX_QUANT)) > 0)
	EndSql
	aData := FwLoadByAlias(oModel, cAliasSD4, "SD4", "RECNO", /*lCopy*/, .T.)
	(cAliasSD4)->(DBCloseArea())
Return aData


/*/{Protheus.doc} loadFldOct
	Necessario para inicializar com grid
	@type  Function
	@author carlos.augusto
	@since 05/12/2024
	@see (DLOGWMSMSP-16968)
	/*/
Static Function loadFldOct(oModel)
Return {""}


/*/{Protheus.doc} WMSS501Can
	Permite o cancelamento do modelo sem perguntar operacoes
	@type  Function
	@author carlos.augusto
	@since 05/12/2024
	@see (DLOGWMSMSP-16968)
	/*/
Static Function WMSS501Can()
Local oModel := FWModelActive()

	If (!Empty(oModel))
		oModel:lModify := .F.
	EndIf
Return .T.


/*/{Protheus.doc} WMSS501VSl
	Valid do campo de saldo a requisitar
	@type  Function
	@author carlos.augusto
	@since 05/12/2024
	@see (DLOGWMSMSP-16968)
	/*/
Function WMSS501VSl()
Local lRet := .T.
Local oModel    := FWModelActive()
Local oModelSD4 := oModel:GetModel("MdItemSD4")

	If oModelSD4:GetValue("D4_QTDREQ") > oModelSD4:GetValue("D4_SALDO")
		lRet := .F.
		oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0010 , "", "", "") //"Saldo insuficiente para a requisição informada."
	EndIf
Return lRet


/*/{Protheus.doc} WMSS501BTN
	Gera dois novos botoes do painel SD4
	@type  Function
	@author carlos.augusto
	@since 05/12/2024
	@see (DLOGWMSMSP-16968)
	/*/
Static Function WMSS501BTN(oPanel,oView)
Local oModel := FWModelActive()
	@ 003, 003 Button STR0011 Size 60, 15 Message STR0012 Pixel Action {||Processa( {||WMSS501Env(oModel)}, STR0013)} of oPanel //"Requisitar Itens" "Requisita os itens da Ordem de Produção posicionada""Enviando para Convergência"
	@ 003, 065 Button STR0014 Size 90, 15 Message STR0015 Pixel Action {||WMSS501Zer(oModel)} of oPanel //"Zerar Quantidades a Requisitar""Zerar quantidades a requisitar da Ordem de Produção posicionada"
	@ 003, 157 Button STR0033 Size 90, 15 Message STR0034 Pixel Action {||Processa( {||WMSS501Ev2()}, STR0013)} of oPanel //"Requisitar Todos" "Processar requisicoes de todos os registros"
	
Return .T.

/*/{Protheus.doc} WMSS501Env
	Envia a requisicao
	@type  Function
	@author carlos.augusto
	@since 05/12/2024
	@see (DLOGWMSMSP-16968)
	/*/
Static Function WMSS501Env(oModel)
Local oModelSC2 := oModel:GetModel("MdItemSC2")
Local oModelSD4 := oModel:GetModel("MdItemSD4")
Local nX 		:= 1
Local lReqOk    := .F.
Local lRet      := .T.
Local lLibAut	:= .F.
    
	//chamada de funcao para validacao do armazem de empenho que nao deve controlar SAAS 
	lRet := WMSSVArEmp(.T.)

	If lRet
		SaveInter()
		Pergunte("WMSSAAS01A",.F.)
		lLibAut := MV_PAR&(MANUFATURA_REQUISICAO) = TRANSACAO_AUTOMATICA
		RestInter()
	EndIf
    
	If lRet .And. !Empty(oModelSC2:GetValue("C2_OP"))
		If FWAlertNoYes(STR0016 + AllTrim(oModelSC2:GetValue("C2_OP"))+ STR0017 + AllTrim(oModelSC2:GetValue("C2_PRODUTO"))+ "?", WMSSAAS50103) //"Confirma as requisições para a ordem de Produção "" e produto "
			For nX := 1 To  oModelSD4:Length()
				oModelSD4:Goline( nX )
				If oModelSD4:GetValue("D4_QTDREQ") > 0
				  	lReqOk := .T.
					WMSSGERREQ(oModelSC2:GetDataID(oModelSC2:GetLine()), oModelSD4:GetDataID(nX), oModelSD4:GetValue("D4_QTDREQ"))
				EndIf

				If lLibAut
					LibAutConv(oModelSC2:GetValue("C2_OP"), MANUFATURA_REQUISICAO)
				EndIf
			Next nX

			If lReqOk
				FWAlertSuccess(STR0019 + AllTrim(oModelSC2:GetValue("C2_OP"))+".<br><br>"+;//"Requisição realizada com sucesso para a ordem de Produção "
				STR0020, WMSSAAS50105)//"Acompanhe o status da requisição pela rotina Convergência WMS SaaS(WMSSAAS001)."
				//Nao deve executar nada abaixo disso ate o return!
				__lRViewPg := .F.
				WMSS501SX1()
			Else
				FWAlertWarning(STR0021 + AllTrim(oModelSC2:GetValue("C2_OP"))+".<br><br>"+;//"Nenhuma requisição realizada para a ordem de Produção "
				STR0022, WMSSAAS50106)//"Verifique o preenchimento das quantidades a requisitar."
			EndIf
		EndIf
	ElseIf Empty(oModelSC2:GetValue("C2_OP"))
		FWAlertInfo(STR0023 + "<br><br>"+STR0024, WMSSAAS50107)//"Sem ordem de Produção para requisição.""Tecle F12 e realize a pesquisa novamente."
	EndIf

Return lRet

/*/{Protheus.doc} WMSS501Ev2
	Envia a requisicao de todos os registros em tela
	@type  Function
	@author roselaine.adriano
	@since 20/05/2025
	@see (DLOGWMSMSP-17456)
	/*/
Static Function WMSS501Ev2()
Local nQtdOK     	:= 0 
Local nQTdArSaas	:= 0
Local lLibAut		:= .F.
Local cWhere    	:= "% "
Local cAliasSD4		:= GetNextAlias()

	SaveInter()
	Pergunte("WMSSAAS01A",.F.)
	lLibAut := MV_PAR&(MANUFATURA_REQUISICAO) = TRANSACAO_AUTOMATICA
	RestInter()
    
	If FWAlertNoYes(STR0035, WMSSAAS50114) //"Esta opcao tem por objetivo gerar as requisicoes para todas as OPs filtradas em tela, deseja prosseguir?"

		cWhere += " SD4.D4_FILIAL = '"+xFilial("SD4")+"'"

		If (!Empty(MV_PAR07) .Or. Upper(MV_PAR08) == Replicate('Z', Len(MV_PAR08))) .And. MV_PAR07 != MV_PAR08
			cWhere  += " AND SD4.D4_COD >= '"+MV_PAR07+"'"
			cWhere  += " AND SD4.D4_COD <= '"+MV_PAR08+"'"
		ElseIf MV_PAR07 == MV_PAR08
			cWhere  += " AND SD4.D4_COD = '"+MV_PAR07+"'"
		EndIf

		If (!Empty(MV_PAR03) .Or. Upper(MV_PAR04) == Replicate('Z', Len(MV_PAR04))) .And. MV_PAR03 != MV_PAR04
			cWhere  += " AND SC2.C2_OP >= '"+MV_PAR03+"'"
			cWhere  += " AND SC2.C2_OP <= '"+MV_PAR04+"'"
		ElseIf MV_PAR03 == MV_PAR04
			cWhere  += " AND SC2.C2_OP = '"+MV_PAR03+"'"
		EndIf

		If (!Empty(MV_PAR05) .Or. Upper(MV_PAR06) == Replicate('Z', Len(MV_PAR06))) .And. MV_PAR05 != MV_PAR06
			cWhere  += " AND SC2.C2_PRODUTO >= '"+MV_PAR05+"'"
			cWhere  += " AND SC2.C2_PRODUTO <= '"+MV_PAR06+"'"
		ElseIf MV_PAR05 == MV_PAR06
			cWhere  += " AND SC2.C2_PRODUTO = '"+MV_PAR05+"'"
		EndIf

		If MV_PAR01 != MV_PAR02
			cWhere  += " AND SC2.C2_EMISSAO >= '"+DTOS(MV_PAR01)+"'"
			cWhere  += " AND SC2.C2_EMISSAO <= '"+DTOS(MV_PAR02)+"'"
		Else
			cWhere  += " AND SC2.C2_EMISSAO = '"+DTOS(MV_PAR01)+"'"
		EndIf

		//filtra somente OPs firmes para fazer requisicao
		cWhere  += " AND SC2.C2_TPOP = 'F' "
		cWhere  += " %"

		BeginSql Alias cAliasSD4
			SELECT  SD4.D4_FILIAL,
					SD4.D4_LOCAL,
					SD4.D4_COD,
					SD4.D4_OP,
					(SD4.D4_QTDEORI - (SD4.D4_QTDEORI - SD4.D4_QUANT)) - 
					CASE 
						WHEN SUM(DBX.DBX_QUANT) IS NULL	THEN 0
						ELSE SUM(DBX.DBX_QUANT)
					END AS D4_QTDREQ,
					SC2.R_E_C_N_O_ RECNOSC2,
					SD4.R_E_C_N_O_ RECNOSD4,
					NNR.NNR_WSAAS
			FROM %Table:SD4% SD4
			INNER JOIN %Table:SC2% SC2
				ON(SC2.C2_FILIAL  = %Exp:xFilial("SC2")%
					AND SC2.C2_OP = SD4.D4_OP
					AND SC2.%NotDel%)
			LEFT JOIN %Table:DBX% DBX 
				ON (DBX.DBX_FILIAL     = %Exp:xFilial("DBX")%
					AND DBX.DBX_COD    = SD4.D4_COD
					AND DBX.DBX_OP     = SD4.D4_OP
					AND DBX.DBX_TRT    = SD4.D4_TRT
					AND DBX.DBX_LOTECT = SD4.D4_LOTECTL
					AND DBX.DBX_NUMLOT = SD4.D4_NUMLOTE
					AND DBX.DBX_LOCAL  = SD4.D4_LOCAL
					AND DBX.DBX_ORDEM  = SD4.D4_ORDEM
					AND DBX.DBX_OPORIG = SD4.D4_OPORIG
					AND DBX.DBX_SEQ    = SD4.D4_SEQ
					AND (DBX.DBX_STATUS = %Exp:WMSSaasManufaturaControleRequisicao():getStatusGerada()% OR DBX.DBX_STATUS = %Exp:WMSSaasManufaturaControleRequisicao():getStatusConcluida()%)
					AND DBX.%NotDel%)
			INNER JOIN %Table:NNR% NNR
				ON (NNR.NNR_FILIAL = %Exp:xFilial("NNR")%
					AND NNR.NNR_CODIGO	= SD4.D4_LOCAL
					AND NNR.%NotDel%)	
			INNER JOIN %Table:D1A% D1A 
				ON (D1A.D1A_FILIAL = %Exp:xFilial("D1A")%
					AND D1A.D1A_COD    = SD4.D4_COD
					AND D1A.D1A_WSAAS  = 'T'
					AND D1A.%NotDel%)
			WHERE %Exp:cWhere%
				AND SD4.D4_LOTECTL = %Exp:Space(__nTamLote)%
				AND SD4.D4_NUMLOTE = %Exp:Space(__nTamSLot)%
				AND SD4.D4_OPORIG  = %Exp:Space(__nTamOpOr)%
				AND SD4.%NotDel%
			GROUP BY SD4.D4_FILIAL,SD4.D4_LOCAL,SD4.D4_COD,SD4.D4_OP,SD4.D4_QUANT,SD4.D4_QTDEORI,SC2.R_E_C_N_O_,SD4.R_E_C_N_O_,NNR.NNR_WSAAS
			HAVING (SUM(DBX.DBX_QUANT) IS NULL
				OR SUM(DBX.DBX_QUANT) IS NOT NULL AND ((SD4.D4_QTDEORI - (SD4.D4_QTDEORI - SD4.D4_QUANT)) - SUM(DBX.DBX_QUANT)) > 0)
		EndSql

		If (cAliasSD4)->( EOF() )
			FWAlertInfo(STR0023 + "<br><br>"+STR0024, WMSSAAS50107)//"Sem ordem de Produção para requisição.""Tecle F12 e realize a pesquisa novamente."
			Return .T.
		EndIf

		ProcRegua( (cAliasSD4)->( RecCount() ) )
		While (cAliasSD4)->( !EOF() )
			IncProc()

			If (cAliasSD4)->NNR_WSAAS == 'T'
				nQTdArSaas++
				(cAliasSD4)->( DbSkip() )
				Loop
			EndIf

			If (cAliasSD4)->D4_QTDREQ > 0
				WMSSGERREQ( (cAliasSD4)->RECNOSC2, (cAliasSD4)->RECNOSD4, (cAliasSD4)->D4_QTDREQ )
				nQtdOK++			   
			EndIf

			If lLibAut
				LibAutConv((cAliasSD4)->D4_OP, MANUFATURA_REQUISICAO)
			EndIf

			(cAliasSD4)->( DbSkip() )
		EndDo
		(cAliasSD4)->( DbCloseArea() )
		
		FWAlertSuccess(STR0036 + cValToChar(nQtdOK)+CRLF+CRLF+; //"Requisições realizadas: "
		STR0038 + cValToChar(nQTdArSaas), WMSSAAS50113)			//"Registros de requisição com empenho em local de estoque que controla WMS SAAS não permitindo a geração: "

		//Nao deve executar nada abaixo disso ate o return!
		__lRViewPg := .F.
		WMSS501SX1()
	EndIf
		
Return .T.

/*/{Protheus.doc} WMSS501Zer
	Zera quantidades a solicitar da ordem de producao posicionada
	@type  Function
	@author carlos.augusto
	@since 05/12/2024
	@see (DLOGWMSMSP-16968)
	/*/
Static Function WMSS501Zer(oModel)
Local oModelSD4 := oModel:GetModel("MdItemSD4")
Local nX 	:= 1
Local oView     := FWViewActive()
Local lRet := .T.

	IF lRet
		For nX := 1 To  oModelSD4:Length()
			oModelSD4:Goline( nX )
			oModelSD4:LoadValue("D4_QTDREQ",0)
		Next nX

		oModelSD4:Goline( 1 )
		oView:Refresh('MdItemSD4')
	EndIf
Return lRet


/*/{Protheus.doc} WMSS501SX1
	Funcionalidade F12
	@type  Function
	@author carlos.augusto
	@since 05/12/2024
	@see (DLOGWMSMSP-16968)
	/*/
Function WMSS501SX1()
Local oView  := FWViewActive()
Local oModel := FWModelActive()

	__lPresF12 := .T.

	If ReadVar() != "M->D4_QTDREQ"
		If (!Empty(oModel))
			oModel:lModify := .F.
		EndIf

		__lRLoadPg := .T.
		oView:ButtonCancelAction()
	EndIf
Return


/*/{Protheus.doc} WMSSVArEmp
	Funcao para validacao do armazem do empenho o mesmo nao deve controlar SAAS .
	@type  Function
	@author Equipe WMS
	@since 29/01/2025
	@version 1.0
	@param lShowMsg, Logico, Exibe mensagem
	@return boolean
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function WMSSVArEmp(lShowMsg )
Local lRet := .T. 
Local nX := 0
Local oModel := FWModelActive()
Local oModelSD4 := oModel:GetModel("MdItemSD4")
Local lArEmpSaas := .F. 
Local lTemRegInt := .F.
Default lShowMsg := .T.

	DbSelectArea("SD4")
	
	For nX := 1 To  oModelSd4:Length()
		oModelSD4:Goline( nX )
		SD4->(DbGoTo(oModelSD4:GetDataID(nX)))
		If oModelSD4:GetValue("D4_QTDREQ") > 0 
			If WMSSaasInt(SD4->D4_COD,SD4->D4_LOCAL)
				lArEmpSaas := .T. 
			Else
		   		lTemRegInt := .T.
			Endif
		EndIf
	Next nX

	If lArEmpSaas .AND. lShowMsg
		IF !lTemRegInt 
	   	  WmsMessage(STR0027,WMSSAAS50109,5,,, STR0029) //"Os registros de requisição possuem empenho em local de estoque que controla WMS SAAS." "Altere os empenhos para um local de produção sem controle WMS SAAS para efetuar o processamento."
		  lRet := .F. 
		Else 
			lRet := FWAlertNoYes(STR0032, WMSSAAS50110) //"Existem registros de requisição com empenho em local de estoque que controla WMS SAAS. Para estes registros não serão geradas requisições. Deseja continuar o processamento? "
		EndIf  
	ElseIf !lShowMsg .AND. lArEmpSaas .AND. !lTemRegInt
		lRet := .F.
	EndIF
    	
Return lRet

/*/{Protheus.doc} LibAutConv
	Libera as convergencias geradas de forma automática
	@type  Function
	@author fagner.ferraaz
	@since 11/06/2025
	@see (DLOGWMSMSP-17496)
	/*/
Static Function LibAutConv(cOP, cTransacao)
Local oClasse 	 := Nil
Local cStatus	 := "01" //CRIADO
Local cAliasDBZ	 := ""

	oClasse := WMSSaasConvergenciaFactory():get(cTransacao)

	cAliasDBZ := GetNextAlias()
    BeginSql Alias cAliasDBZ
	    SELECT DBZ.DBZ_ID
		  FROM %Table:DBZ% DBZ
		 WHERE DBZ.DBZ_FILIAL = %Exp:xFilial("DBZ")%
		   AND DBZ.DBZ_NUMDOC = %Exp:cOP%
		   AND DBZ.DBZ_TIPOTR = %Exp:cTransacao%
		   AND DBZ.DBZ_STATUS = %Exp:cStatus%
		   AND DBZ.%NotDel%
	EndSql
	While (cAliasDBZ)->(!Eof())
		oClasse:loadById((cAliasDBZ)->DBZ_ID)
		If !Empty(oClasse:id) .And. oClasse:isCriado()
			oClasse:setLiberado()
		EndIf
		(cAliasDBZ)->(DbSkip())  
	EndDo
	(cAliasDBZ)->(DbCloseArea())

    FreeObj(oClasse)
Return
