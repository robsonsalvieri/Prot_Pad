#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "GTPJ002.CH"

/*/{Protheus.doc} GTPJTEF
	Job para chamar a função de geração de titulos de vendas por cartão TEF 
	@type  Function
	@author SIGAGTP
	@version 1
	@param aParam - Array com 4 posições com os parametros informados no job = {'dtIni', 'dtFim', 'agenciaIni', 'agenciaFim'}
/*/
Function GTPJTEF(aParam)
Local lJob     := Iif(Select("SX6")==0,.T.,.F.)  //Rotina automatica (schedule)
Local cEmpJob  := ""
Local cFilJob  := ""
Local cFilOk   := ""
Local cDataIni := ""
Local cDataFim := ""
Local cAgeIni  := ""
Local cAgeFim  := ""

cEmpJob := aParam[Len(aParam)-3]
cFilJob := aParam[Len(aParam)-2]

If lJob
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob MODULO "FAT"
EndIf   

cFilOk := cfilant

If !Empty(StoD(aParam[1])) .And. !Empty(StoD(aParam[2]))
	cDataIni := aParam[1]
	cDataFim := aParam[2]
	cAgeIni  := aParam[3]
	cAgeFim  := aParam[4]

Endif
//Gera titulo de vendas por cartão TEF
GTPP002(ljob, cDataIni, cDataFim, cAgeIni, cAgeFim)

cFilAnt	:= cFilOk

Return()

/*/{Protheus.doc} GTPP002
	Gera titulo de vendas por cartão TEF, se a geração for concluida com sucesso altera o campo GZP_STAPRO com 1 - Gerado Titulo 
	e o campo GZP_TITTEF com o numero do titulo gerado (FILIAL+PREFIXO+NUM+PARCELA+TIPO)
	@type  Function
	@author SIGAGTP
	@version 1
	@param lJob - Boolean - Define se está sendo executada via job (schedule)
	       cDataIni - String - Data incio, informada por parametro
		   cDataFim - String - Data Fim, informada por parametro
		   cAgeIni  - String - Agencia inicio, informada por parametro, informação da tabela GI6
		   cAgeFim  - String - Agencia fim, informada por parametro, informação da tabela GI6
/*/
Function GTPP002(ljob, cDataIni, cDataFim, cAgeIni, cAgeFim)
Local cAliasJob        := GetNextAlias()
Local aTit             := {}
Local aRet             := {}
Local cRet             := ''
Local cCliSBan         := '999' // cliente sem bandeira
Local cDescAdm         := ''
Local cTipo            := ""
Local cHistTit         := ""
Local nParc            := 0 
Local cFpagto          := ""
Local cNatureza        := ""
Local CARTAO_CREDITO   := GTPGetRules('TPCARDCRED', .F., Nil, "CC")
Local CARTAO_DEBITO    := GTPGetRules('TPCARDDEBI', .F., Nil, "CD")
Local CARTAO_PARCELADO := GTPGetRules('TPCARDPARC', .F., Nil, "CP")
Local PIX_TEF 		   := GTPGetRules('TPCARDPIX' , .F., Nil, "PX")
Local cQuery           := ''
Local cFilCart 		   := GTPGetRules('FILTITCART')
Local cAdmFin 		   := '999'
Local uDiasVenc		   := Nil
Default ljob	 := .F.
Default cDataIni := ''
Default cDataFim := ''
Default cAgeIni  := ''
Default cAgeFim  := '' 

If !Empty(cDataIni) .And. !Empty(cDataFim)
	cQuery += " AND GIC.GIC_DTVEND BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
Endif

If !Empty(cAgeIni) .And. !Empty(cAgeFim)
	cQuery += " AND GIC.GIC_AGENCI BETWEEN '" + cAgeIni + "' AND '" + cAgeFim + "' "
Endif

cQuery := "%"+cQuery+"%"

