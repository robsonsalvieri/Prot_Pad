#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPR4040.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR4040
Rotinas de apuração do Pagamentos a beneficiarios não identificados
Registro R-4040 da Reinf 2.0

@author Leticia Campos; Katielly Feitosa
@since  23/08/2019
@version 1.0
/*/
Function TAFAPR4040(cPeriod, cIdApReinf, aFil, lValid, lSucesso, lReinf212, cIdEvAdic )
Local cAmbReinf as Character
Local oModel543 as Object

Local aFilSel   as Array
Private aMovs as array 

Default cPeriod    := ""
Default cIdApReinf := ""
Default aFil 	   := { "", "", "","", "", "", .T. }
Default lValid	   := .F.	
Default lSucesso   := .F.
Default lReinf212  := .F. 
Default cIdEvAdic  := ""


aMovs      := {}
aFilSel    := {}

oModel543 := FWLoadModel("TAFA543")
cAmbReinf := Left(GetNewPar( "MV_TAFAMBR", "2" ),1)
TAFR4040( cPeriod, cIdApReinf, aFil, lValid, @lSucesso, cAmbReinf, @aMovs, @oModel543, lReinf212, cIdEvAdic )

oModel543:Destroy() 
oModel543 := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFR4040
Rotinas de apuração do Pagamentos a beneficiarios não identificados
Registro R-4040 da Reinf 2.0
Contem a inteligencia de verificação de cada status do modelo, e toma a ação necessário de acordo com o status retornado

@author Leticia Campos; Katielly Feitosa
@since  23/08/2019
@version 1.0
/*/

Static Function TAFR4040(cPeriod, cIdApReinf, aFil, lValid, lSucesso, cTpAmb, aMovs, oModel543, lReinf212, cIdEvAdic )

Local cFilAux    as Character
Local cStatus    as Character
Local cVerAnt	 as Character
Local cProTpn    as Character
Local cId		 as Character
Local cAliasV4K  as Character
Local lDsarm     as Logical
Local cNrInsc    as Character
Local cTpInsc    as Character
Local cErro      as Character
Local cEvento    as Character
Local nContLog   as Numeric
Local aErro      as Array

Default cPeriod	:= "" 
Default cIdApReinf := ""
Default aFil 	   := { "", "", "", "", "", "", .F. }
Default lValid	   := .F.	
Default lSucesso   := .F.
Default cTpAmb     := ""
Default aMovs      := {}
Default lReinf212  := .F.
Default cIdEvAdic  := ""

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
nContLog    := 1
aErro       := {}

DbSelectArea("V4N")
V4N->(DbSetOrder(2)) //V4N_FILIAL, V4N_PERAPU, V4N_TPINSC, V4N_NRINSC, V4N_EVADIC, V4N_ATIVO

If !Empty(cPeriod)
    cAliasV4K	    := Qry4040(cPeriod, aFil, lReinf212)
EndIf

