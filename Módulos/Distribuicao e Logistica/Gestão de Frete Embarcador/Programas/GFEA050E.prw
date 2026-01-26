#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
 
//====================================================================================================================\\
/*/{Protheus.doc}IVALEXPD_MVC
  ====================================================================================================================
	@description
	Rotina que efetua a validação da expedição x Pedido de venda

	@author		Lucas Farias
	@version	1.0
	@since		25 de ago de 2016

/*/
//===================================================================================================================\\
Function GFEA050E(cRomaneio,lSimula,nOperation)
	Local oView
	Local oModel
	Local cTitulo		 := "Roteiro do Romaneio - Número: " + cRomaneio
	Local oExecView

	Public  nRomaneio := ""
	Private lAltOrdem := .F.
	
	Default cRomaneio	:= ""
	Default lSimula		:= .F.
	Default nOperation	:= 4
	
	nRomaneio := cRomaneio
		
	DbSelectArea("GWR")	//Cria tabela
	DbSelectArea("GWS") //Cria tabela
	DbSelectArea("GWT") //Cria tabela
		
	oView	:= ViewDef()
	oModel	:= ModelDef()
			
	// Ajuste de botões padrão
	aEnableButtons := Array(14)
	aFill(aEnableButtons, {.F.,Nil})
	aEnableButtons[7]:= {.T.,"Confirmar"}
	aEnableButtons[8]:= {.T.,"Fechar"}
			
	If oView <> Nil
		If nOperation != 2 // SetOperation não aceita 2-Visualizar
			oView:SetOperation(nOperation)
		EndIf
	
		oView:SetCloseOnOk({ || .T. })
	
		oExecView := FWViewExec():New()
				
		oExecView:SetModel(oModel)
		oExecView:SetView(oView)
		If nOperation != 2
			oExecView:SetOperation(oView:GetOperation()) // SetOperation não aceita 2-Visualizar
		EndIf
		oExecView:SetTitle(cTitulo)
		oExecView:SetButtons(aEnableButtons)
		oExecView:OpenView(.F.)
			
		oView:DeActivate()
		oView:Destroy()
	EndIf
		
Return
//====================================================================================================================\\
/*/{Protheus.doc}ModelDef
//====================================================================================================================
	@description
	Definição do Modelo de Dados

	@author		Lucas Farias
	@version	1.0
	@since		07 de Setembro de 2017
/*/
//===================================================================================================================\\

