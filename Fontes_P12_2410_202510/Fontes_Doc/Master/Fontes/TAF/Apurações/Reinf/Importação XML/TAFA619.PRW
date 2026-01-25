#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFA619.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA619
Importação XML Lucros e Dividendos R-4010
@author Carlos Pister
@since 19/10/2023
@version 1.0
@Return
/*/ 
//-------------------------------------------------------------------

Function TAFA619(oXml, cIdEvAdic, cError) 

    Local cCodPar   as Character
    Local cIdPar    as Character
	Local cNIF      as Character
    Local cPerPur   as Character
    Local cInscr    as Character
    Local cCPF      as Character
    Local cIdNat    as Character
    Local cNomePar  as Character
    Local cNtRend   as Character
    Local cIndNif   as Character
    Local cDscLog   as Character
    Local cNrLogr   as Character
    Local cBairro   as Character
    Local cCidade   as Character
    Local cPaisExt  as Character
    Local cCdPExt   as Character
    Local cIndJud   as Character
    Local cFmTrib   as Character
    Local cNifBenf  as Character
    Local cIdTrib   as Character
    Local cDscTrb   as Character
    Local cFilTaf   as Character
    Local nVlrBrt 	as Numeric
    Local nVlrRnd 	as Numeric
    Local nVlrIrf 	as Numeric
    Local nI 		as Numeric
    Local nL 		as Numeric
    Local nX 		as Numeric
    Local nJ 		as Numeric
    Local nCount    as Numeric
    Local nQtdPgto  as Numeric
    Local nPgto 	as Numeric
    Local nVerIdBen as Numeric
    Local aArea 	as Array
    Local aDados    as Array
    Local aLoadFil	as Array
    Local aRet   	as Array
    Local lRet  	as Logical
    Local dDtPgto	as Date

    Private cAliasTmp  as Character
    Private oTable     as Object

    cCodPar   := ''
    cIdPar    := ''
    cNIF      := ''
    cPerPur   := ''
    cInscr    := ''
    cCPF      := ''
    cIdNat    := ''
    cNomePar  := ''
    cNtRend   := ''
    cIndNif   := ''
    cDscLog   := ''
    cNrLogr   := ''
    cBairro   := ''
    cCidade   := ''
    cPaisExt  := ''
    cCdPExt   := ''
    cIndJud   := ''
    cFmTrib   := ''
    cNifBenf  := ''   
    cIdTrib   := ''
    cDscTrb   := ''
    cFilTaf   := ''
    nVlrBrt   := 0
    nVlrRnd   := 0
    nVlrIrf   := 0
    nI        := 0
    nL        := 0
    nX        := 0
    nJ        := 0
    nCount    := 0
    nQtdPgto  := 0
    nPgto     := 0
    nVerIdBen := 0
    aArea     := GetArea()
    aDados    := {}
    aLoadFil  := {}
    aRet      := {}
    lRet      := .T.
    dDtPgto   := cTod(' / / ')
    cAliasTmp := ''
    oTable    := nil

    aTable := Tafa619A( Tafa619B() )
    cAliasTmp := aTable[01]
    oTable    := aTable[02]

    If Alltrim(UPPER(oXML:CNAME)) == "REINF" .and. oXML:XPathRegisterNs( "ns", oXML:XPathGetRootNsList()[1][2] )
        //Período de apuração
        If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPF/ns:ideEvento' )
            cPerPur  := Substring(AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEvento/ns:perApur')),6,2);
            +Substring(AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEvento/ns:perApur')),1,4)
        EndIf
        If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPF/ns:ideEstab' )
            //ideEstab
            cInscr  := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:nrInscEstab'))
            //ideBenef
            aLoadFil := WSLoadFil()
            cInsMat := Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{ "M0_CGC" })[1][2])
            If cInsMat == cInscr
                cFilTaf := cFilAnt
            Else 
                For nX := 1 To Len(aLoadFil)
                    If cInscr == aLoadFil[nX][06]
                        cFilTaf := aLoadFil[nX][03]
                    EndIf
                Next nX
            EndIf
            If !Empty( cFilTaf )
                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:cpfBenef' )
                    cCPF := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:cpfBenef'))
                ElseIf oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:nmBenef' )
                    cNomePar := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:nmBenef'))
                EndIf
                DBSelectArea("C1H")
                If !Empty(cCPF)
                    C1H->( DBSetOrder(4) )
                    If C1H->( DbSeek( xFilial("C1H") + cCPF ) )
                    	cCodPar  := C1H->C1H_CODPAR
                        cIdPar   := C1H->C1H_ID
                        cNomePar := C1H->C1H_NOME
                    EndIf
                Else 
                    C1H->( DBSetOrder(2) )
                    If C1H->( DbSeek( xFilial("C1H") + cNomePar ) )
                    	cCodPar  := C1H->C1H_CODPAR
                        cIdPar   := C1H->C1H_ID
                    EndIf
                EndIf
    
                If AllTrim(cNomePar) == ''
                    cNomePar := 'XML Inst. Financeira'
                EndIf

                ("C1H")->(DbCloseArea())

                //Varre a tag ideBenef e atribui +1 ao contador cada vez que a tag idePgto for localizada
                For nVerIdBen := 1 To oXML:XPathChildCount( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef')
                    if oXML:XPathGetChildArray( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef')[nVerIdBen][1] == 'idePgto'
                        nQtdPgto++
                    endif
                Next nVerIdBen
                
                For nPgto := 1 To nQtdPgto
                    If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']' )
                        If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:natRend' )
                            cNtRend := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:natRend'))
                            DBSelectArea("V3O")
                            V3O->( DBSetOrder(1) )
                            If V3O->( DbSeek( xFilial("V3O") + cNtRend ) )
                                cIdNat := V3O->V3O_ID
                            EndIf
                            ("V3O")->(DbCloseArea())
                        EndIf            
                        //Verifico a quantidade de array do infoPgto
                        For nI := 1 To oXML:XPathChildCount( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']' )
                            If oXML:XPathGetChildArray( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']' )[nI][01] == 'infoPgto'
                                nCount++
                            EndIf
                        Next nI
                        //Faço a leitura do array do infoPgto
                        For nL := 1 To nCount
                            If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:dtFG' )
                                dDtPgto := sTod(StrTran(AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:dtFG')),'-',''))
                            EndIf
                            If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:vlrRendBruto' )
                                nVlrBrt := Val(StrTran(AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:vlrRendBruto')),',','.'))
                            EndIf
                            If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:paisResidExt' )
                                cPaisExt := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:paisResidExt'))
                                C08->( DBSetOrder(4) )
                                If C08->( DbSeek( xFilial("C08") + cPaisExt ) )
                                    cCdPExt := C08->C08_ID
                                EndIf
                            EndIf
                            If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:indJud' )
                                cIndJud := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:indJud'))
                            EndIf
                            If !(cNtRend == '12001')
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:vlrRendTrib' )
                                    nVlrRnd := Val(StrTran(AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:vlrRendTrib')),',','.'))
                                EndIf
                                If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:vlrIR' )
                                    nVlrIrf := Val(StrTran(AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:vlrIR')),',','.'))
                                EndIF
                            EndIf
                            If oXML:XPathHasNode( '/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt' )
                                If oXml:XPathHasNode('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:indNIF')
                                    cIndNif := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:indNIF'))
                                EndIf 
                            
                                If oXml:XPathHasNode('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:nifBenef')
                                    cNifBenf := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:nifBenef'))
                                EndIf


                                If oXml:XPathHasNode('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:frmTribut')
                                    cFmTrib := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:frmTribut'))
                                    cFmTrib := StrZero(Val(cFmTrib),4)
                                    T9A->( DBSetOrder(3) )
                                    If T9A->( DbSeek( xFilial("T9A") + cFmTrib ) )
                                        cIdTrib := T9A->T9A_ID
                                        cDscTrb := NoAcento(T9A->T9A_DESCRI)
                                        cFmTrib := StrZero(Val(cFmTrib),2)
                                    EndIf
                                EndIf 
                                If oXml:XPathHasNode('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt')
                                    If oXml:XPathHasNode('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:dscLograd')
                                        cDscLog := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:dscLograd'))
                                    EndIf
                                    If oXml:XPathHasNode('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:nrLograd')
                                        cNrLogr := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:nrLograd'))
                                    EndIf
                                    If oXml:XPathHasNode('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:bairro')
                                        cBairro := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:bairro'))
                                    EndIf
                                    If oXml:XPathHasNode('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:cidade')
                                        cCidade := AllTrim(oXml:XPathGetNodeValue('/ns:Reinf/ns:evtRetPF/ns:ideEstab/ns:ideBenef/ns:idePgto[' + cValToChar(nPgto) + ']/ns:infoPgto['+cValToChar(nL)+']/ns:infoPgtoExt/ns:endExt/ns:cidade'))
                                    EndIf
                                EndIf
                            EndIf
                            aAdd(aDados,{cFilTaf, cIdEvAdic, cCPF, cNomePar, cIdPar, cIdNat, dDtPgto, nVlrBrt, nVlrRnd, nVlrIrf, cCdPExt, cIndNif, cNifBenf, cFmTrib, cIdTrib, cDscTrb, cDscLog, cNrLogr, cBairro, cCidade, cCodPar, cNtRend})
                        Next nL
                        nCount := 0
                    EndIf
                Next nPgto
                Tafa619C( aDados )
            else
                cError := STR0001 + cInscr + STR0002 //"Inscrição " + "não vinculada a matriz"
                lRet   := .F.
            EndIf
        EndIf
        If lRet
            aRet := Tafa619D( cFilTaf, cPerPur, cCPF, cCodPar, cNIF, aLoadFil )

            For nJ := 1 To Len(aRet)
                iF !Empty(aRet[nJ][4])
                    cError := aRet[nJ][4]
                EndIf
            Next nJ

        EndIf
    else
        cError := STR0004//"XML não possui tag REINF"
    EndIf 

    oTable:Delete()  

    RestArea(aArea)       

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Tafa619A
Criação da tabela temporária
@author Carlos Pister
@since 19/10/2023
@version 1.0
@Return
/*/ 
//-------------------------------------------------------------------
Static Function Tafa619A( aFields )
                 
	Local cTR4010     as character

    cTR4010     := getNextAlias()
    oTable      := FWTemporaryTable():New( cTR4010 )

    oTable:SetFields( aFields )
    oTable:AddIndex("01", { aFields[01][01]})  
    oTable:Create()
	
