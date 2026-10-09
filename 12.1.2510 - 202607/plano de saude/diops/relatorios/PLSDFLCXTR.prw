#Include 'Protheus.ch'
#Include 'PLSDFLCXTR.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSDFLCXTR
Geração de arquivo CSV. DIOPS - Fluxo de Caixa Trimestral 

@return	
@author	Fábio Siqueira/Roger
@since	03/03/2017 / 18/09/2017
@version P12
/*/
//-------------------------------------------------------------------
Function PLSDFLCXTR()
Local aSays			:= {}
Local aButtons		:= {}
Local cCadastro		:= STR0001 //"DIOPS Fluxo de Caixa Trimestral"

Private cPerg		:= "PLSDFLCXTR"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta texto para janela de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aSays,STR0002 ) //"Esta rotina efetua a exportacão do arquivo CSV da DIOPS - Fluxo de Caixa Trimestral."
aadd(aSays,STR0003 ) //"Antes de executar a rotina, informar os parâmetros."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botoes para janela de processamento                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| Processa( {|| Pergunte(cPerg,.F. ),DFLCXTR() }, STR0004,STR0005,.F. ) } } )//"Processando DIOPS - Fluxo de Caixa Trimestral"###"Buscando informações..."
Aadd(aButtons, { 2,.T.,{|| FechaBatch() }} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela de processamento                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FormBatch(cCadastro,aSays,aButtons)
Return

//------------------------------------------------------------------
/*/{Protheus.doc} DFLCXTR

@description Processa o DIOPS 
@author Fábio Siqueira dos Santos
@since 13/02/2017
@version P12
@return Grava arquivo .CSV com as informações

/*/
//------------------------------------------------------------------
Static Function DFLCXTR()
Local aSetOfBook	:= {}		
Local lEnd			:= .F.
Local cArqTmp		:= GetNextAlias()
Local lImpAntLP		:= .F.
Local lVlrZerado	:= .T.
Local lImpSint		:= .T.
Local cFilUser		:= ""
Local lRecDesp0 	:= .F.
Local cRecDesp		:= ""
Local dDtZeraRD		:= ""
Local cMoedaDsc		:= ""
Local aSelFil		:= {}
Local aValores		:= {}
Local cDiretorio	:= ""

If Empty(MV_PAR01) .Or. Empty(MV_PAR02) //.Or. Empty(MV_PAR03)
	MsgInfo(STR0006,STR0001) //"Parâmetros não informados, por favor informar!"#"DIOPS Fluxo de Caixa Trimestral"
Else

/*
	If ! Ct040Valid( mv_par03 )
		Return .F.
	Else
	   aSetOfBook := CTBSetOf(mv_par03)
	EndIf
*/
	FechaBatch()		
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
		PLSDFLCXTM(@cArqTmp, MV_PAR01, MV_PAR02) },;
		OemToAnsi(OemToAnsi(STR0007)),; //Aguarde ...
		OemToAnsi(STR0001)) //Gerando CSV - Balancete Trimestral ...
					
	DbSelectArea(cArqTmp)	
				
	nCount := (cArqTmp)->(RecCount())
	(cArqTmp)->(DbGoTop())

	//If AllTrim(aSetOfBook[11]) <> ""

		nCount := 0
		
		While (cArqTmp)->(!Eof())			
			nCount := nCount + 1
			aadd(aValores, alltrim((cArqTmp)->B8V_CODIGO) + ";" + B8HDescri((cArqTmp)->B8V_CODIGO)+ ";" + alltrim(cvaltochar((cArqTmp)->VALORBAIXA)))		
			(cArqTmp)->(dbSkip())
		enddo
		
		cDiretorio := PLSGerCSV("fluxo_"+ AllTrim(mv_par02) + "_" + AllTrim(mv_par01)+".csv", "", aValores)
	
		Set Filter To
		
		dbCloseArea()
		
		If Select(cArqTmp) == 0
			FErase(cArqTmp+GetDBExtension())
			FErase(cArqTmp+OrdBagExt())
		EndIF
		
		MsgInfo(STR0008 + cDiretorio, "TOTVS" )//Geração Finalizada. O arquivo foi gerado em:
	//else	
		//MsgInfo(STR0009, STR0010 )//"É necessário vincular um plano referencial ao livro selecionado."#"TOTVS"
	//endif

