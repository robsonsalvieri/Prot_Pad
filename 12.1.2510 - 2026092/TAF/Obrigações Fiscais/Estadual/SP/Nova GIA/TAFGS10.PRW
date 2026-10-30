#Include "Protheus.ch" 

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGS10

Rotina de geração do registro CR=10 da GIA-SP - DETALHES CFOPs

@Param cCNAE		->	CNAE da Filial que de geração
cCNPJ   	->	Cnpj da Filial que de geração
cInscEst  	->	Inscrição Estadual da Filial que de geração
aWizard	->	Array com as informacoes da Wizard
cFilSel	->	Filiais selecionadas para o processamento
cJobAux	->	Responsável pelo controle de término do Bloco - Multi Thread

@Author Paulo V.B. Santana
@Since 17/04/2015
@Version 1.0

/*/
//---------------------------------------------------------------------
Function TAFGS10( aWizard, cFilSel, cJobAux, cInscEst, cCNPJ, cCNAE, cMesRef, cAnoRef, lSomaFil, cIn, oReport )

Local oError			:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description,3,.T.,"GIA") } )
Local cREG 				:= "CR10" + cInscEst
Local cStrTxt 			:= ""
Local ni 				:= 0
Local nx 				:= 0
Local cTxtSys  			:= CriaTrab( , .F. ) + ".TXT"
Local nHandle    		:= MsFCreate( cTxtSys )
Local cAnoMesRef 		:= ""
Local nValor			:= 0
Local cRegistro 		:= ""
Local nVlrCont1  		:= 0 // Valor_Contábil_1
Local nVlrBase1  		:= 0 // BaseCálculo_1
Local nVlrCont2  		:= 0 // Valor_Contábil_2
Local nVlrBase2  		:= 0 // BaseCálculo_2
Local nImposto   		:= 0 // Imposto
Local nOutros    		:= 0 // Outros
Local nVlIcmsST  		:= 0 // ICMSCobradoST
Local nPetrEnerg 		:= 0 // PetróleoEnergia
Local nOutroProd 		:= 0 // Outros Produtos
Local nVlCont    		:= 0 // Vlr Contabil
Local nValDoc			:= 0 // Vlr doc
Local nBase      		:= 0 // Base de Calculo
Local cCFOP	   			:= ""// CFOP
Local nSbtuto    		:= 0 // ImpRetSubstitutoST
Local nSbtuido   		:= 0 // ImpRetSubstituído
Local nIsentoNT  		:= 0 // IsentasNãoTrib
Local nOutroImp  		:= 0 // OutrosImp
Local cNumDoc    		:= ""
Local cMunGIa    		:= ""
Local cCNPJDest  		:= ""
Local cDtDoc     		:= ""
Local cEstado    		:= ""
Local cAliasQry  		:= GetNextAlias()
Local cAliasQry1 		:= GetNextAlias()
Local lFound     		:= .T.
Local aRegCR10			:= {}
Local aRegCR14			:= {}
Local aRegCR18			:= {}
Local nQtd10			:= 0
Local aMungia			:= {}
Local lContrib			:= .f.
Local nQtd14			:= 0

// Variaveis do relatório
Local lReport           := .F.
Local lSecaoEnt         := .T.
Local lSecaoSai         := .T.
Local lTemCR14          := .F.
Local cTipoCfop         := ""
Local nImpRet           := 0 // Imposto Retido
Local oTpCfop           := ""
Local oCr10             := Nil
Local oCr14             := Nil
// ----------

Default cMesRef			:= ""
Default	cAnoRef			:= ""
Default	lSomaFil		:= .F.
Default	cIn				:= ""
Default oReport         := Nil

If oReport != Nil
	lReport := .T.
	oTpCfop := oReport:Section( 1 ):Section( 1 )
	oCr10   := oTpCfop:Section( 1 ) // Estrutura com os campos do CR10
	oCr14   := oCr10:Section( 1 ) // Estrutura com os campos do CR14
EndIf

/*-------------------------------------------------------------------------------
Tratamento para verificação da existência do campo C20_UF para o caso de notas de 
entrada, com UF divergente do fornecedor origem DSERTAF2-1177/DSERTAF2-1134
-------------------------------------------------------------------------------*/
If !TAFColumnPos( "C20_UF" ) 
	Aviso( "Dicionário Incompatível", TafAmbInvMsg(), { "Encerrar" }, 3 ) //+ Chr(13) + Chr(10) + "Deve-se aplicar o diferencial de dicionário referente aos chamados DSERTAF2-1177/ DSERTAF2-1134", { "Encerrar" }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
	Final()
ElseIf !TAFColumnPos( "C1H_CONTRI" ) 
	Aviso( "Dicionário Incompatível", TafAmbInvMsg(), { "Encerrar" }, 3 ) //+ Chr(13) + Chr(10) + "Deve-se aplicar o diferencial de dicionário referente aos chamados DSERTAF2-2708/ DSERTAF2-1134", { "Encerrar" }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
	Final()
