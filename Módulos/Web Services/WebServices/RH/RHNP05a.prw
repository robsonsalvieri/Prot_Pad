#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"

#INCLUDE "RHNP.CH"

Function RHNP05a()
Return .T.


/*/{Protheus.doc} fPermission
Retorna o permissionamento do MeuRH
@author:    Marcelo Faria
@since:     12/05/2020
@param:		cBranchVld - Filial do Token;
@param:		cLogin - Login do Token;
@param:		cRD0Cod - Login do participante (RD0);
@param:		cService - Nome do serviço que está sendo avaliado;
@param:		lHabil - Indica se o servico está ou nao habilitado;
@return:    Array de Serviços;
/*/
Function fPermission(cBranchVld, cLogin, cRD0Cod, cService, lHabil)
Local aArea         := {}
Local aServices     := {}
Local cFilAI3       := ""
Local cPortal       := ""

Default cBranchVld	:= ""
Default cLogin      := ""
Default cRD0Cod     := ""
Default cService    := ""
Default lHabil      := .F.

If !Empty(cBranchVld)
    aArea := GetArea()
    
    dbSelectArea("RD0")
    RD0->(dbSetOrder(10))
    If RD0->(dbSeek( FWxFilial("RD0", cBranchVld)+ Padr(UPPER(AllTrim(cLogin)),TamSx3("RD0_LOGIN")[1])))
        cPortal := RD0->RD0_PORTAL
    Else
        RD0->( dbSetOrder(1) )
        If RD0->(dbSeek( FWxFilial("RD0", cBranchVld) + UPPER(AllTrim(cRD0Cod))) )
            cPortal := RD0->RD0_PORTAL
        EndIf
    EndIf

    If AliasInDic("RJD") .And. !Empty( cPortal )
        cFilAI3 := Iif( FWModeAccess("AI3") == "C", FwxFilial("AI3", cBranchVld), cBranchVld )
        RJD->( DbGoTop() )
        RJD->(dbSetOrder(1))
        If RJD->(dbSeek(FWxFilial("RJD", cBranchVld) + cPortal))
            While RJD->( !Eof() .And. RJD->RJD_FILIAL == cFilAI3 .And. RJD->RJD_CODUSU == cPortal ) 

                If Empty(cService) 
                    Aadd(aServices,{ AllTrim(RJD->RJD_WS), RJD->RJD_HABIL, AllTrim(RJD->RJD_GRUPO), AllTrim(RJD->RJD_DESC) })
                ElseIf AllTrim(RJD->RJD_WS) == AllTrim(cService) 
                    Aadd(aServices,{ AllTrim(RJD->RJD_WS), RJD->RJD_HABIL, AllTrim(RJD->RJD_GRUPO), AllTrim(RJD->RJD_DESC) })
                    lHabil := RJD->RJD_HABIL == "1"
                    exit
                EndIf

                RJD->(DbSkip())
            EndDo
        EndIf
    EndIf

    If Empty( aServices ) .and. Empty( cService )	
        aServices := TCFA006SRV( .T. )
    EndIf


    RestArea(aArea)
EndIf

Return aServices


// ---------------------------------------------------
// - FUNCIONALIDADES DIVERSAS DO SERVIÇO de CONTEXTO.
// ---------------------------------------------------
/*/{Protheus.doc}getMultV()
- Prepara os dados para o caregamento de múltiplos vínculos do usuário.
@author:	Marcelo Faria
/*/
Function getMultV(cBranchVld,cMatSRA,cLogin,aDadosCtx,aItemCtx,lContext)

Local nI            := 0
Local aInfo         := {}
Local aRet          := {}
Local aDadosFunc    := {}
Local aArea         := GetArea()
Local oItemData     := JsonObject():New()

Default cBranchVld  := FwCodFil()
Default cMatSRA     := ""
Default cLogin      := ""
DEFAULT aDadosCtx   := {}
DEFAULT aItemCtx    := {}


//Busca todas as matrículas do usuário logado
//MatParticiant() com parametro MeuRH, para validar login também pelo RD0_CIC
If lContext .and. MatParticipant(cLogin, @aRet, .T., .T.)

    For nI := 1 to len(aRet)

        //busca dados passando filial e matrícula. Não adiciona matrículas transferidas.
        If !( aRet[nI,10] $ "30/31" ) .And. fGetFunc(aRet[nI,3], aRet[nI,1], @aDadosFunc)

            oItemData                 :=  JsonObject():New()
            oItemData["employeeType"] := "internal"

            //descrição do departamento
            oItemData["branchName"]   := alltrim(EncodeUTF8(fDesc('SQB',aDadosFunc[1,2],'SQB->QB_DESCRIC',,aRet[nI,3],1)))

            //dados do funcionário para autenticação (Filial+Mat+Codigo)
            oItemData["employeeID"]   := aRet[nI,3] + "|" + aRet[nI,1] + "|" + aDadosFunc[1,5]

            //verifica situação atual
            If aRet[nI,9] == "D"
               oItemData["status"]    := "inactive"
            Else
               oItemData["status"]    := "active"
            EndIf

            //identifica qual a matrícula corrente do funcionário
            //If nI == 1
            If alltrim(aRet[nI,1]) == cMatSRA
                oItemData["current"]  := .T.
            Else
                oItemData["current"]  := .F.
            EndIf

            If !fInfo(@aInfo, aRet[nI,3])
                oItemData["companyName"] := ""
            Else
                //descrição da filial/empresa
                oItemData["companyName"] := alltrim(aInfo[1]) +'/' +alltrim(aInfo[2])
            EndIf

            //carrega matrícula localizada
            Aadd(aDadosCtx,oItemData)
        Endif

    Next
