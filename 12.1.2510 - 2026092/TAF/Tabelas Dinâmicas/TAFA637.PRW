#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA637.CH"

/*----------------------------------------------------------------------
{Protheus.doc} TAFA637
Cadastro MVC de Dere - Atividades de Serviços Financeiros, Plano de Saúde e Concurso Prognóstico

Tabela 21 – Atividades de Serviços Financeiros

Versão 1.1.0 | 22 de junho de 2026
	Aumento de tamanho do código da atividade de 1 para 3, conforme schema evento 1001 ( value="[0-9]{2}[A-Z] )
	T7P_CODATI alterado de C(2) para C(3) para comportar códigos alfanuméricos oficiais (ex: 01A, 06B, 09Z)
	Autocontidas atualizadas com códigos oficiais do Anexo I v1.1.0 da LC 214/2025
	Tabela 21 reestruturada: leasing separado em 06A/06B, seguros em 11A/11B, previdência em 13A/13B,
	arranjos de pagamento com novos subtipos 09C/09D/09E/09F/09Z

@author Carlos Pister
@since 06/11/2025
@version 1.0
----------------------------------------------------------------------*/
Function TAFA637()
	Local oBrowse := FWmBrowse():New()

	If AliasIndic("T7P")
        oBrowse:SetDescription(STR0001) //'Dere - Atividades de Serviços Financeiros, Plano de Saúde e Concurso Prognóstico'
        oBrowse:SetAlias('T7P')
        oBrowse:SetMenuDef('TAFA637')
        oBrowse:Activate()
    Else
        MsgAlert(STR0002)   //"Tabela T7P não existe." 
    EndIf

Return

/*----------------------------------------------------------------------
{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Carlos Pister	
@since 02/03/2026
@version 1.0
----------------------------------------------------------------------*/
Static Function ModelDef()
	Local oStructT7P := FWFormStruct(1, 'T7P')
	Local oModel     := MPFormModel():New('TAFA637')

	oModel:AddFields('MODEL_T7P',, oStructT7P)
	oModel:GetModel('MODEL_T7P'):SetPrimaryKey({'T7P_FILIAL','T7P_ID'})
Return oModel

/*----------------------------------------------------------------------
/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Carlos Pister
@since 02/03/2026
@version 1.0
----------------------------------------------------------------------*/
Static Function ViewDef()
	Local oModel     := FWLoadModel('TAFA637')
	Local oStructT7P := FWFormStruct(2, 'T7P')
	Local oView      := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_T7P', oStructT7P, 'MODEL_T7P')

	oView:EnableTitleView('VIEW_T7P',STR0001) //'Dere -Atividades de Serviços Financeiros, Plano de Saúde e Concurso Prognóstico'   
	oView:CreateHorizontalBox('FIELDST7P', 100)
	oView:SetOwnerView('VIEW_T7P', 'FIELDST7P')

	oStructT7P:RemoveField('T7P_ID')

Return oView 

/*----------------------------------------------------------------------
/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Carlos Pister
@since 02/03/2026
@version 1.0
----------------------------------------------------------------------*/
Static Function MenuDef()
Return XFUNMnuTAF('TAFA637',,,.T.)

