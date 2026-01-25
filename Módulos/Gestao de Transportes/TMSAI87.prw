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
Function TMSAI87Aux()
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
	Local lCpentAvls := AliasInDic("DND") .And. DND->(ColumnPos("DND_CMPAVL"))>0 // Comprovante de Entrega Avulso
	Local aAlias     := {}
	Local aPlanej    := {}
	Local nCntFor1   := 0
	Local oColEnt  As Object
	Local oPortLog As Object
	Local oIntegr  As Object
	Local oHere    As Object
	Local lLoop      := .F.
	Local lDelVia    := .F.
	Local lErroInteg := .F.

	Local aEntrParc  := {}
	Local nLinParc   := 0
	Local lEntrParc  := .T.
	
	If AliasInDic("DN1")
		AAdd(aAlias,"DN1")
	EndIf
	If AliasInDic("DNM")
		AAdd(aAlias,"DNM")
	EndIf

    If LockByName("TM87JbLoop",.T.,.T.)
		For nCntFor1 := 1 To Len(aAlias)
	        oIntegr := TMSBCACOLENT():New(aAlias[nCntFor1])
	        If oIntegr:DbGetToken()
	        	If aAlias[nCntFor1] == "DN1"
	        		oColEnt := oIntegr
		            DN1->(DbGoTo(oColEnt:config_recno))
		            aEntrParc := TMSAI87Par()
					aEntrParc := TMSAI87MPr(Aclone(aEntrParc))
		        ElseIf aAlias[nCntFor1] == "DNM"
		        	oHere := oIntegr
					DNM->(DbGoTo(oHere:config_recno))
				EndIf
				
	            //-- Inicializa a estrutura
	            aStruct := TMSMntStru(&(aAlias[nCntFor1] + "->" + aAlias[nCntFor1] + "_CODFON"),.T.,Iif(aAlias[nCntFor1] == "DNM","0002",""))
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
	            cQuery += "ORDER BY DN5.DN5_PROCES" + CRLF
	
	            cQuery := ChangeQuery(cQuery)
	            DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	            Do While !(cAliasQry)->(Eof())
		            Begin Transaction
	                    DN4->(DbGoTo((cAliasQry)->DN4REC))
	                    DN5->(DbGoTo((cAliasQry)->DN5REC))
	                    If aAlias[nCntFor1] == "DN1"
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
		                                If aViagem[2] == "ENCERRADA" .Or. (oColEnt:cRetSucesso != "3" .Or. oColEnt:cRetInsucesso != "3")
										
		                                    aDocVia := TMSAC30GDV(AllTrim(DN5->DN5_IDEXT))
		                                    For nDoc := 1 To Len(aDocVia[2])
		                                        If (aEvidencia := TMSAC30GEv(aDocVia[2][nDoc][1]))[1]
		                                            aDocVia[2][nDoc][6] := AClone(aEvidencia)
												Else
													lErroInteg := .T.
													Exit
		                                        EndIf
		                                    Next
		                                    If lTMI87Con
		                                        aPEDocVia := ExecBlock("TMI87CON",.F.,.F.,{AClone(aDocVia)})
		                                        aDocVia := AClone(aPEDocVia)
		                                    EndIf

											DUD->(DbSetOrder(1))
											If !lErroInteg
												For nDoc := 1 To Len(aDocVia[2])
													If ( nViaCol := AScan(aViaCol,{|x| AllTrim(x[3]+x[4]+x[5]) == aDocVia[2][nDoc][3] }) ) > 0
														If DUD->(MsSeek(xFilial("DUD")+aViaCol[nViaCol][3]+aViaCol[nViaCol][4]+aViaCol[nViaCol][5]+aViaCol[nViaCol][1]+aViaCol[nViaCol][2]))
															aEvidencia := AClone(aDocVia[2][nDoc][6])
															cCodOco := ""

															lEntrParc := .F.
															If aDocVia[2][nDoc][4] == "FINALIZADA_COM_SUCESSO"
																If aDocVia[2][nDoc][2] == "ENTREGA"
																	If (nLinParc := Ascan(aEntrParc,{|x| x[8] + x[9] + x[10] + x[16] + x[17] == ;
																					aViaCol[nViacol,3] + aViaCol[nViacol,4] + aViaCol[nViacol,5] + ;
																					aViaCol[nViacol,1] + aViaCol[nViacol,2]})) > 0
																		TMSAI87LPr(Aclone(aEntrParc),nLinParc,nLinParc)
																		lEntrParc := .T.
																	EndIf
																	cCodOco := DN1->DN1_OCOENT
																ElseIf aDocVia[2][nDoc][2] == "COLETA"
																	cCodOco := DN1->DN1_OCOCOL
																	If ( aChaveCol := TMSAC30GCh( aDocVia[2][nDoc][1] ) )[1]
																		DUD->( TME81CoCol( aChaveCol[2], DUD_FILORI,DUD_VIAGEM,DUD_FILDOC,DUD_DOC,DUD_SERIE, aEvidencia[2][01], aEvidencia[2][02] ) )
																	EndIf
																EndIf
															ElseIf aDocVia[2][nDoc][4] == "FINALIZADA_COM_INSUCESSO"
																If aDocVia[2][nDoc][2] == "ENTREGA"
																	cCodOco := DN1->DN1_OCNFEC
																ElseIf aDocVia[2][nDoc][2] == "COLETA"
																	cCodOco := DN1->DN1_OCNCOL
																Endif
															Else
																Loop
															EndIf

															lLoop := .F.
															DUA->(DbSetOrder(3))
															If DUA->(MsSeek(xFilial("DUA")+cCodOco+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
																Do While !DUA->(Eof()) .And. DUA->(DUA_FILIAL+DUA_CODOCO+DUA_FILDOC+DUA_DOC+DUA_SERIE) == xFilial("DUA")+cCodOco+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)
																	If DUD->(DUD_FILORI+DUD_VIAGEM) == DUA->(DUA_FILORI+DUA_VIAGEM)
																		lLoop := .T.
																		Exit
																	EndIf
																	DUA->(DbSkip())
																EndDo
																If lLoop
																	Loop
																EndIf
															EndIf

															If aViagem[2] != "ENCERRADA"
																If aDocVia[2][nDoc][4] == "FINALIZADA_COM_SUCESSO"
																	If oColEnt:cRetSucesso == "3"
																		Loop
																	ElseIf oColEnt:cRetSucesso == "2" .And. aDocVia[2][nDoc][7] != "APROVADA"
																		Loop
																	EndIf
																ElseIf aDocVia[2][nDoc][4] == "FINALIZADA_COM_INSUCESSO"
																	If oColEnt:cRetInsucesso == "3"
																		Loop
																	ElseIf oColEnt:cRetInsucesso == "2" .And. aDocVia[2][nDoc][7] != "APROVADA"
																		Loop
																	EndIf
																EndIf
															EndIf

															cErroOco := ""
															If !Empty(cCodOco) .And. DUD->(ApontaOcor(DUD_FILORI,DUD_VIAGEM,DUD_FILDOC,DUD_DOC,DUD_SERIE,DUD_SERTMS,cCodOco,aEvidencia[2][1],aEvidencia[2][2],aEvidencia[2][4],,,,@cErroOco,lEntrParc))
																If !Empty(aEvidencia[2][3][1]) .And. (aImagem := TMSAC30Img(aClone(aEvidencia[2][3])))[1]
																	aDadosGrv := {}
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
																	ApontaCEle("DM0",4,aDadosGrv,xFilial("DM0")+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE),1)
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
																				If DND->DND_CMPAVL == "1"
																					TMS30ANEXO( DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE, .F. )
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
											If aViagem[2] == "ENCERRADA"
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
	                    ElseIf aAlias[nCntFor1] == "DNM"	//-- Here
	                        If(aPlanej := TMSAC30GDV(AllTrim(DN5->DN5_IDEXT),,.F.,"DNM"))[1]
					            If FindFunction("AtuPlaHere")  //-- Atualização do planejamento vindo da Here
									AtuPlaHere(aPlanej[2],DN5->DN5_PROCES,aAlias[nCntFor1])
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

		            End Transaction
                EndDo
	            (cAliasQry)->(DbCloseArea())
	        EndIf
        Next nCntFor1
		UnLockByName("TM87JbLoop")
    EndIf

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

