#Include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#Include "OFIC002.CH"

/*/{Protheus.doc} OFIC002
Consulta Peças Reservadas - BALCAO / OFICINA

@author Andre Luis Almeida
@since 09/09/2026
@version 1.0
@type function
/*/
Function OFIC002()
Local aSizeAut := MsAdvSize(.f.)
Local aFldC002 := OFC002011_Folders()
Local aColVB2  := OFC002021_ColunasBrowse("VB2") // Balcao
Local aColVB3  := OFC002021_ColunasBrowse("VB3") // Oficina
Local aColFUT  := OFC002021_ColunasBrowse("FUT") // Entrega Futura - BO
Local aIndVB2  := OFC002031_Indices("VB2") // Balcao
Local aIndVB3  := OFC002031_Indices("VB3") // Oficina
Local aIndFUT  := OFC002031_Indices("FUT") // Entrega Futura - BO
Local aSekVB2  := OFC002041_Seeks("VB2") // Balcao
Local aSekVB3  := OFC002041_Seeks("VB3") // Oficina
Local aSekFUT  := OFC002041_Seeks("FUT") // Entrega Futura - BO
Local cBkpFil  := cFilAnt
Private aPAROC002 := { cFilAnt , space(GetSX3Cache("B1_GRUPO","X3_TAMANHO")) , space(GetSX3Cache("B1_CODITE","X3_TAMANHO")) } // Parametros do Filtro
Private oBrwVB2
Private oBrwVB3
Private oBrwFUT

If !GetNewPar("MV_MIL0181",.f.) //Utiliza novo controle de reserva rastreavel?
	MsgStop(STR0018,STR0017) // Consulta disponível apenas para Reserva Rastreável. / Atenção
	Return
EndIf

OFC002091_F12(.t.)

DEFINE MSDIALOG oOFIC002 FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0001 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Consulta Peças Reservadas

oFldOC002 := TFolder():New(1,1,aFldC002,aFldC002,oOFIC002,,,,.T.,.F.,100,100)
oFldOC002:Align:= CONTROL_ALIGN_ALLCLIENT

oBrwVB2 := FWMBrowse():New()
oBrwVB2:SetOwner(oFldOC002:aDialogs[1])
oBrwVB2:SetDataQuery(.T.)
oBrwVB2:SetAlias("SQLVB2")
oBrwVB2:SetQueryIndex(aIndVB2)
oBrwVB2:SetQuery( OFC002051_Query("VB2") )
oBrwVB2:SetSeek(,aSekVB2)
oBrwVB2:DisableLocate()
oBrwVB2:SetColumns(aColVB2)
oBrwVB2:DisableDetails()
oBrwVB2:SetAmbiente(.F.)
oBrwVB2:SetWalkthru(.F.)
oBrwVB2:ForceQuitButton(.T.)
oBrwVB2:AddButton( STR0005 ,{|| OFC002071_VisualizaOrcamento( SQLVB2->VB2FILORC , SQLVB2->VB2NUMORC ) },,2) // Visualizar Orçamento/Pedido
oBrwVB2:SetDescription(STR0002) // Reservas - Peças Balcão
oBrwVB2:SetMenuDef("")
oBrwVB2:SetInsert(.f.)
oBrwVB2:SetUseFilter(.f.)
oBrwVB2:Activate()

oBrwVB3 := FWMBrowse():New()
oBrwVB3:SetOwner(oFldOC002:aDialogs[2])
oBrwVB3:SetDataQuery(.T.)
oBrwVB3:SetAlias("SQLVB3")
oBrwVB3:SetQueryIndex(aIndVB3)
oBrwVB3:SetQuery( OFC002051_Query("VB3") )
oBrwVB3:SetSeek(,aSekVB3)
oBrwVB3:DisableLocate()
oBrwVB3:SetColumns(aColVB3)
oBrwVB3:DisableDetails()
oBrwVB3:SetAmbiente(.F.)
oBrwVB3:SetWalkthru(.F.)
oBrwVB3:ForceQuitButton(.T.)
oBrwVB3:AddButton( STR0006 ,{|| OFC002081_VisualizaOS( SQLVB3->VB3FILOSV , SQLVB3->VB3NUMOSV ) },,2) // Visualizar Ordem de Serviço
oBrwVB3:SetDescription(STR0003) // Reservas - Peças Oficina
oBrwVB3:SetMenuDef("")
oBrwVB3:SetInsert(.f.)
oBrwVB3:SetUseFilter(.f.)
oBrwVB3:Activate()

If cPaisLoc == "ARG"
	oBrwFUT := FWMBrowse():New()
	oBrwFUT:SetOwner(oFldOC002:aDialogs[3])
	oBrwFUT:SetDataQuery(.T.)
	oBrwFUT:SetAlias("SQLFUT")
	oBrwFUT:SetQueryIndex(aIndFUT)
	oBrwFUT:SetQuery( OFC002051_Query("FUT") )
	oBrwFUT:SetSeek(,aSekFUT)
	oBrwFUT:DisableLocate()
	oBrwFUT:SetColumns(aColFUT)
	oBrwFUT:DisableDetails()
	oBrwFUT:SetAmbiente(.F.)
	oBrwFUT:SetWalkthru(.F.)
	oBrwFUT:ForceQuitButton(.T.)
	oBrwFUT:AddButton( STR0007 ,{|| OFC002071_VisualizaOrcamento( SQLFUT->VS1FILIAL , SQLFUT->VS1NUMORC ) },,2) // Visualizar Orçamento
	oBrwFUT:SetDescription(STR0004) // Reservas - Entrega Futura
	oBrwFUT:SetMenuDef("")
	oBrwFUT:SetInsert(.f.)
	oBrwFUT:SetUseFilter(.f.)
	oBrwFUT:Activate()
