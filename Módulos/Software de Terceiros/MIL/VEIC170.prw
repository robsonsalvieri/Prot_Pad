#Include "TOTVS.ch"
#Include "FWMVCDef.ch"
#Include "VEIC170.ch"
 
/*/
{Protheus.doc} VEIC170
Rotina MVC para VV0 e VVA
@type   Function
@author Jose L. S. Filho
@since  27/03/2023
@param  nil
@return nil
/*/
Function VEIC170(cFilVV0 , cNumtra)

Local oBrowse 
Local aArea
Private lCotitul := VEC17001H_PosicionaNoCotitular()
Default cFilVV0 := ""
Default cNumtra := ""

If Empty( cFilVV0 + cNumtra )
    aArea := VV0->(GetArea())
    DbSelectArea("VV0")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("VV0")
    oBrowse:SetDescription(STR0001)	// Consulta Movimentações de Saida
    oBrowse:Activate()
    oBrowse:SetInsert(.f.)
    RestArea(aArea)
Else
    DbSelectArea("VV0")
    DbSetOrder(1)
    If DbSeek( cFilVV0 + cNumtra )
		VC1700011_Visualizar() // Chama VIEW
    Endif
Endif

Return Nil 
/*/
{Protheus.doc} MenuDef
Função padrão do MVC responsável pela definição das opções de menu do Browse do fonte VEIC170 que estarão disponíveis ao usuário.
@type   Static Function
@author Jose L. S. Filho
@since  27/03/2023
@param  nil
@return aRot,   Matriz, Matriz que contém as opções de menu a serem utilizadas pelo usuário.
/*/
Static Function MenuDef()
    
Local aRot := {}
ADD OPTION aRot TITLE STR0004 ACTION 'VC1700011_Visualizar' OPERATION 2 ACCESS 0 // Visualizar
 
Return aRot

/*/
{Protheus.doc} ModelDef
Função padrão do MVC responsável pela criação do modelo de dados (regras de negócio) para a rotina VEIC170.
@type   Static Function
@author Jose L. S. Filho
@since  27/03/2023
@param  nil
@return oModel, Objeto, Objeto que contém o modeldef.
/*/
Static Function ModelDef()
Local oModel  := MPFormModel():New("VEIC170")
Local oStVV0  := FWFormStruct(1, "VV0")
Local oStVVA  := FWFormStruct(1, "VVA")
Local oStVW1
local aVW1Rel := {}
local aVVARel := {}
local lCotitul := VEC17001H_PosicionaNoCotitular()

