#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEX000.CH"
#DEFINE TOTVS_COLAB_ONDEMAND 3100 // TOTVS Colaboracao
 
Static _aTipEsp := {}
Static _aTipPre := {}
//-------------------------------------------------------------------
// Parâmetro do módulo
/*{Protheus.doc} GFEX000
Função que cria uma tela aonde se pode ser incluidos ou alterados os parametros que existem na base

@author Felipe Mendes / Octávio Augusto Felippe de Macedo
@since 05/10/11
@version 1.0

Alteração para subir no TFS
*/
Function GFEX000()
	Local aAux     := {}
	Local oFreteBr := Nil
	Local nI       := 0
	Local nF       := 0
	
	// Verifica se está integrado com Fretebras e os parâmetros estão criados
	If IntGFEFrtBr(.F.) .And. GFXPR12131("MV_GFEFBPR")
		// Classe de conexão com o FreteBras 
		oFreteBr := TMSBCAFreteBras():New()
		// Busca do Token para conexão
		oFreteBr:GetAccessToken()
		// Seta que não devem ser mostradas mensagens dentro da classe
		oFreteBr:SetMostraErro(.F.)
		// Monta opções do Tipo Espécie
		Aadd(_aTipEsp,"")
		aAux := oFreteBr:GetEspecie()
		nF := Len(aAux)
		For nI := 1 To nF
			Aadd(_aTipEsp,cValToChar(aAux[nI,1])+"="+aAux[nI,2])
		Next nI
		// Monta opções do Tipo Preço
		Aadd(_aTipPre,"")
		aAux := oFreteBr:GetPreco()
		nF := Len(aAux)
		For nI := 1 To nF
			Aadd(_aTipPre,cValToChar(aAux[nI,1])+"="+aAux[nI,2])
		Next nI
	EndIf

	// Monta tela
	FWExecView("Frete Embarcador", 'GFEX000', 3, , {|| .T. } )	
