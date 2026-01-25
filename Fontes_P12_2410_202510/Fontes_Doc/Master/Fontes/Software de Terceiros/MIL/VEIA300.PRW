#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA300.CH"

Static cSiglaAMS := GetNewPar("MV_MIL0106","AMS") // Sigla da Solucao Agregada. Exemplos: AMS ou AFS ou SAG. Default: AMS

/*/{Protheus.doc} VEIA300
	Agrega/Desagrega Multieventos

	@author Andre Luis Almeida
	@since 14/02/2023
/*/
Function VEIA300()
Local aSize       := FWGetDialogSize( oMainWnd )
Local aProc       := X3CBOXAVET("VFJ_PROCES","0")
Local aTipo       := X3CBOXAVET("VFJ_TIPPRO","0")
Local aItem       := { "1="+cSiglaAMS , "2="+STR0014 } // Peças
Local nCntFor     := 0
Local cNamVV1     := RetSQLName("VV1")
Local aColumns    := VA3000081_Colunas_VV1()
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBBUGMIL",.f.,.f.),"")
Private cCadastro := STR0001 // Agrega/Desagrega Multieventos
Private cMarVeiF3 := "" // Variavel utilizada no F3 do Modelo VV2 -> SXB: 'MCF'
Private cGrupoA   := "" // Variavel utilizada no F3 do Produto SB1 -> SXB: 'B23'

//Necessário realizar a chamada via VEIXA040 pois existem validações de SX3 que verificam FUNNAME()
If !FM_PILHA("VEIXA040")
	Return //A função VEIA300 não pode ser chamada diretamente através do MENU
Endif	

oDlgVA300 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oWAVA300 := FWUIWorkArea():New( oDlgVA300 ) // Work Area
oWAVA300:CreateHorizontalBox( "LINE01", 65 )
oWAVA300:SetBoxCols( "LINE01", { "OBJ1" } )
oWAVA300:CreateHorizontalBox( "LINE02", 35 )
oWAVA300:SetBoxCols( "LINE02", { "OBJ2" , "OBJ3" } )
oWAVA300:Activate()

oBrwVV1:= FWMBrowse():New()
oBrwVV1:SetOwner(oWAVA300:GetPanel("OBJ3"))
oBrwVV1:SetDescription(STR0002) // Veículos/Máquinas/Equipamentos do Processo
oBrwVV1:SetDataQuery(.T.)
oBrwVV1:SetAlias("VA300VV1")
oBrwVV1:SetQuery( VA3000111_Query_VV1( cNamVV1 , VFJ->VFJ_VV1001 , VFJ->VFJ_VV1002 ) )
oBrwVV1:SetMenuDef("")
oBrwVV1:AddButton(STR0003, {|| VA3000011_VV1_Consultar( 1 , VA300VV1->VV1_CHASSI , VA300VV1->VV1_CHAINT ) },,2,2) // Rastreamento do Chassi
oBrwVV1:AddButton(STR0004, {|| VA3000011_VV1_Consultar( 2 , VA300VV1->VV1_CHASSI , VA300VV1->VV1_CHAINT ) },,2,2) // Histórico de Agrega/Desagrega do Chassi
oBrwVV1:SetColumns(aColumns)
oBrwVV1:DisableDetails()
oBrwVV1:DisableLocate()
oBrwVV1:SetAmbiente(.F.)
oBrwVV1:SetWalkthru(.F.)
oBrwVV1:SetUseFilter(.F.)
oBrwVV1:lOptionReport := .F.
oBrwVV1:DisableSeek()
oBrwVV1:Activate()

oBrwVFJ := FWMBrowse():New()
oBrwVFJ:SetAlias("VFJ")
oBrwVFJ:SetDescription(cCadastro)
oBrwVFJ:SetMenuDef( 'VEIA300' )
oBrwVFJ:SetOwner(oWAVA300:GetPanel("OBJ1"))
oBrwVFJ:AddLegend( 'VFJ->VFJ_STATUS == "0"' , 'BR_BRANCO'   , STR0005+": "+STR0006 ) // Status / Digitado
oBrwVFJ:AddLegend( 'VFJ->VFJ_STATUS == "1"' , 'BR_VERDE'    , STR0005+": "+STR0007 ) // Status / Efetivado
oBrwVFJ:AddLegend( 'VFJ->VFJ_STATUS == "2"' , 'BR_VERMELHO' , STR0005+": "+STR0008 ) // Status / Cancelado
oBrwVFJ:AddLegend( 'VFJ->VFJ_STATUS == "3"' , 'BR_LARANJA'  , STR0005+": "+STR0009 ) // Status / Efetivação Pendente ( problema para Efetivar )
For nCntFor := 1 to len(aProc)
	oBrwVFJ:AddFilter(STR0011+": "+substr(aProc[nCntFor],3),"@ VFJ_PROCES='"+left(aProc[nCntFor],1)+"'",.f.,.f.,) // Processo
Next
For nCntFor := 1 to len(aTipo)
	oBrwVFJ:AddFilter(STR0012+": "+substr(aTipo[nCntFor],3),"@ VFJ_TIPPRO='"+left(aTipo[nCntFor],1)+"'",.f.,.f.,) // Tipo
Next
For nCntFor := 1 to len(aItem)
	oBrwVFJ:AddFilter(STR0013+": "+substr(aItem[nCntFor],3),"@ VFJ_TIPITE='"+left(aItem[nCntFor],1)+"'",.f.,.f.,) // Item
Next
oBrwVFJ:bChange := { || oBrwVV1:SetQuery( VA3000111_Query_VV1( cNamVV1 , VFJ->VFJ_VV1001 , VFJ->VFJ_VV1002 ) ), oBrwVV1:Refresh() }
oBrwVFJ:DisableDetails()
oBrwVFJ:DisableLocate()
oBrwVFJ:SetAmbiente(.F.)
oBrwVFJ:SetWalkthru(.F.)
oBrwVFJ:SetUseFilter()
oBrwVFJ:ForceQuitButton()
oBrwVFJ:Activate()

oBrwVDV := FWMBrowse():New()
oBrwVDV:SetAlias("VDV")
oBrwVDV:SetDescription(STR0015) // Eventos gerados na Efetivação
oBrwVDV:SetOwner(oWAVA300:GetPanel("OBJ2"))
oBrwVDV:SetMenuDef( '' )
oBrwVDV:SetOnlyFields({"VDV_AGRDES","VDV_DATMOV","VDV_HORMOV","VDV_CHAINT"})
oBrwVDV:AddLegend( 'VDV->VDV_STATUS == "1"' , 'BR_VERDE'    , STR0010 ) // Ativo
oBrwVDV:AddLegend( 'VDV->VDV_STATUS == "0"' , 'BR_VERMELHO' , STR0008 ) // Cancelado
oBrwVDV:AddButton(STR0016, {|| VA3000051_Cancelar(1) },,2,2) // Cancelamento Individual
oBrwVDV:AddButton(STR0094, {|| VA3300131_MostrarDocumentosTela(,VDV->VDV_CODIGO) },,2,2) // Documentos Gerados
oBrwVDV:AddButton(STR0017+" - "+STR0094, {|| VA3000161_VisualizarDocumento() },,2,2) // Visualizar / Documentos Gerados
oBrwVDV:DisableDetails()
oBrwVDV:DisableLocate()
oBrwVDV:SetAmbiente(.F.)
oBrwVDV:SetWalkthru(.F.)
oBrwVDV:SetUseFilter(.F.)
oBrwVDV:lOptionReport := .F.
oBrwVDV:DisableSeek()
oBrwVDV:Activate()

oRlc1VA300:= FWBrwRelation():New()
oRlc1VA300:AddRelation( oBrwVFJ , oBrwVDV , { { "VDV_FILEXE", "VFJ_FILIAL" }, { "VDV_CODEXE", "VFJ_CODIGO" } })
oRlc1VA300:Activate()

oDlgVA300:Activate( , , , , , , ) //ativa a janela

Return

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0017 ACTION 'VA3000021_Visualizar()' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0018 ACTION 'VA3000031_Incluir()' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0019 ACTION 'VA3000041_Alterar()' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0020 ACTION 'VEIA330()' OPERATION 4 ACCESS 0 // Efetivar
	ADD OPTION aRotina TITLE STR0094 ACTION 'VA3300131_MostrarDocumentosTela()' OPERATION 2 ACCESS 0 // Documentos Gerados
	ADD OPTION aRotina TITLE STR0021 ACTION 'VA3000051_Cancelar(0)' OPERATION 5 ACCESS 0 // Cancelar
	if ExistBlock("RELAGDG")
		ADD OPTION aRotina TITLE STR0096 ACTION 'VA300022H_RelatorioAgrDs()' OPERATION 6 ACCESS 0 // Imprimir Relatório Agrega/Desagrega
	Endif

	If ( ExistBlock("VA300BT") )
		aRotina := ExecBlock("VA300BT",.f.,.f.,{aRotina})
	EndIf

