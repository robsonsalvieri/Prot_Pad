#include "protheus.ch"

/*
  Esta funcao foi criada para que seja possivel visualizar a data deste
  fonte no inspetor de objetos, pois nao eh possivel fazer isso se nao
  houver nenhuma FUNCTION no fonte.
*/
function FISA305A();Return

/*/{Protheus.doc} SJCGEN
    (Classe para criar o objeto que receberá o Pergunte da rotina para geração do arquivo)
    @type  Class
    @author pereira.weslley
    @since 03/12/2020
    @version 1.0
    @param Nil
    @return Nil
    @example
    (Classe para criar o objeto que receberá o Pergunte da rotina para geração do arquivo)
    @see (links_or_references)
    /*/
CLASS SJCGEN
    Data dDataIni   As Date    HIDDEN
    Data dDataFim   As Date    HIDDEN
    Data cArcName   As String  HIDDEN
    Data cPath      As String  HIDDEN

    Method New(Value1, Value2, Value3, Value4)
    Method SetFilial(Value)
    Method SetDtIni(Value)
    Method SetDtFim(Value)
    Method SetArcName(Value)
    Method SetPath(Value)

    Method GetFilial()
    Method GetDtIni()
    Method GetDtFim()
    Method GetArcName()
    Method GetPath()

ENDCLASS

Method New(Value1, Value2, Value3, Value4) Class SJCGEN
    Self:dDataIni  := Value1
    Self:dDataFim  := Value2
    Self:cPath     := Value3
    Self:cArcName  := Value4
Return Self

Method SetDtIni(Value) Class SJCGEN
    Self:dDataIni := Value
Return

Method SetDtFim(Value) Class SJCGEN
    Self:dDataFim := Value
Return

Method SetArcName(Value) Class SJCGEN
    Self:cArcName := Value
Return

Method SetPath(Value) Class SJCGEN
    Self:cPath := Value
Return

Method GetDtIni() Class SJCGEN
Return Self:dDataIni

Method GetDtFim() Class SJCGEN
Return Self:dDataFim

Method GetArcName() Class SJCGEN
Return Self:cArcName

Method GetPath() Class SJCGEN
Return Self:cPath

/*/{Protheus.doc} REGH
    (Classe para criar o objeto que receberá os atributos para geração do Registro H)
    @type  Class
    @author pereira.weslley
    @since 03/12/2020
    @version 1.0
    @param Nil
    @return Nil
    @example
    (Classe para criar o objeto que receberá os atributos para geração do Registro H)
    @see (links_or_references)
    /*/
CLASS REGH
    Data cIdent     As String  HIDDEN    // Campo - 1
    Data cInscrMun  As String  HIDDEN    // Campo - 2
    
    Method New()
    Method SetCmp2(Value)

    Method GetCmp1()
    Method GetCmp2()

ENDCLASS

Method New() Class REGH
    Self:cIdent := 'H'
    Self:cInscrMun := SM0->M0_INSCM
Return Self

Method SetCmp2(Value) Class REGH
    Self:cInscrMun := Value
Return

Method GetCmp1() Class REGH
Return Self:cIdent

Method GetCmp2() Class REGH
Return Self:cInscrMun

/*/{Protheus.doc} REGT
    (Classe para criar o objeto que receberá os atributos para geração do Registro T)
    @type  Class
    @author pereira.weslley
    @since 03/12/2020
    @version 1.0
    @param Nil
    @return Nil
    @example
    (Classe para criar o objeto que receberá os atributos para geração do Registro T)
    @see (links_or_references)
    /*/