If (cAliasV4K)->( !Eof() )
    lSucesso    := .T.
    cNrInsc	:=	Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , (cAliasV4K)->FIL , { "M0_CGC" } )[1][2]) 
    cTpInsc :=  Iif(LEN(cNrInsc)==14, "1", "2")
            
    cStatus := Stats4040( xFilial("V4N") + cPeriod + cTpInsc + cNrInsc + Iif(lReinf212, cIdEvAdic, ""), @cVerAnt, @cProTpn, @cId )

    Begin Transaction
        Do Case
        Case cStatus == "Z" //Commit do modelo em modo de inclusão
            cEvento	:= 'I'	
            If Grava4040(MODEL_OPERATION_INSERT, cAliasV4K, cPeriod, cTpInsc, cNrInsc, cIdApReinf, cEvento, , , , , aFil, cTpAmb,aMovs, @oModel543,@aErro, lReinf212, cIdEvAdic )
                lDsarm := .T.
            EndIf   
        Case cStatus $ ' |0|1|3|7'
            If ExcluiReg(cIdApReinf, cPeriod, oModel543)
                If cStatus<>'7' .And. V4N->V4N_EVENTO=='A'
                    cEvento	:= 'A'
                    If Grava4040(MODEL_OPERATION_INSERT,cAliasV4K,cPeriod,cTpInsc,cNrInsc,cIdApReinf,cEvento,V4N->V4N_VERANT,V4N->V4N_PROTPN,,cId, aFil, cTpAmb,aMovs, @oModel543,@aErro, lReinf212, cIdEvAdic )
                        lDsarm := .T.
                    EndIf
                else
                    cEvento	:= 'I'
                    If Grava4040(MODEL_OPERATION_INSERT,cAliasV4K,cPeriod,cTpInsc,cNrInsc,cIdApReinf,cEvento, , , , , aFil, cTpAmb,aMovs, @oModel543 ,@aErro, lReinf212, cIdEvAdic )
                        lDsarm := .T.
                    EndIf
                endif
            Else 
                lDsarm := .T.
            EndIf

        //Registro transmitido ao governo e sem retorno, não deve ser alterado
        Case cStatus $ '2|6'
            cMsg  := STR0002 + CRLF //"Registro transmitido ao governo e sem retorno, não deve ser alterado."  
            cMsg  += STR0001 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
            cMsg  += "tpInscEstab: " + cTpInsc + CRLF
            cMsg  += "nrInscEstab: " + cNrInsc + CRLF + CRLF

            lSucesso    := .F.
            Aadd(aErro, {'R-4040', 'ERRO', cMsg})
        Case cStatus == '4'
            cEvento	:= 'A'
            FAltRegAnt( 'V4N', '2', .F. ) //Inativa o registro anterior
            If Grava4040(MODEL_OPERATION_INSERT, cAliasV4K, cPeriod, cTpInsc, cNrInsc, cIdApReinf, cEvento, cVerAnt, cProTpn, cStatus, cId, aFil, cTpAmb,aMovs, @oModel543,@aErro, lReinf212, cIdEvAdic )
                lDsarm := .T.
            EndIf
        EndCase

        If lDsarm
            lSucesso    := .F.
            DisarmTransaction()
        EndIf
    End Transaction

    For nContLog := 1 to Len ( aErro) 
        TafXLog(cIdApReinf, aErro[nContLog][1], aErro[nContLog][2], aErro[nContLog][3], cPeriod )
    Next nContLog
EndIf    
If !Empty(cAliasV4K)
    (cAliasV4K)->( DbCloseArea() )
EndIf    

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Qry4040
Rotinas de apuração do Pagamentos a beneficiarios não identificados
Registro R-4040 da Reinf 2.0
Executa a query principal, esta que é montada por Qury4040()

@author Katielly Feitosa, Leticia Campos
@since  21/08/2019
@version 1.0
/*/ 

Static Function Qry4040(cPeriod, aFil, lReinf212 )

Local cAliasV4K     as Character
Local cDataIni      as Character
Local cDataFim      as Character
Local cQuery        as Character
Local cFilsV4K	    as Character

Default cPeriod     := ""
Default aFil        := {}
Default lReinf212   := .F.

cFilsV4K := TafRetFilC("V4K", aFil )
cDataIni := Substr(cPeriod,3,4) + Substr(cPeriod,1,2) + "01" //ex: 20220201
cDataFim := DtoS( LastDay( StoD( cDataIni ) ) )

cAliasV4K := GetNextAlias() 
cQuery := "SELECT V4K.V4K_FILIAL FIL, V4K.V4K_ID V4KID, V4K.V4K_CODDOC CODDOC, V4K.V4K_IDNATR NATREN, V4K.V4K_DTPAG DTPAG, V4K.V4K_VLRLIQ VLRLIQ, "
cQuery += "V4K.V4K_BASEIR BASEIR, V4K.V4K_VLRIR VLRIR, V4K.V4K_DESCRI DESCRI, V4K.R_E_C_N_O_ RECNO, V3O.V3O_CODIGO CODNAT, V3O.V3O_DESCR DESCNAT "
If lReinf212
    cQuery += ",V4K.V4K_DTESCO DTESCO "
Endif
cQuery += "FROM " + RetSqlName("V4K") + " V4K "
cQuery += "INNER JOIN " + RetSqlName("V3O") + " V3O "
cQuery += "ON V3O.V3O_FILIAL = '" + xFilial("V3O") + "' "
cQuery += "AND V3O.V3O_ID = V4K.V4K_IDNATR AND V3O.D_E_L_E_T_ = ' ' "
cQuery += "WHERE "
cQuery += "V4K.V4K_FILIAL IN " + cFilsV4K + " "
cQuery += "AND V4K.V4K_DTPAG BETWEEN  '" + cDataIni + "' AND '" + cDataFim + "' "
cQuery += "AND V4K.V4K_INDNAT = '0' "
cQuery += "AND V4K.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY V4K.V4K_IDNATR, V4K.V4K_DTPAG "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasV4K,.F.,.T.)
TCSetField(cAliasV4K, "VLRLIQ" ,"N", 14, 2 )
TCSetField(cAliasV4K, "BASEIR" ,"N", 14, 2 )
TCSetField(cAliasV4K, "VLRIR"  ,"N", 14, 2 )
TCSetField(cAliasV4K, "DTPAG"  ,"D" )
If lReinf212
    TCSetField(cAliasV4K, "DTESCO" ,"D" )
Endif

Return cAliasV4K

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava4040
Efetua gravação no modelo da tabela espelho do evento R-4040 da Reinf 2.0
(Rotinas de apuração do Pagamentos a beneficiarios não identificados)

@author Leticia Campos, Katielly Feitosa
@since 21/08/2019
@version 1.0
/*/

