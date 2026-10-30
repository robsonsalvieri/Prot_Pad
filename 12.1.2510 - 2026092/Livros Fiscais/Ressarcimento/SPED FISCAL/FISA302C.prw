#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA302C.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA302C
  
Rotina de Apuração do Ressarcimento / Complemento do ICMS ST via SPED Fiscal.
O leiaute dos registros ressarcimento foi instituído Guia Prático da EFD-ICMS/IPI, a partir da versão 3.0.2, 
leiaute 014.

@author Rafael.Soliveira / Ulisses.Oliveira / Anedino.Santos
@since 08/11/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA302C()
	Local aArea     := GetArea()
	Local cIdApur   := ''
	Local cPerApur  := ''
	Local lProcess  := .T.

	If AliasIndic("CIG") .and. AliasIndic("CIH") .and. AliasIndic("CII") .and. AliasIndic("CIJ") .and. AliasIndic("CIK") .and. AliasIndic("CIL") .and. AliasIndic("CIF") .and. AliasIndic("CIM")

		If Pergunte("FISA302C",.T.)
			cPerApur := MV_PAR01

			//---Verifica a existência de apuração no período selecionado---//
			cIdApur := CheckApur(cPerApur)

			If !Empty(cIdApur)
				If (ApMsgNoYes(STR0002 + CHR(10) + CHR(13) + STR0001 ) ) //"Apuração já realizada no período selecionado." "Deseja fazer o reprocessamento?"
					DeletApur(cIdApur,cPerApur)
				Else
					lProcess := .F.
				EndIf
			EndIf

			If lProcess
				FwMsgRun(,{|oSay| FISA302CA(oSay,cPerApur)},STR0003,"") //"Apuração do Ressarcimento do ICMS Retido por ST"
			EndIf

		EndIf
	EndIf

	RestArea(aArea)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
  
Rotina de Processamento da Apuração.

@author Rafael.Soliveira
@since 08/11/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA302CA(oSay,cPerApur)
	Local cAlias      := GetNextAlias()
	Local cIdApur     := ''
	Local cPerSld     := ''
	Local dDataDe     := CtoD('  /  /    ')
	Local dDataAte    := CtoD('  /  /    ')
	Local cProduto    := ''
	Local nMVICMPAD   := SuperGetMV('MV_ICMPAD',.F.,18)
	Local cMVESTADO   := SuperGetMV('MV_ESTADO',.F.,'')
	Local nAliqInt    := 0
	Local aDocOriApu  := {}
	Local oApuracao   := Nil
	Local cSGBD       := TCGetDB()
	Local cSubStrBD   := ''
	Local aRegSemCod  := CheckCIM()
	Local oModel      := FWLoadModel('FISA302B') //---Model da rotina FISA302B---//
	Local lCIJRessar  := CIJ->(FieldPos("CIJ_RESSAR")) > 0
	Local cCIJRessar  := ''
	Local cFiltro     := ''
	Local lCSDXML     := SuperGetMv("MV_CSDXML",,.F.)
	Local lCPItXml    := Iif(FindFunction('VerTabXml'), VerTabXml(), .F.)
	Local lUsaXml     := lCSDXML .And. lCPItXml
	Local cItem       := ""
	Local cProxIt     := ""
	Local oJsonXML    := JsonObject():new()
	Local cSlctXML    := ""
	Local cJoinXML    := ""
	Local cOrderBy    := ""
	Private lAutomato := IiF(IsBlind(),.T.,.F.)

	If lAutomato
		FwMsgRun(,{|oSay| FISA302Carga( oSay ) },STR0001,"") //"Processando carga inicial das Regras"
		FwMsgRun(,{|oSay| F302CCarga( oSay ) },STR0001,"") //"Processando carga inicial das Regras"
	EndIf

	AtualizaMsg(oSay,STR0004) //"Iniciando processamento..."

	cIdApur   := FWUUID("CII")
	dDataDe   := StoD(MV_PAR01+'01')
	dDataAte  := LastDay(dDataDe)

	//---Classe responsável pela apuração do movimento---//
	oApuracao := FISA302APURACAO():New(cIdApur,cPerApur,aRegSemCod,cMVESTADO)

	AtualizaMsg(oSay,STR0005) //"Verificando movimento no período..."

	//---Query Principal---//
	If cSGBD = 'ORACLE'
		cSubStrBD := 'SUBSTR(SFT.FT_CLASFIS,2,2)'
	Else
		cSubStrBD := 'RIGHT(SFT.FT_CLASFIS,2)'
	EndIf
	cSubStrBD := "%" + cSubStrBD + "%"

	If lCIJRessar
		cCIJRessar := "CIJ.CIJ_RESSAR"
	Else
		cCIJRessar := "''"
	EndIf
	cCIJRessar := "%" + cCIJRessar + "%"

	cFiltro := " SFT.FT_FILIAL   = '" + xFilial("SFT")   + "' AND "
	cFiltro += " SFT.FT_ENTRADA >= '" + dtos(dDataDe )   + "' AND "
	cFiltro += " SFT.FT_ENTRADA <= '" + dtos(dDataAte)   + "' AND "
	cFiltro += " SFT.FT_TIPO    <> 'S'  AND "
	cFiltro += " SFT.FT_DTCANC   = ' '  AND "
	cFiltro += " SFT.D_E_L_E_T_  = ' ' "

	If  ExistBlock("FSA302FMOV")
		cFiltro	:= ExecBlock("FSA302FMOV",.F.,.F.,{cFiltro})
	Endif
	cFiltro := "%" + cFiltro + "%"

	cOrderBy := "SFT.FT_PRODUTO, FT_DATAMOV, FT_ORDEM, FT_CLIEFOR, FT_LOJA, FT_NFISCAL" + Iif(lUsaXml, ", DKA_ITXML", "") + ", FT_ITEM, FT_SERIE"
	cOrderBy := "%" + cOrderBy + "%"

	If lUsaXml
		cSlctXML := ", DKA.DKA_ITXML, DKA.DKA_DESCFO, DKA.DKA_QTDXML, DKA.DKA_UMXML, DKA.DKA_VLRTOT, DKA.DKA_QUANT "
		cJoinXML := " LEFT OUTER JOIN " + RetSqlName("DKC") + " DKC ON (DKC.DKC_FILIAL =" + ValToSql(xFilial("DKC"))
		cJoinXML += " AND DKC.DKC_FORNEC = SFT.FT_CLIEFOR AND DKC.DKC_LOJA = SFT.FT_LOJA AND DKC.DKC_DOC = SFT.FT_NFISCAL"
		cJoinXML += " AND DKC.DKC_SERIE = SFT.FT_SERIE AND DKC.DKC_ITEMNF = SFT.FT_ITEM AND SFT.FT_TIPOMOV = 'E' AND DKC.D_E_L_E_T_  = ' ')"
		cJoinXML += " LEFT OUTER JOIN " + RetSqlName("DKA") + " DKA ON (DKA.DKA_FILIAL = " + ValToSql(xFilial("DKA"))
		cJoinXML += " AND DKA.DKA_FORNEC = DKC.DKC_FORNEC AND DKA.DKA_LOJA = DKC.DKC_LOJA AND DKA.DKA_DOC = DKC.DKC_DOC"
		cJoinXML += " AND DKA.DKA_SERIE = DKC.DKC_SERIE AND DKA.DKA_ITXML = DKC.DKC_ITXML AND DKA.D_E_L_E_T_  = ' ')"

	EndIf

	cSlctXML := "%" + cSlctXML + "%"
	cJoinXML := "%" + cJoinXML + "%"

