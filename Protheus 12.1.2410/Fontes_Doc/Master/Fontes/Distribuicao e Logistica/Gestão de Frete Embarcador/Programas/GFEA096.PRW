#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static __lLogIntP := IIF(SuperGetMv("MV_GFELPR",,'1') == '2',.F., .T.) //Indica se será gerado ou não o log da integração com o ERP Protheus

// Constante usada na função AddToLog()
#DEFINE _LOG_END   2
 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA096
Lotes Provisão


@sample
GFEA096()

@author Siegklenes.Beulke
@since 09/01/2014 
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA096()
	
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GXE") // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA096") // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Lotes de Provisão Contábil")
	
	oBrowse:AddLegend("GXE_SIT=='1'", "WHITE"	, "Não Enviado") 
	oBrowse:AddLegend("GXE_SIT=='2'", "YELLOW"	, "Enviado") 
	oBrowse:AddLegend("GXE_SIT=='3'", "GRAY"	, "Rejeitado") 
	oBrowse:AddLegend("GXE_SIT=='4'", "GREEN"	, "Atualizado")
	oBrowse:AddLegend("GXE_SIT=='5'", "RED"		, "Pendente Estorno")
	oBrowse:AddLegend("GXE_SIT=='6'", "BLACK"	, "Estornado")
	oBrowse:AddLegend("GXE_SIT=='7'", "ORANGE"	, "Pendente Estorno Parcial")
	oBrowse:AddLegend("GXE_SIT=='8'", "BLUE"	, "Estornado Parcial")
		
	oBrowse:Activate()
	
Return Nil

Static Function MenuDef()
	Local aRotina := {}

	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE "Pesquisar" 	ACTION "AxPesqui"			OPERATION 1  ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.GFEC096"	OPERATION 2  ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 		ACTION "VIEWDEF.GFEA096"	OPERATION 3  ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" 		ACTION "VIEWDEF.GFEA096"    OPERATION 4  ACCESS 0
	ADD OPTION aRotina TITLE "Montar Lote" 	ACTION "GFEA096MNT()"	    OPERATION 4  ACCESS 0
	ADD OPTION aRotina TITLE "Integrar ERP"	ACTION "GFEA096ATU()"	    OPERATION 4  ACCESS 0
	ADD OPTION aRotina TITLE "Estornar ERP"	ACTION "GFEA096DES()"	    OPERATION 4  ACCESS 0
	
	If GFEA105ATV()
		//Se o tipo de estorno for Parcial e integrado ao Datasul
		If SuperGetMv('MV_TPEST',, '1') == "2" .And. SuperGetMv('MV_ERPGFE',, '1') == "1"
			ADD OPTION aRotina TITLE "Gerar Sublote Estorno" 	ACTION "GFEA105( GXE->GXE_PERIOD )"						OPERATION 4  ACCESS 0
			ADD OPTION aRotina TITLE "Desatualizar Sublote ERP"	ACTION "GFEA105DET( GXE->GXE_FILIAL,GXE->GXE_CODLOT )"	OPERATION 4  ACCESS 0
			ADD OPTION aRotina TITLE "Excluir Sublote Estorno"  ACTION "GFEA105DEL( GXE->GXE_FILIAL,GXE->GXE_CODLOT )"  OPERATION 5  ACCESS 0
		EndIf
	EndIf
	
	ADD OPTION aRotina TITLE "Excluir" 	ACTION "GFEA096EXC()"	OPERATION 5  ACCESS 0
	ADD OPTION aRotina TITLE "Vis. Detalhada" 	ACTION "VIEWDEF.GFEA096A"	OPERATION 2  ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir" ACTION "VIEWDEF.GFEA096"	OPERATION 8  ACCESS 0

Return aRotina