Else

    //Carrega apenas o contexto da matrícula atual
    If fGetFunc(cBranchVld, cMatSRA, @aDadosFunc)

        SRA->(dbSetOrder(1))
        SRA->(dbSeek(cBranchVld+cMatSRA))

        oItemData                 :=  JsonObject():New()
        oItemData["employeeType"] := "internal"

        //descrição do departamento
        oItemData["branchName"]   := EncodeUTF8(fDesc('SQB',aDadosFunc[1,2],'SQB->QB_DESCRIC',,,1))

        //dados do funcionário para autenticação (Filial+Mat+Codigo)
        oItemData["employeeID"]   := cBranchVld + "|" + cMatSRA + "|" + aDadosFunc[1,5]

        //verifica situação atual
        If SRA->RA_SITFOLH == "D" .And. SRA->RA_RESCRAI $ '30/31'
           oItemData["status"]    := "inactive"
        Else
           oItemData["status"]    := "active"
        EndIf

        //identifica qual a matrícula corrente do funcionário
        oItemData["current"]  := .T.

        If !fInfo(@aInfo,cBranchVld)
            oItemData["companyName"] := ""
        Else
           //descrição da filial/empresa
           oItemData["companyName"] := alltrim(aInfo[1]) +'/' +alltrim(aInfo[2])
        EndIf

        //carrega matrícula localizada
        Aadd(aItemCtx,oItemData["employeeID"])
        Aadd(aItemCtx,oItemData["branchName"])
        Aadd(aItemCtx,oItemData["companyName"])

        //carrega matrícula localizada
        Aadd(aDadosCtx,oItemData)
    Endif
EndIf
RestArea(aArea)
FreeObj(oItemData)

Return(Nil)


/*/{Protheus.doc}resultSetContext()
- Prepara o json para retorno de atualização do contextocontext
@author:    Marcelo Faria
/*/

Function resultSetContext(aItemCtx,lSet)

Local cRet      := ""
Local cMsg      := ""
Local nCode     := 200
Local aMessage  := {}
Local oItem     := JsonObject():New()
Local oItemData := JsonObject():New()
Local oMessage  := JsonObject():New()

DEFAULT aItemCtx := {}
DEFAULT lSet     := .F.

If len(aItemCtx) > 0

    oItemData["employeeType"]   := "internal"
    oItemData["status"]         := "active"
    oItemData["employeeID"]     := aItemCtx[1]
    oItemData["branchName"]     := AllTrim(aItemCtx[2])
    oItemData["companyName"]    := AllTrim(aItemCtx[3])
    oItemData["current"]        := .T. 
    
    oMessage["code"]            := Nil
    oMessage["type"]            := "success"
    oMessage["detail"]          := OemToAnsi(STR0103) //"Contexto alterado com sucesso!"
    aAdd( aMessage, oMessage )

Else

    nCode := 204

    If lSet
        //PUT Context
        cMsg := EncodeUTF8(STR0088) //"Não foi possível atualizar o contexto!"
    Else
        //Get Context
        cMsg := EncodeUTF8(STR0089) //"Não foi possível buscar o contexto!"
    Endif

    oItemData["employeeType"]   := ""
    oItemData["status"]         := ""
    oItemData["employeeID"]     := ""
    oItemData["branchName"]     := ""
    oItemData["companyName"]    := ""
    oItemData["current"]        := .F. 

    oMessage["code"]            := 204
    oMessage["type"]            := "error"
    oMessage["detail"]          := cMsg
    aAdd( aMessage, oMessage )

Endif

oItem["data"] 	        := oItemData
oItem["length"]	        := 1
oItem["messages"]	    := aMessage
oItem["HttpStatusCode"]	:= nCode

cRet := oItem:ToJson()

FREEOBJ( oItem )
FREEOBJ( oItemData )
FREEOBJ( oMessage )

Return(cRet)