CLASS REGT
    Data cIdent     As String  HIDDEN    // Campo - 1
    Data dEmissao   As Date    HIDDEN    // Campo - 2
    Data cDataComp  As String  HIDDEN    // Campo - 3
    Data nDoc       As Integer HIDDEN    // Campo - 4
    Data cSerie     As String  HIDDEN    // Campo - 5
    Data cModelo    As String  HIDDEN    // Campo - 6
    Data cTpPrestad As String  HIDDEN    // Campo - 7
    Data cCPFPrest  As String  HIDDEN    // Campo - 8
    Data nDocPrest  As Integer HIDDEN    // Campo - 9
    Data cNomePrest As String  HIDDEN    // Campo - 10
    Data cMunPrest  As String  HIDDEN    // Campo - 11
    Data cPrestSimp As String  HIDDEN    // Campo - 12
    Data cPrestMEI  As String  HIDDEN    // Campo - 13
    Data cPMesmoMun As String  HIDDEN    // Campo - 14
    Data nCEPPrest  As Integer HIDDEN    // Campo - 15
    Data cTpLogrado As String  HIDDEN    // Campo - 16
    Data cNomeLogra As String  HIDDEN    // Campo - 17
    Data nNumLograd As Integer HIDDEN    // Campo - 18
    Data cComplPres As String  HIDDEN    // Campo - 19
    Data cBairroPre As String  HIDDEN    // Campo - 20
    Data cUFPrestad As String  HIDDEN    // Campo - 21
    Data cPaísPrest As String  HIDDEN    // Campo - 22
    Data cCidadePre As String  HIDDEN    // Campo - 23
    Data nCodServ   As Integer HIDDEN    // Campo - 24
    Data nCodCNAE   As Integer HIDDEN    // Campo - 25
    Data nCodObra   As Integer HIDDEN    // Campo - 26
    Data cLocalPres As String  HIDDEN    // Campo - 27
    Data cCdMunLoc  As String  HIDDEN    // Campo - 28
    Data cUFPreServ As String  HIDDEN    // Campo - 29
    Data cMunExPres As String  HIDDEN    // Campo - 30
    Data cUFExPres  As String  HIDDEN    // Campo - 31
    Data nPaísExPre As Integer HIDDEN    // Campo - 32
    Data cResulPres As String  HIDDEN    // Campo - 33
    Data cResuCdMun As String  HIDDEN    // Campo - 34
    Data cResulUF   As String  HIDDEN    // Campo - 35
    Data cResuMunEx As String  HIDDEN    // Campo - 36
    Data cResuEstEx As String  HIDDEN    // Campo - 37
    Data nResuPaís  As Integer HIDDEN    // Campo - 38
    Data cMotNaoRet As String  HIDDEN    // Campo - 39
    Data nExigiISS  As Integer HIDDEN    // Campo - 40
    Data nTpRecImp  As String  HIDDEN    // Campo - 41
    Data cAliqISS   As String  HIDDEN    // Campo - 42
    Data cValServNF As String  HIDDEN    // Campo - 43
    Data cValDed    As String  HIDDEN    // Campo - 44
    Data cDescIncon As String  HIDDEN    // Campo - 45
    Data cDescCond  As String  HIDDEN    // Campo - 46
    Data cBaseCalc  As String  HIDDEN    // Campo - 47
    Data cValorPIS  As String  HIDDEN    // Campo - 48
    Data cValorCOF  As String  HIDDEN    // Campo - 49 
    Data cValorINSS As String  HIDDEN    // Campo - 50
    Data cValorIR   As String  HIDDEN    // Campo - 51
    Data cValorCSLL As String  HIDDEN    // Campo - 52
    Data cOutrasRet As String  HIDDEN    // Campo - 53
    Data cValorISS  As String  HIDDEN    // Campo - 54
    Data cDescServ  As String  HIDDEN    // Campo - 55

    Method New()
    Method LimpaObj()

    Method SetCmp2(Value)
    Method SetCmp3(Value)
    Method SetCmp4(Value)
    Method SetCmp5(Value)
    Method SetCmp6(Value)
    Method SetCmp7(Value)
    Method SetCmp8(Value)
    Method SetCmp9(Value)
    Method SetCmp10(Value)
    Method SetCmp11(Value)
    Method SetCmp12(Value)
    Method SetCmp13(Value)
    Method SetCmp14(Value)
    Method SetCmp15(Value)
    Method SetCmp16(Value)
    Method SetCmp17(Value)
    Method SetCmp18(Value)
    Method SetCmp19(Value)
    Method SetCmp20(Value)
    Method SetCmp21(Value)
    Method SetCmp22(Value)
    Method SetCmp23(Value)
    Method SetCmp24(Value)
    Method SetCmp25(Value)
    Method SetCmp26(Value)
    Method SetCmp27(Value)
    Method SetCmp28(Value)
    Method SetCmp29(Value)
    Method SetCmp30(Value)
    Method SetCmp31(Value)
    Method SetCmp32(Value)
    Method SetCmp33(Value)
    Method SetCmp34(Value)
    Method SetCmp35(Value)
    Method SetCmp36(Value)
    Method SetCmp37(Value)
    Method SetCmp38(Value)
    Method SetCmp39(Value)
    Method SetCmp40(Value)
    Method SetCmp41(Value)
    Method SetCmp42(Value)
    Method SetCmp43(Value)
    Method SetCmp44(Value)
    Method SetCmp45(Value)
    Method SetCmp46(Value)
    Method SetCmp47(Value)
    Method SetCmp48(Value)
    Method SetCmp49(Value)
    Method SetCmp50(Value)
    Method SetCmp51(Value)
    Method SetCmp52(Value)
    Method SetCmp53(Value)
    Method SetCmp54(Value)
    Method SetCmp55(Value)

    Method GetCmp1()
    Method GetCmp2()
    Method GetCmp3()
    Method GetCmp4()
    Method GetCmp5()
    Method GetCmp6()
    Method GetCmp7()
    Method GetCmp8()
    Method GetCmp9()
    Method GetCmp10()
    Method GetCmp11()
    Method GetCmp12()
    Method GetCmp13()
    Method GetCmp14()
    Method GetCmp15()
    Method GetCmp16()
    Method GetCmp17()
    Method GetCmp18()
    Method GetCmp19()
    Method GetCmp20()
    Method GetCmp21()
    Method GetCmp22()
    Method GetCmp23()
    Method GetCmp24()
    Method GetCmp25()
    Method GetCmp26()
    Method GetCmp27()
    Method GetCmp28()
    Method GetCmp29()
    Method GetCmp30()
    Method GetCmp31()
    Method GetCmp32()
    Method GetCmp33()
    Method GetCmp34()
    Method GetCmp35()
    Method GetCmp36()
    Method GetCmp37()
    Method GetCmp38()
    Method GetCmp39()
    Method GetCmp40()
    Method GetCmp41()
    Method GetCmp42()
    Method GetCmp43()
    Method GetCmp44()
    Method GetCmp45()
    Method GetCmp46()
    Method GetCmp47()
    Method GetCmp48()
    Method GetCmp49()
    Method GetCmp50()
    Method GetCmp51()
    Method GetCmp52()
    Method GetCmp53()
    Method GetCmp54()
    Method GetCmp55()

    Method GravaRegT(oRegT, cAlias)

