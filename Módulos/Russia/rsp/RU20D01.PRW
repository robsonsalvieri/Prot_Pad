#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ru20d01rus.CH"



/*/{Protheus.doc} RU20D01()
    Creating directory fields.

    @type Function
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01()

    Local oBrowse as object
    Local aArea := GetArea()
    Local a310nField as Array
    
    Private aRotina

    a310nField	:= {"F6I_CODIGO","F6I_DESC", "F6I_SHOWMA","F6I_PROCES"} 
	aHeader	:= gp310aHead(a310nField,"F6I")

    DbSelectArea('F6I')
    F6I->(dbSetOrder(1))
    
    aRotina := MenuDef()
    oBrowse := BrowseDef()
    oBrowse:Activate()

    RestArea(aArea)

Return Nil



/*/{Protheus.doc} ModelDef()
    Model for RU20D01 routine.

    @type Function
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Static Function ModelDef()

    Local oModel As Object
    Local oMaster := FWFormStruct(1,'F6K')
    Local oStruF6I	:= FWFormStruct(1,'F6I')
    Local oEvent As Object

    oModel := MPFormModel():New('RU20D01')

    oMaster:AddTable('MASTER_F6I',,'MASTER_F6I')

    oMaster:AddField("NTABLE","","NTABLE","C",GetSX3Cache("F6I_CODIGO","X3_TAMANHO"),0,FwBuildFeature( STRUCT_FEATURE_VALID, 'NaoVazio() .and. ExistChav("F6I", M->NTable,1) .and. FreeForUse("F6I",M->NTable) '),;
            /*When*/,,.F.,/* */,/*Key*/,IIf(oModel:nOperation == MODEL_OPERATION_INSERT,.F.,.T.),.T.,)

    oMaster:AddField("DTABLE","","DTABLE","C",GetSX3Cache("F6I_DESC","X3_TAMANHO"),0,FwBuildFeature( STRUCT_FEATURE_VALID, 'NAOVAZIO()'),;
            /*When*/,,.F.,,/*Key*/,IIf(oModel:nOperation == MODEL_OPERATION_INSERT,.F.,.T.),.T.,)
    
    oModel:AddFields('MASTER_F6I', /*cOwner*/, oMaster , , ,{|o|{}} )
    oModel:AddGrid('GRID_F6I','MASTER_F6I',oStruF6I)

    oModel:SetPrimaryKey( {} )
    oModel:SetRelation('GRID_F6I', {{'F6I_FILIAL','xFilial("F6I")'}, {'F6I_CODIGO','F6I->F6I_CODIGO'}})
    oModel:GetModel('MASTER_F6I'):SetOnlyQuery(.T.)
    oEvent := RU20D01Event():New()

    oStruF6I:SetProperty( "F6I_TAMAN",MODEL_FIELD_WHEN,FwBuildFeature( STRUCT_FEATURE_WHEN, ".T."))
    oStruF6I:SetProperty( "F6I_TIPO",MODEL_FIELD_WHEN,FwBuildFeature( STRUCT_FEATURE_WHEN, ".T."))
    oStruF6I:SetProperty( "F6I_CODIGO",MODEL_FIELD_WHEN,FwBuildFeature( STRUCT_FEATURE_WHEN, ".F."))
    oStruF6I:SetProperty( "F6I_DESC",MODEL_FIELD_WHEN,FwBuildFeature( STRUCT_FEATURE_WHEN, ".F."))

    oModel:SetDescription(STR0001) 
    oModel:GetModel('MASTER_F6I'):SetOnlyQuery(.T.)
    oModel:InstallEvent("RU20D01_Event",, oEvent)
    
Return oModel


/*/{Protheus.doc} ViewDef()
    View for RU20D01 routine.

    @type Function
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Static Function ViewDef()

    Local oStrVirt As Object

    Local oModel := FWLoadModel('RU20D01')
    Local oView := FWFormView():New()
    Local oStruF6I := FWFormStruct(2,'F6I')
    
    oView:SetModel(oModel)
    oStrVirt := FWFormStruct(2,'F6K')

    oStrVirt:RemoveField("F6K_FILIAL")
    oStrVirt:RemoveField("F6K_CODIGO")
    oStrVirt:RemoveField("F6K_FIL")
    oStrVirt:RemoveField("F6K_CHAVE")
    oStrVirt:RemoveField("F6K_SEQUEN")
    oStrVirt:RemoveField("F6K_CONTEU")

    oStruF6I:RemoveField("F6I_PADRAO")
    oStruF6I:RemoveField("F6I_VERSAO")
    oStruF6I:RemoveField("F6I_SHOWMA")
    oStruF6I:RemoveField("F6I_PESQ")
    oStruF6I:RemoveField("F6I_MODULO")
    oStruF6I:RemoveField("F6I_PROCES")
    oStruF6I:RemoveField("F6I_CODIGO")
    oStruF6I:RemoveField("F6I_DESC")
    oStruF6I:RemoveField("F6I_ORDEM")

    oStrVirt:AddField("NTABLE","01",RU07XFUN22_GetSx3Translations("F6I_CODIGO"),"Num Table",{"Num Table"},"C","@!",Nil,Nil,.T.,Nil)
    oStrVirt:AddField("DTABLE","02",RU07XFUN22_GetSx3Translations("F6I_DESC"),"Des Table",{"Des Table"},"C","@!",Nil,Nil,.T.,Nil)

    oView:AddField('MASTER_F6I', oStrVirt, 'MASTER_F6I')
    oView:AddGrid('GRID_F6I', oStruF6I, 'GRID_F6I')

    oView:CreateHorizontalBox('MASTER_F6I' ,10) 
    oView:CreateHorizontalBox('GRID_F6I' ,90) 

    oView:SetOwnerView('MASTER_F6I' ,'MASTER_F6I' )	
    oView:SetOwnerView('GRID_F6I' ,'GRID_F6I')

    oView:SetCloseOnOk({||.T.})

    oView:SetCloseOnOk({ || .T. }) 

Return oView




/*/{Protheus.doc} MenuDef()
    Menu for RU20D01 routine.

    @type Function
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Static Function MenuDef()

