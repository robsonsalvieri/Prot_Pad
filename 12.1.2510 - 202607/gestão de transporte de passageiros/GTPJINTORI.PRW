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
Local oQryTmp   as object
Local cAliasTmp as character
Local cChvOri   := ''

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
cQuery += "  AND GIC_STATUS IN ('C', 'T') "
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
        
        If !(BuscaBilOri(cChvOri, (cAliasTmp)->GIC_STATUS))

            CallIntrRJ(cEmpRJ, cChvOri)

        Endif

    Endif

    (cAliasTmp)->(dbSkip())

EndDo

(cAliasTmp)->(dbCloseArea())
FwFreeObj(oQryTmp)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaBilOri(cChvOri, cStatus)
Função responsável por verificar se o bilhete de origem já foi integrado
@author flavio.martins
@since 30/03/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function BuscaBilOri(cChvOri, cStatus)
Local lRet      := .F.
Local cQuery    := ''
Local oQryBil   as object
Local cAliasBil as character

cQuery := "SELECT GIC.GIC_CODIGO," 
cQuery += "  GIC.GIC_TIPO FROM " + RetSqlName('GIC') + " GIC " 
cQuery += "WHERE "
cQuery += "  GIC.GIC_FILIAL = ? "
cQuery += "  AND GIC.GIC_CHVBPE = ? "
cQuery += "  AND GIC.D_E_L_E_T_ = ' ' "

If (cStatus == 'C')
    cQuery += "  AND GIC.GIC_STATUS != 'T' "
Else
    cQuery += "  AND GIC.GIC_STATUS != 'C' "
Endif

cQuery := ChangeQuery(cQuery)

oQryBil := FwExecStatement():New(cQuery)
oQryBil:SetString(1, xFilial("GIC"))
oQryBil:SetString(2, cChvOri)

cAliasBil := oQryBil:OpenAlias()

lRet := (cAliasBil)->(!Eof())

(cAliasBil)->(dbCloseArea())

FwFreeObj(oQryBil)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CallIntrRJ(cEmpRJ, cChvOri, aChvBpe, lCallRoot)
Função recursiva responsável por integrar os bilhetes de origem e seus substitutos
@author flavio.martins
@since 30/03/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function CallIntrRJ(cEmpRJ, cChvOri, aChvBpe, lCallRoot)
Local dDataIni   := ''
Local dDataFim   := ''
Local aParams    := {}
Local lRet       := .F.
Local cCodIntr   := ''
Local cNewChvOri := ''
Local cNewStatus := ''
Local nX         := 0
Local lIntBilOri := .F.

Default aChvBpe  := {}
Default lCallRoot := .T.

dDataIni := CtoD('01/'+Substr(cChvOri,5,2)+'/2'+Padl(Substr(cChvOri,3,2),3,'0'))
dDataFim := LastDate(dDataIni)

aParams := {cEmpRJ,dDataIni,"00:00",dDataFim,"23:59",/*cAgenc*/ "",/*cAgenc*/ ""}

GTPIRJ115(.T.,aParams,.F.,.F.,"","",cChvOri,"",@cCodIntr, lIntBilOri)

If !Empty(cCodIntr) 

    If Ascan(aChvBpe, cChvOri) == 0
        Aadd(aChvBpe, cChvOri)
    Endif

    VldBilIntr(cCodIntr, @cNewChvOri, @cNewStatus)

    If !Empty(cNewChvOri)

        If !(BuscaBilOri(cNewChvOri, cNewStatus))

            CallIntrRJ(cEmpRJ, cNewChvOri, @aChvBpe, .F.)

        Endif

    Endif

    If lCallRoot
        For nX := Len(aChvBpe) To 1 Step -1

            If !Empty(aChvBpe[nX])
                GTPJBPE(.T., Nil, Nil, Nil, Nil, aChvBpe[nX], .T.)	
            Endif
            
        Next
    Endif

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldBilIntr(cCodBil, cNewChvOri, cNewStatus)
Função responsável por validar o bilhete integrado e retornar a chave de substituição caso exista
@author flavio.martins
@since 30/03/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function VldBilIntr(cCodBil, cNewChvOri, cNewStatus)
Local cQuery    := ''
Local oQryGIC   as object
Local cAliasGIC as character

cQuery := "SELECT GIC.GIC_CHVSUB," 
cQuery += "  GIC.GIC_STATUS FROM " + RetSqlName('GIC') + " GIC " 
cQuery += "WHERE "
cQuery += "  GIC.GIC_FILIAL = ? "
cQuery += "  AND GIC.GIC_CODIGO = ? "
cQuery += "  AND GIC.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

oQryGIC := FwExecStatement():New(cQuery)
oQryGIC:SetString(1, xFilial("GIC"))
oQryGIC:SetString(2, cCodBil)

cAliasGIC := oQryGIC:OpenAlias()

cNewChvOri := (cAliasGIC)->GIC_CHVSUB
cNewStatus := (cAliasGIC)->GIC_STATUS

(cAliasGIC)->(dbCloseArea())

FwFreeObj(oQryGIC)  

Return Nil

Static Function Scheddef()

Local aParam  := {}

aParam := { "P",;           //Tipo R para relatorio P para processo
            "GTPJINTORI",;   //Pergunte do relatorio, caso nao use passar ParamDef
            ,;              //Alias
            ,;              //Array de ordens
            }               //Titulo

Return aParam