Return aRotina

/*/{Protheus.doc} VA3000011_VV1_Consultar
1 = Rastreamento do Veiculo / Máquina / Equipamento
2 = Historico de Agrega / Desagrega do Veiculo

@author Andre Luis Almeida
@since 10/03/2023
/*/
Static Function VA3000011_VV1_Consultar( nTp , cChassi , cChaInt )
If nTp == 1 // Rastreamento
	VEIVC140( cChassi , cChaInt )
ElseIf nTp == 2 // Histórico
	VEIC020( cChassi )
EndIf	
Return()

/*/{Protheus.doc} VA3000021_Visualizar
Visualizar Processo

@author Andre Luis Almeida
@since 15/02/2023
/*/
Function VA3000021_Visualizar()
Local cPrw := ""
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBBUGMIL",.f.,.f.),"")
DbSelectArea("VFJ")
cPrw := VA3000061_PRW( 2 , VFJ->VFJ_PROCES + VFJ->VFJ_TIPPRO + VFJ->VFJ_TIPITE ) // Retorna o nome do PRW a ser executado pelo Processo + Tipo + Item
If !Empty(cPRW)
	oExecView := FWViewExec():New()
	oExecView:SetTitle(STR0017) // Visualizar
	oExecView:SetSource(cPrw)
	oExecView:SetOperation(MODEL_OPERATION_VIEW)
	oExecView:OpenView(.T.)
EndIf
Return

/*/{Protheus.doc} VA3000031_Incluir
Incluir Processo

@author Andre Luis Almeida
@since 14/02/2023
/*/
Function VA3000031_Incluir()
Local cMV_MIL0113 := Iif(cPaisLoc == "ARG", "2", GetNewPar("MV_MIL0113","1")) // Agrega/Desagrega - Gerar? ( 1=Sempre NF (default) / 2=Sempre Mov.Interna / 3=Usuário seleciona o tipo )
Local aParambox   := {}
Local aRet        := {"","",""}
Local aProc       := X3CBOXAVET("VFJ_PROCES","0")
Local aTipo       := X3CBOXAVET("VFJ_TIPPRO","0")
Local aItem       := { "1="+cSiglaAMS , "2="+STR0014 } // Peças
Local aAux        := aClone(aTipo)
Local cPrw        := ""
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBBUGMIL",.f.,.f.),"")
If cMV_MIL0113 == "1" // Sempre NF
	aTipo := {aAux[1]} // Notas Fiscais
ElseIf cMV_MIL0113 == "2" // Sempre Mov.Interna
	aTipo := {aAux[2]} // Movimentações Internas
EndIf
AADD(aParamBox,{2,STR0011,"",aProc,110,"",.f.,".t."}) // Processo
AADD(aParamBox,{2,STR0012,"",aTipo,110,"",.f.,".t."}) // Tipo
AADD(aParamBox,{2,STR0013,"",aItem,110,"",.f.,".t."}) // Item
If ParamBox(aParamBox,"",@aRet,,,,,,,,.f.)
	cPrw := VA3000061_PRW( 2 , aRet[1] + aRet[2] + aRet[3] ) // Retorna o nome do PRW a ser executado pelo Processo + Tipo + Item
	If !Empty(cPRW)
		DbSelectArea("VFJ")
		oExecView := FWViewExec():New()
		oExecView:SetTitle(STR0018) // Incluir
		oExecView:SetSource(cPRW)
		oExecView:SetOperation(MODEL_OPERATION_INSERT)
		oExecView:OpenView(.T.)
	EndIf
EndIf
Return

/*/{Protheus.doc} VA3000041_Alterar
Alterar Processo

@author Andre Luis Almeida
@since 17/02/2023
/*/
Function VA3000041_Alterar()
Local cPrw := ""
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBBUGMIL",.f.,.f.),"")
DbSelectArea("VFJ")
If VFJ->VFJ_STATUS == "0" // 0 = Digitado
	cPrw := VA3000061_PRW( 2 , VFJ->VFJ_PROCES + VFJ->VFJ_TIPPRO + VFJ->VFJ_TIPITE ) // Retorna o nome do PRW a ser executado pelo Processo + Tipo + Item
	oExecView := FWViewExec():New()
	oExecView:SetTitle(STR0019) // Alterar
	oExecView:SetSource(cPrw)
	oExecView:SetOperation(MODEL_OPERATION_UPDATE)
	oExecView:OpenView(.T.)
ElseIf VFJ->VFJ_STATUS == "1" // 1 = Efetivado
	Help("",1,"VA3000041_Alterar",,STR0022,1,0) // Processo já Efetivado. Impossível continuar.
ElseIf VFJ->VFJ_STATUS == "2" // 2 = Cancelado
	Help("",1,"VA3000041_Alterar",,STR0023,1,0) // Processo já Cancelado. Impossível continuar.
ElseIf VFJ->VFJ_STATUS == "3" // 3 = Efetivação Pendente ( problema para Efetivar )
	Help("",1,"VA3000041_Alterar",,STR0024,1,0) // Processo Pedente Efetivação. Impossível continuar.
EndIf
Return

/*/{Protheus.doc} VA3000051_Cancelar
Cancelar Processo

@author Andre Luis Almeida
@since 17/02/2023
/*/
Function VA3000051_Cancelar(nTp)
Local cQuery    := ""
Local cFilExe   := ""
Local cCodExe   := ""
Local nQtdVDV   := 0
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBBUGMIL",.f.,.f.),"")

if !VA300019H_PermiteCancAgrega()
	Return 
EndIf

If nTp == 0 // Cancelar o processo todo - VFJ
	DbSelectArea("VFJ")
	If VFJ->VFJ_STATUS == "0" // 0 = Digitado
		If MsgYesNo(STR0026,STR0025) // Confirma o Cancelamento do Processo? / Atenção
			cFilExe := VFJ->VFJ_FILIAL
			cCodExe := VFJ->VFJ_CODIGO
		EndIf
	ElseIf VFJ->VFJ_STATUS $ "1/3" // 1 = Efetivado / 3 = Efetivação Pendente ( problema para Efetivar )
		cQuery := "  FROM "+RetSQLName("VDV")
		cQuery += " WHERE VDV_FILIAL = '"+xFilial("VDV")+"'"
		cQuery += "   AND VDV_STATUS = '1'"
		cQuery += "   AND VDV_FILEXE = '"+VFJ->VFJ_FILIAL+"'"
		cQuery += "   AND VDV_CODEXE = '"+VFJ->VFJ_CODIGO+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		nQtdVDV := FM_SQL("SELECT COUNT(VDV_CODIGO) "+cQuery)
		If nQtdVDV <= 1
			If MsgYesNo(STR0026,STR0025) // Confirma o Cancelamento do Processo? / Atenção
				If nQtdVDV == 0 .or. VEIA331( FM_SQL("SELECT R_E_C_N_O_ "+cQuery) ) // Cancelamento Individual
					cFilExe := VFJ->VFJ_FILIAL
					cCodExe := VFJ->VFJ_CODIGO
				EndIf
			EndIf
		Else
			Help("",1,"VA3000051_Cancelar",,STR0027,1,0) // Impossível Cancelar todo processo. Necessário realizar o cancelamento individualmente.
		EndIf
	ElseIf VFJ->VFJ_STATUS == "2" // 2 = Cancelado
		Help("",1,"VA3000051_Cancelar",,STR0023,1,0) // Processo já Cancelado. Impossível continuar.
	EndIf
ElseIf nTp == 1 // Cancelamento Individual - VDV
	If VDV->VDV_STATUS == "1" // 1 = Ativo
		If MsgYesNo(STR0026,STR0025) // Confirma o Cancelamento do Processo? / Atenção
			If VEIA331( VDV->(RecNo()) ) // Cancelamento Individual
				cFilExe := VDV->VDV_FILEXE
				cCodExe := VDV->VDV_CODEXE
			EndIf
		EndIf
	ElseIf VDV->VDV_STATUS == "0" // 0 = Cancelado
		Help("",1,"VA3000051_Cancelar",,STR0028,1,0) // Registro já Cancelado. Impossível continuar.
	EndIf
EndIf
If !Empty(cCodExe) // Verificar se não existe registro ativo no VDV para poder cancelar o VFJ ( Multieventos )
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "  FROM "+RetSQLName("VDV")
	cQuery += " WHERE VDV_FILIAL = '"+xFilial("VDV")+"'"
	cQuery += "   AND VDV_STATUS = '1'"
	cQuery += "   AND VDV_FILEXE = '"+cFilExe+"'"
	cQuery += "   AND VDV_CODEXE = '"+cCodExe+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	If FM_SQL(cQuery) == 0 // Não existe nenhum registro ATIVO no VDV - Pode cancelar a cabeça do processo
		VA3000151_Grava_Status( cFilExe , cCodExe , "2" ) // 2=Cancelado
	EndIf
	MsgInfo(STR0029,STR0025) // Processo cancelado com sucesso! / Atenção
