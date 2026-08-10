#include "totvs.ch"
#include "retail.rmi.servicos.usuarios.ch"

Static cThread := "RmiInteUsr - Thread: " + cValToChar(ThreadID())

/*/{Protheus.doc} RmiInteUsr
    Processo de Integração de estrutura de usuários ( Retaguarda X CentralPDV )
    @type  Function
    @author m.adente
    @since 01/04/2025
    @version 1.0	
	@params xEmp, caracter, Empresa
			cFil, caracter, Filial
			cAut, caracter, palavra_passe 
/*/

Main Function RmiInteUsr(xEmp,cFil,cAut)
Local cAutoriza := ''
Local cModo		:= ''

Default cAut := ''


If LockByName('RmiInteUsr', .F., .F.) 

	If ValType(xEmp) == 'C'
		If !Empty(xEmp) .AND. !Empty(cFil)
			RPCSetEnv(xEmp,cFil,,, 'FRT')	
		EndIf
	Else
		If !Empty(xEmp[1]) .AND. !Empty(xEmp[2])
			RPCSetEnv(xEmp[1],xEmp[2],,, 'FRT')	
		EndIf
	EndIf
	cAutoriza				:=SuperGetMV("MV_LJIUSR5", .F., "")
	cModo					:=SuperGetMV("MV_LJIUSR6", .F., "")
	If ValType(xEmp) == 'A'
		cAut:= cAutoriza
	EndIf
	If cAut == cAutoriza
		If cModo == 'I'
			LJIMPUsr()
		ElseIf cModo == 'E'
			LJEXPUsr()
		EndIf
	EndIf
    UnlockByName("RmiInteUsr", .F., .F.) 
EndIf


Return .T.

/*/{Protheus.doc} LJIMPUsr
	@type  Static Function
	@author m.adente
	@since 01/04/2025
	@version 1.0
	@return lRet
/*/
Static Function LJIMPUsr()
Local lRet:= .F.
Local cServerSFTP 			:=SuperGetMV("MV_LJIUSR1", .F., "")
Local cPortSFTP   			:=SuperGetMV("MV_LJIUSR2", .F., "")
Local cUserSFTP   			:=SuperGetMV("MV_LJIUSR3", .F., "")
Local cPwdSFTP	  			:=SuperGetMV("MV_LJIUSR4", .F., "")

lRet:= RmiIntUDown(cServerSFTP,cPortSFTP,cUserSFTP,cPwdSFTP,cThread)	

If lRet
	LjGrvLog(cThread,STR0002)//"Processo de Importação MpFileToUsr Inicializado"
	totvs.framework.UserSync.MpFileToUsr(.F.)
	LjGrvLog(cThread,STR0003)//"Processo de Importação MpFileToUsr Finalizado"
EndIf	

Return lRet

/*/{Protheus.doc} LJEXPUsr
	@type  Static Function
	@author m.adente
	@since 01/04/2025
	@version 1.0
/*/
Static Function LJEXPUsr()

LjGrvLog(cThread,STR0004) //"Processo de Exportação MPUserTofile Iniciado"
totvs.framework.UserSync.MPUserToFile()
LjGrvLog(cThread,STR0005) //"Processo de Exportação MPUserTofile Finalizado"

Return 
