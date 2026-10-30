#INCLUDE "GFEC055.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEC055

Consulta de Pré-faturas de frete

@author Jorge Matos Valcanaia
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEC055()
Local oBrowse
Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GWJ")								// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEC055")				  		// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)	    				// Descrição do browse //"Consulta Pré-faturas"

oBrowse:AddLegend( "GWJ_SIT=='1'", "GRAY" , STR0002 ) // Legenda //"Pendente"
oBrowse:AddLegend( "GWJ_SIT=='2'", "BLUE" , STR0003 ) // Legenda //"Enviada"
oBrowse:AddLegend( "GWJ_SIT=='3'", "GREEN", STR0004 ) // Legenda //"Confirmada"
oBrowse:AddLegend( "GWJ_SIT=='4'", "RED"  , STR0005 ) // Legenda //"Cancelada"

oBrowse:Activate()                                       

Return(Nil)  

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0006 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEC055" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEC055" OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE "Visualizar Anexo" ACTION "MsDocument('GWJ',GWJ->(RecNo()), 2)" OPERATION 2  ACCESS 0 

Return aRotina   

//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local nCont
Local oStructGWJ := FWFormStruct(1, "GWJ")
Local oStructGWF := FWFormStruct(1, "GWF")  
Local oStructGWK := FWFormStruct(1, "GWK") 
Local oStructGW1 := FWFormStruct(1, "GW1", { |cCampo| BscStrGW1( cCampo ) } )
Local oStructGW6 := FWFormStruct(1, "GW6", { |cCampo| BscStrGW6( cCampo ) } ) 

oStructGWF:AddField(STR0011, STR0012, "GWF_VALFRT", "N", 9, 2/*nDECIMAL*/, /*bVALID*/, /*bWHEN*/, , /*lOBRIGAT*/, ;
					{|| VLTOTFRET()}/*bINIT*/, /*lKEY*/, /*lNOUPD*/, /*lVIRTUAL*/)

oStructGWF:AddField(STR0011, STR0012, "VLFRTCRD", "N", 9, 2/*nDECIMAL*/, /*bVALID*/, /*bWHEN*/, , /*lOBRIGAT*/, ;
					{|| VLFRTPROV(,,"2")}/*bINIT*/, /*lKEY*/, /*lNOUPD*/, /*lVIRTUAL*/)
					
oStructGWF:AddField(STR0011, STR0012, "VLFRTIMP", "N", 9, 2/*nDECIMAL*/, /*bVALID*/, /*bWHEN*/, , /*lOBRIGAT*/, ;
					{|| VLFRTPROV(,,"3")}/*bINIT*/, /*lKEY*/, /*lNOUPD*/, /*lVIRTUAL*/)
					
For nCont := 1 To Len(oStructGWF:aFields)
	If oStructGWF:aFields[nCont][3] != "GWF_VALFRT" .And. !oStructGWF:aFields[nCont][14] .And. oStructGWF:aFields[nCont][3] != "VLFRTCRD" .And. oStructGWF:aFields[nCont][3] != "VLFRTIMP"
		If oStructGWF:aFields[nCont][4] == "C"
			oStructGWF:SetProperty(oStructGWF:aFields[nCont][3], MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:="",FWCloseCpo(a,b,c,.T.),lRetorno } )
	    ElseIf oStructGWF:aFields[nCont][4] == "N"
	    	oStructGWF:SetProperty(oStructGWF:aFields[nCont][3], MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:=0,FWCloseCpo(a,b,c,.T.),lRetorno } )
	    ElseIf oStructGWF:aFields[nCont][4] == "D"
	    	oStructGWF:SetProperty(oStructGWF:aFields[nCont][3], MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:=CToD("  /  /    "),FWCloseCpo(a,b,c,.T.),lRetorno } )
	    EndIf
	EndIf
Next nCont