Local aRotina :=  {}

    aAdd( aRotina, { STR0003, 'VIEWDEF.RU20D01', 0, 2, 0, NIL } ) // View
    aAdd( aRotina, { STR0004, 'VIEWDEF.RU20D01', 0, 3, 0, NIL } ) // Add
    aAdd( aRotina, { STR0005, 'VIEWDEF.RU20D01', 0, 4, 0, NIL } ) // Edit
    aAdd( aRotina, { STR0006, 'VIEWDEF.RU20D01', 0, 5, 0, NIL } ) // Delete

Return aRotina



/*/{Protheus.doc} BrowseDef()
    Browse for RU20D01 routine.

    @type Function
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Static Function BrowseDef()

Local oBrowse as Object

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F6I") 
    oBrowse:SetDescription(STR0001)
    oBrowse:SetFilterDefault("F6I->F6I_ORDEM == '01'")

Return oBrowse



/*/{Protheus.doc} RU20D01016()
    Displays F6K Table Search Screen.

    @type Function
    @param cTabela, Name table.
           cCpoRet, CPO.
           cFiltro, Character, Filter.
           cCpo2, Character
           lFilial, Logical
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01016( cTabela, cCpoRet, cFiltro, cCpo2, lFilial )
Local aArea        := GetArea()
Local nOpca:=0, i,lAllOk
Local oDlg, cCampo, nX, nY, cCaption, cPict, cValid, cF3, cWhen, nLargSay,  oSay, oGet
Local cBlkGet,cBlkWhen,cBlkVld, oSaveGetdad := Nil, aSvRot := Nil
Local oTop
Local aObject := {}              
Local aSize := {}
Local nObject
Local aCordW := {125,0,450,635}      
Local cSvField    := &(ReadVar())
Local nCount := 0
Local cMyCpo := ""
Local cLineOk := "AllwaysTrue()"
Local cAllOk  := "AllwaysTrue()"
Local nOpcx    := 7
Local aCGD    := {}
Local lExist := .F.
Local nCpoRet := 0
Local cPesq := Space(30)
Local nCntCmb := 0
Local nMaxCmb := 5    //# Maximum number of options in the Combo
Local nPos         := At("+", cCpoRet )  
Local cCpoAux    := ""
Local cF6ICampo    := ""
Local cF6IDescr    := ""
Local cDescr    := ""
Local lContin as logic

Private cCombo  := ""
Private aCombo  := {}
Private aMyCombo:= {}
Private aSXBCols   := {}
Private aSXBHeader := {}
Private nUsado  := 0

Private cFilF6I  := ""
Private cFilF6K  := ""
Private cDescF6K := ""
Private lPesqComp := .F. //Variable that indicates whether the search is being done with more than one field

Default cFiltro := ""
Default cCpo2    := ""
Default lFilial    := .T.

lContin := .T.

If cTabela == NIL .Or. cCpoRet == NIL
    MsgAlert(OemToAnsi(STR0049),OemToAnsi(STR0014))    // "It is not possible to continue because there are missing parameters in this function!!!"##"Attention!"
    lContin := .F. //Return(.F.)
EndIf

