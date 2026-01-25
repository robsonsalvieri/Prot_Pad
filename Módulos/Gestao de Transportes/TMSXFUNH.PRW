#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSXFUNH.CH"

#DEFINE RH_TOTPED 01
#DEFINE RH_LENVET 01

Static lTMChkObs  := ExistBlock("TMCHKOBS")
Static _cURLChk   := GetURLChk()	//-- URL Check-List
Static lDM0       := TableInDic("DM0")
Static cThreadNum := StrZero(ThreadId(),20)

/*/{Protheus.doc} TMSNFcECmp
Busca as notas fiscais a partir de um CTe
@author Valdemar Roberto Mognon
@since 30/07/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSNFcECmp(aChvCte)
Local aRet      := {}
Local aAreas    := {DT6->(GetArea()),GetArea()}
Local aVetWrk   := {}
Local cQuery    := ""
Local cAliasDTC := ""
Local nCntFor1  := 0

Default aChvCte := ""

//-- Mapa do vetor aRet
//-- 01 - Chave do CTe
//-- 02 - Vetor com as notas do CTe
//--      01 - Codigo do remetente
//--      02 - Loja do remetente
//--      03 - Numero da nota fiscal                                                                                                               l
//--      04 - Serie da nota fiscal
//--      05 - Data de emissao da nota fiscal
//--      06 - RECNO da nota fiscal (DTC)

If !Empty(aChvCte)
	For nCntFor1 := 1 To Len(aChvCte)
		DT6->(DbSetOrder(18))
		If DT6->(DbSeek(xFilial("DT6") + aChvCte[nCntFor1]))
			cAliasDTC := GetNextAlias()
			cQuery := "SELECT DISTINCT DTC_CLIREM,DTC_LOJREM,DTC_NUMNFC,DTC_SERNFC,DTC_EMINFC,DTC.R_E_C_N_O_ NUMREC "

			cQuery += "  FROM " + RetSqlName("DTC") + " DTC "

			cQuery += "  JOIN " + RetSqlName("DT6") + " DT6 "
			cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
			cQuery += "   AND DT6_CHVCTE = '" + aChvCte[nCntFor1] + "' "
			cQuery += "   AND DT6.D_E_L_E_T_ = ' '"

			cQuery += " WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
			cQuery += "   AND DTC_FILDOC = DT6_FILDOC "
			cQuery += "   AND DTC_DOC    = DT6_DOC "
			cQuery += "   AND DTC_SERIE  = DT6_SERIE "
			cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)

			aVetWrk := {}
					
			While (cAliasDTC)->(!Eof())
				Aadd(aVetWrk,{(cAliasDTC)->DTC_CLIREM,(cAliasDTC)->DTC_LOJREM,(cAliasDTC)->DTC_NUMNFC,(cAliasDTC)->DTC_SERNFC,;
							  (cAliasDTC)->DTC_EMINFC,(cAliasDTC)->NUMREC})
				(cAliasDTC)->(DbSkip())
			EndDo
			If !Empty(aVetWrk)
				Aadd(aRet,{aChvCte[nCntFor1],aVetWrk})
			EndIf
			(cAliasDTC)->(DbCloseArea())
		EndIf
	Next nCntFor1
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRet

/*/{Protheus.doc} TMSVldECmp
Valida a exclusão do evento de cancelamento do comprovante de entrega junto à SEFAZ
@author Valdemar Roberto Mognon
@since 30/07/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSVldECmp(aRecNFc,aChvCte)
Local aAreas    := {GetArea()}
Local aRet      := {}
Local aVetWrk   := {}
Local cQuery    := ""
Local cAliasDLY := ""
Local cAcaoDLY  := ""
Local nCntFor1  := 0
Local nCntFor2  := 0
Local lCondNFc  := .T.
Local lCondCte  := .T.

Default aRecNFc := {}
Default aChvCte := {}

//-- Mapa do vetor aRet
//-- 01 - Chave do CTe
//-- 02 - Condicao lógica de continuidade do processo de estorno da ocorrência do CTe no TMSA360(.T. ou .F.)
//-- 03 - Status do evento da DLY
//-- 04 - Vetor com as notas do CTe que recebeu a ocorrência
//--      01 - Codigo do remetente
//--      02 - Loja do remetente
//--      03 - Numero da nota fiscal
//--      04 - Serie da nota fiscal
//--      05 - Data de emissao da nota fiscal
//--      06 - RECNO do ultimo evento da nota fiscal (DLY)
//--      07 - Condição de estorno do evento da nota fiscal (.T. ou .F.)
//--      08 - Ação que deve ser tomada na tabela de eventos da nota fiscal (DLY) (0=Nenhuma Ação, 1=Exclui Registro ou 2=Gera Evento de Cancelamento)

If !Empty(aChvCte)
	aRecNFc := TMSNFcECmp(Aclone(aChvCte))
EndIf

If !Empty(aRecNFc)
	For nCntFor1 := 1 To Len(aRecNFc)

		aVetWrk  := {}
		lCondCte := .T.
		
		For nCntFor2 := 1 To Len(aRecNFc[nCntFor1,2])

			cAliasDLY := GetNextAlias()
			cQuery := " SELECT DLY1.DLY_TIPEVE,DLY1.DLY_STATUS,DLY1.R_E_C_N_O_ ULTIMO1"

			cQuery += "  FROM " + RetSqlName("DLY") + " DLY1 "

			cQuery += " WHERE DLY1.DLY_FILIAL = '" + xFilial("DLY") + "' "
			cQuery += "   AND DLY1.R_E_C_N_O_ = (SELECT MAX(DLY2.R_E_C_N_O_) ULTIMO2 "
			cQuery += "                            FROM " + RetSqlName("DLY") + " DLY2 "
			cQuery += "                           WHERE DLY2.DLY_FILIAL = '" + xFilial("DLY") + "' "
			cQuery += "                             AND DLY2.DLY_CLIREM = '" + aRecNFc[nCntFor1,2,nCntFor2,1] + "' "
			cQuery += "                             AND DLY2.DLY_LOJREM = '" + aRecNFc[nCntFor1,2,nCntFor2,2] + "' "
			cQuery += "                             AND DLY2.DLY_NUMNFC = '" + aRecNFc[nCntFor1,2,nCntFor2,3] + "' "
			cQuery += "                             AND DLY2.DLY_SERNFC = '" + aRecNFc[nCntFor1,2,nCntFor2,4] + "' "
			cQuery += "                             AND DLY2.DLY_EMINFC = '" + aRecNFc[nCntFor1,2,nCntFor2,5] + "' "
			cQuery += "                             AND DLY2.D_E_L_E_T_ = ' ')
			cQuery += "   AND DLY1.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY)

			While (cAliasDLY)->(!Eof())

				lCondNFc := .T.
				cAcaoDLY := ""
				//-- Se for um registro de Envio com status 1-nao apto ou 2-apto permite cancelar.
				//-- Já que se for a primeira transmissão não existe na sefaz e se for do tipo cancelamento
				//-- segue para a próxima validação.
				If (cAliasDLY)->DLY_STATUS $ "12" .And. (cAliasDLY)->DLY_TIPEVE == "1"
					lCondNFc := .T.
					cAcaoDLY := "1"	//-- Exclui Registro
				//-- Se for um registro de Cancelamento e o status for 1-nao apto ou 2-apto, não permite
				//-- cancelar porque o registro de cancelamento não altorizando considerando assim o ultimo
				//-- registro que é de envio e está autorizado.
				ElseIf (cAliasDLY)->DLY_STATUS $ "12" .And. (cAliasDLY)->DLY_TIPEVE == "2"
					lCondNFc := .F. //-- não permite estornar a ocorrencia
					cAcaoDLY := "0" //-- não faz nada
				ElseIf (cAliasDLY)->DLY_STATUS $ "3"	//-- Transmitido
					lCondNFc := .F.
					cAcaoDLY := "0"	//-- Nenhuma Acao
				ElseIf (cAliasDLY)->DLY_STATUS $ "4" .And. (cAliasDLY)->DLY_TIPEVE == "1"	//-- Autorizado - Envio
					lCondNFc := .F.
					cAcaoDLY := "2"	//-- Gera Evento de Cancelamento
				ElseIf (cAliasDLY)->DLY_STATUS $ "4" .And. (cAliasDLY)->DLY_TIPEVE == "2"	//-- Autorizado - Cancelamento na SEFAZ
					lCondNFc := .T.
					cAcaoDLY := "0"	//-- Nenhuma Ação \ não gera DLY
				ElseIf (cAliasDLY)->DLY_STATUS $ "5" .And. (cAliasDLY)->DLY_TIPEVE == "1"	//-- Rejeitado - Envio
					lCondNFc := .T.
					cAcaoDLY := "0"	//-- Nenhuma Ação \ não gera DLY
				ElseIf (cAliasDLY)->DLY_STATUS $ "5" .And. (cAliasDLY)->DLY_TIPEVE == "2"	//-- Rejeitado - Cancelamento
					lCondNFc := .F.
					cAcaoDLY := "0"	//-- Nenhuma Acao
				EndIf

				Aadd(aVetWrk,{aRecNFc[nCntFor1,2,nCntFor2,1],aRecNFc[nCntFor1,2,nCntFor2,2],aRecNFc[nCntFor1,2,nCntFor2,3],;
							  aRecNFc[nCntFor1,2,nCntFor2,4],aRecNFc[nCntFor1,2,nCntFor2,5],(cAliasDLY)->ULTIMO1,lCondNFc,cAcaoDLY})
				If lCondCte .And. !lCondNFc
					lCondCte := .F.
				EndIf
				(cAliasDLY)->(DbSkip())
			EndDo
			(cAliasDLY)->(DbCloseArea())

		Next nCntFor2

		If !Empty(aVetWrk)
			Aadd(aRet,{aRecNFc[nCntFor1,1],lCondCte,,aVetWrk})
		EndIf

	Next nCntFor1
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRet

/*/{Protheus.doc} TMSCanECmp
Exclusão do evento de cancelamento do comprovante de entrega junto à SEFAZ
@author Valdemar Roberto Mognon
@since 30/07/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSCanECmp(aRecNFc,cTipCan)
Local aAreas   := {DLY->(GetArea()),GetArea()}
Local aEventos := {}
Local nCntFor1 := 0
Local nCntFor2 := 0

Default aRecNFc := {}
Default cTipCan := ""

If !Empty(aRecNFc)
	For nCntFor1 := 1 To Len(aRecNFc)
		For nCntFor2 := 1 To Len(aRecNFc[nCntFor1,4])

			If aRecNFc[nCntFor1,2] .Or. (!aRecNFc[nCntFor1,2] .And. aRecNFc[nCntFor1,4,nCntFor2,8] == "2")	//-- Pode estornar a ocorrência do CTe ou
				//-- Não pode estornar porém gera DLY de cancelamento

				If (aRecNFc[nCntFor1,4,nCntFor2,7] .And. aRecNFc[nCntFor1,4,nCntFor2,8] != "0") .Or. (!aRecNFc[nCntFor1,4,nCntFor2,7] .And. aRecNFc[nCntFor1,4,nCntFor2,8] == "2") //-- Pode estornar o evento da nota fiscal, 
					//-- e existe ação a ser feita
					DLY->(DbGoTo(aRecNFc[nCntFor1,4,nCntFor2,6]))
					If aRecNFc[nCntFor1,4,nCntFor2,8] == "1" .And. cTipCan == "2"	//-- Exclui Registro
						aRecNFc[nCntFor1,3] := DLY->DLY_STATUS

						RecLock("DLY",.F.)
						DLY->(DbDelete())
						DLY->(MsUnlock())
					ElseIf aRecNFc[nCntFor1,4,nCntFor2,8] == "2"	//-- Gera Evento de Cancelamento
						aRecNFc[nCntFor1,3] := DLY->DLY_STATUS

						aEventos := {}
						Aadd(aEventos,{"DLY_CLIREM",DLY->DLY_CLIREM,Nil})
						Aadd(aEventos,{"DLY_LOJREM",DLY->DLY_LOJREM,Nil})
						Aadd(aEventos,{"DLY_NUMNFC",DLY->DLY_NUMNFC,Nil})
						Aadd(aEventos,{"DLY_SERNFC",DLY->DLY_SERNFC,Nil})
						Aadd(aEventos,{"DLY_EMINFC",DLY->DLY_EMINFC,Nil})
						Aadd(aEventos,{"DLY_TIPEVE",StrZero(2,Len(DLY->DLY_TIPEVE)),Nil})	//-- Cancelamento
						Aadd(aEventos,{"DLY_TIPCAN",cTipCan        ,Nil})	//-- 0=Não se Aplica, 1=Manual ou 2=Automático
						Aadd(aEventos,{"DLY_STATUS",StrZero(2,Len(DLY->DLY_TIPEVE)),Nil})	//-- Apto
						Aadd(aEventos,{"DLY_NFEID ",DLY->DLY_NFEID ,Nil})
						Aadd(aEventos,{"DLY_CHVCTE",DLY->DLY_CHVCTE,Nil})
						Aadd(aEventos,{"DLY_RECEBE",DLY->DLY_RECEBE,Nil})
						Aadd(aEventos,{"DLY_DOCREC",DLY->DLY_DOCREC,Nil})
						Aadd(aEventos,{"DLY_DIRIMG",DLY->DLY_DIRIMG,Nil})
						Aadd(aEventos,{"DLY_DATENT",DLY->DLY_DATENT,Nil})
						Aadd(aEventos,{"DLY_HORENT",DLY->DLY_HORENT,Nil})
						If DLY->(ColumnPos("DLY_FILDOC")) > 0 .And. DLY->(ColumnPos("DLY_DOC")) > 0 .And. DLY->(ColumnPos("DLY_SERIE")) > 0
							Aadd(aEventos,{"DLY_FILDOC",DLY->DLY_FILDOC,Nil})
							Aadd(aEventos,{"DLY_DOC"   ,DLY->DLY_DOC   ,Nil})
							Aadd(aEventos,{"DLY_SERIE" ,DLY->DLY_SERIE ,Nil})
						EndIf
						TMSIncDLY(aEventos)
					EndIf
				EndIf
			EndIf
		Next nCntFor2
	Next nCntFor1
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRecNFc
/*/-----------------------------------------------------------
{Protheus.doc} TMSIncDLY()
Inclui o registro na DLY de acordo com o array passado

@author Daniel Leme
@since 01/08/2019
-----------------------------------------------------------/*/
Function TMSIncDLY(aDados,nOpcx)
Local cChvCTe := ""
Local cCliRem := ""
Local cLojRem := ""
Local cNumNFc := ""
Local cSerNFc := ""
Local dEmiNFc := CToD("")
Local cSeqDLY := ""
Local lGrava  := .F.
Local aAreaDM0:= {}

Default aDados	:= {}
Default nOpcx 	:= 3

If nOpcx == 3
	cChvCTe := aDados[Ascan(aDados,{|x| x[1] == "DLY_CHVCTE"}),2]
	cCliRem := aDados[Ascan(aDados,{|x| x[1] == "DLY_CLIREM"}),2]
	cLojRem := aDados[Ascan(aDados,{|x| x[1] == "DLY_LOJREM"}),2]
	cNumNFc := aDados[Ascan(aDados,{|x| x[1] == "DLY_NUMNFC"}),2]
	cSerNFc := aDados[Ascan(aDados,{|x| x[1] == "DLY_SERNFC"}),2]
	dEmiNFc := aDados[Ascan(aDados,{|x| x[1] == "DLY_EMINFC"}),2]
	cSeqDLY := TMSSeqDLY( cChvCTe, cCliRem, cLojRem, cNumNFc, cSerNFc, dEmiNFc )

	RecLock("DLY",.T.)
	DLY->DLY_FILIAL := xFilial("DLY")
	DLY->DLY_SEQEVE := cSeqDLY
ElseIf DLY->(!Eof())
	RecLock("DLY",.F.)
ElseIf DLY->(Eof()) 
	RestArea(aAreaDM0)
	Return Nil
EndIf

If nOpcx != 5
	aEval(aDados,{|x| Iif( !(AllTrim(x[1]) $ "DLY_FILIAL|DLY_SEQEVE"), DLY->(FieldPut(FieldPos(x[1]),x[2])), Nil) })
Else
	DLY->(DbDelete())
Endif

DLY->(MSUnlock())

//-- Atualiza o status da DLY de 0 para 2 quando da atualização da DLY vindo do Check List
//-- É alteração
//-- Os campos de Recebedor, Documento do Recebedor e Imagem estão preenchidos
//-- O status da DLY é 0=Integração
If nOpcx == 4 .And. !Empty(DLY->DLY_RECEBE) .And. !Empty(DLY->DLY_DOCREC) .And. DLY->DLY_STATUS == "1"
	If !lDM0 .And. !Empty(DLY->DLY_DIRIMG)
		lGrava := .T.
	ElseIf lDM0
		aAreaDM0 := DM0->(GetArea())
		DM0->(DbSetOrder(1))
		If DM0->(DbSeek(xFilial("DM0") + DLY->(DLY_FILDOC + DLY_DOC + DLY_SERIE))) .And. !Empty(DM0->DM0_EXTENS)
			lGrava := .T.
			RestArea(aAreaDM0)
		EndIf
	EndIf
	If lGrava
		RecLock("DLY",.F.)
		DLY->DLY_STATUS := "2"
		DLY->(MsUnlock())
	EndIf
EndIf

Return Nil

/*/-----------------------------------------------------------
{Protheus.doc} TMSSeqDLY()
Retorna a próxima sequencia de uma chave na tabela DLY

@author Daniel Leme
@since 30/07/2019
-----------------------------------------------------------/*/
Static Function TMSSeqDLY(cChvCte,cCliRem,cLojRem,cNumNfc,cSerNfc,dEmiNfc)
Local cRet   := StrZero(1,Len(DLY->DLY_SEQEVE))
Local aArea  := GetArea()
Local cQuery := ""
Local cAlias := GetNextAlias()

cQuery := " SELECT MAX(DLY_SEQEVE) DLY_SEQEVE"
cQuery += " FROM " + RetSqlName("DLY") + " DLY "
cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "'"
cQuery += "   AND DLY.DLY_CLIREM = '" + cCliRem + "'"
cQuery += "   AND DLY.DLY_LOJREM = '" + cLojRem + "'"
cQuery += "   AND DLY.DLY_NUMNFC = '" + cNumNfc + "'"
cQuery += "   AND DLY.DLY_SERNFC = '" + cSerNfc + "'"
cQuery += "   AND DLY.DLY_EMINFC = '" + DtoS(dEmiNfc) + "'"
cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

If (cAlias)->(!Eof()) .And. !Empty((cAlias)->DLY_SEQEVE)
	cRet := Soma1((cAlias)->DLY_SEQEVE)
EndIf

(cAlias)->(DbCloseArea())

RestArea(aArea)

Return cRet

/*/{Protheus.doc} TMSPrcCmp
Processa comprovante de entrega para envio ao TSS
@author Valdemar Roberto Mognon
@since 06/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSPrcCmp(aChvCTe)
Local aAreas    := {GetArea()}
Local aDadosCmp := {}
Local cQuery    := ""
Local cAliasDLY := ""
Local nCntFor1  := 0

Local lStaDM0   := DM0->(ColumnPos("DM0_STATUS")) > 0
Local cNomRec   := ""
Local cDocRec   := ""
Local lLatLong  := DM0->(ColumnPos("DM0_LATITU")) > 0 .And. DM0->(ColumnPos("DM0_LONGIT")) > 0
Local cLatitude := ""
Local cLongitit := ""
Default aChvCTe := {}

If !Empty(aChvCTe)
	For nCntFor1 := 1 To Len(aChvCTe)
		cAliasDLY := GetNextAlias()
		cQuery := "SELECT DLY.* "
		
		    cQuery += ", DM0.R_E_C_N_O_ DM0_RECNO "

		If lStaDM0
			cQuery += ", DM0.DM0_NOMRES, DM0.DM0_DOCRES "
		EndIf
		If lLatLong
			cQuery += ", DM0.DM0_LATITU, DM0.DM0_LONGIT "
		EndIf
		
		cQuery += "  FROM " + RetSqlName("DLY") + " DLY "

            cQuery += " INNER JOIN " + RetSqlName("DM0") + " DM0 "
            cQuery += "   ON DM0.DM0_FILDOC = DLY.DLY_FILDOC "
            cQuery += "   AND DM0.DM0_DOC = DLY.DLY_DOC "
            cQuery += "   AND DM0.DM0_SERIE = DLY.DLY_SERIE "
            cQuery += "   AND DM0.DM0_FILIAL = '" + xFilial("DM0") + "' "
            cQuery += "   AND DM0.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
		cQuery += "   AND DLY.DLY_CHVCTE = '" + aChvCTe[nCntFor1] + "' "
		cQuery += "   AND DLY.DLY_STATUS = '2' "
		cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY)

		TCSetField(cAliasDLY,"DLY_EMINFC","D",8,0)
		TCSetField(cAliasDLY,"DLY_DATENV","D",8,0)
		TCSetField(cAliasDLY,"DLY_DATENT","D",8,0)

		aDadosCmp := {}
		
			DM0->(DbGoTo((cAliasDLY)->DM0_RECNO))
		
		While (cAliasDLY)->(!Eof())
			If lStaDM0
				cNomRec := If( Empty( (cAliasDLY)->DM0_NOMRES ), (cAliasDLY)->DLY_RECEBE, (cAliasDLY)->DM0_NOMRES )
				cDocRec := If( Empty( (cAliasDLY)->DM0_DOCRES ), (cAliasDLY)->DLY_DOCREC, (cAliasDLY)->DM0_DOCRES )
			Else
				cNomRec := (cAliasDLY)->DLY_RECEBE
				cDocRec := (cAliasDLY)->DLY_DOCREC
			EndIf
			If lLatLong
				cLatitude := AllTrim(Str(Val(AllTrim((cAliasDLY)->DM0_LATITU)),10,6))
				cLongitit := AllTrim(Str(Val(AllTrim((cAliasDLY)->DM0_LONGIT)),11,6))
			EndIf
			Aadd(aDadosCmp,{(cAliasDLY)->DLY_CLIREM,(cAliasDLY)->DLY_LOJREM,(cAliasDLY)->DLY_NUMNFC,(cAliasDLY)->DLY_SERNFC,;
							(cAliasDLY)->DLY_EMINFC,(cAliasDLY)->DLY_SEQEVE,(cAliasDLY)->DLY_DATENV,(cAliasDLY)->DLY_HORENV,;
							(cAliasDLY)->DLY_TIPEVE,(cAliasDLY)->DLY_TIPCAN,(cAliasDLY)->DLY_STATUS,(cAliasDLY)->DLY_IDREVE,;
							(cAliasDLY)->DLY_RETEVE,(cAliasDLY)->DLY_NFEID ,(cAliasDLY)->DLY_CHVCTE,cNomRec,;
							cDocRec,IIf(!lDM0, (cAliasDLY)->DLY_DIRIMG, DM0->DM0_IMAGEM),(cAliasDLY)->DLY_DATENT,(cAliasDLY)->DLY_HORENT,;
							(cAliasDLY)->DLY_PROTOC, cLatitude, cLongitit } )
			(cAliasDLY)->(DbSkip())
		EndDo
		(cAliasDLY)->(DbCloseArea())

		If !Empty(aDadosCmp)
			TMSEnvCmp(Aclone(aDadosCmp),aDadosCmp[1,9])
		EndIf
	Next nCntFor1
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return

/*/{Protheus.doc} TMSEnvCmp
Envia XML de comprovante de entrega ao TSS
@author Valdemar Roberto Mognon
@since 06/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSEnvCmp(aDadosCmp,cTipo)
Local aAreas    := {DT6->(GetArea()),GetArea()}
Local aCTe      := {}
Local cXML      := ""
Local cIdEnt    := ""
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cErro     := ""
Local cRetorno  := ""
Local cQuery    := ""
Local cIdEven   := ""
Local lUsaColab := UsaColaboracao("2")
Local lRetorno  := .F.

Local cHshImg   := ""
Local cFilVia   := ""
Local cNumVia   := ""
Local lTemVia   := DLY->(ColumnPos("DLY_FILORI") > 0) .And. DLY->(ColumnPos("DLY_VIAGEM") > 0) .And. DLY->(ColumnPos("DLY_HSHIMG") > 0)

If CTIsReady(,,,lUsaColab)
	cIdEnt := RetIdEnti(lUsaColab)
EndIf

If !Empty(cIdEnt)

	cXML := TMSXMLCmp(Aclone(aDadosCmp),cTipo,cIdEnt,lUsaColab,.T.,@aCTe,@cHshImg)

	If lUsaColab
		If ColEnvEvento("CEC",aCte,cXML,@cIdEven,@cErro,,,.T.,,Iif(cTipo == "1",.F.,.T.))
			lRetorno := .T.
		EndIf
	Else
		// Chamado do método e envio
		oWs:= WsNFeSBra():New()
		oWs:cUserToken	:= "TOTVS"
		oWs:cID_ENT		:= cIdEnt
		oWs:cXML_LOTE	:= cXML
		oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
	
		If oWs:RemessaEvento()
			If Type("oWS:oWsRemessaEventoResult:cString") <> "U"
				lRetorno := .T.
			EndIf
		Else
			cErro	:= IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		Endif

		If !lRetorno
			cRetorno := STR0001 + CRLF + CRLF	//-- "Houve erro durante a transmissão para o Totvs Services SPED."
			cRetorno += cErro
		EndIf
	EndIf
	
	If lRetorno
		DT6->(DbSetOrder(18))	//-- DT6_FILIAL + DT6_CHVCTE
		If DT6->(DbSeek(xFilial("DT6") + aDadosCmp[1,15]))
			cFilVia := DT6->DT6_FILVGA
			cNumVia := DT6->DT6_NUMVGA
		EndIf
		//-- Atualiza a DLY
		cQuery := " UPDATE " + RetSqlName("DLY") + CRLF
		cQuery += "    SET DLY_DATENV = '" + DToS(dDataBase) + "', " + CRLF
		cQuery += "        DLY_HORENV = '" + SubStr(Time(),1,2) + SubStr(Time(),4,2) + "', " + CRLF
		cQuery += "        DLY_STATUS = '3' " + CRLF
		If lTemVia
			cQuery += "    , DLY_FILORI = '" + cFilVia + "' "
			cQuery += "    , DLY_VIAGEM = '" + cNumVia + "' "
			cQuery += "    , DLY_HSHIMG = '" + cHshImg + "' "
		EndIf
		cQuery += "  WHERE DLY_FILIAL = '" + xFilial("DLY") + "' " + CRLF
		cQuery += "    AND DLY_CHVCTE = '" + aDadosCmp[1,15] + "' " + CRLF
		cQuery += "    AND DLY_STATUS = '2' "
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		TCSqlExec(cQuery)
	EndIf

Else
	Aviso("SPED","Atenção",{STR0002},3)	//-- "Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
Endif

aEval(aAreas,{|xArea| RestArea(xArea)})

Return

/*/{Protheus.doc} TMSXMLCmp
Monta XML de comprovante de entrega
@author Valdemar Roberto Mognon
@since 06/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSXMLCmp(aDadosCmp,cTipo,cIdEnt,lUsaColab,lReady,aCTe,cHash)
Local aAreas    := {DT6->(GetArea()),SF2->(GetArea()),DLY->(GetArea()),GetArea()}
Local aUF       := {}
Local cCnpj     := SM0->M0_CGC
Local cUF       := Upper(Left(LTrim(SM0->M0_ESTENT),2))
Local cRet      := ""
Local cRetNF    := "" 
Local cDatEnt   := ""
Local cDatHsh   := ""
Local cError    := ""
Local cModel    := "57"
Local cAmbiente := ""
Local dDataEnt  := ""
Local cHoraEnt  := ""
Local cVerLayout:= ""
Local cVerLayEven := ""
Local cVerEven  := ""
Local cCodOrgao := ""
Local cEvento   := ""
Local nCntFor1  := 0
Local nPosUf    := 0
Local lHVerao	:= SuperGetMv("MV_HVERAO",,.F.)

Default aDadosCmp := {}
Default cTipo     := ""
Default cIdEnt    := ""
Default lUsaColab := UsaColaboracao("2")
Default lReady    := .F.

If !Empty(aDadosCmp)

	If lUsaColab
		//-- Dados do CTe
		DT6->(DbSetOrder(18))	//-- DT6_FILIAL + DT6_CHVCTE
		DT6->(DbSeek(xFilial("DT6") + AllTrim(aDadosCmp[1,15])))
		SF2->(DbSetOrder(1))	//-- F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
		SF2->(DbSeek(DT6->(DT6_FILORI + DT6_DOC + DT6_SERIE)))
		aCTe := {SF2->F2_CHVNFE,;	//-- 01-Chave da Nfe
				 SF2->(RECNO()),;	//-- 02-Recno 
				 SF2->F2_SERIE ,;	//-- 03-Serie
				 SF2->F2_DOC}		//-- 04-Cte

		//-- Parâmetros de integração
		cAmbiente   := ColGetPar("MV_AMBICTE","")
		cVerLayout  := ColGetPar("MV_VLAYCTE","3.00")
		cVerLayEven := ColGetPar("MV_EVENCTE","3.00")
		cVerEven    := ColGetPar("MV_LAYOCTE","3.00")

		//-- Sequencia do evento do CTe
		cSeqEven := ColSeqCCe(aCte)
		If cSeqEven == "00"
			cSeqEven := "01"
		EndIf

		//-- Data do Evento
		cDatEve := TMSConvDat(dDataBase,SubStr(Time(),1,2) + SubStr(Time(),4,2),cIdEnt)

		//-- Tabela do IBGE
		aUf := SpedTabIBGE()

		//-- Codigo do Orgão
		nPosUf := aScan(aUf,{|x| Upper(x[1]) == cUF})
		If nPosUf > 0
			cCodOrgao := aUf[nPosUf][4]
		EndIf

		//-- Montagem do ID do evento
		cEvento := "ID" + Iif(cTipo == "1","110180","110181") + AllTrim(aDadosCmp[1,15]) + cSeqEven

		//-- Monta início do XML
		cRet := '<?xml version="1.0" encoding="UTF-8"?>'
		cRet += '<eventoCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVerLayEven + '">'
		cRet +=		'<infEvento Id="' + cEvento + '">'
		cRet +=			'<cOrgao>' + cCodOrgao + '</cOrgao>'
		cRet += 		'<tpAmb>' + cAmbiente + '</tpAmb>'
		cRet += 		'<CNPJ>' + cCnpj + '</CNPJ>'
		cRet +=			'<chCTe>' + AllTrim(aDadosCmp[1,15]) + '</chCTe>'
		cRet += 		'<dhEvento>' + cDatEve + '</dhEvento>'
		cRet += 		'<tpEvento>' + Iif(cTipo == "1","110180","110181") + '</tpEvento>'
		cRet += 		'<nSeqEvento>' + cValToChar(Val(cSeqEven)) + '</nSeqEvento>'
		cRet += 		'<detEvento versaoEvento="' + cVerEven + '">'

		//-- Monta corpo do XML
		If cTipo == "1"	//-- Envio do Comprovante de Entrega
			cDatEnt  := TMSConvDat(aDadosCmp[1,19],aDadosCmp[1,20],cIdEnt)
			cDatHsh  := TMSConvDat(dDataBase,SubStr(Time(),1,2) + SubStr(Time(),4,2),cIdEnt)
			cHash    := TMSMntHsh(aDadosCmp[1,15],aDadosCmp[1,18])	//-- Chave eletrônica do CTe e nomer do arquivo de imagem
			cRet += 		'<evCECTe>'
			cRet += 			'<descEvento>' + 'Comprovante de Entrega do CT-e' + '</descEvento>'
			cRet += 			'<nProt>' + AllTrim(DT6->DT6_PROCTE) + '</nProt>'
			cRet += 			'<dhEntrega>' + AllTrim(cDatEnt) + '</dhEntrega>'
			cRet += 			'<nDoc>' + AllTrim(aDadosCmp[1,17]) + '</nDoc>'
			cRet += 			'<xNome>' + AllTrim(aDadosCmp[1,16]) + '</xNome>'
			cRet += 			'<hashEntrega>' + AllTrim(cHash) + '</hashEntrega>'
			cRet += 			'<dhHashEntrega>' + AllTrim(cDatHsh) + '</dhHashEntrega>'
			cRet += 			'<infEntrega>'

			For nCntFor1 := 1 To Len(aDadosCmp)
				If !Empty(aDadosCmp[nCntFor1,14])
					cRet += 		'<chNFe>' + AllTrim(aDadosCmp[nCntFor1,14]) + '</chNFe>'
				EndIf
			Next nCntFor1

			cRet += 			'</infEntrega>'
			cRet += 		'</evCECTe>'

		ElseIf cTipo == "2"	//-- Envio do Cancelamento do Comprovante de Entrega
			DLY->(DbSetOrder(1))
			DLY->(DbSeek(xFilial("DLY") + aDadosCmp[1,1] + aDadosCmp[1,2] + aDadosCmp[1,3] + aDadosCmp[1,4] + DToS(aDadosCmp[1,5]) + ;
										  StrZero(Val(aDadosCmp[1,6]) - 1,Len(DLY->DLY_SEQEVE))))

			cRet += 		'<evCancCECTe>'
			cRet += 			'<descEvento>Cancelamento do Comprovante de Entrega do CT-e</descEvento>'
			cRet += 			'<nProt>' + AllTrim(DT6->DT6_PROCTE) + '</nProt>'
			cRet += 			'<nProtCE>' + AllTrim(DLY->DLY_PROTOC) + '</nProtCE>'
			cRet += 		'</evCancCECTe>'

		EndIf

		cRet += 		'</detEvento>'
		cRet += 	'</infEvento>'
		cRet += '</eventoCTe>'

	Else

		cAmbiente := getCfgAmbiente(@cError, cIdEnt, cModel)

		If Empty(cError)			 
			If cTipo == "1"	//-- Envio do Comprovante de Entrega
				cDatEnt := TMSConvDat(aDadosCmp[1,19],aDadosCmp[1,20],cIdEnt)
				
				//--considerando fusos de cada estado.
				DateTimeFS(/*cUF*/, lHVerao,@dDataEnt,@cHoraEnt)
				cDatHsh := TMSConvDat(dDataBase,cHoraEnt,cIdEnt)

				cHash   := TMSMntHsh(aDadosCmp[1,15],aDadosCmp[1,18])	//-- Chave eletrônica do CTe e nomer do arquivo de imagem
				cRet := "<envEvento>"
				cRet += 	"<eventos>"
				cRet += 		"<detEvento>"
				cRet += 			"<tpEvento>110180</tpEvento>"
				cRet += 			"<chnfe>" + AllTrim(aDadosCmp[1,15]) + "</chnfe>"
				cRet += 			"<ambiente>" + AllTrim(cAmbiente) + "</ambiente>"
				cRet += 			"<comprovanteEntrega>"
				cRet += 				"<docIdent>" + AllTrim(aDadosCmp[1,17]) + "</docIdent>"
				cRet += 				"<dhEntrega>" + AllTrim(cDatEnt) + "</dhEntrega>"
				cRet += 				"<nomeIdent>" + AllTrim(aDadosCmp[1,16]) + "</nomeIdent>"
				If !Empty(aDadosCmp[1,22]) .And. !Empty(aDadosCmp[1,23])
					cRet += 			"<latitude>" + AllTrim(aDadosCmp[1,22])+ "</latitude>"
					cRet += 			"<longitude>" + AllTrim(aDadosCmp[1,23]) + "</longitude>"
				EndIf
				cRet += 				"<hashEntrega>" + AllTrim(cHash) + "</hashEntrega>"
				cRet += 				"<dhHashEntrega>" + AllTrim(cDatHsh) + "</dhHashEntrega>"
				
				For nCntFor1 := 1 To Len(aDadosCmp)
					If !Empty(aDadosCmp[nCntFor1,14])
						cRetNF += 	"<nfe>" + AllTrim(aDadosCmp[nCntFor1,14]) + "</nfe>"
					EndIf
				Next nCntFor1
				If !Empty(cRetNF)
					cRet += "<nfes>"
					cRet +=       cRetNF
					cRet += "</nfes>"
				EndIf
				
				cRet += 			"</comprovanteEntrega>"
				cRet += 		"</detEvento>"
				cRet += 	"</eventos>"
				cRet += "</envEvento>"
			ElseIf cTipo == "2"	//-- Envio do Cancelamento do Comprovante de Entrega
				DLY->(DbSetOrder(1))
				DLY->(DbSeek(xFilial("DLY") + aDadosCmp[1,1] + aDadosCmp[1,2] + aDadosCmp[1,3] + aDadosCmp[1,4] + DToS(aDadosCmp[1,5]) + ;
											  StrZero(Val(aDadosCmp[1,6]) - 1,Len(DLY->DLY_SEQEVE))))
				cRet := "<envEvento>"
				cRet += 	"<eventos>"
				cRet += 		"<detEvento>"
				cRet += 			"<tpEvento>110181</tpEvento>"
				cRet += 			"<chnfe>" + AllTrim(aDadosCmp[1,15]) + "</chnfe>"
				cRet += 			"<ambiente>" + AllTrim(cAmbiente) + "</ambiente>"
				cRet += 			"<cancComprovanteEntrega>"
				cRet += 				"<protCE>" + AllTrim(DLY->DLY_PROTOC) + "</protCE>"
				cRet += 			"</cancComprovanteEntrega>"
				cRet += 		"</detEvento>"
				cRet += 	"</eventos>"
				cRet += "</envEvento>"
			EndIf
		EndIf
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return cRet

