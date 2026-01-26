// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : TDWPrivileges - Define o objeto de privilégios do usuário
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 21.02.06 |2481-Paulo R Vieira| Versão 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe: TDWPrivileges
Uso   : Define o objeto de privilégios do usuário
--------------------------------------------------------------------------------------
*/
class TDWPrivileges from TDWObject

	data fnDwID
	data fnUserID
	data fnUserGroup
	data flUserIsAdm
	
	method New(anDwID, anUserID) constructor
	method Free()
	method Clean()

	// DW
	method DwID()

	// Usuário
	method UserID()
	
	// Grupo do usuário
	method UserGroup()

	// usuário é administrador
	method UserIsAdm()
	
	// carrega informações sobre o usuário
	method DoLoad()
	
	// verifica se o usuário têm um grupo
	method UserHaveGroup()
	
	// checa um privilégio genérico para este usuário
	method checkPrivilege(anObjID, acPriv, acOper)
	
	// checa o privilégio de acesso ao DW
	method checkDwPrivileges(anDwID)
	
	// checa os privilégios de um determinado cubo
	method checkCubePrivileges(anCubID)
	
	// checa o privilégio de criação de consultas
	method checkCreateQuery()
	
	// checa os privilégios de acesso de determinada consulta
	method checkQryAcessPrivileges(anQryID)
	
	// checa os privilégios de manutenção de determinada consulta
	method checkQryMaintPrivileges(anQryID)
	
	// checa os privilégios de exportar uma determinada consulta
	method checkQryExportPrivileges(anQryID)
	
	// checa os privilégios de uma determinada consulta
	method checkQueryPrivileges(anQryID, acOperType)
	
	// salva um privilégio genérico para este usuário
	method SavePrivilege(anObjID, acPriv, acOper, acAuthoriz) 
	
	// salva privilégios de DW para este usuário
	method SaveDwPrivileges(anDwID, aoNewPrivOper)
	
	// salva privilégios de criação para este usuário
	method SaveCreatePrivileges(aoNewPrivOper)
	
	// salva os privilégios de uma consulta para este usuário
	method SaveQueryPrivileges(anQueryID, aoNewPrivOper)
	
	// salva os privilégios de um cubo para este usuário
	method SaveCubePrivileges(anCubeID, aoNewPrivOper)

	// redefine todos os privilégios deste usuário
	method ResetAllPrivileges()
	
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: 	anDwID, numérico, contendo o id do dw aonde serão gerenciados os privilégios do usuário
		anUserID, numérico, contendo o id do usuário dos privilégios
--------------------------------------------------------------------------------------
*/
method New(anDwID, anUserID) class TDWPrivileges

	_Super:New()
	::Clean()
	::DwID(anDwID)
	::UserID(anUserID)
	::DoLoad()
	
return

method Free() class TDWPrivileges

	::Clean()
	_Super:Free()

return


method Clean() class TDWPrivileges
	
	::DwID(0)
	::UserID(0)
	::UserGroup(0)
    ::UserIsAdm(.F.)

return