If lContin
    If nPos > 0
        lPesqComp := .T.
    EndIf

    //# Posiciona no F6I
    dbSelectArea("F6I")
    dbSetOrder(1)

    If !dbSeek(xFilial("F6I")+cTabela,.F.)
        MsgAlert(OemToAnsi(STR0050),OemToAnsi(STR0014))    // "The Table informed does not exist !!!"##"Attention!"
        lContin := .F. //Return(.F.)
    EndIf

    If lContin
        
        cFilF6I  := xFilial("F6I")
        cDescF6K := Alltrim(F6I_DESC)

        //# Posiciona no F6K
        dbSelectArea("F6K")
        dbSetOrder(1)

        If !RU20D01020(cTabela)//!dbSeek(xFilial("F6K")+cTabela,.F.)
            MsgAlert(OemToAnsi(STR0051) + cTabela,OemToAnsi(STR0014) )    // "There is no information registered in the table "##"Attention!"    
            lContin := .F. //Return(.F.)
        EndIf

        If lContin
            //-- Checks whether it was called by the GPEM080 function and filters the results by the parameters entered in the routine
            cFilF6K := xFilial("F6K")

            RU20D01022( cTabela, cCpoRet )
            RU20D01025( cTabela, cCpoRet, , cFiltro, lFilial )

            //# Variables initialized in the test
            Private cTitulo := cTabela+" - "+cDescF6K //#"U014 - Teste"
            Private nMax := Len(aSXBCols)
            Private aC := {}
            Private aColsBkp := aClone(aSXBCols)

            //# Variables initialized in the test
            aAdd(aC,{"cMyCpo", {15,001},"",,,,.F.,})

            nCount++
            __cLineOk := cLineOK
            __nOpcx     := nOpcx
            If nCount > 1
                oSaveGetdad := oGetDados
                oSaveGetdad:oBrowse:lDisablePaint := .t.
            EndIf

            oGets := {}
            If Type("aRotina") == "A"
                aSvRot := aClone(aRotina)
            EndIf

            aRotina := {}
            For nX := 1 to nOpcX
                AADD(aRotina,{"","",0,nOpcx})
            Next

            aCGD:=Iif(Len(aCGD)==0,{34,5,128,315},aCGD)

            DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) FROM aCordW[1],aCordW[2] TO aCordW[3],aCordW[4] PIXEL OF oMainWnd

            If Len(aC) > 0
                
                //# Assemble the Combo from the F6I Title
                dbSelectArea("F6I")
                dbSeek(xFilial("F6I")+cTabela,.F.)
                
                While F6I->(!EOF()) .And. F6I->(F6I_FILIAL+F6I_CODIGO) == (cFilF6I+cTabela)

                    //# Checks if the field already exists
                    If !lExist .And. ValType("F6I->F6I_PESQ")<>"U"
                        lExist := .T.
                    EndIf
                    
                    //# Mount or aCombo and aMyCombo
                    If !lExist .Or. (lExist .And. F6I->F6I_PESQ=="1")
                        nCntCmb += 1
                        aAdd( aCombo    , Alltrim(Capital(F6I_DESCPO)) )
                        aAdd( aMyCombo, {Alltrim(Capital(F6I_DESCPO)),Alltrim(F6I_CAMPOS)} )
                        If lPesqComp .And. At(Alltrim(F6I_CAMPOS), cCpoRet) > 0
                            cF6IDescr += Alltrim(Substr(Capital(F6I_DESCPO),1,9)) + '+'
                            cF6ICampo += Alltrim(F6I_CAMPOS) + '+'
                        EndIf
                        If nCntCmb >= nMaxCmb
                            Exit
                        EndIf
                    EndIf
                    F6I->(dbSkip())
                EndDo
                If lPesqComp
                    cF6IDescr := Substr(cF6IDescr, 1, Len(cF6IDescr)-1)
                    cF6ICampo := Substr(cF6ICampo, 1, Len(cF6ICampo)-1)
                    nCntCmb += 1
                    aAdd( aCombo, Alltrim(cF6IDescr) )
                    aAdd( aMyCombo, {Alltrim(cF6IDescr),Alltrim(cF6ICampo)} )
                EndIf       

                dbSelectArea("F6K")
                
                oTop:= TPanel():Create(oDlg,01,102,"",,.F.,,,,100,100)    
                
                Aadd(aSize,aCGD[1]+16)
                Aadd(aObject,oTop)
                nObject := 2
                
                Private oCombo, oPesq, oBtn1, oCheckBox, lCheck
                
                @ 003,005 SAY OemToAnsi(STR0052) SIZE 35,10 OF oTop PIXEL    // "Search for: "
                @ 010,005 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 125,12 OF oTop PIXEL
                @ 010,140 CHECKBOX oCheckBox VAR lCheck PROMPT OemToAnsi(STR0053) VALID Iif(!Empty(cCombo),RU20D01017(),RU20D01024()) SIZE 55,10 OF oTop PIXEL    // "Order"
                @ 010,180 MSGET oPesq VAR cPesq PICTURE "@!" VALID Iif(!Empty(cCombo),RU20D01026(cPesq),RU20D01024()) SIZE 115,10 OF oTop PIXEL
                @ 021,585 BTNBMP oBtn1 RESOURCE "FWSKIN_ICON_LOOKUP" SIZE 025,025 OF oTop PIXEL ACTION ( RU20D01026(cPesq) )
                
                For i:=1 to Len(aC)
                    cCampo:=aC[i,1]
                    nX:=aC[i,2,1]-13
                    nY:=aC[i,2,2]
                    cCaption:=Iif(Empty(aC[i,3])," ",aC[i,3])
                    cPict:=Iif(Empty(aC[i,4]),Nil,aC[i,4])
                    cValid:=Iif(Empty(aC[i,5]),".t.",aC[i,5])
                    cF3:=Iif(Empty(aC[i,6]),NIL,aC[i,6])
                    cWhen    := Iif(aC[i,7]==NIL,".t.",Iif(aC[i,7],".t.",".f."))
                    cWhen    := Iif(!(Str(nOpcx,1,0)$"346"),".f.",cWhen)
                    cBlKSay  := "{|| OemToAnsi('"+cCaption+"')}"
                    
                    oSay     := TSay():New( nX+1, nY, &cBlkSay,oTop,,, .F., .F., .F., .T.,,,,, .F., .F., .F., .F., .F. )
                    nLargSay := GetTextWidth(0,cCaption) / 1.8  
                    cCaption := oSay:cCaption
                    
                    cBlkGet  := "{ | u | If( PCount() == 0, "+cCampo+","+cCampo+":= u ) }"
                    cBlKVld  := "{|| "+cValid+"}"
                    cBlKWhen := "{|| "+cWhen+"}"
                                
                    oGet := TGet():New( nX, nY+nLargSay,&cBlKGet,oTop,,,cPict, &(cBlkVld),,,, .F.,, .T.,, .F., &(cBlkWhen), .F., .F.,, .F., .F. ,cF3,(cCampo))
                    AADD(oGets,oGet)
                Next
            EndIf

            oGetDados := MsNewGetDados():New(aCGD[1],;// nTop
                                            aCGD[2],;       // nLelft
                                            aCGD[3],;    // nBottom
                                            aCGD[4],;    // nRright
                                            nOPCX,;            // control of what can be done in GetDate - style
                                            "RU20D01018()",;    // function to validate line editing - ulinhaOK
                                            "AllwaysTrue()",;    // function to validate all GetDados records - ouTloOK
                                            NIL,;                // cIniCPOS
                                            NIL,;                // aAlter
                                            0,;                 // nfreeze
                                            nMax,;              // nMax
                                            NIL,;                 // cFieldOK
                                            NIL,;                // usuperdel
                                            .F.,;                // udelOK
                                            @oDlg,;            // dialogue object - oWnd
                                            @aSXBHeader,;        // Vector with Columns - AparHeader
                                            @aSXBCols;            // Vector with Header - AparCols
                                )

            Aadd(aObject,oGetDados:oBrowse)
            Aadd(aSize,NIL)

            ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,lAllOk:=RU20D01019(cAllOk),;
                                                        IIF(lAllOk,oDlg:End(),nOpca:=0)},{||oDlg:End()},,),;
                                                        AlignObject(oDlg,aObject,1,nObject,aSize),oGetDados:oBrowse:Refresh())

            nCount--
            If nCount > 0
                oGetDados := oSaveGetDad
                oGetDados:oBrowse:lDisablePaint := .f.
            EndIf
            If ValType(aSvRot) == "A"
                aRotina := aClone(aSvRot)
            EndIf

            If nOpca == 1 .and. Len(aSXBCols)>0
                If !lPesqComp
                    nCpoRet := GdFieldPos(cCpoRet, aSXBHeader)
                    VAR_IXB  := aSXBCols[oGetDados:nAt,nCpoRet]
                    
                    If !Empty(cCpo2)
                        Var_IXB := {}
                        aadd(VAR_IXB,aSXBCols[oGetDados:nAt,nCpoRet])
                        nCpoRet := GdFieldPos(cCpo2, aSXBHeader)
                        cDescr := aSXBCols[oGetDados:nAt,nCpoRet]
                        aadd(VAR_IXB,cDescr)
                    EndIf
                    If Funname() == 'RU20D02' 
                        &(ReadVar()) := VAR_IXB
                    EndIf
                    
                    
                Else         
                    VAR_IXB := ""    
                    While lPesqComp
                        cCpoAux := Substr(cCpoRet, 1, nPos - 1)
                        cCpoRet := Substr(cCpoRet, nPos +1)    

                        nCpoRet := GdFieldPos(cCpoAux, aSXBHeader)
                        VAR_IXB += aSXBCols[oGetDados:nAt,nCpoRet]

                        nPos := At("+", cCpoRet )
                        lPesqComp := If (nPos > 0, .T., .F.)
                        
                        If nPos == 0
                            nCpoRet := GdFieldPos(cCpoRet, aSXBHeader)
                            VAR_IXB += aSXBCols[oGetDados:nAt,nCpoRet]
                        EndIf
                    EndDo
                    
                    If Funname() == 'RU20D02' 
                        &(ReadVar()) := VAR_IXB
                    EndIf
                    
                    If !Empty(cCpo2)
                        cDescr := VAR_IXB
                        Var_IXB := {}
                        aadd(VAR_IXB,cDescr)
                        nCpoRet := GdFieldPos(cCpo2, aSXBHeader)
                        cDescr := aSXBCols[oGetDados:nAt,nCpoRet]
                        aadd(VAR_IXB,cDescr)
                    EndIf
                EndIf
            Else
                If !Empty(cCpo2)
                    Var_IXB := {}
                    aadd(VAR_IXB,cSvField)
                    aadd(VAR_IXB,"")
                Else
                    VAR_IXB := cSvField
                EndIf
                RestArea(aArea)
                Return .T.
            EndIf

            RestArea( aArea )
        EndIf
    EndIf