EndIf
oBrwVDV:Refresh()
oBrwVFJ:Refresh()
Return

/*/{Protheus.doc} VA3000061_PRW
PRW e Processo+Tipo+Item
1 = Retorna o Processo
2 = Retorna o Nome da rotina

@author Andre Luis Almeida
@since 17/02/2023
/*/
Function VA3000061_PRW( nCol , cAux )
Local nColRet := IIf(nCol==1,2,1) // Se pesquisou a primeira coluna, retorna segunda coluna. Se pesquisou a segunda coluna, retorna a primeira coluna
Local nPosRet := 0
Local aRot    := {}
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBBUGMIL",.f.,.f.),"")
aAdd(aRot,{ "VEIA301" , "111" }) // VEIA301 => Processo: 1=Agrega (Individual) / Com: 1=Notas Fiscais / Para: 1=AMS
aAdd(aRot,{ "VEIA302" , "112" }) // VEIA302 => Processo: 1=Agrega (Individual) / Com: 1=Notas Fiscais / Para: 2=Peças
aAdd(aRot,{ "VEIA303" , "121" }) // VEIA303 => Processo: 1=Agrega (Individual) / Com: 2=Movimentações Internas / Para: 1=AMS
aAdd(aRot,{ "VEIA304" , "122" }) // VEIA304 => Processo: 1=Agrega (Individual) / Com: 2=Movimentações Internas / Para: 2=Peças
aAdd(aRot,{ "VEIA305" , "211" }) // VEIA305 => Processo: 2=Desagrega (Individual) / Com: 1=Notas Fiscais / Para: 1=AMS
aAdd(aRot,{ "VEIA306" , "212" }) // VEIA306 => Processo: 2=Desagrega (Individual) / Com: 1=Notas Fiscais / Para: 2=Peças
aAdd(aRot,{ "VEIA307" , "221" }) // VEIA307 => Processo: 2=Desagrega (Individual) / Com: 2=Movimentações Internas / Para: 1=AMS
aAdd(aRot,{ "VEIA308" , "222" }) // VEIA308 => Processo: 2=Desagrega (Individual) / Com: 2=Movimentações Internas / Para: 2=Peças
aAdd(aRot,{ "VEIA309" , "311" }) // VEIA309 => Processo: 3=Transferência / Com: 1=Notas Fiscais / Para: 1=AMS
aAdd(aRot,{ "VEIA310" , "312" }) // VEIA310 => Processo: 3=Transferência / Com: 1=Notas Fiscais / Para: 2=Peças
aAdd(aRot,{ "VEIA311" , "321" }) // VEIA311 => Processo: 3=Transferência / Com: 2=Movimentações Internas / Para: 1=AMS
aAdd(aRot,{ "VEIA312" , "322" }) // VEIA312 => Processo: 3=Transferência / Com: 2=Movimentações Internas / Para: 2=Peças
aAdd(aRot,{ "VEIA313" , "411" }) // VEIA313 => Processo: 4=Troca / Com: 1=Notas Fiscais / Para: 1=AMS
aAdd(aRot,{ "VEIA314" , "412" }) // VEIA314 => Processo: 4=Troca / Com: 1=Notas Fiscais / Para: 2=Peças
aAdd(aRot,{ "VEIA315" , "421" }) // VEIA315 => Processo: 4=Troca / Com: 2=Movimentações Internas / Para: 1=AMS
aAdd(aRot,{ "VEIA316" , "422" }) // VEIA316 => Processo: 4=Troca / Com: 2=Movimentações Internas / Para: 2=Peças
nPosRet := aScan(aRot,{ |x| x[nCol] == cAux })
Return aRot[nPosRet,nColRet]

/*/{Protheus.doc} VA3000071_TipoItem
Retorna a String do Combo de Tipo do Item

@author Andre Luis Almeida
@since 22/02/2023
/*/
Function VA3000071_TipoItem()
Return "1="+cSiglaAMS+";2="+STR0014 // Peças

/*/{Protheus.doc} VA3000081_Colunas_VV1
Retorna colunas utilizadas no SQL para filtrar os VV1 do Processo

@author Andre Luis Almeida
@since 10/03/2023
/*/
Static Function VA3000081_Colunas_VV1()
Local aColumns := {}
AAdd(aColumns,FWBrwColumn():New())
	aColumns[1]:SetData( &("{|| VV1_CHAINT }") ) 
	aColumns[1]:SetTitle(RetTitle("VDV_CHAINT"))
	aColumns[1]:SetSize(5)
AAdd(aColumns,FWBrwColumn():New())
	aColumns[2]:SetData( &("{|| VV1_CHASSI }") ) 
	aColumns[2]:SetTitle(RetTitle("VV1_CHASSI"))
	aColumns[2]:SetSize(20)
AAdd(aColumns,FWBrwColumn():New())
	aColumns[3]:SetData( &("{|| VV1_CODMAR }") ) 
	aColumns[3]:SetTitle(RetTitle("VV1_CODMAR"))
	aColumns[3]:SetSize(5)
AAdd(aColumns,FWBrwColumn():New())
	aColumns[4]:SetData( &("{|| VV1_MODVEI }") ) 
	aColumns[4]:SetTitle(RetTitle("VV1_MODVEI"))
	aColumns[4]:SetSize(20)
Return aColumns

/*/{Protheus.doc} VA3000091_TipoRegistro
Retorna a String do Combo de Tipo de Registro - Saida e Entrada

@author Andre Luis Almeida
@since 23/02/2023
/*/
Function VA3000091_TipoRegistro(cTipo)
Local cRet := ""
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBBUGMIL",.f.,.f.),"")
Do Case
	Case cTipo == "S" // NF Saida
		cRet += "1="+STR0030+";" // NF Saida Veículo/Máquina/Equipamento 1
		cRet += "2="+STR0031+";" // NF Saida Peças para Agregar no 1
		cRet += "3="+STR0032+";" // NF Saida Veículo/Máquina/Equipamento 2
		cRet += "4="+STR0033     // NF Saida Peças para Agregar no 2
	Case cTipo == "E" // NF Entrada
		cRet += "1="+STR0034+";" // NF Entrada Veículo/Máquina/Equipamento 1
		cRet += "2="+STR0035+";" // NF Entrada Peças para Desagregar do 1
		cRet += "3="+STR0036+";" // NF Entrada Veículo/Máquina/Equipamento 2
		cRet += "4="+STR0037     // NF Entrada Peças para Desagregar do 2
	Case cTipo == "M" // Movimentações Internas
		cRet += "1="+STR0038+";" // Saida Veículo/Máquina/Equipamento 1
		cRet += "2="+STR0039+";" // Saida Peças para Agregar no 1
		cRet += "3="+STR0040+";" // Saida Veículo/Máquina/Equipamento 2
		cRet += "4="+STR0041+";" // Saida Peças para Agregar no 2
		cRet += "5="+STR0042+";" // Entrada Veículo/Máquina/Equipamento 1
		cRet += "6="+STR0043+";" // Entrada Peças para Desagregar do 1
		cRet += "7="+STR0044+";" // Entrada Veículo/Máquina/Equipamento 2
		cRet += "8="+STR0045     // Entrada Peças para Desagregar do 2
EndCase
Return cRet

/*/{Protheus.doc} VA3000101_Trigger
Monta Trigger dos campos nas Rotinas de Agrega/Desagrega/Transferencia/Troca

@author Andre Luis Almeida
@since 24/02/2023
/*/
Function VA3000101_Trigger(oAuxStru, aAuxTrigger)
	oAuxStru:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
Return

/*/{Protheus.doc} VA3000111_Query_VV1
Retorna SQL para filtrar os VV1 do Processo

@author Andre Luis Almeida
@since 10/03/2023
/*/
Static Function VA3000111_Query_VV1( cNamVV1 , cChaInt1 , cChaInt2 )
Local cRetSQL := ""
cRetSQL += "SELECT VV1_CHAINT , VV1_CHASSI , VV1_CODMAR , VV1_MODVEI "
cRetSQL += "  FROM "+cNamVV1
cRetSQL += " WHERE VV1_FILIAL = '"+xFilial("VV1")+"'"
cRetSQL += "   AND VV1_CHAINT "
Do Case
	Case !Empty(cChaInt1) .and. !Empty(cChaInt2)
		cRetSQL += "IN ('"+cChaInt1+"','"+cChaInt2+"')"
	Case !Empty(cChaInt1)
		cRetSQL += "= '"+cChaInt1+"'"
	Case !Empty(cChaInt2)
		cRetSQL += "= '"+cChaInt2+"'"
	Otherwise
		cRetSQL += "= 'NAOTRAZERVV1'"
EndCase
cRetSQL += " AND D_E_L_E_T_ = ' '"
Return cRetSQL

