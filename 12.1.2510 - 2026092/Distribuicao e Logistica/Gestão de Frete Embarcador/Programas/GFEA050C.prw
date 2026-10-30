#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"

Static cAliasGW1C := ""
Static cMsgErro  := ""
Static oFwFilter
/*--------------------------------------------------------------------------------------------------  
{Protheus.doc} GFEA050C
Tela de inclusão de trechos de redespacho

@sample
GFEA050C()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Function GFEA050C()
Return

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} ModelDef

@sample
ModelDef()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function ModelDef()
	Local oModel	   := Nil
	Local oStrGWU    := FWFormStruct(1,'GWU')
	Local oStructTab := FWFormModelStruct():New()
	Local oStructX3	:= GFESeekSX():New()

	oModel := MPFormModel():New('GFEA050C',,{|oModel| ValidModel(oModel) },{|oModel| CommitMdl(oModel) })
	oModel:AddFields('GWUMASTER',,oStrGWU)
	oModel:SetDescription("Redespachantes")
	oModel:GetModel('GWUMASTER'):SetDescription("Trechos") 
	
	// Monta Struct
	oStructTab:AddTable(cAliasGW1C, {'CDTPDC','EMISDC','SERDC','NRDC','SEQ'},'Tb Trechos')
	oStructTab:AddIndex(1,'1','CDTPDC+EMISDC+SERDC+NRDC+SEQ',"Idx Trechos",'','',.T.) 
	
	oStructX3:SeekX3("GWU_CDTPDC")
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'CDTPDC','C' ,oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.)  
	
	oStructX3:SeekX3("GWU_EMISDC")
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'EMISDC'  ,'C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) 
	
	oStructX3:SeekX3("GWU_SEQ")
	oStructTab:AddField("Trecho",oStructX3:getX3Titulo(),'SEQ','C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) 
	
	oStructX3:SeekX3("GWU_SERDC")
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'SERDC' ,'C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) 
	
	oStructX3:SeekX3("GWU_NRDC")
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'NRDC' ,'C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) 
		
	oStructX3:SeekX3("GWU_CDTRP")
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'CDTRP'  ,'C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.)	  
	                                                                                
	oStructX3:SeekX3("GU3_NMEMIT")                                                                                   
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'NMEMIT'  ,'C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.)
	
	oStructX3:SeekX3("GWU_NRCIDO")                                                                                 
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'NRCIDO'  ,'C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.)
	
	oStructX3:SeekX3("GWU_NMCIDO")                                                                                 
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'NMCIDO','C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.)
	
	oStructX3:SeekX3("GWU_UFO")                                                                                 
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'UFO','C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.)
	
	oStructX3:SeekX3("GWU_NRCIDD")                                                                                 
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'NRCIDD','C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.)	        
	                                                                          
	oStructX3:SeekX3("GU7_NMCID")                                                                                 
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'NMCID','C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.)    
	                                                                                                                
	oStructX3:SeekX3("GU7_CDUF")                                                                                  
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'UFD' ,'C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) 
	
	oStructX3:SeekX3("GWU_CDTPVC")                                                                                  
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'CDTPVC' ,'C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.)        
	                                                                   
	oStructX3:SeekX3("GWU_PAGAR")                                                                                  
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'PAGAR' ,'C',oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) 
	
	oStructTab:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. )
	oStrGWU:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. )
	
	oModel:AddGrid('TRECHOS','GWUMASTER',oStructTab)
	oModel:GetModel('TRECHOS'):SetOnlyQuery(.T.)
	oModel:GetModel('TRECHOS'):SetOptional(.T.)
	oModel:GetModel('TRECHOS'):SetNoInsertLine(.T.)
	oModel:GetModel('TRECHOS'):SetNoDeleteLine(.T.)
	
	oStructX3:Destroy()
	
Return oModel
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} ViewDef

@sample
ViewDef()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function ViewDef()
	Local oModel     :=  ModelDef()
	Local oStructTab := FWFormViewStruct():New()
	Local oView      := Nil
	Local oStructX3	:= GFESeekSX():New()
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Cria campos virtuais para a tabela temporária GWU
	oStructX3:SeekX3("GWU_CDTPDC")
	oStructTab:AddField('CDTPDC' ,'01',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Código do Produto
	
	oStructX3:SeekX3("GWU_EMISDC")
	oStructTab:AddField('EMISDC'  ,'02',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Quantidade
	
	oStructX3:SeekX3("GWU_SEQ")                                                                                      
	oStructTab:AddField('SEQ','03',"Trecho",oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Serviço de Transferência
	
	oStructX3:SeekX3("GWU_SERDC")                                                                                      
	oStructTab:AddField("SERDC" ,'04',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Armazém Destino
	
	oStructX3:SeekX3("GWU_NRDC")                                                                                                                                                                                                                                                                          // 
	oStructTab:AddField('NRDC' ,'05',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Endereço Destino                                                                                                                                                                                                                                                                                                           // 
	
	oStructX3:SeekX3("GWU_CDTRP")                                                                                                                                                                                                                                                                           // 
	oStructTab:AddField('CDTRP'  ,'06',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Armazém Origem
	
	oStructX3:SeekX3("GU3_NMEMIT")                                                                                                                                                                                                                                                                           // 
	oStructTab:AddField('NMEMIT'  ,'07',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Endereço Origem
	
	oStructX3:SeekX3("GWU_NRCIDO")                                                                                                                                                                                                                                                                         // 
	oStructTab:AddField('NRCIDO','08',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Lote
	
	oStructX3:SeekX3("GWU_NMCIDO")                                                                                                                                                                                                                                                                         // 
	oStructTab:AddField('NMCIDO','09',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Sub-Lote
	
	oStructX3:SeekX3("GWU_UFO")
	oStructTab:AddField('UFO' ,'10',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Produto Origem
	
	oStructX3:SeekX3("GWU_NRCIDD")                                                                                                                                                                                                                                                                         // 
	oStructTab:AddField('NRCIDD','11',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,"GU7"  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Lote
	
	oStructX3:SeekX3("GU7_NMCID")                                                                                                                                                                                                                                                                         // 
	oStructTab:AddField('NMCID','12',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Sub-Lote
	
	oStructX3:SeekX3("GWU_UFD")
	oStructTab:AddField('UFD' ,'13',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Produto Origem
	
	oStructX3:SeekX3("GWU_CDTPVC")
	oStructTab:AddField('CDTPVC' ,'14',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,"GV3"  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted ##"Número de Serie"
	
	oStructX3:SeekX3("GWU_PAGAR")
	oStructTab:AddField('PAGAR' ,'15',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,{"1=Sim", "2=Não"},Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted ##"Número de Serie"

	oView:AddOtherObject('GW1MARK',{|oPainel| MarkCarga(oPainel,oModel,oView) })
	oView:AddGrid('GWUGRID',oStructTab,'TRECHOS')
	oView:EnableTitleView('GWUGRID', "Trechos")
		
	oView:CreateHorizontalBox('DOCCARGA',40)
	oView:CreateHorizontalBox('TRECHOS',60)
		
	oView:SetOwnerView('GW1MARK','DOCCARGA')
	oView:SetOwnerView('GWUGRID','TRECHOS')
	
	oStructX3:Destroy()
Return oView
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} CommitMdl

Realiza commit das informações da grid de trechos

@sample
GFEA050C()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function CommitMdl(oModel)
	Local lRet       := .T.
	
	If !Empty(dData) .And. !Empty(cHora) .And. MsgYesNo("Deseja liberar novamente o romaneio?" )
		GFEA050LIB (.F.,"Liberado pela rotina de redespacho",dData,cHora)		
	EndIf 	
	dData := ""
	cHora := ""

Return lRet


Function GFEA050CFR(oBrw,aField)
	oBrwse := oBrw
	
	If Empty(oFwFilter)
		oFwFilter := FWFilter():New(oBrw:GetOwner())
		oFwFilter:SetAlias(cAliasGW1C)
		oFwFilter:SetProfileID("50C1")
		oFwFilter:SetField(aField)
		oFwFilter:DisableValid(.F.)
		oFwFilter:CleanFilter(.F.)	
		oFwFilter:LoadFilter()
		oFwFilter:SetExecute({|| GFEA050CFW(oFwFilter,oBrwse)})
	EndIf
	oFwFilter:Activate(oBrw:GetOwner())	
	
Return

Function GFEA050CFW(oFwFilter,oBrw)
	Local cFiltroAdv := oFwFilter:GetExprAdvPL() 
    
	oBrw:SetFilterDefault("") 
    oBrw:SetFilterDefault(cFiltroAdv)
    If Empty(cFiltroAdv)
        (cAliasGW1C)->(DBClearfilter())
    EndIf
    oBrw:oBrowse:UpdateBrowse()
    oBrw:oBrowse:Refresh(.T.)
Return

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} MarkCarga
Monta browse de marcação para os documentos de carga (GW1)

@sample
MarkCarga()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function MarkCarga(oPainel,oModel,oView)
	Local aAreaAnt   := GetArea()
	Local aCamposGW1 := {} 
	Local aFieldGW1  := {}
	Local aFilterGW1 := {}
	Local aSeek      := {}
	Local lMarcar    := .F.
	Local oMarkGW1   := Nil
	Local oStructX3	:= GFESeekSX():New()

	//Cria array com campos que serão mostrados em tela
	oStructX3:SeekX3("GW1_FILIAL")	
	Aadd(aFieldGW1,  {oStructX3:getX3Titulo(),"FILIAL_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"FILIAL_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GW1_CDTPDC")
	Aadd(aFieldGW1,  {oStructX3:getX3Titulo(),"CDTPDC_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"CDTPDC_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GW1_EMISDC")
	Aadd(aFieldGW1,  {oStructX3:getX3Titulo(),"EMISDC_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"EMISDC_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GU3_NMEMIT")
	Aadd(aFieldGW1,  {oStructX3:getX3Titulo(),"NMEMIT_GU3","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"NMEMIT_GU3", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GW1_DTEMIS")
	Aadd(aFieldGW1,  {oStructX3:getX3Titulo(),"DTEMIS_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"DTEMIS_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GW1_SERDC")
	Aadd(aFieldGW1,  {oStructX3:getX3Titulo(),"SERDC_GW1" ,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"SERDC_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GW1_NRDC")
	Aadd(aFieldGW1,  {oStructX3:getX3Titulo(),"NRDC_GW1"  ,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"NRDC_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GW1_CDREM")
	Aadd(aFieldGW1,  {oStructX3:getX3Titulo(),"CDREM_GW1" ,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"CDREM_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GU3_NMEMIT")
	Aadd(aFieldGW1,  {oStructX3:getX3Titulo(),"NMRED_GU3" ,"C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"NMRED_GU3", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:Destroy()

	//Pesquisar - Chave primária  //GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC
	Aadd( aSeek, { "Filial + Tp Doc + Emissor + Serie + Numero",;
	{ {"",aFieldGW1[1][3],aFieldGW1[1][4],aFieldGW1[1][5],aFieldGW1[1][1],aFieldGW1[1][6]},;
	  {"",aFieldGW1[2][3],aFieldGW1[2][4],aFieldGW1[2][5],aFieldGW1[2][1],aFieldGW1[2][6]},;	
	  {"",aFieldGW1[3][3],aFieldGW1[3][4],aFieldGW1[3][5],aFieldGW1[3][1],aFieldGW1[3][6]},;
	  {"",aFieldGW1[6][3],aFieldGW1[6][4],aFieldGW1[6][5],aFieldGW1[6][1],aFieldGW1[6][6]},;
	  {"",aFieldGW1[7][3],aFieldGW1[7][4],aFieldGW1[7][5],aFieldGW1[7][1],aFieldGW1[7][6]}},1})
	 
	 //Pesquisar GW1_FILIAL+DTOS(GW1_DTEMIS)+GW1_EMISDC Data Emissao + Emissor
	 Aadd( aSeek, { "Filial + Data Emissao + Emissor",;
	{ {"",aFieldGW1[1][3],aFieldGW1[1][4],aFieldGW1[1][5],aFieldGW1[1][1],aFieldGW1[1][6]},;	
	  {"",aFieldGW1[3][3],aFieldGW1[3][4],aFieldGW1[3][5],aFieldGW1[3][1],aFieldGW1[3][6]}},2})
	
	//Pesquisar GW1_FILIAL+GW1_NRDC Numero
	 Aadd( aSeek, { "Filial + Numero",;
	{ {"",aFieldGW1[1][3],aFieldGW1[1][4],aFieldGW1[1][5],aFieldGW1[1][1],aFieldGW1[1][6]},;	
	  {"",aFieldGW1[7][3],aFieldGW1[7][4],aFieldGW1[7][5],aFieldGW1[7][1],aFieldGW1[7][6]}},3})

	//Cria tabela temporária	
	CriaTabGW1(@aCamposGW1)		
	
	//Carrega dados da tabela temporária
	CarregaGW1(aCamposGW1)
	
	oMarkGW1 := FWMarkBrowse():New()
	oMarkGW1:SetDescription("Documento de Carga") 
	oMarkGW1:SetAlias(cAliasGW1C)
	oMarkGW1:SetOwner(oPainel)
	oMarkGW1:SetFieldMark('OK_GW1')
	oMarkGW1:SetTemporary(.T.)
	oMarkGW1:SetSeek(.T.,aSeek)
	oMarkGW1:SetFields( aFieldGW1 )
	oMarkGW1:bAllMark := { || SetMarkAll(oMarkGW1:Mark(),lMarcar := !lMarcar, 'GW1', oModel ), oMarkGW1:Refresh(.T.),SetTrechos(oModel), oView:Refresh()}
	oMarkGW1:SetAfterMark({|| SetTrechos(oModel), oView:Refresh() })
	oMarkGW1:oBrowse:AddButton("Incluir Lote",{ || GFE050CINC(oModel),oMarkGW1:Refresh(.T.),SetTrechos(oModel), oView:Refresh() },,3)
	oMarkGW1:oBrowse:AddButton("Filtrar",{ || GFEA050CFR(oMarkGW1,aFilterGW1),SetTrechos(oModel), oView:Refresh() },,2) 
	oMarkGW1:SetMenuDef('')
	oMarkGW1:SetWalkThru(.F.)
	oMarkGW1:Activate()
	
	RestArea(aAreaAnt)
Return 
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} SetMarkAll
Marca/Desmarca todos os documentos de carga 

@sample
SetMarkAll()

@author Amanda Vieira
@since 25/02/2016  
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function SetMarkAll(cMarca,lMarcar,cTable,oModel )
	Local aAreaTable  := (cTable)->( GetArea() )

	//----------------------------------------
	// Seleciona todos GW1 para marcação/desmarcação
	//----------------------------------------
	(cAliasGW1C)->(dbSetOrder(1))
	(cAliasGW1C)->(dbGoTop() )
	While !(cAliasGW1C)->(Eof())

		RecLock( cAliasGW1C, .F. )
		(cAliasGW1C)->OK_GW1 := IIf( lMarcar, cMarca, '  ' )
		MsUnLock()

		(cAliasGW1C)->(dbSkip())
	EndDo

	RestArea( aAreaTable )
Return .T.
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} CarregaGW1
Carrega dados da tabela temporária dos documentos de carga

@Parametros
CarregaGW1()

@author Amanda Vieira
@since 25/02/2016  
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function CarregaGW1(arrayCampos)
	Local cAliasQry
	Local cQuery
	Local nCont := 0
	Local nCont1:= 0
	Local aTab  := {}

    //-------------------------------------------------------------------
    // Limpa tabela temporária
    //-------------------------------------------------------------------
    dbSelectArea(cAliasGW1C)
    (cAliasGW1C)->( dbSetOrder(1) )
    ZAP
	
    //-------------------------------------------------------------------
    // Carga de dados
    //-------------------------------------------------------------------	
	cQuery := " SELECT DISTINCT GW1.GW1_FILIAL,"
	cQuery += "                 GW1.GW1_NRDC,"
	cQuery += "                 GW1.GW1_TPFRET,"
	cQuery += "                 GW1.GW1_CDTPDC,"
	cQuery += "                 GW1.GW1_EMISDC,"
	cQuery += "                 GW1.GW1_SERDC,"
	cQuery += "                 GW1.GW1_DTEMIS,"
	cQuery += "                 GW1.GW1_CDREM"
	cQuery += " FROM "+RetSqlName('GW1')+" GW1"
	cQuery += " LEFT JOIN "+RetSqlName('GWH')+" GWH ON GWH.GWH_FILIAL = GW1.GW1_FILIAL"
	cQuery += " AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += " AND GWH.GWH_EMISDC = GW1.GW1_EMISDC"
	cQuery += " AND GWH.GWH_SERDC  = GW1.GW1_SERDC"
	cQuery += " AND GWH.GWH_NRDC   = GW1.GW1_NRDC"
	cQuery += " AND GWH.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN "+RetSqlName('GWF')+" GWF ON GWF.GWF_FILIAL = GWH.GWH_FILIAL" 
	cQuery += " AND GWF.GWF_NRCALC = GWH_NRCALC"
	cQuery += " AND GWF.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN "+RetSqlName('GXD')+" GXD ON GXD.GXD_FILIAL = GWH.GWH_FILIAL"
	cQuery += " AND GXD.GXD_NRCALC = GWH.GWH_NRCALC"
	cQuery += " AND GXD.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN "+RetSqlName('GXE')+" GXE ON GXE.GXE_FILIAL = GXD.GXD_FILIAL"
	cQuery += " AND GXE.GXE_CODLOT = GXD.GXD_CODLOT"
	cQuery += " AND GXE.D_E_L_E_T_ = ' '"
	If GFXCP1212210('GW1_FILROM')
		cQuery += " WHERE GW1.GW1_FILROM = '"+GWN->GWN_FILIAL+"'"
	Else
		cQuery += " WHERE GW1.GW1_FILIAL = '"+GWN->GWN_FILIAL+"'"
	EndIf
	cQuery += "   AND GW1.GW1_NRROM = '"+GWN->GWN_NRROM+"'"
	cQuery += "   AND (GXE.GXE_SIT NOT IN ('2|3|4|5')"
	cQuery += "        OR GXE.GXE_SIT IS NULL)"
	cQuery += "   AND (GWF.GWF_ORIGEM = '1'"
	cQuery += "       OR GWF.GWF_ORIGEM = '2'"
	cQuery += "       OR GWF.GWF_ORIGEM = '4'"
	cQuery += "       OR GWF.GWF_ORIGEM IS NULL)  
	cQuery += "   AND GW1.D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField(cAliasQry,'GW1_DTEMIS','D',8,0)
	
	While (cAliasQry)->(!Eof())
		Aadd(aTab,{ " ",;
			(cAliasQry)->GW1_FILIAL,;
			(cAliasQry)->GW1_CDTPDC,;
			(cAliasQry)->GW1_EMISDC,;
			POSICIONE("GU3",1,XFILIAL("GU3")+(cAliasQry)->GW1_EMISDC,"GU3_NMEMIT"),;
			DtoC((cAliasQry)->GW1_DTEMIS),;
			(cAliasQry)->GW1_SERDC,;
			(cAliasQry)->GW1_NRDC,;
			(cAliasQry)->GW1_CDREM,;
			POSICIONE("GU3",1,XFILIAL("GU3")+(cAliasQry)->GW1_CDREM,"GU3_NMEMIT")})
		(cAliasQry)->(dbSkip())
	EndDo
	
    For nCont := 1 To Len(aTab)
        RecLock(cAliasGW1C,.T.)
    	//Inicia a contagem como 2, ignorando o campo "marca/desmarca" que não existe na tabela física
        For nCont1 := 2 To Len(arrayCampos)
            (cAliasGW1C)->&(arrayCampo[nCont1,1]) := aTab[nCont,nCont1]
        Next
        MsUnLock(cAliasGW1C)
    Next
    dbGoTop()
 	(cAliasQry)->(dbCloseArea())
Return cAliasGW1C
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} SetTrechos
Carrega dados da tabela temporária dos trechos

@sample
SetTrechos()

@author Amanda Vieira
@since 25/02/2016  
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function SetTrechos(oModel)
	Local cAliasQry := ""
	Local cQuery    := ""
	Local nI        := 1
	Local aAreaTemp := (cAliasGW1C)->(GetArea())
	
	oModel:GetModel('TRECHOS'):SetNoInsertLine(.F.)
	oModel:GetModel('TRECHOS'):SetNoDeleteLine(.F.)
	oModel:GetModel("TRECHOS"):ClearData()
	oModel:GetModel("TRECHOS"):InitLine()
	oModel:GetModel("TRECHOS"):GoLine(1)

	//Busca documentos de carga marcados para formar grid com seus trechos
	(cAliasGW1C)->(dbGoTop())
	While (cAliasGW1C)->(!Eof()) 
		If !Empty((cAliasGW1C)->OK_GW1)
	    	// Carga de dados
			cQuery := " SELECT GWU_CDTPDC,GWU_EMISDC,GWU_SEQ,GWU_SERDC,GWU_NRDC,GWU_CDTRP,GWU_NRCIDO,GWU_NRCIDD,GWU_CDTPVC,GWU_PAGAR "
			cQuery += " FROM "+RetSqlName('GWU')+" "
			cQuery += " WHERE GWU_FILIAL = '"+(cAliasGW1C)->FILIAL_GW1+"'" 
			cQuery += "	AND GWU_CDTPDC = '"+(cAliasGW1C)->CDTPDC_GW1+"'"
			cQuery += "   AND GWU_EMISDC = '"+(cAliasGW1C)->EMISDC_GW1+"'"
			cQuery += "   AND GWU_SERDC  = '"+(cAliasGW1C)->SERDC_GW1+ "'"
			cQuery += "   AND GWU_NRDC   = '"+(cAliasGW1C)->NRDC_GW1+  "'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			
			While (cAliasQry)->(!Eof())
				If !Empty(oModel:GetModel('TRECHOS'):GetValue('CDTPDC'))
					oModel:GetModel('TRECHOS'):AddLine()
					oModel:GetModel('TRECHOS'):GoLine(++nI)
				EndIf	
				
				oModel:GetModel("TRECHOS"):LoadValue("CDTPDC",(cAliasQry)->GWU_CDTPDC)	
				oModel:GetModel("TRECHOS"):LoadValue("EMISDC",(cAliasQry)->GWU_EMISDC)
				oModel:GetModel("TRECHOS"):LoadValue("SEQ"   ,(cAliasQry)->GWU_SEQ)
				oModel:GetModel("TRECHOS"):LoadValue("SERDC" ,(cAliasQry)->GWU_SERDC)
				oModel:GetModel("TRECHOS"):LoadValue("NRDC"  ,(cAliasQry)->GWU_NRDC)
				oModel:GetModel("TRECHOS"):LoadValue("CDTRP" ,(cAliasQry)->GWU_CDTRP)
				oModel:GetModel("TRECHOS"):LoadValue("NMEMIT",POSICIONE("GU3",1,XFILIAL("GU3")+(cAliasQry)->GWU_CDTRP,"GU3_NMEMIT"))
				oModel:GetModel("TRECHOS"):LoadValue("NRCIDO",(cAliasQry)->GWU_NRCIDO)
				oModel:GetModel("TRECHOS"):LoadValue("NMCIDO",POSICIONE("GU7",1,XFILIAL("GU7")+(cAliasQry)->GWU_NRCIDO,"GU7_NMCID"))
				oModel:GetModel("TRECHOS"):LoadValue("UFO"   ,POSICIONE("GU7",1,XFILIAL("GU7")+(cAliasQry)->GWU_NRCIDO,"GU7_CDUF"))
				oModel:GetModel("TRECHOS"):LoadValue("NRCIDD",(cAliasQry)->GWU_NRCIDD)
				oModel:GetModel("TRECHOS"):LoadValue("NMCID" ,POSICIONE("GU7",1,XFILIAL("GU7")+(cAliasQry)->GWU_NRCIDD,"GU7_NMCID"))
				oModel:GetModel("TRECHOS"):LoadValue("UFD"   ,POSICIONE("GU7",1,XFILIAL("GU7")+(cAliasQry)->GWU_NRCIDD,"GU7_CDUF"))
				oModel:GetModel("TRECHOS"):LoadValue("CDTPVC",(cAliasQry)->GWU_CDTPVC)
				oModel:GetModel("TRECHOS"):LoadValue("PAGAR" ,(cAliasQry)->GWU_PAGAR)	
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		EndIf
		(cAliasGW1C)->(dbSkip())
	EndDo
	
	oModel:GetModel('TRECHOS'):GoLine(1)
	oModel:GetModel('TRECHOS'):SetNoInsertLine(.T.)
	oModel:GetModel('TRECHOS'):SetNoDeleteLine(.T.)
	
	RestArea(aAreaTemp)
Return Nil
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} CriaTabGW1
Cria tabela temporária dos documentos de carga (GW1)

@sample
CriaTabGW1()

@author Amanda Vieira
@since 25/02/2016  
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function CriaTabGW1(aCamposGW1)
	Local oStructX3	:= GFESeekSX():New()
	
	Aadd(aCamposGW1,{"OK_GW1","C",1,0})	
	
	oStructX3:SeekX3("GW1_FILIAL")
	Aadd(aCamposGW1,{"FILIAL_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GW1_CDTPDC")
	Aadd(aCamposGW1,{"CDTPDC_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GW1_EMISDC")
	Aadd(aCamposGW1,{"EMISDC_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GU3_NMEMIT")
	Aadd(aCamposGW1,{"NMEMIT_GU3","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GW1_DTEMIS")
	Aadd(aCamposGW1,{"DTEMIS_GW1","C",10,oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GW1_SERDC")
	Aadd(aCamposGW1,{"SERDC_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GW1_NRDC")
	Aadd(aCamposGW1,{"NRDC_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GW1_CDREM")
	Aadd(aCamposGW1,{"CDREM_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GU3_NMEMIT")
	Aadd(aCamposGW1,{"NMRED_GU3","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
	
	If Empty(cAliasGW1C) // Criação da temporária de seleção GW1
		cAliasGW1C := GFECriaTab({aCamposGW1,{"FILIAL_GW1+CDTPDC_GW1+EMISDC_GW1+SERDC_GW1+NRDC_GW1","FILIAL_GW1+DTEMIS_GW1+EMISDC_GW1","FILIAL_GW1+NRDC_GW1"}})
	EndIf

	oStructX3:Destroy()

Return Nil
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA050CP
Função utilizada para definir consulta padrão do campo de transportadora, 
com base no parâmetro MV_TREDESP que identifica a utilização de redespachantes.

@sample
GFEA050CP()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Function GFEA050CP()
	Local cAliasQry := ""
	Local cQuery    := ""
	Local cFiltro   := " GU3->GU3_TRANSP == '1' "
	Local cAreaAnt  := GetArea()

	dbSelectArea('GU3')

	cQuery := " SELECT GU3.GU3_REDESP FROM "+RetSqlName('GU3')+" GU3" 
	cQuery += " WHERE GU3.GU3_FILIAL = '"+xFilial('GU3')+"'"
	If SuperGetMV("MV_TREDESP",, "1") == "3"  // MV_TREDESP == "3" (Obrigatório a utilização de redespachantes)
		cQuery += "   AND GU3.GU3_REDESP = '1'"
	EndIf
	cQuery += "   AND GU3.GU3_TRANSP = '1'"
	cQuery += "   AND GU3.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If SuperGetMV("MV_TREDESP",, "1") == "3"
		cFiltro += " .AND. GU3->GU3_REDESP == '1' "
	EndIf
	(cAliasQry)->(dbCloseArea())
 
	RestArea(cAreaAnt)        
Return cFiltro
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE050CINC
Tela de alteração de redespachantes por lote

@sample
GFE050CINC()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function GFE050CINC(oModel)
	Local aItems      := {'Sim','Não'}
	Local nOpc        := 0
	Local oDlg        := NIL
	Local oSize       := Nil
	Local oPanel      := Nil
	Local oCombo      := Nil
	Local bOk         := {|| IIF(ValTrePago(cPago,cCdTrp),(oDlg:End(),nOpc := 1),.F.) } //nOpc := 1 .And. oDlg:End()
	Local bCancel     := {|| nOpc := 0, oDlg:End() }
	Local cCdTrp	    := Space(TamSX3("GWU_CDTRP")[1])
	Local cNrCidO	    := Space(TamSX3("GWU_NRCIDO")[1])
	Local cPago       := ""
	Local lRet        := .T.
	Local lHasGW1     := .F.
	
	//Valida se há GW1 selecionada
	(cAliasGW1C)->(dbGoTop())	
	While !(cAliasGW1C)->(Eof()) .And. !lHasGW1
		If !Empty((cAliasGW1C)->OK_GW1)
			lHasGW1 := .T.
		EndIf
		(cAliasGW1C)->(dbSkip())
	EndDo
	If !lHasGW1
		MsgInfo("Não há documentos de carga selecionados para a inclusão em lote.")
		Return lRet
	EndIf
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 20, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 200, 600})
	oSize:lLateral     := .F.  // Calculo vertical
	oSize:Process() //executa os calculos

	DEFINE MSDIALOG oDlg TITLE "Incluir trechos em lote";
							FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
							TO oSize:aWindSize[3],oSize:aWindSize[4] ;
							PIXEL OF oMainWnd
							
	oDlg:lEscClose := .F.				
			
	oPanel := tPanel():New(oSize:GetDimension("ENCHOICE","LININI"),;
	                       oSize:GetDimension("ENCHOICE","COLINI"),;
	                       "",oDlg,,,,,,;
	                       oSize:GetDimension("ENCHOICE","XSIZE"),;
	                       oSize:GetDimension("ENCHOICE","YSIZE"))
	                       
	// Combo box 
    cPago := aItems[1] //Vertical Horizontal       
	oCombo := TComboBox():New(37,55,{|u|if(PCount()>0,cPago:=u,cPago)},;
	aItems,50,14,oPanel,,;
	,,,,.T.,,,,,,,,,'cPago')
	
	//@ nLinha, nColuna SAY cTexto SIZE nLargura,nAltura UNIDADE OF oObjetoRef								
	@ 07,10  Say "Transportadora: " Of oPanel COLOR CLR_BLACK Pixel
	@ 05,55  MSGET cCdTrp Picture "@!"  F3 "GU3RED"  Of oPanel Valid Empty(cCdTrp) .Or. VldTransp(cCdTrp) When .T. SIZE 70,10  Pixel
	@ 05,130 MSGET POSICIONE("GU3",1,XFILIAL("GU3")+cCdTrp,"GU3_NMEMIT") Picture "@!" Of oPanel  When .F. SIZE 160,10  Pixel
			
	@ 22,10  Say "Cidade Origem.: " Of oPanel COLOR CLR_BLACK Pixel 
	@ 20,55  MSGET cNrCidO Picture "@!" F3 "GU7" Of oPanel   Valid  Empty(cNrCidO) .Or. VldNrCid(cNrCidO) When .T. SIZE 35,10   Pixel  			
	@ 20,95  MSGET POSICIONE("GU7",1,XFILIAL("GU7")+cNrCidO,"GU7_NMCID") Picture "@!" Of oPanel   When .F. SIZE 175,10   Pixel 			 		
	@ 20,275 MSGET POSICIONE("GU7",1,XFILIAL("GU7")+cNrCidO,"GU7_CDUF")  Picture "@!" Of oPanel   When .F. SIZE 10,10   Pixel
	
	@ 37,10  Say "Frete Pago?" SIZE 40,10  Of oPanel COLOR CLR_BLACK Pixel //"Frete Pago?"	
	                    			
	ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED
	
	If nOpc == 1 //Ato de confirmar
		
		//Armazena resposta do usuário, se o trecho será pago ou não.
		cPago:= IIF(cPago == "Sim", cPago := "1", cPago := "2") 
		
		Processa({|lEnd| lRet := GFEProcInc(cCdTrp,cPago,cNrCidO)})//Processa Inclusão dos trechos	
		If lRet
			MsgInfo("Trecho(s) incluído(s) com sucesso.") 
		EndIf
	EndIf 
	
Return lRet 
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEProcInc
Processa a inclusão do trecho nos documentos marcados pelo usuário.

@sample
GFEProcInc()

-cCdTrp = Código do transportador informado pelo usuário
-cPago  = Define se o trecho incluído será pago ou não
-cNrCidO = Número da cidade de origem do trecho

@author Amanda Vieira
@since 15/06/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function GFEProcInc(cCdTrp,cPago,cNrCidO)
	Local aAreaGW1  := GW1->(GetArea())
	Local cAliasQry := ""
	Local cQuery    := ""
	Local nGerados  := 0
	Local GFEResult := GFEViewProc():New()
	Local lRet      := .T. 
	Local lErro     := .F.
	Local aCopyGWU	:= {}
	Local nCnt		:= 0
	Local aDcCarga	:= {}
	Local nI		:= 0

	dbSelectArea('GW1')
	GW1->(dbSetOrder(1)) //GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC
	dbSelectArea("GWU")
	GWU->(dbSetOrder(1)) //GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ

	ProcRegua(0)
	
	BEGIN TRANSACTION
	(cAliasGW1C)->(dbGoTop())	
	While !(cAliasGW1C)->(Eof())
		
		GW1->(dbSeek((cAliasGW1C)->(FILIAL_GW1+CDTPDC_GW1+EMISDC_GW1+SERDC_GW1+NRDC_GW1)))
		
		//Inicializa variáveis
		lRet  := .T.
		cMsgErro := ""
		
		If !Empty((cAliasGW1C)->OK_GW1)
			IncProc("Incluindo trecho... Documento:"+(cAliasGW1C)->NRDC_GW1) //"Incluindo trecho... Documento:"	
			
			//Valida sentido do documento conforme tipo de frete
			lRet := GFE050VLSE((cAliasGW1C)->CDTPDC_GW1,(cAliasGW1C)->EMISDC_GW1,(cAliasGW1C)->SERDC_GW1,(cAliasGW1C)->NRDC_GW1,cPago,@cMsgErro)
						
			If lRet
				//Altera tipo de frete, visto que será incluso mais um trecho
				If GW1->GW1_TPFRET $ "1|3|5"//1=CIF;3=FOB;5=Consignado;
					RecLock("GW1", .F.)
					GW1->GW1_TPFRET := Soma1(GW1->GW1_TPFRET) //Soma um no tipo de frete com o propósito de mudar para CIF, FOB ou Consignado Redespacho
					MsUnLock("GW1")
				EndIf
				
				cQuery := " SELECT GWU1.R_E_C_N_O_ RECGWU, GWU1.GWU_SEQ,GWU1.GWU_CDTRP"
				cQuery += "   FROM "+RetSqlName('GWU')+" GWU1"
				cQuery += "  WHERE GWU1.GWU_FILIAL = '"+(cAliasGW1C)->FILIAL_GW1+"'"
				cQuery += "    AND GWU1.GWU_CDTPDC = '"+(cAliasGW1C)->CDTPDC_GW1+"'"
				cQuery += "    AND GWU1.GWU_EMISDC = '"+(cAliasGW1C)->EMISDC_GW1+"'"
				cQuery += "    AND GWU1.GWU_SERDC  = '"+(cAliasGW1C)->SERDC_GW1+"'"
				cQuery += "    AND GWU1.GWU_NRDC   = '"+(cAliasGW1C)->NRDC_GW1+"'"
				cQuery += "    AND GWU1.GWU_SEQ    = ("
				cQuery += "                            SELECT MAX(GWU_SEQ)"
				cQuery += "                              FROM "+RetSqlName('GWU')+" GWU2"
				cQuery += "                             WHERE GWU2.GWU_FILIAL = GWU1.GWU_FILIAL"
				cQuery += "                               AND GWU2.GWU_CDTPDC = GWU1.GWU_CDTPDC"
				cQuery += "                               AND GWU2.GWU_EMISDC = GWU1.GWU_EMISDC"
				cQuery += "                               AND GWU2.GWU_SERDC  = GWU1.GWU_SERDC"
				cQuery += "                               AND GWU2.GWU_NRDC   = GWU1.GWU_NRDC"
				cQuery += "                               AND GWU2.D_E_L_E_T_ = ''"
				cQuery += "                            )"
				cQuery += "   AND GWU1.D_E_L_E_T_ = ''"
				cQuery := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
				
				If (cAliasQry)->(!EoF())
					GWU->(dbGoTo((cAliasQry)->RECGWU))

					If aScan(aDcCarga, {|x|x[1] + x[2] + x[3] + x[4] + x[5] == GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC}) == 0
						Aadd(aDcCarga, {GWU->GWU_FILIAL, GWU->GWU_CDTPDC, GWU->GWU_EMISDC, GWU->GWU_SERDC, GWU->GWU_NRDC})
					EndIf
					
					aCopyGWU := {}
					
					For nCnt := 1 To GWU->(FCount())
						AAdd(aCopyGWU, GWU->(FieldGet(nCnt)))
					Next nCnt

					//Altera o último trecho do documento para assumir a cidade de destino da transportadora informada ou a cidade origem do novo trecho
					RecLock("GWU", .F.)
					
					If Empty(cNrCidO)
						GWU->GWU_NRCIDD := POSICIONE("GU3",1,XFILIAL("GU3")+cCdTrp,"GU3_NRCID")
						cNrCidO			:= POSICIONE("GU3",1,XFILIAL("GU3")+cCdTrp,"GU3_NRCID")
					Else
					    GWU->GWU_NRCIDD := POSICIONE("GU7",1,XFILIAL("GU7")+cNrCidO,"GU7_NRCID")
					EndIf    	
					
					MsUnLock("GWU")
					
					//Incluí um novo trecho, com base no último trecho
					RecLock("GWU", .T.)
					For nCnt := 1 To Len(aCopyGWU)
						FieldPut(nCnt, aCopyGWU[nCnt])
					Next nCnt
					GWU->GWU_SEQ    := Soma1((cAliasQry)->GWU_SEQ)
					GWU->GWU_NRCIDO := cNrCidO
					GWU->GWU_NRCIDD := POSICIONE("GU3",1,XFILIAL("GU3")+GW1->GW1_CDDEST,"GU3_NRCID")
					GWU->GWU_CDTRP  := cCdTrp
					GWU->GWU_PAGAR  := cPago
					GWU->GWU_DTENT	:= CToD(" / / ")
					GWU->GWU_HRENT	:= ""
					MsUnLock("GWU")
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
			
			If !Empty(cMsgErro)
				lErro := .T.
			   	GFEResult:AddDetail("# "+cValToChar(nGerados)+" - Filial: "+AllTrim((cAliasGW1C)->FILIAL_GW1)+" Tipo Doc: "+Alltrim((cAliasGW1C)->CDTPDC_GW1)+" Emissor: "+Alltrim((cAliasGW1C)->EMISDC_GW1)+" Série: "+Alltrim((cAliasGW1C)->SERDC_GW1)+" Documento: "+Alltrim((cAliasGW1C)->NRDC_GW1))
			   	GFEResult:AddDetail("** " + cMsgErro, 1)
			Else 
			   	nGerados++
			   	GFEResult:Add("# Filial: "+Alltrim((cAliasGW1C)->FILIAL_GW1)+" Tipo Doc: "+Alltrim((cAliasGW1C)->CDTPDC_GW1)+" Emissor: "+Alltrim((cAliasGW1C)->EMISDC_GW1)+" Série: "+Alltrim((cAliasGW1C)->SERDC_GW1)+" Documento: "+Alltrim((cAliasGW1C)->NRDC_GW1))
			EndIf
		EndIf
		(cAliasGW1C)->(dbSkip())
	EndDo
	END TRANSACTION

	GFEResult:Add()

	// Verifica se algum trecho foi gerado
	If nGerados == 0
		GFEResult:Add("Nenhum trecho de redespacho gerado.")
	Else
		If GWN->GWN_SIT == "4"
			RecLock("GWN",.F.)
				GWN->GWN_SIT := "3"
			GWN->(MsUnlock())

			For nI := 1 To Len(aDcCarga)
				GW1->(dbSetOrder(1))
				If GW1->(dbSeek(aDcCarga[nI][1] + aDcCarga[nI][2] + aDcCarga[nI][3] + aDcCarga[nI][4] + aDcCarga[nI][5]))
					RecLock("GW1",.F.)
						GW1->GW1_SIT := "4"
					GW1->(MsUnlock())
				EndIf
			Next nI
		EndIf
		
		//Se houve alguma inclusão de trecho e o romaneio já encontrava-se calculado, altera para "necessita recáculo"
		//A alteração ocorre neste ponto e não no commit do model, para evitar que o usuário feche a tela sem ter completar a alteração da situação do cálculo
		If GWN->GWN_CALC == "1" //Verifica se o romaneio encontrava-se calculado
			RecLock("GWN", .F.)
				GWN->GWN_CALC 	:= "4" // Romaneio necessita recálculo
				GWN->GWN_MTCALC := "Incluído trecho de redespacho em documento de carga"
				GWN->GWN_DTCALC := CToD("  /  /    ")
				GWN->GWN_HRCALC := ""
			MsUnLock("GWN")
 			 
			If MsgYesNo("Deseja recalcular este romaneio?" )	// "Deseja recalcular este romaneio?" 
				GFE050CALC() // Recalcula o romaneio
			EndIf
		EndIf
	EndIf

	If lErro
		GFEResult:Add()
	EndIf

	GFEResult:Show("Geração de trecho de redespacho", "Documentos com trecho de redespacho gerado", "Erros")

	
	RestArea(aAreaGW1)
Return

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA050C
Valida informações da grid de trechos

@sample
GFEA050C()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function ValidModel(oModel)
	Local oModelGWU  := oModel:GetModel('GWUMASTER')

	// O modelo principal precisa sofrer alguma alteração.
	oModelGWU:LoadValue("GWU_CDTPDC"," ")
Return .T.
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA050C
Valida transportadora

@sample
GFEA050C()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function VldTransp(cCdTrp,lMsg)
	Default lMsg := .T.
	
	//Verifica se a transportadora existe e é válida.
	GU3->(dbSetOrder(1))//GU3_FILIAL+GU3_CDEMIT
	If GU3->(dbSeek(xFilial('GU3')+cCdTrp))
		If GU3->GU3_TRANSP != "1"
			If lMsg
				Help( ,, 'HELP',, "Transportadora Inválida. ", 1, 0,)
			EndIf
			Return .F.
		EndIf
		If GU3->GU3_REDESP != "1" .And. SuperGetMV("MV_TREDESP",, "1") == "3"
			If lMsg
				Help( ,, 'HELP',, "Informe uma transportadora redespachante. ", 1, 0,)
			EndIf
			Return .F.
		EndIf
	Else
		If lMsg
			Help( ,, 'HELP',, "Transportadora Inválida. ", 1, 0,)
		EndIf
		Return .F.
	EndIf
	
Return .T.
/*-------------------------------------------------------------------                                                                           
{Protheus.doc}ValTrePago
Valida se trecho pode ser pago

@author Amanda Rosa Vieira
@since 22/06/2016
@version 1.0
-------------------------------------------------------------------*/ 
Static Function ValTrePago(cPago,cCdTrp)
	If !Empty(cCdTrp) .And. cPago == "Sim"
		If Posicione("GU3",1,xFilial("GU3")+cCdTrp,"GU3_AUTON") == "1"
			Help( ,, 'HELP',, "Só é permitido incluir proprietário autônomo em trecho pago, quando for o primeiro trecho", 1, 0,)
			Return .F. 
		EndIf
	EndIf