EndIf

ACTIVATE MSDIALOG oOFIC002 // ON INIT EnchoiceBar(oOFIC002,{ || oOFIC002:End() }, { || oOFIC002:End() },,aBotEnch) 

cFilAnt := cBkpFil

OFC002091_F12(.f.)

Return

/*/{Protheus.doc} OFC002011_Folders
Monta Folders da Consulta

@author Andre Luis Almeida
@since 10/09/2026
/*/
Static Function OFC002011_Folders()
Local aRetFold := {}
AAdd( aRetFold, STR0002 ) // Reservas - Peças Balcão
AAdd( aRetFold, STR0003 ) // Reservas - Peças Oficina
If cPaisLoc == "ARG"
	AAdd( aRetFold, STR0004 ) // Reservas - Entrega Futura
EndIf
Return aClone(aRetFold)

/*/{Protheus.doc} OFC002021_ColunasBrowse
Monta Colunas dos Browses da Consulta

@author Andre Luis Almeida
@since 10/09/2026
/*/
Static Function OFC002021_ColunasBrowse(cTab)
Local aRetCol := {}
Do Case 
	Case cTab == "VB2" // Balcao
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[1]:SetData( &("{|| VB2GRUITE }") ) 
			aRetCol[1]:SetTitle(RetTitle("VB2_GRUITE"))
			aRetCol[1]:SetSize(5)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[2]:SetData( &("{|| VB2CODITE }") ) 
			aRetCol[2]:SetTitle(RetTitle("VB2_CODITE"))
			aRetCol[2]:SetSize(15)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[3]:SetData( &("{|| B1DESC }") ) 
			aRetCol[3]:SetTitle(RetTitle("B1_DESC"))
			aRetCol[3]:SetSize(20)
		AAdd(aRetCol,FWBrwColumn():New())
    		aRetCol[4]:SetData( &('{|| Transform(VB2QUANT,GetSX3Cache("VB2_QUANT","X3_PICTURE")) }'))
			aRetCol[4]:SetTitle(RetTitle("VB2_QUANT"))
			aRetCol[4]:SetSize(10)
			aRetCol[4]:SetAlign(2) // Direita
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[5]:SetData( &("{|| Stod(VB2DATMOV) }") ) 
			aRetCol[5]:SetTitle(RetTitle("VB2_DATMOV"))
			aRetCol[5]:SetSize(8)
			aRetCol[5]:SetAlign(0) // Centralizado
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[6]:SetData( &("{|| OFC002061_Tipo('B',VS1TIPORC) }") ) 
			aRetCol[6]:SetTitle(RetTitle("VS1_TIPORC"))
			aRetCol[6]:SetSize(10)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[7]:SetData( &("{|| VB2FILORC }") ) 
			aRetCol[7]:SetTitle(RetTitle("VB2_FILORC"))
			aRetCol[7]:SetSize(8)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[8]:SetData( &("{|| VB2NUMORC }") ) 
			aRetCol[8]:SetTitle(RetTitle("VB2_NUMORC"))
			aRetCol[8]:SetSize(8)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[9]:SetData( &("{|| Stod(VS1DATORC) }") ) 
			aRetCol[9]:SetTitle(RetTitle("VS1_DATORC"))
			aRetCol[9]:SetSize(8)
			aRetCol[9]:SetAlign(0) // Centralizado
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[10]:SetData( &("{|| Stod(VS1DATVAL) }") ) 
			aRetCol[10]:SetTitle(RetTitle("VS1_DATVAL"))
			aRetCol[10]:SetSize(8)
			aRetCol[10]:SetAlign(0) // Centralizado
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[11]:SetData( &("{|| VS1CODVEN }") ) 
			aRetCol[11]:SetTitle(RetTitle("VS1_CODVEN"))
			aRetCol[11]:SetSize(7)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[12]:SetData( &("{|| A3NOME }") ) 
			aRetCol[12]:SetTitle(RetTitle("A3_NOME"))
			aRetCol[12]:SetSize(12)
	Case cTab == "VB3" // Oficina
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[1]:SetData( &("{|| VB3GRUITE }") ) 
			aRetCol[1]:SetTitle(RetTitle("VB3_GRUITE"))
			aRetCol[1]:SetSize(5)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[2]:SetData( &("{|| VB3CODITE }") ) 
			aRetCol[2]:SetTitle(RetTitle("VB3_CODITE"))
			aRetCol[2]:SetSize(15)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[3]:SetData( &("{|| B1DESC }") ) 
			aRetCol[3]:SetTitle(RetTitle("B1_DESC"))
			aRetCol[3]:SetSize(20)
		AAdd(aRetCol,FWBrwColumn():New())
    		aRetCol[4]:SetData( &('{|| Transform(VB3QUANT,GetSX3Cache("VB3_QUANT","X3_PICTURE")) }'))
			aRetCol[4]:SetTitle(RetTitle("VB3_QUANT"))
			aRetCol[4]:SetSize(10)
			aRetCol[4]:SetAlign(2) // Direita
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[5]:SetData( &("{|| Stod(VB3DATMOV) }") ) 
			aRetCol[5]:SetTitle(RetTitle("VB3_DATMOV"))
			aRetCol[5]:SetSize(8)
			aRetCol[5]:SetAlign(0) // Centralizado
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[6]:SetData( &("{|| OFC002061_Tipo('O',VO1TIPOSV) }") ) 
			aRetCol[6]:SetTitle(STR0008) // Tipo
			aRetCol[6]:SetSize(15)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[7]:SetData( &("{|| VB3FILOSV }") ) 
			aRetCol[7]:SetTitle(RetTitle("VB3_FILOSV"))
			aRetCol[7]:SetSize(8)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[8]:SetData( &("{|| VB3NUMOSV }") ) 
			aRetCol[8]:SetTitle(RetTitle("VB3_NUMOSV"))
			aRetCol[8]:SetSize(8)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[9]:SetData( &("{|| Stod(VO1DATABE) }") ) 
			aRetCol[9]:SetTitle(RetTitle("VO1_DATABE"))
			aRetCol[9]:SetSize(8)
			aRetCol[9]:SetAlign(0) // Centralizado
	Case cTab == "FUT" .and. cPaisLoc == "ARG" // Entrega Futura - BO
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[1]:SetData( &("{|| B1GRUPO }") ) 
			aRetCol[1]:SetTitle(RetTitle("B1_GRUPO"))
			aRetCol[1]:SetSize(5)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[2]:SetData( &("{|| B1CODITE }") ) 
			aRetCol[2]:SetTitle(RetTitle("B1_CODITE"))
			aRetCol[2]:SetSize(15)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[3]:SetData( &("{|| B1DESC }") ) 
			aRetCol[3]:SetTitle(RetTitle("B1_DESC"))
			aRetCol[3]:SetSize(20)
		AAdd(aRetCol,FWBrwColumn():New())
    		aRetCol[4]:SetData( &('{|| Transform(C6QUANT,GetSX3Cache("VB2_QUANT","X3_PICTURE")) }'))
			aRetCol[4]:SetTitle(RetTitle("VB2_QUANT"))
			aRetCol[4]:SetSize(10)
			aRetCol[4]:SetAlign(2) // Direita
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[5]:SetData( &("{|| Stod(C5EMISSAO) }") ) 
			aRetCol[5]:SetTitle(RetTitle("VB2_DATMOV"))
			aRetCol[5]:SetSize(8)
			aRetCol[5]:SetAlign(0) // Centralizado
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[6]:SetData( &("{|| VS1FILIAL }") ) 
			aRetCol[6]:SetTitle(RetTitle("VS1_FILIAL"))
			aRetCol[6]:SetSize(8)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[7]:SetData( &("{|| VS1NUMORC }") ) 
			aRetCol[7]:SetTitle(RetTitle("VS1_NUMORC"))
			aRetCol[7]:SetSize(8)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[8]:SetData( &("{|| Stod(VS1DATORC) }") ) 
			aRetCol[8]:SetTitle(RetTitle("VS1_DATORC"))
			aRetCol[8]:SetSize(8)
			aRetCol[8]:SetAlign(0) // Centralizado
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[9]:SetData( &("{|| VS1CODVEN }") ) 
			aRetCol[9]:SetTitle(RetTitle("VS1_CODVEN"))
			aRetCol[9]:SetSize(7)
		AAdd(aRetCol,FWBrwColumn():New())
			aRetCol[10]:SetData( &("{|| A3NOME }") ) 
			aRetCol[10]:SetTitle(RetTitle("A3_NOME"))
			aRetCol[10]:SetSize(12)
