#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPR4080.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR4080
Rotinas de apuração do evento 4080- Retenção no recebimento
Registro R-4080 da Reinf 2.0

@author Karen Honda
@since  23/11/2019
@version 1.0
/*/
Function TAFAPR4080(cPeriod, cIdApReinf, aFil, lValid, lSucesso, cCNPJFont, lReinf212 )
Local cAmbReinf as Character
Local oModel602 as Object

Local aFilSel   as Array
Private aMovs as array

Default cPeriod    := ""
Default cIdApReinf := ""
Default aFil 	   := { "", "", "","", "", "", .T. }
Default lValid	   := .F.	
Default lSucesso   := .F.
Default lReinf212  := .F.


aMovs      := {}
aFilSel    := {}

oModel602 := FWLoadModel("TAFA602")
cAmbReinf := Left(GetNewPar( "MV_TAFAMBR", "2" ),1)
TAFR4080( cPeriod, cIdApReinf, aFil, lValid, @lSucesso, cAmbReinf, @aMovs, @oModel602, cCNPJFont,, lReinf212 )

oModel602:Destroy() 
oModel602 := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFR4080
Rotinas de apuração do evento 4080- Retenção no recebimento
Registro R-4080 da Reinf 2.0
Contem a inteligencia de verificação de cada status do modelo, e toma a ação necessário de acordo com o status retornado

@author Karen Honda
@since  23/11/2019
@version 1.0
/*/

Static Function TAFR4080(cPeriod, cIdApReinf, aFil, lValid, lSucesso, cTpAmb, aMovs, oModel602, cCNPJFont, lAutomato, lReinf212 )

Local cFilAux    as Character
Local cStatus    as Character
Local cVerAnt	 as Character
Local cProTpn    as Character
Local cId		 as Character
Local cAliasV4K  as Character
Local lDsarm     as Logical
Local cNrInsc    as Character
Local cTpInsc    as Character
Local cEvento    as Character 
Local cErro      as Character
Local aLog       as array
Local nContLog   as numeric

Default cPeriod	:= "" 
Default cIdApReinf := ""
Default aFil 	   := { "", "", "", "", "", "", .F. }
Default lValid	   := .F.	
Default lSucesso   := .F.
Default cTpAmb     := ""
Default aMovs      := {}
Default cCNPJFont  := ""
Default lAutomato  := .T.
Default lReinf212  := .F.

cFilAux     := ""
cStatus     := ""
cVerAnt	    := ""  
cProTpn     := ""    
cId		    := ""  
cErro       := ""
cAliasV4K   := ""
cEvento     := ""
cNrInsc     := ""
cTpInsc     := ""
lDsarm      := .F.
aLog        := {}
nContLog    := 0

DbSelectArea("V97")
V97->(DbSetOrder(2)) //V97_FILIAL, V97_PERAPU, V97_TPINSC, V97_NRINSC, V97_NRINSF, V97_ATIVO, R_E_C_N_O_, D_E_L_E_T_

If !Empty(cPeriod)
    cAliasV4K	    := Qry4080(cPeriod, aFil,cCNPJFont, lReinf212 )
EndIf

