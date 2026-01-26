#INCLUDE "PROTHEUS.CH"

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto

Static lChkLxProp:= FindFunction("ChkLxProp")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100RICA ³ Autor ³ Rodrigo M. Pontes     ³ Data ³09/12/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retenção do imposto de ICA			    			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M100RICA                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alterações³ Foi alterado o criterio da busca da aliquota de calculo do ³±±
±±³			 ³ ICA, quando a empresa emitir uma nota de compra e o codigo ³±±
±±³			 ³ A2_CODICA estiver vazio, o sistema usa a base de calculo da³±±
±±³			 ³ SFB, caso esteja preenchido, busca a aliquota na SFF, de   ³±±
±±³			 ³ acordo com o agrupamento do codigo do CIIU.    			  ³±±
±±³			 ³ A base calc.não soma outros gastos como Frete,seguro e desp³±±
±±³			 ³ e despesas.												  ³±±
±±³R.Berti   ³20/10/13³THYBRQ³P/ ICA, deve haver SA2->A2_CODICA ou		  ³±±
±±³		     ³        ³      ³SA1->A1_ATIVIDA preenchido. Obtem aliq. SFF:³±±
±±³		     ³        ³      ³Munic.+CIIU. Aliq.SFB tem como padrao 0%	  ³±±
±±³Veronica F³19/06/18³DMINA-³Se realizo la modificación para que tomara  ³±±
±±³		     ³        ³  6843³la actividad economica de la NF y NDP.      ³±±
±±³Oscar G.  ³16/01/19³DMINA-³Se incluye el valor de los gastosa la base  ³±±
±±³		     ³        ³  7896³de calculo de la retención. COL             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Retenção de ICA                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function M100RICA(cCalculo,nItem,aInfo)
Local aConfTES    := {}
Local aDatosSFF   := Array(5)
Local cCatCliFor  := ""
Local cClaveSFF   := ""
Local cCodICA     := ""
Local cCodMun     := ""
Local cCpoLivro   := ""
Local cImpuesto   := ""
Local cMvAgente   := SuperGetMv( 'MV_AGENTE' , .F., , '' )
Local cMvDescSai  := SuperGetMv( 'MV_DESCSAI' , .F., , '1' )
Local cPessoa     := ""
Local cRetICA     := ""
Local cTes        := ""
Local cTipoCliFor := ""
Local cZonfis     := ""
Local lCodMun     := .F.
Local lRet        := .F.
Local lRetCF      := .T.
Local lXFis       := .F.
Local nAliq       := 0
Local nBase       := 0
Local nImporte    := 0
Local nMoeda      := 1
Local nMoedSFF    := 1
Local nRet        := 0
Local nTaxaMoed   := 0

Static lRatVICol := FindFunction("RatVICol")
Static oJConfImp := JsonObject():New()