Return { cTR4010 , oTable}

//-------------------------------------------------------------------
/*/{Protheus.doc} Tafa619B
Criação dos campos para as tabelas temporárias 
@author Carlos Pister
@since 19/10/2023
@version 1.0
@Return
/*/ 
//-------------------------------------------------------------------
Static Function Tafa619B()

    Local nTamFil     as character
    Local aFields     as array

    nTamFil := TamSX3( "C20_FILIAL" )[1]  
    aFields := {}

    aFields := {{'ID'		    ,'C', 030       ,0},;
                {'ROTINA'		,'C', 003       ,0},;
                {'RECNO'		,'N', 020       ,0},;
                {'LEMID'		,'C', 250       ,0},;
                {'FILIAL'		,'C', nTamFil   ,0},;
                {'NRNTLEM'		,'C', 015       ,0},;
                {'NUMDOCTO'		,'C', 015       ,0},;
                {'SERIE'		,'C', 005       ,0},;
                {'CHVNF'		,'C', 001       ,0},;
                {'V3UID'		,'C', 001       ,0},;
                {'DTEMISSA'		,'D', 008       ,0},;
                {'DTPV3U'		,'C', 001       ,0},;
                {'NRV3U'		,'C', 001       ,0},;
                {'SERV3U'		,'C', 001       ,0},;
                {'LEMDOCORI'	,'C', 001       ,0},;
                {'FILC1H'		,'C', nTamFil   ,0},;
                {'C1H_ID'		,'C', 036       ,0},;
                {'BAIEXT'		,'C', 060       ,0},;
                {'LOGEXT'		,'C', 080       ,0},;
                {'NUMEXT'		,'C', 010       ,0},;
                {'NMCEXT'		,'C', 040       ,0},;
                {'CDPOSE'		,'C', 012       ,0},;
                {'CODPAI'		,'C', 006       ,0},;
                {'COMEXT'		,'C', 030       ,0},;
                {'CPF'			,'C', 011       ,0},;
                {'CNPJ'			,'C', 014       ,0},;
                {'ISENT'		,'C', 001       ,0},;
                {'RELFONT'		,'C', 006       ,0},;
                {'DTMOLE'		,'C', 008       ,0},;
                {'NOME'			,'C', 100       ,0},;
                {'INDFCISCP'	,'C', 001       ,0},;
                {'VLBRUT'		,'N', 014       ,2},;
                {'IDSCP'		,'C', 036       ,0},;
                {'IDRRAPJD'		,'C', 036       ,0},;
                {'IDTRIB2'		,'C', 002       ,0},;
                {'BASECA'		,'N', 014       ,2},;
                {'DECTER'		,'C', 001       ,0},;
                {'IDNATR'		,'C', 006       ,0},;
                {'COMPFP'		,'C', 007       ,0},;
                {'INDNIF'		,'C', 001       ,0},;
                {'NIF'			,'C', 030       ,0},;
                {'IDTRIB'		,'C', 036       ,0},;
                {'DESCID'		,'C', 220       ,0},;
                {'VLTRIB'		,'N', 014       ,2},;
                {'CHVNFC30'		,'C', 001       ,0},;
                {'NUMITC30'		,'C', 001       ,0},;
                {'CODITC30'		,'C', 001       ,0},;
                {'NUMITE'		,'C', 001       ,0},;
                {'CODITE'		,'C', 001       ,0},;
                {'CODPAR'		,'C', 060       ,0},;
                {'DTESCO'		,'C', 008       ,0},;
                {'CEVADIC'		,'C', 008       ,0},;
                {'CCNATRE'		,'C', 005       ,0},;
                {'OBSERV'		,'C', 200       ,0}}

