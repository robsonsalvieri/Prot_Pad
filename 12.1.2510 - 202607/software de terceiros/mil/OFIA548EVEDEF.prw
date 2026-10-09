#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "OFIA548EVDEF.CH"

/*/{Protheus.doc} OFIA548EVDEF 
    Classe de eventos do OFIA548 - Diário de oficina
    @author Renan Migliaris
    @since 02/12/2025
    @version version
    /*/
Class OFIA548EVDEF from FwModelEvent
	data isAuto

    method new() constructor
    method modelPosVld(oModel, cModelId)
	method fieldPreVld(oSubModel, cModelID, cAction, cId, xValue)
	method gridPreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)

    //Métodos que irão realizar validações da rotina MVC
	method carregaChaInt(xValue)
    method _validacaoDaModelMVC(oModel)
	method _buscaVeiculo(oSubModel, cId, xValue)
	method _carregaDadosDoVeiculo(oSubModel)
    method _recuperaChaIntDoVeiculo(oSubModel, xValue)
	method _posVeiEvDef(cCampo, cValor)
	method _setaVzwAberto(oSubModel)
EndClass

/*/{Protheus.doc} new
    Método construtor da classe
    @author Renan Migliaris
    @since 02/12/2025
    @version version
    /*/
Method new(isAuto) class OFIA548EVDEF
	default isAuto := .f.
	self:isAuto := isAuto
Return .t.

/*/{Protheus.doc} modelPosVld
    Validaçõa do modelo
    @author Renan Migliaris
    @since 02/12/2025
    /*/
Method modelPosVld(oModel, cModelId) class OFIA548EVDEF
Return self:_validacaoDaModelMVC(oModel)

/*/{Protheus.doc} modelPreVld
	Pré Validação da Model
	@author Renan Migliaris
	@since 04/12/2025
	/*/
Method fieldPreVld(oSubModel, cModelID, cAction, cId, xValue) class OFIA548EVDEF
    // Se estiver em ExecAuto, pula validação de campo
    if self:isAuto
        return .T.
    endif

    if cId == "VZW_CHASSI" .or.  cId == "VZW_PLAVEI" .or. cId == "VZW_CHAINT"
	    return self:_buscaVeiculo(oSubModel, cId, xValue)
    endif

	if cId == "VZW_NUMORC"
		return OA548003J_Exist("VS1", " VS1_NUMORC = '"+oSubModel:GetValue('VZW_NUMORC')+"' ")
	elseif cId == 'VZW_NUMOSV'
		return OA548003J_Exist("VO1", " VO1_NUMOSV = '"+oSubModel:GetValue('VZW_NUMOSV')+"' ")
	elseif  cId == 'VZW_NUMAGE
		return OA548003J_Exist("VSO", " VSO_NUMIDE = '"+oSubModel:GetValue('VZW_NUMAGE')+"' ")
	endif
Return .t.

/*/{Protheus.doc} gridPreVld
	Validação da grid
	@author Renan Migliaris
	@since 05/12/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	/*/
Method gridPreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) class OFIA548EVDEF
	if cId == "VZY_ORIGEM"
        return self:_recuperaChaIntDoVeiculo(oSubModel, xValue)
    endif
Return .t.

/*/{Protheus.doc} new
    Método que irá fazer a validação do modelo
    @author Renan Migliaris
    @since 02/12/2025
    @version version
    /*/
method _validacaoDaModelMVC(oModel) class OFIA548EVDEF
    local lRet := .T.
	local cErros := STR0002 + chr(13) + chr(10) //"Erros de validação:"
    local oSubMod01 := oModel:GetModel('FRM01')
    local cChassi := ""
    local cPlaca := ""
    local cCodigo := ""

    default cModelId := ''

	cChassi := oSubMod01:GetValue("VZW_CHASSI")
	cPlaca  := oSubMod01:GetValue("VZW_PLAVEI")
	cCodigo := oSubMod01:GetValue("VZW_CODIGO")

	if !Empty(cChassi) .AND. !OA548003J_Exist("VV1", " VV1_CHASSI = '"+cChassi+"' ")
		cErros += STR0001 + chr(13) + chr(10) //"Chassi inválido/inexistente, se o veículo não tem cadastro basta digitar somente a placa."
		lRet := .F.
	endif

	if !Empty(cPlaca) .AND. !OA548003J_Exist("VV1", " VV1_PLAVEI = '"+cPlaca+"' ")
			lRet := .F.
			if !Empty(cPlaca) .AND. Empty(cChassi) // blz nao existir os dados mas ter placa, pois o veiculo sera cadastrado posteriormente
				lRet := .T.
			else
				cErros := STR0003 + chr(13) + chr(10) //"Placa não condiz com o chassi"
			endif
	endif

	if Empty(cPlaca) .AND. Empty(cChassi)
		cErros := STR0004 + chr(13) + chr(10) //"Nenhuma identificação de veículo digitada, digite ao menos a placa."
		lRet := .F.
	endif

	if oModel:GetOperation() <> 5
		self:_setaVzwAberto(@oSubMod01)
	endif
	
	if !lRet
		FMX_HELP("OFIA548", cErros)
	endif