/*/{Protheus.doc} TMSConvDat
Converte data e hora para formato de envio à SEFAZ
@author Valdemar Roberto Mognon
@since 06/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSConvDat(dData,cHora,cIdEnt)
Local cRet      := ""
Local cFuso     := ""

Default dData  := CToD("")
Default cHora  := ""
Default cIdEnt := ""

If !Empty(dData) .And. !Empty(cHora)
	If !Empty(cIdEnt)
		cFuso := TMS73TZUTC(cIdEnt)
	Else
		cFuso := "-00:00"
	EndIf
	
	cRet := SubStr(DToS(dData),1,4) + "-" + SubStr(DToS(dData),5,2) + "-" + SubStr(DToS(dData),7,2) + "T" + SubStr(cHora,1,2) + ":" + ;
			SubStr(cHora,3,2) + ":00" + cFuso
EndIf

Return cRet

/*/{Protheus.doc} TMSConvUTC
Converte data e hora para formato de envio ao App CheckList
@author Rodrigo Pirolo
@since 21/05/2021
@version 12.1.25
@return caracter
@param 
@type function
/*/

Static Function TMSConvUTC(dData,cHora,cIdEnt)

Local cRet      := ""

Default dData  := CToD("")
Default cHora  := ""
Default cIdEnt := ""

If !Empty(dData) .And. !Empty(cHora)
	
	If !(":" $ cHora) .AND. Len(cHora) == 4
		cHora := SubStr( cHora, 1, 2 ) + ":" + SubStr( cHora, 3, 2 ) + ":00"
	EndIf

	cRet := FWTimeStamp(5, dData, cHora)
		
EndIf

Return cRet

/*/{Protheus.doc} TMSRefCmp
Busca status do comprovante de entrega
@author Valdemar Roberto Mognon
@since 07/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSRefCmp(aVetEnv,aVetCan)
Local aAreas    := {GetArea()}
Local aRet      := {}
Local aDLY      := {}
Local lUsaColab := UsaColaboracao("2")
Local cIdEnt    := ""
Local cQuery    := ""
Local cAliasDLY := ""
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cErro     := ""
Local cAviso    := ""
Local nCntFor1  := 0
Local oWs
Local oDados
Local oMonEvt   := NIL
Local oEvento
Local oXMLRet
Local nX		:= 0
Local aDocs		:= {}
//-- Variaveis de retorno Totvs Colaboração
Local cStatEven  := ""
Local cMotEven   := ""
Local cProtocolo := ""
Local cTpEvento  := ""

Default aVetEnv := {}
Default aVetCan := {}

// Verifica se a entidade foi configurada
If CTIsReady(,,,lUsaColab)
	cIdEnt := RetIdEnti(lUsaColab)
EndIf

If !Empty(cIdEnt)

	If lUsaColab

		If !Empty(aVetEnv)
			aVetEnv := ASort(aVetEnv,,,{|x,y| x < y})

			DT6->(DbSetOrder(18))
			
			For nCntFor1 := 1 To Len(aVetEnv)
				FwFreeObj(oEvento)

				If DT6->(DbSeek(xFilial("DT6") + aVetEnv[nCntFor1]))
					oEvento := ColaboracaoDocumentos():new()
					oEvento:cModelo	 := "CEC"
					oEvento:cTipoMov := "1"
					oEvento:cIdErp   := DT6->DT6_SERIE + DT6->DT6_DOC + FWGrpCompany() + FWCodFil()
			
					If oEvento:consultar()
						If !Empty(oEvento:cXMLRet)
							cXmlRet := oEvento:cXMLRet
							oXmlRet := XmlParser(cXmlRet,"_",@cAviso,@cErro)
							If ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_CSTAT) == "O" .And. ;
							   ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_XMOTIVO) == "O" .And. ;
							   ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_NPROT) == "O" .And. ;
							   ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_TPEVENTO) == "O"
								cStatEven  := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_CSTAT:TEXT)
								cMotEven   := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_XMOTIVO:TEXT)
								cProtocolo := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_NPROT:TEXT)
								cTpEvento  := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_TPEVENTO:TEXT)

								If cTpEvento == "110180"
									//-- Gera novo evento caso ocorra recusa
									If cStatEven != "135"
										cAliasDLY := GetNextAlias()
										cQuery := "SELECT * "
										cQuery += "  FROM " + RetSqlName("DLY") + " DLY "
										cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
										cQuery += "   AND DLY.DLY_CHVCTE = '" + aVetEnv[nCntFor1] + "' "
										cQuery += "   AND DLY.DLY_STATUS = '3' "
										cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
										cQuery := ChangeQuery(cQuery)
										DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY)
		
										TcSetField(cAliasDLY,"DLY_EMINFC","D",8,0)
										TCSetField(cAliasDLY,"DLY_DATENV","D",8,0)
										TcSetField(cAliasDLY,"DLY_DATENT","D",8,0)
		
										While (cAliasDLY)->(!Eof())
											aDLY := {}
											aAdd(aDLY, {"DLY_CLIREM", (cAliasDLY)->DLY_CLIREM, Nil })
											aAdd(aDLY, {"DLY_LOJREM", (cAliasDLY)->DLY_LOJREM, Nil })
											aAdd(aDLY, {"DLY_NUMNFC", (cAliasDLY)->DLY_NUMNFC, Nil })
											aAdd(aDLY, {"DLY_SERNFC", (cAliasDLY)->DLY_SERNFC, Nil })
											aAdd(aDLY, {"DLY_EMINFC", (cAliasDLY)->DLY_EMINFC, Nil })
											aAdd(aDLY, {"DLY_STATUS", "2"                    , Nil }) //-- 1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
											aAdd(aDLY, {"DLY_IDREVE", ""                     , Nil })
											aAdd(aDLY, {"DLY_RETEVE", ""                     , Nil })
											aAdd(aDLY, {"DLY_NFEID" , (cAliasDLY)->DLY_NFEID , Nil })
											aAdd(aDLY, {"DLY_CHVCTE", (cAliasDLY)->DLY_CHVCTE, Nil })
											aAdd(aDLY, {"DLY_TIPEVE", "1"                    , Nil }) //-- 1=Envio;2=Cancelamento
											aAdd(aDLY, {"DLY_TIPCAN", "0"                    , Nil }) //-- 0=Não se Aplica;1=Manual;2=Automático
											aAdd(aDLY, {"DLY_DATENT", (cAliasDLY)->DLY_DATENT, Nil })
											aAdd(aDLY, {"DLY_HORENT", (cAliasDLY)->DLY_HORENT, Nil })
											aAdd(aDLY, {"DLY_RECEBE", (cAliasDLY)->DLY_RECEBE, Nil })
											aAdd(aDLY, {"DLY_DOCREC", (cAliasDLY)->DLY_DOCREC, Nil })
											aAdd(aDLY, {"DLY_DIRIMG", (cAliasDLY)->DLY_DIRIMG, Nil })
											If DLY->(ColumnPos("DLY_FILDOC")>0) .And. DLY->(ColumnPos("DLY_DOC")>0) .And. DLY->(ColumnPos("DLY_SERIE")>0)
												aAdd(aDLY, {"DLY_FILDOC", (cAliasDLY)->DLY_FILDOC, Nil })
												aAdd(aDLY, {"DLY_DOC"   , (cAliasDLY)->DLY_DOC   , Nil })
												aAdd(aDLY, {"DLY_SERIE" , (cAliasDLY)->DLY_SERIE , Nil })
											EndIf
											//-- Inclui os dados na tabela DLY
											TMSIncDLY(aDLY)
											(cAliasDLY)->(DbSkip())
										EndDo
										(cAliasDLY)->(DbCloseArea())
									EndIf

									//-- Atualiza a DLY
									cQuery := " UPDATE " + RetSqlName("DLY") + CRLF
									cQuery += "    SET DLY_STATUS = '" + Iif(cStatEven == "135","4","5") + "', " + CRLF
									cQuery += "        DLY_IDREVE = '" + AllTrim(cStatEven) + "', " + CRLF
									cQuery += "        DLY_RETEVE = '" + PadR(StrTran(cMotEven,"'",""),GetSX3Cache("DLY_RETEVE","X3_TAMANHO")) + "', " + CRLF
									cQuery += "        DLY_PROTOC = '" + Iif(cProtocolo == "0","",AllTrim(cProtocolo)) + "' " + CRLF
									cQuery += "  WHERE DLY_FILIAL = '" + xFilial("DLY") + "' " + CRLF
									cQuery += "    AND DLY_CHVCTE = '" + aVetEnv[nCntFor1] + "' " + CRLF
									cQuery += "    AND DLY_STATUS = '3' "
									cQuery += "    AND D_E_L_E_T_ = ' ' "
									TCSqlExec(cQuery)
									
									If cStatEven == "135"
										TMXHComp( aVetEnv[nCntFor1] )
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next nCntFor1
		EndIf

		If !Empty(aVetCan)
			aVetCan := ASort(aVetCan,,,{|x,y| x < y})

			DT6->(DbSetOrder(18))

			For nCntFor1 := 1 To Len(aVetCan)
				FwFreeObj(oEvento)

				If DT6->(DbSeek(xFilial("DT6") + aVetCan[nCntFor1]))
					oEvento := ColaboracaoDocumentos():new()
					oEvento:cModelo	 := "CEC"
					oEvento:cTipoMov := "1"
					oEvento:cIdErp   := DT6->DT6_SERIE + DT6->DT6_DOC + FWGrpCompany() + FWCodFil()
			
					If oEvento:consultar()
						If !Empty(oEvento:cXMLRet)
							cXmlRet := oEvento:cXMLRet
							oXmlRet := XmlParser(cXmlRet,"_",@cAviso,@cErro)
							If ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_CSTAT) == "O" .And. ;
							   ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_XMOTIVO) == "O" .And. ;
							   ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_NPROT) == "O" .And. ;
							   ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_TPEVENTO) == "O"
								cStatEven  := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_CSTAT:TEXT)
								cMotEven   := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_XMOTIVO:TEXT)
								cProtocolo := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_NPROT:TEXT)
								cTpEvento  := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_TPEVENTO:TEXT)

								If cTpEvento == "110181"
									//-- Gera novo evento caso ocorra autorização
									If cStatEven == "135"
										cAliasDLY := GetNextAlias()
										cQuery := "SELECT * "
										cQuery += "  FROM " + RetSqlName("DLY") + " DLY "
										cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
										cQuery += "   AND DLY.DLY_CHVCTE = '" + aVetCan[nCntFor1] + "' "
										cQuery += "   AND DLY.DLY_STATUS = '3' "
										cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
										cQuery := ChangeQuery(cQuery)
										DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY)
		
										TcSetField(cAliasDLY,"DLY_EMINFC","D",8,0)
										TCSetField(cAliasDLY,"DLY_DATENV","D",8,0)
										TcSetField(cAliasDLY,"DLY_DATENT","D",8,0)
		
										While (cAliasDLY)->(!Eof())
											aDLY := {}
											aAdd(aDLY, {"DLY_CLIREM", (cAliasDLY)->DLY_CLIREM, Nil })
											aAdd(aDLY, {"DLY_LOJREM", (cAliasDLY)->DLY_LOJREM, Nil })
											aAdd(aDLY, {"DLY_NUMNFC", (cAliasDLY)->DLY_NUMNFC, Nil })
											aAdd(aDLY, {"DLY_SERNFC", (cAliasDLY)->DLY_SERNFC, Nil })
											aAdd(aDLY, {"DLY_EMINFC", (cAliasDLY)->DLY_EMINFC, Nil })
											aAdd(aDLY, {"DLY_STATUS", "2"                    , Nil }) //-- 1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
											aAdd(aDLY, {"DLY_IDREVE", ""                     , Nil })
											aAdd(aDLY, {"DLY_RETEVE", ""                     , Nil })
											aAdd(aDLY, {"DLY_NFEID" , (cAliasDLY)->DLY_NFEID , Nil })
											aAdd(aDLY, {"DLY_CHVCTE", (cAliasDLY)->DLY_CHVCTE, Nil })
											aAdd(aDLY, {"DLY_TIPEVE", "1"                    , Nil }) //-- 1=Envio;2=Cancelamento
											aAdd(aDLY, {"DLY_TIPCAN", "0"                    , Nil }) //-- 0=Não se Aplica;1=Manual;2=Automático
											aAdd(aDLY, {"DLY_DATENT", (cAliasDLY)->DLY_DATENT, Nil })
											aAdd(aDLY, {"DLY_HORENT", (cAliasDLY)->DLY_HORENT, Nil })
											aAdd(aDLY, {"DLY_RECEBE", (cAliasDLY)->DLY_RECEBE, Nil })
											aAdd(aDLY, {"DLY_DOCREC", (cAliasDLY)->DLY_DOCREC, Nil })
											
												aAdd(aDLY, {"DLY_DIRIMG", (cAliasDLY)->DLY_DIRIMG, Nil })
											
											If DLY->(ColumnPos("DLY_FILDOC")>0) .And. DLY->(ColumnPos("DLY_DOC")>0) .And. DLY->(ColumnPos("DLY_SERIE")>0)
												aAdd(aDLY, {"DLY_FILDOC", (cAliasDLY)->DLY_FILDOC, Nil })
												aAdd(aDLY, {"DLY_DOC"   , (cAliasDLY)->DLY_DOC   , Nil })
												aAdd(aDLY, {"DLY_SERIE" , (cAliasDLY)->DLY_SERIE , Nil })
												aAdd(aDocs, { (cAliasDLY)->DLY_FILDOC, (cAliasDLY)->DLY_DOC, (cAliasDLY)->DLY_SERIE } )
											EndIf
		
											//-- Inclui os dados na tabela DLY
											TMSIncDLY(aDLY)
											(cAliasDLY)->(DbSkip())
										EndDo
										(cAliasDLY)->(DbCloseArea())
									EndIf
		
									//-- Atualiza a DLY
									cQuery := " UPDATE " + RetSqlName("DLY") + CRLF
									cQuery += "    SET DLY_STATUS = '" + Iif(cStatEven == "135","4","5") + "', " + CRLF
									cQuery += "        DLY_IDREVE = '" + AllTrim(cStatEven) + "', " + CRLF
									cQuery += "        DLY_RETEVE = '" + PadR(StrTran(cMotEven,"'",""),GetSX3Cache("DLY_RETEVE","X3_TAMANHO")) + "', " + CRLF
									cQuery += "        DLY_PROTOC = '" + Iif(cProtocolo == "0","",AllTrim(cProtocolo)) + "' " + CRLF
									cQuery += "  WHERE DLY_FILIAL = '" + xFilial("DLY") + "' " + CRLF
									cQuery += "    AND DLY_CHVCTE = '" + aVetCan[nCntFor1] + "' " + CRLF
									cQuery += "    AND DLY_STATUS = '3' "
									cQuery += "    AND D_E_L_E_T_ = ' ' "
									TCSqlExec(cQuery)
									//-- Inclui novo registro da DLY para nova tentativa de transmissao
									If cStatEven != "135"
										aRet := TMSVldECmp({},aVetCan[nCntFor1])
										If !Empty(aRet)
											TMSCanECmp(aRet,"1")
										EndIf
									ElseIf cStatEven == "135"
										For nX := 1 To Len(aDocs)
											TM30AltStt( , 1, "NAO", aDocs[nX][1] + aDocs[nX][2] + aDocs[nX][3] )
										Next nX
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next nCntFor1
		EndIf
		
	Else

		If !Empty(aVetEnv)
			aVetEnv := ASort(aVetEnv,,,{|x,y| x < y})

			For nCntFor1 := 1 To Len(aVetEnv)
				// Executa o metodo NfeRetornaEvento()
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN	:= "TOTVS"
				oWS:cID_ENT		:= cIdEnt
				oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
				oWS:cEVENTO		:= "110180"
				oWS:cCHVINICIAL	:= aVetEnv[nCntFor1]
				oWS:cCHVFINAL	:= aVetEnv[nCntFor1]
				lOk := oWS:NFEMONITORLOTEEVENTO()
		
				If lOk		
					// Tratamento do retorno do evento			
					If ValType(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "U"
	
						oMonEvt := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento
						//-- Parece que quando o TSS não está atualizado(Schemas e RPO)
						//-- o objecto wsnfemonitorloteEventoResult vem vazio.
						If Empty(oMonEvt)
							Return Nil
						EndIf

						oDados  := oMonEvt[Len(oMonEvt)]
	
						If oDados:nTipoEvento == 110180
							//-- tag nSTATUS retornada pelo TSS (código interno)
						    // Status 1 - Recebido
							// Status 2 - Assinado
							// Status 3 - Erro, erro de schema
							// Status 4 - Consulta no governo - só foi transmitido
							// Status 5 - Rejeitado pelo governo - transmitido com retorno
							// Status 6 - Autorizado - transmitido com retorno
							If  oDados:nCSTATEVEN != 0 .And. oDados:nCSTATENV != 135 .And. oDados:nSTATUS > 4
								cAliasDLY := GetNextAlias()
								cQuery := "SELECT * "
								cQuery += "  FROM " + RetSqlName("DLY") + " DLY "
								cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
								cQuery += "   AND DLY.DLY_CHVCTE = '" + aVetEnv[nCntFor1] + "' "
								cQuery += "   AND DLY.DLY_STATUS = '3' "
								cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
								cQuery := ChangeQuery(cQuery)
								DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY)

								TcSetField(cAliasDLY,"DLY_EMINFC","D",8,0)
								TCSetField(cAliasDLY,"DLY_DATENV","D",8,0)
								TcSetField(cAliasDLY,"DLY_DATENT","D",8,0)

								While (cAliasDLY)->(!Eof())
									aDLY := {}
									aAdd(aDLY, {"DLY_CLIREM", (cAliasDLY)->DLY_CLIREM, Nil })
									aAdd(aDLY, {"DLY_LOJREM", (cAliasDLY)->DLY_LOJREM, Nil })
									aAdd(aDLY, {"DLY_NUMNFC", (cAliasDLY)->DLY_NUMNFC, Nil })
									aAdd(aDLY, {"DLY_SERNFC", (cAliasDLY)->DLY_SERNFC, Nil })
									aAdd(aDLY, {"DLY_EMINFC", (cAliasDLY)->DLY_EMINFC, Nil })
									aAdd(aDLY, {"DLY_STATUS", "2"                    , Nil }) //-- 1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
									aAdd(aDLY, {"DLY_IDREVE", ""                     , Nil })
									aAdd(aDLY, {"DLY_RETEVE", ""                     , Nil })
									aAdd(aDLY, {"DLY_NFEID" , (cAliasDLY)->DLY_NFEID , Nil })
									aAdd(aDLY, {"DLY_CHVCTE", (cAliasDLY)->DLY_CHVCTE, Nil })
									aAdd(aDLY, {"DLY_TIPEVE", "1"                    , Nil }) //-- 1=Envio;2=Cancelamento
									aAdd(aDLY, {"DLY_TIPCAN", "0"                    , Nil }) //-- 0=Não se Aplica;1=Manual;2=Automático
									aAdd(aDLY, {"DLY_DATENT", (cAliasDLY)->DLY_DATENT, Nil })
									aAdd(aDLY, {"DLY_HORENT", (cAliasDLY)->DLY_HORENT, Nil })
									aAdd(aDLY, {"DLY_RECEBE", (cAliasDLY)->DLY_RECEBE, Nil })
									aAdd(aDLY, {"DLY_DOCREC", (cAliasDLY)->DLY_DOCREC, Nil })
									
										aAdd(aDLY, {"DLY_DIRIMG", (cAliasDLY)->DLY_DIRIMG, Nil })
									
									If DLY->(ColumnPos("DLY_FILDOC")>0) .And. DLY->(ColumnPos("DLY_DOC")>0) .And. DLY->(ColumnPos("DLY_SERIE")>0)
										aAdd(aDLY, {"DLY_FILDOC", (cAliasDLY)->DLY_FILDOC, Nil })
										aAdd(aDLY, {"DLY_DOC"   , (cAliasDLY)->DLY_DOC   , Nil })
										aAdd(aDLY, {"DLY_SERIE" , (cAliasDLY)->DLY_SERIE , Nil })
									EndIf
									//-- Inclui os dados na tabela DLY
									TMSIncDLY(aDLY)
									(cAliasDLY)->(DbSkip())
								EndDo
								(cAliasDLY)->(DbCloseArea())
							EndIf

							//-- Atualiza a DLY
							If oDados:nSTATUS > 4 .And. oDados:nCSTATEVEN != 0
								cQuery := " UPDATE " + RetSqlName("DLY") + CRLF
								cQuery += "    SET DLY_STATUS = '" + Iif(oDados:nCSTATENV == 135,"4","5") + "', " + CRLF
								cQuery += "        DLY_IDREVE = '" + AllTrim(Str(oDados:nCSTATEVEN)) + "', " + CRLF
								cQuery += "        DLY_RETEVE = '" + PadR(StrTran(oDados:cCMOTEVEN,"'",""),GetSX3Cache("DLY_RETEVE","X3_TAMANHO")) + "', " + CRLF
								cQuery += "        DLY_PROTOC = '" + Iif(oDados:nPROTOCOLO == 0,"",AllTrim(Str(oDados:nPROTOCOLO))) + "' " + CRLF
								cQuery += "  WHERE DLY_FILIAL = '" + xFilial("DLY") + "' " + CRLF
								cQuery += "    AND DLY_CHVCTE = '" + aVetEnv[nCntFor1] + "' " + CRLF
								cQuery += "    AND DLY_STATUS = '3' "
								cQuery += "    AND D_E_L_E_T_ = ' ' "
								TCSqlExec(cQuery)
							EndIf

							If oDados:nCSTATENV == 135
								TMXHComp( aVetEnv[nCntFor1] )
							EndIf
						EndIf
					Endif
				EndIf
            Next nCntFor1

		EndIf

		If !Empty(aVetCan)
			aVetCan := ASort(aVetCan,,,{|x,y| x < y})

			For nCntFor1 := 1 To Len(aVetCan)
				// Executa o metodo NfeRetornaEvento()
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN	:= "TOTVS"
				oWS:cID_ENT		:= cIdEnt
				oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
				oWS:cEVENTO		:= "110181"
				oWS:cCHVINICIAL	:= aVetCan[nCntFor1]
				oWS:cCHVFINAL	:= aVetCan[nCntFor1]
				lOk := oWS:NFEMONITORLOTEEVENTO()
		
				If lOk		
					// Tratamento do retorno do evento			
					If ValType(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "U"
	
						oMonEvt := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento
						//-- Parece que quando o TSS não está atualizado(Schemas e RPO)
						//-- o objecto wsnfemonitorloteEventoResult vem vazio.
						If Empty(oMonEvt)
							Return Nil
						EndIf

						oDados  := oMonEvt[Len(oMonEvt)]
	
						If oDados:nTipoEvento == 110181
							If oDados:nCSTATENV == 135
								cAliasDLY := GetNextAlias()
								cQuery := "SELECT * "
								cQuery += "  FROM " + RetSqlName("DLY") + " DLY "
								cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
								cQuery += "   AND DLY.DLY_CHVCTE = '" + aVetCan[nCntFor1] + "' "
								cQuery += "   AND DLY.DLY_STATUS = '3' "
								cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
								cQuery := ChangeQuery(cQuery)
								DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY)

								TcSetField(cAliasDLY,"DLY_EMINFC","D",8,0)
								TCSetField(cAliasDLY,"DLY_DATENV","D",8,0)
								TcSetField(cAliasDLY,"DLY_DATENT","D",8,0)

								While (cAliasDLY)->(!Eof())
									aDLY := {}
									aAdd(aDLY, {"DLY_CLIREM", (cAliasDLY)->DLY_CLIREM, Nil })
									aAdd(aDLY, {"DLY_LOJREM", (cAliasDLY)->DLY_LOJREM, Nil })
									aAdd(aDLY, {"DLY_NUMNFC", (cAliasDLY)->DLY_NUMNFC, Nil })
									aAdd(aDLY, {"DLY_SERNFC", (cAliasDLY)->DLY_SERNFC, Nil })
									aAdd(aDLY, {"DLY_EMINFC", (cAliasDLY)->DLY_EMINFC, Nil })
									aAdd(aDLY, {"DLY_STATUS", "2"                    , Nil }) //-- 1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
									aAdd(aDLY, {"DLY_IDREVE", ""                     , Nil })
									aAdd(aDLY, {"DLY_RETEVE", ""                     , Nil })
									aAdd(aDLY, {"DLY_NFEID" , (cAliasDLY)->DLY_NFEID , Nil })
									aAdd(aDLY, {"DLY_CHVCTE", (cAliasDLY)->DLY_CHVCTE, Nil })
									aAdd(aDLY, {"DLY_TIPEVE", "1"                    , Nil }) //-- 1=Envio;2=Cancelamento
									aAdd(aDLY, {"DLY_TIPCAN", "0"                    , Nil }) //-- 0=Não se Aplica;1=Manual;2=Automático
									aAdd(aDLY, {"DLY_DATENT", (cAliasDLY)->DLY_DATENT, Nil })
									aAdd(aDLY, {"DLY_HORENT", (cAliasDLY)->DLY_HORENT, Nil })
									aAdd(aDLY, {"DLY_RECEBE", (cAliasDLY)->DLY_RECEBE, Nil })
									aAdd(aDLY, {"DLY_DOCREC", (cAliasDLY)->DLY_DOCREC, Nil })
									aAdd(aDLY, {"DLY_DIRIMG", (cAliasDLY)->DLY_DIRIMG, Nil })
									If DLY->(ColumnPos("DLY_FILDOC")>0) .And. DLY->(ColumnPos("DLY_DOC")>0) .And. DLY->(ColumnPos("DLY_SERIE")>0)
										aAdd(aDLY, {"DLY_FILDOC", (cAliasDLY)->DLY_FILDOC, Nil })
										aAdd(aDLY, {"DLY_DOC"   , (cAliasDLY)->DLY_DOC   , Nil })
										aAdd(aDLY, {"DLY_SERIE" , (cAliasDLY)->DLY_SERIE , Nil })
										aAdd(aDocs, { (cAliasDLY)->DLY_FILDOC, (cAliasDLY)->DLY_DOC, (cAliasDLY)->DLY_SERIE } )
									EndIf

									//-- Inclui os dados na tabela DLY
									TMSIncDLY(aDLY)
									(cAliasDLY)->(DbSkip())
								EndDo
								(cAliasDLY)->(DbCloseArea())
							EndIf

							//-- tag nSTATUS retornada pelo TSS (código interno)
						    // Status 1 - Recebido
							// Status 2 - Assinado - Não Transmitiu
							// Status 3 - Erro, erro de schema
							// Status 4 - Consulta no governo
							// Status 5 - Rejeitado pelo governo
							// Status 6 - Autorizado 
							//-- Atualiza a DLY
							If oDados:nSTATUS > 4
								cQuery := " UPDATE " + RetSqlName("DLY") + CRLF
								cQuery += "    SET DLY_STATUS = '" + Iif(oDados:nCSTATENV == 135,"4","5") + "', " + CRLF
								cQuery += "        DLY_IDREVE = '" + AllTrim(Str(oDados:nCSTATEVEN)) + "', " + CRLF
								cQuery += "        DLY_RETEVE = '" + PadR(StrTran(oDados:cCMOTEVEN,"'",""),GetSX3Cache("DLY_RETEVE","X3_TAMANHO")) + "', " + CRLF
								cQuery += "        DLY_PROTOC = '" + Iif(oDados:nPROTOCOLO == 0,"",AllTrim(Str(oDados:nPROTOCOLO))) + "' " + CRLF
								cQuery += "  WHERE DLY_FILIAL = '" + xFilial("DLY") + "' " + CRLF
								cQuery += "    AND DLY_CHVCTE = '" + aVetCan[nCntFor1] + "' " + CRLF
								cQuery += "    AND DLY_STATUS = '3' "
								cQuery += "    AND D_E_L_E_T_ = ' ' "
								TCSqlExec(cQuery)
								//-- Inclui novo registro da DLY para nova tentativa de transmissao
								If oDados:nCSTATENV != 135
									aRet := TMSVldECmp({},aVetCan[nCntFor1])
									If !Empty(aRet)
										TMSCanECmp(aRet,"1")
									EndIf
								ElseIf oDados:nCSTATENV == 135
									For nX := 1 To Len(aDocs)
										TM30AltStt( , 1, "NAO", aDocs[nX][1] + aDocs[nX][2] + aDocs[nX][3] )
									Next nX
								EndIf
							EndIf
						EndIf
					Endif
				EndIf
            Next nCntFor1
            
		EndIf

	EndIf
Else
	Aviso("SPED","Atenção",{STR0002},3)	//-- "Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return

/*/{Protheus.doc} TMSMntHsh
Busca status do comprovante de entrega
@author Valdemar Roberto Mognon
@since 07/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSMntHsh( cChvCte, cArquivo, lDNN, cBase64DNN )
Local nHeader := 0
Local nTam    := 0
Local cBuffer := ""
Local cRet    := ""
Local cBase64 := ""
Local cHash   := ""

Local aAreas  := {}

Default lDNN	:= .F.
Default cChvCte	:= ""
Default cArquivo:= ""

	aAreas := {DM0->(GetArea()),DTC->(GetArea()),DT6->(GetArea()),GetArea()}

If !Empty(cChvCte)
	//-- O sistema está gravando a imagem no banco de dados já em base64
		DT6->(DbSetOrder(18))	//-- DT6_FILIAL + DT6_CHVCTE
	If DT6->(DbSeek(xFilial("DT6") + cChvCte)) .AND. !lDNN
			DM0->(DbsetOrder(1))
			If DM0->(DbSeek(xFilial("DM0") + DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))
				cBase64 := DM0->DM0_IMAGEM
			EndIf
		EndIf
	
	If !lDM0 .Or. Empty(cBase64)	//-- O sistema está gravando o caminho de onde se localiza o arquivo de imagem
		If !Empty(cArquivo)
			//-- Abre e lê o arquivo de imagem
			nHeader := FOpen(cArquivo)
			//-- Pega o tamanho da imagem 
			nTam := FSeek(nHeader,0,2)
			FSeek(nHeader,0)
			FRead(nHeader,@cBuffer,nTam)
			FClose(nHeader)
		
			cBase64 := Encode64(cBuffer)
		EndIf
	EndIf

	If lDNN .AND. !Empty(cBase64DNN)
		cBase64 := cBase64DNN
	EndIf

	If !Empty(cBase64)	
		//-- Converte imagem para 64 e concatena com a chave eletrônica do CTe
		cBase64 := cChvCte + cBase64

		//-- Gera o SHA1 em binário (não Hexadecimal) 
		cHash := Sha1(cBase64,1) 
	
		//-- Converte o Hash em 64
		cRet := Encode64(cHash)
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return cRet

/*/{Protheus.doc} FDocApoio()
	(long_description)
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function FDocApoio(cDocTms)
 Local lResult  := .F.
 //Local aEspecie := {}
 Local cSerie   := ""
 Local cDocFat  := ""
		
		//-- Pesquisa DUI para verificar se o campo DUI_DOCFAT está preenchido
		DUI->(DbSetOrder(1))
		If DUI->(MsSeek(xFilial("DUI") + cDocTms))
			cSerie  := DUI->DUI_SERIE
			cDocFat := DUI->DUI_DOCFAT
		EndIf

		If !Empty(cDocFat)
			lResult := .T.
		EndIf
Return lResult

/*/{Protheus.doc} TMSLstChk
Busca documentos para envio ao aplicativo Meu Check-List
@author Valdemar Roberto Mognon
@since 21/10/2019
@version 12.1.25
@return Array
@param 
@type function
/*/

Function TMSLstChk( cFilOri, cViagem, cCHVCTE, cFilDoc, cDoc, cSerie, aSaiApoio )
Local cQuery    := ""
Local cAliasQry := ""
Local aAreas    := { DTC->(GetArea()) ,GetArea() }
Local aVetNom   := {}

Local cObserv	:= ""
Local nPosCli   := 0
Local nPosDoc   := 0
Local aCliente  := {}

Local lUsaCli   := .T.
Local nQTDVol   := 0
Local cNfsDocs  := ""
Local aParPE    := {}
Local aRetPE    := {}
Local n1, n2

Default cFilOri   := ""
Default cViagem   := ""
Default cCHVCTE   := ""
Default cFilDoc   := ""
Default cDoc	  := ""
Default cSerie	  := ""
DEFAULT aSaiApoio := {}

lUsaCli := !Empty(TMF10RtVge(cFilOri,cViagem,,,,2))

DTC->( DbSetOrder(3) )

//-- Mapa do vetor aVetNom
//-- 01-Nome do Solicitante/Remetente/Destinatário
//-- 02-Código do Solicitante/Remetente/Destinatário
//-- 03-Loja do Solicitante/Remetente/Destinatário
//-- 04-Vetor com os CTes/Coleta
//-- 04-01-Filial do Documento/Coleta
//-- 04-02-Número do Documento/Coleta
//-- 04-03-Série do Documento/Coleta
//-- 04-04-Chave Eletrônica do CTe/Coleta
//-- 04-05-Vetor com as Notas Fiscais do CTe
//-- 04-06-Observação (Nome/Endereço/QtdVol/Nfs)
//-- 04-07-Tipo de Documento
//-- 04-05-01-Código do Remetente
//-- 04-05-02-Loja do Remetente
//-- 04-05-03-Número da Nota Fiscal
//-- 04-05-04-Série da Nota Fiscal
//-- 04-05-05-Data de Emissão da Nota Fiscal
//-- 04-05-06-Chave Eletrônica da NFe

cAliasQry := GetNextAlias()

cQuery := "SELECT " + CRLF
cQuery += "DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE, DT6.DT6_CHVCTE, DT6.DT6_DOCTMS " + CRLF
If lUsaCli
	cQuery += "FROM " + RetSqlName("DLT") + " DLT " + CRLF
Else
	cQuery += "FROM " + RetSqlName("DUD") + " DUD " + CRLF
EndIf
cQuery += "INNER JOIN " + RetSqlName("DT6") + " DT6 " + CRLF
cQuery += "  ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' " + CRLF
If lUsaCli
	cQuery += " AND DT6.DT6_FILDOC = DLT.DLT_FILDOC " + CRLF
	cQuery += " AND DT6.DT6_DOC    = DLT.DLT_DOC " + CRLF
	cQuery += " AND DT6.DT6_SERIE  = DLT.DLT_SERIE " + CRLF
Else
	cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC " + CRLF
	cQuery += " AND DT6.DT6_DOC    = DUD.DUD_DOC " + CRLF
	cQuery += " AND DT6.DT6_SERIE  = DUD.DUD_SERIE " + CRLF
EndIf
If Len(aSaiApoio) > 0
	cQuery += " AND DT6.DT6_CLIREM = '" + aSaiApoio[1] + "' " + CRLF
	cQuery += " AND DT6.DT6_LOJREM = '" + aSaiApoio[2] + "' " + CRLF
	cQuery += " AND DT6.DT6_DOCTMS <> '1' " + CRLF
ElseIf !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
	cQuery += " AND DT6.DT6_FILDOC = '" + cFilDoc + "' " + CRLF
	cQuery += " AND DT6.DT6_DOC    = '" + cDoc + "' " + CRLF
	cQuery += " AND DT6.DT6_SERIE  = '" + cSerie + "' " + CRLF
ElseIf !Empty(cCHVCTE)
	cQuery += " AND DT6.DT6_CHVCTE = '" + cCHVCTE + "' " + CRLF
EndIf
cQuery += " AND DT6.D_E_L_E_T_ = ' '" + CRLF
If lUsaCli
	cQuery += "WHERE DLT_FILIAL = '" + xFilial("DLT") + "' " + CRLF
	cQuery += "AND DLT_FILORI = '" + cFilOri + "' " + CRLF
	cQuery += "AND DLT_VIAGEM = '" + cViagem + "' " + CRLF
	cQuery += "AND DLT_OPEDOC = '1' " + CRLF
	cQuery += "AND DLT.D_E_L_E_T_ = ' ' " + CRLF
Else
	cQuery += "WHERE DUD_FILIAL = '" + xFilial("DUD") + "' " + CRLF
	cQuery += "AND DUD_FILORI = '" + cFilOri + "' " + CRLF
	cQuery += "AND DUD_VIAGEM = '" + cViagem + "' " + CRLF
	cQuery += "AND DUD.D_E_L_E_T_ = ' ' " + CRLF
EndIf
If Len(aSaiApoio) > 0
	cQuery += "AND NOT EXISTS(SELECT 1 QTDE " + CRLF
	cQuery += "     FROM " + RetSqlName("DM0") + " DM0 " + CRLF
	cQuery += "     WHERE DM0_FILIAL = '" + xFilial("DM0") + "' " + CRLF
	cQuery += "     AND DM0.DM0_FILDOC = DT6.DT6_FILDOC " + CRLF
	cQuery += "     AND DM0.DM0_DOC = DT6.DT6_DOC " + CRLF
	cQuery += "     AND DM0.DM0_SERIE = DT6.DT6_SERIE " + CRLF
	cQuery += "     AND DM0.D_E_L_E_T_ = ' ' ) " + CRLF
EndIf

cQuery += "GROUP BY DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE, DT6.DT6_CHVCTE, DT6.DT6_DOCTMS " + CRLF
cQuery += "ORDER BY DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE, DT6.DT6_CHVCTE, DT6.DT6_DOCTMS " + CRLF

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry )

TcSetField( cAliasQry, "DTC_EMINFC", "D", 8, 0 )