EndIf

Return IIf( lContin, (nOpca == 1), lContin)




/*/{Protheus.doc} RU20D01020()
    Checks if there are valid records in the query for this branch.

    @type Function
    @param cCodTab, Character, Code table.
           
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01020(cCodTab)
    
    Local lRet        := .F.
    Local cFOrigem    := ""
    Local cF6KAlias := GetNextAlias()
    
    If __READVAR == "M->CODFOR"           //F3 QUERY FROM AN SNNN TABLE
        cFOrigem := aCols[n][1]
    Else
        cFOrigem := cFilAnt    
    EndIf
    
    F6K->(dbSetOrder(1))    // F6K_FILIAL + F6K_CODIGO + F6K_FIL + F6K_CHAVE + F6K_SEQUEN
    F6K->(dbSeek(xFilial("F6K")+cCodTab))
    
    BeginSql Alias cF6KAlias
        SELECT  F6K.*   FROM     %table:F6K% F6K 
                WHERE F6K.F6K_CODIGO   = %Exp:(cCodTab)%  AND F6K.%NotDel%  
    EndSql
        
    While (cF6KAlias)->(!Eof()) .and. !lRet
        
        If Empty((cF6KAlias)->(F6K_FIL)) .or. (cF6KAlias)->(F6K_FIL) == cFOrigem
            lRet := .T.
            F6K->(DbGoto( (cF6KAlias)->(R_E_C_N_O_) ))    
        EndIf
            
        (cF6KAlias)->(DBSkip())
    End
        
    (cF6KAlias)->(DBCloseArea())
    
Return lRet




/*/{Protheus.doc} RU20D01022()
    Array the aHeader of the F6L Table Search Screen.

    @type Function
    @param cTabela, Character, Code table.
           cPesqComp, Character, Field name.
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01022(cTabela, cPesqComp)
Local aArea            := GetArea()
Local nQtdCol        := 99
Local nTamAux        := 0   
Local cTitSeq        := ""
Default cPesqComp    := ""

