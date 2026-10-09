#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA324.CH"
#Include "FWEVENTVIEWCONSTS.CH"

Static _oHashUF := Nil
Static oJsUFFil := Nil

#DEFINE DTNICIO  1
#DEFINE DTFINAL  2
#DEFINE TPPERIOD 5
#DEFINE TRIBUTOS 6
#DEFINE CODMUN   1
#DEFINE UF       2
#DEFINE NMCONT   3

#DEFINE FIL_CENTRALIZADORA   7

//Parametros do SCHEDULE
#DEFINE aFIL    1
#DEFINE aPARAM  2
#DEFINE CHAVE   3
#DEFINE EMPRESA 4
#DEFINE FILIAL  5

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA324Apu()
Apuração do Índice de Participação dos Municípios (IPM)
Utilizado no 1400 do SPED Fiscal

@param	aFil     - Array   - {Grupo, Filial, Nome Fil, Nome Grupo, CNPJ}
@param	aParams  - Array   - (dDataIni, dDataFim, cSelFil, cCNPJIE, cTPPeriod, cFilial, aInfoApu)
@param	lRet     - Logical - Indica se houve êxito na apuração.
@param	cMsgProc - String  - Indica se houve algum aviso de incosistência.
@param  lExecSch - Logical - Indica se a execução é por SmartSchedule
@Return Nil

@author Denis Souza / Carlos Pister
@since 21/08/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------
Function FISA324Apu(aFil, aParams, lRet, cMsgProc, lExecSch, lAuto)

Local cFilCentr  as character
Local aTrbSel    as array
Local cAliasIPM  as character
Local cIdApur    as character
Local lMensal    as logical
Local aAreaSM0   as array
Local nX         as numeric
Local aParamQry  as array
Local cAliasMov  as character
Local cCredDeb   as character
Local nValTrib   as numeric
Local lIntTms	 as logical
Local aRateio    as array
Local aCalcRat   as array
Local cChvCKF    as character
Local cFilCKF    as character
Local nPos       as numeric
Local oPrepIPM   as object
Local oPrepMOV   as object
Local oPrepSIM   as object
Local cLastChv   as character
Local lGrvRat    as logical
Local cFilCC2    as character
Local aContrib   as array
Local cChvCtrb   as character
Local aDados     as array
Local cCodMun    as character
Local cUF        as character
Local cNomeMun   as character
Local lBulk      as logical
Local nTmCalcR   as numeric
Local nCountF2D  as numeric
Local nTotItens  as numeric
Local cMsg       as character
Local lGrvCKH    as logical
Local cUfFil     as character
Local lGrvCKI    as logical
Local oInsertCKI as object
Local aStructCKI as array

Default aFil     := {}
Default aParams  := array(8)
Default lRet     := .T.
Default cMsgProc := ""
Default lExecSch := .F.
Default lAuto    := .F.

cFilCentr  := aParams[FIL_CENTRALIZADORA] //Filial selecionada antes de abrir a wizard, pode ser diferente da logada.
aTrbSel    := {}
cAliasIPM  := ""
cIdApur    := ""
lMensal    := .T.
aAreaSM0   := {}
nX         := 0
aParamQry  := {}
cAliasMov  := ""
cCredDeb   := ""
nValTrib   := 0
lIntTms	   := IntTMS()
aRateio    := {}
aCalcRat   := {}
cChvCKF    := ""
cFilCKF    := ""
nPos       := 0
oPrepIPM   := Nil
oPrepMOV   := Nil
cLastChv   := ""
lGrvRat    := .F.
cFilCC2    := xFilial("CC2")
aContrib   := {}
cChvCtrb   := ""
aDados     := {}
cCodMun    := ""
cUF        := ""
cNomeMun   := ""
lBulk      := .F.
nTmCalcR   := 0
lGrvCKH    := .F.
cUfFil     := ""
nCountF2D  := 0
nTotItens  := 0
cMsg       := ""
lGrvCKI    := .F.

Fisa324Tab({{"CC2",1},{"CLN",1},{"CKD",1},{"CKE",1},{"CKF",1},{"CKG",2},{"CKH",1},{"CKI",1}})
if lIntTms
    Fisa324Tab({{"DT6",1},{"DUY",1}})
endif

if len(aFil) == 0 //Se nao houver filial selecionada adiciona a centralizadora no aFil
    aadd(aFil,{cEmpAnt,cFilCentr})
endif

aTrbSel := StrToKArr(aParams[TRIBUTOS], "|") //tributos selecionados na wizard

cAliasIPM := Fisa324CKD( @oPrepIPM, aParams, cFilCentr, aTrbSel )

