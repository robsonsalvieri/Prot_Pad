#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE F_C1E_MATRIZ 09

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSTAF005
WS para retorno das informações referente ao detalhe das movimentações da base

@author Henrique Fabiano Pateno Pereira
@since 17/05/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSRESTFUL WSTAF005 DESCRIPTION "API Reinf - Retorno dos Card de Transmissão"

WSDATA companyId	AS STRING
WSDATA period		AS STRING
WSDATA event		AS STRING
WSDATA status		AS STRING
WSDATA errorId		AS INTEGER
WSDATA page			AS INTEGER OPTIONAL
WSDATA pageSize		AS INTEGER OPTIONAL

WSMETHOD GET detailStatusTransmission;
	DESCRIPTION "Detalhe por status";
	WSSYNTAX "/detailStatusTransmission";
	PATH "detailStatusTransmission";
	PRODUCES APPLICATION_JSON

WSMETHOD GET statusTransmission;
	DESCRIPTION "Status da transmissão";
	WSSYNTAX "/statusTransmission";
	PATH "statusTransmission";
	PRODUCES APPLICATION_JSON

WSMETHOD GET MsErrorGov;
	DESCRIPTION "Mensagem de erro retornada pelo governo";
	WSSYNTAX "/MsErrorGov";
	PATH "MsErrorGov";
	PRODUCES APPLICATION_JSON

WSMETHOD GET monitoring;
	DESCRIPTION "Monitoramento ao TSS";
	WSSYNTAX "/monitoring";
	PATH "monitoring";
	PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} statusTransmission 
WS para retorno das quantidades exitentes de transmitidos, rejeitado, autorizados e aguardando retorno

@author Henrique Fabiano Pateno Pereira
@since 17/05/2019
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET statusTransmission QUERYPARAM companyId, period, event WSREST WSTAF005

Local aEvents		as array
Local aCompany		as array
Local cAliasTmp		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local nTransmitd	as numeric
Local lRet			as logical
Local oResponse		as object
Local cCode			as character
Local cUser			as character
Local cModule		as character
Local cRoutine		as character

//-----------------------------------------------
// Inicialização variáveis do tipo array
//-----------------------------------------------
aEvents		:=	{}
aCompany	:=	{}

//-----------------------------------------------
// Inicialização variáveis do tipo caracter
//-----------------------------------------------
cAliasTmp	:=	""
cEmpRequest	:=	""
cFilRequest	:=	""
cCode		:= "LS006"
cUser		:= ""
cModule		:= "84"
cRoutine 	:= "TAFReinf"+StrTran(self:event,"-", "")+"BtnAcompanhar"

//-----------------------------------------------
// Inicialização variáveis do tipo numéricas
//-----------------------------------------------
nTransmitd	:=	0

//-----------------------------------------------
// Inicialização variáveis do tipo booleano
//-----------------------------------------------
lRet	:=	.T.

//-----------------------------------------------
// Inicialização variáveis do tipo object
//-----------------------------------------------
oResponse	:=	JsonObject():New()
oResponse["transmitted"]	:=	0
oResponse["waitingReturn"]	:=	0
oResponse["rejected"]		:=	0
oResponse["authorized"]		:=	0

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:period == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Período não informado no parâmetro 'period'." ) )
ElseIf self:event == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Evento não informado no parâmetro 'event'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]

		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )

			cUser := RetCodUsr()
		
			If FindFunction( "FWLSPutAsyncInfo" )
				FWLSPutAsyncInfo( cCode, cUser, cModule, cRoutine )
				TAFConOut( "-> " +cRoutine,1,.F.,"LSTAF")
			EndIf 	

			aEvents := TAFRotinas( self:event, 4, .F., 5 )

			//-------------------------------------------------------------------
			// Executa a query de pesquisa ao evento no monitor
			//-------------------------------------------------------------------
			cAliasTmp := WS005Stat( aEvents, self:period,,, cFilAnt )

			While ( cAliasTmp )->( !Eof() )
				If !( Empty( ( cAliasTmp )->STATUS ) .or. ( cAliasTmp )->STATUS $ "6|7" )
					nTransmitd ++
				EndIf

				Do Case
					Case ( cAliasTmp )->STATUS == "2"
						oResponse["waitingReturn"] ++
					Case ( cAliasTmp )->STATUS == "3"
						oResponse["rejected"] ++
					Case ( cAliasTmp )->STATUS == "4"
						oResponse["authorized"] ++
				EndCase

				( cAliasTmp )->( DBSkip() )
			EndDo

			( cAliasTmp )->( DBCloseArea() )

			oResponse["transmitted"] := nTransmitd

			lRet := .T.
			self:SetResponse( oResponse:ToJson() )
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} WS005Stat

Executa a consulta aos eventos que ainda não estão protocolados e OK

