#INCLUDE "LOCA086.CH" 
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"                                                                                                   
#INCLUDE "PROTHEUS.CH"

/*/{PROTHEUS.DOC} LOCA086.PRW
ITUP BUSINESS - TOTVS RENTAL
PROJETOS - REAJUSTE DE VALORES
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/04/2024
@HISTORY 15/04/2024, FRANK ZWARG FUGA, CRIACAO DO FONTE
/*/

FUNCTION LOCA086( aExecAuto, aFil1, cSeqx )
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local lRet      := .T.
Local cPerg     := "LOCP078"
Local a1Struct  := {} 
Local nP
Local cProjeto

Private lAuto := .F.
Private MVPAR01 // Tipo do calculo
Private MVPAR02 // Projeto de
Private MVPAR03 // Projeto até
Private MVPAR04 // Data de
Private MVPAR05 // Data até
Private MVPAR06 // Bem de
Private MVPAR07 // Bem até
Private MVPAR08 // Indice de reajuste
Private MVPAR09 // Cliente de
Private MVPAR10 // Loja de
Private MVPAR11 // Cliente até
Private MVPAR12 // Local até
Private MVPAR13 // Produto de
Private MVPAR14 // Produto até
Private MVPAR15 // Localidade de
Private MVPAR16 // Localidade até
Private MVPAR17 // Data de aniversário de
Private MVPAR18 // Data de aniversário até
Private MVPAR19 // Atualiza data de aniversário
Private MVPAR20 // Fator de Reajuste
Private MVPAR21 // Calcular automático
Private MVPAR22 // Atualiza a medição
Private aEsp := {} // campos customizados do cliente
Private cSeq := "" // uso na rotina automatica
Private lProvis := .T. // uso na rotina automatica
Private cObsAut := ""  // uso na rotina automatica
Private dNiverAut 

Default aExecAuto := {}
Default aFil1 := {}
Default cSeqx := ""

    If len(aExecAuto) > 0
        lAuto := .T.
        
        If !lMvLocBac
            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
            Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
            {STR0003}) //"Uso obrigatório do parâmetro habilitado MV_LOCBAC."
            lRet := .F.
            LMSERROAUTO := .T.
        EndIf

        If !empty(cSeqx) .and. aExecAuto[01] == 2 // estorno
            lAuto := .T.

            MVPAR19 := aExecAuto[2]

            If !LOCA08G(cSeqx)
                LMSERROAUTO := .T.
                Return .F.
            Else
                LMSERROAUTO := .F.        
                Return .T.
            EndIf
        EndIF

        If len(aFil1) == 0 .and. lRet
            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
            Nil,STR0002+STR0082,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."+"Falta identificar a sequência."
            {""}) 
            lRet := .F.
            LMSERROAUTO := .T.
        Else
            cSeq        := aFil1[1]
            lProvis     := aFil1[2]
            cObsAut     := aFil1[3]
            dDtAute     := aFil1[4]
            dNiverAut   := aFil1[5]
        EndIf

        If lRet .and. empty(dDtAute)
            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
            Nil,STR0002+STR0086,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."+"Erro na passagem do FPA->FPA_DTENRE."
            {""}) 
            lRet := .F.
            LMSERROAUTO := .T.
        EndIf

        //If len(aExecAuto) < 21 .and. lRet
        //    Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
        //    Nil,STR0002+STR0006,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."###"Erro na passagem dos parâmetros."
        //    {STR0005}) //"Falta de parâmetros para o processamento."     
        //    lRet := .F.
        //Else
            MVPAR01 := aExecAuto[01]
            MVPAR02 := aExecAuto[02]
            MVPAR03 := aExecAuto[03]
            MVPAR04 := aExecAuto[04]
            MVPAR05 := aExecAuto[05]
            MVPAR06 := aExecAuto[06]
            MVPAR07 := aExecAuto[07]
            MVPAR08 := aExecAuto[08]
            MVPAR09 := aExecAuto[09]
            MVPAR10 := aExecAuto[10]
            MVPAR11 := aExecAuto[11]
            MVPAR12 := aExecAuto[12]
            MVPAR13 := aExecAuto[13]
            MVPAR14 := aExecAuto[14]
            MVPAR15 := aExecAuto[15]
            MVPAR16 := aExecAuto[16]
            MVPAR17 := aExecAuto[17]
            MVPAR18 := aExecAuto[18]
            MVPAR19 := aExecAuto[19]
            MVPAR20 := aExecAuto[20]
            MVPAR21 := aExecAuto[21]
            If len(aExecAuto) > 21
                MVPAR22 := aExecAuto[22]
            Else
                MVPAR22 := 2
            EndIF
        //EndIF

        If lRet .and. (MVPAR15 <> MVPAR16 .or. empty(MVPAR15) .or. empty(MVPAR16))
            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
            Nil,STR0002+STR0083,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."+"O parâmetro obra de/até tem que ser a mesma e não pode estar em branco."
            {""}) 
            lRet := .F.
            LMSERROAUTO := .T.
        EndIF

        If lRet .and. (MVPAR02 <> MVPAR03 .or. empty(MVPAR02) .or. empty(MVPAR03))
            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
            Nil,STR0002+STR0084,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."+"O parâmetro projeto de/até tem que ser o mesmo e não pode estar em branco."
            {""}) 
            lRet := .F.
            LMSERROAUTO := .T.
        EndIF

        If lRet .and. (MVPAR22 == 1)
            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
            Nil,STR0002+STR0090,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."+"Reajuste da medição disponível somente no próximo release."
            {""}) 
            lRet := .F.
            LMSERROAUTO := .T.
        EndIF

    Else
        
        If !lMvLocBac
            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
            Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
            {STR0003}) //"Uso obrigatório do parâmetro habilitado MV_LOCBAC."
            lRet := .F.
        EndIf

        If lRet
            If !Pergunte(cPerg,.T.)
                Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
                Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
                {STR0004}) //"Processo cancelado pelo usuário."  
                lRet := .F.
            Else
                MVPAR01 := MV_PAR01
                MVPAR02 := MV_PAR02
                MVPAR03 := MV_PAR03
                MVPAR04 := MV_PAR04
                MVPAR05 := MV_PAR05
                MVPAR06 := MV_PAR06
                MVPAR07 := MV_PAR07
                MVPAR08 := MV_PAR08
                MVPAR09 := MV_PAR09
                MVPAR10 := MV_PAR10
                MVPAR11 := MV_PAR11
                MVPAR12 := MV_PAR12
                MVPAR13 := MV_PAR13
                MVPAR14 := MV_PAR14
                MVPAR15 := MV_PAR15
                MVPAR16 := MV_PAR16
                MVPAR17 := MV_PAR17
                MVPAR18 := MV_PAR18
                MVPAR19 := MV_PAR19
                MVPAR20 := MV_PAR20
                MVPAR21 := MV_PAR21
                If type("MV_PAR22") == "N"
                    MVPAR22 := MV_PAR22
                Else
                    MVPAR22 := 2
                EndIF
            EndIf
            If MVPAR22 == 1
                MsgAlert(STR0090,STR0008) //"Reajuste da medição disponível somente no próximo release."###"Atenção!"
                Return .f.
            EndIf
        EndIF
    EndIf

    If lRet
        a1Struct := FWSX3Util():GetListFieldsStruct( "FPA", .F.)
        For nP := 1 to len(a1Struct)
            If x3Usado( a1Struct[nP][01] ) .and. GetSx3Cache(a1Struct[nP][01],"X3_TIPO") <> "M"
                If GetSx3Cache(a1Struct[nP][01],"X3_PROPRI") == "U" .and. GetSx3Cache(a1Struct[nP][01],"X3_CONTEXT") == "R"
                    aadd(aEsp,{a1Struct[nP][01],alltrim(GetSx3Cache(a1Struct[nP][01],"X3_TITULO"))})    
                EndIF
            EndIf
        Next
    EndIf

    cProjeto := alltrim(MVPAR02)
    cProjeto += replicate(" ",tamsx3("FP0_PROJET")[1]-len(cProjeto))
    FPA->(dbSetOrder(1))
    If !lAuto
        MVPAR02 := MV_PAR02
        MVPAR15 := MV_PAR15
    EndIF
    If !FPA->(dbSeek(xFilial("FPA")+MVPAR02+MVPAR15+cSeq)) .and. lAuto
        Return .f.
    EndIf


    If lRet
        If MVPAR01 == 1
            lRet := LOCA086A() // realiza o reajuste
        Else
            lRet := LOCA086B() // realiza o estorno do reajuste
        EndIF
    EndIF

    If !lRet
        LMSERROAUTO := .T.
    Else
        LMSERROAUTO := .F.
    EndIF

