#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

Function GFE51Query(cId, aParam)
Local oResponse as object
Local lRetDados := .f.
Local lMsgErro := ''
Local aRet := {}
Local cDanfe := ""
Local cSeq := "" 


If !Empty(cId)

	cDanfe := substring(cId,1,44)
	cSeq   := substring(cId,45,2)

	cWhere := "%"	
	cWhere += "AND GWU.GWU_SEQ = " + cSeq + " AND GW1.GW1_DANFE = " + "'" + cDanfe + "'"
	cWhere += "%"
Else
	If Len(aParam) > 0 .AND. !Empty(aParam[1])
		cWhere := "%"
		cWhere += "AND GWU.GWU_DTENT = " + aParam[1]
		cWhere += "%"
	Else
		cWhere := "% AND 1 = 1%"
	EndIf
EndIf

oResponse := JsonObject():New()
cAliasQry := GetNextAlias()

If Len(aParam) > 1

	BeginSql Alias cAliasQry
		SELECT *
		FROM %table:GWU% GWU
			INNER JOIN %table:GW1% GW1 
			ON  GW1.GW1_FILIAL = GWU.GWU_FILIAL
			AND GW1.GW1_CDTPDC = GWU.GWU_CDTPDC
			AND GW1.GW1_EMISDC = GWU.GWU_EMISDC
			AND GW1.GW1_SERDC  = GWU.GWU_SERDC
			AND GW1.GW1_NRDC   = GWU.GWU_NRDC
		WHERE GWU.%notDel% AND GW1.%notDel%
		%Exp:cWhere%
		ORDER BY GWU.GWU_FILIAL, GWU.GWU_NRDC
		OFFSET %exp:aParam[2]% ROWS FETCH NEXT %exp:aParam[3]% ROWS ONLY
	EndSql	


Else

	BeginSql Alias cAliasQry
		SELECT *
		FROM %table:GWU% GWU
			INNER JOIN %table:GW1% GW1 
			ON  GW1.GW1_FILIAL = GWU.GWU_FILIAL
			AND GW1.GW1_CDTPDC = GWU.GWU_CDTPDC
			AND GW1.GW1_EMISDC = GWU.GWU_EMISDC
			AND GW1.GW1_SERDC  = GWU.GWU_SERDC
			AND GW1.GW1_NRDC   = GWU.GWU_NRDC
		WHERE GWU.%notDel% AND GW1.%notDel%
		%Exp:cWhere%
		ORDER BY GWU.GWU_FILIAL, GWU.GWU_NRDC
	EndSql	
EndIf

oResponse["hasNext"] := .t.
oResponse["items"]   := {}
        
If (cAliasQry)->(!Eof())

	While (cAliasQry)->(!Eof())

		oTrecho := JsonObject():New()

		oTrecho["BranchId"]       		   := (cAliasQry)->GWU_FILIAL
		oTrecho["DocType"]			       := (cAliasQry)->GWU_CDTPDC
		oTrecho["Issuer"]       		   := (cAliasQry)->GWU_EMISDC
		oTrecho["IssueDate"]       		   := (cAliasQry)->GW1_DTEMIS
		oTrecho["Series"]       		   := (cAliasQry)->GWU_SERDC
		oTrecho["Number"]       		   := (cAliasQry)->GWU_NRDC
		oTrecho["ElectronicValidationKey"] := (cAliasQry)->GW1_DANFE
		oTrecho["Carrier"]       		   := (cAliasQry)->GWU_CDTRP
		oTrecho["PartSequence"]            := (cAliasQry)->GWU_SEQ
		oTrecho["DeliveryDate"]            := (cAliasQry)->GWU_DTENT
		oTrecho["DeliveryReceipt"]         := (cAliasQry)->GWU_FLGENT
		oTrecho["EvidenceOfDelivery"]      := (cAliasQry)->GWU_EVENTR

		AADD(oResponse["items"], oTrecho)
		
		lRetDados := .t.

		(cAliasQry)->(dbSkip())
	End
Else
	lMsgErro := "Nao fo(ram) encontrado(s) trecho(s)."
Endif       
(cAliasQry)->(DbCloseArea())

If lRetDados
	aRet := {lRetDados,,oResponse:ToJson()}
Else
	aRet := {lRetDados, 404, lMsgErro}
EndIf

Return aRet