ENDCLASS

Method New() Class REGT
    Self:cIdent := 'T'
Return Self

Method LimpaObj() Class REGT
    Self:dEmissao   := '  /  /    '
    Self:cDataComp  := '  /    '
    Self:nDoc       := 0
    Self:cSerie     := ''
    Self:cModelo    := ''
    Self:cTpPrestad := ''
    Self:cCPFPrest  := ''
    Self:nDocPrest  := 0
    Self:cNomePrest := ''
    Self:cMunPrest  := ''
    Self:cPrestSimp := ''
    Self:cPrestMEI  := ''
    Self:cPMesmoMun := ''
    Self:nCEPPrest  := 0
    Self:cTpLogrado := ''
    Self:cNomeLogra := ''
    Self:nNumLograd := 0
    Self:cComplPres := ''
    Self:cBairroPre := ''
    Self:cUFPrestad := ''
    Self:cPaísPrest := ''
    Self:cCidadePre := ''
    Self:nCodServ   := 0
    Self:nCodCNAE   := 0
    Self:nCodObra   := 0
    Self:cLocalPres := ''
    Self:cCdMunLoc  := ''
    Self:cUFPreServ := ''
    Self:cMunExPres := ''
    Self:cUFExPres  := ''
    Self:nPaísExPre := 0
    Self:cResulPres := ''
    Self:cResuCdMun := ''
    Self:cResulUF   := ''
    Self:cResuMunEx := ''
    Self:cResuEstEx := ''
    Self:nResuPaís  := 0
    Self:cMotNaoRet := ''
    Self:nExigiISS  := 0
    Self:nTpRecImp  := ''
    Self:cAliqISS   := ''
    Self:cValServNF := ''
    Self:cValDed    := ''
    Self:cDescIncon := ''
    Self:cDescCond  := ''
    Self:cBaseCalc  := ''
    Self:cValorPIS  := ''
    Self:cValorCOF  := ''
    Self:cValorINSS := ''
    Self:cValorIR   := ''
    Self:cValorCSLL := ''
    Self:cOutrasRet := ''
    Self:cValorISS  := ''
    Self:cDescServ  := ''