/*/{Protheus.doc} VA3000121_CorEvento
Retorna BitMap para cor do Evento

@author Andre Luis Almeida
@since 28/04/2023
/*/
Function VA3000121_CorEvento( cAl , cTp )
Local cBitMap  := ""
Default cTp    := ""
If Empty(cTp)
	Do Case
		Case cAl == "VFK" // NF Saida
			cTp := "S"+VFK->VFK_AGRDES+VFK->VFK_TIPREG
		Case cAl == "VFL" // NF Entrada
			cTp := "E"+VFL->VFL_AGRDES+VFL->VFL_TIPREG
		Case cAl == "VFO" // Movimentações Internas
			cTp := "M"+VFO->VFO_AGRDES+VFO->VFO_TIPREG
		Case cAl $ "TVFP/TVFQ" // Transferencia - Desagrega
			cTp := "T01"
		Case cAl $ "TVFM/TVFN" // Transferencia - Agrega
			cTp := "T02"
	EndCase
EndIf
Do Case
	Case cTp $ "S21/E21/E22/M21/M25/M26/T01/"
		cBitMap := "gr_blue01" // Legenda 1
	Case cTp $ "S13/S14/E13/M13/M14/M17/T02/"
		cBitMap := "gr_blue02" // Legenda 2
	Case cTp $ "S23/E23/E24/M23/M27/M28/"
		cBitMap := "gr_blue03" // Legenda 3
	Case cTp $ "S11/S12/E11/M11/M12/M15/"
		cBitMap := "gr_blue04" // Legenda 4
EndCase
Return cBitMap

/*/{Protheus.doc} VA3000131_LegendaEvento
Legenda dos Eventos

@author Andre Luis Almeida
@since 02/05/2023
/*/
Function VA3000131_LegendaEvento(cTp)
Local cTitulo  := IIf(cTp=="3",STR0046,STR0047) // Eventos da Transferência / Eventos da Troca
Local aLegenda := {}
aAdd(aLegenda,{"gr_blue01", STR0048 }) // Desagrega do Veículo/Máquina/Equipamento 1
aAdd(aLegenda,{"gr_blue02", STR0049 }) // Agrega no Veículo/Máquina/Equipamento 2
If cTp == "4" // 4 = Troca
	aAdd(aLegenda,{"gr_blue03", STR0050 }) // Desagrega do Veículo/Máquina/Equipamento 2
	aAdd(aLegenda,{"gr_blue04", STR0051 }) // Agrega no Veículo/Máquina/Equipamento 1
EndIf
BrwLegenda(cTitulo,STR0052,aLegenda) // Legenda
Return

/*/{Protheus.doc} VA300014D_Validacoes_Efetivacao
Validações antes da Efetivação da rotina Agrega/Desagrega Multieventos.

@author Francisco Carvalho
@since 09/03/2023
/*/
Function VA300014D_Validacoes_Efetivacao()
Local oCliente
Local oFornece
Local oPeca 
Local oVeiculos 
Local cQry      := ""
Local nCntFor   := 0
Local cCampo    := ""
Local nRegVFM   := 0 
Local cLocAux   := ""
Local nSaldoSB2 := 0
Local cTES      := ""
Local nRegVV1   := 0
Local cGruVei   := Padr(GetMv("MV_GRUVEI"),GetSX3Cache("B1_GRUPO","X3_TAMANHO"))
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBBUGMIL",.f.,.f.),"")
If VFJ->VFJ_TIPPRO == "1"// Operações com Notas Fiscais
	//Verificar se o TES selecionado no AMS movimenta estoque
	If VFJ->VFJ_TIPITE == "1"
		If VFJ->VFJ_PROCES $ "2/3/4/" //2 = Desagrega (individual), 3 = Transferência, 4 = Troca
			cQry := "SELECT VFP.VFP_CODTES "
			cQry += "  FROM "+RetSqlName("VFP")+" VFP "
			cQry += "  JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO = VFP.VFP_CODTES AND SF4.F4_ESTOQUE = 'N' AND SF4.D_E_L_E_T_ = ' ' "
			cQry += " WHERE VFP.VFP_FILIAL = '"+xFilial("VFP")+"' "
			cQry += "   AND VFP.VFP_CODEXE = '"+VFJ->VFJ_CODIGO+"'" 
			cQry += "   AND VFP.D_E_L_E_T_ = ' '"
			cTES := FM_SQL(cQry)
			If !Empty(cTES)
				MsgStop(STR0053+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;// O TES selecionado não movimenta estoque
				RetTitle("VFP_CODTES")+": "+cTES+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0054+": "+cSiglaAMS+" - "+STR0055,STR0057) // Aba / Desagrega / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif
		Endif
		If VFJ->VFJ_PROCES $ "1/3/4/" //1 = Agrega (individual), 3 = Transferência, 4 = Troca
			cQry := "SELECT VFM.VFM_CODTES "
			cQry += "  FROM "+RetSqlName("VFM")+" VFM "
			cQry += "  JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO = VFM.VFM_CODTES AND SF4.F4_ESTOQUE = 'N' AND SF4.D_E_L_E_T_ = ' ' "
			cQry += " WHERE VFM.VFM_FILIAL = '"+xFilial("VFM")+"' "
			cQry += "   AND VFM.VFM_CODEXE = '"+VFJ->VFJ_CODIGO+"'" 
			cQry += "   AND VFM.D_E_L_E_T_ = ' '"
			cTES := FM_SQL(cQry)
			If !Empty(cTES)
				MsgStop(STR0053+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;// O TES selecionado não movimenta estoque
				RetTitle("VFM_CODTES")+": "+cTES+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0054+": "+cSiglaAMS+" - "+STR0056,STR0057) // Aba / Agrega / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif
		Endif	
	//Verificar se o TES selecionado na Peça movimenta estoque	
	Elseif VFJ->VFJ_TIPITE == '2'
		If VFJ->VFJ_PROCES $ "2/3/4/" //2 = Desagrega(individual), 3 = Transferência, 4 = Troca
			cQry := "SELECT VFQ.VFQ_CODTES "
			cQry += "  FROM "+RetSqlName("VFQ")+" VFQ "
			cQry += "  JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO = VFQ.VFQ_CODTES AND SF4.F4_ESTOQUE = 'N' AND SF4.D_E_L_E_T_ = ' ' "
			cQry += " WHERE VFQ.VFQ_FILIAL = '"+xFilial("VFQ")+"' "
			cQry += "   AND VFQ.VFQ_CODEXE = '"+VFJ->VFJ_CODIGO+"'" 
			cQry += "   AND VFQ.D_E_L_E_T_ = ' '"
			cTES := FM_SQL(cQry)
			If !Empty(cTES)
				MsgStop(STR0053+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;// O TES selecionado não movimenta estoque
				RetTitle("VFN_CODTES")+": "+cTES+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0054+": "+STR0014+" - "+STR0055,STR0057) // Aba / Peças / Desagrega / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif
		Endif
		If VFJ->VFJ_PROCES $ "1/3/4/" //1 = Agrega(individual), 3 = Transferência, 4 = Troca
			cQry := "SELECT VFN.VFN_CODTES "
			cQry += "  FROM "+RetSqlName("VFN")+" VFN "
			cQry += "  JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO = VFN.VFN_CODTES AND SF4.F4_ESTOQUE = 'N' AND SF4.D_E_L_E_T_ = ' ' "
			cQry += " WHERE VFN.VFN_FILIAL = '"+xFilial("VFN")+"' "
			cQry += "   AND VFN.VFN_CODEXE = '"+VFJ->VFJ_CODIGO+"'" 
			cQry += "   AND VFN.D_E_L_E_T_ = ' '"
			cTES := FM_SQL(cQry)
			If !Empty(cTES)
				MsgStop(STR0053+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;// O TES selecionado não movimenta estoque
				RetTitle("VFN_CODTES")+": "+cTES+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0054+": "+STR0014+" - "+STR0056,STR0057) // Aba / Peças / Agrega / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif
		Endif	
	Endif
	//Verificar se o TES selecionado na NF de Saída movimenta estoque
	cQry := "SELECT VFK.VFK_CODTES "
	cQry += "  FROM "+RetSqlName("VFK")+" VFK "
	cQry += "  JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO = VFK.VFK_CODTES AND SF4.F4_ESTOQUE = 'N' AND SF4.D_E_L_E_T_ = ' ' "
	cQry += " WHERE VFK.VFK_FILIAL = '"+xFilial("VFK")+"' "
	cQry += "   AND VFK.VFK_CODEXE = '"+VFJ->VFJ_CODIGO+"'" 
	cQry += "   AND VFK.D_E_L_E_T_ = ' '"
	cTES := FM_SQL(cQry)
	If !Empty(cTES)
		MsgStop(STR0053+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;// O TES selecionado não movimenta estoque
		RetTitle("VFK_CODTES")+": "+cTES+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
		STR0054+": "+STR0058,STR0057) // Aba / Dados para a geração da Nota Fiscal de Saída. / Validações Agrega/Desagrega Multieventos
		Return .f.
	Endif
	//Verificar se o TES selecionado na NF de Entrada movimenta estoque
	cQry := "SELECT VFL.VFL_CODTES "
	cQry += "  FROM "+RetSqlName("VFL")+" VFL "
	cQry += "  JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO = VFL.VFL_CODTES AND SF4.F4_ESTOQUE = 'N' AND SF4.D_E_L_E_T_ = ' ' "
	cQry += " WHERE VFL.VFL_FILIAL = '"+xFilial("VFL")+"' "
	cQry += "   AND VFL.VFL_CODEXE = '"+VFJ->VFJ_CODIGO+"'" 
	cQry += "   AND VFL.D_E_L_E_T_ = ' '"
	cTES := FM_SQL(cQry)
	If !Empty(cTES)
		MsgStop(STR0053+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;// O TES selecionado não movimenta estoque
		RetTitle("VFL_CODTES")+": "+cTES+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
		STR0054+": "+STR0059,STR0057) // Aba / Dados para a geração da Nota Fiscal de Entrada. / Validações Agrega/Desagrega Multieventos
		Return .f.
	Endif