BeginSQL Alias cAliasJob

	SELECT 
		GZP.GZP_FILIAL FILGZP, 
		GZP.GZP_CODIGO CODIGO,
		GZP.GZP_CODBIL CODBIL,
		GZP.GZP_ITEM   ITEM,
		GI6.GI6_FILRES FILRES, 
		GZP.GZP_FPAGTO FPAGTO, 
		GZP.GZP_QNTPAR PARCTIT, 
		GIC.GIC_CODIGO GICCOD,
		GIC.GIC_DTVEND DTTIT, 
		GIC.GIC_STATUS STATUS,
		GIC.GIC_BILREF BILREF,
		GZP.GZP_TPAGTO TPTIT, 
		GZP.GZP_AUT AUT, 
		GZP.GZP_NSU NSU, 
		GZP.GZP_ESTAB ESTAB, 
		SUM(GZP.GZP_VALOR) VLTIT
	FROM %Table:GZP% GZP
		INNER JOIN %Table:GIC% GIC ON
			GIC.GIC_FILIAL = GZP.GZP_FILIAL
			AND GIC.GIC_CODIGO = GZP.GZP_CODIGO
			AND GIC.GIC_BILHET = GZP.GZP_CODBIL 
			%Exp:cQuery%
			AND GIC.GIC_NUMFCH <> ''
			AND GIC.%NotDel%
		INNER JOIN %Table:GI6% GI6 ON
			GI6.GI6_FILIAL = GIC.GIC_FILIAL
			AND GI6.GI6_CODIGO = GIC.GIC_AGENCI
			AND GI6.%NotDel%
	WHERE  	
		GZP_STAPRO IN ('','0')
		AND (GZP_FPAGTO <> ' ' OR GZP_TPAGTO = 'PP')
		AND GZP.%NotDel%
	GROUP BY 
		GZP.GZP_FILIAL, 
		GZP.GZP_CODIGO,
		GZP.GZP_CODBIL,
		GZP.GZP_ITEM,
		GI6.GI6_FILRES, 
		GZP.GZP_FPAGTO, 
		GZP.GZP_QNTPAR, 
		GIC.GIC_CODIGO,
		GIC.GIC_DTVEND, 
		GIC.GIC_STATUS,
		GIC.GIC_BILREF,
		GZP.GZP_TPAGTO, 
		GZP.GZP_AUT, 
		GZP.GZP_NSU, 
		GZP.GZP_ESTAB 
	ORDER BY GI6.GI6_FILRES, GIC.GIC_CODIGO
				
EndSQL

SAE->(DbSetOrder(1))
G58->(DbSetOrder(2))
SA1->(DbSetOrder(1))
SED->(DbSetOrder(1))

(cAliasJob)->(dbGoTop())

