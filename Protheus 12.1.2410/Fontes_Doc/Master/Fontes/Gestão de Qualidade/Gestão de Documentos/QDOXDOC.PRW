#INCLUDE "FILEIO.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "QDOXDOC.CH"
#INCLUDE "TOTVS.CH"

Static _aMascara    := Nil
Static _aQdhCaminho := Nil
Static _cServerTmp  := Nil
Static lQDOLog      := ExistBlock("LOGQDO")
Static slDocControl := Nil


#define CMD_GETAPPPATH      0
#define CMD_OPENTOTVSVIEWER 1
#DEFINE ENTER               CHR(13) + CHR(10)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDOXDOC  ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcoes para processamento de documentos via Word          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo S.  ³30/10/01³------³ Acertado para atualizar corretamente as  ³±±
±±³            ³        ³      ³ variaveis do Word qdo for cancel. Docto. ³±±
±±³Eduardo S.  ³04/01/02³------³ Alterado para salvar e visualizar docto  ³±±
±±³            ³        ³      ³ em Html.                                 ³±±
±±³Eduardo S.  ³28/01/02³------³ Incluido o ponto de entrada "QDOVISION". ³±±
±±³Eduardo S.  ³04/02/02³------³ Alterado para visualizar docto somente   ³±±
±±³            ³        ³      ³ Leitura qdo for Cancelamento de Docto.   ³±±
±±³Eduardo S.  ³28/02/02³------³ Acertado para salvar o Docto Html no dire³±±
±±³            ³        ³      ³ torio especificado no param. "MV_QPATHWH"³±±
±±³Eduardo S.  ³26/03/02³ META ³ Alteracao utilizando o novo conceito de  ³±±
±±³            ³        ³      ³ arquivos de Usuarios no Quality.(SRA-QAA)³±±
±±³Eduardo S.  ³10/04/02³ META ³ Alterado para visualizar documento em fa-³±±
±±³            ³        ³      ³ se de leitura de acordo com o tipo de edi³±±
±±³            ³        ³      ³ tor definido cad.usuarios(Html/WordView).³±±
±±³Eduardo S.  ³13/05/02³ xxxx ³ Acertado para nao mostrar responsaveis   ³±±
±±³            ³        ³      ³ Inativos na visualizacao/Reemissao Docto.³±±
±±³Eduardo S.  ³26/06/02³ META ³ Alteracao na Funcao QDODOCCON() para vi- ³±±
±±³            ³        ³      ³ sualizar Docto Externo.                  ³±±
±±³Eduardo S.  ³22/07/02³------³ Incluido o parametro MV_QDHTML definindo ³±±
±±³            ³        ³      ³ se grava documento HTML.                 ³±±
±±³Eduardo S.  ³14/08/02³------³ Acertado para atualizar os responsaveis  ³±±
±±³            ³        ³      ³ do docto no Word tambem qdo for Reemissao³±±
±±³            ³        ³      ³ e Visualizacao do Documento.             ³±±
±±³Eduardo S.  ³03/12/02³ ---- ³ Alterado para listar os textos(QA2) apar-³±±
±±³            ³        ³      ³ tir da funcao QA_RecTxt().               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QdoDocImp ³ Autor ³ Newton R. Ghiraldelli ³ Data ³   /09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QdoDocImp(lAlter,lDetalhe,lFecha,lCpyS2T,lSolAtr,nOpc)

	Local aAreaQD1    := {}
	Local aAreaQdg    := QDG->(GetArea())
	Local aDocs       := {}
	Local aQPath      := QDOPATH()
	Local aTemp       := {}
	Local aUsrMat     := QA_USUARIO()
	Local cLibCli     := ""
	Local cMatCod     := aUsrMat[3]
	Local cMatDep     := aUsrMat[4]
	Local cMatFil     := aUsrMat[2]
	Local cMvSave     := QDOPswOLE() // "Verifica se insere senha ou nao
	Local cQArqTmp    := ""
	Local cQPath      := aQPath[1] // Diretorio que contem os .CEL
	Local cQPathD     := aQPath[2]
	Local cQPathTrm   := aQPath[3]
	Local cSvFilAnt   := cFilAnt
	Local cTexto      := ""
	Local cTextoD     := aQPath[4]
	Local lExist700   := ExistBlock( "QDOM700" )
	Local lExist710   := ExistBlock( "QDOM710" )
	Local lExist720   := ExistBlock( "QDOM720" )
	Local lFound      := .F.
	Local lNew        := .F.
	Local lOpenSmCl   := .F.
	Local lReadOnly   := .T.
	Local nT          := 0
	Local oQdoControl := Nil

	Private cEdit      := Alltrim( GetMV( "MV_QDTIPED" ) ) 
	Private cChave     := M->QDH_FILIAL + M->QDH_DOCTO + "  RV:" + M->QDH_RV
	Private cEditor    := "TMsOleWord97" //Space( 12 ) 
	Private cNomFilial := Space( 40 )
	Private cFilApSol  := Space( 02 )
	Private cCodApSol  := Space( 06 )
	Private cFilApDes  := Space( 02 )
	Private cCodApDes  := Space( 06 ) 
	Private cNomRece   := IF(M->QDH_STATUS == "L  ",QA_nUsr( cMatFil, cMatCod )," ")
	Private cDepRece   := IF(M->QDH_STATUS == "L  ",cMatDep," ")
	Private cFilRece   := IF(M->QDH_STATUS == "L  ",cMatFil," ")
	Private cObjetivo  := " "
	Private cMotRevi   := " "
	Private cApElabo   := " "
	Private cApRevis   := " "
	Private cApAprov   := " "
	Private cApHomol   := " "
	Private cElabora   := " "
	Private cRevisor   := " "
	Private cAprovad   := " "
	Private cHomolog   := " "
	Private cSumario   := " "
	Private cRodape    := " "
	Private cRevalid   := " "
	Private cDtEmiss   := dDatabase
	Private cCodAtu    := " "
	Private cCodNov	   := " "
	Private cDescr	   := " "
	Private cDe		   := " "
	Private cPara	   := " "
	Private cMdpRaz	   := " "
	Private cMdpObs	   := " "
	Private cMdsRaz    := " "
	Private cMdsObs	   := " "
	Private cPreview   := GetMv("MV_QDPRVW",.T.,"1")// Indica a Utilização do Printpreview

	Default lSolAtr    := .F.

	If  cFilAnt <> M->QDH_FILIAL .AND. !Empty(AllTrim(xFilial("QDH")))
		cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV   

		aQPath       := QDOPATH()
		cQPath       := aQPath[1]	  // Diretorio que contem os .CEL
		cQPathD      := aQPath[2]
		cQPathTrm    := aQPath[3]
		cTextoD      := aQPath[4]   

		cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
	EndIf

	If !Empty(AllTrim(xFilial("QDH")))
		If _cServerTmp <> Nil // Forço o reload das configurações
			_cServerTmp  := Nil 
			_aQdhCaminho := Nil
		EndIf
	EndIf

	If type("INCLUI")# "L"
	   _SetOwnerPrvt("inclui",.F.)
	EndIf
	If type("ALTERA")# "L"
	   _SetOwnerPrvt("altera",.F.)
	EndIf
	If ExistBlock( "QDOPRVW" )
		ExecBlock( "QDOPRVW", .F., .F.,{M->QDH_DOCTO, M->QDH_RV,M->QDH_STATUS} )
	Endif

	If type("lGerRev")=='U'
		lGerRev:= .F.
	endif

	lCpyS2T  := If(lCpyS2T == NIL, .F.,lCpyS2T)
	lDetalhe := If( lDetalhe == Nil, .f., lDetalhe )

	If Empty( M->QDH_DOCTO + M->QDH_RV )
	   Help( " ", 1, "QD050DOCND" )
		Return .f.
	EndIf

	IF ExistBlock( "QDOVISION" )
		ExecBlock( "QDOVISION", .t., .f. )
		Return .T.
	Endif

	cTextoD := Alltrim( GetMV( "MV_QDDOTPD" ) )

	aAreaQD1 := QD1->(GetArea())
	QD1->( dbSetOrder( 1 ) )
	If QD1->( dbSeek( M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod ) )
		While QD1->(!Eof()) .And. M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod == ;
				QD1->(QD1_FILIAL + QD1_DOCTO + QD1_RV + QD1_DEPTO + QD1_FILMAT + QD1_MAT)
	       	If Rtrim(QD1->QD1_TPPEND) == "L"
	       		lFound := .T.
				Exit
			EndIf
			QD1->( dbSkip() )
		Enddo	
	Endif
	If !lFound
		RestArea( aAreaQD1 )
	Endif

	If M->QDH_STATUS <> "L  "
		DbSelectArea( "QD2" )
		If DbSeek( xFilial( "QD2" ) + M->QDH_CODTP )
			If !Empty( QD2->QD2_MODELO )    
				cTextoD := Alltrim( QD2->QD2_MODELO )
				If (TamSx3("QD2_MODELO")[1]) == 12
					If !File(cQPathD + Alltrim(QD2->QD2_MODELO))
						cTextoD := Alltrim( QD2->QD2_MODELO )+ "X" 
					Else
						cTextoD := Alltrim( QD2->QD2_MODELO ) 			
					Endif  
				Else
					cTextoD := Alltrim( QD2->QD2_MODELO )
				Endif
			EndIf
			If Empty( M->QDH_NOMDOC )
				If !File( cQPathTrm + cTextoD )
					CpyS2T(cQPathD+cTextoD,cQPathTrm,.T.)
					If !File( cQPathTrm + cTextoD )
						Help( " ", 1, "QD_DOTNEXT" )
						Return .f.
					Endif
				Endif
			EndIf
		EndIf
	Endif
	DbSelectArea( "QDH" )

	If Empty( M->QDH_NOMDOC )
	   If lDetalhe .Or. !lAlter
	      Help( " ", 1, "QDCDOCERR" )
	      Return .f.
	   EndIf
	   lNew   :=.t.
	   cTexto := STRZERO( VAL( QA_SEQU( "QDH", 6, "N" ) ), 6 )  + SubStr( StrZero( year( dDataBase ), 4 ),3 ,2 ) + ".CEL"
	   While File( cQPath + cTexto )
	   		cTexto := STRZERO( VAL( QA_SEQU( "QDH", 6, "N" ) ), 6 )  + SubStr( StrZero( year( dDataBase ), 4 ),3 ,2 ) + ".CEL"
	   EndDo
	Else	
	   cTexto := Alltrim(M->QDH_NOMDOC)
	EndIf


	If lAlter .And. M->QDH_CANCEL <> "S"
	   lReadOnly := .f.
	EndIf	

	oQdoControl   := QDODocumentControl():New()
	If !oQdoControl:arquivoLiberado(cQPathTrm + cTexto, .T.)
		Return .F.
	EndIf

	RegProcDoc( nT-2 )
	If lNew;
	   .OR. (cPreview != "2" .AND. !lReadOnly);
	   .OR. (cPreview == "2" .AND. lAlter    );
	   .OR. (IncProcDoc( STR0007 ) ); // "Abrindo documento existente"
	   .OR. !(lOpenSmCl := lCpyS2T := QDOViewOLE(M->QDH_NOMDOC, M->QDH_DOCTO, M->QDH_RV))

		DbSelectArea( "QDH" )
		QDH->( DbSetOrder( 1 ) )
		If lQDOLog
			ProcLogIni( {},"QDOXDOC")
		Endif	
		If lNew
			lCpyS2T:= .T.
			If !File( cQPathTrm + cTextoD )
				CpyS2T(cQPathD+cTextoD,cQPathTrm,.T.)
				If !File( cQPathTrm + cTextoD )
					Help( " ", 1, "QD_DOTNEXT" )
					Return .f.
				Endif
				If lQDOLog
					ProcLogAtu("MENSAGEM", cTextoD+ ' ' + M->QDH_DOCTO + 'Tipo: Gravação Sistema Função:CpyS2T Linha:256 Ação:New', '')
					Execblock("LOGQDO",.F.,.F.,{cTextoD,M->QDH_DOCTO,'Gravação Sistema','CpyS2T','256','New'})
				EndIf	
			EndIf
		Else   
			If !lAlter
				If M->QDH_STATUS $ "L  |I  " 
					If File(cQPathTrm+cTexto)
						fErase(cQPathTrm+cTexto)		
						If lQDOLog
							ProcLogAtu("MENSAGEM", cTexto+ ' ' + M->QDH_DOCTO + 'Tipo: Gravação Sistema Função:fErase Linha:265 Ação:<>Alt', '')
							Execblock("LOGQDO",.F.,.F.,{cTexto,M->QDH_DOCTO,'Gravação Sistema','fErase','265','<>Alt'})
						EndIf					
					EndIf

					If File(Left(cQPathTrm+cTexto,Len(cQPathTrm+cTexto)-4)+"_TMP.CEL")
						fErase(Left(cQPathTrm+cTexto,Len(cQPathTrm+cTexto)-4)+"_TMP.CEL")		
						If lQDOLog
							ProcLogAtu("MENSAGEM", cTexto+ ' ' + M->QDH_DOCTO + 'Tipo: Gravação Sistema Função:fErase_TMP Linha:273 Ação:!Alt', '')
							Execblock("LOGQDO",.F.,.F.,{cTexto,M->QDH_DOCTO,'Gravação Sistema','fErase','273','<>Alt'})
						EndIf					
					EndIf

					If  cFilAnt <> M->QDH_FILIAL .AND. FWModeAccess("QDH")=="E"
						cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV
						QdoCamCel(cQPath, @cQPathTrm, cTexto)
						cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
					Else
						QdoCamCel(cQPath, @cQPathTrm, cTexto)
					EndIf
				Else
					QDODocumentControl():copiaProtegidaArquivo(cQPath+cTexto, cQPathTrm+cTexto)
					If lQDOLog
						ProcLogAtu("MENSAGEM", cTexto+ ' ' + M->QDH_DOCTO + 'Tipo: Gravação Sistema Função:CpyS2T visual/excl Linha:288 Ação:!Alt', '')
						Execblock("LOGQDO",.F.,.F.,{cTexto,M->QDH_DOCTO,'Gravação Sistema','CpyS2T visual/excl','288','<>Alt'})
					EndIf					
				Endif
				If !File( cQPathTrm + cTexto )
					Help( " ", 1, "QD_DOCNEXT" )
					Return .f.
				Endif
			Else
				If File(cQPathTrm+cTexto) .And. File(cQPath+cTexto)
					If M->QDH_STATUS $ "L  |I  "
						fErase(cQPathTrm+cTexto)
						CpyS2T(cQPath+cTexto,cQPathTrm,.T.)
						If lQDOLog
							ProcLogAtu("MENSAGEM", cTexto+ ' ' + M->QDH_DOCTO + 'Tipo: Gravação Sistema Função:fErase/CpyS2T Linha:301 Ação:Alt', '')
							Execblock("LOGQDO",.F.,.F.,{cTexto,M->QDH_DOCTO,'Gravação Sistema','fErase/CpyS2T','301','Alt'})
						EndIf
					Else
						If !lSobDocTmp // Caso esta variavel estaja com True alguma acção já foi tomada
							aTemp := DIRECTORY(cQPathTrm+cTexto)
							aDocs := DIRECTORY(cQPath+cTexto)
							If lQDOLog
								ProcLogAtu("MENSAGEM", cTexto+ ' ' + M->QDH_DOCTO + 'Tipo: Gravação Sistema Função:Dialog Linha:309 Ação:Alt', '')
								Execblock("LOGQDO",.F.,.F.,{cTexto,M->QDH_DOCTO,'Gravação Sistema','Dialog','309','Alt'})
							EndIf
							nOpt  := QDSobDoc(aTemp,aDocs)
							If nOpt == 0
								oQdoControl:copiaProtegidaArquivo(cQPath+cTexto,cQPathTrm+cTexto)
								lSobDocTmp := .T. // Exibo somente uma vez esta  tela
								If lQDOLog
									ProcLogAtu("MENSAGEM", cTexto+ ' ' + M->QDH_DOCTO + 'Tipo: Ação Usuario Função:CpyS2T Linha:317 Ação:Alt', '')
									Execblock("LOGQDO",.F.,.F.,{cTexto,M->QDH_DOCTO,'Ação Usuario','CpyS2T','317','Alt'})
								EndIf
							Elseif nOpt == 1
								If lAlter .And. !lReadOnly 
									If MsgYesNo(OemToAnsi(STR0055),OemToAnsi(STR0015))//"Após executado este procedimento, não haverá  forma de recuperar o arquivo, deseja realmente substituir o arquivo localizado no Servidor?"###"Atenção"
										oQdoControl:copiaProtegidaArquivo(cQPathTrm+cTexto, cQPath+cTexto)
										lSobDocTmp := .T.
										If lQDOLog
											ProcLogAtu("MENSAGEM", cTexto+ ' ' + M->QDH_DOCTO + 'Tipo: Ação Usuario Função:CpyT2S Linha:326 Ação:Alt', '')
											Execblock("LOGQDO",.F.,.F.,{cTexto,M->QDH_DOCTO,'Ação Usuario','CpyT2S','326','Alt'})
										EndIf
									Else
										lSobDocTmp := .F.
										If lQDOLog
											ProcLogAtu("MENSAGEM", cTexto + ' ' + M->QDH_DOCTO + ' Usu abort CpyT2S ', '') 
											Execblock("LOGQDO",.F.,.F.,{cTexto,M->QDH_DOCTO,'Usu abort CpyT2S','CpyT2S','346','Alt'})
											ProcLogAtu("MENSAGEM", cTexto+ ' ' + M->QDH_DOCTO + 'Tipo: Ação Usuario Função:Yesno=no Linha:325 Ação:Alt', '')
											Execblock("LOGQDO",.F.,.F.,{cTexto,M->QDH_DOCTO,'Ação Usuario','Yesno=no','325','Alt'})
										EndIf
										Return .F.
									EndIf
								EndIf
							Else
								If lQDOLog
									ProcLogAtu("MENSAGEM", cTexto+ ' ' + M->QDH_DOCTO + 'Tipo: Ação Usuario Função:semMudança Linha:348 Ação:Alt', '')
									Execblock("LOGQDO",.F.,.F.,{cTexto,M->QDH_DOCTO,'Ação Usuario','semMudanca','348','Alt'})
								EndIf
								Return .F.
							EndIf
						EndIf
					Endif
				Else
					If File(cQPath+cTexto)
						QDODocumentControl():copiaProtegidaArquivo(cQPath+cTexto,cQPathTrm+cTexto)
					EndIf
					If lQDOLog
						ProcLogAtu("MENSAGEM", cTexto+ ' ' + M->QDH_DOCTO + 'Tipo: Gravação Sistema Função:CpyS2T Linha:353 Ação:Alt', '')
						Execblock("LOGQDO",.F.,.F.,{cTexto,M->QDH_DOCTO,'Gravação Sistema','CpyS2T','353','Alt'})
					EndIf
				EndIf
				If !File( cQPathTrm + cTexto )
					Help( " ", 1, "QD_DOCNEXT" )
					Return .f.
				Endif		
			EndIf
		Endif
		If lQDOLog
			ProcLogAtu("FIM")
		EndIf
		nT:=10
		If lNew
		nT:=nT+1
		EndIf
		If lReadOnly
		nT:=nT-3
		EndIf

		If Empty(M->QDH_CHAVE)
			cChave:= QA_CvKey(cChave,"QDH",2)
			M->QDH_CHAVE:= cChave
			If !Inclui
				Begin Transaction
					RecLock("QDH",.F.)
					QDH->QDH_CHAVE := cChave
					QDH->(MsUnlock())
				End Transaction
			EndIf
		Else
			cChave:= M->QDH_CHAVE
		EndIf

		If Type("cTpCopia") == "U"
			cTpCopia := OemToAnsi(STR0016)	// "Copia Controlada"
		Endif

		If lExist700
			ExecBlock( "QDOM700", .f., .f., { cEdit, cEditor } )

			If Empty( cEditor )
				Help( " ", 1, "QD_NEXTEDT" )
				Return .f.
			EndIf
		EndIf

		RegProcDoc( nT-2 )
		IncProcDoc( STR0001 ) // "Gerando complementos de campos texto"

		QdoDocQa2()

		DbSelectArea( "QDH" )
		QDH->( DbSetOrder( 1 ) )

		IncProcDoc( STR0003 ) // "Criando link de comunica‡„o com o editor"
		If Type("oWord") <> "U"
			If !Empty(oWord) .And. oWord <> "-1"
				OLE_CloseFile( oWord )
				OLE_CloseLink( oWord )
			EndIf
		Endif

		GetRemoteType( @cLibCli )
		if !('WIN' $ cLibCli)
			MsgAlert ('O modulo de controle de documentos utiliza funcionalidades exclusivas do MSOFFICE (segurança, DocVariables) não disponiveis neste Sistema Operacional')
			Return .F.
		EndIf 	
		oWord := OLE_CreateLink( cEditor )
		IncProcDoc( STR0004 ) // "Ajustando propriedades do editor"
		OLE_SetProperty( oWord, oleWdVisible,   .f. ) 
		OLE_SetProperty( oWord, oleWdLeft,   000 )
		OLE_SetProperty( oWord, oleWdTop,    090 )
		OLE_SetProperty( oWord, oleWdWidth,  480 )
		OLE_SetProperty( oWord, oleWdHeight, 250 )
		
		If lNew
			IncProcDoc( STR0005 ) // "Gerando novo documento"
			OLE_NewFile( oWord, ( cQPathTrm + cTextoD ) )
			IncProcDoc( STR0006 ) // "Salvando matriz de documento"
			QDODocumentControl():OLE_SaveAsFile( oWord, ( cQPathTrm + cTexto ), cMvSave, cMvSave, .f., oleWdFormatDocument, .T. /*lPermiteRTF*/)
			cDocBase      := AllTrim(cTexto)
			M->QDH_NOMDOC := cDocBase
			If File(cQPathTrm+cTextoD)
				FErase(cQPathTrm+cTextoD)
			Endif
		Else
			If M->QDH_STATUS == "L  "	// Leitura
			
				cQArqTmp := Left(cQPathTrm+cTexto,Len(cQPathTrm+cTexto)-4)+"_TMP.CEL"
				QDODocumentControl():copiaProtegidaArquivo(cQPathTrm+cTexto, cQArqTmp)
				
				If File(cQArqTmp)
					IncProcDoc( STR0007 ) // "Abrindo documento existente"
					OLE_OpenFile( oWord, cQArqTmp, .F., cMvSave, cMvSave )
					IncProcDoc( STR0008 ) // "Transferindo dados do sistema"
					QDG->(DbSetOrder(3))	// Posiciona o destinatario de acordo com o usuario corrente
					QDG->(DbSeek(	xFilial() + M->QDH_DOCTO + M->QDH_RV + cMatFil +;
					cMatDep + cMatCod))
					
					QDOVar720() // função que absorveu o conteúdo do PE QDOM720

					If lExist720
						ExecBlock( "QDOM720", .f., .f. )
					EndIf
					
					QDG->(RestArea(aAreaQdg))
					IncProcDoc( STR0009 ) // "Atualizando vari veis do editor"
					OLE_UpdateFields( oWord )
					If cPreview == "2"
						If !lAlter
							QDODocumentControl():abreDocumentoDoServidorComArquivoTemporario(oWord, cTexto, lReadOnly)
						Else
							OLE_SaveFile( oWord )
							OLE_CloseFile( oWord )                  
							OLE_OpenFile( oWord, cQArqTmp, lReadOnly, cMvSave, cMvSave )
							OLE_SetProperty( oWord, oleWdVisible,   .T. ) 
							QDOTimeOut(.F.,lReadOnly)
							If nOpc <> 2 .OR. Alltrim(M->QDH_STATUS) <> "L" 
								MessageBox(STR0056+STR0051,STR0050,0)  //"Antes de encerrar esta sessão, certifique se o documento foi salvo."###"Confirme para finalizar a comunicação com o MS Word.","Documento"
							Else
								MessageBox(STR0051,STR0050,0)  //"Confirme para finalizar a comunicação com o MS Word.","Documento"
							EndIf
							QDOTimeOut(.T.,lReadOnly)
							OLE_CloseFile( oWord )
							OLE_CloseLink ( oWord, .T. )
						Endif
					Else
						if lReadOnly //protecao para quando não for readonly, o programa chamar o qdom710 e alterar corretamente o documento.
							OLE_SaveFile( oWord )
							OLE_CloseFile( oWord )                  
							OLE_OpenFile( oWord, cQArqTmp, lReadOnly, cMvSave, cMvSave )
							OLE_SetProperty( oWord, oleWdVisible,   .T. ) 
							QDOTimeOut(.F.,lReadOnly)
							MessageBox(STR0051,STR0050,0)  //"Confirme para finalizar a comunicação com o MS Word.","Documento"
							QDOTimeOut(.T.,lReadOnly)
							OLE_CloseFile( oWord )
							OLE_CloseLink ( oWord, .T. )
						Endif
					Endif
				Else
					OLE_SetProperty( oWord, oleWdPrintBack, .f. )
					OLE_CloseFile( oWord )
					OLE_CloseLink( oWord )
				Endif

			Else
				If M->QDH_CANCEL == "S" .Or. lGerRev
					
					cQArqTmp := Left(cQPathTrm+cTexto,Len(cQPathTrm+cTexto)-4)+"_TMP.CEL"
					QDODocumentControl():copiaProtegidaArquivo(cQPathTrm+cTexto,cQArqTmp)
					OLE_SetProperty( oWord, oleWdPrintBack, .f. )
					
					If File(cQPathTrm + cTexto)
						IncProcDoc( STR0007 ) // "Abrindo documento existente"
						OLE_OpenFile( oWord, ( cQPathTrm + cTexto ), .F., cMvSave, cMvSave )
						
						IncProcDoc( STR0008 ) // "Transferindo dados do sistema"
						
						QDOVar710() //função que absosrveu as variáveis do PE QDOM710

						If lExist710
							ExecBlock( "QDOM710", .f., .f. )
						Endif

						IncProcDoc( STR0009 ) // "Atualizando vari veis do editor"
						OLE_UpdateFields( oWord )
						
						If cPreview == "2"
							If !lAlter
								QDODocumentControl():abreDocumentoDoServidorComArquivoTemporario(oWord, cTexto, lReadOnly)
							Else
								if lReadOnly //protecao para quando não for readonly, o programa chamar o qdom710 e alterar corretamente o documento.
									OLE_SaveFile( oWord ) 	
									OLE_CloseFile( oWord )                  
									OLE_OpenFile( oWord, ( cQPathTrm + cTexto ), lReadOnly, cMvSave, cMvSave )
									OLE_SetProperty( oWord, oleWdVisible,   .T. ) 
									QDOTimeOut(.F.,lReadOnly)
									MessageBox(STR0051,STR0050,0)  //"Confirme para finalizar a comunicação com o MS Word.","Documento"
									QDOTimeOut(.T.,lReadOnly)
									OLE_CloseFile( oWord )
									OLE_CloseLink ( oWord, .T. )
								Endif
							Endif
						Else
							if lReadOnly //protecao para quando não for readonly, o programa chamar o qdom710 e alterar corretamente o documento.
								OLE_SaveFile( oWord )
								OLE_CloseFile( oWord )                  
								OLE_OpenFile( oWord, ( cQPathTrm + cTexto ), lReadOnly, cMvSave, cMvSave )
								OLE_SetProperty( oWord, oleWdVisible,   .T. ) 
								QDOTimeOut(.F.,lReadOnly)
								MessageBox(STR0051,STR0050,0)  //"Confirme para finalizar a comunicação com o MS Word.","Documento"
								QDOTimeOut(.T.,lReadOnly)
								OLE_CloseFile( oWord )
								OLE_CloseLink ( oWord, .T. )
							endif
						Endif

						lCpyS2T := .T.
					Else
						OLE_SetProperty( oWord, oleWdPrintBack, .f. )
						OLE_CloseFile( oWord )
						OLE_CloseLink( oWord )
					EndIf

				Else
					
					IncProcDoc( STR0007 ) // "Abrindo documento existente"

					OLE_OpenFile( oWord, ( cQPathTrm + cTexto ), .F., cMvSave, cMvSave )                  
					//OLE_SetProperty( oWord, oleWdWindowState, "2")
					
					QDOVar720() // função que absorveu o conteúdo do PE QDOM720

					If lExist720
						ExecBlock( "QDOM720", .f., .f. )
					EndIf
					
					OLE_UpdateFields( oWord )                       
					If cPreview == "2"
						If !lAlter
							QDODocumentControl():abreDocumentoDoServidorComArquivoTemporario(oWord, cTexto, lReadOnly)
						Else
							if lReadOnly //protecao para quando não for readonly, o programa chamar o qdom710 e alterar corretamente o documento.
								OLE_SaveFile( oWord )
								OLE_CloseFile( oWord )                  
								OLE_OpenFile( oWord, ( cQPathTrm + cTexto ), lReadOnly, cMvSave, cMvSave )
								OLE_SetProperty( oWord, oleWdVisible,   .T. ) 
								QDOTimeOut(.F.,lReadOnly)
								MessageBox(STR0051,STR0050,0)  //"Confirme para finalizar a comunicação com o MS Word.","Documento"
								QDOTimeOut(.T.,lReadOnly)
								OLE_CloseFile( oWord )
								OLE_CloseLink ( oWord, .T. )
							endif
						Endif
					Else
						if lReadOnly //protecao para quando não for readonly, o programa chamar o qdom710 e alterar corretamente o documento.
							OLE_SaveFile( oWord )
							OLE_CloseFile( oWord )                  
							OLE_OpenFile( oWord, ( cQPathTrm + cTexto ), lReadOnly, cMvSave, cMvSave )
							OLE_SetProperty( oWord, oleWdVisible,   .T. ) 
							MessageBox(STR0051,STR0050,0)  //"Confirme para finalizar a comunicação com o MS Word.","Documento"		                
							OLE_CloseFile( oWord )
							OLE_CloseLink ( oWord, .T. )
						endif
					Endif
				EndIf
			EndIf
		EndIf
	EndIf
	
	If !lReadOnly
		IncProcDoc( STR0008 ) // "Transferindo dados do sistema"
		
		QDOVar710() //função que absosrveu as variáveis do PE QDOM710

		If lExist710
			ExecBlock( "QDOM710", .f., .f. )
		Endif
		
		IncProcDoc( STR0009 ) // "Atualizando vari veis do editor"
		OLE_UpdateFields( oWord )
		IncProcDoc( STR0010 ) // "Salvando documento"
		OLE_SaveFile( oWord )
		lCpyS2T := .T.
		If lQDOLog
			ProcLogIni( {},"QDOXDOC")
			ProcLogAtu("MENSAGEM", cTexto+ ' ' + M->QDH_DOCTO + 'Tipo: Ação Usuario/sistema Função:Edição Word/salva  Linha:626 Ação:Alt', '')
			Execblock("LOGQDO",.F.,.F.,{cTexto,M->QDH_DOCTO,'Ação Usuario/sistema','Edicao Word/salva','626','Alt'})
			ProcLogAtu("FIM")
		EndIf
	Endif
	
	If !lOpenSmCl
		IncProcDoc( STR0004 ) // "Ajustando propriedades do editor"
		OLE_SetProperty( oWord, oleWdVisible, .t. )
	EndIf

	If !(cPreview == "2" .AND. !lAlter) .AND. !lOpenSmCl
		OLE_SetProperty( oWord, oleWdWindowState, "1")//Maximiza
	EndIf
	
	If lFecha .AND. !lOpenSmCl
		OLE_SetProperty( oWord, oleWdPrintBack, .f. )
		OLE_CloseFile( oWord )
	   	OLE_CloseLink( oWord ) 
	Endif
	
	If !lFecha
		If !lReadOnly
			If Type("oWord") <> "U"
				QDOTimeOut(.F.,lReadOnly)
				If nOpc <> 2 .OR. Alltrim(M->QDH_STATUS) <> "L" 
					MessageBox(STR0056+STR0051,STR0050,0)  //"Antes de encerrar esta sessão, certifique se o documento foi salvo."###"Confirme para finalizar a comunicação com o MS Word.","Documento"
				Else
		           	MessageBox(STR0051,STR0050,0)  //"Confirme para finalizar a comunicação com o MS Word.","Documento"
				EndIf
				QDOTimeOut(.T.,lReadOnly)
				If !Empty(oWord) .And. oWord <> "-1"
					OLE_CloseFile( oWord )
					OLE_CloseLink( oWord )
				ElseIf oWord <> "-1"
					OLE_CloseLink( oWord )
				EndIf
			Endif
		EndIf
		If !lDetalhe
		   DbSelectArea( "QD1" )
		   DbSetOrder( 1 )
		   If DbSeek( M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod )
		      While !Eof() .And. M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod == QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_DEPTO + QD1->QD1_FILMAT + QD1->QD1_MAT  
		         If QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND == M->QDH_STATUS
	               If RecLock( "QD1", .f. )
		               QD1->QD1_LEUDOC := "S"
		               MsUnlock()
						Endif
		            Exit
		         EndIf
	            DbSkip()
		      Enddo	
		   EndIf
		Endif
		If lNew
		   M->QDH_NOMDOC := cTexto
		   If !Inclui
		      If Empty( QDH->QDH_NOMDOC )
				   RecLock( "QDH", .f. )
		         QDH->QDH_NOMDOC := cTexto
		         MsUnlock()
		      EndIf
		   EndIf
		EndIf
	Endif
	
	If cPreview == "2" .AND. !lNew .AND. !(!lReadOnly .AND. !lFecha /*FECHADO ACIMA*/) .AND. !lOpenSmCl
		If Type("oWord") <> "U"
			If !Empty(oWord) .And. oWord <> "-1"
				OLE_CloseFile( oWord )
				OLE_CloseLink( oWord )
			ElseIf oWord <> "-1"
				OLE_CloseLink( oWord )
			EndIf
		Endif
	EndIf


Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QdoDocRDoc³ Autor ³ Newton R. Ghiraldelli ³ Data ³   /09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QdoDocRDoc(nCopias,lReemissao)

	Local aQPath       := QDOPATH()
	Local cMvSave      := QDOPswOLE() // "Verifica se insere senha ou nao
	Local cQPath       := aQPath[1]   // Diretorio que contem os .CEL
	Local cQPathD      := aQPath[2]
	Local cQPathTrm    := aQPath[3]
	Local cSvFilAnt    := cFilAnt
	Local cTexto       := " "
	Local cTextoD      := aQPath[4]
	Local lExist700    := ExistBlock( "QDOM700" )
	Local lExist720    := ExistBlock( "QDOM720" )
	Local lMultP       := .F.
	Local nT           := 0

	Private cApAprov   := " "
	Private cApElabo   := " "
	Private cApHomol   := " "
	Private cApRevis   := " "
	Private cAprovad   := " "
	Private cChave     := xFilial( "QDH" ) + M->QDH_DOCTO + " RV:" + M->QDH_RV
	Private cCodApDes  := Space( 06 )
	Private cCodApSol  := Space( 06 )
	Private cCodAtu    := " "
	Private cCodNov    := " "
	Private cDe        := " "
	Private cDescr     := " "
	Private cDtEmiss   := dDatabase
	Private cEdit      := Alltrim( GetMV( "MV_QDTIPED" ) )
	Private cEditor    := "TMsOleWord97" //Space( 12 ) 
	Private cElabora   := " "
	Private cFilApDes  := Space( 02 )
	Private cFilApSol  := Space( 02 )
	Private cHomolog   := " "
	Private cMdpObs    := " "
	Private cMdpRaz    := " "
	Private cMdsObs    := " "
	Private cMdsRaz    := " "
	Private cMotRevi   := " "
	Private cNomFilial := Space( 40 )
	Private cObjetivo  := " "
	Private cPara      := " "
	Private cRevalid   := " "
	Private cRevisor   := " "
	Private cRodape    := " "
	Private cSumario   := " "
	Private cTpCopia   := If( lChCopia, OemToAnsi( STR0016 ), OemToAnsi( STR0017 ) ) // "Copia Controlada" ### "Copia nao Controlada"
	Private Inclui     := .f.

	nCopias    := If(nCopias   == NIL , 1  , nCopias   )
	lReemissao := If(lReemissao== NIL , .F., lReemissao)

	If ExistBlock( "QDOPRVW" )
		ExecBlock( "QDOPRVW", .F., .F.,{M->QDH_DOCTO, M->QDH_RV,M->QDH_STATUS} )
	Endif
	If Empty( M->QDH_DOCTO + M->QDH_RV )
	   Help( " ", 1, "QD050DOCND" )
	   Return .f.
	EndIf

	If  cFilAnt <> M->QDH_FILIAL .AND. !Empty(AllTrim(xFilial("QDH")))
		cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV

		aQPath    := QDOPATH()
		cQPath    := aQPath[1]	// Diretorio que contem os .CEL
		cQPathD   := aQPath[2]
		cQPathTrm := aQPath[3]
		cTextoD   := aQPath[4]

		cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
	EndIf

	If lExist700
		ExecBlock( "QDOM700", .f., .f., { cEdit, cEditor } )

		If Empty( cEditor )
		   Help( " ", 1, "QD_NEXTEDT" )
		   Return .f.
		EndIf
	EndIf
	
	cTextoD := Alltrim( GetMV( "MV_QDDOTPD" ) )
	
	DbSelectArea( "QD2" )
	If DbSeek( xFilial( "QD2" ) + M->QDH_CODTP )
	   	If !Empty( QD2->QD2_MODELO )
	      	cTextoD := Alltrim( QD2->QD2_MODELO )
		EndIf
	   	If !File( cQPathTrm + cTextoD )
		   	If (TamSx3("QD2_MODELO")[1]) == 12
		   		If !File( cQPathTrm + cTextoD + "X" )
					CpyS2T(cQPathD+cTextoD,cQPathTrm,.T.)
				Endif          
			Else
		   		If !File( cQPathTrm + cTextoD )
					CpyS2T(cQPathD+cTextoD,cQPathTrm,.T.)
				Endif          			
			Endif
		   	If !File( cQPathTrm + cTextoD )  
		   		If (TamSx3("QD2_MODELO")[1]) == 12
			   		If !File( cQPathTrm + cTextoD + "X" )
				      	Help( " ", 1, "QD_DOTNEXT" )
				      	Return .f.                      
			      	Endif
			    Else
			      	Help( " ", 1, "QD_DOTNEXT" )
			      	Return .f.                      
			    Endif
			Endif
			cQPathTrm := aQPath[3]
	   	EndIf
	EndIf
	DbSelectArea( "QDH" )
	If Empty( M->QDH_NOMDOC )
	   Help( " ", 1, "QD050DOCND" )
	   Return .f.
	Else	
	   cTexto := Alltrim( M->QDH_NOMDOC )
	EndIf
	
	DbSelectArea("QA2")
	If Empty( M->QDH_CHAVE )
	   cChave       := QA_CvKey( cChave, "QDH", 2 )
	   M->QDH_CHAVE := cChave
	   Begin Transaction
	         RecLock( "QDH", .f. )
	         QDH->QDH_CHAVE := cChave
	         MsUnlock()
	   End Transaction
	Else
	   cChave := M->QDH_CHAVE
	EndIf
	
	If !Empty(AllTrim(xFilial("QDH")))
		If _cServerTmp <> Nil // Forço o reload das configurações
			_cServerTmp  := Nil 
			_aQdhCaminho := Nil
		EndIf
	EndIf
	
	DbSelectArea( "QDH" )
	QDH->( DbSetOrder( 1 ) )
	If !File( cQPathTrm + cTexto )
		If M->QDH_STATUS = "L  "
			If  cFilAnt <> M->QDH_FILIAL .AND. FWModeAccess("QDH")=="E"
				cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV
				QdoCamCel(cQPath, @cQPathTrm, cTexto, @lMultP)
				cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
			Else
				QdoCamCel(cQPath, @cQPathTrm, cTexto, @lMultP)
			EndIf
		Else
			CpyS2T(cQPath+cTexto,cQPathTrm,.T.)
		Endif
	   	If !File( cQPathTrm + cTexto )
		   	Help( " ", 1, "QD_DOCNEXT" )
		   	Return .f.
		EndIf
	Endif
	nT := 10
	RegProcDoc( nT-2 )
	If !lReemissao
		cNomRece:= QAA->QAA_NOME
		cDepRece:= QAA->QAA_CC
	Endif
	
	IF ExistBlock( "QDOCAPA" )
		ExecBlock( "QDOCAPA", .f., .f.,{ 1 } )
	Endif
	
	DbSelectArea( "QDH" )
	QDH->( DbSetOrder( 1 ) )
	IncProcDoc( STR0003 ) // "Criando link de comunica‡„o com o editor"
	
	QdoDocQa2()
		
	If Type("oWord") <> "U"
		If !Empty(oWord) .And. oWord <> "-1"
			OLE_CloseFile( oWord )
			OLE_CloseLink( oWord )
		EndIf
	Endif
	oWord := OLE_CreateLink( cEditor )
	IncProcDoc( STR0004 ) // "Ajustando propriedades do editor"
	OLE_SetProperty( oWord, oleWdVisible,   .f. )
	OLE_SetProperty( oWord, oleWdPrintBack, .f. )
	OLE_SetProperty( oWord, oleWdLeft,   000 )
	OLE_SetProperty( oWord, oleWdTop,    074 )
	OLE_SetProperty( oWord, oleWdWidth,  600 )
	OLE_SetProperty( oWord, oleWdHeight, 320 )
	IncProcDoc( STR0007 ) // "Abrindo documento existente"
	OLE_OpenFile( oWord, ( cQPathTrm + cTexto ), .F., cMvSave, cMvSave )
	IncProcDoc( STR0008 ) // "Transferindo dados do sistema"
	OLE_SetDocumentVar( oWord, "Adv_CopiaControlada"	, cTpCopia ) //Atualiza tipo de cópia
	IncProcDoc( STR0009 ) // "Atualizando vari veis do editor"
	OLE_UpdateFields( oWord )
	IncProcDoc( STR0012 ) // "Imprimindo c¢pia"
	OLE_PrintFile( oWord, "ALL",,, nCopias ) 
	IncProcDoc( STR0004 ) // "Ajustando propriedades do editor"
	OLE_SetProperty( oWord, oleWdVisible, .t. )
	IncProcDoc( STR0013 ) // "Fechando link de comunica‡„o com o editor"
	OLE_CloseFile( oWord )
	OLE_CloseLink( oWord ) 
	
	If ! lMultP .And. File(cQPathTrm+cTexto)
		FErase(cQPathTrm+cTexto)
	Endif
	
Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QdoDocRUsr³ Autor ³ Newton R. Ghiraldelli ³ Data ³   /09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QdoDocRUsr( lEditor, lFim, cNomRece , lSalva, lObsoleto, nCopias, lCpyS2T, lCopiaMultp, lAtPendVar)

	Local aQPath              := QDOPATH()
	Local cMvQDHTML           := GetMV("MV_QDHTML",.F.,"2") // "Grava Html"
	Local cMvSave             := QDOPswOLE() // "Verifica se insere senha ou nao
	Local cQPath              := aQPath[1] // Diretorio que contem os .CEL
	Local cQPathDot           := Alltrim(GetMV("MV_QPATHWD"))
	Local cQPathTrm           := aQPath[3]
	Local cSvFilAnt           := cFilAnt
	Local cTexto              := " "
	Local cTextoD             := aQPath[4]
	Local lAbreDoc            := GetMV("MV_QABRDOC",.F.,"1") == "1" // "Exibo o Documento na Distribuicao"
	Local lExist700           := ExistBlock( "QDOM700" )
	Local lExist720           := ExistBlock( "QDOM720" )
	Local lFile               := .T.
	Local lMultP              := .F.
	Local lReadOnly           := .T.
	Local nI                  := 0
	Local nT                  := 0

	Default lCopiaMultp := .T.
	Default lAtPendVar  := .F.

	Private cApAprov    := " "
	Private cApElabo    := " "
	Private cApHomol    := " "
	Private cApRevis    := " "
	Private cAprovad    := " "
	Private cChave      := xFilial( "QDH" ) + M->QDH_DOCTO + " RV:" + M->QDH_RV
	Private cCodApDes   := Space( 06 )
	Private cCodApSol   := Space( 06 )
	Private cDtEmiss    := dDatabase
	Private cEdit       := Alltrim( GetMV( "MV_QDTIPED" ) )
	Private cEditor     := "TMsOleWord97" //Space( 12 ) 
	Private cElabora    := " "
	Private cFilApDes   := Space( 02 )
	Private cFilApSol   := Space( 02 )
	Private cHomolog    := " "
	Private cMotRevi    := " "
	Private cNomFilial  := Space( 40 )
	Private cObjetivo   := " "
	Private cRevalid    := " "
	Private cRevisor    := " "
	Private cRodape     := " "
	Private cSumario    := " "
	Private cTpCopia    := If( lChCopia, OemToAnsi( STR0016 ), OemToAnsi( STR0017 ) ) // "Copia Controlada" ### "Copia nao Controlada"
	Private Inclui      := .F.

	Private cCodAtu     := " "
	Private cCodNov     := " "
	Private cDe         := " "
	Private cDescr      := " "
	Private cMdpObs     := " "
	Private cMdpRaz     := " "
	Private cMdsObs     := " "
	Private cMdsRaz     := " "
	Private cPara       := " "
	Private cPreview    := GetMv("MV_QDPRVW",.T.,"1") // Indica a Utilização do Printpreview

	If  cFilAnt <> M->QDH_FILIAL .AND. !Empty(AllTrim(xFilial("QDH")))
		cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV

		aQPath    := QDOPATH()
		cQPath    := aQPath[1]	// Diretorio que contem os .CEL
		cQPathTrm := aQPath[3]
		cTextoD   := aQPath[4]

		cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
	EndIf

	If ExistBlock( "QDOPRVW" )
		ExecBlock( "QDOPRVW", .F., .F.,{M->QDH_DOCTO, M->QDH_RV,M->QDH_STATUS} )
	Endif
	
	lCpyS2T   := If(lCpyS2T   == NIL, .F., lCpyS2T)
	lSalva	  := IF(lSalva    == NIL, .F., lSalva)
	lObsoleto := IF(lObsoleto == NIL, .F., lObsoleto )
	nCopias	  := If(nCopias   == Nil, 1  , nCopias)
	lReadOnly := Empty(cNomRece) .OR. !IsInCalLStack("QDOA110") //Permite Edição durante a distribuição para atualização das variáveis de Destinatário e Departamento

	If Empty( M->QDH_DOCTO + M->QDH_RV )
	   Help( " ", 1, "QD050DOCND" )
	   Return .f.
	EndIf

	If lExist700
		ExecBlock( "QDOM700", .f., .f., { cEdit, cEditor } )

		If Empty( cEditor )
			Help( " ", 1, "QD_NEXTEDT" )
	 		Return .f.
		EndIf
	EndIf
	
	If !lObsoleto
		dbSelectArea( "QD2" )
		If DbSeek( xFilial( "QD2" ) + M->QDH_CODTP )
		   If !Empty( QD2->QD2_MODELO )
		   		If (TamSx3("QD2_MODELO")[1]) == 12
			   		If !File(cQPathDot + cTextoD)
				    	cTextoD := Alltrim( QD2->QD2_MODELO ) + "X"
				    Else
						cTextoD := Alltrim( QD2->QD2_MODELO )
				    Endif                        
				Else
					cTextoD := Alltrim( QD2->QD2_MODELO )			
				Endif
			EndIf
		EndIf
	
		DbSelectArea( "QDH" )
		If Empty( M->QDH_NOMDOC )
		   Help( " ", 1, "QD050DOCND" )
		   Return .f.
		Else	
		   cTexto := Alltrim( M->QDH_NOMDOC )
		EndIf
	
		DbSelectArea("QA2")
		If Empty( M->QDH_CHAVE )
		   cChave       := QA_CvKey( cChave, "QDH", 2 )
		   M->QDH_CHAVE := cChave
	       RecLock( "QDH", .f. )
	       QDH->QDH_CHAVE := cChave
	       MsUnlock()
		Else
		   cChave := M->QDH_CHAVE
		EndIf
	
		DbSelectArea( "QDH" )
		QDH->( DbSetOrder( 1 ) )
	Else
		If Empty( M->QDH_NOMDOC )
		   Help( " ", 1, "QD050DOCND" )
		   Return .f.
		Else	
		   cTexto := Alltrim( M->QDH_NOMDOC )
		EndIf
	Endif
	
	If !File( cQPathTrm + cTexto )
		If M->QDH_STATUS = "L  " .And. lCopiaMultp
			If  cFilAnt <> M->QDH_FILIAL .AND. FWModeAccess("QDH")=="E"
				cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV
				QdoCamCel(cQPath, @cQPathTrm, cTexto, @lMultP)
				cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
			Else
				QdoCamCel(cQPath, @cQPathTrm, cTexto, @lMultP)
			EndIf
		Else
			QDODocumentControl():copiaProtegidaArquivo(cQPath+cTexto, cQPathTrm+cTexto)
		Endif
	   	If !File( cQPathTrm + cTexto )
		   	Help( " ", 1, "QD_DOCNEXT" )
		   	Return .f.
		Endif
	
	ElseIf File(cQPathTrm+cTexto) .AND. File(cQPath+cTexto)
		aTemp := DIRECTORY(cQPathTrm+cTexto) 
		aDocs := DIRECTORY(cQPath+cTexto)
		For nI := 1 To Len(aTemp) // Verificacao de diferencas entre arquivo temporario e servidor
			If aTemp[1][nI] <> aDocs[1][nI]
				lFile := .T.
			Endif
		Next
		If lFile
			If !lAtPendVar
		    	fErase(cQPathTrm+cTexto)
			EndIf
			If M->QDH_STATUS = "L  " .And. lCopiaMultp
				If  cFilAnt <> M->QDH_FILIAL .AND. FWModeAccess("QDH")=="E"
					cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV
					QdoCamCel(cQPath, @cQPathTrm, cTexto)
					cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
				Else
					QdoCamCel(cQPath, @cQPathTrm, cTexto)
				EndIf
			ElseIf !lAtPendVar
				QDODocumentControl():copiaProtegidaArquivo(cQPath+cTexto, cQPathTrm+cTexto)
			EndIf
		EndIf
	
	EndIf
	
	If lEditor
	   nT := 10
	Elseif !lEditor .and. !lFim
	   nT := 6	
	EndIf
	If lFim
	   nT := 3
	Endif
	If alltrim(Funname()) <> "QDOA120"
		RegProcDoc( nT-2 )
	Endif
	
	QdoDocQa2()  
		
	If !lObsoleto
		DbSelectArea( "QDH" )
		QDH->( DbSetOrder( 1 ) )
	Endif
	
	If lEditor                                  
		//-- Sera executado o Ponto de Entrada apenas na Impressao
		If !lSalva
			IF ExistBlock( "QDOCAPA" )
				ExecBlock( "QDOCAPA", .f., .f.,{ 2 } )
			Endif
		Endif
	   	If Alltrim(Funname()) <> "QDOA120"
		   IncProcDoc( STR0003 ) // "Criando link de comunica‡„o com o editor"
		Endif
	   If Type("oWord") <> "U"
	      If !Empty(oWord) .And. oWord <> "-1"
	         OLE_CloseFile( oWord )
	         OLE_CloseLink( oWord )
	      EndIf
	   Endif
	
		If Type("lForcaAtua") == "U" .OR. !lForcaAtua .OR. Empty(oWord) .OR. oWord == "-1"
			OLE_CloseFile( oWord )
			OLE_CloseLink( oWord )
			oWord := OLE_CreateLink( cEditor )
		EndIf

	   	If Alltrim(Funname()) <> "QDOA120"
		   IncProcDoc( STR0004 ) // "Ajustando propriedades do editor"
		Endif                           
	
	   OLE_SetProperty( oWord, oleWdVisible,   .f. )
	   OLE_SetProperty( oWord, oleWdPrintBack, .f. )
	   If !lObsoleto
		  OLE_SetProperty( oWord, oleWdLeft,   000 )
		  OLE_SetProperty( oWord, oleWdTop,    074 )
		  OLE_SetProperty( oWord, oleWdWidth,  600 )
		  OLE_SetProperty( oWord, oleWdHeight, 320 )
	   Endif
	
	   If Alltrim(Funname()) <> "QDOA120"
	      IncProcDoc( STR0007 ) // "Abrindo documento existente"
	   Endif
	
	   If cPreview == "2"
			OLE_OpenFile( oWord, ( cQPathTrm + cTexto ), .F., cMvSave, cMvSave )
	  	 	OLE_UpdateFields( oWord ) 
			If lAbreDoc
				QDODocumentControl():abreDocumentoDoServidorComArquivoTemporario(oWord, cTexto, lReadOnly)			
		  		OLE_SetProperty( oWord, oleWdVisible,   .f. )
			    OLE_SetProperty( oWord, oleWdPrintBack, .f. )
				OLE_OpenFile( oWord, ( cQPathTrm + cTexto ), .F., cMvSave, cMvSave )
			
		    Endif
		else
			 OLE_OpenFile( oWord, ( cQPathTrm + cTexto ), If(lSalva .Or. lObsoleto,.F.,lReadOnly), cMvSave, cMvSave )    
		EndIf
	Endif
	
	// Inicio do contorno problema da Impressão
	If !lEditor .OR. Empty(oWord) .OR. oWord == "-1"
		OLE_CloseFile( oWord )
		OLE_CloseLink( oWord )
		oWord := OLE_CreateLink( cEditor )
	EndIf
	OLE_SetProperty( oWord, oleWdVisible,   .f. )
	OLE_SetProperty( oWord, oleWdPrintBack, .f. )
	OLE_OpenFile( oWord, ( cQPathTrm + cTexto ), If(lSalva .Or. lObsoleto,.F.,lReadOnly), cMvSave, cMvSave ) 	
	// Fim contorno

	If Alltrim(Funname()) <> "QDOA120"
		IncProcDoc( STR0008 ) // "Transferindo dados do sistema"
	Endif
	
	If !Iif(lSalva .Or. lObsoleto,.F.,lReadOnly)
		QDOVar720() // função que absorveu o conteúdo do PE QDOM720

		If lExist720
			ExecBlock( "QDOM720", .f., .f. )
		EndIf
		
		If Alltrim(Funname()) <> "QDOA120"
			IncProcDoc( STR0009 ) // "Atualizando vari veis do editor"
		Endif
		OLE_UpdateFields( oWord )
	EndIf

	If lSalva
		If Alltrim(Funname()) <> "QDOA120"
			IncProcDoc( STR0010 ) // "Salvando documento"
		Endif
		OLE_SaveFile( oWord )
		lCpyS2T := .T.

	ElseIf nCopias > 0
		If Alltrim(Funname()) <> "QDOA120"
			IncProcDoc( STR0012 ) // "Imprimindo c¢pia"
		Endif
		OLE_PrintFile( oWord, "ALL",,, nCopias )

	Endif

	If Alltrim(Funname()) <> "QDOA120"
		IncProcDoc( STR0004 ) // "Ajustando propriedades do editor"
	Endif 

	OLE_SetProperty( oWord, oleWdVisible, .t. )

	If cMvQDHTML == "1"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Salva Documento em Html						       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqTmp := Left(AllTrim(M->QDH_NOMDOC),Len(AllTrim(M->QDH_NOMDOC))-3)+"htm"
		If Alltrim(Funname()) <> "QDOA120"
			IncProcDoc( STR0010 ) // "Salvando documento"
		Endif
		QDODocumentControl():OLE_SaveAsFile( oWord, (cQPathTrm+cArqTmp), "", "", .f., oleWdFormatHTML )
	EndIf

	If Alltrim(Funname()) <> "QDOA120"
		IncProcDoc( STR0013 ) // "Fechando link de comunica‡„o com o editor"
	Endif

	If Type("oWord") <> "U"
		OLE_CloseFile( oWord )
		OLE_CloseLink( oWord )
	Endif

	If !lMultP .And. File(cQPathTrm+cTextoD)
		FErase(cQPathTrm+cTextoD)
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QdoDocCon  ³Autor  ³ Aldo Marini Junior   ³ Data ³ 21/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Abre o Docto no Word apenas para Consulta                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QdoDocCon(lCpyS2T)