Static Function Grava4040(nOpc, cAliasV4K, cPeriod, cTpInsc, cNrInsc, cIdApReinf, cEvento, cVerAnt, cProTpn, cRetStat, cId, aFil, cTpAmb,aMovs, oModel543, aErro, lReinf212, cIdEvAdic )

Local nC1EArray  as Numeric
Local nTamFil    as Numeric
Local aInfoC1E   as Array

Local cChvV4O    as Character
Local cChvV4P    as Character
Local nQtdV4O    as Numeric
Local nQtdV4P    as Numeric
Local nQtdV9C    as Numeric
Local aSeek      as Array
Local cMsg       as Character 

Local lRollBack     as Logical
Local oModelV4O	    as Object
Local oModelV4P	    as Object
Local oModelV4N	    as Object
Local oModelV9C	    as Object

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
Default lReinf212   := .F.
Default cIdEvAdic   := ""

nC1EArray := ASCAN(aFil,{|x|x[7]})
nTamFil   := len( aFil )
 
cChvV4O   := ""
cChvV4P   := ""
nQtdV4O   := 0
nQtdV4P   := 0
nQtdV9C   := 0
lRollBack := .F.
oModelV4N := oModel543:GetModel("MODEL_V4N")
oModelV4O := oModel543:GetModel("MODEL_V4O")
oModelV4P := oModel543:GetModel("MODEL_V4P")
oModelV9C := oModel543:GetModel("MODEL_V9C")

aInfoC1E  := {}
If nC1EArray > 0 
    AADD(aInfoC1E,aFil[nC1EArray][1])
    AADD(aInfoC1E,aFil[nC1EArray][4])
Elseif nTamFil > 0
	AADD(aInfoC1E,aFil[nTamFil][1])
	AADD(aInfoC1E,aFil[nTamFil][4])  
EndIf

oModel543:SetOperation(nOpc)
oModel543:Activate()

If !Empty(cVerAnt)
	oModel543:LoadValue( 'MODEL_V4N', 'V4N_VERANT', cVerAnt )
	oModel543:LoadValue( 'MODEL_V4N', 'V4N_PROTPN', cProTpn )
	oModel543:LoadValue( 'MODEL_V4N', 'V4N_ID'	  , cId     )
EndIf