BeginSql Alias cAlias
	    COLUMN FT_EMISSAO AS DATE
	    COLUMN FT_ENTRADA AS DATE
        COLUMN FT_DATAMOV AS DATE
        COLUMN FT_EMISORI AS DATE

        SELECT SFT.FT_PRODUTO             FT_PRODUTO,
	           SB1.B1_CRICMS              B1_CRICMS,
	           SB1.B1_PICM                B1_PICM,
               SB1.B1_UM                  B1_UM,
	           ISNULL(CIL.CIL_PERIOD,'')  CIL_PERIOD,
	           ISNULL(CIL.CIL_QTDSLD,0)   CIL_QTDSLD,
               ISNULL(CIL.CIL_TIBCST,0)   CIL_TIBCST,
               ISNULL(CIL.CIL_MUBCST,0)   CIL_MUBCST,
	           ISNULL(CIL.CIL_TUST  ,0)   CIL_TUST,
	           ISNULL(CIL.CIL_MUST  ,0)   CIL_MUST, 
               ISNULL(CIL.CIL_TICM,0)     CIL_TICM,
               ISNULL(CIL.CIL_MICM  ,0)   CIL_MICM,
               ISNULL(CIL.CIL_TIFC,0)     CIL_TIFC,
               ISNULL(CIL.CIL_MIFC,0)     CIL_MIFC,
	           CASE SFT.FT_TIPOMOV
                   WHEN 'E' THEN      SFT.FT_ENTRADA
		           ELSE               SFT.FT_EMISSAO
               END                        FT_DATAMOV,
	           SFT.FT_TIPOMOV             FT_TIPOMOV,
	           SFT.FT_TIPO                FT_TIPO,
	           CASE SFT.FT_TIPOMOV
                   WHEN 'E' THEN 
                        CASE SFT.FT_TIPO 
                            WHEN 'D' THEN 
                                CASE 
                                    WHEN SFT.FT_ENTRADA = SF22.F2_EMISSAO THEN '5'
                                    ELSE				                       '2'
                                END
                            ELSE '1' 
                        END 
                    ELSE 
                        CASE SFT.FT_TIPO 
                            WHEN 'D' THEN '3' 
                            ELSE          '4' 
                        END 
               END                        FT_ORDEM,
               SFT.FT_NFISCAL             FT_NFISCAL,
               SFT.FT_SERIE               FT_SERIE,
               SFT.FT_ITEM                FT_ITEM,
               SFT.FT_ESPECIE             FT_ESPECIE,
	           SFT.FT_CHVNFE              FT_CHVNFE,
               SFT.FT_CLIEFOR             FT_CLIEFOR,
               SFT.FT_LOJA                FT_LOJA,
               CASE
                   WHEN ISNULL(SF21.F2_TIPOCLI,'')<>''
                   THEN SF21.F2_TIPOCLI
                   ELSE
                       CASE
                           WHEN ISNULL(SF22.F2_TIPOCLI,'')<>''
                           THEN SF22.F2_TIPOCLI
                           ELSE ISNULL(SA1.A1_TIPO,'')
                       END
               END                        A1_TIPO,
	           SFT.FT_CFOP                FT_CFOP,
               SFT.FT_CLASFIS             FT_CLASFIS,
	           SFT.FT_QUANT               FT_QUANT,
               SFT.FT_PRCUNIT             FT_PRCUNIT,
	           SFT.FT_TOTAL               FT_TOTAL,
	           SFT.FT_FRETE               FT_FRETE,
	           SFT.FT_SEGURO              FT_SEGURO,
	           SFT.FT_DESPESA             FT_DESPESA,
	           SFT.FT_DESCONT             FT_DESCONT,
			   SFT.FT_VALIPI              FT_VALIPI,
               SFT.FT_VALCONT             FT_VALCONT,
               SFT.FT_NRLIVRO             FT_NRLIVRO,
	           SFT.FT_BASEICM             FT_BASEICM,
               SFT.FT_VICEFET             FT_VICEFET,
               CASE 
                   WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                   THEN 0
                   ELSE CASE
                            WHEN SFT.FT_BASEICM = 0 AND SFT.FT_OUTRICM > 0
                            THEN CASE SFT.FT_TIPOMOV
                                     WHEN 'E' THEN SD1.D1_VALICM
                			                  ELSE SD2.D2_VALICM
                		         END
                            ELSE SFT.FT_VALICM
                        END
               END                        FT_VALICM,
               CASE 
                   WHEN  %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                   THEN '2'
                   ELSE CASE WHEN SFT.FT_VALANTI > 0 
                            THEN '3' 
               			 ELSE '1' 
               	    END 
               END                        FT__RESRET,
               CASE 
                   WHEN %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                   THEN SFT.FT_BASNDES
                   ELSE SFT.FT_BASERET
               END                        FT__BCST,
               CASE 
                   WHEN  %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                   THEN SFT.FT_ALQNDES
                   ELSE SFT.FT_ALIQSOL
               END                        FT__ALQST,
               CASE 
                   WHEN  %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                   THEN SFT.FT_ICMNDES
                   ELSE SFT.FT_ICMSRET
               END                        FT__VLRST,
               CASE 
                   WHEN  %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                   THEN SFT.FT_BFCPANT
                   ELSE SFT.FT_BSFCPST
               END                        FT__BASFEC,
               CASE 
                   WHEN  %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                   THEN SFT.FT_AFCPANT
                   ELSE SFT.FT_ALFCPST
               END                        FT__ALQFEC,
               CASE 
                   WHEN  %Exp:cSubStrBD% = '60' AND SFT.FT_ICMSRET = 0 
                   THEN SFT.FT_VFCPANT
                   ELSE SFT.FT_VFECPST
               END                        FT__VALFEC,
               SFT.FT_NFORI               FT_NFORI,
               SFT.FT_SERORI              FT_SERORI,
               SFT.FT_ITEMORI             FT_ITEMORI,
               SFTO.FT_EMISSAO            FT_EMISORI,
               CASE 
                   WHEN SFTO.FT_QUANT > 0
                   THEN (SFTO.FT_VICEFET/SFTO.FT_QUANT) 
                   ELSE 0 
               END                        FT_VICEORI,
	           CIJ.CIJ_FATGER             CIJ_FATGER,
               %Exp:cCIJRessar%           CIJ_RESSAR,
	           ISNULL(SFI.FI_SERPDV,'')   FI_SERPDV,
               SFT.FT_PDV                 FT_PDV,
               SF6.F6_NUMERO              F6_NUMERO,
			   SA1.A1_INSCR				  A1_INSCR,
			   SA1.A1_CONTRIB			  A1_CONTRIB
               %Exp:cSlctXML%
        FROM  %table:SFT% SFT INNER JOIN      %table:SB1% SB1  ON (SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.B1_COD     = SFT.FT_PRODUTO  AND SB1.B1_CRICMS  = '1' AND SB1.%NotDel%)
                              INNER JOIN      %table:CIJ% CIJ  ON (CIJ.CIJ_FILIAL = %xFilial:CIJ% AND CIJ.CIJ_CFOP   = SFT.FT_CFOP     AND CIJ.%NotDel%)
                              INNER JOIN      %table:CIK% CIK  ON (CIK.CIK_FILIAL = %xFilial:CIK% AND CIK.CIK_IDTAB  = CIJ.CIJ_IDTAB   AND CIK.CIK_CSTICM = %Exp:cSubStrBD%         AND CIK.%NotDel%)
                              LEFT OUTER JOIN %table:CIL% CIL  ON (CIL.CIL_FILIAL = %xFilial:CIL% AND CIL.CIL_PERIOD = %Exp:cPerApur%  AND CIL.CIL_PRODUT = SB1.B1_COD              AND CIL.%NotDel%)
                              LEFT OUTER JOIN %table:SA1% SA1  ON (SA1.A1_FILIAL  = %xFilial:SA1% AND SA1.A1_COD     = SFT.FT_CLIEFOR  AND SA1.A1_LOJA    = SFT.FT_LOJA             AND ((SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO NOT IN ('D','B')) OR (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO IN ('D','B')))              AND  SA1.%NotDel%)
				              LEFT OUTER JOIN %table:SF2% SF21 ON (SF21.F2_FILIAL = %xFilial:SF2% AND SF21.F2_DOC    = SFT.FT_NFISCAL  AND SF21.F2_SERIE  = SFT.FT_SERIE            AND SF21.F2_CLIENTE = SFT.FT_CLIEFOR AND SF21.F2_LOJA = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='S' AND SFT.FT_TIPO NOT IN ('D','B')) AND SF21.%NotDel%)
				              LEFT OUTER JOIN %table:SF2% SF22 ON (SF22.F2_FILIAL = %xFilial:SF2% AND SF22.F2_DOC    = SFT.FT_NFORI    AND SF22.F2_SERIE  = SFT.FT_SERORI           AND SF22.F2_CLIENTE = SFT.FT_CLIEFOR AND SF22.F2_LOJA = SFT.FT_LOJA AND (SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO='D')              AND SF22.%NotDel%)
                              LEFT OUTER JOIN %table:SFI% SFI  ON (SFI.FI_FILIAL  = %xFilial:SFI% AND SFI.FI_DTMOVTO = SFT.FT_EMISSAO  AND SFI.FI_PDV     = SFT.FT_PDV              AND SFI.%NotDel%)
                              LEFT OUTER JOIN %table:SD1% SD1  ON (SD1.D1_FILIAL  = %xFilial:SD1% AND SD1.D1_DOC     = SFT.FT_NFISCAL  AND SD1.D1_SERIE   = SFT.FT_SERIE            AND SD1.D1_FORNECE = SFT.FT_CLIEFOR AND SD1.D1_LOJA = SFT.FT_LOJA AND SD1.D1_COD = SFT.FT_PRODUTO AND SD1.D1_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = 'E' AND SD1.%NotDel%)
                              LEFT OUTER JOIN %table:SD2% SD2  ON (SD2.D2_FILIAL  = %xFilial:SD2% AND SD2.D2_DOC     = SFT.FT_NFISCAL  AND SD2.D2_SERIE   = SFT.FT_SERIE            AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.D2_COD = SFT.FT_PRODUTO AND SD2.D2_ITEM = SFT.FT_ITEM AND SFT.FT_TIPOMOV = 'S' AND SD2.%NotDel%) 
                              LEFT OUTER JOIN %table:SFT% SFTO ON (SFTO.FT_FILIAL = %xFilial:SFT% AND SFTO.FT_TIPOMOV = CASE SFT.FT_TIPOMOV WHEN 'E' THEN 'S' ELSE 'E' END          AND SFTO.FT_SERIE  = SFT.FT_SERORI  AND SFTO.FT_NFISCAL = SFT.FT_NFORI   AND SFTO.FT_CLIEFOR = SFT.FT_CLIEFOR AND SFTO.FT_LOJA = SFT.FT_LOJA AND SFTO.FT_ITEM = SFT.FT_ITEMORI AND SFTO.FT_PRODUTO = SFT.FT_PRODUTO AND SFT.FT_TIPO ='D' AND SFTO.FT_DTCANC = '' AND SFTO.%NotDel%) 
							  LEFT OUTER JOIN %table:CDC% CDC  ON (CDC.CDC_FILIAL = %xFilial:CDC% AND CDC.CDC_TPMOV  = 'E'             AND CDC.CDC_DOC    = SFT.FT_NFISCAL          AND CDC.CDC_SERIE  = SFT.FT_SERIE   AND CDC.CDC_CLIFOR  = SFT.FT_CLIEFOR AND CDC.CDC_LOJA    = SFT.FT_LOJA    AND SFT.FT_TIPOMOV = 'E' AND CDC.%NotDel%) 
                              LEFT OUTER JOIN %table:SF6% SF6  ON (SF6.F6_FILIAL  = %xFilial:SF6% AND SF6.F6_EST     = CDC.CDC_UF      AND SF6.F6_NUMERO  = CDC.CDC_GUIA            AND SF6.F6_TIPOIMP = '3'            AND SFT.FT_TIPOMOV  = 'E'            AND SF6.%NotDel%) 
                              %Exp:cJoinXML%
        WHERE 
            %Exp:cFiltro%

        ORDER BY %Exp:cOrderBy%

	EndSql

	// FOI RETIRADO O TRANSACTION POIS ESTAVA DANDO IMPACTO QUANDO SE RODAVA PARA UMA QUANTIDADE GRADE DE REGISTROS.
	// A PROPRIA ROTINA FOI CRIADA JA COM UM CONTROLE DE SEGURANÇA CASO UM APURAÇÃO DE PROBLEMA DURANTE O PROCESSO.
	//Begin Transaction

	//---Grava registro cabeçalho da apuração (Tabela CIG)---//
	GravaCIGH(oApuracao,1)

	AtualizaMsg(oSay,STR0006) //"Processando movimento..."

	DbSelectArea(cAlias)

	cItem := xFilial("SFT") + (cAlias)->(FT_TIPOMOV + FT_SERIE + FT_NFISCAL +FT_CLIEFOR + FT_LOJA + FT_PRODUTO)
	
	cItem += Iif(lUsaXml .And. !Empty((cAlias)->DKA_ITXML), (cAlias)->DKA_ITXML, (cAlias)->FT_ITEM)

	While !(cAlias)->(Eof())

		If cProduto != (cAlias)->FT_PRODUTO

			//---Atualiza o saldo final do produto (Tabela CIL)---//
			If !Empty(cProduto)
				GravaCIL('1',oApuracao,Iif(Empty(cPerSld),.T.,.F.),,oModel)
			EndIf

			//---Método SetaSldIni: Carrega o saldo inicial do produto (Tabela CIL)---//
			oApuracao:SetaSldIni((cAlias)->FT_PRODUTO, (cAlias)->CIL_QTDSLD, (cAlias)->CIL_MICM, (cAlias)->CIL_TICM, (cAlias)->CIL_MUBCST, (cAlias)->CIL_TIBCST, (cAlias)->CIL_MUST, (cAlias)->CIL_TUST, (cAlias)->CIL_MIFC, (cAlias)->CIL_TIFC)

			//---Define a alíquota interna do ICMS para o produto---//
			nAliqInt := Iif((cAlias)->B1_PICM>0, (cAlias)->B1_PICM, nMVICMPAD)

		EndIf

		//---Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução---//
		aDocOriApu := aSize(aDocOriApu,0)
		If (cAlias)->FT_TIPO == 'D'
			aDocOriApu := PesqApur((cAlias)->FT_TIPOMOV, (cAlias)->FT_NFORI, (cAlias)->FT_SERORI, (cAlias)->FT_ITEMORI, (cAlias)->FT_CLIEFOR, (cAlias)->FT_LOJA, (cAlias)->FT_PRODUTO)
		EndIf

		cProduto := (cAlias)->FT_PRODUTO
		cPerSld  := (cAlias)->CIL_PERIOD

		If !oJsonXML:hasProperty(cItem)
			oJsonXML[cItem] := JsonObject():New()
			oJsonXML[cItem]["FT_DATAMOV"] := (cAlias)->FT_DATAMOV
			oJsonXML[cItem]["FT_TIPOMOV"] := (cAlias)->FT_TIPOMOV
			oJsonXML[cItem]["FT_TIPO"]    := (cAlias)->FT_TIPO
			oJsonXML[cItem]["FT_PRODUTO"] := (cAlias)->FT_PRODUTO
			oJsonXML[cItem]["A1_TIPO"]    := (cAlias)->A1_TIPO
			oJsonXML[cItem]["FT_CFOP"]    := (cAlias)->FT_CFOP
			oJsonXML[cItem]["FT_CLASFIS"] := (cAlias)->FT_CLASFIS
			oJsonXML[cItem]["FT__ALQFEC"] := (cAlias)->FT__ALQFEC
			oJsonXML[cItem]["FT_EMISORI"] := (cAlias)->FT_EMISORI
			oJsonXML[cItem]["FT_PRCUNIT"] := (cAlias)->FT_PRCUNIT
			oJsonXML[cItem]["CIJ_FATGER"] := (cAlias)->CIJ_FATGER
			oJsonXML[cItem]["CIJ_RESSAR"] := (cAlias)->CIJ_RESSAR
			oJsonXML[cItem]["FT__RESRET"] := (cAlias)->FT__RESRET
			oJsonXML[cItem]["B1_UM"]      := (cAlias)->B1_UM
			oJsonXML[cItem]["FT_NFISCAL"] := (cAlias)->FT_NFISCAL
			oJsonXML[cItem]["FT_SERIE"]   := (cAlias)->FT_SERIE
			oJsonXML[cItem]["FT_ITEM"]    := (cAlias)->FT_ITEM
			oJsonXML[cItem]["FT_NRLIVRO"] := (cAlias)->FT_NRLIVRO
			oJsonXML[cItem]["FT_CLIEFOR"] := (cAlias)->FT_CLIEFOR
			oJsonXML[cItem]["FT_LOJA"]    := (cAlias)->FT_LOJA
			oJsonXML[cItem]["FT_ESPECIE"] := (cAlias)->FT_ESPECIE
			oJsonXML[cItem]["FI_SERPDV"]  := (cAlias)->FI_SERPDV
			oJsonXML[cItem]["FT_TOTAL"]   := (cAlias)->FT_TOTAL
			oJsonXML[cItem]["FT_QUANT"]   := (cAlias)->FT_QUANT
			oJsonXML[cItem]["FT_FRETE"]   := (cAlias)->FT_FRETE
			oJsonXML[cItem]["FT_SEGURO"]  := (cAlias)->FT_SEGURO
			oJsonXML[cItem]["FT_DESPESA"] := (cAlias)->FT_DESPESA
			oJsonXML[cItem]["FT_DESCONT"] := (cAlias)->FT_DESCONT
			oJsonXML[cItem]["FT_VALIPI"]  := (cAlias)->FT_VALIPI
			oJsonXML[cItem]["FT_VALCONT"] := (cAlias)->FT_VALCONT
			oJsonXML[cItem]["FT_BASEICM"] := (cAlias)->FT_BASEICM
			oJsonXML[cItem]["FT_VALICM"]  := (cAlias)->FT_VALICM
			oJsonXML[cItem]["FT__BCST"]   := (cAlias)->FT__BCST
			oJsonXML[cItem]["FT__VLRST"]  := (cAlias)->FT__VLRST
			oJsonXML[cItem]["FT__BASFEC"] := (cAlias)->FT__BASFEC
			oJsonXML[cItem]["FT__VALFEC"] := (cAlias)->FT__VALFEC
			oJsonXML[cItem]["FT_VICEFET"] := (cAlias)->FT_VICEFET
			oJsonXML[cItem]["FT_VICEORI"] := (cAlias)->FT_VICEORI
			oJsonXML[cItem]["F6_NUMERO"]  := (cAlias)->F6_NUMERO
			If lUsaXml
				oJsonXML[cItem]["DKA_UMXML"]  := (cAlias)->DKA_UMXML
			EndIf
			oJsonXML[cItem]["A1_INSCR"]	  := (cAlias)->A1_INSCR
			oJsonXML[cItem]["A1_CONTRIB"] := (cAlias)->A1_CONTRIB

		Else
			oJsonXML[cItem]["FT_ITEM"]    := (cAlias)->FT_ITEM
			oJsonXML[cItem]["FT_TOTAL"]   += (cAlias)->FT_TOTAL
			oJsonXML[cItem]["FT_QUANT"]   += (cAlias)->FT_QUANT
			oJsonXML[cItem]["FT_FRETE"]   += (cAlias)->FT_FRETE
			oJsonXML[cItem]["FT_SEGURO"]  += (cAlias)->FT_SEGURO
			oJsonXML[cItem]["FT_DESPESA"] += (cAlias)->FT_DESPESA
			oJsonXML[cItem]["FT_DESCONT"] += (cAlias)->FT_DESCONT
			oJsonXML[cItem]["FT_VALIPI"]  += (cAlias)->FT_VALIPI
			oJsonXML[cItem]["FT_VALCONT"] += (cAlias)->FT_VALCONT
			oJsonXML[cItem]["FT_BASEICM"] += (cAlias)->FT_BASEICM
			oJsonXML[cItem]["FT_VALICM"]  += (cAlias)->FT_VALICM
			oJsonXML[cItem]["FT__BCST"]   += (cAlias)->FT__BCST
			oJsonXML[cItem]["FT__VLRST"]  += (cAlias)->FT__VLRST
			oJsonXML[cItem]["FT__BASFEC"] += (cAlias)->FT__BASFEC
			oJsonXML[cItem]["FT__VALFEC"] += (cAlias)->FT__VALFEC
			oJsonXML[cItem]["FT_VICEFET"] += (cAlias)->FT_VICEFET
			oJsonXML[cItem]["FT_VICEORI"] += (cAlias)->FT_VICEORI
		EndIf

		(cAlias)->(dbSkip())		
		cProxIt := xFilial("SFT") + (cAlias)->(FT_TIPOMOV + FT_SERIE + FT_NFISCAL +FT_CLIEFOR + FT_LOJA + FT_PRODUTO)

		cProxIt += Iif(lUsaXml .And. !Empty((cAlias)->DKA_ITXML), (cAlias)->DKA_ITXML, (cAlias)->FT_ITEM)
 
		If cItem <> cProxIt
			//---Método SetaMovim: Carrega os dados do movimento para que seja feita sua apuração---//
			oApuracao:SetaMovim(oJsonXML[cItem]["FT_DATAMOV"],;           //---dDataMov   - Data do Movimento
			oJsonXML[cItem]["FT_TIPOMOV"],;           //---cTipoMov   - Tipo do Movimento (E-Entrada / S-Saída)
			oJsonXML[cItem]["FT_TIPO"],;              //---cTipoDoc   - Tipo do Documento (Normal / Devolução / Complemento)
			oJsonXML[cItem]["FT_PRODUTO"],;           //---cCodProd   - Código do Produto
			oJsonXML[cItem]["A1_TIPO"],;              //---cTipoPart  - Tipo do Participante (Cliente Final / Revendedor)
			nAliqInt,;                       //---nAliqInt   - Alíquota Interna do Produto
			oJsonXML[cItem]["FT_CFOP"],;              //---cCFOP      - CFOP
			Right(oJsonXML[cItem]["FT_CLASFIS"],2),;  //---cCST       - CST ICMS
			oJsonXML[cItem]["CIJ_FATGER"],;           //---cFGerNReal - Indica se a operação (CFOP) deve ser enquadrada como 2-Fato Gerador não realizado
			oJsonXML[cItem]["CIJ_RESSAR"],;           //---cCFOPRess  - Indica se a operação (CFOP) deve ser considerada para cálculo de Ressarcimento
			oJsonXML[cItem]["FT_QUANT"],;             //---nQtdade    - Quantidade
			oJsonXML[cItem]["FT_PRCUNIT"],;           //---nVlrUnit   - Valor Unitário do Item da Nota Fiscal
			oJsonXML[cItem]["FT_TOTAL"],;             //---nVlrTotPrd - Valor Total do Produto
			oJsonXML[cItem]["FT_FRETE"],;             //---nVlrFrete  - Valor do Frete
			oJsonXML[cItem]["FT_SEGURO"],;            //---nVlrSeguro - Valor do Seguro
			oJsonXML[cItem]["FT_DESPESA"],;           //---nVlrDesp   - Valor das Despesas
			oJsonXML[cItem]["FT_DESCONT"],;           //---nVlrDesc   - Valor do Desconto
			oJsonXML[cItem]["FT_VALCONT"],;           //---nVlrTotNf  - Valor Total da Nota Fiscal
			oJsonXML[cItem]["FT_BASEICM"],;           //---nVlrBICMS  - Base de Cálculo do ICMS
			oJsonXML[cItem]["FT_VALICM"],;            //---nVlrICMS   - Valor do ICMS
			oJsonXML[cItem]["FT__BCST"],;             //---nVlrBICMST - Valor da Base de Cálculo do ICMS-ST
			oJsonXML[cItem]["FT__VLRST"],;            //---nVlrICMSST - Valor do ICMS-ST
			oJsonXML[cItem]["FT__BASFEC"],;           //---nVlrBCFec  - Base do FECP ST
			oJsonXML[cItem]["FT__ALQFEC"],;           //---nAliqFec   - Alíquota do FECP ST
			oJsonXML[cItem]["FT__VALFEC"],;           //---nVlrFec    - Alíquota do FECP ST
			oJsonXML[cItem]["FT_VICEFET"],;           //---nVlrICMEfe - Valor do ICMS Efetivo na Saída
			oJsonXML[cItem]["FT__RESRET"],;           //---cRespRet   - Responsável pela retenção do ICMS-ST (1 – Remetente Direto / 2 – Remetente Indireto / 3 – Próprio declarante )---//
			oJsonXML[cItem]["FT_EMISORI"],;           //---dDtMovOri  - Data do Movimento Original, em casos de movimentos de devolução
			oJsonXML[cItem]["FT_VICEORI"],;           //---nVlrEfeOri - Valor do ICMS Efetivo na Saída Original, em casos de movimentos de devolução
			aDocOriApu,;							  //---aDocOriApu - Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução
			oJsonXML[cItem]["A1_INSCR"],;			  //---cInscricao - Incrição estadual do Participante
			oJsonXML[cItem]["A1_CONTRIB"])			  //---cContrib   - Contribuinte do ICMS (1 - Sim / 2 - Não)

			//---Método ApuraMovim: Para Entradas / Devoluções de Entradas.: ---//
			//---                   Para Devoluções de Saídas..............: ---//
			//---                   Carrega os valores apurados no atributo oMovimApur---//
			oApuracao:ApuraMovim()

			//---Grava o movimento apurado (Tabela CII)---//
			GravaCII(oApuracao,oJsonXML[cItem])
			//--Destroi a posicao do json
			oJsonXML:DelName(oJsonXML[cItem])
			cItem := cProxIt
		Else
			Loop
		EndIf
	EndDo
	
	//Elimina todo o objeto Json
	FreeObj(oJsonXML)
	oJsonXML := Nil

	(cAlias)->(DbCloseArea())
	//---FIM Query Principal---//

	AtualizaMsg(oSay,STR0007) //"Atualizando saldos..."

	//---Atualiza o saldo final do produto (Tabela CIL)---//
	GravaCIL('1',oApuracao,Iif(Empty(cPerSld),.T.,.F.),,oModel)

	//---Atualiza o saldo final dos produtos para os quais não houve movimento no período apurado (Tabela CIL)---//
	GravaCIL('2',oApuracao,,cPerApur,oModel)

	AtualizaMsg(oSay,STR0008) //"Gravando apuração..."

	//---Grava totalizadores da apuração (Tabelas CIG e CIH)---//
	GravaCIGH(oApuracao,2)

	//End Transaction

	oModel:Destroy()
	AtualizaMsg(oSay,STR0009) //"Processamento concluído."
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaCIL
  