Local lLiberado := .f.
Local nI		:= 0
Local aUsrMat   := QA_USUARIO()
Local aSavQDH	:= {}
Local lApelido  := aUsrMat[1]
Local cMatFil   := aUsrMat[2]
Local cMatCod   := aUsrMat[3]
Local cMatDep   := aUsrMat[4]
Local lVisHtml  := .F.
Local lWordView := .F.
Local nOrdQD1   := QD1->(IndexOrd())
Local lLibLei 	:= GetMV( "MV_QLIBLEI" ) == "S"
Local lQDOPRVX  := ExistBlock( "QDOPRVX" )

Private lEditou:= .F.
Private lVisu  := .F.
Private lExcExt:= .F.
Private lNoExc := .F.

Default lCpyS2T := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Usuario Logado esta cadastrado no Cad.Usuarios/Responsaveis atraves   ³
//³ do Apelido cadastrado no Configurador                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !lLibLei
	If !lApelido 
		Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual do configurador."
	    Return .t.	
	Endif
EndIf

If Inclui .Or. ( QDH->QDH_STATUS $ "D  ,DC " .And. cMatFil + cMatCod == QDH->QDH_FILMAT + QDH->QDH_MAT )
   lLiberado := .t.
Else
	QD1->(DbSetOrder(1))
   	If QD1->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+cMatDep+cMatFil+cMatCod))   	   	
      	lLiberado := .t.
   	EndIf
	QD1->(DbSetOrder(nOrdQD1))
