#Include "PROTHEUS.CH"
#INCLUDE "OFIC300.CH"

/*/{Protheus.doc} OFIC300
Consulta Serviços Especializados - Movimentações de Estoque

@author Andre Luis Almeida
@since 07/11/2022
/*/
Function OFIC300()
//
Local aSize      := FWGetDialogSize( oMainWnd )
Local nLin       := 0
Local nCol       := 0
Local nCntFor    := 0
Local oFilHelp   := DMS_FilialHelper():New()
Local aTipMov    := X3CBOXAVET("VPZ_TIPMOV","1")
Local aPorMov    := X3CBOXAVET("VPZ_PORMOV","1")
Local aOpeMov    := X3CBOXAVET("VPZ_OPEMOV","1")
Local aBotEnch   := {}
//
Private aFiltros := {} // Filtros
Private aVetMov  := {} // Movimentações
Private aTitCol  := OC3000021_TitulosCOLUNAS() // Colunas Browse
Private aFilPerm := oFilHelp:GetAllFilPermis(.f.)
Private cCadastro := STR0001 // Consulta Serviços Especializados - Movimentações de Estoque

If len(aFilPerm) > 1
	aAdd(aFilPerm,"") // Adicionar um registro em branco para trazer todas as Filiais juntas
	aSort(aFilPerm)
EndIf

// Filtros //
aAdd(aFiltros,{2, STR0002 ,cFilAnt,80,aFilPerm,'{ || .t. }','{ || .t. }'}) // 01 - Filial Movimento
aAdd(aFiltros,{2, STR0003 ,"",80,aTipMov,'{ || .t. }','{ || .t. }'}) // 02 - Tipo
aAdd(aFiltros,{2, STR0004 ,"",80,aPorMov,'{ || .t. }','{ || .t. }'}) // 03 - Movimento
aAdd(aFiltros,{2, STR0005 ,"",80,aOpeMov,'{ || OC3000041_VALID( 1 ) }','{ || .t. }'}) // 04 - Operação
aAdd(aFiltros,{1, STR0006 ,dDataBase-day(dDataBase)+1,50,"@D",'{ || .t. }','{ || .t. }',''}) // 05 - Data Inicial
aAdd(aFiltros,{1, STR0007 ,dDataBase,50,"@D",'{ || aFiltros[06,03] >= aFiltros[05,03] }','{ || .t. }',''}) // 06 - Data Final
aAdd(aFiltros,{1, STR0008 ,Space(GetSX3Cache("VRP_CODFOR","X3_TAMANHO")),50,"@!",'{ || .t. }','{ || aFiltros[04,03] == "0" }','FOR'}) // 07 - Fornecedor
aAdd(aFiltros,{1, ""      ,Space(GetSX3Cache("VRP_LOJFOR","X3_TAMANHO")),25,"@!",'{ || .t. }','{ || aFiltros[04,03] == "0" }',''}) // 08 - Loja
aAdd(aFiltros,{1, STR0009 ,Space(GetSX3Cache("VRR_CODCLI","X3_TAMANHO")),50,"@!",'{ || .t. }','{ || aFiltros[04,03] == "1" }','SA1'}) // 09 - Cliente
aAdd(aFiltros,{1, ""      ,Space(GetSX3Cache("VRR_LOJCLI","X3_TAMANHO")),25,"@!",'{ || .t. }','{ || aFiltros[04,03] == "1" }',''}) // 10 - Loja
aAdd(aFiltros,{1, STR0010 ,Space(GetSX3Cache("VPX_SERINT","X3_TAMANHO")),50,"@!",'{ || OC3000041_VALID( 2 ) }','{ || .t. }','VPX'}) // 11 - Cód.Int.Serviço
aAdd(aFiltros,{1, STR0011 ,Space(GetSX3Cache("VPX_CODSER","X3_TAMANHO")),80,"@!",'{ || .t. }','{ || .f. }',''}) // 12 - Código Serviço
aAdd(aFiltros,{1, STR0012 ,Space(GetSX3Cache("VPW_CODGRU","X3_TAMANHO")),50,"@!",'{ || OC3000041_VALID( 3 ) }','{ || Empty(aFiltros[11,03]) }','VPW'}) // 13 - Grupo Serviço
aAdd(aFiltros,{1, STR0013 ,Space(GetSX3Cache("VPV_CODTIP","X3_TAMANHO")),50,"@!",'{ || OC3000041_VALID( 4 ) }','{ || Empty(aFiltros[11,03]) }','VPV'}) // 14 - Tipo Serviço
aAdd(aFiltros,{1, STR0014 ,Space(GetSX3Cache("VRS_NROSER","X3_TAMANHO")),80,"@!",'{ || .t. }','{ || aFiltros[04,03] == "1" }',''}) // 15 - Nro.Serie
aAdd(aFiltros,{1, STR0015 ,Space(GetSX3Cache("VRS_CHASSI","X3_TAMANHO")),80,"@!",'{ || .t. }','{ || aFiltros[04,03] == "1" }','VV1'}) // 16 - Chassi/PIN
aAdd(aFiltros,{1, STR0016 ,cTod(""),50,"@D",'{ || .t. }','{ || aFiltros[04,03] == "1" }',''}) // 17 - Fim Vigência: De
aAdd(aFiltros,{1, STR0017 ,cTod(""),50,"@D",'{ || .t. }','{ || aFiltros[04,03] == "1" }',''}) // 18 - Fim Vigência: Até
aAdd(aFiltros,{1, STR0018 ,Space(GetSX3Cache("VPZ_USRMOV","X3_TAMANHO")),50,"@!",'{ || .t. }','{ || .t. }','USR'}) // 19 - Usuário