Return lRet

/*/{PROTHEUS.DOC} LOCA086A
ITUP BUSINESS - TOTVS RENTAL
PROJETOS - REAJUSTE DE VALORES 
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/04/2024
@HISTORY 15/04/2024, FRANK ZWARG FUGA, CRIACAO DO FONTE
/*/

Function LOCA086A
Local lRet := .T.
Local aSize := MsAdvSize(.t.)
Local oOk
Local oNo
Local aObjects  := {}
Local aInfo
Local aPosObj
Local cTitulo := STR0007 // "Reajuste de projetos."
Local oDlg
Local nGrava := 0
Local cTemp
Local nTemp
Local cVarGrp
Local nZ
Local oScr
Local nLin
Local nValor := 0
Local dFim := ctod("")
Local dProx := ctod("")
Local dAniv := ctod("")
Local nKm1 := 0
Local nValor2 := 0
Local dFim2 := ctod("")
Local dProx2 := ctod("")
Local dAniv2 := ctod("")
Local cObs := space(100)
Local nTotal := 0
Local nTotaln := 0
Local nDesc := 0
Local nAcres := 0
Local lContinua := .T.

Private oVlr
Private ofim
Private oprox
Private oani
Private oVlr2
Private ofim2
Private oprox2
Private oani2
Private oObs
Private oKmi
Private oKmf
Private nKm2 := 0
Private lInverte := .F.
Private oTotal
Private oTotaln
Private oDesc
Private oAcres
Private nPVlrn
Private nPVlro
Private nPDes
Private nPAcre
Private nPQtd
Private nPRecno
Private aItens := {}
Private oListP5
Private nTot 

    If !lAuto
        oOk := LoadBitmap( GetResources(), "LBOK")
        oNo := LoadBitmap( GetResources(), "LBNO")
        // Redimensionamento da tela
        AAdd( aObjects, {  100,  30, .T., .T. } ) // MsSelect
        AAdd( aObjects, {  100,  70, .T., .T. } ) // GetFixo
        
        aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 } 
        aPosObj := MsObjSize( aInfo, aObjects,.T.) 
    EndIf
    
    If !lAuto
        Processa( {|| lContinua := LOCA086C() }, STR0010 ) //"Localizando os projetos válidos."
    Else
        lContinua := LOCA086C()
    EndIF
    
    If !lContinua
        Return .F.
    EndIf

    If !lAuto
        DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],00 To aSize[6],aSize[5] of oMainWnd PIXEL

        @ aPosObj[1][1],aPosObj[1][2] LISTBOX oListP5 VAR cVarGrp FIELDS HEADER "";
        SIZE aPosObj[1][4],aPosObj[1][3] ON DBLCLICK ( aItens[oListP5:nAt,1] := !aItens[oListP5:nAt,1],oListP5:Refresh() ) OF oDlg PIXEL

        aadd(oListP5:aheaders,STR0019) //"Projeto"
        aadd(oListP5:aheaders,STR0020) //"Cliente"
        aadd(oListP5:aheaders,STR0021) //"Loja"
        aadd(oListP5:aheaders,STR0022) //"Nome Cliente"
        aadd(oListP5:aheaders,STR0023) //"Obra"
        aadd(oListP5:aheaders,STR0024) //"Sequencia"
        aadd(oListP5:aheaders,STR0025) //"Produto"
        aadd(oListP5:aheaders,STR0026) //"Nome Produto"
        aadd(oListP5:aheaders,STR0027) //"Bem"
        aadd(oListP5:aheaders,STR0028) //"Nome Bem"
        aadd(oListP5:aheaders,STR0029) //"AS"
        aadd(oListP5:aheaders,STR0030) //"Valor parcela antigo"
        aadd(oListP5:aheaders,STR0031) //"Valor parcela novo"
        aadd(oListP5:aheaders,STR0032) //"Indice aplicado"
        aadd(oListP5:aheaders,STR0033) //"Tipo de indice"
        aadd(oListP5:aheaders,STR0034) //"Tipo de calculo"
        aadd(oListP5:aheaders,STR0035) //"Aniversario antigo"
        aadd(oListP5:aheaders,STR0036) //"Aniversario novo"
        aadd(oListP5:aheaders,STR0037) //"Data fim antigo"
        aadd(oListP5:aheaders,STR0038) //"Data fim novo"
        aadd(oListP5:aheaders,STR0039) //"Prox.fat. antigo"
        aadd(oListP5:aheaders,STR0040) //"Prox.fat. novo"
        aadd(oListP5:aheaders,STR0041) //"Observacao"
        If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
            aadd(oListP5:aheaders,STR0042) //"Vl.Uni.Franq antigo"
            aadd(oListP5:aheaders,STR0043) //"Vl.Uni.Franq novo"
        EndIF

        aadd(oListP5:aheaders,STR0044) //"Quantidade"
        aadd(oListP5:aheaders,STR0045) //"Total antigo"
        aadd(oListP5:aheaders,STR0046) //"Total novo"
        aadd(oListP5:aheaders,STR0047) //"Acréscimo"
        aadd(oListP5:aheaders,STR0048) //"Desconto"

        For nZ := 1 to len(aEsp)
            aadd(oListP5:aheaders,aEsp[nZ,2])
        Next

        oListP5:REFRESH()

        oListP5:SetArray(aItens)
        oListP5:REFRESH()
        oListP5:bChange := {|| LOCA086D()}
        oListP5:bHeaderClick = {|| LOCA086E()}

        cTemp := "{||{ If(aItens[oListP5:nAt,1],oOk,oNo),"
        cTemp += "aItens[oListP5:nAt,2],"
        cTemp += "aItens[oListP5:nAt,3],"
        cTemp += "aItens[oListP5:nAt,4],"
        cTemp += "aItens[oListP5:nAt,5],"
        cTemp += "aItens[oListP5:nAt,6],"
        cTemp += "aItens[oListP5:nAt,7],"
        cTemp += "aItens[oListP5:nAt,8],"
        cTemp += "aItens[oListP5:nAt,9],"
        cTemp += "aItens[oListP5:nAt,10],"
        cTemp += "aItens[oListP5:nAt,11],"
        cTemp += "aItens[oListP5:nAt,12],"
        cTemp += "aItens[oListP5:nAt,13],"
        cTemp += "aItens[oListP5:nAt,14],"
        cTemp += "aItens[oListP5:nAt,15],"
        cTemp += "aItens[oListP5:nAt,16],"
        cTemp += "aItens[oListP5:nAt,17],"
        cTemp += "aItens[oListP5:nAt,18],"
        cTemp += "aItens[oListP5:nAt,19],"
        cTemp += "aItens[oListP5:nAt,20],"
        cTemp += "aItens[oListP5:nAt,21],"
        cTemp += "aItens[oListP5:nAt,22],"
        cTemp += "aItens[oListP5:nAt,23],"
        If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
            cTemp += "aItens[oListP5:nAt,24],"
            cTemp += "aItens[oListP5:nAt,25],"
            cTemp += "aItens[oListP5:nAt,26],"
            cTemp += "aItens[oListP5:nAt,27]," 
            cTemp += "aItens[oListP5:nAt,28]," 
            cTemp += "aItens[oListP5:nAt,29]," 
            cTemp += "aItens[oListP5:nAt,30]," 
            cTemp += "aItens[oListP5:nAt,31]" 
            nTemp := 32
        Else
            cTemp += "aItens[oListP5:nAt,24],"
            cTemp += "aItens[oListP5:nAt,25]," 
            cTemp += "aItens[oListP5:nAt,26]," 
            cTemp += "aItens[oListP5:nAt,27]," 
            cTemp += "aItens[oListP5:nAt,28]," 
            cTemp += "aItens[oListP5:nAt,29]" 
            nTemp := 30
        EndIF

        For nZ := 1 to len(aEsp)
            cTemp += ",aItens[oListP5:nAt,"+alltrim(str(nTemp))+"]"
            nTemp ++
        Next
        cTemp += "}}"

        oListP5:bLine := &(cTemp)
        oListP5:REFRESH()

        oScr := TScrollBox():New(oDlg, aPosObj[2][1]+aPosObj[1][1], aPosObj[2][2],aPosObj[2][1]+15,aPosObj[2][4],.T.,.T.,.T.) 

        nLin := 5
        @ nLin,5 SAY STR0050 Pixel Of oScr //"Valor unitário reajustado: "
        nLin += 13
        @ nLin,5 SAY STR0051 Pixel Of oScr //"Data final: "
        nLin += 13
        @ nLin,5 SAY STR0052 Pixel Of oScr //"Próximo faturamento: "
        nLin += 13
        @ nLin,5 SAY STR0053 Pixel Of oScr //"Data do aniversário: "
        nLin += 13
        If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
            @ nLin,5 SAY STR0054 Pixel Of oScr //"Vl.Uni.Franq reajustado: "
            nLin += 13
        EndIF
        @ nLin,aPosObj[2][2] SAY STR0055 Pixel Of oScr //"Valor Total:"

        nLin := 5  
        @ nLin,350 SAY STR0064 Pixel Of oScr //"Observação: "        
        
        @ nLin,180 SAY STR0056 Pixel Of oScr //"Valor unitário original: "
        nLin += 13
        @ nLin,180 SAY STR0057 Pixel Of oScr //"Data final original: "
        nLin += 13
        @ nLin,180 SAY STR0058 Pixel Of oScr //"Próximo faturamento original: "
        nLin += 13
        @ nLin,180 SAY STR0059 Pixel Of oScr //"Data do aniversário original: "
        nLin += 13
        If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
            @ nLin,180 SAY STR0060 Pixel Of oScr //"Vl.Uni.Franq original: "
            nLin += 13
        EndIF
        @ nLin,180 SAY STR0061 Pixel Of oScr //"Valor total original: "
        nLin += 13
        @ nLin,180 SAY STR0062 Pixel Of oScr //"Acréscimo:"
        nLin += 13
        @ nLin,180 SAY STR0063 Pixel Of oScr //"Desconto:"

        nLin := 5
        @ nLin,75 MSGET oVlr var nValor PICTURE("99999999.99") when .f. Size  50,10 Pixel Of oScr
        nLin += 13
        @ nLin,75 MSGET oFim var dFim valid LOCA086F("FIM") Size  50,10 Pixel Of oScr
        nLin += 13
        @ nLin,75 MSGET oProx var dProx valid LOCA086F("PROX") Size  50,10 Pixel Of oScr
        nLin += 13
        @ nLin,75 MSGET oAni var dAniv valid LOCA086F("NIVER") Size  50,10 Pixel Of oScr
        nLin += 13
        If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
            @ nLin,75 MSGET oKmf var nKm2 PICTURE("99999999.99") valid LOCA086F("KM") Size  50,10 Pixel Of oScr when .f.
            nLin += 13
        EndIF
        @ nLin,75 MSGET oTotaln var nTotaln valid LOCA086F("TOTAL") PICTURE("99999999.99") Size  50,10 Pixel Of oScr

        nLin := 5
        @ nLin,270 MSGET oVlr2 var nValor2 PICTURE("99999999.99") Size  50,10 Pixel Of oScr when .f.
        nLin += 13
        @ nLin,270 MSGET ofim2 var dFim2 Size  50,10 Pixel Of oScr when .f.
        @ nLin,350 MSGET oObs var cObs Size  150,10 Pixel Of oScr valid LOCA086F("OBS")
        nLin += 13
        @ nLin,270 MSGET oprox2 var dProx2 Size  50,10 Pixel Of oScr when .f.
        nLin += 13
        @ nLin,270 MSGET oani2 var dAniv2 Size  50,10 Pixel Of oScr when .f.
        nLin += 13
        If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
            @ nLin,270 MSGET oKmi var nKm1 PICTURE("99999999.99") Size  50,10 Pixel Of oScr when .f.
            nLin += 13
        EndIF
        @ nLin,270 MSGET oTotal var nTotal PICTURE("99999999.99") Size  50,10 Pixel Of oScr when .f.
        nLin += 13
        @ nLin,270 MSGET oAcres var nAcres PICTURE("99999999.99") Size  50,10 Pixel Of oScr when .f.
        nLin += 13
        @ nLin,270 MSGET oDesc var nDesc PICTURE("99999999.99") Size  50,10 Pixel Of oScr when .f.

        Activate MsDialog oDlg CENTERED On Init EnchoiceBar(oDlg,{|| If(MsgYesNo(STR0009,STR0008),If(.T.,(nGrava:=1,oDlg:end()),.F.) ,.F.)},{|| oDlg:end()},,) //"Confirma a gravação dos registros?"###"Atenção!"
    Else
        //If len(aItens) == 0 .or. len(aItens) > 1
        //    Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
        //    Nil,STR0002+STR0085,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."+"Nenhum projeto foi localizado para execução."
        //    {""}) 
        //    lRet := .F.
        //    LMSERROAUTO := .T.
        //Else
            nTot := 0
            ProcReaj()
            lRet := .T.
        //Endif
    EndIf

    If nGrava == 1 .and. !lAuto
       nTot := 0
       Processa({|| ProcReaj() }, STR0068, STR0067, .t.) //"Gravando os reajustes." ####  "Aguarde..."
       MsgAlert(STR0071+alltrim(str(nTot))+STR0070,STR0069) //"Processo realizado com sucesso, "###" contrato(s) reajustado(s)."###"Reajuste Contratual!"
       lRet := .T.
    EndIF

