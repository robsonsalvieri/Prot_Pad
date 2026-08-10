#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "JURA176A.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} J176ASMail()
Rotina para envio de e-mails via Schedule com as pendências de aprovação do Tarifador.

MV_PAR01 - Configuração do Servidor (NR7)
MV_PAR02 - Configuração do Usuário  (NR8)
MV_PAR03 - Configuração de Envio    (NRU)

@return lRet , Indica o sucesso da execução

@author Cristina Cintra / Jorge Martins
@since  01/07/2019
/*/
//-------------------------------------------------------------------
Function J176ASMail()
Local lRet       := .T.
Local lSchedule  := .T.
Local cCfgSrv    := IIf(Type("MV_PAR01") <> "U", Alltrim(MV_PAR01), "")
Local cCfgUsrSrv := IIf(Type("MV_PAR02") <> "U", Alltrim(MV_PAR02), "")
Local cCfgEnv    := IIf(Type("MV_PAR03") <> "U", Alltrim(MV_PAR03), "")

	If (Empty(cCfgSrv) .Or. Empty(cCfgUsrSrv) .Or. Empty(cCfgEnv))
		lRet := .F.
		JurMsgErro(STR0039) // "A execução via schedule necessita do envio dos parâmetros de envio de e-mail. Ajustar a chamada informando a configuração do servidor de e-mail e de envio."
	Else
		If !ExistCpo("NR7", cCfgSrv, 1) .Or. !ExistCpo("NR8", cCfgUsrSrv, 1) .Or. !ExistCpo("NRU", cCfgEnv, 1)
			lRet := .F.
			JurMsgErro(STR0040) // "Existe inconsistência nos parâmetros enviados. Verifique e indique os códigos corretos para execução."
		EndIf
	EndIf

	If lRet
		J176ASend(lSchedule, cCfgSrv, cCfgUsrSrv, cCfgEnv)
	EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Parâmetros para execução via Schedule.

@author  Bruno Ritter | Jorge Martins
@since   09/02/2018
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
Local aOrd   := {}
Local aParam := {}

aParam := { "P"       ,; // Tipo R para relatorio P para processo
            "J176ASMAIL",; // Pergunte do relatorio, caso nao use passar ParamDef
            ""        ,; // Alias
            aOrd      ,; // Array de ordens
          }
Return aParam

//------------------------------------------------------------------------------