SetKey(VK_F4,{ || OC3000051_VerEstoque() })
SetKey(VK_F5,{ || OC3000061_VerMovimento() })
AADD(aBotEnch, {"PRECO" ,{ || OC3000051_VerEstoque() }, "<F4> "+STR0019 } ) // Visualizar Estoque atual do Serviço posicionado
AADD(aBotEnch, {"ANALITIC" ,{ || OC3000061_VerMovimento() }, "<F5> "+STR0020 } ) // Visualizar Movimento posicionado

DEFINE MSDIALOG oDlgOFIC300 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] TITLE STR0001 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta Serviços Especializados - Movimentações de Estoque
oDlgOFIC300:lEscClose := .F.

oScrollFilt := TScrollBox():New( oDlgOFIC300 , 0, 0, (oDlgOFIC300:nClientWidth/2) , 160 , .t. /* lVertical */ , .f. /* lHorizontal */ , .t. /* lBorder */ )
oScrollFilt:Align := CONTROL_ALIGN_LEFT

oTPanGRID := TPanel():New(0,0,"",oDlgOFIC300,NIL,.T.,.F.,NIL,NIL,(oDlgOFIC300:nClientWidth/2)-160,(oDlgOFIC300:nClientHeight)-160,.T.,.F.)
oTPanGRID:Align := CONTROL_ALIGN_LEFT

For nCntFor := 1 to len(aFiltros)
	If !Empty(aFiltros[nCntFor,02])
		nLin += 13
		tSay():New( nLin , 007 , &('{|| aFiltros['+str(nCntFor)+',02] }') , oScrollFilt,,,,,, .T., CLR_BLUE, CLR_WHITE, 080, 020)
		nCol := 57
	EndIf
	Do Case
		Case aFiltros[nCntFor,01] == 1 // Get
			TGet():New( nLin, nCol , &('{|u| If( PCount() > 0, aFiltros['+str(nCntFor)+',03] := u,aFiltros['+str(nCntFor)+',03])}') , oScrollFilt , aFiltros[nCntFor,04] , 008, aFiltros[nCntFor,05] ,&(aFiltros[nCntFor,06]),,,,.F.,,.T.,,.F.,&(aFiltros[nCntFor,07]),.F.,.F.,,.F.,.F. ,aFiltros[nCntFor,08],'aFiltros['+str(nCntFor)+',03]',,,,)
		Case aFiltros[nCntFor,01] == 2 // Combo
			TComboBox():New( nLin , nCol , &('{|u| If( PCount() > 0, aFiltros['+str(nCntFor)+',03] := u,aFiltros['+str(nCntFor)+',03])}') , aFiltros[nCntFor,05] , aFiltros[nCntFor,04] , 08 , oScrollFilt ,, &(aFiltros[nCntFor,06]) ,,,, .T. ,,,, &(aFiltros[nCntFor,07]) ,,,,, 'aFiltros['+str(nCntFor)+',03]' )
	EndCase
	nCol += aFiltros[nCntFor,04]
Next
nLin += 20
oButFil := TButton():New( nLin , 07 , STR0021 ,oScrollFilt,{|| OC3000031_LEVANTA() },130,12,,,.F.,.T.,.F.,,.F.,{ || .t. },,.F. ) // Filtrar

