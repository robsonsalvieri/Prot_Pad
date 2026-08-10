#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA360.CH"

/*/{Protheus.doc} VEIA360
	Antecipos - Mercado Internacional

	@author Andre Luis Almeida
	@since 19/11/2024
/*/
Function VEIA360()
Local aSize       := FWGetDialogSize( oMainWnd )
Local cQueryVBT   := ""
Local cQuerySF1   := ""
Private cCadastro := STR0001 // Central de Antecipos
Private a360Totais := {}
Private a360Moedas := {}
Private oLbTotais
Private oTmpTable1
Private oTmpTable2
Private oTmpTable3

If ! (cPaisLoc $ "ARG/MEX") // Utilizado somente na ARGENTINA e MEXICO
	FMX_HELP("VEIA360_HELP01",STR0003+CHR(13)+CHR(10)+cPaisLoc) // Rotina não disponível para o Pais.
	Return
EndIf

Processa( { || VA3600061_Carregar_Tabelas_Temporarias() } )

aAdd(a360Moedas,GetMv("MV_SIMB1"))
aAdd(a360Moedas,GetMv("MV_SIMB2"))
aAdd(a360Moedas,GetMv("MV_SIMB3"))
aAdd(a360Moedas,GetMv("MV_SIMB4"))
aAdd(a360Moedas,GetMv("MV_SIMB5"))

aAdd(a360Totais,{STR0004,""}) // Total do Antecipo
aAdd(a360Totais,{STR0005,""}) // Total utilizado
aAdd(a360Totais,{STR0006,""}) // Saldo disponível

// Relacionamento com Origens
cQueryVBT := "SELECT VBT.VBT_CODIGO "
cQueryVBT += "  FROM " + RetSqlName("VBT") + " VBT "
cQueryVBT += " WHERE VBT.VBT_FILIAL = '"+xFilial("VBT")+"'"
cQueryVBT += "   AND VBT.VBT_FILANT = F2_FILIAL "
cQueryVBT += "   AND VBT.VBT_NRFANT = F2_DOC "
cQueryVBT += "   AND VBT.VBT_SRFANT = F2_SERIE "
cQueryVBT += "   AND VBT.VBT_CODCLI = F2_CLIENTE "
cQueryVBT += "   AND VBT.VBT_LOJCLI = F2_LOJA "
cQueryVBT += "   AND VBT.VBT_ATIVO  = '1' "
cQueryVBT += "   AND VBT.D_E_L_E_T_ = ' ' "

// Relacionamento com Notas de Crédito
cQuerySF1 := "SELECT SF1.F1_DOC "
cQuerySF1 += "  FROM " + RetSqlName("SF1") + " SF1 "
cQuerySF1 += " WHERE SF1.F1_FILIAL  = F2_FILIAL "
cQuerySF1 += "   AND SF1.F1_NFORIG  = F2_DOC "
cQuerySF1 += "   AND SF1.F1_SERORIG = F2_SERIE "
cQuerySF1 += "   AND SF1.F1_FORNECE = F2_CLIENTE "
cQuerySF1 += "   AND SF1.F1_LOJA    = F2_LOJA "
cQuerySF1 += "   AND SF1.F1_ESPECIE = 'NCC' "
cQuerySF1 += "   AND SF1.D_E_L_E_T_ = ' ' "