While (cAliasJob)->(!Eof())

	If !Empty((cAliasJob)->FILRES)
		cfilant := Iif(!Empty(cFilCart),cFilCart,(cAliasJob)->FILRES) 
	Endif

	If (cAliasJOB)->STATUS $ 'E|V' .OR. ((cAliasJOB)->STATUS = 'T' .AND. AllTrim((cAliasJob)->TPTIT) $ "CD|PP")

		aTit := {}
		uDiasVenc := Nil

		cAdmFin := IIF(!Empty((cAliasJob)->FPAGTO),(cAliasJob)->FPAGTO,"999")

		If SAE->(DbSeek(xFilial("SAE") + cAdmFin ))
			G58->(DBSETORDER(1))
			If G58->(DbSeek(xFilial("G58") + SAE->AE_COD))	.AND. !Empty(G58->G58_CLIENT) .AND.	!Empty(G58->G58_LOJA)		
				SA1->(DbSeek(xFilial("SA1") + G58->G58_CLIENT+G58->G58_LOJA ))
				SED->(DbSeek(xFilial("SED") + G58->G58_NATURE))
				cDescAdm	:= Posicione('SAE',1,xFilial('SAE') + G58->G58_CODADM, 'AE_DESC')
				cNatureza	:= G58->G58_NATURE
			Else
				SA1->(DbSeek(xFilial("SA1") + cCliSBan ))
				SED->(DbSeek(xFilial("SED") + SA1->A1_NATUREZ ))
				cDescAdm	:= Posicione('SAE',1,xFilial('SAE') + (cAliasJob)->FPAGTO, 'AE_DESC')	
				cNatureza	:= SA1->A1_NATUREZ
			Endif
			
			nParc	:= (cAliasJob)->PARCTIT
			
			If AllTrim((cAliasJob)->TPTIT) == "DE"		
				cTipo	:= CARTAO_DEBITO
				nParc   := Iif(nParc == 0,1,nParc)
			ElseIf nParc > 1
				cTipo	:= CARTAO_PARCELADO
			ElseIf AllTrim((cAliasJob)->TPTIT) $ "CD|PP"		
				cTipo	:= PIX_TEF
				nParc   := Iif(nParc == 0,1,nParc)
				uDiasVenc := 1
			Else
				cTipo	:= CARTAO_CREDITO
				nParc   := Iif(nParc == 0,1,nParc)				
			Endif
			
			cHistTit := (cAliasJob)->(FILGZP + CODIGO + CODBIL)
			
			aAdd(aTit,nParc)
			aAdd(aTit,(cAliasJob)->VLTIT)
			aAdd(aTit,STOD((cAliasJob)->DTTIT))
			aAdd(aTit, cNatureza)
			aAdd(aTit,SA1->A1_COD)
			aAdd(aTit,SA1->A1_LOJA)
			aAdd(aTit,cTipo)
			aAdd(aTit,(cAliasJob)->CODBIL)
			aAdd(aTit,(cAliasJob)->AUT)
			aAdd(aTit,(cAliasJob)->NSU)
			aAdd(aTit,(cAliasJob)->ESTAB)
			aAdd(aTit,alltrim(cDescAdm))
			aAdd(aTit,alltrim(cHistTit))
			aAdd(aTit,(cAliasJob)->FILGZP)
			aAdd(aTit,(cAliasJob)->CODIGO)
			aAdd(aTit,(cAliasJob)->ITEM)

			aRet := GerTit(aTit,,uDiasVenc)
			cRet := aRet[2]

			cFpagto := (cAliasJob)->FPAGTO

			dbSelectArea('GZP')
			GZP->(dbSetOrder(1))
			
			If GZP->(dbSeek((cAliasJob)->FILGZP+(cAliasJob)->CODIGO+(cAliasJob)->CODBIL+(cAliasJob)->ITEM))
			
				Reclock("GZP", .F.)

					If aRet[1]
						GZP->GZP_STAPRO := '1'
						GZP->GZP_TITTEF := cRet
					Else
						GZP->GZP_STAPRO := '2'

					 	If GZP->(FieldPos('GZP_MOTERR')) > 0
							GZP->GZP_MOTERR := cRet
						Endif

					Endif

				GZP->(MsUnlock())

			Endif

		Endif

	ElseIf (cAliasJOB)->STATUS $ 'C|D'

		CANFORSUB((cAliasJob)->FILGZP, (cAliasJob)->CODIGO, (cAliasJob)->CODBIL, (cAliasJob)->ITEM, (cAliasJob)->BILREF)
		
	Endif

	(cAliasJob)->(DbSkip())
End

If Select(cAliasJob) > 0
	(cAliasJob)->(dbCloseArea())
Endif

If !lJob .And. !IsBlind()
	 FwAlertSuccess(STR0004, STR0003) // "Gerado com sucesso","Job Títulos Tef "
Endif
	
return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerTit()

Gera SE1 do bilhete pago com cartão.
 
