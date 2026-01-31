#INCLUDE 'PROTHEUS.CH'

/*/
{Protheus.doc} UPDRUSTOOL()

Update data dictionary. 
To be used in case of problems on ATUSX.     

@type  Function
@author Flavio Lopes Rasta
@since 04/07/2018
@version 12.1.19 Russia R5
/*/
Main Function UPDRUSTOOL()
Local lRet          as Logical
Local cMsgError     as Character
Local aUpdate       as Array
Local oWizard       as Object
Local aVldUpdate    as Array

lRet        := .T.
nX          := 1
cMsgError   := ""

OpenSM0Excl()

RpcSetType( 3 )

If SM0->M0_CODIGO == "99"
    SM0->(dbSkip())
EndIf

RpcSetEnv( SM0->M0_CODIGO,SM0->M0_CODFIL)

aUpdate     := UPDRUS()
aVldUpdate  := VldUPDRUS(aUpdate)

lRet        := aVldUpdate[1]
cMsgError   := aVldUpdate[2]

oWizard := WizDef(aUpdate,lRet,cMsgError)
oWizard:Activate()

RpcClearEnv()

Return .T.

/*/
{Protheus.doc} WizDef()
    
@type  Function
@author Flavio Lopes Rasta
@since 04/07/2018
@version 12.1.19 Russia R5
@return oStepWiz, Object , Wizard to be activated
/*/
Static Function WizDef(aUpdate,lRet,cMsgError)
Local oStepWiz  as Object
Local lFim      as Logical
Local oNewPag   as Object

lFim    := .F.

oStepWiz:= FWWizardControl():New(,{600,720})
oStepWiz:ActiveUISteps()

//----------------------
// Page 1
//----------------------

oNewPag := oStepWiz:AddStep("1")
oNewPag:SetStepDescription("Introduction")
oNewPag:SetConstruction({|oPanel|InitMessage(oPanel)})
oNewPag:SetNextAction({||.T.})
oNewPag:SetCancelAction({||.T.})
oNewPag:SetNextTitle("Execute")

//----------------------
// Page 2
//----------------------
oNewPag := oStepWiz:AddStep("2")
oNewPag:SetStepDescription("Process")
oNewPag:SetConstruction({|oPanel|Process(oPanel,aUpdate,@lRet,@lFim,@cMsgError)})
oNewPag:SetNextAction({||lFim,.T.})
oNewPag:SetCancelWhen({||.F.})
oNewPag:SetPrevWhen({||.F.})

//----------------------
// Page 3
//----------------------
oNewPag := oStepWiz:AddStep("3", {|Panel|Status(Panel, lRet, cMsgError,aUpdate)})
oNewPag:SetStepDescription("Status")
oNewPag:SetNextAction({||.T.})
oNewPag:SetCancelWhen({||.F.})
oNewPag:SetPrevWhen({||.F.})

Return oStepWiz

/*/
{Protheus.doc} VldUPDRUS()
    
@type  Function
@author Flavio Lopes Rasta
@since 04/07/2018
@version 12.1.19 Russia R5
@return aUpdate, array , Array with the fields structures to update
/*/
Static Function VldUPDRUS(aUpdate)
Local lRet          as Logical
Local cMsgError     as Character
Local nX            as Numeric
Local aDicStru      as Array
Local nPosDicFld    as Numeric

lRet    := .T.
nX      := 1

If ValType(aUpdate) <> 'A'
    lRet := .F.
    cMsgError := "The structure expected (aUpdate) is not an array."
Endif

If lRet .and. Len(aUpdate) == 0
    lRet := .F.
    cMsgError := "The array (aUpdate) is empty."
Endif

