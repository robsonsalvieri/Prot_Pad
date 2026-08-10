#include "totvs.ch"
#include "protheus.ch"
#include "commsgexprot.ch"

/*/{Protheus.doc} ComEndRot
	Apresenta tela informando que a rotina será descontinuada
	@type  Function
	@author Squad SUPRIMENTOS
	@since 10/01/2025
	@version 1.0
	@param cExpirFunc, caracter, nome da rotina que deve ser descontinuada
	@param cDescrFunc, caracter, descrição da rotina e nome da rotina que substitui a rotina descontinuada
	@param cLimiteData, caracter, data de experiração a ser informada deve estar no formato AAAAMMDD
	@param cEndWeb, caracter, endereço http referente a rotina que esta sendo descontinuada
	@param cLimRelease, caracter, informe a partir de qual release a rotina será descontinuada
/*/
Function ComEndRot(cExpirFunc as character, cDescrFunc as character, cEndWeb as character, cLimRelease as character, cLimiteData as character, cExpiraData as character, cNewFunc as character, nPauseDays as numeric)

Local dDate      as date
Local oProfile   as object
Local aLoad      as array
Local cShow      as character
Local lCheck     as logical
Local lRotinExp	 as logical

default cDescrFunc	:= ""
default cNewFunc	:= ""			// Nome da nova rotina/função substituta
default cLimiteData := "20220404"   // Data de expiração da rotina
default cLimRelease	:= "ALL"		// Se não fornecido o release, a rotina será descontinuada para todos os releases.
default nPauseDays  := 7			// Número de dias que pode ser desabilitada a mensagem

	dDate		:= Date()
	lRotinExp	:= dDate > SToD(cExpiraData)
	
	oProfile := FwProFile():New()
	oProfile:SetTask("GCTExpired")	// Nome da sesso
	oProfile:SetType(cExpirFunc)	// Valor
	
	aLoad := oProfile:Load()
	
	If Empty(aLoad) .or. lRotinExp
		cShow := "00000000"
	Else
		cShow := aLoad[1]
	Endif

	// Reseta o controle de nPauseDays dias e volta apresentar a tela de advertencia
	If cShow <> "00000000" .And. SToD(cShow) + nPauseDays <= dDate
		cShow := "00000000"
		oProfile:SetProfile({cShow})
		oProfile:Save()
	ENDIF

	If cShow == "00000000"
		lCheck := DlgEndRot(cLimiteData, cLimRelease, cExpiraData, nPauseDays, cDescrFunc, cNewFunc, cEndWeb)

		If lCheck
			cShow := DToS(Date())
			oProfile:SetProfile({cShow})
			oProfile:Save()
		EndIf

	EndIf

	oProfile:Destroy()
	oProfile := nil
	aLoad := aSize(aLoad,0)
	aLoad := nil

Return

/*/{Protheus.doc} DlgEndRot
	Apresenta tela informando que a rotina será descontinuada
	@type  Function
	@author Squad SUPRIMENTOS
	@since 10/01/2025
	@version 1.0
	@param cLimiteData, caracter, data de experiração a ser informada deve estar no formato AAAAMMDD
	@param nPauseDays, numeric, numero de dias que a mensagem pode ser ocultada
	@param cDescrFunc, caracter, descricão da rotina e nome da rotina que substitui a rotina descontinuada
	@param cEndWeb, caracter, endereço http referente a rotina que esta sendo descontinuada
	@return lCheck, logico, Verdadeiro se foi escolhido para desabilitar a mensagem por 07 dias
/*/
Static Function DlgEndRot(cLimiteData as character, cLimRelease as character, cExpiraData as character, nPauseDays as numeric, cDescrFunc as character, cNewFunc as character, cEndWeb as character)