Função que atualiza, na tabela CIL, o saldo final dos produtos no período analisado, além de transferir esse saldo final para o saldo inicial do próximo período.
É chamada em duas situações (parâmetro cTipo):

1-De dentro do laço da query de movimento (informando o parâmetro oApuracao): Deve, nesse caso, atualizar saldos do produto setado no objeto oApuracao com o resultado da apuração;
2-Após o laço da query de movimento (informando o parâmetro cPerApur).......: Deve, nesse caso, atualizar saldos dos produtos que não tiveram movimento no período atual, e, portanto, não entraram na query de movimento.

@author Rafael.Soliveira
@since 08/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaCIL(cTipo,oApuracao,lInsSldIni,cPerApur,oModel)
	Local aArea     := GetArea()
	Local cAlias    := GetNextAlias()
	Local cProxPer  := ''
	Local aDadosCIL := {}
	Local nCount    := 0
	Local nCount2   := 0
	Local nPos      := 0
	Local nPos2     := 0
	Local lCILOk    := .T.

	If cTipo == '1'
		If Empty(oApuracao:oSaldoProd:GetCodProd())
			Return
		EndIf
		If lInsSldIni
			//---Caso não exista saldo inicial do produto no período analisado, cria registro com saldo inical 0 e atualiza o saldo final (tabela CIL)---//
			Aadd(aDadosCIL,{3,                                                ;
				{{'CIL_PERIOD',oApuracao:GetAnoMes()            },;
				{'CIL_TPREG','3'                               },;
				{'CIL_PRODUT',oApuracao:oSaldoProd:GetCodProd()},;
				{'CIL_QTDFIM',oApuracao:oSaldoProd:GetQtdade() },;
				{'CIL_MFICM',oApuracao:oSaldoProd:GetSldUICM() },;
				{'CIL_TFICM',oApuracao:oSaldoProd:GetSldTICM() },;
				{'CIL_MFST',oApuracao:oSaldoProd:GetSldUIST()  },;
				{'CIL_TFST',oApuracao:oSaldoProd:GetSldTIST()  },;
				{'CIL_MFBCST',oApuracao:oSaldoProd:GetSldUBST()},;
				{'CIL_TFBCST',oApuracao:oSaldoProd:GetSldTBST()},;
				{'CIL_MFFC',oApuracao:oSaldoProd:GetSldUFCP()  },;
				{'CIL_TFFC',oApuracao:oSaldoProd:GetSldTFCP()  },;
				{'CIL_IDAPUR',oApuracao:GetIdApur()            },;
				{'CIL_SPED' ,"1"                               }}})
		Else
			//---Atualiza o saldo final do produto no período analisado (tabela CIL)---//
			Aadd(aDadosCIL,{4,                                                ;
				{{'CIL_PERIOD',oApuracao:GetAnoMes()            },;
				{'CIL_PRODUT',oApuracao:oSaldoProd:GetCodProd()},;
				{'CIL_QTDFIM',oApuracao:oSaldoProd:GetQtdade() },;
				{'CIL_MFICM',oApuracao:oSaldoProd:GetSldUICM() },;
				{'CIL_TFICM',oApuracao:oSaldoProd:GetSldTICM() },;
				{'CIL_MFST',oApuracao:oSaldoProd:GetSldUIST()  },;
				{'CIL_TFST',oApuracao:oSaldoProd:GetSldTIST()  },;
				{'CIL_MFBCST',oApuracao:oSaldoProd:GetSldUBST()},;
				{'CIL_TFBCST',oApuracao:oSaldoProd:GetSldTBST()},;
				{'CIL_MFFC',oApuracao:oSaldoProd:GetSldUFCP()  },;
				{'CIL_TFFC',oApuracao:oSaldoProd:GetSldTFCP()  },;
				{'CIL_IDAPUR',oApuracao:GetIdApur()            },;
				{'CIL_SPED' ,"1"                               }}})
		EndIf

		//---Cria/Atualiza o saldo inicial do produto para o próximo período (tabela CIL)---//
		cProxPer := ProxPer(oApuracao:GetAnoMes())
		CIL->(DbSetOrder(1))
		If !CIL->(DbSeek(xFilial("CIL")+cProxPer+oApuracao:oSaldoProd:GetCodProd()))
			Aadd(aDadosCIL,{3,                                                ;
				{{'CIL_PERIOD',cProxPer                         },;
				{'CIL_TPREG' ,'3'                              },;
				{'CIL_PRODUT',oApuracao:oSaldoProd:GetCodProd()},;
				{'CIL_QTDSLD',oApuracao:oSaldoProd:GetQtdade() },;
				{'CIL_MICM  ',oApuracao:oSaldoProd:GetSldUICM()},;
				{'CIL_TICM  ',oApuracao:oSaldoProd:GetSldTICM()},;
				{'CIL_MUST',oApuracao:oSaldoProd:GetSldUIST()  },;
				{'CIL_TUST',oApuracao:oSaldoProd:GetSldTIST()  },;
				{'CIL_MUBCST',oApuracao:oSaldoProd:GetSldUBST()},;
				{'CIL_TIBCST',oApuracao:oSaldoProd:GetSldTBST()},;
				{'CIL_MIFC',oApuracao:oSaldoProd:GetSldUFCP()  },;
				{'CIL_TIFC',oApuracao:oSaldoProd:GetSldTFCP()  },;
				{'CIL_IDAPUR',oApuracao:GetIdApur()            },;
				{'CIL_SPED' ,"1"                               }}})
		Else
			Aadd(aDadosCIL,{4,                                                ;
				{{'CIL_PERIOD',cProxPer                         },;
				{'CIL_PRODUT',oApuracao:oSaldoProd:GetCodProd()},;
				{'CIL_QTDSLD',oApuracao:oSaldoProd:GetQtdade() },;
				{'CIL_MICM  ',oApuracao:oSaldoProd:GetSldUICM()},;
				{'CIL_TICM  ',oApuracao:oSaldoProd:GetSldTICM()},;
				{'CIL_MUST',oApuracao:oSaldoProd:GetSldUIST()  },;
				{'CIL_TUST',oApuracao:oSaldoProd:GetSldTIST()  },;
				{'CIL_MUBCST',oApuracao:oSaldoProd:GetSldUBST()},;
				{'CIL_TIBCST',oApuracao:oSaldoProd:GetSldTBST()},;
				{'CIL_MIFC',oApuracao:oSaldoProd:GetSldUFCP()  },;
				{'CIL_TIFC',oApuracao:oSaldoProd:GetSldTFCP()  },;
				{'CIL_IDAPUR',oApuracao:GetIdApur()            },;
				{'CIL_SPED' ,"1"                               }}})
		EndIf
	Else
		BeginSql Alias cAlias
            SELECT CIL.CIL_PRODUT, CIL.CIL_QTDSLD, CIL.CIL_MUST, CIL.CIL_TUST , CIL.CIL_MICM , CIL.CIL_TICM, CIL.CIL_MUBCST, CIL.CIL_TIBCST ,CIL_MIFC, CIL.CIL_TIFC, CIL.CIL_MFST,;
             CIL.CIL_TFST, CIL.CIL_MFBCST, CIL.CIL_TFBCST, CIL.CIL_MFFC, CIL.CIL_TFFC

            FROM %Table:CIL% CIL LEFT OUTER JOIN (SELECT CII.CII_FILIAL, CII.CII_PERIOD, CII.CII_PRODUT , MAX(CII.CII_ORDEM) CII_ORDEM
                                                  FROM %Table:CII% CII
                                                  WHERE CII.CII_FILIAL = %xFilial:CII%  AND 
                                                        CII.CII_PERIOD = %Exp:cPerApur% AND
                                                        CII_TPREG      = ' '            AND
                                                        CII.%NotDel%
                                                  GROUP BY CII.CII_FILIAL, CII.CII_PERIOD, CII.CII_PRODUT) CII_ ON (CII_.CII_FILIAL = %xFilial:CII% AND CII_.CII_PERIOD = %Exp:cPerApur% AND CII_.CII_PRODUT = CIL.CIL_PRODUT)
            WHERE CIL.CIL_FILIAL = %xFilial:CIL%  AND 
                  CIL.CIL_PERIOD = %Exp:cPerApur% AND
            	  CIL.%NotDel%                    AND
            	  ISNULL(CII_.CII_ORDEM,'') = ''
		EndSql

		DbSelectArea(cAlias)
		While !(cAlias)->(Eof())

			//---Atualiza o saldo final do produto no período analisado (tabela CIL)---//
			Aadd(aDadosCIL,{4,                                   ;
				{{'CIL_PERIOD',cPerApur             },;
				{'CIL_PRODUT',(cAlias)->CIL_PRODUT },;
				{'CIL_QTDFIM',(cAlias)->CIL_QTDSLD },;
				{'CIL_MFICM ',(cAlias)->CIL_MICM   },;
				{'CIL_TFICM ',(cAlias)->CIL_TICM   },;
				{'CIL_MFST  ',(cAlias)->CIL_MUST   },;
				{'CIL_TFST  ',(cAlias)->CIL_TUST   },;
				{'CIL_MFBCST',(cAlias)->CIL_MUBCST },;
				{'CIL_TFBCST',(cAlias)->CIL_TIBCST },;
				{'CIL_MFFC  ',(cAlias)->CIL_MIFC   },;
				{'CIL_TFFC  ',(cAlias)->CIL_TIFC   },;
				{'CIL_IDAPUR',oApuracao:GetIdApur()},;
				{'CIL_SPED' ,"2"                   }}})

			//---Cria/Atualiza o saldo inicial do produto para o próximo período (tabela CIL)---//
			cProxPer := ProxPer(cPerApur)
			CIL->(DbSetOrder(1))
			If !CIL->(DbSeek(xFilial("CIL")+cProxPer+(cAlias)->CIL_PRODUT))
				Aadd(aDadosCIL,{3,                                   ;
					{{'CIL_PERIOD',cProxPer            },;
					{'CIL_TPREG' ,'3'                 },;
					{'CIL_PRODUT',(cAlias)->CIL_PRODUT},;
					{'CIL_QTDSLD',(cAlias)->CIL_QTDSLD},;
					{'CIL_MICM  ',(cAlias)->CIL_MICM  },;
					{'CIL_TICM  ',(cAlias)->CIL_TICM  },;
					{'CIL_MUST  ',(cAlias)->CIL_MUST  },;
					{'CIL_TUST  ',(cAlias)->CIL_TUST  },;
					{'CIL_MUBCST',(cAlias)->CIL_MUBCST},;
					{'CIL_TIBCST',(cAlias)->CIL_TIBCST},;
					{'CIL_MIFC'  ,(cAlias)->CIL_MIFC  },;
					{'CIL_TIFC'  ,(cAlias)->CIL_TIFC  },;
					{'CIL_IDAPUR',oApuracao:GetIdApur()},;
					{'CIL_SPED' ,"2"                  }}})
			Else
				Aadd(aDadosCIL,{4,                                   ;
					{{'CIL_PERIOD',cProxPer              },;
					{'CIL_PRODUT',(cAlias)->CIL_PRODUT  },;
					{'CIL_QTDSLD',(cAlias)->CIL_QTDSLD  },;
					{'CIL_MICM  ',(cAlias)->CIL_MICM    },;
					{'CIL_TICM  ',(cAlias)->CIL_TICM    },;
					{'CIL_MUST  ',(cAlias)->CIL_MUST    },;
					{'CIL_TUST  ',(cAlias)->CIL_TUST    },;
					{'CIL_MUBCST',(cAlias)->CIL_MUBCST  },;
					{'CIL_TIBCST',(cAlias)->CIL_TIBCST  },;
					{'CIL_MIFC  ',(cAlias)->CIL_MIFC    },;
					{'CIL_TIFC  ',(cAlias)->CIL_TIFC    },;
					{'CIL_IDAPUR',oApuracao:GetIdApur() },;
					{'CIL_SPED' ,"2"                    }}})
			EndIf

			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
	EndIf

	//---Grava a tabela CIL---//
	For nCount := 1 To Len(aDadosCIL)
		lCILOk := .T.
		If aDadosCIL[nCount][1] = 4
			nPos  := Ascan(aDadosCIL[nCount][2],{|a| a[1] == 'CIL_PERIOD'})
			nPos2 := Ascan(aDadosCIL[nCount][2],{|a| a[1] == 'CIL_PRODUT'})

			CIL->(DbSetOrder(1))
			If !CIL->(DbSeek(xFilial("CIL")+aDadosCIL[nCount][2][nPos][2]+aDadosCIL[nCount][2][nPos2][2]))
				lCILOk := .F.
			EndIf
		EndIf

		If lCILOk
			oModel:SetOperation(aDadosCIL[nCount][1])
			oModel:Activate()
			oModel:SetPre({||.T.})  //---Retirada da validação do Model para que a rotina de apuração possa atualizar registros tipo 3-Saldo da Apuração---//
			oModel:SetPost({||.T.}) //---Retirada da validação do Model para que a rotina de apuração possa atualizar registros tipo 3-Saldo da Apuração---//

			For nCount2 := 1 To Len(aDadosCIL[nCount][2])
				oModel:SetValue('FISA302B',aDadosCIL[nCount][2][nCount2][1],aDadosCIL[nCount][2][nCount2][2])
			Next nCount2

			If oModel:VldData()
				oModel:CommitData()
			EndIf

			oModel:DeActivate()
		EndIf
	Next nCount
	//---FIM Grava a tabela CIL---//

	RestArea(aArea)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaCII
  
