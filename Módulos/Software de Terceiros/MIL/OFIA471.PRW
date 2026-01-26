#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA471.CH"

/*/{Protheus.doc} OFIA471
	Cadastro de Solicitações e Liberações de Valor Minimo e Credito do Cliente na Saida de Serviços Especializados

	@author Andre Luis Almeida
	@since 29/09/2022
/*/
Function OFIA471()
Return

Static Function MenuDef()

	Local aRotina := {}
	aRotina := FWMVCMenu('OFIA471')

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVRU := FWFormStruct(1, "VRU")

	oModel := MPFormModel():New('OFIA471',,,,)
	oModel:AddFields('VRUMASTER',/*cOwner*/ , oStrVRU)
	oModel:SetDescription(STR0001) // Solicitações e Liberações de Valor Minimo e Credito do Cliente na Saida de Serviços Especializados
	oModel:GetModel('VRUMASTER'):SetDescription(STR0001) // Solicitações e Liberações de Valor Minimo e Credito do Cliente na Saida de Serviços Especializados

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVRU:= FWFormStruct(2, "VRU", { |cCampo| !ALLTRIM(cCampo) $ 'VRU_CODIGO/VRU_CODVRR/' } )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:CreateHorizontalBox( 'BOXVRU', 100)
	oView:AddField('VIEW_VRU', oStrVRU, 'VRUMASTER')
	oView:SetOwnerView('VIEW_VRU','BOXVRU')

Return oView

/*/{Protheus.doc} OA4710011_InclusaoSolicitacao
Inclusao da Solicitação

@author Andre Luis Almeida
@since 29/09/2022
@type function
/*/
Function OA4710011_InclusaoSolicitacao( cCodVRR , aLimCre , aVlrMin , nTotSai , nDivMin )
	Local oModVRU
	Local aRetTela  := {}
	Local cQuery    := ""
	Local nRecVRU   := 0
	Local nCntFor   := 0
	Default cCodVRR := ""
	Default aLimCre := {}
	Default aVlrMin := {}
	Default nTotSai := 0
	Default nDivMin := 0
	//
	aRetTela := OA4710041_TelaPendencias( aLimCre , aVlrMin , .t. ) // Tela de Pendencias para Solicitacao de Liberação
	//
	cQuery := "SELECT R_E_C_N_O_ AS RECVRU "
	cQuery += "  FROM " + RetSqlName("VRU")
	cQuery += " WHERE VRU_FILIAL = '" + xFilial("VRU") + "'"
	cQuery += "   AND VRU_CODVRR = '" + cCodVRR + "'"
	cQuery += "   AND VRU_ATIVO  = '1'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += "   AND VRU_TIPSOL = "
	//
	For nCntFor := 1 to len(aRetTela)
		//
		nRecVRU := FM_SQL( cQuery + "'" + aRetTela[nCntFor] + "'" )
		If nRecVRU > 0
			VRU->(DbGoTo(nRecVRU))
			oModVRU := FWLoadModel( 'OFIA471' )
			oModVRU:SetOperation( MODEL_OPERATION_UPDATE )
			If oModVRU:Activate()
				oModVRU:LoadValue( "VRUMASTER" , "VRU_ATIVO " , "0" ) // Desativar o registro em aberto para gerar um novo.
				If oModVRU:VldData()
					oModVRU:CommitData()
				EndIf
				oModVRU:DeActivate()
			EndIf
			FreeObj(oModVRU)
		EndIf
		//
		oModVRU := FWLoadModel( 'OFIA471' )
		oModVRU:SetOperation( MODEL_OPERATION_INSERT )
		If oModVRU:Activate()
			oModVRU:LoadValue( "VRUMASTER" , "VRU_CODVRR" , cCodVRR )
			oModVRU:LoadValue( "VRUMASTER" , "VRU_TIPSOL" , aRetTela[nCntFor] )
			oModVRU:LoadValue( "VRUMASTER" , "VRU_VLRSOL" , IIf(aRetTela[nCntFor]=="1",nTotSai,nDivMin) )
			If VRU->(FieldPos('VRU_PERSOL')) > 0
				oModVRU:LoadValue( "VRUMASTER" , "VRU_PERSOL" , IIf(aRetTela[nCntFor]=="1", 0 ,OA471009K_Calc_Percentual_Solicitado(aVlrMin, nCntFor) * -1))
			Endif
			If oModVRU:VldData()
				oModVRU:CommitData()
			EndIf
			oModVRU:DeActivate()
		EndIf
		FreeObj(oModVRU)
		//
	Next
	//
