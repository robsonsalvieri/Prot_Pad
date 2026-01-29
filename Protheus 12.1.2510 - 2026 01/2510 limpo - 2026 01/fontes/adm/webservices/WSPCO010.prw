#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSPCO010.CH"

Static nTamAL2 := TamSX3("AL2_TPSALD")[1]

//dummy function
Function WSPCO010()
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} managementCubeBalance
API para retornar o Saldo conforme Cubo Gerencial

@author Ewerton Franklin
@since 24/02/2025 
/*/
//-------------------------------------------------------------------
WSRESTFUL managementCubeBalance DESCRIPTION STR0001//"Saldo Cubo Gerencial"

    WSDATA cube                    AS STRING OPTIONAL  // código do cube
    WSDATA keyBalanceSum           AS STRING OPTIONAL  // chave Orçado
    WSDATA keyBalanceSub           AS STRING OPTIONAL  // chave Realizado
    WSDATA initDate                AS STRING OPTIONAL  // data inicial
    WSDATA endDate                 AS STRING OPTIONAL  // data final
    WSDATA returnSum               AS STRING OPTIONAL  // Permite somente Orçado
    WSDATA returnSub               AS STRING OPTIONAL  // Permite somenre Realizado
    WSDATA company                 AS STRING OPTIONAL  // Empresa
    WSDATA branch                  AS STRING OPTIONAL  // Filial
    WSDATA validKey                AS STRING OPTIONAL  // Valida Chaves?
    WSDATA lockCode                AS STRING OPTIONAL  //Codigo de Bloqueio
    WSDATA sumBalanceType          AS STRING OPTIONAL  //Soma Tipos de Saldos do Filtro da Configuração (AL4)

    WSMETHOD GET cubeBalance;// 
       DESCRIPTION STR0001; // Retorna saldos dos cubos conforme período cadastrado das chaves referentes aos seus movimentos
       WSSYNTAX "/api/pco/v1/cubeBalance";
       PATH "/api/pco/v1/cubeBalance";
       PRODUCES APPLICATION_JSON;
    
END WSRESTFUL

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} cubeBalance
    Método para retornar os períodos e saldos correspondentes conforme Cubo e Chave
@author Ewerton Franklin
@since 24/02/2025
@return lRet, lógico, se a mensagem foi recebida com sucesso 
/*/
//-------------------------------------------------------------------------------------

WSMETHOD GET cubeBalance WSRECEIVE cube, keyBalanceSum, keyBalanceSub, initDate, endDate,returnSum,returnSub,company,branch,validKey,lockCode,sumBalanceType WSSERVICE managementCubeBalance
    Local oResponse             := JsonObject():New() 
    Local cJson                 := ""
    Local lRet                  := .F.

    Default Self:cube           := "" // Código do cube.
    Default Self:keyBalanceSum  := ""
    Default Self:keyBalanceSub  := ""
    Default Self:initDate       := ""
    Default Self:endDate        := ""
    Default Self:returnSum      := Upper("Yes")
    Default Self:returnSub      := Upper("Yes")
    Default Self:validKey       := Upper("No")
    Default Self:lockCode       := ""
    Default Self:sumBalanceType := Upper("Yes")
    
    self:SetContentType("application/json")

    lRet := LoadCubeResult( @oResponse, @Self )
    
    cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

    ::SetResponse( cJson )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadCubeResult
Função responsável pela busca das informações dos Saldos conforme envio da API

@param @oResponse, object, Objeto que armazena os registros a apresentar.
@param @oSelf, object, Objeto principal do WS