Função que insere, na tabela CII, os dados do movimento apurado.

@author Rafael.Soliveira
@since 08/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------

Static Function GravaCII(oApuracao,oMov)
	Local aCodEnq    := Iif(!Empty(oApuracao:oMovimApur:GetEnquad()), FISA302Enq(oApuracao:oMovimApur:GetEnquad()), {'',''})
	Local lCIITipo   := CII->(FieldPos("CII_TIPO")) > 0
	Local lCIISped   := CII->(FieldPos("CII_SPED")) > 0

	Local cCOD_DA    := ""
	Local cNUM_DA    := ""

	// Referente ao registro C180 campos 10 e 11
	If !Empty(oMov["F6_NUMERO"])
		cCOD_DA := "1" // 0 – Documento estadual de arrecadação; 1 – GNRE
		cNUM_DA := Alltrim(oMov["F6_NUMERO"])
	EndIf

	RecLock('CII',.T.)
	CII->CII_FILIAL   := xFilial("CII")
	CII->CII_IDAPUR   := oApuracao:GetIdApur()
	CII->CII_PERIOD   := oApuracao:GetAnoMes()

	CII->CII_PRODUT   := oMov["FT_PRODUTO"]
	CII->CII_UNID  	  := Iif(oMov:hasProperty("DKA_UMXML") .And. !Empty(oMov["DKA_UMXML"]), oMov["DKA_UMXML"], oMov["B1_UM"])
	CII->CII_DTMOV    := oMov["FT_DATAMOV"]
	CII->CII_ORDEM    := StrZero(oApuracao:oSaldoProd:GetOrdMov(),9)
	CII->CII_TPMOV 	  := oMov["FT_TIPOMOV"]

	If lCIITipo
		CII->CII_TIPO := oMov["FT_TIPO"]
	EndIf

	CII->CII_NFISCA	  := oMov["FT_NFISCAL"]
	CII->CII_SERIE 	  := oMov["FT_SERIE"]
	CII->CII_ITEM  	  := oMov["FT_ITEM"]
	CII->CII_CFOP  	  := oMov["FT_CFOP"]
	CII->CII_CST   	  := oMov["FT_CLASFIS"]
	CII->CII_LIVRO 	  := oMov["FT_NRLIVRO"]
	CII->CII_PARTIC	  := oMov["FT_CLIEFOR"]
	CII->CII_LOJA  	  := oMov["FT_LOJA"]
	CII->CII_ESPECI	  := oMov["FT_ESPECIE"]
	CII->CII_QTDMOV	  := oMov["FT_QUANT"]
	CII->CII_VUNIT    := oApuracao:oMovimApur:GetVUnit()
	If  CII->( FieldPos( "CII_VUNCON" ) > 0 )
		If oApuracao:GetUF() == "RS"
			CII->CII_VUNCON  :=  oApuracao:oMovimApur:GetVUnit() + ((oApuracao:oMovimApur:GetDespesa()+oMov["FT_VALIPI"]) / oMov["FT_QUANT"])
		Else
			CII->CII_VUNCON  :=  oApuracao:oMovimApur:GetVUnit() + (oApuracao:oMovimApur:GetDespesa() / oMov["FT_QUANT"])
		Endif
	EndIf

	//---Dados Apurados - Entrada---//
	CII->CII_ICMEFE	  := oApuracao:oMovimApur:GetUICMSOp()
	CII->CII_BURET 	  := oApuracao:oMovimApur:GetUBICMST()
	CII->CII_VURET 	  := oApuracao:oMovimApur:GetUICMSST()
	CII->CII_VURFCP	  := oApuracao:oMovimApur:GetUFECP()
	CII->CII_CODRES	  := oMov["FT__RESRET"]
	CII->CII_CODDA 	  := cCOD_DA
	CII->CII_NUMDA 	  := cNUM_DA

	//---Dados Apurados - Saída---//
	CII->CII_ICMEFS	  := oApuracao:oMovimApur:GetICMOpCF()
	CII->CII_VCREDI	  := oApuracao:oMovimApur:GetCrICOP()
	CII->CII_VUCRED	  := oApuracao:oMovimApur:GetICMOpFG()
	CII->CII_VRESSA	  := oApuracao:oMovimApur:GetResIC()
	CII->CII_VUREST	  := oApuracao:oMovimApur:GetUResIC()
	CII->CII_VREFCP	  := oApuracao:oMovimApur:GetResFC()
	CII->CII_VURTFC	  := oApuracao:oMovimApur:GetUResFC()
	CII->CII_VCMPL 	  := oApuracao:oMovimApur:GetComIC()
	CII->CII_VUCST 	  := oApuracao:oMovimApur:GetUComIC()
	CII->CII_VCMFCP	  := oApuracao:oMovimApur:GetComFC()
	CII->CII_VUCFC 	  := oApuracao:oMovimApur:GetUComFC()
	CII->CII_ENQLEG	  := aCodEnq[2]
	CII->CII_REGRA    := aCodEnq[1]

	//---Estoque---//
	CII->CII_QTDSLD   := oApuracao:oMovimApur:GetQtdade()
	CII->CII_MUCRED	  := oApuracao:oMovimApur:GetMICMSOp()
	CII->CII_MUBST 	  := oApuracao:oMovimApur:GetMBCICST()
	CII->CII_MUVSTF	  := oApuracao:oMovimApur:GetMICMSST()
	CII->CII_MUVSF 	  := oApuracao:oMovimApur:GetMFECP()

	CII->CII_TPREG    := ''
	CII->CII_PDV   	  := oMov["FI_SERPDV"]

	If lCIISped
		CII->CII_SPED := oApuracao:oMovimApur:GetGSPED()
	EndIf

	CII->(MsUnlock())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaCIGH
  
