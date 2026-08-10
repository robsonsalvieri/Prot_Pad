#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU69XFUN.CH"
/*
{Protheus.doc} RU69XFIL
@author         Alexander Salov
@since          7.18.2018
@version        1.0 
@param          cAlias table name to detirmine context
@param          cType SA1 or SA2
@param          cCtrAgent Counteragent ID
@param          cCtrAUnit Counteragent Unit ID
@return         boolean if contract is ok
@type           function
@description    Finite-state machine to filter contracts by current counteragent (supplier or client) described in some context. 
@e.g            RU69XFIL ("SF1","SA2",Posicione("CNC",1,xFilial("CNC")+CN9->(CN9_NUMERO+CN9_REVISA),"CNC_CODIGO"),Posicione("CNC",1,xFilial("CNC")+CN9->(CN9_NUMERO+CN9_REVISA),"CNC_LOJA"))
*/    
Function RU69XFIL (cAlias as CHARACTER, cType as CHARACTER, cCtrAgent as CHARACTER, cCtrAUnit as CHARACTER)
Local lRet as LOGICAL

lRet := .F.

Do Case
	Case cAlias == 'SF1'
        lRet := SF1Filter(cCtrAgent,cCtrAUnit)
	Case cAlias == 'SF2'
        lRet := SF2Filter(cCtrAgent,cCtrAUnit)
        Case cAlias == 'F47'
        lRet := FINFilter(cType,cCtrAgent,cCtrAUnit, "F47")
        Case cAlias == 'F4C'
        lRet := FINFilter(cType,cCtrAgent,cCtrAUnit, "F4C")
EndCase
Return lRet

/* 
{Protheus.doc} F47Filter
@author         Alexander Salov
@since          7.18.2018
@version        1.0 
@param          cType SA1 or SA2
@param          cCtrAgent Counteragent ID
@param          cCtrAUnit Counteragent Unit ID 
@return         boolean true if contract is ok
@type           function
@description    Filtering for F47
*/
Static Function FINFilter (cType as CHARACTER, cCtrAgent as CHARACTER, cCtrAUnit as CHARACTER, cAlias as CHARACTER)
Local lRet as LOGICAL
lRet := .F.
Do Case
	Case cType == 'SA1'
        lRet := ClientFINFilter(cCtrAgent,cCtrAUnit,cAlias)
	Case cType == 'SA2'
        lRet := SupplierFINFilter(cCtrAgent,cCtrAUnit,cAlias)
EndCase
Return lRet

/*
{Protheus.doc} Compare
@author         Alexander Salov
@since          7.18.2018
@version        1.0 
@param          cType SA1 or SA2
@param          cCurrentCtrAgent Counteragent ID in context
@param          cCurrentCtrAUnit Counteragent Unit ID in context
@param          cCtrAgent Counteragent ID
@param          cCtrAUnit Counteragent Unit ID 
@return         boolean true if contract is ok
@type           function
@description    Comparator function
*/
Static Function Compare (cCurCtrAgent as CHARACTER, cCurCtrAUnit as CHARACTER, cCtrAgent as CHARACTER, cCtrAUnit as CHARACTER)
Return AllTrim(cCurCtrAgent)+AllTrim(cCurCtrAUnit) == AllTrim(cCtrAgent)+AllTrim(cCtrAUnit)

/*
{Protheus.doc} SupplierF47Filter
@author         Alexander Salov
@since          7.18.2018
@version        1.0 
@param          cCtrAgent Counteragent ID
@param          cCtrAUnit Counteragent Unit ID 
@return         boolean true if contract is ok
@type           function
@description    end state check for filter, SF2 CLient
*/
Static Function SF1Filter(cCtrAgent as CHARACTER, cCtrAUnit as CHARACTER)
Return Compare(M->F1_FORNECE,M->F1_LOJA,cCtrAgent,cCtrAUnit)

/*
{Protheus.doc} SupplierF47Filter
@author         Alexander Salov
@since          7.18.2018
@version        1.0 
@param          cCtrAgent Counteragent ID
@param          cCtrAUnit Counteragent Unit ID 
@return         boolean true if contract is ok
@type           function
@description    end state check for filter, SF2 CLient
*/
Static Function SF2Filter (cCtrAgent as CHARACTER, cCtrAUnit as CHARACTER)
Return Compare(M->F2_CLIENTE,M->F2_LOJA,cCtrAgent,cCtrAUnit)