if (cAliasIPM)->(!Eof())

    If _oHashUF == Nil
        Fisa324UF()
    EndIf
   
    aStructCKI := aBulkField({"CKI_FILIAL","CKI_IDDETA","CKI_IDUNIQ","CKI_UFDOC","CKI_CODIPM","CKI_FILDOC","CKI_CODMUN","CKI_REGAPU","CKI_CODTRI","CKI_NF","CKI_SERIE","CKI_TPMOV","CKI_ITEM","CKI_DTENT", "CKI_DTEMIS","CKI_UFNOTA","CKI_UFPART","CKI_MUNPAR","CKI_UFORIG","CKI_MUNORI","CKI_UFDEST","CKI_MUNDES","CKI_VLCONT","CKI_VLTOT", "CKI_BSECAL","CKI_ALIQ","CKI_VLTRIB","CKI_CLIENT","CKI_FORNEC","CKI_CODCLI","CKI_CODFOR","CKI_LOJA","CKI_REGCAL"}) 

    if oJsUFFil == Nil
        oJsUFFil := JsonObject():New()
    endif

    cIdApur := aParams[8][1]

    cLastChv := (cFilCentr + (cAliasIPM)->(CKE_UF+CKE_CODIPM))

    While (cAliasIPM)->(!Eof()) //percorre os itens UF x COD IPM para a competencia

        if !(cLastChv == cFilCentr + (cAliasIPM)->(CKE_UF+CKE_CODIPM))
            cLastChv := (cFilCentr + (cAliasIPM)->(CKE_UF+CKE_CODIPM))
            //Antes de iniciar a proxima chave do CODIGO IPM grava o rateio em memoria da chave anterior
            if lGrvRat .And. Len(aRateio) > 0 .And. Len(aCalcRat) > 0
                Fisa324RAT( aRateio, aCalcRat )
                aSize(aRateio ,0)
                aSize(aCalcRat,0)
                lGrvRat := .F.
                lGrvCKH := .T.
            endif
        endif

        lMensal := .T.
        if CLN->(DbSeek(xFilial("CLN")+(cAliasIPM)->CKE_UF+(cAliasIPM)->CKE_CODIPM))
            if CLN->CLN_TIPO == "2" //1=Mensal; 2=Anual
                lMensal := .F.      //vazio continua como mensal
            endif
        endif
        /*
        Através da UF e Código DIPAM posicionar na CLN e verificar se será mensal ou anual.
        Ex: Se existir 4 linhas na CKE e os códigos DIPAM forem mensais e existir uma única anual
        e se a opção selecionada da wizard for anual, a query abaixo irá rodar apenas para o DIPAM anual
        ( por isso o else faz o skip e o loop para nao processar as demais).
        */
        if (aParams[TPPERIOD] == '1' .And. lMensal) .Or. (aParams[TPPERIOD] == '2' .And. !lMensal)
            if (cAliasIPM)->CKE_CONSMU == '5' //Rateio
                if len(aRateio) == 0 //Adiciona apenas uma vez por uf+codigo ipm totalizando o 100%, quando a chave mudar o aRateio ficara vazio novamente.
                    cFilCKF := PadR(xFilial("CKF",cFilCentr), GetSX3Cache("CKF_FILIAL", "X3_TAMANHO"))
                    cChvCKF := cFilCKF + (cAliasIPM)->( CKE_ID + CKE_UF + CKE_CODIPM )
                    if CKF->(DbSeek(cChvCKF))
                        while CKF->(!Eof()) .And. CKF->(CKF_FILIAL+CKF_IDIPM+CKF_UF+CKF_CODIPM) == cChvCKF
                            aAdd(aRateio,{ cChvCKF, CKF->CKF_CODMUN, CKF->CKF_DESCMU, CKF->CKF_RATEIO } )
                            CKF->(dbskip())
                        enddo
                    endif
                endif
            endif
            //////////////////////////////////////////////
            // DADOS CONTRIBUINTE (FILIAL CENTRALIZADORA//
            //////////////////////////////////////////////
            if len(aContrib) == 0
                aadd(aContrib,{Alltrim(SM0->M0_CODMUN),'',''})
                if len(aContrib[1][CODMUN]) == 7
                    aContrib[1][UF] := SubSTr(aContrib[1][CODMUN],1,2) //Ex: 35
                    aContrib[1][CODMUN] := SubSTr(aContrib[1][CODMUN],3,5)
                    _oHashUF:Get( aContrib[1][UF], @aContrib[1][UF] ) //Converte 35 e volta no formato esperado SP (necessario para o seek)
                else //senao for tamanho 7 considera a UF do M0_ESTENT
                    aContrib[1][UF] := SM0->M0_ESTENT //Ex: SP(formato esperado ex: SP)
                endif

                cChvCtrb := cFilCC2 + aContrib[1][UF] + aContrib[1][CODMUN]
                if CC2->(DbSeek(cChvCtrb)) //CC2_FILIAL, CC2_EST, CC2_CODMUN
                    aContrib[1][NMCONT] := Alltrim(CC2->CC2_MUN)
                endif
            endif

            ///////////////////////////////////////////////////////////
            // PROCESSAMENTO POR FILIAL SELECIONADA OU CENTRALIZADORA//
            ///////////////////////////////////////////////////////////
            aAreaSM0 := SM0->(GetArea())

            For nX := 1 to Len(aFil)
                SM0->(DbGoTop())
                SM0->(MsSeek(aFil[nX][1]+aFil[nX][2], .T.))
                cFilAnt := FWGETCODFILIAL

                cUfFil := GetUFFil(alltrim(cFilAnt))

                If cUfFil == (cAliasIPM)->CKE_UF

                    aParamQry := { aParams[DTNICIO], aParams[DTFINAL] }
                    cAliasMov := Fisa324F2D( @oPrepMOV, aParamQry, aTrbSel, lIntTms, (cAliasIPM)->CKE_REGCAL, (cAliasIPM)->CKE_CONSMU, cUfFil )

                    //Chamada for pelo SMART SCHEDULE
                    if lExecSch
                        //Calcula a quantidade de registros
                        COUNT to nCountF2D
                        
                        //Posiciona no topo da tabela
                        DbGotop()
                    EndIf

                    If oInsertCKI == Nil
                        oInsertCki := FwBulk():New(RetSQLName("CKI"))
                        oInsertCki:SetFields(aStructCKI)
                    EndIf

                    While (cAliasMov)->(!Eof())

                        cUF      := ''
                        cCodMun  := ''
                        cNomeMun := ''
                        
                        Fisa324CMU( lIntTms, cAliasIPM, cAliasMov, @cUF, @cCodMun, @cNomeMun, aContrib )                        

                        If cUfFil == cUF .or. (cAliasIPM)->CKE_CONSMU $ '4|5'

                            cCredDeb := Fisa324CRD(cAliasMov) //Operacao selecionada c/ regra apuracao amarrada na regra de calculo

                            IF !Empty(cCredDeb)

                                nValTrib := (cAliasMov)->F2D_VALOR //Vl Calculado Sobre a Base (F2D_BASE = 10000	F2D_ALIQ = 1 F2D_VALOR = 100)

                                //////////////////
                                // Grava ITENS  //
                                //////////////////
                                If cCredDeb == "2"
                                    nValTrib := (nValTrib * -1) //Se for credito, inverte o valor do tributo
                                EndIf

                                If (cAliasIPM)->CKE_CONSMU == '5' //Rateio
                                    lGrvCKI := .T.
                                    nTmCalcR := len(aCalcRat)
                                    if nTmCalcR == 0
                                        aadd( aCalcRat, { cFilCentr               ,;  //01
                                                        cIdApur                 ,;  //02
                                                        (cAliasIPM)->CKE_UF     ,;  //03
                                                        (cAliasIPM)->CKE_CODIPM ,;  //04
                                                        cCredDeb                ,;  //05
                                                        nValTrib                } ) //06
                                    else
                                        aCalcRat[nTmCalcR][6] += nValTrib //Acumula o valor do tributo
                                    endif
                                Else
                                    if !Empty(cCodMun)
                                        lGrvCKI := .T.
                                        nPos := Ascan(aDados,{|x|AllTrim(x[1]) == Alltrim((cFilCentr + (cAliasIPM)->(CKE_UF+CKE_CODIPM+cCodMun) ))})
                                        If nPos > 0
                                            aDados[nPos][08] += nValTrib //Acumula o valor do tributo
                                        Else
                                            aAdd(aDados,{ Alltrim( cFilCentr + (cAliasIPM)->(CKE_UF+CKE_CODIPM+cCodMun) ),; //01 Chave {Fil Centr. + UF + Cod IPM + Cod Mun}
                                                            cFilCentr,;                                              //02 Filial Centralizadora
                                                            cIdApur,;                                                //03 ID Apuração
                                                            cUF,;                                                    //04 UF
                                                            (cAliasIPM)->CKE_CODIPM,;                                //05 Codigo IPM
                                                            cCodMun,;                                                //06 Cod Municipio
                                                            cNomeMun,;                                               //07 Nome Municipio
                                                            nValTrib } )                                             //08 Valor do tributo
                                        EndIf
                                    EndIf
                                EndIf
                                If lGrvCKI
                                    Fisa324CKI(cFilCentr, cIdApur, cAliasIPM, cAliasMov, cUF, cCodMun, cNomeMun, lIntTms, @lRet, @cMsgProc, lAuto, oInsertCKI)
                                    lGrvCKI := .F.
                                EndIf
                            EndIf

                            if lExecSch
                                nTotItens++
                                Fis324Even(nCountF2D, nTotItens)
                            EndIf
                        EndIf 
                        (cAliasMov)->(dbSkip())
                    EndDo

                    (cAliasMov)->(dbCloseArea())

                    If oPrepMOV != Nil
                        oPrepMOV:Destroy()
                        freeobj(oPrepMOV)
                    EndIf

                    If lAuto
                       oInsertCki:CERROR := STR0015//'Simula erro de gravação'
                    Endif

                    If !Empty(oInsertCki:GetError()) .or. !oInsertCki:Close()
                        lRet := .F.
                        if Empty(cMsgProc)
                            cMsgProc := STR0005//"A apuração foi realizada parcialmente, houve a(s) seguinte(s) inconsistência(s): "
                        endif
                        if len(cMsgProc) <= 200
                            cMsgProc += Alltrim(oInsertCki:GetError())
                            cMsgProc := Alltrim(SubStr(cMsgProc,1,200))
                        endif
                    EndIf

                    oInsertCKI:Destroy()
                    FreeObj(oInsertCki)
                    oInsertCKI:= Nil

                EndIf 
            Next nX

            //Restauro a área da SM0 e o cFilAnt pois daqui para baixo o processamento é feito na visão da filial centralizadora.
            RestArea(aAreaSM0)
            cFilAnt := FWGETCODFILIAL

        else //Registro que nao serao considerados no processamento "pula", pois foi selecionado anual\mensal e o tipo da CNL eh divergente.
            (cAliasIPM)->(DbSkip())
            loop
        endif

        if (cAliasIPM)->CKE_CONSMU == '5'
            lGrvRat := .T.
        endif
        (cAliasIPM)->(dbSkip())
    EndDo

    //Antes de fechar grava o ultimo rateio em memoria
    if lGrvRat .And. Len(aRateio) > 0 .And. Len(aCalcRat) > 0
        Fisa324RAT( aRateio, aCalcRat )
        aSize(aRateio ,0)
        aSize(aCalcRat,0)
        lGrvRat := .F.
        lGrvCKH := .T.
    ElseIf Len(aDados) > 0 .and. !lAuto
        Fisa324CKH( aDados )
        aSize(aDados ,0)
        lGrvCKH := .T.
    endif

    //Se nao houve apuracao pois com as regra de calculo informada nao localizou movimentos
    //ou se a apuracao final gerou credito deveremos verificar se gera valor simbolico
    If len(aContrib) > 0
        Fisa324SIM(@oPrepSIM,cAliasIPM,cIdApur,aContrib, @lGrvCKH, aFil,aParams)
    Endif

    If oPrepSIM != Nil
        oPrepSIM:Destroy()
        freeobj(oPrepSIM)
    EndIf

    If !lGrvCKH
        lRet := .F.
        cMsgProc := STR0014 //O período não possui registros a serem apurados.
    EndIf

    FwFreeArray(aStructCKI)

    (cAliasIPM)->(dbCloseArea())