EndIf
Return


// Função de geração do temporário com os dados a imprimir
Function PLSDFLCXTM(cArqTmp, cTrimestre, cAno, lRelFluxo)
Local cMovBan	:= ''
Local aMotBx	:= {}
Local dDatDe 	:= CtoD('01/'+IIf(cTrimestre=='1','01',IIf(cTrimestre=='2','04',IIf(cTrimestre=='3','07','10')))+'/'+cAno)
Local dDatAte	:= LastDay(Ctod('01/'+IIf(cTrimestre=='1','03',IIf(cTrimestre=='2','06',IIf(cTrimestre=='3','09','12')))+'/'+cAno))
Local nX		:= 0
Local cQuery	:= ''
Local lMsSql	:= "MSSQL" $ Upper(TcGetDb()) 
Local nTFilial		:= tamSX3("E2_FILIAL")[1]
Local nPFilial		:= 1
Local nTPrefixo		:= tamSX3("E2_PREFIXO")[1]
Local nPPrefixo		:= nPFilial + nTFilial + 1
Local nTNumero		:= tamSX3("E2_NUM")[1]
Local nPNumero		:= nPPrefixo + nTPrefixo + 1
Local nTParcela		:= tamSX3("E2_PARCELA")[1]
Local nPParcela		:= nPNumero + nTNumero + 1
Local nTTipo		:= tamSX3("E2_TIPO")[1]
Local nPTipo		:= nPParcela + nTParcela + 1
Local nTFornecedor	:= tamSX3("E2_FORNECE")[1]
Local nPFornecedor	:= nPTipo + nTTipo + 1
Local nTLoja		:= tamSX3("E2_LOJA")[1]
Local nPLoja		:= nPFornecedor + nTFornecedor + 1
Local nTCliente		:= tamSX3("E1_CLIENTE")[1]
Local nPCliente		:= nPTipo + nTTipo + 1

Default cArqTmp		:= GetNextAlias()	 			// Arquivo gerado
Default cTrimestre  := '1'							// Trimestre
Default cAno		:= StrZero(Year(dDataBase),4)	// Ano
Default lRelFluxo	:= .T.

//motivos de baixa que faz movimentacao bancaria
aMotBx := readMotBx() 
for nX = 1 to len(aMotBx)
    if subStr(aMotBx[nX],19,1) == 'S'  
        if nX > 1
            cMovBAN += "|"
        endIf  
        cMovBAN += subStr(aMotBx[nX],01,03)
    endIf
next

// Elimina array
aSize(aMotBx,1)
aDel(aMotBx,1)

// Contas a Pagar
cQuery	+= " SELECT B8V_CODIGO,  SUM( CASE  WHEN FK2_TPDOC = 'ES' THEN FK2_VALOR * -1 ELSE FK2_VALOR END ) AS VALORBAIXA "

cQuery	+= " FROM " + PLSSQLNAME("FK7") + " FK7 "//+ Iif( lMsSql, ' (NOLOCK) ', '' )

cQuery += " INNER JOIN " + PLSSQLNAME("SE2") + " SE2 "//+ Iif( lMsSql, ' (NOLOCK) ', '' )
cQuery += "   ON  E2_FILIAL=FK7_FILTIT AND E2_PREFIXO=FK7_PREFIX AND E2_NUM=FK7_NUM AND E2_PARCELA=FK7_PARCEL AND E2_TIPO=FK7_TIPO AND E2_FORNECE=FK7_CLIFOR AND E2_LOJA=FK7_LOJA "
cQuery += "   AND E2_TIPO NOT IN " + formatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT,"|")//AB-|FB-|FC-|FU-|IR-|IN-|IS-|PI-|CF-|CS-|FE-|IV-//IR-//IN- 
cQuery += "   AND SE2.D_E_L_E_T_ = '' "

cQuery += " INNER JOIN " + PLSSQLNAME("B8V") + " B8V "//+ Iif( lMsSql, ' (NOLOCK) ', '' )
cQuery += "    ON B8V_FILIAL	= '"+ xFilial('B8V') + "' " 
cQuery += "   AND B8V_CODOPE	= '"+PlsIntPad()+"' " 
cQuery += "   AND B8V_CODNAT	= E2_NATUREZ " 