Return lRet


/*/{PROTHEUS.DOC} LOCA086B
ITUP BUSINESS - TOTVS RENTAL
PROJETOS - REAJUSTE DE VALORES (ESTORNO)
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/04/2024
@HISTORY 15/04/2024, FRANK ZWARG FUGA, CRIACAO DO FONTE
/*/

Function LOCA086B()
Local lRet := .T.
Local cFiltro := ""
PRIVATE cCadastro := STR0072 //"Estorno dos reajustes"

    dbSelectArea("FQ9")
    dbSetOrder(1)

    cFiltro := "FQ9_PROJET >= '"+MVPAR02+"' and FQ9_PROJET <= '"+MVPAR03+"' "
    cFiltro += "and FQ9_OBRA >= '"+MVPAR15+"' and FQ9_OBRA <= '"+MVPAR16+"' "
    cFiltro += "and FQ9_PRODUT >= '"+MVPAR13+"' and FQ9_PRODUT <= '"+MVPAR14+"' "
    cFiltro += "and FQ9_GRUA >= '"+MVPAR06+"' and FQ9_GRUA <= '"+MVPAR07+"' "
    IF !empty(MVPAR17) .or. !empty(MVPAR18)
        cFiltro += "and FQ9_ANIVE2 >= '"+dtos(MVPAR17)+"' and FQ9_ANIVE2 <= '"+dtos(MVPAR18)+"' "
    EndIF
    IF !empty(MVPAR04) .or. !empty(MVPAR05)
        cFiltro += "and FQ9_DATA >= '"+dtos(MVPAR04)+"' and FQ9_DATA <= '"+dtos(MVPAR05)+"' "
    EndIF
    IF !empty(MVPAR08)
        cFiltro += "and FQ9_INDICE = '"+MVPAR08+"' "
    EndIF


    PRIVATE AROTINA := {{STR0073 ,"AXPESQUI"  ,0,1},; //"Pesquisar"
                        {STR0074 ,"AXVISUAL"  ,0,2},; //"Visualizar"
                        {STR0075 ,"LOCA08G"   ,0,4}}  //"Restaurar"

    MBROWSE( 6,1,22,75, "FQ9" ,,,,,,,,,,,,,,cFiltro)