else
    lRet := .F.
    cMsgProc := STR0001 //Os cadastros do Código IPM não foram localizados.
endif

if Select( cAliasIPM ) > 0
    (cAliasIPM)->(dbCloseArea())
endif

If oPrepIPM != Nil
    oPrepIPM:Destroy()
	freeobj(oPrepIPM)
EndIf


If oJsUFFil != Nil
    FreeObj(oJsUFFil)
	oJsUFFil := Nil
EndIf

if lExecSch
    cMsg := STR0010 //"Processo de apuração: 100%"
    cMsgProc += CRLF + cMsg

    //Executa o event Viewr para informar o fim da apuração
    FisExecEv( cMsgProc)

endIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa324CKD()
Filtra o código IPM dentro do período informado na wizard e os respectivos
UF + Cod Ipm + Regra de cálculo.

@param	oPrepIPM  - objeto  - objeto para executar a query
@param	aParamQry - Array   - parâmetros
@param	cFilCentr - String  - filial centralizadora
@param	aTrbSel   - Array   - tributos selecionados na wizard
@Return cAlsRet   - String  - alias temporario

@author Denis Souza
@since 21/08/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function Fisa324CKD( oPrepIPM, aParamQry, cFilCentr, aTrbSel )

Local cAlsRet as character
Local aBind   as array
Local nX      as numeric
Local cQry    as character

Default oPrepIPM  := Nil
Default aParamQry := {}
Default cFilCentr := ''
Default aTrbSel   := {}

cAlsRet := ""
aBind   := {}
nX      := 0
cQry    := ""

cQry := "SELECT CKE.CKE_FILIAL, CKE.CKE_ID, CKE.CKE_UF, CKE.CKE_CODIPM, CKE.CKE_REGCAL, "
cQry += "CKE.CKE_CONSMU, CKE.CKE_CONVLS, "
cQry += "F2B.F2B_REGRA, F2B.F2B_TRIB FROM "
cQry += RetSqlName("CKD") + " CKD " //REGRA DE CODIGO IPM (CABECALHO)
cQry += "INNER JOIN " + RetSqlName("CKE") + " CKE ON " //ITENS IPM (UF x COD DIPAM)
cQry += "CKE.CKE_FILIAL = CKD.CKD_FILIAL AND CKE.CKE_ID = CKD.CKD_ID AND CKE.D_E_L_E_T_ = ? "
aAdd(aBind, space(1) )
cQry += "INNER JOIN " + RetSqlName("F2B") + " F2B ON " //REGRA DE CALCULO
cQry += "F2B.F2B_FILIAL = ? AND F2B.F2B_REGRA = CKE.CKE_REGCAL "
cQry += "AND F2B.F2B_ALTERA <> ? "
cQry += "AND F2B.F2B_TRIB IN (?) " //TRIBUTOS SELECIONADOS NA WIZARD
cQry += "AND F2B.D_E_L_E_T_ = ? "
aAdd(aBind, xFilial("F2B", cFilCentr) )
aAdd(aBind, "1" )
aAdd(aBind, aTrbSel )
aAdd(aBind, space(1) )
cQry += "WHERE CKD.CKD_FILIAL = ? AND CKD.CKD_VIGINI <= ? AND ( CKD.CKD_VIGFIM = ? OR CKD.CKD_VIGFIM >= ? ) AND CKD.D_E_L_E_T_ = ? "
aAdd(aBind, xFilial("CKD", cFilCentr) )
aAdd(aBind, DtoS(aParamQry[1]) )
aAdd(aBind, space(1) )
aAdd(aBind, DtoS(aParamQry[2]) )
aAdd(aBind, space(1) )
//A Prioridade começa por regras com UF + Codigo IPM que possui Rateio CKE_CONSMU (5=Rateio,4=Ctrb,3=Part,2=Dest,1=Org)
cQry += "ORDER BY CKE.CKE_FILIAL, CKE.CKE_ID, CKE.CKE_UF, CKE.CKE_CODIPM, CKE.CKE_CONSMU DESC, CKE.CKE_REGCAL "

cQry := ChangeQuery(cQry)

oPrepIPM := FwExecStatement():New(cQry)

For nX := 1 To Len(aBind)
	If ValType(aBind[nX]) == 'C'
		oPrepIPM:setString(nX, aBind[nX])
    Elseif ValType(aBind[nX]) == 'A'
        oPrepIPM:setIn(nX, aBind[nX])
	EndIf
Next nX

cAlsRet := GetNextAlias()

oPrepIPM:OpenAlias(cAlsRet) //oPrepIPM:getfixquery()
dbSelectArea(cAlsRet)
(cAlsRet)->(dbGoTop())

Return cAlsRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa324F2D()
Função responsável por montar a querie utilizada pela apuração por FILIAL.
Com particularidades de IPM ( SF1\SF2\SA1\SA2\DT6 )

Importante como o filtro eh por regra ja reduz bastante resultado
entao nao precisamos fazer uma query so pra entrada e outra para saida
semelhante ao do proprio spedfiscal que executa a query conforme array {'E','S'}

A query sera executada por filial selecionada com o ambiente posicionado 
e atribuido no cFilAnt. SM0 ja posicionada, por isso somente XFILIAL
e nao por range.

@param	oPrepMOV  - objeto  - objeto para executar a query
@param	aParamQry - Array   - parâmetros
@param	aTrbSel   - Array   - tributos selecionados na wizard
@param	lIntTms   - Boolean - integracao com tms
@param	cRegCal   - String - filtro com a regra do cálculo
@Return cAlsRet   - String  - alias temporario

@author Denis Souza
@since 21/08/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function Fisa324F2D( oPrepMOV, aParamQry, aTrbSel, lIntTms, cRegCal, cOpeMun, cUfFil )

Local cAlsRet  as character
Local aBind    as array
Local nX       as numeric
Local cQry     as character
Local cXFilCC2 as character

Default oPrepMOV  := Nil
Default aParamQry := {}
Default aTrbSel   := {}
Default lIntTms   := .F.
Default cRegCal   := ''
Default cOpeMun   := ''
Default cUfFil    := ''

cAlsRet  := ""
aBind    := {}
nX       := 0
cQry     := ""
cXFilCC2 := xFilial("CC2")

//Tributos Genéricos Calculados
cQry := "WITH MUNICIPIO AS ( SELECT CC2.CC2_EST, CC2.CC2_MUN, CC2.CC2_CODMUN FROM (SELECT CC2.CC2_EST, CC2.CC2_CODMUN, CC2.CC2_MUN, ROW_NUMBER() OVER ( PARTITION BY CC2.CC2_EST, CC2.CC2_CODMUN ORDER BY CC2.CC2_MUN ) RN "
cQry += "FROM " + RetSqlName("CC2") + " CC2 WHERE CC2.CC2_FILIAL = ? AND CC2.D_E_L_E_T_ = ? ) CC2 WHERE CC2.RN = ? ) "
aAdd(aBind, cXFilCC2 )
aAdd(aBind, space(1) )
aAdd(aBind, "1" )

if lIntTms
    cQry += ",REGIOES AS ( SELECT DUY.DUY_FILIAL, DUY.DUY_GRPVEN, DUY.DUY_EST, DUY.DUY_CODMUN FROM ( SELECT DUY.DUY_FILIAL, DUY.DUY_GRPVEN, DUY.DUY_EST, DUY.DUY_CODMUN, ROW_NUMBER() OVER ( PARTITION BY DUY.DUY_CODMUN ORDER BY DUY.DUY_EST ) RN "
    cQry += "FROM " + RetSqlName("DUY") + " DUY WHERE DUY.DUY_FILIAL = ? "
    aAdd(aBind, xFilial("DUY") )
    If cOpeMun $ "1|2" //ORIGEM|DESTINO
        cQry += "AND DUY.DUY_EST = ? "
        aAdd(aBind, cUfFil )
    EndIf
    cQry += "AND DUY.D_E_L_E_T_ = ? ) "
    aAdd(aBind, space(1) )
    cQry += " DUY WHERE DUY.RN = ? ) "
    aAdd(aBind, "1" )
endif