If (cAliasV4K)->( !Eof() )
    lSucesso    := .T.
    cNrInsc	:=	Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , (cAliasV4K)->FIL , { "M0_CGC" } )[1][2]) 
    cTpInsc :=  Iif(LEN(cNrInsc)==14, "1", "2")
                            
    cStatus := Stats4080( xFilial("V97") + cPeriod + cTpInsc + cNrInsc + (cAliasV4K)->CNPJFONT, @cVerAnt, @cProTpn, @cId )
    Begin Transaction
        Do Case
        Case cStatus == "Z" //Commit do modelo em modo de inclusão
            cEvento	:= 'I'	
            If Grava4080(MODEL_OPERATION_INSERT, cAliasV4K, cPeriod, cTpInsc, cNrInsc, cIdApReinf, cEvento, , , , , aFil, cTpAmb,aMovs, @oModel602, @aLog, lReinf212 )
                lDsarm := .T.
            EndIf   
        Case cStatus $ ' |0|1|3|7'
            If ExcluiReg(cIdApReinf, cPeriod, oModel602, @aLog) .And. lAutomato
                If cStatus<>'7' .And. V97->V97_EVENTO=='A'
                    cEvento	:= 'A'
                    If Grava4080(MODEL_OPERATION_INSERT,cAliasV4K,cPeriod,cTpInsc,cNrInsc,cIdApReinf,cEvento,V97->V97_VERANT,V97->V97_PROTPN, ,cId , aFil, cTpAmb,aMovs, @oModel602, @aLog, lReinf212)
                        lDsarm := .T.
                    EndIf
                else
                cEvento	:= 'I'
                If Grava4080(MODEL_OPERATION_INSERT,cAliasV4K,cPeriod,cTpInsc,cNrInsc,cIdApReinf,cEvento, , , , , aFil, cTpAmb,aMovs, @oModel602, @aLog, lReinf212 )
                        lDsarm := .T.
                    EndIf
                Endif 
            Else 
                lDsarm := .T.
            EndIf

        //Registro transmitido ao governo e sem retorno, não deve ser alterado
        Case cStatus $ '2|6'
            cErro   := STR0002 + CRLF //"Registro transmitido ao governo e sem retorno, não deve ser alterado."  
            cErro	+= STR0001 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
            cErro 	+= "tpInscEstab: " + cTpInsc + CRLF
            cErro 	+= "nrInscEstab: " + cNrInsc + CRLF 
            cErro 	+= STR0007 + (cAliasV4K)->CNPJFONT + CRLF + CRLF //"Nr Insc Pagadora: "

            Aadd(aLog, {'R-4080', "ERRO", cErro}) // "ERRO"
            //TafXLog(cIdApReinf, "R-4080", "ERRO", cErro, cPeriod )
            lSucesso    := .F.

        Case cStatus == '4'
            cEvento	:= 'A'
            FAltRegAnt( 'V97', '2', .F. ) //Inativa o registro anterior
            If Grava4080(MODEL_OPERATION_INSERT, cAliasV4K, cPeriod, cTpInsc, cNrInsc, cIdApReinf, cEvento, cVerAnt, cProTpn, cStatus, cId, aFil, cTpAmb,aMovs, @oModel602, @aLog, lReinf212 )
                lDsarm := .T.
            EndIf
        EndCase

        If lDsarm
            lSucesso    := .F.
            DisarmTransaction()
        EndIf
    End Transaction 

    For nContLog := 1 to Len (aLog) 
	    TafXLog(cIdApReinf, aLog[nContLog][1], aLog[nContLog][2], aLog[nContLog][3], cPeriod )
	Next nContLog
EndIf    
If !Empty(cAliasV4K)
    (cAliasV4K)->( DbCloseArea() )
EndIf    

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Qry4080
Query para apuração do evento R-4080- Retenção no recebimento
Registro R-4080 da Reinf 2.0