/*
{Protheus.doc} SupplierF47Filter
@author         Alexander Salov
@since          7.18.2018
@version        1.0 
@param          cCtrAgent Counteragent ID
@param          cCtrAUnit Counteragent Unit ID 
@return         boolean true if contract is ok
@type           function
@description    end state check for filter, F47 suplier
*/
Static Function SupplierFINFilter (cCtrAgent as CHARACTER, cCtrAUnit as CHARACTER, cAlias as CHARACTER)
Local cSuppName as CHARACTER
Local cUnitName as CHARACTER

cSuppName:='M->'+cAlias+'_SUPP'
cUnitName:='M->'+cAlias+'_UNIT'

Return Compare(&(cSuppName),&(cUnitName),cCtrAgent,cCtrAUnit)

/*
{Protheus.doc} SupplierF47Filter
@author         Alexander Salov
@since          7.18.2018
@version        1.0 
@param          cCtrAgent Counteragent ID
@param          cCtrAUnit Counteragent Unit ID 
@return         boolean true if contract is ok
@type           function
@description    end state check for filter, F47 suplier
*/
Static Function ClientFINFilter (cCtrAgent as CHARACTER, cCtrAUnit as CHARACTER, cAlias as CHARACTER)
    //Not implemnted yet as client is column does not exist in F47 yet
Return .F.

/*/{Protheus.doc} RU69XFUN01
TListBox for selecting among the same Legal Contracts Code
@author Konstantin Cherchik
@since 17/12/2019
@version P12.1.27
@type function
/*/
Function RU69XFUN01(cLegCode as Character)
        
        Local cLegConUID        as Character
        Local cTabLegCon        as Character
        Local aLegCont          as Array
        Local aContList         as Array
        Local aSaveArea         as Array
        Local oDlg              as Object
        Local nList             as Numeric
        Local nPosition         as Numeric
        Local lAuto             as Logical
        
        aLegCont   := {}
        aContList  := {}
        nList      := 1
        nPosition  := 1
        cLegConUID := ""
        lAuto      := FwIsInCallStack("MSEXECAUTO")
        
        
        If FwIsInCallStack("MATA121") .And. !EMPTY(AllTrim(cLegConCode))
                cLegContr := ""
                cLegCode  := cLegConCode
        ElseIf lAuto .And. FwIsInCallStack("RU06D07RUS")
                // when we post new exchange rate difference line by BS posting process
                // we don't fill legal contract code, because filled contract code field E2_F5QUID
                // is a trigger condition for E2_MOEDA, and if we have in contract E2_MOEDA == 3, 
                // exchange rate difference value will be multipled to exchange rate for 3 currency.
                // So this value completley wrong. Please check SX7 table for x7_campo == "E2_F5QCODE"
                // So E2_MOEDA should be equal to nMoedaTit in F084Grava function.
                // Contract codes should be passed by aTitulo array like it is implemented in F084Grava.
                If !FwIsInCallStack("FA084GDIF")
                        cLegConUID := AllTrim(M->F4C_UIDF5Q)
                EndIf
        EndIf
        
        If !EMPTY(AllTrim(cLegCode)) .And. !lAuto
                aSaveArea := GetArea()
                cTabLegCon := RU01GETALS(RU69XFUN03_LegContr(cLegCode))
        
                While ((cTabLegCon)->(!EoF()))
                        AAdd(aLegCont,{(cTabLegCon)->(F5Q_UID),(cTabLegCon)->(F5Q_CODE),(cTabLegCon)->(F5Q_DESCR),(cTabLegCon)->(F5Q_MOEDA)})
                        AAdd(aContList,(cTabLegCon)->(F5Q_CODE) + " - " + (cTabLegCon)->(F5Q_DESCR))
                        (cTabLegCon)->(DbSkip())
                EndDo
        
                If ValType(aContList) == "A" .And. Len(aContList)>1
        
                        DEFINE DIALOG oDlg TITLE STR0001 FROM 120,120 TO 315,534 PIXEL
                        @ 3,2 Say RetTitle("F5Q_CODE") SIZE 45,7 OF oDlg PIXEL
                        @ 3,45 Say RetTitle("F5Q_DESCR") SIZE 120,7 OF oDlg PIXEL
                        oLegContList := TListBox():New(010,001,{|u|if(Pcount()>0,nList:=u,nList)},aContList,205,85,,oDlg,,,,.T.,,{ || nPosition := oLegContList:GetPos(), oDlg:End()})
                        ACTIVATE DIALOG oDlg CENTERED
        
                EndIf
        
                cLegConUID := aLegCont[nPosition][1]
                RU69XFUN05_TxMoeda(aLegCont[nPosition][4])
                (cTabLegCon)->(dbCloseArea())
                RestArea(aSaveArea) 
        EndIf