Else 
	/*-------------------------------------------------------------------------------
	Tratamento para exibição de mensagem para o usuário final, caso ocorra erro
	durante o processamento
	-------------------------------------------------------------------------------*/
	/*	Criação de um vetor para alimentar os municipio que devem ser tratados diferente para o 
		registro CR14
	*/
	AADD(aMungia,{'00001','GUAJARA MIRIM'			,'23','RO'})
	AADD(aMungia,{'00105','BRASILEIA'				,'01','AC'})
	AADD(aMungia,{'00107','CRUZEIRO DO SUL'		,'01','AC'})
	AADD(aMungia,{'00255','MANAUS'					,'04','AM'})
	AADD(aMungia,{'00307','BONFIM'					,'24','RR'})
	AADD(aMungia,{'00605','MACAPA'					,'03','AP'})
	AADD(aMungia,{'00615','SANTANA'					,'03','AP'})
	AADD(aMungia,{'09841','PRESIDENTE FIGUEIREDO'	,'04','AM'})
	AADD(aMungia,{'09843','RIO PRETO DA EVA'		,'04','AM'})
	AADD(aMungia,{'09847','TABATINGA'				,'04','AM'})
	AADD(aMungia,{'99998','EPITACIOLANDIA'			,'01','AC'})
	AADD(aMungia,{'00301','BOA VISTA'				,'24','RR'})
	AADD(aMungia,{'99999','PACARAIMA'				,'24','RR'})
			
			
	Begin Sequence
	
		if lReport
			cAnoMesRef := cAnoRef + cMesRef
		Else	
			cAnoMesRef := Alltrim(aWizard[1][11]) + Alltrim(aWizard[1][9])
		EndIf

		QryCR10( cAnoMesRef, cAliasQry, cFilSel, cIn, lReport )

		(cAliasQry)->(dbgotop())
		dbSelectArea("C09")
		C09->(dbSetOrder(3))

		Iif( lReport, InitRel( oTpCfop, oReport, ( cAliasQry )->( !Eof( ) ) ), "" )

		While ( cAliasQry )->( !Eof() )
			cStrTxt    := ""

			If   alltrim(( cAliasQry)->CODTRI) == '000001' .and. right((cAliasQry)->CFOP,3)  != '933' 
				(cAliasQry)->(dbSkip())
				loop
			Endif

			If  alltrim((cAliasQry)->REGISTRO) == "CR10"
				nQtd10++

				cRegistro := alltrim( ( cAliasQry )->REGISTRO )
				cCFOP     := ( cAliasQry )->CFOP
				nVlCont   := 0
				nBase     := 0
				nIsentoNT := 0
				nOutros   := 0
				nImpRet   := 0

				Iif( lReport, oCr10:Init( ), "" ) // Inicia a utilização da seção CR10 e imprime o cabeçalho com os titulos das colunas 
				
				While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->CFOP == cCFOP .AND. alltrim(( cAliasQry )->REGISTRO) == cRegistro

					If !Empty((cAliasQry)->CODTRI)
						nVlCont   += SomaMaior0( ( cAliasQry )->VLOPE )
						nBase     += SomaMaior0( ( cAliasQry )->BASE )
						nIsentoNT += SomaMaior0( ( cAliasQry )->ISENTO + ( cAliasQry )->VLNT )
						
						nOutros   += SomaMaior0( ( cAliasQry )->OUTROS )

						If SubStr(cCFOP,1,1) $ "56"
							If (((Val ((cAliasQry)->CFOP)>=5401) .And. (Val ((cAliasQry)->CFOP)<=5449)) .Or. ;
								((Val ((cAliasQry)->CFOP)>=5651) .And. (Val ((cAliasQry)->CFOP)<=5699)) .Or. ;
								((Val ((cAliasQry)->CFOP)>=6401) .And. (Val ((cAliasQry)->CFOP)<=6449)) .Or. ;
								((Val ((cAliasQry)->CFOP)>=6651) .And. (Val ((cAliasQry)->CFOP)<=6699)) .Or. ;
								((Val ((cAliasQry)->CFOP)==5360) .Or. (Val ((cAliasQry)->CFOP)==6360)) .Or. ;
								((Val ((cAliasQry)->CFOP)==5116) .Or. (Val ((cAliasQry)->CFOP)==6116)) .Or. ;
								((Val ((cAliasQry)->CFOP)==5109) .Or. (Val ((cAliasQry)->CFOP)==5110)) .Or. ;
								((Val ((cAliasQry)->CFOP)==5118) .Or. (Val ((cAliasQry)->CFOP)==6118)) .Or. ;
								((Val ((cAliasQry)->CFOP)==6109) .Or. (Val ((cAliasQry)->CFOP)==6110)) .Or. ;
								(SubStr((cAliasQry)->CFOP,1,2)=="59") .Or. (SubStr((cAliasQry)->CFOP,1,2)=="69") )

								If AllTrim(( cAliasQry )->CODTRI) == '000004' .And. !((cAliasQry)->CFOP $ "6119")
									nSbtuto   += SomaMaior0( ( cAliasQry )->IMPOSTO_RET )
								ElseIf(AllTrim(( cAliasQry )->CODTRI) == '000026') .And. !((cAliasQry)->CFOP $ "6119")
									nSbtuido  += SomaMaior0( ( cAliasQry )->IMPOSTO_RET )
								EndIf
								
								nImpRet += SomaMaior0( ( cAliasQry )->IMPOSTO_RET )
							Else
								nSbtuto   += 0
								nSbtuido  += 0
								nImpRet   += 0
							Endif
						ElseIf SubStr(cCFOP,1,1) $ "12"
							If ( (Val ((cAliasQry)->CFOP) <> 1360) .And. ((Val ((cAliasQry)->CFOP)>=1401) .And. (Val ((cAliasQry)->CFOP)<=1449)) .Or. ;
								((Val ((cAliasQry)->CFOP)>=1651) .And. (Val ((cAliasQry)->CFOP)<=1699)) .Or. ;
								((Val ((cAliasQry)->CFOP)>=2401) .And. (Val ((cAliasQry)->CFOP)<=2449)) .Or. ;
								((Val ((cAliasQry)->CFOP)>=2651) .And. (Val ((cAliasQry)->CFOP)<=2699)) .Or. ;
								((Val ((cAliasQry)->CFOP)>=2901) .And. (Val ((cAliasQry)->CFOP)<=2949)) .And. ;
								(Val ((cAliasQry)->CFOP) <> 1603) .And. (Val ((cAliasQry)->CFOP) <> 2603) .And. ;
								(Val ((cAliasQry)->CFOP) <> 2203) .And. (Val ((cAliasQry)->CFOP) <> 2204) .Or. ;
								(SubStr((cAliasQry)->CFOP,1,2)=="19") .Or. (SubStr((cAliasQry)->CFOP,1,2)=="29") )
								
								If AllTrim(( cAliasQry )->CODTRI) == '000004' .And. !((cAliasQry)->CFOP $ "2203|2204")
									nSbtuto += SomaMaior0( ( cAliasQry )->IMPOSTO_RET )
								ElseIf (AllTrim(( cAliasQry )->CODTRI) == '000026') .And. !((cAliasQry)->CFOP $ "2203|2204")
									nSbtuido += SomaMaior0( ( cAliasQry )->IMPOSTO_RET )
								Endif

								nImpRet  += SomaMaior0( ( cAliasQry )->IMPOSTO_RET )
							Else
								nSbtuto   += 0
								nSbtuido  += 0
								nImpRet   += 0
							EndIf
						EndIf
					EndIf
					
					If TAFColumnPos("C2F_ICMNDES") .AND. ( cAliasQry )->ICMNDES > 0 .AND. SubStr(cCFOP,1,1) $ "12"
						nOutroImp  += SomaMaior0( ( cAliasQry )->ICMNDES )
					Else 
						nImposto += SomaMaior0( ( cAliasQry )->IMPOSTO )
					EndIf

					( cAliasQry )->( dbSkip())
				EndDo

				/*-------------------------------------------------------------------------------
				Aplica a regra do validador na obtenção do valor de Outros Impostos
				-------------------------------------------------------------------------------*/
				nOutroImp	:=	( nVlCont - ( nBase + nIsentoNT + nOutros + nSbtuto + nSbtuido ) ) + nOutroImp

				If nOutroImp < 0
					nOutroImp:= 0
				Endif		

				If lReport
					cTipoCfop := IIF( Val( SubStr( cCFOP, 1, 1 ) ) < 4, "E", "S" )
					ChgEntSai( cTipoCfop, oReport, oTpCfop, @lSecaoEnt, @lSecaoSai )
					ImpCr10( oCr10, cFilSel, cTipoCfop, cCFOP, nVlCont, nBase, nImposto, nIsentoNT, nOutros, nImpRet, nSbtuto, nSbtuido, nOutroImp )
				Else
					AADD(aRegCR10,{	Padr(cCFOP,6,"0"),;																		// CFOPs
									xConvGIA(nVlCont,15),;																	// Valor Contabil
									xConvGIA(nBase,15),;																		// BaseCálculo
									xConvGIA(nImposto,15),;																	// Imposto
									xConvGIA(nIsentoNT,15),;																	// IsentasNãoTrib
									xConvGIA(nOutros,15),;			    						   						   	// Outras
									Replicate("0",15),;								    		   						   	// ImpostoRetidoST
									xConvGIA(nSbtuto,15),;																   	// ImpRetSubstitutoST
									xConvGIA(nSbtuido,15),;																	// ImpRetSubstituído
									xConvGIA(nOutroImp,15),;																	// OutrosImpostos
									'0000'})																					// QTD CR14
				Endif	

			Endif	

			
			If alltrim(( cAliasQry )->REGISTRO) == "CR14" 

				cCFOP     := ( cAliasQry )->CFOP
				
				While cCFOP == ( cAliasQry )->CFOP .and. alltrim(( cAliasQry )->REGISTRO) == "CR14"

					If   ALLTRIM((cAliasQry)->CODTRI) == '000001' .and. right((cAliasQry)->CFOP,3)  != '933' 
						(cAliasQry)->(dbSkip())
						loop
					Endif					

					/*-------------------------------------------------------------------------------
					Zero as variáveis
					-------------------------------------------------------------------------------*/
					nImposto  := 0
					nOutros   := 0
					cEstado   := Alltrim(( cAliasQry )->ESTADO)
					nVlIcmsST := 0
					nOutroProd:= 0
					nVlrCont2 := 0
					nVlrBase2 := 0
					nVlrCont1 := 0
					nVlrBase1 := 0
					nPetrEnerg:= 0

					While ( cAliasQry )->( !Eof() ) .and. alltrim(( cAliasQry )->REGISTRO) == "CR14" .and. cEstado == Alltrim(( cAliasQry )->ESTADO)
						
						/* 
							Tivemos diferentes solicitações de clientes TAF sobre o conteúdo " " ( vazio ) para o campo C1H_CONTRI.
							Teve clientes que queriam que o conteúdo fosse considerado como "1-Sim" e outros clientes queriam considerar como "2-Não"

							Para que o participante seja considerado como contribuinte do ICMS, 
							foi levado em consideração a combinação dos campos C1H_CONTRI e C1H_IE.

							A regra para que o participante seja considerado como contribuinte é:
							1o - C1H_CONTRI diferente de "2-Não", ou seja " " ( vazio ) será considerado como "Sim"
							e
							2o - C1H_IE preenchido e diferente de "ISENT"

						*/
						
						//Se é ou não contribuinte do ICMS.
						// Se contrib = 1=Sim não interessa a IE --> Contribuinte
						// Se contrib = 2=Não não interessa a IE --> Não contribuinte
						// Se o contrib = 'Vazio' --> Valida a inscrição 
						lContrib := alltrim(( cAliasQry )->CONTRI) == '1' .Or. ( Empty(( cAliasQry )->CONTRI) .And. !( "ISENT" $ Upper( alltrim( ( cAliasQry )->IE ) ) ) .and. !( Empty( ( cAliasQry )->IE )  ) )
						
						if !lContrib .and. left(cCFOP,1) == '6' 
							nVlrCont2 += SomaMaior0( ( cAliasQry )->VLOPE )
							nVlrBase2 += SomaMaior0( ( cAliasQry )->BASE )
						Else
							nVlrCont1 += SomaMaior0( ( cAliasQry )->VLOPE )
							nVlrBase1 += SomaMaior0( ( cAliasQry )->BASE )
						EndIf

						nImposto  += SomaMaior0( ( cAliasQry )->IMPOSTO )
						nOutros   += SomaMaior0( ( cAliasQry )->OUTROS )

						If SubStr(cCFOP,1,1) $ "56"
							If (((Val ((cAliasQry)->CFOP)>=5401) .And. (Val ((cAliasQry)->CFOP)<=5449)) .Or. ;
								((Val ((cAliasQry)->CFOP)>=5651) .And. (Val ((cAliasQry)->CFOP)<=5699)) .Or. ;
								((Val ((cAliasQry)->CFOP)>=6401) .And. (Val ((cAliasQry)->CFOP)<=6449)) .Or. ;
								((Val ((cAliasQry)->CFOP)>=6651) .And. (Val ((cAliasQry)->CFOP)<=6699)) .Or. ;
								((Val ((cAliasQry)->CFOP)==5360) .Or. (Val ((cAliasQry)->CFOP)==6360)) .Or. ;
								((Val ((cAliasQry)->CFOP)==5109) .Or. (Val ((cAliasQry)->CFOP)==5110)) .Or. ;
								((Val ((cAliasQry)->CFOP)==5116) .Or. (Val ((cAliasQry)->CFOP)==6116)) .Or. ;
								((Val ((cAliasQry)->CFOP)==5118) .Or. (Val ((cAliasQry)->CFOP)==6118)) .Or. ;
								((Val ((cAliasQry)->CFOP)==6109) .Or. (Val ((cAliasQry)->CFOP)==6110)) .Or. ;
								(SubStr((cAliasQry)->CFOP,1,2)=="59") .Or. (SubStr((cAliasQry)->CFOP,1,2)=="69") )

								nVlIcmsST  += SomaMaior0( ( cAliasQry )->IMPOSTO_RET )
							Else
								nVlIcmsST   += 0
							Endif
						ElseIf SubStr(cCFOP,1,1) $ "12"
							If ( (Val ((cAliasQry)->CFOP) <> 1360) .And. ((Val ((cAliasQry)->CFOP)>=1401) .And. (Val ((cAliasQry)->CFOP)<=1449)) .Or. ;
								((Val ((cAliasQry)->CFOP)>=1651) .And. (Val ((cAliasQry)->CFOP)<=1699)) .Or. ;
								((Val ((cAliasQry)->CFOP)>=2401) .And. (Val ((cAliasQry)->CFOP)<=2449)) .Or. ;
								((Val ((cAliasQry)->CFOP)>=2901) .And. (Val ((cAliasQry)->CFOP)<=2949)) .And. ;
								(Val ((cAliasQry)->CFOP) <> 1603) .And. (Val ((cAliasQry)->CFOP) <> 2603) .And. ;
								(Val ((cAliasQry)->CFOP) <> 2203) .And. (Val ((cAliasQry)->CFOP) <> 2204) .Or. ;
								(SubStr((cAliasQry)->CFOP,1,2)=="19") .Or. (SubStr((cAliasQry)->CFOP,1,2)=="29") )

									nOutroProd	+=	SomaMaior0( (cAliasQry)->IMPOSTO_RET )
							Else
								nOutroProd   += 0
							EndIf
						EndIf

						If (cAliasQry)->IMPOSTO_RET > 0 .and. ( Val( ( cAliasQry )->CFOP ) >=2651 .And. Val( ( cAliasQry )->CFOP )<=2653 .or. ( cAliasQry )->CFOP $ '2659|2660|2661|2662' )
							nPetrEnerg += SomaMaior0( ( cAliasQry )->IMPOSTO_RET )
						Endif 

						( cAliasQry )->( dbSkip() )
					EndDo
																									
					If lReport
						lTemCR14 := ImpCr14( oCr14, cEstado, cCFOP, nVlrCont1 + nVlrCont2 , nVlrBase1 + nVlrBase2 , nImposto, nOutros, nPetrEnerg, nOutroProd )
					Else
																									
						AADD(aRegCR14,{	cEstado,;													      					// UF
										xConvGIA(nVlrCont1,15),;  			    					   				 	// Valor_Contábil_1
										xConvGIA(nVlrBase1,15),; 						    		   				  	// BaseCálculo_1
										xConvGIA(nVlrCont2,15),; 			    					   					// Valor_Contábil_2
										xConvGIA(nVlrBase2,15),;  						    		   				  	// BaseCálculo_2
										xConvGIA(nImposto,15),;			    					  						// Imposto
										xConvGIA(nOutros,15),;							    		  			       	// Outros
										xConvGIA(nVlIcmsST,15),;			    				     				   	// ICMSCobradoST
										xConvGIA(nPetrEnerg,15),;						    		   				   	// PetróleoEnergia
										xConvGIA(nOutroProd,15),;													   	// Outros Produtos
										'00000'})
					EndIf

				EndDo


			Endif

			If lReport .and. lTemCR14
				oCr14:Finish( ) // Finaliza a impressão da seção cr14 
				lTemCR14 := .F. // Reinicia o controle de amarração cr14 por cr10
			EndIf


			IF alltrim(( cAliasQry )->REGISTRO) == "CR18"

				cEstado  := Alltrim(( cAliasQry )->ESTADO)

				While cEstado == Alltrim( ( cAliasQry )->ESTADO) .And. alltrim(( cAliasQry )->REGISTRO) == "CR18"
						
					If   ALLTRIM((cAliasQry)->CODTRI) == '000001' .and. right((cAliasQry)->CFOP,3)  != '933'
						(cAliasQry)->(dbSkip())
						loop
					Endif	

					cCNPJDest:= alltrim(( cAliasQry )->CNPJ)
					cDtDoc   := alltrim(( cAliasQry )->DTES)
					cNumDoc  := alltrim(( cAliasQry )->NUMDOC)
					nValDoc  := 0
					cMungia  := alltrim(( cAliasQry )->MUNGIA)

					While ( cAliasQry )->(!EOF()) .And. cNumDoc == alltrim(( cAliasQry )->NUMDOC)

						nValDoc += ( cAliasQry )->VLOPE

						( cAliasQry )->( dbSkip() )
					EndDo
					
					If ( nPos := aScan( aMungia, { |x| AllTrim( x[1] ) == Alltrim(cMungia) } ) ) > 0
							AADD(aRegCR18,{	PADL(right(alltrim(cNumDoc),9),9,"0"),;			// NF
										cDtDoc,;							  			    			// Data
										xConvGIA(nValDoc,15),; 										// Valor
										cCNPJDest,;							   						// CNPJDest
										cMunGIa})										    			// MunicípioDest							
						
					Endif
				Enddo
				
				aRegCR14[Len(aRegCR14)][11] := "1" + STRZERO(Len(aRegCR18),4)

			EndIF
			
			If lReport
				oCr10:Finish( ) // finaliza seção cr10
				oReport:SkipLine( ) // pula linha do relatório
			Else

				If ( Len( aRegCR14 ) > 0 ) .and. ( Len( aRegCR10 ) == 1 )
			
					QryCR14(cAnoMesRef,@cAliasQry1,cCFOP,cFilSel, cIn)
					
					(cAliasQry1)->(dbgotop())
					While (cAliasQry1)->(!Eof())
						nQtd14 := nQtd14+1 
						(cAliasQry1)->(dbSkip())
					Enddo
					
					(cAliasQry1)->(dbclosearea())
					aRegCR10[1][11]:=STRZERO(nQtd14,4)
					nQtd14 := 0
				Endif
	
				/*-------------------------------------------------------------------------------
				Gerando string do CR=10
				-------------------------------------------------------------------------------*/
				if len(aRegCR10) > 0
					cStrTxt += "10"
					For ni:=1 to 11
						cStrTxt += aRegCR10[1][ni]
					next
					cStrTxt += CRLF
				Endif
				/*-------------------------------------------------------------------------------
				Gerando string do CR=14
				-------------------------------------------------------------------------------*/
				if len(aRegCR14) > 0
					aSort(aRegCR14,,, { |x, y| x[1] < y[1] })//Acrescentado um order by para que os itens venham na ordem correta para geração do arquivo
					For ni:=1 to len(aRegCR14)
						cStrTxt += "14"
						For nx := 1 to 11
							cStrTxt += aRegCR14[ni][nx]
						Next
						cStrTxt += CRLF
					next
				Endif
				/*-------------------------------------------------------------------------------
				Gerando string do CR=18
				-------------------------------------------------------------------------------*/
				if len(aRegCR18) > 0 
					//aSort(aRegCR18,,, { |x, y| x[1] < y[1] })//Acrescentado um order by para que os itens venham na ordem correta para geração do arquivo
					For ni:=1 to len(aRegCR18)
						cStrTxt += "18"
						For nx := 1 to 5
							cStrTxt += aRegCR18[ni][nx]
						Next
						cStrTxt += CRLF
					next
				Endif
	
				WrtStrTxt( nHandle, cStrTxt )

			EndIf
			
			/*-------------------------------------------------------------------------------
			Limpo as variáveis
			-------------------------------------------------------------------------------*/
			nValor     := 0
			nVlrCont1  := 0 // Valor_Contábil_1
			nVlrBase1  := 0 // BaseCálculo_1
			nVlrCont2  := 0 // Valor_Contábil_2
			nVlrBase2  := 0 // BaseCálculo_2
			nImposto   := 0 // Imposto
			nOutros    := 0 // Outros
			nVlIcmsST  := 0 // ICMSCobradoST
			nPetrEnerg := 0 // PetróleoEnergia
			nOutroProd := 0 // Outros Produtos
			nVlCont    := 0 // Vlr Contabil
			nBase      := 0 // Base de Calculo
			cCFOP	    := ""// CFOP
			nSbtuto    := 0 // ImpRetSubstitutoST
			nSbtuido   := 0 // ImpRetSubstituído
			nIsentoNT  := 0 // IsentasNãoTrib
			nSbtuto    := 0 // ImpRetSubstitutoST
			nSbtuido   := 0 // ImpRetSubstituído
			nOutroImp  := 0 // OutrosImp
			nImpRet    := 0 // Imposto Retido
			aRegCR10   := {}
			aRegCR14   := {}
			aRegCR18   := {}
		enddo

		( cAliasQry )->( dbCloseArea())

		If lReport
			oCr14:Finish( ) // Finaliza seção cr14
			oCr10:Finish( ) // Finaliza seção cr10
			oTpCfop:Finish( ) // Finaliza seção com quebra e totalizadores
		Else
			cStrTxt	:= "QTD" + STRZERO(nQtd10,4)
			WrtStrTxt( nHandle, cStrTxt )
			GerTxtGIA( nHandle, cTXTSys, cReg )
		EndIf

	Recover
		lFound := .F.
	End Sequence

	/*-------------------------------------------------------------------------------
	Tratamento para ocorrência de erros durante o processamento
	-------------------------------------------------------------------------------*/
	ErrorBlock( oError )

	If !lReport
		If !lFound
	
			/*-------------------------------------------------------------------------------
			Status 9 -
			Indica ocorrência de erro no processamento
			-------------------------------------------------------------------------------*/
			PutGlbValue( cJobAux , "9" )
			GlbUnlock()
	
		Else
			/*-------------------------------------------------------------------------------
			Status 1 -
			Indica que o bloco foi encerrado corretamente para processamento Multi Thread
			-------------------------------------------------------------------------------*/
			PutGlbValue( cJobAux , "1" )
			GlbUnlock()
		EndIf
	Endif