/*/{Protheus.doc} fGetTeamManager
- Responsável por indicar se uma determinada matricula é responsável por algum departamento

@author:	Marcelo Silveira
@since:		28/02/2018
@param:		cFilTeam = Filial que sera pesquisada a estrutura hierarquica;
			cMatTeam = Matricula que sera pesquisada a estrutura hierarquica;
			aEmpFunc = Retorna as empresas abrangidas pelo funcionario conforme sua estrutura hierarquica
			cRoutine = Rotina do WS do Portal para localizar a visão que sera avaliada
			cOrgCFG = Valor do parametro MV_ORGCFG 
			lEmp = Se verdadeiro ira retornar as empresas no array passado por referencia em aEmpFunc 
			cEmpFunc = Empresa que sera pesquisada na estrutura hierarquica
@Return:	lLeadTeam = Retorna verdadeiro/falso caso o funcionario seja responsável por algum departamento
/*/
Function fGetTeamManager(cFilTeam, cMatTeam, aEmpFunc, cRoutine, cOrgCFG, lEmp, cEmpFunc)

Local cQueryA 	:= ""
Local cQueryB 	:= ""
Local cVision	:= ""
Local cTypeOrg  := ""
Local cItem     := ""
Local cWhereEmp := "%%"
Local nX        := 0
Local nY        := 0
Local aEmp      := {}
Local aDepAux	:= {}
Local aVision	:= {}
Local aVisao	:= {}
Local aChaves	:= {}
Local aEmpAux	:= {}
Local aFunc	    := {}
Local aAreaSRA  := {}
Local lLeadTeam	:= .F.
Local lChkRD4	:= .F.

DEFAULT cFilTeam := ""
DEFAULT cMatTeam := ""
DEFAULT aEmpFunc := {}
DEFAULT cRoutine := "W_PWSA100A.APW" //Considera o WS de Ferias por default
DEFAULT cOrgCfg  := GetMv("MV_ORGCFG",NIL,"0")
DEFAULT lEmp     := .F. //Retorna as empresas da estrutura validas para o funcionario
DEFAULT cEmpFunc := cEmpAnt

If !( cOrgCfg == "0" )
	
	//Verifica se existe visao, e se positivo se é estrutura por departamento
	aVision := GetVisionAI8(cRoutine, cFilTeam, cEmpFunc) 
	cVision := aVision[1][1]
	
	If !Empty( cVision )

		TipoOrg(@cTypeOrg, cVision)

		//Considera outras empresas apenas na hierarquia de visão por Departamentos
		If cTypeOrg == "2"
			cRD4Alias := GetNextAlias()
			BeginSQL ALIAS cRD4Alias
				SELECT DISTINCT RD4_EMPIDE
				FROM %table:RD4% RD4 
				WHERE RD4.RD4_CODIGO = %exp:cVision% 
				AND	RD4.RD4_FILIAL = %xfilial:RD4% 
				AND	RD4.%notDel%                   
			EndSQL	
			
			While !(cRD4Alias)->(Eof())
				lChkRD4 := .T.
				aAdd( aEmp, (cRD4Alias)->RD4_EMPIDE )
				(cRD4Alias)->(dbSkip())
			EndDo 
			(cRD4Alias)->(dbCloseArea())
            cWhereEmp := "% QB_EMPRESP = '" + cEmpFunc + "' AND %"
		EndIf
		
	EndIf
	
EndIf

//Quando nao encontra nenhuma empresa a partir da visao considera a propria empresa
If Empty(aEmp)
	aAdd( aEmp, cEmpFunc )
EndIf

//Valida as empresas que serao consideradas
If cOrgCfg == "1" //Estrutura hierárquica com controle por postos
    If !Empty(cTypeOrg)
        
        aAreaSRA := SRA->( GetArea() )
        DbSelectArea("SRA")
        If SRA->( dbSeek( cFilTeam + cMatTeam ))

            aFunc := {cMatTeam,,cFilTeam,,,,,SRA->RA_DEPTO}
            ChaveRD4(cTypeOrg, aFunc, cVision, @cItem)

            If !Empty(cItem)
                cRD4Alias := GetNextAlias()

                BeginSQL ALIAS cRD4Alias
                    SELECT COUNT(*) NQTD
                    FROM %table:RD4% RD4 
                    WHERE RD4.RD4_CODIGO = %exp:cVision% 
                    AND	RD4.RD4_FILIAL = %xfilial:RD4% 
                    AND RD4.RD4_TREE = %exp:cItem%
                    AND	RD4.%notDel%  
                EndSQL

                lLeadTeam := (cRD4Alias)->NQTD > 0
                (cRD4Alias)->(dbCloseArea())
            EndIf
        EndIf
        RestArea( aAreaSRA )
    EndIf
