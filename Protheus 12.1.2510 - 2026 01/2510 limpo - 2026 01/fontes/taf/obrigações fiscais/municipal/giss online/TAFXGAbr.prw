#Include 'Protheus.ch'
#Include 'ApWizard.ch'
#Include 'TAFXGABR.ch'
#Include 'TOPCONN.CH'
#Include 'FWLIBVERSION.CH'

#DEFINE QTDLOTE 50

Static _TmFil     := Nil
Static _lDtCpIss  := Nil
Static _lCodArt   := Nil
Static _lRegTri   := Nil
Static _lPaisIbge := Nil

//_________________________________________________________________________________________________________
/*/{Protheus.doc} TAFXGAbr

Esta rotina tem como objetivo a geracao do Arquivo GISS modelo Abrasf.

@Author Vogas
@Since 25/11/2024
@Version 1.0
/*/
//_________________________________________________________________________________________________________
Function TAFXGAbr(lAutomato,aFiliais,aWizard )

Local cNomWiz       as char
Local lEnd          as logical
Local lSelecFil     as logical
Local lCNPJ         as logical
Local lCNPJ_IE      as logical
Local cFunction	    as char
Local nOpc          as numeric
Local nI            as numeric
Local aRetorno      as array
Local aCNPJIE       as array
Local aSM0          as array
Local cDtIni        as char
Local cDtFin        as char
Local cFiliais      as char
Local aFilGis       as array
Local cAlias        as char
Local cCaminho      as char
Local cNmArquivo    as char
Local lSucess       as logical
Local lFilSel       as logical
Local lAglutina     as logical
Local oPrepare		as object
Local nTotReg       as numeric
Local cQtdLote      as char

Default lAutomato := .F.
Default aFiliais  := {}
Default aWizard   := {}

cNomWiz		:= STR0011 + FWGETCODFILIAL
lEnd		:= .F.
lSelecFil   := .F.
lCNPJ       := .F.
lCNPJ_IE    := .F.
cFunction 	:= ProcName()
nOpc      	:= 2 //View
aCNPJIE     := {}
aSM0        := {}
cDtIni      := ''
cDtFin      := ''
cFiliais    := ''
aFilGis     := {}
cAlias      := ''
cCaminho    := ''
cNmArquivo  := ''
lSucess     := .F.
lFilSel     := .F.
lAglutina   := .F.
oPrepare	:= Nil
nTotReg     := 0
cQtdLote    := '0'
nI          := 1
aRetorno    := {}

if _TmFil == Nil
    _TmFil := GetSx3Cache("C20_FILIAL", "X3_TAMANHO")
endif

//Função para gravar o uso de rotinas e enviar ao LS (License Server)
Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo('LS006',RetCodUsr(),'84',cFunction),)

//Protect Data / Log de acesso / Central de Obrigacoes
Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

aRetorno := ProcGisAbr( @lEnd, cNomWiz, lAutomato, aWizard )

lSelecFil := (Left(aRetorno[1,5], 1) == '1')

lCNPJ     := (Left(aRetorno[1,6], 1) == '1')
lCNPJ_IE  := (Left(aRetorno[1,6], 1) == '2')

//Verificação das filiais selecionadas para processamento da operacao
if lSelecFil //Seleciona Filiais '1 - Sim'
    if lCNPJ //Aglutina CNPJ
        aadd( aCNPJIE , {.T., .F.} )
    elseIf lCNPJ_IE //Aglutina CNPJ + IE
        aadd( aCNPJIE , {.T., .T.} )
    endif
    If !lAutomato
        aFiliais := xFunTelaFil( .T.,,,.T.,,,,,,@aCNPJIE )
    Endif
    if Len( aFiliais ) > 0
        For nI := 1 to Len( aFiliais )
            if aFiliais[nI,1]
                aadd(aSM0, FWSM0Util():GetSM0Data(cEmpAnt, aFiliais[nI][2], {'M0_CODIGO','M0_CODFIL','M0_FILIAL', 'M0_INSC','M0_CGC'}))
            endif
        Next nI
    endif
else
    AADD(aSM0, FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, {'M0_CODIGO','M0_CODFIL','M0_FILIAL','M0_INSC','M0_CGC'}))
endif

for nI:= 1 to len(aSM0)
    aadd(aFilGis,PadR(Alltrim(aSm0[nI,2,2]),_TmFil))
next nI

if valtype(aRetorno) = 'A' .And. len( aRetorno[1] ) >= 6
    cDtIni     := DtoS(aRetorno[1,3])
    cDtFin     := DtoS(aRetorno[1,4])
    cCaminho   := Alltrim(aRetorno[1,1])
    cNmArquivo := Alltrim(aRetorno[1,2])
    lFilSel    := SubStr(Alltrim(aRetorno[1,5]),1,1) == "1"
    lAglutina  := SubStr(Alltrim(aRetorno[1,6]),1,1) <> "0"

    if !Empty(cDtIni) .And. !Empty(cDtFin) .And. !Empty(cCaminho) .And. !Empty(cNmArquivo)
        if lFilSel .And. len(aFilGis) == 0
            MsgAlert(STR0016) //"Filiais não selecionadas...."
        else
            MsgRun(STR0017,STR0018,{||QryGiss204(cDtIni,cDtFin,aFilGis,@cAlias,@oPrepare,@nTotReg)}) //"Consultando os dados..."##"Aguarde..."
            if !(cAlias)->(Eof())
                cQtdLote := cValToChar(Ceiling(nTotReg/QTDLOTE))            
                MsgRun(STR0019 + cQtdLote + STR0020, STR0021,{||TAFGISXML( cAlias, cCaminho, cNmArquivo, @lSucess, lFilSel, lAglutina, lAutomato )}) //"Gerando arquivo XML... Existe(m) um total de "##" lote(s)."##"Aguarde alguns minutos"
            endif
            (cAlias)->(DbCloseArea())
            if oPrepare != Nil
                FreeObj(oPrepare)
                oPrepare := Nil
            endif
        endif
    endif
endif

if lSucess
    MsgAlert(STR0022) //"Arquivo(s) gerado(s) com sucesso."
else
    MsgAlert(STR0023) //"Registros não encontrados."
endif

Return Nil

//_________________________________________________________________________________________________________
/*/{Protheus.doc} ProcGisAbr

Inicia o processamento para geracao da Giss modelo ABRASF.

@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario
	   cNomWiz   -> Nome da Wizard criada para a GISS Online

@Return ( Nil )

@Author vogas
@Since 26/11/2024
@Version 1.0
/*/
//_________________________________________________________________________________________________________
Static Function ProcGisAbr( lEnd as logical, cNomWiz as char, lAutomato as logical, aWizard as array )

    Local cErrorGISS  as char
    Local cErrorTrd   as char
    Local cYearGiss	  as char
    Local nX          as numeric
    Local nPos        as numeric
    Local nProgress1  as numeric
    Local nCont       as numeric

    Default lAutomato := .F.
    Default aWizard   := {}

    cErrorGISS  := ''
    cErrorTrd   := ''
    cYearGiss	:= ''
    nX          := 0
    nPos        := 0
    nProgress1  := 0
    nCont       := 1
  
    If !lAutomato
        xFunLoadProf( cNomWiz , @aWizard ) //Carrega informações na wizard
    EndIf