Endif

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} QueryCR10

Efetua query que busca informações referentes ao Registro de CR=10 -
Detalhes de CFOPs e seus respectivos Filhos.

@Param canoMEsRef-> Ano e mes referencia
cFilSel -> Filial selecionada

@Author Paulo V.B. Santana
@Since 17/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------

Static Function QryCR10( cAnoMesRef, cAliasQry, cFilSel, cIn, lReport )
Local cSelect   	:= ""
Local cWhere    	:= ""
Local cFrom     	:= ""
Local cSelect2  	:= ""
Local cWhere2   	:= ""
Local cFrom2    	:= ""
Local cSelectZF		:= ""
Local cFromZF		:= ""
Local cWhereZF		:= ""
Local cSelect3  	:= ""
Local cWhere3   	:= ""
Local cFrom3    	:= ""
Local cSelect4  	:= ""
Local cWhere4   	:= ""
Local cFrom4    	:= ""
Local cGroupBy  	:= ""
Local cGroupBy10	:= ""
Local cGroupBy14	:= ""
Local cGroupBy18	:= ""
Local cSelectC10	:= ""
Local cFromC10  	:= ""
Local cWhereC10 	:= ""
Local cSelectC11	:= ""
Local cFromC11  	:= ""
Local cWhereC11 	:= ""
Local cGroupBy11	:= ""
Local cSelect14  	:= ""
Local cWhere14   	:= ""
Local cGroupB14		:= ""
Local cFrom14    	:= ""	
Local cCmpRamo		:= iif( TAFColumnPos( "C1H_RAMO" ) , "C1H_RAMO" , "''" )
Local dDtiniRef 	:= Firstday(stod(cAnoMesRef+'01'),1)
Local dDtFimRef 	:= Lastday(stod(cAnoMesRef+'01'),0)
Local cFilAux		:= cFilAnt
Local cInC2F		:= ""
Local cInC1H		:= ""
Local cInC20		:= ""
Local cInC30		:= ""
Local lIN			:= .F.
Local lIcmnDes		:= TAFColumnPos("C2F_ICMNDES")

Default	cIn	:= ""

lIN	:=	Iif( !Empty(cIn), .T., .F. )

If lIN
	cInC2F	:=	INCompFil("C2F", cFilSel, cIn)
	cInC1H	:=	INCompFil("C1H", cFilSel, cIn)
	cInC20	:=	INCompFil("C20", cFilSel, cIn)
	cInC30	:=	INCompFil("C30", cFilSel, cIn)
EndIf

cFilAnt := cFilSel
/*-------------------------------------------------------------------------------
CR10
Adicionados os CFOPs 1933 e 6933 para NF-e que tenham apenas ISS. Removido a UF 000007 (DF)
pois o CR10 e CR14 nessas condições
devem ser gerados para qualquer UF de origem/destino
-------------------------------------------------------------------------------*/

cSelect := " 'CR10' REGISTRO, "
cSelect += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' OR (C2F.C2F_CODTRI = '000004' AND C20.C20_TPDOC = '000003') OR (C2F.C2F_CODTRI = '000026' AND C20.C20_TPDOC = '000003') OR (C2F.C2F_CODTRI = '000001') THEN C2F.C2F_VLOPE WHEN C20.C20_CODMOD = '000029' AND C2F.C2F_CODTRI IN ('000001','000016') AND C20.C20_TPDOC = '000007' AND C0Y.C0Y_CODIGO IN ('1933','2933','5933','6933') THEN C2F.C2F_VLOPE ELSE 0 END) VLOPE, "
cSelect += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_BASE END) BASE, "
cSelect += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VALOR END) IMPOSTO, "
cSelect += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLISEN END) ISENTO, "
cSelect += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLNT WHEN C20.C20_CODMOD = '000029' AND C2F.C2F_CODTRI IN ('000001','000016') AND C20.C20_TPDOC = '000007' AND C0Y.C0Y_CODIGO IN ('1933','2933','5933','6933') 	THEN C2F.C2F_VLOUTR+C2F.C2F_VLISEN END) VLNT, "
cSelect += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLOUTR WHEN (C2F.C2F_CODTRI = '000004' OR C2F.C2F_CODTRI = '000026') AND C20.C20_TPDOC = '000002' AND C0Y.C0Y_CODIGO IN ('2410', '2411','2414','2415','2949') THEN C2F.C2F_VALOR END) OUTROS, "
cSelect += " SUM(CASE WHEN (C2F.C2F_CODTRI = '000004' OR C2F.C2F_CODTRI = '000026') AND (C0Y.C0Y_CODIGO NOT IN ('2410', '2411','2414','2415','2203','2204','2949') OR (C20.C20_TPDOC <>'000002' AND C0Y.C0Y_CODIGO = '2949')) THEN C2F.C2F_BASE 	ELSE 0 END)  BASE_RET, "
cSelect += " SUM(CASE WHEN (C2F.C2F_CODTRI = '000004' OR C2F.C2F_CODTRI = '000026') AND (C0Y.C0Y_CODIGO NOT IN ('2410', '2411','2414','2415','2203','2204','2949') OR (C20.C20_TPDOC <>'000002' AND C0Y.C0Y_CODIGO = '2949')) THEN C2F.C2F_VALOR	ELSE 0 END)  IMPOSTO_RET, "
cSelect += " SUM(CASE WHEN C2F.C2F_CODTRI = '000003' THEN C2F.C2F_VALOR	ELSE 0 END)  IMP_DIF_ALIQ , "
cSelect += " '' ESTADO,  C0Y.C0Y_CODIGO CFOP, '' CNPJ, '' IE,  '' MUNGIA,'' NUMDOC, '' DTES, C1F.C1F_IEST SUBSTITUTO, "
cSelect += " '' RAMO, C2F.C2F_CODTRI CODTRI, C1H.C1H_CONTRI CONTRI "
Iif(lIcmnDes, cSelect +=", C2F.C2F_ICMNDES ICMNDES", )