dbSelectArea("F6I")

nUsado:=0
aSXBHeader:={}

cTitSeq    := RU20D01021()

//# Creates F6K_SEQUEN field
nUsado += 1
aAdd(aSXBHeader,{     cTitSeq, ;        //# 01
                "F6K_SEQUEN", ;    //# 02
                "@!", ;            //# 03
                3, ;            //# 04
                0, ;            //# 05
                NIL, ;            //# 06
                NIL, ;            //# 07
                "C", ;            //# 08
                NIL,  ;             //# 09
                "R" } )            //# 10 Real or Virtual

While F6I->(!EOF()) .And. F6I->(F6I_FILIAL+F6I_CODIGO) == (cFilF6I+cTabela)
                        //Alltrim(F6I_VALID), ;            //# 06    
    If nUsado > nQtdCol
        Exit
    Else
        nUsado += 1
        aAdd(aSXBHeader,{Alltrim(Capital(F6I_DESCPO)), ;    //# 01
                        Alltrim(F6I_CAMPOS), ;            //# 02
                        Alltrim(F6I_PICTUR), ;            //# 03
                        F6I_TAMAN, ;                    //# 04
                        F6I_DECIMA, ;                    //# 05
                        NIL, ;                            //# 06
                        NIL, ;                            //# 07
                        F6I_TIPO, ;                        //# 08
                        NIL, ;                            //# 09
                        "R", ;                            //# 10 Real or Virtual
                         NIL, ;                            //# 11 cbox
                        NIL, ;                            //# 12 relacao
                        NIL, ;                            //# 13 when
                        "V" ;                            //# 14 view or change
                        } )                            
        If lPesqComp .And. At(Alltrim(F6I_CAMPOS), cPesqComp) > 0
            nTamAux += F6I_TAMAN
        EndIf
    EndIf
    F6I->(dbSkip())