oModel543:LoadValue('MODEL_V4N', 'V4N_VERSAO'  , xFunGetVer())
oModel543:LoadValue('MODEL_V4N', 'V4N_STATUS'  , '')
oModel543:LoadValue('MODEL_V4N', 'V4N_EVENTO'  , cEvento)
oModel543:LoadValue('MODEL_V4N', 'V4N_ATIVO'   , '1')
oModel543:LoadValue('MODEL_V4N', 'V4N_PERAPU'  , cPeriod)	
oModel543:LoadValue('MODEL_V4N', 'V4N_TPAMB'   , cTpAmb)	
oModel543:LoadValue('MODEL_V4N', 'V4N_IDESTA'  , aInfoC1E[1])
oModel543:LoadValue('MODEL_V4N', 'V4N_DESTA'   , aInfoC1E[2])
oModel543:LoadValue('MODEL_V4N', 'V4N_TPINSC'  , cTpInsc)		//tpInscEstab - CNPJ
oModel543:LoadValue('MODEL_V4N', 'V4N_NRINSC'  , cNrInsc) 	//nrInscEstab													
If lReinf212
    oModel543:LoadValue('MODEL_V4N', 'V4N_EVADIC'  , cIdEvAdic ) 	//EvAdic
Endif


While (cAliasV4K)->( !Eof() ) 

    ++nQtdV4O

    oModelV4O:lValid := .T. 
    If nQtdV4O > 1 .and. nOpc == MODEL_OPERATION_INSERT .and. (cChvV4O) != (cAliasV4K)->NATREN
        oModelV4O:AddLine()
    EndIf 
    cChvV4O := (cAliasV4K)->NATREN
    oModelV4O:LoadValue('V4O_NATREN', (cAliasV4K)->CODNAT )
    oModelV4O:LoadValue('V4O_DNATRE', (cAliasV4K)->DESCNAT )

    nQtdV4P := 0
    nQtdV9C := 0
    cChvV4P := (cAliasV4K)->NATREN + dToS((cAliasV4K)->DTPAG)
    While (cAliasV4K)->( !Eof() ) .AND. (cChvV4O) == (cAliasV4K)->NATREN
        ++nQtdV4P 
        
        oModelV4P:lValid:= .T. 
        If nQtdV4P > 1 .AND. nOpc == MODEL_OPERATION_INSERT .and. cChvV4P != (cAliasV4K)->NATREN + dtoS((cAliasV4K)->DTPAG)
            oModelV4P:AddLine()
            nQtdV9C := 0
        EndIf
        cChvV4P := (cAliasV4K)->NATREN + dToS((cAliasV4K)->DTPAG)
        
        oModelV4P:LoadValue('V4P_DATAFG', (cAliasV4K)->DTPAG)
        oModelV4P:LoadValue('V4P_VLRLIQ', (cAliasV4K)->VLRLIQ + FWFldGet( "V4P_VLRLIQ" ))
        oModelV4P:LoadValue('V4P_BASEIR', (cAliasV4K)->BASEIR + FWFldGet( "V4P_BASEIR" ))
        oModelV4P:LoadValue('V4P_VLRIR' , (cAliasV4K)->VLRIR  + FWFldGet( "V4P_VLRIR" ))
        oModelV4P:LoadValue('V4P_DESCRI', (cAliasV4K)->DESCRI)        
        If lReinf212
            oModelV4P:LoadValue('V4P_DTESCO', (cAliasV4K)->DTESCO )
        Endif

        If V9B->( DbSeek( (cAliasV4K)->FIL + (cAliasV4K)->V4KID ) )
            While V9B->( !Eof() ) .and. V9B->V9B_FILIAL + V9B->V9B_ID == (cAliasV4K)->FIL + (cAliasV4K)->V4KID
                aSeek := {}
                ++nQtdV9C
                aAdd(aSeek, {"V9C_IDPROC", V9B->V9B_IDPROC } )
                aAdd(aSeek, {"V9C_CODSUS", V9B->V9B_CODSUS } )
                If nQtdV9C > 1 .AND. nOpc == MODEL_OPERATION_INSERT .and. !oModelV9C:SeekLine( aSeek )
                    oModelV9C:AddLine()
                EndIf

                oModelV9C:LoadValue('V9C_IDPROC', V9B->V9B_IDPROC)
                oModelV9C:LoadValue('V9C_TPPROC', V9B->V9B_TPPROC)
                oModelV9C:LoadValue('V9C_NRPROC', V9B->V9B_NRPROC)
                oModelV9C:LoadValue('V9C_CODSUS', V9B->V9B_CODSUS)
                oModelV9C:LoadValue('V9C_IDSUSP', V9B->V9B_IDSUSP)
                oModelV9C:LoadValue('V9C_BSUSIR', V9B->V9B_BSUSIR + FWFldGet( "V9C_BSUSIR" ))
                oModelV9C:LoadValue('V9C_VSUSIR', V9B->V9B_VSUSIR + FWFldGet( "V9C_VSUSIR" ))
                oModelV9C:LoadValue('V9C_VLRDEP', V9B->V9B_VLRDEP + FWFldGet( "V9C_VLRDEP" ))

                V9B->( DbSkip() )
            EndDo    
        EndIf

        aAdd(aMovs, {(cAliasV4K)->RECNO})

        (cAliasV4K)->(DbSkip())
    EndDo
