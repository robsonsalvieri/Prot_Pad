#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFA620.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA620
Importação XML Lucros e Dividendos R-4020
@author Jose Felipe
@since 19/10/2023
@version 1.0
@Return
/*/ 
//-------------------------------------------------------------------
Function TAFA620(oXml, cIdEvAdic, cError )

Local cFilTaf   as Character
Local cCodPar	as Character
Local cIdPar	as Character
Local cNIF	    as Character
Local cPerPur	as Character
Local cInscr	as Character
Local cCGC	    as Character
Local cIdTrib   as Character
Local cCodTrib  as Character
Local cIdNat    as Character
Local cNatRe    as Character
Local cDescNat  as Character
Local cTribNat  as Character
Local cDescTrib as Character
Local cIdPExt   as Character
Local cNomeExt	as Character
Local cNtRend	as Character
Local cNifBenef as Character
Local cRelFonPg as Character
Local cFrmTrib  as Character
Local cDscLogr  as Character
Local cNroLog   as Character
Local cCompExt  as Character
Local cBairExt  as Character
Local cCidaExt  as Character
Local cEstExt   as Character
Local cCepExt   as Character
Local cTelExt   as Character
Local cPaisExt  as Character
Local cIndNif   as Character
Local cNomePar  as Character
Local cInsMat   as Character
Local cDReFonPg as Character
Local nVlrBrt 	as Numeric
Local nVlrRnd 	as Numeric
Local nVlrIrf 	as Numeric
Local nI 		as Numeric
Local nCount    as Numeric
Local nL        as Numeric
Local nX        as Numeric
Local nJ        as Numeric
Local nQtdPgto  as Numeric
Local nPgto 	as Numeric
Local nVerIdBen as Numeric
Local aTable    as Array
Local aCampos   as Array
Local aArea 	as Array
Local aLoadFil  as Array
Local aRet   	as Array
Local lRet      as Logical
Local dDtPgto	as Date

Private cAliasTmp  as Character
Private oTable     as Object

//Variáveis do tipo caractere
cFilTaf   := ''
cCodPar   := ''
cIdPar    := ''
cNIF      := ''
cPerPur   := ''
cInscr    := ''
cCGC      := ''
cIdTrib   := ''
cCodTrib  := ''
cIdNat    := ''
cNatRe    := ''
cDescNat  := ''
cTribNat  := ''
cDescTrib := ''
cIdPExt   := ''
cNomeExt  := ''
cNtRend   := ''
cNifBenef := ''
cRelFonPg := ''
cFrmTrib  := ''
cDscLogr  := ''
cNroLog   := ''
cCompExt  := ''
cBairExt  := ''
cCidaExt  := ''
cEstExt   := ''
cCepExt   := ''
cTelExt   := ''
cPaisExt  := ''
cIndNif   := ''
cNomePar  := ''
cInsMat   := ''
cDReFonPg := ''

//Variáveis do tipo númerica 
nVlrBrt   := 0
nVlrRnd   := 0
nVlrIrf   := 0
nI        := 0
nCount    := 0
nL        := 0
nX        := 0
nJ        := 0
nQtdPgto  := 0
nPgto     := 0
nVerIdBen := 0

//Variáveis do tipo array
aTable    := {}
aCampos   := {}
aArea     := GetArea()
aLoadFil  := {}
aRet      := {}

//Variáveis lógicas
lRet      := .T.

//Variavel Date
dDtPgto   := cTod(' / / ')

cAliasTmp := ''
oTable    := nil

aTable := TAFA620A( TAFA620B() )
cAliasTmp := aTable[01]
oTable    := aTable[02]

    If Alltrim(UPPER(oXML:CNAME)) == "REINF" .and. oXML:XPathRegisterNs( "ns", oXML:XPathGetRootNsList()[1][2] )   
        If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEvento' )
            cPerPur := Substring(AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPJ/ns:ideEvento/ns:perApur')),6,2);
            +Substring(AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPJ/ns:ideEvento/ns:perApur')),1,4)
        EndIf

        If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab' )
            //ideEstab
            cInscr  := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:nrInscEstab'))
            //ideBenef
            aLoadFil := WSLoadFil()
            cInsMat := Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{ "M0_CGC" })[1][2])
            If  cInsMat == cInscr
                cFilTaf := cFilAnt
            Else 
                For nX := 1 To Len(aLoadFil)
                    If cInscr == aLoadFil[nX][06]
                        cFilTaf := aLoadFil[nX][03]
                    EndIf
                Next nX
            EndIf
            If !Empty( cFilTaf )
                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:cnpjBenef' )
                    cCGC := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:cnpjBenef'))
                Elseif oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:nmBenef' )
                    cNomePar := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:nmBenef'))
                Endif

                DBSelectArea("C1H")
                If !Empty(cCGC)
                    C1H->( DBSetOrder(3) )
                    If C1H->( DbSeek( xFilial("C1H") + cCGC ) )
                        cCodPar  := C1H->C1H_CODPAR
                        cIdPar   := C1H->C1H_ID
                        cNomePar := C1H->C1H_NOME
                    EndIf
                Else                     
                    C1H->( DBSetOrder(2) )
                    If C1H->( DbSeek( xFilial("C1H") + cNomePar ) )
                        cCodPar := C1H->C1H_CODPAR
                        cIdPar  := C1H->C1H_ID
                    EndIf
                EndIf  

                If AllTrim(cNomePar) == ''
                    cNomePar := 'XML Inst. Financeira'
                EndIf

                ("C1H")->(DbCloseArea())

                //Varre a tag ideBenef e atribui +1 ao contador cada vez que a tag idePgto for localizada
                For nVerIdBen := 1 To oXML:XPathChildCount( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef')
                    if oXML:XPathGetChildArray( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef')[nVerIdBen][1] == 'idePgto'
                        nQtdPgto++
                    endif
                Next nVerIdBen

                For nPgto := 1 To nQtdPgto
                    If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']' )
                        If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:natRend' )
                            cNtRend := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:natRend' ))
                            DBSelectArea("V3O")
                            V3O->( DBSetOrder(1) )
                            If V3O->( DbSeek( xFilial("V3O") + cNtRend ) )
                                cIdNat := V3O->V3O_ID
                                cNatRe := V3O->V3O_CODIGO
                                cDescNat := V3O->V3O_DESCR
                                cTribNat := V3O->V3O_TRIB
                            EndIf
                        Endif     

                        For nI := 1 To oXML:XPathChildCount( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']' )
                            If oXML:XPathGetChildArray( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']' )[nI][01] == 'infoPgto'
                                nCount++
                            Endif
                        Next nI

                        DBSelectArea("CUB")
                        CUB->( DBSetOrder(2) )

                        For nL := 1 To nCount   
                            If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']' )                                
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:dtFG' )
                                    dDtPgto := sTod(StrTran(AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:dtFG')),'-',''))
                                EndIf
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:vlrBruto' )
                                    nVlrBrt := Val(StrTran(AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:vlrBruto')),',','.'))
                                EndIf                                
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:paisResidExt' )
                                    cPaisExt := AllTrim(oXML:XPathGetNodeValue('/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:paisResidExt' ))
                                    DBSelectArea("C08")
                                    C08->( DBSetOrder(4) )
                                    If C08->( DbSeek( xFilial("C08") + cPaisExt ) )
                                        cIdPExt := C08->C08_ID
                                    EndIf     
                                EndIf         
                                If !(cNtRend == '12001')
                                    If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:retencoes/ns:vlrBaseIR' )
                                        nVlrRnd := Val(StrTran(AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:retencoes/ns:vlrBaseIR')),',','.'))
                                    EndIf
                                    If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:retencoes/ns:vlrIR' )
                                        nVlrIrf := Val(StrTran(AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:retencoes/ns:vlrIR')),',','.'))
                                    Endif
                                EndIf                                
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:indNIF' )
                                    cIndNif := Alltrim((oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:indNIF' )))
                                EndIf
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:nifBenef' )
                                    cNifBenef := Alltrim((oXml:XPathGetNodeValue( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:nifBenef' )))
                                EndIf
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:relFontPg' )
                                    cRelFonPg := Alltrim((oXml:XPathGetNodeValue( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:relFontPg' )))
                                EndIf

                                If !Empty(AllTrim(cRelFonPg))
                                    If CUB->( DbSeek( xFilial("CUB") + AllTrim(cRelFonPg) ) )
                                        cDReFonPg := CUB->CUB_DESCRI
                                    EndIf
                                EndIf

                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:frmTribut' )
                                    cFrmTrib := Alltrim((oXml:XPathGetNodeValue( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:frmTribut' )))
                                    cFrmTrib := StrZero(Val(cFrmTrib),4)
                                    DBSelectArea("T9A")
                                    T9A->( DBSetOrder(3) )
                                    If T9A->( DbSeek( xFilial("T9A") + cFrmTrib ) )
                                        cFrmTrib  := StrZero(Val(cFrmTrib),2)
                                        cIdTrib   := T9A->T9A_ID
                                        cCodTrib  := T9A->T9A_CODIGO
                                        cDescTrib := NoAcento(T9A->T9A_DESCRI)
                                    EndIf
                                EndIf
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:dscLograd' )
                                    cDscLogr := Alltrim((oXml:XPathGetNodeValue( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:dscLograd' )))
                                Endif
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:nrLograd' )
                                    cNroLog := Alltrim((oXml:XPathGetNodeValue( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:nrLograd' )))
                                Endif
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:complem' )
                                    cCompExt := Alltrim((oXml:XPathGetNodeValue( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:complem' )))
                                Endif
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:bairro' )
                                    cBairExt := Alltrim((oXml:XPathGetNodeValue( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:bairro' )))
                                Endif    
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:cidade' )
                                    cCidaExt := Alltrim((oXml:XPathGetNodeValue( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:cidade' )))
                                Endif    
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:estado' )
                                    cEstExt := Alltrim((oXml:XPathGetNodeValue( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:estado' )))
                                Endif 
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:codPostal' )
                                    cCepExt := Alltrim((oXml:XPathGetNodeValue( '/ns:Reinf/ns:evtRetPJ/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:codPostal' )))
                                Endif                         
                            Endif
                            aAdd(aCampos, {cFilTaf, cIdEvAdic, cCGC, cNomePar, cIdPar, cCodPar, cIdNat, dDtPgto, nVlrBrt, nVlrRnd, nVlrIrf, cBairExt, cCepExt, cCompExt, cIndNif, cNifBenef, cNatRe, cDescNat, cDscLogr, cNroLog, cCidaExt, cEstExt, cTelExt, cPaisExt, cRelFonPg, cFrmTrib, cIdPExt, cIdTrib, cDescTrib, cTribNat, cDReFonPg })
                        Next nL
                        nCount := 0            
                    EndIF
                Next nPgto
                TAFA620C(aCampos)
            Else            
                cError := STR0001 + cInscr + STR0002 //"Inscrição " "não vinculada a matriz"
                lRet   := .F.
            Endif     
        Endif           
        If lRet
            aRet := TAFA620D( cFilTaf, cPerPur, cCGC, cCodPar, cNIF, aLoadFil )

            For nJ := 1 To Len(aRet)
                iF !Empty(aRet[nJ][4])
                    cError := aRet[nJ][4]
                EndIf
            Next nJ
        EndIf
    Else
        cError := STR0004 //" XML não possui a tag REINF "        
    Endif

    oTable:Delete() 

    RestArea(aArea) 

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFA620A
Cria tabela temporária
@author Jose Felipe
@since 18/10/2023
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

Static Function TAFA620A( aFields )
                 
Local cTR4020   as character

cTR4020     := getNextAlias()
oTable      := FWTemporaryTable():New( cTR4020 )

oTable:SetFields( aFields )
oTable:AddIndex("01", { aFields[01][01]})  
oTable:Create()
	
Return { cTR4020 , oTable }

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFA620B
Cria campos para utilizar na tabela temporária
@author Jose Felipe
@since 18/10/2023
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

Static Function TAFA620B()

Local nTamFil     as character
Local aFields     as array

nTamFil := TamSX3( "C20_FILIAL" )[1]  
nTamNIF := TamSX3( "V5D_NIF" )[1]
aFields := {}

aFields := {{'SUMBRT'	 ,'C' , 001        ,0},;
            {'ROTINA'	 ,'C' , 003        ,0},;
            {'RECNO'	 ,'N' , 020        ,0},;
            {'LEMID'	 ,'C' , 036        ,0},;
            {'FILIAL'	 ,'C' , nTamFil    ,0},;
            {'NRNTLEM'	 ,'C' , 015        ,0},;
            {'NUMDOCTO'	 ,'C' , 009        ,0},;
            {'SERIE'	 ,'C' , 005        ,0},;
            {'CHVNF'	 ,'C' , 600        ,0},;
            {'V3UID'	 ,'C' , 036        ,0},;
            {'DTEMISSA'	 ,'D' , 008        ,0},;
            {'DTPV3U'	 ,'C' , 008        ,0},;
            {'NRV3U'     ,'C' , 009        ,0},;
            {'SERV3U'	 ,'C' , 005        ,0},;
            {'LEMDOCORI' ,'C' , 001        ,0},;
            {'FILC1H'	 ,'C' , nTamFil    ,0},;
            {'C1H_ID'	 ,'C' , 036        ,0},;
            {'BAIEXT'	 ,'C' , 060        ,0},;
            {'CDPOSE'	 ,'C' , 012        ,0},;
            {'CODPAI'	 ,'C' , 006        ,0},;
            {'COMEXT'	 ,'C' , 030        ,0},;
            {'CPF'	     ,'C' , 011        ,0},;
            {'CNPJ'	     ,'C' , 014        ,0},;
            {'ISENT'     ,'C' , 001        ,0},;
            {'RELFONT'	 ,'C' , 006        ,0},;
            {'DTMOLE'	 ,'C' , 008        ,0},;
            {'NOME'	     ,'C' , 100        ,0},;
            {'INDFCISCP' ,'C' , 001        ,0},;
            {'VLBRUT'	 ,'N' , 014        ,2},;
            {'IDSCP'     ,'C' , 036        ,0},;
            {'IDRRAPJD'	 ,'C' , 036        ,0},;
            {'IDTRIB2'	 ,'C' , 006        ,0},;
            {'BASECA'	 ,'N' , 014        ,2},;
            {'DECTER'	 ,'C' , 001        ,0},;
            {'IDNATR'	 ,'C' , 006        ,0},;
            {'COMPFP'	 ,'C' , 007        ,0},;
            {'INDNIF'	 ,'C' , 001        ,0},;
            {'NIF'	     ,'C' , nTamNIF    ,0},;
            {'IDTRIB'	 ,'C' , 036        ,0},;
            {'TRIBNAT'	 ,'C' , 001        ,0},;
            {'CCNATRE'	 ,'C' , 005        ,0},;
            {'CDNATRE'	 ,'C' , 254        ,0},;
            {'LOGEXT'	 ,'C' , 080        ,0},;
            {'NUMEXT'	 ,'C' , 010        ,0},;
            {'NMCEXT'	 ,'C' , 040        ,0},;
            {'ESTEXT'	 ,'C' , 040        ,0},;
            {'TELEXT'	 ,'C' , 015        ,0},;
            {'PAISEXT'	 ,'C' , 003        ,0},;
			{'CIDTRIB'   ,'C' , 036	       ,0},;            
            {'CRELPGT'	 ,'C' , 003        ,0},;
            {'CDRELPG'	 ,'C' , 100        ,0},;
            {'CCTRIB'	 ,'C' , 002        ,0},;
            {'CDTRIB'    ,'C' , 254	       ,0},;
            {'VLTRIB'	 ,'N' , 014        ,2},;
            {'CHVNFC30'	 ,'C' , 001        ,0},;
            {'NUMITC30'	 ,'C' , 001        ,0},;
            {'CODITC30'	 ,'C' , 001        ,0},;
            {'NUMITE'	 ,'C' , 001        ,0},;
            {'CODITE'	 ,'C' , 001        ,0},;
            {'CODPAR'	 ,'C' , 060        ,0},;
            {'DTESCO'	 ,'C' , 008        ,0},;
            {'CEVADIC'   ,'C',  008	       ,0},;
            {'OBSERV'	 ,'C' , 001        ,0},;
            {'CNMBENE'   ,'C' , 070	       ,0 }}

Return aFields

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFA620C
Gravação dos dados tabela temporária 
@author Jose Felipe
@since 18/10/2023
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TAFA620C( aCampos )

Local nI    as Numreric

nI  := 0

For nI := 1 to Len( aCampos )

    RecLock( cAliasTmp,.T.)
        (cAliasTmp)->SUMBRT     := ''	
        (cAliasTmp)->ROTINA     := 'INT'	
        (cAliasTmp)->RECNO      := Recno()
        (cAliasTmp)->LEMID      := ''	 
        (cAliasTmp)->FILIAL     := aCampos[nI][01] //cFilTaf
        (cAliasTmp)->NRNTLEM    := ''	
        (cAliasTmp)->NUMDOCTO   := ''	
        (cAliasTmp)->SERIE      := ''
        (cAliasTmp)->CHVNF      := ''	
        (cAliasTmp)->V3UID      := ''
        (cAliasTmp)->DTEMISSA   := aCampos[nI][08] //dDtPgto
        (cAliasTmp)->DTPV3U     := ''	
        (cAliasTmp)->NRV3U      := ''     
        (cAliasTmp)->SERV3U     := ''	
        (cAliasTmp)->LEMDOCORI  := '' 
        (cAliasTmp)->FILC1H     := ''	
        (cAliasTmp)->C1H_ID     := aCampos[nI][05] //cIdPar
        (cAliasTmp)->BAIEXT     := aCampos[nI][12] //cBairExt
        (cAliasTmp)->CDPOSE     := aCampos[nI][13] //cCepExt
        (cAliasTmp)->CODPAI     := aCampos[nI][27] //cIdPExt	
        (cAliasTmp)->COMEXT     := aCampos[nI][14] //cCompExt
        (cAliasTmp)->CPF        := ''	    
        (cAliasTmp)->CNPJ       := aCampos[nI][03] //cCGC
        (cAliasTmp)->ISENT      := ''     
        (cAliasTmp)->RELFONT    := ''	
        (cAliasTmp)->DTMOLE     := ''	
        (cAliasTmp)->NOME       := aCampos[nI][04] //cNomePar
        (cAliasTmp)->INDFCISCP  := '' 
        (cAliasTmp)->VLBRUT     := aCampos[nI][09] //nVlrBrt	
        (cAliasTmp)->IDSCP      := ''     
        (cAliasTmp)->IDRRAPJD   := ''	
        (cAliasTmp)->IDTRIB2    := ''	
        (cAliasTmp)->BASECA     := aCampos[nI][10] //nVlrRnd	
        (cAliasTmp)->DECTER     := ''	
        (cAliasTmp)->IDNATR     := aCampos[nI][07] //cIdNat	
        (cAliasTmp)->COMPFP     := ''	
        (cAliasTmp)->INDNIF     := aCampos[nI][15] //cIndNif
        (cAliasTmp)->NIF        := aCampos[nI][16] //cNifBenef	
        (cAliasTmp)->TRIBNAT    := aCampos[nI][30] //cTribNat
        (cAliasTmp)->CCNATRE    := aCampos[nI][17] //cNatRe	
        (cAliasTmp)->CDNATRE    := aCampos[nI][18] //cDescNat
        (cAliasTmp)->LOGEXT     := aCampos[nI][19] //cDscLogr
        (cAliasTmp)->NUMEXT     := aCampos[nI][20] //cNroLog
        (cAliasTmp)->NMCEXT     := aCampos[nI][21] //cCidaExt
        (cAliasTmp)->ESTEXT     := aCampos[nI][22] //cEstExt	
        (cAliasTmp)->TELEXT     := aCampos[nI][23] //cTelExt
        (cAliasTmp)->PAISEXT    := aCampos[nI][24] //cPaisExt
        (cAliasTmp)->CRELPGT    := aCampos[nI][25] //cRelFonPg
        (cAliasTmp)->CDRELPG    := aCampos[nI][31] //cDReFonPg	
        (cAliasTmp)->IDTRIB     := aCampos[nI][28] //cIdTrib
        (cAliasTmp)->CCTRIB     := aCampos[nI][26] //cFrmTrib    
        (cAliasTmp)->CDTRIB     := aCampos[nI][29] //cDescTrib
        (cAliasTmp)->VLTRIB     := aCampos[nI][11] //nVlrIrf	
        (cAliasTmp)->CHVNFC30   := ''	
        (cAliasTmp)->NUMITC30   := ''	
        (cAliasTmp)->CODITC30   := ''	
        (cAliasTmp)->NUMITE     := ''	
        (cAliasTmp)->CODITE     := ''	
        (cAliasTmp)->CODPAR     := aCampos[nI][06] //cCodPar	
        (cAliasTmp)->DTESCO     := ''	
        (cAliasTmp)->CEVADIC    := aCampos[nI][02] //cIdEvAdic 
        (cAliasTmp)->OBSERV     := ''
    (cAliasTmp)->( MsUnLock() )

Next nI 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Tafa620D()
Gera a apuração
@author Jose Felipe
@since 19/10/2023
@version 1.0
@Return
/*/ 
//-------------------------------------------------------------------
Static Function TAFA620D( cFilTaf, cPerPur, cCGC, cCodPar, cNIF, aLoadFil )