Default cCalculo := ""
Default nItem    := 0
Default aInfo    := {}

	lXFis := (MafisFound() .And. ProcName(1)!="EXECBLOCK")

	If lXFis
		cCodMun := MaFisRet(, 'NF_CODMUN' )
		cCodICA := MaFisRet(, 'NF_TPACTIV' )
		cTes    := MaFisRet(nItem, 'IT_TES' )

		If Len(aInfo) >= 2
			cImpuesto := aInfo[01] //Código de impuesto
			cCpoLivro := aInfo[02] //Campo libro
		EndIf
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Deve-se verificar se cEspecie pertence a NCC/NCE/NDC/NDE para que ocor-³
		//³ra busca no SA1, caso contrario deve-se buscar no SA2(Arq.Proveedores) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MaFisRet(,"NF_CLIFOR" ) == "F"
			cCatCliFor := SA2->A2_TIPO
			cTipoCliFor:= SA2->A2_TPESSOA
			cRetICA    := UPPER(SubStr(cMvAgente,2,1))
			If SA2->(ColumnPos("A2_RETICA"))>0
				If !(SA2->A2_RETICA $'S|1')
					cRetICA := 'N'
				EndIf
			EndIf
			If SA2->(ColumnPos("A2_PESSOA")) > 0
				cPessoa := SA2->A2_PESSOA
			EndIf
			cZonfis    := SA2->A2_EST
			IF Empty(cCodICA) // solo con la coma222 no llena cCodICA
				IF (VALTYPE( M->F1_TPACTIV)!="U" .AND. !EMPTY(M->F1_TPACTIV)) .Or. (lChkLxProp .and. ChkLxProp("ActividadICAImp"))
					cCodICA := M->F1_TPACTIV
				ELSE
					cCodICA := SA2->A2_CODICA
				ENDIF
			EndIF
		Else
			cCatCliFor := SA1->A1_TIPO
			cTipoCliFor:= SA1->A1_TPESSOA
			cRetICA    := SA1->A1_RETICA
			cPessoa	   := SA1->A1_PESSOA
			cZonfis    := SM0->M0_ESTENT
			IF (VALTYPE( M->F1_TPACTIV)!="U" .AND. !EMPTY(M->F1_TPACTIV)) 
				cCodICA := M->F1_TPACTIV
			Else
				cCodICA := SA1->A1_ATIVIDA
			EndIf
		Endif

		// Nao calculam ICA: - Gran Contrib. // Desabilitadas as validacoes:  Reg.Simplif.(cTipoCliFor == "2") e Pessoa Fisica (cPessoa == "F")
		If cCatCliFor == "4"
			lRetCF := .F.
		Endif

		If lRetCF
			If Alltrim(cRetICA) == "S" .or. Alltrim(cRetICA) == "1"
				lRet := .T.
			Endif
		Endif

		If lRet

			If !oJConfImp:hasProperty(cImpuesto)
				oJConfImp[cImpuesto] := JsonObject():New()
				oJConfImp[cImpuesto]['FB_ALIQ'] := M100AlqSFB(cImpuesto) //Obtiene alícuota de tabla SFB
			EndIf

			If !oJConfImp:hasProperty(cTES+cImpuesto)
				aConfTES := VldImpxTES(cTES, cImpuesto) //Obtiene información del impuesto configurado en la TES.
				oJConfImp[cTES+cImpuesto] := JsonObject():New()
				oJConfImp[cTES+cImpuesto]['FC_LIQUIDO'] := aConfTES[1]
				oJConfImp[cTES+cImpuesto]['FC_CALCULO'] := aConfTES[2]
			EndIf

			//Verifica na SFF se existe CIIU / Municipio correspondente para:
			// * Calculo de Imposto;
			// * Obtencao de Aliquota;
			// * Faixa de Imposto De/Ate.
			If Empty(cCodIca)
				nAliq   := oJConfImp[cImpuesto]['FB_ALIQ']  // Aliquota padrão
			Else

				cClaveSFF := cImpuesto + cCodMun + cCodICA //Impuesto + Municipio + Tipo de actividad
				If !oJConfImp:hasProperty(cClaveSFF)
					aDatosSFF := M100ICASFF(cImpuesto, cCodMun, cCodICA) //Obtiene datos de configuración de impuestos SFF
					oJConfImp[cClaveSFF]               := JsonObject():New()
					oJConfImp[cClaveSFF]['FF_ALIQ']    := aDatosSFF[1]
					oJConfImp[cClaveSFF]['FF_FLAG']    := aDatosSFF[2]
					oJConfImp[cClaveSFF]['FF_IMPORTE'] := aDatosSFF[3]
					oJConfImp[cClaveSFF]['FF_MOEDA']   := aDatosSFF[4]
					oJConfImp[cClaveSFF]['R_E_C_N_O_'] := aDatosSFF[5]

					If !(oJConfImp[cClaveSFF]['FF_FLAG'] == "1")
						UpdRICASFF(oJConfImp[cClaveSFF]['R_E_C_N_O_']) //Actualiza campo FF_FLAG
					EndIf
				EndIf

				lRet := .F.
				If oJConfImp[cClaveSFF]['R_E_C_N_O_'] > 0
					nAliq    := oJConfImp[cClaveSFF]['FF_ALIQ']
					nImporte := oJConfImp[cClaveSFF]['FF_IMPORTE']
					nMoedSFF := oJConfImp[cClaveSFF]['FF_MOEDA']
					lCodMun  := .T.
					lRet     := .T.
				EndIf

				If !lCodMun
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Metodo antigo de busca , pela zona fiscal (departamento) foi DESATIVADA 						³
					//³caso não tenha aliq. por cod.município, obtera' da SFB, que na Colombia devera' estar ZERADA.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nAliq   := oJConfImp[cImpuesto]['FB_ALIQ']  // Aliquota padrão
					lRet    := .T.
				Endif
			Endif

			If lRet
				Do Case
					Case cCalculo == "A"

						nRet := nAliq

					Case cCalculo=="B"

						nRet := MaFisRet(nItem,"IT_VALMERC") + MaFisRet(nItem,"IT_FRETE") + MaFisRet(nItem,"IT_DESPESA") + MaFisRet(nItem,"IT_SEGURO")

						If cMvDescSai == '1' .And. MaFisRet(, "NF_CLIFOR") == 'C'
							nRet += MaFisRet(nItem,"IT_DESCONTO")
						Endif

						//Tira os descontos se for pelo liquido
						If oJConfImp[cTES+cImpuesto]['FC_LIQUIDO'] == "S"
							nRet -= MaFisRet(nItem,"IT_DESCONTO")
						Endif

					Case cCalculo == "V"

						nRet := 0
						nAliq := MaFisRet(nItem, 'IT_ALIQIV'+cCpoLivro) //Alícuota

						If oJConfImp[cTES+cImpuesto]['FC_CALCULO'] == "T"
							nBase  := MaRetBasT(cCpoLivro, nItem, nAliq)
						Else
							nBase   := MaFisRet(nItem, 'IT_BASEIV'+cCpoLivro)
						EndIf

						If Type("M->F1_MOEDA")<>"U"
							nMoeda := M->F1_MOEDA
							nTaxaMoed := M->F1_TXMOEDA
						ElseIf Type("M->C7_MOEDA")<>"U"
							nMoeda := M->C7_MOEDA
							nTaxaMoed := M->C7_TXMOEDA
						ElseIf Type("nTxMoeda")<>"U" .And. Type("nMoedaCot")<>"U" // Processo de compras(cotação)
							nMoeda := nMoedacot
							nTaxaMoed := nTxMoeda
						ElseIf Type("nTxMoeda")<>"U" .And. Type("nMoedaPed")<>"U" // Processo de compras(Pedido de compras)
							nMoeda := nMoedaPed
							nTaxaMoed := nTxMoeda
						EndIf

						If xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed) >= xMoeda(nImporte,nMoedSFF,1)
							If lRatVICol .And. oJConfImp[cTES+cImpuesto]['FC_CALCULO'] == "I"
								nRet := RatVICol(aInfo, nItem, nAliq, nBase, nMoeda, 1000)
							Else
								nRet := nBase * ( nAliq/1000)
							endIf
						EndIf
				EndCase
			Endif
		Endif
	EndIf

	FwFreeArray(aDatosSFF)
	FwFreeArray(aConfTES)