Return

Method SetCmp2(Value) Class REGT
    Self:dEmissao := Value
Return

Method SetCmp3(Value) Class REGT
    Self:cDataComp := Value
Return

Method SetCmp4(Value) Class REGT
    Self:nDoc := Value
Return

Method SetCmp5(Value) Class REGT
    Self:cSerie := Value
Return

Method SetCmp6(Value) Class REGT
    Self:cModelo := Value
Return

Method SetCmp7(Value) Class REGT
    Self:cTpPrestad := Value
Return

Method SetCmp8(Value) Class REGT
    Self:cCPFPrest := Value
Return

Method SetCmp9(Value) Class REGT
    Self:nDocPrest := Value
Return

Method SetCmp10(Value) Class REGT
    Self:cNomePrest := Value
Return

Method SetCmp11(Value) Class REGT
    Self:cMunPrest := Value
Return

Method SetCmp12(Value) Class REGT
    Self:cPrestSimp := Value
Return

Method SetCmp13(Value) Class REGT
    Self:cPrestMEI := Value
Return

Method SetCmp14(Value) Class REGT
    Self:cPMesmoMun := Value
Return

Method SetCmp15(Value) Class REGT
    Self:nCEPPrest := Value
Return

Method SetCmp16(Value) Class REGT
    Self:cTpLogrado := Value
Return

Method SetCmp17(Value) Class REGT
    Self:cNomeLogra := Value
Return

Method SetCmp18(Value) Class REGT
    Self:nNumLograd := Value
Return

Method SetCmp19(Value) Class REGT
    Self:cComplPres := Value
Return

Method SetCmp20(Value) Class REGT
    Self:cBairroPre := Value
Return

Method SetCmp21(Value) Class REGT
    Self:cUFPrestad := Value
Return

Method SetCmp22(Value) Class REGT
    Self:cPaísPrest := Value
Return

Method SetCmp23(Value) Class REGT
    Self:cCidadePre := Value
Return

Method SetCmp24(Value) Class REGT
    Self:nCodServ := Value
Return

Method SetCmp25(Value) Class REGT
    Self:nCodCNAE := Value
Return

Method SetCmp26(Value) Class REGT
    Self:nCodObra := Value
Return

Method SetCmp27(Value) Class REGT
    Self:cLocalPres := Value
Return

Method SetCmp28(Value) Class REGT
    Self:cCdMunLoc := Value
Return

Method SetCmp29(Value) Class REGT
    Self:cUFPreServ := Value
Return

Method SetCmp30(Value) Class REGT
    Self:cMunExPres := Value
Return

Method SetCmp31(Value) Class REGT
    Self:cUFExPres := Value
Return

Method SetCmp32(Value) Class REGT
    Self:nPaísExPre := Value