Return( aWizard )

//_________________________________________________________________________________________________________
/*/{Protheus.doc} getObrigParam

@Author Vogas
@Since 27/11/2024
@Version 1.0

/*/
//_________________________________________________________________________________________________________
Static Function getObrigParam( lAutomato as logical )

    Local	cNomWiz     as char
    Local 	cNomeAnt 	as char
    Local	cTitObj1	as char
    Local	aTxtApre	as array
    Local	aPaineis	as array	
    Local	aItens1	    as array
    Local	aItens2	    as array
    Local	aRet		as array

    Default lAutomato := .F.

	            //'GISS modelo ABRASF.'
	cNomWiz	    := STR0011 + FWGETCODFILIAL
	cNomeAnt 	:= ''
	cTitObj1	:= ''
    aTxtApre	:= {}
	aPaineis	:= {}	
	aItens1	    := {}	
    aItens2	    := {}	
	aRet		:= {} 
	
	aAdd( aTxtApre, STR0002)	//'Processando Empresa.'	
	aAdd( aTxtApre, '')
	aAdd( aTxtApre, STR0003)	//'Preencha corretamente as informações solicitadas.'	
	aAdd( aTxtApre, STR0004)	//'Informações necessárias para a geração do meio-magnético GISS Online.'	

	//____________________________________ Painel 0 _______________________________________________________

	aAdd( aPaineis, {})
	nPos := Len (aPaineis)
	aAdd( aPaineis[nPos], STR0003)	//'Preencha corretamente as informações solicitadas.'	
	aAdd( aPaineis[nPos], STR0004)	//'Informações necessárias para a geração do meio-magnético GISS Online.'
	aAdd( aPaineis[nPos], {})
																
	//______________LINHA 1________________________________________________________________________________
	cTitObj1 := STR0005 //'Diretório do Arquivo Destino'	                 
	cTitObj2 := STR0006 //'Nome do Arquivo Destino'

	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
	aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

	cTitObj1 := Replicate( 'X', 50 )
	cTitObj2 := Replicate( 'X', 20 )

	aAdd( aPaineis[nPos,3], { 2,, cTitObj1, 1,,,, 50,,,, { 'xValWizCmp', 3 , { '', '' } } } ) //Valida campo: 'Diretório do Arquivo Destino' no Botão Avançar
	aAdd( aPaineis[nPos,3], { 2,, cTitObj2, 1,,,, 20,,,, { 'xValWizCmp', 4 , { '', '' } } } ) //Valida campo: 'Nome do Arquivo Destino' no Botão Avançar

	aAdd( aPaineis[nPos][3], {0,'',,,,,,})					
	aAdd( aPaineis[nPos][3], {0,'',,,,,,}) //Pula Linha
   
   //______________LINHA 2_________________________________________________________________________________

    cTitObj1	:= STR0007 //'Data Inicial:'
    cTitObj2	:= STR0008 //'Data Final:'
	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
    aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )
    aAdd( aPaineis[nPos,3], {2,,,3,,,,})							
    aAdd( aPaineis[nPos,3], {2,,,3,,,,}) 
    aAdd( aPaineis[nPos,3], {0,'',,,,,,})	
    aAdd( aPaineis[nPos,3], {0,'',,,,,,})

    //____________ Linha 3_________________________________________________________________________________

    cTitObj1	:= STR0009 //'Seleciona Filiais:'
    cTitObj2	:= STR0010 //'Algutina:'
	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )    
	aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )
    
	aAdd( aItens1, STR0012 ) //'0 - Não'
	aAdd( aItens1, STR0013 ) //'1 - Sim'    
    aAdd( aPaineis[nPos,3], {3,,,,,aItens1,,,,,}) 

    aAdd( aItens2, STR0012 ) //'0 - Não'
    aAdd( aItens2, STR0014 ) //'1 - Por CNPJ'
    aAdd( aItens2, STR0015 ) //'2 - Por CNPJ + IE'
    aAdd( aPaineis[nPos,3], {3,,,,,aItens2,,,,,}) 

    //_____________________________________________________________________________________________________

	aAdd( aRet, aTxtApre)
	aAdd( aRet, aPaineis)
	aAdd( aRet, cNomWiz)
	aAdd( aRet, cNomeAnt)
	aAdd( aRet, Nil )
	aAdd( aRet, Nil )
	aAdd( aRet, { || TAFXGAbr(lAutomato) } )

Return ( aRet )

//----------------------------------------------------------------------------
/*/{Protheus.doc} QryGiss204
Retorna as notas fiscais de serviço para geração do XML da GISS Online modelo
ABRASF 2.04
@Param
@Return
@Author Rafael de Paula Leme / Denis Souza
@Since 25/11/2024
@Version 1.0
/*/
//----------------------------------------------------------------------------
Static Function QryGiss204( cDtIni, cDtFin, aFilGis, cAlias, oPrepare, nTotReg )

Local cCompC1N   as character
Local cCompC1H   as character
Local cCompT9C   as character
Local cQuery     as character
Local cSGBD  	 as character
Local aInfEUF    as array
Local aCodTri    as array
Local aCodMod    as array
Local aCodSit    as array
Local aBind      as array
Local nX         as numeric
Local nTmAFil    as numeric
Local cIsNullSQL as character
Local cConcat    as character

Default cDtIni    := ''
Default cDtFin    := ''
Default aFilGis   := {}
Default cAlias    := ''
Default oPrepare  := Nil
Default nTotReg   := 0

cSGBD := Upper(Alltrim(TCGetDB())) //Banco de dados que esta sendo utilizado 

if _lDtCpIss == Nil
    _lDtCpIss := C20->(FieldPos("C20_DTCPIS")) > 0
endif

if _lCodArt == Nil
    _lCodArt := T9C->(FieldPos("T9C_CODART")) > 0
endif

if _lRegTri == Nil
    _lRegTri := C1H->(FieldPos("C1H_REGTRI")) > 0
endif

if _lPaisIbge == Nil
    _lPaisIbge := C08->(FieldPos("C08_PAISIB")) > 0
endif

