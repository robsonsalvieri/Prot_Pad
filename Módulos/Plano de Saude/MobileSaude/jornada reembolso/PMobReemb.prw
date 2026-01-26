#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc}  PMobReemb
	Classe com dados pertinentes a gravação do Reembloso integranção PLS X MOBILE SAUDE

	@type class
	@author Robson Nayland
	@since 17/08/2020
/*/

Class PMobReemb
    //Data lExitProc   AS Logical
//    Data aRecScheB6J AS Array Init {}


    Method new() Constructor
	Method ValidReembo()
	Method ValidaBenef()
	Method ValidaPrest()
	Method IncProcedim()
    Method Gerareembo()     // Criando Modelo de Reembolso

   	Method destroy()

EndClass



Method new() Class PMobReemb


Return self


/*/{Protheus.doc} LoadBowMVC
	Methodo que carrega o reembolso em modo MVC para gravação
	
	@type method
	@author Robson Nayland
	@since 17/09/2021
	@version 1.0
/*/

Method ValidReembo(oReemb,aDadUsr,aDadRda,aItens) Class PMobReemb


	// Validando Beneficiario
	If !self:ValidaBenef(oReemb:matricula_beneficiario,@aDadUsr)
		ReTurn(.F.)
	Endif

	// Validando Prestador(nesse caso é prestado padrão)
	If !self:ValidaPrest(@aDadRda)
		ReTurn(.F.)
	Endif


	// Incluindo procedimento padrão
	If !self:IncProcedim(oReemb,@aItens)
		ReTurn(.F.)
	Endif


Return(.T.)


/*/{Protheus.doc} Gerareembo
	Methodo que grava reembolso
	
	@type method
	@author Robson Nayland
	@since 17/09/2021
	@version 1.0