@sample	GerTit()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		06/01/2018
@version	P12
/*/
Static Function GerTit( aTit, cNumSE1,nDiasVenc)
Local lRet		:= .T. 
Local cRet		:= ''
Local aArray 	:= {}	
Local cTipo 	:= aTit[7]
Local cParcela	:= ''
Local cNum		:= ''
Local nI 		:= 0
Local c1DUP     := SuperGetMv("MV_1DUP")
Local cPath     := GetSrvProfString("Rootpath","")
Local cFile    	:= ""
Local cChvSe1	:= ''
Local cVencto	:= ""
Local cVencReal	:= ""
Local cChaveGZP := ''
Local lGTTITTEF := ExistBlock('GTTITTEF')
Local cRetEnc	:= ""

Private lMsErroAuto	:= .F.

Default cNUmSE1	:= ""
Default nDiasVenc := Nil

SE1->(DbSetOrder(1))

For nI := 1 to aTit[1]

	cParcela  := PadR(GTPParcela( nI, c1DUP ), TamSx3('E1_PARCELA')[1])
	cNum 	  := IIF(EMPTY(cNumSE1),GtpTitNum('SE1', "TEF", cParcela, cTipo),cNumSE1)
	cVencto	  := If(aTit[7] ='CD', DaySum(aTit[3],1), MonthSum(aTit[3],nI))
	cVencReal := DataValida(If(aTit[7] ='CD', DaySum(aTit[3],1), MonthSum(aTit[3], nI)))
	cChvSe1	  := xFilial("SE1")+PadR("TEF",TamSx3('E1_PREFIXO')[1]) + cNum + cParcela + PadR(aTit[7] ,TamSx3('E1_TIPO')[1])

	If ValType(nDiasVenc) == 'N'
		cVencto   := DaySum(aTit[3],nDiasVenc*nI)
		cVencReal := DataValida(cVencto)
	Endif
		
	If !SE1->(DbSeek(cChvSe1)) 
		// gera titulo no contas a receber
		aArray 	:= {}
		aAdd( aArray,	{ "E1_FILIAL"	, xFilial("SE1") 	, NIL } )
		aAdd( aArray,	{ "E1_PREFIXO"	, "TEF" 			, NIL } )
		aAdd( aArray,	{ "E1_NUM" 		, cNum				, NIL } )
		aAdd( aArray,	{ "E1_TIPO" 	, aTit[7]  			, NIL } )
		aAdd( aArray,	{ "E1_NATUREZ"	, aTit[4] 			, NIL } )
		aAdd( aArray,	{ "E1_CLIENTE" 	, aTit[5]			, NIL } )
		aAdd( aArray,	{ "E1_LOJA"		, aTit[6]			, NIL } )
		aAdd( aArray,	{ "E1_PARCELA" 	, cParcela			, NIL } )
		aAdd( aArray,	{ "E1_EMISSAO"	, aTit[3]			, NIL } )
		aAdd( aArray,	{ "E1_VENCTO"	, cVencto			, NIL } )
		aAdd( aArray,	{ "E1_VENCREA"	, cVencReal			, NIL } )
		aAdd( aArray,	{ "E1_VALOR" 	, (aTit[2]/aTit[1])	, NIL } )
		aAdd( aArray,	{ "E1_HIST"		, aTit[13]			, NIL } )
		aAdd( aArray,	{ "E1_ORIGEM"	, 'GTPJ002' 		, NIL } )
		aAdd( aArray,	{ "E1_NSUTEF"	, aTit[10] 			, NIL } )
		aAdd( aArray,	{ "E1_CARTAUT"	, aTit[9] 			, NIL } )

        If lGTTITTEF
            cChaveGZP := aTit[14]+aTit[15]+aTit[8]+aTit[16]
            aArray := ExecBlock("GTTITTEF",.F.,.F., {aArray, cChaveGZP})
        Endif
								
		lMsErroAuto	:= .F.
		MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 3) // 3-Inclusao,4-Alteração,5-Exclusão
		
		If lMsErroAuto
			lRet := .F.
			cRet += MostraErro(cPath,cFile)
		Else
			lRet := .T.
			cRet := cChvSe1 //STR0006 + SE1->E1_NUM //'Título gerado, numero: '
			if !Empty(cNUmSE1) .AND. Empty(cRetEnc)
				cRetEnc := cRet
			Endif
		Endif
	Else
		lRet := .T.
		cRet := cChvSe1 //STR0006 + SE1->E1_NUM //'Título gerado, numero: '
	Endif

Next nI

If lRet .AND. !Empty(cNUmSE1)
	cRet := cRetEnc
Endif

Return {lRet,cRet}
	
	
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPParcela()

Devolve a proxima parcela do titulo.
 
@sample	GTPParcela()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		06/01/2018
@version	P12
/*/
*/
Function GTPParcela( uParcela, cTipo )
Local cResult  := ""                    		// Retorno da função
Local iParcela                                  // Numero da parcela
Local nTam 	   := TamSx3( "E1_PARCELA" )[ 1 ]  // Tamanho do campo no SX3
Local cParcela := Space(nTam)                  // Tamanho da variável
Local lSeqParFat := SuperGetMv( "MV_LJPARFA", ,.F.) // verifica se as parcela seguirão sequência do faturamento.
Local nI := 0 //Sequencia

