#include "protheus.ch"

/*
  Esta funcao foi criada para que seja possivel visualizar a data deste
  fonte no inspetor de objetos, pois nao eh possivel fazer isso se nao
  houver nenhuma FUNCTION no fonte.
*/
function FISA307A();Return

//------------------------------------------------------------------
// Montagem das Classes e Metodos do Fonte
//------------------------------------------------------------------

//------------------------------------------------------------------
/*/{Protheus.doc} DMSGEN

    Classe para criar o objeto que receberá o Pergunte da rotina 
    para geração do arquivo
    /*/
//------------------------------------------------------------------
CLASS DMSGEN
    Data dDataIni   As Date    HIDDEN
    Data dDataFim   As Date    HIDDEN
    Data cArqName   As String  HIDDEN
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
    Method GetArqName()
    Method GetPath()

ENDCLASS

Method New(Value1, Value2, Value3, Value4) Class DMSGEN
    Self:dDataIni  := Value1
    Self:dDataFim  := Value2
    Self:cPath     := Value3
    Self:cArqName  := Value4
Return Self

Method SetDtIni(Value) Class DMSGEN
    Self:dDataIni := Value
Return

Method SetDtFim(Value) Class DMSGEN
    Self:dDataFim := Value
Return

Method SetArcName(Value) Class DMSGEN
    Self:cArqName := Value
Return

Method SetPath(Value) Class DMSGEN
    Self:cPath := Value
Return

Method GetDtIni() Class DMSGEN
Return Self:dDataIni

Method GetDtFim() Class DMSGEN
Return Self:dDataFim

Method GetArqName() Class DMSGEN
Return Self:cArqName

Method GetPath() Class DMSGEN
Return Self:cPath

//------------------------------------------------------------------
/*/{Protheus.doc} DMSREG

    Classe para criar o objeto que receberá os atributos para geração 
    dos Registros com os itens da NFS

/*/
//------------------------------------------------------------------
CLASS DMSREG
    Data dEmissao   As Date    HIDDEN    // Campo - 1   F3_EMISSAO
    Data nDoc       As Integer HIDDEN    // Campo - 2   F3_NFISCAL
    Data cSerie     As String  HIDDEN    // Campo - 3   F3_SERIE
    Data cEspecie   As String  HIDDEN    // Campo - 4   F3_ESPECIE
    Data nTpRecImp  As String  HIDDEN    // Campo - 5   F3_RECISS
    Data cTpNf      As String  HIDDEN    // Campo - 6   F3_TIPO
    Data cAliqISS   As String  HIDDEN    // Campo - 7   F3_ALQICM
    Data cValNF     As String  HIDDEN    // Campo - 8   F3_VALCONT
    Data cBaseCalc  As String  HIDDEN    // Campo - 9   F3_BASEICM
    Data cValorISS  As String  HIDDEN    // Campo - 10  F3_VALICM
    Data cCodServ   As String  HIDDEN    // Campo - 11  F3_CODISS
    Data cTpForn    As String  HIDDEN    // Campo - 12  A2_TIPO
    Data cCGCForn   As String  HIDDEN    // Campo - 13  A2_CGC
    Data cNomeForn  As String  HIDDEN    // Campo - 14  A2_NOME
    Data nCEPForn   As Integer HIDDEN    // Campo - 15  A2_CEP
    Data cTpLogrado As String  HIDDEN    // Campo - 16  A2_END
    Data cNomeLogra As String  HIDDEN    // Campo - 17  A2_END
    Data nNumLograd As Integer HIDDEN    // Campo - 18  A2_END
    Data cComplForn As String  HIDDEN    // Campo - 19  A2_COMPLEM
    Data cBairro    As String  HIDDEN    // Campo - 20  A2_BAIRRO
    Data cUFForn    As String  HIDDEN    // Campo - 21  A2_EST
    Data cPaísForn  As String  HIDDEN    // Campo - 22  
    Data cCidade    As String  HIDDEN    // Campo - 23
    Data nExigiISS  As Integer HIDDEN    // Campo - 24  A2_RECISS
    Data cInscrE    As String  HIDDEN    // Campo - 25  A2_INSCR
    Data cInscrM    As String  HIDDEN    // Campo - 26  A2_INSCRM
    Data cDDDForn   As String  HIDDEN    // Campo - 27  A2_DDD
    Data cTelForn   As String  HIDDEN    // Campo - 28  A2_TEL
    Data cMunPrest  As String  HIDDEN    // Campo - 29  A2_EST+A2_COD_MUN
    


    Method New()
    Method LimpaObj()
    
    Method SetCmp1(Value)
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
    
    Method GravaReg(oRegDms, cAlias)

ENDCLASS

Method New() Class DMSREG
   
Return 