Return( nRet )

/*/{Protheus.doc} M100ICASFF
Obtiene la configuración por impuesto, municipio y tipo de actividad registrada en SFF.
@type function
@version 12.1.2410
@author luis.samaniego
@since 8/13/2025
@param cImpuesto, character, Código de impuesto.
@param cCodMun, character, Código de municipio.
@param cCodICA, character, Código de tipo de actividad.
@return Array, Valores de los campos: FF_ALIQ, FF_FLAG, FF_IMPORTE, FF_MOEDA y R_E_C_N_O_.
/*/
Static Function M100ICASFF(cImpuesto, cCodMun, cCodICA)
Local cQuery      := ""
Local nOrd        := 1
Local oQryExec := Nil
Local aDatosSFF := {0, "", 0, 0, 0}

Default cImpuesto := ""
Default cCodMun   := ""
Default cCodICA   := ""

	cQuery := " SELECT "
	cQuery += " SFF.FF_ALIQ, SFF.FF_FLAG, SFF.FF_IMPORTE, SFF.FF_MOEDA, SFF.R_E_C_N_O_ "
	cQuery += " FROM " +  RetSqlName("SFF") + " SFF "
	cQuery += " WHERE "
	cQuery += " SFF.FF_FILIAL = ? "
	cQuery += " AND SFF.FF_IMPOSTO = ? "
	cQuery += " AND SFF.FF_CODMUN = ? "
	cQuery += " AND SFF.FF_COD_TAB = ? "
	cQuery += " AND SFF.D_E_L_E_T_ = ? "

	cQuery := ChangeQuery(cQuery)
	oQryExec := FwExecStatement():New(cQuery)

    oQryExec:SetString(nOrd++, xFilial("SFF")) //Filial
    oQryExec:SetString(nOrd++, cImpuesto) //Impuesto
    oQryExec:SetString(nOrd++, cCodMun) //Municipio
    oQryExec:SetString(nOrd++, cCodICA) //Tipo Actividad
    oQryExec:SetString(nOrd++, ' ') //Delete

	aDatosSFF[1] := oQryExec:ExecScalar("FF_ALIQ") //Alícuota
	aDatosSFF[2] := oQryExec:ExecScalar("FF_FLAG") //Flag
	aDatosSFF[3] := oQryExec:ExecScalar("FF_IMPORTE") //Importe
	aDatosSFF[4] := oQryExec:ExecScalar("FF_MOEDA") //Moneda
	aDatosSFF[5] := oQryExec:ExecScalar("R_E_C_N_O_") //Recno

	oQryExec:Destroy()
	FwFreeObj(oQryExec)