If ValType(uParcela) == "C"
   iParcela := Val( uParcela )
Else   
   iParcela := uParcela
EndIf
   
If cTipo == NIL 
	If !lSeqParFat
   		cTipo := SuperGETMV("MV_1DUP")=="1"  
	Else
		cTipo := "A"
	EndIf
EndIf

If  lSeqParFat .AND. (  "A" $ cTipo .OR. nTam == 1) //Se for sequenciamento do faturamento 
	//Verifica se tipo é alfa ou tamanho é um para chamar a função do faturamento
	   cResult := cTipo
	   
	   If iParcela > 1
	   		
	   		nI := 2  
	   		For nI := 2 to iParcela
	   			cResult :=	MaParcela(cResult)
	   		Next nI
	   EndIf
	   	
Else
	If cTipo == "A" 
		// A..Z
		cResult := Chr(iParcela+64)
	Else 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o tamanho do campo no SX3 for igual 1 , parcela vai de 1...9³
		//³A....Z   e a.....z                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		If nTam == 1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o tamanho do campo no SX3 for igual 1 , parcela vai de 1...9³
				//³A....Z   e a.....z                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
				  Case iParcela >= 01 .AND. iParcela <= 09
				  	cResult := AllTrim( Str(iParcela) )
				  Case iParcela >= 10 .AND. iParcela <= 35
				    cResult :=  Chr( iParcela + 55 )
				  Case iParcela >= 36 .AND. iParcela <= 61
				    cResult :=  Chr( iParcela + 61 )
				  Otherwise
				    cResult := "*"
				EndCase
		Else 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Respeita o tamanho do campo para determinar a quantidade de parcelas ³
			//³Exemplo: E1_PARCELA = 2  parcelas de 1 .......99                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        
			//Esta regra se sequenciamento é igual a função MaParcela
	    	cParcela := StrZero(iParcela - 1, nTam)   
			cResult  := Soma1(cParcela, nTam)  
	
		EndIf	

	EndIf

EndIf

cResult := PadR(AllTrim(cResult),nTam)		// Deve-se ajustar o retorno de cParcela ao tamanho do E1_PARCELA
	
Return( cResult )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CANFORSUB()
 Cancela a Forma de pagamento do bilhete substituido
 @sample	CANFORSUB()
 @return	
 @author	SIGAGTP | Fernando Amorim(Cafu)
@since		10/01/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function CANFORSUB(cFilGZP, cCodigo, cCodBil, cItem, cBilRef)
Local lRet			:= .T.
Local cAliasBil	 	:= GetNextAlias()
Local cAliasSE1	 	:= GetNextAlias()
Local cPath     	:= GetSrvProfString("Rootpath","")
Local cFile    		:= ""
Local cRet			:= " "
Local cFilTit		:= ""
Local cPrefixo		:= ""
Local cNumTit		:= ""
Local cTipo			:= ""
Local cTitTef		:= ""

