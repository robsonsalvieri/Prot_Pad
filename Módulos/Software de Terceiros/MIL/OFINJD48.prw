#Include 'Protheus.ch'
#Include 'TOPCONN.CH'
#Include 'OFINJD48.CH'

/*/{Protheus.doc} OJD010015_ColunasBrowse()
    Rotina de consulta de itens alterados na importação do Parts Info

    @author Renato Vinicius
    @since  21/11/2024
/*/

Function OFINJD48()

	Local oBrowseA
	Local aSize    := FWGetDialogSize( oMainWnd )
	Local oTabParts:= DMS_PartsInfo():New()
	Local cQuery   := ""
	Local aIndex   := {}
	Local aSeek	:= {}

	Aadd( aIndex, "FILIAL+DATAIMP+PRODUTO")
	Aadd( aIndex, "PRODUTO" )

	Aadd( aSeek, { RetTitle("B1_FILIAL") + "+" + STR0002 + "+" + RetTitle("B1_COD") , {{"","C",TamSX3("B1_FILIAL")[1],0, RetTitle("B1_FILIAL"),,},{"","D",14,0, STR0002,,},{"","C",TamSX3("B1_COD")[1],0,RetTitle("B1_COD"),,}}}) // "Filial/Data Import/Código"
	Aadd( aSeek, { RetTitle("B1_COD"), {{"","C",TamSX3("B1_COD")[1],0,RetTitle("B1_COD"),,}} } )	// "Código" ### "Código"

	cQuery += "	SELECT TEMP.DATAIMP, TEMP.FILIAL, TEMP.PRODUTO, TEMP.DESCRICAO, TEMP.PRECOANT, TEMP.PRECOATU, TEMP.PESOANT, "
	cQuery += 		" TEMP.PESOATU, TEMP.CRICODANT, TEMP.CRICODATU, TEMP.POSIPIANT, TEMP.POSIPIATU, TEMP.REMANEANT, TEMP.REMANEATU, "
	cQuery += 		" TEMP.GRUDESANT, TEMP.GRUDESATU, TEMP.PRECOANT2, TEMP.PRECOATU2, TEMP.PRECOANT3, TEMP.PRECOATU3, TEMP.PRECOANT4, "
	cQuery += 		" TEMP.PRECOATU4, TEMP.PRECOANT5, TEMP.PRECOATU5, TEMP.PRECOANT6, TEMP.PRECOATU6 "
	cQuery += " FROM " + oTabParts:TableNameParts() + " TEMP "
	cQuery += " WHERE ( "
	cQuery += " 	CASE WHEN PRECOANT  IS NULL THEN '0' ELSE PRECOANT  END <> PRECOATU  OR "
	cQuery += " 	CASE WHEN PESOANT   IS NULL THEN '0' ELSE PESOANT   END <> PESOATU   OR "
	cQuery += " 	CASE WHEN CRICODANT IS NULL THEN ' ' ELSE CRICODANT END <> CRICODATU OR "
	cQuery += " 	CASE WHEN POSIPIANT IS NULL THEN ' ' ELSE POSIPIANT END <> POSIPIATU OR "
	cQuery += " 	CASE WHEN REMANEANT IS NULL THEN ' ' ELSE REMANEANT END <> REMANEATU OR "
	cQuery += " 	CASE WHEN GRUDESANT IS NULL THEN ' ' ELSE GRUDESANT END <> GRUDESATU OR "
	cQuery += " 	CASE WHEN PRECOANT2 IS NULL THEN '0' ELSE PRECOANT2 END <> PRECOATU2 OR "
	cQuery += " 	CASE WHEN PRECOANT3 IS NULL THEN '0' ELSE PRECOANT3 END <> PRECOATU3 OR "
	cQuery += " 	CASE WHEN PRECOANT4 IS NULL THEN '0' ELSE PRECOANT4 END <> PRECOATU4 OR "
	cQuery += " 	CASE WHEN PRECOANT5 IS NULL THEN '0' ELSE PRECOANT5 END <> PRECOATU5 OR "
	cQuery += " 	CASE WHEN PRECOANT6 IS NULL THEN '0' ELSE PRECOANT6 END <> PRECOATU6 "
	cQuery += " )"

	oDlg := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0001 , , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

		// Criação do browse de tela
		oBrowseA := FWFormBrowse():New( )
		oBrowseA:SetOwner(oDlg)
		oBrowseA:SetDataQuery(.T.)
		oBrowseA:SetAlias("TEMP")
		oBrowseA:SetQueryIndex(aIndex)
		oBrowseA:SetQuery(cQuery)
		oBrowseA:SetSeek(,aSeek)
		oBrowseA:SetDescription( STR0001 ) //"Consulta de Itens Alterados Parts Info"
		oBrowseA:SetMenuDef("")
		oBrowseA:DisableDetails()
		oBrowseA:DisableConfig()
		oBrowseA:SetUseFilter(.t.)
		oBrowseA:SetColumns(OJD010015_ColunasBrowse())
		oBrowseA:Activate()

	oDlg:Activate( , , , , , , ) //ativa a janela