Return aFields

//-------------------------------------------------------------------
/*/{Protheus.doc} Tafa619C
Gravação dos dados tabela temporária 
@author Carlos Pister
@since 19/10/2023
@version 1.0
@Return
/*/ 
//-------------------------------------------------------------------
Static Function Tafa619C( aDados )

    Local nI 		as Numeric

    nI  := 0

    For nI := 1 To Len( aDados )
        RecLock( cAliasTmp,.T.)
            (cAliasTmp)->ID        := ''					   		
	    	(cAliasTmp)->ROTINA    := 'INT'
            (cAliasTmp)->RECNO     := Recno()
            (cAliasTmp)->LEMID     := ''
            (cAliasTmp)->FILIAL    := aDados[nI][01]
            (cAliasTmp)->NRNTLEM   := '' 
            (cAliasTmp)->NUMDOCTO  := ''  
            (cAliasTmp)->SERIE     := ''
            (cAliasTmp)->CHVNF     := ''
            (cAliasTmp)->V3UID     := ''
            (cAliasTmp)->DTEMISSA  := aDados[nI][07] 
            (cAliasTmp)->DTPV3U    := ''
            (cAliasTmp)->NRV3U     := ''
            (cAliasTmp)->SERV3U    := ''
            (cAliasTmp)->LEMDOCORI := ''   
            (cAliasTmp)->FILC1H    := ''
            (cAliasTmp)->C1H_ID    := aDados[nI][05]
            (cAliasTmp)->BAIEXT    := aDados[nI][19]
            (cAliasTmp)->LOGEXT    := aDados[nI][17]
            (cAliasTmp)->NUMEXT    := aDados[nI][18]
            (cAliasTmp)->NMCEXT    := aDados[nI][20]
            (cAliasTmp)->CDPOSE    := ''
            (cAliasTmp)->CODPAI    := aDados[nI][11]
            (cAliasTmp)->COMEXT    := ''
            (cAliasTmp)->CPF       := aDados[nI][03]
            (cAliasTmp)->CNPJ      := ''
            (cAliasTmp)->ISENT     := ''
            (cAliasTmp)->RELFONT   := '' 
            (cAliasTmp)->DTMOLE    := ''
            (cAliasTmp)->NOME      := aDados[nI][04]
            (cAliasTmp)->INDFCISCP := ''   
            (cAliasTmp)->VLBRUT    := aDados[nI][08]
            (cAliasTmp)->IDSCP     := ''
            (cAliasTmp)->IDRRAPJD  := ''       
            (cAliasTmp)->IDTRIB2   := aDados[nI][14]
            (cAliasTmp)->BASECA    := aDados[nI][09]
            (cAliasTmp)->DECTER    := ''
            (cAliasTmp)->IDNATR    := aDados[nI][06]
            (cAliasTmp)->COMPFP    := ''
            (cAliasTmp)->INDNIF    := aDados[nI][12]
            (cAliasTmp)->NIF       := aDados[nI][13] 
            (cAliasTmp)->IDTRIB    := aDados[nI][15]
            (cAliasTmp)->DESCID    := aDados[nI][16]
            (cAliasTmp)->VLTRIB    := aDados[nI][10]
            (cAliasTmp)->CHVNFC30  := ''  
            (cAliasTmp)->NUMITC30  := ''  
            (cAliasTmp)->CODITC30  := ''  
            (cAliasTmp)->NUMITE    := ''
            (cAliasTmp)->CODITE    := ''
            (cAliasTmp)->CODPAR    := aDados[nI][21]
            (cAliasTmp)->DTESCO    := ''
            (cAliasTmp)->CEVADIC   := aDados[nI][02]
            (cAliasTmp)->CCNATRE   := aDados[nI][22]
            (cAliasTmp)->OBSERV    := ''
        (cAliasTmp)->( MsUnLock() )
    Next nI

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} Tafa619D()
Gera a apuração
@author Carlos Pister
@since 19/10/2023
@version 1.0
@Return
/*/ 
//-------------------------------------------------------------------
Static Function Tafa619D( cFilTaf, cPerPur, cCPF, cCodPar, cNIF, aLoadFil )

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
    Local lValid	as Logical
    Local lSucesso	as Logical
    Local nI    	as Numeric

    cAlias    := GetNextAlias()
    cSql      := ''  
    cEvent    := 'R-4010'  
    cInsMat   := ''
    aFilial   := {}
    aIDLog    := {}
    aProcFil  := {}
    lReinf212 := .F.    
    lImp      := .T. 
    lCentApr  := .F.
    lValid    := .F.
    lSucesso  := .F.
    nI        := 0

    //ALIAS
    cSql := "SELECT * FROM " + oTable:GetRealName()
    TCQUERY cSql New Alias (cAlias)
    //Verifica evadic
    lReinf212  := TAFColumnPos( "V4Q_ORIGEM" )

    cInsMat := Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilTaf,{ "M0_CGC" })[1][2])
    //Monta array para verificar a filial
    aAdd(aFilial,{cFilTaf, '', cInsMat})
    //Ordena as filiais
    TafOrdFil( aFilial, @aProcFil, lReinf212, aLoadFil )

    For nI := 1 To Len(aProcFil)
        If nI == 1
            aFil := RetFil(aLoadFil, aFilial, cEvent)
        EndIf    
        TAFAPR4010(cPerPur, aFil, lValid, lSucesso, cCPF, @aIDLog, cCodPar, cNIF, lReinf212, lCentApr, cAlias, lImp)
    Next nI        
        
Return aIDLog

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFil()
Gravação dos dados tabela temporária 
@author Carlos Pister
@since 19/10/2023
@version 1.0
@Return
/*/ 
//-------------------------------------------------------------------

