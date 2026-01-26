#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA380.CH"

/*/{Protheus.doc} OFIA380
	Cadastro de Tipos de Serviços Especializados

	@author Andre Luis Almeida
	@since 17/08/2022
/*/
Function OFIA380()
Local cQuery      := ""
Local cAuxAlias   := "SQLAUX"
Private cCadastro := STR0001 // Cadastro de Tipos de Serviços Especializados
Private _Grupos_Filtro := "" // Variavel usada na consulta padrao SXB -> SB1VPW
//
cQuery := "SELECT BM_GRUPO "
cQuery += "  FROM " + RetSQLName("SBM")
cQuery += " WHERE BM_FILIAL  = '" + xFilial("SBM") + "'"
cQuery += "   AND BM_TIPGRU  = '12' " // Serviços Especializados
cQuery += "   AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
While !(cAuxAlias)->(Eof())
	_Grupos_Filtro += "'" + (cAuxAlias)->(BM_GRUPO) + "',"
	(cAuxAlias)->(DbSkip())
EndDo
(cAuxAlias)->(DbCloseArea())
If !Empty(_Grupos_Filtro)
	_Grupos_Filtro := left(_Grupos_Filtro,len(_Grupos_Filtro)-1)
Else
	_Grupos_Filtro := "'NAO_RELACIONAR'"