Static Function ModelDef()
	Local oModel
	Local oStructGXF := FWFormStruct(1, "GXF")
	Local oStructGXD := FWFormStruct(1, "GXD")
	Local oEvent  := GFEA096OBS():New()
	
	If GFEA105ATV()
		oStructGXN := FWFormStruct(1, "GXN")
	EndIf
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA096", /*bPré*/, /*bPost*/,/*bCommit*/, /*bCancel*/)
	oModel:InstallEvent("GFEA096OBS", /*cOwner*/, oEvent)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:SetVldActivate({|oModel|GFEA096PRE(oModel)})
	oModel:AddFields("GFEA096_GXE", Nil, FWFormStruct(1,"GXE"),/*bPre*/,{|oModel|GFEA096POS(oModel)},/*bLoad*/)
	oModel:SetPrimaryKey({"GXE_FILIAL", "GXE_CODLOT"})
	
	oModel:AddGrid("GFEA096_GXF","GFEA096_GXE", oStructGXF,/*bLinePre*/,/*blinepost*/,,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA096_GXF",{{"GXF_FILIAL","GXE_FILIAL"},{"GXF_CODLOT","GXE_CODLOT"}},"GXF_FILIAL+GXF_CODLOT")
	
	oModel:AddGrid("GFEA096_GXD","GFEA096_GXE", oStructGXD,/*bLinePre*/,/* Pos*/,,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA096_GXD",{{"GXD_FILIAL","GXE_FILIAL"},{"GXD_CODLOT","GXE_CODLOT"}},"GXD_FILIAL+GXD_CODLOT")
	
	If GFEA105ATV()
		oModel:AddGrid("GFEA096_GXN","GFEA096_GXE",oStructGXN,/*bLinePre*/, /*{|oX|GFEA015BRW(oX)}*/ ,/*bPre*/,/*bPost*/,/*bLoad*/)
		oModel:SetRelation("GFEA096_GXN",{{"GXN_FILIAL","GXE_FILIAL"},{"GXN_CODLOT","GXE_CODLOT"}},"GXN_FILIAL+GXN_CODLOT+GXN_CODEST")
	EndIf
		
	oModel:GetModel("GFEA096_GXF"):SetOptional(.T.)
	oModel:GetModel("GFEA096_GXD"):SetOptional(.T.)
	oModel:GetModel("GFEA096_GXF"):SetUniqueLine({"GXF_CODLOT","GXF_SEQ"})
	If GFEA105ATV()
		oModel:GetModel("GFEA096_GXN"):SetOptional(.T.)
	EndIf
	
	oModel:AddCalc('CALCGXF_VLR', 'GFEA096_GXE', 'GFEA096_GXF', 'GXF_VALOR', 'TOTVALOR', 'SUM',,,'Valor Lote' )
	If GFEA105ATV()
		oModel:AddCalc('CALCGXF_VLR', 'GFEA096_GXE', 'GFEA096_GXF', 'GXF_VALOR', 'TOTVALOR2', 'FORMULA',,,'Saldo',{ || GFA096SAL( GXE->GXE_CODLOT ) },15,2 )
	EndIf
	
Return oModel

Static Function ViewDef()
	Local oView := FWFormView():New()	
	Local oStructGXE := FWFormStruct(2, "GXE")
	Local oModel := FWLoadModel("GFEA096")
	
	oStructGXE:AddGroup("GrpId" , "Geral", "", 2)
	oStructGXE:AddGroup("GrpCon", "Controle", "", 2)
	
	oStructGXE:SetProperty("GXE_CODLOT"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_CODLOT"	,MVC_VIEW_ORDEM, "01")
	oStructGXE:SetProperty("GXE_DTCRIA"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_DTCRIA"	,MVC_VIEW_ORDEM, "02")
	oStructGXE:SetProperty("GXE_FILDE"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_FILDE"	,MVC_VIEW_ORDEM, "03")
	oStructGXE:SetProperty("GXE_FILATE"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_FILATE"	,MVC_VIEW_ORDEM, "04")
	oStructGXE:SetProperty("GXE_PERIOD"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_PERIOD"	,MVC_VIEW_ORDEM, "05")
	oStructGXE:SetProperty("GXE_DTDE"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_DTDE"	,MVC_VIEW_ORDEM, "06")
	oStructGXE:SetProperty("GXE_DTATE"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_DTATE"	,MVC_VIEW_ORDEM, "07")
	oStructGXE:SetProperty("GXE_CDEMIT"	,MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGXE:SetProperty("GXE_CDEMIT"	,MVC_VIEW_ORDEM, "08")
	oStructGXE:SetProperty("GXE_SIT"	,MVC_VIEW_GROUP_NUMBER, "GrpCon")
	oStructGXE:SetProperty("GXE_DTSIT"	,MVC_VIEW_GROUP_NUMBER, "GrpCon")
	oStructGXE:SetProperty("GXE_MOTIVO"	,MVC_VIEW_GROUP_NUMBER, "GrpCon")
	
	oView:SetModel(oModel)
	
	oView:AddField("GFEA096_GXE",oStructGXE)
	
	oView:CreateHorizontalBox( 'MASTER', 100 ) 
	
	oView:SetOwnerView("GFEA096_GXE",'MASTER')
Return oView

//Carrega o periodo de corte
Function GFEA096PER(lAtual)
	Local dPer := SuperGetMv("MV_DTULFE",.F.,DDATABASE)
	Local cRet := ""
	Local nAno 
	Local nMes 
	Default lAtual := .F.
	
	If Empty(dPer)
		dPer := DDATABASE
		nAno := Year(dPer)
		nMes := Month(dPer) - If(lAtual,0,1)
		If nMes <= 0
			nAno := nAno - 1
			nMes := 12
		EndIf
	Else
		nAno := Year(dPer)
		nMes := Month(dPer) 
	EndIf
	
	If nAno > 0 .And. nMes > 0
		If nMes + If(lAtual,0,1) > 12
			nAno := nAno + 1
			nMes := 1
		Else
			nMes := nMes + If(lAtual,0,1)
		EndIf
		cRet := Str(nAno,4) + "/" + StrZero(nMes,2)
	EndIf
	
Return cRet

Function GFEA096MNT()
	/*
		01 Finalidade Todos, Documento de Frete, Contrato com Autonomo
		02 Tipo Calc Todos, Estimativa, Romaneio
	*/
	If GXE->GXE_SIT != "1"
		MsgAlert('Não é possivel montar o lote após o primeiro envio ao ERP')
		Return
	EndIf
	
	If Pergunte("GFEA096A",.T.)
		RptStatus({||GFEA096MON(.T.)}, "Carregando", "Aguarde, carregando dados...")
	EndIf
Return

Function GFEA096MON(lProgress)
	Local aAreaGWF := GWF->(GetArea())
	Local aAreaGWF2
	Local aAreaGWJ := GWJ->(GetArea())
	Local aAreaGWH := GWH->(GetArea())
	Local aAreaGW4 := GW4->(GetArea())
	Local aAreaGW3 := GW3->(GetArea())
	Local aAreaGW6 := GW6->(GetArea())
	Local aAreaGWA := GWA->(GetArea())
	Local aAreaGXF := GXF->(GetArea())
	Local aAreaGWM := GWM->(GetArea())
	Local aAreaGXD := GXD->(GetArea())
	Local aAreaGXE := GXE->(GetArea())
	Local aAreaGW2 := GW2->(GetArea())
	Local aCalc := {}
	Local nX
	Local lVincCalc := .F.
	Local lSkip := .F.
	Local cGXE_PERIOD := ""
	Local aGWH
	Local aGXD := {}
	Local aGXF := {}
	Local aGWA := {}
	Local cTipoEst := SuperGetMv('MV_TPEST',, '1')
	Local s_GFEI15 := SuperGetMV('MV_GFEI15',,'3')
	Local cDataR
	Local c_GFEZ01 	:= SuperGetMV("MV_GFEZ01",,"1")
	Local cQuery	:= ""
	Local cAliGWF	:= ""
	Local nTotGWF	:= 0
	Local nI		:= 0
		
	Default lProgress := .F.

	If c_GFEZ01 == "1"
		dbSelectArea("GXF")
		GXF->(dbSetOrder(1))
		
		If GXF->(dbSeek(GXE->GXE_FILIAL+GXE->GXE_CODLOT)) .And. !Empty(GXF->GXF_SEQ)
			MsgAlert('Os lançamentos de provisão já foram processados')
			Return
		EndIf
		
		dbSelectArea("GWF")
		GWF->(dbSetOrder(1))
		
		dbSelectArea("GXE")
		GXE->(dbSetOrder(1))
		
		dbSelectArea("GWM")
		GWM->(dbSetOrder(1))
		
		dbSelectArea("GWJ")
		GWJ->(dbSetOrder(1))
		
		dbSelectArea("GWH")
		GWH->(dbSetOrder(1))//		GWH_FILIAL+GWH_NRCALC+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC
		
		dbSelectArea("GW4")
		GW4->(dbSetOrder(2))//		GW4_FILIAL+GW4_EMISDC+GW4_SERDC+GW4_NRDC+GW4_TPDC
		
		dbSelectArea("GW3")
		GW3->(dbSetOrder(1))//		GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS)
		
		dbSelectArea("GW6")
		GW6->(dbSetOrder(1))//		GW6_FILIAL+GW6_EMIFAT+GW6_SERFAT+GW6_NRFAT+DTOS(GW6_DTEMIS)
		
		dbSelectArea("GW2")
		GW2->(dbSetOrder(1))
		
		dbSelectArea("GWA")
		GWA->(dbSetOrder(3))
		
		dbSelectArea("GXD")
		GXD->(dbSetOrder(2))
		
		GWF->(dbSeek(GXE->GXE_FILDE))
		
		If lProgress
			SetRegua(If(Int(GWF->(RecCount()) - GWF->(RECnO())) >=0, Int(GWF->(RecCount()) - GWF->(RECnO())), 5))
		EndIf
	
		While !GWF->(Eof()) .And. GWF->GWF_FILIAL >= GXE->GXE_FILDE .And. GWF->GWF_FILIAL <= GXE->GXE_FILATE
			lVincCalc := .F.
			lSkip := .F.
			
			If lProgress
				IncRegua()
			EndIf
			
			//---------- Validações impeditivas/Parâmetros
			If !(GWF->GWF_TPCALC $ "1;2;6;8;4;5;7")
				GWF->(dbSkip())
				Loop
			EndIf
			
			If !( GWF->GWF_DTCRIA >= GXE->GXE_DTDE .And. GWF->GWF_DTCRIA <= GXE->GXE_DTATE )
				GWF->(dbSkip())
				Loop
			EndIf
				
			//Somente Cálculos com finalidade de documento de frete
			If MV_PAR01 == 2 .And. !( GWF->GWF_FINCAL  $ "1;2")
				GWF->(dbSkip())
				Loop 
			EndIf
			
			//Somente Cálculos com finalidade de documento de contrato
			If MV_PAR01 == 3 .And. GWF->GWF_FINCAL != "3"
				GWF->(dbSkip())
				Loop 
			EndIf
			
			//Somente Cálculos Estimativa
			If MV_PAR02 == 2 .And. GWF->GWF_TPCALC != "8"
				GWF->(dbSkip())
				Loop 
			EndIf
			
			//Somente Cálculos Normal/Redespacho
			If MV_PAR02 == 3 .And. !(GWF->GWF_TPCALC $ "1;6")
				GWF->(dbSkip())
				Loop 
			EndIf
			
			//Somente Cálculos de Devolução/Serviço/Reentrega
			If MV_PAR02 == 4 .And. !(GWF->GWF_TPCALC $ "4;5;7")
				GWF->(dbSkip())
				Loop 
			EndIf
			
			If MV_PAR03 <> 1 //Se o Tipo Contab for diferente de Ambos.
				
				// Valida o parâmetro "Tipo Contab?"
				cAliasGV5 := GetNextAlias()
				cQuery := " SELECT GV5_FRCTB FROM " + RetSqlName ( "GV5" ) + " GV5 " 
				cQuery += " INNER JOIN " + RetSQLName( "GWH" ) + " GWH "
				cQuery += " ON GV5.GV5_CDTPDC = GWH.GWH_CDTPDC "
				cQuery += " AND GV5.D_E_L_E_T_ = ' '"
				cQuery += " AND GWH.D_E_L_E_T_ = ' '"
				cQuery += " AND GWH.GWH_NRCALC = '" + GWF->GWF_NRCALC + "'"
				cQuery += " AND GWH.GWH_FILIAL = '" + GWF->GWF_FILIAL + "'"
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGV5, .F., .T.)
				
				If (cAliasGV5)->( !Eof() )
				
					//Se parâmetro estiver setado como Custo e Tipo Contab diferente de Custo
					If MV_PAR03 == 2 .AND. (cAliasGV5)->GV5_FRCTB <> "2"
						lSkip := .T.
					EndIf
			
					//Se parâmetro estiver setado como Despesa e Tipo Contab diferente de Despesa
					If MV_PAR03 == 3 .AND. (cAliasGV5)->GV5_FRCTB <> "1"
						lSkip := .T.
					EndIf
				EndIf
				
				(cAliasGV5)->( dbCloseArea() )
				
				If lSkip
					lSkip := .F.
						GWF->(dbSkip())
						Loop
					EndIf
				EndIf
			
			//---------- Validações impeditivas/Fixos
			
			// Já está relacionado a uma pré-fatura
			If s_GFEI15 != '3' .And. !Empty( GWF->GWF_NRPREF ) .And. GWJ->( dbSeek( GWF->GWF_FILIAL + GWF->GWF_NRPREF ) )
				GWF->(dbSkip())
				Loop
			EndIf
			
			//Documentos de Carga relacionados a contrato de autonomos com fatura atualizada no contas a pagar
			If !Empty(GWF->GWF_NRCONT) .And. GW2->(dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCONT)) .And. GW2->GW2_SITFIN $ "2;4"
				GWF->(dbSkip())
				Loop
			EndIf
			
			// Possui um lote cancelado/estornado dentro do mesmo período do lote atual
			// Evitando duplicações de cálculo
			cGXE_PERIOD := GXE->GXE_PERIOD
			If GXD->(dbSeek(GWF->(GWF_FILIAL+GWF_NRCALC)))
			
				If cTipoEst == "2" //Tipo Estorno Parcial
					lSkip := .T.
				EndIf
				
				While !lSkip .And. !GXD->(Eof()) .And. GWF->(GWF_FILIAL+GWF_NRCALC) == GXD->(GXD_FILCAL+GXD_NRCALC)
					If GXE->(dbSeek(GXD->(GXD_FILIAL + GXD_CODLOT)))
						If cGXE_PERIOD == GXE->GXE_PERIOD;
							.And. GXE->GXE_SIT != "6"
							lSkip := .T.
							Exit
						EndIf
					EndIf
					
					GXD->(dbSkip())
				EndDo
			EndIf
			RestArea(aAreaGXE)
			If lSkip
				GWF->(dbSkip())
				Loop
			EndIf
			
			//If GFA105GWH( GWF->GWF_NRCALC, GWF->GWF_FILIAL )//Cálculo relacionado a Documento de Frete atualizado
			cDataR := DtoS(GFA105GWH( GWF->GWF_NRCALC, GWF->GWF_FILIAL, .T. ))
			If !Empty(cDataR) .And. Alltrim(SubSTR(cDataR, 1, 4)) + "/" + Alltrim(SubSTR(cDataR, 5, 2)) <= GXE->GXE_PERIOD
				GWF->(dbSkip())
				Loop
			EndIf
			
			// Documentos de Carga relacionados a Documento de Frete com Fatura atualizada no Contas a Pagar
			// Guarda os documentos de carga para verificação posterior
			If GWF->GWF_TPCALC == '8' .And. GWH->(dbSeek(GWF->(GWF_FILIAL+GWF_NRCALC)))
				aGWH := {}
				While !GWH->(Eof()) .And. GWF->(GWF_FILIAL+GWF_NRCALC) == GWH->(GWH_FILIAL+GWH_NRCALC)
					aAdd(aGWH,GWH->(GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC))
					GWH->(dbSkip())
				EndDo
				
				dbSelectArea("GWH")
				GWH->(dbSetOrder(2))
				aAreaGWF2 := GWF->(GetArea())
				For nX := 1 to Len(aGWH)
					GWH->(dbSeek(aGWH[nX]))
					While !GWH->(Eof()) .And. aGWH[nX] == GWH->(GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC)
						If GWF->(dbseek(GWH->(GWH_FILIAL + GWH_NRCALC)));
							.And. GWF->GWF_DTCRIA >= GXE->GXE_DTDE .And. GWF->GWF_DTCRIA <= GXE->GXE_DTATE .And. GWF->GWF_TPCALC $ '1;6'
							lSkip := .T. // O cálculo já entrou ou vai entrar em outra interação
							Exit
						EndIf
						GWH->(dbSkip())
					EndDo
					If lSkip
						nX := Len(aGWH)
					EndIf
				Next nX
				RestArea(aAreaGWF2)
				dbSelectArea("GWH")
				GWH->(dbSetOrder(1))
			EndIf
			
			If lSkip
				GWF->(dbSkip())
				Loop
			EndIf
			
			// A montagem agrupada GWA_CTADEB+GWA_CCDEB+GWA_UNINEG
			If GWA->(dbSeek(GWF->GWF_FILIAL+If(GWF->GWF_TPCALC $ "1;2;6;4;5;7","1","4")+GWF->GWF_NRCALC))
				While !GWA->(Eof()) .And. GWA->GWA_FILIAL == GWF->GWF_FILIAL;
									.And. GWA->GWA_TPDOC == If(GWF->GWF_TPCALC $ "1;2;6;4;5;7","1","4");
									.And. AllTrim(GWA->GWA_NRDOC) == AllTrim(GWF->GWF_NRCALC)
					lVincCalc := .T.
					//	A despesa liquida/bruta é pelo parametro MV_PROVCON
					If (nX := aScan(aGXF,{|x| x[1] == GWA->GWA_CTADEB .And. x[2] == GWA->GWA_CCDEB .And. x[3] == GWA->GWA_UNINEG})) > 0
						aGXF[nX][4] += GWA->GWA_VLMOV
					Else
						aAdd(aGXF,{GWA->GWA_CTADEB,GWA->GWA_CCDEB,GWA->GWA_UNINEG,GWA->GWA_VLMOV})
					EndIf
					
					aAdd(aGWA,GWA->(RecNo()))
					GWA->(dbSkip())
				EndDo
			EndIf
			
			If lVincCalc
				aAdd(aCalc,{GWF->GWF_FILIAL,GWF->GWF_NRCALC})
			EndIf
			
			GWF->(dbSkip())
		EndDo
	Else
		For nI:= 1 To 3
			cAliGWF	:= GetNextAlias()
			
			If nI <> 3
				If nI == 1
					cQuery := "SELECT DISTINCT GWF.GWF_FILIAL, "
					cQuery += "GWF.GWF_NRCALC "
				ElseIf nI == 2
					cQuery := "SELECT DISTINCT GWA.GWA_CTADEB, "
					cQuery += "GWA.GWA_CCDEB, "
					cQuery += "GWA.GWA_UNINEG, "
					cQuery += "SUM(GWA.GWA_VLMOV) AS VLMOV"
				EndIf
								
				cQuery += "FROM " + RetSQLName("GWF") + " GWF "
				
				If MV_PAR03 <> 1 //Se o Tipo Contab for diferente de Ambos.
					cQuery += "INNER JOIN " + RetSQLName("GWH") + " GWH "
					cQuery += "ON GWH.GWH_NRCALC = GWF.GWF_NRCALC "
					cQuery += "AND GWH.GWH_FILIAL = GWF.GWF_FILIAL "
					cQuery += "AND GWH.D_E_L_E_T_ = '' "
					cQuery += "INNER JOIN " + RetSQLName("GV5") + " GV5 "
					cQuery += "ON GV5.GV5_CDTPDC = GWH.GWH_CDTPDC "
					cQuery += "AND GV5.D_E_L_E_T_ = '' "
				EndIf
				
				cQuery += "INNER JOIN " + RetSQLName("GWA") + " GWA "
				cQuery += "ON GWA.GWA_FILIAL = GWF.GWF_FILIAL "
				cQuery += "AND GWA.GWA_TPDOC = '1' "
				cQuery += "AND GWA.GWA_NRDOC = GWF.GWF_NRCALC "
				cQuery += "AND GWA.D_E_L_E_T_ = '' "
				
				cQuery += "WHERE GWF.GWF_FILIAL >= '" + GXE->GXE_FILDE + "' "
				cQuery += "AND GWF.GWF_FILIAL <= '" + GXE->GXE_FILATE + "' "
				cQuery += "AND GWF.GWF_DTCRIA >= '" + DToS(GXE->GXE_DTDE) + "' "
				cQuery += "AND GWF.GWF_DTCRIA <= '" + DToS(GXE->GXE_DTATE) + "' "
				
				If MV_PAR02 == 2
					cQuery += "AND GWF.GWF_TPCALC IN (1, 4, 5, 6, 7) "
				ElseIf MV_PAR02 == 3
					cQuery += "AND GWF.GWF_TPCALC IN (1, 6) "
				ElseIf MV_PAR03 == 4
					cQuery += "AND GWF.GWF_TPCALC IN (4, 5, 7) "
				Else
					cQuery += "AND GWF.GWF_TPCALC IN (1, 2, 4, 5, 6, 7, 8) "
				EndIf
				
				If MV_PAR01 == 2
					cQuery += "AND GWF.GWF_FINCAL IN (1, 2) "
				ElseIf MV_PAR01 == 3
					cQuery += "AND GWF.GWF_FINCAL <> '3' "
				EndIf
				
				If MV_PAR03 == 2
					cQuery += "AND GV5.GV5_FRCTB = '2' "
				ElseIf MV_PAR03 == 3
					cQuery += "AND GV5.GV5_FRCTB = '1' "
				EndIf
				
				If s_GFEI15 != '3'
					cQuery += "AND GWF.GWF_NRPREF = '' "
				EndIf
				
				cQuery += "AND GWA.GWA_SITCTB = '1' "
				
				cQuery += "AND GWF.D_E_L_E_T_ = '' "
				
				If nI == 2
					cQuery += "GROUP BY GWA.GWA_CTADEB, GWA.GWA_CCDEB, GWA.GWA_UNINEG"
				EndIf
			
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliGWF, .F., .T.)
				
				Count To nTotGWF
			
				(cAliGWF)->(dbGoTop())
				
				If lProgress
					SetRegua(nTotGWF)
				EndIf
				
				GWA->(dbSetOrder(1))
				
				nX := 1
				
				While !(cAliGWF)->(Eof())
					If lProgress
						IncRegua()
					EndIf
					
					If nI == 1
						RecLock("GXD",.T.)
							GXD->GXD_FILIAL	:= GXE->GXE_FILIAL
							GXD->GXD_CODLOT	:= GXE->GXE_CODLOT
							GXD->GXD_FILCAL	:= (cAliGWF)->GWF_FILIAL
							GXD->GXD_NRCALC	:= (cAliGWF)->GWF_NRCALC
						MsUnlock("GXD")
					ElseIf nI == 2
						RecLock("GXF",.T.)
							GXF->GXF_FILIAL := GXE->GXE_FILIAL
							GXF->GXF_CODLOT := GXE->GXE_CODLOT
							GXF->GXF_SEQ	:= nX
							GXF->GXF_CONTA	:= (cAliGWF)->GWA_CTADEB
							GXF->GXF_VALOR	:= (cAliGWF)->VLMOV
							GXF->GXF_TPLANC := "1"
							GXF->GXF_CCUSTO := (cAliGWF)->GWA_CCDEB
							GXF->GXF_UNINEG := (cAliGWF)->GWA_UNINEG	
						MsUnlock("GXF")
					EndIf		
					
					nX++
					
					(cAliGWF)->(dbSkip())
				EndDo			
			Else
				cQuery := "UPDATE " + RetSQLName("GWA") + " "
				cQuery += "SET GWA_CODLOT = '" + GXE->GXE_CODLOT + "' "
				cQuery += "FROM " + RetSQLName("GWA") + " GWA "
				cQuery += "INNER JOIN " + RetSQLName("GWF") + " GWF "
				cQuery += "ON GWF.GWF_FILIAL = GWA.GWA_FILIAL "
				cQuery += "AND GWF.GWF_NRCALC = GWA.GWA_NRDOC "
				
				If MV_PAR03 <> 1 //Se o Tipo Contab for diferente de Ambos.
					cQuery += "INNER JOIN " + RetSQLName("GWH") + " GWH "
					cQuery += "ON GWH.GWH_NRCALC = GWF.GWF_NRCALC "
					cQuery += "AND GWH.GWH_FILIAL = GWF.GWF_FILIAL "
					cQuery += "AND GWH.D_E_L_E_T_ = '' "
					cQuery += "INNER JOIN " + RetSQLName("GV5") + " GV5 "
					cQuery += "ON GV5.GV5_CDTPDC = GWH.GWH_CDTPDC "
					cQuery += "AND GV5.D_E_L_E_T_ = '' "
				EndIf
				
				cQuery += "WHERE GWF.GWF_FILIAL >= '" + GXE->GXE_FILDE + "' "
				cQuery += "AND GWF.GWF_FILIAL <= '" + GXE->GXE_FILATE + "' "
				cQuery += "AND GWF.GWF_DTCRIA >= '" + DToS(GXE->GXE_DTDE) + "' "
				cQuery += "AND GWF.GWF_DTCRIA <= '" + DToS(GXE->GXE_DTATE) + "' "
				
				If MV_PAR02 == 2
					cQuery += "AND GWF.GWF_TPCALC IN (1, 4, 5, 6, 7) "
				ElseIf MV_PAR02 == 3
					cQuery += "AND GWF.GWF_TPCALC IN (1, 6) "
				ElseIf MV_PAR03 == 4
					cQuery += "AND GWF.GWF_TPCALC IN (4, 5, 7) "
				Else
					cQuery += "AND GWF.GWF_TPCALC IN (1, 2, 4, 5, 6, 7, 8) "
				EndIf
				
				If MV_PAR01 == 2
					cQuery += "AND GWF.GWF_FINCAL IN (1, 2) "
				ElseIf MV_PAR01 == 3
					cQuery += "AND GWF.GWF_FINCAL <> '3' "
				EndIf
				
				If MV_PAR03 == 2
					cQuery += "AND GV5.GV5_FRCTB = '2' "
				ElseIf MV_PAR03 == 3
					cQuery += "AND GV5.GV5_FRCTB = '1' "
				EndIf
				
				If s_GFEI15 != '3'
					cQuery += "AND GWF.GWF_NRPREF = '' "
				EndIf
				
				cQuery += "AND GWA.GWA_SITCTB = '1' "
				
				cQuery += "AND GWF.D_E_L_E_T_ = '' "
				
				TCSQLExec(cQuery)
			EndIf
		Next nI
	EndIf

	If c_GFEZ01 == "1"
		RestArea(aAreaGXE)
		For nX := 1 to Len(aCalc)
			
			RecLock("GXD",.T.)
			GXD->GXD_FILIAL	:= GXE->GXE_FILIAL
			GXD->GXD_CODLOT	:= GXE->GXE_CODLOT
			GXD->GXD_FILCAL	:= aCalc[nX][1]
			GXD->GXD_NRCALC	:= aCalc[nX][2]
			MsUnlock("GXD")
		Next nX
		
		
		nX := 1
		For nX := 1 to Len(aGXF)
			RecLock("GXF",.T.)
			GXF->GXF_FILIAL := GXE->GXE_FILIAL
			GXF->GXF_CODLOT := GXE->GXE_CODLOT
			GXF->GXF_SEQ	:= nX
			GXF->GXF_CONTA	:= aGXF[nX][1]//GWA_CTADEB
			GXF->GXF_VALOR	:= aGXF[nX][4]//GWA_VLMOV
			GXF->GXF_TPLANC := "1"
			GXF->GXF_CCUSTO := aGXF[nX][2]//GWA_CCDEB
			GXF->GXF_UNINEG := aGXF[nX][3]//GWA_UNINEG	
			MsUnlock("GXF")
		Next nX
	EndIf
	
	RecLock("GXE",.F.)
	GXE->GXE_SIT	:= "1"
	MsUnlock("GXE")
	
	If c_GFEZ01 == "1"
		For nX := 1 to Len(aGWA)
			GWA->(dbGoTo(aGWA[nX]))
			RecLock("GWA",.F.)
			GWA->GWA_CODLOT := GXE->GXE_CODLOT
			msUnlock("GWA")
		Next nX
	EndIf
	
	RestArea(aAreaGWF)
	RestArea(aAreaGWJ)
	RestArea(aAreaGWH)
	RestArea(aAreaGW4)
	RestArea(aAreaGW3)
	RestArea(aAreaGW6)
	RestArea(aAreaGWA)
	RestArea(aAreaGXF)
	RestArea(aAreaGWM)
	RestArea(aAreaGXD)
	RestArea(aAreaGW2)
Return

Static Function ErroModel(oModel)
	//  A estrutura do vetor aErro com erro é:
	//  [1] Id do formulário de origem
	//  [2] Id do campo de origem
	//  [3] Id do formulário de erro
	//  [4] Id do campo de erro
	//  [5] Id do erro
	//  [6] mensagem do erro
	//  [7] mensagem da solução
	//  [8] Valor atribuido
	//  [9] Valor anterior
	Local aErro := oModel:GetErrorMessage()
	MsgAlert("Ocorreu um erro no campo: " + aErro[4] + ". Motivo: " + aErro[6] + ".",1,0)
Return

Static Function GravaModel(oModel)
	Local lRet := .F.
	If (lRet := oModel:VldData())
		oModel:CommitData()
	Else
		ErroModel(oModel)
	EndIf
	oModel:DeActivate()
	oModel:Destroy()
Return lRet

//Retorna o ultimo dia do período conforme o campo GXE_PERIOD, considerando qual mês deve ser avaliado (0 = mes do periodo, 1 mes seguinte...
Function GFEA096DIP(cPeriod,nMes)
	Local dData
	Local nMesPer := Val(SubStr(cPeriod,6))
	Local nAnoPer := Val(SubStr(cPeriod,1,4))
	Default nMes := 0
	
	nMesPer += 1 + nMes
	If nMesPer > 12
		nAnoPer += Int(nMesPer/12) // Quantidade de meses adicionada no periodo
		nMesPer := Mod(nMesPer,12) // meses é o resto da divisao
	EndIf
	
	dData := CTOD("01/" + StrZero(nMesPer,2) + "/" + StrZero(nAnoPer,4))-1
Return dData

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA096ATU
Readaptada para atualiza o financeiro no ERP.

@since 05/01/2016
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA096ATU()
	
	Local cMsg := ""
	Local cTmp := ""
	Local cQuery := ""
	Local cTipoEst := SuperGetMv('MV_TPEST',, '1')
	Local lSubLote := .F.
	Local lUltTeve := .F.
	If GFEA105ATV() .And. MsgYesNo( "Deseja integrar todos os lotes pendentes?" )
	
		//Percorre todos os lotes
		cAliasGXE := GetNextAlias()
		cQuery := " SELECT GXE_CODLOT,GXE_SIT FROM " + RetSQLName( "GXE" ) + " WHERE GXE_FILIAL = '" + xFilial( "GXE" ) + "' AND "
		cQuery += " (GXE_SIT = '1' OR GXE_SIT = '3' OR GXE_SIT = '4' OR GXE_SIT = '7' OR GXE_SIT = '8') AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGXE, .F., .T.)
		
		While !(cAliasGXE)->( Eof() )
		
			lUltTeve := .F.
			
			If (cAliasGXE)->GXE_SIT $ "1;3" //Não enviado ou rejeitado
				GXE->(dbSetOrder( 01 ))
				If GXE->(dbSeek( xFilial( "GXE" ) + (cAliasGXE)->GXE_CODLOT  ))
					cMsg := GFE096ILO( "2" )
					If !Empty(cMsg)
						cTmp += (cAliasGXE)->GXE_CODLOT + ","
					EndIf
				EndIf
			ElseIf cTipoEst == "2"
				GXN->(dbSetOrder( 01 ))
				If GXN->(dbSeek( xFilial( "GXN" ) + (cAliasGXE)->GXE_CODLOT ))
					While GXN->(!Eof()) .AND. GXN->GXN_FILIAL ==  xFilial( "GXN" )  .And. GXN->GXN_CODLOT == (cAliasGXE)->GXE_CODLOT
						
						If GXN->GXN_SIT $ '1;3' //Não enviado ou rejeitado
							RecLock( "GXN",.F. )
							GXN->GXN_SIT := "2" //Pendente
							GXN->(MsUnlock( "GXN" ))
							lSubLote := .T.
							lUltTeve := .T.
						EndIf
						
						GXN->(dbSkip())
					EndDo
					
					If lUltTeve
						GXE->(dbSetOrder( 01 ))
						GXE->(dbSeek( xFilial( "GXE" ) +  (cAliasGXE)->GXE_CODLOT ))
						RecLock( "GXE",.F. )
						GXE->GXE_SIT := "7" //Pendente Estorno Parcial
						GXE->(MsUnlock( "GXE" ))
					EndIf
					
				EndIf
			EndIf
			
			(cAliasGXE)->(dbSkip())
		EndDo
		If !Empty(cTmp)
			cMsg := "Não foi possível integrar os seguintes lotes: " + SubStr(cTmp,1,Len(cTmp)-1) + "." + CRLF + "Consulte o(s) lote(s) para mais informações."
			MsgAlert(cMsg,"Aviso")
		Else
			cMsg := "Todos os lotes encontrados foram atualizados com sucesso."
			If lSubLote
				cMsg := "Todos os lotes e sublotes encontrados foram atualizados com sucesso."
			EndIf
		EndIf
		(cAliasGXE)->(dbCloseArea())
		
	Else
		
		If GXE->GXE_SIT == "4" .And. cTipoEst != "2"
			Help(,,'HELP',,"Financeiro já atualizado.",1,0)
			Return
		EndIf
		
		If GXE->GXE_SIT == "5" // Pendente desatualização lote
			Help(,,'HELP',,"Não é possível atualizar o lote enquanto houver pendência de desatualização",1,0)
			Return
		EndIf
		
		If GXE->GXE_SIT == "6"
			MsgAlert("Financeiro já estornado.")
			Return
		EndIf
		
		If cTipoEst == "2" .And. GXE->GXE_SIT $ "4;7;8"
			GXN->(dbSetOrder( 01 ))
			If GXN->(dbSeek( xFilial( "GXN" ) + GXE->GXE_CODLOT ))
				While GXN->(!Eof()) .AND. GXN->GXN_FILIAL ==  xFilial( "GXN" )  .And. GXN->GXN_CODLOT == GXE->GXE_CODLOT
					
					If GXN->GXN_SIT $ '1;3' //Não enviado ou rejeitado
						RecLock( "GXN",.F. )
						GXN->GXN_SIT := "2" //Pendente
						GXN->(MsUnlock( "GXN" ))
						lSubLote := .T.
						lUltTeve := .T.
					EndIf
					
					GXN->(dbSkip())
				EndDo
				
				If lUltTeve
					RecLock( "GXE",.F. )
					GXE->GXE_SIT := "7" //Pendente Estorno Parcial
					GXE->(MsUnlock( "GXE" ))
				EndIf
				
			EndIf
			If lSubLote
				Help(,,'HELP',,"Todos os lotes e sublotes encontrados foram atualizados com sucesso.",1,0)
			Else
				Help(,,'HELP',,"Não foram encontrados sublotes com pendência de atualização.",1,0)
			EndIf
			Return
		Else
			cMsg := GFE096ILO( "2" )
		EndIf
	EndIf
	
	
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA096DES
//Desatualiza o financeiro no ERP

@since 06/01/2016
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA096DES()
	
	Local cMsg := ""
	Local cTipoEst := SuperGetMv('MV_TPEST',, '1')
	
	If cTipoEst == "2" //Se o conteúdo do parâmetro "Tipo Estorno" for diferente de 'Parcial', valida.
		Help(,,'HELP',,"Opção disponível apenas quando o sistema está parametrizado para estorno total. Para gerar um estorno do lote, utilize a opção 'Gerar Sublote Estorno'.",1,0)
		Return .F.
	EndIf
	
	//Não será possível utilizar esta opção caso o lote já tenha sido Pendente de estorno parcial ou Parcialmente Estornado.
	If GXE->GXE_SIT == "7" .Or. GXE->GXE_SIT == "8"
		Help(,,'HELP',,"Lote Contábil já foi parcialmente estornado. Para incluir movimentos no sublote de estorno, utilizar a ação 'Gerar Sublote Estorno'. Para eliminar o último sublote de estorno, utilizar a ação 'Desfazer Sublote Estorno'.",1,0)
		Return .F.
	EndIf
	
	If GXE->GXE_SIT != "4"
		MsgAlert("Financeiro deve estar atualizado para realizar o estorno.")
		Return .F.
	EndIf
	
	cMsg := GFE096ILO("5")
	If !Empty(cMsg)
		MsgAlert(cMsg)
	EndIf
	
Return .T.

/*/{Protheus.doc} GFE096ILO
	
@author siegklenes.beulke
@since 14/01/2014
@version 1.0

@param cSituacao, Char, situação de integração desejada

@description

Integra um registro de lote

/*/

Function GFE096ILO(cSituacao)
	Local cMsg
	Local oModel   := FWLoadModel("GFEA096")
	Local lIntGFE  := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cERPGFE  := SuperGetMv('MV_ERPGFE',, '1')
	Local aArea	   := GXE->(GetArea())
	
	oModel:SetOperation( 4 )
	If !oModel:Activate()//Desposiciona GXE
		cMsg := oModel:GetErrorMessage()
		cMsg := '"Ocorreu um erro no campo: "' + cMsg[4] + '". Motivo: "' + cMsg[6] + '"'
		oModel:CommitData()
		oModel:Deactivate()
		RestArea(aArea)
		RecLock("GXE",.F.)
		GXE->GXE_MOTIVO := cMsg
		GXE->(MsUnlock("GXE"))	
		Return cMsg
	EndIf
	
	RestArea(aArea)
	
	If oModel:GetModel('CALCGXF_VLR'):GetValue("TOTVALOR") == 0
		cMsg := "O valor do movimento contábil deve ser maior que zero. Verifique se foram relacionados cálculos e revise os critérios de seleção informados(Datas e Filiais). Se necessário, acione a ação relacionada 'Montar Lote'"
		oModel:CommitData()
		oModel:Deactivate()
		RecLock("GXE",.F.)
		GXE->GXE_MOTIVO := cMsg
		GXE->(MsUnlock("GXE"))
		Return cMsg
	Else
		If cSituacao != "5"
			oModel:GetModel("GFEA096_GXE"):SetValue("GXE_DTSIT",DDATABASE)
		EndIf
		oModel:GetModel("GFEA096_GXE"):SetValue("GXE_SIT",cSituacao)
		
		If !oModel:VldData()
			cMsg := oModel:GetErrorMessage()
			If !Empty(cMsg[4])
				cMsg := '"Ocorreu um erro no campo: "' + cMsg[4] + '". Motivo: "' + cMsg[6] + '"'
			Else
				cMsg := cMsg[6]
			EndIf
			oModel:CommitData()			
			oModel:Deactivate()
			RecLock("GXE",.F.)
			GXE->GXE_MOTIVO := cMsg
			GXE->(MsUnlock("GXE"))
			Return cMsg
		EndIf
		
		If  lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. cERPGFE == "2" // Integra com o protheus e é direto
			cMsg:= IntegraSit(oModel,cSituacao)
		EndIf
		
		If cSituacao == "2" .And. lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. cERPGFE == "2"
			oModel:GetModel("GFEA096_GXE"):SetValue("GXE_SIT",If(Empty(cMsg),"4","3"))
			oModel:GetModel("GFEA096_GXE"):SetValue("GXE_MOTIVO",cMsg)
		ElseIf cSituacao == "5" .And. lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. cERPGFE == "2"
			oModel:GetModel("GFEA096_GXE"):SetValue("GXE_SIT",If(Empty(cMsg),"6","4"))
			oModel:GetModel("GFEA096_GXE"):SetValue("GXE_MOTIVO",cMsg)
			If Empty(cMsg)
				oModel:GetModel("GFEA096_GXE"):SetValue("GXE_DTSIT",StoD("        "))
			EndIf
		EndIf
		
		If !oModel:VldData()
			cMsg := oModel:GetErrorMessage()
			cMsg := '"Ocorreu um erro no campo: "' + cMsg[4] + '". Motivo: "' + cMsg[6] + '"'
			oModel:CommitData()
			RecLock("GXE",.F.)
			GXE->GXE_MOTIVO := cMsg
			GXE->(MsUnlock("GXE"))
		Else
			oModel:CommitData()
		EndIf
	EndIf
	oModel:Deactivate()

Return cMsg

Static Function IntegraSit(oModel,cSituacao)
	
	Local cMsg 		:= ""
	Local oModelGXE := oModel:GetModel("GFEA096_GXE")
	
	Private _oGFEXFBFL := GFEXFBFLog():New()
	
	_oGFEXFBFL:setSaveLog(__lLogIntP)
	_oGFEXFBFL:setAgrFrt(oModelGXE:GetValue("GXE_CODLOT"))
		
	Do Case

		Case cSituacao == "2"
			cMsg := AtuFinERP(oModel) //Atualização do lote no Financeiro

		Case cSituacao == "5"
			cMsg := DesAtuFinERP(oModel)//DesAtualização do lote no Financeiro

		Otherwise

			Return "Verifique a situação de integração do Lote("+cSituacao+")."

	EndCase
	
	_oGFEXFBFL:SaveLog()
	
Return cMsg 

Static Function AtuFinERP(oModel)
	Local cMsg := ""
	Local oModelGXE := oModel:GetModel("GFEA096_GXE")
	Local oModelGXF := oModel:GetModel("GFEA096_GXF")
	Local aFornec := GFEA055GFL(oModelGXE:GetValue("GXE_CDEMIT")) // Retorna se o emissor do lote está no ERP
	Local dPeriod := GFEA096DIP(oModelGXE:GetValue("GXE_PERIOD"))//Ultimo dia do período
	Local dPeriodVc := GFEA096DIP(oModelGXE:GetValue("GXE_PERIOD"),1) //Ultimo dia do período do proximo mes
	Local aLoteFat := {}
	Local aRatCont := {}
	Local aRatAll := {}
	Local aErro
	Local nValorLot := 0
	Local nI := 0
	Local nPercent 	:= 0
	Local nAcPercent:= 0

	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.
	
	If Empty(aFornec[1])
		cMsg := "Fornecedor do lote não cadastrado no Protheus."
	Else
		// Calcula o total do lote
		For nI := 1 to oModelGXF:Length()
			oModelGXF:GoLine( nI )
			nValorLot += oModelGXF:GetValue("GXF_VALOR")
		Next nI
		
		// Monta os lançamentos
		For nI := 1 to oModelGXF:Length()
			oModelGXF:GoLine( nI )

			If nI == oModelGXF:Length()
				nPercent := 100 - nAcPercent
			Else
				nPercent := (100 * oModelGXF:GetValue("GXF_VALOR")) / nValorLot
				nAcPercent += nPercent
			EndIf
			//Dados dos Rateios
			aRatCont := { {"CTJ_DEBITO"  , oModelGXF:GetValue("GXF_CONTA"), Nil },;
							{"CTJ_VALOR" , oModelGXF:GetValue("GXF_VALOR"), Nil },;
							{"CTJ_PERCEN", nPercent, Nil },;
							{"CTJ_CCD"   , oModelGXF:GetValue("GXF_CCUSTO"), Nil }}
			
			Aadd(aRatAll, aRatCont)
		Next nI

		//Dados do Lote		
		aLoteFat := {	{"E2_PREFIXO"	, Space( TamSX3("E2_PREFIXO")[1]) 					, Nil },;
						{"E2_NUM" 		, Right(oModelGXE:GetValue("GXE_CODLOT"),TamSX3("E2_NUM")[1]), Nil },;
						{"E2_PARCELA"	, "1"                  									, Nil },;
						{"E2_TIPO"   	, "PR"                 									, Nil },;
						{"E2_NATUREZ"	, SuperGetMv('MV_NTFGFE',,"")							, Nil },;
						{"E2_EMISSAO"	, dPeriod    											, Nil },;
						{"E2_VENCTO" 	, dPeriodVc   											, Nil },;
						{"E2_VENCREA"	, dPeriodVc   											, Nil },;
						{"E2_VALOR"  	, nValorLot            									, Nil },;
						{"E2_VLCRUZ" 	, nValorLot            									, Nil },;
						{"E2_FORNECE"	, aFornec[1]          									, Nil },;
						{"E2_LOJA"		, aFornec[2]          									, Nil },;
						{"E2_ORIGEM"	, "TOTVSGFE"          									, Nil },;
						{"E2_RATEIO"	, "S"          											, Nil } }
						
		_oGFEXFBFL:NovoLogInP("FINA050") //Log de integração com ERP Protheus
					                    
		AddToLog("LOG DE INTEGRAÇÃO FINA050 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO FINA050 - Iniciado em "###", as "
		AddToLog('Atualização' + CRLF + CRLF)
		AddToLog('Lote' + CRLF)

		For nI := 1 To Len(aLoteFat)
			AddToLog(aLoteFat[nI,1] + " - " + cValToChar(aLoteFat[nI,2]) + CRLF)
		Next nI
		
		If !Empty(aRatAll)
		
			AddToLog(CRLF + 'Dados dos Rateios' + CRLF)
			 
			For nI := 1 To Len(aRatAll[1])
				AddToLog(aRatAll[1,nI,1] + " - " + cValToChar(aRatAll[1,nI,2]) + CRLF)
		    next nI
		EndIf
		
		MsAguarde( {|| MsExecAuto({ |a,b,c| FINA050(a,,b,,,,,c)}, aLoteFat,3,aRatAll ) }, 'Aguarde, enviando ao financeiro...' )
		
		If lMsErroAuto
			aErro := GetAutoGrLog()
			cMsg := ""

			For nI := 1 To Len(aErro)
				cMsg += aErro[nI] + CRLF
			Next nI
			
			AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
			AddToLog(cMsg + CRLF) 
		Else
			AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
		EndIf
		
		AddToLog("LOG DE INTEGRAÇÃO FINA050 - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO FINA050 - Finalizado em "###", as "
	EndIf
	
	
Return cMsg

Static Function DesAtuFinERP(oModel)
	Local cMsg := ""
	Local oModelGXE := oModel:GetModel("GFEA096_GXE")
	Local aFornec := GFEA055GFL(oModelGXE:GetValue("GXE_CDEMIT")) // Retorna se o emissor do lote está no ERP
	Local nI := 0
	Local aErro 
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.
	
	//Dados da Pré-Fatura
	aPreFat := {	{"E2_PREFIXO" , Space( TamSX3("E2_PREFIXO")[1])                               , Nil },;
					{"E2_NUM"     , PadR(oModelGXE:GetValue("GXE_CODLOT"),TamSX3("E2_NUM")[1]) , Nil },;
					{"E2_PARCELA" , AllTrim("1")+Space( (TamSX3("E2_PARCELA")[1])-(Len( AllTrim("1") )) ), Nil },;
					{"E2_TIPO"    , AllTrim("PR")+Space( (TamSX3("E2_TIPO")[1])-(Len( AllTrim("PR") )) ),Nil },;
					{"E2_FORNECE" , aFornec[1]                                                                 , Nil },;
					{"E2_LOJA"    , aFornec[2]                                                                 , Nil } }
	
	_oGFEXFBFL:NovoLogInP("FINA050") //Log de integração com ERP Protheus
				                    
	AddToLog("LOG DE INTEGRAÇÃO FINA050 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO FINA050 - Iniciado em "###", as "
	AddToLog('Desatualização' + CRLF + CRLF)
	AddToLog('Pré-Fatura' + CRLF)

	For nI := 1 To Len(aPreFat)
		AddToLog(aPreFat[nI,1] + " - " + cValToChar(aPreFat[nI,2]) + CRLF)						
	Next nI
	
	MsAguarde( {|| MsExecAuto({ |a,b| FINA050(a,,b)}, aPreFat,5 ) }, 'Aguarde, enviando ao financeiro...' )
	
	If lMsErroAuto
		aErro := GetAutoGrLog()
		cMsg := ""

		For nI := 1 To Len(aErro)
			cMsg += aErro[nI] + CRLF
		Next nI
		
		AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
		AddToLog(cMsg + CRLF) 
	Else
		AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
	EndIf
	
	AddToLog("LOG DE INTEGRAÇÃO FINA050 - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO FINA050 - Finalizado em "###", as "
	
Return cMsg
//Retorna o valor de um lote sem usar o model
Function GFEA096VL(cFil,cLot)
	Local nValor := 0
	Default cFil := GXE->GXE_FILIAL
	Default cLot := GXE->GXE_CODLOT
	dbSelectArea("GXF")
	GXF->(dbSetOrder(1))
	GXF->(dbSeek(cFil + cLot))
	While !GXF->(Eof()) .And. GXF->GXF_FILIAL == cFil .And. GXF->GXF_CODLOT == cLot
		nValor += GXF->GXF_VALOR
		GXF->(dbSkip())
	EndDo
Return nValor

//Habilita os campos edição enquanto o procedimento "Montar Lote" não for executado 
Function GFEA096WHE()
	Local oModel := FWModelActive()
	
Return oModel:GetModel("GFEA096_GXF"):GetValue("GXF_SEQ",1) == 0

// Validação de Post do Model
Function GFEA096POS(oModel)
	Local dDataIni	:= FwFldGet("GXE_DTDE")
	Local dDataFim	:= FwFldGet("GXE_DTATE")
	Local cPeriod	:= FwFldGet("GXE_PERIOD")
	Local dPeriod
	
	// cPeriodo 201401
	If Len(AllTrim(StrTran(cPeriod,"/",""))) < 6
		oModel:GetModel():SetErrorMessage(,"GXE_PERIOD",,"GXE_PERIOD",,"O período deve estar no formato de data aaaa/mm")
		Return .F.
	EndIf
	
	If Val(SubStr(cPeriod,6)) <= 0 .Or. Val(SubStr(cPeriod,6)) > 12
		oModel:GetModel():SetErrorMessage(,"GXE_PERIOD",,"GXE_PERIOD",,"O mês do período é inválido")
		Return .F.
	EndIf
	
	If (!Empty(SuperGetMv("MV_DTULFE",.F.,"")) .And. cPeriod <= GFEA096PER(.T.)) .Or. (Empty(SuperGetMv("MV_DTULFE",.F.,"")) .And. cPeriod < GFEA096PER())
		oModel:GetModel():SetErrorMessage(,,,,,"Lote com período inferior ou igual a data do último fechamento contábil: " + GFEA096PER() + ". Operação disponível apenas para lotes de período posterior a data do último fechamento.")
		Return .F.
	EndIf
	
	If dDataIni > dDataFim
		oModel:GetModel():SetErrorMessage(,,,,,"O campo 'Data De' deve possuir uma data menor que o campo 'Data Ate'")
		Return .F.
	EndIf
	
	dPeriod := GFEA096DIP(cPeriod) // Último dia do período
	
	If dDataFim > dPeriod
		oModel:GetModel():SetErrorMessage(,,,,,"O campo 'Data Ate' deve possuir uma data menor que o campo 'Periodo'")
		Return .F.
	EndIf
	
Return .T.

//Ativação do Model
Function GFEA096PRE(oModel)

	Local nOp := oModel:GetOperation()
	
	If (nOp == MODEL_OPERATION_DELETE .Or. nOp == MODEL_OPERATION_UPDATE) .And. !(GXE->GXE_SIT $ "1;3") .And. !IsInCallStack("GFE096ILO")
		HELP(" ",1,"GFEA0961","GFEA0961" )
		Return .F.
	EndIf
	
Return .T.

//Procura o próximo código de lote disponível
Function GFE096CodL()
	Local nTam := 8
	Local cGXENum := Right(GETSXENUM("GXE","GXE_CODLOT"),nTam)
	Local cGWJNum := Right(GETSXENUM("GWJ","GWJ_NRPF"),nTam)
	Local cNum := If(cGXENum>=cGWJNum,cGXENum,cGWJNum)
	Static cLastCod := ""
	dbSelectArea("GXE")
	GXE->(dbSetOrder(1))
	While GXE->(dbSeek(xFilial("GXE") + cNum))
		cNum := StrZero(Val(cNum)+1,nTam)
	EndDo
	If !Empty(cLastCod)
		GXE->(dbSeek(cLastCod))
	EndIf
	cLastCod := xFilial("GXE") + cNum
Return StrZero(Val(cNum),nTam)

//Retorna o valor dos campos
Function GFE096GXD(nTipo)
	dbselectarea("GWF")
	GWF->(dbSetOrder(1))
	GWF->(dbSeek(GXD->GXD_FILIAL+GXD->GXD_NRCALC))
	If nTipo == 1
		Return VLTOTFRET()
	EndIf
	If nTipo == 2
		Return GWF->GWF_VLICMS + GWF->GWF_VLPIS + GWF->GWF_VLCOFI
	EndIf
	If nTipo == 3
		Return If (GWF->GWF_CRDICM=='1',GWF->GWF_VLICMS,0) + If(GWF->GWF_CRDPC=='1',GWF->GWF_VLPIS + GWF->GWF_VLCOFI,0)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFA096SAL
Retorna o saldo.

@since 09/01/2017
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFA096SAL( cCodLot )

	Local nValor := 0
	Local cQuery := ""
	Local cAliasGXF := GetNextAlias()
	Local cAliasGXO := GetNextAlias() 
	
	cQuery := " SELECT SUM( GXF_VALOR ) VALOR FROM " + RetSQLName( "GXF" ) + " WHERE GXF_FILIAL = '"  + xFilial( "GXF" ) + "'"
	cQuery += " AND GXF_CODLOT = '"  + cCodLot + "'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGXF, .F., .T.)
	
	cAliasGXO := GetNextAlias()
	cQuery := " SELECT SUM( GXO_VALOR ) VALOR FROM " + RetSQLName( "GXO" ) + " WHERE GXO_FILIAL = '" + xFilial( "GXO" ) + "'"
	cQuery += " AND GXO_CODLOT = '" + cCodLot + "'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGXO, .F., .T.)
	
	If !(cAliasGXF)->( Eof() )
		nValor := (cAliasGXF)->VALOR - (cAliasGXO)->VALOR
	EndIf
	
	(cAliasGXF)->(dbCloseArea())
	(cAliasGXO)->(dbCloseArea())
	
Return Val(STR(nValor,12,2))

//-------------------------------------------------------------------
/*/{Protheus.doc} GFA096SAL
Retorna o saldo.

@since 09/01/2017
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFA096GWH( cNrCalc )

	Local cQuery := ""
	Local lRet := .F. 
	Local cMV_DSCTB := SuperGetMv( 'MV_DSCTB',, '1' )
	Local cAliasQry := GetNextAlias()
	
	If cMV_DSCTB == "1"
		cQuery := " SELECT GWH_NRCALC FROM " + RetSQLName( "GWH" ) + " GWH "
		cQuery += " INNER JOIN " + RetSQLName( "GWF" ) + " GWF ON GWH.GWH_NRCALC = GWF.GWF_NRCALC "
		cQuery += " INNER JOIN " + RetSQLName( "GW3" ) + " GW3 ON GWF.GWF_FILIAL = GW3.GW3_FILIAL AND GWF.GWF_CDESP = GW3.GW3_CDESP AND "
		cQuery += " GWF.GWF_EMISDF = GW3.GW3_EMISDF AND GWF.GWF_SERDF = GW3.GW3_SERDF AND 
		cQuery += " GWF.GWF_NRDF = GW3.GW3_NRDF AND GWF.GWF_DTEMDF = GW3.GW3_DTEMIS " 
		cQuery += " INNER JOIN " + RetSQLName( "GW6" ) + " GW6 ON GW6.GW6_NRFAT = GW3.GW3_NRFAT AND GW3.GW3_FILFAT = GW6.GW6_FILIAL "
		cQuery += " WHERE GWF.GWF_TPCALC = '1' AND GW6.GW6_SITFIN = '4' AND GWH.GWH_NRCALC <> " + cNrCalc + " AND "
		cQuery += " GWH.D_E_L_E_T_ = ' ' AND "
		cQuery += " GWF.D_E_L_E_T_ = ' ' AND "
		cQuery += " GW3.D_E_L_E_T_ = ' ' AND "
		cQuery += " GW6.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		
		If !(cAliasQry)->( Eof() )
			lRet := .T.
		EndIf
	ElseIf cMV_DSCTB == "2"
		cQuery := " SELECT GWH.GWH_NRCALC FROM " + RetSQLName( "GWH" ) + " GWH "
		cQuery += " INNER JOIN " + RetSQLName( "GWF" ) + " GWF ON GWH.GWH_NRCALC = GWF.GWF_NRCALC "
		cQuery += " INNER JOIN " + RetSQLName( "GW3" ) + " GW3 ON GWF.GWF_NRDF = GW3.GW3_NRDF "
		cQuery += " INNER JOIN " + RetSQLName( "GW6" ) + " GW6 ON GW6.GW6_FILIAL = GW3.GW3_FILFAT AND GW6.GW6_EMIFAT = GW3.GW3_EMIFAT AND"
		cQuery += " GW6.GW6_SERFAT = GW3.GW3_SERFAT AND GW6.GW6_NRFAT = GW3.GW3_NRFAT AND GW6.GW6_DTEMIS = GW3.GW3_DTEMFA "
		cQuery += " WHERE GWF.GWF_TPCALC = '1' AND GW3.GW3_SITFIS = '4' AND GWH.GWH_NRCALC <> " + cNrCalc + " AND "
		cQuery += " GWH.D_E_L_E_T_ = ' ' AND "
		cQuery += " GWF.D_E_L_E_T_ = ' ' AND "
		cQuery += " GW3.D_E_L_E_T_ = ' ' AND "
		cQuery += " GW6.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		
		If !(cAliasQry)->( Eof() )
			lRet := .T.
		EndIf
	EndIf
	
	(cAliasQry)->(dbCloseArea())
	
Return lRet

/*/{Protheus.doc} GFEA096CMT
	Responsável por eliminar os relacionamentos indiretos
@author siegklenes.beulke
@since 27/03/2017
@version undefined
@param oModel, object, oModel
@example
(examples)
@see (links_or_references)
/*/
Function GFEA096CMT(oModel)
	Local lRet := GFEA096DR(oModel:GetOperation(),oModel:GetValue( 'GFEA096_GXE', 'GXE_FILIAL' ),oModel:GetValue( 'GFEA096_GXE', 'GXE_CODLOT' ))
Return lRet

/*/{Protheus.doc} GFEA096DR
	Responsável por eliminar os relacionamentos indiretos
@author siegklenes.beulke
@since 27/03/2017
@version undefined
@param oModel, object, oModel
@example
(examples)
@see (links_or_references)
/*/
Function GFEA096DR(nOperation,cFil,cLot)
	Local aAreaGWA
	Local cQuery
	Local cAliasQuery
	Local cFilBkp
	
	If nOperation == MODEL_OPERATION_DELETE
		aAreaGWA := GWA->(GetArea())
		cFilBkp := cFilAnt
		cFilAnt := cFil
		cQuery := "SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("GWA") + " WHERE D_E_L_E_T_ = ' ' AND GWA_FILIAL = '" + xFilial("GWA") + "' AND GWA_CODLOT = '" + cLot + "'"
		cAliasQuery := MpSysOpenQuery(ChangeQuery(cQuery))
		
		While !(cAliasQuery)->(Eof())
			GWA->(dbGoto((cAliasQuery)->RECNO))
			RecLock("GWA",.F.)
			GWA->GWA_CODLOT := ""
			GWA->(MsUnlock())
			(cAliasQuery)->(dbSkip())
		EndDo
		
		(cAliasQuery)->(dbCloseArea())
		cFilAnt := cFilBkp	
		RestArea(aAreaGWA)
	EndIf
Return 	.T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA065OBS
Classe interna implementando o FWModelEvent
Intern class inherited from FWModelEvent.
@author hercilio.neto
@since 19/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Class GFEA096OBS FROM FWModelEvent
    Method InTTS()
    Method New()
    
End Class

Method New() Class GFEA096OBS
Return

Method InTTS(oModel, cModelId, cAlias, lNewRecord) Class GFEA096OBS
	GFEA096CMT(oModel)
Return

/*
=========================================================================================================
// {Protheus.doc} IntegDef
// TODO Chamada da Rotina de Integração de Mensagem Unica 
@author Hercilio Henning Neto
@since 18/07/2017
@version 1.000
@param cXml     : Xml definido de acordo com o XSD da mensagem de envio/recebimento.
@param nType    : numeric / Informa o tipo de Mensagem tratada: 0=Response;1=Envio;
@param cTypeMsg : Informa qual o tipo de mensagem que será processada se é uma: Business Message, Receipt Message, WhoIs Message 
@type function
=========================================================================================================
*/
Static Function IntegDef(cXml,nType,cTypeMsg)
Local  aResult := {}
       aResult := GFEI096(cXml,nType,cTypeMsg)
Return aResult


/*/{Protheus.doc} AddToLog
Registra o texto de log recebido na variável de log
Caso a variável exceda o limite estabelecido, o conteúdo é gravado em arquivo
@author silvana.torres
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cTexto, characters, descricao
@param nPosicao, numeric, descricao
@param lTime, logical, descricao
@type function
/*/
Static Function AddToLog(cTexto, nPosicao, lTime)
	Default lTime	:= .T.
	Default nPosicao := _LOG_END

	If !__lLogIntP
		Return
	EndIf
	
	_oGFEXFBFL:setPosicao(nPosicao)
	_oGFEXFBFL:setTime(lTime)
	_oGFEXFBFL:setSaveLog(__lLogIntP)
	_oGFEXFBFL:setTexto(cTexto)
Return NIL

Function GFEA096EXC()
	Local cQuery	:= ""
	
	If !(GXE->GXE_SIT $ "1;3")
		HELP(" ",1,"GFEA0961","GFEA0961" )
		Return .F.
	EndIf

	If MSGYESNO("Confirma a Exclusão do lote " + AllTrim(GXE->GXE_CODLOT) + "?")
		cQuery := "UPDATE " + RetSQLName("GXN") + " "
		cQuery += "SET D_E_L_E_T_ = '*', "
		cQuery += "R_E_C_D_E_L_ = R_E_C_N_O_ "
		cQuery += "WHERE GXN_FILIAL = '" + GXE->GXE_FILIAL + "' "
		cQuery += "AND GXN_CODLOT = '" + GXE->GXE_CODLOT + "' "
		
		TCSQLExec(cQuery)
		
		cQuery := "UPDATE " + RetSQLName("GXD") + " "
		cQuery += "SET D_E_L_E_T_ = '*', "
		cQuery += "R_E_C_D_E_L_ = R_E_C_N_O_ "
		cQuery += "WHERE GXD_FILIAL = '" + GXE->GXE_FILIAL + "' "
		cQuery += "AND GXD_CODLOT = '" + GXE->GXE_CODLOT + "' "
		
		TCSQLExec(cQuery)
		
		cQuery := "UPDATE " + RetSQLName("GXF") + " "
		cQuery += "SET D_E_L_E_T_ = '*', "
		cQuery += "R_E_C_D_E_L_ = R_E_C_N_O_ "
		cQuery += "WHERE GXF_FILIAL = '" + GXE->GXE_FILIAL + "' "
		cQuery += "AND GXF_CODLOT = '" + GXE->GXE_CODLOT + "' "
		
		TCSQLExec(cQuery)
		
		cQuery := "UPDATE " + RetSQLName("GWA") + " "
		cQuery += "SET GWA_CODLOT = '' "
		cQuery += "WHERE GWA_FILIAL = '" + GXE->GXE_FILIAL + "' "
		cQuery += "AND GWA_CODLOT = '" + GXE->GXE_CODLOT + "' "
		
		TCSQLExec(cQuery)
		
		cQuery := "UPDATE " + RetSQLName("GXE") + " "
		cQuery += "SET D_E_L_E_T_ = '*', "
		cQuery += "R_E_C_D_E_L_ = R_E_C_N_O_ "
		cQuery += "WHERE GXE_FILIAL = '" + GXE->GXE_FILIAL + "' "
		cQuery += "AND GXE_CODLOT = '" + GXE->GXE_CODLOT + "' "
		
		TCSQLExec(cQuery)
	EndIf
	
Return