oBrwMSrv := FWBrowse():New()
oBrwMSrv:SetOwner(oTPanGRID)
oBrwMSrv:SetDescription(STR0022) // Movimentações de Estoque
oBrwMSrv:SetProfileID("T")
oBrwMSrv:SetDataArray()
oBrwMSrv:SetColumns(OC3000011_MontaCol(aTitCol))
oBrwMSrv:SetArray(aVetMov)
oBrwMSrv:SetDoubleClick( { || OC3000061_VerMovimento() } ) // <F5>
oBrwMSrv:Activate() // Ativação do Browse
oBrwMSrv:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oBrwMSrv:Refresh()
oBrwMSrv:GoTop()

ACTIVATE MSDIALOG oDlgOFIC300 ON INIT EnchoiceBar(oDlgOFIC300,{ || oDlgOFIC300:End() }, { || oDlgOFIC300:End() },,aBotEnch)

SetKey(VK_F4, nil)
SetKey(VK_F5, nil)

Return()

/*/{Protheus.doc} OC3000011_MontaCol
Adicao das Colunas do Browse

@author Andre Luis Almeida
@since 07/11/2022
/*/
Static Function OC3000011_MontaCol(aHeader)
Local aColunas, oColuna
Local cSetData
Local nHeader := 0
Default aHeader := {}
aColunas := {}
For nHeader := 1 To Len(aHeader)
	// Instancia a Classe
	oColuna := FWBrwColumn():New()
	// Definições Básicas do Objeto
	oColuna:SetAlign(If(aHeader[nHeader][6] == "R", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT))
	oColuna:SetEdit(.F.)
	// Definições do Dado apresentado
	oColuna:SetSize(aHeader[nHeader][3])
	oColuna:SetTitle(aHeader[nHeader][1])
	oColuna:SetType(aHeader[nHeader][2])
	oColuna:SetPicture(aHeader[nHeader][4])
	//
	cSetData := "{|| oBrwMSrv:Data():GetArray()[oBrwMSrv:AT()][" + cValToChar(aHeader[nHeader][5]) + "] }"
	oColuna:SetData(&(cSetData))
	//
	aAdd(aColunas, oColuna)
Next nHeader
Return aColunas

/*/{Protheus.doc} OC3000021_TitulosCOLUNAS
Retorna Titulos/Tipos/Tamanhos/Mascara das Colunas do Browse

@author Andre Luis Almeida
@since 07/11/2022
/*/
Static Function OC3000021_TitulosCOLUNAS()
Local aRetCol := {}
Local nCol    := 0
//
aAdd(aRetCol, {STR0002,"C", 20,""  , ++nCol,"L"}) // 01 - Filial Movimento
aAdd(aRetCol, {STR0003,"C", 10,""  , ++nCol,"L"}) // 02 - Tipo
aAdd(aRetCol, {STR0004,"C", 15,""  , ++nCol,"L"}) // 03 - Movimento
aAdd(aRetCol, {STR0005,"C", 20,""  , ++nCol,"L"}) // 04 - Operação
aAdd(aRetCol, {STR0023,"D", 08,"@D", ++nCol,"L"}) // 05 - Data
aAdd(aRetCol, {STR0024,"N", 05,"@R 99:99", ++nCol,"R"}) // 06 - Hora
aAdd(aRetCol, {STR0025,"C", 15,""  , ++nCol,"L"}) // 07 - NF+Serie / DOC
aAdd(aRetCol, {STR0026,"C", 30,"@!", ++nCol,"L"}) // 08 - Fornecedor / Origem
aAdd(aRetCol, {STR0027,"C", 30,"@!", ++nCol,"L"}) // 09 - Cliente / Destino
aAdd(aRetCol, {STR0011,"C", 10,"@!", ++nCol,"L"}) // 10 - Código Serviço
aAdd(aRetCol, {STR0028,"C", 30,"@!", ++nCol,"L"}) // 11 - Descrição
aAdd(aRetCol, {STR0029,"N", 10,"@E 999,999,999", ++nCol,"R"}) // 12 - Quantidade
aAdd(aRetCol, {STR0012,"C", 05,"@!", ++nCol,"L"}) // 13 - Grupo Serviço
aAdd(aRetCol, {STR0013,"C", 05,"@!", ++nCol,"L"}) // 14 - Tipo Serviço
aAdd(aRetCol, {STR0030,"D", 08,""  , ++nCol,"L"}) // 15 - Inicio Vigência
aAdd(aRetCol, {STR0031,"D", 08,""  , ++nCol,"L"}) // 16 - Fim Vigência
aAdd(aRetCol, {STR0014,"C", 10,"@!", ++nCol,"L"}) // 17 - Nro.Serie
aAdd(aRetCol, {STR0015,"C", 15,"@!", ++nCol,"L"}) // 18 - Chassi/PIN
aAdd(aRetCol, {STR0018,"C", 15,"@!", ++nCol,"L"}) // 19 - Usuário
//
Return aRetCol