Local oSay1		as object
Local oSay2		as object
Local oSay3		as object
Local oSay4		as object
Local oCheck1	as object
Local oModal	as object
Local cMsg1		as character
Local cMsg2		as character
Local cMsg3		as character
Local cMsg4		as character
Local cSTR1		as character
Local cSTR2		as character
Local lCheck	as logical
Local lManutExp	as logical
Local lRotinExp	as logical

	oModal := FWDialogModal():New()
	oModal:SetCloseButton( .F. )
	oModal:SetEscClose( .F. )
	oModal:SetTitle(STR0001) //"Comunicado Ciclo de Vida de Sofware - TOTVS Linha Protheus"

	//Define a altura e largura da janela em pixel
	oModal:setSize(180, 250)

	oModal:createDialog()

	oModal:AddButton( STR0002, {||oModal:DeActivate()}, STR0002, , .T., .F., .T., )	// "Fechar"

	oContainer := TPanel():New( ,,, oModal:getPanelMain() )
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	lManutExp := Date() > SToD(cLimiteData)
	lRotinExp := Date() > SToD(cExpiraData)

	// O Aviso ocorrerá quando a data do dia não ultrapassa a data da manutenção, sem bloquear o uso do fonte
	if !(lRotinExp) .and. !(lManutExp)
		cSTR1 := STR0003 + DToC(SToD(cLimiteData)) + ". "								// "Esta rotina será descontinuada e terá sua manutenção encerrada em "
		cSTR1 += STR0004 + iif(!(cLimRelease == 'ALL'), STR0005 + cLimRelease, STR0006) // "Sua utilização será bloqueada " # "a partir da release " # "para todas as releases."
		cSTR2 := iif(!empty(cNewFunc), STR0008 + cNewFunc + STR0010, "")				// "A rotina que a substiurá é a " # ", já disponível em nosso produto."
	
	// O Aviso ocorrerá quando a data do dia ultrapassa a data da manutenção, sem bloquear o uso do fonte
	elseif !(lRotinExp) .and. lManutExp
		cSTR1 := STR0003 + DToC(SToD(cLimiteData)) + ". "																	// "Esta rotina foi descontinuada e teve sua manutenção encerrada em "
		cSTR1 += STR0016 + DToC(SToD(cExpiraData)) + ", " + iif(!(cLimRelease == 'ALL'), STR0005 + cLimRelease, STR0006)	// "Sua utilização será bloqueada a partir de " # "a partir da release " # "para todas as releases."
		cSTR2 := iif(!empty(cNewFunc), STR0008 + cNewFunc + STR0010, "")													// "A rotina que a substiurá é a " # ", já disponível em nosso produto."

	// O Aviso e bloqueio do fonte ocorrerá quando a data do dia ultrapassa a data da manutenção e data da expiração do fonte
	elseif lRotinExp .and. lManutExp
		cSTR1 := STR0007 + DToC(SToD(cExpiraData)) + ". "									// "Esta rotina foi descontinuada e sua manutenção foi encerrada em "
		cSTR1 += STR0004 + iif(!(cLimRelease == 'ALL'), STR0005 + cLimRelease, STR0006) 	// "Sua utilização será bloqueada " # "a partir da release " # "para todas as releases."
		cSTR2 := iif(!empty(cNewFunc), STR0009 + cNewFunc + STR0010, "")					// "A rotina que a substituiu é a " # ", já disponível em nosso produto."
	
	endif

	cMsg1 := i18n(cSTR1,{DToC(SToD(cExpiraData))})
	cMsg2 := i18n(cSTR2, {cNewFunc} )
	cMsg3 := STR0011	// "Para conhecer mais sobre a convergência entre essas rotinas, "
	cMsg4 := STR0012	// "Para maiores informações, favor contatar o administrador do sistema ou seu ESN TOTVS.")

	oSay1 := TSay():New( 10,10,{||cMsg1 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
	oSay2 := TSay():New( 30,10,{||cMsg2 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

	If !Empty(cEndWeb)
		cMsg3 += "<b><a target='_blank' href='"+cEndWeb+"'> "
		cMsg3 += STR0013 // "clique aqui"
		cMsg3 += " </a></b>."
		cMsg3 += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"
		oSay3 := TSay():New(50,10,{||cMsg3},oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
		oSay3:bLClicked := {|| MsgRun( STR0014, "URL",{|| ShellExecute("open",cEndWeb,"","",1) } ) } // "Abrindo o link, aguarde.."
	EndIf
	oSay4 := TSay():New( 70,10,{||cMsg4 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

	if !(lRotinExp)
		lCheck := .F.
		oCheck1 := TCheckBox():New(100,10,i18n(STR0015,{strzero(nPauseDays,2)}) ,{|x|If(Pcount()==0,lCheck,lCheck:=x)},oContainer,220,21,,,,,,,,.T.,,,) // "Não apresentar esta mensagem nos proximos [07] dias."
	endif

	oModal:Activate()

Return lCheck

/*/{Protheus.doc} DCLMSGINT()
	Apresenta mensagem de descontinuidade da integracao com DCL a partir da 12.1.2510
	@type  Function
	@author Marcos.RPires
	@since 01/09/2025
	@return lRet, logical, Indica se prossegue com a integracao com o DCL
	/*/
Function DCLMSGINT(nPauseDays as numeric)

Local dDate      as date
Local oProfile   as object
Local aLoad      as array
Local cShow      as character
Local lCheck     as logical

Local cRelease		:= GetRpoRelease()
Local lNewIntDCL	:= SuperGetMv("MV_DCLNEW",.F.,.F.)

If Type("lMsgRepeat") = "U"
    Private lMsgRepeat := .T.
EndIf

// numero de dias que pode ser desabilitada a mensagem
DEFAULT nPauseDays := 7

If lNewIntDCL .And. cRelease >= "12.1.2410" .And. lMsgRepeat
    
	//Não repete a mensagem mais de uma vez neste acesso desta rotina
	lMsgRepeat := .F. 
    
	dDate := Date()
    
	oProfile := FwProFile():New()
    oProfile:SetTask(AllTrim(ProcName())) //Nome da sessao

    aLoad := oProfile:Load()
    If Empty(aLoad)
        cShow := "00000000"
    Else
        cShow := aLoad[1]
    Endif

    //Reseta o controle de nPauseDays dias e volta apresentar a tela de advertencia
    If cShow <> "00000000" .And. STOD(cShow) + nPauseDays <= dDate
        cShow := "00000000"
        oProfile:SetProfile({cShow})
        oProfile:Save()
    Endif

    If cShow == "00000000"
        lCheck := DlgDCLInt(nPauseDays)

        If lCheck
            cShow := dtos(date())	
            oProfile:SetProfile({cShow})
            oProfile:Save()
        EndIf
    EndIf

    oProfile:Destroy()
	FreeObj(oProfile)
	FwFreeArray(aLoad)
    
EndIf

Return

/*/{Protheus.doc} DlgDCLInt
	Apresenta uma tela informando que a rotina sera descontinuada
	@type  Function
	@author 
	@since 
	@version 1.0
	@param nPauseDays, numeric, numero de dias que a mensagem pode ser ocultada
	@return lCheck, logico, Verdadeiro se foi escolhido para desabilitar a mensagem por 3O dias
/*/
Static Function DlgDCLInt(nPauseDays as numeric)

Local oSay1    as object
Local oSay2    as object
Local oCheck1  as object
Local oModal   as object
Local cMsg1    as character
Local cMsg2    as character
Local lCheck   as logical

oModal := FWDialogModal():New()
oModal:SetCloseButton( .F. )
oModal:SetEscClose( .F. )
oModal:setTitle(STR0001) //"Comunicado Ciclo de Vida de Sofware - TOTVS Linha Protheus"

//define a altura e largura da janela em pixel
oModal:setSize(140, 250)

oModal:createDialog()

oModal:AddButton( STR0002, {||oModal:DeActivate()}, STR0002, , .T., .F., .T., )	// "Fechar"

oContainer := TPanel():New( ,,, oModal:getPanelMain() )
oContainer:Align := CONTROL_ALIGN_ALLCLIENT

cMsg1 := STR0017 //"O parâmetro MV_DCLNEW está ativo, porém a integração com o módulo Distribuição de Combustíveis e Lubrificantes - DCL passou por uma reestruturação a partir do release 12.1.2510." 

cMsg2 := STR0018 //"Por favor, entre em contato com o administrador do sistema para mais informações."

oSay1 := TSay():New( 10,10,{||cMsg1 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

oSay2 := TSay():New( 40,10,{||cMsg2 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

lCheck := .F.
oCheck1 := TCheckBox():New(60,10,i18n(STR0015,{strzero(nPauseDays,2)}) ,{|x|If(Pcount()==0,lCheck,lCheck:=x)},oContainer,220,21,,,,,,,,.T.,,,) // "Não apresentar esta mensagem nos proximos [07] dias."

oModal:Activate()

Return lCheck
