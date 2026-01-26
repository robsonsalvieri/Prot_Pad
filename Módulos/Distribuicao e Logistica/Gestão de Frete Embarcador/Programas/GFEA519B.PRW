#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA519B.CH"
//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
 // Situação do ponto de controle
Function GFEA519BLE(nOp,cGX3_NRMOV,cGX3_CDOPER, cGX3_SEQ, cGX4_CDPTCT, cGX3_FILIAL)
	Local aAreaGX4
	Local cFilTmp := cFilAnt
	Default cGX3_FILIAL := cFilAnt
	
	_cMov	:= cGX3_NRMOV 	//GX3->GX3_NRMOV
	_cOper := cGX3_CDOPER	//GX3->GX3_CDOPER
	_cSeq  := cGX3_SEQ 		//GX3->GX3_SEQ
	_cPtCt := cGX4_CDPTCT	//GX4->GX4_CDPTCT
	cFilAnt := cGX3_FILIAL
	
	aAreaGX4 := GX4->(GetArea())
	GFEA519BIN()
	RestArea(aAreaGX4)
	
	If Empty(_aAtuPC[1]) .Or. Empty(_aAtuPC[2])
		cFilAnt := cFilTmp 
		Return .F.
	EndIf
	
	If nOp == 1 // Finalizado
		
		If GX4->GX4_SEQ < _aAtuPC[2]
			cFilAnt := cFilTmp
			Return .T.
		ElseIf GFEA519PCP(GX4->GX4_CDPTCT, GX4->GX4_SEQ) .And. !Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI) .And. GX4->GX4_SIT == "2"
			cFilAnt := cFilTmp
			Return .T.
		ElseIf GX3->GX3_SIT == "5"
			cFilAnt := cFilTmp
			Return .T.
		EndIf
	
	ElseIf nOp == 2 // Ponto de controle corrente
	
		If _aAtuPC[1] == GX4->GX4_CDPTCT .And. _aAtuPC[2] == GX4->GX4_SEQ .And. !(GFEA519BIM(GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ) $ "0;1" .And. !Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI))
			cFilAnt := cFilTmp
			Return .T.
		EndIf
	
	ElseIf nOp == 3 // Normal
		
		If (_aAtuPC[1] != GX4->GX4_CDPTCT .Or. _aAtuPC[2] != GX4->GX4_SEQ) .And. (Empty(GX4->GX4_DTSAI) .Or. Empty(GX4->GX4_HRSAI))
			cFilAnt := cFilTmp
			Return .T.
		EndIf
	
	ElseIf nOp == 4 // Pendente ação reprovação
	     
		If !Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI) .And. GX4->GX4_SIT == "3"
	    	cFilAnt := cFilTmp
			Return .T.
		EndIf
	
	EndIf
	
Return .F.

/*
	Verifica se é possível informar ocorrência para um ponto de controle
*/
Function GFEA519BOP(cPtCt)
	Local aArea, lRet
	
	lRet := .F.
	
	aArea := GVF->(GetArea())
	
	GVF->( dbSetOrder(1) )
	If GVF->( dbSeek(xFilial('GVF')+cPtCt) )
		lRet := GVF->GVF_IDOCOR == '1'
	EndIf
    
	RestArea(aArea)

Return lRet

/*
{Protheus.doc} GFEA519BIM
Função para verificar se há ocorrência para o Ponto de Controle

@sample
GFEA519BIM(cMov, cPtCt, cSeq)

@author Octávio Augusto Felippe de Macedo
@since 27/05/2011
@version 1.0
*/

Function GFEA519BIM(cMov, cPtCt, cSeq)
	Local aAreaGX4 := GX4->( GetArea() )
	Local aAreaGVF := GVF->( GetArea() )
	Local aAreaGWD := GWD->( GetArea() )
	
	GX4->( dbSetOrder(1) )
	If GX4->( dbSeek(xFilial("GX4") + cMov + cPtCt + cSeq) )
		
		If !Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI) .And. GX4->GX4_SIT == "3" .And. Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDIMPE") == "1"

			GWD->( dbSetOrder(3) )
			If GWD->( dbSeek(xFilial("GWD") + cMov + cPtCt) )
				While !GWD->(Eof()) .And. GWD->GWD_FILIAL == xFilial("GWD") .And. GWD->GWD_NRMOV == cMov .And. GWD->GWD_CDPTCT == cPtCt
					If DTOS(GWD->GWD_DTOCOR) + StrTran(GWD->GWD_HROCOR,":","") >= DTOS(GX4->GX4_DTSAI) + StrTran(GX4->GX4_HRSAI,":","")
						RestArea(aAreaGX4)
						RestArea(aAreaGVF)
						RestArea(aAreaGWD)
		
						Return GWD->GWD_SIT
					EndIf
					GWD->(dbSkip())
				EndDo
			EndIf

		EndIf

	EndIf
	
	RestArea(aAreaGX4)
	RestArea(aAreaGVF)
	RestArea(aAreaGWD)
	
Return "0"

/*
{Protheus.doc} GFEA519BIN
Função para retornar o filtro

@sample
GFEA519BIN()

@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/

Function GFEA519BIN()
	Local lLast     := .F.
	Local aAreaGX3  := GX3->( GetArea() )
	Local aAreaGX4  := GX4->( GetArea() )
	Local aChave    := {,}
	Local cAliasGX3 := Nil
	Local cOp       := ""
	Local cAddF     := ""
	Local cOcor     := ""
	Local cChave    := ""

	Private cCodUsr := RetCodUsr() //Código usuario
	Private cFilAtu := cFilAnt
	
	cFilAnt := GX3->GX3_FILIAL

	cAliasGX3 := GetNextAlias()
	BeginSql Alias cAliasGX3
		SELECT 1
		FROM %Table:GX3% GX3
		INNER JOIN %Table:GVP% GVP
		ON GVP.GVP_FILIAL = %xFilial:GVP%
		AND GVP.GVP_CDUSUR = %Exp:cCodUsr%
		WHERE GX3.GX3_FILIAL = %xFilial:GX3%
		AND GX3.GX3_NRMOV = %Exp:_cMov%
		AND GX3.%NotDel%
	EndSql
	If (cAliasGX3)->(Eof())
		cFilAnt := cFilAtu
	EndIf
	(cAliasGX3)->(dbCloseArea())

	lAlt := If(Posicione("GX3",1,xFilial("GX3") + _cMov, "GX3_SIT") $ "5;6",.F.,.T.)

	GX4->( dbSetOrder(4) )
	GX4->( dbSeek(xFilial("GX4") + _cMov) )
	Do While GX4->(!Eof()) .And. GX4->GX4_FILIAL == xFilial("GX4") .And. GX4->GX4_NRMOV == _cMov .And. !lLast 

		aChave := {GX4->GX4_CDPTCT, GX4->GX4_SEQ}

		If GX4->GX4_SIT == "1"
			cOp := "1"
		ElseIf ( Empty(GX4->GX4_DTSAI) .Or. Empty(GX4->GX4_HRSAI) ) .And. GX4->GX4_SIT == "2"
			cOp := "2"
		ElseIf ( !Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI) ) .And. GX4->GX4_SIT == "2"
			cOp := "3"
		ElseIf ( Empty(GX4->GX4_DTSAI) .Or. Empty(GX4->GX4_HRSAI) ) .And. GX4->GX4_SIT == "3"
			cOp := "4"
		ElseIf ( !Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI) ) .And. GX4->GX4_SIT == "3"
			cOp := "5"
		EndIf

		/*
		1- Ponto de Controle com situação 'Não Avaliado'
		2- Ponto de Controle sem Data/Hora de Saída e 'Aprovado'
		3- Ponto de Controle com Data/Hora de Saída e 'Aprovado'
		4- Ponto de Controle sem Data/Hora de Saída e 'Reprovado'
		5- Ponto de Controle com Data/Hora de Saída e 'Reprovado'
		*/
		
		cOcor := GFEA519BIM(GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ)
		
		If cOp $ "124"
			Exit
		Else
			If cOp == "5" .And. Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDIMPE") == "1" 
				If cOcor == "3"
					cImped := AllTrim(GX4->GX4_CDPTCT) + "-" + GX4->GX4_SEQ
					lLast  := .T.
				ElseIf cOcor $ "0;1"
					Exit
				EndIf
			EndIf
		EndIf
		
		GX4->( dbSkip() )
	EndDo
	
	aCopy(aChave, _aAtuPC)
	
	If lAlt
		GVJ->( dbSetOrder(1) )
		If _cPtCt == aChave[1]
			lSame := .T.
			cChave := xFilial("GVJ") + _cOper + _cSeq + aChave[2]
		Else
			cChave := xFilial("GVJ") + _cOper + _cSeq
		EndIf
		
		If GVJ->( dbSeek( cChave ) )
		
			Do While GVJ->(!Eof()) .And. ;
				GVJ->GVJ_FILIAL == xFilial("GVJ").And. ;
				GVJ->GVJ_CDOPER == _cOper.And. ;
				GVJ->GVJ_SEQ	 == _cSeq .And. ;
				(_cPtCt != aChave[1] .Or. (GVJ->GVJ_CDPTCT == aChave[1] .And. GVJ->GVJ_ORDEM == aChave[2]))
				
				If GVJ->GVJ_CDPTCT == _cPtCt
					If GVJ->GVJ_IDACES == "1"
						aPtCt := {GVJ->GVJ_CDPTCT, GVJ->GVJ_ORDEM, "1", lLast}
					ElseIf GVJ->GVJ_IDACES == "2"
						aPtCt := {GVJ->GVJ_CDPTCT, GVJ->GVJ_ORDEM, "2", lLast}
					ElseIf GVJ->GVJ_IDACES == "3"
						aPtCt := {GVJ->GVJ_CDPTCT, GVJ->GVJ_ORDEM, "3", lLast}
						cAddF := " .And. GX4_CDPTCT == '" + GVJ->GVJ_CDPTCT + If(lSame, "' .And. GX4_SEQ == '"+GVJ->GVJ_ORDEM+"'", "' ")
					EndIf
					 
				EndIf
				GVJ->( dbSkip() )
			EndDo
		EndIf
		cFiltro := " GX4_NRMOV == '" + _cMov + "' " + cAddF
	Else
		cFiltro := " GX4_NRMOV == '" + _cMov + "' "
	EndIf	
	RestArea(aAreaGX4)
	RestArea(aAreaGX3)
	cFilAnt := cFilAtu
Return cFiltro

//-------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}
	Local aRotAdic := {}
	ADD OPTION aRotina TITLE STR0004				ACTION "GFEA519BVI()" 	OPERATION 4  ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0005				ACTION "VIEWDEF.GFEA519B" 	OPERATION 8  ACCESS 0 //"Imprimir"
	ADD OPTION aRotina TITLE "Instruções"			ACTION "GFEA519BSI()" 		OPERATION 10 ACCESS 0 //"Instrucao"
	ADD OPTION aRotina TITLE "Ocorrência"			ACTION "GFEA519OCO()" 		OPERATION 10 ACCESS 0 //"Ocorrencia"
	ADD OPTION aRotina TITLE "Avaliar Reprovação"	ACTION "GFEA519BAR()" 		OPERATION 10 ACCESS 0 //"Avaliar Reprovacao"
	ADD OPTION aRotina TITLE "Imprimir Checklist"	ACTION "GFEA519BPC()" 		OPERATION 10 ACCESS 0 //"Imprimir Checklist"
	ADD OPTION aRotina TITLE STR0065 				ACTION "GFEA519BRP()"    	OPERATION 4  ACCESS 0 //"Retornar PC anterior"
	ADD OPTION aRotina TITLE "Resumo do Ponto de Controle" ACTION "GFEA519RPT()"    	OPERATION 10 ACCESS 0

	If ExistBlock("GFE519B1")
		aRotAdic := ExecBlock("GFE519B1",.F.,.F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic, {|x| AAdd(aRotina ,x)})
		EndIf
	EndIf

Return aRotina

Function GFEA519RPT()
	Local oModel
	If Empty(GX4->GX4_DTSAI)
		GfeMsgErro("O Resumo do Ponto de Controle só estará disponível após informar a data de saída.")
		Return
	EndIf
	//Faz um carregamento do model para ativar o array de valid dos campos 
	oModel:= FwLoadModel("GFEA519B")
	oModel:SetOperation( 4 )
	oModel:Activate()
	oModel:LMODIFY := .T.
	oModel:VldData()
	GFEA519BRE(,.F.)
	FreeObj(oModel)
Return

//-------------------------------------------------------------------

Function GFEA519BVW()
	Local aAreaGX4 := GX4->(GetArea())
	
	FWExecView("Visualizar","GFEA519B",MODEL_OPERATION_VIEW,,{||.T.})
	oBrwGX4:Refresh()
	RestArea(aAreaGX4)
	
Return

Function GFEA519BVI()
	Local aAreaGX4  := GX4->(GetArea())
	Local nRetPeso  := 0
	Local lGFEA5237 := ExistBlock("GFEA5237")

	If lGFEA5237
		nRetPeso := 0
						
		nRetPeso := ExecBlock("GFEA5237", .F., .F., {GX4->GX4_FILIAL, _cMov, _cPtCt, cPlaca, GX4->GX4_QTPESO})

		If nRetPeso <> 0
			RecLock("GX4", .F.)
				GX4->GX4_QTPESO := nRetPeso
			GX4->(MsUnlock())
		EndIf
	EndIf 
	
	FWExecView("Alterar","GFEA519B",MODEL_OPERATION_UPDATE)
	RestArea(aAreaGX4)
Return

Static Function ModelDef()
	Local oModel
	Local oStructGX4 := FWFormStruct(1,"GX4")
	Local oStructGXA := FWFormStruct(1,"GXA")
	Local oStructGX5 := FWFormStruct(1,"GX5")
	
	oStructGX4:SetProperty("GX4_CDENDE",MODEL_FIELD_OBRIGAT,.F.)
		
	oStructGXA:SetProperty("GXA_NRMOV" ,MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:= (GX4->GX4_NRMOV ),FWCloseCpo(a,b,c,.T.),lRetorno } )
	oStructGXA:SetProperty("GXA_CDPTCT",MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:= (GX4->GX4_CDPTCT),FWCloseCpo(a,b,c,.T.),lRetorno } )
	oStructGXA:SetProperty("GXA_SEQ"   ,MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:= (GX4->GX4_SEQ   ),FWCloseCpo(a,b,c,.T.),lRetorno } )
	
	oStructGX5:SetProperty("GX5_NRMOV" ,MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:= (GX4->GX4_NRMOV ),FWCloseCpo(a,b,c,.T.),lRetorno } )
	oStructGX5:SetProperty("GX5_CDPTCT",MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:= (GX4->GX4_CDPTCT),FWCloseCpo(a,b,c,.T.),lRetorno } )
	oStructGX5:SetProperty("GX5_SEQ"   ,MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:= (GX4->GX4_SEQ   ),FWCloseCpo(a,b,c,.T.),lRetorno } )

	oModel := MPFormModel():New("GFEA519B", /*bPre*/, {|oMod| GFEA519BPO(oMod)}, {|oMod| GFEA519BCMT(oMod)}, /*bCancel*/)
	
	oModel:AddFields("GFEA519B_GX4", Nil, oStructGX4,/*bPre*/,,/*bLoad*/)
	oModel:SetPrimaryKey({"GX4_FILIAL", "GX4_NRMOV"})

	oModel:AddGrid("GFE519BGXA","GFEA519B_GX4",oStructGXA,/*{|oModel| GFEA519DOC(oModel)}*/,{|oModel| GFE519PreT(oModel), GFEA519GXA(oModel)},/*bLinePost*/,/*bPre*/,/*bLoad*/)
	oModel:SetRelation("GFE519BGXA",{{"GXA_FILIAL",'xFilial("GXA")'},{"GXA_NRMOV","GX4_NRMOV"},{"GXA_CDPTCT","GX4_CDPTCT"},{"GXA_SEQ","GX4_SEQ"}},"GXA_FILIAL+GXA_NRMOV")
	oModel:GetModel("GFE519BGXA"):SetDelAllLine(.T.)
	oModel:GetModel("GFE519BGXA"):SetOptional(.T.)
	
	oModel:AddGrid("GFE519BGX5","GFEA519B_GX4",oStructGX5, {|oModel| GFEA519LVA(oModel)} /*bLinePre*/,{|oModel| GFEA519GX5(oModel)},/*bLinePost*/,/*bPre*/,/*bLoad*/)
	oModel:SetRelation("GFE519BGX5",{{"GX5_FILIAL","xFilial('GX5')"},{"GX5_NRMOV","GX4_NRMOV"},{"GX5_CDPTCT","GX4_CDPTCT"},{"GX5_SEQ","GX4_SEQ"}},"R_E_C_N_O_")
	oModel:GetModel("GFE519BGX5"):SetDelAllLine(.T.)
	oModel:GetModel("GFE519BGX5"):SetOptional(.T.)

	oModel:SetVldActivate({|oMod| GFEA519BVL(oMod)})
	oModel:SetActivate({|oMod| GFEA519BAC(oMod)})
		
Return oModel

