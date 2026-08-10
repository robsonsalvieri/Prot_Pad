/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA106
Atualização de Ocorrências por Lote
Generico.
 
@sample
GFER098()

@author Tamyris Ganzenmueller 
@since 06/02/2017
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA106()
	Local oReport                   //objeto que contem o relatorio
	Private aFilPerm   := FwUsrEmp(__cUserID)
	
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
	
Return      

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA106
Atualização de Ocorrências por Lote
Generico.

@sample
ReportDef()

@author Tamyris Ganzenmueller 
@since 06/02/2017
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ReportDef()
	Local oReport, oSection1
	Local aOrdem    := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= TReport():New("GFEA106","Atualização de Ocorrências por Lote","GFEA106", {|oReport| ReportPrint(oReport)},"Atualização de Ocorrências por Lote.")  
	oReport:SetLandscape()   // define se o relatorio saira deitado
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	oReport:SetTotalInLine(.F.)
	oReport:nFontBody	:= 10 // Define o tamanho da fonte.
	oReport:nLineHeight	:= 50 // Define a altura da linha.

	If !IsBlind()
		Pergunte("GFEA106",.F.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da secao utilizada pelo relatorio                               ³
	//³                                                                        ³
	//³TRSection():New                                                         ³
	//³ExpO1 : Objeto TReport que a secao pertence                             ³
	//³ExpC2 : Descricao da seçao                                              ³
	//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
	//³        sera considerada como principal para a seção.                   ³
	//³ExpA4 : Array com as Ordens do relatório                                ³
	//³ExpL5 : Carrega campos do SX3 como celulas                              ³
	//³        Default : False                                                 ³
	//³ExpL6 : Carrega ordens do Sindex                                        ³
	//³        Default : False                                                 ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da celulas da secao do relatorio                                ³
	//³                                                                        ³
	//³TRCell():New                                                            ³
	//³ExpO1 : Objeto TSection que a secao pertence                            ³
	//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
	//³ExpC3 : Nome da tabela de referencia da celula                          ³
	//³ExpC4 : Titulo da celula                                                ³
	//³        Default : X3Titulo()                                            ³
	//³ExpC5 : Picture                                                         ³
	//³        Default : X3_PICTURE                                            ³
	//³ExpC6 : Tamanho                                                         ³
	//³        Default : X3_TAMANHO                                            ³
	//³ExpL7 : Informe se o tamanho esta em pixel                              ³
	//³        Default : False                                                 ³
	//³ExpB8 : Bloco de código para impressao.                                 ³
	//³        Default : ExpC2                                                 ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	
	//Aadd( aOrdem, "Codigo" ) // "Sequência"
	  
	oSection1 := TRSection():New(oReport,"Ocorrências",{"GWD"},aOrdem)  
	oSection1:SetLineStyle() //Define a impressao da secao em linha
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1,"GWD->GWD_NROCO", "GWD", "Ocorrencia" , /**/, 8, /*lPixel*/, /*{|| code-block de impressao }*/) 
	
	/*************************************************************************/ 

Return(oReport)
/*************************************************************************************************************************************/   


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA106
Integração de Ocorrências por Lote
Generico.

@sample
ReportPrint(oReport,cAliasQry)

@author Tamyris Ganzenmueller
@since 26/01/2017                              
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local aRet
	Local cOcor := ""

	If !IsBlind()
		Pergunte("GFEA106",.F.)
	EndIf

	dbSelectArea("GWD")
	GWD->( dbSetOrder(1) )
	GWD->( dbSeek(MV_PAR01, .T.) )
	
	oSection1:Init()
	
	While !GWD->( Eof() ) .And. GWD->GWD_FILIAL >= MV_PAR01 .And. GWD->GWD_FILIAL <= MV_PAR02 
		
		If (GWD->GWD_CDTRP  >= MV_PAR03 .Or. Empty(MV_PAR03)) .And. (GWD->GWD_CDTRP  <= MV_PAR04 .Or. Empty(MV_PAR04)) .And. ;
		   (GWD->GWD_NROCO  >= MV_PAR05 .Or. Empty(MV_PAR05)) .And. (GWD->GWD_NROCO  <= MV_PAR06 .Or. Empty(MV_PAR06)) .And. ;
		   (GWD->GWD_DTCRIA >= MV_PAR07 .Or. Empty(MV_PAR07)) .And. (GWD->GWD_DTCRIA <= MV_PAR08 .Or. Empty(MV_PAR08)) .And. ;
		     Empty(GWD->GWD_CHVEXT)
		    		     	      	
			If (MV_PAR09 == 1 .AND. (GWD->GWD_SITTMS != "2" .Or.  GWD->GWD_SIT != "2")) .Or. ; // Atualizar
			   (MV_PAR09 == 2 .AND. (GWD->GWD_SITTMS != "3" .Or.  GWD->GWD_SIT != "2")) .Or.; // Atu Rejeitado
			   (MV_PAR09 == 3 .AND. GWD->GWD_SITTMS != "4") //Desatualizar
			   			   		   		    
			    GWD->( dbSkip() )
				Loop
			   
			EndIf
  			
  			cOcor := GWD->GWD_FILIAL+GWD->GWD_NROCO
  			
  			If MV_PAR09 == 3
	           	aRet :=  GFE032TMSINT(,.F.,'6')  //Desatualizar
	    	Else
	    		aRet := GFE032TMSINT(,.F.,'3') 
	    	EndIf
	    	
	    	GWD->( dbSeek(cOcor, .T.) )
	    	
	    	If aRet
           		oSection1:PrintLine()
            EndIf
		EndIf
					  
		GWD->( dbSkip() )
			
	EndDo
	
	oSection1:Finish()
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA106FIL

Validação da filial para o Pergunte

@author Israel A. Possoli
@since 19/09/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA106FIL(cFil)

	If Empty(cFil)
		Help( ,, 'HELP',, "É necessário informar a filial.", 1, 0,)
		Return .F.
	EndIf
	
	If !ExistCpo("SM0", cEmpAnt+cFil)
		Return .F.
	EndIf

	// A função retorna "@@@@" quando o usuário possui acesso a todas as empresas e filiais do sistema
	If Len(aFilPerm) > 0 .And. AScan(aFilPerm,"@@@@") <= 0 .And. AScan(aFilPerm,AllTrim(cEmpAnt+cFil)) <= 0
		Help( ,, 'HELP',, "Usuário sem permissão de acesso à filial " + cFil + ".", 1, 0)
		Return .F.
	EndIf


Return .T.