//Criando o modelo e os relacionamentos
dbselectArea("VV0")
dbselectArea("VVA")
oModel:AddFields("VV0MASTER",/*cOwner*/,oStVV0)
If lCotitul // Cotitulares
	oStVW1 := FWFormStruct(1, "VW1")
	oModel:AddGrid("VW1DETAIL","VV0MASTER",oStVW1,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
EndIf
oModel:AddGrid("VVADETAIL","VV0MASTER",oStVVA,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

//Fazendo o relacionamento entre o Pai e Filho
If lCotitul // Cotitulares
	aAdd(aVW1Rel, {"VW1_FILIAL","VV0_FILIAL"} )
	aAdd(aVW1Rel, {"VW1_NUMTRA","VV0_NUMTRA"} )
	oModel:SetRelation("VW1DETAIL", aVW1Rel, VW1->(IndexKey(2))) //IndexKey -> quero a ordenação e depois filtrado
EndIf
aAdd(aVVARel, {"VVA_FILIAL","VV0_FILIAL"} )
aAdd(aVVARel, {"VVA_NUMTRA","VV0_NUMTRA"} )
oModel:SetRelation("VVADETAIL", aVVARel, VVA->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
 
//Setando as descrições
oModel:SetDescription(STR0001)	// Consulta Movimentações de Saida
oModel:GetModel("VV0MASTER"):SetDescription(STR0002)	// Cabeçalho das Movimentações de Saida
If lCotitul // Cotitulares
	oModel:GetModel("VW1DETAIL"):SetDescription(STR0005)	// Cotitulares
EndIf
oModel:GetModel("VVADETAIL"):SetDescription(STR0003)	// Itens da Saida

oStVVA:RemoveField("VVA_OBSERV") 
oStVVA:RemoveField("VVA_OBSMEM") 

Return oModel

/*/
{Protheus.doc} 
ViewDef
Função padrão do MVC responsável pela criação da visão de dados (interação do usuário) para a rotina VEIC170.
@type   Static Function
@author Jose L. S. Filho
@since  27/03/2023
@param  nil
@return oView, Objeto, Objeto que contém o viewdef.
/*/
Static Function ViewDef()
Local oView  := FWFormView():New()
Local oModel := FWLoadModel("VEIC170")
Local oStVV0 := FWFormStruct(2, "VV0") // Cabeçalho
Local oStVVA := FWFormStruct(2, "VVA") // Veiculos
Local oStVW1 // Cotitulares

//Criando a View
oView:SetModel(oModel)
 
//Adicionando os campos do cabeçalho e o grid dos filhos
dbselectArea("VV0")
dbselectArea("VVA")
oView:AddField('VIEW_VV0'   ,oStVV0 ,'VV0MASTER')
If lCotitul // Cotitulares
	oStVW1 := FWFormStruct(2, "VW1" , { |cCampo| !ALLTRIM(cCampo) $ "VW1_FILIAL/VW1_CODIGO/VW1_NUMTRA/VW1_PERCEN/VW1_VALTOT/" } ) // Não mostrar campos internos (controles)
	oView:AddGrid('VIEW_VW1',oStVW1 ,'VW1DETAIL')
EndIf
oView:AddGrid('VIEW_VVA'    ,oStVVA ,'VVADETAIL')
 
//Setando o dimensionamento de tamanho das box
If lCotitul // Cotitulares
	oView:CreateHorizontalBox('CABEC',40)
	oView:CreateHorizontalBox('COTIT',30)
	oView:CreateHorizontalBox('GRID' ,30)
Else
	oView:CreateHorizontalBox('CABEC',60)
	oView:CreateHorizontalBox('GRID',40)
EndIf
 
//Amarrando a view com as box
oView:SetOwnerView('VIEW_VV0','CABEC')
If lCotitul // Cotitulares
	oView:SetOwnerView('VIEW_VW1','COTIT')
EndIf
oView:SetOwnerView('VIEW_VVA','GRID')
 
//Habilitando título
oView:EnableTitleView('VIEW_VV0',STR0002)	// Cabeçalho das Movimentações de Saida
If lCotitul // Cotitulares
	oView:EnableTitleView('VIEW_VW1',STR0005)	// Cotitulares
EndIf
oView:EnableTitleView('VIEW_VVA',STR0003)	// Itens da Saida

//Incremento
oView:AddIncrementField("VIEW_VVA", "VVA_CODSEQ")
oStVVA:RemoveField("VVA_OBSERV")
oStVVA:RemoveField("VVA_OBSMEM")

//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})
         
Return oView

/*/{Protheus.doc} VC1700011_Visualizar
	Visualizar VV0/VVA/VW1
	
	@author Andre Luis Almeida
	@since 10/10/2024
/*/
Function VC1700011_Visualizar()
Local oExecView
//
lCotitul := VEC17001H_PosicionaNoCotitular()
//
oExecView := FWViewExec():New()
oExecView:SetTitle(STR0001) // Consulta Movimentações de Saida
oExecView:SetSource("VEIC170")
oExecView:SetOperation(MODEL_OPERATION_VIEW)
oExecView:OpenView(.T.)
//
Return

/*/
{Protheus.doc} VEC17001H_PosicionaNoCotitular
Função para poscionar a variavel Cotitular.
@type   Static Function
@author João Victor Silva
@since  26/03/2025
@param  nil
/*/

Static Function VEC17001H_PosicionaNoCotitular()

local lCotitul := .f.

If cPaisLoc == "ARG"
	dbselectArea("VW1")
	VW1->(DbSetOrder(2))
	
	if VW1->(DbSeek( VV0->VV0_FILIAL + VV0->VV0_NUMTRA )) // Tem Cotitulares
		lCotitul := .T.
	endif
endif
	
Return lCotitul