/*/

Method Gerareembo(aDadUsr,aDadRda,aItens,cProtocolo) Class PMobReemb
	Local i 		:= 0
	Local nVlrApres := 0

	For i:=1 to Len(aItens)
		nVlrApres+=aItens[i,3]
	Next i

	RecLock("BOW", .T.)
		BOW->BOW_FILIAL := xFilial("BOW")
		BOW->BOW_PROTOC := cProtocolo
		BOW->BOW_TIPPAC := getNewPar("MV_PLSTPAA","05")
		BOW->BOW_STATUS := "0"
		BOW->BOW_USUARI := aDadUsr[2]
		aCliente := PLSAVERNIV(	BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,IF(BA3->BA3_TIPOUS=="1","F","J"),;
									BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,nil,BA1->BA1_TIPREG,.F.)
		If aCliente[1,1] <> "ZZZZZZ"
			BOW->BOW_CODCLI	:= aCliente[1][1]
			BOW->BOW_LOJA  	:= aCliente[1][2]
			BOW->BOW_NOMCLI	:= aCliente[1][3]
		EndIf
		BOW->BOW_TIPUSR := "99"
		BOW->BOW_VIACAR := BA1->BA1_VIACAR
		BOW->BOW_NOMUSR := BA1->BA1_NOMUSR
		BOW->BOW_CODEMP := BA3->BA3_CODEMP
		BOW->BOW_MATRIC := BA3->BA3_MATRIC
		BOW->BOW_TIPREG := BA1->BA1_TIPREG
		BOW->BOW_DIGITO := BA1->BA1_DIGITO
		BOW->BOW_MATUSA := "1"
		BOW->BOW_DTDIGI := dDataBase
		BOW->BOW_OPERDA := BA1->BA1_CODINT
		BOW->BOW_CONEMP := BA3->BA3_CONEMP
		BOW->BOW_VERCON := BA3->BA3_VERCON
		BOW->BOW_SUBCON := BA3->BA3_SUBCON
		BOW->BOW_VERSUB := BA3->BA3_VERSUB
		BOW->BOW_TELCON := BA1->BA1_TELEFO

		BOW->BOW_OPESOL := BA1->BA1_CODINT
		BOW->BOW_OPEUSR := BA1->BA1_CODINT
		BOW->BOW_ESTSOL := GETMV("MV_PLSESPD")
		BOW->BOW_OPEEXE := BA1->BA1_CODINT
		BOW->BOW_SIGLA  := GETMV("MV_PLSIGLA")
		BOW->BOW_ESTEXE := GETMV("MV_PLSESPD")
		BOW->BOW_VLRAPR := nVlrApres
		//BOW->BOW_CDOPER := ::UserCode
		//BOW->BOW_NOMOPE := Posicione("BSW",5,xFilial("BSW")+::UserCode,"BSW_NOMUSR")
		BOW->BOW_CODRDA := BAU->BAU_CODIGO
		BOW->BOW_NOMRDA := BAU->BAU_NOME
		BOW->BOW_TIPPRE := BAU->BAU_TIPPRE
		
		BB0->( DbSetOrder(1) ) //BB0_FILIAL + BB0_CODIGO
		BB0->( MsSeek( xFilial("BB0")+BAU->BAU_CODBB0 ) )
		If BB0->(Found())
			BOW->BOW_REGEXE := BB0->BB0_NUMCR
			BOW->BOW_NOMEXE := BB0->BB0_NOME
			BOW->BOW_CDPFRE := BB0->BB0_CODIGO
		EndIf
		BOW->BOW_CODESP := aDadRDA[15]
		BOW->BOW_DESESP := aDadRDA[17]
		BOW->BOW_LOCATE := aDadRDA[18]
		BOW->BOW_ENDLOC := aDadRDA[20]
		BOW->BOW_OPEMOV := PLSINTPAD()
		BOW->BOW_EMPMOV := cNumEmp
		BOW->BOW_PGMTO := "Em Análise"

	BOW->(MsUnlock())


	// Gravando Itens
	For i:=1 to Len(aItens)

		B1N->(RecLock("B1N", .T.))
		B1N->B1N_FILIAL := xFilial("B1N")
		B1N->B1N_PROTOC := cProtocolo
		B1N->B1N_CODPAD := aItens[i,1]
		B1N->B1N_CODPRO := aItens[i,2]
		B1N->B1N_VLRAPR := aItens[i,3]
		//B1N->B1N_CODREF := oItens:LISTDESP[nI]:CODRDA
		//B1N->B1N_NOMREF := cNomRef
		B1N->B1N_USOCON := "0" //*
		B1N->B1N_TIPDOC := aItens[i,4]
		B1N->B1N_NUMDOC := aItens[i,4]
		B1N->B1N_DATDOC := aItens[i,5]
		B1N->B1N_SEQUEN := StrZero(i,3)
		B1N->B1N_QTDPRO := 1
		B1N->B1N_QTDMED := 1
		B1N->B1N_PROORI := aItens[i,2]
		B1N->B1N_EST	:= BAU->BAU_EST
		B1N->B1N_CODMUN := BAU->BAU_MUN
		B1N->B1N_DESMUN := Posicione("BID",1,xFilial("BID")+BAU->BAU_MUN,"BID_DESCRI")
		B1N->B1N_MATRIC := aDadUsr[2]
		B1N->B1N_IMGSTA := "ENABLE"

		B1N->B1N_PRCNPJ := aDadRDA[16]
		B1N->B1N_PRNOME := aDadRDA[7]
		B1N->B1N_CODREF := ""
		B1N->B1N_NOMREF := ""

		B1N->B1N_DATPRO := aItens[i,5]
		B1N->(MsUnlock())
	Next i
	


Return()


/*/{Protheus.doc} ValidaBenef
	Methodo para validar os beneficiario de reembolso
	
	@type method
	@author Robson Nayland
	@since 17/09/2021.
	@version 1.0
/*/

Method ValidaBenef(cMatric,aDadUsr) Class PMobReemb
	Local lRet 		:= .T.

	aDadUsr	:= PLSDADUSR(cMatric,"1",.F.,dDataBase)
	If !aDadUsr[1]
		Return(.F.)
	Endif'

Return(lRet)


/*/{Protheus.doc} ValidaPrest
	Methodo para validar o prestador
	
	@type method
	@author Robson Nayland
	@since 17/09/2021
	@version 1.0
/*/

Method ValidaPrest(aDadRda) Class PMobReemb
	Local lRet 		:= .T.
	
	aDadRda	:= PLSDADRDA(PlsIntPad(),GetNewPar("MV_PLSRDAG","999999"),"1",dDatabase)
	If !aDadRda[1]
		Return(.F.)
	Endif'

Return(lRet)

/*/{Protheus.doc} IncProcedim
	Methodo para incluir os itens de reembolso
	
	@type method
	@author Robson Nayland
	@since 17/09/2021
	@version 1.0
/*/

Method IncProcedim(oReemb,aItens) Class PMobReemb

	Local lRet 	:= .T.
	Local nItens:=0

	For nItens := 1 to Len(oReemb:Despesas)

		AaDd(aItens,{Subs(AllTrim(GetMv("MV_PLSCDCO")),1,2),Subs(AllTrim(GetMv("MV_PLSCDCO")),3,16),Val(oReemb:Despesas[nItens]['valor_despsa']),oReemb:Despesas[nItens]['prestador_documento'],sTod(strtran(oReemb:Despesas[nItens]['data_despesa'],'-',''))})

	Next nItens

Return(lRet)










Method destroy() Class PMobReemb
Return