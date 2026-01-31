#include 'totvs.ch'

/*/{Protheus.doc} VEChecklistClass
    Classe para ....
    
    @type class
    @author Bruno Forcato
    @since 05/12/2024
/*/
Class VEChecklistClass from VERegistroSql
    Public Method New()
    Public Method BeforeCreate()
    Public Method Validate()
    Public Method ToggleActive()
EndClass

/*/{Protheus.doc} New
    Construtor Simples

    @type method
    @author Bruno Forcato
    @since 05/12/2024
/*/
Method New() Class VEChecklistClass

    _Super:New('VRX')
    ::PermiteAssign({;
        "VRX_CODINT", "VRX_CODIGO", "VRX_CODUSR", "VRX_AGRUP","VRX_DATINC","VRX_ATUAL",; 
        "VRX_DADOS", "VRX_HASH", "VRX_TABELA", "VRX_FILIAL";
    })
    ::AddFields({;
        "R_E_C_N_O_","VRX_TABELA","VRX_CODIGO","VRX_CODINT", "VRX_DADOS",;
        "VRX_HASH","VRX_CODUSR","VRX_AGRUP", "VRX_DATINC", "VRX_ATUAL", "VRX_FILIAL";
    })
    ::AddFieldsMemo({'VRX_DADOS'})
    
Return SELF

/*/{Protheus.doc} BeforeCreate
	Este callback sera chamado antes de salvar o objeto 
	independentemente se ele e novo ou nao
	
	@type function
	@author Bruno Forcato
	@since 06/12/2024
/*/
method BeforeCreate() Class VEChecklistClass
    if ! empty(::Get("VRX_CODINT")) .AND. ! empty(::Get("VRX_AGRUP"))
        cQuery := "UPDATE " + RetSqlName("VRX") +;
            " SET VRX_ATUAL = '0'" +;
            " WHERE (VRX_ATUAL = '1' OR VRX_ATUAL = '2') AND VRX_CODINT =" + ::Get("VRX_CODINT") +;
            " AND VRX_AGRUP = " + ::Get("VRX_AGRUP")
        TcSqlExec(cQuery)
    endif

    ::Set("VRX_CODIGO", FwGetSXENum('VRX', 'VRX_CODIGO','VRX_1',1))
    ConfirmSx8()
    ::Set("VRX_CODINT", IIF(!empty(::Get('VRX_CODINT')) , ::Get('VRX_CODINT'), FwGetSXENum('VRX', 'VRX_CODINT','VRX_2',2)))
    ConfirmSx8()
    ::Set("VRX_FILIAL", xFilial('VRX'))
       
    ::Set("VRX_TABELA", '093')
    ::Set("VRX_ATUAL", '1')
    ::Set("VRX_CODUSR", IIF(!empty(::Get("VRX_CODUSR")), ::Get("VRX_CODUSR") ,__cUserId))
return _Super:BeforeCreate()


/*/{Protheus.doc} Validate
	Validate
	
	@type function
	@author Bruno Forcato
	@since 27/12/2024
/*/
method Validate() Class VEChecklistClass
	self:ValidaTamanho('VRX_FILIAL', len(alltrim(xFilial('VRX'))))

	if Empty(self:Get('VRX_AGRUP'))
		self:AddError('VRX_AGRUP', 'Grupo não digitado')
	endif

return _Super:Validate()

/*/{Protheus.doc} ToggleActive
	alterna o estado de ativo do item
	
	@type function
	@author Bruno Forcato
	@since 20/01/2025
/*/
method ToggleActive() Class VEChecklistClass
	dbSelectarea('VRX')
    dbSetOrder(1)
	dbSeek(xFilial('VRX')+::Get('VRX_CODIGO')+'093')
    
    BEGIN TRANSACTION
    reclock('VRX', .F.)

    if VRX->VRX_ATUAL == '1'
        VRX->VRX_ATUAL := '2'
    else 
        VRX->VRX_ATUAL := '1'
    endif
    self:Set('VRX_ATUAL', VRX->VRX_ATUAL)

    MsUnlock()
    END TRANSACTION
return .t.
