#INCLUDE "GFEC100.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*-------------------------------------------------------------------
{Protheus.doc} GFEC100

Consulta de Contrato de Autonomos

@author Jorge Matos Valcanaia
@since 16/03/10
@version 1.0
-------------------------------------------------------------------*/

Function GFEC100()
	Local oBrowse
	Private aRotina := MenuDef()
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GW2")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEC100")  	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	// Descrição do browse //"Consulta de Contrato Autônomo"
	
	oBrowse:AddLegend("GW2_SITCON=='1'", "WHITE", "Criado")     //"Criado"
	oBrowse:AddLegend("GW2_SITCON=='2'", "GREEN", "Confirmado") //"Confirmado"
	oBrowse:AddLegend("GW2_SITCON=='3'", "BLUE" , "Emitido")   //"Impresso"
	oBrowse:AddLegend("GW2_SITCON=='4'", "RED"  , "Cancelado")  //"Cancelado"
	
	oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------------------
// Adiciona botões do browse
//-------------------------------------------------------------------
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1  ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEC100" OPERATION 2  ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEC100" OPERATION 8  ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE "Visualizar Anexo" ACTION "MsDocument('GW2',GW2->(RecNo()), 2)" OPERATION 2  ACCESS 0 

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local nCont
Local oStructGW2 := FWFormStruct(1,"GW2")
Local oStructGW5 := FWFormStruct(1,"GW5")
Local oStructGWF := FWFormStruct(1,"GWF")
Local oStructGW9 := FWFormStruct(1,"GW9")
Local oStructGWA := FWFormStruct(1,"GWA")

For nCont := 1 To Len(oStructGWF:aFields)
	If oStructGWF:aFields[nCont][3] != "GWF_VALFRT"
		If oStructGWF:aFields[nCont][4] == "C"
			oStructGWF:SetProperty(oStructGWF:aFields[nCont][3], MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:="",FWCloseCpo(a,b,c,.T.),lRetorno } )
	    ElseIf oStructGWF:aFields[nCont][4] == "N"
	    	oStructGWF:SetProperty(oStructGWF:aFields[nCont][3], MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:=0,FWCloseCpo(a,b,c,.T.),lRetorno } )
	    ElseIf oStructGWF:aFields[nCont][4] == "D"
	    	oStructGWF:SetProperty(oStructGWF:aFields[nCont][3], MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:=CToD("  /  /    "),FWCloseCpo(a,b,c,.T.),lRetorno } )
	    EndIf
	EndIf
Next nCont

For nCont := 1 To Len(oStructGw5:aFields)
	If oStructGW5:aFields[nCont][4] == "C"
		oStructGW5:SetProperty(oStructGW5:aFields[nCont][3], MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:="",FWCloseCpo(a,b,c,.T.),lRetorno })
    ElseIf oStructGW5:aFields[nCont][4] == "N"
    	oStructGW5:SetProperty(oStructGW5:aFields[nCont][3], MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:=0,FWCloseCpo(a,b,c,.T.),lRetorno })
    ElseIf oStructGW5:aFields[nCont][4] == "D"
    	oStructGW5:SetProperty(oStructGW5:aFields[nCont][3], MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:=CToD("  /  /    "),FWCloseCpo(a,b,c,.T.),lRetorno })
    EndIf
Next nCont

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEC100", /*bPre*/, /*bPost*/,/*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEC100_GW2", Nil, oStructGW2, /*bPre*/, /*bPost*/, /*bLoad*/)
oModel:SetPrimaryKey({"GW2_FILIAL", "GW2_NRCONT"})                          

oModel:AddGrid("GFEC100_GW5", "GFEC100_GW2", oStructGW5, /*bLinePre*/, , /*bPre*/, /*bPost*/, /*bLoad*/)
oModel:SetRelation("GFEC100_GW5",{{"GW5_FILIAL","xFilial('GW5')"},{"GW5_NRCONT","GW2_NRCONT"}},"GW5_FILIAL+GW5_NRCONT")

oModel:AddGrid("GFEC100_GWF", "GFEC100_GW2", oStructGWF, /*bLinePre*/,, /*bPre*/, /*bPost*/, /*bLoad*/)
oModel:SetRelation("GFEC100_GWF",{{"GWF_FILIAL","xFilial('GWF')"},{"GWF_NRCONT","GW2_NRCONT"}},"GWF_FILIAL+GWF_NRCONT")

oModel:AddGrid("GFEC100_GW9", "GFEC100_GW2", oStructGW9, /*bLinePre*/,, /*bPre*/, /*bPost*/, /*bLoad*/)
oModel:SetRelation("GFEC100_GW9",{{"GW9_FILIAL","xFilial('GW9')"},{"GW9_NRCONT","GW2_NRCONT"}},"GW9_FILIAL+GW9_NRCONT")

oModel:AddGrid("GFEC100_GWA", "GFEC100_GW2", oStructGWA, /*bLinePre*/,, /*bPre*/, /*bPost*/, /*bLoad*/)
oModel:SetRelation("GFEC100_GWA",{{"GWA_FILIAL","xFilial('GWA')"},{"GWA_TPDOC","'3'"},{"GWA_CDEMIT","GW2_CDPROP"},{"GWA_NRDOC","PadR(GW2_NRCONT,TamSX3('GWA_NRDOC')[1])"}},"GWA_FILIAL+GWA_TPDOC+GWA_CDEMIT+GWA_NRDOC")

Return oModel

Static Function ViewDef()