oDlgVA360 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0001, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Central de Antecipos

	oWAVA360 := FWUIWorkArea():New( oDlgVA360 ) // Work Area
	oWAVA360:CreateHorizontalBox( "LINE01", 60 )
	oWAVA360:SetBoxCols( "LINE01", { "OBJ1" } )
	oWAVA360:CreateHorizontalBox( "LINE02", 40 )
	oWAVA360:SetBoxCols( "LINE02", { "OBJ2" } )
	oWAVA360:Activate()

	@ 000,000 FOLDER oFolder360 SIZE 100,100 OF oWAVA360:GetPanel("OBJ2") PROMPTS STR0007,STR0009,STR0010 PIXEL // Totais / Origens relacionadas ao Antecipo / Notas de Crédito relacionadas ao Antecipo
	oFolder360:Align := CONTROL_ALIGN_ALLCLIENT
	oFolder360:bChange    := {|| VA3600091_Refresh(.f.,.t.,.t.,.t.) } // (lSF2,lTot,lTMP,lNCC)

	oLbTotais := TWBrowse():New( 000 , 000 , 100 , 100 ,,,, oFolder360:aDialogs[1] ,,,,, { || .t. } ,,,,,,,.F.,,.T.,,.F.,,,)
	oLbTotais:setArray( a360Totais )
	oLbTotais:addColumn( TCColumn():new( STR0007 , { || a360Totais[oLbTotais:nAt,1] } ,,,, "LEFT"  , 400 ,.F.,.F.,,,,.F.,) ) // Totais
	oLbTotais:addColumn( TCColumn():new( STR0008 , { || a360Totais[oLbTotais:nAt,2] } ,,,, "RIGHT" ,  50 ,.F.,.F.,,,,.F.,) ) // Valor
	oLbTotais:Align := CONTROL_ALIGN_ALLCLIENT

	oBrwSF2 := FWMBrowse():New()
	oBrwSF2:SetAlias("SF2")
	oBrwSF2:SetDescription(STR0001) // Central de Antecipos
	oBrwSF2:SetOwner(oWAVA360:GetPanel("OBJ1"))
	oBrwSF2:SetMenuDef( '' )
	oBrwSF2:AddButton(STR0011 , {|| VA3600021_Cadastro_de_Antecipos() },,2,2) // Cadastro de Antecipos
	oBrwSF2:AddButton(STR0012 , {|| VA3600041_Nota_Credito() },,2,2) // Cadastro de Notas de Crédito
	oBrwSF2:AddButton(STR0013 , {|| VA3600031_Relacionar_com_Origens() },,2,2) // Relacionar Antecipo com Origens
	oBrwSF2:AddFilter(STR0014,"@ NOT EXISTS ( "+cQueryVBT+" )",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar / Antecipos sem relacionamentos com Origens
	oBrwSF2:AddFilter(STR0015,"@ EXISTS ( "+cQueryVBT+" )",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar / Antecipos com relacionamentos com Origens
	oBrwSF2:AddFilter(STR0016,"@ EXISTS ( "+cQueryVBT+" AND VBT.VBT_TIPORI = '1' )",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar / Antecipos relacionados a Atendimentos
	oBrwSF2:AddFilter(STR0017,"@ EXISTS ( "+cQueryVBT+" AND VBT.VBT_TIPORI = '2' )",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar / Antecipos relacionados a Orçamentos
	oBrwSF2:AddFilter(STR0018,"@ EXISTS ( "+cQueryVBT+" AND VBT.VBT_TIPORI = '3' )",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar / Antecipos relacionados a Ordens de Serviço
	oBrwSF2:AddFilter(STR0026,"@ NOT EXISTS ( "+cQuerySF1+" )",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar / Antecipos sem Notas de Crédito relacionadas
	oBrwSF2:AddFilter(STR0027,"@ EXISTS ( "+cQuerySF1+" )",.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar / Antecipos com Notas de Crédito relacionadas
	oBrwSF2:DisableDetails()
	oBrwSF2:SetChange( { || VA3600011_Totaliza() } )
	oBrwSF2:SetDoubleClick( { || VA3600031_Relacionar_com_Origens() } )
	VA3600161_F12_FILTRO(.f.,.f.)
	oBrwSF2:DisableLocate()
	oBrwSF2:SetAmbiente(.F.)
	oBrwSF2:SetWalkthru(.F.)
	oBrwSF2:lOptionReport := .F.
	oBrwSF2:DisableReport()
	oBrwSF2:ForceQuitButton()
	oBrwSF2:Activate()

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oFolder360:aDialogs[2],.f.)
	oFWLayer:AddLine("UP",100,.F.)
	oFWLayer:AddCollumn("OBJTMP1",33,.F.,"UP")
	oFWLayer:AddCollumn("OBJTMP2",33,.F.,"UP")
	oFWLayer:AddCollumn("OBJTMP3",33,.F.,"UP")

	oBrwTMP1 := FWMBrowse():New()
	oBrwTMP1:SetAlias("TEMP1")
	oBrwTMP1:SetDescription("")
	oBrwTMP1:SetOwner(oFWLayer:getColPanel('OBJTMP1','UP'))
	oBrwTMP1:SetMenuDef( '' )
	oBrwTMP1:SetColumns(VA3600071_Colunas_Browse("NUMATE"))
	oBrwTMP1:SetDoubleClick( { || VA3600081_Ver_Origem("1",TEMP1->Z_RECORI,.t.) } )
	oBrwTMP1:SetDelete(.T. , { || VA3600121_Deletar_Relacionamento("1",TEMP1->Z_RECVBT) })
	oBrwTMP1:DisableDetails()
	oBrwTMP1:DisableLocate()
	oBrwTMP1:SetAmbiente(.F.)
	oBrwTMP1:SetWalkthru(.F.)
	oBrwTMP1:SetUseFilter(.F.)
	oBrwTMP1:DisableSeek()
	oBrwTMP1:lOptionReport := .F.
	oBrwTMP1:DisableReport()
	oBrwTMP1:Activate()
	oRelacTMP1 := FWBrwRelation():New()
	oRelacTMP1:AddRelation( oBrwSF2 , oBrwTMP1 , { { "Z_FILANT", "F2_FILIAL" } , { "Z_NRFANT" , "F2_DOC" } , { "Z_SRFANT" , "F2_SERIE" } , { "Z_CODCLI" , "F2_CLIENTE" } , { "Z_LOJCLI" , "F2_LOJA" } })
	oRelacTMP1:Activate()

	oBrwTMP2 := FWMBrowse():New()
	oBrwTMP2:SetAlias("TEMP2")
	oBrwTMP2:SetDescription("")
	oBrwTMP2:SetOwner(oFWLayer:getColPanel('OBJTMP2','UP'))
	oBrwTMP2:SetMenuDef( '' )
	oBrwTMP2:SetColumns(VA3600071_Colunas_Browse("NUMORC"))
	oBrwTMP2:SetDoubleClick( { || VA3600081_Ver_Origem("2",TEMP2->Z_RECORI,.t.) } )
	oBrwTMP2:SetDelete(.T. , { || VA3600121_Deletar_Relacionamento("2",TEMP2->Z_RECVBT) })
	oBrwTMP2:DisableDetails()
	oBrwTMP2:DisableLocate()
	oBrwTMP2:SetAmbiente(.F.)
	oBrwTMP2:SetWalkthru(.F.)
	oBrwTMP2:SetUseFilter(.F.)
	oBrwTMP2:DisableSeek()
	oBrwTMP2:lOptionReport := .F.
	oBrwTMP2:DisableReport()
	oBrwTMP2:Activate()
	oRelacTMP2 := FWBrwRelation():New()
	oRelacTMP2:AddRelation( oBrwSF2 , oBrwTMP2 , { { "Z_FILANT", "F2_FILIAL" } , { "Z_NRFANT" , "F2_DOC" } , { "Z_SRFANT" , "F2_SERIE" } , { "Z_CODCLI" , "F2_CLIENTE" } , { "Z_LOJCLI" , "F2_LOJA" } })
	oRelacTMP2:Activate()

	oBrwTMP3 := FWMBrowse():New()
	oBrwTMP3:SetAlias("TEMP3")
	oBrwTMP3:SetDescription("")
	oBrwTMP3:SetOwner(oFWLayer:getColPanel('OBJTMP3','UP'))
	oBrwTMP3:SetMenuDef( '' )
	oBrwTMP3:SetColumns(VA3600071_Colunas_Browse("NUMOSV"))
	oBrwTMP3:SetDoubleClick( { || VA3600081_Ver_Origem("3",TEMP3->Z_RECORI,.t.) } )
	oBrwTMP3:SetDelete(.T. , { || VA3600121_Deletar_Relacionamento("3",TEMP3->Z_RECVBT) })
	oBrwTMP3:DisableDetails()
	oBrwTMP3:DisableLocate()
	oBrwTMP3:SetAmbiente(.F.)
	oBrwTMP3:SetWalkthru(.F.)
	oBrwTMP3:SetUseFilter(.F.)
	oBrwTMP3:DisableSeek()
	oBrwTMP3:lOptionReport := .F.
	oBrwTMP3:DisableReport()
	oBrwTMP3:Activate()
	oRelacTMP3 := FWBrwRelation():New()
	oRelacTMP3:AddRelation( oBrwSF2 , oBrwTMP3 , { { "Z_FILANT", "F2_FILIAL" } , { "Z_NRFANT" , "F2_DOC" } , { "Z_SRFANT" , "F2_SERIE" } , { "Z_CODCLI" , "F2_CLIENTE" } , { "Z_LOJCLI" , "F2_LOJA" } })
	oRelacTMP3:Activate()

	oBrwNCC := FWMBrowse():New()
	oBrwNCC:SetAlias("SF1")
	oBrwNCC:SetDescription("")
	oBrwNCC:SetOwner(oFolder360:aDialogs[3])
	oBrwNCC:SetMenuDef( '' )
	oBrwNCC:DisableDetails()
	oBrwNCC:DisableLocate()
	oBrwNCC:SetAmbiente(.F.)
	oBrwNCC:SetWalkthru(.F.)
	oBrwNCC:SetUseFilter(.F.)
	oBrwNCC:DisableSeek()
	oBrwNCC:lOptionReport := .F.
	oBrwNCC:DisableReport()
	oBrwNCC:ForceQuitButton()
	oBrwNCC:Activate()
	oRelacNCC := FWBrwRelation():New()
	oRelacNCC:AddRelation( oBrwSF2 , oBrwNCC , { { "F1_FILIAL", "F2_FILIAL" } , { "F1_NFORIG" , "F2_DOC" } , { "F1_SERORIG" , "F2_SERIE" } , { "F1_FORNECE" , "F2_CLIENTE" } , { "F1_LOJA" , "F2_LOJA" } , { "F1_ESPECIE" , "'NCC'" } })
	oRelacNCC:Activate()

oDlgVA360:Activate( , , , , , , ) //ativa a janela

oTmpTable1:CloseTable()
oTmpTable2:CloseTable()
oTmpTable3:CloseTable()

VA3600051_SetKey(.f.)

Return

/*/{Protheus.doc} VA3600011_Totaliza
Totaliza Antecipo

@author Andre Luis Almeida
@since 29/11/2024
/*/
Static Function VA3600011_Totaliza()
Local cQAlias   := "SQLSE1"
Local cQuery    := ""
Local nPosMoeda := 1
Local nVlrSE1   := 0
Local nSldSE1   := 0
If SF2->F2_MOEDA > 0 .and. SF2->F2_MOEDA < 6
	nPosMoeda := SF2->F2_MOEDA
EndIf
cQuery := "SELECT SUM(E1_VALOR) VLRSE1 , SUM(E1_SALDO) SLDSE1 "
cQuery += "  FROM "+ RetSQLName("SE1")
cQuery += " WHERE E1_FILIAL  = '"+xFilial("SE1")+"'"
cQuery += "   AND E1_PREFIXO = '"+SF2->F2_PREFIXO+"'"
cQuery += "   AND E1_NUM     = '"+SF2->F2_DOC+"'"
cQuery += "   AND E1_CLIENTE = '"+SF2->F2_CLIENTE+"'"
cQuery += "   AND E1_LOJA    = '"+SF2->F2_LOJA+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
If !( cQAlias )->( Eof() )
	nVlrSE1 := ( cQAlias )->( VLRSE1 )
	nVlrSE1 := ( cQAlias )->( SLDSE1 )
EndIf
( cQAlias )->( dbCloseArea() )
DbSelectArea("SF2")
a360Totais[1,2] := a360Moedas[nPosMoeda]+" "+Transform(nVlrSE1,"@E 9999,999,999,999.99")
a360Totais[2,2] := a360Moedas[nPosMoeda]+" "+Transform(nVlrSE1-nSldSE1,"@E 9999,999,999,999.99")
a360Totais[3,2] := a360Moedas[nPosMoeda]+" "+Transform(nSldSE1,"@E 9999,999,999,999.99")
VA3600091_Refresh(.f.,.t.,.f.,.f.) // (lSF2,lTot,lTMP,lNCC)
Return

/*/{Protheus.doc} VA3600021_Cadastro_de_Antecipos
Cadastro de Antecipos

@author Andre Luis Almeida
@since 29/11/2024
/*/
Static Function VA3600021_Cadastro_de_Antecipos()
Local cSlvFName := FunName()
Local nRecSF2   := SF2->(RecNo())
VA3600051_SetKey(.f.)
cCadastro := STR0011 // Cadastro de Antecipos
SetFunName("MATA467N")
MATA467N(,,,,,1)
SetFunName(cSlvFName)
cCadastro := STR0001 // Central de Antecipos
SF2->(DbGoTo(nRecSF2))
VA3600161_F12_FILTRO(.f.,.t.)
Return

/*/{Protheus.doc} VA3600031_Relacionar_com_Origens
Relacionar Antecipo com Origens

@author Andre Luis Almeida
@since 06/12/2024
/*/
Static Function VA3600031_Relacionar_com_Origens()
Local aSize       := FWGetDialogSize( oMainWnd )
Local nCntFor     := 0
Local nRecVBT     := 0
Local aVBT        := {}
Local nRecSF2     := SF2->(RecNo())
Local cFilANT     := SF2->F2_FILIAL
Local cNRFANT     := SF2->F2_DOC
Local cSRFANT     := SF2->F2_SERIE
Local cCodCli     := SF2->F2_CLIENTE
Local cLojCli     := SF2->F2_LOJA
Local lOkTela     := .f.
Private aRegVV9   := {}
Private aSlvVV9   := {}
Private aRegVS1   := {}
Private aSlvVS1   := {}
Private aRegVO1   := {}
Private aSlvVO1   := {}
Private cCadastro := STR0013 // Relacionar Antecipo com Origens

VA3600051_SetKey(.f.)

VA3600131_Levanta_Relacionamentos(cFilANT,cNRFANT,cSRFANT,cCodCli,cLojCli) // Levanta VBT

oDlg360Rel := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0013, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Relacionar Antecipo com Origens

	@ 000,000 FOLDER oFolderRel SIZE 100,100 OF oDlg360Rel PROMPTS STR0019,STR0020,STR0021 PIXEL // Atendimentos de Veículos/Máquinas / Orçamentos / Ordens de Serviço
	oFolderRel:Align := CONTROL_ALIGN_ALLCLIENT

	oBrwVV9 := FWMBrowse():New()
	oBrwVV9:SetAlias("VV9")
	oBrwVV9:SetDescription(STR0019) // Atendimentos de Veículos/Máquinas
	oBrwVV9:SetOwner(oFolderRel:aDialogs[1])
	oBrwVV9:SetMenuDef( '' )
	oBrwVV9:AddMarkColumns( { || VA3600101_Coluna_Mark("1") },{ || VA3600111_Mark_Registro("1") }, )
	oBrwVV9:SetDoubleClick( { || VA3600081_Ver_Origem("1",VV9->(RecNo()),.f.) } )
	oBrwVV9:SetFilterDefault( "@ VV9_CODCLI = '"+cCodCli+"' AND VV9_LOJA = '"+cLojCli+"'" )
	oBrwVV9:DisableDetails()
	oBrwVV9:DisableLocate()
	oBrwVV9:SetAmbiente(.F.)
	oBrwVV9:SetWalkthru(.F.)
	oBrwVV9:lOptionReport := .F.
	oBrwVV9:DisableReport()
	oBrwVV9:Activate()

	oBrwVS1 := FWMBrowse():New()
	oBrwVS1:SetAlias("VS1")
	oBrwVS1:SetDescription(STR0020) // Orçamentos
	oBrwVS1:SetOwner(oFolderRel:aDialogs[2])
	oBrwVS1:SetMenuDef( '' )
	oBrwVS1:AddMarkColumns( { || VA3600101_Coluna_Mark("2") },{ || VA3600111_Mark_Registro("2") }, )
	oBrwVS1:SetDoubleClick( { || VA3600081_Ver_Origem("2",VS1->(RecNo()),.f.) } )
	oBrwVS1:SetFilterDefault( "@ VS1_CLIFAT = '"+cCodCli+"' AND VS1_LOJA = '"+cLojCli+"'" )
	oBrwVS1:DisableDetails()
	oBrwVS1:DisableLocate()
	oBrwVS1:SetAmbiente(.F.)
	oBrwVS1:SetWalkthru(.F.)
	oBrwVS1:lOptionReport := .F.
	oBrwVS1:DisableReport()
	oBrwVS1:Activate()

	oBrwVO1 := FWMBrowse():New()
	oBrwVO1:SetAlias("VO1")
	oBrwVO1:SetDescription(STR0021) // Ordens de Serviço
	oBrwVO1:SetOwner(oFolderRel:aDialogs[3])
	oBrwVO1:SetMenuDef( '' )
	oBrwVO1:AddMarkColumns( { || VA3600101_Coluna_Mark("3") },{ || VA3600111_Mark_Registro("3") }, )
	oBrwVO1:SetDoubleClick( { || VA3600081_Ver_Origem("3",VO1->(RecNo()),.f.) } )
	oBrwVO1:SetFilterDefault( "@ VO1_PROVEI = '"+cCodCli+"' AND VO1_LOJPRO = '"+cLojCli+"'" )
	oBrwVO1:DisableDetails()
	oBrwVO1:DisableLocate()
	oBrwVO1:SetAmbiente(.F.)
	oBrwVO1:SetWalkthru(.F.)
	oBrwVO1:lOptionReport := .F.
	oBrwVO1:DisableReport()
	oBrwVO1:Activate()
	
oDlg360Rel:Activate( , , , .t. , , , EnchoiceBar( oDlg360Rel, {|| lOkTela := .t. , oDlg360Rel:End() }, { || oDlg360Rel:End() }, ,, , , , , .F., .T. ) )

If lOkTela
	// Excluir VBT
	For nCntFor := 1 to len(aSlvVV9)
		If aScan(aRegVV9,{|x| x[1]+x[2] == aSlvVV9[nCntFor,1]+aSlvVV9[nCntFor,2] }) == 0
			VA3610021_MVC_VBT_DESATIVAR( aSlvVV9[nCntFor,3] ) // Desativar o VBT que foi desmarcado
			VA3600151_DELETE_TAB_TEMP("1",aSlvVV9[nCntFor,3]) // Excluir na Tabela Temporaria
		EndIf
	Next
	For nCntFor := 1 to len(aSlvVS1)
		If aScan(aRegVS1,{|x| x[1]+x[2] == aSlvVS1[nCntFor,1]+aSlvVS1[nCntFor,2] }) == 0
			VA3610021_MVC_VBT_DESATIVAR( aSlvVS1[nCntFor,3] ) // Desativar o VBT que foi desmarcado
			VA3600151_DELETE_TAB_TEMP("2",aSlvVS1[nCntFor,3]) // Excluir na Tabela Temporaria
		EndIf
	Next
	For nCntFor := 1 to len(aSlvVO1)
		If aScan(aRegVO1,{|x| x[1]+x[2] == aSlvVO1[nCntFor,1]+aSlvVO1[nCntFor,2] }) == 0
			VA3610021_MVC_VBT_DESATIVAR( aSlvVO1[nCntFor,3] ) // Desativar o VBT que foi desmarcado
			VA3600151_DELETE_TAB_TEMP("3",aSlvVO1[nCntFor,3]) // Excluir na Tabela Temporaria
		EndIf
	Next
	// Incluir VBT
	For nCntFor := 1 to len(aRegVV9)
		If aScan(aSlvVV9,{|x| x[1]+x[2] == aRegVV9[nCntFor,1]+aRegVV9[nCntFor,2] }) == 0
			aVBT := {}
			aAdd(aVBT,{ "VBT_TIPORI" , "1" }) // Atendimentos
			aAdd(aVBT,{ "VBT_FILORI" , aRegVV9[nCntFor,1] })
			aAdd(aVBT,{ "VBT_NUMATE" , aRegVV9[nCntFor,2] })
			aAdd(aVBT,{ "VBT_FILANT" , cFilANT })
			aAdd(aVBT,{ "VBT_NRFANT" , cNRFANT })
			aAdd(aVBT,{ "VBT_SRFANT" , cSRFANT })
			aAdd(aVBT,{ "VBT_CODCLI" , cCodCli })
			aAdd(aVBT,{ "VBT_LOJCLI" , cLojCli })
			nRecVBT := VA3610011_MVC_VBT( 0 , aVBT ) // Incluir VBT que foi marcado
			VA3600141_INSERT_TAB_TEMP("1",nRecVBT) // Incluir na Tabela Temporaria
		EndIf
	Next
	For nCntFor := 1 to len(aRegVS1)
		If aScan(aSlvVS1,{|x| x[1]+x[2] == aRegVS1[nCntFor,1]+aRegVS1[nCntFor,2] }) == 0
			aVBT := {}
			aAdd(aVBT,{ "VBT_TIPORI" , "2" }) // Orçamentos
			aAdd(aVBT,{ "VBT_FILORI" , aRegVS1[nCntFor,1] })
			aAdd(aVBT,{ "VBT_NUMORC" , aRegVS1[nCntFor,2] })
			aAdd(aVBT,{ "VBT_FILANT" , cFilANT })
			aAdd(aVBT,{ "VBT_NRFANT" , cNRFANT })
			aAdd(aVBT,{ "VBT_SRFANT" , cSRFANT })
			aAdd(aVBT,{ "VBT_CODCLI" , cCodCli })
			aAdd(aVBT,{ "VBT_LOJCLI" , cLojCli })
			nRecVBT := VA3610011_MVC_VBT( 0 , aVBT ) // Incluir VBT que foi marcado
			VA3600141_INSERT_TAB_TEMP("2",nRecVBT) // Incluir na Tabela Temporaria
		EndIf
	Next
	For nCntFor := 1 to len(aRegVO1)
		If aScan(aSlvVO1,{|x| x[1]+x[2] == aRegVO1[nCntFor,1]+aRegVO1[nCntFor,2] }) == 0
			aVBT := {}
			aAdd(aVBT,{ "VBT_TIPORI" , "3" }) // Ordens de Serviço
			aAdd(aVBT,{ "VBT_FILORI" , aRegVO1[nCntFor,1] })
			aAdd(aVBT,{ "VBT_NUMOSV" , aRegVO1[nCntFor,2] })
			aAdd(aVBT,{ "VBT_FILANT" , cFilANT })
			aAdd(aVBT,{ "VBT_NRFANT" , cNRFANT })
			aAdd(aVBT,{ "VBT_SRFANT" , cSRFANT })
			aAdd(aVBT,{ "VBT_CODCLI" , cCodCli })
			aAdd(aVBT,{ "VBT_LOJCLI" , cLojCli })
			nRecVBT := VA3610011_MVC_VBT( 0 , aVBT ) // Incluir VBT que foi marcado
			VA3600141_INSERT_TAB_TEMP("3",nRecVBT) // Incluir na Tabela Temporaria
		EndIf
	Next
EndIf
//
SF2->(DbGoTo(nRecSF2))
VA3600161_F12_FILTRO(.f.,.t.)
//
Return

/*/{Protheus.doc} VA3600041_Nota_Credito
Nota de Crédito

@author Andre Luis Almeida
@since 29/11/2024
/*/
Static Function VA3600041_Nota_Credito()
Local cSlvFName := FunName()
Local nRecSF2   := SF2->(RecNo())
VA3600051_SetKey(.f.)
cCadastro := STR0012 // Cadastro de Notas de Crédito
SetFunName("MATA465N")
MATA465N(,,,,,4)
SetFunName(cSlvFName)
cCadastro := STR0001 // Central de Antecipos
SF2->(DbGoTo(nRecSF2))
VA3600161_F12_FILTRO(.f.,.t.)
Return

/*/{Protheus.doc} VA3600051_SetKey
Limpar SetKey

@author Andre Luis Almeida
@since 06/12/2024
/*/
Static Function VA3600051_SetKey(lSetaF12)
SetKey(VK_F4 , Nil )
SetKey(VK_F5 , Nil )
SetKey(VK_F6 , Nil )
SetKey(VK_F7 , Nil )
SetKey(VK_F8 , Nil )
SetKey(VK_F9 , Nil )
SetKey(VK_F10, Nil )
SetKey(VK_F11, Nil )
If lSetaF12
	SetKey(VK_F12,{ || VA3600161_F12_FILTRO(.t.,.t.) })
Else
	SetKey(VK_F12, Nil )
EndIf
Return

/*/{Protheus.doc} VA3600061_Carregar_Tabelas_Temporarias
Carregar registros nas Tabelas Temporarias

@author Andre Luis Almeida
@since 09/12/2024
/*/
Static Function VA3600061_Carregar_Tabelas_Temporarias()
Local aCpos  := {}
Local aCpos1 := {}
Local aCpos2 := {}
Local aCpos3 := {}
//
ProcRegua(3)
//
aadd(aCpos, {"Z_FILANT","C",TamSX3("VBT_FILANT")[1],0})
aadd(aCpos, {"Z_NRFANT","C",TamSX3("VBT_NRFANT")[1],0})
aadd(aCpos, {"Z_SRFANT","C",TamSX3("VBT_SRFANT")[1],0})
aadd(aCpos, {"Z_CODCLI","C",TamSX3("VBT_CODCLI")[1],0})
aadd(aCpos, {"Z_LOJCLI","C",TamSX3("VBT_LOJCLI")[1],0})
aadd(aCpos, {"Z_FILORI","C",TamSX3("VBT_FILORI")[1],0})
aadd(aCpos, {"Z_RECORI","N",20,0})
aadd(aCpos, {"Z_DATORI","D", 8,0})
aadd(aCpos, {"Z_RECVBT","N",20,0})
//
// VV9 - Atendimento ( VBT_TIPORI = '1' )
IncProc(STR0022) // Levantando Dados
aCpos1 := aclone(aCpos)
aadd(aCpos1, {"Z_NUMATE","C",TamSX3("VBT_NUMATE")[1],0})
oTmpTable1 := OFDMSTempTable():New()
oTmpTable1:cAlias := "TEMP1"
oTmpTable1:aVetCampos := aCpos1
oTmpTable1:AddIndex(, {"Z_FILANT","Z_NRFANT","Z_SRFANT","Z_CODCLI","Z_LOJCLI"} )
oTmpTable1:CreateTable()
VA3600141_INSERT_TAB_TEMP("1",0)
//
// VS1 - Orçamento ( VBT_TIPORI = '2' )
IncProc(STR0022) // Levantando Dados
aCpos2 := aclone(aCpos)
aadd(aCpos2, {"Z_NUMORC","C",TamSX3("VBT_NUMORC")[1],0})
oTmpTable2 := OFDMSTempTable():New()
oTmpTable2:cAlias := "TEMP2"
oTmpTable2:aVetCampos := aCpos2
oTmpTable2:AddIndex(, {"Z_FILANT","Z_NRFANT","Z_SRFANT","Z_CODCLI","Z_LOJCLI"} )
oTmpTable2:CreateTable()
VA3600141_INSERT_TAB_TEMP("2",0)
//
// VO1 - OS ( VBT_TIPORI = '3' )
IncProc(STR0022) // Levantando Dados
aCpos3 := aclone(aCpos)
aadd(aCpos3, {"Z_NUMOSV","C",TamSX3("VBT_NUMOSV")[1],0})
oTmpTable3 := OFDMSTempTable():New()
oTmpTable3:cAlias := "TEMP3"
oTmpTable3:aVetCampos := aCpos3
oTmpTable3:AddIndex(, {"Z_FILANT","Z_NRFANT","Z_SRFANT","Z_CODCLI","Z_LOJCLI"} )
oTmpTable3:CreateTable()
VA3600141_INSERT_TAB_TEMP("3",0)
//
Return

/*/{Protheus.doc} VA3600071_Colunas_Browse
Carrega as colunas dos Browses Temporarios

@author Andre Luis Almeida
@since 10/12/2024
/*/
Static Function VA3600071_Colunas_Browse( cCampo )
Local aColumns := {}
AAdd(aColumns,FWBrwColumn():New())
    aColumns[1]:SetData( &("{|| Z_FILORI }") )
    aColumns[1]:SetTitle(STR0023) // Filial
    aColumns[1]:SetSize(07)
AAdd(aColumns,FWBrwColumn():New())
    aColumns[2]:SetData( &("{|| Z_"+cCampo+" }") )
    aColumns[2]:SetTitle(RetTitle("VBT_"+cCampo))
    aColumns[2]:SetSize(10)
AAdd(aColumns,FWBrwColumn():New())
    aColumns[3]:SetData( &("{|| Z_DATORI }") )
    aColumns[3]:SetTitle(STR0024) // Data
    aColumns[3]:SetSize(10)
Return aColumns

/*/{Protheus.doc} VA3600081_Ver_Origem
Carrega a coluna do Browse Temporario

@author Andre Luis Almeida
@since 10/12/2024
/*/
Static Function VA3600081_Ver_Origem(cTp,nRecNo,lRefresh)
Local nRecSF2 := SF2->(RecNo())
Private lImpCCO := .f. // variavel utiliza dentro do Fiscal do Mercado Internacional - IMPGENER.PRX
Private lImpSFC := .f. // variavel utiliza dentro do Fiscal do Mercado Internacional - IMPGENER.PRX
Private aImpCCO := {}  // variavel utiliza dentro do Fiscal do Mercado Internacional - IMPGENER.PRX
Private aImpSFC := {}  // variavel utiliza dentro do Fiscal do Mercado Internacional - IMPGENER.PRX
Do Case
	Case cTp == "1" // Atendimentos de Veículos/Máquinas
		cCadastro := STR0019 // Atendimentos de Veículos/Máquinas
		DbSelectArea("VV9")
		DBGoTo(nRecNo)
		VEIXX002(NIL,NIL,NIL,2,)
	Case cTp == "2" // Orçamentos
		cCadastro := STR0020 // Orçamentos
		DBSelectArea("VS1")
		DBGoTo(nRecNo)
		OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
	Case cTp == "3" // Ordens de Serviço
		cCadastro := STR0021 // Ordens de Serviço
		nOpc      := 2
		VISUALIZA := .T.
		INCLUI    := .F.
		ALTERA    := .F.
		EXCLUI    := .F.
		DBSelectArea("VO1")
		DBGoTo(nRecNo)
		OFIOC060(.T.)
EndCase
SF2->(DbGoTo(nRecSF2))
If lRefresh
	VA3600091_Refresh(.t.,.t.,.t.,.t.) // (lSF2,lTot,lTMP,lNCC)
EndIf
Return

/*/{Protheus.doc} VA3600091_Refresh
Refresh nos objetos da TELA

@author Andre Luis Almeida
@since 11/12/2024
/*/
Static Function VA3600091_Refresh(lSF2,lTot,lTMP,lNCC)
If lSF2
	oBrwSF2:Refresh()
EndIf
If lTot
	oLbTotais:Refresh()
EndIf
If lTMP
	oBrwTMP1:SetFocus()
	oBrwTMP1:GoBottom()
	oBrwTMP1:GoTop()
	oBrwTMP1:Refresh()
	oBrwTMP2:SetFocus()
	oBrwTMP2:GoBottom()
	oBrwTMP2:GoTop()
	oBrwTMP2:Refresh()
	oBrwTMP3:SetFocus()
	oBrwTMP3:GoBottom()
	oBrwTMP3:GoTop()
	oBrwTMP3:Refresh()
EndIf
If lNCC
	oBrwNCC:Refresh()
EndIf
Return

/*/{Protheus.doc} VA3600101_Coluna_Mark
Coluna do MarkBrowse - TIK

@author Andre Luis Almeida
@since 12/12/2024
/*/
Static Function VA3600101_Coluna_Mark(cTp)
Local cObjRet := 'LBNO'
Do Case 
	Case cTp == "1" // Atendimentos
		If aScan(aRegVV9,{|x| x[1]+x[2] == VV9->VV9_FILIAL+VV9->VV9_NUMATE }) > 0
			cObjRet := 'LBTIK'
		EndIf
	Case cTp == "2" // Orçamentos
		If aScan(aRegVS1,{|x| x[1]+x[2] == VS1->VS1_FILIAL+VS1->VS1_NUMORC }) > 0
			cObjRet := 'LBTIK'
		EndIf
	Case cTp == "3" // Ordens de Serviço
		If aScan(aRegVO1,{|x| x[1]+x[2] == VO1->VO1_FILIAL+VO1->VO1_NUMOSV }) > 0
			cObjRet := 'LBTIK'
		EndIf
EndCase
Return cObjRet

/*/{Protheus.doc} VA3600111_Mark_Registro
Selecionar o MarkBrowse - TIK

@author Andre Luis Almeida
@since 12/12/2024
/*/
Static Function VA3600111_Mark_Registro(cTp)
Do Case 
	Case cTp == "1" // Atendimentos
		If aScan(aRegVV9,{|x| x[1]+x[2] == VV9->VV9_FILIAL+VV9->VV9_NUMATE }) == 0
			aAdd(aRegVV9, { VV9->VV9_FILIAL , VV9->VV9_NUMATE , 0 })
		Else
			aDel(aRegVV9,aScan(aRegVV9,{|x| x[1]+x[2] == VV9->VV9_FILIAL+VV9->VV9_NUMATE }))
			aSize(aRegVV9, Len(aRegVV9) - 1)
		EndIf
	Case cTp == "2" // Orçamentos
		If aScan(aRegVS1,{|x| x[1]+x[2] == VS1->VS1_FILIAL+VS1->VS1_NUMORC }) == 0
			aAdd(aRegVS1, { VS1->VS1_FILIAL , VS1->VS1_NUMORC , 0 })
		Else
			aDel(aRegVS1,aScan(aRegVS1,{|x| x[1]+x[2] == VS1->VS1_FILIAL+VS1->VS1_NUMORC }))
			aSize(aRegVS1, Len(aRegVS1) - 1)
		EndIf
	Case cTp == "3" // Ordens de Serviço
		If aScan(aRegVO1,{|x| x[1]+x[2] == VO1->VO1_FILIAL+VO1->VO1_NUMOSV }) == 0
			aAdd(aRegVO1, { VO1->VO1_FILIAL , VO1->VO1_NUMOSV , 0 })
		Else
			aDel(aRegVO1,aScan(aRegVO1,{|x| x[1]+x[2] == VO1->VO1_FILIAL+VO1->VO1_NUMOSV }))
			aSize(aRegVO1, Len(aRegVO1) - 1)
		EndIf
EndCase
Return

/*/{Protheus.doc} VA3600121_Deletar_Relacionamento
Deletar Relacionamento com Atecipo

@author Andre Luis Almeida
@since 12/12/2024
/*/
Static Function VA3600121_Deletar_Relacionamento(cTp,nRecVBT)
If nRecVBT > 0 .and. MsgYesNo(STR0025,STR0002) // Deseja excluir o relacionamento? / Atenção
	VA3610021_MVC_VBT_DESATIVAR( nRecVBT ) // Excluir VBT que foi DELETADO
	VA3600151_DELETE_TAB_TEMP(cTp,nRecVBT) // Excluir na Tabela Temporiaria
	VA3600091_Refresh(.t.,.f.,.t.,.f.) // (lSF2,lTot,lTMP,lNCC)
	Do Case 
		Case cTp == "1" // Atendimentos
			oBrwTMP1:SetFocus()
		Case cTp == "2" // Orçamentos
			oBrwTMP2:SetFocus()
		Case cTp == "3" // Ordens de Serviço
			oBrwTMP3:SetFocus()
	EndCase
EndIf
Return

/*/{Protheus.doc} VA3600131_Levanta_Relacionamentos
Deletar Relacionamento com Atecipo

@author Andre Luis Almeida
@since 13/12/2024
/*/
Static Function VA3600131_Levanta_Relacionamentos(cFilANT,cNRFANT,cSRFANT,cCodCli,cLojCli)
Local cQAlias := "SQLVBT"
Local cQuery  := ""
//
aRegVV9 := {}
aRegVS1 := {}
aRegVO1 := {}
//
cQuery := "SELECT VBT_TIPORI , VBT_FILORI , VBT_NUMATE , VBT_NUMORC , VBT_NUMOSV , R_E_C_N_O_ AS RECVBT "
cQuery += "  FROM "+RetSQLName("VBT")
cQuery += " WHERE VBT_FILIAL = '"+xFilial("VBT")+"'"
cQuery += "   AND VBT_FILANT = '"+cFilANT+"'"
cQuery += "   AND VBT_NRFANT = '"+cNRFANT+"'"
cQuery += "   AND VBT_SRFANT = '"+cSRFANT+"'"
cQuery += "   AND VBT_CODCLI = '"+cCodCli+"'"
cQuery += "   AND VBT_LOJCLI = '"+cLojCli+"'"
cQuery += "   AND VBT_ATIVO  = '1'" 
cQuery += "   AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
While !(cQAlias)->(Eof())
	Do Case 
		Case (cQAlias)->( VBT_TIPORI ) == "1" // Atendimentos
			aAdd(aRegVV9, { (cQAlias)->( VBT_FILORI ) , (cQAlias)->( VBT_NUMATE ) , (cQAlias)->( RECVBT ) })
		Case (cQAlias)->( VBT_TIPORI ) == "2" // Orçamentos
			aAdd(aRegVS1, { (cQAlias)->( VBT_FILORI ) , (cQAlias)->( VBT_NUMORC ) , (cQAlias)->( RECVBT ) })
		Case (cQAlias)->( VBT_TIPORI ) == "3" // Ordens de Serviço
			aAdd(aRegVO1, { (cQAlias)->( VBT_FILORI ) , (cQAlias)->( VBT_NUMOSV ) , (cQAlias)->( RECVBT ) })
	EndCase
	(cQAlias)->(dbSkip())
EndDo
(cQAlias)->(dbCloseArea())
DbSelectArea("VBT")
//
aSlvVV9 := aClone(aRegVV9) // Vetor SALVA utilizado para saber se foi DESMARCADO o registro VV9
aSlvVS1 := aClone(aRegVS1) // Vetor SALVA utilizado para saber se foi DESMARCADO o registro VS1
aSlvVO1 := aClone(aRegVO1) // Vetor SALVA utilizado para saber se foi DESMARCADO o registro VO1
//
Return

/*/{Protheus.doc} VA3600141_INSERT_TAB_TEMP
INSERT nas TABELAS TEMPORARIAS

@author Andre Luis Almeida
@since 13/12/2024
/*/
Static Function VA3600141_INSERT_TAB_TEMP(cTp,nRecVBT)
Local cQuery    := "INSERT INTO "
Default nRecVBT := 0
Do Case 
	Case cTp == "1" // Atendimentos
		cQuery += oTmpTable1:GetRealName()
		cQuery += " ( Z_FILANT , Z_NRFANT , Z_SRFANT , Z_CODCLI , Z_LOJCLI , Z_FILORI , Z_NUMATE , Z_RECORI , Z_DATORI , Z_RECVBT ) "
		cQuery += "SELECT "
		cQuery += " VBT.VBT_FILANT , VBT.VBT_NRFANT , VBT.VBT_SRFANT , VBT.VBT_CODCLI , VBT.VBT_LOJCLI , VBT.VBT_FILORI , VBT.VBT_NUMATE , VV9.R_E_C_N_O_ , VV9.VV9_DATVIS , VBT.R_E_C_N_O_ "
		cQuery += "  FROM "+ RetSQLName("VBT")+" VBT "
		cQuery += "  JOIN "+ RetSQLName("VV9")+" VV9 "
		cQuery += "    ON VV9.VV9_FILIAL = VBT.VBT_FILORI "
		cQuery += "   AND VV9.VV9_NUMATE = VBT.VBT_NUMATE "
		cQuery += "   AND VV9.D_E_L_E_T_ = ' '"
	Case cTp == "2" // Orçamentos
		cQuery += oTmpTable2:GetRealName()
		cQuery += " ( Z_FILANT , Z_NRFANT , Z_SRFANT , Z_CODCLI , Z_LOJCLI , Z_FILORI , Z_NUMORC , Z_RECORI , Z_DATORI , Z_RECVBT ) "
		cQuery += " SELECT "
		cQuery += " VBT.VBT_FILANT , VBT.VBT_NRFANT , VBT.VBT_SRFANT , VBT.VBT_CODCLI , VBT.VBT_LOJCLI , VBT.VBT_FILORI , VBT.VBT_NUMORC , VS1.R_E_C_N_O_ , VS1.VS1_DATORC , VBT.R_E_C_N_O_ "
		cQuery += "  FROM "+ RetSQLName("VBT")+" VBT "
		cQuery += "  JOIN "+ RetSQLName("VS1")+" VS1 "
		cQuery += "    ON VS1.VS1_FILIAL = VBT.VBT_FILORI "
		cQuery += "   AND VS1.VS1_NUMORC = VBT.VBT_NUMORC "
		cQuery += "   AND VS1.D_E_L_E_T_ = ' '"
	Case cTp == "3" // Ordens de Serviço
		cQuery += oTmpTable3:GetRealName()
		cQuery += " ( Z_FILANT , Z_NRFANT , Z_SRFANT , Z_CODCLI , Z_LOJCLI , Z_FILORI , Z_NUMOSV , Z_RECORI , Z_DATORI , Z_RECVBT ) "
		cQuery += " SELECT "
		cQuery += " VBT.VBT_FILANT , VBT.VBT_NRFANT , VBT.VBT_SRFANT , VBT.VBT_CODCLI , VBT.VBT_LOJCLI , VBT.VBT_FILORI , VBT.VBT_NUMOSV , VO1.R_E_C_N_O_ , VO1.VO1_DATABE , VBT.R_E_C_N_O_ "
		cQuery += "  FROM "+ RetSQLName("VBT")+" VBT "
		cQuery += "  JOIN "+ RetSQLName("VO1")+" VO1 "
		cQuery += "    ON VO1.VO1_FILIAL = VBT.VBT_FILORI "
		cQuery += "   AND VO1.VO1_NUMOSV = VBT.VBT_NUMOSV "
		cQuery += "   AND VO1.D_E_L_E_T_ = ' '"
EndCase
If nRecVBT == 0
	cQuery += " WHERE VBT.VBT_FILIAL = '"+xFilial("VBT")+"'"
	cQuery += "   AND VBT.VBT_TIPORI = '"+cTp+"'"
	cQuery += "   AND VBT.VBT_ATIVO  = '1'"
	cQuery += "   AND VBT.D_E_L_E_T_ = ' '"
Else
	cQuery += " WHERE VBT.R_E_C_N_O_ = "+str(nRecVBT)
EndIf
TcSqlExec(cQuery)
Return

/*/{Protheus.doc} VA3600151_DELETE_TAB_TEMP
DELETE nas TABELAS TEMPORARIAS

@author Andre Luis Almeida
@since 13/12/2024
/*/
Static Function VA3600151_DELETE_TAB_TEMP(cTp,nRecVBT)
Local cQuery := "DELETE FROM "
Do Case 
	Case cTp == "1" // Atendimentos
		cQuery += oTmpTable1:GetRealName()
	Case cTp == "2" // Orçamentos
		cQuery += oTmpTable2:GetRealName()
	Case cTp == "3" // Ordens de Serviço
		cQuery += oTmpTable3:GetRealName()
EndCase
cQuery += " WHERE Z_RECVBT = "+str(nRecVBT)
TCSqlExec(cQuery)
Return

/*/{Protheus.doc} VA3600161_F12_FILTRO
Filtro do SF2 (Browse de Antecipos)

@author Andre Luis Almeida
@since 16/12/2024
/*/
Static Function VA3600161_F12_FILTRO(lMostraPerg,lRefresh)
Local cFiltroSF2 := ""
Local lOk        := .t.
//
VA3600051_SetKey(.f.)
//
If lMostraPerg
	If !Pergunte("VEIA360",.t.)
		lOk := .f.
	EndIf
Else
	Pergunte("VEIA360",.f.)
EndIf
If lOk
	oBrwSF2:DeleteFilter("filtro_F12")
	If Empty(MV_PAR02)
		MV_PAR02 := dDataBase
	EndIf
	cFiltroSF2 := "@ F2_EMISSAO >='" + dtos(MV_PAR01) + "' AND F2_EMISSAO <='" + dtos(MV_PAR02) + "'"
	If !Empty(MV_PAR03)
		cFiltroSF2 += " AND EXISTS ( SELECT SD2.D2_COD FROM "+RetSQLName("SD2")+" SD2 WHERE SD2.D2_FILIAL=F2_FILIAL AND SD2.D2_DOC=F2_DOC AND SD2.D2_CLIENTE=F2_CLIENTE AND SD2.D2_LOJA=F2_LOJA AND SD2.D2_COD='"+MV_PAR03+"' AND SD2.D_E_L_E_T_=' ' )"
	EndIf
	//
	oBrwSF2:AddFilter("F12", cFiltroSF2 ,.t.,.t.,,,,"filtro_F12")
	If lRefresh
		oBrwSF2:ExecuteFilter(.t.)
		VA3600091_Refresh(.t.,.t.,.t.,.t.)
	EndIf
EndIf
//
VA3600051_SetKey(.t.)
//
Return