cCompC1N   := Upper(AllTrim(FWModeAccess("C1N", 1) + FWModeAccess("C1N", 2) + FWModeAccess("C1N", 3))) //TES
cCompC1H   := Upper(AllTrim(FWModeAccess("C1H", 1) + FWModeAccess("C1H", 2) + FWModeAccess("C1H", 3))) //Participante
cCompT9C   := Upper(AllTrim(FWModeAccess("T9C", 1) + FWModeAccess("T9C", 2) + FWModeAccess("T9C", 3))) //Obra
cQuery     := ''
cAlias     := GetNextAlias()
aInfEUF    := TAFTamEUF(Upper(AllTrim(FWSM0Util():GetSM0Data(,,{'M0_LEIAUTE'})[1][2])))
aCodTri    := {"000001", "000016"}
aCodMod    := {"000040", "000035"}
aCodSit    := {"000001","000002","000004","000007","000008","000009"} //Situações difetentes de CANCELADA, INUTILIZADA E DENEGADA
aBind      := {}
nX         := 0
nTmAFil	   := 0
cIsNullSQL := ''
cConcat    := ''

If cSGBD $ "MSSQL7|MSSQL"
	cIsNullSQL := "ISNULL"
    cConcat    := "+"
ElseIf cSGBD $ "ORACLE"
	cIsNullSQL := "NVL"
    cConcat    := "||"
ElseIf cSGBD $ "POSTGRES"
    cConcat    := "||"
EndIf

cQuery += "SELECT C20.C20_FILIAL FILIAL, C20.C20_NUMDOC NUMDOC, C20.C20_SERIE SERIE, C20.C20_DTDOC DTDOC, "
if _lDtCpIss
    cQuery += "C20.C20_DTCPIS DTCPIS, "
endif
cQuery += "C20.C20_VLSERV VLSERV, "

cQuery += "C20.C20_VLABMT VLABMT, C20.C20_VLABSU VLABSU, "

cQuery += "( SELECT C09.C09_CODIGO " + cConcat + " SUBC07.C07_CODIGO FROM " + RetSqlName("C07") + " SUBC07 LEFT JOIN " + RetSqlName("C09") + " SUBC09 ON "
cQuery += "SUBC09.C09_FILIAL = ? AND SUBC09.C09_ID = C07.C07_UF AND SUBC09.D_E_L_E_T_ = ? "
cQuery += "WHERE SUBC07.C07_FILIAL = ? AND SUBC07.C07_ID = C20.C20_CODLOC AND SUBC07.D_E_L_E_T_ = ? ) CODLOC, " //Necessario concatenar a UF com o Municipio
//auto contidas nao altera compartilhamento
aAdd(aBind, xFilial("C09"))
aAdd(aBind, space(1))
aAdd(aBind, xFilial("C07"))
aAdd(aBind, space(1))

cQuery += "C30.C30_VLDESC VLDESC, "

If cSGBD $ "MSSQL7|MSSQL"
	cQuery += cIsNullSQL + " (CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), C30.C30_DESCRI)),?) DESCRI, "
    aAdd(aBind, space(1))
ElseIf cSGBD $ "ORACLE"
	cQuery += cIsNullSQL + " (dbms_lob.substr(C30.C30_DESCRI,2000,1),?) DESCRI, "
    aAdd(aBind, space(1))
ElseIf cSGBD $ "POSTGRES"
	cQuery += "C30.C30_DESCRI DESCRI, "
EndIf

cQuery += "C0B.C0B_CODIGO CODSER, C30_SRVMUN SRVMUN, "
cQuery += "CASE WHEN C35.C35_CODTRI IN (?) THEN C35.C35_CODTRI ELSE ? END CODTRI, "
aAdd(aBind, aCodTri)
aAdd(aBind, space(1))

If cSGBD $ "ORACLE"
    cQuery += "CASE WHEN C35.C35_CODTRI IN (?) THEN C35.C35_VALOR ELSE TO_NUMBER(?) END VALTRI, "
    cQuery += "CASE WHEN C35.C35_CODTRI IN (?) THEN C35.C35_ALIQ ELSE TO_NUMBER(?) END ALITRI, "
    aAdd(aBind, aCodTri)
    aAdd(aBind, '0')
    aAdd(aBind, aCodTri)
    aAdd(aBind, '0')
Else
    cQuery += "CASE WHEN C35.C35_CODTRI IN (?) THEN C35.C35_VALOR ELSE ? END VALTRI, "
    cQuery += "CASE WHEN C35.C35_CODTRI IN (?) THEN C35.C35_ALIQ ELSE ? END ALITRI, "
    aAdd(aBind, aCodTri)
    aAdd(aBind, 0)
    aAdd(aBind, aCodTri)
    aAdd(aBind, 0)
endif

cQuery += "( SELECT SUM(SUBQ1.C35_VALOR) FROM " + RetSqlName("C35") + " SUBQ1 WHERE " + FwJoinFilial("C35","C20","SUBQ1","C20") + " AND SUBQ1.C35_CHVNF = C20.C20_CHVNF AND SUBQ1.C35_CODTRI = ? AND SUBQ1.D_E_L_E_T_ = ? ) PIS, "
aAdd(aBind, '000010')
aAdd(aBind, space(1))

cQuery += "( SELECT SUM(SUBQ2.C35_VALOR) FROM " + RetSqlName("C35") + " SUBQ2 WHERE " + FwJoinFilial("C35","C20","SUBQ2","C20") + " AND SUBQ2.C35_CHVNF = C20.C20_CHVNF AND SUBQ2.C35_CODTRI = ? AND SUBQ2.D_E_L_E_T_ = ? ) COFINS, "
aAdd(aBind, '000011')
aAdd(aBind, space(1))

cQuery += "( SELECT SUM(SUBQ3.C35_VALOR) FROM " + RetSqlName("C35") + " SUBQ3 WHERE " + FwJoinFilial("C35","C20","SUBQ3","C20") + " AND SUBQ3.C35_CHVNF = C20.C20_CHVNF AND SUBQ3.C35_CODTRI IN (?) AND SUBQ3.D_E_L_E_T_ = ? ) IR, "
aAdd(aBind, {"000012", "000028"})
aAdd(aBind, space(1))

cQuery += "( SELECT SUM(SUBQ4.C35_VALOR) FROM " + RetSqlName("C35") + " SUBQ4 WHERE " + FwJoinFilial("C35","C20","SUBQ4","C20") + " AND SUBQ4.C35_CHVNF = C20.C20_CHVNF AND SUBQ4.C35_CODTRI = ? AND SUBQ4.D_E_L_E_T_ = ? ) INSS, "
aAdd(aBind, '000013')
aAdd(aBind, space(1))

cQuery += "( SELECT SUM(SUBQ5.C35_VALOR) FROM " + RetSqlName("C35") + " SUBQ5 WHERE " + FwJoinFilial("C35","C20","SUBQ5","C20") + " AND SUBQ5.C35_CHVNF = C20.C20_CHVNF AND SUBQ5.C35_CODTRI = ? AND SUBQ5.D_E_L_E_T_ = ? ) CSLL, "
aAdd(aBind, '000018')
aAdd(aBind, space(1))