cFrom := RetSqlName("C2F") + " C2F "
cFrom += " INNER JOIN " + RetSqlName("C20") + " C20 ON C2F.C2F_FILIAL = C20.C20_FILIAL AND C2F.C2F_CHVNF = C20.C20_CHVNF AND C20.C20_DTES BETWEEN '"+ dtos( dDtiniRef ) + "' AND '" + dtos( dDtFimRef ) + "' AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') AND C20.D_E_L_E_T_ = ' ' " //RETIRADA DAS NOTAS CANCELADAS
cFrom += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
if lIN
	cFrom += " C1H.C1H_FILIAL IN (" + cInC1H + ") AND "
else
	cFrom += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' AND "
endif
cFrom += " C1H.C1H_ID = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = ' ' "

cFrom += " LEFT JOIN "  + RetSqlName("C1E") + " C1E ON C1E.C1E_FILTAF = '" + xFilial("C1E") + "' AND C1E.C1E_ATIVO = '1' AND C1E.D_E_L_E_T_ = ' ' "
cFrom += " LEFT JOIN "  + RetSqlName("C1F") + " C1F ON C1F.C1F_FILIAL = C1E.C1E_FILIAL AND C1F.C1F_ID = C1E.C1E_ID AND C1F.C1F_UFST = C1H.C1H_UF AND C1F.C1F_ATIVO = '1' AND C1F.D_E_L_E_T_ = ' ' "
cFrom += " INNER JOIN " + RetSqlName("C0Y") + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' AND C0Y.C0Y_ID = C2F.C2F_CFOP AND C0Y.C0Y_CODIGO NOT IN ('1602','1605','5602','5605') AND C0Y.D_E_L_E_T_ = ' ' " //acrescentado o CFOP 5927 a partir de 01/01/2016
cFrom += " INNER JOIN " + RetSqlName('C07') + " C07 ON C07.C07_FILIAL = '" + xFilial('C07') + "' AND C07.C07_UF = C1H.C1H_UF AND C07.C07_ID = C1H.C1H_CODMUN AND C07.D_E_L_E_T_ = ' ' "

if lIN
	cWhere := " C2F.C2F_FILIAL IN (" + cInC2F + ") AND "
else
	cWhere := " C2F.C2F_FILIAL = '" + xFilial("C2F") + "' AND "
endif
cWhere += " C2F.D_E_L_E_T_ = ' ' AND ( C2F.C2F_CODTRI IN ('000002','000003','000004','000026') OR (C2F.C2F_CODTRI = '000001' AND C20.C20_CODMOD = '000029') OR (C20.C20_CODMOD = '000029' AND C2F.C2F_CODTRI IN ('000001','000016') AND C20.C20_TPDOC = '000007' AND C0Y.C0Y_CODIGO IN ('1933','2933','5933','6933')) ) "

cGroupBy := " C0Y.C0Y_CODIGO, C1F.C1F_IEST, C2F.C2F_CODTRI, C1H.C1H_CONTRI "
Iif(lIcmnDes, cGroupBy +=", C2F.C2F_ICMNDES ", )

/*-------------------------------------------------------------------------------
Selecionando as notas fiscais de transferencias de crédito/debito
Para as notas fiscais de transferencias de crédito eu executo um
select no item da nota C30, pois esse tipo de nota não possui C2F
-------------------------------------------------------------------------------*/
cSelectC10	:= " DISTINCT 'CR10' REGISTRO, SUM(C30.C30_TOTAL) VLOPE, 0 BASE, 0 IMPOSTO, 0 ISENTO,  0 VLNT, 0 OUTROS, 0 BASE_RET,  0 IMPOSTO_RET, "
cSelectC10	+= " 0 IMP_DIF_ALIQ, '' ESTADO,  C0Y.C0Y_CODIGO CFOP, '' CNPJ, '' IE,  ' ' MUNGIA,'' NUMDOC,'' DTES, '' SUBSTITUTO, '' RAMO, '' CODTRI, '' CONTRI "
Iif(lIcmnDes, cSelectC10 +=", '' ICMNDES ", )

cFromC10	:= RetSqlName("C20") + " C20 "
cFromC10	+= " INNER JOIN " + RetSqlName('C30') + " C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF AND C30.D_E_L_E_T_ = ' ' "
cFromC10	+= " INNER JOIN " + RetSqlName('C0Y') + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' AND C0Y.C0Y_ID = C30.C30_CFOP AND C0Y.C0Y_CODIGO IN ('5603','6603','1603','2603','1601','5601') AND C0Y.D_E_L_E_T_ = ' ' "

if lIN
	cWhereC10 := " C30.C30_FILIAL IN (" + cInC30 + ") AND "
else
	cWhereC10 := " C30.C30_FILIAL = '" + xFilial("C30") + "' AND "
endif
cWhereC10 += " C20.C20_DTES BETWEEN '" + Dtos(dDtiniRef+9) + "' AND '" + Dtos(dDtFimRef+9) + "' AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') " //RETIRADA DAS NOTAS CANCELADAS E INUTILIZADAS

cGroupBy10 := " C0Y.C0Y_CODIGO "

/*-------------------------------------------------------------------------------

CR10 - COMPLEMENTO DE IPI

Selecionando as notas fiscais de Complemento de IPI, pois esse tipo de nota não gera C2F, 
por isso a query busca da C30, pois pode ter nota complemento de IPI do período ( cAnoMesRef ) que tenha nota de origem de períodos anteriores 
e o valor contabil dessa nota de complmento de IPI deve ser levada para a GIA.
-------------------------------------------------------------------------------*/
cSelectC11	:= " DISTINCT 'CR10' REGISTRO, SUM(C30.C30_TOTAL) VLOPE, 0 BASE, 0 IMPOSTO, 0 ISENTO,  0 VLNT, 0 OUTROS, 0 BASE_RET,  0 IMPOSTO_RET, "
cSelectC11	+= " 0 IMP_DIF_ALIQ, '' ESTADO,  C0Y.C0Y_CODIGO CFOP, '' CNPJ, '' IE,  ' ' MUNGIA,'' NUMDOC,'' DTES, '' SUBSTITUTO, '' RAMO, '000004' CODTRI, '' CONTRI "
Iif(lIcmnDes, cSelectC11 +=", '' ICMNDES ", )

cFromC11  := RetSqlName("C20") + " C20 "
cFromC11  += " INNER JOIN " + RetSqlName('C30') + " C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF AND C30.D_E_L_E_T_ = ' ' "
cFromC11  += " INNER JOIN " + RetSqlName('C0Y') + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' AND C0Y.C0Y_ID = C30.C30_CFOP AND C0Y.D_E_L_E_T_ = ' ' "

if lIN
	cWhereC11 := " C30.C30_FILIAL IN (" + cInC30 + ") AND "
else
	cWhereC11 := " C30.C30_FILIAL = '" + xFilial("C30") + "' AND "
endif
cWhereC11 += " C20.C20_DTES BETWEEN '" + Dtos(dDtiniRef) + "' AND '" + Dtos(dDtFimRef) + "' "
cWhereC11 += " AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') " //RETIRADA DAS NOTAS CANCELADAS E INUTILIZADAS
cWhereC11 += " AND C20_TPDOC = '000004' "

cGroupBy11 := " C0Y.C0Y_CODIGO "

/*-------------------------------------------------------------------------------
CR14
Adicionados os CFOPs 1933 e 6933 para NF-e que tenham apenas ISS. Removido a UF 000007 (DF)
pois o CR10 e CR14 nessas condições
devem ser gerados para qualquer UF de origem/destino
-------------------------------------------------------------------------------*/
cSelect2:= " DISTINCT 'CR14' REGISTRO, "
cSelect2+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' OR (C2F.C2F_CODTRI = '000004' AND C20.C20_TPDOC = '000003') OR (C2F.C2F_CODTRI = '000026' AND C20.C20_TPDOC = '000003') OR (C2F.C2F_CODTRI = '000001') THEN C2F.C2F_VLOPE WHEN C20.C20_CODMOD = '000029' AND C2F.C2F_CODTRI IN ('000001','000016') AND C20.C20_TPDOC = '000007' AND C0Y.C0Y_CODIGO IN ('1933','2933','5933','6933') THEN C2F.C2F_VLOPE ELSE 0 END) VLOPE, "
cSelect2+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_BASE END) BASE, "
cSelect2+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VALOR END) IMPOSTO, "
cSelect2+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLISEN END) ISENTO, "
cSelect2+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLNT WHEN C20.C20_CODMOD = '000029' AND C2F.C2F_CODTRI IN ('000001','000016') AND C20.C20_TPDOC = '000007' AND C0Y.C0Y_CODIGO IN ('1933','2933','5933','6933') THEN C2F.C2F_VLOUTR+C2F.C2F_VLISEN END) VLNT, "
cSelect2+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLOUTR WHEN (C2F.C2F_CODTRI = '000004' OR C2F.C2F_CODTRI = '000026') AND C20.C20_TPDOC = '000002' AND C0Y.C0Y_CODIGO IN ('2410','2411','2414','2415','2949') THEN C2F.C2F_VALOR END) OUTROS, "
cSelect2+= " SUM(CASE WHEN (C2F.C2F_CODTRI = '000004' OR C2F.C2F_CODTRI = '000026') AND (C20.C20_TPDOC <> '000002' OR (C20.C20_TPDOC ='000002' AND C0Y.C0Y_CODIGO IN ('2660','2661','2662','6411'))) THEN C2F.C2F_BASE ELSE 0 END) BASE_RET, "
cSelect2+= " SUM(CASE WHEN (C2F.C2F_CODTRI = '000004' OR C2F.C2F_CODTRI = '000026') AND (C20.C20_TPDOC <> '000002' OR (C20.C20_TPDOC ='000002' AND C0Y.C0Y_CODIGO IN ('2660','2661','2662','6411'))) THEN C2F.C2F_VALOR ELSE 0 END) IMPOSTO_RET, "
cSelect2+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000003' THEN C2F.C2F_VALOR	ELSE 0 END) IMP_DIF_ALIQ, "
cSelect2+= " C09.C09_CUFGIA ESTADO, "
cSelect2+= " C0Y.C0Y_CODIGO CFOP, "
cSelect2+= " '' CNPJ, C1H.C1H_IE IE, "
cSelect2+= " '' MUNGIA, '' NUMDOC, "
cSelect2+= " '' DTES, '' SUBSTITUTO, " + cCmpRamo + " RAMO, C2F.C2F_CODTRI CODTRI, C1H.C1H_CONTRI CONTRI "
Iif(lIcmnDes, cSelect2 +=", '' ICMNDES ", )