/*
{Protheus.doc} TMSAI87Par
Busca documentos com entrega parcial
@author Valdemar Roberto Mognon
@type Function
@author Valdemar Roberto Mognon
@since 02/01/2025
*/
Function TMSAI87Par(cStatus,dDatIni,cHorIni,dDatFim,cHorFim)
Local aAreas   := {DTC->(GetArea()),GetArea()}
Local aRet     := {}
Local aResGet  := {}
Local aItem    := {}
Local cDatIni  := ""
Local cDatFim  := ""
Local cIdTenta := ""
Local cIdEntre := ""
Local cChaveNF := ""
Local nCntFor1 := 0
Local oColEnt
Local oResult

Default cStatus := "ENTREGA_PARCIAL"
Default dDatIni := dDataBase
Default cHorIni := "00:00:01"
Default dDatFim := dDataBase
Default cHorFIm := "23:59:59"

cDatIni := SubStr(DToS(dDatIni),1,4) + "-" + SubStr(DToS(dDatIni),5,2) + "-" + SubStr(DToS(dDatIni),7,2) + "T" + cHorIni
cDatFim := SubStr(DToS(dDatFim),1,4) + "-" + SubStr(DToS(dDatFim),5,2) + "-" + SubStr(DToS(dDatFim),7,2) + "T" + cHorFim

