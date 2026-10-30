#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE 'GTPR423B.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR423B()
Relatório DER modelo 2

@sample GTPR423B()

@author jose.darocha
@since 09/01/2025
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR423B()

	Local oReport
	Local cPerg  	:= 'GTPR423'
	Local aAreaAtu 	:= GetArea()

	If ( !FindFunction("GTPHASACCESS") .Or.; 
		( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

		If Pergunte(cPerg, .T.)
			oReport := ReportDef(cPerg)
			oReport:PrintDialog()
		EndIf 

	EndIf

	RestArea( aAreaAtu )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Relatório DER modelo 2

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author jose.darocha 
@since 09/01/2025
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)

	Local cTitle    := STR0001  //"Relatório DER - Modelo 2" 	
	Local cHelp     := STR0002  //"Resumo diário e a consolidação mensal"
	Local cAliasQry := GetNextAlias()
	Local oReport
	Local oSecReg_J
	Local oSecReg_P
	Local oSecReg_P9999
    Local nJ := 0

    Local aRegJ     := {}
    Local aRegP     := {}
    Local aRegP999  := {}

    //01-Posição inicial
    //02-Tamanho
    aadd(aRegJ,{01,01,STR0003})     //'Tipo'
    aadd(aRegJ,{02,04,STR0004})     //'Cod.Emp.'             
    aadd(aRegJ,{06,10,STR0005})     //'Linha'
    aadd(aRegJ,{16,04,STR0006})     //'Fixo'
    aadd(aRegJ,{20,01,STR0006})     //'Fixo'
    aadd(aRegJ,{21,05,STR0007})     //'T.Viag.Ord.'
    aadd(aRegJ,{26,07,STR0008})     //'T.lUG.Ord.'
    aadd(aRegJ,{33,05,STR0009})     //'T.Mult.Real.'
    aadd(aRegJ,{38,07,STR0010})     //'T.Lug.Ofer'
    aadd(aRegJ,{45,05,STR0011})     //'T.Viag.Real.'
    aadd(aRegJ,{50,07,STR0012})     //'T.Lug.Ofer.Ref.'
    aadd(aRegJ,{57,05,STR0013})     //'T.Viag.Ref.Parc.'
    aadd(aRegJ,{62,07,STR0014})     //'T.Lug.Ofer.Parc.'
    aadd(aRegJ,{69,06,STR0015})     //'Somatoria 1'
    aadd(aRegJ,{75,08,STR0016})     //'Somatoria 2'
    aadd(aRegJ,{83,08,STR0017})     //'Dt.Grav.Arq.'
    aadd(aRegJ,{91,04,STR0018})     //'Hr.Nao Obrig.'    
    aadd(aRegJ,{95,01,STR0006})     //'Fixo'    

    aadd(aRegP,{01,01,STR0003})     //'Tipo'
    aadd(aRegP,{02,04,STR0004})     //'Cod.Emp.'
    aadd(aRegP,{06,10,STR0005})     //'Linha'
    aadd(aRegP,{16,04,STR0019})     //'Seção'        
    aadd(aRegP,{20,01,STR0020})     //'Digito'
    aadd(aRegP,{21,06,STR0021})     //'T. Ida Ord.'
    aadd(aRegP,{27,06,STR0022})     //'T. Volta Ord.'
    aadd(aRegP,{33,06,STR0023})     //'T. Ida Mult.'
    aadd(aRegP,{39,06,STR0024})     //'T. Volta Mult.'
    aadd(aRegP,{45,06,STR0025})     //'T. Ida Reforço Total'
    aadd(aRegP,{51,06,STR0026})     //'T. Volta Reforço Total'
    aadd(aRegP,{57,06,STR0027})     //'T. Ida Reforço Parc.'
    aadd(aRegP,{63,06,STR0028})     //'T. Volta Reforço Parc.'
    aadd(aRegP,{69,05,STR0029})     //'Qtde. Reforço Parc.'
    aadd(aRegP,{74,07,STR0030})     //'T.passag.pagaram 1a'
    aadd(aRegP,{81,07,STR0031})     //'T.passag.pagaram 2a'
    aadd(aRegP,{88,07,STR0032})     //'T.passag.pagaram 3a'
    aadd(aRegP,{95,01,STR0006})     //'Fixo'

    aadd(aRegP999,{01,01,STR0003})  //'Tipo'
    aadd(aRegP999,{02,04,STR0004})  //'Cod.Emp.'
    aadd(aRegP999,{06,10,STR0005})  //'Linha'
    aadd(aRegP999,{16,04,STR0006})  //'Fixo'
    aadd(aRegP999,{20,01,STR0006})  //'Fixo'
    aadd(aRegP999,{21,20,STR0033})  //'Brancos'
    aadd(aRegP999,{41,07,STR0034})  //'T.passag.1a.'
    aadd(aRegP999,{48,07,STR0035})  //'T.passag.2a.'
    aadd(aRegP999,{55,07,STR0036})  //'T.passag.Pagaram'
    aadd(aRegP999,{62,11,STR0037})  //'Receita'
    aadd(aRegP999,{73,11,STR0038})  //'ICMS Devido'
    aadd(aRegP999,{84,11,STR0039})  //'IASP Devido'
    aadd(aRegP999,{95,11,STR0006})  //'Fixo'

	oReport := TReport():New('GTPR423B',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry,aRegJ,aRegP,aRegP999)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,.F./*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
	oReport:SetPortrait(.T.)
	oReport:nFontBody := 5
	oReport:SetTotalInLine(.F.)
    oReport:SetLandscape()

	oSecReg_J := TRSection():New(oReport, 'REGISTROJ', NIL)
	oSecReg_J:SetTotalInLine(.F.)

    For nJ:=1 To Len(aRegJ)
    	TRCell():New(oSecReg_J,"CAMPOJ"+cValTochar(nJ), '', aRegJ[nJ][03] , /*Picture*/, aRegJ[nJ][2]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    Next nJ

	oSecReg_P := TRSection():New(oReport,'REGISTROP',NIL)
	oSecReg_P:SetTotalInLine(.F.)

    For nJ:=1 To Len(aRegP)
    	TRCell():New(oSecReg_P,"CAMPP"+cValTochar(nJ), '', aRegP[nJ][03] , /*Picture*/, aRegP[nJ][2]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    Next nJ

	oSecReg_P9999 := TRSection():New(oReport,'REGISTROP99',NIL)
	oSecReg_P9999:SetTotalInLine(.F.)

    For nJ:=1 To Len(aRegP999)
    	TRCell():New(oSecReg_P9999,"CAMPP9"+cValTochar(nJ), '', aRegP999[nJ][03] , /*Picture*/, aRegP999[nJ][2]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    Next nJ

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query

@author jose.darocha 
@since 31/01/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry,aRegJ,aRegP,aRegP999)

	Local oSecReg_J     := oReport:Section(1)
	Local oSecReg_P     := oReport:Section(2)
	Local oSecReg_P9999 := oReport:Section(3)

	Local cMes          := PadL(AllTrim(Str(Month(MV_PAR06))),2, '0' )
	Local cAno          := AllTrim(Str(Year(MV_PAR06)))
    Local cBlocoJ       := ''
    Local cBlocoP       := ''
    Local cBlcP99       := ''

    Local cNumLin       := ''
    Local aInfs         := {}
    Local nTotOrd       := 0
    Local nTotRT        := 0
    Local aDdLinha      := {}
    Local lFimGrv       := .T.
    Local nX            := 0
    Local nJ            := 0
    Local nP            := 0
    Local nP99          := 0
    Local aDadosJ       := {}
    Local aDadosP       := {}
    Local aDadosP99     := {}
    Local nArray        := 0
    Local aProcJ        := {}
    Local nPos          := 0
    Local cCodLinha     := 0

	oSecReg_J:BeginQuery()

        //Seleciona os dados
        G423RetLin(@cAliasQry ) 
	
	oSecReg_J:EndQuery()
	
	oReport:SetMeter((cAliasQry)->(RecCount()))
	
	While !oReport:Cancel() .AND. (cAliasQry)->(!Eof())

        //Inicia as variaveis
        cBlocoJ       := ''
        cBlocoP       := ''
        cBlcP99       := ''
        aDdLinha      := {}

		//oReport:StartPage()
        oReport:IncMeter()

        cNumLin := (cAliasQry)->GI2_NUMLIN

        G423TViag(cNumLin, MV_PAR06, MV_PAR07, @nTotOrd, @nTotRT)
        
        G423RetTrc(cNumLin, @aInfs,nTotOrd,nTotRT)
        
        //Imprimir dados
        If G423ValCCSGI4((cAliasQry)->GI2_COD) 

            //Para cada linha monta os blocos J,P e P9999.	
            G423MntBloco( cAliasQry, @aInfs, @aDdLinha, @lFimGrv, cAno+cMes ) 

            For nX:=1 To Len(aDdLinha)
                cBlocoJ := aDdLinha[1]
                cBlocoP := aDdLinha[2]
                cBlcP99 := aDdLinha[3]

                cCodLinha := Substring( cBlocoJ,6,10)

                Aadd( aDadosJ,  {cCodLinha,cBlocoJ})
                Aadd( aDadosP,  {cCodLinha,cBlocoP})
                Aadd( aDadosP99,{cCodLinha,cBlcP99})

            Next nX 

        EndIf 

        (cAliasQry)->(dbSkip())

    EndDo 

    //Ordenar po Linha
    aSort(aDadosJ,,,{|x,y| x[1] < y[1] })
    aSort(aDadosP,,,{|x,y| x[1] < y[1] })
    aSort(aDadosP99,,,{|x,y| x[1] < y[1] })

    For nJ:=1 To Len(aDadosJ)
        cCodLinha   := aDadosJ[nJ][1]
        cBlocoJ     := aDadosJ[nJ][2]

        IF nJ == 1
            oReport:StartPage()
        EndIf 
        If !Empty(cBlocoJ)
            oSecReg_J:Init()
            For nArray:=1 To Len(aRegJ)
                oSecReg_J:Cell("CAMPOJ"+cValTochar(nArray)):SetValue( Substr(cBlocoJ,aRegJ[nArray][01],aRegJ[nArray][02]) ) 
            Next nArray 
            oSecReg_J:PrintLine()	
        EndIf 

        If Ascan(aProcJ,{|x| x == cCodLinha }) == 0
            Aadd(aProcJ,cCodLinha)
            If nJ > 1 .Or. nJ == Len(aDadosJ)
                oSecReg_J:Finish()
                nPos := Iif( nJ == Len(aDadosJ),nJ,nJ-1)                    
                cCodLinha := aDadosJ[nPos][1]

                //BLOCO P
                If ( nPos:= Ascan(aDadosP,{|x| x[1] == cCodLinha }) ) > 0
                    For nP:= nPos To Len(aDadosP)
                        If cCodLinha == aDadosP[nP][1]
                            cBlocoP := aDadosP[nP][2]
                            If !Empty(cBlocoP)
                                oSecReg_P:Init()
                                For nArray:=1 To Len(aRegP)
                                    oSecReg_P:Cell("CAMPP"+cValTochar(nArray)):SetValue( Substr(cBlocoP,aRegP[nArray][01],aRegP[nArray][02]) ) 
                                Next nArray 
                                oSecReg_P:PrintLine()	
                            EndIf 
                        EndIf 
                    Next nP   
                    oSecReg_P:Finish()  
                EndIf

                //BLOCO P SECAO 9999
                If ( nPos:= Ascan(aDadosP99,{|x| x[1] == cCodLinha }) ) > 0
                    For nP99:= nPos To Len(aDadosP99)
                        If cCodLinha == aDadosP99[nP99][1]
                            cBlcP99 := aDadosP99[nP99][2]
                            If !Empty(cBlcP99)
                                oSecReg_P9999:Init()
                                For nArray:=1 To Len(aRegP999)
                                    oSecReg_P9999:Cell("CAMPP9"+cValTochar(nArray)):SetValue( Substr(cBlcP99,aRegP999[nArray][01],aRegP999[nArray][02]) ) 
                                Next nArray 
                                oSecReg_P9999:PrintLine()	
                            EndIf 
                        EndIf 
                    Next nP99   
                    oSecReg_P9999:Finish()  
                EndIf

            EndIf 
        EndIf

    Next nJ 

    If !Empty(aDadosJ)
        oSecReg_J:Finish()
    EndIF             
    If !Empty(aDadosP)        
        oSecReg_P:Finish()
    EndIF             
    If !Empty(aDadosP99)        
        oSecReg_P9999:Finish()
    EndIf 

    oReport:EndPage()	  
    (cAliasQry)->(DbCloseArea())
   
Return