While (cAliasQry)->(!Eof())

	(cAliasQry)->( aCliente := TMSDocEnd( DT6_FILDOC, DT6_DOC, DT6_SERIE )[1] )
    cObserv := "<br><b>"+aCliente[8]+"</b><br>"
	If (cAliasQry)->DT6_DOCTMS == StrZero(1,Len(DT6->DT6_DOCTMS))	//-- É uma coleta
		cObserv += "<i>Local Coleta:</i><br>"
	Else
		cObserv += "<i>Local Entrega:</i><br>"
	EndIf
	cObserv += aCliente[1] + "<br> " + aCliente[2] + "<br>" + aCliente[4] + " - " + aCliente[5] //--  Endereço, bairro, município, estado (retirado o CEP depois do Bairro)

	If ( nPosCli := AScan( aVetNom, {|x| x[2]+x[3] == aCliente[6] + aCliente[7] } ) ) == 0
		AAdd( aVetNom, { aCliente[8], aCliente[6], aCliente[7], {} } ) // Nome Reduzido, Codigo, Loja
		nPosCli := Len(aVetNom)
	EndIf

	(cAliasQry)->( Aadd( aVetNom[nPosCli][4], { DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_CHVCTE, {}, cObserv, DT6_DOCTMS } ) )
	nPosDoc := Len(aVetNom[nPosCli][4])

	If (cAliasQry)->DT6_DOCTMS == StrZero(1,Len(DT6->DT6_DOCTMS))	//-- Diferente de coleta Busca Notas Fiscais
        aVetNom[nPosCli][4][nPosDoc][6] += "<br><b>Coleta: " + (cAliasQry)->( DT6_DOC + "-" + DT6_SERIE ) + "</b>"
    Else
        aVetNom[nPosCli][4][nPosDoc][6] += "<br><b>Documento: " + (cAliasQry)->( DT6_DOC + "-" + DT6_SERIE ) + "</b>"

		cNfsDocs := ""
		nQTDVol  := 0

		DTC->( MsSeek(xFilial("DTC")+(cAliasQry)->(DT6_FILDOC+DT6_DOC+DT6_SERIE)) )
		While DTC->(!Eof()) .And. xFilial("DTC")+(cAliasQry)->(DT6_FILDOC+DT6_DOC+DT6_SERIE) == DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE)
			DTC->( Aadd( aVetNom[nPosCli][4][nPosDoc][5], { DTC_CLIREM,DTC_LOJREM,DTC_NUMNFC,DTC_SERNFC,DTC_EMINFC,DTC_NFEID } ) )
            cNfsDocs += DTC->( DTC_NUMNFC + "/" + DTC_SERNFC + ", " )
			nQTDVol  += DTC->DTC_QTDVOL
			DTC->( DbSkip() )
		EndDo
        aVetNom[nPosCli][4][nPosDoc][6] += "<br><b>Qtd. Volumes Total: " + AllTrim(Str(nQTDVol)) + "</b>"
		aVetNom[nPosCli][4][nPosDoc][6] += "<br><i>NF Cliente: " + cNfsDocs + "</i>"
	EndIf

	(cAliasQry)->(AAdd( aParPE, { DT6_FILDOC, DT6_DOC, DT6_SERIE, aVetNom[nPosCli][4][nPosDoc][6], nPosCli, nPosDoc } ) )
	(cAliasQry)->(DbSkip())

EndDo

If lTMChkObs
	aRetPE := ExecBlock( "TMCHKOBS", .F., .F., AClone(aParPE) )
	If Len(aRetPE) > 0
		For n1 := 1 To Len(aRetPE)
			If ( n2 := AScan( aParPE, {|x| x[1]+x[2]+x[3] == aRetPE[n1][1]+aRetPE[n1][2]+aRetPE[n1][3] } ) ) > 0
				nPosCli := aParPE[n2][5]
				nPosDoc := aParPE[n2][6]
				aVetNom[nPosCli][4][nPosDoc][6] := aRetPE[n1][4]
			EndIf
		Next
	EndIf
EndIf

(cAliasQry)->(DbCloseArea())

aEval(aAreas,{|xArea| RestArea(xArea)})

Return Aclone(aVetNom)

/*/{Protheus.doc} TMSEnvChk
Efetua o envio dos CTes para o Check List
@author Valdemar Roberto Mognon
@since 23/10/2019
@version 12.1.25
@return Array
@param 
@type function
/*/

Function TMSEnvChk( aLstChk, cFilOri, cViagem, aMsgChk, aReenvC, lSaiApoio )
Local aHeader   := {}
Local aRet      := {}
Local aAreas    := {DTW->(GetArea()),DA4->(GetArea()),DUP->(GetArea()),DTQ->(GetArea()),GetArea()}
Local aVetCHK   := {}
Local cDatIni   := ""
Local cDatFim   := ""
Local cToken    := ""
Local cIdCHK    := ""
Local cIdObj    := ""
Local cHasScr   := ""
Local cHasScrCol:= ""
Local cHasScrEnt:= ""
Local cHasObj   := ""
Local cHasCHK   := ""
Local cHasExe   := ""
Local cResScr   := ""
Local cResObj   := ""
Local cResCHK   := ""
Local cDocume   := ""
Local nCntFor1  := 0
Local nCntFor2  := 0
Local nRegDTW   := 0
Local oClient   := Nil
Local cDateTime := DtoS(Date()) + SubStr(StrTran(Time(),":",""),1,6)
Local lEnviado  := .F.
Local cRetChec	:= ""

Local lHaveScr  := DLZ->(ColumnPos("DLZ_SCRCOL")) > 0 .And. DLZ->(ColumnPos("DLZ_SCRENT")) > 0
Local lStaDM0   := DM0->(ColumnPos("DM0_STATUS")) > 0
Local cDM0Stat  := StrZero(1,Len(DM0->DM0_STATUS)) 

Default aLstChk := {}
Default cFilOri := ""
Default cViagem := ""
Default aMsgChk := {}
Default aReenvC := {}
DEFAULT lSaiApoio := .F.

If lSaiApoio
	cDM0Stat  := StrZero(3,Len(DM0->DM0_STATUS)) 
EndIf

oClient	:= FwRest():New(  _cURLChk + "/checklist/core/api" )

If Len(aLstChk) > 0 

	//-- Obtém ID do Motorista
	cHasExe		:= GetDriverID( cFilOri , cViagem )

	If Empty(cHasExe)
		MsgAlert(STR0003 + STR0005,STR0004)	//-- "Log in do executor não encontrado."#" Check-List não será gerado."#"Atenção!!!"
	Else

		nRegDTW := Tm351IdDTW(cFilOri,cViagem,2)
		DTW->(DbGoTo(nRegDTW))
	
		cDatIni := TMSConvUTC(dDataBase, Time() )
		cDatFim := TMSConvUTC(DTW->DTW_DATPRE,DTW->DTW_HORPRE)
		//cDatFim := TMSConvDat(DTW->DTW_DATPRE,DTW->DTW_HORPRE)

	
		//+----------------------------------------
		//| Gera Header para consumir a API
		//+----------------------------------------
		cToken := geraTokAPI()

		Aadd(aHeader, 'Content-Type: application/json')
		Aadd(aHeader, 'Authorization: Bearer ' + cToken)

		If lHaveScr
			//-- Gera Script Coleta
			cHasScrCol := TMSGerScr(oClient,@cResScr,aHeader,"COL")
			//-- Gera Script Entrega
			cHasScrEnt := TMSGerScr(oClient,@cResScr,aHeader,"ENT")
		Else
			//-- Gera Script
			cHasScr := TMSGerScr(oClient,@cResScr,aHeader)
		EndIf
	
		For nCntFor1 := 1 To Len(aLstChk)
			For nCntFor2 := 1 To Len(aLstChk[nCntFor1,4])
				If (aLstChk[ nCntFor1, 4, nCntfor2, 7 ] == "1" .And. !Empty(cHasScrCol)) .Or. ;
				   (aLstChk[ nCntFor1, 4, nCntfor2, 7 ] != "1" .And. !Empty(cHasScrEnt)) .Or. !Empty(cHasScr)

					//-- Monta os Identificadores de objetos e do check list
					cDocume := AllTrim(aLstChk[nCntFor1,4,nCntfor2,2]) //Numero documento
					cDocume += StrTran( AllTrim(aLstChk[nCntFor1,4,nCntfor2,3]), " ", "") //Serie sem Espacos
					cIdObj := StrTran( PadR(aLstChk[nCntFor1][1],24 - Len(cDocume),"_"), " ", "_") + "_" //Cliente (NREDUZ) com tamanho variando de acordo com o documento
					cIdObj += cDocume + "_" + cDateTime // Dcumento + YYYYMMDDHHmmss
					cIdCHK := AllTrim(cViagem) + "_" + cDocume + "_" + cDateTime

					//-- Gera Objeto
					cHasObj := TMSGerObj(oClient,cIdObj,@cResObj,aHeader, Iif( aLstChk[ nCntFor1, 4, nCntfor2, 7 ] == "1", "Coleta","Entrega" ) )
					
					If !Empty(cHasObj)
						//-- Gera Check List
						aVetCHK := TMSGerCHK(	oClient, ;
												cIdCHK, ;
												cHasObj, ;
												cDatIni, ;
												cDatFim, ;
												cHasExe, ;
												If( !Empty(cHasScr),cHasScr,Iif(AllTrim(aLstChk[nCntFor1,4,nCntfor2,3]) == "COL",cHasScrCol,cHasScrEnt) ), ;
												@cHasCHK, ;
												@cResCHK, ;
												aHeader, ;
												aLstChk[ nCntFor1, 4, nCntfor2, 1 ], ;
												aLstChk[ nCntFor1, 4, nCntfor2, 2 ], ;
												aLstChk[ nCntFor1, 4, nCntfor2, 3 ], ;
												cFilOri, ;
												cViagem, ;
												@lEnviado, ;
												aLstChk[ nCntFor1, 4, nCntfor2, 6 ],;
												@cRetChec, ;
												lSaiApoio )
						
						Aadd( aMsgChk, {	STR0010 + ;
											aLstChk[nCntFor1,4,nCntfor2,1] + "-" + ;
											aLstChk[nCntFor1,4,nCntfor2,2] + "-" + ;
											aLstChk[nCntFor1,4,nCntfor2,3] + ;
											If( lEnviado, STR0011, STR0012 + STR0022 + cRetChec ) } ) // STR0022 " Mensagem App Checklist: "
						
						If !lEnviado
							
							nPos := AScan( aReenvC, { |x| x[2] + x[3] == aLstChk[nCntFor1,2] + aLstChk[nCntFor1,3] } )

							If nPos == 0
								AAdd( aReenvC, { aLstChk[nCntFor1][1], aLstChk[nCntFor1][2], aLstChk[nCntFor1][3], { AClone( aLstChk[ nCntFor1 ][4][nCntfor2] ) } } )
							Else
								AAdd( aReenvC[nPos][4], AClone( aLstChk[ nCntFor1 ][4][nCntfor2] ) )
							EndIf

							nPos := 0
						EndIf

						If !Empty(aVetCHK)
							Aadd(aVetCHK, { "DM0_FILDOC", aLstChk[nCntFor1,4,nCntfor2,1], Nil } )
							Aadd(aVetCHK, { "DM0_DOC"   , aLstChk[nCntFor1,4,nCntfor2,2], Nil } )
							Aadd(aVetCHK, { "DM0_SERIE" , aLstChk[nCntFor1,4,nCntfor2,3], Nil } )
							If lStaDM0
								Aadd(aVetCHK,{"DM0_STATUS",cDM0Stat,Nil})
							EndIf
							Aadd( aRet, Aclone(aVetCHK) )
						EndIf

					Else
						Aadd( aMsgChk, {	STR0023 + ; //-- "Falha ao criar objeto: ["
											aLstChk[nCntFor1,4,nCntfor2,1] + "-" + ;
											aLstChk[nCntFor1,4,nCntfor2,2] + "-" + ;
											aLstChk[nCntFor1,4,nCntfor2,3] + ;
											STR0024 } ) //-- "] no portal checklist."
					EndIf
				EndIf
			Next nCntFor2
		Next nCntFor1
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRet

/*/{Protheus.doc} TMSVetChk
Monta o vetor base para inclusão da DLY a partir da viagem (TMSA310, TMSA350, Schedule)
@author Valdemar Roberto Mognon
@since 28/10/2019
@version 12.1.25
@return Array
@param 
@type function
/*/

Function TMSVetChk(aDocsChk,cFilOri,cViagem)
Local aRet     := {}
Local aDLY     := {}
Local aVetDoc  := {}
Local aVetNFc  := {}
Local nCntFor1 := 0
Local nCntFor2 := 0
Local nCntFor3 := 0
Local lExist   := .T.
Local dDataEnt := ""
Local cHoraEnt := ""
Local lHVerao	:= SuperGetMv("MV_HVERAO",,.F.)
Local lHasDLYDoc := TableInDic("DLY") .And. DLY->(ColumnPos("DLY_FILDOC")) > 0 .And. DLY->(ColumnPos("DLY_DOC")) > 0 .And. DLY->(ColumnPos("DLY_SERIE")) > 0
Local lHasDLYVia := TableInDic("DLY") .And. DLY->(ColumnPos("DLY_FILORI")) > 0 .And. DLY->(ColumnPos("DLY_VIAGEM")) > 0

Default aDocsChk := {}
Default cFilOri  := ""
Default cViagem  := ""

For nCntFor1 := 1 To Len(aDocsChk)	//-- Cliente
	aVetDoc := aDocsChk[nCntFor1,4]
	For nCntFor2 := 1 To Len(aVetDoc)	//-- Documentos
		aVetNfc := aVetDoc[nCntFor2,5]
		For nCntFor3 := 1 To Len(aVetNfc)	//-- Notas
			If ExistFunc("TMSVerDLY")
				lExist := TMSVerDLY(aVetDoc[nCntFor2,4]) //--cChvCTe
			EndIf

			If !lExist
				aDLY := {}
				//--Valida fuso horario de acordo com a filial logada.
				DateTimeFS(/*cUF*/,lHVerao,@dDataEnt,@cHoraEnt)
				
				Aadd(aDLY,{"DLY_CLIREM",aVetNfc[nCntFor3,1],Nil})
				Aadd(aDLY,{"DLY_LOJREM",aVetNfc[nCntFor3,2],Nil})
				Aadd(aDLY,{"DLY_NUMNFC",aVetNfc[nCntFor3,3],Nil})
				Aadd(aDLY,{"DLY_SERNFC",aVetNfc[nCntFor3,4],Nil})
				Aadd(aDLY,{"DLY_EMINFC",aVetNfc[nCntFor3,5],Nil})
				Aadd(aDLY,{"DLY_STATUS","1"                ,Nil})	//-- 1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
				Aadd(aDLY,{"DLY_IDREVE",""                 ,Nil})
				Aadd(aDLY,{"DLY_RETEVE",""                 ,Nil})
				Aadd(aDLY,{"DLY_NFEID" ,aVetNfc[nCntFor3,6],Nil})
				Aadd(aDLY,{"DLY_CHVCTE",aVetDoc[nCntFor2,4],Nil})
				Aadd(aDLY,{"DLY_TIPEVE","1"                ,Nil})	//-- 1=Envio;2=Cancelamento
				Aadd(aDLY,{"DLY_TIPCAN","0"                ,Nil})	//-- 0=Não se Aplica;1=Manual;2=Automático
				Aadd(aDLY,{"DLY_DATENT",dDataBase          ,Nil})
				Aadd(aDLY,{"DLY_IDINTG",""                 ,Nil})
				Aadd(aDLY,{"DLY_HORENT",cHoraEnt		   ,Nil})
				If lHasDLYDoc
					Aadd(aDLY,{"DLY_FILDOC",aVetDoc[nCntFor2,1],Nil})
					Aadd(aDLY,{"DLY_DOC"   ,aVetDoc[nCntFor2,2],Nil})
					Aadd(aDLY,{"DLY_SERIE" ,aVetDoc[nCntFor2,3],Nil})
				EndIf
				If lHasDLYVia
					Aadd(aDLY,{"DLY_FILORI",cFilOri,Nil})
					Aadd(aDLY,{"DLY_VIAGEM",cViagem,Nil})
				EndIf

				Aadd(aRet,aClone(aDLY))
			EndIf
		Next nCntFor3
	Next nCntFor2
Next nCntFor1

Return aRet

/*/{Protheus.doc} TMSIntChk
Controlador da integração entre TMS e CheckList
@author Daniel Carlos Leme
@since 24/10/2019
@version 12.1.25
@param 
@type function
/*/

Function TMSIntChk(cAcao,aVetDLY)
Local aAreas   := {DLY->(GetArea()),GetArea()}
Local aDocsDLY := {}
Local aDocsDM0 := {}
Local nCntFor1 := 0
Local nRegDLY  := 0
Local nRegDM0  := 0

Default cAcao   := ""
Default aVetDLY := {}

If cAcao == "1"	//-- Inclui registros na DLY a partir do TMSA310(Fechamento da viagem) e TMSA350(Apontamento de operações)
	For nCntFor1 := 1 To Len(aVetDLY)
		aDocsDLY := aVetDLY[nCntFor1]
		TMSIncDLY(Aclone(aDocsDLY),3)
	Next nCntFor1
ElseIf cAcao == "2"	//-- Inclui registros na DLY a partir do TMSA360(Registro de ocorrências)
	TMSIncDLY(Aclone(aVetDLY),3)
ElseIf cAcao == "3"	//-- Exclui registros da DLY
	nRegDLY  := aVetDLY[1,1]
	DLY->(DbGoTo(nRegDLY))
	TMSIncDLY(,5)
ElseIf cAcao == "4"	//-- Altera registros da DLY
	For nCntFor1 := 1 To Len(aVetDLY)
		nRegDLY  := aVetDLY[nCntFor1,1]
		aDocsDLY := aVetDLY[nCntFor1,2]
		If !Empty(aDocsDLY)
			DLY->(DbGoTo(nRegDLY))
			TMSIncDLY(Aclone(aDocsDLY),4)
		EndIf
	Next nCntFor1
ElseIf cAcao == "5"	//-- Altera registros da DM0
	nRegDM0  := aVetDLY[1]
	aDocsDM0 := aVetDLY[2]
	If !Empty(aDocsDM0)
		DM0->(DbGoTo(nRegDM0))
		TMSIncDM0(Aclone(aDocsDM0),4)
	EndIf
ElseIf cAcao == "6"	//-- Inclui registros da DM0
	TMSIncDM0(Aclone(aVetDLY),3)
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

aSize(aDocsDLY,0);aVetDoc := Nil

Return

/*/{Protheus.doc} TMSVerDLY
Verifica a existência do registro na DLY
@author Valdemar Roberto Mognon
@since 28/10/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSVerDLY(cChvCTe,cCliRem,cLojRem,cNumNFc,cSerNFc,dEmiNFc)
Local aAreas := {DLY->(GetArea()),GetArea()}
Local lRet		:= .T.
Local cAlias	:= ""
Local cQuery	:= ""
Default cChvCTe := ""
Default cCliRem := ""
Default cLojRem := ""
Default cNumNFc := ""
Default cSerNFc := ""
Default dEmiNFc := CToD("")

	//-- CHAVE 1 = DLY_FILIAL+DLY_CLIREM+DLY_LOJREM+DLY_NUMNFC+DLY_SERNFC+DTOS(DLY_EMINFC)+DLY_SEQEVE
	//-- CHAVE 2 = DLY_FILIAL+DLY_CHVCTE+DLY_NFEID
	cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName("DLY") + " WHERE "
	cQuery += " D_E_L_E_T_ = ' ' "
	cQuery += " AND DLY_FILIAL = '" + xFilial("DLY") + "' "
	cQuery += " AND DLY_CHVCTE = '" + cChvCTe + "' "
	cQuery += " AND DLY_CLIREM = '" + cCliRem + "' "
	cQuery += " AND DLY_LOJREM = '" + cLojRem + "' "
	cQuery += " AND DLY_NUMNFC = '" + cNumNFC + "' "
	cQuery += " AND DLY_SERNFC = '" + cSerNFc + "' "
	cQuery += " AND DLY_EMINFC = '" + DTOS(dEmiNfc) + "' "

	cQuery := ChangeQuery(cQuery)
	cAlias := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	lRet := !(cAlias)->(EOF())

aEval(aAreas,{|xArea| RestArea(xArea)})

Return lRet

/*/{Protheus.doc} geraTokAPI()
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function geraTokAPI()
Local cToken	:= ""

//-- filial + msblql + id
DLZ->(dbSetOrder(2))
If DLZ->( MsSeek( xFilial("DLZ") + "2" ))
	cToken	:=  TMSChkTok( DLZ->DLZ_ID , DLZ->DLZ_SECRET , DLZ->DLZ_TENANT , DLZ->DLZ_URLTOK , DLZ->DLZ_USER , DLZ->DLZ_PASSW , DLZ->DLZ_SEQUEN )[2]
EndIf

Return cToken 

/*/{Protheus.doc} TMSCHKLIST(cMethod,cPath,cQueryParam)
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param cMethod deve ser GET,POST,DELETE,PUT
    @param cPath informar o caminho da API que contem a função desejada por exemplo. 'checklists/'
    @param cQueryParam String no seguinte formado ?campo1=valor1&campo2=valor2&campo-n=valor-n
    @param nOrder ordem em que os dados serão apresentados ????
    @param nPage numero da pagina para filtro em pesquisa
    @param nPageSize define o tamanho 
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function TMSCHKLIST(cMethod,cPath,oJBody,cQueryParam,cPathParam,cHTTPCode,nOrder,nPage,nPageSize,cBaseURL,lImagem,lFoundatio,cVersGet)
Local cResJson   := ""

Default cMethod		:= ""
Default cPath		:= ""
Default oJBody   	:= NIL
Default cQueryParam := ""
Default cPathParam	:= ""
Default cHTTPCode	:= ""
Default nOrder		:= 1 
Default nPage		:= 0 
Default nPageSize	:= 0 
Default cBaseURL 	:= ""
Default lImagem     := .F.
Default lFoundatio  := .F.
Default cVersGet    := "v1"

//+--------------------------------------------------------------
//| METODOS GET
//+--------------------------------------------------------------
//| 1 - Consulta Objetos de Checklist
If Upper(cMethod) == "GET"

	cResJson := getChkList(cPath+"/",cQueryParam,cPathParam,cBaseURL,lImagem,lFoundatio,cVersGet)

//+--------------------------------------------------------------
//| METODOS POST
//+--------------------------------------------------------------
ElseIf Upper(cMethod) == "POST"

	cResJson := posChkList(cPath+"/",oJBody,@cHTTPCode,cBaseURL)

//+--------------------------------------------------------------
//| METODOS DELETE
//+--------------------------------------------------------------
ElseIf Upper(cMethod) == "DELETE"

EndIf

Return cResJson

/*/{Protheus.doc} getChkList
    Realiza o GET do Object de Checklist
    para obter uma lista de objetos:
    url: https://totvs.logistica.totvs.app/checklist/query/api/v1/checklistObjects/ 
    para obter um único objeto:
    url: https://totvs.logistica.totvs.app/checklist/query/api/v1/checklistObjects/{checklistId}
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function getChkList(cPath,cQueryParam,cPathParam,cBaseURL,lImagem,lFoundatio,cVersGet)
Local cResult := ""
Local oClient := NIL
Local oJBody  := JsonObject():New()
Local cURL    := ""
Local aHeader := {}
Local cToken  := ""
Local cCompl  := ""

Default cPath       := ""
Default cQueryParam := ""
Default cPathParam  := ""
Default cBaseURL    := ""
Default lImagem     := .F. 
Default lFoundatio  := .F.
DEFAULT cVersGet    := "v1"

cURL := _cURLChk
If lImagem
	cURL		+= "/checklist/query/api/v1/files/"
	cVersGet	:= "v1"
ElseIf lFoundatio
	DLZ->(dbSetOrder(2))
	If DLZ->( MsSeek( xFilial("DLZ") + "2" ))
		cURL := AllTrim( StrTran( DLZ->DLZ_URLTOK, "connect/", "" ) )
	EndIf
Else
	cURL += "/checklist/query/api/" + cVersGet + "/"
EndIf
If cVersGet == "v2"
	cCompl := "/nonCompliances"
EndIf

//+-------------------------------------------------
//| Define a URL Base
//+-------------------------------------------------
If !Empty(cBaseUrl)
	cURL := cBaseURL
EndIf

//+-------------------------------------------------
//| GetToken - gera a chave de autorização necessária para consumo da API
//+-------------------------------------------------
cToken := geraTokAPI()

//+-------------------------------------------------
//| Definição do tipo de envio JSON ou URLEncode
//+-------------------------------------------------
Aadd(aHeader,"Content-Type: application/json;charset=UTF-8")
Aadd(aHeader,"Authorization: Bearer " + cToken )

//+-------------------------------------------------
//| Setting e Consumo da API
//+-------------------------------------------------
oClient := FwRest():New(cURL)
If !Empty(cQueryParam)
	oClient:SetPath( cPath + "?" + cQueryParam )
ElseIf !Empty( cPathParam )
	oClient:SetPath( cPath + cPathParam + cCompl )
ElseIf Empty( cPathParam )
	oClient:SetPath( cPath )
EndIf

If oClient:Get(aHeader)
	cResult := oClient:GetResult()
Else
	cResult := oClient:GetLastError()
EndIf

FreeObj(oJBody)

Return cResult

/*/{Protheus.doc} posChkList
    Realiza o POST do Object de Checklist
    para obter uma lista de objetos:
    url: https://totvs.logistica.totvs.app/checklist/query/api/v1/checklistObjects/ 
    para obter um único objeto:
    url: https://totvs.logistica.totvs.app/checklist/query/api/v1/checklistObjects/{checklistId}
    @type  Function
    @author user
    @since date
    @version version
    @param cPath : é o apontamento do endpoint 
	@param oJBody: Objeto JSon que contem as informações que serão lançadas no corpo da requisição HTTP POST
	@param cHTTPCode : Retorno do código HTTP Exemplo: 200 sucesso de transmissao; 201 Sucesso de transmissão e processamento. 500-Internal Error etc.
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function posChkList(cPath,oJBody,cHttpCode,cBaseURL)
Local cResult		:= ""
Local oClient		:= NIL
Local cURL			:= _cURLChk + "/checklist/core/api/v1/"
Local aHeader		:= {}
Local cToken		:= ""

Default cPath		:= ""
Default oJBody		:= Nil 
Default cHttpCode	:= ""
Default cBaseURL	:= ""	

//+-------------------------------------------------
//| Define a URL Base
//+-------------------------------------------------
If !Empty(cBaseUrl)
	cURL := cBaseURL
EndIf

//+-------------------------------------------------
//| GetToken - gera a chave de autorização necessária para consumo da API
//+-------------------------------------------------
cToken := geraTokAPI()

//+-------------------------------------------------
//| Definição do tipo de envio JSON ou URLEncode
//+-------------------------------------------------
Aadd(aHeader,"Content-Type: application/json;charset=UTF-8")
Aadd(aHeader,"Authorization: Bearer " + cToken )

//+-------------------------------------------------
//| Setting e Consumo da API
//+-------------------------------------------------
oClient := FwRest():New(cURL)
oClient:SetPath( cPath )
oClient:SetPostParams(oJBody:toJson())
If oClient:Post(aHeader)
	cResult   := oClient:GetResult()
	cHttpCode := HTTPGetStatus(cHttpCode)
Else
	cResult := oClient:GetLastError()
EndIf

FreeObj(oJBody)

Return cResult

/*/{Protheus.doc} TMSMovImg
Move e renomeia imagens para gravação na DLY
@author Felipe Barbiere	
@since 25/10/2019
@version 12.1.25
@return Logico
@param Estrutura aVetImg
		[1]FILDOC
		[2]DOC
		[3]SERIE
		[4]EXTENSAO DA IMAGEM - Ex. ".JPG"
		[5]BINARIO DA IMAGEM
@type function
/*/
Function TMSMovImg(aVetImg)
Local nCont  	:= 0
Local lRet  	:= .T.
Local aVetDLY   := {}
Local aAreas    := {}
Local nRecnoDLY := 0
Local lDM0 		:= TableIndic("DM0")

Local cImgVinc  := SuperGetMV("MV_TMSIMGC",.F.,"")
Local cPastaDef := "COMPR_ENTREGA"
Local cPath 	:=""
Local nArquivo 	:= 0

Default aVetImg := {}

If lDM0
	aAreas    := { DM0->(GetArea()),GetArea() }
EndIf

If Empty(aVetImg)
	Return .F.
EndIf

If !lDM0
	If IsSrvUnix()
		cPastaDef += "/" 
	Else
		cPastaDef += "\" 
	EndIf
	If !ExistDir(cPastaDef)     
		MakeDir(cPastaDef)
	EndIf
	If Empty(cImgVinc)
		cImgVinc := cPastaDef
	EndIf
	For nCont := 1 to Len(aVetImg)
		If DT6->(DbSeek(xFilial("DT6")+aVetImg[nCont][1]+aVetImg[nCont][2]+aVetImg[nCont][3])) .And. !Empty(DT6->DT6_CHVCTE);
			.And. DT6->DT6_SITCTE == "2"
			cPath := cImgVinc + "CTe_" + DT6->DT6_CHVCTE + Iif(SubStr(aVetImg[nCont][4],1,1) <> ".",".","") + aVetImg[nCont][4]
			nRecnoDLY := TMSUltDLY(DT6->DT6_CHVCTE)
			If nRecnoDLY > 0			
				If File(cPath)
					If FERASE(cPath) < 0
						lRet := .F.
					EndIf
				EndIf
				
				nArquivo := FCREATE(cPath)
				If nArquivo >= 0
					FWrite(nArquivo, aVetImg[nCont][5])
					FClose(nArquivo)
					Aadd(aVetDLY,{nRecnoDLY,{{"DLY_DIRIMG",cPath,Nil}}})
				Else
					lRet := .F.
				EndIf
			EndIf
		EndIf	
	Next nCont
	If !Empty(aVetDLY)
		TMSIntChk("4",aVetDLY)
	EndIf
Else
	DM0->(DbSetOrder(1))
	For nCont := 1 to Len(aVetImg)
		If DM0->(DbSeek(xFilial("DM0") + aVetImg[nCont,1] + aVetImg[nCont,2] + aVetImg[nCont,3]))
			Aadd(aVetDLY,{{"DM0_EXTENS",aVetImg[nCont,4],Nil}, ;
						  {"DM0_IMAGEM",aVetImg[nCont,5],Nil}})
		EndIf
		If !Empty(aVetDLY)
			TMSIntChk("5",{DM0->(Recno()),aVetDLY})
		EndIf
	Next nCont
	aEval(aAreas,{|xArea| RestArea(xArea)})
EndIf

Return lRet

/*/{Protheus.doc} TMSUltDLY
Retorna o ultimio RECNO da DLY em array de acordo com a chave do CTE
@author Felipe Barbiere	
@since 29/10/2019
@version 12.1.25
@return Logico
@param Chave do CTE e Status da DLY (Padrão 0)
@type function
/*/
Function TMSUltDLY(cChaveCTe, cStatusDLY)
Local aAreas    := {GetArea()}
Local cQuery 	:= ""
Local nRecnoDLY	:= 0
Local cAliasQry := GetNextAlias()

Default cChaveCTe  := ""
Default cStatusDLY := "0"

cQuery := " SELECT MAX(R_E_C_N_O_) DLY_RECNO"
cQuery += " FROM " + RetSqlName("DLY") + " DLY "
cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "'"
cQuery += "   AND DLY.DLY_CHVCTE = '" + cChaveCTe + "'"
cQuery += "   AND DLY.DLY_STATUS = '" + cStatusDLY + "'"
cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
If (cAliasQry)->(!Eof()) .And. !Empty((cAliasQry)->DLY_RECNO)
	nRecnoDLY := (cAliasQry)->DLY_RECNO
EndIf
(cAliasQry)->(DbCloseArea())

aEval(aAreas,{|xArea| RestArea(xArea)})

Return nRecnoDLY

/*/{Protheus.doc} TMSGerScr
Cria o script automaticamente
@author Valdemar Roberto Mognon
@since 30/10/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSGerScr(oClient,cResult,aHeader,cTipDoc)
Local oItems as Object
Local cRet    	:= ""
Local cDescrScr := ""
Local cTitleScr := ""

Default cTipDoc     := ""

//+----------------------------------------
//| Verifica se o Script Existe
//+----------------------------------------
cRet := TMSVerScr(@oItems,cTipDoc,@cDescrScr,@cTitleScr)

If !Empty(cRet)
	cRet := oItems[1]["id"]
EndIf

Return cRet

/*/{Protheus.doc} TMSGerObj
Cria o objeto automaticamente
@author Valdemar Roberto Mognon
@since 30/10/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/
Static Function TMSGerObj(oClient,cIdObj,cResult,aHeader,cLabelComp)
Local cRet        	:= ""
Local oBody			:= Nil
Local oItems		:= Nil
Local cHttpCode		:= ""
Local cVerChk       := ""
Local cFilExt       := ""

Default oClient		:= Nil
Default cIdObj		:= ""
Default cResult		:= ""
Default aHeader		:= {} 
Default cTipDoc     := ""
DEFAULT cLabelComp  := "Entrega"

//+----------------------------------------
//| Verifica se o Objeto Existe
//+----------------------------------------
cRet := TMSVerObj(cIdObj,@oItems)

If !Empty(cRet)
	cRet := oItems[1]["id"]
	cResult := cIdObj
Else
	//+----------------------------------------
	//| Montagem do Objeto CTe
	//+----------------------------------------
	oBody := JSonObject():New()
	oBody["categoryClass"] := "STANDARD"
	oBody["customId"]      := cIdObj
	oBody["description"]   := "Comprovante_de_"+cLabelComp
	If TMSChkVer2( @cVerChk, @cFilExt )
		oBody["branchId"] := cFilExt
	EndIf

	oClient:SetPath( "/" + cVerChk + "/checklistObjects/" )
	oClient:SetPostParams(oBody:toJson())
	
	If oClient:Post(aHeader)
	    cResult  := oClient:GetResult()
		If HTTPGetStatus(@cHttpCode) == 201
			cRet := TMSVerObj(cIdObj,@oItems)
		EndIf
		If !Empty(oItems)
			cRet := oItems[1]["id"]
		EndIf
	Else
	    cResult := oClient:GetLastError()
	EndIf
EndIf

Return cRet

/*/{Protheus.doc} TMSGerCHK
Cria o Check List automaticamente
@author Valdemar Roberto Mognon
@since 30/10/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSGerCHK(oClient,cIdCHK,cHasObj,cDatIni,cDatFim,cHasExe,cHasScr,cHasCHK,cResult,aHeader,cFilDoc,cDoc,cSerie,cFilOri,cViagem,lEnviado,cObserv,cRetChec, lSaiApoio)
Local cRet        := ""
Local cStatus     := ""
Local aRet        := {}
Local oBody		  := NIL
Local oItems	  := NIL
Local cHTTPCode   := ""

Default oClient		:= Nil
Default cIdCHK		:= ""
Default cHasObj		:= ""
Default cDatIni		:= ""
Default cDatFim		:= ""
Default cHasExe		:= ""
Default cHasScr		:= ""
Default cHasCHK		:= ""
Default cResult		:= ""
Default aHeader		:= {} 
Default cFilDoc	  	:= ""
Default cDoc	  	:= ""
Default cSerie	  	:= ""
Default cFilOri		:= ""
Default cViagem		:= ""
Default lEnviado    := .F.
Default cObserv		:= ""
Default cRetChec	:= ""
DEFAULT lSaiApoio   := .F.

//+----------------------------------------
//| Verifica se o Check List Existe
//+----------------------------------------
cRet := TMSVerCHK( cIdCHK, @oItems, @cStatus )

If Empty(cRet) .OR. ( !Empty(cRet) .AND. cStatus == "CANCELED" )
	//+----------------------------------------
	//| Montagem do Check List Viagem
	//+----------------------------------------
	oBody := JSonObject():New()
	oBody["checklistCustomId"]		:= cIdCHK
	oBody["checklistObjectId"]		:= cHasObj
	oBody["creationDateReference"]	:= cDatIni
	oBody["executorId"]				:= cHasExe
	oBody["observation"]			:= PadR( EncodeUtf8( cObserv, ), 600 )
	//oBody["periodEnd"]			:= "2021-02-24T18:18:16.059Z"
	//oBody["periodStart"]			:= "2021-02-24T18:18:16.059Z"
	oBody["scriptId"]				:= cHasScr
	
	oClient:SetPath( "/v1/checklist/" )
	oClient:SetPostParams(oBody:toJson())

	If oClient:Post(aHeader)
	    cResult := oClient:GetResult()
		
		If HTTPGetStatus(@cHttpCode) == 201 //--Checklist created successfully.
			cResult := TMSVerCHK(cIdCHK,@oItems,@cStatus)
		Else
			lEnviado := .F.
		EndIf
	
		If !Empty(oItems)
		 	cHasCHK := oItems[1]["checklistId"]
		Else
			cHasCHK	:= ""
		EndIf

			Aadd(aRet,{"DM0_IDINTG",cHasCHK,Nil})
			Aadd(aRet,{"DM0_INIINT",cDatIni,Nil})
			Aadd(aRet,{"DM0_FIMINT",cDatFim,Nil})

		//-- Atualiza DM0
			AtuDM0Int( cFilDoc, cDoc , cSerie , cHasCHK , cDatIni, cDatFim , cFilOri , cViagem, lSaiApoio  )
			lEnviado := .T.
	Else
	    cResult := oClient:GetResult()
		cRetChec := cResult
		lEnviado := .F.
	EndIf
Else
	If !Empty(oItems)
		cHasCHK := oItems[1]["checklistId"]
	EndIf
	
		Aadd(aRet,{"DM0_IDINTG",cHasCHK,Nil})

	lEnviado := .T.
EndIf

Return aRet