cFrom2  := RetSqlName("C2F") + " C2F "
cFrom2  += " INNER JOIN " + RetSqlName("C20") + " C20 ON C20.C20_FILIAL = C2F.C2F_FILIAL AND C20.C20_CHVNF = C2F.C2F_CHVNF  AND C20.C20_DTES BETWEEN '"+ dtos( dDtiniRef ) + "' AND '" + dtos( dDtFimRef ) + "' AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006')  AND C20.D_E_L_E_T_ = ' ' "
cFrom2  += " INNER JOIN " + RetSqlName("C0Y") + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' AND C0Y.C0Y_ID = C2F.C2F_CFOP AND ( ( C0Y.C0Y_CODIGO >= '6000' AND C0Y.C0Y_CODIGO <= '6999' ) OR ( C0Y.C0Y_CODIGO >= '2000'  AND C0Y.C0Y_CODIGO <= '2999') ) AND C0Y.D_E_L_E_T_ = ' ' "
cFrom2  += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
if lIN
	cFrom2 += " C1H.C1H_FILIAL IN (" + cInC1H + ") AND "
else
	cFrom2 += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' AND "
endif

cFrom2 += " C1H.C1H_ID = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = ' ' "

cFrom2 +=  " LEFT JOIN " + RetSqlName("C39") + " C39 ON C39.C39_FILIAL = C20.C20_FILIAL AND C39.C39_CHVNF = C20.C20_CHVNF AND C39.C39_NUMITE = '0001' AND C39.D_E_L_E_T_ = ' '"  

cFrom2  += " INNER JOIN " + RetSqlName("C09") + " C09 ON C09.C09_FILIAL = '" + xFilial("C09") + "' AND C09.C09_ID = C20.C20_UF AND C09_CUFGIA NOT IN ('09','11','26',' ') AND C09.D_E_L_E_T_ = ' ' "
cFrom2  += " INNER JOIN " + RetSqlName("C07") + " C07 ON C07.C07_FILIAL = '" + xFilial("C07") + "' AND C07.C07_UF = C1H.C1H_UF AND C07.C07_ID = C1H.C1H_CODMUN AND C07.D_E_L_E_T_ = ' ' "

if lIN
	cWhere2 := " C2F.C2F_FILIAL IN (" + cInC2F + ") AND "
else
	cWhere2 := " C2F.C2F_FILIAL = '" + xFilial("C2F") + "' AND "
endif
cWhere2 += " ( C2F.C2F_CODTRI IN ('000002','000003','000004','000026') OR (C2F.C2F_CODTRI = '000001' AND C20.C20_CODMOD = '000029' ) OR (C20.C20_CODMOD = '000029' AND C2F.C2F_CODTRI IN ('000001','000016') AND C20.C20_TPDOC = '000007' AND C0Y.C0Y_CODIGO IN ('1933','2933','5933','6933')) ) "
cWhere2 += " AND (C39.C39_UFDEST NOT IN ('000001','000003','000004','000022','000023') OR C39.C39_CMUNDE IS NULL) "
cWhere2 += " AND C2F.D_E_L_E_T_ = ' ' "

/*-------------------------------------------------------------------------------
CR14 - Notas para a Zona Franca de Manaus
Adicionados os CFOPs 1933 e 6933 para NF-e que tenham apenas ISS. Removido a UF 000007 (DF)
pois o CR10 e CR14 nessas condições
devem ser gerados para qualquer UF de origem/destino
-------------------------------------------------------------------------------*/
cSelectZF:= " DISTINCT 'CR14' REGISTRO, "
cSelectZF+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' OR (C2F.C2F_CODTRI = '000004' AND C20.C20_TPDOC = '000003') OR (C2F.C2F_CODTRI = '000026' AND C20.C20_TPDOC = '000003') OR (C2F.C2F_CODTRI = '000001') THEN C2F.C2F_VLOPE WHEN C20.C20_CODMOD = '000029' AND C2F.C2F_CODTRI IN ('000001','000016') AND C20.C20_TPDOC = '000007' AND C0Y.C0Y_CODIGO IN ('1933','2933','5933','6933') THEN C2F.C2F_VLOPE ELSE 0 END) VLOPE, "
cSelectZF+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_BASE END) BASE, "
cSelectZF+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VALOR END) IMPOSTO, "
cSelectZF+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLISEN END) ISENTO, "
cSelectZF+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLNT WHEN C20.C20_CODMOD = '000029' AND C2F.C2F_CODTRI IN ('000001','000016') AND C20.C20_TPDOC = '000007' AND C0Y.C0Y_CODIGO IN ('1933','2933','5933','6933') THEN C2F.C2F_VLOUTR+C2F.C2F_VLISEN END) VLNT, "
cSelectZF+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLOUTR END) OUTROS, "
cSelectZF+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000004' OR C2F.C2F_CODTRI = '000026' THEN C2F.C2F_BASE ELSE 0 END) BASE_RET, "
cSelectZF+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000004' OR C2F.C2F_CODTRI = '000026' THEN C2F.C2F_VALOR ELSE 0 END) IMPOSTO_RET, "
cSelectZF+= " SUM(CASE WHEN C2F.C2F_CODTRI = '000003' THEN C2F.C2F_VALOR	ELSE 0 END) IMP_DIF_ALIQ, "
cSelectZF+= " C09.C09_CUFGIA ESTADO, "
cSelectZF+= " C0Y.C0Y_CODIGO CFOP, "
cSelectZF+= " '' CNPJ, C1H.C1H_IE IE, "
cSelectZF+= " '' MUNGIA, '' NUMDOC, "
cSelectZF+= " '' DTES, '' SUBSTITUTO, " + cCmpRamo + " RAMO, C2F.C2F_CODTRI CODTRI, C1H.C1H_CONTRI CONTRI "
Iif(lIcmnDes, cSelectZF +=", '' ICMNDES ", )

cFromZF  := RetSqlName("C2F") + " C2F "
cFromZF  += " INNER JOIN " + RetSqlName("C20") + " C20 ON C20.C20_FILIAL = C2F.C2F_FILIAL AND C20.C20_CHVNF = C2F.C2F_CHVNF  AND C20.C20_DTES BETWEEN '"+ dtos( dDtiniRef ) + "' AND '" + dtos( dDtFimRef ) + "' AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006')  AND C20.D_E_L_E_T_ = ' ' "
cFromZF  += " INNER JOIN " + RetSqlName("C0Y") + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' AND C0Y.C0Y_ID = C2F.C2F_CFOP AND ( ( C0Y.C0Y_CODIGO >= '6000' AND C0Y.C0Y_CODIGO <= '6999' ) OR ( C0Y.C0Y_CODIGO >= '2000'  AND C0Y.C0Y_CODIGO <= '2999') ) AND C0Y.D_E_L_E_T_ = ' ' "
cFromZF  += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
if lIN
	cFromZF += " C1H.C1H_FILIAL IN (" + cInC1H + ") AND "
else
	cFromZF += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' AND "
endif
cFromZF += " C1H.C1H_ID = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = ' ' "

cFromZF += " INNER JOIN " + RetSqlName("C39") + " C39 ON C39.C39_FILIAL = C20.C20_FILIAL AND C39.C39_CHVNF = C20.C20_CHVNF AND C39.C39_UFDEST IN ('000001','000003','000004','000022','000023') AND C39.C39_NUMITE = '0001' AND C39.D_E_L_E_T_ = ' '"

cFromZF  += " INNER JOIN " + RetSqlName("C09") + " C09 ON C09.C09_FILIAL = '" + xFilial("C09") + "' AND C09.C09_ID = C39.C39_UFDEST AND C09_CUFGIA NOT IN ('09','11','26',' ') AND C09.D_E_L_E_T_ = ' ' "
cFromZF  += " INNER JOIN " + RetSqlName("C07") + " C07 ON C07.C07_FILIAL = '" + xFilial("C07") + "' AND C07.C07_UF = C39.C39_UFDEST AND C07.C07_ID = C39.C39_CMUNDE AND C07.D_E_L_E_T_ = ' ' "

if lIN
	cWhereZF := " C2F.C2F_FILIAL IN (" + cInC2F + ") AND "
else
	cWhereZF := " C2F.C2F_FILIAL = '" + xFilial("C2F") + "' AND "
endif
cWhereZF += " ( C2F.C2F_CODTRI IN ('000002','000003','000004','000026') OR (C2F.C2F_CODTRI = '000001' AND C20.C20_CODMOD = '000029' ) OR (C20.C20_CODMOD = '000029' AND C2F.C2F_CODTRI IN ('000001','000016') AND C20.C20_TPDOC = '000007' AND C0Y.C0Y_CODIGO IN ('1933','2933','5933','6933')) ) "
cWhereZF += " AND C2F.D_E_L_E_T_ = ' ' "

cGroupBy14 := " C0Y.C0Y_CODIGO, C09.C09_CUFGIA " + iif( cCmpRamo == "''" , "",",C1H.C1H_RAMO" ) + ", C1H.C1H_CONTRI, C2F.C2F_CODTRI, C1H.C1H_IE "

/*-------------------------------------------------------------------------------
CR14 - COMPLEMENTO DE IPI
-------------------------------------------------------------------------------*/
cSelect14:= " DISTINCT 'CR14' REGISTRO, "
cSelect14+= " SUM(C30.C30_TOTAL) VLOPE, "
cSelect14+= " 0 BASE, 0 IMPOSTO, 0 ISENTO, 0 VLNT, 0 OUTROS, "
cSelect14+= " 0 BASE_RET, 0 IMPOSTO_RET, 0 IMP_DIF_ALIQ, "
cSelect14+= " C09.C09_CUFGIA ESTADO, C0Y.C0Y_CODIGO CFOP, '' CNPJ, "
cSelect14+= " C1H.C1H_IE IE, ' ' MUNGIA, '' NUMDOC, '' DTES, '' SUBSTITUTO, "
cSelect14+= " '' RAMO, '' CODTRI, C1H.C1H_CONTRI CONTRI"
Iif(lIcmnDes, cSelect14 +=", '' ICMNDES ", )

cFrom14 := RetSqlName("C20") + " C20 "
cFrom14 += " INNER JOIN " + RetSqlName('C30') + " C30 ON "
if lIN
	cFrom14 += " C30.C30_FILIAL IN (" + cInC30 + ") AND "
else
	cFrom14 += " C30.C30_FILIAL = '" + xFilial("C30") + "' AND "
endif
cFrom14 += " C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF AND C30.D_E_L_E_T_ = ' ' "

cFrom14 += " INNER JOIN " + RetSqlName('C0Y') + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' AND C0Y.C0Y_ID = C30.C30_CFOP AND C0Y.D_E_L_E_T_ = ' ' "
cFrom14 += " INNER JOIN " + RetSqlName("C09") + " C09 ON C09.C09_FILIAL = '" + xFilial("C09") + "' AND C09.C09_ID = C20.C20_UF AND C09_CUFGIA NOT IN ('09','11','26',' ') AND C09.D_E_L_E_T_ = ' ' "
cFrom14 += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
if lIN
	cFrom14 += " C1H.C1H_FILIAL IN (" + cInC1H + ") AND "
else
	cFrom14 += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' AND "
endif
cFrom14 += " C1H.C1H_ID = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = ' ' "

cWhere14  := " C20.C20_DTES BETWEEN '"+ dtos( dDtiniRef ) + "' AND '" + dtos( dDtFimRef ) + "' "
cWhere14  += " AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') "
cWhere14  += " AND C20_TPDOC = '000004' "