While lRet .and. nX <= Len(aUpdate)
    aDicStru := {}
   /* //Verificar necessidade 
    If Len(aUpdate[nX]) <> 5
        lRet := .F.
        cMsgError := I18N("Array out of bounds: aUpdate[#1] = Size #2 of #3.",{nX,Len(aUpdate[nX]),4})
    Endif
   */
    If lRet
        Do Case
            Case aUpdate[nX][1] == "SX3"

                SX3->(DbSetOrder(2))   
                If !SX3->(DbSeek(aUpdate[nX][2]))
                    lRet := .F.
                    cMsgError := I18N("The field #1 was not found in SX3 table. Position aUpdate[#2][2].",{aUpdate[nX][2],nX})
                Endif

                If lRet 
                    aDicStru := SX3->(DbStruct())
                    nPosDicFld := Ascan(aDicStru, {|x| x[1] == aUpdate[nX][3] })
                    If  !(nPosDicFld > 0)
                        lRet := .F.
                        cMsgError := I18N("The field #1 was not found in SX3 table structure. Position aUpdate[#2][3].",{aUpdate[nX][3],nX})
                    EndIf
                Endif
                
                If lRet 
                    If aDicStru[nPosDicFld][2] <> ValType(aUpdate[nX][4])
                        lRet := .F.
                        cMsgError := I18N("Type mismatch #1 -> #2 on aUpdate[#3][4].",{aDicStru[nPosDicFld][2],ValType(aUpdate[nX][4]),nX})
                    Endif
                Endif

            Case aUpdate[nX][1] == "SX7" 
                
                If ValType(aUpdate[nX][2]) <> 'N'
                    lRet := .F.
                    cMsgError := I18N("Type mismatch #1 -> #2 on aUpdate[#3][2].",{"N",ValType(aUpdate[nX][2]),nX})
                Endif
                If lRet
                    Do Case
                        Case aUpdate[nX][2] == 1    
                            //Needs to implement
                        Case aUpdate[nX][2] == 3   
                            //Needs to implement
                        Case aUpdate[nX][2] == 2 
                            If ValType(aUpdate[nX][3]) <> 'A'
                                lRet := .F.
                                cMsgError := I18N("The structure expected is not an array. Position aUpdate[#2][2].",{nX})
                            Endif

                            If lRet .And. Len(aUpdate[nX][3]) < 2
                                lRet := .F.
                                cMsgError := I18N("Array out of bounds: aUpdate[#1][3] = Size #2 of #3.",{nX,2,Len(aUpdate[nX][3])})
                            Endif
                            
                            If lRet .And. ValType(aUpdate[nX][3][1]) <> 'C'
                                lRet := .F.
                                cMsgError := I18N("Type mismatch #1 -> #2 on aUpdate[#3][3][1].",{"C",ValType(aUpdate[nX][3][1]),nX})
                            EndIf

                            If lRet .And. ValType(aUpdate[nX][3][2]) <> 'C'
                                lRet := .F.
                                cMsgError := I18N("Type mismatch #1 -> #2 on aUpdate[#3][3][2].",{"C",ValType(aUpdate[nX][3][1]),nX})
                            EndIf
                            SX7->(DbSetOrder(1))
                            If lRet .And. !SX7->(DbSeek(aUpdate[nX][3][1]+aUpdate[nX][3][2]))
                                lRet := .F.
                                cMsgError := I18N("The key {X7_CAMPO,X7_SEQUENC} #1+#2 was not found in SX7 table. Position aUpdate[#3][3].",{aUpdate[nX][3][1],aUpdate[nX][3][2],nX})
                            Endif

                            If lRet .And.ValType(aUpdate[nX][4]) <> 'C'
                                lRet := .F.
                                cMsgError := I18N("Type mismatch #1 -> #2 on aUpdate[#3][4].",{"C",ValType(aUpdate[nX][4]),nX})
                            EndIf

                            If lRet 
                                aDicStru := SX7->(DbStruct())
                                nPosDicFld := Ascan(aDicStru, {|x| x[1] == aUpdate[nX][4] })
                                If  !(nPosDicFld > 0)
                                    lRet := .F.
                                    cMsgError := I18N("The field #1 was not found in SX3 table structure. Position aUpdate[#2][4].",{aUpdate[nX][4],nX})
                                EndIf
                            Endif
                            
                            If lRet 
                                If aDicStru[nPosDicFld][2] <> ValType(aUpdate[nX][5])
                                    lRet := .F.
                                    cMsgError := I18N("Type mismatch #1 -> #2 on aUpdate[#3][5].",{aDicStru[nPosDicFld][2],ValType(aUpdate[nX][5]),nX})
                                Endif
                            Endif                          

                        Otherwise
                            lRet:= .F.
                            cMsgError := I18N("The array content of aUpdate[#1][1] does not correspond a valid instruction.",{nX})
                    EndCase
                Endif

                 Case aUpdate[nX][1] == "SXA"
                    If lRet .And. ValType(aUpdate[nX][3][1]) <> 'C'
                        lRet := .F.
                        cMsgError := I18N("Type mismatch #1 -> #2 on aUpdate[#3][3][1].",{"C",ValType(aUpdate[nX][3][1]),nX})
                    EndIf

                    If lRet .And. ValType(aUpdate[nX][3][2]) <> 'C'
                        lRet := .F.
                        cMsgError := I18N("Type mismatch #1 -> #2 on aUpdate[#3][3][2].",{"C",ValType(aUpdate[nX][3][1]),nX})
                    EndIf
            Otherwise
                lRet:= .F.
                cMsgError := I18N("The array content of aUpdate[#1][1] does not correspond a valid dictionary update instruction.",{nX})
        EndCase 
    Endif
    nX++
End


