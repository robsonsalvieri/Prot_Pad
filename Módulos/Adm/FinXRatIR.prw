#INCLUDE "PROTHEUS.CH"

//Dummy Function
Function FinXRatIR()
Return

/*/{Protheus.doc} FinBCRateioIR
	Classe responsavel pelo calculo do rateio de IRRF progressivo
	com base na tabela FKJ
	@type  Class
	@author Vitor/Karen
	@since 01/04/2020
	@version 1.0
	@see https://tdn.totvs.com/x/v8l-I
/*/
Class FinBCRateioIR From LongNameClass

	//Propriedades 
    Data nBaseIr    as Numeric
    Data aRatIRF    as Array
    Data lBaixa     as Logical
    Data cFilOrig   as Character
    Data cFornece   as Character
    Data cLoja      as Character
	Data cTipoFor   as Character
	Data nNumDepFor as Numeric 
    Data nValorAces as Numeric
    Data cIdDoc     as Character
	Data lMinimoIR  as Logical
	Data lPropComp  as Logical
	Data nTitImp	as Numeric
    Data nBasOrig   as Numeric
	Data oQryFK3	as Object
	Data lRatCPF    as Logical 

	// Métodos básicos
    Method New() CONSTRUCTOR
	Method Clean()
	
	// Setters e Getters
	Method SetIRBaixa(lIrBaixa)
    Method SetBaseIR(nBaseIrrf,nBasOrig)
    Method SetFilOrig(cFilOrig)
    Method SetForLoja(cFornecedor,cLoja)
    Method SetValAces(nValAcessorios)
	Method SetIrRetido(nRetIr,nPosicao)
    Method GetIdDoc(cChave)
	Method GetIRRetido(cIdOrig)
	Method SetFilial(cCodFil)
	Method GetCPFs(cFilOrig,cIdOrig)
	Method GetIRCalculado(cCPFs, cIdRet, cIdDoc, cIdFK2)
	
	// Criação
    Method StructFKJ()

	// Processamento
	Method CalcRatIr()

EndClass

/*/{Protheus.doc} New()
	Metodo construtor da classe, responsavel pela inicialização
	das propriedades
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@version 1.0
	@see (links_or_references)
/*/
Method new() Class FinBCRateioIR
	::nBaseIr   	:= 0
    ::aRatIRF   	:= {} 
    ::lBaixa    	:= .F.  
    ::cFilOrig  	:= cFilAnt
    ::cFornece  	:= ""
    ::cLoja     	:= ""
	::cTipoFor		:= ""
    ::nValorAces	:= 0
	::lMinimoIR 	:= .F. 
	::lPropComp		:= .F.
	::nTitImp		:= 0
	::nBasOrig		:= 0
	::lRatCPF       :=.F.
	::nNumDepFor	:= 0
Return NIL

/*/{Protheus.doc} SetFilial()
	Define uma filial após o metodo constructor
	@type  Method
	@author Jailton Urbano
	@since 06/12/2022
	@param cCodFil filial a ser preparada
	@version 1.0
	@see (links_or_references)
/*/
Method SetFilial(cCodFil AS CHARACTER) Class FinBCRateioIR
	DEFAULT cCodFil := cFilAnt
	::cFilOrig  	:= cCodFil
Return NIL

/*/{Protheus.doc} SetBaseIR()
	Recebe a base de IRRF que sera tratada no rateio
	considerando as deduções legais
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param nBaseIr , Numeric, Base do IR c/ as deduções legais
	@param nBasOrig, Numeric, Base do IR s/ as deduções legais
	@version 2.0
	@see (links_or_references)
/*/
Method SetBaseIR(nBaseIrrf As Numeric, nBasOrig As Numeric) Class FinBCRateioIR
	Local nValDeps 	:= SuperGetMv("MV_TMSVDEP",.T.,0)  as Numeric

	DEFAULT nBaseIrrf := 0
	DEFAULT nBasOrig  := 0
    ::nBaseIr   := nBaseIrrf + (nValDeps * ::nNumDepFor) // Volta o valor dos dependentes na base que foi descontada do fonte de origem. A dedução do dependente será realizada na CalcRatIr
    ::nBasOrig  := nBasOrig
Return NIL