/*
--------------------------------------------------------------------------------------
Propriedade DwID
Arg: anValue, numérico, define esta propriedade
Ret: numérico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method DwID(anValue) class TDWPrivileges
	property ::fnDwID := anValue
return ::fnDwID

/*
--------------------------------------------------------------------------------------
Propriedade UserID
Arg: anValue, numérico, define esta propriedade
Ret: numérico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method UserID(anValue) class TDWPrivileges
	property ::fnUserID := anValue
return ::fnUserID

/*
--------------------------------------------------------------------------------------
Propriedade UserGroup
Arg: anValue, numérico, define esta propriedade
Ret: numérico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method UserGroup(anValue) class TDWPrivileges
	property ::fnUserGroup := anValue
return ::fnUserGroup

/*
--------------------------------------------------------------------------------------
Propriedade UserIsAdm
Arg: alValue, lógico, define esta propriedade
Ret: lógico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method UserIsAdm(alValue) class TDWPrivileges
	property ::flUserIsAdm := alValue
return ::flUserIsAdm

/*
--------------------------------------------------------------------------------------
Método que realiza o carregamento de informações do usuário
Arg: anValue, numérico, define esta propriedade
Ret: numérico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method DoLoad() class TDWPrivileges
	Local oUser := InitTable(TAB_USER)
	
	oUser:SavePos()
	oUser:Seek(1, { ::UserID() })
	if !oUser:EoF() .AND. oUser:value("id") == ::UserID()
		::UserGroup(oUser:value("id_grupo"))
		::UserIsAdm(oUser:value("admin"))
	endif
	oUser:RestPos()
return

/*
--------------------------------------------------------------------------------------
Método que verifica se o usuário têm um grupo
Arg:
Ret: Lógico, .T. se tiver ou .F. caso contrário
--------------------------------------------------------------------------------------
*/
method UserHaveGroup() class TDWPrivileges
return iif (::UserGroup() > 0, .T., .F.)

/*
--------------------------------------------------------------------------------------
Método responsável por checar um privilégio genérico para este usuário
Arg: 	anObjID, númerico, contém o id do objeto
		acPriv, caracter, contém o tipo de objeto (ver defines PRIV_OBJ_XXXX)
		acOper, caracter, contém a operação (ver defines PRIV_OPER_XXXX)
Ret: Lógico, se possue (.T.) ou não (.F.) o privlégio
--------------------------------------------------------------------------------------
*/
method checkPrivilege(anObjID, acPriv, acOper, anUserID) class TDWPrivileges
    
    Local cRet := PRIV_AUTH_NDEFINED
	Local oTablePriv := InitTable(TAB_USER_PRIV)
	
	default anUserID := ::UserID()
	
	// verifica os privilégios do usuário (caso este não seja admin)
	if !::UserIsAdm()
		__DWIDTemp := ::DwID()
		if anObjID > 0
			oTablePriv:SavePos()
			oTablePriv:Seek(2, { anUserID, anObjID, acPriv, acOper })
			if !oTablePriv:EoF() .AND. oTablePriv:value("id_user") == anUserID .AND. oTablePriv:value("id_dw") == ::DwID() ;
					.AND. oTablePriv:value("id_obj") == anObjID .AND. oTablePriv:value("type_obj") == acPriv .AND. ;
						oTablePriv:value("type_oper") == acOper
				cRet := oTablePriv:value("type_auth")
			endif
			oTablePriv:RestPos()
		else
			oTablePriv:SavePos()
			oTablePriv:Seek(3, { anUserID, acPriv, acOper })
			if !oTablePriv:EoF() .AND. oTablePriv:value("id_user") == anUserID .AND. oTablePriv:value("id_dw") == ::DwID() ;
					.AND. oTablePriv:value("type_obj") == acPriv .AND. oTablePriv:value("type_oper") == acOper
				cRet := oTablePriv:value("type_auth")
			endif
			oTablePriv:RestPos()
		endif
		__DWIDTemp := -1
	else
		cRet := PRIV_AUTH_AUTHOR
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Método responsável por checar os privilégios de um determinado cubo
Arg: anDwID, númerico, contém o id do DW
Ret: Objeto, retorna objeto do tipo TDWPrivOper() com os privilégios deste usuário para cada operação possível
--------------------------------------------------------------------------------------
*/
method checkDwPrivileges(anDwID) class TDWPrivileges
	
	Local cUserPriv
	Local oRet := TDWPrivOper():New()
	
	// privilégio de acesso a DW
	cUserPriv := ::checkPrivilege(anDwID, PRIV_OBJ_DW, PRIV_OPER_ACESS)
	oRet:Acess(checkAuthorization(cUserPriv))
	// se o usuário não tiver privilégio estabelecido, procuro pelo privilégio no grupo do usuário
	if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
		cUserPriv := ::checkPrivilege(anDwID, PRIV_OBJ_DW, PRIV_OPER_ACESS, ::UserGroup())
		oRet:AcessInherited(checkAuthorization(cUserPriv))
	endif
	