@Author		henrique.pereira
@Since		17/05/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Function WS005Stat( aEvents, cPeriodo, cStatus, lAnalitc, cBranch)
    local cAlias    as character
    local cAlsfilho as character
    local cAlsneto  as character
    local cSelect   as character
    local cFrom     as character
    local cWhere    as character
	local cGroupBy	as character
    local cLayout   as character
    local cOrderBy  as character
    local cNrInsc   as character
    local aSM0      as array
    local nMatriz   as numeric
    local cAliasLay as character
    local cFils     as character
    local cSepara   as character
    local cBd       as character
    local cCompC1H	as Character
    local nX        as numeric
    local lCompart  as logical
    local aFils     as array
    local aInfoEUF	as array

    default     cPeriodo := ''
    default     cStatus  := ''
    default     lAnalitc := .f.

    cAlsneto    := "V0Q"
    cAliasLay   := aEvents[3] //Alias do Evento
    cBranch     := xFilial(cAliasLay)
    cSelect		:=	""
    cFrom       :=  ""
    cWhere      :=  ""
    cAlias      :=  getnextalias()
    cLayout     :=  ""
    cAlsfilho   :=  ""
    cOrderBy    :=  ""
    cNrInsc		:=  ""
    cLayout     := aEvents[4] //Layout
    nMatriz     := 0
    aSM0		:= {}
    lCompart    := FWModeAccess(cAliasLay,1) == "C" .OR. FWModeAccess(cAliasLay,2) == "C" .OR. FWModeAccess(cAliasLay,3) == "C"
    cFils       := ""
    cSepara     := "/"
    aInfoEUF    := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
    cCompC1H    := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
    cBd 	    := TcGetDb()
	cGroupBy	:= ''

    if AllTrim( cLayout ) == "R-1000"
        aSM0	:= WsLoadFil()
        nMatriz := aScan(aSM0,{|x| x[F_C1E_MATRIZ] })
        cNrInsc := aSM0[nMatriz][6]
    endif

    If !lCompart
        aFils := wsLoadFil()
        For nX := 1 to len(aFils)
            cFils += aFils[nX][3] + Iif(nX == len(aFils) ,"", cSepara)
        Next
        cFils := FormatIn( cFils, cSepara )
    EndIf

    If AllTrim( cLayout ) == "R-1070"
        cAlsfilho   := "C07"
    ElseIf AllTrim( cLayout ) == "R-2020"
        cAlsfilho   := "C1H"
    ElseIf AllTrim( cLayout ) == "R-2030"
        cAlsfilho   := "V1G"
    ElseIf AllTrim( cLayout ) == "R-2040"
        cAlsfilho   := "V1J"
    ElseIf AllTrim( cLayout ) == "R-2055"
        cAlsfilho   := "V5T"
    ElseIf AllTrim( cLayout ) == "R-3010"
        cAlsfilho   := "T9G"
	Elseif alltrim( cLayout ) == 'R-4010'
		cAlsFilho	:= 'V5E'
	Elseif alltrim( cLayout ) == 'R-4020'
		cAlsFilho	:= 'V4S'		
	Elseif alltrim( cLayout ) == 'R-4040'
		cAlsFilho	:= 'V4P'		
	Elseif alltrim( cLayout ) == 'R-4080'
		cAlsFilho	:= 'V99'		
    ElseIf AllTrim( cLayout ) == "R-9000"
         cAlsfilho  := "T9B"
    EndIf

    //SELECT
    cSelect += "' " + cLayout   + "' EVENTO "
    cSelect += " ," + cAliasLay + "." + cAliasLay + "_ID ID "
    cSelect += " ," + cAliasLay + "." + cAliasLay + "_STATUS  STATUS "
    cSelect += " ," + cAliasLay + "." + cAliasLay + "_PROTUL  PROTOCOLO "
    cSelect += " ," + cAliasLay + ".R_E_C_N_O_ RECNO "

    if AllTrim( cLayout ) $ "R-2010|R-2020" .and. lAnalitc
        cSelect += " ," + cAliasLay + "." + cAliasLay + "_VLRPRI  VALOR "
        cSelect += " ," + cAliasLay + "." + cAliasLay + "_VLRBRE  BASE "
        cSelect += " ," + cAliasLay + "." + cAliasLay + "_VLRBRU  BRUTO "
		if AllTrim( cLayout ) $ "R-2010"
			cSelect += ", " + cAliasLay + "." + cAliasLay + "_CNPJPR  CNPJ "
		elseif AllTrim( cLayout ) $ "R-2020"
			cSelect += ", " + cAliasLay + "." + cAliasLay + "_NRINST  CNPJ "
		endif 
		cSelect += ", " + cAliasLay + "." + cAliasLay + "_DPARTI  DPARTI "
		cSelect += ", " + cAliasLay + "." + cAliasLay + "_TPNUOB  CNO "     // Inscrição da Obra
		cSelect += ", " + cAliasLay + "." + cAliasLay + "_DOBRA   DOBRA "   // descrição da Obra
 
 	elseIf AllTrim( cLayout ) == "R-1000"
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_NRINSC  CNPJ "
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_CLAFIS  CLAFIS "
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_INDECD  INDESC "
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_IDCPRB  INDDES "
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_INDACR  ISEMUL "
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_DTINI  INIPER "
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_DTFIN  FINPER "
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_NOMCTT  CONTATO "
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_CPFCTT  CPFCTT "

    elseIf AllTrim( cLayout ) $ "R-1050"
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_CNPJ  CNPJ "
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_TPENTL ENTLIG "

    elseIf AllTrim( cLayout ) $ "R-1070"
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_TPPROC  TPPROC "      // tipo de processo
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_NUMPRO  NUMPROC "     // número do processo
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_DSUFVA  DESCUFVARA "  // uf da vara
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_IDMUNI  IDMUN "       // id do municipio
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_CDMUNI  CODMUN "      // cód. do municipio
        cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_DESCRI DESCMUN "      // descrição do municipio
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_IDVARA  IDVARA "      // id da vara
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_DTINI  DTINI "        // data de inicio
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_DTFIN  DTFIM "        // data de fim

    elseIf AllTrim( cLayout ) $ "R-2030|R-2040"
        cSelect += ", " + cAliasLay + '.' + cAliasLay + "_FILIAL FILIAL "       //filial
        cSelect += ", " + cAliasLay + '.' + cAliasLay + "_NRINSC NRINSC "       //numero de inscrição
        cSelect += ", SUM(" + cAlsfilho + "." + cAlsfilho + "_VLREPA) VLREPA "  //valor repasse
        cSelect += ", SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRET) VLRET  "   //valor bruto
        cSelect += ", SUM(" + cAlsfilho + "." + cAlsfilho + "_VLNRET) VLNRET "  //valor da retenção
        cSelect += ", " + cAliasLay + '.' + cAliasLay + "_ID     ID     "       //id

    elseIf AllTrim( cLayout ) $ "R-2050"
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_FILIAL  FILIAL "    // filial
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_TPINSC  TPINSC "    // tipo de inscrição
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NRINSC  NRINSC "    // número da inscrição
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VRECBT  BRUTO "     // valor da receita bruta
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VCPAPU  VLRCONTR "  // valor da contribuição previdenciária
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VRAAPU  GILRAT "    // valor da contribuição previdenciária GILRAT
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VSEAPU  SENAR "     // valor da contribuição previdenciária SENAR
    
    elseIf AllTrim( cLayout ) $ "R-2055"    
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_FILIAL  FILIAL "    // filial
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NRINSP  NRINSP "    // número da inscrição
        cSelect += " ,  " + 'C1H'     + "." + 'C1H'     + "_NOME "    // Razão Social
      
        cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VBRTPR)  BRUTO "     // valor da receita bruta
        cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VCPPR)   VLRCONTR "  // valor da contribuição previdenciária
        cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VRATPR)  GILRAT "    // valor da contribuição previdenciária GILRAT
        cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VSENPR)  SENAR "     // valor da contribuição previdenciária SENAR

    elseIf AllTrim( cLayout ) $ "R-2060"
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_FILIAL  FILIAL "    // filial
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_TPINSC CTPINSC"     // tipo de inscrição
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NRINSC CNRINSC"     // número de inscrição
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VLRBRT VLRECBTT"    // valor da receita bruta
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VLCPAP VLCPAPUT"    // valor da CPBR
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VLSCPR VLCSUSPT"    // valor da CPBR com exibilidade suspensa

    elseIf AllTrim( cLayout ) $ "R-3010"
        cSelect += ", " + cAliasLay + "." + cAliasLay + "_FILIAL  FILIAL "      //nome da filial
        cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_NUMBOL  BOLETIM "     //Nº do boletim
        cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_MODDES  MODALIDADE "  //modalidade
        cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_NOMCOM  COMPETICAO "  //competicao
        cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_CNPJMA  CNPJMAND "    //cnpj mandatorio
        cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_CNPJVI  CNPJVI "      //cnpj visitante
        cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_PAGANT  PAGANTES "    //qtd pagantes
        cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_NPAGAN  NAOPAGANTES " //qtd nao pagantes
        cSelect += ", " + cAlsneto  + "." + cAlsneto  + "_VLRTOT  TOTALBRUTO "  //valor total bruto
        cSelect += ", " + cAlsneto  + "." + cAlsneto  + "_VLRCP   TRIBUTO "     //valor contribuicao
        cSelect += ", " + cAlsneto  + "." + cAlsneto  + "_VLRRET  VALORRETIDO " //valor retido
    
	elseIf AllTrim( cLayout ) $ 'R-4010' .and. lAnalitc
		cSelect += " , " + cAliasLay + "." + cAliasLay + "_CPF CPF" 			// cpf
		cSelect += " , " + cAliasLay + "." + cAliasLay + "_NOME NOME" 			// nome
		cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRBRU) BRUTO" 	// Valor bruto tot	al
		cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRTRI) BASE"   	// Valor total tributavel		
		cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRIR) VALOR"    // Valor total de IR		

	elseIf AllTrim( cLayout ) $ 'R-4020' .and. lAnalitc
		cSelect += " , " + cAliasLay + "." + cAliasLay + "_CNPJBN CNPJ" 				// Cnpj beneficiario
		cSelect += " , " + cAliasLay + "." + cAliasLay + "_NMBENE NOME" 				// nome beneficiario
		cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRTOT) BRUTO" 			// Valor bruto tot
		cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_BASEIR) BASE"   			// Valor total tributavel		
		cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRIR) VALOR"   			// Valor total de IR				
		cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VLCSLL) VLRCSLL"		// Valor total de CSLL				
		cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VCOFIN) VLRCOF"   	// Valor total de COFINS
		cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRPP) VLRPP"   		// Valor total de PP				
		cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VAGREG) VAGREG"		// Valor Agregado

    elseIf AllTrim( cLayout ) $ 'R-4040' .and. lAnalitc
		cSelect += " , " + cAliasLay + "." + cAliasLay + "_NRINSC NUMINSC"   // Numero de Inscrição
		cSelect += " , " + cAliasLay + "." + cAliasLay + "_DESTA NOME"   // Nome estabelecimento
		cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRLIQ) VLRLIQUI" // Valor liquido
		cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_BASEIR) BASEIR" // Valor base de IR
		cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRIR) VLRIR"   // Valor total de IR

    elseIf AllTrim( cLayout ) $ 'R-4080' .and. lAnalitc		
		cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NRINSF NUMINSF"     // Numero de Inscrição da Fonte Pagadora
		cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_DPARTI NOME"        // Nome da Fonte Pagadora
		cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRBRU) VLRBRU" // Valor Bruto
		cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_BASEIR) BASEIR" // Valor base de IR
		cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRIR) VLRIR"   // Valor total de IR	

    elseIf AllTrim( cLayout ) $ "R-9000"
        cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_FILIAL  FILIAL "    // filial
        cSelect += " ,  " + cAlsfilho + "." + cAlsfilho + "_CODIGO  EVTGER "    // Evento
    endif

    //FROM
    cFrom += RetSqlName( cAliasLay ) + " " + cAliasLay + " "

    //LEFT JOIN
    if AllTrim( cLayout ) $ "R-1070"
        cFrom += " LEFT JOIN " +  RetSqlName( cAlsfilho  ) + " " + cAlsfilho  + " ON "
        cFrom += cAlsfilho + "." + cAlsfilho + "_ID = " + cAliasLay + "." + cAliasLay + "_IDMUNI "
        cFrom += " AND " + cAlsfilho + ".D_E_L_E_T_ = ' ' "
    elseif AllTrim( cLayout ) $ "R-2030|R-2040|R-2055"
        cFrom += " INNER JOIN " +  RetSqlName( cAlsfilho  ) + " " + cAlsfilho  + " ON "
        cFrom += cAlsfilho + "." + cAlsfilho + "_FILIAL = " + cAliasLay + "." + cAliasLay + "_FILIAL "
        cFrom += " AND " + cAlsfilho + "." + cAlsfilho + "_ID = " + cAliasLay + "." + cAliasLay + "_ID "
        cFrom += " AND " + cAlsfilho + "." + cAlsfilho + "_VERSAO =" + cAliasLay + "." + cAliasLay + "_VERSAO "
        cFrom += " AND " + cAlsfilho + ".D_E_L_E_T_ = ' ' "
        if alltrim( cLayout ) == 'R-2055'
            cFrom += " INNER JOIN " + RetSqlName('C1E') + " C1E ON C1E.C1E_ID = " + cAliasLay + "." + cAliasLay + "_IDESTA AND C1E.C1E_ATIVO = '1' AND C1E.D_E_L_E_T_ = ' ' "
            cFrom += " INNER JOIN " + RetSqlName('C1H') + " C1H ON "
            If cCompC1H == "EEE"
                cFrom += " C1H.C1H_FILIAL = C1E.C1E_FILTAF "
            Else
                If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
                    If cBd $ "ORACLE|POSTGRES|DB2"
                        cFrom += " SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTR(C1E.C1E_FILTAF,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
                    ElseIf cBd $ "INFORMIX"
                        cFrom += " C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] = C1E.C1E_FILTAF[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] "
                    Else
                        cFrom += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C1E.C1E_FILTAF,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
                    EndIf
                ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
                    If cBd $ "ORACLE|POSTGRES|DB2"
                        cFrom += " SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTR(C1E.C1E_FILTAF,1," + cValToChar(aInfoEUF[1]) + ") "
                    ElseIf cBd $ "INFORMIX"
                        cFrom += " C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1]) + "] = C1E.C1E_FILTAF[1," + cValToChar(aInfoEUF[1]) + "] "
                    Else
                        cFrom += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C1E.C1E_FILTAF,1," + cValToChar(aInfoEUF[1]) + ") "
                    EndIf
                Else
                    cFrom += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
                EndIf
            EndIf
            cFrom += " AND C1H.C1H_ID = " + cAliasLay + "." + cAliasLay + "_IDPART "
            cFrom += " AND C1H.D_E_L_E_T_ = ' ' "
        endif
    elseif AllTrim( cLayout ) $ "R-3010"
        cFrom += " LEFT JOIN " + RetSqlName( cAlsfilho ) + " " + cAlsfilho + " ON "
        cFrom += cAlsfilho + "." + cAlsfilho + "_ID =" + cAliasLay + "." + cAliasLay + "_ID "
        cFrom += " AND " + cAlsfilho + ".D_E_L_E_T_ = ' ' "
        cFrom += " LEFT JOIN " + RetSqlName( cAlsneto ) + " " + cAlsneto + " ON "
        cFrom += cAlsneto + "." + cAlsneto + "_ID =" + cAliasLay + "." + cAliasLay + "_ID "
        cFrom += " AND " + cAlsneto + "." + cAlsneto + "_VERSAO =" + cAliasLay + "." + cAliasLay + "_VERSAO "
        cFrom += " AND " + cAlsneto + ".D_E_L_E_T_ = ' ' "
    
	elseif cLayout $ 'R-4010|R-4020|R-4040|R-4080' .and. lAnalitc

		cFrom += "LEFT JOIN " + RetSqlName(cAlsfilho) + " " + cAlsfilho 
		cFrom += 	" ON " + cAlsfilho + "." + cAlsfilho + "_FILIAL = '" + xFilial(cAlsfilho) + "' ""
		cFrom += 	"AND " + cAlsfilho + "." + cAlsfilho + "_ID = " + cAliasLay + "." + cAliasLay + "_ID "
		cFrom += 	"AND " + cAlsfilho + "." + cAlsfilho + "_VERSAO = " + cAliasLay + "." + cAliasLay + "_VERSAO "
		cFrom += 	"AND " + cAlsfilho + ".D_E_L_E_T_ = ' ' "
	
	elseif AllTrim( cLayout ) $ "R-9000"
        cFrom += " LEFT JOIN " + RetSqlName( cAlsfilho ) + " " + cAlsfilho + " ON "
        cFrom += cAlsfilho + "." + cAlsfilho + "_ID =" + cAliasLay + "." + cAliasLay + "_IDTPEV "
        cFrom += " AND " + cAlsfilho + ".D_E_L_E_T_ = ' ' "
    endif

    //WHERE
    if AllTrim( cLayout ) $ "R-1070|R-1050"
        If !lCompart
            cWhere += cAliasLay + "." + cAliasLay + "_FILIAL IN " + cFils
        Else
            cWhere += cAliasLay + "." + cAliasLay + "_FILIAL = '" + cBranch + " '"
        EndIf
    else
        cWhere += cAliasLay + "." + cAliasLay + "_FILIAL = '" + xFilial(cAliasLay) + " '"
    endif

    cWhere += "  AND " + cAliasLay + ".D_E_L_E_T_ = ' ' "
    cWhere += "  AND " + cAliasLay + "." + cAliasLay + "_ATIVO = '1' "

    if !empty(cStatus) .and. cStatus <> "99"
        cWhere += "  AND " + cAliasLay + "." + cAliasLay + "_STATUS = '" + cStatus  + "'"
    endif

    if cStatus == "99"
        cWhere += "  AND " + cAliasLay + "." + cAliasLay + "_STATUS IN ('2','3','4')"
    endif

    if AllTrim( cLayout ) $ "R-1000" .and. !EMPTY(cNrInsc)
        cWhere += " AND " + cAliasLay + "." + cAliasLay + "_NRINSC = '" + cNrInsc + " '"
    endIf

    If AllTrim( cLayout ) $ "R-2010|R-2020|R-2030|R-2040|R-2050|R-2055|R-2060|R-2098|R-2099|R-4010|R-4020|R-4040|R-4080|R-4099|R-9000"
        cWhere += " AND " + cAliasLay + "." + cAliasLay + "_PERAPU = '" + STRTRAN(cPeriodo,"/","") + "'"
    EndIf

    if AllTrim( cLayout ) $ "R-2030|R-2040|R-2055"
        cWhere += " GROUP BY " + cAliasLay + "." + cAliasLay + "_ID "
        cWhere += ", " + cAliasLay + "." + cAliasLay + "_STATUS "
        cWhere += ", " + cAliasLay + "." + cAliasLay + "_PROTUL "
        cWhere += ", " + cAliasLay + ".R_E_C_N_O_ "
        cWhere += ", " + cAliasLay + "." + cAliasLay + "_FILIAL "
        if allTrim(cLayout) != 'R-2055'
            cWhere += ", " + cAliasLay + "." + cAliasLay + "_NRINSC "
        else
            cWhere += ", " + cAliasLay + "." + cAliasLay + "_NRINSP "
            cWhere += ", C1H.C1H_NOME "
        endif        

    endIf

	if alltrim(cLayout) $ 'R-4010|R-4020|R-4040|R-4080' .and. lAnalitc
		cGroupBy += ' group by '
		cGroupBy += cAliasLay + "." + cAliasLay + "_ID, "
		cGroupBy += cAliasLay + "." + cAliasLay + "_STATUS,"
		cGroupBy += cAliasLay + "." + cAliasLay + "_PROTUL, "
		cGroupBy += cAliasLay + "." + "R_E_C_N_O_, "

		if alltrim(cLayout) == 'R-4010'
			cGroupBy += cAliasLay + "." + cAliasLay + "_CPF, "
			cGroupBy += cAliasLay + "." + cAliasLay + "_NOME "
		elseif alltrim(cLayout) == 'R-4020'
			cGroupBy += cAliasLay + "." + cAliasLay + "_CNPJBN , "
			cGroupBy += cAliasLay + "." + cAliasLay + "_NMBENE "		
		elseif alltrim(cLayout) == 'R-4040'
			cGroupBy += cAliasLay + "." + cAliasLay + "_NRINSC, "
			cGroupBy += cAliasLay + "." + cAliasLay + "_DESTA "
		else
			cGroupBy += cAliasLay + "." + cAliasLay + "_NRINSF, "
			cGroupBy += cAliasLay + "." + cAliasLay + "_DPARTI "
		endif	
	endif

    cOrderBy    :=  "RECNO "

    cSelect     :=  "%" +   cSelect     	+   "%"
    cFrom       :=  "%" +   cFrom       	+   "%"
    cWhere      :=  "%" +   cWhere+cGroupBy +   "%"
    cOrderBy    :=  "%" +   cOrderBy    	+   "%"

    BeginSql Alias cAlias
        SELECT DISTINCT
        %Exp:cSelect% 
        FROM 
        %Exp:cFrom%
        WHERE
        %Exp:cWhere%
        ORDER BY 
        %Exp:cOrderBy%
    EndSql