@author Karen Honda
@since  23/11/2019
@version 1.0
/*/ 

Static Function Qry4080(cPeriod, aFil, cCNPJFont, lReinf212 )

Local cAliasV4K     as Character
Local cDataIni      as Character
Local cDataFim      as Character
Local cQuery        as Character
Local cFilsV4K	    as Character
Local cCompC1H      as Character
Local aInfoEUF      as Array

Default cPeriod     := ""
Default aFil        := {}
Default lReinf212   := .F.

cCompC1H  := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))	
cFilsV4K := TafRetFilC("V4K", aFil )
cDataIni := Substr(cPeriod,3,4) + Substr(cPeriod,1,2) + "01" //ex: 20220201
cDataFim := DtoS( LastDay( StoD( cDataIni ) ) )
aInfoEUF 	:= TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))

cAliasV4K := GetNextAlias() 
cQuery := "SELECT V4K.V4K_FILIAL FIL, V4K.V4K_ID V4KID, V4K.V4K_CODDOC CODDOC, V4K.V4K_IDNATR NATREN, V4K.V4K_DTPAG DTPAG, V4K.V4K_VLREAJ VLRBRU, "
cQuery += "V4K.V4K_BASEIR BASEIR, V4K.V4K_VLRIR VLRIR, V4K.V4K_DESCRI DESCRI, V4K.R_E_C_N_O_ RECNO, V3O.V3O_CODIGO CODNAT, V3O.V3O_DESCR DESCNAT, "
cQuery += "C1H.C1H_NOME NOME, C1H.C1H_CNPJ CNPJFONT, C1H.C1H_CODPAR CODPAR, C1H.C1H_ID IDPART "
cQuery += "FROM " + RetSqlName("V4K") + " V4K "
cQuery += "INNER JOIN " + RetSqlName("V3O") + " V3O "
cQuery += "ON V3O.V3O_FILIAL = '" + xFilial("V3O") + "' "
cQuery += "AND V3O.V3O_ID = V4K.V4K_IDNATR AND V3O.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN " + RetSqlName("C1H") + " C1H "
If cCompC1H == "EEE"
    cQuery += "ON C1H.C1H_FILIAL = V4K.V4K_FILIAL "			
ElseIf cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
    cQuery += "ON SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(V4K.V4K_FILIAL, 1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
    cQuery += "ON SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(V4K.V4K_FILIAL, 1," + cValToChar(aInfoEUF[1]) + ") "
Else
    cQuery += "ON C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "			
EndIf
cQuery += "AND C1H.C1H_ID = V4K.V4K_IDPART AND C1H.D_E_L_E_T_ = ' ' "
cQuery += "AND C1H.C1H_PPES   = '2' "
cQuery += "WHERE "
cQuery += "V4K.V4K_FILIAL IN " + cFilsV4K + " "
cQuery += "AND V4K.V4K_DTPAG BETWEEN  '" + cDataIni + "' AND '" + cDataFim + "' "
cQuery += "AND V4K.V4K_INDNAT = '1' "
cQuery += "AND V4K.D_E_L_E_T_ = ' ' "
cQuery += "AND C1H.C1H_CNPJ = " + cCNPJFont + " "
cQuery += "ORDER BY C1H.C1H_CNPJ, V4K.V4K_IDNATR, V4K.V4K_DTPAG "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasV4K,.F.,.T.)
TCSetField(cAliasV4K, "VLRBRU" ,"N", 14, 2 )
TCSetField(cAliasV4K, "BASEIR" ,"N", 14, 2 )
TCSetField(cAliasV4K, "VLRIR"  ,"N", 14, 2 )
TCSetField(cAliasV4K, "DTPAG"  ,"D" )

Return cAliasV4K


//-------------------------------------------------------------------
/*/{Protheus.doc} Grava4080
Efetua gravação no modelo da tabela espelho do evento R-4080 da Reinf 2.0
(Rotinas de apuração da Retenção no recebimento)