Local oModel := FWLoadModel("GFEC100")
Local oView := Nil
Local oStructGW2 := FWFormStruct(2,"GW2")
Local oStructGW5 := FWFormStruct(2,"GW5") 
Local oStructGWF := FWFormStruct(2,"GWF")    
Local oStructGW9 := FWFormStruct(2,"GW9")    
Local oStructGWA := FWFormStruct(2,"GWA")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("GFEC100_GW2", oStructGW2)
             	                                                                                                                                                  
oView:AddGrid("GFEC100_GW5", oStructGW5)
oStructGW5:RemoveField("GW5_FILIAL")
oStructGW5:RemoveField("GW5_NRCONT")       

oView:AddGrid("GFEC100_GWF", oStructGWF)
oStructGWF:RemoveField("GWF_FILIAL")
oStructGWF:RemoveField("GWF_EMIRED")
oStructGWF:RemoveField("GWF_EMIPAG")
oStructGWF:RemoveField("GWF_TRANSP")
oStructGWF:RemoveField("GWF_ORIGEM")
oStructGWF:RemoveField("GWF_TPCALC")
oStructGWF:RemoveField("GWF_FINCAL")
oStructGWF:RemoveField("GWF_CIDORI")
oStructGWF:RemoveField("GWF_CIDDES")
oStructGWF:RemoveField("GWF_ENDENT")
oStructGWF:RemoveField("GWF_BAIENT")
oStructGWF:RemoveField("GWF_CIDENT")
oStructGWF:RemoveField("GWF_HRCRIA")
oStructGWF:RemoveField("GWF_USUCRI")
oStructGWF:RemoveField("GWF_DTPREN")
oStructGWF:RemoveField("GWF_HRPREN")
oStructGWF:RemoveField("GWF_CARREG")
oStructGWF:RemoveField("GWF_NRROM")
oStructGWF:RemoveField("GWF_VLAJUS")
oStructGWF:RemoveField("GWF_TPTRIB")
oStructGWF:RemoveField("GWF_VLISS")
oStructGWF:RemoveField("GWF_BASICM")
oStructGWF:RemoveField("GWF_PCICMS")
oStructGWF:RemoveField("GWF_PCREIC")
oStructGWF:RemoveField("GWF_VLICMS")
oStructGWF:RemoveField("GWF_ICMRET")
oStructGWF:RemoveField("GWF_BAPICO")
oStructGWF:RemoveField("GWF_VLPIS")
oStructGWF:RemoveField("GWF_VLCOFI")
oStructGWF:RemoveField("GWF_FILPRE")
oStructGWF:RemoveField("GWF_NRPREF")
oStructGWF:RemoveField("GWF_IDFRVI")
oStructGWF:RemoveField("GWF_AGRUP")
oStructGWF:RemoveField("GWF_OBS")
oStructGWF:RemoveField("GWF_SEQTRE")
oStructGWF:RemoveField("GWF_NRCONT")
oStructGWF:RemoveField("GWF_BASISS")
oStructGWF:RemoveField("GWF_PCISS")
oStructGWF:RemoveField("GWF_NMCIOR")
oStructGWF:RemoveField("GWF_NMCIDE")
oStructGWF:RemoveField("GWF_NMTRP")
oStructGWF:RemoveField("GWF_NMPAG")
oStructGWF:RemoveField("GWF_NMRED")
   
oView:AddGrid("GFEC100_GW9", oStructGW9)
oStructGW5:RemoveField("GW9_FILIAL")
oStructGW5:RemoveField("GW9_NRCONT")

oView:AddGrid("GFEC100_GWA", oStructGWA)
oStructGWA:RemoveField("GWA_TPDOC")
oStructGWA:RemoveField("GWA_CDESP")
oStructGWA:RemoveField("GWA_CDEMIT")
oStructGWA:RemoveField("GWA_NMEMIT")
oStructGWA:RemoveField("GWA_SERIE")
oStructGWA:RemoveField("GWA_NRDOC")
oStructGWA:RemoveField("GWA_DTEMIS")   

oView:CreateHorizontalBox("MASTER", 55)
oView:CreateHorizontalBox("DETAIL", 45) 

oView:CreateFolder("IDFOLDER", "DETAIL")
oView:AddSheet("IDFOLDER", "IDSHEET01", STR0029) //"Cálculos"
oView:AddSheet("IDFOLDER", "IDSHEET02", STR0006) //"Valores Adicionais"
oView:AddSheet("IDFOLDER", "IDSHEET03", STR0032) //"Rateio Contábil"
oView:AddSheet("IDFOLDER", "IDSHEET04", STR0004) //"Movimentos Contábeis"

oView:CreateHorizontalBox("DETAIL_GWF", 100,,, "IDFOLDER", "IDSHEET01")  
oView:CreateHorizontalBox("DETAIL_GW5", 100,,, "IDFOLDER", "IDSHEET02")
oView:CreateHorizontalBox("DETAIL_GW9", 100,,, "IDFOLDER", "IDSHEET03")
oView:CreateHorizontalBox("DETAIL_GWA", 100,,, "IDFOLDER", "IDSHEET04")

oView:SetOwnerView("GFEC100_GW2", "MASTER")
oView:SetOwnerView("GFEC100_GWF", "DETAIL_GWF")
oView:SetOwnerView("GFEC100_GW5", "DETAIL_GW5")
oView:SetOwnerView("GFEC100_GW9", "DETAIL_GW9")
oView:SetOwnerView("GFEC100_GWA", "DETAIL_GWA")

oView:AddUserButton(STR0007, "csaimg32_mdi", {|oX| GFEA100IM(1)}) //"Impostos"

Return oView   
 