/*/{Protheus.doc} TMSCanChk
Estorno do check list no Estorno do Fechamento da Viagem ou Saída da Filial verificando o parâmetro MV_TMINTEV
@author Fabio Marchiori Sampaio
@since 28/10/2019
@version 12.1.25
@return Undefined
@param 
@type function
/*/
Function TMSCanChk(cChkCustId, cFilOri, cViagem, cObserv )
Local aHeader     := {}
Local cToken      := ""
Local cHasChk     := ""
Local cStatus     := ""
Local nCntFor1    := 0
Local oClient
Local oBody		
Local oItems
Local lIs310350		:= FwIsInCallStack('TMSA310EST') .OR. ( FwIsInCallStack('TMSA350Grv') .AND. FwIsInCallStack('EstDocChk') )

Default cChkCustId 	:= ""
Default dDataDe    	:= ""
Default dDataAte   	:= ""
Default cFilOri    	:= ""
Default cViagem    	:= ""
Default cObserv		:= "Comprovante de Entrega Cancelado"

cIdCHK := AllTrim(cViagem)

//+----------------------------------------
//| Verifica se o Check List Existe
//+----------------------------------------
cRet := TMSVerCHK(cIdCHK,@oItems,@cStatus, cChkCustId)

If ValType(oItems) == "A" .And. !Empty(oItems)

	For nCntFor1 := 1 To Len(oItems)
		
		cStatus	:= oItems[nCntFor1]["status"]

		If ValType(cStatus) == "J" 
			cStatus	:= oItems[nCntFor1]["status"]["id"]
		EndIf

		If ( cStatus == "CANCELED" .OR. cStatus == "PENDING" ) .AND. lIs310350

			cHasChk := oItems[nCntFor1]["checklistId"]
			aHeader	:= {} 

			//+----------------------------------------
			//| Montagem do Objeto CTe
			//+----------------------------------------
			oBody := JSonObject():New()
			oBody["observation"] := cObserv

			//+----------------------------------------
			//| Gera Header para consumir a API
			//+----------------------------------------
			cToken := geraTokAPI()
			Aadd(aHeader, 'Content-Type: application/json')
			Aadd(aHeader, 'Authorization: Bearer ' + cToken)

			oClient := FwRest():New( _cURLChk + "/checklist/core/api/" )
			oClient:SetPath( "/v1/checklist/" + cHasChk + "/cancel/" )
			oClient:SetPostParams(oBody:toJson())
			
			If oClient:Post(aHeader)

				cResult := oClient:GetResult()

				//-- Excluir DM0
					DelDM0( cHasChk , cFilOri , cViagem )

			Else
				cResult := oClient:GetLastError()
			EndIf

			FwFreeArray(aHeader)

		EndIf
				
	Next nCntFor1
EndIf

Return

/*/{Protheus.doc} TMSChkDLY
Pega o cheklist da DLY
@author Fabio Marchiori Sampaio
@since 28/10/2019
@version 12.1.25
@return Undefined
@param 
@type function
/*/

Function TMSChkDLY(cChaveCTe)
Local aRet      := {}
Local aResult   := {}
Local aAreas    := {GetArea()}
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

Local lTemIni   := DLY->(ColumnPos("DLY_INIINT")) > 0
Local lTemVia   := DLY->(ColumnPos("DLY_FILORI")) > 0
Local lTemDM0   := TableInDic("DM0")
Local lCont     := .T.

Default cChaveCTe := ""

cQuery := " SELECT DLY.R_E_C_N_O_ DLY_RECNO , DLY.DLY_IDINTG DLY_IDINTG, DLY.DLY_DATENT DLY_DATENT, DLY.DLY_HORENT DLY_HORENT "
If lTemIni
	cQuery += "   ,DLY.DLY_INIINT DLY_INIINT, DLY.DLY_FIMINT DLY_FIMINT "
EndIf
If lTemVia
	cQuery += "   ,DLY.DLY_FILORI DLY_FILORI, DLY.DLY_VIAGEM DLY_VIAGEM "
EndIf
cQuery += "       ,DT6.DT6_FILDOC DT6_FILDOC, DT6.DT6_DOC    DT6_DOC   , DT6.DT6_SERIE  DT6_SERIE , DT6.DT6_CHVCTE DT6_CHVCTE "
If lTemDM0
	cQuery += "   ,DM0.DM0_IDINTG DM0_IDINTG, DM0.DM0_INIINT DM0_INIINT, DM0.DM0_FIMINT DM0_FIMINT "
EndIf

cQuery += "        FROM " + RetSqlName("DLY") + " DLY "

cQuery += "        JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += " 	     ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += " 	    AND DT6.DT6_CHVCTE = DLY.DLY_CHVCTE "
cQuery += " 	    AND DT6.D_E_L_E_T_ = ' ' "

If lTemDM0
	cQuery += "    JOIN " + RetSqlName("DM0") + " DM0 "
	cQuery += " 	 ON DM0.DM0_FILIAL = '" + xFilial("DM0") + "' "
	cQuery += " 	AND DM0.DM0_FILDOC = DT6.DT6_FILDOC "
	cQuery += " 	AND DM0.DM0_DOC    = DT6.DT6_DOC "
	cQuery += " 	AND DM0.DM0_SERIE  = DT6.DT6_SERIE "
	cQuery += "     AND DM0.DM0_IDINTG <> ' ' "
	cQuery += "     AND DM0.DM0_EXTENS = ' ' "
	cQuery += " 	AND DM0.D_E_L_E_T_ = ' ' "
EndIf

cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
cQuery += "   AND DLY.DLY_CHVCTE <> ' ' "
If !Empty(cChaveCTe)
	cQuery += "   AND DLY.DLY_CHVCTE = '" + cChaveCTe + "' "
EndIf
cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())
	lCont := !Empty((cAliasQry)->DLY_IDINTG)
	If !lCont .And. lTemDM0
		lCont := !Empty((cAliasQry)->DM0_IDINTG)
	EndIf

	If lCont
		aRet := {}
		Aadd(aRet, (cAliasQry)->DLY_RECNO)												//-- [1] Numero do RECNO
		Aadd(aRet, Iif(!Empty((cAliasQry)->DLY_IDINTG),(cAliasQry)->DLY_IDINTG,(cAliasQry)->DM0_IDINTG))	//-- [2] Id do Cheklist - não é o customId e sim o checklistId retornado pela API
		Aadd(aRet, TMSConvDat(stod((cAliasQry)->DLY_DATENT),(cAliasQry)->DLY_HORENT)) 	//-- [3] Data Inicio
		Aadd(aRet, TMSConvDat(stod((cAliasQry)->DLY_DATENT),(cAliasQry)->DLY_HORENT)) 	//-- [4] Data Ate
		Aadd(aRet, Iif(lTemVia,(cAliasQry)->DLY_FILORI,"") ) //-- [5] Filial Origem Viagem
		Aadd(aRet, Iif(lTemVia,(cAliasQry)->DLY_VIAGEM,"") ) //-- [6] Numero da Viagem
		If DLY->(ColumnPos("DLY_INIINT")) > 0
			Aadd(aRet, (cAliasQry)->DLY_INIINT ) //-- [7] equivalente ao planningDateFrom
			Aadd(aRet, (cAliasQry)->DLY_FIMINT ) //-- [8] equivalente ao planningDateUntil
		Else
			Aadd(aRet, TMSConvDat(stod((cAliasQry)->DLY_DATENT),(cAliasQry)->DLY_HORENT)) 	//-- [7] Data Inicio
			Aadd(aRet, TMSConvDat(stod((cAliasQry)->DLY_DATENT),(cAliasQry)->DLY_HORENT)) 	//-- [8] Data Ate
		EndIf
		Aadd(aRet, (cAliasQry)->DT6_FILDOC ) //-- [9 ] Filial Documento
		Aadd(aRet, (cAliasQry)->DT6_DOC    ) //-- [10] Numero Documento
		Aadd(aRet, (cAliasQry)->DT6_SERIE  ) //-- [11] Série  Documento
		Aadd(aRet, (cAliasQry)->DT6_CHVCTE ) //-- [12] chave do documento eletronico
		//-- Adiciona vetor a matriz.
		AADD(aResult,aClone(aRet))
	EndIf

	//-- Next Record
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aResult


/*/{Protheus.doc} TMSCLOcor
Executa o apontamento da ocorrência via TMSA360
@author Felipe Barbiere	
@since 31/10/2019
@version 12.1.25
@param Estrutura aVetOcor
		[1]Chave do CT-e
		[2]DATA OCORRENCIA
		[3]HORA OCORRENCIA
		[4]FILORI VIAGEM
		[5]NUMERO VIAGEM
		[6]Filial de Origem do Documento
		[7]Número do Documento
		[8]Série do Documento
@return Logico
@type function
/*/
Function TMSCLOcor(aVetOcor)
Local cQuery   	:= ""
Local cAliasQry	:= ""
Local aItens   	:= {}
Local aCab		:= {}
Local cOcorEnt 	:= SuperGetMV( 'MV_OCORENT',.F., '' )
Local cOcorCol 	:= SuperGetMV( 'MV_OCORCOL',.F., '' )
Local nCont 	:= 0
Local nLenCont	:= 0
Local nDecQTD	:= TamSX3("DUA_PESOCO")[2]
Local nPeso		:= 0
Local nVolOri	:= 0

Private lMsErroAuto := .F.

Default aVetOcor := {}

If !Empty(cOcorEnt) .And. !Empty(aVetOcor)
	
	For nCont := 1 To Len( aVetOcor )
 	 	//-- Cabecalho da Ocorrencia
		Aadd( aCab, { 'DUA_FILORI', aVetOcor[nCont][4], NIL } )
		Aadd( aCab, { 'DUA_VIAGEM', aVetOcor[nCont][5], NIL } )
		
		If nCont == 1
			nLenCont := Len( aVetOcor[nCont] )
 		EndIf

		cAliasQry := GetNextAlias()

		cQuery := "SELECT DT6_FILDOC,DT6_DOC,DT6_SERIE,DT6_VOLORI,DT6_PESO,DT6_SERTMS "
		cQuery += "  FROM " + RetSqlName("DT6") + " DT6 "
		cQuery += " WHERE DT6_FILIAL = '" + xFilial ("DT6") + "' "
		cQuery += "   AND DT6_FILDOC = '" + aVetOcor[nCont,6] + "' "
		cQuery += "   AND DT6_DOC    = '" + aVetOcor[nCont,7] + "' "
		cQuery += "   AND DT6_SERIE  = '" + aVetOcor[nCont,8] + "' "
		cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		
		While (cAliasQry)->(!Eof())
			If (cAliasQry)->DT6_SERTMS == "1"

				If nLenCont == 10 .AND. aVetOcor[ nCont, 9 ] > 0
					nPeso	:= NoRound( aVetOcor[ nCont, 9 ], nDecQTD )
				Else
					nPeso	:= 1
				EndIf

				If nLenCont == 10 .AND. aVetOcor[ nCont, 10 ] > 0
					nVolOri	:= aVetOcor[ nCont, 10 ]
				Else
					nVolOri	:= 1
				EndIf
				
			Else
				nVolOri	:= (cAliasQry)->DT6_VOLORI
				nPeso	:= (cAliasQry)->DT6_PESO
			EndIf

			aAdd( aItens, {	;
				 {"DUA_SEQOCO", StrZero(1,Len(DUA->DUA_SEQOCO)) , NIL},;
		         {"DUA_DATOCO", CToD(aVetOcor[nCont][2])		, NIL},;
		         {"DUA_HOROCO", aVetOcor[nCont][3]				, NIL},;
		         {"DUA_CODOCO", If( (cAliasQry)->DT6_SERIE == "COL", cOcorCol, cOcorEnt ), NIL },;
				 {'DUA_SERTMS', (cAliasQry)->DT6_SERTMS         , Nil},;
		         {"DUA_FILDOC", (cAliasQry)->DT6_FILDOC			, NIL},;
		         {"DUA_DOC"   , (cAliasQry)->DT6_DOC			, NIL},;
		         {"DUA_SERIE" , (cAliasQry)->DT6_SERIE			, NIL},;
		         {"DUA_QTDOCO", nVolOri							, NIL},;
		         {"DUA_PESOCO", nPeso							, NIL},;
		         {"DUA_ORIGEM", "TMSAE71"						, NIL}})
			(cAliasQry)->(DbSkip())
		EndDo

		MsExecAuto( { | x,y,z | Tmsa360( x, y, z ) }, aCab, aItens, {}, 3 )
		
		If lMsErroAuto
			If !IsBlind()
				MostraErro()
			EndIf
		EndIf

		aCab := {}
		aItens := {}
		(cAliasQry)->(DbCloseArea())
	Next nCont
EndIf

Return .T.

/*/{Protheus.doc} TMSLeExec
Verifica a existência do objeto e o cria automaticamente
@author Valdemar Roberto Mognon
@since 30/10/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/
Function TMSLeExec( cNome, aExec )

Local cQueryParam := ""
Local aRet      := {}
Local nCount    := 0
Local oResult   := Nil
Local cVerChk   := ""
Local cFilExt   := ""
Local cResult   := ""
Local nPage		:= 1
Local lV2		:= .F.
Local lHasNext  := .T.

Default cNome	:= ""
Default aExec	:= {}

lV2 := TMSChkVer2( @cVerChk, @cFilExt )

Do While lHasNext
	If lV2
		cQueryParam	:= "branchId=" + cFilExt + ""
	EndIf
	
	If !Empty( cNome )
		cQueryParam	+= "&fullName=" + cNome
	EndIf

	cQueryParam	+= "&page=" + cValtoChar(nPage)

	cResult := TMSCHKLIST( "GET", "executors", , cQueryParam,,,,,,,,, cVerChk )

	If FWJsonDeserialize( cResult, @oResult )
		If ( lHasNext := AttIsMemberOf( oResult, "hasNext" ) )
			lHasNext := oResult:hasNext
			nPage++
		EndIf
		If AttIsMemberOf( oResult, "items" )
			For nCount := 1 To Len( oResult:items )
				AAdd( aRet, { DeCodeUTF8( oResult:items[nCount]:FULLNAME ), oResult:items[nCount]:ExternalUserID, oResult:items[nCount]:ID } )
			Next nCount
		EndIf
	EndIf
EndDo

If !Empty(aRet)
	ASort(aRet,,,{|x,y| x[1] < y[1]})
ElseIf Empty(aRet) .AND. !Empty(aExec)
	Help( '', 1, "TMSXFUNH", , STR0027, 1 ) // "Termo pesquisado não retornou dados."
	aRet := AClone(aExec)
EndIf

FwFreeObj(oResult)

Return aRet

/*/{Protheus.doc} TMSVerScr
Verifica a existência do script
@author Valdemar Roberto Mognon
@since 05/11/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/
Static Function TMSVerScr(oItems,cTipDoc,cDescrScr,cTitleScr)
Local cQueryParam := ""
Local cRet        := ""
Local cResult     := ""
Local oJSonRes
Local lHaveScr    := DLZ->(ColumnPos("DLZ_SCRCOL")) > 0 .And. DLZ->(ColumnPos("DLZ_SCRENT")) > 0
Local cVerChk     := ""
Local cFilExt     := ""

Default oItems		:= Nil
Default cTipDoc     := ""

//+----------------------------------------
//| Verifica se o Script Existe
//+----------------------------------------
If lHaveScr
	cDescrScr := GetScrChk(cTipDoc)
	cTitleScr := cDescrScr
Else
	cDescrScr := "Data de Entrega"
	cTitleScr := "Data_Entrega"
EndIf

If TMSChkVer2( @cVerChk, @cFilExt )
	cQueryParam	+= "branchId="+cFilExt+"&"
EndIf
cQueryParam += "searchTerm=" + cTitleScr
cQueryParam += "&archived=false"

cResult  := TMSCHKLIST( "GET", "scripts",, cQueryParam,,,,,,,,, cVerChk )

oJSonRes := JsonObject():New()
oJSonRes:fromJSon(cResult)

oItems   := oJSonRes["items"]

If !Empty(oItems)
	cRet := oItems[1]["title"]
EndIf

Return cRet

/*/{Protheus.doc} TMSVerObj
Verifica a existência do objeto
@author Valdemar Roberto Mognon
@since 05/11/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSVerObj(cIdObj,oItems)
Local cQueryParam := ""
Local cRet        := ""
Local cResult     := ""
Local oJSonRes
Local cVerChk     := ""
Local cFilExt     := ""

Default cIdObj	:= ""
Default oItems	:= Nil

//+----------------------------------------
//| Verifica se o Objeto Existe
//+----------------------------------------
If TMSChkVer2( @cVerChk, @cFilExt )
	cQueryParam	+= "branchId="+cFilExt+"&"
EndIf
cQueryParam += "customId=" + cIdObj

cResult  := TMSCHKLIST( "GET", "checklistObjects",, cQueryParam,,,,,,,,, cVerChk )

oJSonRes := JsonObject():New()
oJSonRes:fromJSon(cResult)

oItems   := oJSonRes["items"]
If !Empty(oItems)
	cRet := oItems[1]["customId"]
EndIf

Return cRet

/*/{Protheus.doc} TMSVerCHK
Verifica a existência do check list e o cria automaticamente
@author Valdemar Roberto Mognon
@since 30/10/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSVerCHK(cCustomID,oItems,cStatus,cIdCHK)
Local cQueryParam := ""
Local cRet        := ""
Local cIniPsq     := ""
Local cFimPsq     := ""
Local cResult     := ""
Local oJSonRes
Local cPathParam  := ""
Local cVerChk     := ""
Local cFilExt     := ""

Default	cCustomID	:= ""
Default oItems		:= Nil
Default cStatus		:= ""
Default cIdCHK		:= ""

//+----------------------------------------
//| Verifica se o Check List Existe
//+----------------------------------------
cIniPsq := TMSConvDat(dDataBase - 182,"0000") //MEIO ANO ANTES DA DATABASE
cFimPsq := TMSConvDat(dDataBase + 182,"2359") //MEIO ANO DEPOIS DA DATABASE

If TMSChkVer2( @cVerChk, @cFilExt )
	cQueryParam	+= "branchId="+cFilExt+"&"
EndIf
If Empty(cIdCHK)
	cQueryParam += "checklistCustomId=" + RTrim(cCustomID)
	cQueryparam += "&planningDateFrom=" + cIniPsq
	cQueryParam += "&planningDateUntil="+ cFimPsq
Else
	cQueryParam += "checklistCustomId=" + Padr( RTrim(cCustomID), TamSx3('DTQ_VIAGEM')[1] )
	cQueryparam += "&planningDateFrom=" + cIniPsq
	cQueryParam += "&planningDateUntil="+ cFimPsq
	cPathParam := RTrim(cIdCHK)
EndIf

cResult  := TMSCHKLIST( "GET", "checklists",, cQueryParam, cPathParam,,,,,,,, cVerChk)

oJSonRes := JsonObject():New()
oJSonRes:fromJSon(cResult)

oItems   := oJSonRes["items"]

If !Empty(oItems)
	cRet    := oItems[1]["checklistCustomId"]
	cStatus := oItems[1]["status"]
Else

	oItems	:= { oJsonRes }

	cRet    := oItems[1]["checklistCustomId"]
		
	If ValType(oItems[1]["status"]) == "J"
		cStatus	:= oItems[1]["status"]["id"]
	Else
		cStatus := oItems[1]["status"]
	EndIf

EndIf

Return cRet

/*/{Protheus.doc} DateTimeFS
	Retorna a data
	@type  Function
	@author Tiago dos Santos
	@since 25/11/2019 
	@version 12.1.25
	@param  cUF	   , char,	 UF da filial emissora (default obtem pela região cadastrada no parametro MV_CDRORI)
			lHVerao, logic,	 informa se a hora está em horario de verão (default obtem do cadastro de parâmetro MV_TMSHRVR)
			@cData , Date,	 Retorno da data por referência
			@cHora , char,   Retorno da hora por referência
	@return não há retorno
/*/
Function DateTimeFS(cUF,lHVerao,cData,cHora)
 Local aAreaDUY		:= DUY->(GetArea())
 Local aDataBase	:= {}

 Default cUF		:= ""
 Default lHVerao	:= SuperGetMV("MV_TMSHRVR",,.F.) //-- Define se encontra-se no periodo de horario de verao.

//-- Obtém a UF da filial de emissão
If Empty(cUF)
	cUF := Posicione("DUY",1,xFilial("DUY") + SuperGetMV("MV_CDRORI" ,,"" ),"DUY_EST")
EndIf
If	FindFunction("FwTimeUF")
	aDataBase	:= FwTimeUF(cUF,,lHVerao)
	cData		:= STOD(aDataBase[1])
	cHora		:= StrTran(Left(aDataBase[2],5),':','')
EndIf

RestArea(aAreaDUY)

Return Nil

/*/{Protheus.doc} TMSCmpTrb
Cria Arquivo de Trabalho para Filtrar pelo Painel de Agendamentos/Viagem
@author Valdemar Roberto Mognon
@since 30/03/2020
@version 12.1.28
@return Logico
@param 
@type function
/*/

Function TMSCmpTrb(oTempTable,cAlias,cTableName)
Local aStruct := {}

//-- Cria estrutura do arquivo de trabalho
AAdd(aStruct,{"TRB_FILDOC","C",FWGETTAMFILIAL,0})
AAdd(aStruct,{"TRB_DOC"   ,"C",TamSX3("DT6_DOC")[1],0})
AAdd(aStruct,{"TRB_SERIE" ,"C",TamSX3("DT6_SERIE")[1],0})

cArqTrb := GetNextAlias()
oTempTable:= FWTemporaryTable():New()
oTempTable:SetFields(aStruct)
oTempTable:AddIndex("01",{"TRB_FILDOC","TRB_DOC","TRB_SERIE"} )
oTempTable:Create()

cAlias     := oTempTable:GetAlias()
cTableName := oTempTable:GetRealName()

Return

/*/{Protheus.doc} TMSCmpGrv
Grava Arquivo de Trabalho para Filtrar pelo Painel de Agendamentos/Viagem
@author Valdemar Roberto Mognon
@since 30/03/2020
@version 12.1.28
@return Logico
@param 1=Viagem / 2=Painel de Agendamentos
       Filial de Origem da Viagem
       Numero da Viagem
       Arquivo de Trabalho
@type function
/*/

Function TMSCmpGrv(nAcao,cFilOri,cViagem,cArqTrb,aAgends)
Local cQuery    := ""
Local cAliasDUD := ""
Local nCntFor1  := 0
Local aAreas    := {DF1->(GetArea()),DTC->(GetArea()),GetArea()}
Local aCab      := {}
Local aItens    := {}
Local lTipIns		:= DT2->( ColumnPos("DT2_TIPINS") ) > 0

Default nAcao   := 0
Default cFilOri := ""
Default cViagem := ""
Default cArqTrb := ""
Default aAgends := {}

If nAcao == 1	//-- Viagem
	If !Empty(cFilOri) .And. !Empty(cViagem)
		cAliasDUD := GetNextAlias()
		cQuery := "SELECT DISTINCT DUD_FILDOC,DUD_DOC,DUD_SERIE "

		cQuery += "  FROM " + RetSqlName("DUD") + " DUD "

		cQuery += "  JOIN " + RetSqlName("DUA") + " DUA "
		cQuery += "    ON DUA_FILIAL = '" + xFilial("DUA") + "' "
		cQuery += "   AND DUA_FILDOC = DUD_FILDOC "
		cQuery += "   AND DUA_DOC    = DUD_DOC "
		cQuery += "   AND DUA_SERIE  = DUD_SERIE "
		cQuery += "   AND DUA.D_E_L_E_T_ = ' ' "

		cQuery += "  JOIN " + RetSqlName("DT2") + " DT2 "
		cQuery += "    ON DT2_FILIAL = '" + xFilial("DT2") + "' "
		cQuery += "   AND DT2_CODOCO = DUA_CODOCO "
		
		If lTipIns
			cQuery += "   AND (DT2_CMPENT = '1' Or DT2_TIPINS <> '') "
		Else
			cQuery += "   AND DT2_CMPENT = '1' "
		EndIf

		cQuery += "   AND DT2.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "   AND DUD_FILORI = '" + cFilOri + "' "
		cQuery += "   AND DUD_VIAGEM = '" + cViagem + "' "
		cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDUD)

		(cArqTrb)->(DbSetOrder(1))
		While (cAliasDUD)->(!Eof())
			RecLock((cArqTrb),.T.)
			(cArqTrb)->TRB_FILDOC := (cAliasDUD)->DUD_FILDOC
			(cArqTrb)->TRB_DOC    := (cAliasDUD)->DUD_DOC
			(cArqTrb)->TRB_SERIE  := (cAliasDUD)->DUD_SERIE
			(cArqTrb)->(MsUnlock())
			(cAliasDUD)->(DbSkip())
		EndDo
		(cAliasDUD)->(DbCloseArea())
	EndIf
ElseIf nAcao == 2	//-- Painel de Agendamentos
	aCab   := StrTokArr(StrTran(aAgends[1],"'",""),",")
	aItens := StrTokArr(StrTran(aAgends[2],"'",""),",")
	DF1->(DbSetOrder(1))
	DTC->(DbSetOrder(8))
	For nCntFor1 := 1 To Len(aCab)
		If DF1->(DbSeek(xFilial("DF1") + aCab[1] + aItens[1]))
			If DTC->(DbSeek(xFilial("DTC") + DF1->(DF1_FILDOC + DF1_DOC)))
				While DTC->(!Eof()) .And. DTC->(DTC_FILIAL + DTC_FILORI + DTC_NUMSOL) == DF1->(DF1_FILIAL + DF1_FILDOC + DF1_DOC)
					If !Empty(DTC->DTC_DOC)
						RecLock((cArqTrb),.T.)
						(cArqTrb)->TRB_FILDOC := DTC->DTC_FILDOC
						(cArqTrb)->TRB_DOC    := DTC->DTC_DOC
						(cArqTrb)->TRB_SERIE  := DTC->DTC_SERIE
						(cArqTrb)->(MsUnlock())
					EndIf
					DTC->(DbSkip())
				EndDo
			EndIf
		EndIf
	Next nCntFor1
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return

/*/{Protheus.doc} TMSCmpDel
Deleta Arquivo de Trabalho que Filtra pelo Painel de Agendamentos/Viagem
@author Valdemar Roberto Mognon
@since 30/03/2020
@version 12.1.28
@return Logico
@param 
@type function
/*/

Function TMSCmpDel(oTempTable)

If !Empty(oTempTable)
	oTempTable:Delete()	
EndIf

Return

/*/-----------------------------------------------------------
{Protheus.doc} TMSIncDM0()
Inclui o registro na DM0 de acordo com o array passado

@author Felipe Barbiere
@since 16/04/2020
-----------------------------------------------------------/*/
Function TMSIncDM0(aDados,nOpcx)
Local nCntFor	:= 0
Local aAreaDM0	:= DM0->(GetArea())
Local aArea		:= GetArea()
// Salva bloco de código do tratamento de erro
Local oError := ErrorBlock( { |e| FunHError( e, DM0->( RECNO() ), aDados ) } )

Default aDados := {}
Default nOpcx  := 0

	If nOpcx == 3	//-- Inclusao
		For nCntFor := 1 To Len(aDados)
			RecLock("DM0",.T.)
				DM0->DM0_FILIAL := xFilial("DM0")
				aEval(aDados[nCntFor],{|x| Iif(!(AllTrim(x[1]) $ "DM0_FILIAL"),DM0->(FieldPut(FieldPos(x[1]),x[2])),Nil)})
			DM0->(MsUnlock())
		Next nCntFor1
	ElseIf nOpcx == 4	//-- Alteraçao
		Begin Sequence
			RecLock("DM0",.F.)
				aEval(aDados[1],{|x| Iif(!(AllTrim(x[1]) $ "DM0_FILIAL"),DM0->(FieldPut(FieldPos(x[1]),x[2])),Nil)})
			DM0->(MsUnlock())
		End Sequence
		ErrorBlock(oError)
	EndIf

RestArea(aArea)
RestArea(aAreaDM0)

Return Nil

/*/-----------------------------------------------------------
{Protheus.doc} TMSChkTok()
Obtém Token do APP Meu Check-List

@author Caio Murakami
@since 16/04/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSChkTok( cId , cSecret , cAcrValues , cUrlTok , cUser , cPassword , cSequen )
Local oCheck  		:= TMSBCAMeuChecklist():New()  
Local lRet			:= .T. 

Default cID			:= ""
Default cSecret		:= ""
Default cAcrValues	:= ""
Default cUrlTok		:= ""
Default cUser		:= ""
Default cPassword	:= ""
Default cSequen		:= ""

If !Empty(cUrlTok) .And. Right(AllTrim(cUrlTok),1) != "/"
	cUrlTok := AllTrim(cUrlTok) + "/"
EndIf

cResult	:= oCheck:GetToken( cUrlTok,  cId , cSecret , cAcrValues , cUser , cPassword , cSequen ) 

If Empty(cResult)
	lRet	:= .F. 
	cResult	:= oCheck:GetLastError()
Endif

FwFreeObj(oCheck)

Return { lRet , cResult }


/*{Protheus.doc} TMSListE
Realiza a consulta no serviço do Meu Checklist pelos executores
@author Rodrigo.Pirolo
@since 17/04/2020
@version 12
*/

Function TMSListE()
Local aExec		As Array
Local oDlg		As Object
Local oListBox	As Object
Local lRet		As Logical
Local cNome		As Character
Local oGetNome	As Object

lRet	:= .F.
cNome	:= Space(Len(DA4_NOME))

If TMSDLZAti() // Verifica se existe parametro de CheckList Ativo
	aExec  := TMSLeExec()
	If Len(aExec) > 0
		DEFINE MSDIALOG oDlg TITLE STR0006 FROM 180, 180 TO 530, 910 PIXEL // STR0006 "Meu Check List - Executores"
			@ 005, 005 LISTBOX oListBox FIELDS HEADER STR0007, STR0008, STR0009 SIZE 360, 150 OF oDlg PIXEL //STR0007 "Nome" STR0008 "External ID" STR0009 "ID"
			oListBox:SetArray( aExec )
			oListBox:bLine := { | | { 	aExec[oListBox:nAt][1], aExec[oListBox:nAt][2], aExec[oListBox:nAt][3] } }

			@ 160, 200 MSGet oGetNome VAR cNome SIZE 60,10 OF oDlg PIXEL Picture PesqPict("DA4","DA4_NOME")
			oGetNome:bHelp := { || ShowHelpCpo( STR0025, { STR0026 }, 2, {""}, 2 ) }//STR0025 "Filtre por Nome" STR0026 "Filtre por parte ou pelo nome completo. Se o termo usado no Filtro não existir na base de dados, o sistema retornará todos os dados presentes no App Meu Checklist."

			DEFINE SButton FROM 160, 265 TYPE 17 ENABLE OF oDlg ACTION (	oListBox:nAt := 1,;
																			aExec := TMSLeExec( AllTrim(cNome), aExec),;
																			oListBox:SetArray( aExec ),;
																			oListBox:bLine := { | | { 	aExec[oListBox:nAt][1], aExec[oListBox:nAt][2], aExec[oListBox:nAt][3] } },;
																			oListBox:Refresh(),;
																			oDlg:Refresh() )
			DEFINE SButton FROM 160, 300 TYPE 1 ENABLE OF oDlg ACTION ( lRet := .T., Var_IXB := aExec[oListBox:nAt][3], oDlg:End() )
			DEFINE SButton FROM 160, 335 TYPE 2 ENABLE Of oDlg ACTION oDlg:End()
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} TMSDLZAti
Verifica se existe parametro de CheckList Ativo
@author Rodrigo.Pirolo
@since 17/04/2020
@version 12
/*/
Function TMSDLZAti() As Logical
Local aArea		As Array
Local aAreaDLZ	As Array
Local lRet		As Logical

If TableInDic("DLZ") .And. lDM0
	aArea    := GetArea()
	aAreaDLZ := DLZ->(GetArea())
	lRet     := .F.
	DLZ->( DbSetOrder(2) )	
	If DLZ->( DbSeek( xFilial("DLZ") + "2" ) )
		lRet := .T.
	EndIf
	RestArea(aAreaDLZ)
	RestArea(aArea)
Else
	lRet := .F. 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetURLChk
Obtém a partir da tabela DLZ o endereço de comunicação com o Meu-Check-List

@author Caio Murakami
@since 30/04/2020
@version 12
@return Logico
@param 
@type function
/*/
//-------------------------------------------------------------------
Static Function GetURLChk()
Local cUrl		:= ""
Local aArea		:= {} 

If TableInDic("DLZ")
	aArea	:= DLZ->(GetArea())

	DLZ->(dbSetOrder(2))
	If DLZ->( MsSeek(xFilial("DLZ") + "2" ) )
		cUrl	:= RTrim(DLZ->DLZ_URLCHK)

		If RAt("/",cUrl) == Len(cUrl)
			cUrl	:= SubStr( cUrl , 1 , Len(cUrl) - 1 )
		EndIf

	EndIf

	RestArea(aArea)
EndIf

Return cUrl

//--------------------------------------------------------------------
/*/{Protheus.doc} GetScrChk
Realiza a busca do ID do roteiro do checklist
@author Valdemar Roberto Mognon
@since 10/10/2020
@version 12.1.28
@return Logico
@param Tipo de documento
@type function
/*/
//--------------------------------------------------------------------
Function GetScrChk(cTipDoc)
Local cRet   := ""
Local aAreas := {DLZ->(GetArea()),GetArea()}

Default cTipDoc := ""

If TableInDic("DLZ")
	DLZ->(DbSetOrder(2))
	If DLZ->(DbSeek(xFilial("DLZ") + "2"))
		cRet := AllTrim(Iif(cTipDoc == "COL",DLZ->DLZ_SCRCOL,DLZ->DLZ_SCRENT))
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return cRet