Static Function ModelDef()
	Local oStruGWN
	Local oStruGWT
	Local oStruGWR
	Local oStruGWS
	Local oModel

	oModel := MPFormModel():New("GFEA050E" /*cID*/, /*bPre*/, {|oModel| GFEA50ECMT(oModel)} /*bPost*/, /*bCommit*/, /*bCancel*/)
	
	// Monta as estruturas das tabelas
	oStruGWN := FWFormStruct( 1, "GWN", ,/*lViewUsado*/ )
	oStruGWT := FWFormStruct( 1, "GWT", ,/*lViewUsado*/ )
	oStruGWR := FWFormStruct( 1, "GWR", ,/*lViewUsado*/ )
	oStruGWS := FWFormStruct( 1, "GWS", ,/*lViewUsado*/ )
	
	// Modifica propriedade dos campos.
	oStruGWR:SetProperty( "GWR_ORDEM" , MODEL_FIELD_VALID	,{|oFW, cId, xValue| GFEA050ESEQ(oFW, cId, xValue) })

	oStruGWT:SetProperty( "*" , MODEL_FIELD_WHEN , {|| .T.})
	oStruGWS:SetProperty( "*" , MODEL_FIELD_WHEN , {|| .T.})
	oStruGWR:SetProperty( "*" , MODEL_FIELD_WHEN , {|| .T.})
	
	//Cabeçalho	
	oModel:AddFields( "GFEA050E_GWN", /*cOwner*/, oStruGWN, /*bPre*/, /*bPost*/, /*bLoad*/)
	
	oModel:SetPrimaryKey( {"GWN_FILIAL" , "GWN_NRROM"} )
	
	//Grids
	oModel:AddGrid( "GFEA050E_GWT", "GFEA050E_GWN", oStruGWT, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
	oModel:AddGrid( "GFEA050E_GWR", "GFEA050E_GWT", oStruGWR, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
	oModel:AddGrid( "GFEA050E_GWS", "GFEA050E_GWT", oStruGWS, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
	
	// Propriedades das Grids
	oModel:SetRelation( "GFEA050E_GWT", { {"GWT_FILIAL", "xFilial('GWT')"}, {"GWT_NRROM","GWN_NRROM"} }, GWT->(IndexKey( 1 )) )
	oModel:SetRelation( "GFEA050E_GWR", { {"GWR_FILIAL", "xFilial('GWR')"}, {"GWR_NRROM","GWT_NRROM"}, {"GWR_CDTRP","GWT_CDTRP"}, {"GWR_SEQ", "GWT_SEQ"} }, GWR->(IndexKey( 1 )) )
	oModel:SetRelation( "GFEA050E_GWS", { {"GWS_FILIAL", "xFilial('GWS')"}, {"GWS_NRROM","GWT_NRROM"}, {"GWS_CDTRP","GWT_CDTRP"}, {"GWS_SEQ", "GWT_SEQ"} }, GWS->(IndexKey( 1 )) )
	
	// Permite salvar sem nenhum item relacionado
	oModel:GetModel( "GFEA050E_GWT" ):lOptional := .F.
	oModel:GetModel( "GFEA050E_GWR" ):lOptional := .T.
	oModel:GetModel( "GFEA050E_GWS" ):lOptional := .T.
	
	// Especifica que o grid não irá permitir a edição de dados
	oModel:GetModel( "GFEA050E_GWN" ):SetOnlyView()
	
	// Especifica que o grid não permite exclusão de linhas
	oModel:GetModel("GFEA050E_GWT"):SetNoDeleteLine()
	
	// Define se deleta todas as linhas
	oModel:GetModel( "GFEA050E_GWT" ):SetDelAllLine( .F. )
	oModel:GetModel( "GFEA050E_GWR" ):SetDelAllLine( .F. )
	oModel:GetModel( "GFEA050E_GWS" ):SetDelAllLine( .F. )
		
	// Define duplicação de linhas
	oModel:GetModel( "GFEA050E_GWT" ):SetUniqueLine( { "GWT_NRROM", "GWT_CDTRP", "GWT_SEQ" } )
	oModel:GetModel( "GFEA050E_GWR" ):SetUniqueLine( { "GWR_NRROM", "GWR_CDTRP", "GWR_SEQ", "GWR_SEQID" } )
	oModel:GetModel( "GFEA050E_GWS" ):SetUniqueLine( { "GWS_NRROM", "GWS_CDTRP", "GWS_SEQ", "GWS_SEQID" } )
	
	// Aumenta numero maximo de linha das GRID's
	oModel:GetModel( "GFEA050E_GWT" ):SetMaxLine( 0100 )
	oModel:GetModel( "GFEA050E_GWR" ):SetMaxLine( 9999 )
	oModel:GetModel( "GFEA050E_GWS" ):SetMaxLine( 9999 )
	
Return(oModel)
// FIM da Funcao ModelDef
//======================================================================================================================

//====================================================================================================================\\
/*/{Protheus.doc}ViewDef
//====================================================================================================================
	@description
	Construção da Interface.

	@author		Lucas Farias
	@version	1.0
	@since		21 de Agosto de 2017
/*/
//===================================================================================================================\\

Static Function ViewDef()
	Local cExibir := "GWN_NRROM/"
	Local aCampos,cCampo,nX
	Local oStruGWN
	Local oStruGWT
	Local oStruGWR
	Local oStruGWS
	Local oModel
	Local oView
 
	oView := FWFormView():New()

	oModel	:= ModelDef()

	oView:SetModel( oModel )

	// Monta as estruturas das tabelas
	oStruGWN := FWFormStruct( 2, "GWN", ,/*lViewUsado*/ )
	oStruGWT := FWFormStruct( 2, "GWT", ,/*lViewUsado*/ )
	oStruGWR := FWFormStruct( 2, "GWR", ,/*lViewUsado*/ )
	oStruGWS := FWFormStruct( 2, "GWS", ,/*lViewUsado*/ )
	
	//Remove Campos
	aCampos := aClone(oStruGWN:GetFields())
	
	For nX := 1 to Len(aCampos)
		
		cCampo := aCampos[nX][1]
		
		If !(cCampo $ cExibir)
			oStruGWN:RemoveField(cCampo)
		EndIf
	Next nX
	
	oStruGWT:RemoveField("GWT_NRROM")
	oStruGWR:RemoveField("GWR_SEQ")
	oStruGWS:RemoveField("GWS_SEQ")
	oStruGWR:RemoveField("GWR_SEQID")
	
	// Monta Layout
	oView:SetModel(oModel)
	
	oView:AddField( "GFEA050E_GWN"	, oStruGWN )
	
	oView:AddGrid( "GFEA050E_GWT"	, oStruGWT )
	oView:AddGrid( "GFEA050E_GWR"	, oStruGWR )
	oView:AddGrid( "GFEA050E_GWS"	, oStruGWS )
	
	oView:AddIncrementField( 'GFEA050E_GWR', 'GWR_ORDEM' )
	oView:AddIncrementField( 'GFEA050E_GWS', 'GWS_SEQID' )
	
	oView:CreateHorizontalBox( "MASTER"	, 0 )
	oView:CreateHorizontalBox( "TRANSPORTADOR"	, 30 )
	oView:CreateHorizontalBox( "FOLDERS"		, 70 )

	oView:CreateFolder("IDFOLDER","FOLDERS")
	
	oView:AddSheet("IDFOLDER","IDSHEET01","Roteiro")
	oView:AddSheet("IDFOLDER","IDSHEET02","Tarifas de Pedagio")
	
	oView:CreateHorizontalBox( "DETAIL_ROTEIRO"	, 100,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "DETAIL_TARIFA"	, 100,,,"IDFOLDER","IDSHEET02" )
	
	oView:SetOwnerView( "GFEA050E_GWN"	, "MASTER" )
	oView:SetOwnerView( "GFEA050E_GWT"	, "TRANSPORTADOR" )
	oView:SetOwnerView( "GFEA050E_GWR"	, "DETAIL_ROTEIRO" )
	oView:SetOwnerView( "GFEA050E_GWS"	, "DETAIL_TARIFA" )
	
	// Altura das Linhas
	oView:SetViewProperty("*", "GRIDROWHEIGHT", {20})
	
	//Descrição dos Campos
	oView:SetViewProperty( "GFEA050E_GWN"	, "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_LEFT	, 3 } )
	
	// Adiciona a opção de recálculo
	oView:SetViewCanActivate(	{|oView| GFEA50EOP(oView) })
	
	// Chama a função de população da Grid referente a GWT
	oView:SetAfterViewActivate(	{|oView| GFEA050EVIEW(oView) })
	
Return oView
// FIM da Funcao ViewDef
//======================================================================================================================

//====================================================================================================================\\
/*/{Protheus.doc}GFEA050EVIEW
//====================================================================================================================
	@description
	Função ao Após abertura da VIEW.

	@author		Lucas Farias
	@version	1.0
	@since		12 de Setembro de 2017
/*/
//===================================================================================================================\\

Static Function GFEA050EVIEW(oView)
	
	GWT->(dbSetOrder(1))
	If !dbSeek(xFilial("GWT")+nRomaneio) .And. oView:oModel:GetOperation() == 4	
		GFEA50EPOP()
	EndIf
	
	//oView:GetViewObj("GFEA050E_GWR")[3]:oBrowse:SetDelOk({|| SfDelRot() })
Return
// FIM da Funcao GFEA050EVIEW
//======================================================================================================================

//====================================================================================================================\\
/*/{Protheus.doc}GFEA50EPOP
//====================================================================================================================
	@description
	Função que popula cabeçalho da VIEW.

	@author		Lucas Farias
	@version	1.0
	@since		13 de Setembro de 2017
/*/
//===================================================================================================================\\

Static Function GFEA50EPOP()
	Local oView		:= FWViewActive()
	Local oModel	:= FWModelActive()
	Local oModelGWT	:= oModel:GetModel("GFEA050E_GWT")
	Local oModelGWR	:= oModel:GetModel("GFEA050E_GWR")
	Local oModelGWS	:= oModel:GetModel("GFEA050E_GWS")
	Local aGWT		:= {}
	Local cValepGU3 := ""
	Local cOpVPMod  := SuperGetMV("MV_GFEOVP",.F.,"")	
	Local aTrecho   := {}
	Local nX		:= 0
	Local nI		:= 1
	Local cOrdem	:= STRZERO(1,GetSx3Cache("GWR_ORDEM","X3_TAMANHO"))
	Local aArea		:= GetArea()
	Local nQtdTrecho := 0
	Local cGWU_CDTRP 
	Local cGWU_SEQ
	Local cGWU_CITORI
	Local cGWU_CITDES
	Local cGW1_CDREM
	Local cGW1_CDDEST
	Local cGWU_NRDC
	Local cAliasGWU
	Local cQuery
	Local nContDoc := 0
	Local cAliasGW1 := Nil
	Local cWhere    := Nil
	
	If GFXCP1212210('GW1_FILROM')
		cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
	Else
		cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
	EndIf
	cWhere := "%" + cWhere + "%"

	cAliasGW1 := GetNextAlias()
	BeginSql Alias cAliasGW1
		SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
		FROM %table:GW1% GW1
		WHERE %Exp:cWhere%
		AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
		AND GW1.%NotDel%
		ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
	EndSql
	While !(cAliasGW1)->(Eof())
		GW1->(dbGoto( (cAliasGW1)->GW1RECNO) )
		
		If Select(cAliasGWU) > 0
			(cAliasGWU)->(dbCloseArea())
		EndIf

		cQuery := "SELECT GWU.GWU_CDTRP, GWU.GWU_SEQ, GWU.GWU_NRCIDO, GWU.GWU_NRCIDD, GWU.GWU_NRDC, GWU.GWU_CDTPOP, GWU.GWU_CDTPVC, GWU.GWU_PAGAR"
		cQuery += " FROM " + RetSQLName("GWU") + " GWU "
		cQuery += " WHERE GWU.GWU_FILIAL = '" + GW1->GW1_FILIAL + "'"
		cQuery += "   AND GWU.GWU_EMISDC = '" + GW1->GW1_EMISDC + "'" 
		cQuery += "   AND GWU.GWU_CDTPDC = '" + GW1->GW1_CDTPDC + "'"
		cQuery += "   AND GWU.GWU_SERDC  = '" + GW1->GW1_SERDC  + "'"
		cQuery += "   AND GWU.GWU_NRDC   = '" + GW1->GW1_NRDC   + "'"
		cQuery += "   AND GWU.D_E_L_E_T_  = ' ' "

		cAliasGWU := GetNextAlias()

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGWU, .F., .T.)

		While !((cAliasGWU)->(Eof()))
	
			cGWU_CDTRP  := (cAliasGWU)->GWU_CDTRP
			cGWU_SEQ    := (cAliasGWU)->GWU_SEQ
			cGWU_CITORI := (cAliasGWU)->GWU_NRCIDO
			cGWU_CITDES := (cAliasGWU)->GWU_NRCIDD
			cGW1_CDREM  := GW1->GW1_CDREM
			cGW1_CDDEST := GW1->GW1_CDDEST
			cGWU_NRDC   := (cAliasGWU)->GWU_NRDC
				
			cValepGU3 := POSICIONE("GU3",1,xFilial("GU3") + (cAliasGWU)->GWU_CDTRP,"GU3_VALEP")

			// se a sequencia for diferente mas o transportador for mesmo ainda sim pode adicionar no array		
			If aScan(aGWT,{|x| x[1] == (cAliasGWU)->GWU_CDTRP}) == 0  .And. aScan(aGWT,{|x| x[2] == (cAliasGWU)->GWU_SEQ}) == 0;
			.Or. (aScan(aGWT,{|x| x[1] == (cAliasGWU)->GWU_CDTRP}) > 0 .And. aScan(aGWT,{|x| x[2] == (cAliasGWU)->GWU_SEQ}) == 0)
	
				oModelGWT:AddLine()
				oModelGWT:SetValue("GWT_NRROM"  ,GW1->GW1_NRROM)
				oModelGWT:SetValue("GWT_CDTRP"  ,(cAliasGWU)->GWU_CDTRP)
				oModelGWT:SetValue("GWT_SEQ"    ,(cAliasGWU)->GWU_SEQ)

				If (cAliasGWU)->GWU_SEQ = "01"
					If POSICIONE("GV4",1,xFilial("GV4") + GWN->GWN_CDTPOP,"GV4_PEDAG") == '1' 
						oModelGWT:SetValue("GWT_ADTPDG","2")
					EndIf				  	

					If GWN->GWN_CDTPVC != " "
						oModelGWT:SetValue("GWT_CDTPVC", GWN->GWN_CDTPVC)
					Else
						oModelGWT:SetValue("GWT_CDTPVC" ,(cAliasGWU)->GWU_CDTPVC)
					EndIf

					oModelGWT:SetValue("GWT_TPTRP", "1")
				Else
					oModelGWT:SetValue("GWT_CDTPVC" ,(cAliasGWU)->GWU_CDTPVC)
					oModelGWT:SetValue("GWT_TPTRP", "2")
									
					If POSICIONE("GV4",1,xFilial("GV4") + (cAliasGWU)->GWU_CDTPOP,"GV4_PEDAG") == '1'
						oModelGWT:SetValue("GWT_ADTPDG","2")
					EndIf
				EndIf		  

				If (cValepGU3 == '2' .Or. cValepGU3 == ' ') .Or. ((cAliasGWU)->GWU_PAGAR == "2")
					oModelGWT:SetValue("GWT_ADTPDG","2")
				Else
					oModelGWT:SetValue("GWT_VPCDOP",AllTrim(cOpVPMod))
				EndIf

				aAdd(aGWT, {(cAliasGWU)->GWU_CDTRP, (cAliasGWU)->GWU_SEQ})
			EndIf

			cValepGU3 := ""

			(cAliasGWU)->(dbSkip())

			aAdd(aTrecho,{cGWU_CDTRP,; 
						  cGWU_SEQ,;
						  cGWU_CITORI,;
						  cGWU_CITDES,;
						  cGW1_CDREM,;
						  cGW1_CDDEST,;
						  cGWU_NRDC,;
						  (cAliasGWU)->(Eof()),;
						  (cAliasGWU)->GWU_CDTRP})
		EndDo

		nQtdTrecho := 0	
		(cAliasGW1)->(dbSkip())
	EndDo	
	(cAliasGW1)->(dbCloseArea())
	
	If Select(cAliasGWU) > 0
		(cAliasGWU)->(dbCloseArea())
	EndIf
	
	While(nI <= oModelGWT:Length())
		oModelGWT:GoLine(nI)
		
		cOrdem := "0001"
		
		For nX := 1 To Len(aTrecho)
			If oModelGWT:GetValue("GWT_CDTRP") == aTrecho[nX][1] .And. oModelGWT:GetValue("GWT_SEQ") == aTrecho[nX][2] //se for mesmo transportador do trecho	
				If cOrdem == "0001"
					If oModelGWT:GetValue("GWT_SEQ") = "01"
						oModelGWR:SetValue("GWR_CDEMIT" ,aTrecho[nX][5])
						oModelGWR:SetValue("GWR_TPMOV" ,"1")
					Else
						oModelGWR:SetValue("GWR_CDEMIT" ,aTrecho[nX][1])
						oModelGWR:SetValue("GWR_TPMOV" ,"2")
					EndIf

					If Empty(aTrecho[nX][3]) .And. aTrecho[nX][8] == .T. .And. Len(aTrecho) == 1 
						oModelGWR:SetValue("GWR_NRCID"	,aTrecho[nX][4])
					Else
						If nX > 1 .And. Empty(aTrecho[nX][3])
							oModelGWR:SetValue("GWR_NRCID"	,aTrecho[nX - 1][4])
						Else
							oModelGWR:SetValue("GWR_NRCID"	,aTrecho[nX][3])
						EndIf
					EndIf
					oModelGWR:SetValue("GWR_ORDEM"	,cOrdem) // aTrecho[nX][2]

					cOrdem := SOMA1(cOrdem)
						
					If Len(aTrecho) == 1 .Or. aTrecho[NX][8] == .T.
						nContDoc++
						oModelGWR:AddLine()
						oModelGWR:SetValue("GWR_CDEMIT" ,aTrecho[nX][6])
						oModelGWR:SetValue("GWR_TPMOV" ,"3")
						oModelGWR:SetValue("GWR_NRCID"	,aTrecho[nX][4])
						oModelGWR:SetValue("GWR_ORDEM"	,cOrdem)
					Else
						oModelGWR:AddLine()
						oModelGWR:SetValue("GWR_CDEMIT" ,aTrecho[nX][9])
						oModelGWR:SetValue("GWR_TPMOV" ,"2")
						oModelGWR:SetValue("GWR_NRCID"	,aTrecho[nX][4])
						oModelGWR:SetValue("GWR_ORDEM"	,cOrdem)
					EndIf
				Else
					If aTrecho[NX][8] == .T.  // SE FOR ULTIMO TRECHO É UMA ENTREGA
						nContDoc++
						If oModelGWR:GetValue("GWR_NRCID") != aTrecho[nX][4] .Or. oModelGWR:GetValue("GWR_CDEMIT") != aTrecho[nX][6]
							If nContDoc > 1
								cOrdem := SOMA1(cOrdem)
							EndIf
							oModelGWR:AddLine()
							oModelGWR:SetValue("GWR_CDEMIT" ,aTrecho[nX][6])
							oModelGWR:SetValue("GWR_TPMOV" ,"3")
							oModelGWR:SetValue("GWR_NRCID"	,aTrecho[nX][4])
							oModelGWR:SetValue("GWR_ORDEM"	,cOrdem)
						Else
							If !Empty(aTrecho[nX][9])
								oModelGWR:AddLine()
								oModelGWR:SetValue("GWR_CDEMIT" ,aTrecho[nX][9])
								oModelGWR:SetValue("GWR_TPMOV" ,"2")
								oModelGWR:SetValue("GWR_NRCID"	,aTrecho[nX][4])
								oModelGWR:SetValue("GWR_ORDEM"	,cOrdem)
							EndIf
						EndIf
					Else
						If oModelGWR:GetValue("GWR_CDEMIT") != aTrecho[nX][9]
							oModelGWR:AddLine()
							oModelGWR:SetValue("GWR_CDEMIT" ,aTrecho[nX][9])
							oModelGWR:SetValue("GWR_TPMOV" ,"2")
							oModelGWR:SetValue("GWR_NRCID"	,aTrecho[nX][4])
							oModelGWR:SetValue("GWR_ORDEM"	,cOrdem)
						EndIf
					EndIf
				EndIf 
			EndIf
		Next nX

		GFEA050ETP(oModelGWR)
		
		nI++
	EndDo
	
	GFEA50ECVP(oModel)
	
	RestArea(aArea)
	oModelGWR:GoLine(1)
	oModelGWT:GoLine(1)
	oModelGWS:GoLine(1)
	
	oView:Refresh()
	oModel:GetModel( "GFEA050E_GWR" ):SetOnlyView()
	oModel:GetModel( "GFEA050E_GWT" ):SetOnlyView()
Return
// FIM da Funcao GFEA50EPOP
//======================================================================================================================

//====================================================================================================================\\
/*/{Protheus.doc}GFEA50ECMT
//====================================================================================================================
	@description
	Função referente ao commit do Model.

	@author		João Leonardo Schmidt
	@version	1.0
	@since		20 de Setembro de 2017
/*/
//===================================================================================================================\\
Static Function GFEA50ECMT(oModel)
	Local oModelGWT	:= oModel:GetModel("GFEA050E_GWT")
	Local nI		:= 1
		
	// Validações para verificar se os dados informados estão corretos
	While(nI <= oModelGWT:Length())
		oModelGWT:GoLine(nI)
		
		If oModelGWT:GetValue("GWT_ADTPDG") == "2"
			If oModelGWT:GetValue("GWT_VPVAL") > 0
				oModel:SetErrorMessage(,,,,,"Existe Valor de Pedágio para um trecho que não adianta pedágio.","O trecho está marcado como Não adianta pedágio e possui valor informado. Marque o trecho como adianta pedágio ou coloque o valor igual a 0")
				Return .F.
			EndIf
			If oModelGWT:GetValue("GWT_VPCDOP") != " "
				oModel:SetErrorMessage(,,,,,"Existe Operadora de Vale Pedágio para um trecho que não adianta pedágio.","O trecho está marcado como Não adianta pedágio e possui operadora informada. Marque o trecho como adianta pedágio ou retire a operadora de Vale Pedágio")
				Return .F.
			EndIf
		EndIf
		
		nI++		
	EndDo
				
	// Posiciona no registro relacionado ao transportador do embarque		
	oModelGWT:SeekLine({{"GWT_SEQ","01"}})
			
	GWN->(dbSetOrder(1))
	If GWN->(dbSeek(xFilial("GWN")+oModelGWT:GetValue("GWT_NRROM")))
		RecLock("GWN")
			GWN->GWN_VPVAL  := oModelGWT:GetValue("GWT_VPVAL")
			GWN->GWN_VPCDOP := oModelGWT:GetValue("GWT_VPCDOP")
			GWN->GWN_VPNUM  := oModelGWT:GetValue("GWT_VPNUM")
			GWN->GWN_VALEP  := oModelGWT:GetValue("GWT_VALEP")
			GWN->GWN_CALC   := "4"
		GWN->(MsUnlock())
	EndIf
	
	If lAltOrdem
        MSGALERT( "Roteiro foi alterado, sendo assim a tarifa de pedágio será recalculada automaticamente.", "Alteração de Roteiro" )
        GFEA50ERC(oModel)
	EndIf
    
Return .T.
// FIM da Funcao GFEA50CMT

//====================================================================================================================\\
/*/{Protheus.doc}GFEA50ECVP
//====================================================================================================================
	@description
	Função que realiza o cálculo do vale pedágio com base no roteiro.

	@author		João Leonardo Schmidt
	@version	1.0
	@since		23 de Setembro de 2017
/*/
//===================================================================================================================\\
Static Function GFEA50ECVP(oModel)
	Local oView		:= FWViewActive()
	Local oModelGWT	:= oModel:GetModel("GFEA050E_GWT")
	Local oModelGWR	:= oModel:GetModel("GFEA050E_GWR")
	Local oModelGWS := oModel:GetModel("GFEA050E_GWS")
	Local nIGWT     := 1	
	Local nIGWR     := 1
	Local cCidDe    := ""
	Local cCidAte   := ""
	Local cRegDe    := ""
	Local cRegAte   := ""
	Local cCatPed   := ""
	Local aRetPrPed := {}
	Local nX		:= 0
	Local nNrEixos, nCalPorEixo
	Local nSeqId    := ""
	Local nValorGWT := 0
	Local lTemTransb := .F.
	Local cCepIn	:= ""
	
	GFEA050ETP(oModelGWR)

	// Estrutura para realizar passagem por todos os transportadores
	While(nIGWT <= oModelGWT:Length())
		oModelGWT:GoLine(nIGWT)
		
		cCatPed := POSICIONE("GV3",1,xFilial("GV3") + oModelGWT:GetValue("GWT_CDTPVC"),"GV3_CATPED")
		
		nIGWR  	  := 1
		nSeqId 	  := "0001"
		nValorGWT := 0
		
		If(oModelGWT:GetValue("GWT_ADTPDG") == "1") // Adianta Pedagio
			
			//Verifica se tem redespacho
			lTemTransb := .F.
			While(nIGWR < oModelGWR:Length())
				// Montagem da Cidade Inicial do Trecho
				oModelGWR:GoLine(nIGWR)
				
				If oModelGWR:GetValue("GWR_TPMOV") == '1' //Coleta
					cCidDe := oModelGWR:GetValue("GWR_NRCID")
					cCepIn := oModelGWR:GetValue("GWR_CEP")
				EndIf
				
				If oModelGWR:GetValue("GWR_TPMOV") == '2' //Transbordo
					lTemTransb := .T.
				EndIf
				
				nIGWR++
			EndDo
			
			nIGWR := IIF(lTemTransb,1,0)
			
			// Estrutura para realizar a passagem por todos os roteiros do transportador
			While(nIGWR < oModelGWR:Length())
				
				/*Se tem transbordo: considera a sequencia das rotas. Se não tem transbordo: a origem é sempre "coleta"*/
				If lTemTransb  
					// Montagem da Cidade Inicial do Trecho
					oModelGWR:GoLine(nIGWR)
					cCidDe  := oModelGWR:GetValue("GWR_NRCID")
				EndIF
				
				// Montagem da Cidade Final do Trecho (Necessário passar a próxima linha da GRID)
				nIGWR++
				oModelGWR:GoLine(nIGWR)
					
				//Passa para a próxima linha da GRID se for tipo Coleta
				If !lTemTransb .And. oModelGWR:GetValue("GWR_TPMOV") == '1'
					nIGWR++
					oModelGWR:GoLine(nIGWR)
				EndIF

				cRegDe := GFEA50EREG(cCidDe,cCepIn)
				
				cCidAte := oModelGWR:GetValue("GWR_NRCID")
				cCepFim := oModelGWR:GetValue("GWR_CEP")
				cRegAte := GFEA50EREG(cCidAte,cCepFim)

				// Chama Função que retornará as praças de pegádio
				aRetPrPed := GFEA50EBPP(cCidDe,cCidAte,cCatPed,cRegDe,cRegAte)
				
				For nX := 1 To Len(aRetPrPed)
					If (nSeqId != "0001" .Or. oModelGWS:Length() != 1 .Or. IsInCallStack("GFEA50ERC")) .And. !Empty(oModelGWS:GetValue("GWS_NRPCPD"))
						oModelGWS:AddLine()
					EndIf
					oModelGWS:SetValue("GWS_NRROM",oModelGWT:GetValue("GWT_NRROM"))
					oModelGWS:SetValue("GWS_SEQ",oModelGWT:GetValue("GWT_SEQ"))
					oModelGWS:SetValue("GWS_CDTRP",oModelGWT:GetValue("GWT_CDTRP"))
					oModelGWS:SetValue("GWS_SEQID",nSeqId)
					oModelGWS:SetValue("GWS_NRPCPD",aRetPrPed[nX][1])
					oModelGWS:SetValue("GWS_DATVIG",SToD(aRetPrPed[Nx][3]))
					oModelGWS:SetValue("GWS_CATPED",cCatPed)
					oModelGWS:SetValue("GWS_NRCIDO",cCidDe)
					oModelGWS:SetValue("GWS_NRCIDD",cCidAte)
					
					If GFXCP12127("GWS_NRRGOR")
						oModelGWS:SetValue("GWS_NRRGOR",cRegDe)
						oModelGWS:SetValue("GWS_NRRGDS",cRegAte)
					Endif
					//DLOGGFE-11388 - atualizar GWS_VALOR com valor calculado quando categoria por eixo
					// Quando tarifa com categoria por Eixo, calcula Valor do Pedágio x Nr Eixos 
					If !Empty(aRetPrPed[Nx][4])
						nNrEixos := POSICIONE("GV3",1,xFilial("GV3") + oModelGWT:GetValue("GWT_CDTPVC"),"GV3_EIXOS")
						nCalPorEixo := aRetPrPed[nX][2] * nNrEixos  
						nValorGWT += nCalPorEixo
						oModelGWS:SetValue("GWS_VALOR", nCalPorEixo)

					Else 
						nValorGWT += aRetPrPed[nX][2]
						oModelGWS:SetValue("GWS_VALOR",aRetPrPed[Nx][2])
					EndIf
					

					nSeqId := SOMA1(nSeqId)
				Next nX
			EndDo
		EndIf
		oModelGWS:GoLine(1)
			
		oModelGWT:SetValue("GWT_VPVAL",nValorGWT)
		nIGWT++		
	EndDo
	
	oModelGWT:GoLine(1)
	oModelGWR:GoLine(1)
	oModelGWS:GoLine(1)
	oView:Refresh()
Return

//====================================================================================================================\\
/*/{Protheus.doc}GFEA50EREG
//====================================================================================================================
	@description Verifica se as cidades e/ou ceps de origem e destino do roteiro estão vinculadas a alguma Região

	@author		Gabriela Lima
	@version	1.0
	@since		26 de Setembro de 2019
/*/
//===================================================================================================================\\
Static Function GFEA50EREG(cNrCid,cCep)
	Local lVinc := .F.
	Local cRegDe := ""
	Local cRegAte := ""
	local cReg := ""
	Private cAliGu9 := GetNextAlias()
	

	GUA->(dbGoTop())
	GUA->(dbsetOrder(2)) // GUA_FILIAL+GUA_NRCID						
	While !GUA->(Eof()) 
		If GUA->(dbSeek(xFilial("GUA")+cNrCid))
			GU9->(dbGoTop())
			GU9->(dbsetOrder(1)) // GU9_FILIAL+GU9_NRREG						
			While !GU9->(Eof()) 
				If GU9->(dbSeek(xFilial("GU9")+GUA->GUA_NRREG))
					If GU9->GU9_DEMCID == '2' .And.	!POSICIONE("GVR",1,xFilial("GVR")+GU9->GU9_NRREG,"") 
						cReg := GU9->GU9_NRREG
						lVinc := .T.
						Exit
					EndIf
				Endif
				GU9->(dbSkip())
			EndDo

			If lVinc
				Exit	
			EndIf

		EndIf
		GUA->(dbSkip())
	EndDo
	
	If !lVinc
	
		cQuery := "SELECT * FROM " + RetSQLName("GUL") + " GUL "
		cQuery += " INNER JOIN " + RetSqlName("GU9")  + " GU9 " + " ON GUL_NRREG = GU9_NRREG "		
		cQuery += " WHERE ( GUL.GUL_CEPINI >= '" + cCep + "'
		cQuery += " OR   GUL.GUL_CEPFIM <= '" + cCep + "')  
		cQuery += " AND GUL.D_E_L_E_T_ = ' '"
		cQuery += " AND GU9.D_E_L_E_T_ = ' '"
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliGu9, .F., .T.)
		
		dbSelectArea(cAliGu9)
		(cAliGu9)->(dbGoTop())
		
		While !(cAliGu9)->(EoF())
		
			cReg := (cAliGu9)->GU9_NRREG
						
			Exit
			(cAliGu9)->(dbSkip())
		EndDo	
	EndIf
	

Return cReg

//====================================================================================================================\\
/*/{Protheus.doc}GFEA50EBPP
//====================================================================================================================
	@description
	Função de busca das praças de pedágio e que efetua o retorno para gravação na GWS

	@author		João Leonardo Schmidt
	@version	1.0
	@since		23 de Setembro de 2017
/*/
//===================================================================================================================\\
Static Function GFEA50EBPP(cCidDe,cCidAte,cCatPed,cRegDe,cRegAte)
	Local cQuery 	:= ""
	Local aRetPrPed := {}
	Local cNRPCPD := ""
	
	Default cCidDe  := ""
	Default cCidAte := ""
	Default cRegDe  := ""
	Default cRegAte := ""
	Default cCatPed := ""
		
	Private cAliPrPed := GetNextAlias()
	

	cQuery := "SELECT DISTINCT GVY_NRPCPD, GVY_VALOR, GVY_DATVIG, GVY_CATPED FROM ((" + RetSQLName("GVX") + " GVX "
	cQuery += " INNER JOIN " + RetSqlName("GVZ")  + " GVZ " + " ON GVX_FILIAL = GVZ_FILIAL AND GVX_NRPCPD = GVZ_NRPCPD)"
	cQuery += " INNER JOIN " + RetSqlName("GVY")  + " GVY " + " ON GVX_FILIAL = GVY_FILIAL AND GVX_NRPCPD = GVY_NRPCPD)"		
	cQuery += " WHERE GVX.GVX_MSBLQL = '2' "
	cQuery += "AND ( "
		cQuery += " GVZ.GVZ_NRCIDO = '" + cCidDe + "'"
	If GFXCP12127("GVZ_NRRGOR")
		If !Empty(cRegDe)
			cQuery += " OR GVZ.GVZ_NRRGOR = '" + cRegDe + "'"
		EndIf
	Endif
	cQuery += ") AND ("
		cQuery += " GVZ.GVZ_NRCIDD = '" + cCidAte + "'"
	If GFXCP12127("GVZ_NRRGDS")
		If !Empty(cRegAte)
			cQuery += " OR GVZ.GVZ_NRRGDS = '" + cRegAte + "'"
		EndIf
	Endif
	cQuery += ")"
	cQuery += " AND (GVY.GVY_CATPED = '" + cCatPed + "' OR  GVY.GVY_CATPED = 'E') AND GVY.GVY_DATVIG <= '" + DToS(dDataBase) + "'"
	cQuery += " AND GVY.D_E_L_E_T_ = ' '"
	cQuery += " AND GVX.D_E_L_E_T_ = ' '"
	cQuery += " AND GVZ.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY GVY.GVY_NRPCPD, GVY.GVY_VALOR, GVY.GVY_DATVIG, GVY.GVY_CATPED DESC "
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliPrPed, .F., .T.)
	

	dbSelectArea(cAliPrPed)
	(cAliPrPed)->(dbGoTop())
	
	While !(cAliPrPed)->(EoF())
		
		//Tratamento para selecionar apenas a ultima vigencia
		if empty(cNRPCPD) .Or. cNRPCPD <> (cAliPrPed)->GVY_NRPCPD
			AADD(aRetPrPed,{(cAliPrPed)->GVY_NRPCPD,(cAliPrPed)->GVY_VALOR,(cAliPrPed)->GVY_DATVIG,Iif(AllTrim((cAliPrPed)->GVY_CATPED) == "E","PorEixo","")})
			cNRPCPD := (cAliPrPed)->GVY_NRPCPD
		EndIf
		
		(cAliPrPed)->(dbSkip())
	EndDo
	
	GFEDelTab(cAliPrPed)
Return aRetPrPed

//====================================================================================================================\\
/*/{Protheus.doc}GFEA50EOP
//====================================================================================================================
	@description
	Função ao Abrir a VIEW. Adiciona Botões.

	@author		João Leonardo Schmidt
	@version	1.0
	@since		24 de Setembro de 2017
/*/
//===================================================================================================================\\
Static Function GFEA50EOP(oView)
	
	If oView:oModel:GetOperation() == 4 .or. oView:oModel:GetOperation() == 3
		// Adiciona os botões de usuário
		oView:addUserButton("Recalcular Tarifas"	,"", {|oFw| GFEA50ERC(oView:oModel) })
	EndIf
	
Return .T.
// FIM da Funcao GFEA50EOP

//====================================================================================================================\\
/*/{Protheus.doc}GFEA50ERC
//====================================================================================================================
	@description
	Função para executar o Recálculo

	@author		João Leonardo Schmidt
	@version	1.0
	@since		24 de Setembro de 2017
/*/
//===================================================================================================================\\
Static Function GFEA50ERC(oModel)
	Local oModelGWT := oModel:GetModel("GFEA050E_GWT")
	Local oModelGWS := oModel:GetModel("GFEA050E_GWS")
	Local nIGWT := 0
	Local nIGWS := 0
	
	nIGWT := 1
	While nIGWT <= oModelGWT:Length()
		oModelGWT:GoLine(nIGWT)
		
		nIGWS := 1
		While nIGWS <= oModelGWS:Length()
			oModelGWS:GoLine(nIGWS)
			
			If oModelGWS:GetValue("GWS_VALOR") > 0 .And. oModelGWS:GetValue("GWS_NRPCPD") != " "
				oModelGWS:DeleteLine()
			EndIf
			
			nIGWS++
		EndDo
		
		nIGWT++
	EndDo

	lAltOrdem := .F.
	
	GFEA50ECVP(oModel)
	
Return .T.
// FIM da Funcao GFEA50EOP

//====================================================================================================================\\
/*/{Protheus.doc}GFEA050ESEQ
//====================================================================================================================
	@description
	Função que numera as sequencias.

	@author		Leonardo Ribas Jimenez Hernandez
	@version	1.0
	@since		01 de Março de 2018
/*/
//===================================================================================================================\\

Function GFEA050ESEQ(oFW, cId, xValue)
	Local oView			:= FWViewActive()
	Local oModelGrid	:= oFW
	Local cSeq			:= xValue := PADL(Alltrim(xValue),GetSx3Cache(cId,"X3_TAMANHO"),"0")
	Local nLinTmp		:= oModelGrid:GetLine()
	Local nLinAtu		:= 0
	Local nCampo		:= 0
	Local nID			:= 0
	Local aDados		:= {}
	Local aCampoGrid	:= aClone(oModelGrid:oFormModelStruct:GetFields())
	Local aLinha		:= {}
	Local lDelete		:= .F.
	Local lRet 			:= oModelGrid:LoadValue(cId,xValue)//Preenche com 0 a esquerda
	
	//Atualiza Valores
	If lRet
		For nLinAtu := 1 To oModelGrid:GetQTDLine()
			 // Direciona a linha do For
			oModelGrid:GoLine(nLinAtu)
			
			If !oModelGrid:IsDeleted(nLinAtu) .And. oModelGrid:GetValue(cId,nLinAtu) >= xValue
				If nLinAtu != nLinTmp
					cSeq := SOMA1(cSeq)
					// Preenche com o proximo numero
					oModelGrid:LoadValue(cId,cSeq)
				EndIf
			EndIf
		Next nLinAtu
		
		// Amazena dados a serem inseridos novamente na MODEL
		For nLinAtu := 1 To oModelGrid:GetQTDLine()
			 // Direciona a linha do For
			oModelGrid:GoLine(nLinAtu)

			lDelete	:= oModelGrid:IsDeleted(nLinAtu)
			
			aLinha := {}
			
			For nCampo := 1 to Len(aCampoGrid)
				cCampo := aCampoGrid[nCampo][MODEL_FIELD_IDFIELD]
				
				// Id - Se linha estiver Deletada jogar no final do GRID
				If cCampo == cId
					nID := nCampo 
					Aadd(aLinha,Iif(lDelete,"9999",oModelGrid:GetValue(cId,nLinAtu)))
				Else
					Aadd(aLinha,oModelGrid:GetValue(cCampo,nLinAtu))
				EndIf
				
			Next nCampo
			// Ultima coluna define se linha esta deletada
			Aadd(aLinha,lDelete)
			
			Aadd(aDados,aLinha)
		Next nLinAtu

		ASORT(aDados, , , { | x,y | x[nID] < y[nID] } )
			
		//Insere Dados Novamente na MODEL
		cSeq := PADL("0",GetSx3Cache(cId,"X3_TAMANHO"),"0")
		
		For nLinAtu := 1 To Len(aDados)
			oModelGrid:GoLine(nLinAtu) // Direciona a linha do For
			
			If oModelGrid:IsDeleted(nLinAtu)
				oModelGrid:UnDeleteLine()
			EndIf
			
			cSeq := SOMA1(cSeq)
			
			For nCampo := 1 to Len(aCampoGrid)
				cCampo := aCampoGrid[nCampo][MODEL_FIELD_IDFIELD]
				
				// Define novamente a Sequencia
				If cCampo == cId
					oModelGrid:LoadValue(cId,cSeq)
				Else
					oModelGrid:LoadValue(cCampo,aDados[nLinAtu][nCampo])
				EndIf
				
			Next nCampo
			
			// Ultima coluna define se linha esta deletada
			If aDados[nLinAtu][Len(aDados[nLinAtu])]
				oModelGrid:DeleteLine()
			EndIf
		Next nLinAtu
		
		oModelGrid:GoLine(nLinTmp)
		oView:Refresh()
	EndIf
	lAltOrdem := .T.
	
Return lRet
// FIM da Funcao GFEA050ESEQ

//====================================================================================================================\\
/*/{Protheus.doc}GFEA050ETP
//====================================================================================================================
	@description
	Função que ajusta o tipo da linha para correta definição da busca das praças de pedágio

	@author		João Leonardo Schmidt
	@version	1.0
	@since		26/10/2020
/*/
//===================================================================================================================\\

Function GFEA050ETP(oModelGWR)
	Local nX := 0

	Default oModelGWR := ""

	// Verifica se o ModelGWR está diferente de vazio para efetuar os tratamentos
	If !Empty(oModelGWR)
		// Tratamento para que quando existir mais de uma entrega, somente a última seja considerada como entrega
		// As demais entregas dos documentos de carga, serão considerados transbordos para que seja possível 
		// montar a viagem de acordo com a lógica de transporte
		For nX := 1 To oModelGWR:GetQtdLine()
			If nX <> 1 .And. nX <> oModelGWR:GetQtdLine()
				oModelGWR:GoLine(nX)

				// Transbordo				
				oModelGWR:SetValue("GWR_TPMOV" ,"2")
			ElseIf nX == oModelGWR:GetQtdLine()
				oModelGWR:GoLine(nX)

				// Entrega				
				oModelGWR:SetValue("GWR_TPMOV" ,"3")
			EndIf
		Next nX
	EndIf
Return .T.