cQuery += "C1H.C1H_CNPJ CNPJ, C1H.C1H_CPF CPF, C1H.C1H_NOME NOME, C1H.C1H_TPLOGR TPLOGR, C1H.C1H_END ENDERECO, C1H.C1H_NUM NUMERO, "
cQuery += "C1H.C1H_BAIRRO BAIRRO, C07.C07_CODIGO CODMUN, C09.C09_UF UF, C09.C09_CODIGO CODUF, C1H.C1H_CEP CEP, C1H.C1H_FONE FONE, C1H.C1H_EMAIL EMAIL, "

if _lRegTri
    cQuery += "C1H.C1H_REGTRI REGTRI, "
endif

cQuery += "CASE WHEN C1H.C1H_SIMPLS = ? THEN ? ELSE ? END SIMPLS, "
aAdd(aBind, '1') //sim
aAdd(aBind, '1') //sim
aAdd(aBind, '2') //nao

cQuery += "T9C.T9C_NRINSC OBRINSC, "

cQuery += "CASE T85.T85_CODIGO "
cQuery += "WHEN ? THEN ? " //Exigível
cQuery += "WHEN ? THEN ? " //Exportação
cQuery += "WHEN ? THEN ? " //Imunidade
cQuery += "WHEN ? THEN ? " //Isenção
cQuery += "WHEN ? THEN ? " //Jucidial
cQuery += "WHEN ? THEN ? " //Não incidência
cQuery += "WHEN ? THEN ? " //Exigibilidade Proc. Administrativo
cQuery += "ELSE ? END IDEXIG " //ultimo campo sem protecao nao ter virgula vazio para 00=Cancelada ou 07=Intermunicipal (Nao tem na gissabrasf)
aAdd(aBind, '01')
aAdd(aBind, '1')    //Exigível
aAdd(aBind, '02') 
aAdd(aBind, '4')    //Exportação
aAdd(aBind, '03')
aAdd(aBind, '5')    //Imunidade
aAdd(aBind, '04')
aAdd(aBind, '3')    //Isenção
aAdd(aBind, '05')
aAdd(aBind, '6')    //Exigibilidade Decisão Jucidial
aAdd(aBind, '06')
aAdd(aBind, '2')    //Não incidência
aAdd(aBind, '08')
aAdd(aBind, '7')    //Exigibilidade Proc. Administrativo
aAdd(aBind, space(1) )

if _lCodArt
    cQuery += ", T9C.T9C_CODART OBRCODART "
endif
if _lPaisIbge
    cQuery += ", C08.C08_PAISIB PAISIB "
endif

cQuery += " FROM " + RetSqlName("C20") + " C20 "

cQuery += "INNER JOIN " + RetSqlName("C30") + " C30 ON "
cQuery += FwJoinFilial("C30","C20")
cQuery += " AND C30.C30_CHVNF = C20.C20_CHVNF "
cQuery += "AND C30.D_E_L_E_T_ = ? "
aAdd(aBind, Space(1))

//Codigo Serviço (LCF 116/2003)
cQuery += "LEFT JOIN " + RetSqlName("C0B") + " C0B ON " //C0B_FILIAL, C0B_ID, R_E_C_N_O_, D_E_L_E_T_
cQuery += "C0B.C0B_FILIAL = ? " //auto contidas nao altera compartilhamento
cQuery += "AND C0B.C0B_ID = C30.C30_CODSER "
cQuery += "AND C0B.D_E_L_E_T_ = ? "
aAdd(aBind, xFilial("C0B"))
aAdd(aBind, Space(1))

cQuery += "LEFT JOIN " + RetSqlName("C35") + " C35 ON "
cQuery += FwJoinFilial("C35","C30")
cQuery += " AND C35.C35_CHVNF = C30.C30_CHVNF "
cQuery += "AND C35.C35_NUMITE = C30.C30_NUMITE "
cQuery += "AND C35.C35_CODITE = C30.C30_CODITE "
cQuery += "AND C35.C35_CODTRI IN (?) "
cQuery += "AND C35.D_E_L_E_T_ = ? "
aAdd(aBind, aCodTri)
aAdd(aBind, Space(1))

cQuery += "LEFT JOIN " + RetSqlName("C1N") + " C1N ON " //Cadastro TES
If cCompC1N == "CCC" .or. (cCompC1N == "EEC" .and. (aInfEUF[1] + aInfEUF[2]) == 0)
	cQuery += "C1N.C1N_FILIAL = ? "
	aAdd(aBind, xFilial("C1N"))
Else
	cQuery += FwJoinFilial("C1N","C30")
EndIf
cQuery += " AND C1N.C1N_ID = C30.C30_NATOPE "
cQuery += "AND C1N.D_E_L_E_T_ = ? "
aAdd(aBind, Space(1))

cQuery  += "INNER JOIN " + RetSqlName("C1H") + " C1H ON " //Cadastro Participante
If cCompC1H == "CCC" .or. (cCompC1H == "EEC" .and. (aInfEUF[1] + aInfEUF[2] )== 0)
	cQuery += "C1H.C1H_FILIAL = ? "
	aAdd(aBind, xFilial("C1H"))
Else
	cQuery += FwJoinFilial("C1H","C20")
EndIf
cQuery += " AND C1H.C1H_ID = C20.C20_CODPAR "
cQuery += "AND C1H.D_E_L_E_T_ = ? "
aAdd(aBind, Space(1))

//Municípios do IBGE
cQuery += "LEFT JOIN " + RetSqlName("C07") + " C07 ON " //C07_FILIAL, C07_ID, R_E_C_N_O_, D_E_L_E_T_
cQuery += "C07.C07_FILIAL = ? " //auto contidas nao altera compartilhamento
cQuery += "AND C07.C07_ID = C1H.C1H_CODMUN "
cQuery += "AND C07.D_E_L_E_T_ = ? "
aAdd(aBind, xFilial("C07"))
aAdd(aBind, Space(1))

//Países Bco Central/SISCOMEX IBGE
cQuery += "LEFT JOIN " + RetSqlName("C08") + " C08 ON " //C08_FILIAL, C08_ID, R_E_C_N_O_, D_E_L_E_T_
cQuery += "C08.C08_FILIAL = ? " //auto contidas nao altera compartilhamento
cQuery += "AND C08.C08_ID = C1H.C1H_CODPAI "
cQuery += "AND C08.D_E_L_E_T_ = ? "
aAdd(aBind, xFilial("C08"))
aAdd(aBind, Space(1))

//Unidades Federativas
cQuery += "LEFT JOIN " + RetSqlName("C09") + " C09 ON " //C09_FILIAL, C09_ID, R_E_C_N_O_, D_E_L_E_T_
cQuery += "C09.C09_FILIAL = ? " //auto contidas nao altera compartilhamento
cQuery += "AND C09.C09_ID = C1H.C1H_UF "
cQuery += "AND C09.D_E_L_E_T_ = ? "
aAdd(aBind, xFilial("C09"))
aAdd(aBind, Space(1))

