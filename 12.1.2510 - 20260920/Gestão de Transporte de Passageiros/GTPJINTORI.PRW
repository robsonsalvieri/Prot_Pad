#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} GtpjIntOri
Função que retorna os bilhetes com chave de substituição para serem integrados
@author flavio.martins
@since 30/03/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Function GtpjIntOri(cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim, cAgeIni, cAgeFim)
Local cQuery    := ''
Local cChvOri   := ''
Local oQryTmp   as object
Local cAliasTmp as character


Default cEmpRJ  := ''
Default dDtIni  := Ctod("  /  /  ")
Default cHrIni  := "00:00"
Default dDtFim  := Ctod("  /  /  ")
Default cHrFim  := "23:59"
Default cAgeIni := ''
Default cAgeFim := ''
Default aParam  := {}


If FwGetRunSchedule() // Rotina automatica (schedule)

    cEmpRJ  := MV_PAR01
    dDtIni  := MV_PAR02
    cHrIni  := MV_PAR03
    dDtFim  := MV_PAR04  
    cHrFim  := MV_PAR05
    cAgeIni := MV_PAR06
    cAgeFim := MV_PAR07

Endif
   
cQuery := "SELECT " 
cQuery += "  GIC.GIC_TIPO, "
cQuery += "  GIC.GIC_STATUS, "
cQuery += "  GIC.GIC_DTVEND, "
cQuery += "  GIC.GIC_HRVEND, "
cQuery += "  GIC.GIC_CHVBPE, "
cQuery += "  GIC.GIC_CHVSUB FROM " + RetSqlName('GIC') + " GIC " 
cQuery += "WHERE "
cQuery += "  GIC.GIC_FILIAL = ? "
cQuery += "  AND GIC.GIC_DTVEND BETWEEN ? AND ? "
cQuery += "  AND GIC.GIC_HRVEND BETWEEN ? AND ? "
cQuery += "  AND (GIC_STATUS = 'T' OR (GIC_STATUS = 'C' AND GIC_VENDRJ = 'CAN')) "
cQuery += "  AND GIC.D_E_L_E_T_ = ' ' "

If !Empty(cAgeFim)
    cQuery += "  AND GIC.GIC_AGENCI BETWEEN ? AND ? "
Endif

cQuery += "ORDER BY GIC.GIC_DTVEND, GIC.GIC_HRVEND "

cQuery := ChangeQuery(cQuery)

oQryTmp := FwExecStatement():New(cQuery)
oQryTmp:SetString(1, xFilial("GIC"))
oQryTmp:SetString(2, DtoS(dDtIni))
oQryTmp:SetString(3, DtoS(dDtFim))
oQryTmp:SetString(4, cHrIni)
oQryTmp:SetString(5, cHrFim)

If !Empty(cAgeFim)
    cAgeIni := AllTrim(cEmpRJ) + '|' + cAgeIni
    cAgeIni := GTPxRetId("TotalBus", "GI6", "GI6_CODIGO", cAgeIni, "", 3, .T., "", {"GI6_FILIAL","GI6_CODIGO"}, 1)

    cAgeFim := AllTrim(cEmpRJ) + '|' + cAgeFim
    cAgeFim := GTPxRetId("TotalBus", "GI6", "GI6_CODIGO", cAgeFim, "", 3, .T., "", {"GI6_FILIAL","GI6_CODIGO"}, 1)

    oQryTmp:SetString(6, cAgeIni)
    oQryTmp:SetString(7, cAgeFim)
Endif

cAliasTmp := oQryTmp:OpenAlias()

While (cAliasTmp)->(!Eof())

    If (cAliasTmp)->GIC_STATUS == 'C'
        cChvOri := (cAliasTmp)->GIC_CHVBPE
    Else
        cChvOri := (cAliasTmp)->GIC_CHVSUB
    EndIf

    If !Empty(cChvOri)
        
            CallIntrRJ(cEmpRJ, cChvOri)

    Endif

    (cAliasTmp)->(dbSkip())

EndDo

(cAliasTmp)->(dbCloseArea())
FwFreeObj(oQryTmp)
//Changeset para subida de fonte issue DSERGTP-15189
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaBilOri(cChvOri)
Função responsável por verificar se o bilhete de origem já foi integrado
@author flavio.martins
@since 30/03/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function BuscaBilOri(cChvOri)
Local cQuery    := ''
Local oQryBil   as object
Local cAliasBil as character
Local nWhile    as numeric
Local aRet      := {}
Local lContinua := .T.