Função que grava, nas tabelas CIG e CIH, os totalizadores da apuração.

@author Rafael.Soliveira
@since 16/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaCIGH(oApuracao,cTipoGrv)
	Local nVlrTotRes := 0
	Local nVlrTotCom := 0
	Local nVlrTotCop := 0
	Local nVlrComFcp := 0
	Local nVlrResFcp := 0
	Local nVlrCICOPE := 0
	Local nPos       := 0
	Local nCount     := 0
	Local aCodEnq    := {}

	If cTipoGrv = 1     //--- Parâmetro cTipoGrv = 1 -> Chamada no início do processamento. Insere registro na tabala CIG ---//
		RecLock('CIG',.T.)
		CIG->CIG_FILIAL := xFilial("CIG")
		CIG->CIG_IDAPUR := oApuracao:GetIdApur()
		CIG->CIG_PERIOD := oApuracao:GetAnoMes()
		CIG->(MsUnlock())
	ElseIf cTipoGrv = 2 //--- Parâmetro cTipoGrv = 2 -> Chamada ao fim do processamento. Insere registros na tabala CIH e atualiza totais da tabela CIG ---//

		//---Ajuste do atributo aTotApur para que o Crédito ICMS OP calculado em caso de devoluções interestaduais (Regra 11) seja estornado da Regra 04 (Saídas Interestaduais). Algumas UFs determinam que: Caso o resultado da diferença apurada seja negativo, o campo VL_CREDITO_ICMS_OP_MOT do registro 1255 deverá ser informado com valor 0---//
		nPos := Ascan(oApuracao:aTotApur,{|a|a[1] == '13'})
		If nPos > 0
			nVlrCICOPE := oApuracao:aTotApur[nPos][4]
			oApuracao:aTotApur[nPos][4] := 0
		EndIf

		nPos := Ascan(oApuracao:aTotApur,{|a|a[1] == '04'})
		If nPos > 0
			oApuracao:aTotApur[nPos][4] := Iif(oApuracao:aTotApur[nPos][4] - nVlrCICOPE > 0, oApuracao:aTotApur[nPos][4] - nVlrCICOPE, 0)
		EndIf
		//---FIM Ajuste do atributo aTotApur---//

		For nCount := 1 To Len(oApuracao:aTotApur)
			If oApuracao:aTotApur[nCount][7]
				aCodEnq   := FISA302Enq(oApuracao:aTotApur[nCount][1])

				RecLock('CIH',.T.)
				CIH->CIH_FILIAL := xFilial("CIH")
				CIH->CIH_IDAPUR := oApuracao:GetIdApur()
				CIH->CIH_PERIOD := oApuracao:GetAnoMes()
				CIH->CIH_ENQLEG := aCodEnq[2]    //Converte enquadramento em código da tabela 5.7
				CIH->CIH_REGRA	:= aCodEnq[1]
				CIH->CIH_VRESSA := oApuracao:aTotApur[nCount][2]
				CIH->CIH_VCOMPL := oApuracao:aTotApur[nCount][3]
				CIH->CIH_VCREDI := oApuracao:aTotApur[nCount][4]
				CIH->CIH_REFECP	:= oApuracao:aTotApur[nCount][5]
				CIH->CIH_VCMFCP	:= oApuracao:aTotApur[nCount][6]
				CIH->(MsUnlock())

				nVlrTotRes += oApuracao:aTotApur[nCount][2]
				nVlrTotCom += oApuracao:aTotApur[nCount][3]
				nVlrTotCop += oApuracao:aTotApur[nCount][4]
				nVlrResFcp += oApuracao:aTotApur[nCount][5]
				nVlrComFcp += oApuracao:aTotApur[nCount][6]
			EndIf
		Next nCount

		CIG->(DbSetOrder(2))
		If CIG->(DbSeek(xFilial("CIG")+oApuracao:GetIdApur()))
			RecLock('CIG',.F.)
			CIG->CIG_VRESSA := nVlrTotRes
			CIG->CIG_VCMPL  := nVlrTotCom
			CIG->CIG_VCREDI := nVlrTotCop
			CIG->CIG_REFECP	:= nVlrResFcp
			CIG->CIG_VCMFCP	:= nVlrComFcp
			MsUnLock()
		EndIf
	EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckApur
  