return oRet

/*
--------------------------------------------------------------------------------------
Método responsável por checar os privilégios de um determinado cubo
Arg: anCubID, númerico, contém o id do cubo
Ret: Objeto, retorna objeto do tipo TDWPrivOper() com os privilégios deste usuário para cada operação possível
--------------------------------------------------------------------------------------
*/
method checkCubePrivileges(anCubID) class TDWPrivileges
	
	Local oRet := TDWPrivOper():New()
	Local cUserPriv
	
	// cubo só poderá ser criado pelo administrador
	oRet:Create(::UserIsAdm())
	oRet:CreateInherited(.F.)
	
	// privilégio de manutenção do cubo
	cUserPriv := ::checkPrivilege(anCubID, PRIV_OBJ_CUBE, PRIV_OPER_MANUT)
	oRet:Maintenance(checkAuthorization(cUserPriv))
	// se o usuário não tiver privilégio estabelecido, procuro pelo privilégio no grupo do usuário
	if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
		cUserPriv := ::checkPrivilege(anCubID, PRIV_OBJ_CUBE, PRIV_OPER_MANUT, ::UserGroup())
		oRet:MaintInherited(checkAuthorization(cUserPriv))
	endif

	// privilégio de acesso ao cubo
	cUserPriv := ::checkPrivilege(anCubID, PRIV_OBJ_CUBE, PRIV_OPER_ACESS)
	oRet:Acess(checkAuthorization(cUserPriv))
	// se o usuário não tiver privilégio estabelecido, procuro pelo privilégio no grupo do usuário
	if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
		cUserPriv := ::checkPrivilege(anCubID, PRIV_OBJ_CUBE, PRIV_OPER_ACESS, ::UserGroup())
		oRet:AcessInherited(checkAuthorization(cUserPriv))
	endif	
	
return oRet

/*
--------------------------------------------------------------------------------------
Método responsável por checar o privilégio de criação de consultas
Arg:
Ret: Lógico, se possue (.T.) ou não (.F.) o privlégio
--------------------------------------------------------------------------------------
*/
method checkCreateQuery() class TDWPrivileges
	
	Local cUserPriv
	Local oRet := TDWPrivOper():New()
	
	// privilégio de criação de consulta
	cUserPriv := ::checkPrivilege(0, PRIV_OBJ_QUERY, PRIV_OPER_CREATE)
	oRet:Create(checkAuthorization(cUserPriv))
	// se o usuário não tiver privilégio estabelecido, procuro pelo privilégio no grupo do usuário
	if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
		cUserPriv := ::checkPrivilege(0, PRIV_OBJ_QUERY, PRIV_OPER_CREATE, ::UserGroup())
		oRet:CreateInherited(checkAuthorization(cUserPriv))
	endif
	
return oRet

/*
--------------------------------------------------------------------------------------
Método responsável por checar o privilégio de acesso deste usuário à uma determinada consulta
Arg: anQryID, númerico, contém o id da consulta
Ret: Objeto, retorna objeto do tipo TDWPrivOper() com os privilégios deste usuário para cada operação possível
--------------------------------------------------------------------------------------
*/
method checkQryAcessPrivileges(anQryID) class TDWPrivileges
return ::checkQueryPrivileges(anQryID, PRIV_OPER_ACESS)

/*
--------------------------------------------------------------------------------------
Método responsável por checar o privilégio de manutenção deste usuário à uma determinada consulta
Arg: anQryID, númerico, contém o id da consulta
Ret: Objeto, retorna objeto do tipo TDWPrivOper() com os privilégios deste usuário para cada operação possível
--------------------------------------------------------------------------------------
*/
method checkQryMaintPrivileges(anQryID) class TDWPrivileges
return ::checkQueryPrivileges(anQryID, PRIV_OPER_MANUT)

