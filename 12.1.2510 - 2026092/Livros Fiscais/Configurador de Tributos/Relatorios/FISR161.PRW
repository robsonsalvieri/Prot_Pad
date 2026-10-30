#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FISR161.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} file
Gerenciador de Processamento
@author    joao.pellegrini
@version   12.1.17
@since     06/11/2018
/*/
//------------------------------------------------------------------------------------------
Function FISR161()

Local oReport := NIL
Local cAlsDebCrd := ""
Local cAlsAju := ""
Local cAlsSld := ""
Local cAlsRes := ""

If F2H->(!Eof())

    cAlsDebCrd := GetNextAlias()
    cAlsAju := GetNextAlias()
    cAlsSld := GetNextAlias()
    cAlsRes := GetNextAlias()    

    oReport := ReportDef(cAlsDebCrd, cAlsAju, cAlsSld, cAlsRes)
    oReport:PrintDialog()

    // Fechando os alias utilizados pelo relatório...

    If Select(cAlsDebCrd) > 0
        dbSelectArea(cAlsDebCrd)
        (cAlsDebCrd)->(DbCloseArea())
    EndIf

    If Select(cAlsAju) > 0
        dbSelectArea(cAlsAju)
        (cAlsAju)->(DbCloseArea())
    EndIf

    If Select(cAlsSld) > 0
        dbSelectArea(cAlsSld)
        (cAlsSld)->(DbCloseArea())
    EndIf

    If Select(cAlsRes) > 0
        dbSelectArea(cAlsRes)
        (cAlsRes)->(DbCloseArea())
    EndIf

Else
    Alert(STR0001) //"Nenhuma apuração foi selecionada. O relatório não será gerado."
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Imprimir Relatório
@author    joao.pellegrini
@version   12.1.17
@since     06/11/2018
/*/
//------------------------------------------------------------------------------------------
Static Function ReportDef(cAlsDebCrd, cAlsAju, cAlsSld, cAlsRes)

Local oReport := NIL
Local oSection1A := NIL
Local oSection1B := NIL
Local oSection2A := NIL
Local oSection2B := NIL
Local oSection3A := NIL
Local oSection3B := NIL
Local oSection4 := NIL
Local oBreak1 := NIL
Local oBreak2 := NIL
Local oBreak3 := NIL
Local cIDApur := F2H->F2H_ID
Local cTitle := STR0004 + AllTrim(F2H->F2H_TRIB) + STR0002 + DtoC(F2H->F2H_DTINI) + STR0003 + DtoC(F2H->F2H_DTFIN) //" de " //" a " //"Relatório de Conferência de Apuração - "

//Quando a ReportDef é executada pelo robô de automação, os alias serão criados através de Default
//Quando executada pelo menu, criamos os alias na FISR161 e fechamos ele após a PrintDialog().
Default cAlsDebCrd  := GetNextAlias()
Default cAlsAju     := GetNextAlias()
Default cAlsSld     := GetNextAlias()
Default cAlsRes     := GetNextAlias()

oReport	:= TReport():New("FISR161", cTitle, NIL, {|oReport|ReportPrint(oReport, cIDApur, cAlsDebCrd, cAlsAju, cAlsSld, cAlsRes)})
oReport:SetLandScape()
oReport:HideParamPage()
oReport:SetLineHeight(40)

// Seção 1 - Débitos e Créditos

oSection1A := TRSection():New(oReport, STR0005, {"F2J"}) //"Débitos e Créditos"
oSection1A:SetHeaderSection(.T.)
oSection1A:SetPageBreak(.T.)
oSection1A:SetAutoSize(.T.)
TRCell():New(oSection1A, "F2J_TIPO", "F2J", STR0006) //"Tipo de Movimento"

