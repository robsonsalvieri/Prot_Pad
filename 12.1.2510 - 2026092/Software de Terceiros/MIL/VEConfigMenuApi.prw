#Include "TOTVS.ch"

/*/{Protheus.doc} VEConfigMenuAPI
	CLASSE PARA REGRA DE NEGOCIO DE CONFIGURACAO DO USUARIO                                             
	@author Bruno Forcato
	@since 09/04/2025
	@version version
/*/
Class VEConfigMenuAPI from LongNameClass
    Data cUser
    Data aMenus
    Data aMenusAccess

    Method New(cUser) Constructor
    Method SetMenus(aMenus)
    Method SetMenusAccess()
    Method HasAccess(cMenu)
EndClass

/*/{Protheus.doc} New
	Methodo construtor da classe                                             
	@author Bruno Forcato
	@since 09/04/2025
/*/
Method New(cUser) class VEConfigMenuAPI
    ::cUser := cUser
    ::aMenus := {}
    ::aMenusAccess := {}
Return Self

/*/{Protheus.doc} SetMenus
	Define os menus do usuário
    @param aMenus Array de menus                                         
	@author Bruno Forcato
	@since 09/04/2025
/*/
Method SetMenus(aMenus) class VEConfigMenuAPI
    If ValType(aMenus) == "A"
        ::aMenus := aMenus
        ::SetMenusAccess()
    Else
        ::aMenus := {}
    EndIf
Return

/*/{Protheus.doc} SetMenusAccess
	Define as permissões de acesso aos menus do usuário                                        
	@author Bruno Forcato
	@since 09/04/2025
/*/
Method SetMenusAccess() class VEConfigMenuAPI
    local i := 0
    ::aMenusAccess := {}
    If len(::aMenus) > 0
        For i := 1 To len(::aMenus)
            If MPUserHasAccess(::aMenus[i],1,,.F.)
                aAdd(::aMenusAccess, ::aMenus[i])
            endif
        next
    EndIf
Return