oColEnt := TMSBCACOLENT():New("DN1")
If (aResGet := oColEnt:Get("coletaentrega/query/api/v1/documentosCargaEntrega","?page=1&pageSize=9999&situacao=" + cStatus + "&dataSituacaoInicial=" + cDatIni + "&dataSituacaoFinal=" + cDatFim))[1]
	oResult := JsonObject():New()
	oResult:FromJson(aResGet[2])
	If ValType(oResult["items"]) == "A" .And. Len(oResult["items"]) > 0
		DTC->(DbSetOrder(18))
		For nCntFor1 := 1 To Len(oResult["items"])
			aItem := oResult["items",nCntFor1]
			cIdTenta := aItem["tentativaId"]
			If ValType(aItem["entrega"]) == "J"
				cIdEntre := aItem["entrega","id"]
			Else
				cIdEntre := ""
			EndIf
			cChaveNF := aItem["chave"]
			If DTC->(MsSeek(xFilial("DTC") + cChaveNF))
				Aadd(aRet,{cIdTenta,;
							cIdEntre,;
							cChaveNF,;
							DTC->DTC_CLIREM,;
							DTC->DTC_LOJREM,;
							DTC->DTC_NUMNFC,;
							DTC->DTC_SERNFC,;
							DTC->DTC_FILDOC,;
							DTC->DTC_DOC,;
							DTC->DTC_SERIE,;
							DTC->DTC_PESO,;
							DTC->DTC_QTDVOL})
			EndIf
		Next nCntFor1
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return Aclone(aRet)

/*
{Protheus.doc} TMSAI87MPr
Monta entrega parcial
@type Function
@author Valdemar Roberto Mognon
@since 02/01/2025
*/
Function TMSAI87MPr(aVetEnt)
Local aRet      := {}
Local aAreas    := {DT2->(GetArea()),DT6->(GetArea()),DN1->(GetArea()),GetArea()}
Local aResGet   := {}
Local nCntFor1  := 0
Local nQtdRet   := 0
Local cData     := ""
Local cMotivo   := ""
Local cViagem   := ""
Local cQuery    := ""
Local cAliasDUA := ""
Local cCodOco   := ""
Local oColEnt
Local oResult