Return(cAlias)

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} detailStatusTransmission
WS para retorno das informações referente ao detalhe das movimentações da base

@author Henrique Fabiano Pateno Pereira
@since 22/05/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET detailStatusTransmission QUERYPARAM companyId, period, event, status, page, pageSize WSREST WSTAF005

Local aEvents		as array
Local aCompany		as array
Local aFieldCB		as array
Local cAliasTmp		as character
Local cStatus		as character
Local cFilName		as character
Local cTpProc		as character
Local cCol5055		as character
Local cTxNumber		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local cCpoTax		as character
Local cCpoDesc		as character
Local nPage			as numeric
Local nPageSize		as numeric
Local nContPage		as numeric
Local nTAnalitc		as numeric
Local lPagination	as logical
Local l1000			as logical
Local l1050			as logical
Local l1070			as logical
Local l20302040		as logical
Local l2050			as logical
Local l2055			as logical
Local l2060			as logical
Local l209X4099		as logical
Local l3010			as logical
Local l4010			as logical
Local l4020			as logical
Local l4040			as logical
Local l4080			as logical
Local l9000			as logical
Local lExecuta		as logical
Local lObra			as logical
Local lRet			as logical
Local oResponse		as object
Local cCode			as character
Local cUser			as character
Local cModule		as character
Local cRoutine		as character

