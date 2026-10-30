#include "totvs.ch"
#include "dmsos.ch"

/*/{Protheus.doc} DMSOS
Gera o arquivo CSV no formato "Demais Contribuintes" exigido pela Prefeitura
de Osasco/SP para entrega da DMS (Declaracao Mensal de Servicos) via portal
BETHA. O arquivo contem retencao e substituicao tributaria de ISS.

Estrutura do arquivo:
  Linha 1  : Cabecalho  [InscMun];[CNPJ];[CPF];[Mes];[Exercicio]
  Demais   : Registros DR (documentos recebidos) e RT (retencao nas saidas)

Nome do arquivo gerado: MMMAAAA.CSV (ex: NOV2018.CSV, JAN2019.CSV)
Separador de campos   : ponto-e-virgula (;)
Separador decimal     : ponto (.)

Relacionado: DJOBRIG-117 - DMS Osasco/SP - Layout CSV para Demais Contribuintes

@type  Function
@author Carlos Pister
@since  14/07/2026
@version 1.0
@param dDtIni, Date, Data inicial do periodo de apuracao (MV_PAR01 do EISSOS)
@param dDtFim, Date, Data final do periodo de apuracao (MV_PAR02 do EISSOS)
@param cDir
@return Nil
/*/
Function DMSOS(dDtIni, dDtFim, cDir)

Local cNomeArq := ""
Local cArquivo := ""
Local oArquivo := Nil
Local cLinha   := ""
Local cQuery   := ""
Local cAlias   := ""
Local oPrepare := Nil
Local cInscMun := ""
Local cCNPJ    := ""
Local cCPF     := ""
Local cRazao   := ""
Local lVisDirf := .F.
Local aMeses   := {"JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"}
Local aDocRet  := {}

Default dDtIni := CTod("  /  /    ")
Default dDtFim := CTod("  /  /    ")
Default cDir := ""

If !Empty(cDir) .and. !Empty(dDtIni) .and. !Empty(dDtFim)

    // Nome do arquivo: MMMAAAA.CSV
    cNomeArq := aMeses[Month(dDtIni)] + StrZero(Year(dDtIni), 4) + ".CSV"
    cArquivo := AllTrim(cDir) + cNomeArq
    
    // Inscricao municipal do declarante (MV_PAR01 do EISSOS)
    cInscMun := AllTrim(MV_PAR01)

    // MV_VISDIRF=1 indica que F3_RECISS prevalece sobre A2_RECISS
    lVisDirf := (AllTrim(SuperGetMv("MV_VISDIRF",, "")) == "1")

    // ----------------------------------------------------------------
    // REGISTROS DR - Documentos Recebidos (entradas de servico)
    // ----------------------------------------------------------------
    cQuery := "SELECT F3_FILIAL, F3_NFISCAL, F3_ESPECIE, F3_SERIE, F3_EMISSAO, F3_CFO,"
    cQuery += "       F3_CODISS, F3_VALCONT, F3_ALIQICM, F3_ICMSRET,"
    cQuery += "       F3_CLIEFOR, F3_LOJA, F3_RECISS, F3_TIPO"
    cQuery += " FROM " + RetSqlName("SF3") + " SF3 "
    cQuery += " WHERE SF3.F3_FILIAL = ?"
    cQuery += " AND SF3.F3_EMISSAO BETWEEN ? AND ? "
    cQuery += " AND SF3.F3_TIPO = ?"
    cQuery += " AND SUBSTRING(SF3.F3_CFO, 1, 1) < ?"
    cQuery += " AND SF3.D_E_L_E_T_ = ?"
    cQuery += " ORDER BY SF3.F3_EMISSAO, SF3.F3_NFISCAL"

    cQuery := ChangeQuery(cQuery)
    oPrepare  := FWExecStatement():New(cQuery)

    oPrepare:SetString(1, xFilial("SF3"))
    oPrepare:SetString(2, DToS(dDtIni))
    oPrepare:SetString(3, DToS(dDtFim))
    oPrepare:SetString(4, "S")
    oPrepare:SetString(5, "5")
    oPrepare:SetString(6, " ")

    cAlias := GetNextAlias()
	oPrepare:OpenAlias(cAlias)

    ProcRegua((cAlias)->(LastRec()))

    If !(cAlias)->(Eof())

        oArquivo := FWFileWriter():New(cArquivo, .F.)

        If oArquivo:Exists()
        	oArquivo:Erase()
        EndIf

        If oArquivo:Create()

            cLinha := MntCabec(dDtIni, cInscMun, @cCNPJ, @cCPF, @cRazao)
            oArquivo:write(cLinha + Chr(13) + Chr(10))

            Do While !(cAlias)->(Eof())
                MntDocsRec(cAlias, "SA2", lVisDirf, @aDocRet)

                (cAlias)->(DbSkip())
                IncProc()
            EndDo

            If Len(aDocRet) > 0  
                GrvDocDR(oArquivo, aDocRet )
                GrvDocRT(oArquivo, aDocRet, cCNPJ, cCPF, cRazao)
            EndIf

        EndIf

        If oArquivo != Nil
            oArquivo:Close()
            FreeObj(oArquivo)
        EndIf

    EndIf

    (cAlias)->(DbCloseArea())

    If oPrepare != Nil
		oPrepare:Destroy()
		oPrepare := nil
	EndIf