Return aClone(aDatosSFF)

/*/{Protheus.doc} VldImpxTES
Obtiene configuración de los impuestos en la TES.
@type function
@version 12.1.2410
@author luis.samaniego
@since 8/13/2025
@param cTES, character, Código de la TES.
@param cImpuesto, character, Código del impuesto.
@return Array, Valores de los campos: FC_LIQUIDO y FC_CALCULO.
/*/
Static Function VldImpxTES(cTES, cImpuesto)
Local aAreaSFC := {}
Local aConfTES := {"",""} //[1]=FC_LIQUIDO; [2]=FC_CALCULO

Default cTES := ""
Default cImpuesto := ""

	aAreaSFC := GetArea()
	dbSelectArea("SFC")
	SFC->(DbSetOrder(2))
	If (SFC->(MsSeek(xFilial("SFC") + cTES + cImpuesto)))
		aConfTES[1] := SFC->FC_LIQUIDO
		aConfTES[2] := SFC->FC_CALCULO
	Endif
	RestArea(aAreaSFC)
	FwFreeArray(aAreaSFC)

Return aClone(aConfTES)

/*/{Protheus.doc} UpdRICASFF
Actualización del registro en la tabla SFF.
@type function
@version 12.1.2410
@author luis.samaniego
@since 8/13/2025
@param nRecnoSFF, numeric, Número de recno del registro en SFF.
/*/
Static Function UpdRICASFF(nRecnoSFF)
Local aAreaSFF := {}

Default nRecnoSFF := 0

	If nRecnoSFF > 0
		aAreaSFF := GetArea()
		dbSelectArea("SFF")
		dbSetOrder(1)
		SFF->(dbGoTo(nRecnoSFF))
		RecLock("SFF",.F.)
			Replace FF_FLAG With "1"
		SFF->(MsUnlock())
		RestArea(aAreaSFF)
	EndIf

	FwFreeArray(aAreaSFF)
	
Return

/*/{Protheus.doc} M100AlqSFB
Consulta la tabla SFB para obtener la alícuota.
@type function
@version 12.1.2410
@author luis.samaniego
@since 8/13/2025
@param cImpuesto, character, Código de impuesto.
@return numeric, Alícuota informada en tabla SFB.
/*/
Static Function M100AlqSFB(cImpuesto)
Local nAliqSFB := 0
Local aAreaSFB := {}

Default cImpuesto := ""

	aAreaSFB := GetArea()
	dbSelectArea("SFB")
	dbSetOrder(1)
	If MsSeek(xFilial("SFB") + cImpuesto)
		nAliqSFB := SFB->FB_ALIQ //Aliquota
	EndIf
	RestArea(aAreaSFB)
	FwFreeArray(aAreaSFB)

Return nAliqSFB