Return lRet

/*/{PROTHEUS.DOC} LOCA086C
ITUP BUSINESS - TOTVS RENTAL
PROJETOS - REAJUSTE DE VALORES (LOCALIZA OS PROJETOS VALIDOS PARA O REAJUSTE)
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/04/2024
@HISTORY 15/04/2024, FRANK ZWARG FUGA, CRIACAO DO FONTE
/*/

Function LOCA086C()
Local lRet := .T.
Local cQuery := ""
Local nX := 0
Local nZ := 0
Local nIndice := 0
Local aArea := GetArea()
Local aResult := {}
Local aButtons := {}
Local aSays := {}
Local lContinua := .T.
Local aBindParam := {}
Local nTemp
Local nTempAcr

    If !lAuto
        ProcRegua(3)
    Endif

    cQuery := "SELECT FPA.R_E_C_N_O_ AS REG "
    cQuery += "FROM "+RetSqlName("FPA")+" FPA "
    cQuery += "INNER JOIN "+RetSqlName("FP0")+" FP0 ON FP0.FP0_FILIAL = FPA.FPA_FILIAL AND FP0.FP0_PROJET = FPA.FPA_PROJET "
    cQuery += " AND FP0.D_E_L_E_T_ = '' AND FP0.FP0_CLI >= ? AND FP0.FP0_CLI <= ? "
    aadd(aBindParam,MVPAR09)
    aadd(aBindParam,MVPAR11)
    cQuery += " AND FP0.FP0_LOJA >= ? AND FP0.FP0_LOJA <= ? AND FP0.FP0_CLI > '' "
    aadd(aBindParam,MVPAR10)
    aadd(aBindParam,MVPAR12)
    cQuery += " AND FP0.FP0_STATUS NOT IN ('6','7','A','B','C','8') "
    cQuery += "WHERE FPA.D_E_L_E_T_ = '' " 
    cQuery += " AND FPA.FPA_FILIAL = ? "
    aadd(aBindParam,xFilial("FPA"))

    // Filtro especial para msexecauto - sequencia da FPA
    If !empty(cSeq)
        cQuery += " AND FPA.FPA_SEQGRU = ? "
        aadd(aBindParam,cSeq)
    EndIf

    cQuery += " AND FPA.FPA_PROJET >= ? "
    aadd(aBindParam,MVPAR02)
    cQuery += " AND FPA.FPA_PROJET <= ? "
    aadd(aBindParam,MVPAR03)
    cQuery += " AND FPA.FPA_DTINI >= ? "
    aadd(aBindParam,dtos(MVPAR04))
    cQuery += " AND FPA.FPA_DTINI <= ? "
    aadd(aBindParam,dtos(MVPAR05))
    cQuery += " AND FPA.FPA_GRUA >= ? "
    aadd(aBindParam,MVPAR06)
    cQuery += " AND FPA.FPA_GRUA <= ? "
    aadd(aBindParam,MVPAR07)
    IF !empty(MVPAR08)
        cQuery += " AND FPA.FPA_AJUSTE = ? "
        aadd(aBindParam,MVPAR08)
    EndIF
    cQuery += " AND FPA.FPA_PRODUT >= ? "
    aadd(aBindParam,MVPAR13)
    cQuery += " AND FPA.FPA_PRODUT <= ? "
    aadd(aBindParam,MVPAR14)
    If !empty(MVPAR17)
        cQuery += " AND FPA.FPA_NIVER >= ? "
        aadd(aBindParam,dtos(MVPAR17))
    EndIF
    If !empty(MVPAR18)
        cQuery += " AND FPA.FPA_NIVER <= ? "
        aadd(aBindParam,dtos(MVPAR18))
    EndIF
    cQuery += " AND FPA.FPA_OBRA >= ? "
    aadd(aBindParam,MVPAR15)
    cQuery += " AND FPA.FPA_OBRA <= ? "
    aadd(aBindParam,MVPAR16)
    cQuery += " AND FPA.FPA_QUANT > 0 "
    cQuery += " AND FPA.FPA_NFRET = '' " // Frank em 14/07/22 Card 429 sprint bug
    cQuery += " AND FPA.FPA_TIPOSE <> 'S' " // Frank em 14/07/22 Card 429 sprint bug
    cQuery += "ORDER BY FPA_PROJET, FPA_OBRA, FPA_SEQGRU "

    If Select("TFPA") > 0 
        TFPA->(dbCloseArea()) 
    EndIf 

    cQuery := CHANGEQUERY(cQuery) 

    MPSysOpenQuery(cQuery,"TFPA",,,aBindParam)

    If !lAuto
        IncProc(STR0011) //"Seleção dos registros."
    EndIf

    If TFPA->(Eof())
        If !lAuto
            MsgAlert(STR0087,STR0076) // "O registro do reajuste não foi localizado."###"Processo bloqueado."
            Return .F.
        Else
            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
            Nil,STR0087+STR0076,1,0,Nil,Nil,Nil,Nil,Nil,; //"O registro do reajuste não foi localizado."###"Processo bloqueado."
            {""}) 
            Return .F.
        EndIF
    EndIF

    While !TFPA->(Eof())

        FPA->(dbGoto(TFPA->REG))

        // Card DSERLOCA-1911 - Frank em 02/01/24
        If (FPA->FPA_TIPOSE == "Z" .and. !empty(FPA->FPA_ULTFAT)) .or. FPA->FPA_TIPOSE == "S"
            TFPA->(dbSkip())
            LOOP
        EndIF

        //Proteção para quando nao é alterado o pergunte
        If ValType(MVPAR21) == "N"
            MVPAR21 := cValToChar(MVPAR21)
        EndIf

        //valida reajuste automatico
        If MVPAR21 == "1"
            If Empty(FPA->FPA_AJUSTE) .Or. Empty(FPA->FPA_NIVER)
                If Len(aSays) == 0
                    Aadd(aSays, STR0012) //"Para Reajuste Automático é obrigatório preencher o índice [FPA_AJUSTE] e "
                    Aadd(aSays, STR0013) //"o aniversário [FPA_NIVER]."
                    Aadd(aSays, STR0014) //"Itens não preenchidos (Filial + Projeto + Obra + Seq):"
                EndIf
                Aadd(aSays, FPA->FPA_FILIAL + FPA->FPA_PROJET + FPA->FPA_OBRA + FPA->FPA_SEQGRU ) 
                lContinua := .F.
            EndIf
        EndIf

        If lContinua

            FP0->(dbSetOrder(1))
            FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))
            //If empty(FP0->FP0_CLI)
            //    TFPA->(dbSkip())
            //    Loop
            //EndIf
            SA1->(dbSetOrder(1))
            SA1->(dbSeek(xFilial("SA1")+FP0->FP0_CLI+FP0->FP0_LOJA))
            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))
            ST9->(dbSetOrder(1))
            ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))

            // Melhoria feita em 16/12/21 por Frank card 215
            //SIGALOC94-624 - 26/06/2023- Jose Eulalio - Lui informou que não deve ser consideramo esse parametro
            If !Empty(FPA->FPA_DTPRRT) 
                If dDataBase >= FPA->FPA_DTPRRT
                    TFPA->(dbSkip())
                    Loop
                EndIF
            EndIf

            If MVPAR21 == "1"
                If !lAuto
                    IncProc(STR0018) //"Calculando o Indice acumulado."
                EndIf
                nIndice := ValIndice(FPA->FPA_AJUSTE,FPA->FPA_NIVER)
            Else
                nIndice := MVPAR20
            EndIf

            aadd(aResult,{ .T.,;
                            FPA->FPA_PROJET,;
                            FP0->FP0_CLI,;
                            FP0->FP0_LOJA,;
                            SA1->A1_NOME,;
                            FPA->FPA_OBRA,;
                            FPA->FPA_SEQGRU,;
                            FPA->FPA_PRODUT,;
                            SB1->B1_DESC,;
                            FPA->FPA_GRUA,;
                            iif(ST9->(Eof()),"",ST9->T9_NOME),;
                            FPA->FPA_AS,;
                            transform(FPA->FPA_PRCUNI,"99999999.99"),;
                            transform(FPA->FPA_PRCUNI,"99999999.99"),;
                            Transform(nIndice ,"999999.99999"),;
                            FPA->FPA_AJUSTE,;
                            "Atualização",;
                            FPA->FPA_NIVER,;
                            IIF(MVPAR19 == 1, YearSum(FPA->FPA_NIVER, 1), FPA->FPA_NIVER),;
                            FPA->FPA_DTENRE,;
                            FPA->FPA_DTENRE,;
                            FPA->FPA_DTFIM,;
                            FPA->FPA_DTFIM,;
                            space(100)})
            
            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
                AADD(aResult[len(aResult)],&("FPA->FPA_VLHREX")) // anterior
                AADD(aResult[len(aResult)],&("FPA->FPA_VLHREX")) // corrigido
            EndIF

            AADD(aResult[len(aResult)],&("FPA->FPA_QUANT"))
            nPQtd := len(aResult[len(aResult)])
            AADD(aResult[len(aResult)],&("FPA->FPA_VRHOR")) 
            nPVlro := len(aResult[len(aResult)])
            AADD(aResult[len(aResult)],&("FPA->FPA_VRHOR")) 
            nPVlrn := len(aResult[len(aResult)])
            AADD(aResult[len(aResult)],&("FPA->FPA_ACRESC")) 
            nPAcre := len(aResult[len(aResult)])
            AADD(aResult[len(aResult)],&("FPA->FPA_VLBRUT*FPA->FPA_PDESC/100")) 
            nPDes := len(aResult[len(aResult)])

            For nZ := 1 to len(aEsp)
                AADD(aResult[len(aResult)],&("FPA->"+aEsp[nZ][01]))
            Next
            AADD(aResult[len(aResult)],FPA->(Recno()))
            nPRecno := len(aResult[len(aResult)])

        EndIf

        TFPA->(dbSkip())
    EndDo

    If lContinua
        If !lAuto
            IncProc(STR0017) //"Montagem do ambiente de seleção."
        EndIf

        If len(aResult) == 0
            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
                aadd(aResult,{.F.,"","","","","","","","","","","",0,"0","0","",ctod(""),ctod(""),"",ctod(""),ctod(""),ctod(""),ctod(""),space(100),0,0,0,0,0,0,0})
            Else
                aadd(aResult,{.F.,"","","","","","","","","","","",0,"0","0","",ctod(""),ctod(""),"",ctod(""),ctod(""),ctod(""),ctod(""),space(100),0,0,0,0,0})
            EndIF

            For nZ := 1 to len(aEsp)
                AADD(aResult[len(aResult)],Criavar("FPA->"+aEsp[nZ][01]))
            Next

            AADD(aResult[len(aResult)],0) // recno

        EndIf

        If !lAuto
            IncProc(STR0016) //"Aplicação do reajuste."
        EndIf

        If empty(aResult[1][2])
            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
            Nil,STR0002+STR0015,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados. "+"Itens sem Aniversário"
            {""}) 
            LMSERROAUTO := .T.
            Return .F.
        EndIF

        For nX := 1 to len(aResult)
            // Valor total
            nTemp := aResult[nX][nPVlro]
            // tirar o acrescimo e somar os descontos
            nTemp := nTemp - aResult[nX][nPAcre] + aResult[nX][nPDes]
            nTemp += (nTemp * val(aResult[nX][15]))/100
            // reajustar acrescimo
            nTempAcr := aResult[nX][nPAcre]
            nTempAcr += (nTempAcr * val(aResult[nX][15]))/100
            // Encontrar o valor unitario reajustado
            aResult[nX][nPAcre] := nTempAcr
            aResult[nX][14] := nTemp / aResult[nX][nPQtd]
            nTemp += aResult[nX][nPAcre]
            nTemp -= aResult[nX][nPDes]
            aResult[nX][nPVlrn] := nTemp

            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
                nTemp := ( aResult[nX][25] * val(aResult[nX][15])) / 100
                nTemp := aResult[nX][25] + nTemp
                aResult[nX][26] := nTemp
            EndIF

        next

        aItens := aResult 
    Else
        
        If !lAuto
            aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
            FormBatch(STR0015 , aSays , aButtons )  //"Itens sem Aniversário"
        Else
            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
            Nil,STR0002+STR0015,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados. "+"Itens sem Aniversário"
            {""}) 
            LMSERROAUTO := .T.
        EndIF

    EndIf

    RestArea(aArea)

    lRet := lContinua

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ValIndice
@description	Retorna valor do indice acumulado
@author			José Eulálio
@since     		04/05/2023
/*/
//-------------------------------------------------------------------
Static Function ValIndice(cIndReaj,dDtNiver)
Local cChave    := ""
Local nRet      := 0
Local nDivMedia:= 0
Local nIndCN7   := 0
Local aAreaCN6  := CN6->(GetArea())
Local aAreaCN7  := CN7->(GetArea())

Default cIndReaj := ""
Default dDtNiver := StoD("")

    CN6->(DbSetOrder(1)) //CN6_FILIAL+CN6_CODIGO

    //posiciona no índice
    If CN6->(DbSeek(xFilial("CN6") + cIndReaj))

        //guarda chave para localizar histórico
        cChave := CN6->CN6_FILIAL + CN6->CN6_CODIGO
        //retorna um ano a partir da data de aniversário
        dDataAux    := MonthSub(dDtNiver,12) + 1

        //monta chave de acordo com o tipo de indice 1=diario , 2=mensal
        If CN6->CN6_TIPO == "1"
            nIndCN7     := 1 //CN7_FILIAL+CN7_CODIGO+DTOS(CN7_DATA)
            cChavCN7    := DtoS(dDataAux)
        Else
            nIndCN7     := 2 // CN7_FILIAL+CN7_CODIGO+CN7_COMPET
            cChavCN7    := StrZero(Month(dDataAux),2,0) + "/" + cValToChar(Year(dDataAux))
        EndIf

        //roda o historico de indices
        CN7->(DbSetOrder(nIndCN7)) 
        While dDataAux <= dDtNiver
            If CN7->(DbSeek(CN6->CN6_FILIAL + CN6->CN6_CODIGO + cChavCN7))
                //incrementa o divisor
                nDivMedia++
                //soma total para tirar a média, posteriormente
                nRet += CN7->CN7_VLREAL
            EndIf
            //incrementa data
            If CN6->CN6_TIPO == "1"
                dDataAux    := dDataAux + 1
                cChavCN7    := DtoS(dDataAux)
            Else
                dDataAux    := MonthSum(dDataAux,1)
                cChavCN7    := StrZero(Month(dDataAux),2,0) + "/" + cValToChar(Year(dDataAux))
            EndIf
        EndDo

        //pega media dos indices acumulados
        nRet := nRet / nDivMedia

    EndIf

    RestArea(aAreaCN6)
    RestArea(aAreaCN7)

Return nRet


/*/{PROTHEUS.DOC} LOCA086D
ITUP BUSINESS - TOTVS RENTAL
PROJETOS - REAJUSTE DE VALORES - ATUALIZACAO DA TELA DE REAJUSTE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 19/04/2024
@HISTORY 19/04/2024, FRANK ZWARG FUGA, CRIACAO DO FONTE
/*/

Function LOCA086D
    // Valor original
    oVlr2:cText := aItens[oListP5:nAt][13]     // valor original
    ofim2:cText := aItens[oListP5:nAt][20]     // data final original
    oprox2:cText := aItens[oListP5:nAt][22]    // proximo faturamento original
    oani2:cText := aItens[oListP5:nAt][18]     // aniversario original
    If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
        oKmi:cText := aItens[oListP5:nAt][25]  // Vl.Uni.Franq original
    EndIF
    oTotal:cText := aItens[oListP5:nAt][nPVlro]
    oDesc:cText := aItens[oListP5:nAt][nPDes]
    oAcres:cText := aItens[oListP5:nAt][nPAcre]

    // Valor a ser aplicado
    oVlr:cText := aItens[oListP5:nAt][14]      // valor reajustado
    ofim:cText := aItens[oListP5:nAt][21]      // data final reajustado
    oprox:cText := aItens[oListP5:nAt][23]     // proximo faturamento reajustado
    oani:cText := aItens[oListP5:nAt][19]      // aniversario reajustado
    oObs:cText := aItens[oListP5:nAt][24]      // observacao
    If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
        oKmf:cText := aItens[oListP5:nAt][26] // Vl.Uni.Franq reajustado
    EndIf
    oTotaln:cText := aItens[oListP5:nAt][nPVlrn]

Return .T.

/*/{PROTHEUS.DOC} LOCA086E
ITUP BUSINESS - TOTVS RENTAL
PROJETOS - REAJUSTE DE VALORES - MARCAR TODAS AS LINHAS DA LISTBOX
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 19/04/2024
@HISTORY 19/04/2024, FRANK ZWARG FUGA, CRIACAO DO FONTE
/*/

Static Function LOCA086E
Local nX
    If lInverte
        lInverte := .F.
        If MsgYesNo(STR0065,STR0008) //"Deseja selecionar todas as linhas?"###"Atenção!"
            For nX := 1 to len(aItens)
                aItens[nX,1] := .T.
            Next
            oListP5:REFRESH()
        EndIF
    Else
        lInverte := .T.
        If MsgYesNo(STR0066,STR0008) //"Deseja desmarcar todas as linhas?"###"Atenção!"
            For nX := 1 to len(aItens)
                aItens[nX,1] := .F.
            Next
            oListP5:REFRESH()
        EndIF
    EndIF
Return .t.

/*/{PROTHEUS.DOC} PROCREAJ
ITUP BUSINESS - TOTVS RENTAL
PROJETOS - REAJUSTE DE VALORES - GRAVACAO DO REAJUSTE DE CONTRATOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 19/04/2024
@HISTORY 19/04/2024, FRANK ZWARG FUGA, CRIACAO DO FONTE
/*/
Static Function ProcReaj
Local nZ
Local nX
Local nIndice := 0
Local MV_LOC278 := getmv("MV_LOCX278",,.F.)
Local LOCXIT02 := EXISTBLOCK("LOCXIT02") 
Local LOCXIT01 := EXISTBLOCK("LOCXIT01") 
Local lAltera := .F.
Local lProv
Local cCod
Local nRegX
Local a1Struct := FWSX3Util():GetListFieldsStruct( "FQ9", .F.)
Local nP
Local lAchou

    // DSERLOCA-6564 - Frank em 04/07/2025
    // Tratamento da geração do título provisório pelo campo FP0_PROV
    If FP0->(FieldPos("FP0_PROV")) > 0
        If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
            MV_LOC278 := .T.
        Else
            MV_LOC278 := .F.
        EndIf
    EndIf
    
    if !lAuto
        ProcRegua(len(aItens))
        If MV_LOC278
            If MsgYesNo(STR0091,STR0008) //"Deseja atualizar os títulos provisórios?"###"Atenção!"
                lProv := .T.
            Else
                lProv := .F.
            EndIf
        EndIF
    Else
        If MV_LOC278
            lProv := lProvis
        EndIf
    EndIf

    FPA->(dbSetOrder(1))
    For nX := 1 to len(aItens)
        lAltera := .F.
        if !lAuto
            IncProc()
        EndIF
        If aItens[nX,1]
            FPA->(dbSeek(xFilial("FPA")+aItens[nX,2]+aItens[nX,6]+aItens[nX,7]))
            FPA->(dbGoto(aItens[nX, nPRecno ]))
            FPA->(RecLock("FPA",.F.))
            // Atualizacao do valor unitario
            nVRTOTO := FPA->FPA_PRCUNI
            FPA->FPA_PRCUNI := aItens[nX,14] // Valor unitario
            FPA->FPA_VLBRUT := FPA->FPA_QUANT*FPA->FPA_PRCUNI // Valor bruto    
            If FPA->(FieldPos("FPA_PACRES")) > 0                                                                                                                                              
               FPA->FPA_ACRESC := (FPA->FPA_QUANT*FPA->FPA_PRCUNI) * FPA->FPA_PACRES  
            EndIf 
            FPA->FPA_VRHOR  := (((FPA->FPA_PRCUNI * FPA->FPA_QUANT - (FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC))) // Valor base           
            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
                FPA->FPA_VLHREX := aItens[nX,26]
            EndIF
            
            // Data final
            dDTFIMO := FPA->FPA_DTENRE
            If !lAuto
                FPA->FPA_DTENRE := aItens[nX,21] // data final
            Else
                FPA->FPA_DTENRE := dDtAute
            EndIf
            
            // Proximo faturamento
            dULTFAO := FPA->FPA_DTFIM
            If FPA->FPA_DTFIM <> aItens[nX,23]
                lAltera := .T.
            EndIF
            FPA->FPA_DTFIM  := aItens[nX,23] // proximo faturamento
            If !empty(FPA->FPA_DTINI) .and. !empty(FPA->FPA_DTFIM) .and. lAltera
                IF empty(FPA->FPA_ULTFAT)
                    FPA->FPA_LOCDIA := FPA->FPA_DTFIM - FPA->FPA_DTINI + 1
                Else
                    FPA->FPA_LOCDIA := FPA->FPA_DTFIM - FPA->FPA_ULTFAT + 1
                EndIF
            EndIf

            // Data do aniversario
            dANIVE2 := FPA->FPA_NIVER
            If MVPAR19 == 1
                //If !lAuto
                //    FPA->FPA_NIVER := aItens[_nX,19] // data do aniversario
                //Else
                    FPA->FPA_NIVER := YearSum(FPA->FPA_NIVER, 1) // data do aniversario 
                //EndIF
            EndIf
            FPA->(MsUnlock())

            // Atualização do título provisório
            // Frank em 26/20/2021
            If MV_LOC278 .and. lProv
                LOCA013DEL(2, FPA->FPA_PROJET, FPA->FPA_AS)
                /*FQB->(dbSetOrder(1))
                FQB->(dbSeek(xFilial("FQB")+FPA->FPA_PROJET+FPA->FPA_AS))
                If !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
                    SE1->(dbSetOrder(1))
                    SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR)) 
                    While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR
                        SE1->(RecLock("SE1",.F.))
                        SE1->(dbDelete())
                        SE1->(MsUnlock())
                        SE1->(dbSkip())
                    EndDo
                    While !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
                        FQB->(RecLock("FQB",.F.))
                        FQB->(dbDelete())
                        FQB->(MsUnlock())
                        FQB->(dbSkip())
                    EndDo
                EndIf*/
                FP0->(dbSetOrder(1))
                FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))
                nRegX := FPA->(Recno())
                loca01318() // criacao do titulo provisorio 
                FPA->(dbGoto(nRegX))
            EndIF

            cCod := GETSX8NUM("FQ9","FQ9_COD")
            ConfirmSx8()

            If MVPAR21 == "1"
                IncProc(STR0038) //"Calculando o Indice acumulado."
                nIndice := ValIndice(FPA->FPA_AJUSTE,FPA->FPA_NIVER)
            Else
                nIndice := MVPAR20
            EndIf

            FQ9->(RecLock("FQ9",.T.))
            FQ9->FQ9_FILIAL := xFilial("FQ9")
            FQ9->FQ9_PROJET := FPA->FPA_PROJET
            FQ9->FQ9_OBRA   := FPA->FPA_OBRA
            FQ9->FQ9_SEQGRU := FPA->FPA_SEQGRU
            FQ9->FQ9_PRODUT := FPA->FPA_PRODUT
            FQ9->FQ9_GRUA   := FPA->FPA_GRUA
            FQ9->FQ9_AS     := FPA->FPA_AS
            FQ9->FQ9_VRTOTO := nVRTOTO
            FQ9->FQ9_VRTOTN := FPA->FPA_PRCUNI
            FQ9->FQ9_INDICE := MVPAR08
            FQ9->FQ9_TPCALC := "A"
            FQ9->FQ9_DATA   := dDataBase
            FQ9->FQ9_HORA   := time()
            FQ9->FQ9_ANIVER := dANIVE2 
            FQ9->FQ9_ANIVE2 := FPA->FPA_NIVER
            if !lAuto
                FQ9->FQ9_OBS := aItens[nX,24]
            Else
                FQ9->FQ9_OBS := cObsAut
            Endif
            FQ9->FQ9_DTFIMO := dDTFIMO
            FQ9->FQ9_DTFIMN := FPA->FPA_DTENRE
            FQ9->FQ9_ULTFAO := dULTFAO
            FQ9->FQ9_ULTFAN := FPA->FPA_DTFIM
            FQ9->FQ9_COD    := cCod
            FQ9->FQ9_XATUIN := nIndice
            
            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
                FQ9->FQ9_VLHREX := FPA->FPA_VLHREX
                FQ9->FQ9_VLHREO := aItens[nX,25]
            EndIF

            For nZ := 1 to len(aEsp)
                cCampo1 := aEsp[nZ][01]
                cCampo1 := "FQ9_"+substr(aEsp[nZ][01],5,10)
                cCampo2 := aEsp[nZ][01]

                lachou := .F.
                For nP := 1 to len(a1Struct)
                    If a1Struct[nP][01] == cCampo1
                        lAchou := .T.
                        Exit
                    EndIF
                Next

                If lAchou
                    &("FQ9->"+cCampo1) := &("FPA->"+cCampo2)
                EndIF
            Next

            FQ9->(MsUnlock())

            IF LOCXIT02 
                EXECBLOCK("LOCXIT02" , .T. , .T. , {1,lAuto})  // 1 = Inclusao, 2 = Exclusao
            ENDIF

            IF LOCXIT01 
                EXECBLOCK("LOCXIT01" , .T. , .T. , {1,aItens[nX,15],lAuto})  // 1 = Inclusao, 2 = Exclusao
            ENDIF

            nTot ++
        EndIF
    Next

    If lAuto
        LMSERROAUTO := .F.
    EndIf