@return boolean, .T. se encontrou registros e .F. se ocorreu erro.
@author Ewerton Franklin
@since 24/02/2025
/*/
//----------------------------------------------------------------------------------
Static Function LoadCubeResult( oResponse as object, oSelf as object ) as logical

    Local lRet          := .T. as logical
    Local dIniDate      := ""  as character
    Local dEndDate      := ""  as character
    Local cChaveOrc     := ""  as character
    Local cChaveRea     := ""  as character
    Local cCubo         := ""  as character
    Local aRet          := {}  as array
    Local aValid        := {}  as array
    Local lRetOR        := .T. as Logical
    Local lRetRE        := .T. as Logical
    Local cType         := ""  as Character
    Local cCodBlq       := ""  as Character
    Local lSumTpSLD     := .F. as Logical
    Local aAreaAKJ      := AKJ->(FWGetArea()) as Array
     
    aValid := ValidData(oSelf)

    If aValid[1]
        dIniDate    := Stod(oSelf:initDate)
        dEndDate    := Stod(oSelf:endDate)
        cChaveOrc   := oSelf:keyBalanceSum
        cChaveRea   := oSelf:keyBalanceSub
        cCubo       := Padr(oSelf:cube,TamSX3("AKJ_CONFIG")[1])
        lRetOR      := If(UPPER(Alltrim(oSelf:returnSum)) == 'NO',.F.,.T.)
        lRetRE      := If(UPPER(AllTrim(oSelf:returnSub)) == 'NO',.F.,.T.)
        cCodBlq     := oSelf:lockCode
        lSumTpSLD   := If(UPPER(AllTrim(oSelf:sumBalanceType)) == 'NO',.F.,.T.)

       
        dbSelectArea("AKJ")
        dbSetOrder(3)
        If AKJ->( dbSeek(FwxFilial("AKJ")+cCubo+cCodBlq) ) 
            cType  := X3Combo("AKJ_TPSLD",AKJ->AKJ_TPSLD)
            If AKJ->AKJ_SLDPER <> '1'
                lSldAcum    := .T.
            Else
                lSldAcum    := .F.
            EndIf

            cTipo   := AKJ->AKJ_TPSLD   
            oResponse[ "periods" ] := {}
            oResponse[ "cubeBalanceType" ] := If(lSldAcum,STR0002,EncodeUTF8(STR0003))  //#"Saldo Acumulado"    #"Saldo Por Período" 
            oResponse[ "cube" ] := cCubo 
            oResponse[ "keyBalanceSum" ] := cChaveOrc 
            oResponse[ "keyBalanceSub" ] := cChaveRea 
            oResponse[ "typeOfperiod" ]  := cType

            aRet:= PCOISLDCUB(cCubo, cChaveOrc, cChaveRea,dIniDate, dEndDate,lRetOR,lRetRE,cCodBlq,lSumTpSLD) 

            If Len(aRet) > 0
                nRecords := Len(aRet)
                oResponse[ "periods" ] := SetJson( aRet, oSelf )
            EndIf  
        EndIf
    Else
        SetRestFault(400, EncodeUTF8( aValid[2] ))
    EndIf

    FWRestArea(aAreaAKJ)
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetJson
Função que prepara as informações necessárias para serem utilizadas no retorno do Get

@param cTmp, caracter, alias que esta sendo verificado
@param oSelf, objeto, objeto principal do WS

@return aData, array, componente com as propriedades no formato JSON para envio à plataforma.
@author  Ewerton Franklin
@since   02/08/2023
/*/
//-------------------------------------------------------------------------------------
Static Function ValidData( oSelf as Object ) as Array

    Local aRet		:= {}  as Array
    Local lRet      := .T. as Logical
    Local cMsg      := ""  as Character
    Local aAreaAL2      := AL2->(FWGetArea()) as Array
    Local aAreaAKJ      := AKJ->(FWGetArea()) as Array 
    Local aAreaAKT      := AKT->(FWGetArea()) as Array 

    If lRet .and. oSelf:company == Nil .or. Empty(oSelf:company)
	    lRet := .F.
        cMsg := STR0013+ 'company.'
    EndIf

    If lRet .and. oSelf:branch == Nil .or. Empty(oSelf:branch)
	    lRet := .F.
        cMsg := STR0014+ 'branch.'
    EndIf
   
	If lRet .and. !PrepEnv( AllTrim(oSelf:company), AllTrim(oSelf:branch) )
    	lRet := .F.
        cMsg := STR0015+ ': '+AllTrim(oSelf:company)+"|"+AllTrim(oSelf:branch)
	EndIf

    If lRet .and. UPPER(Alltrim(oSelf:returnSum)) <> 'YES' .and. UPPER(Alltrim(oSelf:returnSum)) <> 'NO'
        lRet := .F. 
        cMsg := STR0004 + "- returnSum: "+oSelf:returnSum //"Tag para tratar retorno da chave Realizado está inválido, é permitido apenas YES ou NO"   
    EndIf
    If  lRet .and. UPPER(AllTrim(oSelf:returnSub)) <> 'YES' .and. UPPER(AllTrim(oSelf:returnSub)) <> 'NO'
        lRet := .F. 
        cMsg := STR0005 + "- returnSub: "+oSelf:returnSub //
    EndIf

    If lRet .and. Empty(oSelf:cube)
        lRet := .F. 
        cMsg := STR0006 + "tag: cube" //"Cubo não informado. É obigatório informar o Cubo" 
    EndIf

    If lRet .and. (Len(oSelf:initDate) <> 8 .Or. Empty(oSelf:initDate)  )
        lRet := .F. 
        cMsg := STR0007 + "- initDate: " +oSelf:initDate //"Data inicial inválida"  
    EndIf
    If lRet .and. (Len(oSelf:endDate) <> 8 .Or. Empty(oSelf:endDate))
        lRet := .F.
        cMsg := STR0008 + "- endDate: " +oSelf:endDate  //"Data final inválida"
    EndIf
    If lRet .and. Stod(oSelf:endDate) < Stod(oSelf:initDate)
        lRet := .F.
        cMsg := STR0009 + "- endDate: " +oSelf:endDate + " - initDate: " +oSelf:initDate //"Não permitido data final menor que a data inicial" 
    EndIf

    dbSelectArea("AKJ")
    dbSetOrder(3)
    If lRet .and. !AKJ->( dbSeek(FwxFilial("AKJ")+Padr(oSelf:cube,TamSX3("AKJ_CONFIG")[1])) )
        lRet := .F.
        cMsg := STR0010 + " - cube: "+Padr(oSelf:cube,TamSX3("AKJ_CONFIG")[1])  //"Cubo informado não encontrado " 
    EndIf

    If UPPER(AllTrim(oSelf:validKey)) == "YES"
        dbSelectArea("AKT")
        AKT->(dbSetOrder(1))
        If lRet .and. !AKT->(DbSeek(FwxFilial("AKT")+oSelf:cube+Padr(oSelf:keyBalanceSum,TamSX3("AKT_CHAVE")[1])))
            If UPPER(Alltrim(oSelf:returnSum)) <> 'NO'
                lRet := .F.
                cMsg := STR0011 + " - cube: "+oSelf:cube + " - keyBalanceSum: "+oSelf:keyBalanceSum //"Chave de saldo vinculado ao cubo não encontrado "
            EndIf
        EndIf
        
        If lRet .and. !AKT->(DbSeek(FwxFilial("AKT")+oSelf:cube+Padr(oSelf:keyBalanceSub,TamSX3("AKT_CHAVE")[1])))
            If UPPER(Alltrim(oSelf:returnSub)) <> 'NO'
                lRet := .F.
                cMsg := STR0012 + " - cube: "+oSelf:cube + " - keyBalanceSub: "+oSelf:keyBalanceSub //"Chave de saldo vinculado ao cubo não encontrado "
            EndIf
        EndIf
    EndIf

    If lRet .and. UPPER(Alltrim(oSelf:sumBalanceType)) == "NO"        
        cVerSldOR := Right(AllTrim(oSelf:keyBalanceSum), 2)
        cVerSldRE := Right(AllTrim(oSelf:keyBalanceSub), 2)

        DbSelectArea("AL2")
        AL2->(DbSetOrder(1))
        
        If ( Empty(cVerSldOR) .or. !AL2->(DbSeek(FwxFilial("AL2")+AllTrim(cVerSldOR)))) .and. UPPER(Alltrim(oSelf:returnSum)) <> 'NO'
            lRet := .F.
            cMsg := STR0017+" - keyBalanceSum: "+oSelf:keyBalanceSum // "Chave sumBalanceType está marcado como falso, portanto deve ser informado o tipo de saldo na chave: "           
        EndIf
        If (Empty(cVerSldRE) .or. !AL2->(DbSeek(FwxFilial("AL2")+AllTrim(cVerSldRE)))) .and. UPPER(Alltrim(oSelf:returnSub)) <> 'NO'
            lRet := .F.
            cMsg := STR0017+" - keyBalanceSub: "+oSelf:keyBalanceSub //  "Chave sumBalanceType está marcado como falso, portanto deve ser informado o tipo de saldo na chave: "                     
        EndIf     
    EndIf

    aRet := {lRet, cMsg }

    FWRestArea(aAreaAKJ)
    FWRestArea(aAreaAL2)
    FWRestArea(aAreaAKT)