Static Function RetFil(aLoadFil, aFilial, cEvent)

    local nX        as numeric
    local aRet      as array
    Local cCnpjSM0  as character
	
    nX          := 0
    aRet        := {}
    cCnpjSM0    := ''
	
	cCnpjSM0 := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , aFilial[1][1] , { "M0_CGC" } )[1][2])
	For nX := 1 to Len(aLoadFil)
		If Alltrim(aLoadFil[nX][6]) == cCnpjSM0
			aAdd(aRet, {     aLoadFil[nx][2], ;
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
@author Carlos Pister
@since 23/11/2022
@version 1.0
@return
---------------------------------------------------------------------*/
Static Function TafOrdFil(aFiliais, aProcFil, lEvAdic, aLoadFil)

Local cFil  as character
Local cCNPJ as character
Local nX    as Numeric
Local nPos  as Numeric
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

/*/{Protheus.doc} Function TAF619Rel
Impressão de relatório da importação dos xml
@author Carlos Pister
@since 06/12/2023
@version 1.0
@type function
/*/

Function TAF619Rel()

    Local aArea 	as Array
    Local aPergunte as Array
    Local oReport   as Object
    Local oObjRel 	as Object
    
	aArea     := FWGetArea()
    aPergunte := {}
	oReport   := Nil
    oObjRel   := Nil
	
    oObjRel := FWSX1Util():New()
    oObjRel:AddGroup("TAF620REL")
    oObjRel:SearchGroup()
    aPergunte := oObjRel:GetGroup("TAF620REL")
	
	If Len( aPergunte ) > 1 .And. Len( aPergunte[2] ) > 1 .and. TAFColumnPos("V4Q_ORIGEM")
	    If FindFunction("TRepInUse") .And. TRepInUse()
	    	oReport := ReportDef()
		    oReport:PrintDialog()
	    EndIf
    else	
	    Help(" ",1,STR0019,,STR0005 ,1,0) //"Dicionário de Dados do TAF desatualizado. Por favor atualie para o pacote com data maior ou igual a 30/12/2023 disponivel no portal do cliente."
    EndIf
	
	FWRestArea(aArea)

Return nil

/*/{Protheus.doc} ReportDef
Definicoes do relatorio TAF619Rel
@author Carlos Pister
@since 06/12/2023
@version 1.0
@type function
/*/

Static Function ReportDef()

    Local oReport   as Object
    Local oSection 	as Object
    Local cPerg   as Character

	oReport    := Nil
	oSection   := Nil
    cPerg 	   := ""

	cPerg := "TAF620REL" //Tam Max 10
	Pergunte( cPerg, .F. ) // Carrega os MV_PAR do grupo de perguntas

	//Criacao do componente de impressao
	oReport := TReport():New(STR0019,STR0006,cPerg,{|oReport| RepPrint(oReport),STR0006})//"Lucros e Dividendos"
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9)
	
	//Orientacao do Relatorio
	oReport:SetPortrait()
	
	//Criando a secao de dados
	oSection := TRSection():New( oReport,STR0006,{"QRY_REP"})//"Lucros e Dividendos"
	oSection:SetTotalInLine(.F.)
    oSection:SetHeaderPage(.F.)
	
	//Colunas do relatorio
	TRCell():New(oSection, "V4Q_FILIAL", "QRY_REP", STR0007, "@!", 15, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Filial"
    TRCell():New(oSection, "V4Q_PERAPU", "QRY_REP", STR0008, "@R 99-9999", 25, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Per. Apur."
	TRCell():New(oSection, "V4Q_CPF"   , "QRY_REP", STR0009, "@!", 25, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"CPF Benef."
    TRCell():New(oSection, "V4Q_IDEXTE", "QRY_REP", STR0010, "@!", 25, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"NIF Benef."
    TRCell():New(oSection, "V4Q_NOME"  , "QRY_REP", STR0011, "@!", 70, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Nome Benef."
    TRCell():New(oSection, "V5E_DATAFG", "QRY_REP", STR0012, /*cPicture*/, 35, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Dt. Fato Gerador"
	TRCell():New(oSection, "V5E_NATREN", "QRY_REP", STR0013, "@!", 22, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Nat. Rend."	
	TRCell():New(oSection, "V5E_VLRBRU", "QRY_REP", STR0014, "@E 99,999,999.99", 22, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Vlr. Bruto"
	TRCell():New(oSection, "V5E_VLRTRI", "QRY_REP", STR0015, "@E 99,999,999.99", 35, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Vlr. Tributavel"
	TRCell():New(oSection, "V5E_VLRIR" , "QRY_REP", STR0016, "@E 99,999,999.99", 22, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"Vlr. IR"
    TRCell():New(oSection, "V4Q_EVADIC", "QRY_REP", STR0017, "@!", 15, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER", /*lLineBreak*/, "CENTER", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)//"EvAdic"
	
	//Totalizadores
	TRFunction():New(oSection:Cell("V5E_VLRBRU"), /*cName*/, "SUM", /*oBreak*/, /*cTitle*/, "@E 99,999,999.99", /*uFormula*/, .F.)
    TRFunction():New(oSection:Cell("V5E_VLRTRI"), /*cName*/, "SUM", /*oBreak*/, /*cTitle*/, "@E 99,999,999.99", /*uFormula*/, .F.)
    TRFunction():New(oSection:Cell("V5E_VLRIR"), /*cName*/, "SUM", /*oBreak*/, /*cTitle*/, "@E 99,999,999.99", /*uFormula*/, .F.)
	TRFunction():New(oSection:Cell("V5E_NATREN"), /*cName*/, "COUNT", /*oBreak*/, /*cTitle*/, "@!", /*uFormula*/, .F.)
	
Return oReport

/*/{Protheus.doc} RepPrint
Impressao do relatorio TAF619Rel
@author Carlos Pister
@since 06/12/2023
@version 1.0
@type function
/*/

Static Function RepPrint(oReport)

	Local aArea    as Array
	Local cSql     as Character
	Local oSectDad as Object
	Local nAtual   as Numeric
	Local nTotal   as Numeric

    aArea    := FWGetArea()
	cSql     := ""
	oSectDad := Nil
	nAtual   := 0
	nTotal   := 0
	
	//Pegando as secoes do relatorio
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cSql += "SELECT "		    
	cSql += "V4Q_FILIAL "	    
    cSql += ", V4Q_PERAPU "		
	cSql += ", V4Q_CPF "	    
    cSql += ", V4Q_IDEXTE "     
    cSql += ", V4Q_NOME "       
	cSql += ", V5E_NATREN "     
	cSql += ", V5E_DATAFG "     
	cSql += ", V5E_VLRBRU "     
	cSql += ", V5E_VLRTRI "     
	cSql += ", V5E_VLRIR "	    
    cSql += ", V4Q_EVADIC "		
    cSql += "FROM " + RetSqlName("V4Q") + " V4Q " 
	cSql += "INNER JOIN " + RetSqlName("V5E") + " V5E ON V5E_FILIAL = V4Q_FILIAL AND V5E_ID = V4Q_ID AND V5E.D_E_L_E_T_ = '' "		
	cSql += "WHERE "		                                       
    cSql += "V4Q_FILIAL = '" + xFilial("V4Q") + "'                 
	cSql += "AND V4Q_ORIGEM = 'I' "		                           
	cSql += "AND V4Q_ATIVO = '1' "		                           
	cSql += "AND V4Q_PERAPU = '" + MV_PAR01 + "'"		           
    cSql += "AND V4Q_EVADIC = '" + AllTrim(MV_PAR02) + "'"		           
    cSql += "AND V4Q.D_E_L_E_T_ = ''"		                       
	
	//Executando consulta e setando o total da regua
	PlsQuery(cSql, "QRY_REP")
	DbSelectArea("QRY_REP")
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_REP->(DbGoTop())
	While ! QRY_REP->(Eof())
	
		//Incrementando a regua
		nAtual++
		oReport:SetMsgPrint(STR0018 + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")//"Imprimindo registro "
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_REP->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_REP->(DbCloseArea())
	
	FWRestArea(aArea)
Return