/*/{Protheus.doc} OC3000031_LEVANTA
Levanta Dados para incluir registros no Browse 

@author Andre Luis Almeida
@since 07/11/2022
/*/
Static Function OC3000031_LEVANTA()
Local cQuery  := ""
Local cQAlSQL := "SQLVPZ"
Local cQAlAux := "SQLAUX"
Local nCntFor := 0
Local nLinVet := 0
Local nQtdCol := len(aTitCol)
Local aAux    := {}
Local cNamVPZ := RetSQLName("VPZ")
Local cNamVPX := RetSQLName("VPX")
Local cNamVRP := RetSqlName("VRP")
Local cNamSA2 := RetSqlName("SA2")
Local cNamVRR := RetSqlName("VRR")
Local cNamVRS := RetSqlName("VRS")
Local cNamSA1 := RetSqlName("SA1")
Local cNamVRT := RetSqlName("VRT")
Local cDescOM := ""
Local cNFSDoc := ""
Local cFornec := ""
Local cClient := ""
Local cONrSer := ""
Local cOChass := ""
Local dDtVIni := ctod("")
Local dDtVFin := ctod("")
Local lRegOk  := .t.
Local nCol    := 0
//
aVetMov := {}
//
For nCntFor := 1 to nQtdCol
	aAdd(aAux,"")
	If aTitCol[nCntFor,2]=="N"
		aAux[nCntFor] := 0
	ElseIf aTitCol[nCntFor,2]=="D"
		aAux[nCntFor] := ctod("")
	EndIf
Next
For nCntFor := 1 to 5
	aAdd(aAux,"") // Adicionar campos de Controle 20 a 24 - VPZ_FILREL / VPZ_CODREL / VPZ_SERINT / VPZ_OPEMOV / VPZ_CODMOV