oModel := MPFormModel():New("GFEC055", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields("GFEC055_GWJ", Nil, oStructGWJ,/*bPre*/,/*bPost*/,/*bLoad*/)

oModel:AddGrid('GFEC055_GWF','GFEC055_GWJ',oStructGWF,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation('GFEC055_GWF',{{'GWF_FILPRE','GWJ_FILIAL'},{'GWF_NRPREF' ,'GWJ_NRPF' }},'GWF_FILIAL+GWF_NRCALC')

oModel:AddGrid('GFEC055_GW1','GFEC055_GWJ', oStructGW1, , , /*bPre*/, /*bPost*/, {|oModelGW1| GFEC055DOC(oModelGW1)}/*bLoad*/) 
oModel:SetRelation("GFEC055_GW1",{{"GW1_FILIAL","GWH_FILIAL"}},"GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC")
oModelGW1 = oModel:GetModel("GFEC055_GW1")
oModelGW1:SetDescription("GW1")

oModel:AddGrid('GFEC055_GW6','GFEC055_GWJ',oStructGW6,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation('GFEC055_GW6',{{'GW6_FILIAL','GWJ_FILFAT'},{'GW6_EMIFAT' ,'GWJ_EMIFAT' },{'GW6_SERFAT' ,'GWJ_SERFAT' },{'GW6_NRFAT' ,'GWJ_NRFAT' },{'GW6_DTEMIS' ,'GWJ_DTEMFA' }},'GW6_FILIAL+GW6_EMIFAT+GW6_SERFAT+GW6_NRFAT')

oModel:AddGrid('GFEC055_GWK','GFEC055_GWJ',oStructGWK,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation('GFEC055_GWK',{{'GWK_FILIAL','GWJ_FILIAL'},{'GWK_NRPF' ,'GWJ_NRPF' }},'GWK_SEQ')

oModel:AddCalc("GFEC55CALC", "GFEC055_GWJ", "GFEC055_GWF", "GWF_VALFRT" , "CALC_VALFRT", "SUM")
oModel:AddCalc("GFEC55CALC", "GFEC055_GWJ", "GFEC055_GWF", "VLFRTCRD" , "CALC_SCRD", "SUM")
oModel:AddCalc("GFEC55CALC", "GFEC055_GWJ", "GFEC055_GWF", "VLFRTIMP" , "CALC_SIMP", "SUM")
  
Return oModel                      

//-------------------------------------------------------------------   

Function VLFRTPROV(cGWF_FILIAL, cGWF_NRCALC, cMV_PROVCON)
	Local nVlTotal 	:= 10
	Local aAreaGWF
	
	Local lSubICMS 	:= .F.
	Local lSubPC 		:= .F.
	
	Default cMV_PROVCON := SuperGetMv("MV_PROVCON",.F., "1")
	
	dbSelectArea("GWF")
	
	If cGWF_FILIAL == Nil .And. cGWF_NRCALC == Nil
		cGWF_FILIAL := GWF->GWF_FILIAL
		cGWF_NRCALC := GWF->GWF_NRCALC
	Else
		aAreaGWF := GWF->(GetArea())
		GWF->(dbSetOrder(1))
		GWF->(dbSeek(cGWF_FILIAL + cGWF_NRCALC))
	EndIf
	
	nVlTotal := VLTOTFRET()
	
	If nVlTotal > 0
		// "1=Despesa Total","2=Despesa menos Impostos Recuperáveis","3=Despesa menos Impostos","4=Despesa e Impostos Recuperáveis"
		If cMV_PROVCON $ "2;3"
			lSubICMS 	:= If(cMV_PROVCON == "3", .T., GWF->GWF_CRDICM == "1")
			lSubPC 	:= If(cMV_PROVCON == "3", .T., GWF->GWF_CRDPC == "1")
			
			If lSubICMS
				nVlTotal -= GWF->GWF_VLICMS
			EndIf
			
			If lSubPC
				nVlTotal -= GWF->GWF_VLPIS
				nVlTotal -= GWF->GWF_VLCOFI
			EndIf
		EndIf
	EndIf
	
	If !Empty(aAreaGWF)
		RestArea( aAreaGWF )
	EndIf
Return nVlTotal

Static Function ViewDef()

Local oModel := FWLoadModel("GFEC055")  
Local oStructGWJ := FWFormStruct(2, "GWJ")
Local oStructGWF := FWFormStruct(2, "GWF")  
Local oStructGWK := FWFormStruct(2, "GWK") 
Local oStructGW1 := FWFormStruct(2, "GW1", { |cCampo| BscStrGW1( cCampo ) } )
Local oStructGW6 := FWFormStruct(2, "GW6", { |cCampo| BscStrGW6( cCampo ) } )
Local oStructCal := FWCalcStruct( oModel:GetModel("GFEC55CALC") )
Local oView  := Nil
Local aCampGWF := {"GWF_FILIAL","GWF_NRCALC","GWF_TRANSP","GWF_NMTRP","GWF_EMIREM","GWF_NMREM","GWF_EMIDES","GWF_NMDEST","GWF_EMIRED","GWF_NMRED",;
					  "GWF_EMIPAG","GWF_NMPAG","GWF_TPCALC","GWF_VALFRT","GWF_ORIGEM","GWF_TPFRET","GWF_FINCAL","GWF_CIDORI","GWF_NMCIOR","GWF_CIDDES",;
					  "GWF_NMCIDE","GWF_ENDENT","GWF_BAIENT","GWF_CIDENT","GWF_DTCRIA","GWF_HRCRIA","GWF_USUCRI","GWF_DTPREN","GWF_HRPREN","GWF_CARREG",;
					  "GWF_NRROM","GWF_VLAJUS","GWF_TPTRIB","GWF_BASISS","GWF_PCISS","GWF_VLISS","GWF_BASICM","GWF_PCICMS","GWF_PCREIC","GWF_VLICMS",;
					  "GWF_ICMRET","GWF_BAPICO","GWF_VLPIS","GWF_VLCOFI","GWF_FILPRE","GWF_NRPREF","GWF_NRCONT","GWF_IDFRVI","GWF_AGRUP","GWF_SEQTRE",;
					  "GWF_OBS","GWF_IMPOST"}
Local nI
Local nUltOrd

oStructGWK:RemoveField("GWK_NRPF")

oStructGWF:AddField("GWF_VALFRT", "", STR0011, "", {STR0012}, "GET", "@E 999,999,999.99", /*bPICTVAR*/, /*cLOOKUP*/, .F., /*"1"*/, /*cGRUP*/, /*aListaCombo*/, /*nMAXLENCOMBO*/, /*"1"*/, /*lVIRTUAL*/, /*cPICTVAR*/, /*lINSERTLIN*/)

For nI := 1 To Len(aCampGWF)
	If nI < 10
		oStructGWF:SetProperty( aCampGWF[nI], MVC_VIEW_ORDEM, '0' + Alltrim(STR(nI)))
	Else
		oStructGWF:SetProperty( aCampGWF[nI], MVC_VIEW_ORDEM, Alltrim(STR(nI)))
	EndIf
Next

nUltOrd := nI

For nI := 1 To Len(oStructGWF:aFields)
	If ASCAN(aCampGWF, oStructGWF:aFields[nI][1]) == 0 .And. Alltrim(oStructGWF:aFields[nI][1]) != "GWF_FILIAL"
		If nUltOrd < 10
			oStructGWF:SetProperty( oStructGWF:aFields[nI][1], MVC_VIEW_ORDEM, '0' + Alltrim(STR(nUltOrd)))
		Else
			oStructGWF:SetProperty( oStructGWF:aFields[nI][1], MVC_VIEW_ORDEM, Alltrim(STR(nUltOrd)))
		EndIf
		nUltOrd := nUltOrd + 1
	EndIf
Next

// Ajuste das propriedades dos campos de calculo
oStructCal:SetProperty("CALC_VALFRT", MVC_VIEW_TITULO   , STR0009) 
oStructCal:SetProperty("CALC_VALFRT", MVC_VIEW_VIRTUAL  , .T.) 
oStructCal:SetProperty("CALC_VALFRT", MVC_VIEW_CANCHANGE, .F.) 
oStructCal:SetProperty("CALC_VALFRT", MVC_VIEW_DESCR    , STR0010)

oStructCal:SetProperty("CALC_SCRD", MVC_VIEW_TITULO   , "Valor - Imp. Recebíveis") 
oStructCal:SetProperty("CALC_SCRD", MVC_VIEW_VIRTUAL  , .T.) 
oStructCal:SetProperty("CALC_SCRD", MVC_VIEW_CANCHANGE, .F.) 
oStructCal:SetProperty("CALC_SCRD", MVC_VIEW_DESCR    , "Valor - Impostos Recebíveis")

oStructCal:SetProperty("CALC_SIMP", MVC_VIEW_TITULO   , "Valor - Impostos") 
oStructCal:SetProperty("CALC_SIMP", MVC_VIEW_VIRTUAL  , .T.) 
oStructCal:SetProperty("CALC_SIMP", MVC_VIEW_CANCHANGE, .F.) 
oStructCal:SetProperty("CALC_SIMP", MVC_VIEW_DESCR    , "Valor - Impostos")

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddUserButton(STR0019, "", {|oView| GFEC55DTLC(oView)}, STR0020)
oView:AddUserButton(STR0016, "", {|oView| GFEC55DTLD(oView)}, STR0018) 
oView:AddUserButton(STR0021, "", {|oView| GFEC55DTLF(oView)}, STR0022)

oView:AddField( "GFEC055_GWJ", oStructGWJ, /*cLinkID*/ )
oView:AddField( "VIEW_CALC", oStructCal, "GFEC55CALC")
oView:AddGrid( "GFEC055_GWF" , oStructGWF )
oView:AddGrid( "GFEC055_GW1" , oStructGW1 ) 
oView:AddGrid( "GFEC055_GW6" , oStructGW6 )             
oView:AddGrid( "GFEC055_GWK" , oStructGWK )

oView:CreateHorizontalBox( "MASTER" , 60,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )   
oView:CreateHorizontalBox( 'DETAIL' , 40 )  

oView:CreateFolder('IDFOLDER01', 'DETAIL')
 
oView:AddSheet('IDFOLDER01', 'IDSHEET01', STR0013) 
oView:AddSheet('IDFOLDER01', 'IDSHEET02', STR0014) 
oView:AddSheet('IDFOLDER01', 'IDSHEET03', STR0015)
oView:AddSheet('IDFOLDER01', 'IDSHEET04', "Rateio Contábil")

oView:CreateHorizontalBox( 'DETAIL1', 77 ,,,'IDFOLDER01','IDSHEET01') 
oView:CreateHorizontalBox( 'DTLCALC', 23 ,,,'IDFOLDER01','IDSHEET01') 
oView:CreateHorizontalBox( 'DETAIL2', 100,,,'IDFOLDER01','IDSHEET02') 
oView:CreateHorizontalBox( 'DETAIL3', 100,,,'IDFOLDER01','IDSHEET03')  
oView:CreateHorizontalBox( 'DETAIL4', 100,,,'IDFOLDER01','IDSHEET04')  

// Associa um View a um box
oView:SetOwnerView( "GFEC055_GWJ" , "MASTER" )   
oView:SetOwnerView( "GFEC055_GWF" , "DETAIL1") 
oView:SetOwnerView( "GFEC055_GW1" , "DETAIL2") 
oView:SetOwnerView( "GFEC055_GW6" , "DETAIL3")
oView:SetOwnerView( "GFEC055_GWK" , "DETAIL4")
oView:SetOwnerView( "VIEW_CALC"   , "DTLCALC") 

Return oView      
  
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BscStrGW1
Criação do objeto Struct 
Uso restrito 

@sample
BscStrGW1( cCampo )

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function BscStrGW1( cCampo )
Local aCampos := {}           
Local lRet   := .F.

aAdd( aCampos, "GW1_FILIAL" )
aAdd( aCampos, "GW1_SERDC " )
aAdd( aCampos, "GW1_NRDC  " )
aAdd( aCampos, "GW1_CDTPDC" )
aAdd( aCampos, "GW1_EMISDC" )
aAdd( aCampos, "GW1_NMEMIS" )
aAdd( aCampos, "GW1_CDREM " )
aAdd( aCampos, "GW1_NMREM " )
aAdd( aCampos, "GW1_CDDEST" )
aAdd( aCampos, "GW1_NMDEST" )

lRet := ( aScan( aCampos, { |x| PadR( cCampo, 10 ) == x } ) > 0 )

Return lRet   

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BscStrGW6
Criação do objeto Struct 
Uso restrito 

@sample
BscStrGW6( cCampo )

@author Felipe M.
@since 14/07/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function BscStrGW6( cCampo )
Local aCampos := {}           
Local lRet   := .F.

aAdd( aCampos, "GW6_FILIAL" )
aAdd( aCampos, "GW6_EMIFAT" )
aAdd( aCampos, "GW6_NMEMIT" )
aAdd( aCampos, "GW6_SERFAT" )
aAdd( aCampos, "GW6_DTEMIS" )
aAdd( aCampos, "GW6_VLFATU" )
aAdd( aCampos, "GW6_VLDESC" )
aAdd( aCampos, "GW6_VLICMS" )
aAdd( aCampos, "GW6_VLICRE" )
aAdd( aCampos, "GW6_VLJURO" )
aAdd( aCampos, "GW6_DTVENC" )
aAdd( aCampos, "GW6_DTCRIA" )
aAdd( aCampos, "GW6_ORIGEM" )
aAdd( aCampos, "GW6_NRFAT " )

lRet := ( aScan( aCampos, { |x| PadR( cCampo, 10 ) == x } ) > 0 )

Return lRet   


/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC040
Insere documentos de carga relacionados a pré-fatura no grid.
Restrito

@sample
GFEC055DOC(oModelGW1)

@author Octávio Augusto Felippe de Macedo
@since 13/01/2011
@version 1.0
---------------------------------------------------------------------------------------------------*/

Static Function GFEC055DOC(oModelGW1)

Local aStruc := {}//Array para armazenar o struct da tabela
Local aRet   := {}//Array de retorno com os regitros. Formato ##array{ #linha{#recno 1, #campos{,,,}}, #linha{#recno 2, #campos{,,,}} }
Local aCmp   := {}
Local nRec   := 1 //Número de registros
Local nCont  := 1

aStruc := oModelGW1:GetStruct()//Struct da tabela

dbSelectArea("GWF")   
dbSetOrder(3)
dbSeek(GWJ->GWJ_FILIAL+GWJ->GWJ_NRPF)
While !Eof() .And. GWJ->GWJ_FILIAL+GWJ->GWJ_NRPF == GWF->GWF_FILPRE+GWF->GWF_NRPREF
	dbSelectArea("GWH")
	dbSetOrder(1)
	dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC)
	While !Eof() .And. GWF->GWF_FILIAL+GWF->GWF_NRCALC == GWH->GWH_FILIAL+GWH->GWH_NRCALC
		dbSelectArea("GW1")
		dbSetorder(1)
		If dbSeek(GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC)
			While nCont <= Len(aStruc:aFields)
				
				If aStruc:aFields[nCont][3] == "GW1_NMEMIS"
					AAdd(aCmp, Posicione("GU3", 1, xFilial("GU3") + GW1->GW1_EMISDC, "GU3_NMEMIT"))
				ElseIf aStruc:aFields[nCont][3] == "GW1_NMREM"
					AAdd(aCmp, Posicione("GU3", 1, xFilial("GU3") + GW1->GW1_CDREM, "GU3_NMEMIT"))
				ElseIf aStruc:aFields[nCont][3] == "GW1_NMDEST"
					AAdd(aCmp, Posicione("GU3", 1, xFilial("GU3") + GW1->GW1_CDDEST, "GU3_NMEMIT"))
				Else
				 	AAdd(aCmp, &("GW1->" + aStruc:aFields[nCont][3]))
				EndIf
			   	
			   	nCont++
			   	
			EndDo
			
			AAdd(aRet,{nRec, aCmp})
			
			aCmp  := {}
			nCont := 1
			nRec++		
		EndIf		
		dbSelectArea("GWH")
		GWH->( dbSkip() )
	EndDo 		
	dbSelectArea("GWF")
	GWF->( dbSkip() )
EndDo

Return aRet

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC55DTLC
Função para visualizar os detalhes do cálculo selecionado
Restrito

@sample
GFEC55DTLC(oView)

@author Octávio Augusto Felippe de Macedo
@since 03/03/2011
@version 1.0
---------------------------------------------------------------------------------------------------*/

Function GFEC55DTLC(oView)
Local oModelGWF := oView:GetModel():GetModel("GFEC055_GWF")
Local nLine := oModelGWF:GetLine()
Local aArea := GWF->( GetArea() )

If oModelGWF:IsEmpty()
	MsgInfo(STR0024, STR0023)
	Return Nil
EndIf

dbSelectArea("GWF")
GWF->( dbSetOrder(1) )
GWF->( dbSeek(FwFldGet("GWF_FILIAL",nLine) + FwFldGet("GWF_NRCALC",nLine)) )
      
FWExecView(STR0017,"GFEC080",1,,{||.T.})

RestArea(aArea)

Return Nil

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC55DTLD
Função para visualizar os detalhes do documento de carga selecionado
Restrito

@sample
GFEC55DTL(oView)

@author Octávio Augusto Felippe de Macedo
@since 03/03/2011
@version 1.0
---------------------------------------------------------------------------------------------------*/

Function GFEC55DTLD(oView)
Local oModelGW1 := oView:GetModel():GetModel("GFEC055_GW1")
Local nLine := oModelGW1:GetLine()
Local aArea := GW1->( GetArea() )

If oModelGW1:IsEmpty()
	MsgInfo(STR0025, STR0023)
	Return Nil
EndIf

dbSelectArea("GW1")
GW1->( dbSetOrder(1) )
GW1->( dbSeek(FwFldGet("GW1_FILIAL",nLine) + FwFldGet("GW1_CDTPDC",nLine) + FwFldGet("GW1_EMISDC",nLine) + FwFldGet("GW1_SERDC",nLine) + FwFldGet("GW1_NRDC",nLine)) )
      
FWExecView(STR0017,"GFEC040",1,,{||.T.})

RestArea(aArea)

Return Nil

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC55DTLF
Função para visualizar os detalhes da Fatura selecionada
Restrito

@sample
GFEC55DTLF(oView)

@author Octávio Augusto Felippe de Macedo
@since 03/03/2011
@version 1.0
---------------------------------------------------------------------------------------------------*/

Function GFEC55DTLF(oView)
	
	Local oModelGW6 := oView:GetModel():GetModel("GFEC055_GW6")
	Local nLine     := oModelGW6:GetLine()
	Local aArea     := GW6->( GetArea() )
	
	If oModelGW6:IsEmpty()
		MsgInfo(STR0026, STR0023)
		Return
	EndIf
	
	dbSelectArea("GW6")
	GW6->( dbSetOrder(1) )
	If GW6->( dbSeek(GW6->GW6_FILIAL + FwFldGet("GW6_EMIFAT", nLine) + FwFldGet("GW6_SERFAT", nLine) + FwFldGet("GW6_NRFAT", nLine) + ;
					 DToS(FwFldGet("GW6_DTEMIS", nLine))) )
	      
		FWExecView(STR0017, "GFEC070", 1,,{|| .T.})
	
	EndIf
	
	RestArea(aArea)

Return
 