Method LimpaObj() Class DMSREG
    Self:dEmissao   := '  /  /    '
    Self:nDoc       := 0
    Self:cSerie     := ''
    Self:cEspecie   := ''
    Self:nTpRecImp  := 0
    Self:cTpNf      := ''
    Self:cAliqISS   := ''
    Self:cValNF     := ''
    Self:cBaseCalc  := ''
    Self:cValorISS  := ''
    Self:cCodServ   := ''
    Self:cTpForn    := ''
    Self:cCGCForn   := ''
    Self:cNomeForn  := ''    
    Self:nCEPForn   := 0
    Self:cTpLogrado := ''
    Self:cNomeLogra := ''
    Self:nNumLograd := 0
    Self:cComplForn := ''
    Self:cBairro    := ''
    Self:cUFForn    := ''
    Self:cPaísForn  := ''
    Self:cCidade    := ''
    Self:nExigiISS  := 0
    Self:cInscrE    := ''
    Self:cInscrM    := ''
    Self:cDDDForn   := ''
    Self:cTelForn   := ''
    Self:cMunPrest  := ''
    
Return

Method SetCmp1(Value) Class DMSREG
    Self:dEmissao := Value
Return

Method SetCmp2(Value) Class DMSREG
    Self:nDoc := Value
Return

Method SetCmp3(Value) Class DMSREG
    Self:cSerie := Value
Return

Method SetCmp4(Value) Class DMSREG
    Self:cEspecie := Value
Return

Method SetCmp5(Value) Class DMSREG
    Self:nTpRecImp := Value
Return

Method SetCmp6(Value) Class DMSREG
    Self:cTpNf := Value
Return

Method SetCmp7(Value) Class DMSREG
    Self:cAliqISS := Value
Return

Method SetCmp8(Value) Class DMSREG
    Self:cValNF := Value
Return

Method SetCmp9(Value) Class DMSREG
    Self:cBaseCalc := Value
Return

Method SetCmp10(Value) Class DMSREG
    Self:cValorISS := Value
Return

Method SetCmp11(Value) Class DMSREG
    Self:cCodServ := Value
Return

Method SetCmp12(Value) Class DMSREG
    Self:cTpForn := Value
Return

Method SetCmp13(Value) Class DMSREG
    Self:cCGCForn := Value
Return

Method SetCmp14(Value) Class DMSREG
    Self:cNomeForn := Value
Return

Method SetCmp15(Value) Class DMSREG
    Self:nCEPForn := Value
Return

Method SetCmp16(Value) Class DMSREG
    Self:cTpLogrado := Value
Return

Method SetCmp17(Value) Class DMSREG
    Self:cNomeLogra := Value
Return

Method SetCmp18(Value) Class DMSREG
    Self:nNumLograd := Value
Return

Method SetCmp19(Value) Class DMSREG
    Self:cComplForn := Value
Return

Method SetCmp20(Value) Class DMSREG
    Self:cBairro := Value
Return

Method SetCmp21(Value) Class DMSREG
    Self:cUFForn := Value
Return

Method SetCmp22(Value) Class DMSREG
    Self:cPaísForn := Value
Return

Method SetCmp23(Value) Class DMSREG
    Self:cCidade := Value
Return

Method SetCmp24(Value) Class DMSREG
    Self:nExigiISS := Value
Return

Method SetCmp25(Value) Class DMSREG
    Self:cInscrE := Value
Return

Method SetCmp26(Value) Class DMSREG
    Self:cInscrM := Value
Return

Method SetCmp27(Value) Class DMSREG
    Self:cDDDForn := Value
Return

Method SetCmp28(Value) Class DMSREG
    Self:cTelForn := Value
Return

Method SetCmp29(Value) Class DMSREG
    Self:cMunPrest := Value
Return

Method GetCmp1() Class DMSREG
Return Self:dEmissao

Method GetCmp2() Class DMSREG
Return Self:nDoc

Method GetCmp3() Class DMSREG
Return Self:cSerie

Method GetCmp4() Class DMSREG
Return Self:cEspecie

Method GetCmp5() Class DMSREG
Return Self:nTpRecImp

Method GetCmp6() Class DMSREG
Return Self:cTpNf

Method GetCmp7() Class DMSREG
Return Self:cAliqISS

Method GetCmp8() Class DMSREG
Return Self:cValNF

Method GetCmp9() Class DMSREG
Return Self:cBaseCalc

Method GetCmp10() Class DMSREG
Return Self:cValorISS

Method GetCmp11() Class DMSREG
Return Self:cCodServ

Method GetCmp12() Class DMSREG
Return Self:cTpForn

Method GetCmp13() Class DMSREG
Return Self:cCGCForn

Method GetCmp14() Class DMSREG
Return Self:cNomeForn

