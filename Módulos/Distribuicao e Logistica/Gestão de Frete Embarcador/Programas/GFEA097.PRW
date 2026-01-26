#INCLUDE "GFEA097.ch"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA097
Envio de Faturas por Lote
Generico.

@sample
GFER097()

@author Israel Possoli
@since 08/04/2010
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA097()
	Local oReport                   //objeto que contem o relatorio
	
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
	
Return      

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA097
Envio de Faturas por Lote
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
	oReport:= TReport():New("GFEA097",STR0001,"GFEA097", {|oReport| ReportPrint(oReport)},STR0002)  //"Envio de Faturas por Lote"###"Envio de Faturas por Lote."
	oReport:SetLandscape()   // define se o relatorio saira deitado
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	oReport:SetTotalInLine(.F.)
	oReport:nFontBody	:= 10 // Define o tamanho da fonte.
	oReport:nLineHeight	:= 50 // Define a altura da linha.
	If !IsBlind()
		Pergunte("GFEA097",.F.)
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
	  
	oSection1 := TRSection():New(oReport,STR0003,{"GW6"},aOrdem)  //"Faturas"
	oSection1:SetLineStyle() //Define a impressao da secao em linha
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1,"GW6->GW6_NRFAT", "GW6", STR0004 , /**/, 16, /*lPixel*/, /*{|| code-block de impressao }*/) //"Fatura"
	
	
Return oReport

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA097
Envio de Faturas por Lote
Generico.

@sample
ReportPrint(oReport,cAliasQry)