Return

/*/{Protheus.doc} OJD010015_ColunasBrowse()
    Retorna as Colunas do Browse de Detalhes ( browse em SQL )

    @author Renato Vinicius
    @since  21/11/2024
/*/
Static Function OJD010015_ColunasBrowse()
Local aColumns := {}

AAdd(aColumns,FWBrwColumn():New())
    aColumns[1]:SetData( &("{|| Stod(DATAIMP) }") ) 
    aColumns[1]:SetTitle( STR0002 ) // Data Import
    aColumns[1]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[2]:SetData( &("{|| FILIAL }") )
    aColumns[2]:SetTitle(RetTitle("B5_FILIAL"))
    aColumns[2]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[3]:SetData( &("{|| PRODUTO }") )
    aColumns[3]:SetTitle(RetTitle("B1_COD"))
    aColumns[3]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[4]:SetData( &("{|| DESCRICAO }") )
    aColumns[4]:SetTitle(RetTitle("B1_DESC"))
    aColumns[4]:SetSize(30) // 30 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[5]:SetData( &('{||Transform( PRECOANT ,GetSX3Cache("B1_PRV1","X3_PICTURE"))}')) 
    aColumns[5]:SetTitle(RetTitle("B1_PRV1") + STR0003 ) //" Anterior"
    aColumns[5]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[6]:SetData( &('{||Transform( PRECOATU ,GetSX3Cache("B1_PRV1","X3_PICTURE"))}')) 
    aColumns[6]:SetTitle(RetTitle("B1_PRV1") + STR0004 ) //" Atual"
    aColumns[6]:SetSize(30) // 30 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[7]:SetData( &("{|| PESOANT }") ) 
    aColumns[7]:SetTitle(RetTitle("B1_PESO") + STR0003 ) //" Anterior"
    aColumns[7]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[8]:SetData( &("{|| PESOATU }") ) 
    aColumns[8]:SetTitle(RetTitle("B1_PESO") + STR0004 ) //" Atual"
    aColumns[8]:SetSize(30) // 30 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[9]:SetData( &("{|| CRICODANT }") ) 
    aColumns[9]:SetTitle(RetTitle("B1_CRICOD") + STR0003 ) //" Anterior"
    aColumns[9]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[10]:SetData( &("{|| CRICODATU }") ) 
    aColumns[10]:SetTitle(RetTitle("B1_CRICOD") + STR0004 ) //" Atual"
    aColumns[10]:SetSize(30) // 30 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[11]:SetData( &("{|| POSIPIANT }") ) 
    aColumns[11]:SetTitle(RetTitle("B1_POSIPI") + STR0003 ) //" Anterior"
    aColumns[11]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[12]:SetData( &("{|| POSIPIATU }") ) 
    aColumns[12]:SetTitle(RetTitle("B1_POSIPI") + STR0004 ) //" Atual"
    aColumns[12]:SetSize(30) // 30 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[13]:SetData( &("{|| REMANEANT }") ) 
    aColumns[13]:SetTitle(RetTitle("B1_REMANE") + STR0003 ) //" Anterior"
    aColumns[13]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[14]:SetData( &("{|| REMANEATU }") ) 
    aColumns[14]:SetTitle(RetTitle("B1_REMANE") + STR0004 ) //" Atual"
    aColumns[14]:SetSize(30) // 30 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[15]:SetData( &("{|| GRUDESANT }") ) 
    aColumns[15]:SetTitle(RetTitle("B1_GRUDES") + STR0003 ) //" Anterior"
    aColumns[15]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[16]:SetData( &("{|| GRUDESATU }") ) 
    aColumns[16]:SetTitle(RetTitle("B1_GRUDES") + STR0004 ) //" Atual"
    aColumns[16]:SetSize(30) // 30 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[17]:SetData( &('{||Transform(PRECOANT2,GetSX3Cache("B5_PRV2","X3_PICTURE"))}')) 
    aColumns[17]:SetTitle(RetTitle("B5_PRV2") + STR0003 ) //" Anterior"
    aColumns[17]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[18]:SetData( &('{||Transform(PRECOATU2,GetSX3Cache("B5_PRV2","X3_PICTURE"))}'))
    aColumns[18]:SetTitle(RetTitle("B5_PRV2") + STR0004 ) //" Atual"
    aColumns[18]:SetSize(30) // 30 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[19]:SetData( &('{||Transform(PRECOANT3,GetSX3Cache("B5_PRV3","X3_PICTURE"))}')) 
    aColumns[19]:SetTitle(RetTitle("B5_PRV3") + STR0003 ) //" Anterior"
    aColumns[19]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[20]:SetData( &('{||Transform(PRECOATU3,GetSX3Cache("B5_PRV3","X3_PICTURE"))}')) 
    aColumns[20]:SetTitle(RetTitle("B5_PRV3") + STR0004 ) //" Atual"
    aColumns[20]:SetSize(30) // 30 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[21]:SetData( &('{||Transform(PRECOANT4,GetSX3Cache("B5_PRV4","X3_PICTURE"))}')) 
    aColumns[21]:SetTitle(RetTitle("B5_PRV4") + STR0003 ) //" Anterior"
    aColumns[21]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[22]:SetData( &('{||Transform(PRECOATU4,GetSX3Cache("B5_PRV4","X3_PICTURE"))}')) 
    aColumns[22]:SetTitle(RetTitle("B5_PRV4") + STR0004 ) //" Atual"
    aColumns[22]:SetSize(30) // 30 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[23]:SetData( &('{||Transform(PRECOANT5,GetSX3Cache("B5_PRV5","X3_PICTURE"))}')) 
    aColumns[23]:SetTitle(RetTitle("B5_PRV5") + STR0003 ) //" Anterior"
    aColumns[23]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[24]:SetData( &('{||Transform(PRECOATU5,GetSX3Cache("B5_PRV5","X3_PICTURE"))}')) 
    aColumns[24]:SetTitle(RetTitle("B5_PRV5") + STR0004 ) //" Atual"
    aColumns[24]:SetSize(30) // 30 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[25]:SetData( &('{||Transform(PRECOANT6,GetSX3Cache("B5_PRV6","X3_PICTURE"))}')) 
    aColumns[25]:SetTitle(RetTitle("B5_PRV6") + STR0003 ) //" Anterior"
    aColumns[25]:SetSize(10) // 10 %
AAdd(aColumns,FWBrwColumn():New())
    aColumns[26]:SetData( &('{||Transform(PRECOATU6,GetSX3Cache("B5_PRV6","X3_PICTURE"))}')) 
    aColumns[26]:SetTitle(RetTitle("B5_PRV6") + STR0004 ) //" Atual"
    aColumns[26]:SetSize(30) // 30 %
Return aColumns