EndDo

If !lRollBack 
    If oModel543:VldData()
        FwFormCommit(oModel543)		
        TafEndGRV( "V4N","V4N_PROCID", cIdApReinf, V4N->(Recno())) //Grava PROCID na espelho
        GravaId(aMovs, cIdApReinf) //Grava PROCID no legado

        //Exito Gravacao
        cMsg := STR0003 + CRLF //"Processamento realizado com sucesso."
        cMsg += STR0004 + AllTrim(cNrInsc) + CRLF //"Nr Insc: "
        cMsg += STR0005 + cValToChar( cIdApReinf ) + " Recno:" + cValToChar( V4N->(Recno())) //"Apuracao Id:"
        TafXLog(cIdApReinf, "R-4040", "MSG", cMsg, cPeriod )
    Else
        lRollBack := .T.
        cMsg 		:= STR0006 + CRLF + CRLF //"Detalhes técnicos do erro: "
        cMsg		+= TafRetEMsg(oModel543)     
        Aadd(aErro, {'R-4040', 'ERRO', cMsg})
    EndIf
EndIf

oModel543:DeActivate()

Return lRollBack

//-------------------------------------------------------------------
/*/{Protheus.doc} Stats4040
Verifica a existência ou não do registro que será apurado

@author Leticia Campos, Katielly Feitosa
@since 26/08/2019
@version 1.0

@parameters Retorna o status do registro encontrado, caso contrário retorna status "Z", 
indicando que ainda não existe o registro no cadastro espelho
@return
/*/ 
Static Function Stats4040(cChave , cVerAnt, cProTpn, cId )

Local cRetStat   as Character

Default cChave   := "" 
Default cVerAnt  := ""
Default cProTpn  := ""
Default cId		 := ""

cRetStat   := ""

If V4N->( DbSeek( cChave + '1') ) //cPeriod + cTpInsc + cNrInsc 
    cVerAnt	 := V4N->V4N_VERSAO
    cProTpn  := V4N->V4N_PROTUL
    cRetStat := V4N->V4N_STATUS
    cId		 := V4N->V4N_ID
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

Static Function ExcluiReg(cIdApReinf, cPeriod, oModel543, lAutomato)

Local cErro		As Character
Local cTpInscEst as Character
Local cNrInscEst as Character
Local oModel     as Object
Local lExcluiu   as Logical

Default lAutomato := .T.

oModel 		:= oModel543 
cTpInscEst	:= V4N->V4N_TPINSC
cNrInscEst	:= V4N->V4N_NRINSC
lExcluiu    := .T.

oModel:SetOperation(5)
oModel:Activate()

If FwFormCommit(oModel) .AND. lAutomato
	lExcluiu := .T.
Else
	cErro	:= STR0001 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
	cErro 	+= "nrInscEstab: " + Alltrim(cNrInscEst) + CRLF
	cErro 	+= TafRetEMsg(oModel)
    TafXLog(cIdApReinf, "R-4040", "ERRO", cErro, cPeriod )
	lExcluiu := .F.    
EndIf

oModel:DeActivate()

Return lExcluiu

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaId()
Função que grava o PROCID na tabela legado

@author Katielly Feitosa
@since 29/08/2019
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