/*/{Protheus.doc} SetFilOrig()
	Recebe a filial de origem (FILORIG)
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param cFilOrig, Character, Filial de origem - _FILORIG 
	@version 1.0
	@see (links_or_references)
/*/
Method SetFilOrig(cFilOrig) Class FinBCRateioIR
    ::cFilOrig  := PadR(cFilOrig,FWSizeFilial())
Return NIL

/*/{Protheus.doc} SetIrRetido()
	Recebe o valor de IR PF ja retido
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param cFilOrig, Character, Filial de origem - _FILORIG 
	@version 1.0
	@see (links_or_references)
/*/
Method SetIrRetido(nRetIr, nPosicao) Class FinBCRateioIR
    ::aRatIRF[nPosicao][7] += nRetIr
Return NIL

/*/{Protheus.doc} SetForLoja()
	Recebe o codigo do fornecedor e a loja que serão utilizados
	na construção do rateio
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param cFornecedor, Character, Codigo do fornecedor (A2_COD)
	@param cLoja, Character, Loja do fornecedor (A2_LOJA)
	@version 1.0
	@see (links_or_references)
/*/
Method SetForLoja(cFornecedor, cLoja) Class FinBCRateioIR
    ::cFornece  := cFornecedor
    ::cLoja     := cLoja

	//Com o fornecedor e loja preenchido sera montado a estrutura do rateio
	If !Empty(::cFornece) .and. !Empty(::cLoja)
		Self:StructFKJ()
	EndIf	
Return NIL

/*/{Protheus.doc} SetValAces()
	Recebe os valores acessorios do titulo
	(Juros,Multa,Desconto,Acrescimo,Decrescimo,Valores acessorios (VA))
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param nValAcessorios, Numeric
	@version 1.0
	@see (links_or_references)
/*/
Method SetValAces(nValAcessorios) Class FinBCRateioIR
    ::nValorAces:= nValAcessorios
Return NIL

/*/{Protheus.doc} SetIRBaixa()
	Define se o caculo do IR é na baixa
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param lIrBaixa, Logico, Define se o calculo ira acontecer pela baixa
	@version 1.0
	@see (links_or_references)
/*/
Method SetIRBaixa(lIRBaixa) Class FinBCRateioIR
    ::lBaixa := lIRBaixa
Return NIL

/*/{Protheus.doc} GetIdDoc()
	Retorna o FK7_IDDOC do titulo 
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@param cChave, Caractere, Chave do titulo no formato FK7_CHAVE
	@version 1.0
	@see (links_or_references)
/*/
Method GetIdDoc(cChave) Class FinBCRateioIR
    ::cIdDoc    := FINGRVFK7('SE2', cChave)
Return self:cIdDoc

/*/{Protheus.doc} GetIRRetido()
	Função para verificar o Ir progressivo retido por CPF
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@version 1.0
	@example
	@see (links_or_references)
/*/
Method GetIRRetido(cIdOrig,cTable) Class FinBCRateioIR
	Local nPos 		As Numeric
	Local aArea		As Array
	Local aAreaFK3	As Array
	Local aAreaFK4	As Array 
	Local cAglImPJ  As Character

	Default cTable	:= Iif(::lBaixa, "FK2", "SE2")

	nPos 		:= 0
	aArea		:= GetArea()
	aAreaFK3	:= FK3->(GetArea())
	aAreaFK4	:= FK4->(GetArea())
	cAglImPJ	:= SuperGetMv("MV_AGLIMPJ",.T.,"1")
	

	FK4->(DbSetOrder(1))
	FK3->(DbSetOrder(2))

	If FK3->(DbSeek(xFiliaL("FK3",::cFilOrig)+cTable+cIdOrig+"IRF"))
		While FK3->(!EOF()) .and. FK3->FK3_IDORIG == cIDOrig
			If FK4->(DbSeek(xFilial("FK4",::cFilOrig)+FK3->FK3_IDRET))
				nPos := Ascan(::aRatIRF,{ |x| AllTrim(x[3]) == AllTrim(FK4->FK4_CGC) } )
				If nPos > 0
					Self:SetIrRetido(FK4->FK4_VALOR,nPos)  
					If cAglImPJ != '1' 
						::aRatIRF[nPos][9] := Iif(FK4->FK4_BASIMP > ::aRatIRF[nPos][9], FK4->FK4_BASIMP, ::aRatIRF[nPos][9])
					Endif						
				EndIf	
			Endif
			FK3->(DbSkip())
		EndDo		
	Endif

	RestArea(aAreaFK3)
	RestArea(aAreaFK4)
	RestArea(aArea)