cQry += "SELECT F2D.F2D_FILIAL, SFT.FT_TIPOMOV, SFT.FT_TIPO, SFT.FT_ENTRADA, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ITEM, SFT.FT_CLIEFOR, SFT.FT_LOJA, "
cQry += "SFT.FT_EMISSAO, SFT.FT_TOTAL, SFT.FT_VALCONT, SFT.FT_ESTADO, "
cQry += "F2B.F2B_ID, F2B.F2B_REGRA, F2B.F2B_TRIB, F2G.F2G_ID, F2G.F2G_CODIGO, F2G.F2G_ENTRAD, F2G.F2G_SAIDA, F2D.F2D_BASE, F2D.F2D_ALIQ, F2D.F2D_VALOR, "
//ORIGEM
cQry += "SF1.F1_UFORITR, SF1.F1_MUORITR, MUNF1ORI.CC2_MUN NF1ORIMN, " //Nome do município (F1_MUORITR)
cQry += "SF2.F2_UFORIG, SF2.F2_CMUNOR, MUNF2ORI.CC2_MUN NF2ORIMN, "   //Nome do município (F2_CMUNOR)
//DESTINO
cQry += "SF1.F1_UFDESTR, SF1.F1_MUDESTR, MUNF1DES.CC2_MUN NF1DESMN, " //Nome do município (F1_MUDESTR)
cQry += "SF2.F2_UFDEST, SF2.F2_CMUNDE, MUNF2DES.CC2_MUN NF2DESMN, "   //Nome do município (F2_CMUNDE) 

if lIntTms
    //ORIGEM
    cQry += "DT6.DT6_CDRORI, DUYORI.DUY_EST DUYUFORI, DUYORI.DUY_CODMUN DUYMCORI, DUYMNORI.CC2_MUN NDUYMORI, "
    //CALCULO (DT6_CDRCAL ao invés do DT6_CDRDES)
    cQry += "DT6.DT6_CDRCAL, DUYCAL.DUY_EST DUYUFCAL, DUYCAL.DUY_CODMUN DUYMCCAL, DUYMNCAL.CC2_MUN NDUYMCAL, "
endif

//PARTICIPANTE
cQry += "SA1.A1_EST, SA1.A1_COD_MUN, MUNSA1.CC2_MUN NA1MNC, SA1.A1_NOME, "  //Nome do município (A1_COD_MUN)
cQry += "SA2.A2_EST, SA2.A2_COD_MUN, MUNSA2.CC2_MUN NA2MNC, SA2.A2_NOME  "  //Nome do município (A2_COD_MUN)

cQry += "FROM " + RetSqlName("F2D") + " F2D "

/* As notas lançadas além do tributo genérico IPM devem ter ICMS na amarracao com a SFT */
cQry += "INNER JOIN " + RetSqlName("SFT") + " SFT ON SFT.FT_FILIAL = ? AND SFT.FT_IDTRIB = F2D.F2D_IDREL "
cQry += "AND SFT.FT_ENTRADA BETWEEN ? AND ? "
cQry += "AND ( SFT.FT_BASEICM > ? OR SFT.FT_ISENICM > ? OR SFT.FT_OUTRICM > ? ) AND SFT.D_E_L_E_T_ = ? "
aAdd(aBind, xFilial("SFT") )
aAdd(aBind, DtoS(aParamQry[DTNICIO]))
aAdd(aBind, DtoS(aParamQry[DTFINAL]))
aAdd(aBind, 0 )
aAdd(aBind, 0 )
aAdd(aBind, 0 )
aAdd(aBind, space(1) )

cQry += "LEFT JOIN " + RetSqlName("SF2") + " SF2 ON SF2.F2_FILIAL = ? AND SF2.F2_DOC = SFT.FT_NFISCAL AND SF2.F2_SERIE = SFT.FT_SERIE "
cQry += "AND SF2.F2_CLIENTE = SFT.FT_CLIEFOR AND SF2.F2_LOJA = SFT.FT_LOJA "
aAdd(aBind, xFilial("SF2") )
If cOpeMun == "1" //Origem
    cQry += "AND SF2.F2_UFORIG = ? "
    aAdd(aBind, cUfFil )
ElseIf cOpeMun == "2" //Destino
    cQry += "AND SF2.F2_UFDEST = ? "
    aAdd(aBind, cUfFil )
EndIf
cQry += "AND SF2.D_E_L_E_T_ = ? "
aAdd(aBind, space(1) )

cQry += "LEFT JOIN " + RetSqlName("SF1") + " SF1 ON SF1.F1_FILIAL = ? AND SF1.F1_DOC = SFT.FT_NFISCAL AND SF1.F1_SERIE = SFT.FT_SERIE "
cQry += "AND SF1.F1_FORNECE = SFT.FT_CLIEFOR AND SF1.F1_LOJA = SFT.FT_LOJA "
aAdd(aBind, xFilial("SF1") )
If cOpeMun == "1" //Origem
    cQry += "AND SF1.F1_UFORITR = ? "
    aAdd(aBind, cUfFil )
ElseIf cOpeMun == "2" //Destino
    cQry += "AND SF1.F1_UFDESTR = ? "
    aAdd(aBind, cUfFil )
EndIf
cQry += "AND SF1.D_E_L_E_T_ = ? "
aAdd(aBind, space(1) )

cQry += "LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = ? AND SA1.A1_COD = SFT.FT_CLIEFOR AND SA1.A1_LOJA = SFT.FT_LOJA "
cQry += "AND ( (SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?) ) OR ( SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?)) ) "
aAdd(aBind, xFilial("SA1") )
aadd(aBind, "S" )
aadd(aBind, {' ','C','I','N','S','P'} )
aadd(aBind, "E" )
aadd(aBind, { 'B', 'D' } )
If cOpeMun == "3" //PARTICIPANTE
    cQry += "AND SA1.A1_EST = ? "
    aAdd(aBind, cUfFil )
EndIf
cQry += "AND SA1.D_E_L_E_T_ = ? "
aAdd(aBind, space(1) )

cQry += "LEFT JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_FILIAL = ? AND SA2.A2_COD = SFT.FT_CLIEFOR AND SA2.A2_LOJA = SFT.FT_LOJA "
cQry += "AND ( ( SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?) ) OR ( SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?) ) ) "
aAdd(aBind, xFilial("SA2") )
aadd(aBind, "E" )
aadd(aBind, {' ','C','I','N','S','P'} )
aadd(aBind, "S" )
aadd(aBind, { 'B', 'D' } )
If cOpeMun == "3" //PARTICIPANTE
    cQry += "AND SA2.A2_EST = ? "
    aAdd(aBind, cUfFil )
EndIf
cQry += "AND SA2.D_E_L_E_T_ = ? "
aAdd(aBind, space(1) )

if lIntTms
    cQry += "LEFT JOIN " + RetSqlName("DT6") + " DT6 ON DT6.DT6_FILIAL = ? AND DT6.DT6_FILDOC = SFT.FT_FILIAL AND DT6.DT6_DOC = SFT.FT_NFISCAL AND DT6.DT6_SERIE = SFT.FT_SERIE AND DT6.D_E_L_E_T_ = ? "
    aAdd(aBind, xFilial("DT6") )
    aAdd(aBind, space(1) )
endif

//Filtra os movimentos com a regra de calculo
cQry += "INNER JOIN " + RetSqlName("F2B") + " F2B ON "

cQry += "F2B.F2B_FILIAL = ? AND F2B.F2B_REGRA = F2D.F2D_TRIB "
aAdd(aBind, xFilial("F2B") )

cQry += "AND F2B.F2B_REGRA = ? " //Regra de Cálculo Posicionada no Cadastro código IPM (CKE_REGCAL)
aAdd(aBind, cRegCal )

cQry += " AND ( "

//Verifica se está compreendido com data inicial preenchida
cQry += "( ? >= F2B.F2B_VIGINI AND F2B.F2B_VIGFIM = ? ) "
aAdd(aBind, DtoS(aParamQry[DTNICIO]))
aAdd(aBind, space(1) )

//Verifica se a data inicial está compreendida como data inicial e final preenchidos
cQry += "OR ( ? >= F2B.F2B_VIGINI AND ? <= F2B.F2B_VIGFIM ) "
aAdd(aBind, DtoS(aParamQry[DTNICIO]))
aAdd(aBind, DtoS(aParamQry[DTNICIO]))

//Caso a data final seja informada então verificaremos se está compreendida em algum cadastro com data inicial e final preenchidos.
cQry += "OR ( ? >=  F2B.F2B_VIGINI AND ? <= F2B.F2B_VIGFIM ) "
aAdd(aBind, DtoS(aParamQry[DTFINAL]))
aAdd(aBind, DtoS(aParamQry[DTFINAL]))
cQry += "OR ( ? >=  F2B.F2B_VIGINI AND F2B.F2B_VIGFIM = ? ) "
aAdd(aBind, DtoS(aParamQry[DTFINAL]))
aAdd(aBind, space(1) )
cQry += " ) "