Return aRet


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetJson
Função que prepara as informações necessárias para serem utilizadas no retorno do Get

@param cTmp, caracter, alias que esta sendo verificado
@param oSelf, objeto, objeto principal do WS

@return aData, array, componente com as propriedades no formato JSON para envio à plataforma.
@author  Ewerton Franklin
@since   02/08/2023
/*/
//-------------------------------------------------------------------------------------
Static Function SetJson( aSaldos as Array, oSelf as Object ) as Array
    Local aData		:= {} as Array
	Local aMakeDoc	:= {} as Array
    Local i         := 1  as numeric

    For i:=1 to Len(aSaldos)   
        aMakeDoc := MakeBalance( aSaldos[i], oSelf )   
        aAdd( aData, aMakeDoc ) 
    Next
Return aData

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeBalance
Função que envia saldo por periodo

@param cTmp, caracter, alias que esta sendo verificado
@param oSelf, object, objeto principal do WS

@return jData, json com os saldo dos períodos
@author  Ewerton Franklin
@since   02/08/2023
/*/
//-------------------------------------------------------------------------------------
Static Function MakeBalance( aSaldo, oSelf ) 
    
    Local jData := NIL 
 
    jData := JsonObject():New()
    
    jData[ "startDate" ]       := Dtoc(aSaldo[1])
    jData[ "endDate" ]         := Dtoc(aSaldo[2])
    jData[ "balance" ]         := aSaldo[3]
                   
