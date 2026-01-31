#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "WMSA101.CH"
#include "rptdef.ch"

#DEFINE WMSA10101 "WMSA10101"
#DEFINE WMSA10102 "WMSA10102"
#DEFINE WMSA10103 "WMSA10103"
#DEFINE WMSA10104 "WMSA10104"
#DEFINE WMSA10105 "WMSA10105"
#DEFINE WMSA10106 "WMSA10106"
#DEFINE WMSA10107 "WMSA10107"

Static lMarkAll   := .T. //Indicador de marca/desmarca todos
Static nContTMP   := 0   //Contador de Registros Marcados (ProcRegua)
Static oTmpTabPck := Nil
Static cAliasTemp := GetNextAlias()
//----------------------------------------------------------------------------------------------------------------------//
//-------------------------Rotina que efetua o reabastecimento nos enderecos de picking fixo----------------------------//
//-------------------------------e/ou enderecos de picking parcialmente preenchidos-------------------------------------//
//----------------------------------------------------------------------------------------------------------------------//
Function WMSA101()
Local aColsBrw := {}
Local aColsSX3 := {}
Local aSeeks   := {}
Local aRegra   := StrTokArr(Posicione('SX3',2,'DCF_REGRA','X3CBox()'),';')
Local nPos     := 0
Local bRegra   := Nil
Local lInterface := .t.
Private oBrowse    := Nil
Private cAliasBrw  := GetNextAlias()
Private cMarca     := "X"

	If IsBlind()
		lInterface := .f.
	EndIf

	If !SuperGetMV("MV_WMSNEW", .F., .F.)
		Return WMSA100()
	EndIf
	If !Pergunte("WMSA100",lInterface) // Rever pergunte com o novo nome
		Return
	EndIf
	For nPos := 1 To Len(aRegra)
		aRegra[nPos] := StrTokArr(aRegra[nPos],'=')
	Next
	bRegra := {|| nPos := AScan(aRegra,{|x| x[1] == (cAliasBrw)->TP_REGRA}), Iif(nPos > 0, aRegra[nPos,2], '')}

    If !BrwQuery()
	   Return
	EndIf
	AAdd(aColsBrw,{BuscarSX3('BE_LOCAL'  ,,aColsSX3), "TP_LOCAL"  ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1}) // Armazem
	AAdd(aColsBrw,{BuscarSX3('BE_LOCALIZ',,aColsSX3), "TP_LOCALIZ",'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1}) // Endereço
	AAdd(aColsBrw,{BuscarSX3('BE_ESTFIS' ,,aColsSX3), "TP_ESTFIS" ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1}) // Prod./Fixo/Endereço
	AAdd(aColsBrw,{BuscarSX3('BE_CODZON' ,,aColsSX3), "TP_CODZON" ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1}) // Zona Armaz.
	AAdd(aColsBrw,{BuscarSX3('D14_PRODUT',,aColsSX3), "TP_PRODUTO",'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.T.,,,,,,,,1}) // Produto
	BuscarSX3('D14_QTDEST',,aColsSX3)
	AAdd(aColsBrw,{/*Mesmo BF_QUANT*/        STR0007, "TP_NORMA"  ,'N',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1}) // Norma
	AAdd(aColsBrw,{/*Mesmo BF_QUANT*/        STR0008, "TP_QTDSALD",'N',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1}) // Qtd Saldo
	AAdd(aColsBrw,{/*Mesmo BF_QUANT*/        STR0009, "TP_QTDPREV",'N',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1}) // Qtd Prevista
	AAdd(aColsBrw,{/*Mesmo BF_QUANT*/        STR0010, "TP_QTDREAB",'N',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1}) // Qtd Reabastecer
	AAdd(aColsBrw,{BuscarSX3('DCF_REGRA' ,,aColsSX3), /*"TP_REGRA"*/bRegra  ,'C',aColsSX3[3],aColsSX3[4],Nil,1,,.T.,,,,,,,,1}) // Regra WMS
	AAdd(aColsBrw,{BuscarSX3('D14_PRDORI',,aColsSX3), "TP_PRDORI" ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.T.,,,,,,,,1}) // Produto Origem

	AAdd(aSeeks, {; // Armazém + Endereço + Produto
					AllTrim(aColsBrw[1][1])+' + '+AllTrim(aColsBrw[2][1])+' + '+AllTrim(aColsBrw[5][1]),;
					{;
						{'NNR',aColsBrw[1][3],aColsBrw[1][4],aColsBrw[1][5],aColsBrw[1][1],Nil},;
						{'SBE',aColsBrw[2][3],aColsBrw[2][4],aColsBrw[2][5],aColsBrw[2][1],Nil},;
						{'SB1',aColsBrw[5][3],aColsBrw[5][4],aColsBrw[5][5],aColsBrw[5][1],Nil} ;
					}})

	AAdd(aSeeks, {; // Produto
					AllTrim(aColsBrw[5][1]),;
					{;
						{'SB1',aColsBrw[5][3],aColsBrw[5][4],aColsBrw[5][5],aColsBrw[5][1],Nil} ;
					}})

	oBrowse:= FWMarkBrowse():New()
	oBrowse:SetDescription(STR0001)
	oBrowse:SetMenuDef("WMSA101")
	oBrowse:SetFields(aColsBrw)
	oBrowse:SetSeek(.T.,aSeeks)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetAlias(cAliasBrw)
	oBrowse:SetFieldMark("TP_MARK")
	oBrowse:SetMark(cMarca,cAliasBrw,"TP_MARK")
	oBrowse:SetValid({||!Empty((cAliasBrw)->TP_PRODUTO)})
	oBrowse:SetAllMark({||BrwAllMark()})
	oBrowse:SetAfterMark({||Iif(oBrowse:IsMark(),nContTMP++,nContTMP--)})
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetParam({|| WMSA101Sel()})
	If lInterface
		oBrowse:Activate()
	Else
		WMS101PReb(lInterface)
	EndIf

	delTabTmp(cAliasBrw,oTmpTabPck)
Return

//-------------------------------------------------------------------//
//-------------------------Função MenuDef----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION 'WMS101PReb()' 		OPERATION 4 ACCESS 0 // Processar
	ADD OPTION aRotina TITLE STR0003 ACTION 'WMSA101Sel()' 		OPERATION 3 ACCESS 0 // Selecionar
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSA101'   OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA101'   OPERATION 4 ACCESS 0 // Alterar
Return aRotina

//--------------------------------------------------------------------//
//-------------------------Função ModelDef----------------------------//
//--------------------------------------------------------------------//
Static Function ModelDef()
Local aColsSX3 := {}
Local oStruct  := FWFormModelStruct():New()
Local oModel   := MPFormModel():New('WMSA101',,{|oModel| ValidModel(oModel)},{|| GravaDados()})
Local aRegra   := StrTokArr(Posicione('SX3',2,'DCF_REGRA','X3CBox()'),';')

	AAdd(aRegra," ")
	// Monta Struct da TEMP
	oStruct:AddTable(IIF(Type("cAliasBrw") != "U",cAliasBrw,"SBE"), {'TP_LOCAL','TP_LOCALIZ','TP_PRODUTO'},STR0006)
	oStruct:AddIndex(1,'1','TP_LOCAL+TP_LOCALIZ+TP_PRODUTO',FWX3Titulo('BE_LOCAL') + '|' + FWX3Titulo('BE_LOCALIZ'),'','',.T.)
	oStruct:AddIndex(2,'2','TP_PRODUTO'                    ,FWX3Titulo('BF_PRODUTO')                               ,'','',.T.)

	oStruct:AddField(BuscarSX3('BE_LOCAL'  ,,aColsSX3),aColsSX3[1],'TP_LOCAL'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.T.,.F.,.T.)
	oStruct:AddField(BuscarSX3('BE_LOCALIZ',,aColsSX3),aColsSX3[1],'TP_LOCALIZ','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.T.,.F.,.T.)
	oStruct:AddField(BuscarSX3('BE_ESTFIS' ,,aColsSX3),aColsSX3[1],'TP_ESTFIS' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.F.,.T.)
	oStruct:AddField(BuscarSX3('BE_CODZON' ,,aColsSX3),aColsSX3[1],'TP_CODZON' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.F.,.T.)
	oStruct:AddField(BuscarSX3('D14_PRODUT',,aColsSX3),aColsSX3[1],'TP_PRODUTO','C',aColsSX3[3],aColsSX3[4],FwBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA101,ValidField)"),{||WhenField('TP_PRODUTO')},Nil,.F.,,.F.,.F.,.T.)
	oStruct:AddField(BuscarSX3('D14_PRDORI',,aColsSX3),aColsSX3[1],'TP_PRDORI' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.F.,.T.)
	BuscarSX3('D14_QTDEST',,aColsSX3)
	oStruct:AddField(/*Mesmo BF_QUANT*/        STR0007,STR0007    ,'TP_NORMA'  ,'N',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.F.,.T.) // Norma
	oStruct:AddField(/*Mesmo BF_QUANT*/        STR0008,STR0008    ,'TP_QTDSALD','N',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.F.,.T.) // Qtd Saldo
	oStruct:AddField(/*Mesmo BF_QUANT*/        STR0009,STR0009    ,'TP_QTDPREV','N',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.F.,.T.) // Qtd Prev
	oStruct:AddField(/*Mesmo BF_QUANT*/        STR0010,STR0010    ,'TP_QTDREAB','N',aColsSX3[3],aColsSX3[4],FwBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA101,ValidField)"),{||.T.},Nil,.F.,,.F.,.F.,.T.) // Qtd Reab
	oStruct:AddField(BuscarSX3('DCF_REGRA' ,,aColsSX3),aColsSX3[1],'TP_REGRA'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},aRegra,.F.,,.F.,.F.,.T.)

	oModel:AddFields('PKGMASTER', /*cOwner*/, oStruct)
	oModel:SetPrimaryKey({'TP_LOCAL','TP_LOCALIZ','TP_PRODUTO'})
	oModel:SetDescription(STR0001)
Return oModel
//-------------------------------------------------------------------//
//-------------------------Função ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local aColsSX3 := {}
Local oModel   := FWLoadModel('WMSA101')
Local oView    := FWFormView():New()
Local oStruct  := FWFormViewStruct():New()
Local aRegra   := StrTokArr(Posicione('SX3',2,'DCF_REGRA','X3CBox()'),';')

	AAdd(aRegra," ")
	// Monta Struct da TEMP
	oStruct:AddField('TP_LOCAL'  ,'01',BuscarSX3('BE_LOCAL'  ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'NNR',.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TP_LOCALIZ','02',BuscarSX3('BE_LOCALIZ',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'SBE',.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TP_ESTFIS' ,'03',BuscarSX3('BE_ESTFIS' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TP_CODZON' ,'04',BuscarSX3('BE_CODZON' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TP_PRODUTO','05',BuscarSX3('D14_PRODUT',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'SB1',.T.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TP_PRDORI' ,'06',BuscarSX3('D14_PRDORI',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	BuscarSX3('D14_QTDEST',,aColsSX3)
	oStruct:AddField('TP_NORMA'  ,'07',/*Mesmo BF_QUANT*/        STR0007,STR0007    ,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.T.) // Norma
	oStruct:AddField('TP_QTDSALD','08',/*Mesmo BF_QUANT*/        STR0008,STR0008    ,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.T.) // Qtd Saldo
	oStruct:AddField('TP_QTDPREV','09',/*Mesmo BF_QUANT*/        STR0009,STR0009    ,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.T.) // Qtd Prev
	oStruct:AddField('TP_QTDREAB','10',/*Mesmo BF_QUANT*/        STR0010,STR0010    ,Nil,'GET',aColsSX3[2],Nil,Nil  ,.T.,Nil,Nil,Nil,Nil,Nil,.T.) // Qtd Reab
	oStruct:AddField('TP_REGRA'  ,'11',BuscarSX3('DCF_REGRA' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.T.,Nil,Nil,aRegra,10,Nil,.T.)

	oView:SetModel(oModel)
	oView:AddField("VIEW_PKG",oStruct,"PKGMASTER")
	oView:CreateHorizontalBox("TELA",100)
	oView:SetOwnerView("VIEW_PKG","TELA")
	oView:SetDescription(STR0001)
	oView:SetAfterOkButton({|oModel| AfterOKView(oModel)})
	oView:SetCloseOnOk({||.T.})
Return oView
//-------------------------------------------------------------------------------//
//-------------------------Realiza validação do Model----------------------------//
//-------------------------------------------------------------------------------//
Static Function ValidModel(oModel)
Return .T.

Static Function GravaDados()
Local cPrdOri   := Nil
Local cAliasQry := GetNextAlias()

	// Se o produto é filho
	BeginSql Alias cAliasQry
		SELECT D11.D11_PRDORI
		FROM %Table:D11% D11
		WHERE D11.D11_FILIAL = %xFilial:D11%
		AND D11.D11_PRDCMP = %Exp:FwFldGet("TP_PRODUTO")%
		AND D11.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		cPrdOri := D11->D11_PRDORI
	EndIf
	(cAliasQry)->(dbCloseArea())
	If !Empty(cPrdOri)
		If WmsMessage(STR0019,WMSA10107,4,,{STR0020,STR0021}) == 1 // Considerar saldo como produto ou componente do [VAR01]? // Produto // Componete
			cPrdOri := Nil
		EndIf
	EndIf
Return GravaTemp(,,,,FwFldGet("TP_PRODUTO"),FwFldGet("TP_QTDSALD"),FwFldGet("TP_NORMA"),FwFldGet("TP_QTDPREV"),FwFldGet("TP_QTDREAB"),2,cPrdOri)
//-------------------------------------------------------------------------------------------------------------//
//-------------------------Desmarca os registros onde não se tem informação de produto-------------------------//
//------------------------------e marca os registros onde essa informação existe-------------------------------//
//-------------------------------------------------------------------------------------------------------------//
Static Function AfterOKView(oModel)
Local cProduto := oModel:GetValue('PKGMASTER','TP_PRODUTO')
	If Empty(cProduto)
		If oBrowse:IsMark()
			oBrowse:SetValid({||.T.}) // Retira o evento de validação
			oBrowse:MarkRec() // Desmarca o registro
			oBrowse:SetValid({||!Empty((cAliasBrw)->TP_PRODUTO)}) // Recoloca o evento de validação
		EndIf
	Else
		If !oBrowse:IsMark()
			oBrowse:MarkRec() // Marca o registro
		EndIf
	EndIf
Return .T.
//---------------------------------------------------------------------------------------------------------//
//-------------------------Realiza busca dos dados que serão exibidos no Browse----------------------------//
//---------------------------------------------------------------------------------------------------------//
Static Function BrwAllMark()
Local aAreaAnt  := GetArea()
	lMarkAll := !lMarkAll
	nContTMP := 0
	(cAliasBrw)->(DbGoTop())
	Do While (cAliasBrw)->(!Eof())
		If !Empty((cAliasBrw)->TP_PRODUTO)
			RecLock(cAliasBrw,.F.)
			(cAliasBrw)->TP_MARK := Iif(lMarkAll,cMarca," ")
			(cAliasBrw)->(MsUnlock())
			If !Empty((cAliasBrw)->TP_MARK)
				nContTMP++
			EndIf
		EndIf
		(cAliasBrw)->(dbSkip())
	EndDo
	(cAliasBrw)->(dbGoTop())
	RestArea(aAreaAnt)
	oBrowse:Refresh()
Return Nil
//---------------------------------------------------------------------------------------------------------//
//-------------------------Realiza busca dos dados que serão exibidos no Browse----------------------------//
//---------------------------------------------------------------------------------------------------------//
Static Function BrwQuery(lCriaTemp)
Local cWhere    := ""
Local cAliasQry := Nil
Local cProduto  := ""
Local cPrdOri   := ""
Local nQtdSaldo := 0
Local nQtdPrev  := 0
Local nQtdNorma := 0
Local nQtdReab  := 0
Local lGeraReab := .T.
Local lRetPE    := .F.
Local lDescEnd  := .F.
Local lWMS101DE := ExistBlock("WMS101DE")
Local cLocAnt   := ""
Local cEndAnt   := ""

Local cTable  := ''
Local cquery  := ''

Default lCriaTemp := .T.
	If lCriaTemp
		If !CriaTemp()
			Return .F.
		EndIf
	EndIf
	nContTMP = 0
	// Somente picking fixo
	If mv_par09 == 1
		cWhere := " AND SBE.BE_CODPRO <> ' '"
	EndIf
	cWhere := "%"+cWhere 

    IF (!Empty(mv_par01) .Or. Upper(SubStr(mv_par02,1,1)) != 'Z') .And. !mv_par01 == mv_par02
 		cWhere  += " AND SBE.BE_LOCAL  >= '"+mv_par01+"'"
		cWhere  += " AND SBE.BE_LOCAL  <= '"+mv_par02+"'"
	ElseIf mv_par01 == mv_par02
		cWhere  += " AND SBE.BE_LOCAL = '"+ mv_par01+"'"
	EndIf

	IF (!Empty(mv_par03) .Or. Upper(SubStr(mv_par04,1,1)) != 'Z') .And. !mv_par03 == mv_par04
 		cWhere  += " AND SBE.BE_CODZON  >= '"+mv_par03+"'"
		cWhere  += " AND SBE.BE_CODZON  <= '"+mv_par04+"'"
	ElseIf mv_par03 == mv_par04
		cWhere  += " AND SBE.BE_CODZON = '"+ mv_par03+"'"
	EndIf

	IF (!Empty(mv_par05) .Or. Upper(SubStr(mv_par06,1,1)) != 'Z') .And. !mv_par05 == mv_par06
 		cWhere  += " AND SBE.BE_LOCALIZ  >= '"+mv_par05+"'"
		cWhere  += " AND SBE.BE_LOCALIZ  <= '"+mv_par06+"'"
	ElseIf mv_par05 == mv_par06
		cWhere  += " AND SBE.BE_LOCALIZ = '"+ mv_par05+"'"
	EndIf

	IF (!Empty(mv_par07) .Or. Upper(SubStr(mv_par08,1,1)) != 'Z') .And. !mv_par07 == mv_par08
		cWhere  += " AND ((SBE.BE_CODPRO >= '"+MV_PAR07+"'"
		cWhere  += " AND SBE.BE_CODPRO <= '"+MV_PAR08+"')"
		cWhere  += "  OR (D14.D14_PRODUT >='"+MV_PAR07+"'"
		cWhere  += "  AND D14.D14_PRODUT <='"+MV_PAR08+"'))"
 	ElseIf mv_par07 == mv_par08
		cWhere  += " AND (SBE.BE_CODPRO = '"+MV_PAR07+"'"
		cWhere  += "  OR D14.D14_PRODUT ='"+MV_PAR07+"')"
	EndIf

    cWhere += "%" 

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SBE.BE_LOCAL,
				SBE.BE_LOCALIZ,
				SBE.BE_ESTFIS,
				SBE.BE_CODZON,
				SBE.BE_CODPRO,
				D14.D14_PRODUT,
				D14.D14_PRDORI,
				D14.D14_QTDEST,
				D14.D14_QTDEPR
		FROM %Table:SBE% SBE
		INNER JOIN %Table:DC8% DC8
		ON DC8.DC8_FILIAL = %xFilial:DC8%
		AND DC8.DC8_CODEST = SBE.BE_ESTFIS
		AND DC8.DC8_TPESTR = '2'
		AND DC8.%NotDel%
		LEFT JOIN (SELECT D14_LOCAL,
							D14_ENDER,
							D14_PRODUT,
							D14_PRDORI,
							SUM(D14_QTDEPR) D14_QTDEPR,
							SUM(D14_QTDEST) D14_QTDEST
					FROM %Table:D14% D14
					INNER JOIN %Table:DC8% DC82 
					ON DC82.DC8_FILIAL =  %xFilial:DC8%
					AND DC82.DC8_CODEST = D14.D14_ESTFIS
					AND DC82.DC8_TPESTR = '2'
					AND DC82.%NotDel%
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND (D14.D14_QTDEST + D14.D14_QTDEPR) > 0
					AND D14.%NotDel%
					GROUP BY D14_LOCAL,
								D14_ENDER,
								D14_PRDORI,
								D14_PRODUT) D14
		ON D14.D14_LOCAL = SBE.BE_LOCAL
		AND D14.D14_ENDER = SBE.BE_LOCALIZ
		WHERE SBE.BE_FILIAL = %xFilial:SBE%
		AND SBE.%NotDel%
		%Exp:cWhere%
		ORDER BY SBE.BE_LOCAL,
					SBE.BE_LOCALIZ,
					SBE.BE_CODPRO,
					D14.D14_PRDORI,
					D14.D14_PRODUT
	EndSql
	Do While !(cAliasQry)->(Eof())
		lGeraReab := .T.
		cProduto := Iif(Empty((cAliasQry)->D14_PRODUT),(cAliasQry)->BE_CODPRO,(cAliasQry)->D14_PRODUT)
		cPrdOri  := Iif(Empty((cAliasQry)->D14_PRDORI),(cAliasQry)->BE_CODPRO,(cAliasQry)->D14_PRDORI)
		// Se o endereço possui saldo ou é especifico de um determinado produto
		If !Empty(cProduto)
			nQtdSaldo := (cAliasQry)->D14_QTDEST
			nQtdPrev := (cAliasQry)->D14_QTDEPR
			nQtdNorma := DLQtdNorma(cProduto, (cAliasQry)->BE_LOCAL, (cAliasQry)->BE_ESTFIS, /*cDesUni*/, /*lNUnit*/, (cAliasQry)->BE_LOCALIZ)
			// Deve verificar se o endereço já possui previsão de reabastecimento
			nQtdReab  := nQtdNorma - (nQtdSaldo + nQtdPrev)
			GravaTemp((cAliasQry)->BE_LOCAL,(cAliasQry)->BE_LOCALIZ,(cAliasQry)->BE_ESTFIS,(cAliasQry)->BE_CODZON,cProduto,nQtdSaldo,nQtdNorma,nQtdPrev,nQtdReab,,cPrdOri)
		Else
			// Grava apenas o endereço em branco para geração de reabastecimento
			GravaTemp((cAliasQry)->BE_LOCAL,(cAliasQry)->BE_LOCALIZ,(cAliasQry)->BE_ESTFIS,(cAliasQry)->BE_CODZON,Nil,0,0,0,0)
		EndIf
		// Se o endereço não é especifico para um produto, deve verificar se o mesmo é compartilhado
		If Empty((cAliasQry)->BE_CODPRO) .And. !Empty(cLocAnt+cEndAnt) .And. (cLocAnt+cEndAnt) != ((cAliasQry)->BE_LOCAL+(cAliasQry)->BE_LOCALIZ)
			ChkEndDCP(cLocAnt,cEndAnt)
		EndIf
		cLocAnt := (cAliasQry)->BE_LOCAL
		cEndAnt := (cAliasQry)->BE_LOCALIZ
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	(cAliasBrw)->(DbGoTop())
	// Verifica se o ultimo endereço é compartilhado
	If !Empty(cLocAnt+cEndAnt)
		ChkEndDCP(cLocAnt,cEndAnt)
	EndIf
	// Exclui os endereços que não precisam ser reabastecidos
	//Se não utiliza o ponto de entrada WMS101DE está excluindo todos os registros através de SQL para melhora de performance. 
	If !lWMS101DE
	   cTable    := oTmpTabPck:GetRealName()
	   cQuery := "DELETE FROM "+ cTable
	   cQuery += " WHERE "+cTable+".TP_PRODUTO <> ' ' "
	   cQuery += " AND ("+cTable+".TP_QTDREAB <= 0 "
       cQuery += " OR  ("+cTable+".TP_QTDREAB < ("+cTable+".TP_NORMA * ("+Transform(MV_PAR10,"@R 9999.9")+"/100)))) "
	   TcSQLExec(cQuery) 
	Else
		(cAliasBrw)->(DbGoTop())	
		Do While !(cAliasBrw)->(Eof())
			lDescEnd := .F.
			If lWMS101DE
				lRetPE   := ExecBlock("WMS101DE", .F., .F.,{(cAliasBrw)->TP_LOCAL,(cAliasBrw)->TP_LOCALIZ,(cAliasBrw)->TP_PRODUTO})
				lDescEnd := If(ValType(lRetPE)=="L",lRetPE,.F.) //Indica se desconsidera endereço
			EndIf
			If lDescEnd .Or. !Empty((cAliasBrw)->TP_PRODUTO)
				// Se não deve reabastecer nada para o endereço dele o mesmo
				If lDescEnd .Or. (QtdComp((cAliasBrw)->TP_QTDREAB) <= QtdComp(0)) .Or. (QtdComp((cAliasBrw)->TP_QTDREAB) < QtdComp((cAliasBrw)->TP_NORMA * (mv_par10/100)))
					RecLock(cAliasBrw,.F.)
					(cAliasBrw)->(DbDelete())
					MsUnlock(cAliasBrw)
				EndIf
			EndIf
			(cAliasBrw)->(DbSkip())
		EndDo
		(cAliasBrw)->(__DBPack())
	EndIf

Return .T.
//--------------------------------------------------------------------------------//
//-------Verifica se o endereço é compartilhado via percentual de ocupação--------//
//--------------------------------------------------------------------------------//
Static Function ChkEndDCP(cLocal,cEndereco)
Local cAliasDCP := GetNextAlias()
Local cTable    := "%"+oTmpTabPck:GetRealName()+"%"
Local nQtdNorma := 0
	BeginSql Alias cAliasDCP
		SELECT DCP.R_E_C_N_O_ RECNODCP,
				DCP.DCP_LOCAL,
				DCP.DCP_ENDERE,
				DCP.DCP_CODPRO,
				DCP.DCP_ESTFIS,
				SBE.BE_CODZON
		FROM %Table:DCP% DCP
		INNER JOIN %table:SBE% SBE
		ON SBE.BE_FILIAL = %xFilial:SBE%
		AND SBE.BE_LOCALIZ = DCP.DCP_ENDERE
		AND SBE.BE_LOCAL = DCP.DCP_LOCAL
		AND SBE.%NotDel%
		WHERE DCP.DCP_FILIAL = %xFilial:DCP%
		AND DCP.DCP_LOCAL = %Exp:cLocal%
		AND DCP.DCP_ENDERE = %Exp:cEndereco%
		AND DCP.DCP_CODPRO <> ' '
		AND NOT EXISTS (SELECT 1
						FROM %Exp:cTable% PCK
						WHERE PCK.TP_LOCAL = DCP.DCP_LOCAL
						AND PCK.TP_LOCALIZ = DCP.DCP_ENDERE
						AND PCK.TP_PRODUTO = DCP.DCP_CODPRO
						AND PCK.%NotDel%)
		AND DCP.%NotDel%
	EndSql
	Do While (cAliasDCP)->(!Eof())
		// Se ainda não existir na TEMP
		nQtdNorma := DLQtdNorma((cAliasDCP)->DCP_CODPRO,(cAliasDCP)->DCP_LOCAL,(cAliasDCP)->DCP_ESTFIS, /*cDesUni*/, /*lNUnit*/,(cAliasDCP)->DCP_ENDERE)
		GravaTemp((cAliasDCP)->DCP_LOCAL,(cAliasDCP)->DCP_ENDERE,(cAliasDCP)->DCP_ESTFIS,(cAliasDCP)->BE_CODZON,(cAliasDCP)->DCP_CODPRO,0,nQtdNorma,0,nQtdNorma)
		(cAliasDCP)->(dbSkip())
	EndDo
	(cAliasDCP)->(dbCloseArea())
Return
//----------------------------------------------------------------------------------------//
//-------------------------Grava os dados na tabela temporária----------------------------//
//----------------------------------------------------------------------------------------//
Static Function GravaTemp(cLocal,cEndereco,cEstFis,cCodZona,cProduto,nQtdSaldo,nQtdNorma,nQtdPrev,nQtdReab,nAcao,cPrdOri)
Default nAcao = 1
Default cPrdOri := cProduto
	If nAcao == 1
		RecLock(cAliasBrw,.T.)
		(cAliasBrw)->TP_MARK    := Iif(!Empty(cProduto),cMarca," ")
		(cAliasBrw)->TP_LOCAL   := cLocal
		(cAliasBrw)->TP_LOCALIZ := cEndereco
		(cAliasBrw)->TP_ESTFIS  := cEstFis
		(cAliasBrw)->TP_CODZON  := cCodZona
		(cAliasBrw)->TP_PRODUTO := cProduto
		(cAliasBrw)->TP_PRDORI  := cPrdOri
		(cAliasBrw)->TP_NORMA   := nQtdNorma
		(cAliasBrw)->TP_QTDSALD := nQtdSaldo
		(cAliasBrw)->TP_QTDPREV := nQtdPrev
		(cAliasBrw)->TP_QTDREAB := nQtdReab
		(cAliasBrw)->TP_REGRA   := ''
		(cAliasBrw)->TP_ALTPRD  := Iif(!Empty(cProduto),"N","S")
		MsUnlock(cAliasBrw)
		If !Empty((cAliasBrw)->TP_MARK)
			nContTMP++
		EndIf
	ElseIf nAcao == 2
	   RecLock(cAliasBrw,.F.)
		(cAliasBrw)->TP_PRODUTO := cProduto
		(cAliasBrw)->TP_NORMA   := nQtdNorma
		(cAliasBrw)->TP_QTDSALD := nQtdSaldo
		(cAliasBrw)->TP_QTDPREV := nQtdPrev
		(cAliasBrw)->TP_QTDREAB := nQtdReab
		(cAliasBrw)->TP_REGRA   := FwFldGet("TP_REGRA")
		(cAliasBrw)->TP_PRDORI  := cPrdOri
		(cAliasBrw)->(MsUnlock())
	EndIf
Return .T.
//-----------------------------------------------------------------------------//
//-------------------------Cria a tabela temporária----------------------------//
//-----------------------------------------------------------------------------//
Static Function CriaTemp()
Local aColsSX3 := {}
Local aColsBrw  := {}

	/*Coluna de marcação*/             AAdd(aColsBrw,{"TP_MARK"   ,"C",          1,          0})
	BuscarSX3("BE_LOCAL"  ,,aColsSX3); AAdd(aColsBrw,{"TP_LOCAL"  ,"C",aColsSX3[3],aColsSX3[4]})
	BuscarSX3("BE_LOCALIZ",,aColsSX3); AAdd(aColsBrw,{"TP_LOCALIZ","C",aColsSX3[3],aColsSX3[4]})
	BuscarSX3("BE_ESTFIS" ,,aColsSX3); AAdd(aColsBrw,{"TP_ESTFIS" ,"C",aColsSX3[3],aColsSX3[4]})
	BuscarSX3("BE_CODZON" ,,aColsSX3); AAdd(aColsBrw,{"TP_CODZON" ,"C",aColsSX3[3],aColsSX3[4]})
	BuscarSX3("D14_PRODUT",,aColsSX3); AAdd(aColsBrw,{"TP_PRODUTO","C",aColsSX3[3],aColsSX3[4]})
	BuscarSX3("D14_PRODUT",,aColsSX3); AAdd(aColsBrw,{"TP_PRDORI" ,"C",aColsSX3[3],aColsSX3[4]})
	BuscarSX3("D14_QTDEST",,aColsSX3); AAdd(aColsBrw,{"TP_NORMA"  ,"N",aColsSX3[3],aColsSX3[4]})
	/*As mesmas informações do saldo*/  AAdd(aColsBrw,{"TP_QTDSALD","N",aColsSX3[3],aColsSX3[4]})
	/*As mesmas informações do saldo*/  AAdd(aColsBrw,{"TP_QTDPREV","N",aColsSX3[3],aColsSX3[4]})
	/*As mesmas informações do saldo*/  AAdd(aColsBrw,{"TP_QTDREAB","N",aColsSX3[3],aColsSX3[4]})
	BuscarSX3("DCF_REGRA" ,,aColsSX3); AAdd(aColsBrw,{"TP_REGRA"  ,"C",aColsSX3[3],aColsSX3[4]})
	/*Coluna oculta auxiliar*/         AAdd(aColsBrw,{"TP_ALTPRD" ,"C",          1,          0})

	// Cria tabelas temporárias
	criaTabTmp(aColsBrw,{'TP_LOCAL+TP_LOCALIZ+TP_PRODUTO','TP_PRODUTO'},cAliasBrw,@oTmpTabPck)
Return .T.
//-----------------------------------------------------------------------------------------------------------//
//-------------------------Validação que seta se é possível alteração do registro----------------------------//
//-----------------------------------------------------------------------------------------------------------//
Static Function WhenField(cField)
	Do Case
	Case cField == "TP_PRODUTO"
		Return Iif((cAliasBrw)->TP_ALTPRD=="N",.F.,.T.)
	EndCase
Return .T.
//---------------------------------------------------------------------------------//
//-------------------------Realiza validação do Produto----------------------------//
//---------------------------------------------------------------------------------//
Static Function ValidField()
Local lRet      := .T.
Local cField    := SubStr(ReadVar(),4)
Local cProduto  := ""
Local cCodZona  := ""
Local cAliasQry := Nil
Local nQtdNorma := 0
Local nQtdReab  := 0
Local nQtdMax   := 0
	Do Case
		Case cField == "TP_PRODUTO"
			cProduto := FwFldGet("TP_PRODUTO")
			If Empty(cProduto)
				FWFldPut('TP_NORMA',0)
				FWFldPut('TP_QTDREAB',0)
				Return .T.
			EndIf
			// Valida se o produto existe
			If !ExistCpo('SB1',cProduto)
				Return .F.
			EndIf
			// Valida se o produto é pai
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT 1
				FROM %Table:D11% D11
				WHERE D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = %Exp:cProduto%
				AND D11.%NotDel%
			EndSql
			If !(cAliasQry)->(Eof())
				WmsMessage(WmsFmtMsg(STR0011,{{"[VAR01]",cProduto}}),WMSA10101,5 /*MSG_HELP*/) // Produto [VAR01] possui controle de componente no WMS (D11).
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
			// Valida se o complemento do produto existe
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT SB5.B5_CODZON
				FROM %Table:SB5% SB5
				WHERE SB5.B5_FILIAL = %xFilial:SB5%
				AND SB5.B5_COD = %Exp:cProduto%
				AND SB5.%NotDel%
			EndSql
			If (cAliasQry)->(Eof())
				WmsMessage(WmsFmtMsg(STR0012,{{"[VAR01]",cProduto}}),WMSA10102,5/*MSG_HELP*/) // Produto [VAR01] não cadastrado nos dados adicionais do produto (SB5).
				lRet := .F.
			Else
				cCodZona := (cAliasQry)->B5_CODZON
			EndIf
			(cAliasQry)->(dbCloseArea())
			If lRet .And. Empty(cCodZona)
				WmsMessage(WmsFmtMsg(STR0013,{{"[VAR01]",cProduto}}),WMSA10103,5/*MSG_HELP*/) // Produto [VAR01] não possui zona de armazenagem informada (SB5).
				lRet := .F.
			EndIf
			If lRet .And. cCodZona != M->TP_CODZON
				// Deve validar se existe uma zona alternativa
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT 1
					FROM %Table:DCH% DCH
					AND DCH.DCH_FILIAL = %xFilial:DCH%
					AND DCH.DCH_CODPRO = %Exp:cProduto%
					AND DCH.DCH_CODZON = %Exp:M->TP_CODZON%
					AND DCH.%NotDel%
				EndSql
				If (cAliasQry)->(Eof())
					WmsMessage(WmsFmtMsg(STR0014,{{"[VAR01]",cProduto},{"[VAR02]",M->TP_CODZON}}),WMSA10104,5/*MSG_HELP*/) // Produto [VAR01] não pode ser armazenado na zona de armazenagem [VAR02].
					lRet := .F.
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
			// Se o produto foi validado deve buscar as informações do mesmo
			If lRet
				nQtdNorma := DLQtdNorma(cProduto, M->TP_LOCAL, M->TP_ESTFIS, /*cDesUni*/, /*lNUnit*/, M->TP_LOCALIZ)
				FWFldPut('TP_NORMA',nQtdNorma)
				FWFldPut('TP_QTDREAB',nQtdNorma)
			EndIf
		Case cField == "TP_QTDREAB"
			nQtdReab := FwFldGet("TP_QTDREAB")
			// Na inclusão de um produto em um endereço vazio, deve validar a quantidade informada contra a norma
			If (cAliasBrw)->TP_ALTPRD == 'S'
				nQtdNorma := DLQtdNorma(M->TP_PRODUTO, M->TP_LOCAL, M->TP_ESTFIS, /*cDesUni*/, /*lNUnit*/, M->TP_LOCALIZ)
				If nQtdNorma < nQtdReab
					WmsMessage(WmsFmtMsg(STR0015,{{"[VAR01]",Str(nQtdNorma)}}),WMSA10105,5/*MSG_HELP*/) // Valor inválido! A quantidade para reabastecimento deste endereço não pode ser superior a [VAR01].
					lRet := .F.
				EndIf
			// Senão, deve validar a quantidade informada contra o que foi calculado automaticamente pelo sistema
			Else
				nQtdMax := (cAliasBrw)->TP_NORMA - (cAliasBrw)->TP_QTDSALD - (cAliasBrw)->TP_QTDPREV
				If QtdComp(nQtdMax) < QtdComp(nQtdReab)
					WmsMessage(WmsFmtMsg(STR0015,{{"[VAR01]",Str(nQtdMax)}}),WMSA10106,5/*MSG_HELP*/) //"Valor inválido! A quantidade para reabastecimento deste endereço não pode ser superior a [VAR01]."
					lRet := .F.
				EndIf
			EndIf
	EndCase
Return lRet
//--------------------------------------------------------------------------------------------------//
//-------------------------Chama a função que processa o reabastecimento----------------------------//
//--------------------------------------------------------------------------------------------------//
Function WMS101PReb(lInterface)
Default lInterface := .t.

	If nContTMP <= 0
		If lInterface
			WmsMessage(STR0018,,1) // Selecione ao menos um item	 para processar o reabastecimento.
		Else
			WmsConout(STR0018)// Selecione ao menos um item para processar o reabastecimento.
		EndIf
	Else
		If !lInterface
			CriaTmpRel()
		EndIf
		// Chamada da função é feita desta forma para que apareça na tela a régua de progressão
		Processa({|| ProcReab01(lInterface)},STR0001,OemToAnsi(STR0016),.T.) // Reabastecimento // Processando Reabastecimento...
	EndIf
Return
//-------------------------------------------------------------------------------//
//-------------------------Processa o Reabastecimento----------------------------//
//-------------------------------------------------------------------------------//
Static Function ProcReab01(lInterface)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cServReab  := ""
Local aMsgLog    := {}
Local nCntMsg    := 0
Local nCont      := 0
Local oRegraConv := WMSBCCRegraConvocacao():New()
Local oOrdServ   := WMSDTCOrdemServicoExecute():New()
Local oAbastece  := WMSBCCAbastecimento():New()
Local oSeqAbast  := WMSDTCSequenciaAbastecimento():New()
Local cMensagem  := ""
Local lGerouTemp := .F.
	// Atribui servico
	cServReab := oAbastece:oOrdServ:oServico:FindReabas()
	If Empty(cServReab)
		If lInterface
			WmsMessage(STR0017,,2)// Não existe um serviço de reabastecimento cadastrado.
		Else
			WmsConout(STR0017)//Não existe um serviço de reabastecimento cadastrado.
		EndIf
		RestArea(aAreaAnt)
		lRet := .F.
	EndIf
	If lRet
		
		oOrdServ:SetArrLib(oRegraConv:GetArrLib())
		// Valor máximo que terá a régua de progressão
		ProcRegua(nContTMP)
		(cAliasBrw)->(DbGoTop())
		Do While (cAliasBrw)->(!Eof())
			oOrdServ:SetDocto( GetSX8Num('DCF', 'DCF_DOCTO') )
			oOrdServ:SetIdDCF("")
			If !Empty((cAliasBrw)->TP_MARK)
				IncProc((cAliasBrw)->(TP_LOCAL+"/"+AllTrim(TP_LOCALIZ)+"/"+TP_PRODUTO))
				// Carrega dados da ordem de serviço que será criada
                //verifica se sequencia de abastecimento do produto possui servico de reabastecimento 
				oOrdServ:oServico:SetServico( cServReab )
				oSeqAbast:SetArmazem((cAliasBrw)->TP_LOCAL)
				oSeqAbast:SetProduto((cAliasBrw)->TP_PRODUTO )
				oSeqAbast:LoadData(1)
				If !Empty(oSeqAbast:GetSerAbas())
					oOrdServ:oServico:SetServico(oSeqAbast:GetSerAbas())
				EndIf
				
				oOrdServ:oOrdEndDes:SetArmazem( (cAliasBrw)->TP_LOCAL )
				oOrdServ:oOrdEndDes:SetEnder( (cAliasBrw)->TP_LOCALIZ )
				// Produto
				oOrdServ:oProdLote:SetArmazem( (cAliasBrw)->TP_LOCAL )
				oOrdServ:oProdLote:SetProduto( (cAliasBrw)->TP_PRODUTO )
				oOrdServ:oProdLote:SetPrdOri((cAliasBrw)->TP_PRDORI )
				oOrdServ:oProdLote:LoadData()
				// Endereço Origem
				oOrdServ:oOrdEndOri:SetArmazem( (cAliasBrw)->TP_LOCAL )
				// Dados gerais
				oOrdServ:SetQuant( (cAliasBrw)->TP_QTDREAB )
				oOrdServ:SetRegra( VAL((cAliasBrw)->TP_REGRA) )
				oOrdServ:SetOrigem("DCF")
				oOrdServ:SetTipReab("M") // Reabastecimento Preventivo
				If !oOrdServ:ExecutePrd()
					cMensagem := oOrdServ:GetErro()
					If !lInterface
						GrvTmpRel((cAliasBrw)->TP_LOCAL,   (cAliasBrw)->TP_LOCALIZ,;
						          (cAliasBrw)->TP_ESTFIS,  (cAliasBrw)->TP_CODZON,;
								  (cAliasBrw)->TP_PRODUTO, cMensagem)
						lGerouTemp := .T.
					EndIF
				Else
					If QtdComp(oOrdServ:GetQuant()) >= QtdComp((cAliasBrw)->TP_QTDREAB)
						cMensagem := STR0022 // Reabastecimento gerado com sucesso.
					Else
						If QtdComp(oOrdServ:GetQuant()) > 0
							cMensagem := WmsFmtMsg(STR0023,{{"[VAR01]",(cAliasBrw)->TP_LOCALIZ},{"[VAR02]",(cAliasBrw)->TP_PRODUTO}}) // Não foi possível reabastecer toda a quantidade para o endereço [VAR01] para o produto [VAR02].
						Else
							cMensagem := WmsFmtMsg(STR0024,{{"[VAR01]",(cAliasBrw)->TP_LOCALIZ},{"[VAR02]",(cAliasBrw)->TP_PRODUTO}}) // Não foi possível reabastecer nenhuma quantidade para o endereço [VAR01] para o produto [VAR02].
						EndIf
					EndIf
				EndIf
				// Carrega os movimentos criados
				For nCont := 1 To Len(oOrdServ:aRecD12)
					AAdd(oOrdServ:aLibD12,oOrdServ:aRecD12[nCont])
				Next
				oOrdServ:aRecD12:= {}

				AAdd(aMsgLog,Array(09))
				nCntMsg := Len(aMsgLog)
				aMsgLog[nCntMsg][01] := oOrdServ:oOrdEndDes:GetArmazem() // Armazém Destino
				aMsgLog[nCntMsg][02] := oOrdServ:oOrdEndDes:GetEstFis()  // Estutura Destino
				aMsgLog[nCntMsg][03] := oOrdServ:oOrdEndDes:GetEnder()   // Endereço Destino
				aMsgLog[nCntMsg][04] := oOrdServ:oProdLote:GetProduto()  // Produto Reabastecimento
				aMsgLog[nCntMsg][05] := oOrdServ:oProdLote:GetDesc()     // Descrição do Produto Reabastecimento
				aMsgLog[nCntMsg][06] := oOrdServ:oOrdEndOri:GetArmazem() // Armazém Origem Reabastecimento
				aMsgLog[nCntMsg][07] := (cAliasBrw)->TP_QTDREAB          // Quantidade solicitada reabastecer
				aMsgLog[nCntMsg][08] := oOrdServ:GetQuant()              // Quantidade reabastecida
				aMsgLog[nCntMsg][09] := cMensagem                        // Mensagem
			EndIf
			(cAliasBrw)->(DbSkip())
		EndDo

		If !Empty(oRegraConv:GetArrLib())
			oRegraConv:LawExecute()
		EndIf
		// Aviso
		If lInterface
			oOrdServ:ShowWarnig()
		Else
			If lGerouTemp
				WMSA101REL()
			EndIf
		EndIf

		If ( __lSX8 )
			ConfirmSX8()
		EndIf

		(cAliasBrw)->(DbGoTop())
		RestArea(aAreaAnt)
		If lInterface
			WMSR100(aMsgLog)
			WMSA101Sel(.F.)
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------------------------------------------------//
//------------------------------Permite selecionar novamente o intervalo------------------------------//
//----------------------------------e recarregar os dados no Browse-----------------------------------//
//----------------------------------------------------------------------------------------------------//
Function WMSA101Sel(lPergunte)
Default lPergunte := .T. // Variável = .F. para quando se usa a função apenas para recarregar os dados
	If lPergunte
		If !Pergunte("WMSA100",.T.)
			Return
		EndIf
	EndIf

	DbSelectArea(cAliasBrw)
	ZAP // Apaga os dados da tabela temporária cAliasBrw

	BrwQuery(.F.)
	oBrowse:Refresh()
Return

//----------------------------------------------------------------------------------------------------//
//--------------------Cria a tabela temporária que irá armazenar as inconsistências-------------------//
//----------------------------------------------------------------------------------------------------//
Static Function CriaTmpRel()
Local aColsSX3 := {}
Local aCamposTmp := {}

    buscarSX3("BE_LOCAL",,aColsSX3)
    Aadd(aCamposTmp,{"LOCAL","C",aColsSX3[3],aColsSX3[4]}) // Local

    buscarSX3("BE_LOCALIZ",,aColsSX3)
    Aadd(aCamposTmp,{"LOCALIZ","C",aColsSX3[3],aColsSX3[4]}) // Localização

    buscarSX3("BE_ESTFIS",,aColsSX3)
    Aadd(aCamposTmp,{"ESTRUTURA","C",aColsSX3[3],aColsSX3[4]}) // Estrutura Física

    buscarSX3("BE_CODZON",,aColsSX3)
    Aadd(aCamposTmp,{"ZONAARM","C",aColsSX3[3],aColsSX3[4]}) // Zona de Armazenagem

    buscarSX3("D14_PRODUT",,aColsSX3)
    Aadd(aCamposTmp,{"PRODUTO","C",aColsSX3[3],aColsSX3[4]}) // Produto

    Aadd(aCamposTmp,{"MENSAGEM","C",200,0}) // Descrição da inconsistência encontrada

    cAliasTemp := CriaTabTmp(aCamposTmp,{"LOCAL+LOCALIZ+PRODUTO"},cAliasTemp)
Return Nil

//----------------------------------------------------------------------------------------------------//
//-------------------------Grava a temporária para armazenar as inconsistências-----------------------//
//----------------------------------------------------------------------------------------------------//
Static Function GrvTmpRel(cLocal, cLocaliz, cEstrutura, cZonaArm, cProduto, cMensagem)

dbSelectArea(cAliasTemp)
Reclock(cAliasTemp,.t.)
(cAliasTemp)->LOCAL      := cLocal
(cAliasTemp)->LOCALIZ    := cLocaliz
(cAliasTemp)->ESTRUTURA  := cEstrutura
(cAliasTemp)->ZONAARM    := cZonaArm
(cAliasTemp)->PRODUTO    := cProduto
(cAliasTemp)->MENSAGEM   := cMensagem
MsUnlock(cAliasTemp)

Return

//----------------------------------------------------------------------------------------------------//
//------------------------------Gera o relatório de inconsistências via Job---------------------------//
//----------------------------------------------------------------------------------------------------//
Static Function WMSA101REL()

oReport:= ReportDef()
oReport:PrintDialog() //gerou no spool

Return

//----------------------------------------------------------
// Definições do relatório
//----------------------------------------------------------
Static Function ReportDef()
Local cTitle    := OemToAnsi("Inconsistências Encontradas - Schedule de Reabastecimento (WMSA101)")
Local oReport
Local oSection1
Local cFile

// Criacao do componente de impressao
//cTitle := "Inconsistências Encontradas - Schedule de Reabastecimento (WMSA101)"
cFile := "inconsschedule_"+StrTran(DTOC(dDATABASE),'/','-')+"_"+StrTran(SubStr(Time(),1,5),":","")
oReport := TReport():New(cFile, 'cTitle', , {|oReport| ReportPrint(oReport,cAliasTemp)} )
oSection := TRSection():New(oReport, cTitle, {"(cAliasTemp)"}, , .T.)
TRCell():New(oSection,"LOCAL",      "(cAliasTemp)","Armazem",,TamSX3('BE_LOCAL')[1]*2,,{|| (cAliasTemp)->LOCAL})
TRCell():New(oSection,"LOCALIZ",    "(cAliasTemp)","Endereço",,TamSX3('BE_LOCALIZ')[1],,{|| (cAliasTemp)->LOCALIZ})
TRCell():New(oSection,"ESTRUT",     "(cAliasTemp)","Estrutura",,TamSX3('BE_LOCALIZ')[1],,{|| (cAliasTemp)->ESTRUTURA})
TRCell():New(oSection,"ZONAARM",    "(cAliasTemp)","Zona Arm.",,TamSX3('BE_LOCALIZ')[1],,{|| (cAliasTemp)->ZONAARM})
TRCell():New(oSection,"PRODUTO",    "(cAliasTemp)","Produto",,TamSX3('D14_PRODUT')[1],,{|| (cAliasTemp)->PRODUTO})
TRCell():New(oSection,"MENSAGEM",   "(cAliasTemp)","Inconsistência",,200,,{|| (cAliasTemp)->MENSAGEM})
oReport:SetReportPortal(cFile)
oReport:SetLandScape()
oReport:SetPreview(.F.)

Return(oReport)
//----------------------------------------------------------
// Impressão do relatório
//----------------------------------------------------------
Static Function ReportPrint(oReport,cAliasTemp)
Local oSection1 := oReport:Section(1)

dbSelectArea(cAliasTemp)
dbGoTop()
oSection1:Init()
oReport:SetMeter((cAliasTemp)->( LastRec() ))
While !oReport:Cancel() .And. !(cAliasTemp)->(Eof())
	oSection1:PrintLine()
	(cAliasTemp)->(dbSkip())
EndDo
oSection1:Finish()

(cAliasTemp)->(dbCloseArea())

Return NIL

//----------------------------------------------------------
// SchedDef - Função do Schedule
//----------------------------------------------------------
Static Function SchedDef()
    Local aParam := {}

    Local aOrd := {}

    aParam := {;
    "R"         ,;  // Tipo: R para relatorio P para processo
    "WMSA100"   ,;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
    "D14"       ,;  // Alias
    aOrd        ,;  // Array de ordens
	"Inconsistencias",; //Titulo
    }

Return aParam
