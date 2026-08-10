#INCLUDE "PROTHEUS.CH"

#Define IS_CANCEL_PAYMENT "1" // F5D_CANCEL = "Yes".
#Define NO_CANCEL_PAYMENT "2" // F5D_CANCEL = "No.

/*/
{Protheus.doc} RUTaxDeduction
    A wrapper class to tax deduction (F5D entry)

    @type Class
    @author dtereshenko
    @since 2021/03/19
    @version 12.1.23
/*/
Class RUTaxDeduction From LongNameClass
    Data cFil As Char
    Data cMat As Char
    Data cF5CId As Char
    Data cType As Char
    Data cDeductionCode As Char
    Data cProcess As Char
    Data cRoteir As Char
    Data cPeriod As Char
    Data cPaymentNumber As Character
    Data nPaidSum As Numeric
    Data nSumToPay As Numeric
    Data nSumPayment As Numeric
    Data lCancelPayment As Logical

    Data lFromSRB As Logical

    Method New() Constructor
EndClass

/*/
{Protheus.doc} New()
    Default RUTaxDeduction constructor, fills its fields from the positioned F5D entry

    @type Method
    @params 
    @author dtereshenko
    @since 2021/03/19
    @version 12.1.23
    @return RUTaxDeduction,    Object,    RUTaxDeduction instance
/*/
Method New(cTableName) Class RUTaxDeduction

    If !Empty(cTableName)
        If !Empty((cTableName)->F5D_COD)                    // Create object from F5D record
            ::cFil := (cTableName)->F5D_FILIAL
            ::cMat := (cTableName)->F5D_MAT
            ::cF5CId := (cTableName)->F5D_COD
            ::cDeductionCode := (cTableName)->F5D_DEDCODE
            ::cPaymentNumber := (cTableName)->F5D_NUMPAG
            ::nPaidSum := (cTableName)->F5D_INCPER
            ::nSumToPay := (cTableName)->F5D_INCRES
            ::nSumPayment := 0 // (cTableName)->F5D_SUMPAY
            ::lCancelPayment := NO_CANCEL_PAYMENT //(cTableName)->F5D_CANCEL
        Else                                                // Create object from F5C record
            ::cFil := (cTableName)->F5C_FILIAL
            ::cMat := (cTableName)->F5C_MAT
            ::cF5CId := (cTableName)->F5C_COD
            ::cDeductionCode := (cTableName)->F5C_DEDCODE
            ::cPaymentNumber := "0"
            ::nPaidSum := 0
            ::nSumToPay := (cTableName)->F5C_INCOME
            ::nSumPayment := 0
            ::lCancelPayment := NO_CANCEL_PAYMENT
        EndIf
        ::lFromSRB := .F.
    EndIf
Return Self