Local cAlias    as caracter
Local cSql      as caracter
Local cEvent    as caracter
Local cInsMat   as caracter
Local aFilial	as Array	
Local aIDLog	as Array	
Local aProcFil	as Array
Local lImp		as Logical
Local lReinf212	as Logical
Local lCentApr	as Logical
Local lValid    as Logical
Local lSucesso  as Logical
Local nI    	as Numeric

cAlias    := GetNextAlias()
cSql      := ''  
cEvent    := 'R-4020'  
cInsMat   := ''
aFilial   := {}
aIDLog    := {}
lReinf212 := .F.    
lImp      := .T. 
lCentApr  := .F.
lValid    := .F.
lSucesso  := .F.
nI        := 0

cSql := "SELECT * FROM " + oTable:GetRealName()
TCQUERY cSql New Alias (cAlias)

lReinf212  := TAFColumnPos( "V4Q_ORIGEM" )

cInsMat := Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilTaf,{ "M0_CGC" })[1][2])

aAdd(aFilial,{cFilTaf, '', cInsMat})

TafOrdFil( aFilial, @aProcFil, lReinf212, aLoadFil )

    For nI := 1 To Len(aProcFil)
        If nI == 1
            aFil := RetFil(aLoadFil, aFilial, cEvent)
        EndIf
        TAFAPR4020(cPerPur, aFil, lValid, lSucesso, cCGC, @aIDLog, cCodPar, cNIF, lReinf212, lCentApr, cAlias, lImp)
    Next nI