@author Karen Honda
@since  23/11/2019
@version 1.0
/*/
Static Function Grava4080(nOpc, cAliasV4K, cPeriod,cTpInsc,cNrInsc,cIdApReinf, cEvento, cVerAnt, cProTpn, cRetStat, cId, aFil, cTpAmb,aMovs, oModel602, aErro, lReinf212 )

Local nC1EArray  as Numeric
Local nTamFil    as Numeric
Local aInfoC1E   as Array

Local cChvV98    as Character
Local cChvV99    as Character
Local nQtdV98    as Numeric
Local nQtdV99    as Numeric
Local nQtdV9A    as Numeric
Local aSeek      as Array
Local cMsg       as Character

Local lRollBack     as Logical
Local oModelV98	    as Object
Local oModelV99	    as Object
Local oModelV97	    as Object
Local oModelV9A	    as Object

Default nOpc        := 3
Default cAliasV4K   := ""
Default cPeriod     := ""
Default cTpInsc     := ""
Default cNrInsc     := ""
Default cIdApReinf  := ""
Default cEvento     := "I"
Default	cVerAnt	    := ""
Default cProTpn	    := ""
Default cRetStat    := ""
Default cId		    := ""
Default aFil        := {}
Default cTpAmb      := ""
Default aMovs       := {}
Default aErro       := {}
Default lReinf212   := .F.

nC1EArray := ASCAN(aFil,{|x|x[7]})
nTamFil   := len( aFil )
 
cChvV98   := ""
cChvV99   := ""
nQtdV98   := 0
nQtdV99   := 0
nQtdV9A   := 0
lRollBack := .F.
oModelV97 := oModel602:GetModel("MODEL_V97")
oModelV98 := oModel602:GetModel("MODEL_V98")
oModelV99 := oModel602:GetModel("MODEL_V99")
oModelV9A := oModel602:GetModel("MODEL_V9A")
V4K->(DbSetOrder(1))

aInfoC1E  := {}
If nC1EArray > 0 
    AADD(aInfoC1E,aFil[nC1EArray][1])
    AADD(aInfoC1E,aFil[nC1EArray][4])
Elseif nTamFil > 0
	AADD(aInfoC1E,aFil[nTamFil][1])
	AADD(aInfoC1E,aFil[nTamFil][4])  
EndIf

oModel602:SetOperation(nOpc)
oModel602:Activate()

If !Empty(cVerAnt)
	oModel602:LoadValue( 'MODEL_V97', 'V97_VERANT', cVerAnt )
	oModel602:LoadValue( 'MODEL_V97', 'V97_PROTPN', cProTpn )
	oModel602:LoadValue( 'MODEL_V97', 'V97_ID'	  , cId     )
EndIf

oModel602:LoadValue('MODEL_V97', 'V97_VERSAO'  , xFunGetVer())
oModel602:LoadValue('MODEL_V97', 'V97_STATUS'  , '')
oModel602:LoadValue('MODEL_V97', 'V97_EVENTO'  , cEvento)
oModel602:LoadValue('MODEL_V97', 'V97_ATIVO'   , '1')
oModel602:LoadValue('MODEL_V97', 'V97_PERAPU'  , cPeriod)	
oModel602:LoadValue('MODEL_V97', 'V97_TPAMB'   , cTpAmb)	
oModel602:LoadValue('MODEL_V97', 'V97_IDESTA'  , aInfoC1E[1])
oModel602:LoadValue('MODEL_V97', 'V97_DESTAB'   , aInfoC1E[2])
oModel602:LoadValue('MODEL_V97', 'V97_TPINSC'  , cTpInsc)		//tpInscEstab - CNPJ
oModel602:LoadValue('MODEL_V97', 'V97_NRINSC'  , cNrInsc) 	//nrInscEstab		
oModel602:LoadValue('MODEL_V97', 'V97_CODPAR'  , (cAliasV4K)->CODPAR)		
oModel602:LoadValue('MODEL_V97', 'V97_IDPART'  , (cAliasV4K)->IDPART)
oModel602:LoadValue('MODEL_V97', 'V97_NRINSF'  , (cAliasV4K)->CNPJFONT)
oModel602:LoadValue('MODEL_V97', 'V97_DPARTI'  , (cAliasV4K)->NOME)

While (cAliasV4K)->( !Eof() ) 

    ++nQtdV98

    oModelV98:lValid := .T. 
    If nQtdV98 > 1 .and. nOpc == MODEL_OPERATION_INSERT .and. (cChvV98) != (cAliasV4K)->CNPJFONT + (cAliasV4K)->NATREN
        oModelV98:AddLine()
    EndIf 
    cChvV98 := (cAliasV4K)->CNPJFONT + (cAliasV4K)->NATREN
    oModelV98:LoadValue('V98_NATREN', (cAliasV4K)->CODNAT )
    oModelV98:LoadValue('V98_DNATRE', (cAliasV4K)->DESCNAT )
    oModelV98:LoadValue('V98_OBS', (cAliasV4K)->DESCRI )

    nQtdV99 := 0
    nQtdV9A := 0
    cChvV99 := (cAliasV4K)->CNPJFONT + (cAliasV4K)->NATREN + dToS((cAliasV4K)->DTPAG)
    While (cAliasV4K)->( !Eof() ) .AND. (cChvV98) == (cAliasV4K)->CNPJFONT + (cAliasV4K)->NATREN
        ++nQtdV99 
        
        oModelV99:lValid:= .T. 
        If nQtdV99 > 1 .AND. nOpc == MODEL_OPERATION_INSERT .and. cChvV99 != (cAliasV4K)->CNPJFONT + (cAliasV4K)->NATREN + dtoS((cAliasV4K)->DTPAG)
            oModelV99:AddLine()
            nQtdV9A := 0
        EndIf
        cChvV99 := (cAliasV4K)->CNPJFONT + (cAliasV4K)->NATREN + dToS((cAliasV4K)->DTPAG)
        
        oModelV99:LoadValue('V99_DATAFG', (cAliasV4K)->DTPAG)
        oModelV99:LoadValue('V99_VLRBRU', (cAliasV4K)->VLRBRU + FWFldGet( "V99_VLRBRU" ))
        oModelV99:LoadValue('V99_BASEIR', (cAliasV4K)->BASEIR + FWFldGet( "V99_BASEIR" ))
        oModelV99:LoadValue('V99_VLRIR' , (cAliasV4K)->VLRIR  + FWFldGet( "V99_VLRIR" ))
        If lReinf212
            If V4K->( MsSeek( xFilial( "V4K" ) + (cAliasV4K)->V4KID ) )
                If !Empty( V4K->V4K_OBSERV )
                    oModelV99:LoadValue('V99_OBSERV', V4K->V4K_OBSERV ) //observ            
                Endif
            endif
        Endif

        If V9B->( DbSeek( (cAliasV4K)->FIL + (cAliasV4K)->V4KID ) )
            While V9B->( !Eof() ) .and. V9B->V9B_FILIAL + V9B->V9B_ID == (cAliasV4K)->FIL + (cAliasV4K)->V4KID
                aSeek := {}
                ++nQtdV9A
                aAdd(aSeek, {"V9A_IDPROC", V9B->V9B_IDPROC } )
                aAdd(aSeek, {"V9A_CODSUS", V9B->V9B_CODSUS } )
                If nQtdV9A > 1 .AND. nOpc == MODEL_OPERATION_INSERT .and. !oModelV9A:SeekLine( aSeek )
                    oModelV9A:AddLine()
                EndIf

                oModelV9A:LoadValue('V9A_IDPROC', V9B->V9B_IDPROC)
                oModelV9A:LoadValue('V9A_TPPROC', V9B->V9B_TPPROC)
                oModelV9A:LoadValue('V9A_NRPROC', V9B->V9B_NRPROC)
                oModelV9A:LoadValue('V9A_CODSUS', V9B->V9B_CODSUS)
                oModelV9A:LoadValue('V9A_IDSUSP', V9B->V9B_IDSUSP)
                oModelV9A:LoadValue('V9A_BSUSIR', V9B->V9B_BSUSIR + FWFldGet( "V9A_BSUSIR" ))
                oModelV9A:LoadValue('V9A_VSUSIR', V9B->V9B_VSUSIR + FWFldGet( "V9A_VSUSIR" ))
                oModelV9A:LoadValue('V9A_VLRDEP', V9B->V9B_VLRDEP + FWFldGet( "V9A_VLRDEP" ))

                V9B->( DbSkip() )
            EndDo    
        EndIf

        aAdd(aMovs, {(cAliasV4K)->RECNO})

        (cAliasV4K)->(DbSkip())
    EndDo
EndDo

If !lRollBack 
    If oModel602:VldData()
        FwFormCommit(oModel602)		
        TafEndGRV( "V97","V97_PROCID", cIdApReinf, V97->(Recno())) //Grava PROCID na espelho
        GravaId(aMovs, cIdApReinf) //Grava PROCID no legado

        //Exito Gravacao
        cMsg := STR0003 + CRLF //"Processamento realizado com sucesso."
        cMsg += STR0004 + AllTrim(cNrInsc) + CRLF //"Nr Insc: "
        cMsg += STR0007 + AllTrim(V97->V97_NRINSF) + CRLF //"Nr Insc Pagadora: "
        cMsg += STR0005 + cValToChar( cIdApReinf ) + " Recno:" + cValToChar( V97->(Recno())) //"Apuracao Id:"
        TafXLog(cIdApReinf, "R-4080", "MSG", cMsg, cPeriod )
    Else
        lRollBack := .T.
        cMsg 		:= STR0006 + CRLF + CRLF //"Detalhes técnicos do erro: "
        cMsg		+= TafRetEMsg(oModel602)
        //TafXLog(cIdApReinf, "R-4080", "ERRO", cMsg, cPeriod )
        Aadd(aErro, {'R-4080', "ERRO", cMsg})
    EndIf
EndIf

oModel602:DeActivate()

Return lRollBack

//-------------------------------------------------------------------
/*/{Protheus.doc} Stats4080
Verifica a existência ou não do registro que será apurado