//-----------------------------------------------
// Inicialização variáveis do tipo array
//-----------------------------------------------
aEvents		:=	{}
aCompany	:=	{}
aFieldCB	:=  {}

//-----------------------------------------------
// Inicialização variáveis do tipo caracter
//-----------------------------------------------
cAliasTmp	:=	""
cStatus		:=	""
cFilName	:=	""
cTpProc		:=	""
cCol5055	:=	""
cTxNumber	:=	""
cEmpRequest	:=	""
cFilRequest	:=	""
cCpoTax		:=	''
cCpoDesc	:= 	''
cCode		:= "LS006"
cUser		:= ""
cModule		:= "84"
cRoutine 	:= "TAFReinf"+StrTran(self:event,"-", "")+"BtnAcompanhar"

//-----------------------------------------------
// Inicialização variáveis do tipo numéricas
//-----------------------------------------------
nPage		:=	0
nPageSize	:=	0
nContPage	:=	0
nTAnalitc	:=	0

//-----------------------------------------------
// Inicialização variáveis do tipo booleanas
//-----------------------------------------------
lPagination	:=	.F.
l1000		:=	.F.
l1050		:=	.F.
l1070		:=	.F.
l20302040	:=	.F.
l2050		:=	.F.
l2055		:=	.F.
l2060		:=	.F.
l209X4099	:=	.F.
l3010		:=	.F.
l4010		:= 	.f.
l4020		:= 	.f.
l4040		:= 	.f.
l4080		:= 	.f.
l9000		:=	.F.
lExecuta	:=	.F.
lObra		:=	.F.
lRet		:=	.T.