/*
--------------------------------------------------------------------------------------
Método responsável por checar o privilégio de exportar deste usuário à uma determinada consulta
Arg: anQryID, númerico, contém o id da consulta
Ret: Objeto, retorna objeto do tipo TDWPrivOper() com os privilégios deste usuário para cada operação possível
--------------------------------------------------------------------------------------
*/
method checkQryExportPrivileges(anQryID) class TDWPrivileges
return ::checkQueryPrivileges(anQryID, PRIV_OPER_EXPORT)

/*
--------------------------------------------------------------------------------------
Método responsável por checar os privilégios de uma determinada consulta
Arg: anQryID, númerico, contém o id da consulta
	 acOperType, string, contém o tipo de operação a ser verificada a permissão. DEFAULT verifica todos os direitos
Ret: Objeto, retorna objeto do tipo TDWPrivOper() com os privilégios deste usuário para cada operação possível
--------------------------------------------------------------------------------------
*/
method checkQueryPrivileges(anQryID, acOperType) class TDWPrivileges
	
	Local oRet
	Local cUserPriv, oUser
	Local oConsulta			:= InitTable(TAB_CONSULTAS)
	
	// verifica o privilégio de criação de consultas
	oRet := ::checkCreateQuery()
	
	oConsulta:SavePos()
	oConsulta:Seek(1, { anQryID })
	// verifica se a consulta é de usuário
	if !oConsulta:EoF() .AND. oConsulta:value("id") == anQryID .AND. oConsulta:value("tipo") == QUERY_USER

		/*Verifica se o CRIADOR da consulta foi este usuário | Se a Consulta é foi definida como sendo PUBLICA
			| Se o usuário corrente é ADMINISTRADOR do SigaDW.*/ 		
		if ( oConsulta:value("id_user") == ::UserID() .or. oConsulta:value("publica") .or. oUserDW:UserIsAdm() )
			oRet:MaintInherited(.F.)	// privilégio de manutenção herdado
			oRet:Maintenance(.T.)		// privilégio de manutenção
			oRet:AcessInherited(.F.)	// privilégio de acesso herdado
			oRet:Acess(.T.) 			// privilégio de acesso
			oRet:ExportInherited(.F.) 	// privilégio de exportação herdado
			oRet:Export(.T.) 			// privilégio de exportação
		else			
			oUser := InitTable(TAB_USER)
			oUser:SavePos()
			oUser:Seek(1, { oConsulta:value("id_user") })
			// verifica se a consulta é pública OU se está disponível para o grupo deste usuário
			if oConsulta:value("publica") .OR. (!oUser:EoF() .and. oUser:value("id") == oConsulta:value("id_user") .and. ;
					oConsulta:value("sogrupo") .and. ::UserGroup() == oUser:value("id_grupo"))
				oRet:MaintInherited(.F.)	// privilégio de manutenção herdado
				oRet:Maintenance(.F.)		// privilégio de manutenção
				oRet:AcessInherited(.T.)	// privilégio de acesso herdado
				oRet:Acess(.F.) 			// privilégio de acesso
				oRet:ExportInherited(.F.) 	// privilégio de exportação herdado
				oRet:Export(.F.) 			// privilégio de exportação			
			endif
			oUser:RestPos()
		endif
	
	// consulta é pré-definida
	else
		
		// privilégio de manutenção da consulta
		if (isNull(acOperType) .OR. acOperType == PRIV_OPER_MANUT)
			cUserPriv := ::checkPrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_MANUT)
			oRet:Maintenance(checkAuthorization(cUserPriv))
			// se o usuário não tiver privilégio estabelecido, procuro pelo privilégio no grupo do usuário
			if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
				cUserPriv := ::checkPrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_MANUT, ::UserGroup())
				oRet:MaintInherited(checkAuthorization(cUserPriv)) 
			endif
		endif
		
		// privilégio de acesso à consulta
		if (isNull(acOperType) .OR. acOperType == PRIV_OPER_ACESS)
			cUserPriv := ::checkPrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_ACESS)
			oRet:Acess(checkAuthorization(cUserPriv))
			// se o usuário não tiver privilégio estabelecido, procuro pelo privilégio no grupo do usuário
			if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
				cUserPriv := ::checkPrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_ACESS, ::UserGroup())
				oRet:AcessInherited(checkAuthorization(cUserPriv))
			endif
		endif
		
		// privilégio de exportar a consulta
		if (isNull(acOperType) .OR. acOperType == PRIV_OPER_EXPORT)
			cUserPriv := ::checkPrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_EXPORT)
			oRet:Export(checkAuthorization(cUserPriv))
			// se o usuário não tiver privilégio estabelecido, procuro pelo privilégio no grupo do usuário
			if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
				cUserPriv := ::checkPrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_EXPORT, ::UserGroup())
				oRet:ExportInherited(checkAuthorization(cUserPriv))
			endif
		endif
	endif
	oConsulta:RestPos()
	