cQry += "AND F2B.F2B_ALTERA <> ? " //Somente a regra válida no range do período acima, igualmente na expressao do filtro do F3 no campo (CKE_REGCAL<>'1').
aAdd(aBind, "1" )

cQry += "AND F2B.F2B_TRIB IN (?) " //Tributos selecionados na wizard (pode ser parcial)
aAdd(aBind, aTrbSel )

cQry += "AND F2B.D_E_L_E_T_ = ? "
aAdd(aBind, space(1) )

//Filtra somente regras de cálculos que estão vinculadas a regras de apuracao
cQry += "LEFT JOIN " + RetSqlName("F2G") + " F2G ON F2G.F2G_FILIAL = ? AND F2G.F2G_CODIGO = F2B.F2B_RAPUR AND F2G.D_E_L_E_T_ = ? "
aAdd(aBind, xFilial("F2G") )
aAdd(aBind, space(1) )

//Afim de evitar posicione e cache no laço
cQry += "LEFT JOIN MUNICIPIO MUNSA1 ON MUNSA1.CC2_EST = SA1.A1_EST AND MUNSA1.CC2_CODMUN = SA1.A1_COD_MUN "

cQry += "LEFT JOIN MUNICIPIO MUNSA2 ON MUNSA2.CC2_EST = SA2.A2_EST AND MUNSA2.CC2_CODMUN = SA2.A2_COD_MUN "

cQry += "LEFT JOIN MUNICIPIO MUNF1ORI ON MUNF1ORI.CC2_EST = SF1.F1_UFORITR AND MUNF1ORI.CC2_CODMUN = SF1.F1_MUORITR "

cQry += "LEFT JOIN MUNICIPIO MUNF2ORI ON MUNF2ORI.CC2_EST = SF2.F2_UFORIG AND MUNF2ORI.CC2_CODMUN = SF2.F2_CMUNOR "

cQry += "LEFT JOIN MUNICIPIO MUNF1DES ON MUNF1DES.CC2_EST = SF1.F1_UFDESTR AND MUNF1DES.CC2_CODMUN = SF1.F1_MUDESTR "

cQry += "LEFT JOIN MUNICIPIO MUNF2DES ON MUNF2DES.CC2_EST = SF2.F2_UFDEST AND MUNF2DES.CC2_CODMUN = SF2.F2_CMUNDE "

if lIntTms

    //REGIAO ORIGEM
    cQry += "LEFT JOIN REGIOES DUYORI ON DUYORI.DUY_FILIAL = ? AND DUYORI.DUY_GRPVEN = DT6.DT6_CDRORI "
    aAdd(aBind, xFilial("DUY") )

    cQry += "LEFT JOIN MUNICIPIO DUYMNORI ON DUYMNORI.CC2_EST = DUYORI.DUY_EST AND DUYMNORI.CC2_CODMUN = DUYORI.DUY_CODMUN "

    //REGIAO CALCULO P/ DESTINO (DT6_CDRCAL ao invés do DT6_CDRDES)
    cQry += "LEFT JOIN REGIOES DUYCAL ON DUYCAL.DUY_GRPVEN = DT6.DT6_CDRCAL "

    cQry += "LEFT JOIN MUNICIPIO DUYMNCAL ON DUYMNCAL.CC2_EST = DUYCAL.DUY_EST AND DUYMNCAL.CC2_CODMUN = DUYCAL.DUY_CODMUN "

endif

cQry += "WHERE F2D.F2D_FILIAL = ? AND F2D.F2D_DTEXCL = ? AND F2D.D_E_L_E_T_ = ? "
aAdd(aBind, xFilial("F2D") )
aAdd(aBind, space(1) )
aAdd(aBind, space(1) )

cQry += "ORDER BY F2D.F2D_FILIAL, SFT.FT_TIPOMOV, SFT.FT_ENTRADA, SFT.FT_NFISCAL, SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_SERIE, SFT.FT_ITEM "

oPrepMOV := FwExecStatement():New(cQry)

For nX := 1 To Len(aBind)
	If ValType(aBind[nX]) == 'C'
		oPrepMOV:setString(nX, aBind[nX])
    Elseif ValType(aBind[nX]) == 'A'
        oPrepMOV:setIn(nX, aBind[nX])
    Elseif ValType(aBind[nX]) == 'N'
        oPrepMOV:SetNumeric(nX, aBind[nX])
	EndIf
Next nX

cAlsRet := GetNextAlias()

oPrepMOV:OpenAlias(cAlsRet) //oPrepMOV:getfixquery()
dbSelectArea(cAlsRet)
(cAlsRet)->(dbGoTop())

Return cAlsRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa324CRD()
Função responsável por interpretar a regra de apuração e retornar se
a movimentação em questão deve ser considerada como um débito ou um crédito.

Se for uma movimentacao de entrada ou saida avalia a configuração na regra de apuração.

Para codigo IPM nao iremos tratar situacoes de devolucao e sem acao.
Exemplo: Para transporte, energia nao existe devolucao.

Importante De\Paras:
CKH_TIPO = 1=Débito;2=Crédito
F2G_ENTRAD\F2G_SAIDA = 1=Sem Ação;2=Debita;3=Credita  

@param	cAliasMov - String
@Return cCredDeb  - String

@author Denis Souza
@since 21/08/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function Fisa324CRD(cAliasMov)

Local cCredDeb := "" //sem acao

//Se for uma movimentacao de entrada avalio a configuração na regra de apuração.
If (cAliasMov)->FT_TIPOMOV == "E"
    Do Case
        Case (cAliasMov)->F2G_ENTRAD == "2" // Debita
            cCredDeb := "1" // CKH_TIPO = 1=Débito
        Case (cAliasMov)->F2G_ENTRAD == "3" // Credita
            cCredDeb := "2" //CKH_TIPO = 2=Crédito
    EndCase
//Se for uma movimentacao de entrada avalio a configuração na regra de apuração.
ElseIf (cAliasMov)->FT_TIPOMOV == "S"
    Do Case
        Case (cAliasMov)->F2G_SAIDA == "2" // Debita
            cCredDeb := "1" // CKH_TIPO = 1=Débito
        Case (cAliasMov)->F2G_SAIDA == "3" // Credita
            cCredDeb := "2" //CKH_TIPO = 2=Crédito
    EndCase
EndIf

Return cCredDeb

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa324CKH()

Função responsável por efetuar a gravação/atualização da 
tabela CKH (Apuração de IPM - Detalhamento).

@author Denis Souza / Carlos Pister
@since 21/08/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function Fisa324CKH( aDados )

Local cCodIBGE as character
Local cCredDeb as character
Local nX       as numeric

Default aDados := {}

cCodIBGE := ""
cCredDeb := "" //1=Débito
nX       := 0

For nX := 1 To Len(aDados)
    If !Empty(aDados[nX][06])
        cCredDeb := "1" //1=Débito
        If aDados[nX][08] < 0
            aDados[nX][08] := (aDados[nX][08] * -1) //Se for negativo, inverte o sinal
            cCredDeb := "2" // 2=Crédito
        EndIf
        cCodIBGE := ""
        _oHashUF:Get(aDados[nX][04], @cCodIBGE)
        if RecLock("CKH", .T.)
            CKH->CKH_FILIAL := aDados[nX][02] //cFilCentr
            CKH->CKH_IDAPUR := aDados[nX][03]
            CKH->CKH_UF     := aDados[nX][04] //Ex: SP
            CKH->CKH_DIPAM  := aDados[nX][05]
            CKH->CKH_CODMUN := aDados[nX][06]
            CKH->CKH_MUNICI := cCodIBGE + aDados[nX][06] + ' - ' + aDados[nX][07] //Ex: 3550308 - SAO PAULO
            CKH->CKH_VLRADC := aDados[nX][08]
            CKH->CKH_TIPO   := cCredDeb
            CKH->(MsUnlock())
        endif
    EndIf
Next nX

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa324Tab()
Responsavel por abertura das novas tabelas e posicionamento dos indices.
Importante ja existe proteção no FISA170 para verificar o AliasInDic
@param	aList - Array
@Return Nil
@author Denis Souza
@since 21/08/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------
Static Function Fisa324Tab( aList )

Local nX as numeric

Default aList := {}

nX := 1