nWhile := 10 

While lContinua .And. nWhile > 0
    nWhile--

    cQuery := "SELECT GIC.GIC_STATUS," 
    cQuery += "  GIC.GIC_STAPRO, " 
    cQuery += "  GIC.GIC_CHVBPE, " 
    cQuery += "  GIC.GIC_CHVSUB FROM " + RetSqlName('GIC') + " GIC " 
    cQuery += "WHERE "
    cQuery += "  GIC.GIC_FILIAL = ? "
    cQuery += "  AND GIC.GIC_CHVBPE = ? "
    cQuery += "  AND GIC.D_E_L_E_T_ = ' ' "
    cQuery += "  AND GIC.GIC_STATUS IN ('T','V') "

    cQuery := ChangeQuery(cQuery)

    oQryBil := FwExecStatement():New(cQuery)
    oQryBil:SetString(1, xFilial("GIC"))
    oQryBil:SetString(2, cChvOri)

    cAliasBil := oQryBil:OpenAlias()

    If (cAliasBil)->(!Eof())
        if (cAliasBil)->GIC_STAPRO <> '1'
            aAdd(aRet,{cChvOri,.T.})
        EndIf

        If (cAliasBil)->GIC_STATUS == 'V'
            lContinua := .F.
        Else
            cChvOri := (cAliasBil)->GIC_CHVSUB
        Endif
    Else
        aAdd(aRet,{cChvOri,.F.})
        lContinua := .F.
    Endif

    (cAliasBil)->(dbCloseArea())

EndDo

FwFreeObj(oQryBil)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CallIntrRJ(cEmpRJ, cChvOri)
Função recursiva responsável por integrar os bilhetes de origem e seus substitutos
@author flavio.martins
@since 30/03/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function CallIntrRJ(cEmpRJ, cChvOri)
Local dDataIni   := ''
Local dDataFim   := ''
Local aParams    := {}
Local cCodIntr   := ''
Local cStatus    := ''
Local cChvOrigem := ''
Local aBilhetes  := {}
Local nI         := 0
Local aAreaGIC   := GIC->(GetArea())

aBilhetes := BuscaBilOri(cChvOri)

If Len(aBilhetes) > 0

    For nI := Len(aBilhetes) to 1 Step -1
        cCodIntr   := ''
        cChvOrigem := aBilhetes[nI][1]

        If !(aBilhetes[nI][2])

            dDataIni := CtoD('01/'+Substr(cChvOrigem,5,2)+'/2'+Padl(Substr(cChvOrigem,3,2),3,'0'))
            dDataFim := LastDate(dDataIni)

            aParams := {cEmpRJ,dDataIni,"00:00",dDataFim,"23:59",/*cAgenc*/ "",/*cAgenc*/ ""}

            GTPIRJ115(.T.,aParams,.F.,.F.,"","",cChvOrigem,"",@cCodIntr, .F.)
            
            GIC->(DbSetOrder(12)) //GIC_FILIAL+GIC_CHVBPE+GIC_STATUS

            If !Empty(cCodIntr) 
                cStatus := ""                
                If GIC->(DBSeek(xFilial('GIC')+cChvOrigem))
                    While GIC->(!Eof()) .And. GIC->(GIC_FILIAL+GIC_CHVBPE) == xFilial('GIC')+cChvOrigem
                        If GIC->GIC_STATUS <> 'C'
                            cStatus := GIC->GIC_STATUS
                        Endif
                        GIC->(DBSkip())
                    EndDo
                Endif

                If cStatus == 'T'
                    CallIntrRJ(cEmpRJ, cChvOrigem)
                Endif
            Endif

        Endif

        GTPJBPE(.T., Nil, Nil, Nil, Nil, cChvOrigem, .T.)	

    Next nI

Endif

ASize(aBilhetes,0)
RestArea(aAreaGIC)

Return 

Static Function Scheddef()

Local aParam  := {}

aParam := { "P",;           //Tipo R para relatorio P para processo
            "GTPJINTORI",;   //Pergunte do relatorio, caso nao use passar ParamDef
            ,;              //Alias
            ,;              //Array de ordens
            }               //Titulo

Return aParam