return oRet

/*
--------------------------------------------------------------------------------------
Método responsável por salvar um privilégio genérico para um usuário
Arg: 	anObjID, númerico, contém o id do objeto
		acPriv, caracter, contém o tipo de objeto (ver defines PRIV_OBJ_XXXX)
		acOper, caracter, contém a operação (ver defines PRIV_OPER_XXXX)
		acAuthoriz, caracter, contém o tipo de autorização (ver defines PRIV_AUTH_XXXX)
--------------------------------------------------------------------------------------
*/
method SavePrivilege(anObjID, acPriv, acOper, acAuthoriz) class TDWPrivileges
	
	Local oTablePriv 	:= InitTable(TAB_USER_PRIV)
	Local aValues 		:= 	{	{ "ID_DW", ::DwID() }, ;
								{ "ID_USER", ::UserID() }, ;
								{ "ID_OBJ", anObjID }, ;
								{ "type_obj", acPriv }, ;
								{ "type_oper", acOper }, ;
								{ "type_auth", acAuthoriz } ;
							}
	
	// VERIFIA O PRIVILÉGIO ATUAL DO USUÁRIO
	__DWIDTemp := ::DwID()
	if !empty(anObjID) .AND. !(anObjID == 0)
		oTablePriv:SavePos()
		oTablePriv:Seek(2, { ::UserID(), anObjID, acPriv, acOper })
		if !oTablePriv:EoF() .AND. oTablePriv:value("id_user") == ::UserID() .AND. oTablePriv:value("id_dw") == ::DwID() ;
				.AND. oTablePriv:value("id_obj") == anObjID .AND. oTablePriv:value("type_obj") == acPriv .AND. ;
					oTablePriv:value("type_oper") == acOper
			oTablePriv:Update( { { "type_auth", acAuthoriz } } )
		else
			oTablePriv:Append(aValues)
		endif
		oTablePriv:RestPos()
	else
		oTablePriv:SavePos()
		oTablePriv:Seek(3, { ::UserID(), acPriv, acOper })
		if !oTablePriv:EoF() .AND. oTablePriv:value("id_user") == ::UserID() .AND. oTablePriv:value("id_dw") == ::DwID() ;
				.AND. oTablePriv:value("type_obj") == acPriv .AND. oTablePriv:value("type_oper") == acOper
			oTablePriv:Update( { { "type_auth", acAuthoriz } } )
		else
			oTablePriv:Append(aValues)
		endif
		oTablePriv:RestPos()
	endif
	__DWIDTemp := -1
	
return