Return

Method SetCmp33(Value) Class REGT
    Self:cResulPres := Value
Return

Method SetCmp34(Value) Class REGT
    Self:cResuCdMun := Value
Return

Method SetCmp35(Value) Class REGT
    Self:cResulUF := Value
Return

Method SetCmp36(Value) Class REGT
    Self:cResuMunEx := Value
Return

Method SetCmp37(Value) Class REGT
    Self:cResuEstEx := Value
Return

Method SetCmp38(Value) Class REGT
    Self:nResuPaís := Value
Return

Method SetCmp39(Value) Class REGT
    Self:cMotNaoRet := Value
Return

Method SetCmp40(Value) Class REGT
    Self:nExigiISS := Value
Return

Method SetCmp41(Value) Class REGT
    Self:nTpRecImp := Value
Return

Method SetCmp42(Value) Class REGT
    Self:cAliqISS := Value
Return

Method SetCmp43(Value) Class REGT
    Self:cValServNF := Value
Return

Method SetCmp44(Value) Class REGT
    Self:cValDed := Value
Return

Method SetCmp45(Value) Class REGT
    Self:cDescIncon := Value
Return

Method SetCmp46(Value) Class REGT
    Self:cDescCond := Value
Return

Method SetCmp47(Value) Class REGT
    Self:cBaseCalc := Value
Return

Method SetCmp48(Value) Class REGT
    Self:cValorPIS := Value
Return

Method SetCmp49(Value) Class REGT
    Self:cValorCOF := Value
Return

Method SetCmp50(Value) Class REGT
    Self:cValorINSS := Value
Return

Method SetCmp51(Value) Class REGT
    Self:cValorIR := Value
Return

Method SetCmp52(Value) Class REGT
    Self:cValorCSLL := Value
Return

Method SetCmp53(Value) Class REGT
    Self:cOutrasRet := Value
Return

Method SetCmp54(Value) Class REGT
    Self:cValorISS := Value
Return

Method SetCmp55(Value) Class REGT
    Self:cDescServ := Value
Return

Method GetCmp1() Class REGT
Return Self:cIdent

Method GetCmp2() Class REGT
Return Self:dEmissao

Method GetCmp3() Class REGT
Return Self:cDataComp

Method GetCmp4() Class REGT
Return Self:nDoc

Method GetCmp5() Class REGT
Return Self:cSerie

Method GetCmp6() Class REGT
Return Self:cModelo

Method GetCmp7() Class REGT
Return Self:cTpPrestad

Method GetCmp8() Class REGT
Return Self:cCPFPrest

Method GetCmp9() Class REGT
Return Self:nDocPrest

Method GetCmp10() Class REGT
Return Self:cNomePrest

Method GetCmp11() Class REGT
Return Self:cMunPrest

Method GetCmp12() Class REGT
Return Self:cPrestSimp

Method GetCmp13() Class REGT
Return Self:cPrestMEI

Method GetCmp14() Class REGT
Return Self:cPMesmoMun

Method GetCmp15() Class REGT
Return Self:nCEPPrest

Method GetCmp16() Class REGT
Return Self:cTpLogrado

Method GetCmp17() Class REGT
Return Self:cNomeLogra

Method GetCmp18() Class REGT
Return Self:nNumLograd

Method GetCmp19() Class REGT
Return Self:cComplPres

Method GetCmp20() Class REGT
Return Self:cBairroPre

Method GetCmp21() Class REGT
Return Self:cUFPrestad

Method GetCmp22() Class REGT
Return Self:cPaísPrest 

Method GetCmp23() Class REGT
Return Self:cCidadePre

Method GetCmp24() Class REGT
Return Self:nCodServ

Method GetCmp25() Class REGT
Return Self:nCodCNAE

Method GetCmp26() Class REGT
Return Self:nCodObra

Method GetCmp27() Class REGT
Return Self:cLocalPres

Method GetCmp28() Class REGT
Return Self:cCdMunLoc