EndCase
Return aClone(aRetCol)

/*/{Protheus.doc} OFC002031_Indices
Monta Indices dos Browses da Consulta

@author Andre Luis Almeida
@since 10/09/2026
/*/
Static Function OFC002031_Indices(cTab)
Local aRetInd := {}
Do Case 
	Case cTab == "VB2" // Balcao
		Aadd( aRetInd, "VB2GRUITE+VB2CODITE+VB2DATMOV+VB2FILORC+VB2NUMORC")
		Aadd( aRetInd, "VB2FILORC+VB2NUMORC+VB2GRUITE+VB2CODITE+VB2DATMOV")
		Aadd( aRetInd, "VS1TIPORC+VB2FILORC+VB2NUMORC+VB2GRUITE+VB2CODITE+VB2DATMOV")
		Aadd( aRetInd, "VB2DATMOV+VB2GRUITE+VB2CODITE+VB2FILORC+VB2NUMORC")
		Aadd( aRetInd, "VS1DATORC+VB2FILORC+VB2NUMORC+VB2GRUITE+VB2CODITE+VB2DATMOV")
		Aadd( aRetInd, "VS1DATVAL+VB2FILORC+VB2NUMORC+VB2GRUITE+VB2CODITE+VB2DATMOV")
		Aadd( aRetInd, "VS1CODVEN+VB2FILORC+VB2NUMORC+VB2GRUITE+VB2CODITE+VB2DATMOV")
	Case cTab == "VB3" // Oficina
		Aadd( aRetInd, "VB3GRUITE+VB3CODITE+VB3DATMOV+VB3FILOSV+VB3NUMOSV")
		Aadd( aRetInd, "VB3FILOSV+VB3NUMOSV+VB3GRUITE+VB3CODITE+VB3DATMOV")
		Aadd( aRetInd, "VO1TIPOSV+VB3FILOSV+VB3NUMOSV+VB3GRUITE+VB3CODITE+VB3DATMOV")
		Aadd( aRetInd, "VB3DATMOV+VB3GRUITE+VB3CODITE+VB3FILOSV+VB3NUMOSV")
		Aadd( aRetInd, "VO1DATABE+VB3FILOSV+VB3NUMOSV+VB3GRUITE+VB3CODITE+VB3DATMOV")
	Case cTab == "FUT" .and. cPaisLoc == "ARG" // Entrega Futura - BO
		Aadd( aRetInd, "B1GRUPO+B1CODITE+C5EMISSAO+VS1FILIAL+VS1NUMORC")
		Aadd( aRetInd, "VS1FILIAL+VS1NUMORC+B1GRUPO+B1CODITE+C5EMISSAO")
		Aadd( aRetInd, "C5EMISSAO+B1GRUPO+B1CODITE+VS1FILIAL+VS1NUMORC")
		Aadd( aRetInd, "VS1DATORC+VS1FILIAL+VS1NUMORC+B1GRUPO+B1CODITE+C5EMISSAO")
		Aadd( aRetInd, "VS1CODVEN+VS1FILIAL+VS1NUMORC+B1GRUPO+B1CODITE+C5EMISSAO")