Else
    For nX := 1 To Len( aEmp )

        //-----------------------------------
        //VERIFICA SE O FUNCIONARIO E LIDER
        //-----------------------------------
        If !lLeadTeam
        
            __cSQBtab := "%" + RetFullName("SQB", aEmp[nX]) + "%"
            cQueryA  := GetNextAlias()
        
            BEGINSQL ALIAS cQueryA
            
                SELECT COUNT(*) NQTD
                    FROM %exp:__cSQBtab% SQB
                WHERE 
                    %exp:cWhereEmp%
                    QB_MATRESP = %Exp:cMatTeam% AND
                    QB_FILRESP = %Exp:cFilTeam% AND
                    SQB.%NotDel%
            ENDSQL
            
            lLeadTeam := (cQueryA)->NQTD > 0
            
            //Quando a chamada da rotina é apenas para verificar se o funcionario é responsavel,
            //quando for atendida a condicao sai do laço sem precisar verificar as outras empresas
            If lLeadTeam 
                If !lEmp
                    (cQueryA)->( dbCloseArea() )
                    Exit				
                Else
                    (cQueryA)->( dbCloseArea() )
                EndIf
            EndIf
        
        EndIf
        
        //--------------------------------------------------------
        //CARREGA OS DEPARTAMENTOS QUE O FUNCIONARIO É RESPONSÁVEL
        //--------------------------------------------------------
        If lEmp
        
            __cSQBtab := "%" + RetFullName("SQB", aEmp[nX]) + "%"
            cQueryB  := GetNextAlias()
        
            BEGINSQL ALIAS cQueryB
                SELECT QB_FILIAL, QB_DEPTO
                    FROM %exp:__cSQBtab% SQB
                WHERE 
                    %exp:cWhereEmp%
                    QB_MATRESP = %Exp:cMatTeam% AND
                    QB_FILRESP = %Exp:cFilTeam% AND
                    SQB.%NotDel%             
            ENDSQL

            While !(cQueryB)->(Eof())
                aAdd( aDepAux, { aEmp[nX], (cQueryB)->QB_FILIAL, (cQueryB)->QB_DEPTO } )
                (cQueryB)->(dbSkip())
            EndDo 

            (cQueryB)->( dbCloseArea() )
                    
        EndIf

    Next nX

    //--------------------------------------------------------------------
    //VALIDA AS EMPRESAS CONFORME A HIERARQUIA DE VISAO POR DEPARTAMENTOS
        //----------------------------------------------------------------
    If lEmp .And. lChkRD4
        
        aVisao  := {}
        aChaves := {}
        aEmpAux := {}
        
        cRD4Alias := GetNextAlias()
        BeginSQL ALIAS cRD4Alias
            SELECT RD4_EMPIDE, RD4_FILIDE, RD4_CODIDE, RD4_CHAVE
            FROM %table:RD4% RD4 
            WHERE RD4.RD4_CODIGO = %exp:cVision% 
            AND	RD4.RD4_FILIAL = %xfilial:RD4% 
            AND	RD4.%notDel%  
        EndSQL	
        
        //Obtem a relacao de Departamentos/Filiais da visao que esta sendo avaliada
        While !(cRD4Alias)->(Eof())
            lChkRD4 := .T.
            aAdd( aVisao, { (cRD4Alias)->RD4_EMPIDE, AllTrim((cRD4Alias)->RD4_FILIDE), (cRD4Alias)->RD4_CODIDE, (cRD4Alias)->RD4_CHAVE } )
            (cRD4Alias)->(dbSkip())
        EndDo 			
        (cRD4Alias)->(dbCloseArea())

        //Obtem a chave dos departamentos que serao considerados na visao
        For nX := 1 To Len( aDepAux )
            nPos := aScan( aVisao, { |x| x[1]+x[2]+x[3] == aDepAux[nX,1] + AllTrim(aDepAux[nX,2]) + aDepAux[nX,3] } )
            If nPos >0
                aAdd( aChaves, { aVisao[nPos,4] } )
            EndIf 
        Next nX

        //Identifica as empresas dentro da hierarquia conforme a chave dos departamentos considerados
        If Len(aChaves) > 0 
            For nX := 1 To Len( aChaves ) 
                cCodChave := AllTrim( aChaves[nX,1] )
                cTamChave := Len( cCodChave )
                
                For nY := 1 To Len(aVisao)
                    If cCodChave == SubStr( aVisao[nY,4], 1, cTamChave )
                        If aScan( aEmpAux, { |x| x == aVisao[nY,1] } ) == 0
                            aAdd( aEmpAux, aVisao[nY,1] )
                        EndIf
                    EndIf				
                Next nY
                
            Next nX
        EndIf

    EndIf
EndIf

//Retorna a relacao de empresas conforme a estrutura dos departamentos ou da visao
If lEmp
    aEmpFunc := If( Len(aEmpAux) > 0, aClone(aEmpAux), aClone(aEmp) )
EndIf

Return( lLeadTeam )

/*/{Protheus.doc} fMRHEmail
- Responsável por retornar um template HTML com os dados para recuperacao da senha

@author:	Marcelo Silveira
@since:		19/03/2020
@param:		
@Return:	cTemplate - Template HTML com os dados para recuperacao da senha
/*/
Function fMRHEmail()

Local lPOR      := .F.
Local lESP      := .F.
Local cTemplate	:= ""
Local cIdioma	:= FWRetIdiom()	//Retorna Idioma Atual