Next
//
cQuery := "SELECT VPZ.VPZ_FILMOV , VPZ.VPZ_CODMOV , VPZ.VPZ_TIPMOV , VPZ.VPZ_PORMOV , VPZ.VPZ_OPEMOV , VPZ.VPZ_QTDMOV , "
cQuery += "       VPZ.VPZ_DATMOV , VPZ.VPZ_HORMOV , VPZ.VPZ_USRMOV , VPZ.VPZ_FILREL , VPZ.VPZ_CODREL ,"
cQuery += "       VPZ.VPZ_SERINT , VPX.VPX_CODSER , VPX.VPX_DESSER , VPX.VPX_GRUSER , VPX.VPX_TIPSER  "
cQuery += "  FROM " + cNamVPZ + " VPZ "
cQuery += "  JOIN " + cNamVPX + " VPX "
cQuery += "    ON VPX.VPX_FILIAL = '" + xFilial("VPX") + "'"
cQuery += "   AND VPX.VPX_SERINT = VPZ.VPZ_SERINT "
cQuery += IIf(!Empty(aFiltros[13,03])," AND VPX.VPX_GRUSER = '"+aFiltros[13,03]+"'","")
cQuery += IIf(!Empty(aFiltros[14,03])," AND VPX.VPX_TIPSER = '"+aFiltros[14,03]+"'","")
cQuery += "   AND VPX.D_E_L_E_T_ = ' '"
cQuery += " WHERE VPZ.VPZ_FILIAL = '" + xFilial("VPZ") + "'"
cQuery += IIf(!Empty(aFiltros[02,03])," AND VPZ.VPZ_TIPMOV = '"+aFiltros[02,03]+"'","")
cQuery += IIf(!Empty(aFiltros[03,03])," AND VPZ.VPZ_PORMOV = '"+aFiltros[03,03]+"'","")
cQuery += IIf(!Empty(aFiltros[04,03])," AND VPZ.VPZ_OPEMOV = '"+aFiltros[04,03]+"'","")
cQuery += IIf(!Empty(aFiltros[11,03])," AND VPZ.VPZ_SERINT = '"+aFiltros[11,03]+"'","")
cQuery += IIf(!Empty(aFiltros[01,03])," AND VPZ.VPZ_FILMOV = '"+aFiltros[01,03]+"'","")
cQuery += "   AND VPZ.VPZ_DATMOV >= '" + dtos(aFiltros[05,03]) + "'"
cQuery += "   AND VPZ.VPZ_DATMOV <= '" + dtos(aFiltros[06,03]) + "'"
cQuery += IIf(!Empty(aFiltros[19,03])," AND VPZ.VPZ_USRMOV = '"+aFiltros[19,03]+"'","")
cQuery += "   AND VPZ.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
While !(cQAlSQL)->(Eof())
	cDescOM := X3CBOXDESC("VPZ_OPEMOV",(cQAlSQL)->( VPZ_OPEMOV ))
	cNFSDoc := ""
	cFornec := ""
	cClient := ""
	cONrSer := ""
	cOChass := ""
	dDtVIni := ctod("")
	dDtVFin := ctod("")
	lRegOk  := .t.
	Do Case
		Case (cQAlSQL)->( VPZ_OPEMOV ) == "0" // Compra - VRP/VRQ
			cQuery := "SELECT VRP.VRP_NUMNFI , VRP.VRP_SERNFI , "
			cQuery += "       VRP.VRP_CODFOR , VRP.VRP_LOJFOR , "
			cQuery += "       SA2.A2_NOME "
			cQuery += "  FROM " + cNamVRP+" VRP "
			cQuery += "  JOIN " + cNamSA2+" SA2 "
			cQuery += "    ON SA2.A2_FILIAL  = '" + xFilial("SA2") + "'"
			cQuery += "   AND SA2.A2_COD     = VRP.VRP_CODFOR "
			cQuery += "   AND SA2.A2_LOJA    = VRP.VRP_LOJFOR "
			cQuery += "   AND SA2.D_E_L_E_T_ = ' '"
			cQuery += " WHERE VRP.VRP_FILIAL = '" + (cQAlSQL)->( VPZ_FILREL ) + "'"
			cQuery += "   AND VRP.VRP_CODIGO = '" + (cQAlSQL)->( VPZ_CODREL ) + "'"
			If !Empty(aFiltros[07,03]+aFiltros[08,03])
				cQuery += " AND VRP.VRP_CODFOR='"+aFiltros[07,03]+"' AND VRP.VRP_LOJFOR='"+aFiltros[08,03]+"'"
			EndIf
			cQuery += "   AND VRP.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
			If ( cQAlAux )->(!Eof())
				cNFSDoc := Alltrim(( cQAlAux )->( VRP_NUMNFI ))+" - "+Alltrim(( cQAlAux )->( VRP_SERNFI ))
				cFornec := ( cQAlAux )->( VRP_CODFOR )+"-"+( cQAlAux )->( VRP_LOJFOR )+" "+( cQAlAux )->( A2_NOME )
			Else
				lRegOk := .f.
			EndIf
			( cQAlAux )->( dbCloseArea() )

		Case (cQAlSQL)->( VPZ_OPEMOV ) == "1" // Venda - VRR/VRS
			cQuery := "SELECT VRR.VRR_NUMNFI , VRR.VRR_SERNFI , "
			cQuery += "       VRR.VRR_CODCLI , VRR.VRR_LOJCLI , "
			cQuery += "       SA1.A1_NOME , "
			cQuery += "       VRS.VRS_DTIVIG , VRS.VRS_DTFVIG , "
			cQuery += "       VRS.VRS_NROSER , VRS.VRS_CHASSI   "
			cQuery += "  FROM " + cNamVRR + " VRR "
			cQuery += "  JOIN " + cNamSA1 + " SA1 "
			cQuery += "    ON SA1.A1_FILIAL  = '" + xFilial("SA1") + "'"
			cQuery += "   AND SA1.A1_COD     = VRR.VRR_CODCLI "
			cQuery += "   AND SA1.A1_LOJA    = VRR.VRR_LOJCLI "
			cQuery += "   AND SA1.D_E_L_E_T_ = ' '"
			cQuery += "  JOIN " + cNamVRS + " VRS "
			cQuery += "    ON VRS.VRS_FILIAL = VRR.VRR_FILIAL "
			cQuery += "   AND VRS.VRS_CODVRR = VRR.VRR_CODIGO "
			cQuery += "   AND VRS.VRS_SERINT = '"+(cQAlSQL)->( VPZ_SERINT )+"'"
			If !Empty(aFiltros[17,03]) .or. !Empty(aFiltros[18,03])
				cQuery += "   AND VRS.VRS_DTFVIG >= '"+dtos(aFiltros[17,03])+"' AND VRS.VRS_DTFVIG <= '"+dtos(aFiltros[18,03])+"'"
			EndIf
			cQuery += IIf(!Empty(aFiltros[15,03])," AND VRS.VRS_NROSER = '"+aFiltros[15,03]+"'","")
			cQuery += IIf(!Empty(aFiltros[16,03])," AND VRS.VRS_CHASSI = '"+aFiltros[16,03]+"'","")
			cQuery += "   AND VRS.D_E_L_E_T_ = ' '"
			cQuery += " WHERE VRR.VRR_FILIAL = '" + (cQAlSQL)->( VPZ_FILREL ) + "'"
			cQuery += "   AND VRR.VRR_CODIGO = '" + (cQAlSQL)->( VPZ_CODREL ) + "'"
			If !Empty(aFiltros[09,03]+aFiltros[10,03])
				cQuery += " AND VRR.VRR_CODCLI='"+aFiltros[09,03]+"' AND VRR.VRR_LOJCLI='"+aFiltros[10,03]+"'"
			EndIf
			cQuery += "   AND VRR.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
			If ( cQAlAux )->(!Eof())
				cNFSDoc := Alltrim(( cQAlAux )->( VRR_NUMNFI ))+" - "+Alltrim(( cQAlAux )->( VRR_SERNFI ))
				cClient := ( cQAlAux )->( VRR_CODCLI )+"-"+( cQAlAux )->( VRR_LOJCLI )+" "+( cQAlAux )->( A1_NOME )
				cONrSer := ( cQAlAux )->( VRS_NROSER )
				cOChass := ( cQAlAux )->( VRS_CHASSI )
				dDtVIni := stod(( cQAlAux )->( VRS_DTIVIG ))
				dDtVFin := stod(( cQAlAux )->( VRS_DTFVIG ))
			Else
				lRegOk := .f.
			EndIf
			( cQAlAux )->( dbCloseArea() )

		Case (cQAlSQL)->( VPZ_OPEMOV ) == "2" // Transferência - VRT
			cQuery := "SELECT VRT.VRT_DOCD3O , VRT.VRT_DOCD3D , "
			cQuery += "       VRT.VRT_FILORI , VRT.VRT_FILDES , "
			cQuery += "       VRT.VRT_TIPTRA "
			cQuery += "  FROM " + cNamVRT + " VRT "
			cQuery += " WHERE VRT.VRT_FILIAL = '" + (cQAlSQL)->( VPZ_FILREL ) + "'"
			cQuery += "   AND VRT.VRT_CODIGO = '" + (cQAlSQL)->( VPZ_CODREL ) + "'"
			cQuery += "   AND VRT.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
			If ( cQAlAux )->(!Eof())
				cNFSDoc := ( cQAlAux )->( VRT_DOCD3O )+" - "+( cQAlAux )->( VRT_DOCD3D )
				cFornec := Alltrim(( cQAlAux )->( VRT_FILORI ))+" - "+Alltrim(FWFilialName( , ( cQAlAux )->( VRT_FILORI ) ))
				cClient := Alltrim(( cQAlAux )->( VRT_FILDES ))+" - "+Alltrim(FWFilialName( , ( cQAlAux )->( VRT_FILDES ) ))
				cDescOM += " ( "+IIf(( cQAlAux )->( VRT_TIPTRA )=="0",STR0032,STR0033)+" )" // Manual / Automática
			EndIf
			( cQAlAux )->( dbCloseArea() )

	EndCase

	If lRegOk
		nCol := 0
		nLinVet++
		aAdd(aVetMov,aClone(aAux))
		aVetMov[nLinVet,++nCol] := (cQAlSQL)->( VPZ_FILMOV )+" - "+Alltrim(FWFilialName( , (cQAlSQL)->( VPZ_FILMOV ) ))	// 01
		aVetMov[nLinVet,++nCol] := X3CBOXDESC("VPZ_TIPMOV",(cQAlSQL)->( VPZ_TIPMOV ))									// 02
		aVetMov[nLinVet,++nCol] := X3CBOXDESC("VPZ_PORMOV",(cQAlSQL)->( VPZ_PORMOV ))									// 03
		aVetMov[nLinVet,++nCol] := cDescOM																				// 04
		aVetMov[nLinVet,++nCol] := stod((cQAlSQL)->( VPZ_DATMOV ))														// 05
		aVetMov[nLinVet,++nCol] := (cQAlSQL)->( VPZ_HORMOV )															// 06
		aVetMov[nLinVet,++nCol] := cNFSDoc																				// 07
		aVetMov[nLinVet,++nCol] := cFornec																				// 08
		aVetMov[nLinVet,++nCol] := cClient																				// 09
		aVetMov[nLinVet,++nCol] := (cQAlSQL)->( VPX_CODSER )															// 10
		aVetMov[nLinVet,++nCol] := (cQAlSQL)->( VPX_DESSER )															// 11
		aVetMov[nLinVet,++nCol] := (cQAlSQL)->( VPZ_QTDMOV )															// 12
		aVetMov[nLinVet,++nCol] := (cQAlSQL)->( VPX_GRUSER )															// 13
		aVetMov[nLinVet,++nCol] := (cQAlSQL)->( VPX_TIPSER )															// 14
		aVetMov[nLinVet,++nCol] := dDtVIni																				// 15
		aVetMov[nLinVet,++nCol] := dDtVFin																				// 16
		aVetMov[nLinVet,++nCol] := cONrSer																				// 17
		aVetMov[nLinVet,++nCol] := cOChass																				// 18
		aVetMov[nLinVet,++nCol] := (cQAlSQL)->( VPZ_USRMOV )+" - "+UsrRetName((cQAlSQL)->( VPZ_USRMOV ))				// 19
		aVetMov[nLinVet,++nCol] := (cQAlSQL)->( VPZ_FILREL )															// 20
		aVetMov[nLinVet,++nCol] := (cQAlSQL)->( VPZ_CODREL )															// 21
		aVetMov[nLinVet,++nCol] := (cQAlSQL)->( VPZ_SERINT )															// 22
		aVetMov[nLinVet,++nCol] := (cQAlSQL)->( VPZ_OPEMOV )															// 23
		aVetMov[nLinVet,++nCol] := (cQAlSQL)->( VPZ_CODMOV )															// 24
	EndIf
	(cQAlSQL)->(DbSkip())