//Exigibilidade do ISSQN
cQuery += "LEFT JOIN " + RetSqlName("T85") + " T85 ON " //T85_FILIAL, T85_ID, R_E_C_N_O_, D_E_L_E_T_
cQuery += "T85.T85_FILIAL = ? " //auto contidas nao altera compartilhamento
cQuery += "AND T85.T85_ID = C1N.C1N_IDEXIG "
cQuery += "AND T85.D_E_L_E_T_ = ? "
aAdd(aBind, xFilial("T85"))
aAdd(aBind, Space(1))

cQuery  += "LEFT JOIN " + RetSqlName("T9C") + " T9C ON " //Cadastro Obra
If cCompT9C == "CCC" .or. (cCompT9C == "EEC" .and. (aInfEUF[1] + aInfEUF[2]) == 0)
	cQuery += "T9C.T9C_FILIAL = ? "
	aAdd(aBind, xFilial("T9C")) 
Else
	cQuery += FwJoinFilial("T9C","C20")
EndIf
cQuery += " AND T9C.T9C_ID = C20.C20_IDOBR AND T9C.D_E_L_E_T_ = ? "
aAdd(aBind, Space(1))

nTmAFil := Len( aFilGis )

cQuery += " WHERE "
if nTmAFil > 1
	cQuery += "C20.C20_FILIAL IN (?) "
	aAdd(aBind, aFilGis )
else
	cQuery += "C20.C20_FILIAL = ? "
	aAdd(aBind, aFilGis[nTmAFil] )
endif

cQuery += "AND C20.C20_DTDOC BETWEEN ? AND ? "
cQuery += "AND C20.C20_INDOPE = ? "
cQuery += "AND C20.C20_CODSIT  IN (?) "
cQuery += "AND (C35.C35_CODTRI IN (?) OR C20.C20_CODMOD IN (?)) "
cQuery += "AND C20.D_E_L_E_T_ = ? "

aAdd(aBind, cDtIni  )
aAdd(aBind, cDtFin  )
aAdd(aBind, '0'     )
aAdd(aBind, aCodSit )
aAdd(aBind, aCodTri )
aAdd(aBind, aCodMod )
aAdd(aBind, Space(1))

cQuery += "ORDER BY C20.C20_FILIAL, C20.C20_NUMDOC, C20.C20_SERIE, C20.C20_DTDOC "

cQuery := ChangeQuery(cQuery)
oPrepare := FwExecStatement():New(cQuery)

For nX := 1 To Len(aBind)
	If ValType(aBind[nX]) == 'C'
		oPrepare:setString(nX, aBind[nX])
	Elseif ValType(aBind[nX]) == 'A'
        oPrepare:setIn(nX, aBind[nX])
	Elseif ValType(aBind[nX]) == 'N'
        oPrepare:setNumeric(nX, aBind[nX])
	EndIf
Next nX

oPrepare:OpenAlias(cAlias) //oPrepare:GetFixQuery()

DbSelectArea(cAlias)
Count to nTotReg

(cAlias)->(dbGoTop())

aSize(aBind,0)
aBind := {}

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFGISXML
Funcao de geracao do XML