Return ( len(aRetTela) > 0 )

/*/{Protheus.doc} OA4710021_AprovarReprovarSolicitacao
1 - Aprovar Solicitação / 2 - Reprovar Solicitação

@author Andre Luis Almeida
@since 29/09/2022
@type function
/*/
Function OA4710021_AprovarReprovarSolicitacao(cAprRep)
	Local oModVRU
	Local nCntFor   := 0
	Local nRecVRU   := 0
	Local aMotivo   := {}
	Local cMotivo   := ""
	Local cStatus   := ""
	Local cQuery    := ""
	Local cMsg      := ""
	Default cAprRep := "1"
	//
	Do Case
		Case VRU->VRU_ATIVO == '0' // NÃO ATIVOS - Cancelada
			MsgStop(STR0003,STR0002) // Solicitação Cancelada. Impossível continuar. / Atenção
		Case VRU->VRU_ATIVO == '1' .and. VRU->VRU_STATUS == '0' // ATIVOS - Pendente Liberação
			If cAprRep == "1" // 1 - Aprovar Solicitação
				cMsg := STR0004 // Deseja APROVAR a Solicitação?
				VAI->(Dbsetorder(4))
				VAI->(DbSeek(xFilial("VAI")+__cUserID))
				If VRU->VRU_TIPSOL == "1" // 1=Limite Crédito
					If VAI->VAI_ALLBCR < VRU->VRU_VLRSOL // Alçada de Liberação de Crédito
						MsgStop(STR0005,STR0002) // Usuário sem permissão para Liberar o Valor Total da Saida dos Serviços Especializados. / Atenção
						Return
					EndIf
					cMotivo := "000029" // APROVA SOL.LIM.CREDITO SERV.ESPECIALIZADO
				ElseIf VRU->VRU_TIPSOL == "2" // 2=Valor Minimo
					If !OA471008K_Usuario_Possui_Alcada()
						MsgStop(STR0006,STR0002) // Usuário sem permissão para Liberar toda divergencia de Valor Minimo dos Serviços Especializados. / Atenção
						Return
					EndIf
					cMotivo := "000027" // APROVA SOL.VLR.MINIMO SERV.ESPECIALIZADO
				EndIf
			Else // 2 - Reprovar Solicitação
				cMsg := STR0007 // Deseja REPROVAR a Solicitação?
				If VRU->VRU_TIPSOL == "1" // 1=Limite Crédito
					cMotivo := "000028" // REPROVA SOL.LIM.CREDITO SERV.ESPECIALIZADO
				ElseIf VRU->VRU_TIPSOL == "2" // 2=Valor Minimo
					cMotivo := "000030" // REPROVA SOL.VLR.MINIMO SERV.ESPECIALIZADO
				EndIf
			EndIf
			If MsgNoYes( cMsg , STR0002 ) // Atenção
				//
				BEGIN TRANSACTION
				//
				aMotivo := OFA210MOT(cMotivo,"B",VRU->VRU_FILIAL,VRU->VRU_CODIGO,.T.) // Filtro da consulta do motivo
				If Len(aMotivo) > 0
					//
					oModVRU := FWLoadModel( 'OFIA471' )
					oModVRU:SetOperation( MODEL_OPERATION_UPDATE )
					If oModVRU:Activate()
						oModVRU:LoadValue( "VRUMASTER" , "VRU_STATUS" , cAprRep ) // ( 1 - Aprovar / 2 - Reprovar )
						oModVRU:LoadValue( "VRUMASTER" , "VRU_DATAPR" , dDatabase )
						oModVRU:LoadValue( "VRUMASTER" , "VRU_HORAPR" , left(time(),2)+substr(time(),4,2) )
						oModVRU:LoadValue( "VRUMASTER" , "VRU_USRAPR" , __cUserID )
						oModVRU:LoadValue( "VRUMASTER" , "VRU_MOTIVO" , aMotivo[1] )
						If oModVRU:VldData()
							oModVRU:CommitData()
						EndIf
						oModVRU:DeActivate()
					EndIf
					FreeObj(oModVRU)
					//
					If cAprRep == "1" // 1 - Aprovar Solicitação
						//
						cQuery := "SELECT VRU_STATUS "
						cQuery += "  FROM " + RetSqlName("VRU")
						cQuery += " WHERE VRU_FILIAL = '" + VRU->VRU_FILIAL + "'"
						cQuery += "   AND VRU_CODVRR = '" + VRU->VRU_CODVRR + "'"
						cQuery += "   AND VRU_ATIVO  = '1'"
						cQuery += "   AND D_E_L_E_T_ = ' '"
						cQuery += "   AND VRU_TIPSOL = "
						For nCntFor := 1 to 2
							cStatus += FM_SQL( cQuery + "'" + strzero(nCntFor,1) + "' ORDER BY VRU_CODIGO DESC" )
						Next
						DbSelectArea("VRU")
						If !("0" $ cStatus) // NAO existe Solicitação Pendente
							If !("2" $ cStatus) // NAO Existe Solicitação Reprovada
								OA4700011_GravaStatusSaida( VRU->VRU_CODVRR , "4" ) // Mudar o VRR_STATUS 4-Liberado para Efetivar Saida
							EndIf
						EndIf
						//
					Else // 2 - Reprovar Solicitação
						//
						OA4700011_GravaStatusSaida( VRU->VRU_CODVRR , "5" ) // Mudar o VRR_STATUS 5-Liberação de Pendências Reprovada
						//
						DbSelectArea("VRU")
						nRecVRU := VRU->(RecNo())
						OA4710051_DesativarSolicitacoes( VRU->VRU_FILIAL , VRU->VRU_CODVRR , VRU->(RecNo()) ) // Marcar 0=NAO ATIVO para todas as Solicitações da Saida VRR
						VRU->( DbGoTo( nRecVRU ) )
						//
					EndIf
					//
				EndIf
				//
				END TRANSACTION
				//
			EndIf
		Case VRU->VRU_ATIVO == '1' .and. VRU->VRU_STATUS == '1' // ATIVOS - Aprovada
			MsgStop(STR0008,STR0002) // Solicitação já esta Aprovada. Impossível continuar. / Atenção
		Case VRU->VRU_ATIVO == '1' .and. VRU->VRU_STATUS == '2' // ATIVOS - Reprovada
			MsgStop(STR0009,STR0002) // Solicitação já esta Reprovada. Impossível continuar. / Atenção
	EndCase