Função que verifica a existência de apuração no período selecionado.

@author Rafael.Soliveira
@since 22/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function CheckApur(cPerApur)
	Local cIdApur := ''

	CIG->(DbSetOrder(1))
	If CIG->(DbSeek(xFilial("CIG")+cPerApur))
		cIdApur := CIG->CIG_IDAPUR
	EndIf

Return cIdApur


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DeletApur
  
Função de exclusão da apuração.

@author Rafael.Soliveira
@since 22/11/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function DeletApur(cIdApur,cPerApur)
	Local cQuery     := ''
	Local cProxPer   := ''
	Local cIdApuProx := ''

	//---Tabela CIG [Apuração]---//
	CIG->(DbSetOrder(2))
	If CIG->(DbSeek(xFilial("CIG")+cIdApur))
		RecLock('CIG',.F.)
		CIG->(DbDelete())
		MsUnLock()
	EndIf

	//---Tabela CIH [Apuração por Enquadramento Legal]---//
	CIH->(DbSetOrder(2))
	CIH->(DbSeek(xFilial("CIH")+cIdApur))
	While !CIH->(Eof()) .And. CIH->CIH_IDAPUR == cIdApur
		RecLock('CIH',.F.)
		CIH->(DbDelete())
		MsUnLock()
		CIH->(DbSkip())
	EndDo

	//---Tabela CIL [Saldos Iniciais]---//
	cQuery := "UPDATE " +  RetSqlName('CIL') + " SET CIL_QTDFIM = 0, CIL_MFICM = 0, CIL_TFICM = 0,CIL_TFST = 0, CIL_MFST = 0,CIL_TFFC = 0, CIL_MFFC = 0,CIL_TFBCST = 0, CIL_MFBCST = 0 WHERE CIL_FILIAL = " + ValToSql(xFilial('CIL')) + " AND CIL_PERIOD = " + ValToSql(cPerApur)
	If !Empty(AllTrim(cQuery))
		TcSqlExec(cQuery)
	EndIf


	cProxPer := cPerApur
	cProxPer := LastDay(CtoD('01/'+Right(cProxPer,2)+'/'+Left(cProxPer,4)))+1
	cProxPer := Left(DToS(cProxPer),6)

	//---Verifica a existência de apuração no próximo período. Caso exista, não exclui registro da CIL---//
	cIdApuProx := CheckApur(cProxPer)
	If Empty(cIdApuProx)
		CIL->(DbSetOrder(1))
		CIL->(DbSeek(xFilial("CIL")+cProxPer))
		While !CIL->(Eof()) .And. CIL->CIL_PERIOD == cProxPer
			RecLock('CIL',.F.)
			CIL->(DbDelete())
			MsUnLock()
			CIL->(DbSkip())
		EndDo
	EndIf

	//---Tabela CII [Apuração Detalhada por Movimento]---//
	cQuery := "DELETE FROM " +  RetSqlName('CII')  + " WHERE CII_FILIAL = " + ValToSql(xFilial('CII')) + " AND CII_IDAPUR = " + ValToSql(cIdApur)
	If !Empty(AllTrim(cQuery))
		TcSqlExec(cQuery)
	EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PesqApur
  