Endif

For nCntFor := 1 to 2 // CHAINT1 e CHAINT2
    If nCntFor == 2 .and. Empty(VFJ->VFJ_VV1002)
        Exit
    EndIf
    cQry := "SELECT R_E_C_N_O_ "
    cQry += "  FROM "+RetSqlName("VV1")
    cQry += " WHERE VV1_FILIAL = '"+xFilial("VV1")+"' " 
    cQry += " AND VV1_CHAINT = '"+IIf(nCntFor == 1,VFJ->VFJ_VV1001,VFJ->VFJ_VV1002)+"' "
    cQry += " AND VV1_SITVEI = '0' "
    cQry += " AND VV1_GRASEV <> '6' "
    cQry += " AND VV1_FILENT = '"+xFilial("VVF")+"' " 
    cQry += " AND D_E_L_E_T_ = ' '"
	nRegVV1 := FM_SQL(cQry)
	If nRegVV1 <= 0
        If nCntFor == 1
        	MsgStop(STR0060,STR0057) // O Veic/Maq. 1 não possui saldo em estoque. / Validações Agrega/Desagrega Multieventos
        ElseIf nCntFor == 2
			MsgStop(STR0061,STR0057) // O Veic/Maq. 2 não possui saldo em estoque. / Validações Agrega/Desagrega Multieventos
        EndIf
        Return .f.
    EndIf
    If nCntFor == 1 .and. VFJ->VFJ_CUSFT1 <= 0 
		MsgStop(STR0062,STR0057) // O custo futuro do Veic/Maq. 1 deverá ser maior que zero. / Validações Agrega/Desagrega Multieventos
        Return .f.
    ElseIf nCntFor == 2 .and. VFJ->VFJ_CUSFT2 <= 0
		MsgStop(STR0063,STR0057) // O custo futuro do Veic/Maq. 2 deverá ser maior que zero. / Validações Agrega/Desagrega Multieventos
        Return .f.
    EndIf
	DBSelectArea("VV1")
	DBGoTo(nRegVV1)
	oVeiculos := DMS_Veiculo():New()
	If oVeiculos:Bloqueado(VV1->VV1_CHAINT)
		Return .f. // A mensagem já é exibida dentro da função Bloqueado()
	Endif
	If oVeiculos:DtUltimaMovimentacao(VV1->VV1_CHASSI) > dDataBase // Valida referente a DataBase
		MsgStop(STR0064+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Chassi com movimentacao posterior a data atual.
				VV1->VV1_CHASSI,STR0057) // Validações Agrega/Desagrega Multieventos
		Return .f.
	Endif
	If FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT, /* cMVMIL0010 */ , cGruVei )
		cLocAux := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
		DBSelectArea("SB2")
		DBSetOrder(1)
		If DbSeek(xFilial("SB2")+SB1->B1_COD+cLocAux)
			nSaldoSB2 := SALDOSB2()
			If nSaldoSB2 < 1 // Valida Saldo
				MsgStop(STR0065+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Produto não possui saldo suficiente para atender a solicitação.
						Alltrim(SB1->B1_CODITE)+" - "+SB1->B1_DESC,STR0057) // Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif
		Endif
	Endif
Next

If VFJ->VFJ_TIPPRO == "1" // Notas Fiscais
    // Validações tabela de NF de Saida
    DBSelectArea("VFK")
    DBSetOrder(2)
    If DbSeek(xFilial("VFK") + VFJ->VFJ_CODIGO)
        // Verificação de cliente bloqueado
        DBSelectArea("SA1")
        DBSetOrder(1)
        If DbSeek(xFilial("SA1")+VFK->VFK_CODCLI+VFK->VFK_LOJCLI)
            oCliente := DMS_Cliente():New()
            If oCliente:Bloqueado(SA1->A1_COD , SA1->A1_LOJA, .T. ) // Cliente Bloqueado ?
                Return .f.
            Endif    
        Else
			MsgStop(STR0066,STR0057) // Cliente não encontrado. / Validações Agrega/Desagrega Multieventos
            Return .f.	
        EndIf
        DBSelectArea("VFK")
		DBSetOrder(2)// VFK_FILIAL+VFK_CODEXE
		DBSeek(xFilial("VFK")+VFJ->VFJ_CODIGO) //
        Do While !VFK->(Eof()) .and. VFK->VFK_FILIAL == xFilial("VFK") .and. VFK->VFK_CODEXE == VFJ->VFJ_CODIGO
            // Validações de campos obrigatórios
            cCampo := ""
			cTES   := ""
			If  VFK->VFK_TIPREG $ "1/3/" // Maq. Equip. 1 e Maq. Equip. 2
            	cCampo += IIf(Empty(cCampo).and.Empty(VFK->VFK_CODTES),"VFK_CODTES","")
				cQry := "SELECT F4_CODIGO FROM "+RetSqlName("SF4")+" WHERE F4_FILIAL='"+xFilial("SF4")+"' AND F4_CODIGO='"+VFK->VFK_CODTES+"' AND F4_DUPLIC='S' AND D_E_L_E_T_=' '"
				cTES := FM_SQL(cQry)
			Endif
			If  VFK->VFK_TIPREG $ "2/4/" //Peça
            	cCampo += IIf(Empty(cCampo).and.Empty(VFK->VFK_CODESP),"VFK_CODESP","")
			Endif		
            cCampo += IIf(Empty(cCampo).and.Empty(VFK->VFK_CODVEN),"VFK_CODVEN","")
            cCampo += IIf(Empty(cCampo).and.Empty(VFK->VFK_FORPAG).and.!Empty(cTES),"VFK_FORPAG","")
            cCampo += IIf(Empty(cCampo).and.Empty(VFK->VFK_NATURE).and.!Empty(cTES),"VFK_NATURE","")
            If !Empty(cCampo)
                MsgStop(STR0067+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;// Obrigatório o preenchimento para Efetivação.
						RetTitle(cCampo)+" ("+cCampo+")"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
					   STR0054+": "+STR0058,STR0057) // Aba / Dados para a geração da Nota Fiscal de Saída. / Validações Agrega/Desagrega Multieventos
                Return .f.
            EndIf
            VFK->(dbSkip())
        EndDo
    Endif
    // Validações na tabela de NF de Entrada
    DBSelectArea("VFL")
    DBSetOrder(2)
    If DbSeek(xFilial("VFL") + VFJ->VFJ_CODIGO)
        // Verificação de Fornecedor bloqueado
        DBSelectArea("SA2")
        DBSetOrder(1)
        If DbSeek(xFilial("SA2")+VFL->VFL_CODFOR+VFL->VFL_LOJFOR)
            oFornece := OFFornecedor():New()
            If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
                Return .f.
            EndIf
        Else
			MsgStop(STR0068,STR0057) // Fornecedor não encontrado. / Validações Agrega/Desagrega Multieventos
			Return .f.
		EndIf
		DBSelectArea("VFL")
		DBSetOrder(2) // VFL_FILIAL+VFL_CODEXE
		DBSeek(xFilial("VFL")+VFJ->VFJ_CODIGO)
		Do While !VFL->(Eof()) .and. VFL->VFL_FILIAL == xFilial("VFL") .and. VFL->VFL_CODEXE == VFJ->VFJ_CODIGO
			// Validações de campos obrigatórios
			cCampo := ""
			cTES   := ""
			If  VFL->VFL_TIPREG $ "1/3/" // Maq. Equip. 1 e Maq. Equip. 2
				cCampo += IIf(Empty(cCampo).and.Empty(VFL->VFL_CODTES),"VFL_CODTES","")
				cQry := "SELECT F4_CODIGO FROM "+RetSqlName("SF4")+" WHERE F4_FILIAL='"+xFilial("SF4")+"' AND F4_CODIGO='"+VFL->VFL_CODTES+"' AND F4_DUPLIC='S' AND D_E_L_E_T_=' '"
				cTES := FM_SQL(cQry)
			Endif
			cCampo += IIf(Empty(cCampo).and.Empty(VFL->VFL_FORPAG).and.!Empty(cTES),"VFL_FORPAG","")
			cCampo += IIf(Empty(cCampo).and.Empty(VFL->VFL_NATURE).and.!Empty(cTES),"VFL_NATURE","")
			If !Empty(cCampo)
				MsgStop(STR0067+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;// Obrigatório o preenchimento para Efetivação.
						RetTitle(cCampo)+" ("+cCampo+")"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
						STR0054+": "+STR0059,STR0057) // Aba / Dados para a geração da Nota Fiscal de Entrada. / Validações Agrega/Desagrega Multieventos
				Return .f.	
			EndIf
			VFL->(dbSkip())
		EndDo
	Endif
