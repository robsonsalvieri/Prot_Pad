#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}
Garação de arquivo .txt de Faturas de Frete para testes importação EDI

@author Ana Claudia da Silva
@since 07/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
User Function GFES004()
	Local oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GW6")
	oBrowse:SetMenuDef("GFES004")
	oBrowse:SetDescription("Faturas de Frete")

	oBrowse:AddLegend("GW6_SITAPR == '1'", "BLACK" , "Recebida")
	oBrowse:AddLegend("GW6_SITAPR == '2'", "RED"   , "Bloqueado")
	oBrowse:AddLegend("GW6_SITAPR == '3'", "GREEN" , "Aprovada Sistema")
	oBrowse:AddLegend("GW6_SITAPR == '4'", "BLUE"  , "Aprovada Usuario")

	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Gerar .TXT" ACTION "GFES04TXT()"   OPERATION 11  ACCESS 0

Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDEF---------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()

	Local oModel
	Local oStruGW3 := FWFormStruct( 1, 'GW3', /*bAvalCampo*/, /*lViewUsado*/ ) 
	Local oStruGWJ := FWFormStruct( 1, 'GWJ', /*bAvalCampo*/, /*lViewUsado*/ ) 
	Local oStruGW7 := FWFormStruct( 1, 'GW7', /*bAvalCampo*/, /*lViewUsado*/ )
	
	oModel := MPFormModel():New('GFES004', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)

	oModel:AddFields('GFES004_GW6', , FWFormStruct(1,'GW6'),/*bPre*/,/*bPost*/,/*bLoad*/)  

	oModel:AddGrid('GFES004_GW3','GFES004_GW6',oStruGW3,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid('GFES004_GWJ','GFES004_GW6',oStruGWJ,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid('GFES004_GW7','GFES004_GW6',oStruGW7,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:SetOptional('GFES004_GW3', .T. )
	oModel:SetOptional('GFES004_GWJ', .T. )

	oModel:SetRelation('GFES004_GW3',{{'GW3_FILFAT','GW6_FILIAL'},{'GW3_EMIFAT','GW6_EMIFAT'},{'GW3_SERFAT','GW6_SERFAT'},{'GW3_NRFAT','GW6_NRFAT'},{'GW3_DTEMFA','GW6_DTEMIS'}},'GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF')
	oModel:SetRelation('GFES004_GWJ',{{'GWJ_FILFAT','GW6_FILIAL'},{'GWJ_EMIFAT','GW6_EMIFAT'},{'GWJ_SERFAT','GW6_SERFAT'},{'GWJ_NRFAT','GW6_NRFAT'},{'GWJ_DTEMFA','GW6_DTEMIS'}},'GWJ_FILIAL+GWJ_NRPF')
	oModel:SetRelation('GFES004_GW7',{{'GW7_FILIAL','GW6_FILIAL'},{'GW7_EMIFAT','GW6_EMIFAT'},{'GW7_SERFAT','GW6_SERFAT'},{'GW7_NRFAT','GW6_NRFAT'},{'GW7_DTEMIS','GW6_DTEMIS'}},'GW7_SEQ')	

Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()

	Local oModel := FWLoadModel('GFES004')
	Local oView  := Nil
	Local oStructGW6 := FWFormStruct(2,'GW6')
	Local oStructGWJ := FWFormStruct(2,'GWJ')
	Local oStructGW3 := FWFormStruct(2,'GW3')
	Local oStructGW7 := FWFormStruct(2,'GW7')

	oStructGW7:RemoveField("GW7_FILIAL")
	oStructGW7:RemoveField("GW7_EMIFAT")
	oStructGW7:RemoveField("GW7_SERFAT")
	oStructGW7:RemoveField("GW7_NRFAT")
	oStructGW7:RemoveField("GW7_DTEMIS")

	oStructGW6:AddGroup("GrpGrl", "Geral", "1", 2)
	oStructGW6:AddGroup("GrpVal", "Valores", "1", 2)
	oStructGW6:AddGroup("GrpImp", "Impostos", "1", 2)
	oStructGW6:AddGroup("GrpObs", "Observações", "1", 2)

	oStructGW6:AddGroup("GrpBlq", "Bloqueio", "2", 2)
	oStructGW6:AddGroup("GrpApr", "Aprovação", "2", 2)
	oStructGW6:AddGroup("GrpInt", "Integração", "2", 2)

	oStructGW6:SetProperty("GW6_EMIFAT", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_NMEMIT", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_SERFAT", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_NRFAT" , MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_DTEMIS", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_DTCRIA", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_DTVENC", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_ORIGEM", MVC_VIEW_GROUP_NUMBER, "GrpGrl")
	oStructGW6:SetProperty("GW6_SITAPR", MVC_VIEW_GROUP_NUMBER, "GrpGrl")

	oStructGW6:SetProperty("GW6_VLFATU", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStructGW6:SetProperty("GW6_VLDESC", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	oStructGW6:SetProperty("GW6_VLJURO", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	If GFXCP12118("GW6_DINDEN")
		oStructGW6:SetProperty("GW6_DINDEN", MVC_VIEW_GROUP_NUMBER, "GrpVal")
	EndIf
	oStructGW6:SetProperty("GW6_VLISS" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_VLISRE", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_DSISCD", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_DSISCL", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_VLICMS", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_VLICRE", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_DSICCD", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_DSICCL", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_DSESPF", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_PRNAT" , MVC_VIEW_GROUP_NUMBER, "GrpImp")
	oStructGW6:SetProperty("GW6_MATREX", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	If GFXCP12130("GW6_VLIRRF") .And. GFXCP12130("GW6_NATURE")
		oStructGW6:SetProperty("GW6_VLIRRF", MVC_VIEW_GROUP_NUMBER, "GrpImp")
		oStructGW6:SetProperty("GW6_NATURE", MVC_VIEW_GROUP_NUMBER, "GrpImp")
	EndIf

	oStructGW6:SetProperty("GW6_OBS"   , MVC_VIEW_GROUP_NUMBER, "GrpObs")

	oStructGW6:SetProperty("GW6_DTBLOQ", MVC_VIEW_GROUP_NUMBER, "GrpBlq")
	oStructGW6:SetProperty("GW6_HRBLOQ", MVC_VIEW_GROUP_NUMBER, "GrpBlq")
	oStructGW6:SetProperty("GW6_USUBLO", MVC_VIEW_GROUP_NUMBER, "GrpBlq")
	oStructGW6:SetProperty("GW6_MOTBLO", MVC_VIEW_GROUP_NUMBER, "GrpBlq")

	oStructGW6:SetProperty("GW6_DTAPR" , MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStructGW6:SetProperty("GW6_HRAPR" , MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStructGW6:SetProperty("GW6_USUAPR", MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStructGW6:SetProperty("GW6_MOTDES", MVC_VIEW_GROUP_NUMBER, "GrpApr")

	oStructGW6:SetProperty("GW6_SITFIN", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW6:SetProperty("GW6_DTFIN" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW6:SetProperty("GW6_HRFIN" , MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW6:SetProperty("GW6_USUFIN", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	oStructGW6:SetProperty("GW6_MOTFIN", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	If GFXCP12127("GW6_DTLIQD")
		oStructGW6:SetProperty("GW6_DTLIQD", MVC_VIEW_GROUP_NUMBER, "GrpInt")
	EndIf

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField('GFES004_GW6' , oStructGW6, /*cLinkID*/ )

	oView:AddGrid( 'GFES004_GWJ' , oStructGWJ )
	oView:AddGrid( 'GFES004_GW3' , oStructGW3 )
	oView:AddGrid( 'GFES004_GW7' , oStructGW7 )

	oView:CreateHorizontalBox('MASTER' , 55 )
	oView:CreateHorizontalBox('DETAILFOLDE' , 45 )
	oView:CreateHorizontalBox('DETAILNETO1' , 100,,,'IDFOLDER01','IDSHEET01')
	oView:CreateHorizontalBox('DETAILNETO2' , 100,,,'IDFOLDER01','IDSHEET02')
	oView:CreateHorizontalBox('DETAILNETO3' , 100,,,'IDFOLDER01','IDSHEET03')

	oView:CreateFolder('IDFOLDER01','DETAILFOLDE') 
	oView:AddSheet('IDFOLDER01','IDSHEET01','Pré-Fatura')
	oView:AddSheet('IDFOLDER01','IDSHEET02','Documentos de Frete')
	oView:AddSheet('IDFOLDER01','IDSHEET03',"Rateio Contábil") 

	oView:SetOwnerView('GFES004_GW6' , 'MASTER')
	oView:SetOwnerView('GFES004_GWJ' , 'DETAILNETO1')   
	oView:SetOwnerView('GFES004_GW3' , 'DETAILNETO2')   
	oView:SetOwnerView('GFES004_GW7' , 'DETAILNETO3') 

	// oView:AddUserButton("Cons. Doc. Frete", "MAGIC_BMP", {|oView| GFEC070CDC(oView)}, ) 
	// oView:AddUserButton("Cons. Pré Fat."   , "MAGIC_BMP", {|oView| GFEC070CCL(oView)}, ) 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES04TXT
Montagem de arquivo .txt com base nos parametros do fonte GFEC070

@author Ana Claudia da Silva
@since 03/10/13
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFES04TXT()

	Local nHandle
	Local cFile
	Local iVALOR := 0   // Valor dos Itens	
	Local cNrDoc1  
	Local cNrDoc   
	Local cSrDoc    

	If Pergunte("GFEA116",.T.)


		//Informações da Nota
		cCdEmit   := POSICIONE("GU3",1,xFilial("GU3")+GW6->GW6_EMIFAT,"GU3_IDFED")
		cNmEmit   := POSICIONE("GU3",1,xFilial("GU3")+GW6->GW6_EMIFAT,"GU3_NMEMIT")
		cSrNf     := GW6->GW6_SERFAT
		cNrNf1    := VAL(GW6->GW6_NRFAT)
		cNrNf     := STRZERO(cNrNf1, 10, 0)
		cNmRem    := POSICIONE("GU3",1,xFilial("GU3")+GW3->GW3_CDREM ,"GU3_NMEMIT")
		cNmDest   := POSICIONE("GU3",1,xFilial("GU3")+GW3->GW3_CDDEST,"GU3_NMEMIT")

		//Hora Importação
		chrmn     := Time()
		cHora     := SUBSTR(chrmn,1,2)
		cMin      := SUBSTR(chrmn,4,2)

		//Data Emissão
		cdata     := DTOC(GW6->GW6_DTEMIS)
		cDataD    := SUBSTR(cdata,1,2)
		cDataM    := SUBSTR(cdata,4,2)
		cDataA    := SUBSTR(cdata,9,2)
		cDataA1   := SUBSTR(cdata,7,4)

		//Data Vencimento

		cdtvenc   := DTOC(GW6->GW6_DTVENC)
		cDtVencD  := SUBSTR(cdtvenc,1,2)
		cDtVencM  := SUBSTR(cdtvenc,4,2)
		cDtVencA  := SUBSTR(cdtvenc,7,4)

		//Valores
		cValor    := PADL(Alltrim(Transform((GW6->GW6_VLFATU*100), '@R 999999999999999')),15,"0")

		cVlJuro   := PADL(Alltrim(Transform((GW6->GW6_VLJURO*100), '@R 999999999999999')),15,"0")

		cVlDesc   := PADL(Alltrim(Transform((GW6->GW6_VLDESC*100), '@R 999999999999999')),15,"0")

		cVlICMS   := PADL(Alltrim(Transform((GW6->GW6_VLICMS*100), '@R 999999999999999')),15,"0")




		//Filial Emissora Doc Cobrança
		cFil352  := "REC"
		cNumCid  := POSICIONE("GU3",1,xFilial("GU3")+GW6->GW6_EMIFAT,"GU3_NRCID")
		cFil353  := POSICIONE("GU7",1,xFilial("GU7")+cNumCid,"GU7_CDUF")

		cDiretorio  := AllTrim(MV_PAR04)
		cFile := cDiretorio + "\"+ "DocCob"+AllTrim(cNrNf)+".TXT"


		nHandle  := fCreate(cFile)
		If nHandle  == -1
			MsgStop("Falha ao criar arquivo - erro "+str(ferror()))
			Return
		Endif

		fWrite(nHandle ,"000" + PADR( cNmRem, 35 )+ PADR( cNmDest, 35 )+ PADR( cDataD, 2 )+ PADR( cDataM, 2 )+ PADR( cDataA, 2 )+ PADR( cHora, 2 )+ PADR( cMin, 2 ) + "COB" + PADR( cDataD, 2 )+ PADR( cDataM, 2 )+ PADR( cHora, 2 )+ PADR( cMin, 2 ) + "0"  + PADR( " ", 75 )+ CRLF)
		fWrite(nHandle ,"350" + "COBRA" + PADR( cDataD, 2 )+ PADR( cDataM, 2 )+ PADR( cHora, 2 )+ PADR( cMin, 2 ) + "0" + PADR( " ", 153 )+ CRLF )
		fWrite(nHandle ,"351" + PADR( cCdEmit, 14 )+ PADR( cNmEmit, 40 )+ PADR( " ", 113 )+ CRLF )
		fWrite(nHandle ,"352" + PADR( cFil352, 10 )+ "0"+ PADR( cSrNf, 3 )+ PADR( cNrNf, 10 ) + PADR( cDataD, 2 )+ PADR( cDataM, 2 )+ PADR( cDataA1, 4 )+ PADR( cDtVencD, 2 )+ PADR( cDtVencM, 2 )+ PADR( cDtVencA, 4 )+  PADL( cValor, 15 )+ "BCO" +  PADL( cVlICMS, 15 ) +  PADL( cVlJuro, 15 ) + PADR( cDtVencD, 2 )+ PADR( cDtVencM, 2 )+ PADR( cDtVencA, 4 )+  PADL( cVlDesc, 15 )  + "Banco de Cobrança TOTVS"  + PADR( " ", 29 )+ "I" + PADR( " ", 3 )+ CRLF)
		
		//Seleciona um ou mais documentos de carga relacionados


        //Doc Frete
		dbSelectArea("GW3")
		GW3->( dbSetOrder(8) )
		If GW3->( dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS)) )
			While !GW3->( Eof() ) .AND. ;
				GW3->GW3_FILFAT == GW6->GW6_FILIAL 		.AND. ;
				GW3->GW3_EMIFAT == GW6->GW6_EMIFAT 		.AND. ;
				GW3->GW3_SERFAT == GW6->GW6_SERFAT 		.AND. ;
				GW3->GW3_NRFAT  == GW6->GW6_NRFAT  		
					
				cNrDoc1   := PADL(Alltrim(Transform((GW3->GW3_NRDF), '@R 9999999999999999')),16,"0")
				cNrDoc    := SUBSTR(cNrDoc1,9,16)
				cSrDoc    := GW3->GW3_SERDF
				fWrite(nHandle ,"353" + PADR( cFil353, 10 )+ PADR( cSrDoc, 5 ) + PADR( cNrDoc, 12 )+ PADR( " ", 140 ) + CRLF )

	        	dbSelectArea("GW4")
				dbSetOrder(1)
				If dbSeek(xFilial("GW4")+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF+DTOS(GW3->GW3_DTEMIS))
					While !GW4->( Eof() ) .and. (GW4->GW4_NRDF == GW3->GW3_NRDF)
					    iVALOR:=0
						dbSelectArea("GW1")
						dbSetOrder(1)
						If dbSeek(xFilial("GW1")+GW4->GW4_TPDC+GW4->GW4_EMISDC+GW4->GW4_SERDC+GW4->GW4_NRDC)
							dbSelectArea("GW8")
							GW8->( dbSetOrder(1) )
							GW8->( dbSeek(xFilial("GW8") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
							While !GW8->( Eof() ) .And. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .And. GW8->GW8_EMISDC == GW1->GW1_EMISDC .And. GW8->GW8_SERDC == GW1->GW1_SERDC .And. GW8->GW8_NRDC == GW1->GW1_NRDC					
						  		iVALOR:= iVALOR + GW8->GW8_VALOR				  		
								GW8->( dbSkip() )
							Enddo
						endif 
						cValordc := PADL(Alltrim(Transform((iVALOR*100), '@R 999999999999999')),15,"0")
						cSrDC    := GW4->GW4_SERDC
						cNrDc1   := PADL(Alltrim(Transform((GW4->GW4_NRDC), '@R 9999999999999999')),16,"0")
						cNrDc    := SUBSTR(cNrDc1,9,16)
						cDataDc  := DTOC(GW4->GW4_DTEMIS)
						cDtD     := SUBSTR(cDataDc,1,2)
						cDtM     := SUBSTR(cDataDc,4,2)
						cDtA1    := SUBSTR(cDataDc,7,4)
						nPeso    := PADL(Alltrim(Transform((GW3->GW3_PESOR*100), '@R 9999999')),7,"0")
						fWrite(nHandle ,"354" + PADR( cSrDc, 3 ) + PADR( cNrDc, 8 )+ PADR( cDtD, 2 )+ PADR( cDtM, 2 )+ PADR( cDtA1, 4 )+ PADR( nPeso, 7 ) +  PADL( cValordc, 15 )+ CRLF )			
						GW4->( dbSkip() )
					Enddo
				EndIf
				GW3->( dbSkip() )
			Enddo
 		EndIf
 		
		Msginfo("Arquivo criado:" + cFile)

		IF !FCLOSE(nHandle)
	        MsgAlert("Erro ao fechar arquivo. Erro número: " + STR(FERROR()))
		ENDIF

	Else
		Return .F.
	EndIf
Return