@Param
@Return
@Author Jose Felipe / Denis Souza
@Since 04/12/2024
@Version 1.0
/*/
//----------------------------------------------------------------------------
Static Function TAFGISXML( cAlias, cCaminho, cNmArquivo, lSucess, lFilSel, lAglutina, lAutomato )

Local cXml         := ""
Local cXmlServ     := ""
Local cTipoInsc    := ""
Local cCGCTmd	   := ""
Local cIMunTmd     := ""
Local cIssRet      := ""
Local cResReten    := ""
Local cEndePart    := ""
Local nValDeduc    := 0
Local nCount       := 0
Local nLote        := 1
Local nTotTrib     := 0
Local cFirstFil    := ''
Local cLastFil     := ''
Local cDtCpIs      := ''
Local cCodArt      := ''
Local cRegTri      := ''
Local cCodExig     := ''
Local cPaisIbge    := ''
Local cDescri      := ''
Local cData        := ''

Default cAlias     := ''
Default cCaminho   := ''
Default cNmArquivo := ''
Default lSucess    := .F.
Default lFilSel    := .F.
Default lAglutina  := .F.
Default lAutomato  := .F.

If !ExistDir(cCaminho)
    MakeDir(cCaminho)
EndIf

//primeira vez carrega os dados da primeira filial
cTipoInsc := cValToChar(FWSM0Util():GetSM0Data( cEmpAnt , (cAlias)->FILIAL , { "M0_TPINSC" } )[1][2]) //numerico
cCGCTmd   := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , (cAlias)->FILIAL , { "M0_CGC" } )[1][2])       //caracter
cIMunTmd  := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , (cAlias)->FILIAL , { "M0_INSCM" } )[1][2])     //caracter
cData     := FmtData((cAlias)->DTDOC)

While !(cAlias)->(Eof())

    if !Empty(cLastFil) .And. cLastFil <> Alltrim((cAlias)->FILIAL)

        if lFilSel .And. !lAglutina //Seleciona Filial = 'Sim' e Aglutina = 'Nao' devera Gerar o Arquivo e nomenclatura por filial + Lote X

            cXml := XmlHeadFoot(nCount,cTipoInsc,cCGCTmd,cIMunTmd,cXmlServ,nLote) //gera o xml por lote

            NewFileLote(cNmArquivo,nLote,cCaminho,@lSucess,cXml,lFilSel,lAglutina,cLastFil,'',lAutomato)

            //Quando alterar a filial, recarrega cTipoInsc, cCGCTmd e cIMunTmd no Header devido a nomenclatura ser por filial
            cTipoInsc := cValToChar(FWSM0Util():GetSM0Data( cEmpAnt , (cAlias)->FILIAL , { "M0_TPINSC" } )[1][2]) //numerico
            cCGCTmd   := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , (cAlias)->FILIAL , { "M0_CGC" } )[1][2])       //caracter
            cIMunTmd  := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , (cAlias)->FILIAL , { "M0_INSCM" } )[1][2])     //caracter

            //Se mudar de filial e Seleciona Filial = 'Sim' e Aglutina = 'Nao', para cada nova filiial o lote e a tag numero irá iniciar com novamente com 1
            nLote    := 1 
            cXmlServ := ""
            nCount   := 0
        endif
    endif

    IF (cAlias)->CODTRI == "000001"
        cIssRet  := "0" //ISS
        cResReten := "2" //Responsável - Intermediario
    Elseif (cAlias)->CODTRI == "000016"
        cIssRet  := "1" //ISS Retido
        cResReten := "1" //Responsável - Tomador
    Endif

    if nCount == 0
        cFirstFil := Alltrim((cAlias)->FILIAL)
    endif
    
    //Incrementa quantidade de registro para o lote.
    nCount++

    cLastFil  := Alltrim((cAlias)->FILIAL)
    cEndePart := Alltrim((cAlias)->TPLOGR) + " " + Alltrim((cAlias)->ENDERECO)
    nValDeduc := GISFmtVlr((cAlias)->VLABMT + (cAlias)->VLABSU)
    nTotTrib  := GISFmtVlr( (cAlias)->PIS + (cAlias)->COFINS + (cAlias)->IR + (cAlias)->INSS + (cAlias)->CSLL )

    cXmlServ +="<tipos:ListaDeclaracaoServicoComprado>"
    cXmlServ +=    "<tipos:TipoDeclaracaoNota>2</tipos:TipoDeclaracaoNota>" //2 quando tem nota e 10 quando nao tem nota.
    cXmlServ +=    "<tipos:IdentificacaoDeclaracao>"
    cXmlServ +=        "<tipos:Numero>" + Alltrim(SubSTr((cAlias)->NUMDOC,1,15)) + "</tipos:Numero>" 
    cXmlServ +=        "<tipos:NumeroDeclarado>" + Alltrim(SubSTr((cAlias)->NUMDOC,1,15)) + "</tipos:NumeroDeclarado>"
    cXmlServ +=        "<tipos:Serie>" + Alltrim(SubSTr((cAlias)->SERIE,1,5)) + "</tipos:Serie>"
    cXmlServ +=        "<tipos:SerieDeclarada>" + Alltrim(SubSTr((cAlias)->SERIE,1,5)) + "</tipos:SerieDeclarada>"
    cXmlServ +=        "<tipos:Tipo>1</tipos:Tipo>" //valor fixo 1
    cXmlServ +=    "</tipos:IdentificacaoDeclaracao>"
    cXmlServ +=    "<tipos:DataEmissao>" + cData + "</tipos:DataEmissao>"

    cDtCpIs := ''
    if _lDtCpIss
        cDtCpIs := FmtData((cAlias)->DTCPIS)
    endif
    cXmlServ +=	    "<tipos:Competencia>" + cDtCpIs + "</tipos:Competencia>"

    cXmlServ +=    "<tipos:DadosTomador>"
    cXmlServ +=        "<tipos:CpfCnpj>"
    If cTipoInsc == "2"
        cXmlServ +=         "<tipos:Cnpj>" + Alltrim(cCGCTmd) + "</tipos:Cnpj>"
    Else
        cXmlServ +=         "<tipos:Cpf>" + Alltrim(cCGCTmd) + "</tipos:Cpf>"
    Endif
    cXmlServ +=       "</tipos:CpfCnpj>"
    cXmlServ +=       "<tipos:InscricaoMunicipal>" + Alltrim(SubSTr(cIMunTmd,1,15)) + "</tipos:InscricaoMunicipal>"
    cXmlServ +=    "</tipos:DadosTomador>"
    cXmlServ +=    "<tipos:DadosPrestador>"
    cXmlServ +=        "<tipos:Identificacao>"
    cXmlServ +=             "<tipos:CpfCnpj>"
    if !Empty(Alltrim((cAlias)->CNPJ))
        cXmlServ +=             "<tipos:Cnpj>" + Alltrim((cAlias)->CNPJ) + "</tipos:Cnpj>"        
    Elseif !Empty(Alltrim((cAlias)->CPF))
        cXmlServ +=             "<tipos:Cpf>" + Alltrim((cAlias)->CPF) + "</tipos:Cpf>"
    Endif
    cXmlServ +=             "</tipos:CpfCnpj>"
    cXmlServ +=        "</tipos:Identificacao>"
    cXmlServ +=        "<tipos:NomeFantasia>" + Alltrim(SubSTr(TafNorStrES((cAlias)->NOME,1),1,60)) + "</tipos:NomeFantasia>"
    cXmlServ +=        "<tipos:RazaoSocial>" + Alltrim(SubSTr(TafNorStrES((cAlias)->NOME,1),1,150)) + "</tipos:RazaoSocial>"
    cXmlServ +=        "<tipos:Endereco>"
    cXmlServ +=            "<tipos:Endereco>" + Alltrim(SubSTr(cEndePart,1,125)) + "</tipos:Endereco>"
    cXmlServ +=            "<tipos:Numero>" + Alltrim(SubSTr((cAlias)->NUMERO,1,10)) + "</tipos:Numero>"
    cXmlServ +=            "<tipos:Bairro>" + Alltrim(SubSTr((cAlias)->BAIRRO,1,60)) + "</tipos:Bairro>"
    cXmlServ +=            "<tipos:CodigoMunicipio>" + Alltrim((cAlias)->CODUF) + Alltrim(SubSTr((cAlias)->CODMUN,1,5)) + "</tipos:CodigoMunicipio>"
    cXmlServ +=            "<tipos:Uf>" + Alltrim((cAlias)->UF) + "</tipos:Uf>"
    cXmlServ +=            "<tipos:Cep>" + Alltrim(SubSTr((cAlias)->CEP,1,8)) + "</tipos:Cep>"
    cXmlServ +=        "</tipos:Endereco>"
    cXmlServ +=        "<tipos:Contato>"
    cXmlServ +=            "<tipos:Telefone>" + Alltrim(SubSTr((cAlias)->FONE,1,20)) + "</tipos:Telefone>"
    cXmlServ +=            "<tipos:Email>" + Alltrim(SubSTr((cAlias)->EMAIL,1,80)) + "</tipos:Email>"
    cXmlServ +=        "</tipos:Contato>"

    cRegTri := ''
    if _lRegTri
        cRegTri := Alltrim((cAlias)->REGTRI)
    endif
    if cRegTri $ "123456" //OBS: Caso o prestador não possua nenhum dos regimes 123456, a tag não deve ser informada no arquivo
        cXmlServ +=        "<tipos:RegimeEspecialTributacao>" + cRegTri + "</tipos:RegimeEspecialTributacao>"
    endif

    cXmlServ +=            "<tipos:OptanteSimplesNacional>" + Alltrim((cAlias)->SIMPLS) + "</tipos:OptanteSimplesNacional>"
    cXmlServ +=    "</tipos:DadosPrestador>"
    cXmlServ +=    "<tipos:DadosServicoComprado>"
    cXmlServ +=        "<tipos:Valores>"
    cXmlServ +=            "<tipos:ValorServicos>" + GISFmtVlr((cAlias)->VLSERV) + "</tipos:ValorServicos>"
    cXmlServ +=            "<tipos:ValorDeducoes>" + nValDeduc + "</tipos:ValorDeducoes>"
    cXmlServ +=            "<tipos:ValorPis>" + GISFmtVlr((cAlias)->PIS) + "</tipos:ValorPis>"
    cXmlServ +=            "<tipos:ValorCofins>" + GISFmtVlr((cAlias)->COFINS) + "</tipos:ValorCofins>"
    cXmlServ +=            "<tipos:ValorInss>" + GISFmtVlr((cAlias)->IR) + "</tipos:ValorInss>"
    cXmlServ +=            "<tipos:ValorIr>" + GISFmtVlr((cAlias)->INSS) + "</tipos:ValorIr>"
    cXmlServ +=            "<tipos:ValorCsll>" + GISFmtVlr((cAlias)->CSLL) + "</tipos:ValorCsll>"
    cXmlServ +=            "<tipos:OutrasRetencoes>0</tipos:OutrasRetencoes>" //0 Não usado
    cXmlServ +=            "<tipos:ValTotTributos>" + nTotTrib +"</tipos:ValTotTributos>" //Somar todos os triburos com excecao do ISSQN.
    cXmlServ +=            "<tipos:ValorIss>" + GISFmtVlr((cAlias)->VALTRI) + "</tipos:ValorIss>"
    cXmlServ +=            "<tipos:Aliquota>" + strZero((cAlias)->ALITRI / 100,6,4)  + "</tipos:Aliquota>" //Valor aceito pelo validador em decimal ex. 5% = 0.0500
    cXmlServ +=            "<tipos:DescontoIncondicionado>" + GISFmtVlr((cAlias)->VLDESC) + "</tipos:DescontoIncondicionado>"
    cXmlServ +=            "<tipos:DescontoCondicionado>0</tipos:DescontoCondicionado>" //0 Não usado
    cXmlServ +=        "</tipos:Valores>"
    cXmlServ +=        "<tipos:IssRetido>" + Alltrim(cIssRet) + "</tipos:IssRetido>"
    cXmlServ +=        "<tipos:ResponsavelRetencao>" + Alltrim(cResReten) + "</tipos:ResponsavelRetencao>"
    cXmlServ +=        "<tipos:ItemListaServico>" + FmtCodIss(Alltrim((cAlias)->CODSER)) + "</tipos:ItemListaServico>"
    cXmlServ +=        "<tipos:CodigoTributacaoMunicipio>" + Alltrim(SubSTr((cAlias)->SRVMUN,1,20)) + "</tipos:CodigoTributacaoMunicipio>"

    cDescri := ''
    if !Empty((cAlias)->DESCRI)
        cDescri := Alltrim(SubSTr((cAlias)->DESCRI,1,2000))
    endif
    cXmlServ +=        "<tipos:Discriminacao>" + cDescri + "</tipos:Discriminacao>"
    
    cXmlServ +=        "<tipos:CodigoMunicipio>" + Alltrim(SubSTr((cAlias)->CODLOC,1,7)) + "</tipos:CodigoMunicipio>" //ex: SP50308

    cPaisIbge := ''
    if _lPaisIbge
        cPaisIbge := Alltrim(cValToChar(Val((cAlias)->PAISIB)))
    endif
    cXmlServ +=     "<tipos:CodigoPais>" + cPaisIbge + "</tipos:CodigoPais>"

    cCodExig := ''
    if !Empty((cAlias)->IDEXIG)
        cCodExig := Alltrim((cAlias)->IDEXIG)
    endif
    cXmlServ +=        "<tipos:ExigibilidadeISS>" + cCodExig + "</tipos:ExigibilidadeISS>"

    cXmlServ +=        "<tipos:MunicipioIncidencia>" + Alltrim(SubSTr((cAlias)->CODLOC,1,7)) + "</tipos:MunicipioIncidencia>"
    cXmlServ +=    "</tipos:DadosServicoComprado>"

    if !Empty((cAlias)->OBRINSC)
        cXmlServ +=    "<tipos:DadosConstrucaoCivil>"
        cXmlServ +=        "<tipos:CodigoObra>" + Alltrim(SubSTr((cAlias)->OBRINSC,1,15)) + "</tipos:CodigoObra>"

        cCodArt := ''
        if _lCodArt
            cCodArt := Alltrim((cAlias)->OBRCODART)
        endif
        cXmlServ +=        "<tipos:Art>" + Alltrim(SubSTr(cCodArt,1,15)) + "</tipos:Art>"

        cXmlServ +=    "</tipos:DadosConstrucaoCivil>"
    endIf
    
    cXmlServ +="</tipos:ListaDeclaracaoServicoComprado>"    

    If nCount == QTDLOTE
        cXml := XmlHeadFoot(nCount,cTipoInsc,cCGCTmd,cIMunTmd,cXmlServ,nLote) //gera o xml por lote
        NewFileLote(cNmArquivo,nLote,cCaminho,@lSucess,cXml,lFilSel,lAglutina,cLastFil,cFirstFil,lAutomato)
        // Incrementa o número do lote e reinicia contadores
        nLote++
        cXmlServ := ""
        nCount := 0
    Endif

    (cAlias)->(DbSkip())
EndDo

if !Empty(cXmlServ) //gera o xml residual
    cXml := XmlHeadFoot(nCount,cTipoInsc,cCGCTmd,cIMunTmd,cXmlServ,nLote) //ultimo lote nao precisara ser incrementado.
    NewFileLote(cNmArquivo,nLote,cCaminho,@lSucess,cXml,lFilSel,lAglutina,cLastFil,cFirstFil,lAutomato)
endif

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} GISFmtVlr

@Param
@Return
@Author Jose Felipe
@Since 04/12/2024
@Version 1.0
/*/
//----------------------------------------------------------------------------
Static Function GISFmtVlr(nValue)

    Local cRetMask := ""

    Default nValue := 0

    If nValue > 0
        cRetMask := StrTran(StrTran(Alltrim(TRANSFORM(nValue, "@E 9,999,999,999,999.99")),".",""),",",".")
    Else
        cRetMask := "0"
    Endif