EndIf

If !lLiberado
   If GetMV( "MV_QLIBLEI" ) == "S" .And. QDH->QDH_STATUS == "L  "
		If QDH->QDH_SIGILO == "2"
      			lLiberado := .t.
		EndIf
   EndIf
EndIf

If !lLiberado
   MsgAlert( OemToAnsi( STR0014 ), OemToAnsi( STR0015 ) ) // "Documento n„o liberado" ### "Aten‡„o"
   Return .t.	
EndIf

DbSelectArea( "QDH" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva os dados das variaveis de memoria (M->) e alimenta	³
//³ conforme documento posicionado								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if funname() $ 'QDOC030'
	RegToMemory ("QDH",.F.,.F.,.F.)	
EndIf	
	
For nI := 1 To FCount()
	if funname() $ 'QDOA120/QDOC050'
		M->&( Eval( bCampo,nI ) ) := FieldGet( nI )                                                           	
		aAdd(aSavQDH,{M->(Eval(bCampo,nI)),M->&(Eval(bCampo,nI))})
	Else
		aAdd(aSavQDH,{M->(Eval(bCampo,nI)),M->&(Eval(bCampo,nI))})
		M->&( Eval( bCampo,nI ) ) := FieldGet( nI )                                                           		
	EndIf
Next i

If M->QDH_DTOIE == "I"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o Tipo de Visualizacao do Usuario (Html/WordView) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QDTPVisuEd(@lVisHtml,@lWordView,cMatFil,cMatCod)
	If lWordView .Or. (lVisHtml .And. M->QDH_STATUS == "L  ")
		If !QDOViewOLE(M->QDH_NOMDOC, M->QDH_DOCTO, M->QDH_RV)
			ProcessaView(.t.,lVisHtml)
		EndIf
	ElseIf lQDOPRVX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ponto de entrada envia numero do documento/revisão do doc interno, evitando a copia     ³
		//³ do doc do server para o terminal, dependendo do tratamento da Func do usuario.          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ExecBlock( "QDOPRVX", .F., .F.,{M->QDH_DOCTO, M->QDH_RV} ) 
	Else
		ProcessaDoc({||QdoDocImp( .f.,.t.,.f.,@lCpyS2T )})
	Endif

ElseIf M->QDH_DTOIE == "E"
	ProcessaDoc({ || QdoDocExt(.f.,.t.,@lCpyS2T) })
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura o conteudo das variaveis de memoria (M->) preenchidas anteriormente	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aSavQDH)
	M->&(aSavQDH[nI,1]) := aSavQDH[nI,2]
Next

