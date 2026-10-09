#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAI87.CH"

Static lTMI87Con := ExistBlock("TMI87CON")

/*{Protheus.doc} TMSAI87()
Funcao de Job de retrono da integração Coleta entrega

@author     Carlos A. Gomes Jr.
@since      22/06/2022
*/
Function TMSAI87()
    FWMsgrun(,{|| TMSAI87Aux()}, STR0006, STR0007 )
Return

/*{Protheus.doc} TMSAI87Aux()
Funcao auxiliar de Loop do Coleta entrega
@author     Carlos A. Gomes Jr.
@since      19/08/2022
*/
Function TMSAI87Aux(cProcess)
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local aResult    := {}
Local cErroInt   := ""
Local aStruct    := {}
Local nPosStruc  := 0
Local aViagem    := {}
Local aViaCol    := {}
Local nViaCol    := 0
Local aDocVia    := {}
Local nDoc       := 0
Local aEvidencia := {}
Local aPEDocVia  := {}
Local cCodOco    := ""
Local cErroOco   := ""
Local aImagem    := {}
Local aDadosGrv  := {}
Local cIdMPOS    := ""
Local aNFsComp   := {}
Local nNFComp    := 0
Local aRegDados  := {}
Local aChaveCol  := {}
Local lCpentAvls := AliasInDic("DND") .And. DND->(ColumnPos("DND_CMPAVL")) > 0 // Comprovante de Entrega Avulso
Local aAlias     := {}
Local aPlanej    := {}
Local nCntFor1   := 0
Local oColEnt  As Object
Local oPortLog As Object
Local oIntegr  As Object
Local oHere    As Object
Local lDelVia    := .F.
Local lErroInteg := .F.

Local aEntrParc  := {}
Local nPosPar    := 0
Local aNotas     := {}
Local aAreas     := { DT2->(GetArea()), DTC->(GetArea()) ,GetArea() }
Local cSeekDTC   := ""
Local cTipPnd    := ""

Local cOcoInf    := ""

Default cProcess := ""

DT2->(DbSetOrder(1))
DT2->(DbGoTop())
While DT2->(!Eof())
	If DT2->DT2_SERTMS == StrZero(1,Len(DT2->DT2_SERTMS)) .And. DT2->DT2_TIPOCO == StrZero(5,Len(DT2->DT2_TIPOCO))	//-- Coleta Informativa
		cOcoInf := DT2->DT2_CODOCO
		Exit
	EndIf
	DT2->(DbSkip())
EndDo