Return aIDLog        

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetFil
Retorna a filial selecionada para apuração do evento
@author Jose Felipe
@since 18/10/2023
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function RetFil(aLoadFil, aFilial, cEvent )

    local nX            as numeric
    local aRet          as array
    Local cCnpjSM0      as character

    nX          := 0
    aRet        := {}
    cCnpjSM0    := ''

	cCnpjSM0 := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , aFilial[1][1] , { "M0_CGC" } )[1][2])
	For nX := 1 to Len(aLoadFil)
		If Alltrim(aLoadFil[nX][6]) == cCnpjSM0
			aAdd(aRet, { aLoadFil[nx][2], ;
				aLoadFil[nx][3], ;
				aLoadFil[nx][4], ;
				aLoadFil[nx][5], ;
				"", ;
				"", ;
				aLoadFil[nx][9],;
				aLoadFil[nx][10] })
		EndIf
	next nX

Return aRet

/*---------------------------------------------------------------------
{Protheus.doc} TafOrdFil()
@author Jose Felipe
@since 23/11/2022
@version 1.0
@return
---------------------------------------------------------------------*/
Static Function TafOrdFil(aFiliais, aProcFil, lEvAdic, aLoadFil)

Local cFil      as character
Local cCNPJ     as character
Local nX        as Numeric
Local nPos      as Numeric
Local cIdEvAdic as character