cGroupB14 := " C0Y.C0Y_CODIGO, C09.C09_CUFGIA, C1H.C1H_IE, C1H.C1H_CONTRI "

/*-------------------------------------------------------------------------------
CR18
-------------------------------------------------------------------------------*/
cSelect3 := " DISTINCT 'CR18' REGISTRO, "
cSelect3 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLOPE END) VLOPE, "
cSelect3 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_BASE  END) BASE, "
cSelect3 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VALOR END) IMPOSTO,"
cSelect3 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLISEN END) ISENTO, "
cSelect3 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLNT END) VLNT, "
cSelect3 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLOUTR END) OUTROS, "
cSelect3 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000004' THEN C2F.C2F_BASE ELSE 0 END) BASE_RET, "
cSelect3 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000004' THEN C2F.C2F_VALOR ELSE 0 END) IMPOSTO_RET, "
cSelect3 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000003' THEN C2F.C2F_VALOR ELSE 0 END)  IMP_DIF_ALIQ, "
cSelect3 += " C09.C09_CUFGIA ESTADO, C0Y.C0Y_CODIGO CFOP, C1H.C1H_CNPJ CNPJ, '' IE, C07.C07_MUNGIA MUNGIA, C20.C20_NUMDOC NUMDOC, C20.C20_DTES DTES, '' SUBSTITUTO, '' RAMO, C2F.C2F_CODTRI CODTRI, C1H.C1H_CONTRI CONTRI "
Iif(lIcmnDes, cSelect3 +=", '' ICMNDES ", )

cFrom3	:= RetSqlName("C20") + " C20 "
cFrom3	+= "INNER JOIN " + RetSqlName("C2F") + " C2F ON C20.C20_FILIAL = C2F.C2F_FILIAL AND C20.C20_CHVNF = C2F.C2F_CHVNF AND ( C2F.C2F_CODTRI IN ('000002','000003','000004') OR (C2F.C2F_CODTRI = '000001' AND C20.C20_CODMOD = '000029' ) ) AND C2F.C2F_CST IN ('000004','000005','000006') AND C2F.D_E_L_E_T_ = ' ' "
cFrom3	+= "INNER JOIN " + RetSqlName("C0Y") + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' AND C0Y.C0Y_ID = C2F.C2F_CFOP AND C0Y.C0Y_CODIGO >= '6000' AND C0Y.C0Y_CODIGO <= '6999' AND C0Y.C0Y_CODIGO NOT IN ('6107','6108','6933') AND C0Y.D_E_L_E_T_ = ' ' "
cFrom3	+= "INNER JOIN " + RetSqlName("C1H") + " C1H ON "
if lIN
	cFrom3 += " C1H.C1H_FILIAL IN (" + cInC1H + ") AND "
else
	cFrom3 += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' AND "
endif
cFrom3 += " C1H.C1H_ID = C20.C20_CODPAR AND C1H.C1H_UF IN ('000001','000003','000004','000022','000023') AND C1H.C1H_PPES = '2' AND C1H.D_E_L_E_T_ = ' ' "

cFrom3 += "INNER JOIN " + RetSqlName("C09") + " C09 ON C09.C09_FILIAL = '" + xFilial("C09") + "' AND C09.C09_ID = C1H.C1H_UF AND C09.C09_CUFGIA IN ('01','03','04','23','24') AND C09.D_E_L_E_T_ = ' ' "
cFrom3 += "INNER JOIN " + RetSqlName("C07") + " C07 ON C07.C07_FILIAL = '" + xFilial("C07") + "' AND C07.C07_UF = C1H.C1H_UF AND C07.C07_ID = C1H.C1H_CODMUN AND C07.C07_MUNGIA <> '' AND C07.D_E_L_E_T_ = ' ' "

if lIN
	cWhere3 := " C20.C20_FILIAL IN (" + cInC20 + ") AND "
else
	cWhere3 := " C20.C20_FILIAL = '" + xFilial("C20") + "' AND "
endif
cWhere3 += " C20.C20_DTES BETWEEN '" + dTos( dDtiniRef ) + "' AND '" + dtos( dDtFimRef ) + "' "
cWhere3 += " AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') "
cWhere3 += " AND C20.C20_INDOPE = '1' AND C20.C20_CODMOD NOT IN ('000005','000006','000007','000008','000009','000023','000024','000030','000034','000039') AND C20.D_E_L_E_T_ = ' ' "

/*-------------------------------------------------------------------------------
CR18 - NOTAS DE TRANSPORTE
-------------------------------------------------------------------------------*/
cSelect4 := " DISTINCT 'CR18' REGISTRO, "
cSelect4 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLOPE END) VLOPE, "
cSelect4 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_BASE  END) BASE, "
cSelect4 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VALOR END) IMPOSTO,"
cSelect4 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLISEN END) ISENTO, "
cSelect4 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLNT END) VLNT, "
cSelect4 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000002' THEN C2F.C2F_VLOUTR END) OUTROS, "
cSelect4 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000004' THEN C2F.C2F_BASE ELSE 0 END) BASE_RET, "
cSelect4 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000004' THEN C2F.C2F_VALOR ELSE 0 END) IMPOSTO_RET, "
cSelect4 += " SUM(CASE WHEN C2F.C2F_CODTRI = '000003' THEN C2F.C2F_VALOR ELSE 0 END)  IMP_DIF_ALIQ, "
cSelect4 += " C09.C09_CUFGIA ESTADO, C0Y.C0Y_CODIGO CFOP, C1H.C1H_CNPJ CNPJ, '' IE, C07.C07_MUNGIA MUNGIA, C20.C20_NUMDOC NUMDOC, C20.C20_DTES DTES, '' SUBSTITUTO, '' RAMO, C2F.C2F_CODTRI CODTRI, C1H.C1H_CONTRI CONTRI "
Iif(lIcmnDes, cSelect4 +=", '' ICMNDES ", )

cFrom4	:= RetSqlName("C20") + " C20 "
cFrom4	+= "INNER JOIN " + RetSqlName("C2F") + " C2F ON C20.C20_FILIAL = C2F.C2F_FILIAL AND C20.C20_CHVNF = C2F.C2F_CHVNF AND ( C2F.C2F_CODTRI IN ('000002','000003','000004') OR (C2F.C2F_CODTRI = '000001' AND C20.C20_CODMOD = '000029' ) ) AND C2F.C2F_CST IN ('000004','000005','000006') AND C2F.D_E_L_E_T_ = ' ' "
cFrom4	+= "INNER JOIN " + RetSqlName("C0Y") + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' AND C0Y.C0Y_ID = C2F.C2F_CFOP AND C0Y.C0Y_CODIGO >= '6000' AND C0Y.C0Y_CODIGO <= '6999' AND C0Y.C0Y_CODIGO NOT IN ('6107','6108','6933') AND C0Y.D_E_L_E_T_ = ' ' "
cFrom4	+= "INNER JOIN " + RetSqlName("C1H") + " C1H ON "
if lIN
	cFrom4 += " C1H.C1H_FILIAL IN (" + cInC1H + ") AND "
else
	cFrom4 += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' AND "
endif
cFrom4 += " C1H.C1H_ID = C20.C20_CODPAR AND C1H.C1H_PPES = '2' AND C1H.D_E_L_E_T_ = ' ' "
cFrom4 += "INNER JOIN " + RetSqlName("C39") + " C39 ON C39.C39_FILIAL = C20.C20_FILIAL AND C39.C39_CHVNF = C20.C20_CHVNF AND C39.C39_UFDEST IN ('000001','000003','000004','000022','000023') AND C39.C39_NUMITE = '0001' AND C39.D_E_L_E_T_ = ' '" 

cFrom4 += "INNER JOIN " + RetSqlName("C09") + " C09 ON C09.C09_FILIAL = '" + xFilial("C09") + "' AND C09.C09_ID = C39.C39_UFDEST AND C09.C09_CUFGIA IN ('01','03','04','23','24') AND C09.D_E_L_E_T_ = ' ' "
cFrom4 += "INNER JOIN " + RetSqlName("C07") + " C07 ON C07.C07_FILIAL = '" + xFilial("C07") + "' AND C07.C07_UF = C39.C39_UFDEST AND C07.C07_ID = C39.C39_CMUNDE AND C07.C07_MUNGIA <> '' AND C07.D_E_L_E_T_ = ' ' "

if lIN
	cWhere4 := " C20.C20_FILIAL IN (" + cInC20 + ") AND "
else
	cWhere4 := " C20.C20_FILIAL = '" + xFilial("C20") + "' AND "
endif
cWhere4 += " C20.C20_DTES BETWEEN '" + dTos( dDtiniRef ) + "' AND '" + dtos( dDtFimRef ) + "' "
cWhere4 += " AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') "
cWhere4 += " AND C20.C20_INDOPE = '1' AND C20.C20_CODMOD IN ('000005','000006','000007','000008','000009','000023','000024','000030','000034','000039') AND C20.D_E_L_E_T_ = ' ' "

cGroupBy18 := " C20.C20_NUMDOC,C20.C20_DTES,C0Y.C0Y_CODIGO,C09.C09_CUFGIA,C1H_CNPJ,C07.C07_MUNGIA, C1H.C1H_CONTRI, C2F.C2F_CODTRI "


cOrderBy   := " CFOP, ESTADO, REGISTRO, NUMDOC ASC "

cSelect    := "%" + cSelect  	+ "%"
cFrom      := "%" + cFrom    	+ "%"
cWhere     := "%" + cWhere   	+ "%"
cGroupBy   := "%" + cGroupBy 	+ "%"

cSelectC10 := "%" + cSelectC10  + "%"
cFromC10   := "%" + cFromC10    + "%"
cWhereC10  := "%" + cWhereC10   + "%"
cGroupBy10 := "%" + cGroupBy10  + "%"

cSelectC11 := "%" + cSelectC11  + "%"
cFromC11   := "%" + cFromC11    + "%"
cWhereC11  := "%" + cWhereC11   + "%"
cGroupBy11 := "%" + cGroupBy11  + "%"

cSelect2   := "%" + cSelect2 	+ "%"
cFrom2     := "%" + cFrom2   	+ "%"
cWhere2    := "%" + cWhere2  	+ "%"

cSelectZF   := "%" + cSelectZF 	+ "%"
cFromZF     := "%" + cFromZF   	+ "%"
cWhereZF    := "%" + cWhereZF  	+ "%"
cGroupBy14 := "%" + cGroupBy14	+ "%"

cSelect14  := "%" + cSelect14	+ "%"
cFrom14    := "%" + cFrom14  	+ "%"
cWhere14   := "%" + cWhere14 	+ "%"
cGroupB14  := "%" + cGroupB14 	+ "%"

cSelect3   := "%" + cSelect3 	+ "%"
cFrom3     := "%" + cFrom3   	+ "%"
cWhere3    := "%" + cWhere3  	+ "%"

cSelect4   := "%" + cSelect4 	+ "%"
cFrom4     := "%" + cFrom4   	+ "%"
cWhere4    := "%" + cWhere4  	+ "%"
cGroupBy18 := "%" + cGroupBy18  + "%"


cOrderBy   := "%" + cOrderBy 	+ "%"