/*-------------------------------------------------------------------
{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

Versão 1.1.0:
	- T7P_CODATI alterado de C(2) para C(3): códigos agora são alfanuméricos (ex: 01A, 06B)
	- Tabela 21 reestruturada conforme Anexo I v1.1.0 da LC 214/2025:
	  * Leasing dividido em 06A (operacional) e 06B (financeiro)
	  * Seguros divididos em 11A (ramos elementares/pessoas sem sobrevivência) e 11B (com sobrevivência)
	  * Previdência dividida em 13A (aberta) e 13B (fechada)
	  * Arranjos de pagamento: novos subtipos 09C, 09D, 09E, 09F, 09Z
	  * Códigos numéricos simples substituídos por códigos alfanuméricos oficiais
	- Tabelas 31 e 41 com códigos alfanuméricos oficiais

@Param	nVerEmp	- Versão corrente na empresa
		nVerAtu	- Versão atual ( passado como referência )

@Return	aRet - Array com estrutura de campos e conteúdo da tabela

@Author	 Carlos Pister
@Since	 02/03/2026
@Version 1.0
-------------------------------------------------------------------*/
Static Function FAtuCont(nVerEmp, nVerAtu)

	Local aHeader := {}
	Local aBody	  := {}
	Local aRet	  := {}

	nVerAtu := 1033.95

	If nVerEmp < nVerAtu
		aAdd(aHeader, 'T7P_FILIAL')
		aAdd(aHeader, 'T7P_ID')
		aAdd(aHeader, 'T7P_TPATIV')
		aAdd(aHeader, 'T7P_CODATI')
		aAdd(aHeader, 'T7P_DESCAT')
		aAdd(aHeader, 'T7P_ALTCON')

		//Tabela 21 – Atividades de Serviços Financeiros (Anexo I v1.1.0 - LC 214/2025)
		aAdd(aBody,{"","1e37fc5c-c9d6-df92-0234-a43f79cf3fc6","1","01A","Operações de crédito, incluídas as operações de captação e repasse, adiantamento, empréstimo, financiamento, desconto de títulos, recuperação de créditos e prestação de garantias, com exceção da securitização, faturização e liquidação antecipada de recebíveis de arranjos de pagamento, de que tratam, respectivamente, os incisos IV, V e IX do caput do art. 182 da Lei Complementar nº 214/2025",1033.95})
		aAdd(aBody,{"","50d79e11-1ba6-cacf-e8c2-7ad8a9f636c7","1","02A","Operações de câmbio, inclusive quando cobrado por tarifa ou comissão",1033.95})
		aAdd(aBody,{"","17255c66-ef20-9b35-108e-99f23c996837","1","03A","Operações com títulos e valores mobiliários, incluídas a aquisição, negociação, liquidação, custódia, corretagem, distribuição e outras formas de intermediação, bem como a atividade de assessor de investimento e de consultor de valores mobiliários",1033.95})
		aAdd(aBody,{"","b0f9fc00-2968-7770-e44a-8fab0b52f08b","1","04A","Operações de securitização",1033.95})
		aAdd(aBody,{"","0d6d0941-004a-4562-4a2f-b968e37ee864","1","05A","Operações de faturização (factoring)",1033.95})
		aAdd(aBody,{"","f96031c4-8ba4-420d-2ce6-3b9df79d595b","1","06A","Arrendamento mercantil (leasing) operacional, de quaisquer bens, incluídos a cessão de direitos e obrigações, substituição de garantia, alteração, cancelamento e registro de contrato e demais serviços relacionados ao arrendamento mercantil",1033.95})
		aAdd(aBody,{"","8e7d7b02-293f-ba37-6519-5a377fc77ecf","1","06B","Arrendamento mercantil (leasing) financeiro, de quaisquer bens, incluídos a cessão de direitos e obrigações, substituição de garantia, alteração, cancelamento e registro de contrato e demais serviços relacionados ao arrendamento mercantil",1033.95})
		aAdd(aBody,{"","84b31465-06f6-6d18-a310-c435a787f04e","1","07A","Administração de consórcio",1033.95})
		aAdd(aBody,{"","3f36d955-79c2-4959-bba1-e51df4ab613a","1","08A","Gestão e administração de recursos, inclusive de fundos de investimento",1033.95})
		aAdd(aBody,{"","16d231e6-5f11-9819-07c9-ba2aa46f628d","1","09A","Arranjos de pagamento - credenciadora ou subcredenciadora",1033.95})
		aAdd(aBody,{"","de965b21-6a85-efe9-2955-92eb2eee218d","1","09B","Arranjos de pagamento - instituidor do arranjo (bandeiras)",1033.95})
		aAdd(aBody,{"","02b9b981-4187-c190-cdc3-0d2a5490b359","1","09C","Arranjos de pagamento - emissor de cartões",1033.95})
		aAdd(aBody,{"","46e663b8-1ee5-06e3-86e9-3bebd5a270c8","1","09D","Arranjos de pagamento - administração de programas de fidelização",1033.95})
		aAdd(aBody,{"","8068a3f9-6b76-d08b-d527-6534f1882596","1","09E","Arranjos de pagamento - programa de fidelidade próprio",1033.95})
		aAdd(aBody,{"","a6ae2a4e-f193-e94c-6148-41f6135b4e9c","1","09F","Arranjos de pagamento - vale refeição, vale alimentação ou vale transporte",1033.95})
		aAdd(aBody,{"","d87c4d37-8a1b-073d-8d8b-3c7517f21534","1","09Z","Arranjos de pagamento - outros tipos de arranjo",1033.95})
		aAdd(aBody,{"","7c295605-569f-3441-ec1b-1e2e286d1957","1","10A","Atividades de entidades administradoras de mercados organizados, infraestruturas de mercado e depositárias centrais",1033.95})
		aAdd(aBody,{"","a285ed37-8dcb-9840-9ce8-1784c1bf4ce2","1","11A","Operações de seguros de ramos elementares e seguros de pessoas sem cobertura por sobrevivência, com exceção dos seguros de saúde de que trata o Capítulo III do Título V da Lei Complementar nº 214/2025",1033.95})
		aAdd(aBody,{"","fff3a562-3fe4-95a5-1ade-19bb936a5d73","1","11B","Operações de seguros de pessoas com cobertura por sobrevivência, com exceção dos seguros de saúde de que trata o Capítulo III do Título V da Lei Complementar nº 214/2025",1033.95})
		aAdd(aBody,{"","e1802226-3520-b572-6f76-f4a3b2b8f2dd","1","12A","Operações de resseguros",1033.95})
		aAdd(aBody,{"","c6e4b015-30d4-f28b-cd89-54a68c2d3d95","1","13A","Previdência privada, composta de operações de administração e gestão da previdência complementar aberta",1033.95})
		aAdd(aBody,{"","6fa432b3-8c52-b118-f308-f21aa76fecae","1","13B","Previdência privada, composta de operações de administração e gestão da previdência complementar fechada",1033.95})
		aAdd(aBody,{"","4058ef1f-a45c-fe7c-6672-018df85a9148","1","14A","Operações de capitalização",1033.95})
		aAdd(aBody,{"","5a5f1014-d759-a339-907f-c7a976d27d17","1","15A","Intermediação de consórcios, seguros, resseguros, previdência complementar e capitalização",1033.95})
		aAdd(aBody,{"","1e0d60c2-4b05-a794-f5a9-690f8b3c674f","1","16A","Serviços de ativos virtuais",1033.95})
		aAdd(aBody,{"","c6aa09cc-d82b-b932-c704-6f390e824e0a","1","17A","Operações de proteção patrimonial mutualista",1033.95})

		//Tabela 31 – Atividades de Planos de Assistência à Saúde (Anexo I v1.1.0)
		aAdd(aBody,{"","cb9155a6-438f-eff9-4127-6e650ffd7731","2","01A","Seguradoras de saúde",1033.95})
		aAdd(aBody,{"","0dae0196-7004-ae12-5725-08ece917624e","2","02A","Administradoras de benefícios",1033.95})
		aAdd(aBody,{"","c7234df3-e979-b9e0-ae82-025ae691bebc","2","03A","Cooperativas operadoras de planos de saúde",1033.95})
		aAdd(aBody,{"","2c18aee3-66ac-09b1-09f1-d77f87d45680","2","04A","Cooperativas de seguro saúde",1033.95})
		aAdd(aBody,{"","83b6cec4-8d8e-f08f-4239-04904b3725e1","2","05A","Demais operadoras de planos de assistência à saúde",1033.95})
		aAdd(aBody,{"","bc0a23dd-edd0-b940-d02a-59518c2a4cac","2","06A","Plano de assistência funerária",1033.95})
		aAdd(aBody,{"","43e3f17b-37cf-b02f-7556-01d3f7f3b978","2","07A","Plano de assistência à saúde de animais",1033.95})
		aAdd(aBody,{"","bcd17841-31d8-d1c1-f715-49ed672dfb5f","2","08A","Plano de assistência à saúde modalidade autogestão",1033.95})

		//Tabela 41 – Atividades de Concursos de Prognósticos (Anexo I v1.1.0)
		aAdd(aBody,{"","c6c68ff0-bf40-04ee-3a2c-9a5bcd8f2168","3","01A","Apostas esportivas",1033.95})
		aAdd(aBody,{"","5c8bcc1d-bc65-5e74-de5a-445528cc91e7","3","01B","Apostas de turfe",1033.95})
		aAdd(aBody,{"","8b02cd5a-243f-adb5-71c7-03595172488e","3","01C","Modalidades lotéricas",1033.95})
		aAdd(aBody,{"","6afe9bff-c802-49e7-1892-fe95e051e61b","3","01D","Jogos online (iGaming)",1033.95})
		aAdd(aBody,{"","2fc7af41-7aa5-cc10-73a9-3d99d1b06179","3","01E","Fantasy sport",1033.95})
		aAdd(aBody,{"","95bf6062-2651-ee02-ab7a-dfe5a9faae5b","3","01F","Sweepstakes",1033.95})
		aAdd(aBody,{"","e9139691-367f-a961-3da9-db6dfa715558","3","01G","Demais apostas",1033.95})

		aAdd(aRet, {aHeader, aBody})
	EndIf

Return(aRet)
