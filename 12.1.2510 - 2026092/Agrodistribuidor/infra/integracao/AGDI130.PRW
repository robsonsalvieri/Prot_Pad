#Include "agdi130.ch"
#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} AGDI130
Ponto de Chamada no cadastro de safras do agrodistribuidor.
@type function
@version 12
@author jean.schulze
@since 20/05/2026
@param oModel, object, modelo de dados do cadastro de safras
@return variant, retorna .F. se deve impedir processo de cadastro de safras
/*/
Function AGDI130(oModel)
	Local lRet := .T.

	If SUPERGETMV("MV_SIGAAGD", .F., .F.) 
		if Empty(oModel:GetValue('NJUUNICO', 'NJU_ANOSAF')) .or. Empty(oModel:GetValue('NJUUNICO','NJU_DTINI')) .or. Empty(oModel:GetValue('NJUUNICO', 'NJU_DTFIM' ))
			Help( , ,STR0002, , STR0001, 1, 0 ) //Ajuda - STR0001                                                                                                                                                                                                                                                                                                                                                                                                                                                                     //"O campo de Ano, Data Início e Data Fim deve ser preenchido corretamente." //"Ajuda"
			lRet := .F.
		EndIf
	EndIf
Return lRet
