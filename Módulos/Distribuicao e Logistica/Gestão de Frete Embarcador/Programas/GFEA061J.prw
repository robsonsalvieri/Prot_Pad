#INCLUDE "PROTHEUS.CH"
#Include "fileio.ch"
#INCLUDE "FWMVCDEF.CH"

Function GFEA061J(nTpOp as numeric)
    Local lRet       as logical
    Local oNewPage   as object
	Local cTargetXml as char
    Local oStepWiz   as object
    Local cName      as char
	Local cTargetLog as char
	Local lSim 		 as logical
	Local lNewXML  	 as logical
	
	Private cAcao      as char
	Private oModelNeg  as object
	Private oModelTRF  as object
	Private oModelCTR  as object
	Private cLogTxt    as char	
	Private nImp       as numeric
	Private oXmlParser as object
	Private lLibre     as Logical

    Private _cAliaGV8  as char
    Private _cAliaGV7  as char
    Private _cAliaGUY  as char
    Private _cAliaGV6  as char
    Private _cAliaGV1  as char
	Private _cAliaGVW  as char
    Private _cAlgv8    as char
    Private _cAlgv7    as char

    _cAliaGV8 := GetNextAlias()
    _cAliaGV7 := GetNextAlias()
    _cAliaGUY := GetNextAlias()
    _cAliaGV6 := GetNextAlias()	
    _cAliaGV1 := GetNextAlias()	
	_cAliaGVW := GetNextAlias()   

	lNewXML := SuperGetMv("MV_IMPTBFR",,.F.)	// .F. - Importa com função anterior, .T. - Importa com função nova

	lSim   := .F.
	lLibre := .F.

	oStepWiz  := FWWizardControl():New()  //Instancia a classe FWWizard

    oStepWiz:ActiveUISteps()

	If IsBlind()
		If nTpOp == 1
			cName      := "Export_Tab"
			cTargetXml := "\spool\"
			lRet := ExpTbXml(cTargetXml, cName)
		ElseIf nTpOp == 2
			cName      := "Import_Tab"
			cTargetXml := "\spool\import_tab.xml"
			cTargetLog := "\spool\"
			lRet := ImpTbXml(cTargetXml, cTargetLog, lSim, lLibre)
		EndIf
	Else
		If nTpOp == 1
			oNewPage := oStepWiz:AddStep("1")
			oNewPage:SetStepDescription("Exportar Tabela")       
			oNewPage:SetConstruction({|Panel, nId |CriarPg(Panel, 1, 1,@cTargetXml, @cName)})
			oNewPage:SetNextAction({|| .T.})
			oNewPage:SetCancelAction({|| Alert("Cancelado Pelo Usuário"), .T.})

			//------------------------------------------------------------    
			// Página 2 - Confirma
			//------------------------------------------------------------
			oNewPage := oStepWiz:AddStep("2")
			oNewPage:SetStepDescription("Confirmar Dados do Arquivo")
			oNewPage:SetConstruction({|Panel, nId | CriarPg(Panel, 2, 1, @cTargetXml, @cName)})
			oNewPage:SetNextAction({|| Processa({|| lRet := ExpTbXml(cTargetXml, cName), "Aguarde, Exportando..."}),  .T.})	

		ElseIf nTpOp == 2
			//------------------------------------------------------------    
			// Página 1 - Importar Tabela de Frete
			//------------------------------------------------------------
			oNewPage := oStepWiz:AddStep("1")
			oNewPage:SetStepDescription("Importar Tabela")       
			oNewPage:SetConstruction({|Panel, nId |CriarPg(Panel, 1, 2,@cTargetXml,,@cTargetLog, @lSim, @lLibre, @lGerLog)})
			oNewPage:SetNextAction({|| ValidaArq(cTargetXml,cTargetLog)})
			oNewPage:SetCancelAction({|| Alert("Cancelado Pelo Usuário"), .T.})

			//------------------------------------------------------------    
			// Página 2 - Confirma
			//------------------------------------------------------------
			lGerLog := .T.

			oNewPage := oStepWiz:AddStep("2")
			oNewPage:SetStepDescription("Confirmar Dados do Arquivo")
			oNewPage:SetConstruction({|Panel, nId | CriarPg(Panel, 2, 2,@cTargetXml,,@cTargetLog, @lSim, @lLibre, @lGerLog)})
			If !lNewXML
				oNewPage:SetNextAction({|| Processa({|| lRet := ImpTbXml(cTargetXml, cTargetLog, lSim, lLibre, lGerLog), IIF(!lSim,"Aguarde, Importando...", "Aguarde, Simulando...")}), .T.})
			Else
				oNewPage:SetNextAction({|| lRet := GFEA061K(cTargetXml, cTargetLog, lSim, lLibre, lGerLog), .T.})
			EndIf
		EndIf

    	oNewPage:SetCancelAction({|| Alert("Cancelado Pelo Usuário"), .T.})

    	oStepWiz:Activate()
	EndIf
    oStepWiz:Destroy(oStepWiz)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CriarPg(oPanel, nId)