Return {lRet,cMsgError}
/*/
{Protheus.doc} InitMessage()
    
@type  Function
@author Flavio Lopes Rasta
@since 04/07/2018
@version 12.1.19 Russia R5
@return aUpdate, array , Array with the fields structures to update
/*/
Static Function InitMessage(oPanel)
Local oTMultiget1   as Object
Local cText         as Character

oTMultiget1 := Nil
cText       := ""

cText := "This program will update the data dictionary (SX3) based on the source code UPDRUS.PRW" + CRLF
cText += "Click in NEXT to commit the changes." + CRLF

oTMultiget1 := tMultiget():new(20,20,{| u | if( pCount() > 0, cText := u, cText )},oPanel,324,168,,,,,,.T.)

Return .T.

/*/
{Protheus.doc} Process()
    
@type  Function
@author Flavio Lopes Rasta
@since 04/07/2018
@version 12.1.19 Russia R5
/*/
Static Function Process(oPanel, aUpdate, lExec, lFim, cMsgError)
Local nX        as Numeric
Local nMeter1   as Numeric
Local cText     as Character

cText := ""

If lExec
    cText := "Processing, please wait..."
Else
    cText := "The program have found errors." 
    cText += CRLF + CRLF + CRLF + "Click in NEXT to see the log..." 
Endif
oTMultiget1 := tMultiget():new(20,20,{| u | if( pCount() > 0, cText := u, cText )},oPanel,324,128,,,,,,.T.)

nMeter1 := 0
oMeter1 := TMeter():New(170,20,{|u|if(Pcount()>0,nMeter1:=u,nMeter1)},Len(aUpdate),oPanel,324,15,,.T.) 

If lExec
    lExec := Perform(aUpdate,@oMeter1,@oTMultiget1,@cMsgError)
    If !lExec
        oTMultiget1:AppendText(CRLF + CRLF + CRLF + "The program have found errors.")
        oTMultiget1:AppendText(CRLF + CRLF + CRLF + "Click in NEXT to see the log..." )
    Endif
Else
    oMeter1:Set(100)
    sleep(100)
Endif

lFim := .F.

Return .T.

/*/
{Protheus.doc} Perform()
    
@type  Function
@author Flavio Lopes Rasta
@since 04/07/2018
@version 12.1.19 Russia R5
/*/
Static Function Perform(aUpdate, oMeter1, oText, cMsgError)
Local nX        as Numeric
Local cTabName  as Character
Local nTopErr   as Numeric
Local aTabBkps  as Array
Local lContinue as Logical

lContinue   := .T.
aTabBkps    := {}


For nX:= 1 to Len(aUpdate)
    Do Case
        Case aUpdate[nX][1] == "SX3"
            oMeter1:Set(nX)
            cTabName    := ""
            SX3->(DbSetOrder(2))
            SX3->(DbSeek(aUpdate[nX][2]))
            If SX3->(&(aUpdate[nX][3])) <> aUpdate[nX][4]
                If aUpdate[nX][3] == "X3_TAMANHO" .Or. aUpdate[nX][3] == "X3_TIPO" .Or. aUpdate[nX][3] == "X3_DECIMAL" .Or. aUpdate[nX][3] == "X3_CONTEXT"
                    cTabName := GetTabName(aUpdate[nX][2])
                    If !(Ascan(aTabBkps, {|x| x == cTabName }) > 0)        
                        aAdd(aTabBkps,cTabName) 
                    EndIf
                Endif
                RecLock("SX3",.F.)
                SX3->(&(aUpdate[nX][3])) := aUpdate[nX][4]
                SX3->(MsUnlock())
            Endif
        Case aUpdate[nX][1] == "SX7"
            If aUpdate[nX][2] == 2  .OR. aUpdate[nX][2] == 3
                SX7->(DbSetOrder(1))
                If SX7->(DbSeek(aUpdate[nX][3][1]+aUpdate[nX][3][2]))
                    If (SX7->(&(aUpdate[nX][4])) <> aUpdate[nX][5])
                        RecLock("SX7",.F.)
                        SX7->(&(aUpdate[nX][4])) := aUpdate[nX][5]
                        SX7->(MsUnlock())
                    Endif
                EndIf
            ElseIf  aUpdate[nX][2] == 1	//Insert
                SX7->(DbSetOrder(1))
                If !(SX7->(DbSeek(aUpdate[nX][3][1]+aUpdate[nX][3][2])))
                    RecLock("SX7",.T.)
                    SX7->X7_CAMPO := aUpdate[nX][3][1]
                    SX7->X7_SEQUENC := aUpdate[nX][3][2]
                    SX7->(&(aUpdate[nX][4])) := aUpdate[nX][5]
                    SX7->(MsUnlock())
                EndIf
            EndIf
        Case aUpdate[nX][1] == "SXA" // Folders
            //SXA->(DbSetOrder(1))
            cQuery := "SELECT 'R_E_C_N_O_' FROM "+ MPSysSqlName("SXA")
            cQuery += " WHERE XA_ALIAS = " + Chr(39) + aUpdate[nX][3][1] + Chr(39)
            cQuery += " AND XA_ORDEM = " + Chr(39) + aUpdate[nX][3][2] + Chr(39)
            cQuery += " AND XA_TIPO = ''"

            //cTabSXA := MPSysOpenQuery(cQuery)   
            cTabSXA:= GetNextAlias()
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSXA,.T.,.F.)
            dbSelectArea("SXA")
            Do Case
                Case aUpdate[nX][2] == 2  .OR. aUpdate[nX][2] == 3 // Insert/Update
                    If (!(cTabSXA)->(Eof()))
                        If (SXA->(DbSeek(aUpdate[nX][3][1]+aUpdate[nX][3][2])))
                            RecLock("SXA",.F.)
                            SXA->(&(aUpdate[nX][4])) := aUpdate[nX][5]
                            SXA->(MsUnlock())
                        EndIf
                    EndIf
                Case  aUpdate[nX][2] == 1	//Insert
                    If (cTabSXA)->(Eof())
                        If (!(SXA->(dbSeek(aUpdate[nX][4] + aUpdate[nX][5]))))
                            RecLock("SXA",.T.)
                            SXA->XA_ALIAS := aUpdate[nX][3][1]
                            SXA->XA_ORDEM := aUpdate[nX][3][2]
                            SXA->(&(aUpdate[nX][4])) := aUpdate[nX][5]
                            SXA->(MsUnlock())
                        EndIf
                    EndIf
            EndCase
            DbCloseArea()
    EndCase