EndCase
Return aClone(aRetInd)

/*/{Protheus.doc} OFC002041_Seeks
Monta Pesquisas dos Browses da Consulta

@author Andre Luis Almeida
@since 10/09/2026
/*/
Static Function OFC002041_Seeks(cTab)
Local aRetSeek := {}
Do Case 
	Case cTab == "VB2" // Balcao
		Aadd( aRetSeek, { Alltrim(RetTitle("VB2_GRUITE")) + "+" + RetTitle("VB2_CODITE") , {{"","C",TamSX3("VB2_GRUITE")[1],0, RetTitle("VB2_GRUITE"),,},{"","C",TamSX3("VB2_CODITE")[1],0, RetTitle("VB2_CODITE"),,}}})
		Aadd( aRetSeek, { Alltrim(RetTitle("VB2_FILORC")) + "+" + RetTitle("VB2_NUMORC") , {{"","C",TamSX3("VB2_FILORC")[1],0, RetTitle("VB2_FILORC"),,},{"","C",TamSX3("VB2_NUMORC")[1],0, RetTitle("VB2_NUMORC"),,}}})
		Aadd( aRetSeek, { Alltrim(RetTitle("VS1_TIPORC"))                                , {{"","C",TamSX3("VS1_TIPORC")[1],0, RetTitle("VS1_TIPORC"),,}                                                             }})
		Aadd( aRetSeek, { Alltrim(RetTitle("VB2_DATMOV"))                                , {{"","C",TamSX3("VB2_DATMOV")[1],0, RetTitle("VB2_DATMOV"),,}                                                             }})
		Aadd( aRetSeek, { Alltrim(RetTitle("VS1_DATORC"))                                , {{"","C",TamSX3("VS1_DATORC")[1],0, RetTitle("VS1_DATORC"),,}                                                             }})
		Aadd( aRetSeek, { Alltrim(RetTitle("VS1_DATVAL"))                                , {{"","C",TamSX3("VS1_DATVAL")[1],0, RetTitle("VS1_DATVAL"),,}                                                             }})
		Aadd( aRetSeek, { Alltrim(RetTitle("VS1_CODVEN"))                                , {{"","C",TamSX3("VS1_CODVEN")[1],0, RetTitle("VS1_CODVEN"),,}                                                             }})
	Case cTab == "VB3" // Oficina
		Aadd( aRetSeek, { Alltrim(RetTitle("VB3_GRUITE")) + "+" + RetTitle("VB3_CODITE") , {{"","C",TamSX3("VB3_GRUITE")[1],0, RetTitle("VB3_GRUITE"),,},{"","C",TamSX3("VB3_CODITE")[1],0, RetTitle("VB3_CODITE"),,}}})
		Aadd( aRetSeek, { Alltrim(RetTitle("VB3_FILOSV")) + "+" + RetTitle("VB3_NUMOSV") , {{"","C",TamSX3("VB3_FILOSV")[1],0, RetTitle("VB3_FILOSV"),,},{"","C",TamSX3("VB3_NUMOSV")[1],0, RetTitle("VB3_NUMOSV"),,}}})
		Aadd( aRetSeek, { STR0008				                                         , {{"","C",1                      ,0, STR0008               ,,}                                                             }}) // Tipo
		Aadd( aRetSeek, { Alltrim(RetTitle("VB3_DATMOV"))                                , {{"","C",TamSX3("VB3_DATMOV")[1],0, RetTitle("VB3_DATMOV"),,}                                                             }})
		Aadd( aRetSeek, { Alltrim(RetTitle("VO1_DATABE"))                                , {{"","C",TamSX3("VO1_DATABE")[1],0, RetTitle("VO1_DATABE"),,}                                                             }})
	Case cTab == "FUT" .and. cPaisLoc == "ARG" // Entrega Futura - BO
		Aadd( aRetSeek, { Alltrim(RetTitle("B1_GRUPO"))   + "+" + RetTitle("B1_CODITE")  , {{"","C",TamSX3("B1_GRUPO")[1]  ,0, RetTitle("B1_GRUPO")  ,,},{"","C",TamSX3("B1_CODITE")[1] ,0, RetTitle("B1_CODITE") ,,}}})
		Aadd( aRetSeek, { Alltrim(RetTitle("VS1_FILIAL")) + "+" + RetTitle("VS1_NUMORC") , {{"","C",TamSX3("VS1_FILIAL")[1],0, RetTitle("VS1_FILIAL"),,},{"","C",TamSX3("VS1_NUMORC")[1],0, RetTitle("VS1_NUMORC"),,}}})
		Aadd( aRetSeek, { Alltrim(RetTitle("VB2_DATMOV"))                                , {{"","C",TamSX3("VB2_DATMOV")[1],0, RetTitle("VB2_DATMOV"),,}                                                             }})
		Aadd( aRetSeek, { Alltrim(RetTitle("VS1_DATORC"))                                , {{"","C",TamSX3("VS1_DATORC")[1],0, RetTitle("VS1_DATORC"),,}                                                             }})
		Aadd( aRetSeek, { Alltrim(RetTitle("VS1_CODVEN"))                                , {{"","C",TamSX3("VS1_CODVEN")[1],0, RetTitle("VS1_CODVEN"),,}                                                             }})