Return cRetMask

//----------------------------------------------------------------------------
/*/{Protheus.doc} XmlHeadFoot

@Param
@Return
@Author Jose Felipe / Denis Souza
@Since 04/12/2024
@Version 1.0
/*/
//----------------------------------------------------------------------------
Static Function XmlHeadFoot(nCount,cTipoInsc,cCGCTmd,cIMunTmd,cXmlServ,nLote)

Local cXml as char

Default nCount    := 0
Default cTipoInsc := ''
Default cCGCTmd   := ''
Default cIMunTmd  := ''
Default cXmlServ  := ''
Default nLote     := 0

cXml :='<?xml version="1.0" encoding="UTF-8"?>'
cXml +='<ns1:EnviarLoteNotaServicoCompradoEnvio xmlns:ns1="http://www.giss.com.br/enviar-lote-nota-servico-comprado-envio-v1_00.xsd" '
cXml +='xmlns:tipos="http://www.giss.com.br/tipos-servicos-comprados-v1_00.xsd">'

cXml +='<ns1:LoteNotaServicoComprado QuantidadeNotaServicoComprado="'+cValToChar(nCount)+'">'
cXml += "<tipos:IdentificacaoRemessa>"
cXml +=     "<tipos:Numero>" + Alltrim(cValToChar(nLote)) + "</tipos:Numero>"
cXml += "</tipos:IdentificacaoRemessa>"
cXml += "<tipos:Tomador>"
cXml +=     "<tipos:CpfCnpj>"