Return

/*/{Protheus.doc} OA4710031_VisualizarSaida
Visualizar Saida

@author Andre Luis Almeida
@since 29/09/2022
@type function
/*/
Function OA4710031_VisualizarSaida()
Private cCadastro := STR0010 // Visualizar Saida
VRR->(DbSetOrder(1))
If VRR->(DbSeek(VRU->VRU_FILIAL+VRU->VRU_CODVRR))
	OA4700051_VisualizarSaida()
EndIf
Return

/*/{Protheus.doc} OA4710041_TelaPendencias
Tela de Pendencias para Solicitar Liberação

@author Andre Luis Almeida
@since 03/10/2022
@type function
/*/
Function OA4710041_TelaPendencias( aLimCre , aVlrMin , lSolicit )
Local aSizeAut   := MsAdvSize(.t.)
Local aObjects   := {}
Local aPosObj    := {}
Local aInfo      := {}
Local aRetTela   := {}
Local aNewBot    := {}
Local oVERDE     := LoadBitmap( GetResources() , "BR_VERDE" )
Local oVERMELHO  := LoadBitmap( GetResources() , "BR_VERMELHO" )
Local oFontTit   := TFont():New( "Arial", 10,20 )
Private cCadastro := STR0011 // Valor Desejado x Valor Minimo dos Serviços Especializados
Default aVlrMin  := {}
Default aLimCre  := {}
Default lSolicit := .t.
//
If lSolicit
	cCadastro := STR0012 // Solicitação de Liberação de Pendências para Saida de Serviços Especializados
