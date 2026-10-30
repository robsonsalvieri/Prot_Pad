#INCLUDE "GFEC080.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
/*------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC080
CONSULTA DO CALCULO DE FRETE
Generico

@sample
GFEC080()

@author Luiz Fernando Soares
@since 10/03/2010
@version 1.0
------------------------------------------------------------------------------------------------*/
 
Function GFEC080()
Local oBrowse



oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GWF")			// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEC080")   // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription("Consulta de Cálculos de Frete")	//"Consulta do Cálculo de Frete"
oBrowse:Activate()

Return(Nil)

//-------------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0007 ACTION "AxPesqui"        OPERATION 1  ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEC080" OPERATION 2  ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.GFEC080" OPERATION 8  ACCESS 0 //"Imprimir"

Return aRotina

//-------------------------------------------------------------------------------------------------------

Static Function ModelDef()
	Local oModel
	Local oStruGWG := FWFormStruct(1, 'GWG', /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruGWI := FWFormStruct(1, 'GWI', /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruGWH := FWFormStruct(1, 'GWH', /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruGWF := FWFormStruct(1, 'GWF', /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruGWA := FWFormStruct(1, "GWA", /*bAvalCampo*/, /*lViewUsado*/)

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New('GFEC080 ', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição

	oModel:AddFields('GFEC080_GWF', , oStruGWF,/*bPre*/,/*bPost*/,/*{|ox|teste(ox)}bLoad*/)

	oModel:AddGrid('GFEC080_GWG','GFEC080_GWF',oStruGWG,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid('GFEC080_GWI','GFEC080_GWF',oStruGWI,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid('GFEC080_GWH','GFEC080_GWF',oStruGWH,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid('GFEC080_GWA','GFEC080_GWF',oStruGWA,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:SetRelation('GFEC080_GWG',{{'GWG_FILIAL','GWF_FILIAL'},{'GWG_NRCALC' ,'GWF_NRCALC' }},'GWG_FILIAL+GWG_NRCALC')
	oModel:SetRelation('GFEC080_GWI',{{'GWI_FILIAL','GWF_FILIAL'},{'GWI_NRCALC' ,'GWF_NRCALC' }},'GWI_FILIAL+GWI_NRCALC')
	oModel:SetRelation('GFEC080_GWH',{{'GWH_FILIAL','GWF_FILIAL'},{'GWH_NRCALC' ,'GWF_NRCALC' }},'GWH_FILIAL+GWH_NRCALC')
	oModel:SetRelation('GFEC080_GWA',{{'GWA_FILIAL','GWF_FILIAL'},{'GWA_TPDOC'  ,'"1"'        },{'GWA_CDEMIT','GWF_TRANSP'},{'GWA_NRDOC','GWF_NRCALC' }},'GWA_FILIAL+GWA_NRDOC')
	
	oModel:AddCalc('GFEC080_CALC' ,'GFEC080_GWF','GFEC080_GWI','GWI_VLFRET','GWI__TOT01','SUM',{ | oFW | oFw:GetValue('GFEC080_GWI','GWI_TOTFRE') == '1'}, { | oFW | oFw:GetValue('GFEC080_GWF','GWF_VLAJUS') })
	oModel:SetDescription("Cálculos de Frete")

Return oModel

//-------------------------------------------------------------------------------------------------------

Static Function ViewDef()

Local oModel     := FWLoadModel('GFEC080 ')
Local oView      := Nil
Local oStructGWG := FWFormStruct(2,'GWG')
Local oStructGWI := FWFormStruct(2,'GWI')
Local oStructGWH := FWFormStruct(2,'GWH')
Local oStructGWF := FWFormStruct(2,'GWF')
Local oStructGWA := FWFormStruct(2,'GWA')
Local lExistCamp := GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1") .And. (FindFunction("GFEA065VFIX") .And. GFEA065VFIX())

If AScan(oStructGWF:aFields,{|x| x[1] == "GWF_FILIAL"}) != 0
  oStructGWF:RemoveField("GWF_FILIAL")
EndIf
oStructGWA:RemoveField("GWA_CDTRAN")
oStructGWA:RemoveField("GWA_TPDOC")
oStructGWA:RemoveField("GWA_CDESP")
oStructGWA:RemoveField("GWA_CDEMIT")
oStructGWA:RemoveField("GWA_NMEMIT")
oStructGWA:RemoveField("GWA_SERIE")
oStructGWA:RemoveField("GWA_NRDOC")
oStructGWA:RemoveField("GWA_DTEMIS")
oStructGWI:RemoveField("GWI_BASICM")
oStructGWI:RemoveField("GWI_BASPIS")

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)

oCalc1 := FWFormViewStruct():New()
oCalc1:AddField('GWI__TOT01','01',STR0001,STR0001, GetHlpSoluc('GWI_VLFRET'),'N','@E 999,999,999.99', Nil, '', .T., '', '', {} , 0, '' ) //'Total Frete'###'Total Frete'

oView:AddField( 'GFEC080_GWF' , oStructGWF , /*cLinkID*/ )	//

oView:AddGrid('GFEC080_GWG', oStructGWG)
oView:AddGrid('GFEC080_GWI', oStructGWI)
oView:AddGrid('GFEC080_GWH', oStructGWH)
oView:AddGrid('GFEC080_GWA', oStructGWA)

oView:AddField('GFEC080_CALC', oCalc1)

oView:CreateHorizontalBox('MASTER' , 55)
oView:CreateHorizontalBox('DETAIL' , 45)

oView:CreateFolder('IDFOLDER01','DETAIL')
oView:AddSheet('IDFOLDER01','IDSHEET01',STR0002)  //'Tabelas'
oView:AddSheet('IDFOLDER01','IDSHEET02',STR0003)  //'Componentes'
oView:AddSheet('IDFOLDER01','IDSHEET03',STR0004)  //'Documentos de Carga'
oView:AddSheet('IDFOLDER01','IDSHEET04',STR0005)  //"Movimentos Contábeis"

oView:CreateHorizontalBox('DETAILNETO1' , 100,,, 'IDFOLDER01', 'IDSHEET01')
oView:CreateHorizontalBox('DETAILNETO2A', 82 ,,, 'IDFOLDER01', 'IDSHEET02')
oView:CreateHorizontalBox('DETAILNETO2B', 18 ,,, 'IDFOLDER01', 'IDSHEET02')
oView:CreateHorizontalBox('DETAILNETO3' , 100,,, 'IDFOLDER01', 'IDSHEET03')
oView:CreateHorizontalBox('DETAILNETO4' , 100,,, 'IDFOLDER01', 'IDSHEET04')

// Associa um View a um box

oView:SetOwnerView('GFEC080_GWF' , 'MASTER'      )
oView:SetOwnerView('GFEC080_GWG' , 'DETAILNETO1' )
oView:SetOwnerView('GFEC080_GWI' , 'DETAILNETO2A')
oView:SetOwnerView('GFEC080_CALC', 'DETAILNETO2B')
oView:SetOwnerView('GFEC080_GWH' , 'DETAILNETO3' )
oView:SetOwnerView('GFEC080_GWA' , 'DETAILNETO4' )

//Se a base de dados está atualizada para permitir vínculo entre GWF e GW3, permite a consulta do documento de frete
If lExistCamp 
	oView:AddUserButton("Documento de Frete", "MAGIC_BMP", {|oView|GFEC080DF(oView)},)
EndIf

Return oView

//--------------------------------------------------------
Function GFEGWATRAN()
	Local cAtrTran := GWA->GWA_CDTRAN
	Local cDsTran := "310=Despesa de Frete;311=ICMS;312=PIS;313=COFINS;300=Despesa de Frete;301=ICMS;302=PIS;303=COFINS;100=Contrato Terceiros"
	Local aDsTran := {}
	Local nPosDsTran

	aDsTran := STRTOKARR(cDsTran,";")
	nPosDsTran := aScan(aDsTran,{|x| Alltrim(cAtrTran) $ x })

Return StrTran(aDsTran[nPosDsTran],Alltrim(cAtrTran)+"=")

/*------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC080DF
Consulta do documento de frete relacionado ao cálculo.

@sample
GFEC080DF()

@author Amanda Rosa Vieira
@since 13/07/2016
@version 1.0 
------------------------------------------------------------------------------------------------*/
Static Function GFEC080DF(oView)
Local oModel    := oView:GetModel()
Local oModelGWF := oModel:GetModel("GFEC080_GWF")
	
	dbSelectArea("GW3")
	GW3->( dbSetOrder(1))//GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS)
	
	If GW3->( dbSeek(xFilial("GW3")+oModelGWF:GetValue("GWF_CDESP")+oModelGWF:GetValue("GWF_EMISDF")+oModelGWF:GetValue("GWF_SERDF")+oModelGWF:GetValue("GWF_NRDF")+DToS(oModelGWF:GetValue("GWF_DTEMDF"))))
		FWExecView("Visualiza", "GFEC065", 1,,{|| .T.})
	Else
		Help( ,, 'Help',, "O cálculo não está realcionado a um Documento de Frete.", 1, 0 )
	EndIf
Return 