Endif
If VFJ->VFJ_TIPITE == "1" // 1=AMS
	If VFJ->VFJ_PROCES $ "1/3/4" // 1 = Agrega(individual), 3 = Transferência, 4 = Troca
		cQry := "SELECT R_E_C_N_O_"
		cQry += "  FROM "+RetSqlName("VFM")
		cQry += " WHERE VFM_CODEXE = '"+VFJ->VFJ_CODIGO+"'"
		cQry += "   AND D_E_L_E_T_ = ' '"
		If VFJ->VFJ_PROCES $ "1/4" // 1 = Agrega(individual) / 4 = Troca
			If FM_SQL(cQry+" AND VFM_VEIMAQ = '1'") <= 0
				MsgStop( cSiglaAMS+" - "+STR0069,STR0057) // Necessário preencher um ou mais registros para Veiculo/Maquina/Equipamento 1. / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif
		EndIf
		If VFJ->VFJ_PROCES $ "3/4" // 3 = Transferência / 4 = Troca
			If FM_SQL(cQry+" AND VFM_VEIMAQ = '2'") <= 0
				MsgStop( cSiglaAMS+" - "+STR0070,STR0057) // Necessário preencher um ou mais registros para Veiculo/Maquina/Equipamento 2. / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif
		EndIf
		If VFJ->VFJ_PROCES == "1" // 1=Agrega(individual)
			cQry := "SELECT VFM.R_E_C_N_O_ "
			cQry += "  FROM "+RetSqlName("VFM")+" VFM "
			cQry += " WHERE VFM.VFM_FILIAL = '"+xFilial("VFM")+"' " 
			cQry += "   AND VFM.VFM_CODEXE = '"+VFJ->VFJ_CODIGO+"' "
			cQry += "   AND VFM.VFM_CHAINT NOT IN ( "
			cQry +=                                 "SELECT VV1.VV1_CHAINT "
			cQry +=                                 "  FROM "+RetSqlName("VV1")+" VV1 "
			cQry +=                                 " WHERE VV1.VV1_FILIAL = '"+xFilial("VV1")+"' " 
			cQry +=                                 "   AND VV1.VV1_SITVEI = '0' "
			cQry +=                                 "   AND VV1.VV1_GRASEV = '6' "
			cQry +=                                 "   AND VV1.VV1_FILENT = '"+xFilial("VVF")+"' " 
			cQry +=                                 "   AND VV1.VV1_CHAINT = VFM.VFM_CHAINT "
			cQry +=                                 "   AND VV1.D_E_L_E_T_ = ' ' "
			cQry +=                             " ) "
			cQry += "   AND VFM.D_E_L_E_T_ = ' '"
			nRegVFM := FM_SQL(cQry)
			If nRegVFM > 0 .or. cDebugMIL == "VEIA300001"
				DBSelectArea("VFM")
				DBGoTo(nRegVFM)
				DBSelectArea("VV1")
				DBSetOrder(1)
				DbSeek(xFilial("VV1")+VFM->VFM_CHAINT)
				MsgStop(STR0071+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Chassi sem saldo em estoque.
						VV1->VV1_CHASSI+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
						STR0054+": "+cSiglaAMS+" - "+STR0056,STR0057) // Aba / Agrega / Validações Agrega/Desagrega Multieventos
				Return .f.
			EndIf
		Endif
		DBSelectArea("VFM")
		DBSetOrder(2)// VFM_FILIAL+VFM_CODEXE
		DBSeek(xFilial("VFM")+VFJ->VFJ_CODIGO)
		Do While !VFM->(EOF()) .and. VFM->VFM_FILIAL == xFilial("VFM") .and. VFM->VFM_CODEXE == VFJ->VFJ_CODIGO
			//Campo de preenchimento obrigatório (VFM_CODTES)
			If Empty(VFM->VFM_CODTES) .and. VFJ->VFJ_TIPPRO == "1" .or. cDebugMIL == "VEIA300002" //1 = Notas Fiscais
				MsgStop(STR0067+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;// Obrigatório o preenchimento para Efetivação.
						RetTitle("VFM_CODTES")+"(VFM_CODTES)"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
						STR0054+": "+cSiglaAMS+" - "+STR0056,STR0057) // Aba / Agrega / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif	 
			If VFJ->VFJ_PROCES $ "1/2/"	//Validação do estoque será feita apenas para 1=Agrega e 2=Desagrega
				DBSelectArea("VV1")
				DBSetOrder(1)
				If DBSeek(xFilial("VV1")+VFM->VFM_CHAINT)
					If FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT, /* cMVMIL0010 */ , cGruVei )
						cLocAux := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
						DBSelectArea("SB2")
						DBSetOrder(1)
						If DbSeek(xFilial("SB2")+SB1->B1_COD+cLocAux)
							nSaldoSB2 := SALDOSB2()
							If nSaldoSB2 < 1 // Valida Saldo
								MsgStop(cSiglaAMS+ " - "+STR0065+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Produto não possui saldo suficiente para atender a solicitação.
										SB1->B1_GRUPO+" "+Alltrim(SB1->B1_CODITE)+" - "+SB1->B1_DESC+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
										STR0054+": "+cSiglaAMS+" - "+STR0056,STR0057) // Aba / Agrega / Validações Agrega/Desagrega Multieventos
								Return .f.
							Endif
						Endif
					Endif	
				Endif
			Endif
			VFM->(dbSkip())
		EndDo
	Endif
	If VFJ->VFJ_PROCES $ "2/3/4" // 2 = Desagrega(individual), 3 = Transferência, 4 = Troca
		cQry := "SELECT R_E_C_N_O_ "
		cQry += "  FROM "+RetSqlName("VFP")
		cQry += " WHERE VFP_CODEXE = '"+VFJ->VFJ_CODIGO+"'" 
		cQry += "   AND D_E_L_E_T_ = ' '"
		If FM_SQL(cQry+" AND VFP_VEIMAQ = '1'") <= 0 .or. cDebugMIL == "VEIA300003"
			MsgStop( cSiglaAMS+" - "+STR0069,STR0057) // Necessário preencher um ou mais registros para Veiculo/Maquina/Equipamento 1. / Validações Agrega/Desagrega Multieventos
			Return .f.
		Endif
		If VFJ->VFJ_PROCES == "4" // 4 = Troca
			If FM_SQL(cQry+" AND VFP_VEIMAQ = '2'") <= 0 .or. cDebugMIL == "VEIA300004"
				MsgStop( cSiglaAMS+" - "+STR0070,STR0057) // Necessário preencher um ou mais registros para Veiculo/Maquina/Equipamento 2. / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif
		EndIf
		If VFJ->VFJ_TIPPRO == "1"//1 = Notas Fiscais
			DBSelectArea("VFP")
			DBSetOrder(2)// VFP_FILIAL+VFP_CODEXE
			DBSeek(xFilial("VFP")+VFJ->VFJ_CODIGO)
			Do While !VFP->(EOF()) .and. VFP->VFP_FILIAL == xFilial("VFP") .and. VFP->VFP_CODEXE == VFJ->VFJ_CODIGO
				//Campo de preenchimento obrigatório (VFP_CODTES)
				If Empty(VFP->VFP_CODTES) .or. cDebugMIL == "VEIA300005"
					MsgStop(STR0067+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;// Obrigatório o preenchimento para Efetivação.
							RetTitle("VFP_CODTES")+"(VFP_CODTES)"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
							STR0054+": "+cSiglaAMS+" - "+STR0055,STR0057) // Aba / Desagrega / Validações Agrega/Desagrega Multieventos
					Return .f.
				Endif	 
				VFP->(dbSkip())
			EndDo
		EndIf
	Endif