EndDo
If lPesqComp
    nUsado += 1
    aAdd(aSXBHeader,{Alltrim(Capital(F6I_DESCPO)), ;    //# 01
                    Alltrim(cPesqComp), ;            //# 02
                    "!@",                 ;            //# 03
                    nTamAux, ;                        //# 04
                    NIL, ;                            //# 05
                    NIL, ;                            //# 06
                    NIL, ;                            //# 07
                    NIL, ;                            //# 08
                    NIL, ;                            //# 09
                    "V", ;                            //# 10 Real or Virtual
                    NIL, ;                            //# 11 cbox
                    NIL, ;                            //# 12 relacao
                    NIL, ;                            //# 13 when
                    "V" ;                            //# 14 view or change
                    } )                            
EndIf

RestArea( aArea )

Return




/*/{Protheus.doc} RU20D01025()
    Mount aCols from the F6L Table Search Screen.

    @type Function
    @param cTabela, Character, Code table.
           cCpoPesq, Character, Field name.
           cCpoFiltro, Character, Field filter.
           cFiltro, Character, filter.
           lFilial, Character, Logic.
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01025( cTabela, cCpoPesq, cCpoFiltro, cFiltro, lFilial )
    
    Local aArea            := GetArea()
    Local nCnt            := 0
    Local nQtdLin        := 7000
    Local uValor
    Local cFOrigem        := ""    
    Local nCpoAux1        := 1
    Local nCpoAux2        := 0
    Local cF6KAlias        := GetNextAlias()
    Default cCpoPesq    := ""
    Default cFiltro        := ""  
    Default cCpoFiltro    := ""
    Default lFilial        := .T.
    
    aSXBCols := {}
    
    If __READVAR == "M->CODFOR"            //F3 QUERY FROM AN SNNN TABLE
        cFOrigem := aCols[n][1]
    Else
        cFOrigem := cFilAnt
    EndIf
    
    nCont := 0
    nCpo1 := 1
    nCpo2 := 0
    
    If !Empty( cCpoFiltro ) .And. !Empty( cFiltro )
        For nCnt := 1 to Len(aSXBHeader)
            If Alltrim(aSXBHeader[nCnt,02]) != "F6K_SEQUEN" 
                nCpoAux2 := (aSXBHeader[nCnt,04] )
                If Alltrim(aSXBHeader[nCnt,02]) == cCpoFiltro
                    Exit
                Else  
                    nCpoAux1 += nCpoAux2            
                EndIf
            EndIf
        Next nCnt
    EndIf
    
    dbSelectArea( "F6K" )
    F6K->(dbSetOrder(1))    // F6K_FILIAL + F6K_CODIGO + F6K_FIL + F6K_CHAVE  + F6K_SEQUEN
    
    // Positions by table, branch treatment is already done within the loop
    F6K->( dbSeek( xFilial( "F6K" ) + cTabela  ) )
    
    BeginSql Alias cF6KAlias
        SELECT F6K.* FROM %table:F6K% F6K
        WHERE F6K.F6K_CODIGO = %Exp:(cTabela)% AND F6K.%NotDel% AND F6K.F6K_FILIAL = %Exp:(xFilial("F6K"))%
    EndSql
    
    While (cF6KAlias)->(! Eof()) .And. (cF6KAlias)->(F6K_CODIGO) == cTabela
    
        If (cF6KAlias)->(F6K_FIL) == cFOrigem .or. Empty((cF6KAlias)->(F6K_FIL)) .Or.;
        (IsInCallStack("GPEM080") .And. (cF6KAlias)->(F6K_FIL) >= MV_PAR04 .AND. (cF6KAlias)->(F6K_FIL) <= MV_PAR05)
            F6K->(DbGoto( (cF6KAlias)->(R_E_C_N_O_) ))
            
            If Empty( cFiltro ) .Or. Eval( cFiltro )        // If Empty( cFiltro ) .Or. ( SubStr( F6K_CONTEU, nCpoAux1, nCpoAux2 ) == cFiltro) 
                AADD(aSXBCols,Array(Len(aSXBHeader)+1))
        
                For nCnt := 1 To Len(aSXBHeader)

                    cCampo := Alltrim(aSXBHeader[nCnt,02])

                    If aSXBHeader[nCnt,10] == "R" .And. cCampo == "F6K_SEQUEN"
                        aSXBCols[Len(aSXBCols)][nCnt] := FieldGet(FieldPos(cCampo))
                    ElseIf lPesqComp .And. At("+", cCampo) > 0
                        aSXBCols[Len(aSXBCols)][nCnt] := cCpoPesq //cCpoAux        
                    Else
                            //#aSXBCols[Len(aSXBCols)][nCnt] := CriaVar(cCampo)
                        nCpo2 := (aSXBHeader[nCnt,04] )//+ aSXBHeader[nCnt,05])
                        If aSXBHeader[nCnt,08] == "N"
                            uValor := Val( SubStr(F6K_CONTEU,nCpo1,nCpo2) )
                        ElseIf aSXBHeader[nCnt,08] == "D"
                            uValor := If(Len(SubStr(F6K_CONTEU,nCpo1,nCpo2)) == 8, STOD(SubStr(F6K_CONTEU,nCpo1,nCpo2)), CTOD(SubStr(F6K_CONTEU,nCpo1,nCpo2)))
                        Else
                            uValor := SubStr(F6K_CONTEU,nCpo1,nCpo2)
                        EndIf
        
                        aSXBCols[Len(aSXBCols)][nCnt] := uValor
                        nCpo1 += nCpo2
                      EndIf
                Next nCnt
        
                aSXBCols[Len(aSXBCols)][nUsado+1] := .F.

                nCont += 1
                If nCont > nQtdLin
                    Exit
                EndIf
                nCpo1 := 1
            EndIf
        EndIf
        
        (cF6KAlias)->(dbSkip())
    EndDo
    
    (cF6KAlias)->(DBCloseArea())
    
    RestArea( aArea )

Return lfilial




/*/{Protheus.doc} RU20D01017()
    Sorts aCols according to the ComboBox chosen by the user, if CheckBos is selected

    @type Function
    @param 
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01017()
Local nCmbLin := aScan( aMyCombo, { |x| Alltrim(x[01]) == Alltrim(cCombo)} )
Local nPosCpo := 0
nPosCpo := GdFieldPos(aMyCombo[nCmbLin,02],aSXBHEADER)