Return .T.

/*/{PROTHEUS.DOC} PROCREAJ
ITUP BUSINESS - TOTVS RENTAL
PROJETOS - REAJUSTE DE VALORES - ATUALIZACAO DA LISTBOX COM OS NOVOS VALORES
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 19/04/2024
@HISTORY 19/04/2024, FRANK ZWARG FUGA, CRIACAO DO FONTE
/*/

Function LOCA086F(cGet)
Local nTemp

    If cGet == "VALOR"
        aItens[oListP5:nAt][14] := transform(oVlr:cText,"99999999.99")
    ElseIf cGet == "FIM"
        aItens[oListP5:nAt][21] := ofim:cText
    ElseIf cGet == "PROX"
        aItens[oListP5:nAt][23] := oprox:cText
    ElseIf cGet == "NIVER"
        aItens[oListP5:nAt][19] := oani:cText
    ElseIf cGet == "OBS"
        aItens[oListP5:nAt][24] := oObs:cText
    ElseIf cGet == "KM"
        aItens[oListP5:nAt][25] := oKmi:cText
        aItens[oListP5:nAt][26] := oKmf:cText
    ElseIF cGet == "TOTAL"
        nTemp := oTotaln:cText
        // tirar o acrescimo e somar os descontos
        nTemp := nTemp - aItens[oListP5:nAt][nPAcre] + aItens[oListP5:nAt][nPDes]
        // Encontrar o valor unitario reajustado
        aItens[oListP5:nAt][14] := nTemp / aItens[oListP5:nAt][nPQtd]
        oVlr:cText := aItens[oListP5:nAt][14]
    EndIf
    oListP5:refresh()