oSection1B := TRSection():New(oSection1A, STR0005, {"F2J"}) //"Débitos e Créditos"
TRCell():New(oSection1B, "F2B_REGRA", "F2B", STR0007) //"Regra"
TRCell():New(oSection1B, "F2B_DESC", "F2B", STR0008) //"Descrição"
TRCell():New(oSection1B, "F2J_VLTRIB", "F2J", STR0009) //"Valor Tributado"
TRCell():New(oSection1B, "F2J_VLDEV", "F2J", STR0010) //"Devoluções/Estornos"

oBreak1 := TRBreak():New(oSection1A, {||(cAlsDebCrd)->(F2J_TIPO)}, STR0011, .F., STR0011, .T.) //"Totais"
TRFunction():New(oSection1B:Cell("F2J_VLTRIB"), NIL, "SUM", oBreak1, NIL, "@E 999,999,999.99",/*uFormula*/, .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
TRFunction():New(oSection1B:Cell("F2J_VLDEV"), NIL, "SUM", oBreak1, NIL, "@E 999,999,999.99",/*uFormula*/, .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)

// Seção 2 - Ajustes

oSection2A := TRSection():New(oReport, STR0012, {"F2M"}) //"Ajustes"
oSection2A:SetHeaderSection(.T.)
oSection2A:SetPageBreak(.T.)
oSection2A:SetAutoSize(.T.)
TRCell():New(oSection2A, "F2M_TPAJUS", "F2M", STR0013) //"Tipo de Ajuste"

oSection2B := TRSection():New(oSection2A, STR0012, {"F2M"}) //"Ajustes"
TRCell():New(oSection2B, "F2M_DESCRI", "F2M", STR0008) //"Descrição"
TRCell():New(oSection2B, "F2M_VALOR", "F2M", STR0014) //"Valor"

oBreak2 := TRBreak():New(oSection2A, {||(cAlsAju)->(F2M_TPAJUS)}, STR0015, .F., STR0015, .T.) //"Total"
TRFunction():New(oSection2B:Cell("F2M_VALOR"), NIL, "SUM", oBreak2, NIL, "@E 999,999,999.99",/*uFormula*/, .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)

// Seção 3 - Saldos Credores

oSection3A := TRSection():New(oReport, STR0016, {"F2I"}) //"Saldos"
oSection3A:SetHeaderSection(.T.)
oSection3A:SetPageBreak(.T.)
oSection3A:SetAutoSize(.T.)
TRCell():New(oSection3A, "F2I_TPSLD", "F2I", STR0017) //"Tipo de Saldo"

oSection3B := TRSection():New(oSection3A, STR0016, {"F2I"}) //"Saldos"
TRCell():New(oSection3B, "F2I_DTORI", "F2I", STR0018) //"Data de Origem"
TRCell():New(oSection3B, "F2I_SLDINI", "F2I", STR0019) //"Saldo Inicial"
TRCell():New(oSection3B, "F2I_SLDUTI", "F2I", STR0020) //"Saldo Utilizado"
TRCell():New(oSection3B, "F2I_SLDFIN", "F2I", STR0021) //"Saldo Final"

oBreak3 := TRBreak():New(oSection3A, {||(cAlsSld)->(F2I_TPSLD)}, STR0015, .F., STR0015, .T.) //"Total"
TRFunction():New(oSection3B:Cell("F2I_SLDFIN"), NIL, "SUM", oBreak3, NIL, "@E 999,999,999.99",/*uFormula*/, .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)

// Seção 4 - Resumo de Apuração

oSection4 := TRSection():New(oReport, STR0022, {"F2H"}) //"Resumo"
oSection4:SetHeaderSection(.T.)
oSection4:SetPageBreak(.T.)

TRCell():New(oSection4, "DESCRICAO", NIL, STR0008) //"Descrição"
oSection4:Cell("DESCRICAO"):SetSize(50)

TRCell():New(oSection4, "VALOR", NIL, STR0014) //"Valor"
oSection4:Cell("VALOR"):SetPicture("@E 999,999,999.99")
oSection4:Cell("VALOR"):SetSize(15)
oSection4:Cell("VALOR"):nHeaderAlign := 3
oSection4:Cell("VALOR"):nAlign := 3

Return oReport

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Montar query e abrir em tabela temporária
@author    joao.pellegrini
@version   12.1.17
@since     06/11/2018
/*/
//------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport, cIDApur, cAlsDebCrd, cAlsAju, cAlsSld, cAlsRes)

Local oSection1A := oReport:Section(1)
Local oSection1B := oReport:Section(1):Section(1)
Local oSection2A := oReport:Section(2)
Local oSection2B := oReport:Section(2):Section(1)
Local oSection3A := oReport:Section(3)
Local oSection3B := oReport:Section(3):Section(1)
Local oSection4 := oReport:Section(4)

// Seção 1 - Débitos e Créditos

oSection1A:BeginQuery()
BeginSql Alias cAlsDebCrd    
    SELECT
        F2B.F2B_REGRA, F2B.F2B_DESC, F2J.F2J_TIPO, F2J.F2J_VLTRIB, F2J.F2J_VLDEV
    FROM
        %Table:F2J% F2J
        JOIN %Table:F2B% F2B ON (F2B.F2B_FILIAL = %xFilial:F2B% AND F2B.F2B_ID = F2J.F2J_RTRIB AND F2B.%NotDel%)
    WHERE
        F2J.F2J_FILIAL = %xFilial:F2J% AND
        F2J.F2J_IDAPUR = %Exp:cIDApur% AND
        F2J.%NotDel%
    ORDER BY F2J.F2J_TIPO, F2B.F2B_REGRA
EndSql
oSection1A:EndQuery()
oSection1B:SetParentQuery()
oSection1B:SetParentFilter({|cParam| (cAlsDebCrd)->F2J_TIPO == cParam}, {||(cAlsDebCrd)->F2J_TIPO})
oSection1A:Print()

// Seção 2 - Ajustes

oSection2A:BeginQuery()
BeginSql Alias cAlsAju    
    SELECT
        F2M.F2M_TPAJUS, F2M.F2M_DESCRI, F2M.F2M_VALOR
    FROM
        %Table:F2M% F2M
        JOIN %Table:F2K% F2K ON (F2K.F2K_FILIAL = %xFilial:F2K% AND F2K.F2K_IDAPUR = %Exp:cIDApur% AND F2K.F2K_ID = F2M.F2M_IDRAPU AND F2K.%NotDel%)        
    WHERE
        F2M.F2M_FILIAL = %xFilial:F2M% AND
        F2M.%NotDel%
    ORDER BY F2M.F2M_TPAJUS, F2M.F2M_DESCRI
EndSql
oSection2A:EndQuery()
oSection2B:SetParentQuery()
oSection2B:SetParentFilter({|cParam| (cAlsAju)->F2M_TPAJUS == cParam}, {||(cAlsAju)->F2M_TPAJUS})
oSection2A:Print()

// Seção 3 - Saldos Credores

oSection3A:BeginQuery()
BeginSql Alias cAlsSld
    COLUMN F2I_DTORI AS DATE
    SELECT
        F2I.F2I_DTORI, F2I.F2I_TPSLD, F2I.F2I_SLDINI, F2I.F2I_SLDUTI, F2I.F2I_SLDFIN
    FROM
        %Table:F2I% F2I
    WHERE
        F2I.F2I_FILIAL = %xFilial:F2I% AND
        F2I.F2I_IDAPUR = %Exp:cIDApur% AND
        F2I.F2I_TPSLD = %Exp:'1'% AND // Saldos Credores somente
        F2I.%NotDel%
    ORDER BY F2I.F2I_DTORI
EndSql
oSection3A:EndQuery()
oSection3B:SetParentQuery()
oSection3B:SetParentFilter({|cParam| (cAlsSld)->F2I_TPSLD == cParam}, {||(cAlsSld)->F2I_TPSLD})
oSection3A:Print()

// Seção 4 - Resumo de Apuração

oReport:PrintText("")
oReport:PrintText(STR0023,,10) //"Resumo de Apuração"
oReport:ThinLine()

BeginSql Alias cAlsRes    
    SELECT
        F2K_OPTRIB, F2K_ESTCRD, F2K_TOTDEB ,F2K_SLDANT, F2K_OPCRED, F2K_ESTDEB, F2K_TOTCRD, F2K_SLDDEV, F2K_SLDATU, F2K_SLDUTI, F2K_AJUCRD, F2K_AJUDEB
    FROM
        %Table:F2K% F2K
    WHERE
        F2K.F2K_FILIAL = %xFilial:F2K% AND
        F2K.F2K_IDAPUR = %Exp:cIDApur% AND
        F2K.%NotDel%
EndSql

If (cAlsRes)->(!Eof())

    oSection4:Init()

    oSection4:Cell("DESCRICAO"):SetValue(STR0024) //"Débitos por Saída"
    oSection4:Cell("VALOR"):SetValue((cAlsRes)->F2K_OPTRIB)
    oSection4:PrintLine()

    oSection4:Cell("DESCRICAO"):SetValue(STR0025) //"Estornos de Crédito"
    oSection4:Cell("VALOR"):SetValue((cAlsRes)->F2K_ESTCRD)
    oSection4:PrintLine()

    oSection4:Cell("DESCRICAO"):SetValue(STR0026) //"Ajustes de Débito"
    oSection4:Cell("VALOR"):SetValue((cAlsRes)->F2K_AJUDEB)
    oSection4:PrintLine()

    oSection4:Cell("DESCRICAO"):SetValue(STR0027) //"Total de Débitos"
    oSection4:Cell("VALOR"):SetValue((cAlsRes)->F2K_TOTDEB)
    oSection4:PrintLine()

    oSection4:Cell("DESCRICAO"):SetValue(STR0028) //"Saldo Credor Transportado do Período Anterior"
    oSection4:Cell("VALOR"):SetValue((cAlsRes)->F2K_SLDANT)
    oSection4:PrintLine()

    oSection4:Cell("DESCRICAO"):SetValue(STR0029) //"Saldo Credor do Período Anterior Utilizado"
    oSection4:Cell("VALOR"):SetValue((cAlsRes)->F2K_SLDUTI)
    oSection4:PrintLine()
    
    oSection4:Cell("DESCRICAO"):SetValue(STR0030) //"Créditos por Entrada"
    oSection4:Cell("VALOR"):SetValue((cAlsRes)->F2K_OPCRED)
    oSection4:PrintLine()

    oSection4:Cell("DESCRICAO"):SetValue(STR0031) //"Estornos de Débito"
    oSection4:Cell("VALOR"):SetValue((cAlsRes)->F2K_ESTDEB)
    oSection4:PrintLine()

    oSection4:Cell("DESCRICAO"):SetValue(STR0032) //"Ajustes de Crédito"
    oSection4:Cell("VALOR"):SetValue((cAlsRes)->F2K_AJUCRD)
    oSection4:PrintLine()

    oSection4:Cell("DESCRICAO"):SetValue(STR0033) //"Total de Créditos"
    oSection4:Cell("VALOR"):SetValue((cAlsRes)->F2K_TOTCRD)
    oSection4:PrintLine()

    oSection4:Cell("DESCRICAO"):SetValue(STR0034) //"Saldo Devedor"
    oSection4:Cell("VALOR"):SetValue((cAlsRes)->F2K_SLDDEV)
    oSection4:PrintLine()

    oSection4:Cell("DESCRICAO"):SetValue(STR0035) //"Saldo Credor a Transportar Para o Próximo Período"
    oSection4:Cell("VALOR"):SetValue((cAlsRes)->F2K_SLDATU)
    oSection4:PrintLine()

    oSection4:Finish()

EndIf

Return