If cTipoInsc == "2"
    cXml +=     "<tipos:Cnpj>" + Alltrim(cCGCTmd) + "</tipos:Cnpj>"
Else 
    cXml +=     "<tipos:Cpf>" + Alltrim(cCGCTmd) + "</tipos:Cpf>"                          
Endif

cXml +=     "</tipos:CpfCnpj>"
cXml +=     "<tipos:InscricaoMunicipal>" + Alltrim(SubSTr(cIMunTmd,1,15)) + "</tipos:InscricaoMunicipal>"
cXml += "</tipos:Tomador>"
cXml += cXmlServ
cXml +="</ns1:LoteNotaServicoComprado>"
cXml +="</ns1:EnviarLoteNotaServicoCompradoEnvio>"

Return cXml

//----------------------------------------------------------------------------
/*/{Protheus.doc} NewFileLote

@Param
@Return
@Author Jose Felipe / Denis Souza
@Since 04/12/2024
@Version 1.0
/*/
//----------------------------------------------------------------------------
Static Function NewFileLote(cNmArquivo,nLote,cCaminho,lSucess,cXml,lFilSel,lAglutina,cLastFil,cFirstFil,lAutomato)

    Local cNomeArquivo := ''
    Local cArqCompleto := ''
    Local nHandle      := 0
    Local cTmpFolder   := ''
    Local cBarra       := ''
    Local cPathTmp     := ''
    Local lSmartCHtml  := .F.
    Local cGrpFil      := ''
    Local lAutoCt10    := .F.

    Default cNmArquivo := ''
    Default nLote      := 0
    Default cCaminho   := ''
    Default lSucess    := .F.
    Default cXml       := ''
    Default lFilSel    := .F.
    Default lAglutina  := .F.
    Default cLastFil   := ''
    Default cFirstFil  := ''
    Default lAutomato  := .F.

	//Tratamento para Linux onde a barra é invertida    
    cBarra := '/' //fmt linux

	If GetRemoteType() <> 2 //0 = QT Win 6e7; 1 = QT Win 8e10; 2 = QT linux 8e10 ; 3 = nao utilizado; 4 = telnet; 5 smartclient html; 6=nao utilizado; 6 smartclient windows C
        cBarra := '\' //windows
	EndIf

    cNomeArquivo := cNmArquivo + "_Lote" + AllTrim(Str(nLote)) + ".xml"
    cArqCompleto := cCaminho + cBarra + cNomeArquivo

    //Cria pasta na gissabrasf dentro do protheus_data
    cTmpFolder := lower(cBarra + "gissabrasf")
    FWMakeDir( cTmpFolder )

    cGrpFil := ''
    if !lFilSel .And. !lAglutina //Selec Filial = 'N' e Aglutina = 'N', gerar arquivo e nomenclatura para a filial logada + Lote X
        cGrpFil := lower(StrTran("_" + Alltrim(cEmpAnt) + "_" + Alltrim(cFilAnt),space(1),'_'))
    elseif lFilSel .And. !lAglutina //Selec Filial = 'S' e Aglutina = 'CNPJ ou CNPJ + IE', gerar arquivo e nomenclatura com: grupo + aglutinado + Lote X
        cGrpFil := lower(StrTran("_" + Alltrim(cEmpAnt) + cLastFil, space(1),'_'))
    elseif lFilSel .And. lAglutina
        cGrpFil := lower(StrTran("_" + Alltrim(cEmpAnt) + "_" + cFirstFil + '-' + cLastFil,space(1),'_'))
    endif

    //Caminho temporario dentro da protheus_data\gissabrasf
    cPathTmp := lower(cTmpFolder + cBarra + cNmArquivo + cGrpFil + "_Lote" + AllTrim(Str(nLote)) + ".xml")

    //Verifica se a chamada esta sendo executada pelo CT10 do caso de testes
    lAutoCt10 := isInCallStack('TAFXGABR10')

    if lAutoCt10
        cPathTmp := lower(cBarra + 'baseline' + cBarra + cNmArquivo + cGrpFil + "_Lote" + AllTrim(Str(nLote)) + ".xml")
    endIf

    //Tratamenento para criar arquivo
    nHandle := FCreate( cPathTmp ) //Vindo de automação, o arquivo será gerado na baseline.
    lSucess := .F.
    if FWrite(nHandle, cXml) == Len(cXml)
        lSucess := .T.
    endif
    FClose(nHandle)

    lSmartCHtml := GetRemoteType() == 5 //smartclient html
    if !lSmartCHtml .and. !lAutomato //Se nao for webapp e automação efetua copia da data para caminho local
        //Tratamento para navegador webapp, efetua copia da protheus_data para local informado pelo cliente
        CpyS2T( cPathTmp , cCaminho , .F. )
        FErase( cPathTmp )
    endif

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} FmtCodIss
Hoje na tabela C0B existem apenas codigos com tamanho 4 ou 3.

@Param
@Return
@Author Jose Felipe / Denis Souza
@Since 11/12/2024
@Version 1.0
/*/
//----------------------------------------------------------------------------
Function FmtCodIss(cCodSer)

    Local   cCodFmtd := ''

    Default cCodSer  := ''

    if Len(cCodSer) > 3 //1002 --> 10.02
        cCodFmtd := SubStr(cCodSer,1,2) + '.' + SubStr(cCodSer,3,2)
    else //tm(3) 105 --> 1.05
        cCodFmtd := SubStr(cCodSer,1,1) + '.' + SubStr(cCodSer,2,2)
    endif

Return cCodFmtd

//----------------------------------------------------------------------------
/*/{Protheus.doc} FmtData
Altera a data no formato XXXX-XX-XX aceito pelo validador da GISS

@Param  cData - No formato aaaammdd 
@Return cDtFormat
@Author Wesley Matos
@Since  01/04/2025
@Version 1.0
/*/
//----------------------------------------------------------------------------
Static Function FmtData(cData as string)
    Local cDtFormat as string
    Default cData := ''

    cDtFormat := ''
    if !Empty(cData) 
        cDtFormat := SubStr(Alltrim(cData),1,4) + "-" + SubStr(Alltrim(cData),5,2) + "-" + SubStr(Alltrim(cData),7,2) //Formata de aaaammdd para aaaa-mm-dd
    endIf

Return cDtFormat