Private lMsErroAuto	:= .F.

BeginSql Alias cAliasBil

	SELECT GZP.GZP_TITTEF
	FROM %Table:GIC% GIC
	INNER JOIN %Table:GZP% GZP 
	ON GZP.GZP_FILIAL = GIC.GIC_FILIAL
	AND GZP.GZP_CODIGO = GIC.GIC_CODIGO
	AND GZP.GZP_CODBIL = GIC.GIC_BILHET
	AND GZP.GZP_ITEM = %Exp:cItem%  
	AND GZP.GZP_STAPRO = '1'
	AND GZP. %NotDel%
	WHERE GIC_FILIAL = %Exp:cFilGZP%
	AND GIC_CODIGO = %Exp:cBilRef%
	AND GIC.GIC_STATUS IN ('E','V')
	AND GIC.%NotDel%
	
EndSql

While (cAliasBil)->(!Eof())

	cTitTef  := (cAliasBil)->GZP_TITTEF

	cFilTit  := Substr(cTitTef, 1, FwSizeFilial())
	cTitTef  := Substr(cTitTef, FwSizeFilial()+1)
	cPrefixo := Substr(cTitTef, 1, TamSx3('E1_PREFIXO')[1]) 
	cTitTef  := Substr(cTitTef, TamSx3('E1_PREFIXO')[1]+1)
	cNumTit  := Substr(cTitTef, 1, TamSx3('E1_NUM')[1])
	cTitTef  := Substr(cTitTef, TamSx3('E1_NUM')[1]+TamSx3('E1_PARCELA')[1]+1)
	cTipo    := Substr(cTitTef, 1, TamSx3('E1_TIPO')[1])

	BeginSql Alias cAliasSE1

		SELECT E1_FILIAL,
			E1_PREFIXO,
			E1_TIPO,
			E1_NUM,
			E1_PARCELA,
			E1_VALOR,
			E1_SALDO
		FROM %Table:SE1%
		WHERE E1_FILIAL = %Exp:cFilTit%
		AND E1_PREFIXO  = %Exp:cPrefixo%
		AND E1_TIPO     = %Exp:cTipo%
		AND E1_NUM      = %Exp:cNumTit%
		AND %NotDel%
		ORDER BY E1_PARCELA

	EndSql

	While (cAliasSE1)->(!Eof())

		SE1->(dbSetOrder(1))

		If SE1->(dbSeek((cAliasSE1)->E1_FILIAL+(cAliasSE1)->E1_PREFIXO+(cAliasSE1)->E1_NUM+(cAliasSE1)->E1_PARCELA+(cAliasSE1)->E1_TIPO))
		   
			If SE1->E1_SALDO == SE1->E1_VALOR	 

				aTitSE1 := {}

				aTitSE1 := {{ "E1_PREFIXO"	, SE1->E1_PREFIXO	, Nil },; //Prefixo 
					{ "E1_NUM"		, SE1->E1_NUM  			    , Nil },; //Numero
					{ "E1_PARCELA"	, SE1->E1_PARCELA		    , Nil },; //Parcela
					{ "E1_TIPO"		, SE1->E1_TIPO			    , Nil },; //Tipo
					{ "E1_NATUREZ"	, SE1->E1_NATUREZ		    , Nil },; //Natureza
					{ "E1_CLIENTE"	, SE1->E1_CLIENTE		    , Nil },; //Cliente
					{ "E1_LOJA"		, SE1->E1_LOJA			    , Nil }} //Loja

				lMsErroAuto	:= .F.
				MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 5)  // Exclui o título
				
				If lMsErroAuto
					lRet := .F.
					cRet += MostraErro(cPath,cFile)
					Exit
				Else
					lRet := .T.
				EndIf

			Endif	

		Endif

		(cAliasSE1)->(dbSkip())
	End

	If Select(cAliasSE1) > 0 
		(cAliasSE1)->(dbCloseArea())
	EndIf

	(cAliasBil)->(dbSkip())