Return jData


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PCOISLDCUB
Função que retorna saldo por periodo


@return array, com os saldo dos períodos
@author  Ewerton franklin
@since   24/02/2025
/*/
//-------------------------------------------------------------------------------------

Function PCOISLDCUB(cConfig as Character, cChaveOrc as Character, cChaveRea as Character, dIni as Date, dFim as Date,lRetOR as Logical,lRetRE as logical,cCodBlq as character,lSumTpSal as Logical) as Array

Local aDatas    := {}  as array
Local aRet      := {}  as array
Local i         := 1   as numeric
Local x         := 1   as numeric
Local lSldAcum  := ""  as logical
Local aRetIniOr := {}  as array
Local nCrdIniOr := 0   as numeric
Local nDebIniOr := 0   as numeric
Local nMovCrdOr := 0   as numeric
Local nMovDebOr := 0   as numeric
Local nMovPerOr := 0   as numeric
Local aRetIniRe := 0   as array
Local nCrdIniRe := 0   as numeric
Local nDebIniRe := 0   as numeric
Local nMovCrdRe := 0   as numeric
Local nMovDebRe := 0   as numeric
Local nMovPerRe := 0   as numeric
Local nDisponiv := 0   as numeric
Local aRetFimOr := {}  as array
Local nCrdFimOr := 0   as numeric
Local nDebFimOr := 0   as numeric
Local aRetFimRE := {}  as array
Local nCrdFimRE := 0   as numeric
Local nDebFimRE := 0   as numeric
Local aAreaAKJ := AKJ->(FWGetArea())

Local aRetTpOR     :=  {} as array
Local aRetTpRE     :=  {} as array
Local cChvOrca     := ""  as character
Local cChvReal     := ""  as character

Default cConfig   := ""       
Default cChaveOrc := ""       
Default cChaveRea := ""       
Default dIni      := cTod("") 
Default dFim      := cTod("") 
Default lRetOR   := .T.
Default lRetRE   := .T.
Default lSumTpSal:= .T.

dbSelectArea("AKJ")
AKJ->(dbSetOrder(3))
If AKJ->( dbSeek(FWxFilial("AKJ")+cConfig+cCodBlq) )
    cTipo  := AKJ->AKJ_TPSLD
    If AKJ->AKJ_SLDPER <> '1'
        lSldAcum    := .T.
    Else
        lSldAcum    := .F.
    EndIf

    cCfgOR := AKJ->AKJ_PRVCFG
    cCfgRE := AKJ->AKJ_REACFG

    oStructOR := PcoStructCube(cConfig, cCfgOR)
    oStructRE := PcoStructCube(cConfig, cCfgRE)

    nPosOrAl2   := Ascan(oStructOR:AALIAS,"AL2") 
    cFiltroOR   := oStructOR:AFILTROS[nPosOrAl2]
    cIniOR      := oStructOR:AINI[nPosOrAl2]
    cfimOR      := oStructOR:AFIM[nPosOrAl2]

    nPosReAl2   := Ascan(oStructRE:AALIAS,"AL2") 
    cFiltroRe   := oStructRE:AFILTROS[nPosReAl2]
    cIniRE      := oStructRE:AINI[nPosReAl2]
    cfimRE      := oStructRE:AFIM[nPosReAl2]


    //Se soma os tipos de saldo configurados no Cubo, busca os saldos configurados no Filtro (AL4)
    If lSumTpSal
        aRetTpOR    := PCO010TPS(cFiltroOR,cIniOR,cfimOR)
        aRetTpRE    := PCO010TPS(cFiltroRE,cIniRE,cfimRE)
    Else
        Aadd(aRetTpOR, Right(AllTrim(cChaveOrc), nTamAL2))
        Aadd(aRetTpRE, Right(AllTrim(cChaveRea), nTamAL2))
    EndIf

    aDatas := GetDates(dIni,dFim,cTipo)
    For i:= 1 to Len(aDatas)
        dIni := aDatas[i][1]
        dFim := aDatas[i][2]
        nMovCrdOr := 0 
        nMovDebOr := 0
        nMovPerOr := 0
        nMovCrdRE := 0 
        nMovDebRE := 0
        nMovPerRE := 0
        // ORCADO.
        For x:= 1 to Len(aRetTpOR)
            If lSumTpSal
                cChvOrca :=  SubStr(AllTrim(cChaveOrc), 1, Len(AllTrim(cChaveOrc)) - nTamAL2) + AllTrim(aRetTpOR[x])  
            Else
                cChvOrca := cChaveOrc
            EndIf
            If !lSldAcum
                If lRetOr
                    aRetIniOr := PcoRetSld(cConfig, AllTrim(cChvOrca), dIni-1)
                    nCrdIniOr := aRetIniOr[1, 1]
                    nDebIniOr := aRetIniOr[2, 1]
                EndIf
            EndiF
            If lRetOr
                aRetFimOr := PcoRetSld(cConfig, Alltrim(cChvOrca), dFim)
                nCrdFimOr := aRetFimOr[1, 1]
                nDebFimOr := aRetFimOr[2, 1]
            EndIf

            nMovCrdOr := nCrdFimOr - nCrdIniOr
            nMovDebOr := nDebFimOr - nDebIniOr
            nMovPerOr += nMovCrdOr - nMovDebOr
        Next
        // REALIZADO.
        For x:= 1 to Len(aRetTpRE)
            If lSumTpSal
                cChvReal :=  SubStr(AllTrim(cChaveRea), 1, Len(AllTrim(cChaveRea)) - nTamAL2) + AllTrim(aRetTpRE[x])  
            Else
                cChvReal := cChaveRea
            EndIf
            If !lSldAcum
                If lRetRE
                    aRetIniRe := PcoRetSld(cConfig, AllTrim(cChvReal), dIni-1)
                    nCrdIniRe := aRetIniRe[1, 1]
                    nDebIniRe := aRetIniRe[2, 1]
                EndIf
            EndIf
            If lRetRE
                aRetFimRe := PcoRetSld(cConfig, AllTrim(cChvReal), dFim)
                nCrdFimRe := aRetFimRe[1, 1]
                nDebFimRe := aRetFimRe[2, 1]
            EndIf
            nMovCrdRe := nCrdFimRe - nCrdIniRe 
            nMovDebRe := nDebFimRe - nDebIniRe
            nMovPerRe += nMovCrdRe - nMovDebRe
        Next

        // Saldo final.
        nDisponiv := nMovPerOr - nMovPerRe
        aAdd(aRet,{dIni,dFim,nDisponiv})
    Next
EndIf

FWRestArea(aAreaAKJ)

Return aRet



/* {Protheus.doc}
	PCO010TPS - Funcao que Retorna Tipo de saldos conforme filtro no Cubo
	
	@author Totvs
	@since 
	@param 
	@version P12
*/
Static Function PCO010TPS(cFilter,cIni,cFim) as Array

	Local cQry			:= "" as Character
    Local cFiltro       := "" as Character
    Local ARetAL2     := {} as Array
    Local cAlias        := ""  as character
    Local oQueryQry	           as Object
    Local nSeq          := 1   as numeric

	Default cFilter		:= ""
    Default cIni		:= Space(nTamAL2)
    Default cFim		:= Replicate("Z", nTamAL2)

	cFiltro := PcoParseFil( cFilter, "AL2" )
    Iif(Empty(cFim),cFim := Replicate("Z", nTamAL2),"" )
	
    cQry	:= " SELECT AL2_TPSALD  "
    cQry	+= " FROM "+ RetSqlName("AL2") +" AL2 "
    cQry	+= " WHERE "
    cQry	+= " AL2.AL2_FILIAL = ? "
    cQry	+= " AND AL2_TPSALD BETWEEN ? AND ? "
    If !Empty(cFiltro)
        cQry    += " AND  (" + cFiltro	+")  "
    EndIf
    cQry	+= " AND AL2.D_E_L_E_T_ = ? "
    cQry 	:= ChangeQuery(cQry)

    oQueryQry := FwExecStatement():New(cQry)

    oQueryQry:SetString(nSeq++,		FwxFilial("AL2"))
    oQueryQry:SetString(nSeq++,		cIni)
    oQueryQry:SetString(nSeq++,		cFim)
    oQueryQry:SetString(nSeq++,		Space(1))
    
    cAlias := oQueryQry:OpenAlias(GetNextAlias())

    While (cAlias)->(! Eof() )
        AAdd(ARetAL2,(cAlias)->AL2_TPSALD)
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())
    oQueryQry:Destroy()
    oQueryQry:=Nil
    

