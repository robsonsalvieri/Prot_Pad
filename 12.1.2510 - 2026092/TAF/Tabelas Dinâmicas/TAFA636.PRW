#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 

/*----------------------------------------------------------------------
{Protheus.doc} TAFA636
Cadastro MVC de Códigos de Class Trib e CST para IBS e CBS

@author Rafael de Paula Leme
@since 06/11/2025
@version 1.0
----------------------------------------------------------------------*/
Function TAFA636()
	Local oBrowse := FWmBrowse():New()

	oBrowse:SetAlias('T5R')
	oBrowse:SetDescription('Códigos de CST e CCT para IBS e CBS') //'Códigos de CST e CCT para IBS e CBS'
	oBrowse:SetMenuDef('TAFA636')

	oBrowse:Activate()

Return

/*----------------------------------------------------------------------
{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rafael de Paula Leme	
@since 05/11/2025
@version 1.0
----------------------------------------------------------------------*/
Static Function ModelDef()
	Local oStructT5R := FWFormStruct(1, 'T5R')
	Local oModel     := MPFormModel():New('TAFA636')

	oModel:AddFields('MODEL_T5R',, oStructT5R)
	oModel:GetModel('MODEL_T5R'):SetPrimaryKey({'T5R_FILIAL','T5R_ID'})

Return oModel

/*----------------------------------------------------------------------
/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rafael de Paula Leme
@since 05/11/2025
@version 1.0
----------------------------------------------------------------------*/
Static Function ViewDef()
	Local oModel     := FWLoadModel('TAFA636')
	Local oStructT5R := FWFormStruct(2, 'T5R')
	Local oView      := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_T5R', oStructT5R, 'MODEL_T5R')

	oView:EnableTitleView('VIEW_T5R','Códigos de CST e CCT para IBS e CBS') //'Códigos de Class. Trib. e CST para IBS e CBS'   
	oView:CreateHorizontalBox('FIELDST5R', 100)
	oView:SetOwnerView('VIEW_T5R', 'FIELDST5R')

	oStructT5R:RemoveField('T5R_ID')

Return oView 

/*----------------------------------------------------------------------
/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rafael de Paula Leme
@since 05/11/2025
@version 1.0
----------------------------------------------------------------------*/
Static Function MenuDef()
Return XFUNMnuTAF('TAFA636',,,.T.)