If lReport
	QryCR10Report( cAliasQry, cSelect, cFrom, cWhere, cGroupBy, cSelectC10, cFromC10, cWhereC10, cGroupBy10, cSelectC11, cFromC11,;
				   cWhereC11, cGroupBy11, cSelect2, cfrom2, cWhere2, cGroupBy14, cSelect14, cFrom14, cWhere14, cGroupB14 )
Else
	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%EXP:cWhere%
		GROUP BY
			%Exp:cGroupBy%

		UNION

		SELECT
			%Exp:cSelectC10%
		FROM
			%Exp:cFromC10%
		WHERE
			%EXP:cWhereC10%
		GROUP BY
			%Exp:cGroupBy10%

		UNION

		SELECT
			%Exp:cSelectC11%
		FROM
			%Exp:cFromC11%
		WHERE
			%EXP:cWhereC11%
		GROUP BY
			%Exp:cGroupBy11%
		UNION

		SELECT
			%Exp:cSelect2%
		FROM
			%Exp:cFrom2%
		WHERE
			%EXP:cWhere2%
		GROUP BY
			%Exp:cGroupBy14%
		
		UNION

		SELECT
			%Exp:cSelectZF%
		FROM
			%Exp:cFromZF%
		WHERE
			%EXP:cWhereZF%
		GROUP BY
			%Exp:cGroupBy14%

		UNION

		SELECT
			%Exp:cSelect14%
		FROM
			%Exp:cFrom14%
		WHERE
			%EXP:cWhere14%
		GROUP BY
			%Exp:cGroupB14%

		UNION

		SELECT
			%Exp:cSelect3%
		FROM
			%Exp:cFrom3%
		WHERE
			%EXP:cWhere3%
		GROUP BY
			%Exp:cGroupBy18%
		
		UNION

		SELECT
			%Exp:cSelect4%
		FROM
			%Exp:cFrom4%
		WHERE
			%EXP:cWhere4%
		GROUP BY
			%Exp:cGroupBy18%

		ORDER BY
			%Exp:cOrderBy%
	EndSql
EndIf

cFilAnt := cFilAux

Return

//-------------------------------------------------------------------
/*{Protheus.doc} QryCR10Report

Função auxiliar utilizada para retornar a query CR10 sem os registros CR18

@author Wesley Pinheiro
@since 27/09/2019
@version 1.0
*/
//-------------------------------------------------------------------
Static Function QryCR10Report( cAliasQry, cSelect, cFrom, cWhere, cGroupBy, cSelectC10, cFromC10, cWhereC10, cGroupBy10, cSelectC11, cFromC11,;
 							   cWhereC11, cGroupBy11, cSelect2, cfrom2, cWhere2, cGroupBy14, cSelect14, cFrom14, cWhere14, cGroupB14 )

	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%EXP:cWhere%
		GROUP BY
			%Exp:cGroupBy%

		UNION

		SELECT
			%Exp:cSelectC10%
		FROM
			%Exp:cFromC10%
		WHERE
			%EXP:cWhereC10%
		GROUP BY
			%Exp:cGroupBy10%

		UNION

		SELECT
			%Exp:cSelectC11%
		FROM
			%Exp:cFromC11%
		WHERE
			%EXP:cWhereC11%
		GROUP BY
			%Exp:cGroupBy11%
		UNION

		SELECT
			%Exp:cSelect2%
		FROM
			%Exp:cFrom2%
		WHERE
			%EXP:cWhere2%
		GROUP BY
			%Exp:cGroupBy14%
		
		UNION

		SELECT
			%Exp:cSelect14%
		FROM
			%Exp:cFrom14%
		WHERE
			%EXP:cWhere14%
		GROUP BY
			%Exp:cGroupB14%

		ORDER BY
			%Exp:cOrderBy%
	EndSql

Return

//-------------------------------------------------------------------
/*{Protheus.doc} QryCR14

Função auxiliar utilizada para retornar quantidade de registros CR14 pertencente a CFOP

@author TOTVS SA

@Obs    27/09/2019 - Wesley Pinheiro - Realizado manutenção, pois a query considerava apenas notas com C2F, 
		Complemento de IPI não estava sendo considerado na quantidade de CR14 contados para a posição 12 do registro CR10

@version 1.0
*/
//-------------------------------------------------------------------
Static Function QryCR14( cAnoMesRef, cAliasQry1, cCfop, cFilSel, cIn )

	Local cSelect2  := ""
	Local cFrom2    := ""
	Local cWhere2   := ""
	Local cFromZF    := ""
	Local cWhereZF   := ""
	Local cGroupBy  := ""
	Local cSelect14 := ""
	Local cFrom14   := ""
	Local cWhere14  := ""
	Local cOrderBy  := ""

	Local dDtiniRef := Firstday(stod(cAnoMesRef+'01'),1)
	Local dDtFimRef := Lastday(stod(cAnoMesRef+'01'),0)
	Local cFilAux   := cFilAnt
	Local cInC1H    := ""
	Local cInC30    := ""
	Local cInC2F	:= ""
	Local lIN       := .F.

	Default cIn     := ""

	lIN	:=	Iif( !Empty(cIn), .T., .F. )

	If lIN
		cInC2F	:=  INCompFil("C2F", cFilSel, cIn)
		cInC1H	:=	INCompFil("C1H", cFilSel, cIn)
		cInC30	:=	INCompFil("C30", cFilSel, cIn)
	EndIf

	cFilAnt := cFilSel

	/*-------------------------------------------------------------------------------
	CR14
	-------------------------------------------------------------------------------*/
	cSelect2:= " DISTINCT 'CR14' REGISTRO, "
	cSelect2+= " C09.C09_CUFGIA ESTADO,  "
	cSelect2+= " C0Y.C0Y_CODIGO CFOP "

	cFrom2  := RetSqlName("C2F") + " C2F"
	cFrom2  += " INNER JOIN " + RetSqlName("C20") + " C20 ON C20.C20_FILIAL = C2F.C2F_FILIAL AND C20.C20_CHVNF = C2F.C2F_CHVNF  AND C20.C20_DTES BETWEEN '"+ dtos( dDtiniRef ) + "' AND '" + dtos( dDtFimRef ) + "' AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') AND C20.D_E_L_E_T_ = ' ' "
	cFrom2  += " INNER JOIN " + RetSqlName("C0Y") + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' AND C0Y.C0Y_ID    = C2F.C2F_CFOP   AND ( ( C0Y.C0Y_CODIGO >= '6000' AND C0Y.C0Y_CODIGO <= '6999' ) OR ( C0Y.C0Y_CODIGO >= '2000'  AND C0Y.C0Y_CODIGO <= '2999') ) AND C0Y.C0Y_CODIGO ='" + cCfop + "' AND C0Y.D_E_L_E_T_ = ' ' "
	cFrom2  += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
	if lIN
		cFrom2 += " C1H.C1H_FILIAL IN (" + cInC1H + ") AND "
	else
		cFrom2 += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' AND "
	endif
	cFrom2 += " C1H.C1H_ID = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = ' ' "

	cFrom2  += " INNER JOIN " + RetSqlName("C09") + " C09 ON C09.C09_FILIAL = '" + xFilial("C09") + "' AND C09.C09_ID = C20.C20_UF AND C09_CUFGIA NOT IN ('09','11','26') AND C09.D_E_L_E_T_ = ' ' "
	cFrom2  += " INNER JOIN " + RetSqlName("C07") + " C07 ON C07.C07_FILIAL = '" + xFilial("C07") + "' AND C07.C07_UF = C1H.C1H_UF AND C07.C07_ID = C1H.C1H_CODMUN AND C07.D_E_L_E_T_ = ' ' "

	if lIN
		cWhere2 := " C2F.C2F_FILIAL IN (" + cInC2F + ") AND "
	else
		cWhere2 := " C2F.C2F_FILIAL = '" + xFilial("C2F") + "' AND "
	endif
	cWhere2 += " ( C2F.C2F_CODTRI IN ('000002','000003','000004','000026') OR (C2F.C2F_CODTRI = '000001' AND C20.C20_CODMOD = '000029' ) OR (C20.C20_CODMOD = '000029' AND C2F.C2F_CODTRI IN ('000001','000016') AND C20.C20_TPDOC = '000007' AND C0Y.C0Y_CODIGO IN ('1933','2933','5933','6933')) ) "
	cWhere2 += " AND C2F.D_E_L_E_T_ = ' ' "

	/*-------------------------------------------------------------------------------
	CR14 - Notas para a Zona Franca de Manaus
	Adicionados os CFOPs 1933 e 6933 para NF-e que tenham apenas ISS. Removido a UF 000007 (DF)
	pois o CR10 e CR14 nessas condições
	devem ser gerados para qualquer UF de origem/destino
	-------------------------------------------------------------------------------*/
	cFromZF  := RetSqlName("C2F") + " C2F "
	cFromZF  += " INNER JOIN " + RetSqlName("C20") + " C20 ON C20.C20_FILIAL = C2F.C2F_FILIAL AND C20.C20_CHVNF = C2F.C2F_CHVNF  AND C20.C20_DTES BETWEEN '"+ dtos( dDtiniRef ) + "' AND '" + dtos( dDtFimRef ) + "' AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006')  AND C20.D_E_L_E_T_ = ' ' "
	cFromZF  += " INNER JOIN " + RetSqlName("C0Y") + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' AND C0Y.C0Y_ID = C2F.C2F_CFOP AND ( ( C0Y.C0Y_CODIGO >= '6000' AND C0Y.C0Y_CODIGO <= '6999' ) OR ( C0Y.C0Y_CODIGO >= '2000'  AND C0Y.C0Y_CODIGO <= '2999') ) AND C0Y.C0Y_CODIGO ='" + cCfop + "' AND C0Y.D_E_L_E_T_ = ' ' "
	cFromZF  += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
	if lIN
		cFromZF += " C1H.C1H_FILIAL IN (" + cInC1H + ") AND "
	else
		cFromZF += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' AND "
	endif
	cFromZF += " C1H.C1H_ID = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = ' ' "

	cFromZF += " INNER JOIN " + RetSqlName("C39") + " C39 ON C39.C39_FILIAL = C20.C20_FILIAL AND C39.C39_CHVNF = C20.C20_CHVNF AND C39.C39_UFDEST IN ('000001','000003','000004','000022','000023') AND C39.C39_NUMITE = '0001' AND C39.D_E_L_E_T_ = ' '"
	cFromZF += " INNER JOIN " + RetSqlName("C09") + " C09 ON C09.C09_FILIAL = '" + xFilial("C09") + "' AND C09.C09_ID = C39.C39_UFDEST AND C09_CUFGIA NOT IN ('09','11','26') AND C09.D_E_L_E_T_ = ' ' "
	cFromZF  += " INNER JOIN " + RetSqlName("C07") + " C07 ON C07.C07_FILIAL = '" + xFilial("C07") + "' AND C07.C07_UF = C39.C39_UFDEST AND C07.C07_ID = C39.C39_CMUNDE AND C07.D_E_L_E_T_ = ' ' "

	if lIN
		cWhereZF := " C2F.C2F_FILIAL IN (" + cInC2F + ") AND "
	else
		cWhereZF := " C2F.C2F_FILIAL = '" + xFilial("C2F") + "' AND "
	endif
	cWhereZF += " ( C2F.C2F_CODTRI IN ('000002','000003','000004','000026') OR (C2F.C2F_CODTRI = '000001' AND C20.C20_CODMOD = '000029' ) OR (C20.C20_CODMOD = '000029' AND C2F.C2F_CODTRI IN ('000001','000016') AND C20.C20_TPDOC = '000007' AND C0Y.C0Y_CODIGO IN ('1933','2933','5933','6933')) ) "
	cWhereZF += " AND C2F.D_E_L_E_T_ = ' ' "

	cGroupBy := " C0Y.C0Y_CODIGO, C09.C09_CUFGIA " 

	/*-------------------------------------------------------------------------------
	CR14 - COMPLEMENTO DE IPI
	-------------------------------------------------------------------------------*/
	cSelect14:= " DISTINCT 'CR14' REGISTRO, "
	cSelect14+= " C09.C09_CUFGIA ESTADO, "
	cSelect14+= " C0Y.C0Y_CODIGO CFOP "

	cFrom14 := RetSqlName("C20") + " C20 "
	cFrom14 += " INNER JOIN " + RetSqlName('C30') + " C30 ON "
	if lIN
		cFrom14 += " C30.C30_FILIAL IN (" + cInC30 + ") AND "
	else
		cFrom14 += " C30.C30_FILIAL = '" + xFilial("C30") + "' AND "
	endif
	cFrom14 += " C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF AND C30.D_E_L_E_T_ = ' ' "

	cFrom14 += " INNER JOIN " + RetSqlName('C0Y') + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' AND C0Y.C0Y_ID = C30.C30_CFOP AND C0Y.C0Y_CODIGO ='" + cCfop + "' AND C0Y.D_E_L_E_T_ = ' ' "
	cFrom14 += " INNER JOIN " + RetSqlName("C09") + " C09 ON C09.C09_FILIAL = '" + xFilial("C09") + "' AND C09.C09_ID = C20.C20_UF AND C09_CUFGIA NOT IN ('09','11','26') AND C09.D_E_L_E_T_ = ' ' "
	cFrom14 += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
	if lIN
		cFrom14 += " C1H.C1H_FILIAL IN (" + cInC1H + ") AND "
	else
		cFrom14 += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' AND "
	endif
	cFrom14 += " C1H.C1H_ID = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = ' ' "

	cWhere14 := " C20.C20_DTES BETWEEN '"+ dtos( dDtiniRef ) + "' AND '" + dtos( dDtFimRef ) + "' "
	cWhere14 += " AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') "
	cWhere14 += " AND C20_TPDOC = '000004' "

	cOrderBy  := " CFOP, ESTADO "

	cSelect2  := "%" + cSelect2  + "%"
	cFrom2    := "%" + cFrom2    + "%"
	cWhere2   := "%" + cWhere2   + "%"
	
	cFromZF   := "%" + cFromZF    + "%"
	cWhereZF  := "%" + cWhereZF   + "%"
	cGroupBy  := "%" + cGroupBy  + "%"

	cSelect14 := "%" + cSelect14 + "%"
	cFrom14   := "%" + cFrom14   + "%"
	cWhere14  := "%" + cWhere14  + "%"

	cOrderBy  := "%" + cOrderBy  + "%"

	BeginSql Alias cAliasQry1

		SELECT
			%Exp:cSelect2%
		FROM
			%Exp:cFrom2%
		WHERE
			%EXP:cWhere2%
		UNION
		SELECT
			%Exp:cSelect2%
		FROM
			%Exp:cFromZF%
		WHERE
			%EXP:cWhereZF%
		GROUP BY
			%Exp:cGroupBy%
		
		UNION

		SELECT
			%Exp:cSelect14%
		FROM
			%Exp:cFrom14%
		WHERE
			%EXP:cWhere14%
		GROUP BY
			%Exp:cGroupBy%

		ORDER BY
			%Exp:cOrderBy%
	EndSql

	cFilAnt := cFilAux