If !Empty(cOcoInf)
	If AliasInDic("DN1")
		AAdd(aAlias,{"DN1","01"})
	EndIf
	If AliasInDic("DNM")
		AAdd(aAlias,{"DNM","HE"})
	EndIf

    If LockByName("TM87JbLoop",.T.,.T.)
		For nCntFor1 := 1 To Len(aAlias)
	        oIntegr := TMSBCACOLENT():New(aAlias[nCntFor1][1],aAlias[nCntFor1][2])
	        If oIntegr:DbGetToken()
	        	If aAlias[nCntFor1][1] == "DN1"
	        		oColEnt := oIntegr
		            DN1->(DbGoTo(oColEnt:config_recno))
		        ElseIf aAlias[nCntFor1][1] == "DNM"
		        	oHere := oIntegr
					DNM->(DbGoTo(oHere:config_recno))
				EndIf
				
	            //-- Inicializa a estrutura
	            aStruct := TMSMntStru(&(aAlias[nCntFor1][1] + "->" + aAlias[nCntFor1][1] + "_CODFON"),.T.,Iif(aAlias[nCntFor1][1] == "DNM","0002",""))
	            //-- Localiza primeiro registro da estrutura
	            For nPosStruc := 1 To Len(aStruct)
	                //-- Não é adicional de ninguém, ainda não foi processado e não dependente de ninguém
	                If (Ascan(aStruct,{|x| x[11] + x[12] == aStruct[nPosStruc,1] + aStruct[nPosStruc,2]}) == 0) .And. ;
	                                                    aStruct[nPosStruc,10] == "2" .And. Empty(aStruct[nPosStruc,6])
	                    Exit
	                EndIf
	            Next
	            
	            cQuery := "SELECT DN5.DN5_PROCES, DN4.R_E_C_N_O_ DN4REC, DN5.R_E_C_N_O_ DN5REC " + CRLF
	            cQuery += "FROM "+RetSQLName("DN5")+" DN5 " + CRLF
	            cQuery += "INNER JOIN "+RetSQLName("DN4")+" DN4 ON " + CRLF
	            cQuery += "  DN4.DN4_FILIAL = '"+xFilial("DN4")+"' AND " + CRLF
	            cQuery += "  DN4.DN4_CODFON = DN5.DN5_CODFON AND " + CRLF
	            cQuery += "  DN4.DN4_CODREG = DN5.DN5_CODREG AND " + CRLF
	            cQuery += "  DN4.DN4_CHAVE  = DN5.DN5_CHAVE AND " + CRLF
	            cQuery += "  DN4.D_E_L_E_T_ = '' " + CRLF
	            cQuery += "WHERE " + CRLF
	            cQuery += "DN5.DN5_FILIAL = '"+xFilial("DN5")+"' AND " + CRLF
	            cQuery += "DN5.DN5_FILORI = '"+cFilAnt+"' AND " + CRLF
	            cQuery += "DN5.DN5_CODFON = '" + aStruct[nPosStruc,1] + "' AND " + CRLF
	            cQuery += "DN5.DN5_CODREG = '" + aStruct[nPosStruc,2] + "' AND " + CRLF
	            cQuery += "DN5.DN5_STATUS = '1' AND " + CRLF
	            cQuery += "DN5.DN5_SITUAC = '2' AND " + CRLF
	            cQuery += "DN5.D_E_L_E_T_ = '' " + CRLF
				If !Empty(cProcess)
					cQuery += "AND DN5.DN5_PROCES = '" + cProcess + "' " + CRLF
				EndIf
	            cQuery += "ORDER BY DN5.DN5_PROCES" + CRLF
	
	            cQuery := ChangeQuery(cQuery)
	            DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	            Do While !(cAliasQry)->(Eof())
					DN4->(DbGoTo((cAliasQry)->DN4REC))
					DN5->(DbGoTo((cAliasQry)->DN5REC))
					If aAlias[nCntFor1][1] == "DN1"
						DTQ->(DbSetOrder(2))
						If !DTQ->(MsSeek(RTrim(DN5->DN5_CHAVE))) .Or. DTQ->DTQ_STATUS == "3" //3==Encerrada
							TMSAC30Err( "TMSAI87Job", STR0001 + DTQ->(DTQ_FILORI+"/"+DTQ_VIAGEM), STR0002 )
							aRegDados := {}
							AAdd( aRegDados, {"DN5_STATUS", "4"} ) //-- Erro Devolução
							AAdd( aRegDados, {"DN5_SITUAC", "3"} ) //-- Recebido
							AAdd( aRegDados, {"DN5_MOTIVO", DN5->DN5_MOTIVO + TMSAC30GEr()} )
							AtuStatDN5(,,, aRegDados )
	
						Else
							lErroInteg := .F.
							If ( aViagem := TMSAC30GDV(AllTrim(DN5->DN5_IDEXT),,.F.) )[1] .And. aViagem[2] != "EXCLUIDA"
								aViaCol := DTQ->( DocViaCol(DTQ_FILORI,DTQ_VIAGEM) )
								If AScan(aViaCol, {|x| x[6] != "2" .And. x[6] != "4" } ) == 0 //2=Em Transito 4=Chegada Em Filial
									//Verifica se configurado para baixar direto do motorista ou aguarda viagem encerrada
									If aViagem[2] == "ENCERRADA" .Or. ( CFGParans(oColEnt,"BEREAL") != "3" .Or. CFGParans(oColEnt,"BENREA") != "3" ) .Or. !Empty(cProcess)
										aDocVia := TMSAC30GDV( AllTrim(DN5->DN5_IDEXT) )
										lErroInteg := !( aEntrParc := TMSAC30Par( oColEnt, AllTrim(DN5->DN5_IDEXT) ) )[1]
										If !lErroInteg
											//Necessário passar por todos os documentos para que o PE possa tratar mesmo os não finalizados.
											For nDoc := 1 To Len(aDocVia[2])
												If aDocVia[2][nDoc][4] != "FINALIZADA_COM_SUCESSO" .And. aDocVia[2][nDoc][4] != "FINALIZADA_COM_INSUCESSO"
													aDocVia[2][nDoc][6] := {}
												ElseIf (aEvidencia := TMSAC30GEv(aDocVia[2][nDoc][1]))[1]
													aDocVia[2][nDoc][6] := AClone(aEvidencia)
													If Len(aEntrParc[2]) > 0
														If ( nPosPar := AScan( aEntrParc[2], {|x| aDocVia[2][nDoc][1] == x[1] } ) ) > 0
															aDocVia[2][nDoc][4] := "FINALIZADA_COM_INSUCESSO"
															aDocVia[2][nDoc][6][2][7] := aEntrParc[2][nPosPar][2]
															aDocVia[2][nDoc][8] := { aEntrParc[2][nPosPar][3], AClone( aEntrParc[2][nPosPar][4] ) }
														EndIf
													EndIf
												Else
													lErroInteg := .T.
													Exit
												EndIf
											Next
											If lTMI87Con
												aPEDocVia := ExecBlock("TMI87CON",.F.,.F.,{AClone(aDocVia)})
												aDocVia := AClone(aPEDocVia)
											EndIf
										EndIf

										If !lErroInteg
											DUD->(DbSetOrder(1))
											For nDoc := 1 To Len(aDocVia[2])
												If aDocVia[2][nDoc][4] != "FINALIZADA_COM_SUCESSO" .And. aDocVia[2][nDoc][4] != "FINALIZADA_COM_INSUCESSO"
													Loop
												EndIf
												If ( nViaCol := AScan( aViaCol, {|x| AllTrim(x[3]+x[4]+x[5]) == aDocVia[2][nDoc][3] }) ) > 0
													If DUD->(MsSeek(xFilial("DUD")+aViaCol[nViaCol][3]+aViaCol[nViaCol][4]+aViaCol[nViaCol][5]+aViaCol[nViaCol][1]+aViaCol[nViaCol][2]))
														aEvidencia := AClone( aDocVia[2][nDoc][6] )
														cCodOco := ""
														cTipPnd := ""
														aNotas  := {}
														If aDocVia[2][nDoc][4] == "FINALIZADA_COM_SUCESSO"
															If aDocVia[2][nDoc][2] == "ENTREGA"
																cCodOco := CFGParans(oColEnt,"OCOENT")
															ElseIf aDocVia[2][nDoc][2] == "COLETA"
																cCodOco := CFGParans(oColEnt,"OCOCOL")
																If ( aChaveCol := TMSAC30GCh( aDocVia[2][nDoc][1] ) )[1]
																	DUD->( TME81CoCol( aChaveCol[2], DUD_FILORI,DUD_VIAGEM,DUD_FILDOC,DUD_DOC,DUD_SERIE, aEvidencia[2][01], aEvidencia[2][02] ) )
																EndIf
															EndIf
														ElseIf aDocVia[2][nDoc][4] == "FINALIZADA_COM_INSUCESSO"
															If aDocVia[2][nDoc][2] == "ENTREGA"
																cTipPnd   := ""
																If !Empty(aEvidencia) .And. aEvidencia[2,7] == "LOCAL_FECHADO"
																	cCodOco := CFGParans(oColEnt,"OCNFEC")
																ElseIf !Empty(aEvidencia) .And. aEvidencia[2,7] == "RECUSA"
																	cCodOco := CFGParans(oColEnt,"OCNREC")
																ElseIf !Empty(aEvidencia) .And. aEvidencia[2,7] == "AVARIA"
																	cCodOco := CFGParans(oColEnt,"OCNAVA")
																ElseIf !Empty(aEvidencia) .And. aEvidencia[2,7] == "FALTA"
																	cCodOco := CFGParans(oColEnt,"OCNFAL")
																Else
																	cCodOco := CFGParans(oColEnt,"OCNOUT")
																EndIf

																//Se gera pendencia é obrigatório ter vetor de notas
																cTipPnd := Posicione("DT2",1,xFilial("DT2") + cCodOco,"DT2_TIPPND")
																If !Empty(cTipPnd) .And. DT2->DT2_TIPOCO == "06"
																	//Se vetor de notas informado no COLENT verifica se está correto
																	If !Empty( aDocVia[2][nDoc][8] )
																		DTC->(DbSetOrder(18))
																		For nPosPar := 1 To Len(aDocVia[2][nDoc][8][2])
																			//Verifica se chave de nota informada no colent pertence ao CTe
																			If DTC->(MsSeek(cSeekDTC := FWxFilial("DTC") + aDocVia[2][nDoc][8][2][nPosPar][1]))
																				//Como uma nota pode fazer parte de vários CTes faz o loop até encotnrar a correta
																				While DTC->(!Eof()) .And. DTC->(DTC_FILIAL + DTC_NFEID) == cSeekDTC
																					//Se encontrada a nota correta utiliza a quantidade informada no colent
																					If DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE) == DTC->(DTC_FILDOC + DTC_DOC + DTC_SERIE)
																						Aadd(aNotas,{ DTC->DTC_NUMNFC, DTC->DTC_SERNFC, DTC->DTC_QTDVOL, aDocVia[2][nDoc][8][2][nPosPar][2], DTC->DTC_PESO } )
																					EndIf
																					DTC->(DbSkip())
																				EndDo
																			EndIf
																		Next
																	EndIf
																	//Se nenhuma nota informada corretamente no COLENT aponta para todas as notas do documento
																	If Len(aNotas) == 0
																		DTC->(DbSetOrder(3))
																		If DTC->(MsSeek(cSeekDTC := xFilial("DTC") + DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE)))
																			While DTC->(!Eof()) .And. DTC->(DTC_FILIAL + DTC_FILDOC + DTC_DOC + DTC_SERIE) == cSeekDTC
																				Aadd(aNotas,{ DTC->DTC_NUMNFC, DTC->DTC_SERNFC, DTC->DTC_QTDVOL, DTC->DTC_QTDVOL, DTC->DTC_PESO } )
																				DTC->(DbSkip())
																			EndDo
																		EndIf
																	EndIf
																EndIf
															ElseIf aDocVia[2][nDoc][2] == "COLETA"
																cCodOco := CFGParans(oColEnt,"OCNCOL")
															Endif
														EndIf

														If Empty(cProcess)
															If aViagem[2] != "ENCERRADA"
																If aDocVia[2][nDoc][4] == "FINALIZADA_COM_SUCESSO"
																	If CFGParans(oColEnt,"BEREAL") == "3"
																		Loop
																	ElseIf CFGParans(oColEnt,"BEREAL") == "2" .And. aDocVia[2][nDoc][7] != "APROVADA"
																		Loop
																	EndIf
																ElseIf aDocVia[2][nDoc][4] == "FINALIZADA_COM_INSUCESSO"
																	If CFGParans(oColEnt,"BENREA") == "3"
																		Loop
																	ElseIf CFGParans(oColEnt,"BENREA") == "2" .And. aDocVia[2][nDoc][7] != "APROVADA"
																		Loop
																	EndIf
																EndIf
															EndIf
														EndIf

														cErroOco := ""
														If !Empty(cCodOco) .And. DUD->(ApontaOcor(DUD_FILORI,DUD_VIAGEM,DUD_FILDOC,DUD_DOC,DUD_SERIE,DUD_SERTMS,cCodOco,aEvidencia[2][1],aEvidencia[2][2],aEvidencia[2][4],,,aNotas,cTipPnd,@cErroOco,cOcoInf))
															If !Empty(aEvidencia)
																If !Empty(aEvidencia[2][3][1]) .And. (aImagem := TMSAC30Img(aClone(aEvidencia[2][3])))[1]
																	aDadosGrv := {}
																	AAdd(aDadosGrv,{ "DM0_FILIAL", FWxFilial("DM0")       , Nil } )
																	AAdd(aDadosGrv,{ "DM0_FILDOC", DUD->DUD_FILDOC        , Nil } )
																	AAdd(aDadosGrv,{ "DM0_DOC"   , DUD->DUD_DOC           , Nil } )
																	AAdd(aDadosGrv,{ "DM0_SERIE" , DUD->DUD_SERIE         , Nil } )
																	AAdd(aDadosGrv,{ "DM0_IDINTG", DN5->DN5_IDEXT         , Nil } )
																	AAdd(aDadosGrv,{ "DM0_IMAGEM", Encode64(aImagem[2][5]), Nil } )
																	AAdd(aDadosGrv,{ "DM0_DATREA", aEvidencia[2][01]      , Nil } )
																	AAdd(aDadosGrv,{ "DM0_HORREA", aEvidencia[2][02]      , Nil } )
																	AAdd(aDadosGrv,{ "DM0_NOMRES", aEvidencia[2][04]      , Nil } )
																	AAdd(aDadosGrv,{ "DM0_DOCRES", aEvidencia[2][05]      , Nil } )
																	AAdd(aDadosGrv,{ "DM0_EXTENS", Substr(aImagem[2][3],At(".", aImagem[2][3])), Nil } )
																	AAdd(aDadosGrv,{ "DM0_STATUS", "2", Nil } )
																	cIdMPOS := ""
																	DUD->( GrvLocal( DUD_FILORI, DUD_VIAGEM, aEvidencia[2][09], aEvidencia[2][10], aEvidencia[2][01], aEvidencia[2][02], @cIdMPOS ) )
																	AAdd(aDadosGrv,{ "DM0_IDMPOS", cIdMPOS          , Nil } )
																	AAdd(aDadosGrv,{ "DM0_LATITU", aEvidencia[2][09], Nil } )
																	AAdd(aDadosGrv,{ "DM0_LONGIT", aEvidencia[2][10], Nil } )
																	ApontaCEle("DM0",0,aDadosGrv,FWxFilial("DM0")+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE),1)
																	If aDocVia[2][nDoc][2] == "ENTREGA" .And. aDocVia[2][nDoc][4] == "FINALIZADA_COM_SUCESSO"
																		aNFsComp := DUD->(ApontaComp(DUD_FILDOC,DUD_DOC,DUD_SERIE,aEvidencia[2][1],aEvidencia[2][2],aEvidencia[2][1],aEvidencia[2][2]))
																		DT6->(DbSetOrder(1))
																		If DT6->(MsSeek(xFilial("DT6") + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE))
																			If !FDocApoio(DT6->DT6_DOCTMS)
																				For nNFComp := 1 To Len(aNFsComp)
																					aDadosGrv := {}
																					AAdd(aDadosGrv,{ "DLY_RECEBE", aEvidencia[2][04], Nil } )
																					AAdd(aDadosGrv,{ "DLY_DOCREC", aEvidencia[2][05], Nil } )
																					AAdd(aDadosGrv,{ "DLY_STATUS", "2", Nil } )
																					ApontaCEle("DLY",4,aDadosGrv,xFilial("DLY")+aNFsComp[nNFComp],2)
																				Next
																			EndIf
																		EndIf 
																		//--Envia Comprante de Entrega Avulso ao Portal Logístico
																		If ExistFunc("TMS30ANEXO") .And. lCpentAvls
																			oPortLog := TMSBCACOLENT():New("DND")
																			If oPortLog:DbGetToken()
																				DND->(DbGoTo(oPortLog:config_recno))
																				If CFGParans(oPortLog,"CMPAVL") == "1"
																					TMS30ANEXO( DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE, .F. )
																				EndIf
																			EndIf  
																		EndIf 
																	EndIf
																EndIf
															EndIf
														Else
															cErroInt := DtoC(dDataBase) + "-" + Time() + CRLF
															If Empty(cCodOco)
																cErroInt += STR0003 + CRLF
															Else
																cErroInt += cErroOco + CRLF
																cErroOco := ""
															EndIf
															TMSAC30PEr(cErroInt)
														EndIf
													EndIf
												EndIf
											Next
										EndIf

										cErroInt := TMSAC30GEr()
										If aViagem[2] == "ENCERRADA" .Or. !Empty(cProcess)
											If !Empty(cErroInt)
												aRegDados := {}
												AAdd( aRegDados, {"DN5_STATUS", "4" } ) //-- Erro Devolução
												AAdd( aRegDados, {"DN5_SITUAC", "3" } ) //-- Recebido
												AAdd( aRegDados, {"DN5_MOTIVO", DN5->DN5_MOTIVO + cErroInt } )
												AtuStatDN5(,,, aRegDados, )
											Else
												aRegDados := {}
												AAdd( aRegDados, {"DN5_STATUS", "1" } ) //-- Integrado
												AAdd( aRegDados, {"DN5_SITUAC", "3" } ) //-- Recebido
												AAdd( aRegDados, {"DN5_MOTIVO", DN5->DN5_MOTIVO + DtoC(dDataBase) + " " + Time() + CRLF + STR0004 } )
												AtuStatDN5(,,, aRegDados )
											EndIf
										EndIf

									EndIf
								EndIf
							Else
								aRegDados := {}
								lDelVia := .F.
								If aViagem[1]
									AAdd( aRegDados, {"DN5_MOTIVO", DN5->DN5_MOTIVO + CRLF + DtoC(dDataBase) + " " + Time() + CRLF + ;
										" Id:"+ AllTrim(DN5->DN5_IDEXT) + " - Sit:" +  aViagem[2] + CRLF + STR0008 } )
									lDelVia := .T.
								Else
									cErroInt := TMSAC30GEr()
									If 'Viagem não encontrada.' $ cErroInt
										lDelVia := .T.
									EndIf
									AAdd( aRegDados, {"DN5_MOTIVO", DN5->DN5_MOTIVO + CRLF + DtoC(dDataBase) + " " + Time() + CRLF + ;
										" Id:"+ AllTrim(DN5->DN5_IDEXT) + " - Error:" +  cErroInt + CRLF + Iif( lDelVia, STR0008 + CRLF, "" ) } )
								EndIf
								AtuStatDN5( ,,, aRegDados, lDelVia )
							EndIf
						EndIf
					ElseIf aAlias[nCntFor1][1] == "DNM"	//-- Here
						If(aPlanej := TMSAC30GDV(AllTrim(DN5->DN5_IDEXT),,.F.,"DNM"))[1]
							If FindFunction("AtuPlaHere")  //-- Atualização do planejamento vindo da Here
								AtuPlaHere(aPlanej[2],DN5->DN5_PROCES,aAlias[nCntFor1][1])
								aRegDados := {}
								AAdd( aRegDados, {"DN5_STATUS", "1" } ) //-- Integrado
								AAdd( aRegDados, {"DN5_SITUAC", "3" } ) //-- Recebido
								AAdd( aRegDados, {"DN5_MOTIVO", DN5->DN5_MOTIVO + DtoC(dDataBase) + " " + Time() + CRLF + STR0004 } )
								AtuStatDN5(,,, aRegDados )
							EndIf
						Else
							cErroInt := TMSAC30GEr()
							If !Empty(cErroInt)
								aRegDados := {}
								AAdd( aRegDados, {"DN5_STATUS", "4" } ) //-- Erro Devolução
								AAdd( aRegDados, {"DN5_SITUAC", "3" } ) //-- Recebido
								AAdd( aRegDados, {"DN5_MOTIVO", DN5->DN5_MOTIVO + cErroInt } )
								AtuStatDN5(,,, aRegDados )
							EndIf
						EndIf
					EndIf
					(cAliasQry)->(DbSkip())
                EndDo
	            (cAliasQry)->(DbCloseArea())
	        EndIf
        Next nCntFor1
		UnLockByName("TM87JbLoop")
    EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