//-----------------------------------------------
// Inicialização variáveis do tipo object
//-----------------------------------------------
oResponse	:=	JsonObject():New()

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:period == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Período não informado no parâmetro 'period'." ) )
ElseIf self:event == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Evento não informado no parâmetro 'event'." ) )
ElseIf self:status == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Status não informado no parâmetro 'status'." ) )
ElseIf !( self:event $ "R-1000|R-1050|R-1070|R-2010|R-2020|R-2030|R-2040|R-2050|R-2055|R-2060|R-2098|R-2099|R-3010|R-4010|R-4020|R-4040|R-4080|R-4099|R-9000" )
	lRet := .F.
	SetRestFault( 403, EncodeUTF8( "A API não está disponível para o evento informado!" ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			cUser := RetCodUsr()
			aEvents := TAFRotinas( self:event, 4, .F., 5 )

			l1000		:=	self:event == "R-1000"
			l1050		:=	self:event == "R-1050"
			l1070		:=	self:event == "R-1070"
			l20302040	:=	( self:event $ "R-2030|R-2040" )
			l2050		:=	self:event == "R-2050"
			l2055		:=	self:event == "R-2055"
			l2060		:=	self:event == "R-2060"
			l209X4099	:=	( self:event $ "R-2098|R-2099|R-4099" )
			l3010		:=	self:event == "R-3010"
			l9000		:=	self:event == "R-9000"
			l4010		:= 	self:event == "R-4010"
			l4020		:= 	self:event == "R-4020"
			l4040		:= 	self:event == "R-4040"
			l4080		:= 	self:event == "R-4080"
			
			cStatus		:=	TAF005Stat( AllTrim( self:status ) )
			
			nPage		:=	Iif( !Empty( self:page ), self:page, 0 )
			nPageSize	:=	Iif( !Empty( self:pageSize ), self:pageSize, 0 )

			//-------------------------------------------------------------------
			// Executa a query de pesquisa ao evento no monitor
			//-------------------------------------------------------------------
			cAliasTmp := WS005Stat( aEvents, self:period, cStatus, .T., cFilAnt )

			oResponse["eventDetail"]	:=	{}
			oResponse["hasnext"]		:=	.F.

			If nPage > 0 .and. nPageSize > 0
				lPagination := .T.
			Else
				lPagination := .F.
				lExecuta := .T.
			EndIf

			( cAliasTmp )->( DBGoTop() )
			While ( cAliasTmp )->( !Eof() )
				nContPage ++

				If nContPage <= nPageSize .or. !lPagination
					If lPagination
						If ( cAliasTmp )->( Recno() ) >= nPage
							lExecuta := .T.
						Else
							lExecuta := .F.
						EndIf
					EndIf

					If lExecuta
						aAdd( oResponse["eventDetail"], JsonObject():New() )

						nTAnalitc := Len( oResponse["eventDetail"] )

						If l1000
							oResponse["eventDetail"][nTAnalitc]["typeOfInscription"]			:=	Iif( Len( AllTrim( ( cAliasTmp )->CNPJ ) ) == 14, "1 - CNPJ", "2 - CPF" )
							oResponse["eventDetail"][nTAnalitc]["taxNumber"]					:=	SubStr( AllTrim( ( cAliasTmp )->CNPJ ), 1, Len( AllTrim( ( cAliasTmp )->CNPJ ) ) - 6 )
							oResponse["eventDetail"][nTAnalitc]["taxClassification"]			:=	( cAliasTmp )->CLAFIS
							oResponse["eventDetail"][nTAnalitc]["isMandatoryBookkeeping"]		:=	EncodeUTF8( Iif( ( cAliasTmp )->INDESC == "0", "0 - Empresa não obrigada a ECD", "1 - Empresa obrigada a ECD" ) )
							oResponse["eventDetail"][nTAnalitc]["isPayrollExemption"]			:=	EncodeUTF8( Iif( ( cAliasTmp )->INDDES == "0", "0 - Não Aplicável", "1 - Empresa enquadrada nos artigos 7º a 9º da Lei 12.546/2011" ) )
							oResponse["eventDetail"][nTAnalitc]["hasFineExemptionAgreement"]	:=	Iif( ( cAliasTmp )->ISEMUL == "0", "0 - Sem acordo", "1 - Com acordo" )
							oResponse["eventDetail"][nTAnalitc]["beginingDate"]					:=	( cAliasTmp )->INIPER
							oResponse["eventDetail"][nTAnalitc]["finishingdate"]				:=	( cAliasTmp )->FINPER
							oResponse["eventDetail"][nTAnalitc]["contact"]						:=	EncodeUTF8( ( cAliasTmp )->CONTATO )
							oResponse["eventDetail"][nTAnalitc]["contactTaxNumber"]				:=	( cAliasTmp )->CPFCTT
						
						ElseIf l1050
							//Transforma as opcções do combo box do campo em array
							aFieldCB := StrTokArr(GetSx3Cache('V82_TPENTL','X3_CBOX'),';')
							
							oResponse["eventDetail"][nTAnalitc]["cnpj"]	:= ( cAliasTmp )->CNPJ
							oResponse["eventDetail"][nTAnalitc]["tpEntLig"]	:= alltrim(encodeUTF8(aFieldCB[val(( cAliasTmp )->ENTLIG)]))
						
						ElseIf l1070
							If ( cAliasTmp )->TPPROC == "1"
								cTpProc := "Administrativo"
							ElseIf ( cAliasTmp )->TPPROC == "2"
								cTpProc := "Judicial"
							ElseIf ( cAliasTmp )->TPPROC == "3"
								cTpProc := "Número do benefício (NB) do INSS"
							ElseIf ( cAliasTmp )->TPPROC == "4"
								cTpProc := "Processo FAP"
							EndIf

							//Tipo de Processo
							oResponse["eventDetail"][nTAnalitc]["proccesType"] := AllTrim( EncodeUTF8( cTpProc ) )

							//Número do Processo
							oResponse["eventDetail"][nTAnalitc]["proccesNumber"] := ( cAliasTmp )->NUMPROC

							//UF Vara
							oResponse["eventDetail"][nTAnalitc]["courtFederatedUnit"] := AllTrim( EncodeUTF8( ( cAliasTmp )->DESCUFVARA ) )

							//Município
							oResponse["eventDetail"][nTAnalitc]["cityCode"] := ( cAliasTmp )->CODMUN + " - " + AllTrim( EncodeUTF8( ( cAliasTmp )->DESCMUN ) )

							//Código Município
							oResponse["eventDetail"][nTAnalitc]["courtId"] := ( cAliasTmp )->IDMUN

							//Data ini
							oResponse["eventDetail"][nTAnalitc]["beginingDate"] := ( cAliasTmp )->DTINI

							//Data fim
							oResponse["eventDetail"][nTAnalitc]["finishingDate"] := ( cAliasTmp )->DTFIM
						ElseIf l20302040
							//Filial
							oResponse["eventDetail"][nTAnalitc]["company"] := ( cAliasTmp )->FILIAL

							//Número de Inscrição
							oResponse["eventDetail"][nTAnalitc]["branchTaxNumber"] := ( cAliasTmp )->NRINSC

							//Valor Bruto dos Recursos Recebidos
							oResponse["eventDetail"][nTAnalitc]["totalGrossValue"] := ( cAliasTmp )->VLREPA

							//Valor Total da Retenção
							oResponse["eventDetail"][nTAnalitc]["totalReceivedWithHoldAmount"] := ( cAliasTmp )->VLRET

							//Valor Total da Retenção previdênciária com exigibilidade suspensa
							oResponse["eventDetail"][nTAnalitc]["totalValueOfRetentionWithSuspendedLiability"] := ( cAliasTmp )->VLNRET

							//ID do Registro
							oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID
						ElseIf ( l2050 .or. l2055 )
							If l2050
								cCol5055	:=	"sociaSecurityContributionValue"
								cTxNumber	:=	"NRINSC"
								cFilName	:=	WSFindFil( ( cAliasTmp )->&( cTxNumber ) )[17]
							Else
								cCol5055	:=	"contributionValue"
								cTxNumber	:=	"NRINSP"
								cFilName	:=	( cAliasTmp )->C1H_NOME
							EndIf

							//Razão Social
							oResponse["eventDetail"][nTAnalitc]["company"] := EncodeUTF8( AllTrim( cFilName ) )

							//Número da Inscrição
							oResponse["eventDetail"][nTAnalitc]["taxNumber"] := ( cAliasTmp )->&( cTxNumber )

							//Valor da Receita Bruta
							oResponse["eventDetail"][nTAnalitc]["totalGrossValue"] := ( cAliasTmp )->BRUTO

							//Valor da Contribuição Previdenciária
							oResponse["eventDetail"][nTAnalitc][cCol5055] := ( cAliasTmp )->VLRCONTR

							//Valor da Contribuição Previdenciária GILRAT
							oResponse["eventDetail"][nTAnalitc]["sociaSecurityContributionValueGilrat"] := ( cAliasTmp )->GILRAT

							//Valor da Contribuição Previdenciária SENAR
							oResponse["eventDetail"][nTAnalitc]["sociaSecurityContributionValueSenar"] := ( cAliasTmp )->SENAR
						ElseIf l2060
							//Filial
							oResponse["eventDetail"][nTAnalitc]["branch"] := AllTrim( ( cAliasTmp )->FILIAL )

							//Tipo de Inscrição do Estabelecimento
							oResponse["eventDetail"][nTAnalitc]["typeOfInscription"] := ( cAliasTmp )->CTPINSC + Iif( ( cAliasTmp )->CTPINSC == "1", " - CNPJ", " - CNO" )

							//Número de Inscrição do Estabelecimento
							oResponse["eventDetail"][nTAnalitc]["companyTaxNumber"] := AllTrim( ( cAliasTmp )->CNRINSC )

							//Valor da Receita Bruta Total
							oResponse["eventDetail"][nTAnalitc]["totalGrossValue"] := ( cAliasTmp )->VLRECBTT

							//Valor Total da Contribuição Previdenciária sobre a Receita Bruta
							oResponse["eventDetail"][nTAnalitc]["sociaSecurityContributionValue"] := ( cAliasTmp )->VLCPAPUT

							//Valor Total da Contribuição Previdenciária com exigibilidade suspensa
							oResponse["eventDetail"][nTAnalitc]["socialSecurityContributionValueSuspended"] := ( cAliasTmp )->VLCSUSPT
						ElseIf l3010
							//Código da Filial
							oResponse["eventDetail"][nTAnalitc]["branch"] := ( cAliasTmp )->FILIAL

							//Nº do Boletim
							oResponse["eventDetail"][nTAnalitc]["newsletterNumber"] := ( cAliasTmp )->BOLETIM

							//Modalidade
							oResponse["eventDetail"][nTAnalitc]["mode"] := ( cAliasTmp )->MODALIDADE

							//Competição
							oResponse["eventDetail"][nTAnalitc]["competition"] := ( cAliasTmp )->COMPETICAO

							//CNPJ do Mandatário
							oResponse["eventDetail"][nTAnalitc]["taxNumberPrincipal"] := ( cAliasTmp )->CNPJMAND

							//CNPJ do Visitante
							oResponse["eventDetail"][nTAnalitc]["taxNumberVisited"] := ( cAliasTmp )->CNPJVI

							//Quantidade Pagantes
							oResponse["eventDetail"][nTAnalitc]["payingOffValue"] := ( cAliasTmp )->PAGANTES

							//Quantidade não Pagantes
							oResponse["eventDetail"][nTAnalitc]["dontPayingOffValue"] := ( cAliasTmp )->NAOPAGANTES

							//Total Receita Bruta
							oResponse["eventDetail"][nTAnalitc]["grossValue"] := ( cAliasTmp )->TOTALBRUTO

							//Contribuição Previdenciaria
							oResponse["eventDetail"][nTAnalitc]["contributionValue"] := ( cAliasTmp )->TRIBUTO

							//Valor Retido 
							oResponse["eventDetail"][nTAnalitc]["contributionValueSuspended"] := ( cAliasTmp )->VALORRETIDO

						ElseIf l4010
							oResponse["eventDetail"][nTAnalitc]["providerCPF"] 		:= alltrim( (cAliasTmp)->CPF ) //CPF
							oResponse["eventDetail"][nTAnalitc]["providerName"] 	:= alltrim( EncodeUtf8( (cAliasTmp)->NOME ) ) //Descrição Participante C1H
							oResponse["eventDetail"][nTAnalitc]["incomeTaxBase"] 	:= ( cAliasTmp )->BASE //Valor Base de Cálculo Retida
							oResponse["eventDetail"][nTAnalitc]["incomeTaxAmount"] 	:= ( cAliasTmp )->VALOR //Valor Total
							oResponse["eventDetail"][nTAnalitc]["grossAmount"] 		:= ( cAliasTmp )->BRUTO //Valor Total Bruto

						ElseIf l4020
							oResponse["eventDetail"][nTAnalitc]['providerCNPJ']  	:= ( cAliasTmp )->CNPJ 		//cnpj beneficiario
							oResponse["eventDetail"][nTAnalitc]['providerName']  	:= EncodeUTF8(alltrim( (cAliasTmp )->NOME ) ) //nome beneficiario
							oResponse["eventDetail"][nTAnalitc]['grossAmount'] 	 	:= ( cAliasTmp )->BRUTO 	//Valor Bruto
							oResponse["eventDetail"][nTAnalitc]['incomeTaxBase'] 	:= ( cAliasTmp )->BASE 		//Valor Base Ir
							oResponse["eventDetail"][nTAnalitc]['incomeTaxAmount'] 	:= ( cAliasTmp )->VALOR 	//Valor Ir
							oResponse["eventDetail"][nTAnalitc]['pisValue'] 		:= ( cAliasTmp )->VLRPP 	//Valor Pis PASEP
							oResponse["eventDetail"][nTAnalitc]['cofinsValue'] 		:= ( cAliasTmp )->VLRCOF 	//Valor Cofins
							oResponse["eventDetail"][nTAnalitc]['csllValue'] 		:= ( cAliasTmp )->VLRCSLL 	//Valor Csll
							oResponse["eventDetail"][nTAnalitc]['agregValue']		:= ( cAliasTmp )->VAGREG	//Valor Agregado
						
						ElseIf l4040
							oResponse["eventDetail"][nTAnalitc]["numInsc"] 			:= alltrim( (cAliasTmp)->NUMINSC ) 	//Numero de inscricao
							oResponse["eventDetail"][nTAnalitc]["company"] 			:= alltrim( (cAliasTmp)->NOME ) 	//Nome estabelecimento
							oResponse["eventDetail"][nTAnalitc]["irBaseValue"] 		:= ( cAliasTmp )->BASEIR 			// Valor base de ir
							oResponse["eventDetail"][nTAnalitc]["irValue"] 			:= ( cAliasTmp )->VLRIR 			//Valor do Ir
							oResponse["eventDetail"][nTAnalitc]["liquidValue"] 		:= ( cAliasTmp )->VLRLIQUI 			//Valor liquido			

						ElseIf l4080								
							oResponse["eventDetail"][nTAnalitc]['numInsc'] 			:= ( cAliasTmp )->NUMINSF	// Numero de Inscrição da Fonte Pagadora 
							oResponse["eventDetail"][nTAnalitc]['fontName'] 		:= EncodeUTF8(alltrim( ( cAliasTmp )->NOME ) ) 	// Nome da Fonte Pagadora
							oResponse["eventDetail"][nTAnalitc]['grossAmount'] 		:= ( cAliasTmp )->VLRBRU 	// Valor Bruto
 							oResponse["eventDetail"][nTAnalitc]['irBaseValue'] 		:= ( cAliasTmp )->BASEIR 	// Valor base de IR
 							oResponse["eventDetail"][nTAnalitc]['irValue'] 		:= ( cAliasTmp )->VLRIR 	// Valor total de IR
 
						ElseIf l9000
							//Razão Social
							oResponse["eventDetail"][nTAnalitc]["branch"] := ( cAliasTmp )->FILIAL

							//Número da Inscrição
							oResponse["eventDetail"][nTAnalitc]["event"] := ( cAliasTmp )->EVTGER

							//Valor da Receita Bruta
							oResponse["eventDetail"][nTAnalitc]["protocol"] := ( cAliasTmp )->PROTOCOLO
						Else
							If !l209X4099
								
								//Verifica se é 2010, 2020 pega o nome do campo na query
								lObra 	:= !Empty( ( cAliasTmp )->DOBRA )
								cCpoTax := iif(lObra,'CNO','CNPJ')
								cCpoDesc:= iif(lObra,'DOBRA','DPARTI')

								//cTaxNumber
								oResponse["eventDetail"][nTAnalitc]["taxNumber"] := alltrim( (cAliasTmp)->&cCpoTax )

								//Descrição Participante C1H
								oResponse["eventDetail"][nTAnalitc]["company"] := alltrim( EncodeUtf8( (cAliasTmp)->&cCpoDesc ) )

								//Valor Base de Cálculo Retida
								oResponse["eventDetail"][nTAnalitc]["totalTaxBase"] := ( cAliasTmp )->BASE

								//Valor Total
								oResponse["eventDetail"][nTAnalitc]["totalTaxes"] := ( cAliasTmp )->VALOR

								//Valor Total Bruto
								oResponse["eventDetail"][nTAnalitc]["totalGrossValue"] := ( cAliasTmp )->BRUTO
							Else
								oResponse["eventDetail"][nTAnalitc]["taxNumber"] := ""

								//Descrição Participante C1H
								oResponse["eventDetail"][nTAnalitc]["company"] := ""

								//Valor Base de Cálculo Retida
								oResponse["eventDetail"][nTAnalitc]["totalTaxBase"] := ""

								//Valor Total
								oResponse["eventDetail"][nTAnalitc]["totalTaxes"] := ""
							EndIf
						EndIf

						if l1070
							//Se for evento 1070, troco a key, para ficar igual ao wstaf002
							oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->NUMPROC
						else
							oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID
						endif
						

						If ( cAliasTmp )->STATUS == "3" .or. l209X4099
							oResponse["eventDetail"][nTAnalitc]["errorId"] := ( cAliasTmp )->RECNO
						ElseIf ( cAliasTmp )->STATUS == "4"
							oResponse["eventDetail"][nTAnalitc]["protocol"] := AllTrim( ( cAliasTmp )->PROTOCOLO )
						EndIf
					EndIf
				ElseIf lPagination
					oResponse["hasnext"] := .T.
					Exit
				EndIf

				( cAliasTmp )->( DBSkip() )
			EndDo

			( cAliasTmp )->( DBCloseArea() )

			lRet := .T.
			self:SetResponse( oResponse:ToJson() )
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSTAF005
WS para retorno da mensagem de erro de transmissão retornado pelo governo

@author Henrique Fabiano Pateno Pereira
@since 22/05/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET MsErrorGov QUERYPARAM companyId, period, event, errorId WSREST WSTAF005

Local aEvents		as array
Local aCompany		as array
Local aRegRec		as array
Local cResponse		as character
Local cError		as character
Local cWarning		as character
Local cReplace		as character
Local cURL			as character
Local cMsg			as character
Local cXml			as character
Local cCodReinf		as character
Local cIDReinf		as character
Local cUserTk		as character
Local cIDEnt		as character
Local cAmbES		as character
Local cVerSchema	as character
Local cCodigo		as character
Local cTagXml		as character
Local cDescription	as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local cMsgRet		as character
Local cContAdvpr	as character
Local nX			as numeric
Local nTam			as numeric
Local dDataIni		as date
Local dDataFim		as date
Local lRet			as logical
Local oResponse		as object
Local oXmlParser	as object
Local oResult		as object
Local lAutoCT1		as logical
Local lErroToken	as logical
Private aRetProc10	as array

aEvents			:=	{}
aRetProc10		:=	{}
aCompany		:=	{}
aRegRec         :=  {}
cResponse		:=	""
cError			:=	""
cWarning		:=	""
cReplace		:=	""
cURL			:=	""
cMsg			:=	""
cXml			:=	""
cCodReinf		:=	""
cIDReinf		:=	""
cUserTk			:=	""
cIDEnt			:=	""
cAmbES			:=	""
cVerSchema		:=	""
cCodigo			:=	""
cTagXml			:=	""
cDescription	:=	""
cEmpRequest		:=	""
cFilRequest		:=	""
nX				:=	0
nTam			:=	0
dDataIni		:=	Nil
dDataFim		:=	Nil
lRet			:=	.T.
oResponse		:=	JsonObject():New()
oXmlParser		:=	Nil
cMsgRet			:= ""
lErroToken		:= .f.
cContAdvpr		:= self:Getheader( "Content-Advpr" )
lAutoCT1   	    := .F.

if valtype( cContAdvpr ) == 'C' .And. !Empty(cContAdvpr) .And. "OCORRENCIA" $ Upper(cContAdvpr)
	lAutoCT1 := .T.
endif

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:period == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Período não informado no parâmetro 'period'." ) )
ElseIf self:event == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Evento não informado no parâmetro 'event'." ) )
ElseIf self:errorId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Identificador do Erro não informado no parâmetro 'errorId'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			aEvents := TAFRotinas( self:event, 4, .F., 5 )

			dDataIni := CToD( "01/" + SubStr( self:period, 1, 2 ) + "/" + SubStr( self:period,3,4 ) )
			dDataFim := LastDay( CToD( "01/" + SubStr( self:period, 1, 2 ) + "/" + SubStr( self:period, 3, 4 ) ) )

			if lAutoCT1 //Automacao Caso Teste1
				oResult := JSONObject():New()
				oResult["CSTATUS"] := "5"
				oResult["CXMLRETEVEN"] := cContAdvpr
				aadd( aRetProc10, { oResult } )
			else
				//Adiciono Recno no Array, pois TAFProc10TSS espera um Array
				aAdd( aRegRec, self:errorId )

				aRetProc10 := TAFProc10TSS( .T., aEvents, /*cStatus*/, /*aIDTrab*/, /*cRecnos*/, /*lEnd*/, @cMsgRet, /*aFiliais*/, dDataIni, dDataFim, /*lEvtInicial*/, /*lCommit*/, aRegRec, /*cIDEnt*/ )
			endif

			oResponse["errorTransmission"] := {}

			If Type( "aRetProc10[1][1]" ) <> "U"
				If aRetProc10[1][1]:CSTATUS == "5"
					oXmlParser := XmlParser( EncodeUTF8( "<tag>" + aRetProc10[1][1]:CXMLRETEVEN + "</tag>" ), cReplace, @cError, @cWarning )

					If XmlChildEx( oXmlParser:_TAG, "_REGOCORRS" ) <> Nil
						If ValType( oXmlParser:_TAG:_REGOCORRS ) == "A"
							For nX := 1 to Len( oXmlParser:_TAG:_REGOCORRS )
								aAdd( oResponse["errorTransmission"], JsonObject():New() )

								nTam := Len( oResponse["errorTransmission"] )

								oResponse["errorTransmission"][nTam]["code"]   := EncodeUTF8( oXmlParser:_TAG:_REGOCORRS[nX]:_CODRESP:TEXT )
								oResponse["errorTransmission"][nTam]["tagxml"] := " "
								If XmlChildEx( oXmlParser:_TAG:_REGOCORRS[nX], "_LOCALERROAVISO" ) <> Nil
									oResponse["errorTransmission"][nTam]["tagxml"] := EncodeUTF8( oXmlParser:_TAG:_REGOCORRS[nX]:_LOCALERROAVISO:TEXT )
								EndIf
								oResponse["errorTransmission"][nTam]["description"] := EncodeUTF8( oXmlParser:_TAG:_REGOCORRS[nX]:_DSCRESP:TEXT )
							Next nX
						Else //É um objeto
							aAdd( oResponse["errorTransmission"], JsonObject():New() )

							nTam := Len( oResponse["errorTransmission"] )

							oResponse["errorTransmission"][nTam]["code"] :=	EncodeUTF8( oXmlParser:_TAG:_REGOCORRS:_CODRESP:TEXT )
							oResponse["errorTransmission"][nTam]["tagxml"] := " "
							If XmlChildEx( oXmlParser:_TAG:_REGOCORRS, "_LOCALERROAVISO" ) <> Nil
								oResponse["errorTransmission"][nTam]["tagxml"] := EncodeUTF8( oXmlParser:_TAG:_REGOCORRS:_LOCALERROAVISO:TEXT )
							EndIf
							oResponse["errorTransmission"][nTam]["description"] := EncodeUTF8( oXmlParser:_TAG:_REGOCORRS:_DSCRESP:TEXT )
						EndIf
					ElseIf XmlChildEx( oXmlParser:_TAG, "_LOCALERROAVISO" ) <> Nil
						aadd( oResponse["errorTransmission"], JsonObject():New() )

						nTam := Len( oResponse["errorTransmission"] )

						oResponse["errorTransmission"][nTam]["code"]		:=	EncodeUTF8( oXmlParser:_TAG:_CODRESP:TEXT )
						oResponse["errorTransmission"][nTam]["tagxml"] := " "
						If XmlChildEx( oXmlParser:_TAG, "_LOCALERROAVISO" ) <> Nil
							oResponse["errorTransmission"][nTam]["tagxml"] := EncodeUTF8( oXmlParser:_TAG:_LOCALERROAVISO:TEXT )
						EndIf
						oResponse["errorTransmission"][nTam]["description"] := EncodeUTF8( oXmlParser:_TAG:_DSCRESP:TEXT )

					//Para o Evento R-2099 Fechamento, no TSS, existe a possibilidade de ficar com Status 5 ( Evento Rejeitado ),
					//porém, com código de retorno 2-Em Processamento <cdRetorno>2</cdRetorno><descRetorno>EM PROCESSAMENTO</descRetorno>
					//Nesta situação, o botão Enviar Fechamento não deverá aparecer, habilitar apenas o botão Consultar Fechamento.
					ElseIf XmlChildEx( oXmlParser:_TAG, "_REINF" ) <> Nil;
						.and. XmlChildEx( oXmlParser:_TAG:_REINF,"_EVTTOTAL" ) <> Nil;
						.and. XmlChildEx( oXmlParser:_TAG:_REINF:_EVTTOTAL, "_IDERECRETORNO" ) <> Nil;
						.and. XmlChildEx( oXmlParser:_TAG:_REINF:_EVTTOTAL:_IDERECRETORNO,"_IDESTATUS" ) <> Nil;
						.and. XmlChildEx( oXmlParser:_TAG:_REINF:_EVTTOTAL:_IDERECRETORNO:_IDESTATUS, "_CDRETORNO" ) <> Nil;
						.and. XmlChildEx( oXmlParser:_TAG:_REINF:_EVTTOTAL:_IDERECRETORNO:_IDESTATUS, "_DESCRETORNO" )<> Nil

						aAdd( oResponse["errorTransmission"], JsonObject():New() )

						nTam := Len( oResponse["errorTransmission"] )

						cCodigo := EncodeUTF8( oXmlParser:_TAG:_REINF:_EVTTOTAL:_IDERECRETORNO:_IDESTATUS:_CDRETORNO:TEXT )
						cCodigo += Space( 1 )
						cCodigo += EncodeUTF8( oXmlParser:_TAG:_REINF:_EVTTOTAL:_IDERECRETORNO:_IDESTATUS:_DESCRETORNO:TEXT )

						oResponse["errorTransmission"][nTam]["code"] := cCodigo

						cTagXml := EncodeUTF8( oXmlParser:_TAG:_REINF:_EVTTOTAL:_IDERECRETORNO:_IDESTATUS:_CDRETORNO:REALNAME )
						cTagXml += Space( 1 )
						cTagXml += EncodeUTF8( oXmlParser:_TAG:_REINF:_EVTTOTAL:_IDERECRETORNO:_IDESTATUS:_DESCRETORNO:REALNAME )

						oResponse["errorTransmission"][nTam]["tagxml"] := cTagXml

						cDescription := EncodeUTF8( "Aguarde o processamento da Receita.")
						cDescription += Chr( 13 ) + Chr( 10 )
						cDescription += EncodeUTF8( "Consulte novamente em alguns instantes." )

						If aRetProc10[1][1]:CXMLRETEVEN <> Nil .and. ValType( aRetProc10[1][1]:CXMLRETEVEN ) == "C"
							cDescription += Chr( 13 ) + Chr( 10 )
							cDescription += EncodeUTF8( aRetProc10[1][1]:CXMLRETEVEN )
						EndIf

						oResponse["errorTransmission"][nTam]["description"] := cDescription

					//Tratamento Generico caso nao exista _REGOCORRS porem exista _OCORRENCIAS, ex: MS0092 Versao de Lote Invalida.
					ElseIf XmlChildEx( oXmlParser:_TAG, "_REGOCORRS" ) == Nil .And. XmlChildEx( oXmlParser:_TAG, "_OCORRENCIAS" ) <> Nil

						aAdd( oResponse["errorTransmission"], JsonObject():New() )
						nTam := Len( oResponse["errorTransmission"] )

						cCodigo := ''
						if XmlChildEx( oXmlParser:_TAG:_OCORRENCIAS:_CODIGO, "TEXT" ) <> Nil
							cCodigo := EncodeUTF8( Alltrim(oXmlParser:_TAG:_OCORRENCIAS:_CODIGO:TEXT) )
						endif
						oResponse["errorTransmission"][nTam]["code"] := cCodigo

						cTagXml := ''
						if XmlChildEx( oXmlParser:_TAG:_OCORRENCIAS, "REALNAME" ) <> Nil
							cTagXml += EncodeUTF8( Alltrim(oXmlParser:_TAG:_OCORRENCIAS:REALNAME) )
						endif
						oResponse["errorTransmission"][nTam]["tagxml"] := cTagXml

						cDescription := ''						
						if XmlChildEx( oXmlParser:_TAG:_OCORRENCIAS:_DESCRICAO, "TEXT" ) <> Nil
							cDescription += EncodeUTF8( Alltrim(oXmlParser:_TAG:_OCORRENCIAS:_DESCRICAO:TEXT) )
						EndIf
						oResponse["errorTransmission"][nTam]["description"] := cDescription
					ElseIf XmlChildEx( oXmlParser:_TAG, "_REGOCORRS" ) == Nil .And. XmlChildEx( oXmlParser:_TAG, "_OCORRENCIA" ) <> Nil

						aAdd( oResponse["errorTransmission"], JsonObject():New() )
						nTam := Len( oResponse["errorTransmission"] )

						cCodigo := ''
						if XmlChildEx( oXmlParser:_TAG:_OCORRENCIA:_CODIGO, "TEXT" ) <> Nil
							cCodigo := EncodeUTF8( Alltrim(oXmlParser:_TAG:_OCORRENCIA:_CODIGO:TEXT) )
						endif
						oResponse["errorTransmission"][nTam]["code"] := cCodigo

						cTagXml := ''
						if XmlChildEx( oXmlParser:_TAG:_OCORRENCIA, "REALNAME" ) <> Nil
							cTagXml += EncodeUTF8( Alltrim(oXmlParser:_TAG:_OCORRENCIA:REALNAME) )
						endif
						oResponse["errorTransmission"][nTam]["tagxml"] := cTagXml

						cDescription := ''						
						if XmlChildEx( oXmlParser:_TAG:_OCORRENCIA:_DESCRICAO, "TEXT" ) <> Nil
							cDescription += EncodeUTF8( Alltrim(oXmlParser:_TAG:_OCORRENCIA:_DESCRICAO:TEXT) )
						EndIf
						oResponse["errorTransmission"][nTam]["description"] := cDescription	
					EndIf
				ElseIf aRetProc10[1][1]:CSTATUS == "3" .or. aRetProc10[1][1]:CSTATUS == "1"
					If T0X->( MSSeek( xFilial( "T0X" ) + aRetProc10[1][1]:CID ) ) //TAFSeekT0X( aRetProc10[1][1]:CID )
						If T0X->T0X_TPERRO = "S" .and. aRetProc10[1][1]:CSTATUS == "3"
							aAdd( oResponse["errorTransmission"], JsonObject():New() )

							nTam := Len( oResponse["errorTransmission"] )

							oResponse["errorTransmission"][nTam]["code"]		:=	EncodeUTF8( "Erro de Schema" )
							oResponse["errorTransmission"][nTam]["tagxml"]		:=	""
							oResponse["errorTransmission"][nTam]["description"]	:=	EncodeUTF8( T0X->T0X_DCERRO )
						Else
							If T0X->T0X_TPERRO = "P" .and. aRetProc10[1][1]:CSTATUS == "1"
								aAdd( oResponse["errorTransmission"], JsonObject():New() )

								nTam := Len( oResponse["errorTransmission"] )

								oResponse["errorTransmission"][nTam]["code"]		:=	EncodeUTF8( "Erro de Predecessão" )
								oResponse["errorTransmission"][nTam]["tagxml"]		:=	""
								oResponse["errorTransmission"][nTam]["description"]	:=	EncodeUTF8( T0X->T0X_PREDEC )
							Else
								aAdd( oResponse["errorTransmission"], JsonObject():New() )

								nTam := Len( oResponse["errorTransmission"] )

								oResponse["errorTransmission"][nTam]["code"]		:=	EncodeUTF8( "Não há Inconsistências para este registro." )
								oResponse["errorTransmission"][nTam]["tagxml"]		:=	EncodeUTF8( "Não há Inconsistências para este registro." )
								oResponse["errorTransmission"][nTam]["description"]	:=	EncodeUTF8( "Não há Inconsistências para este registro." )
							EndIf
						EndIf
					EndIf
				EndIf

				//Mensagem com erro genérico, após a transmissão, há casos que o xmlRetEven ainda consta nulo.
				//Tratamento para não apresentar o log vazio no PO UI, caso não exista log gravado na tabela T0X.
				If ValType( oResponse ) == "J" .and. Len( aRetProc10 ) > 0 .and. Len( oResponse["errorTransmission"] ) == 0 .and. ( AllTrim( cResponse ) == '{"errorTransmission":[]}' .or. Empty( cResponse ) )
					cURL := GetMV( "MV_TAFSURL" )

					If !Empty( AllTrim( cURL ) ) .and. !( "TSSWSREINF.APW" $ Upper( cURL ) )
						cURL += "/TSSWSREINF.apw"
					EndIf

					cXml		:=	aRetProc10[1][1]:CXMLEVENTO
					cCodReinf	:=	Upper( AllTrim( aRetProc10[1][1]:CCODEVENTO ) )
					cIDReinf	:=	aRetProc10[1][1]:CID
					cUserTk		:=	"TOTVS"
					cIDEnt		:=	TAFRIDEnt( ,,,,, .T. )
					cAmbES		:=	aRetProc10[1][1]:CAMBIENTE
					cVerSchema	:=	AllTrim( aRetProc10[1][1]:CVERSAO )
					cMsg		+=	TAFValSche( cXml, cCodReinf, cIDReinf, cURL, cUserTk, cIDEnt, cAmbES, cVerSchema )

					aadd( oResponse["errorTransmission"], JsonObject():New() )

					nTam := Len( oResponse["errorTransmission"] )

					oResponse["errorTransmission"][nTam]["code"]		:=	EncodeUTF8( "Erro" )
					oResponse["errorTransmission"][nTam]["tagxml"]		:=	EncodeUTF8( "Não consta retorno do xml enviado ( xmlRetEven regOcorrs nulo )." )
					oResponse["errorTransmission"][nTam]["description"]	:=	EncodeUTF8( "Não houve retorno da receita. Consulte a estrutura do xml enviado. " + cMsg )
				EndIf

				lRet := .T.
				cResponse := oResponse:ToJSON()
				self:SetResponse( cResponse )
			Else
				//Guardo msg de retorno do webservice
				cCodFault := GetWscError(2)
				
				TAFVldTokenTSS(@cMsgRet, @lErroToken,cCodFault,.t.)

				aadd( oResponse["errorTransmission"], JsonObject():New() )
				nTam := Len( oResponse["errorTransmission"] )
				oResponse["errorTransmission"][nTam]["code"]		:=	EncodeUTF8( IIF(lErroToken,"tokenTSS", "Erro") )
				oResponse["errorTransmission"][nTam]["tagxml"]		:=	EncodeUTF8( "Erro Conexão TSS" )
				oResponse["errorTransmission"][nTam]["description"]	:=	EncodeUTF8( cMsgRet )
				
				lRet := .T.
				cResponse := oResponse:ToJSON()
				self:SetResponse( cResponse )
				
			EndIf
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} monitoring 
WS para monitoramento ao TSS dos eventos transmistidos

@author Henrique Fabiano Pateno Pereira
@since 28/05/2019
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET monitoring QUERYPARAM companyId, period, event WSREST WSTAF005

Local aRegRec		as array
Local aEvents		as array
Local aCompany		as array
Local cAliasTmp		as character
Local cResponse		as character
Local cMsgRet		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local dDataIni		as date
Local dDataFim		as date
Local lRet			as logical
Local oResponse		as object
local lErroToken	as logical
Local cCode			as character
Local cUser			as character
Local cModule		as character
Local cRoutine		as character
Local cRetFb2040	as character
Local cRetRb2040	as character

Private aRetProc10	as array

//-----------------------------------------------
// Inicialização variáveis do tipo array
//-----------------------------------------------
aRegRec		:=	{}
aEvents		:=	{}
aRetProc10	:=	{}
aCompany	:=	{}

//-----------------------------------------------
// Inicialização variáveis do tipo caracter 
//-----------------------------------------------
cAliasTmp		:=	""
cResponse		:=	""
cMsgRet			:=	""
cEmpRequest		:=	""
cFilRequest		:=	""
cCode			:= "LS006"
cUser			:= ""
cModule			:= "84"
cRoutine 		:= ""
cRetFb2040		:= "TAFReinfRetFechBlc"+SubStr(self:event,3,2)
cRetRb2040	    := "TAFReinfRetReabBlc"+SubStr(self:event,3,2)

//-----------------------------------------------
// Inicialização variáveis do tipo data
//-----------------------------------------------
dDataIni	:=	Nil
dDataFim	:=	Nil

//-----------------------------------------------
// Inicialização variáveis do tipo booleano
//-----------------------------------------------
lRet		:= .T.
lErroToken	:= .f.	

//-----------------------------------------------
// Inicialização variáveis do tipo object
//-----------------------------------------------
oResponse	:=	JsonObject():New()

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:period == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Período não informado no parâmetro 'period'." ) )
ElseIf self:event == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Evento não informado no parâmetro 'event'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )

			cUser := RetCodUsr()

			If FindFunction( "FWLSPutAsyncInfo" )
				If self:event $ "R-2099|R-4099"
					cRoutine := cRetFb2040
				ElseIf self:event == "R-2098"						
					cRoutine := cRetRb2040
				Endif
				FWLSPutAsyncInfo( cCode, cUser, cModule, cRoutine )
				TAFConOut( "-> " +cRoutine,1,.F.,"LSTAF")
			EndIf

			aEvents := TAFRotinas( self:event, 4, .F., 5 )

			dDataIni := CToD( "01/" + SubStr( self:period, 1, 2 ) + "/" + SubStr( self:period, 3, 4 ) )
			dDataFim := LastDay( CToD( "01/" + SubStr( self:period, 1, 2 ) + "/" + SubStr( self:period, 3, 4 ) ) )
			
			if self:event $ 'R-2098|R-2099|R-4099'
				cAliasTmp := WS005Stat( aEvents, self:period,,, cFilAnt )
			else
				cAliasTmp := WS005Stat( aEvents, self:period, "2",, cFilAnt )
			endif

			aRegRec := WSTAFRecno( cAliasTmp )

			( cAliasTmp )->( DBCloseArea() )

			aRetProc10 := TAFProc10TSS( .F., aEvents, /*cStatus*/, /*aIDTrab*/, /*cRecnos*/, /*lEnd*/, @cMsgRet, /*aFiliais*/, dDataIni, dDataFim, /*lEvtInicial*/, /*lCommit*/, aRegRec, /*cIDEnt*/ )

			oResponse["success"] := .T.

			If Type( "aRetProc10[1][1]" ) <> "U"
				If "EVENTO AUTORIZADO" $ Upper( AllTrim( aRetProc10[1][1]:CDETSTATUS ) )
					oResponse["success"]	:=	.T.
					oResponse["message"]	:=	AllTrim( aRetProc10[1][1]:CDETSTATUS )
					oResponse["protocol"]	:=	AllTrim( aRetProc10[1][1]:CRECIBO )
				ElseIf "AGUARDANDO" $ Upper( AllTrim( aRetProc10[1][1]:CDETSTATUS ) )
					oResponse["success"]	:=	.F.
					oResponse["message"]	:=	AllTrim( aRetProc10[1][1]:CDETSTATUS )
					oResponse["protocol"]	:=	AllTrim( aRetProc10[1][1]:CRECIBO )
				ElseIf "RECEBIDO" $ Upper( AllTrim( aRetProc10[1][1]:CDETSTATUS ) )
					oResponse["success"]	:=	.F.
					oResponse["message"]	:=	AllTrim( aRetProc10[1][1]:CDETSTATUS )
					oResponse["protocol"]	:=	AllTrim( aRetProc10[1][1]:CRECIBO )
				Else
					oResponse["success"]	:=	.F.
					oResponse["message"]	:=	AllTrim( aRetProc10[1][1]:CDETSTATUS )
					oResponse["protocol"]	:=	AllTrim( aRetProc10[1][1]:CRECIBO )
					oResponse["errorid"]	:=	aRegRec[1]
				EndIf
			ElseIf !Empty( cMsgRet )
				oResponse["success"]	:=	.F.
				oResponse["message"]	:=	EncodeUTF8( cMsgRet )
				oResponse["protocol"]	:=	""
			Else
				cCodFault := GetWscError(2)
				TAFVldTokenTSS(@cMsgRet, @lErroToken,cCodFault,.t.)
				
				if lErroToken
					//Troco msg da função TAFVldTokenTSS pois o poNotication não trabalha legal com quebras de linhas e mensagens grandes
					cMsgRet := "Autenticação obrigatório TAF X TSS - Token TSS não informado ou inválido"
					
					oResponse["success"]	:=	.F.
					oResponse["message"]	:=	EncodeUTF8( cMsgRet )
					oResponse["protocol"]	:=	""
				else
					oResponse["success"]	:=	.F.
					oResponse["message"]	:=	EncodeUTF8( "Evento não encontrado na base para os parâmetros enviados." )
					oResponse["protocol"]	:=	""
				Endif

			EndIf

			lRet := .T.
			cResponse := oResponse:ToJson()
			self:SetResponse( cResponse )
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} taf005Stat 
Converte a palavra para o status necessário

@author Henrique Fabiano Pateno Pereira 
@since 28/05/2019
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
static function taf005Stat(cSatus)
    Local cRet := ''
    do case
    case upper(cSatus) == upper("waitingReturn")
        cRet    :=  '2'
    case upper(cSatus) == upper("rejected")
        cRet    :=  '3'
    case  upper(cSatus) == upper("authorized")
        cRet    :=  '4'
    case  upper(cSatus) == upper("transmitted")
        cRet    :=  '99'
    endcase

return(cRet)
