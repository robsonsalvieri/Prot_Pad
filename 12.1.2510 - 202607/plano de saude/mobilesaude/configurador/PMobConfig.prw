#INCLUDE 'protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobConfig

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Class PMobConfig

	Data oSettings

	Method New() constructor
	Method LoadSettings()
	Method LoadFeactureList()
	Method GetSettings()

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Method New() class PMobConfig

	// Carrega as configurações ao iniciazar o objeto.
	self:oSettings := self:LoadSettings()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetSettings

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Method GetSettings() class PMobConfig
Return(self:oSettings)


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadSettings

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Method LoadSettings() class PMobConfig

	Local oObj     := jSonObject():New()
	Local lCase018 := IsInCallStack('PLSMob_018')
	Local cFase := AllTrim(GetNewPar("MV_PLSPEXT","3,4"))

	BA0->(DbSetOrder(1))
	BA0->(DbSeek(xFilial("BA0")+PlsIntPad()))

	// Configurações de login
	oObj['login'] := jSonObject():New()
	oObj['login']['loginBswKey']	:= iif(BA0->BA0_MSTLOG=='2','MAT','CPF')
	oObj['login']['multiContract'] 	:= iif(BA0->BA0_MSMULT=='1',.T.,.F.)
	oObj['login']['useCache']		:= iif(BA0->BA0_MSCACH=='1' .Or. lCase018,.T.,.F.) //Caso de Teste 18 utiliza cache habilitado
	oObj['login']['accessPortal']   := BA0->BA0_MSACES
	oObj['login']['accessPerfil']   := BA0->BA0_MSPERF
	oObj['login']['timeToExpireCache'] := 1

	oObj['beneficiary'] := jSonObject():New()
	oObj['beneficiary']['typeUsrTitular'] := GetNewPar("MV_PLCDTIT","T")
	oObj['beneficiary']['typeUsrConjuge'] := iif(Empty(BA0->BA0_MSCONJ),'03',BA0->BA0_MSCONJ)
	
	oObj['appFeactures'] := self:LoadFeactureList():GetJsonObject('feactures')

	oObj['security'] := jSonObject():New()
	oObj['security']['timeToExpires'] := 1
	oObj['security']['pdfUrl']        := Lower(Alltrim(BA0->BA0_MSPDFU))

	oObj['businessRules'] := jSonObject():New()
	oObj['businessRules']['useContactFromTitular'] := iif(BA0->BA0_MSCONT=='1',.T.,.F.)
	oObj['businessRules']['useAdressFromTitular']  := iif(BA0->BA0_MSEND =='1',.T.,.F.)

	oObj['financeiro'] := jSonObject():New()
	oObj['financeiro']['prefixosIn'] 	:= GetNewPar("MV_PLPFE11","'PLS'")
	oObj['financeiro']['prefixosNotIn'] := ""
	oObj['financeiro']['tiposIn'] 		:= ""
	oObj['financeiro']['tiposNotIn'] 	:= "'PR', 'RA'"
	oObj['financeiro']['exibePagos'] 	:= iif(BA0->BA0_MSTPAG =='1',.T.,.F.)
	oObj['financeiro']['pdfMode']       := BA0->BA0_MSPDFM //1-URL 2-Base 64
	
	// Configurações do extrato de utilização 
	oObj['utilizacao'] := jSonObject():New()
	oObj['utilizacao']['imprimeDependentes'] := iif(BA0->BA0_MSDEPE=='1',.T.,.F.)
	oObj['utilizacao']['faseIn']             := cFase
	oObj['utilizacao']['excluiPagBloq']      := iif(BA0->BA0_MSEXPB=='1',.T.,.F.)
	
	If BA0->(FieldPos("BA0_MSOCVL")) > 0
		oObj['utilizacao']['ocultaVlr'] := iif(BA0->BA0_MSOCVL=='1',.T.,.F.)
	Else 
		oObj['utilizacao']['ocultaVlr'] := .F.
	EndIf

	// Configurações do Extrato de Autorizações/Reembolso
	oObj['extrato'] := JsonObject():New()
	oObj['extrato']['numberMonthsGuia'] := IIf(BA0->(FieldPos("BA0_MSGUIA")) > 0, BA0->BA0_MSGUIA, 12)
	oObj['extrato']['urlDocuments'] := IIf(BA0->(FieldPos("BA0_MSURDO")) > 0, Lower(Alltrim(BA0->BA0_MSURDO)), "")

	// Configurações das Declarações
	oObj['declaracoes'] := JsonObject():New()
	oObj['declaracoes']['yearListDec'] := IIf(BA0->(FieldPos("BA0_MSDECL")) > 0, BA0->BA0_MSDECL, 3)
	oObj['declaracoes']['activeDeclaration'] := IIf(BA0->(FieldPos("BA0_MSDECD")) > 0, BA0->BA0_MSDECD, "0")

	// Configurações da Atualização cadastral
	oObj['atualizacaoCadastral'] := JsonObject():New()
	oObj['atualizacaoCadastral']['endpointStatus'] := IIf(BA0->(FieldPos("BA0_MSURST")) > 0, BA0->BA0_MSURST, "") 
	
Return(oObj)


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadFeactureList

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Method LoadFeactureList() class PMobConfig

	Local oFeactures :=  jSonObject():New()
	Local nLen := 0
	Local cSql := ""

	// Inicializa a lista
	oFeactures['feactures'] := {}

	cSql := " SELECT B7X_CODIGO, B7X_DESCRI, B7X_ATIVO, B7X_OCULTO, B7X_MSGBLO "
	cSql += " FROM "+RetSqlName("B7X")
	cSql += " WHERE B7X_FILIAL = '"+xFilial("B7X")+"' "
	cSql += " AND B7X_CODOPE = '"+PlsIntPad()+"' "
	cSql += " AND B7X_ATIVO = '1' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB1",.F.,.T.)

	While !TRB1->( Eof() )

		Aadd(oFeactures['feactures'], jSonObject():New())
		nLen := Len(oFeactures['feactures'])
		oFeactures['feactures',nLen,'cod']	 := Alltrim(TRB1->B7X_CODIGO)
		oFeactures['feactures',nLen,'name']	 := Alltrim(TRB1->B7X_DESCRI)
		oFeactures['feactures',nLen,'acesso']	 := TRB1->B7X_ATIVO
		oFeactures['feactures',nLen,'ocultar'] := TRB1->B7X_OCULTO
		oFeactures['feactures',nLen,'mensagemBloqueio'] := Alltrim(TRB1->B7X_MSGBLO)
		
		TRB1->( dbSkip() )
	Enddo

	TRB1->( dbCloseArea() )

Return(oFeactures)
