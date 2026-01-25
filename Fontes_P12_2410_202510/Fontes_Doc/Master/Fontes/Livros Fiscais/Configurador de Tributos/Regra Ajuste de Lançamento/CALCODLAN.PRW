#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

STATIC lPerTpLan := fisExtCmp('12.1.2310', .T.,"CDV", "CDV_TPLANC") .AND. fisExtCmp('12.1.2310', .T.,"CDV", "CDV_PCLANC") // se os campos de tipo de laçamento e percentual existirem
STATIC lCpoSubst := fisExtCmp('12.1.2310', .T.,"CC6", "CC6_SUBST")  .AND. fisExtCmp('12.1.2310', .T.,"CDO", "CDO_SUBST")


//-------------------------------------------------------------------
/*/{Protheus.doc} RetCodAp

Cria um JSON com todos os códigos de lançamentos cadastrados na tabela CJA filtrado por periodo mais filial.

@author Adilson Roberto
@since 04/02/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function RetCodAp(dData, lBdjaSon, oJCodRef, __aPrepared,aNfItem,aNfCab)

Local aInsert      := {}
Local aRegCal      := {}
Local aTribgen     := {}
Local cAliascJA    := GetNextAlias()
Local cFrom        := ""
Local cMD5         := ""
local cOrderby     := ""
Local cQuery       := ""
Local cRegCal      := ""
Local cSelect      := ""
Local cWhere       := ""
Local nLen         := 0
Local nPosPrepared := 0
Local nX           := 0
Local nII          := 0
Local nIF          := Len(aNfItem)
Local cTipoLanc    := ""
Local cSubsCC6   := ""
Local cSubsCDO   := ""

If lBdjaSon

    For nII := 1 to nIF        
        For nX := 1 to Len(aNfItem[nII][IT_TRIBGEN])
            Aadd(aTribgen,aNfItem[nII][IT_TRIBGEN][nX][1])
        Next
    Next
    cSelect := "SELECT CJA.CJA_FILIAL, CJA.CJA_ID, CJA.CJA_CODREG, CJA.CJA_REGCAL, CJA.CJA_CODLAN, CJA.CJA_NFBASE, CJA.CJA_NFALIQ, CJA.CJA_VALOR, CJA.CJA_VLOUTR, "
    cSelect += "CJA.CJA_CODTAB, CJA.CJA_CODCPL, CJA.CJA_CODMSG, CJA.CJA_TXTDSC, CJA.CJA_GERMSG, CDY.CDY_DESCR, CJA.CJA_CNTRL, CJA.CJA_OPER "

    if lPerTpLan
        cSelect += ", CDY_TPLANC "
    endif

    if lCpoSubst
        cSelect += ", CC6.CC6_SUBST , CDO.CDO_SUBST "
    endif

    cFrom   := "FROM " + RetSqlName("CJ9") + " CJ9 "
    cFrom   += "INNER JOIN " + RetSqlName("CJA") + " CJA ON(CJA.CJA_FILIAL = ? AND CJA.CJA_ID_CAB = CJ9.CJ9_ID AND CJA.CJA_VIGINI <= ? AND (CJA.CJA_VIGFIM >= ? OR CJA.CJA_VIGFIM = '' ) AND CJA.D_E_L_E_T_ = ' ' ) "
            aadd(aInsert, {'C',xFilial("CJA")})
            aadd(aInsert, {'D',dData})
            aadd(aInsert, {'D',dData})
    cFrom   += "LEFT JOIN " + RetSqlName("CDY") + " CDY ON(CDY.CDY_FILIAL = ? AND CDY.CDY_CODAJU = CJA.CJA_CODLAN AND CDY.D_E_L_E_T_ = ' ' ) "
            aadd(aInsert, {'C',xFilial("CDY")})

    If lCpoSubst
        cFrom   += "LEFT JOIN " + RetSqlName("CC6") + " CC6 ON(CC6.CC6_FILIAL = ? AND CC6.CC6_CODLAN = CJA.CJA_CODLAN AND CJA.CJA_CODTAB = '03' AND CC6.D_E_L_E_T_ = ' ' ) "
        aadd(aInsert, {'C',xFilial("CC6")})	
        cFrom   += "LEFT JOIN " + RetSqlName("CDO") + " CDO ON(CDO.CDO_FILIAL = ? AND CDO.CDO_CODAJU = CJA.CJA_CODLAN AND CJA.CJA_CODTAB = '01' AND CDO.D_E_L_E_T_ = ' ' ) "
        aadd(aInsert, {'C',xFilial("CDO")})	
    EndIf

    cWhere  := "WHERE CJ9.CJ9_FILIAL= ? AND "
            aadd(aInsert, {'C',xFilial("CJ9")})
    cWhere  += "CJ9.CJ9_VIGINI <= ? AND "
            aadd(aInsert, {'D',dData})
    cWhere  += "(CJ9.CJ9_VIGFIM >= ? OR CJ9.CJ9_VIGFIM = ' ' ) AND "
            aadd(aInsert, {'D',dData})
    cWhere  += "CJA.CJA_REGCAL IN (?) AND "
            aadd(aInsert, {'A',aTribgen})
    cWhere  += "CJ9.D_E_L_E_T_ = ' ' "

    cOrderby   := "ORDER BY CJA.CJA_REGCAL"

    cQuery := cSelect +  cFrom +  cWhere + cOrderby

    nLen := Len(aInsert)
    cMD5 := MD5(cQuery)
    If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
        Aadd(__aPrepared,{FWPreparedStatement():New(),cMD5})
        nPosPrepared := Len(__aPrepared)
        __aPrepared[nPosPrepared][1]:SetQuery(ChangeQuery(cQuery))
    EndIf 

 	For nX := 1 to nLen
		IF aInsert[nX][1] =='C'
			__aPrepared[nPosPrepared][1]:SetString(nX,aInsert[nX][2])
		Elseif aInsert[nX][1] =='A'
			__aPrepared[nPosPrepared][1]:setIn(nX,aInsert[nX][2])
        Elseif aInsert[nX][1] =='D'
			__aPrepared[nPosPrepared][1]:setDate(nX,aInsert[nX][2])  
		Endif
	Next 

    cQuery := __aPrepared[nPosPrepared][1]:getFixQuery()

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliascJA)
  
    oJCodRef := JsonObject():New()
    

    (cAliascJA)->(DBGoTop())
    Do While (cAliascJA)->(!EOF())
        if lPerTpLan
            cTipoLanc := (cAliascJA)->CDY_TPLANC
        endif
        
        if lCpoSubst 
            cSubsCC6   := (cAliascJA)->CC6_SUBST
            cSubsCDO   := (cAliascJA)->CDO_SUBST
        endif

        If !cRegCal == (cAliascJA)->CJA_REGCAL
            aRegCal := {}
            cRegCal := (cAliascJA)->CJA_REGCAL

            Aadd(aRegCal,{cRegCal,;     //1
            (cAliascJA)->CJA_CODLAN,;   //2
            (cAliascJA)->CJA_NFBASE,;   //3
            (cAliascJA)->CJA_NFALIQ,;   //4
            (cAliascJA)->CJA_VALOR, ;   //5
            (cAliascJA)->CJA_VLOUTR,;   //6
            (cAliascJA)->CJA_CODTAB,;   //7
            (cAliascJA)->CJA_CODMSG,;   //8
            (cAliascJA)->CJA_CODCPL,;   //9
            (cAliascJA)->CJA_TXTDSC,;   //10
            (cAliascJA)->CJA_GERMSG,;   //11
            (cAliascJA)->CDY_DESCR, ;   //12
            (cAliascJA)->CJA_CNTRL, ;   //13
            (cAliascJA)->CJA_OPER,;     //14
            cTipoLanc,;                 //15
            cSubsCC6,;                  //16
            cSubsCDO})                  //17

            oJCodRef[cRegCal] := aRegCal

        Else
            Aadd(aRegCal,{cRegCal,;    //1
            (cAliascJA)->CJA_CODLAN,;  //2
            (cAliascJA)->CJA_NFBASE,;  //3
            (cAliascJA)->CJA_NFALIQ,;  //4
            (cAliascJA)->CJA_VALOR,;   //5
            (cAliascJA)->CJA_VLOUTR,;  //6
            (cAliascJA)->CJA_CODTAB,;  //7
            (cAliascJA)->CJA_CODMSG,;  //8
            (cAliascJA)->CJA_CODCPL,;  //9
            (cAliascJA)->CJA_TXTDSC,;  //10
            (cAliascJA)->CJA_GERMSG,;  //11
            (cAliascJA)->CDY_DESCR, ;  //12
            (cAliascJA)->CJA_CNTRL, ;  //13
            (cAliascJA)->CJA_OPER,;    //14
            cTipoLanc,;                //15
            cSubsCC6,;                 //16
            cSubsCDO})                 //17

            oJCodRef[cRegCal] := aRegCal
        Endif
        (cAliascJA)->(DbSkip())
    Enddo

    dbSelectArea(cAliascJA)
    (cAliascJA)->(dbCloseArea())
    //FwFreeArray(aRegCal)
    //FwFreeArray(aInsert)
    asize(aInsert,0)
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BusCodLan

Atualiza array aGrava com todos os lançamentos calculados pelo configurador

@author Adilson Roberto
@since 04/02/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Function BusCodLan(aGrava,nZ,aNfItem,aNfCab, lBdjaSon, oJCodRef)

Local aCodLan   := {}
Local nBasCal   := 0
Local nAlqCal   := 0
Local nValor    := 0
Local nValOut   := 0 
Local nI		:= 0
Local nX        := 0
Local cItem     := aNfItem[nZ,IT_ITEM]
Local aTribgen	:= aNfItem[nZ][IT_TRIBGEN]
Local cTpLanc   := ""
Local cSeq      := "001"
Local cCodRefl  := ""
Local cCodLan   := ""
Local cGeraGNRE := ""
Local cCmp0460  := ""
Local cCMPOrig  := ""
Local cCodDes   := ""
Local cIFCOMP   := ""
Local cLivro    := ""
Local cCFOP     := ""
Local cDescod   := ""
Local cCodObs   := ""
Local cCodOLan  := ""
Local cGeracum  := ""
Local cRegCalc  := ""
Local cCodVal   := ""
Local cCodValOu := ""
Local cOpBase   := ""
Local cOpAliq   := ""
local cEstOri   := aNfCab[NF_UFORIGEM]
Local cEstDest  := aNfCab[NF_UFDEST]
Local cTipoMov  := aNfCab[NF_OPERNF]
Local cDevol    := aNFCab[NF_TIPONF]  
Local lCTOper   := .F.
Local lCtUF     := .F.
Local cTipoLanc := ""
Local nPercLanc := 0
Local nRecDelCDA := 0

//aCodLan[nI][14] =  CJA_OPER  '01=Entrada;02=Saída;03=Devolução;'
//aCodLan[nI][13] =  CJA_CNTRL '01=UF Origem;02=UF Destino;'

IF lBdjaSon .and. Valtype(oJCodRef) =='J'
    If Len(aTribgen) > 0
        For nX := 1 To Len(aTribgen)
            cChave := aTribgen[nX][1]
            aCodLan :=	oJCodRef[cChave]
            If Valtype(aCodLan) =='A' .And. Len(aCodLan) > 0
                For nI := 1 To Len(aCodLan)
                    cCodLan     := Alltrim(aCodLan[nI][2])   //CJA_CODLAN

                    // Controle da Operação
                    If !Empty(aCodLan[nI][14])
                        If (aCodLan[nI][14] == "01" .And. cTipoMov == "E" .And. cDevol <> "D") .Or.;
                        (aCodLan[nI][14] == "02" .And. cTipoMov == "S" .And. cDevol <> "D" ) .Or.;
                            aCodLan[nI][14] == "03" .And. cDevol == "D"
                            lCTOper := .T.
                        Else
                            lCTOper := .F.
                        Endif
                    Else
                        lCTOper := .T.
                    EndIf

                    //Controle de UF
                    If !Alltrim(aCodLan[nI][7]) == "04"
                        If !Empty(aCodLan[nI][13])
                            If aCodLan[nI][13] == "01" .And. cEstOri == Left(cCodLan,2)
                                lCtUF := .T.
                            ElseIf aCodLan[nI][13] == "02" .And. cEstDest == Left(cCodLan,2)
                                lCtUF := .T.
                            Else
                                lCtUF := .F.
                            EndIf
                        Else
                            lCtUF := .T.
                        Endif
                    Else
                        lCtUF := .T.
                    Endif

                    //Geração dos dados para o aGrava, este array irá alimentar as tabelas CDA e CDV 
                    If lCTOper .And. lCtUF
                        nBasCal     := aTribgen[nX][TG_IT_BASE]        //CJA_NFBASE  
                        nAlqCal     := aTribgen[nX][TG_IT_ALIQUOTA]    //CJA_NFALIQ 
                        cTpLanc     := Iif(Alltrim(aCodLan[nI][7]) == "03","2","1") 
                        cRegCalc    := aCodLan[nI][1]   //cRegCal
                        //cGeraGNRE   := aCodLan[nI][7]   //CJA_GRGUIA 
                        cCodVal     := Left(aCodLan[nI][5],3)   //CJA_VALOR
                        cCodValOu   := Left(aCodLan[nI][6],3)   //CJA_VLOUTR
                        nValor      := 0
                        nValOut     := 0
                        cOpBase     := aCodLan[nI][3]
                        cOpAliq     := aCodLan[nI][4]
                        //vALOR
                        If cCodVal == "BAS"
                            nValor := aTribgen[nX][TG_IT_BASE]
                        ElseIf cCodVal == "ALQ"
                            nValor := aTribgen[nX][TG_IT_ALIQUOTA]
                        ElseIf cCodVal == "VAL"
                            nValor := aTribgen[nX][TG_IT_VALOR]
                        ElseIf cCodVal == "ISE"
                            nValor := aTribgen[nX][TG_IT_LF][TG_LF_ISENTO]
                        ElseIf cCodVal == "OUT"
                            nValor := aTribgen[nX][TG_IT_LF][TG_LF_OUTROS]
                        ElseIf cCodVal == "DIF"
                            nValor := aTribgen[nX][TG_IT_LF][TG_LF_DIFERIDO]
                        Endif
                        //vALOR OUTROS
                        If cCodValOu == "BAS"
                            nValOut := aTribgen[nX][TG_IT_BASE]
                        ElseIf cCodValOu == "ALQ"
                            nValOut := aTribgen[nX][TG_IT_ALIQUOTA]
                        ElseIf cCodValOu == "VAL"
                            nValOut := aTribgen[nX][TG_IT_VALOR]
                        ElseIf cCodValOu == "ISE"
                            nValOut := aTribgen[nX][TG_IT_LF][TG_LF_ISENTO]
                        ElseIf cCodValOu == "OUT"
                            nValOut := aTribgen[nX][TG_IT_LF][TG_LF_OUTROS]
                        ElseIf cCodValOu == "DIF"
                            nValOut := aTribgen[nX][TG_IT_LF][TG_LF_DIFERIDO]
                        Endif

                        If nValor > 0 .Or. nValOut > 0
                            cCFOP       := aNfItem[nZ][IT_CF] 
                            cDescod     := aCodLan[nI][12]
                            cLivro      := aNFItem[nZ][IT_TS][TS_NRLIVRO]
                            cCodDes     := aCodLan[nI][10]   //CJA_TXTDSC
                            cCodObs     := aCodLan[nI][09]   //CJA_CODCPL
                            cCodOLan    := aCodLan[nI][08]   //CJA_CODMSG
                            cGeracum    := aCodLan[nI][11]   //CJA_GERMSG
                            cIFCOMP     := "CONFIG"

                            if Len(aCodLan[nI]) > 14
                                cTipoLanc   := aCodLan[nI][15]
                                if cTipoLanc == "1"
                                    nPercLanc := nAlqCal
                                endif
                            endIf

                            // Se tiver documento referenciado, verifica se precisa da exclusao dos lançamentos do doc. original ...
                            nRecDelCDA := 0

                            if Len(aCodLan[nI]) >= 17 .and. lCpoSubst .and. aNFCab[NF_OPERNF] == 'S' .and. !empty(aNFItem[nZ][IT_RECORI]); 
                                         .and. ( alltrim(aCodLan[nI][16]) $ "2" .or. alltrim(aCodLan[nI][17]) $ "2" ) // CC6_SUBST ou CDO_SUBST for igual a "2" (Sub. Dentro do Periodo)
                                nRecDelCDA := CheckCDADocOriginal( Alltrim(aCodLan[nI][2]) , aNFItem[nZ], SF2->F2_DTDIGIT )
                            endif

                            If Alltrim(aCodLan[nI][7]) == "01"
                                cCMPOrig    := "2"
                            ElseIf Alltrim(aCodLan[nI][7]) == "02"
                                cCMPOrig    := "4"
                            ElseIf Alltrim(aCodLan[nI][7]) == "04"
                                cCMPOrig    := "3"
                            Else 
                                cCMPOrig    := "1"
                            EndIf

                            aAdd(aGrava, {;
                            cItem,;     //1  - Item
                            cCodLan,;   //2  - Codigo de Lancamento
                            "1",;       //3  - Sistema
                            nBasCal,;   //4  - Base de Calculo
                            nAlqCal,;   //5  - Aliquota
                            nValor,;    //6  - Valor Calculado
                            cSeq,;      //7  - Sequencia
                            cIFCOMP,;   //8  - Informacoes Complementares
                            cTpLanc,;   //9  - Tipo de Utilidade do Lancamento
                            "",;        //10 - Gravação do valor em ICMS ou OUTROS
                            cCmp0460,;  //11 - Complemento para Registro 0460
                            cCodRefl,;  //12 - Codigo Reflexo
                            cGeraGNRE,; //13 - Gera GNRE
                            cCMPOrig,;  //14 - Campo origem CC7
                            cCFOP,;     //15 - CFOP
                            cLivro,;    //16 - lIVRO
                            cDescod,;   //17 - Descrição DO CÓDIGO
                            cCodDes,;   //18 - Descrição Mensagem bloco 0460
                            cCodObs,;   //19 - Descrição Mensagem Bloco X195
                            cCodOLan,;  //20 - Descrição Mensagem Bloco X197
                            nValOut,;   //21
                            cRegCalc,;  //22
                            cOpBase,;   //23
                            cOpAliq,;   //24
                            cGerAcum,;  //25
                            cTipoLanc,; //26 Tipo do lançamento 1=Credito Presumido; 2=Isenção; 3=Redução de Base de Calculo;
                            nPercLanc,; //27 Percentual utilizado para calculo
                            nRecDelCDA}) //28 Recno do CDA do doc original que precisa ser excluido pela xFisCDA se esses ajustes forem gravados.

                            cSeq := Soma1(cSeq)
                        EndIf
                    Endif
                Next nI
            Endif
        Next nX
    Endif
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecCja

Função responsável por validar campos das tabelas CJA, CJ9 e novos campos das tabelas CDA e CDV, para serem utilizados nas novas funções
da regra de lançamento do configurador

@author Adilson Roberto.
@since 22/02/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function ExecCja(aPos)
Local lExec := .F.

Default aPos := {}

lExec := Mafiscache('ExecCja',,{|| ;
    fisExtCmp('12.1.2310', .T.,'CDA','CDA_REGCAL') .And.;
    fisExtCmp('12.1.2310', .T.,'CDA','CDA_VLOUTR') .And.;
    fisExtCmp('12.1.2310', .T.,'CDA','CDA_CODMSG') .And.;
    fisExtCmp('12.1.2310', .T.,'CDA','CDA_CODCPL') .And.;
    fisExtCmp('12.1.2310', .T.,'CDA','CDA_TXTDSC') .And.;
    fisExtCmp('12.1.2310', .T.,'CDA','CDA_OPBASE') .And.;
    fisExtCmp('12.1.2310', .T.,'CDA','CDA_OPALIQ') .And.;
    fisExtCmp('12.1.2310', .T.,'CDV','CDV_REGCAL') .And.;
    fisExtCmp('12.1.2310', .T.,'CDV','CDV_VLOUTR') .And.;
    fisExtCmp('12.1.2310', .T.,'CDV','CDV_CODMSG') .And.;
    fisExtCmp('12.1.2310', .T.,'CDV','CDV_CODCPL') .And.;
    fisExtCmp('12.1.2310', .T.,'CDV','CDV_TXTDSC') .And.;
    fisExtCmp('12.1.2310', .T.,'CDV','CDV_OPBASE') .And.;
    fisExtCmp('12.1.2310', .T.,'CDV','CDV_OPALIQ') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_FILIAL') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_ID')     .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_CODREG') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_ID_CAB') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_REGCAL') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_CODTAB') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_CODTAB') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_CODLAN') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_VIGINI') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_VIGFIM') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_NFBASE') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_NFALIQ') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_VALOR')  .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_VLOUTR') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_CODCPL') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_CODMSG') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_TXTDSC') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_GERMSG') .And.;
    fisExtCmp('12.1.2310', .T.,'CJ9','CJ9_FILIAL') .And.;
    fisExtCmp('12.1.2310', .T.,'CJ9','CJ9_ID')     .And.;
    fisExtCmp('12.1.2310', .T.,'CJ9','CJ9_CODREG') .And.;
    fisExtCmp('12.1.2310', .T.,'CJ9','CJ9_DESCR')  .And.;
    fisExtCmp('12.1.2310', .T.,'CJ9','CJ9_VIGINI') .And.;
    fisExtCmp('12.1.2310', .T.,'CJ9','CJ9_VIGFIM') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_GUIA')   .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_TITULO') .And.;
    fisExtCmp('12.1.2310', .T.,'CJA','CJA_TITGUI') .And.;
    fisExtCmp('12.1.2310', .T.,'CDA','CDA_AGRLAN') .And.;
    fisExtCmp('12.1.2310', .T.,'CDV','CDV_AGRLAN');
    },.T.)

Return lExec

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckCDADocOriginal

Função responsável por verificar se os códigos de lançamento do documento original possuem o campo CC6_SUBST ou CDO_SUBST igual a "2",
se sim, então deleta esses códigos do documento original.

@author Douglas Dourado
@since 02/10/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Function CheckCDADocOriginal(cCodLan, aNfItem, dEmissaoSub )

Local aAreaAnt  := FwGetArea()
Local nRecno    := 0 as number
Local nRecnoCDA := 0 as number

DEFAULT dEmissaoSub := dDataBase

If Empty(dEmissaoSub)
    dEmissaoSub := dDataBase
EndIf

dbSelectArea("SD2")
SD2->( dbGoto( aNfItem[IT_RECORI] ))

If SD2->(RecNo()) == aNfItem[IT_RECORI]
    If  AnoMes(SD2->D2_EMISSAO) == AnoMes(dEmissaoSub) 
        
        nRecnoCDA := GetCDARecToDel(cCodLan , aNfItem , SD2->D2_ITEM, SD2->D2_CLIENTE, SD2->D2_LOJA)

        If !EmpTy(nRecnoCDA) // Ao passar aqui pela segunda vez, o registro já vai estar deletado, entao ja pula ...
            nRecno := nRecnoCDA
        EndIf

    EndIf
Endif    

FwRestArea(aAreaAnt)
ASize(aAreaAnt,0)

Return nRecno

//-------------------------------------------------------------------
/*/{Protheus.doc} DeleteCDAOrig