Return NIL

/*/{Protheus.doc} StructFKJ()
	Monta estrutura de Rateio IR Progressivo p/ CPF
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@version 1.0
	@example
		Estrutura do aRatIrf
		[1]  = Codigo do Fornecedor
		[2]  = Loja do Fornecedor
		[3]  = CPF do Fornecedor
		[4]  = Percentual de Rateio
		[5]  = Base do Imposto
		[6]  = Imposto Calculado
		[7]  = Imposto retido no periodo
		[8]  = Nome do Fornecedor
		[9]  = Base do imposto quando o MV_AGLIMPJ != 1 
		[10] = Base do Imposto por dedução simplificada
		[11] = Indica se retenção de IRPF ocorreu pelo calculo simplificado
		[12] = ?
		[13] = Número de dependentes por CPF

	@see (links_or_references)
/*/
Method StructFKJ() Class FinBCRateioIR			
	Local aArea			As Array
	Local aAreaSA2		As Array
	Local aAreaFKJ		As Array
	Local cFilFKJ		As Character
	Local lNumDep		As Logical
	Local nNumDep		As Numeric

	::aRatIRF	:= Array(0)

	//Inicialização das variaveis
	aArea		:= GetArea()
	aAreaSA2	:= SA2->( GetArea() )
	aAreaFKJ	:= {}
	cFilFKJ		:= ""
	lNumDep		:= FKJ->(ColumnPos("FKJ_NUMDEP")) > 0 // Release 12.1.2510
	nNumDep		:= 0
	
	// Busca Fornecedor do Título
	SA2->( DbSetOrder(1) )
	
	If !Empty(::cFornece+::cLoja) .And. SA2->( DbSeek(xFilial("SA2",::cFilOrig) + ::cFornece + ::cLoja) ) 
		::cTipoFor := SA2->A2_TIPO
		::nNumDepFor := SA2->A2_NUMDEP
		
		If SA2->A2_MINIRF == "2"
			::lMinimoIR := .T.
		Endif
		
		// Verifica se o fornecedor trata o rateio IR Progressivo p/ CPF
		If SA2->A2_TIPO == 'F' .OR. ( SA2->A2_TIPO == 'J' .AND. SA2->A2_IRPROG == '1' .And. !Empty(SA2->A2_CPFIRP) )
			aAreaFKJ := FKJ->( GetArea() )
			cFilFKJ := xFilial("FKJ", ::cFilOrig)
			
			// Procura Rateios p/ CPF - TABELA FKJ
			FKJ->( DbSetOrder(1) ) // FKJ_FILIAL, FKJ_COD, FKJ_LOJA, FKJ_CPF
			If FKJ->( DbSeek( cFilFKJ + ::cFornece + ::cLoja ) )
				While FKJ->(!Eof()) .And. FKJ->(FKJ_FILIAL+FKJ_COD+FKJ_LOJA) ==  cFilFKJ + ::cFornece + ::cLoja
					nNumDep := SA2->A2_NUMDEP
					If lNumDep
						nNumDep := FKJ->FKJ_NUMDEP
						If FKJ->FKJ_PERCEN == 100 .And. FKJ->FKJ_NUMDEP == 0 .And. SA2->A2_NUMDEP > 0 // Para continuar funcionando clientes com base com A2_NUMDEP preenchido e com rateio 100% e novo campo FKJ_NUMDEP cria zerado.
							nNumDep := SA2->A2_NUMDEP
						EndIf
					EndIf
					AAdd(::aRatIRF, {FKJ->FKJ_COD, FKJ->FKJ_LOJA, FKJ->FKJ_CPF, FKJ->FKJ_PERCEN, 0, 0, 0, FKJ->FKJ_NOME, 0, 0, .F., 0,nNumDep})
					FKJ->( DbSkip() )
				EndDo 
				
				::lRatCPF := .T.
			Else
				AAdd(::aRatIRF, {SA2->A2_COD, SA2->A2_LOJA, IIF(SA2->A2_TIPO == "F", SA2->A2_CGC, SA2->A2_CPFIRP), 100, 0, 0, 0, SA2->A2_NOME, 0, 0, .F., 0,SA2->A2_NUMDEP})
			EndIf
			
			RestArea(aAreaFKJ)
			FwFreeArray(aAreaFKJ)
		EndIf

	EndIf

	Restarea(aAreaSA2)
	RestArea(aArea)
	FwFreeArray(aAreaSA2)
	FwFreeArray(aArea)