If lCheck
    ASort(@aSXBCols,,,{|x,y| x[nPosCpo] < y[nPosCpo]})
    oGetDados:aCols := aClone(aSXBCols)
Else
    aSXBCols := aClone(aColsBkp)
EndIf
oGetDados:oBrowse:Refresh()
Return





/*/{Protheus.doc} RU20D01024()
    Displays an alert message when there is no field to search in the auxiliary table.

    @type Function
    @param 
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01024()

Alert(STR0055)    //-"The 'Search for:' search field cannot be empty!!!"

Return(.F.)






/*/{Protheus.doc} RU20D01026()
    Locates the information entered by the user in the F6L Table Search Screen

    @type Function
    @param cPesq, Char, Field
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01026(cPesq)
Local nPosLin := 0
Local nPosCpo := 0    
Local nLenCmb := Len(Alltrim(cPesq))
Local nCmbLin := aScan( aMyCombo, { |x| Alltrim(x[01]) == Alltrim(cCombo)} )
nPosCpo := GdFieldPos(aMyCombo[nCmbLin,02],aSXBHeader) //GdFieldPos(aMyCombo[nCmbLin,02])

If nPosCpo > 0
    nPosLin := aScan( aSXBCols, { |x| Alltrim(cPesq) $ SubStr(Alltrim(UPPER(x[nPosCpo])),1,nLenCmb)} )
EndIf

If nPosLin >= 1
    oGetDados:oBrowse:nAt := nPosLin
    n:= nPosLin
EndIf
oGetDados:oBrowse:Refresh()
Return





/*/{Protheus.doc} RU20D01018()
    Team RH

    @type Function
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01018()
Local lRet:=.t. , ni
If Str(__nOpcx,1,0)$"346"
    lRet := &__cLineOK
    For ni:= 1 to Len(oGets)
        oGets[ni]:Refresh()
    Next
EndIf
Return lRet





/*/{Protheus.doc} RU20D01019()
    Team RH

    @type Function
    @param cAllOK, logic
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01019(cAllOK)
Local lRet
lRet := RU20D01018()
If lRet
    lRet := &cAllOk
EndIf
Return lRet



/*/{Protheus.doc} RU20D01021()
    Returns title of field F6L_SEQUEN

    @type Function
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
function RU20D01021()
Local aArea:= GetArea()
Local aAreaSX3 := SX3->(GetArea())
Local cTitSeq    := ""

SX3->(dbSelectArea("SX3"))
SX3->(dbSetOrder(2))
If ( SX3->(DbSeek("F6K_SEQUEN")))
    cTitSeq := Alltrim(X3Titulo())
EndIf
RestArea(aAreaSX3)
RestArea(aArea)

Return(cTitSeq)





/*/{Protheus.doc} RU20D01Valid()
    FUNCTIONS USED BY SX3

    @type Function
    @param cAllOK, logic
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01Valid()

Local cCampo     := Substr(ReadVar(),4)
Local lRet        := .T.

cCodigo := F6I->F6I_CODIGO

If (cCampo == "F6I_TIPO") .Or. (cCampo == "F6I_TAMAN") .Or. (cCampo == "F6I_DECIMA")
    DbSelectArea("F6K")
    DbSetOrder(1)
    DbSeek( xFilial("F6I") + cCodigo, .F.)
    If ( F6K->( Eof() ) ) 
        lRet := .T.
    Else
        Help(" ",1,"A310DEL")
        lRet := .F.
    EndIf 
EndIf

Return( lRet )