Default aFiliais := {}
Default aProcFil := {}
Default lEvAdic  := .F.
Default aLoadFil := {}

cFil  := ''
cCNPJ := ''
nX    := 0
nPos  := 0
cIdEvAdic := ''

//Restrutura Array com CNPJ x Filiais
For nX := 1 to Len( aFiliais )
	cFil  := aFiliais[nX][1]
	cCNPJ := aFiliais[nX][3]
	If lEvAdic
		nPos := aScan(aLoadFil,{|x| x[6]==cCNPJ .and. Alltrim(x[3])==Alltrim(cFil)})
		If nPos > 0
			cIdEvAdic := aLoadFil[nPos][10]
		EndIf	
	EndIf	
	If !lEvAdic
		nPos := aScan(aProcFil,{|x| x[1]==cCNPJ })
	Else
		nPos := aScan(aProcFil,{|x| x[1]==cCNPJ .and. x[3]==cIdEvAdic})
	EndIf	
	if nPos == 0
		If !lEvAdic
			aAdd( aProcFil, { cCNPJ,  cFil, "" } )
		Else
			aAdd( aProcFil, { cCNPJ,  cFil, cIdEvAdic } )
		EndIf
	endif
Next nX

Return Nil

/*---------------------------------------------------------------------
{Protheus.doc} TAF620Rel()
@author Jose Felipe
@since 06/12/2023
@version 1.0
@return
---------------------------------------------------------------------*/
Function TAF620Rel()

    Local aArea     := FWGetArea()
	Local oReport
	Local cTxtHlp   := STR0005// "Dicionário de Dados do TAF desatualizado. Por favor atualie para o pacote com data maior ou igual a 30/12/2023 disponivel no portal do cliente." 
    Local aPergunte := {}

    oObjRel := FWSX1Util():New()
    oObjRel:AddGroup("TAF620REL")
    oObjRel:SearchGroup()
    aPergunte := oObjRel:GetGroup("TAF620REL")
	
	If Len( aPergunte ) > 1 .And. Len( aPergunte[2] ) > 1 .And.  TAFColumnPos("V5C_ORIGEM")
	    If FindFunction("TRepInUse") .And. TRepInUse()
	    	oReport := ReportDef()
		    oReport:PrintDialog()
	    EndIf
    else	
	    Help(" ",1,"TAF620REL",,cTxtHlp ,1,0) //"Dicionário de Dados do TAF desatualizado. Por favor atualie para o pacote com data maior ou igual a 30/12/2023 disponivel no portal do cliente."
    EndIf
	
	FWRestArea(aArea)