@author Leticia Campos, Katielly Feitosa
@since 26/08/2019
@version 1.0

@parameters Retorna o status do registro encontrado, caso contrário retorna status "Z", 
indicando que ainda não existe o registro no cadastro espelho
@return
/*/ 
Static Function Stats4080(cChave , cVerAnt, cProTpn, cId )

Local cRetStat   as Character

Default cChave   := "" 
Default cVerAnt  := ""
Default cProTpn  := ""
Default cId		 := ""

cRetStat   := ""

If V97->( DbSeek( cChave + '1') ) //cPeriod + cTpInsc + cNrInsc 
    cVerAnt	 := V97->V97_VERSAO
    cProTpn  := V97->V97_PROTUL
    cRetStat := V97->V97_STATUS
    cId		 := V97->V97_ID
Else
    cVerAnt  := ""
    cProTpn  := ""
    cRetStat := "Z"
    cId		 := ""
EndIf

Return cRetStat 

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiReg()
Efetua a exclusão do modelo conforme parâmetro

@author Katielly Feitosa
@since 28/08/2019
@version 1.0
@return
/*/ 

Static Function ExcluiReg(cIdApReinf, cPeriod, oModel602, aErro, lAutomato )

Local cErro		As Character
Local cTpInscEst as Character
Local cNrInscEst as Character
Local oModel     as Object
Local lExcluiu   as Logical