//Se nao for Portugues nem Espanhol assume o Ingles para todos os demais idiomas
If cIdioma == "pt-br"
    lPOR  := .T.
ElseIf cIdioma == "es"
    lESP  := .T.
EndIf

cTemplate   += '<!DOCTYPE html>'
cTemplate   += '<html>'
cTemplate   += '<head>'
cTemplate   += '    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
cTemplate   += '    <meta name="viewport" content="width=device-width" />'
cTemplate   += '</head>'
cTemplate   += '<body style="display: flex; align-items: center; justify-content: center; margin: 0;">'
cTemplate   += '    <table style="width: 600px; height: 987px; background: #E9F0F0; border-spacing: 0;" border="0">'
cTemplate   += '        <tbody>'
cTemplate   += '            <tr style="background-color: #E9F0F0;">'
cTemplate   += '                <td style="display: flex">'
cTemplate   += '                    <img style="margin-top: 40px; margin-left: 34px; width: 80px; height: 80px;" alt="MeuRH" src="%img_Meurh%" />'
cTemplate   += '                    <div style="margin-top: 41px; margin-left: 20.5px; margin-right: 20.5px; width: 0px; height: 80px; border-left: 1.5px solid #707070;"></div>'
cTemplate   += '                    <p style="margin-top: 50px; left: 175px; width: 283px; height: 61px; text-align: left; font: normal normal bold 26px/31px Arial; letter-spacing: 0px;color: #000000; opacity: 1; white-space: nowrap">'
cTemplate   += '                        Meu RH <br /> Recuperação de senha'
cTemplate   += '                    </p>'
cTemplate   += '                </td>'
cTemplate   += '            </tr>'
cTemplate   += '            <tr style="text-align: center;background-color: #E9F0F0;">'
cTemplate   += '                <td style="width: 100%; opacity: 1;">'
cTemplate   += '                    <img style="width: 425px; height: 234px;" alt="Ilustração de recuperação de senha" src="%img_header%" />'
cTemplate   += '                </td>'
cTemplate   += '            </tr>'
cTemplate   += '            <tr style="background-color: #E9F0F0;">'
cTemplate   += '                <td style="padding: 0 3em 0 3em;">'
cTemplate   += '                    <strong>'
If lPOR
    cTemplate   += '                        <br /><span style="top: 434px; left: 60px; width: 520px; height: 160px; text-align: left; font: normal normal normal 20px/23px Arial; letter-spacing: 0px; color: #32373C; opacity: 1;">'
    cTemplate   += '                            Ol&aacute; %first_name%,</span> '
ElseIf lESP
    cTemplate   += '                        <br /><span style="top: 434px; left: 60px; width: 520px; height: 160px; text-align: left; font: normal normal normal 20px/23px Arial; letter-spacing: 0px; color: #32373C; opacity: 1;">'
    cTemplate   += '                            Hola %first_name%,</span> '
Else
    cTemplate   += '                        <br /><span style="top: 434px; left: 60px; width: 520px; height: 160px; text-align: left; font: normal normal normal 20px/23px Arial; letter-spacing: 0px; color: #32373C; opacity: 1;">'
    cTemplate   += '                            Hello %first_name%,</span> '
EndIf

cTemplate   += '                    </strong>'
cTemplate   += '                </td>'
cTemplate   += '            </tr>'
cTemplate   += '            <tr style="background-color: #E9F0F0;">'
cTemplate   += '                <td style=" padding: 0 3em 0 3em;">'
cTemplate   += '                    <strong>'
cTemplate   += '                        <span style="top: 434px; left: 60px; width: 520px; height: 160px; text-align: left; font: normal normal normal 20px/23px Arial;
cTemplate   += '                        letter-spacing: 0px; color: #32373C; opacity: 1; " '
If lPOR
    cTemplate   += '                        >Recebemos uma solicita&ccedil;&atilde;o para recupera&ccedil;&atilde;o de sua senha em %date_time%. Acesse o '
    cTemplate   += '                        bot&atilde;o abaixo para iniciar o processo de altera&ccedil;&atilde;o da senha.</span> '
ElseIf lESP
    cTemplate   += '                        >Recibimos una solicitud para recuperar su contrase&ntilde;a el %date_time%. Acceda al ' 
    cTemplate   += '                        bot&oacute;n de abajo para iniciar el proceso de cambio de contrase&ntilde;a.</span> '
Else
    cTemplate   += '                        >We received a request to recover your password on %date_time%. Access the button below to 
    cTemplate   += '                        start the password change process.</span> '