Return

//-------------------------------------------------------------------
/*{Protheus.doc} SomaMaior0

Função auxiliar utilizada para validar se o valor recebido como parametro é positivo.
Caso seja, o valor será utilizado no acumulador do campo do registro CR10/CR14

@Obs: No Manual da GIA SP, os valores dos campos do registro CR10/CR14 devem ser de 0,00 a 9.999.999.999.999,99

@param cValor  - Valor a ser analisado se é positivo

@return cVal - Valor a ser utilizado para acumular valores dos registros

@author Wesley Pinheiro
@since 15/07/2019
@version 1.0
*/
//-------------------------------------------------------------------
Static Function SomaMaior0( nValor )

	Local nVal := nValor

	If nVal < 0
		nVal := 0
	EndIf

Return nVal

//---------------------------------------------------------------------
/*/{Protheus.doc} CompFil

Função criada para retornar o nível de compartilhamento de todas as 
filiais que entrarão na query dos registros CR10, CR14 e CR18

@Param cAlias-> Alias da tabela
cFils -> Filiais que devem pertecer a query

@Author Matheus Prada
@Since 27/08/2019
@Version 1.0
/*/
//---------------------------------------------------------------------
Function INCompFil(cAlias, cFilSel, cFils)

Local	aFils		:= {}
Local	nX			:= 0
Local	cFilAglut	:= ""

	cFilSel += ","+cFils

	aFils	:= StrtokArr(cFilSel, ",")

	For nX:=1 to Len(aFils) 
		
		aFils[nX]		:=	StrTran(Alltrim(aFils[nX]), "'", "")
		aFils[nX]	:=	FWxFilial(cAlias,aFils[nX])

		If nX > 1
			cFilAglut += " , '" + aFils[nX] + "'"
		Else
			cFilAglut := "'" + aFils[nX] + "'"
		EndIf
	Next

Return cFilAglut

//-------------------------------------------------------------------
/*{Protheus.doc} InitRel
Inicia a seção que será responsável pela quebra das informações por tipo de CFOP ( Entrada e Saída ) 
e realiza tratamento caso não retorne nenhum registro a ser impresso.

@param oTpCfop  - objeto TRSection contendo objeto TRBreak responsável pela quebra da seção 
                 e objeto TRFunction responsável pela impressão dos totalizadores
@param oReport  - Objeto tReport com a estututra do relatório
@param lTemCR10 - Variável lógica que indica se tem registros a serem impressos no relatório

@see   TAFRGSP.prw - fonte responsável pela estrutura do relatório

@author Wesley Pinheiro
@since 20/09/2019
@version 1.0
*/
//-------------------------------------------------------------------
Static Function InitRel( oTpCfop, oReport, lTemCR10 )

	Local oCR10

	If lTemCR10
		oTpCfop:Init( ) // Inicio a utilização da seção, não imprime o titulo por causa do comando acima
	Else
		oTpCfop:abreak[1]:SetTitle( "Total CFOP's" )
		oTpCfop:Init( )
		oReport:SkipLine( )
		oCR10 := oTpCfop:Section( 1 )
		oCr10:PrintHeader( )
	EndIf

Return


//-------------------------------------------------------------------
/*{Protheus.doc} ChgEntSai
Controla quando inicia e termina a seção 2 ( oTpCfop )

@param cTipoCfop - Tipo da CFOP ( Entrada/Saída )
@param oReport   - objeto Treport com a estrutura do relatório
@param oTpCfop   - objeto TRSection responsável pela quebra da seção por tipo de CFOP
@param lSecaoEnt,lSecaoSai - Variavéis responsáveis por controlar quando deve ser alterado o título do totalizador

@see   TAFRGSP.prw - fonte responsável pela estrutura do relatório

@author Wesley Pinheiro
@since 20/09/2019
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ChgEntSai( cTipoCfop, oReport, oTpCfop, lSecaoEnt, lSecaoSai )

	If ( cTipoCfop == "E" ) .and. lSecaoEnt

		oTpCfop:Cell( "TIPO" ):SetValue( cTipoCfop )
		oTpCfop:abreak[1]:SetTitle( "Total CFOP's Entrada" )
		lSecaoEnt := .F.

	ElseIf ( cTipoCfop == "S" ) .and. lSecaoSai

		If !lSecaoEnt // Se iniciou seção de CFOPs de entrada, finaliza e imprime os totalizadores
			oTpCfop:Finish( )
			oReport:SkipLine( )
			oTpCfop:Init( ) // Inicia a nova seção de CFOP's de saída
		EndIF

		oTpCfop:Cell( "TIPO" ):SetValue( cTipoCfop )
		oTpCfop:abreak[1]:SetTitle( " Total CFOP's Saída")
		lSecaoSai := .F.

	EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCr10
Imprime linha da TRSection oCR10 com os valores recebidos por parâmetro

@see   TAFRGSP.prw - fonte responsável pela estrutura do relatório

@author Wesley Pinheiro
@since 20/09/2019
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ImpCr10( oCr10, cFilSel, cTipoCfop, cCFOP, nVlCont, nBase, nImposto, nIsentoNT, nOutros, nImpRet, nSbtuto, nSbtuido, nOutroImp )

	oCr10:Cell( "FILIAL"      ):SetValue( cFilSel   )
	oCr10:Cell( "TIPO"        ):SetValue( cTipoCfop )
	oCr10:Cell( "CFOP"        ):SetValue( cCFOP     )
	oCr10:Cell( "REG"         ):SetValue( "CR10"    )
	oCr10:Cell( "VLOPE"       ):SetValue( nVlCont   )
	oCr10:Cell( "BASE"        ):SetValue( nBase     )
	oCr10:Cell( "IMPOSTO"     ):SetValue( nImposto  )
	oCr10:Cell( "ISENTO"      ):SetValue( nIsentoNT )
	oCr10:Cell( "OUTRAS"      ):SetValue( nOutros   )
	oCr10:Cell( "IMPOSTO_RET" ):SetValue( nImpRet   )
	oCr10:Cell( "SBTUTO"      ):SetValue( nSbtuto   )
	oCr10:Cell( "SBTUIDO"     ):SetValue( nSbtuido  )
	oCr10:Cell( "OUTROIMP"    ):SetValue( nOutroImp )

	oCr10:PrintLine( ) // imprime a linha de CR10

Return 

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCr14
Imprime linha da TRSection oCR14 com os valores recebidos por parâmetro

@see   TAFRGSP.prw - fonte responsável pela estrutura do relatório

@author Wesley Pinheiro
@since 20/09/2019
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ImpCr14( oCr14, cEstado, cCFOP, nVlrCont, nVlrBase, nImposto, nOutros, nPetrEnerg, nOutroProd )

	Local cUF := GetAdvFVal( "C09", "C09_UF", xFilial( "C09" ) + cEstado, RetOrder( "C09" ,"C09_FILIAL+C09_CUFGIA" ) )

	oCr14:Init( ) // inicia seção e imprime cabeçalho

	oCr14:Cell( "UF"        ):SetValue( cUF        )
	oCr14:Cell( "CFOP"      ):SetValue( cCFOP      )
	oCr14:Cell( "REG"       ):SetValue( "CR14"     )
	oCr14:Cell( "VLOP"      ):SetValue( nVlrCont   )
	oCr14:Cell( "BASE"      ):SetValue( nVlrBase   )
	oCr14:Cell( "IMPOSTO"   ):SetValue( nImposto   )
	oCr14:Cell( "OUTRAS"    ):SetValue( nOutros    )
	oCr14:Cell( "PETRENERG" ):SetValue( nPetrEnerg )
	oCr14:Cell( "OUTROPROD" ):SetValue( nOutroProd )

	oCr14:PrintLine( ) // imprime linha CR14

Return .T.