End

(cAliasBil)->(dbCloseArea())


dbSelectArea('GZP')
GZP->(dbSetOrder(1))

If GZP->(dbSeek(cFilGZP+cCodigo+cCodBil+cItem))

	Reclock("GZP", .F.)

		If lRet
			GZP->GZP_STAPRO := '1'
		Else
			GZP->GZP_STAPRO := '2'
		Endif

	GZP->(MsUnlock())

Endif

Return

/*/{Protheus.doc} GTPP003
	Realiza inclusão de título de cartões TEF originados de encomendas
	e inclui a taxa da administradora
	@type  Function
	@author João Pires
	@since 20/01/2025
	@version 1.0
	@param aTit, array, Array com os dados do título
	@return cChvSe1, Character, Chave do título gerado
	/*/
Function GTPP003(aTit,cAdm,lSE2,cNumSE1)
	Local cChvSe1	:= ""
	Local lTaxa		:= SuperGetMv( "MV_LJGERTX", ,.F.) //Abate a taxa da administradora financeira
	Local nTaxa		:= 0
	Local aTitPagar := {}	
	Local cNum		:= ''
	Local cCliente  := ''
	Local cLoja		:= ''
	Local nDiasVenc	:= 1
	Private lMsErroAuto := .F.

	Default aTit 	:= {}
	Default cAdm 	:= ""
	Default lSE2 	:= .F. //Chave para apenas incluir a taxa no contas a pagar
	Default cNumSE1 := ""

	If Len(aTit) == 16				

		if !Empty(cAdm)
			SAE->(DbSetOrder(1)) //AE_FILIAL+AE_COD

			If SAE->(DbSeek(xFilial("SAE") + cAdm )) 
				nTaxa 		:= CalcTaxa(cAdm,aTit[1]) 
				nTaxa 		:= IIF(nTaxa < 0, SAE->AE_TAXA, nTaxa)
				nTaxa 		:= (nTaxa * aTit[2])/100

				lTaxa 		:= IIF(SAE->AE_FINPRO == 'S',.F.,lTaxa)
				cCliente	:= SAE->AE_CODCLI
				cLoja		:= SAE->AE_LOJCLI
				nDiasVenc	:= SAE->AE_DIAS
			Endif
		endif

		IF lTaxa .AND. nTaxa > 0 
			SA2->(DBSetOrder(8)) //A2_FILIAL+A2_CODADM

			IF SA2->(DBSeek(xFilial('SA2') + SAE->AE_COD))

				cNum 	  := IIF(EMPTY(cNumSE1),GtpTitNum('SE2', "TEF", '', aTit[7]),cNumSE1)			
				aTitPagar := {	{"E2_PREFIXO"	, 'TEF'							, Nil },; //Prefixo
								{"E2_NUM"    	, cNum							, Nil },; //Numero								
								{"E2_PARCELA"	, ''							, Nil },; //Parcela
								{"E2_TIPO"   	, aTit[7]						, Nil },; //Tipo
								{"E2_NATUREZ"	, SA2->A2_NATUREZ				, Nil },; //Natureza
								{"E2_FORNECE"	, SA2->A2_COD					, Nil },; //Fornecedor
								{"E2_LOJA"   	, SA2->A2_LOJA					, Nil },; //Loja
								{"E2_EMISSAO"	, aTit[3]						, Nil },; //Emissão
								{"E2_VENCTO"	, DaySum(aTit[3],nDiasVenc)		, Nil },; //Vencimento																
								{"E2_VALOR"  	, nTaxa							, Nil },; //Valor							
								{"E2_HIST" 		, aTit[13] 						, Nil },;
								{"E2_ORIGEM" 	, 'GTPJ002'						, Nil }}  //Origem
					
				
					MSExecAuto({|x,y,z| FINA050(x,y,z)}, aTitPagar, , 3)
						
					If lMsErroAuto
					
						MostraErro()		
						lSE2 := .T.			
						SE2->(RollBackSx8())
						
					Else
						
						cChvSe1 := IIF(lSE2,SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA),cChvSe1)
						SE2->(ConfirmSX8())
							
					Endif
			Else				
				FWAlertHelp(STR0009,STR0010 )//"Fornecedor não encontrado" - "Efetue o cadastro do fornecedor da Adm. financeira"
				lSE2 := .T.
			Endif
		ENDIF
		
		IF !lSE2  
			If Empty(cCliente) .OR. !SA1->(DBSeek(xFilial("SA1")+cCliente+cLoja))
				FWAlertHelp( STR0011, STR0012)//"Cliente da Adm. Financeira não encontrado" - "Efetue o cadastro de cliente"
			else
				IF !lTaxa //Se falso lança a conta a receber descontando a taxa
					aTit[2] -= nTaxa
				Endif
				
				aTit[5] := cCliente
				aTit[6] := cLoja
				aTit[4] := SA1->A1_NATUREZ

				aRet := GerTit(aTit,cNumSE1,nDiasVenc)
				
				if aRet[1]
					cChvSe1 := aRet[2]
				else
					FWAlertError(aRet[2], STR0013)//"Título não cadastrado"
				endif
			Endif
		Endif

	Endif
	