Method GetCmp15() Class DMSREG
Return Self:nCEPForn

Method GetCmp16() Class DMSREG
Return Self:cTpLogrado

Method GetCmp17() Class DMSREG
Return Self:cNomeLogra

Method GetCmp18() Class DMSREG
Return Self:nNumLograd

Method GetCmp19() Class DMSREG
Return Self:cComplForn

Method GetCmp20() Class DMSREG
Return Self:cBairro

Method GetCmp21() Class DMSREG
Return Self:cUFForn

Method GetCmp22() Class DMSREG
Return Self:cPaísForn 

Method GetCmp23() Class DMSREG
Return Self:cCidade

Method GetCmp24() Class DMSREG
Return Self:nExigiISS

Method GetCmp25() Class DMSREG
Return Self:cInscrE

Method GetCmp26() Class DMSREG
Return Self:cInscrM

Method GetCmp27() Class DMSREG
Return Self:cDDDForn

Method GetCmp28() Class DMSREG
Return Self:cTelForn

Method GetCmp29() Class DMSREG
Return Self:cMunPrest


Method GravaReg(oRegDms, cAlias) Class DMSREG
    Local lExterior  := AllTrim((cAlias)->PAIS) != '105'

    oRegDms:SetCmp1((cAlias)->F3_EMISSAO)
    oRegDms:SetCmp2(Alltrim((cAlias)->F3_NFISCAL))
    oRegDms:SetCmp3(Alltrim((cAlias)->F3_SERIE))
    oRegDms:SetCmp4(Alltrim((cAlias)->F3_ESPECIE))
    oRegDms:SetCmp5((cAlias)->F3_RECISS)
    oRegDms:SetCmp6((cAlias)->F3_TIPO)
    oRegDms:SetCmp7(Iif(Empty((cAlias)->F3_ALIQICM), "0.00", PadR(AllTrim(StrTran(AllTrim(Transform((cAlias)->F3_ALIQICM, "@E 99.99")), ",", ".")), 15, ' ')))
    oRegDms:SetCmp8(Iif(Empty((cAlias)->F3_VALCONT), "0.00", PadR(AllTrim(StrTran(Transform((cAlias)->F3_VALCONT, "@E 999999999999.99"), ",", ".")), 15, ' ')))
    oRegDms:SetCmp9(Iif(Empty((cAlias)->F3_BASEICM), "0.00", PadR(AllTrim(StrTran(Transform((cAlias)->F3_BASEICM, "@E 999999999999.99"), ",", ".")), 15, ' ')))
    oRegDms:SetCmp10(Iif(Empty((cAlias)->F3_VALICM), "0.00", PadR(AllTrim(StrTran(Transform((cAlias)->F3_VALICM,  "@E 999999999999.99"), ",", ".")), 15, ' ')))
    oRegDms:SetCmp11(PadR((cAlias)->F3_CODISS, 5, ' '))
    oRegDms:SetCmp12((cAlias)->TIPO)
    oRegDms:SetCmp13((cAlias)->CGC)
    oRegDms:SetCmp14(Rtrim(ltrim((cAlias)->NOME)))
    oRegDms:SetCmp15((cAlias)->CEP)
    oRegDms:SetCmp16(PadR(fTrtEnd((cAlias)->ENDERECO)[1], 25, " "))
    oRegDms:SetCmp17(PadR(fTrtEnd((cAlias)->ENDERECO)[2], 50, " "))
    oRegDms:SetCmp18(PadR(fTrtEnd((cAlias)->ENDERECO)[3], 10, " "))
    oRegDms:SetCmp19(PadR((cAlias)->COMPLEMENTO, 60, " "))
    oRegDms:SetCmp20(PadR((cAlias)->BAIRRO, 60, " "))
    oRegDms:SetCmp21(PadR((cAlias)->ESTADO, 2, " "))
    oRegDms:SetCmp22(PadR(Iif(lExterior, Alltrim((cAlias)->A2_CODPAIS), '01058'),5," "))
    oRegDms:SetCmp23(PadR((cAlias)->MUNICIPIO, 50, ' '))
    oRegDms:SetCmp24(PadR((cAlias)->A2_RECISS, 5, ' '))
    oRegDms:SetCmp25(PadR(Alltrim((cAlias)->IE), 15, " "))
    oRegDms:SetCmp26(PadR(Alltrim((cAlias)->A2_INSCRM), 15, " "))
    oRegDms:SetCmp27(PadR(Alltrim((cAlias)->A2_DDD), 5, " "))
    oRegDms:SetCmp28(PadR(Alltrim((cAlias)->A2_TEL), 15, " "))
    oRegDms:SetCmp29(UfCodIBGE((cAlias)->ESTADO)+(cAlias)->CODMUN)

Return