//-----------------------------------------------------------------
/*/{Protheus.doc} AtuDM0Int()

Atualiza o ID Integração com a tabela DM0

@author Caio Murakami
@since 07/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Function AtuDM0Int( cFilDoc, cDoc , cSerie , cIdInt , cIniInt, cFimInt , cFilOri, cViagem, lSaiApoio )
Local lRet			:= .T. 
Local aAreas        := {DM0->(GetArea()),DT6->(GetArea()),GetArea()}
Local cDMStatus     := StrZero(1,Len(DM0->DM0_STATUS))

Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""
Default cIdInt		:= ""
Default cIniInt		:= ""
Default cFimInt		:= ""
Default cFilOri		:= ""
Default cViagem		:= ""
DEFAULT lSaiApoio   := .F.

If lSaiApoio
	cDMStatus := StrZero(3,Len(DM0->DM0_STATUS))
EndIf

//-- FILDOC+DOC+SERIE
DM0->(dbSetOrder(1))
If !DM0->( MsSeek( xFilial("DM0") + cFilDoc + cDoc + cSerie ))
	RecLock("DM0",.T.)
	DM0->DM0_FILIAL := xFilial("DM0")
	DM0->DM0_FILDOC := cFilDoc
	DM0->DM0_DOC    := cDoc
	DM0->DM0_SERIE  := cSerie
	DM0->DM0_STATUS := cDMStatus
	DM0->DM0_IDINTG := cIdInt
	DM0->DM0_INIINT := cIniInt
	DM0->DM0_FIMINT := cFimInt
	DM0->( MsUnlock())
EndIf

//-- Atualiza a DLY
If cSerie != "COL"
	DT6->(DbSetOrder(1))
	If DT6->(DbSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie)) .And. !Empty(DT6->DT6_CHVCTE) .And. !DT6->DT6_DOCTMS $ "5,D,F,G"
		AtuDLYInt( cFilOri, cViagem , cFilDoc, cDoc , cSerie , cIdInt , cIniInt, cFimInt )
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} DelDM0()

Apaga ID de integração na DM0

@author Caio Murakami
@since 07/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Function DelDM0( cIdInt , cFilOri , cViagem )
Local aAreas    := {DM0->(GetArea()),DT6->(GetArea()),GetArea()}
Local lRet		:= .T. 
Local cFilDoc	:= ""
Local cDoc		:= ""
Local cSerie	:= ""
Local lDM0Pos	:= DM0->(FieldPos("DM0_IDMPOS")) > 0

Default cIdInt		:= ""
Default cFilOri		:= ""
Default cViagem		:= ""

DM0->(dbSetOrder(2)) //-- ID CHK
If DM0->( MsSeek( xFilial("DM0") + RTrim(cIdInt) ) )
	
	cFilDoc		:= DM0->DM0_FILDOC
	cDoc		:= DM0->DM0_DOC
	cSerie		:= DM0->DM0_SERIE
	
	If lDM0Pos .AND. !Empty(DM0->DM0_IDMPOS)
 		TMSDelDAV(DM0->DM0_IDMPOS)
	EndIf

	RecLock("DM0",.F.)
		DM0->( dbDelete() )
	DM0->(MsUnlock())
Else
	lRet	:= .F. 
Endif

If lRet .And. cSerie != "COL"
	DT6->(DbSetOrder(1))
	If DT6->(DbSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie)) .And. !Empty(DT6->DT6_CHVCTE) .And. !DT6->DT6_DOCTMS $ "5,D,F,G"
		DelDLY( cFilOri, cViagem , cFilDoc , cDoc , cSerie )
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} AtuDLYInt()

Atualiza o ID Integração com a tabela DLY

@author Caio Murakami
@since 07/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function AtuDLYInt( cFilOri, cViagem , cFilDoc, cDoc , cSerie , cIdInt , cIniInt, cFimInt )
Local lRet		:= .T. 
Local aArea		:= GetArea()
Local aAreaDLY	:= DLY->(GetArea())
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()
Local aRet		:= {}
Local aDLY		:= {}
Local nCount	:= 1
Local nOpcx		:= 3 
Local lDLYDOC	:= DLY->(FieldPos("DLY_FILDOC")) > 0 .AND. DLY->(FieldPos("DLY_DOC")) > 0 .AND. DLY->(FieldPos("DLY_SERIE")) > 0
Local nPosIdIn	:= 0
Local nPosIni	:= 0
Local nPosFim	:= 0

Default cFilOri		:= ""
Default cViagem		:= ""
Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""
Default cIdInt		:= ""
Default cIniInt		:= ""
Default cFimInt		:= ""

cQuery	:= " SELECT DT6_CHVCTE , DTC_CLIREM , DTC_LOJREM , DTC_NUMNFC , DTC_SERNFC , DTC_EMINFC, DTC_NFEID "
cQuery	+= " FROM " + RetSqlName("DUD") +  " DUD "
cQuery	+= " INNER JOIN " + RetSqlName("DT6") + " DT6 "
cQuery	+= " ON DT6_FILIAL 			= '" + xFilial("DT6") + "' "
cQuery	+= " 	AND DT6_FILDOC		= DUD_FILDOC "
cQuery	+= " 	AND DT6_DOC			= DUD_DOC "
cQuery	+= " 	AND DT6_SERIE		= DUD_SERIE "
cQuery	+= " 	AND DT6.D_E_L_E_T_ 	= '' "
cQuery	+= " INNER JOIN " + RetSqlName("DTC") + " DTC " 
cQuery	+= "	ON DTC_FILIAL 	= '" + xFilial("DTC") + "' "
cQuery	+= " 	AND DTC_FILDOC		= DT6_FILDOC "
cQuery	+= " 	AND DTC_DOC			= DT6_DOC "
cQuery	+= " 	AND DTC_SERIE		= DT6_SERIE "
cQuery	+= " 	AND DTC.D_E_L_E_T_ = '' "
cQuery	+= " WHERE DUD_FILIAL 		= '" + xFilial("DUD") + "' "
cQuery	+= " 	AND DUD_FILORI		= '" + cFilOri	+ "' " 
cQuery	+= "	AND DUD_VIAGEM		= '" + cViagem + "' "
cQuery	+= " 	AND DUD_FILDOC		= '" + cFilDoc + "' "
cQuery	+= " 	AND DUD_DOC			= '" + cDoc + "' "
cQuery	+= " 	AND DUD_SERIE		= '" + cSerie + "' "
cQuery	+= " 	AND DUD.D_E_L_E_T_ = '' "

cQuery	:= ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

//-- Transforma para tipo Data
TCSetField(cAliasQry,"DTC_EMINFC","D",8,0)
	
While (cAliasQry)->( !Eof() )

	aDLY	:= {} 

	Aadd(aDLY,{"DLY_CLIREM", (cAliasQry)->DTC_CLIREM	,Nil})
	Aadd(aDLY,{"DLY_LOJREM", (cAliasQry)->DTC_LOJREM	,Nil})
	Aadd(aDLY,{"DLY_NUMNFC", (cAliasQry)->DTC_NUMNFC	,Nil})
	Aadd(aDLY,{"DLY_SERNFC", (cAliasQry)->DTC_SERNFC	,Nil})
	Aadd(aDLY,{"DLY_EMINFC", (cAliasQry)->DTC_EMINFC	,Nil})
	Aadd(aDLY,{"DLY_STATUS","1"                			,Nil})	//-- 1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
	Aadd(aDLY,{"DLY_IDREVE",""                 			,Nil})
	Aadd(aDLY,{"DLY_RETEVE",""                 			,Nil})
	Aadd(aDLY,{"DLY_NFEID" , (cAliasQry)->DTC_NFEID 	,Nil})
	Aadd(aDLY,{"DLY_CHVCTE", (cAliasQry)->DT6_CHVCTE 	,Nil})
	Aadd(aDLY,{"DLY_TIPEVE", "1"                		,Nil})	//-- 1=Envio;2=Cancelamento
	Aadd(aDLY,{"DLY_TIPCAN", "0"                		,Nil})	//-- 0=Não se Aplica;1=Manual;2=Automático
	Aadd(aDLY,{"DLY_DATENT", dDataBase          		,Nil})
	Aadd(aDLY,{"DLY_IDINTG", cIdInt             		,Nil})
	Aadd(aDLY,{"DLY_HORENT", SubStr(Time(),1,2) + SubStr(Time(),4,2) ,Nil})
	If lDLYDOC
		Aadd(aDLY,{"DLY_FILDOC", cFilDoc					,Nil})
		Aadd(aDLY,{"DLY_DOC"   , cDoc						,Nil})
		Aadd(aDLY,{"DLY_SERIE" , cSerie						,Nil})
	EndIf
	Aadd(aDLY,{"DLY_FILORI", cFilOri					,Nil})
	Aadd(aDLY,{"DLY_VIAGEM", cViagem					,Nil})
	Aadd(aDLY,{"DLY_INIINT", cIniInt					,Nil})
	Aadd(aDLY,{"DLY_FIMINT", cFimInt					,Nil})

	Aadd( aRet, aClone(aDLY) )
	
	(cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->( dbCloseArea() )

If Len(aRet) > 0
	nPosIdIn:= AScan( aRet[1], { |x| x[1] == "DLY_IDINTG" } )
	nPosIni	:= AScan( aRet[1], { |x| x[1] == "DLY_INIINT" } )
	nPosFim	:= AScan( aRet[1], { |x| x[1] == "DLY_FIMINT" } )
	DLY->( dbSetOrder(1) )
	//-- Realiza inclusão na DLY
	For nCount := 1 To Len( aRet )
		
		//-- DLY_FILIAL+DLY_CLIREM+DLY_LOJREM+DLY_NUMNFC+DLY_SERNFC+DTOS(DLY_EMINFC)+DLY_SEQEVE
		
		If DLY->( MsSeek( xFilial("DLY") + aRet[nCount][1,2] + aRet[nCount][2,2] + aRet[nCount][3,2] + aRet[nCount][4,2] + DToS(aRet[nCount][5,2])) )
			nOpcx 	:= 4
			If Empty(aRet[nCount][nPosIdIn][2])    //Se vier em branco do TMSA360 inclui valores no array direto da tabela
				aRet[nCount][nPosIdIn][2] := AllTrim(DLY->DLY_IDINTG)
			EndIf

			If Empty(aRet[nCount][nPosIni][2])	
				aRet[nCount][nPosIni][2] := AllTrim( DLY->DLY_INIINT)
			EndIf
			
			If Empty(aRet[nCount][nPosFim][2])	
				aRet[nCount][nPosFim][2] := Alltrim(DLY->DLY_FIMINT)
			EndIf

		Else
			nOpcx	:= 3 
		EndIf

		//-- Grava DLY
		TMSIncDLY( aClone(aRet[nCount]) ,nOpcx )

	Next nCount
EndIf
//-- Libera memória de array
FwFreeArray(aDLY)
FwFreeArray(aRet)

//-- Restaura áreas
RestArea( aAreaDLY )
RestArea( aArea )
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} DelDLY()

Excluir DLY

@author Caio Murakami
@since 07/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function DelDLY( cFilOri, cViagem , cFilDoc , cDoc , cSerie )
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()
Local lDLYDOC	:= DLY->(FieldPos("DLY_FILDOC")) > 0 .AND. DLY->(FieldPos("DLY_DOC")) > 0 .AND. DLY->(FieldPos("DLY_SERIE")) > 0

Default cFilOri		:= ""
Default cViagem		:= ""
Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""

cQuery	:= " SELECT DLY.R_E_C_N_O_  RECNODLY "
cQuery	+= " FROM " + RetSqlName("DLY") + " DLY "
cQuery	+= " WHERE DLY_FILIAL 		= '" + xFilial("DLY") + "' "
cQuery	+= " 	AND DLY_FILORI		= '" + cFilOri + "' "
cQuery	+= " 	AND DLY_VIAGEM		= '" + cViagem + "' "
If lDLYDOC
	cQuery	+= " 	AND DLY_FILDOC		= '" + cFilDoc + "' "
	cQuery	+= " 	AND DLY_DOC			= '" + cDoc + "' "
	cQuery	+= " 	AND DLY_SERIE		= '" + cSerie + "' "
EndIf
cQuery	+= " 	AND DLY.D_E_L_E_T_ 	= '' "

cQuery	:= ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

While (cAliasQry)->( !Eof() )
	
	//-- Excluir DLY
	DLY->(DbGoTo( (cAliasQry)->RECNODLY ))
	TMSIncDLY(,5)

	(cAliasQry)->( dbSkip() )
EndDo


(cAliasQry)->(dbCloseArea())

RestArea( aArea )
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} GetDriverID()

Obtém ID do motorista

@author Caio Murakami
@since 07/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function GetDriverID( cFilOri, cViagem )
Local cHasExe	:= ""
Local aAreas  := {DA4->(GetArea()),DLZ->(GetArea()),DTQ->(GetArea()),DUP->(GetArea()),GetArea()}
Local oColEnt

DTQ->(DbSetOrder(2))
DTQ->(DbSeek(xFilial("DTQ") + cFilOri + cViagem))

DUP->(DbSetOrder(1))
DUP->(DbSeek(xFilial("DUP") + cFilOri + cViagem))

If FindFunction("BSCIDMOT") .And. FindFunction("TMSAC30") .And. AliasInDic("DN0")
	oColEnt := TMSBCACOLENT():New("DLZ")
	If oColEnt:DbGetToken()
		DLZ->(DbGoTo(oColEnt:config_recno))
		cHasExe := AllTrim(BscIDMot(DUP->DUP_CODMOT,DLZ->DLZ_CODFON,.T.))
	EndIf
Else
	DA4->(DbSetOrder(1))
	DA4->(DbSeek(xFilial("DA4") + DUP->DUP_CODMOT))
	cHasExe := RTrim(DA4->DA4_APPLOG)
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cHasExe

//--------------------------------------------------------------------
/*/{Protheus.doc} TMSImgDM0
Verifica se existe imagem gravada na tabela de imagens do Check List
@author Valdemar Roberto Mognon
@since 30/04/2020
@version 12.1.28
@return Logico
@param Chave eletronica do CTe
@type function
/*/
//--------------------------------------------------------------------
Function TMSImgDM0(cFilDoc,cDoc,cSerie)
Local lRet   := .F.
Local aAreas := {DM0->(GetArea()),GetArea()}

DM0->(DbSetOrder(1))
If DM0->(DbSeek(xFilial("DM0") + cFilDoc + cDoc + cSerie)) .And. !Empty(DM0->DM0_EXTENS)
	lRet := .T.
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return lRet

/*/{Protheus.doc} TMSChkDM0
Pega o cheklist da DM0
@author Valdemar Roberto Mognon
@since 10/10/2020
@version 12.1.25
@return Undefined
@param 
@type function
/*/

Function TMSChkDM0()
Local aRet      := {}
Local aVetWrk   := {}
Local aAreas    := {DUD->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasDM0 := ""
Local nRecDUD   := ""

cAliasDM0 := GetNextAlias()
cQuery := " SELECT DM0.R_E_C_N_O_ DM0_RECNO, DM0.DM0_IDINTG DM0_IDINTG, DM0.DM0_DATREA DM0_DATREA, DM0.DM0_HORREA DM0_HORREA "
cQuery += 		" ,DT6.DT6_FILDOC DT6_FILDOC, DT6.DT6_DOC DT6_DOC, DT6.DT6_SERIE DT6_SERIE, DT6.DT6_CHVCTE DT6_CHVCTE, DT6.DT6_CDRDES DT6_CDRDES "
cQuery += "   FROM " + RetSqlName("DM0") + " DM0 "
cQuery += "   JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += "     ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "    AND DT6.DT6_FILDOC = DM0.DM0_FILDOC "
cQuery += "    AND DT6.DT6_DOC    = DM0.DM0_DOC "
cQuery += "    AND DT6.DT6_SERIE  = DM0.DM0_SERIE "
cQuery += "    AND DT6.D_E_L_E_T_ = ' ' "
cQuery += "  WHERE DM0.DM0_FILIAL = '" + xFilial("DM0") + "' "
cQuery += "    AND DM0.DM0_IDINTG <> ' ' "
cQuery += "    AND DM0.DM0_EXTENS = ' ' "
cQuery += "    AND ( DM0.DM0_STATUS = '" + StrZero(1,Len(DM0->DM0_STATUS)) + "' OR DM0.DM0_STATUS = '" + StrZero(3,Len(DM0->DM0_STATUS)) + "' ) "
cQuery += "    AND DM0.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDM0,.F.,.T.)

While (cAliasDM0)->(!Eof())
	aVetWrk := {}

	Aadd(aVetWrk,(cAliasDM0)->DM0_RECNO)
	Aadd(aVetWrk,(cAliasDM0)->DM0_IDINTG)
	Aadd(aVetWrk,TMSConvDat(SToD((cAliasDM0)->DM0_DATREA),(cAliasDM0)->DM0_HORREA))
	Aadd(aVetWrk,TMSConvDat(SToD((cAliasDM0)->DM0_DATREA),(cAliasDM0)->DM0_HORREA))

	nRecDUD := TMSRecDUD((cAliasDM0)->DT6_FILDOC,(cAliasDM0)->DT6_DOC,(cAliasDM0)->DT6_SERIE)
	If nRecDUD != 0
		DUD->(DbGoTo(nRecDUD))
		Aadd(aVetWrk,DUD->DUD_FILORI)
		Aadd(aVetWrk,DUD->DUD_VIAGEM)
	Else
		Aadd(aVetWrk,"")
		Aadd(aVetWrk,"")
	EndIf

	Aadd(aVetWrk,"")	//-- Somente para compatibilizar com a função TMSChkDM0
	Aadd(aVetWrk,"")	//-- Somente para compatibilizar com a função TMSChkDM0

	Aadd( aVetWrk, (cAliasDM0)->DT6_FILDOC	)
	Aadd( aVetWrk, (cAliasDM0)->DT6_DOC		)
	Aadd( aVetWrk, (cAliasDM0)->DT6_SERIE	)
	Aadd( aVetWrk, (cAliasDM0)->DT6_CHVCTE	)
	Aadd( aVetWrk, (cAliasDM0)->DT6_CDRDES	)

	Aadd(aRet,aClone(aVetWrk))

	(cAliasDM0)->(DbSkip())
EndDo

(cAliasDM0)->(DbCloseArea())

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} FunHError
Função auxiliar para tratar possivel erro de DM0: TOPCONN - UpdateMemos error (-19).

@author Rodrigo Pirolo
@since 20/11/2020
@version 1.0
*/
//-------------------------------------------------------------------