Return cChvSe1



/*/{Protheus.doc} GTPP004
	Realiza exclusão de título de cartões TEF originados de encomendas	
	@type  Function
	@author João Pires
	@since 14/03/2025
	@version 1.0
	@param aTit, array, Array com os dados do título
	@return lRet, Logical, Retorna true se houver sucesso
	/*/
Function GTPP004(aTit,cErro,cTipo)	
	Local cPath     := GetSrvProfString("Rootpath","")
	Local cFile    	:= ""
	Local lRet		:= .T.
	Private lMsErroAuto := .F.

	Default aTit  := {}
	Default cErro := ""
	Default cTipo := ""
	

	If cTipo == "CR" .AND. Len(aTit) > 0
		MsExecAuto( { |x,y| FINA040(x,y)} , aTit, 5)  // Exclui o título
                            
        If lMsErroAuto              
            cErro := MostraErro(cPath,cFile)
			lRet  := .F.
        Endif
                    
	Endif

	If cTipo == "CP" .AND. Len(aTit) > 0
		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aTit,, 5) // Exclui o título
                            
        If lMsErroAuto              
            cErro := MostraErro(cPath,cFile)
			lRet  := .F.
        Endif
                    
	Endif
	
Return lRet

/*/{Protheus.doc} CalcTaxa
	Calcula a taxa de juros da Adm. Financeira
	@type  Static Function
	@author João Pires
	@since 19/03/2025	
	@param nParc, numeric, quantidade de parcelas
	@return nTaxa, numeric, taxa a ser aplicada	
/*/
Static Function CalcTaxa(cAdm,nParc)
	Local cAliasMEN := GetNextAlias()
	Local nTaxa		:= -1

	BeginSQL Alias cAliasMEN
		
		SELECT MEN_TAXADM 
			FROM %Table:MEN% MEN 
		WHERE 
			MEN_FILIAL = %xFilial:MEN%
			AND MEN_CODADM = %Exp:cAdm% 
			AND MEN.%NotDel%
			AND MEN_PARINI <= %Exp:nParc%  
			AND MEN_PARFIN >= %Exp:nParc% 
						
	EndSQL

	(cAliasMEN)->(dbGoTop())

	If (cAliasMEN)->(!Eof())
		nTaxa := (cAliasMEN)->MEN_TAXADM
	Endif

	(cAliasMEN)->(DBCloseArea())

Return nTaxa