Else
    MsgAlert(STR0001, STR0002)//"Arquivo para gravação não informado!" - "DMS Osasco"
EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} MntCabec
Monta a linha de cabecalho do arquivo CSV conforme layout da Prefeitura
de Osasco/SP.
Formato: [InscMun];[CNPJ];[CPF];[Mes];[Exercicio];
@type  Static Function
@author Carlos Pister
@since  14/07/2026
@param dDtIni,   Date,      Data inicial do periodo
@param cInscMun, Character, Inscricao municipal do declarante (MV_PAR01 do EISSOS)
@param cCNPJ , Character, CNPJ do tomador
@param cCPF , Character, CPF do tomador
@param cRazao , Character, Razão Social do Tomador
@return Character, Linha do cabecalho formatada
/*/
Static Function MntCabec(dDtIni, cInscMun, cCNPJ, cCPF, cRazao)

Local cMes     := ""
Local cExerc   := ""
Local cCGC     := ""
Local cSep     := ";"
Local cRet     := ""
Local aDataSM0 := {}
Local nPosCGC  := 0
Local nPosNome := 0

aDataSM0 := FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, {"M0_CGC", "M0_NOMECOM"})

nPosCGC  := AScan(aDataSM0, {|x| x[1] == "M0_CGC"})
nPosNome := AScan(aDataSM0, {|x| x[1] == "M0_NOMECOM"})

If nPosCGC > 0 .And. nPosNome > 0
    cCGC   := AllTrim(aDataSM0[nPosCGC][2])
    cRazao := AllTrim(aDataSM0[nPosNome][2])
EndIf

If Len(cCGC) >= 14
    cCNPJ := cCGC
Else
    cCPF  := cCGC
EndIf

cMes   := StrZero(Month(dDtIni), 2)
cExerc := StrZero(Year(dDtIni), 4)

cRet :=  cInscMun + cSep + cCNPJ + cSep + cCPF + cSep + cMes + cSep + cExerc 

Return cRet

//------------------------------------------------------------------
/*/{Protheus.doc} MntDocsRec
Monta o array documento Recebido/Retenção para o
arquivo CSV da DMS Osasco/SP.
@type  Static Function
@author Carlos Pister
@since  14/07/2026
@param cAlias,      Character, Alias da query do SF3
@param cAliasSA2,   Character, Alias do SA2 (prestador) - usado em DbSelectArea + DbSeek
@param lVisDirf,    Logical,   .T. se MV_VISDIRF=1 (F3_RECISS prevalece sobre A2_RECISS)
@param aDocRet,     array contendo os documentos
@return
/*/
Static Function MntDocsRec(cAlias, cAliasSA2, lVisDirf, aDocRet)

Local aAreaAnt    := FwGetArea()
Local cTipoDoc    := ""
Local cSerie      := ""
Local cNumero     := ""
Local cDtEmissao  := ""
Local cIndRet     := "N"
Local cCodServico := ""
Local cValorNota  := ""
Local cInscMun    := ""
Local cCNPJ       := ""
Local cCPF        := ""
Local cNome       := ""
Local cAliqSimp   := ""
Local nAliq       := 0

// Dados do SF3
cTipoDoc   := AllTrim((cAlias)->F3_ESPECIE)
cSerie     := AllTrim((cAlias)->F3_SERIE)
cNumero    := AllTrim(RetNf((cAlias)->F3_NFISCAL, 9, "N"))
cDtEmissao := StrZero(Day(STOD((cAlias)->F3_EMISSAO)), 2) + "/" + ;
              StrZero(Month(STOD((cAlias)->F3_EMISSAO)),2) + "/" + ;
              StrZero(Year(STOD((cAlias)->F3_EMISSAO)), 4)

// Codigo do servico no formato Grupo.Atividade (ex: 10.01)
cCodServico := FormCodIss(AllTrim((cAlias)->F3_CODISS))

// Valor da nota com ponto decimal
cValorNota := StrTran(AllTrim(Transform((cAlias)->F3_VALCONT, "@E 999999999999.99")),",", ".") 

DbSelectArea(cAliasSA2)
DbSetOrder(1)
If DbSeek(xFilial(cAliasSA2) + (cAlias)->F3_CLIEFOR + (cAlias)->F3_LOJA)
    // Indicativo de retencao:
    //   MV_VISDIRF=1 -> usa F3_RECISS do documento
    //   Caso contrario -> usa A2_RECISS do cadastro do fornecedor
    If lVisDirf
        If (cAlias)->F3_RECISS $ "2N"
            cIndRet := "S"
        Else
            cIndRet := "N"
        EndIf
    Else
        If (cAliasSA2)->A2_RECISS $ "2N" .Or. Empty((cAliasSA2)->A2_RECISS)
            cIndRet := "S"
        Else
            cIndRet := "N"
        EndIf
    EndIf

    // Inscricao municipal: somente quando o prestador e de Osasco
    If "OSASCO" $ Upper(AllTrim((cAliasSA2)->A2_MUN))
        cInscMun := AllTrim((cAliasSA2)->A2_INSCRM)
    EndIf

    If (cAliasSA2)->A2_TIPO == "J"
        cCNPJ := AllTrim((cAliasSA2)->A2_CGC)
        cCPF  := ""
    Else
        cCNPJ := ""
        cCPF  := AllTrim((cAliasSA2)->A2_CGC)
    EndIf

    cNome := AllTrim((cAliasSA2)->A2_NOME)

    // Aliquota Simples Nacional: somente quando optante (A2_SIMPNAC="1")
    // Formato NNN: 200=2%, 258=2,58%
    If (cAliasSA2)->A2_SIMPNAC == "1"
        nAliq     := (cAlias)->F3_ALIQICM
        cAliqSimp := AllTrim(Str(Round(nAliq * 100, 0), 3, 0))
    EndIf
EndIf

aAdd(aDocRet, {cTipoDoc, cSerie, cNumero, cDtEmissao, cIndRet, cCodServico, cValorNota, cInscMun, cCNPJ, cCPF, cNome, cAliqSimp})

FwRestArea(aAreaAnt)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} GrvDocDR
Monta uma linha de detalhe do tipo DR (Documento Recebido) para o
arquivo CSV da DMS Osasco/SP.
Formato:
DR;[TipoDoc];[Serie];[Numero];[DtEmissao];[IndRetencao];[CodServico];
   [ValorNota];[InscMunPrestador];[CNPJ];[CPF];[NomePrestador];[AliqSimples]
@type  Static Function
@author Carlos Pister
@since  14/07/2026
@param oArquivo
@param aDocRet
@return
/*/
Static Function GrvDocDR(oArquivo, aDocRet)