EndCase
Return aClone(aRetSeek)

/*/{Protheus.doc} OFC002051_Query
Monta Querys dos Browses da Consulta

@author Andre Luis Almeida
@since 10/09/2026
/*/
Static Function OFC002051_Query(cTab)
Local cRetSQL := ""
Do Case 
	Case cTab == "VB2" // Balcao
		cRetSQL += "SELECT * FROM ( "
		cRetSQL += "   SELECT VB2.VB2_GRUITE AS VB2GRUITE , "
		cRetSQL += "          VB2.VB2_CODITE AS VB2CODITE , "
		cRetSQL += "          SB1.B1_DESC AS B1DESC , "
		cRetSQL += "          SUM( CASE WHEN VB2.VB2_TIPREQ <> ' ' THEN VB2.VB2_QUANT ELSE VB2.VB2_QUANT * -1 END ) AS VB2QUANT , "
		cRetSQL += "          MIN(VB2.VB2_DATMOV) AS VB2DATMOV , "
		cRetSQL += "          VS1.VS1_TIPORC AS VS1TIPORC , "
		cRetSQL += "          VB2.VB2_FILORC AS VB2FILORC , "
		cRetSQL += "          VB2.VB2_NUMORC AS VB2NUMORC , "
		cRetSQL += "          VS1.VS1_DATORC AS VS1DATORC , "
		cRetSQL += "          VS1.VS1_DATVAL AS VS1DATVAL , "
		cRetSQL += "          VS1.VS1_CODVEN AS VS1CODVEN , "
		cRetSQL += "          SA3.A3_NOME AS A3NOME "
		cRetSQL += "   FROM " + RetSQLName("VB2") + " VB2 "
		cRetSQL += "   JOIN " + RetSQLName("SB1") + " SB1 "
		cRetSQL += "     ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
		cRetSQL += "    AND SB1.B1_GRUPO = VB2.VB2_GRUITE "
		cRetSQL += "    AND SB1.B1_CODITE = VB2.VB2_CODITE "
		cRetSQL += "    AND SB1.D_E_L_E_T_ = ' ' "
		cRetSQL += "   JOIN " + RetSQLName("VS1") + " VS1 "
		cRetSQL += "     ON VS1.VS1_FILIAL = VB2.VB2_FILORC "
		cRetSQL += "    AND VS1.VS1_NUMORC = VB2.VB2_NUMORC "
		cRetSQL += "    AND ( (  VS1.VS1_TIPORC = 'P' AND VS1.VS1_PEDSTA NOT IN ('2','3') ) OR "
		cRetSQL += "          ( VS1.VS1_TIPORC IN ('1','2','3') AND VS1.VS1_STATUS NOT IN ('X','C') ) ) "
		cRetSQL += "    AND VS1.D_E_L_E_T_ = ' ' "
		cRetSQL += "   LEFT JOIN " + RetSQLName("SA3") + " SA3 "
		cRetSQL += "     ON SA3.A3_FILIAL = '"+xFilial("SA3")+"'"
		cRetSQL += "    AND SA3.A3_COD = VS1.VS1_CODVEN "
		cRetSQL += "    AND SA3.D_E_L_E_T_ = ' ' "
		cRetSQL += "  WHERE VB2.VB2_FILIAL = '"+xFilial("VB2")+"' "
		If !Empty(aPAROC002[2])
			cRetSQL += " AND VB2.VB2_GRUITE = '"+aPAROC002[2]+"'"
		EndIf
		If !Empty(aPAROC002[3])
			cRetSQL += " AND VB2.VB2_CODITE = '"+aPAROC002[3]+"'"
		EndIf
		cRetSQL += "    AND VB2.D_E_L_E_T_ = ' ' "
		cRetSQL += "  GROUP BY VB2.VB2_GRUITE , "
		cRetSQL += "           VB2.VB2_CODITE , "
		cRetSQL += "           SB1.B1_DESC , "
		cRetSQL += "           VS1.VS1_TIPORC , "
		cRetSQL += "           VB2.VB2_FILORC , "
		cRetSQL += "           VB2.VB2_NUMORC , "
		cRetSQL += "           VS1.VS1_DATORC , "
		cRetSQL += "           VS1.VS1_DATVAL , "
		cRetSQL += "           VS1.VS1_CODVEN , "
		cRetSQL += "           SA3.A3_NOME "
		cRetSQL += ") TEMP "
		cRetSQL += "WHERE TEMP.VB2QUANT > 0 "
		cRetSQL += "ORDER BY TEMP.VB2GRUITE , TEMP.VB2CODITE , TEMP.VB2DATMOV "
	Case cTab == "VB3" // Oficina
		cRetSQL += "SELECT * FROM ( "
		cRetSQL += "   SELECT VB3.VB3_GRUITE AS VB3GRUITE , "
		cRetSQL += "          VB3.VB3_CODITE AS VB3CODITE , "
		cRetSQL += "          SB1.B1_DESC AS B1DESC , "
		cRetSQL += "          SUM( CASE WHEN VB3.VB3_TIPREQ <> ' ' THEN VB3.VB3_QUANT ELSE VB3.VB3_QUANT * -1 END ) AS VB3QUANT , "
		cRetSQL += "          MIN(VB3.VB3_DATMOV) AS VB3DATMOV , "
		cRetSQL += "          '1' AS VO1TIPOSV , "
		cRetSQL += "          VB3.VB3_FILOSV AS VB3FILOSV , "
		cRetSQL += "          VB3.VB3_NUMOSV AS VB3NUMOSV , "
		cRetSQL += "          VO1.VO1_DATABE AS VO1DATABE "
		cRetSQL += "   FROM " + RetSQLName("VB3") + " VB3 "
		cRetSQL += "   JOIN " + RetSQLName("SB1") + " SB1 "
		cRetSQL += "     ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
		cRetSQL += "    AND SB1.B1_GRUPO = VB3.VB3_GRUITE "
		cRetSQL += "    AND SB1.B1_CODITE = VB3.VB3_CODITE "
		cRetSQL += "    AND SB1.D_E_L_E_T_ = ' ' "
		cRetSQL += "   JOIN " + RetSQLName("VO1") + " VO1 "
		cRetSQL += "     ON VO1.VO1_FILIAL = VB3.VB3_FILOSV "
		cRetSQL += "    AND VO1.VO1_NUMOSV = VB3.VB3_NUMOSV "
		cRetSQL += "    AND VO1.VO1_STATUS NOT IN ('C','F') "
		cRetSQL += "    AND VO1.D_E_L_E_T_ = ' ' "
		cRetSQL += "  WHERE VB3.VB3_FILIAL = '"+xFilial("VB3")+"' "
		If !Empty(aPAROC002[2])
			cRetSQL += " AND VB3.VB3_GRUITE = '"+aPAROC002[2]+"'"
		EndIf
		If !Empty(aPAROC002[3])
			cRetSQL += " AND VB3.VB3_CODITE = '"+aPAROC002[3]+"'"
		EndIf
		cRetSQL += "    AND VB3.D_E_L_E_T_ = ' ' "
		cRetSQL += "  GROUP BY VB3.VB3_GRUITE , "
		cRetSQL += "           VB3.VB3_CODITE , "
		cRetSQL += "           SB1.B1_DESC , "
		cRetSQL += "           VB3.VB3_FILOSV , "
		cRetSQL += "           VB3.VB3_NUMOSV , "
		cRetSQL += "           VO1.VO1_DATABE "
		cRetSQL += " UNION "
		cRetSQL += "   SELECT VO3.VO3_GRUITE AS VB3GRUITE , "
		cRetSQL += "          VO3.VO3_CODITE AS VB3CODITE , "
		cRetSQL += "          SB1.B1_DESC AS B1DESC , "
		cRetSQL += "          SUM(CASE VO2.VO2_DEVOLU WHEN '1' THEN VO3.VO3_QTDREQ ELSE VO3.VO3_QTDREQ * -1 END) AS VB3QUANT , "
		cRetSQL += "          MIN(VO2.VO2_DATREQ) AS VB3DATMOV , "
		cRetSQL += "          'R' AS VO1TIPOSV , "
		cRetSQL += "          VO1.VO1_FILIAL AS VB3FILOSV , "
		cRetSQL += "          VO1.VO1_NUMOSV AS VB3NUMOSV , "
		cRetSQL += "          VO1.VO1_DATABE AS VO1DATABE "
		cRetSQL += "   FROM " + RetSQLName("VO3") + " VO3 "
		cRetSQL += "   JOIN " + RetSQLName("SB1") + " SB1 "
		cRetSQL += "     ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
		cRetSQL += "    AND SB1.B1_GRUPO = VO3.VO3_GRUITE "
   		cRetSQL += "    AND SB1.B1_CODITE = VO3.VO3_CODITE "
		cRetSQL += "    AND SB1.D_E_L_E_T_ = ' ' "
		cRetSQL += "   JOIN " + RetSQLName("VO1") + " VO1 "
		cRetSQL += "     ON VO1.VO1_FILIAL = VO3.VO3_FILIAL "
		cRetSQL += "    AND VO1.VO1_NUMOSV = VO3.VO3_NUMOSV "
		cRetSQL += "    AND VO1.VO1_STATUS NOT IN ('C','F') "
		cRetSQL += "    AND VO1.D_E_L_E_T_ = ' ' "
		cRetSQL += "   JOIN " + RetSQLName("VO2") + " VO2 "
		cRetSQL += "     ON VO2.VO2_FILIAL = VO3.VO3_FILIAL "
		cRetSQL += "    AND VO2.VO2_NUMOSV = VO3.VO3_NUMOSV "
		cRetSQL += "    AND VO2.VO2_NOSNUM = VO3.VO3_NOSNUM "
		cRetSQL += "    AND VO2.VO2_TIPREQ = 'P' "
		cRetSQL += "    AND VO2.D_E_L_E_T_ = ' ' "
		cRetSQL += "   JOIN " + RetSQLName("SF4") + " SF4 "
		cRetSQL += "     ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
		cRetSQL += "    AND SF4.F4_CODIGO  = VO3.VO3_CODTES "
		cRetSQL += "    AND SF4.F4_ESTOQUE = 'S' "
		cRetSQL += "    AND SF4.D_E_L_E_T_ = ' ' "
		cRetSQL += "  WHERE VO3.VO3_FILIAL = '"+xFilial("VO3")+"' "		
		cRetSQL += "    AND VO3.VO3_DATFEC = ' ' "
		cRetSQL += "    AND VO3.VO3_DATCAN = ' ' "
		If !Empty(aPAROC002[2])
			cRetSQL += " AND VO3.VO3_GRUITE = '"+aPAROC002[2]+"'"
		EndIf
		If !Empty(aPAROC002[3])
			cRetSQL += " AND VO3.VO3_CODITE = '"+aPAROC002[3]+"'"
		EndIf
		cRetSQL += "    AND VO3.D_E_L_E_T_ = ' ' "
		cRetSQL += "  GROUP BY VO3.VO3_GRUITE , "
		cRetSQL += "           VO3.VO3_CODITE , "
		cRetSQL += "           SB1.B1_DESC , "
		cRetSQL += "           VO1.VO1_FILIAL , "
		cRetSQL += "           VO1.VO1_NUMOSV , "
		cRetSQL += "           VO1.VO1_DATABE "
		cRetSQL += ") TEMP "
		cRetSQL += "WHERE TEMP.VB3QUANT > 0 "
		cRetSQL += "ORDER BY TEMP.VB3GRUITE , TEMP.VB3CODITE , TEMP.VB3DATMOV "
	Case cTab == "FUT" .and. cPaisLoc == "ARG" // Entrega Futura - BO
		cRetSQL += "SELECT * FROM ( "
		cRetSQL += "   SELECT SB1.B1_GRUPO AS B1GRUPO , "
		cRetSQL += "          SB1.B1_CODITE AS B1CODITE , "
		cRetSQL += "          SB1.B1_DESC AS B1DESC , "
		cRetSQL += "          SUM( SC6.C6_QTDVEN - SC6.C6_QTDENT ) AS C6QUANT , "
		cRetSQL += "          MIN(SC5.C5_EMISSAO) AS C5EMISSAO , "
		cRetSQL += "          VS1.VS1_FILIAL AS VS1FILIAL , "
		cRetSQL += "          VS1.VS1_NUMORC AS VS1NUMORC , "
		cRetSQL += "          VS1.VS1_DATORC AS VS1DATORC , "
		cRetSQL += "          VS1.VS1_CODVEN AS VS1CODVEN , "
		cRetSQL += "          SA3.A3_NOME AS A3NOME "
		cRetSQL += "   FROM " + RetSQLName("SC6") + " SC6 "
		cRetSQL += "   JOIN " + RetSQLName("SC5") + " SC5 "
		cRetSQL += "     ON SC5.C5_FILIAL = SC6.C6_FILIAL "
		cRetSQL += "    AND SC5.C5_NUM = SC6.C6_NUM "
		cRetSQL += "    AND SC5.D_E_L_E_T_ = ' ' "
		cRetSQL += "   JOIN " + RetSQLName("SB1") + " SB1 "
		cRetSQL += "     ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
		cRetSQL += "    AND SB1.B1_COD = SC6.C6_PRODUTO "
		If !Empty(aPAROC002[2])
			cRetSQL += " AND SB1.B1_GRUPO = '"+aPAROC002[2]+"'"
		EndIf
		If !Empty(aPAROC002[3])
			cRetSQL += " AND SB1.B1_CODITE = '"+aPAROC002[3]+"'"
		EndIf
		cRetSQL += "    AND SB1.D_E_L_E_T_ = ' ' "
		cRetSQL += "   JOIN " + RetSQLName("VS1") + " VS1 "
		cRetSQL += "     ON VS1.VS1_FILIAL = '" + xFilial("VS1") + "'"
		cRetSQL += "    AND VS1.VS1_PEDREM = SC6.C6_NUM "
		cRetSQL += "    AND VS1.VS1_TPFATR = '4' "
		cRetSQL += "    AND VS1.VS1_STATUS = 'X' "
		cRetSQL += "    AND VS1.D_E_L_E_T_ = ' ' "
		cRetSQL += "   LEFT JOIN " + RetSQLName("SA3") + " SA3 "
		cRetSQL += "     ON SA3.A3_FILIAL = '"+xFilial("SA3")+"'"
		cRetSQL += "    AND SA3.A3_COD = VS1.VS1_CODVEN "
		cRetSQL += "    AND SA3.D_E_L_E_T_ = ' ' "
		cRetSQL += "  WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "'"
		cRetSQL += "    AND SC6.C6_QTDENT < SC6.C6_QTDVEN "
		cRetSQL += "    AND SC6.D_E_L_E_T_ = ' ' "
		cRetSQL += "  GROUP BY SB1.B1_GRUPO , "
		cRetSQL += "           SB1.B1_CODITE , "
		cRetSQL += "           SB1.B1_DESC , "
		cRetSQL += "           VS1.VS1_FILIAL , "
		cRetSQL += "           VS1.VS1_NUMORC , "
		cRetSQL += "           VS1.VS1_DATORC , "
		cRetSQL += "           VS1.VS1_CODVEN , "
		cRetSQL += "           SA3.A3_NOME "
		cRetSQL += ") TEMP "
		cRetSQL += "WHERE TEMP.C6QUANT > 0 "
		cRetSQL += "ORDER BY TEMP.B1GRUPO , TEMP.B1CODITE , TEMP.C5EMISSAO "