Elseif VFJ->VFJ_TIPITE == "2" // 2=Peças
	If VFJ->VFJ_PROCES $ "1/3/4" //1 = Agrega(individual), 3 = Transferência, 4 = Troca
		cQry := "SELECT R_E_C_N_O_ "
		cQry += "  FROM "+RetSqlName("VFN")
		cQry += " WHERE VFN_CODEXE = '"+VFJ->VFJ_CODIGO+"'"
		cQry += "   AND D_E_L_E_T_ = ' '"
		If VFJ->VFJ_PROCES $ "1/4" // 1 = Agrega(individual) / 4 = Troca
			If FM_SQL(cQry+" AND VFN_VEIMAQ = '1'") <= 0 .or. cDebugMIL == "VEIA300006"
				MsgStop(STR0014+" - "+STR0069,STR0057) // Peças / Necessário preencher um ou mais registros para Veiculo/Maquina/Equipamento 1. / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif
		EndIf
		If VFJ->VFJ_PROCES $ "3/4" // 3 = Transferencia / 4 = Troca
			If FM_SQL(cQry+" AND VFN_VEIMAQ = '2'") <= 0 .or. cDebugMIL == "VEIA300007"
				MsgStop(STR0014+" - "+STR0070,STR0057) // Peças / Necessário preencher um ou mais registros para Veiculo/Maquina/Equipamento 2. / Validações Agrega/Desagrega Multieventos
				Return .f.
			EndIf
		EndIf
		DBSelectArea("VFN")
		DBSetOrder(2)// VFN_FILIAL+VFN_CODEXE
		DBSeek(xFilial("VFN")+VFJ->VFJ_CODIGO)
		Do While !VFN->(Eof()) .and. VFN->VFN_FILIAL == xFilial("VFN") .and. VFN->VFN_CODEXE == VFJ->VFJ_CODIGO 
			//Campo de preenchimento obrigatório (VFN_CODSB1)
			If Empty(VFN->VFN_CODSB1) .or. cDebugMIL == "VEIA300008"
				MsgStop(STR0067+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Obrigatório o preenchimento para Efetivação.
						RetTitle("VFN_CODSB1")+"(VFN_CODSB1)"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
						STR0054+": "+STR0014+" - "+STR0056 ,STR0057) // Aba / Peças / Agrega / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif
			//Campo de preenchimento obrigatório (VFN_CODTES)
			If ( Empty(VFN->VFN_CODTES) .and. VFJ->VFJ_TIPPRO == "1" ) .or. cDebugMIL == "VEIA300009" //1 = Notas Fiscais
				MsgStop(STR0067+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Obrigatório o preenchimento para Efetivação.
						RetTitle("VFN_CODTES")+"(VFN_CODTES)"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
						STR0054+": "+STR0014+" - "+STR0056,STR0057) // Aba / Peças / Agrega / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif	
			// Validações de Produto Bloqueado
			DBSelectarea("SB1")
			DBSetOrder(1)
			DBSeek(xFilial("SB1")+VFN->VFN_CODSB1)
			oPeca := DMS_Peca():New()
			If oPeca:Bloqueado(VFN->VFN_CODSB1,,,.F.) // Verifica SB1 Bloqueado
				MsgStop(STR0072+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Produto bloqueado.
						SB1->B1_GRUPO+" "+Alltrim(SB1->B1_CODITE)+" - "+SB1->B1_DESC+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
						STR0054+": "+STR0014+" - "+STR0056,STR0057) // Aba / Peças / Agrega / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif
			cLocAux := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
			DBSelectArea("SB2")
			DBSetOrder(1)
			If DbSeek(xFilial("SB2")+SB1->B1_COD+cLocAux)
				nSaldoSB2 := SALDOSB2()
				If nSaldoSB2 < VFN->VFN_QUANT // Valida Saldo
					MsgStop(STR0065+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Produto não possui saldo suficiente para atender a solicitação.
							SB1->B1_GRUPO+" "+Alltrim(SB1->B1_CODITE)+" - "+SB1->B1_DESC+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
							STR0054+": "+STR0014+" - "+STR0056,STR0057) // Aba / Peças / Agrega / Validações Agrega/Desagrega Multieventos
					Return .f.
				Endif
			Endif
			VFN->(dbSkip())
		EndDo
	Endif	
	If VFJ->VFJ_PROCES $ "2/3/4" //2 = Desagrega(individual), 3 = Transferência, 4 = Troca
		cQry := "SELECT R_E_C_N_O_ "
		cQry += "  FROM "+RetSqlName("VFQ")
		cQry += " WHERE VFQ_CODEXE = '"+VFJ->VFJ_CODIGO+"'"
		cQry += "   AND D_E_L_E_T_ = ' '"
		If FM_SQL(cQry+" AND VFQ_VEIMAQ = '1'") <= 0 .or. cDebugMIL == "VEIA300010"
			MsgStop(STR0014+" - "+STR0069,STR0057) // Peças / Necessário preencher um ou mais registros para Veiculo/Maquina/Equipamento 1. / Validações Agrega/Desagrega Multieventos
			Return .f.
		Endif
		If VFJ->VFJ_PROCES == "4" // 4 = Troca
			If FM_SQL(cQry+" AND VFQ_VEIMAQ = '2'") <= 0 .or. cDebugMIL == "VEIA300011"
				MsgStop(STR0014+" - "+STR0070,STR0057) // Peças / Necessário preencher um ou mais registros para Veiculo/Maquina/Equipamento 2. / Validações Agrega/Desagrega Multieventos
				Return .f.
			EndIf
		EndIf
		DBSelectArea("VFQ")
		DBSetOrder(2)// VFQ_FILIAL+VFQ_CODEXE
		DBSeek(xFilial("VFQ")+VFJ->VFJ_CODIGO)
		Do While !VFQ->(Eof()) .and. VFQ->VFQ_FILIAL == xFilial("VFQ") .and. VFQ->VFQ_CODEXE == VFJ->VFJ_CODIGO
			//Campo de preenchimento obrigatório (VFQ_CODSB1)
			If Empty(VFQ->VFQ_CODSB1) .or. cDebugMIL == "VEIA300012"
				MsgStop(STR0067+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Obrigatório o preenchimento para Efetivação.
						RetTitle("VFQ_CODSB1")+"(VFQ_CODSB1)"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
						STR0054+": "+STR0014+" - "+STR0055,STR0057) // Aba / Peças / Desagrega / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif
			//Campo de preenchimento obrigatório (VFQ_CODTES)
			If Empty(VFQ->VFQ_CODTES) .and. VFJ->VFJ_TIPPRO == "1" .or. cDebugMIL == "VEIA300013" //1 = Notas Fiscais
				MsgStop(STR0067+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Obrigatório o preenchimento para Efetivação.
						RetTitle("VFQ_CODTES")+"(VFQ_CODTES)"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
						STR0054+": "+STR0014+" - "+STR0055,STR0057) // Aba / Peças / Desagrega / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif	 
			// Validações de Produto Bloqueado
			DBSelectarea("SB1")
			DBSetOrder(1)
			DBSeek(xFilial("SB1")+VFQ->VFQ_CODSB1)
			oPeca := DMS_Peca():New()
			If oPeca:Bloqueado(VFQ->VFQ_CODSB1,,,.F.) // Verifica SB1 Bloqueado
				MsgStop(STR0072+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Produto bloqueado.
						SB1->B1_GRUPO+" "+Alltrim(SB1->B1_CODITE)+" - "+SB1->B1_DESC+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
						STR0054+": "+STR0014+" - "+STR0055,STR0057) // Aba / Peças / Desagrega / Validações Agrega/Desagrega Multieventos
				Return .f.
			Endif
			VFQ->(dbSkip())
		EndDo
	Endif	
Endif
Return .t.

/*/{Protheus.doc} VA3000151_Grava_Status
Grava novo Status do Processo

@author Andre Luis Almeida
@since 17/02/2023
/*/
Function VA3000151_Grava_Status( cFilExe , cCodExe , cStatus )
Local oModelVFJ := FWLoadModel( 'VEIA317' ) // MVC somente para atualizar o cabeçalho VFJ
Default cFilExe := xFilial("VFJ")
Default cCodExe := ""
Default cStatus := "0" // 0=Digitado
//
VFJ->(DbSetOrder(1))
If VFJ->(DbSeek(cFilExe+cCodExe))
	If cStatus <> VFJ->VFJ_STATUS
		// Gravar Status
		oModelVFJ:SetOperation( MODEL_OPERATION_UPDATE )
		If oModelVFJ:Activate()
			oModelVFJ:SetValue( "VFJMASTER" , "VFJ_STATUS" , cStatus ) // 0=Digitado / 1=Efetivado / 2=Cancelado / 3=Efetivação Pendente ( problema para Efetivar )
			If cStatus == "1" // 1=Efetivado
				oModelVFJ:SetValue( "VFJMASTER" , "VFJ_DATEFE" , dDatabase )
				oModelVFJ:SetValue( "VFJMASTER" , "VFJ_HOREFE" , left(time(),2)+substr(time(),4,2) )
				oModelVFJ:SetValue( "VFJMASTER" , "VFJ_USREFE" , __cUserID )
			EndIf
			If oModelVFJ:VldData()
				oModelVFJ:CommitData()
			EndIf
			oModelVFJ:DeActivate()
		EndIf
	EndIf
EndIf
//
FreeObj(oModelVFJ)
//
Return