EndIf
cTemplate   += '                    </strong>'
cTemplate   += '                </td>'
cTemplate   += '            </tr>'
cTemplate   += '            <tr style="text-align: center; background-color: #E9F0F0;">'
cTemplate   += '                <td style="top: 20x; padding: 40px 80px;">'
cTemplate   += '                    <a href="%link_pwd%" target="_blank" style="background: #0C9ABE 0% 0% no-repeat padding-box; border-radius: 12px; width: 189px; height: 60px;'
cTemplate   += '                     opacity: 1; color: #ffffff; border: 0px solid #000000; box-sizing: border-box; font: normal normal bold 20px/23px Arial;letter-spacing: 0px;'
cTemplate   += '                      color: #FFFFFF; padding: 19px 24px; text-align: left; text-decoration: none;" rel="noopener">Alterar senha</a>'
cTemplate   += '                </td>'
cTemplate   += '            </tr>'
cTemplate   += '            <tr style="background-color: #E9F0F0;">'
cTemplate   += '                <td style="padding: 0 3em 0 3em; margin-top: 40px">'
cTemplate   += '                    <span style="top: 714px; left: 60px; width: 520px; height: 171px; text-align: left; font: normal normal normal 16px/18px Arial; 
cTemplate   += '                     letter-spacing: 0px; color: #32373C; opacity: 1;"'
cTemplate   += '                        >Se o link acima n&atilde;o funcionar, copie o endere&ccedil;o abaixo e cole '
cTemplate   += '                         na barra de endere&ccedil;os do seu navegador: <br /><br /><span style="color: #0C9ABE;"> %link_pwd%</span></span><br /><br />'
cTemplate   += '                </td>'
cTemplate   += '            </tr>'
cTemplate   += '            <tr style="background-color: #E9F0F0; ">'
cTemplate   += '                <td style="padding: 0 3em 37px 3em;">'
cTemplate   += '                    <span style="top: 905px; left: 60px; width: 520px; height: 35px; text-align: left; font: normal normal normal 16px/18px Arial; letter-spacing: 0px; color: #32373C; opacity: 1; ">Caso n&atilde;o tenha solicitado a altera&ccedil;&atilde;o de senha, desconsidere o recebimento desta mensagem.</span>'
cTemplate   += '                </td>'
cTemplate   += '            </tr>'
cTemplate   += '            <tr style="text-align: center; background-color: #ffff;">'
cTemplate   += '                <td style="width: 100%; padding-top: 2%; padding-bottom: 2%;">'
cTemplate   += '                    <img src=%img_bottom% alt="TOTVS" width="72" height="21" />'
cTemplate   += '                </td>'
cTemplate   += '            </tr>'
cTemplate   += '        </tbody>'
cTemplate   += '    </table>'
cTemplate   += '</body>'
cTemplate   += '</html>'


Return( cTemplate )

/*/{Protheus.doc} fDateIng
- Responsável por retornar uma data por extenso em ingles

@author:	Marcelo Silveira
@since:		19/03/2020
@Return:	cRet - Data por extenso em ingles
/*/
Function fDateIng()

Local nDay      := 0
Local cMonth    := ""
Local cYear     := ""
Local cAddDay   := ""
Local cRet      := ""

nDay    := Day( Date() )
cMonth  := Mesextenso( Date() )
cYear   := cValToChar( Year(Date()) )

Do Case
    Case nDay == 1
        cAddDay := "st,"
    Case nDay == 2
        cAddDay := "nd,"
    Case nDay == 3
        cAddDay := "rd,"
    OTHERWISE
        cAddDay := "th,"
EndCase

cRet := cMonth + Space(1) + cValToChar(nDay) + cAddDay + Space(1) + cYear

Return( cRet )

/*/{Protheus.doc} fPwdRules
- Responsável por validar a regra de preenchimento de senhas

@author:	Marcelo Silveira
@since:		04/05/2021
@Return:	lSucesso - Verdadeiro se a regra foi validada com sucesso
/*/
Function fPwdRules( cCodRD0, cPass, cMsgErr )

    Local cID           := ""
    Local cNewPass      := ""
    Local nX            := 0
    Local nLast         := 0
    Local nVezes        := 9
    Local lSucesso      := .F.
    Local aMessage      := {}
    Local aAreaRD0      := RD0->( GetArea() )
    Local oVault        := MPPswVault(aMessage)
    Local lSHA512       := TamSX3("RD0_SENHAC")[1] == 128
    Local lUseHist      := AliasInDic("A30")
    Local cPPAccess     := GetMv("MV_ACESSPP",,"")

    Default cPass       := ""
    Default cMsgErr     := ""    

    dbSelectArea("RD0")
    dbSetOrder(1)    
    If dbSeek( xFilial("RD0")+ cCodRD0 )
        If cPPAccess == "1"
            //Login por e-mail
            cID := UPPER(AllTrim(RD0->RD0_EMAIL))
        Else
            //Login pelo campo LOGIN ou CPF
            cID := If( !Empty(RD0->RD0_LOGIN), UPPER(AllTrim(RD0->RD0_LOGIN)), AllTrim(RD0->RD0_CIC) )
        EndIf
    EndIf

    //Primeiro verifica se a senha nova atende aos requisitos das regras de preenchimento
    lSucesso := oVault:Put(cID, cPass)

	//Em seguida verifica se existe historico e checa se existe validacao de senhas anteriores
    If lSucesso

        oVault:Delete(cID)

        If lUseHist

            //Verifica se existe regra de ultimas senhas simulando a inclusao da senha nova até nVezes
            For nX := 1 To nVezes
                If !oVault:Put(cID, cPass)
                    nLast := fGetPwdNum( aMessage )
                    Exit
                EndIf
            Next nX

            //Checa se a nova senha pode ser incluida considerando o historico
            If nLast >= 1 .And. nLast <= 9
                
                If lSHA512
                    //Cliente possui tamanho do campo RD0_SENHAC atualizado no dicionario
                    cNewPass := SHA512(AllTrim(cPass))
                Else
                    //Cliente possui tamanho padrão(40) do campo RD0_SENHAC no dicionario
                    cNewPass := SHA1(AllTrim(cPass))
                EndIf

                lSucesso := fPwdHist( cCodRD0, nLast, cNewPass, @cMsgErr )
            EndIf

            oVault:Delete(cID)
        EndIf
    Else
        cMsgErr := EncodeUTF8( AllTrim(aMessage[2]) )
    EndIf

    RestArea(aAreaRD0)