Method GetCmp29() Class REGT
Return Self:cUFPreServ

Method GetCmp30() Class REGT
Return Self:cMunExPres

Method GetCmp31() Class REGT
Return Self:cUFExPres

Method GetCmp32() Class REGT
Return Self:nPaísExPre

Method GetCmp33() Class REGT
Return Self:cResulPres

Method GetCmp34() Class REGT
Return Self:cResuCdMun

Method GetCmp35() Class REGT
Return Self:cResulUF

Method GetCmp36() Class REGT
Return Self:cResuMunEx

Method GetCmp37() Class REGT
Return Self:cResuEstEx

Method GetCmp38() Class REGT
Return Self:nResuPaís

Method GetCmp39() Class REGT
Return Self:cMotNaoRet

Method GetCmp40() Class REGT
Return Self:nExigiISS

Method GetCmp41() Class REGT
Return Self:nTpRecImp

Method GetCmp42() Class REGT
Return Self:cAliqISS

Method GetCmp43() Class REGT
Return Self:cValServNF

Method GetCmp44() Class REGT
Return Self:cValDed

Method GetCmp45() Class REGT
Return Self:cDescIncon

Method GetCmp46() Class REGT
Return Self:cDescCond

Method GetCmp47() Class REGT
Return Self:cBaseCalc

Method GetCmp48() Class REGT
Return Self:cValorPIS

Method GetCmp49() Class REGT
Return Self:cValorCOF

Method GetCmp50() Class REGT
Return Self:cValorINSS

Method GetCmp51() Class REGT
Return Self:cValorIR

Method GetCmp52() Class REGT
Return Self:cValorCSLL

Method GetCmp53() Class REGT
Return Self:cOutrasRet

Method GetCmp54() Class REGT
Return Self:cValorISS

Method GetCmp55() Class REGT
Return Self:cDescServ 