Function GFE51REST(lAlteracao,oContent,aNames)
	Local aRetCalc
	Local cContent		:= ""
	Local aRet			:= {}
	Local cReturn		:= ""
	Local oModelGWN
	Local oModelGW1
	Local lFoundGWN     := .f.
	Local nIndLines := 0
	Local nX, nI
	Local aGWN := {}
	Local aGW1 := {}
	Local aGravaGW1 := {}
	Local aDocsCarg := {}
	Local nCont := 0
	Local lRet := .t.
	Local cFilGWN := ''
	Local cGWN_NRROM := ''
	Local nLenCDTPDC := TamSx3("GW1_CDTPDC")[1]
	Local nLenEMISDC := TamSx3("GW1_EMISDC")[1]
	Local nLenSERSDC := TamSx3("GW1_SERDC")[1]
	Local nLenNRSDC  := TamSx3("GW1_NRDC")[1]
	Local aRet := {.t.,,"Romaneio "+IIF(lAlteracao,"alterado","incluido") + " com sucesso."}
	Local cFilDC, cTpDc, cEmisDc, cSerDc, cNrDc

	Private aDocFil := {} // Documentos de carga Filtrados
	Private aDocSel := {} // Documentos de Carga Selecionados
	Private cGWU_DTENT 
	Private cGWU_HRENT 
	Private cGWU_EVENT 
	Private lChkEntr   	
	Private cMovType := ""
	nScan1 := aScan(aNames,{|x| Upper(x) == Upper('CompanyID')})
	nScan2 := aScan(aNames,{|x| Upper(x) == Upper('BranchId')})

	If nScan2 > 0
		RpcClearEnv()
		RPCSetType(3)
		RpcSetEnv(oContent[aNames[nScan1]],oContent[aNames[nScan2]],,,,GetEnvServer(),{ })
	EndIf	
		
	nScan3 := aScan(aNames,{|x| Upper(x) == Upper('DocType')})
	nScan4 := aScan(aNames,{|x| Upper(x) == Upper('Issuer')})
	nScan5 := aScan(aNames,{|x| Upper(x) == Upper('Series')})
	nScan6 := aScan(aNames,{|x| Upper(x) == Upper('Number')})
	
	nScan7 := aScan(aNames,{|x| Upper(x) == Upper('PartSequence')})
	nScan8 := aScan(aNames,{|x| Upper(x) == Upper('DeliveryDate')})
	nScan9 := aScan(aNames,{|x| Upper(x) == Upper('DeliveryHour')})
	nScan10 := aScan(aNames,{|x| Upper(x) == Upper('DeliveryReceipt')})
	nScan11 := aScan(aNames,{|x| Upper(x) == Upper('EvidenceOfDelivery')})
	nScan12 := aScan(aNames,{|x| Upper(x) == Upper('MovementType')})
	nScan13 := aScan(aNames,{|x| Upper(x) == Upper('ElectronicValidationKey')})


	if nScan2 > 0
		cFilDC := PadR( oContent[aNames[nScan2]] , TamSx3("GW1_FILIAL")[1] )
	Endif
	if nScan3 > 0
		cTpDc  := PadR( oContent[aNames[nScan3]] , TamSx3("GW1_CDTPDC")[1] )
	Endif
	if nScan4 > 0
		cEmisDc := PadR( oContent[aNames[nScan4]] , TamSx3("GW1_EMISDC")[1] )
	Endif
	if nScan5 > 0
		cSerDc := PadR( oContent[aNames[nScan5]] , TamSx3("GW1_SERDC")[1] )
	Endif
	if nScan6 > 0
		cNrDc := PadR( oContent[aNames[nScan6]] , TamSx3("GW1_NRDC")[1] )
	Endif	

	if nScan8 > 0
		cGWU_DTENT := oContent[aNames[nScan8]]
	Endif
	if nScan9 > 0
		cGWU_HRENT := oContent[aNames[nScan9]]
	Endif
	if nScan10 > 0
		lChkEntr   := oContent[aNames[nScan10]]
	Endif	
	if nScan11 > 0
		cGWU_EVENT := oContent[aNames[nScan11]]

	Endif
	if nScan12 > 0
		cMovType := oContent[aNames[nScan12]]
	Endif

	if nScan13 > 0
		cDanfe := PadR( oContent[aNames[nScan13]] , TamSx3("GW1_DANFE")[1] )
	Endif	

	/* Verifica se a chave foi informada, senão utiliza os outros campos */
	if nScan13 > 0 

		dbSelectArea("GW1")
		dbSetOrder(12)

		If  dbSeek(cDanfe + cFilDC)
	
			if nScan7 > 0
				aRet := GFEGRVGWU(oContent[aNames[nScan7]])
			Endif

		Else
			aRet := {.f., 200, "Documento de carga informado nao existe no banco de dados!" }
			Return aRet
		EndIf
	else

		dbSelectArea("GW1")
		GW1->( dbSetOrder(1) )

		If GW1->( dbSeek(cFilDC + cTpDc + cEmisDc + cSerDc + cNrDc) ) 

			if nScan7 > 0
				aRet := GFEGRVGWU(oContent[aNames[nScan7]])
			Endif					

		Else
			aRet := {.f., 200, "Documento de carga informado nao existe no banco de dados!" }
			Return aRet
		EndIf
	Endif 