Função responsável por usar o recno encontrado pela GetCDARecToDel(), posicionar e apagar o mesmo ...

@author Douglas Dourado
@since 02/10/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Function DeleteCDAOrig( nRecno )
Local aAreaAnt := CDA->(FWGetArea())

dbSelectArea("CDA")
CDA->( dbGoto(nRecno) )  // Posiciona no registro a ser deletado ...  

RecLock('CDA', .F.)
    CDA->(DbDelete())
CDA->(MsUnlock())    

FwRestArea(aAreaAnt)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCDARecToDel
Função responsável por buscar o recno do CDA que precisa ser deletado, baseado no código de lançamento, item, cliente, loja e documento.
@author Douglas Dourado
@param cCodLan Código de lançamento
@param aNfItem Array do item da nota fiscal
@param cItem Código do item
@param cClifor Código do cliente/fornecedor
@param cLoja Código da loja
@since 02/10/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------

Static Function GetCDARecToDel( cCodLan , aNfItem , cItem, cClifor, cLoja )
Local cQueryCDA  := ""	as character
Local nRecnoCDA  := ""	as character
Local oExecCDA  		as object

cQueryCDA := " SELECT CDA.R_E_C_N_O_ RECNO FROM "+RetSqlName('CDA')+" CDA "
cQueryCDA += " WHERE CDA_FILIAL = ? AND CDA.CDA_NUMERO = ? AND CDA.CDA_SERIE = ? AND CDA.CDA_CLIFOR = ? AND CDA.CDA_LOJA = ? AND CDA.CDA_CODLAN = ? "
cQueryCDA += " AND CDA.CDA_NUMITE = ? AND CDA.D_E_L_E_T_ = ? "

oExecCDA := FwExecStatement():New(cQueryCDA)

oExecCDA:SetString(1,xFilial("CDA"))
oExecCDA:SetString(2, aNfItem[IT_NFORI])
oExecCDA:SetString(3, aNfItem[IT_SERORI])
oExecCDA:SetString(4, cClifor)
oExecCDA:SetString(5, cLoja)
oExecCDA:SetString(6, cCodLan)
oExecCDA:SetString(7, cItem)
oExecCDA:SetString(8, ' ')

nRecnoCDA := oExecCDA:ExecScalar('RECNO')

oExecCDA:Destroy()
oExecCDA := nil

Return(nRecnoCDA)