FwFreeArray(aResult)
FwFreeArray(aStruct)
FwFreeArray(aViagem)
FwFreeArray(aViaCol)
FwFreeArray(aDocVia)
FwFreeArray(aEvidencia)
FwFreeArray(aPEDocVia)
FwFreeArray(aImagem)
FwFreeArray(aDadosGrv)
FwFreeArray(aNFsComp)
FwFreeArray(aRegDados)
FwFreeArray(aAreas)

FWFreeObj(oColEnt)
FwFreeObj(oPortLog)
FwFreeObj(oIntegr)
FwFreeObj(oHere)

Return

/*{Protheus.doc} Scheddef()
@Função Função para atualizar DN5 por Processo (todos registros iguais)
@author Carlos Alberto Gomes Junior
@since 28/07/2022
*/
Static Function AtuStatDN5( cCodFon, cProcess, cLocali, aRegDados, lDelDN4DN5 )
Local aAreas := {}

DEFAULT cCodFon    := DN5->DN5_CODFON
DEFAULT cProcess   := DN5->DN5_PROCES
DEFAULT cLocali    := AllTrim(DN5->DN5_LOCALI)
DEFAULT aRegDados  := {}
DEFAULT lDelDN4DN5 := .F.

    DNC->(DbSetOrder(1))
    If lDelDN4DN5
        aAreas := { dn4->(GetArea()), DN5->(GetArea()), GetArea() }
        DN4->(DbSetOrder(1))
        DN5->(DbSetOrder(5))
        Do While DN5->(DbSeek( xFilial("DN5") + cCodFon + cProcess))
            If DN4->(DbSeek( xFilial("DN4") + cCodFon + DN5->(DN5_CODREG + DN5_CHAVE)))
                RecLock("DN4",.F.)
                DN4->( DbDelete() )
                MsUnlock()
            EndIf
            If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
                RecLock("DNC", .F.)
                DNC->( DbDelete() )
                MsUnlock()
            EndIf
            RecLock("DN5",.F.)
            DN5->( AEval(aRegDados,{|x| FieldPut( FieldPos(x[1]), x[2] ) }) )
            DN5->( DbDelete() )
            MsUnlock()
        EndDo
        AEval(aAreas, {|aArea| RestArea(aArea), FwFreeArray(aArea) })

    ElseIf !Empty(aRegDados)
        aAreas := { DN5->(GetArea()), GetArea() }
        DN5->(DbSetOrder(5))
        DN5->(MsSeek(xFilial("DN5") + cCodFon + cProcess + cLocali))
        Do While !DN5->(Eof()) .And. xFilial("DN5") + cCodFon + cProcess + cLocali == DN5->(DN5_FILIAL + DN5_CODFON + DN5_PROCES + Left(DN5_LOCALI,Len(cLocali)))
            RecLock("DN5",.F.)
            DN5->( AEval(aRegDados,{|x| FieldPut( FieldPos(x[1]), x[2] ) }) )
            MsUnlock()
            If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
                RecLock("DNC", .F.)
                DNC->( AEval(aRegDados,{|x| If(Substr(x[1],4) $ "_STATUS|_SITUAC", FieldPut( FieldPos("DNC"+Substr(x[1],4)), x[2] ) , ) }) )
                DNC->DNC_DATULT := dDataBase
				DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
                MsUnlock()
            EndIf
            DN5->(DbSkip())
        EndDo
        AEval(aAreas, {|aArea| RestArea(aArea), FwFreeArray(aArea) })

    EndIf
    FwFreeArray(aRegDados)
    FwFreeArray(aAreas)