For nX := 1 to Len(aList)
    DbSelectarea(aList[nX][1])
    (aList[nX][1])->(dbsetorder(aList[nX][2]))
Next nX

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa324UF()
De para UF x IBGE e IBGE x UF

@param	Nil
@Return Nil
@author Denis Souza
@since 21/08/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------
Static Function Fisa324UF()

    _oHashUF := tHashMap():New()

    _oHashUF:Set("RO", "11")
    _oHashUF:Set("AC", "12")
    _oHashUF:Set("AM", "13")
    _oHashUF:Set("RR", "14")
    _oHashUF:Set("PA", "15")
    _oHashUF:Set("AP", "16")
    _oHashUF:Set("TO", "17")
    _oHashUF:Set("MA", "21")
    _oHashUF:Set("PI", "22")
    _oHashUF:Set("CE", "23")
    _oHashUF:Set("RN", "24")
    _oHashUF:Set("PB", "25")
    _oHashUF:Set("PE", "26")
    _oHashUF:Set("AL", "27")
    _oHashUF:Set("SE", "28")
    _oHashUF:Set("BA", "29")
    _oHashUF:Set("MG", "31")
    _oHashUF:Set("ES", "32")
    _oHashUF:Set("RJ", "33")
    _oHashUF:Set("SP", "35")
    _oHashUF:Set("PR", "41")
    _oHashUF:Set("SC", "42")
    _oHashUF:Set("RS", "43")
    _oHashUF:Set("MS", "50")
    _oHashUF:Set("MT", "51")
    _oHashUF:Set("GO", "52")
    _oHashUF:Set("DF", "53")

    _oHashUF:Set("11", "RO")
    _oHashUF:Set("12", "AC")
    _oHashUF:Set("13", "AM")
    _oHashUF:Set("14", "RR")
    _oHashUF:Set("15", "PA")
    _oHashUF:Set("16", "AP")
    _oHashUF:Set("17", "TO")
    _oHashUF:Set("21", "MA")
    _oHashUF:Set("22", "PI")
    _oHashUF:Set("23", "CE")
    _oHashUF:Set("24", "RN")
    _oHashUF:Set("25", "PB")
    _oHashUF:Set("26", "PE")
    _oHashUF:Set("27", "AL")
    _oHashUF:Set("28", "SE")
    _oHashUF:Set("29", "BA")
    _oHashUF:Set("31", "MG")
    _oHashUF:Set("32", "ES")
    _oHashUF:Set("33", "RJ")
    _oHashUF:Set("35", "SP")
    _oHashUF:Set("41", "PR")
    _oHashUF:Set("42", "SC")
    _oHashUF:Set("43", "RS")
    _oHashUF:Set("50", "MS")
    _oHashUF:Set("51", "MT")
    _oHashUF:Set("52", "GO")
    _oHashUF:Set("53", "DF")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa324RAT
Regra para gravação do rateio.

@param	aRateio  - Array - Municipios que irao ratear
@param	aCalcRat - Array - Valor total e tipo do UF + código IPM que sera rateado.