Return .T.



/*/{PROTHEUS.DOC} PROCREAJ
ITUP BUSINESS - TOTVS RENTAL
PROJETOS - REAJUSTE DE VALORES - ESTORNO DOS MOVIMENTOS DE REAJUSTE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 19/04/2024
@HISTORY 19/04/2024, FRANK ZWARG FUGA, CRIACAO DO FONTE
/*/

Function LOCA08G(cSeqx) 
Local nReg
Local cProj := FQ9->FQ9_PROJET
Local cObra := FQ9->FQ9_OBRA
Local cSeqG := FQ9->FQ9_SEQGRU
Local dData := FQ9->FQ9_DATA
Local cHora := FQ9->FQ9_HORA
Local lMVLOC278 := getmv("MV_LOCX278",,.F.)
Local lLOCXIT01 := EXISTBLOCK("LOCXIT01") 
Local cQuery
Local aBindParam := {}
Local lProc
Local lRet := .T.

Default cSeqx := ""

    // DSERLOCA-6564 - Frank em 04/07/2025
    // Tratamento da geração do título provisório pelo campo FP0_PROV
    If FP0->(FieldPos("FP0_PROV")) > 0
        If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
            lMVLOC278 := .T.
        Else
            lMVLOC278 := .F.
        EndIf
    EndIf

    If lAuto
        cQuery := "SELECT FQ9.R_E_C_N_O_ AS REG "
        cQuery += "FROM "+RetSqlName("FQ9")+" FQ9 "
        cQuery += "WHERE FQ9.D_E_L_E_T_ = '' AND " 
        cQuery += "FQ9.FQ9_COD = ? "
        aadd(aBindParam,cSeqx)
        If Select("TFQ9") > 0 
            TFQ9->(dbCloseArea()) 
        EndIf 
        cQuery := CHANGEQUERY(cQuery) 
        MPSysOpenQuery(cQuery,"TFQ9",,,aBindParam)
        If TFQ9->(Eof())
            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
            Nil,STR0002+STR0087,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."###"O registro do reajuste não foi localizado."
            {""}) 
            LMSERROAUTO := .T.
            TFQ9->(dbCloseArea()) 
            Return .F.
        Else
            FQ9->(dbGoto(TFQ9->REG))
            TFQ9->(dbCloseArea()) 
            cProj := FQ9->FQ9_PROJET
            dData := FQ9->FQ9_DATA
            cHora := FQ9->FQ9_HORA
            cObra := FQ9->FQ9_OBRA
            cSeqG := FQ9->FQ9_SEQGRU
        EndIf
    EndIf


    If FQ9->FQ9_MSBLQL == "1"
        If !lAuto
            MsgAlert(STR0077,STR0076) // "Reajuste já restaurado."###"Processo bloqueado."
            Return
        Else
            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
            Nil,STR0002+STR0088,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."###"Reajuste já restaurado."
            {""}) 
            Return .F.
        EndIF
    EndIf

    // Não permitir um estorno de um registro menor
    nReg := FQ9->(Recno())
    FQ9->(dbSetOrder(1))
    FQ9->(dbSeek(xFilial("FQ9")+cProj))
    While !FQ9->(Eof()) .and. FQ9->FQ9_FILIAL == xFilial("FQ9") .and. FQ9->FQ9_PROJET == cProj
        If FQ9->FQ9_MSBLQL <> "1"
            If FQ9->FQ9_OBRA == cObra .and. FQ9->FQ9_SEQGRU == cSeqG
                If FQ9->FQ9_DATA > dData
                    If !lAuto
                        MsgAlert(STR0078,STR0076) // "Existe um reajuste mais atual do que o posicionado."###"Processo bloqueado!"
                        FQ9->(dbGoto(nReg))
                        Return .F.
                    Else
                        Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
                        Nil,STR0002+STR0089,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."###"Existe um reajuste mais atual do que o posicionado."
                        {""}) 
                        Return .F.
                   EndIF
                EndIF            
                IF FQ9->FQ9_DATA == dData .and. FQ9->(Recno()) <> nReg
                    IF FQ9->FQ9_HORA > cHora
                        If !lAuto
                            MsgAlert(STR0078,STR0076) // "Existe um reajuste mais atual do que o posicionado."###"Processo bloqueado!"
                            FQ9->(dbGoto(nReg))
                            Return .F.
                        Else
                            Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
                            Nil,STR0002+STR0089,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."###"Existe um reajuste mais atual do que o posicionado."
                            {""}) 
                           Return .F.
                        EndIF
                    EndIF
                EndIF
            EndIf
        EndIF
        FQ9->(dbSkip())
    EndDo
    FQ9->(dbGoto(nReg))

    If !lAuto
        lProc := MsgYesNo(STR0079,STR0008) //"Confirma a restauração dos valores?"###"Atenção!"
        If !lProc
            lRet := .F.
        EndIf
    Else
        lProc := .T.
        lRet := .T.
    EndIF

    If lProc
        FPA->(dbSetOrder(1))
        If FPA->(dbSeek(xFilial("FPA")+FQ9->(FQ9_PROJET+FQ9_OBRA+FQ9_SEQGRU)))
            If FPA->(RecLock("FPA",.F.))
                // Atualizacao do valor unitario
                FPA->FPA_PRCUNI := FQ9->FQ9_VRTOTO // Valor unitario
                FPA->FPA_VLBRUT := FPA->FPA_QUANT*FPA->FPA_PRCUNI // Valor bruto  
                If FPA->(FieldPos("FPA_PACRES")) > 0                                                                        
                     FPA->FPA_ACRESC := (FPA->FPA_QUANT*FPA->FPA_PRCUNI) * FPA->FPA_PACRES
                EndIf

                FPA->FPA_VRHOR  := (((FPA->FPA_PRCUNI * FPA->FPA_QUANT - (FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC))) // Valor base           
                If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0 
                    FPA->FPA_VLHREX := FQ9->FQ9_VLHREO // R$ Hrs Extra                                                            
                EndIF
                
                // Data final
                FPA->FPA_DTENRE := FQ9->FQ9_DTFIMO // data final
                // Proximo faturamento
                FPA->FPA_DTFIM  := FQ9->FQ9_ULTFAO // proximo faturamento
                If !empty(FPA->FPA_DTINI) .and. !empty(FPA->FPA_DTFIM)
                    IF empty(FPA->FPA_ULTFAT)                               // Rossana - DSERLOCA 3658 - 25/07/2024
                      FPA->FPA_LOCDIA := FPA->FPA_DTFIM - FPA->FPA_DTINI + 1
                    Else
                      FPA->FPA_LOCDIA := FPA->FPA_DTFIM - FPA->FPA_ULTFAT  // não soma 1 pq a data está no periodo anterior
                    EndIf
                EndIF

                // Data do aniversario
                If MVPAR19 == 1
                    FPA->FPA_NIVER := FQ9->FQ9_ANIVER // data do aniversario
                EndIf
                FPA->(MsUnlock())      

                // Atualização do título provisório
                // Frank em 26/20/2021
                If lMVLOC278
                    // Deleta os títulos provisórios
			        LOCA013DEL(2, FPA->FPA_PROJET, FPA->FPA_AS)

                    /*FQB->(dbSetOrder(1))
                    FQB->(dbSeek(xFilial("FQB")+FPA->FPA_PROJET+FPA->FPA_AS))
                    If !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
                        SE1->(dbSetOrder(1))
                        SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR)) 
                        While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR
                            SE1->(RecLock("SE1",.F.))
                            SE1->(dbDelete())
                            SE1->(MsUnlock())
                            SE1->(dbSkip())
                        EndDo
                        While !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
                            FQB->(RecLock("FQB",.F.))
                            FQB->(dbDelete())
                            FQB->(MsUnlock())
                            FQB->(dbSkip())
                        EndDo
                    EndIf*/
                    FP0->(dbSetOrder(1))
                    FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))
                    nRegX := FPA->(Recno())
                    loca01318() // criacao do titulo provisorio 
                    FPA->(dbGoto(nRegX))
                EndIF

                IF lLOCXIT01
                    EXECBLOCK("LOCXIT01" , .T. , .T. , {2, FQ9->FQ9_XATUIN, lAuto}) // 1 = Inclusao, 2 = Exclusao
                ENDIF

                FQ9->(RecLock("FQ9"),.F.)
                FQ9->FQ9_MSBLQL := "1"
                FQ9->(MsUnlock())

                If !lAuto
                    MsgAlert(STR0081,STR0080) //"Processo realizado com sucesso."###"Reajuste estornado."
                EndIf

            EndIF
        EndIf
    EndIF
Return lRet