Default aVetEnt := {}

DT6->(DbSetOrder(1))

oColEnt := TMSBCACOLENT():New("DN1")
DN1->(DbGoTo(oColEnt:config_recno))

For nCntFor1 := 1 To Len(aVetEnt)
	If (aResGet := oColEnt:Get("coletaentrega/query/api/v1/documentosCargaEntrega", "/" + aVetEnt[nCntFor1,1] + "/entrega/" + aVetEnt[nCntFor1,2]))[1]
		oResult := JsonObject():New()
		oResult:FromJson(aResGet[2])
		If DT6->(MsSeek(xFilial("DT6") + aVetEnt[nCntFor1,8] + aVetEnt[nCntFor1,9] + aVetEnt[nCntFor1,10]))
			cData   := oResult["tentativa","dataSituacao"]
			cMotivo := oResult["tentativa","motivo"]
			If cMotivo == "RECUSA"
				cCodOco := DN1->DN1_OCNREC
			ElseIf cMotivo == "AVARIA"
				cCodOco := DN1->DN1_OCNAVA
			ElseIf cMotivo == "FALTA"
				cCodOco := DN1->DN1_OCNFAL
			Else
				cCodOco := DN1->DN1_OCNOUT
			EndIf
			nQtdRet := oResult["tentativa","quantidadeRetornada"]
			cViagem := oResult["viagem","descricao"]

			//-- Verifica se já existe ocorrência apontada para o documento e viagem
			cAliasDUA := GetNextAlias()
			cQuery := " SELECT * "
			cQuery +=    "FROM " + RetSQLName("DUA") + " DUA "
			
			cQuery +=   "INNER JOIN " + RetSQLName("DT2") + " DT2 "
			cQuery +=      "ON DT2_FILIAL = '" + xFilial("DT2") + "' "
			cQuery +=     "AND DT2_CODOCO = DUA_CODOCO "
			cQuery +=     "AND DT2_TIPOCO <> '05' "
			cQuery +=     "AND DT2.D_E_L_E_T_ =  ' ' "

			cQuery +=   "WHERE DUA_FILIAL = '" + xFilial("DUA") + "' "
			cQuery +=     "AND DUA_FILDOC = '" + aVetEnt[nCntFor1,8] + "' "
			cQuery +=     "AND DUA_DOC    = '" + aVetEnt[nCntFor1,9] + "' "
			cQuery +=     "AND DUA_SERIE  = '" + aVetEnt[nCntFor1,10] + "' "
			cQuery +=     "AND DUA_FILORI = '" + DT6->DT6_FILVGA + "' "
			cQuery +=     "AND DUA_VIAGEM = '" + DT6->DT6_NUMVGA + "' "
			cQuery +=     "AND DUA.D_E_L_E_T_ =  ' ' "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDUA,.F.,.T.)		
				
			If (cAliasDUA)->(Eof())
				Aadd(aRet,{aVetEnt[nCntFor1,1],;
							aVetEnt[nCntFor1,2],;
							aVetEnt[nCntFor1,3],;
							aVetEnt[nCntFor1,4],;
							aVetEnt[nCntFor1,5],;
							aVetEnt[nCntFor1,6],;
							aVetEnt[nCntFor1,7],;
							aVetEnt[nCntFor1,8],;
							aVetEnt[nCntFor1,9],;
							aVetEnt[nCntFor1,10],;
							aVetEnt[nCntFor1,11],;
							aVetEnt[nCntFor1,12],;
							cData,;
							nQtdRet,;
							cCodOco,;
							DT6->DT6_FILVGA,;
							DT6->DT6_NUMVGA,;
							Posicione("DT2",1,xFilial("DT2") + cCodOco,"DT2_TIPPND")})
			EndIf		
			(cAliasDUA)->(DbCloseArea())	
			RestArea(aAreas[Len(aAreas)])
		EndIf
	EndIf