@Return Nil
@author Denis Souza \ Carlos Pister
@since 21/08/2025
@version P12.1.2410
/*/
//-------------------------------------------------------------------
Static Function Fisa324RAT( aRateio, aCalcRat )

Local nlA      as numeric
Local nAte     as numeric
Local nCalc    as numeric
Local cCodIBGE as character
Local cCodMun  as character
Local lFound   as logical
Local cCredDeb as character

Default aRateio  := {}
Default aCalcRat := {}

nlA      := 0
nAte     := 0
nCalc    := 0
cCodIBGE := ''
cCodMun  := ''
lFound   := .F.
cCredDeb := "1" //default debito, se negativo altera p/ credito e efetua o rateio

nAte := Len(aRateio)
nCalc := Len(aCalcRat)

For nlA := 1 to nAte
    If aCalcRat[nCalc][6] < 0
        aCalcRat[nCalc][6] := (aCalcRat[nCalc][6] * -1) //Se for negativo, inverte o sinal
        cCredDeb := "2" // 2=Crédito
    EndIf
    cCodIBGE := ""
    _oHashUF:Get( aCalcRat[nCalc][3], @cCodIBGE)
    cCodMun := aRateio[nlA][2]
    lFound := !CKH->(DbSeek(aCalcRat[nCalc][1] + aCalcRat[nCalc][2] + aCalcRat[nCalc][3] + aCalcRat[nCalc][4] + cCodMun ))
    if RecLock("CKH", lFound)
            CKH->CKH_FILIAL := aCalcRat[nCalc][1]
            CKH->CKH_IDAPUR := aCalcRat[nCalc][2]
            CKH->CKH_UF     := aCalcRat[nCalc][3]
            CKH->CKH_DIPAM  := aCalcRat[nCalc][4]
            CKH->CKH_CODMUN := cCodMun //Ex: 50308
            CKH->CKH_TIPO   := cCredDeb //1=Debito 2=Credito
            CKH->CKH_VLRADC := ( aCalcRat[nCalc][6] * (aRateio[nlA][4] / 100) )
            CKH->CKH_MUNICI := cCodIBGE + cCodMun + ' - ' + aRateio[nlA][3] //Ex: 3550308 - SAO PAULO
        CKH->(MsUnlock())
    endif
Next nlA

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa324CKI()

Função responsável por efetuar a gravação da tabela CKI via Bulk.

@author Carlos Pister
@since 21/08/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function Fisa324CKI(cFilCentr, cIdApur, cAliasIPM, cAliasMov, cUF, cCodMun, cNomeMun, lIntTms, lRet, cMsgProc, lAuto, oInsertCKI)

Local cIdCki     as character
Local cUfPart    as character
Local cMuPart    as character
Local cUfOrig    as character
Local cMuOrig    as character
Local cUfDest    as character
Local cMuDest    as character
Local cCodCli    as character
Local cCodFor    as character
Local cCodIBGE   as character

Default cFilCentr := ""
Default cIdApur   := "" 
Default cAliasIPM := ""
Default cAliasMov := ""
Default cCodMun   := ""
default lIntTms   := .F.
Default lRet      := .T.    
Default cMsgProc  := ""
Default lAuto     := .F.
Default cUF       := ""
Default cNomeMun  := ""

cIdCki     := ""
cUfPart    := ""
cMuPart    := ""
cUfOrig    := ""
cMuOrig    := ""
cUfDest    := ""
cMuDest    := ""
cCodCli    := ""
cCodFor    := ""
cCodIBGE   := ""

cIdCki := FWUUID("CKI")

If lIntTms .and. (cAliasMov)->FT_TIPOMOV == 'S' .And. ((!Empty((cAliasMov)->DT6_CDRORI) .Or. !Empty((cAliasMov)->DT6_CDRCAL)))
    cUfPart := (cAliasMov)->A1_EST
    cMuPart := (cAliasMov)->NA1MNC
    cUfOrig := (cAliasMov)->DUYUFORI
    cMuOrig := (cAliasMov)->NDUYMORI
    cUfDest := (cAliasMov)->DUYUFCAL
    cMuDest := (cAliasMov)->NDUYMCAL
    cCodCli := (cAliasMov)->FT_CLIEFOR
ElseIf (cAliasMov)->FT_TIPOMOV == 'S'
    cUfPart := (cAliasMov)->A1_EST
    cMuPart := (cAliasMov)->NA1MNC
    cUfOrig := (cAliasMov)->F2_UFORIG
    cMuOrig := (cAliasMov)->NF2ORIMN
    cUfDest := (cAliasMov)->F2_UFDEST
    cMuDest := (cAliasMov)->NF2DESMN
    cCodCli := (cAliasMov)->FT_CLIEFOR
Else
    cUfPart := (cAliasMov)->A2_EST
    cMuPart := (cAliasMov)->NA2MNC
    cUfOrig := (cAliasMov)->F1_UFORITR
    cMuOrig := (cAliasMov)->NF1ORIMN
    cUfDest := (cAliasMov)->F1_UFDESTR
    cMuDest := (cAliasMov)->NF1DESMN
    cCodFor := (cAliasMov)->FT_CLIEFOR
Endif

_oHashUF:Get(cUF, @cCodIBGE)

oInsertCki:AddData({cFilCentr,;       // 01 CKI_FILIAL
    cIdApur,;                         // 02 CKI_IDDETA
    cIdCki,;                          // 03 CKI_IDUNIQ
    (cAliasIPM)->CKE_UF,;             // 04 CKI_UFDOC    
    (cAliasIPM)->CKE_CODIPM,;         // 05 CKI_CODIPM   
    (cAliasMov)->F2D_FILIAL,;         // 06 CKI_FILDOC
    cCodIBGE + AllTrim(cCodMun) + ' - ' + AllTrim(cNomeMun),; // 07 CKI_CODMUN
    (cAliasMov)->F2B_REGRA,;          // 08 CKI_REGAPU
    (cAliasMov)->F2B_TRIB,;           // 09 CKI_CODTRI
    (cAliasMov)->FT_NFISCAL,;         // 10 CKI_NF
    (cAliasMov)->FT_SERIE,;           // 11 CKI_SERIE
    (cAliasMov)->FT_TIPOMOV,;         // 12 CKI_TPMOV
    (cAliasMov)->FT_ITEM,;            // 13 CKI_ITEM
    (cAliasMov)->FT_ENTRADA,;         // 14 CKI_DTENT
    (cAliasMov)->FT_EMISSAO,;         // 15 CKI_DTEMIS  
    (cAliasMov)->FT_ESTADO,;          // 16 CKI_UFNOTA   
    cUfPart,;                         // 17 CKI_UFPART
    cMuPart,;                         // 18 CKI_MUNPAR 
    cUfOrig,;                         // 19 CKI_UFORIG
    cMuOrig,;                         // 20 CKI_MUNORI
    cUfDest,;                         // 21 CKI_UFDEST   
    cMuDest,;                         // 22 CKI_MUNDES
    (cAliasMov)->FT_VALCONT,;         // 23 CKI_VLCONT
    (cAliasMov)->FT_TOTAL,;           // 24 CKI_VLTOT
    (cAliasMov)->F2D_BASE,;           // 25 CKI_BSECAL
    (cAliasMov)->F2D_ALIQ,;           // 26 CKI_ALIQ
    (cAliasMov)->F2D_VALOR,;          // 27 CKI_VLTRIB
    (cAliasMov)->A1_NOME,;            // 28 CKI_CLIENT
    (cAliasMov)->A2_NOME,;            // 29 CKI_FORNEC
    cCodCli,;                         // 30 CKI_CODCLI
    cCodFor,;                         // 31 CKI_CODFOR
    (cAliasMov)->FT_LOJA,;            // 32 CKI_LOJA        
    (cAliasIPM)->CKE_REGCAL;          // 33 CKI_REGCAL
})

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa324CMU()

Função responsável por retornar a UF, Código e nome do Munícipio,
de acordo com a opção do munícipio que foi informado no cadastro
do código IPM (CKE_CONSMU-Op.Município)
1=Municipio Origem;2=Municipio Destino;3=Municipio Participante;4=Municipio Contribuinte;5=Rateio

@author Denis Souza / Carlos Pister
@since 20/08/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function Fisa324CMU(lIntTms, cAliasIPM, cAliasMov, cUF, cCodMun, cNomeMun, aContrib)

Default lIntTms   := .F.
Default cAliasIPM := ""
Default cAliasMov := ""
Default cUF       := ""
Default cCodMun   := ""
Default cNomeMun  := ""
Default aContrib  := ""

If Alltrim((cAliasIPM)->CKE_CONSMU) == "1" //ORIGEM

    if lIntTms .And. (cAliasMov)->FT_TIPOMOV == 'S' .And. !Empty((cAliasMov)->DT6_CDRORI)
        cUF      := (cAliasMov)->DUYUFORI
        cCodMun  := (cAliasMov)->DUYMCORI
        cNomeMun := (cAliasMov)->NDUYMORI
    else
        if (cAliasMov)->FT_TIPOMOV == 'S'
            cUF      := (cAliasMov)->F2_UFORIG
            cCodMun  := (cAliasMov)->F2_CMUNOR
            cNomeMun := (cAliasMov)->NF2ORIMN
        endif
        if (cAliasMov)->FT_TIPOMOV == 'E'
            cUF      := (cAliasMov)->F1_UFORITR
            cCodMun  := (cAliasMov)->F1_MUORITR
            cNomeMun := (cAliasMov)->NF1ORIMN
        endif
    endif

elseIf Alltrim((cAliasIPM)->CKE_CONSMU) == "2" //DESTINO

    //CALCULO (DT6_CDRCAL ao invés do DT6_CDRDES)
    if lIntTms .And. (cAliasMov)->FT_TIPOMOV == 'S' .And. !Empty((cAliasMov)->DT6_CDRCAL) //.And. !empty( (cAliasMov)->DT6_CDRDES)
        cUF      := (cAliasMov)->DUYUFCAL
        cCodMun  := (cAliasMov)->DUYMCCAL
        cNomeMun := (cAliasMov)->NDUYMCAL
    else
        if (cAliasMov)->FT_TIPOMOV == 'S'
            cUF      := (cAliasMov)->F2_UFDEST
            cCodMun  := (cAliasMov)->F2_CMUNDE
            cNomeMun := (cAliasMov)->NF2DESMN
        endif
        if (cAliasMov)->FT_TIPOMOV == 'E'
            cUF      := (cAliasMov)->F1_UFDESTR
            cCodMun  := (cAliasMov)->F1_MUDESTR
            cNomeMun := (cAliasMov)->NF1DESMN
        endif
    endif

ElseIf Alltrim((cAliasIPM)->CKE_CONSMU) == "3" //PARTICIPANTE

    if (cAliasMov)->FT_TIPOMOV == 'S'
        if (cAliasMov)->FT_TIPO $ ("' ','C','I','N','S','P'")
            cUF      := (cAliasMov)->A1_EST
            cCodMun  := (cAliasMov)->A1_COD_MUN
            cNomeMun := (cAliasMov)->NA1MNC
        elseif (cAliasMov)->FT_TIPO $ ("'B', 'D'")
            cUF      := (cAliasMov)->A2_EST
            cCodMun  := (cAliasMov)->A2_COD_MUN
            cNomeMun := (cAliasMov)->NA2MNC
        endif
    endif
    if (cAliasMov)->FT_TIPOMOV == 'E'
        if (cAliasMov)->FT_TIPO  $ ("' ','C','I','N','S','P'")
            cUF      := (cAliasMov)->A2_EST
            cCodMun  := (cAliasMov)->A2_COD_MUN
            cNomeMun := (cAliasMov)->NA2MNC
        elseif (cAliasMov)->FT_TIPO $ ("'B', 'D'")
            cUF      := (cAliasMov)->A1_EST
            cCodMun  := (cAliasMov)->A1_COD_MUN
            cNomeMun := (cAliasMov)->NA1MNC
        endif
    endif

ElseIf Alltrim((cAliasIPM)->CKE_CONSMU) $ "4|5" //4=Municipio Contribuinte 5-Rateio
    cUF      := aContrib[1][UF]
    cCodMun  := aContrib[1][CODMUN]
    cNomeMun := aContrib[1][NMCONT]
endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa324SIM()
Funcao para tratar a questao do valor simbolico.
Se CKE_CONVLS = 1 - Sim
Devera gerar o valor simbolico de R$0,01 importante: somente no municipio do contribuinte,
Caso nao exista nenhuma apuracao para a chave UF + Codigo IPM.

@author Denis Souza
@since 21/08/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function Fisa324SIM(oPrepSIM,cAliasIPM,cIdApur,aContrib,lGrvCKH,aFil,aParams)

Local cQry     as character
Local aBind    as array
Local cAlsSimb as character
Local nX       as numeric
Local lFound   as logical
Local cCodIBGE as character
Local cUfFil   as character
Local lMensal  as logical

Default oPrepSIM  := Nil
Default cAliasIPM := ''
Default cIdApur   := ''
Default aContrib  := {}
Default lGrvCKH   := .F.
Default aFil      := {}
Default aParams   := {}

cQry     := ''
aBind    := {}
cAlsSimb := ''
nX       := 0
lFound   := .F.
cCodIBGE := ''
cUfFil   := ''
lMensal  := .T.

if Select( cAliasIPM ) > 0
    (cAliasIPM)->(DbGoTop())
    if (cAliasIPM)->(!EOF())
        While (cAliasIPM)->(!Eof())
            aSize(aBind,0)
            For nX := 1 To Len(aFil)
                cUfFil := GetUFFil(alltrim(aFil[nX][2]))
                lMensal := .T.
                if CLN->(DbSeek(xFilial("CLN")+(cAliasIPM)->CKE_UF+(cAliasIPM)->CKE_CODIPM))
                    if CLN->CLN_TIPO == "2" //1=Mensal; 2=Anual
                        lMensal := .F.      //vazio continua como mensal
                    endif
                endif
                if (aParams[TPPERIOD] == '1' .And. lMensal) .Or. (aParams[TPPERIOD] == '2' .And. !lMensal)   
                    if (cAliasIPM)->CKE_CONVLS == '1' .and. cUfFil == (cAliasIPM)->CKE_UF
                        cQry := "SELECT COUNT(CKH.CKH_DIPAM) QTDREG FROM " + RetSqlName("CKH") + " CKH WHERE "
                        cQry += "CKH.CKH_FILIAL = ? "
                        aAdd(aBind,(cAliasIPM)->CKE_FILIAL)
                        cQry += "AND CKH.CKH_IDAPUR = ? "
                        aAdd(aBind,cIdApur)
                        cQry += "AND CKH.CKH_UF = ? "
                        aAdd(aBind,(cAliasIPM)->CKE_UF)
                        cQry += "AND CKH.CKH_DIPAM = ? "
                        aAdd(aBind,(cAliasIPM)->CKE_CODIPM)
                        cQry += "AND CKH.D_E_L_E_T_ = ? "
                        aAdd(aBind,space(1))

                        cQry := ChangeQuery(cQry)
                        oPrepSIM := FwExecStatement():New(cQry)
                        For nX := 1 To Len(aBind)
                            If ValType(aBind[nX]) == 'C'
                                oPrepSIM:setString(nX, aBind[nX])
                            Endif
                        Next nX
                        cAlsSimb := GetNextAlias()
                        oPrepSIM:OpenAlias(cAlsSimb) //oPrepSIM:getfixquery()

                        dbSelectArea(cAlsSimb)
                        (cAlsSimb)->(dbGoTop())
                        if (cAlsSimb)->QTDREG == 0 //Nao houve nenhum debito para o codigo dipam
                            lFound := !CKH->(DbSeek( (cAliasIPM)->CKE_FILIAL + cIdApur + (cAliasIPM)->CKE_UF + (cAliasIPM)->CKE_CODIPM + aContrib[1][CODMUN] ) )
                            _oHashUF:Get( aContrib[1][UF], @cCodIBGE )
                            if RecLock("CKH", lFound)
                                    CKH->CKH_FILIAL := (cAliasIPM)->CKE_FILIAL
                                    CKH->CKH_IDAPUR := cIdApur
                                    CKH->CKH_UF     := (cAliasIPM)->CKE_UF
                                    CKH->CKH_DIPAM  := (cAliasIPM)->CKE_CODIPM
                                    CKH->CKH_CODMUN := aContrib[1][CODMUN] //Ex: 50308
                                    CKH->CKH_TIPO   := '1' //1=Debito 2=Credito
                                    CKH->CKH_VLRADC := 0.01
                                    CKH->CKH_MUNICI := cCodIBGE + aContrib[1][CODMUN] + ' - ' + aContrib[1][NMCONT] //Ex: 3550308 - SAO PAULO
                                CKH->(MsUnlock())

                                lGrvCKH := .T.
                            endif
                        endif
                        (cAlsSimb)->(dbCloseArea())
                    endif
                EndIf
            Next nX
            (cAliasIPM)->(dbSkip())
        EndDo
    endif
endif

aSize(aBind,0)

Return Nil
//-----------------------------------------------------------------
/*/{Protheus.doc} Fisa324SCH
Função responsavel por executar a apuração por SCHEDULE