Return NIL 

/*/{Protheus.doc} CalcRatIr()
	Metodo responsvel pelo calculo do rateio, que sera
	armazenado na variavel aRatIRF
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@version 1.0
	@example
	@see (links_or_references)
/*/
Method CalcRatIr(nBaseTit) Class FinBCRateioIR
	Local nX 			As Numeric
	Local lJurMulDes	As Logical
	Local nValor 		As Numeric
	Local cAcmIrrf 		As Character
	Local lIrfRetAnt 	As Logical
	Local nVlRetir		As Numeric
	Local lIrTabSimp    As Logical
	Local lBorder 	    As Logical
	Local nPosBase 		As Numeric
	Local nValDeps		As Numeric
	
	Default nBaseTit	:= 0

	nX 			:= 0 
	lJurMulDes 	:= SuperGetMv("MV_IMPBAIX",.t.,"2") == "1"
	nValor 		:= 0
	cAcmIrrf 	:= SuperGetMv("MV_ACMIRRF",.T.,"1")
	lIrfRetAnt 	:= .F.
	nVlRetIR 	:= SuperGetMv("MV_VLRETIR",.T.,0)
	::nTitImp   := 0 
	lIrTabSimp  := Iif(FindFunction("FVerMP1171"),FVerMP1171(SA2->A2_COD, SA2->A2_LOJA), SuperGetMV("MV_FMP1171",.F.,.F.)) //Habilita calculo do IRPF pela tabela simplificada
	lBorder		:= FwIsInCallStack("FA241Borde") .Or. FwIsInCallStack("Fa590Inclu")
	nPosBase	:= 5
	nValDeps 	:= SuperGetMv("MV_TMSVDEP",.T.,0)
	
	// Rateio p/ CPF
		For nX := 1 To Len(::aRatIRF)
			
			/*	[1]  = Codigo do Fornecedor
				[2]  = Loja do Fornecedor
				[3]  = CPF do Fornecedor
				[4]  = Percentual de Rateio
				[5]  = Base do Imposto por dedução legal
				[6]  = Imposto Calculado por dedução legal
				[7]  = Imposto retido no periodo
				[8]  = Nome do CPF ou Fornecedor
				[9]  = Base do imposto quando o MV_AGLIMPJ != 1
				[10] = Base do Imposto por dedução simplificada
				[11] = Indica se retenção de IRPF ocorreu pelo calculo simplificado
				[12] = Base do Imposto acumulada de impostos
				[13] = Número de dependentes por CPF

			// Aplica rateio do IRRF */
			If ::aRatIRF[nX][9] > 0 .AND. nBaseTit > 0
				::nBaseIr := nBaseTit + ::aRatIRF[nX][9]
			Endif
			
			If lBorder
				::aRatIRF[nX][5]  := nBaseTit * (::aRatIRF[nX][4]/100)
				nPosBase := 12
			EndIf
			
			If ::lBaixa .and. lJurMulDes
				::aRatIRF[nX][nPosBase]  := (::nBaseIr+::nValorAces)*( ::aRatIRF[nX][4]/100 )
				
				If lIrTabSimp .And. ::nBasOrig > 0
					::aRatIRF[nX][10] := (::nBasOrig+::nValorAces)*( ::aRatIRF[nX][4]/100 )
				Endif
			Else
				::aRatIRF[nX][nPosBase]  := ::nBaseIr * ( ::aRatIRF[nX][4]/100 )
				
				If lIrTabSimp .And. ::nBasOrig > 0
					::aRatIRF[nX][10] := ::nBasOrig * ( ::aRatIRF[nX][4]/100 )
				Endif
			Endif

			//Abato da base o valor dos dependentes por CPF
			If Len(::aRatIRF[nX]) >= 13
				::aRatIRF[nX][nPosBase]  := ::aRatIRF[nX][nPosBase] - (nValDeps * ::aRatIRF[nX][13])
			Endif

			//Calculo do IRPF considerando deduçao legal
			::aRatIRF[nX][6] := fa050TabIR(::aRatIRF[nX][nPosBase], .F.)
			
			//Calculo do IRPF considerando dedução simplificada (MP 1.171/23)
			If lIrTabSimp .And. ::nBasOrig > 0
				nVrIrDedS := fa050TabIR(::aRatIRF[nX][10], .F., lIrTabSimp)
				If ::aRatIRF[nX][6] > nVrIrDedS 
					::aRatIRF[nX][6] := nVrIrDedS //Considera o IRRF c/ dedução simplificada por ser mais vantajoso
					::aRatIRF[nX][11] := .T.
				EndIf
			Endif

			::aRatIRF[nX][7] := If( Empty(::aRatIRF[nX][7]), 0, ::aRatIRF[nX][7])

			nValor	+= Round(NoRound(::aRatIRF[nX][6],3),2)

			//Diminuo do valor calculado, o IRRF já retido
			If cAcmIrrf <> "2" .OR. ::cTipoFor == 'F' //Não acumular os valores do IRRF  -> PF sempre acumular
				::aRatIRF[nX][6] -= Iif(::lBaixa .and. ::lPropComp,0,::aRatIRF[nX][7])
				nValor -= Iif(::lBaixa .and. ::lPropComp,0,::aRatIRF[nX][7])
			Endif

			//Controle de retencao anterior no mesmo periodo
			lIrfRetAnt := IIF(::aRatIRF[nX][7] > nVlRetir, .T., .F.)

			// Verifica se o fornecedor trata o valor minimo de retencao.- FINANCEIRO
			If (::lMinimoIR .And. (::aRatIRF[nX][6] <= nVlRetir .and. !lIrfRetAnt)) .OR. ::aRatIRF[nX][6] < 0
				nValor -= ::aRatIRF[nX][6]
				::aRatIRF[nX][6] := 0
			Endif

			::nTitImp += ::aRatIRF[nX][6]
		Next nX