EndCase
Return cRetSQL

/*/{Protheus.doc} OFC002061_Tipo
Retorna o Tipo
BALCAO: Orçamento ou Pedido
OFICINA: Aguardando Requisição ou Requisitado

@author Andre Luis Almeida
@since 10/09/2026
/*/
Function OFC002061_Tipo(cOrigem,cTipo)
Local cRet := ""
Do Case
	Case cOrigem == "B" // Balcao
		cRet := STR0009 // Orçamento
		If cTipo == "P"
			cRet := STR0010 // Pedido
		EndIf
	Case cOrigem == "O" // Oficina
		cRet := STR0011 // Aguardando Requisição
		If cTipo == "R"
			cRet := STR0012 // Requisitado
		EndIf
EndCase
Return cRet

/*/{Protheus.doc} OFC002071_VisualizaOrcamento
Visualizar o Orçamento/Pedido

@author Andre Luis Almeida
@since 10/09/2026
/*/
Static Function OFC002071_VisualizaOrcamento(cFilVS1,cNroVS1)
dbSelectArea("VS1")
dbSetOrder(1)
if dbSeek(cFilVS1+cNroVS1)
	OFC002091_F12(.f.)
	OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
	OFC002091_F12(.t.)
EndIf
Return

/*/{Protheus.doc} OFC002081_VisualizaOS
Visualizar a Ordem de Serviço

@author Andre Luis Almeida
@since 10/09/2026
/*/
Static Function OFC002081_VisualizaOS(cFilVO1,cNroVO1)
dbSelectArea("VO1")
dbSetOrder(1)
if dbSeek(cFilVO1+cNroVO1)
	OFC002091_F12(.f.)
	OC060("VO1",RECNO(),2)
	OFC002091_F12(.t.)