/*-------------------------------------------------------------------
{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param	nVerEmp	- Versão corrente na empresa
		nVerAtu	- Versão atual ( passado como referência )
'
@Return	aRet - Array com estrutura de campos e conteúdo da tabela

@Author	 Rafael de Paula Leme
@Since	 05/11/2025
@Version 1.0
-------------------------------------------------------------------*/
Static Function FAtuCont(nVerEmp, nVerAtu)

	Local aHeader := {}
	Local aBody	  := {}
	Local aRet	  := {}

	nVerAtu := 1033.82

	If nVerEmp < nVerAtu
		aAdd(aHeader, 'T5R_FILIAL')
		aAdd(aHeader, 'T5R_ID')
		aAdd(aHeader, 'T5R_CCLATR')
		aAdd(aHeader, 'T5R_DCLATR')
		aAdd(aHeader, 'T5R_CODCST')
		aAdd(aHeader, 'T5R_DESCST')
		aAdd(aHeader, 'T5R_DTINI')
		aAdd(aHeader, 'T5R_DTFIN')

		aAdd(aBody,{"","000001","000001","Situações tributadas integralmente pelo IBS e CBS."                                                                                                     ,"000","Tributação integral"                                            ,"20260101","",1033.82})
		aAdd(aBody,{"","000002","000002","Exploração de via"                                                                                                                                      ,"000","Tributação integral"                                            ,"20260101","",1033.82})
		aAdd(aBody,{"","000003","000003","Regime automotivo - projetos incentivados (art. 311)"                                                                                                   ,"000","Tributação integral"                                            ,"20260101","",1033.82})
		aAdd(aBody,{"","000004","000004","Regime automotivo - projetos incentivados (art. 312)"                                                                                                   ,"000","Tributação integral"                                            ,"20260101","",1033.82})
		aAdd(aBody,{"","000005","010001","Operações do FGTS não realizadas pela Caixa Econômica Federal"                                                                                          ,"010","Tributação com alíquotas uniformes - operações do FGTS"         ,"20260101","",1033.82})
		aAdd(aBody,{"","000006","010002","Operações do serviço financeiro"                                                                                                                        ,"010","Tributação com alíquotas uniformes - operações setor financeiro","20260101","",1033.82})
		aAdd(aBody,{"","000007","011001","Planos de assistência funerária."                                                                                                                       ,"011","Tributação com alíquotas uniformes reduzidas em 60%"            ,"20260101","",1033.82})
		aAdd(aBody,{"","000008","011002","Planos de assistência à saúde"                                                                                                                          ,"011","Tributação com alíquotas uniformes reduzidas em 60%"            ,"20260101","",1033.82})
		aAdd(aBody,{"","000009","011003","Intermediação de planos de assistência à saúde"                                                                                                         ,"011","Tributação com alíquotas uniformes reduzidas em 60%"            ,"20260101","",1033.82})
		aAdd(aBody,{"","000010","011004","Concursos e prognósticos"                                                                                                                               ,"011","Tributação com alíquotas uniformes"                             ,"20260101","",1033.82})
		aAdd(aBody,{"","000011","011005","Planos de assistência à saúde de animais domésticos"                                                                                                    ,"011","Tributação com alíquotas uniformes reduzidas em 30%"            ,"20260101","",1033.82})
		aAdd(aBody,{"","000012","200001","Aquisições realizadas entre empresas autorizadas a operar em zonas de processamento de exportação"                                                      ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000013","200002","Fornecimento ou importação para produtor rural não contribuinte ou TAC"                                                                                 ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000014","200003","Vendas de produtos destinados à alimentação humana (Anexo I)"                                                                                           ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000015","200004","Venda de dispositivos médicos (Anexo XII)"                                                                                                              ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000016","200005","Venda de dispositivos médicos adquiridos por órgãos da administração pública (Anexo IV)"                                                                ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000017","200006","Situação de emergência de saúde pública reconhecida pelo Poder público (Anexo XII)"                                                                     ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000018","200007","Fornecimento dos dispositivos de acessibilidade próprios para pessoas com deficiência (Anexo XIII)"                                                     ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000019","200008","Fornecimento dos dispositivos de acessibilidade próprios para pessoas com deficiência adquiridos por órgãos da administração pública (Anexo V)"         ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000020","200009","Fornecimento de medicamentos (Anexo XIV)"                                                                                                               ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000021","200010","Fornecimento dos medicamentos registrados na Anvisa, adquiridos por órgãos da administração pública"                                                    ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000022","200011","Fornecimento das composições para nutrição enteral e parenteral quando adquiridas por órgãos da administração pública (Anexo VI)"                       ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000023","200012","Situação de emergência de saúde pública reconhecida pelo Poder público (Anexo XIV)"                                                                     ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000024","200013","Fornecimento de tampões higiênicos, absorventes higiênicos internos ou externos"                                                                        ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000025","200014","Fornecimento dos produtos hortícolas, frutas e ovos (Anexo XV)"                                                                                         ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000026","200015","Venda de automóveis de passageiros de fabricação nacional adquiridos por motoristas profissionais ou pessoas com deficiência"                           ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000027","200016","Prestação de serviços de pesquisa e desenvolvimento por Instituição Científica, Tecnológica e de Inovação (ICT)"                                        ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000028","200017","Operações relacionadas ao FGTS"                                                                                                                         ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000029","200018","Operações de resseguro e retrocessão"                                                                                                                   ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000030","200019","Importador dos serviços financeiros contribuinte"                                                                                                       ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000031","200020","Operação praticada por sociedades cooperativas optantes por regime específico do IBS e CBS"                                                             ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000032","200021","Serviços de transporte público coletivo de passageiros ferroviário e hidroviário"                                                                       ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000033","200022","Serviços de transporte público coletivo de passageiros ferroviário e hidroviário"                                                                       ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000034","200023","Operação realizada por indústria incentivada que destine bem material intermediário para outra indústria incentivada na ZFM"                            ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000035","200024","Operação originada fora das Áreas de Livre Comércio destinadas a contribuinte estabelecido nas Áreas de Livre Comércio"                                 ,"200","Alíquota zero"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000036","200025","Fornecimento dos serviços de educação relacionados ao Programa Universidade para Todos (Prouni)"                                                        ,"200","Alíquota zero apenas CBS e reduzida em 60% para IBS"            ,"20260101","",1033.82})
		aAdd(aBody,{"","000037","200026","Locação de imóveis localizados nas zonas reabilitadas"                                                                                                  ,"200","Alíquota reduzida em 80%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000038","200027","Operações de locação, cessão onerosa e arrendamento de bens imóveis"                                                                                    ,"200","Alíquota reduzida em 70%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000039","200028","Fornecimento dos serviços de educação (Anexo II)"                                                                                                       ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000040","200029","Fornecimento dos serviços de saúde humana (Anexo III)"                                                                                                  ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000041","200030","Venda dos dispositivos médicos (Anexo IV)"                                                                                                              ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000042","200031","Fornecimento dos dispositivos de acessibilidade próprios para pessoas com deficiência (Anexo V)"                                                        ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000043","200032","Fornecimento dos medicamentos registrados na Anvisa ou produzidos por farmácias de manipulação, ressalvados os medicamentos sujeitos à alíquota zero"   ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000044","200033","Fornecimento das composições para nutrição enteral e parenteral (Anexo VI)"                                                                             ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000045","200034","Fornecimento dos alimentos destinados ao consumo humano (Anexo VII)"                                                                                    ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000046","200035","Fornecimento dos produtos de higiene pessoal e limpeza (Anexo VIII)"                                                                                    ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000047","200036","Fornecimento de produtos agropecuários, aquícolas, pesqueiros, florestais e extrativistas vegetais in natura"                                           ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000048","200037","Fornecimento de serviços ambientais de conservação ou recuperação da vegetação nativa"                                                                  ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000049","200038","Fornecimento dos insumos agropecuários e aquícolas (Anexo IX)"                                                                                          ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000050","200039","Fornecimento dos serviços e o licenciamento ou cessão dos direitos destinados às produções nacionais artísticas (Anexo X)"                              ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000051","200040","Fornecimento de serviços de comunicação institucional à administração pública"                                                                          ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000052","200041","Fornecimento de serviço de educação desportiva (art. 141. I)"                                                                                           ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000053","200042","Fornecimento de serviço de educação desportiva (art. 141. II)"                                                                                          ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000054","200043","Fornecimento à administração pública dos serviços e dos bens relativos à soberania (Anexo XI)"                                                          ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000055","200044","Operações e prestações de serviços de segurança da informação e segurança cibernética desenvolvidos por sociedade que tenha sócio brasileiro (Anexo XI)","200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000056","200045","Operações relacionadas a projetos de reabilitação urbana de zonas históricas e de áreas críticas de recuperação e reconversão urbanística"              ,"200","Alíquota reduzida em 60%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000057","200046","Operações com bens imóveis"                                                                                                                             ,"200","Alíquota reduzida em 50%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000058","200047","Bares e Restaurantes"                                                                                                                                   ,"200","Alíquota reduzida em 40%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000059","200048","Hotelaria, Parques de Diversão e Parques Temáticos"                                                                                                     ,"200","Alíquota reduzida em 40%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000060","200049","Transporte coletivo de passageiros rodoviário, ferroviário e hidroviário"                                                                               ,"200","Alíquota reduzida em 40%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000061","200051","Agências de Turismo"                                                                                                                                    ,"200","Alíquota reduzida em 40%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000062","200052","Prestação de serviços de profissões intelectuais"                                                                                                       ,"200","Alíquota reduzida em 30%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000063","200450","Serviços de transporte aéreo regional coletivo de passageiros ou de carga"                                                                              ,"200","Alíquota reduzida em 40%"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000064","220001","Incorporação imobiliária submetida ao regime especial de tributação"                                                                                    ,"220","Alíquota fixa"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000065","220002","Incorporação imobiliária submetida ao regime especial de tributação"                                                                                    ,"220","Alíquota fixa"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000066","220003","Alienação de imóvel decorrente de parcelamento do solo"                                                                                                 ,"220","Alíquota fixa"                                                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000067","221001","Locação, cessão onerosa ou arrendamento de bem imóvel com alíquota sobre a receita bruta"                                                               ,"221","Alíquota fixa proporcional"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000068","222001","Transporte internacional de passageiros, caso os trechos de ida e volta sejam vendidos em conjunto"                                                     ,"222","Redução de Base de Cálculo"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000069","400001","Fornecimento de serviços de transporte público coletivo de passageiros rodoviário e metroviário"                                                        ,"400","Isenção"                                                        ,"20260101","",1033.82})
		aAdd(aBody,{"","000070","410001","Fornecimento de bonificações quando constem no documento fiscal e que não dependam de evento posterior"                                                 ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000071","410002","Transferências entre estabelecimentos pertencentes ao mesmo contribuinte"                                                                               ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000072","410003","Doações sem contraprestação em benefício do doador"                                                                                                     ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000073","410004","Exportações de bens e serviços"                                                                                                                         ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000074","410005","Fornecimentos realizados pela União, pelos Estados, pelo Distrito Federal e pelos Municípios"                                                           ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000075","410006","Fornecimentos realizados por entidades religiosas e templos de qualquer culto"                                                                          ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000076","410007","Fornecimentos realizados por partidos políticos"                                                                                                        ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000077","410008","Fornecimentos de livros, jornais, periódicos e do papel destinado a sua impressão"                                                                      ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000078","410009","Fornecimentos de fonogramas e videofonogramas musicais produzidos no Brasil"                                                                            ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000079","410010","Fornecimentos de serviço de comunicação nas modalidades de radiodifusão sonora e de sons e imagens de recepção livre e gratuita"                        ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000080","410011","Fornecimentos de ouro, quando definido em lei como ativo financeiro ou instrumento cambial"                                                             ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000081","410012","Fornecimento de condomínio edilício não optante pelo regime regular"                                                                                    ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000082","410013","Exportações de combustíveis"                                                                                                                            ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000083","410014","Fornecimento de produtor rural não contribuinte"                                                                                                        ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000084","410015","Fornecimento por transportador autônomo não contribuinte"                                                                                               ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000085","410016","Fornecimento ou aquisição de resíduos sólidos"                                                                                                          ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000086","410017","Aquisição de bem móvel com crédito presumido sob condição de revenda realizada"                                                                         ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000087","410018","Operações relacionadas aos fundos garantidores e executores de políticas públicas"                                                                      ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000088","410019","Exclusão da gorjeta na base de cálculo no fornecimento de alimentação"                                                                                  ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000089","410020","Exclusão do valor de intermediação na base de cálculo no fornecimento de alimentação"                                                                   ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000090","410021","Contribuição de que trata o art. 149-A da Constituição Federal"                                                                                         ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000091","410022","Consolidação da propriedade do bem pelo credor"                                                                                                         ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000092","410023","Alienação de bens móveis ou imóveis que tenham sido objeto de garantia em que o prestador da garantia não seja contribuinte"                            ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000093","410024","Consolidação da propriedade do bem pelo grupo de consórcio"                                                                                             ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000094","410025","Alienação de bem que tenha sido objeto de garantia em que o prestador da garantia não seja contribuinte"                                                ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000095","410026","Doação com anulação de crédito"                                                                                                                         ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000096","410999","Operações não onerosas sem previsão de tributação, não especificadas anteriormente"                                                                     ,"410","Imunidade e não incidência"                                     ,"20260101","",1033.82})
		aAdd(aBody,{"","000097","510001","Operações, sujeitas a diferimento, com energia elétrica, relativas à geração, comercialização, distribuição e transmissão"                              ,"510","Diferimento"                                                    ,"20260101","",1033.82})
		aAdd(aBody,{"","000098","515001","Operações, sujeitas a diferimento, com insumos agropecuários e aquícolas destinados a produtor rural não contribuinte (Anexo IX)"                       ,"515","Diferimento com redução de alíquota"                            ,"20260101","",1033.82})
		aAdd(aBody,{"","000099","550001","Exportações de bens materiais"                                                                                                                          ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000100","550002","Regime de Trânsito"                                                                                                                                     ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000101","550003","Regimes de Depósito (art. 85)"                                                                                                                          ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000102","550004","Regimes de Depósito (art. 87)"                                                                                                                          ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000103","550005","Regimes de Depósito (art. 87, Parágrafo único)"                                                                                                         ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000104","550006","Regimes de Permanência Temporária"                                                                                                                      ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000105","550007","Regimes de Aperfeiçoamento"                                                                                                                             ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000106","550008","Importação de bens para o Regime de Repetro-Temporário"                                                                                                 ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000107","550009","GNL-Temporário"                                                                                                                                         ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000108","550010","Repetro-Permanente"                                                                                                                                     ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000109","550011","Repetro-Industrialização"                                                                                                                               ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000110","550012","Repetro-Nacional"                                                                                                                                       ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000111","550013","Repetro-Entreposto"                                                                                                                                     ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000112","550014","Zona de Processamento de Exportação"                                                                                                                    ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000113","550015","Regime Tributário para Incentivo à Modernização e à Ampliação da Estrutura Portuária"                                                                   ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000114","550016","Regime Especial de Incentivos para o Desenvolvimento da Infraestrutura"                                                                                 ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000115","550017","Regime Tributário para Incentivo à Atividade Econômica Naval"                                                                                           ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000116","550018","Desoneração da aquisição de bens de capital"                                                                                                            ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000117","550019","Importação de bem material por indústria incentivada para utilização na ZFM"                                                                            ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000118","550020","Áreas de livre comércio"                                                                                                                                ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000119","550021","Industrialização destinada a exportações"                                                                                                               ,"550","Suspensão"                                                      ,"20260101","",1033.82})
		aAdd(aBody,{"","000120","620001","Tributação monofásica sobre combustíveis"                                                                                                               ,"620","Tributação monofásica"                                          ,"20260101","",1033.82})
		aAdd(aBody,{"","000121","620002","Tributação monofásica com responsabilidade pela retenção sobre combustíveis"                                                                            ,"620","Tributação monofásica"                                          ,"20260101","",1033.82})
		aAdd(aBody,{"","000122","620003","Tributação monofásica com tributos retidos por responsabilidade sobre combustíveis"                                                                     ,"620","Tributação monofásica"                                          ,"20260101","",1033.82})
		aAdd(aBody,{"","000123","620004","Tributação monofásica sobre mistura de EAC com gasolina A em percentual superior ao obrigatório"                                                        ,"620","Tributação monofásica"                                          ,"20260101","",1033.82})
		aAdd(aBody,{"","000124","620005","Tributação monofásica sobre mistura de EAC com gasolina A em percentual inferior ao obrigatório"                                                        ,"620","Tributação monofásica"                                          ,"20260101","",1033.82})
		aAdd(aBody,{"","000125","620006","Tributação monofásica sobre combustíveis cobrada anteriormente"                                                                                         ,"620","Tributação monofásica"                                          ,"20260101","",1033.82})
		aAdd(aBody,{"","000126","800001","Fusão, cisão ou incorporação"                                                                                                                           ,"800","Transferência de crédito"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000127","800002","Transferência de crédito do associado, inclusive as cooperativas singulares"                                                                            ,"800","Transferência de crédito"                                       ,"20260101","",1033.82})
		aAdd(aBody,{"","000128","810001","Crédito presumido de IBS sobre o valor apurado nos fornecimentos a partir da ZFM"                                                                       ,"810","Ajuste de IBS na ZFM"                                           ,"20260101","",1033.82})
		aAdd(aBody,{"","000129","811001","Anulação de Crédito por Saídas Imunes/Isentas"                                                                                                          ,"811","Ajustes"                                                        ,"20260101","",1033.82})
		aAdd(aBody,{"","000130","811002","Débitos de notas fiscais não processadas na apuração"                                                                                                   ,"811","Ajustes"                                                        ,"20260101","",1033.82})
		aAdd(aBody,{"","000131","811003","Desenquadramento do Simples Nacional"                                                                                                                   ,"811","Ajustes"                                                        ,"20260101","",1033.82})
		aAdd(aBody,{"","000132","820001","Documento com informações de fornecimento de serviços de planos de assistência à saúde"                                                                 ,"820","Tributação em declaração de regime específico"                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000133","820002","Documento com informações de fornecimento de serviços de planos de assistência funerária"                                                               ,"820","Tributação em declaração de regime específico"                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000134","820003","Documento com informações de fornecimento de serviços de planos de assistência à saúde de animais domésticos"                                           ,"820","Tributação em declaração de regime específico"                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000135","820004","Documento com informações de prestação de serviços de consursos de prognósticos"                                                                        ,"820","Tributação em declaração de regime específico"                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000136","820005","Documento com informações de alienação de bens imóveis"                                                                                                 ,"820","Tributação em declaração de regime específico"                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000137","820006","Documento com informações de fornecimento de serviços de exploração de via"                                                                             ,"820","Tributação em declaração de regime específico"                  ,"20260101","",1033.82})
		aAdd(aBody,{"","000138","830001","Documento com exclusão da BC da CBS e do IBS de energia elétrica fornecida pela distribuidora à UC"                                                     ,"830","Exclusão de base de cálculo"                                    ,"20260101","",1033.82})
		
		aAdd(aRet, {aHeader, aBody})
	EndIf

Return(aRet)