EndIf
//
AADD( aNewBot , {"PMSCOLOR",{ || OA4710071_Legenda() } , STR0029 } ) // Legenda
//
If len(aLimCre)>0
	AAdd( aObjects, { 0 , 25 , .T. , .F. } ) // Titulo Cliente ( Limite de Crédito )
	AAdd( aObjects, { 0 , 45 , .T. , .F. } ) // Cliente ( Limite de Crédito )
Else
	AAdd( aObjects, { 0 ,  0 , .T. , .F. } ) // NAO deixa espaço para Titulo Cliente ( Limite de Crédito )
	AAdd( aObjects, { 0 ,  0 , .T. , .F. } ) // NAO deixa espaço para Cliente ( Limite de Crédito )
EndIf
If lSolicit
	AAdd( aObjects, { 0 , 25 , .T. , .F. } ) // Titulo Serviços Especializados ( Valor Minimo )
Else
	AAdd( aObjects, { 0 ,  0 , .T. , .F. } ) // NAO deixa espaço para Titulo Serviços Especializados ( Valor Minimo )
EndIf
AAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // Serviços Especializados ( Valor Minimo )
//
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }	// Tamanho total da tela
aPosObj := MsObjSize( aInfo, aObjects ) 										// Monta objetos conforme especificacoes
//
DEFINE MSDIALOG oDlgOA471 FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL STYLE DS_MODALFRAME
	oDlgOA471:lEscClose := .F.
	//
	oTPan1 := TPanel():New(aPosObj[1,1] ,aPosObj[1,2],"",oDlgOA471,NIL,.T.,.F.,NIL,NIL,aPosObj[1,4] - aPosObj[1,2], aPosObj[1,3] - aPosObj[1,1],.T.,.F.)
	oTPan2 := TPanel():New(aPosObj[2,1] ,aPosObj[2,2],"",oDlgOA471,NIL,.T.,.F.,NIL,NIL,aPosObj[2,4] - aPosObj[2,2], aPosObj[2,3] - aPosObj[2,1],.T.,.F.)
	oTPan3 := TPanel():New(aPosObj[3,1] ,aPosObj[3,2],"",oDlgOA471,NIL,.T.,.F.,NIL,NIL,aPosObj[3,4] - aPosObj[3,2], aPosObj[3,3] - aPosObj[3,1],.T.,.F.)
	oTPan4 := TPanel():New(aPosObj[4,1] ,aPosObj[4,2],"",oDlgOA471,NIL,.T.,.F.,NIL,NIL,aPosObj[4,4] - aPosObj[4,2], aPosObj[4,3] - aPosObj[4,1],.T.,.F.)
	//
	oTPan4:Align := CONTROL_ALIGN_BOTTOM
	oTPan3:Align := CONTROL_ALIGN_BOTTOM
	oTPan2:Align := CONTROL_ALIGN_BOTTOM
	oTPan1:Align := CONTROL_ALIGN_BOTTOM
	//
	If len(aLimCre) > 0
		If !aLimCre[1,1]
			aAdd(aRetTela,"1") // 1=Limite de Credito
		EndIf
		@ 010,010 SAY STR0013 Font oFontTit SIZE 300,10 OF oTPan1 PIXEL COLOR CLR_BLUE // Pendência de Limite de Crédito do Cliente OK
		oLbLimCre := TWBrowse():New( 1,1,100,100,,,,oTPan2,,,,{ || .t. } ,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
		oLbLimCre:addColumn( TCColumn():New( ""      , { || IIf(aLimCre[oLbLimCre:nAt,1],oVERDE,oVERMELHO) } ,,,, "LEFT" ,  05 ,.T.,.F.,,,,.F.,) )
		oLbLimCre:addColumn( TCColumn():New( STR0014 , { || aLimCre[oLbLimCre:nAt,02]                      } ,,,, "LEFT" ,  60 ,.F.,.F.,,,,.F.,) ) // Cliente
		oLbLimCre:addColumn( TCColumn():New( STR0015 , { || aLimCre[oLbLimCre:nAt,03]                      } ,,,, "LEFT" , 200 ,.F.,.F.,,,,.F.,) ) // Nome
		oLbLimCre:nAt := 1
		oLbLimCre:SetArray(aLimCre)
		oLbLimCre:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf
	//
	If ASCAN( aVlrMin , {|i| i[1] == .f. }) <> 0
		aAdd(aRetTela,"2") // 2=Valor Minimo nos Serviços Especializados
	EndIf
	If lSolicit
		@ 010,010 SAY STR0011 Font oFontTit SIZE 300,10 OF oTPan3 PIXEL COLOR CLR_BLUE // Valor Desejado x Valor Minimo dos Serviços Especializados
	EndIf
	oLbVlrMin := TWBrowse():New( 1,1,100,100,,,,oTPan4,,,,{ || .t. } ,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
	oLbVlrMin:addColumn( TCColumn():New( ""      , { || IIf(aVlrMin[oLbVlrMin:nAt,1],oVERDE,oVERMELHO)              } ,,,, "LEFT" ,  05 ,.T.,.F.,,,,.F.,) )
	oLbVlrMin:addColumn( TCColumn():New( STR0016 , { || aVlrMin[oLbVlrMin:nAt,02]                                   } ,,,, "LEFT" ,  35 ,.F.,.F.,,,,.F.,) ) // Grupo
	oLbVlrMin:addColumn( TCColumn():New( STR0017 , { || aVlrMin[oLbVlrMin:nAt,03]                                   } ,,,, "LEFT" ,  80 ,.F.,.F.,,,,.F.,) ) // Código do Serviço
	oLbVlrMin:addColumn( TCColumn():New( STR0018 , { || aVlrMin[oLbVlrMin:nAt,04]                                   } ,,,, "LEFT" , 140 ,.F.,.F.,,,,.F.,) ) // Descrição
	oLbVlrMin:addColumn( TCColumn():New( STR0019 , { || aVlrMin[oLbVlrMin:nAt,05]                                   } ,,,, "LEFT" ,  35 ,.F.,.F.,,,,.F.,) ) // Tipo
	oLbVlrMin:addColumn( TCColumn():New( STR0020 , { || Transform(aVlrMin[oLbVlrMin:nAt,08],"@E 999,999")           } ,,,, "RIGHT",  50 ,.F.,.F.,,,,.F.,) ) // Quantidade
	oLbVlrMin:addColumn( TCColumn():New( STR0021 , { || Transform(aVlrMin[oLbVlrMin:nAt,06],"@E 99,999,999,999.99") } ,,,, "RIGHT",  90 ,.F.,.F.,,,,.F.,) ) // Valor Minimo Permitido
	oLbVlrMin:addColumn( TCColumn():New( STR0022 , { || Transform(aVlrMin[oLbVlrMin:nAt,06]*aVlrMin[oLbVlrMin:nAt,08],"@E 99,999,999,999.99") } ,,,, "RIGHT", 90 ,.F.,.F.,,,,.F.,) ) // Total Minimo Permitido
	oLbVlrMin:addColumn( TCColumn():New( STR0023 , { || Transform(aVlrMin[oLbVlrMin:nAt,07],"@E 99,999,999,999.99") } ,,,, "RIGHT", 100 ,.F.,.F.,,,,.F.,) ) // Valor Desejado (com desconto)
	oLbVlrMin:addColumn( TCColumn():New( STR0024 , { || Transform(aVlrMin[oLbVlrMin:nAt,09],"@E 99,999,999,999.99") } ,,,, "RIGHT", 100 ,.F.,.F.,,,,.F.,) ) // Total Desejado (com desconto)
	oLbVlrMin:addColumn( TCColumn():New( STR0025 , { || Transform((aVlrMin[oLbVlrMin:nAt,06]-aVlrMin[oLbVlrMin:nAt,07])*aVlrMin[oLbVlrMin:nAt,08]*-1,"@E 999,999,999.99") } ,,,, "RIGHT", 70 ,.F.,.F.,,,,.F.,) ) // Diferença
	oLbVlrMin:addColumn( TCColumn():New( STR0026 , { || Transform(OA471009K_Calc_Percentual_Solicitado(aVlrMin, oLbVlrMin:nAt),"@E 9999.99")+" %" } ,,,, "RIGHT", 40 ,.F.,.F.,,,,.F.,) ) // % Diferença
	oLbVlrMin:nAt := 1
	oLbVlrMin:SetArray(aVlrMin)
	oLbVlrMin:Align := CONTROL_ALIGN_ALLCLIENT
	//
ACTIVATE MSDIALOG oDlgOA471 ON INIT EnchoiceBar(oDlgOA471,{ || oDlgOA471:End() }, { || ( aRetTela := {} , oDlgOA471:End() ) },,aNewBot)
//
Return aClone(aRetTela)

/*/{Protheus.doc} OA4710051_DesativarSolicitacoes
Gravar VRU_ATIVO = 0-NAO -> Desativar as Solicitacoes de Pendencias

@author Andre Luis Almeida
@since 05/10/2022
@type function
/*/
Function OA4710051_DesativarSolicitacoes( cFilVRR , cCodVRR , nRecVRU )
Local oModVRU
Local cQuery    := ""
Local cSQLAux   := "SQLAUX"
cQuery := "SELECT R_E_C_N_O_ AS RECVRU "
cQuery += "  FROM " + RetSqlName("VRU")
cQuery += " WHERE VRU_FILIAL = '" + cFilVRR + "'"
cQuery += "   AND VRU_CODVRR = '" + cCodVRR + "'"
cQuery += "   AND VRU_ATIVO  = '1'"
If nRecVRU <> 0
	cQuery += "   AND R_E_C_N_O_ <> "+Alltrim(str(nRecVRU))
EndIf
cQuery += "   AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAux , .F., .T. )
Do While !( cSQLAux )->( Eof() )
	If (cSQLAux)->( RECVRU ) > 0
		VRU->( DbGoTo( (cSQLAux)->( RECVRU ) ) )
		oModVRU := FWLoadModel( 'OFIA471' )
		oModVRU:SetOperation( MODEL_OPERATION_UPDATE )
		If oModVRU:Activate()
			oModVRU:LoadValue( "VRUMASTER" , "VRU_ATIVO " , "0" ) // Desativar o registro em aberto para gerar um novo no futuro.
			If oModVRU:VldData()
				oModVRU:CommitData()
			EndIf
			oModVRU:DeActivate()
		EndIf
		FreeObj(oModVRU)
	EndIf
	( cSQLAux )->( DbSkip() )
EndDo
( cSQLAux )->( dbCloseArea() )
DbSelectArea("VRU")
Return

/*/{Protheus.doc} OA4710061_DescricaoMotivo
Retorna a Descrição do Motivo

@author Andre Luis Almeida
@since 25/10/2022
@type function
/*/
Function OA4710061_DescricaoMotivo()
Local cQuery   := ""
Local cTipAss  := ""
Local cRetDesc := ""
If !Empty(VRU->VRU_MOTIVO)
	Do Case
		Case VRU->VRU_STATUS+VRU->VRU_TIPSOL == "11" // 1=Solicitação Aprovada / 1=Limite Crédito
			cTipAss := "000029" // APROVA SOL.LIM.CREDITO SERV.ESPECIALIZADO
		Case VRU->VRU_STATUS+VRU->VRU_TIPSOL == "12" // 1=Solicitação Aprovada / 2=Valor Minimo
			cTipAss := "000027" // APROVA SOL.VLR.MINIMO SERV.ESPECIALIZADO
		Case VRU->VRU_STATUS+VRU->VRU_TIPSOL == "21" // 1=Solicitação Reprovada / 1=Limite Crédito
			cTipAss := "000028" // REPROVA SOL.LIM.CREDITO SERV.ESPECIALIZADO
		Case VRU->VRU_STATUS+VRU->VRU_TIPSOL == "22" // 1=Solicitação Reprovada / 2=Valor Minimo
			cTipAss := "000030" // REPROVA SOL.VLR.MINIMO SERV.ESPECIALIZADO
	EndCase
	If !Empty(cTipAss)
		cQuery := "SELECT VS0_DESMOT"
		cQuery += "  FROM "+RetSqlName("VS0")
		cQuery += " WHERE VS0_FILIAL = '"+xFilial("VS0")+"'"
		cQuery += "   AND VS0_TIPASS = '"+cTipAss+"'"
		cQuery += "   AND VS0_CODMOT = '"+VRU->VRU_MOTIVO+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cRetDesc := FM_SQL(cQuery)
	EndIf
EndIf
Return Padr(cRetDesc,50)

/*/{Protheus.doc} OA471008K_Usuario_Possui_Alcada
	Função estática que valida se o usuário possui alçada para liberação do valor minimo,
	seja por alçada de % ou por Valor
	@type  Static Function
	@author Lucas Oliveira
	@since 15/04/2025
	@version version
	@param cUser, character, usuario logado
	@return lRet, logical, usuario possui alçada para liberação?
	@example
	(examples)
	@see (links_or_references)
/*/

Static Function OA471008K_Usuario_Possui_Alcada(cUser)

	Local 	lRet 	:= .F.
	Local 	lAlcPerc:= VRU->(FieldPos('VRU_PERSOL')) > 0 .and. VAI->(FieldPos('VAI_ALLPSE')) > 0
	Default cUser 	:=	__cUserID

	VAI->(Dbsetorder(4))
	If VAI->(DbSeek(xFilial("VAI")+__cUserID))

		If VAI->VAI_ALLBSE >= VRU->VRU_VLRSOL // Alçada de Valor Minimo do Servico Especializado
			lRet 	:= .T.
		ElseIf lAlcPerc
			If VAI->VAI_ALLPSE >= VRU->VRU_PERSOL // Alçada de % Minimo do Servico Especializado
				lRet 	:= .T.
			Endif
		Endif
	Endif

Return lRet

/*/{Protheus.doc} OA471009K_Calc_Percentual_Solicitado
	Função que retorna o calculo da diferença de percentual entre
	o valor solicitado e o valor mínimo
	@type  Static Function
	@author Lucas Oliveira
	@since 15/04/2025
	@version version
	@param aVlrMin, array, valores levantados
	@param nPos, numeric, posicao do array a ser calculado
	@return nPerDif, numeric, percentual entre o vlr solicitado e o valor mínimo
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA471009K_Calc_Percentual_Solicitado(aVlrMin, nPos)

	Local nPerDif 	:= 0

	Default	nPos	:= 0
	Default aVlrMin := {}

	If Len(aVlrMin) > 0 .and. nPos > 0
		nPerDif := (((aVlrMin[nPos,06]-aVlrMin[nPos,07])*aVlrMin[nPos,08])/(aVlrMin[nPos,06]*aVlrMin[nPos,08]))*100*-1
	Endif

Return nPerDif

/*/{Protheus.doc} OA4710071_Legenda
Legenda

@author Andre Luis Almeida
@since 28/10/2022
@type function
/*/
Function OA4710071_Legenda()

Local aLegenda  := {{ 'BR_VERDE'    , STR0027 } ,; // OK
					{ 'BR_VERMELHO' , STR0028 } }  // Pendencia

BrwLegenda(cCadastro,STR0029,aLegenda) //Legenda

Return