EndIf
//
oBrwVPV := FWMBrowse():New()
oBrwVPV:SetAlias('VPV')
oBrwVPV:SetDescription(cCadastro)
oBrwVPV:AddButton(STR0002,{|| OA3800031_EstoqueTotal(VPV->VPV_CODTIP,VPV->VPV_DESTIP) },,2,2) // Totais de Estoque do Tipo de Serviço Especializado
oBrwVPV:AddButton(STR0003,{|| OFIA450("",VPV->VPV_CODTIP) },,2,2) // Visualiza Serviços Especializados do Tipo posicionado
oBrwVPV:DisableDetails()
oBrwVPV:SetAmbiente(.F.)
oBrwVPV:SetWalkthru(.F.)
oBrwVPV:SetUseFilter()
oBrwVPV:ForceQuitButton()
oBrwVPV:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}
	aRotina := FWMVCMenu('OFIA380')
	ADD OPTION aRotina TITLE STR0017 ACTION 'OA3800051_ImprimirTipoServico()' OPERATION 8 ACCESS 0 // Imprimir Dados do Tipo de Serviço e Regras de Valores

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVPV := FWFormStruct(1,"VPV")
	Local oStrVRV := FWFormStruct(1,"VRV")

	oModel := MPFormModel():New('OFIA380',,,,)
	oModel:AddFields('VPVMASTER',/*cOwner*/ , oStrVPV)
	oModel:AddGrid( "VRVDETAIL" , "VPVMASTER", oStrVRV , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
	oModel:SetRelation("VRVDETAIL", {{'VRV_FILIAL','VPV_FILIAL'}, {'VRV_CODVPV','VPV_CODTIP'}}, VRV->(IndexKey(1)) )

	oModel:SetDescription(STR0004) // Cadastro do Tipo de Serviço Especializado
	oModel:GetModel('VPVMASTER'):SetDescription(STR0004) // Cadastro do Tipo de Serviço Especializado
	oModel:GetModel("VRVDETAIL"):SetDescription(STR0005) // Regras de Valores do Tipo de Serviço Especializado
	oModel:GetModel("VRVDETAIL"):SetOptional(.T.) // Deixa passar com o Valores em branco
//	oModel:InstallEvent("OFIA380LOG", /*cOwner*/, MVCLOGEV():New("OFIA380") ) // CONSOLE.LOG para verificar as chamadas dos eventos
	oModel:InstallEvent("OFIA380EVDEF", /*cOwner*/, OFIA380EVDEF():New("OFIA380"))

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVPV:= FWFormStruct(2,"VPV")
	Local oStrVRV:= FWFormStruct(2,"VRV", { |cCampo| !ALLTRIM(cCampo) $ "VRV_CODIGO/VRV_CODVPV/" } )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:CreateHorizontalBox( 'BOXVPV', 50)
	oView:CreateHorizontalBox( 'BOXVRV', 50)
	oView:AddField('VIEW_VPV', oStrVPV, 'VPVMASTER')
	oView:AddGrid( 'VIEW_VRV' , oStrVRV, 'VRVDETAIL' )
	oView:EnableTitleView('VIEW_VPV', STR0004) // Cadastro do Tipo de Serviço Especializado
	oView:EnableTitleView('VIEW_VRV', STR0005) // Regras de Valores do Tipo de Serviço Especializado
	oView:SetOwnerView('VIEW_VPV','BOXVPV')
	oView:SetOwnerView('VIEW_VRV','BOXVRV')

	oView:AddUserButton(STR0017,'IMPRESSAO', {|| OA3800071_ValidaImpressao() }) // Imprimir Dados do Tipo de Serviço e Regras de Valores

Return oView

/*/{Protheus.doc} OA3800011_TipoUsado
Verifica se foi utilizado o Tipo no Servico Especializado

@author Andre Luis Almeida
@since 19/08/2022
/*/
Function OA3800011_TipoUsado(cCodigo)
Local cQuery := ""
cQuery := "SELECT R_E_C_N_O_"
cQuery += "  FROM "+RetSQLName('VPX')
cQuery += " WHERE VPX_FILIAL = '"+xFilial("VPX")+"'"
cQuery += "   AND VPX_TIPSER = '"+cCodigo+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
Return ( FM_SQL( cQuery ) > 0 )

/*/{Protheus.doc} OA3800021_WHEN_VPV
WHEN dos campos VPV

@author Andre Luis Almeida
@since 23/08/2022
/*/
Function OA3800021_WHEN_VPV(cCampo)
Local lRet := .f.
If Inclui .or. !OA3800011_TipoUsado(VPV->VPV_CODTIP)
	Do Case
		Case cCampo == "VPV_FILCEN"
			If M->VPV_CTRSLD <> "0" // Controla Saldo de alguma forma
				lRet := .t.
			EndIf
		Case cCampo == "VPV_RELSAI"
			If M->VPV_CTRSLD == "0" // Se NAO Controla Saldo
				lRet := .t.
			EndIf
	EndCase
EndIf
Return lRet

/*/{Protheus.doc} OA3800031_EstoqueTotal()
Retorna a Qtde do Estoque Total de um determinado Tipo de Serviço Especializado

@author Andre Luis Almeida
@since 26/08/2022
/*/
Function OA3800031_EstoqueTotal(cCodigo,cDescr)
Local aIntCab   := {}
Local aIntLin   := {}
Local cQuery    := ""
Local cAuxAlias := "SQLAUX"
Default cDescr  := FM_SQL("SELECT VPV_DESTIP FROM "+RetSQLName('VPV')+" WHERE VPV_FILIAL='"+xFilial("VPV")+"' AND VPV_CODTIP='"+cCodigo+"' AND D_E_L_E_T_=' '")
Private cCadastro := STR0014+" - "+STR0015+": "+Alltrim(cCodigo)+" - "+Alltrim(cDescr) // Estoque do Serviço Especializado / Tipo de Serviço
aadd( aIntLin , { STR0016 , 0 }) // TODAS FILIAIS
cQuery := "SELECT VPY.VPY_FILEST , SUM(VPY.VPY_QTDEST) AS QTDEST"
cQuery += "  FROM "+RetSQLName('VPY')+" VPY "
cQuery += "  JOIN "+RetSQLName('VPX')+" VPX ON VPX.VPX_FILIAL = VPY.VPY_FILIAL AND VPX.VPX_SERINT = VPY.VPY_SERINT AND VPX.D_E_L_E_T_ = ' ' "
cQuery += " WHERE VPY.VPY_FILIAL = '"+xFilial("VPY")+"'"
cQuery += "   AND VPX.VPX_TIPSER = '"+cCodigo+"'"
cQuery += "   AND VPY.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY VPY.VPY_FILEST"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
While !(cAuxAlias)->(Eof())
	aadd( aIntLin , { (cAuxAlias)->(VPY_FILEST)+" - "+FWFilialName( , (cAuxAlias)->(VPY_FILEST) ) , (cAuxAlias)->(QTDEST) })
	aIntLin[1,2] += (cAuxAlias)->(QTDEST)
	(cAuxAlias)->(DbSkip())
EndDo
(cAuxAlias)->(DbCloseArea())
DbSelectArea("VPX")
If len(aIntLin) > 1
	aAdd(aIntCab,{ Alltrim(cCodigo)+" - "+Alltrim(cDescr) , "C" , 300 , "@!" })
	aAdd(aIntCab,{ RetTitle("VPY_QTDEST") , "N" , 100 , "@E 999,999,999,999,999" })
	FGX_VISINT( "OFIA380" , cCadastro , aIntCab , aIntLin , .t. )
Else
	MsgStop(STR0007,STR0006) // Estoque inexistente para o Tipo de Serviço Especializado. Impossível continuar. / Atencao
EndIf
Return

/*/{Protheus.doc} OA3800041_Valor
Retorna o "1-Valor Sugerido de Venda" ou "2-Valor Minimo" por Tipo de Serviço

@author Andre Luis Almeida
@since 22/12/2022
/*/
Function OA3800041_Valor( cTipo , cSerInt , cTipSer , cGruSer , cCodCli , cLojCli , nCusto )
Local nVlrRet := 0
Local nRecVRV := 0
Local cQAlias := "SQLSA1VCF"
Local cQuery  := ""
Local cEstCli := " "
Local cNivImp := " "
Local cGruEcn := " "
//
nCusto := IIf( nCusto > 0 , nCusto , OA4600131_ValorUltimaEntrada( cSerInt ) ) // Retorna Custo Medio ou Valor Unitario da Ultima Entrada
//
cQuery := "SELECT SA1.A1_EST , VCF.VCF_NIVIMP , VCF.VCF_GRUECN"
cQuery += "  FROM "+RetSQLName('SA1')+" SA1"
cQuery += "  LEFT JOIN "+RetSQLName('VCF')+" VCF"
cQuery += "    ON VCF.VCF_FILIAL = SA1.A1_FILIAL"
cQuery += "   AND VCF.VCF_CODCLI = SA1.A1_COD"
cQuery += "   AND VCF.VCF_LOJCLI = SA1.A1_LOJA"
cQuery += "   AND VCF.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SA1.A1_COD     = '"+cCodCli+"'"
cQuery += "   AND SA1.A1_LOJA    = '"+cLojCli+"'"
cQuery += "   AND SA1.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
If !(cQAlias)->(Eof())
	cEstCli := (cQAlias)->( A1_EST )
	cNivImp := (cQAlias)->( VCF_NIVIMP )
	cGruEcn := (cQAlias)->( VCF_GRUECN )
	(cQAlias)->(DbSkip())
EndIf
(cQAlias)->(DbCloseArea())
DbSelectArea("VRV")
cQuery := "SELECT R_E_C_N_O_ AS RECVRV "
cQuery += "  FROM "+RetSQLName('VRV')
cQuery += " WHERE VRV_FILIAL = '" + xFilial("VRV") + "'"
cQuery += "   AND VRV_CODVPV = '" + cTipSer + "'"
cQuery += "   AND VRV_DATINI <= '" + dtos(dDataBase) + "'"
cQuery += "   AND VRV_DATFIN >= '" + dtos(dDataBase) + "'"
cQuery += "   AND ( VRV_GRUSER = '" + cGruSer + "'" + IIf( !Empty(cGruSer) , " OR VRV_GRUSER = ' ' " , " " ) + ")"
cQuery += "   AND ( VRV_ESTCLI = '" + cEstCli + "'" + IIf( !Empty(cEstCli) , " OR VRV_ESTCLI = ' ' " , " " ) + ")"
cQuery += "   AND ( VRV_NIVIMP = '" + cNivImp + "'" + IIf( !Empty(cNivImp) , " OR VRV_NIVIMP = ' ' " , " " ) + ")"
cQuery += "   AND ( VRV_GRUECN = '" + cGruEcn + "'" + IIf( !Empty(cGruEcn) , " OR VRV_GRUECN = ' ' " , " " ) + ")"
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VRV_GRUSER DESC , VRV_ESTCLI DESC , VRV_NIVIMP DESC , VRV_GRUECN DESC "
nRecVRV := FM_SQL(cQuery)
If nRecVRV > 0
	VRV->(DbGoto(nRecVRV))
	If cTipo == "1" // Valor Sugerido de Venda
		If VRV->VRV_SUGVDA > 0
			nVlrRet := VRV->VRV_SUGVDA
		Else
			nVlrRet := ( ( VRV->VRV_PERSUG/100 ) * nCusto ) // % em cima do Custo ( Medio ou Ultima Entrada )
		EndIf
	ElseIf cTipo == "2" // Valor Minimo
		If VRV->VRV_VLRMIN > 0
			nVlrRet := VRV->VRV_VLRMIN
		Else
			nVlrRet := ( ( VRV->VRV_PERMIN/100 ) * nCusto ) // % em cima do Custo ( Medio ou Ultima Entrada )
		EndIf
	EndIf
EndIf
Return nVlrRet

/*/{Protheus.doc} OA3800051_ImprimirTipoServico
Impressão dos Dados do Tipo de Serviço

@author Andre Luis Almeida
@since 02/01/2023
/*/
Function OA3800051_ImprimirTipoServico()
Local aArea     := GetArea()
//
oReport := ReportDef()
oReport:PrintDialog()
RestArea( aArea )
//
Return

/*/{Protheus.doc} ReportDef
	ReportDef para tReport

	@author Andre Luis Almeida
	@since 02/01/2023
/*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local aStrVPV   := FWFormStruct(3,"VPV",{ |x| !AllTrim(x) $ "VPV_FILIAL/" })
Local aStrVRV   := FWFormStruct(3,"VRV",{ |x| !AllTrim(x) $ "VRV_FILIAL/VRV_CODIGO/VRV_CODVPV/" })
Local nCntFor   := 0
Local cCampo    := ""
//
oReport := TReport():New("OFIA380",cCadastro,,{|oReport| OA3800061_TReport( oReport )})
oReport:SetLandscape() // Imprime o relatório em Paisagem
//
oSection1 := TRSection():New(oReport,STR0015,{"VPV"}) // Tipo de Serviço
For nCntFor := 1 to Len(aStrVPV[FORM_STRUCT_TABLE_MODEL])
	cCampo := aStrVPV[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]
	If !aStrVPV[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MODEL_FIELD_VIRTUAL ] // Campos Reais
		TRCell():New(oSection1,cCampo,"VPV",,,)
	Else // Campos Virtuais
		Do Case
			Case cCampo == "VPV_GRUITE"
				TRCell():New(oSection1,cCampo,"VPV",,,,, {|| cVPV_GRUITE },,,,,,,,,)
			Case cCampo == "VPV_CODITE"
				TRCell():New(oSection1,cCampo,"VPV",,,,, {|| cVPV_CODITE },,,,,,,,,)
			Case cCampo == "VPV_DESITE"
				TRCell():New(oSection1,cCampo,"VPV",,,,, {|| cVPV_DESITE },,,,,,,,,)
		EndCase
	EndIf
Next
//
oSection2 := TRSection():New(oReport,STR0005,{"VRV"}) // Regras de Valores do Tipo de Serviço Especializado
For nCntFor := 1 to Len(aStrVRV[FORM_STRUCT_TABLE_MODEL])
	cCampo := aStrVRV[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]
	If !aStrVRV[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MODEL_FIELD_VIRTUAL ] // Campos Reais
		TRCell():New(oSection2,cCampo,"VRV",,,)
	EndIf
Next
//
Return oReport

/*/{Protheus.doc} OA3800061_TReport
	Impressao em tReport

	@author Andre Luis Almeida
	@since 02/01/2023
/*/
Static Function OA3800061_TReport( oReport )
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local cQuery    := ""
Private cVPV_GRUITE := ""
Private cVPV_CODITE := ""
Private cVPV_DESITE := ""
//
cQuery := "SELECT COUNT(*) "
cQuery += "  FROM " + RetSqlName("VRV")
cQuery += " WHERE VRV_FILIAL = '" + VPV->VPV_FILIAL + "'"
cQuery += "   AND VRV_CODVPV = '" + VPV->VPV_CODTIP + "'"
cQuery += "   AND D_E_L_E_T_= ' '"
oReport:SetMeter(FM_SQL(cQuery))
//
SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+VPV->VPV_CODSB1))
cVPV_GRUITE := SB1->B1_GRUPO
cVPV_CODITE := SB1->B1_CODITE
cVPV_DESITE := SB1->B1_DESC
//
oSection1:Init()
oSection1:PrintLine() // VPV
oSection1:Finish()
//
oReport:SkipLine()
oReport:SkipLine()
//
oSection2:Init()
DbSelectArea("VRV")
DbSetOrder(2) // VRV_FILIAL + VRV_CODVPV
DbSeek( VPV->VPV_FILIAL + VPV->VPV_CODTIP )
Do While !VRV->(Eof()) .and. VRV->VRV_FILIAL == VPV->VPV_FILIAL .and. VRV->VRV_CODVPV == VPV->VPV_CODTIP
	oReport:IncMeter()
	oSection2:PrintLine() // VRV
	dbSelectArea("VRV")
	dbSkip()
EndDo
oSection2:Finish()
//
Return Nil

/*/{Protheus.doc} OA3800071_ValidaImpressao
Valida se pode Imprimir os Dados do Tipo de Serviço

@author Andre Luis Almeida
@since 02/01/2023
/*/
Static Function OA3800071_ValidaImpressao()
Local lImprime   := .t.
Local oModel     := FWModelActive()
Local nOperModel := oModel:GetOperation()
If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	lImprime := .f.
	Help("",1,"OA3800071_ValidaImpressao",,STR0018,1,0) // Opção não disponivel na Inclusão/Alteração do Tipo de Serviço. Necessário SALVAR e acessar a Impressão via MENU ou através da Visualização do Tipo de Serviço.
EndIf
If lImprime
	OA3800051_ImprimirTipoServico()
EndIf
Return