Return aRet

Static Function GFEGRVGWU(pSeq_gwu)

	Local lContinua := .T.
	Local aRet := {}
	Local cSeq_GWU := ""
	Local lRet
	Local cMensagem := ""
	Local aGFE := {}
	Local aAreaGWU  := GWL->(GetArea())

	if !empty(pSeq_gwu) 
		if len(pSeq_gwu) == 1
			cSeq_GWU := '0' + pSeq_gwu
		else 
		    cSeq_GWU := pSeq_gwu
		endif
	endif

	dbSelectArea("GWU")
	dbSetOrder(1)
	If dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC + PadR( cSeq_gwu , TamSx3("GWU_SEQ")[1] ) )

		if cMovType == "1" // Entrega	

			If Empty(cGWU_HRENT)
				cX3Rel := &(GetSx3Cache("GWU_HRENT", "X3_RELACAO"))
				If !Empty(cX3Rel)
					cGWU_HRENT := cX3Rel
				EndIf
			EndIf
			
			If !Empty(GWU->GWU_DTENT)
				cAliasGW1 := GetNextAlias()
				BeginSql Alias cAliasGW1
					SELECT 1
					FROM %Table:GW1% GW1
					WHERE GW1.GW1_FILIAL = %xFilial:GWU%
					AND GW1.GW1_CDTPDC = %Exp:GWU->GWU_CDTPDC%
					AND GW1.GW1_EMISDC = %Exp:GWU->GWU_EMISDC%
					AND GW1.GW1_SERDC = %Exp:GWU->GWU_SERDC%
					AND GW1.GW1_NRDC = %Exp:GWU->GWU_NRDC%
					AND GW1.GW1_SIT = '6'
					AND GW1.%NotDel%
				EndSql
				If (cAliasGW1)->(!Eof())
					//If !MsgYesNo("Este registro já contém data/hora de entrega e pertence a um documento retornado.Deseja atualizar a data/hora de entrega?")	// 
					//	lContinua := .F.
					//EndIf
					aRet := {.f., 200, "Este registro já contém data/hora de entrega e pertence a um documento retornado." }
					lContinua := .F.
				Else				
					aRet := {.f., 200, "Este registro já contém data/hora de entrega" }
					lContinua := .F.
				EndIf
				(cAliasGW1)->(dbCloseArea())
			EndIf

			if lContinua

				aGFE := GFEA051PV(STOD(cGWU_DTENT),cGWU_HRENT,cGWU_EVENT,lChkEntr)

				if aGFE[1] 
					aRet := {.T., 200 , "Registro de Entrega Realizado" }

					GFE050AUDIT(GW1->GW1_FILIAL, GW1->GW1_CDTPDC,GW1->GW1_EMISDC,GW1->GW1_SERDC, GW1->GW1_NRDC) // Chamada de função para validação e execução de auditoria de Documento de Frete apos entrega
				else
					aRet := {.F., 200, aGFE[2] }
				endif

			EndIf
		Elseif cMovType == "2"
			// Cancelamento da entrega
			// GFEA051CL

			lRet := .T.

			cAliasGV5 := GetNextAlias()
			BeginSql Alias cAliasGV5
				SELECT 1
				FROM %Table:GV5% GV5
				WHERE GV5.GV5_FILIAL = %xFilial:GV5%
				AND GV5.GV5_CDTPDC = %Exp:GWU->GWU_CDTPDC%
				AND GV5.%NotDel%
			EndSql
			If (cAliasGV5)->(!Eof())
				If Empty(GWU->GWU_DTENT) .And. Empty(GWU->GWU_HRENT)
					aRet := {.f., 200, "Registro não contém Data de Entrega cadastrado." }
					lRet := .F.
				EndIf

				If lRet .And. !GFEA051VDC(@cMensagem)
					aRet := {.f., 200, cMensagem }
					lRet := .F.
				EndIf
				If lRet
					// Grava o recebimento/Cancelamento para demais entregas do mesmo calculo
					//GFEA51ENTD(.F.)
					GFEA51STEN()
				EndIf
			EndIf
			(cAliasGV5)->(dbCloseArea())

			If lRet				
				aRet := {.T., 200 , "Registro de Entrega Cancelado" }
			EndIf
			
			RestArea(aAreaGWU)		

		Endif
	else 	
		aRet := {.f., 200 , "Trecho não encontrado" }	
	Endif

Return aRet