@author Israel Alcantara Possoli
@since 08/04/09                              
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ReportPrint(oReport)
	Local oSection1  := oReport:Section(1)
	Local dDtTrans   := MV_PAR12
	Local lDtEmpty   := .F.
	Local aRet
	Local s_FTMLA    := SuperGetMV("MV_FTMLA", .F., "1")
	Local s_DTULFE   := SuperGetMv("MV_DTULFE",,"20000101")
	Local cIntFisc   := SuperGetMv("MV_GFEI23",.F.,"2")
	local lSelecaoDF := .T.
	local cERPGFE    :=  SuperGetMv("MV_ERPGFE",.F.,"1")
	Local aRetVld	 := {}
	Local aRetDes	 := {}
	
	If MV_PAR11 != 3
	
		If !Empty(dDtTrans) .And. dDtTrans <= s_DTULFE
			Help( ,, 'Help',, STR0005 + DTOC(s_DTULFE) + STR0006, 1, 0 ) //"Data de transação deve ser posterior a data do último fechamento: " //" (Parâmetro MV_DTULFE)"
			Return .F.
		ElseIf Empty(dDtTrans)
			lDtEmpty := .T.
		EndIf
	
	EndIf
		
	dbSelectArea("GW6")
	GW6->( dbSetOrder(1) )
	GW6->( dbSeek(MV_PAR01, .T.) )
	
	oSection1:Init()
	
	While !GW6->( Eof() ) .And. GW6->GW6_FILIAL >= MV_PAR01 .And. GW6->GW6_FILIAL <= MV_PAR02

		If GW6->GW6_EMIFAT >= MV_PAR03 .And. GW6->GW6_EMIFAT <= MV_PAR04 .And. ;
		   GW6->GW6_NRFAT  >= MV_PAR05 .And. GW6->GW6_NRFAT  <= MV_PAR06 .And. ;
		   GW6->GW6_SERFAT >= MV_PAR07 .And. GW6->GW6_SERFAT <= MV_PAR08 .And. ;
		   GW6->GW6_DTEMIS >= MV_PAR09 .And. GW6->GW6_DTEMIS <= MV_PAR10 .And. ;
		   IIf(MV_PAR11 == 3, Empty(GW6->GW6_DTFIN) .Or. GW6->GW6_DTFIN > s_DTULFE, IIf(!lDtEmpty, dDtTrans >= GW6->GW6_DTEMIS, .T.))
		   
		   IF s_FTMLA == "4" .And. GW6->GW6_SITMLA <> "4"
		      GW6->( dbSkip() )
	          Loop
		   EndIf
		   		   
		   	If lDtEmpty
				If GW6->GW6_DTCRIA < s_DTULFE
	           		GW6->( dbSkip() )
	           		Loop
	           	Else
	           		dDtTrans := GW6->GW6_DTCRIA
	           	EndIf
	   		EndIf
		   	
		   	/*Valida integração fiscal*/
		   	If cIntFisc == "1"					
				GW3->(dbSetOrder(8))
				If GW3->(dbSeek( GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS )))
					lSelecaoDF := .T.
				    While !GW3->( Eof() ) .AND. ;
				    	   GW3->GW3_FILFAT == GW6->GW6_FILIAL 		.AND. ;
				    	   GW3->GW3_EMIFAT == GW6->GW6_EMIFAT 		.AND. ;
				    	   GW3->GW3_SERFAT == GW6->GW6_SERFAT 		.AND. ;
				    	   GW3->GW3_NRFAT  == GW6->GW6_NRFAT  		.AND. ;
				    	   GW3->GW3_DTEMFA == GW6->GW6_DTEMIS 												
	
						// Verifica a situação da integração Fiscal								
						If (GW3->GW3_SITFIS != "4" .AND. GW3->GW3_SITFIS != "6" .AND. GW3->GW3_SITREC == "6") .OR.; //SIT. REC == 6 GARANTE QUE NÃO É DOC. FRETE SOBRE ENTRADAS
						   (GW3->GW3_SITREC != "4" .AND. GW3->GW3_SITREC != "6")  //ERP=DATASUL E ATUALIZA FISCAL VIA RECEBIMENTO E A SITUACAO REC <> ATUALIZADA OU <> NÃO SE APLICA		 	      

						   lSelecaoDF := .F.
						   Exit				  

						EndIF	
						
						GW3->( dbSkip() )					
					EndDo
					
					If lSelecaoDF == .F.
					   GW6->( dbSkip() )
	           		   Loop
	           		EndIf
	           							
				EndIF				
			EndIf
			/* */
		   	
		   	
			If (GW6->GW6_SITFIN == "1" .Or. GW6->GW6_SITFIN == "3" .Or. GW6->GW6_SITFIN == "4") .And. ;
			   (GW6->GW6_SITAPR == "3" .Or. GW6->GW6_SITAPR == "4")
			
				If (MV_PAR11 == 1 .And. GW6->GW6_SITFIN == "1") .Or. ; // Atualizar
		           (MV_PAR11 == 2 .And. GW6->GW6_SITFIN == "3") .Or. ; // Atu Rejeitado
		           (MV_PAR11 == 3 .And. GW6->GW6_SITFIN == "4") //Desatualizar
					
		           	If MV_PAR11 == 3
		           		aRetVld := VldDesAtuFatura()

						If aRetVld[1] == .T.
							RecLock("GW6",.F.)
								GW6->GW6_SITFIN := "5" // Pendente Desatualização
								GW6->GW6_USUFIN := cUserName
							GW6->(MsUnLock())

							If cERPGFE == "1"
								aRet := {.T., ""}
							ElseIf cERPGFE == "2"
								aRetDes := DesAtuFatura()
								If aRetDes[1] //Desatualização da Fatura no Financeiro
									//Manipular fatura após Desatualização no Financeiro
									If ExistBlock("GFEA0703")
										ExecBlock("GFEA0703",.F.,.F.,{})
									EndIf

									RecLock("GW6", .F.)
										GW6->GW6_SITFIN := "1"
										GW6->GW6_MOTFIN := ""
									GW6->( MsUnlock() )

									aRet := {.T., ""}
								Else
									RecLock("GW6", .F.)
										GW6->GW6_SITFIN := "4"
										GW6->GW6_MOTFIN := aRetDes[2]
									GW6->( MsUnlock() )

									aRet := {.F., aRetDes[2]}
								EndIf
							EndIf
						Else
							aRet := {.F., aRetVld[2]}
						EndIf
		           	Else
		           		aRet := GFEA070In("2", dDtTrans)
		           	EndIf
		           	
		           	If aRet[1]
	           			oSection1:PrintLine()
	           		EndIf		           	
				EndIf				
			EndIf			
		EndIf
		
		GW6->( dbSkip() )
		
	EndDo
	
	oSection1:Finish()
Return