Method GravaRegT(oRegT, cAlias) Class REGT
    Local cExiGiISS  := NFePstServ((cAlias)->MUNICIPIO,(cAlias)->ESTADO,"SAO JOSE DOS CAMPOS/SÃO JOSÉ DOS CAMPOS","SP",(cAlias)->F3_DTCANC,(cAlias)->F4_ISSST,(cAlias)->F3_ISENICM + (cAlias)->F3_OUTRICM)
    Local lExterior  := AllTrim((cAlias)->PAIS) != '105'
    Local lLocPrest  := Iif(cExiGiISS $ '1|3', .T., .F.) //Se a exigibilidade do ISS for 1 ou 3 o local de prestação é tirado da SM0
    Local cSM0CdMun  := Iif(Len(Alltrim(SM0->M0_CODMUN))<=5,UfCodIBGE(SM0->M0_ESTENT)+SM0->M0_CODMUN,PadR(SM0->M0_CODMUN,7," "))
    Local cTipoLocP  := Iif(lLocPrest, 'LOC', Iif(lExterior, 'EXT', 'LOC'))
    Local cSA2RecIss := (cAlias)->A2_RECISS
    Local cModeloNot := CrtMod(Alltrim((cAlias)->F3_ESPECIE))
    Local dDtCompe   := IIf(Empty((cAlias)->DTCOMPE),(cAlias)->F3_EMISSAO,(cAlias)->DTCOMPE)

    oRegT:SetCmp2((cAlias)->F3_EMISSAO)
    oRegT:SetCmp3( Iif(Empty(dDtCompe), "00/0000", Padl(cValToChar(Month(dDtCompe)),2,"0") + "/" + cValToChar(Year(dDtCompe))))    
    oRegT:SetCmp4(PadR(Alltrim((cAlias)->F3_NFISCAL), 15, " "))
    oRegT:SetCmp5(PadR(Alltrim((cAlias)->F3_SERIE), 5, " "))
    oRegT:SetCmp6(PadR(cModeloNot, 2, " "))
    oRegT:SetCmp7(Iif(lExterior, '2', '1'))
    oRegT:SetCmp8(PadR(Iif(lExterior, '', (cAlias)->CGC), 14, '0'))
    oRegT:SetCmp9(PadR(Iif(lExterior, (cAlias)->A2_PFISICA, ''), 20, ' '))
    oRegT:SetCmp10(PadR((cAlias)->NOME, 150, ' '))
    oRegT:SetCmp11(PadR(Iif(lExterior, '', UfCodIBGE((cAlias)->ESTADO)+(cAlias)->CODMUN), 7, '9'))
    oRegT:SetCmp12(Iif((cAlias)->A2_SIMPNAC = '1' .And. (cAlias)->A2_TPJ != '3', 'S', 'N'))
    oRegT:SetCmp13(Iif((cAlias)->A2_TPJ = '3', 'S', 'N'))
    oRegT:SetCmp14(Iif(Alltrim(cSM0CdMun) = Alltrim((cAlias)->CODMUN), 'S', 'N'))
    oRegT:SetCmp15((cAlias)->CEP)
    oRegT:SetCmp16(PadR(fTrtEnd((cAlias)->ENDERECO)[1], 25, " "))
    oRegT:SetCmp17(PadR(fTrtEnd((cAlias)->ENDERECO)[2], 50, " "))
    oRegT:SetCmp18(PadR(fTrtEnd((cAlias)->ENDERECO)[3], 10, " "))
    oRegT:SetCmp19(PadR((cAlias)->COMPLEMENTO, 60, " "))
    oRegT:SetCmp20(PadR((cAlias)->BAIRRO, 60, " "))
    oRegT:SetCmp21(PadR((cAlias)->ESTADO, 2, " "))
    oRegT:SetCmp22(PadR(Iif(lLocPrest, '', Iif(lExterior, Alltrim((cAlias)->A2_CODPAIS), '')), 4, ' '))
    oRegT:SetCmp23(PadR((cAlias)->MUNICIPIO, 50, ' '))
    oRegT:SetCmp24(PadR((cAlias)->F3_CODISS, 5, ' '))
    oRegT:SetCmp25(PadR((cAlias)->F3_CNAE, 9, ' '))
    oRegT:SetCmp26(PadR('', 15, ' '))
    oRegT:SetCmp27(cTipoLocP)
    oRegT:SetCmp28(PadR(Iif(lLocPrest, cSM0CdMun, UfCodIBGE((cAlias)->ESTADO) + (cAlias)->CODMUN), 7, ' '))
    oRegT:SetCmp29(Iif(lLocPrest, SM0->M0_ESTENT, Iif(lExterior, '  ', (cAlias)->ESTADO)))
    oRegT:SetCmp30(Iif(cTipoLocP == 'EXT', (cAlias)->MUNICIPIO, PadR('', 50, ' ')))
    oRegT:SetCmp31(Iif(cTipoLocP == 'EXT', fBuscSX5UF((cAlias)->ESTADO), PadR('', 50, ' ')))
    oRegT:SetCmp32(Iif(cTipoLocP == 'EXT', (cAlias)->A2_CODPAIS, PadR('', 4, ' ')))
    oRegT:SetCmp33(Iif(cTipoLocP $ 'LOC', 'BRA', cTipoLocP))
    oRegT:SetCmp34(Iif(lLocPrest, cSM0CdMun, UfCodIBGE((cAlias)->ESTADO) + (cAlias)->CODMUN))
    oRegT:SetCmp35(Iif(lLocPrest, SM0->M0_ESTENT, Iif(lExterior, '  ', (cAlias)->ESTADO)))
    oRegT:SetCmp36(Iif(cTipoLocP == 'EXT', (cAlias)->MUNICIPIO, PadR('', 50, ' ')))
    oRegT:SetCmp37(Iif(cTipoLocP == 'EXT', fBuscSX5UF((cAlias)->ESTADO), PadR('', 50, ' ')))
    oRegT:SetCmp38(Iif(cTipoLocP == 'EXT', (cAlias)->A2_CODPAIS, PadR('', 4, ' ')))
    oRegT:SetCmp39(Alltrim((cAlias)->F4_MTRTBH))
    oRegT:SetCmp40(cExiGiISS)
    oRegT:SetCmp41(Iif(cSA2RecIss == "S", "RPP", Iif(cExiGiISS $ "3|5|6|7", "NAP", "RNF")))
    oRegT:SetCmp42(Iif(Empty((cAlias)->F3_ALIQICM), "00.00", PadR(AllTrim(StrTran(Padl(AllTrim(Transform((cAlias)->F3_ALIQICM, "@E 99.99")),5,"0") , ",", ".")), 15, ' ')))
    oRegT:SetCmp43(Iif(Empty((cAlias)->F3_VALCONT), "000000000000.00", PadR(AllTrim(StrTran(Transform((cAlias)->F3_VALCONT, "@E 999999999999.99"), ",", ".")), 15, ' ')))
    oRegT:SetCmp44(Iif(Empty((cAlias)->D1_DESCICM), "000000000000.00", PadR(AllTrim(StrTran(Transform((cAlias)->D1_DESCICM, "@E 999999999999.99"), ",", ".")), 15, ' ')))
    oRegT:SetCmp45(Iif(Empty((cAlias)->DESCONT)   , "000000000000.00", PadR(Iif((cAlias)->F4_DESCOND == "2", AllTrim(StrTran(Transform((cAlias)->DESCONT, "@E 999999999999.99"), ",", ".")), "000000000000.00"), 15, ' ')))
    oRegT:SetCmp46(Iif(Empty((cAlias)->DESCONT)   , "000000000000.00", PadR(Iif((cAlias)->F4_DESCOND == "1", AllTrim(StrTran(Transform((cAlias)->DESCONT, "@E 999999999999.99"), ",", ".")), "000000000000.00"), 15, ' ')))
    oRegT:SetCmp47(Iif(Empty((cAlias)->F3_BASEICM), "000000000000.00", PadR(AllTrim(StrTran(Transform((cAlias)->F3_BASEICM, "@E 999999999999.99"), ",", ".")), 15, ' ')))
    oRegT:SetCmp48(Iif(Empty((cAlias)->VALPIS)    , "000000000000.00", PadR(AllTrim(StrTran(Transform((cAlias)->VALPIS, "@E 999999999999.99"), ",", ".")), 15, ' ')))
    oRegT:SetCmp49(Iif(Empty((cAlias)->VALCOFI)   , "000000000000.00", PadR(AllTrim(StrTran(Transform((cAlias)->VALCOFI, "@E 999999999999.99"), ",", ".")), 15, ' ')))
    oRegT:SetCmp50(Iif(Empty((cAlias)->VALINSS)   , "000000000000.00", PadR(AllTrim(StrTran(Transform((cAlias)->VALINSS, "@E 999999999999.99"), ",", ".")), 15, ' ')))
    oRegT:SetCmp51(Iif(Empty((cAlias)->VALIRRF)   , "000000000000.00", PadR(AllTrim(StrTran(Transform((cAlias)->VALIRRF, "@E 999999999999.99"), ",", ".")), 15, ' ')))
    oRegT:SetCmp52(Iif(Empty((cAlias)->VALCSLL)   , "000000000000.00", PadR(AllTrim(StrTran(Transform((cAlias)->VALCSLL, "@E 999999999999.99"), ",", ".")), 15, ' ')))
    oRegT:SetCmp53(PadR('', 12, "0") + ".00") 
    oRegT:SetCmp54(Iif(Empty((cAlias)->F3_VALICM) , "000000000000.00", PadR(AllTrim(StrTran(Transform((cAlias)->F3_VALICM, "@E 999999999999.99"), ",", ".")), 15, ' ')))
    oRegT:SetCmp55(PadR((cAlias)->B1_DESC, 2000, ' '))

Return