Enddo
(cQAlSQL)->(DbCloseArea())
DbSelectArea("VPZ")
//
aSort(aVetMov,,,{|x,y| x[24] < y[24] }) // Ordem Cronologica - VPZ_CODMOV
oBrwMSrv:SetArray(aVetMov)
oBrwMSrv:Refresh()
oBrwMSrv:GoTop()
//
Return

/*/{Protheus.doc} OC3000041_VALID
VALID dos campos no Filtro da Consulta

@author Andre Luis Almeida
@since 07/11/2022
/*/
Static Function OC3000041_VALID( nTp )
Local lRet := .t.
Do Case
	Case nTp == 1 // Valid do OpeMov
		If aFiltros[04,03] <> "1" // Diferente de Venda - apaga Cliente/Loja / Datas Vigencia
			aFiltros[09,03] := Space(GetSX3Cache("VRR_CODCLI","X3_TAMANHO"))
			aFiltros[10,03] := Space(GetSX3Cache("VRR_LOJCLI","X3_TAMANHO"))
			aFiltros[15,03] := Space(GetSX3Cache("VRS_NROSER","X3_TAMANHO"))
			aFiltros[16,03] := Space(GetSX3Cache("VRS_CHASSI","X3_TAMANHO"))
			aFiltros[17,03] := cTod("")
			aFiltros[18,03] := cTod("")
		EndIf
		If aFiltros[04,03] <> "0" // Diferente de Compra - apaga Fornecedor/Loja
			aFiltros[07,03] := Space(GetSX3Cache("VRP_CODFOR","X3_TAMANHO"))
			aFiltros[08,03] := Space(GetSX3Cache("VRP_LOJFOR","X3_TAMANHO"))
		EndIf
	Case nTp == 2 // Valid do Codigo Interno do Serviço
		aFiltros[12,03] := Space(GetSX3Cache("VPX_CODSER","X3_TAMANHO"))
		aFiltros[13,03] := Space(GetSX3Cache("VPX_GRUSER","X3_TAMANHO"))
		aFiltros[14,03] := Space(GetSX3Cache("VPX_TIPSER","X3_TAMANHO"))
		If !Empty(aFiltros[11,03])
			VPX->(DbSetOrder(1)) // VPX_FILIAL+VPX_SERINT
			lRet := VPX->(DbSeek(xFilial("VPX")+aFiltros[11,03]))
			If lRet
				aFiltros[12,03] := VPX->VPX_CODSER
				aFiltros[13,03] := VPX->VPX_GRUSER
				aFiltros[14,03] := VPX->VPX_TIPSER
			EndIf
		EndIf
	Case nTp == 3 // Valid do Grupo do Serviço
		If !Empty(aFiltros[13,03])
			VPW->(DbSetOrder(1)) // VPW_FILIAL+VPW_CODGRU
			lRet := VPW->(DbSeek(xFilial("VPW")+aFiltros[13,03]))
		EndIf
	Case nTp == 4 // Valid do Tipo do Serviço
		If !Empty(aFiltros[14,03])
			VPV->(DbSetOrder(1)) // VPV_FILIAL+VPV_CODTIP
			lRet := VPV->(DbSeek(xFilial("VPV")+aFiltros[14,03]))
		EndIf
