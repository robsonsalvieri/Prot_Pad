#INCLUDE "PROTHEUS.CH"    
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#include "TOTVS.CH"
#include "RU06D07.CH"
#Include "RWMAKE.CH"
#Define   S_CREATED        "1"
#Define   S_FIN_POS        "2"
#Define   S_REVERSED       "3"
#Define   S_REPLACEMENT    "4"
#Define   S_REPL_POST      "5"
#Define   S_REPL_REV       "6"
#Define   LP_530_AP_WROFF  "530" //lanpad 530 AP Write-off
#Define   LP_531_AP_CWRFF  "531" //lanpad 531 AP Cancel Write-off
#Define   LP_570_ACCTPOST  "570" //lanpad 570 Account post
#Define   LP_571_CNCLACPS  "571" //lanpad 571 Cancel account post
#Define   LP_5BI_AP_PRPCN  "5BI" //lanpad 5BI AP Prepay cancellation
#Define   LP_5BB_AP_PRPST  "5BB" //lanpad 5BB Ap Prepay posting
#Define   LP_575_INFACCPS  "575" //lanpad 575 Account post Header (Inflow BS)
#Define   LP_576_INFCACCP  "576" //lanpad 576 Unpost Account Post Header (Inflow BS)
#Define   LP_520_AR_WROFF  "520" //lanpad 520 Receivables Write Off
#Define   LP_527_AR_CWRFF  "527" //lanpad 527 Cancel Receivables Write Off
#Define   LP_5BP_AR_RAPST  "5BP" //lanpad 5BP Accounts Receivable - Advance Receipt Generated (RA)
#Define   LP_5BW_AR_RACNC  "5BW" //lanpad 5BW Accounts Receivable - Advance Receipt Generated Cancellation (RA)
#Define   IS_INFLOWBANKST  "1"   //"1" for Inflow  BS
#Define   IS_OUTFLOWBANKS  "2"   //"2" for Outflow BS
#Define   IT_RETURNFROMSP  IS_INFLOWBANKST+"|2" //Return from supplier for Inflow BS, 2 stored in SX5 in X5_TABELA "EY", X5_CHAVE ="2"
#Define   OT_PAYMENTTOSUP  IS_OUTFLOWBANKS+"|1" //Payment to supplier for Outflow BS
#Define   X5_TABFOROUTTYP  "EX" //X5_TABELA for Outflow BS types
#Define   X5_TABFORINFTYP  "EY" //X5_TABELA for Inflow  BS types

Static lUsaFlag	:= SuperGetMV("MV_CTBFLAG"  ,;
                              .T. /*lHelp*/ ,;
                              .F. /*cPadrao*/)
Static __cTabHdr := "F4C"
Static __cMdlHdr := "RU06D07_MHEAD"
// Function IsBlind returns .F. if BS ru06d07 is called from other routine with interface
// For calling routine in blind mod use this variable and functions RU06D07739_SetAutoBs(.T.) RU06D07740_GetAutoBs()
Static lAutoBS := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D07
Bank Statement Routine 
@author Eduardo.Flima
@since 20/10/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D07()

    Private cCadastro  As Character
    Private aRotina    As Array

    aRotina		:= {}
    cCadastro := STR0001 //"Bank Statements"
Return (Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition
@author Eduardo.Flima
@since 20/10/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse 	as Object

oBrowse	:= FWmBrowse():New()
oBrowse:SetAlias("F4C")
oBrowse:SetDescription(STR0002) // Bank Statement  
oBrowse:SetMenuDef("RU06D07")
oBrowse:SetAttach(.T.)
oBrowse:AddLegend("F4C_STATUS  == '1'",;
                  "WHITE"                   ,  STR0003) // Created
oBrowse:AddLegend("F4C_STATUS  == '2' .AND. !(F4C_LA == 'S')",;
                  "BLUE"                    ,  STR0004) // Posted in Financial
oBrowse:AddLegend("F4C_STATUS  == '3' .AND. Empty(RU06XFUN49_CheckF4CUUIDRE(F4C_CUUID,.T.,.T.))",;
                  "RED"                     ,  STR0085) // Reversed in Financial
oBrowse:AddLegend("!Empty(RU06XFUN49_CheckF4CUUIDRE(F4C_CUUID,.T.,.T.))",;
                  "BLACK"                   ,  STR0142) // Replaced
oBrowse:AddLegend("F4C_STATUS  == '4'",;
                  "YELLOW"                  ,  STR0143) // Replacement
oBrowse:AddLegend("F4C_STATUS  == '5' .AND. !(F4C_LA == 'S')",;
                  "ORANGE"                  ,  STR0144) // Replacement and posted
oBrowse:AddLegend("F4C_STATUS  == '6'",;
                  "PINK"                    ,  STR0145) // Replacement and reversed
oBrowse:AddLegend("F4C_LA == 'S' ",;
                  "GREEN"                   ,  STR0005) // Posted in Accounting
oBrowse:SetExecuteDef(1) //1 - View

aRotina := Nil // needed for MSDOCUMENT
oBrowse:SetCacheView(.F.)// needed for MSDOCUMENT
Return (oBrowse) 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition
@author natalia.khozyainova
@since 24/10/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()

Local aRotina As Array
Local aTrack  As Array

aRotina := {}
aTrack  := {}

ADD OPTION aTrack Title STR0147   ;  	 
                                    ACTION "RU06D0710_Act(7)";
                                                                OPERATION MODEL_OPERATION_VIEW;
                                                                            ACCESS 0   
ADD OPTION aTrack Title STR0148   ;
                                    ACTION "RU06D0710_Act(8)";
                                                                OPERATION MODEL_OPERATION_VIEW;
                                                                            ACCESS 0
ADD OPTION aTrack Title STR0160  ; //Accounting track 
                                    ACTION "RU06D07008_AccountingTrack()";
                                                                OPERATION MODEL_OPERATION_VIEW;
                                                                            ACCESS 0
ADD OPTION aRotina TITLE STR0007    ACTION "RU06D0710_Act(1)"   OPERATION 1 ACCESS 0   // View
ADD OPTION aRotina TITLE STR0008    ACTION "RU06D0710_Act(3)"   OPERATION 3 ACCESS 0   // Add
ADD OPTION aRotina TITLE STR0009    ACTION "RU06D0710_Act(4)"   OPERATION 4 ACCESS 0   // Edit
ADD OPTION aRotina TITLE STR0010    ACTION "RU06D0710_Act(5)"   OPERATION 5 ACCESS 0   // Delete
ADD OPTION aRotina TITLE STR0011    ACTION "MSDOCUMENT"         OPERATION 4 ACCESS 0   // Knowledge (Upload Documents)
ADD OPTION aRotina TITLE STR0012    ACTION "RU06D0710_Act(9)"   OPERATION 9 ACCESS 0   // Copy
ADD OPTION aRotina TITLE STR0006    ACTION "RU06D0711_Legend"   OPERATION 7 ACCESS 0   // Legend
ADD OPTION aRotina TITLE STR0042 +;
                         STR0044 +;
                         STR0045    ACTION "RU06D0731_ViewFPost(1)"  OPERATION 4 ACCESS 0 //Post in Financial
ADD OPTION aRotina TITLE STR0043 +;
                         STR0044 +;
                         STR0045    ACTION "RU06D0731_ViewFPost(2)"  OPERATION 4 ACCESS 0 //UnPost in Financial
ADD OPTION aRotina TITLE STR0086 +;
                         STR0044 +;
                         STR0045    ACTION "RU06D0731_ViewFPost(3)"  OPERATION 4 ACCESS 0 //Reverse FinPost
ADD OPTION aRotina TITLE STR0143  ;
                                    ACTION "RU06D0731_ViewFPost(4)"  OPERATION 4 ACCESS 0 //Replacement
ADD OPTION aRotina Title STR0146  ;
                                    ACTION  aTrack                   OPERATION MODEL_OPERATION_VIEW;
                                                                                 ACCESS 0 // Track
ADD OPTION aRotina Title STR0161  ; 
                                    ACTION "RU06D07009_PostInAccounting(.T.)" OPERATION MODEL_OPERATION_UPDATE;
                                                                                 ACCESS 0 //Post in accounting
ADD OPTION aRotina TITLE STR0008 +;
                         STR0113 ACTION "RU06D0715_TaxAgVAT(1)"      OPERATION 4 ACCESS 0 //Add  Tax Agent VAT Invoice
ADD OPTION aRotina TITLE STR0007 +;
                         STR0112 ACTION "RU06D0715_TaxAgVAT(2)"      OPERATION MODEL_OPERATION_VIEW;
                                                                                 ACCESS 0 //View Tax Agent VAT Invoice
 
Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition
@author natalia.khozyainova
@since 24/10/2018
@version 1.0
@project MA3 - Russia
Private cOperDirection Character
/*/
Static Function ModelDef()
Local oStrF4C 	as Object
Local oStrF5M 	as Object
Local oStrVirt  as Object
Local lObrig    as Logical
Local oUpdF4CEvent 	:= RU06D07EventRUS():New()

oModel:= MPFormModel():New("RU06D07",/*Pre-validation*/,/*Pos-validation*/,;
                           /*commit*/{|oModel| RU06D0747_CommitModel(oModel)},;
                           /*Cancel*/)
oModel:SetDescription("BSModel_Main") // Bank Statements

// Header structure - F4C Bank Statement - Header
oStrF4C := FWFormStruct(1, "F4C")
oStrF4C:SetProperty("F4C_OPER"  , MODEL_FIELD_INIT   , {|| RU06D0709_PayType(.T.,"F4C_OPER"     )})
oStrF4C:SetProperty("F4C_PAYTYP", MODEL_FIELD_INIT   , {|| RU06D0709_PayType(.T.,"F4C_PAYTYP"   )})
oStrF4C:SetProperty("F4C_RECTYP", MODEL_FIELD_INIT   , {|| RU06D0709_PayType(.T.,"F4C_RECTYP"   )})
oStrF4C:SetProperty("F4C_CUUID" , MODEL_FIELD_INIT   , {|| FWUUIDV4(.F.) }) // unique ID 32 symbols
oStrF4C:SetProperty("F4C_OPER"  , MODEL_FIELD_WHEN   , {|| .F. })
oStrF4C:SetProperty("F4C_ITTOTA", MODEL_FIELD_INIT   , {|oModel| IIf(FWFldGet("F4C_OPER")=="1",RU06D07019_LoadVirtSums("ITTOTA"/*cField*/),0)})
oStrF4C:SetProperty("F4C_ITVATF", MODEL_FIELD_INIT   , {|oModel| IIf(FWFldGet("F4C_OPER")=="1",RU06D07019_LoadVirtSums("ITVATF"/*cField*/),0)})
oStrF4C:SetProperty("F4C_ITVATO", MODEL_FIELD_INIT   , {|oModel| IIf(FWFldGet("F4C_OPER")=="1",RU06D07019_LoadVirtSums("ITVATO"/*cField*/),0)})
oStrF4C:SetProperty("F4C_ITBALA", MODEL_FIELD_INIT   , {|oModel| IIf(FWFldGet("F4C_OPER")=="1",RU06D07019_LoadVirtSums("ITBALA"/*cField*/),0)})
If Type("cOperDirection") == "C"
    lObrig := IIf(StrTokArr(cOperDirection,"|")[1] == "1",.T.,.F.)
    //lObrig == .T. - Inflow; lObrig == .F. - Outflow
    oStrF4C:SetProperty("F4C_CUST", MODEL_FIELD_OBRIGAT,  lObrig)
    oStrF4C:SetProperty("F4C_CUNI", MODEL_FIELD_OBRIGAT,  lObrig)
    oStrF4C:SetProperty("F4C_SUPP", MODEL_FIELD_OBRIGAT, !lObrig)
    oStrF4C:SetProperty("F4C_UNIT", MODEL_FIELD_OBRIGAT, !lObrig)
EndIf

// Add triggers to F4C model
oStrF4C:AddTrigger("F4C_CURREN","F4C_CURNAM",,{|| POSICIONE("CTO",1,xFilial("CTO")+FwFldGet("F4C_CURREN"),"CTO_DESC")})
// add triggers to supplier and supplier unit
oStrF4C:AddTrigger("F4C_SUPP","F4C_UNIT"  ,,{ |oModel| RU06D0548_GatForn("F4C_UNIT",__cMdlHdr)  })
oStrF4C:AddTrigger("F4C_SUPP","F4C_SUPNAM",,{ |oModel| RU06D0548_GatForn("F4C_SUPNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_SUPP","F4C_KPPREC",,{ |oModel| RU06D0548_GatForn("F4C_KPPREC",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_UNIT","F4C_SUPNAM",,{ |oModel| RU06D0548_GatForn("F4C_SUPNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_UNIT","F4C_KPPREC",,{ |oModel| RU06D0548_GatForn("F4C_KPPREC",__cMdlHdr)})
//add triggers to customer and customer unit
oStrF4C:AddTrigger("F4C_CUST","F4C_CUNI"  ,,{ |oModel| RU06D07037_GatCust("F4C_CUNI")  })
oStrF4C:AddTrigger("F4C_CUST","F4C_CUSNAM",,{ |oModel| RU06D07037_GatCust("F4C_CUSNAM")})
oStrF4C:AddTrigger("F4C_CUST","F4C_KPPPAY",,{ |oModel| RU06D07037_GatCust("F4C_KPPPAY")})
oStrF4C:AddTrigger("F4C_CUNI","F4C_CUSNAM",,{ |oModel| RU06D07037_GatCust("F4C_CUSNAM")})
oStrF4C:AddTrigger("F4C_CUNI","F4C_KPPPAY",,{ |oModel| RU06D07037_GatCust("F4C_KPPPAY")})

//add autofilling bank related fields. F4C_PAYNAM or F4C_RECNAM fields should be last in the triggers

oStrF4C:AddTrigger("F4C_CURREN","F4C_BNKPAY",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D05493_GatBankPay("F4C_BNKPAY",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CURREN","F4C_PAYBIK",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D05493_GatBankPay("F4C_PAYBIK",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CURREN","F4C_PAYACC",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D05493_GatBankPay("F4C_PAYACC",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CURREN","F4C_TYPCP" ,{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D05493_GatBankPay("F4C_TYPCP" ,__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CURREN","F4C_BKPNAM",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D05493_GatBankPay("F4C_BKPNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CURREN","F4C_ACPNAM",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D05493_GatBankPay("F4C_ACPNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CURREN","F4C_PAYNAM",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D05493_GatBankPay("F4C_PAYNAM",__cMdlHdr)})

oStrF4C:AddTrigger("F4C_CURREN","F4C_BNKREC",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D05493_GatBankPay("F4C_BNKREC",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CURREN","F4C_RECBIK",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D05493_GatBankPay("F4C_RECBIK",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CURREN","F4C_RECACC",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D05493_GatBankPay("F4C_RECACC",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CURREN","F4C_TYPCC" ,{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D05493_GatBankPay("F4C_TYPCC" ,__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CURREN","F4C_BKRNAM",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D05493_GatBankPay("F4C_BKRNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CURREN","F4C_ACRNAM",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D05493_GatBankPay("F4C_ACRNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CURREN","F4C_RECNAM",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D05493_GatBankPay("F4C_RECNAM",__cMdlHdr)})

oStrF4C:AddTrigger("F4C_SUPP","F4C_BNKREC",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_BNKREC",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_SUPP","F4C_RECBIK",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_RECBIK",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_SUPP","F4C_RECACC",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_RECACC",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_SUPP","F4C_TYPCC" ,{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_TYPCC", __cMdlHdr)})
oStrF4C:AddTrigger("F4C_SUPP","F4C_BKRNAM",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_BKRNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_SUPP","F4C_ACRNAM",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_ACRNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_SUPP","F4C_RECNAM",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_RECNAM",__cMdlHdr)})

oStrF4C:AddTrigger("F4C_UNIT","F4C_BNKREC",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_BNKREC",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_UNIT","F4C_RECBIK",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_RECBIK",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_UNIT","F4C_RECACC",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_RECACC",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_UNIT","F4C_TYPCC" ,{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_TYPCC", __cMdlHdr)})
oStrF4C:AddTrigger("F4C_UNIT","F4C_BKRNAM",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_BKRNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_UNIT","F4C_ACRNAM",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_ACRNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_UNIT","F4C_RECNAM",{|| (FwFldGet("F4C_OPER") == "2")},{ |oModel| RU06D07039_GatBankRec("F4C_RECNAM",__cMdlHdr)})

oStrF4C:AddTrigger("F4C_CUST","F4C_BNKPAY",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_BNKPAY",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CUST","F4C_PAYBIK",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_PAYBIK",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CUST","F4C_PAYACC",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_PAYACC",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CUST","F4C_TYPCP" ,{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_TYPCP", __cMdlHdr)})
oStrF4C:AddTrigger("F4C_CUST","F4C_BKPNAM",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_BKPNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CUST","F4C_ACPNAM",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_ACPNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CUST","F4C_PAYNAM",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_PAYNAM",__cMdlHdr)})

oStrF4C:AddTrigger("F4C_CUNI","F4C_BNKPAY",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_BNKPAY",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CUNI","F4C_PAYBIK",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_PAYBIK",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CUNI","F4C_PAYACC",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_PAYACC",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CUNI","F4C_TYPCP" ,{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_TYPCP", __cMdlHdr)})
oStrF4C:AddTrigger("F4C_CUNI","F4C_BKPNAM",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_BKPNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CUNI","F4C_ACPNAM",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_ACPNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_CUNI","F4C_PAYNAM",{|| (FwFldGet("F4C_OPER") == "1")},{ |oModel| RU06D07038_GatBankPay("F4C_PAYNAM",__cMdlHdr)})

oStrF4C:AddTrigger("F4C_BNKREC","F4C_RECBIK",,{ |oModel| RU06D07039_GatBankRec("F4C_RECBIK",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_BNKREC","F4C_RECACC",,{ |oModel| RU06D07039_GatBankRec("F4C_RECACC",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_BNKREC","F4C_TYPCC" ,,{ |oModel| RU06D07039_GatBankRec("F4C_TYPCC", __cMdlHdr)})
oStrF4C:AddTrigger("F4C_BNKREC","F4C_BKRNAM",,{ |oModel| RU06D07039_GatBankRec("F4C_BKRNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_BNKREC","F4C_ACRNAM",,{ |oModel| RU06D07039_GatBankRec("F4C_ACRNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_BNKREC","F4C_RECNAM",,{ |oModel| RU06D07039_GatBankRec("F4C_RECNAM",__cMdlHdr)})

oStrF4C:AddTrigger("F4C_RECACC","F4C_TYPCC" ,,{ |oModel| RU06D07039_GatBankRec("F4C_TYPCC", __cMdlHdr)})
oStrF4C:AddTrigger("F4C_RECACC","F4C_BKRNAM",,{ |oModel| RU06D07039_GatBankRec("F4C_BKRNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_RECACC","F4C_ACRNAM",,{ |oModel| RU06D07039_GatBankRec("F4C_ACRNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_RECACC","F4C_RECNAM",,{ |oModel| RU06D07039_GatBankRec("F4C_RECNAM",__cMdlHdr)})

oStrF4C:AddTrigger("F4C_BNKPAY","F4C_PAYBIK",,{ |oModel| RU06D07038_GatBankPay("F4C_PAYBIK",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_BNKPAY","F4C_PAYACC",,{ |oModel| RU06D07038_GatBankPay("F4C_PAYACC",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_BNKPAY","F4C_TYPCP" ,,{ |oModel| RU06D07038_GatBankPay("F4C_TYPCP", __cMdlHdr)})
oStrF4C:AddTrigger("F4C_BNKPAY","F4C_BKPNAM",,{ |oModel| RU06D07038_GatBankPay("F4C_BKPNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_BNKPAY","F4C_ACPNAM",,{ |oModel| RU06D07038_GatBankPay("F4C_ACPNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_BNKPAY","F4C_PAYNAM",,{ |oModel| RU06D07038_GatBankPay("F4C_PAYNAM",__cMdlHdr)})

oStrF4C:AddTrigger("F4C_PAYACC","F4C_TYPCP" ,,{ |oModel| RU06D07038_GatBankPay("F4C_TYPCP", __cMdlHdr)})
oStrF4C:AddTrigger("F4C_PAYACC","F4C_BKPNAM",,{ |oModel| RU06D07038_GatBankPay("F4C_BKPNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_PAYACC","F4C_ACPNAM",,{ |oModel| RU06D07038_GatBankPay("F4C_ACPNAM",__cMdlHdr)})
oStrF4C:AddTrigger("F4C_PAYACC","F4C_PAYNAM",,{ |oModel| RU06D07038_GatBankPay("F4C_PAYNAM",__cMdlHdr)})


oModel:AddFields("RU06D07_MHEAD", NIL, oStrF4C)
oModel:GetModel("RU06D07_MHEAD"):SetDescription("BSModel_HeadF4C") // Bank Statement head submodel
oModel:GetModel("RU06D07_MHEAD"):SetFldNoCopy({"F4C_FILIAL","F4C_CUUID" ,"F4C_DTTRAN" ,"F4C_PAYORD",;
                                               "F4C_IDF49" ,"F4C_STATUS","F4C_UUIDRE" ,"F4C_INTNUM",;
                                               "F4C_LA"    ,"F4C_DTREVE","F4C_DTREPL"              })
// Items structure - F5M - Lines Real Hidden Grid
oStrF5M := FWFormStruct(1, "F5M")
oModel:AddGrid("RU06D07_MLNS", "RU06D07_MHEAD", oStrF5M)
oModel:GetModel("RU06D07_MLNS"):SetDescription("BSModel_LinesF5M")
oModel:GetModel('RU06D07_MLNS'):SetOptional(.T.)
oModel:SetRelation("RU06D07_MLNS", {{ "F5M_FILIAL", "xFilial('F5M')" }, { "F5M_IDDOC", "F4C_CUUID", } }, F5M->( IndexKey( 1 ) ) )
oModel:GetModel("RU06D07_MLNS"):SetFldNoCopy(RU06D0540_Array(oModel:GetModel("RU06D07_MLNS")))
oStrVirt := RU06D0525_DefVirtStr()
RU06D0780_TuneVrtModelStructure(oStrVirt)
oModel:AddGrid("RU06D07_MVIRT", "RU06D07_MHEAD", oStrVirt, /*bPreValid*/, /*bPosValid*/	,,, {|oModel| RU06D0713_VirtGridLoad(oModel)}/*bLoad*/ )
oModel:GetModel("RU06D07_MVIRT"):SetDescription("BSModel_LinesVirt") 
oModel:GetModel('RU06D07_MVIRT'):SetOptional(.T.)
oModel:GetModel("RU06D07_MVIRT"):SetFldNoCopy(RU06D0540_Array(oModel:GetModel("RU06D07_MVIRT")))

oModel:InstallEvent("RU06D07_Event",,oUpdF4CEvent)

Return (oModel)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0780_TuneVrtModelStructure

Function for tuning virtual grid structure

@param       <Parameter type> <Parameter name>
@return      Logical          lRet
@example     
@author      astepanov
@since       July/26/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0780_TuneVrtModelStructure(oStrVrt)

    Local lRet       As Logical
    Local aFields    As Array
    Local aVldFlds   As Array
    Local nX         As Numeric
    Local nY         As Numeric
    lRet := .T.
    
    aFields := oStrVrt:GetFields()
    // make all fields unchangable [nX][8] = bWhen
    For nX := 1 To Len(aFields)
        aFields[nX][8] := {|| .F.}
    Next nX
    // define fields which can be changed by user but should be validated
    // in method GridLinePosVld in RU06D07EventRUS file
    aVldFlds := {"B_CHECK", "B_VALPAY", "B_EXGRAT", "B_BSVATC", "B_VLVATC", "B_VALCNV", "B_RATUSR", "B_VLIMP1", "B_BSIMP1"}
    For nX := 1 To Len(aVldFlds)
        For nY := 1 To Len(aFields)
            If aVldFlds[nX] == aFields[nY][3]
                aFields[nY][8] := {|| .T.}
                Exit
            EndIf
        Next nY
    Next nX
    
Return (lRet) /*-------------------------------------------RU06D0780_TuneVrtModelStructure*/




//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0759_RecalcValue
Function used for validation F4C_VALUE, it is located in X3_VALID field.
If F4C_VALUE equals sum of B_VALCNV of virtual grid it returns .T., in other case
we check document status if it is "1" or "4", function will try to add new AP line
to virtual grid with status "PA", or decrese amount of "PA" line, or increase amount of
"PA" line, or delete "PA" line, in other case it will return .F.

@param       Logical          lAskPA      // ask about PA creation(.F.) or not(.T.) 
             Logical          lNoRClcVAT  // Don't recalc VAT amount
@return      Logical          lRet
@example     
@author      astepanov
@since       July/24/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0759_RecalcValue(lAskPA, lNoRClcVAT)

    Local lRet       As Logical
    Local lAutoIns   As Logical
    Local oModel     As Object
    Local oModelF4C  As Object
    Local oModelVrt  As Object
    Local oGridMdl   As Object
    Local oTmp       As Object
    Local cErrMsg    As Character
    Local cPA        As Character
    Local nSaldo     As Numeric
    Local nNewVal    As Numeric
    Local nX         As Numeric
    Local nLinePA    As Numeric
    Local nPAVal     As Numeric
    Local nVATRAT    As Numeric
    Local nVATbLns   As Numeric
    Local aTotals    As Array

    Default lAskPA     := .F.
    Default lNoRClcVAT := .F.

    lRet       := .T.
    cErrMsg    := ""
    oModel     := FWModelActive()
    oModelF4C  := oModel:GetModel("RU06D07_MHEAD")
    lAutoIns   := RU06D07036_GetlAutoIns()
    lInflow := (FWFldGet("F4C_OPER") == "1")
    If lAutoIns
        If FWFldGet("F4C_OPER") == "2"
            cPA        := "PA" // payment in advance indicator
            oModelVrt  := oModel:GetModel("RU06D07_MVIRT")
            nSaldo     := oModelF4C:GetValue("F4C_VALUE")
            nX         := 1
            nLinePA    := 0
            nPAVal     := 0
            nVATbLns   := 0
            oModelVrt:SetNoInsertLine(.F.)
            While nX <= oModelVrt:Length()  .AND.;
                oModelVrt:GoLine(nX) > 0
                nLinePA   := IIF(!oModelVrt:IsDeleted(nX) .AND.;
                                AllTrim(oModelVrt:GetValue("B_TYPE")) == cPA,;
                                nX, 0                               )
                nPAVal    := IIF(nLinePA > 0, oModelVrt:GetValue("B_VALCNV"), 0)
                nSaldo    := IIF(oModelVrt:IsDeleted(nX),nSaldo        ,;
                                nSaldo - oModelVrt:GetValue("B_VALCNV"))
                nVATbLns  += IIF(!oModelVrt:IsDeleted(nX),; 
                                oModelVrt:GetValue("B_VLVATC"),0)
                nX := nX + 1
            EndDo
            nNewVal   := nSaldo     + nPAVal
            If     nSaldo == 0
                lRet := .T.
            ElseIf nSaldo > 0 .AND. nNewVal > 0 .AND. nLinePA > 0 //increase PA
                // case: F4C_VALUE = 15000, SUM(B_VALCNV) = 13000
                // PA Value = 1000, nSaldo == 15000-13000 = 2000, nNewVal = 3000
                If lRet
                    // call function for updating line with PA type
                    oModelVrt:GoLine(nLinePA)
                    oModelVrt:LoadValue("B_VALCNV",nNewVal )
                    nVATRAT := IIF(Empty(oModelF4C:GetValue("F4C_VATRAT")),;
                                    0,oModelF4C:GetValue("F4C_VATRAT")   )
                    nNewVAT := RU06XFUN18_VATFormula(oModelVrt:GetValue("B_VALCNV"),;
                                {nVATRAT,100},;
                                GetSX3Cache("F5M_VLVATC", "X3_DECIMAL"),;
                                .T.                                                 )
                    oModelVrt:LoadValue("B_VLVATC",nNewVAT)
                    oModelVrt:LoadValue("B_BSVATC",nNewVAl - nNewVAT)
                    RU06D07E6_UpdateVlsForPA("B_VALCNV", nNewVal,;
                                            oModelVrt:GetValue("B_VLVATC"),;
                                            oModelVrt,;
                                            oModelF4C                      )
                EndIf
            ElseIf nSaldo > 0 .AND. nNewVal > 0 .AND. nLinePA == 0 //insert PA
                // case: F4C_VALUE = 10000, SUM(B_VALCNV) = 8000
                // PA value = 0, nSaldo = 2000, nNewVal = 2000
                // so we should insert new line with PA
                If !Empty(oModelF4C:GetValue("F4C_PAYORD"))
                    nNewVAT := oModelF4C:GetValue("F4C_VATAMT") - nVATbLns
                Else
                    nVATRAT := IIF(Empty(oModelF4C:GetValue("F4C_VATRAT")),;
                                    0,oModelF4C:GetValue("F4C_VATRAT")   )
                    If lNoRClcVAT // used for replacement
                        nNewVAT := oModelF4C:GetValue("F4C_VATAMT") - nVATbLns
                    Else
                        nNewVAT := RU06XFUN18_VATFormula(nNewVal,;
                                    {nVATRAT,100},;
                                    GetSX3Cache("F5M_VLVATC", "X3_DECIMAL"),;
                                    .T.                                     )
                    EndIf
                EndIf
                If !IsBlind() .And. !RU06D07740_GetAutoBs() .AND. !lAskPA
                    // ask about inserting PA line
                    lRet := MsgYesNo(STR0131;  // We will generate an advance payment of 
                                    + cValToChar(nNewVal),;
                                    STR0130 ) //PAYMENT IN ADVANCE
                EndIf
                If lRet
                    // call functions for inserting line with PA type
                    oTmp    := RU06XFUN47_CreateTmpTab1()[1]
                    cErrMsg := RU06D0753_PreparePALineForInputInOutflowBSGrid(oTmp     ,;
                                                                            oModelF4C,;
                                                                            "X",cPA  )
                    If !Empty(cErrMsg)
                        lRet := .F.
                    EndIf
                    If lRet
                        lRet := RU06D0722_WriteFromMBr(oTmp, Nil, "X", cPA, nNewVal, nNewVAT)
                    EndIf
                EndIf
            ElseIf nSaldo < 0 .AND. nNewVal >= 0 .AND. nLinePA > 0
                // case F4C_VALUE = 3600, SUM(B_VALCNV) = 5200
                // PA Value = 1750, nSaldo = -1600, nNewVal = 150
                // or PA Value = 1600, nSaldo = -1600, nNewVal = 0
                // call function for decreasing PA line value
                If nNewVal == 0                  // delete PA line  
                    //so we should delete these AP PA line
                    oModelVrt:GoLine(nLinePA)
                    oModelVrt:DeleteLine()
                Else                             // decrease PA values
                    //call function for decreasing values
                    oModelVrt:GoLine(nLinePA)
                    oModelVrt:LoadValue("B_VALCNV",nNewVal)
                    nVATRAT := IIF(Empty(oModelF4C:GetValue("F4C_VATRAT")),;
                                    0,oModelF4C:GetValue("F4C_VATRAT")   )
                    nNewVAT := RU06XFUN18_VATFormula(nNewVal,;
                                {nVATRAT,100},;
                                GetSX3Cache("F5M_VLVATC", "X3_DECIMAL"),;
                                .T.                                     )
                    oModelVrt:LoadValue("B_VLVATC",nNewVAT)
                    oModelVrt:LoadValue("B_BSVATC",nNewVAl - nNewVAT)
                    RU06D07E6_UpdateVlsForPA("B_VALCNV", nNewVal,;
                                            oModelVrt:GetValue("B_VLVATC"),;
                                            oModelVrt,;
                                            oModelF4C                      )
                EndIf
            Else   //other cases it will be mistake in value
                lRet := .F.
                cErrMsg := STR0133 //Error
            EndIf
            If lRet .AND. nSaldo != 0
                aTotals := RU06D07E7_RetTotalsForHeader(oModelVrt,"VRT")
                oModelF4C:LoadValue("F4C_VALUE" ,aTotals[1])
                oModelF4C:LoadValue("F4C_VATAMT",aTotals[2])
                If Empty(oModelF4C:GetValue("F4C_PAYORD"))
                    nX := oModelVrt:GetLine()
                    lRet := lRet .AND. RU06D0717_Rsn()
                    oModelVrt:GoLine(nX)
                EndIf
            EndIf
            //don't remove the line below. it locks adding new lines by user
            oModelVrt:SetNoInsertLine(.T.)
        ElseIf lInflow
            nSaldo     := oModelF4C:GetValue("F4C_VALUE")
            nVATRAT := IIF(Empty(oModelF4C:GetValue("F4C_VATRAT")),;
                                0,oModelF4C:GetValue("F4C_VATRAT")   )
            nNewVAT := RU06XFUN18_VATFormula(nSaldo,;
                                    {nVATRAT,100},;
                                    GetSX3Cache("F4C_VATAMT", "X3_DECIMAL"),;
                                    .T.                                     )
            oModelF4C:LoadValue("F4C_VATAMT",nNewVAT)
            oModelF4C:LoadValue("F4C_ITBALA",nSaldo - oModelF4C:GetValue("F4C_ITTOTA") )
        EndIf
    Else
        oGridMdl := oModel:GetModel("RU06D07_MLNS" )
        aTotals  := RU06D07E7_RetTotalsForHeader(oGridMdl, "F5M",lInflow)
        If oModelF4C:GetValue("F4C_VALUE")  != aTotals[1] .AND.;
           oModelF4C:GetValue("F4C_VATAMT") != aTotals[2]
            lRet := .F.
        Else
            lRet := .T.
        EndIf
    EndIf

    If !lRet
        If Empty(cErrMsg)
            HELP(Nil,Nil,Nil,RetTitle("F4C_VALUE"),;
                STR0017 + STR0052,Nil,; //BS - information
                STR0134,;               //FieldNotValidated
                1,0,,,,,,                                )   
        Else
            HELP(Nil,Nil,Nil,RetTitle("F4C_VALUE"),;
                STR0017 + STR0052,Nil,; //BS - information
                cErrMsg,;               //Error Message
                1,0,,,,,,                                )   
        EndIf
    EndIf
    
Return (lRet) /*-----------------------------------------------------RU06D0759_RecalcValue*/



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0753_PreparePALineForInputInOutflowBSGrid

This function called by RU06D0759_RecalcValue, and can be called from other function.
It puts in temporary table cretated by RU06XFUN47_CreateTmpTab1 one line with type "PA".
This temporary table in next step will be used by RU06D0722_WriteFromMBr for adding line
to virtual grid.

@param       <Parameter type> <Parameter name>
@return      Logical          lRet
@example     
@author      astepanov
@since       July/24/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0753_PreparePALineForInputInOutflowBSGrid(oTmp, oModelF4C, cMark, cPATyp)

    Local cRet       As Character
    Local cQuery     As Character
    Local cEmissao   As Character
    Local cVencrea   As Character
    Local cMoedaE2   As Character
    Local cConuni    As Character
    Local cSupp      As Character
    Local cSupUni    As Character
    Local cClass     As Character
    Local cF5QUID    As Character
    Local cF5QCode   As Character
    Local cE         As Character
    Local cForCli    As Character
    Local cDate      As Character
    Local nMoedaF4C  As Numeric
    Local nMoedaE2   As Numeric
    Local nStat      As Numeric
    Local lInflow    As Logical

    Default cMark    := "X"
    Default cPATyp   := "PA"

    cRet      := ""
    If Empty(oModelF4C:GetValue("F4C_DTREPL"))
        cDate := "F4C_DTTRAN"
    Else   
        cDate := "F4C_DTREPL"
    EndIf
    cEmissao  := DTOS(oModelF4C:GetValue(cDate))
    cVencrea  := DTOS(oModelF4C:GetValue(cDate))
    nMoedaF4C := Val(oModelF4C:GetValue("F4C_CURREN"))
    lInflow   := (oModelF4C:GetValue("F4C_OPER") == "1")
    cSupp     := Iif(lInflow,oModelF4C:GetValue("F4C_CUST"),oModelF4C:GetValue("F4C_SUPP"))
    cSupUni   := Iif(lInflow,oModelF4C:GetValue("F4C_CUNI"),oModelF4C:GetValue("F4C_UNIT"))
    cClass    := oModelF4C:GetValue("F4C_CLASS")
    cConuni   := ""
    cConuni   := Posicione("F5Q",1,xFilial("F5Q")          +;
                           oModelF4C:GetValue("F4C_UIDF5Q"),;
                           "F5Q_CONUNI"                     )
    cF5QUID   := ""
    cF5QUID   := oModelF4C:GetValue("F4C_UIDF5Q")
    cF5QDESCR := ""
    cF5QDESCR := Posicione("F5Q",1,xFilial("F5Q")          +;
                           oModelF4C:GetValue("F4C_UIDF5Q"),;
                           "F5Q_DESCR"                      )
    nMoedaE2  := Posicione("F5Q",1,xFilial("F5Q")          +;
                           oModelF4C:GetValue("F4C_UIDF5Q"),;
                           "F5Q_MOEDA"                      )
    nMoedaE2  := IIf(Empty(nMoedaE2),nMoedaF4C,nMoedaE2)
    cMoedaE2  := cValToChar(nMoedaE2)
    cF5QCode  := ""
    cF5QCode  := Posicione("F5Q",1,xFilial("F5Q")          +;
                           oModelF4C:GetValue("F4C_UIDF5Q"),;
                           "F5Q_CODE"                       )
    cE      := IIf(lInflow,"E1", "E2")
    cForCli := IIf(lInflow, "E1_CLIENTE", "E2_FORNECE")
    cQuery  := " INSERT INTO " + oTmp:GetRealName() + " (  "
    cQuery  += "    "+cE+"_OK     ,                            " //ok
    cQuery  += "    "+cE+"_FILIAL ,                            " //fl
    cQuery  += "    "+cE+"_PREFIXO,                            " //pr
    cQuery  += "    "+cE+"_NUM    ,                            " //nm
    cQuery  += "    "+cE+"_PARCELA,                            " //pa 
    cQuery  += "    "+cE+"_TIPO   ,                            " //ti
    cQuery  += "    "+cE+"_EMISSAO,                            " //em
    cQuery  += "    "+cE+"_VENCREA,                            " //vc
    cQuery  += "    CTO_MOEDA ,                                " //mo
    cQuery  += "    "+cE+"_CONUNI ,                            " //cu
    cQuery  += "    "+cE+"_VALOR  ,                            " //vl
    cQuery  += "    "+cE+"_BALANCE,                            " //bl
    cQuery  += "    "+cForCli+"   ,                            " //fn
    cQuery  += "    "+cE+"_LOJA   ,                            " //lj
    cQuery  += "    ADDS"+cE+"KEYC,                            " //ad
    cQuery  += "    "+cE+"_MOEDA  ,                            " //md
    cQuery  += "    "+cE+"_VALIMP1,                            " //vi
    cQuery  += "    "+cE+"_NATUREZ,                            " //na
    cQuery  += "    "+cE+"_VLCRUZ ,                            " //vc
    cQuery  += "    "+cE+"_ALQIMP1,                            " //aq
    cQuery  += "    "+cE+"_F5QUID ,                            " //qu
    cQuery  += "    F5Q_DESCR ,                                " //qd
    cQuery  += "    F5M_CTRBAL,                                " //cb
    cQuery  += "    F5Q_CODE  ,                                " //qo
    cQuery  += "    "+cE+"CUDIGTL ,                            " //cd
    cQuery  += "    F5M_FILIAL                              )  " //fi

    cQuery  += " VALUES                                 (  " //--
    cQuery  += " '"+cMark+"'         ,                     " //ok
    cQuery  += " '"+xFilial(Iif(lInflow,"SE1","SE2"))+"',  " //fl
    cQuery  += "  "+" ''             ,                     " //pr
    cQuery  += "  "+" ''             ,                     " //nm
    cQuery  += "  "+" ''             ,                     " //pa
    cQuery  += " '"+cPATyp+"'        ,                     " //ti
    cQuery  += " '"+cEmissao+"'      ,                     " //em
    cQuery  += " '"+cVencrea+"'      ,                     " //vc
    cQuery  += "  "+cMoedaE2+"       ,                     " //mo
    cQuery  += " '"+IIF(Empty(cConuni),"2",cConuni)+"',    " //cu
    cQuery  += "  "+"0"+"            ,                     " //vl
    cQuery  += "  "+"0"+"            ,                     " //bl
    cQuery  += " '"+cSupp+"'         ,                     " //fn
    cQuery  += " '"+cSupUni+"'       ,                     " //lj
    cQuery  += "  "+" ''             ,                     " //ad
    cQuery  += "  "+cMoedaE2+"       ,                     " //md
    cQuery  += "  "+"0"+"            ,                     " //vi
    cQuery  += " '"+cClass+"'        ,                     " //na
    cQuery  += "  "+"0"+"            ,                     " //vc
    cQuery  += "  "+"0"+"            ,                     " //aq
    cQuery  += " '"+cF5QUID+"'       ,                     " //qu
    cQuery  += " '"+cF5QDESCR+"'     ,                     " //qd
    //F5M_CTRBAL "1" - control balance, "2" - no balance control
    cQuery  += " '"+"2"+"'           ,                     " //cb
    cQuery  += " '"+cF5QCode+"'      ,                     " //qo
    cQuery  += " '"+IIF(Empty(cConuni),"2",cConuni)+"',    " //cd
    cQuery  += " '"+xFilial(Iif(lInflow,"SE1","SE2"))+"' ) " //fi
    nStat  := TCSqlExec(cQuery)
    If nStat < 0
        cRet := " TCSQLError() " + TCSQLError()
    EndIf
  
Return (cRet) /*----------------------------RU06D0753_PreparePALineForInputInOutflowBSGrid*/




//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.
@author natalia.khozyainova
@since 24/10/2018
@version 1.0
@project MA3 - Russia
Private cOperDirection As Character
/*/
Static Function ViewDef()
Local oView     as Object
Local oModel    as Object
Local oModelH   as Object
Local oModelAct as Object
Local oStrF4C   as Object
Local oStrVirt  as Object
Local cBSFlowDir As Character
Local aRmvFields As Array
Local lChView    As Logical
Local lInflowBS  As Logical
Local lRemRevFld As Logical
Local lRemRepFld As Logical
Local oOper      As Object

oModelAct := FWModelActive()
oModel := FWLoadModel("RU06D07") 


oView := FWFormView():New()
oView:SetModel(oModel)

// Header structure - F47 Payment Request - Header
oStrF4C := FWFormStruct(2, "F4C")

cBSFlowDir := " "
aRmvFields := {} 
/*Defining bank statement flow direction----------------------------------------*/
If Type("cOperDirection") == "C" .AND. cOperDirection != "0|0"
    cBSFlowDir := StrTokArr(cOperDirection, "|")[1]
Else
    cBSFlowDir := F4C->F4C_OPER       
EndIf
/*----------------------------------------Defining bank statement flow direction*/
If !Empty(cBSFlowDir)  /*View changing according to BS flow direction-----------*/ 
    lChView := .F.
    Do Case
        Case cBSFlowDir == "1" //Inflow bank statement
            lInflowBS := .T.
            lChView   := .T.
        Case cBSFlowDir == "2" //Outflow bank statement
            lInflowBS := .F.
            lChView   := .T.
    EndCase
    If lChView
        If lInflowBS //Inflow  bank statement
            aRmvFields := {"F4C_PAYORD" , "F4C_PAYTYP" , "F4C_SUPP"   , "F4C_UNIT"  ,;
                           "F4C_SUPNAM" , "F4C_TYPCC"                                }
            oStrF4C:SetProperty("F4C_RECTYP", MVC_VIEW_CANCHANGE, .F.)
            oView:SetAfterViewActivate({|oView|RU06D07013_ModelSettings(oView)})
        Else         //Outflow bank statement
            aRmvFields := {"F4C_RECTYP" , "F4C_CUST"   , "F4C_CUNI"   , "F4C_CUSNAM",; 
                           "F4C_TYPCP" , "F4C_ITTOTA" , "F4C_ITBALA",;
                           "F4C_ITVATO", "F4C_ITVATF" }
            oStrF4C:SetProperty("F4C_PAYTYP", MVC_VIEW_CANCHANGE, .F.)
        EndIf
        // SA6PO - My company as receiver(inf); FIL - Supplier as a receiver(outf)
        oStrF4C:SetProperty("F4C_BNKREC", MVC_VIEW_LOOKUP, IIF(lInflowBS,"SA6PO","FIL"))
        // F4N   - Customer as a receiver(inf); SA6PO -  My company as payer(outf)
        oStrF4C:SetProperty("F4C_BNKPAY", MVC_VIEW_LOOKUP, IIF(lInflowBS,"F4N","SA6PO"))
    EndIf
EndIf /*----------------------------View changing according to BS flow direction*/
oStrF4C:SetProperty("F4C_STATUS", MVC_VIEW_CANCHANGE, .F.)

// If you want to unlock PAYBIK or RECBIK.
// Please add validations to this fields and add them
// to triggers when select or change BIC.
oStrF4C:SetProperty("F4C_PAYBIK", MVC_VIEW_CANCHANGE, .F.)
oStrF4C:SetProperty("F4C_RECBIK", MVC_VIEW_CANCHANGE, .F.)

oStrF4C:SetProperty("F4C_UNIT"  , MVC_VIEW_CANCHANGE, .F.)
oStrF4C:SetProperty("F4C_CUNI"  , MVC_VIEW_CANCHANGE, .F.)
oStrF4C:SetProperty("F4C_CURNAM", MVC_VIEW_CANCHANGE, .F.)

oStrF4C:SetProperty("F4C_VATAMT", MVC_VIEW_CANCHANGE, lInflowBS)
oStrF4C:SetProperty("F4C_VATRAT", MVC_VIEW_CANCHANGE, .F.)
/*Hide fields-------------------------------------------------------------------*/
RU06D0775_RemoveStructFields(oStrF4C, aRmvFields) 
aRmvFields := {"F4C_VRSN"  , "F4C_CUUID", "F4C_IDF49" , "F4C_VALIN",;
               "F4C_VALOUT", "F4C_UUIDRE","F4C_LA", "F4C_UIDF5Q"   }
lRemRevFld := .F.
lRemRepFld := .F.
oOper := RU06D07041(oModelAct)
If !oOper:get('INCLUI')
    If !(F4C->F4C_STATUS  == '3' .OR. F4C->F4C_STATUS == '6')
        lRemRevFld := .T.
        If oOper:get('ALTERA') .AND. F4C->F4C_STATUS == '2' // check if date of reverse is obligatory for posted document
            If oModelAct != Nil .AND. oModelAct:CID == "RU06D07"
                oModelH    := oModelAct:GetModel(__cMdlHdr)
                If oModelH:GetStruct():GetProperty("F4C_DTREVE", MODEL_FIELD_OBRIGAT) // Date of reverse is obligatory?
                    lRemRevFld := .F.
                EndIf
            EndIf
        EndIf
    EndIf
    If !(F4C->F4C_STATUS $ "4|5|6")
        lRemRepFld := .T. // remove date of repalcement field in non-repalcement view
    EndIf
Else
    lRemRevFld := .T.
    lRemRepFld := .T.
    If F4C->F4C_STATUS  == '3' //check if replacement date is obligatory for reversed document
        If oModelAct != Nil .AND. oModelAct:CID == "RU06D07"
            oModelH    := oModelAct:GetModel(__cMdlHdr)
            If oModelH:GetStruct():GetProperty("F4C_DTREPL", MODEL_FIELD_OBRIGAT) // Date of replacement is obligatory?
                lRemRepFld := .F.
            EndIf
        EndIf    
    EndIf
EndIf
If lRemRevFld
    AADD(aRmvFields, "F4C_DTREVE")
EndIf
If lRemRepFld
    AADD(aRmvFields, "F4C_DTREPL")
EndIf
RU06D0775_RemoveStructFields(oStrF4C, aRmvFields)               
/*-------------------------------------------------------------------Hide fields*/

oStrF4C:AddField("F4C_FILIAL","01",RetTitle("F4C_FILIAL"),X3Descric(),{},;
                 "C","",Nil,"",.F.,GetSX3Cache("F4C_FILIAL","X3_FOLDER"),GetSX3Cache("F4C_FILIAL","X3_AGRUP"),{},0,Nil,.F.,Nil,.F.,;
                 GetSX3Cache("F4C_FILIAL","X3_TAMANHO")                  )
oView:AddField("RU06D07_VHEAD", oStrF4C, "RU06D07_MHEAD")

oStrVirt:=RU06D0527_DefVirtViewStr(.T.)
oView:AddGrid("RU06D07_VVIRT", oStrVirt, "RU06D07_MVIRT")
oView:SetViewProperty("RU06D07_VVIRT", "GRIDDOUBLECLICK", {{|oFormula, cFieldName, nLineGrid, nLineModel | RU06XFUN24_2Click(oFormula, cFieldName, nLineGrid, nLineModel)}})

oView:CreateHorizontalBox("SUPERIOR", 60)
oView:CreateHorizontalBox("INFERIOR", 40)
oView:SetOwnerView("RU06D07_VHEAD","SUPERIOR")
oView:SetOwnerView("RU06D07_VVIRT","INFERIOR")

Return (oView)


/*/{Protheus.doc} RU06D0702_VldPayOrd
Function to validate F4C_PAYORD field
@author natalia.khozyainova
@since 25/11/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0702_VldPayOrd()
    Local lRet          As Logical
    Local lAutoIns      As Logical
    Local aArea         As Array

    lAutoIns   := RU06D07036_GetlAutoIns()
    aArea      := GetArea()
    If lAutoIns
        If Empty(FwFldGet("F4C_PAYORD"))  //payord empty, so clear fields
            RU06D0720_PutFromPayOrd("","")
            lRet := .T.
        Else // payord is not empty, validate f4c_idf49
            lRet := RU06XFUN46_CheckPO(FwFldGet("F4C_PAYORD"),FwFldGet("F4C_IDF49"))
            If lRet // so, f4c_idf49 is validated, put data from payment order
                RU06D0720_PutFromPayOrd(FwFldGet("F4C_PAYORD"),FwFldGet("F4C_IDF49"))
            Else // f4c_idf49 isn't valdated, so if a cursor positioned on 
                 // f49_payord which equals f4c_payord, try to put data from f49
                 // in other case false will be returned by lRet
                If AllTrim(FwFldGet("F4C_PAYORD")) == AllTrim(F49->F49_PAYORD)
                    RU06D0720_PutFromPayOrd(F49->F49_PAYORD,F49->F49_IDF49)
                    lRet := .T.
                EndIf
            EndIf
        EndIf
    Else
        If Empty(FwFldGet("F4C_PAYORD")) .AND.;
           Empty(FwFldGet("F4C_IDF49" ))
            lRet := .T.
        Else
            lRet := RU06XFUN46_CheckPO(FwFldGet("F4C_PAYORD"),FwFldGet("F4C_IDF49"))
        EndIf
    EndIf
    RestArea(aArea)
Return (lRet)

/*/{Protheus.doc} RU06D0705_VldCurr
function to validate currency
@author natalia.khozyainova
@since 25/11/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0705_VldCurr()

    Local lRet       As Logical
    Local oModel     As Object
    Local oModelVrt  As Object
    Local oModelHdr  As Object
    Local nX         As Numeric
    Local nCPos      As Numeric

    lRet := ExistCpo("CTO",FwFldGet("F4C_CURREN")) .AND. RU06XFUN26_CheckCurrHeadLines()
    If !lRet
        //included currency not valid
        Help("",1,STR0015,,STR0016,1,0,,,,,,{STR0014})
    EndIf
    If lRet 
        oModel     := FWModelActive()
        // we set private var lUpdReason
        // for preventing reason changing
        // when we change each line in RU06D07_MVIRT
        // so we should update reason additionally
        lUpdReason := .F.
        If oModel != Nil .AND. oModel:GetID() == "RU06D07"
            oModelVrt := oModel:GetModel("RU06D07_MVIRT")
            oModelHdr := oModel:GetModel(__cMdlHdr)
            If !oModelVrt:IsEmpty()
                oModelVrt:SetNoUpdateLine(.F.)
                nCPos     := oModelVrt:GetLine()
                nX       := 1
                lAskAMErRU := .F. // don't ask about changing exchange rate
                While lRet .AND. nX <= oModelVrt:Length()
                    oModelVrt:GoLine(nX)
                    // so we change currency when we have no flag for manual changed
                    // currency and when currency in the line not equal to currency in the header
                    If !oModelVrt:IsDeleted() .AND. oModelVrt:GetValue("B_CHECK") == .F. .AND.;
                       RU06D06011_CanChangeExchangeRateInLine(oModelVrt,oModelHdr)
                        // when we use this setvalue combination, currency will be updated
                        lRet := lRet .AND. oModelVrt:SetValue("B_CHECK",.T.)
                        lRet := lRet .AND. oModelVrt:SetValue("B_CHECK",.F.)
                    EndIf
                    nX := nX + 1
                EndDo
                lAskAMErRU := .T.
                oModelVrt:GoLine(nCPos)
                If lRet
                    // update reason
                    lUpdReason := .T.
                    lRet := lRet .AND. RU06D06008_UpdateReason()
                EndIf
            EndIf
        EndIf
    EndIf

Return (lRet)

/*/{Protheus.doc} RU06D0774_VldF4N
Function used to validate the data relative to F4N in both operations
@param cParam    //If cParam == Nil, validate F4C_BNKPAY, cParam == "ACC"
                   we validate F4C_PAYACC
@type function
@author eduardo.flima
@since 13/08/2018
@version 1.0
@edit  astepanov November 05 2020
@project MA3 - Russia

@return    lRet,   Logical,    Returns if the content of the account is valid
/*/
Function RU06D0774_VldF4N(cParam As Character)

    Local   lRet     As Logical
    Local   cTab     As Character
    Default cParam   := ""

    lRet := .T.
    cTab := __cTabHdr
    If Empty(cParam)       // validate cTab+_BNKPAY
        lRet := RU06XFUN41_VldF4N(FwFldGet(cTab+"_CUST"),FwFldGet(cTab+"_CUNI"),FwFldGet(cTab+"_CURREN"),FwFldGet(cTab+"_BNKPAY"),Nil,Nil,Nil,Nil)  
    ElseIf cParam == "ACC" // validete cTab+_PAYACC
        lRet := RU06XFUN41_VldF4N(FwFldGet(cTab+"_CUST"),FwFldGet(cTab+"_CUNI"),FwFldGet(cTab+"_CURREN"),FwFldGet(cTab+"_BNKPAY"),FwFldGet(cTab+"_PAYBIK"),FwFldGet(cTab+"_PAYACC"),Nil,Nil)
    EndIf

Return (lRet)

/*/
{Protheus.doc} RU06D0707_VldFIL()
Bank account validation
@param  Character    cParam   //If Nil - we validate F4C_BNKREC
                              //If "ACC" - we validate F4C_RECACC
@author natalia.khozyainova
@edit   astepanov  03 November 2020
@since 25/11/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0707_VldFIL(cParam As Character)

    Local lRet       As  Logical
    Local nParam     As  Numeric
    Default cParam   := ""

    nParam := 1
    If Empty(cParam)
        nParam := 1
    ElseIf cParam == "ACC"
        nParam := 4
    EndIf
    lRet := RU06D0504_VldFil(nParam, __cTabHdr)
    
Return (lRet)

//---------------------------------------------------------------------------------------/*/
/*/{Protheus.doc} RU06D0704_VldSA6

Function used for validation payer's (reciever's) account info
using SA6 table

@param       Character        cParam // if we validate bank code and BIK it should be
                                     // empty string, if we validate account number
                                     // it should be "ACC".
             Numeric          nBnkFlw //1 - Inflow BS, 2 - Outflow BS
@return      Logical          lRet
@example     
@author      astepanov
@since       July/02/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0704_VldSA6(cParam As Character, nBnkFlw As Numeric)
    Local lRet     As Logical
    Local cBCId    As Character
    Local cBICID   As Character
    Local cAccID   As Character
    Local cCurrID  As Character
    Local nParam   As Numeric

    Default cParam   := ""
    Default nBnkFlw  := Val(FWFldGet("F4C_OPER"))

    nParam := 0
    If Empty(cParam)
        nParam := 0    // validate bank code
    ElseIf cParam == "ACC"
        nParam := 4    // validate bank account
    EndIf
    // make decision which fields should be checked we are
    // payer or reciever
    If      nBnkFlw == 2 //Outflow BS
        cBCId   := __cTabHdr+"_BNKPAY"
        cBICID  := __cTabHdr+"_PAYBIK"
        cAccID  := __cTabHdr+"_PAYACC"
        cCurrID := __cTabHdr+"_CURREN"
    ElseIf  nBnkFlw == 1 //Inflow  BS
        cBCId   := __cTabHdr+"_BNKREC"
        cBICID  := __cTabHdr+"_RECBIK"
        cAccID  := __cTabHdr+"_RECACC"
        cCurrID := __cTabHdr+"_CURREN"
    EndIf

    lRet := RU06D0508_VldSa6(nParam,cBCId, cBICID, cAccID, cCurrID)

Return (lRet) /*----------------------------------------------------------RU06D0704_VldSA6*/

/*/
{Protheus.doc} RU06D0706_VldSupp()
Supplier code and unit validation
@author natalia.khozyainova
@since 02/11/2018
@edit astepanov 03 November 2020
@param    Numeric        nField // 1 = Supp, 2=Unit
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0706_VldSupp(nField)

    Local lRet          As Logical
    Local lAutoIns      As Logical
    Local oModel        As Object
    Local oModelVrt     As Object
    Default nField      := 1 // it means we validate supplier

    lRet  := RU06D0503_VldSupp(nField,__cTabHdr)

    If lRet
        //lAutoIns - .T. - allows updating fields according to default data,
        //           .F. - no
        lAutoIns   := RU06D07036_GetlAutoIns()
        oModel     := FWModelActive()
        If oModel != Nil .AND. lAutoIns
            //update RU06D07_MLNS grid after supplier or unit validation
            oModelVrt  := oModel:GetModel():GetModel("RU06D07_MVIRT")
            If ! oModelVrt:IsEmpty()
                If FwFldGet("F4C_OPER") == "2" //outflow bank statement
                    RU06D07E11_UpdateFM5MLnsWhenSupOrCusValidatedBeforeDeletion(;
                    oModel:GetModel():GetModel("RU06D07_MLNS"),;
                    FwFldGet("F4C_SUPP"),;
                    FWFldGet("F4C_UNIT"), .F.                                   )
                EndIf
                // prepare RU06D07_MVIRT grid for lines deletion
                oModelVrt:SetNoDeleteLine(.F.)
            EndIf
        EndIf
    EndIf

Return (lRet)


/*/
{Protheus.doc} RU06D0767_VldCust
Customer code and unit validation
@param  Numeric    nParam   //1- Customer, 2 - Unit
@type function
@author dtereshenko
@since 2019/04/08
@version P12.1.25
@edit   astepanov 05 November 2020
@project MA3 - Russia
@param
@return   lRet,      Logical,    Returns if the operation occurred without error
/*/
Function RU06D0767_VldCust(nParam)

    Local lRet          As Logical
    Local lAutoIns      As Logical
    Local oModel        As Object
    Local oModelVrt     As Object
    Local cTab          As Character

    Default nParam := 1  // validate customer code
    cTab  := __cTabHdr
    lRet  := RU06D07035_ValidateCustomer(nParam, cTab)

    If lRet
        //lAutoIns - .T. - allows updating fields according to default data,
        //           .F. - no
        lAutoIns   := RU06D07036_GetlAutoIns()
        oModel     := FWModelActive()
        If oModel != Nil .AND. lAutoIns
            //update RU06D07_MLNS grid after customer or unit validation
            oModelVrt  := oModel:GetModel():GetModel("RU06D07_MVIRT")
            If ! oModelVrt:IsEmpty()
                If FwFldGet("F4C_OPER") == "1" //inflow bank statement
                    RU06D07E11_UpdateFM5MLnsWhenSupOrCusValidatedBeforeDeletion(;
                    oModel:GetModel():GetModel("RU06D07_MLNS"),;
                    FwFldGet("F4C_CUST"),;
                    FWFldGet("F4C_CUNI"), .T.                                   )
                EndIf
                // prepare RU06D07_MVIRT grid for lines deletion
                oModelVrt:SetNoDeleteLine(.F.)
            EndIf
        EndIf
    EndIf

Return (lRet)

/*/
{Protheus.doc} RU06D0708_ShwFIL()
virtual fields from FIL table
@param  Numeric         nNum   // 1,2
@return Character       cRet
                              // nNum == 1 - returns value for F4C_TYPCC
                              // nNum == 2 - returns value for F4C_ACRNUM
@author natalia.khozyainova
@since 25/11/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0708_ShwFIL(nNum)
    Local cRet As Character
    cRet := RU06XFUN02_ShwFIL(nNum,;
                              FwFldGet("F4C_SUPP"  ),;
                              FwFldGet("F4C_UNIT"  ),;
                              FwFldGet("F4C_BNKREC"),;
                              FwFldGet("F4C_RECBIK"),;
                              FwFldGet("F4C_RECACC") )
Return (cRet)


/*/{Protheus.doc} RU06D0709_PayType
This function will show small screen to choose payment type
@param  Logical   lFillFlds : .T. - return value for field in model
                              .F. - default, define payment type and
                                    operation direction: inflw or oflw
        Character cField    : if lFillFlds == .T., should be used for
                                 which field function should return
                                 value
@return Character cOperPay  : if lFillFlds == .F. returns string in
                              format <cSelOperDir>|<cPayType>
                              i.e: "2|1" is ouflow BS payment to
                              supplier, "0|0" means  there was
                              opertion cancelling or mistake with
                              payment type detection.
@author Eduardo.Flima
@since 09/11/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0709_PayType(lFillFlds, cField)
Local aArea      as Array
Local aPayTypes  as Array
Local cPayType   as Character
Local oDlg       as Object 
Local oCmbVw     as Object
Local oCmbPt     as Object
Local oGrpPaym   as Object
Local oButtonOk  as Object
Local oButtonCnc as Object
Local cSelOperDi as Character
Local cOperPay   as Character
Local aOperDir   as Array
Local aTypes     as Array
Local nX         as Numeric
Local cX         as Character

Default lFillFlds := .F.
Default cField    := "" 

If lFillFlds
    cOperPay := "0"
    If Type("cOperDirection") == "C" .AND. cOperDirection != "0|0"
        aTypes := StrTokArr(cOperDirection,"|")
        If cField == "F4C_OPER"
            cOperPay := aTypes[1]
        EndIf
        If (aTypes[1] == "1" .AND. cField == "F4C_RECTYP") .OR.;
           (aTypes[1] == "2" .AND. cField == "F4C_PAYTYP")
            cOperPay := aTypes[2]
        EndIf
    EndIf
Else
    aArea := GetArea()
    cSelOperDi := "2" //Outflow
    cPayType   := "1"
    If nModulo == 6
        If !isBlind() .And. !RU06D07740_GetAutoBs()
            aOperDir := {} 
            AADD(aOperDir,"1=" + STR0095) // 1 - Inflow
            AADD(aOperDir,"2=" + STR0096) // 2 - Outflow
            aPayTypes := RU06D0719_ReturnPayTypes(cSelOperDi)
            // Bank Statement Operation
            oDlg   := MSDialog():New( 01, 01, 160, 245, STR0108,,,,,,,,,.T.)
            oGrpPaym := TGroup():New( 05, 05, 60, 120,  STR0109+" / "+STR0108,oDlg,,,.T.)
            oCmbVw := TComboBox():New(15, 10,;
                                    {|u| If(PCount() > 0,;
                                    cSelOperDi := u,;
                                    cSelOperDi)},;
                                    aOperDir, 105, 20, oDlg,,;
                                    {|| oCmbPt:SetItems(RU06D0719_ReturnPayTypes(cSelOperDi))},,,,;
                                    .T.,,,,,,,,,"cSelOperDi",;
                                    Nil) 
            oCmbPt := TComboBox():New(35, 10,;
                                    {|u| If(PCount() > 0,;
                                    cPayType := u,;
                                    cPayType)},;
                                    aPayTypes, 105, 20, oDlg,,;
                                    ,,,,;
                                    .T.,,,,,,,,,"cPayType",;
                                    Nil)
            oButtonOk   := SButton():Create(oDlg, 65, 65, 1, {||oDlg:End()}, .T.,, {||.T.})
            oButtonCnc  := SButton():Create(oDlg, 65, 95, 2, {||oDlg:End(), cPayType := "0" }, .T.,, {||.T.})
            oDlg:Activate()
            cPayType := AllTrim(cPayType)
            cX       := ""
            For nX := 1 To Len(cPayType)
                If IsDigit(SubStr(cPayType,nX,1))
                    cX += SubStr(cPayType,nX,1)
                Else
                    Exit
                EndIf 
            Next nX
            cPayType := IIf(!Empty(cX),cX,"0")
        EndIf
    EndIf
    RestArea(aArea)
    cOperPay := Iif(cPayType=="0","0",cSelOperDi) + "|" + cPayType
EndIf

Return (cOperPay)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0719_ReturnPayTypes

Function recieves opertion direction parameter and returns array of payment types

@param       Character        cSelOperDi // 1 - Inflow bank statement
                                         // 2 - Outflow bank statement
@return      Array            aPayTypes
@example     
@author      astepanov
@since       May/28/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0719_ReturnPayTypes(cSelOperDi)

    Local    aPayTypes  As Array
    Local    aArea      As Array
    Local    aSX5Area   As Array
    Local    cSX5Fil    As Character
    Local    cX5Tab     As Character
       
    Default  cSelOperDi := "2"

    aPayTypes  := {}
    aArea      := GetArea()
    aSX5Area   := SX5->(GetArea())
    cSX5Fil    := FWXFilial("SX5")
    If     cSelOperDi == "2"
        cX5Tab := PADR("EX",TamSX3("X5_TABELA")[1]) //EX - payment for outflow BS
    ElseIf cSelOperDi == "1"
        cX5Tab := PADR("EY",TamSX3("X5_TABELA")[1]) //EX - payment for inflow BS
    EndIf
    SX5->(DbSetOrder(1)) //filial+tabela+chave
    If SX5->(MsSeek(cSX5Fil + cX5Tab))
        While SX5->(!EoF() .AND. SX5->X5_FILIAL == cSX5Fil .AND. SX5->X5_TABELA == cX5Tab)
            AADD(aPayTypes, AllTrim(SX5->X5_CHAVE) + " - " + X5Descri())
            SX5->(DbSkip())
        EndDo
    EndIf
    //03/06/2019 Stepanov
    //for current moment we have no tabela for inflow payment type
    //so X5_CHAVE from 1 to 7 is a payment type for outflow BS
    //so for inflow we just put harcoded lines:
    // If Empty(aPayTypes)
    //     AADD(aPayTypes,"1"+STR0029) //15 - return  from the supplier
    //     AADD(aPayTypes,"1"+STR0030) //16 - payment from customer
    //     AADD(aPayTypes,"1"+STR0031) //17 - payment from budget
    // EndIf //<-------- need for refactoring after creating tabela for inflow BS in SX5
    SX5->(RestArea(aSX5Area))
    RestArea(aArea)

    If Empty(aPayTypes)
        AADD(aPayTypes, "0 - ")
        HELP("",1,  STR0017 + STR0052,,; //BS - information
                    STR0110,;            //List of payment types is empty
                    1,0,,,,,,;
                    {STR0111})           //Please fill the list of payment types
    EndIf

Return (aPayTypes) /*---------------------------------------------RU06D0719_ReturnPayTypes*/


/*/{Protheus.doc} RU06D0710_Act
all actions, called from Main Menu
@author natalia.khozyainova
@since 24/10/2018
@version R6 - 1.0
@type function
Private cOperDirection As Character
/*/
Function RU06D0710_Act(nOperation as Numeric)
    Local lRet      As Logical
    Local cStatus   As Character
    Local cPayord   As Character
    Local cKey      As Character
    Local aArea     As Array

    Private cOperDirection As Character
    Default nOperation     := 1

    lRet  := .T.
    aArea := {}

    cStatus        := F4C->F4C_STATUS
    cPayord        := F4C->F4C_PAYORD
    cOperDirection := IIf(!Empty(F4C->F4C_OPER+F4C->F4C_PAYTYP),;
                                 F4C->F4C_OPER+"|"+F4C->F4C_PAYTYP, "0|0")

    Do Case
        Case nOperation == 5 .AND.  !(cStatus == "1" .OR. cStatus == "4")    //try to delete
            HELP("",1, STR0047 + STR0049,,;
                    STR0050,;
                    1,0,,,,,,;
                    {STR0051})
            lRet := .F.
        Case nOperation == 4 .AND.;
             !(cStatus == "1" .OR. cStatus == "4")    //try to edit
            HELP("", 1, STR0048 + STR0049,,;
                    STR0050,;
                    1,0,,,,,,;
                    {STR0051})
            lRet := .F.
        Case nOperation == 3
            cOperDirection := RU06D0709_PayType(.F.)
            If cOperDirection == "0|0"
               lRet := .F. 
            EndIf
        Case nOperation == 7 // track replaced BS
            If Empty(AllTrim(F4C->F4C_UUIDRE))
                HELP("", 1, STR0017 + STR0052, ,;
                     STR0149,; //only for replacement
                     1,0,,,,,,;
                     {STR0150}) //is not replacement
                lRet := .F.
            Else
                aArea := GetArea()
                Posicione("F4C",5,xFilial("F4C")+F4C->F4C_UUIDRE,"F4C_CUUID")
                nOperation := 1 // open for view
            EndIf
        Case nOperation == 8 // track replacement BS
            cKey := RU06XFUN49_CheckF4CUUIDRE(F4C->F4C_CUUID,.T.,.T.)
            If Empty(cKey)
                HELP("", 1, STR0017 + STR0052, ,;
                     STR0151,; //no replacement
                     1,0,,,,,,;
                     {STR0152}) //is not replaced
                lRet := .F.
            Else
                aArea := GetArea()
                Posicione("F4C",5,xFilial("F4C")+cKey,"F4C_CUUID")
                nOperation := 1 // open for view
            EndIf
    EndCase

    If lRet
        FWExecView("","RU06D07",nOperation,,{|| .T.})
    EndIf
    If !Empty(aArea)
        RestArea(aArea)
    EndIf

Return (lRet)

/*/{Protheus.doc} RU06D0711_Legend
this function will show list of colours used for legend (status). See Browse:AddLegend()
@author natalia.khozyainova
@since 24/10/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0711_Legend()
Local aRet as Array
aRet:={}
aAdd(aRet,{"BR_BRANCO",   STR0003}) // White == Created
aAdd(aRet,{"BR_AZUL",     STR0004}) // Blue == Posted in Financial
aAdd(aRet,{"BR_VERMELHO", STR0085}) // Reversed in Financial
aAdd(aRet,{"BR_PRETO"   , STR0142}) // Replaced
aAdd(aRet,{"BR_AMARELO" , STR0143}) // Replacement
aAdd(aRet,{"BR_LARANJA" , STR0144}) // Replacement and posted
aAdd(aRet,{"BR_PINK"    , STR0145}) // Replacement and reversed
aAdd(aRet,{"BR_VERDE"   , STR0005}) // Posted in Accounting
BrwLegenda(cCadastro, STR0006, aRet) // Legend 
Return (aRet)


/*/{Protheus.doc} RU06D0712_InitDate
Function to initialize F4C_DTTRAN field
@author natalia.khozyainova
@since 25/11/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0712_InitDate()
Local dRet as Date
// in Brazil Calendar Saturday is day number 7 and sunday us day number 1
/* Day of the week | Number
   Monday          | 2
   Tuesday         | 3
   Wednesday       | 4
   Thursday        | 5
   Friday          | 6
   Saturday        | 7
   Sunday          | 1
*/
dRet:=dDataBase-1 // the date before today
If DOW(dRet) == 7 // if it's saturday or sunday to put friday
    dRet:=dRet-1
ElseIf DOW(dRet) == 1
    dRet:=dRet-2
EndIf
Return (dRet)


/*/
{Protheus.doc} RU06D0713_VirtGridLoad()
Function to load values to the
Outflow Bank statement virtual grid
Please, don't use calculations, Posicione(), DbSeek(),
ExistCPO() and so on, this function only for
loading values. Provide all calculations
in RU06XFUN30_RetVrtLnsForOutBS function where
SQl query is located.
@author natalia.khozyainova
@since 25/11/2018
@version 2.0
@edit    astepanov 17 July 2019
@project MA3 - Russia
/*/
Function RU06D0713_VirtGridLoad(oModel)
    Local aLines    as Array
    Local aFields   As Array
    Local aValues   As Array
    Local aArea     As Array
    Local aF5MPos   As Array
    Local cAlias    As Character
    Local lInflow   As Logical
    Local nX  , nFlS, nFlL, nPrS, nPrL, nNmS, nNmL As Numeric
    Local nPaS, nPaL, nTiS, nTiL, nQRS, nQRL, nF4L As Numeric
    Local xVal
    aLines := {}
    lInflow := (FWFldGet("F4C_OPER") == '1')
    aF5MPos := RU06XFUN44_RetSE2FldsPosInFMKey(lInflow)
    nFlS    := aF5MPos[1][4]
    nFlL    := aF5MPos[1][5]
    nPrS    := aF5MPos[2][4]
    nPrL    := aF5MPos[2][5]
    nNmS    := aF5MPos[3][4]
    nNmL    := aF5MPos[3][5]
    nPaS    := aF5MPos[4][4]
    nPaL    := aF5MPos[4][5]
    nTiS    := aF5MPos[5][4]
    nTiL    := aF5MPos[5][5]
    nQRS    := aF5MPos[7][4] + aF5MPos[7][5] + 1
    nQRL    := GetSX3Cache("F4A_CODREQ","X3_TAMANHO")
    nF4L    := GetSX3Cache("F4A_IDF4A" ,"X3_TAMANHO")
    cAlias := RU06XFUN30_RetVrtLnsForOutBS(FWFldGet("F4C_CUUID" ),;
                                           Iif(lInflow,Nil,FWFldGet("F4C_PAYORD")),;
                                           Iif(lInflow,Nil,FWFldGet("F4C_IDF49" )),;
                                           Nil                   ,;
                                           FWFldGet("F4C_DTTRAN"),;
                                           FWFldGet("F4C_CURREN"),;
                                           lInflow)

    If !Empty(cAlias)
        aFields := ACLONE(oModel:GetStruct():GetFields())
        aArea := GetArea()
        DbSelectArea(cAlias)
        DbGoTop()
        While !EoF()
            aValues := {}
            For nX := 1 To Len(aFields)
                If     aFields[nX][3] == "B_EMISS" .OR. aFields[nX][3] == "B_REALMT"
                    xVal := STOD(AllTrim((cAlias)->&(aFields[nX][3])))
                ElseIf aFields[nX][3] == "B_CHECK"
                    xVal := IIf((cAlias)->&(aFields[nX][3]) == "1", .T., .F.)
                ElseIf aFields[nX][3] == "B_CODREQ"
                    xVal := SubStr((cAlias)->B_F5MKEY,nQRS,nQRL)
                ElseIf aFields[nX][3] == "B_IDF4A"
                    xVal := SubStr((cAlias)->B_F5MKEY,nQRS+nQRL+1,nF4L)
                ElseIf aFields[nX][3] == "B_FLORIG"
                    xVal := SubStr((cAlias)->B_F5MKEY,nFlS,nFlL)
                ElseIf aFields[nX][3] == "B_PREFIX"
                    xVal := SubStr((cAlias)->B_F5MKEY,nPrS,nPrL)
                ElseIf aFields[nX][3] == "B_NUM"
                    xVal := SubStr((cAlias)->B_F5MKEY,nNmS,nNmL)
                ElseIf aFields[nX][3] == "B_PARCEL"
                    xVal := SubStr((cAlias)->B_F5MKEY,nPaS,nPaL)
                ElseIf aFields[nX][3] == "B_TYPE"
                    xVal := SubStr((cAlias)->B_F5MKEY,nTiS,nTiL)
                //Alexandra(17/02/20): check specification Fi-CF-25-15. What should be in this field if bs in euro and aRs in euro
                // ElseIf lInflow .And. aFields[nX][3] == "B_EXGRAT"
                //     xVal := (cAlias)->B_EXGRAT
                Else
                    xVal := IIF(aFields[nX][4] == "C", PADR((cAlias)->&(aFields[nX][3]),aFields[nX][5]," "),;
                               (cAlias)->&(aFields[nX][3]))    
                EndIf
                AADD(aValues,xVal)
            Next nX
            //Update PA or RA line
            RU06D07880_UpdateNonPostedPARALineWhenLoad(@aFields, @aValues)
            AADD(aLines,{0,aValues})
            DBSkip()
        EndDo
        (cAlias)->(DBCloseArea())
        RestArea(aArea)
    EndIf
Return (aLines)


/*/{Protheus.doc} RU06D0716_VldVat
Called from x3_valid of F4C_VALUE, F4C_VATCOD, F4C_VATRAT, F4C_VATAMT
@author natalia.khozyainova
@param  nNum: 2=COD
@since 18/12/2018
@edit  01 August 2019 astepanov
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0716_VldVat(nNum)

    Local lRet          As Logical
    Local lAutoIns      As Logical
    Local aArea         As Array
    Local aVATRAte      As Array
    Local oModel        As Object
    Local oModelF4C     As Object
    Local oModelVrt     As Object
    Local nVATAmnt      As Numeric
    Local nX            As Numeric
    Default  nNum       := 2

    lAutoIns   := RU06D07036_GetlAutoIns()
    aArea      := GetArea()
    lRet       := .T.
    oModel     := FWModelActive()
    oModelF4C  := oModel:GetModel("RU06D07_MHEAD")
    oModelVrt  := oModel:GetModel():GetModel("RU06D07_MVIRT")
    If lAutoIns
        aVATRAte := RU06XFUN34_ParseVatRate(oModelF4C:GetValue("F4C_VATCOD"))
        oModelF4C:LoadValue("F4C_VATRAT",aVATRAte[1])
        If !oModelVrt:IsEmpty()
            nVATAmnt := RU06D07E8_UpdateVATValuesInVrtGrid(oModelF4C, oModelVrt)
            If nVATAmnt != oModelF4C:GetValue("F4C_VATAMT")
                lRet := oModelF4C:LoadValue("F4C_VATAMT",nVATAmnt)
                nX := oModelVrt:GetLine()
                lRet := lRet .AND. RU06D0717_Rsn()
                oModelVrt:GoLine(nX)
            EndIf
        ElseIf (oModelF4C:GetValue("F4C_OPER") == '1')
            nVATAmnt := RU06XFUN18_VATFormula(oModelF4C:GetValue("F4C_VALUE"),;
                                    aVATRAte,;
                                    GetSX3Cache("F4C_VATAMT", "X3_DECIMAL"),;
                                    .T.                                     )
            oModelF4C:LoadValue("F4C_VATAMT",nVATAmnt)
        EndIf
    Else
        aVATRAte := RU06XFUN34_ParseVatRate(FwFldGet("F4C_VATCOD"))
        If oModelF4C:GetValue("F4C_VATRAT") != aVATRAte[1]
            lRet := .F.
        EndIf
    EndIf
    
Return (lRet)

Function RU06D0717_Rsn(lForce as Logical, nLine as Numeric, cAction as Character)
    Local lRet As Logical
    lRet := FwFldPut("F4C_REASON",RU06XFUN19_ReasonText(lForce, nLine, cAction),,,.F.)
Return (lRet)


/*/{Protheus.doc} RU06D0720_PutFromPayOrd
Function to load data of payment order attached to header and lines of BS
@author natalia.khozyainova
@since 25/11/2018
@version 1.0
@param   Character  cOrdValNew    // payment order number
         Character  cF49_IDF49    // Payment order id F49_IDF49
@project MA3 - Russia
/*/
Function RU06D0720_PutFromPayOrd(cOrdValNew As Character, cF49_IDF49 As Character)

    Local nX            As Numeric
    Local nY            As Numeric
    Local cAlias        As Character
    Local cPermFld      As Character
    Local cFldNam       As Character
    Local cReason       As Character
    Local cF49_Stat     As Character
    Local oModel        As Object
    Local oModelF4C     As Object
    Local oModelVrt     As Object
    Local aFields       As Array
    Local aValues       As Array
    Local aSaveArea     As Array
    Local aFldsToClear  As Array
    Local aPermFld      As Array
    Local lClear        As Logical
    Local nCnt          As Numeric
    Local nF4CValue     As Numeric
    Local nF4CVATAm     As Numeric
    Local xVal
    Default cOrdValNew  := ""
    Default cF49_IDF49  := ""
    oModel     := FWModelActive()
    oModelF4C  := oModel:GetModel("RU06D07_MHEAD")
    oModelVrt  := oModel:GetModel():GetModel("RU06D07_MVIRT")
    If RU06D07740_GetAutoBs()
        cF49_Stat := "2"
    Else 
        cF49_Stat := "1"
    Endif
    aFields    := ACLONE(oModelF4C:GetStruct():GetFields())
    aValues    := {}
    //cPermFld these fields should save values and can't be changed
    cPermFld   := "F4C_FILIAL|F4C_CUUID|F4C_OPER|F4C_PAYTYP|F4C_RECTYP|F4C_STATUS|"
    cPermFld   += "F4C_UUIDRE|"
    aPermFld   := StrTokArr(cPermFld,"|")
    nCnt := 0
    For nX := 1 To Len(aPermFld) // exclude permanent fields
        For nY := 1 To Len(aFields)
            If aFields[nY] != Nil .AND. aFields[nY][3] == aPermFld[nX]
                ADEL(aFields, nY)
                nCnt := nCnt + 1
            EndIf
        Next nY
    Next nX
    ASIZE(aFields,Len(aFields) - nCnt)
    lClear  := .T.
    aSaveArea := GetArea()
    If !Empty(cOrdValNew)
        cAlias    := RU06XFUN37_RetPODataByKey(cOrdValNew,cF49_IDF49,cF49_Stat)
        DBSelectArea(cAlias)
        DBGoTop()
        If !EoF()
            For nX := 1 To (cAlias)->(FCount())
                cFldNam := "F4C" + AllTrim((cAlias)->(FIELD(nX)))
                For nY := 1 To Len(aFields)
                    If cFldNam == aFields[nY][3]
                        xVal := (cAlias)->&(FIELD(nX))
                        If     aFields[nY][4] == "C"
                            xVal := AllTrim(xVal)
                        ElseIf aFields[nY][4] == "D"
                            xVal := STOD(AllTrim(xVal))
                        EndIf
                        oModelF4C:LoadValue(cFldNam,xVal)
                        Exit
                    EndIf
                Next nY
            Next nX
            //load memo field F4C_REASON
            oModelF4C:LoadValue("F4C_REASON",;
                Posicione("F49",2,xFilial("F49")+cF49_IDF49,;
                          "F49_REASON")                     )
            lClear := .F.
        EndIf
        (cAlias)->(DbCloseArea())
    EndIf
    RestArea(aSaveArea)
    aFldsToClear := {}
    For nX := 1 To Len(aFields)
        AADD(aFldsToClear, aFields[nX][3])
    Next nX
    If lClear
        RU06D07005_CheckFldsBeforeCleaning(@aFldsToClear)
        RU06XFUN01_CleanFlds(aFldsToClear,.T.)
    EndIf
    oModelVrt:SetNoInsertLine(.F.)
    oModelVrt:SetNoUpdateLine(.F.)
    oModelVrt:SetNoDeleteLine(.F.)
    nF4CValue := oModelF4C:GetValue("F4C_VALUE")
    nF4CVATAm := oModelF4C:GetValue("F4C_VATAMT")
    cReason   := oModelF4C:GetValue("F4C_REASON")
    If !RU06D0721_PayOrdLines(cOrdValNew, cF49_IDF49)
         RU06D07005_CheckFldsBeforeCleaning(@aFldsToClear)
         RU06XFUN01_CleanFlds(aFldsToClear,.T.)
    Else // pay ord lines added success
        // add AP with type PA if we need it
        oModelF4C:LoadValue("F4C_VALUE" , nF4CValue)
        oModelF4C:LoadValue("F4C_VATAMT", nF4CVATAm)
        If oModelF4C:GetValue("F4C_VALUE") > 0 
            RU06D0759_RecalcValue(.T.)
        EndIf
        oModelF4C:LoadValue("F4C_REASON",cReason)
        If !Empty(cOrdValNew)
            oModelVrt:SetNoInsertLine(.T.)
            oModelVrt:SetNoUpdateLine(.T.)
            oModelVrt:SetNoDeleteLine(.T.)
        EndIf
    EndIf

Return (Nil)

/*/{Protheus.doc} RU06D0721_PayOrdLines
add lines from F4B to F5M and Virtual Grid
Please, don't use Posicione(), ExistCPO(), DBSeeK() and so on
all data can be get by one sql query.
@author natalia.khozyainova
@since 25/11/2018
@version 2.0
@param    Character cOrdValNew  //F49_PAYORD field value
          Character cF49ID      //F49_IDF49  field value
@return   Logical   lPrc        //.T. - all is ok
@edit astepanov 15 July 2019
@project MA3 - Russia
/*/
Function RU06D0721_PayOrdLines(cOrdValNew As Character, cF49ID As Character)

    Local cAlias     As Character
    Local cF5MKey    As Character
    Local aSaveArea  as Array
    Local aF5MLns    As Array
    Local aVrtLns    As Array
    Local aE2Tm      As Array
    Local aF5MFlds   As Array
    Local aVrtFlds   As Array
    Local lPrc       As Logical
    Local lNoAddFtLn As Logical
    Local nF5MLen    As Numeric
    Local nVrtLen    As Numeric
    Local nX         As Numeric
    Local nCPos      As Numeric
    Local nF4AQL     As Numeric
    Local nID4AL     As Numeric
    Local oModel     As Object
    Local oModelF5M  As Object
    Local oModelVrt  As Object
    Local xVal

    oModel    := FwModelActive()
    oModelF5M := oModel:GetModel():GetModel("RU06D07_MLNS" )
    oModelVrt := oModel:GetModel():GetModel("RU06D07_MVIRT")
    lPrc     := .T.
    If !(oModelVrt:IsEmpty() .AND. oModelF5M:IsEmpty())
        lNoAddFtLn := .F.
        //clean lines in vrt model
        If FwFldGet("F4C_OPER") == "2"
            RU06D07E11_UpdateFM5MLnsWhenSupOrCusValidatedBeforeDeletion(;
            oModel:GetModel():GetModel("RU06D07_MLNS"),;
            FwFldGet("F4C_SUPP"),;
            FWFldGet("F4C_UNIT"), .F.                                  )
        EndIf
        nCPos := oModelVrt:GetLine()
        For nX := 1 To oModelVrt:Length()
            oModelVrt:GoLine(nX)
            If !oModelVrt:IsDeleted()
                oModelVrt:DeleteLine()
            EndIf
        Next nX
        oModelVrt:GoLine(nCPos)
    Else
        lNoAddFtLn := .T.
    EndIf
    If !(Empty(cOrdValNew) .AND. Empty(cF49ID))
        aF5MFlds := ACLONE(oModelF5M:GetStruct():GetFields())
        aVrtFlds := ACLONE(oModelVrt:GetStruct():GetFields())
        aE2Tm  := RU06XFUN44_RetSE2FldsPosInFMKey()
        nF4AQL := GetSX3Cache("F4A_CODREQ","X3_TAMANHO") 
        nID4AL := GetSX3Cache("F4A_IDF4A ","X3_TAMANHO")
        cAlias := RU06XFUN33_RetPOLinesByKey(cOrdValNew,cF49ID,;
                                             aVrtFlds,;
                                             aF5MFlds          )
        aSaveArea := GetArea()
        DBSelectArea(cAlias)
        DBGoTop()
        aF5MLns := {}
        aVrtLns := {}
        While !EoF()
            lPrc     := .F.
            nF5MLen  := oModelF5M:Length()
            If lNoAddFtLn .OR. nF5MLen < oModelF5M:AddLine() //add line
                For nX := 1 To Len(aF5MFlds)
                    xVal := (cAlias)->&(aF5MFlds[nX][3])
                    If      aF5MFlds[nX][4] == "C"
                        xVal := PADR(xVal,aF5MFlds[nX][5], " ")
                    EndIf
                    oModelF5M:LoadValue(aF5MFlds[nX][3], xVal)
                Next nX
                oModelF5M:LoadValue("F5M_IDDOC" , FwFldGet("F4C_CUUID"))
                oModelF5M:LoadValue("F5M_ALIAS" , "F4C"   )
                oModelF5M:LoadValue("F5M_KEYALI", "SE2"   )
                cF5MKey := PADR((cAlias)->B_FLORIG ,aE2Tm[1][5]," ") + "|" +;
                           PADR((cAlias)->B_PREFIX ,aE2Tm[2][5]," ") + "|" +;
                           PADR((cAlias)->B_NUM    ,aE2Tm[3][5]," ") + "|" +;
                           PADR((cAlias)->B_PARCEL ,aE2Tm[4][5]," ") + "|" +;
                           PADR((cAlias)->B_TYPE   ,aE2Tm[5][5]," ") + "|" +;
                           PADR((cAlias)->B_FORNECE,aE2Tm[6][5]," ") + "|" +;
                           PADR((cAlias)->B_LOJA   ,aE2Tm[7][5]," ")
                If !Empty((cAlias)->B_CODREQ)
                    cF5MKey += "|"
                    cF5MKey += PADR((cAlias)->B_CODREQ ,nF4AQL     ) + "|"
                    cF5MKey += PADR((cAlias)->B_IDF4A  ,nID4AL     )
                EndIf
                oModelF5M:LoadValue("F5M_KEY"   , cF5MKey )
                AADD(aF5MLns,oModelF5M:GetLine())
                lPrc := .T.
            Else
                lPrc := .F.
            EndIf
            nVrtLen := oModelVrt:Length() // add line to Vrt grid
            If lPrc .AND. (lNoAddFtLn .OR. nVrtLen < oModelVrt:AddLine())
                For nX := 1 To Len(aVrtFlds)
                    xVal := (cAlias)->&(aVrtFlds[nX][3])
                    If aVrtFlds[nX][4] == "C"
                        xVal := PADR(xVal,aVrtFlds[nX][5], " ")
                    EndIF
                    oModelVrt:LoadValue(aVrtFlds[nX][3],xVal)
                Next nX
                AADD(aVrtLns,oModelVrt:GetLine())
            Else
                lPrc := .F.
            EndIf
            If !lPrc
                Exit
            EndIf
            DBSkip()
            lNoAddFtLn := .F.
        EndDo
        (cAlias)->(DBCloseArea())
        RestArea(aSaveArea)
        If ! lPrc
            // If there are some problems with line adding
            // delete all added lines and show help message
            For nX := 1 To Len(aVrtLns)
                oModelVrt:GoLine(aVrtLns[nX])
                oModelVrt:DeleteLine()
            Next nX
            HELP("", 1, STR0017 + STR0052, ,; //BS - info; err on ln
                 STR0068+" "+cValToChar(oModelVrt:Length() + 1),;
                 1,0,,,,,,                                      )
        EndIf
        oModelF5M:GoLine(1)
        oModelVrt:GoLine(1)
    EndIf

Return (lPrc)


/*/
{Protheus.doc} RU06D0722_WriteFromMBr()
Function to write line in Vrt grid and F5M grid from Mark Browse
It is called from menu defined in RU06XFUN14_MBrwMenu
Please, don't use Posicione(), DBSeek(), ExistCPO(), because
all data can be get by one sql query which located in 
RU06XFUN15_MyCreaTRB function.
@param    Object       oTmp         // Temporary table FWTemporaryTable()
          Object       oDlg         // link to MarkBrowse Dialog
          Character    cMark        // Indicator of the marked line in oTemp (E2_OK)
          Character    cAPTip       // default "", it can be "PA" or so on ...
          Numeric      nPAVal       // if cAPTip == "PA" nPAVal should be more than 0
          Numeric      nPAVAT       // if cAPTip == "PA" nPAVAT should be more than 0
@return   Logical      lPrc         // .T.  - all is ok
@author natalia.khozyainova
@since 10/12/2018
@edit   astepanov   15 July 2019
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0722_WriteFromMBr(oTmp   As Object   , oDlg   As Object, cMark   As Character,;
                                cAPTip As Character, nPAVal As Numeric, nPAVAT As Numeric   )
    Local oModelF5M   As Object
    Local oModelF4C   As Object
    Local oModelVrt   As Object
    Local nF5MLen     As Numeric
    Local nVrtLen     As Numeric
    Local nX          As Numeric
    Local nVATRAT     As Numeric
    Local cAlias      As Character
    Local cF4C_CUUID  As Character
    Local cErrMsg     As Character
    Local cNaturez    As Character
    Local aArea       As Array
    Local aF5MLns     As Array
    Local aVrtLns     As Array
    Local aF5MFlds    As Array
    Local aVrtFlds    As Array
    Local aE2Tm       As Array
    Local aInp        As Array
    Local aTotals     As Array
    Local lNoAddFtLn  As Logical
    Local lInflow     As Logical
    Local dTrnDate    As Date
    Local xVal
    Default cMark     := " "
    Default cAPTip    := ""
    Default nPAVal    := 0
    Default nPAVAT    := 0

    oModel     := FwModelActive() //"RU06D07" should be active
    oModelF4C  := oModel:GetModel("RU06D07_MHEAD")
    oModelF5M  := oModel:GetModel("RU06D07_MLNS")
    oModelVrt  := oModel:GetModel("RU06D07_MVIRT")
    oModelVrt:SetNoInsertLine(.F.)
    oModelVrt:SetNoUpdateLine(.F.)
    oModelVrt:SetNoDeleteLine(.F.)
    dTrnDate   := oModelF4C:GetValue("F4C_DTTRAN")
    cF4C_CUUID := oModelF4C:GetValue("F4C_CUUID")
    lInflow    := (oModelF4C:GetValue("F4C_OPER") == "1")
    aF5MLns    := {}
    aVrtLns    := {}
    cErrMsg    := ""
    aArea      := GetArea()
    lNoAddFtLn := oModelVrt:IsEmpty() .AND. oModelF5M:IsEmpty()
    aF5MFlds   := ACLONE(oModelF5M:GetStruct():GetFields())
    aVrtFlds   := ACLONE(oModelVrt:GetStruct():GetFields())
    aE2Tm      := RU06XFUN44_RetSE2FldsPosInFMKey(lInflow)
    aInp       := RU06XFUN45_RetF5MnVrtLnsFromAPs(oTmp  , cMark , dTrnDate, oModelF4C,;
                                                  cAPTip, nPAVal, nPAVAT, lInflow      )
    cErrMsg    := aInp[2]
    If !Empty(cErrMsg) //cErrMsg
        lPrc    := .F.
    Else
        cAlias := aInp[1]:GetAlias()
        DBSelectArea(cAlias)
        DbGoTop()
        lPrc := .T.
    EndIf
    nVATRAT  := 0
    cNaturez := ""
    While lPrc .AND. !EoF()  //process sql query result and put data to F5M
        lPrc     := .F.      //and Vrt grids 
        nF5MLen  := oModelF5M:Length()
        If lNoAddFtLn .OR. nF5MLen < oModelF5M:AddLine() //add line to F5M grid
            For nX := 1 To Len(aF5MFlds)
                    xVal := (cAlias)->&(aF5MFlds[nX][3])
                    oModelF5M:LoadValue(aF5MFlds[nX][3], xVal)
            Next nX
            oModelF5M:LoadValue("F5M_IDDOC ", cF4C_CUUID)
            oModelF5M:LoadValue("F5M_ALIAS" , "F4C"     )
            oModelF5M:LoadValue("F5M_KEY"   ,;
                    PADR((cAlias)->B_FLORIG ,aE2Tm[1][5]," ") + "|" +;
                    PADR((cAlias)->B_PREFIX ,aE2Tm[2][5]," ") + "|" +;
                    PADR((cAlias)->B_NUM    ,aE2Tm[3][5]," ") + "|" +;
                    PADR((cAlias)->B_PARCEL ,aE2Tm[4][5]," ") + "|" +;
                    PADR((cAlias)->B_TYPE   ,aE2Tm[5][5]," ") + "|" +;
                    PADR((cAlias)->B_FORNECE,aE2Tm[6][5]," ") + "|" +;
                    PADR((cAlias)->B_LOJA   ,aE2Tm[7][5]," ")        )
            AADD(aF5MLns,oModelF5M:GetLine())
            lPrc := .T.
        Else
            lPrc := .F.
        EndIf
        nVrtLen := oModelVrt:Length() // add line to Vrt grid
        If lPrc .AND. (lNoAddFtLn .OR. nVrtLen < oModelVrt:AddLine())
            For nX := 1 To Len(aVrtFlds)
                    xVal := (cAlias)->&(aVrtFlds[nX][3])
                    oModelVrt:LoadValue(aVrtFlds[nX][3],xVal)
            Next nX
            AADD(aVrtLns,oModelVrt:GetLine())
        Else
            lPrc := .F.
        EndIf
        nVATRAT  := (cAlias)->B_ALIMP1
        cNaturez := (cAlias)->B_CLASS
        DBSkip()
        lNoAddFtLn := .F.
    EndDo
    If !Empty(cAlias)
        (cAlias)->(DBCloseArea())
        aInp[1]:Delete()
    EndIf
    RestArea(aArea)
    // https://jiraproducao.totvs.com.br/browse/RULOC-964
    If lPrc .AND. !lInflow .AND. Empty(oModelF4C:GetValue("F4C_VATRAT"))
        oModelF4C:LoadValue("F4C_VATRAT" ,nVATRAT )
    EndIf
    If lPrc .AND. Empty(oModelF4C:GetValue("F4C_CLASS"))
        oModelF4C:LoadValue("F4C_CLASS"  ,cNaturez)
    EndIf
    If !lPrc
        If Empty(cErrMsg)
            // If there are some problems with line adding
            // delete all added lines and show help message
            For nX := 1 To Len(aVrtLns)
                oModelVrt:GoLine(aVrtLns[nX])
                oModelVrt:DeleteLine()
            Next nX
            cErrMsg := STR0068+" "+cValToChar(oModelVrt:Length() + 1)
        EndIf
        HELP("", 1, STR0017 + STR0052, ,; //BS - info; err on ln
             cErrMsg,;
             1,0,,,,,,                  )
    EndIf
    If !Empty(oDlg)
        oDlg:End()
        aTotals := RU06D07E7_RetTotalsForHeader(oModelVrt, "VRT",lInflow)
        If lInflow
            oModelF4C:LoadValue("F4C_ITTOTA",aTotals[1])
            oModelF4C:LoadValue("F4C_ITVATF",aTotals[2])
            oModelF4C:LoadValue("F4C_ITVATO",aTotals[3])
            oModelF4C:LoadValue("F4C_ITBALA", oModelF4C:GetValue("F4C_VALUE") - aTotals[1])
        Else
            oModelF4C:LoadValue("F4C_VALUE" ,aTotals[1])
            oModelF4C:LoadValue("F4C_VATAMT",aTotals[2])
        EndIf
        nX := oModelVrt:GetLine()
        lPrc := RU06D0717_Rsn()
        oModelVrt:GoLine(nX)
    EndIf
    oModelVrt:GoLine(1)
    oModelVrt:SetNoInsertLine(.T.)
Return (lPrc)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0730_RecalcCurrency
Function to Recalculate Currency Rate. 
It is called from F4C_DTTRAN x3_valid + from button 
@type function
@author natalia.khozyainova
@since 12/02/2019
@version 1.0
/*/ 
//-------------------------------------------------------------------
Function RU06D0730_RecalcCurrency(lForced)

    Local oModel      As Object
    Local oModelHdr   As Object
    Local oModelVrt   As Object
    Local oView       As Object
    Local lAutoIns    As Logical
    Local aArea       As Array
    Local lRet        As Logical
    Local nCPos       As Numeric
    Local nX          As Numeric

    Default lForced := .F.

    lAutoIns   := RU06D07036_GetlAutoIns()
    aArea      := GetArea()
    lRet       := .T.
    If lAutoIns 
         If lRet 
            oModel     := FWModelActive()
            // we set private var lUpdReason
            // for preventing reason changing
            // when we change each line in RU06D07_MVIRT
            // so we should update reason additionally
            lUpdReason := .F.
            If oModel != Nil .AND. oModel:GetID() == "RU06D07"
                oModelVrt := oModel:GetModel("RU06D07_MVIRT")
                oModelHdr := oModel:GetModel(__cMdlHdr)
                If !oModelVrt:IsEmpty()
                    oModelVrt:SetNoUpdateLine(.F.)
                    nCPos     := oModelVrt:GetLine()
                    nX       := 1
                    lAskAMErRU := .F. // don't ask about changing exchange rate
                    While lRet .AND. nX <= oModelVrt:Length()
                        oModelVrt:GoLine(nX)
                        // so we change currency when we have no flag for manual changed
                        // currency and when currency in the line not equal to currency in the header
                        // or currency in line is not equal to 1
                        If AllTrim(oModelVrt:GetValue("B_TYPE")) $ "PA|RA"
				            oModelVrt:LoadValue("B_EMISS" ,oModelHdr:GetValue("F4C_DTTRAN"))
	        	            oModelVrt:LoadValue("B_REALMT",oModelHdr:GetValue("F4C_DTTRAN"))
		                    oModelVrt:LoadValue("B_VLCRUZ",Round(oModelVrt:GetValue("B_VALPAY")*xMoeda(1, oModelVrt:GetValue("B_CURREN"), 1, oModelHdr:GetValue("F4C_DTTRAN"), GetSX3Cache("F5M_EXGRAT","X3_DECIMAL")),GetSX3Cache("E2_VLCRUZ","X3_DECIMAL")))
                        EndIf
                        If !oModelVrt:IsDeleted() .AND. oModelVrt:GetValue("B_CHECK") == .F. .AND.;
                           RU06D06011_CanChangeExchangeRateInLine(oModelVrt,oModelHdr)
                            // when we use this setvalue combination, currency will be updated
                            lRet := lRet .AND. oModelVrt:SetValue("B_CHECK",.T.)
                            lRet := lRet .AND. oModelVrt:SetValue("B_CHECK",.F.)
                        EndIf
                        nX := nX + 1
                    EndDo
                    lAskAMErRU := .T.
                    oModelVrt:GoLine(nCPos)
                    If lRet
                        // update reason
                        lUpdReason := .T.
                        lRet := lRet .AND. RU06D06008_UpdateReason()
                    EndIf
                EndIf
            EndIf
        EndIf
        If lRet
            oView := FWViewActive()
            If oView <> Nil .AND. ValType(oView) == "O" .AND. oView:oModel:cID == "RU06D07"
                oView:Refresh()
            EndIf
        EndIf
    EndIf
    RestArea(aArea)

Return (.T.)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D0731_ViewFPost

Function Used to prepare the Financial Post confirmation screen

@param       Numeric nOperation
                     1 - Post
                     2 - Unpost
                     3 - Reverse
                     4 - Replace
@return      Logical lRet
@example     
@author      astepanov
@since       February/15/2019
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU06D0731_ViewFPost(nOperation)

    Local lRet       As Logical
    Local aEnButtons As Array
    Local bOk        As Block
    Local oModel     As Object
    Local aAllwdOp   As Array
    Local cbOkFun    As Character
    Local cButtonCap As Character
    Local cCap       As Character
    Local nX         As Numeric
    Local nFWExecOp  As Numeric
    Local nRecF4c    As Numeric
    Local aArea      As Array
    Local nIndxF4c   As Numeric
    Local bCancel    As Block
    
    Private lCmtRU6D7  := .F.
    Private lIsFinPost := .F.
    
    lRet := .F.
    aAllwdOp := {1,2,3,4}  /*Allowed opeartions*/
    Do Case /* check recieved operation in the list of allowed operations*/
        Case ValType(nOperation) == "N"
            For nX := 1 To Len(aAllwdOp)
                If nOperation == aAllwdOp[nX]
                    lRet := .T.
                    Exit
                EndIf
            Next nX
    EndCase /* check recieved operation in the list of allowed operations*/
    If lRet 
        Do Case              /*numbers from aAllwdOp*/
            Case nOperation == 1
                cButtonCap := STR0042 //Post
            Case nOperation == 2 
                cButtonCap := STR0043 //Unpost
            Case nOperation == 3
                cButtonCap := STR0086 //Reverse
            Case nOperation == 4
                cButtonCap := STR0153 //Replace
            OtherWise
                cButtonCap := STR0123 //"Ok"
        EndCase
        Do Case // status checking
            Case nOperation == 1 .AND. (Val(("F4C")->F4C_STATUS) == 2 .or. Val(("F4C")->F4C_STATUS) == 5)  //already posted in financial
                HELP("", 1, STR0017 + STR0052, ,;
                        STR0050 + STR0044 + STR0045,;
                        1,0,,,,,,;
                        {STR0055})
                lRet := .F.
            Case nOperation == 2 .AND. Val(("F4C")->F4C_STATUS) == 7 //already posted in accounting
                HELP("", 1, STR0017 + STR0052, ,;
                        STR0050 + STR0044 + STR0046,;
                        1,0,,,,,,;
                        {STR0053 + STR0044 + STR0046})
                lRet := .F.
            Case nOperation == 2 .AND. Val(("F4C")->F4C_STATUS) == 1 //not posted in financial
                HELP("", 1, STR0017 + STR0052, ,;
                        STR0054 + STR0044 + STR0045,;
                        1,0,,,,,,;
                        /*{"solution"}*/)
                lRet := .F.
            Case nOperation == 2 .AND. (Val(("F4C")->F4C_STATUS) == 3  .OR. ;
                                         Val(("F4C")->F4C_STATUS) == Val(S_REPLACEMENT) ) // 4
                //not posted in financial 
                HELP("", 1, STR0017 + STR0052, ,;                    //not posted in Financial
                        STR0054 + STR0044 + STR0045,;
                        1,0,,,,,,;
                        /*{"solution"}*/)
                lRet := .F.
            Case nOperation == 3 .AND. Val(("F4C")->F4C_STATUS) == 7 //already posted in accounting 
                HELP("", 1, STR0017 + STR0052, ,;
                        STR0050 + STR0044 + STR0046,;
                        1,0,,,,,,;
                        {STR0053 + STR0044 + STR0046})
                lRet := .F.
            Case nOperation == 3 .AND. ( Val(("F4C")->F4C_STATUS) == 1  .OR. ;
                                         Val(("F4C")->F4C_STATUS) == Val(S_REPLACEMENT) ) // 4
                //not posted in financial
                HELP("", 1, STR0017 + STR0052, ,;
                        STR0054 + STR0044 + STR0045,;
                        1,0,,,,,,;
                        /*{"solution"}*/)
                lRet := .F.
            Case nOperation == 3 .AND. Val(("F4C")->F4C_STATUS) == 2 
                If lRet .AND. ;
                   RU06XFUN36_RetTaxAgentInvoicesForBS(("F4C")->F4C_CUUID)[3] != 0 // VAT inv. exist
                    HELP("", 1, STR0017 + STR0052, ,;
                        STR0048 + STR0049,; // Document editing is impossible
                        1,0,,,,,,;
                        {STR0115})          // Document has VAT invoices issued
                    lRet := .F. 
                EndIf
            Case nOperation == 4
                // document reversed or replaces and reversed
                If  Val(("F4C")->F4C_STATUS) == 3 .OR.  Val(("F4C")->F4C_STATUS) == 6                                                                                                                                      
                    If RU06XFUN49_CheckF4CUUIDRE(F4C->F4C_CUUID,.T.)
                        If IsBlind() .Or. RU06D07740_GetAutoBs()
                            HELP("", 1, STR0017 + STR0052, ,;
                                 STR0154,; // already replaced
                                 1,0,,,,,,;
                                 {STR0155}) //no actions
                            lRet := .F.
                        Else
                            lRet := MsgYesNo(STR0154,; //already replaced
	                            STR0156) //open for view?
                            If lRet
                                aArea    := GetArea()                            
                                nRecF4c  := F4C->(RecNo())
                                nIndxF4c := F4C->(IndexOrd())
                                F4C->(DBSetOrder(5))
                                If F4C->(DBSeek(xFilial("F4C")+RU06XFUN49_CheckF4CUUIDRE(F4C->F4C_CUUID,.T.,.T.)))
                                    RU06D0710_Act(1) // Open BS in View mode
                                Else
                                    HELP("", 1, STR0017 + STR0052, ,;
                                         STR0151,; // There is no replacement for this BS line 
                                         1,0,,,,,,;
                                         {STR0155}) //no actions                                
                                EndIf                      
                                RestArea(aArea)                                     
                                F4C->(DBGoTo(nRecF4c))
                                F4C->(DBSetOrder(nIndxF4c))
                                lRet := .F.
                            EndIf
                        EndIf
                    Else
                        lRet := .T.
                    EndIf
                Else
                     HELP("", 1, STR0017 + STR0052, ,;
                          STR0157,; // Document editing is impossible
                          1,0,,,,,,;
                          {STR0158}) // Cannot be replaced
                    lRet := .F.
                EndIf      
            Case Val(("F4C")->F4C_STATUS) == 3 .OR.  Val(("F4C")->F4C_STATUS) == 6
                // document reversed
                HELP("", 1, STR0017 + STR0052, ,;
                    STR0048 + STR0049,; // Document editing is impossible
                    1,0,,,,,,;
                    {STR0085}) //Reversed in Financial
                lRet := .F. 
        EndCase 
    EndIf
    If lRet
        bCancel := Nil
        Do Case
	        Case nOperation == 1
	            cbOkFun := "RU06D0732_FinancialPost(oModel)"
                nFWExecOp := MODEL_OPERATION_UPDATE
                lIsFinPost := .T.
	        Case nOperation == 2 
	            cbOkFun   := "RU06D0733_CancelFinancialPost(oModel)"
                nFWExecOp := MODEL_OPERATION_UPDATE
	        Case nOperation == 3
	            cbOkFun   := "RU06D0740_ReverseFinancialPost(oModel)"
                nFWExecOp := MODEL_OPERATION_UPDATE
                bCancel   := {|| RU06D07052_CancelWithoutAskingAboutChangesSaving()}
            Case nOperation == 4
                cbOkFun   := ".T."
                nFWExecOp := MODEL_OPERATION_INSERT
	        OtherWise
	            cbOkFun   :=  ".F."
                nFWExecOp := MODEL_OPERATION_UPDATE
	    EndCase
        aEnButtons := {{.F.,Nil},;
                    {.F.,Nil},;
                    {.F.,Nil},;
                    {.F.,Nil},;
                    {.F.,Nil},;
                    {.F.,Nil},;
                    {.T.,cButtonCap},;
                    {.T.,STR0056},;
                    {.F.,Nil},;
                    {.F.,Nil},;
                    {.F.,Nil},;
                    {.F.,Nil},;
                    {.F.,Nil},;
                    {.F.,Nil}}

        oModel := FWLoadModel("RU06D07")
        oModel := RU06D0728_TuneModelBeforePostingInFinancial(oModel, nOperation, nFWExecOp)
        bOk := {|| lRet := &(cbOkFun)}
        If nOperation == 4
            cCap := RU06D0766_ConstructTitle(3)
        Else
            cCap := STR0042 + STR0044 + STR0045 //Post in financial
        EndIf
        lRet  := FWExecView(cCap,;
                            "RU06D07",;
                            nFWExecOp,;
                            /*oDlg*/,;
                            /* {|| .T.} */,;
                            bOk,;
                            /*nPercReducao*/,;
                            aEnButtons,;
                            bCancel,;
                            /*cOperatId*/,;
                            /*cToolBar*/,;
                            oModel/*oModel*/)
    	oModel:DeActivate()
	EndIf
Return (lRet)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0728_TuneModelBeforePostingInFinancial

<Short description>

@param       Object           oModel
             Numeric          nOperation
             Numeric          nFWExecOp
@return      Object           oModel
@example     
@author      astepanov
@since       August/05/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0728_TuneModelBeforePostingInFinancial(oModel, nOperation, nFWExecOp)

    Local oModelF4C  As Object
    Local oModelVrt  As Object
    Local oModelF5M  As Object
    Local oStrF4C    As Object
    Local oTmp       As Object
    Local aFields    As Array
    Local aNoCopy    As Array
    Local aVirtual   As Array
    Local aPayFlds   As Array
    Local aRecFlds   As Array
    Local aArea      As Array
    Local aF5MPos    As Array
    Local aVrtFlds   As Array
    Local aVrtITXX   As Array
    Local aF5MFlds   As Array
    Local aDelLines  As Array
    Local aTotals    As Array
    Local aError     As Array
    Local nX         As Numeric
    local nPos       As Numeric
    Local nF5MLen    As Numeric 
    Local nFlS       As Numeric
    Local nFlL       As Numeric
    Local nPrS       As Numeric
    Local nPrL       As Numeric
    Local nNmS       As Numeric
    Local nNmL       As Numeric
    Local nPaS       As Numeric
    Local nPaL       As Numeric
    Local nTiS       As Numeric
    Local nTiL       As Numeric
    Local nQRS       As Numeric
    Local nQRL       As Numeric
    Local nKF5ML     As Numeric
    Local nValue     As Numeric
    Local nVATAMT    As Numeric
    Local nITTOTA    As Numeric
    Local nITVATF    As Numeric
    Local cWhen      As Character
    Local cAlias     As Character
    Local cLine      As Character
    Local cREASON    As Character
    Local cAdvTipo   As Character
    Local lNoAddFtLn As Logical
    Local lPrc       As Logical
    Local lInflow    As logical
    Local bPayBlock  As Block
    Local bRecBlock  As Block
    Local xVal

    aF5MPos := RU06XFUN44_RetSE2FldsPosInFMKey(IIF(F4C->F4C_OPER=="1",.T.,.F.))
    nFlS    := aF5MPos[1][4]
    nFlL    := aF5MPos[1][5]
    nPrS    := aF5MPos[2][4]
    nPrL    := aF5MPos[2][5]
    nNmS    := aF5MPos[3][4]
    nNmL    := aF5MPos[3][5]
    nPaS    := aF5MPos[4][4]
    nPaL    := aF5MPos[4][5]
    nTiS    := aF5MPos[5][4]
    nTiL    := aF5MPos[5][5]
    nQRS    := aF5MPos[7][4] + aF5MPos[7][5] + 1
    nQRL    := GetSX3Cache("F4A_CODREQ","X3_TAMANHO")
    nKF5ML  := aF5MPos[8][4]

    oModelF4C  := oModel:GetModel("RU06D07_MHEAD")
    oModelVrt  := oModel:GetModel("RU06D07_MVIRT")
    If     nFWExecOp == MODEL_OPERATION_UPDATE
        oModel:GetModel("RU06D07_MVIRT"):SetNoDeleteLine(.T.)
        oModel:GetModel("RU06D07_MVIRT"):SetOnlyView(.T.)
        oModel:GetModel("RU06D07_MVIRT"):SetNoInsertLine(.T.)
        aFields   := ACLONE(oModelF4C:GetStruct():GetFields())
        For nX := 1 To Len(aFields)
            oModelF4C:GetStruct():SetProperty(aFields[nX][3], MODEL_FIELD_WHEN, {|| .F.})
        Next nX
        If nOperation == 3
            oModelF4C:GetStruct():SetProperty("F4C_DTREVE", MODEL_FIELD_OBRIGAT, .T.)
            oModelF4C:GetStruct():SetProperty("F4C_DTREVE", MODEL_FIELD_WHEN, {|| .T.})
        EndIf
        oModel:SetOperation(4)
        oModel:Activate()
        If nOperation == 3
            oModelF4C:SetValue("F4C_DTREVE",IIF(Empty(F4C->F4C_DTREPL),IIF(dDatabase >= F4C->F4C_DTTRAN,dDatabase,F4C->F4C_DTTRAN),IIF(dDatabase >= F4C->F4C_DTREPL,dDatabase,F4C->F4C_DTREPL)))
        EndIf
    ElseIf nFWExecOp == MODEL_OPERATION_INSERT .AND. nOperation == 4
        aNoCopy   := {"F4C_FILIAL", "F4C_CUUID"  , "F4C_STATUS", "F4C_UUIDRE",;
                      "F4C_PAYORD", "F4C_IDF49"  , "F4C_INTNUM", "F4C_LA", "F4C_DTREPL", "F4C_DTREVE"}
        aVirtual  := {}
        oStrF4C   := oModelF4C:GetStruct()
        aFields   := oStrF4C:GetFields()
        oStrF4C:SetProperty("F4C_DTREPL", MODEL_FIELD_OBRIGAT, .T.)
        oStrF4C:SetProperty("F4C_DTREPL", MODEL_FIELD_WHEN, {||.T. })
        oModel:SetOperation(3)
        oModel:Activate()
        oModelF5M := oModel:GetModel('RU06D07_MLNS')
        oModelVrt:SetOnlyView(.F.)
        oModelF5M:SetNoInsertLine(.F.)
        oModelVrt:SetNoInsertLine(.F.)
        oModelVrt:SetNoDeleteLine(.F.)
        oModelF5M:SetNoDeleteLine(.F.)
        lPrc := .T.
        nX := 1
        While lPrc .AND. nX <= Len(aFields)
            //Virtual fields must not be coppied 
            //but later we must run their initializer (relacao)
            If aFields[nX][14]
                AADD(aVirtual,aFields[nX])
            ElseIf ASCAN(aNoCopy,aFields[nX][3]) == 0
                // we exclude the fields added on array aNoCopy
                cWhen := oStrF4C:GetProperty(aFields[nX][3], MODEL_FIELD_WHEN) 
                oStrF4C:SetProperty(aFields[nX][3], MODEL_FIELD_WHEN, {||.T. })
                // For F4C_RECTYP or F4C_PAYTYP we set "1" if they equal "0"
                // because comboboxes for F4C_RECTYP and F4C_PAYTYP starts from "1"
                If aFields[nX][3] $ "F4C_RECTYP|F4C_PAYTYP" .AND.;
                   F4C->&(aFields[nX][3]) == "0"
                    lPrc := lPrc .AND. oModelF4C:LoadValue(aFields[nX][3] , "1")
                Else
                    lPrc := lPrc .AND. oModelF4C:LoadValue(aFields[nX][3] , F4C->&(aFields[nX][3]))
                EndIf
                oStrF4C:SetProperty(aFields[nX][3], MODEL_FIELD_WHEN, cWhen   )				
            EndIf
            nX := nX + 1
        EndDo
        If lPrc
            aPayFlds := {"F4C_KPPPAY", "F4C_BNKPAY", "F4C_PAYBIK", "F4C_PAYACC"}
            aRecFlds := {"F4C_KPPREC", "F4C_BNKREC", "F4C_RECBIK", "F4C_RECACC"}
            If     F4C->F4C_OPER == "1"
                bPayBlock := {|| RU06D0729_IsDifSuppCust("C") }
                bRecBlock := {|| .F.}
                cAdvTipo  := "RA"
                lInflow   := .T.
            ElseIf F4C->F4C_OPER == "2"
                bPayBlock := {|| .F.}
                bRecBlock := {|| RU06D0729_IsDifSuppCust("S") }
                cAdvTipo  := "PA"
                lInflow   := .F.
            EndIf
            For nX := 1 To Len(aPayFlds)
                oStrF4C:SetProperty(aPayFlds[nX], MODEL_FIELD_WHEN, bPayBlock)
            Next nX
            For nX := 1 To Len(aRecFlds)
                oStrF4C:SetProperty(aRecFlds[nX], MODEL_FIELD_WHEN, bRecBlock)
            Next nX
            lPrc := lPrc .AND. oModelF4C:SetValue("F4C_FILIAL" , xFilial("F4C"))
            lPrc := lPrc .AND. oModelF4C:LoadValue("F4C_UUIDRE", F4C->F4C_CUUID)	
            lPrc := lPrc .AND. FwFldPut("F4C_STATUS", S_REPLACEMENT,,,,.F.)
            lPrc := lPrc .AND. oModelF4C:SetValue("F4C_DTREPL",F4C->F4C_DTREVE)
        EndIf
        lNoAddFtLn := oModelF5M:IsEmpty() .AND. oModelVrt:IsEmpty()
        aVrtFlds   := ACLONE(oModelVrt:GetStruct():GetFields())
        aF5MFlds   := ACLONE(oModelF5M:GetStruct():GetFields())
        aArea  := GetArea()
        // get lines for virtal grid
        cAlias := ""
        If lPrc
            cAlias := RU06XFUN30_RetVrtLnsForOutBS(F4C->F4C_CUUID, Nil, Nil, .T.,;
                                                F4C->F4C_DTTRAN, F4C->F4C_CURREN, lInflow)
        EndIf
        If lPrc .AND. !Empty(cAlias)
            DBSelectArea(cAlias)
            DbGoTop()
        EndIf
        While lPrc .AND. !EoF()
            If AllTrim(SubStr((cAlias)->B_F5MKEY,nTiS,nTiL)) == cAdvTipo
                // pass payment in advance line
                DbSkip()
                Loop
            EndIf
            nVrtLen  := oModelVrt:Length() // add line to Vrt grid
            If (lNoAddFtLn .OR. nVrtLen < oModelVrt:AddLine())
                For nX := 1 To Len(aVrtFlds)
                    If     aVrtFlds[nX][3] == "B_EMISS" .OR.;
                           aVrtFlds[nX][3] == "B_REALMT"
                        xVal := STOD(AllTrim((cAlias)->&(aVrtFlds[nX][3])))
                    ElseIf aVrtFlds[nX][3] == "B_CHECK"
                        xVal := IIf((cAlias)->&(aVrtFlds[nX][3]) == "1", .T., .F.)
                    ElseIf aVrtFlds[nX][3] == "B_CODREQ"
                        xVal := SubStr((cAlias)->B_F5MKEY,nQRS,nQRL)
                    ElseIf aVrtFlds[nX][3] == "B_IDF4A"
                        xVal := SubStr((cAlias)->B_F5MKEY,nQRS+nQRL+1,;
                        GetSX3Cache("F4A_IDF4A","X3_TAMANHO"))
                    ElseIf aVrtFlds[nX][3] == "B_FLORIG"
                        xVal := SubStr((cAlias)->B_F5MKEY,nFlS,nFlL)
                    ElseIf aVrtFlds[nX][3] == "B_PREFIX"
                        xVal := SubStr((cAlias)->B_F5MKEY,nPrS,nPrL)
                    ElseIf aVrtFlds[nX][3] == "B_NUM"
                        xVal := SubStr((cAlias)->B_F5MKEY,nNmS,nNmL)
                    ElseIf aVrtFlds[nX][3] == "B_PARCEL"
                        xVal := SubStr((cAlias)->B_F5MKEY,nPaS,nPaL)
                    ElseIf aVrtFlds[nX][3] == "B_TYPE"
                        xVal := SubStr((cAlias)->B_F5MKEY,nTiS,nTiL)
                    Else
                        xVal := IIF(aVrtFlds[nX][4] == "C", PADR((cAlias)->&(aVrtFlds[nX][3]),aVrtFlds[nX][5]," "),;
                                    (cAlias)->&(aVrtFlds[nX][3]))
                    EndIf
                    lPrc := lPrc .AND. oModelVrt:LoadValue(aVrtFlds[nX][3],xVal)
                Next nX
            Else
                lPrc := .F.
            EndIf
            nF5MLen := oModelF5M:Length()
            If lPrc .AND. (lNoAddFtLn .OR. nF5MLen < oModelF5M:AddLine())
                For nX := 1 To Len(aF5MFlds)
                    If     aF5MFlds[nX][3] == "F5M_FILIAL"
                        xVal := xFilial("F5M")
                    ElseIf aF5MFlds[nX][3] == "F5M_IDDOC"
                        xVal := oModelF4C:GetValue("F4C_CUUID")
                    ElseIf aF5MFlds[nX][3] == "F5M_CTRBAL"
                        xVal := "1"
                    ElseIf aF5MFlds[nX][3] == "F5M_KEY"
                        xVal := AllTrim((cAlias)->&(aF5MFlds[nX][3]))
                    ElseIf aF5MFlds[nX][3] == "F5M_VLVATO"
                        xVal := (cAlias)->B_VLIMP1
                    ElseIf aF5MFlds[nX][3] == "F5M_BSVATO"
                        xVal := (cAlias)->B_BSIMP1
                    Else
                        xVal := IIF(aF5MFlds[nX][4] == "C", PADR((cAlias)->&(aF5MFlds[nX][3]),aF5MFlds[nX][5]," "),;
                                    (cAlias)->&(aF5MFlds[nX][3]))
                    EndIf
                    lPrc := lPrc .AND. oModelF5M:LoadValue(aF5MFlds[nX][3],xVal)
                Next nX
            Else
                lPrc := .F.
            EndIf
            DBSkip()
            lNoAddFtLn := .F.
        EndDo
        If lPrc .AND. !Empty(cAlias)
            (cAlias)->(DBCloseArea())
        EndIf      
        RestArea(aArea)
        If lPrc
            nValue  := oModelF4C:GetValue("F4C_VALUE" )
            nVATAMT := oModelF4C:GetValue("F4C_VATAMT")
            cREASON := oModelF4C:GetValue("F4C_REASON")
            nITTOTA := 0
            nITVATF := 0
            // delete lines when valpay more then balance
            aDelLines := {}
            cLine     := ""
            For nX := 1 To oModelVrt:Length()
                oModelVrt:GoLine(nX)
                If oModelVrt:GetValue("B_VALPAY") > oModelVrt:GetValue("B_OPBAL")
                    cLine := cValToChar(nX) + " "
                    cLine += PADR(oModelVrt:GetValue("B_FLORIG"),;
                            GetSX3Cache("E2_FILIAL" ,"X3_TAMANHO")," ") +"|"
                    cLine += PADR(oModelVrt:GetValue("B_PREFIX"),;
                            GetSX3Cache("E2_PREFIXO","X3_TAMANHO")," ") +"|"
                    cLine += PADR(oModelVrt:GetValue("B_NUM")   ,;
                            GetSX3Cache("E2_NUM"    ,"X3_TAMANHO")," ") +"|"
                    cLine += PADR(oModelVrt:GetValue("B_PARCEL"),;
                            GetSX3Cache("E2_PARCELA","X3_TAMANHO")," ") +"|"
                    cLine += PADR(oModelVrt:GetValue("B_TYPE")  ,;
                            GetSX3Cache("E2_TIPO"   ,"X3_TAMANHO")," ") +"|"
                    cLine += PADR(oModelF4C:GetValue("F4C_SUPP"),;
                            GetSX3Cache("E2_FORNECE","X3_TAMANHO")," ") +"|"
                    cLine += PADR(oModelF4C:GetValue("F4C_UNIT"),;
                            GetSX3Cache("E2_LOJA"   ,"X3_TAMANHO")," ")
                    AADD(aDelLines, cLine)
                    oModelVrt:DeleteLine()
                Else
                    nITTOTA += oModelVrt:GetValue("B_VALCNV")
                    nITVATF += oModelVrt:GetValue("B_VLVATC")
                EndIf
            Next nX
            //validate F4C value and add PA line if we need it
            If !Empty(aDelLines)
                HELP("", 1, STR0017 + STR0052, ,;
                     STR0159,; //Lines which have no enough balance will be deleted
                     1,0,,,,,,)
            EndIf
            If lInflow
                If ((nValue - nITTOTA) != 0) .OR. ((nVATAMT - nITVATF) != 0)
                    // add RA line if we need it
                    oTmp := RU06XFUN47_CreateTmpTab1(lInflow)[1]
                    RU06D0753_PreparePALineForInputInOutflowBSGrid(oTmp,oModelF4C,"X",cAdvTipo)
                    RU06D0722_WriteFromMBr(oTmp, Nil, "X", cAdvTipo,;
                                           (nValue - nITTOTA), (nVATAMT - nITVATF))
                EndIf
                aTotals := RU06D07E7_RetTotalsForHeader(oModelVrt, "VRT", lInflow)
                oModelF4C:LoadValue("F4C_ITTOTA",aTotals[1])
                oModelF4C:LoadValue("F4C_ITBALA",oModelF4C:GetValue("F4C_VALUE") - aTotals[1])
                oModelF4C:LoadValue("F4C_ITVATF",aTotals[2])
                oModelF4C:LoadValue("F4C_ITVATO",aTotals[3])
            Else
                oModelF4C:LoadValue("F4C_VALUE" , nValue )
				oModelF4C:LoadValue("F4C_VATAMT", nVATAMT)
                RU06D0759_RecalcValue(.T.,.T.)
                //delete this line if want do not restore previous reason
                oModelF4C:LoadValue("F4C_REASON", cREASON)
            EndIf
            //Initialize virtual fields
            // exclude from virtual fields F4C_ITTOTA, F4C_ITBALA, F4C_ITVATF, F4C_ITVATO
            aVrtITXX = {"F4C_ITTOTA", "F4C_ITBALA", "F4C_ITVATF", "F4C_ITVATO"}
            For nX := 1 To Len(aVrtITXX)
                nPos := ASCAN(aVirtual, {|x| x[3] == aVrtITXX[nX]})
                ADEL(aVirtual,nPos)
            Next nX
            nX := 1
            While nX <= Len(aVirtual) .AND. aVirtual[nX] != Nil
                // get X3_RELACAO, and put result to the field
                If !Empty(GetSX3Cache(aVirtual[nX][3], "X3_RELACAO"))
                    oModelF4C:LoadValue(aVirtual[nX][3],;
                        &(GetSX3Cache(aVirtual[nX][3], "X3_RELACAO")))
                EndIf
                nX := nX + 1
            EndDo
            //virtual model only for view
            oModelVrt:SetOnlyView(.T.)  
        EndIf
    EndIf
    If oModel:HasErrorMessage()
        aError := oModel:GetErrorMessage()
        If !RU06D07740_GetAutoBs()
	        HELP("",1,  STR0017 + STR0052,,;  //BS - information
	        aError[MODEL_MSGERR_IDFIELDERR] + " "+;
	        aError[MODEL_MSGERR_MESSAGE],;    //Field and error
	        1,0,,,,,,;
	        {aError[MODEL_MSGERR_SOLUCTION]}) //Solution
    	EndIf 
    EndIf 
Return (oModel) /*-----------------------------RU06D0728_TuneModelBeforePostingInFinancial*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0729_IsDifSuppCust
    Function Used To check if the Supplyer or Customer has changed 
    during the Replacement operation 
@author eduardo.Flima
@since 08/05/2019
@version P12.1.Xx
@Parameter  Character      cSuppCust   // "S" for supplier or "C" for Customer     
@Return
    lRet:   Logicaly, Returns if the supplyer has changed or if it`s the same.
@project MA3 - Russia
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0729_IsDifSuppCust(cSuppCust)

    Local lRet       As Logical
    lRet := .T.
    If     cSuppCust = "S"  //Supplier
        lRet := F4C->F4C_SUPP + F4C->F4C_UNIT != ;
            PADR(FwFldGet("F4C_SUPP"),GetSX3Cache("F4C_SUPP","X3_TAMANHO"), " ") + ;
            PADR(FwFldGet('F4C_UNIT'),GetSX3Cache("F4C_UNIT","X3_TAMANHO"), " ")
    ElseIf cSuppCust = "C" //Customer
        lRet := F4C->F4C_CUST + F4C->F4C_CUNI != ;
            PADR(FwFldGet("F4C_CUST"),GetSX3Cache("F4C_CUST","X3_TAMANHO"), " ") + ;
            PADR(FwFldGet("F4C_CUNI"),GetSX3Cache("F4C_CUNI","X3_TAMANHO"), " ")
    EndIf

Return (lRet) /*--------------------------------------------------RU06D0729_IsDifSuppCust*/


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0732_FinancialPost

Function used to commit the Financial posting Process of a bank statment
line for prepayment and non-prepayment

@param       Object  oModelExt  //already activated model, it can be Nil
Private      Logical lCmtRU6D7 // will be changed to True if there is no need for 2nd commit,
                               // initial value should be .F.
@return      Logical lRet
@example     
@author      astepanov
@since       February/15/2019
@version     1.0
@project     MA3
@see         None
//----------------------------------------------------------------------------------------/*/
Function RU06D0732_FinancialPost(oModelExt)

    Local oModel    As Object
    Local oModelF4C As Object
    Local oModelF5M As Object
    Local oView     As Object
    Local aArea     As Array
    Local aTmpArea  As Array
    Local aRecBx    As Array
    Local aTxMoedas As Array
    Local aRes      As Array
    Local aF5MKey   As Array
    Local aLockedF5M As Array
    Local lPrc      As Logical
    Local lCmt      As Logical
    Local lDeAct    As Logical
    Local cKey      As Character
    Local cHlpMsg   As Character
    Local cIDProc   As Character
    Local cStatus   As Character
    Local cAdvance  As Character
    Local cWorkTab  As Character
    Local cSaldoFl  As Character
    Local cAdvTipo  As Character
    Local nX        As Numeric
    Local nPsPrLnNP As Numeric
    Local nFK5VLM2TO As Numeric
    Local bFunPost  As Block
    Local bFunDlAd  As Block
    Local dDTTRAN   As Date


    lRet      := .T.
    aRecBx    := {}
    aArea     := GetArea()

    If ValType(oModelExt) == "O"
        If oModelExt:cID == "RU06D07"
            oModel := oModelExt
            lDeAct := .F.
        Else
            lRet := .F.
        EndIf
    Else
        oModel := FWLoadModel("RU06D07")
        If ValType(oModel) == "O"
            oModel:SetOperation(4)
            oModel:Activate()
            lDeAct := .T.
        Else
            lRet := .F.
        EndIf
    EndIf
    oModelF4C := oModel:GetModel("RU06D07_MHEAD")
    oModelF5M := oModel:GetModel("RU06D07_MLNS" )
    oModelVrt := oModel:GetModel("RU06D07_MVIRT")
    dDTTRAN   := IIF(oModelF4C:GetValue("F4C_STATUS")==S_REPLACEMENT,oModelF4C:GetValue("F4C_DTREPL"),oModelF4C:GetValue("F4C_DTTRAN"))
    cAdvance  := oModelF4C:GetValue("F4C_ADVANC")
    If      oModelF4C:GetValue("F4C_OPER") == "1" //Inflow  BS
        cWorkTab := "SE1"
        cSaldoFl := "E1_SALDO"
        cAdvTipo := "RA"
        bFunPost := {|w,x,y,z,t,o| RU06D07022_InflowFinPost(w,x,y,z,t,@o) }
        bFunDlAd := {|x,y,z,t| RU06D07027_FI040DELRA(x,y,z,t)}
    ElseIf  oModelF4C:GetValue("F4C_OPER") == "2" //Outflow BS
        cWorkTab := "SE2"
        cSaldoFl := "E2_SALDO"
        cAdvTipo := "PA"
        bFunPost := {|w,x,y,z,t,o| RU06D07023_OutflowFinPost(w,x,y,z,t,@o)}
        bFunDlAd := {|x,y,z,t| RU06D0743_FI050DELPA(x,y,z,t) }
    EndIf
    cHlpMsg := ""
    aRes := IIF(lRet, RU06D07020_PostPreValid(oModelF4C,oModelVrt,cAdvTipo), {.F.,cHlpMsg})
    lRet := aRes[1]
    // Initialize Array with currency and currency names according to the SM2 file
    aTxMoedas := IIF(lRet, RU06D0742_CurrenciesArray(oModelF4C:GetValue("F4C_DTTRAN")), {}) //Exchange rates we always get on date of transaction
    If lRet .AND. Empty(oModelF4C:GetValue("F4C_DTPAYM")) //F4C_DTPAYM default if empty
        oModelF4C:GetStruct():SetProperty("F4C_DTPAYM", MODEL_FIELD_WHEN, {|| .T.})
        lRet := oModelF4C:SetValue("F4C_DTPAYM", dDataBase)
    EndIf
    lPrc := .T.
    nFK5VLM2TO := 0 // total FK5_VLMOE2 values by lines
    BEGIN TRANSACTION /*TRANSACTION-------------------------------------------------------*/
    lRet := lRet .AND. LockSubmdF(oModelF5M,@aLockedF5M)
    If lRet
        If     cAdvance == "1" /*only prepayment variant----------------------------------*/
            nPsPrLnNP := 1
            oModelVrt:GoLine(nPsPrLnNP)
            oModelF5M:GoLine(nPsPrLnNP)
            lPrc := RU06D07028_BSAdvanceLineFinPost(cAdvTipo ,cWorkTab,oModelF4C,oModelF5M,;
                                                    oModelVrt,aTxMoedas,.T.,@nFK5VLM2TO    )
            /*only prepayment variant-----------------------------------------------------*/
        ElseIf cAdvance == "2" /*non-only prepayment variant------------------------------*/
            cIDProc  := FINFKSID("FKA","FKA_IDPROC")
            aTmpArea := GetArea()
            DBSelectArea(cWorkTab)
            DBSetOrder(1)
            nX        := 1
            nPsPrLnNP := 0
            While lPrc .AND. nX <= oModelVrt:Length() /* Go through Virtual table---------*/
                oModelVrt:GoLine(nX)
                aF5MKey := RU06D07021_GetAF5MKey(oModelF4C, oModelVrt)
                cKey    := RU06D0749_GencF5MKey(aF5MKey[4][2], cWorkTab)
                If !(AllTrim(oModelVrt:GetValue('B_TYPE')) == cAdvTipo) // non prepayment line
                    If DBSeek(cKey) .AND. RecLock(cWorkTab, .F.)
                        If (cWorkTab)->&(cSaldoFl) >= oModelVrt:GetValue("B_VALPAY")
                            aRes := Eval(bFunPost,cIDProc,aTxMoedas,oModelF4C,oModelVrt,cWorkTab,@nFK5VLM2TO)
                            lPrc := aRes[1]
                        Else
                            cHlpMsg := STR0069 + cValToChar(nX) //error: no saldo
                            lPrc := .F.
                        EndIf
                        (cWorkTab)->(MSUnlock())
                    Else
                        lPrc := .F.
                    EndIf
                    If lPrc .AND. oModelF5M:SeekLine(aF5MKey)
                        lPrc := oModelF5M:SetValue("F5M_CTRBAL", "2")
                        lPrc := lPrc .AND.;
                                RU06D07024_UpdateARecBxForAccountingPosting(@aRecBx,cWorkTab   ,;
                                                                            oModelF4C,oModelF5M,;
                                                                            cKey  ,oModelF4C:GetValue("F4C_STATUS")==S_REPLACEMENT)     
                    Else
                        cHlpMsg := STR0068 + cValToChar(nX) //error on line 
                    EndIf
                Else //prepyment line B_TYPE == "PA" or "RA"
                    If oModelF5M:SeekLine(aF5MKey)
                        nPsPrLnNP := oModelF5M:GetLine()
                        lPrc := RU06D07028_BSAdvanceLineFinPost(cAdvTipo ,cWorkTab ,;
                                                                oModelF4C,oModelF5M,;
                                                                oModelVrt,aTxMoedas,.F.,@nFK5VLM2TO )
                    Else
                        lPrc    := .F.
                        cHlpMsg := STR0068 + cValToChar(nX) //error
                    EndIf
                EndIf
                nX := nX + 1
            EndDo /*----------------------------------------------Go through Virtual table*/
            RestArea(aTmpArea)  
        EndIf
    EndIf
    lCmt := .F.
    Do Case
        Case lRet .AND. lPrc
            oModelF4C:GetStruct():SetProperty("F4C_STATUS", MODEL_FIELD_WHEN, {|| .T.})
            cStatus := oModelF4C:GetValue("F4C_STATUS")
            If     cStatus == S_CREATED
                cStatus := S_FIN_POS
            ElseIf cStatus == S_REPLACEMENT
                cStatus := S_REPL_POST
            EndIf 
            lCmt    := oModelF4C:SetValue("F4C_STATUS", cStatus)
            lCmt    := lCmt .AND. oModel:VldData()
            If lCmt // commit data after validation
                lCmt := !FwInTTSBreak() .AND. oModel:CommitData()
            Else
                cHlpMsg := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
				cHlpMsg += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
				cHlpMsg += cValToChar(oModel:GetErrorMessage()[6])
                If nPsPrLnNP > 0 // so, error during validation - rall back PA or RA
                    oModelF5M:GoLine(nPsPrLnNP)
                    aRes := Eval(bFunDlAd, oModel, oModelF4C, oModelF5M, cWorkTab)
                EndIf
            EndIf
            If lCmt .AND. nPsPrLnNP > 0 // post in accounting advance line
                oModelF5M:GoLine(nPsPrLnNP)
                aF5MKey := StrTokArr(oModelF5M:GetValue("F5M_KEY"),"|") 
                lCmt := RU06D07850_AccountPostAdv(aF5MKey,cWorkTab,cStatus==S_REPL_POST) 
            EndIf
            If lCmt .AND. !Empty(aRecBx) //post in acc postpay for payables or recivables
                lCmt := RU06D07900_AccountPostPstpay(aRecBx, cWorkTab,cStatus==S_REPL_POST)    
            EndIf
            If lCmt .AND. cAdvance == "2" // create bank transaction
                lCmt := RU06D0750_BankTransaction(oModel, cIDProc, aTxMoedas,cStatus==S_REPL_POST,nFK5VLM2TO)
            EndIf
            lCmt := lCmt .AND. RU06D07840_AccountPostHeader(cStatus==S_REPL_POST) //post header in acc
            cHlpMsg := IIF(!lCmt .AND. Empty(cHlpMsg), STR0070 /*data save error*/,cHlpMsg)
    EndCase
    If lRet .AND. !lCmt
        DisarmTransaction()
    EndIf
    UlckSbmdFl(aLockedF5M)
    END TRANSACTION /*---------------------------------------------------------TRANSACTION*/
    Do Case /*Message confirmation--------------------------------------------------------*/
        Case lRet .AND. lCmt
            oView                    := FWViewActive()
            If !Empty(oView)
                oView:lModify        := .T.
                oView:oModel:lModify := .T.
                oView:ShowUpdateMsg(.T.)
                oView:SetUpdateMessage(STR0065 + STR0044 + STR0045, STR0050 + STR0071) //suc
            EndIf
        Case lRet .AND. !lCmt
            If !RU06D07740_GetAutoBs()
	            HELP("",1,STR0065 + STR0044 + STR0045,,;
	                STR0054 + (iif(len(aRes) >= 2 .and. !empty(aRes[2]), CHR(13)+CHR(10) +aRes[2],"")),1,0,,,,,,;
	                {cHlpMsg ,STR0072}) //fail
            else
                oModelF4C:oFormModel:SetErrorMessage(,,,,STR0065 + STR0044 + STR0045,cHlpMsg,STR0072,,)
            EndIf
            	lRet := .F.
    EndCase /*--------------------------------------------------------Message confirmation*/
    If lDeAct .AND. oModel:IsActive()
        oModel:DeActivate()
    EndIf
    If lRet .AND. !lDeAct
        lCmtRU6D7 := .T. //no needs for second commit
    EndIf
    RestArea(aArea)

Return (lRet) /*---------------------------------------------------RU06D0732_FinancialPost*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0733_CancelFinancialPost

Function for cancelling financial post

@param       Object  oModelExt //pased model, it can be Nil 
Private      Logical lCmtRU6D7
Static       Logical lUsaFlag
@return      Logical lRet
@example     
@author      astepanov
@since       February/21/2019
@version     1.0
@project     MA3
@see         None

//---------------------------------------------------------------------------------------/*/
Function RU06D0733_CancelFinancialPost(oModelExt)

    Local lRet       As Logical
    Local lPrc       As Logical
    Local lCmt       As Logical
    Local lDeAct     As Logical
    Local lFirst     As Logical
    Local aArea      As Array
    Local aTmpArea   As Array
    Local aRes       As Array
    Local aRecBx     As Array 
    Local aRecsE5    As Array 
    Local aLockedF5M As Array    
    Local oModel     As Object
    Local oModelF4C  As Object
    Local oModelF5M  As Object
    Local oView      As Object
    Local cINTNUM    As Character
    Local cKey       As Character
    Local cHlpMsg    As Character
    Local cStatus    As Character
    Local cArquivo   As Character
    Local cIdProcH   As Character
    Local cIdProcItn As Character
    Local cPadraoL   As Character
    Local cPadraoH   As Character
    Local cArqBx     As Character
    Local cAdvance   As Character
    Local cWorkTab   As Character
    Local cAdvTipo   As Character
    Local cTipoFld   As Character
    Local cSinal     As Character
    Local cFKX       As Character
    Local nX         As Numeric
    Local nHndlF4C   As Numeric
    Local nRecFK5    As Numeric
    Local nRecFKX    As Numeric
    Local nRecSE5    As Numeric
    Local nHdlF5M    As Numeric
    Local dDTTRAN    As Date

    lRet   := .T.
    lFirst := .T.
    aArea  := GetArea()
    aRecsE5 := {}

    If ValType(oModelExt) == "O" /*Model activation---------------------------------------*/
        If oModelExt:cID == "RU06D07"
            oModel := oModelExt
            lDeAct := .F.
        Else
            lRet   := .F.
        EndIf
    Else
        oModel := FWLoadModel("RU06D07")
        If ValType(oModel) == "O"
            oModel:SetOperation(4)
            lDeAct := .T.
            oModel:Activate() /*------------------------------------------Model activation*/
        Else
            lRet   := .F.
        EndIf
    EndIf
    If lRet
        oModelF4C    := oModel:GetModel("RU06D07_MHEAD")
        oModelF5M    := oModel:GetModel("RU06D07_MLNS" )
        cINTNUM      := oModelF4C:GetValue("F4C_INTNUM")
        dDTTRAN      := IIF(oModelF4C:GetValue("F4C_STATUS")==S_REPL_POST,oModelF4C:GetValue("F4C_DTREPL"),oModelF4C:GetValue("F4C_DTTRAN"))
        /*check document status-----------------------------------------------------------*/
        If oModelF4C:GetValue("F4C_STATUS") $ (S_FIN_POS + "|" + S_REPL_POST)
            lRet    := .T.
        Else
            lRet    := .F.
            cHlpMsg :=  STR0054 + STR0044 + STR0045 // Not posted in Financial
        EndIf
    EndIf
    /*---------------------------------------------------------------check document status*/
    If lRet .AND. !IsBlind() .And. !RU06D07740_GetAutoBs() /*Cancel posting confirmation--------------------------------*/
            lRet := MsgYesNo(STR0073; //confirm posting cancel
                             + CHR(10) + AllTrim(cINTNUM) + " " + STR0044 + STR0045 + "?",;
                             STR0056 + STR0074 + STR0044 + STR0045) //cancel post in fin
    EndIf
    cPadraoH    := ""
    cPadraoL    := ""
    cAdvance    := oModelF4C:GetValue("F4C_ADVANC")
    If oModelF4C:GetValue("F4C_OPER") == "1" //Inflow  BS
        cWorkTab := "SE1"
        cFKX     := "FK1"
        cTipoFld := "SE1->E1_TIPO"
        cAdvTipo := "RA"
        cSinal   := "-"
        cPadraoH := LP_576_INFCACCP
        cPadraoL := LP_527_AR_CWRFF
        bFunDlAd := {|w,x,y,z,t,u| RU06D07027_FI040DELRA(w,x,y,z,t,u)}
    ElseIf oModelF4C:GetValue("F4C_OPER") == "2" //Outflow BS
        cWorkTab := "SE2"
        cFKX     := "FK2"
        cTipoFld := "SE2->E2_TIPO"
        cAdvTipo := "PA"
        cSinal   := "+"
        cPadraoH := LP_571_CNCLACPS
        cPadraoL := LP_531_AP_CWRFF
        bFunDlAd := {|w,x,y,z,t,u| RU06D0743_FI050DELPA(w,x,y,z,t,u) }
    EndIf
    lPrc := .T.
    BEGIN TRANSACTION /*TRANSACTION-------------------------------------------------------*/
    nHndlF4C   := 0
    cArquivo   := ""
    cIdProcH   := ""
    cIdProcItn := ""
    aRecBx     := {}
    If !Empty(cPadraoH) .AND. VerPadrao(cPadraoH)
        nHndlF4C  := RU06D07017_RetNHndlBxPrv(@cArquivo)
        If nHndlF4C <= 0
            lRet    := .F.
            cHlpMsg := STR0162 //A100NOPROV
        EndIf
        nRecFK5 := RU06D07870_RecFK5(oModelF4C:GetValue("F4C_CUUID"))
        FK5->(DBGoTo(nRecFK5)) // Positionate in the last FK5 that is not canceled
        FKA->(DBSetOrder(3))   // FKA_FILIAL+FKA_TABORI+FKA_IDORIG
        If FKA->(DBSeek(xFilial("FKA")+;
                        PADR("FK5",GetSX3Cache("FKA_TABORI","X3_TAMANHO"), " ") + ;
                        FK5->FK5_IDMOV)                                           )
            //This variable will be used to positionate again in the accuont post time
            cIdProcH := FKA->FKA_IDPROC
        EndIf
    EndIf
    lRet := lRet .AND. LockSubmdF(oModelF5M,@aLockedF5M)
    Do Case
        Case lRet .AND. cAdvance == "1"
            // when cAdvance == "1", we have only 1 line in F5M
            oModelF5M:GoLine(1)
            F5M->(DbSetOrder(1)) //F5M_FILIAL+F5M_ALIAS+F5M_IDDOC+F5M_KEY
            F5M->(DBSeek(oModelF5M:GetValue('F5M_FILIAL')+oModelF5M:GetValue('F5M_ALIAS')+oModelF5M:GetValue('F5M_IDDOC')+oModelF5M:GetValue('F5M_KEY')))
            aRes := Eval(bFunDlAd, oModel, oModelF4C, oModelF5M, cWorkTab, .F., dDTTRAN) //BS only advance the Bank Balance are restore at Cheque routine.
            lPrc    := aRes[1]
            cHlpMsg := aRes[2]
            //change F5M_KEY, clear Prefix and Num
            lPrc := lPrc .AND.;
                    oModelF5M:SetValue("F5M_KEY",;
            RU06D07030_ClearPrefixAndNumInF5MKey(oModelF5M:GetValue("F5M_KEY")))
        Case lRet .AND. cAdvance == "2"
            DBSelectArea(cWorkTab)
            DBSetOrder(1)
            nX := 1
            While lPrc .AND. nX <= oModelF5M:Length() /*Pass oModelF5M lines--------------*/
                oModelF5M:GoLine(nX)
                F5M->(DbSetOrder(1)) //F5M_FILIAL+F5M_ALIAS+F5M_IDDOC+F5M_KEY
                F5M->(DBSeek(oModelF5M:GetValue('F5M_FILIAL')+oModelF5M:GetValue('F5M_ALIAS')+oModelF5M:GetValue('F5M_IDDOC')+oModelF5M:GetValue('F5M_KEY')))
                cKey := RU06D0749_GencF5MKey(oModelF5M:GetValue('F5M_KEY'),cWorkTab)
                If DBSeek(cKey) .AND. RecLock(cWorkTab,.F.) /*Position to record in Work Tab SE2 or SE1-*/
                    If AllTrim(&(cTipoFld)) == cAdvTipo  // cancel advance line
                        aRes := Eval(bFunDlAd, oModel, oModelF4C, oModelF5M, cWorkTab, .T.,dDTTRAN)
                        lPrc    := aRes[1]
                        cHlpMsg := aRes[2]
                        //change F5M_KEY, clear Prefix and Num
                        lPrc := lPrc .AND.;
                                oModelF5M:SetValue("F5M_KEY",;
                        RU06D07030_ClearPrefixAndNumInF5MKey(oModelF5M:GetValue("F5M_KEY")))
                    Else // case when E2(E1)_TIPO not equal to "PA" or "RA"
                        aRes := RU06D07029_FinUnPost(oModelF4C, oModelF5M, cWorkTab, lFirst, .F.)
                        lPrc    := aRes[1]
                        cHlpMsg := aRes[2]
                        If lPrc .AND. lFirst 
                            aTmpArea := GetArea()
                            // Set E5_SITUACA to "C" for record with E5_TIPO == "VL",  
                            // E5_TIPODOC == "VL", E5_TABORI == "FK5", E5_ORDREC == F4C_INTNUM, 
                            // E5_DTDISPO == F4C_DTTRAN
                            SE5->(DbGoTo(RU06D0751_FinMovSE5(cINTNUM, dDTTRAN, cWorkTab)))
                            If SE5->(RecLock("SE5",.F.))
                                SE5->E5_SITUACA := "C"
                                SE5->E5_DTCANBX := dDataBase
                                SE5->(MsUnlock())
                            Else
                                cHlpMsg := STR0198 //record lock error
                                lPrc := .F.
                            EndIf
                            If lPrc
                                // store cIdProcItn which will be used in accounting posting
                                FKA->(DBSetOrder(3)) //FKA_FILIAL+FKA_TABORI+FKA_IDORIG
                                FKA->(DBSeek(xFilial("FKA")+cFKX+&(cFKX+"->"+cFKX+"_ID"+cFKX)))
                                cIdProcItn := FKA->FKA_IDPROC
                            EndIf
                            lFirst := .F.
                            RestArea(aTmpArea)
                        ElseIf lPrc .AND. !lFirst .AND. cWorkTab == "SE2"
                            // delete SE5 record. only for outflow BS
                            SE5->(DbGoTo(RU06D0752_FinTitSE5(cINTNUM, dDTTRAN,cWorkTab)))
                            If SE5->(RecLock("SE5",.F.))
                                SE5->(dbDelete())
                                SE5->(MsUnLock())
                            Else
                                cHlpMsg := STR0198 //record lock error
                                lPrc    := .F.
                            EndIf
                        EndIf
                        lPrc := lPrc .AND. oModelF5M:SetValue("F5M_CTRBAL", "1")
                        //Prepare aRecBx for Accounting Posting
                        If lPrc .AND. !Empty(cIdProcItn)
                            // Check if the write-off has been Posted in account 
                            // otherwise we don`t need to post the canceling
                            If RU06D07940_RecFKX_LA(cIdProcItn,oModelF5M:GetValue('F5M_KEY'),cFKX)
                                nRecFKX := RU06D07950_RecCancFKX(cIdProcItn,oModelF5M:GetValue('F5M_KEY'),cFKX)
                                If nRecFKX > 0 
                                    &(cFKX)->(DbGoTo(nRecFKX))
                                    nRecSE5 := 0
                                    SE5->(DBSetOrder(21)) //L: //E5_FILIAL+E5_IDORIG+E5_TIPODOC
                                    If SE5->(DBSeek(xFilial("SE5")+&(cFKX+"->"+cFKX+"_ID"+cFKX)+&(cFKX+"->"+cFKX+"_TPDOC")))
                                        nRecSE5 := SE5->(RecNo())
                                    EndIf
                                    AADD(aRecBx,{nRecFKX,nRecSE5,cKey,;
                                    PADR(xFilial("F5M"),GetSX3Cache("F5M_FILIAL","X3_TAMANHO")," ")+;
                                    PADR(oModelF5M:GetValue("F5M_ALIAS"),;
                                                        GetSX3Cache("F5M_ALIAS", "X3_TAMANHO")," ")+;
                                    PADR(oModelF5M:GetValue("F5M_IDDOC"),;
                                                        GetSX3Cache("F5M_IDDOC", "X3_TAMANHO")," ")+;
                                    PADR(oModelF5M:GetValue("F5M_KEY")  ,;
                                                        GetSX3Cache("F5M_KEY"  , "X3_TAMANHO")," "),;
                                    "S"     }                                                       )
                                EndIf
                            EndIf
                        EndIf
                    EndIf  // SE2->E2_TIPO != "PA" or SE1->E1_TIPO != "RA"
                    (cWorkTab)->(MSUnlock())
                Else
                    lPrc    := .F.
                EndIf
                If !lPrc
                    cHlpMsg := STR0068 + cValToChar(nX) +": "+cHlpMsg //error on line
                EndIf
                nX := nX + 1
            EndDo /*--------------------------------------------------Pass oModelF5M lines*/
            If lPrc
                aRes:= RU06D07034_GetCanceledSe5(FK5->FK5_IDMOV) 
                lPrc    := aRes[1]
                cHlpMsg := aRes[2]
            EndIf
            // post lines in accounting
            If lPrc .AND. !Empty(cPadraoL) .AND. VerPadrao(cPadraoL) .AND. Len(aRecBx) > 0
                cArqBx := ""
                nHdlF5M  := RU06D07017_RetNHndlBxPrv(@cArqBx)
                If nHdlF5M > 0
                    aRes    := RU06D07018_A100Include(nHdlF5M,@cArqBx,cPadraoL,cFKX,aRecBx,{},"",dDTTRAN)
                    lPrc    := aRes[1]
                    cHlpMsg := aRes[2]
                Else
                    lPrc    := .F.
                    cHlpMsg := STR0162 //A100NOPROV
                EndIf
            EndIf
        /*---------------------------------------------------------------is not prepayment*/
    EndCase
    lCmt := .F.
    Do Case /*Commiting-------------------------------------------------------------------*/
        Case lRet .AND. lPrc
            oModelF4C:GetStruct():SetProperty("F4C_STATUS", MODEL_FIELD_WHEN, {|| .T.})
            cStatus := oModelF4C:GetValue("F4C_STATUS")
            If     cStatus == S_FIN_POS   //2
                cStatus := S_CREATED      //1
            ElseIf cStatus == S_REPL_POST //5
                cStatus := S_REPLACEMENT  //4
            EndIf 
            lCmt    := oModelF4C:SetValue("F4C_STATUS", cStatus)
            If lCmt
                lCmt := oModel:VldData()
            EndIf
            If lCmt
                lCmt := !FwInTTSBreak() .AND. oModel:CommitData()
            EndIf
            If !lCmt
               cHlpMsg := STR0070 // data saving error
            EndIf
    EndCase /*-------------------------------------------------------------------Commiting*/
    If lCmt .AND. nHndlF4C > 0 .AND. F4C->F4C_LA == "S"
            lCmt := RU06D07930_A100Cncl(nHndlF4C  ,; //nHdlF4C
                                        cIdProcH  ,; //cIdProcHea
                                        @cArquivo ,; //cArquivo
                                        cPadraoH  ,; //cPadrao
                                        Nil       ,;  //lRev
                                        dDTTRAN ) //Transaction date
    EndIf
    If lRet .AND. !lCmt
        DisarmTransaction()
    EndIf
    UlckSbmdFl(aLockedF5M)
    END TRANSACTION /*---------------------------------------------------------TRANSACTION*/
    Do Case /*Message confirmation--------------------------------------------------------*/
        Case lRet .AND. lCmt
            oView                    := FWViewActive()
            If ! Empty(oView)
                oView:lModify        := .T.
                oView:oModel:lModify := .T.
                oView:ShowUpdateMsg(.T.)
                oView:SetUpdateMessage(STR0056 + STR0074 + STR0044 + STR0045,; //cancel
                                    STR0056 + STR0074 + STR0044 + STR0045 + ;
                                    STR0076 + STR0071) //success
            EndIf
        Case lRet .AND. !lCmt
            HELP("",1,STR0056 + STR0074 + STR0044 + STR0045,,;
                STR0077,1,0,,,,,,; //failed
                {cHlpMsg})
            lRet := .F.
    EndCase /*--------------------------------------------------------Message confirmation*/
    If lRet
        If lDeAct
            oModel:DeActivate()
        Else
            lCmtRU6D7 := .T. //no needs for second commit
        EndIf
    EndIf
    RestArea(aArea)

Return (lRet) /*---------------------------------------------RU06D0733_CancelFinancialPost*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0734_FI080Write

Static Function Used to write-off an account payable 

@param       Array   aBaixa
             Array with the key of the account payable and write-off keys in the format:
             aBaixa[1][1] == "E2_FILIAL"     aBaixa[1][2] == C:6   aBaixa[1][3]  == Nil
             aBaixa[2][1] == "E2_PREFIXO"    aBaixa[2][2] == C:3   aBaixa[2][3]  == Nil
             aBaixa[3][1] == "E2_NUM"        aBaixa[3][2] == C:8   aBaixa[3][3]  == Nil
             aBaixa[4][1] == "E2_PARCELA"    aBaixa[4][2] == C:2   aBaixa[4][3]  == Nil
             aBaixa[5][1] == "E2_TIPO"       aBaixa[5][2] == C:3   aBaixa[5][3]  == Nil
             aBaixa[6][1] == "E2_FORNECE"    aBaixa[6][2] == C:6   aBaixa[6][3]  == Nil
             aBaixa[7][1] == "E2_LOJA"       aBaixa[7][2] == C:2   aBaixa[7][3]  == Nil
             aBaixa[8][1] == "E2_MOEDA"      aBaixa[8][2] == C:2   aBaixa[8][3]  == Nil
             aBaixa[9][1] == "AUTOMOTBX"     aBaixa[9][2] == "DEB" aBaixa[9][3]  == Nil
             aBaixa[10][1] == "AUTOBANCO"    aBaixa[10][2] == C:3  aBaixa[10][3] == Nil
             aBaixa[11][1] == "AUTAGENCIA"   aBaixa[11][2] == C:9  aBaixa[11][3] == Nil
             aBaixa[12][1] == "AUTCONTA"     aBaixa[12][2] == C:34 aBaixa[12][3] == Nil
             aBaixa[13][1] == "AUTDTBAIXA"   aBaixa[13][2] == D    aBaixa[13][3] == Nil
             aBaixa[14][1] == "AUTDTCREDITO" aBaixa[14][2] == D    aBaixa[14][3] == Nil
             aBaixa[15][1] == "AUTHIST"      aBaixa[15][2] == C:40 aBaixa[15][3] == Nil
             aBaixa[16][1] == "AUTPAYORD"    aBaixa[16][2] == C:10 aBaixa[16][3] == Nil
             aBaixa[17][1] == "AUTVLRPG"     aBaixa[17][2] == N    aBaixa[17][3] == Nil

             Array   aTxExt recieves  aTxMoedas
             Array with currencies and exchange rates in the format:
             aTxExt[N][1] == <Currency name> As Character
             aTxExt[N][2] == <Exchange rate> As Numeric
             aTxExt[N][3] == <Picture> As Character in the format "@E 99,999.9999"
             Array  aBStExpPrm array prepared in RU06D07023_OutflowFinPost 
@return      Logical lRet //.T. - ok, .F. - errors during writing
@example     
@author      astepanov
@since       February/18/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D0734_FI080Write(aBaixa, aTxExt, aBStExpPrm)

    Local   lRet        As Logical
    Local   aArea       As Array
    Private lMsErroAuto := .F.

    lRet  := .T.
    aArea := GetArea()
    If Empty(aBaixa) .OR. Empty(aTxExt) .OR. ValType(aBaixa) != "A" .OR.;
       ValType(aTxExt) != "A" .OR. Len(aBaixa) < 8 .OR. Len(aTxExt) < 1
        lRet := .F.
    EndIf
    If lRet
        AcessaPerg("FIN080", .F.)
        MsExecAuto({|par1,par2,par3,par4| FINA080(par1,;  //xAutoCab         [1]
                                                  par2,;  //nOpc             [2]
                                                  ,;      //lNoMBrowse       [3]
                                                  ,;      //nOpbaixa         [4]
                                                  ,;      //lExibeLanc       [5]
                                                  .F.,;   //lOnline          [6]
                                                  ,;      //aVAAut           [7]
                                                  ,;      //aCtb430          [8]
                                                  ,;      //cLanc430         [9]
                                                  par3,;  //aTxExt          [10]
                                                   Nil,;   //lMov           [11]
                                                  ,;      //aPerg           [12]
                                                  par4 )},;//aBStExpPrm     [13] 
                                             aBaixa /*par1*/,3/*par2*/,aTxExt/*par3*/,aBStExpPrm/*par4*/ )
        If lMsErroAuto
            If !IsBlind() .And. !RU06D07740_GetAutoBs()
                MostraErro()
            EndIf
            lRet := .F.
        EndIf
    EndIf
    RestArea(aArea)

Return (lRet) /*------------------------------------------------------RU06D0734_FI080Write*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0735_CancelExRates

Function Used to Check if there are exgange rates to this bill and delete it where 
the account payable is in convenntional units

@param       Date             dFRDatadi
             Character        cTable  table of the operation
             Logical          lForcCanc  Force the cancelation even with 0 balance
             Character        cUUID F4C_CUUID by deafault or other parameter passed by user
@return      Logical          lRet .T. - all ok, .F. - in case of error
@example     
@author      astepanov
@since       February/21/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0735_CancelExRates(dFRDatadi,cTable,lForcCanc,cUUID)

    Local lRet       	As Logical
    Local cSFRChavor 	As Character
    Local cSFRChavde 	As Character
    Local cPrf     		As Character
    Local cNum     		As Character
    Local cPar     		As Character
    Local cTip     		As Character
    Local cCliFor     	As Character
    Local cLoj     		As Character
    Local cBranch    	As Character
    Local cQuery     	As Character
    Local cAlias     	As Character
    Local cCarteira  	As Character
    Local nSaldo     	As Numeric	
	Local nPrf       	As Numeric
	Local nNum       	As Numeric
	Local nPar       	As Numeric
	Local nTip       	As Numeric
	Local nCliFor    	As Numeric
	Local nLoj       	As Numeric
    Local aAreaSEX   	As Array
    Local aArea      	As Array
    Local aAreaSFR   	As Array
    Local aBStExpPrm 	As Array


    DEFAULT cTable:="SE2"
    Default lForcCanc :=.F.
    Default cUUID := ""

    lRet := .T.
    aArea    := GetArea()
    aAreaSEX := (cTable)->(GetArea())
    aAreaSFR := SFR->(GetArea())
    If cTable == "SE2"
        nSaldo      := SE2->E2_SALDO 
        cBranch     := SE2->E2_FILIAL
        cSFRChavor  := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
        cCarteira   :='2'
		nPrf   		:=GetSx3Cache("E2_PREFIXO"	,"X3_TAMANHO"	)	
		nNum   		:=GetSx3Cache("E2_NUM"		,"X3_TAMANHO"	)
		nPar   		:=GetSx3Cache("E2_PARCELA"	,"X3_TAMANHO"	)
		nTip   		:=GetSx3Cache("E2_TIPO"		,"X3_TAMANHO"	)	
		nCliFor		:=GetSx3Cache("E2_FORNECE"	,"X3_TAMANHO"	)
		nLoj   		:=GetSx3Cache("E2_LOJA"		,"X3_TAMANHO"	)
    Else
        nSaldo      := SE1->E1_SALDO 
        cBranch     := SE1->E1_FILIAL
        cSFRChavor  := SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
        cCarteira   :='1'
		nPrf   		:=GetSx3Cache("E1_PREFIXO"	,"X3_TAMANHO"	)	
		nNum   		:=GetSx3Cache("E1_NUM"		,"X3_TAMANHO"	)
		nPar   		:=GetSx3Cache("E1_PARCELA"	,"X3_TAMANHO"	)
		nTip   		:=GetSx3Cache("E1_TIPO"		,"X3_TAMANHO"	)	
		nCliFor		:=GetSx3Cache("E1_CLIENTE"	,"X3_TAMANHO"	)
		nLoj   		:=GetSx3Cache("E1_LOJA"		,"X3_TAMANHO"	)		
    Endif
    If nSaldo == 0  .OR. lForcCanc
        cQuery     := " SELECT SFR.R_E_C_N_O_   RECNO                "
        cQuery     += " FROM "+RetSqlName("SFR")+" SFR               "
        cQuery     += " WHERE  SFR.FR_FILIAL = '"+xFilial("SFR")+"'  "
        cQuery     += "   AND  SFR.FR_CARTEI = '"+cCarteira+"'      "
        cQuery     += "   AND  SFR.FR_CHAVOR = '"+cSFRChavor+"'      "
        cQuery     += "   AND  SFR.FR_DATADI = '"+DTOS(dFRDatadi)+"' "
        cQuery     += "   AND  SFR.D_E_L_E_T_ = ' '                  "
        cQuery     += " ORDER BY RECNO"  
        cQuery     := ChangeQuery(cQuery)
        cAlias     := MPSysOpenQuery(cQuery)
        DBSelectArea(cAlias)
        (cAlias)->(DBGoTop())
        While !EoF()
            SFR->(DbGoTo((cAlias)->RECNO))
            cSFRChavde := SFR->FR_CHAVDE
            If cTable == "SE2"
                cPrf     := SubStr(cSFRChavde,1										,nPrf   )		
                cNum     := SubStr(cSFRChavde,1+Len(cPrf)							,nNum   )		
                cPar     := SubStr(cSFRChavde,1+Len(cPrf+cNum)						,nPar   )		
                cTip     := SubStr(cSFRChavde,1+Len(cPrf+cNum+cPar)					,nTip   )		
                cCliFor  := SubStr(cSFRChavde,1+Len(cPrf+cNum+cPar+cTip)			,nCliFor)		
                cLoj     := SubStr(cSFRChavde,1+Len(cPrf+cNum+cPar+cTip+cCliFor)	,nLoj   )		
            Else
                cCliFor  := SubStr(cSFRChavde,1			                            ,nCliFor)		
                cLoj     := SubStr(cSFRChavde,1+Len(cCliFor)	                    ,nLoj   )		
                cPrf     := SubStr(cSFRChavde,1+Len(cCliFor+cLoj)					,nPrf   )		
                cNum     := SubStr(cSFRChavde,1+Len(cCliFor+cLoj+cPrf)				,nNum   )		
                cPar     := SubStr(cSFRChavde,1+Len(cCliFor+cLoj+cPrf+cNum)			,nPar   )		
                cTip     := SubStr(cSFRChavde,1+Len(cCliFor+cLoj+cPrf+cNum+cPar)	,nTip   )		
            Endif
            (cTable)->(DBSetOrder(1))
            If (cTable)->(DBSeek(cBranch+cPrf+cNum+cPar+cTip+cCliFor+cLoj))
                If cTable == "SE2"
                    If Empty(cUUID)
                        cUUID := F4C->F4C_CUUID
                    ENDIF
                    aBStExpPrm := RU06D07048_Init_aBStExpPrm(cUUID,,,.T.) // Set .T. that we are in exchange rates cancelling process
                    Fa084Canc(aBStExpPrm) //no returns fina084.prw
                Else
                    Fa074Canc(.T.)
                EndIf
            EndIf
            (cAlias)->(DBSkip())
        Enddo
        (cAlias)->(DBCloseArea())
    EndIf
    RestArea(aAreaSFR)
    RestArea(aAreaSEX)
    RestArea(aArea)    
    
Return (lRet) /*---------------------------------------------------RU06D0735_CancelExRates*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0736_FI080CancelWrite

Static Function Used to Cancel a write-off from a non-prepayment in a 
bank statement line 

@param       Array            aBaixa
             Array with the key of the account payable that will be write-off cancelled
             in the format: {E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,
             E2_LOJA}
@return      Logical          lRet
@example     
@author      astepanov
@since       February/21/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D0736_FI080CancelWrite(aBaixa, lMov)
Local lRet       As Logical
Local aBStExpPrm As Array
Local aArea      As Array

Private lMsErroAuto := .F.
aArea := GetArea()
lRet := .T.
aBStExpPrm := RU06D07048_Init_aBStExpPrm()
AcessaPerg("FIN080", .F.)
MsExecAuto({|par1,par2,par3,par4| FINA080(par1,;  //xAutoCab         [1]
                                        par2,;  //nOpc             [2]
                                        ,;      //lNoMBrowse       [3]
                                        ,;      //nOpbaixa         [4]
                                        ,;      //lExibeLanc       [5]
                                        .F.,;   //lOnline          [6]
                                        ,;      //aVAAut           [7]
                                        ,;      //aCtb430          [8]
                                        ,;      //cLanc430         [9]
                                        ,;      //aTxExt          [10]
                                        par3,;  //lMov            [11]
                                        par4,;  //aBStExpPrm      [12]
                                            )},aBaixa/*par1*/,5/*par2*/,lMov/*par3*/,aBStExpPrm/*par4*/)
If lMsErroAuto
    If !IsBlind() .And. !RU06D07740_GetAutoBs()
        MostraErro()
    EndIf
    lRet := .F.
EndIf
RestArea(aArea)

Return (lRet) /*------------------------------------------------RU06D0736_FI080CancelWrite*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0737_FI050IncludePA

Static Function Used to insert the account payable(SE2) of a prepayment
bank statement line which will already perform the necessary bank transactions
and the inclusion of checks 

@param  Character        cF5MKey
             Format:  "E2_FILIAL|E2_PREFIXO|E2_NUM  |E2_PARCELA|E2_TIPO|E2_FORNECE|E2_LOJA"
             Example: "M RU02   |25        |1022-11 |          |PA     |000004    |01     "
        Object           oModelF4C  // header model
        Object           oModelVrt  // virtual model
        Array            aTxMoedas  // array with currencies and exchange rates
        Logical          lCheq  //Include or not F4C_INTNUM
@return Logical          lRet .T. - ok, .F. - error
@example     
@author      astepanov
@since       February/28/2019
@edit        March/18/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D0737_FI050IncludePA(cF5MKey,oModelF4C,oModelVrt,aTxMoedas,lCheq,nFK5VLM2TO)

    Local lRet       As Logical
    Local aTit       As Array
    Local aRotAuto   As Array
    Local aArea      As Array
    Local cHist      As Character
    Local cCheq      As Character
    Local cF5QCod    As Character
    Local nExgRat    As Numeric
    Local dDTTRAN    As Date


    Private lMSErroAuto := .F.
    Default lCheq       := .T.

    aArea    := GetArea()
    lRet    := .T.
    aTit    := StrTokArr(cF5MKey,"|")
    lRet    := IIF(Len(aTit) < 7, .F., lRet)
    cCheq   := IIF(lCheq,oModelF4C:GetValue("F4C_INTNUM"),"")
    nExgRat := aTxMoedas[oModelVrt:GetValue("B_CURREN")][2]
    cF5QCod := ""
    cF5QCod := Posicione("F5Q",1,xFilial("F5Q")+oModelF4C:GetValue("F4C_UIDF5Q"),;
                         "F5Q_CODE"                                              )
    If lRet
        If oModelF4C:GetValue("F4C_STATUS") $ (S_REPLACEMENT)
            dDtTran := oModelF4C:GetValue("F4C_DTREPL")
        Else
            dDtTran:=  oModelF4C:GetValue("F4C_DTTRAN") 
        EndIf

        cHist := RU06D07010_History(1,oModelF4C:GetValue("F4C_BNKORD"),;
                                      oModelF4C:GetValue("F4C_DTPAYM") )
        //please don't change order, fields should be
        //passed in next order: E2_ALQIMP1 -> E2_VALOR ->
        //E2_VALIMP1 -> E2_BASIMP1, they are related to
        //the triggers applied to the fields.
        aRotAuto := { { "E2_FILIAL"   , aTit[1]                          , NIL },;
                      { "E2_PREFIXO"  , aTit[2]                          , NIL },;
                      { "E2_NUM"      , aTit[3]                          , NIL },;
                      { "E2_PARCELA"  , aTit[4]                          , NIL },;
                      { "E2_TIPO"     , aTit[5]                          , NIL },;
                      { "E2_FORNECE"  , aTit[6]                          , NIL },;
                      { "E2_LOJA"     , aTit[7]                          , NIL },;
                      { "E2_NATUREZ"  , oModelF4C:GetValue("F4C_CLASS" ) , NIL },;
                      { "E2_EMISSAO"  , dDtTran , NIL },;
                      { "E2_VENCTO"   , dDtTran , NIL },;
                      { "E2_VENCREA"  , dDtTran , NIL },;
                      { "E2_MOEDA"    , oModelVrt:GetValue("B_CURREN"  ) , NIL },;
                      { "E2_MDCONTR"  , oModelF4C:GetValue("F4C_CNT"   ) , NIL },;
                      { "E2_FORBCO"   , oModelF4C:GetValue("F4C_BNKREC") , NIL },;
                      { "E2_FORAGE"   , oModelF4C:GetValue("F4C_RECBIK") , NIL },;
                      { "E2_FORCTA"   , oModelF4C:GetValue("F4C_RECACC") , NIL },;
                      { "E2_ALQIMP1"  , oModelVrt:GetValue("B_ALIMP1"  ) , NIL },;
                      { "E2_VALOR"    , oModelVrt:GetValue("B_VALPAY"  ) , NIL },;
                      { "E2_VALIMP1"  , oModelVrt:GetValue("B_VLIMP1"  ) , NIL },;
                      { "E2_BASIMP1"  , oModelVrt:GetValue("B_BSIMP1"  ) , NIL },;
                      { "AUTBANCO"    , oModelF4C:GetValue("F4C_BNKPAY") , NIL },;
                      { "AUTAGENCIA"  , oModelF4C:GetValue("F4C_PAYBIK") , NIL },;
                      { "AUTCONTA"    , oModelF4C:GetValue("F4C_PAYACC") , NIL },;
                      { "AUTCHEQUE"   , cCheq                            , NIL },;
                      { "E2_VLCRUZ"   , oModelVrt:GetValue("B_VLCRUZ"  ) , NIL },;
                      { "E2_CONUNI"   , oModelVrt:GetValue("B_CONUNI"  ) , NIL },;
                      { "E2_TXMOEDA"  , nExgRat                          , NIL },;
                      { "E2_ORIGEM"   , FunName()                        , NIL },;
                      { "E2_HIST"     , cHist                            , NIL },;
                      { "E2_CONTAD"   , oModelF4C:GetValue("F4C_CTPRE" ) , NIL },;
                      { "E2_CCUSTO"   , oModelF4C:GetValue("F4C_CCPRE" ) , NIL },;
                      { "E2_ITEMCTA"  , oModelF4C:GetValue("F4C_ITPRE" ) , NIL },;
                      { "E2_CLVL"     , oModelF4C:GetValue("F4C_CLPRE" ) , NIL },;
                      { "E2_F5QCODE"  , cF5QCod                          , NIL },;
                      { "E2_F5QUID"   , oModelF4C:GetValue("F4C_UIDF5Q") , NIL },;
                      { "FIXORDEM"    , "E2_ALQIMP1|E2_BASIMP1|E2_VALIMP1",NIL } }
        CTB105MVC(.T.)
        If oModelVrt:GetValue("B_CONUNI") == "1"
            nFK5VLM2TO += oModelVrt:GetValue("B_VALPAY")
        Else   
            nFK5VLM2TO += oModelVrt:GetValue("B_VLCRUZ")
        EndIf
        MsExecAuto({|t,w,x,y,z| FinA050(t,w,x,,,,y,,,,,,z)},; //z is 13th parameter
                     aRotAuto,;                        //t
                     Nil,;                             //w
                     3,;                               //x 3-Incl,4-Upd,5-Dl
                     .F.,;                             //y
                     oModelF4C:GetValue("F4C_CUUID"))  //z
        If lMsErroAuto
            If !IsBlind() .And. !RU06D07740_GetAutoBs()
                MostraErro()
            EndIf
            lRet := .F.
        EndIf
    EndIf
    RestArea(aArea)
    
Return (lRet) /*--------------------------------------------------RU06D0737_FI050IncludePA*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0739_GetNewF5MKey

Recieves parameters, according to them gets F5MKey for new prepayment line with tipo 
PA or RA

@param       Object      oModelF4C
             Character   cTipo    // character string for e1_tipo or e2_tipo field
@return      Character   cF5MKey "filial|prefixo|num|parcela|tipo|fornece(cliente)|loja"
@example     
@author      astepanov
@since       March/01/2019
@edit        March/16/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0739_GetNewF5MKey(oModelF4C, cTipo)

    Local   cF5MKey   As Character
    Local   cFlorig   As Character
    Local   cPrefixo  As Character
    Local   cNum      As Character
    Local   cTab      As Character
    Local   cFoClPm   As Character
    Local   cForCli   As Character
    Local   cLoja     As Character
    Local   aArea     As Array
    Default cTipo     := "PA"

    cF5MKey  :=  ""
    aArea    :=  GetArea()
    cPrefixo :=  GetMV("MV_BSTPRE")
    If     cTipo == "RA" // Inflow  BS
        cFlorig  :=  xFilial("SE1")
        cTab     := "E1_"
        cNum     :=  ProxTitulo("SE1",cPrefixo,/*cTipo*/)
        cFoClPm  := "CLIENTE"
        cForCli  := oModelF4C:GetValue("F4C_CUST")
        cLoja    := oModelF4C:GetValue("F4C_CUNI")
    ElseIf cTipo == "PA" // Outflow BS
        cFlorig  :=  xFilial("SE2")
        cTab     := "E2_"
        cNum     :=  ProxTitulo("SE2",cPrefixo,cTipo)
        cFoClPm  := "FORNECE"
        cForCli  := oModelF4C:GetValue("F4C_SUPP")
        cLoja    := oModelF4C:GetValue("F4C_UNIT")
    EndIf

    cF5MKey := PADR(cFlorig ,GetSX3Cache(cTab+"FILIAL" ,"X3_TAMANHO"), " ") + "|"
    cF5MKey += PADR(cPrefixo,GetSX3Cache(cTab+"PREFIXO","X3_TAMANHO"), " ") + "|"
    cF5MKey += PADR(cNum    ,GetSX3Cache(cTab+"NUM"    ,"X3_TAMANHO"), " ") + "|"
    cF5MKey += PADR(" "     ,GetSX3Cache(cTab+"PARCELA","X3_TAMANHO"), " ") + "|"
    cF5MKey += PADR(cTipo   ,GetSX3Cache(cTab+"TIPO"   ,"X3_TAMANHO"), " ") + "|"
    cF5MKey += PADR(cForCli ,GetSX3Cache(cTab+cFoClPm  ,"X3_TAMANHO"), " ") + "|"
    cF5MKey += PADR(cLoja   ,GetSX3Cache(cTab+"LOJA"   ,"X3_TAMANHO"), " ")

    RestArea(aArea)
    
Return (cF5MKey) /*-------------------------------------------------RU06D0739_GetNewF5MKey*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0740_ReverseFinancialPost

Function used for financial post reversing

@param       Object           oModelExt //passed model, it can be Nil
Private      Logical          lCmtRU6D7
Stattic      Logical          lUsaFlag
@return      Logical          lRet
@example     
@author      astepanov
@since       March/19/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0740_ReverseFinancialPost(oModelExt)

    Local lRet       As Logical
    Local lDeAct     As Logical
    Local oModel     As Object
    Local oModelF4C  As Object
    Local oModelF5M  As Object
    Local oModelVrt  As Object
    Local lPrc       As Logical
    Local lFirst     As Logical
    Local aArea      As Array
    Local aRevReslt  As Array
    Local aTmpArea   As Array
    Local aRecBx     As Array
    Local aLockedF5M As Array
    Local cHlpMsg    As Character
    Local cKey       As Character
    Local cINTNUM    As Character
    Local cStatus    As Character
    Local cPadraoH   As Character
    Local cPadraoL   As Character
    Local cArquivo   As Character
    Local cIDProc    As Character
    Local cArqBx     As Character
    Local cAdvance   As Character
    Local cWorkTab   As Character
    Local cTipoFld   As Character
    Local cAdvTipo   As Character
    Local cFKX       As Character
    Local nX         As Numeric
    Local nHndlF4C   As Numeric
    Local nHdlF5M    As Numeric
    Local nRecFKX    As Numeric
    Local dDTTRAN    As Date
    Local dDTREVE    As Date
    Local bFunRevAd  As Block

    cArquivo    := ""
    nHndlF4C    := 0
    nHdlF5M     := 0
    aRecBx      := {}
    cIDProc     := ""

    lRet  := .T.
    aArea := GetArea()
    If ValType(oModelExt) == "O" /*Model activation---------------------------------------*/
        If oModelExt:cID == "RU06D07"
            oModel := oModelExt
            lDeAct := .F.
        Else
            lRet   := .F.
        EndIf
    Else
        oModel := FWLoadModel("RU06D07")
        If ValType(oModel) == "O"
            oModel:SetOperation(4)
            lDeAct := .T.
            oModel:Activate() /*------------------------------------------Model activation*/
        Else
            lRet   := .F.
        EndIf
    EndIf
    If lRet
        oModelF4C := oModel:GetModel("RU06D07_MHEAD")
        oModelF5M := oModel:GetModel("RU06D07_MLNS" )
        oModelVrt := oModel:GetModel("RU06D07_MVIRT")
        cINTNUM   := oModelF4C:GetValue("F4C_INTNUM")
        dDTTRAN   := IIF(oModelF4C:GetValue("F4C_STATUS")==S_REPL_POST,oModelF4C:GetValue("F4C_DTREPL"),oModelF4C:GetValue("F4C_DTTRAN"))
        dDTREVE   := oModelF4C:GetValue("F4C_DTREVE")
    EndIf
    /*check document status---------------------------------------------------------------*/
    If lRet
        If oModelF4C:GetValue("F4C_STATUS") $ (S_FIN_POS + "|" + S_REPL_POST)
            lRet    := .T.
        Else
            lRet    := .F.
            cHlpMsg :=  STR0054 + STR0044 + STR0045 // Not posted in Financial
        EndIf
    EndIf
    /*---------------------------------------------------------------check document status*/
    Do Case
        Case lRet .AND. !IsBlind() .And. !RU06D07740_GetAutoBs()
            lRet := MsgYesNo( STR0089 + ; //do you confirm reversal of the document #: 
                              CHR(10)+Alltrim(cINTNUM)+' ?',;
                              STR0086 + STR0044 + STR0045)  // reverse financial post
    EndCase
    cAdvance  := oModelF4C:GetValue("F4C_ADVANC")
    If      oModelF4C:GetValue("F4C_OPER") == "1" //Inflow  BS
        cWorkTab  := "SE1"
        cTipoFld  := "SE1->E1_TIPO"
        cAdvTipo  := "RA"
        cPadraoH  := LP_576_INFCACCP
        cPadraoL  := LP_527_AR_CWRFF
        cFKX      := "FK1"
        bFunRevAd := {|x,y,z| RU06D07033_ReverseRecivableInAdvance(x,y,z)}
    ElseIf  oModelF4C:GetValue("F4C_OPER") == "2" //Outflow BS
        cWorkTab  := "SE2"
        cTipoFld  := "SE2->E2_TIPO"
        cAdvTipo  := "PA"
        cPadraoH  := LP_571_CNCLACPS
        cPadraoL  := LP_531_AP_CWRFF
        cFKX      := "FK2"
        bFunRevAd := {|x,y,z| RU06D0741_ReversePaymentInAdvance(x,y,z)}
    EndIf
    lPrc   := .T.
    BEGIN TRANSACTION /*Transaction-------------------------------------------------------*/
    lRet   := lRet .AND. LockSubmdF(oModelF5M,@aLockedF5M)
    Do Case
        Case lRet
            If     cAdvance == "2"
                DBSelectArea(cWorkTab)
                DBSetOrder(1)
                nX     := 1
                lFirst := .T.
                While lPrc .AND. nX <= oModelF5M:Length()
                    oModelF5M:GoLine(nX)
                    cKey :=  RU06D0749_GencF5MKey(oModelF5M:GetValue('F5M_KEY'), cWorkTab)
                    If DBSeek(cKey) .AND. RecLock(cWorkTab, .F.)/*Position to cWorkTab record---*/
                        If AllTrim(&(cTipoFld)) == cAdvTipo // reverse RA or PA in advance
                            aRevReslt := Eval(bFunRevAd,oModel,oModelF4C,oModelF5M)
                            lPrc      := aRevReslt[1]
                            cHlpMsg   := aRevReslt[2]
                        Else
                            aRevReslt := RU06D07029_FinUnPost(oModelF4C, oModelF5M,;
                                                              cWorkTab, lFirst, .T.)
                            lPrc      := aRevReslt[1]
                            cHlpMsg   := aRevReslt[2]
                            If lPrc .AND. lFirst 
                                aTmpArea := GetArea()
                                // Set E5_SITUACA to "C" for record with E5_TIPO == "VL",  
                                // E5_TIPODOC == "VL", E5_TABORI == "FK5", 
                                // E5_ORDREC == F4C_INTNUM, E5_DTDISPO == F4C_DTTRAN
                                SE5->(DbGoTo(RU06D0751_FinMovSE5(cINTNUM, dDTTRAN, cWorkTab)))
                                If SE5->(RecLock("SE5",.F.))
                                    SE5->E5_SITUACA := "C"
                                    SE5->E5_DTCANBX := dDTREVE
                                    SE5->(MsUnlock())
                                Else
                                    cHlpMsg := STR0198 //record lock error
                                    lPrc := .F.
                                EndIf
                                If lPrc
                                    // store cIdProc which will be used in accounting posting
                                    FKA->(DBSetOrder(3)) //FKA_FILIAL+FKA_TABORI+FKA_IDORIG
                                    FKA->(DBSeek(xFilial("FKA")+cFKX+&(cFKX+"->"+cFKX+"_ID"+cFKX)))
                                    cIDProc := FKA->FKA_IDPROC
                                EndIf
                                lFirst := .F.
                                RestArea(aTmpArea)
                            ElseIf lPrc .AND. !lFirst .AND. cWorkTab == "SE2"
                                // delete SE5 record. only for outflow BS
                                SE5->(DbGoTo(RU06D0752_FinTitSE5(cINTNUM, dDTTRAN,cWorkTab)))
                                If SE5->(RecLock("SE5",.F.))
                                    SE5->(dbDelete())
                                    SE5->(MsUnLock())
                                Else
                                    cHlpMsg := STR0198 //record lock error
                                    lPrc    := .F.
                                EndIf
                            EndIf
                            lPrc := lPrc .AND. oModelF5M:SetValue("F5M_CTRBAL", "2")
                            // Add element to aRecBx for posting in accounting
                            If lPrc .AND. !Empty(cIDProc) .AND.;
                                RU06D07940_RecFKX_LA(cIDProc,oModelF5M:GetValue('F5M_KEY'),cFKX)
                                nRecFKX := RU06D07950_RecCancFKX(cIDProc,oModelF5M:GetValue('F5M_KEY'),cFKX)
                                If nRecFKX > 0
                                    AADD(aRecBx,{nRecFKX,0,cKey,;
                                        PADR(xFilial("F5M"),;
                                            GetSX3Cache("F5M_FILIAL","X3_TAMANHO")," ")+;
                                        PADR(oModelF5M:GetValue("F5M_ALIAS"),;
                                            GetSX3Cache("F5M_ALIAS" ,"X3_TAMANHO")," ")+;
                                        PADR(oModelF5M:GetValue("F5M_IDDOC"),;
                                            GetSX3Cache("F5M_IDDOC" ,"X3_TAMANHO")," ")+;
                                        PADR(oModelF5M:GetValue("F5M_KEY")  ,;
                                            GetSX3Cache("F5M_KEY"   ,"X3_TAMANHO")," "),;
                                        "S"     }                                       )
                                EndIf
                            EndIf
                        EndIf
                        (cWorkTab)->(MSUnlock())
                    Else
                        lPrc    := .F.
                        cHlpMsg := STR0068 + cValToChar(nX) //error on line
                    EndIf
                    nX :=  nX + 1
                EndDo
                If lPrc
                    aRevReslt:= RU06D07034_GetCanceledSe5(FK5->FK5_IDMOV) 
                    lPrc      := aRevReslt[1]
                    cHlpMsg   := aRevReslt[2]
                EndIf
                //Post BS lines in accounting if we need it
                If lPrc .AND. !Empty(cPadraoL) .AND. VerPadrao(cPadraoL) .AND. !Empty(aRecBx)
                    cArqBx   := ""
                    nHdlF5M  := RU06D07017_RetNHndlBxPrv(@cArqBx)
                    If nHdlF5M <= 0
                        lPrc    := .F.
                        cHlpMsg := STR0162 //A100NOPROV
                    Else
                        aRevReslt := RU06D07018_A100Include(nHdlF5M, @cArqBx, cPadraoL,;
                                                            cFKX, aRecBx, {}, "", dDTREVE)
                        lPrc      := aRevReslt[1]
                        cHlpMsg   := aRevReslt[2]
                    EndIf
                EndIf
            ElseIf cAdvance == "1"
                aRevReslt := Eval(bFunRevAd,oModel,oModelF4C,oModelF5M)
                lPrc      := aRevReslt[1]
                cHlpMsg   := aRevReslt[2]
            EndIf
    EndCase
    lCmt := .F.
    Do Case
        Case lRet .AND. lPrc
            oModelF4C:GetStruct():SetProperty("F4C_STATUS", MODEL_FIELD_WHEN, {|| .T.})
            cStatus := oModelF4C:GetValue("F4C_STATUS")
            If     cStatus == S_FIN_POS   //2
                cStatus := S_REVERSED     //3
            ElseIf cStatus == S_REPL_POST //5
                cStatus := S_REPL_REV     //6
            EndIf 
            lCmt    := oModelF4C:SetValue("F4C_STATUS", cStatus)
            If lCmt
                lCmt := oModel:VldData()
            EndIf
            If lCmt
                lCmt := !FwInTTSBreak() .AND. oModel:CommitData()
            EndIf
            If !lCmt
                cHlpMsg := STR0070 //data saving error
            EndIf
    EndCase
    If lCmt .AND. !Empty(cPadraoH) .AND. VerPadrao(cPadraoH)
        nHndlF4C := RU06D07017_RetNHndlBxPrv(@cArquivo)
        If nHndlF4C <= 0
            lCmt    := .F.
            cHlpMsg := STR0162 //A100NOPROV
        EndIF
    EndIf
    If lCmt .AND. nHndlF4C > 0 .AND. F4C->F4C_LA == "S"
        lCmt := RU06D07930_A100Cncl(nHndlF4C  ,; //nHdlF4C
                                    Nil       ,; //cIdProcHea
                                    @cArquivo ,; //cArquivo
                                    cPadraoH  ,; //cPadrao
                                    .T.       ,; //lRev
                                    dDTREVE    ) //dDatAcc
    EndIf
    If lRet .AND. !lCmt
        DisarmTransaction()
    EndIf
    UlckSbmdFl(aLockedF5M)
    END TRANSACTION /*---------------------------------------------------------Transaction*/

    Do Case
        Case lRet .AND. lCmt
            oView                    := FWViewActive()
            If ! Empty(oView)
                oView:lModify        := .T.
                oView:oModel:lModify := .T.
                oView:ShowUpdateMsg(.T.)
                oView:SetUpdateMessage(STR0090 + STR0044 + STR0045,; //revers fin post
                                       STR0090 + STR0091 + STR0071) //success
            EndIf
        Case lRet .AND. !lCmt
            HELP("",1,STR0090 + STR0044 + STR0045,,; //revers fin post
                STR0077,1,0,,,,,,; //failed
                {cHlpMsg}) //error message
            lRet := .F.
    EndCase
    If lRet
        If lDeAct
            oModel:DeActivate()
        Else
            lCmtRU6D7 := .T. //no needs for second commit
        EndIf
    EndIf
    RestArea(aArea)
       
Return (lRet) /*--------------------------------------------RU06D0740_ReverseFinancialPost*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0741_ReversePaymentInAdvance

Static Function Used to Reverser Payment in advance that consist in to 
 1) delete check(SEF) - reverting the bank transaction
 2) writeoff the payment in advance generated

@param       Object           oModel
             Object           oModelF4C
             Object           oModelF5M
@return      Array            aRet aRet[1] == Logical   : .T.  - ok, payments reversed
                                   aRet[2] == Character : "" - if aRet[1] == .T.
                                                          "<ErrorMesg>" - aRet[1] == .F. 
@example     
@author      astepanov
@since       March/19/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0741_ReversePaymentInAdvance(oModel,oModelF4C,oModelF5M)

    Local lUpd       As Logical
    Local lSek       As Logical
    Local dPosDate   As Date
    Local dTmpDate   As Date
    Local cF4CKey    As Character
    Local cF5MKey    As Character
    Local cHistBaixa As Character
    Local cFilSEF    As Character
    Local cHlpMsg    As Character
    Local cArqBx     As Character 
    Local cPadrao530 As Character
    Local cChaveBusc As Character
    Local nX         As Numeric
    Local nHdlBxPrv  As Numeric
    Local nRecFK2    As Numeric
    Local nRecSE5    As Numeric
    Local aArea      As Array
    Local aRet       As Array
    Local aBaixa     As Array
    Local aUpdSEF    As Array
    Local aFlagBx    As Array
    Local aChkRes    As Array

    Private aTxMoedas   := {}
    
    dPosDate  := oModelF4C:GetValue("F4C_DTREVE")
    dTmpDate  := dDataBase
    dDataBase := dPosDate
    aArea     := GetArea()
    cHlpMsg   := ""
    lUpd      := .T.
    aRet      := {lUpd,cHlpMsg}
    nHdlBxPrv := 0
    cArqBx    := ""
    nRecFK2   := 0
    nRecSE5   := 0

    /*It is necessary first to cancel the check (SEF register) and rool back the bank 
    transaction before to write-off the bill ---------------------------------------------*/
    If lUpd
        cFilSEF := xFilial("SEF")
        cF4CKey := RU06D0761_GencF4CKey(oModelF4C,cFilSEF)
        SEF->(DBSetOrder(1)) //EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM
        aUpdSEF := RU06D0762_UpdateSEFTable(cF4CKey,cFilSEF,RU06D07032_DtFk5(oModelF4C:GetValue("F4C_CUUID")) )  // in next release change here the function RU06D07032_DtFk5 for the new field that will be created to store the date of replacment.
        //Update bank account balance - this happen inside the FINA190, we dont need that again here(account at F12 (on FINA050) should be On always - it make diference)
        /*AtuSalBco(oModelF4C:GetValue('F4C_BNKPAY')  ,;
                oModelF4C:GetValue('F4C_PAYBIK')    ,;
                oModelF4C:GetValue('F4C_PAYACC')    ,;
                dDataBase                           ,;
                oModelF5M:GetValue('F5M_VALPAY')    ,;
                "+"                               )*/
        lSek    := aUpdSEF[1]
        lUpd    := aUpdSEF[2]
        cHlpMsg := aUpdSEF[3]
    EndIf
    /*----------------------------------------------------------end work with SEF register*/
    Do Case
        Case lUpd
            aTxMoedas := RU06D0742_CurrenciesArray(oModelF4C:GetValue("F4C_DTTRAN"))
            DBSelectArea("SE2")  
            DBSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+
                          //+E2_TIPO+E2_FORNECE+E2_LOJA
            aBaixa     := {}
            cHistBaixa := RU06D07010_History(3,oModelF4C:GetValue("F4C_BNKORD"),;
                                             oModelF4C:GetValue("F4C_DTPAYM")   )
            cF5MKey := RU06D0749_GencF5MKey(oModelF5M:GetValue('F5M_KEY'))
            If DBSeek(cF5MKey) .AND. SE2->E2_SALDO > 0 // Position to SE2 record
                aBaixa := RU06D0760_GenArrayWithElementsForSE_Index()
                AADD(aBaixa, {"AUTMOTBX"    , "DAC"                            , Nil})
                AADD(aBaixa, {"AUTDTBAIXA"  , dPosDate                         , Nil}) 
                AADD(aBaixa, {"AUTDTCREDITO", dPosDate                         , Nil})
                AADD(aBaixa, {"AUTHIST"     , cHistBaixa                       , Nil})
                AADD(aBaixa, {"AUTPAYORD"   , oModelF4C:GetValue("F4C_INTNUM") , Nil})
                AADD(aBaixa, {"AUTVLRPG"    , oModelF5M:GetValue("F5M_VALPAY") , Nil})
                If !IsBlind() .And. !RU06D07740_GetAutoBs()
                        MsgRun(STR0066, STR0067,; //saving
                            {|| lUpd := RU06D0734_FI080Write(aBaixa, aTxMoedas)})
                Else
                                lUpd := RU06D0734_FI080Write(aBaixa, aTxMoedas)
                EndIf                                                    
                If !lUpd
                    cHlpMsg := STR0070 // error during data saving
                EndIf
                dDataBase := dTmpDate
                //Initialize Account Post file
                cPadrao530 := LP_530_AP_WROFF
                If lUpd .AND. VerPadrao(cPadrao530)
                    nHdlBxPrv := RU06D07017_RetNHndlBxPrv(@cArqBx)
                    If nHdlBxPrv <= 0
                        lUpd    := .F.
                        cHlpMsg := STR0162 //A100NOPROV
                    EndIf
                EndIf 
                If nHdlBxPrv > 0
                    cChaveBusc := ""
                    aFlagBx    := {}
                    nRecFK2 := RU06D07890_RecFKX(oModelF4C:GetValue("F4C_INTNUM"),;
                                                 oModelF5M:GetValue('F5M_KEY')   ,;
                                                 dPosDate                         )
                    If nRecFK2 > 0
                        FK2->(DBGoTo(nRecFK2))
                        AADD(aFlagBx,{ "FK2_LA", "S", "FK2", nRecFK2, 0, 0, 0})
                        SE5->(DBSetOrder(21))  //E5_FILIAL+E5_IDORIG+E5_TIPODOC
                        If SE5->(DBSeek(xFilial("SE5")+FK2->FK2_IDFK2+FK2->FK2_TPDOC))
                            nRecSE5 := SE5->(RecNo())
                            AADD(aFlagBx,{ "E5_LA" , "S", "SE5", nRecSE5, 0, 0, 0})
                        EndIf
                        cChaveBusc := FK2->FK2_FILIAL+FK2->FK2_IDFK2
                        aChkRes := RU06D07018_A100Include(nHdlBxPrv, @cArqBx, cPadrao530,;
                                                          "F4C", {}, aFlagBx, cChaveBusc, dPosDate)
                        lUpd    := aChkRes[1]
                        cHlpMsg := aChkRes[2]
                    Else
                        lUpd    := .F.
                    EndIf
                EndIf
            Else 
                lUpd    := .F. 
                cHlpMsg := STR0069 + cValToChar(nX) //no SE2 line
            EndIf 
    EndCase
    aRet[1] := lUpd
    aRet[2] := cHlpMsg
    dDataBase := dTmpDate
    RestArea(aArea)

Return (aRet) /*-----------------------------------------RU06D0741_ReversePaymentInAdvance*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0742_CurrenciesArray

Initialize Array with currency and currency names according to the SM2 file

@param       Date           dCurrDate // currency exhange rate date
@return      Array          aRet // array with currencies names, exrate and picture
                                 // aRet[n][1] == Curr name   <Character>: "US Dollar" or ""
                                 // aRet[n][2] == Curr exrate <Numeric>  : 62.4524 
                                 // aRet[n][3] == Picture     <Character>: "@E 99,999.9999"
                                 // n - number of currencies
@example     
@author      astepanov
@since       March/19/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0742_CurrenciesArray(dCurrDate)

    Local aRet       As Array
    Local nX         As Numeric
    Local nLen       As Numeric
    Local nQnt       As Numeric
    Local cMoedaTx   As Character
    Local aArea      As Array

    Default dCurrDate := dDataBase

    aArea := GetArea()
    aRet := {}
    If Empty(dCurrDate) .OR. ValType(dCurrDate) != "D"
        dCurrDate := dDataBase
    EndIf
    AADD(aRet,{"", 1, PesqPict("SM2","M2_MOEDA1")})
    If MoedFin() > 1 //MoedFin() gets available moedas quantity
        For nX := 2 To MoedFin()
            nLen := 1
            nQnt := nX
            While (Int(nQnt/10) != 0)
                nLen := nLen + 1
                nQnt := Int(nQnt/10)
            EndDo
            cMoedaTx := Str(nX, nLen)
            AADD(aRet, {GetMv("MV_MOEDA" + cMoedaTx),RecMoeda(dCurrDate,nX),PesqPict("SM2","M2_MOEDA" + cMoedaTx)})
        Next nX
    EndIf
    RestArea(aArea)
    
Return (aRet) /*-------------------------------------------------RU06D0742_CurrenciesArray*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0743_FI050DELPA

Used to delete check(SEF) and account payable(SE2) of a prepayment
bank statement line which will already perform the necessary bank transactions storno

@param       Object           oModel    //cID == "RU06D07"
             Object           oModelF4C //cID == "RU06D07_MHEAD"
             Object           oModelF5M //cID == "RU06D07_MLNS"
                                cWorkTab
                Boolean         lUpdBank    = update bank bank balance                  
@return      Array            aRet aRet[1] == Logical   : .T.  - ok, payments reversed
                                   aRet[2] == Character : "" - if aRet[1] == .T.
                                                          "<ErrorMesg>" - aRet[1] == .F.
@private     lDigita
@static      lUsaFlag
@example     
@author      astepanov
@since       March/20/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D0743_FI050DELPA(oModel, oModelF4C, oModelF5M, cWorkTab, lUpdBank,dDTTRAN)

    Local lSek          As Logical
    Local lUpd          As Logical
    Local lPadrao5BI    As Logical
    Local cFilSEF       As Character
    Local cF4CKey       As Character
    Local cF5MKey       As Character  
    Local cHlpMsg       As Character
    Local cPadrao5BI    As Character
    Local cArquivo      As Character
    Local cChaveBusc    As Character
    Local aArea         As Array
    Local aTmpArea      As Array
    Local aRet          As Array
    Local aBaixa        As Array
    Local aUpdSEF       As Array
    Local aChkRes       As Array
    Local nHdlPrv       As Numeric
    Local dActDt        As DATE
    Local aAreaFK5      as Array

    Private lMSErroAuto := .F.
    Default cWorkTab    := "SE2"
    Default lUpdBank    := .F.
    DEFAULT dDTTRAN     :=dDatabase

    dActDt          := dDataBase    //Save actual system date to restore after delete PA - PA shoul be deleted at same date at transaction date 
    dDataBase       := dDtTran
    cHlpMsg         := ""
    lUpd            := .T.
    aRet            := {.T., cHlpMsg}
    cPadrao5BI      := LP_5BI_AP_PRPCN
    lPadrao5BI      := VerPadrao(cPadrao5BI)	  
    nHdlPrv         := 0
    cArquivo        := ""
    aAreaFK5 := FK5->(GetArea())

    aArea   := GetArea()
    /*Working with SEF register-----------------------------------------------------------*/
    cFilSEF := xFilial("SEF")
    cF4CKey := RU06D0761_GencF4CKey(oModelF4C,cFilSEF)
    SEF->(DBSetOrder(1)) //EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM
    aUpdSEF := RU06D0762_UpdateSEFTable(cF4CKey,cFilSEF,dDtTran)
    /*          WE NEED ADJUST BANK BALANCE            
        For suport BS, the cheque routine FINA190 was change, as standard when we cancel one cheque the delete SE5 Line
        we change that approach and create a new SE5 tipe ES(this happen because the accouting is online), 
        so when delete PA document at FINA050 they change again the Bank balance, 
        to solve that was decided add here the bank adjust, than when FINA050 reduce again they will still corrected
    */
    If !lUpdBank //For mixed we dont need that, they are fixed because we add manual at SE5
        AtuSalBco(oModelF4C:GetValue('F4C_BNKPAY'),;
                    oModelF4C:GetValue('F4C_PAYBIK'),;
                    oModelF4C:GetValue('F4C_PAYACC'),;
                    dDtTran,;
                    oModelF5M:GetValue('F5M_VALPAY'),;
                    "-"                               ) 
    Endif

    lSek    := aUpdSEF[1]
    lUpd    := aUpdSEF[2]
    cHlpMsg := aUpdSEF[3]
    /*-----------------------------------------------------------Working with SEF register*/

    Do Case
        Case lUpd
            DBSelectArea(cWorkTab)  
            DBSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+
                          //+E2_TIPO+E2_FORNECE+E2_LOJA
            aBaixa     := {}
            cF5MKey := RU06D0749_GencF5MKey(oModelF5M:GetValue('F5M_KEY'))
            If DBSeek(cF5MKey) // position to SE2 record before deletion
                aTmpArea := GetArea()
                //Unpost in accounting if we need it
                If (cWorkTab)->E2_LA == "S" .AND. lPadrao5BI
                    nHdlPrv := RU06D07017_RetNHndlBxPrv(@cArquivo) 
                    If nHdlPrv > 0
                        cChaveBusc := F4C->F4C_FILIAL+F4C->F4C_CUUID
                        aChkRes := RU06D07018_A100Include(nHdlPrv, @cArquivo, cPadrao5BI,;
                                                          "F4C", {}, {}, cChaveBusc      )
                        lUpd    := aChkRes[1]
                        cHlpMsg := aChkRes[2]
                    Else //nHdlPrv <= 0
                        lUpd    := .F.
                        cHlpMsg := STR0162 //A100NOPROV
                    EndIf
                EndIf        
                RestArea(aTmpArea)
                If lUpd
                    aBaixa   := RU06D0760_GenArrayWithElementsForSE_Index()
                    cHistory := RU06D07010_History(7,oModelF4C:GetValue("F4C_BNKORD"),oModelF4C:GetValue("F4C_DTPAYM"))
                    AADD(aBaixa, {"AUTHIST", cHistory, Nil})
                    // 3Incl,4-Upd,5-Del
                    MsExecAuto({ |t,w,x,y| FINA050(t,w,x,,,,y)}, aBaixa,, 5,.F.) 
                EndIf
                If lMSErroAuto
                    If !IsBlind() .And. !RU06D07740_GetAutoBs()
                        MostraErro()
                    EndIf
                    lUpd    := .F.
                    cHlpMsg := STR0070 //error during data saving
                EndIf
            EndIf
    EndCase
    If lUpd .AND. lUpdBank
        //Update bank account balance for outflow
        /*we need this point because at mix BS post we add manually a line 
          with total moviment (Write-off + Advance Payment), but at cancel 
          we dont have the Advance moviment to restore balance at SE8 
          on SEL table (with field SEL_NUM empty)                       */
        AtuSalBco(oModelF4C:GetValue('F4C_BNKPAY'),;
                  oModelF4C:GetValue('F4C_PAYBIK'),;
                  oModelF4C:GetValue('F4C_PAYACC'),;
                  dDtTran,;
                  oModelF5M:GetValue('F5M_VALPAY'),;
                  "+"                               )  
    EndIf   
    dDataBase := dActDt 
    aRet[1] := lUpd
    aRet[2] := cHlpMsg
    FK5->(RestArea(aAreaFK5))

    RestArea(aArea)   
Return (aRet) /*------------------------------------------------------RU06D0743_FI050DELPA*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0747_CommitModel

Function calls when model commit starts
Private      Logical          lCmtRU6D7 // equals .T. - situation when model was commited
@param       Object           oModel
@return      Logical          lRet
@example     
@author      astepanov
@since       March/14/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D0747_CommitModel(oModel)

    Local lRet       As Logical
    Local oModelF4C  As Object

    lRet      := .T.
    oModelF4C := oModel:GetModel("RU06D07_MHEAD")

    If Type("lCmtRU6D7") == "L" .AND. lCmtRU6D7 == .T. //oModel already commited
        lRet := .T.
    Else
        lRet := IIf(Empty(oModelF4C:GetValue("F4C_PAYORD")), .T.,;
                    RU06D0714_Commit_RU06D05_MF49(oModel)        )
        lRet := IIf(lRet, FwFormCommit(oModel), .F.)
    EndIf
    
Return (lRet) /*-----------------------------------------------------RU06D0747_CommitModel*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0714_Commit_RU06D05_MF49

This function commits RU06D05_MF49 model (Payment order)

@param       Object           oModel // RU06D07
@return      Logical          lRet   //.T. - commited ok, .F. - there is an error in commit
@example     
@author      astepanov
@since       June/18/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0714_Commit_RU06D05_MF49(oModel)

    Local lRet       As Logical
    Local oModelF4C  As Object
    Local oModelPO   As Object
    Local aAreaF49   As Array
    Local aArea      As Array 
    Local cStatus    As Character
    Local nOper      As Numeric

    lRet := .T.

    nOper     := oModel:GetOperation()
    oModelF4C := oModel:GetModel("RU06D07_MHEAD")
    // we change PO status if we have attached PO and 
    // F4C_STATUS not equal S_REVERSED.
    // for statuses: S_REPLACEMENT, S_REPL_POST, S_REPL_REV
    // payment order always will be empty according to spec.
    If !Empty(oModelF4C:GetValue("F4C_PAYORD"))    .AND.;
        !(oModelF4C:GetValue("F4C_STATUS") == S_REVERSED)
        lRet     := .F.
        aArea    := GetArea()
        aAreaF49 := F49->(GetArea())
        cStatus  := "1"
        If nOper == 3 /*insert*/ .OR.;
           nOper == 4 /*update*/ .OR.;
           nOper == 9 /*only update*/
            cStatus := "2"            //sent to bank
            If oModelF4C:GetValue("F4C_STATUS") == S_FIN_POS //posted in finance
                cStatus := "4"        //paid
            EndIf
        ElseIf nOper == 5 /*delete*/
            cStatus := "1"            //created
        EndIf
        dbSelectArea("F49")
        F49->(DbSetOrder(2)) //F49_FILIAL+F49_IDF49
        If F49->(DbSeek(xFilial("F49") + oModelF4C:GetValue("F4C_IDF49")))
            oModelPO := FwLoadModel(IIF(F49->F49_REQUES == "1","RU06D05","RU06D06"))
            oModelPO:SetOperation(4)
            oModelPO:Activate()
            oModelPO:GetModel("RU06D05_MF49"):SetValue("F49_STATUS", cStatus)
            If     cStatus == "4" //BS is posted in finance
                oModelPO:GetModel("RU06D05_MF49"):SetValue("F49_DTACTP",;
                                  oModelF4C:GetValue("F4C_DTTRAN")       )
            ElseIf cStatus == "2" .OR. cStatus == "1" //BS is unposted in finance
                oModelPO:GetModel("RU06D05_MF49"):SetValue("F49_DTACTP",STOD(".."))
            EndIf
            lRet := oModelPO:VldData() .AND. oModelPO:CommitData()
            If !lRet
                HELP("",1,  STR0017 + STR0052,,;      //BS - information
                      oModelPO:GetErrorMessage()[5],; //Error message info
                      1,0,,,,,,;
                     {oModelPO:GetErrorMessage()[7]}) //Solution
            EndIf
            oModelPO:DeActivate()
        EndIf
        F49->(RestArea(aAreaF49))
        RestArea(aArea)
    EndIf
    
Return (lRet) /*---------------------------------------------RU06D0714_Commit_RU06D05_MF49*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0748_ViewConfig

Function used for view configuration

@param       Object           oView
@return      Logical          .T.
@example     
@author      astepanov
@since       March/15/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0748_ViewConfig(oView)

    Local lRet       As Logical
    Local oModel     As Object
    Local nOper      As Numeric
    lRet := .T.

    If !Empty(oView) .AND. ValType(oView) == "O" .AND. oView:oModel:cID == "RU06D07"
        oModel := oView:GetModel()
        nOper  := oModel:GetOperation()
        oView:SetDescription(RU06D0766_ConstructTitle(nOper))
        If nOper != 1 .AND. nOper != 5
            oModel:GetModel("RU06D07_MHEAD"):LoadValue("F4C_FILIAL",xFilial("F4C"))
        EndIf
        // load default bank account for selected currency. See:
        // https://jiraproducao.totvs.com.br/browse/RULOC-825
        If oModel:GetOperation() == MODEL_OPERATION_INSERT
            If FwFldGet("F4C_OPER") == "2"
                FwFldPut("F4C_BNKPAY",RU06D05493_GatBankPay("F4C_BNKPAY",__cMdlHdr),,,,.F.)
            ElseIf FwFldGet("F4C_OPER") == "1"
                FwFldPut("F4C_BNKREC",RU06D05493_GatBankPay("F4C_BNKREC",__cMdlHdr),,,,.F.)
            EndIf
        EndIf
        If !Empty(oModel:GetModel("RU06D07_MHEAD"):GetValue("F4C_PAYORD"))
            oModel:GetModel("RU06D07_MVIRT"):SetOnlyView()
        EndIf
        If ! FwIsInCallStack("RU06D0731_ViewFPost") .AND. nOper != 1 .AND. nOper != 5
            If Val(FWFldGet("F4C_OPER")) == 2 //outflow BS
                oView:AddUserButton(STR0021, "", {|| Empty(FWFldGet("F4C_PAYORD"))  .AND.;
                                                     RU06XFUN10_PickUpAPs("F4C")})
            ElseIf Val(FWFldGet("F4C_OPER")) == 1 //inflow BS
                oView:AddUserButton(STR0188, "", {|| RU06XFUN10_PickUpAPs("F4C",.T.)})
            EndIf                                    
            oView:AddUserButton(STR0037, "", {|| RU06D0730_RecalcCurrency(.T.)}) //Cur reclc
        EndIf
        oView:AddUserButton(STR0147, "", {|| RU06D0710_Act(7)}) //Track repld BS
        oView:AddUserButton(STR0148, "", {|| RU06D0710_Act(8)}) //Track replt BS
    EndIf
    
Return (lRet) /*------------------------------------------------------RU06D0748_ViewConfig*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0749_GencF5MKey

Recives string from F5M_KEY and returns formatted string, which will be used as a key for
search in SE2 or in SE1 register
filial+prefixo+num+percela+tipo+fornece(cliente)+loja : IndexOrder == 1
If cKey is Empty it will return cF5MKey string with several spaces: "                  "
The length of cF5MKey equals the order length: e2_filial+e2_prefixo+e2_num+e2_parcela+
                                               e2_tipo+e2_fornece+e2_loja
                                               or 
                                               e1_filial+e1_prefixo+e1_num+e1_parcela+
                                               e1_tipo+e1_cliente+e2_loja
@param       Character        cKey //Value from F5M_Key field
             Character        cWorkTab // tab for which we create search key SE2 or SE1
@return      Character        cF5MKey
@example     
@author      astepanov
@since       March/22/2019
@edit        March/17/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0749_GencF5MKey(cKey, cWorkTab)

    Local cF5MKey      As Character
    Local cSepar       As Character
    Local cTbPr        As Character
    Local aF5MKey      As Array

    Default cKey       :=  " "
    Default cWorkTab   := "SE2"

    cF5MKey := " "
    cSepar  := "|"

    If     cWorkTab == "SE2"
        cTbPr := "E2_"
        cFoCl := "FORNECE"
    ElseIf cWorkTab == "SE1"
        cTbPr := "E1_"
        cFoCl := "CLIENTE"
    EndIf

    aF5MKey := StrTokArr(cKey, cSepar)

    If Len(aF5MKey) > 6
        cF5MKey := PADR(aF5MKey[1],TamSX3(cTbPr+"FILIAL" )[1])
        cF5MKey += PADR(aF5MKey[2],TamSX3(cTbPr+"PREFIXO")[1])
        cF5MKey += PADR(aF5MKey[3],TamSX3(cTbPr+"NUM"    )[1])
        cF5MKey += PADR(aF5MKey[4],TamSX3(cTbPr+"PARCELA")[1])
        cF5MKey += PADR(aF5MKey[5],TamSX3(cTbPr+"TIPO"   )[1])
        cF5MKey += PADR(aF5MKey[6],TamSX3(cTbPr+cFoCl    )[1])
        cF5MKey += PADR(aF5MKey[7],TamSX3(cTbPr+"LOJA"   )[1])
    Else
        cF5MKey := PADR(" "       ,TamSX3(cTbPr+"FILIAL" )[1])
        cF5MKey += PADR(" "       ,TamSX3(cTbPr+"PREFIXO")[1])
        cF5MKey += PADR(" "       ,TamSX3(cTbPr+"NUM"    )[1])
        cF5MKey += PADR(" "       ,TamSX3(cTbPr+"PARCELA")[1])
        cF5MKey += PADR(" "       ,TamSX3(cTbPr+"TIPO"   )[1])
        cF5MKey += PADR(" "       ,TamSX3(cTbPr+cFoCl    )[1])
        cF5MKey += PADR(" "       ,TamSX3(cTbPr+"LOJA"   )[1])
    EndIf
    
Return (cF5MKey) /*---------------------------------------------------RU06D0749_GencF5MKey*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0760_GenArrayWithElementsForSE_Index
Requerement for correct work: Cursor should be postioned on record in SE2 register or
in SE1 register, according to passed parameter
Function returns array with elements from SE2 fields: filial + prefixo + num + parcela +
                                                      tipo   + fornece + loja
                                                      Index # 1  for SE2 register
@param       Character      cTab     // "SE2"(Default) or "SE1" ...
@return      Array          aRet [7]
@example     
@author      astepanov
@since       March/22/2019
@edit        March/12/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0760_GenArrayWithElementsForSE_Index(cTab)

    Local aRet       As Array
    Default cTab     := "SE2"
    aRet := {}
    If     cTab == "SE2"
        AADD(aRet, {"E2_FILIAL"   , SE2->E2_FILIAL   , Nil})
        AADD(aRet, {"E2_PREFIXO"  , SE2->E2_PREFIXO  , Nil})
        AADD(aRet, {"E2_NUM"      , SE2->E2_NUM      , Nil})
        AADD(aRet, {"E2_PARCELA"  , SE2->E2_PARCELA  , Nil})
        AADD(aRet, {"E2_TIPO"     , SE2->E2_TIPO     , Nil})
        AADD(aRet, {"E2_FORNECE"  , SE2->E2_FORNECE  , Nil})
        AADD(aRet, {"E2_LOJA"     , SE2->E2_LOJA     , Nil})
    ElseIf cTab == "SE1"
        AADD(aRet, {"E1_FILIAL"   , SE1->E1_FILIAL   , Nil})
        AADD(aRet, {"E1_PREFIXO"  , SE1->E1_PREFIXO  , Nil})
        AADD(aRet, {"E1_NUM"      , SE1->E1_NUM      , Nil})
        AADD(aRet, {"E1_PARCELA"  , SE1->E1_PARCELA  , Nil})
        AADD(aRet, {"E1_TIPO"     , SE1->E1_TIPO     , Nil})
        AADD(aRet, {"E1_CLIENTE"  , SE1->E1_CLIENTE  , Nil})
        AADD(aRet, {"E1_LOJA"     , SE1->E1_LOJA     , Nil})
    EndIf
     
Return (aRet) /*--------------------------------RU06D0760_GenArrayWithElementsForSE_Index*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0761_GencF4CKey

Function forms cF4CKey for searching records in SEF register
If there is problems with input model it returns an empty string

@param       Object           oModelF4C
             Character        cFilSEF // xFilial("SEF")
@return      Character        cF4CKey
@example     
@author      astepanov
@since       March/22/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0761_GencF4CKey(oModelF4C,cFilSEF)

    Local cF4CKey    As Character
    Local aFields    As Array
    Local aF4CFld    As Array
    Local nX         As Numeric
    Local nY         As Numeric
    Local nCnt       As Numeric
    Local lChk       As Logical

    Default cFilSEF := xFilial("SEF")
    aF4CFld := {"F4C_BNKPAY","F4C_PAYBIK","F4C_PAYACC","F4C_INTNUM"}
    cF4CKey := ""

    If ValType(oModelF4C) == "O"
        /*Fields checking-----------------------------------------------------------------*/
        aFields := ACLONE(oModelF4C:GetStruct():aFields)
        nCnt    := 0
        lChk    := .F.
        For nX := 1 To Len(aFields)
            If Empty(aFields[nX][3]) .OR. ValType(aFields[nX][3]) != "C"
                Exit
            EndIf
            For nY := 1 To Len(aF4CFld)
                If aF4CFld[nY] == aFields[nX][3] //field name
                    nCnt := nCnt + 1
                EndIf
            Next nY
            If nCnt == Len(aF4CFld)
                lChk := .T.
                Exit
            EndIf
        Next nX
        /*-----------------------------------------------------------------Fields checking*/
        If lChk
            cF4CKey := cFilSEF
            cF4CKey += PADR(oModelF4C:GetValue(aF4CFld[1]),TamSX3("EF_BANCO"  )[1]) //BNKPAY
            cF4CKey += PADR(oModelF4C:GetValue(aF4CFld[2]),TamSX3("EF_AGENCIA")[1]) //PAYBIK
            cF4CKey += PADR(oModelF4C:GetValue(aF4CFld[3]),TamSX3("EF_CONTA"  )[1]) //PAYACC
            cF4CKey += PADR(oModelF4C:GetValue(aF4CFld[4]),TamSX3("EF_NUM"    )[1]) //INTNUM
        EndIf
    EndIf
    
Return (cF4CKey) /*---------------------------------------------------RU06D0761_GencF4CKey*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0762_UpdateSEFTable

Updates SEF table

@param       Character cF4CKey
             Character cFilSEF xFilial("SEF")
             Date      dDTTRAN  F4C->DTTRAN
@return      Array     aRet : [1] == LSek, [2] == lUpd, [3] == cHlpMsg as error message
                       lUpd == .T. => cHlpMsg == ""
                       lUpd == .F. => cHlpMsg == "<error message>"
                       lSek == .T. => there were founded line in SEF register
@example     
@author      astepanov
@since       March/22/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0762_UpdateSEFTable(cF4CKey,cFilSEF,dDTTRAN)

    Local aRet       As Array
    Local lUpd       As Logical
    Local lSek       As Logical
    Local cHlpMsg    As Character

    Private lMSErroAuto := .F.
    Default cFilSEF     := xFilial("SEF")

    lSek := .F.
    lUpd := .T.
    cHlpMsg := ""
    aRet := {lSek,lUpd,cHlpMsg}

    If Empty(cF4CKey)
        lUpd := .F.
        cHlpMsg := STR0094 //Empty search key
        aRet[1] := lSek
        aRet[2] := lUpd
        aRet[3] := cHlpMsg
        Return (aRet)
    EndIf

    If SEF->(DBSeek(cF4CKey))
        lSek := .T.
        While cF4CKey == (cFilSEF + SEF->EF_BANCO + SEF->EF_AGENCIA +;
                          SEF->EF_CONTA + SEF->EF_NUM )
            If Empty(SEF->EF_IMPRESS) .AND. SEF->EF_DATA == dDTTRAN
                MsExecAuto( { |y,z| FinA190(y,z)},4,.T.)  // 3  Incl, 4 - Upd, 5 - Delete
                If lMsErroAuto
                    If !IsBlind() .And. !RU06D07740_GetAutoBs()
                        MostraErro()
                    EndIf
                    lUpd := .F.
                    cHlpMsg := STR0070 //error during data saving
                EndIf
                Exit  // ------------.
            EndIf                  //.
            SEF->(DBSkip())        //.
        EndDo                      //. 
    EndIf //<------------------------.

    aRet[1] := lSek
    aRet[2] := lUpd
    aRet[3] := cHlpMsg
    
Return (aRet) /*--------------------------------------------------RU06D0762_UpdateSEFTable*/

/*/
{Protheus.doc} RU06D0763_ShwRec

Function used to show data related to the receivables entities
Finction called from X3_RELACAO of F4C_ACRNAM virtual field.
It returns reciever's account name
Also virtual fields F4C_TYPCC, F4C_BKRNAM will be filled too. 
In case of INCLUI real field F4C_RECNAM will be filled too.

nNum 1 = F4C_TYPCC ,;
     2 = F4C_BKRNAM,;
     3 = F4C_ACRNAM,;
     4 = F4C_RECNAM }

@type function
@author dtereshenko
@since 2019/04/05
@version P12.1.25
@project MA3 - Russia
@return   cRet,    Char,       Value for F4C_ACRNAM
/*/
Function RU06D0763_ShwRec(nNum)

    Local cRet As Character
    Local cBnk As Character
    Local cBIK As Character
    Local cAcc As Character
    Local cCliSup As Character
    Local cUnt As Character
    Local cOpr As Character
    Local aInp As Array
    Local aFld As Array
    Local oMdl As Object

    cRet := ""
    aFld := {"F4C_TYPCC","F4C_BKRNAM","F4C_ACRNAM","F4C_RECNAM"}
    oMdl := FWModelActive()
    If ValType(oMdl) == "O" .AND. oMdl:GetId() == "RU06D07" .AND.;
       oMdl:IsActive()
        cOpr := FwFldGet("F4C_OPER")
        cBnk := FwFldGet("F4C_BNKREC")
        cBIK := FwFldGet("F4C_RECBIK")
        cAcc := FwFldGet("F4C_RECACC")
        cCliSup := Iif(cOpr == "1",FwFldGet("F4C_CUST"  ),FwFldGet("F4C_SUPP"  ))
        cUnt    := Iif(cOpr == "1",FwFldGet("F4C_CUNI"  ),FwFldGet("F4C_UNIT"  ))
        
    Else
        cOpr := F4C->F4C_OPER
        cBnk := F4C->F4C_BNKREC
        cBIK := F4C->F4C_RECBIK
        cAcc := F4C->F4C_RECACC
        cCliSup := Iif(cOpr == "1",F4C->F4C_CUST,F4C->F4C_SUPP)
        cUnt    := Iif(cOpr == "1",F4C->F4C_CUNI,F4C->F4C_UNIT)
    EndIf
    //aInp {"reciever's account type", "reciever's bank name",
    //      "reciever's account name", "reciever's name"     }
    aInp := IIf(cOpr == "1",;
                RU06XFUN03_ShwSA6(0,cBnk,cBIK,cAcc),;          //Inflow 
                RU06XFUN02_ShwFIL(0,cCliSup,cUnt,cBnk,cBIK,cAcc)) //Otflow
    If !Empty(aInp)
        cRet := aInp[nNum]             
    EndIf
    If !Empty(cRet)
        cRet := PADR(cRet, GetSX3Cache(aFld[nNum],"X3_TAMANHO"), " ")
    EndIf

Return (cRet)

/*/
{Protheus.doc} RU06D0764_ShwPay

Function used to show data related to the payables entities
Finction called from X3_RELACAO of F4C_ACPNAM virtual field.
It returns payer's account name
Also virtual fields F4C_TYPCP, F4C_BKPNAM will be filled too. 
In case of INCLUI real field F4C_PAYNAM will be filled too.

@type function
@author dtereshenko
@since 2019/04/05
@version P12.1.25
@project MA3 - Russia

nNum 1 = F4C_TYPCP ,;
     2 = F4C_BKPNAM,;
     3 = F4C_ACPNAM,;
     4 = F4C_PAYNAM

@return   cRet,    Char,       Value for F4C_ACPNAM
/*/
Function RU06D0764_ShwPay(nNum)

    Local cRet As Character
    Local cBnk As Character
    Local cBIK As Character
    Local cAcc As Character
    Local cCliSup As Character
    Local cCun As Character
    Local cOpr As Character
    Local aInp As Array
    Local aFld As Array
    Local oMdl As Object

    cRet := ""
    aFld := {"F4C_TYPCP", "F4C_BKPNAM", "F4C_ACPNAM", "F4C_PAYNAM"}
    oMdl := FWModelActive()
    If ValType(oMdl) == "O" .AND. oMdl:GetId() == "RU06D07" .AND.;
       oMdl:IsActive()
        cBnk := FwFldGet("F4C_BNKPAY")
        cBIK := FwFldGet("F4C_PAYBIK")
        cAcc := FwFldGet("F4C_PAYACC")
        cOpr := FwFldGet("F4C_OPER"  )
        cCliSup  := Iif(cOpr == "1",FwFldGet("F4C_CUST"  ),FwFldGet("F4C_SUPP"  ))
        cCun     := Iif(cOpr == "1",FwFldGet("F4C_CUNI"  ),FwFldGet("F4C_UNIT"  ))
    Else
        cOpr := F4C->F4C_OPER
        cBnk := F4C->F4C_BNKPAY
        cBIK := F4C->F4C_PAYBIK
        cAcc := F4C->F4C_PAYACC
        cCliSup := Iif(cOpr == "1",F4C->F4C_CUST,F4C->F4C_SUPP)
        cCun    := Iif(cOpr == "1",F4C->F4C_CUNI,F4C->F4C_UNIT)
    EndIf
    //aInp structure {"payer's account type","payer's bank name",
    //                "payer's account name","payer's name     "}
    aInp := IIf(cOpr == "1",;
                RU06XFUN29_ShwF4N(0,cCliSup,cCun,cBnk,cBIK,cAcc),; //Inflow
                RU06XFUN03_ShwSA6(0,cBnk,cBIK,cAcc)           ) //Otflow                     
    If !Empty(aInp)
        cRet := aInp[nNum]
    EndIf
    If !Empty(cRet)
        cRet := PADR(cRet, GetSX3Cache(aFld[nNum],"X3_TAMANHO"), " ")
    EndIf

Return (cRet)

/*/{Protheus.doc} RU06D0766_ConstructTitle
Function to get title label depending on direction of BS and type of model operation
@type function
@author dtereshenko
@since 2019/03/13
@version P12.1.25
@project MA3 - Russia
@param     nOperation,    Numeric,    Type of model operation
@return    cTitle,        Char,       Main window title
/*/
Function RU06D0766_ConstructTitle(nOperation As Numeric)
    Local   cTitle          As Character
    Local   aOperDirections As Array
    Local   aModOperTypes   As Array
    Default nOperation      := 1 

    cTitle := ""
    aOperDirections := { STR0095,; // Inflow
                         STR0096 } // Outflow

    aModOperTypes := { STR0007,;   // 1- View
                       "",     ;   // 2-
                       STR0008,;   // 3- Add
                       STR0009,;   // 4- Update
                       STR0010,;   // 5- Delete
                       "","","",;
                       STR0012 }   // 9- Copy 

    If !Empty(FwFldGet("F4C_OPER"))
        cTitle := aOperDirections[Val(FwFldGet("F4C_OPER"))]
        cTitle += IIf(nOperation < 10,;
                      " - " + aModOperTypes[nOperation],;
                      "")
    EndIf

Return (cTitle)

/*/{Protheus.doc} RU06D0769_IniKpp
Function Used to initialize the fields related to KPP
according to the operation

@type function
@author Eduardo.FLima
@since 22/02/2019
@version 1.0
@project MA3 - Russia

@param    nField,   Numeric,   Informs which field triggered the validation
                                  1: Receivers KPP   (F4C_KPPREC)
                                  2: Payers KPP      (F4C_KPPPAY)
@return   lRet,     Char,      The correct kpp for field initialization
/*/
Function RU06D0769_IniKpp(nField)
    Local cKpp As Char
    Local oOper As Object

    oOper := RU06D07041()
    cKpp := ""
    If ValType(nField) != "N"
        Return (cKpp)
    EndIf
    If     FwFldGet("F4C_OPER") == "1"
        cKpp := Iif(nField==1, Iif(oOper:get('INCLUI'), GETCOBRRUS()[2][5][2], ""),"")
    ElseIf FwFldGet("F4C_OPER") == "2"
        cKpp := Iif(nField==2, Iif(oOper:get('INCLUI'), GETCOBRRUS()[2][5][2], ""),"")
    EndIf

Return cKpp


/*/{Protheus.doc} RU06D0770_VldRec
Function used to switch between the validations possible in the reciavable entity:
    Inflow: SA6
    Outflow: FIL

@type function
@param  Character    cParam   //If Nil - we validate F4C_BNKREC
                              //If "ACC" - we validate F4C_RECACC
@author dtereshenko
@since 2019/04/08
@version P12.1.25
@project MA3 - Russia

@return    lRet,    Logical,    Returns if the content in the Receivable entity
                                 is valid according to the operation used in the model
/*/
Function RU06D0770_VldRec(cParam As Character)
    Local lRet As Logical
    lRet := .F.
    Default cParam := ""

    If FwFldGet("F4C_OPER") == "1"     // Inflow
        lRet := RU06D0704_VldSA6(cParam, 1)
    ElseIf FwFldGet("F4C_OPER") == "2" // Outflow
        lRet := RU06D0707_VldFIL(cParam)
    Else // None
        Help("", 1, "RU06D07_ROpErr",, STR0107, 1, 0) // Need to set an operation
    EndIf

Return lRet


/*/{Protheus.doc} RU06D0771_VldPay
Function used to switch between the validations possible in the Payable entity:
    Inflow: F4N
    Outflow: SA6
@param  Character    cParam   //If Nil - we validate F4C_BNKPAY
                              //If "ACC" - we validate F4C_PAYACC
@type function
@author dtereshenko
@since 2019/04/08
@version P12.1.25
@project MA3 - Russia

@return    lRet,    Logical,    Returns if the content in the Payable entity
                                 is valid according to the operation used in the model
/*/
Function RU06D0771_VldPay(cParam As Character)

    Local lRet    As Logical
    lRet   := .F.

    If     FwFldGet("F4C_OPER") == "1" // Inflow
        lRet := RU06D0774_VldF4N(cParam)
    ElseIf FwFldGet("F4C_OPER") == "2" // Outflow
        lRet := RU06D0704_VldSA6(cParam, 2)
    Else // None
        Help("", 1, "RU06D07_POpErr",, STR0105, 1, 0) // Need to set an operation
    EndIf

Return lRet

/*/{Protheus.doc} RU06D07041_GetOper
Function used to define operation (INCLUI/ALTERA)

@param  oModelAct, object with model
@type function
@author Dmitry Borisov
@since 02.04.2024
@version 12.1.2310
@project MA3 - Russia
@return   oOper
/*/
Function RU06D07041_GetOper(oModelAct)
    Local oOper := FwHashMap():New()

    If Type('INCLUI') == "L"
        oOper:put('INCLUI', INCLUI)
    Elseif oModelAct != Nil
        oOper:put('INCLUI', oModelAct:GetOperation() == MODEL_OPERATION_INSERT)
    Else
        oOper:put('INCLUI', .F.)
    EndIf

    If Type('ALTERA') == "L"
        oOper:put('ALTERA', ALTERA)
    Elseif oModelAct != Nil
        oOper:put('INCLUI', oModelAct:GetOperation() == MODEL_OPERATION_UPDATE)
    Else
        oOper:put('ALTERA', .F.)
    EndIf

Return (oOper)



















/*/{Protheus.doc} RU06D0775_RemoveStructFields
Function to remove transfered list of fields from transfered form data model instance

@type function
@author dtereshenko
@since 2019/03/13
@version P12.1.25
@project MA3 - Russia

@param     oFormStruct    Object    FWFormModelStruct instance
@param     aFields        Array     List of fields to remove from form structure
/*/ 
Function RU06D0775_RemoveStructFields(oFormStruct As Object, aFields As Array)
    Local nCnt As Numeric

    If !Empty(aFields)
        For nCnt := 1 to Len(aFields)
            oFormStruct:RemoveField(aFields[nCnt])
        Next nCnt
    EndIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0715_TaxAgVAT

This function used for processing Tax agent VAT invoices in RU06D07 model
for correct work cursor should be positioned on correct line in F4C table

@param       Numeric          nOper // 1 - Add tax agent VAT invoice
                                    // 2  - View tax agent VAT invoices
@return      Logical          lRet  // .T. - ok, .F. - error case
@example     
@author      astepanov
@since       June/18/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0715_TaxAgVAT(nOper As Numeric)

    Local   lRet       As Logical
    Local   cHlpMsg    As Character
    Local   aArea      As Array
    Local   aInp       As Array
    Local   oTmpTab1   As Object
    Local   oTmpTab2   As Object
    
    Default nOper      := 1 //Add

    lRet    := .T.
    cHlpMsg := ""

    Do Case /* Initial validation --------------------------------------------------------*/
        Case lRet .AND. nOper == 1
            If !(Val(F4C->F4C_OPER) == 2  .AND. Val(F4C->F4C_PAYTYP) == 1)
                lRet    := .F.
                cHlpMsg += STR0116 + CHR(13) //only for payments to Supplier
            EndIf
            If !(Val(F4C->F4C_STATUS) == 2 .OR. Val(F4C->F4C_STATUS) == 3)
                // 2 - posted in financial, 3 - posted in accounting
                // case when BS is not posted
                lRet    := .F.
                cHlpMsg += STR0117 + CHR(13) //only for bank statement having status 'Posted'
            EndIf
            If lRet // check for tax agent contracts
                //aInp == {oTmpTab, cHlpMsg}
                aInp :=  RU06XFUN35_RetTempTablWTaxAgentsContracts(F4C->F4C_CUUID)
                If aInp[1] == Nil
                    cHlpMsg += aInp[2] + CHR(13)
                    lRet    := .F.
                Else
                    aArea    := GetArea()
                    oTmpTab1 := aInp[1]
                    DBSelectArea(oTmpTab1:GetAlias())
                    DBSetOrder(1)
                    DBGoTop()
                    If Eof()
                        cHlpMsg += STR0118 + CHR(13) //no company payments as a TA
                        oTmpTab1:Delete()
                        lRet    := .F.
                    EndIf
                    RestArea(aArea)
                EndIf
            EndIf
            If lRet // check for created tax agent invoices
                //aInp == {oRetTab, cHlpMsg}
                aInp := RU06XFUN36_RetTaxAgentInvoicesForBS(,oTmpTab1)
                If aInp[1] == Nil
                    cHlpMsg += aInp[2] + CHR(13)
                    lRet    := .F.
                Else
                    aArea    := GetArea()
                    oTmpTab2 := aInp[1]
                    DBSelectArea(oTmpTab2:GetAlias())
                    DBSetOrder(1)
                    DBGoTop()
                    If !Eof()
                        RestArea(aArea)
                        cHlpMsg  += STR0119 +;         // Payments from bank statement #
                                    F4C->F4C_INTNUM +;
                                    STR0120 + CHR(13)  // already have VAT invoices
                        lRet     := .F.
                    EndIf
                    oTmpTab1:Delete()
                    oTmpTab2:Delete()
                    RestArea(aArea)
                EndIf
            EndIf
            /*/If lRet
	            RU09T02Mn2() // Function not found in repository
            EndIf/*/
        Case lRet .AND. nOper == 2
            cHlpMsg += RU06D0725_ViewTaxAgentVATInvoicesForBS(F4C->F4C_CUUID)
            If !Empty(cHlpMsg)
                lRet := .F.
            EndIf
    
    EndCase /* -------------------------------------------------------- Initial validation*/

    /*Out Error messages -----------------------------------------------------------------*/
    If !lRet .AND. !Empty(cHlpMsg)
        HELP("", 1, STR0017 + STR0052, ,;   // BS Information
             cHlpMsg,;
             1,0,,,,,,;
             /*{"solution"}*/)
    EndIf
    /*----------------------------------------------------------------- Out Error messages*/
 
Return(lRet) /*--------------------------------------------------------RU06D0715_TaxAgVAT*/


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0725_ViewTaxAgentVATInvoicesForBS

For viewing tax agent VAT invoices which were generated for bank statement

@param       Character        cF4C_CUUID // F4C->FC_CUUID
             Logical          lPackage // .T. - indicates that we must process 2 or more
                                       //       bank statements, so cF4C_CUUID should be
                                       //       a complex string with delimiters
                                       // .F. - show tax agent VAT invoices only for 1
                                       //       bank statement (Default)
                                       // it is not used yet but it will be used in case
                                       // of list of BS. So, need implementation.       
@return      Character        cHlpMsg  // If cHlpMsg == "" - all ok,
                                       // If cHlpMsg is not emty, so we can show err msg
@example     
@author      astepanov
@since       June/21/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0725_ViewTaxAgentVATInvoicesForBS(cF4C_CUUID, lPackage)

    Local   cHlpMsg    As Character
    Local   aArea      As Array
    Local   aInp       As Array
    Local   aSize      As Array
    Local   oTabF35Inv As Object
    Local   lRet       As Logical
    Private oInvDlg    As Object
    Private oBrowseInv As Object
    Default lPackage   := .F.

    lRet     := .T.
    cHlpMsg  := ""
    aInp       := RU06XFUN36_RetTaxAgentInvoicesForBS(cF4C_CUUID, lPackage)
    oTabF35Inv := aInp[1]
    If oTabF35Inv != Nil
        aArea := GetArea()
        DBSelectArea(oTabF35Inv:GetAlias())
        DBGoTop()
        If EoF()
            lRet    := .F. // no TAX agent VAT invoices
            cHlpMsg += STR0114 + STR0121
            oTabF35Inv:Delete()
        EndIf
        RestArea(aArea)
    Else
        lRet    := .F. // error during SQL query
        cHlpMsg += aInp[2]
    EndIf
    If lRet
        aSize      := MsAdvSize()
        oInvDlg    := MsDialog():New(aSize[7] , aSize[2], aSize[6], aSize[5],;
                                     STR0122,; //List of the tax agent VAT invoices
                                     , , , ,;
                                     CLR_BLACK , CLR_WHITE,;
                                     , , .T., , , , .T.)
        oBrowseInv:=FWMBrowse():New()
        oBrowseInv:SetOwner(oInvDlg)
        oBrowseInv:SetAlias("F35")
        oBrowseInv:SetFilterDefault("@ F35_KEY IN (SELECT F35_KEY FROM "+;
                                     oTabF35Inv:GetRealName()+")")
        aRotina := RU06D0726_MenuForViewTaxAgentVATInvoicesFromBS() //Reset
        oBrowseInv:Activate(oInvDlg)
        oInvDlg:Activate(,,,.T.,,,)
        oTabF35Inv:Delete()
        aRotina := MenuDef() // Return aRotina
    EndIf
Return (cHlpMsg) /*---------------------------------RU06D0725_ViewTaxAgentVATInvoicesForBS*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0726_MenuForViewTaxAgentVATInvoicesFromBS

Menu for oBrowseInv

@param       
@return      Array         aRet
@example     
@author      astepanov
@since       June/24/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0726_MenuForViewTaxAgentVATInvoicesFromBS()

    Local aRet       As Array
    aRet := {{STR0007  , "RU06D0727_OpenTaxAgentVATInvoiceForView",;
                                         0, 1, 0, Nil},;
             {STR0056  , "oInvDlg:End()",0, 1, 0, Nil}             }   
Return (aRet) /*----------------------------RU06D0726_MenuForViewTaxAgentVATInvoicesFromBS*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D0727_OpenTaxAgentVATInvoiceForView

Function runs RU09T02 View from oBrowseInv 

@param       
Private      Object           oBrowseInv
@return      Logical          lRet
@example     
@author      astepanov
@since       June/24/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D0727_OpenTaxAgentVATInvoiceForView()

    Local lRet       As Logical
    Local cAlias     As Character
    Local aArea      As Array
    Local aAreaTMP   As Array
    Local aAreaF35   As Array
    lRet     := .T.
    If Type("oBrowseInv") == "O"
        cAlias   := oBrowseInv:GetAlias()
        aArea    := GetArea()
        aAreaTMP := (cAlias)->(GetArea())
        aAreaF35 := F35->(GetArea())
        DBSelectArea("F35")
        DBSetOrder(3) //f35_filial + f35_key
        If MSSeek((cAlias)->F35_FILIAL + (cAlias)->F35_KEY)
            FWExecView("","RU09T02",1,,{|| .T.})
        EndIf
        F35->(RestArea(aAreaF35))
        (cAlias)->(RestArea(aAreaTMP))
        RestArea(aArea)
    EndIf
Return (lRet) /*-----------------------------------RU06D0727_OpenTaxAgentVATInvoiceForView*/

/*/{Protheus.doc} RU06D0750_BankTransaction
Commit of bank transaction header

@type function
@author Alexandra.Velmozhnya
@since 15/05/2019
@version 1.0
@project MA3 - Russia

@param    oModbkstm,    Object,     Main model
@param    cExProc,      Character,  Name of Process
@param    aTxMoedas     Array,      array with currencies and exchange rates
@public   cUsuario, cFilAnt
@return   lRet,     Logical,    Returns if the model is Valid to be Committed
/*/
Function RU06D0750_BankTransaction(oModbkstm,cExProc,aTxMoedas,lReplace,nFK5VLM2TO)

    Local oModMovBco as object
    Local oFKAMovBco as object
    Local oFK5MovBco as object
    Local oModelF4C	 as Object
    Local oModelF5M	 as Object
    Local cIDProc    as Character
    Local cCposSE5   as Character
    Local cHistTrans as Character
    Local cErrMsg    as Character
    Local cSltMsg    as Character 
    Local cFK5FilOri as Character
    Local cE5Numliq  as Character
    Local cSinal     as Character
    Local lRet       as Logical
    Local nMoeda     as Numeric
    Local nRnd       as Numeric
    Local aArea      as Array
    Local dDtTran    As Date

    DEFAULT lReplace :=.F.

    aArea       := GetArea()
    oModMovBco  := FWLoadModel("FINM030")
    oFKAMovBco  := oModMovBco:GetModel("FKADETAIL")
    oFK5MovBco  := oModMovBco:GetModel("FK5DETAIL")
    oModelF4C	:= oModbkstm:GetModel('RU06D07_MHEAD')
    oModelF5M	:= oModbkstm:GetModel('RU06D07_MLNS')
    cIDProc     :=IIF(cExProc == Nil,FINFKSID("FKA","FKA_IDPROC"),cExProc)
    lRet       := .T.
    cErrMsg    := ""
    cSltMsg    := ""
    nMoeda     := Val(oModelF4C:GetValue("F4C_CURREN"))
    cHistTrans := RU06D07010_History(4,oModelF4C:GetValue("F4C_BNKORD"),;
                                       oModelF4C:GetValue("F4C_DTPAYM") )
    oModMovBco:SetOperation(MODEL_OPERATION_INSERT)
    oModMovBco:Activate()
    oModMovBco:SetValue("MASTER","E5_GRV",.T.    )
    oModMovBco:SetValue("MASTER","IDPROC",cIDProc)
    If lReplace
        dDtTran := oModelF4C:GetValue("F4C_DTREPL")
    Else
        dDtTran := oModelF4C:GetValue("F4C_DTTRAN")
    EndIf

    If !oFKAMovBco:IsEmpty()
        oFKAMovBco:AddLine()  
    EndIf
    oFKAMovBco:SetValue("FKA_IDORIG",FWUUIDV4())
    oFKAMovBco:SetValue("FKA_TABORI","FK5"     )
    //FK5_VLOMOE2 for Inflow can be same like for Outflow BS == nFK5VLM2TO
    nRnd       := TamSX3("FK5_VLMOE2")[2]
    cFK5FilOri := SubString(cFilAnt,1,Len(FK5->FK5_FILIAL))
    cE5Numliq  := Soma1(GetMV("MV_NUMLIQ"),TamSX3("E5_NUMLIQ")[1])
    If     oModelF4C:GetValue("F4C_OPER") == "2" // Outflow bank statement
        cCposSE5 := "{"
        cCposSE5 += "{'E5_DTDIGIT','"+dtos(dDtTran)+"'      },"
        cCposSE5 += "{'E5_VENCTO' ,'"+dtos(dDtTran)+"'      },"
        cCposSE5 += "{'E5_TIPO'   ,'VL'                                        },"
        cCposSE5 += "{'E5_NUMLIQ' ,'" + cE5Numliq                        + "'  },"
        cCposSE5 += "{'E5_PREFIXO',''                                          },"
        cCposSE5 += "{'E5_NUMERO' ,'" + oModelF4C:GetValue("F4C_INTNUM") + "'  },"
        cCposSE5 += "{'E5_PARCELA',''                                          },"
        cCposSE5 += "{'E5_CLIFOR' ,'" + oModelF4C:GetValue("F4C_SUPP")   + "'  },"
        cCposSE5 += "{'E5_LOJA'   ,'" + oModelF4C:GetValue("F4C_UNIT")   + "'  },"
        cCposSE5 += "{'E5_BENEF'  ,'" + oModelF4C:GetValue("F4C_RECNAM") + "'  },"
        cCposSE5 += "{'E5_MOTBX'  ,'NOR'                                       }"
        cCposSE5 += "}"
        oModMovBco:SetValue("MASTER"    , "E5_CAMPOS",cCposSE5            )
        oFK5MovBco:SetValue("FK5_VALOR" , oModelF4C:GetValue("F4C_VALUE") )
        oFK5MovBco:SetValue("FK5_RECPAG", "P"                             )
        oFK5MovBco:SetValue("FK5_HISTOR", cHistTrans                      )	
        oFK5MovBco:SetValue("FK5_DATA"  , dDtTran)
        oFK5MovBco:SetValue("FK5_NATURE", oModelF4C:GetValue("F4C_CLASS") )
        oFK5MovBco:SetValue("FK5_TPDOC" , "VL"                            )
        oFK5MovBco:SetValue("FK5_VLMOE2", nFK5VLM2TO                      )
        oFK5MovBco:SetValue("FK5_ORDREC", oModelF4C:GetValue("F4C_INTNUM"))
        oFK5MovBco:SetValue("FK5_BANCO" , oModelF4C:GetValue("F4C_BNKPAY"))
        oFK5MovBco:SetValue("FK5_AGENCI", oModelF4C:GetValue("F4C_PAYBIK"))
        oFK5MovBco:SetValue("FK5_CONTA" , oModelF4C:GetValue("F4C_PAYACC"))
        oFK5MovBco:SetValue("FK5_NUMCH" , oModelF4C:GetValue("F4C_INTNUM"))
        oFK5MovBco:SetValue("FK5_MOEDA" , oModelF4C:GetValue("F4C_CURREN"))
        oFK5MovBco:SetValue("FK5_DTDISP", dDtTran)
        oFK5MovBco:SetValue("FK5_LA"    , ""                              )
        oFK5MovBco:SetValue("FK5_FILORI", cFK5FilOri                      )
        oFK5MovBco:SetValue("FK5_ORIGEM", FunName()                       )
        oFK5MovBco:SetValue("FK5_TXMOED", aTxMoedas[nMoeda][2]            )
        oFK5MovBco:SetValue("FK5_IDBS"  , oModelF4C:GetValue("F4C_CUUID") )
        cSinal := "-"
    ElseIf oModelF4C:GetValue("F4C_OPER") == "1" // Inflow  bank statement
        oModMovBco:SetValue("MASTER","NOVOPROC",.F.)
        SA6->(DBsetOrder(1))
        SA6->(DBSeek(xFilial("SA6")+oModelF4C:GetValue("F4C_BNKREC")+;
                                    oModelF4C:GetValue("F4C_RECBIK")+;
                                    oModelF4C:GetValue("F4C_RECACC")))
        cCposSE5 := "{"
        cCposSE5 += "{'E5_FILIAL' , '"+ xFilial("SE5")                   + "'},"
        cCposSE5 += "{'E5_PREFIXO', '"+ "BL"                             + "'},"
        cCposSE5 += "{'E5_NUMERO' , '"+ oModelF4C:GetValue("F4C_INTNUM") + "'},"
        cCposSE5 += "{'E5_PARCELA', '"+ ""                               + "'},"
        cCposSE5 += "{'E5_CLIFOR' , '"+ oModelF4C:GetValue("F4C_CUST")   + "'},"
        cCposSE5 += "{'E5_CLIENTE', '"+ oModelF4C:GetValue("F4C_CUST")   + "'},"
        cCposSE5 += "{'E5_LOJA'   , '"+ oModelF4C:GetValue("F4C_CUNI")   + "'},"
        cCposSE5 += "{'E5_NUMLIQ' ,'" + cE5Numliq                        + "'},"
        cCposSE5 += "{'E5_BENEF'  , '"+ oModelF4C:GetValue("F4C_RECNAM") + "'},"
        cCposSE5 += "{'E5_DTDIGIT',  dDataBase                               },"
        cCposSE5 += "{'E5_VENCTO' ,  dDataBase                               },"
        cCposSE5 += "{'E5_SERREC' , '"+ ""                               + "'},"
        cCposSE5 += "{'E5_ORDREC' , '"+ oModelF4C:GetValue("F4C_INTNUM") + "'},"
        cCposSE5 += "{'E5_HISTOR' , '"+ cHistTrans                       + "'},"
        cCposSE5 += "{'E5_MOTBX'  , '"+ "NOR"                            + "'},"
        cCposSE5 += "{'E5_RATEIO' , '"+ ""                               + "'},"
        cCposSE5 += "{'E5_BANCO'  , '"+ oModelF4C:GetValue("F4C_BNKREC") + "'},"
        cCposSE5 += "{'E5_AGENCIA', '"+ oModelF4C:GetValue("F4C_RECBIK") + "'},"
        cCposSE5 += "{'E5_CONTA'  , '"+ oModelF4C:GetValue("F4C_RECACC") + "'},"
        cCposSE5 += "{'E5_TIPO'   , '"+ "VL"                             + "'} "
        cCposSE5 += "}"
        oModMovBco:SetValue( "MASTER"    ,"E5_CAMPOS",cCposSE5              )
        oFK5MovBco:SetValue( "FK5_RECPAG", "R"                              )
        oFK5MovBco:SetValue( "FK5_HISTOR", cHistTrans                       )
        oFK5MovBco:SetValue( "FK5_DATA"  , dDtTran                          )
        oFK5MovBco:SetValue( "FK5_DTDISP", dDtTran                          )
        oFK5MovBco:SetValue( "FK5_TPDOC" , "VL"                             )
        oFK5MovBco:SetValue( "FK5_ORDREC", oModelF4C:GetValue("F4C_INTNUM") )
        oFK5MovBco:SetValue( "FK5_MOEDA" , oModelF4C:GetValue("F4C_CURREN") )
        oFK5MovBco:SetValue( "FK5_VALOR" , oModelF4C:GetValue("F4C_VALUE")  )
        oFK5MovBco:SetValue( "FK5_VLMOE2", nFK5VLM2TO                       )
        oFK5MovBco:SetValue( "FK5_TXMOED", aTxMoedas[nMoeda][2]             )
        oFK5MovBco:SetValue( "FK5_BANCO" , oModelF4C:GetValue("F4C_BNKREC") )
        oFK5MovBco:SetValue( "FK5_AGENCI", oModelF4C:GetValue("F4C_RECBIK") )
        oFK5MovBco:SetValue( "FK5_CONTA" , oModelF4C:GetValue("F4C_RECACC") )
        oFK5MovBco:SetValue( "FK5_NUMCH" , oModelF4C:GetValue("F4C_INTNUM") )
        oFK5MovBco:SetValue( "FK5_SEQ"   , PadL("1",TamSX3("E5_SEQ")[1],"0"))
        oFK5MovBco:SetValue( "FK5_LA"    , ""                               )
        oFK5MovBco:SetValue( "FK5_NATURE", oModelF4C:GetValue("F4C_CLASS")  )
        oFK5MovBco:SetValue( "FK5_ORIGEM", FunName()                        )
        oFK5MovBco:SetValue( "FK5_FILORI", cFK5FilOri                       )
        oFK5MovBco:SetValue( "FK5_IDBS"  , oModelF4C:GetValue("F4C_CUUID")  )
        cSinal := "+"
    EndIf
    If oModMovBco:VldData() .AND. oModMovBco:CommitData()
        AtuSalBco(SE5->E5_BANCO  ,;
                  SE5->E5_AGENCIA,;
                  SE5->E5_CONTA  ,;
                  SE5->E5_DATA   ,;
                  SE5->E5_VALOR  ,;
                  cSinal          )
    Else
        cErrMsg := cValToChar(oModMovBco:GetErrorMessage()[4]) + ' - '
        cErrMsg += cValToChar(oModMovBco:GetErrorMessage()[5]) + ' - '
        cErrMsg += cValToChar(oModMovBco:GetErrorMessage()[6])
        lRet := .F.
    EndIf
    oModMovBco:DeActivate()
    If !Empty(cErrMsg)
         Help("",1,STR0163,,;    //Bank transaction
             cErrMsg,;
             1,0,,,,,,{cSltMsg})
    EndIf
    RestArea(aArea)

Return lRet

/*/{Protheus.doc} RU06D0751_FinMovSe5
Commit of bank transaction header

@type function
@author Alexandra.Velmozhnya
@since 30/05/2019
@version 1.0
@project MA3 - Russia

@param    cINTNUM   Character       Bank Statement Number
          dDTTRAN   Date            F4C_DTTRAN  
          Character cWorkTab        "SE2" or "SE1"
@return   nRet      Numeric         Returns Recno of Bank Transaction
/*/
Static Function RU06D0751_FinMovSe5(cINTNUM, dDTTRAN, cWorkTab)
	Local aArea   as Array
	Local nRec    as Numeric	
	Local cQuery  as Character
    Local cStatus as Character
    Local cAlias  as Character
    Local cDTTRAN as Character
	
	Default cINTNUM := ""
    Default dDTTRAN := dDataBase
    Default cWorkTab := "SE2"
   
	nRec    := 0
    cStatus := "C"
	cINTNUM := PADR(cINTNUM, GetSX3Cache("E5_ORDREC", "X3_TAMANHO"), " ")
    cDTTRAN := DTOS(dDTTRAN)
	cQuery := " SELECT SE5.R_E_C_N_O_  R_E_C_N_O_                    "
    cQuery += " FROM " + RetSQlName("SE5") + " SE5                   "
	cQuery += " WHERE SE5.E5_FILORIG = '" + XFILIAL(cWorkTab) + "'   "
    cQuery += " AND   SE5.E5_TIPO    = 'VL'                          "
    cQuery += " AND   SE5.E5_TIPODOC = 'VL'                          "
    cQuery += " AND   SE5.E5_TABORI  = 'FK5'                         "
    cQuery += " AND   SE5.E5_SITUACA <> '" + cStatus + "'            "
    cQuery += " AND   SE5.E5_ORDREC  =  '" + cINTNUM + "'            "
    cQuery += " AND   SE5.E5_DTDISPO =  '" + cDTTRAN + "'            "
    cQuery += " AND   SE5.D_E_L_E_T_ = ' '                           "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    aArea  := GetArea()
    DbSelectArea(cAlias)
    DBGoTop()
    If !EoF()
        nRec := (cAlias)->R_E_C_N_O_
    EndIf
    (cAlias)->(DBCloseArea())
	RestArea(aArea)	

Return nRec

Static Function  RU06D0752_FinTitSE5(cINTNUM, dDTTRAN, cWorkTab)

    Local   aArea     As Array
    Local   nRec      As Numeric	
    Local   cQuery    As Character
    Local   cAlias    As Character
    Local   cDTTRAN   As Character
    Local   cPrf      As Character
    Local   cNum      As Character
    Local   cPar      As Character
    Local   cC_F      As Character
    Local   cLoj      As Character
    Default cINTNUM   := ""
    Default dDTTRAN   := dDataBase
    Default cWorkTab  := "SE2"

    nRec    := 0
    cINTNUM := PADR(cINTNUM, GetSX3Cache("E5_ORDREC", "X3_TAMANHO"), " ")
    cDTTRAN := DTOS(dDTTRAN)
    If      cWorkTab == "SE2"
        cPrf := "E2_PREFIXO"
        cNum := "E2_NUM"
        cPar := "E2_PARCELA"
        cC_F := "E2_FORNECE"
        cLoj := "E2_LOJA"
    ElseIf  cWorkTab == "SE1"
        cPrf := "E1_PREFIXO"
        cNum := "E1_NUM"
        cPar := "E1_PARCELA"
        cC_F := "E1_CLIENTE"
        cLoj := "E1_LOJA"
    EndIf
    cQuery := " SELECT                                                     "
    cQuery += "       R_E_C_N_O_                                           "
    cQuery += " FROM " + RetSQlName("SE5") + " SE5                         "
    cQuery += " WHERE E5_FILORIG = '" + xFilial(cWorkTab)     + "'         "
    cQuery += "   AND E5_PREFIXO = '" + &(cWorkTab+"->"+cPrf) + "'         "
    cQuery += "   AND E5_NUMERO  = '" + &(cWorkTab+"->"+cNum) + "'         "
    cQuery += "   AND E5_PARCELA = '" + &(cWorkTab+"->"+cPar) + "'         "
    cQuery += "   AND E5_CLIFOR  = '" + &(cWorkTab+"->"+cC_F) + "'         "
    cQuery += "   AND E5_LOJA    = '" + &(cWorkTab+"->"+cLoj) + "'         "
    cQuery += "   AND E5_ORDREC  = '" + cINTNUM         + "'               "
    cQuery += "   AND E5_DATA    = '" + cDTTRAN         + "'               "
    cQuery += "   AND D_E_L_E_T_ = ' '                                     "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    aArea  := GetArea()
    DbSelectArea(cAlias)
    DBGoTop()
    If !EoF()
        nRec := (cAlias)->R_E_C_N_O_
        (cAlias)->(DBCloseArea())
    EndIf
    RestArea(aArea)

Return nRec

//------------------------------------------------------------------------------------------





	







	







	
	














	



	







	







	






	








	


/*/{Protheus.doc} RU06D07E6_UpdateVlsForPA
Function used for updating values in virual grid  for AP with type "PA"
It is used by RU06D0759_RecalcValue

@@param      Character        cID            // field name
             Variant          xNVal          // field new value
             Variant          nCurVLVATC     // new B_VLVATC value
             Object           oModelVrt      // Virtual grid model
             Object           oMdlHdr        // oModelF4C
@return      Logical          lRet
@example     
@author      astepanov
@since       July/30/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07E6_UpdateVlsForPA(cID, xNVal, nCurVLVATC, oModelVrt, oMdlHdr)

	Local lRet       As Logical
	Local nExRat     As Numeric
    Local nRnd       As Numeric
    Local nVATAMT    As Numeric
	
	lRet             := .T.
	
	If      cID == "B_VALCNV"
        //B_VALPAY
        lRet := oModelVrt:LoadValue("B_VALPAY",Round(xNVal/oModelVrt:GetValue("B_EXGRAT"),GetSX3Cache("F5M_VALPAY","X3_DECIMAL")))
        nExRat := xMoeda(1, oModelVrt:GetValue("B_CURREN"), 1, oMdlHdr:GetValue("F4C_DTTRAN"), GetSX3Cache("F5M_EXGRAT","X3_DECIMAL"))
        //B_VLCRUZ
        If Val(oMdlHdr:GetValue("F4C_CURREN")) != oModelVrt:GetValue("B_CURREN")
            lRet := lRet .AND. oModelVrt:LoadValue("B_VLCRUZ",xNVal)
        Else
            nExRat := IIF(nExRat == 0, 1, nExRat)
            nRnd := GetSX3Cache(Iif(lInflow,"E1_VLCRUZ","E2_VLCRUZ"), "X3_DECIMAL")
            lRet := lRet .AND. oModelVrt:LoadValue("B_VLCRUZ",Round(oModelVrt:GetValue("B_VALPAY")*nExRat,2))
        EndIf
		//B_VLIMP1
        nVATAMT := Round(nCurVLVATC/oModelVrt:GetValue("B_EXGRAT"),GetSX3Cache("E2_VALIMP1","X3_DECIMAL"))
		lRet := lRet .AND. oModelVrt:LoadValue("B_VLIMP1",nVATAMT)
		//B_BSIMP1
		lRet := lRet .AND. oModelVrt:LoadValue("B_BSIMP1",oModelVrt:GetValue("B_VALPAY") - oModelVrt:GetValue("B_VLIMP1"))
		//B_OPBAL
		lRet := lRet .AND. oModelVrt:LoadValue("B_OPBAL",oModelVrt:GetValue("B_VALPAY"))
        //B_VALUE
        lRet := lRet .AND. oModelVrt:LoadValue("B_VALUE",oModelVrt:GetValue("B_VALPAY"))
        lRet := lRet .AND. RU06D07E9_UpdateF5MLine(oModelVrt, oMdlHdr, "UPDATE")
	EndIf

	
Return (lRet) /*--------------------------------------------------RU06D07E6_UpdateVlsForPA*/


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07E7_RetTotalsForHeader
This function goes through lines in grid and returns totals
of B_VALCNV(F5M_VALCNV) and B_VLAVATC(F5M_VLVATC). This amounts can be used for
updating F4C_VALUE and F4C_VATAMT (F49_VALUE and F49_VATAMT) or not. 
Other case of using this function it is
when we should make decision about adding new AP line with type "PA"
It is used by RU06D0722_WriteFromMBr: when we add new AP, we recalculate F4C_VALUE and
F4C_VATAMT
It cam be used by RU06D06001_AddBills: when we add new AP, we recalculate F49_VALUE and
F49_VATAMT
It is used by RU06D0759_RecalcValue: when we validate F4C_VALUE

@param       Object           oGridMdl // for example oModelF5M or oModelVrt
             Character        cID      // "VRT" or "F5M"
@edit       avelmozhnya(03/02/2020):
            Logical           lInflow  //  Bank Statment Direction
@return      Array            aRet     {Value for F4C_VALUE, Value for F4C_VATAMT}
@example     
@author      astepanov
@since       August/01/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07E7_RetTotalsForHeader(oGridMdl, cID, lInflow)
	Local aRet       As Array
	Local nX         As Numeric
	Local nValue     As Numeric
	Local nVATAMT    As Numeric
    Local nVATCon    As Numeric
    Local nCurrPs    As Numeric
    Local nLen       As Numeric

    Default lInflow := .T.

    If lInflow
        aRet := {0,0,0} //{F4C_ITTOTA, F4C_ITVATF ,F4C_ITVATO}
        nVATCon := 0
    Else
        aRet := {0,0} //{"F4C_VALUE", "F4C_VATAMT"} or {"F49_VALUE", "F49_VATAMT"}
    EndIf
	nValue  := 0
	nVATAMT := 0
    nCurrPs := oGridMdl:GetLine()
    nLen    := oGridMdl:Length()
	If     cID == "VRT"
		For nX := 1 To nLen
			oGridMdl:GoLine(nX)
            nValue  := IIF(oGridMdl:IsDeleted(),nValue ,nValue  + ;
                        oGridMdl:GetValue("B_VALCNV")          )
            nVATAMT := IIF(oGridMdl:IsDeleted(),nVATAMT,nVATAMT + ;
                        oGridMdl:GetValue("B_VLVATC")          )
            If lInflow
                nVATCon := IIF(oGridMdl:IsDeleted(),nVATCon,nVATCon + ;
                             Round(oGridMdl:GetValue("B_VLVATC")/oGridMdl:GetValue("B_EXGRAT"),GetSX3Cache("F4C_ITVATO", "X3_DECIMAL"))    )
            EndIf
		Next nX
	ElseIf cID == "F5M"
		For nX := 1 To nLen
			oGridMdl:GoLine(nX)
            nValue  := IIF(oGridMdl:IsDeleted(),nValue ,nValue  + ;
                            oGridMdl:GetValue("F5M_VALCNV")        )
            nVATAMT := IIF(oGridMdl:IsDeleted(),nVATAMT,nVATAMT + ;
                        oGridMdl:GetValue("F5M_VLVATC")        )
            If lInflow
                nVATCon := IIF(oGridMdl:IsDeleted(),nVATCon,nVATCon + ;
                            Round(oGridMdl:GetValue("F5M_VLVATC")/oGridMdl:GetValue("F5M_EXGRAT"),GetSX3Cache("F4C_ITVATO", "X3_DECIMAL"))    )
            EndIf
		Next nX
	EndIf
    oGridMdl:GoLine(nCurrPs)
    If lInflow
        aRet := {nValue, nVATAMT, nVATCon} 
	Else
        aRet := {nValue, nVATAMT} 
    EndIf

Return (aRet) /*----------------------------------------------RU06D07E7_RetTotalsForHeader*/


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07E8_UpdateVATValuesInVrtGrid
This function should be called when we change VAT in Header model, so
VAT amounts and VAT rates in virtual grid should be updated only for PA lines
It is called by RU06D0716_VldVat, and can be called by other functions

@param       Object           oModelF4C
             Object           oModelVrt
@return      Numeric          nVATbyLns // Return total VAT by lines which will be used
                                           for change or not F4C_VATAMT
@example     
@author      astepanov
@since       August/01/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07E8_UpdateVATValuesInVrtGrid(oModelF4C, oModelVrt)

	Local lRet       As Logical
	Local nX         As Numeric
	Local nVATbyLns  As Numeric
	Local nStop      As Numeric
	Local nAlimp1    As Numeric

	lRet      := .T.
	nVATbyLns := 0
	nX        := 1
	nStop     := oModelVrt:Length()
	nAlimp1   := IIF(Empty(oModelF4C:GetValue("F4C_VATRAT")),0,;
                     oModelF4C:GetValue("F4C_VATRAT")          )
	While lRet .AND. nX <= nStop
		oModelVrt:GoLine(nX)
		If !oModelVrt:IsDeleted() //update VAT only for prepayment
			If AllTrim(oModelVrt:GetValue("B_TYPE")) $ "PA|RA"
                //B_ALIMP1
                oModelVrt:LoadValue("B_ALIMP1",nAlimp1)
				//B_VLVATC
				lRet := lRet .AND. oModelVrt:LoadValue("B_VLVATC",;
				RU06XFUN18_VATFormula(oModelVrt:GetValue("B_VALCNV"),;
				{nAlimp1,100},;
				GetSX3Cache("F5M_VLVATC", "X3_DECIMAL"),;
				.T.)                                                 )
		        //B_BSVATC
		        lRet := lRet .AND. oModelVrt:LoadValue("B_BSVATC" ,;
		        oModelVrt:GetValue("B_VALCNV") - ;
				oModelVrt:GetValue("B_VLVATC")                     )
                //B_VLIMP1
                oModelVrt:LoadValue("B_VLIMP1",;
                ROUND((oModelVrt:GetValue("B_VLVATC"))/;
                               oModelVrt:GetValue("B_EXGRAT"),;
                       GetSX3Cache("E2_VALIMP1", "X3_DECIMAL")))
                //B_BSIMP1
                oModelVrt:LoadValue("B_BSIMP1",oModelVrt:GetValue("B_VALPAY")-;
                                       oModelVrt:GetValue("B_VLIMP1")         )
            EndIf
			nVATbyLns := nVATbyLns + oModelVrt:GetValue("B_VLVATC")
		EndIf
		nX := nX + 1
	EndDo

Return (nVATbyLns) /*-----------------------------------RU06D07E8_UpdateVATValuesInVrtGrid*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07E9_UpdateF5MLine
This function should be called when we update line in virtual grid for 
outflow bank statement

@param       Object           oSubModel // for example oModelVrt
             Object           oMdlHdr   // for example oModelF4C
             Character        cAction   // "DELETE", "UNDELETE", "UPDATE"
@return      Logical          lRet
@example     
@author      astepanov
@since       August/01/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07E9_UpdateF5MLine(oSubModel, oMdlHdr, cAction)

	Local lRet       As Logical
    Local cHlpMsg    As Character
	Local oModelF5M  As Object
	Local aKey       As Array

	lRet      := .F.
    cHlpMsg   := ""
	oModelF5M := oSubModel:GetModel():GetModel("RU06D07_MLNS")
    aKey      := RU06D07021_GetAF5MKey(oMdlHdr, oSubModel)
	If     cAction == "DELETE"
		If oModelF5M:SeekLine(aKey)
			lRet := oModelF5M:DeleteLine()
		Else
			lRet := .F.
            cHlpMsg := STR0182 //No line
		EndIf
	ElseIf cAction == "UNDELETE"
		If oModelF5M:SeekLine(aKey)
			lRet    := .F. // can't undelete line which already exists with same key
            cHlpMsg := STR0183 //duplicate line with same key
		Else
			oModelF5M:GoLine(1)
			If oModelF5M:SeekLine(aKey,.T.,.T.)
				lRet := oModelF5M:UndeleteLine()
			Else
				lRet := .F.
                cHlpMsg := STR0182 //No line
			EndIf
		EndIf
	ElseIf cAction == "UPDATE"
		If oModelF5M:SeekLine(aKey)
			lRet := .T.
			oModelF5M:LoadValue("F5M_VALPAY",oSubModel:GetValue("B_VALPAY"))
			oModelF5M:LoadValue("F5M_EXGRAT",oSubModel:GetValue("B_EXGRAT"))
			oModelF5M:LoadValue("F5M_VALCNV",oSubModel:GetValue("B_VALCNV"))
			oModelF5M:LoadValue("F5M_BSVATC",oSubModel:GetValue("B_BSVATC"))
			oModelF5M:LoadValue("F5M_VLVATC",oSubModel:GetValue("B_VLVATC"))
            oModelF5M:LoadValue("F5M_BSVATO",oSubModel:GetValue("B_BSIMP1"))
			oModelF5M:LoadValue("F5M_VLVATO",oSubModel:GetValue("B_VLIMP1"))
			oModelF5M:LoadValue("F5M_RATUSR",oSubModel:GetValue("B_RATUSR"))
		Else
			lRet := .F.
            cHlpMsg := STR0184 //It's impossible to update this line
		EndIf
	EndIf
    If !lRet
        HELP("", 1, STR0017 + STR0052, ,;   // BS Information
             cHlpMsg,;
             1,0,,,,,,;
             /*{"solution"}*/)
    EndIf

Return (lRet) /*---------------------------------------------------RU06D07E9_UpdateF5MLine*/

//------------------------------------------------------------------------------------------


	

	
	


/*/{Protheus.doc} RU06D07E11_UpdateFM5MLnsWhenSupOrCusValidatedBeforeDeletion

When supplier or customer valiadated we should delete F5M lines, 
because F4C_SUPP and F4C_UNIT for outflow BS (or F4C_CUST and F4C_CUNI for inflow BS)
are news, but deletion starts virt model, so we update lines before deletion

@param       Object           oModelF5M	
             Character        cForCli //F4C_SUPP or F4C_CUST
			 Character        cLoja   //F4C_UNIT or F4C_CUNI
             Logical          lInf    //if .T. - this is inflow BS, 
                                        if .F. - this is outflow BS
@return      Logical          lRet
@example     
@author      astepanov
@since       August/07/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07E11_UpdateFM5MLnsWhenSupOrCusValidatedBeforeDeletion(oModelF5M,;
         cForCli, cLoja, lInf                                                  )

	Local lRet       As Logical
	Local nX         As Numeric
	Local nY         As Numeric
    Local nTamForCli As Numeric
    Local nTamLoja   As Numeric
	Local cKey       As Character
	Local cNewKey    As Character
	Local aKey       As Array
    
    Default lInf     := .F.

	lRet := .T.

    nTamForCli := GetSX3Cache(IIf(lInf,"E1_CLIENTE","E2_FORNECE"), "X3_TAMANHO")
    nTamLoja   := GetSX3Cache(IIf(lInf,"E1_LOJA","E2_LOJA")      , "X3_TAMANHO")
	For nX := 1 To oModelF5M:Length()
		oModelF5M:GoLine(nX)
		If !oModelF5M:IsDeleted()
			cKey   := oModelF5M:GetValue("F5M_KEY")
			aKey   := StrTokArr(cKey, "|")
			aKey[6] := PADR(cForCli,nTamForCli, " ")
			aKey[7] := PADR(cLoja  ,nTamLoja  , " ")
			cNewKey := ""
			For nY := 1 To Len(aKey) - 1
				cNewKey += aKey[nY] + "|"
			Next nY
			cNewKey += aKey[Len(aKey)] 
			oModelF5M:LoadValue("F5M_KEY",cNewKey)
		EndIf
	Next nX
	
Return (lRet) /*---------------RU06D07E11_UpdateFM5MLnsWhenSupOrCusValidatedBeforeDeletion*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07840_AccountPostHeader()

Function used for posting bank statement header in accounting.
So, it should be previously positioned in the correct F4C record before posting

@param
             Logical          lReplace //We post in accounting Replacement?
@return      Logical          lRet
@private     lDigita, lGeraLanc
@public      cUsuario
@static      lUsaFlag
@example     
@author      astepanov
@since       September/23/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07840_AccountPostHeader(lReplace)

    Local lRet       As Logical
    Local cHlpMsg    As Character
    Local cSltMsg    As Character
    Local cArquivo   As Character
    Local cPadrao    As Character
    Local cChaveBusc As Character
    Local nHdlPrv    As Numeric
    Local nRecFK5    As Numeric
    Local nRecSE5    As Numeric
    Local aArea      As Array
    Local aFlagCTB   As Array
    Local aChkRes    As Array
    Default lReplace := .F.

    lRet       := .T.
    cHlpMsg    := ""
    cSltMsg    := ""
    nHdlPrv    := 0
    nRecFK5    := 0
    nRecSE5    := 0
    aFlagCTB   := {}

    aArea      := GetArea()
    cPadrao     := ""
    If     F4C->F4C_OPER == "2" // outflow BS
        cPadrao := LP_570_ACCTPOST  
    ElseIf F4C->F4C_OPER == "1" // inflow  BS
        cPadrao := LP_575_INFACCPS
    EndIf
    If lRet .AND. lGeraLanc .AND. !Empty(cPadrao) .AND. VerPadrao(cPadrao) 
        //+--------------------------------------------------------------+
        // Positions Batch Number for Financial Postings			     
        //+--------------------------------------------------------------+
        cArquivo  := ""
        nHdlPrv   := RU06D07017_RetNHndlBxPrv(@cArquivo)
        If nHdlPrv <= 0
            lRet    := .F.
            cHlpMsg := STR0162 //A100NoPROV
            cSltMsg := ""
        EndIf
    EndIf
    If nHdlPrv > 0
        // Positions in the last FK5 avaliable
        nRecFK5 := RU06D07870_RecFK5(F4C->F4C_CUUID)
        If nRecFK5 > 0
            FK5->(DbGoTo(nRecFK5))
            SE5->(DbSetOrder(21)) //E5_FILIAL+E5_IDORIG+E5_TIPODOC
            // Positions in the last moviment SE5 avaliable                                                                                                                               
            If SE5->(DBSeek(xFilial("SE5")+FK5->FK5_IDMOV+FK5->FK5_TPDOC))
                nRecSE5 := SE5->(RecNo())
            EndIf
        EndIf      
        AADD(aFlagCTB, {"F4C_LA", "S", "F4C", F4C->(RecNo()), 0, 0, 0})
        If nRecFK5 > 0
            AADD(aFlagCTB, {"FK5_LA", "S", "FK5", nRecFK5, 0, 0, 0})
        EndIf
        If nRecSE5 > 0
            AADD(aFlagCTB, {"E5_LA" , "S", "SE5", nRecSE5, 0, 0, 0})
        EndIf
        cChaveBusc := F4C->F4C_FILIAL+F4C->F4C_CUUID
        aChkRes := RU06D07018_A100Include(nHdlPrv, @cArquivo, cPadrao, "F4C", {},;
                                          aFlagCTB, cChaveBusc , IIF(lReplace,F4C->F4C_DTREPL,F4C->F4C_DTTRAN) )
        lRet    := aChkRes[1]
        cHlpMsg := aChkRes[2]
    EndIf  
    If !lRet
        Help("",1,STR0161,,; //Post in Accounting
             cHlpMsg,;
             1,0,,,,,,{cSltMsg}          )
    EndIf
    RestArea(aArea)

Return (lRet) /*----------------------------------------------RU06D07840_AccountPostHeader*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07850_AccountPostAdv

<Short description>
For correct work should be positioned on correct F4C record
@param       Array            aTit {"FILIAL" , "PREFIXO", "NUM", "PARCELA", "TIPO",
                                    "FORNECE", "LOJA"  ...                        }
             Character        cWorkTab  // "SE1" or "SE2"
@return      Logical          lRet
@private     lGeraLanc
@example     
@author      astepanov
@since       September/25/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07850_AccountPostAdv(aTit, cWorkTab,lReplace)

    Local lRet       As Logical
    Local cPadrao    As Character
    Local cArquivo   As Character
    Local cHlpMsg    As Character
    Local cSltMsg    As Character
    Local cChaveBusc As Character
    Local cLA        As Character
    Local nHdlPrv 	 As Numeric
    Local aArea      As Array
    Local aFlagCTB   As Array
    Local aChkRes    As Array

    Default cWorkTab := "SE2"
    DEFAULT lReplace :=.F.

    lRet       := .T.
    nHdlPrv    := 0 
    cArquivo   := ""
    cHlpMsg    := ""
    cSltMsg    := ""
    aFlagCTB   := {}
    aArea      := GetArea()
    cPadrao    := ""
    If     cWorkTab == "SE2"
        cPadrao := LP_5BB_AP_PRPST
        cLA     := "E2_LA"
    ElseIf cWorkTab == "SE1"
        cPadrao := LP_5BP_AR_RAPST
        cLA     := "E1_LA"
    EndIf  
    If lGeraLanc .AND. !Empty(cPadrao) .AND. VerPadrao(cPadrao)
        nHdlPrv := RU06D07017_RetNHndlBxPrv(@cArquivo)
        If nHdlPrv > 0
            (cWorkTab)->(DBSetOrder(1)) //_FILIAL+_PREFIXO+_NUM+_PARCELA+
                                        //_TIPO+_FORNECE(_CLIENTE)+E_LOJA
            (cWorkTab)->(DBSeek(aTit[1]+aTit[2]+aTit[3]+aTit[4]+aTit[5]+aTit[6]+aTit[7]))
            AADD(aFlagCTB, {cLA, "S", cWorkTab, (cWorkTab)->(Recno()), 0, 0, 0})
            SE5->(DBSetOrder(7)) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+
                                //E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
            If  SE5->(DBSeek(xFilial("SE5",aTit[1])+aTit[2]+aTit[3]+aTit[4]+;
                                     aTit[5]+aTit[6]+aTit[7]                ))
                AADD(aFlagCTB, {"E5_LA", "S", "SE5", SE5->(Recno()), 0, 0, 0})
            EndIf
            cChaveBusc := F4C->F4C_FILIAL+F4C->F4C_CUUID
            aChkRes := RU06D07018_A100Include(nHdlPrv, @cArquivo, cPadrao, "F4C", {},;
                                              aFlagCTB, cChaveBusc,Iif(lReplace,F4C->F4C_DTREPL,F4C->F4C_DTTRAN))

            lRet    := aChkRes[1]
            cHlpMsg := aChkRes[2]
        Else
            lRet    := .F.
            cHlpMsg := STR0162 //A100NOPROV
            cSltMsg := ""
        EndIf
    EndIf
    If !lRet
        Help("",1,STR0161,,; //Post in Accounting
             cHlpMsg,;
             1,0,,,,,,{cSltMsg}          )
    EndIf
    RestArea(aArea)
    
Return (lRet) /*--------------------------------------------------------RU06D07850_AccountPostAdv*/


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07870_RecFK5

Function Used to return the Recno of the bank transaction in FK5 that is not canceled

@param       Character        cF4C_CUUID F4C->F4C_CUUID
@return      Numeric          nRec
                              Recno number related to the line of the Bank Transaction 
                              related to that Bank Statment and that is not canceled.
@example     
@author      astepanov
@since       September/27/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07870_RecFK5(cF4C_CUUID)

    Local   nRec       As Numeric
    Local   cQuery     As Character
    Local   cAlias     As Character
    Local   aArea      As Array
    Default cF4C_CUUID := " "

    nRec  := 0
    aArea := GetArea()  
    cQuery := "SELECT                                                                     "
    cQuery += "FKFINAL.R_E_C_N_O_                                                         "
    cQuery += "FROM      (                                                                "
    cQuery += "            SELECT *                                                       "
    cQuery += "            FROM " + RetSQLName("FK5")+ "                                  "
    cQuery += "            WHERE                                                          "
    cQuery += "                  FK5_FILIAL = '"+xFilial("FK5")+"'                        "
    cQuery += "              AND FK5_IDBS   = '"  +cF4C_CUUID+"'                          "
    cQuery += "              AND D_E_L_E_T_ = ' '                         )  FKFINAL      "
    cQuery += "LEFT JOIN (                                                                "
    cQuery += "            SELECT FKX.FKA_IDORIG UUID                                     "
    cQuery += "            FROM      (                                                    "
    cQuery += "                        SELECT FKA.FKA_IDPROC SUBPROC                      "
    cQuery += "                        FROM      (                                        "
    cQuery += "                                    SELECT FK5_IDMOV MOV                   "
    cQuery += "                                    FROM " + RetSQLName("FK5") + "         "
    cQuery += "                                    WHERE                                  "
    cQuery += "                                          FK5_FILIAL = '"+xFilial("FK5")+"'"
    cQuery += "                                      AND FK5_TPDOC  = 'ES'                "
    cQuery += "                                      AND D_E_L_E_T_ = ' ' )      FK5      "
    cQuery += "                        INNER JOIN " + RetSQLName("FKA") + " FKA           "
    cQuery += "                                ON  FKA.FKA_FILIAL = '"+xFilial("FKA")+"'  "
    cQuery += "                                AND FKA.FKA_IDORIG = FK5.MOV               "
    cQuery += "                                AND FKA.D_E_L_E_T_ = ' '   ) FKAXESTO      "
    cQuery += "            LEFT JOIN " + RetSQLName("FKA") + " FKX                        "
    cQuery += "                   ON   FKX.FKA_FILIAL = '"+xFilial("FKA")+"'              "
    cQuery += "                   AND  FKX.FKA_IDPROC = FKAXESTO.SUBPROC                  "
    cQuery += "                   AND  FKX.D_E_L_E_T_ = ' '                               "
    cQuery += "                   AND  FKX.FKA_TABORI = 'FK5'             )  FK5XFKA      "
    cQuery += "       ON  FK5XFKA.UUID = FKFINAL.FK5_IDMOV                                "
    cQuery += "WHERE  FK5XFKA.UUID IS NULL                                                "

    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    aArea  := GetArea()
    DBSelectArea(cAlias)
    DBGoTop()
    If !Eof()
       nRec := (cAlias)->R_E_C_N_O_ 
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    
Return (nRec) /*---------------------------------------------------------RU06D07870_RecFK5*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07880_UpdateNonPostedPARALineWhenLoad

Call this function when we load not posted PA lines.
They are exist in F5M but they are not exist in SE2, so we should recalculate values

@param       Array            aFields    // List of fields in Vrt model
             Array            aValues    // link to array of values
@return      Logical          lRet
@example     
@author      astepanov
@since       September/30/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07880_UpdateNonPostedPARALineWhenLoad(aFields, aValues)

    Local lRet       As Logical
	Local nRnd       As Numeric
    Local nBVlcruz   As Numeric
    Local nBOpBal    As Numeric
    Local nX         As Numeric
    Local nVPPos     As Numeric 
    Local nERPos     As Numeric 
    Local nBTypePos  As Numeric 
    Local nVlCrzPos  As Numeric 
    Local nVlimpPos  As Numeric 
    Local nBSimpPos  As Numeric 
    Local nOpbalPos  As Numeric
    Local nBPrfxPos  As Numeric
    Local nAlimpPos  As Numeric
    Local nValuePos  As Numeric
    Local nCurrPs    As Numeric
    Local nConuPs    As Numeric
    Local nVlCnPs    As Numeric
    Local nVlVATCPs  As Numeric
    Local nExgCRZ    As Numeric
    Local nEMISS     As Numeric
    Local nREALMT    As Numeric
    Local nBCLASS    As Numeric
    Local cDate      As Character
    Local cAdvMrk    As Object

   	lRet      := .T.
    nVPPos    := 0
    nERPos    := 0
    nBTypePos := 0
    nVlCrzPos := 0
    nVlimpPos := 0
    nBSimpPos := 0
    nOpbalPos := 0
    nBPrfxPos := 0
    nAlimpPos := 0
    nValuePos := 0
    nCurrPs   := 0
    nConuPs   := 0
    nVlVATCPs := 0
    nVlCnPs   := 0
    nEMISS    := 0
    nREALMT   := 0
    nBCLASS   := 0

    For nX := 1 To Len(aFields)
         If AllTrim(aFields[nX][3]) == "B_VALPAY"
            nVPPos := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_EXGRAT"
            nERPos := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_TYPE"
            nBTypePos := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_VLCRUZ"
            nVlCrzPos := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_VLIMP1"
            nVlimpPos := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_BSIMP1"
            nBSimpPos := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_OPBAL"
            nOpbalPos := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_PREFIX"
            nBPrfxPos := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_ALIMP1"
            nAlimpPos := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_VALUE"
            nValuePos := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_CURREN"
            nCurrPs   := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_CONUNI"
            nConuPs   := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_VALCNV"
            nVlCnPs   := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_VLVATC"
            nVlVATCPs := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_EMISS"
            nEMISS := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_REALMT"
            nREALMT := nX
         EndIf
         If AllTrim(aFields[nX][3]) == "B_CLASS"
            nBCLASS := nX
         EndIf
    Next nX
    cAdvMrk := IIf(F4C->F4C_OPER == "1", "RA", "PA")
    If Empty(FwFldGet("F4C_DTREPL"))
        cDate := "F4C_DTTRAN"
    Else
        cDate := "F4C_DTREPL"
    EndIf
    //empty prefix means that we have no SE2 or SE1 line
    If AllTrim(aValues[nBTypePos]) == cAdvMrk .AND.;
       Empty(aValues[nBPrfxPos])
        //B_CURREN and B_CONUNI in case of legal contract
        If !Empty(FwFldGet("F4C_UIDF5Q"))
            aValues[nCurrPs] := Posicione("F5Q",1,xFilial("F5Q")+FwFldGet("F4C_UIDF5Q"),;
                                          "F5Q_MOEDA"                                   )
            aValues[nConuPs] := Posicione("F5Q",1,xFilial("F5Q")+FwFldGet("F4C_UIDF5Q"),;
                                          "F5Q_CONUNI"                                  )
        EndIf
        nExgCRZ := xMoeda(1, aValues[nCurrPs], 1, FwFldGet(cDate),;
                          GetSX3Cache("F5M_EXGRAT","X3_DECIMAL")         )
        nExgCRZ := IIF(nExgCRZ == 0, 1, nExgCRZ)
        //B_VLCRUZ
        nRnd      := GetSX3Cache("E2_VLCRUZ", "X3_DECIMAL")
        If aValues[nCurrPs] != Val(FwFldGet("F4C_CURREN"))
            nBVlcruz := aValues[nVlCnPs]
        Else
            nBVlcruz := ROUND(aValues[nVPPos]*nExgCRZ,nRnd)
        EndIf
        //B_OPBAL
        nBOpBal   := aValues[nVPPos]

        aValues[nVlCrzPos] := nBVlcruz
        aValues[nOpbalPos] := nBOpBal
        aValues[nValuePos] := nBOpBal
        aValues[nAlimpPos] := FWFldGet("F4C_VATRAT")
        aValues[nEMISS]    := FWFldGet(cDate)
        aValues[nREALMT]   := FWFldGet(cDate)
        avalues[nBCLASS]   := FWFldGet("F4C_CLASS")
    EndIf

Return (lRet) /*--------------------------------RU06D07880_UpdateNonPostedPARALineWhenLoad*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07890_RecFKX

Function Used to return the Recno of the Write-off  FK2 (FK1) that is not canceled related to a 
specific BS and a speific PA(RA) linked to that BS 
FK7_CHAVE =  E2_FILIAL + '|' + E2_PREFIXO + '|' + E2_NUM + '|' + E2_PARCELA + '|' + 
             E2_TIPO + '|' + E2_FORNECE + '|' + E2_LOJA
             or
             E1_FILIAL + '|' + E1_PREFIXO + '|' + E1_NUM + '|' + E1_PARCELA + '|' + 
             E1_TIPO + '|' + E2_CLIENTE + '|' + E1_LOJA

@param       Character 	      Internal Key of the BS line: F4C_INTNUM
             Character 	      Unique key based on SE2:     F5M_KEY
             Date             Transaction date             F4C_DTTRAN
             Character        "SE1" or "SE2"               cWorkTab
@return      Numeric          nRec
@example     
@author      astepanov
@since       September/30/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07890_RecFKX(cINTNUM, cF5MKey, dDTTRAN, cWorkTab)

    Local aArea   As Array
    Local nRec    As Numeric
	Local cQuery  As Character
	Local cAlias  As Character
    Local cFKX    As Character
    Local lInflow As Logical

    Default  cWorkTab := "SE2"

    cFKX    := IIF(cWorkTab == "SE2","FK2","FK1")
    lInflow := IIF(cWorkTab == "SE2", .F., .T.)
    cINTNUM := PADR(cINTNUM, GetSX3Cache(cFKX+"_ORDREC","X3_TAMANHO"), " ")
    cF5MKey := SUBSTR(cF5MKey,1,RU06XFUN44_RetSE2FldsPosInFMKey(lInflow)[8][4])
    cF5MKey := PADR(cF5MKey, GetSX3Cache("FK7_CHAVE" ,"X3_TAMANHO"), " ")
    nRec    := 0

   	aArea  := GetArea()
    cQuery := "SELECT                                                            "
    cQuery += "        "+cFKX+".R_E_C_N_O_                                       "
    cQuery += "FROM       (                                                      "
    cQuery += "            SELECT *                                              "
    cQuery += "            FROM " + RetSQLName(cFKX) + "                         "
    cQuery += "            WHERE   "+cFKX+"_FILIAL  = '" + xFilial(cFKX) + "'    "
    cQuery += "              AND   D_E_L_E_T_  = ' '                             "
    cQuery += "              AND   "+cFKX+"_ORDREC  = '" + cINTNUM + "'          "
    cQuery += "              AND   "+cFKX+"_DATA    = '" + DTOS(dDTTRAN) + "'    "
    cQuery += "                                                        )"+cFKX+" "
    cQuery += "INNER JOIN " + RetSQLName("FK7") + "                      FK7     "
    cQuery += "        ON   FK7.FK7_FILIAL = '" + xFilial("FK7") + "'            "
    cQuery += "        AND  FK7.D_E_L_E_T_ = ' '                                 "
    cQuery += "        AND  FK7.FK7_ALIAS  = '" + cWorkTab+ "'                   "
    cQuery += "        AND  FK7.FK7_CHAVE  = '" + cF5MKey + "'                   "
    cQuery += "        AND  FK7.FK7_IDDOC  = "+cFKX+"."+cFKX+"_IDDOC             "
    cQuery += "INNER JOIN " + RetSQLName("FKA") + "                      FKA     "
    cQuery += "        ON   FKA.FKA_FILIAL = '" + xFilial("FKA") + "'            "
    cQuery += "        AND  FKA.D_E_L_E_T_ = ' '                                 "
    cQuery += "        AND  FKA.FKA_IDORIG = "+cFKX+"."+cFKX+"_ID"+cFKX+"        "
    cQuery += "LEFT  JOIN (                                                      "
    cQuery += "            SELECT                                                "
    cQuery += "                   FKA_IDPROC                                     "
    cQuery += "            FROM " + RetSQLName("FKA") + " FKA                    "
    cQuery += "            INNER JOIN " + RetSQLName(cFKX) + " "+cFKX+"          "
    cQuery += "               ON  "+cFKX+"."+cFKX+"_FILIAL = '"+xFilial(cFKX)+"' "
    cQuery += "               AND "+cFKX+"."+cFKX+"_TPDOC  = 'ES'                "
    cQuery += "               AND "+cFKX+".D_E_L_E_T_ = ' '                      "
    cQuery += "               AND FKA.FKA_FILIAL = '" + xFilial("FKA") + "'      "
    cQuery += "               AND FKA.FKA_TABORI = '"+cFKX+"'                    "
    cQuery += "               AND FKA.D_E_L_E_T_ = ' '                           "
    cQuery += "               AND FKA.FKA_IDORIG = "+cFKX+"."+cFKX+"_ID"+cFKX+"  "
    cQuery += "            GROUP BY FKA.FKA_IDPROC                     ) EST     "
    cQuery += "        ON   FKA.FKA_IDPROC = EST.FKA_IDPROC                      "
    cQuery += "WHERE EST.FKA_IDPROC IS NULL                                      "

    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    DBSelectArea(cAlias)
    DBGoTop()
    If !Eof()
        nRec := (cAlias)->R_E_C_N_O_
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    
Return (nRec) /*---------------------------------------------------------RU06D07890_RecFKX*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07900_AccountPostPstpay

Function used for posting in accounting for Postpayment APs or Postpayment ARs

@param       Array            aRecBx  //{Recno for FK2, Recno for SE5,
                                         key for SE2, key for F5M     }
             Character        cWorkTab   // "SE2" or "SE1"
@return      Logical          lRet
@example
@private     lGeraLanc
@public      cUsuario
@static      lUsaFlag
@author      astepanov
@since       September/30/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07900_AccountPostPstpay(aRecBx, cWorkTab,lReplace)

    Local lRet       As Logical
    Local cArqBx     As Character 
    Local cPadrao    As Character
    Local cHlpMsg    As Character
    Local cSltMsg    As Character
    Local cFKX       As Character
    Local nHdlBxPrv  As Numeric
    Local aArea      As Array
    Local aChkRes    As Array

    Default cWorkTab := "SE2"
    DEFAULT lReplace :=.F.


    lRet       := .T.
    cArqBx     := ""
    nHdlBxPrv  := 0
    cHlpMsg    := ""
    cSltMsg    := ""
    aArea      := GetArea()
    cPadrao    := ""
    If     cWorkTab == "SE2"
        cPadrao := LP_530_AP_WROFF
        cFKX    := "FK2"
    ElseIf cWorkTab == "SE1"
        cPadrao := LP_520_AR_WROFF
        cFKX    := "FK1"
    EndIf
    If lGeraLanc  .AND. !Empty(cPadrao) .AND. VerPadrao(cPadrao)
        nHdlBxPrv := RU06D07017_RetNHndlBxPrv(@cArqBx)
        If nHdlBxPrv <= 0
            lRet    := .F.
            cHlpMsg := STR0162 //A100NOPROV
            cSltMsg := ""
        EndIf
    EndIf
    If nHdlBxPrv > 0
        aChkRes := RU06D07018_A100Include(nHdlBxPrv, @cArqBx, cPadrao, cFKX, aRecBx, {}, "" ,Iif(lReplace,F4C->F4C_DTREPL,F4C->F4C_DTTRAN))
        lRet    := aChkRes[1]
        cHlpMsg := aChkRes[2]
    EndIf
    If !lRet
        Help("",1,STR0161,,; //Post in Accounting
             cHlpMsg,;
             1,0,,,,,,{cSltMsg}          )  
    EndIf
    RestArea(aArea)

Return (lRet) /*----------------------------------------------RU06D07900_AccountPostPstpay*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07091_PositionSA2SA6FIL

Function called when we post in accounting. It positions cursor in SA2, SA6 and FIL
tables. For correct work we should be positioned on correct F4C record

@return      Logical          lRet .T. - all records positioned, .F. - one or more records
                                   not positioned
@example     
@author      astepanov
@since       October/01/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07091_PositionSA2SA6FIL()

    Local lRet       As Logical
    Local aArea      As Array
    Local cAliasFIL  As Character
    Local nFILRecno  As Numeric

    lRet := .T.

    aArea  := GetArea()
    SA2->(DBSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
    lRet := IIF(SA2->(DBSeek(xFilial("SA2")+F4C->F4C_SUPP+F4C->F4C_UNIT)),;
                .T.,.F.) .AND. lRet
    SA6->(DBSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
    lRet := IIF(SA6->(DBSeek(xFilial("SA6")+;
                F4C->F4C_BNKPAY+F4C->F4C_PAYBIK+F4C->F4C_PAYACC,.F.)),;
                .T.,.F.) .AND. lRet              
    cAliasFIL := RU06XFUN40_RetBankAccountDataFromFIL(F4C->F4C_SUPP  ,;
                                                      F4C->F4C_UNIT  ,;
                                                      Nil            ,;
                                                      F4C->F4C_BNKREC,;
                                                      F4C->F4C_RECBIK,;
                                                      F4C->F4C_RECACC,;
                                                      .T., .F.        )
    DBSelectArea(cAliasFIL)
    DBGoTop()
    If !EoF()
        nFILRecno := 0
        nFILRecno := (cAliasFIL)->_FILREC
        If nFILRecno <> 0
            FIL->(DBSetOrder(1)) //FIL_FILIAL+FIL_FORNEC+FIL_LOJA+FIL_TIPO+
                                //FIL_BANCO+FIL_AGENCI+FIL_CONTA   
            FIL->(DBGoTo(nFILRecno))
        Else
            lRet := .F.
        EndIf
    EndIf
    (cAliasFIL)->(DBCloseArea())
    RestArea(aArea)
    
Return (lRet) /*----------------------------------------------RU06D07091_PositionSA2SA6FIL*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07930_A100Cncl

Function called when we cancel Financial posting. For correct work should be positioned on
correct F4C record

@param       Numeric          nHdlF4C     
             Character        cIdProcHea
             Character        cArquivo
             Character        cPadrao
             Logical          lRev     .T. when called by RU06D0740_ReverseFinancialPost
             Date             dDatAcc     //Data that will be consider at accounting post process, if empty will be dDataBase
@return      Logical          lRet
@example     
@author      astepanov
@since       October/04/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07930_A100Cncl(nHdlF4C,cIdProcHea,cArquivo,cPadrao,lRev,dDatAcc)

    Local lRet       As Logical
    Local nRecFk5    As Numeric
    Local aFlagHead  As Array
    Local aArea      As Array
    Local aChkRes    As Array
    Local cChaveBusc As Character
    Local cHlpMsg    As Character

    Default lRev     := .F.
    Default dDatAcc  := dDataBase

    lRet       := .T.
    nRecFk5    := 0
    aFlagHead  := {}
    aArea      := GetArea()
    cChaveBusc := ""

    If !Empty(cIdProcHea)
        nRecFk5 := RU06D07960_RecCanFK5(cIdProcHea)
        FK5->(DBGoTo(nRecFk5)) // need to positionate in the canceled FK5                                         
    EndIf
    AADD(aFlagHead, {"F4C_LA", IIF(lRev,"S"," "), "F4C", F4C->(RecNo()), 0, 0, 0})
    If nRecFk5 > 0
        AADD(aFlagHead, {"FK5_LA", "S", "FK5", nRecFk5, 0, 0, 0})
    EndIf
    cChaveBusc := F4C->F4C_FILIAL+F4C->F4C_CUUID
    aChkRes := RU06D07018_A100Include(nHdlF4C, @cArquivo, cPadrao, "F4C", {},;
                                      @aFlagHead, cChaveBusc  , dDatAcc      )
    lRet    := aChkRes[1]
    cHlpMsg := aChkRes[2]
    RestArea(aArea)
    
Return (lRet) /*------------------------------------------------------RU06D07930_A100Cncl*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07940_RecFKX_LA

Function Used to check if the Write-off hass beeen posted in account 

@param       Characther       cIDProc : responsible to link with the field 
                                        FKA_IDPROC and filter by process
             Characther       ckey    : responsible to link with the field 
                                        FK7_CHAVE and filter by AP
             Character        cFKX    : "FK2" or "FK1"
@return      Logical          lRet Returns if the writeoff has been posted in account
@example     
@author      astepanov
@since       October/04/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07940_RecFKX_LA(cIDProc, ckey, cFKX)

    Local lRet       As Logical
    Local cQuery     As Character
    Local cAlias     As Character
    Local aArea      As Array
    Default  cFKX := "FK2"

    lRet := .F.
    ckey    := SUBSTR(ckey,1,RU06XFUN44_RetSE2FldsPosInFMKey()[8][4])
    ckey    := PADR(ckey   , GetSX3Cache("FK7_CHAVE" , "X3_TAMANHO"), " ")
    cIDProc := PADR(cIDProc, GetSX3Cache("FKA_IDPROC", "X3_TAMANHO"), " ")
    cQuery := "SELECT                                                   "
    cQuery += "      "+cFKX+"."+cFKX+"_LA                               "
    cQuery += " FROM      (                                             "
    cQuery += "             SELECT *                                    "
    cQuery += "             FROM " + RetSQLName(cFKX) + "               "
    cQuery += "             WHERE "+cFKX+"_FILIAL = '"+xFilial(cFKX)+"' "
    cQuery += "               AND "+cFKX+"_TPDOC  = 'BA'                "
    cQuery += "               AND D_E_L_E_T_ = ' ' ) "+cFKX+"           "
    cQuery += " INNER JOIN " + RetSQLName("FK7") + " FK7                "
    cQuery += " ON       FK7.FK7_FILIAL = '" + xFilial("FK7") + "'      "
    cQuery += "    AND   FK7.FK7_IDDOC  = "+cFKX+"."+cFKX+"_IDDOC       "
    cQuery += "    AND   FK7.FK7_CHAVE  = '" +   ckey  +  "'            "
    cQuery += "    AND   FK7.D_E_L_E_T_ = ' '                           "
    cQuery += " INNER JOIN " + RetSQLName("FKA") + " FKA                "
    cQuery += " ON       FKA.FKA_FILIAL = '" + xFilial("FKA") + "'      "
    cQuery += "    AND   FKA.FKA_IDORIG = "+cFKX+"."+cFKX+"_ID"+cFKX+"  "
    cQuery += "    AND   FKA.FKA_IDPROC = '" + cIDProc + "'             "
    cQuery += "    AND   FKA.D_E_L_E_T_ = ' '                           "
    cQuery := ChangeQuery(cQuery)
    aArea  := GetArea()
    cAlias := MPSysOpenQuery(cQuery)
    DBSelectArea(cAlias)
    DbGoTop()
    If !EoF()
        lRet := (cAlias)->&(cFKX+"_LA") == "S"
    EndIf
    (cAlias)->(DbCloseArea())
    RestArea(aArea)
    
Return (lRet) /*------------------------------------------------------RU06D07940_RecFKX_LA*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07950_RecCancFKX

Function Used to Return the Register related to the cancelation of the write-off

@param       Characther       cIDProc to link with the field FKA_IDPROC and filter by proc
             Characther       ckey    to link with the field FK7_CHAVE and filter by AP or AR
             Character        cFKX    "FK2" or "FK1"
@return      Numeric          nRec    Recno of the Register in table FK2 to be positioned
@example     
@author      astepanov
@since       October/04/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07950_RecCancFKX(cIDProc, ckey, cFKX)

    Local nRec       As Numeric
    Local cQuery     As Character
    Local cAlias     As Character
    Local aArea      As Array

    Default cFKX := "FK2"
    nRec    := 0
    ckey    := SUBSTR(ckey,1,RU06XFUN44_RetSE2FldsPosInFMKey()[8][4])
    ckey    := PADR(ckey   , GetSX3Cache("FK7_CHAVE" , "X3_TAMANHO"), " ")
    cIDProc := PADR(cIDProc, GetSX3Cache("FKA_IDPROC", "X3_TAMANHO"), " ")
    cQuery := "SELECT                                                   "
    cQuery += "      "+cFKX+".R_E_C_N_O_                                "
    cQuery += " FROM      (                                             "
    cQuery += "             SELECT *                                    "
    cQuery += "             FROM " + RetSQLName(cFKX) + "               "
    cQuery += "             WHERE "+cFKX+"_FILIAL = '"+xFilial(cFKX)+"' "
    cQuery += "               AND "+cFKX+"_TPDOC  = 'ES'                "
    cQuery += "               AND D_E_L_E_T_ = ' ' ) "+cFKX+"           "
    cQuery += " INNER JOIN " + RetSQLName("FK7") + " FK7                "
    cQuery += " ON       FK7.FK7_FILIAL = '" + xFilial("FK7") + "'      "
    cQuery += "    AND   FK7.FK7_IDDOC  = "+cFKX+"."+cFKX+"_IDDOC       "
    cQuery += "    AND   FK7.FK7_CHAVE  = '" +   ckey  +  "'            "
    cQuery += "    AND   FK7.D_E_L_E_T_ = ' '                           "
    cQuery += " INNER JOIN " + RetSQLName("FKA") + " FKA                "
    cQuery += " ON       FKA.FKA_FILIAL = '" + xFilial("FKA") + "'      "
    cQuery += "    AND   FKA.FKA_IDORIG = "+cFKX+"."+cFKX+"_ID"+cFKX+"  "
    cQuery += "    AND   FKA.FKA_IDPROC = '" + cIDProc + "'             "
    cQuery += "    AND   FKA.D_E_L_E_T_ = ' '                           "
    cQuery := ChangeQuery(cQuery)
    aArea  := GetArea()
    cAlias := MPSysOpenQuery(CQuery)
    DBSelectArea(cAlias)
    DbGoTop()
    If !EoF()
        nRec  := (cAlias)->R_E_C_N_O_
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    
Return (nRec) /*-----------------------------------------------------RU06D07950_RecCancFKX*/


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07960_RecCanFK5

unction Used to Return the Register related to the cancelation of the Bank Transaction.

@param       Character        cProcess to link with the field FKA_IDPROC and filter by proc
@return      Numeric          nRec     of the Register in table FK5 to be positioned
@example     
@author      astepanov
@since       October/04/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07960_RecCanFK5(cProcess)

    Local nRec         As Numeric
    Local cQuery       As Character
    Local cAlias       As Character
    Local aArea        As Array

    nRec := 0
    cProcess := PADR(cProcess,GetSX3Cache("FKA_IDPROC","X3_TAMANHO"), " ")
    cQuery := "SELECT FK5.R_E_C_N_O_                                 "
    cQuery += "FROM   (                                              "
    cQuery += "         SELECT *                                     "
    cQuery += "         FROM  " + RetSQLName("FKA") + "              "
    cQuery += "         WHERE FKA_FILIAL = '" +  xFilial("FKA") + "' "
    cQuery += "           AND FKA_IDPROC = '" + cProcess + "'        "
    cQuery += "           AND FKA_TABORI = 'FK5'                     "
    cQuery += "           AND D_E_L_E_T_ = ' '    )  FKA             "
    cQuery += "INNER JOIN " + RetSQLName("FK5") + "  FK5             "
    cQuery += "        ON  FK5.FK5_FILIAL = '" + xFilial("FK5") + "' "
    cQuery += "        AND FK5.FK5_TPDOC  = 'ES'                     "
    cQuery += "        AND FK5.FK5_IDMOV  = FKA.FKA_IDORIG           "
    cQuery += "        AND FK5.D_E_L_E_T_ = ' '                      "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    aArea  := GetArea()
    DBSelectArea(cAlias)
    DbGoTop()
    If !EoF()
        nRec := (cAlias)->R_E_C_N_O_
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    
Return (nRec) /*------------------------------------------------------RU06D07960_RecCanFK5*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07001_TrackCtbXbs

Will be included in aCTL array in CTBA090.PRW

@param       
@return      Nil
@example     
@author      astepanov
@since       October/09/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07001_TrackCtbXbs()

    Local aArea     As Array
	aArea := GetArea()
	DBSelectArea("F4C")
	DBSetOrder(5) //F4C_FILIAL+F4C_CUUID
	If DBSeek(CV3->CV3_KEY) //Need to position the register before to open
		RU06D0710_Act(1)
	EndIf	
	RestArea(aArea)	
    
Return (Nil) /*-----------------------------------------------------RU06D07001_TrackCtbXbs*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07002_TrackWriteXbs

Will be included in aCTL array in CTBA090.PRW

@param
@return      Nil
@example     
@author      astepanov
@since       October/09/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07002_TrackWriteXbs()

    Local aArea     As Array
    Local cOrigem   As Character
    Local cIdFK     As Character
    Local cRecPag   As Character
    Local cFKTab    As Character
	aArea := GetArea()
	If DbSeek(CV3->CV3_KEY) //Need to position the register before to open
        cFKTab  := AllTrim(CV3->CV3_TABORI)
        DBSelectArea(cFKTab)
	    DbSetOrder(1) // FK2_FILIAL+FK2_IDFK2  or FK1_FILIAL+FK1_IDFK1
        cOrigem := &(cFKTab+"->"+cFKTab+"_ORIGEM")
        cIdFK   := &(cFKTab+"->"+cFKTab+"_ID"+cFKTab)
        cRecPag := &(cFKTab+"->"+cFKTab+"_RECPAG")
        cTpDoc  := &(cFKTab+"->"+cFKTab+"_TPDOC")
		If AllTrim(cOrigem) == "RU06D07"
			DBSelectArea("F4C")		
			F4C->(DBGoTo(RU06D07003_FKXToF4C(cIdFK,cRecPag)))		
			RU06D0710_Act(1)
		Else
			DBSelectArea("SE5")		
			SE5->(DbSetOrder(21)) //L: E5_FILIAL+E5_IDORIG+E5_TIPODOC
			If  SE5->(DBSeek(xFilial("SE5")+cIdFK+cTpDoc))
				CTBBAIXAPG()
			EndIf
		EndIf
	EndIf
    
    RestArea(aArea)	
  
Return (Nil) /*-------------------------------------------------------------RU06D07002_TrackWriteXbs*/

//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07003_FKXToF4C

Function Used to track BS (F4C) usinf Writeoff(FK2 or FK1) as parameter 

@param       Character        cIDFK_
             Character        cFK_RECPAG
@return      Numeric          nRec
@example     
@author      astepanov
@since       October/09/2019
@version     1.0
@project     MA3
@see         None
//-------------------------------------------------------------------------------------------------/*/
Function RU06D07003_FKXToF4C(cIDFK_,cFK_RECPAG)

    Local nRec       As Numeric
    Local cQuery     As Character
    Local cAlias     As Character
    Local aArea      As Array

    nRec := 0
    cIDFK_     := PADR(cIDFK_    , GetSX3Cache("FKA_IDORIG", "X3_TAMANHO"), " ")
    cFK_RECPAG := PADR(cFK_RECPAG, GetSX3Cache("FK5_RECPAG", "X3_TAMANHO"), " ")
    cQuery := "SELECT                                                                                "
    cQuery += "       R_E_C_N_O_                                                                     "
	cQuery += "FROM " + RetSQlName("F4C") + "                                                        "
    cQuery += "WHERE F4C_FILIAL = '"+xFilial("F4C",CT2->CT2_FILORI)+"'                               "
    cQuery += "  AND F4C_CUUID  = (                                                                  "
    cQuery += "                    /* subquery 1 begin---------------------------------------------*/"
    cQuery += "                    SELECT FK5_IDBS                                                   "
	cQuery += "                    FROM (                                                            "
    cQuery += "                          /* subquery 2 begin---------------------------------------*/"
    cQuery += "                          SELECT  FKA_IDORIG                                          "
	cQuery += "                          FROM " + RetSQlName("FKA") + "                              "
	cQuery += "                          WHERE FKA_FILIAL = '"+xFilial("FKA")+"'                     "
	cQuery += "                            AND FKA_IDPROC = (                                        "
    cQuery += "                                              /* subquery 3 begin-------------------*/"
    cQuery += "                                              SELECT FKA_IDPROC                       "
	cQuery += "                                              FROM " + RetSQlName("FKA") + "          "
	cQuery += "                                              WHERE FKA_FILIAL = '"+xFilial("FKA")+"' "
    cQuery += "                                                AND FKA_IDORIG = '" + cIDFK_ +"'      "
    cQuery += "                                                AND D_E_L_E_T_ = ' '                  "
    cQuery += "                                              /* subquery 3 end---------------------*/"
    cQuery += "                                             )                                        "
	cQuery += "                            AND FKA_TABORI = 'FK5'                                    "
    cQuery += "                            AND D_E_L_E_T_ = ' '                                      "
    cQuery += "                            /* subquery 2 end---------------------------------------*/"
    cQuery += "                         )                                                   FKA      "
	cQuery += "                    INNER JOIN "  + RetSQlName("FK5") + "                    FK5      "
    cQuery += "                            ON  FK5.FK5_FILIAL = '"+xFilial("FK5")+"'                 "
	cQuery += "                            AND FK5.FK5_IDMOV  = FKA.FKA_IDORIG                       "
    cQuery += "                            AND FK5.FK5_RECPAG = '" + cFK_RECPAG +"'                  "
    cQuery += "                            AND FK5.D_E_L_E_T_ = ' '                                  "
    cQuery += "                    /* subquery 1 end-----------------------------------------------*/"
    cQuery += "                   )                                                                  "
    cQuery += "  AND D_E_L_E_T_ = ' '                                                                "
    cQuery := ChangeQuery(cQuery)
    aArea  := GetArea()
    cAlias := MPSysOpenQuery(cQuery)
    DBSelectArea(cAlias)
    DBGoTop()
    If !EoF()
        nRec := (cAlias)->R_E_C_N_O_
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    
Return (nRec) /*-----------------------------------------------------------------RU06D07003_FKXToF4C*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07004_CheckAccntFieldsDuringFinPost
Function recieves header model and virual model, checks payment 
(recivable) types in the virual model.
Defines which accounting fields should be filled in header model.
If one of them is empty it will be added to value cFields, for example this function
can return "F4C_CTPOS, F4C_CCPOS" or empty string in case all required accounting fields
are filled.
@param       Object        oModelF4C
             Object        oModelVrt
             Character     cAdvTipo        // "PA" or "RA"
@return      Character     cFields         //list of emty accounting fields
@example
@author      astepanov
@since       October/09/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07004_CheckAccntFieldsDuringFinPost(oModelF4C, oModelVrt,cAdvTipo)

    Local cFields    As Character
    Local aFields    As Array
    Local nX         As Numeric
    Local nPos       As Numeric
    Local lAddAFPA   As Logical
    Local lAddAFXX   As Logical
    Local lInflow    As Logical

    cFields  := ""
    aFields  := {}
    nX       :=  1
    lAddAFPA := .F.
    lAddAFXX := .F.
    lInflow  := IIF(oModelF4C:GetValue("F4C_OPER") == "1",.T.,.F.)
    //According to consultant requirement only fields related
    //to ledger accounts should be checked, they are: F4C_CTPRE and F4C_CTPOS
    nPos := oModelVrt:GetLine()
    While nX <= oModelVrt:Length() .AND. (!lAddAFPA .OR. !lAddAFXX)
        oModelVrt:GoLine(nX)
        If     AllTrim(oModelVrt:GetValue('B_TYPE')) == cAdvTipo .AND. !lAddAFPA
            If ASCAN(aFields, "F4C_CTPRE") == 0
                AADD(aFields ,"F4C_CTPRE")
            EndIf
            lAddAFPA := .T.
        ElseIf !(AllTrim(oModelVrt:GetValue('B_TYPE')) == cAdvTipo) .AND. !lAddAFXX
            If ASCAN(aFields,"F4C_CTPOS") == 0
                AADD(aFields,"F4C_CTPOS")
            EndIf
            lAddAFXX := .T.
        EndIf
        nX := nX + 1 
    EndDo
    oModelVrt:GoLine(nPos)
    nX      := 1
    While nX <= Len(aFields)
        If Empty(oModelF4C:GetValue(aFields[nX]))
                cFields += RetTitle(aFields[nX]) + ", "
        EndIf
        nX := nX + 1
    EndDo
    If !Empty(cFields)
        cFields := Left(cFields,Len(cFields)-2)
    EndIf

Return (cFields) /*-------------------------------RU06D07004_CheckAccntFieldsDuringFinPost*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07005_CheckFldsBeforeCleaning
Function recieves list of fields which should be cleaned, check every field,
if this field not initialized it will be deleted from this list
@param       Array         aFields         //List of array for cleaning
@return      Logical       lRet 
@example
@author      astepanov
@since       October/09/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07005_CheckFldsBeforeCleaning(aFields)
    Local nX          As Numeric
    Local nLen        As Numeric
    Local nI          As Numeric

    nLen := Len(aFields)
    nX   := nLen
    nI   := 0
    While nX > 0
        If FWFldGet(aFields[nX],,,.F.) == NIL
            ADEL(aFields,nX)
            nI := nI + 1
        EndIf
        nX := nX - 1 
    EndDo
    If nI > 0
        ASIZE(aFields, nLen - nI)
    EndIf

Return .T. /*-------------------------------------------RU06D07005_CheckFldsBeforeCleaning*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07006_CheckA6Conta
Function recieves bank code, agencia(BIK), and account namber, and returns A6_CONTA
Ledger account for bank account if exists, or returns  empty string.
@param       Character     cBnkCod     //==A6_COD ex: "003"
             Character     cBik        //==A6_AGENCIA ex: "044525000"
             Character     cAcc        //==A6_NUMCON ex: "40702810600000000795             "
@return      Character     cA6Conta    //A6_CONTA, ex: "5201                " 
@example
@author      astepanov
@since       October/09/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07006_CheckA6Conta(cBnkCod,cBik,cAcc)
    
    Local cA6Conta   As Character
    Local aArea      As Array
    Local aAreaSA6   As Array

    Default cBnkCod  := IIF(F4C->F4C_OPER == "1", F4C->F4C_BNKREC, F4C->F4C_BNKPAY)
    Default cBik     := IIF(F4C->F4C_OPER == "1", F4C->F4C_RECBIK, F4C->F4C_PAYBIK) 
    Default cAcc     := IIF(F4C->F4C_OPER == "1", F4C->F4C_RECACC, F4C->F4C_PAYACC)

    cBnkCod  := PADR(cBnkCod,GetSX3Cache("A6_COD"    ,"X3_TAMANHO")," ")
    cBik     := PADR(cBik   ,GetSX3Cache("A6_AGENCIA","X3_TAMANHO")," ")
    cAcc     := PADR(cAcc   ,GetSX3Cache("A6_NUMCON" ,"X3_TAMANHO")," ")
    aArea    := GetArea()
    aAreaSA6 := SA6->(GetArea())
    //ordem: A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
    cA6Conta := Posicione("SA6",1,xFilial("SA6")+cBnkCod+cBik+cAcc,"A6_CONTA")
    RestArea(aAreaSA6)
    RestArea(aArea)

Return cA6Conta /*-------------------------------------------------RU06D07006_CheckA6Conta*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07007_AddToCT5History
This Function used for creation History field , when we create accounting posting
It should be inserted in CT5_HIST of standard entry with parameter 2 or 1, or else.
@param       Numeric       nType       // 2 - history for postpayment
                                       // 1 - history for prepayment
                                       // 3 - history for cancel prepayment
                                       // 4 - history for cancel postpayment
                                       // 5  -history for reverse prepayment
             Character     cOper       // "2" for outflow BS, "1" for Inflow BS
@return      Character     cHistory    // " <some text> "
@example
@author      astepanov
@since       October/09/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07007_AddToCT5History(nType,cOper)
    
    Local cHistory     As Character
    Local cPrefix      As Character
    Local cNum         As Character
    Local cParcela     As Character
    Local dF49DTPAYM   As Date
    Local dEmissao     As Date

    Default nType      := 2   // Postpayment
    Default cOper      := "2" // Outflow BS
    cHistory := ""
    If     nType == 2 //Postpayment
        cHistory := STR0174 //PAYMENT BY
    ElseIf nType == 1 //Prepayment
        cHistory := STR0175 //PREPAYMENT BY
    ElseIf nType == 3 //Cancel Prepayment
        cHistory := STR0176 //CANCEL PREPAYMENT BY
    ElseIf nType == 4 //Cancel Postpayment
        cHistory := STR0177 //CANCEL PAYMENT BY
    ElseIf nType == 5 //Reverse Prepayment
        cHistory := STR0201 // Storno of adv. paym. by
    EndIf
    cHistory   += STR0178 + AllTrim(F4C->F4C_BNKORD) //PO #
    cHistory   += STR0126 //from
    dF49DTPAYM := F4C->F4C_DTPAYM 
    cHistory   += DTOC(dF49DTPAYM) + ", "
    cHistory   += STR0179 //Bill #
    If cOper == "2"
        cPrefix    := SE2->E2_PREFIXO
        cNum       := SE2->E2_NUM
        cParcela   := SE2->E2_PARCELA
        dEmissao   := SE2->E2_EMISSAO
    Else
        cPrefix    := SE1->E1_PREFIXO
        cNum       := SE1->E1_NUM
        cParcela   := SE1->E1_PARCELA
        dEmissao   := SE1->E1_EMISSAO
    EndIf
    cHistory   += AllTrim(cPrefix)  + "/" + AllTrim(cNum) + " "
    cHistory   += AllTrim(cParcela) + STR0126 //from
    cHistory   += DTOC(dEmissao)

Return cHistory /*----------------------------------------------RU06D07007_AddToCT5History*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07008_AccountingTrack

Function used for opening new window with accounting postings for selected bank statement

@param       
@return      Logical          lRet
@example     
@author      astepanov
@since       January/22/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07008_AccountingTrack()

    Local lRet       As Logical
    lRet := .T.
    
    //CTBC662 returns Nil
    CTBC662("F4C", F4C->(Recno()))
   
Return (lRet) /*------------------------------------------------RU06D07008_AccountingTrack*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07009_PostInAccounting

Should be postioned on correct line in F4C table and F4C record should be locked.
@param       Logical          lMenu  //.T. - function called from menu
@return      Logical          lRet
@private     lGeraLanc (.T. - account post online, .F. - account post offline), 
             lDigita   (.T. - display entries,     .F. - not dispaly entries)
@static      lUsaFlag
@example     
@author      astepanov
@since       January/23/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07009_PostInAccounting(lMenu)

    Local lRet       As Logical
    Local lReplace   As Logical
    Local cHlpMsg    As Character
    Local cSltMsg    As Character
    Local cQuery     As Character
    Local cAlias     As Character
    Local cPAF5MKey  As Character
    Local cWorkTab   As Character
    Local cFKX       As Character
    Local aArea      As Array
    Local aRecBx     As Array
    Local aKeyPos    As Array
    Local aRecBxOut  As Array
    Local aTit       As Array
    Local lTmpGerLn  As Logical
    Local lTmpDigit  As Logical
    Local nX         As Numeric
    Local nRecFKX    As Numeric
    Local nRecSE5    As Numeric
    Default lMenu    := .F.
    
    lRet := .T.

    If lMenu
        If lRet .AND. !(F4C->F4C_STATUS $ (S_FIN_POS + "|" + S_REPL_POST))
            cHlpMsg := STR0164 //Should be posted in Financial
            cSltMsg := STR0165 //Post in Financial the BS Line
            lRet := .F.
        EndIf
        If lRet .AND. (F4C->F4C_LA == "S")
            cHlpMsg := STR0166 //This BS line is already posted in Acc
            cSltMsg := STR0167 //It cannot be posted twice
            lRet := .F.
        EndIf
        // temporary store for private variables
        lTmpGerLn := lGeraLanc
        lTmpDigit := lDigita
        lGeraLanc := .T.
        lDigita   := .T.
    EndIf

    If lRet
        // get F5M lines by sql query
        cQuery := " SELECT *                                        "
        cQuery += " FROM " + RetSQLName("F5M") + " F5M              "
        cQuery += " WHERE F5M.F5M_FILIAL = '" + xFilial("F5M") + "' "
        cQuery += "   AND F5M.F5M_ALIAS  = 'F4C'                    "
        cQuery += "   AND F5M.F5M_IDDOC  = '" + F4C->F4C_CUUID + "' "
        cQuery += "   AND F5M.D_E_L_E_T_ = ' '                      "
        cQuery := ChangeQuery(cQuery)
        cAlias := MPSysOpenQuery(cQuery)
        aArea  := GetArea()
        DBSelectArea(cAlias)
        DBGoTop()
        aRecBx    := {}
        aRecBxOut := {}
        aTit      := {}
        cPAF5MKey := ""
        aKeyPos   := RU06XFUN44_RetSE2FldsPosInFMKey(F4C->F4C_OPER=="1")
        While !EOF()
            // check TIPO part of F5M_KEY
            If AllTrim(SubStr((cAlias)->F5M_KEY,aKeyPos[5][4],aKeyPos[5][5])) $ (MVPAGANT+"|"+MVRECANT)
                //PA (or RA) line
                cPAF5MKey := (cAlias)->F5M_KEY
            Else
                // non PA(RA) line
                aTit := StrTokArr(SubStr((cAlias)->F5M_KEY,1,aKeyPos[8][4]),"|")
                AADD(aRecBx, {0,; // nRecFKX will be filled later in aRecBxOut
                              0,; // nRecSE5 will be filled later in aRecBxOut
                              aTit[1]+aTit[2]+aTit[3]+aTit[4]+aTit[5]+aTit[6]+aTit[7],;
                              xFilial("F5M")+(cAlias)->F5M_ALIAS+;
                              (cAlias)->F5M_IDDOC+(cAlias)->F5M_KEY,;     //cF5MKeyIn
                              (cAlias)->F5M_KEY                        }) //F5M_KEY
            EndIf
            DBSkip()
        EndDo
        (cAlias)->(DBCloseArea())
        RestArea(aArea)
        aArea := GetArea()
        DBSelectArea("F4C")
        lReplace := (F4C->F4C_STATUS==S_REPL_POST)
        If F4C->F4C_OPER == "1"
            cWorkTab := "SE1"
            cPrfx    := "E1"
            cFKX     := "FK1"
        Else
            cWorkTab := "SE2"
            cPrfx    := "E2"
            cFKX     := "FK2"
        EndIf
        If Len(aRecBx) > 0
            //Check posted and uposted in accounting writeoffs
            //if it is already posted it will be excluded from lines for posting
            nX := 1
            While nX <= Len(aRecBx)
                nRecFKX := RU06D07890_RecFKX(F4C->F4C_INTNUM,aRecBx[nX][5],IIF(lReplace,F4C->F4C_DTREPL,F4C->F4C_DTTRAN),cWorkTab)
                If nRecFKX > 0
                    &(cFKX)->(DBGoTo(nRecFKX))
                    If !(AllTrim(&(cFKX+"->"+cFKX+"_LA")) == "S")
                        // this writeoff is not posted in accounting
                        SE5->(DbSetOrder(21)) //E5_FILIAL+E5_IDORIG+E5_TIPODOC
                        nRecSE5 := 0                                                                                                                                
                        If SE5->(DBSeek(xFilial("SE5")+&(cFKX+"->"+cFKX+"_ID"+cFKX)+&(cFKX+"->"+cFKX+"_TPDOC")))
						    nRecSE5 := SE5->(RecNo())
                        EndIf
                        AADD(aRecBxOut,{nRecFKX,nRecSE5,aRecBx[nX][3],aRecBx[nX][4],"S"})
                    EndIf
                EndIf
                nX := nX + 1
            EndDo
        EndIf
        BEGIN TRANSACTION
        If !Empty(aRecBxOut)
            //Post writeoffs in Accounting
            lRet := lRet .AND. RU06D07900_AccountPostPstpay(aRecBxOut,cWorkTab,lReplace)
        EndIf
        If lRet .AND. !Empty(cPAF5MKey)
            // Post PA(RA) line in accounting
            aTit := StrTokArr(cPAF5MKey,"|")
            &(cWorkTab)->(DBSetOrder(1))
            If &(cWorkTab)->(DBSeek(aTit[1]+aTit[2]+aTit[3]+aTit[4]+aTit[5]+aTit[6]+aTit[7]))
                If !(AllTrim(&(cWorkTab+"->"+cPrfx+"_LA")) == "S")
                    // SO, PA (RA) line not posted in accounting, we should post it
                    lRet := lRet .AND. RU06D07850_AccountPostAdv(aTit,cWorkTab,lReplace)
                Else
                    aTit := {}
                EndIf
            EndIf
        EndIf
        If lRet .AND. !(F4C->F4C_LA == "S")
            // Post BS header in accounting
            lRet := lRet .AND. RU06D07840_AccountPostHeader(lReplace)
        EndIf
        If !lRet
            DisarmTransaction()
        EndIf
        END TRANSACTION      
        RestArea(aArea)
    EndIf

    If lMenu  // restore private variables
        lGeraLanc := lTmpGerLn
        lDigita   := lTmpDigit
        If !lRet
            Help("",1,STR0161,,; //Post in Accounting
                 cHlpMsg,;
                 1,0,,,,,,{cSltMsg})
        Else
            If !IsBlind() .And. !RU06D07740_GetAutoBs()
                // Title: Document posting in Accounting
                // Message: Document posted successfully
                MsgInfo(STR0050 + STR0071          ,;
                        STR0065 + STR0044 + STR0046 )
            EndIf
        EndIf
    EndIf
    
Return (lRet) /*-----------------------------------------------RU06D07009_PostInAccounting*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07010_History

Used for history generation for financial post, cancel financial and reverse financial

@param       Numeric          nType // 1 - Advance financial post
                                    // 2 - non PA AP financial post
                                    // 3 - Reverse PA (RA) line
                                    // 4 - Post bank statement header
                                    // 5 - non RA AR financial post
                                    // 6 - Reverse regular AP or AR line
                                    // 7 - Cancel regular AP or AR line
             Character        cBNKORD
             Date             dDTPAYM
             Logical          lInflow // .T.  - Inflow BS, .F.(Default) - Outflow BS.
@return      Character        cRet //History text for lines created for financial posting,
                                   //cancel financial posting and reverse financial posting
@example     
@author      astepanov
@since       January/30/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07010_History(nType, cBNKORD, dDTPAYM)

    Local    cRet       As Character
    
    Default  cBNKORD    :=  F4C->F4C_BNKORD
    Default  dDTPAYM    :=  F4C->F4C_DTPAYM

    cRet := ""

    If     nType == 1
        cRet := STR0185 // Advance by PO # 
    ElseIf nType == 2
        cRet := STR0203     // "Payment "
        cRet += STR0205+" " // "p/o "
    ElseIf nType == 3 
        cRet := STR0208     // "Rev. adv. "
        cRet += STR0205+" " // "p/o "
    ElseIf nType == 4
        cRet := STR0186 //'PO # '
    ElseIf nType == 5
        cRet := STR0204     // "Receipt "
        cRet += STR0205+" " // "p/o "
    ElseIf nType == 6
        cRet := STR0207     // "Rev. "
        cRet += STR0205+" " // "p/o "
    ElseIf nType == 7
        cRet := STR0206     // "Cancel "
        cRet += STR0205+" " // "p/o "
    EndIf
    // +            __          from     __.__._____
    cRet += AllTrim(cBNKORD) + STR0126 + DTOC(dDTPAYM)
    
Return (cRet) /*-------------------------------------------------------RU06D07010_History*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07011_ShowInflowBill

Called from Menu in markbrowse - option to see details of Bill (Inflow direction)

@param      Nil
@return     Nil
@example     
@author      Alexandra Velmozhnya
@since       February/04/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07011_ShowInflowBill()
Local aArea as Array
Local cKey as Char

aArea := (cTempTbl)->(GetArea())	
cKey:=(cTempTbl)->E1_FILIAL+(cTempTbl)->E1_CLIENTE + (cTempTbl)->E1_LOJA +(cTempTbl)->E1_PREFIXO+ (cTempTbl)->E1_NUM + (cTempTbl)->E1_PARCELA + (cTempTbl)->E1_TIPO
RestArea(aArea)

dbSelectArea("SE1")
SE1->(DbSetOrder(2))    //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
If SE1->(DbSeek(cKey))
    AxVisual('SE1',SE1->(RecNo()),2,FINXFIN03("SE1"),4,SA1->A1_NOME,,fa040BAR('SE1->E1_PROJPMS == "1"'))
EndIf
DbCloseArea()

Return nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07012_ShowInflowBill

Creation and changing Reciavleble in advance line during Model commit

@param      oModel      working Data Model
@return     lRet
@example     
@author      Alexandra Velmozhnya
@since       February/10/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07012_CommitRALine(oModel)
Local lRet      As Logical
Local oModelF4C As Object
Local oModelVrt As Object
Local nNewVal   As Numeric
Local nNewVAT   As Numeric
Local nVATDif   As Numeric
Local cErrMsg   As Character

lRet      := .T.
oModelF4C := oModel:GetModel("RU06D07_MHEAD")
oModelVrt := oModel:GetModel("RU06D07_MVIRT")
cPA := PadR("RA",TamSX3("E1_TIPO")[1]," ")

// call functions for inserting line with RA type
nNewVal := oModelF4C:GetValue("F4C_ITBALA")
nVATRAT := oModelF4C:GetValue("F4C_VATRAT")
nNewVAT := RU06XFUN18_VATFormula(nNewVal,;
            {nVATRAT,100},;
            GetSX3Cache("F5M_VLVATC", "X3_DECIMAL"),;
            .T.                                     )
nVATDif := (oModelF4C:GetValue("F4C_ITVATF") + nNewVAT) - oModelF4C:GetValue("F4C_VATAMT") 
nNewVAT := Iif(nVATDif <> 0, nNewVAT - nVATDif, nNewVAT)

oTmp    := RU06XFUN47_CreateTmpTab1(.T./*lInflow*/)[1]
cErrMsg := RU06D0753_PreparePALineForInputInOutflowBSGrid(oTmp     ,;
                                                        oModelF4C,;
                                                        "X",cPA  )
If !Empty(cErrMsg)
    lRet := .F.
EndIf
If lRet
    lRet := RU06D0722_WriteFromMBr(oTmp, Nil, "X", cPA, nNewVal, nNewVAT)
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07013_ModelSettings

Loading sums in virtualk fields and delete RA line for updating

@param      oView      working View Model
@return     lRet
@example 
@private    lIsFinPost  Logical //.T.  we are in financial post process  
@author      Alexandra Velmozhnya
@since       February/11/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07013_ModelSettings(oView)
Local oModel    as Object
Local oModelF4C as Object
Local oModelVrt as Object
Local oModelF5M as Object
Local nOper     as Numeric
Local cStatus   as Character
Local lInflow   as Logical
Local lDelRALn  as Logical

nOper := oView:GetOperation()
oModel := oView:GetModel()
oModelF4C := oModel:GetModel("RU06D07_MHEAD")
oModelF5M := oModel:GetModel("RU06D07_MLNS")
oModelVrt := oModel:GetModel("RU06D07_MVIRT")

lInflow := (oModelF4C:GetValue("F4C_OPER") == '1')
cStatus := oModelF4C:GetValue("F4C_STATUS")

If lInflow .And. cStatus == '1' //Created
    lDelRALn := IIF(Type("lIsFinPost") == "L",!lIsFinPost,.T.) //don't delete line when FinPost
    If nOper == MODEL_OPERATION_UPDATE .AND. lDelRALn
        If oModelVrt:SeekLine({{"B_TYPE", PadR("RA",TamSX3("E1_TIPO")[1]," ")}},.F.,.T.)
            oModelVrt:DeleteLine()
        EndIf
    EndIf
    oView:Refresh()
    oModelVrt:GoLine(1)
EndIf

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07014_AddFIFO

Function for Finding Biils according specific rules (FIFO)

@param      Object       oTmp         // Temporary table FWTemporaryTable()
            Object       oDlg         // link to MarkBrowse Dialog
            Character    cMark        // Indicator of the marked line in oTemp (E2_OK)
@return     lRet
@example     
@author      Alexandra Velmozhnya
@since       February/11/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07014_AddFIFO(oTmp, oDlg, cMark)
Local lRet      as Logical
Local aAreaTmp  as Array
Local oModel    as Object
Local oModelF4C as Object
Local nValue    as Numeric
Local nItSumVl  as Numeric  //Check Sum of Item
Local cAliasTab as Character
Local cTab      as Character
Local cQuery    as Character
Local cSeek     as Character

lRet       := .F.
aAreaTmp   := GetArea()
cAliasTab  := oTmp:GetAlias()
oModel     := FwModelActive() //"RU06D07" should be active
oModelF4C  := oModel:GetModel("RU06D07_MHEAD")
nValue     := oModelF4C:GetValue("F4C_ITBALA")
nItSumVl   := 0

//DbSelectArea(cAliasTab)
(cAliasTab)->(DBGoTop())

While (cAliasTab)->(!EOF())
    RecLock(cAliasTab, .F.)
    (cAliasTab)->E1_OK := " "
    (cAliasTab)->(MsUnlock())
    (cAliasTab)->(DbSkip())
EndDo
// Sorting Table
cQuery := "        SELECT  * "                                                  "
cQuery += "          FROM " + oTmp:GetRealName() + "                            "
cQuery += "          ORDER BY E1_VENCREA ASC, E1_BALANCE DESC                   "
cQuery := ChangeQuery(cQuery)

cTab   := MPSysOpenQuery(cQuery)
DbSelectArea(cTab)
(cTab)->(DBGoTop())
If (cTab)->(!EOF())
    While (cTab)->(!EOF()) .And. nItSumVl < nValue
        cSeek := (cTab)->E1_FILIAL+(cTab)->E1_PREFIXO+(cTab)->E1_NUM+(cTab)->E1_PARCELA+(cTab)->E1_TIPO

        (cAliasTab)->(DBGoTop())

        While (cAliasTab)->(!EOF()) .And. ;
            cSeek != (cAliasTab)->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO)
        (cAliasTab)->(DbSkip())
        EndDo
        RecLock(cAliasTab, .F.)
        (cAliasTab)->E1_OK := cMark
        (cAliasTab)->(MsUnlock())
        // Convert value if bill is in Convencial Unit
        If (cAliasTab)->E1_CONUNI == "YES" .Or. (cAliasTab)->E1_CONUNI == "1"  // Conv Units = Yes
            nItSumVl += xMoeda((cAliasTab)->E1_BALANCE,;
                            (cAliasTab)->E1_MOEDA/*nMoedp*/,;
                            1/*nMoedd*/,;
                            oModelF4C:GetValue( "F4C_DTTRAN")/*dData*/,;
                            GetSx3Cache("F4C_VALUE","X3_DECIMAL")/*nDecimal*/)
        Else
            nItSumVl += (cAliasTab)->E1_BALANCE
        EndIf
        (cTab)->(DbSkip())
    EndDo
    lRet:=.T.
EndIf
    
(cTab)->(DBCloseArea())
RestArea(aAreaTmp)
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07015_AddExactValue

Function for Finding Biils according specific rules (EXACT Value)

@param      Object       oTmp         // Temporary table FWTemporaryTable()
            Object       oDlg         // link to MarkBrowse Dialog
            Character    cMark        // Indicator of the marked line in oTemp (E2_OK)
@return     lRet
@example     
@author      Alexandra Velmozhnya
@since       February/11/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07015_AddExactValue(oTmp, oDlg, cMark)
Local lRet      as Logical
Local aAreaTmp  as Array
Local oModel    as Object
Local oModelF4C as Object
Local nValue    as Numeric
Local nX        as Numeric
Local nCurCount as Numeric
Local cAliasTab as Character
Local cTab      as Character
Local cQuery    as Character
Local cSeek     as Character
Local cWhere    as Character

aAreaTmp   := GetArea()
cAliasTab  := oTmp:GetAlias()
oModel     := FwModelActive() //"RU06D07" should be active
oModelF4C  := oModel:GetModel("RU06D07_MHEAD")
nValue     := oModelF4C:GetValue("F4C_VALUE")
nCurCount  := Moedfin() // Quantyty of currency in the system

cWhere     := " WHERE "
If oModelF4C:GetValue("F4C_CURREN") == '01'
// Prepare where condition with value in currency for bills in convencial units
    For nX := 1 to nCurCount
        cWhere += " ( E1_BALANCE = " + cValToChar( xMoeda(nValue,;
                                        1/*nMoedp*/,;
                                        nX/*nMoedd*/,;
                                        oModelF4C:GetValue( "F4C_DTTRAN")/*dData*/,;
                                        GetSx3Cache("F4C_VALUE","X3_DECIMAL")/*nDecimal*/);
                                        )
        If nX != 1
            cWhere += "  AND E1_CONUNI = 'YES' "
        EndIf
        cWhere += " AND E1_MOEDA = " + cValToChar(nX) + " ) " + Iif( nX == nCurCount, " ", " Or ")
    Next nX
Else
    cWhere += " E1_BALANCE = " + cValToChar(nValue)
EndIf
(cAliasTab)->(DBGoTop())

While (cAliasTab)->(!EOF())
    RecLock(cAliasTab, .F.)
    (cAliasTab)->E1_OK := " "
    (cAliasTab)->(MsUnlock())
    (cAliasTab)->(DbSkip())
EndDo
// Lines with Exact Value
cQuery := "        SELECT  * "                                                  "
cQuery += "          FROM " + oTmp:GetRealName() + "                      "
cQuery += cWhere
cQuery += "          ORDER BY E1_VENCREA ASC, E1_BALANCE DESC                   "
cQuery := ChangeQuery(cQuery)

cTab   := MPSysOpenQuery(cQuery)
DbSelectArea(cTab)
(cTab)->(DBGoTop())
If (cTab)->(!EOF())
    cSeek := (cTab)->E1_FILIAL+(cTab)->E1_PREFIXO+(cTab)->E1_NUM+(cTab)->E1_PARCELA+(cTab)->E1_TIPO

    (cAliasTab)->(DBGoTop())

    While (cAliasTab)->(!EOF()) .And. ;
        cSeek != (cAliasTab)->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO)
    (cAliasTab)->(DbSkip())
    EndDo
    RecLock(cAliasTab, .F.)
    (cAliasTab)->E1_OK := cMark
    (cAliasTab)->(MsUnlock())
    lRet:=.T.
Else
    Help("",1,STR0189,,STR0190,1,0,,,,,,{STR0191})  //--"Exact Value"--"Bills is not found"--"Use another function or change value"
    lRet:=.F.
EndIf
    
(cTab)->(DBCloseArea())
RestArea(aAreaTmp)
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07016_CheckCV3Records

We use this function during posting in accounting, if user selected an option "Show account
records" (it means for us lDigita == .T.) this user can delete several lines, so CT2 and CTF
tables will be cleared, but we should delete already added records to CV3 and CTK.
Main rule for selecting strange records - is CV3_RECDES is empty, so we select CV3 records
and delete them, we also select  CTK records related to CV3 records and delete them.
So after finish this function, we should change _LA field to " " in several records from 
cTabOri and this function returns in aRet[2] array of records which should be changed.
If aRet[2] is empty, so user didn't delete records in CT2 and no records for change in
cTabOri

@param       Character        cTabOri //alias to table with original record, i.e. "FK2"
                                      //or "F4C" and so on
@return      Array            aRet    // aRet[1] - logical result, if .T. - all is ok, if
                                      //           .F. - look at aRet[3] where saved error
                                      //           message
                                      // aRet[2] - 1dim array with recnos from cTabOri
                                      //           for selected records field _LA should be
                                      //           set " ", type of elements is Numeric
                                      //           if we have no records for change this
                                      //           array will be empty
                                      // aRet[3] - error message, look at it 
                                      //           if aRet[1] == .F., if we could not block
                                      //           a record aRet[1] will be .F. and aRet[3]
                                      //           will be ""
@example     
@author      astepanov
@since       February/19/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07016_CheckCV3Records(cTabOri, aCV3RecOri)

    Local lRet       As Logical
    Local aArea      As Array
    Local aRet       As Array
    Local aDelRcs    As Array
    Local aFields    As Array
    Local cErrMsg    As Character
    Local cTmpTab    As Character
    Local cTmpTab2   As Character
    Local cQuery     As Character
    Local cAlias     As Character
    Local oTmpTab    As Object
    Local oTmpTab2   As Object
    Local nCV3RecOri As Numeric
    Local nX         As Numeric
    Local nStatus    As Numeric
    Local nDelCTK    As Numeric

    lRet := .T.

    aDelRcs := {}
    cErrMsg := ""
    cTabOri := PADR(cTabOri, GetSX3Cache("CV3_TABORI", "X3_TAMANHO"), " ")
    aArea   := GetArea()
    cTmpTab := CriaTrab(, .F.)
    oTmpTab := FWTemporaryTable():New(cTmpTab)
    aFields := {}
    AADD(aFields, {"CV3RECORI","C", GetSX3Cache("CV3_RECORI","X3_TAMANHO"),0})
    oTmpTab:SetFields(aFields)
    oTmpTab:Create()
    cTmpTab2 := CriaTrab(,.F.)
    oTmpTab2 := FWTemporaryTable():New(cTmpTab2)
    aFields  := {}
    AADD(aFields, {"CTKSEQUEN", "C", GetSX3Cache("CTK_SEQUEN","X3_TAMANHO"),0})
    AADD(aFields, {"CTKRECORI", "C", GetSX3Cache("CTK_RECORI","X3_TAMANHO"),0})
    oTmpTab2:SetFields(aFields)
    oTmpTab2:Create()
    nCV3RecOri := Len(aCV3RecOri)
    nX := 1
    While lRet .AND. nX <= nCV3RecOri
        cQuery  := " INSERT INTO " + oTmpTab:GetRealName() + " ( CV3RECORI ) "
        cQuery  += " VALUES ( '"
        cQuery  += PADR(cValToChar(aCV3RecOri[nX]),GetSX3Cache("CV3_RECORI","X3_TAMANHO")," ")
        cQuery  += "'       )  "
        nStatus := TCSqlExec(cQuery)
        If nStatus < 0
            lRet    := .F.
            cErrMsg := " TCSQLError() " + TCSQLError()
        EndIf
        nX := nX + 1
    EndDo
    nDelCTK := 0
    If lRet
        // select CV3 records, where CV3_RECDES is empty, CV3_TABORI = cTabOri and
        // CV3_RECORI is in the list of aCV3RecOri.
        // Main rule: CV3_RECDES cannot be empty, so we try to find records where
        // CV3_RECDES is empty and try to delete them. Before deletion we store info
        // about CV3_SEQUEN and CV3_RECORI it will be used for serching records in CTK
        // and deleteng them.
        // indice #3 for CV3 table: CV3_FILIAL+CV3_TABORI+CV3_RECORI+CV3_RECDES
        cQuery := " SELECT                                                          "
        cQuery += " CV3.R_E_C_N_O_  CV3RECNO,                                       "
        cQuery += " CV3.CV3_RECORI  CV3_RECORI,                                     "
        cQuery += " CV3.CV3_SEQUEN  CV3_SEQUEN                                      "
        cQuery += " FROM  " + RetSQLName("CV3") + " CV3                             "
        cQuery += " WHERE CV3.CV3_FILIAL = '"+xFilial("CV3")+"'                     "
        cQuery += "   AND CV3.CV3_TABORI = '"+cTabOri+       "'                     "
        cQuery += "   AND CV3.CV3_RECORI IN ( SELECT CV3RECORI                      "
        cQuery += "                           FROM " + oTmpTab:GetRealName() + "    "
        cQuery += "                         )                                       "
        cQuery += "   AND CV3.CV3_RECDES =                                          "
        cQuery += "'"+ REPLICATE(" ",GetSX3Cache("CV3_RECDES","X3_TAMANHO")) + "'   "
        cQuery += "   AND CV3.D_E_L_E_T_ = ' '                                      "
        cQuery := ChangeQuery(cQuery)
        cAlias := MPSysOpenQuery(cQuery)
        DBSelectArea(cAlias)
        (cAlias)->(DBGoTop())
        While lRet .AND. (cAlias)->(!Eof())
            CV3->(DBGoTo((cAlias)->CV3RECNO))
            If lRet .AND. ASCAN(aDelRcs, Val((cAlias)->CV3_RECORI)) ==  0
                AADD(aDelRcs,Val(((cAlias)->CV3_RECORI)))
                cQuery := " INSERT INTO " + oTmpTab2:GetRealName() + " "
                cQuery += " (CTKSEQUEN, CTKRECORI) "
                cQuery += " VALUES ( "
                cQuery += "'"
                cQuery += PADR((cAlias)->CV3_SEQUEN, GetSX3Cache("CTK_SEQUEN","X3_TAMANHO")," ")
                cQuery += "' , '"
                cQuery += PADR((cAlias)->CV3_RECORI, GetSX3Cache("CTK_RECORI","X3_TAMANHO")," ")
                cQuery += "'       ) "
                nStatus := TCSqlExec(cQuery)
                If nStatus < 0
                    lRet    := .F.
                    cErrMsg := " TCSQLError() " + TCSQLError()
                Else
                    nDelCTK += 1
                EndIf
            EndIf
            If lRet .AND. RecLock("CV3", .F.)
                CV3->(DBDelete())
                CV3->(MSUnlock())
            Else
                lRet := .F.
            EndIf
            (cAlias)->(DBSkip())
        EndDo
        (cAlias)->(DBCloseArea())
        RestArea(aArea)
    EndIf
    If lRet .AND. nDelCTK > 0
        // try to delete lines in CTK
        // indice #1 for CTK table: CTK_FILIAL+CTK_SEQUEN  
        cQuery := " SELECT                                              "
        cQuery += "        CTK.R_E_C_N_O_  CTKRECNO                     "
        cQuery += " FROM " + oTmpTab2:GetRealName()  + " TMP            "
        cQuery += " LEFT  JOIN " + RetSQLName("CTK") + " CTK            "
        cQuery += "         ON  CTK.CTK_FILIAL = '"+xFilial("CTK") + "' "
        cQuery += "        AND  CTK.CTK_SEQUEN = TMP.CTKSEQUEN          "
        cQuery += "        AND  CTK.CTK_TABORI = '"+cTabOri+"'          "
        cQuery += "        AND  CTK.CTK_RECORI = TMP.CTKRECORI          "
        cQuery += "        AND  CTK.D_E_L_E_T_ = ' '                    "
        cQuery := ChangeQuery(cQuery)
        cAlias := MPSysOpenQuery(cQuery)
        DBSelectArea(cAlias)
        (cAlias)->(DBGoTop())
        While lRet .AND. (cAlias)->(!Eof())
            CTK->(DBGoTo((cAlias)->CTKRECNO))
            If RecLock("CTK", .F.)
                CTK->(DBDelete())
                CTK->(MSUnlock())
            Else
                lRet := .F.
            EndIf
            (cAlias)->(DBSkip())
        EndDo
        (cAlias)->(DBCloseArea())
        RestArea(aArea)
    EndIf
    aRet    := {lRet,aDelRcs,cErrMsg}
    oTmpTab:Delete()
    oTmpTab2:Delete()
    RestArea(aArea)
    
Return (aRet) /*------------------------------------------------RU06D07016_CheckCV3Records*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07017_RetNHndlBxPrv

HeadProva for RU06D07

@param       Character        cArquivo
@return      Numeric          nHndl
@global      Character        cUsuario   // user name  
@example     
@author      astepanov
@since       February/25/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07017_RetNHndlBxPrv(cArquivo)

    Local nHndl As Numeric
    Local aArea As Array

    Default cArquivo := ""

    aArea := GetArea()
    nHndl := HeadProva(LoteCont("FIN"),"RU06D07",SubStr(cUsuario,7,6),@cArquivo)
    RestArea(aArea)
Return (nHndl)  /*------------------------------------------------RU06D07017_RetNHndlBxPrv*/


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07018_A100Include

Function used for adding values to accounting tables. it should be used after HeadProva()

@param       Numeric        nHndl     // result returned by HeadProva(), should be > 0
             Character      cArquivo  // cArchive variable that was updated by HeadProva()
             Character      cPadrao   // standard entry code, for example "530", "531" ...
             Character      cTabori   // Table name that will be used to SelectArea
                                      // It should be filled. If aRecBx is empty
                                      // and cTabori == "F4C", so cursor should
                                      // be positioned on correct record, because
                                      // cTabOri and (cTabori)->(RecNO()) will be
                                      // used for creating aTabRecOri
             Arrray         aRecBx    // {{FK2->(RecNO()),SE5->(RecNo()), Character key
                                      //   for SE2 indice #1 search, Character key
                                      //   for F5M indice #1 search}}
                                      // aRecBx[nX][1] should be > 0, because 
                                      // FK2->(Recno()) will be used for aTabRecOri
                                      // aRecBx can be Empty
             Array          aFlagBx   // This arry will be used if aRecBx is empty
                                      // it should be like:
                                      // {
                                      // {"F4C_LA", "S", "F4C", ("F4C")->(Recno()),0,0,0}
                                      // ...
                                      // } or just empty array {}
                                      // aFlagBx will be used to set a _LA field in all
                                      // provided tables to aFlagBx[nX][2] (in our case
                                      // to "S"). So if aRecBx is not empty, we don't
                                      // use aFlagBx, but fill aFlagBx iside this function.
             Character      cChaveBusc // key with the data stored in table CTL 
                                       // that will allow us to track the posting
                                       // for example: FK2->FK2_FILIAL+FK2->FK2_IDFK2 or
                                       // F4C->F4C_FILIAL+F4C->F4C_CUUID, it can be ""
                                       // if aRecBx is not empty
            Date            dDatAcc     //Data that will be consider at accounting post process, if empty will be dDataBase
@return      Array          aRet    //  if aRet[1] == .T. it is ok. if aRet[1] == .F.
                                    //  look at aRet[2] for error message details
@private     lDigita
@static      lUsaFlag
@example     
@author      astepanov
@since       February/25/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07018_A100Include(nHndl, cArquivo, cPadrao, cTabOri, aRecBx, aFlagBx, cChaveBusc, dDatAcc)

    Local aRet       As Array
    Local aTabRecOri As Array
    Local aRecOriBx  As Array
    Local aArea      As Array
    Local aChkRes    As Array
    Local aDelRec    As Array
    Local aTmpBx     As Array
    Local lRet       As Logical
    Local lLanOkBx   As Logical
    Local cErrMsg    As Character
    Local cLote      As Character
    Local cTab       As Character
    Local cFld       As Character
    Local cLAS       As Character
    Local cFKX       As Character
    Local cSEX       As Character
    Local nX         As Numeric
    Local nY         As Numeric
    Local nPos       As Numeric
    Local nRec       As Numeric
    Local nTotal     As Numeric

    Default aRecBx  := {}
    Default aFlagBx := {}
    Default dDatAcc := dDataBase//date for acc post

    lRet       := .T.
    cErrMsg    := ""
    aArea      := GetArea()
    nTotal     := 0
    cLote      := LoteCont("FIN")
    aCV3RecOri := {}
    aRecOriBx  := {}
    If F4C->F4C_OPER == "2"
        RU06D07091_PositionSA2SA6FIL()
        cFKX := "FK2"
        cSEX := "SE2"
    Else
        RU06D07053_PositionSA1SA6F4N()
        cFKX := "FK1"
        cSEX := "SE1"
    EndIf
    If Empty(aRecBx)
        aTabRecOri := {}
        AADD(aTabRecOri, cTabOri)
        AADD(aTabRecOri,(cTabOri)->(RecNo()))
        AADD(aCV3RecOri,(cTabOri)->(RecNo()))
        AADD(aRecOriBx, {(cTabOri)->(RecNo())})
        For nX := 1 To Len(aFlagBx)
            AADD(aRecOriBx[1],ACLONE(aFlagBx[nX]))    
        Next nX
        DBSelectArea(cTabOri)
        nTotal += DetProva(nHndl                       ,;
                           cPadrao                     ,;
                           "RU06D07"                   ,;
                           cLote                       ,;
                           /*@nLinha*/                 ,;
                           /*lExecuta*/                ,;
                           /*cCriterio*/               ,;
                           /*lRateio*/                 ,;
                           cChaveBusc                  ,;
                           /*aCT5*/                    ,;
                           /*lPosiciona*/              ,;
                           IIF(lUsaFlag, @aFlagBx, {}) ,;
                           aTabRecOri                  ,;
                           /*aDadosProva*/             ,;
                           .F.                         ,;
                           "CTK"                       ,;
                           "CT2"                       ,;
                           "CV3"                        )
    Else
        DBSelectArea(cTabOri)
        For nX := 1 To Len(aRecBx)
            aTmpBx     := {}
            aTabRecOri := {}
            If aRecBx[nX][1] > 0 
                &(cFKX)->(DBGoTo(aRecBx[nX][1]))
                AADD(aTmpBx,  { cFKX+"_LA", aRecBx[nX][5], cFKX, aRecBx[nX][1], 0, 0, 0})
                AADD(aFlagBx, ACLONE(aTmpBx[Len(aTmpBx)]))
            EndIf 
            If aRecBx[nX][2] > 0 
                SE5->(DBGoTo(aRecBx[nX][2]))
                AADD(aTmpBx,  { "E5_LA" , aRecBx[nX][5], "SE5", aRecBx[nX][2], 0, 0, 0})
                AADD(aFlagBx, ACLONE(aTmpBx[Len(aTmpBx)]))
            EndIf 
            If !Empty(aRecBx[nX][3])
                &(cSEX)->(DBSetOrder(1)) //fil+pref+num+parcel+tipo+forn+loja. For SE1 table it is fil+pref+num+parcel+tipo
                &(cSEX)->(DBSeek(aRecBx[nX][3])) 							
            EndIf
            If !Empty(aRecBx[nX][4])
                F5M->(DBSetOrder(1)) //F5M_FILIAL+F5M_ALIAS+F5M_IDDOC+F5M_KEY
                F5M->(DBSeek(aRecBx[nX][4])) 							
            EndIf
            // aRecBx[nX][5] == "S"
            AADD(aTabRecOri, cTabOri)
            AADD(aTabRecOri,(cTabOri)->(RecNo()))
            AADD(aCV3RecOri,(cTabOri)->(RecNo()))
            AADD(aRecOriBx, {(cTabOri)->(RecNo())})
            nPos := Len(aRecOriBx)
            For nY := 1 To Len(aTmpBx)
                AADD(aRecOriBx[nPos],ACLONE(aTmpBx[nY]))    
            Next nY
            cChaveBusc := &(cFKX+"->"+cFKX+"_FILIAL")+&(cFKX+"->"+cFKX+"_ID"+cFKX)
            nTotal += DetProva(nHndl                       ,;
                               cPadrao                     ,;
                               "RU06D07"                   ,;
                               cLote                       ,;
                               /*@nLinha*/                 ,;
                               /*lExecuta*/                ,;
                               /*cCriterio*/               ,;
                               /*lRateio*/                 ,;
                               cChaveBusc                  ,;
                               /*aCT5*/                    ,;
                               /*lPosiciona*/              ,;
                               IIF(lUsaFlag, @aFlagBx, {}) ,;
                               aTabRecOri                  ,;
                               /*aDadosProva*/             ,;
                               .F.                         ,;
                               "CTK"                       ,;
                               "CT2"                       ,;
                               "CV3"                        )
        Next nX
    EndIf
    If nTotal > 0
        lLanOkBx := .T.
        If !lUsaFlag
            lLanOkBx := MrkLinsAcc(@aFlagBx)
        EndIf
        If lLanOkBx
            RodaProva(nHndl, nTotal)
            lLanOkBx := cA100Incl(@cArquivo                 ,;
                                nHndl                       ,;
                                3 /*nOpcx*/                 ,;
                                cLote                       ,;
                                lDigita                     ,;
                                .F.                         ,;
                                /*cOnLine*/                 ,;
                                dDatAcc/*dData*/            ,;
                                /*dReproc*/                 ,;
                                IIF(lUsaFlag, @aFlagBx, {}) ,;
                                /*aDadosProva*/             ,;
                                /*aDiario{}*/               ,;
                                /*aTpSaldo*/                ,;
                                .F.                         ,;
                                "CTK"                       ,;
                                "CT2"                       ,;
                                "CTF"                        )
        EndIf
        SET KEY VK_F4 To
        SET KEY VK_F5 To
        SET KEY VK_F6 To
        SET KEY VK_F7 To
        If lLanOkBx
            aChkRes := {lLanOkBx,{},""}
            If lDigita
                //so we check and delete CV3 and CTK records
                //when user manually deleted lines during accounting posting
                //and we recive cTabori recnos where _LA field should be set
                //to " "
                aChkRes := RU06D07016_CheckCV3Records(cTabOri, aCV3RecOri)
            EndIf
            lRet    := aChkRes[1]
            aDelRec := aChkRes[2]
            cErrMsg := aChkRes[3]
            If lRet .AND. (!lUsaFlag .OR. !Empty(aDelRec))
                For nX := 1 to Len(aDelRec)
                    nPos := ASCAN(aRecOriBx, {|x| x[1] == aDelRec[nX] })
                    If nPos > 0
                        // change _LA from "S" or "N" to " "
                        For nY := 2 To Len(aRecOriBx[nPos])
                            aRecOriBx[nPos][nY][2] := " "
                        Next nY   
                    EndIf
                Next nX
                nX := 1
                nY := 2
                While lRet .AND. nX <= Len(aRecOriBx)
                    While lRet .AND. nY <= Len(aRecOriBx[nX])
                        cTab := aRecOriBx[nX][nY][3]
                        cFld := aRecOriBx[nX][nY][1]
                        cLAS := aRecOriBx[nX][nY][2]
                        nRec := aRecOriBx[nX][nY][4]
                        (cTab)->(DbGoTo(nRec))
                        If (cTab)->(RecLock(cTab,.F.))
                            Replace (cTab)->(&cFld) With cLAS
                            (cTab)->(MSUnlock())
                        Else
                            lRet :=  .F.
                        EndIf
                        nY := nY + 1
                    EndDo // next nY
                    nX += nX + 1
                EndDo // next nX
            EndIf
        Else
            lRet := .F.
        EndIf
    EndIf
    aRet :=  {lRet, cErrMsg}
    RestArea(aArea)

Return (aRet) /*----------------------------------------------------RU06D07018_A100Include*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07019_LoadVirtSums

This function will be called 4 times during initialization of the fields:
ITVATO, ITVATF, ITTOTA, ITBALA. Thees fields are virtual.

The main rule:
We goes through F5M table related to Inflow Bankstatement and make calculations:
ITVATF == SUM(F5M_VLVATC)
ITTOTA == SUM(F5M_VALCNV)
ITBALA == F4C_VALUE - ITTOTA
ITVATO == 
SUM(xMoeda(F5M_VLVATC,Val(F4C->F4C_CURREN),E1_MOEDA,F4C->F4C_DTTRAN,nDecim,F5M_EXGRAT))

for example we have next currencies and exchange rates on dDatabase:
1RUB = moeda 1 = 1       ExchangeRate(1RUB/1RUB)
1USD = moeda 2 = 68.6745 ExchangeRate(1USD/1RUB)
1EUR = moeda 3 = 77.3481 ExchangeRate(1EUR/1RUB)

If we have Val(F4C_CURREN) == E1_MOEDA

xMoeda returns to us:

xMoeda(100,1,1,,2,,35) -> 100
xMoeda(100,2,2,,2,,35) -> 100
xMoeda(100,3,3,,2,,35) -> 100

So, 2nd and next parameters have no sense, xMoeda returns 100 (F5M_VLVATC)

If we have Val(F4C_CURREN) != E1_MOEDA
we have next cases:
  case1:   E1_MOEDA != 1:
xMoeda(100,1,2,,2,,35) -> 2.86 = (100 * (1))/35 
       = (F5M_VLVATC * ExchangeRate(1RUB/1RUB))/F5M_EXGRAT;
xMoeda(100,2,3,,2,,35) -> 196.21 = ((100 * 68.6745) / 35) 
       = (F5M_VLVATC * ExchangeRate(1USD/1RUB))/F5M_EXGRAT
xMoeda(100,3,2,,2,,35) -> 220.99 = ((100 * 77.3481) / 35) 
       = (F5M_VLVATC * ExchangeRate(1EUR/1RUB))/F5M_EXGRAT
 case2: E1_MOEDA == 1
xMoeda(100,2,1,,2,,35) -> 6867.45 = 100 * 68,6745 
       = F5M_VLAVTC * ExchangeRate(1USD/1RUB)
According to thees cases we can construct CASE clause for SQL query, for this we
need only currency code (moeda) and exchange rate at selected date.

This function have static array aD07019Res.
When we call it at first time we fill aD07019Res. It can look like:
{ {"ITVATO",12000,0},
  {"ITVATF",12000,0},
  {"ITTOTA",86000,0},
  {"ITBALA",0,0}    }
After that we scan aD07019Res and try to find cField in this array.
In general case it should be founded. After that we
assign to nRet a value in aD07019Res[nX][2], so if cField == ITTOTA, nRet will be 86000.
After that we mark aD07019Res[nX][3] as 1, it means this value will be returned.

When we call this function 2nd time we don't run sql query, we get values from
static array aD07019Res, if cField == "ITVATO", so according to our example 
we return 12000 and aD07019Res[nX][3] will be marked as 1.

So when we have returned all fields ITVATO, ITVATF, ITTOTA, ITBALA,
all items in aD07019Res[?][3] will be marked like 1, so we destroy this array.
and when we call this function in next time we will start from new SQL query.

@param       Character      
@return      Numeric          nRet

@static      aD07019Res
@example 
@author      Alexandra Menyashina  
@edit        astepanov June/11/2020
@version     1.1
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07019_LoadVirtSums(cField)

    Local aArea     as Array
    Local aCurrArr  as Array
    Local aExRatFld as Array
    Local nRet      as Numeric
    Local nX        as Numeric
    Local nStat     as Numeric
    Local cQuery    as Character
    Local cAlias    as Character
    Local cMoedHdr  as Character
    Local cDecim    as Character
    Local cTaman    as Character
    Local oExRatTab as Object

    //aD07019Res : 1 - ITVATO, 2 - ITVATF, 3 - ITTOTA, 4 - ITBALA
    Static aD07019Res as Array

    aArea := GetArea()
    If aD07019Res == Nil
        aD07019Res := {}
        AADD(aD07019Res,{"ITVATO",0,0})
        AADD(aD07019Res,{"ITVATF",0,0})
        AADD(aD07019Res,{"ITTOTA",0,0})
        AADD(aD07019Res,{"ITBALA",0,0})
        //get curruncies and exchange rates and fill oExRatTab 
        //temporary table
        aCurrArr  := RU06D0742_CurrenciesArray(FWFldGet("F4C_DTTRAN"))
        oExRatTab := FWTemporaryTable():New((CriaTrab(,.F.)))
        aExRatFld := {}
        AADD(aExRatFld, {"MOEDA",;
                        GetSX3Cache("E2_MOEDA", "X3_TIPO"   ),;
                        GetSX3Cache("E2_MOEDA", "X3_TAMANHO"),;
                        GetSX3Cache("E2_MOEDA", "X3_DECIMAL")})
        AADD(aExRatFld, {"EXCHRAT",;
                        GetSX3Cache("F5M_EXGRAT","X3_TIPO"   ),;
                        GetSX3Cache("F5M_EXGRAT","X3_TAMANHO"),;
                        GetSX3Cache("F5M_EXGRAT","X3_DECIMAL")})
        oExRatTab:SetFields(aExRatFld)
        oExRatTab:Create()
        nStat := 0
        nX := 1
        While nX <= Len(aCurrArr) .AND. nStat >= 0
            cQuery := " INSERT INTO " + oExRatTab:GetRealName() +;
                      " (MOEDA, EXCHRAT) VALUES ("              +;
                      cValToChar(nX) + ", "                     +;
                      cValToChar(aCurrArr[nX][2]) + ")          "
            nStat := TCSqlExec(cQuery)
            nX := nX + 1
        EndDo
        If nStat >= 0
            //run sql query for getting ITVATO, ITVATF, ITTOTA, ITBALA
            cMoedHdr  := cValToChar(Val(FWFldGet("F4C_CURREN")))
            cDecim    := cValToChar(GetSx3Cache("F4C_VALUE","X3_DECIMAL"))
            cTaman    := cValToChar(GetSx3Cache("F4C_VALUE","X3_TAMANHO"))
            cQuery := "SELECT                                                         "
            cQuery += "       COALESCE(SUM(TMP.ITVATO), 0)           ITVATO,          "
            cQuery += "       COALESCE(SUM(TMP.ITVATF), 0)           ITVATF,          "
            cQuery += "       COALESCE(SUM(TMP.ITTOTA), 0)           ITTOTA           "
            cQuery += "FROM                                                           "
            cQuery += "( SELECT                                                       "
            cQuery += "   CASE WHEN COALESCE(SE1.E1_MOEDA,0) = 0                      "
            cQuery += "        THEN                             F5M.ITVATF            "
            cQuery += "        ELSE                                                   "
            cQuery += "         CASE WHEN SE1.E1_MOEDA = "+cMoedHdr+"                 "
            cQuery += "         THEN                            F5M.ITVATF            "
            cQuery += "         ELSE                                                  "
            cQuery += "          CASE WHEN SE1.E1_MOEDA <> 1                          "
            cQuery += "          THEN CAST(                                           "
            cQuery += "               ROUND((F5M.ITVATF * ERT.EXCHRAT)/F5M.F5M_EXGRAT,"
            cQuery += "               "+cDecim+")                                     "
            cQuery += "               AS FLOAT)             "
            cQuery += "          ELSE CAST(                                           "
            cQuery += "               ROUND(F5M.ITVATF * ERT.EXCHRAT,"+cDecim+")      "
            cQuery += "               AS FLOAT )             "
            cQuery += "          END                                                  "
            cQuery += "         END                                                   "
            cQuery += "   END                                                  ITVATO,"
            cQuery += "                                             F5M.ITVATF ITVATF,"
            cQuery += "                                             F5M.ITTOTA ITTOTA "
            cQuery += "  FROM                                                         "
            cQuery += "     (   SELECT                                                " 
            cQuery += "                F5M_KEY, F5M_EXGRAT,                           "
            cQuery += "                CAST (F5M.F5M_VLVATC                           "
            cQuery += "                AS FLOAT)     ITVATF,"
            cQuery += "                CAST (F5M.F5M_VALCNV                           "
            cQuery += "                AS FLOAT)     ITTOTA "
            cQuery += "         FROM " +  RetSQLName("F5M") + " F5M                   "
            cQuery += "         WHERE   F5M_FILIAL = '"+xFilial("F5M")+"'             "
            cQuery += "           AND   F5M_ALIAS  = 'F4C'                            "
            cQuery += "           AND   F5M_IDDOC  = '"+FwFldGet("F4C_CUUID")+"'      "
            cQuery += "           AND   D_E_L_E_T_ = ' '                              "
            cQuery += "     ) F5M                                                     "
            cQuery += "    LEFT JOIN " + RetSQLName("SE1") + "      SE1               "
            cQuery += "    ON ( "+RU06XFUN09_RetSE2F5MJoinOnString(,.T.)+"            "
            cQuery += "    AND  SE1.D_E_L_E_T_ = ' ' )                                "
            cQuery += "    LEFT JOIN " + oExRatTab:GetRealName() + " ERT              "
            cQuery += "    ON (ERT.MOEDA = SE1.E1_MOEDA)                              "
            cQuery += "           ) TMP                                               "
            cQuery := ChangeQuery(cQuery)
            cAlias := MPSysOpenQuery(cQuery)
            DBSelectArea(cAlias)
            (cAlias)->(DBGoTop())
            aD07019Res[1][2] := (cAlias)->(ITVATO)
            aD07019Res[2][2] := (cAlias)->(ITVATF)
            aD07019Res[3][2] := (cAlias)->(ITTOTA)
            aD07019Res[4][2] := FwFldGet("F4C_VALUE") - (cAlias)->(ITTOTA) //ITBALA
            (cAlias)->(DBCloseArea())
        EndIf
    EndIf
    nX := ASCAN(aD07019Res,{|x| x[1] == cField})
    If nX > 0
        nRet := aD07019Res[nX][2]
        aD07019Res[nX][3] := 1
        If ASCAN(aD07019Res,{|x| x[3] == 0}) == 0
            //so all aD07019Res[nX][3] != 0
            //it means we've returned all values to model
            //now we clear a static array
            aD07019Res := Nil
        EndIf
    Else
        nRet := 0
    EndIf
    RestArea(aArea)
  
Return (nRet)  /*--------------------------------------------------RU06D07019_LoadVirtSums*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07020_PostPreValid

Prevalidation check before posting in finance

@param       Object           oModelF4C
             Object           oModelVrt
             Character        cAdvTipo    //"PA" or "RA" TIPO for payment advance or
                                          // recivable advance
@return      Array            aRet
@example     
@author      astepanov
@since       March/10/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07020_PostPreValid(oModelF4C,oModelVrt,cAdvTipo)

    Local aRet       As Array
    Local aArea      As Array
    Local aBnkInfM   As Array
    Local lRet       As Logical
    Local cHlpMsg    As Character
    Local cTitMsg    As Character
    Local cInfMsg    As Character
    Local cBNKCODE   As Character
    Local cBANKBIK   As Character
    Local cBANKACC   As Character
    Local cAccFlds   As Character
    Local nX         As Numeric
    Local nPos       As Numeric
    Local nF4CCurr   As Numeric

    lRet    := .T.
    cHlpMsg := ""
    aArea   := GetArea()
    cTitMsg := STR0017 + STR0052 //Bank statement - information
    cInfMsg := ""
    //aBnkInfM == {"@ bank account code","@ BIC","@ bank account number",
    //             "@ bank account information is not correct ", 
    //             "Check next fields:"                                 }
    // where @ is Payer's or Reciever's       
    If      oModelF4C:GetValue("F4C_OPER") == "1" //Inflow  BS
        cBNKCODE := oModelF4C:GetValue("F4C_BNKREC")
        cBANKBIK := oModelF4C:GetValue("F4C_RECBIK")
        cBANKACC := oModelF4C:GetValue("F4C_RECACC")
        aBnkInfM := {STR0192,STR0193,STR0194,STR0195,STR0061}
    ElseIf  oModelF4C:GetValue("F4C_OPER") == "2" //Outflow BS
        cBNKCODE := oModelF4C:GetValue("F4C_BNKPAY")
        cBANKBIK := oModelF4C:GetValue("F4C_PAYBIK")
        cBANKACC := oModelF4C:GetValue("F4C_PAYACC")
        aBnkInfM := {STR0057,STR0058,STR0059,STR0060,STR0061}
    EndIf
    //check bank account data
    If Empty(cBNKCODE) .OR. Empty(cBANKBIK) .OR. Empty(cBANKACC) .OR.;
             !RU06XFUN05_VldSA6(oModelF4C:GetValue("F4C_CURREN"),;
                                cBNKCODE,cBANKBIK,cBANKACC, Nil, .T.)
        cHlpMsg += IIF(Empty(cBNKCODE), aBnkInfM[1] + CHR(10), "")
        cHlpMsg += IIF(Empty(cBANKBIK), aBnkInfM[2] + CHR(10), "")
        cHlpMsg += IIF(Empty(cBANKACC), aBnkInfM[3] + CHR(10), "")
        cHlpMsg := aBnkInfM[5] + CHR(10) + cHlpMsg
        cInfMsg := aBnkInfM[4]
        lRet := .F.                          
    EndIf
    //check ledger account for bank account
    If lRet .AND. Empty(RU06D07006_CheckA6Conta(cBNKCODE,cBANKBIK,cBANKACC))
        cHlpMsg := STR0173 //Please, fill the ledger account
        cInfMsg := aBnkInfM[4]
        lRet := .F.
    EndIf
    //check accounting fields
    cAccFlds := RU06D07004_CheckAccntFieldsDuringFinPost(oModelF4C,oModelVrt,cAdvTipo)
    If lRet .AND. !Empty(cAccFlds)
        cHlpMsg := STR0169 + cAccFlds + STR0170 + CHR(10) +;
                   STR0171 //the fields: <list> are empty, please fill.
        cInfMsg := STR0172  //Acc data is not filled
        lRet := .F.
    EndIf
    nX   := 1
    nPos := oModelVrt:GetLine()
    nF4CCurr := Val(oModelF4C:GetValue("F4C_CURREN"))
    //check conventional units
    While lRet .AND. nX <= oModelVrt:Length() 
        oModelVrt:GoLine(nX)
        If oModelVrt:GetValue("B_CURREN") == nF4CCurr .AND.;
           oModelVrt:GetValue("B_CONUNI") == "1"
            //same currency in line and in the header, so CONUNI should be 2
            cHlpMsg := STR0093 +  CHR(10) + STR0068 + cValToChar(nX)
            cInfMsg := STR0070   //Error during data saving
            lRet := .F.
        EndIf
        nX := nX + 1
    EndDo
    oModelVrt:GoLine(nPos)
    //check F4C_CLASS
    If lRet .AND. oModelF4C:GetValue("F4C_OPER") == "1" .AND. Empty(oModelF4C:GetValue("F4C_CLASS"))
        //If it is empty we must go through the Grid and check if we have a Receivable in advance
        While lRet .AND. nX <= oModelVrt:Length()
            oModelVrt:GoLine(nX)
            If oModelVrt:GetValue("B_TYPE") $ MVRECANT
                lRet := .F.
                cInfMsg := STR0231 // Bank statement that have Receivable in advance must not have the field class Empty
                cHlpMsg := STR0232 // Edit the bank statement and fill in the field Class
            EndIf 
        EndDo
        oModelVrt:GoLine(nPos)   
    EndIf
    //check ITTOTA
    If lRet .AND.  oModelF4C:GetValue("F4C_OPER") == "1" .AND.;
       oModelF4C:GetValue("F4C_VALUE") != oModelF4C:GetValue("F4C_ITTOTA")
        // Summa pozitciy ne sootvetstvuet summe platezha. ITTOTA is not eqal F4C_VALUE
        cHlpMsg := STR0196
        cInfMsg := STR0070   //Error during data saving
        lRet := .F.
    EndIf
    If lRet .AND. !IsBlind() .And. !RU06D07740_GetAutoBs() //confirm financial post?
        lRet := MsgYesNo(STR0064 + CHR(10)                         +;
                         AllTrim(oModelF4C:GetValue("F4C_INTNUM")) +;
                         " " + STR0044 + STR0045 + "?",;
                         STR0065 + STR0044 + STR0045                )
    EndIf

    If !lRet .AND. !Empty(cHlpMsg)
        If !RU06D07740_GetAutoBs()
        	HELP("",1,cTitMsg,,cInfMsg,1,0,,,,,,{cHlpMsg})
        else
            oModelF4C:oFormModel:SetErrorMessage(,,,,cTitMsg,cInfMsg,cHlpMsg,,)
        EndIf
    EndIf

    RestArea(aArea)
    aRet := {lRet, cHlpMsg}

Return (aRet) /*---------------------------------------------------RU06D07020_PostPreValid*/

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07021_GetAF5MKey

Function gets values from current line in oModelVrt and values from oModelF4C and creates
searck key(array) for searching line in oModelF5M grid using method SeekLine()

@param       Object           oModelF4C
             Object           oMOdelVrt
@return      Logical          lRet
@example     
@author      astepanov
@since       March/10/2020
@version     1.0
@project     MA3
@see         None
//-----------------------------------------------------------------------------------------------/*/
Function RU06D07021_GetAF5MKey(oModelF4C, oModelVrt)

    Local aKey       As Array
    Local lInflow    As Logical
    Local cKey       As Character
    Local cPrfx      As Character

    lInflow := IIF(oModelF4C:GetValue("F4C_OPER") == "1",.T.,.F.)
    cPrfx   := IIF(lInflow, "E1_", "E2_")
    cKey := PADR(oModelVrt:GetValue("B_FLORIG"),GetSX3Cache(cPrfx+"FILIAL" ,"X3_TAMANHO")," ") +"|"
    cKey += PADR(oModelVrt:GetValue("B_PREFIX"),GetSX3Cache(cPrfx+"PREFIXO","X3_TAMANHO")," ") +"|"
    cKey += PADR(oModelVrt:GetValue("B_NUM"   ),GetSX3Cache(cPrfx+"NUM"    ,"X3_TAMANHO")," ") +"|"
    cKey += PADR(oModelVrt:GetValue("B_PARCEL"),GetSX3Cache(cPrfx+"PARCELA","X3_TAMANHO")," ") +"|"
    cKey += PADR(oModelVrt:GetValue("B_TYPE"  ),GetSX3Cache(cPrfx+"TIPO"   ,"X3_TAMANHO")," ") +"|"
    If lInflow  //last part of key for inflow  BS
        cKey += PADR(oModelF4C:GetValue("F4C_CUST"),GetSX3Cache("E1_CLIENTE","X3_TAMANHO")," ") +"|"
        cKey += PADR(oModelF4C:GetValue("F4C_CUNI"),GetSX3Cache("E1_LOJA"   ,"X3_TAMANHO")," ")
    Else        //last part of key for outflow BS
        cKey += PADR(oModelF4C:GetValue("F4C_SUPP"),GetSX3Cache("E2_FORNECE","X3_TAMANHO")," ") +"|"
        cKey += PADR(oModelF4C:GetValue("F4C_UNIT"),GetSX3Cache("E2_LOJA"   ,"X3_TAMANHO")," ")
        If !Empty(oModelVrt:GetValue("B_CODREQ"))
            cKey += "|"
            cKey += PADR(oModelVrt:GetValue("B_CODREQ"),GetSX3Cache("F4A_CODREQ","X3_TAMANHO"), " ")
            cKey += "|"
            cKey += PADR(oModelVrt:GetValue("B_IDF4A" ),GetSX3Cache("F4A_IDF4A" ,"X3_TAMANHO"), " ")
        EndIf
    EndIf
    aKey := {{"F5M_FILIAL", xFilial("F5M")                 },;
             {"F5M_ALIAS" , "F4C"                          },;
             {"F5M_IDDOC" , oModelF4C:GetValue("F4C_CUUID")},;
             {"F5M_KEY", cKey                              } }
Return (aKey) /*-------------------------------------------------------------RU06D07021_GetAF5MKey*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07022_InflowFinPost

Function collects data and prepare them for FINA070, which provide posting in finance for
AP

@param       Character        cIDProc
             Array            aTxMoedas // array with currencies and exchange rates
             Object           oModelF4C
             Object           oModelVrt
             Character        cWorkTab // should be "SE1"
@return      Logical          lRet
@example     
@author      astepanov
@since       March/11/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07022_InflowFinPost(cIDProc,aTxMoedaBK,oModelF4C,oModelVrt,cWorkTab,nFK5VLM2TO)

    Local aRet          As Array
    Local aArea         As Array
    Local aBaixa        As Array
    Local aTxAux        As Array
    Local aF5MKey       As Array    
    Local lRet          As Logical
    Local cHlpMsg       As Character
    Local cREASON       As Character
    Local dBkpActDt     as Date
    Local aBStExpPrm    As Array    
    Local nX            as Numeric
    Local dTrnDate      As Date
    Local lRvlListFl    As Logical
    Local nTxOrig       As Numeric
    Local dUltDif       As Date 
    Local lAchouSFR     As Logical
    Local lAchouDt      As Logical
    Local nTxAt         As Numeric
    Local nOpcAviso     As Numeric
    Local lReval        As Logical

    
    Private aTxMoedas   As Array

    Default cWorkTab := "SE1"
    
    nTxOrig     :=0
    nTxAt       :=0
    dUltDif     := Ctod("")
    lAchouSFR   := .F.
    lAchouDt    := .F.    
    lRet        := .T.
    lRetPost    := .T.
    lReval      := .T.
    cHlpMsg := ""
    lRvlListFl := .F.
    nOpcAviso  :=2 
    aArea   := GetArea()
    aBStExpPrm := RU06D07048_Init_aBStExpPrm()
    aTxMoedas   := ACLONE(aTxMoedaBK)
    aTxAux      := ACLONE(aTxMoedas)
    dBkpActDt   := dDataBase
    aF5MKey := RU06D07021_GetAF5MKey(oModelF4C, oModelVrt)
    F5M->(DBSetOrder(1))
    F5M->(DBSeek(aF5MKey[1][2]+aF5MKey[2][2]+aF5MKey[3][2]+aF5MKey[4][2]))
    aBaixa  := RU06D0760_GenArrayWithElementsForSE_Index(cWorkTab)
    cREASON := RU06D07010_History(5,oModelF4C:GetValue("F4C_BNKORD"),;
                                    oModelF4C:GetValue("F4C_DTPAYM") )
    If  oModelF4C:GetValue("F4C_STATUS") == S_REPLACEMENT
        //In next release instead of dDatabase we must use here the new field date of replacement.
        dTrnDate  := dDatabase
    Else
        dTrnDate  := oModelF4C:GetValue("F4C_DTTRAN")
    Endif
    AADD(aBaixa, {"AUTMOTBX"    , "NOR"                            , Nil})
    AADD(aBaixa, {"AUTBANCO"    , oModelF4C:GetValue("F4C_BNKREC") , Nil})
    AADD(aBaixa, {"AUTAGENCIA"  , oModelF4C:GetValue("F4C_RECBIK") , Nil})
    AADD(aBaixa, {"AUTCONTA"    , oModelF4C:GetValue("F4C_RECACC") , Nil})
    AADD(aBaixa, {"AUTDTBAIXA"  , dTrnDate , Nil})
    AADD(aBaixa, {"AUTDTCREDITO", dTrnDate , Nil})
    AADD(aBaixa, {"AUTHIST"     , cREASON                          , Nil})
    AADD(aBaixa, {"AUTTXMOEDA"  , oModelVrt:GetValue("B_EXGRAT"  ) , Nil})
    AADD(aBaixa, {"AUTRECORD"   , oModelF4C:GetValue("F4C_INTNUM") , Nil})
    //Id do processo para FKA
    AADD(aBaixa, {"AUTIDPROC"   , cIDProc                          , Nil})
    AADD(aBaixa, {"AUTVALREC"   , oModelVrt:GetValue("B_VALPAY")   , Nil})
    AADD(aBaixa, {"E1_MOEDA"    , oModelVrt:GetValue("B_CURREN")   , Nil})
    If oModelVrt:GetValue("B_CONUNI") == "1" .OR. SE1->E1_MOEDA != 1
        If oModelVrt:GetValue("B_CONUNI") == "1"
            aTxMoedas[SE1->E1_MOEDA][2] := oModelVrt:GetValue("B_EXGRAT")
        EndIf
        Pergunte("FIN74A",.F.)
        MV_PAR01 := 0
        MV_PAR06 := 2
        MV_PAR07 := 1
        MV_PAR08 := 2         
        aTmpArea := GetArea()
        //nMoedaTit := 1 //FI-AP-15-8, currency for AP Exchnge rate related to Write-off, most part we will not have any value, but register at SFR  exchange rate value as 0

        dDataBase :=  dTrnDate //TODORFL backup dDataBase, FINA084 need dDataBase as transaction date
        If oModelVrt:GetValue("B_CONUNI") == "1"
            //check record in SFR table with same date
            aTmp := RU06XFUN87_CheckFR_DATADI(cWorkTab,dDataBase)
            If aTmp[1] != Nil .AND. aTmp[1] == dDataBase .AND. !(aTmp[2] == oModelVrt:GetValue("B_EXGRAT"))
                If !IsBlind() .And. !RU06D07740_GetAutoBs()
                    lRet := MsgYesNo(STR0214+cValToChar(oModelVrt:GetLine())+" "+;
                                     DTOC(dDataBase)+"."+STR0216+cValToChar(aTmp[2])+"."+STR0217+;
                                     cValToChar(oModelVrt:GetLine())+STR0218+cValToChar(oModelVrt:GetValue("B_EXGRAT"))+"."+STR0219,STR0002) // Ask about adding new exch rate calculation with same date --BS 
                Else
                    lRet := .F.
                EndIf
            EndIf
            aTmp := Nil
        EndIf
        cFK7Chave  := PADR(aF5MKey[4][2],RU06XFUN44_RetSE2FldsPosInFMKey()[8][4])
        If lRet
            aTmp := RU06XFUN88_GetRevaluationList(RU06D07049(cFK7Chave),dTrnDate,"1")
            aRevalList := aTmp[1]
            lRet       := aTmp[2]
            lRvlListFl := IIF(!Empty(aRevalList), .T., .F.)
            aBStExpPrm[5][2] := lRvlListFl
            If lRet
                If SE1->E1_CONUNI == "1".and. SE1->E1_SALDO == F5M->F5M_VALPAY .and. !lRvlListFl 
                    RU06D07051(@nTxOrig,@dUltDif,@lAchouSFR,@lAchouDt,@nTxAt) //RU06D07051_GetTxSfr 
                    If nTxAt == F5M->F5M_EXGRAT
                        aTmp := RU06XFUN86(SE1->E1_FILIAL+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA,"SE1")
                        nSaldoAt :=  ((aTmp[3] + F5M->F5M_VALCNV) - aTmp[2]) - SE1->E1_VLCRUZ
                        If nSaldoAt != 0
                            iF !IsBlind() .And. !RU06D07740_GetAutoBs()
                                nOpcAviso := Aviso( STR0221,STR0222+ Alltrim(Transform(nSaldoAt,PesqPict("SE1","E1_SALDO"))) + STR0223+ cValToChar(oModelVrt:GetLine()) + CHR(13)+CHR(10) + ; //"Balance Difference"  / "There is a difference of " /" Rubles between the available balance in rubles and the calculated value for the line -"
                                STR0224, {STR0225, STR0226,STR0056 },3 )  //"The amount can be recalculated according to the available balance in rubles or the process can continue with the current amount and it will be considered as an amount manually entered by the user, and the difference will be considered as exchange rate difference"/ "Continue with current amount" / "Recalculate" / "Cancel"
                            ENDIF
                            If nOpcAviso == 1 //Manual rate  
                                lRet := oModelVrt:LoadValue("B_RATUSR", "1")
                                lRet :=  lRet .AND. RU06D07E9_UpdateF5MLine(oModelVrt, oModelF4C, "UPDATE")                                
                                If !lRet
                                    cHlpMsg := STR0227//"Problem Flagging manual user exchange rate"
                                EndIf
                                If lRet.and. Fa074TemDC(.F.,aBStExpPrm)
                                    If !IsBlind() .And. !RU06D07740_GetAutoBs()
                                        lRet := MsgYesNo(STR0214+cValToChar(oModelVrt:GetLine())+" "+ STR0215 + " "+;
                                                        DTOC(dDataBase)+"."+STR0233+STR0213,STR0002)  //If you continue, this exchange rate will be canceled and a new one will be generated
                                    Else
                                        lRet := .t.
                                    EndIf                                    
                                    If !lRet
                                        cHlpMsg := STR0229 //"Process aborted by User"
                                    Else                                      
                                        dFRDatadi := oModelF4C:GetValue("F4C_DTTRAN")
                                        lRet := RU06D0735_CancelExRates(dFRDatadi,"SE1",.T.)
                                        if !lRet
                                            cHlpMsg := STR0234 // Problem canceling exchange rate difference 
                                        EndIf                                     
                                    EndIf
                                EndIf
                                If lRet
                                    lReval:=.T.
                                Endif    
                            Elseif nOpcAviso == 2 //Recalculate 
                                lRet :=  lRet .AND. oModelVrt:LoadValue("B_VALCNV",(oModelVrt:GetValue("B_VALCNV")-nSaldoAt))
                                lRet :=  lRet .AND. oModelVrt:LoadValue("B_BSVATC",(oModelVrt:GetValue("B_BSVATC")-nSaldoAt))
                                lRet :=  lRet .AND. RU06D07E9_UpdateF5MLine(oModelVrt, oModelF4C, "UPDATE")                                
                                lRet :=  lRet .AND. oModelF4C:LoadValue("F4C_VALUE",oModelF4C:GetValue("F4C_VALUE")-nSaldoAt)
                                If lRet
                                    lReval:=.F.
                                Else
                                    cHlpMsg := STR0228 //"Problem in the recalculation of the converted value "
                                Endif    
                            Elseif nOpcAviso == 3 //Cancel 
                                cHlpMsg := STR0229 //"Process aborted by User"
                                lRet:=.F.
                            Endif
                        Endif
                    Endif    
                Elseif SE1->E1_CONUNI != "1" .and. !lRvlListFl
                    RU06D07051(@nTxOrig,@dUltDif,@lAchouSFR,@lAchouDt,@nTxAt) //RU06D07051_GetTxSfr 
                    If nTxAt == RecMoeda(dDataBase,SE1->E1_MOEDA)
                        lReval:=.F.
                    Endif                    
                Endif
                iF lRet .and. lReval
                    Fa074GDif(.F./*lMutiplo*/,/*aCorrecoes*/,/*lMarcados*/,.T./*lExterno*/,/*nMoedaCor*/,/*nTxaAtual*/,/*nMoedaTit*/,@aBStExpPrm)
                    lRet :=!aBStExpPrm[6][2]                
                EndIf
            Else
                cHlpMsg := STR0220 //Impossible to lock the record
            EndIf
            If lRvlListFl
                For nX := 1 To Len(aRevalList)
                    SFR->(DBGoto(aRevalList[nX]))
                    SFR->(MSUnlock())
                Next nX
            EndIf
            //so when we'll create FK2 record for write-off, we change
            //FR_IDWTOFF to IDFK2 for SFR recno's stored in aBStExpPrm[3][2]
            //we set array element LWRITFRRUS to .T.
            aBStExpPrm[4][2] := .T.
        EndIf

        dDataBase := dBkpActDt //restore database original

        RestArea(aTmpArea)
        nFK5VLMOE2 := 0
        If lRet
            If oModelVrt:GetValue("B_CONUNI") == "1"
                AADD(aBaixa,{"AUTVLRPG",oModelVrt:GetValue("B_VALCNV") , Nil})
                nFK5VLMOE2 := oModelVrt:GetValue("B_VALPAY")
            Else
                AADD(aBaixa,{"AUTVLRPG",oModelVrt:GetValue("B_VALPAY") , Nil})
                If SE1->E1_SALDO == oModelVrt:GetValue("B_VALPAY") .AND. !lRvlListFl
                    aTmp := RU06XFUN86_GetLastInstallmentValue(PADR(cFK7Chave,GetSX3Cache("FK7_CHAVE","X3_TAMANHO")),cWorkTab)
                    nFK5VLMOE2 := oModelVrt:GetValue("B_VLCRUZ") - (aTmp[1] - aTmp[2])
                Else
                    nRnd       := TamSX3("FK5_VLMOE2")[2]
                    nFK5VLMOE2 := Round(xMoeda(oModelVrt:GetValue("B_VALCNV"),;
                                    SE1->E1_MOEDA,1,,nRnd,aTxMoedas[SE1->E1_MOEDA][2]),;
                                    nRnd)
                EndIf
            EndIf
        EndIf
    Else
        AADD(aBaixa,{"AUTVLRPG",oModelVrt:GetValue("B_VALPAY") , Nil})
        nFK5VLMOE2 := oModelVrt:GetValue("B_VALCNV")
    EndIf
    aBStExpPrm[2][2] := nFK5VLMOE2
    nFK5VLM2TO += IIf(nFK5VLMOE2 == Nil,0,nFK5VLMOE2)

    If lRet
        If ! IsBlind() .And. !RU06D07740_GetAutoBs() /*FINA070 calling--------------------------------------*/
            MsgRun(STR0066, STR0067,; //saving data
                    {|| lRet := RU06D07025_FI070Write(aBaixa, aTxMoedas,aBStExpPrm)})
        Else 
                        lRet := RU06D07025_FI070Write(aBaixa, aTxMoedas,aBStExpPrm) 
        EndIf /*-----------------------------------------------FINA070 calling*/
    EndIf
    aTxMoedas := aTxAux
    RestArea(aArea)
    aRet := {lRet, cHlpMsg}
    
Return (aRet) /*--------------------------------------------------RU06D07022_InflowFinPost*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07023_OutflowFinPost

Function collects data and prepare them for FINA080, which provide posting in finance for
AP

@param       Character        cIDProc
             Array            aTxMoedas // array with currencies and exchange rates
             Object           oModelF4C
             Object           oModelVrt
             Character        cWorkTab // should be "SE2"
@return      Logical          lRet
@example     
@author      astepanov
@since       March/11/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07023_OutflowFinPost(cIDProc,aTxMoedaBK,oModelF4C,oModelVrt,cWorkTab,nFK5VLM2TO)

    Local aArea      As Array
    Local aRet       As Array
    Local aBaixa     As Array
    Local aTmp       As Array
    Local aF5MKey    As Array
    Local lRet       As Logical
    Local cHlpMsg    As Character
    Local cREASON    As Character
    Local dTrnDate   as DATE
    Local dDebito    As Date
    Local dBkpActDt  as Date
    Local aBStExpPrm As Array
    Local nFK5VLMOE2 As Numeric
    Local nValInLocC As Numeric
    Private aTxMoedas   As Array//FI-AP-15-8, we need that at FINA084 as Private
        
    Default cWorkTab := "SE2"

    lRet    := .T.
    cHlpMsg := ""
    aArea   := GetArea()
    aTxMoedas  := ACLONE(aTxMoedaBK)
    If oModelVrt:GetValue("B_CONUNI") == "1"
        aTxMoedas[SE2->E2_MOEDA][2] := oModelVrt:GetValue("B_EXGRAT")
    EndIf
    dBkpActDt   := dDataBase
    cREASON := RU06D07010_History(2,oModelF4C:GetValue("F4C_BNKORD"),;
                                    oModelF4C:GetValue("F4C_DTPAYM") )
    If  oModelF4C:GetValue("F4C_STATUS") == S_REPLACEMENT
        dTrnDate  := oModelF4C:GetValue("F4C_DTREPL")
        dDebito   := oModelF4C:GetValue("F4C_DTREPL")
    Else
        dTrnDate  := oModelF4C:GetValue("F4C_DTTRAN")
        dDebito   := dTrnDate
    Endif
    aF5MKey := RU06D07021_GetAF5MKey(oModelF4C, oModelVrt)
    F5M->(DBSetOrder(1))
    F5M->(DBSeek(aF5MKey[1][2]+aF5MKey[2][2]+aF5MKey[3][2]+aF5MKey[4][2]))
    aBStExpPrm := RU06D07048_Init_aBStExpPrm(,oModelVrt:GetValue("B_VALPAY"),oModelVrt:GetValue("B_VALCNV"))
    //Form aBaixa

    aBaixa := RU06D0760_GenArrayWithElementsForSE_Index(cWorkTab)
    AADD(aBaixa, {"E2_MOEDA"    , oModelVrt:GetValue("B_CURREN")  , Nil})
    AADD(aBaixa, {"AUTMOTBX"    , "NOR"                           , Nil})
    AADD(aBaixa, {"AUTBANCO"    , oModelF4C:GetValue("F4C_BNKPAY"), Nil})
    AADD(aBaixa, {"AUTAGENCIA"  , oModelF4C:GetValue("F4C_PAYBIK"), Nil})
    AADD(aBaixa, {"AUTCONTA"    , oModelF4C:GetValue("F4C_PAYACC"), Nil})
    AADD(aBaixa, {"AUTDTBAIXA"  , dTrnDate                        , Nil})
    AADD(aBaixa, {"AUTDTDEB"    , dDebito                         , Nil})
    AADD(aBaixa, {"AUTDTCREDITO", dDebito                         , Nil})
    AADD(aBaixa, {"AUTHIST"     , cREASON                         , Nil}) 
    AADD(aBaixa, {"AUTIDPROC"   , cIDProc                         , Nil})
    AADD(aBaixa, {"AUTPAYORD"   , oModelF4C:GetValue("F4C_INTNUM"), Nil})
    //Set AUTVLRPG for aBaixa




    If oModelVrt:GetValue("B_CONUNI") == "1"
        AADD(aBaixa,{"AUTVLRPG",oModelVrt:GetValue("B_VALCNV") , Nil})
        nValInLocC := oModelVrt:GetValue("B_VALCNV")
    Else
        AADD(aBaixa,{"AUTVLRPG",oModelVrt:GetValue("B_VALPAY") , Nil})
        // nValInLocC :=oModelVrt:GetValue("B_VALPAY")
         nRnd       := TamSX3("FK5_VLMOE2")[2]
         nValInLocC := Round(xMoeda(oModelVrt:GetValue("B_VALCNV"),SE2->E2_MOEDA,1,,nRnd,aTxMoedas[SE2->E2_MOEDA][2]),nRnd)
        //  AADD(aBaixa,{"AUTVLRPG",nValInLocC , Nil})
    EndIf 
    aTmp := RU06XFUN11_GenerateExchangeRateDifferenceFA084(@aBStExpPrm,dTrnDate,aTxMoedas[SE2->E2_MOEDA][2],oModelVrt:GetValue("B_VALPAY"),nValInLocC,.F.,.F.)
    lRet := aTmp[1]
    If lRet
        nFK5VLMOE2 := aBStExpPrm[2][2]
        If aTmp[3] != NIL 
            //Check nValInLocC with aTmp[3] calculated in RU06XFUN11.
            //We should check it until correct calculation algorithm will be applied to conventional units calculation
            //for last installment for AP in conventional units
            If oModelVrt:GetValue("B_CONUNI") == "1"
                If nValInLocC != aTmp[3] .AND. !IsBlind() .And. !RU06D07740_GetAutoBs()
                     lRet := lRet .AND. MsgYesNo(STR0222 + CValToChar(aTmp[3]-nValInLocC)+STR0223+CValToChar(nValInLocC)+" "+STR0225+ "?", STR0072)
                EndIf
            EndIf
        Endif
    EndIf
    nFK5VLM2TO += IIf(nFK5VLMOE2 == Nil,0,nFK5VLMOE2)
    If lRet
        If ! IsBlind() .And. !RU06D07740_GetAutoBs() /*FINA080 calling--------------------------------------*/
            MsgRun(STR0066, STR0067,; //saving data
                    {|| lRet := RU06D0734_FI080Write(aBaixa, aTxMoedas,aBStExpPrm)})
        Else 
                        lRet := RU06D0734_FI080Write(aBaixa, aTxMoedas,aBStExpPrm) 
        EndIf /*-----------------------------------------------FINA080 calling*/
    EndIf
    aTxMoedas := aTxMoedaBK
    RestArea(aArea)
    aRet      := {lRet, cHlpMsg}    
Return (aRet) /*------------------------------------------------RU06D07023_OutflowFinPost*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07024_UpdateARecBxForAccountingPosting

Function used for updating aRecBx array, (add new item).
Items in the aRecBx in next steps will be used for posting in accounting 
non advance AP or AR

@param       Array            aRecBx
             Character        cWorkTab // "SE1" or "SE2"
             Object           oModelF4C
             Object           oModelF5M
             Character        cKey   //search key for searching record in SE1 or SE2, ind=1     
@return      Logical          lRet
@example     
@author      astepanov
@since       March/11/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07024_UpdateARecBxForAccountingPosting(aRecBx   ,cWorkTab,oModelF4C,;
                                                     oModelF5M,cKey, lReplace               )

    Local lRet       As Logical
    Local aArea      As Array
    Local cF5MKeyIn  As Character
    Local cFKXTab    As Character
    Local nRecFKX    As Numeric
    Local nRecSE5    As Numeric

    DEFAULT lReplace :=.F.

    If lReplace
        dDtTran := oModelF4C:GetValue("F4C_DTREPL")
    Else
        dDtTran := oModelF4C:GetValue("F4C_DTTRAN")
    EndIf

    lRet  := .T.
    aArea := GetArea()
    //cF5MKeyIn: F5M_FILIAL+F5M_ALIAS+F5M_IDDOC+F5M_KEY
    cF5MKeyIn := PADR(xFilial("F5M")                 ,GetSX3Cache("F5M_FILIAL","X3_TAMANHO", " "))
    cF5MKeyIn += PADR(oModelF5M:GetValue('F5M_ALIAS'),GetSX3Cache("F5M_ALIAS" ,"X3_TAMANHO", " "))
    cF5MKeyIn += PADR(oModelF5M:GetValue('F5M_IDDOC'),GetSX3Cache("F5M_IDDOC" ,"X3_TAMANHO", " "))
    cF5MKeyIn += PADR(oModelF5M:GetValue('F5M_KEY'  ),GetSX3Cache("F5M_KEY"   ,"X3_TAMANHO", " "))
    cFKXTab := IIF(cWorkTab=="SE2","FK2","FK1")
    nRecFKX := RU06D07890_RecFKX(oModelF4C:GetValue("F4C_INTNUM"),oModelF5M:GetValue('F5M_KEY'),dDtTran,cWorkTab)
    If nRecFKX > 0
        &(cFKXTab)->(DBGoTo(nRecFKX))
        SE5->(DBSetOrder(21)) //L: E5_FILIAL+E5_IDORIG+E5_TIPODOC                                                                                                                                
        If SE5->(DBSeek(xFilial("SE5")+&(cFKXTab+"->"+cFKXTab+"_ID"+cFKXTab)+&(cFKXTab+"->"+cFKXTab+"_TPDOC")))
            nRecSE5 := SE5->(RecNo())
        Else
            nRecSE5 := 0
        EndIf
        AADD(aRecBx,{nRecFKX,nRecSE5,cKey,cF5MKeyIn,"S"})
    EndIf

    RestArea(aArea)

Return (lRet) /*-------------------------------RU06D07024_UpdateARecBxForAccountingPosting*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07025_FI070Write

Call main fuction in finxbx/FINA070 for posting, should be positioned on correct SE1, 
F4C, SA1 records

Function with Equal approach to FINA087A

@param       Array            aBaixa      // xAutocab parameter for FINA070
             Array            aTxExt      // array with currencies and exchange rates
@return      Logical          lRet
@example     
@author      astepanov
@since       March/12/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07025_FI070Write(aBaixa, aTxExt, aBStExpPrm)

    Local   lRet        As Logical
    Local   lPadrao     As Logical
    Local   lConta      As Logical
    Local   aArea       As Array
    Local   dE1Baixa    As Date
    Local   dE1Movim    As Date
    Local   cE1Motiv    As Character
    Local   cIDProc     As Character
    Local   nValMov     As Numeric
    Local   nMoedaF     As Numeric
    Local   nExgRat     As Numeric
    Local   nTxMoeda    As Numeric

    Private lMsErroAuto := .F.
    Private nQtMoedas   := MoedFin()
    Private aTaxa       := Array(nQtMoedas)
    Private nValEstrang := 0 

    Default aBStExpPrm  :={}
    

    lRet  := .T.
    aArea := GetArea()
    // MsExecAuto({|x,y| FINA070(x,y)},aBaixa,3) was excluded
    // we use FA070Mov
    //Atualiza SE1
    dE1Baixa := aBaixa[ASCAN(aBaixa,{|x|, x[1] == "AUTDTBAIXA"  })][2]
    dE1Movim := aBaixa[ASCAN(aBaixa,{|x|, x[1] == "AUTDTCREDITO"})][2]
    cE1Motiv := aBaixa[ASCAN(aBaixa,{|x|, x[1] == "AUTMOTBX"    })][2]
    nValMov  := aBaixa[ASCAN(aBaixa,{|x|, x[1] == "AUTVALREC"   })][2]
    If RecLock("SE1",.F.)
        If SE1->E1_SALDO - nValMov < 0
            AutoGrLog(STR0197) // No saldo
            lMsErroAuto := .T.  
        Else
            SE1->E1_BAIXA   := If(SE1->E1_BAIXA <= dE1Baixa, dE1Baixa, SE1->E1_BAIXA)
            SE1->E1_MOTIVO  := cE1Motiv
            SE1->E1_MOVIMEN := dE1Movim
            SE1->E1_SALDO   := SE1->E1_SALDO - nValMov
            NVLLIQSLV       := SE1->E1_VALLIQ
            SE1->E1_VALLIQ  := nValMov
            SE1->E1_STATUS  := IIF(SE1->E1_SALDO == 0, "B", "A")
        EndIf
        MsUnlock()
    Else
        AutoGrLog(STR0198) // Record lock error
        lMsErroAuto := .T.
    EndIf
    // Go to SA1
    SA1->(DBSetOrder(1))
    nMoedaF := 1
    If SA1->(DBSeek(xFilial("SA1")+;
             PADR(F4C->F4C_CUST, TamSX3("A1_COD" )[1], " ") +;
             PADR(F4C->F4C_CUNI, TamSX3("A1_LOJA")[1], " ") ))
        nMoedaF := IIF(SA1->A1_MOEDALC > 0,;
                       SA1->A1_MOEDALC    ,;
                       Val(GetMV("MV_MCUSTO")))
    Else
        AutoGrLog(STR0133 + ": " + STR0199) // Error : No info about customer
        lMsErroAuto := .T.
    EndIf
    // Go to SA6
    SA6->(DBSetOrder(1))
    If !SA6->(DBSeek(xFilial("SA6")+;
              PADR(F4C->F4C_BNKREC, TamSX3("A6_COD"    )[1], " ") +;
              PADR(F4C->F4C_RECBIK, TamSX3("A6_AGENCIA")[1], " ") +;
              PADR(F4C->F4C_RECACC, TamSX3("A6_NUMCON" )[1], " ") ))
        AutoGrLog(STR0133 + ": " + STR0200) // Error : No bank account info
        lMsErroAuto := .T.
    EndIf
    If !lMsErroAuto
        nTxMoeda    := Round(SE1->E1_VLCRUZ / SE1->E1_VALOR ,;
                             TamSX3("M2_MOEDA"+AllTrim(STR(SE1->E1_MOEDA)))[2])
        //Initialize parameters for FA070Mov
        lPadrao     := .F.
        lConta      := .F.
        nExgRat     := aBaixa[ASCAN(aBaixa,{|x|, x[1] == "AUTTXMOEDA"  })][2]
        cIDProc     := aBaixa[ASCAN(aBaixa,{|x|, x[1] == "AUTIDPROC"   })][2]
        // cLoteFin we need for generation estorno when we cancel "BA"
        CLOTEFIN    := GetSX8Num("SE5", "E5_LOTE", "E5_LOTE" + cEMPANT)
        NVALREC     := nValMov
        NTOTABAT    := 0
        CBANCO      := aBaixa[ASCAN(aBaixa,{|x|, x[1] == "AUTBANCO"   })][2]
        CAGENCIA    := aBaixa[ASCAN(aBaixa,{|x|, x[1] == "AUTAGENCIA" })][2]
        CCONTA      := aBaixa[ASCAN(aBaixa,{|x|, x[1] == "AUTCONTA"   })][2]
        NDESCONT    := 0
        NJUROS      := 0
        NMULTA      := 0
        NDESCCALC   := 0
        NJUROSCALC  := 0
        NMULTACALC  := 0
        NCM         := 0
        NVALTOLER   := 0
        CMOTBX      := SE1->E1_MOTIVO
        NMOEDABCO   := SA6->A6_MOEDA
        CORDPAG     := aBaixa[ASCAN(aBaixa,{|x|, x[1] == "AUTRECORD"   })][2]
        CHIST070    := aBaixa[ASCAN(aBaixa,{|x|, x[1] == "AUTHIST"     })][2]
        NMOEDA      := aBaixa[ASCAN(aBaixa,{|x|, x[1] == "E1_MOEDA"    })][2]
        If NMOEDA > 1
            If SE1->E1_CONUNI == '1'
                NVALREC:=aBaixa[ASCAN(aBaixa,{|x|, x[1] == "AUTVLRPG"  })][2]
            Else
                nValEstrang:=xMoeda(nValMov,NMOEDA,1,dE1Baixa,2)
            Endif
        Else
            nValEstrang:= SE1->E1_VALLIQ
        Endif
        DBAIXA      := dE1Baixa
        FA070Mov(lPadrao,lConta,.F.,SE1->E1_DTACRED,{},,,nExgRat,,,,,cIDProc,/*/oModelBxC/*/,/*/ lMultNat/*/,/*/ aMotRet/*/,/*/lPccMR/*/;
                ,/*/lIrfMR/*/,/*/lInsMR/*/,/*/lIssMR/*/,/*/lImpMR/*/,aBStExpPrm)
        If !lMsErroAuto
            ConfirmSX8()
            AtuSalDup(IIF(SE1->E1_TIPO $ MV_CRNEG+"/"+MVRECANT,"+","-"),;
                      SE1->(E1_VALLIQ+E1_DESCONT-E1_JUROS-E1_MULTA)    ,;
                      SE1->E1_MOEDA                                    ,;
                      SE1->E1_TIPO                                     ,;
                      aTaxa[nMoedaF]                                   ,;
                      SE1->E1_EMISSAO                                   )
        EndIf
    EndIf
    If lMsErroAuto
        If !IsBlind() .And. !RU06D07740_GetAutoBs()
            MostraErro()
        EndIf
        lRet := .F.
    EndIf
    RestArea(aArea)

Return (lRet) /*-----------------------------------------------------RU06D07025_FI070Write*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07026_FI040IncludeRA

Function used for adding new AR to SE1 table

@param       Character        cF5MKey  //e1_filial|e1_prefixo|e1_num|e1_parcela|e1_tipo|
                                       //e1_cliente|e1_loja...
             Object           oModelF4C
             Object           oModelVrt
             Array            aTxMoedas // array with currencies and exchange rates
             Logical          lGerMov  // 
@return      Logical          lRet     // .T. is ok
@example     
@author      astepanov
@since       March/16/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07026_FI040IncludeRA(cF5MKey,oModelF4C,oModelVrt,aTxMoedas,lGerMov,nFK5VLM2TO)

    Local lRet       As Logical
    Local aTit       As Array
    Local aArea      As Array
    Local aRotAuto   As Array
    Local cHist      As Character
    Local cF5QCod    As Character
    Local nExgRat    As Numeric
    Local dDtTran    As Date
    
    Private lMSErroAuto := .F.
    Default lGerMov     := .F.

    lRet     := .T.
    aArea    := GetArea()
    aTit     := StrTokArr(cF5MKey,"|")
    nExgRat  := aTxMoedas[oModelVrt:GetValue("B_CURREN")][2]
    cHist    := RU06D07010_History(1,oModelF4C:GetValue("F4C_BNKORD"),;
                                     oModelF4C:GetValue("F4C_DTPAYM") )
    cF5QCod  := ""
    cF5QCod  := Posicione("F5Q",1,xFilial("F5Q")+oModelF4C:GetValue("F4C_UIDF5Q"),;
                          "F5Q_CODE"                                              )
    If oModelF4C:GetValue("F4C_STATUS") $ (S_REPLACEMENT)
        dDtTran := oModelF4C:GetValue("F4C_DTREPL")
    Else
        dDtTran:=  oModelF4C:GetValue("F4C_DTTRAN") 
    EndIf
    // next order: E2_ALQIMP1 -> E2_VALOR -> E2_VALIMP1 -> E2_BASIMP1                   
    aRotAuto := {{ "E1_FILIAL"   , aTit[1]                         , NIL },;
                 { "E1_PREFIXO"  , aTit[2]                         , NIL },;
                 { "E1_NUM"      , aTit[3]                         , NIL },;
                 { "E1_PARCELA"  , aTit[4]                         , NIL },;
                 { "E1_TIPO"     , aTit[5]                         , NIL },;
                 { "E1_CLIENTE"  , aTit[6]                         , NIL },;
                 { "E1_LOJA"     , aTit[7]                         , NIL },;
                 { "E1_NATUREZ"  , oModelF4C:GetValue("F4C_CLASS" ), NIL },;
                 { "E1_EMISSAO"  , dDtTran                         , NIL },;
                 { "E1_VENCTO"   , dDtTran                         , NIL },;
                 { "E1_VENCREA"  , dDtTran                         , NIL },;
                 { "CBCOAUTO"    , oModelF4C:GetValue("F4C_BNKREC"), NIL },;
                 { "CAGEAUTO"    , oModelF4C:GetValue("F4C_RECBIK"), NIL },;
                 { "CCTAAUTO"    , oModelF4C:GetValue("F4C_RECACC"), NIL },;
                 { "E1_MOEDA"    , oModelVrt:GetValue("B_CURREN")  , NIL },;
                 { "E1_TXMOEDA"  , nExgRat                         , NIL },;
                 { "E1_ALQIMP1"  , oModelVrt:GetValue("B_ALIMP1")  , NIL },;
                 { "E1_VALOR"    , oModelVrt:GetValue("B_VALPAY")  , NIL },;
                 { "E1_VALIMP1"  , oModelVrt:GetValue("B_VLIMP1")  , NIL },;
                 { "E1_BASIMP1"  , oModelVrt:GetValue("B_BSIMP1")  , NIL },;
                 { "E1_CTACLI"   , oModelF4C:GetValue("F4C_CTPRE") , NIL },;
                 { "E1_CCUSTO"   , oModelF4C:GetValue("F4C_CCPRE") , NIL },;
                 { "E1_ITEMCTA"  , oModelF4C:GetValue("F4C_ITPRE") , NIL },;
                 { "E1_CLVL"     , oModelF4C:GetValue("F4C_CLPRE") , NIL },;
                 { "E1_F5QCODE"  , cF5QCod                         , NIL },;
                 { "E1_F5QUID"   , oModelF4C:GetValue("F4C_UIDF5Q"), NIL },;
                 { "E1_ORIGEM"   , FunName()                       , NIL },;
                 { "E1_HIST"     , cHist                           , NIL },;
                 { "E1_VLCRUZ"   , oModelVrt:GetValue("B_VLCRUZ")  , NIL },;
                 { "GERFINBS"    , lGerMov                         , NIL } }
    CTB105MVC(.T.)
    MsExecAuto( {|x,y| FINA040(x,y)} , aRotAuto, 3) // 3 - Incl, 4 - Edit, 5 - Delete
    If lMsErroAuto
        If !IsBlind() .And. !RU06D07740_GetAutoBs()
            MostraErro()
        EndIf
        lRet := .F.
    EndIf
    RestArea(aArea)
    
Return (lRet) /*-------------------------------------------------RU06D07026_FI040IncludeRA*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07027_FI040DELRA

Function used for deletion advanced accounts recivable. For correct work grid model
oModelF5M should be positioned on correct line

@param       Object       oModel
             Object       oModelF4C
             Object       oMOdelF5M
             Character    cWorkTab   // should be "SE1"
             Logical      lUpdBnkSld // update bank saldo in SE8 table
             Date         dDtTran    //Moviment date to be considered to balance moviment
@return      Array        aRet
@example     
@author      astepanov
@since       March/16/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07027_FI040DELRA(oModel, oModelF4C, oModelF5M, cWorkTab, lUpdBnkSld,dDtTran)
    Local lRet       As Logical
    Local lPadrao5BW As Logical
    Local aRet       As Array
    Local aArea      As Array
    Local aBaixa     As Array
    Local aChkRes    As Array
    Local cKey       As Character
    Local cHlpMsg    As Character
    Local cHistory   As Character
    Local cPadrao5BW As Character
    Local cArquivo   As Character
    Local cChaveBusc As Character
    Local dActDt     As Date
    Local nHdlPrv    As Numeric

    Default cWorkTab    := "SE1"
    Default lUpdBnkSld  := .F.
    Default dDtTran     := dDataBase
    Private lMsErroAuto := .F.

    dActDt      := dDataBase      //Save actual system date to restore after delete RA - RA should be canceled at same date at transaction date 
    dDataBase   := dDtTran        //set actual date as transaction date
    lRet        := .T.
    cHlpMsg     := ""
    aArea       := GetArea()
    cKey        := RU06D0749_GencF5MKey(oModelF5M:GetValue("F5M_KEY"), cWorkTab)
    cHistory    := RU06D07010_History(7,oModelF4C:GetValue("F4C_BNKORD"),oModelF4C:GetValue("F4C_DTPAYM"))
    cPadrao5BW  := LP_5BW_AR_RACNC
    lPadrao5BW  := VerPadrao(cPadrao5BW)
    DBSelectArea(cWorkTab)
    DBSetOrder(1)
    If DBSeek(cKey)
        //Unpost in accounting if we need it
        If (cWorkTab)->E1_LA == "S" .AND. lPadrao5BW
            cArquivo := ""
            nHdlPrv  := RU06D07017_RetNHndlBxPrv(@cArquivo) 
            If nHdlPrv > 0
                cChaveBusc := F4C->F4C_FILIAL+F4C->F4C_CUUID
                aChkRes := RU06D07018_A100Include(nHdlPrv,@cArquivo,cPadrao5BW,"F4C",{},{},cChaveBusc)
                lRet    := aChkRes[1]
                cHlpMsg := aChkRes[2]
            Else //nHdlPrv <= 0
                lRet    := .F.
                cHlpMsg := STR0162 //A100NOPROV
            EndIf
        EndIf
        If lRet
            aBaixa := RU06D0760_GenArrayWithElementsForSE_Index(cWorkTab)
            AADD(aBaixa, {"AUTHIST", cHistory, Nil})
            AADD(aBaixa, {"E1_ORIGEM", FunName(),Nil}) 
            MsExecAuto({ |x,y| FINA040(x,y)}, aBaixa, 5) //5-Delete
        EndIf
    EndIf
    If lMSErroAuto
        If !IsBlind() .And. !RU06D07740_GetAutoBs()
            MostraErro()
        EndIf
        lRet    := .F.
        cHlpMsg := STR0070 //error during data saving
    EndIf
    If lRet .AND. lUpdBnkSld
        AtuSalBco(oModelF4C:GetValue("F4C_BNKREC"),;
                  oModelF4C:GetValue("F4C_RECBIK"),;
                  oModelF4C:GetValue("F4C_RECACC"),;
                  oModelF4C:GetValue("F4C_DTTRAN"),;
                  oModelF5M:GetValue("F5M_VALCNV"),;
                  "-"                               )
    EndIf
    dDataBase := dActDt //Restore the correct date
    aRet := {lRet, cHlpMsg}
    RestArea(aArea)
    
Return (aRet) /*-----------------------------------------------------RU06D07027_FI040DELRA*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07028_BSAdvanceLineFinPost

Function used for posting advanced lines for accounts payables or accounts recivables

@param       Character        cAdvTipo  // "PA" or "RA"
             Character        cWorkTab // table where advance line will be created "SE1" or
                                       // "SE2"
             Object           oModelF4C
             Object           oModelVrt
             Array            aTxMoedas // array with currencies and exchange rates
             Logical          lGerMov   // Variable responsable do contro if we create
                                           or not bank movement
@return      Logical          lRet      // .T. - is ok
@example     
@author      astepanov
@since       March/16/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07028_BSAdvanceLineFinPost(cAdvTipo ,cWorkTab,oModelF4C,oModelF5M,;
                                         oModelVrt,aTxMoedas,lGerMov,nFK5VLM2TO          )

    Local lRet       As Logical
    Local cF5MKey    As Character
    Local bFun       As Block
    Local aArea      As Array
    
    Default lGerMov  := .F.

    lRet  := .T.
    aArea := GetArea()
    cF5MKey := RU06D0739_GetNewF5MKey(oModelF4C,cAdvTipo)
    lRet := lRet .AND. oModelF5M:SetValue("F5M_KEY", cF5MKey)
    If     cWorkTab == "SE1"
        Private cItnUuidBs := F4C->F4C_CUUID
        bFun := {|v,w,x,y,t,o| RU06D07026_FI040IncludeRA(v,w,x,y,t,@o)}
    ElseIf cWorkTab == "SE2"
        bFun := {|v,w,x,y,t,o| RU06D0737_FI050IncludePA(v,w,x,y,t,@o)  }  
    EndIf
    If !IsBlind() .And. !RU06D07740_GetAutoBs()
        MsgRun(STR0066, STR0067,; //saving data
        {|| lRet := lRet .AND. Eval(bFun,cF5MKey,oModelF4C,oModelVrt,aTxMoedas,lGerMov,@nFK5VLM2TO)})
    Else
            lRet := lRet .AND. Eval(bFun,cF5MKey,oModelF4C,oModelVrt,aTxMoedas,lGerMov,@nFK5VLM2TO)
    EndIf
    RestArea(aArea)
    
Return (lRet) /*-------------------------------------------RU06D07028_BSAdvanceLineFinPost*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07029_FinUnPost

This function will be called when we cancel financial posting for regular PA or RA

@param       Object     oModelF4C
             Object     oModelF5M
             Character  cWorkTab
             Logical    lFirst
             Logical    lRev    // if .T. we are in reverse process
@return      Array      aRet    {lRet, cHlpMsg} // if lRet == .T. - it is Ok, cHlpMsg
                                                   can be used for additional info
@example     
@author      astepanov
@since       April/17/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07029_FinUnPost(oModelF4C, oModelF5M, cWorkTab, lFirst, lRev)

    Local aRet       As Array
    Local aArea      As Array
    Local aBaixa     As Array
    Local aSFRRecnos As Array
    Local cINTNUM    As Character
    Local cHlpMsg    As Character
    Local cHistory   As Character
    Local cStatus    As Character
    Local cFR_CHAVOR As Character
    Local cCarteira  As Character
    Local lRet       As Logical
    Local bFunUnPost As Block
    Local dActDate   AS Date
    Local dFRDatadi  As Date
    Local nX         As Numeric
    Local aFK2Tot    As Array
    Local nWrOfOnDat As Numeric
    Local lReval     as Logical


    dActDate    := dDataBase
    aArea       :=  GetArea()
    lRet        := .T.
    cHlpMsg     := ""
    cCarteira   := ""
    aFK2Tot     :={}
    nWrOfOnDat  :=0
    aBaixa      := RU06D0760_GenArrayWithElementsForSE_Index(cWorkTab)
    cINTNUM     := oModelF4C:GetValue("F4C_INTNUM")
    cStatus     := oModelF4C:GetValue("F4C_STATUS")
    dFRDatadi   := IIF(cStatus==S_REPL_POST,oModelF4C:GetValue("F4C_DTREPL"),oModelF4C:GetValue("F4C_DTTRAN"))
    lReval      :=.F.
    If lRev
        cHistory := RU06D07010_History(6,oModelF4C:GetValue("F4C_BNKORD"),oModelF4C:GetValue("F4C_DTPAYM"))
    Else
        cHistory := RU06D07010_History(7,oModelF4C:GetValue("F4C_BNKORD"),oModelF4C:GetValue("F4C_DTPAYM"))
    EndIf
    AADD(aBaixa, {"AUTHIST" , cHistory , Nil})
    If     cWorkTab == "SE2"
        // additional data to aBaixa
        AADD(aBaixa, {"AUTPAYORD" , cINTNUM , Nil})
        // Use original date at Cancel(Cancel must be using the same date)
        If !lRev
            //only for cancel operation, for reverse dont add this line
            AADD(aBaixa, {"AUTORIGDT" , .T.     , Nil})
        Else
            dDataBase := oModelF4C:GetValue("F4C_DTREVE")  // for reverse operation we use Reversal date
        EndIf
        // Cancel exchange rates
        If SE2->E2_CONUNI == "1" .OR. SE2->E2_MOEDA != 1
            lReval:=.T.
            cCarteira:="2"
            cFR_CHAVOR := PADR(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA,GetSX3Cache("FR_CHAVOR","X3_TAMANHO")," ")            
            aFK2Tot  := RU06XFUN96_CheckWriteOffsOnSameDate("SE2",PADR(SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA,GetSX3Cache("FK7_CHAVE","X3_TAMANHO")," "),dFRDatadi)
            nWrOfOnDat := IIF(SE2->E2_CONUNI == "1",aFK2Tot[2],aFK2Tot[1])
            If nWrOfOnDat == oModelF5M:GetValue("F5M_VALPAY") //cancel only when we have only one write-off on dFRDatadi date
                lRet := RU06D0735_CancelExRates(dFRDatadi)
            Endif
        EndIf
        bFunUnPost := {|x,y| RU06D0736_FI080CancelWrite(x /*aBaixa*/ , y /*lMov*/)}        
    ElseIf cWorkTab == "SE1"
        // Cancel exchange rates
        If SE1->E1_CONUNI == "1" .OR. SE1->E1_MOEDA != 1
            lReval:=.T.
            cCarteira:="1"
            cFR_CHAVOR  :=PADR(SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO,GetSX3Cache("FR_CHAVOR","X3_TAMANHO")," ")
            //for replacement BS F4C_STATUS == S_REPL_POST  should be
            //used for dFRDatadi F4C_DTREPL which is not developed yet.
            If RU06D07050(dFRDatadi, alltrim(oModelF5M:GetValue('F5M_KEY')))  == 1
                lRet := RU06D0735_CancelExRates(dFRDatadi,"SE1")
            Endif
        EndIf
        AADD(aBaixa, {"AUTRECORD" , cINTNUM , Nil})
        If !lRev
            dDataBase := oModelF4C:GetValue("F4C_DTTRAN")  // cancel must use transaction date
            AADD(aBaixa, {"AUTORIGDT" , .T.     , Nil})
        Else
            dDataBase := oModelF4C:GetValue("F4C_DTREVE")  // for reverse operation we use Reversal date
        EndIf
        bFunUnPost := {|x,y| RU06D07031_FI070CancelWrite(x /*aBaixa*/, lFirst /*lMov*/, .F.)}
    EndIf
    lRet := lRet .AND. Eval(bFunUnPost,aBaixa,lFirst)
    //when we cancel write-off we cahnge EX_SALDO, and if
    //we have exchange rate revaluations in future for this AP we should mark them for rebuilding
    If lRet .AND. lReval        
        aSFRRecnos := RU06XFUN88_GetRevaluationList(cFR_CHAVOR,dFRDatadi,cCarteira)
        lRet := aSFRRecnos[2]
        For nX := 1 To Len(aSFRRecnos[1])
            SFR->(DBGoto(aSFRRecnos[1][nX]))
            SFR->(MSUnlock())
        Next nX
    EndIf
    RestArea(aArea)
    aRet := {lRet, cHlpMsg}
    dDataBase := dActDate
Return (aRet)  /*-----------------------------------------------------RU06D07029_FinUnPost*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07030_ClearPrefixAndNumInF5MKey

This function clears prefix and num in F5M_KEY

@param      Character    cF5MKey filial|prefix|num|parcela|tipo|fornece|loja...
@return     Character    cRet    filial|      |   |parcela|tipo|fornece|loja...
@example     
@author      astepanov
@since       April/17/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07030_ClearPrefixAndNumInF5MKey(cF5MKey)

    Local   aF5MKey As Array
    Local   cRet    As Character

    Default cF5MKey := F5M->F5M_KEY

    aF5MKey := StrTokArr(cF5MKey, "|")
    aF5MKey[2] := PADR(" ",Len(aF5MKey[2])," ") //prefix
    aF5MKey[3] := PADR(" ",Len(aF5MKey[3])," ") //num
    cRet := aF5MKey[1]+"|"+aF5MKey[2]+"|"+aF5MKey[3]+"|"+;
            aF5MKey[4]+"|"+aF5MKey[5]+"|"+aF5MKey[6]+"|"+aF5MKey[7]
    cRet := IIF(Len(aF5MKey) > 7,;
                cRet+"|"+aF5MKey[8]+"|"+aF5MKey[9],cRet)
Return(cRet) /*---------------------------------------RU06D07030_ClearPrefixAndNumInF5MKey*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07031_FI070CancelWrite

Function calls FINA070 for cancelling BS postings in Finance

@param       Array    aBaixa
             Logical  lMov
             Logical  lRevRA  // .T. if we create reverse for RA, defaul .F.
@return      Logiacl  lRet  // If .T. - it is ok
@example     
@author      astepanov
@since       April/20/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07031_FI070CancelWrite(aBaixa, lMov, lRevRA)
    
    Local   lRet        As Logical
    Local   aArea       As Array
    Local   nOpc        As Numeric
    Default lRev        := .F.
    Default lMov        := .T.
    Private lMsErroAuto := .F.
    lRet  := .T.
    aArea := GetArea()
    nOpc  := IIF(lRevRA,3,5) 
    AcessaPerg("FIN070", .F.)

    MsExecAuto({|w,x,y,z  | FINA070(w,; //xAutoCab  [1]
                                x,; //nOpc        [2]
                                 ,; //lNoMbrowse  [3]
                                 ,; //nOpbaixa    [4]
                                 ,; //cFiltro     [5]
                                 ,; //aParam      [6]
                                 ,; //lRatAuto    [7]
                                 ,; //aVAAut      [8]
                                 ,; //aRatEvEz    [9]
                                 ,; //lCtbBx      [10]                                 
                                y,; //lMov        [11]
                                 ,; //lPix       [12]                                 
                                z,; //lRevRA      [13]
                                )}, aBaixa,nOpc,lMov,lRevRA )


    If lMsErroAuto
        If !IsBlind() .And. !RU06D07740_GetAutoBs()
            MostraErro()
        EndIf
        lRet := .F.
    EndIf
    RestArea(aArea)

Return (lRet) /*-----------------------------------------------RU06D07031_FI070CancelWrite*/







/*/{Protheus.doc} RU06D07032_DtFk5
Return date of transaction

@type function
@author eduardo.flima
@since 12/05/2020
@version 1.0
@project MA3 - Russia

@param    cFk5IdBs  Character       F4C_CUUID
@return   dDate     Date            FK5_DATA
/*/
Static Function RU06D07032_DtFk5(cFk5IdBs)
	Local aArea   as Array
	Local dDate   as Date	
    Local nRecno   as Numeric
    Local nFK5Rec  as Numeric

    nFK5Rec  := FK5->(RecNo())

    aArea  := GetArea()	
    nRecno:= RU06D07870_RecFK5(cFk5IdBs)
    FK5->(DBGoTo(nRecno))
    dDate = FK5->FK5_DATA
	RestArea(aArea)	
    FK5->(DBGoTo(nFK5Rec))


Return dDate

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07033_ReverseRecivableInAdvance

Static Function Used to Reverser recivable in advance that consist in to 

@param       Object           oModel
             Object           oModelF4C
             Object           oModelF5M
@return      Array            aRet aRet[1] == Logical   : .T.  - ok, recivables reversed
                                   aRet[2] == Character : "" - if aRet[1] == .T.
                                                          "<ErrorMesg>" - aRet[1] == .F. 
@example     
@author      astepanov
@since       March/19/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07033_ReverseRecivableInAdvance(oModel,oModelF4C,oModelF5M)
    Local aArea      As Array
    Local aRet       As Array
    Local aBaixa     As Array
    Local aFlagBx    As Array
    Local cHistBaixa As Character
    Local cF5MKey    As Character
    Local cErrMsg    As Character
    Local cINTNUM    As Character
    Local cBNKCODE   As Character
    Local cBANKBIK   As Character
    Local cBANKACC   As Character
    Local cPadrao520 As Character
    Local cChaveBusc As Character
    Local cArqBx     As Character
    Local nF5MVALPAY As Numeric
    Local nHdlBxPrv  As Numeric
    Local nRecFK1    As Numeric
    Local nRecSE5    As Numeric
    Local lRet       As Logical
    Local lMov       As Logical
    Local dPosDate   As Date
    Local dTmpDate   As Date
     

    If Type("cItnUuidBs") == "U"
        Private cItnUuidBs := oModelF4C:GetValue("F4C_CUUID")
    Else
        cItnUuidBs := oModelF4C:GetValue("F4C_CUUID")
	EndIf
    dPosDate   := oModelF4C:GetValue("F4C_DTREVE")
    dTmpDate   := dDataBase
    dDataBase  := dPosDate
    cPadrao520 := LP_520_AR_WROFF
    lMov:= oModelF4C:GetValue("F4C_ADVANC") == "1" // If is prepayment must generate reversal moviment otherwise no

    lRet       := .T.
    cErrMsg    := ""
    aArea      := GetArea()
    cF5MKey    := RU06D0749_GencF5MKey(oModelF5M:GetValue('F5M_KEY'), "SE1")
    cHistBaixa := RU06D07010_History(3,oModelF4C:GetValue("F4C_BNKORD"),;
                                       oModelF4C:GetValue("F4C_DTPAYM") )
    cHistBaixa := PADR(cHistBaixa,GetSX3Cache("FK1_HISTOR","X3_TAMANHO")," ")
    cINTNUM    := oModelF4C:GetValue("F4C_INTNUM")
    nF5MVALPAY := oModelF5M:GetValue("F5M_VALPAY")
    cBNKCODE   := oModelF4C:GetValue("F4C_BNKREC")
    cBANKBIK   := oModelF4C:GetValue("F4C_RECBIK")
    cBANKACC   := oModelF4C:GetValue("F4C_RECACC")
    DBSelectArea("SE1")
    DBSetOrder(1)
    If DBSeek(cF5MKey) .AND. SE1->E1_SALDO > 0
        aBaixa :=  {}
        AADD(aBaixa, {"E1_FILIAL"   , SE1->E1_FILIAL  , Nil})
        AADD(aBaixa, {"E1_PREFIXO"  , SE1->E1_PREFIXO , Nil})
        AADD(aBaixa, {"E1_NUM"      , SE1->E1_NUM     , Nil})
        AADD(aBaixa, {"E1_PARCELA"  , SE1->E1_PARCELA , Nil})
        AADD(aBaixa, {"E1_TIPO"     , SE1->E1_TIPO    , Nil})
        AADD(aBaixa, {"E1_CLIENTE"  , SE1->E1_CLIENTE , Nil})
        AADD(aBaixa, {"E1_LOJA"     , SE1->E1_LOJA    , Nil})
        AADD(aBaixa, {"AUTDTBAIXA"  , dPosDate        , Nil}) 
        AADD(aBaixa, {"AUTDTCREDITO", dPosDate        , Nil})
        AADD(aBaixa, {"AUTMOTBX"    , "DAC"           , Nil})
        AADD(aBaixa, {"AUTHIST"     , cHistBaixa      , Nil})
        AADD(aBaixa, {"AUTRECORD"   , cINTNUM         , Nil})
        AADD(aBaixa, {"AUTVLRPG"    , nF5MVALPAY      , Nil})
        If !IsBlind() .And. !RU06D07740_GetAutoBs()
            MsgRun(STR0066, STR0067,; //saving
            {|| lRet := RU06D07031_FI070CancelWrite(aBaixa,lMov,.T.)})
        Else
                lRet := RU06D07031_FI070CancelWrite(aBaixa,lMov,.T.)
        EndIf
        dDataBase := dTmpDate
        //Initialize Account Post file
        nHdlBxPrv  := 0
        cArqBx     := ""
        If lRet .AND. VerPadrao(cPadrao520)
            nHdlBxPrv := RU06D07017_RetNHndlBxPrv(@cArqBx)
            If nHdlBxPrv <= 0
                lRet    := .F.
                cErrMsg := STR0162 //A100NOPROV
            EndIf
        EndIf 
        If lRet .AND. nHdlBxPrv > 0
            cChaveBusc := ""
            aFlagBx    := {}
            nRecFK1 := RU06D07890_RecFKX(oModelF4C:GetValue("F4C_INTNUM"),oModelF5M:GetValue('F5M_KEY'),dPosDate,"SE1")
            If nRecFK1 > 0
                FK1->(DBGoTo(nRecFK1))
                AADD(aFlagBx,{ "FK1_LA", "S", "FK1", nRecFK1, 0, 0, 0})
                SE5->(DBSetOrder(21))  //E5_FILIAL+E5_IDORIG+E5_TIPODOC
                If SE5->(DBSeek(xFilial("SE5")+FK1->FK1_IDFK1+FK1->FK1_TPDOC))
                    nRecSE5 := SE5->(RecNo())
                    AADD(aFlagBx,{ "E5_LA" , "S", "SE5", nRecSE5, 0, 0, 0})
                EndIf
                cChaveBusc := FK1->FK1_FILIAL+FK1->FK1_IDFK1
                aChkRes := RU06D07018_A100Include(nHdlBxPrv, @cArqBx, cPadrao520,"F4C",{},aFlagBx,cChaveBusc,dPosDate)
                lRet    := aChkRes[1]
                cErrMsg := aChkRes[2]
            Else
                lRet    := .F.
            EndIf
        EndIf
    Else
        lRet    := .F.
        cErrMsg += STR0069 + " " // no saldo
    EndIf
    //Bank saldo actualization
    AtuSalBco(cBNKCODE,;
              cBANKBIK,;
              cBANKACC,;
              dPosDate,;//Reversal should use actual date to register bank moviments -- oModelF4C:GetValue("F4C_DTTRAN")
              oModelF5M:GetValue("F5M_VALCNV"),;
              "-"                              )
    //Add accounting posting routines if you need
    dDataBase := dTmpDate
    RestArea(aArea)
    aRet := {lRet, cErrMsg}

Return (aRet) /*--------------------------------------RU06D07033_ReverseRecivableInAdvance*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07034_GetCanceledSe5

Static Function Used to delete SE5 setles as canceled related to bank transactions 

@param       Character        cIdMov: Id from bank transaction

@return      Array            aRes[1]: If everything occours OK
                              aRes[2]: Message when something Wrong occours
@example     
@author      Eduardo.FLima
@since       13/10.2020 
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07034_GetCanceledSe5(cIdMov)
    Local cQuery        As Character
    Local aRecno        As Array
    Local cAlias        As Character
    Local aArea         as Array
    Local lPrc          As Logical
    Local nX            As Numeric
    Local aRes          As Array
    Local cHlpMsg       As Character
    

    aRecno  := {}
    aRes    := {}
    lPrc    :=.T.
    cHlpMsg :=""

    aArea      := GetArea()
        cQuery := "SELECT SE5.R_E_C_N_O_                                          "
        cQuery += "FROM "       + RetSQLName("SE5") + " SE5                       "
        cQuery += "INNER JOIN " + RetSQLName("FKA") + " FKA                       "
        cQuery += "  ON FKA_IDORIG =  SE5.E5_IDORIG                                   "
        cQuery += "  WHERE FKA.FKA_IDPROC = "
        cQuery += " ( "
        cQuery += " SELECT fka_idproc "
        cQuery += "FROM "       + RetSQLName("FKA")
        cQuery += "WHERE  fka_idorig = '" + cIdMov +"' "
        cQuery += " ) "
        cQuery += "  AND FKA.D_E_L_E_T_ = ''   AND SE5.D_E_L_E_T_ = '' AND SE5.E5_SITUACA = 'C'"
        cQuery := ChangeQuery(cQuery)
        cAlias := MPSysOpenQuery(cQuery)
        DBSelectArea(cAlias)
        (cAlias)->(DBGoTop())
        While (cAlias)->(!EOF())
            AADD(aRecno,(cAlias)->(r_e_c_n_o_)) 
            (cAlias)->(DBSkip())
        EndDo
        (cAlias)->(DBCloseArea())

        If !EMPTY( aRecno )
            For nX := 1 To Len(aRecno)
                SE5->(DbGoTo(aRecno[nX]))
                If SE5->(RecLock("SE5",.F.))
                    SE5->(dbDelete())
                    SE5->(MsUnLock())
                Else
                    cHlpMsg := STR0198 //record lock error
                    lPrc := .F.
                EndIf
            Next nX            
        ENDIF            

    RestArea(aArea)
    AADD( aRes, lPrc )
    AADD( aRes, cHlpMsg )

Return aRes 


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07035_ValidateCustomer
Function used for customer related fields validation F4C_CUST and F4C_CUNI

@param       Numeric          nParam //1 - validate customer code, 2 - validate customer unit
             Character        cTab  // character Id for table "F4C"
@return      Logical          lRet
@example     
@author      astepanov
@since       November/05/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07035_ValidateCustomer(nParam, cTab)
    Local lRet      As Logical
    Local aSaveArea as Array
    Default nField := 1
    lRet := .T.
    aSaveArea := GetArea()
    If     lRet .AND. nParam == 1
        If !Empty(FwFldGet(cTab+"_CUST"))
            lRet:= ExistCpo("SA1",FwFldGet(cTab+"_CUST"))
        EndIf
    ElseIf lRet .AND. nParam == 2
        lRet:= ExistCpo("SA1",FwFldGet(cTab+"_CUST")+FwFldGet(cTab+"_CUNI"))
    Endif
    RestArea(aSaveArea) 
Return lRet // End of RU06D07035_ValidateCustomer


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07036_GetlAutoIns
Check bank statement status, and return a logical value.
If .T. - we can update lines and fields in model, if .F. - we cannot update lines and fields
in the model
@return      Logical          lRet
@example     
@author      astepanov
@since       November/05/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06D07036_GetlAutoIns()
    Local lRet       As Logical
    lRet := IIf(FWFldGet("F4C_STATUS") == S_CREATED .OR. FWFldGet("F4C_STATUS") == S_REPLACEMENT, .T., .F.)
Return lRet //End of RU06D07036_GetlAutoIns


/*/{Protheus.doc} RU06D07037_GatCust
This function assigned to the triggers
for F4C_CUST and F4C_CUNI fields. When we input
F4C_CUST or F4C-CUNI fields we fill information about
customer like customer name, KPP.
@author astepanov
@param cField     Character   Field id which we should fill
@since 18 August 2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D07037_GatCust(cField)
    Local  cRet      As Character
    Local  aArea     As Array
    Local  aAreaSA1  As Array
    Local  cTab      As Character
    aArea    := GetArea()
    aAreaSA1 := SA1->(GetArea())
    cRet     := ""
    cTab     := __cTabHdr
    If     cField == cTab+"_CUNI"
        cRet := Posicione("SA1",1,xFilial("SA1")+FwFldGet(cTab+"_CUST"),"A1_LOJA")
    ElseIf cField == cTab+"_CUSNAM"
        cRet := Posicione("SA1",1,xFilial("SA1")+FwFldGet(cTab+"_CUST")+FwFldGet(cTab+"_CUNI"),"A1_NOME")
    ElseIf cField == cTab+"_KPPPAY"
        cRet := Posicione("SA1",1,xFilial("SA1")+FwFldGet(cTab+"_CUST")+FwFldGet(cTab+"_CUNI"),"A1_INSCGAN")
        // Delete Lines in a grid after entering a new customer
        RU06D05497_DelLinesInTheGrid()
    EndIf
    cRet := PADR(cRet,GetSX3Cache(cField,"X3_TAMANHO"," "))
    RestArea(aAreaSA1)
    RestArea(aArea)
Return cRet //End of RU06D07037_GatCust


Function RU06D07038_GatBankPay(cField, cModelID)
    Local cRet As Character
    If      FwFldGet("F4C_OPER") == "1" //Inflow BS
        cRet := RU06D07040_GatCustBankData(cField)
    ElseIf  FwFldGet("F4C_OPER") == "2" //Outflow BS
        cRet := RU06D05493_GatBankPay(cField,cModelID)    
    EndIf
Return cRet


Function RU06D07039_GatBankRec(cField, cModelID)
    Local cRet As Character
    If      FwFldGet("F4C_OPER") == "1" //Inflow BS
        cRet := RU06D05493_GatBankPay(cField,cModelID) 
    ElseIf  FwFldGet("F4C_OPER") == "2" //Outflow BS
        cRet := RU06D05495_GatBankRec(cField,cModelID)  
    EndIf
Return cRet


/*/{Protheus.doc} RU06D07040_GatCustBankData
This function called when we run triggers for : F4C_BNKPAY, F4C_PAYACC, F4C_CUST, F4C_CUNI
when F4C_OPER == "1" (inflow bank statement)
The main reason for this function : return a content for bank account related fields like:
F4C_BNKPAY,F4C_PAYBIK,F4C_PAYACC,F4C_TYPCP,F4C_BKPNAM,F4C_ACPNAM,F4C_PAYNAM according to rules
described in https://jiraproducao.totvs.com.br/browse/RULOC-825
@param  Character cField     // Target field id, for which we return cRet
@return Character cRet
@author astepanov
@since 30 September 2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D07040_GatCustBankData(cField)
    Local cRet        As Character
    Local cAlias      As Character
    Local cTab        As Character
    Local cBnkField   As Character
    Local cBICField   As Character
    Local cAccField   As Character
    Local cCurField   As Character
    Local cPayRecNam  As Character
    Local cBKPRNam    As Character
    Local cACPRNam    As Character
    Local cTypNam     As Character
    Local cCusField   As Character
    Local cUntField   As Character
    Local lPutDeflt   As Logical
    Local aArea       As Array
    Local aResD07040  As Array
    Local nX          As Numeric

    cRet  := ""
    aArea := GetArea()
    cTab := __cTabHdr
    cBnkField  := cTab+"_BNKPAY"
    cBICField  := cTab+"_PAYBIK"
    cAccField  := cTab+"_PAYACC"
    cCurField  := cTab+"_CURREN"
    cBKPRNam   := cTab+"_BKPNAM"
    cPayRecNam := cTab+"_PAYNAM"
    cACPRNam   := cTab+"_ACPNAM"
    cTypNam    := cTab+"_TYPCP"
    cCusField  := cTab+"_CUST"
    cUntField  := cTab+"_CUNI"
    // we put customers's bank company info if we have main account
    // or we have only one non-main account in other cases
    // we clear customer's bank account data.
    // https://jiraproducao.totvs.com.br/browse/RULOC-825
    cAlias     := ""
    aResD07040 := {{"",""}}
    If cField == cBnkField
        // if we will add for standard query F4N a filter for blocked bank accounts
        // we should change 8th parameter (lExClsd) to .T.
        cAlias := RU06XFUN43_RetCustDataByKey(FWFldGet(cCusField),FWFldGet(cUntField),FwFldGet(cCurField),Nil,Nil,Nil," INNER JOIN ",.F.)
        aArea  := GetArea()
        DBSelectArea(cAlias)
        (cAlias)->(DBGoTop())
        If (cAlias)->(!Eof())
            lPutDeflt  := .T.
            If !(AllTrim((cAlias)->_TYPCP) == "1")
            (cAlias)->(DBSkip())
                If (cAlias)->(!Eof())
                    lPutDeflt := .F.
                EndIf
            EndIf
            (cAlias)->(DBGoTop())
            If lPutDeflt
                AADD(aResD07040, {cBnkField, (cAlias)->_BNKPAY})
                AADD(aResD07040, {cBICField, (cAlias)->_PAYBIK})
                AADD(aResD07040, {cAccField, (cAlias)->_PAYACC})
                AADD(aResD07040, {cTypNam,   (cAlias)->_TYPCP })
                AADD(aResD07040, {cBKPRNam,  (cAlias)->_BKPNAM})
                AADD(aResD07040, {cACPRNam,  (cAlias)->_ACPNAM})
                AADD(aResD07040, {cPayRecNam,(cAlias)->_PAYNAM})
            EndIf
        EndIf
        (cAlias)->(DBCloseArea())
        RestArea(aArea)
    Else //!(cField == cBnkField)
        // if we will add for standard query F4N a filter for blocked bank accounts
        // we should change 8th parameter (lExClsd) to .T.
        If !Empty(FWFldGet(cBnkField))
            If     cField == cBICField
                cAlias := RU06XFUN43_RetCustDataByKey(FWFldGet(cCusField),FWFldGet(cUntField),FwFldGet(cCurField),FWFldGet(cBnkField),Nil,Nil," INNER JOIN ",.F.)
            ElseIf cField == cAccField
                cAlias := RU06XFUN43_RetCustDataByKey(FWFldGet(cCusField),FWFldGet(cUntField),FwFldGet(cCurField),FWFldGet(cBnkField),FWFldGet(cBICField),Nil," INNER JOIN ",.F.)
            Else
                cAlias := RU06XFUN43_RetCustDataByKey(FWFldGet(cCusField),FWFldGet(cUntField),FwFldGet(cCurField),FWFldGet(cBnkField),FWFldGet(cBICField),FWFldGet(cAccField)," INNER JOIN ",.F.)
            EndIf
        EndIf
        If !Empty(cAlias)
            DBSelectArea(cAlias)
            (cAlias)->(DBGoTop())
            If (cAlias)->(!Eof())
                AADD(aResD07040, {cBnkField, (cAlias)->_BNKPAY})
                AADD(aResD07040, {cBICField, (cAlias)->_PAYBIK})
                AADD(aResD07040, {cAccField, (cAlias)->_PAYACC})
                AADD(aResD07040, {cTypNam,   (cAlias)->_TYPCP })
                AADD(aResD07040, {cBKPRNam,  (cAlias)->_BKPNAM})
                AADD(aResD07040, {cACPRNam,  (cAlias)->_ACPNAM})
                AADD(aResD07040, {cPayRecNam,(cAlias)->_PAYNAM})
            EndIf
            (cAlias)->(DBCloseArea())
        EndIf
    EndIf
    nX := ASCAN(aResD07040 ,{|x| x[1] == cField})
    If nX > 0
        cRet := PADR(aResD07040[nX][2],GetSX3Cache(cField,"X3_TAMANHO"), " ")
    EndIf
    RestArea(aArea)
    
Return cRet //End of RU06D07040_GatCustBankData

/*/{Protheus.doc} RU06D07048_Init_aBStExpPrm
Function creates initial array for RU06D07023_OutflowFinPost and oyher functions.
We pass this array to functions located in fina084 source and to FINA080.
For details look at specification FI-AP-15-11, For correct work
should be positioned on correct F4C record.
@type function
@version  
@author astepanov
@since 7/5/2021
@param cFCUUID,   Character F4C->F4C_CUUID
       nValCntCur, Numeric  Value in contracted currency F5M->F5M_VALPAY or other value
@return aBStExpPrm, array 
//1 - Bank statement UUID
//2 - FK5_VLMOE2 value when we post AP
//3 - array with SFR recnos. We should change FR_IDWTOFF
      for these recno's to IDFK2
//4 - flag .T. - we should write AFRIDWTOFF, .F. - no
//5 - flag .T. - revaluation list filled, .F. - no
//9 - Value in contracted currency F5M->F5M_VALPAY or other value
//10 - Value in BS currency F5M->F5M_VALCNV or other value
//11 - we are in cnacelling exchange rates process
/*/
Function RU06D07048_Init_aBStExpPrm(cFCUUID,nValCntCr,nValInBSCr,lCanclExRt)
    Local aBStExpPrm As Array
    Local lGrLncBkp  As Logical
    Local lDigitaBkp As Logical
    Default cFCUUID     := F4C->F4C_CUUID
    Default nValCntCr   := F5M->F5M_VALPAY
    Default nValInBSCr  := F5M->F5M_VALCNV
    Default lCanclExRt  := .F.
    If Type("lGeraLanc") == "L"
        lGrLncBkp := lGeraLanc
    Else
        lGeraLanc := .F.
        lGrLncBkp := lGeraLanc
    EndIf
    If Type("lDigita") == "L"
        lDigitaBkp  := lDigita
    Else
        lDigita    := .F.
        lDigitaBkp := lDigita
    EndIf    
    aBStExpPrm := {{"CITNUUIDBS", cFCUUID           },; //1
                   {"NFK5VLMOE2", Nil               },; //2
                   {"AFRIDWTOFF", {}                },; //3
                   {"LWRITFRRUS", .F.               },; //4
                   {"LRVLLISTFL", .F.               },; //5
                   {"LPOSTPROB", .F.                },; //6
                   {"NPOSTONLIN", iif(lGeraLanc,1,2)},; //7
                   {"NVIEWPOST", iif(lDigita,1,2)   },; //8
                   {"NVALCNTCR", nValCntCr          },; //9
                   {"NVALBSCUR", nValInBSCr         },; //10
                   {"CANCLEXRAT",lCanclExRt         }}  //11
    lDigita   := lDigitaBkp
    lGeraLanc := lGrLncBkp
Return aBStExpPrm


/*/{Protheus.doc} RU06D07049_GetSrfREceivable
Transform the FK7 KEY in SFR key for receivable
@type function
@version  P12
@author eduardo.Flima
@since 8/6/2021
@param cFK7Chave, character, key used in FK7 
@return character, key in format SFR used in receivable
/*/
Function RU06D07049_GetSrfREceivable(cFK7Chave)
    Local cSFRChavor    As Character
    Local aSFRChavor    As Array   
    Local nX            As Numeric

    aSFRChavor:=Separa(alltrim(cFK7Chave), "|", .T.)
    cSFRChavor:= aSFRChavor[len(aSFRChavor)-1]
    cSFRChavor+= aSFRChavor[len(aSFRChavor)]
    For nX:=2 to Len(aSFRChavor)-2
        cSFRChavor+= aSFRChavor[nX]
    Next nX    

Return cSFRChavor

/*/{Protheus.doc} RU06D07050_Number_Of_Writeoff
Return the quantity of write-off for determinated bill in a determinated date
@type function
@version  P12
@author eduardo.Flima
@since 8/13/2021
@param dData, date, Date to chech the write-off
@param cChave, character, Key of the bill in FK7 format
@return numeric, Number of write off found 
/*/
Function RU06D07050_Number_Of_Writeoff(dData,cChave)
    Local aArea  As Array
    Local nCount   As Numeric
	Local cQuery As Character
	Local cAlias As Character



   	aArea  := GetArea()
    cQuery := "SELECT                                                            "
    cQuery += "        COUNT(FK1.r_e_c_n_o_)        QTD                         "
    cQuery += "FROM       (                                                      "
    cQuery += "            SELECT *                                              "
    cQuery += "            FROM " + RetSQLName("FK1") + "                        "
    cQuery += "            WHERE   FK1_FILIAL  = '" + xFilial("FK1") + "'        "
    cQuery += "              AND   D_E_L_E_T_  = ' '                             "
    cQuery += "              AND   FK1_DATA    = '" + DTOS(dData) + "'         "
    cQuery += "                                                        ) FK1     "
    cQuery += "INNER JOIN " + RetSQLName("FK7") + "                      FK7     "
    cQuery += "        ON   FK7.FK7_FILIAL = '" + xFilial("FK7") + "'            "
    cQuery += "        AND  FK7.D_E_L_E_T_ = ' '                                 "
    cQuery += "        AND  FK7.FK7_ALIAS  = 'SE1'                               "
    cQuery += "        AND  FK7.FK7_CHAVE  = '" + cChave + "'                   "
    cQuery += "        AND  FK7.FK7_IDDOC  = FK1.FK1_IDDOC                       "
    cQuery += "INNER JOIN " + RetSQLName("FKA") + "                      FKA     "
    cQuery += "        ON   FKA.FKA_FILIAL = '" + xFilial("FKA") + "'            "
    cQuery += "        AND  FKA.D_E_L_E_T_ = ' '                                 "
    cQuery += "        AND  FKA.FKA_IDORIG = FK1.FK1_IDFK1                       "
    cQuery += "LEFT  JOIN (                                                      "
    cQuery += "            SELECT                                                "
    cQuery += "                   FKA_IDPROC                                     "
    cQuery += "            FROM " + RetSQLName("FKA") + " FKA                    "
    cQuery += "            INNER JOIN " + RetSQLName("FK1") + " FK1              "
    cQuery += "                    ON  FK1.FK1_FILIAL = '" + xFilial("FK1") + "' "
    cQuery += "                    AND FK1.FK1_TPDOC  = 'ES'                     "
    cQuery += "                    AND FK1.D_E_L_E_T_ = ' '                      "
    cQuery += "                    AND FKA.FKA_FILIAL = '" + xFilial("FKA") + "' "
    cQuery += "                    AND FKA.FKA_TABORI = 'FK1'                    "
    cQuery += "                    AND FKA.D_E_L_E_T_ = ' '                      "
    cQuery += "                    AND FKA.FKA_IDORIG = FK1.FK1_IDFK1            "
    cQuery += "            GROUP BY FKA.FKA_IDPROC                     ) EST     "
    cQuery += "        ON   FKA.FKA_IDPROC = EST.FKA_IDPROC                      "
    cQuery += "WHERE EST.FKA_IDPROC IS NULL                                      "

    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    DBSelectArea(cAlias)
    DBGoTop()
    If !Eof()
        nCount := (cAlias)->QTD
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)


Return nCount





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa074GetTxºAutor  ³Bruno Sobieski      ºFecha ³  10-14-04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pega a taxa que sera considerada como a taxa original (e a  º±±
±±º          ³taxa da ultima correcao, ou a do titulo)                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍ'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*/{Protheus.doc} RU06D07051_GetTxSfr
Get the last date and tax of revaluation in SFR
@type function
@version  P12
@author eduardo.Flima
@since 8/26/2021
@param nTaxa, numeric, variable that will receive the tax of the last revaliation
@param dUltDif, date,  variable that will receive the date of the last revaliation
@param lAchouSFR, logical, variable that will receive if found a SFR
@param lAchouDt, logical, variable that will receive if found a prevows date in SFR
@param nTaxaAt, numeric, variable that will receive the actual tax rate
/*/
Function RU06D07051_GetTxSfr(nTaxa,dUltDif,lAchouSFR,lAchouDt,nTaxaAt,lRbdBal)
    Local cSequencia	:=	Space(TamSx3('FR_SEQUEN')[1])
    Local cTipoMov		:=	"S"     

    Default lRbdBal     := .F.

    dUltDif:=SE1->E1_EMISSAO
    nTaxa	:= RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)
    nTaxaAt	:= RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)
    DbSelectArea('SFR')
    DbSetOrder(3)
    DbSeek(xFilial()+"1"+cTipoMov+cSequencia+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO,.T.)
    While ( FR_FILIAL==xFilial() .And. FR_CARTEI=="1".And. FR_CHAVOR==PADR(SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO, len(FR_CHAVOR)) ) .And. !EOF() 
        If FR_FILIAL==xFilial() .And. FR_CARTEI=="1".And. FR_CHAVOR==PADR(SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO, len(FR_CHAVOR)) .AND. ((SFR->FR_DATADI <= dDataBase) .AND. (SFR->FR_RBDBAL!='3'))
            If FR_TIPODI=='S'
                nTaxa:=Iif( SFR->FR_MOEDA == mv_par10,IIf(SFR->FR_MOEDA==0,RecMoeda(SFR->FR_DATADI,mv_par10), SFR->FR_TXORI),nTaxa) 
                lAchouSFR:=.T.
                dUltDif	:=	SFR->FR_DATADI
                lAchouDt:= Iif(SFR->FR_DATADI ==dDataBase,.T.,.F.)
                nTaxa:= SFR->FR_TXORI
                nTaxaAt:=SFR->FR_TXATU                
                lRbdBal:=SFR->FR_RBDBAL=='1'                
            EndIf	
        Endif
    SFR->(DbSKip())
    EndDo
Return

/*/{Protheus.doc} MrkLinsAcc
When MV_CTBFLAG set to T we pass aFlagBx to DetProva, but when it F
we should manually mark all lines which contains aFlagBx
aFlagBx has next format:
{{"E5_LA", "S", "SE5", SE5->(Recno()), 0, 0, 0} ...}
@type static function
@version  
@author astepanov
@since May/17/2022
@param aFlagBx, array, array in format {{"E5_LA", "S", "SE5", SE5->(Recno()), 0, 0, 0} ...}
@return lRet, Logical
/*/
Static Function MrkLinsAcc(aFlagBx)
    Local lRet   As Logical
    Local aArea  As Array
    Local nX     As Numeric
    Local nRecno As Numeric
    Local cField As Character
    Local cAlias As Character
    lRet  := .T.
    aArea := GetArea()
    nX    := 1
    While lRet .AND. nX <= Len(aFlagBx)
        cAlias := aFlagBx[nX][3]
        nRecno := aFlagBx[nX][4]
        DBSelectArea(cAlias)
        (cAlias)->(DBGoto(nRecno))
        If RecLock(cAlias, .F.)
            cField    := aFlagBx[nX][1]
            &(cField) := aFlagBx[nX][2]
            (cAlias)->(MsUnlock())
        Else
            lRet := .F.
        EndIf
        nX := nX + 1
    EndDo
    RestArea(aArea)
Return lRet

/*/{Protheus.doc} RU06D07721_IsReturnFromSupplier

According provided cOprDircton or F4C_RECTYP we define: is it Return from supplier
or not
@type function
@version  
@author astepanov
@since 1/17/2022
@param cOprDircton, character, "1|2" or other, can be Nil
@param cOper, character, Default "" value of F4C_OPER fro defining it is Inflow BS or not
@param cRecTyp, character, Default "" value of F4C_RECTYP for defining it is return from supplier or not
@return lRet, if .T. it is a Return from Supplier
/*/
Function RU06D07721_IsReturnFromSupplier(cOprDircton,cOper,cRecTyp)
    Local lRet  As Logical
    Default cOprDircton := "0|0"
    default cOper       := ""
    Default cRecTyp     := ""
    lRet := .F.
    If !( cOprDircton == "0|0" )
        lRet := IIf(cOprDircton == IT_RETURNFROMSP,.T.,.F.)
    Else
        lRet := IIf(cOper+"|"+cRecTyp == IT_RETURNFROMSP,.T.,.F.)
    EndIf 
Return lRet

/*/{Protheus.doc} RU06D07722_IsInflow
According provided cOprDircton or F4C_OPER we define: is it Inflow BS or Not
@type function
@version  
@author astepanov
@since 1/17/2022
@param cOprDircton, character, "1|1" or other, can be Nil
@param cOper, character, value of F4C_OPER field, Default ""
@return lRet, if .T. it is an Inflow BS
/*/
Function RU06D07722_IsInflow(cOprDircton, cOper)
    Local lRet  As Logical
    Default cOprDircton := "0|0"
    Default cOper       := ""
    lRet := .F.
    If !( cOprDircton == "0|0" )
        lRet := IIf(StrTokArr(cOprDircton,"|")[1] == IS_INFLOWBANKST,.T.,.F.)    
    Else
        lRet := IIf(cOper == IS_INFLOWBANKST,.T.,.F.)
    EndIf
Return lRet

/*/{Protheus.doc} RU06D07723_IsOutflow
According provided cOprDircton or F4C_OPER we define: is it Outflow BS or Not
@type function
@version  
@author astepanov
@since 1/17/2022
@param cOprDircton, character, "2|1" or other, can be Nil
@param cOper, character, value of F4C_OPER field, Default ""
@return lRet, if .T. it is an Outflow BS
/*/
Function RU06D07723_IsOutflow(cOprDircton, cOper)
    Local lRet  As Logical
    Default cOprDircton := "0|0"
    Default cOper       := ""
    lRet := .F.
    If !( cOprDircton == "0|0" )
        lRet := IIf(StrTokArr(cOprDircton,"|")[1] == IS_OUTFLOWBANKS,.T.,.F.)    
    Else
        lRet := IIf(cOper == IS_OUTFLOWBANKS,.T.,.F.)
    EndIf
Return lRet

/*/{Protheus.doc} RU06D07052_CancelWithoutAskingAboutChangesSaving()
We call this fucnction when press Cancel button during reversal process
We should abort all modifications and just close the window.
@type function
@version  
@author astepanov
@since 10/21/2021
@return Logical, lRet
/*/
Static Function RU06D07052_CancelWithoutAskingAboutChangesSaving()
    Local oModel As Object
    Local lRet   As Logical
    lRet   := .T.
    oModel := FWModelActive()
    If oModel != Nil .AND. oModel:CID == "RU06D07"
        oModel:lModify := .F.
    EndIf
Return lRet

Function RU06D07053_PositionSA1SA6F4N()
    Local lRet       As Logical
    Local aArea      As Array
    Local cAliasF4N  As Character
    Local nF4NRecno  As Numeric
    lRet := .T.
    aArea  := GetArea()
    SA1->(DBSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
    lRet := IIF(SA1->(DBSeek(xFilial("SA1")+F4C->F4C_CUST+F4C->F4C_CUNI)),;
                .T.,.F.) .AND. lRet
    SA6->(DBSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
    lRet := IIF(SA6->(DBSeek(xFilial("SA6")+;
                F4C->F4C_BNKREC+F4C->F4C_RECBIK+F4C->F4C_RECACC,.F.)),;
                .T.,.F.) .AND. lRet
    cAliasF4N := RU06XFUN42_RetBankAccountDataFromF4N(F4C->F4C_CUST, F4C->F4C_CUNI, Nil, F4C->F4C_BNKPAY, F4C->F4C_PAYBIK, F4C->F4C_PAYACC,.T.)
    DBSelectArea(cAliasF4N)
    DBGoTop()
    If !EoF()
        nF4NRecno := 0
        nF4NRecno := (cAliasF4N)->_F4NREC
        If nF4NRecno <> 0
            F4N->(DBSetOrder(1)) //F4N_FILIAL+F4N_CLIENT+F4N_LOJA+F4N_TYPE+F4N_BANK+F4N_BIK+F4N_ACC   
            F4N->(DBGoTo(nF4NRecno))
        Else
            lRet := .F.
        EndIf
    EndIf
    (cAliasF4N)->(DBCloseArea())
    RestArea(aArea)
Return lRet

/*/{Protheus.doc} RU06D07720_VldAdvance
description
@type function
@version  
@author astepanov
@since 10/8/2021
@return variant, return_description
/*/
Function RU06D07720_VldAdvance()
    Local lRet      As Logical
    Local oModel    As Object
    Local oModelVrt As Object
    Local nX        As Numeric
    Local nPos      As Numeric
    Local cAdvance  As Character
    Local cErrMsg0  As Character
    Local cErrMsg1  As Character
    Local cErrMsg2  As Character
    lRet := .T.
    oModel := FWModelActive()
    If ValType(oModel) == "O" .AND. oModel:GetId() == "RU06D07"
        If FwFldGet("F4C_OPER") == "1" //Inflow BS
            cAdvance := MVRECANT
            cErrMsg0 := STR0230 //Advance
            cErrMsg1 := STR0103 /* Bank statement has AR */
            cErrMsg2 := STR0104 /*'Bank statement with a flag "Advance = Yes" cannot have Accounts Receivables linked' */
        Else                           //Outflow BS
            cAdvance := MVPAGANT
            cErrMsg0 := STR0230 //Advance
            cErrMsg1 := STR0105 /* Bank statement has AP */
            cErrMsg2 := STR0106 /* 'Bank statement with a flag "Advance = Yes" cannot have Accounts Payables linked'*/
        EndIf
        nX := 1
        oModelVrt := oModel:GetModel("RU06D07_MVIRT")
        nPos      := oModelVrt:GetLine()
        While lRet .AND. nX <= oModelVrt:Length()
            oModelVrt:GoLine(nX)
            If !oModelVrt:IsDeleted() .AND.;
               !Empty(oModelVrt:GetValue("B_TYPE")) .AND.;
               !(AllTrim(oModelVrt:GetValue("B_TYPE")) $ cAdvance) 
                lRet := .F.
            EndIf
            nX := nX + 1
        EndDo
        oModelVrt:GoLine(nPos)
        If !lRet
            oModel:SetErrorMessage("RU06D07_MHEAD", "F4C_ADVANC"  , "RU06D07_MHEAD",;
                                   "F4C_ADVANC"   , cErrMsg0, cErrMsg1, cErrMsg2    )
        EndIf
    EndIf
Return lRet


/*/{Protheus.doc} RU06D07738_CheckExchangeRateCalculationForSameDate
When we generate exchange rate difference for conventional units.
We can write-off AP on same date with different exchange rates. This case provides a lot of
troubles for calculations. So, for preventing this case we ask an user about it or just return .F.
if process is automated.
@type function
@version 1.0
@author astepanov
@since MArch/31/2022
@param cWorkTab, character, "SE2" or "SE1"
@param nTxMoeda, numeric, Exchange rate
@return logical, .T. - allow generating new exchange rate difference, .F. - disallow
/*/
Function RU06D07738_CheckExchangeRateCalculationForSameDate(cWorkTab,nTxMoeda)
    Local lRet       As Logical
    Local lAuto      As Logical
    Local aTmp       As Array
    Local oModel     As Object
    Local oModelVrt  As Object
    Local nLine      As Numeric
    Local cMsg       As Character
    Local cTit       As Character
    lRet  := .T.
    lAuto := .F.
    nLine := 1
    oModel := FWModelActive()
    If ValType(oModel) == "O" .AND. oModel:GetId() == "RU06D07"
        oModelVrt := oModel:GetModel("RU06D07_MVIRT")
        nLine := oModelVrt:GetLine()
        lAuto := IsBlind() .Or. RU06D07740_GetAutoBs()
    Else
        // Check FINA080Auto
        If ValType(lF080Auto) == "L" .AND. lF080Auto == .T.
            lAuto := .T.
        EndIf
    EndIf
    aTmp := RU06XFUN87_CheckFR_DATADI(cWorkTab,dDataBase)
    // Asking Message about adding new exch rate calculation with same date and different exchange rate --BS 
    cMsg := STR0214+cValToChar(nLine)+" "+DTOC(dDataBase)+"."+STR0216+cValToChar(aTmp[2])+"."+STR0217+cValToChar(nLine)+STR0218+cValToChar(nTxMoeda)+"."+STR0219
    cTit := STR0002
    If aTmp[1] != Nil .AND. aTmp[1] == dDataBase .AND. !(aTmp[2] == nTxMoeda)
        If !lAuto
            lRet := MsgYesNo(cMsg,cTit)
        Else
            lRet := .F.
        EndIf
    EndIf
Return lRet


/*/{Protheus.doc} LockSubmdF
    Lock submodel fields in database
    @type  Function
    @author astepanov
    @since 19/10/2022
    @version version
    @param oModelF5M, Object, Grid model which fields we must lock in DB
    @param aLockedF5M, Array, Array of locked fields
    @return lRet, Logical, .T. or .F.
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function LockSubmdF(oModelF5M,aLockedF5M)
    Local lRet As Logical
    Local nPos As Numeric
    Local nX   As Numeric
    F5M->(DbSetOrder(1)) //F5M_FILIAL+F5M_ALIAS+F5M_IDDOC+F5M_KEY
    nPos := oModelF5M:GetLine()
    aLockedF5M := {}
    nX   := 1
    lRet := .T.
    While nX <= oModelF5M:Length() .AND. lRet
        oModelF5M:GoLine(nX)
        If F5M->(DBSeek(oModelF5M:GetValue('F5M_FILIAL')+oModelF5M:GetValue('F5M_ALIAS')+oModelF5M:GetValue('F5M_IDDOC')+oModelF5M:GetValue('F5M_KEY')))
            If RecLock("F5M",.F.)
                AADD(aLockedF5M,{"F5M",F5M->(Recno())})
            Else
                lRet := .F.
            EndIf
        EndIf
        nX := nX + 1
    EndDo
    oModelF5M:GoLine(nPos)
Return lRet

/*/{Protheus.doc} UlckSbmdFl
    Unlock locked submodel fields in database
    @type  Function
    @author astepanov
    @since 19/10/2022
    @version version
    @param aLockedF5M, Array, Array of locked fields in formt ({"Alias",R_e_c_n_o_})
    @return lRet, Logical, .T. or .F.
    @example
    (examples)
    @see (links_or_references)
    /*/
Function UlckSbmdFl(aLockedF5M)
    Local lRet As Logical
    Local nX   As Numeric
    lRet := .T.
    If !Empty(aLockedF5M)
        For nX := 1 To Len(aLockedF5M)
            (aLockedF5M[nX][1])->(DbGoto(aLockedF5M[nX][2]))
            (aLockedF5M[nX][1])->(MSUnlock())
        Next nX
    EndIf
Return lRet

/*/{Protheus.doc} RU06D07739_SetAutoBs
Set flag lAutoBS for blind mod
@type function
@version 12.1.2310
@author ogalyandina
@since 19/04/2024
@param lIsBlind, logical
@return NIL
/*/
Function RU06D07739_SetAutoBs(lIsBlind as Logical)
    DEFAULT lIsBlind := .F.
    lAutoBS := lIsBlind
Return NIL

/*/{Protheus.doc} RU06D07740_GetAutoBs
Get flag lAutoBS about blind mod
@type function
@version 12.1.2310
@author ogalyandina
@since 19/04/2024
@return lAutoBS: .T. is blind, .F. is not blind
/*/
Function RU06D07740_GetAutoBs()
Return lAutoBS
                   
//Merge Russia R14 
                   
