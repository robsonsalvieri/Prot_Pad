#include 'totvs.ch'

/*/{Protheus.doc} VEChecklistResponseClass
    Classe para ....
    
    @type class
    @author Bruno Forcato
    @since 06/12/2024
/*/
Class VEChecklistResponseClass from VERegistroSql
    Public Method New()
    Public Method BeforeCreate()
    Public Method Validate()
EndClass

/*/{Protheus.doc} New
    Construtor Simples

    @type method
    @author Bruno Forcato
    @since 06/12/2024
/*/
Method New() Class VEChecklistResponseClass

    _Super:New('VRZ')
    ::AddFields({;
        "R_E_C_N_O_","VRZ_FILIAL","VRZ_CODIGO","VRZ_CODUSR","VRZ_CODVRX",;
        "VRZ_DADOS","VRZ_DATINC", "VRX.VRX_DADOS AS VRX_DADOS", "VRZ_CODINT" ;
    })
    ::PermiteAssign({;
        "VRZ_FILIAL","VRZ_CODIGO","VRZ_CODUSR","VRZ_CODVRX",;
        "VRZ_DADOS","VRZ_DATINC","VRZ_DATALT", "VRZ_CODINT";
    })
    ::AddFieldsMemo({'VRZ_DADOS'})
    
    // relacoes
    ::HasOne('VEChecklistClass', {{{||xFilial('VRX')}, 'VRX.VRX_FILIAL'}, {'VRX.VRX_CODIGO', 'VRZ_CODVRX'}})
Return SELF

/*/{Protheus.doc} BeforeCreate
	Este callback sera chamado antes de salvar o objeto 
	independentemente se ele e novo ou nao
	
	@type function
	@author Bruno Forcato
	@since 10/12/2024
/*/
method BeforeCreate() Class VEChecklistResponseClass
    ::Set("VRZ_CODIGO", GETSXENUM('VRZ', 'VRZ_CODIGO'))
    ConfirmSx8()
    ::Set("VRZ_FILIAL", xFilial('VRZ'))
    ::Set("VRZ_CODUSR", IIF(!empty(::Get("VRX_CODUSR")), ::Get("VRX_CODUSR") ,__cUserId))

return _Super:BeforeCreate()

/*/{Protheus.doc} Validate
	Validate
	
	@type function
	@author Bruno Forcato
	@since 27/12/2024
/*/
method Validate() Class VEChecklistResponseClass
	self:ValidaTamanho('VRZ_FILIAL', len(alltrim(xFilial('VRZ'))))

	if Empty(self:Get('VRZ_CODVRX'))
		self:AddError('VRZ_CODVRX', 'Checklist é obrigatório')
	endif

return _Super:Validate()