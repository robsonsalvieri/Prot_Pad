#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'GTPA421L.CH'

/*/{Protheus.doc} GTPA421L
	Reprocessamento de ficha de remessa
	@type Function
	@author João Pires
	@since 19/06/2026
/*/
Function GTPA421L()
	Local aParamBox := {}
	Local aRet      := {}
	Local lRet      := .T.
	Local lSldFch   := GTPGetRules("HABSLDFCH",,,.F.)

	aAdd(aParamBox, {1,STR0001,  Space(6)	 , "@!" ,, "GI6",, 50, .T.} )	//Agencia
	aAdd(aParamBox, {1,STR0002, Ctod(Space(8)),"","","","",50,.T.})        //Data inicial

	If lSldFch .And. ParamBox(aParamBox,STR0003,@aRet)  //"Informe os parâmetros..."
		FWMsgRun(,{|| lRet := A421kChkG6X(aRet[1],aRet[2])}, STR0004, STR0005) //"Reprocessamento de Ficha de Remessa" "Analisando fichas de remessa..."

		If lRet
			FWMsgRun(,{|| lRet := A421kReproc(aRet[1],aRet[2])}, STR0004, STR0006) //Reprocessando fichas de remessa..."
		Endif

		If lRet
			FWAlertSuccess(STR0007) //"Processo concluido"
		Else
			FWAlertError(STR0008) //"Falha na execução do reprocessamento!"
		Endif

	Endif
Return

/*/{Protheus.doc} A421kChkG6X
    Reprocessa ficha de remessa
    @type  Static Function
    @author João Pires
    @since 19/06/2026
/*/
Static Function A421kChkG6X(cAgencia,dData)
	Local cAliasG6X := GetNextAlias()
	Local lRet      := .T.

	BeginSQL alias cAliasG6X
		SELECT
            G6X_NUMFCH
        FROM %TABLE:G6X% G6X  
        WHERE 
            G6X_FILIAL = %xFilial:GIC%
        AND G6X_AGENCI = %Exp:cAgencia%
        AND G6X_DTINI >= %Exp:DtoS(dData)%
        AND (G6X_STATUS NOT IN ('1','5')
            OR G6X_FLAGCX = 'T'
            OR G6X_FECHCX = 'T')
        AND G6X.%NotDel%

	EndSQL

	lRet := (cAliasG6X)->(Eof())

	(cAliasG6X)->(DbCloseArea())

	If !lRet
		FWAlertError(STR0009, STR0010) //"Existem fichas de remessa entregues ou finalizadas no período!"
	Endif

Return lRet


