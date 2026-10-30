#INCLUDE "GFEA098.ch"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA098
Envio de Contratos por Lote
Generico.

@sample
GFER098()

@author Israel Possoli
@since 08/04/2010
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA098()
	Local oReport                   //objeto que contem o relatorio
	
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
	
Return      

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA098
Envio de Contratos por Lote
Generico.

@sample
ReportDef()

@author Israel Possoli
@since 08/04/2010
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
	oReport:= TReport():New("GFEA098",STR0001,"GFEA098", {|oReport| ReportPrint(oReport)},STR0001)  //"Envio de Contratos por Lote"###"Envio de Contratos por Lote."
	oReport:SetLandscape()   // define se o relatorio saira deitado
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	oReport:SetTotalInLine(.F.)
	oReport:nFontBody	:= 10 // Define o tamanho da fonte.
	oReport:nLineHeight	:= 50 // Define a altura da linha.
	
	If !IsBlind()
		Pergunte("GFEA098",.F.)
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
	  
	oSection1 := TRSection():New(oReport,STR0002,{"GW2"},aOrdem)  //"Contratos"
	oSection1:SetLineStyle() //Define a impressao da secao em linha
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1,"GW2->GW2_NRCONT", "GW2", STR0003 , /**/, 8, /*lPixel*/, /*{|| code-block de impressao }*/) //"Contrato"
	
	/*************************************************************************/ 

Return(oReport)
/*************************************************************************************************************************************/   


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA098
Envio de Contratos por Lote
Generico.

@sample
ReportPrint(oReport,cAliasQry)

@author Israel Alcantara Possoli
@since 08/04/09                              
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local cAcao     := AllTrim(Str(MV_PAR11))
	Local dDtTrans  := MV_PAR10
	Local aRet
	Local s_DTULFE := SuperGetMv("MV_DTULFE",,"20000101")
	
	If MV_PAR09 != 3
	
		If Empty(dDtTrans)
			dDtTrans := Date()
		EndIf
		
		If dDtTrans < s_DTULFE
			Help( ,, 'Help',, STR0004 + DTOC(s_DTULFE) + STR0005, 1, 0 ) //"Data de transação deve ser posterior a data do último fechamento: " //" (Parâmetro MV_DTULFE)"
			Return .F.
		EndIf
		
	EndIf
	
	dbSelectArea("GW2")
	GW2->( dbSetOrder(1) )
	GW2->( dbSeek(MV_PAR01, .T.) )
	
	oSection1:Init()
	
	While !GW2->( Eof() ) .And. GW2->GW2_FILIAL  >= MV_PAR01 .And. GW2->GW2_FILIAL <= MV_PAR02
		
		If (GW2->GW2_CDPROP  >= MV_PAR03 .Or. Empty(MV_PAR03)) .And. GW2->GW2_CDPROP <= MV_PAR04 .And. ;
		   (GW2->GW2_NRCONT  >= MV_PAR05 .Or. Empty(MV_PAR05)) .And. GW2->GW2_NRCONT <= MV_PAR06 .And. ;
		   (GW2->GW2_DTCRIA  >= MV_PAR07 .Or. Empty(MV_PAR07)) .And. GW2->GW2_DTCRIA <= MV_PAR08 .And. ;
		   GW2->GW2_SITCON == "3"
		   
		    // Financeiro
			If cAcao == "1" 
		   
				If (MV_PAR09 != 3 .And. dDtTrans < GW2->GW2_DTCRIA) .Or. (MV_PAR09 == 3 .And. !Empty(GW2->GW2_DTFIN) .And. GW2->GW2_DTFIN <= s_DTULFE)
					GW2->( dbSkip() )
					Loop
				EndIf
				
				If (MV_PAR09 == 1 .AND. GW2->GW2_SITFIN != "1").Or.; // Atualizar
				   (MV_PAR09 == 2 .AND. GW2->GW2_SITFIN != "3").Or.; // Atu Rejeitado
				   (MV_PAR09 == 3 .AND. GW2->GW2_SITFIN != "4") //Desatualizar
				    
				    GW2->( dbSkip() )
					Loop
				   
				EndIf
			
			ElseIf cAcao == "2"
		        
        		If (GW2->GW2_SITFIN != "4" .And. MV_PAR09 != 3) .Or. (MV_PAR09 == 3 .And. !Empty(GW2->GW2_DTRH) .And. GW2->GW2_DTRH <= s_DTULFE)
        			GW2->( dbSkip() )
		 			Loop
		        EndIf
		        
				If (MV_PAR09 == 1 .AND. GW2->GW2_SITRH != "1") .Or. ; // Atualizar
				   (MV_PAR09 == 2 .AND. GW2->GW2_SITRH != "3") .Or. ; // Atu Rejeitado
				   (MV_PAR09 == 3 .AND. GW2->GW2_SITRH != "4") //Desatualizar
				   
					GW2->( dbSkip() )
				    Loop
				   
				EndIf
				
		    ElseIf cAcao == "3"
		    	
		    	If MV_PAR09 == 3 .And. !Empty(GW2->GW2_DTREC) .And. GW2->GW2_DTREC <= s_DTULFE
		    		
		    		GW2->( dbSkip() )
				    Loop
		    		
		    	EndIf
		    	
		    	If (MV_PAR09 == 1 .AND. GW2->GW2_SITREC != "1") .Or. ; // Atualizar
				   (MV_PAR09 == 2 .AND. GW2->GW2_SITREC != "3") .Or. ; // Atu Rejeitado
				   (MV_PAR09 == 3 .AND. GW2->GW2_SITREC != "4") //Desatualizar
				   
					GW2->( dbSkip() )
				    Loop
				   
				EndIf
		    	
		    EndIf
  			
  			If MV_PAR09 == 3
	           	aRet := GFEA100In("5", , cAcao)
	    	Else
	    		aRet := GFEA100In("2", dDtTrans, cAcao)
	    	EndIf
	    	
	    	If aRet[1]
           		oSection1:PrintLine()
           	EndIf
			
		EndIf
		
		GW2->( dbSkip() )
		
	EndDo
	
	oSection1:Finish()
	
Return