Return .t.            


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ProcessaDoc³Autor ³ Newton R. Ghiraldelli ³ Data ³   /09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Processa Documento                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ProcessaDoc(ExpB1,ExpC1,ExpC2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ProcessaDoc( bAction, cTitle ,cMsg )

Local oDlg

Local lEnd  := .f.
Local nVal  := 0
Private oBmp
Private nBmp  := 1
Private nAtual
Default bAction := { || nil }
Default cMsg    := OemToAnsi( STR0018 ) // "Processando"
Default cTitle  := OemToAnsi( STR0019 ) // "Aguarde..."

DEFINE MSDIALOG oDlg;
       FROM     000, 000 TO 095, 310;
       TITLE    OemToAnsi( cTitle );
       STYLE    DS_MODALFRAME STATUS;
		 PIXEL
@ 005, 020 SAY  oNome;
           VAR  OemToAnsi( cMsg );
           FONT oDlg:oFont;
           SIZE 140, 010;
           OF   oDlg;
           PIXEL
@ 015, 003 METER oMeter;
           VAR   nVal;
           SIZE  150, 010;
           TOTAL 10;
           OF    oDlg;
           PIXEL
oDlg:bStart = { || Eval( bAction, @lEnd ),lEnd := .t., oDlg:End() }
nBmp := 1
ACTIVATE DIALOG  oDlg VALID lEnd CENTERED
Return nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³RegProcDoc³ Autor ³ Newton R. Ghiraldelli ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RegProcDoc( nTotal )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RegProcDoc( nTotal )

oMeter:nTotal := nTotal
nAtual        := 0

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³IncProcDoc³ Autor ³ Newton R. Ghiraldelli ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IncProcDoc(cMsg)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function IncProcDoc(cMsg)

oMeter:Set( ++nAtual )
oNome:SetText( OemToAnsi( cMsg ) )
SysRefresh()

Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ProcessaDoc³Autor ³ Newton R. Ghiraldelli ³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa para abertura do Docto com Word Viewer            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ProcessaView(ExpL1,ExpL2)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Baixa Pendencia                                    ³±±
±±³          ³ ExpL2 - Visualiza Documento HTML                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ProcessaView(lBaixa,lVisHtml,lCopiaMultp)

	Local aQPath        := QDOPATH()
	Local aUsrMat       := QA_USUARIO()
	Local cLinha        := ""
	Local cMatCod       := aUsrMat[3]
	Local cMatDep       := aUsrMat[4]
	Local cMatFil       := aUsrMat[2]
	Local cMvSave       := QDOPswOLE() // "Verifica se insere senha ou nao
	Local cNomeDoc      := POSICIONE("QDH",1,xFilial("QDH")+M->QDH_DOCTO+M->QDH_RV,"QDH_NOMDOC")
	Local cPathRem      := GetRemoteIniName()
	Local cPathView     := aQPath[6]
	Local cPView        := Alltrim( GetMv( "MV_QDPVIEW" ) )
	Local cQArqTmp      := ""
	Local cQPath        := aQPath[1] // Diretorio que contem os .CEL
	Local cQPathTrm     := aQPath[3]
	Local cSvFilAnt     := cFilAnt
	Local cTexto        := " "
	Local lATUVIEW      := SuperGetMv("MV_ATUVIEW",.F.,.F.) //Atualiza o documento via MS Word + PEs antes da leitura via MS Word View (.T./.F.).
	Local lCpyS2T       := .F.
	Local lExist700     := ExistBlock( "QDOM700" )
	Local lExist720     := ExistBlock( "QDOM720" )

	Default lCopiaMultp := .T.

	Private cApAprov    := " "
	Private cApElabo    := " "
	Private cApHomol    := " "
	Private cApRevis    := " "
	Private cAprovad    := " "
	Private cChave      := xFilial( "QDH" ) + M->QDH_DOCTO + " RV:" + M->QDH_RV
	Private cCodApDes   := Space( 06 )
	Private cCodApSol   := Space( 06 )
	Private cCodAtu     := " "
	Private cCodNov     := " "
	Private cDe         := " "
	Private cDepRece    := IF(M->QDH_STATUS == "L ",cMatDep," ")
	Private cDescr      := " "
	Private cDtEmiss    := dDatabase
	Private cEdit       := Alltrim( GetMV( "MV_QDTIPED" ) )
	Private cEditor     := "TMsOleWord97" //Space( 12 ) 
	Private cElabora    := " "
	Private cFilApDes   := Space( 02 )
	Private cFilApSol   := Space( 02 )
	Private cHomolog    := " "
	Private cMdpObs     := " "
	Private cMdpRaz     := " "
	Private cMdsObs     := " "
	Private cMdsRaz     := " "
	Private cMotRevi    := " "
	Private cNomFilial  := Space( 40 )
	Private cNomRece    := IF(M->QDH_STATUS == "L ",QA_nUsr( cMatFil, cMatCod )," ")
	Private cObjetivo   := " "
	Private cPara       := " "
	Private cRevalid    := " "
	Private cRevisor    := " "
	Private cRodape     := " "
	Private cSumario    := " "
	Private cTpCopia    := OemToAnsi( STR0016 )
	Private Inclui      := .F.
	Private lChCopia    := .T.

	If !QDOVlWorVi(1) //Valida se o modelo do documento na QD2 é válido para integração com Word Viewer
		Return .F.
	EndIf

	If  cFilAnt <> M->QDH_FILIAL .AND. !Empty(AllTrim(xFilial("QDH")))
		cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV

		aQPath    := QDOPATH()
		cQPath    := aQPath[1]	// Diretorio que contem os .CEL
		cQPathTrm := aQPath[3]
		cPathView := aQPath[6]

		cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
	EndIf

	If !Empty(AllTrim(xFilial("QDH")))
		If _cServerTmp <> Nil // Forço o reload das configurações
			_cServerTmp  := Nil 
			_aQdhCaminho := Nil
		EndIf
	EndIf

	If( Right( cPView, 1 ) # "\", cPView += "\", cPView ) 

	If Empty( M->QDH_DOCTO + M->QDH_RV )
	   Help( " ", 1, "QD050DOCND" )
		Return .f.		
	EndIf

	DbSelectArea( "QDH" )
	If Empty( cNomeDoc )
	   Help( " ", 1, "QDCDOCERR" )
	   Return .f.
	EndIf

	cTexto := Alltrim( cNomeDoc )
	If M->QDH_STATUS <> "L  "
		If !File( cQPathTrm + cTexto )
			CpyS2T(cQPath+cTexto,cQPathTrm,.T.)
		   	If !File( cQPathTrm + cTexto )
				lBaixa := .F.
			Endif
		EndIf
	ElseIf !lVisHtml
		If !File( cQPathTrm + cTexto )
			If M->QDH_STATUS = "L  " .And. lCopiaMultp
				If  cFilAnt <> M->QDH_FILIAL .AND. FWModeAccess("QDH")=="E"
					cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV
					QdoCamCel(cQPath, @cQPathTrm, cTexto)
					cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
				Else
					QdoCamCel(cQPath, @cQPathTrm, cTexto)			
				EndIf
			Else
				CpyS2T(cQPath+cTexto,cQPathTrm,.T.)
			Endif
		   	If !File(cQPathTrm + cTexto )
				lBaixa := .F.
			Endif
		EndIf
		Do While Right(cPathRem,1) <> "\"
			If Right(cPathRem,1) <> "\"
				cPathRem := Stuff(cPathRem,Len(cPathRem),1,"")
			Endif
		Enddo

		If !File(cPathRem+"ADVVIEW.EXE",2) 
			Alert(OemToAnsi(STR0023))  //"O ADVVIEW.EXE nao localizada. Ela deve estar no diretorio BIN\REMOTE."
			lBaixa := .F.
			Return .F.
		Endif	                           
		If Empty(cPathView) .OR. !File(cPathView+"WORDVIEW.EXE")	 
			Alert(OemToAnsi(STR0024))   //"Preencha o conteudo do Parametro (MV_QDPVIEW) com o Diretorio(Caminho) onde foi instalado o WordView na Estacao Local"
			lBaixa := .F.
			Return .F.	
		Endif
	EndIf

	If M->QDH_STATUS == "L  "
		If !Empty(M->QDH_CHAVE)
			cChave:= M->QDH_CHAVE
		EndIf
	
		If lVisHtml
			QDViewHtml(Alltrim(cTexto)) // Visualiza Html
		Else
			cQArqTmp := Left(cQPathTrm+cTexto,Len(cQPathTrm+cTexto)-4)+"_TMP.CEL"
			__CopyFile(cQPathTrm+cTexto,cQArqTmp)		
			If File(cQArqTmp)
				If lExist700
					ExecBlock( "QDOM700", .f., .f., { cEdit, cEditor } )
					
					If Empty( cEditor )
						Help( " ", 1, "QD_NEXTEDT" )
						Return .f.
					EndIf
				EndIf
				
				//Linha não alterada devido a complexidade de cobertura e descontinuação do Word Viewer
	 			QdoDocQa2(M->QDH_FILIAL)
								
				dbSelectArea( "QDH" )
				QDH->( DbSetOrder( 1 ) )
				If Type("oWord") <> "U"
					If !Empty(oWord) .And. oWord <> "-1"
						OLE_CloseFile( oWord )
						OLE_CloseLink( oWord )
					EndIf
				Endif

				IF QAA->QAA_TPWORD == '2' .AND. !lATUVIEW //Atualiza o documento via MS Word + PEs antes da leitura via MS Word View (.T./.F.).
					cLinha := "ADVVIEW "+cPView+"WORDVIEW "+cQArqTmp+" Microsoft Word Viewer"
				Else
					oWord := OLE_CreateLink( cEditor )
					If oWord <> "-1"                        
						OLE_SetProperty( oWord, oleWdVisible,   .f. )
						OLE_SetProperty( oWord, oleWdPrintBack, .f. )
						OLE_OpenFile( oWord, cQArqTmp, .F., cMvSave, cMvSave )
						
						QDOVar720() // função que absorveu o conteúdo do PE QDOM720

						If lExist720
							ExecBlock( "QDOM720", .f., .f. )
						EndIf
							
						OLE_UpdateFields( oWord )
						OLE_SaveFile( oWord )
						OLE_CloseFile( oWord )
						OLE_CloseLink( oWord )
						cLinha := "ADVVIEW "+cPView+"WORDVIEW "+cQArqTmp+" Microsoft Word Viewer"
					Else
						cLinha := "ADVVIEW "+cPView+"WORDVIEW "+cQPathTrm+cTexto+" Microsoft Word Viewer"
					Endif
				EndIf
			Endif
		EndIf
	Else
		nCopDoc	:= If(! GetMv("MV_QDOCPCN", .T., .T.) .And. QDH->QDH_CANCEL = "S", 0, 1) 
		ProcessaDoc( { || QdoDocRUsr( .T., .F. , ,.T.,, nCopDoc,@lCpyS2T,.F.) } )
		cLinha := "ADVVIEW "+cPView+"WORDVIEW "+cQPathTrm+cTexto+" Microsoft Word Viewer"
	Endif
	
	If !Empty(cLinha)
		nRecebe := WaitRun( cLinha )
		cLinha  := StrTran(cLinha, "ADVVIEW ", "")
		cLinha  := StrTran(cLinha, "WORDVIEW ", "WORDVIEW.EXE ")
		nRecebe := WaitRun( cLinha )
	EndIf
	
	If lBaixa
		QD1->(DbSetOrder(1))
		If QD1->(DbSeek(M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod))
			While QD1->(!Eof()) .And. M->QDH_FILIAL + M->QDH_DOCTO + M->QDH_RV + cMatDep + cMatFil + cMatCod == QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_DEPTO + QD1->QD1_FILMAT + QD1->QD1_MAT
				If QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND == M->QDH_STATUS
					Begin Transaction
						RecLock( "QD1", .f. )
						QD1->QD1_LEUDOC := "S"
						QD1->(MsUnlock())
					End Transaction
					Exit
				EndIf
				QD1->(DbSkip())
			Enddo
		EndIf
	EndIf							  

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDOVIEW   ³Autor ³ Aldo Marini Junior    ³ Data ³ 03/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa para abertura do Docto para visualizacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOVIEW( cFilDoc, cCodDoc, cRevDoc )

	Local aQPath      := Nil
	Local aRet        := Nil
	Local aUsrMat     := Nil
	Local bCampo      := Nil
	Local cAlias      := Nil
	Local cLinha      := Nil
	Local cMatCod     := Nil
	Local cMatDep     := Nil
	Local cMatFil     := Nil
	Local cMvSave     := Nil
	Local cPView      := Nil
	Local cQArqTmp    := Nil
	Local cQPath      := Nil
	Local cQPathTrm   := Nil
	Local cSvFilAnt   := Nil
	Local cTexto      := Nil
	Local lDocControl := .F.
	Local lExist700   := Nil
	Local lExist720   := Nil
	Local lView       := Nil
	Local nC          := Nil
	Local nOrdAlias   := Nil
	Local nRegAlias   := Nil
	Local oDocControl := Nil

	Private cApAprov   := Nil
	Private cApElabo   := Nil
	Private cApHomol   := Nil
	Private cApRevis   := Nil
	Private cAprovad   := Nil
	Private cChave     := Nil
	Private cCodApDes  := Nil
	Private cCodApSol  := Nil
	Private cCodAtu    := Nil
	Private cCodNov    := Nil
	Private cDe        := Nil
	Private cDepRece   := Nil
	Private cDescr     := Nil
	Private cDtEmiss   := Nil
	Private cEdit      := Nil
	Private cEditor    := Nil
	Private cElabora   := Nil
	Private cFilApDes  := Nil
	Private cFilApSol  := Nil
	Private cHomolog   := Nil
	Private cMdpObs    := Nil
	Private cMdpRaz    := Nil
	Private cMdsObs    := Nil
	Private cMdsRaz    := Nil
	Private cMotRevi   := Nil
	Private cNomFilial := Nil
	Private cNomRece   := Nil
	Private cObjetivo  := Nil
	Private cPara      := Nil
	Private cPreview   := Nil
	Private cRevalid   := Nil
	Private cRevisor   := Nil
	Private cRodape    := Nil
	Private cSumario   := Nil
	Private cTpCopia   := Nil
	Private Inclui     := Nil

	//Atribui Variáveis Locais
	aQPath       := QDOPATH()
	aRet         := {}
	aUsrMat      := QA_USUARIO()
	bCampo       :={|n| FieldName(n) }
	cAlias       := Alias()
	cLinha       := ""
	cMatCod      := aUsrMat[3]
	cMatDep      := aUsrMat[4]
	cMatFil      := aUsrMat[2]
	cMvSave      := QDOPswOLE() // "Verifica se insere senha ou nao
	cPView       := Alltrim( GetMv( "MV_QDPVIEW" ) )
	cQArqTmp     := ""
	cQPath       := aQPath[1] // Diretorio que contem os .CEL
	cQPathTrm    := aQPath[3]
	cSvFilAnt    := cFilAnt
	cTexto       := " "
	lExist700    := ExistBlock( "QDOM700" )
	lExist720    := ExistBlock( "QDOM720" )
	lView        := GetMv( "MV_QDVIEW" )
	nC           := Nil
	nOrdAlias    := IndexOrd()
	nRegAlias    := Recno()

	//Atribui Variáveis Private
	cApAprov   := " "
	cApElabo   := " "
	cApHomol   := " "
	cApRevis   := " "
	cAprovad   := " "
	cChave     := " "
	cCodApDes  := Space( 06 )
	cCodApSol  := Space( 06 )
	cCodAtu    := " "
	cCodNov    := " "
	cDe        := " "
	cDepRece   := Space( 20 )
	cDescr     := " "
	cDtEmiss   := dDatabase
	cEdit      := Alltrim( GetMV( "MV_QDTIPED" ) )
	cEditor    := "TMsOleWord97" //Space( 12 ) 
	cElabora   := " "
	cFilApDes  := Space( 02 )
	cFilApSol  := Space( 02 )
	cHomolog   := " "
	cMdpObs    := " "
	cMdpRaz    := " "
	cMdsObs    := " "
	cMdsRaz    := " "
	cMotRevi   := " "
	cNomFilial := Space( 40 )
	cNomRece   := Space( 30 )
	cObjetivo  := " "
	cPara      := " "
	cPreview   := GetMv("MV_QDPRVW",.T.,"1") // Indica a Utilização do Printpreview
	cRevalid   := " "
	cRevisor   := " "
	cRodape    := " "
	cSumario   := " "
	cTpCopia   := OemToAnsi( STR0016 )
	Inclui     := .F.

	If nModulo == 24 // Consistencia efetuada somente para o Controle de Documentos
		If  cFilAnt <> M->QDH_FILIAL
			cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV

			aQPath    := QDOPATH()
			cQPath    := aQPath[1]	// Diretorio que contem os .CEL
			cQPathTrm := aQPath[3]

			cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
		EndIf
	EndIf

	If !Empty(AllTrim(xFilial("QDH")))
		If _cServerTmp <> Nil // Forço o reload das configurações
			_cServerTmp  := Nil 
			_aQdhCaminho := Nil
		EndIf
	EndIf

	If ExistBlock( "QDOPRVW" )
		ExecBlock( "QDOPRVW", .F., .F.,{M->QDH_DOCTO, M->QDH_RV,M->QDH_STATUS} )
	Endif     
	If( Right( cPView, 1 ) # "\", cPView += "\", cPView ) 

	cCodDoc := Left(cCodDoc + Space(Len(QDH->QDH_DOCTO)), Len(QDH->QDH_DOCTO))
	cFilDoc := IF(cFilDoc == NIL, xFilial("QDH"),cFilDoc)

	If ExistBlock( "QDOVIEW" ) 
		aRet := ExecBlock( "QDOVIEW", .f., .f., { cFilDoc, cCodDoc, cRevDoc } )
		If ValType(aRet) = "A"
			cFilDoc := aRet[1]
			cCodDoc := aRet[2]
			cRevDoc := aRet[3] 
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca a ultima revisao vigente do Documento                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( cRevDoc ) .Or. cRevDoc = Nil
		DbSelectArea( "QDH" )
		DbSetOrder(1)
		If dbSeek( cFilDoc + cCodDoc )
			While !QDH->( Eof() ) .And. QDH->QDH_FILIAL + QDH->QDH_DOCTO == cFilDoc + cCodDoc
	         If QDH->QDH_STATUS == "L  " .And. QDH->QDH_OBSOL <> "S" .And. QDH->QDH_CANCEL <> "S"
	            cRevDoc := QDH->QDH_RV
	         Endif
			   DbSkip()
			Enddo
		Endif
		If Empty(cRevDoc) 
			If AllTrim(FunName()) == "QIEA215" 
		       MsgAlert( OemToAnsi( STR0029 ), OemToAnsi( STR0015 ) ) // "Nao existe medicao cadastrada." ### "Aten‡„o"
		    Else
		       Help( " ", 1, "QDNEXISREV" )	// Nao existe revisao vigente
			   dbSelectArea(cAlias)
			   dbSetOrder(nOrdAlias)
			   dbGoTo(nRegAlias)
		    Endif
		   	Return .F.	   
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se codigo do Documento estiver branco finaliza                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( cCodDoc )
		dbSelectArea(cAlias)
		dbSetOrder(nOrdAlias)
		dbGoTo(nRegAlias)
		Return .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se Nao achar finalizar                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QDH")
	dbSetOrder(1)
	If !dbSeek( cFilDoc + cCodDoc + cRevDoc)
		dbSelectArea(cAlias)
		dbSetOrder(nOrdAlias)
		dbGoTo(nRegAlias)
	   Return .f.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Documento com o Status diferente de Leitura nao podera ser aberto                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QDH->QDH_STATUS <> "L  "
		dbSelectArea(cAlias)
		dbSetOrder(nOrdAlias)
		dbGoTo(nRegAlias)
	   Return .f.
	Endif

	For nC :=1 to fCount()
	    M->&( Eval( bCampo,nC ) ) := FieldGet( nC )
	Next

	//Desvio para Visualização Interna no ERP
	If QDOViewOLE(M->QDH_NOMDOC, M->QDH_DOCTO, M->QDH_RV)
		Return .T.
	EndIf

	If ExistBlock( "QDOPRVW" )
		ExecBlock( "QDOPRVW", .F., .F.,{M->QDH_DOCTO, M->QDH_RV,M->QDH_STATUS} )
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Documento com nome em branco significa erro na copia do Server/Client             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( M->QDH_NOMDOC )
	   Help( " ", 1, "QDCDOCERR" )
		dbSelectArea(cAlias)
		dbSetOrder(nOrdAlias)
		dbGoTo(nRegAlias)
	   Return .f.
	EndIf

	cChave := M->QDH_FILIAL + M->QDH_DOCTO + "  RV:" + M->QDH_RV
	cNomRece := IF(M->QDH_STATUS == "L  ",QA_nUsr( cMatFil, cMatCod )," ")
	cDepRece := IF(M->QDH_STATUS == "L  ",cMatDep," ")

	cTexto := Alltrim( M->QDH_NOMDOC )

	If M->QDH_DTOIE != "I"
		IF FindClass(Upper("QDODocumentControl"))
			oDocControl := QDODocumentControl():New() 
			lDocControl := oDocControl:abreDocumentoExternoDoServidor(cTexto, M->QDH_DOCTO, M->QDH_RV)
		EndIf
	EndIf

	If !lDocControl
		If !File( cQPathTrm + cTexto )
			If M->QDH_STATUS = "L  "
				If  cFilAnt <> M->QDH_FILIAL .AND. FWModeAccess("QDH")=="E"
					cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV
					QdoCamCel(cQPath, @cQPathTrm, cTexto)
					cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
				Else
					QdoCamCel(cQPath, @cQPathTrm, cTexto)
				EndIf
			Else
				CpyS2T(cQPath+cTexto,cQPathTrm,.T.)
			Endif
			If ! File( cQPathTrm + cTexto )
				Help( " ", 1, "QDCDOCERR" )
				dbSelectArea(cAlias)
				dbSetOrder(nOrdAlias)
				dbGoTo(nRegAlias)
				Return .F.
			Endif
		Endif

		cQArqTmp := Left(cQPathTrm+cTexto,Len(cQPathTrm+cTexto)-4)+"_TMP.CEL"
		__CopyFile(cQPathTrm+cTexto,cQArqTmp)

		If File(cQArqTmp)
			If M->QDH_DTOIE == "I"
				If lExist700
					ExecBlock( "QDOM700", .f., .f., { cEdit, cEditor } )

					If Empty( cEditor )
						Help( " ", 1, "QD_NEXTEDT" )
						Return .f.
					EndIf
				EndIf

				QdoDocQa2()
						
				dbSelectArea( "QDH" )
				QDH->( DbSetOrder( 1 ) )
				If Type("oWord") <> "U"
					If !Empty(oWord) .And. oWord <> "-1"
						OLE_CloseFile( oWord )
						OLE_CloseLink( oWord )
					EndIf
				Endif
				
				oWord := OLE_CreateLink( cEditor )
				
				If oWord <> "-1"
					OLE_SetProperty( oWord, oleWdVisible,   .f. )
					OLE_SetProperty( oWord, oleWdPrintBack, .F. )
					OLE_OpenFile( oWord, cQArqTmp, .F., cMvSave, cMvSave )
					If cPreview == "2"
						QDODocumentControl():abreDocumentoDoServidorComArquivoTemporario(oWord, cTexto, .T.)
					Else
						QDOVar720() // função que absorveu o conteúdo do PE QDOM720

						If lExist720
							ExecBlock( "QDOM720", .f., .f. )
						EndIf
							
						OLE_UpdateFields( oWord )
						OLE_SaveFile( oWord )
						OLE_CloseFile( oWord )
					Endif
					
					If lView == "S"
						OLE_CloseLink( oWord )
						cLinha := "ADVVIEW "+cPView+"WORDVIEW "+cQArqTmp+" Microsoft Word Viewer"
						nRecebe := WaitRun( cLinha )
					Else
						OLE_SetProperty( oWord, oleWdVisible,   .T. )
						OLE_SetProperty( oWord, oleWdPrintBack, .T. )
						OLE_OpenFile( oWord, cQArqTmp, .T., cMvSave, cMvSave )
					Endif
				Else
					cLinha := "ADVVIEW "+cPView+"WORDVIEW "+cQArqTmp+" Microsoft Word Viewer"
					nRecebe := WaitRun( cLinha )
				Endif
				OLE_CloseLink( oWord ,.F.)
			Else
				QA_OPENARQ(cQPathTrm+cTexto)
			EndIf
		Endif
	EndIf

	dbSelectArea(cAlias)
	dbSetOrder(nOrdAlias)
	dbGoTo(nRegAlias)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDViewHtml³Autor ³ Eduardo de Souza      ³ Data ³ 02/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Programa para visualizacao em Html                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDViewHtml(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nome do Arquivo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDViewHtml(cArquivo)

	Local oWnd 
	Local oNet 

	Local aQPath    := QDOPATH()
	Local lRemotp:= GetRemoteType() == 2 
	Local cQPathTrm := aQPath[3]
	Local cQPathHtm := aQPath[5]
	Local aDiretorio:= {}
	Local nMyWidth  := oMainWnd:nClientWidth - 16 
	Local nMyHeight := oMainWnd:nClientHeight- 30
	Local cTitulo   := AllTrim(QDH->QDH_TITULO)
	Local nDirHtml  := 0
	Local nT
	Local cSvFilAnt := cFilAnt 

	If  cFilAnt <> M->QDH_FILIAL .AND. !Empty(AllTrim(xFilial("QDH")))
		cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV

		aQPath    := QDOPATH()
		cQPathTrm := aQPath[3]
		cQPathHtm := aQPath[5]

		cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
	EndIf

	If !File(cQPathTrm+SubStr(cArquivo,1,8)+".htm")
		CpyS2T(cQPathHtm+SubStr(cArquivo,1,8)+".htm",cQPathTrm,.T.)
		aDiretorio:= QDocDirc(cQPathHtm,"D") //DIRECTORY	
		If Len(aDiretorio) > 0
			nPosDir:= ASCAN(aDiretorio,{|X| Substr(cArquivo,1,8)+"_" $ X[1] })
			If nPosDir > 0
				If ( nDirHtml:= MakeDir(cQPathTrm+aDiretorio[nPosDir,1])) == 0
					aData  := QDocDirc(cQPathHtm+aDiretorio[nPosDir,1]) //DIRECTORY
					For nT:= 1 to Len(aData)
						If File(cQPathHtm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]))
							CpyS2T(cQPathHtm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]),cQPathTrm+aDiretorio[nPosDir,1],.T.)
						Endif
					Next
				EndIf
			EndIf
		EndIf
	EndIf

	If !lRemotp
		DEFINE MSDIALOG oWnd TITLE cTitulo FROM 5,5 TO nMyHeight,nMyWidth  Of oMainWnd PIXEL 

		oFwLayer := FwLayer():New()
		oFwLayer:Init( oWnd, .f., .t. )
		oFWLayer:AddLine( 'INDIV', 5, .F. )
		oFWLayer:AddLine( 'MOV', 95, .F. )
		oFWLayer:AddCollumn( 'INDIVCOL' , 100, .T., 'INDIV' )
		oFWLayer:AddCollumn( 'MOVCOL' , 100, .T., 'MOV' )
		oPnInd := oFWLayer:GetColPanel( 'INDIVCOL', 'INDIV' )
		oPnMov := oFWLayer:GetColPanel( 'MOVCOL', 'MOV' )

		@ 002,003 BUTTON oBtnSair PROMPT OemToAnsi("Sair") SIZE 035,010 PIXEL OF oPnInd; // "Sair"
						ACTION oWnd:End()

		//https://tdn.totvs.com/x/G5iRDg - Classe TWebChannel
		//https://tdn.totvs.com/x/z5SRDg - Classe TWebEngine
		oWebChannel := TWebChannel():New()
		oWebChannel:Connect()

		If !oWebChannel:lConnected
			UserException("Erro na conexao com o WebSocket")
			Return
		EndIf

		cLink := cQPathTrm+SubStr(cArquivo,1,8)+".htm"

		oWebChannel:bJsToAdvpl := {|self,codeType,codeContent| oInstance:JsToAdvpl(self,codeType,codeContent) } 
		oWebEngine := TWebEngine():New(oPnMov, 50, 0, (nMyWidth-2)/2, ((nMyHeight-2)/2)-16, NIL, oWebChannel:nPort)
		oWebEngine:Navigate(cLink)
		oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oWnd CENTERED 
	Else
	   	cArquivo:=Lower(cArquivo)
		WinExec("linexec "+cQPathTrm+SubStr(cArquivo,1,8)+".htm")				
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QDRemDirHtm³Autor ³ Eduardo de Souza      ³ Data ³ 02/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Remove Arquivos Html do Diretorio Temporario               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDRemDirHtm(ExpC1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nome do Arquivo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDRemDirHtm(cArquivo, lPosQDH)

	Local aQPath    := QDOPATH()
	Local cQPathTrm := aQPath[3]
	Local aDiretorio:= {}
	Local aData     := {}
	Local nPosDir   := 0
	Local nCnt      := 0
	Local cSvFilAnt := cFilAnt

	Default lPosQDH := .T. // Variavel usada para  verificar se a QDH esta aberta

	If lPosQDH
		If  cFilAnt <> M->QDH_FILIAL .AND. !Empty(AllTrim(xFilial("QDH")))
			cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV

			aQPath    := QDOPATH()
			cQPathTrm := aQPath[3]

			cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
		EndIf              
	EndIf

	cArquivo:= Left(AllTrim(cArquivo),Len(AllTrim(cArquivo))-4)

	aDiretorio:= QDocDirc(cQpathTrm,"D") //DIRECTORY
	If Len(aDiretorio) > 0
		nPosDir:= ASCAN(aDiretorio,{|X| cArquivo+"_" $ X[1] })
		If nPosDir > 0
			aData  := QDocDirc(cQPathTrm+aDiretorio[nPosDir,1]) //DIRECTORY
			For nCnt:= 1 to Len(aData)
				If File(cQPathTrm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nCnt,1]))
					FErase(cQPathTrm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nCnt,1]))
				Endif
			Next
		EndIf
		If Len(aData) > 0
			DirRemove(cQPathTrm+aDiretorio[nPosDir,1])	
		EndIf
	EndIf
	FErase(cQPathTrm+cArquivo+".htm")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QDTPVisuEd³Autor ³ Eduardo de Souza      ³ Data ³ 04/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica o Tipo de Visualizacao do Usuario (Html/WordView) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDTPVisuEd(ExpL1,ExpL2,ExpC1,ExpC2)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Visualiza Html                                     ³±±