cQuery += " INNER JOIN " + PLSSQLNAME("FK2") + " FK2 " //+ Iif( lMsSql, ' (NOLOCK) ', '' )
cQuery += "    ON FK2_FILIAL = '" + xFilial("FK2") + "' "
cQuery += "   AND FK7_IDDOC = FK2_IDDOC "
cQuery += "   AND FK2_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
cQuery += "   AND FK2_MOTBX IN " + formatIn(cMovBAN,"|")		//lista motivo de baixa que gera movimentacao bancaria ou baixa de PA		
//cQuery += "         OR FK2_MOTBX = 'CMP' AND FK2_TPDOC = 'CP' )"		
cQuery += "   AND FK2.D_E_L_E_T_ = ' ' "

cQuery += " WHERE FK7_FILIAL = '" + xFilial("FK7") + "' "
cQuery += "   AND FK7_ALIAS  = 'SE2' "
cQuery += "   AND FK7.D_E_L_E_T_ = ' ' "

cQuery	+= " GROUP BY B8V_CODIGO "

cQuery += " UNION ALL "

// Contas a Receber
cQuery	+= " SELECT B8V_CODIGO,  SUM(FK1_VALOR) AS VALORBAIXA "

cQuery += " FROM " + PLSSQLNAME("FK1") + " FK1 "//+ Iif( lMsSql, ' (NOLOCK) ', '' )

cQuery += " INNER JOIN " + PLSSQLNAME("FK7") + " FK7 " //+ Iif( lMsSql, ' (NOLOCK) ', '' )
cQuery += "    ON FK7_FILIAL = '" + xFilial("FK7") + "' "
cQuery += "   AND FK7_ALIAS  = 'SE1' "
cQuery += "   AND FK7_IDDOC  = FK1.FK1_IDDOC "
cQuery += "   AND FK7.D_E_L_E_T_ = ' ' "

cQuery += " INNER JOIN " + PLSSQLNAME("SE1") + " SE1 "//+ Iif( lMsSql, ' (NOLOCK) ', '' )
cQuery += "   ON  E1_FILIAL=FK7_FILTIT AND E1_PREFIXO=FK7_PREFIX AND E1_NUM=FK7_NUM AND E1_PARCELA=FK7_PARCEL AND E1_TIPO=FK7_TIPO AND E1_CLIENTE=FK7_CLIFOR AND E1_LOJA=FK7_LOJA "
//AB-|FB-|FC-|FU-|IR-|IN-|IS-|PI-|CF-|CS-|FE-|IV- //IR- //IN- //NCC //NDF //RA //PA
cQuery += "   AND E1_TIPO NOT IN " + formatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MV_CRNEG+"|"+MV_CPNEG+"|"+MVPAGANT+"|"+MVRECANT ,"|") 
cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "

// a data de emissão deve ser menor que a informada no parâmetro
cQuery += "   AND E1_EMISSAO <='"+DtoS(dDatAte)+"' "	
cQuery += "   AND SE1.D_E_L_E_T_ = ' ' " 

cQuery += " INNER JOIN " + PLSSQLNAME("B8V") + " B8V "+ Iif( lMsSql, ' (NOLOCK) ', '' )
cQuery += "    ON B8V_FILIAL	= '" + xFilial('B8V') + "' " 
cQuery += "   AND B8V_CODOPE	= '"+PlsIntPad()+"' " 
cQuery += "   AND B8V_CODNAT	= E1_NATUREZ " 

cQuery += "WHERE FK1_FILIAL = '" + xFilial("FK1") + "' "
cQuery += "AND FK1_DTDISP BETWEEN '" + dtos(dDatDe) + "' AND '" +  dtos(dDatAte) + "' "
cQuery += "AND FK1_MOTBX NOT IN ('LIQ', 'NEG')  "
cQuery += "AND FK1.D_E_L_E_T_ = ' ' "

cQuery	+= " GROUP BY B8V_CODIGO "

cQuery	+= " ORDER BY B8V_CODIGO "

cQuery	:= ChangeQuery(cQuery)

nHandle := FCREATE('QRYDFLX.SQL',0)
FWRITE(nHandle, cQuery)
FCLOSE(nHandle)

MPSysOpenQuery( cQuery, cArqTmp )
TCSetField(cArqTmp,"VALORBAIXA","N",16,2)

Return