/*
--------------------------------------------------------------------------------------
Método responsável por salvar privilégios de DW para este usuário. Atualmente só acesso ao DW
Arg: aoNewPrivOper, objeto, objeto do tipo TDWPrivOper() com os privilégios a serem salvos
--------------------------------------------------------------------------------------
*/
method SaveDwPrivileges(anDwID, aoNewPrivOper) class TDWPrivileges
	
	// recupera os privilégios atuais do usuário para acessar o DW específico
	Local oPrivOper := ::checkDwPrivileges(anDwID)
	
	// salva o privilégio de acesso do DW CASO o usuário já possuia
	// autoriz de acesso DW  OU herdou do grupo               E estou negando essa autoriz
	if ((oPrivOper:Acess() .OR. oPrivOper:AcessInherited()) .AND. !aoNewPrivOper:Acess()) .OR. ; //OU não tinha autoriz e estou concedendo
						((!oPrivOper:Acess() .AND. !oPrivOper:AcessInherited()) .AND. aoNewPrivOper:Acess())
		::SavePrivilege(anDwID, PRIV_OBJ_DW, PRIV_OPER_ACESS, getAuthorization(aoNewPrivOper:Acess()))
	endif
	
return

/*
--------------------------------------------------------------------------------------
Método responsável por salvar privilégios de criação para um usuário. Atualmente só criação de consultas
Arg: aoNewPrivOper, objeto, objeto do tipo TDWPrivOper() com os privilégios a serem salvos
--------------------------------------------------------------------------------------
*/
method SaveCreatePrivileges(aoNewPrivOper) class TDWPrivileges
	
	// recupera os privilégios atuais do usuário para esta consulta
	Local oPrivOper := ::checkCreateQuery()
	
	// salva o privilégio de criação de consultas CASO o usuário já possuia
	// autoriz de criação  OU herdou do grupo                   E estou negando essa autoriz
	if ((oPrivOper:Create() .OR. oPrivOper:CreateInherited()) .AND. !aoNewPrivOper:Create()) .OR. ; //OU não tinha autoriz e estou concedendo
						((!oPrivOper:Create() .AND. !oPrivOper:CreateInherited()) .AND. aoNewPrivOper:Create())
		::SavePrivilege(0, PRIV_OBJ_QUERY, PRIV_OPER_CREATE, getAuthorization(aoNewPrivOper:Create()))
	endif
	
return

/*
--------------------------------------------------------------------------------------
Método responsável por salvar um privilégio para um usuário em um determinada consulta
Arg: 	anQryID, númerico, contém o id da consulta
		aoNewPrivOper, objeto, objeto do tipo TDWPrivOper() com os privilégios a serem salvos
--------------------------------------------------------------------------------------
*/
method SaveQueryPrivileges(anQryID, aoNewPrivOper) class TDWPrivileges
	
	// recupera os privilégios atuais do usuário para esta consulta
	Local oPrivOper := ::checkQueryPrivileges(anQryID)
	
	// salva o privilégio de acesso CASO o usuário já possuia
	// autoriz de acesso  OU herdou do grupo                   E estou negando essa autoriz
	if ((oPrivOper:Acess() .OR. oPrivOper:AcessInherited()) .AND. !aoNewPrivOper:Acess()) .OR. ; //OU não tinha autoriz e estou concedendo
						((!oPrivOper:Acess() .AND. !oPrivOper:AcessInherited()) .AND. aoNewPrivOper:Acess())
		::SavePrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_ACESS, getAuthorization(aoNewPrivOper:Acess()))
	endif
	
	// salva o privilégio de manutenção CASO o usuário já possuia
	// autoriz de manutenção      OU herdou do grupo                   E estou negando essa autoriz
	if ((oPrivOper:Maintenance() .OR. oPrivOper:MaintInherited()) .AND. !aoNewPrivOper:Maintenance()) .OR. ; //OU não tinha autoriz e estou concedendo
						((!oPrivOper:Maintenance() .AND. !oPrivOper:MaintInherited()) .AND. aoNewPrivOper:Maintenance())
		::SavePrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_MANUT, getAuthorization(aoNewPrivOper:Maintenance()))
	endif
	
	// salva o privilégio de exportar CASO o usuário já possuia
	// autoriz de exportar   OU herdou do grupo                 E estou negando essa autoriz
	if ((oPrivOper:Export() .OR. oPrivOper:ExportInherited()) .AND. !aoNewPrivOper:Export()) .OR. ; //OU não tinha autoriz e estou concedendo
						((!oPrivOper:Export() .AND. !oPrivOper:ExportInherited()) .AND. aoNewPrivOper:Export())
		::SavePrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_EXPORT, getAuthorization(aoNewPrivOper:Export()))
	endif
	