Next nCntFor1

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return aRet

/*
{Protheus.doc} TMSAI87LPr
Lança entrega parcial
@author Valdemar Roberto Mognon
@type Function
@author Valdemar Roberto Mognon
@since 02/01/2025
*/
Function TMSAI87LPr(aVetEnt,nLinIni,nLinFim)
Local aCab      := {}
Local aItens    := {}
Local aNFAvaria := {}
Local nCntFor1  := 0

Private lMSErroAuto := .F.

Default aVetEnt  := {}
Default nLinIni  := 1
Default nLinFim  := Len(aVetEnt)

//-- Mapa do vetor aVetEnt
//-- 01 - Id da Tentativa
//-- 02 - Id da Entrega
//-- 03 - Chave Eletrônica da NF
//-- 04 - Código do Remetente
//-- 05 - Loja do Remetente
//-- 06 - Número da NF
//-- 07 - Série da NF
//-- 08 - Filial de Origem do CTe
//-- 09 - Número do CTe
//-- 10 - Série do CTe
//-- 11 - Peso da NF
//-- 12 - Quantidade de Volumes da NF
//-- 13 - Data e hora da ocorrência
//-- 14 - Quantidade Retornada
//-- 15 - Código da ocorrência
//-- 16 - Filial de Origem da viagem
//-- 17 - Número da viagem
//-- 18 - Tipo da Pendência

If nLinIni > 0 .And. nLinFim > 0
	For nCntFor1 := nLinIni To nLinFim
		//-- Cabeçalho da ocorrência
		Aadd(aCab,{"DUA_FILORI",aVetEnt[nCntFor1,16],NIL})
		Aadd(aCab,{"DUA_VIAGEM",aVetEnt[nCntFor1,17],NIL})

		//--Item da ocorrência
		Aadd(aItens,{{"DUA_SEQOCO",StrZero(1,Len(DUA->DUA_SEQOCO))                        ,NIL},;
					{"DUA_DATOCO",SToD(StrTran(SubStr(aVetEnt[nCntFor1,13],1,10),"-","")),NIL},;
					{"DUA_HOROCO",StrTran(SubStr(aVetEnt[nCntFor1,13],12,5),":","")      ,NIL},;
					{"DUA_CODOCO",PadR(aVetEnt[nCntFor1,15],Len(DT2->DT2_CODOCO))        ,NIL},;
					{"DUA_FILDOC",aVetEnt[nCntFor1,8]                                    ,NIL},;
					{"DUA_DOC"   ,aVetEnt[nCntFor1,9]                                    ,NIL},;
					{"DUA_SERIE" ,aVetEnt[nCntFor1,10]                                   ,NIL},;
					{"DUA_QTDOCO",aVetEnt[nCntFor1,12]                                   ,NIL},;
					{"DUA_PESOCO",aVetEnt[nCntFor1,11]                                   ,NIL}})

		//-- Nota fiscal com pendência
		aNFAvaria := {{aVetEnt[nCntFor1,8] + aVetEnt[nCntFor1,9] + aVetEnt[nCntFor1,10],;
					{{aVetEnt[nCntFor1,6],aVetEnt[nCntFor1,7],aVetEnt[nCntFor1,12],aVetEnt[nCntFor1,14],"",.F.}},;
					{{aVetEnt[nCntFor1,6],(aVetEnt[nCntFor1,11] / aVetEnt[nCntFor1,12])}},;
					PadR(aVetEnt[nCntFor1,15],Len(DT2->DT2_CODOCO)),aVetEnt[nCntFor1,18],"1"}}

		lMSErroAuto := .F.

		MsExecAuto({|x,y,z| TMSA360(x,y,z)},aCab,aItens,aNFAvaria,3)
		
		If lMSErroAuto   
			MostraErro()
		EndIf
	Next nCntFor1
EndIf

Return