Local nI := 0

Default oArquivo := Nil
Default aDocRet := {}

For nI := 1 To Len(aDocRet)

    oArquivo:write("DR"             + ";" + ; //Identificador do tipo de registro (DR)
                   aDocRet[nI][01]  + ";" + ; //Tipo do Documento
                   aDocRet[nI][02]  + ";" + ; //Serie do Documento
                   aDocRet[nI][03]  + ";" + ; //Número do Documento
                   aDocRet[nI][04]  + ";" + ; //Data de Emissão
                   aDocRet[nI][05]  + ";" + ; //Indicativo de Retenção (S ou N)
                   aDocRet[nI][06]  + ";" + ; //Código do Serviço (informado no padrão Grupo.Atividade. Ex. 10.01, 7.02)
                   aDocRet[nI][07]  + ";" + ; //Valor da Nota (deverá ser utilizado o ‘.’ como separador decimal. Ex. 1500.23)
                   aDocRet[nI][08]  + ";" + ; //Inscrição Municipal do Prestador (quando inscrito em Osasco)
                   aDocRet[nI][09]  + ";" + ; //CNPJ do prestador (quando PJ)
                   aDocRet[nI][10]  + ";" + ; //CPF do prestador (quando PF)
                   aDocRet[nI][11]  + ";" + ; //Nome do prestador
                   aDocRet[nI][12]  + Chr(13) + Chr(10)) //Alíquota Simples Nacional

