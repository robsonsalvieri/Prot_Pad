#INCLUDE "PROTHEUS.CH"    
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RU06XFUN.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE _RECSEx 		1
#DEFINE _BAIXAS 		2
#DEFINE _SALDO  		3
#DEFINE _MARCADO		"LBTIK"
#DEFINE _DESMARCADO		"LBNO"
#DEFINE _PRETO   		"BR_PRETO"
#DEFINE _AMARELO    	"BR_AMARELO"
#DEFINE _AZUL       	"BR_AZUL"

Static __cRuPrf 		:='' // used for filters  FINXFIN02_FILFilter(),  Function FINXFIN01_BCOFilter()
/*/
{Protheus.doc} RU06XFUN01_CleanFlds()
Function to load empty values to the list of character fields
if lRelacao is .T., fields in aFields will be initialized by
functions located in x3_relacao
@author natalia.khozyainova
@since 12/11/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06XFUN01_CleanFlds(aFields as Array, lRelacao As Logical)
Local nX     As Numeric
Local bBlock As Block
Local cRunFn As Character
Local xVal

Default lRelacao := .F.

If ValType(aFields)=='A' 
    For nX:=1 to Len(aFields)
        If !lRelacao .OR. Empty(GetSX3Cache(aFields[nX],"X3_RELACAO"))
            If     GetSX3Cache(aFields[nX],"X3_TIPO") == "C"
                FwFldPut(aFields[nX],"",,,,.T.)
            ElseIf GetSX3Cache(aFields[nX],"X3_TIPO") == "N"
                FwFldPut(aFields[nX],0,,,,.T.)
            ElseIf GetSX3Cache(aFields[nX],"X3_TIPO") == "M"
                FwFldPut(aFields[nX],"",,,,.T.)
            ElseIf GetSX3Cache(aFields[nX],"X3_TIPO") == "D"
                FwFldPut(aFields[nX],STOD(".."),,,,.T.)
            EndIf
        Else
            cRunFn := AllTrim(GetSX3Cache(aFields[nX],"X3_RELACAO"))
            bBlock := &("{|| "+ cRunFn + " }")
            xVal := Eval(bBlock)
            FwFldPut(aFields[nX],xVal,,,,.T.)
        EndIf
    Next nX    
EndIf
Return (Nil)

/*/
{Protheus.doc} RU06XFUN02_ShwFIL()
a query to FIL table which returns FIL->FIL_TIPO value if nNum=1 
or FIL->FIL_ACNAME value if nNum=2.
If nNum == 0 will be returnd array with next data:
{"type of account", "bank name", "account name", "supplier's name"}
called for initialisation of fields F47_, F49_, F4C_... TYPCC, BKRNAM
@param    Numeric        nNum     //1, 2, 0
          Character      cSupp    //Supplier
          Character      cUnit    //Unit
          Character      cBnk
          Character      cBIK
          Character      cAcc
@return   Variant        xRet     //If nNum == 0, will be returned array of values:
                                    {"_TYPCC","_BKNAME","_ACNAME", "_RECNAM"}, so
                                    this array can be extended in future. 
                                    If nNum == 1 returns TMPFIL->FIL_TIPO   (_TYPCC )
                                    If nNum == 2 returns TMPFIL->FIL_ACNAME (_ACNAME)
nothing found in FIL -> Empty string or array with empty strings will be returned
@author natalia.khozyainova
@since 12/11/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06XFUN02_ShwFIL(nNum as Numeric  , cSupp as Character, cUnit as Character,;
                           cBnk as Character, cBIK  as Character, cAcc  as Character )

    Local     cRet      As Character
    Local     cAlias    As Character
    Local     aArea     As Array
    Local     aRet      As Array
    Local     xRet
    Default   nNum := 1

    cRet := ""
    cAlias := RU06XFUN40_RetBankAccountDataFromFIL(cSupp,cUnit,Nil,cBnk,cBIK,cAcc,.T.)
    aArea  := GetArea()
    DbSelectArea(cAlias)
    DbGoTop()
    If !EoF()
        If     nNum == 1 // account type
            cRet := (cAlias)->(_TYPCC)
        ElseIf nNum == 2 // account name
            cRet := (cAlias)->(_ACNAME)
        ElseIf nNum == 0
            aRet := {(cAlias)->_TYPCC ,;
                     (cAlias)->_BKNAME,;
                     (cAlias)->_ACNAME,;
                     (cAlias)->_RECNAM }
        EndIf
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    xRet := IIf(nNum == 0, aRet, cRet)

Return (xRet)


/*/
{Protheus.doc} RU06XFUN03_ShwSA6()
@param  Numeric     nNum    //1, 2, 0
        Character   cBnk    //bank code
        Character   cBIK    //BIC
        Character   cAcc    //Account
@return Variant     xRet    // in case nNum == 0:
will be returnd array with next data {"type of account", "bank name",
"account name", "reciever's or payer's name"} , so this array can be
extended in future.
                            // in case nNum != 0:  
                            if nNum == 1, -> A6_NOME   //bank name
                            if nNum == 2, -> A6_ACNAME //account name
nothing found in SA6 -> Empty string or array with empty strings 
@author natalia.khozyainova
@since 21/11/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06XFUN03_ShwSA6(nNum as Numeric  , cBnk as Character,;
                           cBIK as Character, cAcc as Character )

    Local       aArea       As Array
    Local       aRet        As Array
    Local       cAlias      As Character
    Local       cRet        As Character
    Local       xRet
    Default     nNum := 1
    cRet   := ""
    cAlias := RU06XFUN39_RetBankAccountDataFromSA6(cBnk, cBIK, cAcc, Nil, .T.)
    aArea  := GetArea()
    DBSelectArea(cAlias)
    DbGoTop()
    If !Eof()
        If     nNum == 1
            cRet := (cAlias)->_BKPNAM
        ElseIf nNum == 2
            cRet := (cAlias)->_ACPNAM
        ElseIf nNum == 0 
            aRet := {(cAlias)->_TYPCP ,;
                     (cAlias)->_BKPNAM,;
                     (cAlias)->_ACPNAM,;
                     (cAlias)->_PAYNAM }
        EndIf
    EndIF
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    xRet := IIf(nNum == 0, aRet, cRet)

Return (xRet)

/*/
{Protheus.doc} RU06XFUN04_VldFIL()
@author natalia.khozyainova
@since 21/11/2018
@version 1.0
@project MA3 - Russia
This function validates bank account information located in FIL table and 
fills fields passed through aFlds array
How it works: Function recives several parameters: cCurr (Currency code), cBnk(Bank code), 
cBIK(Bank BIK or BIC), cAccount (Account number) and tries to find bank account information in FIL table 
using these parameters. If cAcc is Empty, or other parameter is Empty, it will be excluded from 
sql query, so sql query can return to us zero or several lines. SQl query located in 
RU06XFUN40_RetBankAccountDataFromFIL function.
cSupp (Supplier's code) and cUnit (supplier's loja) are obligatory, so if they are empty in normal case
will be returned .F.
If cAcc is not empty, all parameters will be included in sql query - so, in normal case we should recieve
by sql query one or zero lines, if it is zero - it means no bank account information (lRet == .F.)
Alse you can use lForce( default: false) parameter setting it to .T.. If lForce is .T., doesn't matter
empty or not empty is cAcc parameter, all parameters will be included to SQL query
If lForce is .T. or cAcc is not empty, bank account information will be putted to fields in aFlds array.
Rule for aFlds items: For example aFlds[1] == "XXX_PAYBIK", if query result contains field "_PAYBIK", so
value of _PAYBIK will be putted in XXX_PAYBIK.
If lExClsd we exclude from result closed bank accounts.
/*/
Function RU06XFUN04_VldFIL(cSupp as Character, cUnit as Character, cCurr as Character, cBnk   as Character,;
                           cBIK  as Character, cAcc  as Character, aFlds as Array,     lForce as Logical  ,;
                           lExClsd as Logical                                                              )
    Local lRet        As Logical
    Local lFull       As Logical
    Local nMoeda      As Numeric
    Local nX          As Numeric
    Local nY          As Numeric
    Local cAlias      As Character
    Local cFieldName  As Character
    Local aSaveArea   As Array
    Local xFldVal
    Default lForce    := .F.
    Default lExClsd   := .F.

    nMoeda := IIF(ValType(cCurr) == "C" .AND. !Empty(cCurr), Val(cCurr), 0)
    lRet := .T.
    aSaveArea  := GetArea()
    lFull      := !Empty(cAcc) .OR. lForce
    If lRet
        cAlias := RU06XFUN40_RetBankAccountDataFromFIL(cSupp, cUnit, nMoeda, cBnk, cBik, cAcc,;
                                                       lFull, .T./*left join F45*/, lExClsd)
        DBSelectArea(cAlias)
        DBGoTop()
        If !Eof() // bank account was found
            If !Empty(aFlds) .AND. lFull            //fill fields from aFlds when  
                For nX := 1 To (cAlias)->(FCOUNT()) //we already have account info in FIL
                    cFieldName := AllTrim((cAlias)->(FIELD(nX)))
                    For nY := 1 To Len(aFlds)
                        If  cFieldName $ aFlds[nY]
                            xFldVal := (cAlias)->(FieldGet(nX))
                            xFldVal := IIf(ValType(xFldVal) == "C", AllTrim(xFldVal),xFldVal)
                            FwFldPut(aFlds[nY],xFldVal,,,.T.,.T.) 
                        EndIf 
                    Next nY
                Next nX
            EndIf
        Else
            lRet := .F. // no bank account
        EndIf
        (cAlias)->(DBCloseArea())
    EndIf
    RestArea(aSaveArea)

Return (lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN41_VldF4N

Function can be used for validation customer's bank account info and 
filling fields passed through aFlds array if it is not empty

How it works: Function recives several parameters: cCurr (Currency code), cBnk(Bank code), 
cBIK(Bank BIK or BIC), cAccount (Account number) and tries to find bank account information 
in F4N table using these parameters. If cAcc is Empty, or other parameter is Empty, it will 
be excluded from sql query, so sql query can return to us zero or several lines. 
SQl query located in RU06XFUN42_RetBankAccountDataFromF4N function. 
cCust (Customer's code) and cUnit (customer's loja) are obligatory, so if they are empty 
in normal case will be returned .F.
If cAcc is not empty, all parameters will be included in sql query - so, in normal case 
we should recieve by sql query one or zero lines, if it is zero - it means no bank account 
information (lRet == .F.).
Alse you can use lForce( default: false) parameter setting it to .T.. 
If lForce is .T., doesn't matter empty or not empty is cAcc parameter, all parameters will 
be included to SQL query.
If lForce is .T. or cAcc is not empty, bank account information will be putted to 
fields located in aFlds array. Rule for aFlds items: For example aFlds[1] == "XXX_PAYBIK", 
if query result contains field "_PAYBIK", so value of _PAYBIK will be putted in XXX_PAYBIK.

@param       Character          cCust       // Customer's code ->F4N_CLIENT
             Character          cUnit       // Customer's loja ->F4N_LOJA
             Character          cBnk        // Customer's bank code ->F4N->BANK
             Character          cBIK        // BIK ->F4N_BIK
             Character          cAcc        // Account number ->F4N_ACC
             Array              aField      // array of fields should be updated, not obrig
             Logical            lForce      // if .T. - all parmeters will be included to
                                            // sql query, .F. - nonempty parameters will
                                            // be included(default)          
@return      Logical            lRet        // .T. - ok, validated
@example     
@author      astepanov
@since       July/03/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN41_VldF4N(cCust As Character, cUnit  As Character, cCurr as Character,;
                           cBnk  As Character, cBIK   As Character, cAcc  as Character,;
                           aFlds As Array    , lForce As Logical                       )

    Local lRet       As Logical
    Local lFull      As Logical
    Local aSaveArea  As Array
    Local cAlias     As Character
    Local cFieldName As Character
    Local nX         As Numeric
    Local nY         As Numeric
    Local xFldVal
    Default lForce   := .F. 

    lRet := .T.
    aSaveArea  := GetArea()
    lFull      := !Empty(cAcc) .OR. lForce
    If lRet
        cAlias := RU06XFUN42_RetBankAccountDataFromF4N(cCust, cUnit, cCurr, cBnk, cBIK,;
                                                       cAcc, lFull)
        DBSelectArea(cAlias)
        DBGoTop()
        If !Eof() // bank account was found
            If !Empty(aFlds) .AND. lFull            //fill fields from aFlds when  
                For nX := 1 To (cAlias)->(FCOUNT()) //we already have account info in F4N
                    cFieldName := AllTrim((cAlias)->(FIELD(nX)))
                    For nY := 1 To Len(aFlds)
                        If  cFieldName $ aFlds[nY]
                            xFldVal := (cAlias)->(FieldGet(nX))
                            xFldVal := IIf(ValType(xFldVal)=="C",AllTrim(xFldVal),xFldVal)
                            FwFldPut(aFlds[nY],xFldVal,,,.T.,.T.) 
                        EndIf 
                    Next nY
                Next nX
            EndIf
        Else
            lRet := .F. // no bank account
        EndIf
        (cAlias)->(DBCloseArea())
    EndIf
    RestArea(aSaveArea)
    
Return (lRet) /*---------------------------------------------------------RU06XFUN41_VldF4N*/


/*/{Protheus.doc} RU06XFUN05_VldSA6
SA6 Fields validation 
@author natalia.khozyainova
@since 25/11/2018
@version 1.0
@project MA3 - Russia
This function validates bank account information and 
fills fields passed through aFlds array
cCurr is optional
How it works: Function recives several parameters: cCurr (Currency code),
cBnk(Bank code), cBIK(Bank BIK or BIC),
cAccount (Account number)  and tries to find bank account information in SA6 table using these parameters.
If cAcc is Empty, or other parameter is Empty, it will be excluded from sql query, so sql query can return
to us zero or several lines. SQl query located in RU06XFUN39_RetBankAccountDataFromSA6 function.
If cAcc is not empty, all parameters will be included in sql query - so, in normal case we should recieve
by sql query one or zero lines, if it is zero - it means no bank account information.
Alse you can use lForce( default: false) parameter setting it to .T.. If lForce is .T., doesn't matter
empty or not empty is cAcc parameter, all parameters will be included to SQL query
If lForce is .T. or cAcc is not empty, bank account information will be putted to fields in aFlds array.
Rule for aFlds items: For example aFlds[1] == "XXX_BKRNAM", if query result contains field "_BKRNAM", so
value of _BKRNAM will be putted in XXX_BKRNAM.
/*/
Function RU06XFUN05_VldSA6(cCurr as Character, cBnk as Character, cBIK as Character, cAcc as Character, aFlds as Array,;
                           lForce As Logical)

    Local lRet        As Logical
    Local lFull       As Logical
    Local nMoeda      As Numeric
    Local nX          As Numeric
    Local nY          As Numeric
    Local cAlias      As Character
    Local cFieldName  As Character
    Local aSaveArea   As Array
    Local xFldVal

    Default lForce    := .F. 

    nMoeda := IIF(ValType(cCurr) == "C" .AND. !Empty(cCurr), Val(cCurr), 0)
    lRet := .T.
    aSaveArea  := GetArea()
    lFull      := !Empty(cAcc) .OR. lForce
    If lRet
        cAlias := RU06XFUN39_RetBankAccountDataFromSA6(cBnk, cBIK, cAcc, nMoeda, lFull)
        DBSelectArea(cAlias)
        DBGoTop()
        If !Eof() // bank account was found
            If !Empty(aFlds) .AND. lFull            //fill fields from aFlds when  
                For nX := 1 To (cAlias)->(FCOUNT()) //we already have all account info in SA6
                    cFieldName := AllTrim((cAlias)->(FIELD(nX)))
                    For nY := 1 To Len(aFlds)
                        If  cFieldName $ aFlds[nY]
                            If nMoeda == 0 .AND. cFieldName == "_CURREN"
                                FwFldPut(aFlds[nY],;
                                        PADL(AllTrim(STR((cAlias)->(FieldGet(nX)))),;
                                        GetSX3Cache(aFlds[nY],"X3_TAMANHO"),"0"   );
                                        ,,,.T.,.T.)
                                RunTrigger(1,Nil,Nil,,"F60_CURREN")
                            ElseIf nMoeda != 0 .AND. cFieldName == "_CURREN"
                                xFldVal := (cAlias)->(FieldGet(nX))
                                xFldVal := PADL(AllTrim(STR(xFldVal)), GetSX3Cache(aFlds[nY],"X3_TAMANHO"),"0"   )
                                FwFldPut(aFlds[nY],xFldVal,,,.T.,.T.)
                            Else
                                xFldVal := (cAlias)->(FieldGet(nX))
                                xFldVal := IIf(ValType(xFldVal) == "C",AllTrim(xFldVal),xFldVal)
                                FwFldPut(aFlds[nY],xFldVal,,,.T.,.T.)
                            EndIf   
                        EndIf 
                    Next nY
                Next nX
            EndIf
        Else
            lRet := .F. // no bank account
        EndIf
        (cAlias)->(DBCloseArea())
    EndIf
    RestArea(aSaveArea)

Return (lRet)

/*/{Protheus.doc} RU06XFUN06_GetOpenBalance
Function Used to restore the Open balance of the accounts payable 
Subtracting all the values that is already used in any Bank Statement Process.
@author natalia.khozyainova
@since 27/11/2018
@version 1.1
@edit   astepanov 11 July 2019
@Parameter 
cSe2Key: String with key Fields of SE2 used to find the Specified Register
in the format: E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_FORNECE|E2_LOJA
@Return
nOpBal: Numeric with the Value considering the E2_SALDO- SUM(F5M_VALPAY) to the related cSe2Key
@project MA3 - Russia
/*/
Function RU06XFUN06_GetOpenBalance(cSe2Key,cTable)

    Local nOpBal    As Numeric
    Local cQuery    As Character
    Local cAlias    As Character
    Local aSaveArea As Array

    Default cTable:="SE2"

    aSaveArea := GetArea()
    cQuery:= RU06XFUN55_QuerryF5MBalance(cSe2Key,cTable) // set the querry 
    cAlias := MPSysOpenQuery(cQuery)
    DBSelectArea(cAlias)
    DBGoTop()
    If !Eof()
        nOpBal := (cAlias)->SALDO - (cAlias)->TOTAL
    Else
        nOpBal := 0
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aSaveArea)

Return (nOpBal)


/*/{Protheus.doc} RU06XFUN07_WrToF5
Function to write a line in F5M table at the moment of ebtries in Payment Request, Payment Order or Bank Statement Creation/Edition/Deletion
@author natalia.khozyainova
@since 28/11/2018
@version 1.0
@Parameter 
cIdDoc: Unique ID of Document F47_IDF47, F48_UUID, F49_IDF49, F4B_UUID, F4C_CUUID
cAlias: Name of a tabel: F47, F48, F49, F4B, F4C
cKeyF5M: format is E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_FORNRCE|E2_LOJA with the spaces
nValue: line amount to pay
cCtrlBal: 1 or 2. 1 means line participates on Open balance calculation
nOper: Operation to perform on F5M, can be 1 or 2. 1 means - update or create line, 2 menas - delete line
cFil: Filial
lCtrBalOnl : update only F5M_CTRBAL, so it have senese when nOper == 1 , and we have F5M record for update,
             Default  - .F.
nVALCNV -> F5M_VALCNV
nBSVATC -> F5M_BSVATC
nVLVATC -> F5M_VLVATC
@Return
nil
@project MA3 - Russia
/*/
Function RU06XFUN07_WrToF5(cIdDoc  as Character, cAlias     as Character, cKeyF5M as Character,;
                           nValue  as Numeric  , cCtrlBal   as Character, nOper   as Numeric  ,;
                           cFil    as Character, lCtrBalOnl as Logical  , nVALCNV as Numeric  ,;
                           nBSVATC as Numeric  , nVLVATC    as Numeric                         )
// nOper==1 is update or create, nOper==2 is deletion
Local aSaveArea as Array
Local lOk       as Logical
Default cFil:=xFilial("F5M")
Default cIdDoc:=""
Default cAlias:=""
Default cKeyF5M:=""
Default nValue:=0
Default cCtrlBal:="2"
Default nOper:=0
Default lCtrBalOnl := .F.
Default nVALCNV := 0
Default nBSVATC := 0
Default nVLVATC := 0

aSaveArea:=GetArea()
lOk      := .T.

If nOper==1 .and. !Empty(cIdDoc) .and. !(Empty(cKeyF5M) .and. cCtrlBal=="1")
    DBSELECTAREA("F5M")
    DBSETORDER(1)
    If !lCtrBalOnl
        If DBSEEK(cFil+cAlias+cIdDoc+cKeyF5M )
            lOk := RECLOCK("F5M",.F.)
        Else
            lOk := RECLOCK("F5M",.T.)
        EndIf
        If lOk
            F5M->F5M_FILIAL:=cFil
            F5M->F5M_IDDOC:=cIdDoc
            F5M->F5M_ALIAS:=cAlias
            F5M->F5M_VALPAY:=nValue
            F5M->F5M_CTRBAL:=cCtrlBal
            F5M->F5M_KEY:=cKeyF5M
            F5M->F5M_VALCNV := nVALCNV
            F5M->F5M_BSVATC := nBSVATC
            F5M->F5M_VLVATC := nVLVATC
            MSUNLOCK()
        EndIf
    Else //just update F5M_CTRBAL
        If DBSEEK(cFil+cAlias+cIdDoc+cKeyF5M )
            If RECLOCK("F5M",.F.)
                F5M->F5M_CTRBAL:=cCtrlBal
                MSUNLOCK()
            Else
                lOk := .F.
            EndIf
        EndIf
    EndIf
ElseIf nOper==2 .and. !Empty(cIdDoc)
    DBSELECTAREA("F5M")
    DBSETORDER(1)
    If DBSEEK(cFil+cAlias+cIdDoc+cKeyF5M )
        If RECLOCK("F5M")
            DBDELETE()
            MSUNLOCK()
        Else
            lOk := .F.
        EndIf
    EndIf
EndIf

Return (lOk)

/*/{Protheus.doc} RU06XFUN08_SetOpenBalance
Function Used to Set the Locked balance of the accounts payable related to the bank statement process.
@author natalia.khozyainova
@since 28/11/2018
@version 1.0
@Parameter 
cNewUuid : Mandatory. UUID related to the new register in table F5M. Will be the content of the field F5M_IDDOC (to add)
cNewAlias: Mandatory. Alias related to the new register in table F5M. Will be the content of the field F5M_ALIAS (to add)
nValPay  : Mandatory. Value related to the new register in table F5M. Will be the content of the field F5M_VALPAY (to add) 
cCtrBal  : Optional. Flag if this settlement control balance 
1-Control Ballance 	
2-don`t control Ballance (default)	
cSe2Key  : Optional. Key Fields of SE2 used to link the Specified Register with an account payable when this link exists (to add and for search) 
Format: E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_FORNECE|E2_LOJA with spaces
cOldUuid : Optional. UUID related to the old register in table F5M that we need to delete (for search nd to delete)
cOldAlias: Optional. Alias related to the old register in table F5M that we need to delete (for search and to delete)
@Return
lReturn: Logic return showing if all the process occurs ok
@project MA3 - Russia
/*/
Function RU06XFUN08_SetOpenBalance(cNewUuid as Character, cNewAlias as Character, nValPay as Numeric, cCtrBal as Character, cSe2Key as Character, cOldUuid as Character, cOldAlias as Character)
Local lRet as Logical
Default cNewUuid:=""
Default cNewAlias:=""
Default cSe2Key:=""
Default nValPay:=0
Default cCtrBal:="2"
Default cOldUuid:=""
Default cOldAlias:=""
lRet:=.F.
If !Empty(cOldUuid) .and. !Empty(cOldAlias)
    RU06XFUN07_WrToF5(cOldUuid, cOldAlias, cSe2Key, , , 2)// delete if old line exists
    RU06XFUN07_WrToF5(cNewUuid, cNewAlias, cSe2Key, nValPay, cCtrBal, 1)
    lRet:=.T.
EndIf
Return (lRet) 

/*/{Protheus.doc} RU06XFUN09_RetSE2F5MJoinOnString
Function returns string to join part of sql query
when we try join SE2 line to F5M line, because F5M_KEY field
constructs from: E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_LOJA ... so on
So, we don't use RPAD (Transact-SLQ doesn't support it), we use TRIM and
SUBSTRING which can be easly converted to SUBSTR for Oracle DBMS.
@author natalia.khozyainova
@since 28/11/2018
@version 1.3
@edit astepanov 16 July 2019
@param   Character        cFMTN       // F5M table alias name
@edit avelmozhnya 29 January 2020
@param   Logical          lInflow       // Bank Statment direction
@return  Character        cJoinLn   
@project MA3 - Russia
/*/
Function RU06XFUN09_RetSE2F5MJoinOnString(cFM5TNA As Character, lInflow as Logical)

    Local cJoinLn    As Character
    Local cTabName   As Character
    Local cFS, cFE, cPS, cPE, cNS, cNE, cRS, cRE, cTS As Character
    Local cTE, cCS, cCE, cLS, cLE                     As Character
    Local aKs        As Array
    Default cFM5TNA  := "F5M"
    Default lInflow := .F.

    aKs := RU06XFUN44_RetSE2FldsPosInFMKey(lInflow)
    cFS := aKs[1][2]
    cFE := aKs[1][3]
    cPS := aKs[2][2]
    cPE := aKs[2][3]
    cNS := aKs[3][2]
    cNE := aKs[3][3]
    cRS := aKs[4][2]
    cRE := aKs[4][3]
    cTS := aKs[5][2]
    cTE := aKs[5][3]
    cCS := aKs[6][2]
    cCE := aKs[6][3]
    cLS := aKs[7][2]
    cLE := aKs[7][3]

    cTabName := Iif(lInflow,"SE1.E1","SE2.E2")
    
    cJoinLn := " TRIM("+cTabName+"_FILIAL)  = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cFS+","+cFE+")) AND "
    cJoinLn += " TRIM("+cTabName+"_PREFIXO) = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cPS+","+cPE+")) AND "
    cJoinLn += " TRIM("+cTabName+"_NUM)     = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cNS+","+cNE+")) AND "
    cJoinLn += " TRIM("+cTabName+"_PARCELA) = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cRS+","+cRE+")) AND "
    cJoinLn += " TRIM("+cTabName+"_TIPO)    = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cTS+","+cTE+")) AND "
    cJoinLn += " TRIM("+cTabName+Iif(lInflow,"_CLIENTE)","_FORNECE)")+" = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cCS+","+cCE+")) AND "
    cJoinLn += " TRIM("+cTabName+"_LOJA)    = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cLS+","+cLE+"))     "
   
Return(cJoinLn)

/*/{Protheus.doc} RU06XFUN10_PickUpAPs
This function has inside the Group of Questions for picking up Accounts Payables (items to F48) and
the window with markbrowse
@author natalia.khozyainova
@since 11/12/2018
@version 2.0
@project MA3 - Russia
/*/
Function RU06XFUN10_PickUpAPs(cHeadAlias AS Character, lInflow as Logical)
Local cPerg       as Character
Local cProgName   as Character
Local cHeadModel  as Character
Local lRet        as Logical
Local lInAdvance  as Logical
Local oModel      as Object

Default lInflow := .F.

Do Case
    Case cHeadAlias == 'F47'
        cProgName := 'RU06D04'
        lInAdvance := FwFldGet(cHeadAlias + "_PREPAY") != '1'
    Case cHeadAlias == 'F49'
        cProgName := 'RU06D06'
        lInAdvance := FwFldGet(cHeadAlias + "_PREPAY") != '1'
    Case cHeadAlias == 'F4C'
        cProgName := 'RU06D07'
        lInAdvance := FwFldGet(cHeadAlias + "_ADVANC") != '1'
EndCase

If cProgName = "RU06D06"
    cHeadModel := "RU06D05_MF49"
Else
    cHeadModel := cProgName + "_MHEAD"
EndIf
If lInAdvance // if not prepayment
    If IIf(lInflow,Empty(FwFldGet(cHeadAlias + "_CUST")),Empty(FwFldGet(cHeadAlias + "_SUPP")) )
        If lInflow
            Help("",1,STR0060,,STR0058,1,0,,,,,,{STR0059}) //Client data -- Client is not selected -- Select Client
        Else
            Help("",1,STR0001,,STR0030,1,0,,,,,,{STR0031}) //Supplier data -- Supplier is not selected -- Select supplier
        EndIf
    ElseIf  IIf(lInflow,;
            !(ExistCpo("SA1",FwFldGet(cHeadAlias + "_CUST") + FwFldGet(cHeadAlias + "_CUNI"))),; // something is wrong with client code/unit
            !(ExistCpo("SA2",FwFldGet(cHeadAlias + "_SUPP") + FwFldGet(cHeadAlias + "_UNIT")))) // something is wrong with supplier code/unit
            If lInflow
                Help("",1,STR0060,,STR0061,1,0,,,,,,{STR0062}) // Client data -- Client Code and Unit not valid -- Change Client data
            Else
                Help("",1,STR0001,,STR0002,1,0,,,,,,{STR0003}) // Supplier data -- Supplier Code and Unit not valid -- Change supplier data
            EndIf
    ElseIf lInflow .And. Vazio(FwFldGet(cHeadAlias + "_VALUE") )
        Help("",1,STR0020,,STR0063,1,0,,,,,,{STR0064}) // Balance -- Operation is unavailable -- Fill in the amount field
    Else
        oModel:= FWModelActive()
        cPerg := "RUD604" 
        // Update initial Ranges in Group of Questions:
        If Empty(FwFldGet(cHeadAlias+"_CURREN"))
            // in case when user has 'last values' from pergunta stored in system table
            SetMVValue(cPerg,"MV_PAR09",Replicate(" ",TamSX3(cHeadAlias + "_CURREN")[1]))
            SetMVValue(cPerg,"MV_PAR10",Replicate("Z",TamSX3(cHeadAlias + "_CURREN")[1]))
        Else
            // in case when user has 'last values' from pergunta stored in system table
            SetMVValue(cPerg,"MV_PAR09", oModel:GetValue(cHeadModel,cHeadAlias + '_CURREN'))
            SetMVValue(cPerg,"MV_PAR10", oModel:GetValue(cHeadModel,cHeadAlias + '_CURREN'))
        Endif

        If Empty(FwFldGet(cHeadAlias + "_CNT"))
            // in case when user has 'last values' from pergunta stored in system table
            SetMVValue(cPerg,"MV_PAR07",Replicate(" ",TamSX3(cHeadAlias + "_CNT")[1]))
            SetMVValue(cPerg,"MV_PAR08",Replicate("Z",TamSX3(cHeadAlias + "_CNT")[1]))
        Else
            // in case when user has 'last values' from pergunta stored in system table
            SetMVValue(cPerg,"MV_PAR07",oModel:GetValue(cHeadModel,cHeadAlias + '_CNT'))
            SetMVValue(cPerg,"MV_PAR08",oModel:GetValue(cHeadModel,cHeadAlias + '_CNT'))
        Endif
        
        lRet:= Pergunte(cPerg,.T.,IIf(lInflow,STR0065,STR0004),.F.) // Pick Up APs

        If lRet
            RU06XFUN12_MBRW(cHeadAlias, cProgName, lInflow) // MarkBrowse is here
        Endif
    EndIf
Else
    Help("",1,IIf(lInflow,STR0065,STR0004),,IIf(lInflow,STR0066,STR0005),1,0,,,,,,{STR0006}) // Pick Up APs -- Not allowed APs in Prepayment - Change type to add bills 
EndIf
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN12_MBRW
This function will create and process the markbrowse window 
where we choose Bils for Payment Request
@author natalia.khozyainova
@since 11/12/2018
@version 3.0
@edit   astepanov 12 July 2019
@project MA3 - Russia
/*/
Function RU06XFUN12_MBRW(cHeadAlias as Character, cProgName as Character, lInflow as Logical)
    Local aSize        As Array
    Local aColumns     As Array
    Local aFields      As Array
    Local aInp         As Array
    Local aForView     As Array
    Local aArea        As Array
    Local nX           As Numeric
    Local nY           As Numeric
    Local nZ           As Numeric
    Local cErrMsg      As Character
    Local cFldOK       As Character

    Private oMoreDlg   As Object
    Private oBrowsePut As Object
    Private oTempTable As Object
    Private cTempTbl   As Character
    Private cMark      As Character

    Default lInflow := .F.

    aArea := GetArea()
    // Create temporary table
    // "Please wait"  "Creating temporary table"
    MsgRun(STR0007,STR0008,{|| aInp := RU06XFUN15_MyCreaTRB(cHeadAlias, cProgName, lInflow)})
    // aInp == {FWtemporaryTable, aFields, cErrMsg}
    oTempTable := aInp[1]
    aFields    := aInp[2]
    cErrMsg    := aInp[3]
    If Empty(cErrMsg)
        cTempTbl   := oTempTable:GetAlias()
        DBSelectArea(cTempTbl)
        DBGoTop()
        If !((cTempTbl)->(Eof()))
            aColumns 	:= {}
            If lInflow
                 aForView    := {"E1_PREFIXO", "E1_F5QCODE","E1_NUM"    ,;
                                "E1_PARCELA", "E1_TIPO"   , "E1_EMISSAO",;
                                "E1_VENCREA", "CTO_MOEDA" , "E1_CONUNI" ,;
                                "E1_VALOR"  , "E1_BALANCE"               }
            Else
                aForView    := {"E2_PREFIXO", "E2_F5QCODE", "E2_NUM"    ,;
                                "E2_PARCELA", "E2_TIPO"   , "E2_EMISSAO",;
                                "E2_VENCREA", "CTO_MOEDA" , "E2_CONUNI" ,;
                                "E2_VALOR"  , "E2_BALANCE"               }
            EndIf
            For nX := 1 To  Len(aForView)
                For nY := 1 To Len(aFields)
                    If AllTrim(aForView[nX]) == AllTrim(aFields[nY][1])
                        AADD(aColumns, FWBrwColumn():New())
                        nZ := Len(aColumns)
                        aColumns[nZ]:SetData(&("{||"+aFields[nY][1]+"}"))
                        aColumns[nZ]:SetTitle(aFields[nY][6]  ) 
                        aColumns[nZ]:SetSize(aFields[nY][3]   )
                        aColumns[nZ]:SetDecimal(aFields[nY][4])
                        aColumns[nZ]:SetPicture(aFields[nY][5])
                        If aFields[nY][2] == "N" // https://jiraproducao.totvs.com.br/browse/RULOC-369
                            aColumns[nZ]:SetAlign(2) // 0-center, 1-left, 2-right
                        EndIf
                    EndIf
                Next nY
            Next nX
            aSize	 := MsAdvSize()
            oMoreDlg := MsDialog():New( aSize[7], aSize[2], aSize[6], aSize[5],;
                                        STR0021, , , , , CLR_BLACK, CLR_WHITE,;
                                        , , .T., , , , .T.                     )
            oBrowsePut := FWMarkBrowse():New()
            cFldOK := IIf(lInflow,"E1_OK","E2_OK")
            oBrowsePut:SetFieldMark(cFldOK)
            oBrowsePut:SetOwner(oMoreDlg)
            oBrowsePut:SetAlias(cTempTbl)
            oBrowsePut:SetMenuDef("")
            oBrowsePut:SetColumns(aColumns)
            oBrowsePut:bAllMark := {||RU06XFUN16_MarkAll(oBrowsePut,cTempTbl,cFldOK)}
            oBrowsePut:DisableReport()
            oBrowsePut:SetIgnoreARotina(.T.)
            oBrowsePut:AddButton(STR0012, {||RU06XFUN13_CloseMBrowse()},0, 1)   //Cancel
            Do Case 
                Case cProgName == "RU06D04"     //Payment Request
                    oBrowsePut:AddButton(STR0011, {||RU06D04WR(oTempTable, oMoreDlg, cMark)},0, 3) //Add
                    oBrowsePut:AddButton(STR0013, {||R0604ShwBl()},0, 1)                //Show Bill Details 
                Case cProgName == "RU06D06"     //Payment Orders without payment requsts
                    oBrowsePut:AddButton(STR0011, {||RU06D06001_AddBills(oTempTable, oMoreDlg, cMark)},0, 3) //Add
                    oBrowsePut:AddButton(STR0013, {||R0604ShwBl()},0, 1)                                     //Show Bill Details 
                Case cProgName == "RU06D07"    //Bank Statement
                    oBrowsePut:AddButton(STR0011, {||RU06D0722_WriteFromMBr(oTempTable, oMoreDlg, cMark)},0, 3)   //Add          
                    If lInflow
                        oBrowsePut:AddButton(STR0013, {||RU06D07011_ShowInflowBill()},0, 1) //Show Bill Details
                        oBrowsePut:AddButton(STR0067, {||RU06XFUN14_AddByRules("FIFO",oTempTable, oMoreDlg, cMark, oBrowsePut)},0, 8) //"Add FIFO"
                        oBrowsePut:AddButton(STR0068, {||RU06XFUN14_AddByRules("EXACT",oTempTable, oMoreDlg, cMark, oBrowsePut)},0, 8) //"Add Exact Value"
                    Else
                        oBrowsePut:AddButton(STR0011, {||RU06D0722_WriteFromMBr(oTempTable, oMoreDlg, cMark)},0, 3)   //Add
                        oBrowsePut:AddButton(STR0013, {||R0604ShwBl()},0, 1)                  //Show Bill Details  
                    EndIf
            EndCase
            
            oBrowsePut:Activate()
            cMark := oBrowsePut:Mark()
            oMoreDlg:Activate(,,,.T.,,,)
            (cTempTbl)->(DBCloseArea())
            oTempTable:Delete()
        Else
            Help("",1,STR0009,,STR0010,; //No bills found, Change Group of Questions
                 1,0,,,,,,/*{'solution'}*/) 
        EndIf
    Else
        Help("",1,"TSQLError()",,cErrMsg,;
             1,0,,,,,,/*{'solution'}*/) // Error during sql query execution
    EndIf
    RestArea(aArea)

Return (.T.)

/*/{Protheus.doc} RU06XFUN13_CloseMBrowse
Cancel Button - close window
@param	oModel	
@author natalia.khozyainova
@since 11/12/2018
@version 2.0
@type function
@project	MA3
/*/
Function RU06XFUN13_CloseMBrowse()
oMoreDlg:End()
Return (.F.)

/*/{Protheus.doc} RU06XFUN14_AddByRules
Function for adding Biils according specific rules (FIFO, EXACT Value)
@author eduardo.flima
@edit   alexandra.velmozhnaia
        20/03/2020
@since 18/03/2020
@version 2.0
@type function
@project	MA3
/*/
Function RU06XFUN14_AddByRules(cRule, oTempTable, oMoreDlg, cMark, oBrowsePut)
Local lRet       as Logical
Local nDifVlpay  as Numeric
Local aTotals    as Array
Local oModel     as Object
Local oModelF4C  as Object
Local oModelVrt  as Object

Default cRule := "FIFO"
Do Case 
    Case cRule == "FIFO"
        lRet := RU06D07014_AddFIFO(@oTempTable, @oMoreDlg, @cMark, @oBrowsePut)
    Case cRule == "EXACT"
        lRet:=  RU06D07015_AddExactValue(@oTempTable, @oMoreDlg, @cMark, @oBrowsePut)
EndCase
If lRet
    RU06D0722_WriteFromMBr(@oTempTable, @oMoreDlg, @cMark)
Endif

If lRet .And. cRule == "FIFO"
    oModel := FWModelActive()
    oModelF4C := oModel:GetModel("RU06D07_MHEAD")
    oModelVrt := oModel:GetModel("RU06D07_MVIRT")
    nDifVlpay := oModelF4C:GetValue("F4C_ITBALA")
    
    //Fix payment value in last line
    If nDifVlpay < 0
        oModelVrt:GoLine(oModelVrt:Length())
    // Difference in currency of bill
        If oModelVrt:GetValue("B_CONUNI") == "1"
            nDifVlpay := xMoeda(nDifVlpay /*Value */,;
                                1 /* Currency from*/,;
                                oModelVrt:GetValue("B_CURREN")/* Currency to*/ ,;
                                oModelF4C:GetValue("F4C_DTTRAN") /* Date of exchage rate*/  ,;
                                GetSX3Cache("F48_VALPAY", "X3_DECIMAL")  /* Decimal*/)
        EndIf
        lRet := RU06D07E2_RecalcVlsForNonPA("B_VALPAY"/*cID*/,;
                                        oModelVrt:GetValue("B_VALPAY")+nDifVlpay/*xNVal*/,;
                                        oModelVrt:GetValue("B_VALPAY")/*xCVal*/,;
                                        oModelVrt/*oModel*/,;
                                        oModelF4C/*oMdlHdr*/)
        lRet := lRet .And. oModelVrt:LoadValue("B_VALPAY",oModelVrt:GetValue("B_VALPAY")+nDifVlpay)

        // Update Total Values according fixing in last line of grid
        aTotals := RU06D07E7_RetTotalsForHeader(oModelVrt, "VRT",.T.)
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITTOTA",aTotals[1])
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITVATF",aTotals[2])
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITVATO",aTotals[3])
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITBALA", oModelF4C:GetValue("F4C_VALUE") - aTotals[1])

        nDifVlpay := oModelF4C:GetValue("F4C_ITBALA")
        // check rounding error
        If nDifVlpay <> 0 .And. oModelVrt:GetValue("B_CONUNI") == "1"
            lRet := RU06D07E2_RecalcVlsForNonPA("B_VALCNV"/*cID*/,;
                                        oModelVrt:GetValue("B_VALCNV")+nDifVlpay/*xNVal*/,;
                                        oModelVrt:GetValue("B_VALCNV")/*xCVal*/,;
                                        oModelVrt/*oModel*/,;
                                        oModelF4C/*oMdlHdr*/)
            lRet := lRet .And. oModelVrt:LoadValue("B_VALCNV",oModelVrt:GetValue("B_VALCNV")+nDifVlpay)
        EndIf

        lRet := lRet .And. RU06D07E9_UpdateF5MLine(oModelVrt/*oSubModel*/, oModelF4C/*oMdlHdr*/, "UPDATE"/*cAction*/)

        // Update Total Values according fixing in last line of grid
        aTotals := RU06D07E7_RetTotalsForHeader(oModelVrt, "VRT",.T.)
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITTOTA",aTotals[1])
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITVATF",aTotals[2])
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITVATO",aTotals[3])
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITBALA", oModelF4C:GetValue("F4C_VALUE") - aTotals[1])
        oModelVrt:GoLine(1)
    EndIf
EndIf
If lRet
    oBrowsePut:GetOwner():End()
EndIf

Return Nil

/*/{Protheus.doc} RU06XFUN15_MyCreaTRB
Create temporary table and insert data into it
Please, extend aFieldList array if you need it.
@param	cHeadAlias - Header table name
        cProgName  - Source name (RU06D04 or RU06D07)
@return		Array      aRet {oTempTable , aFields, cErrMsg}
                                         // temporary table which was created, +
                                         // array of fields with parameters for view, 
                                         // + cErrMsg, if all ok with qeuries
                                         // cErrMsg will be Empty
@author natalia.khozyainova
@since 11/12/2018
@edit   astepanov 11 July 2019
@version 3.0
@type function
/*/
Static Function RU06XFUN15_MyCreaTRB(cHeadAlias As Character, cProgName As Character, lInflow as Logical)
    Local aFields    As Array
    Local aRet       As Array
    Local aFields2   As Array
    Local aInp       As Array
    Local aF5MFldsAd As Array
    local cQuery     As Character
    Local oModel     As Object
    Local oModelHead As Object
    Local oModelDet  As Object
    Local oTmpTab2   As Object
    Local oTempTable As Object
    Local cSupp      As Character
    Local cUnit      As Character
    Local cCurr      As Character
    Local cDetAlias  As Character
    Local cLnForDel  As Character
    Local cTab2Fun15 As Character
    Local cErrMsg    As Character
    Local cSETab     As Character
    Local cFilLen    As Character
    Local cFields    As Character
    Local cQrSE2     As Character
    Local cSelct     As Character
    Local cQrCTO     As Character
    Local cQrF5Q     As Character
    Local cPr        As Character
    Local cE         As Character
    Local cForCli    As Character
    Local cFrCl      As Character
    Local cExclTipos As Character
    Local cF5MFldsAd As Character
    Local cF5MLen    As Character
    Local cForbCo    As Character
    Local nX         As Numeric
    Local nAddSE2KLn As Numeric

    Default lInflow := .F.

    cErrMsg    := ""
    nStatus    := 0
    oModel     := FWModelActive()
    If cProgName == "RU06D06"
        oModelHead := oModel:GetModel("RU06D05_MF49")
    Else
        oModelHead := oModel:GetModel(cProgName + "_MHEAD")
    EndIf
    Do Case 
        Case cProgName == "RU06D04"
            oModelDet := oModel:GetModel(cProgName + "_MLNS" )
            cDetAlias := "F48"
        Case cProgName == "RU06D06"
            oModelDet := oModel:GetModel("RU06D05_MF4B")
            cDetAlias := "F4B"
        Case cProgName == "RU06D07"
            oModelDet := oModel:GetModel(cProgName + "_MVIRT")
            cDetAlias := "B"
    EndCase
    cFilLen    := cValToChar(GetSX3Cache("F5M_FILIAL", "X3_TAMANHO"))
    aInp       := RU06XFUN47_CreateTmpTab1(lInflow)
    oTempTable := aInp[1]
    aFields    := aInp[2]
    cSupp   := oModelHead:GetValue(cHeadAlias + Iif(lInflow, "_CUST","_SUPP")  )
    cUnit   := oModelHead:GetValue(cHeadAlias + Iif(lInflow,"_CUNI","_UNIT")  )
    cCurr   := oModelHead:GetValue(cHeadAlias + "_CURREN")
    cTab2Fun15 := CriaTrab(, .F.)
    oTmpTab2   := FWTemporaryTable():New(cTab2Fun15)
    aFields2   := {}
    nAddSE2KLn := RU06XFUN44_RetSE2FldsPosInFMKey(lInflow)[8][5]
    cSETab := Iif(lInflow,"SE1","SE2")
    cPr    := IIF(lInflow,"SE1.E1_", "SE2.E2_")
    cE     := IIF(lInflow,"E1_", "E2_")
    cForCli:= IIF(lInflow,"SE1.E1_CLIENTE", "SE2.E2_FORNECE")
    cFrCl  := IIF(lInflow,"E1_CLIENTE","E2_FORNECE")
    cForbCo:= IIF(lInflow,"SE1.E1_BCOCLI","SE2.E2_FORBCO")
    AADD(aFields2,{IIf(lInflow,"ADDSE1KEYT","ADDSE2KEYT")  , "C", nAddSE2KLn ,00})
    oTmpTab2:SetFields(aFields2)
    oTmpTab2:AddIndex("1", {IIf(lInflow,"ADDSE1KEYT","ADDSE2KEYT")})
    oTmpTab2:Create()
    For nX := 1 To oModelDet:Length() // pass virtual grid, and add lines which
        oModelDet:GoLine(nX)          // will be excluded from result query
        If !(oModelDet:IsDeleted())
            cLnForDel := AllTrim(xFilial(cSETab))                           +;
                         AllTrim(oModelDet:GetValue(cDetAlias + "_PREFIX")) +;
                         AllTrim(oModelDet:GetValue(cDetAlias + "_NUM"   )) +;
                         AllTrim(oModelDet:GetValue(cDetAlias + "_PARCEL")) +;
                         AllTrim(oModelDet:GetValue(cDetAlias + "_TYPE"  )) +;
                         AllTrim(cSupp)                                     +;
                         AllTrim(cUnit)
            cLnForDel := PADR(cLnForDel,nAddSE2KLn,' ')
            cQuery  := "INSERT INTO " + oTmpTab2:GetRealName() + " ( ADDSE2KEYT ) "
            cQuery  += "VALUES ( '" + cLnForDel + "' )"
            cQuery  := IIf(lInflow,StrTran(cQuery,"( ADDSE2KEYT )","( ADDSE1KEYT )"),cQuery)
            nStatus := TCSqlExec(cQuery)
            If nStatus < 0
                cErrMsg += " TCSQLError() " + TCSQLError()
                Exit
            EndIf
        EndIf
    Next nX
    //form a set of keys cExclTipos for excluding from query result
    //lines with E2_(E1_)TIPO in MVRECANT,MVPAGANT,MV_CPNEG,MV_CRNEG
    //https://jiraproducao.totvs.com.br/browse/RUIT-700
    cExclTipos := IIf(lInflow,MVRECANT+"|"+MV_CRNEG, MVPAGANT+"|"+MV_CPNEG)
    cExclTipos := FormatIn(cExclTipos,"|")
    
    // Query text for Temporary table
    cSelct := " SELECT                                                               "
    cSelct += "    CAST('0' AS CHAR(1))     "+cE+"OK,                                "
    cSelct += "    "+cPr+"FILIAL , "+cPr+"PREFIXO, "+cPr+"F5QCODE, " +cPr+"NUM    ,  "
    cSelct += "    "+cPr+"PARCELA, "+cPr+"TIPO   , "+cPr+"EMISSAO, "+cPr+"VENCREA,   "
    cSelct += "    CTO.CTO_MOEDA ,                                                   "
    cSelct += "    CASE WHEN "+cPr+"CONUNI = '1'                                     "
    cSelct += "         THEN 'Yes'                                                   "
    cSelct += "         ELSE 'No'                                                    "
    cSelct += "    END "+cE+"CONUNI , "+cPr+"VALOR  ,                                "
    cSelct += "    COALESCE("+cPr+"SALDO - OPB.OPBVALUE, "+cPr+"SALDO) "+cE+"BALANCE,"
    cSelct += "    "+cForCli+", "+cPr+"LOJA   ,                                      "
    cSelct += "    (TRIM("+cPr+"FILIAL) ||TRIM("+cPr+"PREFIXO)||TRIM("+cPr+"NUM) ||  "
    cSelct += "     TRIM("+cPr+"PARCELA)||TRIM("+cPr+"TIPO)   ||TRIM("+cForCli+")    "
    cSelct += "     ||TRIM("+cPr+"LOJA))  ADD"+cSETab+"KEYC ,                        "
    cSelct += "    "+cPr+"MOEDA  , "+cPr+"VALIMP1, "+cPr+"NATUREZ, "+cPr+"VLCRUZ ,   "
    cSelct += "    "+cPr+"ALQIMP1, "+cPr+"F5QUID,                                    "
    cSelct += "    COALESCE(F5Q.F5Q_DESCR, '' ),                                     "
    cSelct += "    CAST('1' AS CHAR(1)),                                             "
    cSelct += "    COALESCE(F5Q.F5Q_CODE , ''),                                      "
    cSelct += "    "+cPr+"CONUNI "+IIF(lInflow,"E1","E2")+"CUDIGTL,                  "
    cSelct += "    CAST('"+xFilial(cSETab)+"' AS CHAR("+cFilLen+")) F5M_FILIAL,      "
    cSelct += "    COALESCE(OPB.BSVATOBF, 0)   BSVATOBF,                             "
    cSelct += "    COALESCE(OPB.VLVATOBF, 0)   VLVATOBF,                             "
    cSelct += "    "+cPr+"BASIMP1,                                                   "
    cSelct += "    COALESCE(PST.VLVATPST, 0)   VLVATPST,                             "
    cSelct += "    "+cForbCo+"                                                       "

    cQrSE2 := "           ( SELECT *                                                 "
    cQrSE2 += "             FROM " + RetSQLName(cSETab) + "                          "
    cQrSE2 += "             WHERE                                                    "
    cQrSE2 += "                       "+cE+"FILIAL   =   '" + xFilial(cSETab)+ "'    "
    cQrSE2 += "                   AND "+cFrCl+"      =   '" +      cSupp     + "'    "
    cQrSE2 += "                   AND "+cE+"LOJA     =   '" +      cUnit     + "'    "
    cQrSE2 += "                   AND "+cE+"VENCREA  BETWEEN                         "
    cQrSE2 += "                                          '" + DTOS(MV_PAR01) + "'    "
    cQrSE2 += "                                      AND '" + DTOS(MV_PAR02) + "'    "
    cQrSE2 += "                   AND "+cE+"NUM      BETWEEN                         "
    cQrSE2 += "                                          '" +    MV_PAR03    + "'    "
    cQrSE2 += "                                      AND '" +    MV_PAR04    + "'    "
    cQrSE2 += "                   AND "+cE+"NATUREZ  BETWEEN                         "
    cQrSE2 += "                                          '" +    MV_PAR05    + "'    "
    cQrSE2 += "                                      AND '" +    MV_PAR06    + "'    "
    cQrSE2 += "                   AND "+cE+"F5QCODE  BETWEEN                         "
    cQrSE2 += "                                          '" +    MV_PAR07    + "'    "
    cQrSE2 += "                                      AND '" +    MV_PAR08    + "'    "
    If !Empty(cExclTipos)
        cQrSE2 += "               AND "+cE+"TIPO NOT IN                              "
        cQrSE2 += "                                       " +   cExclTipos   + "     "
    EndIf
    If !lInflow .And. GETMV("MV_CTLIPAG")
        cQrSE2 += "               AND (   E2_STATLIB  = '03'                         "
        cQrSE2 += "                    OR E2_STATLIB  = '05' )                       "
    EndIf
    If !Empty(cCurr)
        If cCurr == '01'
            cQrSE2 += "           AND "+cE+"MOEDA    BETWEEN                         "
            cQrSE2 += "                                   " +     MV_PAR09   + "     "
            cQrSE2 += "                               AND " +     MV_PAR10   + "     "
            cQrSE2 += "           AND (   "+cE+"MOEDA    =  1                        "
            cQrSE2 += "                OR "+cE+"CONUNI   = '1'  )                    "
        Else
            cQrSE2 += "           AND "+cE+"MOEDA    =    " +      cCurr     + "     "
            cQrSE2 += "           AND "+cE+"CONUNI   <>  '" +       "1"      + "'    "
        EndIf
    EndIf
    cQrSE2 += "                   AND D_E_L_E_T_  = ' ' ) "+cSETab+"                 "

    cQrCTO := " INNER JOIN " + RetSQLName("CTO") + " CTO                             "
    cQrCTO += "            ON (                                                      "
    cQrCTO += "                    CAST(CTO.CTO_MOEDA AS INTEGER) = "+cPr+"MOEDA     "
    cQrCTO += "                AND CTO.CTO_FILIAL = '"+xFilial("CTO")+"'             "
    cQrCTO += "                AND CTO.D_E_L_E_T_ = ' '                    )         "

    cQrF5Q := " LEFT JOIN  " + RetSQlName("F5Q") + " F5Q                             "
    cQrF5Q += "            ON (                                                      "
    cQrF5Q += "                    F5Q.F5Q_FILIAL = "+cPr+"FILIAL                    "
    cQrF5Q += "                AND F5Q.F5Q_UID    = "+cPr+"F5QUID                    "
    cQrF5Q += "                AND F5Q.D_E_L_E_T_ = ' '                    )         "

    cFields := "( "
    For nX := 1 To Len(aFields) //get list of fields
        cFields += aFields[nX][1] + ", "
    Next nX
    cFields := Left(cFields,Len(cFields)-2)
    cFields += ") "
    If nStatus >= 0
        aF5MFldsAd := ACLONE(F5M->(DBStruct()))
        AADD(aF5MFldsAd,{"F5MFLKEY"                         ,;
                         GetSX3Cache("F5M_KEY","X3_TIPO")   ,;
                         GetSX3Cache("F5M_KEY","X3_TAMANHO"),;
                         GetSx3Cache("F5M_KEY","X3_DECIMAL")})
        cF5MFldsAd := " "
        cF5MLen    := RU06XFUN44_RetSE2FldsPosInFMKey(lInflow)[8][2]
        For nX := 1 To Len(aF5MFldsAd)
            If     aF5MFldsAd[nX][1] == "F5M_KEY"
                cF5MFldsAd += "CAST(F5M_KEY AS CHAR("+cF5MLen+")) F5M_KEY" + ", "
            ElseIf aF5MFldsAd[nX][1] == "F5MFLKEY"
                cF5MFldsAd += "F5M_KEY F5MFLKEY" + ", "
            Else
                cF5MFldsAd += aF5MFldsAd[nX][1] + ", "
            EndIf
        Next nX
        cF5MFldsAd := SubStr(cF5MFldsAd,1,Len(cF5MFldsAd)-2)
        cQuery := cSelct
        cQuery += " FROM                                                                 "
        cQuery += cQrSE2
        //in this left join we get VLVATO, BSVATO, and VALPAY which saved by PR, PO or BS in F5M
        //but these lines are not posted yet.
        cQuery += " LEFT JOIN                                                            "
        cQuery += "      ( SELECT                                                        "
        cQuery += "            GRP.F5M_KEY           F5M_KEY,                            "
        cQuery += "            SUM(GRP.F5M_VALPAY)   OPBVALUE,                           "
        cQuery += "            SUM(GRP.F5M_BSVATO)   BSVATOBF,                           "
        cQuery += "            SUM(GRP.F5M_VLVATO)   VLVATOBF                            "
        cQuery += "        FROM                                                          "
        cQuery += "             ( SELECT F5M.F5M_KEY,                                    "
        cQuery += "                      F5M.F5M_VALPAY,                                 "
        cQuery += "                      F5M.F5M_BSVATO,                                 "
        cQuery += "                      F5M.F5M_VLVATO,                                 "
        cQuery += "                      F5M.F5MFLKEY                                    "
        cQuery += "               FROM                                                   "
        cQuery += "                      ( SELECT " + cF5MFldsAd + "                     "
        cQuery += "                        FROM     "+RetSQlName("F5M") + " F5M          "
        cQuery += "                        WHERE F5M.F5M_CTRBAL = '1'                    "
        cQuery += "                        AND   F5M.D_E_L_E_T_ = ' ') F5M               "
        cQuery += "                                                ) GRP                 "
        cQuery += "               GROUP BY GRP.F5M_KEY)                   OPB            "
        cQuery += " ON ( "  + RU06XFUN09_RetSE2F5MJoinOnString("OPB",lInflow) + ")       "
        // get data from F5M table where F5M_CTRBAL == 2, F5M_ALIAS == "F4C"
        // and F4C_STATUS inner joined to F5M line by F5M_IDODC
        // have value 2 or 5, we get this info for calculating already posted VLVATO
        // by BS
        cQuery += " LEFT JOIN                                                            "
        cQuery += "      ( SELECT                                                        "
        cQuery += "            GRP.F5M_KEY           F5M_KEY,                            "
        cQuery += "            SUM(GRP.F5M_VLVATO)   VLVATPST                            "
        cQuery += "        FROM                                                          "
        cQuery += "             ( SELECT F5M.F5M_KEY,                                    "
        cQuery += "                      F5M.F5M_VLVATO,                                 "
        cQuery += "                      F5M.F5MFLKEY                                    "
        cQuery += "               FROM                                                   "
        cQuery += "                   ( SELECT " + cF5MFldsAd + "                        "
        cQuery += "                     FROM     "+RetSQlName("F5M") + " F5M             "
        cQuery += "                     INNER JOIN                                       "
        cQuery += "                           (SELECT *                                  "
        cQuery += "                            FROM   "+RetSQlName("F4C")+"              "
        cQuery += "                            WHERE                                     "
        cQuery += "                                (F4C_STATUS = '2' OR F4C_STATUS = '5')"
        cQuery += "                                 AND D_E_L_E_T_ = ' '                 "
        cQuery += "                            ) F4C                                     "
        cQuery += "                     ON  ( F4C.F4C_CUUID = F5M.F5M_IDDOC )            "
        cQuery += "                     WHERE F5M.F5M_CTRBAL = '2'                       "
        cQuery += "                       AND F5M.F5M_ALIAS  = 'F4C'                     "
        cQuery += "                       AND F5M.D_E_L_E_T_ = ' '                       "
        cQuery += "                    ) F5M                                             "
        cQuery += "                                                ) GRP                 "
        cQuery += "               GROUP BY GRP.F5M_KEY)                   PST            "
        cQuery += " ON ( "  + RU06XFUN09_RetSE2F5MJoinOnString("PST",lInflow) + ")       "
        //---------Join moeda information from CTO table----------------------------------
        cQuery += cQrCTO
        //---------Join contract information from F5Q table-------------------------------
        cQuery += cQrF5Q
        //--------Balance should be greater 0---------------------------------------------
        cQuery += " WHERE COALESCE("+cPr+"SALDO - OPB.OPBVALUE, "+cPr+"SALDO) > 0        "
        cQuery += "   AND                                                                "
        cQuery += "    (TRIM("+cPr+"FILIAL) ||TRIM("+cPr+"PREFIXO)||TRIM("+cPr+"NUM) ||  "
        cQuery += "     TRIM("+cPr+"PARCELA)||TRIM("+cPr+"TIPO)   ||TRIM("+cForCli+")    "
        cQuery += "     ||TRIM("+cPr+"LOJA))  NOT IN (                                   "
        cQuery += "                               SELECT ADD"+cSETab+"KEYT               "
        cQuery += "                               FROM " + oTmpTab2:GetRealName() + "    "
        cQuery += "                                                            )         "
        cQuery := ChangeQuery(cQuery)
        cQuery := " INSERT INTO " + oTempTable:GetRealName() + " " + cFields + " " + cQuery
        nStatus := TCSqlExec(cQuery)
        If nStatus < 0
            cErrMsg += " TCSQLError() " + TCSQLError()
        EndIf
    Else
        cErrMsg += " TCSQLError() " + TCSQLError()
    EndIf
    aRet    := {oTempTable, aFields, cErrMsg}
Return (aRet)

/*/{Protheus.doc} RU06XFUN16_MarkAll
Mark all records
@param		oBrowsePut - Object
			cTempTbl - Alias markbrowse
            cFieldName - Name of field containing mark sign in markbrowse
@author natalia.khozyainova
@since 11/12/2018
@version 2.0
@type function
@project	MA3
/*/
Function RU06XFUN16_MarkAll(oBrowsePut as Object, cTempTbl as Char, cFieldName as Character)
Local nRecOri 	as Numeric

Default cFieldName:="E2_OK"
nRecOri	:= (cTempTbl)->( RecNo() )

dbSelectArea(cTempTbl)
(cTempTbl)->( DbGoTop() )
Do while !(cTempTbl)->( Eof() )
	RecLock(cTempTbl, .F.)
	If !Empty((cTempTbl)-> ( &(cFieldName) ) )
		(cTempTbl)-> ( &(cFieldName) ) := ""
	Else
		(cTempTbl)->( &(cFieldName) ) := cMark
	EndIf
	MsUnlock()

	(cTempTbl)->( DbSkip() )
Enddo

(cTempTbl)->( DbGoTo(nRecOri) )
oBrowsePut:oBrowse:Refresh(.T.)
Return .T.

/*/{Protheus.doc} RU06XFUN17_VldVATFields
VAT fields validation and update in RU06D04, RU06D05, RU06D07
@param	nNum - shows which field is validated, comes from sx3
		cAlias - ehader table alias
        cModelLines - model name to check if grid is empty
@author eduardo.flima
@since 18/12/2018
@version 3.0
@type function
@project	MA3
/*/
Function RU06XFUN17_VldVATFields(nNum as Numeric, cAlias as Character, cModelLines as Character)
// 1 = VALUE, 2=COD , 3=RAT, 4=AMOUNT
Local lRet          as Logical
Local aRate         as Array
Local oModel        as Object
Local oModelL       as Object
Local lGridEmpty    as Logical
Local cModelID      as Character

lRet        := .T.
aRate       := {0,100}  // if VATCOD is empty
oModel      :=FWModelActive()
cModelID    :=oModel:GetID()
oModelL     :=oModel:GetModel(cModelLines)
lGridEmpty  := oModelL:IsEmpty()

If nNum <> 4
    If !Empty( FwFldGet(cAlias+"_VATCOD") )   // Need to check if it is a formula or a rate.
        // formula
        aRate := RU06XFUN34_ParseVatRate( FwFldGet(cAlias+"_VATCOD") )
    Else
        aRate := { FwFldGet(cAlias+"_VATRAT"), 100 }
    EndIf
EndIf

If nNum == 2 // _VATCOD
    If !Empty(FwFldGet(cAlias+"_VATCOD"))
        FwFldPut(cAlias+"_VATRAT", aRate[1],,,.T.)
        If FwFldGet(cAlias+IIF(cModelID=="RU06D07","_ADVANC","_PREPAY"))=="1" .or. lGridEmpty                 
            FWFldPut(cAlias+"_VATAMT", RU06XFUN18_VATFormula(FwFldGet(cAlias+"_VALUE"),aRate) )
        Endif                    
        lRet:= .T.
    Endif
EndIf

If (nNum==1 .or. nNum==3) // _VALUE or _VATRATE    
    FWFldPut(cAlias+"_VATAMT", RU06XFUN18_VATFormula(FwFldGet(cAlias+"_VALUE"), aRate) )
EndIf

If (nNum==4) .and. !(Positivo()) // _VATAMT
    lRet:=.F.
EndIf
Return (lRet)

/*/{Protheus.doc} RU06XFUN18_VATFormula
Formula to calculate VAT
@author eduardo.flima
@since 04/05/2018
@version 3.0
@type function
/*/
Function RU06XFUN18_VATFormula(nValue, aVatRat, nDec, lInc) 
    Local   nRet As Numeric

    Default nValue  := 0
    Default aVatRat := {0,100}
    Default nDec    := 2
    Default lInc    := .T. // If .T. - VAT amount included in nValue

    nRet   := 0 
    If lInc //VAT included in nValue
        nRet := ROUND((nValue  * aVatRat[1]) /;
                      (aVatRat[2] + aVatRat[1]), nDec)
    EndIf
Return (nRet)


/*/{Protheus.doc} RU06XFUN19_ReasonText
Function to generate automatic text of Reason of Payment
@author natalia.khozyainova
@since 28/12/2018
@version 1.0
@type function
/*/
Function RU06XFUN19_ReasonText(lForce as Logical, nLine as Numeric, cAction as Character) 
Local cRet as Character
Local oModel as Object
Local oModelH as Object
Local oModelL as Object
Local nX as Numeric
Local nQtyLns as Numeric
Local cContract as Character
Local cReason as Character
Local cBills as Character
Local nVatRt as Numeric
Local nVatAmnt as Numeric
Local cPrepay as Character
Local cAliasH as Character
Local cAliasL as Character
Local cModel as Character
Local cF5QUID as Character
Local aArea   as Array

Default lForce:=.F.
Default nLine:=0
Default cAction:=""
oModel:=FwModelActive()
cModel:=oModel:GetID()
aArea := GetArea()
Do Case 
    Case cModel=="RU06D04"
        oModelH:=oModel:GetModel("RU06D04_MHEAD")
        oModelL:=oModel:GetModel("RU06D04_MLNS")
        cAliasH:="F47"
        cAliasL:="F48"
        cF5QUID:=cAliasH+"_F5QUID"
        cPrepay:=oModelH:GetValue(cAliasH+"_PREPAY")
    Case cModel=="RU06D07"
        oModelH:=oModel:GetModel("RU06D07_MHEAD")
        oModelL:=oModel:GetModel("RU06D07_MVIRT")
        cAliasH:="F4C"
        cAliasL:="B"
        cF5QUID:=cAliasH+"_UIDF5Q"
        cPrepay:=oModelH:GetValue(cAliasH+"_ADVANC")
    Case cModel=="RU06D06"
        oModelH:=oModel:GetModel("RU06D05_MF49")
        oModelL:=oModel:GetModel("RU06D05_MVIRT")
        cAliasH:="F49"
        cAliasL:="B"
        cF5QUID:=cAliasH+"_F5QUID"
        cPrepay:=oModelH:GetValue(cAliasH+"_PREPAY")
EndCase

cContract:= ""

If !Empty(oModelH:GetValue(cF5QUID))
    DBSelectArea("F5Q")
    F5Q->(DBGoTop())
    F5Q->(DbSetOrder(1)) //F5Q_FILIAL+F5Q_UID
    If F5Q->(DbSeek(xFilial("F5Q")+oModelH:GetValue(cF5QUID)))
        cContract := AllTrim(F5Q->F5Q_NUMBER) + STR0073 + DToC(F5Q_EDATE)
    EndIf
    DBCloseArea()
EndIf

cReason:=oModelH:GetValue(cAliasH+"_REASON")
nVatRt:=oModelH:GetValue(cAliasH+"_VATRAT")
nVatAmnt:=oModelH:GetValue(cAliasH+"_VATAMT")

nQtyLns:=0
cBills:=''

// calc qty of lines
For nX := 1 To oModelL:Length()
    oModelL:GoLine(nX)
    if ( !(oModelL:IsDeleted()) .or. cAction=='UNDELETE') .and. !Empty(oModelL:GetValue(cAliasL+"_NUM")) 
        if !(cAction='DELETE' .and. nX==nLine)
            nQtyLns++
        EndIf
    EndIf
Next nX

If nQtyLns > 0
    // Go line by line to check bills
    For nX := 1 To oModelL:Length()
        oModelL:GoLine(nX)
        if ( !(oModelL:IsDeleted()) .or. cAction=='UNDELETE') .and. !Empty(oModelL:GetValue(cAliasL+"_NUM")) 
            if !(cAction='DELETE' .and. nX==nLine)
                If alltrim(cBills)==""
                    If nQtyLns == 1
                        cBills:=STR0014 //' the bill'
                    Else
                        cBills:=STR0015 //' the bills'
                    EndIf
                EndIf
                cBills+=' '+alltrim(oModelL:GetValue(cAliasL+"_PREFIX"))+if(alltrim(oModelL:GetValue(cAliasL+"_PREFIX"))!='','/','');
                +alltrim(oModelL:GetValue(cAliasL+"_NUM"))+STR0016 +DToC(oModelL:GetValue(cAliasL+"_EMISS"))+',' //' from '
                nQtyLns++
            EndIf
        EndIf
    Next nX
    cBills:=left(cBills,Len(cBills)-1)+'.'
Else
    cBills:=''
Endif

If alltrim(cReason) == '' .or. left(alltrim(cReason),Len(STR0018)) == STR0018  .or. left(alltrim(cReason),Len(STR0017)) == STR0017 .or. lForce //'Payment' or 'Including VAT '
    cRet:=''
    IF alltrim(cContract)!=''
        cRet:=STR0018 //'Payment'
        cRet+=STR0019 + ' ' + alltrim(cContract)+', ' //' under the contrract '
    EndIf

    IF alltrim(cBills)!='' .and. cPrepay!='1'
        If alltrim(cRet) == ''
            cRet:=STR0018 //'Payment'
        EndIf
        cRet+=cBills+' '
    EndIf


    If alltrim(cRet)!='' 
        cRet+= CRLF
    EndIf

    if !(nVatRt=0 .and. nVatAmnt=0)
        If nVatRt!=0
            cRet+=STR0017+' '+alltrim(STR(ROUND(nVatRt,2)))+'%' //'Including VAT '
        EndIf

        If nVatAmnt!=0
            cRet+=' - '+alltrim(STR(ROUND(nVatAmnt,2),15,2))
        EndIf
    else
        //no rules were applied, simply retain initial text: 
        if alltrim(cRet)==''
            cRet:= cReason
        Endif
    Endif
Else
    cRet:=cReason
EndIf

RestArea(aArea)

Return (cRet)

/*/{Protheus.doc} RU06XFUN20_VldValPay
@author natalia.khozyainova
@since 28/12/2018
@version 1.0
@type function
/*/
Function RU06XFUN20_VldValPay(nPos as Numeric)
Local lRet      as Logical
Local oModel    as Object
Local cModel    as Character
Local oModelL   as Object
Local oModelH   as Object
Local nOpBal    as Numeric
Local cKey      as Character
Local nCurren   as Numeric
Local dDateToCalc as Date
Local nValLineFld as Numeric
Local aImp        as Array

lRet:=.T.
nOpBal:=0
oModel:=FwModelActive()
cModel:=oModel:GetID()
Do Case 
    Case cModel=="RU06D04"
    oModelH:=oModel:GetModel("RU06D04_MHEAD")
    oModelL:=oModel:GetModel("RU06D04_MLNS")
    dDateToCalc:=oModelH:GetValue("F47_DTPLAN")
    cAliasH:="F47"
    cAliasL:="F48"
    nValLineFld:=oModelL:GetValue("F48_VALREQ")
    Case cModel=="RU06D07"
    oModelH:=oModel:GetModel("RU06D07_MHEAD")
    oModelL:=oModel:GetModel("RU06D07_MVIRT")
    dDateToCalc:=oModelH:GetValue("F4C_DTTRAN")
    cAliasH:="F4C"
    cAliasL:="B"
    nValLineFld:=oModelL:GetValue("B_VALPAY")
    Case cModel=="RU06D06"
    oModelH:=oModel:GetModel("RU06D05_MF49")
    oModelL:=oModel:GetModel("RU06D05_MF4B")
    dDateToCalc:=oModelH:GetValue("F49_DTPAYM")
    cAliasH:="F49"
    cAliasL:="F4B"
    nValLineFld:=oModelL:GetValue("F4B_VALPAY")
    Otherwise
    Return(lRet)
EndCase
nPos:=oModelL:GetLine()
nOpBal:=oModelL:GetValue(cAliasL+"_OPBAL")
nCurren:=oModelL:GetValue(cAliasL+"_CURREN")

If (nValLineFld <= 0)  .OR. (nValLineFld > nOpBal)
            lRet := .F.
EndIf
If !lRet
    Help("",1,"",,STR0022 + cValToChar(nOpBal),1,0,,,,,,) // Error: Bill Balance =
Else
    cKey := oModelL:GetValue(cAliasL+"_FLORIG")+oModelL:GetValue(cAliasL+"_PREFIX")+oModelL:GetValue(cAliasL+"_NUM")+;
            oModelL:GetValue(cAliasL+"_PARCEL")+oModelL:GetValue(cAliasL+"_TYPE")+;
            oModelH:GetValue(cAliasH+"_SUPP")+oModelH:GetValue(cAliasH+"_UNIT")
    aImp :=  RU06XFUN80_Ret_VLIMP1_BSIMP1(cKey,nValLineFld,oModelL:GetValue(cAliasL+"_VALUE"),2)
    oModelL:LoadValue(cAliasL+"_VLIMP1",aImp[1])
    oModelL:LoadValue(cAliasL+"_BSIMP1",aImp[2])
EndIf

Return (lRet)


/*/{Protheus.doc} RU06XFUN21_RecalcRubls
@author natalia.khozyainova
@since 28/12/2018
@version 1.0
@type function
/*/
Function RU06XFUN21_RecalcRubls(lOnlyRate, dDateToRecalc)
Local oModel    as Object
Local cModel    as Character
Local oModelH   as Object
Local oModelL   as Object
Local nCurrLin  as Numeric
Local nExgRat   as Numeric
Local cAliasL   as Character
Local cAliasH   as Character
Local nValLineFld as Numeric
Local nValImp     as Numeric
Local aCnvVls     as Array

Default lOnlyRate:=.F.

oModel:=FwModelActive()
cModel:=oModel:GetID()
Do Case 
    Case cModel=="RU06D04"
    oModelH:=oModel:GetModel("RU06D04_MHEAD")
    oModelL:=oModel:GetModel("RU06D04_MLNS")
    Default dDateToRecalc:=oModelH:GetValue("F47_DTPLAN")
    cAliasL:="F48"
    cAliasH:="F47"
    nValLineFld:=oModelL:GetValue("F48_VALREQ")
    Case cModel=="RU06D06"
    oModelH:=oModel:GetModel("RU06D05_MF49")
    oModelL:=oModel:GetModel("RU06D05_MF4B")
    Default dDateToCalc:=oModelH:GetValue("F49_DTPAYM")
    cAliasH:="F49"
    cAliasL:="F4B"
    nValLineFld:=oModelL:GetValue("F4B_VALPAY")
EndCase
nCurrLin:=oModelL:GetValue(cAliasL+"_CURREN")
nExgRat:=oModelL:GetValue(cAliasL+"_EXGRAT")

LimpaMoeda()

If lOnlyRate
    If Val(oModelH:GetValue(cAliasH+"_CURREN")) == 1 // local currency
        If nCurrLin == 1 //i.e. RUB/RUB
            oModelL:LoadValue(cAliasL+"_EXGRAT", 1)
        Else //i.e. USD/RUB
            oModelL:LoadValue(cAliasL+"_EXGRAT", RecMoeda(dDateToRecalc,nCurrLin))
        EndIf
    Else // for different currencies calculates cross rate
        If nCurrLin == Val(oModelH:GetVaValue(cAliasH+"_CURREN")) // i.e. EUR/EUR
            oModelL:LoadValue(cAliasL+"_EXGRAT", 1)
        Else // i.e. USD/EUR
            oModelL:LoadValue(cAliasL+"_EXGRAT", xMoeda(1, nCurrLin,;
                              Val(oModelH:GetValue(cAliasH+"_CURREN")),;
                              dDateToRecalc,4))
        EndIf
    EndIf 
Else
    nValImp := oModelL:GetValue(cAliasL+"_VLIMP1")
    aCnvVls := RU06XFUN81_RetCnvValues(nValLineFld,nValImp,oModelL:GetValue(cAliasL + "_EXGRAT"),2)
    oModelL:LoadValue(cAliasL+"_VALCNV",aCnvVls[1])
    oModelL:LoadValue(cAliasL+"_VLVATC",aCnvVls[2])
    oModelL:LoadValue(cAliasL+"_BSVATC",aCnvVls[3])
    Do Case
        Case cModel == "RU06D04"
            RU06D0407_ValidRubles()
    EndCase
EndIf

Return (.T.)

/*/{Protheus.doc} RU06XFUN22_CurrRatValid
@author natalia.khozyainova
@since 21/01/2019
@version 1.0
@type function
/*/
Function RU06XFUN22_CurrRatValid(nNum)
Local oModel    as Object
Local oModelL   as Object
Local cModel    as Character
Local oStrL     as Object
Local cAliasL   as Character
Default nNum:=0

oModel:=FwModelActive()
cModel:=oModel:GetID()
Do Case 
    Case cModel=="RU06D04"
    oModelL:=oModel:GetModel("RU06D04_MLNS")
    cAliasL:="F48"
EndCase

oStrL:=oModelL:GetStruct()

If nNum==2 
    If FwFldGet(cAliasL+"_RATUSR") != "1"   
    RU06XFUN21_RecalcRubls(.T.)
    EndIf
Else   
    oModelL:SetValue(cAliasL+"_RATUSR","1")
    oStrL:SetProperty(cAliasL+"_CHECK"	,MODEL_FIELD_WHEN,{|| .T. })
    oModelL:SetValue(cAliasL+"_CHECK",.T.)
EndIf
RU06XFUN21_RecalcRubls(.F.)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN23_VirtCheckBoxValid
Validation on virtual checkbox, attached to _RATUSR fields
@type function
@author natalia.khozyainova
@since 21/01/2019
@version 1.0
/*/ 
//-------------------------------------------------------------------
Function RU06XFUN23_VirtCheckBoxValid()
Local lRet      as Logical
Local oModel    as Object
Local cModel    as Character
Local oStrL     as Object
Local cAliasL   as Character

lRet:=.T.
oModel:=FwModelActive()
cModel:=oModel:GetID()
Do Case 
    Case cModel=="RU06D04"
    oStrL:=oModel:GetModel("RU06D04_MLNS"):GetStruct()
    cAliasL:="F48"
EndCase

If FwFldGet(cAliasL+"_CHECK")
            FwFldPut(cAliasL+"_RATUSR","1")
Else
    FwFldPut(cAliasL+"_RATUSR","0")
    oStrL:SetProperty(cAliasL+"_CHECK"	,MODEL_FIELD_WHEN,{|| .F. })
EndIf

Return (lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN24_2Click
Doubleclick on bills
@author natalia.khozyainova
@since 21/01/2019
@version P12.1.21
@type function
/*/
//-----------------------------------------------------------------------
Function RU06XFUN24_2Click(oFormula, cFieldName, nLineGrid, nLineModel)
Local aArea		as Array
Local aAreaSE2	as Array 
Local aAreaSA6	as Array 
Local aAreaFil	as Array 
Local oModel    as Object
Local oModelL   as Object
Local oModelH   as Object
Local lRet      as Logical
Local lInflow   as Logical
Local cAliasL   as Character
Local cAliasH   as Character
Local cModel    as Character
Local cFilReserv  as Character
Private cCadastro as Character

Default oFormula:=NIL
Default cFieldName:=""
Default nLineGrid:=0
Default nLineModel:=0

lRet:=.T.
oModel:=FwModelActive()
cModel:=oModel:GetID()
aArea:= GetArea()
aAreaSA6:= SA6->(GetArea())
Do Case 
    Case cModel=="RU06D04"
    oModelL:=oModel:GetModel("RU06D04_MLNS")
    oModelH:=oModel:GetModel("RU06D04_MHEAD")
    cAliasL:="F48"
    cAliasH:="F47"
    lInflow := .F.

    Case cModel=="RU06D07"
    oModelL:=oModel:GetModel("RU06D07_MVIRT")
    oModelH:=oModel:GetModel("RU06D07_MHEAD")
    cAliasL:="B"
    cAliasH:="F4C"
    lInflow := (oModelH:GetValue("F4C_OPER") == '1')

EndCase

If lInflow
    aAreaSE2:= SE1->(GetArea())
Else
    aAreaSE2:= SE2->(GetArea())
EndIf

If cFieldName==cAliasL+"_CHECK" .or. cFieldName==cAliasL+"_EXGRAT" .or. cFieldName==cAliasL+"_VALCNV" .or. cFieldName==cAliasL+"_CONUNI"
    lRet:=.T.
ElseIf !(oModelL:CanSetValue(cFieldName))
    If lInflow
        SE1->(DbSetOrder(2))    //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
        If SE1->(DbSeek(ALLTRIM(oModelL:GetValue(cAliasL+"_FLORIG"))+oModelH:GetValue(cAliasH+"_CUST")+oModelH:GetValue(cAliasH+"_CUNI")+oModelL:GetValue(cAliasL+"_PREFIX")+oModelL:GetValue(cAliasL+"_NUM")+oModelL:GetValue(cAliasL+"_PARCEL")+oModelL:GetValue(cAliasL+"_TYPE")))
            dbSelectArea("SA1")
            If SA1->(dbSeek(xFilial("SA1", SE1->E1_FILIAL)+SE1->E1_CLIENTE+SE1->E1_LOJA))
                dbSelectArea("SE1")
                aAreaFil:= GetArea()
                cFilReserv:=cFilAnt
                cFilAnt:=SE1->E1_FILIAL
                cCadastro := OEMToAnsi(STR0074)
                AxVisual("SE1",SE1->(RecNo()),4,,4,SA1->A1_NOME)
                cFilAnt:=cFilReserv
                RestArea(aAreaFil)
            EndIf
            lRet:=.F.
        EndIf
    Else
        SE2->(DbSetOrder(1))
        If SE2->(DbSeek(ALLTRIM(oModelL:GetValue(cAliasL+"_FLORIG"))+oModelL:GetValue(cAliasL+"_PREFIX")+oModelL:GetValue(cAliasL+"_NUM")+oModelL:GetValue(cAliasL+"_PARCEL")+oModelL:GetValue(cAliasL+"_TYPE")+oModelH:GetValue(cAliasH+"_SUPP")+oModelH:GetValue(cAliasH+"_UNIT")))
            dbSelectArea("SA2")
            If SA2->(dbSeek(xFilial("SA2", SE2->E2_FILIAL)+SE2->E2_FORNECE+SE2->E2_LOJA))
                dbSelectArea("SE2")
                aAreaFil:= GetArea()
                cFilReserv:=cFilAnt
                cFilAnt:=SE2->E2_FILIAL
                cCadastro := OEMToAnsi(STR0021)
                AxVisual("SE2",SE2->(RecNo()),4,,4,SA2->A2_NOME)
                cFilAnt:=cFilReserv
                RestArea(aAreaFil)
            EndIf
            lRet:=.F.
        EndIf
    EndIf
EndIf
RestArea(aArea)
RestArea(aAreaSE2)
RestArea(aAreaSA6)
Return (lRet)

/*/{Protheus.doc} RU06XFUN25_CheckBoxWhen()

@type function
@author natalia.khozyainova
@since 21/01/2019
@version 1.0
/*/ 
Function RU06XFUN25_CheckBoxWhen(cAliasL)
Local lRet
lRet:=.F.
If !Empty(cAliasL)
    lRet:=IIF(FwFldGet(cAliasL+"_RATUSR")=="1", .T., .F.)
EndIf
Return (lRet)

/*/{Protheus.doc} RU06XFUN26_CheckCurrHeadLines()
this function will compare currency in the header of the document to currency in each line
and return lRet == True, if currency is same or 01 in header and conventional units in lines
return lRet == False otherwise
@type function
@author natalia.khozyainova
@since 29/01/2019
@version 1.0
/*/ 
Function RU06XFUN26_CheckCurrHeadLines()
Local oModel    as Object
Local oModelL   as Object
Local oModelH   as Object
Local lRet      as Logical
Local cAliasL   as Character
Local cAliasH   as Character
Local cModel    as Character
Local nX        as Numeric
Local cCurrenH  as Character
Local cCurrenL  as Character
local cType     as Character 

lRet:=.T.
oModel:=FwModelActive()
cModel:=oModel:GetID()
Do Case 
    Case cModel=="RU06D04"
    oModelL:=oModel:GetModel("RU06D04_MLNS")
    oModelH:=oModel:GetModel("RU06D04_MHEAD")
    cAliasL:="F48"
    cAliasH:="F47"

    Case cModel=="RU06D07"
    oModelL:=oModel:GetModel("RU06D07_MVIRT")
    oModelH:=oModel:GetModel("RU06D07_MHEAD")
    cAliasL:="B"
    cAliasH:="F4C"

    Case cModel=="RU06T02"
    oModelL:=oModel:GetModel("RU06T02_MVIRT")
    oModelH:=oModel:GetModel("RU06T02_MHEAD")
    cAliasL:="B"
    cAliasH:="F60"

EndCase
cCurrenH:=oModelH:GetValue(cAliasH+"_CURREN")
nX:=1
cType := ValType(oModelL:GetValue(cAliasL+"_CURREN"))

While nX <= oModelL:Length() .and. lRet
    oModelL:GoLine(nX)

    IF cType == "N"
        cCurrenL:=STRZERO(oModelL:GetValue(cAliasL+"_CURREN"), 2, 0)
    ElseIf cType == "C"
        cCurrenL:=oModelL:GetValue(cAliasL+"_CURREN")
    Endif 

    If !(oModelL:IsDeleted())
        If ( !Empty(Val(cCurrenL)) .AND. cCurrenH!=cCurrenL )
            If !( cCurrenH =="01" .and. oModelL:GetValue(cAliasL+"_CONUNI") == "1" )
                lRet:=.F.
            Endif
        Endif
    EndIf
    nX++
Enddo
Return (lRet)

/*/{Protheus.doc} RU06XFUN27_GridSortAPs()
this function is designed to sort grid after manual include of APs to payment request or to bank statement
@type function
@author eduardo.FLima
@since 29/01/2019
@version 2.0
/*/ 
Function RU06XFUN27_GridSortAPs(oGrid,cAliasL,nDest)
Local lRet          as Logical
Local cFrom         as Char
Local cTo           as Char
Local nOrig         as Numeric
Local cFilFldName   as Character 

Default nDest :=  1 
lRet := .F.    
cFilFldName:=IIF(cAliasL=="B","B_BRANCH",cAliasL+"_FILIAL")
cFrom := oGrid:GetValue(cFilFldName) + oGrid:GetValue(cAliasL+"_PREFIX") +  oGrid:GetValue(cAliasL+"_NUM") +  oGrid:GetValue(cAliasL+"_PARCEL")  +  oGrid:GetValue(cAliasL+"_TYPE")  
nOrig := oGrid:GetLine()
oGrid:GoLine(nDest)
cTo  := oGrid:GetValue(cFilFldName) + oGrid:GetValue(cAliasL+"_PREFIX") +  oGrid:GetValue(cAliasL+"_NUM") +  oGrid:GetValue(cAliasL+"_PARCEL")  +  oGrid:GetValue(cAliasL+"_TYPE")  

While cFrom !=   cTo    
    If cFrom < cTo 
        oGrid:LineShift( nOrig, nDest)
        lRet := .T.
        oGrid:GoLine(nOrig)
        RU06XFUN27_GridSortAPs(oGrid,cAliasL,nDest)
        cFrom := oGrid:GetValue(cFilFldName) + oGrid:GetValue(cAliasL+"_PREFIX") +  oGrid:GetValue(cAliasL+"_NUM") +  oGrid:GetValue(cAliasL+"_PARCEL")  +  oGrid:GetValue(cAliasL+"_TYPE")              
    Else 
        nDest := nDest + 1 
        oGrid:GoLine(nDest)
        cTo  := oGrid:GetValue(cFilFldName) + oGrid:GetValue(cAliasL+"_PREFIX") +  oGrid:GetValue(cAliasL+"_NUM") +  oGrid:GetValue(cAliasL+"_PARCEL")  +  oGrid:GetValue(cAliasL+"_TYPE")  
    Endif
Enddo 

Return (lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN28_CheckAReversalOfAdvancePayment

Function Used to Check If the write-off of this bill was generated 
by a Reversal of an advance payment.

@param       Character        cKey //String with the key to find the BIL in this operation
                                   //filial+prefixo+num+parcela+tipo+fornece+loja for SE2
@return      Logical          lRet //Returns if the Write off of this bill was generated 
                                   //by Reversal PA Bank Statement Process
@example     
@author      astepanov
@since       March/20/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN28_CheckAReversalOfAdvancePayment(cKey)
    Local lRet       As Logical
    Local aArea      As Array
    Local cQuery     As Character
    Local cTab       As Character
    Local cFK7Chave  As Character
    lRet := .F.
    aArea := GetArea()
    DBSelectArea("SE2")  
    DBSetOrder(1)   // filial+prefixo+num+parcela+tipo+fornece+loja
    If DBSeek(cKey) // position to record before post
        /*Check if it`s a PA and if the BILL was generated in the Bank Statement Process--*/
        
        If AllTrim(SE2->E2_TIPO) == "PA" .AND. AllTrim(SE2->E2_ORIGEM) == "RU06D07"
            cFK7Chave := PADR(SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+;
                              SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+;
                              SE2->E2_LOJA,GetSX3Cache("FK7_CHAVE", "X3_TAMANHO"), " " )
            cQuery := "SELECT FK7.FK7_CHAVE "
            cQuery += "FROM "       + RetSQLName("FK2") + " FK2 "
            cQuery += "INNER JOIN " + RetSQLName("FK7") + " FK7 "
            cQuery += " ON (FK7.FK7_IDDOC = FK2.FK2_IDDOC) "
            cQuery += "WHERE "
            cQuery += " FK7.FK7_CHAVE      = '"+ cFK7Chave    +"' "
            cQuery += " AND FK2.FK2_FILIAL = '"+xFilial("FK2")+"' "
            cQuery += " AND FK7.FK7_FILIAL = '"+xFilial("FK7")+"' "
            cQuery += " AND FK2.FK2_MOTBX  = " + " 'DAC' "
            cQuery += " AND FK2.FK2_ORIGEM = " + " 'RU06D07' "
            cQuery += " AND FK7.d_e_l_e_t_ = " + "''"
            cQuery += " AND FK2.d_e_l_e_t_ = " + "''"
            cQuery := ChangeQuery(cQuery)
            cTab   := MPSysOpenQuery(cQuery)
            DBSelectArea(cTab)
            DBGoTop()
            If (cTab)->(!eof())
                lRet := .T.
            EndIf
            (cTab)->(DBCloseArea())
        EndIf
    EndIf
    RestArea(aArea)
Return (lRet) /*---------------------------------RU06XFUN28_CheckAReversalOfAdvancePayment*/


/*/{Protheus.doc} RU06XFUN29_ShwF4N
Function used load values to fields related to table F4N
@param  Numeric     nNum    //1, 2, 0
        Character   cCust   //customer's code (->F4N_CLIENT)
        Character   cUnit   //customer's loja (->F4N_LOJA)
        Character   cBnk    //bank code
        Character   cBIK    //BIC
        Character   cAcc    //Account
@return Variant     xRet    //in case nNum == 0:
will be returnd array with next data {"type of account", "bank name",
"account name", "customer's name"} , so this array can be
extended in future.
                            // in case nNum != 0:  
                            if nNum == 1, -> _BKPNAM  bank name
                            if nNum == 2, -> _ACPNAM  account name
                            if nNum == 3, -> _TYPCP   account type
nothing found in F4N -> Empty string or array with empty strings will be returned 
@type function
@author dtereshenko
@since 2019/04/10
@version P12.1.25
@project MA3 - Russia
/*/
Function RU06XFUN29_ShwF4N(nNum As Numeric  , cCust As Character, cUnit As Character,;
                           cBnk As Character, cBIK  As Character, cAcc  As Character )

    Local cRet    As Character
    Local cAlias  As Character
    Local aArea   As Array
    Local aRet    As Array
    Local xRet
    Default nNum  := 1
    
    cRet := ""
    cAlias := RU06XFUN42_RetBankAccountDataFromF4N(cCust,cUnit,Nil,cBnk,cBIK,cAcc,.T.)
    aArea  := GetArea()
    DbSelectArea(cAlias)
    DbGoTop()
    If !EoF()
        If     nNum == 1 // bank name from F45 table
            cRet := (cAlias)->(_BKPNAM)
        ElseIf nNum == 2 // account name
            cRet := (cAlias)->(_ACPNAM)
        ElseIf nNum == 3 // account type
            cRet := (cAlias)->(_TYPCP)
        ElseIf nNum == 0 // array of data
            aRet := {(cAlias)->(_TYPCP) ,;
                     (cAlias)->(_BKPNAM),;
                     (cAlias)->(_ACPNAM),;
                     (cAlias)->(_PAYNAM) }
        EndIf
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    xRet := IIf(nNum == 0, aRet, cRet)

Return (xRet)

/*/{Protheus.doc} RU06XFUN31_RelacaoRerun()
Function for rerun x3_relacao of all virtual fields in oModel.

oModel - Model where function should rerun relacao's.
cModelID - If this argument is not empty, rerun will affect only fields of this Submodel. 
           If it's empty, function will affect all Model.

@type function
@author Cherchik.Konstantin
@since 02/04/2019
@version P12.1.25
/*/ 
Function RU06XFUN31_RelacaoRerun(oModel as Object, cModelID as Character)
Local lRet         as Logical
Local aModelIDs    as Array
Local aFields      as Array
Local cModelName   as Character
Local cFieldName   as Character
Local nModels      as Numeric
Local nItems       as Numeric

lRet     := .T.
aModelIDs := oModel:GetModelIds()

If EMPTY(AllTrim(cModelID)) .And. !EMPTY(aModelIDs)
    For  nModels := 1 to Len(aModelIDs)
        cModelName := aModelIDs[nModels]
        aFields := oModel:GetModel(aModelIDs[nModels]):GetStruct():GetFields()
        For  nItems := 1 to Len(aFields)
            If aFields[nItems][MODEL_FIELD_VIRTUAL] .And. aFields[nItems][MODEL_FIELD_INIT] != NIL
                cFieldName := aFields[nItems][MODEL_FIELD_IDFIELD] 
                lRet := lRet .And. oModel:GetModel(cModelName):LoadValue(cFieldName,CriaVar(cFieldName))
            EndIf
        Next nItems
    Next nModels
ElseIf ValType(oModel:GetModel(cModelID)) == "O"
    aFields := oModel:GetModel(cModelID):GetStruct():GetFields()
        For  nItems := 1 to Len(aFields)
            If aFields[nItems][MODEL_FIELD_VIRTUAL] .And. aFields[nItems][MODEL_FIELD_INIT] != NIL
                cFieldName := aFields[nItems][MODEL_FIELD_IDFIELD]
                lRet := lRet .And. oModel:GetModel(cModelID):LoadValue(cFieldName,CriaVar(cFieldName))
            EndIf
        Next nItems
EndIf

Return lRet

/*/{Protheus.doc} RU06XFUN32_GetFromCbox()
Function to get value from cbox.

cField - Field's ID from SX3, which Combo-box you need.
cValue - Value, that user was selected from Combo-box.

@type function
@author Cherchik.Konstantin
@since 06/04/2019
@version P12.1.25
/*/ 
Function RU06XFUN32_GetFromCbox(cField as Character, cValue as Character)
Local cString     as Character
Local cContainer  as Character
Local nStrStart   as Numeric
Local nStrtEnd    as Numeric
Local nShift      as Numeric

Default cString := " "

If !EMPTY(AllTrim(cField))
    nShift := 2     // First 2 symbols in Cbox for each value starts from "1=", thats why we need to do shift for 2 symbols.
    cContainer := GetSx3Cache(cField,"X3_CBOXENG")
EndIf

If !EMPTY(AllTrim(cContainer)) .And. !EMPTY(AllTrim(cValue)) .And. cValue $ cContainer
    nStrStart := AT(cValue,cContainer)+nShift
    nStrtEnd := AT(";",cContainer,nStrStart)
    cString := SubStr(cContainer,nStrStart,nStrtEnd-nStrStart)
EndIf 

Return cString

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN34_ParseVatRate

Function parses F30_RATE to array

@param       Character  cVatCode
@return      Array      aRet
@example     
@author      Alexandra Velmozhnya
@since       21/06/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN34_ParseVatRate(cVatCode)
    Local aRet    as Array
    Local aRate   as Array
    Local aArea    as Array
    Local aAreaF30 as Array

    Default cVatCode := ""
    aRate := {}
    cVatCode := PADR(cVatCode,GetSX3Cache("F30_CODE", "X3_TAMANHO"), " ")
    aArea    := GetArea()
    aAreaF30 := F30->(GetArea())
    F30->(DbSetOrder(1))
    // Trying to find VAT Rate
    If (F30->(DbSeek(xFilial("F30") + cVatCode)))
        // Needs to check if it is a formula or a rate
        If ("/" $ F30->F30_RATE)
            aRate   := StrTokArr(F30->F30_RATE, "/")
            aRet    := {Val(aRate[1]), Val(aRate[2])}
        Else
            aRet    := {Val(F30->F30_RATE), 100}
        EndIf
    Else
        aRet        := {0, 100}
    EndIf
    RestArea(aAreaF30)
    RestArea(aArea)

Return aRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN35_RetTempTablWTaxAgentsContracts

Function recieves string which contains F4C->F4C_CUUID value(s)
and returns temporary table with next fields:
F4C_CUUID (C:32), 
E2_F5QUID (C:32)
Sql query seeks all APs related to bank statement, takes from these lines E2_F5QUID (C:32)
field and seeks in legal contracts (F5Q table) lines according to next condition:
F5Q_UID = E2_F5QUID and F5Q_TPAGEN <> '01'
'01' is a parameter (X5_CHAVE) located in 'OT' (X5_TABELA = 'OT'), 
X5_DESCENG = 'With the buyer/customer'
F5M_KEY field is a character(100) string which contains "|" delimiter. 
F5M_KEY should be used for searching lines in SE2 table by next order: filial+prefixo+num+
parcela+tipo+fornece+loja (7 fields).
So we seek all contracts except contracts concluded with the bayer or customer.
Relation scheme between tables can be showed like this:
===========================================================================================
+----+------------------+
| T  |F4C Bank Statement|
+----+------------------+
| PK |F4C_FILIAL(C:6)   |
|    |F4C_CUUID(C:32)   +-=-+---------------------------+
+----+------------------+   | +---+---------------+     |       +---+----------------+
|    |----------------- |   | | T |F5M BS lines   |     |       | T |SE2 AP          |
+----+------------------+   | +---+---------------+     |       +---+----------------+
                            | |PK |F5M_FILIAL(C:6)|     |       |PK |E2_FILIAL(C:6)  |
                            | |   |F5M_ALIAS(C:3) |     |       |   |E2_PREFIXO(C:3) |
                            | |   |F5M_IDDOC(C:32)+-=---+       |   |E2_NUM(C:8)     |
                            | |   |F5M_KEY(C:100) +-=---------=-+   |E2_PARCELA(C:2) |
+----+----------------+     | +---+---------------+             |   |E2_TIPO(C:3)    |
| T  |F5Q Legal contr.|     | |   |-------------- |             |   |E2_FORNECE(C:6) |
+----+----------------+     | +---+---------------+             |   |E2_LOJA(C:2)    |
| PK |F5Q_FILIAL(C:6) +-1-+ |                                   +---+----------------+
|    |F5Q_UIDF4C(C:32)+-=---------------------------------------|-=-+E2_F5QUID(C:32)+-+
+----+----------------+   | |                                   |   |--------------- | =
|    |F5Q_TPAGEN(C:6) |   | |                                   +---+----------------+ |
|    |F5Q_CODE(C:9)   |   | |                                                          |
|    |                |   | | +---+----------------+                                   |
|    |--------------- |   | | | T |F35 VAT Inv.    |                                   |
+----+----------------+   | | +---+----------------|                                   |
                          | | |PK |F35_FILIAL(C:6) +-1-----+                           |
+----+----------------+   | | |   |F35_KEY(C:10)   +-=--+  |                           |
| T  |F5R Legal contr.|   | | +---+----------------+    |  |                           |
|    |    Revision    |   | | |   |F35_CONTRA(C:32)+-=---------------------------------+
+----+----------------+   | | |   |--------------- |    |  |
| PK |F5R_FILIAL(C:6) +-N-+ | +---+----------------+    |  |    +----+---------------+
|    |F5R_UID(C:32)   |     |                           |  |    | T  |F36 VAT Inv.Det|
+----+----------------+     | +---+----------------+    |  |    +----+---------------+
|    |F5R_CODE(C:9)   |     | | T |F5P Advanc. Doc.|    |  +--N-+PK  |F36_FILIAL(C:6)|
|    |------------    |     | +---+----------------+    |       |    |F36_KEY(C:10)  |
+----+----------------+     | |PK |F5P_FILIAL(C:6) |    |       |    |F36_ITEM(C:4)  |
                            | |   |F5P_KEY(C:10)   +-=--+       +----+---------------+
                            | +---+----------------+            |    |-------------- |
                            +-|-=-+F5P_UIDF4C(C:32)|            +----+---------------+
                              |   |--------------- |
                              +---+----------------+
===========================================================================================
If bank statement doesn't contains payments under contracts concluded by the company as a
tax agent, temporary table will be empty and cursor will be positioned on eof().
In case of error in sql query, function returns {Nil, "Error message"},
in normal case will be returned {FWTemporaryTable(), ""}

@param       Character       cF4C_CUUID // 32 character UID for bank statement
             Logical         lPackage   // .T. - indicates that we must process 2 or more
                                        //       bank statements, so cF4C_CUUID should be
                                        //       a complex string with delimiters
                                        // .F. - return tax agent VAT invoices only for 1
                                        //       bank statement (Default)
                                        // it is not used yet but it will be used in case
                                        // of list of BS. So, need implementation.
@return      Array           aRet    // aRet[1] == FWTemporaryTable() Object with the
                                     fields: F4C_CUUID, E2_F5QUID with Index by F4C_CUUID
                                     aRet[2] (C) // in normal case it will be "", in case of
                                     error it contains error message and aRet[1] will be Nil

@example     
@author      astepanov
@since       June/21/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN35_RetTempTablWTaxAgentsContracts(cF4C_CUUID As Character,;
                                                   lPackage   As Logical   )
    Local aRet       As Array
    Local aArea      As Array
    Local aFields    As Array
    Local oTmpTab    As Object
    Local cHlpMsg    As Character
    Local cAlias     As Character
    Local cQuery     As Character
    Local cFields    As Character
    Local nStat      As Numeric
    Local nX         As Numeric
    Default cF4C_CUUID := ""
    Default lPackage   := .F.
    
    aArea   := GetArea()
    cAlias  := CriaTrab(, .F.)
    oTmpTab := FWTemporaryTable():New(cAlias)
    cHlpMsg := ""
    aFields := {}
    AADD(aFields, {"F4C_FILIAL",;
                    GetSX3Cache("F4C_FILIAL", "X3_TIPO"   ),;
                    GetSX3Cache("F4C_FILIAL", "X3_TAMANHO"),;
                    GetSX3Cache("F4C_FILIAL", "X3_DECIMAL") })
    AADD(aFields, {"F4C_CUUID",;              
                    GetSX3Cache("F4C_CUUID" , "X3_TIPO"   ),;
                    GetSX3Cache("F4C_CUUID" , "X3_TAMANHO"),;
                    GetSX3Cache("F4C_CUUID" , "X3_DECIMAL") })
    AADD(aFields, {"E2_F5QUID",;
                    GetSX3Cache("E2_F5QUID", "X3_TIPO")   ,;
                    GetSX3Cache("E2_F5QUID", "X3_TAMANHO"),;
                    GetSX3Cache("E2_F5QUID", "X3_DECIMAL") })
    oTmpTab:SetFields(aFields)
    oTmpTab:AddIndex(cAlias + "01",{"F4C_CUUID"})
    oTmpTab:Create()

    //----------INSERT INTO oTmpTab:GetRealName()-------------------------------------
    cQuery := " SELECT                                                               "
    cQuery += "           F4C.F4C_FILIAL AS F4C_FILIAL,                              "
    cQuery += "           F4C.F4C_CUUID  AS F4C_CUUID,                               "
    cQuery += "           SE2.E2_F5QUID AS E2_F5QUID                                 "
    cQuery += " FROM                                                                 "
    cQuery += "           ( SELECT * FROM  " + RetSQLName("F4C") + "                 "
    cQuery += "                      WHERE F4C_FILIAL =  '" + xFilial("F4C") + "'    "
    cQuery += "                        AND F4C_CUUID  =  '" + cF4C_CUUID     + "'    "
    cQuery += "                        AND D_E_L_E_T_ =  ' '                   ) F4C "
    cQuery += " INNER JOIN " + RetSQLName("F5M")   + " F5M                           "
    cQuery += "            ON (F5M.F5M_FILIAL = F4C.F4C_FILIAL                       "
    cQuery += "           AND  F5M.F5M_IDDOC  = F4C.F4C_CUUID                        "
    cQuery += "           AND  F5M.D_E_L_E_T_ = ' '  )                               "
    cQuery += " INNER JOIN " + RetSQLName("SE2")   + " SE2                           "
    cQuery += "            ON ("+RU06XFUN09_RetSE2F5MJoinOnString()+"                "
    cQuery += "           AND  SE2.D_E_L_E_T_ = ' '  )                               "
    cQuery += " INNER JOIN " + RetSQLName("F5Q")   + " F5Q                           "
    cQuery += "            ON (F5Q.F5Q_FILIAL = SE2.E2_FILIAL                        "
    cQuery += "           AND  F5Q.F5Q_UID    = SE2.E2_F5QUID                        "
    cQuery += "           AND  F5Q.D_E_L_E_T_ = ' '                                  "
    cQuery += "           AND  F5Q.F5Q_TPAGEN <> "  +  "                            '"
    cQuery +=                     PADR("01",TamSX3("F5Q_TPAGEN")[1])  + "' )         "
    cQuery += " GROUP BY F4C_FILIAL, F4C_CUUID, E2_F5QUID                            "
    cQuery := ChangeQuery(cQuery)
    cFields := "( "
    For nX := 1 To Len(aFields) //get list of fields
        cFields += aFields[nX][1] + ", "
    Next nX
    cFields := Left(cFields,Len(cFields)-2)
    cFields += ") "
    cQuery := " INSERT INTO " + oTmpTab:GetRealName() + " " + cFields + " " + cQuery
    nStat  := TCSqlExec(cQuery)
    If nStat < 0
        cHlpMsg += "TCSQLError() " + TCSQLError()
    EndIf
    RestArea(aArea)
    If Empty(cHlpMsg)
        aRet := {oTmpTab, cHlpMsg}
    Else
        aRet := {Nil,     cHlpMsg}
    EndIf
Return (aRet) /*---------------------------------RU06XFUN35_RetTempTablWTaxAgentsContracts*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN36_RetTaxAgentInvoicesForBS

This function returns a list of VAT Tax agent invoices produced for bank statement
List format: {"F4C_CUUID","E2_F5QUID","F35_FILIAL","F35_KEY"}

@param      Character        cF4C_CUUID // Unique 32symb ID for Bank statement
            Object           oTmpTab    // Temporary table generated by function:
                                        // RU06XFUN35_RetTempTablWTaxAgentsContracts
                                        // it can be Nil.
            Logical          lPackage   // .T. - indicates that we must process 2 or more
                                        //       bank statements, so cF4C_CUUID should be
                                        //       a complex string with delimiters
                                        // .F. - return tax agent VAT invoices only for 1
                                        //       bank statement (Default)
                                        // it is not used yet but it will be used in case
                                        // of list of BS. So, need implementation.
@return     Array            aRet       // aRet[1] == FWTemporaryTable with next fields:
                                        // {"F4C_CUUID","E2_F5QUID","F35_FILIAL",;
                                        // "F35_KEY"                                }
                                        // aRet[2] == (Character) "" or "ErrorMsg"
                                        // In case of no VAT invoices temporary table will
                                        // be empty and cursor will be positioned on eof()
                                        // In case of error: {Nil, "cHlpMsg"} will be
                                        // returned
                                        // aRet[3] == LastRec(). number of last record
@example     
@author      astepanov
@since       June/21/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN36_RetTaxAgentInvoicesForBS(cF4C_CUUID As Character,;
                                             oTmpTab    As Object,;
                                             lPackage   As Logical    )
    Local aArea      As Array
    Local aRet       As Array
    Local aInp       As Array
    Local aFields    As Array
    Local lRes       As Logical
    Local lDelTMP    As Logical
    Local cQuery     As Character
    Local cTab       As Character
    Local cAlias     As Character
    Local cHlpMsg    As Character
    Local cFields    As Character
    Local oRetTab    As Object
    Local nStat      As Numeric
    Local nX         As Numeric
    Local nLastRec   As Numeric
    Default cF4C_CUUID := ""
    Default lPackage   := .F.
    lRes    := .T.
    lDelTMP := .F.
    cTab    := ""
    cHlpMsg := ""
    aRet    := {Nil, cHlpMsg, 0}
    aArea   := GetArea()
    If oTmpTab == Nil
        aInp :=  RU06XFUN35_RetTempTablWTaxAgentsContracts(cF4C_CUUID, lPackage)
        If aInp[1] == Nil
            lRes    := .F.
            cHlpMsg += aInp[2]
        Else
            oTmpTab := aInp[1]
            lDelTMP := .T.
        EndIf
    EndIf
    If lRes
        cAlias  := CriaTrab(, .F.) 
        oRetTab := FWTemporaryTable():New(cAlias)
        aFields := {}
        AADD(aFields, {"F4C_CUUID",;              
                        GetSX3Cache("F4C_CUUID" , "X3_TIPO"   ),;
                        GetSX3Cache("F4C_CUUID" , "X3_TAMANHO"),;
                        GetSX3Cache("F4C_CUUID" , "X3_DECIMAL") })
        AADD(aFields, {"E2_F5QUID",;
                        GetSX3Cache("E2_F5QUID", "X3_TIPO")   ,;
                        GetSX3Cache("E2_F5QUID", "X3_TAMANHO"),;
                        GetSX3Cache("E2_F5QUID", "X3_DECIMAL") })
        AADD(aFields, {"F35_FILIAL",;
                        GetSX3Cache("F35_FILIAL", "X3_TIPO"   ),;
                        GetSX3Cache("F35_FILIAL", "X3_TAMANHO"),;
                        GetSX3Cache("F35_FILIAL", "X3_DECIMAL") })
        AADD(aFields, {"F35_KEY",;
                        GetSX3Cache("F35_KEY"   , "X3_TIPO"   ),;
                        GetSX3Cache("F35_KEY"   , "X3_TAMANHO"),;
                        GetSX3Cache("F35_KEY"   , "X3_DECIMAL") })
        oRetTab:SetFields(aFields)
        oRetTab:AddIndex(cAlias+"01",{"F4C_CUUID" , "E2_F5QUID",;
                                      "F35_FILIAL", "F35_KEY"   })
        oRetTab:Create()
        cQuery := " SELECT                                               "
        cQuery += "         TMP.F4C_CUUID  AS F4C_CUUID,                 "
        cQuery += "         TMP.E2_F5QUID AS E2_F5QUID,                  "
        cQuery += "         F35.F35_FILIAL AS F35_FILIAL,                "
        cQuery += "         F35.F35_KEY    AS F35_KEY                    "
        cQuery += " FROM " + oTmpTab:GetRealName()     + " TMP           "
        cQuery += " INNER JOIN " + RetSQLName("F5P")   + " F5P           "
        cQuery += "            ON (F5P.F5P_FILIAL = TMP.F4C_FILIAL       "
        cQuery += "           AND  F5P.F5P_UIDF4C = TMP.F4C_CUUID        "
        cQuery += "           AND  F5P.D_E_L_E_T_ = ' ')                 "
        cQuery += " INNER JOIN " + RetSQLName("F35")   + " F35           "
        cQuery += "            ON (F35.F35_FILIAL = F5P.F5P_FILIAL       "
        cQuery += "           AND  F35.F35_KEY    = F5P.F5P_KEY          "
        cQuery += "           AND  F35.D_E_L_E_T_ = ' '                  "
        cQuery += "           AND  F35.F35_F5QUID = TMP.E2_F5QUID)      "
        cQuery += " GROUP BY F4C_CUUID, E2_F5QUID, F35_FILIAL, F35_KEY  "
        cQuery := ChangeQuery(cQuery)
        cFields := "( "
        For nX := 1 To Len(aFields) //get list of fields
            cFields += aFields[nX][1] + ", "
        Next nX
        cFields := Left(cFields,Len(cFields)-2)
        cFields += ") "
        cQuery := "INSERT INTO " + oRetTab:GetRealName() + " " + cFields + " " + cQuery
        nStat  := TCSqlExec(cQuery)
        If nStat < 0 
            lRes    := .F.
            cHlpMsg += "TCSQLError() " + TCSQLError()
        EndIf
    EndIf
    nLastRec := 0
    DBSelectArea(cAlias)
    nLastRec := LastRec()
    If lDelTMP
       oTmpTab:Delete() 
    EndIf
    If lRes
        aRet[1] := oRetTab
        aRet[2] := cHlpMsg
        aRet[3] := nLastRec
    Else
        aRet[1] := Nil
        aRet[2] := cHlpMsg
        aRet[3] := nLastRec
    EndIf
    RestArea(aArea)
Return (aRet) /*---------------------------------------RU06XFUN36_RetTaxAgentInvoicesForBS*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN37_RetPODataByKey

This function recievs search key for payment order and returns data related to passed PO.
So it returns alias to the result of SQL query execution, 
if there is no result a cursor will be positioned on Eof()

@param       Character        cKey   // search key F49_PAYORD
             Character        cIDF49 //            F49_IDF49 
             Character        cStat  // PO status (default "1")
@return      Caharacter       cAlias // alias to SQL query execution result, don't forget
                                     // DBCloseArea()
@example     
@author      astepanov
@since       June/27/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN37_RetPODataByKey(cKey, cIDF49, cStat)

    Local   cAlias       As Character
    Local   cQuery       As Character
    Default cKey       := ""
    Default cIDF49     := ""
    Default cStat      := "1"

    cKey   := PADR(cKey  ,GetSX3Cache("F49_PAYORD","X3_TAMANHO"), ' ')
    cStat  := PADR(cStat ,GetSX3Cache("F49_STATUS","X3_TAMANHO"), ' ')
    cIDF49 := PADR(cIDF49,GetSx3Cache("F49_IDF49" ,"X3_TAMANHO"), " ")
    cQuery := " SELECT                                                             "
    cQuery += " F49.F49_SUPP   As _SUPP,   COALESCE(SA2.A2_NOME,  '')  As _SUPNAM, "
    cQuery += " F49.F49_UNIT   As _UNIT,   F49.F49_IDF49               As _IDF49,  "
    cQuery += " F49.F49_CURREN As _CURREN, COALESCE(CTO.CTO_DESC, '')  As _CURNAM, "
    cQuery += " F49.F49_PREPAY As _ADVANC, F49.F49_DTPAYM              As _DTPAYM, "
    cQuery += " F49.F49_BNKPAY As _BNKPAY, F49.F49_PAYBIK              As _PAYBIK, "
    cQuery += " F49.F49_PAYACC As _PAYACC, F49.F49_PAYNAM              As _PAYNAM, "
    cQuery += " F49.F49_REASON As _REASON, F49.F49_VALUE               As _VALUE,  "
    cQuery += " F49.F49_F5QUID As _UIDF5Q, F49.F49_CNT                 As _CNT,    "
    cQuery += " F49.F49_CLASS  As _CLASS,  COALESCE(F5Q.F5Q_DESCR,'')  As _F5QDES, "
    cQuery += " F49.F49_VATCOD As _VATCOD, F49.F49_VATRAT              As _VATRAT, "
    cQuery += " F49.F49_VATAMT As _VATAMT, F49.F49_KPPREC              As _KPPREC, "
    cQuery += " F49.F49_BNKREC As _BNKREC, F49.F49_RECBIK              As _RECBIK, "
    cQuery += " F49.F49_RECACC As _RECACC, F49.F49_RECNAM              As _RECNAM, "
    cQuery += " F49.F49_CTPRE  As _CTPRE,  F49.F49_CTPOS               As _CTPOS,  "
    cQuery += " F49.F49_CCPRE  As _CCPRE,  F49.F49_CCPOS               As _CCPOS,  "
    cQuery += " F49.F49_ITPRE  As _ITPRE,  F49.F49_ITPOS               As _ITPOS,  "
    cQuery += " F49.F49_CLPRE  As _CLPRE,  F49.F49_CLPOS               As _CLPOS,  "
    cQuery += " F49.F49_BNKORD As _BNKORD, COALESCE(FIL.FIL_TIPO,  '') As _TYPCC,  "
    cQuery += "                            COALESCE(FIL.FIL_ACNAME,'') As _ACRNAM, "
    cQuery += "                            COALESCE(F45.F45_NAME,  '') As _BKRNAM, "
    cQuery += "                            COALESCE(SA6.A6_NOME,   '') As _BKPNAM, "
    cQuery += "                            COALESCE(SA6.A6_ACNAME, '') As _ACPNAM  "
    cQuery += " FROM                                                               "
    cQuery += "       ( SELECT *                                    "
    cQuery += "         FROM " + RetSQlName("F49") + "              "
    cQuery += "         WHERE F49_FILIAL = '" + xFilial("F49") + "' "
    cQuery += "         AND   F49_IDF49  = '" + cIDF49         + "' "
    cQuery += "         AND   F49_PAYORD = '" + cKey           + "' "
    cQuery += "         AND   F49_STATUS = '" + cStat          + "' "
    cQuery += "         AND   D_E_L_E_T_ = ' ') As F49              "
    cQuery += " LEFT JOIN " + RetSQlName("SA2")   + " As SA2                       "
    cQuery += "           ON  (SA2.A2_FILIAL  = '"+ xFilial("SA2") + "'            "
    cQuery += "           AND  SA2.A2_COD     = F49.F49_SUPP                       "
    cQuery += "           AND  SA2.A2_LOJA    = F49.F49_UNIT                       "
    cQuery += "           AND  SA2.D_E_L_E_T_ = ' '           )                    "
    cQuery += " LEFT JOIN " + RetSQlName("CTO")   + " As CTO                       "
    cQuery += "           ON  (CTO.CTO_FILIAL = '"+ xFilial("CTO") + "'            "
    cQuery += "           AND CTO.CTO_MOEDA   = F49.F49_CURREN                     "
    cQuery += "           AND CTO.D_E_L_E_T_  = ' '           )                    "
    cQuery += " LEFT JOIN " + RetSQLName("F5Q")   + " As F5Q                       "
    cQuery += "           ON  (F5Q.F5Q_FILIAL = F49.F49_FILIAL                     "
    cQuery += "           AND  F5Q.F5Q_UID    = F49.F49_F5QUID                     "
    cQuery += "           AND  F5Q.D_E_L_E_T_ = ' '           )                    "
    cQuery += " LEFT JOIN " + RetSQLName("FIL")   + " As FIL                       "
    cQuery += "           ON  (FIL.FIL_FILIAL = '"+ xFilial("FIL") + "'            "
    cQuery += "           AND  FIL.FIL_FORNEC = F49.F49_SUPP                       "
    cQuery += "           AND  FIL.FIL_LOJA   = F49.F49_UNIT                       "
    cQuery += "           AND  FIL.FIL_BANCO  = F49.F49_BNKREC                     "
    cQuery += "           AND  FIL.FIL_AGENCI = F49.F49_RECBIK                     "
    cQuery += "           AND  FIL.FIL_CONTA  = F49.F49_RECACC                     "
    cQuery += "           AND  FIL.D_E_L_E_T_ = ' '           )                    "
    cQuery += " LEFT JOIN " + RetSQlName("F45")   + " As F45                       "
    cQuery += "           ON  (F45.F45_FILIAL = '"+ xFilial("F45") + "'            "
    cQuery += "           AND  F45.F45_BIK    = F49.F49_RECBIK                     "
    cQuery += "           AND  F45.D_E_L_E_T_ = ' '           )                    "
    cQuery += " LEFT JOIN " + RetSQlName("SA6")   + " As SA6                       "
    cQuery += "           ON  (SA6.A6_FILIAL  = '"+ xFilial("SA6") + "'            "
    cQuery += "           AND  SA6.A6_COD     = F49.F49_BNKPAY                     "
    cQuery += "           AND  SA6.A6_AGENCIA = F49.F49_PAYBIK                     "
    cQuery += "           AND  SA6.A6_NUMCON  = F49.F49_PAYACC                     "
    cQuery += "           AND  SA6.D_E_L_E_T_ = ' '           )                    "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)

Return (cAlias) /*-----------------------------------------------RU06XFUN37_RetPODataByKey*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN38_RetSuppDataByKey

Get Supplier information using key: filial+cod+loja
Also it returns supplier bank information from FIL table and F45 table, using left join

@param       Character        cCoD   // A2_COD
             Character        cLoja  // A2_LOJA
             Numeric          nMoeda // currency number, for searching account by currency
             Character        cBnkrec // bank BIK code
             Character        cJoin  // how FIL will be connected to SA2    
             Logical          lExClsd // exclude closed bank accounts  if .T., we add
                                      // condition  FIL.FIL_CLOSED  = '2'
             Character        cRecBik // bank BIK code FIL_AGENCI
             Character        cRecAcc // bank account code FIL_CONTA
@return      Object           cAlias // alias to sql query result, 
                                     // don't forget DBCloseArea()
@example     
@author      astepanov
@since       June/27/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN38_RetSuppDataByKey(cCod, cLoja, nMoeda, cBnkRec, cJoin, lExClsd, cRecBik,;
                                     cRecAcc)

    Local   cMoeda  As Character
    Local   cAlias  As Character
    Local   cQuery  As Character
    Default cCoD    := ""
    Default cLoja   := ""
    Default nMoeda  := 0
    Default cBnkRec := ""
    Default cJoin   := " LEFT JOIN "
    Default lExClsd := .F.
    Default cRecBik := ""
    Default cRecAcc := ""
 
    cCOD    := PADR(cCOD   , GetSX3Cache("A2_COD"    ,"X3_TAMANHO"))
    cLoja   := PADR(cLoja  , GetSX3Cache("A2_LOJA"   ,"X3_TAMANHO"))
    cBnkRec := PADR(cBnkRec, GetSX3Cache("FIL_BANCO" ,"X3_TAMANHO"))
    cRecBik := PADR(cRecBik, GetSX3Cache("FIL_AGENCI","X3_TAMANHO"))
    cRecAcc := PADR(cRecAcc, GetSX3Cache("FIL_CONTA" ,"X3_TAMANHO"))
    cMoeda := cValToChar(nMoeda)
    cQuery := " SELECT                                                         "
    cQuery += " SA2.A2_NOME                 As _SUPNAM, SA2.A2_KPP As _KPPREC, "
    cQuery += " SA2.A2_LOJA                 As _UNIT,                          "
    cQuery += " COALESCE(FIL.FIL_BANCO ,'') As _BNKREC,                        "
    cQuery += " COALESCE(FIL.FIL_AGENCI,'') As _RECBIK,                        "
    cQuery += " COALESCE(FIL.FIL_CONTA ,'') As _RECACC,                        "
    cQuery += " COALESCE(FIL.FIL_TIPO  ,'') As _TYPCC ,                        "
    cQuery += " COALESCE(F45.F45_NAME  ,'') As _BKRNAM,                        "
    cQuery += " COALESCE(FIL.FIL_ACNAME,'') As _ACRNAM,                        "
    cQuery += " LEFT(TRIM(COALESCE(FIL.FIL_NMECOR,' ')),100) As _RECNAM,       "
    cQuery += " COALESCE(FIL.FIL_MOEDA , 0) As _CURREN                         "        
    cQuery += " FROM                                                           "
    cQuery += "       (SELECT * FROM " + RetSQLName("SA2") + "                 "
    cQuery += "                 WHERE A2_FILIAL  = '" + xFilial("SA2") + "'    "
    cQuery += "                 AND   A2_COD     = '" + cCoD           + "'    "
    If !Empty(cLoja)
        cQuery += "             AND   A2_LOJA    = '" + cLoja          + "'    "
    EndIf
    cQuery += "                 AND   D_E_L_E_T_ = ' '  ) As SA2               "
    cQuery += cJoin         + RetSQLName("FIL") + " As FIL                     "
    cQuery += "           ON  (FIL.FIL_FILIAL  = '"+xFilial("FIL")+"'          "
    cQuery += "           AND  FIL.FIL_FORNEC  = SA2.A2_COD                    "
    cQuery += "           AND  FIL.FIL_LOJA    = SA2.A2_LOJA                   "
    If nMoeda != 0
        cQuery += "       AND  FIL.FIL_MOEDA   =  "+    cMoeda    +"           "
    EndIf
    If !Empty(cBnkRec)
        cQuery += "       AND  FIL.FIL_BANCO   = '"+    cBnkRec   +"'          "
    EndIf
    If !Empty(cRecBik)
        cQuery += "       AND  FIL_AGENCI      = '"+    cRecBik    +"'         "
    EndIf
    If !Empty(cRecAcc)
        cQuery += "       AND  FIL_CONTA       = '"+    cRecAcc    +"'         "
    EndIf
    If lExClsd
        cQuery += "       AND  FIL.FIL_CLOSED  = '2'                           "
    EndIf
    cQuery += "           AND  FIL.D_E_L_E_T_  = ' '                )          "
    cQuery += cJoin         + RetSQLName("F45") + " As F45                     "
    cQuery += "           ON  (F45.F45_FILIAL  = '"+xFilial("F45")+"'          "
    cQuery += "           AND  F45.F45_BIK     = FIL.FIL_AGENCI                "
    cQuery += "           AND  F45.D_E_L_E_T_  = ' '                )          "
    //          -- MAIN ACCOUNT SHOULD BE FIRST IN THE RESULT                  
    cQuery += " ORDER BY _SUPNAM, _UNIT, _TYPCC                                "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)

    
Return (cAlias) /*---------------------------------------------RU06XFUN38_RetSuppDataByKey*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN39_RetBankAccountDataFromSA6

Function returns alias to the query result with bank account information according
the parameters passed to this function,
If lFull == .F. function checks cBnkCod, cBik, cAcc. If someone is empty it will
be excluded from query. If lFull == .T.  - function will search bank account information 
using all parameteres cBnkCod+cBik+cAcc and no matter empty this parameter or not.

@param       Character        cBnkCod  // A6_COD
             Character        cBik     // A6_AGENCIA
             Character        cAcc     // A6_NUMCON
             Numeric          nMoeda   // A6_MOEDA
             Logical          lFull    // If .T. should be returned account data
                                       // by next search key: cBnkCod == A6_COD,
                                       //  cBik == A6_AGENCIA, cAcc == A6_NUMCON
                                       // So if lFull == .T. should be returned 
                                       // after query execution 1 or 0 lines, no more
                                       // If lFull == .F., it can be returned several lines
             Logical          lExBlkd  // If .T. Blocked accounts with A6_BLOCKED == "1"
                                          will be excluded, if .F. (default) blocked accnts
                                          will be included in query result. So only
                                          accounts with A6_BLOCKED == "2" will be included
                                          in query result if this parameter equals .T.
             Logical          lOBncAc  // .T. select only non cash account
                                       //TIPBCO = "1"
@return      Character        cAlias   // alias to query result, don't forget DBCloseArea()
@example     
@author      astepanov
@since       June/27/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN39_RetBankAccountDataFromSA6(cBnkCod, cBik, cAcc, nMoeda, lFull,;
                                              lExBlkd, lOBncAc                   )

    Local cAlias      As Character
    Local cQuery      As Character
    Local cMoeda      As Character
    Local cLstOfOrder As Character

    Default nMoeda  := 0
    Default cBnkCod := ""
    Default cBik    := ""
    Default cAcc    := ""
    Default lFull   := .F.
    Default lExBlkd := .F.
    Default lOBncAc := .F.
    
    cLstOfOrder := " SA6.A6_TYPEACC "
    cMoeda      := cValToChar(nMoeda)
    cBnkCod     := PADR(cBnkCod, GetSX3Cache("A6_COD"    ,"X3_TAMANHO"))
    cBik        := PADR(cBik   , GetSX3Cache("A6_AGENCIA","X3_TAMANHO"))
    cAcc        := PADR(cAcc   , GetSX3Cache("A6_NUMCON" ,"X3_TAMANHO"))
    cQuery := " SELECT                                                     "
    cQuery += " SA6.A6_MOEDA      _CURREN, SA6.A6_COD          _BNKPAY,    "
    cQuery += " SA6.A6_AGENCIA    _PAYBIK, SA6.A6_NUMCON       _PAYACC,    "
    cQuery += " SA6.A6_NOME       _BKPNAM, SA6.A6_ACNAME       _ACPNAM,    "
    cQuery += " TRIM(SA6.A6_NAMECOR)  _PAYNAM,                             "
    cQuery += "                            SA6.A6_COD          _BNKREC,    "
    cQuery += " SA6.A6_AGENCIA    _RECBIK, SA6.A6_NUMCON       _RECACC,    "
    cQuery += " SA6.A6_NOME       _BKRNAM, SA6.A6_ACNAME       _ACRNAM,    "
    cQuery += " TRIM(SA6.A6_NAMECOR)  _RECNAM,                             "
    cQuery += " SA6.A6_TYPEACC    _TYPCC,  SA6.A6_TYPEACC      _TYPCP      "
    cQuery += " FROM " + RetSQLName("SA6") + "    SA6                      "
    cQuery += " WHERE     SA6.A6_FILIAL  = '" + xFilial("SA6") + "'        "
    //-- FILTERS------------------------------------------------------------
    If nMoeda != 0
        cQuery += "   AND SA6.A6_MOEDA   =  " +   cMoeda       + "         "    
    EndIf
    If !Empty(cBnkCod) .OR. lFull
        cQuery += "   AND SA6.A6_COD     = '" +   cBnkCod      + "'        "
    EndIf
    If !Empty(cBik)    .OR. lFull
        cQuery += "   AND SA6.A6_AGENCIA = '" +     cBik       + "'        "
    EndIf
    If !Empty(cAcc)    .OR. lFull
        cQuery += "   AND SA6.A6_NUMCON  = '" +     cAcc       + "'        "
    EndIf
    If lExBlkd
        cQuery += "   AND SA6.A6_BLOCKED = '" +     "2"        + "'        " 
    EndIf
    If lOBncAc
        cQuery += "   AND SA6.A6_TIPBCO  = '" +     "1"        + "'        "
    EndIf
    //-- FILTERS------------------------------------------------------------
    cQuery += "       AND SA6.D_E_L_E_T_ = ' '                             "
    cQuery += " ORDER BY  " +cLstOfOrder + "                               "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    
Return (cAlias) /*------------------------------------RU06XFUN39_RetBankAccountDataFromSA6*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN40_RetBankAccountDataFromFIL

Function returns alias to the query result with bank account information from FIL according
the parameters passed to this function,
If lFull == .F. function checks cBnkCod, cBik, cAcc. If someone is empty it will
be excluded from query.
cSupp and cUnit are obligatory.
If lFull == .T.  - function will search bank account information 
using all parameteres cSupp+cUnit+cBnkCod+cBik+cAcc 
and no matter empty this parameter or not.

param        Character        cSupp    // Supplier's code (obligatory) FIL_FORNEC
             Character        cUnit    // Supplier's loja (obligatory) FIL_LOJA
             Numeric          nMoeda   // FIL_MOEDA
             Character        cBnkCod  // FIL_BANCO
             Character        cBik     // FIL_AGENCI
             Character        cAcc     // FIL_CONTA
             Logical          lFull    // If .T. should be returned account data
                                       // by next search key: cSupp+cUnit+cBnkCod+cBik+cAcc
                                       // So, after query execution 1 or 0 lines 
                                       // will be returned, no more.
                                       // If lFull == .F., it can be returned several lines
             Logical          LJnF45   // If .T.(Default) - F45 fields will be joined, .F. -
                                       // we don't left join F45
             Logical          lExClsd  // if .T. we exclude form result closed bank accounts
                                       // FIL.FIL_CLOSED  = '2'
@return      Character        cAlias   // alias to query result, don't forget DBCloseArea()
@example     
@author      astepanov
@since       July/01/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN40_RetBankAccountDataFromFIL(cSupp, cUnit, nMoeda, cBnkCod, cBik, cAcc,;
                                              lFull, lJnF45, lExClsd)

    Local cAlias       As Character
    Local cMoeda       As Character
    Local cQuery       As Character
    Local cLstOfOrder  As Character
    Default nMoeda  := 0
    Default lFull   := .F.
    Default cSupp   := ""
    Default cUnit   := ""
    Default cBnkCod := ""
    Default cAcc    := ""
    Default lJnF45  := .T.
    Default lExClsd := .F.

    cSupp   := PADR(cSupp,  GetSX3Cache("FIL_FORNEC" ,"X3_TAMANHO"))
    cUnit   := PADR(cUnit,  GetSX3Cache("FIL_LOJA"   ,"X3_TAMANHO"))
    cMoeda  := cValToChar(nMoeda)
    cBnkCod := PADR(cBnkCod,GetSX3Cache("FIL_BANCO"  ,"X3_TAMANHO"))
    cBik    := PADR(cBik,   GetSX3Cache("FIL_AGENCI" ,"X3_TAMANHO"))
    cAcc    := PADR(cAcc,   GetSX3Cache("FIL_CONTA"  ,"X3_TAMANHO"))
    cLstOfOrder := " FIL.FIL_TIPO "

    cQuery  := " SELECT                                                         "
    cQuery  += " FIL.FIL_TIPO   _TYPCC ,                                        "
    cQuery  += " FIL.FIL_ACNAME _ACNAME, FIL.FIL_REASON            _REASON  ,   "
    cQuery  += " TRIM(FIL.FIL_NMECOR)      _RECNAM,                             "
    If lJnF45
        cQuery += " COALESCE(F45.F45_NAME,'') _BKNAME,                          "
        cQuery += " COALESCE(F45.F45_NAME,'') _BKRNAM,                          "
    EndIf
    cQuery  += " FIL.FIL_ACNAME            _ACRNAM,                             "
    cQuery  += " FIL.R_E_C_N_O_            _FILREC,                             "
    cQuery  += " FIL.FIL_MOEDA             _MOEDA                               "
    cQuery  += " FROM                                                           "
    cQuery  += " (SELECT * FROM " + RetSQLName("FIL") + "                       "
    cQuery  += " WHERE    FIL_FILIAL  = '" + xFilial("FIL") + "'                "
    cQuery  += "     AND  FIL_FORNEC  = '"   +     cSupp    + "'                "
    cQuery  += "     AND  FIL_LOJA    = '"   +     cUnit    + "'                "
    //-- FILTERS-----------------------------------------------------------------
    If nMoeda != 0
        cQuery  += " AND  FIL_MOEDA   =  "   +     cMoeda   + "                 "
    EndIf
    If !Empty(cBnkCod) .OR. lFull
        cQuery  += " AND  FIL_BANCO   = '"   +    cBnkCod   + "'                "
    EndIf
    If !Empty(cBik)    .OR. lFull
        cQuery  += " AND  FIL_AGENCI  = '"   +     cBik     + "'                "
    EndIf
    If !Empty(cAcc)    .OR. lFull
        cQuery  += " AND  FIL_CONTA   = '"   +     cAcc     + "'                "
    EndIf
    If lExClsd
        cQuery  += " AND  FIL_CLOSED  = '"   +     "2"      + "'                "
    EndIf
    //-- FILTERS-----------------------------------------------------------------
    cQuery  +=  "    AND  D_E_L_E_T_  = ' '                                     "
    cQuery  +=  "                              ) FIL                            "
    If lJnF45
        cQuery  +=  " LEFT JOIN " + RetSQLName("F45")  + " F45                  "
        cQuery  +=  "         ON (F45.F45_FILIAL = '" + xFilial("F45") + "'     "
        cQuery  +=  "        AND  F45.F45_BIK    = FIL.FIL_AGENCI               "
        cQuery  +=  "        AND  F45.D_E_L_E_T_ = ' ')                         "
    EndIf
    cQuery  +=  " ORDER BY " + cLstOfOrder + "                                  "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)

Return (cAlias) /*------------------------------------RU06XFUN40_RetBankAccountDataFromFIL*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN42_RetBankAccountDataFromF4N
Function returns alias to the query result with bank account information from F4N according
the parameters passed to this function,
If lFull == .F. function checks cBnkCod, cBik, cAcc. If someone is empty it will
be excluded from query.
cSupp and cUnit are obligatory.
If lFull == .T.  - function will search bank account information 
using all parameteres cCust+cUnit+cBnkCod+cBik+cAcc 
and no matter empty this parameter or not.

@param       Character        cCust    // Customer's code (obligatory) F4N_CLIENT
             Character        cUnit    // Customer's loja (obligatory) F4N_LOJA
             Character        cMoeda   // F4N_CURREN
             Character        cBnkCod  // F4N_BANK
             Character        cBik     // F4N_BIK
             Character        cAcc     // F4N_ACC
             Logical          lFull    // If .T. should be returned account data
                                       // by next search key: cCust+cUnit+cBnkCod+cBik+cAcc
                                       // So, after query execution 1 or 0 lines 
                                       // will be returned, no more.
                                       // If lFull == .F., it can be returned several lines
@return      Character        cAlias   // alias to query result, don't forget DBCloseArea()
@author      astepanov
@since       July/03/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN42_RetBankAccountDataFromF4N(cCust, cUnit, cMoeda, cBnkCod, cBik, cAcc,;
                                              lFull)

    Local cAlias      As Character
    Local cLstOfOrder As Character
    Local cQuery      As Character
    Default cCust     := ""
    Default cUnit     := ""
    Default cBnkCod   := ""
    Default cBik      := ""
    Default cAcc      := ""

    cCust   := PADR(cCust,  GetSX3Cache("F4N_CLIENT" ,"X3_TAMANHO"))
    cUnit   := PADR(cUnit,  GetSX3Cache("F4N_LOJA"   ,"X3_TAMANHO"))
    cBnkCod := PADR(cBnkCod,GetSX3Cache("F4N_BANK"   ,"X3_TAMANHO"))
    cBik    := PADR(cBik,   GetSX3Cache("F4N_BIK"    ,"X3_TAMANHO"))
    cAcc    := PADR(cAcc,   GetSX3Cache("F4N_ACC"    ,"X3_TAMANHO"))
    If !Empty(cMoeda)
        cMoeda  := PADL(AllTrim(cMoeda), GetSX3Cache("F4N_CURREN","X3_TAMANHO"),"0")
    EndIf
    cLstOfOrder := " F4N.F4N_TYPE "

    cQuery  := " SELECT                                                         "
    cQuery  += " F4N.F4N_TYPE   _TYPCP , COALESCE(F45.F45_NAME,'') _BKPNAM ,    "
    cQuery  += " F4N.F4N_ACNAME _ACPNAM, F4N.F4N_NMECOR            _PAYNAM ,    "
    cQuery  += " F4N.F4N_ACC    _PAYACC, F4N.F4N_BIK               _PAYBIK ,    "
    cQuery  += " F4N.F4N_BANK   _BNKPAY, F4N.R_E_C_N_O_            _F4NREC      "
    cQuery  += " FROM                                                           "
    cQuery  += " (SELECT * FROM " + RetSQLName("F4N") + "                       "
    cQuery  += " WHERE    F4N_FILIAL  = '" + xFilial("F4N") + "'                "
    cQuery  += "     AND  F4N_CLIENT  = '"   +     cCust    + "'                "
    cQuery  += "     AND  F4N_LOJA    = '"   +     cUnit    + "'                "
    //-- FILTERS-----------------------------------------------------------------
    If !Empty(cMoeda)
        cQuery  += " AND  F4N_CURREN  = '"   +     cMoeda   + "'                "
    EndIf
    If !Empty(cBnkCod) .OR. lFull
        cQuery  += " AND  F4N_BANK    = '"   +    cBnkCod   + "'                "
    EndIf
    If !Empty(cBik)    .OR. lFull
        cQuery  += " AND  F4N_BIK     = '"   +     cBik     + "'                "
    EndIf
    If !Empty(cAcc)    .OR. lFull
        cQuery  += " AND  F4N_ACC     = '"   +     cAcc     + "'                "
    EndIf
    //-- FILTERS-----------------------------------------------------------------
    cQuery  +=  "    AND  D_E_L_E_T_  = ' '                                     "
    cQuery  +=  "                              ) F4N                            "
    cQuery  +=  " LEFT JOIN " + RetSQLName("F45")  + " F45                      "
    cQuery  +=  "         ON (F45.F45_FILIAL = '" + xFilial("F45") + "'         "
    cQuery  +=  "        AND  F45.F45_BIK    = F4N.F4N_BIK                      "
    cQuery  +=  "        AND  F45.D_E_L_E_T_ = ' ')                             "
    cQuery  +=  " ORDER BY " + cLstOfOrder + "                                  "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
  
Return (cAlias) /*------------------------------------RU06XFUN42_RetBankAccountDataFromF4N*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN43_RetCustDataByKey()
Get Customer information using key: filial+cod+loja
Also it returns customer's bank information from F4N table and F45 table, using left join 
by default or cJoin from parameter.
@param       Character        cCoD    // A1_COD
             Character        cLoja   // A1_LOJA
             Character        cMoeda  // currency code, for searching account by currency
             Character        cBnkRec // bank code
             Character        cBnkBIC // bank BIC
             Character        cBnkAcc // bank account
             Character        cJoin   // how F4N will be connected to SA1
             Logical          lExClsd // exclude form query closed bank accounts         
@return      Object           cAlias  // alias to sql query result, 
                                      // don't forget DBCloseArea()
@example     
@author      astepanov
@since       June/27/2019
@edit        November/03/2020
@version     1.1
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN43_RetCustDataByKey(cCod, cLoja, cMoeda, cBnkRec, cBnkBIC, cBnkAcc, cJoin, lExClsd)

    Local   cAlias  As Character
    Local   cQuery  As Character
    Default cCoD    := ""
    Default cLoja   := ""
    Default cMoeda  := ""
    Default cBnkRec := ""
    Default cJoin   := " LEFT JOIN "
    Default lExClsd := .F.
 
    cCOD    := PADR(cCOD   , GetSX3Cache("A1_COD"   ,"X3_TAMANHO"))
    cLoja   := PADR(cLoja  , GetSX3Cache("A1_LOJA"  ,"X3_TAMANHO"))
    cBnkRec := PADR(cBnkRec, GetSX3Cache("F4N_BANK" ,"X3_TAMANHO"))
    cBnkBIC := PADR(cBnkBIC, GetSX3Cache("F4N_BIK"  ,"X3_TAMANHO"))
    cBnkAcc := PADR(cBnkAcc, GetSX3Cache("F4N_ACC"  ,"X3_TAMANHO"))
    If !Empty(cMoeda)
        cMoeda  := PADL(AllTrim(cMoeda), GetSX3Cache("F4N_CURREN","X3_TAMANHO"),"0")
    EndIf
    cQuery := " SELECT   
    cQuery += " SA1.A1_NOME                  _CUSNAM, SA1.A1_INSCGAN  _KPPPAY, "
    cQuery += " SA1.A1_LOJA                  _CUNI  ,                          "
    cQuery += " COALESCE(F4N.F4N_BANK,  '')  _BNKPAY,                          "
    cQuery += " COALESCE(F4N.F4N_BIK,   '')  _PAYBIK,                          "
    cQuery += " COALESCE(F4N.F4N_ACC,   '')  _PAYACC,                          "
    cQuery += " COALESCE(F4N.F4N_TYPE,  '')  _TYPCP ,                          "
    cQuery += " COALESCE(F45.F45_NAME,  '')  _BKPNAM,                          "
    cQuery += " COALESCE(F4N.F4N_ACNAME,'')  _ACPNAM,                          "
    cQuery += " COALESCE(F4N.F4N_NMECOR,'')  _PAYNAM,                          "
    cQuery += " COALESCE(F4N.F4N_CURREN,'')  _CURREN                           " 
    cQuery += " FROM                                                           "
    cQuery += "       (SELECT * FROM " + RetSQLName("SA1") + "                 "
    cQuery += "                 WHERE A1_FILIAL  = '" + xFilial("SA1") + "'    "
    cQuery += "                 AND   A1_COD     = '" + cCoD           + "'    "
    If !Empty(cLoja)
        cQuery += "             AND   A1_LOJA    = '" + cLoja          + "'    "
    EndIf
    cQuery += "                 AND   D_E_L_E_T_ = ' '  )    SA1               "
    cQuery += cJoin         + RetSQLName("F4N") + "    F4N                     "
    cQuery += "           ON  (F4N.F4N_FILIAL  = '"+xFilial("F4N")+"'          "
    cQuery += "           AND  F4N.F4N_CLIENT  = SA1.A1_COD                    "
    cQuery += "           AND  F4N.F4N_LOJA    = SA1.A1_LOJA                   "
    If !Empty(cMoeda)
        cQuery += "       AND  F4N.F4N_CURREN  = '"+    cMoeda    +"'          "
    EndIf
    If !Empty(cBnkRec)
        cQuery += "       AND  F4N.F4N_BANK    = '"+    cBnkRec   +"'          "
    EndIf
    If !Empty(cBnkBIC)
        cQuery += "       AND  F4N.F4N_BIK     = '"+    cBnkBIC   +"'          "
    EndIf
    If !Empty(cBnkAcc)
        cQuery += "       AND  F4N.F4N_ACC     = '"+    cBnkAcc   +"'          "
    EndIf
    If lExClsd
        cQuery += "       AND  F4N.F4N_CLOSED  = '2'                           "
    EndIf
    cQuery += "           AND  F4N.D_E_L_E_T_  = ' '                )          "
    cQuery += cJoin         + RetSQLName("F45") + "    F45                     "
    cQuery += "           ON  (F45.F45_FILIAL  = '"+xFilial("F45")+"'          "
    cQuery += "           AND  F45.F45_BIK     = F4N.F4N_BIK                   "
    cQuery += "           AND  F45.D_E_L_E_T_  = ' '                )          "
    //          -- MAIN ACCOUNT SHOULD BE FIRST IN THE RESULT                  
    cQuery += " ORDER BY _CUSNAM, _CUNI, _TYPCP                                "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    
Return (cAlias) /*---------------------------------------------------RU06XFUN43_RetCustDataByKey*/

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN33_RetPOLinesByKey

Function returns payment order lines from F4B table, according
to passed payment order number F49_PAYORD(C:10) and payment order ID cF49IDF49(C:32)
used tables: F49 - Payment order, F4A - Payment order details, F4B - Payment order bills
SE2 - Accounts payable, F5Q - legal contracts

@param       Character        cF49PayOrd // F49_PAYORD
             Character        cF49IDF49  // F49_IDF49
             Array            aVrtFields
             Array            aF5MFields
@return      Character        cAlias     // alias to sql query result, don't forget about
                                            DBCloseArea()
@example     
@author      astepanov
@since       July/15/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------------/*/
Function RU06XFUN33_RetPOLinesByKey(cF49PayOrd As Character, cF49IDF49 As Character,;
                                    aVrtFields As Array    , aF5MFields As Array    )

    Local   cAlias     As Character
    Local   cQuery     As Character
    Local   cF5MLen    As Character
    Local   nX         As Numeric
    Default cF49PayOrd := ""
    Default cF49IDF49  := ""

    cF49IDF49  := PADR(AllTrim(cF49IDF49), GetSX3Cache("F49_IDF49" ,"X3_TAMANHO")," ")
    cF49PayOrd := PADR(AllTrim(cF49PayOrd),GetSX3Cache("F49_PAYORD","X3_TAMANHO")," ")
    cF5MLen    := RU06XFUN44_RetSE2FldsPosInFMKey()[8][2]
    cQuery := " SELECT                                                                           "
    cQuery += " F4B.F4B_FLORIG   B_FLORIG, F4B.F4B_PREFIX   B_PREFIX,  F4B.F4B_NUM     B_NUM    ,"
    cQuery += " F4B.F4B_PARCEL   B_PARCEL, F4B.F4B_TYPE     B_TYPE  ,  F49.F49_SUPP    B_FORNECE,"
    cQuery += " F49.F49_UNIT     B_LOJA  ,                             F4B.F4B_EXGRAT  B_EXGRAT ,"
    cQuery += " F4B.F4B_VALCNV   B_VALCNV, F4B.F4B_BSVATC   B_BSVATC,  F4B.F4B_VLVATC  B_VLVATC ,"
    cQuery += " F4B.F4B_RATUSR   B_RATUSR, F4B.F4B_VALPAY   B_VALPAY,  F4B.F4B_CONUNI  B_CONUNI ,"
    cQuery += " F4B.F4B_IDF4A    B_IDF4A , F4B.F4B_FILIAL   B_BRANCH,  F4B.F4B_RATUSR  B_CHECK  ,"
    cQuery += " COALESCE(F4A.F4A_CODREQ, '')              B_CODREQ  ,                            "
    cQuery += " COALESCE(SE2.E2_NATUREZ, '')              B_CLASS   ,                            "
    cQuery += " COALESCE(SE2.E2_EMISSAO, '')              B_EMISS   ,                            "
    cQuery += " COALESCE(SE2.E2_VENCREA, '')              B_REALMT  ,                            "
    cQuery += " COALESCE(SE2.E2_VALOR  ,  0)              B_VALUE   ,                            "
    cQuery += " COALESCE(SE2.E2_MOEDA  ,  1)              B_CURREN  ,                            "
    cQuery += " COALESCE(SE2.E2_SALDO  ,  0)              E2_SALDO  ,                            "
    cQuery += " COALESCE(SE2.E2_BASIMP1,  0)              E2_BASIMP1,                            "
    cQuery += " COALESCE(SE2.E2_ALQIMP1,  0)              B_ALIMP1  ,                            "
    cQuery += " COALESCE(SE2.E2_VALIMP1,  0)              E2_VALIMP1,                            "
    // Calculate B_OPBAL
    cQuery += " CASE WHEN COALESCE(OPB.F5MCTRBAL, '1')  = '1'                                    "
    cQuery += " THEN                                                                             "
    cQuery += " ( COALESCE(SE2.E2_SALDO, 0) -                                                    "
    cQuery += "   COALESCE(OPB.OPBVALUE, 0) +                                                    "
    cQuery += "   F4B.F4B_VALPAY                                                                 "
    cQuery += " )                                                                                "
    cQuery += " ELSE                                                                             "
    cQuery += " ( COALESCE(SE2.E2_SALDO, 0) -                                                    "
    cQuery += "   COALESCE(OPB.OPBVALUE, 0)                                                      "
    cQuery += " )                                                                                "
    cQuery += " END                                                                   B_OPBAL   ,"
    // B_VLCRUZ
    cQuery += " COALESCE(SE2.E2_VLCRUZ,0)                                             B_VLCRUZ  ,"
    //B_VLIMP1, B_BSIMP1, F5M_VLVATO, F5M_BSVATO  values loading should be disclosed in future 
    //specifications. Now we use suggested values for them, they should be correct. 
    cQuery += " F4B.F4B_VLIMP1                                                        B_VLIMP1  ,"
    cQuery += " F4B.F4B_VLIMP1                                                        F5M_VLVATO,"
    cQuery += " F4B.F4B_VALPAY - F4B.F4B_VLIMP1                                       B_BSIMP1  ,"
    cQuery += " F4B.F4B_VALPAY - F4B.F4B_VLIMP1                                       F5M_BSVATO,"
    cQuery += " COALESCE(SE2.E2_CONUNI ,'2')                                          E2_CONUNI ,"
    cQuery += " COALESCE(F5Q.F5Q_CODE  , '')                                          B_MDCNTR  ,"
    cQuery += " '"+xFilial("F5M")+"'                                      F5M_FILIAL,            "
    cQuery += " COALESCE(OPB.F5MCTRBAL, '1')                              F5M_CTRBAL,            "
    cQuery += " F4B.F4B_VALPAY F5M_VALPAY, F4B.F4B_EXGRAT F5M_EXGRAT,  F4B.F4B_VALCNV F5M_VALCNV,"
    cQuery += " F4B.F4B_BSVATC F5M_BSVATC, F4B.F4B_VLVATC F5M_VLVATC,  F4B.F4B_RATUSR F5M_RATUSR,"
    cQuery += " ' '            F5M_IDDOC , ' '            F5M_ALIAS ,  ' '            F5M_KEY,   "
    cQuery += " 0              F5M_RTORIG, 0              F5M_VLORIG,  ' '            F5M_KEYALI "
    cQuery += " FROM                                                                             "
    cQuery += "              ( SELECT *                                                          "
    cQuery += "                         FROM " + RetSQLName("F49") +  "                          "
    cQuery += "                         WHERE F49_FILIAL =   '" + xFilial("F49")      + "'       "
    cQuery += "                           AND F49_IDF49  =   '" + cF49IDF49           + "'       "
    cQuery += "                           AND F49_PAYORD =   '" + cF49PayOrd          + "'       "
    cQuery += "                           AND D_E_L_E_T_ = ' '          ) F49                    "
    cQuery += " INNER JOIN " + RetSQLName("F4B") + "  F4B                                        "
    cQuery += "            ON (F4B.F4B_FILIAL = F49.F49_FILIAL                                   "
    cQuery += "           AND  F4B.F4B_IDF49  = F49.F49_IDF49                                    "
    cQuery += "           AND  F4B.D_E_L_E_T_ = ' '           )                                  "
    cQuery += " LEFT  JOIN " + RetSQLName("F4A") + "  F4A                                        "
    cQuery += "            ON (F4A.F4A_FILIAL = F4B.F4B_FILIAL                                   "
    cQuery += "           AND  F4A.F4A_IDF4A  = F4B.F4B_IDF4A                                    "
    cQuery += "           AND  F4A.D_E_L_E_T_ = ' '           )                                  "
    cQuery += " LEFT  JOIN " + RetSQLName("SE2") + "  SE2                                        "
    cQuery += "            ON (SE2.E2_FILIAL  = F4B.F4B_FLORIG                                   "
    cQuery += "           AND  SE2.E2_PREFIXO = F4B.F4B_PREFIX                                   "
    cQuery += "           AND  SE2.E2_NUM     = F4B.F4B_NUM                                      "
    cQuery += "           AND  SE2.E2_PARCELA = F4B.F4B_PARCEL                                   "
    cQuery += "           AND  SE2.E2_TIPO    = F4B.F4B_TYPE                                     "
    cQuery += "           AND  SE2.E2_FORNECE = F49.F49_SUPP                                     "
    cQuery += "           AND  SE2.E2_LOJA    = F49.F49_UNIT                                     "
    cQuery += "           AND  SE2.D_E_L_E_T_ = ' '           )                                  "
    cQuery += " LEFT JOIN  " + RetSQLName("F5Q") + "  F5Q                                        "
    cQuery += "            ON (F5Q.F5Q_FILIAL = SE2.E2_FILIAL                                    "
    cQuery += "           AND  F5Q.F5Q_UID    = SE2.E2_F5QUID                                    "
    cQuery += "           AND  F5Q.D_E_L_E_T_ = ' '           )                                  "
    cQuery += " LEFT JOIN                                                                        "
    cQuery += "           ( SELECT                                                               "
    cQuery += "                    GRP.F5M_KEY           F5M_KEY,                                "
    cQuery += "                    SUM(GRP.F5M_VALPAY)   OPBVALUE,                               "
    cQuery += "                    CAST('1' AS CHAR(1))  F5MCTRBAL                               "
    cQuery += "             FROM                                                                 "
    cQuery += "                  ( SELECT                                                        "
    cQuery += "                           TRIM(SUBSTRING(F5M_KEY,1,"+cF5MLen+")) F5M_KEY,        "
    cQuery += "                                                                  F5M_VALPAY      "
    cQuery += "                    FROM " + RetSQLName("F5M") + "                                "
    cQuery += "                    WHERE  F5M_CTRBAL = '1'                                       "
    cQuery += "                      AND D_E_L_E_T_ = ' ') GRP                                   "
    cQuery += "                    GROUP BY F5M_KEY)                             OPB             "
    cQuery += "            ON ( "  + RU06XFUN09_RetSE2F5MJoinOnString("OPB") + ")                "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    For nX := 1 To Len(aVrtFields)
        If !(aVrtFields[nX][4] == "C" .OR. aVrtFields[nX][4] == "M")
            TCSetField(cAlias,aVrtFields[nX][3],aVrtFields[nX][4],aVrtFields[nX][5],aVrtFields[nX][6])
        EndIf
    Next nX
    For nX := 1 To Len(aF5MFields)
        If !(aF5MFields[nX][4] == "C" .OR. aF5MFields[nX][4] == "M")
            TCSetField(cAlias,aF5MFields[nX][3],aF5MFields[nX][4],aF5MFields[nX][5],aF5MFields[nX][6])
        EndIf
    Next nX

Return (cAlias) /*----------------------------------------------------RU06XFUN33_RetPOLinesByKey*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN30_RetVrtLnsForOutBS

Function returns alias to query result for creating
lines for Outflow bank statement virtual grid

@param       Character        cF4C_CUUID  //F4C_CUUID 32 character UID
             Character        cF49PayOrd  //F49_PAYORD value
             Character        cF49IDF49   //F49_IDF49 32sym UID
             Date             dDtTran     //F4C->F4C_DTTRAN
             Character        cCurren     //F4C->F4C_CURREN
@Edit       aVelmozhya
@param      Logical           lInflow     //F4C_OPER Bank Statment Direction
@return      Character        cAlias      //Alias to query result, if no result will be ""   
@example     
@author      astepanov
@since       July/16/2019
@version     1.2
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN30_RetVrtLnsForOutBS(cF4C_CUUID, cF49PayOrd, cF49IDF49, lReplace,;
                                      dDtTran   , cCurren   , lInflow             )

    Local   cVlPT   , cVlPD   , cExRT   , cExRD  , cVT              As Character
    Local   cVD     , cVC    , cCD     , cAQ     , cAT              As Character
    Local   cE2ST   , cE2SD  , cE2IT   , cE2ID   , cBImT  , cBImD   As Character
    Local   cVCnT   , CVCnD  , cBCnT   , cBcnD   , cVVnT  , cVVnD   As Character
    Local   cQuery  , cAlias , cLFILIA                              As Character
    Local   cF5MLen , cQRQSt , cQRQLn  , cF4CAlias , cSE2Alias      As Character
    Local   cRtOT   , cRtOD  , cV5OT                                As Character
    Local   cPr     , cTab   , cF4CFil                              As Character
    Local   lExistPO   As Logical

    Default cF4C_CUUID := ""
    Default cF49PayOrd := ""
    Default cF49IDF49  := ""
    Default lReplace   := .F.
    Default lInflow    := .F.
    cAlias     := ""

    cF4CFil    := IIF(FwIsInCallStack("CTBRASTREAR"),xFilial("F4C",CT2->CT2_FILORI),xFilial("F4C"))
    cPr        := IIF(lInflow, "SE1.E1_", "SE2.E2_")
    cTab       := IIF(lInflow, "SE1", "SE2")
    cF4C_CUUID := PADR(cF4C_CUUID,GetSX3Cache("F4C_CUUID" ,"X3_TAMANHO"), " ")
    cF49PayOrd := PADR(cF49PayOrd,GetSX3Cache("F4C_PAYORD","X3_TAMANHO"), " ")
    cF49IDF49  := PADR(cF49IDF49 ,GetSX3Cache("F4C_IDF49" ,"X3_TAMANHO"), " ")
    lExistPO   := IIF(!Empty(cF49PayOrd) .AND. !Empty(cF49IDF49), .T., .F.)
    cLFILIA := cValToChar(GetSX3Cache("F5M_FILIAL","X3_TAMANHO"))
    cVlPT   := cValToChar(GetSX3Cache("F5M_VALPAY","X3_TAMANHO"))
    cVlPD   := cValToChar(GetSX3Cache("F5M_VALPAY","X3_DECIMAL"))
    cExRT   := cValToChar(GetSX3Cache("F5M_EXGRAT","X3_TAMANHO"))
    cExRD   := cValToChar(GetSX3Cache("F5M_EXGRAT","X3_DECIMAL"))
    cVT     := cValToChar(GetSX3Cache(Iif(lInflow,"E1_VALOR","E2_VALOR")  ,"X3_TAMANHO"))
    cVD     := cValToChar(GetSX3Cache(Iif(lInflow,"E1_VALOR","E2_VALOR")  ,"X3_DECIMAL"))
    cVC     := cValToChar(GetSX3Cache(Iif(lInflow,"E1_VLCRUZ","E2_VLCRUZ") ,"X3_TAMANHO"))
    cCD     := cValToChar(GetSX3Cache(Iif(lInflow,"E1_VLCRUZ","E2_VLCRUZ") ,"X3_DECIMAL"))
    cAQ     := cValToChar(GetSX3Cache(Iif(lInflow,"E1_ALQIMP1","E2_ALQIMP1"),"X3_TAMANHO"))
    cAT     := cValToChar(GetSX3Cache(Iif(lInflow,"E1_ALQIMP1","E2_ALQIMP1"),"X3_DECIMAL"))
    cE2ST   := cValToChar(GetSX3Cache(Iif(lInflow,"E1_SALDO","E2_SALDO")  ,"X3_TAMANHO"))
    cE2SD   := cValToChar(GetSX3Cache(Iif(lInflow,"E1_SALDO","E2_SALDO")  ,"X3_DECIMAL"))
    cE2IT   := cValToChar(GetSX3Cache(Iif(lInflow,"E1_VALIMP1","E2_VALIMP1"),"X3_TAMANHO"))
    cE2ID   := cValToChar(GetSX3Cache(Iif(lInflow,"E1_VALIMP1","E2_VALIMP1"),"X3_DECIMAL"))
    cBImT   := cValToChar(GetSX3Cache(Iif(lInflow,"E1_BASIMP1","E2_BASIMP1"),"X3_TAMANHO"))
    cBImD   := cValToChar(GetSX3Cache(Iif(lInflow,"E1_BASIMP1","E2_BASIMP1"),"X3_DECIMAL"))
    cVCnT   := cValToChar(GetSX3Cache("F5M_VALCNV","X3_TAMANHO"))
    CVCnD   := cValToChar(GetSX3Cache("F5M_VALCNV","X3_DECIMAL"))
    cBCnT   := cValToChar(GetSX3Cache("F5M_BSVATC","X3_TAMANHO"))
    cBcnD   := cValToChar(GetSX3Cache("F5M_BSVATC","X3_DECIMAL"))
    cVVnT   := cValToChar(GetSX3Cache("F5M_VLVATC","X3_TAMANHO"))
    cVVnD   := cValToChar(GetSX3Cache("F5M_VLVATC","X3_DECIMAL"))
    cF5MLen := RU06XFUN44_RetSE2FldsPosInFMKey(lInflow)[8][2]
    cQRQSt  := cValToChar(Val(cF5MLen) + 2)
    cQRQLn  := cValToChar(GetSX3Cache("F4A_CODREQ","X3_TAMANHO"))
    cF4CAlias := PADR("F4C", GetSX3Cache("F5M_ALIAS" ,"X3_TAMANHO"), " ")
    cSE2Alias := PADR(Iif(lInflow,"SE1","SE2"), GetSX3Cache("F5M_KEYALI","X3_TAMANHO"), " ")
    //
    cRtOT   := cValToChar(GetSX3Cache("F5M_RTORIG","X3_TAMANHO"))
    cRtOD   := cValToChar(GetSX3Cache("F5M_RTORIG","X3_DECIMAL"))
    cV5OT   := cValToChar(GetSX3Cache("F5M_VLORIG","X3_TAMANHO"))
    cV5OD   := cValToChar(GetSX3Cache("F5M_VLORIG","X3_DECIMAL"))
    If !Empty(cF4C_CUUID)
        cQuery := " SELECT                                                                 "
        //-----------------------------------------------------------------------[-FIELDS-]-
        cQuery += " F5M.F5M_RATUSR                                                B_CHECK ,"
        cQuery += " F5M.F5M_RATUSR                                                B_RATUSR,"
        cQuery += " F5M.F5M_RATUSR                                              F5M_RATUSR,"
        cQuery += " F5M.F5M_KEY                                                   B_F5MKEY,"
        cQuery += " F5M.F5M_KEY                                                    F5M_KEY,"
        cQuery += " COALESCE("+cPr+"NATUREZ,'')                                   B_CLASS ,"
        cQuery += " COALESCE("+cPr+"EMISSAO,'')                                   B_EMISS ,"
        cQuery += " COALESCE("+cPr+"VENCREA,'')                                   B_REALMT,"
        cQuery += " F5M.F5M_VALPAY                                                B_VALPAY,"
        cQuery += " F5M.F5M_VALPAY                                              F5M_VALPAY,"
        cQuery += " F5M.F5M_EXGRAT                                                B_EXGRAT,"
        cQuery += " F5M.F5M_EXGRAT                                              F5M_EXGRAT,"
        cQuery += " F5M.F5M_VALCNV                                                B_VALCNV,"
        cQuery += " F5M.F5M_VALCNV                                              F5M_VALCNV,"
        cQuery += " F5M.F5M_BSVATC                                                B_BSVATC,"
        cQuery += " F5M.F5M_BSVATC                                              F5M_BSVATC,"
        cQuery += " F5M.F5M_VLVATC                                                B_VLVATC,"
        cQuery += " F5M.F5M_VLVATC                                              F5M_VLVATC,"
        cQuery += " F5M.F5M_RTORIG                                              F5M_RTORIG,"
        cQuery += " F5M.F5M_VLORIG                                              F5M_VLORIG,"
        cQuery += " F5M.F5M_ALIAS                                               F5M_ALIAS ,"
        cQuery += " F5M.F5M_KEYALI                                              F5M_KEYALI,"
        // B_VLIMP1
        cQuery += " F5M.F5M_VLVATO                                                B_VLIMP1,"
        cQuery += " F5M.F5M_VLVATO                                              F5M_VLVATO,"
        // B_BSIMP1
        cQuery += " F5M.F5M_BSVATO                                                B_BSIMP1,"
        cQuery += " F5M.F5M_BSVATO                                              F5M_BSVATO,"
        cQuery += " COALESCE("+cPr+"VALOR,0)                                      B_VALUE ,"
        cQuery += " COALESCE("+cPr+"MOEDA,1)                                      B_CURREN,"
        cQuery += " COALESCE("+cPr+"CONUNI,'2')                                   B_CONUNI,"
        cQuery += " COALESCE("+cPr+"ALQIMP1,0)                                    B_ALIMP1,"
        cQuery += " COALESCE(F5Q.F5Q_CODE, ' ')                                   B_MDCNTR,"
        If lExistPO // define B_BRANCH, B_IDF4A in case PO existance
            cQuery += " CASE WHEN COALESCE(F4A.F4A_FILIAL,' ') = ' '                       "
            cQuery += "      THEN F5M.F5M_FILIAL                                           "
            cQuery += "      ELSE F4A.F4A_FILIAL                                           "
            cQuery += " END                                                       B_BRANCH,"
        Else        // so, we have no payment order
            cQuery += " F5M.F5M_FILIAL                                            B_BRANCH,"
        EndIf
        // Calculate B_OPBAL
        cQuery += " CASE WHEN F5M.F5M_CTRBAL = '1'                                         "
        cQuery += " THEN                                                                   "
        cQuery += " ( COALESCE("+cPr+"SALDO, 0)   -                                        "
        cQuery += "   COALESCE(OPB.OPBVALUE, 0)   +                                        "
        cQuery += "   F5M.F5M_VALPAY                                                       "
        cQuery += " )                                                                      "
        cQuery += " ELSE                                                                   "
        cQuery += " ( COALESCE("+cPr+"SALDO, 0)   -                                        "
        cQuery += "   COALESCE(OPB.OPBVALUE, 0)                                            "
        cQuery += " )                                                                      "
        cQuery += " END                                                           B_OPBAL, "
        // B_VLCRUZ
        cQuery += " COALESCE("+cPr+"VLCRUZ,0)                                     B_VLCRUZ "
        //-----------------------------------------------------------------------[-FROM---]-
        cQuery += " FROM                                                                   "
        cQuery += "        (SELECT * FROM " + RetSQLName("F4C") + "                        "
        cQuery += "                  WHERE F4C_FILIAL =  '" +    cF4CFil     + "'          "
        cQuery += "                    AND F4C_CUUID  =  '" +   cF4C_CUUID   + "'          "
        cQuery += "                    AND D_E_L_E_T_ =  ' '                     ) F4C     "
        If !lReplace
            cQuery += " INNER JOIN            " + RetSQLName("F5M") + "                F5M "
            cQuery += "                  ON (  F5M.F5M_FILIAL  = F4C.F4C_FILIAL            "
            cQuery += "                    AND F5M.F5M_IDDOC   = F4C.F4C_CUUID             "
            cQuery += "                    AND F5M.D_E_L_E_T_  = ' '                 )     "
        Else
            cQuery += " INNER JOIN            " + RetSQLName("F5M") + "                F5M "
            cQuery += "                  ON (  F5M.F5M_FILIAL  = F4C.F4C_FILIAL            "
            cQuery += "                    AND F5M.F5M_IDDOC   = F4C.F4C_CUUID             "
            cQuery += "                    AND SUBSTRING(F5M.F5M_KEY," + " "
            cQuery +=                          cValToChar(Val(cLFILIA)+1) + ",1) = '|'     "
            cQuery += "                    AND F5M.F5M_ALIAS   = '" +cF4CAlias+ "'         "
            cQuery += "                    AND F5M.F5M_KEYALI  = '" +cSE2Alias+ "'         " 
            cQuery += "                    AND F5M.D_E_L_E_T_  = ' '                 )     "  
        EndIf
        cQuery += " LEFT JOIN             " + RetSQLName(cTab) + "           " + cTab + "  "
        cQuery += "                  ON ( " + RU06XFUN09_RetSE2F5MJoinOnString(,lInflow) +""
        cQuery += "                    AND "+cTab+".D_E_L_E_T_ = ' '                  )    "
        cQuery += " LEFT JOIN                                                              "
        cQuery += "           ( SELECT                                                     "
        cQuery += "                    GRP.F5M_KEY           F5M_KEY,                      "
        cQuery += "                    SUM(GRP.F5M_VALPAY)   OPBVALUE                      "
        cQuery += "             FROM                                                       "
        cQuery += "                  ( SELECT                                              "
        cQuery += "                         TRIM(SUBSTRING(F5M_KEY,1,"+cF5MLen+")) F5M_KEY,"
        cQuery += "                                                             F5M_VALPAY "
        cQuery += "                    FROM " + RetSQLName("F5M") + "                      "
        cQuery += "                    WHERE  F5M_CTRBAL = '1'                             "
        cQuery += "                      AND D_E_L_E_T_ = ' ') GRP                         "
        cQuery += "                    GROUP BY F5M_KEY)                           OPB     "
        cQuery += "            ON ( "+ RU06XFUN09_RetSE2F5MJoinOnString("OPB",lInflow)+" ) "
        cQuery += " LEFT JOIN             " + RetSQLName("F5Q") + "                F5Q     "
        cQuery += "                  ON (  F5Q.F5Q_FILIAL = "+cPr+"FILIAL                  "
        cQuery += "                    AND F5Q.F5Q_UID    = "+cPr+"F5QUID                  "
        cQuery += "                    AND F5Q.D_E_L_E_T_ = ' '                  )         "
        If lExistPO
            //-Join Payment order and its details-------------------------------------------
            cQuery += " INNER JOIN " + RetSQLName("F49") + "                       F49     "
            cQuery += "           ON ( F49.F49_FILIAL = F4C.F4C_FILIAL                     "
            cQuery += "           AND  F49.F49_PAYORD = F4C.F4C_PAYORD                     "
            cQuery += "           AND  F49.F49_IDF49  = F4C.F4C_IDF49                      "
            cQuery += "           AND  F49.D_E_L_E_T_ = ' '            )                   "
            cQuery += " LEFT  JOIN                                                         "
            cQuery += "           (         SELECT                                         "
            cQuery += "                            F4A_IDF49 ,                             "
            cQuery += "                            F4A_FILIAL,                             "
            cQuery += "                            F4A_IDF4A ,                             "
            cQuery += "                            F4A_CODREQ                              "
            cQuery += "                     FROM " + RetSQLName("F4A") +  "                "
            cQuery += "                     WHERE  F4A_FILIAL = '" + xFilial("F4A") + "'   "
            cQuery += "                       AND  F4A_IDF49  = '" +    cF49IDF49   + "'   "
            cQuery += "                       AND  D_E_L_E_T_ = ' '                        " 
            cQuery += "                     GROUP BY F4A_IDF49 , F4A_FILIAL, F4A_IDF4A,    "
            cQuery += "                              F4A_CODREQ                 )     F4A  " 
            cQuery += "           ON   (F4A.F4A_FILIAL = F49.F49_FILIAL                    " 
            cQuery += "           AND   F4A.F4A_IDF49  = F49.F49_IDF49                     "
            cQuery += "           AND   TRIM(F4A.F4A_CODREQ) =                             "
            cQuery += "                 TRIM(SUBSTRING(F5M.F5M_KEY,                        "
            cQuery += "                        "+cQRQSt+","+cQRQLn+"))  )                  "
        EndIf
        cQuery := ChangeQuery(cQuery)
        cAlias := CriaTrab(Nil, .F.)
        dbUseArea( .T., 'TOPCONN', TCGenQry( , , cQuery ), cAlias, .F., .T. )

        //TCSetField( < cAlias >, < cField >, < cType >, [ nSize ], [ nPrecision ] )
        //If a value other than "D", "L" and "N" is passed in cType , the command will 
        //be ignored and a warning message will be displayed in the Application Server 
        //console log: " TCSetField with type different from 'D', ' L 'and' N '- 
        //statement ignored. ".
        
        //Use PADR or AllTrim function when process result of query
        //because using CAST function prohibited

        TCSetField( cAlias, "B_VALPAY"  , "N", Val(cVlPT), Val(cVlPD) )
        TCSetField( cAlias, "F5M_VALPAY", "N", Val(cVlPT), Val(cVlPD) )
        TCSetField( cAlias, "B_EXGRAT"  , "N", Val(cExRT), Val(cExRD) )
        TCSetField( cAlias, "F5M_EXGRAT", "N", Val(cExRT), Val(cExRD) )
        TCSetField( cAlias, "B_VALCNV"  , "N", Val(cVCnT), Val(CVCnD) )
        TCSetField( cAlias, "F5M_VALCNV", "N", Val(cVCnT), Val(CVCnD) )
        TCSetField( cAlias, "B_BSVATC"  , "N", Val(cBCnT), Val(cBcnD) )
        TCSetField( cAlias, "F5M_BSVATC", "N", Val(cBCnT), Val(cBcnD) )
        TCSetField( cAlias, "B_VLVATC"  , "N", Val(cVVnT), Val(cVVnD) )
        TCSetField( cAlias, "F5M_VLVATC", "N", Val(cVVnT), Val(cVVnD) )
        TCSetField( cAlias, "F5M_RTORIG", "N", Val(cRtOT), Val(cRtOD) )
        TCSetField( cAlias, "F5M_VLORIG", "N", Val(cV5OT), Val(cV5OD) )
        TCSetField( cAlias, "B_VALUE"   , "N", Val(cVT)  , Val(cVD)   )
        TCSetField( cAlias, "B_ALIMP1"  , "N", Val(cAQ)  , Val(cAT)   )
        TCSetField( cAlias, "B_OPBAL"   , "N", Val(cE2ST), Val(cE2SD) )
        TCSetField( cAlias, "B_VLCRUZ"  , "N", Val(cVC)  , Val(cCD)   )
        TCSetField( cAlias, "B_VLIMP1"  , "N", Val(cE2IT), Val(cE2ID) )
        TCSetField( cAlias, "B_BSIMP1"  , "N", Val(cBImT), Val(cBImD) )
        TCSetField( cAlias, "F5M_VLVATO", "N", GetSX3Cache("F5M_VLVATO","X3_TAMANHO"), GetSX3Cache("F5M_VLVATO","X3_DECIMAL"))
        TCSetField( cAlias, "F5M_BSVATO", "N", GetSX3Cache("F5M_BSVATO","X3_TAMANHO"), GetSX3Cache("F5M_BSVATO","X3_DECIMAL"))

    EndIf

Return (cAlias) /*--------------------------------------------RU06XFUN30_RetVrtLnsForOutBS*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN44_RetSE2FldsPosInFMKey

Function returns array with SE2 fields names which located in F5M_KEY, and 
position of each one and its length.
F5M_KEY consists from 7 or more strings delimited by '|'example:
E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_FORNECE|E2_LOJA ... so on
Please, don't change fields order, it should be fixed.
aRet[8][4]  - Sum of [x][5] + 6 delimires
aRet[8][5]  - Sum of [x][5]

@return      Array         aRet
                [1]         [2]  [3] [4] [5]
@example     {{'E2_FILIAL' ,'1' ,'6', 1 , 6 }  [1]
              {'E2_PREFIXO','8' ,'3', 8 , 3 }  [2]
              {'E2_NUM'    ,'12','8', 12, 8 }  [3]
              {'E2_PARCELA','21','2', 21, 2 }  [4]
              {'E2_TIPO'   ,'24','3', 24, 3 }  [5]
              {'E2_FORNECE','28','6', 28, 6 }  [6]
              {'E2_LOJA'   ,'35','2', 35, 2 }  [7]
              {''          ,'36','30',36, 30}  [8]
             }
@author      astepanov
@since       July/17/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN44_RetSE2FldsPosInFMKey(lInflow as Logical)
    Local aRet       As Array
    Local cFl        As Character
    Local cFS        As Character
    Local cPr        As Character
    Local cPS        As Character
    Local cNm        As Character
    Local cNS        As Character
    Local cPl        As Character
    Local cRS        As Character
    Local cTp        As Character
    Local cTS        As Character
    Local cFr        As Character
    Local cCS        As Character
    Local cLS        As Character
    Local cLj        As Character
    Local nF5MKeyLen As Numeric
    Local nX         As Numeric

    Default lInflow := .F.

    aRet       := {}
    nF5MKeyLen := 0
    nX         := GetSX3Cache("E2_FILIAL" , "X3_TAMANHO")
    cFl        := cValToChar(nX)
    cFS        := "1"
    AADD(aRet,{Iif(lInflow, "E1_FILIAL","E2_FILIAL"),cFS,cFl,Val(cFS),Val(cFl)})
    nF5MKeyLen += nX
    nX         := GetSX3Cache("E2_PREFIXO", "X3_TAMANHO")
    cPr        := cValToChar(nX)
    cPS        := cValToChar(nF5MKeyLen + 2)
    AADD(aRet,{Iif(lInflow,"E1_PREFIXO", "E2_PREFIXO"),cPS,cPr,Val(cPS),Val(cPr)})
    nF5MKeyLen += nX
    nX         := GetSX3Cache("E2_NUM"    , "X3_TAMANHO")
    cNm        := cValToChar(nX)
    cNS        := cValToChar(nF5MKeyLen + 3)
    AADD(aRet,{Iif(lInflow,"E1_NUM","E2_NUM"),cNS,cNm,Val(cNS),Val(cNm)})
    nF5MKeyLen += nX
    nX         := GetSX3Cache("E2_PARCELA", "X3_TAMANHO")
    cPl        := cValToChar(nX)
    cRS        := cValToChar(nF5MKeyLen + 4)
    AADD(aRet,{Iif(lInflow,"E1_PARCELA","E2_PARCELA"),cRS,cPl,Val(cRS),Val(cPl)})
    nF5MKeyLen += nX
    nX         := GetSX3Cache("E2_TIPO"   , "X3_TAMANHO")
    cTp        := cValToChar(nX)
    cTS        := cValToChar(nF5MKeyLen + 5)
    AADD(aRet,{Iif(lInflow,"E1_TIPO","E2_TIPO" ),cTS,cTp,Val(cTS),Val(cTp)})
    nF5MKeyLen += nX
    nX         := GetSX3Cache("E2_FORNECE", "X3_TAMANHO")
    cFr        := cValToChar(nX)
    cCS        := cValToChar(nF5MKeyLen + 6)
    AADD(aRet,{Iif(lInflow,"E1_CLIENTE","E2_FORNECE"),cCS,cFr,Val(cCs),Val(cFr)})
    nF5MKeyLen += nX
    nX         := GetSX3Cache("E2_LOJA"   , "X3_TAMANHO")
    cLj        := cValToChar(nX)
    cLS        := cValToChar(nF5MKeyLen + 7)
    AADD(aRet,{Iif(lInflow,"E1_LOJA","E2_LOJA"),cLS,cLj,Val(cLS),Val(cLj)})

    nF5MKeyLen += nX + 6 // 6 is count of delimiter chars -  |
    nX         := nF5MKeyLen - 6 
    AADD(aRet,{"",cValToChar(nF5MKeyLen),cValToChar(nX), nF5MKeyLen, nX})

Return (aRet) /*-------------------------------------------RU06XFUN44_RetSE2FldsPosInFMKey*/

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN45_RetF5MnVrtLnsFromAPs

Function recieves FWTemporarytable generated by RU06XFUN12_MBRW, cMark parameter used for
filter data by E2_OK field, dTrnDate date on which we will recieve exhange rates,
oModel - link to Header model, for example: oModelF4C

@param       Object           oTmp
             Character        cMark
             Date             dExRatDate// Date for exhange rate 
             Object           oModel    // link to Header model, for example: oModelF4C
             Character        cAPTip    // deafult "", but when we create new AP line from BS
                                        // it should be markered like "PA" for payment in advance
             Numeric          nPAval    // Payment in advance value, should be filled when
                                        // cAPTip is not empty
             Numeric          nPAVAT    // Payment in advance VAT value
@edit   Velmozhnya Alexandra
            Logical           lInflow   // Bank Statment Direction
@return      Array            aRet {oTmpRet, cErrMsg} oTmpRet - temporary table with result 
@example     
@author      astepanov
@since       July/22/2019
@version     1.1
@project     MA3
@see         None
//--------------------------------------------------------------------------------------------/*/
Function RU06XFUN45_RetF5MnVrtLnsFromAPs(oTmp, cMark, dExRatDate, oModel, cAPTip, nPAVal, nPAVAT, lInflow)

    Local cAlias       As Character
    Local cErrMsg      As Character
    Local cQuery       As Character
    Local cPr          As Character
    Local cAl          As Character
    Local cCnnd        As Character
    Local cForCli      As Character
    Local cGr          As Character
    Local cBanco       As Character
    Local nMoedaHdr    As Numeric
    Local nVATRAT      As Numeric
    Local nX           As Numeric
    Local aRet         As Array
    Local aArea        As Array
    Local aGrdFields   As Array
    Local aVrtFields   As Array
    Local aFields      As Array
    Local aSEFields    As Array
    Local aTmp         As Array
    Local oTmpRet      As Object
    Local oModelGrd    As Object
    Local oModelVrt    As Object

    Default cMark      := " "
    Default dExRatDate := dDataBase
    Default cAPTip     := ""
    Default nPAVal     := 0
    Default nPAVAT     := 0
    Default lInflow    := .F.

    cAlias    := ""
    cMark     := AllTrim(cMark)
    cErrMsg   := ""
    aArea     := GetArea()
    If     oModel:CID == "RU06D07_MHEAD"
        cGr       := "F5M"
        oModelGrd := oModel:GetModel():GetModel("RU06D07_MLNS" )
        oModelVrt := oModel:GetModel():GetModel("RU06D07_MVIRT")
        nVATRAT   := IIF(Empty(oModel:GetValue("F4C_VATRAT")),0,oModel:GetValue("F4C_VATRAT"))
        nMoedaHdr := IIf(Empty(oModel:GetValue("F4C_CURREN")),;
                        1,Val(oModel:GetValue("F4C_CURREN")) )
    ElseIf oModel:CID == "RU06D05_MF49"
        cGr       := "F4B"
        oModelGrd := oModel:GetModel():GetModel("RU06D05_MF4B" )
        oModelVrt := oModel:GetModel():GetModel("RU06D05_MVIRT")
        nVATRAT   := IIF(Empty(oModel:GetValue("F49_VATRAT")),0,oModel:GetValue("F49_VATRAT"))
        nMoedaHdr := IIf(Empty(oModel:GetValue("F49_CURREN")),;
                        1,Val(oModel:GetValue("F49_CURREN")) )
    ElseIf oModel:CID == "RU06D04_MHEAD"
        cGr      := "F48"
        oModelGrd := oModel:GetModel():GetModel("RU06D04_MLNS")
        oModelVrt := Nil
        nVATRAT   := IIF(Empty(oModel:GetValue("F47_VATRAT")),0,oModel:GetValue("F47_VATRAT"))
        nMoedaHdr := IIf(Empty(oModel:GetValue("F47_CURREN")),;
                        1,Val(oModel:GetValue("F47_CURREN")) )
    EndIf
    If  lInflow
        cPr       := "E1_"
        cAl       := "SE1"
        cCnnd     := "E1CUDIGTL"
        cForCli   := "E1_CLIENTE"
        cBanco    := "E1_BCOCLI"
    Else
        cPr       := "E2_"
        cAl       := "SE2"
        cCnnd     := "E2CUDIGTL"
        cForCli   := "E2_FORNECE"
        cBanco    := "E2_FORBCO"
    EndIf
    
    aGrdFields := ACLONE(oModelGrd:GetStruct():GetFields())
    aVrtFields := IIF(!Empty(oModelVrt),ACLONE(oModelVrt:GetStruct():GetFields()),{})
    aFields    := {}
    For nX := 1 To Len(aGrdFields)
        AADD(aFields, {aGrdFields[nX][3],;
                       aGrdFields[nX][4],;
                       aGrdFields[nX][5],;
                       aGrdFields[nX][6]}) 
    Next nX
    For nX := 1 To Len(aVrtFields)
        AADD(aFields, {aVrtFields[nX][3],;
                       aVrtFields[nX][4],;
                       aVrtFields[nX][5],;
                       aVrtFields[nX][6]})
    Next nX
    AADD(aFields ,{"B_FORNECE", GetSx3Cache(cForCli,"X3_TIPO"   ),;
                                GetSx3Cache(cForCli,"X3_TAMANHO"),;
                                GetSx3Cache(cForCli,"X3_DECIMAL")})
    AADD(aFields ,{cBanco     , GetSx3Cache(cBanco,"X3_TIPO"   ),;
                                GetSx3Cache(cBanco,"X3_TAMANHO"),;
                                GetSx3Cache(cBanco,"X3_DECIMAL")})
    AADD(aFields ,{"B_LOJA"   , GetSx3Cache(cPr+"LOJA","X3_TIPO"   ),;
                                GetSx3Cache(cPr+"LOJA","X3_TAMANHO"),;
                                GetSx3Cache(cPr+"LOJA","X3_DECIMAL")})
    AADD(aFields ,{"B_F5QDES" , GetSx3Cache("F4C_F5QDES","X3_TIPO"   ),;
                                GetSx3Cache("F4C_F5QDES","X3_TAMANHO"),;
                                GetSx3Cache("F4C_F5QDES","X3_DECIMAL")})
    AADD(aFields ,{"B_UIDF5Q" , GetSx3Cache("F4C_UIDF5Q","X3_TIPO"   ),;
                                GetSx3Cache("F4C_UIDF5Q","X3_TAMANHO"),;
                                GetSx3Cache("F4C_UIDF5Q","X3_DECIMAL")})
    AADD(aFields ,{"BALANCE" ,  GetSx3Cache(cPr+"SALDO","X3_TIPO"   ),;
                                GetSx3Cache(cPr+"SALDO","X3_TAMANHO"),;
                                GetSx3Cache(cPr+"SALDO","X3_DECIMAL")})
    AADD(aFields ,{"VLVATOBF" , GetSx3Cache("F5M_VLVATO","X3_TIPO"   ),;
                                GetSx3Cache("F5M_VLVATO","X3_TAMANHO"),;
                                GetSx3Cache("F5M_VLVATO","X3_DECIMAL")})
    AADD(aFields ,{"BSVATOBF" , GetSx3Cache("F5M_BSVATO","X3_TIPO"   ),;
                                GetSx3Cache("F5M_BSVATO","X3_TAMANHO"),;
                                GetSx3Cache("F5M_BSVATO","X3_DECIMAL")})
    AADD(aFields ,{"VLVATPST" , GetSx3Cache("F5M_VLVATO","X3_TIPO"   ),;
                                GetSx3Cache("F5M_VLVATO","X3_TAMANHO"),;
                                GetSx3Cache("F5M_VLVATO","X3_DECIMAL")})
    If cGr == "F48"
        AADD(aFields,{"B_BRANCH",GetSx3Cache("F48_FILIAL","X3_TIPO"   ),;
                                 GetSx3Cache("F48_FILIAL","X3_TAMANHO"),;
                                 GetSx3Cache("F48_FILIAL","X3_DECIMAL")})
    EndIf
    aSEFields := {"VALOR", "VLCRUZ","VALIMP1","BASIMP1","ALQIMP1"}
    For nX := 1 To Len(aSEFields)
        AADD(aFields ,{aSEFields[nX],GetSx3Cache(cPr+aSEFields[nX],"X3_TIPO"   ),;
                                     GetSx3Cache(cPr+aSEFields[nX],"X3_TAMANHO"),;
                                     GetSx3Cache(cPr+aSEFields[nX],"X3_DECIMAL")})
    Next nX
    oTmpRet := FWTemporaryTable():New(CriaTrab(,.F.))                         
    oTmpRet:SetFields(aFields)
    oTmpRet:Create()
    cQuery := " INSERT INTO " + oTmpRet:GetRealName() + "      "
    cQuery += "( "+cGr+"_FILIAL ,                                                 "
    If cGr == "F5M"
        cQuery += "              F5M_CTRBAL     ,                                 "
    EndIf
    If cGr == "F48"
        cQuery += "  F48_MDCNTR ,F48_FLORIG     ,B_BRANCH       ,F48_REALMT     , "
        cQuery += "  F48_PREFIX ,F48_NUM        ,F48_PARCEL     ,F48_TYPE       , "
        cQuery += "  F48_CLASS  ,F48_EMISS      ,F48_CURREN     ,F48_CONUNI     , "
    Else
        cQuery += "  B_MDCNTR   ,B_FLORIG       ,B_BRANCH       ,B_REALMT       , "
        cQuery += "  B_PREFIX   ,B_NUM          ,B_PARCEL       ,B_TYPE         , "
        cQuery += "  B_CLASS    ,B_EMISS        ,B_CURREN       ,B_CONUNI       , "
    EndIf
    cQuery += "  B_FORNECE      ,B_LOJA         ,B_F5QDES       ,B_UIDF5Q       , "
    cQuery += "  BALANCE        ,VALOR          ,                                 "
    cQuery += "  VLCRUZ         ,VALIMP1        ,BASIMP1        ,ALQIMP1        , "
    cQuery += "  VLVATOBF       ,BSVATOBF       ,VLVATPST,      "+cBanco+"        "
    cQuery += ")                                                                  "

    cQuery += " SELECT                                                            "
    cQuery += " F5M_FILIAL      ,                                                 "
    If cGr == "F5M"
        cQuery += "              F5M_CTRBAL     ,                                 "
    EndIf  
    cQuery += "  F5Q_CODE       ,"+cPr+"FILIAL  ,F5M_FILIAL     ,"+cPr+"VENCREA , "
    cQuery += " "+cPr+"PREFIXO  ,"+cPr+"NUM     ,"+cPr+"PARCELA ,"+cPr+"TIPO    , "
    cQuery += " "+cPr+"NATUREZ  ,"+cPr+"EMISSAO ,"+cPr+"MOEDA   ,"+cCnnd+"      , "
    cQuery += " "+cForCli+"     ,"+cPr+"LOJA    ,F5Q_DESCR      ,"+cPr+"F5QUID  , "
    cQuery += " "+cPr+"BALANCE  ,"+cPr+"VALOR   ,                                 "
    cQuery += " "+cPr+"VLCRUZ   ,"+cPr+"VALIMP1 ,"+cPr+"BASIMP1 ,"+cPr+"ALQIMP1 , "
    cQuery += " VLVATOBF        ,BSVATOBF       ,VLVATPST,      "+cBanco+"        "
    cQuery += " FROM " + oTmp:GetRealName() + "                                   "
    cQuery += " WHERE "+cPr+"OK = '" + cMark  + "'                                "
    If lInflow
        cQuery += " ORDER BY "+cPr+"VENCREA ASC, "+cPr+"BALANCE DESC              "
    EndIf  

    nStat := TCSqlExec(cQuery)
    If nStat >= 0
        DbSelectArea(oTmpRet:GetAlias())
        DBGoTop()
        While !Eof()
            nExgRat := xMoeda(1, IIf(cGr=="F48",(F48_CURREN),(B_CURREN)), nMoedaHdr, dExRatDate, GetSX3Cache(cGr+"_EXGRAT","X3_DECIMAL"))
            nExgCRZ := xMoeda(1, IIf(cGr=="F48",(F48_CURREN),(B_CURREN)), 1, dExRatDate, GetSX3Cache(cGr+"_EXGRAT","X3_DECIMAL"))
            nExgRat := IIF(nExgRat == 0, 1, nExgRat)
            nExgCRZ := IIF(nExgCRZ == 0, 1, nExgCRZ)
            
            RecLock(oTmpRet:GetAlias(),.F.)
            &(cGr+"_EXGRAT") := nExgRat
            IIF(FieldPos("B_EXGRAT") > 0, (B_EXGRAT):=&(cGr+"_EXGRAT"), Nil)
            If oModelVrt != Nil
                If AllTrim(cAPTip) $ "PA|RA"
                    (B_VALPAY)   := Round(nPAVal/F5M_EXGRAT,aFields[ASCAN(aFields,{|x| x[1] = "B_VALPAY"})][4])
                    (F5M_VALPAY) := (B_VALPAY)
                    (B_VALUE)    := (B_VALPAY)
                    (B_OPBAL)    := (B_VALPAY)
                    (B_VLIMP1)   := Round(nPAVAT/F5M_EXGRAT,aFields[ASCAN(aFields,{|x| x[1] = "B_VLIMP1"})][4])
                    (B_BSIMP1)   := (B_VALUE) - (B_VLIMP1)
                    (F5M_VALCNV) := nPAVal
                    (F5M_VLVATC) := nPAVAT
                    (F5M_BSVATC) := (F5M_VALCNV) - (F5M_VLVATC)
                    (B_VALCNV)   := (F5M_VALCNV)
                    (B_VLVATC)   := (F5M_VLVATC)
                    (B_BSVATC)   := (F5M_BSVATC)
                    (B_ALIMP1)   := nVATRAT
                    If (B_CURREN)  != nMoedaHdr
                        (B_VLCRUZ) := (B_VALCNV)
                    Else
                        (B_VLCRUZ) := ROUND((B_VALPAY)*nExgCRZ,aFields[ASCAN(aFields,{|x| x[1] = "B_VLCRUZ"})][4])
                    EndIf
                Else
                    (B_VALPAY)       := (BALANCE)
                    &(cGr+"_VALPAY") := (B_VALPAY)
                    (B_VALUE)        := (VALOR)
                    (B_OPBAL)        := (BALANCE)
                    (B_VLCRUZ)       := (VLCRUZ)
                    (B_VLIMP1)       := (VALIMP1)-(VLVATOBF)-(VLVATPST)
                    (B_BSIMP1)       := (B_VALPAY)-(B_VLIMP1)
                    aTmp             := RU06XFUN81_RetCnvValues((B_VALPAY),(B_VLIMP1),&(cGr+"_EXGRAT"),aFields[ASCAN(aFields,{|x| x[1] = cGr+"_VALCNV"})][4])
                    &(cGr+"_VALCNV") := aTmp[1]
                    &(cGr+"_VLVATC") := aTmp[2]
                    &(cGr+"_BSVATC") := aTmp[3]
                    (B_VALCNV)   := &(cGr+"_VALCNV")
                    (B_VLVATC)   := &(cGr+"_VLVATC")
                    (B_BSVATC)   := &(cGr+"_BSVATC")
                    (B_ALIMP1)   := (ALQIMP1)
                EndIf
            EndIf
            If     cGr == "F5M"
                (F5M_KEY)    := ""
                (F5M_ALIAS)  := ""
                (F5M_KEYALI) := cAl
                (F5M_IDDOC)  := ""
                (F5M_VLVATO) := (B_VLIMP1)
                (F5M_BSVATO) := (B_BSIMP1)
                (F5M_RTORIG) := 0
                (F5M_VLORIG) := 0
                (B_CHECK)    := .F.
                (B_CODREQ)   := ""
                (B_IDF4A)    := ""
            ElseIf cGr == "F4B"
                (B_CHECK)    := .F.
                &(cGr+"_CHECK")  := (B_CHECK)
                &(cGr+"_PREFIX") := (B_PREFIX)
                &(cGr+"_NUM")    := (B_NUM)
                &(cGr+"_PARCEL") := (B_PARCEL)
                &(cGr+"_TYPE")   := (B_TYPE)
                &(cGr+"_CLASS")  := (B_CLASS)
                &(cGr+"_EMISS")  := (B_EMISS)
                &(cGr+"_REALMT") := (B_REALMT)
                &(cGr+"_VALUE")  := (B_VALUE)
                &(cGr+"_CURREN") := (B_CURREN)
                &(cGr+"_CONUNI") := (B_CONUNI)
                &(cGr+"_VLCRUZ") := (B_VLCRUZ)
                &(cGr+"_OPBAL")  := (B_OPBAL)
                &(cGr+"_BSIMP1") := (B_BSIMP1)
                &(cGr+"_ALIMP1") := (B_ALIMP1)
                &(cGr+"_VLIMP1") := (B_VLIMP1)
                &(cGr+"_MDCNTR") := (B_MDCNTR)
                &(cGr+"_FLORIG") := (B_FLORIG)
                (B_CODREQ)   := ""
                &(cGr+"_CODREQ") := (B_CODREQ)
                // we generate IDF4A because unique key
                // for F4B is: F4B_FILIAL+F4B_IDF4A+F4B_PREFIX+F4B_NUM+F4B_PARCEL+F4B_TYPE
                // so this IDF4A will not relate to real payment request
                (B_IDF4A)      := FWUUIDV4()
                &(cGr+"_IDF4A") := (B_IDF4A)
            ElseIf cGr == "F48"
                &(cGr+"_FILIAL") := xFilial("F48")
                &(cGr+"_UUID"  ) := FWUUIDV4()
                &(cGr+"_IDF48" ) := oModel:GetValue("F47_IDF47")
                &(cGr+"_VALREQ") := (BALANCE)
                &(cGr+"_OPBAL")  := (BALANCE)
                &(cGr+"_VALUE")  := (VALOR)
                &(cGr+"_VLCRUZ") := (VLCRUZ)
                &(cGr+"_VLIMP1") := (VALIMP1)-(VLVATOBF)-(VLVATPST)
                &(cGr+"_BSIMP1") := &(cGr+"_VALREQ") - &(cGr+"_VLIMP1")
                aTmp := RU06XFUN81_RetCnvValues(&(cGr+"_VALREQ"),&(cGr+"_VLIMP1"),&(cGr+"_EXGRAT"),aFields[ASCAN(aFields,{|x| x[1] = cGr+"_VALCNV"})][4])
                &(cGr+"_VALCNV") := aTmp[1]
                &(cGr+"_VLVATC") := aTmp[2]
                &(cGr+"_BSVATC") := aTmp[3]
                &(cGr+"_ALIMP1") := (ALQIMP1)
            EndIf
            &(cGr+"_RATUSR") := "0"
            IIF(FieldPos("B_RATUSR") > 0,(B_RATUSR):= &(cGr+"_RATUSR"), Nil)
            MSUnlock()
            DBSkip()
        EndDo
    Else
        cErrMsg := "TCSqlError() "+TCSqlError()
    EndIf
    RestArea(aArea)
    aRet := {oTmpRet, cErrMsg}
Return (aRet) /*------------------------------------------------RU06XFUN45_RetF5MnVrtLnsFromAPs*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN46_CheckPO

Function for checking payment order existance by next fields F49_PAYORD and F49_IDF49

@param       Character        cF49_PAYORD
             Character        cF49_IDF49
@return      Logical          lRet
@example     
@author      astepanov
@since       July/23/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN46_CheckPO(cF49_PAYORD, cF49_IDF49)

    Local   lRet        As Logical
    Local   cQuery      As Character
    Local   cAlias      As Character
    Local   aArea       As Array
    Default cF49_PAYORD := ""
    Default cF49_IDF49  := "" 

    lRet := .F.
    cF49_PAYORD := PADR(cF49_PAYORD,GetSX3Cache("F49_PAYORD","X3_TAMANHO"), " ")
    cF49_IDF49  := PADR(cF49_IDF49 ,GetSX3Cache("F49_IDF49" ,"X3_TAMANHO"), " ")
    cQuery := " SELECT *                                                    "
    cQuery += " FROM " + RetSQLName("F49") + "  F49                         "
    cQuery += " WHERE                                                       "
    cQuery += "      F49.F49_FILIAL = '"   +  xFilial("F49") + "'           "
    cQuery += "  AND F49.F49_IDF49  = '"   +   cF49_IDF49    + "'           "
    cQuery += "  AND F49.F49_PAYORD = '"   +   cF49_PAYORD   + "'           "
    cQuery += "  AND F49.D_E_L_E_T_ = ' '                                   "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    aArea  := GetArea()
    DBSelectArea(cAlias)
    DBGoTop()
    If !EoF()
        lRet := .T.
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
Return (lRet) /*--------------------------------------------------------RU06XFUN46_CheckPO*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN47_CreateTmpTab1

<Short description>

@param       <Parameter type> <Parameter name>
@return      Logical          lRet
@example     
@author      astepanov
@since       July/24/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN47_CreateTmpTab1(lInflow as Logical)

    Local aRet       As Array
    Local aFieldList As Array
    Local aFields    As Array
    Local cAlias     As Character
    Local oTempTable As Object
    Local nX         As Numeric
    Local nAddSE2KLn As Numeric

    Default lInflow := .F.
    aRet := {}

    cAlias     := CriaTrab(, .F.)
    oTempTable := FWTemporaryTable():New(cAlias)
    nAddSE2KLn := RU06XFUN44_RetSE2FldsPosInFMKey(lInflow)[8][5]
    If lInflow
        aFieldList := {"E1_OK"  , "E1_FILIAL" , "E1_PREFIXO", "E1_F5QCODE",;
                    "E1_NUM"    , "E1_PARCELA", "E1_TIPO"   , "E1_EMISSAO",;
                    "E1_VENCREA", "CTO_MOEDA" , "E1_CONUNI" , "E1_VALOR"  ,;
                    "E1_BALANCE", "E1_CLIENTE", "E1_LOJA"   , "ADDSE1KEYC",;
                    "E1_MOEDA"  , "E1_VALIMP1", "E1_NATUREZ", "E1_VLCRUZ" ,;
                    "E1_ALQIMP1", "E1_F5QUID" , "F5Q_DESCR" , "F5M_CTRBAL",;
                    "F5Q_CODE"  , "E1CUDIGTL" , "F5M_FILIAL", "BSVATOBF"  ,;
                    "VLVATOBF"  , "E1_BASIMP1", "VLVATPST"  , "E1_BCOCLI"  }
    Else
        aFieldList := {"E2_OK"  , "E2_FILIAL" , "E2_PREFIXO", "E2_F5QCODE",;
                    "E2_NUM"    , "E2_PARCELA", "E2_TIPO"   , "E2_EMISSAO",;
                    "E2_VENCREA", "CTO_MOEDA" , "E2_CONUNI" , "E2_VALOR"  ,;
                    "E2_BALANCE", "E2_FORNECE", "E2_LOJA"   , "ADDSE2KEYC",;
                    "E2_MOEDA"  , "E2_VALIMP1", "E2_NATUREZ", "E2_VLCRUZ" ,;
                    "E2_ALQIMP1", "E2_F5QUID" , "F5Q_DESCR" , "F5M_CTRBAL",;
                    "F5Q_CODE"  , "E2CUDIGTL" , "F5M_FILIAL", "BSVATOBF"  ,;
                    "VLVATOBF"  , "E2_BASIMP1", "VLVATPST"  , "E2_FORBCO"  }
    EndIf
    // aFields: {{"field name", "x3_tipo"   , "x3_tamanho", "x3_decimal",;
    //            "x3_picture", "RetTitle()"                            }}
    aFields := {}
    For nX  := 1 To Len(aFieldList)
        If     aFieldList[nX] $ "E1_OK|E2_OK"
            AADD(aFields, {aFieldList[nX], "C", 1, 00, "", ""       })
        ElseIf aFieldList[nX] $ "E1_CONUNI|E2_CONUNI"
            AADD(aFields, {aFieldList[nX], "C", 3, 00, "",;
                           RetTitle(Iif(lInflow,"E1_CONUNI","E2_CONUNI"))                    })
        ElseIf aFieldList[nX] $ "E1_BALANCE|E2_BALANCE"
            AADD(aFields, {aFieldList[nX],;
                           GetSX3Cache(Iif(lInflow,"E1_VALOR","E2_VALOR" )     ,"X3_TIPO"   ),;
                           GetSX3Cache(Iif(lInflow,"E1_VALOR","E2_VALOR" )     ,"X3_TAMANHO"),;
                           GetSX3Cache(Iif(lInflow,"E1_VALOR","E2_VALOR" )     ,"X3_DECIMAL"),;
                           GetSX3Cache(Iif(lInflow,"E1_VALOR","E2_VALOR" )     ,"X3_PICTURE"),;
                           STR0020                                  })
        ElseIf aFieldList[nX] $ "ADDSE1KEYC|ADDSE2KEYC"
            AADD(aFields, {aFieldList[nX],"C",nAddSE2KLn,00,"",""   })
        ElseIf aFieldList[nX] == "BSVATOBF"
             AADD(aFields, {aFieldList[nX],;
                           GetSX3Cache("F5M_BSVATO"   ,"X3_TIPO"   ),;
                           GetSX3Cache("F5M_BSVATO"   ,"X3_TAMANHO"),;
                           GetSX3Cache("F5M_BSVATO"   ,"X3_DECIMAL"),;
                           GetSX3Cache("F5M_BSVATO"   ,"X3_PICTURE"),;
                           RetTitle("F5M_BSVATO")                   })
        ElseIf aFieldList[nX] == "VLVATOBF" .OR.;
               aFieldList[nX] == "VLVATPST"
             AADD(aFields, {aFieldList[nX],;
                           GetSX3Cache("F5M_VLVATO"   ,"X3_TIPO"   ),;
                           GetSX3Cache("F5M_VLVATO"   ,"X3_TAMANHO"),;
                           GetSX3Cache("F5M_VLVATO"   ,"X3_DECIMAL"),;
                           GetSX3Cache("F5M_VLVATO"   ,"X3_PICTURE"),;
                           RetTitle("F5M_VLVATO")                   })
        ElseIf aFieldList[nX] $ "E1CUDIGTL|E2CUDIGTL"
            AADD(aFields, {aFieldList[nX],;
                           GetSX3Cache("E2_CONUNI"    ,"X3_TIPO"   ),;
                           GetSX3Cache("E2_CONUNI"    ,"X3_TAMANHO"),;
                           GetSX3Cache("E2_CONUNI"    ,"X3_DECIMAL"),;
                           GetSX3Cache("E2_CONUNI"    ,"X3_PICTURE"),;
                           RetTitle("E2_CONUNI")                    })
        Else  
            AADD(aFields, {aFieldList[nX],;
                           GetSX3Cache(aFieldList[nX] ,"X3_TIPO"   ),;
                           GetSX3Cache(aFieldList[nX] ,"X3_TAMANHO"),;
                           GetSX3Cache(aFieldList[nX] ,"X3_DECIMAL"),;
                           GetSX3Cache(aFieldList[nX] ,"X3_PICTURE"),;
                           RetTitle(aFieldList[nX])                 })
        EndIf 
    Next nX
    oTempTable:SetFields(aFields)
    If lInflow
            oTempTable:AddIndex(cAlias+"1", {"E1_FILIAL", "E1_VENCREA"} )
            oTempTable:AddIndex(cAlias+"2", {"E1_FILIAL", "E1_PREFIXO",;
                                        "E1_NUM"   , "E1_PARCELA",;
                                        "E1_TIPO"}                 )
    Else
        oTempTable:AddIndex(cAlias+"1", {"E2_FILIAL", "E2_VENCREA"} )
        oTempTable:AddIndex(cAlias+"2", {"E2_FILIAL", "E2_PREFIXO",;
                                        "E2_NUM"   , "E2_PARCELA",;
                                        "E2_TIPO"}                 )
    EndIf
    oTempTable:Create()
    aRet := {oTempTable,aFields}

Return (aRet) /*--------------------------------------------------RU06XFUN47_CreateTmpTab1*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN48_RetExchRatesTempTabForAddingNewF5MlineToOutBS

Returns alias to table with structure:
[AP_MOEDA]---[ERCNYS]-[ERCNNO]-[ERQVMD]-[CRUZMD]

@param       Array          aMoedas     // array with currencies like numerics
             Date           dExRatDate  // exchange rates on this date
@return      Object         oTmpMds     // temprary table with different exchange rates
                                        // for the list of currencies
@example     [AP_MOEDA]---[ERCNYS]-[ERCNNO]-[ERQVMD]-[CRUZMD]
                2          72.3645    1.36     1      72.3645   ... so on
@author      astepanov
@since       July/25/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN48_RetExchRatesTempTabForAddingNewF5MlineToOutBS(aMoedas,;
                                                                  dExRatDate,nMoedaHdr)

    Local   oTmpMds    As Object
    Local   cTmpMds    As Character
    Local   nX         As Numeric
    Local   nCnt       As Numeric 
    Local   aFields    As Array
    Local   aArea      As Array
    Default aMoedas    := {}
    Default dExRatDate := dDataBase
    Default nMoedaHdr  := 1

    cTmpMds   := CriaTrab(, .F.)
    oTmpMds   := FWTemporaryTable():New(cTmpMds)
    aFields   := {}
    AADD(aFields, {"AP_MOEDA",;
                   GetSX3Cache("E2_MOEDA"  , "X3_TIPO"   ),;
                   GetSX3Cache("E2_MOEDA"  , "X3_TAMANHO"),;
                   GetSX3Cache("E2_MOEDA"  , "X3_DECIMAL") })
    AADD(aFields, {"ERCNYS",; // exgrat when conuni = yes
                   GetSX3Cache("F5M_EXGRAT", "X3_TIPO"   ),;
                   GetSX3Cache("F5M_EXGRAT", "X3_TAMANHO"),;
                   GetSX3Cache("F5M_EXGRAT", "X3_DECIMAL") })
    AADD(aFields, {"ERCNNO",; // exgrat when conuni  = no, 
                            ; // but currencies are different,
                            ; // crossrate 
                   GetSX3Cache("F5M_EXGRAT", "X3_TIPO"   ),;
                   GetSX3Cache("F5M_EXGRAT", "X3_TAMANHO"),;
                   GetSX3Cache("F5M_EXGRAT", "X3_DECIMAL") })
    AADD(aFields, {"ERQVMD",; // exgrat when moedas equals
                   GetSX3Cache("F5M_EXGRAT", "X3_TIPO"   ),;
                   GetSX3Cache("F5M_EXGRAT", "X3_TAMANHO"),;
                   GetSX3Cache("F5M_EXGRAT", "X3_DECIMAL") })
    AADD(aFields, {"CRUZMD",; // exrate for calculating VALCRUZ
                   GetSX3Cache("F5M_EXGRAT", "X3_TIPO"   ),;
                   GetSX3Cache("F5M_EXGRAT", "X3_TAMANHO"),;
                   GetSX3Cache("F5M_EXGRAT", "X3_DECIMAL") }) 
    oTmpMds:SetFields(aFields)
    oTmpMds:AddIndex(cTmpMds+"01",{"AP_MOEDA"})
    oTmpMds:Create()
    aArea := GetArea()
    If Empty(aMoedas)
        // add moedas
        AADD(aMoedas,1)
        nCnt := MoedFin()
        If nCnt > 1
            For nX := 2 To nCnt
                AADD(aMoedas,nX)
            Next nX
        EndIf
    EndIf
    DBSelectArea(cTmpMds)
    nRnd := GetSX3Cache("F5M_EXGRAT", "X3_DECIMAL")
    For nX := 1 To Len(aMoedas)
        RecLock((cTmpMds), .T.)
        (cTmpMds)->AP_MOEDA := aMoedas[nX]
        (cTmpMds)->ERCNYS   := IIf(RecMoeda(dExRatDate,aMoedas[nX]) == 0, 1,;
                                   RecMoeda(dExRatDate,aMoedas[nX])         )
        (cTmpMds)->ERCNNO   := IIf(xMoeda(1,aMoedas[nX],;
                                          nMoedaHdr    ,;
                                          dExRatDate   ,;
                                          nRnd          ) == 0, 1,;
                                   xMoeda(1,aMoedas[nX],;
                                          nMoedaHdr    ,;
                                          dExRatDate   ,;
                                          nRnd          )         )
        (cTmpMds)->ERQVMD   := 1
        (cTmpMds)->CRUZMD   := IIf(xMoeda(1,aMoedas[nX],;
                                          1            ,;
                                          dExRatDate   ,;
                                          nRnd          ) == 0, 1,;
                                   xMoeda(1,aMoedas[nX],;
                                          1            ,;
                                          dExRatDate   ,;
                                          nRnd          )         )
        (cTmpMds)->(MsUnlock())
    Next nX
    RestArea(aArea)
Return (oTmpMds) /*---------------RU06XFUN48_RetExchRatesTempTabForAddingNewF5MlineToOutBS*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN49_CheckF4CUUIDRE

Function called from RU06D0731_ViewFPost
If lRevers == .F.
We check existanse bankstatement with F4C_CUUID which equals F4C_UUIDRE
If lRevers == .T.
We check existanse bankstatement with F4C_UUIDRE which equals F4C_CUUID
If it exist .T.  - will be returned, if it is not exist .F. will be returned

If lData == .T. will be returned F4C_CUUID or ""

@param       Character        cKey //F4C_CUUID or F4C_UUIDRE
             Logical          LRevers
@return      Logical          lRet
@example     
@author      astepanov
@since       August/06/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN49_CheckF4CUUIDRE(cKey, lRevers, lData)

    Local lRet       As Logical
    Local cQuery     As Character
    Local cAlias     As Character
    Local cF4C_CUUID As Character
    Local aArea      As Array
    Local xRet

    Default lRevers  := .F.
    Default lData    := .F.

    lRet := .T.
    cKey := PADR(cKey ,GetSX3Cache("F4C_CUUID", "X3_TAMANHO"), " ")
    cF4C_CUUID := ""
    cQuery := " SELECT                                  "
    cQuery += "        F4C_CUUID                        "
    cQuery += " FROM  "+RetSQLName("F4C")+"             "
    cQuery += " WHERE F4C_FILIAL = '"+xFilial("F4C")+"' "
    If lRevers
        cQuery += "   AND F4C_UUIDRE = '" +  cKey + "'  "
    Else
        cQuery += "   AND F4C_CUUID  = '" +  cKey + "'  "
    EndIf
    cQuery += "   AND D_E_L_E_T_ = ' '                  "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    aArea := GetArea()
    DBSelectArea(cAlias)
    DBGoTop()
    If Eof()
        lRet := .F.
    Else
        lRet := .T.
        cF4C_CUUID := PADR((cAlias)->F4C_CUUID,;
                      GetSX3Cache("F4C_CUUID", "X3_TAMANHO"), " ")
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    xRet := lRet
    If lData
        xRet := cF4C_CUUID
    EndIf

Return (xRet) /*------------------------------------------------RU06XFUN49_CheckF4CUUIDRE*/

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN50_RetVATSaldoValues
Function used for get VAT realted values for last part of AP added to BAnk statement
@param       Object           oVrtModel,
             Object           oHdrModel,
@return      Array            aRet array with next values {B_OPBAL,B_VLIMP1}
@example     
@author      astepanov
@since       November/13/2019
@edit        April/05/2021
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------------/*/
Function RU06XFUN50_RetVATSaldoValues(oVrtModel,oHdrModel)

    Local   aRet      As Array
    Local   cFil      As Character
    Local   cPrefixo  As Character
    Local   cNum      As Character
    Local   cParcela  As Character
    Local   cTipo     As Character
    Local   cFornece  As Character
    Local   cLoja     As Character
    Local   cF5MKey   As Character
    Local   cF5MkLen  As Character
    Local   cAlias    As Character
    Local   cQuery    As Character
    Local   cF4CCUUID As Character
    Local   cPr       As Character
    Local   cE        As Character
    Local   cForCli   As Character
    Local   cTab      As Character
    Local   lInflow   As Logical

    aRet     := {}

    lInflow   := (oHdrModel:GetValue("F4C_OPER") == "1")
    cFil      := PADR(oVrtModel:GetValue("B_FLORIG"),GetSX3Cache(IIf(lInflow,"E1_FILIAL" ,"E2_FILIAL") ,"X3_TAMANHO")," ")
	cPrefixo  := PADR(oVrtModel:GetValue("B_PREFIX"),GetSX3Cache(IIf(lInflow,"E1_PREFIXO","E2_PREFIXO"),"X3_TAMANHO")," ")
	cNum      := PADR(oVrtModel:GetValue("B_NUM"   ),GetSX3Cache(IIf(lInflow,"E1_NUM"    ,"E2_NUM")    ,"X3_TAMANHO")," ")
	cParcela  := PADR(oVrtModel:GetValue("B_PARCEL"),GetSX3Cache(IIf(lInflow,"E1_PARCELA","E2_PARCELA"),"X3_TAMANHO")," ")
	cTipo     := PADR(oVrtModel:GetValue("B_TYPE"  ),GetSX3Cache(IIf(lInflow,"E1_TIPO"   ,"E2_TIPO")   ,"X3_TAMANHO")," ")
	cFornece  := PADR(Iif(lInflow, oHdrModel:GetValue("F4C_CUST"),oHdrModel:GetValue("F4C_SUPP")),;
                      GetSX3Cache(IIf(lInflow,"E1_CLIENTE","E2_FORNECE"),"X3_TAMANHO")," "        )
	cLoja     := PADR(Iif(lInflow, oHdrModel:GetValue("F4C_CUNI"),oHdrModel:GetValue("F4C_UNIT")),;
                      GetSX3Cache(IIf(lInflow,"E1_LOJA","E2_LOJA")  ,"X3_TAMANHO")," "            )
    cF5MKey   := cFil+"|"+cPrefixo+"|"+cNum+"|"+cParcela+"|"+cTipo+"|"+cFornece+"|"+cLoja
    cF5MkLen  := cValToChar(Len(cF5MKey))
    cF4CCUUID := IIF(Empty(oHdrModel:GetValue("F4C_CUUID")),"",oHdrModel:GetValue("F4C_CUUID"))
    cPr       := IIF(lInflow, "SE1.E1_", "SE2.E2_")
    cE        := IIF(lInflow, "E1_"    , "E2_")
    cForCli   := IIF(lInflow, "E1_CLIENTE", "E2_FORNECE")
    cTab      := IIF(lInflow, "SE1", "SE2")
    cQuery := " SELECT                                                                           "
    cQuery += cPr+"SALDO - COALESCE(TMP.VALUEBEF,0)                                    B_OPBAL  ,"
    cQuery += cPr+"VALIMP1 -  COALESCE(TMP.VLVATOBF,0) - COALESCE(PST.VLVATPST,0)      B_VLIMP1  "
    cQuery += " FROM                                                                             "
    cQuery += "       (SELECT "+cE+"SALDO  ,                                                     "
    cQuery += "               "+cE+"VALIMP1,                                                     "
    cQuery += "               "+cE+"BASIMP1,                                                     "
    cQuery += "               "+cE+"VLCRUZ ,                                                     "
    cQuery += "               "+cE+"FILIAL, "+cE+"PREFIXO, "+cE+"NUM, "+cE+"PARCELA, "+cE+"TIPO, "
    cQuery += "               "+cForCli+",  "+cE+"LOJA                                           "
    cQuery += "        FROM  " + RetSQLName(cTab)   +"                                           "
    cQuery += "        WHERE "+cE+"FILIAL  = '"+cFil    +"'                                      "
    cQuery += "          AND "+cE+"PREFIXO = '"+cPrefixo+"'                                      "
    cQuery += "          AND "+cE+"NUM     = '"+cNum    +"'                                      "
    cQuery += "          AND "+cE+"PARCELA = '"+cParcela+"'                                      "
    cQuery += "          AND "+cE+"TIPO    = '"+cTipo   +"'                                      "
    cQuery += "          AND "+cForCli+"   = '"+cFornece+"'                                      "
    cQuery += "          AND "+cE+"LOJA    = '"+cLoja   +"'                                      "
    cQuery += "          AND D_E_L_E_T_ = ' ' )                              "+cTab+"            "
    cQuery += " LEFT JOIN                                                                        "
    cQuery += "       ( SELECT                                                                   "
    cQuery += "                GRP.F5M_KEY           F5M_KEY,                                    "
    cQuery += "                SUM(GRP.F5M_VALPAY)   VALUEBEF,                                   "
    cQuery += "                SUM(GRP.F5M_VLVATO)   VLVATOBF                                    "
    cQuery += "         FROM                                                                     "
    cQuery += "              ( SELECT                                                            "
    cQuery += "                       CAST(F5M_KEY AS CHAR("+cF5MkLen+")) F5M_KEY,               "
    cQuery += "                                                       F5M_VALPAY,                "
    cQuery += "                                                       F5M_VLVATO                 "
    cQuery += "                FROM " + RetSQLName("F5M") + "                                    "
    cQuery += "                WHERE F5M_CTRBAL = '1'                                            "
    cQuery += "                AND TRIM(SUBSTRING(F5M_KEY,"+"1"+","+cF5MkLen+")) = '"+cF5MKey+"' "
    cQuery += "                AND F5M_IDDOC <> '"+cF4CCUUID+"'                                  "
    cQuery += "                AND D_E_L_E_T_ = ' ') GRP                                         "
    cQuery += "                GROUP BY GRP.F5M_KEY)                         TMP                 "
    cQuery += "        ON ( "  + RU06XFUN09_RetSE2F5MJoinOnString("TMP",lInflow) + ")            "
    cQuery += " LEFT JOIN                                                                        "
    cQuery += "       ( SELECT                                                                   "
    cQuery += "                GRP.F5M_KEY           F5M_KEY,                                    "
    cQuery += "                SUM(GRP.F5M_VLVATO)   VLVATPST                                    "
    cQuery += "         FROM                                                                     "
    cQuery += "              ( SELECT                                                            "
    cQuery += "                       CAST(F5M_KEY AS CHAR("+cF5MkLen+")) F5M_KEY,               "
    cQuery += "                                                       F5M_VLVATO,                "
    cQuery += "                                                       F5M_IDDOC                  "
    cQuery += "                FROM " + RetSQLName("F5M") + "                                    "
    cQuery += "                WHERE F5M_CTRBAL = '2'                                            "
    cQuery += "                AND TRIM(SUBSTRING(F5M_KEY,"+"1"+","+cF5MkLen+")) = '"+cF5MKey+"' "
    cQuery += "                AND F5M_ALIAS  = 'F4C'                                            "
    cQuery += "                AND D_E_L_E_T_ = ' '                                              "
    cQuery += "                                    ) GRP                                         "
    cQuery += "         INNER JOIN                                                               "
    cQuery += "              ( SELECT *                                                          "
    cQuery += "                FROM " + RetSqlName("F4C") + "                                    "
    cQuery += "                WHERE (F4C_STATUS = '2' OR F4C_STATUS = '5')                      "
    cQuery += "                AND D_E_L_E_T_ = ' '                                              " 
    cQuery += "                                    ) F4C                                         "
    cQuery += "              ON (F4C.F4C_CUUID = GRP.F5M_IDDOC)                                  "                 
    cQuery += "         GROUP BY GRP.F5M_KEY)                                PST                 "
    cQuery += "        ON ( "  + RU06XFUN09_RetSE2F5MJoinOnString("PST",lInflow) + ")            "
    cQuery := ChangeQuery(cQuery)
    aArea  := GetArea()
    cAlias := MPSysOpenQuery(cQuery)
    TCSetField(cAlias,"B_OPBAL" ,"N",GetSx3Cache("E2_SALDO"  ,"X3_TAMANHO"),GetSx3Cache("E2_SALDO"  ,"X3_DECIMAL"))
    TCSetField(cAlias,"B_VLIMP1","N",GetSx3Cache("E2_VALIMP1","X3_TAMANHO"),GetSx3Cache("E2_VALIMP1","X3_DECIMAL"))
    DBSelectArea(cAlias)
    DBGoTop()
    //shuld be returned 1 line, if no - it is error in data
    While !EoF()
        AADD(aRet,(cAlias)->B_OPBAL )
        AADD(aRet,(cAlias)->B_VLIMP1)
        DBSkip()
    EndDo
    (cAlias)->(DBCloseArea())
    RestArea(aArea)

Return (aRet) /*----------------------------------------------------RU06XFUN50_RetVATSaldoValues*/


//------------------------------------------------------------------------------------------








        


/*/{Protheus.doc} RU06XFUN52_CTBF4C

This function called from CTBFINProc() and used for automatic offline accounting posting
for bank statements

@param       nShwPst  - Show Postings? 1- Yes, 2- No. Related to private var in RU06D07RUS
                        lDigita (.T. - dispaly entries, .F. - not display)                        
             dDatFrm  - Date Started, From Date
             dDatEnd  - End Date, To Date
@public      cFilAnt  - Current branch, for which we make postings in accounting
@return      Logical          lRet
@example     
@author      astepanov
@since       November/06/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN52_CTBF4C(nShwPst,dDatFrm,dDatEnd)

    Local lRet       As Logical
    Local cSFINPOS   As Character
    Local cSREPLPS   As Character
    Local cQuery     As Character
    Local cAlias     As Character
    Local aArea      As Array
    Local aAreaF4C   As Array
    Local aTmpArea   As Array
    Local lTmpGerLn  As Logical
    Local lTmpDigit  As Logical

    Default nShwPst := 1
    Default dDatFrm := dDataBase
    Default dDatEnd := dDataBase

    lRet := .T.
    
    //check private vars and create temporary store for them
    //if lGeraLanc == .T. we create accounting postings
    //so, for our case it should be always .T.
    //if lDigita == .T. - we show accounting postings
    //if lDigita == .F. - we don't show accounting postings
    If Type("lGeraLanc") == "L"
        lTmpGerLn := lGeraLanc
        lGeraLanc := .T.
    Else
        Private lGeraLanc := .T.
        lTmpGerLn := lGeraLanc
    EndIf
    If Type("lDigita") == "L"
        lTmpDigit := lDigita
        lDigita   := IIf(nShwPst == 1,.T.,.F.)
    Else
        Private lDigita := IIf(nShwPst == 1,.T.,.F.)
        lTmpDigit := lDigita
    EndIf

    cSFINPOS :=  "2" // status: posted in finance
    cSREPLPS :=  "5" // replacement posted in finance

    //select  outflow bank statements unposted in accounting which
    //posted in finance . We select unposted BS lines because:
    //1: if BS header is posted in accounting (F4C_LA == "S") according
    //   to current specification writeoffs and PA lines which related to
    //   this BS line should be posted in accounting too. We cannot post separate
    //   BS header and BS line. If it will be changed in future, 
    //   so we should also select F4C_LA == "S" too and change if condition
    //   below.
    //2: For BS reversal F4C_LA=="S" and for reverasal in finance we also
    //   have postings in accounting. So according to specification
    //   reversed BS line always posted in accounting.
    cQuery := " SELECT R_E_C_N_O_,                        "
    cQuery += "        F4C_DTTRAN,                        "
    cQuery += "        F4C_INTNUM                         "
    cQuery += " FROM " + RetSQLName("F4C") + "            "
    cQuery += " WHERE  F4C_FILIAL = '" + cFilAnt + "'     "
    cQuery += "   AND  F4C_DTTRAN BETWEEN                 "
    cQuery += "                   '" + DTOS(dDatFrm) + "' "
    cQuery += "                   AND                     "
    cQuery += "                   '" + DTOS(dDatEnd) + "' "
    cQuery += "   AND (F4C_STATUS = '" + cSFINPOS +    "' "
    cQuery += "        OR                                 "
    cQuery += "        F4C_STATUS = '" + cSREPLPS +    "')" 
    cQuery += "   AND  F4C_LA    <> 'S'                   "
    cQuery += "   AND  D_E_L_E_T_ = ' '                   "
    cQuery += " ORDER BY F4C_DTTRAN, F4C_INTNUM ASC       "
    cQuery   := ChangeQuery(cQuery)
    cAlias   := MPSysOpenQuery(cQuery)
    aArea    := GetArea()
    aAreaF4C := F4C->(GetArea())
    DBSelectArea(cAlias)
    DBGoTop()
    While lRet .AND. !EoF()
        aTmpArea := GetArea()
        DbSelectArea("F4C")
        DBGoTo((cAlias)->(R_E_C_N_O_))
        //lock F4C record
        If RecLock("F4C",.F.)
            If !(F4C->F4C_LA == "S") .AND.;
                (F4C->F4C_STATUS == cSFINPOS .OR.;
                 F4C->F4C_STATUS == cSREPLPS     )
               //so we postioned on correct F4C record it is locked
               //for changes, so run posting function:
               lRet := lRet .AND. RU06D07009_PostInAccounting(.F.)
            EndIf
            F4C->(MSUnlock())
        Else
            lRet := .F. // stop postings, we can't lock F4C record
        EndIf
        RestArea(aTmpArea)
        DBSkip()
    EndDo
    (cAlias)->(DBCloseArea())
    RestArea(aAreaF4C)
    RestArea(aArea)

    //restore private vars values if we need it:
    If Type("lGeraLanc") == "L"
        lGeraLanc := lTmpGerLn
    EndIf
    If Type("lDigita") == "L"
        lDigita   := lTmpDigit
    EndIf
    
Return (lRet) /*---------------------------------------------------------RU06XFUN52_CTBF4C*/

/*/{Protheus.doc} RU06XFUN53_LegendForQuery()
Makes legend in finc040 and finc050: Query menu - Other actions - Legend button
@author Alexander Ivanov
@since 28/11/2019
@project     MA3
@version 12.1.25
/*/
Function RU06XFUN53_LegendForQuery(cOperation)
    Local aLegenda as Array
    Local lShowLgnd as Logical
    aLegenda := {}
    lShowLgnd := .T.

    aadd(aLegenda, {"BR_VERDE",   STR0024})
    aadd(aLegenda, {"DISABLE",    STR0025})

    If cOperation == "AP"
        aadd(aLegenda, {"BR_BRANCO",  STR0026})

    ElseIf cOperation == "AR"  
        aadd(aLegenda, {"BR_AMARELO", STR0028})

    Else
        Help(STR0029)
        lShowLgnd := .F.  
    EndIf

    aadd(aLegenda, {"BR_PRETO", STR0057})
    If lShowLgnd
        BrwLegenda(STR0027, STR0027, aLegenda)
    EndIf
Return

/*/{Protheus.doc} RU06XFUN53_LegendForQuery()
Retunr The recno related to the cancelation of the writeoff moviment. 
@author Eduardo.Flima
@since 17/21/2019
@project     MA3
@version 12.1.25
/*/
Function RU06XFUN54_RetFk2Canc(cIdOrig)
    Local cQuery    As Character
    Local cAlias    As Character
    Local aSaveArea As Array
    Local nRet      As Numeric
    
    aSaveArea  := GetArea()
    cQuery:=""
    cAlias:=""

    cQuery:= "SELECT R_E_C_N_O_ "
    cQuery += " FROM "      + RetSQLName("FK2") +" "  
    cQuery += " WHERE  fk2_iddoc = ( "
    cQuery += " SELECT fk2_iddoc  "
    cQuery += " FROM "      + RetSQLName("FK2") +" "    
    cQuery += " WHERE  fk2_idfk2 = '"+ cIdOrig +"') "    
    cQuery += " AND fk2_tpdoc = 'ES'  "    
    
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    DBSelectArea(cAlias)
    DBGoTop()
    If !Eof()
        nRet := (cAlias)->R_E_C_N_O_
    Else
        nRet := 0
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aSaveArea)
Return nRet
/*/{Protheus.doc} RU06XFUN55_QuerryF5MBalance
Function Used to set the query about the locked balances in F5M used in several functons that need to have access to this
information like RU06XFUN06_GetOpenBalance. It only set the query so the use of this string will be setled in the calling function
it works for SE1\SE2
@author eduardo.flima
@since 18/12/2018
@version 1.1
@Parameter 
cSeXKey: String with key Fields of SE2\SE1 used to find the Specified Register
in the format: EX_FILIAL|EX_PREFIXO|EZ_NUM|EX_PARCELA|EX_TIPO|E2_FORNECE\E1_CLIENTE|EX_LOJA
@Return
cQuery: Character with the String responsible to perform the query and return the values about the balance locked in F5M to the related cSeXKey
cTable: Character with the table we are dealing SE1 or SE2
@project MA3 - Russia
/*/

Function RU06XFUN55_QuerryF5MBalance(cSeXKey,cTable)
    Local aSeXKey   As Array
	Local cPrefix 	As Character
	Local cQryprfix	As Character
	
	Default cTable:="SE2"
	
	cPrefix:= REPLACE(cTable,"S","")
	cQryprfix:= cTable+"."+cPrefix
	
    aSeXKey   := StrTokArr(cSeXKey, "|") 
    cQuery := " SELECT                                                         "
    cQuery += "      "+cQryprfix+"_SALDO SALDOSEX,                             "
    cQuery += "      0            TOTALF5M                                     "
    cQuery += " FROM "      + RetSQLName(cTable) + " "+ cTable
    cQuery += " WHERE "+cQryprfix+"_FILIAL  = '"+ PADR(AllTrim(aSeXKey[1]),GetSX3Cache(cPrefix+"_FILIAL" ,"X3_TAMANHO"),' ') + "'"
    cQuery += "   AND "+cQryprfix+"_PREFIXO = '"+ PADR(AllTrim(aSeXKey[2]),GetSX3Cache(cPrefix+"_PREFIXO","X3_TAMANHO"),' ') + "'"
    cQuery += "   AND "+cQryprfix+"_NUM     = '"+ PADR(AllTrim(aSeXKey[3]),GetSX3Cache(cPrefix+"_NUM"    ,"X3_TAMANHO"),' ') + "'"
    cQuery += "   AND "+cQryprfix+"_PARCELA = '"+ PADR(AllTrim(aSeXKey[4]),GetSX3Cache(cPrefix+"_PARCELA","X3_TAMANHO"),' ') + "'"
    cQuery += "   AND "+cQryprfix+"_TIPO    = '"+ PADR(AllTrim(aSeXKey[5]),GetSX3Cache(cPrefix+"_TIPO"   ,"X3_TAMANHO"),' ') + "'"
	If cTable =="SE2"
		cQuery += "   AND "+cQryprfix+"_FORNECE = '"+ PADR(AllTrim(aSeXKey[6]),GetSX3Cache(cPrefix+"_FORNECE","X3_TAMANHO"),' ') + "'"
	ElseIf cTable =="SE1"
		cQuery += "   AND "+cQryprfix+"_CLIENTE = '"+ PADR(AllTrim(aSeXKey[6]),GetSX3Cache(cPrefix+"_CLIENTE","X3_TAMANHO"),' ') + "'"
	EndIf
    cQuery += "   AND "+cQryprfix+"_LOJA    = '"+ PADR(AllTrim(aSeXKey[7]),GetSX3Cache(cPrefix+"_LOJA"   ,"X3_TAMANHO"),' ') + "'"
    cQuery += "   AND "+cTable+".D_E_L_E_T_ = ' '                              "
    cQuery += " UNION                                                          "
    cQuery += " SELECT                                                         "
    cQuery += "       0                   SALDOSEX,                            "
    cQuery += "       SUM(F5M.F5M_VALPAY) TOTALF5M                             "
    cQuery += " FROM "      + RetSQLName("F5M") + " F5M                        "
    cQuery += "           WHERE  F5M.F5M_KEY    = '" + cSeXKey + "'            "
    cQuery += "             AND  F5M.F5M_CTRBAL = '" +   "1"   + "'            "
	If cTable == "SE2"	
		cQuery += "             AND ((F5M.f5m_keyali = '" +   cTable   + "') OR ((F5M.f5m_keyali = '') AND (F5M.f5m_alias IN('F4B','F48'))))"	
	Else
		cQuery += "             AND  F5M.F5M_KEYALI = '" +   cTable   + "'         "	
	EndIf
    cQuery += "             AND  F5M.D_E_L_E_T_ = ' '                          "
    cQuery := " SELECT SUM(SALDOSEX) SALDO, SUM(TOTALF5M) TOTAL FROM ( " +;
            cQuery +;
            " ) RSLT "
    cQuery := ChangeQuery(cQuery)

Return cQuery





/*/{Protheus.doc} RU06XFUN06_GetOpenBalance
Function Used to restore the Open balance of the accounts payable 
Subtracting all the values that is already used in any Bank Statement Process.
@author natalia.khozyainova
@since 27/11/2018
@version 1.1
@edit   astepanov 11 July 2019
@Parameter 
cSe2Key: String with key Fields of SE2 used to find the Specified Register
in the format: E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_FORNECE|E2_LOJA
@Return
nOpBal: Numeric with the Value considering the E2_SALDO- SUM(F5M_VALPAY) to the related cSe2Key
@project MA3 - Russia
/*/
Function RU06XFUN56_GetLockedBalance(cSe2Key,cTable)

    Local nLockBal    As Numeric
    Local cQuery    As Character
    Local cAlias    As Character
    Local aSaveArea As Array

    Default cTable:="SE2"

    aSaveArea := GetArea()
    cQuery:= RU06XFUN55_QuerryF5MBalance(cSe2Key,cTable) // set the querry 
    cAlias := MPSysOpenQuery(cQuery)
    DBSelectArea(cAlias)
    DBGoTop()
    If !Eof()
        nLockBal := (cAlias)->TOTAL
    Else
        nLockBal := 0
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aSaveArea)

Return (nLockBal)

/*/{Protheus.doc} RU06XFUN
Check EA table in SX5
FI-CF-25-5
@author alexander.kharchenko
@since 16.12.2019 
@version 1.0 
@project MA3 - Russia
/*/
Function RU06XFUN57_PutTableEA()

DbSelectArea('SX5')
SX5->(DbSetOrder(1))
Do case
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0048)))
        FWPutSX5(STR0047, STR0055, STR0048, STR0032, STR0032, STR0032, STR0032)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0049)))
        FWPutSX5(STR0047, STR0055, STR0049, STR0033, STR0033, STR0033, STR0033)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0050)))
        FWPutSX5(STR0047, STR0055, STR0050, STR0034, STR0034, STR0034, STR0034)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0051)))
        FWPutSX5(STR0047, STR0055, STR0051, STR0035, STR0035, STR0035, STR0035)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0052)))
        FWPutSX5(STR0047, STR0055, STR0052, STR0036, STR0036, STR0036, STR0036)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0053)))
        FWPutSX5(STR0047, STR0055, STR0053, STR0037, STR0037, STR0037, STR0037)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0054)))
        FWPutSX5(STR0047, STR0055, STR0054, STR0038, STR0038, STR0038, STR0038)
EndCase

Return

/*/{Protheus.doc} RU06XFUN
Check EB table in SX5
FI-CF-25-5
@author alexander.kharchenko
@since 16.12.2019 
@version 1.0 
@project MA3 - Russia
/*/
Function RU06XFUN58_PutTableEB()

DbSelectArea('SX5')
SX5->(DbSetOrder(1))
Do case
    Case(SX5->(Dbseek(xFilial('SX5') + STR0056 + STR0043)))
        FWPutSX5(STR0047, STR0056, STR0043, STR0039, STR0039, STR0039, STR0039)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0056 + STR0044)))
        FWPutSX5(STR0047, STR0056, STR0044, STR0040, STR0040, STR0040, STR0040)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0056 + STR0045)))
        FWPutSX5(STR0047, STR0056, STR0045, STR0041, STR0041, STR0041, STR0041)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0056 + STR0046)))
        FWPutSX5(STR0047, STR0056, STR0046, STR0042, STR0042, STR0042, STR0042)
EndCase

Return
/*/{Protheus.doc} RU06XFUN
Check EB table in SX5
FI-CF-25-5
@author alexander.kharchenko
@since 16.12.2019 
@version 1.0 
@project MA3 - Russia
/*/
Function RU06XFUN60_Calcfk3Rus(cOrdPag,dBaixa,nValBx,cFil,cPrefixo,cNum,cParcela,cTipo,cFornece,cLoja)
    Local aArea         As Array
    Local cQuery        as Character
    Local cAlias        as Character
    Local cF5MKLn       as Character
    Local nVatCalc      as Numeric
    Local nVatBaseC     as Numeric
    Local aImpostos     as Array



    aArea       := GetArea()
    cQuery      := ""
    cAlias      :=""
    nVatCalc    :=0
    nVatBaseC   :=0
    aImpostos   :={}

    If !empty(cOrdPag)
        cFil      := PADR(cFil,GetSX3Cache("E2_FILIAL" ,"X3_TAMANHO")," ")
	    cPrefixo  := PADR(cPrefixo,GetSX3Cache("E2_PREFIXO","X3_TAMANHO")," ")
	    cNum      := PADR(cNum,GetSX3Cache("E2_NUM"    ,"X3_TAMANHO")," ")
	    cParcela  := PADR(cParcela,GetSX3Cache("E2_PARCELA","X3_TAMANHO")," ")
	    cTipo     := PADR(cTipo,GetSX3Cache("E2_TIPO"   ,"X3_TAMANHO")," ")
	    cFornece  := PADR(cFornece,GetSX3Cache("E2_FORNECE","X3_TAMANHO")," ")
	    cLoja     := PADR(cLoja,GetSX3Cache("E2_LOJA"   ,"X3_TAMANHO")," ")
        cF5MKey   := cFil+"|"+cPrefixo+"|"+cNum+"|"+cParcela+"|"+cTipo+"|"+cFornece+"|"+cLoja
        cF5MKLn   := RU06XFUN44_RetSE2FldsPosInFMKey()[8][2]

        cQuery := " SELECT    F5M_BSVATC,                                      "
        cQuery += "       F5M_VLVATC,                                          "
        cQuery += "       F5M_VALPAY                                          "        
        cQuery += " FROM " + RetSQlName("F5M") + " F5M                         "
        cQuery += " WHERE F5M_FILIAL = '"+xFilial("F5M")+"' "
        cQuery += " AND F5M_IDDOC = (SELECT F4C_CUUID                       "
        cQuery += " FROM " + RetSQlName("F4C") + " F4C                         "
        cQuery += " WHERE F4C_FILIAL = '"+xFilial("F4C")+"' "
        cQuery += "   AND F4C_INTNUM = '"+ cOrdPag +"'"                       
        cQuery += "   AND F4C_DTTRAN = '" + DTOS(dBaixa) + "'               "
        cQuery += "   AND F4C.D_E_L_E_T_ = ' '             ) "
        cQuery += "   AND TRIM(SUBSTRING(F5M_KEY,1,"+cF5MKLn+")) = '" + cF5MKey + "' "
        cQuery += " AND F5M.D_E_L_E_T_ = ' '                       "
        cQuery := ChangeQuery(cQuery)
        cAlias := MPSysOpenQuery(cQuery)
        DbSelectArea(cAlias)
        DBGoTop()
        If !EoF()
            nVatCalc := (cAlias)->F5M_VLVATC
            nVatBaseC:= (cAlias)->F5M_BSVATC
            (cAlias)->(DBCloseArea())
        EndIf
        RestArea(aArea)
    Else
        DBSelectArea("SE2")  
        DBSetOrder(1)   // filial+prefixo+num+parcela+tipo+fornece+loja
        If DBSeek(cFil+cPrefixo+cNum+cParcela+cTipo+cFornece+cLoja) // position to record before post
            nVatBaseC:=nValBx			
            nVatCalc:= round((nValBx / SE2->E2_VALOR * SE2->e2_valimp1),2)
        Endif
        RestArea(aArea)
    Endif
	aadd(aImpostos,{"VAT", nVatCalc, "VAT", "", 0, nVatBaseC, , ""})

Return aImpostos

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINXFIN01_BCOFilter (Russian Name)
Filter for BCO query, Russia
@Author	natalia.khozyainova	
@since	15/10/2018
/*/
//-----------------------------------------------------------------------------------------------------
Function FINXFIN001()
Local lRet as Logical
Local cFldMoeda as Character
Local cFldConUni as Character

If alltrim(ReadVar())!= ''
	__cRuPrf:=SUBSTR(ReadVar(),4,AT('_',ReadVar())-4)
EndIf
lRet:=.T.

If __cRuPrf=='E1' .or. __cRuPrf=='E2'
	cFldMoeda:='M->'+__cRuPrf+'_MOEDA'
	cFldConUni:='M->'+__cRuPrf+'_CONUNI'
	lRet:= (SA6->A6_MOEDA == &(cFldMoeda).and. &(cFldConUni)!='1') .or. ( SA6->A6_MOEDA==1 .and. &(cFldConUni)=='1')
ElseIf __cRuPrf=='F47' .or. __cRuPrf=='F49' 
	cFldMoeda:='M->'+__cRuPrf+'_CURREN'
	lRet:= (SA6->A6_MOEDA== VAL(&(cFldMoeda)) ) 
EndIf

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINXFIN002_FILFilter (Russian Name)
    (old: FINXFIN02)
Filter for FIL query, Russia
@Author	natalia.khozyainova	
@since	15/10/2018
/*/
//-----------------------------------------------------------------------------------------------------

Function FINXFIN002_FILFilter()
    Local cRet			as Character
    Local cFldMoeda		as Character
    Local cFldConUni	as Character
    Local cCliFor		as Character
    Local cBranch		as Character

    cRet:="@#@#"
    
    If alltrim(ReadVar())!= ''
        __cRuPrf:=SUBSTR(ReadVar(),4,AT('_',ReadVar())-4)
    EndIf
    If __cRuPrf == "A2"
        cCliFor := M->A2_COD
        cBranch := M->A2_LOJA
        cRet := "@#(FIL_FORNEC = '" + cCliFor + "') .And. (FIL_LOJA == '" + cBranch + "')@#"
    ElseIf __cRuPrf=='E1' .or. __cRuPrf=='E2'
        cCliFor := Iif(__cRuPrf == "E1",M->E1_CLIENTE,M->E2_FORNECE)
        cBranch := &(__cRuPrf+"_LOJA")
        cFldMoeda:='M->'+__cRuPrf+'_MOEDA'
        cFldConUni:='M->'+__cRuPrf+'_CONUNI'
        cRet:= "@#(FIL_FORNEC = '" + cCliFor + "') .And. (FIL_LOJA == '" + cBranch + "') .And. ((FIL_MOEDA == " + alltrim(STR(&(cFldMoeda))) + " .And. " + cFldConUni + "!='1') .Or. ( FIL_MOEDA==1 .And. " + cFldConUni + "=='1'))@#"
    ElseIf __cRuPrf $ "F47|F49|F4C"
        cCliFor := &(__cRuPrf + "_SUPP")
        cBranch := &(__cRuPrf+"_UNIT")
        cFldMoeda:='M->'+__cRuPrf+'_CURREN'
        cRet:= "@#(FIL_FORNEC = '" + cCliFor + "') .And. (FIL_LOJA == '" + cBranch + "') .And. (FIL_MOEDA== VAL('" + &(cFldMoeda) + "') )@#"
   	ElseIf __cRuPrf $ "F6B"
		cCliFor := FwFldGet("F6B_SUPP")
		cBranch := FwFldGet("F6B_UNIT")
        cRet:= "@#(FIL_FORNEC = '" + cCliFor + "') .And. (FIL_LOJA == '" + cBranch + "') @#"
	EndIf
Return cRet


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINXFIN004_F4NFilter (Russian Name)
Filter for F4N query, Russia
@Author	alexandra.velmozhnya
@since	16/01/2020
/*/
//-----------------------------------------------------------------------------------------------------
function FINXFIN004_F4NFilter()
Local cRuPrf as Character	//Prefix current table
Local cCliFor as Character	//Client or Supplier Code
Local cBranch as Character	//Client or Supplier Branch
Local cBSFlowDir as Character	//Bank Statment Direction
Local cMoeda as Character	//Currency of Document
Local cRet := ""

If alltrim(ReadVar())!= ''
     cRuPrf:=SUBSTR(ReadVar(),4,AT('_',ReadVar())-4)
EndIf

If cRuPrf == "A1"
	cCliFor := M->A1_COD
	cBranch := M->A1_LOJA
	cMoeda := ""
ElseIf cRuPrf == "F4C"
    cBSFlowDir := FwFldGet("F4C_OPER")
    cCliFor := Iif(cBSFlowDir == "1",FWFldGet("F4C_CUST"),FWFldGet("F4C_SUPP"))
    cBranch := Iif(cBSFlowDir == "1",FWFldGet("F4C_CUNI"),FWFldGet("F4C_UNIT"))
    cMoeda := FwFldGet("F4C_CURREN")
EndIf
cRet := "@#F4N_CLIENT == '"+ cCliFor + "' .And. F4N_LOJA == '"+ cBranch + Iif(!Empty(cMoeda),"' .And. F4N_CURREN == '" + cMoeda + "'@#","'@#")
Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN61_SE5LinesFilter

This function used by CTBFINProc() in ctbafin.prw
We use it during bank statement automatic off-line accounting posting
for excluding SE5 lines created by outflow bank statement

@return      Character        cQuery
@example     
@author      astepanov
@since       February/28/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN61_SE5LinesFilter()

    Local cQuery     As Character
    cQuery := ""
    cQuery += " E5_ORIGEM <> '"+;
              PADR("RU06D07",GetSX3Cache("E5_ORIGEM","X3_TAMANHO")," ")+"' AND "
    cQuery += " NOT ( "
    cQuery += "       E5_TIPO    = 'PA' AND "
    cQuery += "       E5_ORIGEM  = ' '  AND "
    cQuery += "       E5_TIPODOC = 'BA' AND "
    cQuery += "       E5_PREFIXO = '"+;
              PADR(GetMV("MV_BSTPRE"),GetSX3Cache("E5_PREFIXO","X3_TAMANHO")," ")+"' AND "
    cQuery += "       E5_MOVFKS  = 'N'  AND "
    cQuery += "       E5_IDORIG  = ' '  AND "
    cQuery += "       E5_TABORI  = ' '      "
    cQuery += "     ) AND "
    
Return (cQuery) /*------------------------------------------------RU06XFUN61_SE5LinesFilter*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN62_SE2LinesFilter

This function used by CTBFINProc() in ctbafin.prw
We use it during bank statement automatic off-line accounting posting
for excluding SE2 lines created by outflow bank statement

@return      Character        cQuery
@example     
@author      astepanov
@since       February/28/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN62_SE2LinesFilter()

    Local cQuery     As Character
    cQuery := ""
    cQuery += " E2_ORIGEM <> '"+;
              PADR("RU06D07",GetSX3Cache("E2_ORIGEM","X3_TAMANHO")," ")+"' AND "
    
Return (cQuery) /*------------------------------------------------RU06XFUN62_SE2LinesFilter*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN63_F40GrvSE5

Russian variant of F040GrvSE5 located in FINA040

@param       Numeric          nOpc  // 1
             Logical          lDesdobr
             Character        cBcoAdt
             Character        cAgeAdt
             Character        cCtaAdt
             Numeric          nRecSe1
             Array            aAutoCab
@return      Logical          lRet
@example     
@author      astepanov
@since       March/23/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN63_F40GrvSE5(nOpc,lDesdobr,cBcoAdt,cAgeAdt,cCtaAdt,nRecSe1,aAutoCab)

    Local lRet       As Logical
    Local lMovFinBS  As Logical
    Local nZ         As Numeric

    lRet      := .T.
    nZ := ASCAN(aAutoCab, {|x| x[1] == "GERFINBS"})
    lMovFinBS := IIF(nZ > 0, aAutoCab[nZ,2], .T.)
    If lMovFinBS
        F040GrvSE5(nOpc,lDesdobr,cBcoAdt,cAgeAdt,cCtaAdt,nRecSE1)
    EndIf

Return (lRet) /*------------------------------------------------------RU06XFUN63_F40GrvSE5*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN64_AddLinkToAR

Adds field to aBaixaSE5 to link the write-off to specific account receivables
This function called from FINA070.
This function involved in process of Innflow Bank statement financial posting.

@param       Array            aBaixaSE5
             Character        cNumero
             Character        cOrdRec
             Character        cSerRec
             Logical          lRaRtImp
@return      Nil
@example     
@author      astepanov
@since       March/10/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN64_AddLinkToAR(aBaixaSE5,cNumero,cOrdRec,cSerRec,lRaRtImp)
    AADD(aBaixaSE5,{ SE5->E5_PREFIXO , cNumero         , SE5->E5_PARCELA, SE5->E5_TIPO,;
                     SE5->E5_CLIFOR , SE5->E5_LOJA , SE5->E5_DATA    , IIF(  SE1->E1_CONUNI=="1",SE5->E5_VLMOED2,SE5->E5_VALOR) ,;
                     SE5->E5_SEQ     , SE5->E5_DTDISPO, SE5->E5_BANCO   , SE5->E5_AGENCIA,;
                     SE5->E5_CONTA   , SE5->E5_VLJUROS, SE5->E5_VLMULTA , SE5->E5_VLDESCO,;
                     SE5->E5_VLCORRE , SE5->E5_VRETPIS, SE5->E5_VRETCOF , SE5->E5_VRETCSL,;
                     SE5->E5_PRETPIS , SE5->E5_PRETCOF, SE5->E5_PRETCSL , SE5->E5_MOEDA ,;
                     SE5->E5_TIPODOC , AllTrim(SE5->E5_FORMAPG)          , cOrdRec        ,;
                     cSerRec         , SE5->E5_MOTBX   , SE5->E5_VRETIRF , SE5->E5_PRETIRF,;
                     If(lRaRtImp, SE5->E5_PRISS,0)     , If(lRaRtImp, SE5->E5_PRINSS,0)   ,;
                     SE5->E5_ORDREC                                                       })
Return (Nil) /*-----------------------------------------------------RU06XFUN64_AddLinkToAR*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN65_FI040TrackBS

This function called from FINA04 and added to aRotina in MenuDef() of FINA040.
It is used to show all Bank statements related to currently selected AR.
For properly work, cursor should be positioned on correct SE1 line.

@private     aRotina, oPQDlgRU06
@return      Nil
@example     
@author      astepanov
@since       April/23/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN65_FI040TrackBS()

    Local aFldList   As Array
    Local aFields    As Array
    Local aArea      As Array
    Local aColumns   As Array
    Local aSize      As Array
    Local aTmpRot    As Array
    Local nX         As Numeric
    Local nStat      As Numeric
    Local oTmp       As Object
    Local oBrwsInfBS As Object
    Local cQuery     As Character
    Local cInsFld    As Character
    Local cKey       As Character
    Local cHlpMsg    As Character
    Local cAlias     As Character

    Private oPQDlgRU06 As Object

    aArea    := GetArea()
    cHlpMsg  := ""
    cKey     := SE1->E1_FILIAL+"|"+SE1->E1_PREFIXO+"|"+;
                SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+;
                SE1->E1_CLIENTE+"|"+SE1->E1_LOJA
    cKey     := PADR(cKey,GetSX3Cache("F5M_KEY","X3_TAMANHO"), " ")
    //F4C_CUSNAM field is virtual
    aFldList := {"F4C_FILIAL", "F4C_INTNUM", "F4C_DTTRAN",;
                 "F4C_CUST"  , "F4C_CUNI"  , "F4C_CUSNAM",;
                 "F5M_VALPAY"                              }
    aFields  := {}
    cInsFld  := ""
    cSlcFld  := ""
    // aFields: {{field_name,tipo,tamanho,decimal,picture,title}}
    // cInsFld " F4C_FILIAL, F4C_INTNUM ...... "
    For nX := 1 To Len(aFldList)
        AADD(aFields, { aFldList[nX],;
                        GetSX3Cache(aFldList[nX], "X3_TIPO"   ),;
                        GetSX3Cache(aFldList[nX], "X3_TAMANHO"),;
                        GetSX3Cache(aFldList[nX], "X3_DECIMAL"),;
                        GetSX3Cache(aFldList[nX], "X3_PICTURE"),;
                        RetTitle(aFldList[nX]);
                       }                                        )
        If     aFldList[nX] == "F5M_VALPAY"
            cSlcFld += aFldList[nX] + ", "
        ElseIf aFldList[nX] == "F4C_CUSNAM"
            cSlcFld += "COALESCE(A1_NOME,'') AS "+aFldList[nX]+", "
        Else
            cSlcFld += "COALESCE("+aFldList[nX]+",'') AS "+aFldList[nX]+", "
        EndIf
        cInsFld += aFldList[nX] + ", "
    Next nX
    cSlcFld := SubStr(cSlcFld,1,Len(cSlcFld)-2)
    cInsFld := SubStr(cInsFld,1,Len(cInsFld)-2)
    cAlias  := CriaTrab(,.F.)
    oTmp := FWTemporaryTable():New(cAlias)
    oTmp:SetFields(aFields)
    oTmp:AddIndex(cAlias+"1",{"F4C_FILIAL", "F4C_INTNUM"})
    oTmp:Create()
    cQuery := " SELECT " + cSlcFld + "                              "
    cQuery += " FROM                                                "
    cQuery += "      ( SELECT *                                     "
    cQuery += "        FROM " + RetSqlName("F5M") + "               "
    cQuery += "        WHERE F5M_KEY    = '" + cKey + "'            "
    cQuery += "          AND F5M_KEYALI = 'SE1'                     "
    cQuery += "          AND D_E_L_E_T_ = ' '                       "
    cQuery += "      )                              F5M             "
    cQuery += " LEFT JOIN " + RetSqlName("F4C") + " F4C             "
    cQuery += "        ON F4C.F4C_FILIAL = '" + xFilial("F4C") + "' "
    cQuery += "       AND F4C.F4C_CUUID  = F5M.F5M_IDDOC            "
    cQuery += "       AND F4C.D_E_L_E_T_ = ' '                      "
    cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1             "
    cQuery += "        ON SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "
    cQuery += "       AND SA1.A1_COD     = F4C.F4C_CUST             "
    cQuery += "       AND SA1.A1_LOJA    = F4C.F4C_CUNI             "
    cQuery += "       AND SA1.D_E_L_E_T_ = ' '                      "
    cQuery := ChangeQuery(cQuery)
    cQuery := "INSERT INTO " + oTmp:GetRealName() +;
              "          ( " + cInsFld            + ") " + cQuery
    nStat  := TCSqlExec(cQuery)
    If nStat >= 0
        DBSelectArea(oTmp:GetAlias())
        DBGoTop()
        If !EoF()
            aColumns := {}
            For nX := 1 To Len(aFields)
                AADD(aColumns, FWBrwColumn():New())  
                aColumns[nX]:SetData(&("{||"+aFields[nX][1]+"}"))
                aColumns[nX]:SetTitle(aFields[nX][6])
                aColumns[nX]:SetSize(aFields[nX][3])
                aColumns[nX]:SetDecimal(aFields[nX][4])
                aColumns[nX]:SetPicture(aFields[nX][5]) 
            Next nX
            aSize  := MsAdvSize()
            oPQDlgRU06 := MsDialog():New(aSize[7], aSize[2], aSize[6], aSize[5],;
                                        STR0069, , , , ,; //Bank statements
                                        CLR_BLACK, CLR_WHITE, , ,;
                                        .T., , , , .T.                         )
            
            oBrwsInfBS := FWMBrowse():New()
            oBrwsInfBS:SetAlias(oTmp:GetAlias())
            oBrwsInfBS:SetOwner(oPQDlgRU06)
            oBrwsInfBS:SetColumns(aColumns)
            aTmpRot  := IIF(aRotina == Nil, Nil, ACLONE(aRotina))
            aRotina := RU06XFUN66_FI040TBSMenu() //Reset global aRotina
            oBrwsInfBS:SetMenuDef("RU06XFUN66_FI040TBSMenu")
            oBrwsInfBS:Activate()
            oPQDlgRU06:Activate(,,,.T.,,,)
            aRotina := aTmpRot //Return aRotina
        Else
            cHlpMsg := STR0070 // no BS for this AR
        EndIf
    Else
        cHlpMsg += " TCSQLError() " + TCSQLError()
    EndIf
    If !Empty(cHlpMsg)
        Help("",1,STR0071,,cHlpMsg,1,0) //Information
    EndIf
    If !Empty(oTmp:GetAlias())
       DBSelectArea(oTmp:GetAlias())
       DBCloseArea()
    EndIf
    oTmp:Delete()
    RestArea(aArea)

Return (Nil) /*----------------------------------------------------RU06XFUN65_FI040TrackBS*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN66_FI040TBSMenu
This function returm menu items for oPQDlgRU06
@private     aRotina, oPQDlgRU06
@return      aRet     // Menu for oPQDlgRU06
@example     
@author      astepanov
@since       April/23/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06XFUN66_FI040TBSMenu()

    Local aRet As Array
    aRet := {{ STR0072, "RU06XFUN67_FI040TBS_VIEW()", 0, 2, 0, Nil},; //view
             { STR0012, "oPQDlgRU06:End()"          , 0, 1, 0, Nil} } //cancl
Return (aRet) /*---------------------------------------------------RU06XFUN66_FI040TBSMenu*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN67_FI040TBS_VIEW
This function open Bank Statement for view
Alias of the current area should be equal to oTmp:GetAlias() from RU06XFUN65_FI040TrackBS
@return      Nil
@example     
@author      astepanov
@since       April/23/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN67_FI040TBS_VIEW()
    
    Local aArea    As Array
    Local cAlias   As Character
    Local cKey     As Character

    aArea := GetArea()
    cAlias := aArea[1]
    cKey   := (cAlias)->F4C_FILIAL + (cAlias)->F4C_INTNUM +;
              DTOS((cAlias)->F4C_DTTRAN)
    DBSelectArea("F4C")
    DBSetOrder(1)
    If DBSeek(cKey)
        RU06D0710_Act(1)
    EndIf
    RestArea(aArea)

Return (Nil) /*---------------------------------------------------RU06XFUN67_FI040TBS_VIEW*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN68_CheckAReversalOfRecivableAdvance

Function Used to Check If the write-off of this bill was generated 
by a Reversal of an advance recivable in bank statement
For correct work we should be positioned on correct SE1 record

We are able to use the AR type NF the way we want after we revert the bank statement 
but we cannot use the AR type RA created by it so we need to change the behavior in the 
routine FINA070 and don`t allow that the user can cancel this the write-off of this 
accounts receivables advanced when it is linked with a bank statement 
Reversed or Replaced and Reversed.

@param       Character        cKey //String with the key to find the BIL in this operation
                                   //filial+prefixo+num+parcela+tipo+cliente+loja for SE1
@return      Logical          lRet //Returns if the Write off of this bill was generated 
                                   //by Reversal RA Bank Statement Process, .T. - means
                                   //generated by Bank tsatement
@example     
@author      astepanov
@since       April/24/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN68_CheckAReversalOfRecivableAdvance(cKey)
    Local lRet       As Logical
    Local aArea      As Array
    Local cQuery     As Character
    Local cTab       As Character
    Local cFK7Chave  As Character
    lRet := .F.
    aArea := GetArea()
    /*Check if it`s a RA and if the BILL was generated in the Bank Statement Process--*/
    If AllTrim(SE1->E1_TIPO) == "RA" .AND. AllTrim(SE1->E1_ORIGEM) == "RU06D07"
        cFK7Chave := PADR(SE1->E1_FILIAL+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+;
                          SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+;
                          SE1->E1_LOJA,GetSX3Cache("FK7_CHAVE", "X3_TAMANHO"), " " )
        cQuery := " SELECT FK7.FK7_CHAVE                             "
        cQuery += " FROM                                             "
        cQuery += "    ( SELECT FK7_CHAVE, FK7_IDDOC                 "
        cQuery += "      FROM   " + RetSQlName("FK7") + "            "
        cQuery += "      WHERE FK7_FILIAL = '" + xFilial("FK7") + "' "
        cQuery += "        AND FK7_CHAVE  = '" +    cFK7Chave   + "' " 
        cQuery += "        AND D_E_L_E_T_ = ' '                      " 
        cQuery += "    )                                       FK7   "
        cQuery += " INNER JOIN                                       "
        cQuery += "    ( SELECT FK1_IDDOC                            "
        cQuery += "      FROM   " + RetSQlName("FK1") + "            "
        cQuery += "      WHERE FK1_FILIAL = '" + xFilial("FK1") + "' "
        cQuery += "        AND FK1_MOTBX  = 'DAC'                    "
        cQuery += "        AND FK1_ORIGEM = 'RU06D07'                "
        cQuery += "        AND D_E_L_E_T_ = ' '                      "
        cQuery += "    )                                       FK1   "
        cQuery += " ON  FK1.FK1_IDDOC = FK7.FK7_IDDOC                "
        cQuery := ChangeQuery(cQuery)
        cTab   := MPSysOpenQuery(cQuery)
        DBSelectArea(cTab)
        DBGoTop()
        If (cTab)->(!eof())
            lRet := .T.
        EndIf
        (cTab)->(DBCloseArea())
    EndIf
    RestArea(aArea)
Return (lRet) /*-------------------------------RU06XFUN68_CheckAReversalOfRecivableAdvance*/


//-----------------------------------------------------------------------
/*/{Protheus.doc} FINA04001_VATCalc(RUSSIAN FUNCTION NAME)

Function calculates and returns:
								tax amount in case of VALIMP
								tax base in case of BASIMP
								0 otherwise
General Rule for indirect tax calculation:

	TaxAmount = TaxBase * (TaxRate / 100)
	GrossTotalWithTax = TaxBase + TaxAmount

[Business Cases for Russia, INCLUI == True, cPaisLoc == 'RUS']
1st case: 
User changes TaxRate or GrossTotalWithTax, so we should call this 
function 2 times: 
1: param = BASIMP, (TaxBase will be changed)
2: param = VALIMP, (TaxAmount will be changed)
2nd case:
User changes TaxBase, so we call this function 1 time:
1: param = VALIMP, (TaxAmount will be changed)
In this case we don't control TaxRate,
this routine should be implemented additionaly.
And we don't control situation when GrossTotalWithTax < TaxBase, in
this condition function returns negative number.

@param       CHARACTER cField   {VALIMP;BASIMP;...}
@return      NUMERIC   nRet     {min(NUMERIC)..max(NUMERIC)}
@examples   
@author      astepanov
@since       November/13/2018
@version     1.0
@project     MA3
@see         FI-CF-23-5
/*/
//-----------------------------------------------------------------------
Function FINA04001(cField)

    Local    nRet     As NUMERIC
    Local	 nGrosTot As NUMERIC //Gross total with a tax >= 0
    Local	 nTaxBase As NUMERIC //Tax base >= 0
    Local    nTaxRate As NUMERIC //Tax rate >= 0 
    
    Default  cField := ''
    nGrosTot := M->E1_VALOR
    nTaxBase := M->E1_BASIMP1
    nTaxRate := M->E1_ALQIMP1

    If cPaisLoc == 'RUS' .and.;
    INCLUI            .and.;
    !Empty(nGrosTot)
            Do Case
                Case cField == 'BASIMP'
                    If nTaxRate == 0
                        nRet := nGrosTot
                    Else
                        nRet := (nGrosTot * 100)/(100 + nTaxRate)
                    EndIf
                Case cField == 'VALIMP'
                    nRet := (nGrosTot - nTaxBase)
                OtherWise
                    nRet := 0
            EndCase
    Else
        nRet := 0
    EndIf

Return nRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} FINXFIN03_FlView(Russian Name)

This function excludes fields from SE1(SE2) View.
Function gets cAlias to current selected Area, if it equals SE1(SE2) 
function returns field array, otherwise returns Nil

@param       CHARACTER cAlias
@return      ARRAY     aFields .or. NIL
@author      astepanov
@since       November/27/2018
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function FINXFIN03(cAlias)
	Local aFields    AS ARRAY
	Local aExcField  AS ARRAY
	Local cFieldName AS CHARACTER
	Local cQuery	 AS CHARACTER
	Local cAliasQry	 AS CHARACTER
	Local nPos       AS NUMERIC
	Local nFieldPos  As NUMERIC 

	aFields := {}
	cAliasQry := GetNextAlias()

	If cAlias != Nil
		cQuery := "SELECT X3_CAMPO FROM " + RetSQLName("SX3") + " WHERE X3_ARQUIVO = '" + cAlias + "' AND D_E_L_E_T_  = ' '"

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

		While !(cAliasQry)->(Eof()) 
			AADD(aFields, AllTrim((cAliasQry)->X3_CAMPO))
			(cAliasQry)->(dbSkip())
		EndDo 
		(cAliasQRY)->(dbCloseArea())
	EndIf

	aExcField := {}
	Do Case  //#2 Fills array by fields for exclusion
		Case aFields != Nil .and. cAlias == "SE1"
			AADD(aExcField, "E1_FILDEB" )
			AADD(aExcField, "E1_FABOV"  )
			AADD(aExcField, "E1_FACS"   )
			AADD(aExcField, "E1_INSTR1" )
			AADD(aExcField, "E1_INSTR2" )
			AADD(aExcField, "E1_DTACRED")
			AADD(aExcField, "E1_BCOCLI" )
			AADD(aExcField, "E1_OCORREN")
			AADD(aExcField, "E1_NODIA"  )
			AADD(aExcField, "E1_DIACTB" )
			AADD(aExcField, "E1_PROJPMS")
			AADD(aExcField, "E1_CODORCA")
			AADD(aExcField, "E1_CODIMOV")
			AADD(aExcField, "E1_NUMCRD" )
			AADD(aExcField, "E1_TXMDCOR")
			AADD(aExcField, "E1_MDCRON" )
			AADD(aExcField, "E1_MDCONTR")
			AADD(aExcField, "E1_MEDNUME")
			AADD(aExcField, "E1_MDPLANI")
			AADD(aExcField, "E1_MDPARCE")
			AADD(aExcField, "E1_MDREVIS")
			AADD(aExcField, "E1_NUMMOV" )
			AADD(aExcField, "E1_BOLETO" )
			AADD(aExcField, "E1_NUMPRO" )
			AADD(aExcField, "E1_INDPRO" )
			AADD(aExcField, "E1_RETCNTR")
			AADD(aExcField, "E1_MDDESC" )
			AADD(aExcField, "E1_MDBONI" )
			AADD(aExcField, "E1_MDMULT" )
			AADD(aExcField, "E1_TURMA"  )
			AADD(aExcField, "E1_TCONHTL")
			AADD(aExcField, "E1_CONHTL" )
		//-} aFields != Nil .and. cAlias == "SE1"
		Case aFields != Nil .and. cAlias == "SE2"
			AADD(aExcField, "E2_VBASISS")
			AADD(aExcField, "E2_APLVLMN")
			AADD(aExcField, "E2_NODIA"  )
			AADD(aExcField, "E2_DIACTB" )
	End Case //#2
	Do Case  //#3 Excludes fields for viewing 
		Case aFields != Nil .and. Len(aExcField) > 0
			For nPos := 1 To Len(aExcField)
				nFieldPos    := AScan(aFields, {|cFieldName| cFieldName == aExcField[nPos]})
				If nFieldPos != 0 
					ADel(aFields,nFieldPos)
				EndIf
			Next
	End Case //#3
Return aFields //End FINXFIN03_FlView



//-------------------------------------------------------------------------------------------------------------
// Revitalizao FINA050
// Funes exclusivas da localizao RUS - Movidas por no ter cobertura da automao para essa localizao
//-------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------
/*/{Protheus.doc} R604Is48

@author TOTVS S/A

@since 01/01/2018
@version P12
/*/
//-------------------------------------------------------
Function R604Is48(cFilOrig,cPrefix,cNUm,cParcel,cTipo,cForn,cLoj)
	
    Local lRet As Logical // if bill included in Payment Request
	Local cQuery As Character
	Local nStatus As Numeric
	Local aArea As Array

	aArea := GetArea()

	cQuery	:= "SELECT F48.F48_FLORIG, F48.F48_PREFIX, F48.F48_NUM, F48.F48_PARCEL, F48.F48_TYPE, F47.F47_SUPP, F47.F47_UNIT, F47.F47_CODREQ "
	cQuery	+= "FROM " + RetSQLName("F48") +" F48 INNER JOIN " +  RetSQLName("F47") + " F47 "
	cQuery	+= " ON F48.F48_IDF48 = F47.F47_IDF47 "
	cQuery	+= " WHERE F48.F48_FILIAL = '" + xFilial("F48") + "' AND F48.F48_FLORIG = '" + cFilOrig + "'"
	cQuery	+= " AND F48.F48_PREFIX = '" + cPrefix + "'"
	cQuery	+= " AND F48.F48_NUM = '" + cNUm + "'"
	cQuery	+= " AND F48.F48_PARCEL = '" + cParcel + "'"
	cQuery	+= " AND F48.F48_TYPE = '" + cTipo + "'"
	cQuery	+= " AND F47.F47_SUPP = '" + cForn + "'"
	cQuery	+= " AND F47.F47_UNIT = '" + cLoj + "'"
	cQuery	+= " AND F47.D_E_L_E_T_ = ' '  AND F48.D_E_L_E_T_ = ' ' "

	nStatus := TCSqlExec(cQuery)
	cQuery := ChangeQuery(cQuery)
	If select("TMPFIL") > 0
		TMPFIL->(DbCloseArea())
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "TMPFIL", .T., .F.)
	If !(TMPFIL->(Eof()))
		lRet:=.T.
	Else
		lRet:=.F.
	EndIf
	RestArea(aArea)

Return (lRet)


//-------------------------------------------------------
/*/{Protheus.doc} FIN50PQBrw

@author TOTVS S/A

@since 01/01/2018
@version P12
/*/
//-------------------------------------------------------
Function FIN50PQBrw(cDoc) 
	Local aSize     As Array
	Local aStr      As Array // Structure to show
	Local aColumns  As Array
	Local nX        As Numeric 
	Local cTitle    As Character
	Local cWinHeader as Character
	Local cErrorMsg as Character
	
	Private oPQDlg    As object
	Private oBrowsePut  As object
	Private oTmpPQs  As Object
	Private cTmpPQs    As character
	Private cMark   As character
	Private	lOneline	As Logical
	
	Default cDoc:='PR' // PR - paymnnt request, PO - payment order
	aSize	:= MsAdvSize()
	nX:=0
	cTmpPQs	:= CriaTrab(,.F.)
	aStr	:= {}
	aColumns 	:= {}
	cTitle:=""
	cErrorMsg:=''
	cWinHeader:=''
	lOneline	:= .F.
	
	// Create temporary table
	if cDoc=='PR'
		aStr:={"F47_FILIAL", "F47_CODREQ", "F47_DTREQ", "F47_SUPP", "F47_UNIT", "F47_VALUE", "F47_PRIORI", "CTO_DESC"}
		MsgRun(STR0007,STR0008,{|| PQCreaTRB(cDoc, aStr)}) //"Please wait"//"Creating temporary table"
		cWinHeader:= STR0076    //"Solicitaes de pagamento"
		cErrorMsg:= STR0077  //"Any Payment Requests cannot be found for this bill"                                                                                                                                                                                                                                                                                                                                                                                                                                                                
	ElseIf cDoc=='PO'
		aStr:={"F49_FILIAL", "F49_PAYORD", "F49_DTPAYM", "F49_SUPP", "F49_UNIT", "F49_VALUE", "F49_DTACTP", "CTO_DESC"}
		MsgRun(STR0007,STR0008,{|| PQCreaTRB(cDoc, aStr)}) //"Please wait"//"Creating temporary table"
		cWinHeader:= STR0078 // Paymnet Order
		cErrorMsg:= STR0079  //"No payment orders are found for this AP"                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
	ElseIf cDoc == 'BS'
		aStr:={"F4C_FILIAL", "F4C_INTNUM", "F4C_DTTRAN", "F4C_DTPAYM", "F4C_ADVANC", "F4C_BNKPAY", "F4C_CNT", "F4C_CLASS", "F4C_VALUE", "F4C_REASON"}
		MsgRun(STR0007,STR0008,{|| PQCreaTRB(cDoc, aStr)}) //"Please wait"//"Creating temporary table"
		cWinHeader:= STR0080 // "Bank Statements"
		cErrorMsg:=STR0081	//"No Bank Statements are found for this AP"
	EndIf
	
	If ((cTmpPQs)->(Eof()))
		Help("",1,cWinHeader,,cErrorMsg,1,0) // FINA 050 -- Can not find any Payment Requests for this bill
	ElseIf cDoc == "BS" .And. lOneline
		FINA50OkBr("BS")
	Else
		For nX := 1 TO  Len(aStr)
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aStr[nX]+"}") )
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStr[nX])) 
			aColumns[Len(aColumns)]:SetSize(GetSX3Cache(aStr[nX], "X3_TAMANHO")) 
			aColumns[Len(aColumns)]:SetDecimal(GetSX3Cache(aStr[nX], "X3_DECIMAL"))
			aColumns[Len(aColumns)]:SetPicture(GetSX3Cache(aStr[nX], "X3_PICTURE")) 
		Next nX
	
		oPQDlg := MsDialog():New( aSize[7], aSize[2], aSize[6], aSize[5], cWinHeader, , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.) // PQs or POs
	
		oBrowsePut := FWMBrowse():New()
		oBrowsePut:SetAlias(cTmpPQs)
		oBrowsePut:SetOwner(oPQDlg)
		oBrowsePut:SetColumns(aColumns)
		aRotina	 := FIN50BrMen(cDoc) //Reset global aRotina
		oBrowsePut:SetMenuDef("FIN50BrMen")
			
		oBrowsePut:Activate()
		oPQDlg:Activate(,,,.T.,,,)
	
		If !Empty (cTmpPQs)
			dbSelectArea(cTmpPQs)
			dbCloseArea()
			cTmpPQs := ""
			dbSelectArea("SE2")
			dbSetOrder(1)
		EndIf
	
		If oTmpPQs <> Nil
			oTmpPQs:Delete()
			oTmpPQs := Nil
	
		Endif
	EndIf 
	
return (.T.)
	
	
	
//-------------------------------------------------------
/*/ PQCreaTRB

@author TOTVS S/A

@since 01/01/2018
@version P12
*/
//-------------------------------------------------------
Static Function PQCreaTRB(cDoc, aStr)
	Local aFields   As Array
	local cQuery    As Character
	Local cSupp     As Character
	Local cUnit     As Character
	Local cPrefix	As Character
	Local cNum		As Character
	Local cParcel	As Character
	Local cType		As Character
	Local nX 		As Numeric
	Local cF5MKey	As Character
	Local cF4CUID	As Character
    Local cFields   As Character
    	
	Default cDoc:='PR'
	Default aStr:={}

    cFields := ''
	cPrefix :=SE2->E2_PREFIXO
	cNum    :=SE2->E2_NUM
	cParcel :=SE2->E2_PARCELA
	cType   :=SE2->E2_TIPO
	cSupp   :=SE2->E2_FORNECE
	cUnit   :=SE2->E2_LOJA
	
	/* Object creation*/
	oTmpPQs := FWTemporaryTable():New(cTmpPQs)
	
	// Table fields - structure
	aFields := {}
	For nX := 1 TO  Len(aStr)
		aadd(aFields, {aStr[nX]	, GetSX3Cache(aStr[nX], "X3_TIPO"), GetSX3Cache(aStr[nX], "X3_TAMANHO"), GetSX3Cache(aStr[nX], "X3_DECIMAL")})
        cFields += Iif(empty(cFields),aStr[nX],','+aStr[nX]) //fields for select and insert
	Next nX
	
	If cDoc=='PO'
		aadd(aFields, {"F49_BNKORD"	, GetSX3Cache("F49_BNKORD", "X3_TIPO"), GetSX3Cache("F49_BNKORD", "X3_TAMANHO"), GetSX3Cache("F49_BNKORD", "X3_DECIMAL")})
        cFields += ',F49_BNKORD'
	ElseIf cDoc == "BS"
		aadd(aFields, {"F4C_CUUID"	, GetSX3Cache("F4C_CUUID", "X3_TIPO"), GetSX3Cache("F4C_CUUID", "X3_TAMANHO"), GetSX3Cache("F4C_CUUID", "X3_DECIMAL")})
        cFields += ',F4C_CUUID'
	EndIf
	
	oTmpPQs:SetFields(aFields)
	if cDoc=='PR'
		oTmpPQs:AddIndex("Indice2", {"F47_FILIAL", "F47_CODREQ"} )
	ElseIf cDoc=='PO'
		oTmpPQs:AddIndex("Indice2", {"F49_FILIAL", "F49_PAYORD"} )
	ElseIf cDoc=='BS'
		oTmpPQs:AddIndex("Indice2", {"F4C_FILIAL", "F4C_INTNUM"} )
		cF5MKey := xFilial("SE2") + "|" + cPrefix + "|"+ cNum + "|" + cParcel + "|"+ cType +"|" + cSupp + "|" + cUnit 
	EndIf
	
	// Table creation - data
	oTmpPQs:Create()
	
	if cDoc=='PR'
		cQuery := "INSERT INTO " + oTmpPQs:GetRealName() +" (" + cFields + ") "
		cQuery += " SELECT " + cFields
		cQuery += " FROM " + RetSQLName("F47") + " F47 "
		cQuery += " INNER JOIN " + RetSQLName("CTO") + " CTO ON (F47_CURREN=CTO_MOEDA and CTO_FILIAL = '" + xFILIAL("F47",CTO->CTO_FILIAL) + "') "
		cQuery += " INNER JOIN " + RetSQLName("F48") + " F48 ON (F47_IDF47=F48_IDF48 and F48_FILIAL = '" + xFILIAL("F48") + "') "
		cQuery += " WHERE F47.D_E_L_E_T_ =' ' AND F48.D_E_L_E_T_=' '  AND CTO.D_E_L_E_T_=' '" 
		cQuery += " AND F48_PREFIX = '" + cPrefix + "'"
		cQuery += " AND F48_NUM  = '" +  cNum  + "'"
		cQuery += " AND F48_PARCEL = '" + cParcel +"'"
		cQuery += " AND F48_TYPE = '" + cType +"'"
		cQuery += " AND F47_SUPP = '" + cSupp +"'"
		cQuery += " AND F47_UNIT = '" + cUnit +"'"
	ElseIf cDoc=='PO'
		cQuery := "INSERT INTO " + oTmpPQs:GetRealName()  +" (" + cFields + ") "
		cQuery += " SELECT " + cFields
		cQuery += " FROM " + RetSQLName("F49") + " F49 "
		cQuery += " INNER JOIN " + RetSQLName("CTO") + " CTO ON (F49_CURREN=CTO_MOEDA and CTO_FILIAL = '" + xFILIAL("F49",CTO->CTO_FILIAL) + "') "
		cQuery += " INNER JOIN " + RetSQLName("F4B") + " F4B ON (F4B_IDF49=F49_IDF49 and F4B_FILIAL = '" + xFILIAL("F4B") + "') "
		cQuery += " WHERE F49.D_E_L_E_T_ =' ' AND F4B.D_E_L_E_T_=' ' AND CTO.D_E_L_E_T_=' '" 
		cQuery += " AND F4B_PREFIX = '" + cPrefix + "'"
		cQuery += " AND F4B_NUM  = '" +  cNum  + "'"
		cQuery += " AND F4B_PARCEL = '" + cParcel +"'"
		cQuery += " AND F4B_TYPE = '" + cType +"'"
		cQuery += " AND F49_SUPP = '" + cSupp +"'"
		cQuery += " AND F49_UNIT = '" + cUnit +"'"
	ElseIf cDoc=='BS'
		cQuery := "INSERT INTO " + oTmpPQs:GetRealName()  +" (" + cFields + ") "
		cQuery += " SELECT " + cFields
		cQuery += " FROM " + RetSQLName("F4C") + " F4C "
		cQuery += " INNER JOIN " + RetSQLName("F5M") + " F5M ON (F5M_IDDOC=F4C_CUUID and F5M_FILIAL = '" + xFILIAL("F5M") + "') "
		cQuery += " WHERE F4C.D_E_L_E_T_ =' ' AND F5M.D_E_L_E_T_=' '"
		cQuery += " AND F5M_KEY like '" + cF5MKey + "%' and F5M_ALIAS='F4C' "
	EndIf
	
    //cQuery := ChangeQuery(cQuery)     //Change query here create a SQL statment wrong with two select that became invalid return error -19 at TCSqlExec
	TCSqlExec(cQuery)
	
	DbSelectArea(cTmpPQs) 
	DbGotop()
	
	If cDoc == "BS"
		lOneline := (cTmpPQs)->(!Eof())
		If lOneline
			cF4CUID := (cTmpPQs)->F4C_CUUID
			DbGoBottom()
			lOneline := cF4CUID == (cTmpPQs)->F4C_CUUID
		EndIf
		DbGotop()
	EndIf
	
Return (NIL)
	
//-------------------------------------------------------
/*/ FIN50BrMen

@author TOTVS S/A

@since 01/01/2018
@version P12
*/
//-------------------------------------------------------
Static Function FIN50BrMen(cDoc)
	Local aRet As Array
	
	Default cDoc:='PR'
	aRet := {}
	aAdd(aRet, {STR0072, "FINA50OkBr('"+cDoc+"')", 0, 2, 0, Nil})	//Ok
	aAdd(aRet, {STR0012, "FIN50ClBr()", 0, 1, 0, Nil})		//Cancel

Return (aRet)

//-------------------------------------------------------
/*/ FIN50ClBr

@author TOTVS S/A

@since 01/01/2018
@version P12
*/
//-------------------------------------------------------
Function FIN50ClBr()
	oPQDlg:End()
Return .F.

//-------------------------------------------------------
/*/ FINA50OkBr

@author TOTVS S/A

@since 01/01/2018
@version P12
*/
//-------------------------------------------------------
Function FINA50OkBr(cDoc)
    Local aEnableButtons As Array
    Local aArea As Array
    Local cKey As Character
    Local cHeadArea		As Character 
    Local cProgName		As Character
    Local nHeadIndex	As Numeric

    Default cDoc:='PR'

    aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0012},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //Hide the standart options of the Form 
    aArea := (cTmpPQs)->(GetArea())	

    If cDoc == 'PR'
        cKey:=(cTmpPQs)->F47_FILIAL+(cTmpPQs)->F47_CODREQ
        cHeadArea := "F47"
        nHeadIndex := 1
        cProgName := "RU06D04"
    ElseIf cDoc == 'PO'
        cKey:=(cTmpPQs)->F49_FILIAL+(cTmpPQs)->F49_PAYORD+(cTmpPQs)->F49_BNKORD+DTOS((cTmpPQs)->F49_DTPAYM)
        cHeadArea := "F49"
        nHeadIndex := 1
        cProgName := "RU06D05"
    ElseIf cDoc == 'BS'
        //F4C_FILIAL+F4C_INTNUM+DTOS(F4C_DTTRAN)
        cKey:=(cTmpPQs)->F4C_FILIAL+(cTmpPQs)->F4C_INTNUM+DTOS((cTmpPQs)->F4C_DTTRAN)
        cHeadArea := "F4C"
        nHeadIndex := 1
    EndIf

    dbSelectArea(cHeadArea)
    &(cHeadArea)->(DbSetOrder(nHeadIndex))

    If &(cHeadArea)->(DbSeek(cKey))
        If cDoc == "BS" 
            RU06D0710_Act(MODEL_OPERATION_VIEW)
        Else
            FWExecView( STR0072, cProgName, MODEL_OPERATION_VIEW, /*oDlg*/,/*/ {|| .T. }/*/ ,/*bOk*/ , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ ) // Payment Request - View
        EndIf
    EndIf

    &(cHeadArea)->(DbCloseArea())
    RestArea(aArea)
Return Nil

//-------------------------------------------------------
/*/ FINA05001_VATCalc(Russian Function Name)

@author natalia.khozyainova
@since 16/10/2018
@edit astepanov 29Septempber 2023
@version P12
*/
//-------------------------------------------------------
Function FINA05001_(cField)
    Local nRet as Numeric
    Default cField:=''
    nRet:=0

    If cPaisLoc=='RUS' .and. INCLUI
        If M->E2_ALQIMP1 != Nil .and. M->E2_VALOR != Nil
            If cField=='BASIMP'
                nRet:= (M->E2_VALOR *100) / (100 + M->E2_ALQIMP1)
            ElseIf cField == 'VALIMP'
                nRet:= M->E2_VALOR - M->E2_BASIMP1
            EndIf
        EndIf
    EndIf

Return nRet




//--------------------------------------------------------------------------
/*/{Protheus.doc}RU06XFUN69_F340VlCrVl
Function for validation for Value to clear.

@return lRet

@author Cherchik Konstantin
@since  18/09/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function RU06XFUN69_F340VlCrVl(nValor,nSaldo,cHelp)
	Local lRet 		as Logicaly
	Local nOpenBal	as Numeric
	Local cSe2Key	as Character

	lRet		:= .F.
	cSe2Key		:= SE2->E2_FILIAL + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
	nOpenBal	:= RU06XFUN06(cSe2Key) // Open balance from F5M //RU06XFUN06_GetOpenBalance

	If !Empty(nValor) .And. !Empty(nSaldo)
		If nValor <= nOpenBal	//nSaldo
			lRet := .T.
		Else
            Help("",1,"FA340ValClrVld",,cHelp,1,0)
		EndIf
	EndIf

Return lRet




//--------------------------------------------------------------------------
/*/{Protheus.doc}RU06XFUN70_FA340Filte
Filter for AP list

@author Cherchik Konstantin
@since  02/08/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function RU06XFUN70_FA340Filte(oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,cMsg,cTitMsg)
	Local cPerg		as Character
	Local lRet		as Logical
	Local aFilter as Array

	lRet	:=.F.
	cPerg	:=""
	lFilMark:= MsgYesNo(cMsg,cTitMsg)

	If lFilMark
		cPerg := "AF3401"
		lRet  := Pergunte(cPerg,.T.,cTitMsg)
		If lRet
			cTitFilt := ""
			aFilter := {}
			Aadd(aFilter, MV_PAR01)	//From E2_PREFIXO
			Aadd(aFilter, MV_PAR02)	//To E2_PREFIXO
			Aadd(aFilter, MV_PAR03)	//From E2_NUM
			Aadd(aFilter, MV_PAR04)	//To E2_NUM
			Aadd(aFilter, MV_PAR05)	//From E2_TIPO
			Aadd(aFilter, MV_PAR06)	//To E2_TIPO
			Aadd(aFilter, MV_PAR07)	//From E2_MOEDA
			Aadd(aFilter, MV_PAR08)	//To E2_MOEDA
			Aadd(aFilter, MV_PAR09)	//From E2_FORNECE
			Aadd(aFilter, MV_PAR10)	//To E2_FORNECE
			Aadd(aFilter, MV_PAR11)	//From E2_F5QCODE
			Aadd(aFilter, MV_PAR12)	//To E2_F5QCODE
			Aadd(aFilter, MV_PAR13)	//From E2_EMISSAO
			Aadd(aFilter, MV_PAR14)	//To E2_EMISSAO
			Aadd(aFilter, MV_PAR15)	//From E2_VENCTO
			Aadd(aFilter, MV_PAR16)	//To E2_VENCTO
			Pergunte("AFI340",.F.)

			cTitFilt += " AND SE2.E2_PREFIXO >= '" + aFilter[1] + "' AND SE2.E2_PREFIXO <= '" + aFilter[2] + "'" 
			cTitFilt += " AND SE2.E2_NUM >= '" + aFilter[3] + "' AND SE2.E2_NUM <= '" + aFilter[4] + "'"
			cTitFilt += " AND SE2.E2_TIPO >= '" + aFilter[5] + "' AND SE2.E2_TIPO <= '" + aFilter[6] + "'"
			cTitFilt += " AND SE2.E2_MOEDA >= " + AllTrim(Str(aFilter[7])) + " AND SE2.E2_MOEDA <= " + AllTrim(Str(aFilter[8])) + ""
			cTitFilt += " AND SE2.E2_FORNECE >= '" + aFilter[9] + "' AND SE2.E2_FORNECE <= '" + aFilter[10] + "'"
			cTitFilt += " AND SE2.E2_F5QCODE >= '" + aFilter[11] + "' AND SE2.E2_F5QCODE <= '" + aFilter[12] + "'"
			cTitFilt += " AND SE2.E2_EMISSAO >= '" + DTOS(aFilter[13]) + "' AND SE2.E2_EMISSAO <= '" + DTOS(aFilter[14]) + "'"
			cTitFilt += " AND SE2.E2_VENCTO >= '" + DTOS(aFilter[15]) + "' AND SE2.E2_VENCTO <= '" + DTOS(aFilter[16]) + "'"

			Fa340TitEx(cNumCont, 0, lAutomato) //Generates Table with titles - aTitulos:
		EndIf
	EndIf

	oTitulo:SetArray(aTitulos)
	oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
		aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
		aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
		aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
		aTitulos[oTitulo:nAt,18],;
		aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,6],;
		aTitulos[oTitulo:nAt,11],aTitulos[oTitulo:nAt,7],;
		aTitulos[oTitulo:nAt,12],aTitulos[oTitulo:nAt,15],;
		aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,19],;
		aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,17],;
		aTitulos[oTitulo:nAt,14]}}
	oTitulo:Refresh()
	Pergunte("AFI340",.F.)
Return lRet


//--------------------------------------------------------------------------
/*/{Protheus.doc}RU06XFUN71_FA340Unfil
Function to remove the filter from the listbox

@author Cherchik Konstantin
@since  13/12/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function RU06XFUN71_FA340Unfil(oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,cMsg,cTitMsg)
	Local lUnfilter	as Logical

	lUnfilter := MsgYesNo(cMsg,cTitMsg)

	If lUnfilter
		cTitFilt := ""
		Fa340TitEx(cNumCont, 0, lAutomato)
		oTitulo:SetArray(aTitulos)
			oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
				aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
				aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,18],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,6],;
				aTitulos[oTitulo:nAt,11],aTitulos[oTitulo:nAt,7],;
				aTitulos[oTitulo:nAt,12],aTitulos[oTitulo:nAt,15],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,19],;
				aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,17],;
				aTitulos[oTitulo:nAt,14]}}
		oTitulo:Refresh()	
	EndIf
Return lUnfilter

//--------------------------------------------------------------------------
/*/{Protheus.doc}FA340Sort
Sorting for AP list

@author Cherchik Konstantin
@since  03/08/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function RU06XFUN72_FA340Sort (oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,cTitle,cMsg,cOpc1,cOpc2)
	Local nX		as Numeric
	Local nOpcS		as Numeric
	Local aPayTypes as Array
	Local oDlg 		as Object
	Local oCbx 		as Object 
	Local oRadio 	as Object 

	aPayTypes:= {}
	oDlg	 := Nil
	oCbx	 := Nil
	oRadio	 := Nil
	nOpcS	 :=0

	If !IsInCallStack("RU06XFUN73_F340AutMrk")
		For nX := 2 To Len(oTitulo:AHEADERS) 
			Aadd(aPayTypes, oTitulo:AHEADERS[nX]) 
		Next

		DEFINE MSDIALOG oDlg FROM  94,1 TO 273,293 TITLE cTitle PIXEL 
		@ 10,17 Say cMsg SIZE 150,7 OF oDlg PIXEL
		@ 27,07 TO 72, 140 OF oDlg  PIXEL
		@ 34,13 COMBOBOX oCbx VAR cPayType ITEMS aPayTypes SIZE 120, 27 OF oDlg PIXEL
		@ 50,13 Radio 	oRadio VAR nRadio;
			ITEMS 	cOpc1,;	
					cOpc2;	
			SIZE 110,10 OF oDlg PIXEL
		DEFINE SBUTTON FROM 75,085 TYPE 1 ENABLE OF oDlg ACTION (nOpcS := 1,FA340Combo(cPayType, oDlg,oCbx,@nSel))
		DEFINE SBUTTON FROM 75,115 TYPE 2 ENABLE OF oDlg ACTION (nOpcS := 0,FA340Combo(cPayType, oDlg,oCbx,@nSel))
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpcS := 0, .T.)    
	EndIf

		/* Due to the fact that the arrays aTitulos & aHeaders are out of sync, the sort function must be synchronized in this form */

	DO Case
		Case nSel == 1
			cSortField := "E2_FILIAL "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[13] < y[13] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[13] > y[13] } )		
			Endif 
		Case nSel == 2
			cSortField := "E2_PREFIXO, E2_NUM "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[1]+x[2] < y[1]+y[2] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[1]+x[2] > y[1]+y[2] } )		
			Endif  
		Case nSel == 3
			cSortField := "E2_NUM "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[2] < y[2] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[2] > y[2] } )
			Endif	  
		Case nSel == 4
			cSortField := "E2_PARCELA "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[3] < y[3] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[3] > y[3] } )
			Endif	 
		Case nSel == 5
			cSortField := "E2_TIPO "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[4] < y[4] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[4] > y[4] } )
			Endif	
		Case nSel == 6
			cSortField := "E2_MOEDA "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[9] < y[9] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[9] > y[9] } )
			Endif	 
		Case nSel == 7
			cSortField := "E2_MOEDA "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[18] < y[18] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[18] > y[18] } )
			Endif	
		Case nSel == 8
			cSortField := "E2_SALDO "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[5] < y[5] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[5] > y[5] } )
			Endif	 
		Case nSel == 9
			cSortField := "E2_NUM " // We can not sort and set "clear value"  at the same time, in column that contains values to clear.
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[6] < y[6] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[6] > y[6] } )
			Endif	 
		Case nSel == 10
			cSortField := "E2_FORNECE "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[11] < y[11] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[11] > y[11] } )
			Endif	
		Case nSel == 11
			cSortField := "E2_NOMFOR "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[7] < y[7] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[7] > y[7] } )
			Endif	 
		Case nSel == 12
			cSortField := "E2_LOJA "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[12] < y[12] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[12] > y[12] } )
			Endif	  
		Case nSel == 13
			cSortField := "E2_F5QCODE "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[15] < y[15] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[15] > y[15] } )
			Endif	
		Case nSel == 14
			cSortField := "E2_EMISSAO "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[10] < y[10] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[10] > y[10] } )
			Endif	  
		Case nSel == 15
			cSortField := "E2_VENCTO "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[19] < y[19] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[19] > y[19] } )
			Endif	
		Case nSel == 16
			cSortField := "E2_VALOR "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[16] < y[16] } ) 
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[16] > y[16] } )
			Endif	
		Case nSel == 17
			cSortField := "E2_VLCRUZ "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[17] < y[17] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[17] > y[17] } )
			Endif	
		Case nSel == 18
			cSortField := "E2_CONUNI "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[14] < y[14] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[14] > y[14] } )
			Endif	 
		Otherwise
			cSortField := "E2_NUM "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[2] < y[2] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[2] > y[2] } )
			Endif	 
	EndCase
	
	oTitulo:SetArray(aTitulos)
	oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
		aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
		aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
		aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
		aTitulos[oTitulo:nAt,18],;
		aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,6],;
		aTitulos[oTitulo:nAt,11],aTitulos[oTitulo:nAt,7],;
		aTitulos[oTitulo:nAt,12],aTitulos[oTitulo:nAt,15],;
		aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,19],;
		aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,17],;
		aTitulos[oTitulo:nAt,14]}}
	oTitulo:Refresh()	

Return nSel


//--------------------------------------------------------------------------
/*/{Protheus.doc}RU06XFUN73_F340AutMrk
Function for Auto Mark

@author Cherchik Konstantin
@since  03/08/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function RU06XFUN73_F340AutMrk(oTitulo,aTitulos, oOk,oNo,cNumCont,lAutomato,cTitle,cMsg,cHlp)
	Local nOpcB		as Numeric
	Local oDlg 		as Object
	Local oGet01 	as Object

	nOpcB:=0
	oDlg	 := Nil
	oGet01	 := Nil	
	

	DEFINE MSDIALOG oDlg FROM  94,1 TO 273,233 TITLE cTitle PIXEL 
	@ 05,17 Say cMsg SIZE 110,7 OF oDlg PIXEL
	@ 22,07 TO 72, 100 OF oDlg  PIXEL
	@ 30,10 MSGET oGet01 VAR nValor PICTURE "@E 999,999,999.99" Valid .T. WHEN .T. PIXEL OF oDlg SIZE 70,7 HASBUTTON	


	DEFINE SBUTTON FROM 75,045 TYPE 1 ENABLE OF oDlg ACTION (nOpcB := 1,Iif(nValor >= 0 .AND. nValor <= nSaldo,oDlg:End(),EVAL({|| Help("",1,"F340VlCrVl",,cHlp,1,0) , .F. })))
	DEFINE SBUTTON FROM 75,75 TYPE 2 ENABLE OF oDlg ACTION (nOpcB := 0,oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpcB := 0, .T.)    

	If nOpcB == 1 
		RU06XFUN72(oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,nValTot) // RU06XFUN72_FA340Sort
		Fa340TitEx(cNumCont) //Generates Table with titles - aTitulos:
		oTitulo:SetArray(aTitulos)
		oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
			aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
			aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
			aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
			aTitulos[oTitulo:nAt,18],;
			aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,6],;
			aTitulos[oTitulo:nAt,11],aTitulos[oTitulo:nAt,7],;
			aTitulos[oTitulo:nAt,12],aTitulos[oTitulo:nAt,15],;
			aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,19],;
			aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,17],;
			aTitulos[oTitulo:nAt,14]}}
	oTitulo:Refresh()	
	Endif

Return

//--------------------------------------------------------------------------
/*/{Protheus.doc}RU06XFUN74_RetOrd
Function to encapsulate the order of titles in browse 

@author eduardo.flima
@since  07/08/2020
@version R9
/*/
//--------------------------------------------------------------------------
Function RU06XFUN74_RetFunc()
Return IsInCallStack("RU06XFUN72_FA340Sort") .Or. IsInCallStack("RU06XFUN73_F340AutMrk")





//--------------------------------------------------------------------------
/*/{Protheus.doc}FA340Combo
Function for buttons of FA340Sort

@author Cherchik Konstantin
@since  03/08/2018
@version 12
/*/
//--------------------------------------------------------------------------
Static Function FA340Combo(cPayType, oDlg,oCbx, nSel)
	nSel := oCbx:nAt
	oDlg:End()
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN75_Set_VLCRUZ
This function is called from FA050AxInc(FA040valor) function located in FINA050.PRX
(FINA040.PRX) when we post new outflow (inflow) bank statement.
We set SE2->E2_VLCRUZ(M->E1_VLCRUZ) for AP (AR) created by outflow bank statement with type
"PA"("RA")
We use value calculated in RU06D07

@param       Character          cTipo        //"PA"(Default) or "RA" (E2_TIPO or E1_TIPO)
@return      Numeric            nRet        // VLCRUZ
@example     
@author      astepanov
@since       September/01/2020
@edit        January/15/2021
@version     1.1
@project     MA3
@see         https://jiraproducao.totvs.com.br/browse/RULOC-694
             https://jiraproducao.totvs.com.br/browse/RULOC-1205
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN75_Set_VLCRUZ(cTipo)

    Local nPos1       As Numeric
    Local nPos2       As Numeric
    Local nRet        As Numeric

    Default cTipo     := "PA"
    If     cTipo == "PA"
        nRet := SE2->E2_VLCRUZ
    ElseIf cTipo == "RA"
        nRet := M->E1_VLCRUZ
    EndIf
    If Type("aAutoCab") == "A"
        nPos1 := ASCAN(aAutoCab, {|x| x[1] $ "E2_ORIGEM|E1_ORIGEM"})
        nPos2 := ASCAN(aAutoCab, {|x| x[1] $ "E2_TIPO|E1_TIPO"})
        If nPos1 > 0 .AND. nPos2 > 0 .AND. AllTrim(aAutoCab[nPos1][2]) == "RU06D07" .AND.;
           AllTrim(aAutoCab[nPos2][2]) == cTipo
            nRet := aAutoCab[ASCAN(aAutoCab,{|x| x[1] $ "E2_VLCRUZ|E1_VLCRUZ"})][2]
        EndIf
    EndIf

Return nRet /*-------------------------------------------------------RU06XFUN75_Set_VLCRUZ*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN76_ARortinaUpd
This is a generic function used when we need to update or replace aRotina in standart 
non russian source codes 
@param    Numeric        nNum     //1, 2, 0
          Character      cSupp    //Supplier
          Character      cUnit    //Unit
          Character      cBnk
          Character      cBIK
          Character      cAcc

@param    
    cRot    : Character : Madatory Tag identifing from wich routine we are calling and what is the procedure to take. 
    aOriRot : Array     : Optional the original aRotina that maybe can be used to re-feed inside the function it is not mandatory. 
    aOriRot :aStr       : Optional Strings from original source code that maybe used in the aRotina                        
@return 
    aRotina: Array: the new array of aRotina
@example     
@author      Eduardo.Flima
@since       01/01/2020
@version     1.0
@project     MA3
//---------------------------------------------------------------------------------------/*/

Function RU06XFUN76_ARortinaUpd(cRot,aOriRot,aStr)
    Local aXRotina     As Array    

    DEFAULT aOriRot := {}
    DEFAULT cRot := ""
    DEFAULT aStr := {}

    aXRotina := {}

    cRot := AllTrim(UPPER(cRot))
    Do Case
        Case cRot == 'FINA070'
            aAdd( aXRotina,	{ aStr[1], "fa070Visual", 0, 2})         // View
            aAdd( aXRotina,	{ aStr[2], "fA070Tit", 0, 4})            // Post
            aAdd( aXRotina,	{ aStr[3], "fA070Lot", 0, 4})            // Lot
            aAdd( aXRotina,	{ aStr[4], "fA070Can", 0, 5})            // Cancel
            aAdd( aXRotina,	{ aStr[5], "FA040Legenda", 0, 6, ,.F.})  // Legend
            aAdd( aXRotina,	{ aStr[6], "Fc040Con", 0, 2})            // Query
            aAdd( aXRotina,	{ aStr[7], "CTBC662", 0, 7})             // Acc. tracker

        Case cRot == 'FINA080'
            // Removed "Delete" option, added "Query" option
            aXRotina := {;
            { aStr[1], "AxPesqui" , 0 , 1,,.F.},; //"Pesquisar"
            { aStr[2], "AxVisual" , 0 , 2},; //"Visualizar"
            { aStr[3], "FA080Tit" , 0 , 4},; //"Baixar"
            { aStr[4], "FA080Lot" , 0 , 4},; //"Lote"
            { aStr[5], "FA080Can" , 0 , 5},; //"Canc Baixa"
            { aStr[6], "CTBC662" , 0 , 8},;	//"Tracker Contbil"
            { aStr[7], "FA040Legenda", 0 , 6, ,.F.},; //"Le&genda"
            { aStr[8], "fc050con", 0 , 4 }}  // Query
    EndCase


Return aXRotina /*-------------------------------------------------------RU06XFUN76_ARortinaUpd*/


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN77_RetVrtLinesForPO
This function returns alias to query result when we load lines
to virtual grid in Payment order

@param       Array     aVrtFields // reslut of 
                                     oModel:GetStruct():GetFields()
             Character cSupp      // Supplier code for E2_FORNECE
             Character cUnit      // Supplier unit for E2_LOJA
             Character cIDF49     // Unique identifier for F49 record
                                     F49_IDF49 
@return      Character cAlias     //don't forget about 
                                    (cAlias)->(DBCloseArea())
@examples   
@author      astepanov
@since       October/22/2020
@version     1.0
@project     MA3
/*/
//-----------------------------------------------------------------------
Function RU06XFUN77_RetVrtLinesForPO(aVrtFields,cSupp,cUnit,cIDF49)
    Local cQuery     As Character
    Local cAlias     As Character
    Local nX         As Numeric


    cQuery := " SELECT '"+xFilial("F4B")+"'              B_BRANCH,"
    cQuery += "  CASE                                             "
    cQuery += "  WHEN   F4B.F4B_RATUSR = '1' THEN 'T'             "
    cQuery += "  ELSE                             'F'             "
    cQuery += "  END                                     B_CHECK ,"
    cQuery += "         COALESCE(F4A.F4A_CODREQ,'')      B_CODREQ,"
    cQuery += "         F4B.F4B_PREFIX                   B_PREFIX,"
    cQuery += "         F4B.F4B_NUM                      B_NUM   ,"
    cQuery += "         F4B.F4B_PARCEL                   B_PARCEL,"
    cQuery += "         F4B.F4B_TYPE                     B_TYPE  ,"
    cQuery += "         COALESCE(SE2.E2_NATUREZ,'')      B_CLASS ,"
    cQuery += "         COALESCE(SE2.E2_EMISSAO,'')      B_EMISS ,"
    cQuery += "         COALESCE(SE2.E2_VENCREA,'')      B_REALMT,"
    cQuery += "         F4B.F4B_VALPAY                   B_VALPAY,"
    cQuery += "         F4B.F4B_EXGRAT                   B_EXGRAT,"
    cQuery += "         F4B.F4B_VALCNV                   B_VALCNV,"
    cQuery += "         F4B.F4B_BSVATC                   B_BSVATC,"
    cQuery += "         F4B.F4B_VLVATC                   B_VLVATC,"
    cQuery += "         COALESCE(SE2.E2_VALOR  , 0)      B_VALUE ,"
    cQuery += "         COALESCE(SE2.E2_MOEDA  , 1)      B_CURREN,"
    cQuery += "         F4B.F4B_CONUNI                   B_CONUNI,"
    cQuery += "         COALESCE(SE2.E2_VLCRUZ , 0)      B_VLCRUZ,"
    cQuery += "         (COALESCE(SE2.E2_SALDO  , 0) -            "
    cQuery += "         COALESCE(OPB.OPBVALUE  , 0)   ) +         "
    cQuery += "         COALESCE(F5M.F5M_VALPAY, 0)      B_OPBAL ,"
    cQuery += "         COALESCE(SE2.E2_ALQIMP1, 0)      B_ALIMP1,"
    cQuery += "         F4B.F4B_VLIMP1                   B_VLIMP1,"
    cQuery += "         F4B.F4B_VALPAY - F4B.F4B_VLIMP1  B_BSIMP1,"
    cQuery += "         COALESCE(SE2.E2_F5QCODE,'')      B_MDCNTR,"
    cQuery += "         F4B.F4B_FLORIG                   B_FLORIG,"
    cQuery += "         F4B.F4B_IDF4A                    B_IDF4A ,"
    cQuery += "         F4B.F4B_RATUSR                   B_RATUSR "
    cQuery += " FROM      "+RetSQLName("F4B")+"               F4B "

    cQuery += " LEFT JOIN "+RetSQLName("SE2")+"               SE2 "
    cQuery += "        ON ( SE2.E2_FILIAL  = F4B.F4B_FLORIG       "
    cQuery += "         AND SE2.E2_PREFIXO = F4B.F4B_PREFIX       "
    cQuery += "         AND SE2.E2_NUM     = F4B.F4B_NUM          "
    cQuery += "         AND SE2.E2_PARCELA = F4B.F4B_PARCEL       "
    cQuery += "         AND SE2.E2_TIPO    = F4B.F4B_TYPE         "
    cQuery += "         AND SE2.E2_FORNECE = '"+cSupp+"'          "
    cQuery += "         AND SE2.E2_LOJA    = '"+cUnit+"'          "
    cQuery += "         AND SE2.D_E_L_E_T_ = ' '            )     "

    cQuery += " LEFT JOIN                                         "
    cQuery += "  ( SELECT                                         "
    cQuery += "        GRP.F5M_KEY             F5M_KEY,           "
    cQuery += "        SUM(GRP.F5M_VALPAY)     OPBVALUE           "
    cQuery += "    FROM                                           "
    cQuery += "      (SELECT                                      "
    cQuery += "                         F5M.F5M_KEY   ,           "
    cQuery += "                         F5M.F5M_VALPAY            "
    cQuery += "       FROM "+RetSQLName("F5M")+"             F5M  "
    cQuery += "       WHERE F5M_CTRBAL     = '1'                  "
    cQuery += "         AND F5M.D_E_L_E_T_ = ' '                  "
    cQuery += "      )                                        GRP "
    cQuery += "    GROUP BY GRP.F5M_KEY                           "
    cQuery += "  )                                            OPB "
    cQuery += "   ON ("+RU06XFUN09_RetSE2F5MJoinOnString("OPB")+")"

    cQuery += " LEFT JOIN "+RetSQLName("F5M")+"               F5M "
    cQuery += "   ON ("+RU06XFUN78_JoinOnF5MToF4B(cSupp,cUnit)+"  "
    cQuery += "         AND F5M.F5M_CTRBAL = '1'            )     "
    
    cQuery += " LEFT JOIN "+RetSQLName("F4A")+"               F4A "
    cQuery += "        ON ( F4A.F4A_FILIAL = F4B.F4B_FILIAL       "
    cQuery += "         AND F4A.F4A_IDF4A  = F4B.F4B_IDF4A        "
    cQuery += "         AND F4A.D_E_L_E_T_ = ' '            )     "

    cQuery += " WHERE                                             "
    cQuery += "             F4B.F4B_FILIAL = '"+xFilial("F4B")+"' "
    cQuery += "         AND F4B.F4B_IDF49  = '"+cIDF49+"'         "
    cQuery += "         AND F4B.D_E_L_E_T_ = ' '                  "

    cQuery := ChangeQuery(cQuery)
    cAlias := CriaTrab( , .F.)
    TcQuery cQuery New Alias ((cAlias))
    For nX := 1 To Len(aVrtFields)
        If aVrtFields[nX][4] $ "N|D|L"
            TCSetField(cAlias, aVrtFields[nX][3],;
                               aVrtFields[nX][4],;
                               aVrtFields[nX][5],;
                               aVrtFields[nX][6] )
        EndIf
    Next nX
Return cAlias //End of RU06XFUN77_RetVrtLinesForPO

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN78_JoinOnF5MToF4B
Function creates join string for joining F5M line to F4B line

@param       Character cSupp      // Supplier code for E2_FORNECE
             Character cUnit      // Supplier unit for E2_LOJA
             
@return      Character cRet
@examples   
@author      astepanov
@since       October/23/2020
@version     1.0
@project     MA3
/*/
//-----------------------------------------------------------------------
Function RU06XFUN78_JoinOnF5MToF4B(cSupp,cUnit)

    Local cFS, cFE, cPS, cPE, cNS, cNE, cRS, cRE, cTS As Character
    Local cTE, cCS, cCE, cLS, cLE                     As Character
    Local cRet       As Character
    Local aKs        As Array

    aKs := RU06XFUN44_RetSE2FldsPosInFMKey()
    cFS := aKs[1][2]
    cFE := aKs[1][3]
    cPS := aKs[2][2]
    cPE := aKs[2][3]
    cNS := aKs[3][2]
    cNE := aKs[3][3]
    cRS := aKs[4][2]
    cRE := aKs[4][3]
    cTS := aKs[5][2]
    cTE := aKs[5][3]
    cCS := aKs[6][2]
    cCE := aKs[6][3]
    cLS := aKs[7][2]
    cLE := aKs[7][3]

    cRet := " F5M.F5M_FILIAL                               = '"+xFilial("F5M")+"' AND "
    cRet += " F5M.F5M_ALIAS                                = 'F4B'                AND "
    cRet += " F5M.F5M_IDDOC                                =  F4B.F4B_UUID        AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cFS+","+cFE+")) = TRIM(F4B.F4B_FLORIG) AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cPS+","+cPE+")) = TRIM(F4B.F4B_PREFIX) AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cNS+","+cNE+")) = TRIM(F4B.F4B_NUM)    AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cRS+","+cRE+")) = TRIM(F4B.F4B_PARCEL) AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cTS+","+cTE+")) = TRIM(F4B.F4B_TYPE)   AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cCS+","+cCE+")) = '"+cSupp+"'          AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cLS+","+cLE+")) = '"+cUnit+"'          AND "
    cRet += " F5M.D_E_L_E_T_                               = ' '                      "

Return cRet //End of RU06XFUN78_JoinOnF5MToF4B


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN79_JoinOnF5MToF48
Function creates join string for joining F5M line to F48 line

@param       Character cSupp      // Supplier code for E2_FORNECE
             Character cUnit      // Supplier unit for E2_LOJA
             
@return      Character cRet
@examples   
@author      astepanov
@since       October/27/2020
@version     1.0
@project     MA3
/*/
//-----------------------------------------------------------------------
Function RU06XFUN79_JoinOnF5MToF48(cSupp,cUnit)

    Local cFS, cFE, cPS, cPE, cNS, cNE, cRS, cRE, cTS As Character
    Local cTE, cCS, cCE, cLS, cLE                     As Character
    Local cRet       As Character
    Local aKs        As Array

    aKs := RU06XFUN44_RetSE2FldsPosInFMKey()
    cFS := aKs[1][2]
    cFE := aKs[1][3]
    cPS := aKs[2][2]
    cPE := aKs[2][3]
    cNS := aKs[3][2]
    cNE := aKs[3][3]
    cRS := aKs[4][2]
    cRE := aKs[4][3]
    cTS := aKs[5][2]
    cTE := aKs[5][3]
    cCS := aKs[6][2]
    cCE := aKs[6][3]
    cLS := aKs[7][2]
    cLE := aKs[7][3]

    cRet := " F5M.F5M_FILIAL                               = '"+xFilial("F5M")+"' AND "
    cRet += " F5M.F5M_ALIAS                                = 'F48'                AND "
    cRet += " F5M.F5M_IDDOC                                =  F48.F48_UUID        AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cFS+","+cFE+")) = TRIM(F48.F48_FLORIG) AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cPS+","+cPE+")) = TRIM(F48.F48_PREFIX) AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cNS+","+cNE+")) = TRIM(F48.F48_NUM)    AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cRS+","+cRE+")) = TRIM(F48.F48_PARCEL) AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cTS+","+cTE+")) = TRIM(F48.F48_TYPE)   AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cCS+","+cCE+")) = '"+cSupp+"'          AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cLS+","+cLE+")) = '"+cUnit+"'          AND "
    cRet += " F5M.D_E_L_E_T_                               = ' '                      "

Return cRet  //End of RU06XFUN79_JoinOnF5MToF48


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN80_Ret_VLIMP1_BSIMP1
We use this function when calculate _VLIMP1 or _BSIMP1
@param       Character cSEXKey    // Key for SE2 index #1 
                            filial+prefix+num+parcel+tipo+fornece+loja
                                // Key for SE1 index #2
                            E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
             Numeric   nValpay    // payment value
             Numeric   nSEXValor  // can be Nil, if Nil 
                                  // we get SE2->E2_VALOR (SE1->E1_VALOR)from search
             Numeric   nRnd       // how many numbers we leave after
                                  // point when round _VLIMP1
                                  // Default is 2
             
@return      Array     aRet       // {_VLIMP1,_BSIMP1}
@examples   
@author      astepanov
@since       October/29/2020
@edit        May/25/2022
@version     1.0
@project     MA3
Look at https://jiraproducao.totvs.com.br/browse/RULOC-44
Comments #3-6
/*/
//-----------------------------------------------------------------------
Function RU06XFUN80_Ret_VLIMP1_BSIMP1(cSEXKey,nValpay,nSEXValor,nRnd,cSEX)

    Local aRet        As Array
    Local aArea       As Array
    Local aSEXArea    As Array
    Local nSEXValimp  As Numeric
    Local cPr         As Character
    Default nRnd  := 2
    Default cSEX  := "SE2"

    aRet := {0,0}
    aArea      := GetArea()
    aSEXArea   := &(cSEX)->(GetArea())
    DBSelectArea(cSEX)
    If     cSEX == "SE2"
        DBSetOrder(1) //filial+prefix+num+parcel+tipo+fornece+loja
        cPr := "E2"
    Elseif cSEX == "SE1"
        DbSetOrder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
        cPr := "E1"
    EndIf
    If DBSeek(cSEXKey)
        nSEXValimp := &(cSEX+"->"+cPr+"_VALIMP1")
        If nSEXValor == Nil
            nSEXValor :=  &(cSEX+"->"+cPr+"_VALOR")
        EndIf
    Else
        nSEXValimp := 0
    EndIf
    RestArea(aSEXArea)
    RestArea(aArea)
    aRet[1]  := RU06XFUN82_Calc_VLIMP1(nValpay,nSEXValimp,nSEXValor,nRnd)
    aRet[2]  := nValpay - aRet[1]

Return aRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN81_RetCnvValues
According to passed Payment value ,_VLIMP1 and exchange rate
we calculate _VALCNV, _VLVATC, BSVATC according to rules previously
located in RU06XFUN20_VldValPay :
nValImp := oModelL:GetValue(cAliasL+"_VLIMP1")
oModelL:LoadValue(cAliasL+"_VALCNV",ROUND(nValLineFld * oModelL:GetValue(cAliasL + "_EXGRAT"), 2))
oModelL:LoadValue(cAliasL+"_VLVATC",ROUND(nValImp     * oModelL:GetValue(cAliasL + "_EXGRAT"), 2))
oModelL:LoadValue(cAliasL+"_BSVATC",oModelL:GetValue(cAliasL + "_VALCNV") - ;
                                    oModelL:GetValue(cAliasL + "_VLVATC")   )

@param       Numeric   nValpay    // payment value
             Numeric   nValImp    // _VLIMP1
             Numeric   nRnd       // how many numbers we leave after
                                  // point when round _VALCNV
                                  // default is 2
             
@return      Array     aRet       // {_VALCNV,_VLVATC,_BSVATC}
@examples   
@author      astepanov
@since       October/29/2020
@version     1.0
@project     MA3

/*/
//-----------------------------------------------------------------------
Function RU06XFUN81_RetCnvValues(nValPay,nValImp,nExgRat,nRnd)

    Local   aRet As Array
    Default nRnd := 2

    aRet    := {0,0,0} //{_VALCNV,_VLVATC,_BSVATC}
    aRet[1] := Round(nValPay*nExgRat,nRnd)
    aRet[2] := Round(nValImp*nExgRat,nRnd)
    aRet[3] := aRet[1] - aRet[2]

Return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN82_Calc_VLIMP1
This function used by RU06XFUN80_Ret_VLIMP1_BSIMP1 for _VLIMP1
calculation
_VLIMP1 = (nValpay * SE2->E2_VALIMP1)/SE2->E2_VALOR
@param       Numeric   nValpay    // payment value
             Numeric   nSE2Valimp // relates to SE2->E2_VALIMP1
             Numeric   nSE2Valor  // relates to SE2->E2_VALOR
             Numeric   nRnd       // how many numbers we leave after
                                  // point when round _VLIMP1
                                  // default is 2
             
@return      Numeric   nVlimp1
@examples   
@author      astepanov
@since       October/29/2020
@version     1.0
@project     MA3
/*/
//-----------------------------------------------------------------------
Function RU06XFUN82_Calc_VLIMP1(nValpay, nSE2Valimp, nSE2Valor, nRnd)
    Local nVlimp1 As Numeric
    Default nRnd := 2
    nVlimp1 := ROUND((nValpay*nSE2Valimp)/nSE2Valor,nRnd)
Return nVlimp1

/*/{Protheus.doc} RU06XFUN83_Add_Info_In_Rate_Diff_Doc
@type           
@description    Adding information about the code and GIUD of the main document to a new document 
                that is created when converting the amount of the main document for the difference in exchange rates.
@author         Nikita.Lysenko
@since          06/04/2021
@version        1.0
@project        MA3 - Russia
/*/
Function RU06XFUN83_Add_Info_In_Rate_Diff_Doc(aTitulo, cF5qcode, cF5quid,dDtLib)
    AADD (aTitulo, {"E2_F5QCODE",   cF5qcode,	Nil})
    AADD (aTitulo, {"E2_F5QUID",    cF5quid,	Nil})
    AADD (aTitulo, {"E2_DATALIB",    dDtLib,	Nil})
Return aTitulo


//--------------------------------------------------------------------------
/*/{Protheus.doc}FA330Filt
Filter for AR list

@author Cherchik Konstantin
@since  14/12/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function FA330Filt(oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,cVarQ,oPanel,dEmissao,cOrigem,lCredito,aNumLay,cNumCont)
	Local cPerg		as Character
	Local lRet		as Logical
	Local cParCont	as Character

	Private aFilter as Array

	cParCont	:= MV_PAR02
    If Type("lFilterMark") == 'U' .And. ValType(lFilterMark) == 'U'
        Private lFilterMark := .F.
    EndIf 
	lFilterMark	:= MsgYesNo(STR0090,STR0089)    // Filter will unmark all selections, do you agree? ## Filter 
    cPerg       :=""
    lRet        :=.F.
    aFilter     := {}


	If lFilterMark
		cPerg := "AF3301"
	    lRet  := Pergunte(cPerg,.T.,STR0089)    // Filter
		If lRet
			cTitFilt := ""			
			Aadd(aFilter, MV_PAR01)	//From E1_PREFIXO
			Aadd(aFilter, MV_PAR02)	//To E1_PREFIXO
			Aadd(aFilter, MV_PAR03)	//From E1_NUM
			Aadd(aFilter, MV_PAR04)	//To E1_NUM
			Aadd(aFilter, MV_PAR05)	//From E1_TIPO
			Aadd(aFilter, MV_PAR06)	//To E1_TIPO
			Aadd(aFilter, MV_PAR07)	//From E1_MOEDA 
			Aadd(aFilter, MV_PAR08)	//To E1_MOEDA
			Aadd(aFilter, MV_PAR09)	//From E1_CLIENTE
			Aadd(aFilter, MV_PAR10)	//To E1_CLIENTE
			Aadd(aFilter, MV_PAR11)	//From E1_F5QCODE
			Aadd(aFilter, MV_PAR12)	//To E1_F5QCODE
			Aadd(aFilter, MV_PAR13)	//From E1_EMISSAO
			Aadd(aFilter, MV_PAR14)	//To E1_EMISSAO
			Pergunte("FIN330",.F.)

			cTitFilt += " SE1.E1_PREFIXO >= '" + aFilter[1] + "' AND SE1.E1_PREFIXO <= '" + aFilter[2] + "'" 
			cTitFilt += " AND SE1.E1_NUM >= '" + aFilter[3] + "' AND SE1.E1_NUM <= '" + aFilter[4] + "'"
			cTitFilt += " AND SE1.E1_TIPO >= '" + aFilter[5] + "' AND SE1.E1_TIPO <= '" + aFilter[6] + "'"
			cTitFilt += " AND SE1.E1_MOEDA >= " + AllTrim(Str(aFilter[7])) + " AND SE1.E1_MOEDA <= " + AllTrim(Str(aFilter[8])) + ""
			cTitFilt += " AND SE1.E1_CLIENTE >= '" + aFilter[9] + "' AND SE1.E1_CLIENTE <= '" + aFilter[10] + "'"
			cTitFilt += " AND SE1.E1_F5QCODE >= '" + aFilter[11] + "' AND SE1.E1_F5QCODE <= '" + aFilter[12] + "'"
			cTitFilt += " AND SE1.E1_EMISSAO >= '" + DTOS(aFilter[13]) + "' AND SE1.E1_EMISSAO <= '" + DTOS(aFilter[14]) + "' AND "

			Fa330TitEx(dEmissao,cOrigem,lCredito,aNumLay,lAutomato,cNumCont)  //Generates Table with titles - aTitulos:
		EndIf
	EndIf

	MV_PAR02 := cParCont
	oTitulo:SetArray(aTitulos)
	If MV_PAR02 == 2
		oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,1],;
				aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
				aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,23],aTitulos[oTitulo:nAt,6],;
				If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,18],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,11],;
				aTitulos[oTitulo:nAt,15],aTitulos[oTitulo:nAt,19],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,20],;
				aTitulos[oTitulo:nAt,21],aTitulos[oTitulo:nAt,22]}}
	Else
		oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
				aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
				aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,20],aTitulos[oTitulo:nAt,6],;
				If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,15],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,16],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,17],;
				aTitulos[oTitulo:nAt,18],aTitulos[oTitulo:nAt,19]}}
	EndIf
	oTitulo:Refresh()
	Pergunte("FIN330",.F.)    
Return


//--------------------------------------------------------------------------
/*/{Protheus.doc}FA330Unfil
Function to remove the filter from the listbox

@author Cherchik Konstantin
@since  13/12/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function FA330Unfil(oTitulo,aTitulos,lAutomato,oOk,oNo,dEmissao,cOrigem,lCredito,aNumLay,cNumCont)
	Local lUnfilter	as Logical

	lUnfilter := MsgYesNo(STR0092,STR0091)  	// Unfilter will unmark all selections, do you agree? ## Unfilter

	If lUnfilter
		cTitFilt := ""
		Fa330TitEx(dEmissao,cOrigem,lCredito,aNumLay,lAutomato, cNumCont)
		If MV_PAR02 == 2
			oTitulo:SetArray(aTitulos)
			oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
					aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,1],;
					aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
					aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
					aTitulos[oTitulo:nAt,23],aTitulos[oTitulo:nAt,6],;
					If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,18],;
					aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,11],;
					aTitulos[oTitulo:nAt,15],aTitulos[oTitulo:nAt,19],;
					aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,20],;
					aTitulos[oTitulo:nAt,21],aTitulos[oTitulo:nAt,22]}}
			oTitulo:Refresh()
			Pergunte("FIN330",.F.)
		Else
			oTitulo:SetArray(aTitulos)
			oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
					aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
					aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
					aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
					aTitulos[oTitulo:nAt,20],aTitulos[oTitulo:nAt,6],;
					If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,15],;
					aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,16],;
					aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,17],;
					aTitulos[oTitulo:nAt,18],aTitulos[oTitulo:nAt,19]}}
			oTitulo:Refresh()
			Pergunte("FIN330",.F.)
		EndIf
	EndIf

Return

//--------------------------------------------------------------------------
/*/{Protheus.doc}FA330AutMk
Function for Auto Mark

@author Cherchik Konstantin
@since  12/11/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function FA330AutMk(oTitulo,aTitulos,lAutomato,oOk,oNo,dEmissao,cOrigem,lCredito,aNumLay,cNumCont)

	Local nOpcB as Numeric
    Local oDlg as Object
    Local oGet01 as Object 

	DEFINE MSDIALOG oDlg FROM  94,1 TO 273,233 TITLE STR0082 PIXEL  //Auto Mark
	@ 05,17 Say STR0083 SIZE 110,7 OF oDlg PIXEL        // Value to clear
	@ 22,07 TO 72, 100 OF oDlg  PIXEL
	@ 30,20 MSGET oGet01 VAR nValor PICTURE "@E 999,999,999.99" Valid .T. WHEN .T. PIXEL OF oDlg SIZE 70,7 HASBUTTON	

	DEFINE SBUTTON FROM 75,045 TYPE 1 ENABLE OF oDlg ACTION (nOpcB := 1,Iif(nValor >= 0 .AND. nValor <= nSaldo,oDlg:End(),EVAL({|| Help("",1,"FA330ValClrVld",,STR0084,1,0) , .F. })))  //You have entered the value that exceeds the limit
	DEFINE SBUTTON FROM 75,75 TYPE 2 ENABLE OF oDlg ACTION (nOpcB := 0,oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpcB := 0, .T.)    

	If nOpcB == 1 .And. MV_PAR02 == 2
		FA330Sort(oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,,nValTot,dEmissao,cOrigem,lCredito,aNumLay)
        Fa330TitEx(dEmissao,cOrigem,lCredito,aNumLay,lAutomato,cNumCont) //Generates Table with titles - aTitulos:
		oTitulo:SetArray(aTitulos)
		oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,1],;
				aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
				aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,23],aTitulos[oTitulo:nAt,6],;
				If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,18],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,11],;
				aTitulos[oTitulo:nAt,15],aTitulos[oTitulo:nAt,19],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,20],;
				aTitulos[oTitulo:nAt,21],aTitulos[oTitulo:nAt,22]}}
		oTitulo:Refresh()	
	ElseIf nOpcB == 1
		FA330Sort(oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,,nValTot,dEmissao,cOrigem,lCredito,aNumLay)
		Fa330TitEx(dEmissao,cOrigem,lCredito,aNumLay,lAutomato,cNumCont) //Generates Table with titles - aTitulos:
		oTitulo:SetArray(aTitulos)
		oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
				aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
				aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,20],aTitulos[oTitulo:nAt,6],;
				If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,15],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,16],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,17],;
				aTitulos[oTitulo:nAt,18],aTitulos[oTitulo:nAt,19]}}
		oTitulo:Refresh()	
	Endif
Return

//--------------------------------------------------------------------------
/*/{Protheus.doc}FINA340Sort
Sorting for AR list

@author Cherchik Konstantin
@since  13/12/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function FA330Sort (oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,oPanel,nValTot,dEmissao,cOrigem,lCredito,aNumLay)
	Local nX		as Numeric
	Local nOpcS		as Numeric
    Local aPayTypes as Array
    Local oDlg      as Object
    Local oCbx      as Object
    Local oRadio    as Object 


    aPayTypes   := {}
    oDlg        :=nil
    oCbx        :=nil

	If !IsInCallStack("FA330AutMk")		
		For nX := 2 To Len(oTitulo:AHEADERS) 
			Aadd(aPayTypes, oTitulo:AHEADERS[nX]) 
		Next

		aDel(aPayTypes,9) // We can not sort and set "clear value"  at the same time, in column that contains values to clear.

		DEFINE MSDIALOG oDlg FROM  94,1 TO 273,293 TITLE STR0085 PIXEL  	//Sorting
		@ 10,17 Say STR0086 SIZE 150,7 OF oDlg PIXEL 		// Order
		@ 27,07 TO 72, 140 OF oDlg  PIXEL
		@ 34,13 COMBOBOX oCbx VAR cPayType ITEMS aPayTypes SIZE 120, 27 OF oDlg PIXEL
		@ 50,13 Radio 	oRadio VAR nRadio; 
			ITEMS 	STR0087,;			// Ascending
					STR0088;			// Descending
			SIZE 110,10 OF oDlg PIXEL
		DEFINE SBUTTON FROM 75,085 TYPE 1 ENABLE OF oDlg ACTION (nOpcS := 1,FA330Combo(cPayType, oDlg,oCbx,@nSel))
		DEFINE SBUTTON FROM 75,115 TYPE 2 ENABLE OF oDlg ACTION (nOpcS := 0,FA330Combo(cPayType, oDlg,oCbx,@nSel))
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpcS := 0, .T.)    
	EndIf

	/* Due to the fact that the arrays aTitulos & aHeaders are out of sync, the sort function must be synchronized in this form */

	If MV_PAR02 == 2
	DO Case
			Case nSel == 1
				cSortField := "E1_FILIAL "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[16] < y[16] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[16] > y[16] } )		
				Endif 
			Case nSel == 2
				cSortField := "E1_PREFIXO, E1_NUM "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[1]+x[2] < y[1]+y[2] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[1]+x[2] > y[1]+y[2] } )		
				Endif  
			Case nSel == 3
				cSortField := "E1_NUM "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[2] < y[2] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[2] > y[2] } )
				Endif	  
			Case nSel == 4
				cSortField := "E1_PARCELA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[3] < y[3] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[3] > y[3] } )
				Endif	 
			Case nSel == 5
				cSortField := "E1_TIPO "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[4] < y[4] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[4] > y[4] } )
				Endif	
			Case nSel == 6
				cSortField := "E1_MOEDA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[9] < y[9] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[9] > y[9] } )
				Endif	 
			Case nSel == 7
				cSortField := "E1_MOEDA "	//CTO_SIMB
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[23] < y[23] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[23] > y[23] } )
				Endif	
			Case nSel == 8
				cSortField := "E1_SALDO "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[6] < y[6] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[6] > y[6] } )
				Endif	 
			Case nSel == 9
				cSortField := "E1_CLIENTE "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[18] < y[18] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[18] > y[18] } )
				Endif	 
			Case nSel == 10
				cSortField := "E1_LOJA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[5] < y[5] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[5] > y[5] } )
				Endif	  
			Case nSel == 11
				cSortField := "E1_CLIENTE, E1_LOJA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[18]+x[5] < y[18]+y[5] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[18]+x[5] > y[18]+y[5] } )
				Endif	
			Case nSel == 12
				cSortField := "E1_HIST "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[15] < y[15] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[15] > y[15] } )
				Endif	
			Case nSel == 13
				cSortField := "E1_F5QCODE "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[19] < y[19] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[19] > y[19] } )
				Endif	
			Case nSel == 14
				cSortField := "E1_EMISSAO "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[10] < y[10] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[10] > y[10] } )
				Endif	  
			Case nSel == 15
				cSortField := "E1_VALOR "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[20] < y[20] } ) 
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[20] > y[20] } )
				Endif	
			Case nSel == 16
				cSortField := "E1_VLCRUZ "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[21] < y[21] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[21] > y[21] } )
				Endif	
			Case nSel == 17
				cSortField := "E1_CONUNI "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[22] < y[22] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[22] > y[22] } )
				Endif	 
			Otherwise
				cSortField := "E1_FILIAL "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[2] < y[2] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[2] > y[2] } )
				Endif	 
		EndCase
			
        Fa330TitEx(dEmissao,cOrigem,lCredito,aNumLay,lAutomato,cNumCont) //Generates Table with titles - aTitulos:	
		oTitulo:SetArray(aTitulos)
        oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
                aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,1],;
                aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
                aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
                aTitulos[oTitulo:nAt,23],aTitulos[oTitulo:nAt,6],;
                If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,18],;
                aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,11],;
                aTitulos[oTitulo:nAt,15],aTitulos[oTitulo:nAt,19],;
                aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,20],;
                aTitulos[oTitulo:nAt,21],aTitulos[oTitulo:nAt,22]}}
        oTitulo:Refresh()
	Else
		DO Case
			Case nSel == 1
				cSortField := "E1_FILIAL "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[13] < y[13] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[13] > y[13] } )		
				Endif 
			Case nSel == 2
				cSortField := "E1_PREFIXO, E1_NUM "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[1]+x[2] < y[1]+y[2] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[1]+x[2] > y[1]+y[2] } )		
				Endif  
			Case nSel == 3
				cSortField := "E1_NUM "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[2] < y[2] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[2] > y[2] } )
				Endif	  
			Case nSel == 4
				cSortField := "E1_PARCELA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[3] < y[3] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[3] > y[3] } )
				Endif	 
			Case nSel == 5
				cSortField := "E1_TIPO "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[4] < y[4] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[4] > y[4] } )
				Endif	
			Case nSel == 6
				cSortField := "E1_MOEDA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[9] < y[9] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[9] > y[9] } )
				Endif	 
			Case nSel == 7
				cSortField := "E1_MOEDA "	//CTO_SIMB
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[20] < y[20] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[20] > y[20] } )
				Endif	
			Case nSel == 8
				cSortField := "E1_SALDO "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[6] < y[6] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[6] > y[6] } )
				Endif	 	 
			Case nSel == 9
				cSortField := "E1_CLIENTE "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[15] < y[15] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[15] > y[15] } )
				Endif	 
			Case nSel == 10
				cSortField := "E1_LOJA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[5] < y[5] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[5] > y[5] } )
				Endif	  
			Case nSel == 11
				cSortField := "E1_F5QCODE "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[16] < y[16] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[16] > y[16] } )
				Endif	
			Case nSel == 12
				cSortField := "E1_EMISSAO "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[10] < y[10] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[10] > y[10] } )
				Endif	  
			Case nSel == 13
				cSortField := "E1_VALOR "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[17] < y[17] } ) 
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[17] > y[17] } )
				Endif	
			Case nSel == 14
				cSortField := "E1_VLCRUZ "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[18] < y[18] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[18] > y[18] } )
				Endif	
			Case nSel == 15
				cSortField := "E1_CONUNI "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[19] < y[19] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[19] > y[19] } )
				Endif	 
			Otherwise
				cSortField := "E1_FILIAL "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[2] < y[2] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[2] > y[2] } )
				Endif	 
		EndCase
			
        Fa330TitEx(dEmissao,cOrigem,lCredito,aNumLay,lAutomato,cNumCont) //Generates Table with titles - aTitulos:	
		oTitulo:SetArray(aTitulos)
		oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
				aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
				aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,20],aTitulos[oTitulo:nAt,6],;
				If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,15],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,16],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,17],;
				aTitulos[oTitulo:nAt,18],aTitulos[oTitulo:nAt,19]}}
		oTitulo:Refresh()	
	EndIf
Return


//--------------------------------------------------------------------------
/*/{Protheus.doc}FA330Combo
Function for buttons of FA330Sort

@author Cherchik Konstantin
@since  13/12/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function FA330Combo(cPayType, oDlg,oCbx, nSel)
	nSel := oCbx:nAt
	oDlg:End()
Return

/*/{Protheus.doc} RU06XFUN84_StandQueryFilter
@type           Function
@description    We determine from which routine the standard query was called to set the filter we need and the table from which the selection will be made.
@author         Nikita.Lysenko
@since          12/05/2021
@version        1.0
@project        MA3 - Russia
/*/
Function RU06XFUN84_StandQueryFilter()
    Local lRet as Logical

    lRet := .F.

    Do Case
        Case !EMPTY(M->F47_SUPP) //RU06D04  F47 Table
            lRet := F5Q->F5Q_STATUS=="1".AND.M->F47_SUPP==F5Q->F5Q_A2COD.AND.M->F47_UNIT==F5Q->F5Q_A2LOJ.AND.!EMPTY(AllTrim(F5Q->F5Q_A2COD)) //Filter from F5QF47 (SXB)
        Case !EMPTY(M->F49_SUPP) //RU06D05  F49 Table
            lRet := F5Q->F5Q_STATUS=="1".AND.M->F49_SUPP==F5Q->F5Q_A2COD.AND.M->F49_UNIT==F5Q->F5Q_A2LOJ.AND.!EMPTY(AllTrim(F5Q->F5Q_A2COD)) //Filter from F5QF49 (SXB)
        Case !EMPTY(M->F4C_SUPP) .OR. !EMPTY(M->F4C_CUST) //RU06D07  F4C Table
            lRet := F5Q->F5Q_STATUS=="1".AND.((M->F4C_SUPP==F5Q->F5Q_A2COD.AND.M->F4C_UNIT==F5Q->F5Q_A2LOJ).OR.(M->F4C_CUST==F5Q->F5Q_A1COD.AND.M->F4C_CUNI==F5Q->F5Q_A1LOJ)) //Filter from F5QF4C (SXB)
    EndCase
Return lRet

/*/{Protheus.doc} RU06XFUN85_LegContractsCheck
@type           Function
@description    Checking suppliers when filling out the header with the contract.
                Informing the user about the availability of suppliers with several different contracts, if any.
@author         Nikita.Lysenko
@since          12/05/2021
@version        1.0
@project        MA3 - Russia
/*/
Function RU06XFUN85_LegContractsCheck(cActivRtn, nCnt)
    Local lRet          As Logical
    Local oSubModel     As Object
    Local oModel        As Object
    Local nX            As Numeric
    Local cNameField    As Character

    nX      := 1
    lRet    := .F.
    oModel  := FwModelActive()

    Do Case
        Case cActivRtn == 'RU06D04' //RU06D04  F47 Table
            oSubModel  := oModel:GetModel("RU06D04_MLNS")
            cNameField := "F48_MDCNTR"
        Case cActivRtn == 'RU06D05' //RU06D05  F49 Table
            oSubModel  := oModel:GetModel("RU06D05_MVIRT")
            cNameField := "B_MDCNTR"
        Case cActivRtn == 'RU06D07' //RU06D07  F4C Table
            oSubModel  := oModel:GetModel("RU06D07_MVIRT")
            cNameField := "B_MDCNTR"
    EndCase

    Do While lRet == .F. .AND. oSubModel:Length() >= nX
        oSubModel:GoLine(nX)
        If !(oSubModel:GetValue(cNameField) == nCnt)
            lRet := .T.
        EndIf
        nX ++
    Enddo

    If !IsBlind() .AND. !(oSubModel:IsEmpty()) .AND. lRet
        MsgAlert(STR0093)
    Else
        lRet := .T.
    EndIf
Return lRet
/*/{Protheus.doc} RU06XFUN86_GetLastInstallmentValue
@type           
@description    When we post last part of AP in foregn currency or in
                conventional units, we store calculated numeric values.
                During calculations we use rounding, we accumulate rounding
                error and when we post last part of AP we should exclude this error.
                When we post part of AP in conventional units we should get correct values
                for exchange rate revaluation. When we post AP in foreign currency
                we should get correct values for posting correct value in local currency.
                For this case we get data from FK7, FK2\FK1 and SFR tables. If you check
                SQL query we get totals by SFR_VALOR, FK_VLMOE2 and FK_VALOR according
                to content in FK7_CHAVE. For details look at the specification.
                The same SQL query used by RU06XFUN89_GetRebuildList
                It could be used for receivables and payables                
@param          Character    cFK7Chave // string formatted to FK7_CHAVE length
                Character    cTab      // alias to table with AP, "SE2"
@return         Array        aRet      // {FKVLMOE2,SFRVALOR,FKVALOR}
@author         astepanov
@since          01 June 2021
@specification  FI-AP-15-11
@project        MA3 - Russia
/*/
Function RU06XFUN86_GetLastInstallmentValue(cFK7Chave,cTab)
    Local aRet       As Array
    Local cQuery     As Character
    Local cAlias     As Character
    Local cSFRChavor As Character
    Local aSFRChavor As Array   
    Local nX         As Numeric   
    Local cFk        As Character
    Local cPositive  As Character
    Local cNegative  As Character

    Default cFK7Chave := " "
    Default cTab      := "SE2"
    cFK7Chave  := PADR(cFK7Chave, GetSX3Cache("FK7_CHAVE","X3_TAMANHO"), " ")
    cSFRChavor := SUBSTR(cFK7Chave,Len(xFilial("SE2"))+1)
    If cTab == "SE1"
        cFk:="FK1"
        cPositive   := 'R'
        cNegative   := 'P'
        aSFRChavor:=Separa(alltrim(cFK7Chave), "|", .T.)
        cSFRChavor:= aSFRChavor[len(aSFRChavor)-1]
        cSFRChavor+= aSFRChavor[len(aSFRChavor)]
        For nX:=2 to Len(aSFRChavor)-2
            cSFRChavor+= aSFRChavor[nX]
        Next nX    
    ELSE
        cFk:="FK2"
        cSFRChavor  := STRTRAN(cSFRChavor, "|", "")
        cPositive   := 'P'
        cNegative   := 'R'
    Endif
    cSFRChavor := PADR(cSFRChavor,GetSX3Cache("FR_CHAVOR","X3_TAMANHO"), " ")
    aRet       := {0,0,0}
    cQuery := "SELECT SUM("+cFk+"VLMOE2)  FKVLMOE2,                                     "
    cQuery += "       SUM(SFRVALOR)  SFRVALOR,                                          "
    cQuery += "       SUM("+cFk+"VALOR)   FKVALOR                                       "
    cQuery += "FROM (                                                                   "
    cQuery += " SELECT BAL.SUMVLMOE2  "+cFk+"VLMOE2,                                    "
    cQuery += "        0              SFRVALOR,                                         "
    cQuery += "        BAL.SUMFVALOR  "+cFk+"VALOR                                      "
    cQuery += " FROM (                                                                  "
    cQuery += "   SELECT  SUM(TMP."+cFk+"_VLMOE2)                 SUMVLMOE2,            "
    cQuery += "           SUM(TMP."+cFk+"_VALOR)                  SUMFVALOR             "
    cQuery += "   FROM (                                                                "
    cQuery += "     SELECT  FK7.FK7_CHAVE  FK7_CHAVE,                                   "
    cQuery += "             FK7.FK7_IDDOC  FK7_IDDOC,                                   "
    cQuery += "        " +cFk+"."+cFk+"_VLMOE2 "+cFk+"_VLMOE2,                          "
    cQuery += "             " +cFk+"."+cFk+"_VALOR  "+cFk+"_VALOR                       "
    cQuery += "     FROM   " + RetSQlName("FK7") + " FK7                                "
    cQuery += "     INNER JOIN                                                          "
    cQuery += "    ( SELECT " +cFk+"."+cFk+"_IDDOC  "+cFk+"_IDDOC,                      "
    cQuery += "   CASE  WHEN "+cFk+"."+cFk+"_RECPAG = '"+cPositive+"' THEN              "
    cQuery += "                                       "+cFk+"."+cFk+"_VLMOE2            "
    cQuery += "                   WHEN "+cFk+"."+cFk+"_RECPAG = '"+ cNegative +"' THEN  "
    cQuery += "                                       0 - "+cFk+"."+cFk+"_VLMOE2        "
    cQuery += "             END            "+cFk+"_VLMOE2,                              "
    cQuery += "             CASE  WHEN "+cFk+"."+cFk+"_RECPAG = '"+cPositive+"' THEN    "
    cQuery += "                                       "+cFk+"."+cFk+"_VALOR             "
    cQuery += "                   WHEN "+cFk+"."+cFk+"_RECPAG = '"+ cNegative +"' THEN  "
    cQuery += "                                       0 - "+cFk+"_VALOR                 "
    cQuery += "             END            "+cFk+"_VALOR                                "
    cQuery += "      FROM   " + RetSQlName(cFk) + " "+cFk+"                             "
    cQuery += "      WHERE "+cFk+"."+cFk+"_FILIAL = '" + xFilial(cFk) + "'              "
    cQuery += "        AND "+cFk+".D_E_L_E_T_ = ' '                                     "
    cQuery += "    )                                  "+cFk+"                           "
    cQuery += "     ON FK7.FK7_IDDOC = "+cFk+"."+cFk+"_IDDOC                            "
    cQuery += "     WHERE FK7.FK7_FILIAL = '" + xFilial("FK7") + "'                     "
    cQuery += "       AND FK7.FK7_ALIAS  = '" +      cTab      + "'                     "
    cQuery += "       AND FK7.FK7_CHAVE  = '" +    cFK7Chave   + "'                     " 
    cQuery += "       AND FK7.D_E_L_E_T_ = ' '                                          "
    cQuery += "        ) TMP                                                            "
    cQuery += "   GROUP BY TMP.FK7_IDDOC                                                "
    cQuery += "      ) BAL                                                              "
    cQuery += " UNION ALL                                                               "
    cQuery += " SELECT 0                          "+cFk+"VLMOE2,                        "
    cQuery += "        COALESCE(SFR.SFRVALOR,0)   SFRVALOR,                             "
    cQuery += "        0                          "+cFk+"VALOR                          "
    cQuery += " FROM (                                                                  "
    cQuery += "         SELECT SUM(SFR.FR_VALOR) SFRVALOR                               "
    cQuery += "         FROM    "+RetSqlName("SFR")+ "  SFR                             "
    cQuery += "         WHERE SFR.FR_FILIAL  = '" + xFilial("SFR") + "'                 "
    cQuery += "           AND SFR.FR_TIPODI  = 'S'                                      "
    cQuery += "           AND SFR.FR_CHAVOR  = '" +   cSFRChavor   + "'                 "
    cQuery += "           AND SFR.D_E_L_E_T_ = ' '                                      "
    cQuery += "      ) SFR                                                              "
    cQuery += "     ) RES                                                               "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    TCSetField(cAlias,"FKVLMOE2","N",GetSx3Cache (cFk+"_VLMOE2","X3_TAMANHO"),GetSx3Cache(cFk+"_VLMOE2","X3_DECIMAL"))
    TCSetField(cAlias,"SFRVALOR" ,"N",GetSx3Cache("FR_VALOR"  ,"X3_TAMANHO"),GetSx3Cache("FR_VALOR"  ,"X3_DECIMAL"))
    TCSetField(cAlias,"FKVALOR" ,"N",GetSx3Cache(cFk+"_VALOR" ,"X3_TAMANHO"),GetSx3Cache(cFk+"_VALOR" ,"X3_DECIMAL"))
    aArea  := GetArea()
    DBSelectArea(cAlias)
    DBGoTop()
    If !Eof()
        aRet[1] := FKVLMOE2
        aRet[2] := SFRVALOR
        aRet[3] := FKVALOR
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
Return aRet
/*/{Protheus.doc} RU06XFUN87_CheckFR_DATADI
@type           
@description    For correct work we should be positioned on correct SE2 record.
                We can post two parts the same AP (in foreign currency or in
                conventional units) on same date. When we post first part we
                calculate exchange rate difference according to accounting rules.
                When we post the second part we don't calculate and don't post
                exchange rate difference. We have problem when we post on same
                date two AP parts with different exchange rates.
                So we should check this case and we use this function for checking.
                So we can check:
                1) Do we have posted exchange rate difference on dDate for our AP?
                2) If yes. Which exchange rate was used for this posting?
@param          Character    cAliasTab // alias to table with AP, "SE2"
                Date         dDate     // FR_DATADI date for check
@return         Array        aRet      // {Nil,Nil} or {FR_DATADI,FR_TXATU}
@author         astepanov
@since          01 June 2021
@specification  FI-AP-15-11
@project        MA3 - Russia
/*/
Function RU06XFUN87_CheckFR_DATADI(cAliasTab,dDate)
    Local aRet      As Array
    Local aArea     As Array
    Local aAreaSFR  As Array
    Local cChave    As Character
    Local cAlias    As Character
    Local cQuery    As Character
    Local cCarteira As Character
    If  cAliasTab == "SE2"
        cChave := (cAliasTab)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
        cCarteira := '2'
    ElseIf cAliasTab == "SE1"
        cChave := (cAliasTab)->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
        cCarteira := '1'
    Endif

	cChave := PADR(cChave, GetSX3Cache("FR_CHAVOR","X3_TAMANHO")," ")
    aArea    := GetArea()
    aAreaSFR := SFR->(GetArea())
    cQuery :=  " SELECT SFR.FR_DATADI  FR_DATADI,                    "
    cQuery +=  "        SFR.FR_TXATU   FR_TXATU                      "
    cQuery +=  " FROM   "+RetSqlName("SFR")+"  SFR                   "
    cQuery +=  " WHERE   SFR.FR_FILIAL  = '"+xFilial("SFR")   + "'   "
    cQuery +=  "   AND   SFR.FR_CARTEI  = '"+   cCarteira        + "'   "
    cQuery +=  "   AND   SFR.FR_CHAVOR  = '"+   cChave        + "'   "
    cQuery +=  "   AND   SFR.FR_DATADI  = '"+ DTOS(dDate)     + "'   "
    cQuery +=  "   AND   SFR.D_E_L_E_T_ = ' '                        "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    TCSetField(cAlias,"FR_TXATU","N",GetSx3Cache("FR_TXATU","X3_TAMANHO"),GetSx3Cache("FR_TXATU","X3_DECIMAL"))
    DBSelectArea(cAlias)
    (cAlias)->(DBGoTop())
    aRet := {Nil, Nil}
    If (cAlias)->(!Eof())
        aRet[1] := STOD((cAlias)->FR_DATADI)
        aRet[2] := (cAlias)->FR_TXATU
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aAreaSFR)
    RestArea(aArea)
Return aRet
/*/{Protheus.doc} RU06XFUN88_GetRevaluationList
@type           
@description    When we post or unpost AP in foreign currency or in conventional units in
                nonchronological order, we must mark all future exchange rate revaluations
                for rebuilding. They should be recalculated again.
                This fuction should be runned in transaction mode only.
                Be careful, we don't unlock here SFR records, they should be unlocked 
                in top procedure by callstack. At current moment they will be unlocked in 
                RU06D07.
@param          Character    cFR_CHAVOR  // string formatted according to FR_CHAVOR
                Date         dTranDate   // date of operation
                Character    cCarteira  // Type of the operation 1-Receivable, 2-Payable
                Logical      lOnlyGet   // We only get this list and do not change SFR->FR_RBDBAL to "1"
@return         Array        {aRecs,lOk} // aRecs contains recno list of SFR records
                                         // with FR_RBDBAL == "1", in case
                                         // we can't lock SFR recno or RBDBAL == "3"
                                         // lOk will be set to .F. 
@author         astepanov
@since          01 June 2021
@specification  FI-AP-15-11
@project        MA3 - Russia
/*/
Function RU06XFUN88_GetRevaluationList(cFR_CHAVOR,dTranDate,cCarteira,lOnlyGet)
    Local aRecs    As Array
    Local cAlias   As Character
    Local cQuery   As Character
    Local aArea    As Array
    Local aAreaSFR As Array
    Local lOk      As Logical

    Default cCarteira:="2"
    Default lOnlyGet := .F.
    aRecs := {}
    lOk   := .T.
    aArea := GetArea()
    aAreaSFR := SFR->(GetArea())
    cFR_CHAVOR := PADR(cFR_CHAVOR,GetSX3Cache("FR_CHAVOR","X3_TAMANHO")," ")
    cQuery :=  " SELECT SFR.R_E_C_N_O_ SFRRECNO                      "
    cQuery +=  " FROM   "+RetSqlName("SFR")+"  SFR                   "
    cQuery +=  " WHERE   SFR.FR_FILIAL  = '"+xFilial("SFR")   + "'   "
    cQuery +=  "   AND   SFR.FR_CARTEI  = '"+   cCarteira        + "'   "
    cQuery +=  "   AND   SFR.FR_CHAVOR  = '"+   cFR_CHAVOR    + "'   "
    cQuery +=  "   AND   SFR.FR_DATADI  > '"+ DTOS(dTranDate) + "'   "
    cQuery +=  "   AND   SFR.FR_TIPODI  = 'S'                        "
    cQuery +=  "   AND   SFR.FR_RBDBAL <> '3'                        "
    cQuery +=  "   AND   SFR.D_E_L_E_T_ = ' '                        "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    DBSelectArea(cAlias)
    (cAlias)->(DBGoTop())
    While (cAlias)->(!Eof())
        SFR->(DBGoto((cAlias)->(SFRRECNO)))
        If RecLock("SFR",.F.)
            AADD(aRecs,(cAlias)->(SFRRECNO))
            If !(SFR->FR_RBDBAL == "3")
                If !lOnlyGet
                    SFR->FR_RBDBAL := "1"
                EndIf
            Else
                lOk := .F.
                Exit    
            EndIf
        Else
            lOk := .F.
            Exit
        EndIf
        (cAlias)->(DBSkip())
    Enddo
    (cAlias)->(DBCloseArea())
    RestArea(aAreaSFR)
    RestArea(aArea)
Return {aRecs,lOk}

/*/{Protheus.doc} RU06XFUN89_GetRebuildList
@type           
@description    When we create exchange rate differences for selected AP's
                on date dOperDate, we should get all revaluations before dOperDate
                and select items which need rebuilding(FR_RBDBAL == "1").
                Also we get total values by FK2_VLMOE2, FK2_VALOR and SFR_VALOR.
                Look a query in RU06XFUN86_GetLastInstallmentValue.
                We sort items by special rules. For details look at specification.
@param          Array        aSE2Recnos  // array of SE2 recnos
                Date         dOperDate   // date of operation
                Character    cTable     // SE1 OR SE2                   
@return         Array        aList       // {{Se2Recno,SFRVLTOT,FK2VMTOT,FK2VRTOT,;
                                              {SFRRECNO,FRDATADI,FRIDWTOFF,FRCHAVOR,AFTE2BAIXA}}
                                            ...
                                            }
@author         astepanov
@since          01 June 2021
@specification  FI-AP-15-11
@project        MA3 - Russia
/*/
Function RU06XFUN89_GetRebuildList(aSEXRecnos,dOperDate,cTable)
    Local aList      As Array
    Local aArea      As Array
    Local aAreaSE2   As Array
    Local aAreaSE1   as Array
    Local aAreaSFR   As Array
    Local aTmpFld    As Array
    Local aTmpRec    As Array
    Local cQuery     As Character
    Local cAlias     As Character
    Local cAlsTmp    As Character
    Local cFrKey     as Character   
    Local cUNQKEY    as Character
    Local cFK7C      as Character
    Local cDtBx      as Character
    Local cFk        as Character
    Local cCarteira  as Character
    Local cPositive  as Character
    Local cNegative  as Character
    Local oTmp       As Object
    Local nX         As Numeric
    Local nY         As Numeric
    Local nStat      As Numeric
    Local nPos       As Numeric

	Default cTable :="SE2" 

    aList    := {}
    aTmpRec  := {}
    aArea    := GetArea()
    aAreaSE2 := SE2->(GetArea())
    aAreaSE1 := SE1->(GetArea())    
    aAreaSFR := SFR->(GetArea())
    nX    := 1
    nStat := 0
    cAlsTmp := CriaTrab(, .F.)
    oTmp    := FWTemporaryTable():New(cAlsTmp)
    aTmpFld := {}
	if cTable == "SE2"
		cFrKey	:="SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA"
		cUNQKEY	:= "SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA"
		cFK7C	:="SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA"
		cDtBx	:= "SE2->E2_BAIXA"
        cFk := "FK2"
		cCarteira := "2"
		cPositive := 'P'
		cNegative := 'R'		
	ELSE
		cFrKey	:="SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO"
		cUNQKEY	:= "SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA"
		cFK7C	:="SE1->E1_FILIAL+'|'+SE1->E1_PREFIXO+'|'+SE1->E1_NUM+'|'+SE1->E1_PARCELA+'|'+SE1->E1_TIPO+'|'+SE1->E1_CLIENTE+'|'+SE1->E1_LOJA"
		cDtBx	:= "SE1->E1_BAIXA"		
        cFk := "FK1"
		cCarteira := "1"
		cPositive := 'R'
		cNegative := 'P'		
	EndIf
    AADD(aTmpFld, {"SEXKEY"   ,"C",GetSx3Cache("FR_CHAVOR", "X3_TAMANHO"),0})
    AADD(aTmpFld, {"SEXUNQKEY","C",Len(&(cUNQKEY)),0})
    AADD(aTmpFld, {"SEXBAIXA" ,"C",8,0})
    AADD(aTmpFld, {"SEXFK7C"  ,"C",Len(&(cFK7C)),0})
    oTmp:SetFields(aTmpFld)
    oTmp:Create()
    While nX <= Len(aSEXRecnos) .AND. nStat >= 0
        (cTable)->(DBGoTo(aSEXRecnos[nX]))
        AADD(aTmpRec, {aSEXRecnos[nX], &(cUNQKEY)})
        cQuery := " INSERT INTO "+ oTmp:GetRealName() + " "
        cQuery += " (SEXKEY,SEXUNQKEY,SEXBAIXA,SEXFK7C) VALUES (            "
        cQuery += "'"+&(cFrKey)+"', "
        cQuery += "'"+&(cUNQKEY)+"', "
        cQuery += "'"+DTOS(&(cDtBx)) + "', "
        cQuery += "'"+&(cFK7C)+"' "
        cQuery += ") "
        nStat  := TCSqlExec(cQuery)
        nX :=  nX + 1
    EndDo
    cQuery := " SELECT     TAB1.SFRRECNO    SFRRECNO,                                                   "
    cQuery += "            TAB1.FRDATADI    FRDATADI,                                                   "
    cQuery += "            TAB1.FRIDWTOFF   FRIDWTOFF,                                                  "
    cQuery += "            TAB1.FRCHAVOR    FRCHAVOR,                                                   "
    cQuery += "            TAB1.SEXUNQKEY   SEXUNQKEY,                                                  "
    cQuery += "            TAB1.SFRVLTOT    SFRVLTOT,                                                   "
    cQuery += "            TAB1.FKXVMTOT    FKXVMTOT,                                                   "
    cQuery += "            TAB1.FKXVRTOT    FKXVRTOT,                                                   "
    cQuery += "     CASE WHEN TAB1.FRDATADI > TAB1.SEXBAIXA                                             "
    cQuery += "          THEN 1                                                                         "
    cQuery += "          ELSE 2                                                                         "
    cQuery += "     END                     AFTE2BAIXA                                                  "
    cQuery += " FROM                                                                                    "
    cQuery += " (                                                                                       "
    cQuery += " SELECT                                                                                  "
    cQuery += " SFR.R_E_C_N_O_ SFRRECNO,                                                                "
    cQuery += " SFR.FR_DATADI  FRDATADI,                                                                "
    cQuery += " SFR.FR_IDWTOFF FRIDWTOFF,                                                               "
    cQuery += " SFR.FR_CHAVOR  FRCHAVOR,                                                                "
    cQuery += " TMP.SEXUNQKEY  SEXUNQKEY,                                                               "
    cQuery += " TMP.SEXBAIXA   SEXBAIXA,                                                                "
    cQuery += " VLR.SFRVALOR   SFRVLTOT,                                                                "
    cQuery += " COALESCE(TP2.FKXVLMOE2,0)  FKXVMTOT,                                                    "
    cQuery += " COALESCE(TP2.FKXVALOR,0)   FKXVRTOT                                                     "
    cQuery += " FROM  "+RetSqlName("SFR")+ " SFR                                                        "
    cQuery += " INNER JOIN "+oTmp:GetRealName()+ " TMP                                                  "
    cQuery += "    ON   SFR.FR_CHAVOR  = TMP.SEXKEY                                                     "
    cQuery += " INNER JOIN                                                                              "
    cQuery += "     ( SELECT                                                                            "
    cQuery += "              SUM(SFR.FR_VALOR) SFRVALOR,                                                "
    cQuery += "                  SFR.FR_CHAVOR SFRCHAVOR                                                "
    cQuery += "       FROM    "+RetSqlName("SFR")+ "  SFR                                               "
    cQuery += "       WHERE SFR.FR_FILIAL  = '" + xFilial("SFR")+"'                                     "
    cQuery += "         AND SFR.FR_TIPODI  = 'S'                                                        "
    cQuery += "         AND SFR.D_E_L_E_T_ = ' '                                                        "
    cQuery += "       GROUP BY SFR.FR_CHAVOR                                                            "
    cQuery += "     ) VLR                                                                               "
    cQuery += "    ON   SFR.FR_CHAVOR = VLR.SFRCHAVOR                                                   "
    cQuery += " LEFT JOIN                                                                               "
    cQuery += "     (                                                                                   "
    cQuery += "       SELECT                                                                            "
    cQuery += "              TP1.FK7IDDOC       FK7IDDOC,                                               "
    cQuery += "              MAX(TP1.FK7CHAVE)  FK7CHAVE,                                               "
    cQuery += "              SUM(TP1.FKXVLMOE2) FKXVLMOE2,                                              "
    cQuery += "              SUM(TP1.FKXVALOR)  FKXVALOR                                                "
    cQuery += "       FROM                                                                              "
    cQuery += "           ( SELECT                                                                      "
    cQuery += "                   FK7.FK7_IDDOC   FK7IDDOC,                                             "
    cQuery += "                   FK7.FK7_CHAVE   FK7CHAVE,                                             "
    cQuery += "                   CASE  WHEN "+cfk+"."+cfk+"_RECPAG = '"+cPositive+"' THEN              "
    cQuery += "                                   "+cfk+"."+cfk+"_VLMOE2                                "
    cQuery += "                         WHEN "+cfk+"."+cfk+"_RECPAG = '"+ cNegative +"' THEN            "
    cQuery += "                                   0 - "+cfk+"."+cfk+"_VLMOE2                            "
    cQuery += "                   END             FKXVLMOE2,                                            "
    cQuery += "                   CASE  WHEN "+cfk+"."+cfk+"_RECPAG = '"+cPositive+"' THEN              "
    cQuery += "                                   "+cfk+"."+cfk+"_VALOR                                 "
    cQuery += "                         WHEN "+cfk+"."+cfk+"_RECPAG = '"+ cNegative +"' THEN            "
    cQuery += "                                   0 - "+cfk+"_VALOR                                     "
    cQuery += "                   END             FKXVALOR                                              "
    cQuery += "             FROM   "+RetSqlName("FK7")    + " FK7                                       "
    cQuery += "             INNER JOIN "+RetSqlName(cfk)+ " "+cfk+"                                     "
    cQuery += "                ON "+cfk+"."+cfk+"_FILIAL = '" + xFilial(cfk) + "'                       "
    cQuery += "               AND "+cfk+".D_E_L_E_T_ = ' '                                              "
    cQuery += "               AND "+cfk+"."+cfk+"_IDDOC = FK7.FK7_IDDOC                                 "
    cQuery += "             WHERE FK7.FK7_FILIAL = '" + xFilial("FK7") + "'                             "
    cQuery += "               AND FK7.FK7_ALIAS  = '"+cTable+"'                                         "
    cQuery += "               AND FK7.D_E_L_E_T_ = ' '                                                  "
    cQuery += "           ) TP1                                                                         "
    cQuery += "       GROUP BY TP1.FK7IDDOC                                                             "
    cQuery += "     ) TP2                                                                               "
    cQuery += "    ON TP2.FK7CHAVE = TMP.SEXFK7C                                                        "
    cQuery += " WHERE   SFR.FR_FILIAL  = '"+xFilial("SFR")     +"'                                      "
    cQuery += "   AND   SFR.FR_CARTEI  = '"+ cCarteira+"'                                               "
    cQuery += "   AND   SFR.FR_DATADI <= '"+DTOS(dOperDate)    +"'                                      "
    cQuery += "   AND   SFR.FR_TIPODI  = 'S'                                                            "
    cQuery += "   AND   SFR.FR_RBDBAL  = '1'                                                            "
    cQuery += "   AND   SFR.D_E_L_E_T_ = ' '                                                            "
    cQuery += " ) TAB1                                                                                  "
    cQuery += " ORDER BY SEXUNQKEY ASC, FRCHAVOR ASC, AFTE2BAIXA ASC, FRDATADI ASC                      "
    If nStat >= 0
        cQuery := ChangeQuery(cQuery)
        cAlias := MPSysOpenQuery(cQuery)
        TCSetField(cAlias,"SFRVLTOT","N",GetSx3Cache("FR_VALOR","X3_TAMANHO"),  GetSx3Cache("FR_VALOR","X3_DECIMAL")  )
        TCSetField(cAlias,"FKXVMTOT","N",GetSx3Cache(cfk+"_VLMOE2","X3_TAMANHO"),GetSx3Cache(cfk+"_VLMOE2","X3_DECIMAL"))
        TCSetField(cAlias,"FKXVRTOT","N",GetSx3Cache(cfk+"_VALOR","X3_TAMANHO") ,GetSx3Cache(cfk+"_VALOR","X3_DECIMAL") )
        DBSelectArea(cAlias)
        DBGoTop()
        nX := 0
        nY := 0
        cKey := ""
        While !Eof()
            If !(cKey == (cAlias)->SEXUNQKEY)
                nPos := ASCAN(aTmpRec, {|x| x[2] == (cAlias)->SEXUNQKEY})
                AADD(aList,{aTmpRec[nPos][1],(cAlias)->SFRVLTOT,(cAlias)->FKXVMTOT,(cAlias)->FKXVRTOT,{}})
                nX   := nX + 1
                nY   := 0
                cKey := (cAlias)->SEXUNQKEY
            EndIf
            AADD(aList[nX][5],{})
            nY  := nY + 1
            AADD(aList[nX][5][nY],(cAlias)->SFRRECNO      )
            AADD(aList[nX][5][nY],(cAlias)->FRDATADI      )
            AADD(aList[nX][5][nY],(cAlias)->FRIDWTOFF     )
            AADD(aList[nX][5][nY],(cAlias)->FRCHAVOR      )
            AADD(aList[nX][5][nY],(cAlias)->AFTE2BAIXA    )
            DBSkip()
        EndDo
        (cAlias)->(DBCloseArea())
    EndIf
    (cAlsTmp)->(DBCloseArea())
    oTmp:Delete()
    RestArea(aAreaSFR)
    RestArea(aAreaSE2)
    RestArea(aAreaSE1)    
    RestArea(aArea)
Return aList
/*/{Protheus.doc} RU06XFUN90_RetaBaixas
@type           
@description    
                We sort items by special rules. For details look at specification.
@param          Array        aRebldList  // multidimensional array prepared by RU06XFUN89_GetRebuildList
                Date         dOperDate   // date of operation
                Character    cTable     // SE1 OR SE2                   
@return         Array        aBaixas     // specially prepared array which will be used for changing
                                         // aCorrecoes in fina084.prx
                                         // {{SE2recno, 
                                         //  {Exchange rate diff,Balance,TaxRate,TaxRateOri,SFRrecno,'3',FR_IDWTOFF}}
                                         //  ...
                                         //  }
                                         // in case we have no rights for locking SFR record or
                                         // FR_RBDBAL is not equal to "1" will be returned {-1}
@author         astepanov
@since          01 June 2021
@specification  FI-AP-15-11
@project        MA3 - Russia
/*/
Function RU06XFUN90_RetaBaixas(aRebldList, dOperDate,cTable)
    Local aBaixas     As Array
    Local aArea       As Array
    Local aAreaSE2    As Array
    Local aAreaSE1    As Array    
    Local aAreaFK2    As Array
    Local aAreaSE5    As Array
    Local aAreaSFR    As Array
    Local aValues     As Array
    Local aList       As Array
    Local aTmp        As Array
    Local aSFRLckd    As Array
    Local nX          As Numeric
    Local nY          As Numeric
    Local nPos        As Numeric
    Local nRecSFR     As Numeric
    Local nRnd        As Numeric
    Local nTotERCorr  As Numeric
    Local nTotWrOff   As Numeric
    Local nTotReval   As Numeric
    Local lOk         As Logical
    Local lLast       As Logical

    DEFAULT cTable:="SE2"
    aBaixas  := {}
    lOk      := .T.
    aArea    := GetArea()
    aAreaSE2 := SE2->(GetArea())
    aAreaSE1 := SE1->(GetArea())    
    aAreaFK2 := FK2->(GetArea())
    aAreaSE5 := SE5->(GetArea())
    aAreaSFR := SFR->(GetArea())
    nRnd     := GetSX3Cache("FR_VALOR" ,"X3_DECIMAL")
    aSFRLckd := SFR->(DBRLockList())
    For nX := 1 To Len(aRebldList)
        aList := ACLONE(aRebldList[nX][5])
        (cTable)->(DBGoto(aRebldList[nX][1]))
        nTotReval  := aRebldList[nX][2]
        nTotWrOff  := IIF(&(cTable+"->"+REPLACE(cTable,"S","")+"_CONUNI")=="1",aRebldList[nX][4],aRebldList[nX][3]) // SE2->E2_CONUNI or SE1->E1_CONUNI =="1"
        nTotERCorr := 0
        lLast      := .F.
        AADD(aBaixas,{aRebldList[nX][1],{}})
        If &(cTable+"->"+REPLACE(cTable,"S","")+"_SALDO") == 0 // SE2->E2_SALDO or SE1->E1_SALDO == 0 
            //no need in additional sorting, already sorted by query
            For nY := 1 To Len(aList)
                nRecSFR := aList[nY][1]
                If nY == Len(aList)
                    lLast := .T.
                EndIf
                aValues := RU06XFUN91_GetValuesForRebuild((cTable)->(Recno()), nRecSFR, nRnd, nTotERCorr, lLast, nTotWrOff, nTotReval, @aSFRLckd,cTable)
                If Empty(aValues) //SFR record was not locked or was changed
                    lOk := .F.
                    Exit
                EndIf
                nTotERCorr += aValues[1]
                AADD(aBaixas[Len(aBaixas)][2],ACLONE(aValues))
            Next nY
        Else
            // sort by date only
            aTmp  := {}
            For nY := 1 To Len(aList)
                AADD(aTmp,aList[nY][2]+cValToChar(nY))
            Next nY
            ASORT(aTmp,,,{|x,y| SubStr(x,1,8) < SubStr(y,1,8)})
            For nY := 1 To Len(aTmp)
                nPos := Val(SubStr(aTmp[nY],9))
                nRecSFR := aList[nPos][1]
                aValues := RU06XFUN91_GetValuesForRebuild((cTable)->(Recno()), nRecSFR, nRnd, nTotERCorr, lLast, nTotWrOff, nTotReval, @aSFRLckd,cTable)
                If Empty(aValues) //SFR record was not locked or was changed
                    lOk := .F.
                    Exit
                EndIf
                nTotERCorr += aValues[1]
                AADD(aBaixas[Len(aBaixas)][2],ACLONE(aValues))
            Next nY
        EndIf
        aList := Nil
        If !lOk
            Exit
        EndIf
    Next nX
    If !lOk
        aBaixas := {-1}
    EndIf
    RestArea(aAreaSFR)
    RestArea(aAreaSE5)
    RestArea(aAreaFK2)
    RestArea(aAreaSE2)
    RestArea(aAreaSE1)    
    RestArea(aArea)
Return aBaixas

/*/{Protheus.doc} RU06XFUN91_GetValuesForRebuild
@type           
@description    
                This function used by RU06XFUN90_RetaBaixas for values calculations.
                For details look at specification.
@param          Numeric      nRecSEX     // SE2/SE1 recno
                Numeric      nRecSFR     // SFR recno
                Numeric      nRnd        // decimal rounding for exchange rate difference
                Numeric      nTotERCorr  // Accumulated excahnge rate corrections for same AP
                Logical      lLast       // flag of last item in rebuild list
                Numeric      nTotWrOff   // Total write offs for AP from FK2 table
                Numeric      nTotReval   // Total revaluations for AP from SFR table
                Array        aSFRLckd    // list of SFR locked records. can be Nil
                Character    cTable     // SE1 OR SE2                   
@return         Array        aValues     // specially prepared array which will be used for changing
                                         // aCorrecoes in fina084.prx 
                                         // {Exchange rate diff,Balance,TaxRate,TaxRateOri,SFRrecno,'3',FR_IDWTOFF}
                                         // in case we have no rights for locking SFR record or
                                         // FR_RBDBAL is not equal to "1" will be returned empty array {}
@author         astepanov
@since          01 June 2021
@specification  FI-AP-15-11
@project        MA3 - Russia
/*/
Function RU06XFUN91_GetValuesForRebuild(nRecSEX, nRecSFR, nRnd, nTotERCorr, lLast, nTotWrOff, nTotReval, aSFRLckd,cTable)
    Local aValues     As Array
    Local nBalance    As Numeric
    Local nFKXValue   As Numeric
    Local nPrevTax    As Numeric
    Local nCurrTax    As Numeric
    Local nNewExRtVl  As Numeric
    Local nSFRVALOR   As Numeric
    Local nSFRTXORI   As Numeric
    Local nSFRSKLen   As Numeric
    Local dCurrDate   As Date
    Local dPrevDate   As Date
    Local cSFRSubKey  As Character
    Local cFRIDWTOFF  As Character
    Local cFKXValFld  As Character
    Local cFk         as Character  
    LOCAL cPositive   as Character
    Local aArea       As Array
    Local aAreaSE2    As Array
    Local aAreaSE1    As Array    
    Local aAreaSFR    As Array
    Local aAreaFK2    As Array
    Local aAreaFK1    As Array    
    Local lLockedSFR  As Logical
    Local cCarteira   As Character  

    DEFAULT cTable:="SE2"

    aArea := GetArea()
    aAreaSE2 := SE2->(GetArea())
    aAreaSE1 := SE1->(GetArea())    
    aAreaSFR := SFR->(GetArea())
    aAreaFK2 := FK2->(GetArea())
    aAreaFK1 := FK1->(GetArea())    
    (cTable)->(DBGoto(nRecSEX))
    SFR->(DBGoto(nRecSFR))
    aValues := {}
    lLockedSFR := .F.
    If Reclock("SFR", .F.)
        lLockedSFR := .T.
    Else
        Help("",1,STR0071,,STR0094,1,0) //Information -Impossible to lock record
    EndIf
    If lLockedSFR .AND. SFR->FR_RBDBAL == "1" // empty aValues will be returned if RBDBAL was changed
        cFRIDWTOFF := SFR->FR_IDWTOFF
        cSFRSubKey := SFR->FR_FILIAL+SFR->FR_CARTEI+SFR->FR_CHAVOR
        nSFRSKLen  := Len(cSFRSubKey)
        nCurrTax   := SFR->FR_TXATU
        dCurrDate  := SFR->FR_DATADI
        nSFRTXORI  := SFR->FR_TXORI
        nSFRVALOR  := SFR->FR_VALOR
        dPrevDate  := SFR->FR_DATADI
        If cTable == "SE2"
            cFk         :="FK2"
            cPositive   :="P"
            nBalance    := SaldoTit( SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_NATUREZ, "P", SE2->E2_FORNECE, SE2->E2_MOEDA, dCurrDate-1, dCurrDate-1, SE2->E2_LOJA )
            cFKXValFld  := IIF(SE2->E2_CONUNI == "1", "FK2_VLMOE2", "FK2_VALOR")
            cCarteira   :="2"
            nPrevTax   := SE2->E2_TXMOEDA
        Else
            cFk         :="FK1"
            cPositive   :="R"
            nBalance    := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, SE1->E1_MOEDA, dCurrDate-1, dCurrDate-1, SE1->E1_LOJA )
            cFKXValFld  := IIF(SE1->E1_CONUNI == "1", "FK1_VLMOE2", "FK1_VALOR")
            cCarteira   :="1"
            nPrevTax   := SE1->E1_TXMOEDA
        EndIf
        If lLast
            nNewExRtVl := (nTotWrOff-(nTotReval+nTotERCorr)) - &(cTable+"->"+REPLACE(cTable,"S","")+"_VLCRUZ") 
        Else
            SFR->(DBSetOrder(1))
            If SFR->(DBSeek(cSFRSubKey))
                While dCurrDate > SFR->FR_DATADI
                    nPrevTax  := SFR->FR_TXATU
                    dPrevDate := SFR->FR_DATADI
                    SFR->(DBSkip())
                EndDo
            EndIf
            If !Empty(cFRIDWTOFF)
                SFR->(DBSetOrder(1))
                If SFR->(DBSeek(cSFRSubKey))
                    While SFR->FR_FILIAL+cCarteira+SFR->FR_CHAVOR == cSFRSubKey
                        If SFR->FR_TIPODI == "S" .AND. SFR->FR_IDWTOFF == cFRIDWTOFF .AND. SFR->(RECNO()) != nRecSFR
                            nSFRVALOR := nSFRVALOR + SFR->FR_VALOR
                        EndIf
                        SFR->(DBSkip())
                    EndDo
                EndIf
            EndIf
            nNewExRtVl := ROUND(((nBalance*nCurrTax)) - ((nBalance*nPrevTax)) - nSFRVALOR,2)
        EndIf
        aValues    := {nNewExRtVl,nBalance,nCurrTax,nSFRTXORI,nRecSFR,'3',cFRIDWTOFF}
    EndIf
    If lLockedSFR //Try to unlock SFR, except SFR record which were locked by calling routines
        If ASCAN(aSFRLckd, {|x| x == nRecSFR}) == 0
            SFR->(DBGoTo(nRecSFR))
            SFR->(MSUnlock())
        EndIf
    EndIf
    RestArea(aAreaFK1)
    RestArea(aAreaFK2)   
    RestArea(aAreaSFR)
    RestArea(aAreaSE2)
    RestArea(aAreaSE1)    
    RestArea(aArea)
Return aValues

/*/{Protheus.doc} RU06XFUN92_ChangeCorrecoes        
This function used by fina084.prw for changing aCorrecoes by corrections
calculated according to russian accounting standards.
For details look at specification.
@type  Function 
@author         astepanov
@since          01/06/2021
@version version
@param  aRusCorrec, Array,  array with russian corrections
@param  aCorrecoes, Array,  array with standard fina084 corrections
@param  aRecSE2, Array,     array with SE2 recnos
@return lRet, Logical,      .T.
@see  FI-AP-15-11
/*/
Function RU06XFUN92_ChangeCorrecoes(aRusCorrec,aCorrecoes,aRecSE2)
    Local lRet       As Logical
    Local nX         As Numeric
    Local nPos       As Numeric
    Local nPos2      As Numeric
    Local aSald      As Array
    lRet := .T.
    For nX := 1 To Len(aRusCorrec)
        nPos  := nX
        nPos2 := ASCAN(aCorrecoes, {|x| x[1] == aRusCorrec[nPos][1]})
        If nPos2 > 0
            aSald  := ACLONE(aCorrecoes[nPos2][3][1])
            aCorrecoes[nPos2][3] := Nil
            aCorrecoes[nPos2][3] := ACLONE(aRusCorrec[nPos][2])
            AADD(aCorrecoes[nPos2][3],ACLONE(aSald))
            aSald := Nil 
        EndIf
    Next nX
Return lRet
/*/{Protheus.doc} RU06XFUN93_LockSEXRec
@type           
@description    
                We lock SE2/SE1 recnos because need correct E2_SALDO/E1_SALDO for calculating
                exchange rate revealuations. During long process E2_SALDO/E1_SALDO can be
                changed by other users, so it is prohibited.
                For details look at specification.
@param          Array        aRec     // list of SE2/SE1 recnos for locking
                Chacacter    cAlias   // Alias of the operation SE1 or SE2
@return         Logical      lRet        // .T. if locked, .F. if not.
@author         astepanov
@since          01 June 2021
@specification  FI-AP-15-11
@project        MA3 - Russia
/*/
Function RU06XFUN93_LockSEXRec(aRec,cAlias)
    Local lRet       	As Logical
    Local nX         	As Numeric
    Local nPos       	As Numeric
    Local aArea      	As Array
    Local aAreaAlias   	As Array
	
	Default cAlias := "SE2" 
    aArea    := GetArea()
    aAreaAlias := (cAlias)->(GetArea())
    lRet := .T.
    nX := 1
    While lRet .AND. nX <= Len(aRec)
        (cAlias)->(DBGoto(aRec[nX]))
        If !RecLock(cAlias,.F.)
            lRet := .F.
        EndIf
        nX := nX + 1
    EndDo
    nPos := nX - 1
    If !lRet
        Help("",1,STR0071,,STR0094,1,0) //Information -Impossible to lock record
        For nX := 1 To nPos
            (cAlias)->(DBGoto(aRec[nX]))
            (cAlias)->(MSUnlock())    
        Next nX
    EndIf
    RestArea(aAreaAlias)
    RestArea(aArea)
Return lRet

/*/{Protheus.doc} RU06XFUN94_UnLockSE2Rec
@type           
@description    
                Here we unlock list of SE2 records, we exclude from unlocking
                items which included in aSE2NotUnl
@param          Array        aRecSE2     // list of SE2 recnos for unlocking
                Chacacter    cAlias   // Alias of the operation SE1 or SE2
                Array        aSE2NotUnl  // item list for excluding from unlocking
@return         Logical      lRet        // .T.
@author         astepanov
@since          01 June 2021
@specification  FI-AP-15-11
@project        MA3 - Russia
/*/
Function RU06XFUN94_UnLockSEXRec(aRecSEX, aSEXNotUnl,cAlias)
    Local lRet     As Logical
    Local nX       As Numeric
    Local aAreaSEX As Array
    Local aArea    As Array

	Default cAlias := "SE2" 

    aArea    := GetArea()
    aAreaSEX := (cAlias)->(GetArea())
    lRet := .T.
    For nX := 1 To Len(aRecSEX)
        If ASCAN(aSEXNotUnl,aRecSEX[nX]) == 0
            (cAlias)->(DBGoTo(aRecSEX[nX]))
            (cAlias)->(MSUnlock())
        EndIf
    Next nX
    RestArea(aAreaSEX)
    RestArea(aArea)
Return lRet

/*/{Protheus.doc} RU06XFUN95_WriteIDFK2toIDWTOFF
When we create exchange rate difference we should write to SFR record
write-off identificator. So we write to FR_IDWTOFF content of FK2_IDFK2.
SFR recnos saved in private array aFRIDWTOFF because at first we create exchange rate
difference, at second we write AP write-off.
This function called from fA080Grv and you should be in transaction mode.
@type function
@version  
@author astepanov
@since 7/2/2021
@param cIdFK, character, id of the write-off
@param aBStExpPrm , array, Array with values filled in Bank statement process
@return lRet, .T., .F. if SFR record was not locked
/*/
Function RU06XFUN95_WriteIDFK2toIDWTOFF(cIdFK,aBStExpPrm,aRecWri)
    Local lRet       As Logical
    Local nX         As Numeric
    Local nSFRRecno  As Numeric
    Local aSFRLocked As Array
    Local aArea      As Array
    Local aAreaSFR   As Array
    Local aRecSfr     As Array
    Default aBStExpPrm := {}
    Default aRecWri := {}
    lRet  :=  .T.
    aRecSfr := {}
    aArea := GetArea()
    aAreaSFR := SFR->(GetArea())
    aSFRLocked := SFR->(DBRLockList())
    If !Empty(aBStExpPrm) .AND. aBStExpPrm[4][2] == .T.
        aRecSfr :=aBstExpPrm[3][2]
    ElseIf !Empty(aRecWri)
        aRecSfr :=aRecWri
    EndIf
    If !Empty(aRecSfr)
        For nX := 1 To Len(aRecSfr)
            SFR->(DBGoto(aRecSfr[nX]))
            nSFRRecno := SFR->(Recno())
            If RecLock("SFR", .F.)
                SFR->FR_IDWTOFF := cIdFK
                If ASCAN(aSFRLocked, nSFRRecno) == 0 // we didn't find this record in previously locked SFR records, so we unlock it
                    SFR->(MSUnlock())
                EndIf
            Else
                lRet := .F.
                Exit
            EndIf
		Next nX
    EndIf
    RestArea(aAreaSFR)
    RestArea(aArea)
Return lRet
/*/{Protheus.doc} RU06XFUN96_CheckWriteOffsOnSameDate
In case we have two or more postings in foreign currency, we have only one 
exchange rate revaluation, so we should delete this revaluation string when:
we have only one posting on dDate (we exclude deleted an cancelled postings)
for this cases we calculate total values by FK2_VALOR and FK2_VLMOE2 and
compare it with F5M_VALPAY.
Look at https://jiraproducao.totvs.com.br/browse/RULOC-1955
@type function
@version  
@author astepanov
@since 7/23/2021
@param cTab, character, "SE2"
@param cFK7Chave, character, string for selecting by FK7_CHAVE
@param dDate, date, for filter by FK2_DATA
@return array, {FK2_VALOR Total, FK2_VLMOE2 Total}
/*/
Function RU06XFUN96_CheckWriteOffsOnSameDate(cTab,cFK7Chave, dDate)
    Local cQuery     As Character
    Local cAlias     As Character
    Local aArea      As Array
    Local aRet       As Array
    aArea  := GetArea()
    aRet   := {0,0}
    cQuery := " SELECT                                              "
    cQuery += " SUM(TOT.FK2_VLMOE2) FK2VMTOT,                       "
    cQuery += " SUM(TOT.FK2_VALOR)  FK2VRTOT                        "
    cQuery += " FROM (                                              "
    cQuery += " SELECT                                              "
    cQuery += "    CASE  WHEN FK2.FK2_RECPAG = 'P' THEN             "
    cQuery += "                    FK2.FK2_VLMOE2                   "
    cQuery += "          WHEN FK2.FK2_RECPAG = 'R' THEN             "
    cQuery += "                    0 - FK2.FK2_VLMOE2               "
    cQuery += "    END             FK2_VLMOE2,                      "
    cQuery += "    CASE  WHEN FK2.FK2_RECPAG = 'P' THEN             "
    cQuery += "                    FK2.FK2_VALOR                    "
    cQuery += "          WHEN FK2.FK2_RECPAG = 'R' THEN             "
    cQuery += "                    0 - FK2_VALOR                    "
    cQuery += "    END             FK2_VALOR                        "
    cQuery += " FROM                                                "
    cQuery += "(                                                    "
    cQuery += " SELECT FK7.FK7_IDDOC FK7_IDDOC                      "
    cQuery += " FROM "+RetSqlName("FK7")+" FK7                      "
    cQuery += " WHERE FK7.FK7_FILIAL = '"+xFilial("FK7")+"'         "
    cQuery += "   AND FK7.FK7_ALIAS  = '" +      cTab      + "'     "
    cQuery += "   AND FK7.FK7_CHAVE  = '" +    cFK7Chave   + "'     " 
    cQuery += "   AND FK7.D_E_L_E_T_ = ' '                          "
    cQuery += ") FK7                                                "
    cQuery += " INNER JOIN "+RetSqlName("FK2") + " FK2              "
    cQuery += "    ON   FK2.FK2_FILIAL = '"+xFilial("FK2")+"'       "
    cQuery += "    AND  FK2.FK2_IDDOC  =  FK7.FK7_IDDOC             "
    cQuery += "    AND  FK2.FK2_DATA   = '"+DTOS(dDate)+"'          "
    cQuery += "    AND  FK2.D_E_L_E_T_ = ' '                        "
    cQuery += ") TOT                                                "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    TCSetField(cAlias,"FK2VMTOT","N",GetSx3Cache("FK2_VLMOE2","X3_TAMANHO"),GetSx3Cache("FK2_VLMOE2","X3_DECIMAL"))
    TCSetField(cAlias,"FK2VRTOT","N",GetSx3Cache("FK2_VALOR","X3_TAMANHO") ,GetSx3Cache("FK2_VALOR","X3_DECIMAL") )
    DBSelectArea(cAlias)
    DBGoTop()
    If !Eof()
        aRet[1] := (cAlias)->FK2VRTOT
        aRet[2] := (cAlias)->FK2VMTOT 
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
Return aRet

/*/{Protheus.doc} RU06XFUN97_NumeratorForTypeDocPA
@type           Function
@description    A custom numbering tool that works with the SX5 is "Tabela 01". 
                Designed for routines that deal with bank transactions. 
                Posting transactions are recorded in addition to the main table, also in table SE5.
@author         Nikita.Lysenko
@since          03/09/2021
@version        
@project        MA3 - Russia
@param          cTipo - character, document type
@return         cNum - character, numbered number
/*/
Function RU06XFUN97_NumeratorForTypeDocPA(cTipo)
    Local nRecSX5	As Numeric
    Local nTimes    As Numeric
    Local aArea     As Array
    Local aSX5Area  As Array
    Local cNum      :=  ""

    Default cTipo   :=  ""

    aArea  := GetArea()
    aSX5Area   := SX5->(GetArea())
    DbSelectArea('SX5')
	DbSetOrder(1)

    If cTipo == ""
        cNum := "" // If the document type was not passed to the function parameter.
    Else
        If SX5->(DbSeek(xFilial()+'01'+cTipo))
            nTimes := 0
            While !MsRLock() .and. nTimes < 10
                nTimes++
                Inkey(.1)
                DbSeek( xFilial("SX5")+"01"+cTipo,.F. )
            EndDo
            If MsRLock()
                    cNum	:=	Right(alltrim(SX5->X5_DESCENG),TamSX3('E2_NUM')[1])
                    nRecSX5	:=	Recno()
                    IF RecLock("SX5",.F.)
                        Replace X5_DESCRI  With Soma1(cNum)
                        Replace X5_DESCENG With Soma1(cNum)
                        Replace X5_DESCSPA With Soma1(cNum)
                        MsUnlock()
                    Endif

                    If nRecSX5 > 0
                        SX5->(MsGoTo(nRecSX5))
                        MsUnLock()
                    EndIf
            Else
                HELP('',1,'FA084004')
            Endif	
        Else
            HELP('',1,'FA084003')
        Endif
    Endif
    
    SX5->(RestArea(aSX5Area))
    RestArea(aArea)
Return cNum


/*/{Protheus.doc} FA330Unch
@type           Function
@description    Used at FINA330 to unCheck all lines at screen
                similar to function F330Button(lPccBxCr,oTitulo,oGet01,lMarkAll)
@author         Rafael.Goncalves
@since          25/11/2021
@version        
@project        MA3 - Russia
@param          oTitulo - object l
@return         nothing
/*/
Function FA330Unch(oTitulo,aTitulos,oGet01,oOk,oNo)
Local _ni := 0 
nValTot := 0

For _ni:=1 to len(aTitulos)
    //If selected, change to false ans restore value
    If aTitulos[_ni][8]
        aTitulos := FA330Troca( _ni , aTitulos , oGet01 ,.F.,,.F.)
    EndIf
Next

FA330RF(@oTitulo,aTitulos,oOk,oNo)
oGet01:Refresh()

Return


/*/{Protheus.doc} FA330RF
@type           Function
@description    Used to refresh grid component aat FINA330
@author         Rafael.Goncalves
@since          28/11/2021
@version        
@project        MA3 - Russia
@param          oTitulo - object
                aTitulos - array with data
@return         nothing
/*/
Static Function FA330RF(oTitulo,aTitulos,oOk,oNo)
oTitulo:SetArray(aTitulos)
If MV_PAR02 == 2
    oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
            aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,1],;
            aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
            aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
            aTitulos[oTitulo:nAt,23],aTitulos[oTitulo:nAt,6],;
            If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,18],;
            aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,11],;
            aTitulos[oTitulo:nAt,15],aTitulos[oTitulo:nAt,19],;
            aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,20],;
            aTitulos[oTitulo:nAt,21],aTitulos[oTitulo:nAt,22]}}
Else
    oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
            aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
            aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
            aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
            aTitulos[oTitulo:nAt,20],aTitulos[oTitulo:nAt,6],;
            If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,15],;
            aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,16],;
            aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,17],;
            aTitulos[oTitulo:nAt,18],aTitulos[oTitulo:nAt,19]}}
EndIf
oTitulo:Refresh()
Return


/*/{Protheus.doc} RU06XFUN11_GenerateExchangeRateDifferenceFA084
We use this function for calculating or generating exchange rate difference for AP, when we write-off it.
We call it from FINA080 or RU06D07. Specification is FI-AP-15-16 Write-off of AP in foreign currency. We should be positioned in correct SE2 line.
SE2 record should be locked for changes. Also if we generate exchange rate difference we should be in transaction mode.
@type function
@version 1.0
@author astepanov
@since March/31/2022
@param aBStExpPrm, array, array generated by RU06D07048_Init_aBStExpPrm function, it can be as empty array {}. If it is empty we fill it inside this function.
@param dPostDate, date, date for generating exchange rate difference
@param nTxMoeda, numeric, Exchange rate value
@param nValInCntCr, numeric, Value in currency of AP
@param nValInLocCr, numeric, Value in local currency, if we pass it by link we can change it.
@param lOnlyCalc, logical, Only calculate exchange rate difference. Don't generate lines in SFR table
@param lChkCllStk, logical, Check bank statement functions in callstack. Default is .T.
@return array, {success or not logical value,calculated exchange rate difference,calculated value in local currency}
/*/
Function RU06XFUN11_GenerateExchangeRateDifferenceFA084(aBStExpPrm,dPostDate,nTxMoeda,nValInCntCr,nValInLocCr,lOnlyCalc,lChkCllStk)
    Local lRet       As Logical
    Local lRvlListFl As Logical
    Local lCallStack As Logical
    Local aRet       As Array
    Local aArea      As Array
    Local aAreaSE2   As Array
    Local aPergParam As Array
    Local aTmp       As Array
    Local aRevalList As Array
    Local aTxMoedasB As Array
    Local aDifExRat  As Array
    Local dBkpDtBase As Date
    Local cSE2Key    As Character
    Local cFK7Chave  As Character
    Local cWorkTab   As Character
    Local cAdvanceTp As Character
    Local nX         As Numeric
    Local nFK5VLMOE2 As Numeric
    Local nMoedaTitB As Numeric
    Local nExRtDifVl As Numeric
    Local nSign      As Numeric

    Default lOnlyCalc   := .F.
    Default lChkCllStk  := .T.

    lRet       := .T.
    nExRtDifVl := 0
    aArea      := GetArea()
    cWorkTab   := "SE2"
    cAdvanceTp := IIf(cWorkTab == "SE2",MVPAGANT,"")
    lRvlListFl := .F.
    nFK5VLMOE2 := Iif(SE2->E2_CONUNI == "1",nValInCntCr,nValInLocCr)
    lCallStack := .F.
    If lChkCllStk
        lCallStack := FWIsInCallStack("RU06D07023_OutflowFinPost") .OR. FWIsInCallStack("RU06D0736_FI080CancelWrite")
    EndIf 
    If SE2->E2_MOEDA > 1 .AND. !lCallStack
        If Type("nCM") == "N" .AND. !lOnlyCalc// We set private nCM to 0, because for storing exchange rate difference we will use Fa084Gdif function
            nCM := 0
        EndIf
        aPergParam := {}
        For nX := 1 To 60
            Aadd(aPergParam, &("MV_PAR" + StrZero(nX, 2)))
        Next nX
        Pergunte("FIN84A",.F.)
        &("MV_PAR01") := 0
        &("MV_PAR07") := 1
        &("MV_PAR08") := 0
        &("MV_PAR11") := 1
        aAreaSE2   := SE2->(GetArea())
        If Type("nMoedaTit") == "N"
            nMoedaTitB := nMoedaTit
            nMoedaTit  := 1
        Else
            nMoedaTit  := 1
            nMoedaTitB := nMoedaTit
        EndIf
        If !(Type("aTxMoedas") == "A")
            Private aTxMoedas := {} 
        EndIf
        aTxMoedasB := ACLONE(aTxMoedas)
        aTxMoedas := RU06D0742_CurrenciesArray(dPostDate)
        aTxMoedas[SE2->E2_MOEDA][2] := nTxMoeda
        dBkpDtBase := dDataBase
        dDataBase  := dPostDate
        If Empty(aBStExpPrm)
            aBStExpPrm := RU06D07048_Init_aBStExpPrm(PADR("FINA080",TamSX3("F4C_CUUID")[1]," "),nValInCntCr,nValInLocCr)
        EndIf
        If SE2->E2_CONUNI == "1" .AND. !lOnlyCalc // Conventional Units. Check if we create writeofs with different exchange rates on same date
            lRet := lRet .AND. RU06D07738_CheckExchangeRateCalculationForSameDate(cWorkTab,nTxMoeda)
        EndIf
        cSE2Key    := SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA
        cFK7Chave  := PADR(cSE2Key, GetSX3Cache("FK7_CHAVE","X3_TAMANHO"), " ")
        //change FR_RBDBAL for writeoffs when lOnlyCalc is .F.
        aTmp := RU06XFUN88_GetRevaluationList(STRTRAN(SUBSTR(cFK7Chave,Len(xFilial("SE2"))+1), "|", ""),dPostDate,"2",lOnlyCalc)
        aRevalList := aTmp[1]
        lRet       := aTmp[2]
        lRvlListFl := IIF(!Empty(aRevalList), .T., .F.)
        aBStExpPrm[5][2] := lRvlListFl
        // for advance AP Exchange rate difference should be always be equal to 0
        //prevent 2 different writeoffs with the same bill separated between them and with the same transaction date
        If lRet .AND. !(SE2->E2_TIPO $ cAdvanceTp) .AND. !Fa084TemDC(cWorkTab,@aBStExpPrm)
            If lRet .AND. !lOnlyCalc
                lRet := Fa084GDif(.F./*lMutiplo*/,/*aCorrecoes*/,/*lMarcados*/,.T./*lExterno*/,/*nMoedaCor*/,/*nTxaAtual*/,/*nMoedaTit*/,@aBStExpPrm)
            EndIf
            If lRet .AND. lOnlyCalc
                aDifExRat  := Fa084CDif(aTxMoedas[SE2->E2_MOEDA][2],.T.,@aBStExpPrm)
                nExRtDifVl := aDifExRat[3][1][1]
            EndIf
            //so when we'll create FK2 record for write-off, we change
            //FR_IDWTOFF to IDFK2 for SFR recno's stored in aBStExpPrm[3][2]
            //we set array element LWRITFRRUS to .T.
            aBStExpPrm[4][2] := .T.
        EndIf
        If lRvlListFl //unlock SFR records
            For nX := 1 To Len(aRevalList)
                SFR->(DBGoto(aRevalList[nX]))
                SFR->(MSUnlock())
            Next nX
        EndIf
        aTmp       := Nil 
        dDataBase  := dBkpDtBase
        For nX := 1 To Len(aPergParam)
            &("MV_PAR" + StrZero(nX, 2)) := aPergParam[nX]
        Next nX
        aTxMoedas  := ACLONE(aTxMoedasB)
        nMoedaTit  := nMoedaTitB
        RestArea(aAreaSE2)
        If lRet
            nSign := IIF(SE2->E2_TIPO $ cAdvanceTp,-1,+1)
            If SE2->E2_CONUNI == "2" //Non Conventional units
                If SE2->E2_SALDO == nValInCntCr .AND. !lRvlListFl
                    aTmp := RU06XFUN86_GetLastInstallmentValue(cFK7Chave,cWorkTab)
                    nFK5VLMOE2 := SE2->E2_VLCRUZ - (aTmp[1] - aTmp[2])*nSign + IIF(lOnlyCalc,nExRtDifVl,0)
                    If nFK5VLMOE2 != ROUND(nValInLocCr,GetSX3Cache("FK5_VLMOE2","X3_DECIMAL"))
                        // we need theese code becase when we calculate exchange rate difference
                        // we store rounding mistakes is SFR and FK2 and SE5, we should exclude this
                        // mistake when post last installment
                        nValInLocCr := nFK5VLMOE2 // we change nValPgTo in FINA080 if it passed by link
                    EndIf
                Else
                    nFK5VLMOE2 := ROUND(nValInLocCr,GetSX3Cache("FK5_VLMOE2","X3_DECIMAL"))
                EndIf
            EndIf
            If SE2->E2_CONUNI == "1" //Conventional units case
                nFK5VLMOE2 := nValInCntCr
                If SE2->E2_SALDO == nValInCntCr .AND. !lRvlListFl
                    aTmp := RU06XFUN86_GetLastInstallmentValue(cFK7Chave,cWorkTab)
                    If nValInLocCr != SE2->E2_VLCRUZ - (aTmp[3] - aTmp[2])*nSign + IIF(lOnlyCalc,nExRtDifVl,0)
                        // we need theese code becase when we calculate exchange rate difference
                        // we store rounding mistakes is SFR and FK2 and SE5, we should exclude this
                        // mistake when post last installment
                        nValInLocCr := SE2->E2_VLCRUZ - (aTmp[3] - aTmp[2])*nSign + IIF(lOnlyCalc,nExRtDifVl,0) //// we change nValPgTo in FINA080 if it passed by link
                    EndIf
                EndIf
            EndIf
        EndIf
        aBStExpPrm[2][2] := nFK5VLMOE2
    EndIf
    RestArea(aArea)
    aRet := {lRet,nExRtDifVl,nValInLocCr}
Return aRet


/*/{Protheus.doc} RU06XFUN51_CancelExchangeRatesFa080Can
We call this function when cancel write-off in FINA080. If we cancel AP write-off we should also cancel related to it exchange rate differences.
So we must be located on correct SE2 and SE5 record. We must be in transaction mode. SE2 record should be locked.
@type function
@version 1.0
@author astepanov
@since March/31/2022
@param dPostDate, date, Date for cancelling exchange rate differences
@param nValInCntCr, numeric, Value in AP currency
@return logical, result of cancellation
/*/
Function RU06XFUN51_CancelExchangeRatesFa080Can(dPostDate,nValInCntCr)
    Local lRet       As Logical
    Local LRevalList As Logical
    Local lCallStack As Logical
    Local aArea      As Array
    Local aAreaSE2   As Array
    Local aAreaSE5   As Array
    Local aAreaFK2   As Array
    Local aAreaFK5   As Array
    Local aFK2Tot    As Array
    Local aSFRRecnos As Array
    Local aPergParam As Array
    Local aPrvtVals  As Array
    Local cCarteira  As Character
    Local cWorkTab   As Character 
    Local cFR_CHAVOR As Character
    Local dFRDatadi  As Date
    Local nWrOfOnDat As Numeric
    Local nX         As Numeric

    lRet       := .T.
    aArea      := GetArea()
    aAreaSE2   := SE2->(GetArea())
    aAreaSE5   := SE5->(GetArea())
    aAreaFK2   := FK2->(GetArea())
    aAreaFK5   := FK5->(GetArea())
    aAreaSEF   := SEF->(GetArea())
    cWorkTab   := "SE2"
    cCarteira  := SubString(cWorkTab,3,1)//"2" for SE2, "1" for "SE1"
    lRevalList := .F.
    dFRDatadi  := dPostDate
    cFR_CHAVOR := ""
    lCallStack := FWIsInCallStack("RU06D0736_FI080CancelWrite")
    If SE2->E2_MOEDA != 1 .AND. !lCallStack
        lRevalList := .T.
        cFR_CHAVOR := PADR(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA,GetSX3Cache("FR_CHAVOR","X3_TAMANHO")," ")
        aFK2Tot    := RU06XFUN96_CheckWriteOffsOnSameDate(cWorkTab,PADR(SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA,GetSX3Cache("FK7_CHAVE","X3_TAMANHO")," "),dFRDatadi)
        nWrOfOnDat := IIF(SE2->E2_CONUNI == "1",aFK2Tot[2],aFK2Tot[1])
        If nWrOfOnDat == nValInCntCr //cancel only when we have only one write-off on dFRDatadi date
            aPergParam := {}
            For nX := 1 To 60
                Aadd(aPergParam, &("MV_PAR" + StrZero(nX, 2)))
            Next nX
            aPrvtVals := {}
            aPrvtVals := RU06XFUN98_StoreReStorePrivateVarsFromFa080Can(aPrvtVals,"S")
            lRet := RU06D0735_CancelExRates(dFRDatadi,cWorkTab,.T./*Ignore balance*/,PADR("FINA080",TamSX3("F4C_CUUID")[1]," "))
            For nX := 1 To Len(aPergParam)
                &("MV_PAR" + StrZero(nX, 2)) := aPergParam[nX]
            Next nX
            RU06XFUN98_StoreReStorePrivateVarsFromFa080Can(aPrvtVals,"R")
            aPrvtVals := Nil
        EndIf
    EndIf
    If lRet .AND. lRevalList
        aSFRRecnos := RU06XFUN88_GetRevaluationList(cFR_CHAVOR,dFRDatadi,cCarteira)
        lRet := aSFRRecnos[2]
        For nX := 1 To Len(aSFRRecnos[1])
            SFR->(DBGoto(aSFRRecnos[1][nX]))
            SFR->(MSUnlock())
        Next nX
    EndIf
    RestArea(aAreaSEF)
    RestArea(aAreaFK5)
    RestArea(aAreaFK2)
    RestArea(aAreaSE5)
    RestArea(aAreaSE2)
    RestArea(aArea)
Return lRet


/*/{Protheus.doc} RU06XFUN59_GetExchangeRateDifferenceBySE5Recno
Get value of generated exchange rate difference for related SE5 record.
For correct work we should be positioned on correct SE2 record
@type function
@version  1.0
@author astepanov
@since March/31/2022
@param nRecSE5, numeric, SE->(Recno()) or other passed value
@return numeric, exchange rate difference value from SFR table
/*/
Function RU06XFUN59_GetExchangeRateDifferenceBySE5Recno(nRecSE5)
    Local nVal       As Numeric
    Local aArea      As Array
    Local aAreaSE5   As Array
    Local aAreaFKX   As Array
    Local cIDFKX     As Character
    Local cTabFKX    As Character
    Local cE5_IDORIG As Character
    Local cCarteira  As Character
    Local cSFRChavor As Character
    Local cQuery     As Character
    Local cAlias     As Character
    Default nRecSE5 := SE5->(Recno())
    
    nVal     := 0
    aArea    := GetArea()
    aAreaSE5 := SE5->(GetArea())
    
    SE5->(DBGoto(nRecSE5))
    cTabFKX    := SE5->E5_TABORI
    cE5_IDORIG := SE5->E5_IDORIG
    aAreaFKX   := &(cTabFKX)->(GetArea())
    &(cTabFKX)->(DBSetOrder(1))
    &(cTabFKX)->(DbSeek(xFilial(cTabFKX)+cE5_IDORIG))
    If &(cTabFKX)->(Found())
        cIDFKX := &(cTabFKX+"->"+cTabFKX+"_ID"+cTabFKX)
        cCarteira := SubString(cTabFKX,3,1)
        If     cCarteira == "2"
            cSFRChavor  := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
        ElseIf cCarteira == "1"
            cSFRChavor  := SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
        EndIf
        cQuery := " SELECT SUM(SFR.FR_VALOR)   FRVALOR           "
        cQuery += " FROM "+RetSqlName("SFR")+" SFR               "
        cQuery += " WHERE  SFR.FR_FILIAL  = '"+xFilial("SFR")+"' "
        cQuery += "   AND  SFR.FR_CARTEI  = '"+cCarteira+"'      "
        cQuery += "   AND  SFR.FR_CHAVOR  = '"+cSFRChavor+"'     "
        cQuery += "   AND  SFR.FR_IDWTOFF = '"+cIDFKX    +"'     "
        cQuery += "   AND  SFR.D_E_L_E_T_ = ' '                  "
        cQuery := ChangeQuery(cQuery)
        cAlias := MPSysOpenQuery(cQuery)
        DbSelectArea(cAlias)
        DbGoTop()
        If !Eof()
            nVal := FRVALOR
        EndIf
    EndIf
    RestArea(aAreaFKX)
    RestArea(aAreaSE5)
    RestArea(aArea)
Return nVal


/*/{Protheus.doc} RU06XFUN98_StoreReStorePrivateVarsFromFa080Can
We use this function for storing private variables when we call Fa080Can
and restore them if we need it.
@type function
@version 1.0
@author astepanov
@since March/31/2022
@param aValues, array, Array when we store private variables
@param cTip, character, "S" - store private vars in aValues; "R" - restore private values from aValues
@return array, array with stored private variables
/*/
Function RU06XFUN98_StoreReStorePrivateVarsFromFa080Can(aValues,cTip)
    Local aPrvVars As Array
    Local nX       As Numeric
    Local nLen     As Numeric
    Local cPrvVarb As Numeric
    If cTip == "S" // we store values in aValues
        aPrvVars := {"LF080AUTO","LBXLOTE","AAUTOCAB","NESTORIGINAL","LF415AUTO","LFINI055",;
        "LIMP","LGERIMP","AROTINA","CLOTEFIN","CBANCO","CAGENCIA","CCONTA","CCHEQUE","CORDPAG",;
        "CIDPROC","CPORTADO","CNUMBOR","CMARCA","NVALPADRAO","NVALESTRANG","CBENEF","CBANCOV",;
        "CAGENCIAV","CCONTRATO","CPREFV","CNUMV","CPARCV","CTIPV","CNATURV","CFORNECV","NVALACRES",;
        "NTXACRESV","NVALTITV","DDATAVENCV","CCTBAIXA","CFIL080","OVLESTRANG","OCM","LGEROUSEF","NACRESC",;
        "NDECRESC","LINTEGRACAO","LEECFAT","ODIFCAMBIO","OACRESC","ODECRESC","ADADOSSPB","NMOEDABCO",;
        "CCODDIARIO","LIRPROG","NPGTOAUTO","NVALEIC","NOPC1","NUMCHEQUE","CLOTE","CCADASTRO","INCLUI","ALTERA",;
        "AENCHO","LREFRESH","__AMAPFIELD","OMARK","ABAIXASE5","ARECBORRA","NPAGTOPARCIAL","CLOJA","NTOTABAT",;
        "NVALPGTO","CCHAVE","CHIST070","CMOTBX","CMULTNAT"}
        nLen := Len(aPrvVars)
        For nX := 1 To nLen
            cPrvVarb := aPrvVars[nX]
            If TYPE(cPrvVarb) == "U"
                AADD(aValues,{cPrvVarb, Nil})
            Else
                If ValType(&(cPrvVarb)) $ "L|N|D|C|O"
                    AADD(aValues,{cPrvVarb, &(cPrvVarb)})
                EndIf
                If ValType(&(cPrvVarb)) == "A"
                    AADD(aValues,{cPrvVarb, ACLONE(&(cPrvVarb))})
                EndIf
            EndIf

        Next nX 
    EndIf
    If cTip == "R" // we restore values from aValues to Private vars
        For nX := 1 To Len(aValues)
            If TYPE(aValues[nX][1]) != "U"
                If ValType(&(aValues[nX][1])) == "A"
                    &(aValues[nX][1]) := ACLONE(aValues[nX][2])
                Else
                    &(aValues[nX][1]) := aValues[nX][2]
                EndIf
            eNDIF 
        Next nX
    EndIf
Return aValues

/*/{Protheus.doc} RU06XFUN99_CalcE_SaldoWhenExRatDiffCalculating
We use this function for calculating saldo during exchange rate difference calculation
We should be positioned on correct SE2 line. 
@type function
@version 1.0
@author astepanov
@since March/31/2022
@param nCalcSaldo, Numeric, Saldo calculated by standrd (Brazilian) routine
@param aBStExpPrm, array, array generated by RU06D07048_Init_aBStExpPrm function
@param xMVpar11, Variant, passed MV_PAR11
@param xMVpar01, Variant, passed MV_PAR01
@return Numeric, Calculated Saldo
/*/
Function RU06XFUN99_CalcE_SaldoWhenExRatDiffCalculating(nCalcSaldo,aBStExpPrm,xMVpar11,xMVpar01)
    Local nSaldoAt   As Numeric
    Local aTmp       As Array
    nSaldoAt := nCalcSaldo
    If !Empty(aBStExpPrm) .AND. !Empty(aBStExpPrm[1][2])
        If SE2->E2_SALDO == aBStExpPrm[9][2] .AND. !aBStExpPrm[5][2] // last writeoff and revaluation list is empty
            aTmp := RU06XFUN86(SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA,"SE2")
            If SE2->E2_CONUNI =="2"  //non conventional units case
                nSaldoAt := (Round(xMoeda(aBStExpPrm[9][2],SE2->E2_MOEDA,xMVpar11,,5,xMVpar01,aTxMoedas[xMVpar11][2]),2)+aTmp[1]-aTmp[2]) - SE2->E2_VLCRUZ
            Else // conventional units case
                nSaldoAt := ((aTmp[3] + aBStExpPrm[10][2]) - aTmp[2]) - SE2->E2_VLCRUZ
            EndIf
        EndIf
    EndIf
Return nSaldoAt

/*/{Protheus.doc} RU06XFUNAB_Fa084RUSTX
Return STR values from fina084.ch
@type function
@version 1.0 
@author astepanov
@since March/31/2022
@param cString, character, STR00XX
@return character, Localized string value for STR00XX
/*/
Function RU06XFUNAB_Fa084RUSTX(cString)
	Local cRet := ""
	Local nPos As Numeric
	cString := AllTrim(cString)
	nPos := Val(SubString(cString,4,Len(cString)-3))
	cRet := OemToAnsi(FWI18NLang("FINA084",cString,nPos))
Return cRet

/*/{Protheus.doc} RU06XFUNA0_OperOptionsForWriteOff
FI_AP_15_16: We assume that for operation of write-off FINA080, 
we will always use the second option from the combo box with reasons of write-off.
Other options are non-relevant and could be removed for not to confuse users.
@type function
@version 1.0 
@author astepanov
@since March/31/2022
@param aMotBx, Array
@param nI, Numeric
@param aDescMotbx, Array
@return Nil
/*/
Function RU06XFUNA0_OperOptionsForWriteOff(aMotBx, nI, aDescMotbx)
    If SubStr(aMotBx[nI],01,03) == "DAC"
        AADD(aDescMotbx,SubStr(aMotBx[nI],07,10))
    EndIf
Return Nil

/*/{Protheus.doc} RU06XFUNA1_AddLegContrCombos
Add Legal Contract Info to panel
Use in FINA080
@param cLglCntCod, Character
@param oLglCntCod, Object
@param cLglCntDsc, Character
@param oLglCntDsc, Object
@param nUltLin,    Numeric
@param oDlg,       Object
@return Nil
/*/
Function RU06XFUNA1_AddLegContrInfo(nUltLin,oDlg)
    Local  cLglCntCod AS character
    Local  cLglCntDsc AS CHARACTER
    Local  oLglCntDsc as Object
    Local  oLglCntCod AS OBJECT
    If !Empty(SE2->E2_F5QCODE)
        cLglCntCod := SE2->E2_F5QCODE
        nUltLin += 12
        @ nUltLin,005 SAY RetTitle("E2_F5QCODE") SIZE 40,07 OF oDlg PIXEL //"Legal contract code"
        @ nUltLin,065 MSGET oLglCntCod VAR cLglCntCod  SIZE 65, 08 OF oDlg PIXEL HASBUTTON When .F. F3 AllTrim(SX3->X3_F3)
        oLglCntCod:lReadOnly := .T.
        cLglCntDsc := Posicione("F5Q",1,xFilial("F5Q")+SE2->E2_F5QUID,"F5Q_DESCR")
        nUltLin += 12
        @ nUltLin,005 SAY RetTitle("E2_F5QDESC")  SIZE 39,07 OF oDlg PIXEL //"Legal Contract description"
        @ nUltLin,065 MSGET oLglCntDsc VAR cLglCntDsc  SIZE 65, 08 OF oDlg PIXEL HASBUTTON When .F.
    EndIf
Return Nil

/*/{Protheus.doc} RU06XFUNA2_AddConvUnitsInfo
Add Conventional Units Info to panel
Use in FINA080
@param cDescMoeda, Character
@param cCnvUntTtl, Object
@param cCnvUntCbx, Character
@param aCnvUntCbx, Array
@param oCnvUntCbx, Object
@param nUltLin,    Numeric
@param oDlg,       Object
@return Nil
/*/
Function RU06XFUNA2_AddConvUnitsInfo(cDescMoeda,nUltLin,oDlg)
    Local nI As Numeric

	Local cCnvUntTtl    := ""
	Local aCnvUntCbx    := {}
	Local oCnvUntCbx    := Nil
	Local cCnvUntCbx	:= ""


    @ nUltLin,144 SAY RetTitle("E2_MOEDA")	SIZE 53,07 OF oDlg PIXEL COLOR CLR_HBLUE
    @ nUltLin,210 MSGET cDescMoeda 			SIZE 65, 08 OF oDlg PIXEL HASBUTTON When .F. Picture "@!"

    cCnvUntTtl := RetTitle("E2_CONUNI")
    aCnvUntCbx := StrTokArr(AllTrim(X3Cbox()),";")
    cCnvUntCbx := aCnvUntCbx[ASCAN(aCnvUntCbx,{|x| Alltrim(SE2->E2_CONUNI)+"=" $ x})]
    cCnvUntCbx := SubStr(cCnvUntCbx,AT("=",cCnvUntCbx)+1)
    For nI := 1 To Len(aCnvUntCbx)
        aCnvUntCbx[nI] := SubStr(aCnvUntCbx[nI],AT("=",aCnvUntCbx[nI])+1)
    Next nI

    nUltLin += 12
    @ nUltLin,144 SAY cCnvUntTtl SIZE 53,07 OF oDlg PIXEL 
    @ nUltLin,210 MSCOMBOBOX oCnvUntCbx VAR cCnvUntCbx ITEMS aCnvUntCbx SIZE 65, 08 OF oDlg PIXEL When .F.
    nUltLin += 12

Return Nil 

/*/{Protheus.doc} RU06XFUNA3_Change_dDatabase
We change dDatabase and lDtRusChgd when we run fa080can
@param aAutoCab, Array
@param aBaixaSE5, Array
@param nOpBaixa, Numeric
@param lDtRusChgd, Logical
@return Nil
/*/
Function RU06XFUNA3_ChangedDatabase(aAutoCab,aBaixaSE5,nOpBaixa,lDtRusChgd)
    Local nT    As Numeric
    Local nX    As Numeric
    If (Type("lF080Auto")<>"U" .and. lF080Auto) .AND.  (nT := ascan(aAutoCab,{|x| x[1] == 'AUTPAYORD'}) ) > 0
        //Used to find the write-off related to that payment order received in variable AUTPAYORD.
        nX := ascan(aBaixaSE5,{|x| x[29] == aAutoCab[nT][2]})
        If nX > 0
            nOpBaixa := nX
            //check if we need to change the date do original
            If  (nT := ascan(aAutoCab,{|x| x[1] == 'AUTORIGDT'}) ) > 0 //use the original database
                //We must consider the date of operation and not the actual day
                If aAutoCab[nT][2]
                    dDataBase  :=  aBaixaSE5[nX,7]
                    lDtRusChgd := .T.
                Endif
            Endif
            nX := 0
        EndIf
    EndIf
Return Nil 

/*/{Protheus.doc} RU06XFUNA4_Change_PgTo_Valestrang
We change nValPgto and nValestrang and nCorrec when we run fa080can
@param nCorrec, Numeric
@param nValPgto, Numeric
@param nValestrang, Numeric
@return Nil
/*/
Function RU06XFUNA4_Change_PgTo_Valestrang_nCorrec(nCorrec,nValPgto,nValestrang,aBStExpPrm)
    If SE2->E2_MOEDA != 1
        nCorrec := RU06XFUN59(SE5->(Recno()))
    EndIf
    If SE2->E2_CONUNI == "1"
        nValPgto := SE5->E5_VALOR
        nValestrang := SE5->E5_VLMOED2
    Else
        If Empty(aBStExpPrm) .OR. Empty(aBStExpPrm[9][2]) .OR. aBStExpPrm[11][2] /*if aBStExpPrm[11][2] == .T. we are in exchange rates cancelling process */
            nValestrang := SE5->E5_VALOR
            nValPgto := SE5->E5_VLMOED2
        Else
            nValestrang := SE5->E5_VLMOED2
            nValPgto := aBStExpPrm[9][2]
        EndIf
    EndIf
Return Nil

/*/{Protheus.doc} RU06XFUNA5_CancelExRateDiffInFa080Can
cancel exchange rate difference when we run fa080can
Spec: AP Write-off in foreign currency
@param lBaixaOk, Logical, should be .T. for cancelling
@param nCorrec, Numeric
@param lDtRusChgd, Logical
@param dDatSave, Date
@param dBaixa, Date
@param nValestrang, Numeric
@param aBstExpPrm, Array created by RU06D07048_Init_aBStExpPrm
@return Nil
/*/
Function RU06XFUNA5_CancelExRateDiffInFa080Can(lBaixaOk,nCorrec,lDtRusChgd,dDatSave,dBaixa,nValEstrang,aBstExpPrm)
    nCorrec := 0 // we set it parameter to 0, becase we don't need it according to spec.
    //we must cancel exchange rates only for FINA080, because for bank statement cancelling implemented separetly
    If Empty(aBstExpPrm)
        If !lDtRusChgd //Change dDtataBase If We need it
            dDatSave  := dDatabase
            dDatabase := dBaixa
        EndIf
    EndIf
    lBaixaOk  := lBaixaOk .AND. RU06XFUN51(dBaixa,nValEstrang)
Return Nil

/*/{Protheus.doc} RU06XFUNA6_SetFK2Values
Set FK2 submodel values when we call fa080adiant function
Spec: AP Write-off in foreign currency
@param nI, Numeric
@param nValEstrang, Numeric
@param cCpoTp, Character
@param nTxModBco, Numeric
@param nTxMoeda, Numeric
@param oSubFK2, Object
@return Nil
/*/
Function RU06XFUNA6_SetFK2Values(nI,nValEstrang,cCpoTp,nTxModBco,nTxMoeda,oSubFK2)
    oSubFK2:SetValue( "FK2_TXMOED", nTxModBco )
    If SE2->E2_CONUNI == "1" //conventional units case
        oSubFK2:SetValue("FK2_VALOR",&cCpoTp)
        If nValEstrang != 0 .and. nI == 1
            oSubFK2:SetValue("FK2_VLMOE2",nValEstrang)
        Else
            oSubFK2:SetValue("FK2_VLMOE2",xMoeda(&cCpoTp,1,SE2->E2_MOEDA,,,,nTxMoeda))
        EndIf
    Else
        If nValEstrang != 0 .and. nI == 1
            oSubFK2:SetValue("FK2_VALOR", nValEstrang)
        Else
            oSubFK2:SetValue("FK2_VALOR", xMoeda(&cCpoTp,1,SE2->E2_MOEDA,,,,nTxMoeda))
        EndIf
        oSubFK2:SetValue("FK2_VLMOE2",&cCpoTp)
    EndIf
Return Nil

/*/{Protheus.doc} RU06XFUNA7_SetFK2ValuesWhenGrv
Set FK2 submodel values when we call fa080grv function
Spec: AP Write-off in foreign currency
@param nMoedaBco, Numeric
@param nTxMoeda, Numeric
@param aBStExpPrm, Array
@param cCpoTp, Character
@param dBaixa, Date
@param nCentMd1, Numeric
@param cTpDoc, Character
@param nValEstrang, Numeric
@param i, Numeric
@param nTxModBco, Numeric
@param oSubFK2, Object
@return Nil
/*/
Function RU06XFUNA7_SetFK2ValuesWhenGrv(nMoedaBco,nTxMoeda,aBStExpPrm,cCpoTp,dBaixa,nCentMd1,cTpDoc,nValEstrang,i,nTxModBco,oSubFK2)
    If nMoedaBco == SE2->E2_MOEDA
        nTxModBco := nTxMoeda
        oSubFK2:SetValue( "FK2_TXMOED", nTxModBco )
        If SE2->E2_CONUNI == "1" .AND. !Empty(aBStExpPrm) .AND. aBStExpPrm[10][2] != Nil
            oSubFK2:SetValue("FK2_VALOR", aBStExpPrm[10][2])
        Else
            If !Empty(aBStExpPrm) .AND. aBStExpPrm[9][2] != Nil
                oSubFK2:SetValue("FK2_VALOR"  , aBStExpPrm[9][2])
            Else
                oSubFK2:SetValue("FK2_VALOR", Round(NoRound(xMoeda(&cCpoTp,1,SE2->E2_MOEDA,dBaixa,nCentMd1+1,,nTxModBco),nCentMd1+1),nCentMd1))
            EndIf
        EndIf
        If !Empty(aBStExpPrm) .AND. aBStExpPrm[2][2] != Nil
            oSubFK2:SetValue( "FK2_VLMOE2", aBStExpPrm[2][2])
        Else
            oSubFK2:SetValue( "FK2_VLMOE2", Round(NoRound(xMoeda(&cCpoTp,nMoedaBco,1,dBaixa,nCentMd1+1,,nTxModBco),nCentMd1+1),nCentMd1))
        EndIf
    Else
        oSubFK2:SetValue( "FK2_VALOR" , &cCpoTp )
        If nValEstrang != 0 .and. cTpDoc $ "BA|VL" //i == 6  // VL ou BA
            If SE2->E2_CONUNI == "1" .AND. !Empty(aBStExpPrm) .AND. aBStExpPrm[2][2] != Nil
                oSubFK2:SetValue( "FK2_VLMOE2", aBStExpPrm[2][2])
            Else
                oSubFK2:SetValue( "FK2_VALOR"  , nValEstrang)
                oSubFK2:SetValue( "FK2_VLMOE2" , &cCpoTp )
            EndIf
        Else
            oSubFK2:SetValue( "FK2_VLMOE2", Iif(i!=4 .or. SE2->E2_MOEDA<=1,Round(NoRound(xMoeda(&cCpoTp.,nMoedaBco,SE2->E2_MOEDA,dBaixa,nCentMd1+1,nTxMoeda),nCentMd1+1),nCentMd1),0) )
        EndIf
        If SE2->E2_MOEDA > 1
            oSubFK2:SetValue( "FK2_TXMOED", nTxMoeda )
        Endif
    EndIf
Return Nil

/*/{Protheus.doc} RU06XFUNA8_AddLineTo_aBaixaSE5
Add line to abaixa SE5 in FINA080
@param aBaixaSE5, Array
@return Nil
/*/
Function RU06XFUNA8_AddLineTo_aBaixaSE5(aBaixaSE5)
    Aadd(aBaixaSE5,{ SE5->E5_PREFIXO, SE5->E5_NUMERO, SE5->E5_PARCELA, SE5->E5_TIPO, SE5->E5_CLIFOR, ;
                     SE5->E5_LOJA, SE5->E5_DATA, SE5->E5_VALOR, SE5->E5_SEQ, SE5->E5_DTDISPO, SE5->E5_BANCO, ;
                     SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VRETPIS, SE5->E5_VRETCOF, ;
                     SE5->E5_VRETCSL, SE5->E5_PRETPIS, SE5->E5_PRETCOF, SE5->E5_PRETCSL, SE5->E5_TIPODOC, ;
                     SE5->E5_VRETIRF, SE5->E5_PRETIRF, SE5->E5_VLDESCO, SE5->E5_VLJUROS, SE5->E5_VLMULTA, ;
                     0,0,SE5->E5_ORDREC})
Return Nil

/*/{Protheus.doc} RU06XFUNA9_Change_nCM_nValPgto
Change nCM and nValPgto when function Fa080ValEstrang called
@param dBaixa, Date
@param nTxMoeda, Numeric
@param nValEstrang, Numeric
@param nValPgto, Numeric
@param nCM, Numeric
@return Nil
/*/
Function RU06XFUNA9_Change_nCM_nValPgto(dBaixa,nTxMoeda,nValEstrang,nValPgto,nCM)
    Local aRusTmpArr As Array
    If SE2->E2_MOEDA > 1
        aRusTmpArr := RU06XFUN11({},dBaixa,nTxMoeda,nValEstrang,nValPgto,.T.)
        If aRusTmpArr[1]
            nCM      := aRusTmpArr[2]
            nValPgto := aRusTmpArr[3]
        EndIf
    EndIf
Return Nil

/*/{Protheus.doc} RU06XFUNAA_Set_nTxMoeda_For_AdvanceAP
Change nTxMoeda for advance AP in function fa080Tit
@param cMVPAGANT, Character
@param aAutoCab, Array
@param nTxMoeda, Numeric
@return Nil
/*/
Function RU06XFUNAA_Set_nTxMoeda_For_AdvanceAP(cMVPAGANT,aAutoCab,nTxMoeda)
    Local nT As Numeric
    If SE2->E2_TIPO $ cMVPAGANT
        nTxMoeda := SE2->E2_TXMOEDA
    EndIf
    If (nT := ascan(aAutoCab,{|x| x[1]='AUTTXMOEDA'}) ) > 0
        nTxMoeda := aAutoCab[nT,2]
    EndIf
Return Nil

/*/{Protheus.doc} RU06XFUNAC_Add_to_aSaldo
Add aSaldo values when we call fa084cdif
we must be positioned on cerrect SE2 line
@param nSaldoAt, Numeric, Saldo at exchange rate difference calculation
@param nSaldo, Numeric
@param aTxMoedas, Array, Currencies and exchange rates array
@param nMV_PAR11 , Numeric, Foreign currency position in aTxMoedas
@param aSaldo, Array to which we add next exchange rate difference calculation
@return Nil
/*/
Function RU06XFUNAC_Add_to_aSaldo(nSaldoAt,nSaldo,aTxMoedas,nMV_PAR11,aSaldo)
AADD(aSaldo,{nSaldoAt,nSaldo,aTxMoedas[SE2->E2_MOEDA][2],aTxMoedas[nMV_PAR11][2],0 /*origsfrrecno*/,'0'/*newsfrrbdbal*/,' ' /*sfridwtoff*/})
Return Nil




/*/{Protheus.doc} RU06XFUN2H_SaveVarPrivFIA070
Save Private variables for FINA070 befor revaluation 
    because it will call FINA070 again and overwrite private variables
@type function
@version  P12
@author eduardo.Flima
@since 10/01/2021
@return array, array with the variables to be saved 
/*/
Function RU06XFUN2H_SaveVarPrivFIA070()
    Local aPrvt AS array

    aPrvt:={}

    SaveVarPrv(@aPrvt,"lF070Auto")
    SaveVarPrv(@aPrvt,"aAutoCab")
    SaveVarPrv(@aPrvt,"cPortado")
    SaveVarPrv(@aPrvt,"cBanco")
    SaveVarPrv(@aPrvt,"cAgencia")
    SaveVarPrv(@aPrvt,"cConta")
    SaveVarPrv(@aPrvt,"cNatMov")
    SaveVarPrv(@aPrvt,"lValidou")
    SaveVarPrv(@aPrvt,"lOracle")
    SaveVarPrv(@aPrvt,"aDadosRef")
    SaveVarPrv(@aPrvt,"lFini055")
    SaveVarPrv(@aPrvt,"nValRec")
    SaveVarPrv(@aPrvt,"nOldValRec")

    SaveVarPrv(@aPrvt,"aRotina")
    SaveVarPrv(@aPrvt,"nValTot")
    SaveVarPrv(@aPrvt,"nJuros")
    SaveVarPrv(@aPrvt,"nVA")
    SaveVarPrv(@aPrvt,"nMulta")
    SaveVarPrv(@aPrvt,"nPIS")
    SaveVarPrv(@aPrvt,"nCOFINS")
    SaveVarPrv(@aPrvt,"nCSLL")
    SaveVarPrv(@aPrvt,"nIss")
    SaveVarPrv(@aPrvt,"nInss")
    SaveVarPrv(@aPrvt,"nlImpMR")
    SaveVarPrv(@aPrvt,"nCM")
    SaveVarPrv(@aPrvt,"nDescont")
    SaveVarPrv(@aPrvt,"nTotAGer")
    SaveVarPrv(@aPrvt,"nTotADesp")
    SaveVarPrv(@aPrvt,"nTotADesc")
    SaveVarPrv(@aPrvt,"nTotAMul")
    SaveVarPrv(@aPrvt,"nTotAJur")
    SaveVarPrv(@aPrvt,"nValPadrao")
    SaveVarPrv(@aPrvt,"nValEstrang")
    SaveVarPrv(@aPrvt,"cMarca")
    SaveVarPrv(@aPrvt,"cLote")
    SaveVarPrv(@aPrvt,"cLoteFin")
    SaveVarPrv(@aPrvt,"cNaturLote")
    SaveVarPrv(@aPrvt,"nAcresc")
    SaveVarPrv(@aPrvt,"nDecresc")
    SaveVarPrv(@aPrvt,"aCaixaFin")
    SaveVarPrv(@aPrvt,"aCols")
    SaveVarPrv(@aPrvt,"aHeader")
    SaveVarPrv(@aPrvt,"nMoedaBco")
    SaveVarPrv(@aPrvt,"nCM1")
    SaveVarPrv(@aPrvt,"nProRata")
    SaveVarPrv(@aPrvt,"cCodDiario")
    SaveVarPrv(@aPrvt,"nVlRetPis")
    SaveVarPrv(@aPrvt,"nVlRetCof")
    SaveVarPrv(@aPrvt,"nVlRetCsl")
    SaveVarPrv(@aPrvt,"aDadosRet")
    SaveVarPrv(@aPrvt,"nIrrf")
    SaveVarPrv(@aPrvt,"nOldIrrf")

    SaveVarPrv(@aPrvt,"aBxAcr")
    SaveVarPrv(@aPrvt,"aBxDec")
    SaveVarPrv(@aPrvt,"nDecrVlr")
    SaveVarPrv(@aPrvt,"nOdlMoedBco")
    SaveVarPrv(@aPrvt,"nTxMoeda")
    SaveVarPrv(@aPrvt,"nRuCont")
    SaveVarPrv(@aPrvt,"nRuDig")

    SaveVarPrv(@aPrvt,"oFontLbl")
    SaveVarPrv(@aPrvt,"lInverte")

    SaveVarPrv(@aPrvt,"nPisCalc")
    SaveVarPrv(@aPrvt,"nCofCalc")
    SaveVarPrv(@aPrvt,"nCslCalc")
    SaveVarPrv(@aPrvt,"nIrfCalc")
    SaveVarPrv(@aPrvt,"nIssCalc")
    SaveVarPrv(@aPrvt,"nPisBaseR")
    SaveVarPrv(@aPrvt,"nCofBaseR")
    SaveVarPrv(@aPrvt,"nCslBaseR")
    SaveVarPrv(@aPrvt,"nIrfBaseR")
    SaveVarPrv(@aPrvt,"nIssBaseR")
    SaveVarPrv(@aPrvt,"nPisBaseC")
    SaveVarPrv(@aPrvt,"nCofBaseC")
    SaveVarPrv(@aPrvt,"nCslBaseC")
    SaveVarPrv(@aPrvt,"nIrfBaseC")
    SaveVarPrv(@aPrvt,"nIssBaseC")

    SaveVarPrv(@aPrvt,"aParamAuto")

    SaveVarPrv(@aPrvt,"cCadastro")

    SaveVarPrv(@aPrvt,"lRaRtImp")
    SaveVarPrv(@aPrvt,"nParciais")
    SaveVarPrv(@aPrvt,"aBaixaSE5")
    SaveVarPrv(@aPrvt,"cMotBx")
    SaveVarPrv(@aPrvt,"oVlEstrang")
    SaveVarPrv(@aPrvt,"oValRec")
    SaveVarPrv(@aPrvt,"oCM")
    SaveVarPrv(@aPrvt,"oAgencia")
    SaveVarPrv(@aPrvt,"oBanco")
    SaveVarPrv(@aPrvt,"oConta")
    SaveVarPrv(@aPrvt,"oDescont")
    SaveVarPrv(@aPrvt,"nOtrga")
    SaveVarPrv(@aPrvt,"nDifCambio")
    SaveVarPrv(@aPrvt,"aTxMoedas")
    SaveVarPrv(@aPrvt,"cModSpb")
    SaveVarPrv(@aPrvt,"nAcrescF")
    SaveVarPrv(@aPrvt,"nIndexSE1")
    SaveVarPrv(@aPrvt,"cIndexSE1")
    SaveVarPrv(@aPrvt,"lAltera")
    SaveVarPrv(@aPrvt,"nOldValor")
    SaveVarPrv(@aPrvt,"nOldIss")
    SaveVarPrv(@aPrvt,"nOldInss")
    SaveVarPrv(@aPrvt,"nOldPis")
    SaveVarPrv(@aPrvt,"nOldCofins")
    SaveVarPrv(@aPrvt,"nOldCsll")
    SaveVarPrv(@aPrvt,"nOldVlAcres")
    SaveVarPrv(@aPrvt,"nOldIrrf")
    SaveVarPrv(@aPrvt,"nOldVlDecres")
    SaveVarPrv(@aPrvt,"lAlterNat")
    SaveVarPrv(@aPrvt,"nOldVencto")
    SaveVarPrv(@aPrvt,"nOldVenRea")
    SaveVarPrv(@aPrvt,"cOldNatur")
    SaveVarPrv(@aPrvt,"nOldVlCruz")
    SaveVarPrv(@aPrvt,"lAlterImp")
    SaveVarPrv(@aPrvt,"aDadosRet")
    SaveVarPrv(@aPrvt,"nSomaCheq")
    SaveVarPrv(@aPrvt,"nIrrf")
    SaveVarPrv(@aPrvt,"nOldDescont")
    SaveVarPrv(@aPrvt,"nOldMulta")
    SaveVarPrv(@aPrvt,"nOldJuros")
    SaveVarPrv(@aPrvt,"nOldVA")
    SaveVarPrv(@aPrvt,"cOldVA")
    SaveVarPrv(@aPrvt,"lTitLote")
    SaveVarPrv(@aPrvt,"cTpDesc")
    SaveVarPrv(@aPrvt,"lBloqSa1")
    SaveVarPrv(@aPrvt,"cFilAbat")
    SaveVarPrv(@aPrvt,"lBolsa")
    SaveVarPrv(@aPrvt,"nDescCalc")
    SaveVarPrv(@aPrvt,"nJurosCalc")
    SaveVarPrv(@aPrvt,"nMultaCalc")
    SaveVarPrv(@aPrvt,"aRetMsg")
    SaveVarPrv(@aPrvt,"lReval")

    If lF070Auto
        SaveVarPrv(@aPrvt,"lAutValRec")
    EndIf

    SaveVarPrv(@aPrvt,"dBaixa")
    SaveVarPrv(@aPrvt,"cHist070")

    //cancel
    SaveVarPrv(@aPrvt,"n")

Return aPrvt

/*/{Protheus.doc} SaveVarPrv
set the array with the variables and i`ts conttents to be saved
@type function
@version  P12
@author eduardo.Flima
@since 10/01/2021
@param aSave, array, array with the variables to be saved
@param cVar, character, name of the variable to be saved
/*/
Static Function SaveVarPrv(aSave,cVar)
    If Type(cVar) != 'U'    
        AADD(aSave,{cVar,&(cVar)})
    EndIf
Return .T.

/*/{Protheus.doc} RU06XFUN2J_LoadVarPrivFIA070
Restore the conttent of the priavles variables related to FINA070
@type function
@version  P12
@author eduardo.Flima
@since 10/01/2021
@param aPrvt, array,array with the variables to be saved
/*/
Function RU06XFUN2J_LoadVarPrivFIA070(aPrvt)
    Local nX     As Numeric
    For nX:=1 to Len(aPrvt)
        &( aPrvt[nX][1] ) := aPrvt[nX][2]
    Next nX
Return .T.

/*/{Protheus.doc} RU06XFUN1A_GetOldToRebuild
@type           
@description    Return If there is revaluations with date before the date of opetarion in status TO-REBUILD
@param          Character    cFR_CHAVOR  // string formatted according to FR_CHAVOR
                Date         dTranDate   // date of operation
                Character    cCarteira  // Type of the operation 1-Receivable, 2-Payable
@return         Logica       lRet        // Return if tehre is or not  revaluations with date before the date of opetarion in status TO-REBUILD 
@author         eduardo.Flima
@since          18 FeB 2022
@specification  FI-AP-15-17
@project        MA3 - Russia
/*/
Function RU06XFUN1A_GetOldToRebuild(cFR_CHAVOR,dTranDate,cCarteira)
    Local cAlias   As Character
    Local cQuery   As Character
    Local aArea    As Array
    Local aAreaSFR As Array
    Local lRet     As Logical

    Default cCarteira:="2"
    lRet:=.F.
    aArea := GetArea()
        aAreaSFR := SFR->(GetArea())
            cFR_CHAVOR := PADR(cFR_CHAVOR,GetSX3Cache("FR_CHAVOR","X3_TAMANHO")," ")
            cQuery :=  " SELECT SFR.R_E_C_N_O_ SFRRECNO                      "
            cQuery +=  " FROM   "+RetSqlName("SFR")+"  SFR                   "
            cQuery +=  " WHERE   SFR.FR_FILIAL  = '"+xFilial("SFR")   + "'   "
            cQuery +=  "   AND   SFR.FR_CARTEI  = '"+   cCarteira        + "'   "
            cQuery +=  "   AND   SFR.FR_CHAVOR  = '"+   cFR_CHAVOR    + "'   "
            cQuery +=  "   AND   SFR.FR_DATADI  <= '"+ DTOS(dTranDate) + "'   "
            cQuery +=  "   AND   SFR.FR_TIPODI  = 'S'                        "
            cQuery +=  "   AND   SFR.FR_RBDBAL = '1'                         "
            cQuery +=  "   AND   SFR.D_E_L_E_T_ = ' '                        "
            cQuery := ChangeQuery(cQuery)
            cAlias := MPSysOpenQuery(cQuery)
            DBSelectArea(cAlias)
                (cAlias)->(DBGoTop())
                If (cAlias)->(!Eof())
                    lRet:=.T.
                EndIf
            (cAlias)->(DBCloseArea())
        RestArea(aAreaSFR)
    RestArea(aArea)
Return lRet


/*/{Protheus.doc} RU06XFUN1B_AddRusInfo
Add Fields descriptions and informations that shlould be used only for russian localization in write-off and cancelling write-off (FINA070)
@type Function    
@author  eduardo.Flima
@since   04/03/2022
@param oPanel1, Object,   Main panel of FINA070 
@param oCurrency, Object, object of the currency information
@param oConUni, Object,   object of the conventional units information
@param oLegCnt, Object,   object of the legal contract information                
@param lCanc, Logical,    variable indicating if it is a canceling
@param a1stRow, Array,    array with initial corditanes to set the screeen used only in cancelation.
@see  FI-AP-15-17
/*/
Function RU06XFUN1B_AddRusInfo(oPanel1,oCurrency,oConUni,oLegCnt,lCanc,a1stRow)    
    Local aConUni       := {}
    Local cTitCur       := ""
    Local cTitConUni    := ""
    Local cLegCnt       := ""
    Local cDesCurr      := ""
    Local cDesCnt      := ""

    DEFAULT lCanc       :=.F.
    DEFAULT a1stRow     :={}
    

    aConUni     := SEPARA(RU06XFUN2I("E1_CONUNI" ,2),";") // RU06XFUN2I_NewGetSx3Cache
    cTitCur     := RU06XFUN2I("E1_MOEDA"  ,1) //RU06XFUN2I_NewGetSx3Cache
    cTitConUni	:= RU06XFUN2I("E1_CONUNI" ,1) //RU06XFUN2I_NewGetSx3Cache
    cLegCnt     := RU06XFUN2I("E1_F5QCODE",1) //RU06XFUN2I_NewGetSx3Cache

	cDesCurr:=(Posicione("CTO",1,xFilial("CTO")+StrZero(SE1->E1_MOEDA,TamSX3("CTO_MOEDA")[1]),"CTO_DESC"))
    cDesCnt:=Iif(!EMPTY(SE1->E1_F5QCODE),Posicione("F5Q",2,XFILIAL("F5Q")+SE1->E1_F5QCODE,"F5Q_DESCR"),"")

    If lCanc
		@ a1stRow[1] +044,a1stRow[2] +004 SAY cTitCur 				SIZE 31,07 OF oDlg PIXEL //"Currency"
		@ a1stRow[1] +044,a1stRow[2] +030 MSGET oCurrency VAR SE1->E1_MOEDA	F3 "CTO" SIZE 20,08 OF oDlg PIXEL HASBUTTON  When .F.

		@ a1stRow[1] +044,a1stRow[2] +050 MSGET cDesCurr SIZE 30,08 OF oDlg PIXEL When .F.
		@ a1stRow[1] +044,a1stRow[2] +085 SAY cTitConUni 				SIZE 48,08 OF oDlg PIXEL //"Conv.units"
		@ a1stRow[1] +044,a1stRow[2] +115 COMBOBOX oConUni VAR SE1->E1_CONUNI ITEMS aConUni SIZE 30, 08 OF oDlg PIXEL When .F.

		@ a1stRow[1] +056,a1stRow[2] +004 SAY cLegCnt 				SIZE 31,07 OF oDlg PIXEL //"Leg. Contr."
		@ a1stRow[1] +056,a1stRow[2] +030 MSGET oLegCnt VAR SE1->E1_F5QCODE	F3 "F5Q" SIZE 20,08 OF oDlg PIXEL HASBUTTON  When .F.

		@ a1stRow[1] +056,a1stRow[2] +085 MSGET cDesCnt SIZE 165,08 OF oDlg PIXEL When .F.
    else            
        @ 041,004 SAY cTitCur 				SIZE 31,07 OF oPanel1 PIXEL //"Currency"
        @ 041,030 MSGET oCurrency VAR SE1->E1_MOEDA	F3 "CTO" SIZE 20,08 OF oPanel1 PIXEL HASBUTTON  When .F.

        @ 041,050 MSGET cDesCurr SIZE 30,08 OF oPanel1 PIXEL When .F.
        @ 041,085 SAY cTitConUni 				SIZE 48,08 OF oPanel1 PIXEL //"Conv.units"
        @ 041,115 COMBOBOX oConUni VAR SE1->E1_CONUNI ITEMS aConUni SIZE 30, 08 OF oPanel1 PIXEL When .F.

        @ 052,004 SAY cLegCnt 				SIZE 31,07 OF oPanel1 PIXEL //"Leg. Contr."
        @ 052,030 MSGET oLegCnt VAR SE1->E1_F5QCODE	F3 "F5Q" SIZE 20,08 OF oPanel1 PIXEL HASBUTTON  When .F.
        		
        @ 052,085 MSGET cDesCnt SIZE 165,08 OF oPanel1 PIXEL When .F.
    ENDIF
    oCurrency:lReadOnly := .T.		
    oLegCnt:lReadOnly := .T.		
Return 


/*/{Protheus.doc} RU06XFUN1C_CalcBalAval
Calculate the balance avaliable for write-off acording to rules of lock balance rebuild exchange rate  and conventional units
@type   Function           
@author  eduardo.Flima
@since   12/03/2022
@version vevrsion  
@param  nValOrig,  Numeric,   Original balance avaliable before the rules applied 
@param  nTotAbat, Numeric,    Value related to decrease values like balance locked
@param  nMulta, Numeric,      Value related to penalty if aplyable
@param nMoedaBco, Numeric,    Currency of the operation                
@param nTxMoeda, Numeric,     Tax rate  of the operation
@param nTxMdaOr, Numeric,     Tax rate original of the bill
@param dBaixa, Date,          Date of the operation
@param nDecimal, Numeric,     float points of the calculation
@param lReval, Logical,      If the calculation will be revaluated in a latter operation
@param nTypeOper, Numeric,   the kind of calculation to be done as standart.
@return nvalSld,  Numeric,   Balance avaliable for write-off
@see  FI-AP-15-17
/*/
Function RU06XFUN1C_CalcBalAval(nValOrig,nTotAbat,nMulta,nTotMult,nMoedaBco,nTxMoeda,nTxMdaOr,dBaixa,nDecimal,lReval,nTypeOper)

    Local aTmp      as Array
    Local nvalSld   as Numeric    

    DEFAULT lReval      :=.F.
    DEFAULT nTotAbat    :=0
    DEFAULT nMulta      :=0
    DEFAULT nTotMult    :=0
    DEFAULT nMoedaBco   :=1
    DEFAULT nTxMoeda    :=1
    DEFAULT nDecimal    :=7
    DEFAULT nTypeOper   :=1   

    aTmp        :={}
    nvalSld     :=0

    If SE1->E1_MOEDA !=1 .AND. nValOrig==SE1->E1_SALDO .AND. !lReval
        aTmp := RU06XFUN86(SE1->E1_FILIAL+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA,"SE1")
        If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
            If SE1->E1_CONUNI == "1"
                nvalSld :=  SE1->E1_VLCRUZ + ((aTmp[3]) - aTmp[2])
            Else
                nvalSld :=  SE1->E1_VLCRUZ + ((aTmp[1]) - aTmp[2])
            Endif
        Else
            If SE1->E1_CONUNI == "1"
                nvalSld :=  SE1->E1_VLCRUZ - ((aTmp[3]) - aTmp[2])
            Else
                nvalSld :=  SE1->E1_VLCRUZ - ((aTmp[1]) - aTmp[2])
            Endif
        Endif
    Else					
		Do Case 
			Case nTypeOper == 1 
                nvalSld := Round(xMoeda(SE1->E1_SALDO-nTotAbat + Iif(SE1->E1_JUROS > 0,nMulta,nTotMult),SE1->E1_MOEDA,nMoedaBco,,nDecimal,nTxMoeda),2)
			Case nTypeOper == 2 
                nvalSld	:= xMoeda(nValOrig,SE1->E1_MOEDA,nMoedaBco,dBaixa,nDecimal,nTxMdaOr,nTxMoeda)
			Case nTypeOper == 3 
                nvalSld := xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,nMoedaBco,,nDecimal,nTxMoeda,)
		EndCase		    
    Endif
Return nvalSld

/*/{Protheus.doc} RU06XFUN1D_VldBal          
Validate if the value use match the avaliable ballance   acording to rules of lock balance rebuild exchange rate  and conventional units
Plus reset the valiables to store the values if valid or not.
@type Function
@author  eduardo.Flima
@since   12/03/2022
@version version
@param  nValOrig,    Numeric,  Value to be validated
@param  nValEstrang, Numeric,  Value in foreing  currency
@param  nTotAbat,    Numeric,  Value related to decrease values like balance locked
@param  nMulta,      Numeric,  Value related to penalty if aplyable
@param  nMoedaBco,   Numeric,  Currency of the operation                
@param  nTxMoeda,    Numeric,  Tax rate  of the operation
@param  dBaixa,      Date,     Date of the operation
@param  lReval,      Logical,  If the calculation will be revaluated in a latter operation
@param  aTxMoedas,   Array,    Array with tax currencyes 
@return  lRet, Logical,        If it`s a valid value
@see  FI-AP-15-17
/*/
Function RU06XFUN1D_VldBal(nValRec,nValEstrang,nTotAbat,nMulta,nMoedaBco,nTxMoeda,dBaixa,lReval,aTxMoedas)
    Local lRet as Logical 
    Local nValCalc as Numeric

    DEFAULT lReval      :=  .F.
    DEFAULT nTotAbat    :=  0
    DEFAULT nMulta      :=  0
    DEFAULT nTotMult    :=  0
    DEFAULT nMoedaBco   :=  1
    DEFAULT nTxMoeda    :=  1
    DEFAULT dBaixa      :=  dDataBase
    DEFAULT aTxMoedas   := {}
 
    
    

    lRet        :=.T.
    nValCalc    :=0

    RU06XFUN1N_SetTxMoed(@nTxMoeda,,aTxMoedas)

    nValCalc:=RU06XFUN1C(nValEstrang,nTotAbat,nMulta,,nMoedaBco,nTxMoeda,,dBaixa,7,lReval.OR.nTotAbat!=0,3)
    lRet	:= Str(nValRec,17,2) <= Str(nValCalc,17,2)

    If lRet
    	nOldValrec:=nValrec
    Else
		nValEstrang:= Round(Noround(xMoeda(nValrec,nMoedaBco,SE1->E1_MOEDA,,3,,nTxMoeda),3),2)		
		nEstOriginal := nValEstrang-(xMoeda(nJuros+nVa+(nCm1+nProRata)+nMulta-nDescont-nOtrga+nAcresc-nDecresc ,nMoedaBco,SE1->E1_MOEDA,,,,nTxMoeda))
		FA070CORR(nEstOriginal,nTxMoeda)
    EndIf

Return lRet 

/*/{Protheus.doc} RU06XFUN1E_SetMd
Auxiliar proccess needed in function Fa070SetMd needed only for localization Russia
@type Function
@author  eduardo.Flim
@since   12/03/2022
@version version
@param   nTxMoeda   , Numeric,  Tax rate  of the operation
@param   lReval     , Logical,  If the calculation will be revaluated in a latter operation
@param   nValEstrang, Numeric,  Value in foreing  currency
@param   nValRec    , Numeric,  Value calculated
@param   nOldValRec , Numeric,  Value before the update                
@param   nTotAbat   , Numeric,  Value related to decrease values like balance locked
/*/
Function RU06XFUN1E_SetMd(nTxMoeda,lReval,nValEstrang,nValRec,nOldValRec,nTotAbat)
    Local nTxOrig       As Numeric
    Local dUltDif       As Date 
    Local lAchouSFR     As Logical
    Local lAchouDt      As Logical
    Local nTxAt         As Numeric
    Local lRbdBal		As Logical

    nTxOrig     :=0
    nTxAt       :=0
    dUltDif     := Ctod("")
    lAchouSFR   := .F.
    lAchouDt    := .F.    
    lRbdBal		:= .F.

    If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
        nTxMoeda:= SE1->E1_TXMOEDA
    ELSE
        RU06D07051(@nTxOrig,@dUltDif,@lAchouSFR,@lAchouDt,@nTxAt,@lRbdBal)
        If nTxMoeda != nTxAt .or. lRbdBal
            lReval:=.T.
        ELSE
            lReval:=.F.
        EndIf	
    EndIf
    nValEstrang:= SE1->E1_SALDO-nTotAbat
    nValRec:=RU06XFUN1C(nValEstrang,nTotAbat,,,nMoedaBco,nTxMoeda,/*/nTxMdaOr/*/,/*/dBaixa/*/,3,lReval.OR.nTotAbat!=0,1)
    nOldValRec:=nValrec
    If Type("oValEstrang") == "O"
        oVlEstrang:Refresh()
    Endif			

    If Type("oValRec") == "O"
        oValRec:Refresh()
    Endif		
Return  

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN1F_F070REFR()
Atualiza Objeto
@author  eduardo.FLima
@since 12/2021
@version 12
/*/
//-------------------------------------------------------------------
FUNCTION RU06XFUN1F_F070REFR(oVar)
	oVar:Refresh()
Return .T.

/*/{Protheus.doc} RU06XFUN1G_FA070BtOK
Extra validation for russian localization in the confirmation of the write-off 
@type Function
@author eduardo.Flima
@since  18/03/2022
@version version          
@param  nMoedaBco, Numeric,      Currency of the operation
@param  aTxMoedas, Array  ,      Array with tax currencyes
@param  lReval   , Logical,      If the calculation will be revaluated in a latter operation
@return lReturn,   Logical,      If we can proceed with the wirte-off
@see  FI-AP-15-17
/*/
FUNCTION RU06XFUN1G_FA070BtOK(aTxMoedas,lReval)
    LOCAL lRet          AS Logical
    LOCAL nTxMoeda      AS NUMERIC
    LOCAL cFA070BtOK    AS Character
    Local aTmp          AS Array   

    DEFAULT aTxMoedas   :={}
    DEFAULT lReval      :=.T.


    lRet        :=.T.
    nTxMoeda    :=0
    cFA070BtOK  :=""
    aTmp        :={}


   RU06XFUN1N_SetTxMoed(@nTxMoeda,,aTxMoedas)
    lRet := RU06XFUNBC_CHeckTxxMoed(nTxMoeda,SE1->E1_MOEDA)
	iF lRet .AND. lReval
		aTmp := RU06XFUN87("SE1",dDataBase)
		If aTmp[1] != Nil .AND. aTmp[1] == dDataBase .AND. !(aTmp[2] == aTxMoedas[SE1->E1_MOEDA][2])
			Help( ,,"EXRATE",,STR0100+DTOC(dDataBase)+chr(13)+chr(10)+; //"There is already an exchange rate revaluation calculation for this bill on the date of "
				STR0101+chr(13)+chr(10)+; //" In the existing revaluation the exchange rate used was:"
				Transform(aTmp[2],PesqPict("SFR","FR_TXATU"))+;
				chr(13)+chr(10)+STR0102+chr(13)+chr(10)+; //" However, in the current bill we have the rate:"
				Transform(aTxMoedas[SE1->E1_MOEDA][2],PesqPict("SFR","FR_TXATU"))+;
				chr(13)+chr(10)+STR0103; //" So the write-off will not continue."
				, 1, 0 , NIL, NIL, NIL, NIL, NIL, {STR0104}) //" It is needed to change the tax rate of the current bill or to cancel the previows exchange rate revaluation for this bill in this date"
			lRet := .F.
		EndIf
	Endif


Return lRet

/*/{Protheus.doc} RU06XFUN1H_ResetVar
Reset variables when the write-off is in conventional unit 
@type Funcgtion
@author eduardo.Flima
@since   18/03/2022
@version version
@param  nValOld    , Numeric  ,  Value before the change
@param  nValRec    , Numeric  ,  New value calculated
@param  nValEstrang, Numeric  ,  Value in foreing  currency                
@param  cMotBx     , Character,  Reason for write-off 
@param  cConUni    , Character,  Conventional Units
@see  FI-AP-15-17
/*/
FUNCTION RU06XFUN1H_ResetVar(nValOld,nValRec,nValEstrang,cMotBx,cConUni)
    IF TrazCodMot(cMotBx) == "DAC" .and. cConUni !='1' 
        nValOld		:= nValRec					
        nValRec		:= nValEstrang
        nValEstrang	:= nValOld
    Endif
Return 

/*/{Protheus.doc} RU06XFUN1I_GenExrat
Function responsible for preparation and generation of  exchange rate in write-off FINA070 
@type Function          
@author  eduardo.Flima
@since   18/03/2022
@version vevrsion
@param  lReval , Logical, If the calculation will be revaluated in a latter operation
@param  aRecSfr, Array  , Array with the recno of SFR generated in the process                
@return lReturn, Logical, If the proccess has happened correctly
@see  FI-AP-15-17
/*/
FUNCTION RU06XFUN1I_GenExrat(lReval,aRecSfr)
    Local lRet      as Logical 
    Local nX        as Numeric			
    Local aPrvt     as Array
    Local aMvPar    as Array 
    Local aAreaSe1  as Array 
    Local aAreaFK1  as Array 
    Local aAreaaUX  as Array 
    
    Private l070Err			:=.F.
    lRet        :=.T.
    nX          :=0
    aPrvt       := {}
    aMvPar	    := {}
    aAreaSe1    := {}
    aAreaFK1	:= {}
    aAreaaUX	:= {}
    

    If ! FwIsInCallStack("F074Grava") .AND. lReval
        SaveInter() //Save status of private and public variables
        aprvt:={}
        aprvt:=RU06XFUN2H()//Save private variables FINA070
        
        aMvPar := {}
        aAreaSe1 := SE1->(GetArea())
        aAreaSe5 := SE5->(GetArea())
        aAreaFK1 := FK1->(GetArea())				
        aAreaaUX := GetArea() 	


        For nX := 1 To 60
            aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
        Next nX

            Pergunte("FIN74A",.F.)
            MV_PAR01 := 0
            MV_PAR06 := 2
            MV_PAR07 := 1
            MV_PAR08 := 2         
            aRecSfr :={}
            l070Err:=.F.
            Fa074GDif(.F./*lMutiplo*/,/*aCorrecoes*/,/*lMarcados*/,.T./*lExterno*/,/*nMoedaCor*/,/*nTxaAtual*/,/*nMoedaTit*/,/*aBStExpPrm*/,@aRecSfr)
            lRet:= !l070Err

        For nX := 1 To Len( aMvPar )
            &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
        Next nX				

        SE1->(RestArea(aAreaSe1))
        SE5->(RestArea(aAreaSe5))
        FK1->(RestArea(aAreaFK1))
        RestArea(aAreaaUX)
        RestInter() //Restore status of private and public variables				
        RU06XFUN2J(aprvt)//Load saved private variables FINA070
    ENDIF
Return lRet

/*/{Protheus.doc} RU06XFUN1J_ChekAccPos
Function responsible for checking if the post in account will happen
@type Function          
@author eduardo.Flima
@since  18/03/2022
@version version 
@param  nOriRec, Numeric, recno of the FK1 before the posting
@return lDigita, Logical, If it will be psted in account
@see  FI-AP-15-17
/*/
FUNCTION RU06XFUN1J_ChekAccPos(nOriRec)
    Local lDigita as Logical

    lDigita:=.F.

    nOriRec:= FK1->(Recno())
    If nRuDig <> 0 
        lDigita := nRuDig==1
    Else
        lDigita := Iif(mv_par01==1,.T.,.F.)
    Endif
Return lDigita

/*/{Protheus.doc} RU06XFUN1K_ChkErr
Function responsible for abort the proccess if some problem has happenes in account post.
@type Function           
@author eduardo.Flima
@since  18/032022
@version version
@param nOriRec, Numeric, recno of the FK1 before the posting
@see  FI-AP-15-17
/*/
FUNCTION RU06XFUN1K_ChkErr(nOriRec,cTable,cNamHelp,cTitHelp,cMsgHelp)
    Default cTable := "FK1"
    Default cNamHelp := "F070CONT"
    Default cTitHelp := STR0105 //Posting Problem,
    Default cMsgHelp := STR0106  //Check the posting settings for receivable write-off  
    (cTable)->(DbGoTo(nOriRec))
    If nOriRec != (cTable)->(Recno())
        Help( ,, cNamHelp,, cTitHelp , 1, 0,,,,,, {cMsgHelp} ) 
        If (Type('lPrbPost')=="L")
            lPrbPost:=.T.				
        ENDIF
    Endif
Return 

/*/{Protheus.doc} RU06XFUN1L_SetForeignValues
Function responsible for set the values in foreingn currencies for canceling process.
@type Function           
@author  eduardo.Flima
@since   18/03/2022
@version version
@param  nValorM2, Numeric, value  foreing currency
@param  nValSE5 , Numeric, value in national currency
@see  FI-AP-15-17
/*/
FUNCTION RU06XFUN1L_SetForeignValues(nValorM2,nValSE5)
    If Alltrim(SE5->E5_MOEDA) != "01" .AND. SE1->E1_CONUNI != "1"
        nValorM2 := SE5->E5_VALOR
        nValSE5 := SE5->E5_VLMOED2
    ELSE
        nValSE5 := SE5->E5_VALOR
        nValorM2:= SE5->E5_VLMOED2
    ENDIF

Return 

/*/{Protheus.doc} RU06XFUN1M_CanExrat
Function responsible for preparation and generation of CANCELING exchange rate in write-off FINA070
@type Function           
@author eduardo.Flima
@since  22/03/2022
@version veresion 
@param dBaixa, Date, Date of the write-off
@see  FI-AP-15-17
/*/
FUNCTION RU06XFUN1M_CanExrat(dBaixa)
    Local cKey			as Character 
    LOCAL nx			as Numeric
    Local aPrvt			as Array
    Local aAreaSE1		as Array
    Local aMvPar		as Array
    LOCAL aAreaSE5		as Array
    Local aAreaFK1		as Array
    Local aAreaaUX		as Array

    cKey     :=  SE1->E1_FILIAL+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA
    nx		 :=  0
    aPrvt	 :=  {}    
    aAreaSE1 :=  {}
    aMvPar	 :=  {}
    aAreaSE5 :=  {}
    aAreaFK1 :=  {}
    aAreaaUX :=  {} 
    
    If !FwIsInCallStack("RU06D0735_CancelExRates") .AND. RU06D07050(dBaixa, cKey) == 1
        SaveInter() //Salva status das variaveis private e public
        aprvt:=RU06XFUN2H()//Save private variables FINA070
        
        aMvPar := {}
        aAreaSe1 := SE1->(GetArea())
        aAreaSe5 := SE5->(GetArea())
        aAreaFK1 := FK1->(GetArea())				
        aAreaaUX := GetArea() 	


        For nX := 1 To 60
            aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
        Next nX

        Pergunte("FIN74A",.F.)
        MV_PAR01 := 0
        MV_PAR06 := 2
        MV_PAR07 := 1
        MV_PAR08 := 2         

        RU06D0735_(dBaixa,"SE1",.F.)
        RU06XFUN88(RU06D07049(cKey),dBaixa,"1")


        For nX := 1 To Len( aMvPar )
            &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
        Next nX				

        SE1->(RestArea(aAreaSe1))
        SE5->(RestArea(aAreaSe5))
        FK1->(RestArea(aAreaFK1))
        RestArea(aAreaaUX)
        RestInter() //Restaura status das variaveis private e public				
        RU06XFUN2J(aprvt)//Load saved private variables FINA070
    Endif
Return 

/*/{Protheus.doc} RU06XFUN1N_SetTxMoed
Function responsible for set the tax rate in  the recalculation function used in FINA070
@type Function           
@author eduardo.Flima
@since  22/03/2022
@version version 
@param  nTxMoeda,   Numeric,  Tax rate of the currency of the proccess
@param  nTxMdaOr,   Numeric,  Tax rate of the currency of the bill
@param  aTxMAux ,   Array  ,  Array with tax currencyes
@see  FI-AP-15-17
/*/
FUNCTION RU06XFUN1N_SetTxMoed(nTxMoeda,nTxMdaOr,aTxMAux,aBStExpPrm)
    DEFAULT nTxMoeda      :=0
    DEFAULT nTxMdaOr      :=0
    DEFAULT aTxMAux       :={}
    DEFAULT aBStExpPrm    :={}  
    
    If Empty(aTxMAux)
        If type('aTxMoedas') == "A"
            aTxMAux:=aTxMoedas
        Endif
    Endif
    

    If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
        nTxMoeda:= SE1->E1_TXMOEDA	
        nTxMdaOr := SE1->E1_TXMOEDA	
    Else
        If !Empty(aBStExpPrm)
			nTxMoeda:= aTxMoedas[oModelVrt:GetValue("B_CURREN")][2]
			nTxMoeda:= aTxMoedas[oModelVrt:GetValue("B_CURREN")][2]
        Else
            nTxMoeda := aTxMAux[SE1->E1_MOEDA][2]
            nTxMdaOr := aTxMAux[SE1->E1_MOEDA][2]
        Endif
    Endif
Return 

/*/{Protheus.doc} RU06XFUN1O_SetFilterFINA074
Function responsible for set Special Filter in FINA074 grid related to table FIE and if it will filter not showing Currency 1 bills 
@type Function
@author eduardo.Flima
@since  22/03/2022
@version version           
@param  nParFil, Numeric,   Parameter if we will filter currency 1 bills 1-Yes; 2-No
@param  lFARREV, Logical,   Parameter if we will filter by parameter MV_FARREV
@param  lAnd   , Logical,   Parameter if we will add AND before the sql string used when this is a part of a bigger sql clausule
@param  cPrefix, Character, If we willl name the subquery when part of a a bigger sql clausule               
@return cFilQry, Character, Filter in SQL format
@see  FI-AP-15-17
/*/
FUNCTION RU06XFUN1O_SetFilterFINA074(nParFil,lFARREV,lAnd,cPrefix)
    Local cFilQry as Character
    Local aNoRvl as array 
    Local ni as Numeric

	
    DEFAULT nParFil	:= 2 
	DEFAULT lFARREV	:=.F.
	DEFAULT	lAnd	:=.F.	
	DEFAULT	cPrefix	:=""

    cFilQry:=" "
	
	If lAnd
		cFilQry += " AND "
	Endif
	
	If !empty(cPrefix)
		cFilQry +=	cPrefix+"."
	Endif
    cFilQry += "R_E_C_N_O_ NOT IN ("
    cFilQry += "           SELECT SE1FIL.R_E_C_N_O_ "
    cFilQry += "           FROM " + RetSqlName("SE1") + " SE1FIL "
    cFilQry += "           WHERE "
    cFilQry += "                 SE1FIL.E1_TIPO = 'RA' OR "
    cFilQry += "                 SE1FIL.R_E_C_N_O_ IN ( SELECT SE1JOIN.R_E_C_N_O_ FROM " + RetSqlName("SE1") + " SE1JOIN JOIN " + RetSqlName("FIE") + " FIE ON "
    cFilQry += "                                  FIE.FIE_CART = 'R' AND "
    cFilQry += "                                  FIE.FIE_PREFIX = SE1JOIN.E1_PREFIXO AND "
    cFilQry += "                                  FIE.FIE_PARCEL = 	SE1JOIN.E1_PARCELA AND "
    cFilQry += "                                  FIE.FIE_NUM = SE1JOIN.E1_NUM AND "
    cFilQry += "                                  FIE.FIE_TIPO = SE1JOIN.E1_TIPO AND "
    cFilQry += "                                  FIE.FIE_CLIENT = SE1JOIN.E1_CLIENTE AND "
    cFilQry += "                                  FIE.FIE_LOJA = SE1JOIN.E1_LOJA AND"
    cFilQry += "                                  FIE.D_E_L_E_T_ = ' ' "
    cFilQry += "                                  ) "
    cFilQry += " ) "
    If nParFil == 1
        cFilQry+= " AND (E1_MOEDA <> 1 OR E1_ORIGEM = 'FINA074') "
    Endif

    If lFARREV
		aNoRvl := SEPARA ( SuperGetMV( "MV_FARREV" , .F. /*lHelp*/, "RA" /*cPadrao*/), ";" )
		For ni := 1 to Len(aNoRvl)
			cFilQry += "   AND E1_TIPO   <> '"+aNoRvl[ni]+"'"
		Next		
	Endif
Return cFilQry


/*/{Protheus.doc} RU06XFUN1P_VldFARREV
Function responsible for validate the type of bills that can`t be writen-off acording to the parameter  MV_FARREV
@type Function           
@author  eduardo.Flima
@since 22/03/2022
@version version
@param cHelp    , Character,  Message to be showed in help problem
@param cSolution, Character,  Message to be showed in help solution      
@return lReturn,  Logical,    If it is the type can be calculated.
@see  FI-AP-15-17
/*/
FUNCTION RU06XFUN1P_VldFARREV(cHelp,cSolution)
    Local lRet      as Logical
    Local aMvFarrev as Array

    DEFAULT cHelp       :=""
    DEFAULT cSolution   :=""

    aMvFarrev		:= {}
    lRet:=.T.
	aMvFarrev := SEPARA ( SuperGetMV( "MV_FARREV" , .F. /*lHelp*/, "RA" /*cPadrao*/), ";" )
	If ASCAN(aMvFarrev,{ | x | PADR(LTRIM(x), 3, " ") == SE1->E1_TIPO })
		Help(NIL, NIL, "FA074018", NIL, cHelp, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolution})
		lRet:=.F.
	EndIf
Return lRet

/*/{Protheus.doc} RU06XFUN1Q_VldRAorFIE
Function responsible for validate the type of bills that can`t be writen-off and if it is locked in table FIE
@type Function          
@author eduardo.Flima
@since  22/03/2022
@version version
@param  lHelp  , Logical  ,  If it will show help when the bill is not valid
@param  cHelp  , Character,  Message to be showed in help       
@return lReturn, Logical  ,  If this bill can be calculated.
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN1Q_VldRAorFIE(lHelp,cHelp)
    Local aAresFIE  as Array
    Local lRet      as Logical

    DEFAULT lHelp :=.F.
    DEFAULT cHelp :=""
    lRet:=.T.
	aAresFIE := FIE->(GetArea())
	DbSelectArea("FIE")
	FIE->(DBSetOrder(2))	// FIE_FILIAL+FIE_CART+FIE_CLIENT+FIE_LOJA+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO+FIE_PEDIDO
	If SE1->E1_TIPO == "RA" .Or. (FIE->(DBSeek(xFilial("FIE") + "R" + SE1->E1_CLIENTE + SE1->E1_LOJA + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)))
        If lHelp 
            Help(NIL, NIL, "RUF07401", NIL, cHelp, 1, 0, NIL, NIL, NIL, NIL, NIL,)
        ENDIF
        lRet :=.F.
	EndIf
	RestArea(aAresFIE)
Return lRet

/*/{Protheus.doc} RU06XFUN1R_PrepareRuRvl
Function to prepare the revaluation in russian localizations and stop the proccess if lock problems occur
@type Function
@author  eduardo.Flima
@since   22/03/2022
@version version
@param   nTaxaAtu  , Numeric,  Tax rate  of the operation
@param   aSE1Locked, Array  ,  Array with the records locked 
@param   aTxMoedas , Array  ,  Array with tax currencyes       
@return  lReturn   , Logical,  If the proccess can continuue.
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN1R_PrepareRuRvl(nTaxaAtu,aSE1Locked,aTxMoedas)
    Local lRet as Logical

    DEFAULT nTaxaAtu    :=RecMoeda(dDataBase,SE1->E1_MOEDA)
    DEFAULT aSE1Locked  :={}

    lRet:=.T.

    If SE1->E1_CONUNI=='1'
        nTaxaAtu:=aTxMoedas[SE1->E1_MOEDA][2]
    EndIF
    aSE1Locked := SE1->(DBRLockList())
    If !RU06XFUN93({SE1->(RecNo())},"SE1") //try to lock SE1 record
        lRet:=.F. //SE1 record was not locked
    EndIf
Return lRet

/*/{Protheus.doc} RU06XFUN1S_SetRusCorrec
Function to check if it is necessary to add rebuilds in revaluation consideration and to stop the process if some lock problem happen 
@type Function           
@author  eduardo.Flima
@since   22/03/2022
@version version
@param   aRecSEx        , Array         ,  Array with the records to be revaluated 
@param   aSEXLocked     , Array         ,  Array with the records locked 
@param   aCorrecoes     , Array         ,  Array revaluations already calculated 
@param   lExterno       , Logical       ,  If the proccess is called external of FINA074
@param   nRebuildCorr   , Numeric       ,  Rebuild Corrections -1-Not applicable 2-Manual Only 3-Always
@param   cTable         , Character    ,  Table we are dealing 
@return  lReturn        , Logical,  If the proccess can continuue.
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN1S_SetRusCorrec(aRecSEx,aSEXLocked,aCorrecoes,lExterno,nRebuildCorr,cTable,lLockSEX)
    Local lRet          as Logical
    Local aRusCorrec    as Array

    DEFAULT lExterno :=.F.
    Default cTable   :="SE1"
    DEFAULT lLockSEX := .T.

    lRet        :=.T.
    aRusCorrec  :={}

    If lLockSEX .AND. ((lExterno .AND. nRebuildCorr == 3) .OR. (!lExterno .AND. nRebuildCorr > 1))
        aRusCorrec := RU06XFUN90(RU06XFUN89(aRecSEx,dDataBase,cTable),dDataBase,cTable)
        If !Empty(aRusCorrec) .AND. ValType(aRusCorrec[1]) == "N" .AND. aRusCorrec[1] == -1
            lRet:=.F.
        Else
            //change aCorrecoes
            If !Empty(aRusCorrec)
                RU06XFUN92(@aRusCorrec,@aCorrecoes,@aRecSEx)
            EndIf
        EndIf
    EndIf

    RU06XFUN94(@aRecSEx,@aSEXLocked,cTable) //unlock SEX records
Return lRet


/*/{Protheus.doc} RU06XFUN1T_ADDRUSSTRU
Function to ADD specific fields for localization russia in the structure of the TMP table
@type Function          
@author eduardo.Flima
@since  22/03/2022
@version version 
@param  aStruTrb,  Array,   Array with the fields of the temporary table  
@return aStruTrb,  Array,   Array with the fields of the temporary table
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN1T_ADDRUSSTRU(aStruTrb AS Array,cTable AS character)
    default cTable := "SE1"
    If cTable == "SE1"
	    aadd(aStruTrb,{"E1_RECIBO"		,"C",TamSx3("E1_RECIBO" )[1],TamSx3("E1_RECIBO" )[2]})
    else
		aadd(aStruTrb,{"E2_ORDPAGO"	    ,"C",TamSx3("E2_ORDPAGO")[1],TamSx3("E2_ORDPAGO")[2]})
    Endif 
	aadd(aStruTrb,{"TRB_RBDBAL","C",TamSx3("FR_RBDBAL" )[1] ,TamSx3("FR_RBDBAL" )[2] })
	aadd(aStruTrb,{"TRB_DTFIX" ,"D",TamSx3("FR_DTFIX" )[1]  ,TamSx3("FR_DTFIX" )[2]  })
	aadd(aStruTrb,{"TRB_IDWTFF","C",TamSx3("FR_IDWTOFF" )[1],TamSx3("FR_IDWTOFF" )[2]})
Return aStruTrb

/*/{Protheus.doc} RU06XFUN1U_SetCorBal
Function responsilbe to persist the data of the revaluations in the temporary table that will be the origin of the revaluation it is already prepared to work with rebilds
@type Function          
@author eduardo.Flima
@since  22/03/2022
@version version
@param aCorrecoes,  Array  ,  Array with the data of the revaluations  
@param lMultiplo ,  Logical,  If it is several revaluations  
@param lMarcados ,  Logical,  If it is selected for revaluation  
@param nTotAjuste,  Numeric,  Total value of the revaluation to be considered  
@param aOldSFRRUS,  Array  ,  Array with the SFR recnos ot be flagged in rebild cases
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN1U_SetCorBal(aCorrecoes,lMultiplo,lMarcados,nTotAjuste,aOldSFRRUS,cTable)
    Local nX    as Numeric
    Local aBox  as Array
    Local cAlias as Chacacter
    Local cClifor as Chacacter
    Local cTpNeg as Character

    Default cTable := "SE1"

    cAlias := right(cTable,len(cTable)-1)
    aBox    := {}
    nX      := 0
    cClifor := iif(cTable == "SE1","_CLIENTE","_FORNECE")
    cTpNeg :=  iif(cTable == "SE1",MVRECANT+"/"+MV_CRNEG, MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM  )
    For nX := 1 To Len(aCorrecoes[_SALDO])
        If aCorrecoes[_SALDO][nX][1] <> 0 .OR.aCorrecoes[_SALDO][nX][6] =='3' 
            (cTable)->(MsGoTo(aCorrecoes[_RECSEx]))
            Reclock('TRB',.T.)
            RU06XFUNBG(cAlias,cTable,cClifor)           //  E1_CLIENTE OR E2_FORNECE
            RU06XFUNBG(cAlias,cTable,'_LOJA')           //  EX_LOJA
            RU06XFUNBG(cAlias,cTable,'_PREFIXO')        //  EX_PREFIXO 
            RU06XFUNBG(cAlias,cTable,'_NUM')            //  EX_NUM
            RU06XFUNBG(cAlias,cTable,'_PARCELA')        //  EX_PARCELA
            RU06XFUNBG(cAlias,cTable,'_TIPO')           //  EX_TIPO
            RU06XFUNBG(cAlias,cTable,'_EMISSAO')        //  EX_EMISSAO
            Replace TRB_ORIGEM With _AZUL
            Replace TRB_VALDIF With aCorrecoes[_SALDO][nX][1]
            Replace TRB_VALOR1 With aCorrecoes[_SALDO][nX][2]*aCorrecoes[_SALDO][nX][4]
            Replace TRB_VALCOR With aCorrecoes[_SALDO][nX][2]*aCorrecoes[_SALDO][nX][3]
            Replace TRB_TXATU  With aCorrecoes[_SALDO][nX][3]
            Replace TRB_TXORI  With aCorrecoes[_SALDO][nX][4]
            Replace TRB_DTAJUS With dDataBase
            Replace TRB_TIPODI With "S"
            Replace TRB_RBDBAL  With aCorrecoes[_SALDO][nX][6]
            SX3->(DbSeek("FR_RBDBAL"))
            aBox:=RetSx3Box(AllTrim(X3CBox()),,,1)
            Replace TRB_DRBDBL With ABOX[Ascan(aBox,{|x| x[2]==aCorrecoes[_SALDO][nX][6]})][3]
            Replace TRB_IDWTFF  With aCorrecoes[_SALDO][nX][7]
            If lMultiplo
                TRB_MARCA	:=	IIf(lMarcados,_MARCADO,_DESMARCADO)
            Endif
            MsUnLock()
            If !lMultiplo .Or. (lMultiplo .And. lMarcados)             
                If &("TRB->"+cAlias+"_TIPO")$ cTpNeg //if EX_TIPO is type negative
                    nTotAjuste	-=	TRB_VALDIF 
                Else
                    nTotAjuste	+=	TRB_VALDIF
                EndIf
            EndIf
            If aCorrecoes[_SALDO][nX][5] <> 0
                AADD(aOldSFRRUS, {aCorrecoes[_SALDO][nX][5], dDataBASE, ' '})
                If aCorrecoes[_SALDO][nX][6] == '3'
                    aOldSFRRUS[Len(aOldSFRRUS)][3] := '2'
                EndIf
            EndIf	
        Endif
    Next nX
Return 

/*/{Protheus.doc} RU06XFUN1V_CalcAsaldo
Function responsilbe for the calculation of aSaldo and to add it according to the rebuild process if necessary.
@type Function
@author  eduardo.Flima
@since   22/03/2022
@version version          
@param  aSaldo    ,  Array  ,  Array with the data of the revaluations to be changed 
@param  nSaldo    ,  Numeric,  Total balance 
@param  nSaldoAt  ,  Numeric,  value calculated of the revaluation
@param  nTxMdaOr  ,  Numeric,  Tax rate of the operation
@param  aTxMoedas ,  Array  ,  Array with tax currencyes       
@param  aBStExpPrm,  Array  ,  Array with values filled in Bank statement process
@return aSaldo    ,  Array  ,  Array with the data of exchange rate recalculations
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN1V_CalcAsaldo(aSaldo,nSaldo,nSaldoAt,nTxMda,aTxMoedas,aBStExpPrm)
    Local cFR_CHAVOR    as Character
    Local aTmp          as Array
    Local aRevalList    as Array
    Local lRet          as Logical
    Local lRvlListFl    as Logical    

    DEFAULT nSaldo     := 0  
    DEFAULT nTxMda     := 0  
    DEFAULT aSaldo     := {}
    DEFAULT aTxMoedas  := {}
    Default aBStExpPrm := {} 


    cFR_CHAVOR  :=""
    aTmp        :={}
    aRevalList  :={}
    lRet        :=.F.
    lRvlListFl  :=.F.

    If FwIsInCallStack("FA070TIT")
        cFR_CHAVOR  :=PADR(SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO,GetSX3Cache("FR_CHAVOR","X3_TAMANHO")," ")
		aTmp	    :=RU06XFUN88(cFR_CHAVOR,dDataBase,"1")
        aRevalList := aTmp[1]
        lRet       := aTmp[2]
		If lRet
		    lRvlListFl := IIF(!Empty(aRevalList), .T., .F.) .OR. (RU06XFUN1A(cFR_CHAVOR,dDataBase,"1"))
            If !lRvlListFl .AND. IIF(SE1->E1_CONUNI=="1",SE1->E1_SALDO == nValEstrang,SE1->E1_SALDO == NVALREC )            
                nTxAtu:=  aTxMoedas[SE1->E1_MOEDA][2]
                aTmp := RU06XFUN86(SE1->E1_FILIAL+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA,"SE1")
                If SE1->E1_CONUNI == "1"
                    nSaldoAt := ((aTmp[3] + xMoeda(nValEstrang,SE1->E1_MOEDA,,dDataBase,,nTxAtu,aTxMoedas[SE1->E1_MOEDA][2])) - aTmp[2]) - SE1->E1_VLCRUZ
                Else
                    nSaldoAt := ((aTmp[1]+xMoeda(nValRec,SE1->E1_MOEDA,,dDataBase,,nTxAtu,aTxMoedas[SE1->E1_MOEDA][2])) - aTmp[2]) - SE1->E1_VLCRUZ
                Endif
            Endif		
        else
            Help(NIL, NIL, "FA07SFR", NIL, STR0107, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0108}) //"Problem locking record in SFR"  "Problem in exchange rate calculation"
            DisarmTransaction()
        Endif
    ENDIF
	If  !Empty(aBStExpPrm) .AND. !Empty(aBStExpPrm[1][2]) // check we are in Russian BS process
        If SE1->E1_SALDO == F5M->F5M_VALPAY .AND. !aBStExpPrm[5][2] // revaluation list is empty
            aTmp := RU06XFUN86(SE1->E1_FILIAL+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA,"SE1")
            If SE1->E1_CONUNI == "1"
                nSaldoAt := ((aTmp[3] + F5M->F5M_VALCNV) - aTmp[2]) - SE1->E1_VLCRUZ
            Else
                nSaldoAt := ((aTmp[1]+xmoeda(F5M->F5M_VALPAY,SE1->E1_MOEDA,1,ddatabase)) - aTmp[2]) - SE1->E1_VLCRUZ
            Endif
        EndIf
    EndIf
	AADD(aSaldo, {nSaldoAt,nSaldo,aTxMoedas[SE1->E1_MOEDA][2],nTxMda,0 /*origsfrrecno*/,'0'/*newsfrrbdbal*/,' ' /*sfridwtoff*/})
Return  aSaldo

/*/{Protheus.doc} RU06XFUN1X_F074GetTx
Function responsible initialize the variables of F074GetTx for russian localization.
@type Function           
@author  eduardo.Flima
@since   18/03/2022
@version version
@param dUltDif, Date   , Date of the last revaluation
@param nTaxa  , Numeric, Rate of the last revaluation
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN1X_F074GetTx(dUltDif,nTaxa)
	dUltDif:=SE1->E1_EMISSAO
	nTaxa	:= RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)
Return

/*/{Protheus.doc} RU06XFUN1Y_Set_aGerar
Function responsilbe for setting the array aGerar according to localization Russian business logic.
@type Function          
@author  eduardo.Flima
@since   22/03/2022
@version version
@param   aGerar, Array, Array with the data of the revaluations 
@return  aGerar, Array, Array with the data of the revaluations
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN1Y_Set_aGerar(aGerar as array ,cTable as Character)
    Local cExKey    as Character
    Local cNatGer   as Character
    Local c5qCdGer  as Character
    Local c5qidGer  as Character
    Local aArea     As Array
    Local cAlias    as Character

    Default cTable :="SE1"

    cAlias := right(cTable,len(cTable)-1)
    aArea  := GetArea()

    cExKey:= &("TRB->"+cAlias+"_PREFIXO")+&("TRB->"+cAlias+"_NUM")+&("TRB->"+cAlias+"_PARCELA")+&("TRB->"+cAlias+"_TIPO") //EX_FILIAL+EX_PREFIXO+EX_NUM+EX_PARCELA+EX_TIPO
    (cTable)->(DbSetOrder(1))
    If  (cTable)->(DbSeek(xFilial(cTable)+cExKey))
        cNatGer		 := &(cTable+"->"+cAlias+"_NATUREZ")
        c5qCdGer	 := &(cTable+"->"+cAlias+"_F5QCODE")
        c5qidGer	 := &(cTable+"->"+cAlias+"_F5QUID")				
    Endif
    If cTable == "SE1"
        AAdd(aGerar,{{TRB->(Recno())},'',Iif(TRB->E1_TIPO$ MVRECANT+"/"+MV_CRNEG,(TRB->TRB_VALDIF*-1),TRB->TRB_VALDIF),TRB->TRB_DTAJUS,TRB->E1_CLIENTE,TRB->E1_LOJA,"/"+TRB->E1_PREFIXO+TRB->E1_NUM+"/"+iIF(empty(TRB->E1_RECIBO),"Seq:"+TRB->E5_SEQ," RC:"+TRB->E1_RECIBO),cNatGer,c5qCdGer,c5qidGer})
    Else
        AAdd(aGerar,{{TRB->(Recno())},'',Iif(TRB->E2_TIPO$ MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM,(TRB->TRB_VALDIF*-1),TRB->TRB_VALDIF),TRB->TRB_DTAJUS,TRB->E2_FORNECE,TRB->E2_LOJA,TRB->E2_PREFIXO+TRB->E2_NUM+iIF(empty(TRB->E2_ORDPAGO),"Seq:"+TRB->E5_SEQ," OP:"+TRB->E2_ORDPAGO),cNatGer,c5qCdGer,c5qidGer})
    Endif 

    RestArea(aArea)
Return aGerar

/*/{Protheus.doc} RU06XFUN1Z_Set_aGerar
Function responsilbe validate the fiiling of the class according to the parameters and fill class and legal contract informations when it is applyable.
@type Function           
@author eduardo.Flima
@since  22/03/2022
@version version
@param  cNatOrig ,  Character,  content of the parameter Class 
@param  nSepara  ,  Numeric  ,  content of the parameter if it is splited by class or not 
@param  aGerarNx ,  Array    ,  Array with the data to be revaluated
@param  cNatureza,  Character,  content of the class that will be used if valid 
@param  c5qCode  ,  Character,  content of the legal contract code that will be used if valid 
@param  c5quid   ,  Character,  content of the legal contract uuid that will be used if valid
@return lRet     ,  Logical  ,  If it is valid according to the parameter filled in
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN1Z_Set_aGerar(cNatOrig,nSepara,aGerarNx,cNatureza,c5qCode,c5quid)
    Local lRet      AS Logical
    Local cE1Key    AS Character

    DEFAULT cNatOrig   := "" 
    DEFAULT nSepara    := 0  
    DEFAULT aGerarNx   := {}
    DEFAULT cNatureza  := ""
    DEFAULT c5qCode    := ""
    DEFAULT c5quid     := ""

    lRet    :=.T.
    cE1Key  :=""

    If Empty(cNatOrig)
		If nSepara == 1
			SA1->(DbSetOrder(1))
			If  SA1->(DbSeek(xFilial('SA1')+aGerarNx[5]+aGerarNx[6]))
				cNatureza:= SA1->A1_NATUREZ
			Endif
			If Empty(cNatureza)
				Help(NIL, NIL, "FA074016", NIL, STR0109 + " "+aGerarNx[5]+"/" +aGerarNx[6]+ STR0110, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0111})
				lRet :=.F.
			Endif
		elseif nSepara == 2
			cE1Key:= LEFT(aGerarNx[2],len(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
			SE1->(DbSetOrder(1))
			If  SE1->(DbSeek(xFilial('SE1')+cE1Key))
				cNatureza:= SE1->E1_NATUREZ
				c5qCode	 := SE1->E1_F5QCODE
				c5quid	 := SE1->E1_F5QUID				
			Endif
			If Empty(cNatureza)
				Help(NIL, NIL, "FA074017", NIL, STR0112  + cE1Key + STR0110, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0113})
				lRet :=.F.
			Endif
		elseif nSepara == 3
			cNatureza:= aGerarNx[8]
			c5qCode	 := aGerarNx[9]
			c5quid	 := aGerarNx[10]				
			If Empty(cNatureza)
				Help(NIL, NIL, "FA074017", NIL, STR0112 + aGerarNx[7] + STR0110, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0113})
				lRet :=.F.
			Endif
		Endif
    Endif
Return lRet

/*/{Protheus.doc} RU06XFUN2A_AddLegCntAtit
Function responsilbe add the Legal contract Informations and initialize variable lPrbPost.
@type Function           
@author eduardo.Flima
@since  22/03/2022
@version version
@param aTitulo,  Array    , Array with the data of the Bill
@param c5qCode,  Character, content of the legal contract code that will be used if valid 
@param c5quid ,  Character, content of the legal contract uuid that will be used if valid
@return aTitulo, Logical,   Array with the data of the Bill
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN2A_AddLegCntAtit(aTitulo,c5qCode,c5quid)
    DEFAULT aTitulo    := {}
    DEFAULT c5qCode    := ""
    DEFAULT c5quid     := ""

    AADD(aTitulo,{"E1_F5QCODE"		, c5qCode	,Nil})
    AADD(aTitulo,{"E1_F5QUID"		, c5quid	,Nil})
    lPrbPost :=.F.

Return aTitulo

/*/{Protheus.doc} RU06XFUN2B_AutoOperationsBS_EXCHANGErATE
Function responsilbe for performing the bill add and write-off operations in exchange rate acording to BS parameters.
@type Function          
@author eduardo.Flima
@since  22/03/2022
@version version
@param aTitulo   ,  Array  , Array with the data of the Bill
@param aBStExpPrm,  Array  , Array with values filled in Bank statement process
@param nOper     ,  Numeric, if it is the operation 1- RECEIVABLES inclusion or 2-Write-off
@see  FI-AP-15-17
/*/
FUNCTION RU06XFUN2B_AutoOperationsBS_EXCHANGErATE(aTitulo,aBStExpPrm,nOper)
    Local nCont     as Numeric
    Local nDigCont  as Numeric
    
    DEFAULT nOper := 1 
    nCont    := 0
    nDigCont := 0
    
    If !empty(aBStExpPrm[7])
        nCont:=aBStExpPrm[7][2]
    Endif
    If !empty(aBStExpPrm[8])
        nDigCont:=aBStExpPrm[8][2]
    Endif
    If nOper == 1
        MSExecAuto({|w,x,y,z| FinA040(w,x, , , , , , , , ,,y,z)},aTitulo,3,nCont,nDigCont)
    elseIf nOper == 2
        MSExecAuto({|w,x,y,z| FinA070(w,x, , ,  , , , ,, , , ,,y,z)},aTitulo,3,nCont,nDigCont)    
    Endif
Return

/*/{Protheus.doc} RU06XFUN2C_DisarmExchangeRate
Function responsilbe for disable all the operations of the exchange rate.
@type Function          
@author eduardo.Flima
@since  22/03/2022
@version version
@param aBStExpPrm, Array, array with values filled in Bank statement process
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN2C_DisarmExchangeRate(aBStExpPrm)
    DEFAULT aBStExpPrm :={}
    iF TYPE("lPrbPost") == "U"
        lPrbPost :=.f.
    Endif 

    DisarmTransaction()
    If FwIsInCallStack("Fa074GDif") 
        If lPrbPost 
            Help( ,, "F074CONT",, STR0105 , 1, 0,,,,,, {STR0106} ) //Posting Problem, "Check the posting settings for receivable write-off"
        else
            Help(NIL, NIL, "F074PRBL", NIL, STR0108, 1, 0, NIL, NIL, NIL, NIL, NIL) // "Problem in exchange rate calculation"
        Endif
            
    Endif
    iF !Empty(aBStExpPrm) .AND. !Empty(aBStExpPrm[6])
        aBStExpPrm[6][2] = .T.
	elseif FwIsInCallStack("FA070TIT")
		l070Err:=.T.
	Endif 
Return 

/*/{Protheus.doc} RU06XFUN2B_AutoOperationsBS_EXCHANGErATE
Function responsilbe for setting SFR as rebuilded.
@type  function      
@author eduardo.Flima
@since  22/03/2022
@version version
@param aOldSFRRUS, Arrayu, array with the SFR recnos ot be flagged in rebild cases            
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN2D_SetRebuildSFrasFixed(aOldSFRRUS as Array,lErrorExt as Logical, cTable as Character)
    Local 	aArea   as Array
    Local   nX      as Numeric
    Local   aSEx    as Array
    Local   lRet    as Logical
    Local   cAlias  as Chacacter

    Default lErrorExt   :=.F.
    Default cTable      :="SE1"

    nX      :=0
    aSEx    :={}
	aArea   := GetArea()
    lRet    :=.T.
    cAlias := right(cTable,len(cTable)-1)

    If lErrorExt
        lRet    :=.F.
    Else
        For nX := 1 To Len(aOldSFRRUS)
            SFR->(DBGoTo(aOldSFRRUS[nX][1]))
            RecLock("SFR", .F.)
                SFR->FR_DTFIX  := aOldSFRRUS[nX][2]
                SFR->FR_RBDBAL := aOldSFRRUS[nX][3]
            SFR->(MSUnlock())
            aSEx:= (cTable)->(GetArea())
                (cTable)->(DbSetOrder(1))
                If (cTable)->(DbSeek(xFilial(cTable)+SFR->FR_CHAVOR))
                    RecLock(cTable,.F.)
                        Replace &(CALIAS+"_DTDIFCA") With dDataBase//Necessary to reasing the date value to ensure in cases when there is no difference but is necessary to fix rebuild status 
                    MsUnLock()
                EndIf
            RestArea(aSEx)
        Next nX
    Endif
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} RU06XFUN2E_SetRebuildID
Function responsilbe for record the fields related to rebuild in SFR.
@type function 
@author eduardo.Flima
@since  22/03/2022
@version version
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN2E_SetRebuildID()
    Replace FR_IDWTOFF WITH TRB->TRB_IDWTFF
    Replace FR_RBDBAL  WITH TRB->TRB_RBDBAL
Return 

/*/{Protheus.doc} RU06XFUN2F_FillAcontrols
Function responsilbe for store the informations of the exchange rate generated.
@type function
@author eduardo.Flima
@since  22/03/2022
@version version
@param  aBStExpPrm, Array,  Array with values filled in Bank statement process
@param  aRecSfr,    Array,  Array with the recno of SFR generated in the process           
@see FI-AP-15-17
/*/
FUNCTION RU06XFUN2F_FillAcontrols(aBStExpPrm,aRecSfr)
    If !Empty(aBStExpPrm)
        AADD(aBStExpPrm[3][2],SFR->(Recno())) 
    ELSE
        AADD(aRecSfr,SFR->(Recno())) 
    EndIf
Return 

/*/{Protheus.doc} RU06XFUN2G_SetMoedBco
Function responsilbe for return the currency that should be used in the operation.
@type  Function
@author eduardo.Flima
@since 22/03/2022
@version version
@param cConUni, Character, Conventional Units                                         
@return nMoedaBco, Numeric, Currency of the operation
@see  FI-AP-15-17
/*/
FUNCTION RU06XFUN2G_SetMoedBco(cConUNi)
    Local nMoedaBco as Numeric
	IF cConUNi == '1'
		nMoedaBco   :=1
	else
		nMoedaBco   :=SE1->E1_MOEDA
	EndIf
Return nMoedaBco

/*/{Protheus.doc} RU06XFUN2I_NewGetSx3Cache
Function responsilbe for return the description of SX3 fields in the current idiom of the system .
@type Static Function
@author eduardo.Flima
@since  12/05/2022
@version version
@param cField, Character, The field which we will retrieve the information  
@param cRet,   Numeric  , Which information from the X3 will we retrieve
                        1 - TITLE
                        2 - COMBOBOX OPTIONS          
@return cRet,  Character, Information from X3 in the current idiom of the system
@see  FI-AP-15-17
/*/
Static Function RU06XFUN2I_NewGetSx3Cache(cField,nType)
    Local cRet      as Character
    Local aAreaSx3  as Array

    cRet:=""
    aAreaSx3 := SX3->(GetArea())
        SX3->(DbSetOrder(2))
        If SX3->(DbSeek(cField))
            Do Case
                Case nType == 1
                    cRet := X3Titulo()
                Case nType == 2
                    cRet := X3CBox()
            EndCase
        Endif
    SX3->(RestArea(aAreaSx3))	
Return cRet


/*/{Protheus.doc} RU06XFUNAD_aBrowseForFINC050
Form aBrowse for FINC050 routine
@param Character, cSimb, Currency symbol
@return array, aBrowse for Function Fc050Con()
/*/
Function RU06XFUNAD_aBrowseForFINC050(cSimb)
    Local aBrowse As Array
    Local cProg   := "FINC050"
    aBrowse := {{"  ","OK"},;
                {OEMTOANSI(FWI18NLang(cProg,"STR0010",9)),"DATAX"},;     // Date
                {OEMTOANSI(FWI18NLang(cProg,"STR0011",10)),"JUROS"},;    // Inter.Rt
                {OEMTOANSI(FWI18NLang(cProg,"STR0012",11)),"MULTA"},;    // Fine
                {OEMTOANSI(FWI18NLang(cProg,"STR0013",12)),"CORRECAO"},; // Adjustm.
                {OEMTOANSI(FWI18NLang(cProg,"STR0014",13)),"DESCONTOS"},;// Discounts
                {OEMTOANSI(FWI18NLang(cProg,"STR0067",65)),"VALACESS"},; // Accessory Values
                {OEMTOANSI(FWI18NLang(cProg,"STR0062",60)),"RETENCOES"},;// Withholding
                {OEMTOANSI(FWI18NLang(cProg,"STR0015",14)),"VALORPAGO"},;// Paid Value
                {OEMTOANSI(FWI18NLang(cProg,"STR0071",69)+" "+cSimb),"VLMOED2"},; // Amount in cSimb
                {OEMTOANSI(FWI18NLang(cProg,"STR0016",15)),"MOTIVO"},;   // Reason
                {OEMTOANSI(FWI18NLang(cProg,"STR0017",16)),"HISTORICO"},;// Prosm.
                {OEMTOANSI(FWI18NLang(cProg,"STR0018",17)),"DATACONT"},; // Typing Date
                {OEMTOANSI(FWI18NLang(cProg,"STR0044",42)),"DATADISP"},; // Availability Date
                {OEMTOANSI(FWI18NLang(cProg,"STR0019",18)),"LOTE"},;     // Lot
                {OEMTOANSI(FWI18NLang(cProg,"STR0020",19)),"BANCO"},;    // Bank
                {OEMTOANSI(FWI18NLang(cProg,"STR0021",20)),"AGENCIA"},;  // Branch
                {OEMTOANSI(FWI18NLang(cProg,"STR0022",21)),"CONTA"},;    // Accnt
                {OEMTOANSI(FWI18NLang(cProg,"STR0043",41)),"NROCHEQUE"},;// Check No.
                {OEMTOANSI(FWI18NLang(cProg,"STR0023",22)),"DOCUMENTO"},;// Document
                {OEMTOANSI(FWI18NLang(cProg,"STR0047",45)),"FILIAL"},;   // Mov. Branch
                {OEMTOANSI(FWI18NLang(cProg,"STR0045",43)),"RECONC"},;   // Reconciled
                {"ID"   ,"IDORIG"},;                                     // ID Origem // VA
                {"#"    ,"NORD" }}                                       // only for Russia       
Return aBrowse

/*/{Protheus.doc} RU06XFUNAE_aCamposForFINC050
Form acampos for FINC050 routine
@param Array, aTamSX3
@param Array, aTamSX3a
@param Array, aTamSX3b
@param Array, aTamSX3c
@param Logical, lFWCodFil
@param Numeric, nTamFilial, FWGETTAMFILIAL
@return array, aCampos for Static Function Fn050Cria in FINC050.PRX
/*/
Function RU06XFUNAE_aCamposForFINC050(aTamSX3,aTamSX3a,aTamSX3b,aTamSX3c,lFWCodFil,nTamFilial)
    Local aCampos as Array
    aCampos	:= {{"OK","N",1,0},;
                {"DATAX", "D", 08, 0 }, ;
                { "JUROS     ", "N", 16, 2 }, ;
                { "MULTA     ", "N", 16, 2 }, ;
                { "CORRECAO  ", "N", 16, 2 }, ;
                { "DESCONTOS ", "N", 16, 2 }, ;
                { "VALACESS"  , "N", 16, 2 }, ;
                { "RETENCOES ", "N", 16, 2 }, ;
                { "VALORPAGO ", "N", 16, 2 }, ;
                { "VLMOED2   ", "N", 16, 2 }, ;
                { "MOTIVO    ", "C", 03, 0 }, ;
                { "HISTORICO ", "C", aTamSX3a[1]+1,aTamSX3a[2]},;
                { "DATACONT  ", "D", 08, 0 }, ;
                { "DATADISP  ", "D", 08, 0 }, ;
                { "LOTE      ", "C", aTamSX3b[1], aTamSX3b[2]},;
                { "BANCO     ", "C", 03, 0 }, ;
                { "AGENCIA   ", "C", 05, 0 }, ;
                { "CONTA     ", "C", 10, 0 }, ;
                { "NROCHEQUE ", "C", 15, 0 }, ;
                { "DOCUMENTO ", "C", aTamSX3[1],aTamSX3[2]},;
                { "FILIAL    ", "C", IIf( lFWCodFil, nTamFilial, 2 ), 0 },;
                { "RECONC    ", "C", 01, 0 },;
                { "IDORIG    ", "C", aTamSX3c[1],aTamSX3c[2] },;
                { "NORD",       "N",  16, 0 } } //only for Russia
Return aCampos

/*/{Protheus.doc} RU06XFUNAF_RetdBaixaForFINA080
This function returns dBaixa dor fA080Tit function
@param Array, aAutoCab // private array
@return Date, dBaixa
/*/
Function RU06XFUNAF_RetdBaixaForFINA080(aAutoCab)
    Local dBaixa As Date
    If !Empty(aAutoCab)
        nPos := ASCAN(aAutoCab, {|x| x[1] == "AUTDTBAIXA"})
        If nPos > 0
            dBaixa := aAutoCab[nPos][2]
        EndIf
    EndIf
    If Empty(dBaixa)
        dBaixa := CriaVar("E2_BAIXA")
    EndIf
Return dBaixa

/*/{Protheus.doc} RU06XFUNAG_Fa084BrwDef
    Browser for fina084
    @type  Function
    @author astepanov
    @since 02/12/2022
    @version version
    @param cAlias, Character, "SE2"
    @param cTitle, Character, Title for browse
    @param cSQLFilter, Character, SQL filter for browse
    @return oBrowse, Object, FWmBrowse prepared object
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU06XFUNAG_Fa084BrwDef(cAlias,cTitle,cSQLFilter)
	Local aLegenda   As Array
	Local oBrowse    As Object
	Local nX         As Numeric
	oBrowse := FWLoadBrw("FINA084RUS")
	oBrowse:SetAlias(cAlias)
	oBrowse:SetDescription(cTitle)
	oBrowse:SetCanSaveArea(.T.)
	aRotina := FwLoadMenuDef("FINA084RUS") // set menu fro russian localization
	aLegenda := Fa084Legenda(cAlias)
	For nX := 1 to Len(aLegenda)
		oBrowse:AddLegend(aLegenda[nX][1],aLegenda[nX][2])
	Next nX
	cSQLFilter := IIF(Empty(cSQLFilter),"",cSQLFilter + " AND ")
	cSQLFilter += RU06XFUNAH_Fa084_Filter()
	oBrowse:SetFilterDefault("@ "+cSQLFilter)
	oBrowse:SetUseFilter(.T.)
Return oBrowse

/*/{Protheus.doc} RU06XFUNAI_Fa084_Filter
    Filter for query in F084DifMulti
    part 5 and part 6 of Oleg Ivanov Specification
    FI-AP-16-1     [ADVANCE PAYMENTS IN FOREIGN CURRENCY]
    @type  Function
    @author astepanov
    @since 02/12/2022
    @version version
    @return cFilter, Character, filtering part of SQL query
    @example
    (examples)
    @see https://jiraproducao.totvs.com.br/browse/RULOC-40
    /*/
Function RU06XFUNAH_Fa084_Filter()
    Local cFilter As Character
    cFilter := ""
    //Add to not allow PA types and documents seletec to prepayments (at FR3 table)
	cFilter += " E2_TIPO NOT IN " + FormatIn(GetNewPar('MV_PPREPA',MVPAGANT),IIf("|" $ GetNewPar('MV_PPREPA', MVPAGANT),"|",",")) 
	cFilter += " AND CONCAT(E2_NUM, E2_PREFIXO, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA) "
	cFilter += " NOT IN ( SELECT CONCAT(FR3.FR3_NUM, FR3.FR3_PREFIX, FR3.FR3_PARCEL, FR3.FR3_TIPO, FR3.FR3_FORNEC, FR3.FR3_LOJA) "
	cFilter += " FROM " + RetSqlName("FR3") + "  FR3 WHERE FR3.FR3_FILIAL = E2_FILIAL AND FR3.FR3_CART = 'P' AND FR3.D_E_L_E_T_ = ' ' ) "
Return cFilter

/*/{Protheus.doc} RU06XFUNAJ_Fa080_SetnTxMoeda
    Set nTxMoeda when we in fA080Grv function
    When we post replacement bank statement we must use one date for recoreds, but for
    exchange rate we must use another date/ So we set exchange rate manually
    @type  Function
    @author astepanov
    @since 06/21/2023
    @version version
    @param nTxMoeda, Numeric, Passed parameter which we change
    @param aBStExpPrm, Array, Array with parameters created by RU06D07048_Init_aBStExpPrm function
    @param aTxMoedas, Array, array with currencies and exchange rates
    @return lRet, Logical, .T. or .F.
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU06XFUNAJ_Fa080_SetnTxMoeda(nTxMoeda, aBStExpPrm, aTxMoedas)
    Local lRet As Logical
    lRet := .T.
    If !Empty(aBStExpPrm) .AND. Len(aBStExpPrm) > 1 .AND. !Empty(aBStExpPrm[1][2]) 
		If !Empty(aTxMoedas)
			If Len(aTxMoedas) >= SE2->E2_MOEDA
				nTxMoeda := aTxMoedas[SE2->E2_MOEDA][2]
			Else
				nTxMoeda := 1
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} RU06XFUNAK_CorrectnSaldoinFA080GRV
    We use this function for correcting nSaldo in fa080grv function in fina080
    @type  Function
    @author astepanov
    @since 11/08/2023
    @version version
    @param nSaldo,   Numeric, New saldo calculated by fa080grv function, changebale parameter
    @param nE2Saldo, Numeric, SE2->E2_SALDO value
    @param aBStExpPrm, Array, parametere created by RU06D07048_Init_aBStExpPrm function
    @return nSaldo, Numeric, Corrected saldo value
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU06XFUNAK_CorrectnSaldoinFA080GRV(nSaldo, nE2Saldo, aBStExpPrm)
    Local lRet As Logical
    lRet  := .T.
    If !Empty(aBStExpPrm)
        If aBStExpPrm[9][2] != Nil   // check Bank statement process
            If (.NOT. aBStExpPrm[11][2]) // we are not in cancelling exchange rates process
                nSaldo := nE2Saldo  - aBStExpPrm[9][2]
            EndIf
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} ChangeaAutocabOrder(aRotAuto, aAutocab)
    When we save AP in FIAN050 function we call FWVetByDic function
    for ordering fields by their order in SX3 table. In Russia case we
    put FINA05001_ funtion in a trigger to E2_ALQIMP1 field. It is good for
    automatic calculations for E2_BASIMP1 and E2_ALQIMP1, but if user wants
    to change E2_BASIMP1 and E2_ALQIMP1 fields manually, we should run FINA05001_
    at first and after that change E2_BASIMP1 and E2_ALQIMP1.
    So we seek in aRotAuto "FIXORDEM" tag, if we found it we parse value
    related to this tag and store it in aFields array. 
    This value must coantial list of field separated by "|",
    for example "E2_ALQIMP1|E2_BASIMP1|E2_VALIMP1" order matters!
    We change field order in aAutoCab  according to fildes order aFields.
    So we can escape automatic field changing, changing field order and  moving
    fields with trigger to top in aAutocab
    @type Function
    @author astepanov
    @since 28/09/2023
    @version version
    @param aRotAuto, Array, first parameter of FINA050 function
    @param aAutocab, Array, Array with fields which must be changed in SE2 table
    @return lRet, Logical, .T. if all is ok
    @example
    (examples)
    @see (links_or_references)
/*/
Function RU06XFUNAL_ChangeaAutocabOrder(aRotAuto, aAutocab)
    Local lRet    As Logical
    Local nX      As Numeric
    Local nY      As Numeric
    Local aFields As Array
    Local aPos    As Array
    Local aTemp   As Array
    lRet := .T.
    If !Empty(aRotAuto) .AND. !Empty(aAutocab)
        nX := ASCAN(aRotAuto, {|x| x[1] == "FIXORDEM"})
        If nX > 0
            aFields := STRTOKARR(aRotAuto[nX][2],"|")
            aPos  := {}
            aTemp := {}
            For nX := 1 To Len(aFields) //Fill aPos
                nY := ASCAN(aAutocab, {|x| aFields[nX] = x[1]})
                If nY > 0 
                    AADD(aPos, nY)
                    AADD(aTemp, ACLONE(aAutocab[nY])) //save to temporary array
                EndIf
            Next nX
            ASORT(aPos) // sort available positions
            For nX := 1 To Len(aPos) //put to aTemp items to new positions
                aAutocab[aPos[nX]] := ACLONE(aTemp[nX])
            Next nX
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} RU06XFUNAM
    Used in RU06D04
    @type  Function
    @author kkonovalov
    @since 04/07/2023
    @version version
    @param cAlias, aFldList
    @return array object with list of fields belongs to given folder(s)
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU06XFUNAM_GetFolderFieldsList(cAlias, aFldList)

    Local aBelField     as Array
    Local iFldLst       as Numeric
    Local cActEnv       as Character
    Local cSXANam       as Character
	Local cQuery	    as Character
    Local cQueryEx      as Character
	Local cAliasQry	    as Character
    // If no aFldList, so return all fields
    // for all folders (include all tab!):
    DEFAULT aFldList   := {}

    aBelField:={}
	cAliasQry := GetNextAlias()
    cActEnv := RetSQLName("SX3")
    cSXANam := "SXA" + Right(cActEnv, Len(cActEnv) - 3)

	If cAlias != Nil
		cQuery := " SELECT X3_CAMPO, X3_FOLDER FROM " + cActEnv 
        cQuery += " LEFT JOIN " + cSXANam + "  ON "
        cQuery += " X3_ARQUIVO = XA_ALIAS and X3_FOLDER = XA_ORDEM "
        cQuery += " and XA_AGRUP = '' and XA_TIPO = '' "
        cQuery += " WHERE X3_ARQUIVO = '" + cAlias + "' AND " + cActEnv  
        cQuery += ".D_E_L_E_T_  = ' ' AND " + cSXANam + ".D_E_L_E_T_  = ' '"
        
        if !Empty(aFldList)
            //build additional where condition:
            if Len(aFldList) == 1
                // simply equal:
                cQueryEx := " and X3_FOLDER = '" + aFldList[1] + "' "
            else
                // IN() statement:
                cQueryEx := " and X3_FOLDER IN( "
                For iFldLst := 1 to Len(aFldList)
		            cQueryEx +="'" + aFldList[iFldLst] + "', "
	            Next iFldLst
                //remove last two symbols ', '                
                cQueryEx := Left(cQueryEx, len(cQueryEx)-2)
                // add closing parenthesis:
                cQueryEx += " ) "
            endif
            cQuery += cQueryEx
        endif

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

		While !(cAliasQry)->(Eof()) 
			AADD(aBelField, AllTrim((cAliasQry)->X3_CAMPO))
			(cAliasQry)->(dbSkip())
		EndDo 
		(cAliasQRY)->(dbCloseArea())
	EndIf
Return aBelField

/*/{Protheus.doc} aAddEx
    Used in RU06D04
    @type  Function
    @author kkonovalov
    @since 04/07/2023
    @version version
    @param aDest - array where the data will be added(by copied) to
    @param aSource - array from where the data will be copied
    @return array object aDest 
    @example
    (examples)
    @see (links_or_references)
    /*/
Function aAddEx(aDest, aSource)
    Local extetS    as Numeric
    Local nIex      as Numeric

    if !Empty(aSource)
        extetS := Len(aSource)
        for nIex := 1 To extetS  
            AADD(aDest, aSource[nIex])
        Next nIex
    Endif

Return aDest

/*/{Protheus.doc} RU06XFUNAN_FilterBills(cInParam)
    This function creates filter for query in FA340QRYTI
    @type  Function
    @author astepanov
    @since 29/11/2023
    @version version
    @param cInParam, Character, Bill types separated by "|"
    @param cTipo, Character, SE2->E2_TIPO
    @param dEmissao, Date, SE2->E2_EMISSAO
    @param nMoeda, Numeric, SE2->E2_MOEDA
    @param lForADVPLF, Logical, prepare for ADVPL FILTER
    @return cQry, Character, Filtre for query cQry in FA340QRYTI
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU06XFUNAN_FilterBills(cInParam, cTipo, dEmissao, nMoeda, lForADVPLF)
    Local cQry As Character
    Default lForADVPLF := .F.
    cQry := ""
    If !Empty(cInParam)
        cQry += " AND SE2.E2_TIPO IN "+cInParam+ " "
    EndIf
    If cTipo $ MVNOTAFIS
        If nMoeda != 1
            cQry += " AND SE2.E2_EMISSAO >= "+IIF(lForADVPLF,"STOD('"+DTOS(dEmissao)+"') ","'"+DTOS(dEmissao)+"' ")
        EndIf
    ElseIf cTipo $ MVPAGANT
        cQry += " AND ( SE2.E2_MOEDA = 1 OR ( SE2.E2_MOEDA <> 1 AND SE2.E2_EMISSAO <= "+IIF(lForADVPLF,"STOD('"+DTOS(dEmissao)+"') ","'"+DTOS(dEmissao)+"' ")+")) "
    EndIf
Return cQry

/*/{Protheus.doc} RU06XFUNAO_ApplyFilterBills(nIt,aArray,nmvpar10)
    This function creates ADVPL filter when we check bills in compensation window
    in Static Function FA340Troca in FINA340.PRX
    @type  Function
    @author astepanov
    @since 29/11/2023
    @version version
    @param nIt, Numeric,position of selected item
    @param aArray, Array, Array with grid items
    @param nmvpar10, Numeric, SE2->MV_PAR10 value, 1 means standard
    @return lRet, Logical, if .T. all is ok
    @example
    (examples)
    @see FI-AP-15-6 Compensation of AP in foreign currency
    /*/
Function RU06XFUNAO_ApplyFilterBills(nIt,aArray,nmvpar10)
    Local lRet       As Logical
    Local cFilter    As Character
    Local cE2Tipo    As Character
    Local dE2Emissao As Date
    Local nE2Moeda   As Numeric
    lRet := .T.
    If nmvpar10 == 1
        cE2Tipo    := aArray[nIt][4]
        dE2Emissao := STOD(aArray[nIt][10])
        nE2Moeda   := aArray[nIt][9]
        If SE2->E2_TIPO $ MVPAGANT+"|"+MV_CPNEG+"|DIC"
            cFilter := RU06XFUNAN("", SE2->E2_TIPO, SE2->E2_EMISSAO, SE2->E2_MOEDA, .T.)
        Else
            cFilter := RU06XFUNAN("'"+MVPAGANT+"'", SE2->E2_TIPO, SE2->E2_EMISSAO, SE2->E2_MOEDA, .T.)
        EndIf
        cFilter := STRTRAN( cFilter, " AND ", " .AND. ")
        cFilter := STRTRAN( cFilter, " OR " , " .OR. ")
        cFilter := STRTRAN( cFilter, " IN ", " $ ")
        cFilter := STRTRAN( cFilter, " = ", " == ")
        cFilter := STRTRAN( cFilter, " SE2.E2_TIPO ", " cE2Tipo ")
        cFilter := STRTRAN( cFilter, " SE2.E2_EMISSAO ", " dE2Emissao ")
        cFilter := STRTRAN( cFilter, " SE2.E2_MOEDA ", " nE2Moeda ")
        cFilter := ".T. "+cFilter
        lRet := &(cFilter)
    EndIf
    If !lRet
        Help("",1,STR0114,,STR0115,1,0,,,,,,{}) // Bills compensation, It's impossible to select this bill for compensation 
    EndIf
Return lRet

/*/{Protheus.doc} RU06XFUNAP_OrderByEmissao(cOrder)
    This function changes __cOrder in Static Function FA340QryTi in FINA340.PRX
    accordin to consultant requirements it is obligatory to order bills by E2_EMISSAO
    at first
    @type  Function
    @author astepanov
    @since 29/11/2023
    @version version
    @param cOrder, Character , part of sql query after ORDER BY
    @return cRet, Character, new order string
    @example
    (examples)
    @see FI-AP-15-6 Compensation of AP in foreign currency
    /*/
Function RU06XFUNAP_OrderByEmissao(cOrder)
    Local cRet As Character
    cRet := cOrder
    If !Empty(cOrder)
        If AT("E2_FILIAL,",cOrder) > 0
           cRet := STRTRAN( cOrder, "E2_FILIAL,", "E2_FILIAL,E2_EMISSAO,") 
        EndIf
    EndIf
Return cRet

/*/{Protheus.doc} RU06XFUNAR_SortByEmissao(aTitles)
    Order elements of  aTitles by emissao date in Function fA340Comp in FINA340.PRX
    @type  Function
    @author astepanov
    @since 29/11/2023
    @version version
    @param aTitles, Array , elements of compensation grid
    @return lRet, Logical, .T. if all is ok
    @example
    (examples)
    @see FI-AP-15-6 Compensation of AP in foreign currency
    /*/
Function RU06XFUNAR_SortByEmissao(aTitles)
    Local lRet As Logical
    lRet := .T.
    ASORT(aTitles, , , { | a,b | STOD(a[10]) <= STOD(b[10]) } )
Return lRet

/*/{Protheus.doc} RU06XFUNAS_SnippetForGeneratingExchangeRateDif(nSE2Recno,nSE2MOEDA,cSE2TIPO,dSE2EMISSA,nSE2SALDO,@aBStExpPrm,nmvpar10,nREGVALOR,nVlrMov,aTitulos,nTit)
    Generate exchange rate difference whe run compensation
    @type  Function
    @author astepanov
    @since 29/11/2023
    @version version
    @param nSE2Recno,  Numeric , current SE2->(Recno())
    @param nSE2MOEDA,  Numeric, SE2->E2_MOEDA
    @param cSE2TIPO,   Character, SE2->E2_TIPO
    @param dSE2EMISSA, Date, SE2->E2_EMISSAO
    @param nSE2SALDO,  Numeric, SE2->E2_SALDO
    @param aBStExpPrm, Array, 
    @param nmvpar10  , Numeric, mv_par10 F12 parameter in FINA340
    @param nREGVALOR,  Numeric, position of SE2 record
    @param nVlrMov,    Numeric, Monetary value
    @param aTitulos,   Array, Array with selected elements for compensation
    @param nTit,       Numeric, Currenly selected item in aTitulos
    @return lRet, Logical, .T. if all is ok
    @example
    (examples)
    @see FI-AP-15-6 Compensation of AP in foreign currency
    /*/
Function RU06XFUNAS_SnippetForGeneratingExchangeRateDif(nSE2Recno,nSE2MOEDA,cSE2TIPO,dSE2EMISSA,nSE2SALDO,aBStExpPrm,nmvpar10,nREGVALOR,nVlrMov,aTitulos,nTit)
    Local aRet       As Array
    Local lRet       As Logical
    Local nMoedaTit  As Numeric
    Local nCurrSE2Re As Numeric
    Local dE2_Emissa As Date
    lRet := .T.
    nMoedaTit := nSE2MOEDA
    If nmvpar10 == 1
        If cSE2TIPO $ MVPAGANT
            nCurrSE2Re  := nSE2Recno
            dE2_Emissa  := dSE2EMISSA
            SE2->(DBGoto(nREGVALOR))
            aRet := RU06XFUN11(@aBStExpPrm,dE2_Emissa,RecMoeda(dE2_Emissa,nMoedaTit),nVlrMov,xMoeda(SE2->E2_SALDO,nMoedaTit,1,dE2_Emissa),.F.,Nil)
            SE2->(DBGoto(nCurrSE2Re ))
        Else
            aRet := RU06XFUN11(@aBStExpPrm,STOD(aTitulos[nTit, 10]),RecMoeda(STOD(aTitulos[nTit, 10]),nMoedaTit),nVlrMov,xMoeda(nSE2SALDO,nMoedaTit,1,STOD(aTitulos[nTit, 10])),.F.,Nil)
        EndIf
        lRet := aRet[1]
    EndIf
Return lRet

/*/{Protheus.doc} RU06XFUNAT(nPar,dDataBase,dBaixa,nTxMoedP,nTxTiBrw,nSE2MOEDA,dBackUpDat,nBckUpTxMo,nBckUpTxTB)
    We use this snippet for changing dDataBase, __nTxMoedP, __nTxTiBrw before running fa340mov and restore
    these vars at tne end of fa340mov. We must in correct way transfer parameters to this function.
    @type  Function
    @author astepanov
    @since 29/11/2023
    @version version
    @param nPar,  Numeric , 1 - change and save, 2 - restore
    @param dDataBase,  Date, current database date
    @param dBaixa,   Date, 
    @param nTxMoedP, Numeric, Exchange rate
    @param nTxTiBrw,  Numeric, Exchange rate
    @param nSE2MOEDA, Numeric, SE2->E2_MOEDA
    @param dBackUpDat  , Date, parameter used for backup dDataBase
    @param nBckUpTxMo,  Numeric, parameter used for backup nTxMoedP
    @param nTxMoedP,    Numeric, parameter used for backup nTxTiBrw
    @return lRet, Logical, .T. if all is ok
    @example
    (examples)
    @see FI-AP-15-6 Compensation of AP in foreign currency
    /*/
Function RU06XFUNAT(nPar,dDataBase,dBaixa,nTxMoedP,nTxTiBrw,nSE2MOEDA,dBackUpDat,nBckUpTxMo,nBckUpTxTB)
    Local lRet   As Logical
    lRet := .T.
    If nPar == 1 // change values and save them
        dBackUpDat := dDataBase
        dDataBase  := dBaixa
        nBckUpTxMo := nTxMoedP
        nBckUpTxTB := nTxTiBrw
        nTxMoedP := RecMoeda(dDataBase,nSE2MOEDA)
        nTxTiBrw := nTxMoedP
    ElseIf nPar == 2 // restore saved values
        dDataBase  := dBackUpDat
        nTxMoedP   := nBckUpTxMo
        nTxTiBrw   := nBckUpTxTB
    EndIf
Return lRet


/*/{Protheus.doc} RU06XFUNB1_RussianMenuItems
Russian menu items for FINA050 module
@type   Function
@author Konstantin Konovalov
@since  01/04/2024
@version version 
@param  aRotina, Array, Standard menu items array from caller
@return aRotina, Array, Modified menu items array
@see  FI-VAT-37-3, FI-VAT-37-4
/*/
Function RU06XFUNB1_RussianMenuItems(aRotina as Array)
    Local aAddOpc   as Array  

    aAdd( aRotina, { STR0116 ,"FIN50PQBrw('PR')",0,4})		//"Track PRs"
    aAdd( aRotina, { STR0117 ,"FIN50PQBrw('PO')",0,4})		//"Track POs"
    aAdd( aRotina, { STR0118 ,"FIN50PQBrw('BS')",0,4})      //"Bank Statements"
               
    aAddOpc:= {{STR0120,  "RU06XFUNB2()", 0, 2, 0, Nil},;   //"Track"  
                {STR0121, "RU06XFUNB5()", 0, 3, 0, Nil},;   //"Add"
                {STR0122, "RU06XFUNB6()", 0, 4, 0, Nil},;   //"Edit"
                {STR0123, "RU06XFUNB7()", 0, 5, 0, Nil}}    //Delete
    aAdd(aRotina, {STR0119, aAddOpc, 0, 3, 0, Nil})         //Tracking inflow VAT Invoice

Return aRotina

/*/{Protheus.doc} RU06XFUNB2_TrackVATInvoice
Tracks(view) a VAT Invoice from FINA050
@type   Function          
@author Konstantin Konovalov
@since  01/04/2024
@version version
@see FI-VAT-37-3, FI-VAT-37-4
/*/
Function RU06XFUNB2_TrackVATInvoice()

	Local aArea     As Array
	Local cTitle    As Character
	Local cHelp     As Character
	Local oModel    As Object
	Local cCustomer As Character
	Local cBranch   As Character
	Local cSupplier As Character

	cTitle := ""
	cHelp  := ""
	cCustomer := ""
	cBranch := ""
	cSupplier := ""

	aArea := GetArea()

	If RU06XFUNB3()
        If RU06XFUNB4()

            FWExecView(STR0120, "RU09T10", MODEL_OPERATION_VIEW,, {|| .T.})
        Else

            cTitle := "RU06XFUNB2_TrackVATInvoice"
            cHelp := STR0124 + CRLF + STR0125 //"There is no Outflow VAT Invoice for the Payment in Advance created at this Bank Statement. | Would you like to create the Outflow VAT Invoice?"

            If IsBlind() .Or. MsgYesNo(cHelp, cTitle)

                cSupplier := SE2->E2_FORNECE
                cBranch   := SE2->E2_LOJA

                // If it is everything OK, must to show a window to the end user to continue to add a Sales VAT Invoice.
                oModel := FwLoadModel("RU09T10")
                oModel:SetOperation(MODEL_OPERATION_INSERT)
                oModel:SetDescription(STR0130) //Advances Payment
                oModel:Activate()
                oModel := RU09T10008(oModel, , , cSupplier, cBranch)
                oModel:GetModel("F38detail"):SetNoInsertLine(.F.)
                oModel:GetModel("SE2detail"):SetNoInsertLine(.T.)
                FwExecView(STR0121, "RU09T10", MODEL_OPERATION_INSERT,, {|| .T.},,,,,,, oModel) // "Add"

            EndIf
        EndIf
	Else
		cTitle := "RU06XFUNB2_TrackVATInvoice"
		cHelp := STR0126 //There is no Receipt/Payment in Advance for the selected document
		Help(Nil, Nil, cTitle, Nil, cHelp, 1, 0,,,,,,)
	EndIf

	RestArea(aArea)

Return()

/*/{Protheus.doc} RU06XFUNB3_CheckBankStatement
If Invoice(Advance) has a Bank statement document (based from) (FINA050 context)
This is inverse function to  RU06D07819_CheckAdvances (from F4C to SE2)
@type   Static Function
@author Konstantin Konovalov
@since  01/04/2024
@version version    
@return lRet, Logical, .T. - Bank statement exists, otherwise .F.
@see  FI-VAT-37-3, FI-VAT-37-4
/*/
Static Function RU06XFUNB3_CheckBankStatement() as Logical
	Local lRet      As Logical
	Local cKey      As Character
    Local cQuery    As Character
    Local cTabF5F4  As Character
    Local aArea     As Array
 
    aArea := GetArea()
	lRet := .F. 
    // Type:
    If (SE2->E2_TIPO $ MVPAGANT)    
        cKey := ""
        cKey := PADR(xFilial("SE2"),  TamSX3("E2_FILIAL")[1]) + "|"
        cKey += PADR(SE2->E2_PREFIXO, TamSX3("E2_PREFIXO")[1]) + "|"
        cKey += PADR(SE2->E2_NUM,     TamSX3("E2_NUM")[1])    + "|"
        cKey += PADR(SE2->E2_PARCELA, TamSX3("E2_PARCELA")[1]) + "|"
        cKey += PADR(SE2->E2_TIPO,    TamSX3("E2_TIPO")[1])   + "|"
        cKey += PADR(SE2->E2_FORNECE, TamSX3("E2_FORNECE")[1]) + "|"
        cKey += PADR(SE2->E2_LOJA,    TamSX3("E2_LOJA")[1])	
        
        cQuery := " SELECT Count(*) BS_EXIST "
        cQuery += " FROM " + RetSQLName("F5M") + " FM "
        cQuery += " INNER JOIN " + RetSQLName("F4C") + " FC "
        cQuery += " ON (F5M_IDDOC=F4C_CUUID and F5M_FILIAL = '" + xFILIAL("F5M") + "') "
        cQuery += " WHERE FC.D_E_L_E_T_ =' ' AND FM.D_E_L_E_T_=' '"
        cQuery += " AND F5M_KEY ='" + cKey + "' and F5M_ALIAS='F4C' " 

        cTabF5F4 := MPSysOpenQuery(ChangeQuery(cQuery))
        DBSelectArea(cTabF5F4)
        (cTabF5F4)->(DBGoTop())
        If !(cTabF5F4)->(Eof())
            If (cTabF5F4)->BS_EXIST > 0
                lRet := .T.
            EndIf
        EndIf
        (cTabF5F4)->(DBCloseArea())        

    EndIf
    RestArea(aArea)
 
Return(lRet)

/*/{Protheus.doc} RU06XFUNB4_CheckVATonAdvances
If there is a VAT Invoice for the Advance Receivement/Payment (FINA050 context)
@type   Static Function
@author Konstantin Konovalov
@since  02/04/2024
@version version 
@return lRet, Logical, .T. - Vat Invoice exists, otherwise .F.
@see  FI-VAT-37-3, FI-VAT-37-4
/*/
Static Function RU06XFUNB4_CheckVATonAdvances() As Logical

	Local cQuery    As Character
	Local cAlias    As Character
	Local lRet      As Logical
    Local aArea     As Array
    Local aAreaF37  As Array

    aArea := GetArea()
	cQuery := ""
	cAlias := ""
	lRet   := .F.

    cQuery := "SELECT F37_FILIAL, " + CRLF
    cQuery += "       F37_FORNEC, " + CRLF
    cQuery += "       F37_BRANCH, " + CRLF
    cQuery += "       F37_PDATE, " + CRLF
    cQuery += "       F37_DOC, " + CRLF
    cQuery += "       F37_TYPE, " + CRLF
    cQuery += "       F37_KEY " + CRLF
    cQuery += " FROM " + RetSQLName("F37")  + CRLF
    cQuery += " WHERE F37_FILIAL  = '" + xFilial("F37", SE2->E2_FILIAL) + "' " + CRLF
    cQuery += "      AND F37_PREFIX  = '" + SE2->E2_PREFIXO + "' " + CRLF
    cQuery += "      AND F37_NUM     = '" + SE2->E2_NUM + "' " + CRLF
    cQuery += "      AND F37_PARCEL  = '" + SE2->E2_PARCELA + "' " + CRLF
    cQuery += "      AND F37_TIPO    = '" + SE2->E2_TIPO + "' " + CRLF
    cQuery += "      AND F37_FORNEC  = '" + SE2->E2_FORNECE + "' " + CRLF
    cQuery += "      AND F37_BRANCH  = '" + SE2->E2_LOJA + "' " + CRLF
    cQuery += "      AND D_E_L_E_T_  = ' ' "

    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    DBSelectArea(cAlias)

    If !(cAlias)->(Eof())
        aAreaF37 := F37->(GetArea())
        DBSelectArea("F37")
        F37->(DBSetOrder(3)) //f37_filial + f37_key
        If F37->(MSSeek(xFilial("F37", (cAlias)->F37_FILIAL) + (cAlias)->F37_KEY))
            lRet := .T.
        EndIf
        RestArea(aAreaF37)
    EndIf

    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    
Return(lRet)

/*/{Protheus.doc} RU06XFUNB5_AddVatInvoice
Adding VAT Invoice for selected Invoice (FINA050 context)
@type   Function
@author Konstantin Konovalov
@since  02/04/2024
@version version
@see  FI-VAT-37-3, FI-VAT-37-4
/*/
Function RU06XFUNB5_AddVatInvoice()
         
	// Working areas
	Local aArea As Array
	Local cTitle As Character
	Local cHelp  As Character

	Local oModel As Object

	Local cCustomer As Character
	Local cBranch As Character
	Local cSupplier As Character

	cTitle := ""
	cHelp  := ""
	cCustomer := ""
	cBranch := ""
	cSupplier := ""

	aArea := GetArea()

	If RU06XFUNB3()
        If RU06XFUNB4()

            cTitle := "RU06XFUNB5_AddVatInvoice"
            cHelp := STR0127 + F37->F37_DOC + STR0128 + CRLF + ; // "A Outflow VAT Invoice number: " + F37->F37_DOC + " was found for the Payment in Advance created by selected Bank Statement." + CRLF + ;
                     STR0129 //"Would you like to view this Outflow VAT Invoice??"
            If IsBlind() .Or. MsgYesNo(cHelp, cTitle)
                FWExecView(STR0120, "RU09T10", MODEL_OPERATION_VIEW,, {|| .T.})
            EndIf
        Else

            cSupplier := SE2->E2_FORNECE
            cBranch   := SE2->E2_LOJA

            // If it is everything OK, must to show a window to the end user to continue to add a Sales VAT Invoice.
            oModel := FwLoadModel("RU09T10")
            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:SetDescription(STR0130) // "Payments in Advance"
            oModel:Activate()
            oModel := RU09T10008(oModel, , , cSupplier, cBranch)
            oModel:GetModel("F38detail"):SetNoInsertLine(.F.)
            oModel:GetModel("SE2detail"):SetNoInsertLine(.T.)
            FwExecView(STR0121, "RU09T10", MODEL_OPERATION_INSERT,, {|| .T.},,,,,,, oModel) // "Add"
        EndIf

	Else
		cTitle := "RU06XFUNB5_AddVatInvoice"
		cHelp := STR0126 + CRLF + STR0131 //There is no Receipt/Payment in Advance for the selected document & It will be impossible to create a Inflow/Outflow VAT Document for this Bank Statement.
		Help(Nil, Nil, cTitle, Nil, cHelp, 1, 0,,,,,,)
	EndIf

	RestArea(aArea)

Return()

/*/{Protheus.doc} RU06XFUNB6_EditVATInvoice
Editing VAT Invoice for selected Invoice (FINA050 context)
@type   Function
@author Konstantin Konovalov
@since  02/04/2024
@version version
@see  FI-VAT-37-3, FI-VAT-37-4
/*/
Function RU06XFUNB6_EditVATInvoice()
         
	Local aArea As Array
	Local cTitle As Character
	Local cHelp  As Character

	cTitle := ""
	cHelp  := ""

	aArea := GetArea()

	If RU06XFUNB3()
		If RU06XFUNB4()

			FWExecView(STR0122, "RU09T10", MODEL_OPERATION_UPDATE,, {|| .T.})            
		Else
			cTitle := "RU06XFUNB6_EditVATInvoice"
			cHelp := STR0132 //Inflow/Outflow VAT not found for the selected Bank Statement.
			Help(Nil, Nil, cTitle, Nil, cHelp, 1, 0,,,,,,)
		EndIf

	Else
		cTitle := "RU06XFUNB6_EditVATInvoice"
		cHelp := STR0126 + CRLF + STR0133 //There is no Receipt/Payment in Advance for the selected document & It will be impossible to edit the Inflow/Outflow VAT Document for this Bank Statement.
		Help(Nil, Nil, cTitle, Nil, cHelp, 1, 0,,,,,,)
	EndIf

	RestArea(aArea)

Return()

/*/{Protheus.doc} RU06XFUNB7_DeleteVATInvoice
Delete VAT Invoice for selected Invoice (FINA050 context)
@type   Function
@author Konstantin Konovalov
@since  02/04/2024
@version version
@see  FI-VAT-37-3, FI-VAT-37-4
/*/
Function RU06XFUNB7_DeleteVATInvoice()

    Local aArea As Array
	Local cTitle As Character
	Local cHelp  As Character

	cTitle := ""
	cHelp  := ""

	aArea := GetArea()

	If RU06XFUNB3()
		If RU06XFUNB4()

			FWExecView(STR0123, "RU09T10", MODEL_OPERATION_DELETE,, {|| .T.})	
		Else
			cTitle := "RU06XFUNB7_DeleteVATInvoice"
			cHelp := STR0132 //Inflow/Outflow VAT not found for the selected Payment Invoice.
			Help(Nil, Nil, cTitle, Nil, cHelp, 1, 0,,,,,,)
		EndIf

	Else
		cTitle := "RU06XFUNB7_DeleteVATInvoice"
		cHelp := STR0126 + CRLF + STR0134  //There is no Receipt/Payment in Advance for the selected document & It will be impossible to delete the Inflow/Outflow VAT Document for this Payment Invoice.
		Help(Nil, Nil, cTitle, Nil, cHelp, 1, 0,,,,,,)
	EndIf

	RestArea(aArea)

Return()


/*/{Protheus.doc} RU06XFUNB8_CheckIfPost
    "This function checks whether we should post the inclusion of the bill or not."
    @type  Function
    @author eduardo.Flima
    @since 03/03/2025
    @version R14
    @param nRuCont   , Character , Options if we are going to post 1-Yes 2-No 0-something wrong
    @param aAutoCab  , Array     , Array with the data of the inclusion
    @param lPadrao   , Logica    , If it will be posted or not    
    @return lPadrao   , Logica    , If it will be posted or not
/*/
Function RU06XFUNB8_CheckIfPost(nRuCont as Numeric,aAutoCab as Array, lPadrao as Logical)
    Local nLoop     :=0     as Numeric
    If lPadrao .and. nRuCont <> 0 
        lPadrao := nRuCont == 1
    EndIf
    nLoop := ASCAN(aAutoCab, {|x|, x[1] == "E1_ORIGEM"})
    If lPadrao .and. (nLoop > 0 .AND. aAutoCab[nLoop][2] == "RU06D07")
        lPadrao := .F.
    EndIf
Return lPadrao

/*/{Protheus.doc} RU06XFUNB9_CheckIfPost
    Try to find history line and set it into the model 
    @type  Function
    @author eduardo.Flima
    @since 04/03/2025
    @version R14
    @param oModel       , Object    , Model of the transaction
    @param aAutoCab     , Array     , Array with the 
    @return oModel      , Object    , Model of the transaction
/*/
Function RU06XFUNB9_UpdHist(oModel As Object ,aAutoCab As Array)
    Local nX as Numeric
    nX := ASCAN(aAutoCab, {|x|, x[1] == "AUTHIST"}) // Try to find history line
    If nX > 0
        oModel:SetValue( "MASTER", "HISTMOV", OemToAnsi(aAutoCab[nX][2]))
    EndIf
Return oModel


/*/{Protheus.doc} RU06XFUNB9_GerChqAdt
    Function responsible for verifying whether a check will be issued for the advance payment.
    @type  Function
    @author eduardo.Flima
    @since 06/04/2025
    @version R14
    @param lGerChqAdt   , Logical   , Current state if the check will be issued
    @param lMovRus      , Logical   , If the bill generates movement 
    @return lRetGerChA  , Logical   , If the check will be issued for the advance payment.
/*/
Function RU06XFUNBA_GerChqAdt(lGerChqAdt AS Logical,lMovRus AS Logical)
    Local lRetGerChA := lGerChqAdt as Logical
    If !lMovRus
        lRetGerChA := .T.
    Endif 
Return lRetGerChA


/*/{Protheus.doc} RU06XFUNBB_PrbPost
    Function responsible for verifying whether any issue occurred during the posting process.
    @type  Function
    @author eduardo.Flima
    @since 06/04/2025
    @version R14
    @param lF070Auto    , Logical       , If it is an automatic routine
    @param nOriRec      , Numeric       , Recno Number
    @param cInfo        , Caharacter    , Info message of problem 
    @param cSolut       , Caharacter    , Info message of Solution 
/*/
Function RU06XFUNBB_PrbPost(lF070Auto as Logical ,nOriRec as Numeric ,cInfo as Caharacter,cSolut as Character)
    If lF070Auto
        FK1->(DbGoTo(nOriRec))
        If nOriRec != FK1->(Recno())
            Help( ,, "F070CONT",, cInfo , 1, 0,,,,,, {cSolut} ) //Posting Problem, "Check the posting settings for receivable write-off"
            If (ValType(lPrbPost)=="L")
                lPrbPost:=.T.				
            ENDIF
        Endif
    Endif 
Return 


/*/{Protheus.doc} RU06XFUNBC_CHeckTxxMoed
    Function responsible for validating that the exchange rate is greater than zero for currencies different than the base currency (currency 1)
    @type  Function
    @author eduardo.Flima
    @since 08/04/2025
    @version R14
    @param nTxMoeda     , Numeric   , Currency exchange rate
    @param nMoeda       , Numeric   , Currency of the operation
    @return lRet        , LOGICAL   , If it is valid or not
/*/
Function RU06XFUNBC_CHeckTxxMoed(nTxMoeda AS Numeric,nMoeda AS Numeric)
    Local lRet := .T. AS LOGICAL
	If !(nTxMoeda > 0) .And. (nMoeda > 1)
		cFA070BtOK = ALLTRIM(Posicione("CTO",1,xFilial("CTO")+StrZero(nMoeda,2),"CTO_SIMB"))
		RU99XFUN05(STR0095 + " " + STR0096 + " " + cFA070BtOK + " " + STR0097 + " " + DTOC(dDatabase) + " " + STR0098 + " " + STR0099) // "Help" messeg: "It is impossible to write off. The USD exchange rate as of the date DD.MM.YYYY is not filled in. You can specify the currency rate in module 06, "Currencies" programm (MATA090)"
		lRet := .F.
	Endif
Return lRet


/*/{Protheus.doc} RU06XFUNBD_AddExtraFields
    Function responsible for injecting additional fields into the accounts receivable write-off panel.
    @type  Function
    @author eduardo.Flima
    @since 08/04/2025
    @version R14
    @param oPanel1  , Object    , Panel of the receive write-off
    @return oPanel1 , Object    , Panel of the receive write-off
/*/
Function RU06XFUNBD_AddExtraFields(oPanel1 as Object)
    Local aConUni		:= {}
    Local aAreaSx3 		:= {}
    Local cDesCurr 		:=""
    Local cDesCnt		:=""
    Local cTitCur		:=""
    Local cTitConUni	:=""
    Local cLegCnt		:=""

    aAreaSx3 := SX3->(GetArea())
        If SX3->(DbSeek("E1_CONUNI"))
            aConUni:=SEPARA(X3CBox(),";")
        Endif
        If SX3->(DbSeek("E1_MOEDA"))
            cTitCur	:=X3Titulo()
        Endif
        If SX3->(DbSeek("E1_CONUNI"))
            cTitConUni	:=X3Titulo()
        Endif
        If SX3->(DbSeek("E1_F5QCODE"))
            cLegCnt		:=X3Titulo()
        Endif
    SX3->(RestArea(aAreaSx3))	

    @ 041,004 SAY cTitCur 				SIZE 31,07 OF oPanel1 PIXEL //"Currency"
    @ 041,030 MSGET oCurrency VAR SE1->E1_MOEDA	F3 "CTO" SIZE 20,08 OF oPanel1 PIXEL HASBUTTON  When .F.
    oCurrency:lReadOnly := .T.		
    cDesCurr:=(Posicione("CTO",1,xFilial("CTO")+StrZero(SE1->E1_MOEDA,TamSX3("CTO_MOEDA")[1]),"CTO_DESC"))
    @ 041,050 MSGET cDesCurr SIZE 30,08 OF oPanel1 PIXEL When .F.
    @ 041,085 SAY cTitConUni 				SIZE 48,08 OF oPanel1 PIXEL //"Conv.units"
    @ 041,115 COMBOBOX oModSPB VAR SE1->E1_CONUNI ITEMS aConUni SIZE 30, 08 OF oPanel1 PIXEL When .F.

    @ 052,004 SAY cLegCnt 				SIZE 31,07 OF oPanel1 PIXEL //"Leg. Contr."
    @ 052,030 MSGET oLegCnt VAR SE1->E1_F5QCODE	F3 "F5Q" SIZE 20,08 OF oPanel1 PIXEL HASBUTTON  When .F.
    oLegCnt:lReadOnly := .T.		
    cDesCnt:=Iif(!EMPTY(SE1->E1_F5QCODE),Posicione("F5Q",2,XFILIAL("F5Q")+SE1->E1_F5QCODE,"F5Q_DESCR"),"")
    @ 052,085 MSGET cDesCnt SIZE 165,08 OF oPanel1 PIXEL When .F.

Return oPanel1


/*/{Protheus.doc} RU06XFUNBE
    Applies modifications to the write-off model when the write-off is performed via the bank statement process.
    @type  Function
    @author eduardo.Flima
    @since 08/04/2025
    @version R14
    @param oModelBx     , Object    , write-off model
    @param cHistCan070  , Character , history of the write-off Cancelation
    @param aAutoCab     , Array     , Array with write-off Data
/*/
Function RU06XFUNBE_SetWriteOffBS(oModelBx As Object ,cHistCan070 as Character,aAutoCab as Array)
    Local x AS Numeric 
    oModelBx:SetValue( "MASTER", "E5_OPERACAO", 1 )//Russia - keep all lines equal do BS cancel bank moviment.
    If aScan(aAutoCab,{|x| x[1] == 'AUTRECORD'}) > 0 // Is Bank  statement process
        x := aScan(aAutoCab,{|x| x[1] == 'AUTHIST'})   //Try to find history text line
        cHistCan070 := IIF(x > 0, aAutoCab[x][2], cHistCan070)
    EndIf    
Return 



/*/{Protheus.doc} RU06XFUNBF_VLDMOTBAIXA
    Check if the writeoff should be allowed for exchange rate generation 
    @type  Function
    @author eduardo.Flima
    @since 24/04/2025
    @version R14
    @param aAutoCab     , array , Array with the write-off configurations 
    @return lVldMotBx   , Logical   , If we will perform the write-off reason validation 
/*/
Function RU06XFUNBF_VLDMOTBAIXA(aAutoCab as array)
    Local lVldMotBx as Logical
    Local nT as Numeric
    lVldMotBx   :=.T.
    nT          := 0
    If FwIsInCallStack("F084Grava") 
        nT      := ascan(aAutoCab, {|x| x[1]='AUTMOTBX'})
        If nT > 0 .and. aAutoCab[nT,2] == "DIF" 
            lVldMotBx   :=.F.
        endiF
    Endif 
Return lVldMotBx

/*/{Protheus.doc} RU06XFUNBG
    MacroExecuts Field in temporary table
    @type  Static Function
    @author eduardo.Flima
    @since 28/06/2025
    @version 28/06/2025
    @param cAlias   , Character , Alias of the table ex E1, E2
    @param cTable   , Character , Name of the table  ex SE1, SE2
    @param cField   , Character , Name of the Field
/*/
Static Function RU06XFUNBG_MacroexecuteField(cAlias as Character ,cTable as Character ,cField as Character)
    Replace &(CALIAS+cField) 	 With &(cTable+'->'+calias+cField)
Return 

/*/{Protheus.doc} RU06XFUNBH_SetLegalContractVar
    Function responsible for setting the legal contract variables for the monetary revaluation routine
    @type  Function
    @author eduardo.Flima
    @since 28/06/2025
    @version R14
    @param cKey     , Character , The key is similar: "xFilial("SE2")+TRB->E2_PREFIXO+TRB->E2_NUM+TRB->E2_PARCELA+TRB->E2_TIPO+TRB->E2_FORNECE+TRB->E2_LOJA"
    @param cNatPar  , Character , Class set in the original function
    @param cF5qcode , Character , Legal contract Code
    @param cF5quid  , Character , Legal contract UUID
    @param cNatureza, Character , Class used in Legal Contract
/*/
Function RU06XFUNBH_SetLegalContractVar(cKey as Character, cNatPar as Character, cF5qcode as Character,  cF5quid as Chacacter, cNatureza as Character)
    Local aSE2ap as Array
    Default cNatPar := ""
	aSE2ap := getArea()
    DbSelectArea("SE2")  
    dbSetOrder(1)
    If DbSeek(xFilial("SE2")+cKey) 
        cF5qcode    := SE2->E2_F5QCODE
        cF5quid     := SE2->E2_F5QUID
        IF Empty(cNatPar)
            cNatureza := SE2->E2_NATUREZ
        Else
            cNatureza := cNatPar
        EndIf
    EndIf
	RestArea(aSE2ap)   
Return 