Return cLegConUID

/*/{Protheus.doc} RU69XFUN03_LegContr
Query to create the temporary table of Legal Contracts with same codes.
@author Konstantin Cherchik
@since 17/12/2019
@version P12.1.27
@type function
/*/
Function RU69XFUN03_LegContr(cLegCode as Character)

        Local cQuery as Character

        cQuery := " SELECT * FROM " + RetSQLName("F5Q")
        cQuery += " WHERE F5Q_FILIAL = '" + xFilial("F5Q") + "' "
        cQuery += " AND F5Q_CODE = '" + AllTrim(cLegCode) + "' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += " ORDER BY F5Q_CODE ASC"

        cQuery := ChangeQuery(cQuery)
 
Return cQuery

/*/{Protheus.doc} RU69XFUN04_When
Function for x3_when for fields F4C_SUPP, F4C_UNIT
@author Konstantin Cherchik
@since 17/12/2019
@version P12.1.27
@type function
/*/
Function RU69XFUN04_When(cPayOrd as Character, cOper as Character, cCNT as Character)

        Local lRet as Logical 

        Default cPayOrd := Space(TamSX3("F4C_PAYORD")[1])
        Default cOper   := Space(TamSX3("F4C_OPER")[1])
        Default cCNT    := Space(TamSX3("F4C_CNT")[1])

        lRet := .T.

        If !EMPTY(AllTrim(cPayOrd))
                lRet := .F.
        EndIf

        If AllTrim(cOper) != '2'
                lRet := .F.  
        EndIf

        If !EMPTY(AllTrim(cCNT))
                lRet := .F.
        EndIf

Return lRet

/*/{Protheus.doc} RU69XFUN05_TxModa
Function for recalculation of moeda exchange rate in Sales/Purchase order, Inflow/Outflow invoice
@author Konstantin Cherchik
@since 05/03/2020
@version P12.1.30
@type function
/*/
Function RU69XFUN05_TxMoeda(nMoeda as Numeric)

        Local lRet as Logical

        Default lRet   := .T.
        Default nMoeda := 1     // Rubles by default

        Do Case
                Case __ReadVar == "cLegConCod"          // Purchase order, fields are defined in code, not in metadata, assigning values directly to the variables is permissible
                        nMoedaPed     := nMoeda
                        nTxMoeda      := RecMoeda(dA120Emis,nMoeda)
                Case SubStr(__ReadVar,4,2) == "C5"      // Sales order
                        M->C5_MOEDA   := nMoeda
                        M->C5_TXMOEDA := RecMoeda(M->C5_EMISSAO,nMoeda)
                Case SubStr(__ReadVar,4,2) == "F1"      // Inflow invoice
                        M->F1_MOEDA   := nMoeda
                        M->F1_TXMOEDA := RecMoeda(M->F1_EMISSAO,nMoeda)
                        ExcRt101N()
                Case SubStr(__ReadVar,4,2) == "F2"      // Outflow invoice
                        lRet := RU69XFUN06_UpdVars({{"M->F2_MOEDA",nMoeda},{"M->F2_TXMOEDA",RecMoeda(M->F2_EMISSAO,nMoeda)}})
        EndCase

Return lRet