Return nValor

/*/{Protheus.doc} Clean()
	Metodo responsavel pela limpeza das propriedades 
	@type  Method
	@author Vitor/Karen
	@since 01/04/2020
	@version 1.0
	@example
	@see (links_or_references)
/*/
Method Clean() Class FinBCRateioIR
	::nBaseIr   	:= 0 
    ::lBaixa    	:= .F.  
    ::cFilOrig  	:= cFilAnt
    ::cFornece  	:= ""
    ::cLoja     	:= ""
	::cTipoFor		:= ""
    ::nValorAces	:= 0
	::lMinimoIR 	:= .F.
	::lPropComp		:= .F.
	::nTitImp		:= 0
	::nBasOrig		:= 0

	FwFreeArray(::aRatIRF)
	::aRatIRF		:= {}
Return NIL

/*/{Protheus.doc} GetCPFs()
	Retorna os CPFs que fizeram parte da
	retenção do IR do título indicado.

	@type  Method
	@author fabio.casagrande
	@since 07/03/2024
	@param cFilOrig, Char, Filial de origem do título
	@param cIdOrig, Char, ID da tabela de referencia
	@param cTable, Char, Tabela de referencia para pesquisar o ID
	@version 1.0
	@example
	@see (links_or_references)
/*/
Method GetCPFs(cFilOrig,cIdOrig,cTable) Class FinBCRateioIR
	Local aArea		As Array
	Local aAreaFK3	As Array
	Local aAreaFK4	As Array 
	Local aCPFs     As Array

	Default cFilOrig := cFilAnt
	Default cIdOrig	 := ""
	Default cTable	 := Iif(::lBaixa, "FK2", "SE2")

	aArea		:= GetArea()
	aAreaFK3	:= FK3->(GetArea())
	aAreaFK4	:= FK4->(GetArea())
	aCPFs		:= {}
	
	FK4->(DbSetOrder(1))
	FK3->(DbSetOrder(2))

	If FK3->(DbSeek(xFiliaL("FK3",cFilOrig)+cTable+cIdOrig+"IRF"))
		While FK3->(!EOF()) .and. FK3->FK3_IDORIG == cIDOrig
			If FK4->(DbSeek(xFilial("FK4",cFilOrig)+FK3->FK3_IDRET))
				aAdd(aCPFs, AllTrim(FK4->FK4_CGC))
			Endif
			FK3->(DbSkip())
		EndDo		
	Endif

	RestArea(aAreaFK3)
	RestArea(aAreaFK4)
	RestArea(aArea)

	FwFreeArray(aAreaFK3)
	FwFreeArray(aAreaFK4)
	FwFreeArray(aArea)

Return aCPFs