EndCase
Return lRet

/*/{Protheus.doc} OC3000051_VerEstoque
Visualizar Estoque do Item posicionado

@author Andre Luis Almeida
@since 09/11/2022
/*/
Static Function OC3000051_VerEstoque()
Local cBkpFil := cFilAnt
Local cFilSD2 := ""
Local nLinha  := oBrwMSrv:AT()
Local cFilRel := IIf(nLinha>0.and.len(aVetMov)>=nLinha,aVetMov[nLinha,20],"") // VPZ_FILREL
Local cSerInt := IIf(nLinha>0.and.len(aVetMov)>=nLinha,aVetMov[nLinha,22],"") // VPZ_SERINT
If !Empty(cSerInt)
	SetKey(VK_F4, nil)
	SetKey(VK_F5, nil)
	cFilAnt := cFilRel
	cFilSD2 := xFilial("SD2")
	DbSelectArea("VPY")
	DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
	If DbSeek( xFilial("VPY") + cSerInt + cFilSD2 ) .or. DbSeek( xFilial("VPY") + cSerInt ) // Pega qualquer Filial
		OFIA451( VPY->VPY_FILIAL , VPY->VPY_CODEST , .f. )
	EndIf
	cFilAnt := cBkpFil
	SetKey(VK_F4,{ || OC3000051_VerEstoque() })
	SetKey(VK_F5,{ || OC3000061_VerMovimento() })