Return( lSucesso )


/*/{Protheus.doc} fPwdHist
- Responsável por verificar se uma determinada senha já existe no histórico

@author:	Marcelo Silveira
@since:		04/05/2021
@Return:	lRet - Verdadeiro se a senha com base no histórico foi validada com sucesso
/*/
Function fPwdHist( cCodRD0, nLast, cNewPass, cErr )
    
    Local nCount        := 0
    Local lRet          := .T.
    Local cQuery        := ""
    Local cFilA30       := xfilial("A30")

    DEFAULT cCodRD0     := ""
    DEFAULT nLast       := 0
    DEFAULT cNewPass    := ""
    DEFAULT cErr        := ""

    If nLast > 0 .And. !Empty( cCodRD0 )

        cQuery    := GetNextAlias()

        BEGINSQL ALIAS cQuery
            SELECT A30_DATA, A30_HORA, A30_SENHAC
            FROM
                %Table:A30% A30
            WHERE
                A30.A30_FILIAL = %Exp:cFilA30% AND
                A30.A30_CODIGO = %Exp:cCodRD0% AND
                A30.%NotDel%
            ORDER BY 1 DESC, 2 DESC 
        ENDSQL

        If !Empty(cQuery)
            While !(cQuery)->(Eof())

                nCount ++ 

                //Verifica se a nova senha está contida entre as últimas n senhas do histórico
                If (cNewPass == AllTrim((cQuery)->A30_SENHAC) .And. nCount <= nLast)
                    If nLast > 1
                        cErr := EncodeUTF8( STR0104 + Space(1) + STR0105 + Space(1) + cValToChar(nLast) + Space(1) + STR0106 ) //"Senha inválida." # "Não é possível utilizar as" # "últimas senhas."
                    Else
                        cErr := EncodeUTF8( STR0104 + Space(1) + STR0107) // # "Senha inválida. Não é possível utilizar a mesma senha." )
                    EndIf
                    lRet := .F.
                    Exit
                EndIf

                //Sai do laço quando ultrapassa o numero de registros que precisa ser verificado
                If nCount > nLast
                    Exit
                EndIf

                (cQuery)->(dbSkip())
            EndDo
        EndIf

        (cQuery)->(dbCloseArea())
    EndIf    

Return( lRet )

/*/{Protheus.doc} fGetPwdNum
- Identifica a partir da mensagem de validacao o numero de n senhas anteriores

@author:	Marcelo Silveira
@since:		04/05/2021
@Return:	nNumPwd - Numero de senhas anteriores
/*/
Static Function fGetPwdNum( aMsg )
    
    Local nX        := 0
    Local nNumPwd   := 0
    Local cStr      := ""
    Local cNum      := "123456789"

    DEFAULT aMsg    := {}
    
    If Len(aMsg) > 0 .And. aMsg[1] == "106" //Ultimas n senhas da Politica
        
        For nX := 1 To Len(aMsg[2])
            cStr := SubStr(aMsg[2], nX, 1)
            If cStr $ cNum
                nNumPwd := Val(cStr)
                Exit
            EndIf
        Next nX

    EndIf

Return( nNumPwd )

/*/{Protheus.doc} MrhMail
- Responsável por disparar o email da recuperação de senha do Meu RH

@author:	Henrique Ferreira
@since:		19/11/2021
@Return:	lEnvioOK - Verdadeiro caso o email tenha sido disparado.
/*/
Function MrhMail(cSubject,cMensagem,cEMail,cMsgErro)

Local cMailServer	:= GetMv("MV_RELSERV",, "")
Local cMailConta	:= GetMv("MV_RELACNT",, "")
Local cMailSenha	:= GetMv("MV_RELPSW" ,, "")
Local cFrom         := GetMv("MV_RELFROM",,"" )
Local cUsuario		:= SubStr(cMailConta,1,At("@",cMailConta)-1)
Local cServer		:= ""