±±³Parametros³ ExpL2 - Visualiza WordView                                 ³±±
±±³Parametros³ ExpC1 - Filial do Usuario                                  ³±±
±±³Parametros³ ExpC2 - Matricula do Usuario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QDOXDOC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDTPVisuEd(lVisHtml,lWordView,cMatFil,cMatCod)

	Local lView  := GetMv( "MV_QDVIEW" )
	Local cMvHTML:= GetMV("MV_QDCHTM",.F.,"N") // "Visualiza Html"

	QAA->(DbSetOrder(1))
	If QAA->(DbSeek(cMatFil+cMatCod))
		If QAA->QAA_TPWORD == "1" .And. cMvHTML == "S"
			lVisHtml:= .T.
		ElseIf QAA->QAA_TPWORD == "2" .And. lView == "S"
			lWordView:= .T.
		EndIf
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QdoDocExt ³ Autor ³ Eduardo de Souza      ³ Data ³ 25/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava documento externo no diretorio de documentos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QdoDocExt()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QdoDocExt(lAlter,lDetalhe,lCpyS2T,lDocOK)

	Local aQPath      := QDOPATH()
	Local aUsrMat     := QA_USUARIO()
	Local cMatCod     := aUsrMat[3]
	Local cMatDep     := aUsrMat[4]
	Local cMatFil     := aUsrMat[2]
	Local cQPath      := aQPath[1] // Diretorio que contem os .CEL/.EXT
	Local cQPathTrm   := aQPath[3]
	Local cSvFilAnt   := cFilAnt
	Local cTexto      := ""
	Local lBloqMsg    := If(GetMv("MV_QBLQMSG",.T.,"1") == "1",.T.,.F.) //Bloqueia a finalizacao de doc. externo, quando nao informado. 1=Sim /2=Nao                          
	Local lDiferente  := .F.
	Local lDupExt     := GETMV("MV_QDUPEXT",.F.,"2") == "1" //1=SIM ; 2=NAO Duplica o Documento externo na Revisao.
	Local lNew        := .f.
	Local lReturn     := .T.
	Local oDocControl := Nil

	Default lDetalhe:= .F.
	Default lCpyS2T := .F.
	Default lDocOK  := .F.

	IF FindClass(Upper("QDODocumentControl"))
		oDocControl := QDODocumentControl():New() 
	EndIf

	lNoExc := .F. 

	If  cFilAnt <> M->QDH_FILIAL .AND. !Empty(AllTrim(xFilial("QDH")))
		cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV
		
		aQPath       := QDOPATH()
		cQPath       := aQPath[1]	  // Diretorio que contem os .CEL
		cQPathTrm    := aQPath[3]
		
		cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
	EndIf

	If !Empty(AllTrim(xFilial("QDH")))
		If _cServerTmp <> Nil // Forço o reload das configurações
			_cServerTmp  := Nil 
			_aQdhCaminho := Nil
		EndIf
	EndIf

	If Empty( M->QDH_DOCTO + M->QDH_RV )
	Help( " ", 1, "QD050DOCND" )
		Return .F.
	EndIf

	If Empty(M->QDH_NOMDOC)
		If lAlter
			lExcExt:= .F. 
			lNew   := .T.
			lCpyS2T:= .T.
		
		cTexto := StrZero(Val(QA_SEQU("DOCEXT",6,"N")),6)+SubStr(StrZero(year(dDataBase),4),3,2)
		While File(cQPath+cTexto)
				cTexto:= StrZero(Val(QA_SEQU("DOCEXT",6,"N")),6)+SubStr(StrZero(year(dDataBase),4),3,2)
		EndDo
		
		If !File(cQPathTrm+cTexto)
			lEditou:=.t.
				cArquivo:= Trim(cGetFile(PADR("Todos Arquivos(*.*)",27)+"|*.*|" ,"Selecione Diretorio e Arquivo",0,,.T.,49))
				If Empty(cArquivo)
					Help(" ",1,"QD050DND") // "Documento nao foi criado."
					If lBloqMsg
						Return .F.
					Else
						lReturn:= .F.
					Endif
				Endif 
						
				IF QDOCLExt(cArquivo) == 0 // Arquivo nao tem extensao
					M->QDH_NOMDOC:= "DOCEXT"+Alltrim(Str(Day(Date())))+Alltrim(Str(Month(Date())))+Alltrim(Str(Year(Date())))
					lReturn:= .F.

					//STR0015 - "Atenção"
					//STR0058 - "Não foi selecionado um arquivo válido para prosseguir."
					//STR0059 - "Selecione um arquivo com extensão."
					Help(NIL, NIL, STR0015, NIL, STR0058, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0059}) 
					M->QDH_NOMDOC := ""
					Return QdoDocExt(lAlter,lDetalhe,@lCpyS2T,@lDocOK)

				Else
					cTexto  := cTexto+SubStr(cArquivo,QDOCLExt(cArquivo))
					QDODocumentControl():copiaProtegidaArquivo(cArquivo, cQPathTrm+cTexto)
				
					If !File(cQPathTrm+cTexto)
						Help(" ",1,"QD_DOCNEXT")
						lReturn:= .F.
					EndIf
					M->QDH_NOMDOC:= cTexto
				EndIf
			EndIf
		Else
			Help(" ",1,"QDNDOCEXT") // "Nao existe documento externo relacionado neste documento"
			lReturn:= .F.
		EndIf
	Else   
		If lAlter .and. lDupExt
			lCpyS2T:= DocExDlg(cQPathTrm) //Visualiza ou Altera ou Exclui
		Endif	
		If lVisu .and. lEditou .and. !lExcExt
			MessageDlg(STR0049,,3) //"Houve edição do documento e ainda não foram salvas as alterações, não poderá efetuar a visualização"
			Return(.F.)
		Endif
		cTexto:= Alltrim(M->QDH_NOMDOC)
		If !lExcExt .and. (At("DOCEXT",M->QDH_NOMDOC) > 0 .Or. Empty(M->QDH_NOMDOC))
			Help(" ",1,"QDNDOCEXT") //"Nao existe documento externo relacionado neste documento"
			lReturn:= .F.
		Elseif !lExcExt
			If !File(cQPathTrm+cTexto)
				If M->QDH_STATUS = "L  "
					If  cFilAnt <> M->QDH_FILIAL .AND. FWModeAccess("QDH")=="E"
						cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV
						QdoCamCel(cQPath, @cQPathTrm, cTexto)
						cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
					Else
						QdoCamCel(cQPath, @cQPathTrm, cTexto)
					EndIf				
				Else
					QDODocumentControl():copiaProtegidaArquivo(cQPath+cTexto, cQPathTrm+cTexto)
				Endif

				If !File(cQPathTrm+cTexto)
					Help(" ",1,"QD_DOCNEXT")
					lReturn:= .F.
				EndIf
			ElseIf File(cQPathTrm+cTexto) .AND. File(cQPath+cTexto)
				lDiferente := oDocControl == Nil .Or. !oDocControl:conteudoArquivosIguais(cQPath+cTexto, cQPathTrm+cTexto)
				If lDiferente .AND. M->QDH_STATUS $ "L  |I  "
					fErase(cQPathTrm+cTexto)
					If M->QDH_STATUS = "L  "
						If  cFilAnt <> M->QDH_FILIAL .AND. FWModeAccess("QDH")=="E"
							cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV
							QdoCamCel(cQPath, @cQPathTrm, cTexto)
							cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
						Else
							QdoCamCel(cQPath, @cQPathTrm, cTexto)
						EndIf				
					Else
						__CopyFile(cQPath+cTexto,cQPathTrm+cTexto)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abre Documento Externo. 			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lReturn .and. !lExcExt .and. !lNoExc
		IF oDocControl != Nil .AND. !Inclui .And. !lAlter
			If !oDocControl:abreDocumentoExternoDoServidor(cTexto, M->QDH_DOCTO, M->QDH_RV)
				QA_OPENARQ(cQPathTrm+cTexto)
			EndIf	
		Else
			QA_OPENARQ(cQPathTrm+cTexto)
		EndIf

		If Type("lAltDoc") == "L" .And. lAltDoc 
			//STR0064 - "Antes de encerrar esta sessão, certifique se de salvar e fechar o documento externo."
			MessageBox(STR0064,"QDODOCEXT",0)
		Else
			//STR0065 - "Documento externo aberto apenas para consulta, as alterações não serão enviadas para o servidor."
			MessageBox(STR0065,"QDOVIEWDOCEXT",0)
		EndIf

	EndIf

	If !lDetalhe .And. lReturn
		QD1->(DbSetOrder(1))
	If QD1->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+cMatDep+cMatFil+cMatCod))
		While QD1->(!Eof()) .And. QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+cMatDep+cMatFil+cMatCod
			If QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND == M->QDH_STATUS
					RecLock("QD1",.F.)
				QD1->QD1_LEUDOC:= "S"
				QD1->(MsUnlock())
				Exit
			EndIf
			QD1->(DbSkip())
		EndDo	
		EndIf
	EndIf

	lDocOK := lReturn

Return lReturn

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QdoCamCel ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 28/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o caminho da localizacao do arquivo .CEL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QdoDocExt()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQDO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QdoCamCel(cQPath, cQPathTrm, cArqCel, lMultP)

	Local _nQdhCaminho, nHandle
	Local _IpComputerClient := GetClientIp()
	Local _IpAUX            := GetClientIp()
	Local nConfig1:=0
	Local nConfig2:=0
	Local nConfig3:=0
	Local nCnt     := 0
	Local nInic    := 1	
	Local cQXFilial  := xFilial("SX5")
	Local nConfigCp	 := 0
	Local nConfigPrio:= 0
	Local lFile	   := .T.
	Local nI	   := 0
	Local aSx5

	Default lMultP := .F.

	// Modifica a chave  de Busca, campo 'Filial' na Tabela "QX" seguira o compartilhamento da QDH
	If GetMV("MV_QCOMPQX",.F.,.F.)
		cQXFilial  := xFilial("QDH")
	EndIf

	If _aMascara == NIL
		_aMascara := {"","","",""}
	Endif

	If _cServerTmp == NIL
		_cServerTmp := cQPath
	Else
		If !File(cQPathTrm+cArqCel)
			If File(_cServerTmp+cArqCel)
				__CopyFile(_cServerTmp+cArqCel,cQPathTrm+cArqCel)
				Return
			Else
				_cServerTmp := cQPath
			Endif
		Endif
	Endif

	If _aQdhCaminho = Nil
		aSx5 := FWGetSX5("QX")
		_aQdhCaminho := {}
		For nI := 1 To Len(aSx5) 
			If aSx5[nI][1] == cQXFilial
				Aadd(_aQdhCaminho, AllTrim(aSx5[nI][4]))
				If Right(_aQdhCaminho[Len(_aQdhCaminho)], 1) <> "\"
					_aQdhCaminho[Len(_aQdhCaminho)] += "\"
				Endif
			Else
				Exit
			EndIf
		Next nI
	Endif

	If !Empty(_IpComputerClient)
		_IPAux := _IpComputerClient
		For nCnt:=1 to 4
			If (nIp := AT(".",_IPAUX)) > 0
				_aMascara[nCnt]:= SubStr(_IPAUX,1,nIp-1)
				_IPAUX := SubStr(_IPAUX,nIp+1,Len(_IPAUX))
				nInic := nIp+1	
			Endif
		Next
		If !Empty(_IPAUX)
			_aMascara[4]:= _IPAUX
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Colocado a funcao File() dentro do IF para ficar mais rapido       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For _nQdhCaminho := 1 To Len(_aQdhCaminho)
		If AT(".",_aQdhCaminho[_nQdhCaminho]) > 0
			If (_aMascara[1]+"."+_aMascara[2]+"."+_aMascara[3]) $ _aQdhCaminho[_nQdhCaminho] .And. nConfig3 == 0
				If File(_aQdhCaminho[_nQdhCaminho] + cArqCel)
					nConfig3 	:= _nQdhCaminho
					nConfigPrio	:= 4
				Endif
				nConfigCp := If (nConfigPrio < 4,_nQdhCaminho,nConfigCp)
			ElseIf (_aMascara[1]+"."+_aMascara[2]) $ _aQdhCaminho[_nQdhCaminho] .And. (nConfig3 + nConfig2) == 0
				If File(_aQdhCaminho[_nQdhCaminho] + cArqCel)
					nConfig2	:= _nQdhCaminho
					nConfigPrio	:= 3
				Endif
				nConfigCp := If(nConfigPrio < 3,_nQdhCaminho,nConfigCp)
			ElseIf _aMascara[1] $ _aQdhCaminho[_nQdhCaminho] .And. (nConfig3 + nConfig2 + nConfig1) == 0
				If File(_aQdhCaminho[_nQdhCaminho] + cArqCel)
					nConfig1	:= _nQdhCaminho
					nConfigPrio	:= 2
				Endif
				nConfigCp := If(nConfigPrio < 2,_nQdhCaminho,nConfigCp)
			Endif
		Endif	
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A prioridade da mascara eh da nConfig3, depois nConfig2 e nConfig1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nConfig3 + nConfig2 + nConfig1) > 0
		If nConfig3 > 0
			_cServerTmp := _aQdhCaminho[nConfig3]
		ElseIf nConfig2 > 0
			_cServerTmp := _aQdhCaminho[nConfig2]
		ElseIf nConfig1 > 0
			_cServerTmp := _aQdhCaminho[nConfig1]
		Endif
		lMultP := .T.
	Else
		For _nQdhCaminho := 1 To Len(_aQdhCaminho)
			If File(_aQdhCaminho[_nQdhCaminho] + cArqCel)
				_cServerTmp := _aQdhCaminho[_nQdhCaminho]
				lMultP := .T.
				Exit
			Else
				nHandle := fCreate(_aQdhCaminho[_nQdhCaminho] + "TESTE")	// Tenta Criar arquivo teste para ver se diretorio existe
				If nHandle <> -1  // Nao Consegui criar arquivo no diretorio
					fClose(nHandle)
					fErase(_aQdhCaminho[_nQdhCaminho]+"TESTE")
					_cServerTmp := _aQdhCaminho[_nQdhCaminho]
					lMultP := .T.
					Exit
				Endif			
			Endif
		Next
	Endif

	If !lMultP	// Armazenamento dos doctos em um unico Server
		QDODocumentControl():copiaProtegidaArquivo(cQPath+cArqCel, cQPathTrm+cArqCel)
	Else		// Armazenamento dos doctos em varios Server's
		// Verifica se o arquivo no Server QX é o mesmo do Server
		If File(_cServerTmp+cArqCel) .AND. File(cQPath+cArqCel)
			aTempQX := DIRECTORY(_cServerTmp+cArqCel) 
			aDocs   := DIRECTORY(cQPath+cArqCel)
			For nI := 1 To Len(aTempQX) // Verificacao de diferencas entre arquivo temporario e servidor
				If aTempQX[1][nI] <> aDocs[1][nI]
					lFile := .T.
				Endif
			Next
			If lFile
				fErase(_cServerTmp+cArqCel)
			EndIf
		EndIf
		
		If File(_cServerTmp + cArqCel)
			__CopyFile(_cServerTmp+cArqCel,cQPathTrm+cArqCel)
		Else
			nHandle := fCreate(_cServerTmp + "TESTE")	// Tenta Criar arquivo teste para ver se diretorio existe
			If nHandle <> -1  // Nao Consegui criar arquivo no diretorio
				fClose(nHandle)
				fErase(_cServerTmp+"TESTE")
				__CopyFile(cQPath+cArqCel,_cServerTmp+cArqCel)
				__CopyFile(_cServerTmp+cArqCel,cQPathTrm+cArqCel)
			Endif			
		Endif
		
		//Replica o arquivo para o servidor preferencial
		If nConfigCp > 0 .And. _aQdhCaminho[nConfigCp] != _cServerTmp
			_cServerTmp := _aQdhCaminho[nConfigCp]
			nHandle := fCreate(_cServerTmp + "TESTE")	// Tenta Criar arquivo teste para ver se diretorio existe
			If nHandle <> -1  // Consegui criar arquivo no diretorio
				fClose(nHandle)
				fErase(_cServerTmp+"TESTE")
				__CopyFile(cQPath+cArqCel,_cServerTmp+cArqCel)
			EndIf
		EndIf
	Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOChkRmt ºAutor  ³Telso Carneiro      º Data ³  26/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Checa se o Remote e Linux                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QDOChkRmt()
Local lRet:= .F.

IF GetRemoteType() == 2  
	MsgAlert(STR0022)
	lRet:=.T.
Endif