return

/*
--------------------------------------------------------------------------------------
Método responsável por salvas os privilégios de um cubo para este usuário
Arg: 	anQryID, númerico, contém o id da consulta
		aoNewPrivOper, objeto, objeto do tipo TDWPrivOper() com os privilégios a serem salvos
--------------------------------------------------------------------------------------
*/
method SaveCubePrivileges(anCubeID, aoNewPrivOper) class TDWPrivileges
	
	// recupera os privilégios atuais do usuário para esta consulta
	Local oPrivOper := ::checkCubePrivileges(anCubeID)
	
	// salva o privilégio de acesso CASO o usuário já possuia
	// autoriz de acesso  OU herdou do grupo                   E estou negando essa autoriz
	if ((oPrivOper:Acess() .OR. oPrivOper:AcessInherited()) .AND. !aoNewPrivOper:Acess()) .OR. ; //OU não tinha autoriz e estou concedendo
						((!oPrivOper:Acess() .AND. !oPrivOper:AcessInherited()) .AND. aoNewPrivOper:Acess())
		::SavePrivilege(anCubeID, PRIV_OBJ_CUBE, PRIV_OPER_ACESS, getAuthorization(aoNewPrivOper:Acess()))
	endif
	
	// salva o privilégio de manutenção CASO o usuário já possuia
	// autoriz de manutenção      OU herdou do grupo                   E estou negando essa autoriz
	if ((oPrivOper:Maintenance() .OR. oPrivOper:MaintInherited()) .AND. !aoNewPrivOper:Maintenance()) .OR. ; //OU não tinha autoriz e estou concedendo
						((!oPrivOper:Maintenance() .AND. !oPrivOper:MaintInherited()) .AND. aoNewPrivOper:Maintenance())
		::SavePrivilege(anCubeID, PRIV_OBJ_CUBE, PRIV_OPER_MANUT, getAuthorization(aoNewPrivOper:Maintenance()))
	endif
	
return

/*
--------------------------------------------------------------------------------------
Método responsável por redefinir todos os privilégios deste usuário com os privilégios do grupo do usuário
Arg:
--------------------------------------------------------------------------------------
*/
method ResetAllPrivileges() class TDWPrivileges
	
	Local oTablePriv := InitTable(TAB_USER_PRIV)
	
	__DWIDTemp := ::DwID()
	if ::UserHaveGroup()
		oTablePriv:SavePos()
		oTablePriv:Seek(2, { ::UserID() })
		while !oTablePriv:EoF() .AND. oTablePriv:value("id_user") == ::UserID()
			oTablePriv:Delete()
			oTablePriv:_Next()
		enddo
		oTablePriv:RestPos()
	endif
	__DWIDTemp := -1
	
return

/*
--------------------------------------------------------------------------------------
Função responsável por verificar se o usuário tem ou não autorização
Arg: acPrivilege, caracter, contém o tipo de autorização do usuário
Ret: .T. se não tiver autorização, .F. em outra situação
--------------------------------------------------------------------------------------
*/
static function checkAuthorization(acPrivilege)
return iif (acPrivilege == PRIV_AUTH_AUTHOR, .T., .F.)

/*
--------------------------------------------------------------------------------------
Função responsável por recuperar o tipo de autorização
Arg: alPrivilege, lógico, contém o tipo de autorização do usuário
Ret: PRIV_AUTH_AUTHOR caso seja .T., PRIV_AUTH_DENIED em outra situação
--------------------------------------------------------------------------------------
*/
static function getAuthorization(alPrivilege)
return iif (alPrivilege, PRIV_AUTH_AUTHOR, PRIV_AUTH_DENIED)