Next nI 

Return

//------------------------------------------------------------------
/*/{Protheus.doc} GrvDocRT
Monta uma linha de detalhe do tipo RT (Documento de Retencao) para o
arquivo CSV da DMS Osasco/SP.
Formato:
RT;[TipoDoc];[Serie];[Numero];[DtEmissao];[CodServico];[ValorNota];
   [AliqSimples];[CNPJ];[CPF];[NomeTomador]
@type  Static Function
@author Carlos Pister
@since  14/07/2026
@return
/*/
Static Function GrvDocRT(oArquivo, aDocRet, cCNPJ, cCPF, cRazao)

Local nI := 0

Default oArquivo := Nil
Default aDocRet := {}
Default cCNPJ  := ""
Default cCPF   := ""
Default cRazao := ""

For nI := 1 To Len(aDocRet)

    If aDocRet[nI][05] == "S"

        oArquivo:write("RT"             + ";" + ; //Identificador do tipo de registro (RT)
                       aDocRet[nI][01]  + ";" + ; //Tipo do Documento
                       aDocRet[nI][02]  + ";" + ; //Serie do Documento 
                       aDocRet[nI][03]  + ";" + ; //Número do Documento
                       aDocRet[nI][04]  + ";" + ; //Data de Emissão
                       aDocRet[nI][06]  + ";" + ; //Código do Serviço (informado no padrão Grupo.Atividade. Ex. 10.01, 7.02
                       aDocRet[nI][07]  + ";" + ; //Valor da Nota
                       aDocRet[nI][12]  + ";" + ; //Alíquota(específica para prestador enquadrado no Simples Nacional)
                       cCNPJ            + ";" + ; //CNPJ do Tomador (quando PJ) 
                       cCPF             + ";" + ; //CPF do Tomador (quando PF)
                       cRazao + Chr(13) + Chr(10)) //Nome do Tomador
    EndIf

Next nI 

Return

//------------------------------------------------------------------
/*/{Protheus.doc} FormCodIss
Converte o codigo de servico ISS do formato interno do Protheus
(ex: "10.01   " ou "1001") para o formato Grupo.Atividade exigido
no layout (ex: "10.01").
@type  Static Function
@author Carlos Pister
@since  14/07/2026
@param cCodISS, Character, Codigo de servico ISS do campo F3_CODISS
@return Character, Codigo formatado como Grupo.Atividade
/*/
Static Function FormCodIss(cCodISS)

Local cResult := ""

cResult := AllTrim(cCodISS)

If !Empty(cResult) .and. At(".", cResult) == 0 .and. Len(cResult) >= 3
    cResult := Left(cCodISS, 2) + "." + SubStr(cCodISS, 3)
EndIf

Return cResult