Return(lRet)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOCLExt  ºAutor  ³Telso Carneiro      º Data ³  02/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Localiza a Extensao de Arquivos para Documentos Externos   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QDOCLExt(cNmArq)
Local nRet	:=0
Local nC	:=0
Local cBarra:=IIF(GetRemoteType() == 2,"/","\")   //Checa se o Remote e Linux    

For nC:=Len(cNmArq) TO 1 Step -1
	IF Subs(cNmArq,nC,1)== cBarra
		Exit
	Endif
	IF Subs(cNmArq,nC,1)=="."
		nRet:=nC
		Exit
	Endif
Next

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DocExDlg  ºAutor  ³Telso Carneiro      º Data ³  20/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela que Pergunta Visualiza ou Edita o Documento Externo   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOXDOC,QDOXFUN                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function DocExDlg(cQPathTrm)

Local oDlgExt
Local oBtn1
Local oBtn2
Local lRet :=.F.
Local lExc :=.F.

DEFINE MSDIALOG oDlgExt TITLE OemToAnsi(STR0015)+" !" FROM 000, 000 TO 090, 300 PIXEL //"Atençäo"
	

@ 006, 040 SAY  OemToAnsi(STR0025) OF oDlgExt PIXEL	 //"Consta um Documento Externo."
@ 013, 030 SAY  OemToAnsi(STR0026) OF oDlgExt PIXEL  //"Deseja Visualiza-lo ou Edita-lo ou Exclui-lo ?"

@ 023, 005 TO 023,148 LABEL "" OF oDlgExt PIXEL	

DEFINE SBUTTON oBtn1 FROM 030, 20 TYPE 15 ENABLE OF oDlgExt;
		ACTION (lVisu:=.T.,If(lEditou,lRet:=.T.,lRet:=.F.),oDlgExt:End())
					
DEFINE SBUTTON oBtn2 FROM 030, 60 TYPE 11 ENABLE OF oDlgExt;
		ACTION (MsgAlert(STR0027),lRet:=.T.,lEditou:=.T.,lVisu:=.F., oDlgExt:End()) //"Não esqueça de salva-lo e fecha-lo antes de baixar a pendencia!"

DEFINE SBUTTON oBtn3 FROM 030, 100 TYPE 3 ENABLE OF oDlgExt;
		ACTION (lExc:=.T.,lExcExt:=.T.,oDlgExt:End()) 
	
ACTIVATE MSDIALOG oDlgExt CENTERED

IF lExc
	IF MsgNoYes(STR0028) //"Confirma a Exclusão do Documento Externo ?"
		If File(cQPathTrm+Alltrim(M->QDH_NOMDOC))
			Ferase(cQPathTrm+Alltrim(M->QDH_NOMDOC))
		Endif
		M->QDH_NOMDOC:=Space(TamSx3("QDH_NOMDOC")[1])
		lVisu:=.T.
	Else
		lVisu:=.T.
		lExcExt:=.F.  
		lNoExc:=.T.
	Endif
Endif	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDocDirc  ºAutor  ³Telso Carneiro      º Data ³  03/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para obter resultado da funcao DIRECTORY para windowsº±±
±±º          ³ e linux atendendo patch de remote ou server                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QDocDirc(cQDirPat,cTipo)         

Local aAuxList	:={} 
Local aDircLst	:={} 
Local i			:=0
Local cBarRmt	:=IIF(GetRemoteType() == 2	,"/","\")   //Checa se o Remote e Linux    
Local cBarSrv	:=IIF(ISSRVUNIX()			,"/","\")   //Checa se o Server e Linux 
Local cBar		   

Default cTipo	:="A"

IF Left (cQDirPat, 1 ) == "/" .OR. Left (cQDirPat, 1 ) == "\"
	cBar:=cBarSrv 
Else
	cBar:=cBarRmt
Endif

If Right( cQDirPat, 1 ) # cBar
	cQDirPat  += cBar
Endif      

aAuxList:=DIRECTORY(cQDirPat+"*.*","D")
For i:=1 To Len(aAuxList)
	IF aAuxList[i,5]==cTipo
		AAdd(aDircLst,aAuxList[i])
	Endif
Next

Return(aDircLst)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDSobDoc  ºAutor  ³Rafael S. Bernardi  º Data ³  10/05/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que pergunta ao usuario se ele deseja sobrescrever o º±±
±±º          ³documento que esta na pasta temporaria ou se deseja mante-loº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOXDOC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDSobDoc(aTemp,aDoc)

Local cBreak      := chr(13)+chr(10)
Local lFecha      := .F.
Local nRet        := 3
Local oBtDet      := NIL
Local oBtNo       := NIL
Local oBtYes      := NIL
Local oDlgDoc     := NIL
Local oDocControl := QDODocumentControl():New()
Local oGroup      := NIL

oDocControl:logMsgNaDocsDoServidor("QDOSOBR", STR0032 + cBreak + STR0033 + cBreak + STR0034 + cBreak + STR0035 + cBreak + STR0050 + cBreak + STR0053 + cBreak + STR0052, "aTemp: " + ArrTokStr(aTemp) + " - aDoc: " + ArrTokStr(aDoc), "MSDIALOG", AllTrim(QDH->QDH_NOMDOC))

DEFINE MSDIALOG oDlgDoc FROM 005,005 TO 017,050 TITLE "QDOSOBR - " + STR0030 //"Sobrescrever Documento"
                                             	
@ 002,005 GROUP oGroup TO 075,175 LABEL STR0031  OF oDlgDoc PIXEL //"Divergencia"

@ 010,010 SAY STR0032 + cBreak + STR0033 + cBreak + STR0034 + cBreak + STR0035 + cBreak + STR0050 + cBreak + STR0053 + cBreak + STR0052 SIZE 180,200 OF oGroup PIXEL //"Ja existe este documento na pasta temporarios."###"Clique em: "###"Detalhes - Compara os dois documentos (Servidor e Temporários)."###"Sim - Considera o arquivo do Servidor e exclui o do Temporários."+ cBreak +"Não - Considera o arquivo do Temporários e substitui o do Servidor."###"Cancela - Preserva os arquivos para analise."###"Em caso de duvida, contate o administrador."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe detalhes dos documentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON oBtDet FROM 077,52   TYPE 15 ACTION (QDCompDoc(aTemp,aDoc), oDocControl:logMsgNaDocsDoServidor("QDOSOBR", STR0032 + cBreak + STR0033 + cBreak + STR0034 + cBreak + STR0035 + cBreak + STR0050 + cBreak + STR0053 + cBreak + STR0052, "aTemp: " + ArrTokStr(aTemp) + " - aDoc: " + ArrTokStr(aDoc), "Detalhes", AllTrim(QDH->QDH_NOMDOC))) ENABLE OF oDlgDoc
oBtDet:cToolTip := STR0036 //"Propriedades dos documentos"
IIf(SetMDIChild(),oBtDet:cCaption:= OemToAnsi(STR0037),) // "Detalhes" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não executar acão alguma     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON oBtCan FROM 077,82   TYPE 2 ACTION (nRet := 2, lFecha := .T., lNoDelTmp   := .T., , oDocControl:logMsgNaDocsDoServidor("QDOSOBR", STR0032 + cBreak + STR0033 + cBreak + STR0034 + cBreak + STR0035 + cBreak + STR0050 + cBreak + STR0053 + cBreak + STR0052, "aTemp: " + ArrTokStr(aTemp) + " - aDoc: " + ArrTokStr(aDoc), "Cancelar", AllTrim(QDH->QDH_NOMDOC)), oDlgDoc:End()) ENABLE OF oDlgDoc
oBtCan:cToolTip := "Não executar ação alguma" //"Não executar ação alguma"
IIf(SetMDIChild(),oBtCan:cCaption := OemToAnsi("Cancelar"),) // "Cancelar"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indica que o usuario deseja   ³
//³sobrescrever o documentos que ³
//³esta na pasta temporaria, pelo³
//³documento do servidor         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON oBtYes FROM 077,112   TYPE 1 ACTION (nRet := 0, lFecha := .T., lNoDelTmp   := .F., , oDocControl:logMsgNaDocsDoServidor("QDOSOBR", STR0032 + cBreak + STR0033 + cBreak + STR0034 + cBreak + STR0035 + cBreak + STR0050 + cBreak + STR0053 + cBreak + STR0052, "aTemp: " + ArrTokStr(aTemp) + " - aDoc: " + ArrTokStr(aDoc), "Sim", AllTrim(QDH->QDH_NOMDOC)), oDlgDoc:End()) ENABLE OF oDlgDoc
oBtYes:cToolTip := "Substitui o arquivo do Temporário" //"Substitui o arquivo do Temporário"
IIf(SetMDIChild(),oBtYes:cCaption:= OemToAnsi(STR0038),) // "Sim" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indica que o usuario nao deseja³
//³sobrescrever o documentos que  ³
//³esta na pasta temporaria, pelo ³
//³documento do servidor, e sim   ³
//|copia-lo para o servidor       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON oBtNo  FROM 077,142 TYPE 3 ACTION (nRet := 1, lFecha := .T., lNoDelTmp   := .F., , oDocControl:logMsgNaDocsDoServidor("QDOSOBR", STR0032 + cBreak + STR0033 + cBreak + STR0034 + cBreak + STR0035 + cBreak + STR0050 + cBreak + STR0053 + cBreak + STR0052, "aTemp: " + ArrTokStr(aTemp) + " - aDoc: " + ArrTokStr(aDoc), "Não", AllTrim(QDH->QDH_NOMDOC)), oDlgDoc:End()) ENABLE OF oDlgDoc
oBtNo:cToolTip := "Substitui o arquivo do Server" //"Substitui o arquivo do Server"
IIf(SetMDIChild(),oBtNo:cCaption:= OemToAnsi(STR0039),) // "Nao" 

ACTIVATE MSDIALOG oDlgDoc CENTERED VALID lFecha

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDCompDoc ºAutor  ³Rafael S. Bernardi  º Data ³  10/05/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que mostra para o usuario uma comparacao entre os    º±±
±±º          ³documentos que estao no servidor e na pasta temporaria      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOXDOC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDCompDoc(aTemp,aDocs)
Local oDlgDoc
Local oBtClose
Local oBtVTemp
Local oGroupT
Local oGroupS
Local cTexto    := Alltrim( M->QDH_NOMDOC )
Local cQPathTrm := QDOPATH()[3]
Local cQArqTmp  := ""
Local cSvFilAnt := cFilAnt

If  cFilAnt <> M->QDH_FILIAL  .AND. !Empty(AllTrim(xFilial("QDH")))
	cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV
	
	cQPathTrm := QDOPATH()[3]
	
	cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
EndIf                                                                       

cQArqTmp  := Left(cQPathTrm+cTexto,Len(cQPathTrm+cTexto)-4)+"_TMP.CEL"

DEFINE MSDIALOG oDlgTS FROM 005,005 TO 018,050 TITLE STR0040 //"Detalhes dos Documentos"

@ 005,005 GROUP oGroupT TO 080,090 LABEL STR0041  OF oDlgTS PIXEL //"Pasta Temporaria"

@ 005,090 GROUP oGroupS TO 080,175 LABEL STR0042 OF oDlgTS PIXEL //"Servidor"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do documentos que esta na pasta temporaria³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 020,007 SAY STR0043 + aTemp[1][1]               SIZE 080,010 OF oGroupT PIXEL //"Nome: "
@ 030,007 SAY STR0044 + AllTrim(STR(aTemp[1][2])) SIZE 080,020 OF oGroupT PIXEL //"Tamanho: "
@ 040,007 SAY STR0045 + DtoC(aTemp[1][3])         SIZE 080,030 OF oGroupT PIXEL //"Data: "
@ 050,007 SAY STR0046 + aTemp[1][4]               SIZE 080,040 OF oGroupT PIXEL //"Hora: "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe os dados do documento que esta na pasta temporaria ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON oBtVTemp  FROM 060,032 TYPE 15 ACTION (QDVisTmp("T")) ENABLE OF oGroupT
oBtVTemp:cToolTip := STR0047 //"Visualizar"
oBtVTemp:cCaption:= OemToAnsi(STR0047) // "Visualizar" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do documentos que esta na pasta do server ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 020,092 SAY STR0043 + aDocs[1][1]               SIZE 080,010 OF oGroupS PIXEL //"Nome: "
@ 030,092 SAY STR0044 + AllTrim(STR(aDocs[1][2])) SIZE 080,020 OF oGroupS PIXEL //"Tamanho: "
@ 040,092 SAY STR0045 + DtoC(aDocs[1][3])         SIZE 080,030 OF oGroupS PIXEL //"Data: "
@ 050,092 SAY STR0046 + aDocs[1][4]               SIZE 080,040 OF oGroupS PIXEL //"Hora: "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe os dados do documento que esta na pasta do server ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON oBtVDoc  FROM 060,117 TYPE 15 ACTION ( Iif( AllTrim(aDocs[1][1]) == "Nao Existe", MsgAlert("Nao Localizado"), QDVisTmp("S") ) ) ENABLE OF oGroupS
oBtVDoc:cToolTip := STR0047 //"Visualizar"
oBtVDoc:cCaption:= OemToAnsi(STR0047) // "Visualizar" 

DEFINE SBUTTON oBtClose  FROM 082,142 TYPE 2 ACTION (oDlgTS:End()) ENABLE OF oDlgTS
oBtClose:cToolTip := STR0048 //"Fechar"
oBtClose:cCaption:= OemToAnsi(STR0048) // "Fechar" 

ACTIVATE MSDIALOG oDlgTS CENTERED

If ValType(oWord) <> "U"
	If !Empty(oWord) .And. oWord <> "-1"
		OLE_CloseFile( oWord )
		OLE_CloseLink( oWord )
	EndIf
Endif

If File(cQArqTmp)
	fErase(cQArqTmp)
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDVisTmp  ºAutor  ³Rafael S. Bernardi  º Data ³  14/05/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que gera uma visualizacao temporaria dos arquivos    º±±
±±º          ³que estao na pasta do servidor e na temporaria para orientarº±±
±±º          ³o usuario se deve sobrescrever o arquivo ou nao             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOXDOC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDVisTmp(cDoc)
Local aQPath    := QDOPATH()
Local cMvSave   := QDOPswOLE() // "Verifica se insere senha ou nao
Local cQArqTmp  := ""
Local cQPath    := aQPath[1] // Diretorio que contem os .CEL
Local cQPathTrm := aQPath[3] // Diretorio dos docs temporarios
Local cSvFilAnt := cFilAnt
Local cTexto    := Alltrim( M->QDH_NOMDOC )

If  cFilAnt <> M->QDH_FILIAL  .AND. !Empty(AllTrim(xFilial("QDH")))
	cFilAnt		 := M->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV
	
	aQPath    := QDOPATH()
	cQPath    := aQPath[1]   // Diretorio que contem os .CEL
	cQPathTrm := aQPath[3]   // Diretorio dos docs temporarios
	
	cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
EndIf                                                                       

cQArqTmp := Left(cQPathTrm+cTexto,Len(cQPathTrm+cTexto)-4)+"_TMP.CEL"

If ValType(oWord) <> "U"
	If !Empty(oWord) .And. oWord <> "-1"
		OLE_CloseFile( oWord )
		OLE_CloseLink( oWord )
	EndIf
Endif

oWord := OLE_CreateLink( cEditor )

OLE_SetProperty( oWord, oleWdVisible,   .F. )
OLE_SetProperty( oWord, oleWdPrintBack, .T. )
OLE_SetProperty( oWord, oleWdLeft,   000 )
OLE_SetProperty( oWord, oleWdTop,    090 )
OLE_SetProperty( oWord, oleWdWidth,  480 )
OLE_SetProperty( oWord, oleWdHeight, 250 )
OLE_SetProperty( oWord, oleWdPrintBack, .f. )

If cDoc == "T" //Caso seja visualizar doc do temp
	If File(cQArqTmp)
		FErase(cQArqTmp)
	EndIf
	__CopyFile(cQPathTrm+cTexto,cQArqTmp)
	If File(cQArqTmp)
		OLE_OpenFile( oWord, cQArqTmp, .T., cMvSave, cMvSave )
		OLE_SetProperty( oWord, oleWdVisible,   .T. )
	EndIf
ElseIf cDoc == "S" //Caso seja visualizar doc do server
	
	If !QDOViewOLE(M->QDH_NOMDOC, M->QDH_DOCTO, M->QDH_RV)
		If File(cQArqTmp)
			FErase(cQArqTmp)
		EndIf
		__CopyFile(cQPath+cTexto,cQArqTmp)
		If File(cQArqTmp)
			OLE_OpenFile( oWord, cQArqTmp, .T., cMvSave, cMvSave )
			OLE_SetProperty( oWord, oleWdVisible,   .T. )
		EndIf
	EndIf

EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDTotOffViewºAutor  ³Cicero Cruz         º Data ³  04/29/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Abre o arquivo de forma segura impedindo cópias e impressões º±±
±±º          ³ não autorizadas (TOTVS Office Viewer)                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Abertura do Arquivo de forma segura                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QDTotOffView( cFile )
	Local oDocControl := Nil
	Local lSucesso    := .F.
	IF FindClass(Upper("QDODocumentControl"))
		oDocControl := QDODocumentControl():New() 
		lSucesso := oDocControl:abreDocumentoDoServidorNoSmartClientSemImpressaoEValidacaoUsuario(cFile)
	EndIf		
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDX_EMBNOM  ºAutor  ³Cicero Cruz         º Data ³  29/04/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Aplica algoritimo de embaralhamento tornando irreconhecivel o º±±
±±º          ³ nome do arquivo do do sistema.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Abertura do Arquivo de forma segura                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QDX_EMBNOM(cNome)
Local cAux := UPPER(cNome)
Local aProib := {"|","\","/",";",":",".","<",">",","," "}
Local nX := 0

For nX:=1 to Len(aProib)
	While At(aProib[nX],cAux) > 0
	   nPos := At(aProib[nX],cAux)
	   cAux := Substr(cAux,1,nPos-1)+Substr(cAux,nPos+1,Iif(nPos<LEN(cAux),LEN(cAux)-nPos,nPos))
	EndDo
Next

Return cAux

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDX_CPYT2SºAutor  ³Cicero Cruz         º Data ³  07/04/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Copia o arquivo do terminal para o server e mostra ao usuario º±±
±±º          ³ as caracteristicas dos fontes caso esteja parametrizado.      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QDX_CPYT2S(cArquivo, cServerPath, cNomDoc)

	Local aDocs       := DIRECTORY(cServerPath+cNomDoc)
	Local aTemp       := DIRECTORY(cArquivo)
	Local cMensagem   := ""
	Local lExist700   := ExistBlock( "QDOM700" )
	Local lVerifica   := GETMV("MV_QCFCT2S",.T.,"1") == "2" // Confirma se a copia  foi bem sucedida, 1 - Padrao nao Exibe dados
	Local nOpcao      := 0
	Local oDocControl := QDODocumentControl():New()

	Private cEditor    := "TMsOleWord97" //Space( 12 )
	Private cEdit      := Alltrim( GetMV( "MV_QDTIPED" ) ) 

	If lExist700
		ExecBlock( "QDOM700", .f., .f., { cEdit, cEditor } )
		
		If Empty( cEditor )
			Help( " ", 1, "QD_NEXTEDT" )
	 		Return .f.
		EndIf
	EndIf

	If oDocControl:arquivoLiberado(cArquivo)

		oDocControl:copiaProtegidaArquivo(cArquivo, cServerPath+cNomDoc)
	
	Else
		
		//STR0066 - "O arquivo abaixo ainda está aberto na sua estação."
		//STR0067 - "Deseja continuar assim mesmo?"
		//STR0068 - "- Tentar novamente: repete a operação (indicado após liberação pelo usuário)."
		//STR0069 - "- Ignorar: pode causar problema de versionamento local x servidor."
		//STR0070 - "- Cancelar: interrompe o processo de manutenção da etapa atual."

		cMensagem := STR0066 + ENTER
        cMensagem += AllTrim(cArquivo) + ENTER + ENTER
        cMensagem += STR0067 + ENTER
        cMensagem += STR0068 + ENTER
        cMensagem += STR0069 + ENTER
        cMensagem += STR0070 + ENTER

		//STR0071 - "Lock"
		//STR0072 - "Ignorar"
		//STR0073 - "Tentar novamente"
		//STR0074 - "Cancelar"
		oDocControl:logMsgNaDocsDoServidor("QDODOCABFIM", cMensagem, STR0071 + ": " + cArquivo, "Aviso", cArquivo)

		
		//STR0075 - "Falha na operação, o arquivo ainda está aberto."
		nOpcao := Aviso( "QDODOCABFIM", cMensagem, { STR0072, STR0073, STR0074 }, 3,  STR0075,,'', .F., 0 )

		oDocControl:logMsgNaDocsDoServidor("QDODOCABFIM", cMensagem, STR0071 + ": " + cArquivo, "nOpcao=" + AllTrim(Str(nOpcao)), cArquivo)

		If nOpcao == 2 // Tentar novamente

			Return QDX_CPYT2S(cArquivo, cServerPath, cNomDoc)
			
		ElseIf nOpcao == 3 // Cancelar

			//STR0076 - "Interrupção do processo de manutenção por escolha do usuário - documento aberto."
			UserException( "QDODOCABFIM - " + STR0076 )

		EndIf

	EndIf
	
	If lVerifica
		If File(cServerPath+cNomDoc) 
			aDocs := DIRECTORY(cServerPath+cNomDoc)
		Else     
			aDocs := {{"Nao Existe",0,CtoD("  /  /  ", "DDMMYY" ),"  :  :  ","A"}}
		EndIf	
		
		While lVerifica .AND. QDX_VerDoc(aTemp,aDocs)
			CpyT2S(cArquivo,cServerPath,.T.)
			aTemp := DIRECTORY(cArquivo)
			If File(cServerPath+cNomDoc) 
				aDocs := DIRECTORY(cServerPath+cNomDoc)
			Else     
				aDocs := {{"Nao Existe",0,CtoD("  /  /  ", "DDMMYY" ),"  :  :  ","A"}}
			EndIf
		EndDo
	EndIf

Return Nil        

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDX_VerDocºAutor  ³Rafael S. Bernardi  º Data ³  10/05/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que pergunta ao usuario se ele deseja sobrescrever o º±±
±±º          ³documento que esta na pasta temporaria ou se deseja mante-loº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOXDOC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDX_VerDoc(aTemp,aDoc)
Local oDlgDoc
Local oBtYes
Local oBtNo
Local oBtDet
Local oGroup
Local cBreak := chr(13)+chr(10)
Local lRet   := .F.

DEFINE MSDIALOG oDlgDoc FROM 005,005 TO 016,050 TITLE "Verique a eficacia da Copia" //"Sobrescrever Documento"
                                             	
@ 005,005 GROUP oGroup TO 060,175 LABEL "Dados"  OF oDlgDoc PIXEL //"Divergencia"
																																																	
@ 010,010 SAY "Verifique se o Documento foi realmente copiado." + cBreak + "Devido a algumas caracteristicas do ambiente é " + cBreak + "necesario fazer esta verificação. Clique em " + cBreak + "Detalhes para verificar se o Documento esta OK." SIZE 125,200 OF oGroup PIXEL //"Verifique se o Documento foi realmente copiado."###"Devido a algumas caracteristicas do ambiente  "###"é necesario fazer esta verificação. Clique em Detalhes"###"para verificar se o Documento no server esta OK."
                                                                                                                                                                                                                                                                          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe detalhes dos documentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*DEFINE SBUTTON oBtDet FROM 065,82   TYPE 5 ACTION (QDCompDoc(aTemp,aDoc)) ENABLE OF oDlgDoc
oBtDet:cToolTip := STR0036 //"Propriedades dos documentos"
oBtDet:cCaption:= OemToAnsi(STR0037) // "Detalhes" */
@ 065,082 BUTTON oBtDet PROMPT OemToAnsi("Detalhes") ;
		  ACTION (QDCompDoc(aTemp,aDoc)) ;
		  SIZE 025,012 OF oDlgDoc PIXEL  
oBtDet:cToolTip := "Propriedades dos documentos" //"Propriedades dos documentos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indica que o usuario deseja   ³
//³sobrescrever o documentos que ³
//³esta na pasta temporaria, pelo³
//³documento do servidor         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       

@ 065,112 BUTTON oBtYes PROMPT OemToAnsi("Copiar") ;
			  ACTION (lRet := .T.,oDlgDoc:End()) ;
			  SIZE 025,012 OF oDlgDoc PIXEL 
oBtYes:cToolTip := "Tentar Novamente a Cópia" //"Tentar Novamente a Cópia"
			   
/*DEFINE BUTTON oBtYes RESOURCE "AUTOM" FROM 065,112 OF oDlgDoc;
       ACTION (lRet := .T.,oDlgDoc:End()) */
//       TOOLTIP  OemToAnsi("Tentar Novamente a Cópia") // "Tentar Novamente a Cópia"
//oBtYes:cCaption:= OemToAnsi("Copiar") // "Copiar"
//DEFINE SBUTTON oBtYes FROM 065,112   TYPE 1 ACTION (lRet := .T.,oDlgDoc:End()) ENABLE OF oDlgDoc
//oBtYes:cToolTip := "Tentar Novamente a Cópia" //"Tentar Novamente a Cópia"
//oBtYes:cCaption:= OemToAnsi("Copiar") // "Copiar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indica que o usuario nao deseja³
//³sobrescrever o documentos que  ³                                              
//³esta na pasta temporaria, pelo ³
//³documento do servidor          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/* DEFINE SBUTTON oBtNo  FROM 065,142 TYPE 2 ACTION (lRet := .F.,oDlgDoc:End()) ENABLE OF oDlgDoc
oBtNo:cCaption:= OemToAnsi("Doc OK") // "Sair" */ 

@ 065,142 BUTTON oBtNo PROMPT OemToAnsi("Doc OK") ;
		  ACTION (lRet := .F.,oDlgDoc:End()) ;
		  SIZE 025,012 OF oDlgDoc PIXEL 
oBtNo:cToolTip := "Documento copiado corretamente." //"Documento copiado corretamente."
			  
ACTIVATE MSDIALOG oDlgDoc CENTERED 

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QDoDocQa2 ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 14/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Transfere os dados do arquivo Qa2 para variaveis na memoria ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QdoDocQa2(cFilla)

	Local aAreaQAA  := QAA->(GetArea())
	Local aAreaQD1  := QD1->(GetArea())
	Local aQD0IMP   := {}
	Local aResp     := {}
	Local aTxt      := {}
	Local cAut01    := ""
	Local cAut02    := ""
	Local cChave1   := ""
	Local cChaveQD1 := ""
	Local cQuery    := ""
	Local cReApel   := ""
	Local cReNome   := ""
	Local ic        := 0
	Local nC        := 0
	Local Ni        := 0
	Local nLocTxt   := 0
	Local nPos1     := 0
	Local nPos2     := 0
	Local nPos3     := 0
	Local nPos4     := 0
	Local nRegAnt   := 0

	If Type("aTxtResul") != "U"
		aTxt:=AClone(aTxtResul)
	Endif	

	If Type("aQD0Doc") != "U"
		aQD0IMP:=AClone(aQD0Doc)
	Endif	

	cObjetivo := ""		   
	cSumario  := ""
	cMotRevi  := ""
	cRevalid  := ""

	DbSelectArea( "QA2" )
	dbSetOrder(1)    

	For nC := 1 to 4 
		If nC == 1	
			nLocTxt:=ASCAN(aTxt,{|X| Alltrim(x[1])=="OBJ" .AND. X[2]==cChave})
			If nLocTxt!=0 					
				cObjetivo +=STRTRAN(aTxt[nLocTxt,3,1,2],CHR(13)+CHR(10),CHR(11))	//TROCA DE CHR            
			Else        
				cObjetivo += QA_Rectxt(cChave,"OBJ     ",,,,,.T.)		
			Endif	
		ElseIf nC == 2       
			nLocTxt:=ASCAN(aTxt,{|X| Alltrim(x[1])=="SUM" .AND. X[2]==cChave})
			If nLocTxt!=0            
				cSumario += STRTRAN(aTxt[nLocTxt,3,1,2],CHR(13)+CHR(10),CHR(11))	//TROCA DE CHR                       
			Else
				cSumario += QA_Rectxt(cChave,"SUM     ",,,,,.T.)
			Endif	
		Elseif nC == 3
			nLocTxt:=ASCAN(aTxt,{|X| Alltrim(x[1])=="REV" .AND. X[2]==cChave})
			If nLocTxt!=0            
				cMotRevi += STRTRAN(aTxt[nLocTxt,3,1,2],CHR(13)+CHR(10),CHR(11))	//TROCA DE CHR            	            
			Else
				cMotRevi += QA_Rectxt(cChave,"REV     ",,,,,.T.)       
			Endif	
		Elseif nC == 4
			nLocTxt:=ASCAN(aTxt,{|X| Alltrim(x[1])=="RED" .AND. X[2]==cChave})
			If nLocTxt!=0            
				cRevalid += STRTRAN(aTxt[nLocTxt,3,1,2],CHR(13)+CHR(10),CHR(11))	//TROCA DE CHR            	            
			Else
				cRevalid += QA_Rectxt(cChave,"RED     ",,,,,.T.)       
			Endif	
		EndIf
	Next
	cObjetivo += " "		   
	cSumario  += " "
	cMotRevi  += " "             
	cRevalid  += " "
	QDH->( DbSetOrder( 1 ) )


	DbSelectArea( "SM0" )
	nRegAnt := Recno()
	If DbSeek( cEmpAnt + cFilAnt )
	cNomFilial := SM0->M0_NOMECOM
	EndIf
	DbGoTo( nRegAnt )


	cApElabo := ""
	cApRevis := ""
	cApAprov := ""
	cApHomol := ""
	cElabora := ""
	cRevisor := ""
	cAprovad := ""
	cHomolog := ""

	// ****** Preenchimento Responáveis Atuais - INICIO ****** 
	// ****** Preenchimento Responáveis Atuais - INICIO ****** 
	IF Len(aQD0Imp)>0 
		IF !Empty(aQD0IMP[1,1])
			nPos1 := GdFieldPos("QD0_AUT"   ,aHedDoc[1])
			nPos2 := GdFieldPos("QD0_FLAG"  ,aHedDoc[1])
			nPos3 := GdFieldPos("QD0_FILMAT",aHedDoc[1])
			nPos4 := GdFieldPos("QD0_MAT"   ,aHedDoc[1])
			nPos5 := GdFieldPos("QD0_DEPTO" ,aHedDoc[1])
		
			For ic := 1 TO Len(aQD0IMP)
				If !aQD0IMP[ic,Len(aQD0IMP[ic])]
					
					QDOXDocAuxClass():atribuiNomeVariaveisDoStatus(@cAut01, @cAut02, aQD0IMP[ic,nPos1])
					
					cChaveQD1 := xFilial("QD1") + M->(QDH_DOCTO+QDH_RV) + aQD0IMP[ic,nPos5] + aQD0IMP[ic,nPos3] + aQD0IMP[ic,nPos4] + aQD0IMP[ic,nPos1]

					QD1->(DbSetOrder(7)) //QD1_FILIAL + QD1_DOCTO + QD1_RV + QD1_DEPTO + QD1_FILMAT + QD1_MAT + QD1_TPPEND + QD1_PENDEN
					If QD1->(DbSeek( cChaveQD1 ))
						While !QD1->(Eof()) .AND. AllTrim(QD1->(QD1_FILIAL + QD1_DOCTO + QD1_RV + QD1_DEPTO + QD1_FILMAT + QD1_MAT + QD1_TPPEND)) == AllTrim(cChaveQD1)

							If Empty(QD1->QD1_DTBAIX)
								cReApel	:= AllTrim( QA_NUSR( aQD0IMP[ic,nPos3],aQD0IMP[ic,nPos4], .T., "A" ))
								cReNome	:= AllTrim( QA_NUSR( aQD0IMP[ic,nPos3],aQD0IMP[ic,nPos4], .T.))
								QDOXDocAuxClass():adicionaResponsavelNoArrayDeControle(cAut01, cAut02, cReApel, cReNome, @aResp)
							EndIf

							QD1->(DbSkip())		
						EndDo
					Else
						cReApel	:= AllTrim( QA_NUSR( aQD0IMP[ic,nPos3],aQD0IMP[ic,nPos4], .T., "A" ))
						cReNome	:= AllTrim( QA_NUSR( aQD0IMP[ic,nPos3],aQD0IMP[ic,nPos4], .T.))
						QDOXDocAuxClass():adicionaResponsavelNoArrayDeControle(cAut01, cAut02, cReApel, cReNome, @aResp)
					EndIf
				Endif
			Next
		Endif
	Else 

		cQuery := " SELECT QAA.QAA_NOME, QAA.QAA_APELID, QD0.QD0_AUT, "
		cQuery += " COALESCE(QD1.QD1_MATBX,' ') MATBX, COALESCE(QD1.QD1_DTBAIX,' ') DTBAIX  "
		cQuery += " FROM "+RetSqlName("QAA")+" QAA, "+ RetSqlName("QD0")+" QD0 " 
		cQuery += " LEFT JOIN "+ RetSqlName("QD1") +" QD1 "
		cQuery += 			" ON QD0.QD0_FILIAL = QD1.QD1_FILIAL "
		cQuery += 			" AND QD0.QD0_DOCTO = QD1.QD1_DOCTO "
		cQuery += 			" AND QD0.QD0_RV = QD1.QD1_RV "
		cQuery += 			" AND QD0.QD0_FILMAT = QD1.QD1_FILMAT "
		cQuery += 			" AND QD0.QD0_MAT = QD1.QD1_MAT "
		cQuery += 			" AND QD0.QD0_AUT = QD1.QD1_TPPEND "
		cQuery += " WHERE QD0.QD0_FILIAL = '"+M->QDH_FILIAL+"'"
		cQuery += 		" AND QD0.QD0_DOCTO = '"+M->QDH_DOCTO+"'"
		cQuery += 		" AND QD0.QD0_RV = '"+M->QDH_RV+"'"		
		cQuery += 		" AND QD0.QD0_FLAG <> 'I' "
		cQuery += 		" AND QAA.QAA_FILIAL = QD0.QD0_FILMAT "
		cQuery += 		" AND QAA.QAA_MAT = QD0.QD0_MAT "
		cQuery += 		" AND QD0.D_E_L_E_T_ = ' ' AND QAA.D_E_L_E_T_ = ' ' AND QD1.D_E_L_E_T_ = ' ' "
				
		cQuery := ChangeQuery(cQuery)
					
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD0TRB",.T.,.T.)
					
		QD0TRB->(DBGotop())  
		While QD0TRB->(!EOF())
			
			QDOXDocAuxClass():atribuiNomeVariaveisDoStatus(@cAut01, @cAut02, QD0TRB->QD0_AUT)

			If Empty(QD0TRB->DTBAIX) 
				cReApel	:= AllTrim( QD0TRB->QAA_APELID )
				cReNome	:= AllTrim( QD0TRB->QAA_NOME )
				QDOXDocAuxClass():adicionaResponsavelNoArrayDeControle(cAut01, cAut02, cReApel, cReNome, @aResp)
			EndIf
				
			QD0TRB->(DbSkip())
		EndDo                      
		QD0TRB->(DbCloseArea())
		DbSelectArea( "QD0" )
				
	Endif
	RestArea(aAreaQAA)
	RestArea(aAreaQD1)
	// ****** Preenchimento Responáveis Atuais - FIM    ****** 
	// ****** Preenchimento Responáveis Atuais - FIM    ****** 

	QDOXDocAuxClass():preencheResponsaveisBaixasHistoricas(M->QDH_FILIAL, M->QDH_DOCTO, M->QDH_RV, AllTrim(M->QDH_STATUS), @aResp)

	//Preenche variáveis Private cApElabo à cHomolog - INICIO
	For Ni:=1 To Len(aResp)
		If !Empty(aResp[Ni,1])
			If !Empty( &( aResp[Ni,1] ) )
				&( aResp[Ni,1] ) += ", "
			Endif
			&( aResp[Ni,1] ) += aResp[Ni,2]
		EndIf
	Next
	cApElabo += " "
	cApRevis += " "
	cApAprov += " "
	cApHomol += " "
	cElabora += " "
	cRevisor += " "
	cAprovad += " "
	cHomolog += " "
	//Preenche variáveis Private cApElabo à cHomolog - FIM

	DbSelectArea("SX2")
	DbSetorder(1)
	If DbSeek("QDO")
		DbSelectArea("SX3")
		DbSetorder(1)
		If DbSeek("QDO")
			DbSelectArea("QDO")
			DbSetOrder( 3 )
			cCodAtu	:= ""
			cCodNov	:= ""
			cDescr	:= ""
			cDe		:= ""
			cPara	:= ""
			cChave 	:= M->QDH_DOCTO
			QDO->(DbGotop())
			If DbSeek( xFilial( "QDO" ) + cChave )
				While !( QDO->( Eof() ) ) .and. xFilial( "QDO" )+Alltrim( cChave ) == QDO->QDO_FILIAL+ Alltrim(QDO->QDO_DOCTO)
						cCodAtu	+= QDO->QDO_CODIGO	+ Chr( 11 )
						cCodNov	+= QDO->QDO_NOVCOD	+ Chr( 11 )
						cDescr	+= QDO->QDO_DESCR	+ Chr( 11 )
						cDe		+= QDO->QDO_DE		+ Chr( 11 )
						cPara	+= QDO->QDO_PARA	+ Chr( 11 )
						cChave1	:= QDO->QDO_CHAVE
						DbSkip()
				EndDo
				DbSelectArea("QA2")
				If !Empty( cChave1 ) 
					cMdpRaz		:= ""
					cMdpObs		:= ""
					cMdsRaz		:= ""
					cMdsObs		:= ""
					For nC := 1 to 4
						If nC == 1
							cMdpRaz +=	QA_Rectxt(cChave1,"MDPRAZ  ",,,,,.T.)
						ElseIf nC == 2
							cMdpObs +=	QA_Rectxt(cChave1,"MDPOBS  ",,,,,.T.)
						Elseif nC == 3
							cMdsRaz +=	QA_Rectxt(cChave1,"MDSRAZ  ",,,,,.T.)
						Elseif nC == 4
							cMdsObs +=	QA_Rectxt(cChave1,"MDSOBS  ",,,,,.T.)
						EndIf
					Next
				Endif
			Endif
			cCodAtu	+= " "
			cCodNov	+= " "
			cDescr	+= " "
			cDe		+= " "
			cPara	+= " "
			cMdpRaz	+= " "
			cMdpObs	+= " "
			cMdsRaz	+= " "
			cMdsObs	+= " "
		Endif
	Endif

Return

/*/{Protheus.doc} QDOTimeOut
//TODO Remove timeout, caso exista.
@author brunno.costa
@since 04/04/2018
@version 6
@return ${return}, ${return_description}
@param lRetorna, logical 
		.T.: retorna para timeout anterior
		.F.: primeira execução removento o TimeOut
		lReadOnly, logical
@type function
/*/

Static Function QDOTimeOut(lRetorna, lReadOnly)

Static nTimeOutSt

If !lReadOnly .AND. !SuperGetMV("MV_QDOTOWO",.F.,.T.)
	If !lRetorna 				//Remove TimeOut
		If FindFunction("GetSrvProfString")
			nTimeOutSt := Val(GetSrvProfString("InactiveTimeOut", "-1"))
			If nTimeOutSt < 0
				nTimeOutSt := Nil
			EndIf
		EndIf
		PtInternal(2,  Str(0))	//Remove o TimeOut
	Else						//Retorna TimeOut Padrão
		If ValType(nTimeOutSt) == "N"
			PtInternal(2,  Str(nTimeOutSt))
		EndIf
	EndIf
EndIf

Return

/*/{Protheus.doc} QDOVar710
Função que incorpotou as variaveis antes utilizadas no programa QDOM710.
Caso o fonte esteja compilado continua usando os fontes por questão que compatibilidade do legado.
@type  Function
@author filipe.olegini
@since 31/05/2019
@version 12
/*/
Function QDOVar710()

	OLE_SetDocumentVar( oWord, "Adv_NomeFilial"		, cNomFilial )                                            	//01 - Filial do Sistema
	OLE_SetDocumentVar( oWord, "Adv_CopiaControlada", cTpCopia )                                              	//02 - Copia Controlada
	OLE_SetDocumentVar( oWord, "Adv_Cancel"			, If( M->QDH_CANCEL == 'S','Documento Cancelado',' ' ) ) //03 - Cancelado
	OLE_SetDocumentVar( oWord, "Adv_Obsoleto"		, If( M->QDH_OBSOL  == 'S','Documento Obsoleto' ,' ' ) )	//04 - Obsoleto
	OLE_SetDocumentVar( oWord, "Adv_DTpDoc"			, QDXFNANTPD( M->QDH_CODTP, .t. ) )                     	//05 - Tipo
	OLE_SetDocumentVar( oWord, "Adv_DataVigencia"	, if(Valtype(M->QDH_DTVIG) == 'D',DtoC( M->QDH_DTVIG ),' ')) //06 - Data de Vigencia
	OLE_SetDocumentVar( oWord, "Adv_Titulo"			, M->QDH_TITULO )                                  	     	//07 - Titulo
	OLE_SetDocumentVar( oWord, "Adv_Objetivo"		, cObjetivo )                        								//08 - Objetivo
	OLE_SetDocumentVar( oWord, "Adv_NUsrR"			, cNomRece )                                             	//09 - Destinatario
	
	If Empty( cNomRece )
	   OLE_SetDocumentVar( oWord, "Adv_NDeptoR", " " )
	Else                                                                                                        	//10 - Departamento do Destinatario ( Nome )
	   OLE_SetDocumentVar( oWord, "Adv_NDeptoR", QA_NDEPT( QDG->QDG_DEPTO,.T.,QDG->QDG_FILMAT) )     
	Endif

	OLE_SetDocumentVar( oWord, "Adv_NDeptoD"			, QA_nDeptos( M->QDH_FILIAL, M->QDH_DOCTO, M->QDH_RV ) )	//11 - Departamento Recebedores - Distribuicao ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_Sumario"			, cSumario )                                            	//12 - Sumario
	OLE_SetDocumentVar( oWord, "Adv_MotivoRevisao"		, cMotRevi )                                             	//13 - Motivo da Revisao
	OLE_SetDocumentVar( oWord, "Adv_ApelidoElaborador"	, cApElabo )                                             	//14 - Elaboradores( Apelido )
	OLE_SetDocumentVar( oWord, "Adv_ApelidoRevisor"		, cApRevis )                                             	//15 - Revisores( Apelido )
	OLE_SetDocumentVar( oWord, "Adv_ApelidoAprovador"	, cApAprov )                                             	//16 - Aprovadores( Apelido )
	OLE_SetDocumentVar( oWord, "Adv_ApelidoHomologador"	, cApHomol )                                             	//17 - Homologador ( Apelido )
	OLE_SetDocumentVar( oWord, "Adv_Docto"				, Alltrim( M->QDH_DOCTO ) )                              	//18 - Codigo do Documento
	OLE_SetDocumentVar( oWord, "Adv_Rv"					, M->QDH_RV )                                            	//19 - Numero da Revisao
	OLE_SetDocumentVar( oWord, "Adv_Rodape"				, cRodape )                                              	//20 - Rodape
	OLE_SetDocumentVar( oWord, "Adv_MdpCodigo"			, cCodAtu )                                             
	OLE_SetDocumentVar( oWord, "Adv_MdpNovCod"			, cCodNov )                                             
	OLE_SetDocumentVar( oWord, "Adv_MdsDescr"			, cDescr  )                                             
	OLE_SetDocumentVar( oWord, "Adv_MdpDe"				, cDe )                                             
	OLE_SetDocumentVar( oWord, "Adv_MdpPara"			, cPara )                                           
	OLE_SetDocumentVar( oWord, "Adv_MdpRaz"				, cMdpRaz )                                         
	OLE_SetDocumentVar( oWord, "Adv_MdpObs"				, cMdpObs )                                         
	OLE_SetDocumentVar( oWord, "Adv_MdsRaz"				, cMdsRaz )                                         
	OLE_SetDocumentVar( oWord, "Adv_MdsObs"				, cMdsObs ) 
	OLE_SetDocumentVar( oWord, "Adv_ApelidoDestino"		, QA_nUsr( cFilApDes, cCodApDes, .t., "A" ) )            //20 - Destinatario ( Apelido ) 
	OLE_SetDocumentVar( oWord, "Adv_ApelidoSolicitante"	, QA_nUsr( cFilApSol, cCodApSol, .t., "A" ) )            //21 - Solicitante ( Apelido ) *** Quando de uma solicitacao de alteracao ***
	OLE_SetDocumentVar( oWord, "Adv_Elaborador"			, cElabora )                                             //22 - Elaborador ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_Revisor"			, cRevisor )                                             //23 - Revisor ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_Aprovador"			, cAprovad )                                             //24 - Aprovador ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_Homologador"		, cHomolog )                                             //25 - Homologador ( Nome ) 
	OLE_SetDocumentVar( oWord, "Adv_Ass1"				, QDXFNANASS( M->QDH_CODASS, .t. ) )                     //26 - Assunto ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_Ass2"				, QDXFNANASS( M->QDH_CODAS1, .t. ) )                     //27 - Assunto 1 ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_Ass3"				, QDXFNANASS( M->QDH_CODAS2, .t. ) )                     //28 - Assunto 2 ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_Ass4"				, QDXFNANASS( M->QDH_CODAS3, .t. ) )                     //29 - Assunto 3 ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_Ass5"				, QDXFNANASS( M->QDH_CODAS4, .t. ) )                     //30 - Assunto 4 ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_CRespR"				, SI3->I3_MAT )                                          //34 - Responsavel pelo Centro de Custo ( Matricula )
	OLE_SetDocumentVar( oWord, "Adv_DeptoD"				, M->QDH_DEPTOD )                                        //35 - Departamento Recebedores - Distribuicao ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_DeptoE"				, M->QDH_DEPTOE )                                        //36 - Departamento Elaborador ( Codigo ) 
	OLE_SetDocumentVar( oWord, "Adv_NDeptoE"			, QA_nDept( M->QDH_DEPTOE, .t., M->QDH_FILMAT ) )        //37 - Departamento Elaborador ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_CPastaR"			, QDG->QDG_CODMAN )                                      //38 - Pasta ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_NPastaR"			, QDXFNANMAN( QDG->QDG_CODMAN, .t., QDJ->QDJ_FILMAT ) )  //39 - Pasta ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_DeptoR"				, QDG->QDG_DEPTO )                                       //40 - Departamento do Destinatario ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_NRespR"				, QA_nUsr( SI3->I3_FILMAT, SI3->I3_MAT ) )               //41 - Responsavel pelo Departamento doDestinatario ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_DataEmissao"		, DtoC( cDtEmiss ) )                                     //42 - Data de Emissao
	OLE_SetDocumentVar( oWord, "Adv_DataValidade"		, DtoC( M->QDH_DTLIM ) )                                 //43 - Data de Validade
	OLE_SetDocumentVar( oWord, "Adv_DataImplantacao"	, DtoC( M->QDH_DTIMPL ) )                                //44 - Data de Implantacao
	OLE_SetDocumentVar( oWord, "Adv_DataDistribuicao"	, DtoC( QD1->QD1_DTGERA ) )                

Return 

/*/{Protheus.doc} QDOVar720
Função que incorpotou as variaveis antes utilizadas no programa QDOM720.
Caso o fonte esteja compilado continua usando os fontes por questão que compatibilidade do legado.
@type  Function
@author filipe.olegini
@since 31/05/2019
@version 12
/*/
Function QDOVar720()

	OLE_SetDocumentVar( oWord, "Adv_CopiaControlada"	, cTpCopia )                                             	//02 - Copia Controlada
	OLE_SetDocumentVar( oWord, "Adv_Cancel"				, If( M->QDH_CANCEL == 'S','Documento Cancelado',' ' ) ) //03 - Cancelado
	OLE_SetDocumentVar( oWord, "Adv_Obsoleto"			, If( M->QDH_OBSOL  == 'S','Documento Obsoleto' ,' ' ) ) //04 - Obsoleto
	OLE_SetDocumentVar( oWord, "Adv_DataVigencia"		, DtoC( M->QDH_DTVIG ) )                                 	//05 - Data de Vigencia
	OLE_SetDocumentVar( oWord, "Adv_NUsrR"				, cNomRece )                                             	//08 - Destinatario
	
	//09 - Departamento do Destinatario ( Nome )
	If Empty( cNomRece )
	   OLE_SetDocumentVar( oWord, "Adv_NDeptoR"			, " " )
	Else 
	   OLE_SetDocumentVar( oWord, "Adv_NDeptoR"			, QA_NDEPT( cDepRece,.T.,QDG->QDG_FILMAT) )     
	Endif
	
	OLE_SetDocumentVar( oWord, "Adv_Rodape"				, cRodape )                                              	//18 - Rodape
	OLE_SetDocumentVar( oWord, "Adv_NDeptoD"			, QA_nDeptos( M->QDH_FILIAL, M->QDH_DOCTO, M->QDH_RV ) )	//10 - Departamento Recebedores - Distribuicao ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_NomeFilial"			, cNomFilial )                                           	//01 - Filial do Sistema
	OLE_SetDocumentVar( oWord, "Adv_DTpDoc"				, QDXFNANTPD( M->QDH_CODTP, .t. ) )                         //04 - Tipo
	OLE_SetDocumentVar( oWord, "Adv_Titulo"				, M->QDH_TITULO )                                        	//06 - Titulo
	OLE_SetDocumentVar( oWord, "Adv_Objetivo"			, cObjetivo )                                            	//07 - Objetivo
	OLE_SetDocumentVar( oWord, "Adv_NDeptoD"			, QA_nDeptos( M->QDH_FILIAL, M->QDH_DOCTO, M->QDH_RV ) ) 	//10 - Departamento Recebedores - Distribuicao ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_Sumario"			, cSumario )                                             	//11 - Sumario
	OLE_SetDocumentVar( oWord, "Adv_MotivoRevisao"		, cMotRevi )                                             	//12 - Motivo da Revisao
	OLE_SetDocumentVar( oWord, "Adv_ApelidoElaborador"  , cApElabo )                                             	//13 - Elaboradores( Apelido )
	OLE_SetDocumentVar( oWord, "Adv_ApelidoRevisor"		, cApRevis )                                             	//14 - Revisores( Apelido )
	OLE_SetDocumentVar( oWord, "Adv_ApelidoAprovador"	, cApAprov )                                             	//15 - Aprovadores( Apelido )
	OLE_SetDocumentVar( oWord, "Adv_Docto"				, Alltrim( M->QDH_DOCTO ) )                              	//16 - Codigo do Documento
	OLE_SetDocumentVar( oWord, "Adv_Rv"					,M->QDH_RV )                                            	//17 - Numero da Revisao
	OLE_SetDocumentVar( oWord, "Adv_ApelidoHomologador"	, cApHomol )                                             	//19 - Homologador ( Apelido )
	OLE_SetDocumentVar( oWord, "Adv_ApelidoDestino"		, QA_nUsr( cFilApDes, cCodApDes, .t., "A" ) )            	//20 - Destinatario ( Apelido ) 
	OLE_SetDocumentVar( oWord, "Adv_ApelidoSolicitante"	, QA_nUsr( cFilApSol, cCodApSol, .t., "A" ) )            	//21 - Solicitante ( Apelido ) *** Quando de uma solicitacao de alteracao ***
	OLE_SetDocumentVar( oWord, "Adv_Elaborador"			, cElabora )                                             	//22 - Elaborador ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_Revisor"			, cRevisor )                                             	//23 - Revisor ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_Aprovador"			, cAprovad )                                             	//24 - Aprovador ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_Homologador"		, cHomolog )                                             	//25 - Homologador ( Nome ) 
	OLE_SetDocumentVar( oWord, "Adv_Ass1"				, QDXFNANASS( M->QDH_CODASS, .t. ) )                        //26 - Assunto ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_Ass2"				, QDXFNANASS( M->QDH_CODAS1, .t. ) )                        //27 - Assunto 1 ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_Ass3"				, QDXFNANASS( M->QDH_CODAS2, .t. ) )                        //28 - Assunto 2 ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_Ass4"				, QDXFNANASS( M->QDH_CODAS3, .t. ) )                        //29 - Assunto 3 ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_Ass5"				, QDXFNANASS( M->QDH_CODAS4, .t. ) )                        //30 - Assunto 4 ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_CRespR"				, SI3->I3_MAT )                                          	//34 - Responsavel pelo Centro de Custo ( Matricula )
	OLE_SetDocumentVar( oWord, "Adv_DeptoD"				, M->QDH_DEPTOD )                                        	//35 - Departamento Recebedores - Distribuicao ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_DeptoE"				, M->QDH_DEPTOE )                                        	//36 - Departamento Elaborador ( Codigo ) 
	OLE_SetDocumentVar( oWord, "Adv_NDeptoE"			, QA_nDept( M->QDH_DEPTOE, .t., M->QDH_FILMAT ) )        	//37 - Departamento Elaborador ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_CPastaR"			, QDG->QDG_CODMAN )                                      	//38 - Pasta ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_NPastaR"			, QDXFNANMAN( QDG->QDG_CODMAN, .t., QDJ->QDJ_FILMAT ) )     //39 - Pasta ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_DeptoR"				, QDG->QDG_DEPTO )                                       	//40 - Departamento do Destinatario ( Codigo )
	OLE_SetDocumentVar( oWord, "Adv_NRespR"				, QA_nUsr( SI3->I3_FILMAT, SI3->I3_MAT ) )               	//41 - Responsavel pelo Departamento doDestinatario ( Nome )
	OLE_SetDocumentVar( oWord, "Adv_DataEmissao"		, DtoC( cDtEmiss ) )                                     	//42 - Data de Emissao
	OLE_SetDocumentVar( oWord, "Adv_DataValidade"		, DtoC( M->QDH_DTLIM ) )                                 	//43 - Data de Validade
	OLE_SetDocumentVar( oWord, "Adv_DataImplantacao"	, DtoC( M->QDH_DTIMPL ) )                                	//44 - Data de Implantacao
	OLE_SetDocumentVar( oWord, "Adv_DataDistribuicao"	, DtoC( QD1->QD1_DTGERA ) )                              	//45 - Data de Distribuicao

Return 

/*/{Protheus.doc} QDOPswOLE()
Retorna Senha Padrão de Proteção dos Arquivos de Integração com MS Office
@since 28/04/2022
@version P12.1.37
@return cPSW, caracter, senha padrão de configuração
Nota: IFs INLINE para facilitar cobertura
/*/
Function QDOPswOLE()
	
	Local cPSW := ""
	Local oQdoControl := QDODocumentControl():New()

	slDocControl := Iif(slDocControl == Nil, FindClass(Upper("QDODocumentControl")), slDocControl)

	cPSW := Iif(slDocControl                              ,;
                oQdoControl:retornaSenhaPadrao()          ,;
                IIf( GetMV("MV_QSAVPSW",.F.,"1") == "1" ,;
                     "CELEWIN400"                       ,;
                     ""                                  ) )

Return cPSW


/*/{Protheus.doc} QDOViewOLE()
Abre Documento do SIGAQDO no SmartClient
@since 28/04/2022
@version P12.1.37
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@param 04 - cTipo     , caracter, tipo do documento (I) interno ou (E) externo
@return lSucesso, lógico, indica se conseguiu abrir o documento do SIGAQDO no SmartClient
Nota: IFs INLINE para facilitar cobertura
/*/
Function QDOViewOLE(cArquivo, cDocumento, cRevisao, cTipo)
	Local lSucesso    := .F.
	Local oQdoControl := NIL

	Default cTipo := Iif(Empty(M->QDH_DTOIE),QDH->QDH_DTOIE,M->QDH_DTOIE)

	slDocControl      := Iif(slDocControl == Nil, FindClass(Upper("QDODocumentControl")), slDocControl)
	If slDocControl
		oQdoControl   := QDODocumentControl():New()
		If cTipo == "I"
			lSucesso  := oQdoControl:abreDocumentoDoServidorNoSmartClient(cArquivo, cDocumento, cRevisao)
		Else
			lSucesso  := oQdoControl:abreDocumentoExternoDoServidor(cArquivo, cDocumento, cRevisao)
		EndIf
	EndIf

Return lSucesso

/*/{Protheus.doc} QDOVlWorVi()
Exibe help de falha para exibição de documentos via Word Viewer quando implantada Leitura Interna
@since 05/01/2023
@version P12.1.2310
@author brunno.costa
@param nOrigem, numérico, indicação de chamada da função:
	1 - ao tentar abrir documento com wordviewer
	2 - ao tentar alterar o campo QAA_TPWORD para 2
@return lValido, lógico, indica que o formato do arquivo de modelo é inválido para visualização no Word Viewer
lValido -> .F., sempre que for um modelo de documento do Office recente
/*/
Function QDOVlWorVi(nOrigem)

	Local aArea               := GetArea()
	Local lValido             := .T.
	Local oQDODocumentControl := Nil

	Default nOrigem := 1

	IF FindClass(Upper("QDODocumentControl"))
		oQDODocumentControl := QDODocumentControl():New()
		If oQDODocumentControl:validaImplantacao(.F.)
			lValido := .F.
			If nOrigem == 1
				//STR0015 - "Atenção"
				//STR0060 - "Projeto de Leitura Interna implantado, porém seu usuário está configurado no campo 'Tipo de Exibição' (QAA_TPWORD) com '2 - Word Viewer' que é incompatível com arquivos Office recentes."
				//STR0061 - "Configure seu o usuário no campo 'Tipo de Exibição' com '4 - Leitura Interna' OU solicite uma cópia do arquivo .cel convertido para Office 2003 para usar o Word Viewer. Demonstração de passos para conversão: 1. Localize o arquivo referente QDH_NOMDOC no diretório do servidor /Rootpath/MV_QPATHW; 2. Abra o arquivo .cel manualmente no servidor via MS Office recente; 3. Utilize a opção 'Salvar como Office 2003 (.doc)'; 4. Compartilhe o arquivo com o usuário que deseja abrir."
				Help(NIL, NIL, STR0015, NIL, STR0060, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0061})
			ElseIf nOrigem == 2
				//STR0015 - "Atenção"
				//STR0062 - "A leitura de documentos com Word Viewer é incompatível em bases com a implantação da leitura interna."
				//STR0063 - "Utilize outra opção de leitura diferente de '2 = Word Viewer'."
				Help(NIL, NIL, STR0015, NIL, STR0062, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0063})
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lValido

/*/{Protheus.doc} QDOXDocAuxClass
Classe Auxiliar do fonte QDOXDOC
@author brunno.costa
@since  22/08/2023
/*/
CLASS QDOXDocAuxClass FROM LongNameClass

	Method new()

	//Métodos Internos
	Method adicionaResponsavelNoArrayDeControle(cVarApelid, cVarNome, cApelido, cNome, aResp)
	Method atribuiNomeVariaveisDoStatus(cAut01, cAut02, cEtapa)
	Method limpaMemoriaResponsaveisBaixasEtapasAnteriores(cEtapa, aResp)
	Method preencheResponsaveisBaixasHistoricas(cFilDoc, cDocumento, cRevisao, cEtapa, aResp)
	
EndClass

/*/{Protheus.doc} New
Construtor da Classe Auxiliar do QDOXDOC
@author brunno.costa
@since  22/08/2023
/*/
Method new() CLASS QDOXDocAuxClass
Return Self

/*/{Protheus.doc} preencheResponsaveisBaixasHistoricas
1) Limpa responsáveis gravados nas etapas anteriores no array aResp
2) Preenche array interno aResp com os responsáveis pelas Baixas Históricas
@author brunno.costa
@since  22/08/2023
@param 01 - cFilDoc   , caracter, filial do documento
@param 02 - cDocumento, caracter, código do documento
@param 03 - cRevisao  , caracter, revisão do documento
@param 04 - cEtapa    , caracter, código da etapa atual do documento
@param 05 - aResp     , array   , controla variáveis de memória dos responsáveis para impressão
/*/
Method preencheResponsaveisBaixasHistoricas(cFilDoc, cDocumento, cRevisao, cEtapa, aResp) CLASS QDOXDocAuxClass

	Local cAliasTMP        := Nil
	Local cAut01           := ""
	Local cAut02           := ""
	Local cQuery           := ""
	Local cReApel          := ""
	Local cReNome          := ""
	Local oQLTQueryManager := QLTQueryManager():New()

	Self:limpaMemoriaResponsaveisBaixasEtapasAnteriores(cEtapa, @aResp)

	cQuery := " SELECT DISTINCT QAA.QAA_NOME, QAA.QAA_APELID, QD1.QD1_TPPEND  "
	cQuery += " FROM "+RetSqlName("QAA")+" QAA, "+ RetSqlName("QD1") +" QD1 "
	cQuery += " WHERE QD1.QD1_FILIAL = '" + cFilDoc + "'"
	cQuery +=   " AND QD1.QD1_DOCTO  = '" + cDocumento + "'"
	cQuery +=   " AND QD1.QD1_RV     = '" + cRevisao + "'"

	cQuery +=   " AND QD1.QD1_FMATBX = QAA.QAA_FILIAL "
	cQuery +=   " AND QD1.QD1_MATBX  = QAA.QAA_MAT "

	cQuery +=   " AND QD1.QD1_DTBAIX <> ' ' "
	cQuery +=   " AND QD1.QD1_DTBAIX IS NOT NULL "
	cQuery +=   " AND RTRIM(QD1.QD1_TPPEND) IN ('E','EC','R','A','H') "

	cQuery +=   " AND QD1.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND QAA.D_E_L_E_T_ = ' ' "
	
	cQuery    := oQLTQueryManager:changeQuery(cQuery)
	cAliasTMP := oQLTQueryManager:executeQuery(cQuery)
				
	(cAliasTMP)->(DBGotop())
	While (cAliasTMP)->(!EOF())

		Self:atribuiNomeVariaveisDoStatus(@cAut01, @cAut02, AllTrim((cAliasTMP)->QD1_TPPEND))

		cReApel	:= AllTrim( (cAliasTMP)->QAA_APELID )
		cReNome	:= AllTrim( (cAliasTMP)->QAA_NOME )

		Self:adicionaResponsavelNoArrayDeControle(cAut01, cAut02, cReApel, cReNome, @aResp)
			
		(cAliasTMP)->(DbSkip())
	EndDo                      
	(cAliasTMP)->(DbCloseArea())
	DbSelectArea( "QD0" )
	
Return

/*/{Protheus.doc} atribuiNomeVariaveisDoStatus
Atribui por Referência o Nome da Variável do Status
@author brunno.costa
@since  22/08/2023
@param 01 - cAut01 , caracter, retorna por referência nome da variável de controle do apelido do usuário no status
@param 02 - cAut02 , caracter, retorna por referência nome da variável de controle do nome do usuário no status
@param 03 - cEtapa , caracter, indica a etapa para preencher as variáveis de controle
/*/
Method atribuiNomeVariaveisDoStatus(cAut01, cAut02, cEtapa) CLASS QDOXDocAuxClass

	Do Case
		Case cEtapa == "E" .OR. cEtapa == "EC"
			cAut01 := "cApElabo"
			cAut02 := "cElabora"
		Case cEtapa == "R"
			cAut01 := "cApRevis"
			cAut02 := "cRevisor"
		Case cEtapa == "A"
			cAut01 := "cApAprov"
			cAut02 := "cAprovad"
		Case cEtapa == "H"
			cAut01 := "cApHomol"
			cAut02 := "cHomolog"
	EndCase

Return

/*/{Protheus.doc} adicionaResponsavelNoArrayDeControle
Adiciona Responsável Inexistente na Etapa no Array de Controle
@author brunno.costa
@since  22/08/2023
@param 01 - cAut01 , caracter, contém nome da variável do apelido no status atual para relacionar
@param 02 - cAut02 , caracter, contém nome da variável do nome no status atual para relacionar
@param 03 - cReApel, caracter, contém apelido para relacionar no controle de memória
@param 04 - cReNome, caracter, contém nome para relacionar no controle de memória
@param 05 - aResp  , array   , controla variáveis de memória dos responsáveis para impressão
/*/
Method adicionaResponsavelNoArrayDeControle(cAut01, cAut02, cReApel, cReNome, aResp) CLASS QDOXDocAuxClass

	IF Ascan(aResp, {|x| x[1] == cAut01 .AND. x[2] == cReApel })== 0
		AAdd(aResp, {cAut01, cReApel })
	Endif

	IF Ascan(aResp, {|x| x[1] == cAut02 .AND. x[2] == cReNome })== 0
		AAdd(aResp, {cAut02, cReNome })
	Endif

Return

/*/{Protheus.doc} limpaMemoriaResponsaveisBaixasEtapasAnteriores
Limpa Variáveis de Memória  Responsáveis pela Baixas das Etapas Anteriores
@author brunno.costa
@since  22/08/2023
@param 01 - cEtapa, caracter, código da etapa atual do documento
@param 02 - aResp , array   , controla variáveis de memória dos responsáveis para impressão
/*/
Method limpaMemoriaResponsaveisBaixasEtapasAnteriores(cEtapa, aResp) CLASS QDOXDocAuxClass

	Local aRemover := {}
	Local nIndResp := 0
	Local nIndPesq := 0

	Do Case
		Case "E" $ cEtapa                                        //Elaboração ou Elaboração com Crítica - Não faz limpeza
		Case cEtapa == "R"                                       //Revisão
			aAdd(aRemover, "cApElabo")
			aAdd(aRemover, "cElabora")
		Case cEtapa == "A"                                       //Aprovação
			aAdd(aRemover, "cApElabo")
			aAdd(aRemover, "cElabora")
			aAdd(aRemover, "cApRevis")
			aAdd(aRemover, "cRevisor")
		Case cEtapa == "H"                                       //Homologação
			aAdd(aRemover, "cApElabo")
			aAdd(aRemover, "cElabora")
			aAdd(aRemover, "cApRevis")
			aAdd(aRemover, "cRevisor")
			aAdd(aRemover, "cApAprov")
			aAdd(aRemover, "cAprovad")
		Case cEtapa == "I" .OR. cEtapa == "L" //Distribuição ou Leitura
			aAdd(aRemover, "cApElabo")
			aAdd(aRemover, "cElabora")
			aAdd(aRemover, "cApRevis")
			aAdd(aRemover, "cRevisor")
			aAdd(aRemover, "cApAprov")
			aAdd(aRemover, "cAprovad")
			aAdd(aRemover, "cApHomol")
			aAdd(aRemover, "cHomolog")
	EndCase

	For nIndResp := 1 To Len(aResp)
		nIndPesq := aScan(aRemover, {|cRemover| cRemover == aResp[nIndResp, 1] })
		aResp[nIndResp, 1] := Iif(nIndPesq > 0, "", aResp[nIndResp, 1])
		aResp[nIndResp, 2] := Iif(nIndPesq > 0, "", aResp[nIndResp, 2])
	Next

Return