Return

/*{Protheus.doc} GrvLocal
Grava Geolocalização Tabela DAV
@author Carlos Alberto Gomes Junior
@CopiadoDe Função statica no TMSAO10 de Rodrigo Pirolo
@since 09/05/22
*/
Static Function GrvLocal( cFilOrigem, cNumViagem, cLatitu, cLongit, dDatEnt, cHorEnt, cIdMPOS )

    Local aAreas  := { DTR->(GetArea()), GetArea() }
    Local lRet    := .T.
    Local lBlind  := IsBlind()
    Local aCabDAV := {}
    
    Private lMsErroAuto     := .F.
    Private lAutoErrNoFile  := .T.

    Default cFilOrigem := ""
    Default cNumViagem := ""
    Default cLatitu    := 0
    Default cLongit    := 0
    Default dDatEnt    := CToD("")
    Default cHorEnt    := ""

    DbSelectArea( "DTR" )
    DTR->( DbSetOrder( 1 ) ) // DTR_FILIAL, DTR_FILORI, DTR_VIAGEM, DTR_ITEM
    If DTR->( DbSeek( xFilial( "DTR" ) + cFilOrigem + cNumViagem + StrZero( 1, Len( DTR->DTR_ITEM ) ) ) )

        AAdd( aCabDAV, { "DAV_CODVEI", DTR->DTR_CODVEI, NIL } )
        AAdd( aCabDAV, { "DAV_FILORI", cFilOrigem,      NIL } )
        AAdd( aCabDAV, { "DAV_VIAGEM", cNumViagem,      NIL } )
        AAdd( aCabDAV, { "DAV_TIPPOS", "3",             NIL } ) // 1=GPRS Memória; 2=GPRS Atual; 3=Satelital
        AAdd( aCabDAV, { "DAV_LATITU", cLatitu,         NIL } )
        AAdd( aCabDAV, { "DAV_LONGIT", cLongit,         NIL } )
        AAdd( aCabDAV, { "DAV_STATUS", "3",             NIL } ) // 1=Nao Processado; 2=Processado com erro; 3=Processado
        AAdd( aCabDAV, { "DAV_DATPOS", dDatEnt,         NIL } )
        Aadd( aCabDAV, { "DAV_HORPOS", cHorEnt,         NIL } )
        Aadd( aCabDAV, { "DAV_IGNICA", "2",             NIL } ) // 0=Desligada; 1=Ligada; 2=Não identificada

        lAutoErrNoFile := If( lBlind, .T., .F. )
        MSExecAuto( { | x, y | TMSAO10( x, y ) }, aCabDAV, 3 )
        If lMsErroAuto
            If !lBlind
                MostraErro()
            EndIf
            lRet := .F.
        Else
            cIdMPOS := DAV->DAV_IDMPOS
        EndIf
        lMsErroAuto := .F.
    EndIf

    FwFreeArray( aCabDAV )
    AEval(aAreas, {|aArea| RestArea(aArea) })
    FwFreeArray( aAreas )
    