Static Function FunHError( oErrorH, nRegDM0, aDados )

	Local lImagem	:= FwIsInCallStack("TMSMOVIMG")

	DEFAULT oErrorH := Nil
	DEFAULT nRegDM0	:= 0
	DEFAULT aDados	:= {}

	If !Empty( oErrorH:Description )
		Help( '', 1, "TMSXFUNHError", , STR0013 + chr(10) + oErrorH:Description, 1 ) //"Erro encontrado na Função executada: " ####
		If lImagem
			TMSGrvErr( nRegDM0 )
		EndIf
	EndIf

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} TMSImgInf
Realiza a comunicação e o tratamento do retorno do Get Metadata
@author Rodrigo Pirolo
@since 24/11/2020
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Function TMSImgInf( cPathParam, cQueryParam )

	Local aRet			:= { "", "", "", "" }
	Local oResult		:= Nil
	Local cResult		:= ""
	
	Default cPathParam	:= ""
	Default cQueryParam	:= ""
	
	cResult		:= TMSCHKLIST( "GET", cPathParam, , cQueryParam, , , , , , , .T. ) //Antigo era metadata
	
	If FWJsonDeserialize( cResult, @oResult )
		aRet := { oResult:ID, oResult:NAME, oResult:URL, HttpGet( AllTrim( oResult:URL ) ) }
	EndIf

	FwFreeObj(oResult)

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMSGrvErr
Realiza a gravação da mensagem de erro na DM0
@author Rodrigo Pirolo
@since 24/11/2020
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Function TMSGrvErr( nRegDM0 )

	Local lRet := .F.

	Default nRegDM0	:= 0

	If nRegDM0 > 0
		lRet := .T.
		DM0->( DbGoTo( nRegDM0 ) )
		RecLock( "DM0", .F. )
			DM0->DM0_IMAGEM := ""
			DM0->DM0_EXTENS := ""
			DM0->DM0_OBSERV := STR0014 //"A imagem ultrapassou o limite de 10 mb. Realizar o upload via Protheus."
		DM0->(MsUnlock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMSGrvErr
Realiza a gravação da mensagem de erro na DM0
@author Rodrigo Pirolo
@since 02/06/2020
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Function TMSReevCh( aMsgErr, aReenvC )

	Local lRet		:= .F.
	Local aDocsChk	:= {}
	Local aMsg		:= {}
	Local nX		:= 0
	Local nY		:= 0

	Default aMsgErr	:= {}
	Default aReenvC	:= {}

	If Len(aReenvC) > 0
		aDocsChk:= AClone(aReenvC)
		aReenvC	:= {}
		Processa( { || TMSEnvChk( aDocsChk, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, @aMsg, @aReenvC ) }, STR0015, STR0016 ) //"Integração Protheus TMS x Meu Checklist" "Aguarde..."
		
		For nX := 1 To Len(aMsg)
			For nY := 1 To Len(aMsgErr)
				If PadR(aMsg[nX,1],40) $ aMsgErr[nY,1]
					aMsgErr[nY,1] := aMsg[nX,1]
				EndIf
			Next nY
		Next nX

		lRet := Len(aReenvC) == 0
	Else
		Help( '', 1, "TMSXFUNH", , STR0017, 1 ) // "A Viagem não possui documentos pendentes de integração."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMSButCh
Realiza a gravação da mensagem de erro na DM0
@author Rodrigo Pirolo
@since 07/06/2020
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Function TMSButCh()

	Local aSays		:= {}
	Local aButtons	:= {}
	Local aArea		:= GetArea()
	Local aAreaDTX	:= DTX->( GetArea() )
	Local aAreaDTQ	:= DTQ->( GetArea() )
	Local aAreaDTW	:= DTW->( GetArea() )
	Local aAreaDUA	:= DUA->( GetArea() )
	Local aAreaDTR	:= DTR->( GetArea() )
	Local aAreaDUV	:= DUV->( GetArea() )
	Local aAreaDA3	:= DA3->( GetArea() )
	Local cFilOri	:= DTQ->DTQ_FILORI
	Local cViagem	:= DTQ->DTQ_VIAGEM
		
	Local lFechada	:= DTQ->DTQ_STATUS == '5'
	Local lTransi	:= DTQ->DTQ_STATUS == '2'
	Local aMsgChk	:= {}
	Local aDocsChk	:= {}
	Local aReenvC	:= {}
	Local nX		:= 0
	Local nY		:= 0
	Local nPos		:= 0
	Local lFecha	:= SuperGetMV( "MV_TMINTEV", , "" ) == "1"
	Local lContinua	:= .F.
	Local cHelp     := ""

	// Busca os documentos da viagem
	aDocsChk := TMSLstChk( cFilOri, cViagem )
	
	If lFecha .And. ( lFechada .Or. lTransi )
		lContinua := .T.
	ElseIf !lFecha .And. lTransi
		lContinua := .T.
	EndIf

	If lContinua
		For nX := 1 To Len( aDocsChk )
			For nY := 1 To Len( aDocsChk[nX,4] )

				lFeito := VerInteg( aDocsChk[nX,4,nY,1], aDocsChk[nX,4,nY,2], aDocsChk[nX,4,nY,3] )

				If !lFeito
					
					nPos := AScan( aReenvC, { |x| x[2] + x[3] == aDocsChk[nX,2] + aDocsChk[nX,3] } )

					If nPos == 0
						AAdd( aReenvC, { aDocsChk[nX][1], aDocsChk[nX][2], aDocsChk[nX][3], { AClone( aDocsChk[ nX ][4][nY] ) } } )
					Else
						AAdd( aReenvC[nPos][4], AClone( aDocsChk[ nX ][4][nY] ) )
					EndIf

					nPos := 0

				EndIf

			Next nY

		Next nX

		aDocsChk	:= {}
		aDocsChk	:= AClone( aReenvC )
		aReenvC		:= {}
		aMsgChk		:= {}

		If Len(aDocsChk) > 0

			AAdd( aSays, STR0020 ) //'Este programa tem como objetivo, efetuar o reenvio dos documentos da viagem '
			AAdd( aSays, STR0021 ) //'para Integração Protheus TMS x Meu Checklist. '

			AAdd( aButtons, { 1, .T., { |o| Processa( { || TMSEnvChk( Aclone(aDocsChk), cFilOri, cViagem, @aMsgChk, @aReenvC ) , TmsMsgErr( aMsgChk, , , .T., AClone(aReenvC) ) }, STR0015, STR0016 ), o:oWnd:End() } } ) //"Integração Protheus TMS x Meu Checklist" "Aguarde..."
			AAdd( aButtons, { 2, .T., { |o| o:oWnd:End() } } )

			FormBatch( STR0015, aSays, aButtons ) //"Integração Protheus TMS x Meu Checklist"
		Else
			If lFecha
				cHelp := STR0018 //"A integração TMS x Meu Checklist está configurada para integrar no Fechamento da Viagem. Portanto a Viagem precisa estar 'Fechada' e ter documentos não integrados para utilizar esta rotina."
			Else
				cHelp := STR0019 // "A integração TMS x Meu Checklist está configurada para integrar no Apontamento de Saída da Viagem. Portanto a Viagem precisa estar 'Em Transito' e ter documentos não integrados para utilizar esta rotina."
			EndIf
			Help( '', 1, "TMSXFUNH", , STR0017, 1 ) // "A Viagem não possui documentos pendentes de integração."
		EndIf
	Else
		Help( '', 1, "TMSXFUNH", , cHelp, 1 )
	EndIf

	FwFreeArray(aDocsChk)
	FwFreeArray(aReenvC)
	FwFreeArray(aMsgChk)

	RestArea(aAreaDTX)
	RestArea(aAreaDTQ)
	RestArea(aAreaDTW)
	RestArea(aAreaDUA)
	RestArea(aAreaDTR)
	RestArea(aAreaDUV)
	RestArea(aAreaDA3)
	RestArea(aArea)

Return lContinua

//-------------------------------------------------------------------
/*{Protheus.doc} VerInteg
Verifica se documento foi gravado na DM0 e gerado ID de Integração
@author Rodrigo Pirolo
@since 07/06/2020
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Static Function VerInteg( cFilDoc, cDoc, cSerie )

	Local cQuery	:= ""
	Local cAlias	:= ""
	Local lFeito	:= .F.

	Default cFilDoc	:= ""
	Default cDoc	:= ""
	Default cSerie	:= ""

	If !Empty(cFilDoc) .AND. !Empty(cDoc) .AND. !Empty(cSerie)
		cAlias := GetNextAlias()
			cQuery :=	" SELECT DM0.DM0_IDINTG IDINTG "
			cQuery += 	" FROM " + RetSqlName("DM0") + " DM0 "
			cQuery += 	" JOIN " + RetSqlName("DT6") + " DT6 "
			cQuery += 		" ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
			cQuery += 			" AND DT6.DT6_FILDOC = DM0.DM0_FILDOC "
			cQuery += 			" AND DT6.DT6_DOC    = DM0.DM0_DOC "
			cQuery += 			" AND DT6.DT6_SERIE  = DM0.DM0_SERIE "
			cQuery += 			" AND DT6.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE DM0.DM0_FILIAL = '" + xFilial("DM0") + "' "
			cQuery += 		" AND DM0.DM0_FILDOC = '" + cFilDoc + "'"
			cQuery += 		" AND DM0.DM0_DOC = '" + cDoc + "'"
			cQuery += 		" AND DM0.DM0_SERIE = '" + cSerie + "'"
			cQuery += 		" AND DM0.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)

		DbUseArea( .T., "TOPCONN", TCGENQRY( , , cQuery ), cAlias, .F., .T. )

		If !( (cAlias)->( EOF() ) )
			If !Empty( (cAlias)->IDINTG )
				lFeito := .T.
			EndIf
		EndIf

		(cAlias)->( DbCloseArea() )
	EndIf

Return lFeito

//-------------------------------------------------------------------
/*{Protheus.doc} TMSDelDAV
Deleta DAV vinculada com a DM0
@author Rodrigo Pirolo
@since 29/10/2021
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Static Function TMSDelDAV( cIDMPos )

	Local aArea		:= GetArea()
	Local aAreaDM0	:= DM0->( GetArea() )

	Default cIDMPos := ""

	DbSelectArea("DAV")
	DAV->( DbSetOrder( 1 ) )

	If DAV->( DbSeek( FwxFilial("DAV") + cIDMPos ) )
		RecLock("DAV", .F. )
			DAV->( DbDelete() )
		DAV->( MsUnlock() )
	EndIf

	RestArea(aArea)
	RestArea(aAreaDM0)

Return .T.


/*/{Protheus.doc} TMSListU
Realiza a consulta no serviço do Meu Checklist pelos executores
@author Carlos A. Gomes Jr.
@since 17/04/2020
/*/
Function TMSListU()

Local aExec		As Array
Local oDlg		As Object
Local oListBox	As Object
Local lRet := .F.

If TMSDLZAti() // Verifica se existe parametro de CheckList Ativo
    Var_IXB := ""
    aExec   := TMSLeUnid()
	If Len(aExec) > 0
		DEFINE MSDIALOG oDlg TITLE "Meu Check List - Unidades" FROM 180, 180 TO 530, 910 PIXEL
			@ 005, 005 LISTBOX oListBox FIELDS HEADER "Nome", "Apelido", "ID" SIZE 360, 150 OF oDlg PIXEL
			oListBox:SetArray( aExec )
			oListBox:bLine := { | | { 	aExec[oListBox:nAt][1],;
										aExec[oListBox:nAt][2],;
										aExec[oListBox:nAt][3] } }
			DEFINE SButton FROM 160, 300 TYPE 1 ENABLE OF oDlg ACTION ( lRet := .T., Var_IXB := aExec[oListBox:nAt][3], oDlg:End() )
			DEFINE SButton FROM 160, 335 TYPE 2 ENABLE Of oDlg ACTION oDlg:End()
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} TMSLeUnid
Busca lista de Unidades do Foundation
Carlos A. Gomes Jr.
@since 20/01/2022
@return aRet Vetor com as unidades ativas
/*/
Static Function TMSLeUnid()

Local cQryParam	:= ""
Local nCount    := 0
Local cResult   := ""
Local oResult
Local aRet      := {}

cQryParam += "pageSize=500"
cResult   := TMSCHKLIST( "GET", "api/organizationUnit", , cQryParam, , , , , , , , .T. )

If FWJsonDeserialize( cResult, @oResult )
	If AttIsMemberOf( oResult, "items" )
		aRet := {}

        For nCount := 1 To Len( oResult:items )
            If oResult:items[nCount]:ISACTIVE
                AAdd( aRet, { Iif(!Empty(oResult:items[nCount]:NAME),DeCodeUTF8(oResult:items[nCount]:NAME),""),;
                              Iif(!Empty(oResult:items[nCount]:ALIAS),DeCodeUTF8(oResult:items[nCount]:ALIAS),""),;
                              Iif(AttIsMemberOf( oResult:items[nCount], "EXTERNALID" ),oResult:items[nCount]:EXTERNALID,"") } )
            EndIf
        Next nCount

        ASort(aRet,,,{|x,y| x[1] < y[1]})

	EndIf
EndIf

FwFreeObj(oResult)

Return aRet

/*/{Protheus.doc} TMSChkVer2
Verifica a versão a ser executada do checklist
Carlos A. Gomes Jr.
@since 21/01/2022
@Return Se versão 2 retorna .T. se versão 1 retrona .F.
/*/

Function TMSChkVer2(cVerChk, cFilExt)
Local aAreas
DEFAULT cVerChk := ""
DEFAULT cFilExt := ""

cVerChk := "v1"
cFilExt := ""
If DVL->(ColumnPos("DVL_FILEXT")) > 0
	aAreas := {GetArea("DVL"),GetArea()}
	DVL->(DbSetOrder(1))
	If DVL->(MsSeek(xFilial("DVL")+cFilAnt)) .And. !Empty(DVL->DVL_FILEXT)
		cVerChk := "v2"
		cFilExt := AllTrim(DVL->DVL_FILEXT)
	EndIf
	AEval( aAreas, { |aArea| RestArea(aArea) } )
EndIf

Return ( cVerChk == "v2" )

/*{Protheus.doc} TMSDocEnd
Busca endereço de coleta/entrega seja ele do solicitante ou cliente ou sequencia de endereço
Seguindo a regra do documento.
@author Carlos A. Gomes Jr.
@since 11/05/22
*/
#DEFINE NDOCEND_END    01
#DEFINE NDOCEND_BAIRRO 02
#DEFINE NDOCEND_CEP    03
#DEFINE NDOCEND_MUN    04
#DEFINE NDOCEND_EST    05
#DEFINE NDOCEND_CODIGO 06
#DEFINE NDOCEND_LOJA   07
#DEFINE NDOCEND_NREDUZ 08
#DEFINE NDOCEND_NOME   09
#DEFINE NDOCEND_CGC    10
#DEFINE NDOCEND_PESSOA 11
#DEFINE NDOCEND_PAIS   12
#DEFINE NDOCEND_TEL    13
#DEFINE NDOCEND_ALIAS  14
#DEFINE NDOCEND_LENVET 14

Function TMSDocEnd( cFilDoc, cDoc, cSerie, cAliasLay )
Local aAreas := { DT6->(GetArea()), DTC->(GetArea()), SA1->(GetArea()), DT5->(GetArea()), DUE->(GetArea()), DUL->(GetArea()), GetArea() }
Local aRet   := { Array(NDOCEND_LENVET), Array(NDOCEND_LENVET), Array(NDOCEND_LENVET) }

Default cFilDoc   := ""
Default cDoc      := ""
Default cSerie    := ""
Default cAliasLay := ""

	If !Empty(cAliasLay)
		aRet   := { Array(NDOCEND_LENVET), Array(NDOCEND_LENVET), Array(NDOCEND_LENVET),Array(NDOCEND_LENVET), Array(NDOCEND_LENVET), Array(NDOCEND_LENVET), Array(NDOCEND_LENVET) }
	EndIf

	DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie)) .AND. Empty(cAliasLay)
		AFill(aRet[1],"")
		aRet[1][NDOCEND_PAIS] := { "BR", "BRASIL" }
		AFill(aRet[2],"")
		aRet[2][NDOCEND_PAIS] := { "BR", "BRASIL" }
		If DT6->DT6_DOCTMS != StrZero( 1, Len(DT6->DT6_DOCTMS) )	//-- Diferente de coleta

			aRet := AClone( RetDadosCli( cFilDoc, cDoc, cSerie ) )

		Else	//-- Coleta
			DT5->(DbSetOrder(4))
			If DT5->(DbSeek(xFilial("DT5") + cFilDoc + cDoc + cSerie))
				If Empty(DT5->(DT5_CLIREM + DT5_LOJREM))
					DUE->(DbSetOrder(1))
					If DUE->(DbSeek(xFilial("DUE") + DT5->DT5_CODSOL))
						aRet[1][NDOCEND_CODIGO] := DUE->DUE_CODSOL
						aRet[3][NDOCEND_LOJA  ] := ""
						aRet[1][NDOCEND_NOME  ] := AllTrim(DUE->DUE_NOME)
						aRet[1][NDOCEND_NREDUZ] := AllTrim(DUE->DUE_NREDUZ)
						aRet[1][NDOCEND_CGC   ] := AllTrim(DUE->DUE_CGC)
						aRet[1][NDOCEND_PESSOA] := Iif(Len(aRet[1][NDOCEND_CGC]) == 11,"F","J")
						If Empty(DT5->DT5_SEQEND)
							aRet[1][NDOCEND_END   ] := AllTrim(DUE->DUE_END)
							aRet[1][NDOCEND_BAIRRO] := AllTrim(DUE->DUE_BAIRRO)
							aRet[1][NDOCEND_CEP   ] := AllTrim(DUE->DUE_CEP)
							aRet[1][NDOCEND_MUN   ] := AllTrim(DUE->DUE_MUN)
							aRet[1][NDOCEND_EST   ] := AllTrim(DUE->DUE_EST)
							aRet[1][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(DUE->DUE_DDD),"("+AllTrim(DUE->DUE_DDD)+")","")+DUE->DUE_TEL)
							aRet[1][NDOCEND_ALIAS ] := "DUE"
						Else
							aRet[1][NDOCEND_ALIAS ] := "DUL"
							DUL->(DbSetOrder(3))
							If DUL->(DbSeek(xFilial("DUL") + DT5->(DT5_CODSOL + DT5_SEQEND)))
								aRet[1][NDOCEND_END   ] := AllTrim(DUL->DUL_END)
								aRet[1][NDOCEND_BAIRRO] := AllTrim(DUL->DUL_BAIRRO)
								aRet[1][NDOCEND_CEP   ] := AllTrim(DUL->DUL_CEP)
								aRet[1][NDOCEND_MUN   ] := AllTrim(DUL->DUL_MUN)
								aRet[1][NDOCEND_EST   ] := AllTrim(DUL->DUL_EST)
								aRet[1][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(DUL->DUL_DDD),"("+AllTrim(DUL->DUL_DDD)+")","")+DUL->DUL_TEL)
							EndIf
						EndIf
					EndIf
				Else
					SA1->(DbSetOrder(1))
					If SA1->(DbSeek(xFilial("SA1") + DT5->(DT5_CLIREM + DT5_LOJREM)))
						aRet[1][NDOCEND_CODIGO] := SA1->A1_COD
						aRet[1][NDOCEND_LOJA  ] := SA1->A1_LOJA
						aRet[1][NDOCEND_NOME  ] := AllTrim(SA1->A1_NOME)
						aRet[1][NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
						aRet[1][NDOCEND_CGC   ] := AllTrim(SA1->A1_CGC)
						aRet[1][NDOCEND_PESSOA] := SA1->A1_PESSOA
						aRet[1][NDOCEND_PAIS  ] := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
						If Empty(DT5->DT5_SQEREM)
							aRet[1][NDOCEND_END   ] := AllTrim(SA1->A1_END)
							aRet[1][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
							aRet[1][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
							aRet[1][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
							aRet[1][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
							aRet[1][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
							aRet[1][NDOCEND_ALIAS ] := "SA1"
						Else
							aRet[1][NDOCEND_ALIAS ] := "DUL"
							DUL->(DbSetOrder(2))
							If DUL->(DbSeek(xFilial("DUL") + DT5->(DT5_CLIREM + DT5_LOJREM + DT5_SQEREM)))
								aRet[1][NDOCEND_END   ] := AllTrim(DUL->DUL_END)
								aRet[1][NDOCEND_BAIRRO] := AllTrim(DUL->DUL_BAIRRO)
								aRet[1][NDOCEND_CEP   ] := AllTrim(DUL->DUL_CEP)
								aRet[1][NDOCEND_MUN   ] := AllTrim(DUL->DUL_MUN)
								aRet[1][NDOCEND_EST   ] := AllTrim(DUL->DUL_EST)
								aRet[1][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(DUL->DUL_DDD),"("+AllTrim(DUL->DUL_DDD)+")","")+DUL->DUL_TEL)
							EndIf
						EndIf
					EndIf
				EndIf
				If !Empty(DT5->(DT5_CLIDES + DT5_LOJDES)) .And. SA1->(DbSeek(xFilial("SA1") + DT5->(DT5_CLIDES + DT5_LOJDES)))
					aRet[2][NDOCEND_CODIGO] := SA1->A1_COD
					aRet[2][NDOCEND_LOJA  ] := SA1->A1_LOJA
					aRet[2][NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
					aRet[2][NDOCEND_NOME  ] := AllTrim(SA1->A1_NOME)
					aRet[2][NDOCEND_CGC   ] := AllTrim(SA1->A1_CGC)
					aRet[2][NDOCEND_PESSOA] := SA1->A1_PESSOA
					aRet[2][NDOCEND_PAIS  ] := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }

					If Empty(DT5->DT5_SQEDES)
						aRet[2][NDOCEND_END   ] := AllTrim(SA1->A1_END)
						aRet[2][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
						aRet[2][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
						aRet[2][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
						aRet[2][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
						aRet[2][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
						aRet[1][NDOCEND_ALIAS ] := "SA1"
					Else
						aRet[1][NDOCEND_ALIAS ] := "DUL"
						DUL->(DbSetOrder(2))
						If DUL->(DbSeek(xFilial("DUL") + DT5->(DT5_CLIDES + DT5_LOJDES + DT5_SQEDES)))
							aRet[2][NDOCEND_END   ] := AllTrim(DUL->DUL_END)
							aRet[2][NDOCEND_BAIRRO] := AllTrim(DUL->DUL_BAIRRO)
							aRet[2][NDOCEND_CEP   ] := AllTrim(DUL->DUL_CEP)
							aRet[2][NDOCEND_MUN   ] := AllTrim(DUL->DUL_MUN)
							aRet[2][NDOCEND_EST   ] := AllTrim(DUL->DUL_EST)
							aRet[2][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(DUL->DUL_DDD),"("+AllTrim(DUL->DUL_DDD)+")","")+DUL->DUL_TEL)
						EndIf
					EndIf
				EndIf
				If !Empty(DT5->(DT5_CLIDEV + DT5_LOJDEV)) .And. SA1->(DbSeek(xFilial("SA1") + DT5->(DT5_CLIDEV + DT5_LOJDEV)))
					aRet[3][NDOCEND_CODIGO] := SA1->A1_COD
					aRet[3][NDOCEND_LOJA  ] := SA1->A1_LOJA
					aRet[3][NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
					aRet[3][NDOCEND_NOME  ] := AllTrim(SA1->A1_NOME)
					aRet[3][NDOCEND_CGC   ] := AllTrim(SA1->A1_CGC)
					aRet[3][NDOCEND_PESSOA] := SA1->A1_PESSOA
					aRet[3][NDOCEND_PAIS  ] := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
					aRet[3][NDOCEND_END   ] := AllTrim(SA1->A1_END)
					aRet[3][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
					aRet[3][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
					aRet[3][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
					aRet[3][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
					aRet[3][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
					aRet[1][NDOCEND_ALIAS ] := "SA1"
				Else 
					DUE->(DbSetOrder(1))
					If DUE->(DbSeek(xFilial("DUE") + DT5->DT5_CODSOL))
						aRet[3][NDOCEND_CODIGO] := DUE->DUE_CODSOL
						aRet[3][NDOCEND_LOJA  ] := ""
						aRet[3][NDOCEND_NOME  ] := AllTrim(DUE->DUE_NOME)
						aRet[3][NDOCEND_NREDUZ] := AllTrim(DUE->DUE_NREDUZ)
						aRet[3][NDOCEND_CGC   ] := AllTrim(DUE->DUE_CGC)
						aRet[3][NDOCEND_PESSOA] := Iif(Len(aRet[1][NDOCEND_CGC]) == 11,"F","J")
						If Empty(DT5->DT5_SEQEND)
							aRet[3][NDOCEND_END   ] := AllTrim(DUE->DUE_END)
							aRet[3][NDOCEND_BAIRRO] := AllTrim(DUE->DUE_BAIRRO)
							aRet[3][NDOCEND_CEP   ] := AllTrim(DUE->DUE_CEP)
							aRet[3][NDOCEND_MUN   ] := AllTrim(DUE->DUE_MUN)
							aRet[3][NDOCEND_EST   ] := AllTrim(DUE->DUE_EST)
							aRet[3][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(DUE->DUE_DDD),"("+AllTrim(DUE->DUE_DDD)+")","")+DUE->DUE_TEL)
							aRet[1][NDOCEND_ALIAS ] := "DUE"
						Else
							aRet[1][NDOCEND_ALIAS ] := "DUL"
							DUL->(DbSetOrder(3))
							If DUL->(DbSeek(xFilial("DUL") + DT5->(DT5_CODSOL + DT5_SEQEND)))
								aRet[3][NDOCEND_END   ] := AllTrim(DUL->DUL_END)
								aRet[3][NDOCEND_BAIRRO] := AllTrim(DUL->DUL_BAIRRO)
								aRet[3][NDOCEND_CEP   ] := AllTrim(DUL->DUL_CEP)
								aRet[3][NDOCEND_MUN   ] := AllTrim(DUL->DUL_MUN)
								aRet[3][NDOCEND_EST   ] := AllTrim(DUL->DUL_EST)
								aRet[3][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(DUL->DUL_DDD),"("+AllTrim(DUL->DUL_DDD)+")","")+DUL->DUL_TEL)
							EndIf
						EndIf
					EndIf 	
				EndIf 
			EndIf
		EndIf
	Else
		aRet := AClone( RetDadosCli( cFilDoc, cDoc, cSerie, cAliasLay ) )
	EndIf

	aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} RetDadosCli
Retorna dados dos clientes envolvidos no documento

@author		Rodrigo Pirolo
@since		24/08/2022
@version	12.1.27
@return		Array
@param		cFilDoc - Filial do Documento 
@param		cDoc - Numero do documento
@param		cSerie - Serie do Documento
@type function
*/
//-------------------------------------------------------------------

Static Function RetDadosCli( cFilDoc, cDoc, cSerie, cAliasLay )

	Local aAreas		:= { DT6->(GetArea()), SA1->(GetArea()), SYA->(GetArea()), DUL->(GetArea()), GetArea() }
	Local aRet			:= { Array(NDOCEND_LENVET), Array(NDOCEND_LENVET), Array(NDOCEND_LENVET) }
	Local cCliDev		:= ""
	Local cLojDev		:= ""
	Local aFieldSM0     := {    "M0_ENDENT" ,;  //Posição [1]
                                "M0_ESTENT" ,;  //Posição [2]
                                "M0_CODMUN" ,;  //Posição [3]
                                "M0_NOME"   ,;  //Posição [4]
                                "M0_CGC"    ,;  //Posição [5]
                                "M0_BAIRENT",;  //Posição [6]
                                "M0_CEPENT"	,;	//Posição [7]
								"M0_TEL"	}   //Posição [8]
	Local aSM0Dados		:= {}

	Default cFilDoc		:= ""
	Default cDoc		:= ""
	Default cSerie		:= ""
	Default cAliasLay	:= "DT6"
	
	If !Empty(cAliasLay)
		aRet   := { Array(NDOCEND_LENVET), Array(NDOCEND_LENVET), Array(NDOCEND_LENVET),Array(NDOCEND_LENVET), Array(NDOCEND_LENVET), Array(NDOCEND_LENVET), Array(NDOCEND_LENVET) }
	EndIf

	DT6->(DbSetOrder(1))  //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE                                                                                                                         
	If DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1") + DT6->(DT6_CLIDES + DT6_LOJDES)))
			aRet[1][NDOCEND_CODIGO] := SA1->A1_COD
			aRet[1][NDOCEND_LOJA  ] := SA1->A1_LOJA
			aRet[1][NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
			aRet[1][NDOCEND_NOME  ] := AllTrim(SA1->A1_NOME)
			aRet[1][NDOCEND_CGC   ] := AllTrim(SA1->A1_CGC)
			aRet[1][NDOCEND_PESSOA] := SA1->A1_PESSOA
			aRet[1][NDOCEND_PAIS  ] := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
			If Empty(DT6->DT6_SQEDES) .Or. AllTrim(DT6->DT6_DOCTMS) == StrZero( 6, Len( DT6->DT6_DOCTMS ) ) //Para os casos de CTe de devolução onde não teremos sequencia de entrega, pois o destinatário virou remetente.
				aRet[1][NDOCEND_END   ] := AllTrim(SA1->A1_END)
				aRet[1][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
				aRet[1][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
				aRet[1][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
				aRet[1][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
				aRet[1][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
				aRet[1][NDOCEND_ALIAS ] := "SA1"
			Else
				DUL->(DbSetOrder(2))
				If DUL->(DbSeek(xFilial("DUL") + DT6->(DT6_CLIDES + DT6_LOJDES + DT6_SQEDES)))
					aRet[1][NDOCEND_END   ] := AllTrim(DUL->DUL_END)
					aRet[1][NDOCEND_BAIRRO] := AllTrim(DUL->DUL_BAIRRO)
					aRet[1][NDOCEND_CEP   ] := AllTrim(DUL->DUL_CEP)
					aRet[1][NDOCEND_MUN   ] := AllTrim(DUL->DUL_MUN)
					aRet[1][NDOCEND_EST   ] := AllTrim(DUL->DUL_EST)
					aRet[1][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(DUL->DUL_DDD),"("+AllTrim(DUL->DUL_DDD)+")","")+DUL->DUL_TEL)
					aRet[1][NDOCEND_ALIAS ] := "DUL"
				Else
					aRet[1][NDOCEND_END   ] := AllTrim(SA1->A1_END)
					aRet[1][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
					aRet[1][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
					aRet[1][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
					aRet[1][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
					aRet[1][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)	
					aRet[1][NDOCEND_ALIAS ] := "SA1"
				EndIf
			EndIf
		EndIf
		
		If SA1->(DbSeek(xFilial("SA1") + DT6->(DT6_CLIREM + DT6_LOJREM)))
			aRet[2][NDOCEND_CODIGO] := SA1->A1_COD
			aRet[2][NDOCEND_LOJA  ] := SA1->A1_LOJA
			aRet[2][NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
			aRet[2][NDOCEND_NOME  ] := AllTrim(SA1->A1_NOME)
			aRet[2][NDOCEND_CGC   ] := AllTrim(SA1->A1_CGC)
			aRet[2][NDOCEND_PESSOA] := SA1->A1_PESSOA
			aRet[2][NDOCEND_PAIS  ] := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
			aRet[2][NDOCEND_END   ] := AllTrim(SA1->A1_END)
			aRet[2][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
			aRet[2][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
			aRet[2][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
			aRet[2][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
			aRet[2][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
			aRet[2][NDOCEND_ALIAS ] := "SA1"
		EndIf

		If !Empty(cAliasLay)
			//contratante Pagador do frete
			If DT6->DT6_DEVFRE == '1' //1=Remetente;2=Destinatario;3=Consignatario;4=Despachante;6=Expedidor;7=Recebedor
				cCliDev := DT6->DT6_CLIREM
				cLojDev := DT6->DT6_LOJREM
			ElseIf DT6->DT6_DEVFRE == '2'
				cCliDev := DT6->DT6_CLIDES
				cLojDev := DT6->DT6_LOJDES
			ElseIf DT6->DT6_DEVFRE == '3'
				cCliDev := DT6->DT6_CLICON
				cLojDev := DT6->DT6_LOJCON
			ElseIf DT6->DT6_DEVFRE == '4'
				cCliDev := DT6->DT6_CLIDPC
				cLojDev := DT6->DT6_LOJDPC
			ElseIf DT6->DT6_DEVFRE == '6'
				cCliDev := DT6->DT6_CLIEXP
				cLojDev := DT6->DT6_LOJEXP
			ElseIf DT6->DT6_DEVFRE == '7'
				cCliDev := DT6->DT6_CLIREC
				cLojDev := DT6->DT6_LOJREC
			EndIf

			// contratante
			If SA1->( DbSeek(xFilial("SA1") + cCliDev + cLojDev ) )
				aRet[3][NDOCEND_CODIGO] := SA1->A1_COD
				aRet[3][NDOCEND_LOJA  ] := SA1->A1_LOJA
				aRet[3][NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
				aRet[3][NDOCEND_NOME  ] := AllTrim(SA1->A1_NOME)
				aRet[3][NDOCEND_CGC   ] := AllTrim(SA1->A1_CGC)
				aRet[3][NDOCEND_PESSOA] := SA1->A1_PESSOA
				aRet[3][NDOCEND_PAIS  ] := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
				aRet[3][NDOCEND_END   ] := AllTrim(SA1->A1_END)
				aRet[3][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
				aRet[3][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
				aRet[3][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
				aRet[3][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
				aRet[3][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
				aRet[3][NDOCEND_ALIAS ] := "SA1"
			EndIf

			// Emitente
			If SA1->(DbSeek(xFilial("SA1") + DT6->(DT6_CLIREM + DT6_LOJREM)))
				aRet[4][NDOCEND_CODIGO] := SA1->A1_COD
				aRet[4][NDOCEND_LOJA  ] := SA1->A1_LOJA
				aRet[4][NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
				aRet[4][NDOCEND_NOME  ] := AllTrim(SA1->A1_NOME)
				aRet[4][NDOCEND_CGC   ] := AllTrim(SA1->A1_CGC)
				aRet[4][NDOCEND_PESSOA] := SA1->A1_PESSOA
				aRet[4][NDOCEND_PAIS  ] := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
				aRet[4][NDOCEND_END   ] := AllTrim(SA1->A1_END)
				aRet[4][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
				aRet[4][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
				aRet[4][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
				aRet[4][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
				aRet[4][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
				aRet[4][NDOCEND_ALIAS ] := "SA1"
			EndIf

			// Unidade Cadastro - Informações da Filial
			aSM0Dados		:= FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt )
			If Len( aSM0Dados ) > 0
				aRet[5][NDOCEND_CODIGO] := ""
				aRet[5][NDOCEND_LOJA  ] := ""
				aRet[5][NDOCEND_NREDUZ] := Alltrim( aSM0Dados[Ascan( aSM0Dados, { |x| x[1] == "M0_NOME"		} )][2] )
				aRet[5][NDOCEND_NOME  ] := Alltrim( aSM0Dados[Ascan( aSM0Dados, { |x| x[1] == "M0_NOMECOM"	} )][2] )
				aRet[5][NDOCEND_CGC   ] := Alltrim( aSM0Dados[Ascan( aSM0Dados, { |x| x[1] == "M0_CGC"		} )][2] )
				aRet[5][NDOCEND_PESSOA] := "J"
				aRet[5][NDOCEND_PAIS  ] := { "BR", "BRASIL" }
				aRet[5][NDOCEND_END   ] := AllTrim( aSM0Dados[Ascan( aSM0Dados, { |x| x[1] == "M0_ENDENT"	} )][2] )
				aRet[5][NDOCEND_BAIRRO] := Alltrim( aSM0Dados[Ascan( aSM0Dados, { |x| x[1] == "M0_BAIRENT"	} )][2] )
				aRet[5][NDOCEND_CEP   ] := Alltrim( aSM0Dados[Ascan( aSM0Dados, { |x| x[1] == "M0_CEPENT"	} )][2] )
				aRet[5][NDOCEND_MUN   ] := AllTrim( aSM0Dados[Ascan( aSM0Dados, { |x| x[1] == "M0_CIDENT"	} )][2] )
				aRet[5][NDOCEND_EST   ] := AllTrim( aSM0Dados[Ascan( aSM0Dados, { |x| x[1] == "M0_ESTENT"	} )][2] )
				aRet[5][NDOCEND_TEL   ] := AllTrim( aSM0Dados[Ascan( aSM0Dados, { |x| x[1] == "M0_EQUIP"	} )][2] )
				aRet[5][NDOCEND_ALIAS ] := "SM0"
			EndIf

			// Expedidor
			If SA1->(DbSeek(xFilial("SA1") + DT6->(DT6_CLIEXP + DT6_LOJEXP)))
				aRet[6][NDOCEND_CODIGO] := SA1->A1_COD
				aRet[6][NDOCEND_LOJA  ] := SA1->A1_LOJA
				aRet[6][NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
				aRet[6][NDOCEND_NOME  ] := AllTrim(SA1->A1_NOME)
				aRet[6][NDOCEND_CGC   ] := AllTrim(SA1->A1_CGC)
				aRet[6][NDOCEND_PESSOA] := SA1->A1_PESSOA
				aRet[6][NDOCEND_PAIS  ] := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
				aRet[6][NDOCEND_END   ] := AllTrim(SA1->A1_END)
				aRet[6][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
				aRet[6][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
				aRet[6][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
				aRet[6][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
				aRet[6][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
				aRet[6][NDOCEND_ALIAS ] := "SA1"
			EndIf

			// Recebedor
			If SA1->(DbSeek(xFilial("SA1") + DT6->(DT6_CLIREC + DT6_LOJREC)))
				aRet[7][NDOCEND_CODIGO] := SA1->A1_COD
				aRet[7][NDOCEND_LOJA  ] := SA1->A1_LOJA
				aRet[7][NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
				aRet[7][NDOCEND_NOME  ] := AllTrim(SA1->A1_NOME)
				aRet[7][NDOCEND_CGC   ] := AllTrim(SA1->A1_CGC)
				aRet[7][NDOCEND_PESSOA] := SA1->A1_PESSOA
				aRet[7][NDOCEND_PAIS  ] := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
				aRet[7][NDOCEND_END   ] := AllTrim(SA1->A1_END)
				aRet[7][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
				aRet[7][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
				aRet[7][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
				aRet[7][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
				aRet[7][NDOCEND_TEL   ] := AllTrim(If(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
				aRet[7][NDOCEND_ALIAS ] := "SA1"
			EndIf
		EndIf
	EndIf

	aEval(aAreas,{|xArea| RestArea(xArea)})
	FwFreeArray( aFieldSM0 )
	FwFreeArray( aSM0Dados )
	FwFreeArray( aAreas )

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMHVerFinTMHVerFin
Realiza verificação na DM0 se houve algum documento entregue
@author Rodrigo Pirolo
@since 29/10/2021
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Function TMHVerFin( cFilOri, cViagem )

	Local aArea		:= GetArea()
	Local aAreaDM0	:= DM0->( GetArea() )
	Local aAreaDTA	:= DTA->( GetArea() )

	Local lRet		:= .T.
	Local lFinish	:= .F.

	Local nX		:= 0

	Local oItems	:= Nil

	Local cQuery	:= ""
	Local cIdCHK	:= ""
	Local cStatus	:= ""
	Local cAliasQry	:= GetNextAlias()

	Default cFilOri	:= ""
	Default cViagem	:= ""

	cQuery := " SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE "
	cQuery += " FROM " + RetSQLName('DUD') + " DUD "
	cQuery += " WHERE DUD.DUD_FILORI = '" + cFilOri + "' "
	cQuery += 		" AND DUD.DUD_VIAGEM = '" + cViagem + "' "
	cQuery += 		" AND DUD.D_E_L_E_T_ = ' ' "

	DbUseArea( .T., "TOPCONN", TCGenQRY( , , cQuery ), cAliasQry, .F., .T. )

	If (cAliasQry)->( !Eof() )
		While (cAliasQry)->( !Eof() )
			
			DbSelectArea("DM0")
			DM0->( DbSetOrder( 1 ) ) //DM0_FILIAL, DM0_FILDOC, DM0_DOC, DM0_SERIE

			cIdCHK := AllTrim(cViagem) + "_" + (cAliasQry)->DUD_DOC + (cAliasQry)->DUD_SERIE
			oItems := Nil
			// Verifica se o Check List Existe
			cRet := TMSVerCHK(cIdCHK, @oItems )

			If ValType(oItems) == "A" .And. !Empty(oItems)

				For nX := 1 To Len(oItems)
					
					cStatus	:= oItems[nX]["status"]

					If cStatus == "FINISHED"
						lFinish := .T.
						Exit
					EndIf
				
				Next nX

			EndIf

			If lFinish
				lRet := .F.
				Exit
			EndIf

			(cAliasQry)->(  DbSkip() )
		EndDo
	EndIf

	(cAliasQry)->( DbCloseArea() )

	FwFreeObj(oItems)

	RestArea(aArea)
	RestArea(aAreaDM0)
	RestArea(aAreaDTA)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc}TMXHDTISO()
Retorna uma data e hora passada por parametro no padrão Data ISO-8601

@author     Rodrigo.Pirolo 
@since      23/08/2022
@Param      dDt     - Data a ser passada no padrão Data ISO-8601
@Param      cTime   - Hora a ser passada no padrão Data ISO-8601
@return     cRet    - Data no padrão Data ISO-8601
@version 1.0
*/
//-------------------------------------------------------------------

Function TMXHDTISO( dDt, cTime )

    Local cRet      := ""
    Local aLocalUTC := {}

	Default dDt		:= dDataBase
	Default cTime	:= "24:00:00"

	If !Empty(dDt) .AND. !Empty(cTime)

		If !( ':' $ cTime ) .AND. Len( cTime ) == 4
			cTime := cTime + "00"
			cTime := Transform(StrTran(cTime,":",""),"@R 99:99:99")
		EndIf

		aLocalUTC   := LocalToUTC( DToS( dDt ), cTime )
		//FWTimeStamp([ nType ], [ dDate ], [ cTime ])
		cRet        := SubStr( aLocalUTC[1], 1, 4 ) + "-" + SubStr( aLocalUTC[1], 5, 2 ) + "-" + SubStr( aLocalUTC[1], 7, 2 ) + "T" + aLocalUTC[2] + ".000Z" // "2021-12-09T20:33:49.004Z"
	EndIf

    FwFreeArray( aLocalUTC )

Return cRet

/*{Protheus.doc}TmsBscFil()
Retorna Dados da Filial para integração Portal Logístico
@author     Rafael Souza
@since      23/08/2022
@Param      dDt     - Data a ser passada no padrão Data ISO-8601
@Param      cTime   - Hora a ser passada no padrão Data ISO-8601
@return     cRet    - Data no padrão Data ISO-8601
@version 1.0
*/
Function TmsBscFil(cCodEmp,cCodFil,cCodCli,cLojCli)
Local aAreas    := {SA1->(GetArea()),GetArea()}
Local aFilSM0	:= {}
Local aRet		:= {}
Local aGeoLoc   := {}
Local lHasDnm 	:= FWAliasInDic("DNM",.F.)
Local lHere		:= .F. 
Local oHere	

Default cCodEmp := cEmpAnt
Default cCodFil := cFilAnt
Default cCodCli := ""
Default cLojCli := ""

	If lHasDnm .And. FindFunction("HereBscLoc")
		oHere  := TMSBCACOLENT():New("DNM")
		If oHere:DbGetToken()
			lHere := .T. 
		EndIf
	EndIf  

	If Empty(cCodCli + cLojCli)
		aFilSM0 := FWSM0Util():GetSM0Data( cCodEmp , cCodFil )
	
	 	AAdd( aRet, AllTrim( aFilSM0[ Ascan( aFilSM0, { |x| x[1] == "M0_NOMECOM"} ) ][2] )	)	//01 - Nome Completo
		AAdd( aRet, AllTrim( aFilSM0[ Ascan( aFilSM0, { |x| x[1] == "M0_NOME"	} ) ][2] )	)	//02 - Nome Filial
		AAdd( aRet, 		 aFilSM0[ Ascan( aFilSM0, { |x| x[1] == "M0_CGC"	} ) ][2]	)	//03 - CGC
	    AAdd( aRet, AllTrim( aFilSM0[ Ascan( aFilSM0, { |x| x[1] == "M0_CIDENT"	} ) ][2] )	)	//04 - Cidade
		AAdd( aRet, 		 aFilSM0[ Ascan( aFilSM0, { |x| x[1] == "M0_ESTENT"	} ) ][2]	)	//05 - UF
		AAdd( aRet, AllTrim( aFilSM0[ Ascan( aFilSM0, { |x| x[1] == "M0_ENDENT"	} ) ][2] )	)   //06 - Endereço
		AAdd( aRet, AllTrim( aFilSM0[ Ascan( aFilSM0, { |x| x[1] == "M0_BAIRENT"} ) ][2] )	)	//07 - Bairro
		AAdd( aRet, 		 aFilSM0[ Ascan( aFilSM0, { |x| x[1] == "M0_CEPENT"	} ) ][2]	)	//08 - CEP
	
		If lHere 
			aGeoLoc := HereBscLoc("SM0",cCodEmp + cCodFil,aRet[06],aRet[07],aRet[04],aRet[05],aRet[08],"Brasil")
			Aadd(aRet,aGeoLoc[1])	//-- 09 - Latitude
			Aadd(aRet,aGeoLoc[2])	//-- 10 - Longitude
		Else
			Aadd(aRet,"")	//-- 09 - Latitude
			Aadd(aRet,"")	//-- 10 - Longitude
		EndIf
	Else
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1") + cCodCli + cLojCli))
		 	AAdd(aRet,AllTrim(SA1->A1_NOME))	//01-- Nome Completo
			AAdd(aRet,AllTrim(SA1->A1_NREDUZ))	//02-- Nome Reduzido
			AAdd(aRet,AllTrim(SA1->A1_CGC))		//03-- CGC
		    AAdd(aRet,AllTrim(SA1->A1_MUN))		//04-- Cidade
			AAdd(aRet,AllTrim(SA1->A1_EST))		//05-- UF
			AAdd(aRet,AllTrim(SA1->A1_END))		//06-- Endereço
			AAdd(aRet,AllTrim(SA1->A1_BAIRRO))	//07-- Bairro
			AAdd(aRet,AllTrim(SA1->A1_CEP))		//08-- CEP

			If lHere 
				aGeoLoc := HereBscLoc("SA1",cCodCli + cLojCli,aRet[06],aRet[07],aRet[04],aRet[05],aRet[08],"Brasil")
				Aadd(aRet,aGeoLoc[1])	//-- 09 - Latitude
				Aadd(aRet,aGeoLoc[2])	//-- 10 - Longitude
			Else
				Aadd(aRet,"")	//-- 09 - Latitude
				Aadd(aRet,"")	//-- 10 - Longitude
			EndIf
		EndIf
	EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	
FWFreeObj(oHere)
FwFreeArray(aGeoLoc)
FwFreeArray(aAreas)
	
Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSStsOpe
Atualiza status Operacional Integração Portal Logístico
@type function
@author Rafael 
@version 12
@since 15/09/2022
@return lRet True ou False
/*/
//-------------------------------------------------------------------------------------------------
Function TMSStsOpe(cFilDoc,cDoc,cSerie,cAcao, cIdExt)

Local lRet := .T.
Local oColEnt
Local aStruct   := {}
Local nCntFor1  := 0
Local aAreaDT5  := {}
Local nRegistro := 0
Local cCodFon	:= ''
Local cProces	:= ''

Default cFilDoc := ''
Default cDoc	:= ''
Default cSerie	:= ''
Default cAcao	:= ''
Default cIdExt  := ''

oColEnt  := TMSBCACOLENT():New("DND")
If oColEnt:DbGetToken()
	DND->(DbGoTo(oColEnt:config_recno))
		aAreaDT5  := DT5->(GetArea())
		
		//-- Inicializa a estrutura
		aStruct   := TMSMntStru(DND->DND_CODFON,.F.)

//-- Localiza primeiro registro da estrutura
    For nCntFor1 := 1 To Len(aStruct)
        //-- Não é adicional de ninguém, ainda não foi processado e não dependente de ninguém
        If (Ascan(aStruct,{|x| x[11] + x[12] == aStruct[nCntFor1,1] + aStruct[nCntFor1,2]}) == 0) .And. ;
                                            aStruct[nCntFor1,10] == "2" .And. Empty(aStruct[nCntFor1,6])
            //-- Guarda variáveis estaticas
            cCodFon := aStruct[nCntFor1,1]
            cProces := PadR(cFilDoc + cDoc + cSerie,Len(DN5->DN5_PROCES))
            If ExisteDN5(aStruct[nCntFor1,1],aStruct[nCntFor1,2],cProces,{"1","2"},@nRegistro)
                DN5->(DbGoTo(nRegistro))
				cIdExt := AllTrim(DN5->DN5_IDEXT)
                If !Empty(cIdExt)
					TM30StsDoc(cIdExt,cAcao) 
					lRet := .T. 
					Exit
				Else
					lRet := .F. 
				EndIf 
            Else 
                lRet := .F. 
            EndIf 
        EndIf
    Next nCntFor1
	
	RestArea(aAreaDT5)
	FwFreeArray(aAreaDT5) 
	
EndIf 

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMXHTpNFC()
Retorna o Tipo

@author     Rodrigo.Pirolo 
@since      23/08/2022
@Param      cTipNFC - Data a ser passada no padrão Data ISO-8601
@return     cRet    - Descrição do tipo de NF Do Cliente
@version    1.0
@type       function
*/
//-------------------------------------------------------------------

Function TMXHTpNFC( cTipNFC )

    Local cRet  := ""

	If cTipNFC == '0'
        cRet  := 'Normal'
	ElseIf cTipNFC == '1'
        cRet  := 'Devolucao'
	ElseIf cTipNFC == '2'
        cRet  := 'SubContratacao'
	ElseIf cTipNFC == '3'
        cRet  := 'Nao Fiscal'
	ElseIf cTipNFC == '4'
        cRet  := 'Exportacao'
    ElseIf cTipNFC == '5'
        cRet  := 'Redespacho'
	ElseIf cTipNFC == '6'
        cRet  := 'Nao Fiscal 1'
	ElseIf cTipNFC == '7'
        cRet  := 'Nao Fiscal 2'
	ElseIf cTipNFC == '8'
        cRet  := 'Serv Vincul.Multimodal'
	ElseIf cTipNFC == '9'
        cRet  := 'Redespacho Inter.'
	ElseIf cTipNFC == 'A'
        cRet  := 'Vinc. Multimodal(Exped/Receb)'
    EndIf

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMXHSttOpe()
Retorna o STATUS Operacional do Documento de Carga de Acordo com a DUD

@author     Rodrigo.Pirolo 
@since      23/08/2022
@Param      cFilDoc - Filial do Documento
@Param      cDoc	- Numero do documento
@Param      cSerie  - Serie do Documento
@Param      lSttOpe	- Indica se deve retornar o Status Operacional Do Docuemnto ou o Status do Documento de Carga
@return     cRet    - Data no padrão Data ISO-8601
@version    1.0
@type       function
*/
//-------------------------------------------------------------------

Function TMXHStatus( cFilDoc, cDoc, cSerie, lSttOpe )

	Local aAreas	:= { DTC->(GetArea()), DUD->(GetArea()), GetArea() }
	Local cRet		:= ''

	Default cFilDoc	:= ""
	Default cDoc	:= ""
	Default cSerie	:= ""
	Default lSttOpe	:= .T.

	DbSelectArea( "DUD" )
	DUD->( DbSetOrder( 7 ) ) // DUD_FILIAL, DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD_NUMROM

	If DUD->( DbSeek( FwxFilial( 'DUD' ) + cFilDoc + cDoc + cSerie ) )

		If lSttOpe	
			//1=Em Aberto;2=Em Transito;3=Carregado;4=Encerrado;9=Cancelado
			If DUD_STATUS $ "1/9"
				cRet		:= "NAO_INICIADO"
			ElseIf DUD_STATUS $ "2/3"
				cRet		:= "EM_TRANSITO"
			ElseIf DUD_STATUS $ "4"
				cRet		:= "ENTREGUE"
			EndIf
		Else
			//1=Em Aberto;2=Em Transito;3=Carregado;4=Encerrado;9=Cancelado
			If DUD_STATUS $ "9"
				cRet		:= "CANCELADO"
			Else
				cRet		:= "AUTORIZADO"
			EndIf
		EndIf
	EndIf
	aEval(aAreas,{|xArea| RestArea(xArea)})
	FwFreeArray(aAreas)

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMXHSttCar
Retorna o STATUS Documento de Carga

@author     Rodrigo.Pirolo 
@since      23/08/2022
@param		cFilDoc	- Filial do Documento 
@param		cDoc	- Numero do documento
@param		cSerie	- Serie do Documento
@return     cRet    - Data no padrão Data ISO-8601
@version    1.0
@type       function
*/
//-------------------------------------------------------------------

Function TMXRetTip( cCGC )

	Local cRet	:= ""

	Default cCGC	:= ""
	
	cCGC := AllTrim( cCGC )

	If Len( cCGC ) == 11
		cRet	:= 'CPF'
	ElseIf Len( cCGC ) == 14
		cRet	:= 'CNPJ'
	Else
		cRet	:= 'IDENTIFICADOR_ESTRANGEIRO'
	EndIf

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMXHSttCar
Retorna o STATUS Documento de Carga

@author     Rodrigo.Pirolo 
@since      23/08/2022
@param		cFilDoc	- Filial do Documento 
@param		cDoc	- Numero do documento
@param		cSerie	- Serie do Documento
@return     cRet    - Data no padrão Data ISO-8601
@version    1.0
@type       function
*/
//-------------------------------------------------------------------

Function TMXRetDtS( dDtTrans )

	Local cRet := ""
	
	cRet := DToS( dDtTrans )
	cRet := SubStr( cRet, 1, 4 ) + "-" + SubStr( cRet, 5, 2 ) + "-" + SubStr( cRet, 7, 2 )

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMXHSttCar
Retorna o STATUS Documento de Carga

@author     Rodrigo.Pirolo 
@since      23/08/2022
@param		cFilDoc	- Filial do Documento 
@param		cDoc	- Numero do documento
@param		cSerie	- Serie do Documento
@return     cRet    - Data no padrão Data ISO-8601
@version    1.0
@type       function
*/
//-------------------------------------------------------------------

Function TMXComp( cSeekDLY, cNFEID )

	Local aAreas	:= { DTC->(GetArea()), DLY->(GetArea()), GetArea() }
	Local cRet := ""

	Default cSeekDLY := ""
	
	If !Empty( cNFEID )
		DLY->( DbSetOrder( 1 ) ) // DLY_FILIAL, DLY_CLIREM, DLY_LOJREM, DLY_NUMNFC, DLY_SERNFC, DLY_EMINFC, DLY_SEQEVE
		If DLY->( DbSeek( FwxFilial('DLY') + cSeekDLY ) )
			//DLY_STATUS 0=Integrado;1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
			If DLY->DLY_STATUS $ '4'
				cRet := "NAO"
			Else
				cRet := "SIM"
			EndIf
		Else
			cRet := "SIM"
		EndIf
	Else
		cRet := "NAO"
	EndIf

	aEval(aAreas,{|xArea| RestArea(xArea)})
	FwFreeArray(aAreas)

Return cRet
/*{Protheus.doc} TMSIDEXFAT
Retorna o ID Externo de uma Fatura
@author Rafael Souza
@since 10/10/22
*/
Function TmsIdExFat(cFilFat, cPrefixo, cFatura, cParcela, cTipo)
Local cIdExt := ""
Local aAreas := { DN5->(GetArea()), GetArea() }

Default cFilFat		:= ""
Default cPrefixo	:= ""
Default cFatura 	:= ""
Default cParcela	:= ""
Default cTipo 		:= ""

If !Empty(cPrefixo) .And. !Empty(cFatura)
	DbSelectArea("DN5")	    
    DN5->(DbSetOrder(5)) //DN5_FILIAL+DN5_CODFON+DN5_PROCES+DN5_LOCALI                                                                                                                     
	If DN5->( MsSeek( cSeekDN5 := xFilial("DN5")+DND->DND_CODFON + PadR( cFilFat + cPrefixo + cFatura + cParcela + cTipo, Len(DN5->DN5_PROCES)) ) )
   		cIdExt := AllTrim(DN5->DN5_IDEXT)    
    EndIf

    AEval(aAreas,{|aArea| RestArea(aArea) })
EndIf 

Return cIdExt

//-------------------------------------------------------------------
/*{Protheus.doc} TMXHComp
Retorna o STATUS Documento de Carga

@author     Rodrigo.Pirolo 
@since      23/08/2022
@param		cChvCTE	- Chave do CTE
@return     cRet    - Data no padrão Data ISO-8601
@version    1.0
@type       function
*/
//-------------------------------------------------------------------

Function TMXHComp( cChvCTE )
	
	Local aArea		:= GetArea()
	Local cAliasDLY	:= ""
	Local cQuery	:= ""
	Local aDocs		:= {}
	Local nX		:= 0
	Local lCpentAvls := DND->(ColumnPos("DND_CMPAVL")) > 0 // Comprovante de Entrega Avulso uso somente com o Coleta Entrega
	Local lEvPortLog := .F. 
	Local oPortLog As Object 

	cAliasDLY := GetNextAlias()
	cQuery := "SELECT DLY.DLY_FILDOC, DLY.DLY_DOC, DLY.DLY_SERIE "
	cQuery += " FROM " + RetSqlName("DLY") + " DLY "
	cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
	cQuery += 		" AND DLY.DLY_CHVCTE = '" + cChvCTE + "' "
	cQuery += 		" AND DLY.DLY_STATUS in ('3','4') "
	cQuery += 		" AND DLY.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY)
	
	While (cAliasDLY)->(!Eof())
		
		aAdd(aDocs, { (cAliasDLY)->DLY_FILDOC, (cAliasDLY)->DLY_DOC, (cAliasDLY)->DLY_SERIE } )
		
		(cAliasDLY)->(DbSkip())
	EndDo

	(cAliasDLY)->(DbCloseArea())

	If AliasInDic("DND")
		If lCpentAvls
			oPortLog := TMSBCACOLENT():New("DND")
			oPortLog:DbGetToken()   
			DND->(DbGoTo(oPortLog:config_recno))

			If DND->DND_CMPAVL == "2"
				lEvPortLog := .T. 
			EndIf 
		EndIf 
		For nX := 1 To Len(aDocs)
			TM30AltStt( , 1, "NAO", aDocs[nX][1] + aDocs[nX][2] + aDocs[nX][3] )
			If ExistFunc("TMS30ANEXO") .And. lCpentAvls
				If lEvPortLog
					TMS30ANEXO( aDocs[nX][1], aDocs[nX][2], aDocs[nX][3], .F. )
				EndIf 
			ElseIf ExistFunc("TMS30ANEXO")
				TMS30ANEXO( aDocs[nX][1], aDocs[nX][2], aDocs[nX][3], .F. )
			EndIf 
		Next nX
	EndIf
	
	RestArea(aArea)
	FwFreeArray(aArea)
	FwFreeArray(aDocs)
	FwFreeObj(oPortLog)

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSFatPgPL
Informa pagamento de fatura ao Portal Logístico
@type function
@author Rafael Souza
@version 12
@since 18/10/2022
@return
/*/
//-------------------------------------------------------------------------------------------------
Function TMSFatPgPL()

Local oColEnt
Local aLayout    := {}
Local aStruct    := {}
Local cSequen    := ""
Local nCntFor1   := 0
Local aAreaSE1   := {}
Local nOldMod	 := nModulo 

If AliasInDic("DND")
	oColEnt  := TMSBCACOLENT():New("DND")
	nModulo := 43 //--Seta o modulo como TMS
	If oColEnt:DbGetToken() 
		DND->(DbGoTo(oColEnt:config_recno))

		aAreaSE1  := SE1->(GetArea())

		//-- Inicializa a estrutura
		aStruct   := TMSMntStru(DND->DND_CODFON,.F.)
		TMSSetVar("aStruct",aStruct)
		
		//-- Define o processo
		TMSSetVar("cProcesso", SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

		//-- Inicializa o localizador
		TMSSetVar("aLocaliza",{})

		For nCntFor1 := 1 To Len(aStruct)
			If (Ascan(aStruct,{|x| x[11] + x[12] ==  aStruct[nCntFor1,1] +  aStruct[nCntFor1,2]}) == 0) .And. aStruct[nCntFor1,10] == "2" .And. "FINA070" $ aStruct[nCntFor1,9] 	
				aLayout := BscLayout(aStruct[nCntFor1,1],aStruct[nCntFor1,2])
				If !Empty(aLayout)
					If Empty(aStruct[nCntFor1,6])
						//-- Inicia a gravação dos registros
						MontaReg(Aclone(aLayout),nCntFor1,,cSequen,.T.)
						
						TMSCtrLoop(Aclone(aLayout),nCntFor1)
					EndIf
				EndIf
			EndIf
			aStruct := TMSGetVar("aStruct")
		Next nCntFor1
		RestArea(aAreaSE1)
		FwFreeArray(aAreaSE1)
	EndIf 
	nModulo := nOldMod //-- Restaura o módulo anterior
EndIf

Return 


//-------------------------------------------------------------------
/*{Protheus.doc} TMXStsFat
Retorna o STATUS Financeiro da Fatura para o Portal Logístico
@type function
@author Rafael 
@version 12
@since 18/10/2022
@return cRet 
*/
//-------------------------------------------------------------------

Function TMXStsFat(cStatus)

Local cRet	:= ""

Default cStatus	:= ""

If cStatus == "A"
	cRet	:= 'A_VENCER'
ElseIf cStatus == "B"
	cRet	:= 'PAGO'
EndIf

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMSXSTDocT
Retorna o STATUS Documento de Carga

@author     Fabio Marchiori Sampaio 
@since      23/08/2022
@param		cStatusDT6	- Codigo do Status da DT6
@return     cRet        - Status do Documento de Transporte
@version    1.0
@type       function
*/
//-------------------------------------------------------------------

Function TMSXSTDocT(cStatusDT6)

Local cRet := ''

Default cStatusDT6 := ''

	If cStatusDT6 = '1'
		cRet := 'NAO_INICIADO'
	ElseIf cStatusDT6 = '5'
		cRet := 'EM_CROSSDOCKING'
	ElseIf cStatusDT6 = '3'
		cRet := 'EM_TRANSITO' 
	ElseIf cStatusDT6 = '7'
		cRet := 'ENTREGUE'
	EndIf

Return cRet

/*{Protheus.doc} BscIDExtDc
Busca ID Externo do Documento de Transporte
@type Function
@author Rafael Souza
@since 24/10/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function BscIDExtDc(cCodFon,cCodReg,cChave)
Local cRet   := ""
Local aAreas := {DN4->(GetArea()),DT6->(GetArea()),GetArea()}

Default cCodFon := ""
Default cCodReg := ""
Default cChave 	:= ""

DN4->(DbSetOrder(1))
If DN4->(DbSeek(xFilial("DN4") + cCodFon + cCodReg + PadR(cChave,Len(DN4->DN4_CHAVE))))
	cRet := DN4->DN4_IDEXT
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMPrEveDoc
Faz o processamento de geração dos dados DN5 para envio dos eventos 
ao Portal Logístico
@type function
@author Rafael Souza  
@version 12
@since 17/03/2023
@return lRet 
*/
//-------------------------------------------------------------------
Function TMPrEveDoc(aDocs)

Local lRet := .T.
Local oColEnt
Local aLayout    := {}
Local aStruct    := {}
Local cSequen    := ""
Local nCntFor1   := 0
Local aAreaDT5   := {}
Local aAreaDTC 	 := {}
Local nx 		 := 0
Local cAliasDTC  := ""
Local cQuery     := ""
Local cFilDoc	 := ""
Local cDoc		 := ""
Local cSerie	 := ""
Local cIdExt	 := ""

Default aDocs	:= {} 

oColEnt  := TMSBCACOLENT():New("DND")
If oColEnt:DbGetToken()
	For nx := 1 To Len(aDocs)
		DND->(DbGoTo(oColEnt:config_recno))
		aAreaDT5  := DT5->(GetArea())
		aAreaDTC  := DTC->(GetArea())
		DT5->(dbSetOrder(4))
		DTC->(dbSetOrder(3))
		If DT5->(MsSeek(xFilial("DT5")+aDocs[nx][1])) .And. DT5->DT5_SERIE == 'COL' 
			cIdExt := BscIDExtDc("04","0130",FwxFilial("DT5")+ DT5->(DT5_FILORI + DT5_NUMSOL))                            
			If !Empty(cIdExt)
				//-- Inicializa a estrutura
				aStruct   := TMSMntStru(DND->DND_CODFON,.F.)
				TMSSetVar("aStruct",aStruct)
				
				//-- Define o processo
				TMSSetVar("cProcesso", aDocs[nx][1] ) // cFilDoc + Doc + Serie da DT5 -> aDocs[nx][1]

				//-- Inicializa o localizador
				TMSSetVar("aLocaliza",{})

				For nCntFor1 := 1 To Len(aStruct)

					If aStruct[nCntFor1,10] == "2" .And. aStruct[nCntFor1,3] == "DT5" .And. aStruct[nCntFor1,2] == '2060'	
						aLayout := BscLayout(aStruct[nCntFor1,1],aStruct[nCntFor1,2])
						If !Empty(aLayout)
							If Empty(aStruct[nCntFor1,6])
								//-- Inicia a gravação dos registros
								MontaReg(Aclone(aLayout),nCntFor1,,cSequen,.T.)
								
								TMSCtrLoop(Aclone(aLayout),nCntFor1)
							EndIf
						EndIf
					EndIf
					aStruct := TMSGetVar("aStruct")
				Next nCntFor1
			EndIf 
		ElseIf DTC->(MsSeek(xFilial("DTC")+aDocs[nx][1]))
			cIdExt := BscIDExtDc("04","1000",FwxFilial("DTC")+DTC->(DTC_DOC+DTC_SERIE+DTC_FILDOC+DTC_NUMNFC+DTC_SERNFC))
			If !Empty(cIdExt)
		 		//-- Inicializa a estrutura
				aStruct   := TMSMntStru(DND->DND_CODFON,.F.)
				TMSSetVar("aStruct",aStruct)
				
				//-- Define o processo
				TMSSetVar("cProcesso", aDocs[nx][1] ) // cFilDoc + Doc + Serie da DTC -> aDocs[nx][1]
				cFilDoc := DTC->DTC_FILDOC
				cDoc	:= DTC->DTC_DOC
				cSerie	:= DTC->DTC_SERIE 

				//--Query Identificar Registros DTC 
				cAliasDTC := GetNextAlias()

				cQuery := " SELECT DTC.DTC_NUMNFC, DTC.DTC_SERNFC, DTC.R_E_C_N_O_ REGISTRO "
				cQuery += " FROM " + RetSqlName("DTC") + " DTC "
				cQuery += " WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
				cQuery += 	" AND DTC.DTC_FILDOC = '" + cFilDoc + "' "
				cQuery += 	" AND DTC.DTC_DOC = '" + cDoc + "' "
				cQuery += 	" AND DTC.DTC_SERIE = '" + cSerie + "' "
				cQuery += 	" AND DTC.D_E_L_E_T_ = ' ' "

				cQuery := ChangeQuery(cQuery)
				DbUseArea( .T., "TOPCONN", TCGENQRY( , , cQuery ), cAliasDTC, .F., .T. )

				While (cAliasDTC)->(!Eof())
					DTC->(dbSetOrder(7))
					If DTC->(MsSeek(xFilial("DTC") + cDoc + cSerie + cFilDoc + (cAliasDTC)->(DTC_NUMNFC) + (cAliasDTC)->(DTC_SERNFC) ))	
						//-- Inicializa o localizador
						TMSSetVar("aLocaliza",{})

						For nCntFor1 := 1 To Len(aStruct)

							If aStruct[nCntFor1,10] == "2" .And. aStruct[nCntFor1,3] == "DTC" .And. 'IsInCallStack("Tmsa350") .Or. IsInCallStack("Tmsa360")'  $ aStruct[nCntFor1,9]	
								aLayout := BscLayout(aStruct[nCntFor1,1],aStruct[nCntFor1,2])
								If !Empty(aLayout)
									If Empty(aStruct[nCntFor1,6])
										//-- Inicia a gravação dos registros
										MontaReg(Aclone(aLayout),nCntFor1,,cSequen,.T.)
										
										TMSCtrLoop(Aclone(aLayout),nCntFor1)
									EndIf
								EndIf
							EndIf
							aStruct := TMSGetVar("aStruct")
						Next nCntFor1
					EndIf

					(cAliasDTC)->( DbSkip() )
				EndDo
				(cAliasDTC)->( DbCloseArea() )
			EndIf 
		EndIf 
	Next nx 
	RestArea(aAreaDT5)
	RestArea(aAreaDTC)
	FwFreeArray(aAreaDT5)
	FwFreeArray(aAreaDTC)
	FwFreeArray(aDocs)
EndIf 

Return lRet 

/*{Protheus.doc} HereBscLoc
Busca Latitude/Longitude (Here)
@type Function
@author Valdemar Roberto Mognon
@since 09/11/2023
*/
Function HereBscLoc(cAliEnt,cChvEnt,cEnder,cBairro,cMun,cUF,cCEP,cPais)
Local aRet      := {"",""}
Local aCab      := {}
Local aGeoLoc   := {}
Local cLatitu   := ""
Local cLongit   := ""
Local cFilEnt   := Space(Len(DAR->DAR_FILIAL))
Local oJson

Private lMsErroAuto := .F.

DEFAULT cAliEnt := ""
DEFAULT cChvEnt := ""
DEFAULT cEnder  := ""
DEFAULT cBairro := ""
DEFAULT cMun    := ""
DEFAULT cUF     := ""
DEFAULT cCEP    := ""
DEFAULT cPais   := ""

If !Empty(cAliEnt) .And. !Empty(cChvEnt)
	If cAliEnt != "SM0"
		cFilEnt := xFilial(cAliEnt)
	EndIf
	
	cChvEnt := PadR(cChvEnt,TamSX3("DAR_CODENT")[1])

	//--- Verifica se existe na DAR, caso não existir busca a Geolocalização na Here e grava a DAR
	DAR->(DbSetOrder(1))
	If DAR->(DbSeek(xFilial("DAR") + cFilEnt + cAliEnt + cChvEnt)) .And. !Empty(DAR->DAR_LATITU) .And. !Empty(DAR->DAR_LONGIT)
		cLatitu := AllTrim(DAR->DAR_LATITU)
		cLongit := AllTrim(DAR->DAR_LONGIT)
	Else
		oJson := HereGeoLoc({cEnder,cBairro,cMun,cUF,cCEP,cPais})
		aGeoLoc := HereIteGeo(oJson)
		If !Empty(aGeoLoc)
			cLatitu := AllTrim(Str(aGeoLoc[1]))
			cLongit := AllTrim(Str(aGeoLoc[2]))
	
			//-- Executa cadastro da DAR
			RecLock("DAR",.T.)
			DAR->DAR_FILIAL := xFilial("DAR")	
			DAR->DAR_FILENT := cFilEnt
			DAR->DAR_ENTIDA := cAliEnt
			DAR->DAR_CODENT := cChvEnt
			DAR->DAR_LATITU := cLatitu
			DAR->DAR_LONGIT := cLongit
	        DAR->(MsUnlock())
		EndIf
    EndIf
    
	aRet[1] := cLatitu
	aRet[2] := cLongit
EndIf

FwFreeArray(aGeoLoc)
FwFreeArray(aCab)

Return aRet

/*{Protheus.doc} HereGeoLoc
Busca Geolocalização na Here
@type Function
@author Valdemar Roberto Mognon
@since 09/11/2023
*/
Function HereGeoLoc(aLogradour,lApiCarol)
Local cLogradour := ""
Local aResGet    := {}
Local oColEnt
Local oJson

DEFAULT aLogradour := Array(6)
DEFAULT lApiCarol  := .F.

If !Empty(aLogradour)
	cLogradour := "city="         + AllTrim(aLogradour[3]) + ;
				  ";country="     + AllTrim(aLogradour[6]) +;
	              ";street="      + AllTrim(FisGetEnd(aLogradour[1])[1]) + ;
				  Iif(!Empty(FisGetEnd(aLogradour[1])[3]) .And. !lApiCarol,";houseNumber=" + AllTrim(FisGetEnd(aLogradour[1])[3]),"") + ;
				  Iif(!Empty(aLogradour[5]),";postalCode="  + aLogradour[5],"") + ;
				  ";state="       + AllTrim(aLogradour[4]) 

	If FWAliasInDic("DNM",.F.)
		oColEnt := TMSBCACOLENT():New("DNM")
		If (aResGet := oColEnt:Get("","?qq=" + FwURLEncode(cLogradour),"https://geocode.search.hereapi.com/v1/geocode"))[1]
			oJson := JsonObject():New()
			oJson:FromJson(aResGet[2])
		Else
			TMSAC30Err("TMSAC30011",oColEnt:last_error,oColEnt:desc_error)
		EndIf
	EndIf

	FWFreeObj(oColEnt)
	FwFreeArray(aResGet)
EndIf

Return oJson

/*{Protheus.doc} HereIteGeo
Define Latitude/Longitude Here
@type Function
@author Valdemar Roberto Mognon
@since 10/11/2023
*/
Function HereIteGeo(oJson)
Local aRet     := {}
Local nCntFor1 := 0
Local oJsonLoc
Local nScore   := 0

DEFAULT oJson := Nil

If oJson != Nil .And. oJson["items"] != Nil
	For nCntFor1 := 1 To Len(oJson["items"])		
		If oJson["items",nCntFor1,"position"] != Nil                .And. ;
		   oJson["items",nCntFor1,"scoring", "queryScore"] != Nil   .And. ;
		   oJson["items",nCntFor1,"scoring", "queryScore"] > 0.6    .And. ;
		   oJson["items",nCntFor1,"scoring", "queryScore"] > nScore 

			oJsonLoc := oJson["items",nCntFor1,"position"]
			If Empty(aRet)
				Aadd(aRet,oJsonLoc["lat"])
				Aadd(aRet,oJsonLoc["lng"])
			Else
				aRet[1] := oJsonLoc["lat"]
				aRet[2] := oJsonLoc["lng"]
			EndIf
			nScore := oJson["items",nCntFor1,"scoring", "queryScore"]
		EndIf
	Next nCntFor1
EndIf

Return aRet

/*{Protheus.doc} HereToken
Efetua conexão para buscao do token na Here
@type Function
@author Valdemar Roberto Mognon
@since 13/11/2023
*/
Function HereToken(cURL,cClientId,cSecret)
Local cNonce      := StrTran(Time(),":") + cThreadNum	//-- Chave única por solicitação
Local cTimeStamp  := FWTimeStamp(4,Date(),Time())
Local cStringBase := ""
Local cSignature  := ""
Local aHeaders    := {}
Local cOAuthStr   := ""

DEFAULT cUrl      := "https://account.api.here.com/oauth2/token"
DEFAULT cClientID := ""
DEFAULT cSecret   := ""

If !Empty(cClientId) .And. !Empty(cSecret)
	cStringBase := "POST"
	cStringBase += "&" + FWURLEncode(cUrl + "token")
	cStringBase += "&" + FWURLEncode("grant_type=client_credentials")
	cStringBase += FWURLEncode("&oauth_consumer_key=" + cClientID)
	cStringBase += FWURLEncode("&oauth_nonce=" + cNonce)
	cStringBase += FWURLEncode("&oauth_signature_method=HMAC-SHA256")
	cStringBase += FWURLEncode("&oauth_timestamp=" + cTimeStamp)
	cStringBase += FWURLEncode("&oauth_version=1.0")
	
	cSignature := FWURLEncode(Encode64(HMAC(cStringBase,cSecret + "&",5,1,1,1)))
	
	cOAuthStr := 'Authorization: OAuth '
	cOAuthStr += 'oauth_consumer_key="' + cClientID + '",'
	cOAuthStr += 'oauth_signature_method="HMAC-SHA256",'
	cOAuthStr += 'oauth_timestamp="' + cTimeStamp + '",'
	cOAuthStr += 'oauth_nonce="' + cNonce + '",'
	cOAuthStr += 'oauth_version="1.0",'
	cOAuthStr += 'oauth_signature="' + cSignature + '"'
	
	aHeaders := {}
	Aadd(aHeaders,cOAuthStr)
	Aadd(aHeaders,"Content-Type: application/x-www-form-urlencoded")
EndIf

Return aHeaders

/*{Protheus.doc} AtuSeqHere
Atualiza a sequencia das coletas/entregas vindas da Here
@type Function
@author Valdemar Roberto Mognon
@since 14/11/2023
*/
Function AtuSeqHere(xResult_Ok,cAlias)
Local aAreas     := {}
Local aResults   := {}
Local aWayPoints := {}
Local nCntFor1   := 0
Local nCntFor2   := 0
Local cUltSeq    := ""
Local cQuery     := 0
Local cAliasDM3  := ""
Local cFilOri    := ""
Local cViagem    := ""
Local oObjResult

Default xResult_Ok := ""
Default cAlias     := ""

//-- Mapa do vetor aSequencia
//-- 01-Identificador do ponto de coleta/entrega
//-- 02-Latitude
//-- 03-Longitude
//-- 04-Sequencia de coleta/Entrega

oObjResult := JsonObject():New()
oObjResult:FromJson(xResult_Ok)

If ValType(oObjResult["results"]) == "A"
	aResults := oObjResult["results"]
	For nCntFor1 := 1 To Len(aResults)
		If ValType(aResults[nCntFor1,"waypoints"]) == "A"
			aWayPoints := aResults[nCntFor1,"waypoints"]
			For nCntFor2 := 1 To Len(aWayPoints)
				If Right(AllTrim(aWayPoints[nCntFor2]["id"]),2) != "FI" .And. ;
				   Right(AllTrim(aWayPoints[nCntFor2]["id"]),2) != "FF"
					If cAlias == "DF8"	//-- Programação de Carregamento
						//-- Documentos da Programação de Carregamento
						cQuery := "UPDATE " + RetSqlName("DD9") + " "
						cQuery +=    "SET DD9_SEQUEN = '" + StrZero(aWayPoints[nCntFor2]["sequence"],Len(DD9->DD9_SEQUEN)) + "' "
						cQuery +=  "WHERE DD9_FILIAL = '" + xFilial("DD9") + "' "
						cQuery +=    "AND DD9_WAYPNT = '" + aWayPoints[nCntFor2]["id"] + "' "
						cQuery +=    "AND D_E_L_E_T_ = ' ' "
						TCSqlExec(cQuery)
					ElseIf cAlias == "DTQ"	//-- Viagem
						cFilOri := SubStr(aWayPoints[nCntFor2]["id"],8,Len(DTQ->DTQ_FILORI))
						cViagem := SubStr(aWayPoints[nCntFor2]["id"],8 + Len(DTQ->DTQ_FILORI),Len(DTQ->DTQ_VIAGEM))

						//-- Localiza a sequencia do último DM3 apontado com ocorrência diferente de 05
						aAreas := {GetArea()}
						cAliasDM3 := GetNextAlias()
						cQuery := "SELECT MAX(DM3_SEQUEN) ULTSEQ"

						cQuery +=   "FROM " + RetSqlName("DM3") + " DM3 "

						cQuery +=  "INNER JOIN " + RetSqlName("DUA") + " DUA "
						cQuery +=     "ON DUA_FILIAL = '" + xFilial("DUA") + "' "
						cQuery +=    "AND DUA_FILORI = DM3_FILORI "
						cQuery +=    "AND DUA_VIAGEM = DM3_VIAGEM "
						cQuery +=    "AND DUA_FILDOC = DM3_DOC "
						cQuery +=    "AND DUA_DOC = DM3_DOC "
						cQuery +=    "AND DUA_SERIE = DM3_SERIE "
						cQuery +=    "AND DUA.D_E_L_E_T_ = ' ' "

						cQuery +=  "INNER JOIN " + RetSqlName("DT2") + " DT2 "
						cQuery +=     "ON DT2_FILIAL = '" + xFilial("DT2") + "' "
						cQuery +=    "AND DT2_CODOCO = DUA_CODOCO "
						cQuery +=    "AND DT2_TIPOCO <> '05' "
						cQuery +=    "AND DT2.D_E_L_E_T_ = ' ' "

						cQuery +=  "WHERE DM3_FILIAL = '" + xFilial("DM3") + "'"
						cQuery +=    "AND DM3_FILORI = '" + cFilOri + "'"
						cQuery +=    "AND DM3_VIAGEM = '" + cViagem + "'"
						cQuery +=    "AND DM3.D_E_L_E_T_ = ' '"

						cQuery := ChangeQuery(cQuery)
						DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasDM3,.F.,.T.)

						If (cAliasDM3)->(Eof()) .Or. Empty((cAliasDM3)->ULTSEQ)
							cUltSeq := StrZero(0,Len(DM3->DM3_SEQUEN))
						Else
							cUltSeq := (cAliasDM3)->ULTSEQ
						EndIf
						(cAliasDM3)->(DbCloseArea())

						AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
						FwFreeArray(aAreas)

						//-- Documentos da Viagem Modelo 3
						cQuery := "UPDATE " + RetSqlName("DM3") + " "
						cQuery +=    "SET DM3_SEQUEN = '" + StrZero(Val(cUltSeq) + aWayPoints[nCntFor2]["sequence"],Len(DM3->DM3_SEQUEN)) + "' "
						cQuery +=  "WHERE DM3_FILIAL = '" + xFilial("DM3") + "' "
						cQuery +=    "AND DM3_WAYPNT = '" + aWayPoints[nCntFor2]["id"] + "' "
						cQuery +=    "AND D_E_L_E_T_ = ' ' "
						TCSqlExec(cQuery)
						//-- Documentos da Viagem
						aAreas := {DUD->(GetArea()),GetArea()}

						cAliasDM3 := GetNextAlias()
						cQuery := "SELECT DM3_SEQUEN,DUD.R_E_C_N_O_ NUMREC "
						
						cQuery +=   "FROM " + RetSqlName("DUD") + " DUD "
						
						cQuery +=   "JOIN " + RetSqlName("DM3") + " DM3 "
						cQuery +=     "ON DM3_FILIAL = '" + xFilial("DM3") + "' "
						cQuery +=    "AND DM3_FILORI = '" + cFilOri + "' "
						cQuery +=    "AND DM3_VIAGEM = '" + cViagem + "' "
						cQuery +=    "AND DM3_WAYPNT = '" + aWayPoints[nCntFor2]["id"] + "' "
						cQuery +=    "AND DM3.D_E_L_E_T_ = ' ' "
						
						cQuery +=  "WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
						cQuery +=    "AND DUD_FILDOC = DM3_FILDOC "
						cQuery +=    "AND DUD_DOC = DM3_DOC "
						cQuery +=    "AND DUD_SERIE = DM3_SERIE "
						cQuery +=    "AND DUD_FILORI = '" + cFilOri + "' "
						cQuery +=    "AND DUD_VIAGEM = '" + cViagem + "' "
						cQuery +=    "AND DUD.D_E_L_E_T_ = ' ' "
						
						cQuery := ChangeQuery(cQuery)
						DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDM3)
						
						While (cAliasDM3)->(!Eof())
							DUD->(DbGoTo((cAliasDM3)->NUMREC))
							RecLock("DUD",.F.)
							DUD->DUD_SEQUEN := (cAliasDM3)->DM3_SEQUEN
							DUD->(MsUnlock())
							(cAliasDM3)->(DbSkip())
						EndDo
						(cAliasDM3)->(DbCloseArea())

						AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
						FwFreeArray(aAreas)
					EndIf
				EndIf
			Next nCntFor2
		EndIf
	Next nCntFor1
EndIf

Return

/*{Protheus.doc} RetRotHere
Retorna Informações do Roteiro da Here
@type Function
@author Valdemar Roberto Mognon
@since 22/08/2024
*/
Function RetRotHere(xResult_Ok)
Local aRet       := {}
Local aRotas     := {}
Local aSecoes    := {}
Local nCntFor1   := 0
Local nCntFor2   := 0
Local oObjResult
Local oSumarios
Local oPedagios
Local oTotais

aRet := Array(RH_LENVET)
aRet[RH_TOTPED] := 0

oObjResult := JsonObject():New()
oObjResult:FromJson(xResult_Ok)

If ValType(oObjResult["routes"]) == "A"
	aRotas := oObjResult["routes"]
	For nCntFor1 := 1 To Len(aRotas)
		If ValType(aRotas[nCntFor1,"sections"]) == "A"
			aSecoes := aRotas[nCntFor1,"sections"]
			For nCntFor2 := 1 To Len(aSecoes)
				If ValType(aSecoes[nCntFor2,"summary"]) == "J"
					oSumarios := aSecoes[nCntFor2,"summary"]
					If ValType(oSumarios["tolls"]) == "J"
						oPedagios := oSumarios["tolls"]
						If ValType(oPedagios["total"]) == "J"
							oTotais := oPedagios["total"]
							If ValType(oTotais["value"])  == "N"
								aRet[RH_TOTPED] += oTotais["value"]	//-- Valor total do pedágio da viagem
							EndIf
						EndIf
					EndIf
				EndIf
			Next nCntFor2
		EndIf
	Next nCntFor1
EndIf

Return Aclone(aRet)

/*{Protheus.doc} BscRotHere
Busca Informações do Roteiro da Here
@type Function
@author Valdemar Roberto Mognon
@since 23/08/2024
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
*/
Function BscRotHere()
Local aAreaCol := {}
Local aStruct  := {}
Local aLayout  := {}
Local cCndDep  := ""
Local cSequen  := ""
Local nCntFor1 := 0
Local oHere

If FWAliasInDic("DNM",.F.)
	oHere := TMSBCACOLENT():New("DNM")
	If oHere:DbGetToken()
	
		//-- Inicializa a estrutura
		aStruct := TMSMntStru(DNM->DNM_CODFON,.T.,"0003")
		TMSSetVar("aStruct",aStruct)
		
		//-- Define o processo
		TMSSetVar("cProcesso","ROT" + DF8->(DF8_FILORI + DF8_NUMPRG + DF8_SEQPRG))
		
		//-- Inicializa o localizador
		TMSSetVar("aLocaliza",{})
		
		//-- Inicializa o agrupamento
		TMSSetVar("aAgrLoc",{})
			
		DA3->(DbSetOrder(1))
		If DA3->(DbSeek(xFilial("DA3") + DDZ->DDZ_CODVEI))
		
			Aadd(aAreaCol,GetArea())
			Aadd(aAreaCol,DNM->(GetArea()))
		
			For nCntFor1 := 1 To Len(aStruct)
				Aadd(aAreaCol,(aStruct[nCntFor1,3])->(GetArea()))
		
				If Empty(aStruct[nCntFor1,9])
					cCndDep := ".T."
				Else
					cCndDep := AllTrim(aStruct[nCntFor1,9])
				EndIf
		
				//-- Ainda não foi processado
				//-- Não depende de outro registro
				//-- Não é adicional de nenhum outro registro
				//-- Condição do Registro do Layout atendida ou não informada
				If aStruct[nCntFor1,10] == "2" .And. Empty(aStruct[nCntFor1,6]) .And. (Ascan(aStruct,{|x| x[11] + x[12] ==  aStruct[nCntFor1,1] +  aStruct[nCntFor1,2]}) == 0) .And. &(cCndDep)
					aLayout := BscLayout(aStruct[nCntFor1,1],aStruct[nCntFor1,2])
		
					If !Empty(aLayout)
		
						If Empty(aStruct[nCntFor1,6])
		
							//-- Inicia a gravação dos registros
							MontaReg(Aclone(aLayout),nCntFor1,.T.,cSequen,.T.)
							TMSCtrLoop(Aclone(aLayout),nCntFor1)
		
						EndIf
		
					EndIf
		
				EndIf
		
				aStruct := TMSGetVar("aStruct")
			Next nCntFor1
		
			AEval(aAreaCol,{|x,y| RestArea(x),FwFreeArray(x)})
		
		EndIf
					  
	EndIf
EndIf

Return

/*/{Protheus.doc} TMSVerDLY
Verifica a existência do registro na DLY
@author Valdemar Roberto Mognon
@since 28/10/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSVerDNN( cFildoc, cDoc, cSerie, cNumNFc, cSerNFc, dEmiNFc, cNFEID, cProcCTE, cCodOco )

	Local aAreas := {DLY->(GetArea()),GetArea()}
	Local lRet		:= .T.
	Local cAlias	:= ""
	Local cQuery	:= ""

	Default cChvCTe := ""
	Default cCliRem := ""
	Default cLojRem := ""
	Default cNumNFc := ""
	Default cSerNFc := ""
	Default dEmiNFc := CToD("")
	Default cNFEID	:= ""
	Default cProcCTE:= ""
	Default cCodOco	:= ""

	//-- CHAVE 1 = DLY_FILIAL+DLY_CLIREM+DLY_LOJREM+DLY_NUMNFC+DLY_SERNFC+DTOS(DLY_EMINFC)+DLY_SEQEVE
	//-- CHAVE 2 = DLY_FILIAL+DLY_CHVCTE+DLY_NFEID
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "FROM " + RetSqlName("DNN") + " DNN "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += 	" AND DNN_FILIAL = '" + xFilial("DNN") + "' "
	cQuery += 	" AND DNN_FILDOC = '" + cFildoc + "' "
	cQuery += 	" AND DNN_DOC = '" + cDoc + "' "
	cQuery += 	" AND DNN_SERIE = '" + cSerie + "' "
	cQuery += 	" AND DNN_NUMNFC = '" + cNumNFC + "' "
	cQuery += 	" AND DNN_SERNFC = '" + cSerNFc + "' "
	cQuery += 	" AND DNN_EMINFC = '" + DTOS(dEmiNfc) + "' "
	cQuery += 	" AND DNN_NFEID = '" + cNFEID + "'"
	cQuery += 	" AND DNN_PROCTE = '" + cProcCTE + "'"
	cQuery += 	" AND DNN_CODOCO = '" + cCodOco + "' "

	cQuery := ChangeQuery(cQuery)
	cAlias := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAlias, .F., .T. )

	lRet := !(cAlias)->(EOF())

	aEval( aAreas, { |xArea| RestArea(xArea) } )

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSIncDLY()
Inclui registros na DNN de acordo com o array passado

@author Rodrigo Pirolo
@since 01/08/2019
-----------------------------------------------------------/*/

Function TMSCruDNN(aDados,nOpcx)
	Local cFilDoc	:= ""
	Local cDoc		:= ""
	Local cSerie	:= ""
	Local cNumNFc	:= ""
	Local cSerNFc	:= ""
	Local dEmiNFc	:= CToD("")
	Local cNFEID	:= ""
	Local cProCTE	:= ""
	Local cCodOco	:= ""
	Local cSeqs		:= ""

	Default aDados	:= {}
	Default nOpcx	:= 3

	If nOpcx == 3
		cFilDoc	:= aDados[Ascan(aDados,{|x| x[1] == "DNN_FILDOC"}), 2]
		cDoc	:= aDados[Ascan(aDados,{|x| x[1] == "DNN_DOC"}),    2]
		cSerie	:= aDados[Ascan(aDados,{|x| x[1] == "DNN_SERIE"}),  2]
		cNumNFc := aDados[Ascan(aDados,{|x| x[1] == "DNN_NUMNFC"}), 2]
		cSerNFc := aDados[Ascan(aDados,{|x| x[1] == "DNN_SERNFC"}), 2]
		dEmiNFc := aDados[Ascan(aDados,{|x| x[1] == "DNN_EMINFC"}), 2]
		cNFEID	:= aDados[Ascan(aDados,{|x| x[1] == "DNN_NFEID"}),  2]
		cProCTE := aDados[Ascan(aDados,{|x| x[1] == "DNN_PROCTE"}), 2]
		cCodOco := aDados[Ascan(aDados,{|x| x[1] == "DNN_CODOCO"}), 2]

		cSeqs := DNN->( TMSSeqDNN( cFilDoc, cDoc, cSerie, cNumNFc, cSerNFc, dEmiNFc, cNFEID, cProCTE, cCodOco ) )

		RecLock("DNN",.T.)
			DNN->DNN_FILIAL := xFilial("DNN")
			DNN->DNN_SEQEVE := "01"
			DNN->DNN_SEQINS := cSeqs

			aEval( aDados, { |x| If( !(AllTrim(x[1]) $ "DNN_FILIAL|DNN_SEQEVE|DNN_SEQINS"), DNN->( FieldPut( FieldPos( x[1] ), x[2] ) ), Nil ) } )
		DNN->(MSUnlock())
	EndIf

Return Nil

//-----------------------------------------------------------
/*/
{Protheus.doc} TMSSeqDNN()
Retorna a próxima sequencia de uma chave na tabela DLY

@author Rodrigo Pirolo
@since 30/07/2019
/*/
//-----------------------------------------------------------

Static Function TMSSeqDNN( cFilDoc, cDoc, cSerie, cNumNFc, cSerNFc, dEmiNFc, cNFEID, cProCTE, cCodOco )

	Local cRet   :=  StrZero(1, Len(DNN->DNN_SEQINS)) 
	Local aArea  := GetArea()
	Local cQuery := ""
	Local cAlias := GetNextAlias()

	cQuery := " SELECT  MAX(DNN_SEQINS) DNN_SEQINS "
	cQuery += " FROM " + RetSqlName("DNN") + " DNN "
	cQuery += " WHERE DNN.D_E_L_E_T_ = ' ' "
	cQuery += 	" AND DNN.DNN_FILIAL = '" + xFilial("DNN") + "' "
	cQuery += 	" AND DNN.DNN_FILDOC = '" + cFildoc + "' "
	cQuery += 	" AND DNN.DNN_DOC = '" + cDoc + "' "
	cQuery += 	" AND DNN.DNN_SERIE = '" + cSerie + "' "
	cQuery += 	" AND DNN.DNN_NUMNFC = '" + cNumNFC + "' "
	cQuery += 	" AND DNN.DNN_SERNFC = '" + cSerNFc + "' "
	cQuery += 	" AND DNN.DNN_EMINFC = '" + DTOS(dEmiNfc) + "' "
	cQuery += 	" AND DNN.DNN_NFEID = '" + cNFEID + "'"
	cQuery += 	" AND DNN.DNN_PROCTE = '" + cProcCTE + "'"
	cQuery += 	" AND DNN.DNN_CODOCO = '" + cCodOco + "' "
	
	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T. )

	If (cAlias)->(!Eof()) .And. !Empty((cAlias)->DNN_SEQINS) .AND. !Empty((cAlias)->DNN_SEQEVE)
		cRet := Soma1((cAlias)->DNN_SEQINS) 
	EndIf

	(cAlias)->(DbCloseArea())

	RestArea(aArea)

Return cRet

//-----------------------------------------------------------
/*/
{Protheus.doc} TMSSeqDLY()
Retorna a próxima sequencia de uma chave na tabela DLY

@author Rodrigo Pirolo
@since 30/07/2019
/*/
//-----------------------------------------------------------

Function TMSExcDNN( aExcDNN )

	Local aRet	:= {}
	Local aArea	:= GetArea()
	Local cQuery:= ""
	Local cAlias:= GetNextAlias()
	Local nX	:= 0

	DbSelectArea('DNN')

	cQuery := " SELECT DNN.DNN_IDRETE, DNN.R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("DNN") + " DNN "
	cQuery += " WHERE DNN.D_E_L_E_T_ = ' ' "
	cQuery += 	" AND DNN.DNN_FILIAL = ? "
	cQuery += 	" AND DNN.DNN_FILDOC = ? "
	cQuery += 	" AND DNN.DNN_DOC = ? "
	cQuery += 	" AND DNN.DNN_SERIE = ? "

	cQuery := ChangeQuery(cQuery)

	oQry := FWPreparedStatement():New()
	oQry:SetQuery(cQuery)

	oQry:SetString( 1, xFilial("DNN") )

	For nX := 1 To Len(aExcDNN)
		
		oQry:SetString( 2, aExcDNN[nX,1] )
		oQry:SetString( 3, aExcDNN[nX,2] )
		oQry:SetString( 4, aExcDNN[nX,3] )

		cQuery  := oQry:GetFixQuery()

		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T. )

		While (cAlias)->(!Eof())
			If Empty( (cAlias)->DNN_IDRETE )
				DNN->( DbGoTo( (cAlias)->RECNO ) )
				RecLock( 'DNN', .F. )
					DNN->( DbDelete() )
				DNN->( MsUnLock() )
			Else
				nPos := Ascan( aRet, { |x| x[1] + x[2] + x[3] == aExcDNN[nX,1] + aExcDNN[nX,2] + aExcDNN[nX,3] } )
				If nPos == 0
					AAdd( aRet, { aExcDNN[nX,1], aExcDNN[nX,2], aExcDNN[nX,3] } )
				EndIf
			EndIf
			(cAlias)->(DbSkip())
		EndDo

		(cAlias)->(DbCloseArea())
	Next nX

	If Len(aRet) > 0
		Help( '', 1, "TMSExcDNN", , STR0028, 1 ) // "Existem documentos que já iniciaram o processo de envio do insucesso por este motivo, é necessario verificar a necessidade de transmissão deste evento."
	EndIf

	RestArea(aArea)

Return aRet

/*/{Protheus.doc} TMSPrcCmp
Processa comprovante de entrega para envio ao TSS
@author Valdemar Roberto Mognon
@since 06/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSPrcIns( aChvDNN, cTipo, nOption )
Local aAreas    := {GetArea()}
Local aDadosCmp := {}
Local cQuery    := ""
Local cAlias	:= ""
Local nCntFor1  := 0
Local cLatitude := ""
Local cLongitit := ""
Local aDadosNFe := {}

Default aChvDNN := {}
Default cTipo	:= ""
Default nOption := 0

If !Empty(aChvDNN)
	For nCntFor1 := 1 To Len(aChvDNN)
		cAlias := GetNextAlias()
		cQuery := " SELECT DNN.DNN_PROCTE, DNN.DNN_NFEID, DNN.DNN_TIPINS, DNN.DNN_JUSTIF, DUA.DUA_DATOCO, DUA.DUA_HOROCO, "
		cQuery += " DT6.DT6_CHVCTE, DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE, DNN.DNN_SEQINS, DNN.DNN_PROTOC, DNN.R_E_C_N_O_ RECNO, DNN.DNN_SEQEVE "
		
		cQuery += " FROM " + RetSqlName("DNN") + " DNN "

		cQuery += " INNER JOIN " + RetSqlName("DUA") + " DUA ON "
		cQuery += 							" DUA.DUA_FILIAL = '" + FWxFilial("DUA") + "' AND "
		cQuery += 							" DUA.DUA_DOC = DNN.DNN_DOC AND "
		cQuery += 							" DUA.DUA_FILDOC = DNN.DNN_FILDOC AND "
		cQuery += 							" DUA.DUA_SERIE = DNN.DNN_SERIE AND "
		cQuery += 							" DUA.DUA_CODOCO = DNN.DNN_CODOCO AND "
		cQuery += 							" DUA.D_E_L_E_T_ = ' ' "
		
		cQuery += " INNER JOIN " + RetSqlName("DT6") + " DT6 ON "
		cQuery += 							" DT6.DT6_FILIAL = '" + FWxFilial("DT6") + "' AND "
		cQuery += 							" DT6.DT6_DOC = DNN.DNN_DOC AND "
		cQuery += 							" DT6.DT6_FILDOC = DNN.DNN_FILDOC AND "
		cQuery += 							" DT6.DT6_SERIE = DNN.DNN_SERIE AND "
		cQuery += 							" DT6.D_E_L_E_T_ = ' ' "

		/*
		aChvDNN:= { { "DNN_FILDOC", cFilDoc },;
					{ "DNN_DOC",    cDoc    },;
					{ "DNN_SERIE",  cSerie  },;
					{ "DNN_NFEID",  (cAliasDNN)->DNN_NFEID  },;
					{ "DNN_SEQEVE", (cAliasDNN)->DNN_SEQEVE },;
					{ "RECNO",      (cAliasDNN)->RECNO } } )
		*/
		cQuery += " WHERE DNN.DNN_FILIAL = '" + FWxFilial("DNN") + "' "
		cQuery += 	" AND DNN.DNN_FILDOC = '" + aChvDNN[nCntFor1,1] + "' "
		cQuery += 	" AND DNN.DNN_DOC = '" + aChvDNN[nCntFor1,2] + "' "
		cQuery += 	" AND DNN.DNN_SERIE = '" + aChvDNN[nCntFor1,3] + "' "
		//cQuery += 	" AND DNN.DNN_NFEID = '" + aChvDNN[nCntFor1,4,2] + "' "
		//cQuery += 	" AND DNN.DNN_SEQEVE = '" + aChvDNN[nCntFor1,5,2] + "' "
		//cQuery += 	" AND DNN.R_E_C_N_O_ = " + cValTochar(aChvDNN[nCntFor1,6,2]) + " "
		If nOption == 1
			cQuery += 	" AND (( DNN.DNN_STATUS = '2' OR DNN.DNN_STATUS = '5') OR (DNN.DNN_STATUS = '4' AND DNN.DNN_SEQEVE = '02' )) "
		ElseIf nOption == 3
			cQuery += 	" AND ( DNN.DNN_STATUS = '3' OR DNN.DNN_STATUS = '4' OR DNN.DNN_STATUS = '5' )"
		EndIf
		cQuery += 	" AND DNN.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		
		DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAlias)

		TCSetField( cAlias, "DUA_DATOCO", "D", 8, 0 )

		aDadosCmp := {}
		
		If (cAlias)->(!Eof())
			
			DNN->( DbGoTo( (cAlias)->RECNO) )
			
			Aadd( aDadosCmp, {	(cAlias)->DNN_PROCTE,;		// 1
								{},;						// 2
								(cAlias)->DNN_TIPINS,;		// 3
								(cAlias)->DNN_JUSTIF,;		// 4
								(cAlias)->DUA_DATOCO,;		// 5 
								(cAlias)->DUA_HOROCO,;		// 6
								(cAlias)->DT6_CHVCTE,;		// 7
								DNN->DNN_IMAGEM,;			// 8
								cTipo,;						// 9
								cLatitude,;					// 10 latitude
								cLongitit,;				    // 11 Longitude
								(cAlias)->DT6_FILDOC,;      // 12
								(cAlias)->DT6_DOC,;         // 13
								(cAlias)->DT6_SERIE,;       // 14
								(cAlias)->DNN_SEQINS,;      // 15
								(cAlias)->DNN_PROTOC,;      // 16
								(cAlias)->DNN_SEQEVE} )     // 17

			While (cAlias)->(!Eof())

				Aadd( aDadosNFe, (cAlias)->DNN_NFEID)

				(cAlias)->(DbSkip())
			EndDo
			(cAlias)->(DbCloseArea())

			If Len(aDadosCmp) > 0
				aDadosCmp[1,2] := aClone(aDadosNFe)
			EndIf
		EndIf

		If !Empty(aDadosCmp) .And. nOption == 1
			TMSEnvINS( Aclone(aDadosCmp), aDadosCmp[1,9] )
		ElseIf !Empty(aDadosCmp) .And. nOption == 2
			TMSEnvINS( Aclone(aDadosCmp), aDadosCmp[1,9] )
		ElseIf !Empty(aDadosCmp) .And. nOption == 3
			TMSRefIns(aDadosCmp)
		EndIf
	Next nCntFor1
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return

/*/{Protheus.doc} TMSXMLInE
Monta XML do evento de insucesso na entrega
@author Fabio Marchiori Sampaio
@since 13/11/2023
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSXMLInE( aDadosCmp, cTipo, cIdEnt, lReady, aCTe, cHshImg, cDatHsh )
Local aAreas    := { DT6->(GetArea()), SF2->(GetArea()), DLY->(GetArea()), GetArea() }
Local cRet      := ""
Local cDatEnt   := ""
Local cError    := ""
Local cModel    := "57"
Local cAmbiente := ""
Local dDataEnt  := ""
Local cHoraEnt  := ""
Local lHVerao	:= SuperGetMv("MV_HVERAO",,.F.)
Local nX		:= 0

Default aDadosCmp := {}
Default cTipo     := ""
Default cIdEnt    := ""
Default lReady    := .F.

If !Empty(aDadosCmp)

	cAmbiente := getCfgAmbiente(@cError, cIdEnt, cModel)

	If Empty(cError)			 
		If cTipo == "1"	//-- Envio do Evento de Insucesso
			cDatEnt := TMSConvDat( aDadosCmp[1,5], aDadosCmp[1,6], cIdEnt )
			
			//--considerando fusos de cada estado.
			DateTimeFS( /*cUF*/, lHVerao, @dDataEnt, @cHoraEnt )
			cDatHsh := TMSConvDat( dDataBase, cHoraEnt, cIdEnt )
			cHshImg := TMSMntHsh( aDadosCmp[1,7], , .T., aDadosCmp[1,8] )	//-- Chave eletrônica do CTe e nome do arquivo de imagem

			cRet := "<envEvento>"
			cRet += 	"<eventos>"
			cRet += 		"<detEvento>"
			cRet += 			"<tpEvento>110190</tpEvento>"
			cRet += 			"<chnfe>" + aDadosCmp[1,7] + "</chnfe>"
			cRet += 			"<ambiente>" + AllTrim(cAmbiente) + "</ambiente>"
			cRet += 			"<evIECTe>"
			cRet += 			   "<dhTentativaEntrega>" + AllTrim(cDatEnt) + "</dhTentativaEntrega>"
			cRet += 			   "<nTentativa>" + StrZero(Val(aDadosCmp[1,15]), 3) + "</nTentativa>"
			cRet += 			   "<tpMotivo>" + aDadosCmp[1,3] + "</tpMotivo>"
			If !Empty(aDadosCmp[1,4])
				cRet += 			   "<xJustMotivo>" + aDadosCmp[1,4] + "</xJustMotivo>"
			EndIf

			If !Empty( aDadosCmp[1,10] ) .And. !Empty( aDadosCmp[1,11] )
				cRet += 		   "<latitude>" + AllTrim(aDadosCmp[1,10])+ "</latitude>"
				cRet += 		   "<longitude>" + AllTrim(aDadosCmp[1,11]) + "</longitude>"
			EndIf
			cRet += 		       "<hashTentativaEntrega>" + AllTrim(cHshImg) + "</hashTentativaEntrega>"
			cRet += 			   "<dhHashTentativaEntrega>" + AllTrim(cDatHsh) + "</dhHashTentativaEntrega>"
			For nX := 1 to Len(aDadosCmp[1,2])
				cRet += 		   "<infEntrega >" 
				cRet += 		   	   "<chNFe>" + aDadosCmp[1,2,nX] + "</chNFe>"							
				cRet += 		   "</infEntrega >" 
			Next
			cRet += 			"</evIECTe>"
			cRet += 		"</detEvento>"
			cRet += 	"</eventos>"
			cRet += "</envEvento>"
		ElseIf cTipo == "2"	//-- Envio do Cancelamento do Evento de Insucesso
			cRet := "<envEvento>"
			cRet += 	"<eventos>"
			cRet += 		"<detEvento>"
			cRet += 			"<tpEvento>110191</tpEvento>"			
			cRet += 			"<chnfe>" + aDadosCmp[1,7] + "</chnfe>"
			cRet += 			"<ambiente>" + AllTrim(cAmbiente) + "</ambiente>"
			cRet += 			"<evCancIECTe>"
			cRet += 			  "<nProt>" + aDadosCmp[1,1] + "</nProt>"
			cRet += 			  "<nProtIE>" + aDadosCmp[1,16] + "</nProtIE>"
			cRet += 			"</evCancIECTe>"
			cRet += 		"</detEvento>"
			cRet += 	"</eventos>"
			cRet += "</envEvento>"
		EndIf
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return cRet

/*/{Protheus.doc} TMSEnvCmp
Envia XML de comprovante de entrega ao TSS
@author Valdemar Roberto Mognon
@since 06/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSEnvINS( aDadosCmp, cTipo )

Local aAreas    := { DT6->(GetArea()), GetArea() }
Local aCTe      := {}
Local cXML      := ""
Local cIdEnt    := ""
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cErro     := ""
Local cRetorno  := ""
Local cQuery    := ""
Local lUsaColab := UsaColaboracao("2")
Local lRetorno  := .F.
Local cHshImg   := ""
Local cDatHsh   := ""

Default cTipo   := ""

If CTIsReady(,,,lUsaColab)
	cIdEnt := RetIdEnti(lUsaColab)
EndIf

If !Empty(cIdEnt)

	cXML := TMSXMLInE( AClone(aDadosCmp), cTipo, cIdEnt, lUsaColab, @aCTe, @cHshImg, @cDatHsh )

	// Chamado do método e envio
	oWs:= WsNFeSBra():New()
	oWs:cUserToken	:= "TOTVS"
	oWs:cID_ENT		:= cIdEnt
	oWs:cXML_LOTE	:= cXML
	oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"

	If oWs:RemessaEvento()
		If Type("oWS:oWsRemessaEventoResult:cString") <> "U"
			lRetorno := .T.
		EndIf
	Else
		cErro	:= If( Empty(GetWscError(3)), GetWscError(1), GetWscError(3) )
	Endif

	If !lRetorno
		cRetorno := STR0001 + CRLF + CRLF	//-- "Houve erro durante a transmissão para o Totvs Services SPED."
		cRetorno += cErro
		Help( '', 1, "TMSXFUNH", , cRetorno, 1 ) // 
	EndIf

	If lRetorno .And. cTipo == "1"	//-- Envio do Evento de Insucesso
		//-- Atualiza a DNN
		cQuery := " UPDATE " + RetSqlName("DNN") + CRLF
		cQuery += "    SET DNN_HSHIMG = '" + cHshImg + "', " + CRLF
		cQuery += "       DNN_DTHRIN = '" + cDatHsh + "', " + CRLF
		cQuery += "       DNN_STATUS = '" + '3' + "', " + CRLF
		cQuery += "       DNN_SEQEVE = '01' " + CRLF
		cQuery += "  WHERE DNN_FILIAL = '" + xFilial("DNN") + "' " + CRLF
		cQuery += "    AND DNN_FILDOC = '" + aDadosCmp[1][12] + "' " + CRLF
		cQuery += "    AND DNN_DOC    = '" + aDadosCmp[1][13] + "' " + CRLF
		cQuery += "    AND DNN_SERIE  = '" + aDadosCmp[1][14] + "' " + CRLF
		cQuery += "    AND DNN_SEQINS = '" + aDadosCmp[1,15] + "' " + CRLF
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		TCSqlExec(cQuery)
	ElseIf lRetorno .And. cTipo == "2"	//-- Envio do Evento de Insucesso
		cQuery := " UPDATE " + RetSqlName("DNN") + CRLF
		cQuery += "    SET DNN_SEQEVE = '" + '02' + "', " + CRLF
		cQuery += "       DNN_STATUS = '3' " + CRLF
		cQuery += "  WHERE DNN_FILIAL = '" + xFilial("DNN") + "' " + CRLF
		cQuery += "    AND DNN_FILDOC = '" + aDadosCmp[1][12] + "' " + CRLF
		cQuery += "    AND DNN_DOC    = '" + aDadosCmp[1][13] + "' " + CRLF
		cQuery += "    AND DNN_SERIE  = '" + aDadosCmp[1][14] + "' " + CRLF
		cQuery += "    AND DNN_SEQINS = '" + aDadosCmp[1,15] + "' " + CRLF
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		TCSqlExec(cQuery)
	EndIf

Else
	Aviso("SPED","Atenção",{STR0002},3)	//-- "Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
Endif

aEval(aAreas,{|xArea| RestArea(xArea)})

Return

/*/{Protheus.doc} TMSRefIns
	(long_description)
	@type  Function para o refresh do evento de insucesso
	@author Fabio Marchiori Sampaio
	@since 21/12/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

Function TMSRefIns(aVetEnv)

Local aAreas    := {GetArea()}
Local lUsaColab := UsaColaboracao("2")
Local cIdEnt    := ""
Local cQuery    := ""
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local nCntFor1  := 0
Local oWs
Local oDados
Local oMonEvt   := NIL

Default aVetEnv := {}

// Verifica se a entidade foi configurada
If CTIsReady(,,,lUsaColab)
	cIdEnt := RetIdEnti(lUsaColab)
EndIf

If !Empty(cIdEnt)

	If !Empty(aVetEnv) 
		aVetEnv := ASort(aVetEnv,,,{|x,y| x < y})

		For nCntFor1 := 1 To Len(aVetEnv)
			If aVetEnv[nCntFor1, 17] == '01'
				// Executa o metodo NfeRetornaEvento()
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN	:= "TOTVS"
				oWS:cID_ENT		:= cIdEnt
				oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
				oWS:cEVENTO		:= "110190"
				oWS:cCHVINICIAL	:= aVetEnv[nCntFor1][7]
				oWS:cCHVFINAL	:= aVetEnv[nCntFor1][7]
				lOk := oWS:NFEMONITORLOTEEVENTO()
		
				If lOk		
					// Tratamento do retorno do evento			
					If ValType(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "U"

						oMonEvt := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento
						//-- Parece que quando o TSS não está atualizado(Schemas e RPO)
						//-- o objecto wsnfemonitorloteEventoResult vem vazio.
						If !Empty(oMonEvt)

							oDados  := oMonEvt[Len(oMonEvt)]

							If oDados:nTipoEvento == 110190

								//-- Atualiza a DNN
								If oDados:nSTATUS > 4 .And. oDados:nCSTATEVEN != 0
									cQuery := " UPDATE " + RetSqlName("DNN") + CRLF
									cQuery += "    SET DNN_STATUS = '" + Iif(oDados:nCSTATENV == 135,"4","5") + "', " + CRLF
									cQuery += "        DNN_IDRETE = '" + AllTrim(Str(oDados:nCSTATEVEN)) + "', " + CRLF
									cQuery += "        DNN_DRETEV = '" + PadR(StrTran(oDados:cCMOTEVEN,"'",""),GetSX3Cache("DNN_DRETEV","X3_TAMANHO")) + "', " + CRLF
									cQuery += "        DNN_PROTOC = '" + Iif(oDados:nPROTOCOLO == 0,"",AllTrim(Str(oDados:nPROTOCOLO))) + "' " + CRLF
									cQuery += "  WHERE DNN_FILIAL = '" + xFilial("DNN") + "' " + CRLF
									cQuery += "    AND DNN_FILDOC = '" + aVetEnv[nCntFor1][12] + "' " + CRLF
									cQuery += "    AND DNN_DOC    = '" + aVetEnv[nCntFor1][13] + "' " + CRLF
									cQuery += "    AND DNN_SERIE  = '" + aVetEnv[nCntFor1][14] + "' " + CRLF
									cQuery += "    AND (DNN_STATUS = '3' OR  DNN_STATUS = '5')"
									cQuery += "    AND D_E_L_E_T_ = ' ' "
									TCSqlExec(cQuery)
								EndIf

							EndIf
						EndIf
					Endif
				EndIf
			Else
				If aVetEnv[nCntFor1, 17] == '02'
					// Executa o metodo NfeRetornaEvento()
					oWS:= WSNFeSBRA():New()
					oWS:cUSERTOKEN	:= "TOTVS"
					oWS:cID_ENT		:= cIdEnt
					oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
					oWS:cEVENTO		:= "110191"
					oWS:cCHVINICIAL	:= aVetEnv[nCntFor1][7]
					oWS:cCHVFINAL	:= aVetEnv[nCntFor1][7]
					lOk := oWS:NFEMONITORLOTEEVENTO()
			
					If lOk		
						// Tratamento do retorno do evento			
						If ValType(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "U"

							oMonEvt := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento
							//-- Parece que quando o TSS não está atualizado(Schemas e RPO)
							//-- o objecto wsnfemonitorloteEventoResult vem vazio.
							If !Empty(oMonEvt)

								oDados  := oMonEvt[Len(oMonEvt)]

								If oDados:nTipoEvento == 110191

									//-- tag nSTATUS retornada pelo TSS (código interno)
									// Status 1 - Recebido
									// Status 2 - Assinado - Não Transmitiu
									// Status 3 - Erro, erro de schema
									// Status 4 - Consulta no governo
									// Status 5 - Rejeitado pelo governo
									// Status 6 - Autorizado 
									//-- Atualiza a DLY
									
									If oDados:nSTATUS > 4 .And. oDados:nCSTATEVEN != 0
										cQuery := " UPDATE " + RetSqlName("DNN") + CRLF
										cQuery += "    SET DNN_STATUS = '" + Iif(oDados:nCSTATENV == 135,"4","5") + "', " + CRLF
										cQuery += "        DNN_IDRETE = '" + AllTrim(Str(oDados:nCSTATEVEN)) + "', " + CRLF
										cQuery += "        DNN_DRETEV = '" + PadR(StrTran(oDados:cCMOTEVEN,"'",""),GetSX3Cache("DNN_DRETEV","X3_TAMANHO")) + "', " + CRLF
										cQuery += "        DNN_PROTOC = '" + Iif(oDados:nPROTOCOLO == 0,"",AllTrim(Str(oDados:nPROTOCOLO))) + "' " + CRLF
										cQuery += "  WHERE DNN_FILIAL = '" + xFilial("DNN") + "' " + CRLF
										cQuery += "    AND DNN_FILDOC = '" + aVetEnv[nCntFor1][12] + "' " + CRLF
										cQuery += "    AND DNN_DOC    = '" + aVetEnv[nCntFor1][13] + "' " + CRLF
										cQuery += "    AND DNN_SERIE  = '" + aVetEnv[nCntFor1][14] + "' " + CRLF
										cQuery += "    AND (DNN_STATUS = '3' OR DNN_STATUS = '5')"
										cQuery += "    AND D_E_L_E_T_ = ' ' "
										TCSqlExec(cQuery)
									EndIf
								EndIf
							EndIf
						Endif
					EndIf
				EndIf
			EndIf
		Next nCntFor1

	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return

/*{Protheus.doc} AtuPlaHere
Atualiza os planejamentos vindos da Here
@type Function
@author Valdemar Roberto Mognon
@since 20/02/2024
*/
Function AtuPlaHere(xResult_Ok,cProcesso,cAlias)
Local aAreas   := {DNP->(GetArea()),DA3->(GetArea()),DUT->(GetArea()),DA4->(GetArea()),DT6->(GetArea()),GetArea()}
Local aTours   := {}
Local aStops   := {}
Local aActivs  := {}
Local aEftHere := {}
Local nCntFor1 := 0
Local nCntFor2 := 0
Local nCntFor3 := 0
Local nCntFor4 := 0
Local lHere    := .F.
Local cPlanej  := ""
Local oObjResult
Local oHere

//-- Variáveis da programação
Local nPrgQtdVol := 0
Local nPrgPeso   := 0
Local nPrgPesoM3 := 0
Local nPrgValor  := 0
Local nPrgMetro3 := 0

//-- Variáveis do documento
Local cActiv   := ""
Local cFilDoc  := ""
Local cDoc     := ""
Local cSerie   := ""
Local nItem    := 0
Local lErroDoc := .F.

//-- Variáveis do veículo
Local cCodVei  := ""
Local lErroVei := .F.

Default xResult_Ok := ""
Default cProcesso  := ""
Default cAlias     := "DNM"

oObjResult := JsonObject():New()
oObjResult:FromJson(xResult_Ok)

cPlanej := SubStr(cProcesso,8,TamSx3("DNP_CODIGO")[1])

lErroDoc := TMSNDocHer(oObjResult,cPlanej)

If ValType(oObjResult["tours"]) == "A"
	INCLUI := .T.

	DA3->(DbSetOrder(1))
	DUT->(DbSetOrder(1))
	DA4->(DbSetOrder(1))
	DT6->(DbSetOrder(1))

	nPrgQtdVol := 0
	nPrgPeso   := 0
	nPrgPesoM3 := 0
	nPrgValor  := 0
	nPrgMetro3 := 0

	aTours := oObjResult["tours"]
	For nCntFor1 := 1 To Len(aTours)
		//-- Gera cabeçalho da programação
		RecLock("DF8",.T.)
		RegToMemory("DF8",.T.)
		DF8->DF8_FILIAL := xFilial("DF8")
		DF8->DF8_FILORI := M->DF8_FILORI
		DF8->DF8_NUMPRG := M->DF8_NUMPRG
		DF8->DF8_SEQPRG := StrZero(1,Len(DF8->DF8_SEQPRG))
		DF8->DF8_ROTA   := Padr(SuperGetMv("MV_ROTGENT",,""),Len(DF8->DF8_ROTA))
		DF8->DF8_SERTMS := StrZero(3,Len(DF8->DF8_SERTMS))
		DF8->DF8_TIPTRA := StrZero(1,Len(DF8->DF8_TIPTRA))
		DF8->DF8_DATGER := M->DF8_DATGER
		DF8->DF8_HORGER := M->DF8_HORGER
		DF8->DF8_STATUS := M->DF8_STATUS
		If DF8->(ColumnPos("DF8_ORIGEM")) > 0
			DF8->DF8_ORIGEM := StrZero(2,Len(DF8->DF8_ORIGEM))
		EndIf
		DF8->DF8_CODPLA := SubStr(cProcesso,8)
		DF8->(MsUnlock())
		ConfirmSX8()
		
		//-- Gera veículo da programação
		cCodVei := Upper(aTours[nCntFor1,"vehicleId"])
		cCodVei := BscProxVei(DF8->DF8_CODPLA,cCodVei)
		If DA3->(DbSeek(xFilial("DA3") + cCodVei))
			RecLock("DDZ",.T.)
			DDZ->DDZ_FILIAL := xFilial("DDZ")
			DDZ->DDZ_FILORI := DF8->DF8_FILORI
			DDZ->DDZ_NUMPRG := DF8->DF8_NUMPRG
			DDZ->DDZ_SEQPRG := DF8->DF8_SEQPRG
			If DUT->(DbSeek(xFilial("DUT") + DA3->DA3_TIPVEI))
				If DUT->DUT_CATVEI == "3"	//-- Carreta
					DDZ->DDZ_CODRB1 := DA3->DA3_COD
				Else	//-- Van, Truck, Especial, Utilitário
					DDZ->DDZ_CODVEI := DA3->DA3_COD
				EndIf
			EndIf
			DDZ->(MsUnlock())
			//-- Atualiza veículo utilizado no planejamento
			If FWAliasInDic("DNR",.F.) .And. cAlias == "DNM"
				DNR->(DbSetOrder(1))
				If DNR->(DbSeek(xFilial("DNR") + cPlanej + cCodVei))
					RecLock("DNR",.F.)
					DNR->DNR_USADO := StrZero(1,Len(DNR->DNR_USADO))
					DNR->(MsUnlock())
				EndIf
			EndIf
		EndIf
		
		//-- Gera documentos da programação
		nItem  := 0
		aStops := oObjResult["tours",nCntFor1,"stops"]
		For nCntFor2 := 1 To Len(aStops)
			aActivs := oObjResult["tours",nCntFor1,"stops",nCntFor2,"activities"]
			For nCntFor3 := 1 To Len(aActivs)
				If !AllTrim(aActivs[nCntFor3,"jobId"]) $ "departure:arrival"
					nItem   ++
					cActiv  := StrTran(Upper(aActivs[nCntFor3,"jobId"]),"_"," ")
					cFilDoc := SubStr(cActiv,1,Len(DD9->DD9_FILDOC))
					cDoc    := SubStr(cActiv,Len(DD9->DD9_FILDOC) + 1,Len(DD9->DD9_DOC))
					cSerie  := PadR(SubStr(cActiv,Len(DD9->DD9_FILDOC) + Len(DD9->DD9_DOC) + 1),Len(DD9->DD9_SERIE))
					RegToMemory("DD9",.T.)
					RecLock("DD9",.T.)
					DD9->DD9_FILIAL := xFilial("DD9")
					DD9->DD9_FILORI := DF8->DF8_FILORI
					DD9->DD9_NUMPRG := DF8->DF8_NUMPRG
					DD9->DD9_ITEM   := StrZero(nItem,Len(DD9->DD9_ITEM))
					If DT6->(DbSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie))
						DD9->DD9_CLIREM := DT6->DT6_CLIREM
						DD9->DD9_LOJREM := DT6->DT6_LOJREM
						DD9->DD9_CLIDES := DT6->DT6_CLIDES
						DD9->DD9_LOJDES := DT6->DT6_LOJDES
						DD9->DD9_SERTMS := DT6->DT6_SERTMS
					EndIf
					DD9->DD9_FILDOC := cFilDoc
					DD9->DD9_DOC    := cDoc
					DD9->DD9_SERIE  := cSerie
					DD9->DD9_SEQPRG := DF8->DF8_SEQPRG
					DD9->DD9_SEQUEN := StrZero(nItem,Len(DD9->DD9_SEQUEN))
					DD9->(MsUnlock())
				EndIf
			Next nCntFor3
		Next nCntFor2

		//-- Atualiza cabeçalho da programação
		RecLock("DF8",.F.)
		DF8->DF8_QTDVOL := nPrgQtdVol
		DF8->DF8_PESO   := nPrgPeso
		DF8->DF8_PESOM3 := nPrgPesoM3
		DF8->DF8_VALOR  := nPrgValor
		DF8->DF8_METRO3 := nPrgMetro3
		DF8->(MsUnlock())
				
		//-- Gera motorista da programação
		RegToMemory("DLS",.T.)
		RecLock("DLS",.T.)
		DLS->DLS_FILIAL := xFilial("DLS")
		DLS->DLS_FILORI := DF8->DF8_FILORI
		DLS->DLS_NUMPRG := DF8->DF8_NUMPRG
		DLS->DLS_ITEDF8 := DF8->DF8_SEQPRG
		DLS->DLS_CODVEI := DDZ->DDZ_CODVEI
		DLS->DLS_CODMOT := DA3->DA3_MOTORI
		DLS->DLS_CONDUT := M->DLS_CONDUT
		DLS->DLS_FORADT := M->DLS_FORADT
		DLS->DLS_FORPAG := StrZero(1,Len(DLS->DLS_FORPAG))
		If DA4->(DbSeek(xFilial("DA4") + DA3->DA3_MOTORI))
			DLS->DLS_TIPMOT := DA4->DA4_TIPMOT
		EndIf
		DLS->(MsUnlock())

		//-- Efetiva programação de carregamento
		If FWAliasInDic("DNM",.F.)
			oHere := TMSBCACOLENT():New("DNM")
			If oHere:DbGetToken()
				DNM->(DbGoTo(oHere:config_recno))
				If DNM->DNM_VIAAUT == "1"	//-- Efetiva automaticamente a programação
				    FWMsgrun(,{|| TMSA146Eft(.T.)},STR0029,STR0030)	//-- "Efetivação da Programação de carregamento" ### "Aguarde a geração da viagem."
					lHere := .T.
				EndIf
			EndIf
		EndIf

	Next nCntFor1

	If lHere
		If FindFunction("TMSA146Get")
			aEftHere := TMSA146Get("aEftHere")
		EndIf
		
		If !Empty(aEftHere)
			For nCntFor4 := 1 To Len(aEftHere)
				TMSBscRota(aEftHere[nCntFor4,1],aEftHere[nCntFor4,2],aEftHere[nCntFor4,3])
			Next nCntFor4
			aEftHere := {}
		EndIf

		If FindFunction("TMSA146Set")
			TMSA146Set("aEftHere",aEftHere)
		EndIf
	EndIf

EndIf

lErroVei := TMSnVeiHer(cPlanej)

//-- Atualiza planejamento Here quando houver falha no envio/processamento
If FWAliasInDic("DNP",.F.) .And. cAlias == "DNM"
	If lErroDoc .Or. lErroVei
		TMSAF94Atu(cPlanej,"3")
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return

/*{Protheus.doc} AtuViagem
Atualiza a Viagem após o Retorno da Here
@type Function
@author Valdemar Roberto Mognon
@since 26/08/2024
*/
Function AtuViagem(cFilOri,cViagem,aDados)
Local aAreas  := {DTR->(GetArea()),GetArea()}
Local cUltVia := ""

Default cFilOri := ""
Default cViagem := ""
Default aDados  := {}

DTR->(DbSetOrder(1))
If DTR->(DbSeek(cUltVia := xFilial("DTR") + cFilOri + cViagem))
	While DTR->(!Eof()) .And. DTR->(DTR_FILIAL + DTR_FILORI + DTR_VIAGEM) == cUltVia
		RecLock("DTR",.F.)
		DTR->DTR_VALPDG := aDados[1]
		DTR->(MsUnlock())
		DTR->(DbSkip())
	EndDo 
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} BscProxVei
Busca Próximo Veículo da Fila
@type Function
@author Valdemar Roberto Mognon
@since 25/09/2024
*/
Function BscProxVei(cCodPla,cIDHere)
Local aAreas    := {DNR->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasDNR := ""
Local cRet      := ""
Local nPos      := 0

Default cIDHere := ""

If !Empty(cIDHere)
	If (nPos := At("_",cIDHere)) > 1
		cIDHere := Left(cIDHere,nPos - 1)
	EndIf
	
	cAliasDNR := GetNextAlias()
	cQuery := "SELECT DNR.R_E_C_N_O_ REGISTRO,DNR_CODVEI "

	cQuery += "  FROM " + RetSqlName("DNR") + " DNR "

	cQuery += " WHERE DNR_FILIAL = '" + xFilial("DNR") + "' "
	cQuery += "   AND DNR_CODIGO = '" + cCodPla + "' "
	cQuery += "   AND DNR_IDHERE = '" + cIDHere + "' "
	cQuery += "   AND DNR.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDNR)

	If (cAliasDNR)->(!Eof())
		cRet := (cAliasDNR)->DNR_CODVEI
		DNR->(DbGoTo((cAliasDNR)->REGISTRO))
		RecLock("DNR",.F.)
		DNR->DNR_IDHERE := ""
		DNR->(MsUnlock())
	EndIf
	(cAliasDNR)->(DbCloseArea())
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cRet

/*{Protheus.doc} TMSBscRota
Busca Roteiro da Here
@type Function
@author Valdemar Roberto Mognon
@since 10/10/2024
*/
Function TMSBscRota(cFilOri,cNumPrg,cSeqPrg)
Local aRotHere := {}
Local aRetorno := {}
Local aAreas   := {DF8->(GetArea()),DDZ->(GetArea()),GetArea()}
Local cFilVia  := ""
Local cViagem  := ""

Default cFilOri := ""
Default cNumPrg := ""
Default cSeqPrg := ""

//-- Posiciona na Programação
DF8->(DbSetOrder(1))
DF8->(DbSeek(xFilial("DF8") + cFilOri + cNumPrg + cSeqPrg))
cFilVia := DF8->DF8_FILORI
cViagem := DF8->DF8_VIAGEM

//-- Posiciona no Veículo da Programação
DDZ->(DbSetOrder(1))
DDZ->(DbSeek(xFilial("DDZ") + cFilOri + cNumPrg + cSeqPrg))

//-- Grava Historico para Envio da Roteirização para a Here
If FindFunction("BscRotHere")
	BscRotHere()
EndIf

//-- Envia Pedido de Roteirização para a Here
aRetorno := TMSAI86AUX("ROT" + cFilOri + cNumPrg + cSeqPrg)

//-- Analisa o Retorno da Here
If FindFunction("RetRotHere") .And. aRetorno[1]
	aRotHere := RetRotHere(aRetorno[2])
EndIf

//-- Atualiza o Pedágio da Viagem
AtuViagem(cFilVia,cViagem,aRotHere)

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return

/*{Protheus.doc} TMSNDocHer
Retorna Documentos não Utilizados no Planejamento
@type Function
@author Valdemar Roberto Mognon
@since 10/11/2024
*/
Function TMSNDocHer(oObjeto,cPlanej)
Local lRet       := .F.
Local aUnassigne := {}
Local aRazoes    := {}
Local aAreas     := {DNQ->(GetArea()),GetArea()}
Local nCntFor1   := 0
Local nCntFor2   := 0
Local cFilDoc    := ""
Local cDoc       := ""
Local cSerie     := ""
Local cMensagem  := ""

Default oObjeto := Nil
Default cPlanej := ""

If ValType(oObjeto["unassigned"]) == "A"
	aUnassigne := oObjeto["unassigned"]

	For nCntFor1 := 1 To Len(aUnassigne)
		cFilDoc := StrTran(Upper(SubStr(aUnassigne[nCntFor1,"jobId"],1,Len(DT6->DT6_FILDOC))),"_"," ")
		cDoc    := StrTran(Upper(SubStr(aUnassigne[nCntFor1,"jobId"],Len(DT6->DT6_FILDOC) + 1,Len(DT6->DT6_DOC))),"_"," ")
		cSerie  := StrTran(Upper(SubStr(aUnassigne[nCntFor1,"jobId"],Len(DT6->DT6_FILDOC) + Len(DT6->DT6_DOC) + 1,Len(DT6->DT6_SERIE))),"_"," ")

		If ValType(aUnassigne[nCntFor1,"reasons"]) == "A"
			aRazoes := aUnassigne[nCntFor1,"reasons"]
            
			cMensagem := ""
			For nCntFor2 := 1 To Len(aRazoes)
				cMensagem += AllTrim(aRazoes[nCntFor2,"code"]) + CHR(10) + CHR(13) + ;
							 AllTrim(aRazoes[nCntFor2,"description"]) + CHR(10) + CHR(13)
			Next nCntFor2
			
			//-- Atualiza mensagens de erro no planejamento dos documentos
			If FWAliasInDic("DNQ",.F.)
				If !Empty(cMensagem)
					DNQ->(DbSetOrder(1))
					If DNQ->(DbSeek(xFilial("DNQ") + cPlanej + cFilDoc + cDoc + cSerie))
						RecLock("DNQ",.F.)
						DNQ->DNQ_MSGRET := cMensagem
						DNQ->(MsUnlock())
						lRet := .T.
					EndIf
				EndIf
			EndIf
		EndIf
	Next nCntFor1
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aAreas)

Return lRet

/*{Protheus.doc} TMSnVeiHer
Retorna Veículos não Utilizados no Planejamento
@type Function
@author Valdemar Roberto Mognon
@since 10/11/2024
*/
Function TMSnVeiHer(cPlanej)
Local lRet      := .F.
Local aAreas    := {DNR->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasDNR := ""
Local nQtdVei   := 0

Default cPlanej := ""

If FWAliasInDic("DNR",.F.)
	//-- Verifica se existem veículos não usados
	cAliasDNR := GetNextAlias()

	cQuery := "SELECT DNR.R_E_C_N_O_ REGISTRO"
	cQuery +=   "FROM " + RetSqlName("DNR") + " DNR "
	cQuery +=  "WHERE DNR_FILIAL = '" + xFilial("DNR") + "' "
	cQuery +=    "AND DNR_CODIGO = '" + cPlanej + "' "
	cQuery +=    "AND DNR.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDNR)

	While (cAliasDNR)->(!Eof())
		DNR->(DbGoTo((cAliasDNR)->REGISTRO))

		If DNR->DNR_USADO == "2"
			nQtdVei ++
			RecLock("DNR",.F.)
			DNR_MSGRET = STR0031	//-- Veículo não utilizado por falta de mercadoria
			DNR->(MsUnlock())
		EndIf

		(cAliasDNR)->(DbSkip())
	EndDo

	(cAliasDNR)->(DbCloseArea())

	If nQtdVei > 0
		lRet := .T.
	EndIf
EndIf

aEval(aAreas,{|x| RestArea(x)})
FwFreeArray(aAreas)

Return lRet