Função que pesquisa, no movimento já apurado (tabela CII), o movimento de saída original, em casos de devoluções.
Retorna um vetor contendo os seguintes valores:

[01]-Data do documento fiscal original
[02]-Quantidade do movimento original
[03]-Valor Unitário do Produto no movimento original
[04]-Valor Médio Unitário do ICMS OP do estoque calculado no movimento original de saída
[05]-Valor Médio Unitário da BC ICMS ST do estoque calculado no movimento original de saída
[06]-Valor Médio Unitário do ICMS ST do estoque calculado no movimento original de saída
[07]-Valor Médio Unitário do FECP ST do estoque calculado no movimento original de saída
[08]-Código do Enquadramento Legal do movimento original
[09]-Valor ICMS OP calculado no movimento original de saída - CF
[10]-Valor ICMS OP entrada calculado no movimento original de saída - Fato Gerador Presumido não realizado
[11]-Valor Unitário do ICMS OP no movimento original de entrada
[12]-Valor Unitário do ICMS ST no movimento original de entrada
[13]-Valor Unitário da BC do ICMS ST no movimento original de entrada
[14]-Valor Unitário do FECP ST no movimento original de entrada
[15]-Flag de geração do registro do movimento original no SPED Fiscal
[xx]-Espécie do movimento original
[xx]-Série do movimento original
[xx]-Número de série ECF do movimento original
[xx]-Número do documento fiscal original
[xx]-Número do item do movimento original