Next nX

oMeter1:Set(Len(aUpdate))

If !Empty(aTabBkps)
    oMeter1:SetTotal(Len(aTabBkps))
    oMeter1:Set(0)
    oText:AppendText(CRLF+CRLF+CRLF+"Processing Backup/Restore tables...")
    
    For nX:=1 to Len(aTabBkps)
        __SetX31Mode(.F.)
        X31UPDTABLE(aTabBkps[nX]) 
        If __GetX31Error()
                lContinue := .F. 
                cMsgError := __GetX31Trace()
                __SetX31Mode(.T.) 
                Exit
        Else
            DbSelectArea(aTabBkps[nX])
            (aTabBkps[nX])->(DbCloseArea())
        EndIf
        __SetX31Mode(.T.)   
    Next nX

    oMeter1:Set(Len(aTabBkps))
EndIf

If lContinue
    oText:AppendText(CRLF+CRLF+CRLF+"Succesfully finished, Click in NEXT to see the log.")
Endif
Return lContinue

/*/
{Protheus.doc} Status()
    
@type  Function
@author Flavio Lopes Rasta
@since 04/07/2018
@version 12.1.19 Russia R5
/*/
Static Function Status(oPanel,lExec, cMsgError, aUpdate)
Local oTMultiget1   as Object
Local cText         as Character 
Local nX            as Numeric

cText := ""

If lExec
    cText := "Done!" 
    cText += CRLF + "Updates:" + CRLF
    For nX:= 1 to Len(aUpdate)
        Do Case
            Case aUpdate[nX][1] == "SX3"
                cText += + CRLF + "   " + "SX3 -> " + aUpdate[nX][2]
            Case aUpdate[nX][1] == "SX7"
                cText += + CRLF + "   " + "SX7 -> "+ aUpdate[nX][3][1] + "+" + aUpdate[nX][3][2]
            Case aUpdate[nX][1] == "SXA"
                cText += + CRLF + "   " + "SXA -> "+ aUpdate[nX][3][1] + "+" + aUpdate[nX][3][2]
        EndCase
    Next
Else
    cText := "Error:" 
    cText +=  CRLF +  CRLF + cMsgError
    cText +=  CRLF +  CRLF + "Check the source code UPDRUS.PRW to fix it."
Endif

oTMultiget1 := tMultiget():new(20,20,{| u | if( pCount() > 0, cText := u, cText )},oPanel,324,168,,,,,,.T.)

Return .T.

/*/
{Protheus.doc} GetTabName()
    
@type  Function
@author Flavio Lopes Rasta
@since 04/07/2018
@version 12.1.19 Russia R5
/*/
Static Function GetTabName(cField)
Local cTabName as Character

cTabName := SubStr(cField,1,At("_",cField)-1)

If Len(cTabName) < 3
    cTabName := "S" + cTabName
Endif

Return cTabName
// Russia_R5