Return NIL
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel    := Nil
	Local oStruct   := FWFormModelStruct():New()
	Local aCampos   := {}
	Local nCont     := 0
	Local nContF    := 0
	Local aValues 	:= {"","0=Nenhum","1=Filial","2=Tipo Operação","3=Item","4=Reg Comecial","5=Grupo Emitente","6=Tipo Doc Carga","7=Classificação Frete","8=Tipo de Frete","9=Info Ctb 1","10=Info Ctb 2","11=Info Ctb 3","12=Info Ctb 4","13=Info Ctb 5","14=Representante","15=Unidade de Negócio","16=CFOP Item Doc Carga","17=Tipo de Serviço","18=Grupo de Transportador","19-Serie Doc Carga"}
	Local aSelVal 	:= {"","0=Nenhuma","1=Alertar","2=Desfazer Cálculo"}
	Local bValidDsCtb 	:= FwBuildFeature(1,'ValidDSCTB()')
	Local bValidTPEST 	:= FwBuildFeature(1,"ValidTPEST( FwFldGet( 'MV_TPEST' ),FwFldGet( 'MV_ERPGFE' ))")

	aAdd(aCampos,{"MV_TPGRP1" , "Grupo Contábil 1"                                 	, "C", 02 , 0,,aValues, {|| SuperGetMv("MV_TPGRP1",.F.,"0") }, })
	aAdd(aCampos,{"MV_TPGRP2" , "Grupo Contábil 2"                                 	, "C", 02 , 0,,aValues, {|| SuperGetMv("MV_TPGRP2",.F.,"0") }, })
	aAdd(aCampos,{"MV_TPGRP3" , "Grupo Contábil 3"                                 	, "C", 02 , 0,,aValues, {|| SuperGetMv("MV_TPGRP3",.F.,"0") }, })
	aAdd(aCampos,{"MV_TPGRP4" , "Grupo Contábil 4"                                 	, "C", 02 , 0,,aValues, {|| SuperGetMv("MV_TPGRP4",.F.,"0") }, })
	aAdd(aCampos,{"MV_TPGRP5" , "Grupo Contábil 5"                                 	, "C", 02 , 0,,aValues, {|| SuperGetMv("MV_TPGRP5",.F.,"0") }, })
	aAdd(aCampos,{"MV_TPGRP6" , "Grupo Contábil 6"                                 	, "C", 02 , 0,,aValues, {|| SuperGetMv("MV_TPGRP6",.F.,"0") }, })
	aAdd(aCampos,{"MV_TPGRP7" , "Grupo Contábil 7"                                 	, "C", 02 , 0,,aValues, {|| SuperGetMv("MV_TPGRP7",.F.,"0") }, })
	aAdd(aCampos,{"MV_DTULFE" , "Data do Último Fechamento"                        	, "D", 08 , 0,,, {||SuperGetMv("MV_DTULFE",.F.,"01/01/1900") }, })
	aAdd(aCampos,{"MV_TPGERA" , "Tipo de Geração Contábil"                         	, "C", 01 , 0,,{"","1=Automática","2=Sob Demanda"}, {|| SuperGetMV("MV_TPGERA",.F.,"1") }, })
	aAdd(aCampos,{"MV_ESCTAB" , "Critério de Seleção"                              	, "C", 01 , 0,,{"","1=Escolha do Usuário","2=Menor Valor Frete","3=Menor Prazo Entrega"}, {|| SuperGetMv("MV_ESCTAB",.F.,"1") }, })
	aAdd(aCampos,{"MV_CRIRAT" , "Critério de Rateio"                               	, "C", 01 , 0,,{"","0=(Não definido)","1=Peso Mercadoria","2=Valor Mercadoria","3=Volume","4=Quantidade"}, {|| IIf(Empty(SuperGetMv("MV_CRIRAT",.F.,"1")), "0", SuperGetMv("MV_CRIRAT",.F.,"1")) }, })
	aAdd(aCampos,{"MV_CRIRAT2", "Critério de Rateio Frete Mín Romaneio"            	, "C", 01 , 0,,{"","1=Valor do Frete","2=Peso Carga","3=Valor Carga","4=Quantidade Itens","5=Volume Carga"}, {|| IIf(Empty(SuperGetMv("MV_CRIRAT2",.F.,"1")),"1", SuperGetMv("MV_CRIRAT2",.F.,"1"))}, })
	aAdd(aCampos,{"MV_CRIRAT3", "Valor usado Rateio/Frete Minimo por Romaneio"     	, "C", 01 , 0,,{"","1=Diferença","2=Total Frete Mínimo"}, {|| IIf(Empty(SuperGetMv("MV_CRIRAT3",.F.,"1")),"1", SuperGetMv("MV_CRIRAT3",.F.,"1"))}, })
	aAdd(aCampos,{"MV_UMPESO" , "Unidade de Medida para Quilogramas"               	, "C", TamSX3("GV9_UNIFAI")[1] , 0,,, {|| SuperGetMv("MV_UMPESO",.F.,"1") }, })
	aAdd(aCampos,{"MV_GFECRIC", "ICMS Frete"                                       	, "C", 01 , 0,,{"","1=com Direito a Crédito", "2=sem Direito a Crédito"}, {|| IIf(Empty(SuperGetMv("MV_GFECRIC",.F.,"1")), "1", SuperGetMv("MV_GFECRIC",.F.,"1"))}, })
	aAdd(aCampos,{"MV_GFEGVR", "Realizar a busca de tabelas de frete considerando a tabela GVR (Região x Regiões)?"			, "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| SuperGetMv("MV_GFEGVR",.F.,"1")}, })
	aAdd(aCampos,{"MV_GFEGUL", "Realizar a busca de tabelas de frete considerando a tabela GUL (Região x Faixa de CEP)?"	, "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| SuperGetMv("MV_GFEGUL",.F.,"1")}, })
	aAdd(aCampos,{"MV_GFEVIN", "Realizar a busca de tabelas de frete considerando tabelas de tipo vínculo?"					, "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| SuperGetMv("MV_GFEVIN",.F.,"1")}, })

	aAdd(aCampos,{"MV_GFEQBR", "% Máx Quebra Peso"									, "N", 05 , 2,,, {|| SuperGetMV('MV_GFEQBR',.F.,)  }, })
	aAdd(aCampos,{"MV_GFEIND", "Descontar Indenizações"								, "C", 01 , 0,,{"","0=Não","1=Sim"}, {|| SuperGetMv("MV_GFEIND",.F.,"0")}, })

	aAdd(aCampos,{"MV_CRDPAR" , "Crédito ICMS"										, "C", 01 , 0,,{"","1=Total", "2=Parcial, conforme Itens Nota"}, {|| IIf(Empty(SuperGetMV('MV_CRDPAR',,'1')), "1", SuperGetMV('MV_CRDPAR',,'1'))}, {|| oModel:GetValue("GFEX000_01", "MV_GFECRIC") == "1" .And. oModel:GetValue("GFEX000_01", "MV_ERPGFE") == "1" },})
	aAdd(aCampos,{"MV_GFEPC"  , "PIS/COFINS Frete"                                 	, "C", 01 , 0,,{"","1=com Direito a Crédito", "2=sem Direito a Crédito"}, {|| IIf(Empty(SuperGetMv("MV_GFEPC",.F.,"1")), "1", SuperGetMv("MV_GFEPC",.F.,"1"))}, })
	aAdd(aCampos,{"MV_PCPIS"  , "Alíquota PIS"                                     	, "N", 05 , 2,,, {|| SuperGetMV('MV_PCPIS',.F.,)  }, })
	aAdd(aCampos,{"MV_PCCOFI" , "Alíquota COFINS"                                  	, "N", 05 , 2,,, {|| SuperGetMV('MV_PCCOFI',.F.,) }, })
	
	aAdd(aCampos,{"MV_PISDIF"  , "Alíquota PIS Diferenciada"						, "N", 07 , 4,,, {|| SuperGetMV('MV_PISDIF',.F.,)  }, })
	aAdd(aCampos,{"MV_COFIDIF" , "Alíquota COFINS Diferenciada"						, "N", 07 , 4,,, {|| SuperGetMV('MV_COFIDIF',.F.,) }, })
		
	aAdd(aCampos,{"MV_ISSBAPI", "ISS no PIS/COFINS"                                 , "C", 01 , 0,,{"","1=Manter","2=Retirar"}, {|| SuperGetMV('MV_ISSBAPI',,'1')}, })
	aAdd(aCampos,{"MV_ICMBAPI", "ICMS Ret no PIS/Cofins"                            , "C", 01 , 0,,{"","1=Manter","2=Retirar Retido","3=Retirar Total"}, {|| SuperGetMV('MV_ICMBAPI',,'1')}, })
	aAdd(aCampos,{"MV_DIMRET" , "Imp Retido Componente "                            , "C", 01 , 0,,{"","1=Manter","2=Retirar"}, {|| SuperGetMV('MV_DIMRET',,'1')}, })
	aAdd(aCampos,{"MV_DRTLOG" , "Diretório LOG"                                    	, "C", 200, 0,,, {|| SuperGetMv('MV_DRTLOG',.F.,"") }, })
	aAdd(aCampos,{"MV_LOGCALC", "Gera log de cálculo?" 								, "C", 01,  0,,, {|| SuperGetMv('MV_LOGCALC',.F.,"")  }, })
	aAdd(aCampos,{"MV_CALDEV" , "Valor Devolução"                                  	, "C", 01 , 0,,{"","1=Permite Alterar","2=Não Permite Alterar"}, {|| SuperGetMV('MV_CALDEV',,'1') }, })
	aAdd(aCampos,{"MV_CALREN" , "Valor Reentrega"                                  	, "C", 01 , 0,,{"","1=Permite Alterar","2=Não Permite Alterar"}, {|| SuperGetMV('MV_CALREN',,'1') }, })
	aAdd(aCampos,{"MV_CALSER" , "Valor Serviço"                                    	, "C", 01 , 0,,{"","1=Permite Alterar","2=Não Permite Alterar"}, {|| SuperGetMV('MV_CALSER',,'1') }, })
	aAdd(aCampos,{"MV_TIPREG" , "Regionalização"                                   	, "C", 01 , 0,,{"","1=de Terceiros","2=Própria"}, {|| SuperGetMV('MV_TIPREG',,'1') }, })
	aAdd(aCampos,{"MV_GFETAB1", "Estrutura de Tabelas de Frete"                    	, "C", 01 , 0,,{"","1=Uma por Transportador","2=Sem restrição"}, {|| IIf(Empty(SuperGetMV('MV_GFETAB1',,'1')), "1", SuperGetMV('MV_GFETAB1',,'1')) }, })
	aAdd(aCampos,{"MV_APRTAB" , "Controle de Aprovação"                            	, "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| SuperGetMV('MV_APRTAB',,'1') }, })
	aAdd(aCampos,{"MV_PFENTR" , "Registro de Entrega"                              	, "C", 01 , 0,,{"","0=Prova de Entrega","1=Informação de Entrega","2=Nenhuma"}, {|| SuperGetMV('MV_PFENTR',,'1') }, })
	aAdd(aCampos,{"MV_OBNENT" , "Cálculo Normal"                                   	, "C", 01 , 0,,{"","1=Obrigatório","2=Opcional"}, {|| SuperGetMV('MV_OBNENT',,'1') }, })
	aAdd(aCampos,{"MV_OBREDE" , "Cálculo Redespacho"                               	, "C", 01 , 0,,{"","1=Obrigatório","2=Opcional"}, {|| SuperGetMV('MV_OBREDE',,'1') }, })
	aAdd(aCampos,{"MV_OBCOMP" , "Cálculo Complementar"                             	, "C", 01 , 0,,{"","1=Obrigatório","2=Opcional"}, {|| SuperGetMV('MV_OBCOMP',,'1') }, })
	aAdd(aCampos,{"MV_OBREEN" , "Cálculo Reentrega"                                	, "C", 01 , 0,,{"","1=Obrigatório","2=Opcional"}, {|| SuperGetMV('MV_OBREEN',,'1') }, })
	aAdd(aCampos,{"MV_OBDEV"  , "Cálculo Devolução"                                	, "C", 01 , 0,,{"","1=Obrigatório","2=Opcional"}, {|| SuperGetMV('MV_OBDEV',,'1') }, })
	aAdd(aCampos,{"MV_OBSERV" , "Cálculo Serviços"                                 	, "C", 01 , 0,,{"","1=Obrigatório","2=Opcional"}, {|| SuperGetMV('MV_OBSERV',,'1') }, })
	aAdd(aCampos,{"MV_CFOFR1" , "CFOP ICMS Estadual"                               	, "C", 04 , 0,,, {|| SuperGetMV('MV_CFOFR1',,'') }, })
	aAdd(aCampos,{"MV_CFOFR2" , "CFOP ICMS Interestadual"                           , "C", 04 , 0,,, {|| SuperGetMV('MV_CFOFR2',,'') }, })
	
	If GFXPR1212310("MV_CALRET")
		aAdd(aCampos,{"MV_CALRET" , "Atribui % de Devolução no Cálculo de Retorno"  , "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| SuperGetMV('MV_CALRET',,'') }, })
	EndIF

	aAdd(aCampos,{"MV_CFOFR3" , "CFOP ISS Mesmo Município"							, "C", 04 , 0,,, {|| SuperGetMV("MV_CFOFR3",.T.,"")}, })
	aAdd(aCampos,{"MV_CFOFR4" , "CFOP ISS Outro Município"							, "C", 04 , 0,,, {|| SuperGetMV("MV_CFOFR4",.T.,"")}, })
	aAdd(aCampos,{"MV_GFEVLDT", "Identificação Única Doc Fret"                     	, "C", 01 , 0,,{"", "1=Número", "2=Número e Série", "3=Número, Série e Data de Emissão"}, {|| IIf(Empty(SuperGetMV('MV_GFEVLDT',,'1')), "3", SuperGetMV('MV_GFEVLDT',,'1'))}, })
	aAdd(aCampos,{"MV_VLCNPJ" , "Transportador Doc Frete"                           , "C", 01 , 0,,{"", "1=Somente Transp Nota ", "2=Considera mesma raiz CNPJ"}, {|| IIf(Empty(SuperGetMV('MV_VLCNPJ',,'1')), "1", SuperGetMV('MV_VLCNPJ',,'1'))}, })	
	aAdd(aCampos,{"MV_GFEVLFT", "Identificação Única Fatura"                       	, "C", 01 , 0,,{"", "1=Número", "2=Número e Série", "3=Número, Série e Data de Emissão"}, {|| IIf(Empty(SuperGetMV('MV_GFEVLFT',,'1')), "3", SuperGetMV('MV_GFEVLFT',,'1'))}, })
	aAdd(aCampos,{"MV_DCOUT"  , "Confere Dados da Carga?"                          	, "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| SuperGetMV('MV_DCOUT',,'1') }, })
	aAdd(aCampos,{"MV_DCABE"  , "Valor Detalhado"                                  	, "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| SuperGetMV('MV_DCABE',,'1') }, })
	aAdd(aCampos,{"MV_DCTOT"  , "Valor Total"                                      	, "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| SuperGetMV('MV_DCTOT',,'1') }, })
	If GFXPR1212510("MV_DMIMP")
		aAdd(aCampos,{"MV_DMIMP"  , "Valor Imposto"                                   	, "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| SuperGetMV('MV_DMIMP',,'1') }, })
	EndIf
	aAdd(aCampos,{"MV_DCVAL"  , "Diferença Máxima de Valor"                        	, "N", 08 , 2,,, {|| SuperGetMv("MV_DCVAL",.F.,99999.99) }, }) 
	aAdd(aCampos,{"MV_DCPERC" , "Diferença Máxima de Percentual"                   	, "N", 06 , 2,,, {|| SuperGetMv("MV_DCPERC",.F.,999.99) }, })
	If GFXPR1212510("MV_DMVAL")
		aAdd(aCampos,{"MV_DMVAL"  , "Diferença Máxima de Valor a Menor"             , "N", 08 , 2,,, {|| SuperGetMv("MV_DMVAL",.F.,99999.99) }, }) 
	EndIf
	If GFXPR1212510("MV_DMPERC")
		aAdd(aCampos,{"MV_DMPERC" , "Diferença Máxima de Percentual a Menor"        , "N", 06 , 2,,, {|| SuperGetMv("MV_DMPERC",.F.,999.99) }, })
	EndIf
	aAdd(aCampos,{"MV_DCNEG"  , "Diferença Menor"                                  	, "C", 01 , 0,,{"","1=Aprovar","2=Conferir"}, {|| SuperGetMV('MV_DCNEG',,'1') }, })
	aAdd(aCampos,{"MV_CFCONPG", "Data Vencimento"                                  	, "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| SuperGetMV('MV_CFCONPG',,'1') }, })
	aAdd(aCampos,{"MV_CFAGRUP", "Agrupamento"                                      	, "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| SuperGetMV('MV_CFAGRUP',,'1') }, })
	aAdd(aCampos,{"MV_CFVLFAT", "Valor"                                            	, "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| IIf(Empty(SuperGetMV('MV_CFVLFAT',,'1')), "2", SuperGetMV('MV_CFVLFAT',,'1')) }, })
	aAdd(aCampos,{"MV_CFVLVAR", "Diferença Máxima de Valor"                        	, "N", 08 , 2,,, {|| SuperGetMv("MV_CFVLVAR",.F.,99999.99) }, })
	aAdd(aCampos,{"MV_CFPCVAR", "Diferença Máxima de Percentual"                   	, "N", 06 , 2,,, {|| SuperGetMv("MV_CFPCVAR",.F.,999.99) }, })
	aAdd(aCampos,{"MV_GFEDCFA", "Controle de Compensação de Divergências"			, "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| SuperGetMV('MV_GFEDCFA',,'1') }, })
	aAdd(aCampos,{"MV_AUDINF" , "Auditoria Frete Combinado"							, "C", 01 , 0,,{"","1=Auditar normalmente","2=Exigir aprovação"}, {|| SuperGetMV('MV_AUDINF',,'1') }, })
	aAdd(aCampos,{"MV_GFE011" , "Auditoria Documentos Complementares"				, "C", 01 , 0,,{"","1=Auditar normalmente","2=Exigir aprovação"}, {|| SuperGetMV('MV_GFE011',,'1') }, })
	aAdd(aCampos,{"MV_GFE012" , "Condição Agendamento Doc Carga"					, "C", 01 , 0,,{"","0=Sem Restrição","1=Em Romaneio","2=Em Romaneio Liberado ou Encerrado"}, {|| SuperGetMV('MV_GFE012',,'0') }, })
	aAdd(aCampos,{"MV_PFOBRIG", "PF Obrigatória"                                	, "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| IIf(Empty(SuperGetMV('MV_PFOBRIG',,'2')), "2", SuperGetMV('MV_PFOBRIG',,'2')) }, {|| oModel:GetValue("GFEX000_01", "MV_CFVLFAT") == "1" }, })
	aAdd(aCampos,{"MV_APUIRF" , "Apuração IRRF/INSS"                                , "C", 01 , 0,,{"","1=Centralizado","2=por Filial"}, {|| SuperGetMV("MV_APUIRF", .F., "2") }, })
	aAdd(aCampos,{"MV_GFE016" , "Data de Referência para apuração IRRF"             , "C", 01 , 0,,{"","1=Data de Criação","2=Data de Vencimento"}, {|| SuperGetMV("MV_GFE016", .F., "1") }, })
	aAdd(aCampos,{"MV_BASIRF" , "% Base IRRF"                                      	, "N", 06 , 2,,, {|| SuperGetMv("MV_BASIRF",.F.,999.99) }, })
	aAdd(aCampos,{"MV_DEDINS" , "INSS Base IRRF"                                   	, "C", 01 , 0,,{"","1=Descontar","2=Manter"}, {|| SuperGetMV('MV_DEDINS',,'1') }, })
	aAdd(aCampos,{"MV_DEDSES" , "SEST/SENAT Base IRRF"								, "C", 01 , 0,,{"","1=Descontar","2=Manter"}, {|| SuperGetMV('MV_DEDSES',,'1') }, })
	aAdd(aCampos,{"MV_MINIRF" , "Valor Mínimo IRRF"                                	, "N", 08 , 2,,, {|| SuperGetMv("MV_MINIRF",.F.,99999.99) }, })
	aAdd(aCampos,{"MV_BASINS" , "% Base INSS"                                      	, "N", 06 , 2,,, {|| SuperGetMv("MV_BASINS",.F.,999.99) }, })
	aAdd(aCampos,{"MV_PCINAU" , "% INSS Autônomo"                                  	, "N", 05 , 2,,, {|| SuperGetMv("MV_PCINAU",.F.,99.99) }, })
	aAdd(aCampos,{"MV_VLMXRE" , "Valor Máximo de INSS"                             	, "N", 08 , 2,,, {|| SuperGetMv("MV_VLMXRE",.F.,99999.99) }, })
	aAdd(aCampos,{"MV_PCINEM" , "% INSS Embarcador"                                	, "N", 06 , 2,,, {|| SuperGetMv("MV_PCINEM",.F.,999.99) }, })
	If GFXPR1212310("MV_PCSEST")
		aAdd(aCampos,{"MV_PCSEST" , "% SEST"                                     	, "N", 05 , 2,,, {|| SuperGetMv("MV_PCSEST",.F.,99.99) }, })
	EndIf
	If GFXPR1212310("MV_PCSENA")
		aAdd(aCampos,{"MV_PCSENA" , "% SENAT"                                  	    , "N", 05 , 2,,, {|| SuperGetMv("MV_PCSENA",.F.,99.99) }, })
	EndIf
	aAdd(aCampos,{"MV_ESPDF1" , "Espécie CTR"                                      	, "C", 05 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_ESPDF1).Or.GFEExistC("GVT",,,"GVT->GVT_SIT=='1'")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},, {|| SuperGetMV('MV_ESPDF1',,'1') }, })
	aAdd(aCampos,{"MV_ESPDF3" , "Espécie CT-e"                                     	, "C", 05 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_ESPDF3).Or.GFEExistC("GVT",,,"GVT->GVT_SIT=='1'")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},, {|| SuperGetMV('MV_ESPDF3',,'1') }, })
	aAdd(aCampos,{"MV_ESPDF2" , "Espécie NFST"                                     	, "C", 05 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_ESPDF2).Or.GFEExistC("GVT",,,"GVT->GVT_SIT=='1'")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},, {|| SuperGetMV('MV_ESPDF2',,'1') }, })
	aAdd(aCampos,{"MV_CADERP" , "Origem dos Cadastros"                             	, "C", 01 , 0,,{"","1=ERP","2=SIGAGFE"}, {|| SuperGetMV('MV_CADERP',,'1') }, })
	aAdd(aCampos,{"MV_GFEEDIL", "Tipo de Geração de Log"                           	, "C", 01 , 0,,{"", "1=Não Gerar","2=Normal","3=Modo Debug","4=Modo Console"}, {|| SuperGetMV('MV_GFEEDIL',,'1') }, })
	aAdd(aCampos,{"MV_ERPGFE" , "ERP Integrado"                                    	, "C", 01 , 0,,{"","1=Datasul","2=Protheus","3=RM","4=Logix"}, {||SuperGetMV('MV_ERPGFE',,'1') }, {|| oModel:GetValue("GFEX000_01", "MV_CADERP") == "1" }, })
	aAdd(aCampos,{"MV_CDCLFR" , "Classificação de Frete Padrão"                    	, "C", 09 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_CDCLFR).Or.GFEExistC("GUB",,M->MV_CDCLFR,"GUB->GUB_SIT=='1'")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},, {|| SuperGetMV('MV_CDCLFR',,'') }, })
	aAdd(aCampos,{"MV_EAIURL" , "Url EAI"                                          	, "C", 200, 0,,, {|| SuperGetMV('MV_EAIURL',,'') }, })
	aAdd(aCampos,{"MV_EAIPORT", "Porta EAI"                                        	, "C", 50 , 0,,, {|| SuperGetMV('MV_EAIPORT',,'') }, })
	aAdd(aCampos,{"MV_CADOMS" , "Origem dos Cadastros OMS"                         	, "C", 01 , 0,,{"","1=OMS","2=SIGAGFE"}, {|| SuperGetMV('MV_CADOMS',,'1') }, })
	aAdd(aCampos,{"MV_PRITDF" , "Código Produto Registro de Entrada"               	, "C", TamSX3("B1_COD")[1] , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_PRITDF).Or.GFEExistC("SB1",,M->MV_PRITDF,"1==1")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},, {|| SuperGetMV('MV_PRITDF',,'') }, })
	aAdd(aCampos,{"MV_ESCPED" , "Pedágio com TES Própria", "C", 1  , 0,,{"","1=Sim","2=Não"},{|| SuperGetMv("MV_ESCPED",.F.,"2")}, })
	If GFXPR1212310("MV_GFEVOLU")
		aAdd(aCampos,{"MV_GFEVOLU", "Volume por Unitizador"  , "C", 1  , 0,,{"","1=Sim","2=Não"},{|| SuperGetMv("MV_GFEVOLU",.F.,"2")}, })
	EndIf
	aAdd(aCampos,{"MV_TPOPEMB", "Tipo de Operação Padrão"                          	, "C", 10 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_TPOPEMB).Or.GFEExistC("GV4",,M->MV_TPOPEMB,"GV4->GV4_SIT=='1'")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},, {|| SuperGetMV('MV_TPOPEMB',,'') }, })
	aAdd(aCampos,{"MV_DSESPF" , "Espécie Fatura"                                   	, "C", 02 , 0,,, {|| SuperGetMV('MV_DSESPF',,'') }, })
	aAdd(aCampos,{"MV_DSEPRO" , "Espécie Provisão"                                 	, "C", 02 , 0,,, {|| SuperGetMV('MV_DSEPRO',,'') }, })
	aAdd(aCampos,{"MV_DSESCT" , "Espécie Fatura Avulsa"                            	, "C", 02 , 0,,, {|| SuperGetMV('MV_DSESCT',,'') }, })
	aAdd(aCampos,{"MV_DSOFIT" , "Código Item Documento Fiscal"                     	, "C", 16 , 0,,, {|| SuperGetMV('MV_DSOFIT',,'') }, })
	aAdd(aCampos,{"MV_DSOFDT" , "Data Transação Documento Fiscal"                  	, "C", 01 , 0,,{"","1=Entrada","2=Financeira","3=Informada","4=Corrente"}, {|| SuperGetMV('MV_DSOFDT',,'1') }, })
	aAdd(aCampos,{"MV_DSICCD" , "Imposto ICMS Retido"                              	, "C", 05 , 0,,, {|| SuperGetMV('MV_DSICCD',,'') }, })
	aAdd(aCampos,{"MV_DSICCL" , "Classificação ICMS Retido"                        	, "C", 05 , 0,,, {|| SuperGetMV('MV_DSICCL',,'') }, })
	aAdd(aCampos,{"MV_DSISCD" , "Imposto ISS Retido"                               	, "C", 05 , 0,,, {|| SuperGetMV('MV_DSISCD',,'') }, })
	aAdd(aCampos,{"MV_DSISCL" , "Classificação ISS Retido"                         	, "C", 05 , 0,,, {|| SuperGetMV('MV_DSISCL',,'') }, })
	aAdd(aCampos,{"MV_MATREX" , "Matriz de Tradução Externa"                       	, "C", 08 , 0,,, {|| SuperGetMV('MV_MATREX',,'') }, })
	aAdd(aCampos,{"MV_DSESCO" , "Espécie Contrato"                                 	, "C", 02 , 0,,, {|| SuperGetMV('MV_DSESCO',,'') }, })
	aAdd(aCampos,{"MV_DSIRCD" , "Imposto IRRF"                                    	, "C", 05 , 0,,, {|| SuperGetMV('MV_DSIRCD',,'') }, })
	aAdd(aCampos,{"MV_DSIRCL" , "Classificação IRRF"                               	, "C", 05 , 0,,, {|| SuperGetMV('MV_DSIRCL',,'') }, })
	aAdd(aCampos,{"MV_DSIACD" , "Imposto INSS Autônomo"                            	, "C", 05 , 0,,, {|| SuperGetMV('MV_DSIACD',,'') }, })
	aAdd(aCampos,{"MV_DSIACL" , "Classificação INSS Autônomo"                      	, "C", 05 , 0,,, {|| SuperGetMV('MV_DSIACL',,'') }, })
	aAdd(aCampos,{"MV_DSINCD" , "Código Imposto INSS Embarcador"                   	, "C", 05 , 0,,, {|| SuperGetMV('MV_DSINCD',,'') }, })
	aAdd(aCampos,{"MV_DSINCL" , "Classificação Imposto INSS Embarc."            	, "C", 05 , 0,,, {|| SuperGetMV('MV_DSINCL',,'') }, })
	aAdd(aCampos,{"MV_ADINEM" , "Adc. INSS Embarc. RE"								, "C", 01 , 0,,{"","1=Sim","2=Nao"}, {|| SuperGetMV('MV_ADINEM',,'2') }, } )
	aAdd(aCampos,{"MV_DSSSCD" , "Código Imposto SEST/SENAT"                        	, "C", 05 , 0,,, {|| SuperGetMV('MV_DSSSCD',,'') }, })
	aAdd(aCampos,{"MV_DSSSCL" , "Classificação Imposto SEST/SENAT"                 	, "C", 05 , 0,,, {|| SuperGetMV('MV_DSSSCL',,'') }, })
	aAdd(aCampos,{"MV_XMLDIR" , "Diretorio do XML Totvs Colaboração"               	, "C", 99 , 0,,, {|| SuperGetMV('MV_XMLDIR',,'') }, } )
	aAdd(aCampos,{"MV_GFEI19" , "Contrato com RH"                                  	, "C", 01 , 0,,, {|| SuperGetMV('MV_GFEI19',,'1') }, } )
	aAdd(aCampos,{"MV_GFEI20" , "Data Integração Faturamento"						, "C", 08 , 0,,{"","1=Automática","2=Não Integrar"}, {||SuperGetMV("MV_GFEI20",,'2') }, })
	aAdd(aCampos,{"MV_GFEBI01", "Freight Expenses Fact"                            	, "C", 50 , 0,,, {|| SuperGetMV('MV_GFEBI01',,'') }, } )
	aAdd(aCampos,{"MV_GFEBI02", "Freight Occurrence Fact"                          	, "C", 50 , 0,,, {|| SuperGetMV('MV_GFEBI02',,'') }, } )
	aAdd(aCampos,{"MV_GFEBI03", "Freight LeadTime Fact"                            	, "C", 50 , 0,,, {|| SuperGetMV('MV_GFEBI03',,'') }, } )
	aAdd(aCampos,{"MV_EMPBI"  , "Empresa BI"										, "C", 15 , 0,,, {|| SuperGetMV('MV_EMPBI',,'')   }, } )
	aAdd(aCampos,{"MV_FILBI"  , "Filial BI"                                    		, "C", 15 , 0,,, {|| SuperGetMV('MV_FILBI',,'')   }, } )
	aAdd(aCampos,{"MV_GFEI10" , "Nota Fiscal de Entrada"                           	, "C", 01 , 0,,, {|| SuperGetMV('MV_GFEI10',,'1') }, } )
	aAdd(aCampos,{"MV_GFEI11" , "Nota Fiscal de Saída"                             	, "C", 01 , 0,,, {|| SuperGetMV('MV_GFEI11',,'1') }, } )
	aAdd(aCampos,{"MV_GFEI12" , "Carga"                                            	, "C", 01 , 0,,, {|| SuperGetMV('MV_GFEI12',,'1') }, } )
	aAdd(aCampos,{"MV_GFEI13" , "Doc. Frete com Fiscal"                            	, "C", 01 , 0,,, {|| SuperGetMV('MV_GFEI13',,'1') }, } )
	aAdd(aCampos,{"MV_GFEI14" , "Doc. Frete com Custo"                             	, "C", 01 , 0,,, {|| SuperGetMV('MV_GFEI14',,'1') }, } )
	aAdd(aCampos,{"MV_GFEI15" , "Pré-fatura com Financeiro"                        	, "C", 01 , 0,,, {|| SuperGetMV('MV_GFEI15',,'1') }, } )
	aAdd(aCampos,{"MV_GFEI16" , "Fatura com Financeiro"                            	, "C", 01 , 0,,, {|| SuperGetMV('MV_GFEI16',,'1') }, } )
	aAdd(aCampos,{"MV_GFEI23" , "Fiscal Pré-requisito para Atualizar Fatura com Financ."   , "C", 01 , 0,,, {|| SuperGetMV('MV_GFEI23',,'2') }, } )
	aAdd(aCampos,{"MV_GFEI17" , "Contrato com Financeiro"                          	, "C", 01 , 0,,, {|| SuperGetMV('MV_GFEI17',,'1') }, } )
	aAdd(aCampos,{"MV_GFEI18" , "Contrato com Custo"                               	, "C", 01 , 0,,, {|| SuperGetMV('MV_GFEI18',,'1') }, } )
	aAdd(aCampos,{"MV_DSDTAP" , "Data Integração Financeiro"                       	, "C", 01 , 0,,, {|| SuperGetMV('MV_DSDTAP',,'1') }, } )
	aAdd(aCampos,{"MV_DSDTRE" , "Data Integração Recebimento"                      	, "C", 01 , 0,,, {|| SuperGetMV('MV_DSDTRE',,'1') }, } )
	aAdd(aCampos,{"MV_GFE002", "Integração por Item de Transporte"					, "C", 01 , 0,,{"","1=Sim","2=Nao"}, {|| SuperGetMV('MV_GFE002',,'2') }, } )
	aAdd(aCampos,{"MV_WSGFE"  , "URL do WebService"                                	, "C", 40 , 0,,, {|| SuperGetMV('MV_WSGFE' ,,'')  }, } )
	aAdd(aCampos,{"MV_WSINST" , "Nome da instância"                                	, "C", 20 , 0,,, {|| SuperGetMV('MV_WSINST',,'')  }, } )
	aAdd(aCampos,{"MV_FATGFE" , "Nota Fiscal Interrompida"                         	, "C", 01 , 0,,{"","1=Sim","2=Nao"} ,{|| SuperGetMv('MV_FATGFE',.F.,"2") }, } )
	aAdd(aCampos,{"MV_PROVCON", "Provisão Contábil"                      			, "C", 01 , 0,,{"","1=Despesa Total","2=Despesa menos Impostos Recuperáveis","3=Despesa menos Impostos","4=Despesa e Impostos Recuperáveis"}, {|| SuperGetMV('MV_PROVCON',,'1') }, })
	aAdd(aCampos,{"MV_NTFGFE" , "Natureza da Fatura de Frete"                      	, "C", 10 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_NTFGFE) .Or.GFEExistC("SED",,M->MV_NTFGFE,"1==1")) ,FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},, {|| SuperGetMv("MV_NTFGFE",,"") }, })
	aAdd(aCampos,{"MV_GFEVLIT", "Valor do Item"										, "C", 01 , 0,,{"","1=Valor Bruto","2=Valor Total"} ,{|| SuperGetMv('MV_GFEVLIT',.F.,"1") }, } )
	aAdd(aCampos,{"MV_CPDGFE" , "Condição de Pagamento do Documento de Frete"      	, "C", 03 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_CPDGFE) .Or.GFEExistC("SE4",,M->MV_CPDGFE,"1==1")) ,FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},, {|| SuperGetMv("MV_CPDGFE",,"") }, })
	aAdd(aCampos,{"MV_CDTPOP" , "Código de Operação da Carga"                      	, "C", 10 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_TPOPEMB).Or.GFEExistC("GV4",,M->MV_TPOPEMB,"GV4->GV4_SIT=='1'")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},, {|| SuperGetMv("MV_CDTPOP",,"") }, })
	aAdd(aCampos,{"MV_INTGFE" , "Integracao com o TOTVS GFE"                       	, "L", 01 , 0,,{.T.,.F.},{|| SuperGetMv("MV_INTGFE",.F.,.F.) }, } )
	aAdd(aCampos,{"MV_INTGFE2", "Integracao Direta com TOTVS GFE"                  	, "C", 01 , 0,,{"","1=Sim","2=Nao"} ,{|| SuperGetMv("MV_INTGFE2",.F.,"2") }, } )
	aAdd(aCampos,{"MV_GFELIM1", "Valor Máximo Frete Romaneio"                      	, "N", 10 , 2,,,{|| SuperGetMv("MV_GFELIM1",.F.,999999.99) }, } )
	aAdd(aCampos,{"MV_GFELAC1", "Ação Frete Romaneio Excedido"                     	, "C", 01 , 0,,aSelVal ,{|| SuperGetMv("MV_GFELAC1",.F.,"0") }, } )
	aAdd(aCampos,{"MV_GFELIM2", "Valor Máximo Frete Cálculo"                       	, "N", 10 , 2,,,{|| SuperGetMv("MV_GFELIM2",.F.,999999.99) }, } )
	aAdd(aCampos,{"MV_GFELAC2", "Ação Frete Cálculo Excedido"                      	, "C", 01 , 0,,aSelVal ,{|| SuperGetMv("MV_GFELAC2",.F.,"0") }, } )
	aAdd(aCampos,{"MV_GFELIM3", "% Max Frete/Valor Carga"                          	, "N", 08 , 2,,,{|| SuperGetMv("MV_GFELIM3",.F.,9999.99) }, } )
	aAdd(aCampos,{"MV_GFELAC3", "Ação % Frete/Valor Excedido"                     	, "C", 01 , 0,,aSelVal ,{|| SuperGetMv("MV_GFELAC3",.F.,"0") }, } )
	aAdd(aCampos,{"MV_GFELIM4", "Val Max Frete/Peso Carga (Ton)"                   	, "N", 09 , 3,,,{|| SuperGetMv("MV_GFELIM4",.F.,9999.999) }, } )
	aAdd(aCampos,{"MV_GFELAC4", "Ação Val Frete/Peso Excedido"                     	, "C", 01 , 0,,aSelVal ,{|| SuperGetMv("MV_GFELAC4",.F.,"0") }, } )
	aAdd(aCampos,{"MV_GFELAC5", "Ação ao Exceder o Limite do Contrato"				, "C", 01 , 0,,aSelVal ,{|| SuperGetMv("MV_GFELAC5",.F.,"0") }, } )
	aAdd(aCampos,{"MV_GFEAJDF", "Ajuste Cálculo com Documento Frete e/ou Lote de Provisão", "C", 01 , 0,,{"","1=Somente sem documento de frete e lote de provisão","2=Sem restrição"} ,{|| SuperGetMv("MV_GFEAJDF",.F.,"1") }, } )
	aAdd(aCampos,{"MV_GFE005" , "Documento de Carga vinculado Documento de Frete"   , "C", 01 , 0,,{"","1=Não permite recalcular","2=Permite recalcular somente com documento de frete não aprovado"} ,{|| SuperGetMv("MV_GFE005",.F.,"1") }, } )
	aAdd(aCampos,{"MV_GFEOVP" , "Operadora Vale Pedágio"                          	, "C", 14 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_GFEOVP).Or.GFEExistC("GU3",,M->MV_GFEOVP,"GU3->GU3_SIT=='1' .And. GU3->GU3_FORN == '1'")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO}, ,{|| SuperGetMv("MV_GFEOVP",.F.,"") }, } )
	aAdd(aCampos,{"MV_EMITMP" , "Código do Emitente"                             	, "C", 01 , 0,,{"","0=CNPJ/CPF","1=Numeração própria"}, {||SuperGetMv("MV_EMITMP",.F.,"1") }, {|| oModel:GetValue("GFEX000_01", "MV_INTGFE2") == "1" }, })
	aAdd(aCampos,{"MV_ESCTBAT", "Critério de seleção Cálculo Automático"      	 	, "C", 01 , 0,,{"","1=Menor Valor Frete","2=Menor Prazo Entrega"} 	  ,{|| SuperGetMv("MV_ESCTBAT",.F.,"1") }, })
	aAdd(aCampos,{"MV_ICMSST" , "ICMS ST"      	 									, "C", 01 , 0,,{"","1=com Direito a Crédito","2=sem Direito a Crédito"} 	  ,{|| SuperGetMv("MV_ICMSST",.F.,"1") },{|| oModel:GetValue("GFEX000_01", "MV_GFECRIC") == "1" }, })
	aAdd(aCampos,{"MV_TMSGFE" , "Redespachos"                                    	, "L", 01 , 0,,{.T.,.F.},{|| SuperGetMv("MV_TMSGFE",.F.,.F.) }, } )
	aAdd(aCampos,{"MV_MOTCAN" , "Motivo Cancelamento Agendamento"                  	, "C", 01 , 0,,{"1=Obrigatório","2=Opcional"}, {|| SuperGetMv("MV_MOTCAN",.F.,"1") }, })
	aAdd(aCampos,{"MV_GFEPVE" , "Permite incluir veículo na portaria?"           	, "C", 01 , 0,,{"1=Sim","2=Não"},{|| SuperGetMv("MV_GFEPVE",.F.,"2") }, } )
	aAdd(aCampos,{"MV_GFECPL" , "Código do veículo"              				   	, "C", 01 , 0,,{"1=Sugerido pelo sistema","2=Placa do veículo"},{|| SuperGetMv("MV_GFECPL",.F.,"2") }, } )
	aAdd(aCampos,{"MV_GFEPMT" , "Permite incluir motorista na portaria?"         	, "C", 01 , 0,,{"1=Sim","2=Não"},{|| SuperGetMv("MV_GFEPMT",.F.,"2") }, } )
	aAdd(aCampos,{"MV_GFEMVPE" , "Ação Mov Pendente"								, "C", 01 , 0,,{"","1=Nenhum","2=Alertar","3=Bloquear"},{|| SuperGetMv("MV_GFEMVPE",.F.,"1") }, } )
	aAdd(aCampos,{"MV_GFEPP01", "% Tolerância PBT"         							, "N", 03 , 0,,,{|| SuperGetMv("MV_GFEPP01",.F.,000) }, } )
	aAdd(aCampos,{"MV_GFEPP02", "% Tolerância Peso Mínimo Doc Carga"         		, "N", 03 , 0,,,{|| SuperGetMv("MV_GFEPP02",.F.,000) }, } )
	aAdd(aCampos,{"MV_GFEPP03", "% Tolerância Peso Máximo Doc Carga"         		, "N", 03 , 0,,,{|| SuperGetMv("MV_GFEPP03",.F.,000) }, } )
	aAdd(aCampos,{"MV_GFEPP04", "Permite relacionar mais de 1 romaneio nas movimentações", "L", 01 , 0,,{.T.,.F.},{|| SuperGetMv("MV_GFEPP04",.F.,.T.) }, } )
	aAdd(aCampos,{"MV_DSCTB" ,  "Contabilização Frete de Vendas"					, "C", 01 , 0, bValidDsCtb,{"","1=Fatura de Frete (Financeiro)","2=Documento de Frete (Recebimento)"} ,{|| SuperGetMv("MV_DSCTB",.F.,"1")}, } )
	aAdd(aCampos,{"MV_TMS2GFE", "Ocorrências"  				                      	, "C", 01 , 0,,{"","1=Sim","2=Não"},{|| AtuOcorr() }                      ,{|| !Empty(SuperGetMv("MV_INTTMS",.F.,.F.)) .And. SuperGetMv("MV_INTTMS",.F.,.F.)} } )
	aAdd(aCampos,{"MV_GFEI22" , "Atualização Automática"							, "C", 01 , 0,,{"","1=Sim","2=Não"},{|| SuperGetMv("MV_GFEI22" ,.F.,"2") },{|| oModel:GetValue("GFEX000_01", "MV_TMS2GFE") == "1" } } )
	aAdd(aCampos,{"MV_TMS3GFE", "Viagens"											, "C", 01 , 0,,{"","N=Não integra","F=Fechamento da viagem","S=Saída da viagem","C=Chegada da viagem"}, {|| SuperGetMV('MV_TMS3GFE',,'N') }, {|| !Empty(SuperGetMv("MV_INTTMS",.F.,.F.)) .And. SuperGetMv("MV_INTTMS",.F.,.F.)} })
	aAdd(aCampos,{"MV_REGOCO" , "Ocorrência Entrega"  				               	, "C", 01 , 0,,{"","1=sem Ocorrência","2=com Ocorrência"} ,{|| SuperGetMv("MV_REGOCO",.F.,"1") }, } )
	aAdd(aCampos,{"MV_CDTIPOE", "Código Ocorrência Entrega"							, "C", 06 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_CDTIPOE).Or.GFEExistC("GU5",,M->MV_CDTIPOE,"GU5->GU5_SIT=='1' .And. GU5->GU5_EVENTO == '4'")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},,{|| SuperGetMv("MV_CDTIPOE",.F.,"") },{|| FWFldGet("MV_REGOCO")== "2"} })
	aAdd(aCampos,{"MV_EMIPRO" , "Emitente Estimativa"  				               	, "C", 14 , 0,, ,{|| SuperGetMv("MV_EMIPRO",.F.,"") }, } )
	aAdd(aCampos,{"MV_TABPRO" , "Tabela Estimativa"  				               	, "C", 06 , 0,, ,{|| SuperGetMv("MV_TABPRO",.F.,"") }, } )
	aAdd(aCampos,{"MV_NEGPRO" , "Negociação Estimativa"  				           	, "C", 06 , 0,, ,{|| SuperGetMv("MV_NEGPRO",.F.,"") }, } )		
	aAdd(aCampos,{"MV_LOGCONT", "Gerar log de contabilização"						, "C", 01,  0,,{"","1=Sim", "2=Não"}, {|| SuperGetMv("MV_LOGCONT", , "2") }, })
	aAdd(aCampos,{"MV_PICOTR" , "PIS/COFINS Transferências"							, "C", 06 , 0,,{"","1=com Direito a Crédito", "2=sem Direito a Crédito"} ,{|| SuperGetMv("MV_PICOTR",.F.,"2") }, {|| oModel:GetValue("GFEX000_01", "MV_GFEPC") == "1" } } )
	aAdd(aCampos,{"MV_PDGPIS" , "Pedágio PIS/COFINS"								, "C", 01 , 0,,{"","1=Sim", "2=Não"} ,{|| SuperGetMv("MV_PDGPIS",.F.,"2") }, } )	// Não localizado uso dentro dos fontes.
	aAdd(aCampos,{"MV_GFEPF1" , "Condição para associar Pré-fatura"	         		, "C", 01 , 0,,{"","1=Confirmada", "2=Enviada"} ,{|| SuperGetMv("MV_GFEPF1",.F.,"1") }, } )
	aAdd(aCampos,{"MV_SERVTO" , "Serviço por Tipo de Ocorrência"              		, "C", 01 , 0,,{"","1=Sim","2=Não"} ,{|| SuperGetMv("MV_SERVTO",.F.,"1") }, } )
	aAdd(aCampos,{"MV_DSESIM" , "Permite Eliminação Cálculo Simulado"           	, "L", 01 , 0,,{.T.,.F.} ,{|| SuperGetMv("MV_DSESIM",.F.,.F.) }, } )	
	aAdd(aCampos,{"MV_CHVNFE" , "Consulta chave do CTE no Portal SEFAZ"      	  	, "L", 01 , 0,,{.T.,.F.} ,{|| SuperGetMv("MV_CHVNFE",.F.,.F.) }, } )
	aAdd(aCampos,{"MV_GFECVFA", "Calendário Vencimento Fatura Avulsa"               , "C", 01 , 0,,{"","1=Conforme Cadastro Emitente", "2=Nunca", "3=Sempre"} ,{|| SuperGetMv("MV_GFECVFA",.F.,'1') }, } )
	aAdd(aCampos,{"MV_ALQIRRF", "Aliquota IRRF"                                		, "N", 06 , 2,,, {|| SuperGetMv("MV_ALQIRRF",.F.,999.99) }, })
	aAdd(aCampos,{"MV_IRFPRED", "% Redução Base Calc. IRRF"                    		, "N", 06 , 2,,, {|| SuperGetMv("MV_IRFPRED",.F.,999.99) }, })
	aAdd(aCampos,{"MV_GFEROTR" , "Dt liberação Romaneio e Transportador obrigatório", "C", 01 , 0,,{"","1=Sim", "2=Não"} ,{|| SuperGetMv("MV_GFEROTR",.F.,"1") }, } )	// Não localizado uso dentro dos fontes.
	aAdd(aCampos,{"MV_ESPDF4" , "Espécie Doc Frete Subcontratação"                  , "C", 05 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_ESPDF4).Or.GFEExistC("GVT",,,"GVT->GVT_SIT=='1' ")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},, {|| SuperGetMv("MV_ESPDF4",.F.,'') }, })
	aAdd(aCampos,{"MV_AMBCTEC", "Ambiente Neogrid para recebimento CT-e"         	, "C", 01 , 0,,{"","1=Produção","2=Homologação"} ,{|| SuperGetMv("MV_AMBCTEC",.F.,"2") }, } )
	aAdd(aCampos,{"MV_AMBICOL", "Ambiente Neogrid para recebimento NF-e"          	, "C", 01 , 0,,{"","1=Produção","2=Homologação"} ,{|| SuperGetMv("MV_AMBICOL",.F.,"2") }, } )
	aAdd(aCampos,{"MV_CONFALL", "Confirma todos os documentos Colaboração?"       	, "C", 01 , 0,,{"","S=Sim","N=Não"} ,{|| SuperGetMv("MV_CONFALL",.F.,"N") }, } )
	aAdd(aCampos,{"MV_DOCSCOL", "Tipos de documentos que o TSS deve transmitir"   	, "C", 01 , 0,,{"","0=Todos","1=NFe","2=CTe","3=NFSe","4=Somente Recebimento"} ,{|| SuperGetMv("MV_DOCSCOL",.F.,"0") }, } )
	aAdd(aCampos,{"MV_NRETCOL", "Quantidade de registros por importação do TSS"   	, "N", 04 , 0,, ,{|| SuperGetMv("MV_NRETCOL",.F.,10) }, } )
	aAdd(aCampos,{"MV_USERCOL", "Usuário Totvs Colaboração"  					   	, "C", 50 , 0,, ,{|| SuperGetMv("MV_USERCOL",.F.,"") },  } )
	aAdd(aCampos,{"MV_PASSCOL", "Senha TOTVS Colaboração"  						   	, "C", 50 , 0,, ,{|| SuperGetMv("MV_PASSCOL",.F.,"") }, } )
	aAdd(aCampos,{"MV_SPEDCOL", "Utiliza Totvs Colaboração?"     					, "C", 01 , 0,,{"","S=Sim","N=Não"} ,{|| SuperGetMv("MV_SPEDCOL",.F.,"N") }, } )
	aAdd(aCampos,{"MV_SPEDURL", "URL de comunicação com TSS"						, "C", 200 , 0,, ,{|| SuperGetMv("MV_SPEDURL",.F.,"") }, })
	aAdd(aCampos,{"MV_GFETRP" , "Doc Carga x Romaneio"     					   		, "C", 01 , 0,,{"",'1=Sem restrição','2=Somente com o mesmo Transportador'} ,{|| SuperGetMv("MV_GFETRP",.F.,"1") }, })
	
	If GFXPR12137("MV_RECPRZ")
		aAdd(aCampos,{"MV_RECPRZ" , "Recalcula Prazos"     					   		, "C", 01 , 0,,{"0=Não",'1=Somente posterga','2=Antecipa e posterga'} ,{|| SuperGetMv("MV_RECPRZ",.F.,"1") }, })
	EndIf
	
	aAdd(aCampos,{"MV_CRIVAL" , "Valida critério com os itens do Doc. Carga"  		, "L", 01 , 0,,{.T.,.F.} ,{|| SuperGetMv("MV_CRIVAL",.F.,.F.) }, })
	aAdd(aCampos,{"MV_GFEOCO" , "Data retroativa para ocorrência entrega."  		, "C", 01 , 0,,{"","1=Não permite data retroativa","2=Somente ocorrências EDI","3=Todas ocorrências"} ,{|| SuperGetMv("MV_GFEOCO",.F.,"1") }, })
	aAdd(aCampos,{"MV_GFEIDTE", "Registrar Entrega"							  		, "L", 01 , 0,,{.T.,.F.} ,{|| SuperGetMv("MV_GFEIDTE",.F.,.F.) }, })
	aAdd(aCampos,{"MV_GFEOPC" , "Grava Peso Cubado Calculado?"  					, "C", 01 , 0,,{"","0=Não","1=Sim"} ,{|| SuperGetMv("MV_GFEOPC",.F.,"0") }, })
	aAdd(aCampos,{"MV_TCNEW"  , "Tipos de documento transmitidos via TOTVS Colaboração 2.0", "C", 30 , 0,, ,{|| SuperGetMv("MV_TCNEW",.F.,"") },{|| FwFldGet( "MV_SPEDCOL" )  == "S" .And. FwFldGet( "MV_ERPGFE" )  != "1" } } )
	aAdd(aCampos,{"MV_VERCTE" , "Versão do CTe para TOTVS Colaboração 2.0"			, "C", 10 , 0,, , {|| SuperGetMv("MV_VERCTE",.F.,"3.00") }, } )
	aAdd(aCampos,{"MV_NGOUT"  , "Diretório de saída TOTVS Colaboração 2.0"			, "C", 200, 0,, ,{|| SuperGetMv("MV_NGOUT",.F.,"") }, } )
	aAdd(aCampos,{"MV_NGINN"  , "Diretório de entrada TOTVS Colaboração 2.0"		, "C", 200, 0,, ,{|| SuperGetMv("MV_NGINN",.F.,"N") }, } )
	aAdd(aCampos,{"MV_GFETOTC", "Tempo de espera para processar retorno da consulta via TOTVS Colaboração 2.0", "N", 03, 0,, ,{|| SuperGetMv("MV_GFETOTC",.F.,25) }, })
	aAdd(aCampos,{"MV_TREENTR", "Local de entrega"							  		, "C", 01 , 0,,{"",'0=Origem e Destino','1=Trechos do Itinerário'},{|| SuperGetMv("MV_TREENTR",.F.,'0') }, })
	aAdd(aCampos,{"MV_ACGRRAT", "Ação para item sem Rateio Contábil"			  	, "C", 01 , 0,,aSelVal ,{|| SuperGetMv("MV_ACGRRAT",.F.,"1") }, })
	aAdd(aCampos,{"MV_MTNRERP", "Mantém Numeração Embarque ERP?"					, "C", 01 , 0,,{"","1=Sim","2=Não"},{|| SuperGetMv("MV_MTNRERP",.F.,"2") }, })
	aAdd(aCampos,{"MV_NGLIDOS", "Diretório de arquivos lidos Totvs Colaboração 2.0"	, "C", 200, 0,, ,{|| SuperGetMv("MV_NGLIDOS",.F.,"N") }, })	
	aAdd(aCampos,{"MV_DSINTTV", "Integração Tipo de Veículo?"						, "C", 01 , 0,,{"","1=Sim","2=Não"},{|| SuperGetMv("MV_DSINTTV",.F.,"2") }, })	
	aAdd(aCampos,{"MV_RENTNP" , "Registrar Entrega de Documentos de Carga"         	, "C", 1  , 0,,{"","1=Somente Trechos Pagos", "2=Todos os Trechos"}, {|| SuperGetMv("MV_RENTNP", .F., "1") }, })
	aAdd(aCampos,{"MV_NRPF"   , "Numeração Título Provisão"         				, "C", 1  , 0,,{"","1=Número Pré-fatura", "2=Filial+Número Pré-fatura"}, {|| SuperGetMv("MV_NRPF", .F., "1") }, })
	aAdd(aCampos,{"MV_TREDESP", "Redespachantes"         	                        , "C", 1  , 0,,{"","1=Não Identifica", "2=Opcional","3=Obrigatório"}, {|| SuperGetMv("MV_TREDESP", .F., "1") }, })
	aAdd(aCampos,{"MV_SITEDC" , "Situação Doc. Carga com Ocorrência Entrega"        , "C", 1  , 0,,{"","1=Trechos pagos entregues/último trecho", "2=Todos trechos entregues"}, {|| SuperGetMv("MV_SITEDC" , .F., "1") }, })

	If GFXCP12117("GU2_RECNFE") 
		aAdd(aCampos,{"MV_NFEENV" , "Envio XML NFe"           						, "C", 01 , 0,,{"","1=Não Enviar","2=Automática","3=Sob Demanda"},{|| SuperGetMv("MV_NFEENV",.F.,"1") }, } )
		aAdd(aCampos,{"MV_NFEDIR" , "Diretório XML NFe"								, "C", 200 , 0,,, {|| SuperGetMV("MV_NFEDIR",.F.,"") },{|| oModel:GetValue("GFEX000_01", "MV_NFEENV") <> "1" } })
	EndIf

	If GFXPR1212310("MV_PLROADE")
		aAdd(aCampos,{"MV_PLROADE" , "Permite liberar romaneio com data anterior a data de emissão doc carga" , "C", 01 , 0,,{"","1=Sim","2=Não"},{|| SuperGetMv("MV_PLROADE",.F.,"2") }, } )
	EndIf

	aAdd(aCampos,{"MV_APRCOP" , "Envio automático para aprovação após Registro Comparativo", "C", 1  , 0,,{"","0=Não enviar","1=Automático","2=Perguntar"}, {|| SuperGetMv("MV_APRCOP", .F., "0") },{|| oModel:GetValue("GFEX000_01", "MV_APRTAB") == "1" } })
	
	If GFEA065INP()
		aAdd(aCampos,{"MV_TESGFE" , "TES Doc. Frete"								, "C", 01 , 0,,{"","1=Atribuído.Sistema","2=Informado.Usuário","3=Atribuido CFOP/TES Itens NF"}	,{|| SuperGetMv("MV_TESGFE",.F.,"1") }, })
		aAdd(aCampos,{"MV_SIGFE"  , "Solicita Info Integração"  					, "C", 01 , 0,,{"","1=Sim", "2=Não"} 															,{|| SuperGetMv("MV_SIGFE" ,.F.,"2") }, })
	EndIf

	If GFXPR1212410("MV_INTFIS") 
		aAdd(aCampos,{"MV_INTFIS" , "Integração Fiscal"   							, "C", 01 , 0,,{"","1=Normal", "2=Pre-Nota", "3=Pre-CTE", "4=Ambos"} 							, {|| SuperGetMv("MV_INTFIS",.F.,"2") }, {|| oModel:GetValue("GFEX000_01", "MV_GFEI13") == "2" .OR. oModel:GetValue("GFEX000_01", "MV_GFEI14") == "2" }, })
	EndIf

	aAdd(aCampos,{"MV_GFEISS" , "Utilizar Imposto ISS"								, "C", 01 , 0,,{"","1=Sim","2=Não"},{|| SuperGetMv("MV_GFEISS",.F.,"1") }, })
	aAdd(aCampos,{"MV_GFEIRRF", "Utilizar Imposto IRRF"								, "C", 01 , 0,,{"","1=Sim","2=Não"},{|| SuperGetMv("MV_GFEIRRF",.F.,"1") }, })
	aAdd(aCampos,{"MV_GFEINSS", "Utilizar Imposto INSS/SEST"						, "C", 01 , 0,,{"","1=Sim","2=Não"},{|| SuperGetMv("MV_GFEINSS",.F.,"1") }, })
	aAdd(aCampos,{"MV_DFMLA"  , "Aprovação de Documentos de Frete via MLA"			, "C",	1  , 0,,{"","1=Não integra", "2=Integra com valor doc.", "3=Integra valor diferença prev./realizado"},{|| SuperGetMv("MV_DFMLA",.F.,"1") }, })
	aAdd(aCampos,{"MV_FTMLA"  , "Aprovação de Faturas via MLA"						, "C",	1  , 0,{|oModel| ValidFTMLA(oModel)},{"1=Não integra", "2=Integra com valor doc.", "3=Integra valor diferença prev./realizado", "4=Integra após aprovação no GFE (Liberação de pagamento)"},{|| SuperGetMv("MV_FTMLA",.F.,"1") }, })
	aAdd(aCampos,{"MV_TFMLA"  , "Integração MLA"                                   	, "C", 1  , 0,,{"","1=Sim","2=Não"},{|| SuperGetMv("MV_TFMLA",.F.,"2")}, })
	aAdd(aCampos,{"MV_DTROMV" , "Data de liberação do romaneio na partida da viagem", "C", 1  , 0,,{"","1=Dt. Criação","2=Dt. Partida"}, {|| SuperGetMv("MV_DTROMV", .F., "1") }, })
	aAdd(aCampos,{"MV_LOCTVEI", "Tipo Veículo Informado"							, "C", 1  , 0,,{"","1=Lotação Fracionada e Fechada","2=Lotação Fechada"},{|| SuperGetMv("MV_LOCTVEI",.F.,"1")}, } )
	aAdd(aCampos,{"MV_GFE006", "Tipo de Veículo para Cálculo"						, "C", 1  , 0,,{"","1=Sempre do Romaneio","2=Do Trecho Quando Preenchido"},{|| SuperGetMv("MV_GFE006",.F.,"1")}, } )
	aAdd(aCampos,{"MV_GFEVPRT", "Valida protocolo/assinatura do CTe?"				, "C", 1  , 0,,{"","1-Sim","2=Não"},{|| SuperGetMv("MV_GFEVPRT",.F.,"1")}, } )	
	aAdd(aCampos,{"MV_IMPPRO" , "Ação"												, "C", 1 , 0,,{"","1=Importar","2=Importar e Processar"} ,{|| SuperGetMv("MV_IMPPRO",.F.,"1") }, } )
	
	If GFXTB12117("GXN")
		aAdd(aCampos,{"MV_TPEST"  , "Tipo Estorno Provisão"							, "C", 01 , 0, bValidTPEST,, {|| SuperGetMV('MV_TPEST',,'1') }, } )
		aAdd(aCampos,{"MV_PEPRONO", "Período Saldo Prov. Normal (Meses)"			, "N", 04 , 0,,, {|| SuperGetMV('MV_PEPRONO',,3) }, {|| FwFldGet( "MV_TPEST" )  == "2" } })
		aAdd(aCampos,{"MV_PEPROES", "Período Saldo Prov. Estimativa (Meses)"		, "N", 04 , 0,,, {|| SuperGetMV('MV_PEPROES',,1) }, {|| FwFldGet( "MV_TPEST" )  == "2" } })
		aAdd(aCampos,{"MV_PEPROAD", "Período Saldo Prov. Adicional (Meses)"			, "N", 04 , 0,,, {|| SuperGetMV('MV_PEPROAD',,1) }, {|| FwFldGet( "MV_TPEST" )  == "2" } })
	EndIf
	
	aAdd(aCampos,{"MV_GFETROT", "Rotas coincidentes"								, "C", 01 , 0,,{"1=Escolher","2=Compor"}, {|| SuperGetMV('MV_GFETROT',.F.,'1') },  })
	
	If GFXTB12117("GWC")
		aAdd(aCampos,{"MV_GFEI21" , "Custos de Transporte"							, "C", 01 , 0,,{"","1=Sob demanda","2=Automática","3=Não integrar"}, {|| SuperGetMV('MV_GFEI21',,"3") }, {|| SuperGetMv("MV_INTTMS",.F.,.F.) == .T. } })
		aAdd(aCampos,{"MV_DESGFE1", "Despesa de Frete para Doc. Frete Normal"		, "C", 15 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_DESGFE1).Or.GFEExistC("DT7",,M->MV_DESGFE1,"1==1")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},{}, {|| SuperGetMV('MV_DESGFE1',,"") }, {|| SuperGetMv("MV_INTTMS",.F.,.F.) == .T. } })
		aAdd(aCampos,{"MV_DESGFE2", "Despesa de Frete para Doc. Frete Compl. Valor"	, "C", 15 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_DESGFE2).Or.GFEExistC("DT7",,M->MV_DESGFE2,"1==1")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},{}, {|| SuperGetMV('MV_DESGFE2',,"") }, {|| SuperGetMv("MV_INTTMS",.F.,.F.) == .T. } }) 
		aAdd(aCampos,{"MV_DESGFE3", "Despesa de Frete para Doc. Frete Compl. Imposto", "C", 15 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_DESGFE3).Or.GFEExistC("DT7",,M->MV_DESGFE3,"1==1")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},{}, {|| SuperGetMV('MV_DESGFE3',,"") }, {|| SuperGetMv("MV_INTTMS",.F.,.F.) == .T. } })
		aAdd(aCampos,{"MV_DESGFE4", "Despesa de Frete para Doc. Frete Reentrega"	, "C", 15 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_DESGFE4).Or.GFEExistC("DT7",,M->MV_DESGFE4,"1==1")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},{}, {|| SuperGetMV('MV_DESGFE4',,"") }, {|| SuperGetMv("MV_INTTMS",.F.,.F.) == .T. } })
		aAdd(aCampos,{"MV_DESGFE5", "Despesa de Frete para Doc. Frete Devolução"	, "C", 15 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_DESGFE5).Or.GFEExistC("DT7",,M->MV_DESGFE5,"1==1")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},{}, {|| SuperGetMV('MV_DESGFE5',,"") }, {|| SuperGetMv("MV_INTTMS",.F.,.F.) == .T. } })
		aAdd(aCampos,{"MV_DESGFE6", "Despesa de Frete para Doc. Frete de Redespacho", "C", 15 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_DESGFE6).Or.GFEExistC("DT7",,M->MV_DESGFE6,"1==1")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},{}, {|| SuperGetMV('MV_DESGFE6',,"") }, {|| SuperGetMv("MV_INTTMS",.F.,.F.) == .T. } })
		aAdd(aCampos,{"MV_DESGFE7", "Despesa de Frete para Doc. Frete de Serviço"	, "C", 15 , 0, {|A,B,C,D| FWINITCPO(A,B,C), LRETORNO := (Empty(M->MV_DESGFE7).Or.GFEExistC("DT7",,M->MV_DESGFE7,"1==1")),FWCLOSECPO(A,B,C,LRETORNO),LRETORNO},{}, {|| SuperGetMV('MV_DESGFE7',,"") }, {|| SuperGetMv("MV_INTTMS",.F.,.F.) == .T. } })
	EndIf

	aAdd(aCampos,{"MV_GFELPR" , "Habilita a geração de log antes da integração com o ERP Protheus?","C",01,0,,{"","1=Sim","2=Não"}, {|| SuperGetMv("MV_GFELPR",.F.,"2") }, })
	aAdd(aCampos,{"MV_GFE001" , "Ação sobre Documentos de Carga origem ERP"			, "C", 01 , 0,,, {|| SuperGetMV('MV_GFE001',,'1') }, } )
	
	If GFXCP12117("GV9_SITCON")
		aAdd(aCampos,	{"MV_INTTAB" , "Integração Tabela de Frete para Consulta Datasul", "C", 1  , 0,,{"","1=Não Integrar","2=Integrar"},{|| SuperGetMv("MV_INTTAB",.F.,"1")}, })
	EndIf
	
	aAdd(aCampos,	{"MV_INTFRE" , "Integra as informações de Frete na Nota Fiscal ERP Datasul", "C", 1  , 0,,{"","1=Não Integrar","2=Integrar"},{|| SuperGetMv("MV_INTFRE",.F.,"1")}, })

	aAdd(aCampos,{"MV_ICMSPA" , "Calcula ICMS de Pauta", "C", 01 , 0,,{"","1=Sim","2=Não"}, {|| SuperGetMV('MV_ICMSPA',,'2') }, })
	If GFXPR1212510("MV_GFECLCT") 
		aAdd(aCampos,{"MV_GFECLCT", "Calculo por Config. Tributos", "L", 01 , 0,,{.T.,.F.}, {|| SuperGetMv("MV_GFECLCT",.F.,.F.) }, })
	EndIf

	If IntGFEFrtBr(.F.) .And. GFXPR12131("MV_GFEFBPR")
		aAdd(aCampos,{"MV_GFEFBPR",STR0012,"C",TamSx3("GZY_PROD")[1] ,0,,                    ,{|| SuperGetMv("MV_GFEFBPR",.F.," ") }, })
		aAdd(aCampos,{"MV_GFEFBTE",STR0013,"C",02                    ,0,,_aTipEsp            ,{|| SuperGetMv("MV_GFEFBTE",.F.," ") }, })
		aAdd(aCampos,{"MV_GFEFBRA",STR0014,"C",01                    ,0,,                    ,{|| SuperGetMv("MV_GFEFBRA",.F.,"") }, })
		aAdd(aCampos,{"MV_GFEFBLT",STR0015,"C",01                    ,0,,{"","1=Sim","2=Não"},{|| SuperGetMv("MV_GFEFBLT",.F.,"1") }, })
		aAdd(aCampos,{"MV_GFEFBTP",STR0016,"C",02                    ,0,,_aTipPre            ,{|| SuperGetMv("MV_GFEFBTP",.F.," ") }, })
	EndIf

	nContF := Len(aCampos)
	For nCont := 1 To nContF
		oStruct:AddField(aCampos[nCont][2], aCampos[nCont][2], aCampos[nCont][1],aCampos[nCont][3],aCampos[nCont][4],aCampos[nCont][5],aCampos[nCont][6],aCampos[nCont][9],aCampos[nCont][7]/*@aVALUES*/,.F./*lOBRIG*/,aCampos[nCont][8]/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	Next

	oModel := MPFormModel():New("GFEX000", /*bPre*/, {|oModel| GFEX000VLD(oModel)}/*bPost*/, {|oModel|GFEX000COM(oModel)} /*bCommit*/, /*bCancel*/)
	oModel:AddFields("GFEX000_01", Nil,oStruct , /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:SetDescription("Parâmetros")
	oModel:GetModel("GFEX000_01"):SetDescription("Pré-faturas")
	oModel:SetPrimaryKey({"MV_MOTCAN"})

Return oModel

//------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView   := Nil
	Local oStruct := FWFormViewStruct():New()
	Local oModel  := FWLoadModel("GFEX000")
	Local aCampos := {}
	Local aFolder    := {}
	Local nCont      := 0
	Local nContF     := 0
	Local nContFolde := 0
	Local cCadERP    := SuperGetMv("MV_CADERP", .F., "1")  //
	Local cERPGFE    := SuperGetMv("MV_ERPGFE", .F., "2")  //
	Local aValues := {"","0=Nenhum","1=Filial","2=Tipo Operação","3=Item","4=Reg Comecial","5=Grupo Emitente","6=Tipo Doc Carga ","7=Classificação Frete","8=Tipo de Frete","9=Info Ctb 1","10=Info Ctb 2","11=Info Ctb 3","12=Info Ctb 4","13=Info Ctb 5","14=Representante","15=Unidade de Negócio","16=CFOP Item Doc Carga","17=Tipo de Serviço","18=Grupo de Transportador","19=Série Doc Carga"}
	Local aSelVal := {"","0=Nenhuma","1=Alertar","2=Desfazer Cálculo"}
	
	Static aCamposCam := {}
	
	aAdd(aCampos,{"MV_GFEOVP" , "Operadora Vale Pedágio"                        		, "C", "@!"            , "GU3FRN"  , "ExpRec"  , "ValPed"       , 																							, .T.})
	aAdd(aCampos,{"MV_GFETRP" , "Doc Carga x Romaneio"                   	   			, "C", "@!"            ,		   , "ExpRec"  , "DocCar"       , {"",'1=Sem restrição','2=Somente com o mesmo Transportador'}									, .T.})
	
	If GFXPR12137("MV_RECPRZ")
		aAdd(aCampos,{"MV_RECPRZ" , "Recalcula Prazos"                   	   			, "C", "@!"            ,		   , "ExpRec"  , "DocCar"       , {"0=Não",'1=Somente posterga','2=Antecipa e posterga'}									, .T.})
	EndIf

	aAdd(aCampos,{"MV_MOTCAN" , "Motivo Cancelamento Agendamento"               		, "C", "@!"            ,           , "PatPort" , "GpGeral"    	, {"1=Obrigatório","2=Opcional"}   															, .T.})
	aAdd(aCampos,{"MV_GFEPVE" , "Permite incluir veículo na portaria?"          		, "C", "@!"            ,           , "PatPort" , "GpPort"     	, {"","1=Sim","2=Não"}  	   																	, .T.})
	aAdd(aCampos,{"MV_GFECPL" , "Código do veículo"           							, "C", "@!"            ,           , "PatPort" , "GpPort"     	, {"","1=Sugerido pelo sistema","2=Placa do veículo"}											, .T.})
	aAdd(aCampos,{"MV_GFEPMT" , "Permite incluir motorista na portaria?"        		, "C", "@!"            ,           , "PatPort" , "GpPort"     	, {"","1=Sim","2=Não"}                                                            			   	, .T.})
	aAdd(aCampos,{"MV_GFEMVPE" , "Ação Mov Pendente"           							, "C", "@!"            ,           , "PatPort" , "GpPort"     	, {"","1=Nenhum","2=Alertar","3=Bloquear"}		, .T.})	
	aAdd(aCampos,{"MV_GFEPP01", "% Tolerância PBT"                        				, "N", "@E 999"        , 		   , "PatPort" , "GpVlPeso"     , 																							, .T.})
	aAdd(aCampos,{"MV_GFEPP02", "% Tolerância Peso Mínimo Doc Carga"          			, "N", "@E 999"        ,		   , "PatPort" , "GpVlPeso"     , 																							, .T.})
	aAdd(aCampos,{"MV_GFEPP03", "% Tolerância Peso Máximo Doc Carga"           			, "N", "@E 999"        ,		   , "PatPort" , "GpVlPeso"   	, 																							, .T.})
	aAdd(aCampos,{"MV_GFEPP04", "Permite relacionar mais de 1 romaneio nas movimentações", "C", "@!"   		   , 		   , "PatPort" , "GpGeral"		, 																							, .T.})

	aAdd(aCampos,{"MV_TPGRP1" , "Grupo Contábil 1"                              		, "C", "@!"			   ,           , "Contab"  ,              	, aValues                                                                                   , .T.})
	aAdd(aCampos,{"MV_TPGRP2" , "Grupo Contábil 2"                              		, "C", "@!"            ,           , "Contab"  ,              	, aValues                                                                                   , .T.})
	aAdd(aCampos,{"MV_TPGRP3" , "Grupo Contábil 3"                              		, "C", "@!"            ,           , "Contab"  ,              	, aValues                                                                                   , .T.})
	aAdd(aCampos,{"MV_TPGRP4" , "Grupo Contábil 4"                              		, "C", "@!"            ,           , "Contab"  ,              	, aValues                                                                                   , .T.})
	aAdd(aCampos,{"MV_TPGRP5" , "Grupo Contábil 5"                              		, "C", "@!"            ,           , "Contab"  ,              	, aValues                                                                                   , .T.})
	aAdd(aCampos,{"MV_TPGRP6" , "Grupo Contábil 6"                              		, "C", "@!"            ,           , "Contab"  ,              	, aValues                                                                                   , .T.})
	aAdd(aCampos,{"MV_TPGRP7" , "Grupo Contábil 7"                              		, "C", "@!"            ,           , "Contab"  ,              	, aValues                                                                                   , .T.})
	aAdd(aCampos,{"MV_PROVCON", "Provisão Contábil"                      	   			, "C", ""         	   ,           , "Contab"  ,    		    , {"","1=Despesa Total","2=Despesa menos Impostos Recuperáveis","3=Despesa menos Impostos","4=Despesa e Impostos Recuperáveis"} , .T.})
	aAdd(aCampos,{"MV_DTULFE" , "Data do Último Fechamento"                     		, "D", ""              ,           , "Contab"  ,              	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_TPGERA" , "Tipo de Geração Contábil"                      		, "C", "@!"            ,           , "Contab"  ,                , {"","1=Automática","2=Sob Demanda"}                                                          , .T.})

	aAdd(aCampos,{"MV_ESCTAB" , "Critério de seleção"                              		, "C", "@!"            ,           , "CalcFret", "GrpGrlFrt"    , {"","1=Escolha do Usuário","2=Menor Valor Frete","3=Menor Prazo Entrega"}                    , .T.})
	aAdd(aCampos,{"MV_ESCTBAT", "Critério de seleção Cálculo Automático"           		, "C", "@!"            ,           , "CalcFret", "GrpGrlFrt"  	, {"","1=Menor Valor Frete","2=Menor Prazo Entrega"}                                           , .T.})
	aAdd(aCampos,{"MV_GFETROT", "Rotas coincidentes"           							, "C", "@!"            ,           , "CalcFret", "GrpGrlFrt"  	, {"","1=Escolher","2=Compor"}                                           						, .T.})
	aAdd(aCampos,{"MV_CRIRAT" , "Critério de Rateio"                               		, "C", "@!"            ,           , "CalcFret", "GrpGrlFrt"  	, {"","1=Peso Mercadoria","2=Valor Mercadoria","3=Volume","4=Quantidade"}                 	, .T.})
	aAdd(aCampos,{"MV_CRIVAL" , "Valida critério com os itens do Doc. Carga"    		, "L", "@!"            ,           , "CalcFret", "GrpGrlFrt"   	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_ACGRRAT", "Ação para item sem Rateio Contábil"   		 			, "C", "@!"            ,           , "CalcFret", "GrpGrlFrt"   	, aSelVal                                                                                   , .T.})
	aAdd(aCampos,{"MV_GFEOPC" , "Grava Peso Cubado Calculado?"                	   		, "C", "@!"            ,		   , "CalcFret", "GrpGrlFrt"	, {"",'0=Não','1=Sim'}									, .T.})
	aAdd(aCampos,{"MV_TREENTR", "Local de Entrega"                 	   					, "N", "@!"            ,		   , "CalcFret", "GrpGrlFrt"	, {"",'0=Origem e Destino','1=Trechos do Itinerário'}												, .T.})
	aAdd(aCampos,{"MV_CRIRAT2", "Critério de Rateio Frete Mín Romaneio"            		, "C", "@!"            ,           , "CalcFret", "GrpFMR"     	, {"","1=Valor do Frete","2=Peso Carga","3=Valor Carga","4=Quantidade Itens","5=Volume Carga"} , .T.})
	aAdd(aCampos,{"MV_CRIRAT3", "Valor usado Rateio/Frete Minimo por Romaneio"  		, "C", "@!"            ,           , "CalcFret", "GrpFMR"     	, {"","1=Diferença","2=Total Frete Mínimo"}                                                    , .T.})
	aAdd(aCampos,{"MV_UMPESO" , "Unidade de Medida para Quilogramas"               		, "C", "@!"            ,           , "CalcFret", "GrpGrlFrt"  	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_GFECRIC", "ICMS Frete"                                    		, "C", "@!"            ,           , "CalcFret", "GrpGrlImp"  	, {"","1=com Direito a Crédito","2=sem Direito a Crédito"}                                     , .T.})
	aAdd(aCampos,{"MV_GFEGVR", "Realizar busca de tabelas de frete considerando tabela GVR (Região x Regiões)?"     , "C", "@!"            ,           , "CalcFret", "GrpPerfFr"     	, {"","1=Sim","2=Não"} , .T.})
	aAdd(aCampos,{"MV_GFEGUL", "Realizar busca de tabelas de frete considerando tabela GUL (Região x Faixa de CEP)?", "C", "@!"            ,           , "CalcFret", "GrpPerfFr"     	, {"","1=Sim","2=Não"} , .T.})
	aAdd(aCampos,{"MV_GFEVIN", "Realizar busca de tabelas de frete considerando tabelas de tipo vínculo?"           , "C", "@!"            ,           , "CalcFret", "GrpPerfFr"     	, {"","1=Sim","2=Não"} , .T.})
	aAdd(aCampos,{"MV_GFELAC5", "Ação ao Exceder o Limite do Contrato"    				, "C", "@!"      		,           , "CalcFret", "GrpCtrFrt"    , aSelVal , .T.})	
	aAdd(aCampos,{"MV_CRDPAR" , "Crédito ICMS"											, "C", "@!"				,			, "CalcFret", "GrpGrlImp"	, {"","1=Total","2=Parcial, conforme Itens Nota"}													, .T.})
	aAdd(aCampos,{"MV_ICMSST" ,  "ICMS ST"                                      		, "C", "@!"            	,           , "CalcFret", "GrpGrlImp"  	, {"","1=com Direito a Crédito","2=sem Direito a Crédito"}                                     , .T.})
	aAdd(aCampos,{"MV_GFEPC"  , "PIS/COFINS Frete"                              		, "C", "@!"            	,           , "CalcFret", "GrpGrlImp"  	, {"","1=com Direito a Crédito","2=sem Direito a Crédito"}                                     , .T.})
	aAdd(aCampos,{"MV_PICOTR" , "PIS/COFINS Transferências"                     		, "C", "@!"            	,           , "CalcFret", "GrpGrlImp"  	, {"","1=com Direito a Crédito","2=sem Direito a Crédito"}                               		, .T.})
	aAdd(aCampos,{"MV_PCPIS"  , "Alíquota PIS"                                  		, "N", "@E 99.99"      	,           , "CalcFret", "GrpGrlImp"  	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_PCCOFI" , "Alíquota COFINS"                               		, "N", "@E 99.99"      	,           , "CalcFret", "GrpGrlImp"  	,                                                                                           , .T.})
   	aAdd(aCampos,{"MV_ISSBAPI", "ISS no PIS/COFINS"                             		, "C", "@!"            	,           , "CalcFret", "GrpGrlImp"  	, {"","1=Manter","2=Retirar"}                                                                  , .T.})
   	aAdd(aCampos,{"MV_PISDIF"  , "Alíquota PIS Diferenciada"                         	, "N", "@E 99.9999"     ,           , "CalcFret", "GrpGrlImp"  	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_COFIDIF" , "Alíquota COFINS Diferenciada"                      	, "N", "@E 99.9999"     ,           , "CalcFret", "GrpGrlImp"  	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_ICMBAPI", "ICMS Ret no PIS/COFINS"                             	, "C", "@!"           	,           , "CalcFret", "GrpGrlImp"  	, {"","1=Manter","2=Retirar Retido","3=Retirar Total"}                                                                  , .T.})
	aAdd(aCampos,{"MV_DIMRET",  "Imp Retido Componente"                             	, "C", "@!"            	,           , "CalcFret", "GrpGrlFrt"  	, {"","1=Manter","2=Retirar"}                                                                  , .T.})	
	aAdd(aCampos,{"MV_DRTLOG" , "Diretório LOG"                                 		, "C", ""            	,           , "CalcFret", "GrpGrlLog"  	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_LOGCALC", "Gera log de cálculo?"                          		, "C",                 	,           , "CalcFret", "GrpGrlFrt"  	, {"","1=Sim","2=Não"}                                                                        	, .T.})
	aAdd(aCampos,{"MV_LOCTVEI", "Tipo Veículo Informado"                        		, "C",		           	,           , "CalcFret", "GrpBscNeg"  	, {"","1=Lotação Fracionada e Fechada","2=Lotação Fechada"}									, .T.})
	aAdd(aCampos,{"MV_GFE006" , "Tipo Veículo Para Cálculo"                     		, "C",                 	,           , "CalcFret", "GrpBscNeg"  	, {"","1=Sempre do Romaneio","2=Do Trecho Quando Preenchido"}									, .T.})
	aAdd(aCampos,{"MV_CALDEV" , "Valor Devolução"                               		, "C", "@!"            	,           , "CalcFret", "GrpGrlAdf"  	, {"","1=Permite Alterar","2=Não Permite Alterar"}                                             , .T.})
	aAdd(aCampos,{"MV_CALREN" , "Valor Reentrega"                               		, "C", "@!"            	,           , "CalcFret", "GrpGrlAdf"  	, {"","1=Permite Alterar","2=Não Permite Alterar"}                                             , .T.})
	aAdd(aCampos,{"MV_CALSER" , "Valor Serviço"                                 		, "C", "@!"            	,           , "CalcFret", "GrpGrlAdf"  	, {"","1=Permite Alterar","2=Não Permite Alterar"}                                             , .T.})
	aAdd(aCampos,{"MV_GFELIM1", "Valor Máximo Frete Romaneio"                   		, "N", "@E 999,999.99" 	,           , "CalcFret", "GrpRomFrt"  	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_GFELAC1", "Ação Frete Romaneio Excedido"                  		, "C", "@!"            	,           , "CalcFret", "GrpRomFrt"  	, aSelVal                                            , .T.})
	aAdd(aCampos,{"MV_GFELIM2", "Valor Máximo Frete Cálculo"                    		, "N", "@E 999,999.99" 	,           , "CalcFret", "GrpClcFrt"  	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_GFELAC2", "Ação Frete Cálculo Excedido"                   		, "C", "@!"            	,           , "CalcFret", "GrpClcFrt"  	, aSelVal                                            , .T.})
	aAdd(aCampos,{"MV_GFELIM3", "% Max Frete/Valor Carga"                       		, "N", "@E 9,999.99"   	,           , "CalcFret", "GrpClcFrt"  	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_GFELAC3", "Ação % Frete/Valor Excedido"                   		, "C", "@!"            	,           , "CalcFret", "GrpClcFrt"  	, aSelVal                                            , .T.})
	aAdd(aCampos,{"MV_GFELIM4", "Val Max Frete/Peso Carga (Ton)"                		, "N", "@E 9,999.999"  	,           , "CalcFret", "GrpClcFrt"  	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_GFELAC4", "Ação Val Frete/Peso Excedido"                  		, "C", "@!"            	,           , "CalcFret", "GrpClcFrt"  	, aSelVal                                            , .T.})
	
	If GFXPR1212310("MV_CALRET")
		aAdd(aCampos,{"MV_CALRET" , "Atribui % de Devolução no Cálculo de Retorno"      , "C",                 	,           , "CalcFret", "GrpClcFrt"  	, {"","1=Sim","2=Não"}								 , .T.})
	EndIf

	aAdd(aCampos,{"MV_GFEAJDF", "Ajuste Cálculo com Documento Frete e/ou Lote de Provisão", "C", "@!"			   ,           , "CalcFret", "GrpGrlFrt"  	, {"","1=Somente sem documento de frete e lote de provisão","2=Sem Restrição"}                     , .T.})
	aAdd(aCampos,{"MV_ICMSPA" , "Calcula ICMS de Pauta"                     			, "C", "@!"            ,           , "CalcFret" , "GrpGrlImp"     	, {"","1=Sim","2=Não"}  	   																	, .T.})
	If GFXPR1212510("MV_GFECLCT") 
		aAdd(aCampos,{"MV_GFECLCT" , "Calc. Imposto Config. Tributos"          			, "L", "@!"            ,           , "CalcFret" , "GrpGrlImp"     	,   	   										, .T.})
	EndIf
	aAdd(aCampos,{"MV_GFE005" , "Documento de Carga X Documento de Frete"         		, "C", "@!"			   ,           , "CalcFret", "GrpGrlFrt"  	, {"","1=Não permite recalcular","2=Permite recalcular somente com documento de frete não aprovado"}, .T.})
	
	aAdd(aCampos,{"MV_TIPREG" , "Regionalização"                                		, "C", "@!"            ,           , "TabFrete",              	, {"","1=de Terceiros","2=Própria"}                                                            , .T.})
	aAdd(aCampos,{"MV_GFETAB1", "Estrutura de Tabelas de Frete"                 		, "C", "@!"            ,           , "TabFrete",              	, {"","1=Uma por Transportador","2=Sem restrição"}                                             , .T.})
	aAdd(aCampos,{"MV_APRTAB" , "Controle de Aprovação"                         		, "C", "@!"            ,           , "TabFrete",              	, {"","1=Sim","2=Não"}                                                                         , .T.})
	aAdd(aCampos,{"MV_APRCOP" , "Envio aprovação após Registro Comparativo"				, "C", "@!"            ,           , "TabFrete",               , {"","0=Não enviar","1=Automático","2=Perguntar"}                                             , .T.})
	aAdd(aCampos,{"MV_SERVTO" , "Serviço por Tipo de Ocorrência"                		, "C", "@!"            ,           , "TabFrete",              	, {"","1=Sim","2=Não"}                                                                         , .T.})

	aAdd(aCampos,{"MV_PFENTR" , "Registro de Entrega"                           		, "C", "@!"            ,           , "PreFat"  ,              	, {"","0=Prova de Entrega","1=Informação de Entrega","2=Nenhuma"}                                                            , .T.})

	aAdd(aCampos,{"MV_OBNENT" , "Cálculo Normal"                                		, "C", "@!"            ,           , "DocFret" ,               	, {"","1=Obrigatório","2=Opcional"}                                                            , .T.})
	aAdd(aCampos,{"MV_OBREDE" , "Cálculo Redespacho"                                	, "C", "@!"            ,           , "DocFret" ,            	, {"","1=Obrigatório","2=Opcional"}                                                            , .T.})
	aAdd(aCampos,{"MV_OBCOMP" , "Cálculo Complementar"                          		, "C", "@!"            ,           , "DocFret" ,               	, {"","1=Obrigatório","2=Opcional"}                                                            , .T.})
	aAdd(aCampos,{"MV_OBREEN" , "Cálculo Reentrega"                             		, "C", "@!"            ,           , "DocFret" ,            	, {"","1=Obrigatório","2=Opcional"}                                                            , .T.})
	aAdd(aCampos,{"MV_OBDEV"  , "Cálculo Devolução"                             		, "C", "@!"            ,           , "DocFret" ,            	, {"","1=Obrigatório","2=Opcional"}                                                            , .T.})
	aAdd(aCampos,{"MV_OBSERV" , "Cálculo Serviços"                              		, "C", "@!"            ,           , "DocFret" ,            	, {"","1=Obrigatório","2=Opcional"}                                                            , .T.})
	aAdd(aCampos,{"MV_CFOFR1" , "CFOP ICMS Estadual"                            		, "C", "@!"            ,           , "DocFret" ,            	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_CFOFR2" , "CFOP ICMS Interestadual"                       		, "C", "@!"            ,           , "DocFret" ,            	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_CFOFR3" , "CFOP ISS Mesmo Município"                      		, "C", "@!"            ,           , "DocFret" ,            	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_CFOFR4" , "CFOP ISS Outro Município"								, "C", "@!"            ,           , "DocFret" ,            	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_GFEVLDT", "Identificação Única Doc Frete"                 		, "C", "@!"            ,           , "DocFret" ,            	, {"","1=Número","2=Número e Série","3=Número, Série e Data de Emissão"}                       , .T.})
	aAdd(aCampos,{"MV_VLCNPJ" , "Transportador Doc Frete"                       		, "C", "@!"            ,           , "DocFret" ,            	, {"","1=Somente Transp Nota ", "2=Considera mesma raiz CNPJ"}                       			, .T.})
	aAdd(aCampos,{"MV_GFEVLFT", "Identificação Única Fatura"                    		, "C", "@!"            ,           , "DocFret" ,            	, {"","1=Número","2=Número e Série","3=Número, Série e Data de Emissão"}                       , .T.})
	aAdd(aCampos,{"MV_PDGPIS" , "Pedágio PIS/COFINS"		 				       		, "C", "@!" 		   , 		   , "DocFret" ,            	, {"","1=Sim", "2=Não"} 																				, .T. })
	aAdd(aCampos,{"MV_GFEPF1" , "Condição para associar Pré-fatura"	         			, "C", "@!"            ,           , "DocFret" ,           		, {"","1=Confirmada", "2=Enviada"}															, .T.})
	aAdd(aCampos,{"MV_CHVNFE" , "Consulta chave do CTE no Portal SEFAZ"         		, "L", "@!"            ,           , "DocFret" ,           		, 															, .T.})
	aAdd(aCampos,{"MV_GFECVFA", "Calendário Vencimento Fatura Avulsa"         			, "C", "@!"            ,           , "DocFret" , 				, {"","1=Conforme Cadastro Emitente", "2=Nunca", "3=Sempre"}, .T.})	
	aAdd(aCampos,{"MV_ALQIRRF", "Aliquota de calc. IRRF"   								, "N", "@E 999"		   , 		   , "DocFret" , , , .T.})
	aAdd(aCampos,{"MV_IRFPRED", "% Redução Base Calc. IRRF"         					, "N", "@E 999"		   , 		   , "DocFret" , , , .T.})
	aAdd(aCampos,{"MV_ESPDF4" , "Espécie Doc Frete Subcontratação"                      , "C", "@!"            , "GVTFRT"  , "DocFret"  ,              	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_GFEROTR", "Dt liberação Romaneio e Transportador obrigatórios"	, "C", "@!"            ,           , "DocFret" , ""             , {"","1=Sim","2=Não"}                                                                         , .T.})	

	aAdd(aCampos,{"MV_DCOUT"  , "Confere Dados da Carga?"                       		, "C", "@!"            ,           , "AudiFret", "GrpDF"      	, {"","1=Sim","2=Não"}                                                                         , .T.})
	aAdd(aCampos,{"MV_DCABE"  , "Valor Detalhado"                               		, "C", "@!"            ,           , "AudiFret", "GrpDF"      	, {"","1=Sim","2=Não"}                                                                         , .T.})
	aAdd(aCampos,{"MV_DCTOT"  , "Valor Total"                                   		, "C", "@!"            ,           , "AudiFret", "GrpDF"      	, {"","1=Sim","2=Não"}                                                                         , .T.})
	If GFXPR1212510("MV_DMIMP")
		aAdd(aCampos,{"MV_DMIMP"  , "Valor Imposto"                                  		, "C", "@!"            ,           , "AudiFret", "GrpDF"      	, {"","1=Sim","2=Não"}                                                                         , .T.})
	EndIf
	aAdd(aCampos,{"MV_DCVAL"  , "Diferença Máxima de Valor"                     		, "N", "@E 99,999.99"  ,           , "AudiFret", "GrpDF"      	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DCPERC" , "Diferença Máxima de Percentual"                		, "N", "@E 999.99"     ,           , "AudiFret", "GrpDF"      	,                                                                                           , .T.})
	If GFXPR1212510("MV_DMVAL")
		aAdd(aCampos,{"MV_DMVAL"  , "Diferença Máxima de Valor a Menor"            		, "N", "@E 99,999.99"  ,           , "AudiFret", "GrpDF"      	,                                                                                           , .T.})
	EndIf
	If GFXPR1212510("MV_DMPERC")
		aAdd(aCampos,{"MV_DMPERC" , "Diferença Máxima de Percentual a Menor"       		, "N", "@E 999.99"     ,           , "AudiFret", "GrpDF"      	,                                                                                           , .T.})
	EndIf
	aAdd(aCampos,{"MV_DCNEG"  , "Diferença Menor"                               		, "C", "@!"            ,           , "AudiFret", "GrpDF"      	, {"","1=Aprovar","2=Conferir"}                                                                , .T.})
	aAdd(aCampos,{"MV_CFCONPG", "Data Vencimento"                               		, "C", "@!"            ,           , "AudiFret", "GrpFat"     	, {"","1=Sim","2=Não"}                                                                         , .T.})
	aAdd(aCampos,{"MV_CFAGRUP", "Agrupamento"                                   		, "C", "@!"            ,           , "AudiFret", "GrpFat"     	, {"","1=Sim","2=Não"}                                                                         , .T.})
	aAdd(aCampos,{"MV_CFVLFAT", "Valor"                                         		, "C", "@!"            ,           , "AudiFret", "GrpFat"     	, {"","1=Sim","2=Não"}                                                                         , .T.})
	aAdd(aCampos,{"MV_CFVLVAR", "Diferença Máxima de Valor"                     		, "N", "@E 99,999.99"  ,           , "AudiFret", "GrpFat"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_CFPCVAR", "Diferença Máxima de Percentual"                		, "N", "@E 999.99"     ,           , "AudiFret", "GrpFat"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_GFE011" , "Auditoria Documentos Complementares"           		, "C", "@!" 	       ,           , "AudiFret", "GrpDF"     	, {"","1=Auditar normalmente","2=Exigir aprovação"}                                            , .T.})
	aAdd(aCampos,{"MV_GFE012" , "Condição Agendamento Doc Carga"           				, "C", "@!" 	       ,           , "PatPort" , "GpGeral"     	, {"","0=Sem Restrição","1=Em Romaneio","2=Em Romaneio Liberado ou Encerrado"}                                            , .T.})
	aAdd(aCampos,{"MV_AUDINF" , "Auditoria Frete Combinado"           					, "C", "@!" 	       ,           , "AudiFret", "GrpDF"     	, {"","1=Auditar normalmente","2=Exigir aprovação"}                                            , .T.})
	aAdd(aCampos,{"MV_GFEDCFA" , "Controle de Compensação de Divergências"				, "C", "@!"				,          , "AudiFret", "GrpDF"      	, {"","1=Sim","2=Não"}, .T.})
	aAdd(aCampos,{"MV_PFOBRIG", "PF Obrigatória"          				      			, "C", "@!"		       ,           , "AudiFret", "GrpFat"     	, {"","1=Sim","2=Não"}                                                                     , .T.})
	aAdd(aCampos,{"MV_APUIRF" , "Apuração IRRF/INSS"                                  	, "C", "@!" 		   , 		   , "ContAuto", "GpIrrf"		, {"","1=Centralizado","2=por Filial"}															, .T.})
	aAdd(aCampos,{"MV_GFE016" , "Data de Referência para apuração IRRF"                 , "C", "@!" 		   , 		   , "ContAuto", "GpIrrf"		, {"","1=Data de Criação","2=Data de Vencimento"}												, .T.})
	aAdd(aCampos,{"MV_BASIRF" , "% Base IRRF"                                   		, "N", "@E 999.99"     ,           , "ContAuto", "GpIrrf"       ,                                                                                           	, .T.})
	aAdd(aCampos,{"MV_DEDINS" , "INSS Base IRRF"                                		, "C", "@!"            ,           , "ContAuto", "GpIrrf"       , {"","1=Descontar","2=Manter"}                                                                , .T.})
	aAdd(aCampos,{"MV_DEDSES" , "SEST/SENAT Base IRRF"                                	, "C", "@!"            ,           , "ContAuto", "GpIrrf"       , {"","1=Descontar","2=Manter"}                                                                , .T.})
	aAdd(aCampos,{"MV_MINIRF" , "Valor Mínimo IRRF"                             		, "N", "@E 99,999.99"  ,           , "ContAuto", "GpIrrf"       ,                                                                                           , .T.})
	aAdd(aCampos,{"MV_BASINS" , "% Base INSS"                                   		, "N", "@E 999.99"     ,           , "ContAuto", "GpInss"       ,                                                                                           , .T.})
	aAdd(aCampos,{"MV_PCINAU" , "% INSS Autônomo"                               		, "N", "@E 99.99"      ,           , "ContAuto", "GpInss"       ,                                                                                           , .T.})
	aAdd(aCampos,{"MV_VLMXRE" , "Valor Máximo de INSS"                          		, "N", "@E 99,999.99"  ,           , "ContAuto", "GpInss"       ,                                                                                         	, .T.})
	aAdd(aCampos,{"MV_PCINEM" , "% INSS Embarcador"                             		, "N", "@E 999.99"     ,           , "ContAuto", "GpInss"       ,                                                                                           , .T.})
	If GFXPR1212310("MV_PCSEST")
		aAdd(aCampos,{"MV_PCSEST" , "% SEST"                               		        , "N", "@E 99.99"      ,       	   , "ContAuto", "GpOutros"  	,                                                                                           , .T.})
	EndIf
	If GFXPR1212310("MV_PCSENA")
		aAdd(aCampos,{"MV_PCSENA" , "% SENAT"                              		        , "N", "@E 99.99"      ,       	   , "ContAuto", "GpOutros"  	,                                                                                           , .T.})
	EndIf
	aAdd(aCampos,{"MV_ESPDF1" , "Espécie CTR"                                   		, "C", "@!"            , "GVTFRT"  , "IntEDI"  ,              	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_ESPDF3" , "Espécie CT-e"                                  		, "C", "@!"            , "GVTFRT"  , "IntEDI"  ,              	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_ESPDF2" , "Espécie NFST"                                  		, "C", "@!"            , "GVTFRT"  , "IntEDI"  ,              	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_REGOCO" , "Ocorrência Entrega"                            		, "C", "@!"            ,    	   , "IntEDI"  ,              	, {"","1=sem Ocorrência","2=com Ocorrência"}		                                       	, .T.})
	aAdd(aCampos,{"MV_CDTIPOE", "Código Ocorrência Entrega"                     		, "C", "@!"            , "GU5ENT"  , "IntEDI"  ,              	, 													                                       	, .T.})
	aAdd(aCampos,{"MV_GFEOCO" , "Data retroativa para ocorrência entrega"    			, "C", "@!"            ,           , "IntEDI"	,				, {"","1=Não permite data retroativa","2=Somente ocorrências EDI","3=Todas ocorrências"}	, .T.})
	aAdd(aCampos,{"MV_GFEEDIL", "Tipo de geração de Log"                        		, "C", "@!"            ,           , "IntEDI"  ,              	, {"", "1=Não Gerar","2=Normal","3=Modo Debug","4=Modo Console"}                           , .T.})
	aAdd(aCampos,{"MV_CDCLFR" , "Classificação de Frete Padrão"                 		, "C", "@!"            , "GUB"     , "IntERP"  , "PdSug"      	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_CADERP" , "Origem dos Cadastros"                          		, "C", "@!"            ,           , "IntERP"  , "OpInt1"     	, {"","1=ERP","2=SIGAGFE"}                                                                 , .T.})
	aAdd(aCampos,{"MV_ERPGFE" , "ERP Integrado"                                 		, "C", "@!"            ,           , "IntERP"  , "OpInt1"     	, {"","1=Datasul","2=Protheus","3=RM","4=Logix","5=Outro"}                                 , .T.})
	aAdd(aCampos,{"MV_GFEI13" , "Doc. Frete Fiscal"                             		, "C", "@!"            ,           , "IntERP"  , "OpInt1"     	, {"","1=sob Demanda","2=Automática","3=Não integrar"}                                     , .T.})
	aAdd(aCampos,{"MV_GFEI14" , "Doc. Frete Custo"                              		, "C", "@!"            ,           , "IntERP"  , "OpInt1"     	, {"","1=sob Demanda","2=Automática","3=Não integrar"}                                     , .T.})
	aAdd(aCampos,{"MV_GFEI15" , "Pré-fatura Financeiro"                         		, "C", "@!"            ,           , "IntERP"  , "OpInt1"     	, {"","1=sob Demanda","2=Automática","3=Não integrar"}                                     , .T.})
	aAdd(aCampos,{"MV_GFEI16" , "Fatura Financeiro"                             		, "C", "@!"            ,           , "IntERP"  , "OpInt1"     	, {"","1=sob Demanda","2=Automática","3=Não integrar"}                                     , .T.})
	aAdd(aCampos,{"MV_GFEI23" , "Fiscal Pré-requisito para Atualizar Fatura com Financ.", "C", "@!"            ,           , "IntERP"  , "OpInt1"     	, {"","1=Sim","2=Não"}                                    								  , .T.})
	aAdd(aCampos,{"MV_GFEI17" , "Contrato Financeiro"                           		, "C", "@!"            ,           , "IntERP"  , "OpInt1"     	, {"","1=sob Demanda","2=Automática","3=Não integrar"}                                     , .T.})
	aAdd(aCampos,{"MV_GFEI18" , "Contrato Custo"                                		, "C", "@!"            ,           , "IntERP"  , "OpInt1"     	, {"","1=sob Demanda","2=Automática","3=Não integrar"}                                     , .T.})
	aAdd(aCampos,{"MV_XMLDIR" , "Diretório do XML Totvs Colaboração"            		, "C", ""              ,           , "TotvsCol", "ComunTC10"    ,                                                                                           , .T.})
	aAdd(aCampos,{"MV_EAIURL" , "Url EAI"                                       		, "C", ""              ,           , "IntERP"  , "Comun"      	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_EAIPORT", "Porta EAI"                                     		, "C", ""              ,           , "IntERP"  , "Comun"      	,                                                                                           , .T.})

	aAdd(aCampos,{"MV_SPEDCOL", "Utiliza Totvs Colaboração?"     				  	 	, "C", "@!"            ,           , "TotvsCol", "ComunTC"     	, {"","S=Sim","N=Não"}                                                                  	, .T.})  
	aAdd(aCampos,{"MV_GFEVPRT", "Valida protocolo/assinatura do CTe?"     				, "C", "@!"            ,           , "TotvsCol", "ComunTC"     	, {"","1=Sim","2=Não"}                                                                  	, .T.})
	aAdd(aCampos,{"MV_IMPPRO",  "Ação"													, "C", "@!"            ,           , "TotvsCol", "ComunTC"     	, {"","1=Importar","2=Importar e Processar"}                              			, .T.})
	aAdd(aCampos,{"MV_AMBCTEC", "Ambiente Neogrid para recebimento CT-e"        		, "C", "@!"            ,           , "TotvsCol", "ComunTC10"     , {"","1=Produção","2=Homologação"}                                                       , .T.})
	aAdd(aCampos,{"MV_AMBICOL", "Ambiente Neogrid para recebimento NF-e"        		, "C", "@!"            ,           , "TotvsCol", "ComunTC10"     , {"","1=Produção","2=Homologação"}                                                       , .T.})
	aAdd(aCampos,{"MV_CONFALL", "Confirma todos os documentos Colaboração?"      		, "C", "@!"            ,           , "TotvsCol", "ComunTC10"     , {"","S=Sim","N=Não"}                                                                    , .T.})
	aAdd(aCampos,{"MV_DOCSCOL", "Tipos de documentos que o TSS deve transmitir" 		, "C", "@!"            ,           , "TotvsCol", "ComunTC10"     , {"","0=Todos","1=NFe","2=CTe","3=NFSe","4=Somente Recebimento"}                         , .T.})
	aAdd(aCampos,{"MV_SPEDURL", "URL de comunicação com TSS"  				  		 	, "C", "@!"            ,           , "TotvsCol", "ComunTC10"     ,                                                                                      	, .T.})
	aAdd(aCampos,{"MV_NRETCOL", "Quantidade de registros por importação do TSS" 		, "N", "@E 9999"       ,           , "TotvsCol", "ComunTC10"     ,                                                                                          , .T.})
	aAdd(aCampos,{"MV_USERCOL", "Usuário"						  						, "C", "@!"            ,           , "TotvsCol", "ComunTC10"     ,                                                                                      	, .T.})
	aAdd(aCampos,{"MV_PASSCOL", "Senha"						         				   	, "C", "@*"            ,           , "TotvsCol", "ComunTC10"     ,                                                                                  		, .T.})
	
	aAdd(aCampos,{"MV_INTGFE" , "GFE Ativo"                                     		, "L", "@!"            ,           , "IntProt" , "GpGerais"   	 ,                                                                                          , .T.})
	aAdd(aCampos,{"MV_INTGFE2", "Modo Integração"                               		, "C", "@!"            ,           , "IntProt" , "GpGerais"   	 , {"","1=Direta","2=Com EAI/ESB"}                                                         , .T.})
	aAdd(aCampos,{"MV_EMITMP" , "Código do Emitente"                            		, "C", "@!"            ,           , "IntProt" , "GpGerais"   	 , {"","0=CNPJ/CPF","1=Numeração Própria"}                                                 , .T.})
	aAdd(aCampos,{"MV_CDTPOP" , "Tipo Operação Padrão"                          		, "C", "@!"            , "GV4"     , "IntProt" , "GpGerais"      ,                                                                                         , .T.})
	aAdd(aCampos,{"MV_GFEI11" , "Nota Fiscal de Saída"                          		, "C", "@!"            ,           , "IntProt" , "GpFatura"   	 , {"","1=Integrar","2=Não integrar"}                                                      , .T.})
	aAdd(aCampos,{"MV_FATGFE" , "Impede Faturamento?"                           		, "C", "@!"            ,           , "IntProt" , "GpFatura"   	 , {"","1=Sim","2=Nao"}                                                                    , .T.})
	aAdd(aCampos,{"MV_GFEVLIT", "Valor do Item"                          	   			, "C", "@!"            ,           , "IntProt" , "GpFatura"   	, {"","1=Valor Bruto","2=Valor Total"}                                                        	, .T.})
	aAdd(aCampos,{"MV_GFEIDTE", "Registrar Entrega"                          	   		, "L", "@!"            ,           , "IntProt" , "GpFatura"   	, 										                                                       	, .T.})
	aAdd(aCampos,{"MV_GFEI12" , "Carga"                                         		, "C", "@!"            ,           , "IntProt" , "GpOms"      	, {"","1=Integrar","2=Não integrar"}                                                           , .T.})
	aAdd(aCampos,{"MV_CADOMS" , "Origem dos Cadastros OMS"                      		, "C", "@!"            ,           , "IntProt" , "GpOms"      	, {"","1=OMS","2=SIGAGFE"}                                                                     , .T.})
	aAdd(aCampos,{"MV_GFEI10" , "Nota Fiscal de Entrada"                        		, "C", "@!"            ,           , "IntProt" , "GpMate"     	, {"","1=Integrar","2=Não integrar"}                                                           , .T.})
	aAdd(aCampos,{"MV_CPDGFE" , "Cond. Pagto. Padrao"                           		, "C", "@!"            , "SE4"     , "IntProt" , "GpMate"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_PRITDF" , "Código Produto Registro de Entrada"            		, "C", "@!"            , "SB1"     , "IntProt" , "GpMate"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_ESCPED" , "Pedágio com TES Própria"  								, "C","@!"			   , "SB1"     , "IntProt" , "GpMate"		, {"","1=Sim","2=Não"}																			, .T.	})	
	If GFXPR1212310("MV_GFEVOLU")
		aAdd(aCampos,{"MV_GFEVOLU", "Volume por unitizador"                            		, "C", "@!"            ,           , "IntProt" , "GpMate"   	, {"","1=Sim","2=Não"}                                                                                           , .T.})
	EndIf
	aAdd(aCampos,{"MV_NTFGFE" , "Natureza Título a Pagar"                       		, "C", "@!"            , "SED"     , "IntProt" , "GpFinan"    	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_TMSGFE" , "Redespachos"                                   		, "L", "@!"            ,           , "IntProt" , "GpTMS"  	 	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_TMS2GFE", "Ocorrências"                                   		, "C", "@!"            ,           , "IntProt" , "GpTMS"   	 	, {"","1=Sim","2=Não"}                                                                                           , .T.})
	aAdd(aCampos,{"MV_GFEI22" , "Integração Automática"  								, "C", "@!"			   ,           , "IntProt" , "GpTMS"		, {"","1=Sim","2=Não"}																			, .T.	})
	aAdd(aCampos,{"MV_TMS3GFE", "Viagens"  	                                 			, "C", "@!"            ,           , "IntProt" , "GpTMS"   	 	, {"","N=Não integra","F=Fechamento da viagem","S=Saída da viagem","C=Chegada da viagem"}		, .T.})
	
	aAdd(aCampos,{"MV_WSGFE"  , "URL do WebService"                             		, "C", "@!"            ,           , "IntDS"   , "GrpCfg"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_WSINST" , "Nome da instância"                             		, "C", "@!"            ,           , "IntDS"   , "GrpCfg"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_TPOPEMB", "Tipo de Operação Padrão"                       		, "C", "@!"            , "GV4"     , "IntDS"   , "GrpGrl"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSDTRE" , "Data Integração Recebimento"                   		, "C", "@!"            ,           , "IntDS"   , "GrpGrl"     	, {"","1=Data Corrente","2=Data Criação","3=Informada Usuário","4=Financeiro"}   			   	, .T.})
	aAdd(aCampos,{"MV_GFE002" , "Integração por Item de Transporte"             		, "C", "@!"            ,           , "IntDS"   , "GrpGrl"     	, {"","1=Sim","2=Não"}   			   															, .F.})
	aAdd(aCampos,{"MV_DSINTTV", "Integração Tipo de Veículo?"             				, "C", "@!"            ,           , "IntDS"   , "GrpGrl"     	, {"","1=Sim","2=Não"}   			   															, .T.})
	aAdd(aCampos,{"MV_DSOFDT" , "Data Transação Documento Fiscal"               		, "C", "@!"            ,           , "IntDS"   , "GrpFsc"     	, {"","1=Entrada","2=Financeira","3=Informada","4=Corrente"}                                                , .T.})
	aAdd(aCampos,{"MV_DSOFIT" , "Código Item Documento Fiscal"                  		, "C", "@!"            ,           , "IntDS"   , "GrpFsc"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSDTAP" , "Data Integração Financeiro"                    		, "C", "@!"            ,           , "IntDS"   , "GrpFin"     	, {"","1=Data Corrente","2=Data Criação","3=Informada Usuário"}                                , .T.})
	aAdd(aCampos,{"MV_DSESPF" , "Espécie Fatura"                                		, "C", "@!"            ,           , "IntDS"   , "GrpFin"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSEPRO" , "Espécie Provisão"                              		, "C", "@!"            ,           , "IntDS"   , "GrpFin"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSESCT" , "Espécie Fatura Avulsa"                         		, "C", "@!"            ,           , "IntDS"   , "GrpFin"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSICCD" , "Cód. Imposto ICMS Retido"                      		, "C", "@!"            ,           , "IntDS"   , "GrpFin"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSICCL" , "Classificação ICMS Retido"                     		, "C", "@!"            ,           , "IntDS"   , "GrpFin"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSISCD" , "Cód. Imposto ISS Retido"                       		, "C", "@!"            ,           , "IntDS"   , "GrpFin"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSISCL" , "Classificação ISS Retido"                      		, "C", "@!"            ,           , "IntDS"   , "GrpFin"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_MATREX" , "Matriz de Tradução Externa"                    		, "C", "@!"            ,           , "IntDS"   , "GrpFin"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_NRPF"   , "Numeração Título Provisão"								, "C", "@!"			   ,           , "IntDS"   , "GrpFin"      , {"","1=Número Pré-fatura", "2=Filial+Número Pré-fatura"}                                     , .T.})
	aAdd(aCampos,{"MV_DSESCO" , "Espécie Contrato"                              		, "C", "@!"            ,           , "IntDS"   , "GrpFna"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSIRCD" , "Cód. Imposto IRRF"                             		, "C", "@!"            ,           , "IntDS"   , "GrpFna"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSIRCL" , "Classif. IRRF"                                 		, "C", "@!"            ,           , "IntDS"   , "GrpFna"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSIACD" , "Cód. Imposto INSS Autônomo"                    		, "C", "@!"            ,           , "IntDS"   , "GrpFna"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSIACL" , "Classif. INSS Autônomo"                        		, "C", "@!"            ,           , "IntDS"   , "GrpFna"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSINCD" , "Cód. Imposto INSS Embarcador"                  		, "C", "@!"            ,           , "IntDS"   , "GrpFna"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSINCL" , "Classif. Imposto INSS Embarc."              			, "C", "@!"            ,           , "IntDS"   , "GrpFna"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_ADINEM" , "Adc. INSS Embarc. RE"                  				, "C", "@!"            ,           , "IntDS"   , "GrpFna"     	, {"","1=Sim","2=Não"}                                                                         , .T.})
	aAdd(aCampos,{"MV_DSSSCD" , "Cód. Imposto SEST/SENAT"                       		, "C", "@!"            ,           , "IntDS"   , "GrpFna"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_DSSSCL" , "Classif. Imposto SEST/SENAT"                   		, "C", "@!"            ,           , "IntDS"   , "GrpFna"     	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_GFEI19" , "Contrato RH"                                   		, "C", "@!"            ,           , "IntDS"   , "OpInt2"     	, {"","1=sob Demanda","2=Automática","3=Não integrar"}                                      , .T.})
	aAdd(aCampos,{"MV_GFEI20" , "Data Integração Faturamento"                   		, "C", ""              ,           , "IntDS"   , "OpInt2"   , {"","1=Automática","2=Não integrar"}                                     					, .T.})
	aAdd(aCampos,{"MV_DSESIM" , "Permite Eliminação Cálculo Simulado"           		, "L", ""              ,           , "IntDS"   , "OpInt2"     	, 														                                    , .T.})
	aAdd(aCampos,{"MV_GFEBI01", "Freight Expenses Fact"                         		, "C", ""              ,           , "IntDS"   , "GrpBI"      	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_GFEBI02", "Freight Occurrence Fact"                       		, "C", ""              ,           , "IntDS"   , "GrpBI"      	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_GFEBI03", "Freight LeadTime Fact"                         		, "C", ""              ,           , "IntDS"   , "GrpBI"      	,                                                                                           , .T.})
	aAdd(aCampos,{"MV_EMPBI" , "Empresa BI"                                 			, "C", "@!"            ,           , "IntDS"   , "GrpBI"  	    ,                                                                                           , .T.})
	aAdd(aCampos,{"MV_FILBI" , "Filial BI"                                 				, "C", "@!"            ,           , "IntDS"   , "GrpBI"  	    ,                                                                                          , .T.})
	aAdd(aCampos,{"MV_MTNRERP", "Mantém Numeração Embarque ERP?"						, "C", "@!"			   ,		   , "IntDS"   , "OpInt2"		, {"","1=Sim","2=Não"}																					 , .T.})
	aAdd(aCampos,{"MV_DSCTB" , "Contabilização Frete de Vendas"                      	, "C", ""              , ""        , "IntDS"   , "GrpCtb"		, {"","1=Fatura de Frete (Financeiro)","2=Documento de Frete (Recebimento)"}						 , .T.})
	
	aAdd(aCampos,{"MV_EMIPRO" , "Emitente Estimativa"                       	   		, "C", ""              	, "GV9"     , "Contab"  , ""				, , .T.})
	aAdd(aCampos,{"MV_TABPRO" , "Tabela Estimativa"                      	   			, "C", ""              	,           , "Contab"  , ""				, , .T.})
	aAdd(aCampos,{"MV_NEGPRO" , "Negociação Estimativa"									, "C", ""				,           , "Contab"  , ""				, 																							, .T.})
	aAdd(aCampos,{"MV_LOGCONT", "Gera log de contabilização?"  		                 	, "C",					,           , "Contab"  , ""  			, {"","1=Sim","2=Não"}                                                                        	, .T.})
	
	aAdd(aCampos,{"MV_TCNEW"  , "Tipos de documento transmitidos"						, "C", "@!"				,			, "TotvsCol", "ComunTC20"		,																							, })
	aAdd(aCampos,{"MV_VERCTE" , "Versão do CTe"											, "C", "@!"				,			, "TotvsCol", "ComunTC20"		,																			, })
	aAdd(aCampos,{"MV_NGOUT"  , "Diretório de saída"									, "C", ""				, 			, "TotvsCol", "ComunTC20"		,																							, })
	aAdd(aCampos,{"MV_NGINN"  , "Diretório de entrada"									, "C", ""				,			, "TotvsCol", "ComunTC20"		,																							, })
	aAdd(aCampos,{"MV_NGLIDOS", "Diretório de arquivos lidos"							, "C", ""				,			, "TotvsCol", "ComunTC20"		,																							, })
	aAdd(aCampos,{"MV_GFETOTC", "Tempo de espera para processar retorno da consulta"	, "N", "@E 999"			,			, "TotvsCol", "ComunTC20"     	,                                                                              	, .T.})  
	
	aAdd(aCampos,{"MV_RENTNP" , "Registrar Entrega de Documentos de Carga"         		, "C", "@!"  			,          	, "ExpRec"  , "DocCar"	, {"","1=Somente Trechos Pagos", "2=Todos os Trechos"}, })
	aAdd(aCampos,{"MV_TREDESP", "Redespachantes"         								, "C", "@!"  			,			, "ExpRec" 	, "DocCar"		, {"","1=Não Identifica", "2=Opcional","3=Obrigatório"}									, })
	aAdd(aCampos,{"MV_SITEDC" , "Situação Doc. Carga com Ocorrência Entrega"            , "C", "@!"  			,			, "ExpRec" 	, "DocCar"		, {"","1=Trechos pagos entregues/último trecho", "2=Todos trechos entregues"}									, })
	
	If GFEA065INP()
		aAdd(aCampos,{"MV_TESGFE" , "TES Doc. Frete"									, "C", "@!" 			, 			, "IntProt"	, "GpMate"		, {"","1=Atribuído.Sistema", "2=Informado.Usuário", "3=Atribuido CFOP/TES Itens NF"}										, })
		aAdd(aCampos,{"MV_SIGFE"  , "Solicita Info Integração"  						, "C", "@!" 			, 			, "IntProt"	, "GpMate"		, {"","1=Sim", "2=Não"}																		, })
	EndIf

	If GFXPR1212410("MV_INTFIS")
		aAdd(aCampos,{"MV_INTFIS" , "Integração Fiscal" 		 						, "C", "@!" 			, 			, "IntProt"	, "GpMate"		, {"","1=Normal", "2=Pre-Nota", "3=Pre-CTE", "4=Ambos"}																		, })
	EndIf

	aAdd(aCampos,{"MV_GFEISS" , "Utilizar Imposto ISS"									, "C", "@!"  			,         	, "IntProt" 	, "GpFinan"	, {"","1=Sim","2=Não"}										, .T.	})
	aAdd(aCampos,{"MV_GFEIRRF", "Utilizar Imposto IRRF"									, "C", "@!"  			,         	, "IntProt" 	, "GpFinan"	, {"","1=Sim","2=Não"}										, .T.	})
	aAdd(aCampos,{"MV_GFEINSS", "Utilizar Imposto INSS/SEST"							, "C", "@!"  			,         	, "IntProt" 	, "GpFinan"	, {"","1=Sim","2=Não"}										, .T.	})
	
	aAdd(aCampos,{"MV_DFMLA"  , "Aprovação de Documentos de Frete via MLA"				, "C", "@!"  			,           , "IntDS"  , "OpInt2", {"","1=Não integra", "2=Integra com valor doc.", "3=Integra valor diferença prev./realizado"}, })
	aAdd(aCampos,{"MV_FTMLA"  , "Aprovação de Faturas via MLA"							, "C", "@!"  			,           , "IntDS"  , "OpInt2", {"","1=Não integra", "2=Integra com valor doc.", "3=Integra valor diferença prev./realizado", "4=Integra após aprovação no GFE (Liberação de pagamento)"}, })
	aAdd(aCampos,{"MV_TFMLA"  , "Integração MLA"										, "C", "@!" 			,			, "IntDS"  , "OpInt2", {"","1=Sim","2=Não"}								 , .T.})
	aAdd(aCampos,{"MV_DTROMV" , "Data de liberação do romaneio na partida da viagem"    , "C", "@!"  			,           , "ExpRec" , "Romane", {"","1=Dt. Criação","2=Dt. Partida"}, })
	
	If GFXCP12117("GU2_RECNFE") 
		aAdd(aCampos,{"MV_NFEENV" , "Envio XML NFe"										, "C", "@!"				, 			, "ExpRec", "Romane"		, {"","1=Não Enviar","2=Automática","3=Sob Demanda"} , })
		aAdd(aCampos,{"MV_NFEDIR" , "Diretório XML NFe"									, "C", "@!"				, 			, "ExpRec", "Romane"		,		, })
	EndIf
	
	aAdd(aCampos,{"MV_PLROADE" , "Permite liberar romaneio com data anterior a data de emissão doc carga" , "C", "@!", 			, "ExpRec", "Romane"		, {"","1=Sim","2=Não"} , })

	If GFXTB12117("GXN")
		aAdd(aCampos,{"MV_TPEST"  , "Tipo Estorno Provisão"		 						, "C", "@!"				, 			, "Contab"	, ""		,{"","1=Total","2=Parcial"},.T.})
		aAdd(aCampos,{"MV_PEPRONO", "Período Saldo Prov. Normal (Meses)"				, "N", "@E 99"        	,			, "Contab"	, ""		,,.T.})
		aAdd(aCampos,{"MV_PEPROES", "Período Saldo Prov. Estimativa (Meses)"	 		, "N", "@E 99"        	,			, "Contab"	, ""		,,.T.})
		aAdd(aCampos,{"MV_PEPROAD", "Período Saldo Prov. Adicional (Meses)"	 			, "N", "@E 99"        	,			, "Contab"	, ""		,,.T.})
	EndIf
	
	If GFXTB12117("GWC")
		AAdd(aCampos,{"MV_GFEI21" , "Custos de Transporte"                             	, "C", "@!"            ,           , "IntProt" , "GpTMS"       , {"","1=Sob demanda","2=Automática","3=Não integrar"}                                         , .T.})
		AAdd(aCampos,{"MV_DESGFE1", "Despesa de Frete para Doc. Frete Normal"			, "C", "@!"            , "DT7"     , "IntProt" , "GpTMS"        ,                                                                                          , .T.})
		AAdd(aCampos,{"MV_DESGFE2", "Despesa de Frete para Doc. Frete Compl. Valor"		, "C","@!"             , "DT7"     , "IntProt" , "GpTMS"        ,                                                                                          , .T.})
		AAdd(aCampos,{"MV_DESGFE3", "Despesa de Frete para Doc. Frete Compl. Imposto"	, "C","@!"             , "DT7"     , "IntProt" , "GpTMS"        ,                                                                                          , .T.})
		AAdd(aCampos,{"MV_DESGFE4", "Despesa de Frete para Doc. Frete Reentrega"		, "C", "@!"            , "DT7"     , "IntProt" , "GpTMS"        ,                                                                                      , .T.})
		AAdd(aCampos,{"MV_DESGFE5", "Despesa de Frete para Doc. Frete Devolução"		, "C", "@!"            , "DT7"     , "IntProt" , "GpTMS"        ,                                                                                      , .T.})
		AAdd(aCampos,{"MV_DESGFE6", "Despesa de Frete para Doc. Frete de Redespacho"	, "C", "@!"            , "DT7"     , "IntProt" , "GpTMS"        ,                                                                                          , .T.})
		AAdd(aCampos,{"MV_DESGFE7", "Despesa de Frete para Doc. Frete de Serviço"		, "C", "@!"            , "DT7"     , "IntProt" , "GpTMS"        ,                                                                                          , .T.})
	EndIf
	
	aAdd(aCampos,{"MV_GFELPR" , "Habilita a geração de log antes da integração com o ERP Protheus?", "C", "@!" ,     	   , "IntProt" , "GpGerais"    	, {"","1=Sim","2=Não"}                                         	, .T.})
	AAdd(aCampos,{"MV_INTTAB" , "Integração Tabela de Frete para Consulta Datasul"		, "C", "@!" 		   ,		   , "IntDS"   , "OpInt2"		, {"","1=Não Integrar","2=Integrar"}							, .T.})
	AAdd(aCampos,{"MV_INTFRE" , "Integra as informações de Frete na Nota Fiscal ERP Datasul" , "C", "@!" 	   ,		   , "IntDS"   , "OpInt2"		, {"","1=Não Integrar","2=Integrar"}							, .T.})
	aAdd(aCampos,{"MV_GFEQBR" , "% Máx Quebra Peso"                        				, "N", "@E 99.99"      ,  		   , "ExpRec"  , "TraEnt"       , 															   	, .T.})
	aAdd(aCampos,{"MV_GFEIND" , "Descontar Indenizações"                        		, "C", "@!"            ,  		   , "ExpRec"  , "TraEnt"       , {"","0=Não","1=Sim"} 										   	, .T.})
	aAdd(aCampos,{"MV_GFE001" , "Ação sobre Documentos de Carga origem ERP"				, "C", "@!"            ,           , "IntERP"  , "AçUsu"     	, {"","1=Nenhuma","2=Somente Cancelar","3=Cancelar e Eliminar"}	, .T.})
	
	If IntGFEFrtBr(.F.)
		aAdd(aCampos,{"MV_GFEFBPR",STR0012,"C","@!",,"IntFtBr","",,.T.})
		aAdd(aCampos,{"MV_GFEFBTE",STR0013,"C","@!",,"IntFtBr","",_aTipEsp, .T.})
		aAdd(aCampos,{"MV_GFEFBRA",STR0014,"C","@!",,"IntFtBr","",,.T.})
		aAdd(aCampos,{"MV_GFEFBLT",STR0015,"C","@!",,"IntFtBr","",{"","1=Sim","2=Não"},.T.})
		aAdd(aCampos,{"MV_GFEFBTP",STR0016,"C","@!",,"IntFtBr","",_aTipPre,.T.})
	EndIf
	
	nContF := Len(aCampos)
	For nCont := 1 To nContF
		AAdd(aCampos[nCont], GFEX000GTT(aCampos[nCont][1]))
	Next nCont
	
	aFolder := {{"ExpRec"  ,"Expedição/Recebim"},;
				{"PatPort" ,"Pátio/Portaria"},;
				{"TabFrete","Tabela de Frete"},;
				{"CalcFret","Cálculo de Frete"},;
				{"PreFat"  ,"Pré-faturas"},;
				{"DocFret" ,"Doc Frete/Fatura"},;
				{"AudiFret","Auditoria de Frete"},;
				{"ContAuto","Contrato Autônomo"},;
				{"Contab"  ,"Contabilização"},;
				{"TotvsCol","Totvs Colaboração"},;
				{"IntEDI"  ,"Integração EDI"},;
				{"IntERP"  ,"Integração ERP"},;
				{"IntProt" ,"Integração Protheus"},;
				{"IntDS"   ,"Integração Datasul"}}

	If IntGFEFrtBr(.F.)
		aAdd(aFolder,{"IntFtBr" ,STR0017}) // Integração Fretebras
	EndIf
	
	nContF := Len(aFolder)
	For nCont := 1 To nContF
		oStruct:AddFolder(aFolder[nCont][1],aFolder[nCont][2])
	Next nCont

	oStruct:AddGroup("ValPed"   , "Vale Pedágio", "ExpRec", 2)
	oStruct:AddGroup("TraEnt"   , "Trânsito/Entregas", "ExpRec", 2)
	oStruct:AddGroup("DocCar"   , "Documento de Carga", "ExpRec", 2)
	oStruct:AddGroup("Romane"   , "Romaneio", "ExpRec", 2)
	
	oStruct:AddGroup("GrpDF" 	, "Documento de Frete", "AudiFret", 2) // "Documento de Frete"
	oStruct:AddGroup("GrpFat"	, "Fatura X Pré-Fatura", "AudiFret", 2) // "Fatura X Pré-Fatura"

	oStruct:AddGroup("GrpCfg"	, "Configuração", "IntDS", 2) // "Configuração"
	oStruct:AddGroup("GrpGrl"	, "Geral", "IntDS", 2) // "Geral"
	oStruct:AddGroup("GrpFsc"	, "Fiscal", "IntDS", 2) // "Fiscal"
	oStruct:AddGroup("GrpCtb"	, "Contábil", "IntDS", 2) // "Contábil"
	oStruct:AddGroup("GrpFin"	, "Financeiro", "IntDS", 2) // "Financeiro"
	oStruct:AddGroup("GrpFna"	, "Financeiro Autônomo", "IntDS", 2) // "Financeiro Autônomo"
	oStruct:AddGroup("OpInt1"	, "Opções de Integração", "IntDS", 2) // "Opções de Integração"
	oStruct:AddGroup("GrpBI" 	, "BI", "IntDS", 2) // "BI"

	oStruct:AddGroup("PdSug" 	, "Padrões Sugeridos"	 , "IntERP", 2) //"Padrões Sugeridos"
	oStruct:AddGroup("AçUsu" 	, "Ações de Usuários"	 , "IntERP", 2) //"Ações de Usuários"	
	oStruct:AddGroup("OpInt2" 	, "Opções de Integração", "IntERP", 2) // "Opções de Integração"

	oStruct:AddGroup("Comun" 	, "Comunicação"		 , "IntERP", 2) // "Comunicação"
	oStruct:AddGroup("ComunTC"  , "Geral" , "TotvsCol", 2) 
	oStruct:AddGroup("ComunTC10", "Versão 1.0" , "TotvsCol", 2) 
	oStruct:AddGroup("ComunTC20", "Versão 2.0" , "TotvsCol", 2) 

	oStruct:AddGroup("GpGerais"	, "Gerais"  , "IntProt", 2)
	oStruct:AddGroup("GpFatura"	, "SIGAFAT" , "IntProt", 2)
	oStruct:AddGroup("GpOms"   	, "SIGAOMS" , "IntProt", 2)
	oStruct:AddGroup("GpMate"  	, "SIGACOM" , "IntProt", 2)
	oStruct:AddGroup("GpFinan" 	, "SIGAFIN" , "IntProt", 2)
	oStruct:AddGroup("GpTMS"   	, "SIGATMS" , "IntProt", 2)
	
	oStruct:AddGroup("GrpGrlFrt", "Geral"				, "CalcFret", 2) // "Geral"
	oStruct:AddGroup("GrpBscNeg", "Busca Negociação"	, "CalcFret", 2) // "Busca Negociação"
	oStruct:AddGroup("GrpGrlImp", "Impostos"			, "CalcFret", 2) // "Impostos"
	oStruct:AddGroup("GrpGrlLog", "Log"					, "CalcFret", 2) // "Log"
	oStruct:AddGroup("GrpGrlAdf", "Adicional de Frete"	, "CalcFret", 2) // "Adicional de Frete"
	oStruct:AddGroup("GrpRomFrt", "Romaneio"			, "CalcFret", 2) // "Romaneio"
	oStruct:AddGroup("GrpClcFrt", "Cálculo de Frete"	, "CalcFret", 2) // "Cálculo de Frete"
	oStruct:AddGroup("GrpFMR"	, "Frete Mínimo por Romaneio", "CalcFret", 2) // "Frete Mínimo Por Romaneio"
	oStruct:AddGroup("GrpPerfFr", "Performance Cálculo de Frete", "CalcFret", 2) // "Performance Cálculo de Frete"
	
	oStruct:AddGroup("GrpCtrFrt", "Contrato de Frete", "CalcFret", 2) // "Performance Cálculo de Frete"
	
	oStruct:AddGroup("GpGeral"  , "Geral" 			, "PatPort", 2)
	oStruct:AddGroup("GpPort"   , "Portaria" 		, "PatPort", 2)
	oStruct:AddGroup("GpVlPeso" , "Validação Peso"	, "PatPort", 2)

	oStruct:AddGroup("GpIrrf"   , "IRRF"	, "ContAuto", 2)
	oStruct:AddGroup("GpInss"   , "INSS"	, "ContAuto", 2)
	oStruct:AddGroup("GpOutros" , "Outros"	, "ContAuto", 2)

	nContF := Len(aCampos)
	For nCont := 1 To nContF
		oStruct:AddField(aCampos[nCont][1], NTOC(nCont,32,2), aCampos[nCont][2] ,aCampos[nCont][10] , , aCampos[nCont][3], aCampos[nCont][4],/*bPICTVAR*/,aCampos[nCont][5], aCampos[nCont][9] /*lCANCHANGE*/,aCampos[nCont][6]/*cFOLDER*/,aCampos[nCont][7]/*cGRUP*/,aCampos[nCont][8]/*@aCOMBOVALUES*/,/*nMAXLENCOMBO*/," ",/*lVIRTUAL*/,/*cPICTVAR*/,/*lINSERTLIN*/)
		For nContFolde := 1 to Len(aFolder)
			If aFolder[nContFolde][1] ==  aCampos[nCont][6]
				AAdd(aCamposCam, {aCampos[nCont][1] , aCampos[nCont][6], aFolder[nContFolde][2] })
			EndIf
		Next nCont
	Next nCont

	//Remove campo da view
	If GW3->(FieldPos("GW3_ACINT")) = 0
    	oStruct:RemoveField("MV_DSCTB")
	EndIf
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "GFEX000_01" , oStruct, /*cLinkID*/ )
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddUserButton("Email", "MAGIC_BMP", {|oView| GFEX000EML(oView)}, ) // "Email"
	oView:AddUserButton("Filial x Emitente", "MAGIC_BMP", {|| GFEX000A()}, )

	If (cCadERP = "1") .AND. ( cERPGFE = "2")
		oView:AddUserButton("CFOP x CT-e", "MAGIC_BMP", {|| GFEX020() }, )
	EndIf

	oView:SetOwnerView("GFEX000_01","MASTER")

Return oView

//------------------------------------------------------------------------------------------------

Static Function GFEX000COM(oModel)

	Local nCont 	:= 0
	Local cDIRXML
	Local oModelPF	:= oModel:GetModel('GFEX000_01')
	Local aCamposPF	:= oModelPF:GetStruct():GetFields()
	Local cDIRLIDO	:= "OLD\"
	
	For nCont := 1 To Len(aCamposPF)
		if aCamposPF[nCont][3] == "MV_TMS2GFE"
			PUTMV(aCamposPF[nCont][3] , IIf(oModel:GetValue("GFEX000_01", aCamposPF[nCont][3]) == "1", .T.,.F.)  )
		else
			PUTMV(aCamposPF[nCont][3] , oModel:GetValue("GFEX000_01",aCamposPF[nCont][3]))
		endif
	Next nCont

	//Criação dos diretorios para Importações de CT-e
	//-- Prepara estrutura de diretorios
	cDIRXML:= SuperGetMv("MV_XMLDIR",.F.,"")
	//Trata a string do campo caminho para importação - veificando se existe a barra no final
	If !Empty(cDIRXML)
		IF ISSRVUNIX()	
			//if que verifica se a barra esta correta
			If AT("\",cDIRXML) > 0  //Linux Unix
			    While AT("\",cDIRXML) > 0 
			    	cDIRXML := Stuff(cDIRXML,AT("\",cDIRXML),1,"/")
				Enddo 
			Endif
			//if que insere a barra no final
			If right(cDIRXML,1) != "/"
				cDIRXML := cDIRXML + "/"
				PutMv("MV_XMLDIR",cDIRXML)
			EndIf
			//if que cria os diretórios
			If !ExistDir(cDIRXML) 
				MakeDir(cDIRXML)
				MakeDir(cDIRXML +"/"+cDIRLIDO)
			ElseIf !ExistDir(cDIRXML + "/" + cDIRLIDO)
				MakeDir(cDIRXML +"/"+cDIRLIDO)
			EndIf	
		Else
			//if que verifica se a barra esta correta
			If AT("/",cDIRXML) > 0  //Windows
				While AT("/",cDIRXML) > 0
			    	cDIRXML := Stuff(cDIRXML,AT("/",cDIRXML),1,"\")
				Enddo                                                         
			Endif
			//if que insere a barra no final
			If right(cDIRXML,1) != "\"
				cDIRXML := cDIRXML + "\"
				PutMv("MV_XMLDIR",cDIRXML)
			EndIf
			//if que cria os diretórios
			If !ExistDir(cDIRXML) 
				MakeDir(cDIRXML)
				MakeDir(cDIRXML +"\"+cDIRLIDO)
			ElseIf !ExistDir(cDIRXML + "\" + cDIRLIDO)
				MakeDir(cDIRXML +"\"+cDIRLIDO)
			EndIf
				 
		EndIf
	EndIf
Return .T.

//----------------------------------------------------------------------------------------------

Function GFEX000EML(oView)
	Local oDlg
	Local oGet
	Private cServer   := IIf( Empty(SuperGetMv("MV_RELSERV",.F.,"")  ), Space(200), PadR(SuperGetMv("MV_RELSERV",.F.,""), 200))
	Private cEmail    := IIf( Empty(SuperGetMv("MV_RELACNT",.F.,"")  ), Space(200), PadR(SuperGetMv("MV_RELACNT",.F.,""), 200) )
	Private cPass     := IIf( Empty(SuperGetMv("MV_RELPSW",.F.,"")   ), Space(20) , PadR(SuperGetMv("MV_RELPSW",.F.,"") , 20))
	Private cContAuth := IIf( Empty(SuperGetMv("MV_RELAUTH",.F.,"")  ), Space(200), PadR(SuperGetMv("MV_RELAUTH",.F.,""), 200))
	Private cPswAuth  := IIf( Empty(SuperGetMv("MV_RELAPSW",.F.,"")  ), Space(20),   PadR(SuperGetMv("MV_RELAPSW",.F.,""), 20) )

	DEFINE MsDialog oDlg Title "Parâmetros de Email" From 0, 0 TO 175, 600 Of oDlg Pixel

	@   3,  3 Say "Servidor"       Size 40, 7 Pixel Of oDlg
	@  15,  3 Say "Conta Email"    Size 40, 7 Pixel Of oDlg
	@  27,  3 Say "Senha"          Size 40, 7 Pixel Of oDlg
	@  39,  3 Say "Conta Autentic" Size 40, 7 Pixel Of oDlg
	@  51,  3 Say "Senha Autentic" Size 40, 7 Pixel Of oDlg

	oGet := TGet():New(2, 45, {|u| If(Pcount( )>0, cServer := u, cServer ) }, oDlg, 248,8,'@',,,,,,,.T.,,,{|| .T.},,,,,,,"cServer",,,,)
	oGet:cToolTip := "Parâmetro MV_RELSERV : " + GFEX000GTT("MV_RELSERV")

	oGet := TGet():New(14, 45, {|u| If(Pcount( )>0, cEmail := u, cEmail ) }, oDlg, 248,8,'@',,,,,,,.T.,,,{|| .T.},,,,,,,"cEmail",,,,)
	oGet:cToolTip := "Parâmetro MV_RELACNT : " + GFEX000GTT("MV_RELACNT")

	oGet := TGet():New(26, 45, {|u| If(Pcount( )>0, cPass := u, cPass ) }, oDlg, 248,8,'@',,,,,,,.T.,,,{|| .T.},,,,,.T.,,"cPass",,,,)
	oGet:cToolTip := "Parâmetro MV_RELPSW : " + GFEX000GTT("MV_RELPSW")

	oGet := TGet():New(38, 45, {|u| If(Pcount( )>0, cContAuth := u, cContAuth ) }, oDlg, 248,8,'@',,,,,,,.T.,,,{|| .T.},,,,,,,"cContAuth",,,,)
	oGet:cToolTip := "Parâmetro MV_RELAUTH : " + GFEX000GTT("MV_RELAUTH")

	oGet := TGet():New(50, 45, {|u| If(Pcount( )>0, cPswAuth := u, cPswAuth ) }, oDlg, 248,8,'@',,,,,,,.T.,,,{|| .T.},,,,,.T.,,"cPswAuth",,,,)
	oGet:cToolTip := "Parâmetro MV_RELAPSW : " + GFEX000GTT("MV_RELAPSW")

	@ 70, 205 Button "&Salvar" Size 36, 13 Message 'Salvar Parâmetros' Pixel Action Eval({|oDlg| GFEX000SV(), oDlg:End()}, oDlg)
	@ 70, 250 Button "&Fechar" Size 36, 13 Message 'Fechar'            Pixel Action oDlg:End()

	Activate MsDialog oDlg Centered

Return

//-----------------------------------------------------

Static Function GFEX000SV()

	PUTMV('MV_RELSERV', cServer)
	PUTMV('MV_RELACNT', cEmail)
	PUTMV('MV_RELPSW' , cPass)
	PUTMV('MV_RELAUTH', cContAuth)
	PUTMV('MV_RELAPSW', cPswAuth)

Return

//-----------------------------------------------------

Static Function GFEX000GTT(cPar)

Return AllTrim( Posicione("SX6",1,xFilial("SX6")+cPar,"X6_DESCRIC") + ;
			    Posicione("SX6",1,xFilial("SX6")+cPar,"X6_DESC1")   + ;
			    Posicione("SX6",1,xFilial("SX6")+cPar,"X6_DESC2"))   + ;
			    " | " + Alltrim(Posicione("SX6",1,xFilial("SX6")+cPar,"X6_VAR") )

//-----------------------------------------------------

Function GFEX000VLD(oModel)
	Local oStruct	:= oModel:GetModel("GFEX000_01"):GetStruct()
	Local cQuery	:= ""
	Local cAliasGW2 := ""	
	Local oModelPF	:= oModel:GetModel('GFEX000_01')
	Local aCamposPF	:= oModelPF:GetStruct():GetFields()	
	Local nCont1	:= 0
	Local nCont2	:= 0
	
	For nCont1 := 1 To Len(aCamposPF)
		If aCamposPF[nCont1][4] == "C" .and. !empty(aCamposPF[nCont1][9]) .and. (aCamposPF[nCont1][3] != "MV_TMS2GFE") .and. (aCamposPF[nCont1][3]!= "MV_AMBCTEC") .and. (aCamposPF[nCont1][3] != "MV_AMBICOL")  .and. (aCamposPF[nCont1][3] != "MV_GFEI22")  .and. (aCamposPF[nCont1][3] != "MV_GFE002")  .and. (aCamposPF[nCont1][3] != "MV_MOTCAN")  
			If alltrim(FWFldGet(aCamposPF[nCont1][3])) == "" 
				If oModel:GetValue("GFEX000_01","MV_ERPGFE") == "1"
					For nCont2 := 1 To Len(aCamposCam)						
						If aCamposCam[ncont2][1] == aCamposPF[nCont1][3] .and. aCamposCam[ncont2][2] != "IntProt"
							Help(,,"HELP",,"Parâmetro ("+ aCamposPF[nCont1][3] + " - "+ aCamposPF[nCont1][1] + ", da aba - " + aCamposCam[ncont2][3] +  ") esta em branco, valor não permitido.",1,0, , , , , , {"A partir desta atualização da rotina de parâmetros do módulo, será obrigatório o preenchimento de todos os campos tipo lista, por favor verificar em todas as abas os campos tipo lista em branco e preenche-los."})
							nCont2 := 0
							Return .F.	
						Endif 										
					Next nCont2					
				ElseIf oModel:GetValue("GFEX000_01","MV_ERPGFE") == "2"
					For nCont2 := 1 To Len(aCamposCam)						
						If aCamposCam[ncont2][1] == aCamposPF[nCont1][3] .and. aCamposCam[ncont2][2] != "IntDS"
							Help(,,"HELP",,"Parâmetro ("+ aCamposPF[nCont1][3] + " - "+ aCamposPF[nCont1][1] + ", da aba - " + aCamposCam[ncont2][3] +  ") esta em branco, valor não permitido.",1,0, , , , , , {"A partir desta atualização da rotina de parâmetros do módulo, será obrigatório o preenchimento de todos os campos tipo lista, por favor verificar em todas as abas os campos tipo lista em branco e preenche-los."})
							nCont2 := 0
							Return .F.	
						Endif 										
					Next nCont2					
				Else
					For nCont2 := 1 To Len(aCamposCam)						
						If aCamposCam[ncont2][1] == aCamposPF[nCont1][3] 
							Help(,,"HELP",,"Parâmetro ("+ aCamposPF[nCont1][3] + " - "+ aCamposPF[nCont1][1] + ", da aba - " + aCamposCam[ncont2][3] +  ") esta em branco, valor não permitido.",1,0, , , , , , {"A partir desta atualização da rotina de parâmetros do módulo, será obrigatório o preenchimento de todos os campos tipo lista, por favor verificar em todas as abas os campos tipo lista em branco e preenche-los."})
							nCont2 := 0
							Return .F.	
						Endif 										
					Next nCont2	
				EndIf
			EndIf
		EndIf
	Next nCont1

	If !ValidDSCTB( oModel:GetValue("GFEX000_01", "MV_DSCTB"), oModel:GetValue("GFEX000_01","MV_GFEI15"), oModel:GetValue("GFEX000_01","MV_DSOFDT"))
		Return .F.
	EndIf
	
	If oStruct:HasField("MV_TPEST")
		If !ValidTPEST( oModel:GetValue("GFEX000_01", "MV_TPEST"),oModel:GetValue("GFEX000_01", "MV_ERPGFE"),.T. )
			Return .F.
		EndIf
	EndIf
	If oModel:GetValue("GFEX000_01", "MV_CADERP") == "1" .And. Empty(oModel:GetValue("GFEX000_01", "MV_ERPGFE"))
		Help( ,, 'HELP',, "É necessário informar o campo ERP Integrado quando o campo Origem dos Cadastros é igual a ERP.", 1, 0)
		Return .F.
	EndIf

	If GFXPR12127("MV_ESPDF4")
		If !Empty(oModel:GetValue("GFEX000_01", "MV_ESPDF4"))
			dbSelectArea("GVT")
			GVT->( dbSetOrder(1) ) // GVT_FILIAL+GVT_CDESP
			If	GVT->( dbSeek(xFilial("GVT") + oModel:GetValue("GFEX000_01", "MV_ESPDF4") ) ) 
				If  GVT->GVT_CHVCTE == "1" .Or. GVT->GVT_TPIMP !='3'
					Help( ,, 'HELP',, "Espécie não deve estar vinculada a nenhum imposto e a chave do CT-e não deve ser obrigatória.", 1, 0)
					Return .F.
				EndIf			
			EndIf			
		EndIf
	EndIf

	If oModel:GetValue("GFEX000_01", "MV_EMITMP") == "0" .And. oModel:GetValue("GFEX000_01", "MV_ERPGFE") == "2"
		MsgAlert("O Código do Emitente recomendado é por Numeração Própria. Integração Protheus>Código Emitente(MV_EMITMP).", "Atenção")
	EndIf

	//Validação que impede opção integração Automática x Data Informada (Fiscal e Financeiro)
	If (oModel:GetValue("GFEX000_01", "MV_GFEI16") == "2" .OR. oModel:GetValue("GFEX000_01", "MV_GFEI15") == "2" .OR. oModel:GetValue("GFEX000_01", "MV_GFEI17") == "2" ) ;
	.AND. oModel:GetValue("GFEX000_01", "MV_DSDTAP") == "3"
		Help( ,, 'HELP',, "Não é admitida a opção 'Data Informada' para o parâmetro 'Data Integração Financeiro' quando o tipo de uma ou mais integrações com o Financeiro é 'Automática'. Altere o(s) tipo(s) de integração para 'Sob Demanda' ou opte por 'Data Corrente' ou 'Data Criação' como 'Data de Integração Finaceiro'.", 1, 0)
		Return .F.
	EndIf
	
	//Validação que impede opção obriga fiscal = 'sim' antes da fatura no financ., quando a data de integração fiscal for a data financeira
	If GFXPR12127("MV_GFEI23")
	   If (oModel:GetValue("GFEX000_01", "MV_ERPGFE") == "1"  .AND. (oModel:GetValue("GFEX000_01", "MV_DSOFDT") == "2"  .AND. oModel:GetValue("GFEX000_01", "MV_GFEI23") == "1"))
	   	  Help( ,, 'HELP',, "Não é admitida a opção '1-Sim' para o parâmetro 'Fiscal Pré-requisito para Atualizar Fatura com Financ.' quando data de integração fiscal é 'Financeiro'.", 1, 0)
		  Return .F.	 
	   EndIf
	EndIf

	If oModel:GetValue("GFEX000_01", "MV_EMITMP") == "1"
		dbSelectArea("GU3")
		If GU3->( FieldPos("GU3_CDERP") ) == 0
			Help( ,, 'HELP',, "Não é possível utilizar Código do Emitente com Númeração própria. (MV_EMITMP).", 1, 0)
			Return .F.
		EndIf
	EndIf
	
	If !Empty(oModel:GetValue("GFEX000_01", "MV_EMIPRO")) .Or. ;
	   !Empty(oModel:GetValue("GFEX000_01", "MV_TABPRO")) .Or. ;
	   !Empty(oModel:GetValue("GFEX000_01", "MV_NEGPRO"))
	   
	   dbSelectArea("GVA")
	   GVA->( dbSetOrder(1) )
	   
		If !GVA->( dbSeek(xFilial("GVA")+oModel:GetValue("GFEX000_01", "MV_EMIPRO")+oModel:GetValue("GFEX000_01", "MV_TABPRO")) )
			Help( ,, 'HELP',, "Tabela de frete de estimativa não encontrada (MV_EMIPRO + MV_TABPRO).", 1, 0)
			Return .F.			
		EndIf
		
		dbSelectArea("GV9")
	   	GV9->( dbSetOrder(1) )
	   	
		If	GV9->( dbSeek(xFilial("GV9")+oModel:GetValue("GFEX000_01", "MV_EMIPRO")+oModel:GetValue("GFEX000_01", "MV_TABPRO")+oModel:GetValue("GFEX000_01", "MV_NEGPRO")) )
			If GV9->GV9_SIT == "1"
				Help( ,, 'HELP',, "Negociação da tabela de frete de estimativa deve estar com a situação 'Liberada' (MV_EMIPRO + MV_TABPRO + MV_NEGPRO).", 1, 0)
				Return .F.	
			EndIf			
		Else
			Help( ,, 'HELP',, "Negociação da tabela de frete de estimativa não encontrada (MV_EMIPRO + MV_TABPRO + MV_NEGPRO).", 1, 0)
			Return .F.
		EndIf
	   
	EndIf
	
	
	If !Empty(SuperGetMv("MV_INTTMS",.F.,.F.)) .And. SuperGetMv("MV_INTTMS",.F.,.F.)
		If !Empty(FWFldGet("MV_TMSGFE")) .And. !FWFldGet("MV_TMSGFE") ;
		.And. GfeVerCmpo({"GU5_OCOTMS"}) .And. !Empty(FWFldGet("MV_TMS2GFE")) .And. FWFldGet("MV_TMS2GFE")
			Help(,, 'HELP',, "Quando a integração de ocorrências com o TMS está ativo (MV_TMS2GFE,Integração Protheus), a integração de redespachos também deve estar ativo(MV_TMSGFE)",1,0)
			Return .F.
		EndIf
	EndIf
	
	//A mesma regra existe no GFEA065/GFEA118/GEFX000.
	//Validação de utilização do Totvs Colaboração 2.0
	//Lógica copiada da função ColabGeneric.prw
	If FWFldGet("MV_SPEDCOL") == "S" .And. ( ("0" $ AllTrim(FWFldGet("MV_TCNEW"))) .Or. ("6" $ AllTrim(FWFldGet("MV_TCNEW")))) //0-Todos / 6-Recebimento
		If !FWLSEnable(TOTVS_COLAB_ONDEMAND) .and. !FwEmpTeste()
			Help(,, 'HELP',, "Ambiente não licenciado para o modelo TOTVS Colaboração 2.0. O campo Tipos de documento transmitidos não pode conter 0 e 6.",1,0)
			Return .F.
		EndIf
	EndIf

	If oStruct:HasField("MV_ACGRRAT")
		If FwFldGet("MV_ACGRRAT") == "2" .And. FwFldGet("MV_TPGERA") == "2"
			Help(,, 'HELP',, "Quando a Ação para item sem Rateio Contábil for 2-desfazer cálculo e o tipo de geração contábil estiver como sob demanda, não será possível efetuar cálculos de romaneio.",1,0)
			Return .F.
		EndIf
	EndIf
	
	If oStruct:HasField("MV_INTTAB")
		If FwFldGet("MV_TFMLA") == "1" .And. FwFldGet("MV_INTTAB") == "2"
			Help(,,"HELP",,"É permitido marcar apenas um dos parâmetros de integração da tabela de frete, então desmarque a integração com o MLA ou a integração com a consulta Datasul",1,0)
			Return .F.
		EndIf
	EndIf
	
	If oModel:GetValue("GFEX000_01", "MV_GFE016") <> SuperGetMV("MV_GFE016",.F.,"1")
		cQuery := "SELECT GW2.GW2_NRCONT FROM " + RetSqlName("GW2") + " GW2"
		cQuery += " WHERE GW2.GW2_SITCON <> '3'"
		cQuery += " AND GW2.GW2_SITCON <> '4'"
		cQuery += " AND GW2.D_E_L_E_T_ = ''"
		
		cAliasGW2 := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery), cAliasGW2, .F., .T.)
		(cAliasGW2)->(dbGoTop())
		
		If (cAliasGW2)->(Recno()) > 0
			MsgAlert("Atenção! Exsitem contratos em aberto (situação criado ou confirmado). Avalie o impacto da alteração do parâmetro 'Data de Referência para apuração IRRF', se houver mais de um contrato para um mesmo proprietário. ")
		EndIf
		
		(cAliasGW2)->(dbCloseArea())
	EndIf
Return .T.

/*
Valida Campos para ativar ou desativar alterações
*/
Function GFEX000VAC(cCampo)
	Local lRet := .T.
	Default cCampo := ReadVar()
	
	Do Case

		Case At("GU1_SIT", cCampo) > 0 
			
			If M->GU1_ORIGEM == '1'
				
				lRet := .F.
			EndIf
			
		Case At("GU3_SIT", cCampo) > 0 
			
			lRet := Validacao('1')
			
		Case At("GU7_SIT", cCampo) > 0 
			
			lRet := Validacao('1')
			
		Case At("GUG_SIT", cCampo) > 0
			
			If SuperGetMv("MV_CADERP",.F.,'2') == '1' .And. SuperGetMv("MV_ERPGFE",.F.,'2') == '1'
				
				lRet := .F.
			EndIF
			
		Case At("GUH_SIT", cCampo) > 0 
			
			lRet := Validacao('1')
			
		Case At("GUE_SIT", cCampo) > 0
			
		 	lRet := Validacao('1')
		
		Case At("GU8_SIT", cCampo) > 0
			
			lRet := Validacao('2')
			
		Case At("GV3_SIT", cCampo) > 0
			
			lRet := Validacao('2') 
			
		Case At("GUU_SIT", cCampo) > 0
			
			lRet := Validacao('2')
				
	EndCase
	
Return lRet
/*/
Informa o Tipo de validação que sera feita pela Function GFEX000VAC()
/*/

Static Function Validacao(cTipo)
	Local lValid := .T.
	
	If cTipo == '1'
		If SuperGetMv("MV_CADERP",.F.,'2') == '1'
				
			lValid := .F.
		EndIf
	Else
		If SuperGetMv("MV_CADOMS",.F.,'2') == '1' .And. SuperGetMv("MV_ERPGFE",.F.,'2') == '2'
				
			lValid := .F.
		EndIf 
	EndIf
	
Return lValid

/*
Validação utilizada para mostrar mensagem de alerta quando o parâmetro MV_DSCTB for alterado para "2"
*/
Function ValidDSCTB( cVal,cMV_GFEI15, cMV_DSOFDT )

	Local oModel := FwModelActive()
	Default cVal := oModel:GetValue("GFEX000_01","MV_DSCTB")
	Default cMV_GFEI15 := oModel:GetValue("GFEX000_01","MV_GFEI15")
	Default cMV_DSOFDT := oModel:GetValue("GFEX000_01","MV_DSOFDT")
	
	/*Para informar o parâmetro "Contabilização Frete de Vendas" (MV_DSCTB) 
	como "2=Documento de Frete (Recebimento)", o parâmetro "Int Pré-fatura" (MV_GFEI15) estar marcado como 3-"Não integrar".*/
	If Alltrim(cVal) == "2" .And. cMV_GFEI15 <> "3" .And. cMV_DSOFDT <> "2"
		Help(,,"HELP",,"Para que a contabilização do frete venda seja realizada pelo Recebimento, desative a integração da Pré-Fatura com o Financeiro.",1,0)
		Return .F.
	EndIf

 	IF Alltrim(cVal)  != SuperGetMv("MV_DSCTB",.F.,"1") .And. Alltrim(cVal) == "2"
 		Help(,,"HELP",,"Atenção: refaça a grade de lançamentos contábeis dos Documentos de Frete e Faturas de Frete não enviados para o ERP. Para essa ação é possível utilizar o programa Gerar Contabilização - GFEA095",1,0)
	EndIf
	
Return .T.

Static Function ValidFTMLA(oModel)
	Local oView := Nil

	If oModel:GetValue("MV_FTMLA") == "2" .And. oModel:GetValue("MV_GFEI16") == "2"
		Help(,,"HELP",,"Desative a integração automática da Fatura para utilizar esta opção. (MV_GFEI16)",1,0)
		
		oView := FwViewActive()
		oModel:LoadValue("MV_FTMLA","1")
		oView:Refresh()
	EndIf
Return .T.
/* . */

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidTPEST
Só permite informar a opção 2=Parcial se o ERP for Datasul (MV_ERPGFE).

@author Elynton Fellipe Bazzo
@since 05/01/2016
@version 1.0
/*/
//------------------------------------------------------------------- 
Function ValidTPEST( cVal,cMV_ERPGFE,lConfirmar )

	Local oModel 	:= FwModelActive()
	Local cQuery 	:= ""
	Local cAliasQry := ""
	
	Default cMV_ERPGFE := SuperGetMv("MV_ERPGFE",.F.,'1')
	Default lConfirmar := .F.
	
	If lConfirmar
		If oModel:GetValue("GFEX000_01", "MV_CADERP") == "1" //Se a origem dos cadastros for 'ERP'
			If Alltrim(cVal) == "2" .And. cMV_ERPGFE <> "1"
				Help(,,"HELP",,"A opção de Estorno Parcial está disponível apenas para o ERP Datasul",1,0)
				Return .F.
			EndIf
		EndIf
	EndIf
	
	If oModel:GetValue("GFEX000_01", "MV_TPEST") <> cValToChar(SuperGetMV('MV_TPEST',,'1')) //Se houve alteração
		/*Não permite alterar o parâmetro (de Total para Parcial ou vice-versa) se existirem Lotes Contábeis (GXE) em aberto  
		(situação diferente de não-enviado ou estornado).*/
		cAliasQry := GetNextAlias()
		cQuery := " SELECT * FROM " + RetSQLName( "GXE" ) + " WHERE GXE_SIT <> '1' AND GXE_SIT <> '6' AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		
		If !(cAliasQry)->( Eof() )
			Help(,,"HELP",,"Não é possível alterar o Tipo Estorno Provisão, pois  existem lotes contábeis pendentes.",1,0)
			Return .F.
		EndIf
		
		(cAliasQry)->(dbCloseArea())
	EndIf
	
Return .T.

Static Function AtuOcorr()

	nVal := IIf ( SuperGetMv("MV_TMS2GFE",.F.,.F.) == .T.,"1","2") 
	
Return nVal
/* . */  