Return ARetAL2


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetDates
Função que retorna Array conforme tipo do periodo 

cTipo -> 1=Semanal;2=Quinzenal;3=Mensal;4=Bimestral;5=Semestral;6=Anual;7=Trimestral  


@return array, com datas conforme tipo do período
@author  Ewerton franklin
@since   24/02/2025
/*/
//-------------------------------------------------------------------------------------


Static Function GetDates(dDataIni as Date,dFim as Date,cTipo as Character) as Array

Local aData := {} as Array

Default cTipo     := "1"
Default dDataIni  := cTod("")
Default dFim      := cTod("")

//1=Semanal;2=Quinzenal;3=Mensal;4=Bimestral;5=Semestral;6=Anual;7=Trimestral                                                     
Do Case 
    Case cTipo == "1"
        If DOW(dDataIni)<>1
            dDataIni -= DOW(dDataIni)-1
        EndIf
        //dDataFim := dFim
        While dDataIni <= dFim
            dDataFim := dDataIni+6
            aadd(aData,{dDataIni,dDataFim})
            dDataIni := DaySum(dDataFim,1)
        EndDo
    Case cTipo == "2"
        If DAY(dDataIni) <= 15
            dDataIni := FirstDay(dDataIni)
        Else
            dDataIni := CTOD("16/"+Str(Month(dDataIni),2,0)+"/"+Str(Year(dDataIni),4,0))
        EndIf
        While dDataIni <= dFim
            If DAY(dDataIni) <= 15
                 dDataFim := CTOD("15/"+Str(Month(dDataIni),2,0)+"/"+Str(Year(dDataIni),4,0))
            Else
                dDataFim :=  LastDay(dDataIni)
            EndIf
            aadd(aData,{dDataIni,dDataFim})
            dDataIni := DaySum(dDataFim,1)
        EndDo
    Case cTipo == "3"
        dDataIni := FirstDay(dDataIni)
        While dDataIni <= dFim
            dDataFim :=  LastDay(dDataIni)
            aadd(aData,{dDataIni,dDataFim})
            dDataIni := DaySum(dDataFim,1)
        EndDo
    Case cTipo == "4"
        dDataIni := CTOD("01/"+Str((Round(MONTH(dDataIni)/2,0)*2)-1,2,0)+"/"+Str(Year(dDataIni),4,0))     
        While dDataIni <= dFim
            dDataFim := LastDay(CTOD("01/"+Str((Round(MONTH(dDataIni)/2,0)*2),2,0)+"/"+Str(Year(dDataIni),4,0)))
            aadd(aData,{dDataIni,dDataFim})
            dDataIni := DaySum(dDataFim,1)
        EndDo
    Case cTipo == "5"
        If MONTH(dDataIni)<7  //1o. semestre
            dDataIni := CTOD("01/01/"+Str(Year(dDataIni),4,0))
        Else //2o. semestre
            dDataIni := CTOD("01/07/"+Str(Year(dDataIni),4,0))
        EndIf
        While dDataIni <= dFim
            If MONTH(dDataIni)<7  //1o. semestre
                dDataFim := LastDay(CTOD("01/06/"+Str(Year(dDataIni),4,0)))
            Else //2o. semestre
                dDataFim := LastDay(CTOD("01/12/"+Str(Year(dDataIni),4,0)))
            EndIf
            aadd(aData,{dDataIni,dDataFim})
            dDataIni := DaySum(dDataFim,1)
        EndDo
    Case cTipo == "6"
        dDataIni := CTOD("01/01/"+Str(Year(dDataIni),4,0))
        While dDataIni <= dFim
            dDataFim := LastDay(CTOD("31/12/"+Str(Year(dDataIni),4,0)))
            aadd(aData,{dDataIni,dDataFim})
            dDataIni := DaySum(dDataFim,1)
        EndDo
    Case cTipo == "7"
        dDataIni := CTOD("01/"+Str((Round(((MONTH(dDataIni)+1)/(12/4)),0))*(12/4)-2,2,0)+"/"+Str(Year(dDataIni),4,0))
        While dDataIni <= dFim
            dDataFim := LastDay(CTOD("01/"+Str((Round(((MONTH(dDataIni)+1)/(12/4)),0))*(12/4),2,0)+"/"+Str(Year(dDataIni),4,0)))
            aadd(aData,{dDataIni,dDataFim})
            dDataIni := DaySum(dDataFim,1)
        EndDo
EndCase

Return aData