/*/{Protheus.doc} A421kReproc
    Reprocessa ficha de remessa
    @type  Static Function
    @author João Pires
    @since 19/06/2026
/*/
Static Function A421kReproc(cAgencia,dData)
	Local oMdl421   := FwLoadModel('GTPA421')
	Local nTaCodSeq := TamSx3('GZG_SEQ')[1]
	Local nTamDescr := TamSx3('GZG_DESCRI')[1]
	Local cMdlGZG   := ""
	Local cAliasG6X := ""
	Local cAliasGIC := ""
	Local cAliasSLD := ""
	Local cAliasTef := ""
	Local aFichas   := {}
	Local nX        := 1
	Local aAreaG6X  := G6X->(GetArea())
	Local nSaldoAnt := 0
	Local nTotCan   := 0
	Local lRet      := .T.
	Local cTPAgto   := ""
	Local nTpAgto   := 0
	Local cSeq		:= ""

	cAliasG6X := GetNextAlias()

	BeginSQL alias cAliasG6X
		SELECT
            R_E_C_N_O_ AS G6XREC
        FROM %TABLE:G6X% G6X  
        WHERE 
            G6X_FILIAL = %xFilial:G6X%
        AND G6X_AGENCI = %Exp:cAgencia%
        AND G6X_DTINI >= %Exp:DtoS(dData)%
        AND G6X_STATUS IN ('1','5')            
        AND G6X.%NotDel%
        ORDER BY G6X_DTINI

	EndSQL

	While (cAliasG6X)->(!Eof())
		aAdd(aFichas,(cAliasG6X)->G6XREC)
		(cAliasG6X)->(DBSkip())
	EndDo
	(cAliasG6X)->(DBCloseArea())

	For nX := 1 to Len(aFichas)

		//Amarração de novos bilhetes
		G6X->(DBGoTo(aFichas[nX]))

		cAliasGIC := GetNextAlias()

		BeginSQL alias cAliasGIC
            SELECT                    
                R_E_C_N_O_ AS GICREC
            FROM %TABLE:GIC% GIC 
            WHERE 
                GIC_FILIAL = %xFilial:GIC%
            AND GIC_AGENCI = %Exp:cAgencia%
            AND (
                    (%Exp:G421CpoVenda()%  BETWEEN %Exp:DtoS(G6X->G6X_DTINI)%  AND %Exp:DtoS(G6X->G6X_DTFIN)%)
			    or 
			    (
				%Exp:G421CpoVenda()% <= %Exp:DtoS(G6X->G6X_DTINI)%
				AND GIC_TIPO = 'E' 
				AND GIC_ORIGEM = '2'   
			    )
                )
            AND GIC_NUMFCH = ''
            AND GIC_VENDRJ Not In ('BCA','IVP')	
            AND GIC.%NotDel%            
		EndSQL

		While (cAliasGIC)->(!Eof())
			GIC->(DBGoTo((cAliasGIC)->GICREC))
			RecLock("GIC",.F.)
			    GIC->GIC_NUMFCH := G6X->G6X_NUMFCH
			    GIC->GIC_CARGA  := .T.
			MSUnlock()

			(cAliasGIC)->(DBSkip())
		EndDo
		(cAliasGIC)->(DBCloseArea())

		//Atualização de saldos
		nSaldoAnt := 0
		cAliasSLD := GetNextAlias()

		BeginSql Alias cAliasSLD

            SELECT G6X.G6X_VLDIFE
                FROM %Table:G6X% G6X
            WHERE  G6X.G6X_FILIAL =  %xFilial:G6X%
                AND G6X.G6X_AGENCI = %Exp:cAgencia%
                AND G6X.G6X_DTFIN < %Exp:DtoS(G6X->G6X_DTINI)%
                AND G6X.%NotDel%
            ORDER  BY G6X.G6X_DTFIN DESC 

		EndSql

		If (cAliasSLD)->(!Eof())
			nSaldoAnt := (cAliasSLD)->G6X_VLDIFE
		Endif

		(cAliasSLD)->(DBCloseArea())

		//Requisições
		cAliasREQ := GetNextAlias()

		BeginSql Alias cAliasREQ
            SELECT 
                '5' AS TIPO,                     
                COALESCE(SUM(GIC.GIC_REQTOT), 0) AS TOTAL
            FROM %TABLE:GIC% GIC
            WHERE 
                GIC.GIC_STATUS = 'V'
                AND GIC.GIC_FILIAL  = %xFilial:GIC%
                AND GIC.GIC_AGENCI  = %Exp:cAgencia%
                AND (
                    (%Exp:G421CpoVenda()% BETWEEN %Exp:DtoS(G6X->G6X_DTINI)% AND %Exp:DtoS(G6X->G6X_DTFIN)%)
                    OR (
                        %Exp:G421CpoVenda()% <= %Exp:DtoS(G6X->G6X_DTINI)%
                        AND GIC.GIC_TIPO = 'E'
                        AND GIC.GIC_ORIGEM = '2'
                    )
                )
                AND GIC.GIC_NUMFCH = %Exp:G6X->G6X_NUMFCH%
                AND GIC.GIC_VENDRJ NOT IN ('BCA', 'IVP')				
                AND GIC.GIC_CODREQ <> ''                    
                AND GIC.%NotDel%
		EndSql

		nTotReq := (cAliasREQ)->TOTAL
		(cAliasREQ)->(DBCloseArea())

		oMdl421:SetOperation(MODEL_OPERATION_UPDATE)
		oMdl421:Activate()
		lRet := oMdl421:IsActive()

		If lRet

			If oMdl421:GetModel('GZGRECEITA'):SeekLine({{'GZG_COD', '026'}}, , .T.)
				oMdl421:GetModel('GZGRECEITA'):DeleteLine()
			ElseIf oMdl421:GetModel('GZGDESPESA'):SeekLine({{'GZG_COD', '026'}}, , .T.)
				oMdl421:GetModel('GZGDESPESA'):DeleteLine()
			Endif

			If nSaldoAnt <> 0
				cMdlGZG := IIf(nSaldoAnt > 0,'GZGRECEITA','GZGDESPESA')
				cSeq := GA421SeqGZG(oMdl421:GetModel(cMdlGZG),nTaCodSeq)

				If !Empty(oMdl421:GetModel(cMdlGZG):GetValue('GZG_COD')) .Or. oMdl421:GetModel(cMdlGZG):IsDeleted()
					oMdl421:GetModel(cMdlGZG):AddLine()
				Endif
				oMdl421:GetModel(cMdlGZG):SetValue("GZG_AGENCI", cAgencia)
				oMdl421:GetModel(cMdlGZG):SetValue("GZG_NUMFCH", G6X->G6X_NUMFCH)
				oMdl421:GetModel(cMdlGZG):SetValue("GZG_SEQ"   , cSeq)
				oMdl421:GetModel(cMdlGZG):SetValue("GZG_COD"   , '026')
				oMdl421:GetModel(cMdlGZG):SetValue("GZG_DESCRI", Padl(AllTrim(POSICIONE('GZC' ,1 ,XFILIAL('GZC') + '026', 'GZC_DESCRI')),nTamDescr))
				oMdl421:GetModel(cMdlGZG):SetValue("GZG_TIPO"  , IIf(nSaldoAnt > 0,'1','2'))
				oMdl421:GetModel(cMdlGZG):SetValue("GZG_CARGA" , .T.)
				oMdl421:GetModel(cMdlGZG):SetValue("GZG_VALOR" , IIf(nSaldoAnt > 0,nSaldoAnt,nSaldoAnt*(-1)))

			Endif

			//Atualiza cancelamentos
			nTotCan := oMdl421:GetModel('421CALCTOT'):GetValue('TOTALCANCEL')
			If nTotCan > 0
				If oMdl421:GetModel('GZGDESPESA'):SeekLine({{'GZG_COD', '003'}}, , .T.)
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_VALOR",nTotCan)
				Else
					cSeq := GA421SeqGZG(oMdl421:GetModel('GZGDESPESA'),nTaCodSeq)

					If !Empty(oMdl421:GetModel('GZGDESPESA'):GetValue('GZG_COD')) .Or. oMdl421:GetModel('GZGDESPESA'):IsDeleted()
						oMdl421:GetModel('GZGDESPESA'):AddLine()
					Endif

					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_AGENCI", cAgencia)
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_NUMFCH", G6X->G6X_NUMFCH)
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_SEQ"   , cSeq)
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_COD"   , '003')
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_DESCRI", Padl(AllTrim(POSICIONE('GZC' ,1 ,XFILIAL('GZC') + '003', 'GZC_DESCRI')),nTamDescr))
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_TIPO"  , '2')
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_CARGA" , .T.)
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_VALOR" , nTotCan)
				Endif

			Endif

			//Atualiza requisições
			If nTotReq > 0
				If oMdl421:GetModel('GZGDESPESA'):SeekLine({{'GZG_COD', '005'}}, , .T.)
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_VALOR",nTotReq)
				Else
					cSeq := GA421SeqGZG(oMdl421:GetModel('GZGDESPESA'),nTaCodSeq)

					If !Empty(oMdl421:GetModel('GZGDESPESA'):GetValue('GZG_COD')) .Or. oMdl421:GetModel('GZGDESPESA'):IsDeleted()
						oMdl421:GetModel('GZGDESPESA'):AddLine()
					Endif

					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_AGENCI", cAgencia)
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_NUMFCH", G6X->G6X_NUMFCH)
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_SEQ"   , cSeq)
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_COD"   , '005')
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_DESCRI", Padl(AllTrim(POSICIONE('GZC' ,1 ,XFILIAL('GZC') + '005', 'GZC_DESCRI')),nTamDescr))
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_TIPO"  , '2')
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_CARGA" , .T.)
					oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_VALOR" , nTotReq)
				Endif

			Endif

			cAliasTef := GetNextAlias()

			BeginSQL alias cAliasTef
                    SELECT 
                        GZP.GZP_TPAGTO AS TIPO,
                        SUM(GZP.GZP_VALOR) AS TOTAL
                    FROM %TABLE:GIC% GIC 
                    INNER JOIN %TABLE:GZP% GZP ON
                        GZP.GZP_FILIAL = GIC.GIC_FILIAL
                        AND GZP.GZP_CODIGO = GIC.GIC_CODIGO
                        AND GZP.GZP_CODBIL = GIC.GIC_BILHET
                        AND GZP.%NotDel%
                    WHERE 
                        GIC.GIC_FILIAL = %xFilial:GIC%
                        AND GIC.GIC_AGENCI = %Exp:cAgencia%
                        AND (
                            (%Exp:G421CpoVenda()% BETWEEN %Exp:DtoS(G6X->G6X_DTINI)% AND %Exp:DtoS(G6X->G6X_DTFIN)%)
                            OR (
                                %Exp:G421CpoVenda()% <= %Exp:DtoS(G6X->G6X_DTINI)% 
                                AND GIC.GIC_TIPO = 'E' 
                                AND GIC.GIC_ORIGEM = '2'
                            )
                        )
                        AND GIC.GIC_STATUS <> 'C'
                        AND GIC.GIC_VENDRJ NOT IN ('BCA','IVP')		                        
                        AND GIC.GIC_NUMFCH = %Exp:G6X->G6X_NUMFCH%
                        AND GIC.%NotDel%
                    GROUP BY 
                        GZP.GZP_TPAGTO

			EndSQL

			While (cAliasTef)->(!Eof())

				cTPAgto := (cAliasTef)->TIPO
				nTpagto := Gtp421Pgto("2",cTPAgto)

				If (cAliasTef)->TOTAL > 0 .And. nTpagto > 0 .And. cTPAgto <> "OS"
					nTpagto := StrZero(nTpagto,TamSx3('GZG_COD')[1])

					If oMdl421:GetModel('GZGDESPESA'):SeekLine({{'GZG_COD', nTpagto}}, , .T.)
						oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_VALOR",(cAliasTef)->TOTAL)
					Else

						cSeq := GA421SeqGZG(oMdl421:GetModel('GZGDESPESA'),nTaCodSeq)

						If !Empty(oMdl421:GetModel('GZGDESPESA'):GetValue('GZG_COD')) .Or. oMdl421:GetModel('GZGDESPESA'):IsDeleted()
							oMdl421:GetModel('GZGDESPESA'):AddLine()
						EndIf

						oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_AGENCI", cAgencia)
						oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_NUMFCH", G6X->G6X_NUMFCH)
						oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_SEQ"   , cSeq)
						oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_COD"   , nTpagto)
						oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_DESCRI", Padl(POSICIONE('GZC' ,1 ,XFILIAL('GZC') + nTpagto , 'GZC_DESCRI'),nTamDescr))
						oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_TIPO"  , "2")
						oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_CARGA" , .T.)
						oMdl421:GetModel('GZGDESPESA'):SetValue("GZG_VALOR" , (cAliasTef)->TOTAL )

					Endif
				Endif

				(cAliasTef)->(dbSkip())

			EndDo

			(cAliasTef)->(DbCloseArea())

		Endif

		lRet := lRet .And. oMdl421:VldData() .AND. oMdl421:CommitData()

		If lRet
			oMdl421:DeActivate()
		Else
			JurShowErro( oMdl421:GetErrormessage() )
			Exit
		Endif

	Next nX

	RestArea(aAreaG6X)
	aSize(aFichas,0)
    GTPDestroy(oMdl421)

Return lRet

/*/{Protheus.doc} GA421SeqGZG
	Retorna a próxima sequência da GZG
	@type  Static Function
	@author João Pires
	@since 13/08/2026
/*/
Static Function GA421SeqGZG(oGrid,nTaCodSeq)
	Local cSeq := ""

	oGrid:GoLine(oGrid:Length())

	If !Empty(oGrid:GetValue("GZG_SEQ"))
		cSeq := Soma1(oGrid:GetValue("GZG_SEQ"))
	Else
		cSeq := StrZero(oGrid:Length(),nTaCodSeq)
	Endif

Return cSeq