/*/{Protheus.doc} ValidF6K()
    Check code in Table Registration

    @type Function
    @param cCodigo, Character, Code table.
           cConteudo, Character, Code table.
           nPos1, Numeric, pos. start.
           nPos2, Numeric, pos. end.
           lMsg, Logic, flag Massage.
           cFilF6K, Character, F6K filtr.
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function ValidF6K(cCodigo,cConteudo,nPos1,nPos2,lMsg,cFilF6K)
Local lRet := .F.
Local lExitFil := iif (!Empty(cFilF6K), .T., .F.)

Default lMsg := .T.

If nPos1 = Nil
    nPos1 := 0
EndIf
If nPos2 = Nil
    nPos2 := 0
EndIf

If cCodigo <> Nil .AND. cConteudo <> Nil    
    If(lExitFil)
        cFilF6K    := ""
        dbSelectArea( "F6K" )
        dbSetOrder(1)    
        dbSeek(xFilial("F6K") + cCodigo+cFilF6K)
        While F6K->(!Eof()) .AND. F6K->F6K_FILIAL+F6K_CODIGO+"" == xFilial("F6K")+cCodigo    
            If F6K->F6K_FILIAL+F6K_CODIGO == xFilial("F6K")+cCodigo .AND. ;
                Alltrim(Substr(F6K->F6K_CONTEU,nPos1,nPos2)) == Alltrim(cConteudo)
                lRet := .T.
                Exit
            EndIf
            F6K->(dBSkip())    
        EndDo
    Else
        cFilF6K    :=  ""
        dbSelectArea( "F6K" )
        dbSetOrder(1)
        dbSeek(xFilial("F6K")+ cCodigo+cFilF6K)
        While F6K->(!Eof()) .AND. F6K->F6K_FILIAL+F6K_CODIGO+cFilF6K == xFilial("F6K")+cCodigo+cFilF6K
            If F6K->F6K_FILIAL+F6K_CODIGO == xFilial("F6K")+cCodigo .AND. ;
                Alltrim(Substr(F6K->F6K_CONTEU,nPos1,nPos2)) == Alltrim(cConteudo)
                lRet := .T.
                Exit
            EndIf
            F6K->(dBSkip())
        EndDo
    EndIf
    If !lRet .And. lMsg
        Help(" ",1, "NOTAB")
    EndIf
EndIf

Return(lRet)





/*/{Protheus.doc} RU20D01014(cAlias,cAuxChave)
    Check code in Table Registration

    @type Function
    @param cCodigo, Character, Code table.
           cConteudo, Character, Code table.
           nPos1, Numeric, pos. start.
           nPos2, Numeric, pos. end.
           lMsg, Logic, flag Massage.
           cFilF6K, Character, F6K filtr.
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01014(cAlias,cAuxChave)
                                        
    Local lChaveOk    := .T.

    Local cFullName  As Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character

    Local aDataSign  As Array
    Local aRes       As Array
    Local cSQL       As Character

    aDataSign := {}
    aRes := {}
    cFullName := ""
    aArea := GetArea()

    If !Empty(cAuxChave)
        cSQL := "SELECT * FROM " + RetSqlName("F6I") + " WHERE F6I_FILIAL = ? AND F6I_CODIGO = ? AND F6I_CAMPOS = ? AND D_E_L_E_T_=' ' "
        oStatement := FWPreparedStatement():New(cSQL)
        oStatement:SetString(1, xFilial(cAlias))
        oStatement:SetString(2, F6I->F6I_CODIGO)
        oStatement:SetString(3, cAuxChave)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        
        If (cTab)->(!Eof())
           
            Help(" ",1,"A310CHADUP")
            lChaveOk := .F.
            
        Endif

        (cTab)->(DBCloseArea())

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)

Return lChaveOk



/*/{Protheus.doc} RU20D01011(nDecimal)
    Check code in Table Registration

    @type Function
    @param nDecimal, Character, Code type.

    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01011(nDecimal)

Local lCpoOk	:= .T. 

Return lCpoOK


/*/{Protheus.doc} RU20D01011(nDecimal)
    Check code in Table Registration

    @type Function
    @param nDecimal, Character, Code type.

    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Static Function gp310aHead(aFields,cAlias)

Private aTELA[0][0],aGETS[0],aHeader[0],nUsado:=0

aHeader := GdMontaHeader( 	NIL			,;	
						  	NIL			,;	
						  	NIL			,;	
							"F6I"		,;
							aFields		,;	
							NIL			,;	
							.T.			,;	
							NIL			,;	
							NIL			,;	
							.T.			,;	
							.T. 		,;	
							NIL			,;	
							.T.			 ;	
					   )

DbSelectArea( cAlias )
Return aHeader

/*/{Protheus.doc} RU20D01012(cTipo)
    Check cTipo in Table Registration

    @type Function
    @param cTipo, Character, Code type.

    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D01012(cTipo)

If 	cTipo == "D"
	M->F6I_TAMAN := 8
	M->F6I_DECIMA := 0
ElseIf cTipo == "C"
	M->F6I_DECIMA := 0
EndIf

RETURN .T.