//-------------------------------------------------------------------

Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA519B")
	Local oView  := Nil
	Local oStructGX4 := FWFormStruct(2,"GX4")
	Local oStructGXA := FWFormStruct(2,"GXA")
	Local oStructGX5 := FWFormStruct(2,"GX5")
	
	oStructGXA:RemoveField("GXA_NRMOV" )
	oStructGXA:RemoveField("GXA_CDPTCT")
	oStructGXA:RemoveField("GXA_SEQ")
	
	oStructGX5:RemoveField("GX5_NRMOV" )
	oStructGX5:RemoveField("GX5_CDPTCT")
	oStructGX5:RemoveField("GX5_DSPTCT")
	oStructGX5:RemoveField("GX5_SEQ"   )
	
	oStructGX4:RemoveField("GX4_CDENDE")
	oStructGX4:RemoveField("GX4_DSENDE")
	oStructGX4:RemoveField("GX4_PRIORI")
	oStructGX4:RemoveField("GX4_QTPEEN")
	oStructGX4:RemoveField("GX4_QTVEEN")
	oStructGX4:RemoveField("GX4_DTCHEN")
	oStructGX4:RemoveField("GX4_HRCHEN")
	oStructGX4:RemoveField("GX4_DTINCA")
	oStructGX4:RemoveField("GX4_HRINCA")
	oStructGX4:RemoveField("GX4_DTFICA")
	oStructGX4:RemoveField("GX4_HRFICA")
	oStructGX4:RemoveField("GX4_DTLIEN")
	oStructGX4:RemoveField("GX4_HRLIEN")
	oStructGX4:RemoveField("GX4_DTSAEN")
	oStructGX4:RemoveField("GX4_HRSAEN")
		
	oView := FWFormView():New()
		
	oView:SetModel(oModel)
	oView:AddField("GFEA519B_GX4", oStructGX4 )
	oView:AddGrid("GFE519BGXA", oStructGXA )
	oView:AddGrid("GFE519BGX5", oStructGX5 )
	
	oView:CreateHorizontalBox("MASTER" , 55, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox("DETAIL" , 45 )

	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER", "IDSHEET01", "Endereço")
	oView:AddSheet("IDFOLDER", "IDSHEET02", STR0006) //"Documentos de Carga"
	oView:AddSheet("IDFOLDER", "IDSHEET03", "Checklist"/*STR0007*/) //"Perguntas"
	
	
	oView:CreateHorizontalBox("DETAILAG" , 100,,,"IDFOLDER","IDSHEET02" )
	oView:CreateHorizontalBox("DETAILBG" , 100,,,"IDFOLDER","IDSHEET03" )

	oView:CreateHorizontalBox("ENDERECO" , 30,,,"IDFOLDER","IDSHEET01")
	oView:CreateHorizontalBox("ENDDETAI" , 70,,,"IDFOLDER","IDSHEET01")
	
	//Não mvc
	oView:AddOtherObject("ENDGROUP", {|oPanel| COMP519GEND(oPanel,oView)}) //Endereço
	oView:AddOtherObject("ENDDATAS", {|oPanel| COMP519DEND(oPanel,oView)}) //Data/hora
	
	oView:SetOwnerView("GFEA519B_GX4", "MASTER"   )
	oView:SetOwnerView("GFE519BGXA"  , "DETAILAG" )
	oView:SetOwnerView("GFE519BGX5"  , "DETAILBG" )
	oView:SetOwnerView("ENDGROUP", "ENDERECO")
	oView:SetOwnerView("ENDDATAS", "ENDDETAI")
	
	
	//Botões referentes as datas
	oView:AddUserButton(STR0128, "MAGIC_BMP", {|oView| GFEA519BDT(oView, 2)}, ) // "Dt Cheg End"
	oView:AddUserButton(STR0129, "MAGIC_BMP", {|oView| GFEA519BDT(oView, 3)}, ) // "Dt Ini Carg/Desc"
	oView:AddUserButton(STR0130, "MAGIC_BMP", {|oView| GFEA519BDT(oView, 4)}, ) // "Dt Fim Carg/Desc"
	oView:AddUserButton(STR0131, "MAGIC_BMP", {|oView| GFEA519BDT(oView, 5)}, ) // "Dt Lib Ender"
	oView:AddUserButton(STR0132, "MAGIC_BMP", {|oView| GFEA519BDT(oView, 6)}, ) // "Dt Saíd End"
	
	oView:AddUserButton(STR0012, "MAGIC_BMP", {|oView| GFEA519BCH(oView)}, ) // "Chamar Veículo"
	oView:AddUserButton(STR0066, "MAGIC_BMP", {|oView| GFEA519BFI(oView)}, ) // "Fila"
	oView:AddUserButton("Doc. Relac.", "MAGIC_BMP", {|oView| GFE519REL(oView)}, )
	
	oView:SetCloseOnOk({|oView| lModified := oView:GetModel():lModify .And. oView:GetModel():VldData(), .T.})
	oView:SetAfterOkButton({|oView| GFEA519BRE(oView)})

	//CHAMADA DE FUNCAO AGROINDUSTRIA
	If FindFunction("AGRA870aVL") .AND. (SuperGetMV("MV_AGRUBS",.F.,.F.))
		oView:AddUserButton("Log Validação", "MAGIC_BMP", {|oView| AGRA870aVL(oView)}, )
	EndIf

Return oView

//Monta o painel com informações de endereço
Function COMP519GEND(oPanel,oView,lVer)
	
	Local aStructGX4 := {FWFormStruct(1,"GX4"),{},FWFormStruct(2,"GX4")}
	Local aCampo
	Local oPan
	Local oGrpDt
	Local oGet
	Local lReadOnly := !(oView:GetModel():GetOperation() == MODEL_OPERATION_INSERT .Or. oView:GetModel():GetOperation() == MODEL_OPERATION_UPDATE)
	Local nCliArea //area total de um bloco Horizontal
	Local nVCliArea //area total de um bloco Vertical
	Local nBlocoCli := 15 // Quantidade de colunas de desenho Horizontal
	Local nVBlocoCli := 4 // Quantidade de colunas de desenho Vertical
	Local nMargemComp // Margem de componente Horizontal
	Local nVMargemComp // Margem de componente Vertical
	Default lVer := .F. // Define a orientação Vertical/Horizontal
	// -- Margens Esquerda x Direita
	oPan := TPanel():New(0,60,,oPanel,,,,,,5,2,,)
	oPan:Align := CONTROL_ALIGN_LEFT
	
	oPan := TPanel():New(0,60,,oPanel,,,,,,5,2,,)
	oPan:Align := CONTROL_ALIGN_RIGHT
	
	oPan := TPanel():New(0,60,,oPanel,,,,,,20,2,,)
	oPan:Align := CONTROL_ALIGN_TOP
	
	If lVer
		oSize := FWDefSize():New(.T.)
		oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	//	oSize:SetWindowSize({000,000, nAlt,nLrg})
		oSize:lLateral     := .F.  // Calculo vertical
		oSize:Process() //executa os calculos
		aPos := {oSize:GetDimension("ENCHOICE","LININI"),;
			oSize:GetDimension("ENCHOICE","COLINI"),;
			oSize:GetDimension("ENCHOICE","XSIZE"),;
			oSize:GetDimension("ENCHOICE","YSIZE")}
       
	Else
		aPos := {0,0,0,0}
	EndIf
	
	oGrpDt := tGroup():New(0,0,27,55,"Endereço",oPanel,,CLR_GRAY,.T.)
	oGrpDt:Align := CONTROL_ALIGN_ALLCLIENT
	
	nCliArea := Int(Int(oGrpDt:NCLIENTWIDTH/2)/nBlocoCli)
	nVCliArea := Int(Int(oGrpDt:NCLIENTHEIGHT/2)/nVBlocoCli)
	nMargemComp := Int(oGrpDt:NCLIENTHEIGHT/4)-8
	If nMargemComp< 8
		nMargemComp := 8
	EndIf
	nVMargemComp := 6
	If lVer
		nMargemComp := 8
	EndIf
	
	// Código do endereço
	aCampo := aStructGX4[3]:AFields[aScan(aStructGX4[3]:AFIELDS,{|x|x[1] == "GX4_CDENDE"})]
	
	oFont := TFont():New ("Arial", , -11, , .F., , , , , .F., .F. )
	
	oSay := tSay():New(nMargemComp+aPos[1],10+aPos[2],{||COMP519SAY("GX4","GX4_CDENDE")},oGrpDt,,oFont,,,,.T.,RGB(0,74,119),,If(lVer,nCliArea*3,nCliArea),10)
	
	oGet := tGet():New(nMargemComp+8+aPos[1],10+aPos[2],{|u| if(PCount()>0,COMP519SET(oView,"GFEA519B_GX4","GX4_CDENDE",u,M->GX4_CDENDE),COMP519GET(oView,"GFEA519B_GX4","GX4_CDENDE"))},oGrpDt,If(lVer,nCliArea*3,nCliArea),10,aCampo[7],,0,,,,, .T.,,,,,,,.F.,.F.,,"M->GX4_CDENDE",,,,.T.  )
//	oGet:SetCss(FWGetCSS( "TGET", CSS_GET_HASBTN ))
	If !lReadOnly
		oGet:cF3 := aCampo[9]
	EndIf
	oGet:bWhen := {||GFEA519BEN() .And. !lReadOnly}
	oGet:bValid := {||GFEA519BVE()}
	
	
	//Descrição do endereço
	aCampo := aStructGX4[3]:AFields[aScan(aStructGX4[3]:AFIELDS,{|x|x[1] == "GX4_DSENDE"})]
	
	oSay := tSay():New(nMargemComp+aPos[1],If(lVer,4*nCliArea,2*nCliArea)+aPos[2],{||COMP519SAY("GX4","GX4_DSENDE")},oGrpDt,,oFont,,,,.T.,RGB(0,74,119),,If(lVer,11*nCliArea,7*nCliArea),10)
	
	oGet := tGet():New(nMargemComp+8+aPos[1],If(lVer,4*nCliArea,2*nCliArea)+aPos[2],{|u| if(PCount()>0,M->GX4_DSENDE:=COMP519POSI(oView,{{"GFEA519B_GX4","GX4_CDENDE"}},"GVD",1,"GVD_DSENDE"),;
		COMP519POSI(oView,{{"GFEA519B_GX4","GX4_CDENDE"}},"GVD",1,"GVD_DSENDE"))},oGrpDt,If(lVer,11*nCliArea,7*nCliArea),10,aCampo[7],,,,,,,.T.,,,,,,,lReadOnly,,,"M->"+aCampo[1],,,1)
	oGet:bWhen := {||.F.}
	
	//Prioridade
	aCampo := aStructGX4[3]:AFields[aScan(aStructGX4[3]:AFIELDS,{|x|x[1] == "GX4_PRIORI"})]
	If lVer
		nMargemComp := 2*nVMargemComp + nVCliArea
	EndIf
	oSay := tSay():New(nMargemComp+aPos[1],If(lVer,10,10*nCliArea)+aPos[2],{||COMP519SAY("GX4","GX4_PRIORI")},oGrpDt,,oFont,,,,.T.,RGB(0,74,119),,If(lVer,nCliArea*3,nCliArea),10)
	
	oCombo := TComboBox():New(nMargemComp+8+aPos[1],If(lVer,10,10*nCliArea)+aPos[2],{|u| if(PCount()>0,COMP519SET(oView,"GFEA519B_GX4","GX4_PRIORI",u),COMP519GET(oView,"GFEA519B_GX4","GX4_PRIORI"))},aCampo[13],If(lVer,nCliArea*3,nCliArea),10,oGrpDt,,,,,,.T.,oFont,,,,,,,,"M->"+aCampo[1])
	oCombo:bWhen := {||GFEA519BEN() .And. !lReadOnly}
//	Quantidade de pessoas 
	aCampo := aStructGX4[3]:AFields[aScan(aStructGX4[3]:AFIELDS,{|x|x[1] == "GX4_QTPEEN"})]
	If lVer
		nMargemComp := 2*nVMargemComp + nVCliArea
	EndIf
	oSay := tSay():New(nMargemComp+aPos[1],If(lVer,6.5*nCliArea,12*nCliArea)+aPos[2],{||COMP519SAY("GX4","GX4_QTPEEN")},oGrpDt,,oFont,,,,.T.,RGB(0,74,119),,If(lVer,nCliArea*3,nCliArea),10)
	
	oSpinBox := tSpinBox():new(nMargemComp+8+aPos[1], If(lVer,6.5*nCliArea,12*nCliArea)+aPos[2], oGrpDt, {|U| COMP519SET(oView,"GFEA519B_GX4","GX4_QTPEEN",u) }, If(lVer,nCliArea*3,nCliArea), 12)
	oSpinBox:setRange(0, 999)
	oSpinBox:setStep(1)
	oSpinBox:setValue(COMP519GET(oView,"GFEA519B_GX4","GX4_QTPEEN"))
	oSpinBox:bWhen := {||GFEA519BAT() .And. !lReadOnly}
    //	Quantidade de Veículos  
	aCampo := aStructGX4[3]:AFields[aScan(aStructGX4[3]:AFIELDS,{|x|x[1] == "GX4_QTVEEN"})]
	If lVer
		nMargemComp := 2*nVMargemComp + nVCliArea
	EndIf
	oSay := tSay():New(nMargemComp+aPos[1],If(lVer,12*nCliArea,14*nCliArea)+aPos[2],{||COMP519SAY("GX4","GX4_QTVEEN")},oGrpDt,,oFont,,,,.T.,RGB(0,74,119),,If(lVer,nCliArea*3,nCliArea),10)
	
	oSpinBox := tSpinBox():new(nMargemComp+8+aPos[1], If(lVer,12*nCliArea,14*nCliArea)+aPos[2], oGrpDt, {|U| COMP519SET(oView,"GFEA519B_GX4","GX4_QTVEEN",u) }, If(lVer,nCliArea*3,nCliArea), 12)
	oSpinBox:setRange(0,999)
	oSpinBox:setStep(1)
	oSpinBox:setValue(COMP519GET(oView,"GFEA519B_GX4","GX4_QTVEEN"))
	oSpinBox:bWhen := {||GFEA519BAT() .And. !lReadOnly}
	
Return .T.
//Monta o painel com informações de controle de endereço
Function COMP519DEND(oPanel,oView)
	Local aCampo := {}
	Local oStructGX4 := FWFormStruct(2,"GX4")
	Local oPan
	Local oPanDT
	Local oGroup
	Local oFont
	Local nCliAreaW //largura total de um bloco
	Local nCliAreaH //altura total de um bloco
	Local nCliAltura // altura
	Local nBlocoCliW := 15 // Quantidade de colunas de desenho
	Local nBlocoCliH := 9 // Quantidade de colunas de desenho
	Local nCompo := 5 //Quantidade de componentes que serao alinhados
	Local nMargemComp // Margem de componente
	Local nMargemGr	// Margem dos TGroups
	Local lReadOnly := !(oView:GetModel():GetOperation() == MODEL_OPERATION_INSERT .Or. oView:GetModel():GetOperation() == MODEL_OPERATION_UPDATE)
	Local oBtn1, oBtn2, oBtn3, oBtn4, oBtn5
	Local oViews := FWViewActive()
	Local cInfEnd
	Local cInfDoc
	// -- Margens Esquerda x Direita
	oPan := TPanel():New(0,60,,oPanel,,,,,,5,2,,)
	oPan:Align := CONTROL_ALIGN_LEFT
	
	oPan := TPanel():New(0,60,,oPanel,,,,,,5,2,,)
	oPan:Align := CONTROL_ALIGN_RIGHT
	
	oPan := TPanel():New(0,60,,oPanel,,,,,,20,2,,)
	oPan:Align := CONTROL_ALIGN_TOP
	
	oPanDT := TPanel():New(0,60,,oPanel,,,,,,20,2,,)
	oPanDT:Align := CONTROL_ALIGN_ALLCLIENT
	
	nMargemComp := Int(Int(Int(oPanDT:NCLIENTWIDTH/2)/nBlocoCliW)/(nCompo -1 ))
	
	nCliAreaW := ((oPanDT:NCLIENTWIDTH/2)/nBlocoCliW)
	If nCliAreaW < 40
		nCliAreaW := 40
	EndIf
	nCliAreaWC:= nCliAreaW + nMargemComp
	If nCliAreaWC < 45
		nCliAreaWC := 45
	EndIf
	nMargemGr	:= nCliAreaW
	nCliAltura := oPanDT:NCLIENTHEIGHT/2
	nCliAreaH := nCliAltura/nBlocoCliH
	
	
	//	1.Chegada Endereço
	oGroup := tGroup():New(0,0,nCliAltura,(nCliAreaW*3),"1.Chegada Endereço",oPanDT,,CLR_GRAY,.T.)

	//Data Chegada Endereço
	aCampo := oStructGX4:AFields[aScan(oStructGX4:AFields,{|x|x[1] == "GX4_DTCHEN"})]
	
	oFont := TFont():New ("Arial", , -11, , .F., , , , , .F., .F. )
	
	oSay := tSay():New(nMargemComp,nMargemGr,{||"Data:"},oGroup,,oFont,,,,.T.,RGB(0,74,119),,nCliAreaWC,10)
	oSay:lTransparent := .T.
	
	oGet := tGet():New(nMargemComp+8,nMargemGr,{|u| if(PCount()>0,M->GX4_DTCHEN:=u,M->GX4_DTCHEN )},oGroup,nCliAreaWC,10,aCampo[7],,,,,,,.T.,,,,,,,lReadOnly,,,"M->"+aCampo[1],,,1,.T.)
	oGet:bWhen:= {||.F.}
	
	//Hora Chegada Endereço
	aCampo := oStructGX4:AFields[aScan(oStructGX4:AFields,{|x|x[1] == "GX4_HRCHEN"})]
	
	oSay := tSay():New(nMargemComp+nCliAreaH*3,nMargemGr,{||"Hora:"},oGroup,,oFont,,,,.T.,RGB(0,74,119),,nCliAreaWC,10)
	oSay:lTransparent := .T.
	
	oGet := tGet():New(nMargemComp+nCliAreaH*3+8,nMargemGr,{|u| if(PCount()>0,M->GX4_HRCHEN:=u,M->GX4_HRCHEN )},oGroup,nCliAreaWC-11,10,'@R 99:99',,,,,,,.T.,,,,,,,lReadOnly,,,"M->"+aCampo[1],,,1,.T.)
	oGet:bWhen:= {||.F.}
	
	// botão Informar chegada endereço	
	
	oBtn1 := tButton():New(1.5*nMargemComp+nCliAreaH*6,nMargemGr,"Informar",oGroup,{|oBtn|COMP519INF(oView,2,oBtn2)},nCliAreaWC,10,,oFont,,.T.,,,,{||COMP519NIVEL(.F.,1) .And. !lReadOnly})
	
	// -------------- Fim Data Chegada -------------------
	
	//	"2.Início Carga/Descarga"
	oGroup := tGroup():New(0, nCliAreaW*3 + nMargemComp,nCliAltura, (nCliAreaW*6)  ,"2.Início Carga/Descarga",oPanDT,,CLR_GRAY,.T.)

	//Data Início Carga/Descarga
	aCampo := oStructGX4:AFields[aScan(oStructGX4:AFields,{|x|x[1] == "GX4_DTINCA"})]
	
	oSay := tSay():New(nMargemComp,nMargemGr*4,{||"Data:"},oGroup,,oFont,,,,.T.,RGB(0,74,119),,nCliAreaWC,10)
	oSay:lTransparent := .T.
	
	oGet := tGet():New(nMargemComp+8,nMargemGr*4,{|u| if(PCount()>0,M->GX4_DTINCA:=u,M->GX4_DTINCA )},oGroup,nCliAreaWC,10,aCampo[7],,,,,,,.T.,,,,,,,lReadOnly,,,"M->"+aCampo[1],,,1,.T.)
	oGet:bWhen:= {||.F.}
	
	//Hora Início Carga/Descarga
	aCampo := oStructGX4:AFields[aScan(oStructGX4:AFields,{|x|x[1] == "GX4_HRINCA"})]
	
	oSay := tSay():New(nMargemComp+nCliAreaH*3,nMargemGr*4,{||"Hora:"},oGroup,,oFont,,,,.T.,RGB(0,74,119),,nCliAreaWC,10)
	oSay:lTransparent := .T.
	
	oGet := tGet():New(nMargemComp+nCliAreaH*3+8,nMargemGr*4,{|u| if(PCount()>0,M->GX4_HRINCA:=u,M->GX4_HRINCA )},oGroup,nCliAreaWC-11,10,'@R 99:99',,,,,,,.T.,,,,,,,lReadOnly,,,"M->"+aCampo[1],,,1,.T.)
	oGet:bWhen:= {||.F.}
	
	// botão Informar Início Carga/Descarga
	
	oBtn2 := tButton():New(1.5*nMargemComp+nCliAreaH*6,nMargemGr*4,"Informar",oGroup,{||COMP519INF(oView,3,oBtn3)},nCliAreaWC,10,,oFont,,.T.,,,,{||COMP519NIVEL(.F.,2) .And. !lReadOnly})
	
	// -------------- Fim Início Carga/Descarga -------------------
	
	//	"3.Fim Carga/Descarga"
	oGroup := tGroup():New(0,nCliAreaW*6 + nMargemComp,nCliAltura,(nCliAreaW*9) ,"3.Fim Carga/Descarga",oPanDT,,CLR_GRAY,.T.)

	//Data Fim Carga/Descarga
	aCampo := oStructGX4:AFields[aScan(oStructGX4:AFields,{|x|x[1] == "GX4_DTFICA"})]
	
	oSay := tSay():New(nMargemComp,nMargemGr*7,{||"Data:"},oGroup,,oFont,,,,.T.,RGB(0,74,119),,nCliAreaWC,10)
	oSay:lTransparent := .T.
	
	oGet := tGet():New(nMargemComp+8,nMargemGr*7,{|u| if(PCount()>0,M->GX4_DTFICA:=u,M->GX4_DTFICA )},oGroup,nCliAreaWC,10,aCampo[7],,,,,,,.T.,,,,,,,lReadOnly,,,"M->"+aCampo[1],,,1,.T.)
	oGet:bWhen:= {||.F.}
	
	//Hora Fim Carga/Descarga
	aCampo := oStructGX4:AFields[aScan(oStructGX4:AFields,{|x|x[1] == "GX4_HRFICA"})]
	
	oSay := tSay():New(nMargemComp+nCliAreaH*3,nMargemGr*7,{||"Hora:"},oGroup,,oFont,,,,.T.,RGB(0,74,119),,nCliAreaWC,10)
	oSay:lTransparent := .T.
	
	oGet := tGet():New(nMargemComp+nCliAreaH*3+8,nMargemGr*7,{|u| if(PCount()>0,M->GX4_HRFICA:=u,M->GX4_HRFICA )},oGroup,nCliAreaWC-11,10,'@R 99:99',,,,,,,.T.,,,,,,,lReadOnly,,,"M->"+aCampo[1],,,1,.T.)
	oGet:bWhen:= {||.F.}
	
	// botão Informar Fim Carga/Descarga
	
	oBtn3 := tButton():New(1.5*nMargemComp+nCliAreaH*6,nMargemGr*7,"Informar",oGroup,{||COMP519INF(oView,4,oBtn4)},nCliAreaWC,10,,oFont,,.T.,,,,{||COMP519NIVEL(.F.,3) .And. !lReadOnly})
	
	// -------------- Fim fim Carga/Descarga -------------------
	
	//	"4.Liberação Endereço"	
	oGroup := tGroup():New(0,nCliAreaW*9 + nMargemComp ,nCliAltura,(nCliAreaW*12)  ,"4.Liberação Endereço",oPanDT,,CLR_GRAY,.T.)

	//Data Liberação Endereço
	aCampo := oStructGX4:AFields[aScan(oStructGX4:AFields,{|x|x[1] == "GX4_DTLIEN"})]
	
	oSay := tSay():New(nMargemComp,nMargemGr*10,{||"Data:"},oGroup,,oFont,,,,.T.,RGB(0,74,119),,nCliAreaWC,10)
	oSay:lTransparent := .T.
	
	oGet := tGet():New(nMargemComp+8,nMargemGr*10,{|u| if(PCount()>0,M->GX4_DTLIEN:=u,M->GX4_DTLIEN )},oGroup,nCliAreaWC,10,aCampo[7],,,,,,,.T.,,,,,,,lReadOnly,,,"M->"+aCampo[1],,,1,.T.)
	oGet:bWhen:= {||.F.}
	
	//Hora Início Carga/Descarga
	aCampo := oStructGX4:AFields[aScan(oStructGX4:AFields,{|x|x[1] == "GX4_HRLIEN"})]
	
	oSay := tSay():New(nMargemComp+nCliAreaH*3,nMargemGr*10,{||"Hora:"},oGroup,,oFont,,,,.T.,RGB(0,74,119),,nCliAreaWC,10)
	oSay:lTransparent := .T.
	
	oGet := tGet():New(nMargemComp+nCliAreaH*3+8,nMargemGr*10,{|u| if(PCount()>0,M->GX4_HRLIEN:=u,M->GX4_HRLIEN )},oGroup,nCliAreaWC-11,10,'@R 99:99',,,,,,,.T.,,,,,,,lReadOnly,,,"M->"+aCampo[1],,,1,.T.)
	oGet:bWhen:= {||.F.}
	
	// botão Informar Início Carga/Descarga
	
	oBtn4 := tButton():New(1.5*nMargemComp+nCliAreaH*6,nMargemGr*10,"Informar",oGroup,{||COMP519INF(oView,5,oBtn5)},nCliAreaWC,10,,oFont,,.T.,,,,{||COMP519NIVEL(.F.,4) .And. !lReadOnly})
	
	// -------------- Fim fim Carga/Descarga -------------------
	
	
	// "5.Saída Endereço"
	oGroup := tGroup():New(0,nCliAreaW*12 + nMargemComp ,nCliAltura,(nCliAreaW*15) ,"5.Saída Endereço",oPanDT,,CLR_GRAY,.T.)

	//Data Saída Endereço
	aCampo := oStructGX4:AFields[aScan(oStructGX4:AFields,{|x|x[1] == "GX4_DTSAEN"})]
	
	oSay := tSay():New(nMargemComp,nMargemGr*13,{||"Data:"},oGroup,,oFont,,,,.T.,RGB(0,74,119),,nCliAreaWC,10)
	oSay:lTransparent := .T.
	
	oGet := tGet():New(nMargemComp+8,nMargemGr*13,{|u| if(PCount()>0,M->GX4_DTSAEN:=u,M->GX4_DTSAEN )},oGroup,nCliAreaWC,10,aCampo[7],,,,,,,.T.,,,,,,,lReadOnly,,,"M->"+aCampo[1],,,1,.T.)
	oGet:bWhen:= {||.F.}
	
	//Hora Saída Endereço
	aCampo := oStructGX4:AFields[aScan(oStructGX4:AFields,{|x|x[1] == "GX4_HRSAEN"})]
	
	oSay := tSay():New(nMargemComp+nCliAreaH*3,nMargemGr*13,{||"Hora:"},oGroup,,oFont,,,,.T.,RGB(0,74,119),,nCliAreaWC,10)
	oSay:lTransparent := .T.
	
	oGet := tGet():New(nMargemComp+nCliAreaH*3+8,nMargemGr*13,{|u| if(PCount()>0,M->GX4_HRSAEN:=u,M->GX4_HRSAEN )},oGroup,nCliAreaWC-11,10,'@R 99:99',,,,,,,.T.,,,,,,,lReadOnly,,,"M->"+aCampo[1],,,1,.T.)
	oGet:bWhen:= {||.F.}
	
	// botão Informar Saída Endereço 
	
	oBtn5 := tButton():New(1.5*nMargemComp+nCliAreaH*6,nMargemGr*13,"Informar",oGroup,{||COMP519INF(oView,6,oBtn5)},nCliAreaWC,10,,oFont,,.T.,,,,{||COMP519NIVEL(.F.,5) .And. !lReadOnly})
	
	// -------------- Fim fim Carga/Descarga -------------------
	
	cInfEnd := Posicione("GVF",1,xFilial("GVF")+M->GX4_CDPTCT,"GVF_IDINEN")
	cInfDoc := GVF->GVF_IDVIDC
	If ValType(oViews) == "O" .And. Len(oViews:aFolders) > 0
		If cInfEnd != "1"
			oViews:aFolders[1][5]:HidePage(1)
		EndIf
		If cInfDoc != "1"
			oViews:aFolders[1][5]:HidePage(2)
		EndIf
	EndIf
Return .T.

//Retorna o label
Function COMP519SAY(cTabela,cCampo)
	Private _cCampo := cCampo
Return FWFormStruct(2,cTabela):AFields[aScan(FWFormStruct(2,cTabela):AFields,{|x|x[1] == _cCampo})][3]

//Retorna informação do campo, se o model estiver ativo e para variável de memória

Function COMP519GET(oView,cModel,cCampo)
	If oView:LACTIVATE
		Return oView:GetModel():GetValue(cModel,cCampo)
	Else
		Return &("M->" + cCampo)
	EndIF
Return
//Atribui informação do campo, se o model estiver ativo
Function COMP519SET(oView,cModel,cCampo,uValue,uTmp)
	Local uTmp2
	Default uTmp := &("M->" + cCampo)
	
	If cCampo == "GX4_HRSAI"
		uValue := Transform(uValue,'@R 99:99')	
	EndIf 

	If cCampo == "GX4_HRENTR"
		uValue := Transform(uValue,'@R 99:99')	
	EndIf 
	
	&("M->" + cCampo) := uValue	
	If oView:LACTIVATE .And. oView:GetModel():GetOperation() == MODEL_OPERATION_INSERT .Or. oView:GetModel():GetOperation() == MODEL_OPERATION_UPDATE
		If oView:GetModel():GetModel(cModel):LoadValue(cCampo,uValue)
			oView:GetModel():LMODIFY := .T.
			oView:LMODIFY := .T.
			uTmp2 := uValue
		Else
			oView:GetModel():GetModel(cModel):LoadValue(cCampo,uTmp)
			&("M->" + cCampo) := uTmp
			uTmp2 := uTmp
		EndIf
	EndIf
Return uTmp2

Function COMP519POSI(oView,acCampos,cTabela,cOrder,cCampoRet)
	Local cPesquisa := xFilial(cTabela)
	Local nX := 0
	Local cRetorno
	If oView:LACTIVATE
		For nX :=1 to Len(acCampos)
			cPesquisa += oView:GetModel():GetValue(acCampos[nX][1],acCampos[nX][2])
		Next nX
		dbSelectArea(cTabela)
		cRetorno:= Posicione(cTabela,cOrder,cPesquisa,cCampoRet)
	EndIf
Return cRetorno


Function COMP519NIVEL(lHelp,nNivelBtn,cCDPTCT, aArrPasso,cCdEnde)
	Local nNivel := 1
	Local nProxNivel := 1
	Local lErro := .F.
	Local nItemVazio := 0
	Local lIdAten := .F.
	Local lIdEnder := .F.
	   
	Default lHelp := .F.
	Default nNivelBtn := 0
	Default cCDPTCT := FwFldGet("GX4_CDPTCT")
	Default cCdEnde := FwFldGet("GX4_CDENDE")
	// Datas da chegada a saída
	Default aArrPasso := {;
		{M->GX4_DTENTR,StrTran(M->GX4_HRENTR,':','')},;
		{M->GX4_DTCHEN,StrTran(M->GX4_HRCHEN,':','')},;
		{M->GX4_DTINCA,StrTran(M->GX4_HRINCA,':','')},;
		{M->GX4_DTFICA,StrTran(M->GX4_HRFICA,':','')},;
		{M->GX4_DTLIEN,StrTran(M->GX4_HRLIEN,':','')},;
		{M->GX4_DTSAEN,StrTran(M->GX4_HRSAEN,':','')},;
		{M->GX4_DTSAI,StrTran(M->GX4_HRSAI,':','')};
		}
	dbSelectArea("GVF")
	dbSetOrder(1)
	
	If Empty(cCDPTCT) .Or. Empty(cCdEnde)
		Return If (nNivelBtn > 0,.F., 0)
	EndIf
	
	lIdEnder := Posicione("GVF",1,xFilial("GVF") + cCDPTCT,"GVF_IDINEN") == "1"
	If !lIdEnder
		Return If (nNivelBtn > 0,.F., 0)
	EndIf
	
	lIdAten := Posicione("GVF",1,xFilial("GVF") + cCDPTCT,"GVF_IDATEN") == "2"
	If lIdAten.And. nNivelBtn >1 .And. nNivelBtn<4
		Return .F.
	ElseIf lIdAten
		If !(Empty(aArrPasso[1][1]) .Or. Empty(aArrPasso[1][2]))
			If !(Empty(aArrPasso[2][1]) .Or. Empty(aArrPasso[2][2]))
				If DTOS(aArrPasso[2][1]) + aArrPasso[2][2] < DTOS(aArrPasso[1][1]) + aArrPasso[1][2]
					If lHelp
						Help(,,"HELP",,"Data/Hora da Entrada ("+DtoC(aArrPasso[1][1])+" "+Transform(aArrPasso[1][2],"@R 99:99")+") deve ser igual ou menor a Data/Hora da Chegada no Endereço ("+DtoC(aArrPasso[2][1])+" "+ Transform(aArrPasso[2][2],'@R 99:99')+").",1,0)
						Return -2
					Else
						Return .F.
					EndIf
				Else
					nProxNivel := 4
				EndIf
			Else
				nProxNivel := 1
				nItemVazio := 1
			EndIf
			If !(Empty(aArrPasso[5][1]) .Or. Empty(aArrPasso[5][2])) .And. nProxNivel > 2
				If DTOS(aArrPasso[5][1]) + aArrPasso[5][2] < DTOS(aArrPasso[2][1]) + aArrPasso[2][2]
					If lHelp
						Help(,,"HELP",,"Data/Hora da Chegada no Endereço ("+DtoC(aArrPasso[2][1])+" "+ Transform(aArrPasso[2][2],'@R 99:99')+") deve ser igual ou menor a Data/Hora da Liberação do Endereço ("+DtoC(aArrPasso[5][1])+" "+ Transform(aArrPasso[5][2],'@R 99:99')+")." ,1,0)
						Return -5
					Else
						Return .F.
					EndIf
				Else
					nProxNivel := 5
				EndIf
			Else
				If !(Empty(aArrPasso[5][1]) .Or. Empty(aArrPasso[5][2])) .And. nItemVazio > 0
					lErro := .T.
				ElseIf nItemVazio == 0
					nItemVazio := 4
				EndIf
				nProxNivel := nItemVazio
			EndIf
			If !(Empty(aArrPasso[6][1]) .Or. Empty(aArrPasso[6][2])) .And. nProxNivel > 4
				If DTOS(aArrPasso[6][1]) + aArrPasso[6][2] <= DTOS(aArrPasso[5][1]) + aArrPasso[5][2]
					If lHelp
						Help(,,"HELP",,"Data/Hora da Liberação do Endereço ("+DtoC(aArrPasso[5][1])+" "+ Transform(aArrPasso[5][2],'@R 99:99')+") deve ser igual ou menor que a Data/Hora da Saída do Endereço ("+DtoC(aArrPasso[6][1])+" "+ Transform(aArrPasso[6][2],'@R 99:99')+")." ,1,0)
						Return -6
					Else
						Return .F.
					EndIf
				Else
					nProxNivel := 6
				EndIf
			Else
				If !(Empty(aArrPasso[6][1]) .Or. Empty(aArrPasso[6][2])) .And. nItemVazio > 0
					lErro := .T.
				ElseIf nItemVazio == 0
					nItemVazio := 5
				EndIf
				nProxNivel := nItemVazio
			EndIf
			If !(Empty(aArrPasso[7][1]) .Or. Empty(aArrPasso[7][2])) .And. nProxNivel > 5
				If DTOS(aArrPasso[7][1]) + aArrPasso[7][2] < DTOS(aArrPasso[6][1]) + aArrPasso[6][2]
					If lHelp
						Help(,,"HELP",,"Data/Hora da Saída do Endereço ("+DtoC(aArrPasso[6][1])+" "+ Transform(aArrPasso[6][2],'@R 99:99')+") deve ser igual ou menor a Data/Hora da Saída ("+DtoC(aArrPasso[7][1])+" "+ Transform(aArrPasso[7][2],'@R 99:99')+").",1,0)
						Return -7
					Else
						Return .F.
					EndIf
				Else
					nProxNivel := 7
				EndIf
			Else
				If !(Empty(aArrPasso[7][1]) .Or. Empty(aArrPasso[7][2])) .And. nItemVazio > 0
					lErro := .T.
				ElseIf nItemVazio == 0
					nItemVazio := 6
				EndIf
				nProxNivel := nItemVazio
			EndIf
		EndIf
		
	Else
		For nNivel := 1 to Len(aArrPasso) -1
			If !(Empty(aArrPasso[nNivel][1]) .Or. Empty(aArrPasso[nNivel][2])) .And. nItemVazio == 0
				nProxNivel := nNivel
				If !(Empty(aArrPasso[nNivel+1][1]) .Or. Empty(aArrPasso[nNivel+1][2]))
					If DTOS(aArrPasso[nNivel+1][1]) + aArrPasso[nNivel+1][2] <= DTOS(aArrPasso[nNivel][1]) + aArrPasso[nNivel][2]
						lErro := .T.
						Exit
					Else
						nProxNivel++
						If nNivel+1 == 5
							nProxNivel++
						EndIf
					EndIf
				EndIf
			ElseIf nItemVazio > 0 .And. !(Empty(aArrPasso[nNivel][1]) .Or. Empty(aArrPasso[nNivel][2]))
				lErro := .T.
				Exit
			Else
				nItemVazio := nNivel
			EndIf
		Next nNivel
	EndIf
	If lErro
		nProxNivel *= -1
		If nProxNivel == 0
			nProxNivel := -1
		EndIf
		If lHelp
			Do Case
			Case nProxNivel == -1
				If nItemVazio > 0
					Help(,,"HELP",,"Data/Hora da Entrada devem estar preenchidos.",1,0)
				Else
					Help(,,"HELP",,"Data/Hora da Entrada ("+DtoC(aArrPasso[1][1])+" "+ Transform(aArrPasso[1][2],'@R 99:99')+") deve ser menor que a Data/Hora da Chegada no Endereço ("+DtoC(aArrPasso[2][1])+" "+ Transform(aArrPasso[2][2],'@R 99:99')+").",1,0)
				EndIf
			Case nProxNivel == -2
				If nItemVazio > 0
					Help(,,"HELP",,"Data/Hora da Chegada no Endereço devem estar preenchidos.",1,0)
				Else
					Help(,,"HELP",,"Data/Hora da Chegada no Endereço ("+DtoC(aArrPasso[2][1])+" "+ Transform(aArrPasso[2][2],'@R 99:99')+") deve ser menor que a Data/Hora do Início da Carga/Descarga ("+DtoC(aArrPasso[3][1])+" "+ Transform(aArrPasso[3][2],'@R 99:99')+").",1,0)
				EndIf
			Case nProxNivel == -3
				If nItemVazio > 0
					Help(,,"HELP",,"Data/Hora do Início da Carga/Descarga devem estar preenchidos.",1,0)
				Else
					Help(,,"HELP",,"Data/Hora do Início da Carga/Descarga ("+DtoC(aArrPasso[3][1])+" "+ Transform(aArrPasso[3][2],'@R 99:99')+") deve ser menor que a Data/Hora do Fim da Carga/Descarga ("+DtoC(aArrPasso[4][1])+" "+ Transform(aArrPasso[4][2],'@R 99:99')+").",1,0)
				EndIf
			Case nProxNivel == -4
				If nItemVazio > 0
					Help(,,"HELP",,"Data/Hora do Fim da Carga/Descarga devem estar preenchidos.",1,0)
				Else
					Help(,,"HELP",,"Data/Hora do Fim da Carga/Descarga ("+DtoC(aArrPasso[4][1])+" "+ Transform(aArrPasso[4][2],'@R 99:99')+") deve ser menor que a Data/Hora da Liberação do Endereço ("+DtoC(aArrPasso[5][1])+" "+ Transform(aArrPasso[5][2],'@R 99:99')+").",1,0)
				EndIf
			Case nProxNivel == -5
				If nItemVazio > 0
					Help(,,"HELP",,"Data/Hora da Liberação do Endereço devem estar preenchidos.",1,0)
				Else
					Help(,,"HELP",,"Data/Hora da Liberação do Endereço ("+DtoC(aArrPasso[5][1])+" "+ Transform(aArrPasso[5][2],'@R 99:99')+") deve ser menor que a Data/Hora da Saída do Endereço ("+DtoC(aArrPasso[6][1])+" "+ Transform(aArrPasso[6][2],'@R 99:99')+").",1,0)
				EndIf
			Case nProxNivel == -6
				If nItemVazio > 0
					Help(,,"HELP",,"Data/Hora da Saída do Endereço devem estar preenchidos.",1,0)
				Else
					Help(,,"HELP",,"Data/Hora da Saída do Endereço ("+DtoC(aArrPasso[6][1])+" "+ Transform(aArrPasso[6][2],'@R 99:99')+") deve ser menor que a Data/Hora da Saída " + DtoC(aArrPasso[7][1]) + " " + Transform(aArrPasso[7][2],'@R 99:99') ,1,0)
				EndIf
			EndCase
		EndIf
	EndIf
			
Return If (nNivelBtn > 0,nProxNivel >= nNivelBtn, nProxNivel)

Function COMP519INF(oView,nNivel,oBtn)
	GFEA519BDT(oView,nNivel)
Return

Function COMP519GRA(oView,cModel,cCampo1,cCampo2,lLimpa)
	Local uValor1 := &('M->' + cCampo1)
	Local uValor2 := &('M->' + cCampo2)
	Local lRet

	Default lLimpa := .F.
	
	If lLimpa
		&('M->' + cCampo1) := CtoD("  /  /    ")
		&('M->' + cCampo2) := "    "
	Else
		If Empty(uValor1)
			Help(,,"HELP",,"Informe a data.",1,0)
			Return .F.
		EndIf
		If Empty(uValor2)
			Help(,,"HELP",,"Informe a hora.",1,0)
			Return .F.
		EndIf
	EndIf
	
	lRet := If(COMP519NIVEL(.T.) >= 0,.T.,.F.)
	
	If lRet
		COMP519SET(oView, cModel, cCampo1, &('M->' + cCampo1),uValor1)
		COMP519SET(oView, cModel, cCampo2, &('M->' + cCampo2),uValor2)
	ElseIf lLimpa
		&('M->' + cCampo1) := uValor1
		&('M->' + cCampo2) := uValor2
	EndIf

Return lRet
/*
{Protheus.doc} GFEA519GXA
Função para validação da tabela GXA - Documentos de Carga dos Pontos de Controle do Registro de Movimentação

@sample
GFEA519GXA()

@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/
Function GFEA519GXA(oModelGXA)
	Local nI         := 0
	Local nLine      := oModelGXA:GetLine()
	Local nPesoIt    := 0
	Local nVolIt     := 0
	Local nCrgUtVeic := 0
	Local nVolUtVeic := 0
	Local cTpDc			:= oModelGXA:GetValue("GXA_CDTPDC")
	Local cEmiDc	  	:= oModelGXA:GetValue("GXA_EMISDC")
	Local cSerDc	  	:= oModelGXA:GetValue("GXA_SERDC")
	Local cNrDc	  		:= oModelGXA:GetValue("GXA_NRDC")
	Local cChave     	:= cTpDc + cEmiDc + cSerDc + cNrDc
	Local aAreaGXA   := GXA->(GetArea())
	Local aAreaGX3   := GX3->(GetArea())
	Local cNrMov     := oModelGXA:GetValue("GXA_FILIAL") + oModelGXA:GetValue("GXA_NRMOV")
	Local lRoman		:= SuperGetMv("MV_GFEPP04",.F.,.T.)	// Permite vincular documentos de carga que não pertencem ao mesmo romaneio
	Local cNrRom		:= ""
	Local cChvTmp		:= ""

	GXA->( dbSetOrder(2) )
	GX3->( dbSetOrder(1) )

	If GXA->(dbSeek(xFilial("GXA")+cChave))
		While !GXA->(Eof()) .And. xFilial("GXA")+cChave == GXA->(GXA_FILIAL+GXA_CDTPDC+GXA_EMISDC+GXA_SERDC+GXA_NRDC) .And. GX3->(dbSeek(GXA->(GXA_FILIAL+GXA_NRMOV)))
			If GX3->GX3_SIT != "5" .And. cNrMov != GX3->(GX3_FILIAL+GX3_NRMOV)
				Help( ,, 'HELP',, "Documento de carga já esta vinculado a outra movimentação", 1, 0)
				RestArea(aAreaGXA)
				RestArea(aAreaGX3)
				Return .F.
			EndIf
			GXA->(dbSkip())
		EndDo
	EndIf
	RestArea(aAreaGXA)
	RestArea(aAreaGX3)

GW1->(dbSetOrder(1))
If !GW1->(dbSeek(xFilial("GW1")+cChave))
		Help( ,, 'HELP',, "Documento de Carga não existe.", 1, 0) //"Série do Documento de Carga não existe"
		Return .F.
	Else
		If Empty(GW1->GW1_NRROM)
			Help( ,, 'HELP',, "Documento de Carga não está vinculado a um romaneio.", 1, 0) //"Documento de Carga não está vinculado a um romaneio"
			Return .F.
		Else
		GWN->(  dbSetOrder(1) )
			If GWN->( dbSeek(xFilial("GWN")+GW1->GW1_NRROM) )
				cNrRom := GW1->GW1_NRROM
				If !(GWN->GWN_SIT $ '3;4')
					Help( ,, 'HELP',, "Documento de carga deve estar vinculado a um romaneio que esteja 'Liberado' ou 'Encerrado'.", 1, 0) //"Documento de carga deve estar vinculado a um romaneio que esteja 'Liberado' ou 'Embarcado'"
					Return .F.
				Endif
			Else
				Help( ,, 'HELP',, "Romaneio do documento de carga não existe.", 1, 0)
				Return .F.
			Endif
		Endif
	EndIf


	For nI := 1 To oModelGXA:Length()
		oModelGXA:GoLine( nI )
	
		cChvTmp := FwFldGet("GXA_CDTPDC", nI) + FwFldGet("GXA_EMISDC", nI) + FwFldGet("GXA_SERDC", nI) + FwFldGet("GXA_NRDC", nI)
		If !oModelGXA:IsDeleted() .And. nI != nLine
		
			If !lRoman .And. GW1->(dbSeek(xFilial("GW1")+cChvTmp)) .And.  cNrRom != GW1->GW1_NRROM
				Help( ,, 'HELP',, "Não pode ser vinculado mais de um romaneio nos documentos de carga.", 1, 0)
				Return .F.
			EndIf
		
			If cChvTmp == cChave
				oModelGXA:GoLine( nLine )
				Help( ,, 'HELP',, STR0013 + AllTrim(Str(nI)) + ".", 1, 0) //"O documento de carga já foi informado na linha "
				Return .F.
			EndIf
		
		EndIf
							
	Next nI

	For nI := 1 To oModelGXA:Length()
		oModelGXA:GoLine( nI )

		If !oModelGXA:IsDeleted()
			GW8->( dbSetOrder(1) )
			GW8->( dbSeek(xFilial("GW8") + cTpDc + cEmiDc + cSerDc + cNrDc) )
					  
			While !GW8->( Eof() ) .And. GW8->GW8_FILIAL == xFilial("GW8") .And. GW8->GW8_CDTPDC == cTpDc .And. ;
					GW8->GW8_EMISDC == cEmiDc .And. GW8->GW8_SERDC == cSerDc .And. GW8->GW8_NRDC == cNrDc
			  
				nPesoIt += GW8->GW8_PESOR
				nVolIt  += GW8->GW8_VOLUME
			
				GW8->( dbSkip() )
			EndDo
		EndIf
	Next nI

	oModelGXA:GoLine( nLine )

	GX3->( dbSetOrder(1) )
	If GX3->( dbSeek( xFilial("GX3") + FwFldGet("GX4_NRMOV") ) )
		GX6->( dbSetOrder(1) )
		GX6->( dbSeek(xFilial("GX6")+GX3->GX3_NRMOV) )
		While !GX6->( Eof() ) .And. xFilial("GX6") == GX6->GX6_FILIAL .And. GX6->GX6_NRMOV == GX3->GX3_NRMOV
			GU8->( dbSetOrder(1) )
			If GU8->( dbSeek(xFilial("GU8")+GX6->GX6_CDVEIC) )

				nCrgUtVeic += GU8->GU8_CARGUT
				nVolUtVeic += GU8->GU8_VOLUT
			
			EndIf
		
			GX6->( dbSkip() )
		EndDo
	EndIf

	If nPesoIt > nCrgUtVeic
		oModelGXA:GoLine( nLine )
		Help( ,, 'HELP',, STR0008 + AllTrim(Str(nPesoIt)) + STR0009 + AllTrim(Str(nCrgUtVeic)), 1, 0) //"O peso dos itens somados ultrapassou a capacidade dos veículos informados. Peso Itens: " ### " Carga Útil Veículo : "
		Return .F.
	ElseIf nVolIt > nVolUtVeic
		oModelGXA:GoLine( nLine )
		Help( ,, 'HELP',, STR0010 + AllTrim(Str(nVolIt)) + STR0011 + AllTrim(Str(nVolUtVeic)), 1, 0) //"O volume dos itens somados ultrapassou a capacidade dos veículos informados. Volume Itens: " ### " Volume Útil Veículo : "
		Return .F.
	EndIf
	
Return .T.

/*
{Protheus.doc} GFEA519BAC
Função chamada ao ativar o Model

@sample
GFEA519BAC(oModel)

@author Octávio Augusto Felippe de Macedo
@since 28/04/2011
@version 1.0
*/

Function GFEA519BAC(oModel)
	Local oModelGX4 := oModel:GetModel("GFEA519B_GX4")
	Local oModelGX5 := oModel:GetModel("GFE519BGX5")
	Local oModelGXA := oModel:GetModel("GFE519BGXA")
	Local nLine     := oModelGXA:GetLine()
	Local nCont
	
	
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oModel:GetModel("GFEA519B_GX4"):SetValue("GX4_USUENT", cUserName)
	EndIf
	
	oModel:lModify := .F.
	
	_lNEnd := Empty(GX4->GX4_DTCHEN) .Or. Empty(GX4->GX4_HRCHEN)
	_lNLib := Empty(GX4->GX4_DTLIEN) .Or. Empty(GX4->GX4_HRLIEN)
	
	aDC := {}
	
	If Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDVIDC") == "2"
		For nCont := 1 To oModelGXA:Length()
			oModelGXA:GoLine(nCont)
			If !Empty(oModelGXA:GetValue("GXA_NRDC"))
				GWV->( dbSetOrder(4) )
				GWV->( dbSeek(xFilial("GWV") + GX4->GX4_NRMOV) )
				While !GWV->( Eof() ) .And. GWV->GWV_FILIAL == xFilial("GWV") .And. GWV->GWV_NRMOV == GX4->GX4_NRMOV
					
					GWW->( dbSetOrder(1) )
					If GWW->( dbSeek(xFilial("GWW") + GWV->GWV_NRAGEN + oModelGXA:GetValue("GXA_CDTPDC") + oModelGXA:GetValue("GXA_EMISDC") + oModelGXA:GetValue("GXA_SERDC") + oModelGXA:GetValue("GXA_NRDC")) )
						AAdd(aDC, {oModelGXA:GetValue("GXA_CDTPDC"), oModelGXA:GetValue("GXA_EMISDC"), oModelGXA:GetValue("GXA_SERDC"), oModelGXA:GetValue("GXA_NRDC")})
						Exit
					EndIf
					
					GWV->( dbSkip() )
				EndDo
				
			EndIf
		Next nCont
		
		oModelGXA:GoLine(nLine)
	EndIf
	
	oModelGX5:SetNoInsertLine(.T.)
	oModelGX5:SetNoDeleteLine(.T.)
	
	If oModelGX5:IsEmpty()
		oModelGX5:SetNoUpdateLine(.T.)
	EndIf
	
	// Valida GX4_VLTARA verificando se campo GVF_IDTARA
	// 1=Não informar						Não permitir a edição do campo.
	// 2=Informada 						Deve ser informado pelo usuário.
	// 3=Veículo ou Tipo de Veículo		Não permitira edição do campo, mas atribuir ao mesmo o valor da tara do veículo 
	//			(GU8) preferencialmente, ou do tipo de veículo (GV3), do primeiro veículo da movimentação corrente (GX6)
	If GX4->GX4_VLTARA == 0
		GVF->( dbSetOrder(1) )
		If GVF->( dbSeek(xFilial("GVF") + GX4->GX4_CDPTCT ) )
			
			// Busca Valor TARA
			If GVF->GVF_IDTARA == "3"
				dbSelectArea("GX6")
				GX6->( dbSetOrder(1) )
				GX6->( dbSeek(xFilial("GX6")+GX4->GX4_NRMOV) )
				While !GX6->( Eof() )
					If xFilial("GX6") == GX6->GX6_FILIAL .And. GX6->GX6_NRMOV == GX4->GX4_NRMOV
						// GU8 - Veiculos
						dbSelectArea("GU8")
						GU8->( dbSetOrder(1) )
						If GU8->( dbSeek(xFilial("GU8")+GX6->GX6_CDVEIC) )
						
							If GU8->GU8_TARA == 0
								// GV3 - Tipos de Veiculos
								dbSelectArea("GV3")
								GV3->( dbSetOrder(1) )
								If GV3->( dbSeek(xFilial("GV3")+GU8->GU8_CDTPVC) )
									oModelGX4:LoadValue("GX4_VLTARA", GV3->GV3_TARA)
								EndIf
							Else
								oModelGX4:LoadValue("GX4_VLTARA", GU8->GU8_TARA)
							EndIf
							
						EndIf
					EndIf
		
					GX6->( dbSkip() )
				EndDo
			EndIf
		EndIf
	EndIf
	
Return

Static Function A519PESOT(cCampo)
	Local nRet		:= 0
	Local cMov		:= GX4->GX4_FILIAL+GX4->GX4_NRMOV
	Local cSeq		:= GX4->GX4_SEQ
	Local aAreaGX4, aAreaGXA
	Local nI, nLine, oModel, oModelGXA
	
	Default cCampo := "GX4_QTPESO"
	
	If cCampo $ "DOC_CARGA;UNITIZADORES;AGENDAMENTO"
		
		If cCampo == "DOC_CARGA"
			oModel 	:= FWModelActive()
			If !Empty(oModel) .And. oModel:lActivate .And. oModel:GetModel("GFE519BGXA"):GetLine() > 0
				oModelGXA 	:= oModel:GetModel("GFE519BGXA")
				nLine 		:= oModelGXA:GetLine()
				
				// Busca no ponto atual
				For nI := 1 To oModelGXA:Length()
					oModelGXA:GoLine( nI )
				
					If !oModelGXA:IsDeleted()
						dbSelectArea("GW8")
						GW8->( dbSetOrder(1) )
						GW8->( dbSeek(xFilial("GW8") + oModelGXA:GetValue("GXA_CDTPDC") + oModelGXA:GetValue("GXA_EMISDC") + ;
							oModelGXA:GetValue("GXA_SERDC") + oModelGXA:GetValue("GXA_NRDC")) )
									  
						While !GW8->( Eof() ) .And. GW8->GW8_FILIAL == xFilial("GW8") .And. GW8->GW8_CDTPDC == oModelGXA:GetValue("GXA_CDTPDC") .And. ;
								GW8->GW8_EMISDC == oModelGXA:GetValue("GXA_EMISDC") .And. GW8->GW8_SERDC == oModelGXA:GetValue("GXA_SERDC") .And. ;
								GW8->GW8_NRDC == oModelGXA:GetValue("GXA_NRDC")
							  
							nRet += GW8->GW8_PESOR
							
							dbSelectArea("GW8")
							GW8->( dbSkip() )
						EndDo
					EndIf
				Next nI
				oModelGXA:GoLine( nLine )
			EndIf
			// Busca nos pontos anteriores
			If nRet == 0
				aAreaGX4 := GX4->(GetArea())
				
				GX4->(dbSetOrder(4))
				
				dbSelectArea("GXA")
				
				aAreaGXA := GXA->(GetArea())
				
				GXA->( dbSetOrder(1))
				
				If GX4->(dbSeek(cMov+cSeq))
					If !Empty(oModel) .And. oModel:lActivate // Se estiver ativo o model, ignora o ponto atual
						GX4->(dbSkip(-1))
					EndIf
					
					While !GX4->(Bof()) .And. cMov == GX4->GX4_FILIAL+GX4->GX4_NRMOV
						
						If GXA->(dbSeek(GX4->GX4_FILIAL + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ))
							While GXA->( !Eof() ) .And. GXA->GXA_FILIAL == GX4->GX4_FILIAL .And. ;
									GXA->GXA_NRMOV == GX4->GX4_NRMOV .And. ;
									GXA->GXA_CDPTCT == GX4->GX4_CDPTCT .And. ;
									GXA->GXA_SEQ == GX4->GX4_SEQ
									
								dbSelectArea("GW8")
								GW8->( dbSetOrder(1) )
								GW8->( dbSeek(xFilial("GW8") + GXA->GXA_CDTPDC + GXA->GXA_EMISDC + GXA->GXA_SERDC + GXA->GXA_NRDC) )
											  
								While !GW8->( Eof() ) .And. GW8->GW8_FILIAL == xFilial("GW8") .And. GW8->GW8_CDTPDC == GXA->GXA_CDTPDC .And. ;
										GW8->GW8_EMISDC == GXA->GXA_EMISDC .And. GW8->GW8_SERDC == GXA->GXA_SERDC .And. ;
										GW8->GW8_NRDC == GXA->GXA_NRDC
									nRet += GW8->GW8_PESOR
									GW8->( dbSkip() )
								EndDo
								
								GXA->(dbSkip())
							EndDo
						EndIf
						
						GX4->(dbSkip(-1))
					EndDo
				EndIf
				
				RestArea(aAreaGXA)
				RestArea(aAreaGX4)
			EndIf
		ElseIf cCampo == "UNITIZADORES"
			dbSelectArea("GX9")
			GX9->(dbSetOrder(1))
			If GX9->(dbSeek(GX4->GX4_FILIAL+GX4->GX4_NRMOV))
				While GX9->(!Eof()) .And. GX9->GX9_FILIAL == GX4->GX4_FILIAL .And. GX9->GX9_NRMOV == GX4->GX4_NRMOV
					nRet += GX9->GX9_QTD * Posicione("GUG",1,xFilial("GUG")+GX9->GX9_CDUNIT,"GUG_TARA")
					GX9->(dbSkip())
				EndDo
			EndIf
		ElseIf cCampo == "AGENDAMENTO"
			dbSelectArea("GWV")
			GWV->(dbSetOrder(4))
			If GWV->(dbSeek(GX4->GX4_FILIAL+GX4->GX4_NRMOV))
				While GWV->(!Eof()) .And. GWV->GWV_FILIAL == GX4->GX4_FILIAL .And. GWV->GWV_NRMOV == GX4->GX4_NRMOV
					nRet += Val(GWV->GWV_PESOR)
					GWV->(dbSkip())
				EndDo
			EndIf
		EndIf
	Else
		oModel	:= FWModelActive()
		
		If !Empty(oModel) .And. oModel:lActivate
			nRet := FWFldGet(cCampo)
		Else
			nRet := &("GX4->"+cCampo)
		EndIf
		
		If nRet == 0 .And. Val(GX4->GX4_SEQ) > 1
			aAreaGX4 := GX4->(GetArea())
				
			GX4->(dbSetOrder(4))
			
			If GX4->(dbSeek(cMov+cSeq))
				GX4->(dbSkip(-1))
				
				While !GX4->(Bof()) .And. cMov == GX4->GX4_FILIAL+GX4->GX4_NRMOV
					nRet := &("GX4->"+cCampo)
					
					If nRet > 0
						Exit
					EndIf
					
					GX4->(dbSkip(-1))
				EndDo
			EndIf
			
			RestArea(aAreaGX4)
		EndIf
	EndIf
	If nRet == Nil
		nRet := 0
	EndIf
Return nRet


/*
{Protheus.doc} GFEA519BPO
Função de validação ao confirmar o Model

@sample
GFEA519BPO(oModel)

@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/

Function GFEA519BPO(oModel)
	Local oModelGXA := oModel:GetModel("GFE519BGXA")
	Local oModelGX5 := oModel:GetModel("GFE519BGX5")
	Local nLine     := oModelGXA:GetLine()
	Local nI        := 0
	Local nPesoIt   := 0
	Local lAprov    := .T.
	Local nPeso
	Local nMinNeg
	Local nMinPos
	Local nMinDiff
	Local nTmDiff
	Local nCont     := 0
	Local cSitAnt   := GX4->GX4_SIT
	Local lSaida
	Local lEEnd
	Local lSEnd
	Local lLEnd
	Local aAreaGX4
	Local nDC
	Local nX
	Local lFDC      	:= .F.
	Local nPBT		  	:= 0
	Local nTara		:= 0
	Local nPesoLiq	:= 0
	Local nPerTolPBT 	:= SuperGetMv("MV_GFEPP01",.F.,000)	// % Tolerancia PBT
	Local nPerTolPMin	:= SuperGetMv("MV_GFEPP02",.F.,000)	// % Tolerancia Peso Minimo Doc Carga
	Local nPerTolPMax	:= SuperGetMv("MV_GFEPP03",.F.,000)	// % Tolerancia Peso Maximo Doc Carga	
	Local aAreaGX4 := GX4->(GetArea())
	Local aAreaGXA
	Local cElapTime
	Local cRetAct

	dbSelectArea("GVF")
	GVF->( dbSetOrder(1) )
	GVF->( dbSeek(xFilial("GVF") + GX4->GX4_CDPTCT) )
	If !Empty(FwFldGet("GX4_CDENDE")) .And. Empty(FwFldGet("GX4_PRIORI")) .And. GVF->GVF_IDINEN == "1"
		Help(,,'HELP',,"O campo prioridade deve ser informado",1,0)
		Return .F.
	EndIf
	
	If !Empty(aDC) .And. Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDVIDC") == "2"
		For nX := 1 To Len(aDC)
			For nDC := 1 To oModelGXA:Length()
				oModelGXA:GoLine(nDC)
				
				If !oModelGXA:IsDeleted() .And. oModelGXA:GetValue("GXA_CDTPDC") == aDC[nX][1] .And. oModelGXA:GetValue("GXA_EMISDC") == aDC[nX][2] .And. ;
						oModelGXA:GetValue("GXA_SERDC") == aDC[nX][3] .And. oModelGXA:GetValue("GXA_NRDC") == aDC[nX][4]
					lFDC := .T.
					Exit
				EndIf
			Next nDC
			
			If lFDC
				lFDC := .F.
			Else
				Help( ,, 'HELP',, STR0067 + AllTrim(aDc[nX][1]) + ", " + STR0068 + " : " + AllTrim(aDc[nX][2]) + ", " + STR0069 + " : " + AllTrim(aDc[nX][3]) + ", " + STR0070 + " : " + AllTrim(aDc[nX][4]) + STR0071, 1, 0) //"O Documento de Carga de Tp. de DC : " ### "Emitente" ### "Série" ### "Nº Dc" ### " deve estar relacionado ao Ponto de Controle."
				oModelGXA:GoLine(nLine)
				Return .F.
			EndIf
		Next nX
		
		oModelGXA:GoLine(nLine)
	EndIf
	
	oModelGXA:GoLine(nLine)
	
	If GX4->GX4_SIT == "1" .And. !Empty(FwFldGet("GX4_DTSAI")) .And. !Empty(FwFldGet("GX4_HRSAI")) .AND. !(IsInCallStack("GFEA523"))
		Help( ,, 'HELP',, STR0072, 1, 0) //"A Data e Hora de saída não devem ser informadas na primeira movimentação do Ponto de Controle."
		Return .F.
	EndIf
	
	If (!Empty(FwFldGet("GX4_DTSAI")) .And. !Empty(FwFldGet("GX4_HRSAI"))) 
		If (!(IsInCallStack("GFEA523")) .And. FwFldGet("GX5_RESPOS") == "0")
			Help( ,, 'HELP',, "Check-List pendente de resposta.", 1, 0) 
			Return .F.
		EndIf
	EndIf
	//--------------Verificação do Atraso/Antecipação do Agendamento
	dbSelectArea("GX3")
	GX3->( dbSetOrder(1) )
	If GX3->( dbSeek(xFilial("GX3") + GX4->GX4_NRMOV) )
		
		dbSelectArea("GVI")
		GVI->( dbSetOrder(1) )
		If GVI->( dbSeek(xFilial("GVI") + GX3->GX3_CDOPER + GX3->GX3_SEQ) )
			
			If GVI->GVI_IDCOAG == "1"
			
				nMinNeg := GVI->GVI_QTHRPO //Tolerancia atraso
				nMinPos := GVI->GVI_QTHRNE //Tolerancia adiantado
			    
				If Val(GX4->GX4_SEQ) == 1 //Caso seja o primeiro ponto de controle deve comparar atraso/antecedência com o agendamento.
				
					dbSelectArea("GWV")
					GWV->( dbSetOrder(4) )
					GWV->( dbSeek(xFilial("GWV") + GX3->GX3_NRMOV) )
					While !GWV->( Eof() ) .And. GWV->GWV_FILIAL == xFilial("GWV") .And. GWV->GWV_NRMOV == GX3->GX3_NRMOV
						
						If Val(GWV->GWV_HRAGEN) < Val(FwFldGet("GX4_HRENTR"))
							cElapTime := ElapTime(AllTrim(GWV->GWV_HRAGEN)+":00",AllTrim(FwFldGet("GX4_HRENTR"))+":00")
						Else
							cElapTime := ElapTime(AllTrim(FwFldGet("GX4_HRENTR"))+":00",AllTrim(GWV->GWV_HRAGEN)+":00")
						EndIf
							
						nTmDiff := (Val(SubStr(cElapTime,1,2))*60) + Val(SubStr(cElapTime,4,2))
						
						If ( DTOS(GWV->GWV_DTAGEN) == DTOS(FwFldGet("GX4_DTENTR")) .And. Val(GWV->GWV_HRAGEN) < Val(FwFldGet("GX4_HRENTR")) ) .Or. ;
								DTOS(GWV->GWV_DTAGEN) < DTOS(FwFldGet("GX4_DTENTR")) //Atrasado
							
							nMinDiff := ( ((FwFldGet("GX4_DTENTR") - GWV->GWV_DTAGEN) * 24) * 60 ) + nTmDiff
							
							If nMinDiff > nMinNeg
								lAprov := .F.
							EndIf
							
							aValid[1][1] := If(lAprov,STR0054,STR0055) //"S" ### "N"
							aValid[1][2] := AllTrim(Str(nMinNeg))
							aValid[1][3] := AllTrim(Str(nMinDiff))
							
							If !lAprov
								Exit
							EndIf
							 
						ElseIf ( DTOS(GWV->GWV_DTAGEN) == DTOS(FwFldGet("GX4_DTENTR")) .And. Val(GWV->GWV_HRAGEN) > Val(FwFldGet("GX4_HRENTR")) ) .Or. ;
								DTOS(GWV->GWV_DTAGEN) > DTOS(FwFldGet("GX4_DTENTR"))//Adiantado
							
							nMinDiff := ( ((GWV->GWV_DTAGEN - FwFldGet("GX4_DTENTR")) * 24) * 60 ) + nTmDiff
							
							If nMinDiff > nMinPos
								lAprov := .F.
							EndIf
							
							aValid[2][1] := If(lAprov,STR0054,STR0055) //"S" ### "N"
							aValid[2][2] := AllTrim(Str(nMinPos))
							aValid[2][3] := AllTrim(Str(nMinDiff))
							
							If !lAprov
								Exit
							EndIf
							
						EndIf
						
						dbSelectArea("GWV")
						GWV->( dbSkip() )
					EndDo
					
				EndIf
			EndIf
		EndIf
		
	EndIf

	//--------------Verificação do Peso
	
	If lAprov
		
		//
		// VALIDAÇÃO PESO
		//
		dbSelectArea("GVF")
		GVF->( dbSetOrder(1) )
		If GVF->( dbSeek(xFilial("GVF") + GX4->GX4_CDPTCT) ) .And. GVF->GVF_IDVLPE $ "2;3;4;5;6" // GVF_IDVLPE=1 Não validar
			// Sobre o Peso e a Tara: essas informações podem ser digitadas em diferentes pontos da movimentação, 
			// portanto caso esteja zerada no ponto corrente, vai tentando buscar nos anteriores, para que possa fazer a validação 
			// contra peso/tara de outros pontos
			nPeso		:= A519PESOT("GX4_QTPESO")
			nTara		:= A519PESOT("GX4_VLTARA")
			
			nPesoLiq	:= nPeso - nTara
			
			If GVF->GVF_IDPELI == "2" // Campo que informa como é considerado o peso líquido neste ponto de controle. 1=Peso-Tara;2=Peso-Tara-Unitizadores
				nPesoLiq -= A519PESOT("UNITIZADORES")
			EndIf
			
			// 2=PBT, 4=PBT e Doc Carga, 6=PBT e Peso agend
			If GVF->GVF_IDVLPE $ "2;4;6"
				nPBT 		:= GFEA519BVA(GX4->GX4_FILIAL,GX4->GX4_NRMOV)
				
				// (peso informado deve ser até PBT do veículo ou  tipo de veículo)  + % de Tolerância (MV_GFEPP01)
				If nPeso > (nPBT + (nPBT * nPerTolPBT / 100))
					lAprov := .F.
				EndIf
										
				aValid[3][1] := If((nPeso > (nPBT + (nPBT * nPerTolPBT / 100))),STR0055,STR0054) //"N"##"S"
				aValid[3][2] := AllTrim(Str((nPBT + (nPBT * nPerTolPBT / 100))))
				aValid[3][3] := AllTrim(Str(nPeso))
			EndIf
			
			// 3=Doc Carga, 4=PBT e Doc Carga
			If GVF->GVF_IDVLPE $ "3;4"
				nPesoIt := A519PESOT("DOC_CARGA")
				// Só valida peso de Doc Carga se for maior que zero
				If nPesoIt > 0
					// Peso Carga = (Peso Informado - TARA Caminhao)
					// (Peso Carga - % Peso Mínimo)  <= Soma Peso Documentos de Carga
					// Soma Peso Documentos de Carga <= (Peso Carga + % Peso Máximo)
					
					// Peso mínimo doc carga
					If nPesoIt < nPesoLiq - ((nPesoLiq * nPerTolPMin) / 100 )
						lAprov := .F.
					EndIf
					
					aValid[4][1] := If((nPesoIt < nPesoLiq - ((nPesoLiq * nPerTolPMin) / 100 )),STR0055,STR0054)//"N"##"S"
					aValid[4][2] := AllTrim(Str((nPesoLiq - ((nPesoLiq * nPerTolPMin) / 100 ))))
					aValid[4][3] := AllTrim(Str(nPesoIt))
					
					// Peso máximo doc carga
					If nPesoIt > nPesoLiq + ( (nPesoLiq * nPerTolPMax) / 100 )
						lAprov := .F.
					EndIf
					
					aValid[5][1] := If((nPesoIt > nPesoLiq + ( (nPesoLiq * nPerTolPMax) / 100 )),STR0055,STR0054)//"N"###"S"
					aValid[5][2] := AllTrim(Str((nPesoLiq + ( (nPesoLiq * nPerTolPMax) / 100 ))))
					aValid[5][3] := AllTrim(Str(nPesoIt))
				EndIf
			EndIf
			
			//5=Peso Agendamento
			If GVF->GVF_IDVLPE $ "5;6"
				nPesoAgend := A519PESOT("AGENDAMENTO")
				
				// Tolerância peso mínimo x peso agendamento
				If nPesoLiq < nPesoAgend - ((nPesoAgend * nPerTolPMin) / 100)
					lAprov := .F.
				EndIf
				
//				aValid[8][1] := If((nPesoAgend < nPesoLiq - ((nPesoLiq * nPerTolPMin) / 100 )),STR0055,STR0054)//"N"##"S"
//				aValid[8][2] := AllTrim(Str((nPesoLiq - ((nPesoLiq * nPerTolPMin) / 100 ))))
//				aValid[8][3] := AllTrim(Str(nPesoAgend))
				
				aValid[8][1] := If((nPesoLiq < nPesoAgend - ((nPesoAgend * nPerTolPMin) / 100 )),STR0055,STR0054)//"N"##"S"
				aValid[8][2] := AllTrim(Str((nPesoAgend - ((nPesoAgend * nPerTolPMin) / 100 ))))
				aValid[8][3] := AllTrim(Str(nPesoLiq))
				
				// Tolerância peso máximo x peso agendamento
				If nPesoLiq > nPesoAgend + ((nPesoAgend * nPerTolPMax) / 100)
					lAprov := .F.
				EndIf
				
				//aValid[9][1] := If((nPesoAgend > nPesoLiq + ( (nPesoLiq * nPerTolPMax) / 100 )),STR0055,STR0054)//"N"###"S"
				//aValid[9][2] := AllTrim(Str((nPesoLiq + ( (nPesoLiq * nPerTolPMax) / 100 ))))
				//aValid[9][3] := AllTrim(Str(nPesoAgend))
				aValid[9][1] := If((nPesoLiq > nPesoAgend + ( (nPesoAgend * nPerTolPMax) / 100 )),STR0055,STR0054)//"N"###"S"
				aValid[9][2] := AllTrim(Str((nPesoAgend + ( (nPesoAgend * nPerTolPMax) / 100 ))))
				aValid[9][3] := AllTrim(Str(nPesoLiq))
			EndIf
		EndIf
	EndIf
	
	//--------------Verificação das quantidades de documento de carga
	
	If lAprov
	   
		dbSelectArea("GX3")
		GX3->( dbSetOrder(1) )
		
		If GX3->( dbSeek(xFilial("GX3") + GX4->GX4_NRMOV) )
			
			dbSelectArea("GVI")
			GVI->( dbSetOrder(1) )
			
			If GVI->( dbSeek(xFilial("GVI") + GX3->GX3_CDOPER + GX3->GX3_SEQ) )
			
				If GVI->GVI_IDBLQT == "1" // Se pela configuração da operação bloqueia
					
					dbSelectArea("GVF")
					GVF->( dbSetOrder(1) )
					nCont := 0
					If GVF->( dbSeek(xFilial("GVF") + GX4->GX4_CDPTCT) ) .And. GVF->GVF_IDQTDC == "1"
						// Valida quantidade conforme ponto atual 
						For nI := 1 To oModelGXA:Length()
							oModelGXA:GoLine(nI)
							If !oModelGXA:IsDeleted() .And. !Empty(oModelGXA:GetValue("GXA_NRDC"))
								nCont++
							EndIf
						Next nI
						
						oModelGXA:GoLine(nLine)
						
						If nCont > 0
							If nCont != FwFldGet("GX4_QTDC")
								lAprov := .F.
							EndIf
						    
							aValid[7][1] := If(lAprov,STR0054,STR0055) //"S" ### "N"
							aValid[7][2] := AllTrim(Str(nCont))
							aValid[7][3] := AllTrim(Str(FwFldGet("GX4_QTDC")))
						Else
							// Se não foram informados documentos no ponto de controle corrente, validar com os documentos dos pontos anteriores
							nSeq 		:= Val(FwFldGet("GX4_SEQ"))
							cMovAtual 	:= FwFldGet("GX4_FILIAL")+FwFldGet("GX4_NRMOV")+FwFldGet("GX4_SEQ")
							
							If nSeq > 1
								// Se não informa documentos neste ponto de controle, validar com os documentos dos pontos anteriores
								dbSelectArea("GX4")
								dbSelectArea("GXA")
								
								aAreaGX4 := GX4->(GetArea())
								aAreaGXA := GXA->(GetArea())
								
								GX4->(dbSetOrder(4))
								GXA->(dbSetOrder(1))
								
								If GX4->(dbSeek(cMovAtual))
									While nSeq > 1
										If GXA->(dbSeek(GX4->GX4_FILIAL + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ))
											While GXA->(!Eof()) .And. ;
													GXA->GXA_FILIAL == GX4->GX4_FILIAL .And. ;
													GXA->GXA_NRMOV == GX4->GX4_NRMOV .And. ;
													GXA->GXA_CDPTCT == GX4->GX4_CDPTCT .And. ;
													GXA->GXA_SEQ == GX4->GX4_SEQ
												nCont++
												GXA->(dbSkip())
											EndDo
											
											Exit
										EndIf
										
										GX4->(dbSkip(-1))
										nSeq--
									EndDo
								EndIf
								
								RestArea(aAreaGX4)
								RestArea(aAreaGXA)
								
								If nCont != FwFldGet("GX4_QTDC")
									lAprov := .F.
								EndIf
								
								aValid[7][1] := If(lAprov,STR0054,STR0055) //"S" ### "N"
								aValid[7][2] := AllTrim(Str(nCont))
								aValid[7][3] := AllTrim(Str(FwFldGet("GX4_QTDC")))
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	//------------Verificação das perguntas
	If lAprov
		For nI := 1 To oModelGX5:Length()
			oModelGX5:GoLine(nI)
			
			If oModelGX5:GetValue("GX5_RESPOS") == "2" .And. Posicione("GVH",2,xFilial("GVH") + FwFldGet("GX4_CDPTCT") + oModelGX5:GetValue("GX5_CDPERG"),"GVH_IDIMPE") == "1"
				lAprov := .F.
			EndIf
		Next nI
	EndIf
	//-------------------------------------
	
	lSaida := !Empty(FwFldGet("GX4_DTSAI") ) .And. !Empty(FwFldGet("GX4_HRSAI") )
	lEEnd  := !Empty(FwFldGet("GX4_DTCHEN")) .And. !Empty(FwFldGet("GX4_HRCHEN"))
	lSEnd  := !Empty(FwFldGet("GX4_DTSAEN")) .And. !Empty(FwFldGet("GX4_HRSAEN"))
	lLEnd  := !Empty(FwFldGet("GX4_DTLIEN")) .And. !Empty(FwFldGet("GX4_HRLIEN"))
	
	//Valida se a Data de entrada do movimento atual é maior que o anterior, quando existir
	nSeq 		:= Val(FwFldGet("GX4_SEQ"))
	cMovAtual 	:= FwFldGet("GX4_FILIAL")+FwFldGet("GX4_NRMOV")+FwFldGet("GX4_SEQ")
	cDtEntr	:= DTOS(FWFldGet("GX4_DTENTR")) + StrTran(FWFldGet("GX4_HRENTR"),":","")
	If nSeq > 1 .And. !Empty(cDtEntr)
		dbSelectArea("GX4")
		aAreaGX4 := GX4->(GetArea())
		GX4->(dbSetOrder(4))
		
		If GX4->(dbSeek(cMovAtual))
			GX4->(dbSkip(-1))
			If cDtEntr < DTOS(GX4->GX4_DTENTR) + StrTran(GX4->GX4_HRSAI,":","")
				HELP(,,'HELP',,"A data/hora de entrada do Ponto de Controle atual deve ser maior ou igual que a data/hora de saída do Ponto de Controle anterior.",1,0)
				Return .F.
			EndIf
		EndIf
		RestArea(aAreaGX4)
	EndIf
	dbSelectArea("GVF")
	GVF->( dbSetOrder(1) )
	If GVF->( dbSeek(xFilial("GVF") + FwFldGet("GX4_CDPTCT")) )
	
		dbSelectArea("GX3")
		GX3->( dbSetOrder(1) )
		If GX3->( dbSeek(xFilial("GX3") + FwFldGet("GX4_NRMOV")) )
		    
			If lSaida
	    		
				If !If(FwFldGet("GX4_DTSAI") == FwFldGet("GX4_DTENTR"), StrTran(FwFldGet("GX4_HRSAI"),":","") >= StrTran(FwFldGet("GX4_HRENTR"),":",""), FwFldGet("GX4_DTSAI") > FwFldGet("GX4_DTENTR"))
					Help( ,, 'HELP',, "A data/hora de Saída do Ponto de Controle deve ser igual ou maior que a data/hora de Entrada do Ponto de Controle.", 1, 0) //"A data/hora de Saída do Ponto de Controle deve ser maior que a data/hora de Entrada do Ponto de Controle."
					Return .F.
				EndIf
	    			
			EndIf
	    
			If GVF->GVF_IDINEN == "1"
	    		
	    		//Validação da Data de Chegada no Endereço
	    		
				If lEEnd
	    			
					If !If(FwFldGet("GX4_DTCHEN") == FwFldGet("GX4_DTENTR"), StrTran(FwFldGet("GX4_HRCHEN"),":","") > StrTran(FwFldGet("GX4_HRENTR"),":",""), FwFldGet("GX4_DTCHEN") > FwFldGet("GX4_DTENTR"))
						Help( ,, 'HELP',, STR0074, 1, 0) //"A data/hora de Chegada no Edereço deve ser maior que a data/hora de Entrada do Ponto de Controle."
						Return .F.
					EndIf
	    			
				EndIf
	    		
	    		//Validação da Data de Carga/Descarga no Endereço
	    		
				If !Empty(FwFldGet("GX4_DTINCA")) .And. !Empty(FwFldGet("GX4_HRINCA"))
	    			
					If !lEEnd
						Help( ,, 'HELP',, STR0075, 1, 0) //"Deve-se informar a data/hora de Chegada no Endereço para informar a data/hora de Carga/Descarga no Endereço."
						Return .F.
					EndIf
	    			
					If !If(FwFldGet("GX4_DTINCA") == FwFldGet("GX4_DTCHEN"), StrTran(FwFldGet("GX4_HRINCA"),":","") > StrTran(FwFldGet("GX4_HRCHEN"),":",""), FwFldGet("GX4_DTINCA") > FwFldGet("GX4_DTCHEN"))
						Help( ,, 'HELP',, STR0076, 1, 0) //"A data/hora de Carga/Descarga no Endereço deve ser maior que a data/hora de Chegada no Edereço."
						Return .F.
					EndIf
	    			
				EndIf
	    		
	    		//validação da Data de Fim de Carga/Descarga no Endereço
	    		
				If !Empty(FwFldGet("GX4_DTFICA")) .And. !Empty(FwFldGet("GX4_HRFICA"))
	    			    			
					If Empty(FwFldGet("GX4_DTINCA")) .Or. Empty(FwFldGet("GX4_HRINCA"))
						Help( ,, 'HELP',, STR0077, 1, 0) //"Deve-se informar a data/hora de Carga/Descarga no Endereço para poder informar a data/hora de Fim da Carga/Descarga no Endereço."
						Return .F.
					EndIf
	    			
					If !If(FwFldGet("GX4_DTFICA") == FwFldGet("GX4_DTINCA"), StrTran(FwFldGet("GX4_HRFICA"),":","") > StrTran(FwFldGet("GX4_HRINCA"),":",""), FwFldGet("GX4_DTFICA") > FwFldGet("GX4_DTINCA"))
						Help( ,, 'HELP',, STR0078, 1, 0) //"A data/hora de Fim da Carga/Descarga no Endereço deve ser maior que a data/hora de Carga/Descarga no Endereço."
						Return .F.
					EndIf
	    			
				EndIf
	    		
	    		//Validação da Data de Liberação do Endereço
	    		
				If lLEnd
	    			
					If Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDATEN") == "1"
	    			
						If Empty(FwFldGet("GX4_DTFICA")) .Or. Empty(FwFldGet("GX4_HRFICA"))
							Help( ,, 'HELP',, STR0079, 1, 0) //"Deve-se informar a data/hora de Fim da Carga/Descarga no Endereço para poder informar a data/hora de Liberação do Endereço."
							Return .F.
						EndIf
		    			
						If !If(FwFldGet("GX4_DTLIEN") == FwFldGet("GX4_DTFICA"), StrTran(FwFldGet("GX4_HRLIEN"),":","") >= StrTran(FwFldGet("GX4_HRFICA"),":",""), FwFldGet("GX4_DTLIEN") > FwFldGet("GX4_DTFICA"))
							Help( ,, 'HELP',, STR0080, 1, 0) //"A data/hora de Liberação do Endereço deve ser igual ou maior que a data/hora de Fim da Carga/Descarga no Endereço."
							Return .F.
						EndIf
		    		
					Else
		    		
						If !If(FwFldGet("GX4_DTLIEN") == FwFldGet("GX4_DTCHEN"), StrTran(FwFldGet("GX4_HRLIEN"),":","") >= StrTran(FwFldGet("GX4_HRCHEN"),":",""), FwFldGet("GX4_DTLIEN") > FwFldGet("GX4_DTCHEN"))
							Help( ,, 'HELP',, STR0081, 1, 0) //"A data/hora de Liberação do Endereço deve ser igual ou maior que a data/hora de Chegada no Endereço."
							Return .F.
						EndIf
		    		
					EndIf
	    			
				EndIf
	    		
	    		//Validação da Data de Saída do Endereço
	    		
				If lSEnd
	    			
					If !lLEnd
						Help( ,, 'HELP',, STR0082, 1, 0) //"Deve-se informar a data/hora de Liberação do Endereço para poder informar a data/hora de Saída do Endereço."
						Return .F.
					EndIf
	    			
					If !If(FwFldGet("GX4_DTSAEN") == FwFldGet("GX4_DTLIEN"), StrTran(FwFldGet("GX4_HRSAEN"),":","") >= StrTran(FwFldGet("GX4_HRLIEN"),":",""), FwFldGet("GX4_DTSAEN") > FwFldGet("GX4_DTLIEN"))
						Help( ,, 'HELP',, "A data/hora de Saída do Endereço deve ser maior ou igual a data/hora de Liberação do Endereço.", 1, 0) //"A data/hora de Saída do Endereço deve ser maior que a data/hora de Liberação do Endereço."
						Return .F.
					EndIf
	    			
				EndIf
	    		
	    		//Validação da Data de Saída
	    		
				If lSaida
	    			
					If !lSEnd
						Help( ,, 'HELP',, STR0084, 1, 0) //"Deve-se informar a data/hora de Saída do Endereço para poder informar a data de Saída do Ponto de Controle."
						Return .F.
					EndIf
	    			
					If !If(FwFldGet("GX4_DTSAI") == FwFldGet("GX4_DTSAEN"), StrTran(FwFldGet("GX4_HRSAI"),":","") >= StrTran(FwFldGet("GX4_HRSAEN"),":",""), FwFldGet("GX4_DTSAI") > FwFldGet("GX4_DTSAEN"))
						Help( ,, 'HELP',, "A data/hora de Saída do Ponto de Controle deve ser maior ou igual a data/hora de Saída do Endereço.", 1, 0) //"A data/hora de Saída do Ponto de Controle deve ser maior que a data/hora de Saída do Endereço."
						Return .F.
					EndIf
	    			
					dbSelectArea("GVF")
					GVF->( dbSetOrder(1) )
					If GVF->( dbSeek(xFilial("GVF") + GX4->GX4_CDPTCT) )
						
						If GVF->GVF_IDINEN == "1"
							If Empty(FwFldGet("GX4_CDENDE"))
								Help( ,, 'HELP',, STR0020, 1, 0) //"O Ponto de Controle obriga que se informe um endereço."
								Return .F.
							EndIf
						EndIf
						
						If Empty(FwFldGet("GX4_PRIORI")) .And. GVF->GVF_IDINEN == "1"
							Help( ,, 'HELP',, STR0056, 1, 0) //"Não foi informado o campo 'Prioridade'."
							Return .F.
						EndIf
						
					EndIf
						    			
				EndIf
	    		
	    		//------------------------------------Validação do processo de fila
				
				If GVF->GVF_IDFILA == "1"

					If cSitAnt == "1" //de Não avaliado

						If lEEnd

							If lLEnd

								If GFEA519BOC(FwFldGet("GX4_CDENDE")) == "2"

									RecLock("GX3", .F.)
									GX3->GX3_SIT := "2"
									MsUnlock("GX3")
			    					
								Else
									Help( ,, 'HELP',, STR0086, 1, 0) //"O endereço está ocupado, logo, os Campos Dt/Hr de Liberação não podem ser preenchidos antes do Ponto de Controle entrar em fila."
									Return .F.
								EndIf
			    			
							Else
			    				
			    				//se o endereço não estiver ocupado, coloca no endereço, senão verifica se a fila não está no tamanho máximo, senão coloca na fila
								If !GFEA519BEE(FwFldGet("GX4_CDENDE"), FwFldGet("GX4_PRIORI"), GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ)
									Help( ,, 'HELP',, STR0087, 1, 0) //"A fila do endereço está cheia, você não pode confirmar este Ponto de Controle."
									Return .F.
								EndIf
			    				
							EndIf
			    			
						Else
			    			
							RecLock("GX3", .F.)
							GX3->GX3_SIT := "2"
							MsUnlock("GX3")
			    			
						EndIf
			    		
					ElseIf cSitAnt == "2" .And. lAprov //de Aprovado para Aprovado
			    	    
						If _lNLib
			    	    
							If !_lNEnd .And. !lEEnd
			    	    		
								dbSelectArea("GVK")
								GVK->( dbSetOrder(2) )
								If GVK->( dbSeek(xFilial("GVK") + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ) )
								
									GFEA519RGK()// Remove da fila do endereçamento
		
									RecLock("GX3", .F.)
									GX3->GX3_SIT := "2"
									MSUnlock("GX3")
									
								Else
									GFEA519BPF(GX4->GX4_CDENDE)// Desfaz endereçamento
								EndIf
			    	    		
							ElseIf _lNEnd .And. lEEnd
				    	    	
								If lLEnd
				    				
									If GFEA519BOC(FwFldGet("GX4_CDENDE")) == "2"
				    					
										RecLock("GX3", .F.)
										GX3->GX3_SIT := "2"
										MsUnlock("GX3")
				    					
									Else
										Help( ,, 'HELP',, STR0088, 1, 0) //"O endereço está ocupado, logo, os Campos Dt/Hr de Liberação não podem ser preenchidos antes do Ponto de Controle entrar em fila."
										Return .F.
									EndIf
				    					    			
								Else
			
					    		    //se o endereço não estiver ocupado, coloca no endereço, senão verifica se a fila não está no tamanho máximo, senão coloca na fila
									If !GFEA519BEE(FwFldGet("GX4_CDENDE"), FwFldGet("GX4_PRIORI"), GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ)
										Help( ,, 'HELP',, STR0089, 1, 0) //"A fila do endereço está cheia, você não pode confirmar este Ponto de Controle."
										Return .F.
									EndIf
					    			
								EndIf
								
							Else
								dbSelectArea("GVK")
								GVK->( dbSetOrder(2) )
								If GVK->( dbSeek(xFilial("GVK") + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ) )
									Help( ,, 'HELP',, STR0090, 1, 0) //"O Ponto de Controle está em fila, portanto, não pode ser liberado."
									Return .F.
								EndIf
				    				
				    				//Tira do Endereço e chama o próximo da fila
								GFEA519BPF(GX4->GX4_CDENDE)
				    	    		    	    
							EndIf
				    	    
						Else
				    		
							If !lLEnd .And. lEEnd
				    			//se o endereço não estiver ocupado, coloca no endereço, senão verifica se a fila não está no tamanho máximo, senão coloca na fila
								If !GFEA519BEE(FwFldGet("GX4_CDENDE"), FwFldGet("GX4_PRIORI"), GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ)
									Help( ,, 'HELP',, STR0091, 1, 0) //"A fila do endereço está cheia, você não pode confirmar este Ponto de Controle."
									Return .F.
								EndIf
							EndIf
				    		
						EndIf
			    		
					ElseIf cSitAnt == "2" .And. !lAprov //de Aprovado para Reporvado
			    		
						If _lNLib .And. !_lNEnd
			    		    
							dbSelectArea("GVK")
							GVK->( dbSetOrder(2) )
							If GVK->( dbSeek(xFilial("GVK") + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ) )
							
								GFEA519RGK()// Remove da fila do endereçamento
	
								RecLock("GX3", .F.)
								GX3->GX3_SIT := "2"
								MSUnlock("GX3")
								
							Else
								GFEA519BPF(GX4->GX4_CDENDE)
							EndIf
				    		
						EndIf
			    		
					ElseIf cSitAnt == "3" .And. lAprov //de Reprovado para Aprovado
			    		
						If lEEnd .And. !lSEnd //Entrada preenchida e saida não preenchida
			    			
							If lLEnd
			    				
								If GFEA519BOC(FwFldGet("GX4_CDENDE")) == "2"
			    					
									RecLock("GX3", .F.)
									GX3->GX3_SIT := "2"
									MsUnlock("GX3")
			    					
								Else
									Help( ,, 'HELP',, STR0092, 1, 0) //"O endereço está ocupado, logo, os Campos Dt/Hr de Liberação não podem ser preenchidos antes do Ponto de Controle entrar em fila."
									Return .F.
								EndIf
			    			
							Else
			    				
			    				//se o endereço não estiver ocupado, coloca no endereço, senão verifica se a fila não está no tamanho máximo, senão coloca na fila
								If !GFEA519BEE(FwFldGet("GX4_CDENDE"), FwFldGet("GX4_PRIORI"), GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ)
									Help( ,, 'HELP',, STR0093, 1, 0) //"A fila do endereço está cheia, você não pode confirmar este Ponto de Controle antes de enviar para a fila."
									Return .F.
								EndIf
			    				
							EndIf
			    			
						Else
			    			
							RecLock("GX3", .F.)
							GX3->GX3_SIT := "2"
							MsUnlock("GX3")
			    			
						EndIf
					ElseIf cSitAnt == "3" .And. !lAprov //reprovado para reprovado
						If !lEEnd
			    	    	// Tirar da fila quando continua reprovado
							dbSelectArea("GVK")
							GVK->( dbSetOrder(2) )
							If GVK->( dbSeek(xFilial("GVK") + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ) )
								GFEA519RGK()// Remove da fila do endereçamento
	
								RecLock("GX3", .F.)
								GX3->GX3_SIT := "2"
								MSUnlock("GX3")
								
							ElseIf GX4->GX4_CDENDE != FwFldGet("GX4_CDENDE") .And. !Empty(GX4->GX4_CDENDE) .And. GX3->GX3_SIT $ "3;4"
								GFEA519BPF(GX4->GX4_CDENDE)
							EndIf
						EndIf
						If lEEnd  .And. !lLEnd
							If !(GX3->GX3_SIT $ "3;4") .And. !GFEA519BEE(FwFldGet("GX4_CDENDE"), FwFldGet("GX4_PRIORI"), GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ,!(GX3->GX3_SIT $ "3;4"))
								Help( ,, 'HELP',, STR0091, 1, 0) //"A fila do endereço está cheia, você não pode confirmar este Ponto de Controle."
								Return .F.
							EndIf
						ElseIf lEEnd .And. lLEnd .And. GX3->GX3_SIT $ "3;4"
							GFEA519BPF(GX4->GX4_CDENDE)
						EndIf
					EndIf
			    	
				Else // Não envia para fila-------------------------------------------------------------------------------------
			    	
					If cSitAnt == "1" .And. lAprov //de Não avaliado para Aprovado
			    		
						If lEEnd
			    			
							If lLEnd
			    				
								If GFEA519BOC(FwFldGet("GX4_CDENDE")) == "2"
			    					
									RecLock("GX3", .F.)
									GX3->GX3_SIT := "2"
									MsUnlock("GX3")
			    					
								Else
									Help( ,, 'HELP',, STR0094, 1, 0) //"O endereço está ocupado, logo, os Campos Dt/Hr de Liberação não podem ser preenchidos."
									Return .F.
								EndIf
			    			
							Else
								
								If !GFEA519BEE(FwFldGet("GX4_CDENDE"), FwFldGet("GX4_PRIORI"), GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ, .F.)
									Help( ,, 'HELP',, STR0095, 1, 0) //"O Endereço está ocupado, e o ponto de controle não permite enviar para fila, portanto, não poderá ser confirmado o Ponto de Controle."
									Return .F.
								EndIf
			    				
							EndIf
			    			
						Else
			    			
							RecLock("GX3", .F.)
							GX3->GX3_SIT := "2"
							MsUnlock("GX3")
			    			
						EndIf
			    		
					ElseIf cSitAnt == "2" .And. lAprov //de Aprovado para Aprovado
			    	    
						If _lNLib
			    	    
							If !_lNEnd .And. !lEEnd
			    	    		
								GFEA519BPF(GX4->GX4_CDENDE)
								
							ElseIf _lNEnd .And. lEEnd
				    	    	
								If lLEnd
				    				
									If GFEA519BOC(FwFldGet("GX4_CDENDE")) == "2"
				    					
										RecLock("GX3", .F.)
										GX3->GX3_SIT := "2"
										MsUnlock("GX3")
				    					
									Else
										Help( ,, 'HELP',, STR0096, 1, 0) //"O endereço está ocupado, logo, os Campos Dt/Hr de Liberação não podem ser preenchidos antes do Ponto de Controle entrar em fila."
										Return .F.
									EndIf
				    					    			
								Else
			
									If !GFEA519BEE(FwFldGet("GX4_CDENDE"), FwFldGet("GX4_PRIORI"), GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ, .F.)
										Help( ,, 'HELP',, STR0097, 1, 0) //"O Endereço está ocupado, e o ponto de controle não permite enviar para fila, portanto, não poderá ser confirmado o Ponto de Controle."
										Return .F.
									EndIf
					    			
								EndIf
								
							Else
				    	    	
								If lLEnd
				    				//Tira do Endereço e chama o próximo da fila
									GFEA519BPF(GX4->GX4_CDENDE)
								EndIf
				    	    		    	    
							EndIf
				    	    
						Else
				    		
							If !lLEnd .And. lEEnd
								If !GFEA519BEE(FwFldGet("GX4_CDENDE"), FwFldGet("GX4_PRIORI"), GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ, .F.)
									Help( ,, 'HELP',, STR0098, 1, 0) //"O Endereço está ocupado, e o ponto de controle não permite enviar para fila, portanto, não poderá ser confirmado o Ponto de Controle."
									Return .F.
								EndIf
							EndIf
				    					    		
						EndIf
			    		
					ElseIf cSitAnt == "2" .And. !lAprov //de Aprovado para Reporvado
			    		
						If _lNLib .And. !_lNEnd
			    		
							GFEA519BPF(GX4->GX4_CDENDE)
				    		
						EndIf //reprovado idfila
			    		
						If !lEEnd
			    	    	// Tirar da fila quando continua reprovado
							dbSelectArea("GVK")
							GVK->( dbSetOrder(2) )
							If GX4->GX4_CDENDE != FwFldGet("GX4_CDENDE") .And. !Empty(GX4->GX4_CDENDE)
								GFEA519BPF(GX4->GX4_CDENDE)
							EndIf
						EndIf
						
						If lEEnd  .And. !lLEnd
							If !GFEA519BEE(FwFldGet("GX4_CDENDE"), FwFldGet("GX4_PRIORI"), GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ,.F.)
								Help( ,, 'HELP',, STR0100, 1, 0) //"O Endereço está ocupado, e o ponto de controle não permite enviar para fila, portanto, não poderá ser confirmado o Ponto de Controle."
								Return .F.
							EndIf
						EndIf
					ElseIf cSitAnt == "3" .And. !lAprov //de Reprovado para Reprovado
						If _lNLib .And. !_lNEnd
			    		
							GFEA519BPF(GX4->GX4_CDENDE)
				    		
						EndIf //reprovado idfila
			    		
						If !lEEnd .And. !Empty(GX4->GX4_DTCHEN)
			    	    	// Tirar da fila quando continua reprovado
							dbSelectArea("GVK")
							GVK->( dbSetOrder(2) )
							If GX4->GX4_CDENDE != FwFldGet("GX4_CDENDE") .And. !Empty(GX4->GX4_CDENDE)
								GFEA519BPF(GX4->GX4_CDENDE)
							EndIf
						EndIf
						
						If lEEnd  .And. !lLEnd
							If !GFEA519BEE(FwFldGet("GX4_CDENDE"), FwFldGet("GX4_PRIORI"), GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ,.F.)
								Help( ,, 'HELP',, STR0100, 1, 0) //"O Endereço está ocupado, e o ponto de controle não permite enviar para fila, portanto, não poderá ser confirmado o Ponto de Controle."
								Return .F.
							EndIf
						EndIf
					ElseIf cSitAnt == "3" .And. lAprov //de Reprovado para Aprovado
			    		
						If lEEnd
			    			
							If lLEnd
			    				
								If GFEA519BOC(FwFldGet("GX4_CDENDE")) == "2"
			    					
									RecLock("GX3", .F.)
									GX3->GX3_SIT := "2"
									MsUnlock("GX3")
			    					
								Else
									Help( ,, 'HELP',, STR0099, 1, 0) //"O endereço está ocupado, logo, os Campos Dt/Hr de Liberação não podem ser preenchidos antes do Ponto de Controle entrar em fila."
									Return .F.
								EndIf
			    			
							Else
			    				
								If !GFEA519BEE(FwFldGet("GX4_CDENDE"), FwFldGet("GX4_PRIORI"), GX4->GX4_NRMOV, GX4->GX4_CDPTCT, GX4->GX4_SEQ, .F.)
									Help( ,, 'HELP',, STR0100, 1, 0) //"O Endereço está ocupado, e o ponto de controle não permite enviar para fila, portanto, não poderá ser confirmado o Ponto de Controle."
									Return .F.
								EndIf
			    				
							EndIf
			    			
						Else
			    			
							RecLock("GX3", .F.)
							GX3->GX3_SIT := "2"
							MsUnlock("GX3")
			    			
						EndIf
			    	
					EndIf
			
				EndIf
				
			Else
			    
				If GVF->GVF_IDFILA == "1" .And. GX3->GX3_SIT == "3" .And. lSaida
					Help( ,, 'HELP',, STR0101, 1, 0) //"O Ponto de Controle está em fila, portanto, não poderá ser informada a data de saída."]
					Return .F.
				EndIf
				
				RecLock("GX3", .F.)
				GX3->GX3_SIT := "2"
				MsUnlock("GX3")
			
			EndIf
			
			//Bloquear a aprovação do ponto de controle quando a configuração obrigar a informar o peso e este estiver vazio.
			If GFXCP12117("GVJ_IDPESO")
				GX3->( dbSetOrder(1) )
				If GX3->( dbSeek(xFilial("GX3") + GX4->GX4_NRMOV) )
	
					GVI->( dbSetOrder(1) ) // GVI_FILIAL+GVI_CDOPER+GVI_SEQ
					If GVI->( dbSeek(xFilial("GVI") + GX3->GX3_CDOPER + GX3->GX3_SEQ) )
	
						GVJ->( dbSetOrder(1) )
						If GVJ->( dbSeek(xFilial("GVJ") + GVI->GVI_CDOPER + GVI->GVI_SEQ + GX4->GX4_SEQ ) )
							
							If GVJ->GVJ_IDPESO == '0'
								If Posicione("GVF", 1, xFilial("GVF") + GX4->GX4_CDPTCT,"GVF_IDPESO") == '3' .And. M->GX4_QTPESO == 0 .And. AllTrim( DToC(FwFldGet("GX4_DTSAI")) ) <> "/  /"
									Help( ,, 'HELP',, "É obrigatória a etapa de pesagem antes de concluir a operação do Ponto de Controle.", 1, 0)
									Return .F.
								EndIf
							ElseIf GVJ->GVJ_IDPESO == '3' .And. M->GX4_QTPESO == 0 .And. AllTrim( DToC(FwFldGet("GX4_DTSAI")) ) <> "/  /"
								Help( ,, 'HELP',, "É obrigatória a etapa de pesagem antes de concluir a operação do Ponto de Controle.", 1, 0)
								Return .F.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			
			
			// Se leitura de hodometro estiver habilitada para o ponto de controle (GVF_IDHODO = “1=Sim;”) AND “Vl Hodometro” (GX4_VLHODO) nao for preenchido
			// Nao permitir informar data de saida do ponto de controle
			If 	Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDHODO") == "1" .And. ;
					AllTrim( Str(FwFldGet("GX4_VLHODO")) ) == "0" .And. ;
					AllTrim( DToC(FwFldGet("GX4_DTSAI")) ) <> "/  /"
				Help( ,, 'HELP',, "Informe o campo 'Vl Hodômetro' antes de registrar a saída do Ponto de Controle.", 1, 0)
				Return .F.
			Else
		
				dbSelectArea("GX3")
				GX3->( dbSetOrder(1) )
				If GX3->( dbSeek( xFilial("GX3") + FwFldGet("GX4_NRMOV") ) )
					dbSelectArea("GX6")
					GX6->( dbSetOrder(1) )
					GX6->( dbSeek(xFilial("GX6")+GX3->GX3_NRMOV) )
					While !GX6->( Eof() ) .And. xFilial("GX6") == GX6->GX6_FILIAL .And. GX6->GX6_NRMOV == GX3->GX3_NRMOV
						dbSelectArea("GU8")
						GU8->( dbSetOrder(1) )
						If GU8->( dbSeek(xFilial("GU8")+GX6->GX6_CDVEIC) )
		
							// Quando o campo “Vl Hodometro” for informado, atualizar a leitura de hodômetro na tabela de veículos do GFE (GU8).
							RecLock("GU8", .F.)
							GU8->GU8_VLHODO := FwFldGet("GX4_VLHODO")
							GU8->GU8_DTHODO := Date()
							MsUnLock("GU8")
		
						EndIf
						
						GX6->( dbSkip() )
					EndDo
				EndIf
			EndIf
			//ÚLTIMO PONTO DE CONTROLE.
			GFEA519BST(lAprov, lSaida)
			
		EndIf
		
	EndIf
	
	If cSitAnt == "1"
	
		dbSelectArea("GX6")
		GX6->( dbSetOrder(1) )
		GX6->( dbSeek(xFilial("GX6") + GX4->GX4_NRMOV) )
		While !GX6->( Eof() ) .And. GX6->GX6_FILIAL == xFilial("GX6") .And. GX6->GX6_NRMOV == GX4->GX4_NRMOV
		    
			If Empty(GX6->GX6_DTENTR) .Or. Empty(GX6->GX6_HRENTR)
				RecLock("GX6", .F.)
				GX6->GX6_DTENTR := FwFldGet("GX4_DTENTR")
				GX6->GX6_HRENTR := FwFldGet("GX4_HRENTR")
				MsUnlock("GX6")
			EndIf
			
			GX6->( dbSkip() )
		EndDo
		
	ElseIf GFEA519PCP(GX4->GX4_CDPTCT, GX4->GX4_SEQ) .And. lSaida
		
		dbSelectArea("GX6")
		GX6->( dbSetOrder(1) )
		GX6->( dbSeek(xFilial("GX6") + GX4->GX4_NRMOV) )
		While !GX6->( Eof() ) .And. GX6->GX6_FILIAL == xFilial("GX6") .And. GX6->GX6_NRMOV == GX4->GX4_NRMOV
		
			RecLock("GX6", .F.)
			GX6->GX6_DTSAI  := FwFldGet("GX4_DTSAI")
			GX6->GX6_HRSAI  := FwFldGet("GX4_HRSAI")
			MsUnlock("GX6")
		
			GX6->( dbSkip() )
		EndDo
	EndIf
	
	
		 
	If lSaida
		oModel:SetValue("GFEA519B_GX4","GX4_USUSAI", cUserName)
	EndIf
	 
	// lAprov : Aprovado / Reprovado
	If lAprov
		oModel:SetValue("GFEA519B_GX4","GX4_SIT","2")
	Else
		oModel:SetValue("GFEA519B_GX4","GX4_SIT","3")
	EndIf
	
	//Concluiu reprovado, verifcar ação GVJ BPO
	If !Empty(FwFldGet("GX4_DTSAI")) .And. !Empty(FwFldGet("GX4_HRSAI")) .And. !lAprov
		cRetAct := "1"
	
		dbSelectArea("GVJ")
		GVJ->(dbSetOrder(2))
		If GVJ->(dbSeek(xFilial("GVJ") + GX4->GX4_SEQ + GX4->GX4_CDPTCT + GX3->GX3_CDOPER + GX3->GX3_SEQ ))
			If !Empty(GVJ->GVJ_REPROV)
				cRetAct := GVJ->GVJ_REPROV
			EndIf
		EndIf
		
		If cRetAct != "6" .And. Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDIMPE") == "2" // Quanto o ponto não é impeditivo, grava o usuário que concluiu a movimentação como reprovado
			oModel:SetValue("GFEA519B_GX4","GX4_REPUSU",cUserName)
		EndIf
		
		If cRetAct == "4" // Cancelar movimento
			oModel:SetValue("GFEA519B_GX4","GX4_REPOBS","Cancelado pela configuração do ponto de controle.")
			oModel:SetValue("GFEA519B_GX4","GX4_REPUSU",cUserName)
			RecLock("GX3", .F.)
			GX3->GX3_SIT := "5"
			MsUnlock("GX3")
			
		EndIf
		If cRetAct == "5" // Continuar movimento
			oModel:SetValue("GFEA519B_GX4","GX4_REPOBS","Aprovado pela configuração do ponto de controle")
			oModel:SetValue("GFEA519B_GX4","GX4_REPUSU",cUserName)
			oModel:SetValue("GFEA519B_GX4","GX4_SIT","2")
			
		EndIf
		If cRetAct == "6" // voltar ao ponto anterior
			If Val(FwFldGet("GX4_SEQ")) == 1
				Help( ,, 'HELP',, STR0126, 1, 0) //"Somente a partir do segundo Ponto de Controle pode-se retornar ao Ponto de Controle anterior."
				Return .F.
			EndIf
			oModel:SetValue("GFEA519B_GX4","GX4_SIT","1")
			oModel:SetValue("GFEA519B_GX4","GX4_DTENTR",CToD("  /  /    "))
			oModel:SetValue("GFEA519B_GX4","GX4_HRENTR","")
			A523CanEnd(oModel) // Desfaz endereçamento
			dbSelectArea("GX4")
			GX4->( dbSetOrder(4) )
			If GX4->( dbSeek(xFilial("GX4") + GX4->GX4_NRMOV + StrZero(Val(GX4->GX4_SEQ)-1, 3)) )
				RecLock("GX4", .F.)
				GX4->GX4_DTSAI := CToD("  /  /    ")
				GX4->GX4_HRSAI := ""
				GX4->GX4_SIT   := "1"
				MSUnlock("GX4")
				
				GFEA519BIN()
			EndIf
		EndIf
	EndIf
	RestArea(aAreaGX4)
Return .T.

/*
{Protheus.doc} GFEA519BCMT
Função p/ gravar Nr. Movimento 

@sample
GFEA519BCMT(oMod)

@author Helder Fuckner dos Santos
@since 25/11/2013
@version 1.0
*/

Static Function GFEA519BCMT(oMod)
	Local nCont
	Local vGXA_CDTPDC, vGXA_EMISDC, vGXA_SERDC, vGXA_NRDC, vGXA_NRMOV
	Local oModelGXA
	Local aSitGX3cBox	:= STRToKArr(Posicione("SX3",2,"GX3_SIT","X3CBOX()"),";")
	Local aAreacGX3
	Local aAreaGX4 := GX4->(GetArea())
	Local nLinha
	FwFormCommit(oMod)
	oModelGXA := oMod:GetModel('GFE519BGXA')
	If Type("cAliGX3") == "C"
		aAreacGX3:= (cAliGX3)->(GetArea())
	EndIf
	For nCont := 1 To oModelGXA:Length()
		oModelGXA:GoLine(nCont)
		
		If !oModelGXA:IsDeleted()
			vGXA_CDTPDC = oModelGXA:GetValue('GXA_CDTPDC')
			vGXA_EMISDC = oModelGXA:GetValue('GXA_EMISDC')
			vGXA_SERDC  = oModelGXA:GetValue('GXA_SERDC')
			vGXA_NRDC   = oModelGXA:GetValue('GXA_NRDC')
			vGXA_NRMOV  = oModelGXA:GetValue('GXA_NRMOV')

			// Documentos de Carga
			dbSelectArea("GW1")
			GW1->( dbSetOrder(1) )
			GW1->( dbSeek(xFilial("GW1") + vGXA_CDTPDC + vGXA_EMISDC + vGXA_SERDC + vGXA_NRDC ) )
			While !GW1->( Eof() ) .And. GW1->GW1_FILIAL == xFilial("GW1") .And. GW1->GW1_CDTPDC == vGXA_CDTPDC .And. GW1->GW1_EMISDC == vGXA_EMISDC .And. GW1->GW1_SERDC == vGXA_SERDC .And. GW1->GW1_NRDC == vGXA_NRDC
				// GWN - Romaneios de Carga
				dbSelectArea("GWN")
				GWN->( dbSetOrder(1) )
				GWN->( dbSeek(xFilial("GWN") + GW1->GW1_NRROM ) )
				While !GWN->( Eof() ) .And. GWN->GWN_NRROM == GW1->GW1_NRROM
					RecLock("GWN", .F.)
					GWN->GWN_NRMOV := vGXA_NRMOV
					MsUnLock("GWN")
					
					GWN->( dbSkip() )
				EndDo
				
				GW1->( dbSkip() )
			EndDo
		EndIf
		
	Next nCont
	If Type("cAliGX3") == "C"
		RecLock(cAliGX3,.F.)
		(cAliGX3)->GX3_SIT	:= GX3->GX3_SIT
		(cAliGX3)->GX3_SIT2	:= SubStr(aSitGX3cBox[aScan(aSitGX3cBox,{|x| SubStr(x,1,1) == GX3->GX3_SIT })],3)
		MsUnlock(cAliGX3)
	EndIf
	
	If Type("oBrwGX3") == "O"
		oBrwGX3:Refresh()
		If Type("cAliGX3") == "C"
			RestArea(aAreacGX3)
		EndIf
	EndIf
	If Type("oBrwGX3:bChange") == "B"
		nLinha := oBrwGX4:NAT
		Eval(oBrwGX3:bChange)
		RestArea(aAreaGX4)
		oBrwGX4:NAT := nLinha
	EndIf
	
Return .T.

/*
{Protheus.doc} GFEA519BPF
Função que tira o Ponto de Controle do endereço
e chama o próximo.

@sample
GFEA519BPF(cEnde)

@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/

Function GFEA519BPF(cEnde)
	Local aAreaGX3 := GX3->( GetArea() )
	Local aAreaGVF := GVF->( GetArea() )
	
	dbSelectArea("GVD")
	GVD->( dbSetOrder(1) )
	If GVD->( dbSeek(xFilial("GVD") + cEnde) )
		
		dbSelectArea("GVK")
		GVK->( dbSetOrder(1) )
		If GVK->( dbSeek(xFilial("GVK") + cEnde) )
			
			cAlias := GetNextAlias()
	
			cQuery := " SELECT * FROM " + RetSQLName("GVK")
			cQuery += " WHERE GVK_CDENDE = '" + cEnde + "' "
			cQuery += " AND D_E_L_E_T_ = ' ' "
			cQuery += " ORDER BY GVK_NRPOS, GVK_SEQ ASC "
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)
			
			(cAlias)->( dbGoTop() )
			
			dbSelectArea("GVK")
			GVK->( dbSetOrder(2) )
			If GVK->( dbSeek(xFilial("GVK") + (cAlias)->GVK_NRMOV + (cAlias)->GVK_CDPTCT + (cAlias)->GVK_PTSEQ) )
				
				RecLock("GVD", .F.)
				GVD->GVD_IDOCUP := "1"
				MsUnlock("GVD")
				
				GFEA519RGK()// Remove da fila do endereçamento
				
				If Posicione("GVF",1,xFilial("GVF")+(cAlias)->GVK_CDPTCT,"GVF_IDENDE") == "1"
				
					dbSelectArea("GX3")
					GX3->( dbSetOrder(1) )
					If GX3->( dbSeek(xFilial("GX3") + (cAlias)->GVK_NRMOV) )
						
						RecLock("GX3", .F.)
						GX3->GX3_SIT := "4"
						MsUnlock("GX3")
						
					EndIf
				
					RestArea(aAreaGX3)
				
				EndIf
				
				RestArea(aAreaGVF)
				
			EndIf
			
			(cAlias)->( dbCloseArea() )
			
		Else
			RecLock("GVD", .F.)
			GVD->GVD_IDOCUP := "2"
			MsUnlock("GVD")
		EndIf
		
		RecLock("GX3", .F.)
		GX3->GX3_SIT := "2"
		MSUnlock("GX3")
		
	EndIf
	
Return

/*
{Protheus.doc} GFEA519BEE
Função para colocar o ponto de controle no,
endereço e se estiver ocupado coloca na fila.

@sample
GFEA519BEE(cEnde, cPrior, cMov, cPtCt, cSeq, lFila)

@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/

Static Function GFEA519BEE(cEnde, cPrior, cMov, cPtCt, cSeq, lFila)
	Local nCont := 0
	Default lFila := .T.
	
	dbSelectArea("GVK")
	GVK->( dbSetOrder(2) )
	If GVK->( dbSeek(xFilial("GVK") + cMov + cPtCt + cSeq) )
		Return .T. // já está endereçado
	EndIf
	dbSelectArea("GVD")
	GVD->( dbSetOrder(1) )
	If GVD->( dbSeek(xFilial("GVD") + cEnde) )
		
		If GVD->GVD_IDOCUP == "1"
			
			If !lFila
				
				Return .F.
			EndIf
			
			dbSelectArea("GVK")
			GVK->( dbSetOrder(1) )
			GVK->( dbSeek(xFilial("GVK") + cEnde) )
			While !GVK->( Eof() ) .And. GVK->GVK_FILIAL == xFilial("GVK") .And. GVK->GVK_CDENDE == cEnde
				
				nCont++
				
				GVK->( dbSkip() )
			EndDo
			
			If (nCont + 1) > Val(GVD->GVD_QTPOFI)
				Return .F.
			EndIf
			
			RecLock("GVK", .T.)
			GVK->GVK_FILIAL := xFilial("GVK")
			GVK->GVK_CDENDE := cEnde
			GVK->GVK_SEQ    := GFEA519BSF(cEnde)
			GVK->GVK_NRPOS  := cPrior
			GVK->GVK_NRMOV  := cMov
			GVK->GVK_CDPTCT := cPtCt
			GVK->GVK_PTSEQ  := cSeq
			GVK->GVK_DTCRIA := DDATABASE
			MsUnlock("GVK")
			
			RecLock("GX3", .F.)
			GX3->GX3_SIT := "3"
			MsUnlock("GX3")
			
		Else
			
			RecLock("GVD", .F.)
			GVD->GVD_IDOCUP := "1"
			MsUnlock("GVD")
			
			If Posicione("GVF",1,xFilial("GVF")+cPtCt,"GVF_IDENDE") == "1"
			
				RecLock("GX3", .F.)
				GX3->GX3_SIT := "4"
				MsUnlock("GX3")
			
			EndIf
					
		EndIf
			
	EndIf
	
Return .T.

/*
{Protheus.doc} GFEA519BSF
Função para retornar a próxima sequência da fila.

@sample
GFEA519BSF(cEnde)

@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/

Static Function GFEA519BSF(cEnde)
	Local aAreaGVK := GVK->( GetArea() )
	Local cSeq

	GVK->( dbSetFilter({|| GVK->GVK_CDENDE == cEnde},"") )
	GVK->( dbGoBottom() )

	If GVK->( Eof() )
		cSeq := StrZero(1, TamSX3("GVK_SEQ")[1])
	Else
		cSeq := StrZero(Val(GVK->GVK_SEQ) + 1, TamSX3("GVK_SEQ")[1])
	EndIf

	GVK->( dbClearFilter() )

	RestArea(aAreaGVK)

Return cSeq

/*
{Protheus.doc} GFEA519BST
Função para mudar o status da movimentação quando o PC 
deve entrar em fila

@sample
GFEA519BST(lAprov, lSaida)

@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/

Static Function GFEA519BST(lAprov, lSaida)
	Local lLast := GFEA519PCP(GX4->GX4_CDPTCT, GX4->GX4_SEQ)

	If lLast .And. lAprov .And. lSaida //GVF->GVF_IDCONC == "1" .And.
		RecLock("GX3", .F.)
		GX3->GX3_SIT := "6"
		MsUnlock("GX3")
	ElseIf !lAprov .And. !(GX3->GX3_SIT $ "2;3;4")//Não deve voltar para movimentado se está em fila ou endereçado
		RecLock("GX3", .F.)
		GX3->GX3_SIT := "2"
		MsUnlock("GX3")
	EndIf

Return

/*
{Protheus.doc} GFEA519PCP
Função que informa se o ponto de controle em questão
é o último da movimentação.

@sample
GFEA519PCP(cPtCt, cSeq)
@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/

Static Function GFEA519PCP(cPtCt, cSeq)
	Local aAreaGVJ := GVJ->( GetArea() )
	Local cChave   := xFilial("GVJ") + _cOper + _cSeq

	dbSelectArea("GVJ")
	GVJ->( dbSetOrder(1) )
	If GVJ->( dbSeek(cChave + cSeq) )

		dbSelectArea("GVJ")
		GVJ->( dbSkip() )

		If cChave != ( GVJ->GVJ_FILIAL + GVJ->GVJ_CDOPER + GVJ->GVJ_SEQ )
			RestArea(aAreaGVJ)

			Return .T.
		EndIf

	EndIf
	RestArea(aAreaGVJ)

Return .F.

/*
{Protheus.doc} GFEA519BVL
Validação antes de executar o Model

@sample
GFEA519BVL(oModel)

@author Octávio Augusto Felippe de Macedo
@since 28/04/2011
@version 1.0
*/

Function GFEA519BVL(oModel)

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	
		If GX3->GX3_SIT == "5"
			Help(,, 'HELP',, "A movimentação está cancelada, portanto não pode ser alterada.",1,0)
			Return .F.
		EndIf
	
		If Empty(aPtCt[1])
			Help( ,, 'HELP',, If(Empty(aPtCt[1]) .And. lAlt, STR0102, STR0057), 1, 0) //"O Ponto de Controle informado não tem acesso a esta movimentação." ### "Registro de Movimentação já está finalizado."
			Return .F.
		EndIf

		If aPtCt[4] .And. (_aAtuPC[1] != GX4->GX4_CDPTCT .Or. _aAtuPC[2] != GX4->GX4_SEQ)
			Help( ,, 'HELP',, STR0058 + cImped + STR0059, 1, 0) //"O Ponto de Controle " ### " foi reprovado e é impeditivo, somente o último Ponto de Controle pode ser altereado."
			Return .F.
		EndIf
		If !Empty(GX4->GX4_DTSAI) .And. !Empty(GX4->GX4_HRSAI)
			Help( ,, 'HELP',, STR0060, 1, 0) //"O Ponto de Controle já foi finalizado, portanto, não pode ser alterado."
			Return .F.
		EndIf

		If _aAtuPC[1] != GX4->GX4_CDPTCT .Or. _aAtuPC[2] != GX4->GX4_SEQ
			Help( ,, 'HELP',, STR0103 + cValToChar(_aAtuPC[1]) + "-" + cValToChar(_aAtuPC[2]) + STR0104, 1, 0) //"Somente o Ponto de Controle " ### ", que está corrente, pode ser alterado."
			Return .F.
		EndIf

		If (aPtCt[1] != GX4->GX4_CDPTCT .Or. If(lSame, aPtCt[2] != GX4->GX4_SEQ, .F.)) .And. aPtCt[3] != "1"
			Help( ,, 'HELP',, STR0022, 1, 0) //"O Ponto de Controle corrente está parametrizado para não permitir alterar outros Pontos de Controle."
			Return .F.
		EndIf

	EndIf

Return .T.

/*
{Protheus.doc} GFEA519BCH
Gera um chamado para o Ponto de Controle

@sample
GFEA519BCH()

@author Octávio Augusto Felippe de Macedo
@since 28/04/2011
@version 1.0
*/

Function GFEA519BCH(oView)
	Local cSeq

	dbSelectArea("GVF")
	GVF->( dbSetOrder(1) )
	If GVF->( dbSeek(xFilial("GVF") + GX4->GX4_CDPTCT) )
		If GVF->GVF_IDCHAM != "1"
			Help( ,, 'HELP',, STR0023, 1, 0) //"O Ponto de Controle não está parametrizado para chamar veículo."
			Return .F.
		EndIf
	EndIf

	dbSelectArea("GXB")
	GXB->( dbSetFilter({|| GXB->GXB_NRMOV == GX4->GX4_NRMOV .And. GXB->GXB_CDPTCT == GX4->GX4_CDPTCT .And. GXB->GXB_PTSEQ == GX4->GX4_SEQ},"") )
	GXB->( dbGoBottom() )

	If GXB->( Eof() )
		cSeq := StrZero(1, TamSX3("GXB_SEQ")[1])
	Else
		cSeq := StrZero(Val(GXB->GXB_SEQ) + 1,TamSX3("GXB_SEQ")[1] )
	EndIf

	GXB->( dbClearFilter() )

	RecLock("GXB", .T.)
	GXB->GXB_FILIAL := xFilial("GXB")
	GXB->GXB_NRMOV  := GX4->GX4_NRMOV
	GXB->GXB_CDPTCT := GX4->GX4_CDPTCT
	GXB->GXB_PTSEQ  := GX4->GX4_SEQ
	GXB->GXB_SEQ    := cSeq
	GXB->GXB_DTCHAM := dDataBase
	GXB->GXB_HRCHAM := Time()
	MsUnlock("GXB")
                                     
	oView:Refresh("GFEA519B_GX4")

	MsgInfo(STR0024,"") // "Chamado efetuado com sucesso."

Return .T.

/*
{Protheus.doc} GFEA519BRE
Gera o resumo do Ponto de Controle

@sample
GFEA519BRE(oView)

@author Octávio Augusto Felippe de Macedo
@since 28/04/2011
@version 1.0
*/

Function GFEA519BRE(oView,lAlter)
	Local cLog
	Local nLenSt   		:= Len(STR0025)+1 //"Status"
	Local nLenRef  		:= Len(STR0026)+1 //"Valor Referência"
	Local aAreaGX4 		:= GX4->( GetArea() )
	Local nTara	 		:= 0
	Local nPeso			:= 0
	Local nDocCarga		:= 0
	Local nUnitizadores	:= 0
	Local nDiff			:= 0
	Local nPeliq 			:= 0
	Local nAgendamento	:= 0
	Local nPct			:= 0
	Local CSIT			:= ""
	Local cAcaoRepro	:= ""
	Local cDesRepro		:= ""
	Default lAlter 		:= .T.

	If Empty(GX4->GX4_DTSAI)
		Return
	EndIf

	If lModified .Or. !lAlter
		If lAlter
			oView:GetModel():lModify := .F.
			oView:lModify := .F.
		
			lModified := .F.

		EndIf

		cLog := STR0027 + CRLF + CRLF //"RESUMO PONTO DE CONTROLE"
		
		cLog += STR0028 + " : " + GX4->GX4_NRMOV + CRLF //"MOVIMENTAÇÃO"
		cLog += STR0029 + " : " + AllTrim(Posicione("GX3",1,xFilial("GX3")+GX4->GX4_NRMOV,"GX3_CDOPER")) + "-" + GX3->GX3_SEQ + CRLF //"OPERAÇÃO"
		cLog += STR0030 + " : " + GX4->GX4_CDPTCT + CRLF //"PONTO DE CONTROLE"
		cLog += STR0031 + " : " + DToC(GX4->GX4_DTENTR) + " " + Stuff(GX4->GX4_HRENTR,3,0,":") + CRLF //"DATA E HORA DE INÍCIO"
		cLog += STR0032 + " : " + DToC(GX4->GX4_DTSAI) + " " + Stuff(GX4->GX4_HRSAI,3,0,":") + CRLF //"DATA E HORA DE TÉRMINO"
		cLog += "INÍCIO CARGA/DESCARGA" + " : " + DToC(GX4->GX4_DTINCA) + " " + Stuff(GX4->GX4_HRINCA,3,0,":") + CRLF
		cLog += "TÉRMINO CARGA/DESCARGA" + " : " + DToC(GX4->GX4_DTFICA) + " " + Stuff(GX4->GX4_HRFICA,3,0,":") + CRLF
		cLog += STR0033 + " : " + {STR0034,STR0035,STR0036}[Val(GX4->GX4_SIT)] + CRLF + CRLF //"STATUS PONTO DE CONTROLE" ### "Não Avaliado" ### "Aprovado" ### "Reprovado"
		
		cAcaoRepro := A523AcaoReprov()
		
		If cAcaoRepro == "1"
			cDesRepro := "Abrir Ocorrência"
		ElseIf cAcaoRepro == "2"
			cDesRepro := "Informar Controle Pátio"
		ElseIf cAcaoRepro == "3"
			cDesRepro := "Decisão Pto Controle "
		ElseIf cAcaoRepro == "4"
			cDesRepro := "Cancelar Movto "
		ElseIf cAcaoRepro == "5"
			cDesRepro := "Permitir Continuar "
		ElseIf cAcaoRepro == "6"
			cDesRepro := "Voltar Pto Anterior "
		EndIf
	
		cSit		:= GetSitDs()
		If !Empty(GFEA032PTO(,GX4->GX4_NRMOV,GX4->GX4_CDPTCT))
		
			cLog += "NÚMERO OCORRÊNCIA: " + GWD->GWD_NROCO  + CRLF 
			cLog += "DESCRIÇÃO: " + GWD->GWD_DSOCOR  + CRLF 
			GU5->(dbSetOrder(1))
			GU5->(dbSeek(xFilial("GU5") + GWD->GWD_CDTIPO))
			GU6->(dbSetOrder(1))
			GU6->(dbSeek(xFilial("GU6")+GWD->GWD_CDMOT))
			cLog += "TIPO: " 	+ GWD->GWD_CDTIPO 	+  "-" + AllTrim(GU5->GU5_DESC) + CRLF 
			cLog += "MOTIVO: " 	+ GWD->GWD_CDMOT 	+  "-" + AllTrim(GU6->GU6_DESC) + CRLF 
			cLog += "STATUS DO PONTO: " + cSit  + CRLF + CRLF
		Else
			cLog += "AÇÃO REPROVAÇÃO: " + cDesRepro  + CRLF 	
			cLog += "STATUS DO PONTO: " + cSit  + CRLF + CRLF											
		EndIf 

			
		dbSelectArea("GVF")
		If Posicione("GVF",1,GX4->GX4_FILIAL+GX4->GX4_CDPTCT,"GVF_IDVLPE") != "1"
			nTara 			:= A519PESOT("GX4_VLTARA")
			nPeso			:= A519PESOT("GX4_QTPESO")
			nDocCarga 		:= A519PESOT("DOC_CARGA")
			nUnitizadores	:= A519PESOT("UNITIZADORES")
			nAgendamento	:= A519PESOT("AGENDAMENTO")
		
			cLog += "-" + "PESOS INFORMADOS" + CRLF
			cLog += "|_ " + PadR("Agendamentos", 20) + " : " + cValToChar(nAgendamento) + CRLF
			cLog += "|_ " + PadR("Tara", 20) + " : " + cValToChar(nTara) + CRLF
			cLog += "|_ " + PadR("Veículo", 20) + " : " + cValToChar(nPeso) + CRLF
			cLog += "|_ " + PadR("Doc Carga", 20) + " : " + cValToChar(nDocCarga) + CRLF
			cLog += "|_ " + PadR("Unitizadores", 20) + " : " + cValToChar(nUnitizadores) + CRLF
		
			If Posicione("GVF",1,GX4->GX4_FILIAL+GX4->GX4_CDPTCT,"GVF_IDPELI") != "2"
				nPeliq := nPeso - nTara
				cLog += "|_ " + "Fórmula peso líquido : PESO - TARA" + CRLF
			Else
				nPeliq := nPeso - nTara - nUnitizadores
				cLog += "|_ " + "Fórmula peso líquido : PESO - TARA - UNITIZADORES" + CRLF
			EndIf
		
			cLog += "|_ " + PadR("Peso Líquido", 20) + " : " + cValToChar(nPeliq) + CRLF
		
			If nDocCarga > 0
				nDiff := nPeliq - nDocCarga
				cLog += "|_ " + PadR("Dif. Doc Carga", 20) + " : " + cValToChar(nDiff) + CRLF
			
				nPct := nDiff / nDocCarga * 100
				cLog += "|_ " + PadR("% Doc Carga", 20) + " : " + Transform(nPct, "9999.999") + "%" + CRLF
			EndIf
		
			If nAgendamento > 0
				nDiff := nPeliq - nAgendamento
				cLog += "|_ " + PadR("Dif. Agendamento", 20) + " : " + cValToChar(nDiff) + CRLF
			
				nPct := nDiff / nAgendamento * 100
				cLog += "|_ " + PadR("% Agendamento", 20) + " : " + Transform(nPct, "9999.999") + "%" + CRLF
			EndIf
		EndIf
	
		cLog += "-" + STR0037 + CRLF //"VALIDAÇÕES DO PONTO DE CONTROLE"
		cLog += "|_ " + PadR(STR0038, 26) + " | " + STR0025 + " | " + STR0026 + " | " + STR0039 + CRLF //"Validação" ### "Status" ### "Valor Referência" ### "Valor Obtido"
		cLog += " |_" + STR0040 + " " + "(" + STR0041 + ")" + "       | " + PadR(aValid[1][1],nLenSt) + "| " + PadR(aValid[1][2],nLenRef)     + "| " + aValid[1][3] + CRLF //"Agendamento" ### Atraso
		cLog += " |_" + STR0040 + " " + "(" + STR0042 + ")" + "  | " + PadR(aValid[2][1],nLenSt) + "| " + PadR(aValid[2][2],nLenRef)     + "| " + aValid[2][3] + CRLF //"Agendamento" ### "Antecipação"
		cLog += " |_" + PadR("Peso veículo", 26) + " | " + PadR(aValid[3][1],nLenSt) + "| " + PadR(aValid[3][2],nLenRef) + "| " + aValid[3][3] + CRLF
		cLog += " |_" + PadR("Peso min doc carga", 26) + " | " + PadR(aValid[4][1],nLenSt) + "| " + PadR(aValid[4][2],nLenRef) + "| " + aValid[4][3] + CRLF
		cLog += " |_" + PadR("Peso max doc carga", 26) + " | " + PadR(aValid[5][1],nLenSt) + "| " + PadR(aValid[5][2],nLenRef) + "| " + aValid[5][3] + CRLF
		cLog += " |_" + STR0047 + "        | " + PadR(aValid[7][1],nLenSt) + "| " + PadR(aValid[7][2],nLenRef)     + "| " + aValid[7][3] + CRLF //"Qtde. Doctos. Carga"
		cLog += " |_" + PadR("Peso min agend", 26) + " | " + PadR(aValid[8][1],nLenSt) + "| " + PadR(aValid[8][2],nLenRef) + "| " + aValid[8][3] + CRLF
		cLog += " |_" + PadR("Peso max agend", 26) + " | " + PadR(aValid[9][1],nLenSt) + "| " + PadR(aValid[9][2],nLenRef) + "| " + aValid[9][3] + CRLF + CRLF
	
		cLog += "-" + STR0048 + CRLF //"PERGUNTA DO PONTO DE CONTROLE"
	
		cLog += "|_ " + PadR(STR0049,TamSX3("GVG_DSPERG")[1]) + "| " + STR0061 + " | " + STR0050 + " | " + STR0051 //"Perguntas" ### "Resposta" ### "Impeditiva" ### "Observação"
	

		GX5->( dbSetOrder(1) )
		GX5->( dbSeek(xFilial("GX5") + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ) )
		While !GX5->( Eof() ) .And. GX5->GX5_FILIAL == xFilial("GX5") .And. GX5->GX5_NRMOV == GX4->GX4_NRMOV .And. ;
				GX5->GX5_CDPTCT == GX4->GX4_CDPTCT .And. GX5->GX5_SEQ == GX4->GX4_SEQ
		  
			cLog += CRLF + " |_" + Posicione("GVG",1,xFilial("GVG")+GX5->GX5_CDPERG,"GVG_DSPERG") + "| " + PadR({STR0052,STR0053}[Val(Posicione("GVH",2,xFilial("GVH") + GX5->GX5_CDPTCT + GX5->GX5_CDPERG,"GVH_IDIMPE"))],Len(STR0061)+1) + "| " + PadR({STR0052,STR0053}[Val(GX5->GX5_RESPOS)],Len(STR0050)+1) + "| " + GX5->GX5_OBS //"Impeditiva"
		
			GX5->( dbSkip() )
		EndDo
	
		cLog += CRLF + CRLF
	
		DEFINE MSDIALOG oDlg TITLE Capital(Lower(STR0027)) FROM 500,120 TO 900,950 OF oMainWnd Color CLR_BLACK,RGB(225,225,225) PIXEL //"Resumo Ponto de Controle"
	
		oMGet:= tMultiget():New(0,0,{|u| If(Pcount()>0,cLog:=u,cLog)},oDlg,300,204,,,,,,.T.,,,,,,.T.)
		oMGet:EnableVScroll(.T.)
		oMGet:EnableHScroll(.T.)
		oMGet:Align := CONTROL_ALIGN_ALLCLIENT
		oMGet:oFont := TFont():New( 'Courier New', 6, 16 )
	
		oPanel := tPanel():New(0,0,,oDlg,,,,,,31,15,.F.,.F.)
		oPanel:Align := CONTROL_ALIGN_BOTTOM
	
		oBtn := TButton():New( 2, 370, "OK", oPanel,{||oDlg:End()},;
			40, 10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
		ACTIVATE MSDIALOG oDlg CENTERED
    
		aValid := { {"NA","--","--"}, ;
			{"NA","--","--"}, ;
			{"NA","--","--"}, ;
			{"NA","--","--"}, ;
			{"NA","--","--"}, ;
			{"NA","--","--"}, ;
			{"NA","--","--"},;
			{"NA","--","--"},;
			{"NA","--","--"} }

	EndIf
	If lAlter
		GFEA519BIN()
	EndIf
	RestArea( aAreaGX4 )

Return

/*
{Protheus.doc} GFEA519BWH
Função que informa se o ponto de controle
faz verificação da quantidade de DC's.

@sample
GFEA519BWH()

@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/

Function GFEA519BWH()

Return Posicione("GVF",1,xFilial("GVF")+FwFldGet("GX4_CDPTCT"),"GVF_IDQTDC") == "1"

/*
{Protheus.doc} GFEA519BOC
Função que informa se endereço está ocupado.

@sample
GFEA519BOC(cEnde)

@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/
                                        
Static Function GFEA519BOC(cEnde)
	Local cOcup := "2"

	dbSelectArea("GVD")
	GVD->( dbSetOrder(1) )
	If GVD->( dbSeek(xFilial("GVD") + cEnde) )
		
		cOcup := GVD->GVD_IDOCUP
		
	EndIf
	
Return cOcup

/*
{Protheus.doc} GFEA519BFI
Função que retira o Ponto de Controle da fila.

@sample
GFEA519BFI(oView)

@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/

Function GFEA519BFI(oView)
	Local aAreaGX4 := GX4->( GetArea() )
	Local aAreaGX3 := GX3->( GetArea() )
	Local aAreaGVF := GVF->( GetArea() )
	Local aAreaGVK := GVK->( GetArea() )

	If Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDFILA") == "1"

		If Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDINEN") == "2"
		
			dbSelectArea("GX3")
			GX3->( dbSetOrder(1) )
			If GX3->( dbSeek(xFilial("GX3") + GX4->GX4_NRMOV) )
			
				If GX3->GX3_SIT == "3"
					RecLock("GX3", .F.)
					GX3->GX3_SIT := "2"
					MSUnlock("GX3")
				
					Help( ,, 'HELP',, STR0105, 1, 0) //"O Ponto de Controle retirado da fila."
				Else
					RecLock("GX3", .F.)
					GX3->GX3_SIT := "3"
					MSUnlock("GX3")
				
					Help( ,, 'HELP',, STR0106, 1, 0) //"O Ponto de Controle colocado em fila."
				EndIf
			
			EndIf
		
		Else
	
			dbSelectArea("GVK")
			GVK->( dbSetOrder(2) )
			If GVK->( dbSeek(xFilial("GVK") + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ) )
		    
				If MsgYesNo(STR0107) //"Deseja retirar o Ponto de Controle da Fila?"
		
					GFEA519RGK()// Remove da fila do endereçamento
				
					oView:GetModel():GetModel("GFEA519B_GX4"):SetValue("GX4_DTCHEN", CToD("  /  /    "))
					oView:GetModel():GetModel("GFEA519B_GX4"):SetValue("GX4_HRCHEN", "")
					oView:GetModel():GetModel("GFEA519B_GX4"):SetValue("GX4_DTINCA", CToD("  /  /    "))
					oView:GetModel():GetModel("GFEA519B_GX4"):SetValue("GX4_HRINCA", "")
					oView:GetModel():GetModel("GFEA519B_GX4"):SetValue("GX4_DTFICA", CToD("  /  /    "))
					oView:GetModel():GetModel("GFEA519B_GX4"):SetValue("GX4_HRFICA", "")
				
					RecLock("GX4", .F.)
					GX4->GX4_DTCHEN := CToD("  /  /    ")
					GX4->GX4_HRCHEN := ""
					GX4->GX4_DTINCA := CToD("  /  /    ")
					GX4->GX4_HRINCA := ""
					GX4->GX4_DTFICA := CToD("  /  /    ")
					GX4->GX4_HRFICA := ""
					MSUnlock("GX4")
				
					_lNEnd := .T.
					_lNLib := .T.
				
					dbSelectArea("GX3")
					GX3->( dbSetOrder(1) )
					If GX3->( dbSeek(xFilial("GX3") + GX4->GX4_NRMOV) )
						RecLock("GX3", .F.)
						GX3->GX3_SIT := "2"
						MSUnlock("GX3")
					EndIf
				
					oView:Refresh()
				
				EndIf
			
			Else
				Help( ,, 'HELP',, STR0108, 1, 0) //"O Ponto de Controle não está na fila."
			EndIf
		
		EndIf

	Else
		Help( ,, 'HELP',, STR0109, 1, 0) //"O Ponto de Controle não está parametrizado para controle de fila."
	EndIf

	RestArea(aAreaGX4)
	RestArea(aAreaGX3)
	RestArea(aAreaGVF)
	RestArea(aAreaGVK)

Return

/*
{Protheus.doc} GFEA519BEN
Função informa se informa endereço

@sample
GFEA519BEN()

@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/

Function GFEA519BEN()
	Local cInfEnd
	
	dbSelectArea("GVF")
	
	cInfEnd := Posicione("GVF",1,xFilial("GVF")+M->GX4_CDPTCT,"GVF_IDINEN")
	
Return cInfEnd == "1"
         
/*
{Protheus.doc} GFEA519BVE
Função que verifica se o endereço pertence aos agendamentos da movimentação

@sample
GFEA519BVE()

@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/

Function GFEA519BVE()
	Local aEnde := {}
	Local oModel := FWModelActive()

	If !Empty(FwFldGet("GX4_CDENDE"))
		dbSelectarea("GVD")
		GVD->(dbSetOrder(1))
		If !GVD->(DbSeek(xFilial("GVD")+FwFldGet("GX4_CDENDE")))
			Help( ,, 'HELP',, STR0110, 1, 0) //"O endereço informado não existe no cadastro de Endereços de Mercadorias."
			Return .F.
		EndIf
		If GVD->GVD_SIT == "2"
			Help(,,'HELP',, "Endereço está inativo",1,0)
			Return .F.
		EndIf
		dbSelectArea("GWV")
		GWV->( dbSetOrder(4) )
		GWV->( dbSeek(xFilial("GWV") + GX4->GX4_NRMOV) )
		While !GWV->( Eof() ) .And. GWV->GWV_FILIAL == xFilial("GWV") .And. GWV->GWV_NRMOV == GX4->GX4_NRMOV
		
			dbSelectArea("GWX")
			GWX->( dbSetOrder(1) )
			GWX->( dbSeek(xFilial("GWX") + GWV->GWV_NRAGEN) )
			While !GWX->( Eof() ) .And. GWX->GWX_FILIAL == xFilial("GWX") .And. GWX->GWX_NRAGEN == GWV->GWV_NRAGEN
			
				If AScan(aEnde, {|x| x == GWX->GWX_CDENDE}) == 0
					aAdd(aEnde, GWX->GWX_CDENDE)
				EndIf
			
				dbSelectArea("GWX")
				GWX->( dbSkip() )
			EndDo
		
			dbSelectArea("GWV")
			GWV->( dbSkip() )
		EndDo
	
		If !Empty(aEnde) .And. AScan(aEnde, {|x| x == FwFldGet("GX4_CDENDE")}) == 0
			Help( ,, 'HELP',, STR0111, 1, 0) //"O endereço deve pertencer a um dos endereços relacionados aos Agendamentos."
			Return .F.
		EndIf
	
		If !Empty(FwFldGet("GX4_DTCHEN")) .And. GX4->GX4_CDENDE != FwFldGet("GX4_CDENDE")
			Help( ,, 'HELP',, "Não é possível trocar o endereço quando a chegada está preenchida.", 1, 0)
			Return .F.
		EndIf
	ElseIf !Empty(FwFldGet("GX4_DTCHEN")) .And. Empty(FwFldGet("GX4_DTSAEN"))
		If !MsgYesNo("Desfazer o endereçamento?")
			Help( ,, 'HELP',, "O endereço é obrigatório quando a data de entrada do endereço está preenchida.", 1, 0)
			Return .F.
		Else
			A523CanEnd(oModel)
		EndIf
	ElseIf !Empty(FwFldGet("GX4_DTSAEN"))
		Help( ,, 'HELP',, "O endereço é obrigatório quando a data de saída do endereço está preenchida.", 1, 0)
		Return .F.
	EndIf
	
Return .T.

/*
{Protheus.doc} GFEA519BDT
Função para o usuário informar as datas referente ao controle de endereço

@sample
GFEA519BDT(oView, nData)

@author Octávio Augusto Felippe de Macedo
@since 25/05/2011
@version 1.0
*/

Function GFEA519BDT(oView, nData)
	Local oModel    := oView:GetModel()
	Local oModelGX4 := oModel:GetModel("GFEA519B_GX4")
	Local aOp       := {"Entrada","1.Chegada Endereço", "2.Início Carga/Descarga", "3.Fim Carga/Descarga", "4.Liberação Endereço", "5.Saida Endereço", "Saída"} //"Cheg End" ### "Ini Carg/Desc" ### "Fim Carg/Desc" ### "Lib Ender" ### "Saíd End"
	Local aCmp      := {{"DTENTR","HRENTR"},{"DTCHEN","HRCHEN"},{"DTINCA","HRINCA"},{"DTFICA","HRFICA"},{"DTLIEN","HRLIEN"},{"DTSAEN","HRSAEN"},{"DTSAI","HRSAI"}}
	Local lGravou := .F.
	Local uValor1 := &('M->GX4_'+aCmp[nData][1])
	Local uValor2 := &('M->GX4_'+aCmp[nData][2])
	Local cEditDt := "1"  //1-Edita Data e Hora
	Local lHab    := .F.
	lRet := .T.
	Private cCodUsr := RetCodUsr()   
	Private oDlg

	If Empty(&('M->GX4_'+aCmp[nData][1]))
		&('M->GX4_'+aCmp[nData][1]) := Date()
	EndIf

	If Empty(&('M->GX4_'+aCmp[nData][2]))
		&('M->GX4_'+aCmp[nData][2]) := StrTran(SubStr(Time(),1,5),':','')
	EndIf
	
	If oModel:GetOperation() != MODEL_OPERATION_UPDATE
		Help( ,, 'HELP',, STR0117, 1, 0) //"Deve-se alterar o Ponto de Controle para acessar esta opção."
		&('M->GX4_'+aCmp[nData][1]) := uValor1
		&('M->GX4_'+aCmp[nData][2]) := uValor2
		Return .F.
	EndIf
	If nData == 3 .Or. nData == 4
	
		If Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDINEN") != "1" //.Or. Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDATEN") != "1"
			Help( ,, 'HELP',, STR0118 + aOp[nData], 1, 0) //"O Ponto de Controle não está parametrizado para informar Endereço, logo, não pode-se informar Data/Hora de "
			&('M->GX4_'+aCmp[nData][1]) := uValor1
			&('M->GX4_'+aCmp[nData][2]) := uValor2
			Return .F.
		EndIf
	
		If Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDATEN") != "1"
			Help( ,, 'HELP',, STR0119 + aOp[nData], 1, 0) //"O Ponto de Controle não está parametrizado para Atendimento, logo, não pode-se informar Data/Hora de "
			&('M->GX4_'+aCmp[nData][1]) := uValor1
			&('M->GX4_'+aCmp[nData][2]) := uValor2
			Return .F.
		EndIf
	
		dbSelectArea("GVK")
		GVK->( dbSetOrder(2) )
		If GVK->( dbSeek(xFilial("GVK") + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ) )
			Help(,,'HELP',,"Não é possível efetuar a carga/descarga com o endereçamento 'Em Fila'",1,0)
			&('M->GX4_'+aCmp[nData][1]) := uValor1
			&('M->GX4_'+aCmp[nData][2]) := uValor2
			Return .F.
		EndIf
	
	ElseIf nData > 1 .And. nData < 7
	
		If Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDINEN") != "1"
			Help( ,, 'HELP',, STR0120 + aOp[nData], 1, 0) //"O Ponto de Controle não está parametrizado para informar Endereço, logo, não pode-se informar Data/Hora de "
			&('M->GX4_'+aCmp[nData][1]) := uValor1
			&('M->GX4_'+aCmp[nData][2]) := uValor2
			Return .F.
		EndIf
		If nData == 5
			dbSelectArea("GVK")
			GVK->( dbSetOrder(2) )
			If GVK->( dbSeek(xFilial("GVK") + GX4->GX4_NRMOV + GX4->GX4_CDPTCT + GX4->GX4_SEQ) )
				Help(,,'HELP',,"Não é possível efetuar a liberação com o ponto de controle 'Em Fila'",1,0)
				&('M->GX4_'+aCmp[nData][1]) := uValor1
				&('M->GX4_'+aCmp[nData][2]) := uValor2
				Return .F.
			EndIf
		EndIf
		If Empty(oModelGX4:GetValue("GX4_CDENDE"))
			Help( ,, 'HELP',, "É necessário informar um endereço de carga", 1, 0)
			Return .F.
		EndIF
	EndIf

	if GFXCP12121("GVP_EDITDT") .And. ( nData == 1 .OR. nData == 7 )  //Dt Entrada/Saída Pto Controle
		GVP->(dbSetOrder(1))
		if GVP->(dbSeek(xFilial("GVP") + cCodUsr + GX4->GX4_CDPTCT))
			if !Empty (GVP->GVP_EDITDT)	  
				cEditDt := GVP->GVP_EDITDT	 //Config Edição campos Data 
			Endif
		EndIf
	EndIf
    
	/* Ponto de entrada Sementes Goias -Bloquear a edição do campo Data e Hora para digitação - via PE*/
	IF ExistBlock("GFE519B2")
		lHab := ExecBlock("GFE519B2",.F.,.F.,{})
	EndIf
	    
    if cEditDt != "4"
    	
        if cEditDt == "2" .OR. cEditDt == "3"   //2-Edita Horário ou 3-Visualiza
        	lHab := .T.
        EndIf
    	
		DEFINE MSDIALOG oDlg TITLE aOp[nData] FROM 100,100 TO 187, 329 COLOR CLR_BLACK,RGB(225,225,225) PIXEL //
		oGrpDt := tGroup():New(03,03,27,55, STR0121,oDlg,,CLR_GRAY,.T.) // "Data "

		TGet():New(12,7,{|u| If(PCount()>0,&('M->GX4_'+aCmp[nData][1]):=u,&('M->GX4_'+aCmp[nData][1]))}, oGrpDt, 45,5,'99/99/9999',,,,,,,.T.,,,{|| .T.},,,,lHab,,,'M->GX4_'+aCmp[nData][1])

		if cEditDt == "2"  //2-Edita Horário
			lHab := .F.
		EndIf
        	
		oGrpHr := tGroup():New(03,60,27,112, STR0122,oDlg,,CLR_GRAY,.T.) // "Hora "

		TGet():New(12,64,{|u| If(PCount()>0,&('M->GX4_'+aCmp[nData][2]):=u,&('M->GX4_'+aCmp[nData][2]))}, oGrpHr, 45,5,'@R 99:99',{|| GFEVLDHR(&('M->GX4_'+aCmp[nData][2]))},,,,,,.T.,,,{|| .T.},,,,lHab,,,'M->GX4_'+aCmp[nData][2])

		TButton():New( 32, 50, "OK", oDlg,{||If ((lGravou:=COMP519GRA(oView, "GFEA519B_GX4", "GX4_" + aCmp[nData][1], "GX4_" + aCmp[nData][2])),oDlg:End(),Nil)},;
		30, 10,,,.F.,.T.,.F.,,.F.,,,.F. )

		TButton():New( 32, 82, STR0123, oDlg,{||;
		COMP519SET(oView, "GFEA519B_GX4", "GX4_" + aCmp[nData][1], COMP519GET(oView, "GFEA519B_GX4", "GX4_" + aCmp[nData][1])),;
		COMP519SET(oView, "GFEA519B_GX4", "GX4_" + aCmp[nData][2], COMP519GET(oView, "GFEA519B_GX4", "GX4_" + aCmp[nData][2])),;
		lRet:=.F.,oDlg:End()},30, 10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"

		TButton():New( 32, 03, STR0124, oDlg,{|| If ((lGravou:=COMP519GRA(oView, "GFEA519B_GX4", "GX4_" + aCmp[nData][1], "GX4_" + aCmp[nData][2], .T.)),oDlg:End(),Nil) },;
		30, 10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Limpar"

	    SetKey(VK_F11, {|| &('M->GX4_'+aCmp[nData][1]) := Date(), &('M->GX4_'+aCmp[nData][2]) := StrTran(SubStr(Time(),1,5),':','')})
	    ACTIVATE MSDIALOG oDlg CENTERED
		SetKey(VK_F11, {|| })	
	Else
	    &('M->GX4_'+aCmp[nData][1]) := Date()   // 4-Automático grava dt e hora atual
		&('M->GX4_'+aCmp[nData][2]) := StrTran(SubStr(Time(),1,5),':','')
	    lGravou:=COMP519GRA(oView, "GFEA519B_GX4", "GX4_" + aCmp[nData][1], "GX4_" + aCmp[nData][2])	
	EndIf  
	
	If !lGravou
		&('M->GX4_'+aCmp[nData][1]) := uValor1
		&('M->GX4_'+aCmp[nData][2]) := uValor2
	EndIf
	
Return  lRet

/*
{Protheus.doc} GFEA519BRP
Função para retornar ao Ponto de Controle anterior

@sample
GFEA519BRP()

@author Octávio Augusto Felippe de Macedo
@since 25/05/2011
@version 1.0
*/
Function GFEA519BRP()
	Local aAreaGX4 := GX4->( GetArea() )
	Local lRet := .F.
	
	cPcAnt 	:=	StrZero(Val(_aAtuPC[2])-1, 3)
	cNomePc 	:= 	Posicione("GX4",4, xFilial("GX4") + GX4->GX4_NRMOV + cPcAnt, "GX4_CDPTCT")
	
	If MsgYesNo("Deseja retornar ao ponto de controle anterior (" + Alltrim(cNomePc) + ") ?" ) //"Deseja retornar ao ponto de controle anterior?"
		
		dbSelectArea("GX4")
		GX4->( dbSetOrder(4) )
		If GX4->( dbSeek(xFilial("GX4") + GX4->GX4_NRMOV + _aAtuPC[2]) )
		
			If Val(GX4->GX4_SEQ) == 1
				Help( ,, 'HELP',, STR0126, 1, 0) //"Somente a partir do segundo Ponto de Controle pode-se retornar ao Ponto de Controle anterior."
				Return lRet
			EndIf
			
			If GX4->GX4_SIT != "1" .And. GVJ->GVJ_REPROV != "2" .And. !IsInCallStack("GFEA519") .And. !IsInCallStack("GFEA523")
				Help( ,, 'HELP',, STR0127, 1, 0) //"Pode-se apenas retornar ao Ponto de Controle anterior quando o Ponto de Controle atual ainda esteja com status 'Não Avaliado.'"
				Return lRet
			EndIf
			
			RecLock("GX4",.F.)
			GX4->GX4_SIT		:= "1"
			GX4->GX4_DTENTR	:= CToD("  /  /    ")
			GX4->GX4_HRENTR	:= ""
			
			dbSelectArea("GVK")
			GVK->( dbSetOrder(2) )
			If GVK->( dbSeek(xFilial("GVK") + GX4->GX4_NRMOV+ GX4->GX4_CDPTCT + GX4->GX4_SEQ) )
			
				GFEA519RGK()// Remove da fila do endereçamento
	
			ElseIf !Empty(GX4->GX4_DTCHEN) .And. Empty(GX4->GX4_DTLIEN)
				GFEA519BPF(GX4->GX4_CDENDE)// Desfaz endereçamento
			EndIf
			A523CanEnd() // Desfaz endereçamento
			MSUnlock("GX4")
			dbSelectArea("GX4")
			GX4->( dbSetOrder(4) )
			If GX4->( dbSeek(xFilial("GX4") + GX4->GX4_NRMOV + StrZero(Val(_aAtuPC[2])-1, 3)) )
				RecLock("GX4", .F.)
				GX4->GX4_DTENTR	:= CToD("  /  /    ")
				GX4->GX4_HRENTR	:= ""
				GX4->GX4_DTSAI 	:= CToD("  /  /    ")
				GX4->GX4_HRSAI 	:= ""
				GX4->GX4_SIT   	:= "1"
				MSUnlock("GX4")
				
				GFEA519BIN()
				lRet := .T.
			EndIf
			RecLock("GX3", .F.)
			GX3->GX3_SIT := "2"
			MSUnlock("GX3")
		EndIf
		
	EndIf

	RestArea( aAreaGX4 )

Return lRet

/*
{Protheus.doc} GFEA519BAT
Função informa se pode atender o Ponto de Controle 

@sample
GFEA519BAT()

@author Octávio Augusto Felippe de Macedo
@since 19/05/2011
@version 1.0
*/

Function GFEA519BAT()

Return (Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDATEN") == "1" .And. Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_IDINEN") == "1")


Function GFEA519BSI()
	Local oTMultiget
	Local cTextoGVF := ""
	Local cAuxGVF   := ""
	Local cTextoGVI := ""
	Local cTexto 	:= ""
	Private oDlgInst

	If GFXCP12117("GVF_INSTRU")
		cTextoGVF 	:= Posicione("GVF",1,xFilial("GVF") + _cPtCt,"GVF_INSTRU")
		cAuxGVF 	:= StrTran(cTextoGVF, Chr(13)+Chr(10), "")	
		cTexto		+= "** Ponto de Controle **" + CRLF 
		If AllTrim(cAuxGVF) <> ""
			cTexto 	+= + cTextoGVF +  CRLF + CRLF + CRLF
		Else 
			cTexto	+= "Não há instruções cadastradas para este Ponto de Controle." + CRLF + CRLF + CRLF
		EndIf
	EndIf
		
	If GFXCP12117("GVI_INSTRU") 
		GX3->( dbSetOrder(1) )
		GX3->( dbSeek(xFilial("GX3") + GX4->GX4_NRMOV) )
		
		GVI->( dbSetOrder(1) )
		GVI->( dbSeek(xFilial("GVI") + GX3->GX3_CDOPER + GX3->GX3_SEQ) )
		
		cTextoGVI 	:= GVI->GVI_INSTRU
		cAuxGVI 	:= StrTran(cTextoGVI, Chr(13)+Chr(10), "")		
		cTexto		+= "** Configuração de Operação **" + CRLF 
		If AllTrim(cAuxGVI) <> ""
			cTexto 	+= + cTextoGVI +  CRLF + CRLF + CRLF
		Else 
			cTexto	+= "Não há instruções cadastradas para esta Configuração da Operação." + CRLF + CRLF + CRLF
		EndIf
	EndIf

	DEFINE DIALOG oDlgInst TITLE "Instruções" FROM 180, 110 TO 400, 628 PIXEL
	oTMultiget := tMultiget():new( 01, 01, {| u | if( pCount() > 0, cTexto := u, cTexto ) }, oDlgInst, 260, 92, , , , , , .T. ,,,,,,.T.,,,,,.T.)  	
 	DEFINE SBUTTON oSBtnEnd FROM 95, 01 TYPE 01 OF oDlgInst ENABLE ACTION oDlgInst:End()
 	ACTIVATE DIALOG oDlgInst CENTERED


Return


Function GFEA519OCO()
	Local oView	:= FWLoadView('GFEA032')
	Local oModel 	:= FWLoadModel('GFEA032')
	Local aAreaGX4 := GX4->(GetArea())
	Local oStruct
	Local cString := ""
	Private cAliGWU
	
	If _aAtuPC[1] != GX4->GX4_CDPTCT .Or. _aAtuPC[2] != GX4->GX4_SEQ
		Help( ,, 'HELP',, "Somente o Ponto de Controle " + cValToChar(_aAtuPC[1]) + ", que está corrente, pode ser alterado.", 1, 0)
		Return .F.
	EndIf
	
	If !Empty(cString := GFEA032PTO(,GX4->GX4_NRMOV,GX4->GX4_CDPTCT))
		GFEMsgErro("Existe uma outra ocorrência para este ponto de controle que está pendente." + CRLF + "Ocorrência :" + AllTrim(cString))
		Return .F.
	EndIf
	
	If GX4->GX4_SIT != "3"
		GFEMsgErro("Ponto de controle deve estar reprovado para abrir a ocorrência.")
		Return .F.
	EndIf
	
	If Empty(GX4->GX4_DTSAI)
		GFEMsgErro("A data de saída do ponto de controle deve estar informada.")
		Return .F.
	EndIf
	
	If A523AcaoReprov() != "1"
		GFEMsgErro("A ação da reprovação não permite abrir a ocorrência.")
		Return .F.
	EndIf
	
	aCoors := FWGetDialogSize(oMainWnd)
	oStruct := oView:GetViewStruct("GFEA032_GWD")
								
	oView:SetModel(oModel)
	oStruct:SetProperty("GWD_DTOCOR", MVC_VIEW_CANCHANGE, .F.)
	oStruct:SetProperty("GWD_HROCOR", MVC_VIEW_CANCHANGE, .F.)
	
	oView:EnableControlBar(.T.)
	oView:SetOperation(MODEL_OPERATION_INSERT)
	oView:SetUseCursor(.F.)
	oView:SetCloseOnOk({|| .T.})
	oView:oModel:SetActivate({|oModel|A519AbreCad(oModel,oView)})

	oFWMVCWindow := FWMVCWindow():New()
	oFWMVCWindow:SetUseControlBar(.T.)
	oFWMVCWindow:SetView(oView)
	oFWMVCWindow:SetCentered(.T.)
	oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
	oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
	oFWMVCWindow:SetTitle("Ocorrência")
	oFWMVCWindow:Activate()
	RestArea(aAreaGX4)
Return

Static Function GetGWDCpos()
	Local cCDEMIT := Posicione("GX3",1,xFilial("GX3")+GX4->GX4_NRMOV,"GX3_CDEMIT")
	Local aCpoVal := {;
		{ 'GWD_CDTRP'	, cCDEMIT			},;
		{ 'GWD_NRMOV'	, GX4->GX4_NRMOV	},;
		{ 'GWD_CDPTCT', GX4->GX4_CDPTCT	},;
		{ 'GWD_DTOCOR', GX4->GX4_DTSAI	},;
		{ 'GWD_HROCOR', GX4->GX4_HRSAI	};
		}
Return aCpoVal

Static Function A519AbreCad(oModel, oView)
	Local nCount
	Local aCpoVal := GetGWDCpos()
	
	For nCount := 1 To Len(aCpoVal)
		oModel:SetValue('GFEA032_GWD', aCpoVal[nCount][1], aCpoVal[nCount][2])
	Next nCount

Return

Function GFEA519BAR()
	Local aItems 		:= {}
	Local cJustifica	:= ""
	Local oPanel
	Private oDlgJust
	Private lAcao := .F.
	// Habilitar quando na configuração da operação, campo "GVJ_REPROV" == “2=Informar Controle Pátio” e 
	// situação de aprovação do ponto estiver reprovada GX4_SIT=”3”
	If _aAtuPC[1] != GX4->GX4_CDPTCT .Or. _aAtuPC[2] != GX4->GX4_SEQ
		Help( ,, 'HELP',, "Somente o Ponto de Controle " + cValToChar(_aAtuPC[1]) + ", que está corrente, pode ser alterado.", 1, 0)
		Return .F.
	EndIf
	If GX4->GX4_SIT == "3"

		dbSelectArea("GX3")
		GX3->( dbSetOrder(1) )
		If GX3->( dbSeek(xFilial("GX3") + GX4->GX4_NRMOV) )
			
			dbSelectArea("GVI")
			GVI->( dbSetOrder(1) ) // GVI_FILIAL+GVI_CDOPER+GVI_SEQ
			If GVI->( dbSeek(xFilial("GVI") + GX3->GX3_CDOPER + GX3->GX3_SEQ) )
			
				dbSelectArea("GVJ")
				GVJ->( dbSetOrder(1) )
				If GVJ->( dbSeek(xFilial("GVJ") + GVI->GVI_CDOPER + GVI->GVI_SEQ + GX4->GX4_SEQ ) )
					If GVJ->GVJ_REPROV == "2" .Or. GVJ->GVJ_REPROV == "3"
						aItems := {'Cancelar','Continuar','Voltar para o ponto anterior'}
						cCombo := aItems[1]

						DEFINE DIALOG oDlgJust TITLE "Avaliar Reprovação" FROM 150,110 TO 380,500 PIXEL

						@ 000, 000 MsPanel oPanel Of oDlgJust Size 100, 100
						oPanel:Align := CONTROL_ALIGN_ALLCLIENT

						@ 05,5 SAY "Reprovação" SIZE 50,8 OF oPanel PIXEL
						oCombo := TComboBox():New(12,05,{|u|if(pCount() > 0, cCombo := u, cCombo) }, aItems,100,20,oDlgJust,,/*{||Alert('Mudou item da combo')}*/,,,,.T.,,,,,,,,,'cCombo')

						@ 30,5 SAY "Justificativa" SIZE 50,8 OF oPanel PIXEL
							//@ 32,5 MSGET oJustifica VAR cJustifica MESSAGE "" Picture "@!" SIZE 99,60 OF oPanel PIXEL //"Digite o Tempo em Milisegundos"
							//oJustifica:= TMultiGet():New(150,05,{|u| IIf(Pcount()>0,cJustifica:= u,cJustifica)},oDlgJust,140,60, /*<oFont>*/, .T. /*<.hscroll.>*/, CLR_BLACK/*<nClrFore>*/, /*<nClrBack>*/, /*<oCursor>*/, .T./*<.pixel.>*/, /*<cMsg>*/, /*<.update.>*/,.T., /*<.lCenter.>*/, /*<.lRight.>*/, .T./*<.readonly.>*/, /*<{uValid}>*/, /*[\{|nKey, nFlags, Self| <uChange>\}]*/, /*<.lDesign.>*/, .f./*[<.lNoBorder.>]*/, .F./*[<.lNoVScroll.>]*/ )
						oJustifica:= TMultiget():New(37,05,{|u|if(pCount() > 0, cJustifica := u, cJustifica) },oDlgJust,140,60,,,,,,.T.,,.T.,{|| .T.},,,,,,,,)//,.T.,.T.)

						DEFINE SBUTTON oSBtnEnd FROM 100, 05 TYPE 01 OF oDlgJust ENABLE ACTION GFEA519BAJ(cJustifica, cCombo)
							
						ACTIVATE DIALOG oDlgJust CENTERED
					Else
						MsgAlert("A reprovação dessa configuração de operação não pode ser avaliada pelo Controle de Pátio.","Aviso")
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		MsgAlert("Situação do Ponto não está reprovada.","Aviso")
	EndIf

Return lAcao

Function GFEA519BPC()
	Local wnrel
	Local lPassa
	Local cString 	:= "GVH"
	Local cTitulo  	:= "Impressão de Checklist"
	Local cPrograma	:= "CHECKLIST"
	Local cTamanho	:= "M"
	Private aReturn 	:= { "", 1, "", 1, 2, 1, "", 1 }
/*
	// INICIO - Verifica se tem PERGUNTAS relacionadas com PONTO DE CONTROLE
	dbSelectArea("GX4")
	GX4->( dbSetOrder(4) )
	GX4->( dbSeek(xFilial("GX4") + GX3->GX3_NRMOV) )
	While !GX4->( Eof() ) .And. GX4->GX4_FILIAL == xFilial("GX4") .And. GX4->GX4_NRMOV == GX3->GX3_NRMOV
	*/
	dbSelectArea("GVH")
	GVH->( dbSetOrder(2) )
	If !GVH->( dbSeek(xFilial("GVH") + GX4->GX4_CDPTCT ) )
		lPassa := .F.
		MsgAlert('Não existe Perguntas (Checklist) no Ponto de Controle do Movimento.','Aviso')
	Else
		lPassa := .T.
	EndIf
	/*	
		GX4->( dbSkip() )
	EndDo	
	// FIM - Verifica se tem PERGUNTAS relacionadas com PONTO DE CONTROLE 
	*/
	
	If lPassa
		wnrel := SetPrint(cString,cPrograma,"",@cTitulo,"", "", "",.F.,.F.,.F.,cTamanho,,.F.)
		
		If nLastkey == 27
			Return
		EndIf
		
		SetDefault(aReturn,cString)
		
		If nLastkey == 27
			Return
		EndIf
		/*
		dbSelectArea("GX4")
		GX4->( dbSetOrder(4) )
		GX4->( dbSeek(xFilial("GX4") + GX3->GX3_NRMOV) )
		While !GX4->( Eof() ) .And. GX4->GX4_FILIAL == xFilial("GX4") .And. GX4->GX4_NRMOV == GX3->GX3_NRMOV
		*/
		RptStatus({|lEnd| RelCheck(@lEnd,wnRel,cString,cTamanho,cPrograma,GX4->GX4_NRMOV,GX4->GX4_CDPTCT)},cTitulo)
		/*
			GX4->( dbSkip() )
		EndDo
		*/
	EndIf
	
Return

/*/{Protheus.doc} GFEA519BAJ
description
@type function
@version  
@author unknown
@since 14/01/2021
@param cJustifica, character, Justificativa para 
@param cCombo, character, param_description
@return lRet, True=OK, False=Problema
/*/
Function GFEA519BAJ(cJustifica, cCombo)
	Local lRet := .F.
	If AllTrim(cJustifica) <> ""
		If cCombo == 'Cancelar'
			// Cancelar  -> GX3_SIT da movimentação corrente deve utilizar o status "Cancelado"
			RecLock("GX3", .F.)
			GX3->GX3_SIT := "5"
			MsUnlock("GX3")
			lRet := .T.
		EndIf

		If cCombo == 'Continuar'
			// Continuar -> GX4_SIT do ponto de controle da movimentação como aprovado
			RecLock("GX4", .F.)
			GX4->GX4_SIT := "2"
			MsUnlock("GX4")
			
			// Se todos os registros da GX4 forem iguais a 2=Aprovado, o registro pai da GX3 deve ser 6=Concluido
			GFEA519SIT()

			lRet := .T.
		EndIf

		If cCombo == 'Voltar para o ponto anterior'
			// Voltar para o ponto anterior ->
			GFEA519BRP()
		EndIf

		RecLock("GX4",.F.)
			// Gravar justificativa no campo GX4_REPOBS
		GX4->GX4_REPOBS := cJustifica
			// gravar usuário corrente no campo GX4_REPUSU
		GX4->GX4_REPUSU := cUserName
		MsUnlock("GX4")
		
		If Type("oBrwGX3") == "O"
			oBrwGX3:Refresh()
			oBrwGX4:Refresh()
		EndIf
		If Type("lAcao") == "L"
			lAcao := .T.
		EndIf
		If Type("oDlgJust") == "O"
			oDlgJust:End()
		EndIf
	Else
		MsgAlert('Informe uma Justificativa', 'Aviso')
	EndIf
	
Return lRet

/*/{Protheus.doc} GFEA519SIT
Atualiza a GX3 (Movimentação) para ficar com situação 6=Concluido, se todos os registros da GX4 (tabela filha, Movimentação Ponto Controle) estiverem como 2=Aprovado
@type function
@version  
@author André Eduardo Pérez Álvarez
@since 15/01/2021
@return Null, Null
/*/
Static Function GFEA519SIT()

	Local lAllAproved := .F.	// Teste de hipótese: todos os registros filhos da GX4 estão aprovados (True=Sim); caso cxontrário, False=Não.
	Local aAreaGX4 := GX4->(GetArea())
	Local cAliasGX4 := GetNextAlias()

	// Existe pelo menos 1 registro diferente de 2=Aprovado ?
	
	BeginSql Alias cAliasGX4
		SELECT 1
		FROM %Table:GX4% GX4
		WHERE GX4.GX4_FILIAL = %xFilial:GX4%
		AND GX4.GX4_NRMOV = %Exp:_cMov%
		AND GX4.%NotDel%
		AND GX4.GX4_SIT <> '2'
	EndSql
	
	If (cAliasGX4)->(Eof())
		lAllAproved := .T.
	EndIf
	(cAliasGX4)->(dbCloseArea())
	
	RestArea(aAreaGX4)	

	If lAllAproved
		RecLock("GX3", .F.)
		GX3->GX3_SIT := "6"
		MsUnlock("GX3")
	EndIf
	
Return Nil

// Funcao acessada via "Modo Edicao" do Configurador do Banco de Dados
Function GFEA519BW2(cCDPTCT)
	Local lRet
	Local aAreaGVF := GVF->(GetArea())
	Default cCDPTCT := ""
	
	// Valida GX4_VLTARA verificando se campo GVF_IDTARA
	// 1=Não informar						Não permitir a edição do campo.
	// 2=Informada 						Deve ser informado pelo usuário.
	// 3=Veículo ou Tipo de Veículo		Não permitira edição do campo, mas atribuir ao mesmo o valor da tara do veículo 
	//			(GU8) preferencialmente, ou do tipo de veículo (GV3), do primeiro veículo da movimentação corrente (GX6)
	If cCDPTCT <> ""
		cAux := cCDPTCT
	Else
		cAux := GX4->GX4_CDPTCT
	EndIf
		
	dbSelectArea("GVF")
	GVF->( dbSetOrder(1) )
	If GVF->( dbSeek(xFilial("GVF") + cAux ) )
		If GVF->GVF_IDTARA $ "1,3"
			lRet := .F.
		Else
			lRet := .T.
		EndIf
	EndIf
	
	RestArea(aAreaGVF)
Return lRet

Function GFEA519BVA(cFil, cNRMOV)
	Local nPBT := 0

	dbSelectArea("GX6")
	GX6->( dbSetOrder(1) )
	GX6->( dbSeek(cFil+GX3->GX3_NRMOV) )
	While !GX6->( Eof() ) .And. xFilial("GX6") == GX6->GX6_FILIAL .And. GX6->GX6_NRMOV == GX3->GX3_NRMOV
		// GU8	Veiculos	
		dbSelectArea("GU8")
		GU8->( dbSetOrder(1) )
		If GU8->( dbSeek(xFilial("GU8")+GX6->GX6_CDVEIC) )

			If GU8->GU8_TARA == 0
				// GV3 - Tipos de Veiculos
				dbSelectArea("GV3")
				GV3->( dbSetOrder(1) )
				If GV3->( dbSeek(xFilial("GV3")+GU8->GU8_CDTPVC) )
					nPBT := GV3->GV3_PBT
				EndIf
			Else
				nPBT := GU8->GU8_PBT
			EndIf

		EndIf
		
		GX6->( dbSkip() )
	EndDo
	
		
Return nPBT

//adiciona os documentos relacionados pelos romaneio do agendamentos
Function GFE519REL(oView)
	Local oModel	:= oView:GetModel()
	Local oModGX4 := oModel:GetModel("GFEA519B_GX4")
	Local oModGXA := oModel:GetModel("GFE519BGXA")
	Local cQuery := ""
	Local cAliasT := GetNextAlias()
	Local lCpoSrGXA := GfeVerCmpo({"GXA_SDOC"})
	
	cQuery += "SELECT DISTINCT"
	cQuery += "	GW1_FILIAL,"
	cQuery += "	GW1_CDTPDC,"
	cQuery += "	GW1_EMISDC,"
	cQuery += "	GW1_SERDC,"
	cQuery += "	GW1_NRDC" + If(lCpoSrGXA,", GW1_SDOC ","")

	cQuery += "	FROM " + RetSqlName("GWV") + " GWV"
		
	cQuery += "	INNER JOIN " + RetSqlName("GWN") + " GWN"
	cQuery += "	ON GWN.GWN_FILIAL = GWV.GWV_FILIAL"
	cQuery += "	AND GWV.GWV_NRROM = GWN.GWN_NRROM"
		
	cQuery += "	INNER JOIN " + RetSqlName("GW1") + " GW1"
	cQuery += "	ON GW1.GW1_FILIAL = GWV.GWV_FILIAL"
	cQuery += "	AND GW1.GW1_NRROM = GWN.GWN_NRROM"
		
	cQuery += "	WHERE GWV.D_E_L_E_T_ = ''"
	cQuery += "	AND GWV.GWV_FILIAL = '" + xFilial('GWV') + "'"
	cQuery += "	AND GWV.GWV_NRMOV  = '" + oModGX4:GetValue("GX4_NRMOV") + "'"
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cAliasT, .F., .T.)
	(cAliasT)->(dbGoTop())
	
	If (cAliasT)->(Eof())
		Help(,,'HELP',,"Não há documentos relacionados ao romaneio do agendamento.",1,0)
		Return .F.
	EndIf
	
	While !(cAliasT)->(Eof())
		If !oModGXA:SeekLine({{"GXA_FILIAL",(cAliasT)->GW1_FILIAL	},;
				{"GXA_CDTPDC"	,(cAliasT)->GW1_CDTPDC	},;
				{"GXA_EMISDC"	,(cAliasT)->GW1_EMISDC	},;
				{"GXA_SERDC"	,(cAliasT)->GW1_SERDC	},;
				{"GXA_NRDC"	,(cAliasT)->GW1_NRDC		}})
			
			If !oModGXA:IsEmpty()
				oModGXA:AddLine()
			EndIf
			
			oModGXA:SetValue('GXA_FILIAL'	,(cAliasT)->GW1_FILIAL)
			oModGXA:SetValue('GXA_CDTPDC'	,(cAliasT)->GW1_CDTPDC)
			oModGXA:SetValue('GXA_EMISDC'	,(cAliasT)->GW1_EMISDC)
			oModGXA:SetValue('GXA_SERDC'	,(cAliasT)->GW1_SERDC)
			oModGXA:SetValue('GXA_NRDC'		,(cAliasT)->GW1_NRDC)
			If lCpoSrGXA
				oModGXA:SetValue('GXA_SDOC'	,(cAliasT)->GW1_SDOC)
			EndIf
			
			If !oModGXA:VldLineData()
				Help(,,'HELP',,"Doc " + AllTrim((cAliasT)->GW1_NRDC) + ": " + oModel:Geterrormessage(.T.)[6],1,0)
				Exit
			EndIf
			
		EndIf
		(cAliasT)->(dbSkip())
	EndDo
	(cAliasT)->(dbCloseArea())
Return

// Prepara campos para chamar tela de escolha de Doc. Carga, caso exista mais de um com as seguintes chaves em parâmetro
Static Function GFE519PreT(oModelGXA)
	Local nLine		:= oModelGXA:GetLine()
	Local cTpDc		:= oModelGXA:GetValue("GXA_CDTPDC")
	Local cEmiDc		:= oModelGXA:GetValue("GXA_EMISDC")
	Local cSerDc		:= oModelGXA:GetValue("GXA_SERDC")
	Local cNrDc		:= oModelGXA:GetValue("GXA_NRDC")
	Local oView     	:= FWViewActive()
	Local aRet			:= {}
	
	If TamSx3("GWW_SERDC")[1] == 14
		aRet := GFE517TLDC( cNrDc , cTpDc , cEmiDc , cSerDc )

		If Len(aRet) > 0
			If !oModelGXA:IsDeleted()
				oModelGXA:GoLine( nLine )
				
				oModelGXA:SetValue('GXA_CDTPDC',	aRet[6])
				oModelGXA:SetValue('GXA_EMISDC',	aRet[2])
				oModelGXA:SetValue('GXA_SERDC',		aRet[4])
				oModelGXA:SetValue('GXA_NRDC',		aRet[5])
			EndIf
		
			oView:Refresh()
		EndIf
	EndIf
		
Return Nil

/* Função para executar bloco cadastrado na pergunta 
  Chamada ao alterar resposta movto x pto controle x pergunta - GX5_RESPOS
  grava parametros identicadores da gx5 aParam para gerar NJS
  executar bloco cadastrado na pergunta GVG_CODBLK se houver ação a ser tomada conforme 
  GVH_CODBLT //1-Não,2-Opc,3-Obrig
@param:     	oModel	    Recebe o oMOdel principal
@return:    .t.
@author:    Equipe AgroIndustria
@since:     01/2017
@Uso:       GFEA519B */

Function GFEA519LVA(oModelGX5)
	Local cPtoCtl := oModelGX5:GetValue("GX5_CDPTCT")
	Local cPerg   := oModelGX5:GetValue("GX5_CDPERG")
	Local cResp   := oModelGX5:GetValue("GX5_RESPOS")
	Local lRet    := .T.
	Local lReFnc
	Private aParam

	IF TYPE('M->GX5_RESPOS') == 'C'
	
		If M->GX5_RESPOS <> cResp //Alterou o conteúdo
			
			cExec := Posicione('GVH',1,xFilial('GVH') + cPerg + cPtoCtl ,'GVH_CODBLT') //1-Não,2-Opc,3-Obrig
			cAcao := Posicione('GVG',1,xFilial('GVG') + cPerg ,'GVG_CODBLK')
			aParam := {oModelGX5:GetValue("GX5_FILIAL"),oModelGX5:GetValue("GX5_NRMOV"),cPtoCtl,oModelGX5:GetValue("GX5_SEQ"),cPerg,M->GX5_RESPOS}
			
			If cExec >= '2' .and. !empty(cAcao)
			
				If MsgYesNo("Item possui ação relacionada. Deseja executar?") //"Item possui ação relacionada. Deseja executar?"
					lReFnc := GFE519BLK(cAcao)
					If !lReFnc
						lRet := .F.
						Help( ,, "AJUDA",, "Retorno da ação relacionada não permite alteração de valor", 1, 0) //AJUDA,'Retorno da ação relacionada não permite alteração de valor'
					EndIf
				Else
					IF cExec == '3'
						lRet := .F.
						Help( ,, "AJUDA",, "Valor deve ser alterado através da Ação Relacionada", 1, 0) //'Valor deve ser alterado através da Ação Relacionada'
					EndIf
				EndIF
				
			EndIf
		EndIF
	EndIf

	
Return lRet


/* Função para executar  bloco cadastrado na pergunta 
@param:     
@return:    .t.
@author:    Equipe AgroIndustria
@since:     01/2017
@Uso:       GFEA519LVA */
Function GFE519BLK(cExecBlk)
      
	Local uRetExBlk   := NIL
	Local bExecBlk    := Nil
            
	If (("{" $ cExecBlk) .AND. ("}" $ cExecBlk) .AND. ("|" $ cExecBlk))
		cExecBlk := AllTrim(cExecBlk)
	Else
		cExecBlk := "{ || "+ IIf(Empty(cExecBlk),".T.",AllTrim( cExecBlk)) +" }"
	EndIf
      
	bExecBlk    := &( cExecBlk )
	uRetExBlk := Eval( bExecBlk, aParam )
      	
Return uRetExBlk

////////////////////////////////////////////////////////////////
//	Função incluida para validar se a Data de entrada		  //
//	foi informa monstrando mensagem de que o campo é          //
// obrigatorio para execução do CheckList. 					  //
///////////////////////////////////////////////////////////////

Function GFEA519GX5(oModelGX5)
	Local cNrMov  := oModelGX5:GetValue("GX5_NRMOV")
	Local cCdPto  := oModelGX5:GetValue("GX5_CDPTCT")
	Local cSeq    := oModelGX5:GetValue("GX5_SEQ")
	Local cChave  := cNrMov + cCdPto + cSeq
	
	GX5->( dbSetOrder(1))
	GX4->( dbSetOrder(1))
	
	If GX4->(dbSeek(xFilial("GX4")+cChave))


		If Empty(GX4->GX4_DTENTR)

			Help( ,, 'HELP',, "Antes de realizar o Check-list é necessário registrar a data de entrada do Veículo (GX4_DTENTR)", 1, 0)
			Return .F.
				
		EndIf
		
	EndIf
Return
 