Return lRet

/*{Protheus.doc} Scheddef()
@Função Função de parâmetros do Scheduler
@author Carlos Alberto Gomes Junior
@since 25/07/2022
*/
Static Function SchedDef()
Local aParam := { "P",;        //Tipo R para relatorio P para processo
                  "",;         //Pergunte do relatorio, caso nao use passar ParamDef
                  "DN5",;      //Alias
                  ,;           //Array de ordens
                  STR0005 }    //Descrição do Schedule
Return aParam

/*{Protheus.doc} CFGParans
Função para gartir funcionalidade caso o fonte TMSAC30 não esteja atualizado
@author Carlos Alberto Gomes Junior
@since 30/10/25
*/
Static Function CFGParans(oColEnt,cCpo)
	Local cVersao := TMSAC30()
	Local nPos, uRet
	If ( nPos := (oColEnt:Alias_Config)->( FieldPos( oColEnt:Alias_Config+"_"+cCpo ) ) ) > 0
		uRet := (oColEnt:Alias_Config)->(FieldGet( nPos ))
	EndIf
	If ValType(cVersao) == "C" .And. cVersao == "2.0" .And. oColEnt:CFGParans:HasProperty(cCpo)
		uRet := oColEnt:CFGParans[cCpo]
	EndIf
Return uRet