/*/{Protheus.doc} RU69XFUN06_UpdVars
Here we change vars and runs validation rules for them
@author astepanov
@since 04 March 2021
@version 1.1
@type static function
@param
Array       aMVars   // array with variables and new values for them
                     // for example 
                     // {{"M->F2_MOEDA",2},{"M->F2_TXMOEDA",72.55}}
For example:
we validate M->F2_MOEDA because during validation we run
function MaFisRef("NF_MOEDA","MT100",M->F2_MOEDA)
in this function we update static var aNFCab from matxfis.prx
aNFCab[NF_MOEDA] should be set to nMoeda
It is obligatory for correct calculations in foreign currency
We validate M->F2_TXMOEDA", because during validation
we run for example ExcRt467N() function.
@see // https://jiraproducao.totvs.com.br/browse/RULOC-831
/*/
Static Function RU69XFUN06_UpdVars(aMVars)
        Local aArea   As Array
        Local cReadV  As Character
        Local cVar    As Character
        Local cValid  As Character
        Local cWhen   As Character
        Local lRet    As Logical
        Local nX      As Numeric
        Local nPos    As Numeric
        Local bWhen   As Block
        Local bChange As Block
        Local bValid  As Block
        Local xOldVal

        lRet      := .T.
        aArea     := GetArea()
        cReadV    := __ReadVar
        nX := 1
        While lRet .AND. nX <= Len(aMVars)
                cVar      := aMVars[nX][1]
                __ReadVar := cVar
                xOldVal   := &cVar
                //We use bWhen from SX3 and it should be empty (please check X3_WHEN) or not have a condition Empty("M->F2_CNTID")
                //Condition Empty("M->F2_CNTID") returns false in case we fill
                //currency from contract.
                cWhen   := GetSX3Cache(SubStr(cVar,4),"X3_WHEN")
                bWhen   := &("{ || " + IIF(Empty(cWhen), " .T. ", cWhen) + "}")
                bChange := { ||  }
                bValid  := { || .T. }
                //try to find objects created by locxnf
                nPos := IIF(__AOGETS != Nil .AND. TYPE("__AOGETS") == "A",ASCAN(__AOGETS, {|x| x:cReadVar == cVar }),0)
                If nPos > 0
                        bChange := __AOGETS[nPos]:bChange
                        bValid  := __AOGETS[nPos]:bValid
                Else
                        cValid := LocX3VALID(SubStr(cVar,4))
                        bValid := &("{ || " + IIF(Empty(cValid), " .T. ", cValid) + "}")
                EndIf           
                If Eval(bWhen) //always check this condition because a field can be locked for change, don't remove   
                        &cVar := aMVars[nX][2]
                        Eval(bChange) //as usual Eval(bChange) returns Nil, so we not check result of this block
                        lRet := Eval(bValid) //validate new value, don't remove
                Else
                        lRet := .F. // field changing is prohibited
                EndIf
                nX := nX + 1
        EndDo
        If !lRet
                //return previous value if not validated or field changing is prohibited in bWhen block of code
                &cVar := xOldVal
        EndIf
        __ReadVar := cReadV
        RestArea(aArea)

Return lRet //end of RU69XFUN06_UpdVars


/*/{Protheus.doc} RU69XFNE1F
	Default filter for F5QSE1
        we use condition  1 = 1 , becase several databases doesn't support logical data types
	@type  Function
	@author astepanov
	@since 18/10/2022
	@version version
	@return , Character, part of SQL query for appling to WHERE clause of Standard Query.
	@example
	Original filter in XB_CONTEM was 
	F5Q->F5Q_STATUS=="1".AND.M->E1_CLIENTE==F5Q->F5Q_A1COD.AND.M->E1_LOJA==F5Q->F5Q_A1LOJ.AND.!EMPTY(AllTrim(F5Q->F5Q_A1COD))
	@see (links_or_references)
	/*/
Function RU69XFNE1F()
Return IIF(!Empty(M->E1_CLIENTE) .AND. !Empty(M->E1_LOJA), "@F5Q_STATUS = '1' AND F5Q_A1COD = '"+M->E1_CLIENTE+"' AND F5Q_A1LOJ = '"+M->E1_LOJA+"' ","@1 = 1 ")

                   
//Merge Russia R14 
                   
