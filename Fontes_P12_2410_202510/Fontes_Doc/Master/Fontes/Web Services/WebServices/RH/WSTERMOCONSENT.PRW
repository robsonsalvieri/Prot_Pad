#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "WSTERMOCONSENT.CH"

WSSTRUCT TCurrentTerm
	WSDATA Code			AS String
	WSDATA DirTermo		AS String	OPTIONAL
	WSDATA FilePath		AS String	OPTIONAL
ENDWSSTRUCT

WSSTRUCT TAcceptResp
	WSDATA Accept		AS Boolean
	WSDATA CodRDG		AS String
ENDWSSTRUCT

WSSERVICE TERMOCONSENT DESCRIPTION STR0003	//Métodos relacionados aos termos e aceites de consentimento do Portal

	WSDATA Accept		AS Boolean
	WSDATA UserID		AS String
	WSDATA CPF			AS String
	WSDATA CurrentTerm	AS TCurrentTerm
	WSDATA Origin		AS String
	WSDATA LRETORNO		AS BOOLEAN
	WSDATA AcceptResp	AS TAcceptResp

	WSMETHOD PutAceite			DESCRIPTION STR0002	//Método de inclusao do aceite do consentimento
	WSMETHOD GetCandidate		DESCRIPTION STR0004	//Método para checar SQG a partir do cpf de login
	WSMETHOD GetCurrentTerm		DESCRIPTION STR0005	//Método para checar existência de modelo de consentimento vigente
	WSMETHOD GetCurrentAccept	DESCRIPTION STR0006	//Método para checar histórico de aceite
	WSMETHOD GetMinorAccept		DESCRIPTION STR0011	//Método para checar aceite do responsável pelo menor de idade
ENDWSSERVICE

WSMETHOD PutAceite WSRECEIVE CurrentTerm, Origin, UserID WSSEND LRETORNO WSSERVICE TERMOCONSENT
	Local lRet		:= .F.
	Local cUserID	:= PadR( ::UserID, GetSx3Cache("RI3_USER","X3_TAMANHO") )

	::LRETORNO := .F.
	If ChkFile("RI2") .And. ChkFile("RI3") .And. !Empty(::CurrentTerm:Code)
		Begin Transaction
			DbSelectArea("RI3")
			RI3->( DbSetOrder(1) )	//RI3_FILIAL+RI3_ORIGEM+RI3_USER+RI3_CODVER
			If !RI3->(DbSeek(xFilial("RI3") + ::Origin + cUserID + ::CurrentTerm:Code))
				Reclock("RI3",.T.)
					RI3->RI3_FILIAL	:= xFilial("RI3")
					RI3->RI3_CODVER	:= ::CurrentTerm:Code
					RI3->RI3_DATA	:= dDatabase
					RI3->RI3_HORA	:= VAL(StrTran(Substr(time(),1,5),":","."))
					RI3->RI3_ORIGEM	:= ::Origin
					RI3->RI3_USER	:= ::UserID
				RI3->(MsUnlock())

				DbSelectArea("SQG")
				SQG->( DbSetOrder(1) )
				If SQG->(ColumnPos("QG_ACEITE")) > 0 .And. SQG->(DbSeek(::UserID))
					Reclock("SQG",.F.)
					SQG->QG_ACEITE := "2"
					SQG->(MsUnlock())
					::LRETORNO := .T.
					lRet := .T.
				Else
					SetSoapFault(STR0002, STR0009)	//"Registro do candidato não atualizado"
					DisarmTransaction()
				EndIf
			else
				SetSoapFault(STR0002, STR0010)	//"Aceite do modelo vigente já consentido pelo usuário"
				DisarmTransaction()
			EndIf
		End Transaction
	else
		SetSoapFault(STR0002, STR0001)	//"Inconsistencia na base de dados - tabelas RI2/RI3 inexistentes"
	EndIf

return lRet

WSMETHOD GetCandidate WSRECEIVE CPF WSSEND UserID WSSERVICE TERMOCONSENT
	Local lret			:= .F.
	Local aAreaSQG		:= SQG->(GetArea())

	Default Self:CPF	:= ""

	::UserID := ''

	DbSelectArea("SQG")
	SQG->( DbSetOrder(3) )
	If !Empty(::CPF) .And. SQG->( DbSeek( xFilial("SQG") + ::CPF ))
		::UserID := SQG->QG_FILIAL + SQG->QG_CURRIC
		lret := .T.
	else
		SetSoapFault(STR0004, STR0007)	//'Candidato não encontrado.'
	EndIf
	RestArea(aAreaSQG)