EndIf
Return

/*/{Protheus.doc} OC3000061_VerMovimento
Visualizar Origem do Movimento

@author Andre Luis Almeida
@since 09/11/2022
/*/
Static Function OC3000061_VerMovimento()
Local cBkpFil := cFilAnt
Local nLinha  := oBrwMSrv:AT()
Local cFilRel := IIf(nLinha>0.and.len(aVetMov)>=nLinha,aVetMov[nLinha,20],"") // VPZ_FILREL
Local cCodRel := IIf(nLinha>0.and.len(aVetMov)>=nLinha,aVetMov[nLinha,21],"") // VPZ_CODREL
Local cOpeMov := IIf(nLinha>0.and.len(aVetMov)>=nLinha,aVetMov[nLinha,23],"") // VPZ_OPEMOV
If !Empty(cCodRel)
	SetKey(VK_F4, nil)
	SetKey(VK_F5, nil)
	cFilAnt := cFilRel
	Do Case
		Case cOpeMov == "0" // Compra - VRP/VRQ
			DbSelectArea("VRP")
			DbSetOrder(1)
			If DbSeek( cFilRel + cCodRel )
				OA4600041_VisualizarEntrada()
			EndIf
		Case cOpeMov == "1" // Venda - VRR/VRS
			DbSelectArea("VRR")
			DbSetOrder(1)
			If DbSeek( cFilRel + cCodRel )
				OA4700051_VisualizarSaida()
			EndIf
		Case cOpeMov == "2" // Transferência - VRT
			DbSelectArea("VRT")
			DbSetOrder(1)
			If DbSeek( cFilRel + cCodRel )
				OA4650041_VisualizarTransferencia()
			EndIf
	EndCase
	cFilAnt := cBkpFil
	SetKey(VK_F4,{ || OC3000051_VerEstoque() })
	SetKey(VK_F5,{ || OC3000061_VerMovimento() })
EndIf
Return