EndIf
Return

/*/{Protheus.doc} OFC002091_F12
Habilita ou Desabilita o F12 ( Filtro nos SQLs )

@author Andre Luis Almeida
@since 11/09/2026
/*/
Static Function OFC002091_F12(lHabilita)
SetKey(VK_F12,Nil)
If lHabilita
	SetKey(VK_F12,{|| OFC002101_Filtro_SQLs() })
EndIf
Return

/*/{Protheus.doc} OFC002101_Filtro_SQLs
Executa Filtro nos SQLs

@author Andre Luis Almeida
@since 11/09/2026
/*/
Static Function OFC002101_Filtro_SQLs()
Local aParamBox := {}
Local aRet      := {}
Local oFilHelp  := DMS_FilialHelper():New()
Local aFiliais  := oFilHelp:GetAllFilPermis(.f.)
Private cGrupoA := aPAROC002[2] // Utilizado no F3 do B23
OFC002091_F12(.f.)
//
aAdd(aParamBox,{2,STR0013,aPAROC002[1],aFiliais,60,"",.F.}) // Filial
aAdd(aParamBox,{1,STR0014,aPAROC002[2],"@!","OFC002111_Valid(1)","SBM","",35,.F.}) // Grupo do Item
aAdd(aParamBox,{1,STR0015,aPAROC002[3],"@!","OFC002111_Valid(2)","B23","",90,.F.}) // Código do Item
If ParamBox(aParamBox,STR0016,@aRet,,,,,,,,.f.) // Filtro
	//
	aPAROC002[1] := cFilAnt := aRet[1]
	aPAROC002[2] := aRet[2]
	aPAROC002[3] := aRet[3]
	//
	oBrwVB2:SetQuery( OFC002051_Query("VB2") )
	SQLVB2->(DbGoTop())
	oBrwVB2:nAt := 1
	oBrwVB2:SetFocus()
	oBrwVB2:Refresh()
	//
	oBrwVB3:SetQuery( OFC002051_Query("VB3") )
	SQLVB3->(DbGoTop())
	oBrwVB3:nAt := 1
	oBrwVB3:SetFocus()
	oBrwVB3:Refresh()
	//
	If cPaisLoc == "ARG"
		oBrwFUT:SetQuery( OFC002051_Query("FUT") )
		SQLFUT->(DbGoTop())
		oBrwFUT:nAt := 1
		oBrwFUT:SetFocus()
		oBrwFUT:Refresh()
	EndIf
	//
EndIf
//
OFC002091_F12(.t.)
Return

/*/{Protheus.doc} OFC002111_Valid
Valid do Grupo e Codigo do Item

@author Andre Luis Almeida
@since 11/09/2026
/*/
Function OFC002111_Valid(nTp)
Local lRet := .f.
If nTp == 1 // Grupo do Item
	If Empty(MV_PAR02) .or. FG_SEEK("SBM","MV_PAR02",1,.F.)
		cGrupoA := MV_PAR02 // Utilizado no F3 do B23
		lRet := .t.
	EndIf
Else // nTp == 2 // Codigo do Item
	If Empty(MV_PAR03) .or. FG_SEEK("SB1","MV_PAR02+MV_PAR03",7,.F.)
		lRet := .t.
	EndIf
EndIf
Return lRet