Return .T.

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE050VLSE
Valida coerência entre sentido do documento e tipo de frete.

@sample
GFE050VLSE()

@author Amanda Vieira
@since 29/06/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Function GFE050VLSE(cCdTpDc,cEmisDc,cSerDc,cNrDc,cPago,cMsgErro)
	Local cQuery    := ""
	Local lRet      := .T.
	Local lCIFSaida := .F.	//Valida a existencia de um trecho pago em um Doc Carga Saida CIF     
	Local lFOBSaida := .T.	//Valida a existencia de um trecho pago em um Doc Carga Saida FOB     
	Local lCIFEnt   := .T.	//Valida a existencia de um trecho pago em um Doc Carga Entrada CIF   
	Local lFOBEnt   := .F.	//Valida a existencia de um trecho pago em um Doc Carga Entrada FOB  
	
	Default cMsgErro  := ""

	cTpDcSent := Posicione("GV5",1,xFilial("GV5")+cCdTpDc,"GV5_SENTID")
			
	cQuery := " SELECT GWU_PAGAR,GWU_SEQ,GWU_DTENT FROM "+RetSqlName('GWU') 
	cQuery += "  WHERE GWU_FILIAL = '"+xFilial('GWU')+"'"
  	cQuery += "    AND GWU_CDTPDC = '"+cCdTpDc+"'"
  	cQuery += "    AND GWU_EMISDC = '"+cEmisDc+"'"
  	cQuery += "    AND GWU_SERDC  = '"+cSerDc+"'"
  	cQuery += "    AND GWU_NRDC   = '"+cNrDc+"'"
  	cQuery += "    AND D_E_L_E_T_ = ' '"
  	cQuery := ChangeQuery(cQuery)
  	cAliasGWU := GetNextAlias()
  	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasGWU,.F.,.T.)
  	
  	While (cAliasGWU)->(!EoF()) 			
		//Validação existente no programa GFEA044	
		lPagar := (cAliasGWU)->GWU_PAGAR == '1' .Or. cPago == '1'  //Idica se o trecho é pago ou se será incluído um trecho pago
		If cTpDcSent == '2' // Doc Carga com sentido Saida
			//Doc Carga Sentido Saida e CIF deve conter ao menos 1 trecho pago
			If GW1->GW1_TPFRET $ '12' .And. lPagar
				lCIFSaida := .T.
			//Doc Carga Sentido Saida e FOB não deve ter trechos pagos
		    ElseIf GW1->GW1_TPFRET $ '34' .And. lPagar
		    	lFOBSaida := .F.
		    EndIf
		ElseIf cTpDcSent == '1' // Doc Carga com sentido Entrada
			// Doc Carga com sentido Entrada e CIF não deve ter trechos pagos
		    If GW1->GW1_TPFRET $ '12' .And. lPagar
			 	lCIFEnt := .F.
			 	// Doc Carga com sentido Entrada e FOB deve conter ao menos 1 trecho pago
		   	ElseIf GW1->GW1_TPFRET $ '34' .And. lPagar
		    	lFOBEnt := .T.
			EndIf
		EndIf
		(cAliasGWU)->(dbSkip())
	EndDo
	(cAliasGWU)->(dbCloseArea())
	
	//Mensagens de erro referentes a validação do tipo de Doc Carga e os trechos
	If !lCIFSaida .And. GW1->GW1_TPFRET $ '12' .And. cTpDcSent == '2'
		cMsgErro := 'Deve haver, pelo menos um, trecho com Pagar "Sim" quando o Tipo do Frete for "CIF" ou "CIF Redesp" e o sentido do documento for "Saida".' 
		lRet  := .F.
	ElseIf !lFOBSaida .And. GW1->GW1_TPFRET $ '34' .And. cTpDcSent == '2'
		cMsgErro := 'Não pode haver trechos com Pagar "Sim" quando o Tipo do Frete for "FOB" ou "FOB Redesp" e o sentido do documento for "Saida".' 
		lRet  := .F.
	ElseIf !lCIFEnt .And. GW1->GW1_TPFRET $ '12'  .And. cTpDcSent == '1'
		cMsgErro := 'Não pode haver trechos com Pagar "Sim" quando o Tipo do Frete for "CIF" ou "CIF Redesp" e o sentido do documento for "Entrada".' 
		lRet  := .F.
	ElseIf !lFOBEnt  .And. GW1->GW1_TPFRET $ '34'  .And. cTpDcSent == '1'
		cMsgErro := 'Deve haver, pelo menos um, trecho com Pagar "Sim" quando o Tipo do Frete for "FOB" ou "FOB Redesp" e o sentido do documento for "Entrada".' 
		lRet  := .F.
	EndIf
	
Return lRet

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} VldNrCid
Valida cidade destino

@sample
VldNrCid()

@author Pedro E Scandolara
@since 30/11/2018
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function VldNrCid(cNrCidd,lMsg)
	Default lMsg := .T.

	dbSelectArea("GU7")
	GU7->(dbSetOrder(1)) //GU7_FILIAL+GU7_NRCID
	
	If GU7->(!dbSeek(xFilial("GU7")+cNrCidd))
		If lMsg
			Help( ,, 'HELP',, "Cidade Inválida. ", 1, 0,)
		EndIf
		Return .F.
	EndIf
Return .T.
/*--------------------------------------------------------------------------------------------------