@author Rafael.Soliveira
@since 03/12/2018
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function PesqApur(cTipoMov, cDocOri, cSerOri, cItemOri, cCliOri, cLojaOri, cProdOri)
	Local aArea    := GetArea()
	Local cAlias   := GetNextAlias()
	Local aRetorno := {CtoD('  /  /    '),0,0,0,0,0,0,'',0,0,0,0,0,0,''}
	Local lCIISped := CII->(FieldPos("CII_SPED")) > 0
	Local cCIISped := Iif(lCIISped, '%, CII_SPED%', '%%')

	cTipoMov := Iif(cTipoMov == 'E','S','E')

	//--Localiza saída original apurada na tabela CII, para utilizar os valores informados anteriormente---//
	BeginSql Alias cAlias
        COLUMN CII_DTMOV AS DATE

        SELECT CII_DTMOV, CII_QTDMOV, CII_VUNIT, CII_MUCRED, CII_MUBST, CII_MUVSTF, CII_MUVSF, CII_REGRA, CII_ICMEFS, CII_VUCRED, CII_ICMEFE, CII_VURET, CII_BURET, CII_VURFCP %EXP:cCIISped%
        FROM %TABLE:CII% CII
        WHERE CII_FILIAL = %XFILIAL:CII%  AND
        	  CII_TPMOV  = %EXP:cTipoMov% AND
        	  CII_SERIE  = %EXP:cSerOri%  AND
        	  CII_NFISCA = %EXP:cDocOri%  AND
        	  CII_PARTIC = %EXP:cCliOri%  AND
        	  CII_LOJA   = %EXP:cLojaOri% AND
        	  CII_ITEM   = %EXP:cItemOri% AND
        	  CII_PRODUT = %EXP:cProdOri% AND
              CII_TPREG  = ''             AND 
        	  CII.%NOTDEL%
	EndSql

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	If !(cAlias)->(Eof())
		aRetorno := {(cAlias)->CII_DTMOV, (cAlias)->CII_QTDMOV, (cAlias)->CII_VUNIT, (cAlias)->CII_MUCRED, (cAlias)->CII_MUBST, (cAlias)->CII_MUVSTF, (cAlias)->CII_MUVSF, (cAlias)->CII_REGRA, (cAlias)->CII_ICMEFS, (cAlias)->CII_VUCRED, (cAlias)->CII_ICMEFE, (cAlias)->CII_VURET, (cAlias)->CII_BURET, (cAlias)->CII_VURFCP, Iif(lCIISped, (cAlias)->CII_SPED, '')}
	EndIf
	(cAlias)->(DbCloseArea())

	RestArea(aArea)
Return aRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProxPer
Função que calcula o próximo período

@author Rafael.Soliveira
@since 27/12/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ProxPer(cPerApur)
	Local cProxPer := ''

	cProxPer := LastDay(CtoD('01/'+Right(cPerApur,2)+'/'+Left(cPerApur,4)))+1
	cProxPer := Left(DToS(cProxPer),6)
Return cProxPer


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Função que será chamada para atualizar descrição da barra de status

@author Rafael.Soliveira
@since 22/11/2018
@version 12.1.17
/*/
//--------------------------------------------------------------------------------------------------
Static Function AtualizaMsg(oSay,cMsg)
	If !lAutomato
		oSay:cCaption := (cMsg)
		ProcessMessages()
	EndIf
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA302CEXC
Função de exclusão da apuração selecionada, a partir da rotina FISA193.

@author Rafael.Soliveira
@since 22/11/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA302CEXC()
	If (ApMsgNoYes(STR0011) ) //"Confirma a exclusão da apuração selecionada?"
		DeletApur(CIG->CIG_IDAPUR,CIG->CIG_PERIOD)
	EndIf
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckCIM
  
Função que vertifica, na tabela CIM, as regras de apuração que não possuem relação com código da tabela 5.7.
Movimentos classificados com tais regras não terão cálculo de ressarcimento/complemento.

@author Ulisses.Oliveira
@since 21/01/2021
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function CheckCIM()
	Local cAlias   := GetNextAlias()
	Local aRetorno := {}

	BeginSql Alias cAlias
        SELECT CIM_REGRA
        FROM %TABLE:CIM% CIM
        WHERE CIM_FILIAL = %XFILIAL:CIM% AND CIM_CODIGO = '' AND CIM.%NOTDEL%
	EndSql

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	While !(cAlias)->(Eof())
		Aadd(aRetorno,(cAlias)->CIM_REGRA)
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

Return aRetorno