@param aParSch - Array - Array tratado para execução via SMARTSCHEDULE

@Return Nil
@author Wesley Matos
@since 20/08/2025
@version 1.0
/*/
//------------------------------------------------------------------
Function Fisa324SCH(aParSch)

    Local aFil     as array
    Local aParam   as array
	Local cCompany as character
	Local cBranch  as character
    Local lExecSch as logical
    Local cMsg     as character

    aFil     := {}
    aParam   := {}
    lExecSch := .T.
    cMsg     := ''

    Default aParSch := {}

    if Len(aParSch) > 0

        //Recupera os parametros para a execução da apuração
        aFil   := aParSch[aFIL]
        aParam := aParSch[aPARAM]
        
        //Recupera a chave para atualização do status da apuração 
        cChave   := aParSch[CHAVE]
        
        //Recupera a empresa e filial para abertura do ambiente
		cCompany := aParSch[EMPRESA]
		cBranch  := aParSch[FILIAL]
        
        cMsg := STR0006 //"Erro na abertura do ambiente para execução do SCHEDULE"

		// Preparação do Ambiente
		if RpcSetEnv(cCompany, cBranch)
            
            conout(STR0011)//Inicio da Apuração...
		    
            //Chama a apuração
            FISA324Apu(aFil, aParam,,,lExecSch)
            
            cMsg := STR0012//'Fim do processo de apuração.'
        endIf

        //Atualiza o status da apuração
        if CKG->(DbSeek(cChave))
            RecLock("CKG",.F.)
            CKG->CKG_CONAPU := '2'
            CKG->( MsUnLock( ) )
        endIf

        MsgInfo(cMsg,STR0013)//'Apuração de IPM'

    endIf

return

//-----------------------------------------------------------------
/*/{Protheus.doc} Fis324Even
Função responsavel por calcular o processo de apuração

@param nQtdF2D   - Numeric - Quantidade de registros retornado na query principal
@param nTotItens - Numeric - Contador de registros

@Return Nil
@author Wesley Matos
@since 25/08/2025
@version 1.0
/*/
//------------------------------------------------------------------
Static Function Fis324Even(nQtdF2D, nTotItens)

    if (nQtdF2D * 0.25) == nTotItens
        cMsg := STR0007 //"Processo de apuração: 25%"
        FisExecEv(cMsg)
    elseIf (nQtdF2D * 0.50) == nTotItens
        cMsg := STR0008 //"Processo de apuração: 50%"
        FisExecEv(cMsg)
    elseif (nQtdF2D * 0.75) == nTotItens
        cMsg := STR0009 //"Processo de apuração: 75%"
        FisExecEv(cMsg)
    EndIf

return

//-----------------------------------------------------------------
/*/{Protheus.doc} FisExecEv
Função responsavel por executar a chamada do EventViewr passando a msg a ser exibida

@param cMsg - Character - Mensagem a ser exibida no EventViwer

@Return Nil
@author Wesley Matos
@since 25/08/2025
@version 1.0
/*/
//------------------------------------------------------------------
Static Function FisExecEv( cMsg )

    EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "088", 0, "", STR0013, cMsg ,.F.) //"Apuração de IPM"

return


/*/{Protheus.doc} aBulkField
  Função que obtém os campos da SX3 e os transforma em uma estrutura identica ao DBStruct
  @type Static Function
  @author José Ricardo Bernardo
  @since 22/01/2026
  @version 12.1.2510
  @param  aFields - Array com os campos da SX3
  @return aStructTab - Array com a estrutura  necessária para passar no oBulk:SetFields
  @see (links_or_references)
/*/
Static Function aBulkField( aFields as array)

	Local aStructTab := {} as array
	Local aStructCpo := {} as array
	Local nPosCpo    := 0  as Integer
	Local nLenCpo    := Len(aFields) as Integer

	For nPosCpo := 1 To nLenCpo
            aStructCpo:= FWSX3Util():GetFieldStruct(aFields[nPosCpo])
			//Adicionando campos que serão usados no Bulk da mesma forma que o DBStruct()
			//[1] - Campo
			//[2] - Tipo
			//[3] - Tamanho
			//[4] - Decimais    
			aAdd(aStructTab, { aStructCpo[1], aStructCpo[2], aStructCpo[3], aStructCpo[4] })
	Next

	FwFreeArray(aStructCpo)

Return (aStructTab)


/*/{Protheus.doc} GetUFFil
  Função que atualiza objeto Json com as UF de processamentos definidas no MV_ESTADO filiais definidas de processamento.
  @type Static Function
  @author José Ricardo Bernardo
  @since 23/01/2026
  @version 12.1.2510
  @param  cFilTemp - Filial de processamento e armazenamento no Json
  @return oJsUFFil - UF correspondente ao estado informado no parametro
/*/

Static Function GetUFFil( cFilTemp as character)

    If !oJsUFFil:HasProperty( cFilTemp )
        oJsUFFil[cFilTemp] := AllTrim(SuperGetMv("MV_ESTADO", .T., "", cFilTemp))
    Endif

Return oJsUFFil[cFilTemp]