Cria páginas do wizard
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriarPg(oPanel, nId , nTpOp, cTarget,cName, cTargetLog, lSim, lLibre, lGerLog)
    Local oTGet1    as object
    Local oTGet2    as object
	Local oTGet3    as object
    Local oTButton1 as object
	Local oTButton2 as object
    Local oTSay1    as object
    Local oTSay2    as object
	Local oTSay3    as object
	Local oTCheck   as object
	Local oTCheck2  as object
	Local oTCheck3	as object
    
    If cName == Nil
        cName := Space(30)
    EndIf   

	If nId == 1
		oTSay1    := TSay():New(90,10,{||"Diretório do Arquivo: "},oPanel,,,,,,.T.,,,200,20) 
		oTGet1    := TGet():New(100,10,{|u| If( PCount() > 0, cTarget := u, cTarget ) } ,oPanel,230,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTarget,,,, )
		
        If nTpOp == 1
			oTGet1    := TGet():New(100,10,{|u| If( PCount() > 0, cTarget := u, cTarget ) } ,oPanel,230,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTarget,,,, )
            oTButton1 := TButton():New(0100.5,248,"Pesquisar",oPanel,{||cTarget := BuscaDir()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
            oTGet2    := TGet():New(60,10,{|u|If( PCount() > 0, cName := u, cName )} ,oPanel,230,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cName,,,, )
            oTSay2    := TSay():New(40,10,{||"Nome do Arquivo: "},oPanel,,,,,,.T.,,,200,20)        

        ElseIf nTpOp == 2
			oTSay3    := TSay():New(40,10,{||"Pesquisar Diretório Arquivo de Log: "},oPanel,,,,,,.T.,,,200,20) 
			oTButton2 := TButton():New(050.5,248,"Pesquisar",oPanel,{||cTargetLog := BuscaDir()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			oTGet3    := TGet():New(50,10,{|u| If( PCount() > 0, cTargetLog := u, cTargetLog ) } ,oPanel,230,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTargetLog,,,, )

			oTButton1 := TButton():New(0100.5,248,"Pesquisar",oPanel,{||cTarget := BuscaArq()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			oTCheck   := TCheckBox():New(120,010,'Simular',{|u| If( PCount() > 0, lSim := u, lSim ) },oPanel,100,210,,,,,,,,.T.,,,)  
			oTCheck2  := TCheckBox():New(120,050,'LibreOffice',{|u| If( PCount() > 0, lLibre := u, lLibre ) },oPanel,100,210,,,,,,,,.T.,,,)       
			oTCheck3  := TCheckBox():New(120,090,'Gera Log?',{|u| If( PCount() > 0, lGerLog := u, lGerLog ) },oPanel,100,210,,,,,,,,.T.,,,)       
        EndIf

	ElseIf nId == 2
        If nTpOp == 1        
            oTSay3    := TSay():New(70,10,{||"O arquivo abaixo será criado: "},oPanel,,,,,,.T.,,,200,20)
            oTSay4    := TSay():New(90,10,{||"" + cTarget+AllTrim(cName) +".xml"},oPanel,,,,,,.T.,,,300,30)
        ElseIf nTpOp == 2
            oTSay3    := TSay():New(70,10,{||"O arquivo abaixo foi selecionado: "},oPanel,,,,,,.T.,,,200,20)
            oTSay4    := TSay():New(90,10,{||"" + cTarget + ""},oPanel,,,,,,.T.,,,300,30)
        EndIf
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaArq()
Busca arquivo
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BuscaArq()
    Local cMask := "Arquivos XML Protheus (*.xml)|*.xml|"
    Local cTarget as char

    cTarget := ALLTRIM(cGetFile(cMask,"Arquivo ",1,"",.T.,nOR(GETF_LOCALHARD, GETF_NETWORKDRIVE),.T.,.T.))
Return cTarget

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaDir()
Busca diretório
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BuscaDir()
    Local cTarget as char

    cTarget := ALLTRIM(cGetFile(,"Diretório ",1,"",.T.,nOR(GETF_LOCALHARD,GETF_RETDIRECTORY) ,.T.,.T.))
Return cTarget

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaArq(cTarget)
Valida arquivo
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidaArq(cTarget,cLog)
    Local lRet := .F.

    If !Empty(cTarget) .AND. File(cTarget)
        If AT(".xml",cTarget) <> 0
            lRet := .T.
        Else        
            MsgAlert("Arquivo Inválido!")
            lRet := .F.   
        EndIf
    Else
        MsgAlert("Arquivo Não Selecionado ou não encontrado!")
        lRet := .F.
    EndIf
    
    If lRet
	    If !Empty(cLog) 
	        lRet := .T.
	    Else
	        MsgAlert("Diretório não informado!")
	        lRet := .F.
	    EndIf    
    EndIf
    
Return lRet

Function GetFileDir(cFullName)
    Local cPath as char
    Local lUnix := IsSrvUnix()
    Local nPos  := Rat( IIf( lUnix, "/", "\" ), cFullName )

    If !( nPos == 0 )
      	cPath := SubStr( cFullName, 1, nPos - 1 )
      	cName := SubStr( cFullName, nPos+1, Len(cFullName))
    Else
      	cPath := ""
      	cName := ""
    EndIf

Return {cPath, cName}

//-------------------------------------------------------------------
/*/{Protheus.doc} LogMessage(cMessage)
Criação de logs durante a importação de tabela de frete
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LogMessage(cMessage)
	cMessage := "[" + cValToChar(Date()) +"]" + "["+cValToChar(Time())+"]"+ " : "+cMessage
Return cMessage

//-------------------------------------------------------------------
/*/{Protheus.doc} RetTpOriDsT(cTp)
Descrição do tipo origem/tipo destino
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function RetTpOriDsT(cTp)
	Local cRet as char

	Do Case
		Case cTp == "0"
			cRet := "0"
		Case cTp $ "1;Cidade"
			cRet := "1"
		Case cTp $ "2;Distancia;Distância"
			cRet := "2"
		Case cTp $ "3;Regiao;Região"
			cRet := "3"
		Case cTp $ "4;Pais/UF;País/UF"
			cRet := "4"
		Case cTp $ "5;Remetente"
			cRet := "5"
		OtherWise
			cRet := Nil
	End
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldOriDst(cOriDst, cTp)
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function VldOriDst(cOriDst, cTp)
	Local cRet as char

	Do Case
		Case cTp == "0"
			cRet := ""
		Case cTp == "1"
			cRet := Posicione("GU7", 1, xFilial("GU7")+cOriDst, 'GU7_NRCID')
		Case cTp == "2"
			cRet := cOriDst
		Case cTp == "3"
			cRet := Posicione("GU9", 1, xFilial("GU9")+cOriDst, 'GU9_NRREG')			
		Case cTp == "4"
			cRet := cOriDst
		Case cTp == "5"
			cRet := Posicione("GU3", 1, xFilial("GU3")+cOriDst, 'GU3_CDEMIT')
		OtherWise
			cRet := Nil
	End

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSimNao(cValue)
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function RetSimNao(cValue)
	Local cRet as char

	Do Case
		Case cValue $ "1;Sim;S"
			cRet := "1"
		Case cValue $ "2;Não;Nao;N"
			cRet := "2"
	End

Return cRet


/*/{Protheus.doc} ExpTbXml()
Cria tela de exportação
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ExpTbXml(cDir, cName)
    Local oExcel     as object
    Local cWorkSheet as char
    Local cTable     as char
    Local aCols      as array
    Local aIdx       as array
	Local aAreaGV9   as array
	Local aAreaGVA   as array
	Local cCdOrig    as char
	Local cDsOrig    as char
	Local cCdDest    as char
	Local cDsDest    as char
	Local aRow       as array
	Local cNrCt      as char
	Local cGU3On     as char
	Local lExclusiva := IF((FWModeAccess("GU3",1) == "E"), .T., .F.)

	Local nRecCount := 0
	Local cCpo      := ""
	Local cJoin     := "%"
	Local cAliasT   := GetNextAlias()

	Local lFRACEX	:= GFXCP2610("GV1_FRACEX")
	Local nFRACEX	:= 0

    cWorkSheet := "Tabela de Frete"
    cTable     := "Tabela"

    oExcel := ExcelGFEA061():New()

	oExcel:AddWorkSheet(cWorkSheet)

    aCols := {"Ação",; 
              "Transportador",;
              "Nm. Transp.",;
              "Nr Tabela",; 
              "Desc. Tabela",; 
              "Nr Negociação",;
              "Nr Contrato",;
              "Class. Frete",;
              "Dsc. Clss. Frete",;
              "Tipo Operação",;
              "Desc. Operação",;
              "Data Inicio",; 
              "Data Término",;
              "Tipo Veículo",; 
              "Faixa Até",;
              "Tipo Origem",;
              "Origem",;
              "Desc Origem",;
              "Tipo Destino",;
              "Destino",;
              "Desc Dest",;
              "Prazo",;
              "Cons. Prazo",;
              "Tipo Prazo",;
              "Cont. Prazo",;
              "Componente",;
              "Valor Fixo",;
              "Valor Unitário",;
              "% Sobre Valor",;
              "Valor Minimo",;
              "Fração",;
              "Valor Limite",;
              "Fixo Tarifa Extra",;
              "% Tarifa Extra",;
              "Unit Tarifa Extra",;
              "Cálculo Excedente",;
              "Imposto Incluido",;
			  "Fração Extra";
             }

    aIdx := {"ACAO",;
             "TRANSP",;
             "#NMTRP",;
             "NRTAB",;
             "#DSTAB",;
             "NRNEG",;
             "NRCT",;
             "CLASSF",;
             "#DSCLSS",;
             "TPOPER",;
             "#DSOPER",;
             "INICIO",;
             "TERMIN",;
             "TPVEIC",;
             "FAIXAF",;
             "TPORIG",;
             "ORIGEM",;
             "#ORIGEM",;
             "TPDEST",;
             "DESTIN",;
             "#DESTIN",;
             "PRAZO",;
             "CONSPZ",;
             "TPPRAZ",;
             "CONTPZ",;
             "COMPON",;
             "VLFIXO",;
             "VLUNIT",;
             "PERVAL",;
             "VALMIN",;
             "FRACAO",;
             "VALLIM" ,;
             "VLFIXE",;
             "PCEXTR",;
             "VLUNIE",;
             "CALCEX",;
             "IMPINC",;
			 "FRACEX";
    }

	oExcel:AddTable(cTable, aCols, aIdx)

	aAreaGV9 := GetArea("GV9")
	aAreaGVA := GetArea("GVA")

	cCpo := "%GV9.GV9_CDEMIT, GU3.GU3_NMEMIT, GV9.GV9_NRTAB, GVA.GVA_DSTAB, GV9.GV9_NRNEG, GV7.GV7_CDFXTV, GV9.GV9_CDCLFR, GUB.GUB_DSCLFR"+;
			", GV9.GV9_CDTPOP, GV4.GV4_DSTPOP, GV9.GV9_DTVALI, GV9.GV9_DTVALF, GV9.GV9_TPLOTA, GV9.GV9_QTKGM3, GV8.GV8_TPORIG, GV8.GV8_NRCIOR"+;
			", GV8.GV8_DSTORI, GV8.GV8_DSTORF, GV8.GV8_NRREOR, GV8.GV8_CDPAOR, GV8.GV8_CDUFOR, GV8.GV8_CDFIOR, GV8.GV8_TPDEST, GV8.GV8_NRCIDS"+;
			", GV8.GV8_DSTDEI, GV8.GV8_DSTDEF, GV8.GV8_NRREDS, GV8.GV8_CDPADS, GV8.GV8_CDUFDS, GV8.GV8_CDFIDS, GV8.GV8_CDREM, GV8.GV8_CDDEST"+;
			", GV6.GV6_QTPRAZ, GV6.GV6_CONSPZ, GV6.GV6_TPPRAZ, GV6.GV6_CONTPZ, GV1.GV1_CDFXTV, GV6.GV6_NRROTA, GV7.GV7_CDTPVC, GV7.GV7_QTFXFI"+;
			", GV1.GV1_CDCOMP, GV1.GV1_VLFIXN, GV1.GV1_VLUNIN, GV1.GV1_PCNORM, GV1.GV1_VLMINN, GV1.GV1_VLFRAC, GV1.GV1_VLLIM, GV1.GV1_VLFIXE"+;
			", GV1.GV1_PCEXTR, GV1.GV1_VLUNIE, GV1.GV1_CALCEX, GV9.GV9_ADICMS"

	If GFXCP12125("GVW_CDEMIT")	
		cCpo += ", GVW.GVW_NRCT"
	EndIf

	If lFRACEX
		cCpo += ", GV1.GV1_FRACEX"
	EndIf

	cCpo += "%" 

	// Monta cláusula ON considerando tipo de compartilhamento da tabela de emitente.
	If lExclusiva
		If FWModeAccess("GV9",1) == "E"
			//cGU3on := "% ON GU3.GU3_FILIAL = GV9.GV9_FILIAL AND GU3.GU3_CDEMIT = GV9.GV9_CDEMIT AND GU3.D_E_L_E_T_ = ' '%"	
			If FWModeAccess("GU3",3) == "E" 
				cGU3on := "% ON GU3.GU3_FILIAL = GV9.GV9_FILIAL AND GU3.GU3_CDEMIT = GV9.GV9_CDEMIT AND GU3.D_E_L_E_T_ = ' '%"
			Else
				cGU3on := "% ON GU3.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3.GU3_CDEMIT = GV9.GV9_CDEMIT AND GU3.D_E_L_E_T_ = ' '%"
			EndIf
		Else
			cGU3on := "% ON GU3.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3.GU3_CDEMIT = GV9.GV9_CDEMIT AND GU3.D_E_L_E_T_ = ' '%"
		EndIf
	Else
		cGU3on := "% ON GU3.GU3_CDEMIT = GV9.GV9_CDEMIT AND GU3.D_E_L_E_T_ = ' '%"
	EndIF

	//---------GXT---------
	If GFXCP12125("GVW_CDEMIT")	
		cJoin += " LEFT JOIN " + RetSqlName('GVW') + " GVW"
		cJoin += " ON GVW.GVW_FILIAL = GV9.GV9_FILIAL"
		cJoin += " AND GVW.GVW_CDEMIT = GV9.GV9_CDEMIT"
		cJoin += " AND GVW.GVW_NRTAB = GV9.GV9_NRTAB"
		cJoin += " AND GVW.GVW_NRNEG = GV9.GV9_NRNEG"
		cJoin += " AND GVW.D_E_L_E_T_ = ''"
	EndIf
	cJoin += "%"
	//---------END_GXT---------

	cAliasT := GetNextAlias()
	BeginSql Alias cAliasT
		SELECT %Exp:cCpo%
		FROM %Table:GV9% GV9
		INNER JOIN %Table:GU3% GU3 
		%Exp:cGU3On%
		LEFT JOIN %Table:GVA% GVA 
		ON GVA.GVA_FILIAL = GV9.GV9_FILIAL AND GVA.GVA_NRTAB = GV9.GV9_NRTAB AND GVA.GVA_CDEMIT = GV9.GV9_CDEMIT AND GVA.%NotDel%
		LEFT JOIN %Table:GUB% GUB 
		ON GUB.GUB_CDCLFR = GV9.GV9_CDCLFR AND GUB.%NotDel%
		LEFT JOIN %Table:GV7% GV7 
		ON GV7.GV7_FILIAL = GV9.GV9_FILIAL AND GV7.GV7_CDEMIT = GV9.GV9_CDEMIT AND GV7.GV7_NRTAB = GV9.GV9_NRTAB AND GV7.GV7_NRNEG = GV9.GV9_NRNEG AND GV7.%NotDel%
		LEFT JOIN %Table:GV4% GV4 
		ON GV4.GV4_CDTPOP = GV9.GV9_CDTPOP AND GV4.%NotDel%
		LEFT JOIN %Table:GV8% GV8 
		ON GV8.GV8_FILIAL = GV9.GV9_FILIAL AND GV9.GV9_NRNEG = GV8.GV8_NRNEG AND GV8.GV8_CDEMIT = GV9.GV9_CDEMIT AND GV8.GV8_NRTAB = GV9.GV9_NRTAB AND GV8.%NotDel%
		LEFT JOIN %Table:GV6% GV6 
		ON GV6.GV6_FILIAL = GV8.GV8_FILIAL AND GV6.GV6_NRNEG = GV8.GV8_NRNEG AND GV6.GV6_CDEMIT = GV8.GV8_CDEMIT AND GV6.GV6_NRTAB = GV8.GV8_NRTAB AND GV6.GV6_NRROTA = GV8.GV8_NRROTA AND GV6.GV6_CDFXTV = GV7.GV7_CDFXTV AND GV6.%NotDel%
		LEFT JOIN %Table:GV1% GV1 
		ON GV1.GV1_FILIAL = GV6.GV6_FILIAL AND GV1.GV1_NRNEG = GV6.GV6_NRNEG AND GV1.GV1_CDEMIT = GV6.GV6_CDEMIT AND GV1.GV1_NRTAB = GV6.GV6_NRTAB AND GV1.GV1_NRROTA = GV6.GV6_NRROTA AND GV1.GV1_CDFXTV = GV6.GV6_CDFXTV AND GV1.%NotDel% %Exp:cJoin%
		WHERE GV9.%NotDel%
		AND GV9.GV9_FILIAL = %Exp:GV9->GV9_FILIAL%
		AND GV9.GV9_CDEMIT = %Exp:GVA->GVA_CDEMIT%
		AND GV9.GV9_NRTAB  = %Exp:GVA->GVA_NRTAB%
		AND GV9.GV9_NRNEG = %Exp:GV9->GV9_NRNEG%
		ORDER BY GV9.GV9_CDEMIT, GV9.GV9_NRTAB, GV9.GV9_NRNEG, GV6.GV6_NRROTA, GV7.GV7_CDFXTV, GV1.GV1_CDCOMP ASC
	EndSql
	(cAliasT)->(DBGoTop())
	Count To nRecCount

	ProcRegua(nRecCount)

	(cAliasT)->(DbGoTop())

	Do While !(cAliasT)->(Eof())
		//GV8.GV8_TPORIG / GV8.GV8_TPDEST
		//0=Todos;1=Cidade;2=Distancia;3=Regiao;4=Pais/UF;5=Remetente

		cCdOrig := ''
		cDsOrig := ''	
		Do Case
			Case (cAliasT)->GV8_TPORIG == "0" // Todos
				cCdOrig := ''
				cDsOrig := 'Todas as Rotas'
			Case (cAliasT)->GV8_TPORIG == "1" // Cidade
				cCdOrig := (cAliasT)->GV8_NRCIOR
				cDsOrig := Posicione("GU7",1,xFilial("GU7")+(cAliasT)->GV8_NRCIOR,"GU7_NMCID")
			Case (cAliasT)->GV8_TPORIG == "2" // Distancia
				cCdOrig := cValtoChar((cAliasT)->GV8_DSTORI) + '-' + cValToChar((cAliasT)->GV8_DSTORF)
				cDsOrig := AllTrim(Transform((cAliasT)->GV8_DSTORI, PESQPICT("GV8", "GV8_DSTORI")))+";"+AllTrim(Transform((cAliasT)->GV8_DSTORF, PESQPICT("GV8", "GV8_DSTORF")))
			Case (cAliasT)->GV8_TPORIG == "3" // Regiao
				cCdOrig := (cAliasT)->GV8_NRREOR
				cDsOrig := Posicione("GU9",1,xFilial("GU9")+(cAliasT)->GV8_NRREOR,"GU9_NMREG")
			Case (cAliasT)->GV8_TPORIG == "4" //Pais/UF
				cCdOrig := (cAliasT)->GV8_CDPAOR + '-' + (cAliasT)->GV8_CDUFOR
				cDsOrig := Posicione("SYA",1,xFilial("SYA")+(cAliasT)->GV8_CDPAOR,"YA_DESCR")
			Case (cAliasT)->GV8_TPORIG == "5" // Remetente
				cCdOrig := (cAliasT)->GV8_CDREM
				cDsOrig := Posicione("GU3",1,xFilial("GU3")+(cAliasT)->GV8_CDREM,"GU3_NMEMIT")
		End

		cCdDest := ''
		cDsDest := ''
		Do Case
			Case (cAliasT)->GV8_TPDEST == "0" // Todos
				cCdDest := ''
				cDsDest := 'Todas as Rotas'
			Case (cAliasT)->GV8_TPDEST == "1" // Cidade
				cCdDest := (cAliasT)->GV8_NRCIDS
				cDsDest := Posicione("GU7",1,xFilial("GU7")+(cAliasT)->GV8_NRCIDS,"GU7_NMCID")
			Case (cAliasT)->GV8_TPDEST == "2" // Distancia
				cCdDest := cValToChar((cAliasT)->GV8_DSTDEI) + '-' + cValToChar((cAliasT)->GV8_DSTDEF)
				cDsDest := AllTrim(Transform((cAliasT)->GV8_DSTDEI, PESQPICT("GV8", "GV8_DSTDEI")))+";"+AllTrim(Transform((cAliasT)->GV8_DSTDEF, PESQPICT("GV8", "GV8_DSTDEF")))
			Case (cAliasT)->GV8_TPDEST == "3" // Regiao
				cCdDest := (cAliasT)->GV8_NRREDS
				cDsDest := Posicione("GU9",1,xFilial("GU9")+(cAliasT)->GV8_NRREDS,"GU9_NMREG")
			Case (cAliasT)->GV8_TPDEST == "4" //Pais/UF
				cCdDest := (cAliasT)->GV8_CDPADS + '-' + (cAliasT)->GV8_CDUFDS
				cDsDest := Posicione("SYA",1,xFilial("SYA")+(cAliasT)->GV8_CDPADS,"YA_DESCR")
			Case (cAliasT)->GV8_TPDEST == "5" // Remetente
				cCdDest := (cAliasT)->GV8_CDDEST
				cDsDest := Posicione("GU3",1,xFilial("GU3")+(cAliasT)->GV8_CDDEST,"GU3_NMEMIT")
		End

		cNrCt := ""
		If GFXCP12125("GVW_CDEMIT")
			cNrCt := (cAliasT)->GVW_NRCT
		EndIf

		nFRACEX := 0
		If lFRACEX
			nFRACEX := (cAliasT)->GV1_FRACEX
		EndIf

		oExcel:AddRow({"0",;
					(cAliasT)->GV9_CDEMIT,;
					(cAliasT)->GU3_NMEMIT,;
					(cAliasT)->GV9_NRTAB,;
					(cAliasT)->GVA_DSTAB,;
					(cAliasT)->GV9_NRNEG,;
					cNrCt,;
					(cAliasT)->GV9_CDCLFR,;
					(cAliasT)->GUB_DSCLFR,;
					(cAliasT)->GV9_CDTPOP,;
					(cAliasT)->GV4_DSTPOP,;
					SToD((cAliasT)->GV9_DTVALI),;
					SToD((cAliasT)->GV9_DTVALF),;
					(cAliasT)->GV7_CDTPVC,;
					(cAliasT)->GV7_QTFXFI,;
					(cAliasT)->GV8_TPORIG,;
					cCdOrig ,;
					cDsOrig ,;
					(cAliasT)->GV8_TPDEST,;
					cCdDest ,;
					cDsDest ,;
					(cAliasT)->GV6_QTPRAZ,;
					(cAliasT)->GV6_CONSPZ,;
					(cAliasT)->GV6_TPPRAZ,;
					(cAliasT)->GV6_CONTPZ,;
					(cAliasT)->GV1_CDCOMP,;
					(cAliasT)->GV1_VLFIXN,;
					(cAliasT)->GV1_VLUNIN,;
					(cAliasT)->GV1_PCNORM,;
					(cAliasT)->GV1_VLMINN,;
					(cAliasT)->GV1_VLFRAC,;
					(cAliasT)->GV1_VLLIM,;
					(cAliasT)->GV1_VLFIXE,;
					(cAliasT)->GV1_PCEXTR,;
					(cAliasT)->GV1_VLUNIE,;
					(cAliasT)->GV1_CALCEX,;
					(cAliasT)->GV9_ADICMS,;
					nFRACEX;
					})

		(cAliasT)->(DbSkip())

		IncProc()
	EndDo

	oExcel:EndTable()
	oExcel:EndWorkSheet()

	(cAliasT)->(DbCloseArea())

	//--------------------------------------------------
	//GUB
	//--------------------------------------------------
	aCols := {;
			"Código Class. Frete",;
			"Desc. Class. Frete"  ;
			}

	oExcel:AddWorkSheet("Classificação de Frete")
	oExcel:AddTable("Classificação de Frete", aCols)

	cAliasT := GetNextAlias()
	BeginSql Alias cAliasT
		SELECT GUB_CDCLFR
		, GUB_DSCLFR
		FROM %Table:GUB% GUB
	 	WHERE GUB.%NotDel%
		ORDER BY GUB_CDCLFR
	EndSql
	Do While !(cAliasT)->(Eof())
		oExcel:AddRow({(cAliasT)->GUB_CDCLFR, (cAliasT)->GUB_DSCLFR})

		(cAliasT)->(DbSkip())
	EndDo

	oExcel:EndTable()
	oExcel:EndWorkSheet()

	(cAliasT)->(DbCloseArea())

	//--------------------------------------------------
	//GV4
	//--------------------------------------------------
	aCols := {;
			"Código Tipo Operação" ,;
			"Desc. Tipo Operação"  ,;
			"Sentido Tipo Operação",;
			"Situação"			   ,;
			"Condição Vale Pedágio" ;
			}

	oExcel:AddWorkSheet("Tipos de Operação")
	oExcel:AddTable("Tipos de Operação", aCols)

	cAliasT := GetNextAlias()
	BeginSql Alias cAliasT
		SELECT GV4_CDTPOP
		, GV4_DSTPOP
		, GV4_SENTID
		, GV4_SIT
		, GV4_PEDAG
		FROM %Table:GV4% GV4
		WHERE GV4.%NotDel%
		ORDER BY GV4_CDTPOP
	EndSql
	Do While !(cAliasT)->(Eof())
		aRow := {}

		Aadd(aRow, (cAliasT)->GV4_CDTPOP)
		Aadd(aRow, (cAliasT)->GV4_DSTPOP)

		Do Case
			Case (cAliasT)->GV4_SENTID == '0'
				Aadd(aRow, "Todos")
			Case (cAliasT)->GV4_SENTID == '1'
				Aadd(aRow, "Entrada")
			Case (cAliasT)->GV4_SENTID == '2'
				Aadd(aRow, "Saída")
			Case (cAliasT)->GV4_SENTID == '3'
				Aadd(aRow, "Externo")
			Case (cAliasT)->GV4_SENTID == '4'
				Aadd(aRow, "Interno")
			OtherWise
				Aadd(aRow, "")
		EndCase

		Do Case
			Case (cAliasT)->GV4_SIT == '1'
				Aadd(aRow, "Ativa")
			Case (cAliasT)->GV4_SIT == '2'
				Aadd(aRow, "Inativa")
			OtherWise
				Aadd(aRow, "")
		EndCase

		Do Case
			Case (cAliasT)->GV4_PEDAG == '1'
				Aadd(aRow, "Não se Aplica")
			Case (cAliasT)->GV4_PEDAG == '2'
				Aadd(aRow, "Opcional")
			Case (cAliasT)->GV4_PEDAG == '3'
				Aadd(aRow, "Obrigatório")
			OtherWise
				Aadd(aRow, "")
		EndCase

		oExcel:AddRow(aRow)
		(cAliasT)->(DbSkip())
	EndDo

	oExcel:EndTable()
	oExcel:EndWorkSheet()

	(cAliasT)->(DbCloseArea())

	//--------------------------------------------------
	//GV3
	//--------------------------------------------------
	aCols := {;
			"Código do Tipo de Veículo" ,;
			"Desc. Tipo Veículo"        ,;
			"Número de Eixos"           ,;
			"Peso sem Carga"        	,;
			"Carga Útil"                ,;
			"Peso Bruto Total"          ,;
			"Volume Útil"               ,;
			"Altura do Tipo de Veículo" ,;
			"Comprimento Tipo Veículo"  ,;
			"Largura Tipo Veículo"      ,;
			"Posição na Composição"     ,;
			"Situação Tipo Veículo"     ,;
			"Categoria Veículo Pedágio"  ;
			}

	oExcel:AddWorkSheet("Tipos de Veiculo")
	oExcel:AddTable("Tipos de Veiculo", aCols)

	cAliasT := GetNextAlias()
	BeginSql Alias cAliasT
		SELECT GV3_CDTPVC
		, GV3_DSTPVC
		, GV3_EIXOS
		, GV3_TARA
		, GV3_CARGUT
		, GV3_PBT
		, GV3_VOLUT
		, GV3_ALTURA
		, GV3_COMPRI
		, GV3_LARGUR
		, GV3_POSCOM
		, GV3_SIT
		, GV3_CATPED
		FROM %Table:GV3% GV3
	   	WHERE GV3.%NotDel%
		ORDER BY GV3_CDTPVC
	EndSql
	Do While !(cAliasT)->(Eof())
		aRow := {}
		Aadd(aRow, (cAliasT)->GV3_CDTPVC)
		Aadd(aRow, (cAliasT)->GV3_DSTPVC)
		Aadd(aRow, (cAliasT)->GV3_EIXOS )
		Aadd(aRow, (cAliasT)->GV3_TARA  )
		Aadd(aRow, (cAliasT)->GV3_CARGUT)
		Aadd(aRow, (cAliasT)->GV3_PBT   )
		Aadd(aRow, (cAliasT)->GV3_VOLUT )
		Aadd(aRow, (cAliasT)->GV3_ALTURA)
		Aadd(aRow, (cAliasT)->GV3_COMPRI)
		Aadd(aRow, (cAliasT)->GV3_LARGUR)

		Do Case
			Case (cAliasT)->GV3_POSCOM == '1'
				Aadd(aRow, "Principal")
			Case (cAliasT)->GV3_POSCOM == '2'
				Aadd(aRow, "Reboque")
			OtherWise
				Aadd(aRow, "")
		EndCase

		Do Case
			Case (cAliasT)->GV3_SIT == '1'
				Aadd(aRow, "Ativo")
			Case (cAliasT)->GV3_SIT == '2'
				Aadd(aRow, "Inativo")
			OtherWise
				Aadd(aRow, "")
		EndCase

		Do Case
			Case (cAliasT)->GV3_CATPED == '1'
				Aadd(aRow, "Não se Aplica")
			Case (cAliasT)->GV3_CATPED == '2'
				Aadd(aRow, "Opcional")
			Case (cAliasT)->GV3_CATPED == '3'
				Aadd(aRow, "Obrigatório")
			OtherWise
				Aadd(aRow, "")
		EndCase

		oExcel:AddRow(aRow)
		(cAliasT)->(DbSkip())
	EndDo

	oExcel:EndTable()
	oExcel:EndWorkSheet()

	(cAliasT)->(DbCloseArea())

	//--------------------------------------------------
	//GV2
	//--------------------------------------------------
	aCols := {;
			"Código do Componente"      ,;
			"Descrição Componente"      ,;
			"Atributo para Cálculo"     ,;
			"Suframa"                   ,;
			"Categoria Valor"           ,;
			"Cálculo Serviço"           ,;
			"Código Tipo Serviço"       ,;
			"Calculo Serviço"           ,;
			"Unitizador para Calculo"    ;
			}

	oExcel:AddWorkSheet("Componentes de Frete")
	oExcel:AddTable("Componentes de Frete", aCols)

	cAliasT := GetNextAlias()
	BeginSql Alias cAliasT
	    SELECT GV2_CDCOMP
		, GV2_DSCOMP
		, GV2_ATRCAL
		, GV2_TABSUF
		, GV2_CATVAL
		, GV2_SERVI
		, GV2_CDTPSE
		, GV2_CALSER
		, GV2_UNIT
		FROM %Table:GV2% GV2
	   WHERE GV2.%NotDel%
	   ORDER BY GV2_CDCOMP
	EndSql
	Do While !(cAliasT)->(EoF())
		aRow := {}
		Aadd(aRow, (cAliasT)->GV2_CDCOMP)
		Aadd(aRow, (cAliasT)->GV2_DSCOMP)

		Do Case
			Case (cAliasT)->GV2_ATRCAL == "1"
				Aadd(aRow, "Peso")
			Case (cAliasT)->GV2_ATRCAL == "2"
				Aadd(aRow, "Val. Carga")
			Case (cAliasT)->GV2_ATRCAL == "3"
				Aadd(aRow, "Qt. Itens")
			Case (cAliasT)->GV2_ATRCAL == "4"
				Aadd(aRow, "Volume")
			Case (cAliasT)->GV2_ATRCAL == "5"
				Aadd(aRow, "Qt. Vol.")
			Case (cAliasT)->GV2_ATRCAL == "6"
				Aadd(aRow, "Distância")
			Case (cAliasT)->GV2_ATRCAL == "7"
				Aadd(aRow, "Qt. Entrega")
			Case (cAliasT)->GV2_ATRCAL == "8"
				Aadd(aRow, "Val. Fixo")
			Case (cAliasT)->GV2_ATRCAL == "9"
				Aadd(aRow, "Val. Frete")
			Case (cAliasT)->GV2_ATRCAL == "10"
				Aadd(aRow, "Peso Liq.")
			Case (cAliasT)->GV2_ATRCAL == "11"
				Aadd(aRow, "Qtd. Serviço")
			OtherWise
				Aadd(aRow, "")
		EndCase

		Do Case
			Case (cAliasT)->GV2_TABSUF == '1'
				Aadd(aRow, "Não se Aplica")
			Case (cAliasT)->GV2_TABSUF == '2'
				Aadd(aRow, "Tarifa Tabela Frete")
			Case (cAliasT)->GV2_TABSUF == '3'
				Aadd(aRow, "Tabela Suframa")
			OtherWise
				Aadd(aRow, "")
		EndCase

		Do Case
			Case (cAliasT)->GV2_CATVAL == '1'
				Aadd(aRow, "Frete Unidade")
			Case (cAliasT)->GV2_CATVAL == '2'
				Aadd(aRow, "Frete Valor")
			Case (cAliasT)->GV2_CATVAL == '3'
				Aadd(aRow, "Taxas")
			Case (cAliasT)->GV2_CATVAL == '4'
				Aadd(aRow, "Pedágio")
			OtherWise
				Aadd(aRow, "")
		EndCase

		Do Case
			Case (cAliasT)->GV2_SERVI == '1'
				Aadd(aRow, "Sim")
			Case (cAliasT)->GV2_SERVI == '2'
				Aadd(aRow, "Não")
			OtherWise
				Aadd(aRow, "")
		EndCase

		Aadd(aRow, Posicione("GVU",1,XFILIAL("GVU")+(cAliasT)->GV2_CDTPSE,"GVU_DSTPSE"))

		Do Case
			Case (cAliasT)->GV2_CALSER == '1'
				Aadd(aRow, "Por Ocorrência")
			Case (cAliasT)->GV2_CALSER == '2'
				Aadd(aRow, "Por Romaneio")
			OtherWise
				Aadd(aRow, "")
		EndCase

		Aadd(aRow, (cAliasT)->GV2_UNIT)

		oExcel:AddRow(aRow)
		(cAliasT)->(DbSkip())
	EndDo

	aRow := {}

	oExcel:EndTable()
	oExcel:EndWorkSheet()

	(cAliasT)->(DbCloseArea())
	RestArea(aAreaGV9)
	RestArea(aAreaGVA)

    oExcel:SaveFile(cDir,cName)

	FreeObj(oExcel)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpTbXml()
Cria tela de wizard de importação
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ImpTbXml(cTargetDir, cLogDir, lSim, lLibre, lGerLog)
	Local cFileName  as char
	Local cFileDir   as char
	Local nHdl       as char
	Local aAreaGV9   as array
	Local aAreaGVA   as array
	Local oModelGV8  as object
	Local oModelGV7  as object
	Local oModelGUY  as object
	Local cUnPes     as char
	Local cTpOri     as char
	Local cTpDst	 as char
	Local cOri       as char
	Local cDst       as char
	Local cTrp       as char
	Local cNrTab     as char
	Local cNrNeg 	 as char	
	Local nI         as numeric
	Local nIgv8      as numeric
	Local cNrRota    as char
	Local cCdFxTv    as char
	Local iCdFxTv    := 0
	Local cChave     as char
	Local lSit	     as logical
	local nLinha     as numeric
	Local cNrct      := ""
	Local nVlFixo    := 0
	Local nVlUnit    := 0
	Local nPerVal    := 0
	Local nValMin    := 0
	Local nValLim    := 0
	Local nVlFixE    := 0
	Local nPcExtr    := 0
	Local nVlUniE    := 0
	Local nFracao    := 0
	Local nQtFXFI    := 0
	Local cGv9Filter := ""
	Local aAreaGUB   := GUB->( GetArea() )
	Local nAcaoZero  := 0
	Local cQuery     := ""

	Local lFRACEX	 := GFXCP2610("GV1_FRACEX")
	Local nFRACEX	 := 0
	Local cAliGV2	 := ""

	Private lFoundGXT  as logical
	Private aLog       as Array
	Private cNmCid     := ''

	nI    := 0
	nIgv8 := 0
	nImp  := 0
	aLog  := {}

	aAreaGV9 := GV9->(GetArea())
	aAreaGVA := GVA->(GetArea())

	// Armazena e limpa filtro aplicado
	cGv9Filter := GV9->(dbFilter())
	GV9->(DbClearFilter())

	CriaTabTmp()

	cUnPes := SuperGetMV("MV_UMPESO", .F., "KG",)

	cLogTxt := ""

	oModelNeg := FWLoadModel('GFEA061A')
	oModelGV8 := oModelNeg:GetModel("DETAIL_GV8")
	oModelGV7 := oModelNeg:GetModel("DETAIL_GV7")
	oModelGUY := oModelNeg:GetModel("DETAIL_GUY")

	If GFXCP12125("GVW_CDEMIT")
		oModelCTR := FWLoadModel('GFEA083')
	EndIf

	oModelTRF := FWLoadModel("GFEA061F")

	cFileDir  := GetFileDir(cTargetDir)[1]
	cFileName := GetFileDir(cTargetDir)[2]

	cLogTxt += LogMessage("AVISO: Iniciando Importação do Arquivo " + cFileName + CRLF + CRLF + CRLF)

	Aadd(aLog, cLogTxt)

	aIndic := {'TRANSP','NRTAB','NRNEG'}

	MsgRun("Aguarde a leitura do arquivo", "Aguarde...", {|| oXmlParser := XMLParserGFEA061():New(cTargetDir,2,aIndic,'#',.F., lLibre)})
	

	If Empty(oXmlParser:_xml)
		oXmlParser := nil
		Return .F.
	EndIf

	lReal := .F.
	lErro := .F.
	lFoundGXT := .F.

	nLinha := oXmlParser:GetTotalRows()
	ProcRegua(nLinha)
	For nI := 1 to nLinha
		IncProc()

		nImp := nImp + 1
		cTrp   := PadR(oXmlParser:GetCol("TRANSP",nI) ,TamSX3("GV9_CDEMIT")[1])
		cNrTab := PadR(oXmlParser:GetCol("NRTAB",nI)  ,TamSX3("GV9_NRTAB" )[1])
		cNrNeg := PadR(oXmlParser:GetCol("NRNEG",nI)  ,TamSX3("GV9_NRNEG" )[1])

		cLogTxt := "--------------------------------------------------------------------------------------------" + CRLF
		cLogTxt += LogMessage("AVISO: Tentando operação do registro na linha número " + cValToChar(nImp) + " : " + CRLF +;
							"                                       Transportador   : " + cTrp + CRLF+;
							"                                       Nro. Tabela     : " + cNrTab + CRLF+;
							"                                       Nro. Negociação : " + cNrNeg + CRLF)
		
		// Verifica se a chave da tabela de frete encontrada ou se o arquivo está com formatação indevida.
		If Empty(cTrp) .Or. Empty(cNrTab) .Or. Empty(cNrNeg)
			cLogTxt += LogMessage("AVISO: Chave da tabela de frete não encontrada ou formatação do arquivo indevida"+CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)

			Aadd(aLog, cLogTxt)
			cLogTxt := ""
			nAcaoZero++
			Loop
		EndIf
		// Valida se a ação permitir a importação dos registros
		If Empty(oXmlParser:GetCol("ACAO",nI)) .OR. AllTrim(oXmlParser:GetCol("ACAO",nI)) == "0"
			cLogTxt += LogMessage("AVISO: Registro com nenhuma ação definida, não serão realizadas operações"+CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)

			Aadd(aLog, cLogTxt)
			cLogTxt := ""
			nAcaoZero++
			Loop
		EndIf

		// Valida se tipo de origem e código origem informado quando não for vazio e tipo origem não for 0-Todos
		If Empty(oXmlParser:GetCol("TPORIG",nI)) .OR. (!(oXmlParser:GetCol("TPORIG",nI) == '0') .AND. Empty(oXmlParser:GetCol("ORIGEM",nI)))
			If Empty(oXmlParser:GetCol("TPORIG",nI))
				cLogTxt += LogMessage("ERRO: Tipo origem não definida na rota da negociação de frete"+CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			Else
				cLogTxt += LogMessage("ERRO: Origem não definida na rota da negociação de frete"+CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			EndIf
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Loop
		EndIf

		// Valida se tipo de destino e código destino informado quando não for vazio e tipo destino não for 0-Todos
		If Empty(oXmlParser:GetCol("TPDEST",nI)) .OR. (!(oXmlParser:GetCol("TPDEST",nI) == '0') .AND. Empty(oXmlParser:GetCol("DESTIN",nI)))
			If Empty(oXmlParser:GetCol("TPDEST",nI))
				cLogTxt += LogMessage("ERRO: Tipo destino não definido na rota da negociação de frete"+CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			Else
				cLogTxt += LogMessage("ERRO: Destino não definido na rota da negociação de frete"+CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			EndIf
			lErro := .T.
			
			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Loop
		EndIf

		If Empty(oXmlParser:GetCol("NRTAB",nI)) .OR. Empty(oXmlParser:GetCol("NRNEG",nI)) .OR.;
			Empty(oXmlParser:GetCol("INICIO",nI)) .OR. Empty(oXmlParser:GetCol("COMPON",nI))

			cLogTxt += LogMessage("ERRO: Campos obrigatórios não informados"+CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Loop
		EndIf

		nQtFXFI := val(strtran(oXmlParser:GetCol("FAIXAF",nI),",","."))
		If !Empty(oXmlParser:GetCol("TPVEIC",nI)) .and. (!Empty(nQTFXFI) .or. nQTFXFI != 0)
			cLogTxt += LogMessage("ERRO: Registro com ambos Tipo de Veículo e Faixa preenchidos. Somente um é permitido!"+CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Loop
		EndIf 

		cAliGV2 := GetNextAlias()

		BeginSQL Alias cAliGV2
			SELECT GV2.R_E_C_N_O_ RECNOGV2
			FROM %Table:GV2% GV2
			WHERE GV2.GV2_FILIAL = %xFilial:GV2%
			AND GV2.GV2_CDCOMP = %Exp:Alltrim(oXmlParser:GetCol("COMPON",nI))%
			AND GV2.%NotDel%
		EndSQL

		If (cAliGV2)->(EoF())
			cLogTxt += LogMessage("ERRO: Componente (" + Alltrim(oXmlParser:GetCol("COMPON",nI)) + ") não está cadastrado na rotina de Componentes de Frete."+CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			(cAliGV2)->(dbCloseArea())
			Loop
		EndIf 

		(cAliGV2)->(dbCloseArea())

		nVlFixo := IIf(!Empty(oXmlParser:GetCol("VLFIXO",nI)),val(strtran(oXmlParser:GetCol("VLFIXO",nI),",",".")),0)
		nVlUnit := IIf(!Empty(oXmlParser:GetCol("VLUNIT",nI)),val(strtran(oXmlParser:GetCol("VLUNIT",nI),",",".")),0)
		nPerVal := IIf(!Empty(oXmlParser:GetCol("PERVAL",nI)),val(strtran(oXmlParser:GetCol("PERVAL",nI),",",".")),0)
		nValMin := IIf(!Empty(oXmlParser:GetCol("VALMIN",nI)),val(strtran(oXmlParser:GetCol("VALMIN",nI),",",".")),0)
		nValLim := IIf(!Empty(oXmlParser:GetCol("VALLIM",nI)),val(strtran(oXmlParser:GetCol("VALLIM",nI),",",".")),0)
		nVlFixE := IIf(!Empty(oXmlParser:GetCol("VLFIXE",nI)),val(strtran(oXmlParser:GetCol("VLFIXE",nI),",",".")),0)
		nPcExtr := IIf(!Empty(oXmlParser:GetCol("PCEXTR",nI)),val(strtran(oXmlParser:GetCol("PCEXTR",nI),",",".")),0)
		nVlUniE := IIf(!Empty(oXmlParser:GetCol("VLUNIE",nI)),val(strtran(oXmlParser:GetCol("VLUNIE",nI),",",".")),0)
		nFracao := IIf(!Empty(oXmlParser:GetCol("FRACAO",nI)),val(strtran(oXmlParser:GetCol("FRACAO",nI),",",".")),0)
		nFRACEX := IIf(!Empty(oXmlParser:GetCol("FRACEX",nI)),val(strtran(oXmlParser:GetCol("FRACEX",nI),",",".")),0)

		// Valida Tipo de Cidade Origem
		cTpOri := RetTpOriDsT(AllTrim(oXmlParser:GetCol("TPORIG",nI)))
		If Empty(cTpOri)
			cLogTxt += LogMessage("ERRO: Tipo de Cidade Origem inválido!"+CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Loop
		EndIf

		// Valida Tipo de Cidade Destino
		cTpDst := RetTpOriDsT(AllTrim(oXmlParser:GetCol("TPDEST",nI)))
		If Empty(cTpDst)
			cLogTxt += LogMessage("ERRO: Tipo de Cidade Destino inválido!"+CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Loop
		EndIf

		If Empty(Posicione("GU3", 1, xFilial("GU3")+cTrp, 'GU3_CDEMIT'))
			cLogTxt += LogMessage("ERRO: Transportador não encontrado!"+CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Loop
		EndIf

		GVA->(DbSetOrder(1))
		If !GVA->(DbSeek(xFilial("GVA")+cTrp+cNrTab))
			cLogTxt += LogMessage("ERRO: Tabela de Frete não encontrada!"+CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Loop
		EndIf

		If GVA->GVA_TPTAB == "2"
			cLogTxt += LogMessage("ERRO: Tabela de Frete não pode ser do tipo Vínculo!"+CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Loop
		EndIf

		// Valida a cidade de origem do rota
		cOri := VldOriDst(AllTrim(oXmlParser:GetCol("ORIGEM",nI)), cTpOri)

		VldDescCid(cOri)
		If !(AllTrim(cTpOri) == '0') .And. Empty(cOri)
			If cTpOri $ "1;2;4;5"
				cLogTxt += LogMessage("ERRO: Cidade de Origem não encontrada!"+CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
				lErro := .T.

				Aadd(aLog, cLogTxt)
				cLogTxt := ""

				Loop
			Else
				cLogTxt += LogMessage("ERRO: Região de Origem não encontrada!"+CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
				lErro := .T.

				Aadd(aLog, cLogTxt)
				cLogTxt := ""

				Loop
			EndIf
		EndIf

		// Valida a cidade de destino da rota
		cDst := VldOriDst(AllTrim(oXmlParser:GetCol("DESTIN",nI)), cTpDst)
		
		VldDescCid(cDst)
		If !(AllTrim(cTpDst) == '0') .And. Empty(cDst) 
			If  cTpDst $ "1;2;4;5"
				cLogTxt += LogMessage("ERRO: Cidade de Destino não encontrada!"+CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
				lErro := .T.

				Aadd(aLog, cLogTxt)
				cLogTxt := ""

				Loop
			Else
				cLogTxt += LogMessage("ERRO: Região de Destino não encontrada!"+CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
				lErro := .T.

				Aadd(aLog, cLogTxt)
				cLogTxt := ""

				Loop
			EndIf
		EndIf

		If !Empty(oXmlParser:GetCol("NRCT" ,nI))
			cNrct  := PadR(oXmlParser:GetCol("NRCT" ,nI)  ,TamSX3("GXT_NRCT"  )[1])

			GXT->(DbSetOrder(1))
			If !GXT->(DbSeek(xFilial('GXT')+cNrct))
				cLogTxt += LogMessage("ERRO: Contrato não encontrado!"+CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
				lErro := .T.

				Aadd(aLog, cLogTxt)
				cLogTxt := ""

				Loop

			ElseIf GXT->GXT_CDTRP != cTrp
				cLogTxt += LogMessage("ERRO: Contrato vinculado a outro transportador!"+CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
				lErro := .T.

				Aadd(aLog, cLogTxt)
				cLogTxt := ""

				Loop
			EndIf
		EndIf
	Next nI
	// Verifica o arquivo a ser importado está todo com açao zero(0)
	// Assim não deverá continuar o processamento
	If nLinha == nAcaoZero
		lErro := .T.
	EndIf

	cLogTxt += LogMessage("AVISO: Verificação inicial concluída. " + CRLF)
	Aadd(aLog, cLogTxt)
	cLogTxt := ""

	If !lErro
		ProcRegua(nLinha)

		For nI := 1 To nLinha
			IncProc()

			If AllTrim(oXmlParser:GetCol("ACAO",nI)) == "0"
				Loop
			EndIf

			cTrp   := PadR(oXmlParser:GetCol("TRANSP",nI) ,TamSX3("GV9_CDEMIT")[1])
			cNrTab := PadR(oXmlParser:GetCol("NRTAB",nI)  ,TamSX3("GV9_NRTAB" )[1])
			cNrNeg := PadR(oXmlParser:GetCol("NRNEG",nI)  ,TamSX3("GV9_NRNEG" )[1])

			If Empty(Alltrim(cTrp)) .And. Empty(Alltrim(cNrTab)) .And. Empty(Alltrim(cNrNeg))
				Loop
			EndIf
			Do Case
				Case AllTrim(oXmlParser:GetCol("ACAO",nI)) == "1"
					GV9->(DbSetOrder(1))
					If GV9->(DbSeek(xFilial("GV9") + cTrp + cNrTab + cNrNeg))
						cAcao := "alterada"
						If GV9->GV9_SIT == "1"
							Aadd(aLog, cLogTxt)
							cLogTxt := ""
						Else
							cLogTxt += LogMessage("ERRO: Não Alterado! Somente é possível alterar negociações com o status 'Em Negociação' !"+CRLF)
							cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
							lErro := .T.

							Aadd(aLog, cLogTxt)
							cLogTxt := ""

							Loop
						EndIf
					Else
						cAcao := "criada"

						Aadd(aLog, cLogTxt)
						cLogTxt := ""
					EndIf

				OtherWise
					cLogTxt += LogMessage("ERRO: Ação inválida informada!"+CRLF)
					cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
					lErro := .T.

					Aadd(aLog, cLogTxt)
					cLogTxt := ""

					Loop
			EndCase
		Next
	EndIf

	If !lErro
		ProcRegua(nLinha)

		For nI := 1 to nLinha
			IncProc()

			lSit := .T.

			nImp  := nImp + 1
			If AllTrim(oXmlParser:GetCol("ACAO",nI)) == "0"
				Loop
			EndIf

			cTrp   := PadR(oXmlParser:GetCol("TRANSP",nI) ,TamSX3("GV9_CDEMIT")[1])
			cNrTab := PadR(oXmlParser:GetCol("NRTAB",nI)  ,TamSX3("GV9_NRTAB")[1])
			cNrNeg := PadR(oXmlParser:GetCol("NRNEG",nI)  ,TamSX3("GV9_NRNEG")[1])

			If Empty(Alltrim(cTrp)) .And. Empty(Alltrim(cNrTab)) .And. Empty(Alltrim(cNrNeg))
				Loop
			EndIf

			If !Empty(oXmlParser:GetCol("NRCT" ,nI))
				cNrct  := PadR(oXmlParser:GetCol("NRCT" ,nI)  ,TamSX3("GXT_NRCT"  )[1])
			EndIf

			// Se for uma nova negociação realiza a criação da negociação anterior
			If (!Empty(cChave) .And. cChave <> cTrp + cNrTab + cNrNeg)
				lReal = .T.
				criaGV9(cChave)
			EndIf

			cTpOri := RetTpOriDsT(AllTrim(oXmlParser:GetCol("TPORIG",nI)))
			cTpDst := RetTpOriDsT(AllTrim(oXmlParser:GetCol("TPDEST",nI)))

			cOri := VldOriDst(AllTrim(oXmlParser:GetCol("ORIGEM",nI)), cTpOri)
			cDst := VldOriDst(AllTrim(oXmlParser:GetCol("DESTIN",nI)), cTpDst)

		

			// Verifica se é o primeiro registro ou se é uma nova negociação
			If Empty(cChave) .or. cChave <> cTrp + cNrTab + cNrNeg
				lReal  := .F.
				cChave := cTrp + cNrTab + cNrNeg

				Do Case
					Case AllTrim(oXmlParser:GetCol("ACAO",nI)) == "1"
						GV9->(DbSetOrder(1))
						If GV9->(DbSeek(xFilial("GV9")+cTrp+cNrTab+cNrNeg))
							cAcao := "alterada"
							If GV9->GV9_SIT == "1"
								oModelNeg:SetOperation(MODEL_OPERATION_UPDATE)
								oModelTRF:SetOperation(MODEL_OPERATION_UPDATE)
							Else
								lSit := .F.
								Loop
							EndIf
						Else
							cAcao := "criada"
							oModelNeg:SetOperation(MODEL_OPERATION_INSERT)
							oModelTRF:SetOperation(MODEL_OPERATION_INSERT)
						EndIf 
					OtherWise
						lSit := .F.
						Loop
				End

				oModelNeg:Activate()

				oModelNeg:LoadValue("GFEA061A_GV9","GV9_CDEMIT", cTrp)
				oModelNeg:LoadValue("GFEA061A_GV9","GV9_NRTAB" , cNrTab)
				oModelNeg:LoadValue("GFEA061A_GV9","GV9_NRNEG" , cNrNeg)
			EndIf

			cLogTxt += LogMessage("AVISO: Incluindo/Alterando: " + "Transp: " + AllTrim(oXmlParser:GetCol("TRANSP",nI)) + " NrTab: " +;
									AllTrim(oXmlParser:GetCol("NRTAB",nI)) + " NrNeg: " + AllTrim(oXmlParser:GetCol("NRNEG",nI)) + " DtInicio " +;
									Alltrim(oXmlParser:GetCol("INICIO",nI)) + " Compon " + AllTrim(oXmlParser:GetCol("COMPON",nI)) + CRLF)

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			cAdICMs := RetSimNao(oXmlParser:GetCol("IMPINC",nI))

			oModelNeg:LoadValue("GFEA061A_GV9","GV9_CDCLFR", PadR(oXmlParser:GetCol("CLASSF",nI) ,TamSX3("GV9_CDCLFR")[1]))
			oModelNeg:LoadValue("GFEA061A_GV9","GV9_CDTPOP", PadR(oXmlParser:GetCol("TPOPER",nI) ,TamSX3("GV9_CDTPOP")[1]))
			oModelNeg:LoadValue("GFEA061A_GV9","GV9_DTVALI", CToD(Alltrim(oXmlParser:GetCol("INICIO",nI))))
			oModelNeg:LoadValue("GFEA061A_GV9","GV9_DTVALF", CToD(Alltrim(oXmlParser:GetCol("TERMIN",nI))))
			oModelNeg:LoadValue("GFEA061A_GV9","GV9_UNIFAI", cUnPes)
			oModelNeg:LoadValue("GFEA061A_GV9","GV9_ADICMS", cAdICMs)

			nVlFixo := IIf(!Empty(oXmlParser:GetCol("VLFIXO",nI)),val(strtran(oXmlParser:GetCol("VLFIXO",nI),",",".")),0)
			nVlUnit := IIf(!Empty(oXmlParser:GetCol("VLUNIT",nI)),val(strtran(oXmlParser:GetCol("VLUNIT",nI),",",".")),0)
			nPerVal := IIf(!Empty(oXmlParser:GetCol("PERVAL",nI)),val(strtran(oXmlParser:GetCol("PERVAL",nI),",",".")),0)
			nValMin := IIf(!Empty(oXmlParser:GetCol("VALMIN",nI)),val(strtran(oXmlParser:GetCol("VALMIN",nI),",",".")),0)
			nValLim := IIf(!Empty(oXmlParser:GetCol("VALLIM",nI)),val(strtran(oXmlParser:GetCol("VALLIM",nI),",",".")),0)
			nVlFixE := IIf(!Empty(oXmlParser:GetCol("VLFIXE",nI)),val(strtran(oXmlParser:GetCol("VLFIXE",nI),",",".")),0)
			nPcExtr := IIf(!Empty(oXmlParser:GetCol("PCEXTR",nI)),val(strtran(oXmlParser:GetCol("PCEXTR",nI),",",".")),0)
			nVlUniE := IIf(!Empty(oXmlParser:GetCol("VLUNIE",nI)),val(strtran(oXmlParser:GetCol("VLUNIE",nI),",",".")),0)
			nFracao := IIf(!Empty(oXmlParser:GetCol("FRACAO",nI)),val(strtran(oXmlParser:GetCol("FRACAO",nI),",",".")),0)
			nQtFXFI := IIf(!Empty(oXmlParser:GetCol("FAIXAF",nI)),val(strtran(oXmlParser:GetCol("FAIXAF",nI),",",".")),0)
			nFRACEX := IIf(!Empty(oXmlParser:GetCol("FRACEX",nI)),val(strtran(oXmlParser:GetCol("FRACEX",nI),",",".")),0)

			// Verifica se já existe um registro da Faixa/Tp Veiculo Tab Frete na tabela temporária
			lEncGV7 := .F.
			(_cAliaGV7)->(DBGoTop())
			Do While (_cAliaGV7)->(!Eof())
				If AllTrim((_cAliaGV7)->TRANSP) + AllTrim((_cAliaGV7)->NRTAB) + AllTrim((_cAliaGV7)->NRNEG) +;
					cValToChar((_cAliaGV7)->FAIXAF) + AllTrim((_cAliaGV7)->TPVEIC) == AllTrim(cTrp) + AllTrim(cNrTab) +;
					AllTrim(cNrNeg) + cvaltochar(nQtFXFI) + AllTrim(oXmlParser:GetCol("TPVEIC",nI))

					cCdFxTv := cvaltochar((_cAliaGV7)->CDFXTV)
					lEncGV7 := .T.
					Exit
				EndIf

				(_cAliaGV7)->(DBSkip())
			EndDo

			// Só inclui uma nova linha caso não exista o registro na tabela temporária
			If !lEncGV7
				iCdFxTv := iCdFxTv + 1
				cCdFxTv := PADL(cvaltochar(iCdFxTv),4,"0")
				lCdFxTv := .F.

				// Caso exista a tabela já criada na tabela de frete, atualiza o número da faixa que deverá ser utilizado
				GV7->(DbCloseArea())
				GV7->(DbSetOrder(1))
				GV7->(dbSeek(xFilial("GV7") + cTrp + cNrTab + cNrNeg))
				While !Eof() .AND. GV7->GV7_FILIAL == xFilial("GV7") .AND. GV7->GV7_CDEMIT  == cTrp ;
							 .AND. GV7->GV7_NRTAB == cNrTab .AND. GV7->GV7_NRNEG == cNrNeg
					cCdFxTv := PADL(cvaltochar(val(GV7->GV7_CDFXTV) + 1),4,"0")

					GV7->( dbSkip(1) )
				EndDo

				// Verifica se exista um registro com o mesmo tipo veículo/faixa na tabela de frete
				cWhere := "%"
				If !Empty(oXmlParser:GetCol("TPVEIC",nI)) .OR. (Empty(oXmlParser:GetCol("TPVEIC",nI)) .and. (Empty(nQTFXFI) .OR. nQTFXFI == 0))
					cWhere += " AND GV7_CDTPVC  = '"+AllTrim(oXmlParser:GetCol("TPVEIC",nI))+"'"
				ElseIf nQtFXFI != 0
					cWhere += " AND GV7_QTFXFI  = '" + cvaltochar(nQtFXFI) + "'"
				Else
					cWhere += " AND GV7_QTFXFI  = 999999999.99999"
				EndIf
				cWhere += "%"

				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT GV7_CDFXTV
					FROM %Table:GV7% GV7
					WHERE GV7_FILIAL = %xFilial:GV7%
					AND GV7_CDEMIT = %Exp:cTrp%
					AND GV7_NRTAB  = %Exp:cNrTab%
					AND GV7_NRNEG  = %Exp:cNrNeg%
					AND GV7.%NotDel%
					%Exp:cWhere%
				EndSql

				(cAliasQry)->( dbGoTop() )
				While !(cAliasQry)->(Eof())
					cCdFxTv := PADL(cvaltochar(val((cAliasQry)->GV7_CDFXTV)),4,"0")
					lCdFxTv := .T.

					(cAliasQry)->(dbSkip())
				EndDo

				(cAliasQry)->(DbCloseArea())

				If Reclock(_cAliaGV7, .T.)
					(_cAliaGV7)->TRANSP := cTrp
					(_cAliaGV7)->NRTAB  := cNrTab
					(_cAliaGV7)->NRNEG  := cNrNeg
					(_cAliaGV7)->FAIXAF := nQtFXFI
					(_cAliaGV7)->TPVEIC := oXmlParser:GetCol("TPVEIC",nI)
					(_cAliaGV7)->CDFXTV := cCdFxTv
					(_cAliaGV7)->(MsUnlock())
				EndIf

				If (oModelGV7:GetQtdLine() > 1 .or. !Empty(oModelGV7:GetValue('GV7_CDFXTV',1)))	.AND. !lCdFxTv
					oModelGV7:Addline(.T.)
				EndIf

				If !GV7->(DbSeek(xFilial("GV7")+cTrp+cNrTab+cNrNeg+cCdFxTv))
					If !lCdFxTv
						oModelGV7:LoadValue("GV7_CDEMIT", cTrp)
						oModelGV7:LoadValue("GV7_NRTAB" , cNrTab)
						oModelGV7:LoadValue("GV7_NRNEG" , cNrNeg)
						oModelGV7:LoadValue("GV7_CDFXTV", cCdFxTv)

						cFaixaF := 0
						IF nQtFXFI == 0
							cFaixaF := Val('999.999.999,99999')
						Else
							cFaixaF := nQtFXFI
						EndIf

						If !Empty(oXmlParser:GetCol("TPVEIC",nI)) .OR. (Empty(oXmlParser:GetCol("TPVEIC",nI)) .and. (Empty(nQTFXFI) .OR. nQTFXFI == 0))
							oModelGV7:LoadValue("GV7_CDTPVC", AllTrim(oXmlParser:GetCol("TPVEIC",nI)))
							oModelNeg:LoadValue("GFEA061A_GV9","GV9_TPLOTA", "2")
							oModelNeg:LoadValue("GFEA061A_GV9","GV9_UNIFAI", " ")
						ElseIf nQtFXFI != 0	
							oModelGV7:LoadValue("GV7_QTFXFI", nQtFXFI)
							oModelGV7:LoadValue("GV7_UNICAL", cUnPes)
							oModelNeg:LoadValue("GFEA061A_GV9","GV9_TPLOTA", "1")
						Else
							oModelGV7:LoadValue("GV7_QTFXFI",  Val('999.999.999,99999'))
							oModelGV7:LoadValue("GV7_UNICAL", cUnPes)
							oModelNeg:LoadValue("GFEA061A_GV9","GV9_TPLOTA", "1")
						EndIf
					EndIf
				EndIf
			EndIf

			// Verifica se já existe uma Rota na tabela temporária
			lEncGV8 := .F.
			(_cAliaGV8)->(DBGoTop())
			Do While (_cAliaGV8)->(!Eof())
				If AllTrim((_cAliaGV8)->TRANSP) + AllTrim((_cAliaGV8)->NRTAB) + AllTrim((_cAliaGV8)->NRNEG) + AllTrim((_cAliaGV8)->ORIGEM) + ;
				   AllTrim((_cAliaGV8)->DESTIN) == AllTrim(cTrp) + AllTrim(cNrTab) + AllTrim(cNrNeg) + AllTrim(cOri) + AllTrim(cDst)

					cNrRota := (_cAliaGV8)->NRROTA
					lEncGV8 := .T.
					Exit
				EndIf

				(_cAliaGV8)->(DBSkip())
			EndDo

			// Só inclui uma nova linha caso não exista o registro na tabela temporária
			If !lEncGV8
				lNrRota := .F.

				// Caso exista a tabela já criada na tabela de frete, atualiza o número da rota que deverá ser utilizado
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT MAX(GV8.GV8_NRROTA) GV8_NRROTA
					FROM %Table:GV8% GV8
					WHERE GV8.GV8_FILIAL = %xFilial:GV8%
					AND GV8.GV8_CDEMIT = %Exp:cTrp%
					AND GV8.GV8_NRTAB = %Exp:cNrTab%
					AND GV8.GV8_NRNEG = %Exp:cNrNeg%
					AND GV8.%NotDel%
				EndSql
				If (cAliasQry)->(!Eof())
					cNrRota := PADL(cvaltochar((cAliasQry)->GV8_NRROTA),4,"0")
				EndIf
				(cAliasQry)->(dbCloseArea())
				
				(_cAliaGV8)->(DBGoTop())
				Do While !(_cAliaGV8)->(Eof())
					If AllTrim((_cAliaGV8)->TRANSP) + AllTrim((_cAliaGV8)->NRTAB) + AllTrim((_cAliaGV8)->NRNEG)  == AllTrim(cTrp) + AllTrim(cNrTab) + AllTrim(cNrNeg)
						cNrRota := IIf( cNrRota < (_cAliaGV8)->NRROTA,(_cAliaGV8)->NRROTA,cNrRota)
					EndIf
					(_cAliaGV8)->(DBSkip())
				EndDo
				cNrRota := PADL(cvaltochar(Val(cNrRota)+1),4,"0")

				// Verifica se exista uma rota com a mesma origem/destino na tabela de frete
				cAliasQry := GetNextAlias()
				cQuery := " SELECT GV8_NRROTA "
				cQuery += " FROM " + RetSQLName("GV8")
				cQuery += " WHERE GV8_FILIAL = '" + xFilial("GV8") + "'"
				cQuery += "   AND GV8_CDEMIT = '"+cTrp+"'"
				cQuery += "   AND GV8_NRTAB  = '"+cNrTab+"'"
				cQuery += "   AND GV8_NRNEG  = '"+cNrNeg+"'"
				cQuery += "   AND GV8_TPORIG  = '"+cTpOri+"'"
				Do Case
					Case cTpOri == '1'
						cQuery += "   AND GV8_NRCIOR  = '"+PadR(cOri ,TamSX3("GV8_NRCIOR")[1])+"'"
					Case cTpOri == '2'
						cQuery += "   AND GV8_DSTORI  = " + cValToChar(Val(Substr(cOri, 1, at("-",cOri) - 1)))
						cQuery += "   AND GV8_DSTORF  = " + cValToChar(Val(Substr(cOri, at("-",cOri) + 1, Len(cOri))))
					Case cTpOri == '3'
						cQuery += "   AND GV8_NRREOR  = '"+PadR(cOri ,TamSX3("GV8_NRREOR")[1])+"'"
					Case cTpOri == '4'
						cQuery += "   AND GV8_CDPAOR  = '"+PadR(cOri ,TamSX3("GV8_CDPAOR")[1])+"'"

						// Tratamento para buscar o estado considerando "-" ou "/"
						nPos := IIf(AT( "-", cOri) == 0,AT( "/", cOri),AT( "-", cOri))+1
						
						cQuery += "   AND GV8_CDUFOR  = '"+PadR(SUBSTR(cOri , nPos, TamSX3("GV8_CDUFOR")[1]) ,TamSX3("GV8_CDUFOR")[1])+"'"
					Case cTpOri == '5'
						cQuery += "   AND GV8_CDREM  = '"+PadR(cOri ,TamSX3("GV8_CDREM")[1])+"'"
				EndCase
				cQuery += "   AND GV8_TPDEST  = '"+cTpDst+"'"
				Do Case
					Case cTpDst == '1'
						cQuery += "   AND GV8_NRCIDS  = '"+PadR(cDst ,TamSX3("GV8_NRCIDS")[1])+"'"
					Case cTpDst == '2'
						cQuery += "   AND GV8_DSTDEI  = " + cValToChar(Val(Substr(cDst, 1, at("-",cDst) - 1)))
						cQuery += "   AND GV8_DSTDEF  = " + cValToChar(Val(Substr(cDst, at("-",cDst) + 1, Len(cDst))))
					Case cTpDst == '3'
						cQuery += "   AND GV8_NRREDS  = '"+PadR(cDst ,TamSX3("GV8_NRREDS")[1])+"'"
					Case cTpDst == '4'
						cQuery += "   AND GV8_CDPADS  = '"+PadR(cDst ,TamSX3("GV8_CDPADS")[1])+"'"

						// Tratamento para buscar o estado considerando "-" ou "/"
						nPos := IIf(AT( "-", cDst) == 0,AT( "/", cDst),AT( "-", cDst))+1
						
						cQuery += "   AND GV8_CDUFDS  = '"+PadR(SUBSTR(cDst , nPos, TamSX3("GV8_CDUFDS")[1])  ,TamSX3("GV8_CDUFDS")[1])+"'"
					Case cTpDst == '5'
						cQuery += "   AND GV8_CDDEST  = '"+PadR(cDst ,TamSX3("GV8_CDDEST")[1])+"'"
				EndCase
				cQuery += " AND D_E_L_E_T_ = ' '"

				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				(cAliasQry)->( dbGoTop() )
				Do While (cAliasQry)->(!Eof())
					cNrRota := PadL(cvaltochar(val((cAliasQry)->GV8_NRROTA)),4,"0")
					lNrRota := .T.

					(cAliasQry)->(dbSkip())
				EndDo

				(cAliasQry)->(DbCloseArea())
				If !lNrRota
					If Reclock(_cAliaGV8, .T.)
						(_cAliaGV8)->TRANSP := cTrp
						(_cAliaGV8)->NRTAB  := cNrTab
						(_cAliaGV8)->NRNEG  := cNrNeg
						(_cAliaGV8)->ORIGEM := cOri
						(_cAliaGV8)->DESTIN := cDst
						(_cAliaGV8)->NRROTA := cNrRota
						(_cAliaGV8)->(MsUnlock())
					EndIf
				EndIf
				If (oModelGV8:GetQtdLine() > 1 .Or. !Empty(oModelGV8:GetValue('GV8_NRROTA',1))) .And. !lNrRota
					oModelGV8:Addline(.T.)
				EndIf

				GV8->(DbCloseArea())
				GV8->(DbSetOrder(1))
				If !GV8->(DbSeek(xFilial("GV8") + cTrp + cNrTab + cNrNeg + cNrRota))
					If !lNrRota
						oModelGV8:LoadValue("GV8_CDEMIT", cTrp)
						oModelGV8:LoadValue("GV8_NRTAB" , cNrTab)
						oModelGV8:LoadValue("GV8_NRNEG" , cNrNeg)
						oModelGV8:LoadValue("GV8_NRROTA", cNrRota)
						oModelGV8:LoadValue("GV8_TPORIG", cTpOri)

						Do Case
							Case cTpOri == '1'
								oModelGV8:LoadValue("GV8_NRCIOR", PadR(cOri ,TamSX3("GV8_NRCIOR")[1]))
							Case cTpOri == '2'
								oModelGV8:LoadValue("GV8_DSTORI", Val(Substr(cOri, 1, at("-",cOri) - 1)) )
								oModelGV8:LoadValue("GV8_DSTORF", Val(Substr(cOri, at("-",cOri) + 1, Len(cOri))) )
							Case cTpOri == '3'
								oModelGV8:LoadValue("GV8_NRREOR", PadR(cOri ,TamSX3("GV8_NRREOR")[1]))
							Case cTpOri == '4'
								oModelGV8:LoadValue("GV8_CDPAOR", PadR(cOri ,TamSX3("GV8_CDPAOR")[1]))
								// Tratamento para buscar o estado considerando "-" ou "/"
								nPos := IIf(AT( "-", cOri) == 0,AT( "/", cOri),AT( "-", cOri))+1
								cOri := SUBSTR(cOri , nPos, TamSX3("GV8_CDUFOR")[1])
								oModelGV8:LoadValue("GV8_CDUFOR", PadR(cOri ,TamSX3("GV8_CDUFOR")[1]))
							Case cTpOri == '5'
								oModelGV8:LoadValue("GV8_CDREM", PadR(cOri ,TamSX3("GV8_CDREM")[1]))
						EndCase

						oModelGV8:LoadValue("GV8_TPDEST", cTpDst)

						Do Case
							Case cTpDst == '1'
								oModelGV8:LoadValue("GV8_NRCIDS", PadR(cDst ,TamSX3("GV8_NRCIDS")[1]))
							Case cTpDst == '2'
								oModelGV8:LoadValue("GV8_DSTDEI", Val(Substr(cDst, 1, at("-",cDst) - 1)) )
								oModelGV8:LoadValue("GV8_DSTDEF", Val(Substr(cDst, at("-",cDst) + 1, Len(cDst))) )
							Case cTpDst == '3'
								oModelGV8:LoadValue("GV8_NRREDS", PadR(cDst ,TamSX3("GV8_NRREDS")[1]))
							Case cTpDst == '4'
								oModelGV8:LoadValue("GV8_CDPADS", PadR(cDst ,TamSX3("GV8_CDPADS")[1]))
								// Tratamento para buscar o estado considerando "-" ou "/"
								nPos := IIf(AT( "-", cDst) == 0,AT( "/", cDst),AT( "-", cDst))+1
								cDst := SUBSTR(cDst , nPos, TamSX3("GV8_CDUFDS")[1]) 
								oModelGV8:LoadValue("GV8_CDUFDS", PadR(cDst ,TamSX3("GV8_CDUFDS")[1]))
							Case cTpDst == '5'
								oModelGV8:LoadValue("GV8_CDDEST", PadR(cDst ,TamSX3("GV8_CDDEST")[1]))
						EndCase
					EndIf
				EndIf
			EndIf

			// Verifica todas as tarifas vinculadas a uma negociação
			lEncGV6 := .F.
			(_cAliaGV6)->(DBGoTop())
			Do While (_cAliaGV6)->(!Eof())
				If AllTrim((_cAliaGV6)->TRANSP) + AllTrim((_cAliaGV6)->NRTAB) + AllTrim((_cAliaGV6)->NRNEG) + AllTrim((_cAliaGV6)->CDFXTV) + AllTrim((_cAliaGV6)->NRROTA) == ;
					AllTrim(cTrp) + AllTrim(cNrTab) + AllTrim(cNrNeg) + AllTrim(cCdFxTv) + AllTrim(cNrRota)
					lEncGV6 := .T.
				EndIf

				(_cAliaGV6)->(DBSkip())
			EndDo

			If !lEncGV6
				If Reclock(_cAliaGV6, .T.)
					(_cAliaGV6)->TRANSP := cTrp
					(_cAliaGV6)->NRTAB  := cNrTab
					(_cAliaGV6)->NRNEG  := cNrNeg
					(_cAliaGV6)->CDFXTV := cCdFxTv
					(_cAliaGV6)->NRROTA := cNrRota

					If !Empty(oXmlParser:GetCol("PRAZO"))
						(_cAliaGV6)->PRAZO   := Val(oXmlParser:GetCol("PRAZO",nI))
						(_cAliaGV6)->CONSPZ  := AllTrim(oXmlParser:GetCol("CONSPZ",nI))
						(_cAliaGV6)->TPPRAZ  := AllTrim(oXmlParser:GetCol("TPPRAZ",nI))
						(_cAliaGV6)->CONTPZ  := AllTrim(oXmlParser:GetCol("CONTPZ",nI))
					EndIf
					(_cAliaGV6)->(MsUnlock())
				EndIf
			EndIf

			// Verifica a tabela de Contrato de Transportes
			If !Empty(cNrct)
				GXT->(DbSetOrder(1))
				If GXT->(DbSeek(xFilial('GXT') + cNrct))
					lFoundGXT := .T.
				EndIf
			EndIf

			If GFXCP12125("GVW_CDEMIT")
				If lFoundGXT
					lEncGVW := .F.
					(_cAliaGVW)->(DbGoTop())

					Do While (_cAliaGVW)->(!Eof())
						If AllTrim((_cAliaGVW)->TRANSP) + AllTrim((_cAliaGVW)->NRTAB) + AllTrim((_cAliaGVW)->NRNEG) + AllTrim((_cAliaGVW)->NRCT) == ;
							AllTrim(cTrp) + AllTrim(cNrTab) + AllTrim(cNrNeg) + AllTrim(cNrct)
							lEncGVW := .T.
						EndIf

						(_cAliaGVW)->(DBSkip())
					End

					If !lEncGVW
						If Reclock(_cAliaGVW, .T.)
							(_cAliaGVW)->TRANSP := cTrp
							(_cAliaGVW)->NRTAB  := cNrTab
							(_cAliaGVW)->NRNEG  := cNrNeg
							(_cAliaGVW)->NRCT   := cNrct

							(_cAliaGVW)->(MsUnlock())
						EndIf
					EndIf
				EndIf
			EndIf

			// Verifica todos os componentes vinculados a uma negociação
			lEncGUY := .F.
			(_cAliaGUY)->(DBGoTop())
			While !(_cAliaGUY)->(Eof())
				If AllTrim((_cAliaGUY)->TRANSP) + AllTrim((_cAliaGUY)->NRTAB) + AllTrim((_cAliaGUY)->NRNEG) + AllTrim((_cAliaGUY)->COMPON) == ;
					AllTrim(cTrp) + AllTrim(cNrTab) + AllTrim(cNrNeg) + AllTrim(oXmlParser:GetCol("COMPON",nI))
					lEncGUY := .T.
				EndIf

				(_cAliaGUY)->(DBSkip())
			EndDo

			If !lEncGUY
				If Reclock(_cAliaGUY, .T.)
					(_cAliaGUY)->TRANSP := cTrp
					(_cAliaGUY)->NRTAB  := cNrTab
					(_cAliaGUY)->NRNEG  := cNrNeg
					(_cAliaGUY)->COMPON := AllTrim(oXmlParser:GetCol("COMPON",nI))

					(_cAliaGUY)->(MsUnlock())
				EndIf

				GUY->(DbCloseArea())
				GUY->(DbSetOrder(1))
				If !GUY->(DbSeek(xFilial("GUY")+cTrp+cNrTab+cNrNeg+PadR(oXmlParser:GetCol("COMPON",nI) ,TamSX3("GV1_CDCOMP")[1])))
					If oModelGUY:GetQtdLine() > 1 .or. !Empty(oModelGUY:GetValue('GUY_CDCOMP',1))
						oModelGUY:Addline(.T.)
					EndIf

					oModelGUY:LoadValue("GUY_CDEMIT", cTrp)
					oModelGUY:LoadValue("GUY_NRTAB" , cNrTab)
					oModelGUY:LoadValue("GUY_NRNEG" , cNrNeg)
					oModelGUY:LoadValue("GUY_CDCOMP", PadR(oXmlParser:GetCol("COMPON",nI) ,TamSX3("GV1_CDCOMP")[1]))
				EndIf
			EndIf

			// Verifica todas as tarifas/componentes vinculadas a uma negociação
			lEncGV1 := .F.
			(_cAliaGV1)->(DBGoTop())
			Do While !(_cAliaGV1)->(Eof())
				If AllTrim((_cAliaGV1)->TRANSP) + AllTrim((_cAliaGV1)->NRTAB) + AllTrim((_cAliaGV1)->NRNEG) + AllTrim((_cAliaGV1)->CDFXTV) + AllTrim((_cAliaGV1)->NRROTA) + AllTrim((_cAliaGV1)->COMPON) == ;
					AllTrim(cTrp) + AllTrim(cNrTab) + AllTrim(cNrNeg) + AllTrim(cCdFxTv) + AllTrim(cNrRota) + AllTrim(oXmlParser:GetCol("COMPON",nI))
					lEncGV1 := .T.
				EndIf

				(_cAliaGV1)->(DBSkip())
			EndDo

			If !lEncGV1
				If Reclock(_cAliaGV1, .T.)
					(_cAliaGV1)->TRANSP := cTrp
					(_cAliaGV1)->NRTAB  := cNrTab
					(_cAliaGV1)->NRNEG  := cNrNeg
					(_cAliaGV1)->CDFXTV := cCdFxTv
					(_cAliaGV1)->NRROTA := cNrRota
					(_cAliaGV1)->COMPON := AllTrim(oXmlParser:GetCol("COMPON",nI))
					(_cAliaGV1)->VLFIXO := nVlFixo
					(_cAliaGV1)->VLUNIT := nVlUnit
					(_cAliaGV1)->PERVAL := nPerVal
					(_cAliaGV1)->VALMIN := nValMin
					(_cAliaGV1)->VALLIM := nValLim
					(_cAliaGV1)->VLFIXE := nVlFixE
					(_cAliaGV1)->PCEXTR := nPcExtr
					(_cAliaGV1)->VLUNIE := nVlUniE
					(_cAliaGV1)->CALCEX := AllTrim(oXmlParser:GetCol("CALCEX",nI))
					(_cAliaGV1)->FRACAO := nFracao
					If lFRACEX
						(_cAliaGV1)->FRACEX := nFRACEX
					EndIf
					(_cAliaGV1)->(MsUnlock())
				EndIf
			EndIf
		Next

		// Último registro da Negociação de Frete e a situação da planilha permite a inclusão/alteração
		If !lReal .And. lSit
			criaGV9(cChave, lSim)
		EndIf
	EndIf

	nHdl := FCreate(cLogDir + cFileName + ".txt")
	If nHdl == -1
		MsgAlert("Não foi possível criar o arquivo de log!")
		MsgInfo(cLogTxt)
	Else
		For nI := 1 To Len(aLog)
			FWrite(nHdl, aLog[nI])
		Next
		FClose(nHdl)
	EndIf

	oModelNeg  := Nil
	oXmlParser := Nil
	DelClassIntF()

	// Retorna filtro utilizado anteriormente usado
	GV9->(DbSetFilter({|| cGv9Filter }, cGv9Filter))

	MsgInfo("Operações concluídas. Consulte o log no caminho abaixo para mais informações: " + CRLF + CRLF + cLogDir+cFileName+".txt")

	RestArea(aAreaGUB)
	RestArea(aAreaGV9)
	RestArea(aAreaGVA)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcelGFEA061
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS ExcelGFEA061

    DATA aColumns
    DATA aIdx
    DATA cXml
	DATA aXml
	DATA nMaxStr

    Method New() Constructor
    Method AddRow()
    Method AddTable()
	Method EndTable() 
	Method AddWorkSheet()
	Method EndWorkSheet()
    Method SaveFile()

ENDCLASS

Method New() Class ExcelGFEA061

	::nMaxStr := 1048000 //1.048.576 tamanho maximo string.
	::aXml    := {}

	::cXml := 	'<?xml version="1.0" encoding="windows-1252"?>'					  				    + CRLF + ;
			  	'<?mso-application progid="Excel.Sheet"?>'											+ CRLF

	::cXml +=	'<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' 					+ CRLF +;
			  	' xmlns:o="urn:schemas-microsoft-com:office:office"'			 					+ CRLF +;
			  	' xmlns:x="urn:schemas-microsoft-com:office:excel"'  			 					+ CRLF +;
			  	' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'		 					+ CRLF +;
			  	' xmlns:html="http://www.w3.org/TR/REC-html40">'				 					+ CRLF

	::cXml +=   ' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">' 			+ CRLF +;
			  	'  <Version>15.00</Version>' 														+ CRLF +;
			  	' </DocumentProperties>' 															+ CRLF	

	::cXml += 	' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">' 		+ CRLF +;
			  	'  <AllowPNG/>' 																	+ CRLF +;
			  	' </OfficeDocumentSettings>'														+ CRLF

	::cXml +=  	' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'					+ CRLF +;
			  	'  <WindowHeight>11745</WindowHeight>'												+ CRLF +;
			  	'  <WindowWidth>19200</WindowWidth>' 												+ CRLF +;
			  	'  <WindowTopX>0</WindowTopX>' 														+ CRLF +;
			  	'  <WindowTopY>0</WindowTopY>' 														+ CRLF +;
			  	'  <ProtectStructure>False</ProtectStructure>' 										+ CRLF +;
			  	'  <ProtectWindows>False</ProtectWindows>' 											+ CRLF +;
			  	' </ExcelWorkbook>' 																+ CRLF

	::cXml +=  	' <Styles>' 																		+ CRLF +;
			  	'  <Style ss:ID="Default" ss:Name="Normal">' 										+ CRLF +;
			  	'   <Alignment ss:Vertical="Bottom"/>' 												+ CRLF +;
			  	'   <Borders/>'																		+ CRLF +;
			  	'   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF +;
			  	'   <Interior/>'																	+ CRLF +;
			  	'   <NumberFormat/>'																+ CRLF +;
			  	'   <Protection/>'																	+ CRLF +;
			  	'  </Style>'																		+ CRLF +;
			  	'  <Style ss:ID="s62">'																+ CRLF +;
			  	'   <NumberFormat ss:Format="@"/>'													+ CRLF +;
			  	'  </Style>'																		+ CRLF +;
			  	'  <Style ss:ID="s64">'																+ CRLF +;
			  	'   <NumberFormat ss:Format="0.0000"/>'												+ CRLF +;
			  	'  </Style>'																		+ CRLF +;	
			  	'  <Style ss:ID="s65">'																+ CRLF +;
			  	'   <NumberFormat ss:Format="0.00000000"/>'											+ CRLF +;
			  	'  </Style>'																		+ CRLF +;	
			  	'  <Style ss:ID="s63">'																+ CRLF +;
			  	'   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"'	+ CRLF +;
			  	'    ss:Underline="Single"/>'														+ CRLF +;
			  	'   <NumberFormat ss:Format="@"/>'													+ CRLF +;
			  	'  </Style>'																		+ CRLF +;
			  	' </Styles>'																		+ CRLF

	Aadd(::aXml, ::cXml)  	
		  
Return Self

Method AddWorkSheet(cWorkSheet) Class ExcelGFEA061
	Local lRet := .T.

	::cXml :=   ' <Worksheet ss:Name="'+cWorkSheet+'">' + CRLF
	Aadd(::aXml, ::cXml)
Return lRet

Method EndWorkSheet() Class ExcelGFEA061
	Local lRet := .T.

	::cXml := ' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' 	+ CRLF +;
  			  '  <PageSetup>'														+ CRLF +;
  			  '   <Header x:Margin="0.4921259845"/>'								+ CRLF +;
  			  '   <Footer x:Margin="0.4921259845"/>'								+ CRLF +;
  			  '   <PageMargins x:Bottom="0.984251969" x:Left="0.78740157499999996"'	+ CRLF +;
  			  '    x:Right="0.78740157499999996" x:Top="0.984251969"/>'				+ CRLF +;
  			  '  </PageSetup>'														+ CRLF +;
  			  '  <ProtectObjects>False</ProtectObjects>'							+ CRLF +;
  			  '  <ProtectScenarios>False</ProtectScenarios>'						+ CRLF +;
  			  ' </WorksheetOptions>'												+ CRLF

    ::cXml += '</Worksheet>' + CRLF
	Aadd(::aXml, ::cXml)

Return lRet

Method AddTable(cTableName, aCols, aIdx) Class ExcelGFEA061
    Local lRet as logical
	Local nI   as numeric

	::aColumns := aCols
    ::aIdx     := aIdx

	If ::aColumns <> Nil
		If Len(aCols) < 22
			::cXml := 	'  <Table ss:ExpandedColumnCount="'+cValToChar(22)+'" x:FullColumns="1"' 	+ CRLF
		Else
			::cXml := 	'  <Table ss:ExpandedColumnCount="'+cValToChar(Len(::aColumns))+'" x:FullColumns="1"' 	+ CRLF
		EndIf

		::cXml +=   '   x:FullRows="1" ss:DefaultRowHeight="15">' 						 + CRLF +;
					'   <Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="80.25"/>' + CRLF +;
					'   <Column ss:StyleID="s62" ss:Width="80.25" ss:Span="20"/>'		 + CRLF

		::cXml += '<Row>' + CRLF

		For nI := 1 to Len(::aColumns)       
			::cXml += '<Cell><Data ss:Type="String">'+::aColumns[nI]+'</Data></Cell>' + CRLF
		Next

		::cXml += '</Row>' + CRLF

		If aIdx <> Nil
			::cXml += '<Row>' + CRLF
		
			For nI := 1 To Len(aIdx)
				::cXml +=   '<Cell><Data ss:Type="String">'+aIdx[nI]+'</Data></Cell>' + CRLF
			Next

			::cXml += '</Row>' + CRLF
		EndIf

		lRet := .T.
	Else
		lRet := .F.
	EndIf

	Aadd(::aXml, ::cXml)

Return lRet

Method EndTable() Class ExcelGFEA061
	Local lRet := .T.

	::cXml := '</Table>' 	+ CRLF
	Aadd(::aXml, ::cXml)

Return lRet

Method AddRow(aNewRow) Class ExcelGFEA061
    Local lRet as logical
    Local nX   as numeric

    If Len(aNewRow) == Len(::aColumns)

        ::cXml := '<Row>' + CRLF

        For nX := 1 to Len(aNewRow)

        	If Alltrim(::aColumns[nx]) == "Valor Fixo" .Or. ;
				Alltrim(::aColumns[nx]) == "Valor Unitário" .Or. ;
				Alltrim(::aColumns[nx]) == "% Sobre Valor" .Or. ; 
				Alltrim(::aColumns[nx]) == "Valor Minimo" .Or. ;
				Alltrim(::aColumns[nx]) == "Fração" .Or. ;
				Alltrim(::aColumns[nx]) == "Valor Limite" .Or. ;
				Alltrim(::aColumns[nx]) == "Fixo Tarifa Extra" .Or. ;
				Alltrim(::aColumns[nx]) == "% Tarifa Extra" .Or. ;
				Alltrim(::aColumns[nx]) == "Unit Tarifa Extra" .Or. ;
				Alltrim(::aColumns[nx]) == "Fração Extra"


				If Len(::cXml) < ::nMaxStr
					::cXml += '<Cell ss:StyleID="s64"><Data ss:Type="Number">'+cValToChar(aNewRow[nX])+'</Data></Cell>' + CRLF
				Else
					Aadd(::aXml, ::cXml)
					::cXml := '<Cell ss:StyleID="s64"><Data ss:Type="Number">'+cValToChar(aNewRow[nX])+'</Data></Cell>' + CRLF
				EndIf
			Else 
				If  Alltrim(::aColumns[nx]) == "Faixa Até"
					If Len(::cXml) < ::nMaxStr
						::cXml += '<Cell ss:StyleID="s65"><Data ss:Type="Number">'+cValToChar(aNewRow[nX])+'</Data></Cell>' + CRLF
					Else
						Aadd(::aXml, ::cXml)
						::cXml := '<Cell ss:StyleID="s65"><Data ss:Type="Number">'+cValToChar(aNewRow[nX])+'</Data></Cell>' + CRLF
					EndIf
				Else
					If Len(::cXml) < ::nMaxStr
						::cXml += '<Cell><Data ss:Type="String">'+cValToChar(aNewRow[nX])+'</Data></Cell>' + CRLF
					Else
						Aadd(::aXml, ::cXml)
						::cXml := '<Cell><Data ss:Type="String">'+cValToChar(aNewRow[nX])+'</Data></Cell>' + CRLF
					EndIf
				EndIf
			EndIf
		Next
		::cXml += '</Row>' + CRLF
		Aadd(::aXml, ::cXml)
	Else
		lRet := .F.
	EndIf 
Return lRet

Method SaveFile(cDir, cFileName) Class ExcelGFEA061
    Local lRet as logical
    Local nHdl as numeric
	Local nI   as numeric

    cDir      := AllTrim(cDir)
    cFileName := AllTrim(cFileName) + '.xml'
	nI 		  := 0

    ::cXml := '</Workbook>'  + CRLF
	Aadd(::aXml, ::cXml)

    If !File(cDir+cFileName)
        nHdl := FCreate(cDir+cFileName)
        If nHdl == -1
            MsgAlert("Não foi possível criar o arquivo!")
            FClose(nHdl)
            Return .F.
        EndIf
    Else
        FErase(cDir+cFileName)

        nHdl := FCreate(cDir+cFileName)
        If nHdl == -1
            MsgAlert("Não foi possível criar o arquivo!")
            FClose(nHdl)
            Return .F.
        EndIf
    EndIf

	For nI := 1 To Len(::aXml)
    	FWrite(nHdl, ::aXml[nI])
	Next

    FClose(nHdl)
	FreeObj(::aXml)

    MsgInfo("Arquivo Criado no Diretório "+cDir+cFileName)

Return lRet

//User Function Lexml(param_name)

//cNomearq 


//Return NIL



CLASS XMLParserGFEA061 FROM LongNameClass
	DATA _xml
	DATA aIdx
	DATA nRow
	DATA cAliasT
	DATA lIsTab
	DATA aFields

	Method New() Constructor
	Method GetCol()
	Method GetRow()
	Method GetAllRows()
	Method GetTotalRows()

ENDCLASS

Method New(cFile, nInd, aIdx, cFlag, lTab, lLibre) Class XMLParserGFEA061
	Local nI		 as numeric
	Local nHdl 	     as numeric
	Local cRow 	     as char
	Local nPos	     as numeric
	Local nPos2	     as numeric
	Local cData      as char
	Local nData      as numeric
	Local oTemGV8    as object
	Local nIndexCell as numeric
	Local aRet 		 as array
	Local i          as numeric
	Local iaux       as numeric
	nData := 0

	If lLibre 

		::_xml := {}
		::nRow := 0
		aRet   := GFEA061JXML(cFile)
		iaux   := 0

		If Len(aRet[1]) != Len(aRet[3])
			MsgAlert("Os campos em branco devem ser preenchidos com espaço!")
			Return .F.
		EndIf

		For i :=1 To Len(aRet[1])
			Aadd(::_xml, Column():New(aRet[1][i]))
			For iaux := 1 To Len(aRet[3][i])
				::_xml[i]:AddValue(aRet[3][i][iaux])
			Next iaux
		Next i

		::nRow := aRet[2]
	Else
	
		nHdl  := FOpen(cFile, FO_READWRITE + FO_SHARED)
		::lIsTab := lTab

		If nHdl < 0
			MsgAlert("Não foi possível abrir o arquivo!")
			FClose(nHdl)
			Return
		Else
			If ::lIsTab
				::aFields := {}
				::cAliasT := GetNextAlias()

				FT_FUse(cFile)
				::nRow := 0
				FT_FGoTop()

				oTemGV8 := FWTemporaryTable():New(::cAliasT)

				While !FT_FEOF()
					cRow := FT_FReadLn()

					If "<Row" $ cRow
						::nRow := ::nRow + 1
					ElseIf ::nRow == nInd .and. "<Data" $ cRow
						nData := nData + 1
						
						If '<Data ss:Type="String">' $ cRow
							nPos  := At('<Data ss:Type="String">', cRow)
							nPos2 := At('</Data>', cRow)
							nPos := nPos+Len('<Data ss:Type="String">')

						ElseIf '<Data ss:Type="Number">' $ cRow
							nPos  := At('<Data ss:Type="Number">', cRow)
							nPos2 := At('</Data>', cRow)
							nPos := nPos+Len('<Data ss:Type="Number">')
						EndIf

						cData := SubStr(cRow,nPos,nPos2-nPos)

						If At(cFlag , cData) == 0
							Aadd(::aFields, {cData, "C", 100, 0})
						Else
							cData := StrTran(cData, cFlag, "_x_")
							Aadd(::aFields, {cData, "C", 100, 0})
						EndIf
					ElseIf '</Row>' $ cRow .and. ::nRow >= nInd
						nData  := 0
						::nRow := 0
						Exit
					EndIf

					FT_FSkip()
				End

				oTemGV8:SetFields(::aFields)
				oTemGV8:addIndex('1',aIdx) 
				oTemGV8:Create()

				FT_FGoTop()

				nData := 0

				While !FT_FEOF()

					cRow := FT_FReadLn()
					If "</Worksheet>" $ cRow
						Exit
					EndIf

					If "<Row" $ cRow
						::nRow := ::nRow + 1

						If ::nRow > nInd
							Reclock(::cAliasT, .T.)
						EndIf

					ElseIf "<Data ss:" $ cRow .and. ::nRow > nInd
						nData := nData + 1
					
						If '<Data ss:Type="String">' $ cRow  
							nPos  := At('<Data ss:Type="String">', cRow)
							nPos2 := At('</Data>', cRow)
							nPos := nPos+Len('<Data ss:Type="String">')
							
						ElseIf '<Data ss:Type="Number">' $ cRow
							nPos  := At('<Data ss:Type="Number">', cRow)
							nPos2 := At('</Data>', cRow)
							nPos := nPos+Len('<Data ss:Type="Number">')
						EndIf		

						cData := SubStr(cRow,nPos,nPos2-nPos)
						
						If "ss:Index=" $ cRow
							nPos  := At('ss:Index="', cRow)
							nPos  := nPos + Len('ss:Index="')
							nPos2 := At('"><Data',cRow)

							nIndexCell := Val(SubStr(cRow, nPos, nPos2 - nPos))

							nData := nIndexCell

							(::cAliasT)->&(::aFields[nIndexCell][1]) := AllTrim(cData)
						Else
							(::cAliasT)->&(::aFields[nData][1]) := AllTrim(cData)
						EndIf
						
					ElseIf '</Row>' $ cRow// .and. ::nRow > nInd
						nData := 0
						(::cAliasT)->(MsUnlock())
					EndIf
					FT_FSkip()
				End

			Else 
				::_xml := {}


				FT_FUse(cFile)
				::nRow := 0
				FT_FGoTop()

				While !FT_FEOF()
					cRow := FT_FReadLn()

					If "</Worksheet>" $ cRow
						Exit
					EndIf

					If "<Row" $ cRow
						::nRow := ::nRow + 1

					ElseIf "<Data ss:" $ cRow .and. ::nRow == nInd
						nData := nData + 1
						
						If '<Data ss:Type="String">' $ cRow  
							nPos  := At('<Data ss:Type="String">', cRow)
							nPos2 := At('</Data>', cRow)
							nPos := nPos+Len('<Data ss:Type="String">')
							
						ElseIf '<Data ss:Type="Number">' $ cRow
							nPos  := At('<Data ss:Type="Number">', cRow)
							nPos2 := At('</Data>', cRow)
							nPos := nPos+Len('<Data ss:Type="Number">')
						EndIf	

						cData := SubStr(cRow,nPos,nPos2-nPos)

						Aadd(::_xml, Column():New(cData))

					ElseIf "<Data ss:" $ cRow .and. ::nRow > nInd
						nData := nData + 1

						If '<Data ss:Type="String">' $ cRow  
							nPos  := At('<Data ss:Type="String">', cRow)
							nPos2 := At('</Data>', cRow) 
							nPos := nPos+Len('<Data ss:Type="String">')
							
						ElseIf '<Data ss:Type="Number">' $ cRow
							nPos  := At('<Data ss:Type="Number">', cRow)
							nPos2 := At('</Data>', cRow)
							nPos := nPos+Len('<Data ss:Type="Number">')
						EndIf	

						cData := SubStr(cRow,nPos,nPos2-nPos)
						
						If "ss:Index=" $ cRow
							nPos  := At('ss:Index="', cRow)
							nPos  := nPos + Len('ss:Index="')
							If "ss:StyleID" $ cRow
								nPos2 := At('" ss:StyleID',cRow)
							Else
								nPos2 := At('"><Data',cRow)
							EndIf

							nIndexCell := Val(SubStr(cRow, nPos, (nPos2 - nPos)))

							nData := nIndexCell
						
							If nIndexCell != 0 .and. nIndexCell <= Len(::_xml)
								::_xml[nIndexCell]:AddValue(cData)
							EndIf
						Else
							If nData <= Len(::_xml)
								::_xml[nData]:AddValue(cData)
							EndIf
						EndIf

					ElseIf '</Row>' $ cRow// .and. ::nRow > nInd
						nData := 0
					EndIf
					
					FT_FSkip()
				EndDo
			EndIf

			For nI := Len(::_xml) to 1 step -1
				If !At(cFlag , ::_xml[nI]:cTitle) == 0
					::_xml := ADel( ::_xml, nI)
				EndIf
			Next
			
			FClose(nHdl)
		
		EndIf
		
		::nRow := ::nRow - nInd	
	
	EndIf

Return Self

Method GetRow(nRow) Class XMLParserGFEA061
	Local aRet 	as array
	Local nX 	as numeric
	Local aArea as array

	aRet := {}

	If ::lIsTab
		aArea := (::cAliasT)->(GetArea())

		(::cAliasT)->(DBGoTop())
		(::cAliasT)->(DbSkip(nRow))

		For nX := 1 to Len(::aFields)
			Aadd(aRet, (::cAliasT)->&(::aFields[nX][1]))
		Next

		RestArea(aArea)
	Else
		For nX := 1 to Len(::_xml)
			If !Empty(::_xml[nX])
				Aadd(aRet ,::_xml[nX]:aValues[nRow])
			EndIf
		Next
	EndIf

Return aRet

Method GetAllRows() Class XMLParserGFEA061
	Local aRet 	as array
	Local aLin  as array
	Local nX 	as numeric
	Local aArea as array

	aRet := {}

	If ::lIsTab
		aArea := (::cAliasT)->(GetArea())

		(::cAliasT)->(DBGoTop())
		While !(::cAliasT)->(EoF())
			For nX := 1 to Len(::aFields)
				Aadd(aLin, (::cAliasT)->&(::aFields[nX][1]))
			Next
			Aadd(aRet, aLin)
			(::cAliasT)->(DbSkip())
		End

		RestArea(aArea)

	Else
		For nX := 1 to Len(::_xml)
			If !Empty(::_xml[nX])
				Aadd(aRet, ::_xml[nX]:aValues)
			EndIf
		Next
	EndIf

Return aRet

Method GetCol(cColumn, nRow) Class XMLParserGFEA061
	Local nX    as numeric
	Local aArea as array
	Local xRet := {}

	If nRow <> Nil

		If ::lIsTab
			aArea := (::cAliasT)->(GetArea())

			For nX := 1 to Len(::aFields)
				If cColumn == ::aFields[nX][1]
					(::cAliasT)->(DbGoTop())
					(::cAliasT)->(DbSkip(nRow))

					xRet := (::cAliasT)->&(::aFields[nX][1])
				EndIf
			Next
			RestArea(aArea)

		Else
			For nX := 1 to Len(::_xml)
				If !Empty(::_xml[nX])
					If ::_xml[nX]:cTitle == cColumn
						If !nRow > Len(::_xml[nX]:aValues)
							xRet := ::_xml[nX]:aValues[nRow]
						Else
							xRet := ""
						EndIf
						Exit
					EndIf
				EndIf
			Next
		EndIf

	Else
		If ::lIsTab
			aArea := (::cAliasT)->(GetArea())

			For nX := 1 To Len(::aFields)
				If cColumn == ::aFields[nX][1]
					xRet := {}
					(::cAliasT)->(DbGoTop())

					While !(::cAliasT)->(EoF())
						Aadd(xRet, (::cAliasT)->&(::aFields[nX][1]))
						(::cAliasT)->(DbSkip())
					End
					Exit
				EndIf
			Next

			RestArea(aArea)
		Else
			For nX := 1 to Len(::_xml)
				If ::_xml[nX]:cTitle == cColumn
					xRet := ::_xml[nX]:aValues
					Exit
				EndIf
			Next
		EndIf
	EndIf

Return xRet

Method GetTotalRows() Class XMLParserGFEA061

Return ::nRow

CLASS Column 

	DATA cTitle
	DATA aValues

	Method New() Constructor
	Method AddValue()

ENDCLASS

Method New(cText) Class Column

	::cTitle  := cText
	::aValues := {}

Return Self

Method AddValue(xValue) Class Column
	Aadd(::aValues, xValue)
Return

Static Function CriaTabTmp()
    Local oTemGV8 as object
    Local oTemGUY as object
    Local oTemGV6 as object
    Local oTemGV1 as object
    Local oTemGV7 as object
	Local oTemGVW as object
	
	Local lFRACEX := GFXCP2610("GV1_FRACEX")
    
    _aFields := {;
                {'TRANSP',TamSx3('GV9_CDEMIT')[3],TamSX3('GV9_CDEMIT')[1],TamSX3('GV9_CDEMIT')[2]},;
                {'NRTAB' ,TamSx3('GV9_NRTAB')[3] ,TamSX3('GV9_NRTAB')[1] ,TamSX3('GV9_NRTAB')[2]},;
                {'NRNEG' ,TamSx3('GV9_NRNEG')[3] ,TamSX3('GV9_NRNEG')[1] ,TamSX3('GV9_NRNEG')[2]},;
                {'ORIGEM',TamSx3('GV8_CDREM')[3] ,TamSX3('GV8_CDREM')[1] ,TamSX3('GV8_CDREM')[2]},;
                {'DESTIN',TamSx3('GV8_CDREM')[3] ,TamSX3('GV8_CDREM')[1] ,TamSX3('GV8_CDREM')[2]},;
                {'NRROTA',TamSx3('GV8_NRROTA')[3] ,TamSX3('GV8_NRROTA')[1] ,TamSX3('GV8_NRROTA')[2]};
            	}

	If Select(_cAliaGV8) > 0
		(_cAliaGV8)->(DbCloseArea())
	EndIf

	oTemGV8 := FwTemporaryTable():New(_cAliaGV8,_aFields)
	oTemGV8:AddIndex('1', {'TRANSP',; 
							'NRTAB',;
							'NRNEG',;    
							'ORIGEM',; 
							'DESTIN' })

	oTemGV8:Create()

    _aFields := {;
                {'TRANSP',TamSx3('GV9_CDEMIT')[3] ,TamSX3('GV9_CDEMIT')[1],TamSX3('GV9_CDEMIT')[2]},;
                {'NRTAB' ,TamSx3('GV9_NRTAB')[3]  ,TamSX3('GV9_NRTAB')[1] ,TamSX3('GV9_NRTAB')[2]},;
                {'NRNEG' ,TamSx3('GV9_NRNEG')[3]  ,TamSX3('GV9_NRNEG')[1] ,TamSX3('GV9_NRNEG')[2]},;
                {'TPVEIC',TamSx3('GV7_CDTPVC')[3] ,TamSX3('GV7_CDTPVC')[1],TamSX3('GV7_CDTPVC')[2]},;
                {'FAIXAF',TamSx3('GV7_QTFXFI')[3] ,TamSX3('GV7_QTFXFI')[1],TamSX3('GV7_QTFXFI')[2]},;
                {'CDFXTV',TamSx3('GV7_CDFXTV')[3] ,TamSX3('GV7_CDFXTV')[1],TamSX3('GV7_CDFXTV')[2]};
            	}

	If Select(_cAliaGV7) > 0
		(_cAliaGV7)->(DbCloseArea())
	EndIf

	oTemGV7 := FwTemporaryTable():New(_cAliaGV7,_aFields)
	oTemGV7:AddIndex('1', {'TRANSP',; 
						   'NRTAB',;
						   'NRNEG',;    
						   'TPVEIC',;
						   'FAIXAF' })

	oTemGV7:Create()

    _aFields := {;
                {'TRANSP',TamSx3('GV9_CDEMIT')[3],TamSX3('GV9_CDEMIT')[1],TamSX3('GV9_CDEMIT')[2]},;
                {'NRTAB' ,TamSx3('GV9_NRTAB')[3] ,TamSX3('GV9_NRTAB')[1] ,TamSX3('GV9_NRTAB')[2]},;
                {'NRNEG' ,TamSx3('GV9_NRNEG')[3] ,TamSX3('GV9_NRNEG')[1] ,TamSX3('GV9_NRNEG')[2]},;
                {'COMPON',TamSx3('GUY_CDCOMP')[3] ,TamSX3('GUY_CDCOMP')[1] ,TamSX3('GUY_CDCOMP')[2]};
            	}

	If Select(_cAliaGUY) > 0
		(_cAliaGUY)->(DbCloseArea())
	EndIf

	oTemGUY := FwTemporaryTable():New(_cAliaGUY,_aFields)
	oTemGUY:AddIndex('1', {'TRANSP',; 
						   'NRTAB',;
						   'NRNEG',;     
						   'COMPON' })

	oTemGUY:Create()

	////// ------------------- GVW
	If GFXCP12125("GVW_CDEMIT")
		_aFields := {;
                	{'TRANSP',TamSx3('GV9_CDEMIT')[3],TamSX3('GV9_CDEMIT')[1],TamSX3('GV9_CDEMIT')[2]},;
                	{'NRTAB' ,TamSx3('GV9_NRTAB')[3] ,TamSX3('GV9_NRTAB')[1] ,TamSX3('GV9_NRTAB')[2]},;
                	{'NRNEG' ,TamSx3('GV9_NRNEG')[3] ,TamSX3('GV9_NRNEG')[1] ,TamSX3('GV9_NRNEG')[2]},;
                	{'NRCT'  ,TamSx3('GVW_NRCT')[3]  ,TamSX3('GVW_NRCT')[1]  ,TamSX3('GVW_NRCT')[2]};
            		}

        If Select(_cAliaGVW) > 0
			(_cAliaGVW)->(DbCloseArea())
		EndIf

        oTemGVW := FwTemporaryTable():New(_cAliaGVW,_aFields)
        oTemGVW:AddIndex('1', {'TRANSP',; 
                               'NRTAB',;
                               'NRNEG',;     
                               'NRCT' })

        oTemGVW:Create()
    EndIf
    ////// ------------------- GVW

    _aFields := {;
                {'TRANSP',TamSx3('GV9_CDEMIT')[3],TamSX3('GV9_CDEMIT')[1],TamSX3('GV9_CDEMIT')[2]},;
                {'NRTAB' ,TamSx3('GV9_NRTAB')[3] ,TamSX3('GV9_NRTAB')[1] ,TamSX3('GV9_NRTAB')[2]},;
                {'NRNEG' ,TamSx3('GV9_NRNEG')[3] ,TamSX3('GV9_NRNEG')[1] ,TamSX3('GV9_NRNEG')[2]},;
                {'CDFXTV' ,TamSx3('GV6_CDFXTV')[3] ,TamSX3('GV6_CDFXTV')[1] ,TamSX3('GV6_CDFXTV')[2]},;
                {'NRROTA',TamSx3('GV6_NRROTA')[3] ,TamSX3('GV6_NRROTA')[1] ,TamSX3('GV6_NRROTA')[2]},;
                {'PRAZO',TamSx3('GV6_QTPRAZ')[3] ,TamSX3('GV6_QTPRAZ')[1] ,TamSX3('GV6_QTPRAZ')[2]},;
                {'CONSPZ',TamSx3('GV6_CONSPZ')[3] ,TamSX3('GV6_CONSPZ')[1] ,TamSX3('GV6_CONSPZ')[2]},;
                {'TPPRAZ',TamSx3('GV6_TPPRAZ')[3] ,TamSX3('GV6_TPPRAZ')[1] ,TamSX3('GV6_TPPRAZ')[2]},;
                {'CONTPZ',TamSx3('GV6_CONTPZ')[3] ,TamSX3('GV6_CONTPZ')[1] ,TamSX3('GV6_CONTPZ')[2]};
            	}

	If Select(_cAliaGV6) > 0
		(_cAliaGV6)->(DbCloseArea())
	EndIf

	oTemGV6 := FwTemporaryTable():New(_cAliaGV6,_aFields)
	oTemGV6:AddIndex('1', { 'TRANSP',; 
                            'NRTAB',;
                            'NRNEG',;
                            'CDFXTV',; 
                            'NRROTA' })

	oTemGV6:Create()

    _aFields := {;
                {'TRANSP',TamSx3('GV9_CDEMIT')[3],TamSX3('GV9_CDEMIT')[1],TamSX3('GV9_CDEMIT')[2]},;
                {'NRTAB' ,TamSx3('GV9_NRTAB')[3] ,TamSX3('GV9_NRTAB')[1] ,TamSX3('GV9_NRTAB')[2]},;
                {'NRNEG' ,TamSx3('GV9_NRNEG')[3] ,TamSX3('GV9_NRNEG')[1] ,TamSX3('GV9_NRNEG')[2]},;
                {'CDFXTV',TamSx3('GV6_CDFXTV')[3] ,TamSX3('GV6_CDFXTV')[1] ,TamSX3('GV6_CDFXTV')[2]},;
                {'NRROTA',TamSx3('GV6_NRROTA')[3] ,TamSX3('GV6_NRROTA')[1] ,TamSX3('GV6_NRROTA')[2]},;
                {'COMPON',TamSx3('GV1_CDCOMP')[3] ,TamSX3('GV1_CDCOMP')[1] ,TamSX3('GV1_CDCOMP')[2]},;
                {'VLFIXO',TamSx3('GV1_VLFIXN')[3] ,TamSX3('GV1_VLFIXN')[1] ,TamSX3('GV1_VLFIXN')[2]},;
                {'VLUNIT',TamSx3('GV1_VLUNIN')[3] ,TamSX3('GV1_VLUNIN')[1] ,TamSX3('GV1_VLUNIN')[2]},;
                {'PERVAL',TamSx3('GV1_PCNORM')[3] ,TamSX3('GV1_PCNORM')[1] ,TamSX3('GV1_PCNORM')[2]},;
                {'VALMIN',TamSx3('GV1_VLMINN')[3] ,TamSX3('GV1_VLMINN')[1] ,TamSX3('GV1_VLMINN')[2]},;
                {'VALLIM',TamSx3('GV1_VLLIM')[3]  ,TamSX3('GV1_VLLIM')[1]  ,TamSX3('GV1_VLLIM')[2]},;
                {'VLFIXE',TamSx3('GV1_VLFIXE')[3] ,TamSX3('GV1_VLFIXE')[1] ,TamSX3('GV1_VLFIXE')[2]},;
                {'PCEXTR',TamSx3('GV1_PCEXTR')[3] ,TamSX3('GV1_PCEXTR')[1] ,TamSX3('GV1_PCEXTR')[2]},;
                {'VLUNIE',TamSx3('GV1_VLUNIE')[3] ,TamSX3('GV1_VLUNIE')[1] ,TamSX3('GV1_VLUNIE')[2]},;
                {'CALCEX',TamSx3('GV1_CALCEX')[3] ,TamSX3('GV1_CALCEX')[1] ,TamSX3('GV1_CALCEX')[2]},;
                {'FRACAO',TamSx3('GV1_VLFRAC')[3] ,TamSX3('GV1_VLFRAC')[1] ,TamSX3('GV1_VLFRAC')[2]};
            	}

	If lFRACEX
		Aadd(_aFields,{'FRACEX',TamSx3('GV1_FRACEX')[3] ,TamSX3('GV1_FRACEX')[1] ,TamSX3('GV1_FRACEX')[2]})
	EndIf

	If Select(_cAliaGV1) > 0
		(_cAliaGV1)->(DbCloseArea())
	EndIf

	oTemGV1 := FwTemporaryTable():New(_cAliaGV1,_aFields)
	oTemGV1:AddIndex('1',{'TRANSP',; 
						  'NRTAB',;
						  'NRNEG',;
						  'CDFXTV',;
						  'NRROTA',;
						  'COMPON' })

	oTemGV1:Create()
Return

Function criaGV9(cChave, lSim)
	Local cChGV6    as char
	Local lFound    := .F.
	Local lGV6   	:= .F.
	Local aArea     := GV9->(GetArea())
	Local oModelGV1 := oModelTRF:GetModel("DETAIL_GV1")
	Local lFRACEX	:= GFXCP2610("GV1_FRACEX")

	If oModelNeg:VldData()
		If lSim
			cLogTxt += LogMessage("AVISO: Operação simulada com Sucesso." + CRLF)
			Aadd(aLog, cLogTxt)
			cLogTxt := ""
		Else
			oModelNeg:CommitData()
			cLogTxt += LogMessage("AVISO: Negociação "+cAcao+" com Sucesso." + CRLF)

			If GFXCP12125("GVW_CDEMIT")
				If lFoundGXT
					(_cAliaGVW)->(DBGoTop())
					While !(_cAliaGVW)->(EoF())
						If cChave == (_cAliaGVW)->TRANSP + (_cAliaGVW)->NRTAB + (_cAliaGVW)->NRNEG
							GVW->(DbCloseArea())
							GVW->(DbSetOrder(1))
							IF !GVW->(dbSeek(xFilial("GVW")+(_cAliaGVW)->TRANSP + (_cAliaGVW)->NRTAB + (_cAliaGVW)->NRNEG + xFilial("GXT") + (_cAliaGVW)->NRCT))
								oModelCTR:SetOperation(MODEL_OPERATION_INSERT)
								criaGVW()
							EndIf
						EndIf

						(_cAliaGVW)->(DbSkip())
					End
				EndIf
			EndIf

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			oModelNeg:Deactivate()

			// Após a criação da negociação, realiza a criação das Tarifas (GV6 e GV1)
			(_cAliaGV6)->(DBGoTop())
			Do While !(_cAliaGV6)->(Eof())
				If Empty(cChave) .or. ((_cAliaGV6)->TRANSP + (_cAliaGV6)->NRTAB + (_cAliaGV6)->NRNEG == cChave)
					// Se for uma nova tarifa realiza a criação da tarifa anterior
					If !EMPTY(cChGV6) .And. cChGV6 <> (_cAliaGV6)->TRANSP + (_cAliaGV6)->NRTAB + (_cAliaGV6)->NRNEG + (_cAliaGV6)->CDFXTV+ (_cAliaGV6)->NRROTA
						lGV6 = .T.

						criaGV6(cChGV6)
					EndIf

					If Empty(cChGV6) .or. (cChGV6 <> (_cAliaGV6)->TRANSP + (_cAliaGV6)->NRTAB + (_cAliaGV6)->NRNEG + (_cAliaGV6)->CDFXTV+(_cAliaGV6)->NRROTA)
						lGV6 := .F.
						cChGV6 := (_cAliaGV6)->TRANSP + (_cAliaGV6)->NRTAB + (_cAliaGV6)->NRNEG + (_cAliaGV6)->CDFXTV + (_cAliaGV6)->NRROTA	
					EndIf

					GV9->(DbCloseArea())
					GV9->(DbSetOrder(1))
					If GV9->(DbSeek(xFilial("GV9")+(_cAliaGV6)->TRANSP+(_cAliaGV6)->NRTAB+(_cAliaGV6)->NRNEG))
						lFound := .T.

						GV6->(DbSetOrder(1))
						If !GV6->(DbSeek(xFilial("GV6")+(_cAliaGV6)->TRANSP+(_cAliaGV6)->NRTAB+(_cAliaGV6)->NRNEG+(_cAliaGV6)->CDFXTV+(_cAliaGV6)->NRROTA))
							//Cria
							oModelTRF:Activate()
							
							If FWModeAccess("GV6",1) == "E"
								oModelTRF:LoadValue("GFEA061F_GV6","GV6_FILIAL", xFilial('GV6') )
							EndIf
							
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_CDEMIT", (_cAliaGV6)->TRANSP)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_NRTAB" , (_cAliaGV6)->NRTAB)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_NRNEG" , (_cAliaGV6)->NRNEG)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_CDFXTV", (_cAliaGV6)->CDFXTV)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_NRROTA", (_cAliaGV6)->NRROTA)
						Else
							oModelTRF:Activate()
						EndIf

						If !Empty(oXmlParser:GetCol("PRAZO"))
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_QTPRAZ", (_cAliaGV6)->PRAZO)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_CONSPZ", (_cAliaGV6)->CONSPZ)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_TPPRAZ", (_cAliaGV6)->TPPRAZ)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_CONTPZ", (_cAliaGV6)->CONTPZ)
						Else
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_QTPRAZ", 0)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_CONSPZ", "0")
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_TPPRAZ", "0")
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_CONTPZ", "0")
						EndIf

						(_cAliaGV1)->(DBGoTop())
						Do While !(_cAliaGV1)->(Eof())
							If AllTrim((_cAliaGV1)->TRANSP) + AllTrim((_cAliaGV1)->NRTAB) + AllTrim((_cAliaGV1)->NRNEG) + AllTrim((_cAliaGV1)->CDFXTV) + AllTrim((_cAliaGV1)->NRROTA)  == ;
								AllTrim((_cAliaGV6)->TRANSP) + AllTrim((_cAliaGV6)->NRTAB) + AllTrim((_cAliaGV6)->NRNEG) + AllTrim((_cAliaGV6)->CDFXTV) + AllTrim((_cAliaGV6)->NRROTA)

								GV1->(DbSetOrder(1))
								If !GV1->(DbSeek(xFilial("GV1")+(_cAliaGV1)->TRANSP+(_cAliaGV1)->NRTAB+(_cAliaGV1)->NRNEG+(_cAliaGV1)->CDFXTV+(_cAliaGV1)->NRROTA+(_cAliaGV1)->COMPON))
									//Cria
									If oModelGV1:GetQtdLine() > 1 .or. !Empty(oModelGV1:GetValue('GV1_CDCOMP',1))
										oModelGV1:Addline(.T.)
									EndIf

									oModelGV1:LoadValue("GV1_CDEMIT", (_cAliaGV6)->TRANSP)
									oModelGV1:LoadValue("GV1_NRTAB" , (_cAliaGV6)->NRTAB)
									oModelGV1:LoadValue("GV1_NRNEG" , (_cAliaGV6)->NRNEG)
									oModelGV1:LoadValue("GV1_CDFXTV", (_cAliaGV6)->CDFXTV)
									oModelGV1:LoadValue("GV1_NRROTA", (_cAliaGV6)->NRROTA)
									oModelGV1:LoadValue("GV1_CDCOMP", (_cAliaGV1)->COMPON)
								EndIf

								oModelGV1:SeekLine({{"GV1_CDCOMP", (_cAliaGV1)->COMPON}})

								oModelGV1:LoadValue("GV1_VLFIXN", (_cAliaGV1)->VLFIXO)
								oModelGV1:LoadValue("GV1_VLUNIN", (_cAliaGV1)->VLUNIT)
								oModelGV1:LoadValue("GV1_PCNORM", (_cAliaGV1)->PERVAL)
								oModelGV1:LoadValue("GV1_VLMINN", (_cAliaGV1)->VALMIN)
								oModelGV1:LoadValue("GV1_VLLIM" , (_cAliaGV1)->VALLIM)
								oModelGV1:LoadValue("GV1_VLFIXE", (_cAliaGV1)->VLFIXE)
								oModelGV1:LoadValue("GV1_PCEXTR", (_cAliaGV1)->PCEXTR)
								oModelGV1:LoadValue("GV1_VLUNIE", (_cAliaGV1)->VLUNIE)
								oModelGV1:LoadValue("GV1_CALCEX", (_cAliaGV1)->CALCEX)
								oModelGV1:LoadValue("GV1_VLFRAC", (_cAliaGV1)->FRACAO)

								If lFRACEX
									oModelGV1:LoadValue("GV1_FRACEX", (_cAliaGV1)->FRACEX)	
								EndIf
							EndIf
							(_cAliaGV1)->(DBSkip())
						End
					EndIf
				EndIf
				(_cAliaGV6)->(DBSkip())
			End

			If !lGV6 .and. lFound
				criaGV6(,lSim)
			EndIf
		EndIf
	Else
		cLogTxt += LogMessage(oModelNeg:GetErrorMessage()[6] + CRLF)
		cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
		Aadd(aLog, cLogTxt)
		cLogTxt := ""
		oModelNeg:Deactivate()
	EndIf
	RestArea(aArea)
Return

Function criaGV6(cChave, lSim)

	If oModelTRF:VldData()
		If !lSim
			oModelTRF:CommitData()
			cLogTxt += LogMessage("AVISO: Informações da Tarifa "+cAcao+" com Sucesso." + CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			Aadd(aLog, cLogTxt)
			cLogTxt := ""
		Else
			cLogTxt += LogMessage("AVISO: Informações da Tarifa simuladas com Sucesso." + CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			Aadd(aLog, cLogTxt)
			cLogTxt := ""
		EndIf
	Else
		cLogTxt += LogMessage(oModelTRF:GetErrorMessage()[6] + CRLF)
		cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
		Aadd(aLog, cLogTxt)
		cLogTxt := ""
	EndIf

	oModelTRF:Deactivate()
Return

Function criaGVW()

	oModelCTR:Activate()

	oModelCTR:LoadValue("GFEA083_GVW","GVW_CDEMIT", (_cAliaGVW)->TRANSP)
	oModelCTR:LoadValue("GFEA083_GVW","GVW_NRTAB" , (_cAliaGVW)->NRTAB )
	oModelCTR:LoadValue("GFEA083_GVW","GVW_NRNEG" , (_cAliaGVW)->NRNEG )
	oModelCTR:LoadValue("GFEA083_GVW","GVW_FILGXT", xFilial('GXT') )
	oModelCTR:LoadValue("GFEA083_GVW","GVW_NRCT"  , (_cAliaGVW)->NRCT  )

	If oModelCTR:VldData()
		oModelCTR:CommitData()
		cLogTxt += LogMessage("AVISO: Relação com contrato " + cAcao + " com Sucesso." + CRLF)
		Aadd(aLog, cLogTxt)
		cLogTxt := ""
	Else
		cLogTxt += LogMessage(oModelCTR:GetErrorMessage()[6] + CRLF)
		cLogTxt += LogMessage("AVISO: Não foi possível relacionar o contrato "+ AllTrim((_cAliaGVW)->NRCT) +" ao registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
		Aadd(aLog, cLogTxt)
		cLogTxt := ""
	EndIf

	oModelCTR:Deactivate()

Return


Static Function XmlArray(oTEMP,aNode)
Local lContinua := .T.
Local nCont     := 0
Local nFCont    := 0
Local oXML      := oTEMP
Local aDados	:= {}

	nFCont := Len(aNode)
	For nCont := 1 to nFCont
		If ValType( XmlChildEx( oXML,aNode[nCont]  ) ) == 'O'
			oXML :=  XmlChildEx( oXML,aNode[nCont]  )

		ElseIF ValType( XmlChildEx( oXML,aNode[nCont]  ) ) == 'A'
			aDados :=  XmlChildEx( oXML,aNode[nCont]  )
			Exit
		Else
			lContinua := .F.
		EndIf
	
	Next nCont

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA061JXML()
Função responsavel por realizar a leitura do XML quando é enviado via LibreOffice.
@author  Matheus de Souza
@since   07/07/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA061JXML(cXMLFile)
Local cError   := ""
Local cWarning := ""
Local oXml := NIL
Local lRet := .T.
Local nSize := 0
Local nHandle := 0
Local cBuffer := ""
Local aLinha := {}
Local ni := 0
Local nx := 0
Local cData := ""
Local aDados := {}
Local aRet := {}
Local nLinha := 0
Local aValor := {}
	
	nHandle := FOpen(cXMLFile,FO_READ+FO_SHARED) 

	If nHandle < 0
		cError := str(FError())
		aAdd(aErros,{cXMLFile,"Erro ao abrir arquivo: ( " + cError + CHR(13)+CHR(10), ")" + GFERetFError(FError())})
		lRet := .F.

	EndIf

	If lRet
		nSize := FSeek(nHandle,FS_SET,FS_END)
		FSeek(nHandle,0)
		FRead(nHandle,@cBuffer,nSize)

		oXML  := XmlParser( cBuffer , "_", @cError, @cWarning)
		FClose(nHandle)
		nHandle   := -1

	EndIF

	aLinha := XmlArray(oXML,{"_WORKBOOK","_SS_WORKSHEET"})
	If Len(aLinha) > 0
		aLinha := XmlArray(aLinha[1],{"_TABLE","_ROW"})
	Else
		aLinha := XmlArray(oXML,{"_WORKBOOK","_SS_WORKSHEET","_TABLE","_ROW"})
	EndIf
	nLinha := 0

	For ni := 1 To Len(aLinha)
		If ni == 2
			aDados := XmlArray(aLinha[ni],{"_CELL"})
			For nx := 1 To Len(aDados)
				cData := XmlValid(aDados[nx],{"_DATA"})
				Aadd(aRet,cData)
			
			Next nx

		ElseIf ni >= 3 
			nLinha++
			aDados := XmlArray(aLinha[ni],{"_CELL"})
			For nx := 1 To Len(aDados)
				If ni == 3
					Aadd(aValor,{})
				EndIf
				cData := XmlValid(aDados[nx],{"_DATA"})
				Aadd(aValor[nx],cData)
			
			Next nx
		
		EndIf

	Next ni

Return {aRet,nLinha,aValor}


//-------------------------------------------------------------------
/*/{Protheus.doc} VldDescCid()
Função responsável por validar o campo #DESTIN do arquivo XML. Caso o campo esteja vazio,
irá retornar a descrição da cidade através do seu respectivo código (cOri ou cDst).
@author  Philippe Rocca Bretas
@since   07/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------

STATIC FUNCTION VldDescCid(cOriDest)
		IF !Empty(cOriDest)
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT GU7_NMCID
					FROM %Table:GU7% GU7
					WHERE GU7_NRCID = %Exp:cOriDest%
					AND GU7.%NotDel%
				EndSql
				cNmCid := (cAliasQry)->GU7_NMCID
				(cAliasQry)->( dbGoTop() )
				(cAliasQry)->(DbCloseArea())
			ENDIF
RETURN cNmCid