Local lUseSSL		:= GetMv("MV_RELSSL" ,,.F.)
Local lUseTLS		:= GetMv("MV_RELTLS" ,,.F.)
Local lEnvioOK 		:= .F.	// Variavel que verifica se foi conectado OK
Local lMailAuth		:= GetMv("MV_RELAUTH",,.F.)

Local oMessage		:= NIL
Local oMail			:= NIL

Local nErro			:= 0
Local nPort			:= 0
Local nAt			:= 0

DEFAULT cMsgErro := {}

If Empty(cFrom)
	If At("@",cMailConta) > 0
		cFrom := cMailConta
	Else
        cMsgErro := EncodeUTF8( STR0113 ) // "É necessário configurar um e-mail para envio em Configurador > Ambiente > E-mail/Proxy > Configurar."
		Conout( cMsgErro )
		Return .F.
	EndIf
EndIf

If (!Empty(cMailServer)) .AND. (!Empty(cMailConta))
	
	oMail := TMailManager():New()
	oMail:SetUseSSL(lUseSSL)
	oMail:SetUseTLS(lUseTLS)
	nAt	:=  At(':' , cMailServer)
	
	// Para autenticacao, a porta deve ser enviada como parametro[nSmtpPort] na chamada do método oMail:Init().
	// A documentacao de TMailManager pode ser consultada por aqui : http://tdn.totvs.com/x/moJXBQ
	If ( nAt > 0 )
		cServer		:= SubStr(cMailServer , 1 , (nAt - 1) )
		nPort		:= Val(AllTrim(SubStr(cMailServer , (nAt + 1) , Len(cMailServer) )) )
	Else
		cServer		:= cMailServer
	EndIf
	
	oMail:Init("", cServer, cMailConta, cMailSenha , 0 , nPort)	
	//Init( < cMailServer >, < cSmtpServer >, < cAccount >, < cPassword >, [ nMailPort ], [ nSmtpPort ] )
	
	nErro := oMail:SMTPConnect()
		
	If ( nErro == 0 )
		If lMailAuth
			// try with account and pass
			nErro := oMail:SMTPAuth(cMailConta, cMailSenha)
			If nErro != 0
				// try with user and pass
				nErro := oMail:SMTPAuth(cUsuario, cMailSenha)
				If nErro != 0
                    cMsgErro := EncodeUTF8( STR0114 + oMail:GetErrorString(nErro) ) // "Falha na autenticaçao com o servidor SMTP"
					Conout( cMsgErro )
					Return .F.
				EndIf
			EndIf
		Endif
		
		oMessage := TMailMessage():New()
		
		//Limpa o objeto
		oMessage:Clear()
		
		//Popula com os dados de envio
		oMessage:cFrom 		:= cFrom
		oMessage:cTo 		:= cEmail
		oMessage:cCc 		:= ""
		oMessage:cBcc 		:= ""
		oMessage:cSubject 	:= cSubject
		oMessage:cBody 		:= cMensagem
        //Envia o e-mail
        nErro := oMessage:Send( oMail )
        
        If !(nErro == 0)
            cMsgErro := EncodeUTF8( STR0115 + oMail:GetErrorString(nErro) ) //"Falha no envio do e-mail. Erro retornado: "
            Conout( cMsgErro )
        Else
            lEnvioOk	:= .T.
        EndIf

		//Desconecta do servidor
		oMail:SmtpDisconnect()
		
	Else
		cMsgErro := EncodeUTF8( STR0100 + oMail:GetErrorString(nErro) ) //"Erro desconhecido no envio de email"
		Conout( cMsgErro )
	EndIf
	
Else

	If ( Empty(cMailServer) )
        cMsgErro := EncodeUTF8( STR0096 ) // "Servidor SMTP não encontrado (MV_RELSERV)"
		Conout( cMsgErro )
        Return .F.
	EndIf

	If ( Empty(cMailConta) )
        cMsgErro := EncodeUTF8( STR0097 ) //"Conta de email não encontrado (MV_RELACNT)"
		Conout( cMsgErro )
        Return .F.
	EndIf
	
	If Empty(cMailSenha)
        cMsgErro := EncodeUTF8( STR0098 ) //"Senha de email não encontrado (MV_RELPSW)"
		Conout( cMsgErro )
	EndIf
	
EndIf

Return( lEnvioOK )

/*/{Protheus.doc} fSetFieldP
- Função responsável por setar os fieldProperties.

@author:	Henrique Ferreira
@since:		19/11/2021
@Return:	NIL.
/*/

Function fSetFieldP(cField, lVisible, lEditable, lRequired, oProps)

oProps              := JsonObject():New()
oProps["field"]     := cField
oProps["visible"]   := lVisible
oProps["editable"]  := lEditable
oProps["required"]  := lRequired

Return( NIL )