/*/{Protheus.doc} VA3000161_VisualizarDocumento
Visualizar Documento

@author Andre Luis Almeida
@since 12/05/2023
/*/
Function VA3000161_VisualizarDocumento()
Local nPos      := 0
Local cQuery    := ""
Local cSQLAlias := "SQLVBH"
Local aRet      := {""}
Local aDoc      := {}
Local aSeek     := {}
Local aParamBox := {}
Private cCadastro := STR0094 // Documentos Gerados
Private aRotina := {{ "" , "" , 0 , 1 },;
					{ "" , "" , 0 , 2 },;
					{ "" , "" , 0 , 3 },;
					{ "" , "" , 0 , 4 },;
					{ "" , "" , 0 , 5 }} // variavel necessária para rodar a Visualização do MATA241 - Movimentações Internas
If !Empty(VDV->VDV_CODIGO) .and. VDV->VDV_STATUS == "1" // Somente VALIDOS
	If VDV->VDV_TIPDOC == "1" // Notas Fiscais
		aAdd(aDoc ,Alltrim(VDV->VDV_SNUMNF)+"-"+Alltrim(VDV->VDV_SSERNF))
		aAdd(aSeek,{ "SF2" , VDV->VDV_SFILNF + VDV->VDV_SNUMNF + VDV->VDV_SSERNF })
		If !Empty(VDV->VDV_SNUMNP)
			aAdd(aDoc ,Alltrim(VDV->VDV_SNUMNP)+"-"+Alltrim(VDV->VDV_SSERNP))
			aAdd(aSeek,{ "SF2" ,  VDV->VDV_SFILNF + VDV->VDV_SNUMNP + VDV->VDV_SSERNP })
		EndIf
		aAdd(aDoc,Alltrim(VDV->VDV_ENUMNF)+"-"+Alltrim(VDV->VDV_ESERNF))
		aAdd(aSeek,{ "SF1" ,  VDV->VDV_EFILNF + VDV->VDV_ENUMNF + VDV->VDV_ESERNF + VDV->VDV_ECDFOR + VDV->VDV_ELJFOR })
		If !Empty(VDV->VDV_ENUMNP)
			aAdd(aDoc,Alltrim(VDV->VDV_ENUMNP)+"-"+Alltrim(VDV->VDV_ESERNP))
			aAdd(aSeek,{ "SF1" ,  VDV->VDV_EFILNF + VDV->VDV_ENUMNP + VDV->VDV_ESERNP + VDV->VDV_ECDFOP + VDV->VDV_ELJFOP })
		EndIf
	Else // Movimentações Internas
		cQuery := "SELECT VBH_DOCSD3 "
		cQuery += "  FROM "+RetSQLName("VBH")
		cQuery += " WHERE VBH_FILIAL = '"+xFilial("VBH")+"'"
		cQuery += "   AND VBH_CODVDV = '"+VDV->VDV_CODIGO+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY VBH_DOCSD3 " 
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
		While !(cSQLAlias)->(Eof())
			aAdd(aDoc,(cSQLAlias)->( VBH_DOCSD3 ))
			aAdd(aSeek,{ "SD3" , xFilial("SD3")+(cSQLAlias)->( VBH_DOCSD3 ) })
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
		DbSelectArea("VDV")
	EndIf
	While .t.
		aParamBox := {} // Necessario zerar e criar novamente para posicionar no ultimo pesquisado
		aAdd(aParamBox,{2,STR0094,aRet[1],aDoc,90,"",.t.,".t."}) // Documentos Gerados
		If ParamBox(aParamBox, STR0017 ,@aRet,,,,,,,,.F.,.F.) // Visualizar
			nPos := aScan(aDoc,aRet[1])
			If aSeek[nPos,1] == "SF1"
				DBSelectArea("SF1")
				dbSetOrder(1)
				If dbSeek(aSeek[nPos,2])
					MATA103(,,2)
				EndIf
			ElseIf aSeek[nPos,1] == "SF2"
				DbSelectArea("SF2")
				DbSetOrder(1)
				If DbSeek(aSeek[nPos,2])
					Mc090Visual("SF2",SF2->(Recno()),2)
				EndIf
			ElseIf aSeek[nPos,1] == "SD3"
				DbSelectArea("SD3")
				DbSetOrder(2)
				If DbSeek(aSeek[nPos,2])
					A241Visual("SD3",SD3->(Recno()),2)
				EndIf
			EndIf
			//Necessário limpar os atalhos pois ao realizar a chamada das rotinas de visualização (backoffice) alguns atalhos permaneciam ativos mesmo após fechar a tela.
			SetKey(VK_F4, Nil)
			SetKey(VK_F5, Nil) 
			SetKey(VK_F6, Nil) 
			SetKey(VK_F7, Nil) 
			SetKey(VK_F8, Nil) 
			SetKey(VK_F9, Nil)  
			SetKey(VK_F10, Nil)
		Else
			Exit
		EndIf
	EndDo
EndIf
Return


/*/{Protheus.doc} VA300017D_RetornaCliente
Retorna um array contendo dados do cadastro de cliente da filial logada.

@author Francisco Carvalho
@since 23/04/2024
/*/
Function VA300017D_RetornaCliente()
Local lRet := .f.
Local aRet     := {}
Local aSM0     := {}
Local oCliente
//
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt)
//
DBSelectArea("SA1")
DBSetOrder(3)
If DbSeek(xFilial("SA1")+aSM0[SM0_CGC])
	oCliente := DMS_Cliente():New()
	lRet := !oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
	If lRet	
		aRet := {SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NOME, SA1->A1_TIPO} // Cliente
	EndIf
Else
	Help("",1,"VLDACTIVATE",,STR0073,1,0) // Não existe cliente relacionado a filial logada.
EndIf
If lRet .and. ExistBlock("VA300SA1")
	// Parametros: {  { SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NOME, SA1->A1_TIPO }  ,  Processo: 1=Agrega (Individual) / 2=Desagrega (Individual) / 3=Transferência / 4=Troca  ,  Tipo: 1=Notas Fiscais / 2=Movimentações Internas  ,  Item: 1=AMS / 2=Peças }
	aRet := ExecBlock("VA300SA1", .f., .f., { aRet ,VFJ->VFJ_PROCES ,VFJ->VFJ_TIPPRO ,VFJ->VFJ_TIPITE })
EndIf
DBSelectArea("SA1")
DBSetOrder(1)

Return aRet



/*/{Protheus.doc} VA300018D_RetornaFornecedor
Retorna um array contendo dados do cadastro de fornecedor da filial logada.

@author Francisco Carvalho
@since 23/04/2024
/*/
Function VA300018D_RetornaFornecedor()
Local lRet := .f.
Local aRet := {}
Local aSM0 := {}
Local oFornece
//
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt)
//
DBSelectArea("SA2")
DBSetOrder(3)
If DbSeek(xFilial("SA2")+aSM0[SM0_CGC])
	oFornece := OFFornecedor():New()
	lRet := !oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
	If lRet
		aRet := {SA2->A2_COD, SA2->A2_LOJA, SA2->A2_NOME, SA2->A2_TIPO}
	EndIf
Else
	Help("",1,"VLDACTIVATE",,STR0074,1,0) // Não existe fornecedor relacionado a filial logada.
EndIf
If lRet .and. ExistBlock("VA300SA2")
	// Parametros: {  { SA2->A2_COD, SA2->A2_LOJA, SA2->A2_NOME, SA2->A2_TIPO }  ,  Processo: 1=Agrega (Individual) / 2=Desagrega (Individual) / 3=Transferência / 4=Troca  ,  Tipo: 1=Notas Fiscais / 2=Movimentações Internas  ,  Item: 1=AMS / 2=Peças }
	aRet := ExecBlock("VA300SA2", .f., .f., { aRet , VFJ->VFJ_PROCES ,VFJ->VFJ_TIPPRO ,VFJ->VFJ_TIPITE })
EndIf
DBSelectArea("SA2")
DBSetOrder(1)

Return aRet

/*/{Protheus.doc} VA300019H_PermiteCancAgrega
Verifica, se o usuário tem permissão em cancelar nota na rotina Agrega Desagrega

@author João Victor Silva
@since 24/01/2025
/*/

Static Function VA300019H_PermiteCancAgrega()
Local lVAI_CANCAG := VAI->(FieldPos("VAI_CANCAG")) > 0
Local lRet := .t.

if !lVAI_CANCAG
	return .t. // Caso o usuário não ter o campo, o funcionamento continua o mesmo
Endif

dbSelectArea("VAI")
VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID)) // Posiciona no VAI do usuario logado
If VAI->VAI_CANCAG == "0" //Verifica a permissao para cancelar nota Agrega/Desagrega
	FMX_HELP("VA300019H_PermiteCancAgrega", STR0095) //Usuário sem permissão para cancelar o Agrega/Desagrega. Verifique o cadastro da equipe técnica
	lRet := .f.
EndIf

Return lRet

Function VA300022H_RelatorioAgrDs()
	
	ExecBlock("RELAGDG",.f.,.f.)
		
Return