Return Nil

/*---------------------------------------------------------------------
{Protheus.doc} ReportDef()
@author Jose Felipe
@since 06/12/2023
@version 1.0
@return
---------------------------------------------------------------------*/

Static Function ReportDef()

	Local oReport
	Local oSection   := Nil
    Local cPerg 	 := ""

	cPerg := "TAF620REL" //Tam Max 10
	Pergunte( cPerg, .F. ) // Carrega os MV_PAR do grupo de perguntas

	//Criacao do componente de impressao
	oReport := TReport():New( STR0019,STR0006,cPerg,{|oReport| PrintReport(oReport),STR0007})//"Lucros e Dividendos"
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9)
	
	//Orientacao do Relatorio
	oReport:SetPortrait()
	
	//Criando a secao de dados
	oSection := TRSection():New( oReport,STR0007,{"QRY_REP"})//"Lucros e Dividendos"
	oSection:SetTotalInLine(.F.)
    oSection:SetHeaderPage(.F.)
	
	//Colunas do relatorio
	TRCell():New(oSection, "V5C_FILIAL", "QRY_REP", STR0008, "@!", 15, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Filial"
    TRCell():New(oSection, "V5C_PERAPU", "QRY_REP", STR0017, "@R 99-9999", 25, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Per. Apur."
	TRCell():New(oSection, "V5C_CNPJBN", "QRY_REP", STR0009, "@!", 25, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"CPF Benef."
    TRCell():New(oSection, "V5D_NIF", "QRY_REP", STR0018, "@!", 25, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"NIF Benef."
    TRCell():New(oSection, "V5C_NMBENE"  , "QRY_REP", STR0010, "@!", 70, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Nome Benef."
    TRCell():New(oSection, "V4S_DATAFG", "QRY_REP", STR0011, /*cPicture*/, 35, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Dt. Fato Gerador"
	TRCell():New(oSection, "V5D_CNATRE", "QRY_REP", STR0012, "@!", 22, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Nat. Rend."	
	TRCell():New(oSection, "V4S_VLRTOT", "QRY_REP", STR0013, "@E 99,999,999.99", 22, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Vlr. Bruto"
	TRCell():New(oSection, "V4S_BASEIR", "QRY_REP", STR0014, "@E 99,999,999.99", 35, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Vlr. Tributavel"
	TRCell():New(oSection, "V4S_VLRIR" , "QRY_REP", STR0015, "@E 99,999,999.99", 22, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Vlr. IR"
    TRCell():New(oSection, "V5C_EVADIC", "QRY_REP", STR0016, "@!", 15, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"EvAdic"
	
	//Totalizadores
	TRFunction():New(oSection:Cell("V4S_VLRTOT"), /*cName*/, "SUM", /*oBreak*/, /*cTitle*/, "@E 99,999,999.99", /*uFormula*/, .F.)
    TRFunction():New(oSection:Cell("V4S_BASEIR"), /*cName*/, "SUM", /*oBreak*/, /*cTitle*/, "@E 99,999,999.99", /*uFormula*/, .F.)
    TRFunction():New(oSection:Cell("V4S_VLRIR"), /*cName*/, "SUM", /*oBreak*/, /*cTitle*/, "@E 99,999,999.99", /*uFormula*/, .F.)
	TRFunction():New(oSection:Cell("V5D_CNATRE"), /*cName*/, "COUNT", /*oBreak*/, /*cTitle*/, "@!", /*uFormula*/, .F.)
	
Return oReport


/*---------------------------------------------------------------------
{Protheus.doc} PrintReport()
@author Jose Felipe
@since 06/12/2023
@version 1.0
@return
---------------------------------------------------------------------*/
Static Function PrintReport(oReport)
	
    Local aArea    := FWGetArea()
	Local cQuery     := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as secoes do relatorio
	oSectDad := oReport:Section(1)

    cQuery := " SELECT "
    cQuery += " 	 V5C_FILIAL "
    cQuery += " 	,V5C_PERAPU "
    cQuery += " 	,V5C_CNPJBN "
    cQuery += "     ,V5D_NIF "
    cQuery += " 	,V5C_NMBENE "
    cQuery += " 	,V4S_DATAFG "
    cQuery += " 	,V5D_CNATRE "
    cQuery += " 	,V4S_VLRTOT "
    cQuery += " 	,V4S_BASEIR "
    cQuery += " 	,V4S_VLRIR "
    cQuery += " 	,V5C_EVADIC "
    cQuery += " FROM " + RetSqlName("V5C") + " V5C "
    cQuery += " INNER JOIN " + RetSqlName("V4S") + " V4S ON " 
    cQuery += "     V5C.V5C_FILIAL = V4S.V4S_FILIAL "
    cQuery += "     AND V5C.V5C_ID = V4S.V4S_ID "
    cQuery += "     AND V5C.V5C_VERSAO = V4S.V4S_VERSAO "
    cQuery += "     AND V4S.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSqlName("V5D") + " V5D ON "
    cQuery += "     V5D.V5D_FILIAL = V5C.V5C_FILIAL "
    cQuery += "     AND V5D.V5D_ID = V5C.V5C_ID "
    cQuery += "     AND V5D.V5D_VERSAO = V5C.V5C_VERSAO "
    cQuery += "     AND V5D.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE V5C.V5C_FILIAL = '" + xFilial("V5C") + "'
    cQuery += "     AND V5C.V5C_ORIGEM = 'I' "
    cQuery += " 	AND V5C.V5C_ATIVO = '1' "
    cQuery += "     AND V5C.V5C_EVADIC = '" + MV_PAR02 + "' "
    cQuery += "     AND V5C.V5C_PERAPU = '" + MV_PAR01 + "' "
    cQuery += " 	AND V5C.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY V5C_CNPJBN "

    //Executando consulta e setando o total da regua
	PlsQuery(cQuery, "QRY_REP")
	DbSelectArea("QRY_REP")
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_REP->(DbGoTop())
	While ! QRY_REP->(Eof())
	
		//Incrementando a regua
		nAtual++
		oReport:SetMsgPrint(STR0020 + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")//"Imprimindo registros "
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_REP->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_REP->(DbCloseArea())
	
	FWRestArea(aArea)

Return