Default lAutomato := .T.
Default aErro     := {}

oModel 		:= oModel602 
cTpInscEst	:= V97->V97_TPINSC
cNrInscEst	:= V97->V97_NRINSC
lExcluiu    := .T.

oModel:SetOperation(5)
oModel:Activate()

If FwFormCommit(oModel) .And. lAutomato
	lExcluiu := .T.
Else
	cErro	:= STR0001 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
	cErro 	+= "nrInscEstab: " + Alltrim(cNrInscEst) + CRLF
	cErro 	+= TafRetEMsg(oModel)
    //TafXLog(cIdApReinf, "R-4080", "ERRO", cErro, cPeriod )
    Aadd(aErro, {'R-4080', "ERRO", cErro})
	lExcluiu := .F.    
EndIf

oModel:DeActivate()

Return lExcluiu

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaId()
Função que grava o PROCID na tabela legado

@author Karen Honda
@since  23/11/2019
@version 1.0
@return
/*/ 
Static Function GravaId(aMovs, cIdApur)

Local	nX	as numeric

Default cIdApur	:= ''
Default aMovs 	:= {}

For nX := 1 to Len(aMovs)
    TafEndGRV( "V4K","V4K_PRID40", cIdApur, aMovs[nX][1]  )
Next nX

Return