return lRet

WSMETHOD GetCurrentTerm WSRECEIVE NULLPARAM WSSEND CurrentTerm WSSERVICE TERMOCONSENT
	Local lRet		:= .F.
	Local aVigente	:= fTCVigente()
	Local cFile		:= ""
	Local cExten	:= ""

	Local aIniSessions := GetIniSessions(GetADV97())
	Local cJobs	:= ''
	Local cPesqWeb := ''
	Local nT := 0
	Local cNewDir		:= GetMv("MV_DIRTERM", .T., '')

	IF EMPTY(cNewDir)
		//cenario em que o cliente esteja usando o parametro antigo MV_DIRTERM 

		//o parametro MV_DIRCONS sera utilizado APENAS para ambiente ERP e PORTAL no MESMO appserver.ini)
		For nT:=1 To Len(aIniSessions)
			cJobs := GetPvProfString( aIniSessions[nt] , "DEFAULTPAGE", '', GetADV97() )
			if alltrim(upper(cJobs)) == alltrim(upper("w_pwsr001.apw")) //portal do candidato
				cPesqWeb:= GetPvProfString( aIniSessions[nt] , "PATH", '', GetADV97() )
				if !empty(cPesqWeb)
					Exit
				Endif
			Endif
		Next

		cPesqWeb := StrTran( cPesqWeb, AllTrim(GetSrvProfString ("RootPath", "")), "" )
		cPesqWeb := StrTran( cPesqWeb, "\web", "" )
		cPesqWeb := StrTran( cPesqWeb, "\", "/" )
		cPesqWeb += SuperGetMV("MV_DIRCONS",.F.,"")
	ELSE
		cPesqWeb := StrTran( cNewDir, "\", "/" )
		cPesqWeb := StrTran( cPesqWeb, "/web", "" )
	ENDIF

	::CurrentTerm := WSClassNew("TCurrentTerm")
	Self:CurrentTerm:DirTermo := cPesqWeb

	If LEN(aVigente) > 0
		SplitPath( aVigente[2], , , @cFile, @cExten )
		Self:CurrentTerm:Code		:= aVigente[1]
		Self:CurrentTerm:FilePath	:= cFile + cExten 
		lRet := .T.
	Else
		SetSoapFault(STR0005,STR0008)	//'Não há termo de consentimento vigente.'
	EndIf

Return lRet


WSMETHOD GetCurrentAccept WSRECEIVE CurrentTerm, Origin, UserID WSSEND Accept WSSERVICE TERMOCONSENT
    Local lRet      := .T.
    Local aArea     := GetArea()
    Local cUserID   := ""

    ::Accept := .T.

    If ChkFile("RI2") .And. ChkFile("RI3") .And. !Empty(::CurrentTerm)
        cUserID := PadR( ::UserID, GetSx3Cache("RI3_USER","X3_TAMANHO") )
        DbSelectArea("RI3")
        RI3->( dbSetOrder(1) )
        If !RI3->( dbSeek( xFilial("RI3") + ::Origin + cUserID + ::CurrentTerm:Code ) )
            ::Accept := .F.
        EndIf
        RI3->( dbCloseArea() )
    EndIf

    RestArea(aArea)

Return lRet

WSMETHOD GetMinorAccept WSRECEIVE UserID WSSEND AcceptResp WSSERVICE TERMOCONSENT
	Local lret		:= .T.
	Local aAreaSQG	:= SQG->(GetArea())

	::AcceptResp := WSClassNew("TAcceptResp")
	::AcceptResp:Accept := .T.
	::AcceptResp:CodRDG := SuperGetMv("MV_MENORMB",.F.,"")

	DbSelectArea("SQG")
	SQG->( DbSetOrder(1) )
	If  SQG->(ColumnPos("QG_ACTRSP")) > 0 .And. SQG->( DbSeek( ::UserID ))
		::AcceptResp:Accept := SQG->QG_ACTRSP == '2'
	EndIf
	RestArea(aAreaSQG)

return lRet