return lRet

method _buscaVeiculo(oSubModel, cId, xValue) class OFIA548EVDEF
	if cId == "VZW_CHASSI"
		cChassi := oSubModel:GetValue('VZW_CHASSI')
		if FG_POSVEI("cChassi")
			self:_carregaDadosDoVeiculo(oSubModel)
		endif
	else
		if self:_posVeiEvDef(cId, oSubModel:GetValue(cId))
			self:_carregaDadosDoVeiculo(oSubModel, cId, xValue)
		else
			if cId == "VZW_PLAVEI" .AND. Empty(oSubModel:GetValue("VZW_CHASSI")) .AND. Empty(oSubModel:GetValue("VZW_CHAINT"))
				return .T.
			elseif cId == "VZW_PLAVEI" .and. !Empty(oSubModel:GetValue('VZW_CHASSI')) .and. !Empty(oSubModel:GetValue('VZW_PLAVEI'))
				return .t.
			else
				return Empty(oSubModel:GetValue(cId)) // se tiver vazio ok, não pode travar o campo
			endif
		endif
	endif
return .t.


/*/{Protheus.doc} _carregaDadosDoVeiculo
	Carrega os dados do veículo na model
	@author Renan Migliaris
	@since 04/12/2025
	/*/
Method _carregaDadosDoVeiculo(oSubModel, cId, xValue) class OFIA548EVDEF
	default cId := ""
	default xValue := ""
	if self:_posVeiEvDef(cId, xValue)
		oSubModel:LoadValue("VZW_CHASSI", VV1->VV1_CHASSI)
		oSubModel:LoadValue("VZW_PLAVEI", VV1->VV1_PLAVEI)
		oSubModel:LoadValue("VZW_CHAINT", VV1->VV1_CHAINT)
		
		OA548001J_DadosVeiCompl("VZW_DESMAR")
		OA548001J_DadosVeiCompl("VZW_DESMOD")
		OA548001J_DadosVeiCompl("VZW_DESCOR")

		oSubModel:LoadValue("VZW_DESMAR", VE1->VE1_DESMAR)
		oSubModel:LoadValue("VZW_DESCOR", VVC->VVC_DESCRI)
		oSubModel:LoadValue("VZW_DESMOD", VV2->VV2_DESMOD)
	endif
Return


/*/{Protheus.doc} _recuperaChaIntDoVeiculo
    Busca o ChaInt do veiculo
    @author Renan Migliaris
    @since 04/12/2025
    /*/
Method _recuperaChaIntDoVeiculo(oSubModel, xValue) class OFIA548EVDEF
    local cDesc := ''

    dbSelectArea("VZW")

	If Empty(xValue)
		oSubModel:LoadValue("VZY_DESORI", "")
		Return .t.
	EndIf

	If OFIOA560VL( "049" , xValue , @cDesc , .f. )
		oSubModel:LoadValue("VZY_DESORI", AllTrim(cDesc))
	else
		oSubModel:LoadValue("VZY_DESORI", "")
		Return .f.
	EndIf
Return .t.

/*/{Protheus.doc} methodName
	Posiciona o registro pelo EVEDEF
	@author Renan Migliaris
	@since 11/12/2025
	/*/
Method _posVeiEvDef(cCampo, cValor) class OFIA548EVDEF
	local lret := .f.
	cCampo := STRTRAN(cCampo, "VZW", "VV1")
	if !Empty(cValor) .and. OA548003J_Exist("VV1", " " + cCampo + " = '" + cValor + "' ")
		if "CHAINT" $ cCampo
			VV1->(dbSetOrder(1))
		elseif "CHASSI" $ cCampo
			VV1->(dbSetOrder(2))
		else
			VV1->(dbSetOrder(9))
		endif
		return VV1->(dbSeek(xfilial('VV1')+cValor))
	endif
Return lRet

/*/{Protheus.doc} _setaVzwAberto(oSubModel)
	Caso não esteja na operação de deleção ele vai vazer o load do VZW_ABERTO
	@author Renan Migliaris
	@since 12/12/2025
	/*/
Method _setaVzwAberto(oSubModel) class OFIA548EVDEF
	if Empty(oSubModel:GetValue("VZW_DATFEC"))
		oSubModel:LoadValue("VZW_ABERTO", .t.)
	else
		oSubModel:LoadValue("VZW_ABERTO", .f.)
	endif
Return

/*/{Protheus.doc} carregaChaInt
	Vai carregar o chaint do veículo a partir da trigger adicionada no vzw_chassi
	@author Renan Migliaris
	@since 15/12/2025
	/*/
Method carregaChaInt(xValue) class OFIA548EVDEF
	local aArea := FwGetArea()
	local cRetorno := ''

	dbSelectArea("VV1")
	dbSetOrder(2)
	if dbSeek(xfilial('VV1')+xValue)
	    cRetorno := VV1->VV1_CHAINT
	endif

	fwRestArea(aArea)
Return cRetorno