/*/{Protheus.doc} GetIRCalculado()
	Função para verificar o Ir progressivo calculado por CPF sem retenção
	@type  Method
	@author Pâmela Bernardo
	@since 21/03/2024
	@version 1.0
	@example
	@see (links_or_references)
/*/
Method GetIRCalculado(cCPFs, cIdRet, cIdDoc, cIdFK2) Class FinBCRateioIR
	Local nRet		As Numeric
	Local nCont		As Numeric
	Local cQuery	As Character
	Local cAliasFK3	As Character
	Local aAreaFK3 	As Array

	Default cCPFs  := ""
	Default cIdRet := ""
	Default cIdDoc := ""

	nRet 		:= 0
	nCont		:= 1
	cQuery 		:= ""
	cAliasFK3 	:= ""
	aAreaFK3	:= FK3->(GetArea())

	DbSelectArea("FK3")

	If Self:oQryFK3 == Nil
		cQuery := "Select FK3.R_E_C_N_O_ RECNOFK3, FK3.FK3_BASIMP "
		cQuery += " FROM ? FK3 "
		cQuery += " WHERE  FK3.FK3_FILIAL = ? " 
		cQuery += " AND FK3.FK3_IDRET = ' ' " 
		cQuery += " AND FK3.FK3_STATUS = '1' " 
		cQuery += " AND FK3.FK3_CGC = ?  " 
		cQuery += " AND FK3_DATA BETWEEN ? AND ? "
		cQuery += " AND ( FK3.FK3_TABORI = 'FK7' " 
		cQuery += " OR EXISTS (SELECT FK2.FK2_IDFK2 " 
		cQuery += " FROM ? FK2 "
		cQuery += " WHERE FK2.FK2_FILIAL = ? AND FK2.FK2_IDDOC = ? " 
		cQuery += " AND NOT EXISTS (SELECT FK2EST.FK2_IDDOC " 
		cQuery += " FROM ? FK2EST "
		cQuery += " WHERE FK2EST.FK2_FILIAL = FK2.FK2_FILIAL AND FK2EST.FK2_IDDOC = ?  " 
		cQuery += " AND FK2EST.FK2_SEQ = FK2.FK2_SEQ " 
		cQuery += " AND FK2EST.FK2_TPDOC = 'ES' " 
		cQuery += " AND FK2EST.D_E_L_E_T_ = ' ') " 
		cQuery += " AND FK2.D_E_L_E_T_ = ' ')) " 
		cQuery += " AND FK3.D_E_L_E_T_ = ' ' " 

		cQuery := ChangeQuery( cQuery )
		Self:oQryFK3 := FwExecStatement():New(cQuery)
	EndIf

	Self:oQryFK3:SetUnsafe(nCont++, RetSqlName("FK3")) //Nome da tabela FK3
	Self:oQryFK3:SetString(nCont++, xFilial("FK3")) //FK3.FK3_FILIAL
	Self:oQryFK3:SetString(nCont++, cCPFs) //FK3.FK3_CGC
	Self:oQryFK3:SetString(nCont++, Dtos( FirstDay(DDatabase))) //FK3.FK3_DATA
	Self:oQryFK3:SetString(nCont++, Dtos( LastDay(DDatabase))) //FK3.FK3_DATA
	Self:oQryFK3:SetUnsafe(nCont++, RetSqlName("FK2")) //Nome da tabela FK2
	Self:oQryFK3:SetString(nCont++, xFilial("FK2")) //FK2.FK2_FILIAL
	Self:oQryFK3:SetString(nCont++, cIdDoc) //FK2.FK2_IDDOC
	Self:oQryFK3:SetUnsafe(nCont++, RetSqlName("FK2")) //Nome da tabela FK2EST
	Self:oQryFK3:SetString(nCont++, cIdDoc) //FK2EST.FK2_IDDOC 

	cAliasFK3 := Self:oQryFK3:OpenAlias()
	
	(cAliasFK3)->(Dbgotop())
	
	While (cAliasFK3)->(!EOF())
		nRet += (cAliasFK3)->FK3_BASIMP
		FK3->(DbGoto((cAliasFK3)->RECNOFK3))
		Reclock("FK3", .F.)
			FK3->FK3_IDRET := cIdRet
		FK3->(MsUnLock())
		(cAliasFK3)->(DbSkip())
	EndDo		
	If Select(cAliasFK3) > 0
		(cAliasFK3)->(dbCloseArea())
	Endif

	RestArea(aAreaFK3)
	
Return nRet
