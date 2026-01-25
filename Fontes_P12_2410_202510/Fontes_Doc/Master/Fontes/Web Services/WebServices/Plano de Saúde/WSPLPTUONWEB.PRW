#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE LOGSISPAC "PLSSISPAC.log"

//-------------------------------------------------------------------
/*/{Protheus.doc} PtuOnLayWB
Retorna array com os layouts das transacoes PTU Online

@author  PLS TEAM
@version P11
@since   29/08/16
/*/
//-------------------------------------------------------------------
Function PtuOnLayWB(cCodTra)

	Local aStrucPtu := {}
	Local lPTUOn70 := Alltrim(GetNewPar("MV_PTUVEON","70")) >= "70"
	Local cVersao := "0"+GetNewPar("MV_PTUVEON","70")
	Local lPTUOn80 := Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80"
	Local lPTUOn90 := Alltrim(GetNewPar("MV_PTUVEON","90")) >= "90"
	Local lPTUOn91 := Alltrim(GetNewPar("MV_PTUVEON","91")) >= "91"

	/*
	Estrutura do array de configuracao dos layouts

	[01] -> Layout
	[02] -> Tag (Elemento de Dado)
	[03] -> Campo PTU (indicar 10 caracteres no maximo)
	[04] -> Array de trabalho
	[05] -> Indica tag de abertura de no
	[06] -> Conteudo pre-estabelecido caso a tag nao tenha sido informada no array de dados
	[07] -> Nivel de tag (controla nos e seus filhos)
	[08] -> Tipo do Dado (C-Caracter / D-Data)
	[09] -> Regra para geracao da tag
	[10] -> Indica que e uma tag array que tem repeticao
	[11] -> Indica a regra de repeticao da tag array
	[12] -> Indica a variavel de controle do array de repeticao
	[13] -> Indica se a tag e obrigatoria
	[14] -> Indica o tamanho do campo
	[15] -> Indica se gera a tag vazia no formato <tag />

	As versoes do PTU sempre trabalham em no maximo duas versoes simultaneas.
	Ao criar um novo Array de versao, remover o mais antigo.
	*/

	Do Case
	Case cCodTra == "00600" // Pedido de Autorizacao

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00600","pedidoAutorizacaoWS"})
		AAdd(aStrucPtu,{"00600","cabecalhoTransacao"            ,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00600","codigoTransacao"               ,"CD_TRANS"     ,"aDados",.F.,"00600",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00600","tipoCliente"               ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIF

		AAdd(aStrucPtu,{"00600","codigoUnimedPrestadora"        ,"CD_UNI_ORI"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad())) ,2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00600","codigoUnimedOrigemBeneficiario","CD_UNI_DES"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Pedido de Autorizacao
		AAdd(aStrucPtu,{"00600","pedidoAutorizacao"        		,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00600","numeroTransacaoPrestadora"		,"NR_IDENT_O"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})

		AAdd(aStrucPtu,{"00600","identificacaoBeneficiario"		,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00600","codigoUnimed"             		,"CD_UNI"       ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00600","codigoIdentificacao"      		,"ID_BENEF"     ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,13,"N"})
		AAdd(aStrucPtu,{"00600","identificacaoBiometrica"  		,"DS_BIOMETR"   ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00600","numeroViaCartao"          	,"NR_VIA_CAR"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
		EndIf

		AAdd(aStrucPtu,{"00600","codigoCID"                		,"CD_CID"       ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,4,"N"})

		If !lPTUOn80 .And. !lPTUOn90
			AAdd(aStrucPtu,{"00600","tpRedeMIN"                	,"TIPO_REDE_"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,1,"N"})
		EndIf

		If !lPTUOn90
			AAdd(aStrucPtu,{"00600","prestador"                	,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
			AAdd(aStrucPtu,{"00600","codigoUnimed"             	,"CD_UNI_PRE"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
			AAdd(aStrucPtu,{"00600","codigoPrestador"          	,"CD_PREST"     ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,8,"N"})
			AAdd(aStrucPtu,{"00600","nomePrestador"            	,"NM_PRESTAD"   ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,25,"N"})
		EndiF

		If lPTUOn80 .And. !lPTUOn90
			AAdd(aStrucPtu,{"00600","tpRedeMIN"            		,"TIPO_REDE_"   ,"aDados",.F.,"",3,"N","",.F.,"","",.F.,1,"N"})
		EndIf

		If !lPTUOn90
			AAdd(aStrucPtu,{"00600","prestadorRequisitante"    	,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
			AAdd(aStrucPtu,{"00600","codigoUnimed"             	,"CD_UNI_REQ"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
			AAdd(aStrucPtu,{"00600","codigoPrestador"          	,"CD_PRE_REQ"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,8,"N"})
		EndIf

		If lPTUOn90
			AAdd(aStrucPtu,{"00600","prestadorSolicitante"     	,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
			AAdd(aStrucPtu,{"00600","codigoUnimed"             	,"CD_UNI_REQ"   ,"aDados",.F.,"",3,"N","",.F.,"","",.F.,4,"N"})
			AAdd(aStrucPtu,{"00600","codigoPrestador"          	,"CD_PRE_REQ"   ,"aDados",.F.,"",3,"N","",.F.,"","",.F.,8,"N"})
			AAdd(aStrucPtu,{"00600","nomePrestadorSolic"       	,"NM_PRO_SOLIC" ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,70,"N"})
			AAdd(aStrucPtu,{"00600","siglaConselho"            	,"SG_CONSEL"    ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,12,"N"})
			AAdd(aStrucPtu,{"00600","numeroConselho"           	,"NM_CONSEL"    ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,15,"N"})
			AAdd(aStrucPtu,{"00600","unidadeFederativa"        	,"UN_FEDERA"    ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,2,"N"})
			AAdd(aStrucPtu,{"00600","numeroCBO"                	,"CD_CBO_SOL"   ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,6,"N"})

			AAdd(aStrucPtu,{"00600","prestadorExecutante"      	,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
			AAdd(aStrucPtu,{"00600","codigoUnimed"             	,"CD_UNI_PRE"   ,"aDados",.F.,"",3,"N","",.F.,"","",.F.,4,"N"})
			AAdd(aStrucPtu,{"00600","codigoPrestador"          	,"CD_PREST"     ,"aDados",.F.,"",3,"N","",.F.,"","",.F.,8,"N"})
			AAdd(aStrucPtu,{"00600","nomePrestador"            	,"NM_PRESTAD"   ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,25,"N"})
			AAdd(aStrucPtu,{"00600","tpRedeMIN"                	,"TIPO_REDE_"   ,"aDados",.F.,"",3,"N","",.F.,"","",.F.,1,"N"})
			AAdd(aStrucPtu,{"00600","numeroCBO"                	,"CD_CBO_EXEC"  ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,6,"N"})
		EndIf

		If !lPTUOn90
			AAdd(aStrucPtu,{"00600","codigoEspecialidadeMedica"	,"CD_ESPEC"     ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,2,"N"})
		EndIf

		AAdd(aStrucPtu,{"00600","idUrgenciaEmergencia"     		,"ID_URG_EME"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00600","dataAtendimento"          		,"DT_ATENDIM"   ,"aDados",.F.,"",2,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00600","numeroVersaoPTU"          		,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00600","idRN"                     		,"ID_RN"        ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00600","tpInternacao"             		,"TP_INTERNA"   ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,1,"N"})

		If !lPTUOn90 .Or. lPTUOn91
			AAdd(aStrucPtu,{"00600","idAcidente"               	,"ID_ACIDENT"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,1,"N"})
		EndIf

		AAdd(aStrucPtu,{"00600","cdUnimedAtend"            		,"CD_UNI_ATE"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad())),2,"N","",.F.,"","",.T.,4,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00600","idAnexo"                  	,"ID_ANEXO"     ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
		EndIf

		If !lPTUOn90
			AAdd(aStrucPtu,{"00600","tpSexo"                   	,"TP_SEXO"      ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,1,"N"})
			AAdd(aStrucPtu,{"00600","nrIdade"                  	,"NR_IDADE"     ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,3,"N"})
		EndIf

		AAdd(aStrucPtu,{"00600","dataSugeridaInternacao"   		,"DT_SUG_INT"   ,"aDados",.F.,"",2,"D","",.F.,"","",.F.,8,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00600","idOrdemServico"           	,"ID_ORDEM_S"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,1,"N"})
		EndIf

		AAdd(aStrucPtu,{"00600","nrIdentOrdemServico"      		,"NR_IDE_OS"    ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,10,"N"})
		AAdd(aStrucPtu,{"00600","nrVerTiss"                		,"NR_VER_TIS"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,7,"N"})
		AAdd(aStrucPtu,{"00600","observacao"               		,"DS_OBSERVA"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00600","indicacaoClinica"         		,"DS_IND_CLI"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00600","idLiminar"                		,"ID_LIMINAR"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00600","cdIBGE"                   		,"CD_IBGE"      ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,7,"N"})
		AAdd(aStrucPtu,{"00600","protocoloAtendimento"     		,"PROT_ATEND"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,20,"N"})
		AAdd(aStrucPtu,{"00600","token"                    		,"TOKEN"        ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,10,"N"})
		AAdd(aStrucPtu,{"00600","tipoEtapaAutorizacao"     		,"TP_ETAP_AUT"  ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00600","dataSolicitacao"          		,"DT_SOLICIT"   ,"aDados",.F.,"",2,"D","",.F.,"","",.T.,8,"N"})
		AAdd(aStrucPtu,{"00600","tipoGuia"                 		,"TP_GUIA"      ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00600","tpAcomodacao"     	       		,"TP_ACOMODAC"  ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,2,"N"})

		If lPTUOn90
			AAdd(aStrucPtu,{"00600","complementar1"           	,"ID_COMPLEM1"  ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,2,"N"})
			AAdd(aStrucPtu,{"00600","complementar2"           	,"ID_COMPLEM2"  ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,2,"N"})
			AAdd(aStrucPtu,{"00600","IndicadorRecursoProprio"   ,"ID_COMPLEM3"  ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,2,"N"})
			AAdd(aStrucPtu,{"00600","idCoberturaEspecial"     	,"ID_COBESPE"   ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,1,"N"})
			AAdd(aStrucPtu,{"00600","saudeOcupacional"     	  	,"ID_SAUDEOCUP" ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,1,"N"})
		EndIf

		//Bloco de Eventos - Bloco Servico Pedido
		AAdd(aStrucPtu,{"00600","blocoServicoPedido"          	,""             ,"aItens",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00600","pedidoServico"               	,""             ,"aItens",.T.,"",3,"C","",.T.,"{||(nItem+1 <= len(aItens))}","nItem",.T.,0,"N"})
		AAdd(aStrucPtu,{"00600","servico"                     	,""             ,"aItens",.T.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00600","sqitem"                      	,"SQ_ITEM"      ,"aItens",.F.,"",5,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00600","tipoTabela"                  	,"TP_TABELA"    ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00600","codigoServico"               	,"CD_SERVICO"   ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00600","quantidadeServico"           	,"QT_SERVICO"   ,"aItens",.F.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00600","descricaoServico"            	,"DS_SERVICO"   ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,80,"N"})
		AAdd(aStrucPtu,{"00600","valor"                       	,"VL_SERVICO"   ,"aItens",.F.,"",4,"N2","",.F.,"","",.F.,0,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00600","valorUnitarioServico"      ,"VL_UNI_SER"   ,"aItens",.F.,"",4,"N2","",.F.,"","",.F.,0,"N"})
		EndIf

		AAdd(aStrucPtu,{"00600","codigoAnvisa"                	,"CD_ANVISA"    ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,15,"N"})
		AAdd(aStrucPtu,{"00600","referenciaMaterialFabricante"	,"CD_REF_FAB"   ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,30,"N"})
		AAdd(aStrucPtu,{"00600","tpAnexo"                     	,"TP_ANEXO"     ,"aItens",.F.,"",4,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00600","dataProv"                    	,"DT_PROVAVE"   ,"aItens",.F.,"",4,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00600","totalDosagem"               	,"TOT_DOSAGE"   ,"aItens",.F.,"",4,"N2","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00600","unMedicamento"              	,"UNI_MEDIDA"   ,"aItens",.F.,"",4,"N","",.F.,"","",.F.,3,"N"})
		AAdd(aStrucPtu,{"00600","cdViaAdmin"                  	,"CD_VIA_ADM"   ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,2,"N"})
		AAdd(aStrucPtu,{"00600","qtFrequencia"                	,"QT_FREQUEN"   ,"aItens",.F.,"",4,"N","",.F.,"","",.F.,2,"N"})
		AAdd(aStrucPtu,{"00600","tpOrdem"                     	,"TP_ORDEM"     ,"aItens",.F.,"",4,"N","",.F.,"","",.F.,1,"N"})

		// Dados Anexo OPME
		AAdd(aStrucPtu,{"00600","dadosAnexoOPME"             	,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00600","dsOPME"                     	,"DS_OPME"      ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00600","justificativaTecnica"       	,"DS_JUST_TE"   ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,999,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00600","dsMatSolic"                ,"DS_MAT_SOL"   ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		Else
			AAdd(aStrucPtu,{"00600","especMatSolic"             ,"DS_MAT_SOL"   ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		EndIf

		AAdd(aStrucPtu,{"00600","ProfissionalSolicitanteOPME"	,""             ,"aDados",.T.,"",3,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00600","nomeProfissional"           	,"NM_SOLIC_O"   ,"aDados",.F.,"",4,"C","",.F.,"","",.T.,70,"N"})
		AAdd(aStrucPtu,{"00600","numeroTelefone"             	,"NR_TEL_OPM"   ,"aDados",.F.,"",4,"N","",.F.,"","",.T.,11,"N"})
		AAdd(aStrucPtu,{"00600","enderecoEmail"              	,"END_EM_OPM"   ,"aDados",.F.,"",4,"C","",.F.,"","",.F.,60,"N"})

		// Dados Anexo Quimio
		AAdd(aStrucPtu,{"00600","dadosAnexoQuimio"             	,""             ,"aQuimio",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00600","descricaoDiagCitHist"         	,"DS_DIAG_QU"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00600","informacoesRelevantes"        	,"DS_INF_QUI"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00600","planoTerapeutico"             	,"DS_PL_TERA"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,999,"N"})
		AAdd(aStrucPtu,{"00600","dsQuimio"                     	,"DS_QUIMIO"    ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00600","alturaBenef"                  	,"NR_ALTBENE"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,6,"N"})
		AAdd(aStrucPtu,{"00600","pesoBenef"                    	,"NR_PESOBEN"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,6,"N"})
		AAdd(aStrucPtu,{"00600","supCorp"                      	,"NR_SUPCORP"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,5,"N"})
		AAdd(aStrucPtu,{"00600","dataDiag"                     	,"DT_DIAG"      ,"aQuimio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00600","cdCID"                        	,"CD_CID1"      ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00600","cdCID"                        	,"CD_CID2"      ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00600","cdCID"                        	,"CD_CID3"      ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00600","cdCID"                        	,"CD_CID4"      ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00600","estadTumor"                   	,"CD_ESTADIA"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})

		If lPTUOn90
			AAdd(aStrucPtu,{"00600","cdFinalidade"                 	,"CD_FINALID"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00600","cdEcog"                       	,"CD_ECOG"      ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00600","tpQuimio"                     	,"TP_QUIMIO"    ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00600","numeroCiclos"                 	,"NR_CICLOS"    ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
			AAdd(aStrucPtu,{"00600","cicloAtual"                   	,"NR_CL_ATUA"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
			AAdd(aStrucPtu,{"00600","intervaloCiclos"              	,"NR_INTERV"    ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
			AAdd(aStrucPtu,{"00600","dsCirurgia"                   	,"DS_CIRURGI"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
			AAdd(aStrucPtu,{"00600","dtCirurgia"                   	,"DT_CIRURGI"   ,"aQuimio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
			AAdd(aStrucPtu,{"00600","dsAreaIrrad"                  	,"DS_AREA_IR"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
			AAdd(aStrucPtu,{"00600","dtIrrad"                      	,"DT_IRRAD"     ,"aQuimio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
			AAdd(aStrucPtu,{"00600","clMetastase"                  	,"CL_METASTA"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
			AAdd(aStrucPtu,{"00600","clNodulo"                     	,"CL_NODULO"    ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
			AAdd(aStrucPtu,{"00600","clTumor"                      	,"CL_TUMOR"     ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
			AAdd(aStrucPtu,{"00600","qtDiasCicloAtual"             	,"QT_DIAS_CI"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
		Else
			AAdd(aStrucPtu,{"00600","tpQuimio"                     	,"TP_QUIMIO"    ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00600","cdFinalidade"                 	,"CD_FINALID"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00600","cdEcog"                       	,"CD_ECOG"      ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00600","clTumor"                      	,"CL_TUMOR"     ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
			AAdd(aStrucPtu,{"00600","clNodulo"                     	,"CL_NODULO"    ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
			AAdd(aStrucPtu,{"00600","clMetastase"                  	,"CL_METASTA"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
			AAdd(aStrucPtu,{"00600","numeroCiclos"                 	,"NR_CICLOS"    ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
			AAdd(aStrucPtu,{"00600","cicloAtual"                   	,"NR_CL_ATUA"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
			AAdd(aStrucPtu,{"00600","qtDiasCicloAtual"             	,"QT_DIAS_CI"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
			AAdd(aStrucPtu,{"00600","intervaloCiclos"              	,"NR_INTERV"    ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
			AAdd(aStrucPtu,{"00600","dsCirurgia"                   	,"DS_CIRURGI"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
			AAdd(aStrucPtu,{"00600","dtCirurgia"                   	,"DT_CIRURGI"   ,"aQuimio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
			AAdd(aStrucPtu,{"00600","dsAreaIrrad"                  	,"DS_AREA_IR"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
			AAdd(aStrucPtu,{"00600","dtIrrad"                      	,"DT_IRRAD"     ,"aQuimio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
		EndIf

		AAdd(aStrucPtu,{"00600","ProfissionalSolicitanteQuimio"	,""             ,"aQuimio",.T.,"",3,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00600","nomeProfissional"             	,"NM_SOL_QUI"   ,"aQuimio",.F.,"",4,"C","",.F.,"","",.T.,70,"N"})
		AAdd(aStrucPtu,{"00600","numeroTelefone"               	,"NR_TEL_QUI"   ,"aQuimio",.F.,"",4,"N","",.F.,"","",.T.,11,"N"})
		AAdd(aStrucPtu,{"00600","enderecoEmail"                	,"END_EM_QUI"   ,"aQuimio",.F.,"",4,"C","",.F.,"","",.F.,60,"N"})

		// Dados Anexo Radio
		AAdd(aStrucPtu,{"00600","dadosAnexoRadio "             	,""             ,"aRadio",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00600","descricaoDiagCitHist"         	,"DS_DIAG_RA"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00600","informacoesRelevantes"        	,"DS_INF_RAD"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00600","dsRadio"                      	,"DS_RADIO"     ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00600","dataDiag"                     	,"DT_DIAG"      ,"aRadio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00600","cdCID"                        	,"CD_CID1"      ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00600","cdCID"                        	,"CD_CID2"      ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00600","cdCID"                        	,"CD_CID3"      ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00600","cdCID"                        	,"CD_CID4"      ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00600","estadTumor"                   	,"CD_ESTADIA"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00600","cdFinalidade"                 	,"CD_FINALID"   ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00600","cdEcog"                       	,"CD_ECOG"      ,"aRadio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00600","cdDiagImg"                    	,"CD_DIAG_IM"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,1,"N"})
		AAdd(aStrucPtu,{"00600","qtCampos"                     	,"QT_CAMPOS"    ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00600","qtDoseDia"                    	,"QT_DOSE_DI"   ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00600","qtDoseTotal"                  	,"QT_DOSE_TO"   ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00600","qtDiasTratamento"             	,"QT_DIAS_TR"   ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00600","dtPrevAdmin"                  	,"DT_PREV_AD"   ,"aRadio",.F.,"",3,"D","",.F.,"","",.T.,8,"N"})
		AAdd(aStrucPtu,{"00600","dsCirurgia"                   	,"DS_CIRURGI"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
		AAdd(aStrucPtu,{"00600","dtCirurgia"                   	,"DT_CIRURGI"   ,"aRadio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00600","dsQuimio"                     	,"DS_QUIMIOT"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
		AAdd(aStrucPtu,{"00600","dtQuimio"                     	,"DT_QUIMIOT"   ,"aRadio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})

		AAdd(aStrucPtu,{"00600","ProfissionalSolicitanteRadio"	,""             ,"aRadio",.T.,"",3,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00600","nomeProfissional"             	,"NM_SOL_RAD"   ,"aRadio",.F.,"",4,"C","",.F.,"","",.T.,70,"N"})
		AAdd(aStrucPtu,{"00600","numeroTelefone"               	,"NR_TEL_RAD"   ,"aRadio",.F.,"",4,"N","",.F.,"","",.T.,11,"N"})
		AAdd(aStrucPtu,{"00600","enderecoEmail"                	,"END_EM_RAD"   ,"aRadio",.F.,"",4,"C","",.F.,"","",.F.,60,"N"})

	Case cCodTra == "00605" // Pedido de Complemento de Autorização

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00605","pedidoComplementoAutorizacaoWS"})
		AAdd(aStrucPtu,{"00605","cabecalhoTransacao"            	,""           	,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00605","codigoTransacao"               	,"CD_TRANS"   	,"aDados",.F.,"00605",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00605","tipoCliente"                   ,"TP_CLIENTE" 	,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00605","codigoUnimedPrestadora"        	,"CD_UNI_ORI" 	,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00605","codigoUnimedOrigemBeneficiario"	,"CD_UNI_DES" 	,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Pedido de Complemento de Autorização
		AAdd(aStrucPtu,{"00605","pedidoComplementoAutorizacao"		,""            	,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00605","numeroTransacaoPrestadora"			,"NR_IDENT_O"  	,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00605","numeroTransacaoOriginalPrestadora"	,"NR_TRANS_R"  	,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})

		AAdd(aStrucPtu,{"00605","identificacaoBeneficiario"			,""       		,"aDados",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00605","codigoUnimed"             			,"CD_UNI"       ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00605","codigoIdentificacao"       		,"ID_BENEF"     ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,13,"N"})
		AAdd(aStrucPtu,{"00605","identificacaoBiometrica"  			,"DS_BIOMETR"   ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00605","prestadorRequisitante"			,""       		,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
			AAdd(aStrucPtu,{"00605","codigoUnimed"             		,"CD_UNI_REQ"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
			AAdd(aStrucPtu,{"00605","codigoPrestador"          		,"CD_PRE_REQ"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,8,"N"})
			AAdd(aStrucPtu,{"00605","prestador"						,""       		,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
			AAdd(aStrucPtu,{"00605","codigoUnimed"             		,"CD_UNI_PRE"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
			AAdd(aStrucPtu,{"00605","codigoPrestador"          		,"CD_PREST"     ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,8,"N"})
		Else
			AAdd(aStrucPtu,{"00605","prestadorSolicitante"     		,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
			AAdd(aStrucPtu,{"00605","codigoUnimed"             		,"CD_UNI_REQ"   ,"aDados",.F.,"",3,"N","",.F.,"","",.F.,4,"N"})
			AAdd(aStrucPtu,{"00605","codigoPrestador"          		,"CD_PRE_REQ"   ,"aDados",.F.,"",3,"N","",.F.,"","",.F.,8,"N"})
			AAdd(aStrucPtu,{"00605","nomePrestadorSolic"       		,"NM_PRO_SOLIC" ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,70,"N"})
			AAdd(aStrucPtu,{"00605","siglaConselho"            		,"SG_CONSEL"   	,"aDados",.F.,"",3,"C","",.F.,"","",.F.,12,"N"})
			AAdd(aStrucPtu,{"00605","numeroConselho"           		,"NM_CONSEL"   	,"aDados",.F.,"",3,"C","",.F.,"","",.F.,15,"N"})
			AAdd(aStrucPtu,{"00605","unidadeFederativa"        		,"UN_FEDERA"   	,"aDados",.F.,"",3,"C","",.F.,"","",.F.,2,"N"})
			AAdd(aStrucPtu,{"00605","numeroCBO"                		,"CD_CBO_SOL"   ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,6,"N"})

			AAdd(aStrucPtu,{"00605","prestadorExecutante"      		,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
			AAdd(aStrucPtu,{"00605","codigoUnimed"             		,"CD_UNI_PRE"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
			AAdd(aStrucPtu,{"00605","codigoPrestador"          		,"CD_PREST"     ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,8,"N"})
			AAdd(aStrucPtu,{"00605","numeroCBO"                		,"CD_CBO_EXEC"  ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,6,"N"})
		EndIf

		If !lPTUOn90
			AAdd(aStrucPtu,{"00605","codigoEspecialidadeMedica"		,"CD_ESPEC"     ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,2,"N"})
		EndIf

		AAdd(aStrucPtu,{"00605","numeroVersaoPTU"    				,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00605","tpSexo"             			,"TP_SEXO"   	,"aDados",.F.,"",2,"N","",.F.,"","",.F.,1,"N"})
			AAdd(aStrucPtu,{"00605","nrIdade"          				,"NR_IDADE"     ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,3,"N"})
			AAdd(aStrucPtu,{"00605","idAnexo"						,"ID_ANEXO"     ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,1,"N"})
		EndIf

		AAdd(aStrucPtu,{"00605","observacao"     					,"DS_OBSERVA"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00605","indicacaoClinica"         			,"DS_IND_CLI"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00605","idLiminar"          				,"ID_LIMINAR"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00605","protocoloAtendimento"     			,"PROT_ATEND"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,20,"N"})
		AAdd(aStrucPtu,{"00605","token"                    			,"TOKEN"        ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,10,"N"})
		AAdd(aStrucPtu,{"00605","tpAcomodacao"              		,"TP_ACOMODAC"  ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,2,"N"})

		If lPTUOn90
			AAdd(aStrucPtu,{"00605","complementar1"           		,"ID_COMPLEM1"  ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,2,"N"})
			AAdd(aStrucPtu,{"00605","complementar2"           		,"ID_COMPLEM2"  ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,2,"N"})
			AAdd(aStrucPtu,{"00605","complementar3"           		,"ID_COMPLEM3"  ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,2,"N"})
		EndIf

		//Bloco de Eventos - Bloco Servico Pedido
		AAdd(aStrucPtu,{"00605","blocoServicoPedido"          		,""             ,"aItens",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00605","pedidoServico"               		,""             ,"aItens",.T.,"",3,"C","",.T.,"{||(nItem+1 <= len(aItens))}","nItem",.T.,0,"N"})
		AAdd(aStrucPtu,{"00605","servico"                     		,""             ,"aItens",.T.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00605","sqitem"                      		,"SQ_ITEM"      ,"aItens",.F.,"",5,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00605","tipoTabela"                  		,"TP_TABELA"    ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00605","codigoServico"               		,"CD_SERVICO"   ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00605","quantidadeServico"           		,"QT_SERVICO"   ,"aItens",.F.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00605","descricaoServico"            		,"DS_SERVICO"   ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,80,"N"})
		AAdd(aStrucPtu,{"00605","valor"                       		,"VL_SERVICO"   ,"aItens",.F.,"",4,"N2","",.F.,"","",.F.,0,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00605","valorUnitarioServico"        	,"VL_UNI_SER"   ,"aItens",.F.,"",4,"N2","",.F.,"","",.F.,0,"N"})
		EndIf

		AAdd(aStrucPtu,{"00605","codigoAnvisa"                		,"CD_ANVISA"    ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,15,"N"})
		AAdd(aStrucPtu,{"00605","referenciaMaterialFabricante"		,"CD_REF_FAB"   ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,30,"N"})
		AAdd(aStrucPtu,{"00605","tpAnexo"                     		,"TP_ANEXO"     ,"aItens",.F.,"",4,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00605","dataProv"                    		,"DT_PROVAVE"   ,"aItens",.F.,"",4,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00605","totalDosagem"                		,"TOT_DOSAGE"   ,"aItens",.F.,"",4,"N2","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00605","unMedicamento"               		,"UNI_MEDIDA"   ,"aItens",.F.,"",4,"N","",.F.,"","",.F.,3,"N"})
		AAdd(aStrucPtu,{"00605","cdViaAdmin"                  		,"CD_VIA_ADM"   ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,2,"N"})
		AAdd(aStrucPtu,{"00605","qtFrequencia"                		,"QT_FREQUEN"   ,"aItens",.F.,"",4,"N","",.F.,"","",.F.,2,"N"})
		AAdd(aStrucPtu,{"00605","tpOrdem"                     		,"TP_ORDEM"     ,"aItens",.F.,"",4,"N","",.F.,"","",.F.,1,"N"})

		// Dados Anexo OPME
		AAdd(aStrucPtu,{"00605","dadosAnexoOPME"					,""	            ,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00605","dsOPME"                      		,"DS_OPME"      ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00605","justificativaTecnica"        		,"DS_JUST_TE"   ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,999,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00605","dsMatSolic"              		,"DS_MAT_SOL"   ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		Else
			AAdd(aStrucPtu,{"00605","especMatSolic"           		,"DS_MAT_SOL"   ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		EndIf

		AAdd(aStrucPtu,{"00605","ProfissionalSolicitanteOPME" 		,""             ,"aDados",.T.,"",3,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00605","nomeProfissional"            		,"NM_SOLIC_O"   ,"aDados",.F.,"",4,"C","",.F.,"","",.T.,70,"N"})
		AAdd(aStrucPtu,{"00605","numeroTelefone"              		,"NR_TEL_OPM"   ,"aDados",.F.,"",4,"N","",.F.,"","",.T.,11,"N"})
		AAdd(aStrucPtu,{"00605","enderecoEmail"               		,"EMAIL_OPME"   ,"aDados",.F.,"",4,"C","",.F.,"","",.F.,60,"N"})

		// Dados Anexo Quimio
		AAdd(aStrucPtu,{"00605","dadosAnexoQuimio"	       			,""				,"aQuimio",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00605","descricaoDiagCitHist"   			,"DS_DIAG_QU"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00605","informacoesRelevantes"  			,"DS_INF_QUI"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00605","planoTerapeutico"       			,"DS_PL_TERA"	,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,999,"N"})
		AAdd(aStrucPtu,{"00605","dsQuimio"               			,"DS_QUIMIO"	,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00605","alturaBenef"            			,"NR_ALTBENE" 	,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,6,"N"})
		AAdd(aStrucPtu,{"00605","pesoBenef"              			,"NR_PESOBEN"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,6,"N"})
		AAdd(aStrucPtu,{"00605","supCorp"                			,"NR_SUPCORP"  	,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,5,"N"})
		AAdd(aStrucPtu,{"00605","dataDiag"               			,"DT_DIAG"     	,"aQuimio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00605","cdCID"                  			,"CD_CID1"  	,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00605","estadTumor"             			,"CD_ESTADIA"  	,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00605","tpQuimio"               			,"TP_QUIMIO"  	,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00605","cdFinalidade"           			,"CD_FINALID"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00605","cdEcog"                 			,"CD_ECOG"    	,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00605","clTumor"                			,"CL_TUMOR"  	,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00605","clNodulo"               			,"CL_NODULO"    ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00605","clMetastase"            			,"CL_METASTA"	,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00605","numeroCiclos"           			,"NR_CICLOS"  	,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00605","cicloAtual"             			,"NR_CL_ATUA"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00605","qtDiasCicloAtual"       			,"QT_DIAS_CI"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.F.,3,"N"})
		AAdd(aStrucPtu,{"00605","intervaloCiclos"        			,"NR_INTERV"  	,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00605","dsCirurgia"             			,"DS_CIRURGI"  	,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
		AAdd(aStrucPtu,{"00605","dtCirurgia"             			,"DT_CIRURGI"   ,"aQuimio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00605","dsAreaIrrad"            			,"DS_AREA_IR"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
		AAdd(aStrucPtu,{"00605","dtIrrad"                			,"DT_IRRAD"   	,"aQuimio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})

		AAdd(aStrucPtu,{"00605","ProfissionalSolicitanteQuimio" 	,""  	 	    ,"aQuimio",.T.,"",3,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00605","nomeProfissional"              	,"NM_SOL_QUI"  	,"aQuimio",.F.,"",4,"C","",.F.,"","",.T.,70,"N"})
		AAdd(aStrucPtu,{"00605","numeroTelefone"                	,"NR_TEL_QUI"  	,"aQuimio",.F.,"",4,"N","",.F.,"","",.T.,11,"N"})
		AAdd(aStrucPtu,{"00605","enderecoEmail"                 	,"END_EM_QUI"  	,"aQuimio",.F.,"",4,"C","",.F.,"","",.F.,60,"N"})

		// Dados Anexo Radio
		AAdd(aStrucPtu,{"00605","dadosAnexoRadio"	       			,""			  	,"aRadio",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00605","descricaoDiagCitHist"   			,"DS_CIT_RADIO" ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00605","informacoesRelevantes"  			,"DS_INF_RAD"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00605","dsRadio"                			,"DS_RADIO"	  	,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00605","dataDiag"               			,"DT_DIAG"      ,"aRadio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00605","cdCID"                  			,"CD_CID1"  	,"aRadio",.F.,"",3,"C","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00605","estadTumor"             			,"CD_ESTADIA"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00605","cdFinalidade"           			,"CD_FINALID"   ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00605","cdEcog"                 			,"CD_ECOG"      ,"aRadio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00605","cdDiagImg"              			,"CD_DIAG_IM"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,1,"N"})
		AAdd(aStrucPtu,{"00605","qtCampos"               			,"QT_CAMPOS"    ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00605","qtDoseDia"              			,"QT_DOSE_DI"   ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00605","qtDoseTotal"            			,"QT_DOSE_TO"   ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00605","qtDiasTratamento"       			,"QT_DIAS_TR"   ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00605","dtPrevAdmin"            			,"DT_PREV_AD"   ,"aRadio",.F.,"",3,"D","",.F.,"","",.T.,8,"N"})
		AAdd(aStrucPtu,{"00605","dsCirurgia"             			,"DS_CIRURGI"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
		AAdd(aStrucPtu,{"00605","dtCirurgia"             			,"DT_CIRURGA"   ,"aRadio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00605","dsQuimio"               			,"DS_QUIMIO"	,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
		AAdd(aStrucPtu,{"00605","dtQuimio"               			,"DT_QUIMIO"	,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,8,"N"})

		AAdd(aStrucPtu,{"00605","ProfissionalSolicitanteRadio" 		,""  			,"aRadio",.T.,"",3,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00605","nomeProfissional"             		,"NM_SOL_RAD"  	,"aRadio",.F.,"",4,"C","",.F.,"","",.T.,70,"N"})
		AAdd(aStrucPtu,{"00605","numeroTelefone"               		,"NR_TEL_RAD"   ,"aRadio",.F.,"",4,"N","",.F.,"","",.T.,11,"N"})
		AAdd(aStrucPtu,{"00605","enderecoEmail"                		,"END_EM_RAD"   ,"aRadio",.F.,"",4,"C","",.F.,"","",.F.,60,"N"})

	Case cCodTra == "00501" // Resposta Pedido Autorizacao

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00501","respostaPedidoAutorizacaoWS"})
		AAdd(aStrucPtu,{"00501","cabecalhoTransacao"            	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00501","codigoTransacao"               	,"CD_TRANS"     ,"aDados",.F.,"00501",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00501","tipoCliente"                   ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00501","codigoUnimedPrestadora"        	,"CD_UNI_ORI"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00501","codigoUnimedOrigemBeneficiario"	,"CD_UNI_DES"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Resposta Pedido Autorizacao
		AAdd(aStrucPtu,{"00501","respostaPedidoAutorizacao"        	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00501","numeroTransacaoPrestadora"        	,"NR_IDENT_O"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00501","numeroTransacaoOrigemBeneficiario"	,"NR_IDENT_D"   ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,10,"N"})

		AAdd(aStrucPtu,{"00501","identificacaoBeneficiario"        	,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00501","codigoUnimed"                     	,"CD_UNI"       ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00501","codigoIdentificacao"              	,"ID_BENEF"     ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,13,"N"})
		AAdd(aStrucPtu,{"00501","nomeBeneficiario"                 	,"NM_BENEF"     ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,25,"N"})

		If lPTUOn90
			AAdd(aStrucPtu,{"00501","nomeSocial"                   	,"NM_NOMSOC"    ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,70,"N"})
		EndIf

		AAdd(aStrucPtu,{"00501","dataValidadeAutorizacao"          	,"DT_VALIDAD"   ,"aDados",.F.,"",2,"D","aScan(aItens,{|item|item[aScan(item,{|value|value[1] == 'ID_AUTORIZ'})][2] $ '2'}) > 0" ,.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00501","tpAutorizacao"                    	,"TP_AUTORIZ"   ,"aDados",.F.,"1",2,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00501","tpAcomodacao"                     	,"TP_ACOMODA"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00501","numeroVersaoPTU"                  	,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00501","tpSexo"                           	,"TP_SEXO"      ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,1,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00501","dtNasc"                       	,"DT_NASC"      ,"aDados",.F.,"",2,"D","",.F.,"","",.F.,8,"N"})
		Else
			AAdd(aStrucPtu,{"00501","nrIdade"                      	,"NR_IDADE"     ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,3,"N"})
		EndIf

		AAdd(aStrucPtu,{"00501","observacao"                       	,"DS_LINHA_O"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,999,"N"})

		If lPTUOn90
			AAdd(aStrucPtu,{"00501","complementarResp1"            	,"ID_COMP_RES1", "aDados",.F.,"",2,"C","",.F.,"","",.F.,2,"N"})
			AAdd(aStrucPtu,{"00501","complementarResp2"            	,"ID_COMP_RES2", "aDados",.F.,"",2,"C","",.F.,"","",.F.,2,"N"})
			AAdd(aStrucPtu,{"00501","complementarResp3"            	,"ID_COMP_RES3", "aDados",.F.,"",2,"C","",.F.,"","",.F.,2,"N"})
		EndIf

		// Bloco de Eventos - Bloco Servico Resposta Pedido
		AAdd(aStrucPtu,{"00501","blocoServicoRespostaPedido"  		,""             ,"aItens",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00501","respostaPedidoServico"       		,""             ,"aItens",.T.,"",3,"C","",.T.,"{||(nItem+1 <= len(aItens))}","nItem",.T.,0,"N"})
		AAdd(aStrucPtu,{"00501","servico"                     		,""             ,"aItens",.T.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00501","sqitem"                      		,"SQ_ITEM"      ,"aItens",.F.,"",5,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00501","tipoTabela"                  		,"TP_TABELA"    ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00501","codigoServico"               		,"CD_SERVICO"   ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00501","descricaoServico"            		,"DS_SERVICO"   ,"aItens",.F.,"",5,"C","",.F.,"","",.F.,80,"N"})
		AAdd(aStrucPtu,{"00501","quantidadeAutorizada"        		,"QT_SERVICO"   ,"aItens",.F.,"",4,"C","Val(cConteudo) <> 0",.F.,"","",.T.,0,"N"})

		AAdd(aStrucPtu,{"00501","mensagensEspecificas"        		,""             ,"aItens",.T.,"",4,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00501","mensagem"                    		,"CD_MENS_E1"   ,"aItens",.F.,"",5,"C","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00501","mensagem"                    		,"CD_MENS_E2"   ,"aItens",.F.,"",5,"C","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00501","mensagem"                    		,"CD_MENS_E3"   ,"aItens",.F.,"",5,"C","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00501","mensagem"                    		,"CD_MENS_E4"   ,"aItens",.F.,"",5,"C","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00501","mensagem"                    		,"CD_MENS_E5"   ,"aItens",.F.,"",5,"C","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00501","descricaoMensagemEspec"      		,"DS_MENS_ES"   ,"aItens",.F.,"",5,"C","",.F.,"","",.F.,500,"N"})

		AAdd(aStrucPtu,{"00501","indicaAutorizacao"           		,"ID_AUTORIZ"   ,"aItens",.F.,"",4,"C","",.F.,"","",.T.,1,"N"})

	Case cCodTra == "00302" // Insistencia

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00302","pedidoInsistenciaWS"})
		AAdd(aStrucPtu,{"00302","cabecalhoTransacao"            	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00302","codigoTransacao"               	,"CD_TRANS"     ,"aDados",.F.,"00302",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00302","tipoCliente"                   ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00302","codigoUnimedPrestadora"        	,"CD_UNI_ORI"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00302","codigoUnimedOrigemBeneficiario"	,"CD_UNI_DES"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Insistencia
		AAdd(aStrucPtu,{"00302","pedidoInsistencia"                	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00302","numeroTransacaoPrestadora"        	,"NR_IDENT_O"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00302","numeroTransacaoOrigemBeneficiario"	,"NR_IDENT_D"   ,"aDados",.F.,"",2,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,10,"N"})
		AAdd(aStrucPtu,{"00302","numeroVersaoPTU"                  	,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00302","mensagemLivre"                    	,"DS_MENS_LI"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,999,"N"})

	Case cCodTra == "00309" // Confirmacao

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00309","confirmacaoWS"})
		AAdd(aStrucPtu,{"00309","cabecalhoTransacao"            	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00309","codigoTransacao"               	,"CD_TRANS"     ,"aDados",.F.,"00309",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00309","tipoCliente"                   ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00309","codigoUnimedPrestadora"        	,"CD_UNI_ORI"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00309","codigoUnimedOrigemBeneficiario"	,"CD_UNI_DES"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		//Corpo - Confirmacao
		AAdd(aStrucPtu,{"00309","confirmacao"                      	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00309","numeroTransacaoPrestadora"        	,"NR_IDENT_O"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00309","numeroTransacaoOrigemBeneficiario"	,"NR_IDENT_D"   ,"aDados",.F.,"",2,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,10,"N"})
		AAdd(aStrucPtu,{"00309","identificador"                    	,"TP_IDENTIF"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00309","numeroVersaoPTU"                  	,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})

	Case cCodTra == "00404" // Resposta de Auditoria

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00404","respostaAuditoriaWS"})
		AAdd(aStrucPtu,{"00404","cabecalhoTransacao"            	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00404","codigoTransacao"               	,"CD_TRANS"     ,"aDados",.F.,"00404",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00404","tipoCliente"                   ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00404","codigoUnimedPrestadora"        	,"CD_UNI_ORI"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00404","codigoUnimedOrigemBeneficiario"	,"CD_UNI_DES"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Resposta de Auditoria
		AAdd(aStrucPtu,{"00404","respostaAuditoria"                	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00404","numeroTransacaoPrestadora"        	,"NR_IDENT_O"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00404","numeroTransacaoOrigemBeneficiario"	,"NR_IDENT_D"   ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,10,"N"})
		AAdd(aStrucPtu,{"00404","dataValidadeAutorizacao"          	,"DT_VALIDAD"   ,"aDados",.F.,"",2,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00404","tpAutorizacao"                    	,"TP_AUTORIZ"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00404","numeroVersaoPTU"                  	,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00404","mensagemLivre"                    	,"DS_LINHA_O"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,999,"N"})

		//Bloco de eventos - Bloco Servico Resposta Auditoria
		AAdd(aStrucPtu,{"00404","blocoServicoRespostaAuditoria"		,""             ,"aItens",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00404","respostaPedidoServico"       		,""             ,"aItens",.T.,"",3,"C","",.T.,"{||(nItem+1 <= len(aItens))}","nItem",.T.,0,"N"})
		AAdd(aStrucPtu,{"00404","servico"                     		,""             ,"aItens",.T.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00404","sqitem"                      		,"SQ_ITEM"      ,"aItens",.F.,"",5,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00404","tipoTabela"                  		,"TP_TABELA"    ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00404","codigoServico"               		,"CD_SERVICO"   ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00404","descricaoServico"            		,"DS_SERVICO"   ,"aItens",.F.,"",5,"C","",.F.,"","",.F.,80,"N"})
		AAdd(aStrucPtu,{"00404","quantidadeAutorizada"        		,"QT_SERVICO"   ,"aItens",.F.,"",4,"C","Val(cConteudo) <> 0" ,.F.,"","",.F.,0,"N"})

		AAdd(aStrucPtu,{"00404","mensagensEspecificas"        		,""             ,"aItens",.T.,"",4,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00404","mensagem"                    		,"CD_MENS_E1"   ,"aItens",.F.,"",5,"C","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00404","mensagem"                    		,"CD_MENS_E2"   ,"aItens",.F.,"",5,"C","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00404","mensagem"                    		,"CD_MENS_E3"   ,"aItens",.F.,"",5,"C","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00404","mensagem"                    		,"CD_MENS_E4"   ,"aItens",.F.,"",5,"C","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00404","mensagem"                    		,"CD_MENS_E5"   ,"aItens",.F.,"",5,"C","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00404","descricaoMensagemEspec"      		,"DS_MENS_ES"   ,"aItens",.F.,"",5,"C","",.F.,"","",.F.,300,"N"})
		AAdd(aStrucPtu,{"00404","indicaAutorizacaoAuditoria"  		,"ID_AUTORIZ"   ,"aItens",.F.,"",4,"C","",.F.,"","",.T.,1,"N"})

	Case cCodTra == "00311" // Cancelamento

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00311","cancelamentoWS"})
		AAdd(aStrucPtu,{"00311","cabecalhoTransacao"            	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00311","codigoTransacao"               	,"CD_TRANS"     ,"aDados",.F.,"00311",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00311","tipoCliente"                   ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00311","codigoUnimedPrestadora"        	,"CD_UNI_ORI"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad())),2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00311","codigoUnimedOrigemBeneficiario"	,"CD_UNI_DES"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Cancelamento
		AAdd(aStrucPtu,{"00311","cancelamento"                     	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00311","numeroTransacaoPrestadora"        	,"NR_IDENT_O"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00311","numeroTransacaoOrigemBeneficiario"	,"NR_IDENT_D"   ,"aDados",.F.,"",2,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,10,"N"})
		AAdd(aStrucPtu,{"00311","numeroVersaoPTU"                  	,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00311","descricaoMotivo"                  	,"DS_MOTIVO"    ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,999,"N"})


	Case cCodTra == "00412" // Consulta de Dados do Beneficiário

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00412","consultaDadosBeneficiarioWS"})
		AAdd(aStrucPtu,{"00412","cabecalhoTransacao"            	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00412","codigoTransacao"               	,"CD_TRANS"     ,"aDados",.F.,"00412",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00412","tipoCliente"                   ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00412","codigoUnimedPrestadora"        	,"CD_UNI_EXE"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00412","codigoUnimedOrigemBeneficiario"	,"CD_UNI_BEN"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Consulta Dados Beneficiario
		AAdd(aStrucPtu,{"00412","consultaDadosBeneficiario"     	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00412","numeroTransacaoPrestadora"     	,"NR_IDENT_E"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00412","codigoUnimed"                  	,"CD_UNI"       ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00412","codigoIdentificacao"           	,"ID_BENEF"     ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,13,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00412","dataNascimento"                ,"DT_NASC"      ,"aDados",.F.,"",2,"D","",.F.,"","",.F.,8,"N"})
			AAdd(aStrucPtu,{"00412","nomeBeneficiario"              ,"NM_BENEF"     ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,25,"N"})
			AAdd(aStrucPtu,{"00412","ultimoSobrenomeBeneficiario"   ,"SB_NM_BENE"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,10,"N"})
		EndIf

		AAdd(aStrucPtu,{"00412","numeroCPF"                     	,"NR_CPF"       ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,11,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00412","numeroCNS"                     ,"NR_CNS"       ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00412","numeroVersaoPTU"               	,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00412","token"                         	,"TOKEN"        ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,10,"N"})

	Case cCodTra == "00413" // Resposta da Consulta de Dados do Beneficiário

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00413","respostaConsultaDadosBeneficiarioWS"})
		AAdd(aStrucPtu,{"00413","cabecalhoTransacao"            	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00413","codigoTransacao"               	,"CD_TRANS"     ,"aDados",.F.,"00413",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00413","tipoCliente"                   ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIF

		AAdd(aStrucPtu,{"00413","codigoUnimedPrestadora"        	,"CD_UNI_EXE"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00413","codigoUnimedOrigemBeneficiario"	,"CD_UNI_BEN"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Resposta Consulta Dados Beneficiario
		AAdd(aStrucPtu,{"00413","respostaConsultaDadosBeneficiario"	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00413","identificaSolicitacaoConfirmada"  	,"ID_CONFIRM"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00413","codigoMensagemErro"               	,"CD_MENS_ER"   ,"aDados",.F.,"",2,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00413","numeroTransacaoPrestadora"        	,"NR_IDENT_E"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00413","numeroTransacaoOrigemBeneficiario"	,"NR_IDENT_B"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00413","numeroVersaoPTU"                  	,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})

		// Bloco Nomes
		AAdd(aStrucPtu,{"00413","blocoNomes"                       	,""             ,"aItens",.T.,"",2,"C","",.T.,"{||(nItem+1 <= len(aItens))}","nItem",.F.,0,"N"})
		AAdd(aStrucPtu,{"00413","identificacaoBeneficiario"        	,""             ,"aItens",.T.,"",3,"C","",.F.,"","",.F.,0,"S"})
		AAdd(aStrucPtu,{"00413","codigoUnimed"                     	,"CD_UNI"       ,"aItens",.F.,"",4,"N","",.F.,"","",.F.,4,"S"})
		AAdd(aStrucPtu,{"00413","codigoIdentificacao"              	,"ID_BENEF"     ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,13,"S"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00413","nome"                          ,"NM_BENEF"     ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,25,"S"})
		EndIf

		AAdd(aStrucPtu,{"00413","nomeCompleto"                     	,"NM_COMPL_B"   ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,120,"S"})

		If lPTUOn90
			AAdd(aStrucPtu,{"00413","nomeSocial"                    ,"NM_NOMSOC"   ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,70,"N"})
		EndIf

		AAdd(aStrucPtu,{"00413","dataNascimento"                	,"DT_NASC"      ,"aItens",.F.,"",4,"D","",.F.,"","",.F.,8,"S"})
		AAdd(aStrucPtu,{"00413","sexoBeneficiario"              	,"TP_SEXO"      ,"aItens",.F.,"",4,"N","",.F.,"","",.F.,1,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00413","nomeEmpresa"                   ,"M_EMPR_ABR"   ,"aItens",.F.,"",3,"C","",.F.,"","",.F.,18,"N"})
			AAdd(aStrucPtu,{"00413","nomePlano"                     ,"NM_PLANO"     ,"aItens",.F.,"",3,"C","",.F.,"","",.F.,20,"S"})
		EndIf

		If lPTUOn90
			AAdd(aStrucPtu,{"00413","nrIdade"                       ,"NR_IDADE"     ,"aItens",.F.,"",3,"N","",.F.,"","",.F.,3,"S"})
		EndIf

		AAdd(aStrucPtu,{"00413","tpAcomodacao"                     	,"TP_ACOMOD"    ,"aItens",.F.,"",3,"C","",.F.,"","",.F.,2,"S"})
		AAdd(aStrucPtu,{"00413","tipoAbrangencia"                  	,"TP_ABRANGE"   ,"aItens",.F.,"",3,"N","",.F.,"","",.F.,1,"S"})
		AAdd(aStrucPtu,{"00413","localAtendimento"                 	,"CD_LCAT"      ,"aItens",.F.,"",3,"N","",.F.,"","",.F.,4,"S"})
		AAdd(aStrucPtu,{"00413","dataInclusaoUnimed"               	,"DT_INCL_UN"   ,"aItens",.F.,"",3,"D","",.F.,"","",.F.,8,"S"})
		AAdd(aStrucPtu,{"00413","dataExclusaoUnimed"               	,"DT_EXCL_UN"   ,"aItens",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00413","numeroViaCartao"               ,"NR_VIA_CAR"   ,"aItens",.F.,"",3,"N","",.F.,"","",.F.,2,"N"})
		EndIf

		AAdd(aStrucPtu,{"00413","cdRede"                           	,"CD_REDE"      ,"aItens",.F.,"",3,"C","",.F.,"","",.F.,4,"S"})
		AAdd(aStrucPtu,{"00413","idPlano"                          	,"ID_PLANO"     ,"aItens",.F.,"",3,"N","",.F.,"","",.F.,1,"S"})
		AAdd(aStrucPtu,{"00413","dataValidadeCarteira"          	,"DT_VAL_CAR"   ,"aItens",.F.,"",3,"D","",.F.,"","",.F.,8,"S"})

	Case cCodTra == "00418" // Consulta Prestador

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00418","consultaDadosPrestadorWS"})
		AAdd(aStrucPtu,{"00418","cabecalhoTransacao"            	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00418","codigoTransacao"               	,"CD_TRANS"     ,"aDados",.F.,"00418",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00418","tipoCliente"                   ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00418","codigoUnimedPrestadora"        	,"CD_UNI_EXE"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad())),2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00418","codigoUnimedOrigemBeneficiario"	,"CD_UNI_BEN"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		//Corpo - Consulta Dados Prestador
		AAdd(aStrucPtu,{"00418","consultaDadosPrestador"        	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00418","numeroTransacaoPrestadora"     	,"NR_IDENT_E"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00418","nomePrestador"                 	,"NM_PREST"     ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,40,"N"})
		AAdd(aStrucPtu,{"00418","cnpjCpfPrestador"              	,"CD_CGC_CPF"   ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,15,"N"})

		AAdd(aStrucPtu,{"00418","ct_conselhoProfissional"       	,""             ,""      ,.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00418","siglaConselho"                 	,"SG_CONS_PR"   ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,12,"N"})
		AAdd(aStrucPtu,{"00418","numeroConselho"                	,"NR_CONS_PR"   ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,15,"N"})
		AAdd(aStrucPtu,{"00418","unidadeFederativa"             	,"UF_CONS_PR"   ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00418","numeroVersaoPTU"               	,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})

	Case cCodTra == "00419" // Resposta da Consulta de Prestador

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00419","respostaConsultaDadosPrestadorWS"})
		AAdd(aStrucPtu,{"00419","cabecalhoTransacao"            	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00419","codigoTransacao"               	,"CD_TRANS"     ,"aDados",.F.,"00419",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00419","tipoCliente"                   ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00419","codigoUnimedPrestadora"        	,"CD_UNI_EXE"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad())),2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00419","codigoUnimedOrigemBeneficiario"	,"CD_UNI_BEN"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Resposta Consulta Dados Prestador
		AAdd(aStrucPtu,{"00419","respostaConsultaDadosPrestador"   	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00419","numeroTransacaoPrestadora"        	,"NR_IDENT_E"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00419","numeroTransacaoOrigemBeneficiario"	,"NR_IDENT_B"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00419","identificaSolicitacaoConfirmada"  	,"ID_CONFIRM"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00419","codigoMensagemErro"               	,"CD_MENS_ER"   ,"aDados",.F.,"",2,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00419","numeroVersaoPTU"                  	,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})

		// Bloco Nomes
		AAdd(aStrucPtu,{"00419","blocoNomes"                      	,""             ,"aItens",.T.,"",2,"C","",.T.,"{||(nItem+1 <= len(aItens))}","nItem",.F.,0,"N"})
		AAdd(aStrucPtu,{"00419","identificacaoPrestador"           	,""             ,"aItens",.T.,"",3,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00419","codigoUnimed"                     	,"CD_UNI_PRE"   ,"aItens",.F.,"",4,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00419","codigoPrestador"                  	,"CD_PREST  "   ,"aItens",.F.,"",4,"N","",.F.,"","",.T.,8,"N"})
		AAdd(aStrucPtu,{"00419","nomePrestador"                    	,"NM_PREST"     ,"aItens",.F.,"",4,"C","",.F.,"","",.T.,40,"N"})
		AAdd(aStrucPtu,{"00419","codigoEspecialidadeMedica"        	,"CD_ESPEC"     ,"aItens",.F.,"",4,"N","",.F.,"","",.F.,2,"N"})
		AAdd(aStrucPtu,{"00419","tpRedeMIN"                        	,"TP_REDE_MIN"  ,"aItens",.F.,"",4,"N","",.F.,"","",.T.,1,"N"})


	Case cCodTra == "00360" // Status da Transacao

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00360","statusTransacaoWS"})
		AAdd(aStrucPtu,{"00360","cabecalhoTransacao"            	,""            ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00360","codigoTransacao"               	,"CD_TRANS"    ,"aDados",.F.,"00360",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00360","tipoCliente"                   ,"TP_CLIENTE"  ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00360","codigoUnimedPrestadora"        	,"CD_UNI_EXE"  ,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00360","codigoUnimedOrigemBeneficiario"	,"CD_UNI_BEN"  ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Status da Transacao
		AAdd(aStrucPtu,{"00360","statusTransacao"                	,""            ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00360","numeroTransacaoPrestadora"      	,"NR_IDENT_E"  ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00360","numeroVersaoPTU"                	,"NR_VERSAO"   ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})


	Case cCodTra == "00361" // Resposta do Status da Transação

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00361","respostaStatusTransacaoWS"})
		AAdd(aStrucPtu,{"00361","cabecalhoTransacao"            	,""           ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00361","codigoTransacao"               	,"CD_TRANS"   ,"aDados",.F.,"00361",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00361","tipoCliente"               	,"TP_CLIENTE" ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIF

		AAdd(aStrucPtu,{"00361","codigoUnimedPrestadora"        	,"CD_UNI_EXE" ,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00361","codigoUnimedOrigemBeneficiario"	,"CD_UNI_BEN" ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Resposta Status Transacao
		AAdd(aStrucPtu,{"00361","respostaStatusTransacao"          	,""           ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00361","numeroTransacaoPrestadora"        	,"NR_IDENT_E" ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00361","numeroTransacaoOrigemBeneficiario"	,"NR_IDENT_B" ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,10,"N"})
		AAdd(aStrucPtu,{"00361","tpIdentificadorConfirmacao"       	,"TP_IDENTIF" ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00361","dataValidadeAutorizacao"          	,"DT_VALIDAD" ,"aDados",.F.,"",2,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00361","numeroVersaoPTU"                  	,"NR_VERSAO"  ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00361","tpSexo"                        ,"TP_SEXO"    ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,1,"N"})
			AAdd(aStrucPtu,{"00361","dtNasc"                        ,"DT_NASC"    ,"aDados",.F.,"",2,"D","",.F.,"","",.F.,8,"N"})
		EndIf

		AAdd(aStrucPtu,{"00361","observacao"                       	,"DS_OBSERVA" ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,999,"N"})

		// Bloco de eventos - Bloco Servico Resposta Pedido
		AAdd(aStrucPtu,{"00361","blocoServicoRespostaPedido"		,""           ,"aItens",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00361","respostaPedidoServico"     		,""           ,"aItens",.T.,"",3,"C","",.T.,"{||(nItem+1 <= len(aItens))}","nItem",.T.,0,"N"})
		AAdd(aStrucPtu,{"00361","servico"                   		,""           ,"aItens",.T.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00361","sqitem"                    		,"SQ_ITEM"    ,"aItens",.F.,"",5,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00361","tipoTabela"                		,"TP_TABELA"  ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00361","codigoServico"             		,"CD_SERVICO" ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00361","descricaoServico"          		,"DS_SERVICO" ,"aItens",.F.,"",5,"C","",.F.,"","",.F.,80,"N"})
		AAdd(aStrucPtu,{"00361","quantidadeAutorizada"      		,"QT_AUTORIZ" ,"aItens",.F.,"",4,"C","Val(cConteudo) <> 0" ,.F.,"","",.F.,0,"N"})

		AAdd(aStrucPtu,{"00361","mensagensEspecificas"      		,""           ,"aItens",.T.,"",4,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00361","mensagem"                  		,"CD_MENS_E1" ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00361","mensagem"                  		,"CD_MENS_E2" ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00361","mensagem"                  		,"CD_MENS_E3" ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00361","mensagem"                  		,"CD_MENS_E4" ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00361","mensagem"                  		,"CD_MENS_E5" ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00361","descricaoMensagemEspec"    		,"DS_MENS_ES" ,"aItens",.F.,"",5,"C","",.F.,"","",.F.,300,"N"})
		AAdd(aStrucPtu,{"00361","identificacaoResposta"     		,"ID_RESPOST" ,"aItens",.F.,"",4,"N","",.F.,"","",.T.,1,"N"})


	Case cCodTra == "00430" // Requisição de Contagem de Beneficiários

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00430","requisicaoContagemBeneficiariosWS"})
		AAdd(aStrucPtu,{"00430","cabecalhoTransacao"              ,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00430","codigoTransacao"                 ,"CD_TRANS"     ,"aDados",.F.,"00430",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00430","tipoCliente"                 ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00430","codigoUnimedPrestadora"          ,"CD_UNI_REQ"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00430","codigoUnimedOrigemBeneficiario"  ,"CD_UNI_DES"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Requisicao Contagem Beneficiarios
		AAdd(aStrucPtu,{"00430","requisicaoContagemBeneficiarios" ,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00430","dataReferencia"                  ,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.T.,8,"N"})
		AAdd(aStrucPtu,{"00430","anoReferencia"                   ,"ANO_REFERE"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00430","mesReferencia"                   ,"MES_REFERE"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})

		AAdd(aStrucPtu,{"00430","numeroVersaoPTU"                 ,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})


	Case cCodTra == "00431" // Resposta de Requisição de Contagem de Beneficiários

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00431","respostaRequisicaoContagemBeneficiariosWS"})
		AAdd(aStrucPtu,{"00431","cabecalhoTransacao"            			,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00431","codigoTransacao"               			,"CD_TRANS"     ,"aDados",.F.,"00431",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00431","tipoCliente"                  			,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00431","codigoUnimedPrestadora"        			,"CD_UNI_REQ"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00431","codigoUnimedOrigemBeneficiario"			,"CD_UNI_DES"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Resposta Requisicao Contagem Beneficiarios
		AAdd(aStrucPtu,{"00431","respostaRequisicaoContagemBeneficiarios"	,""     		,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00431","statusResposta"                   			,"ST_RETORNO"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00431","numeroBeneficiariosAtivos"        			,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})

		// Numero Beneficiarios Ativos
		// Custo Operacional
		AAdd(aStrucPtu,{"00431","custoOperacional"                 			,""             ,"aDados",.T.,"",3,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00431","pessoaFisica"                     			,""             ,"aDados",.T.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00431","situacao"                     				,""             ,"aDados",.T.,"",5,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00431","qtBeneficiarios"              				,"QT_PFCOQTD"   ,"aDados",.F.,"",6,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00431","pessoaJuridica"                   			,""             ,"aDados",.T.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00431","situacao"                     				,""             ,"aDados",.T.,"",5,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00431","qtBeneficiarios"              				,"QT_PJCOQTD"   ,"aDados",.F.,"",6,"N","",.F.,"","",.T.,10,"N"})

		// Pre Pagamento
		AAdd(aStrucPtu,{"00431","prePagamento"                     			,""             ,"aDados",.T.,"",3,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00431","pessoaFisica"                     			,""             ,"aDados",.T.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00431","situacao"                     				,""             ,"aDados",.T.,"",5,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00431","qtBeneficiarios"              				,"QT_PFPPQTD"   ,"aDados",.F.,"",6,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00431","pessoaJuridica"                   			,""             ,"aDados",.T.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00431","situacao"                     				,""             ,"aDados",.T.,"",5,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00431","qtBeneficiarios"              				,"QT_PJPPQTD"   ,"aDados",.F.,"",6,"N","",.F.,"","",.T.,10,"N"})

		AAdd(aStrucPtu,{"00431","numeroVersaoPTU"                  			,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})

	Case cCodTra == "00700" // Comunicacao de Decurso de Prazo

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00700","comunicacaoDecursoPrazoWS"})
		AAdd(aStrucPtu,{"00700","cabecalhoTransacao"            	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00700","codigoTransacao"               	,"CD_TRANS"     ,"aDados",.F.,"00700",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00700","tipoCliente"                   ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00700","codigoUnimedPrestadora"        	,"CD_UNI_ORI"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00700","codigoUnimedOrigemBeneficiario"	,"CD_UNI_DES"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Comunicacao Decurso Prazo
		AAdd(aStrucPtu,{"00700","comunicacaoDecursoPrazo"        	,""            ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00700","numeroTransacaoPrestadora"      	,"NR_IDENT_E"  ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00700","numeroVersaoPTU"                	,"NR_VERSAO"   ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})

	Case cCodTra == "00806" // Ordem de Serviço

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00806","ordemServicoWS"})
		AAdd(aStrucPtu,{"00806","cabecalhoTransacao"            		,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00806","codigoTransacao"               		,"CD_TRANS"     ,"aDados",.F.,"00806",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00806","tipoCliente"                   	,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00806","codigoUnimedPrestadora"        		,"CD_UNI_BEN"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00806","codigoUnimedOrigemBeneficiario"		,"CD_UNI_EXE"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad())),2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Ordem Servico
		AAdd(aStrucPtu,{"00806","ordemServico"             				,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})

		If lPTUOn90
			AAdd(aStrucPtu,{"00806","identificacaoBeneficiario"			,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
			AAdd(aStrucPtu,{"00806","codigoUnimed"             			,"CD_UNI"       ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
			AAdd(aStrucPtu,{"00806","codigoIdentificacao"      			,"ID_BENEF"     ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,13,"N"})
			AAdd(aStrucPtu,{"00806","nomeBeneficiario"         			,"NM_BENEF"     ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,25,"N"})
			AAdd(aStrucPtu,{"00806","nomeSocial"           				,"NM_NOMSOC"    ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,70,"N"})

			AAdd(aStrucPtu,{"00806","numeroTransacaoOrigemBeneficiario"	,"NR_IDENT_B"   ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,10,"N"})
			AAdd(aStrucPtu,{"00806","numeroTransacaoUnimedSolicitante"	,"NR_IDENT_S"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
			AAdd(aStrucPtu,{"00806","codigoUnimedSolicitante"  			,"CD_UNI_SOL"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

			AAdd(aStrucPtu,{"00806","prestadorSolicitante"     			,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
			AAdd(aStrucPtu,{"00806","codigoUnimed"             			,"CD_UNI_REQ"   ,"aDados",.F.,"",3,"N","",.F.,"","",.F.,4,"N"})
			AAdd(aStrucPtu,{"00806","codigoPrestador"          			,"CD_PRE_REQ"   ,"aDados",.F.,"",3,"N","",.F.,"","",.F.,8,"N"})
			AAdd(aStrucPtu,{"00806","nomePrestadorSolic"       			,"NM_PRO_SOLIC" ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,70,"N"})
			AAdd(aStrucPtu,{"00806","siglaConselho"            			,"SG_CONSEL"    ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,12,"N"})
			AAdd(aStrucPtu,{"00806","numeroConselho"           			,"NM_CONSEL"    ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,15,"N"})
			AAdd(aStrucPtu,{"00806","unidadeFederativa"        			,"UN_FEDERA"    ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,2,"N"})
			AAdd(aStrucPtu,{"00806","numeroCBO"                			,"CD_CBO_SOL"   ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,6,"N"})

			AAdd(aStrucPtu,{"00806","prestadorExecutante"      			,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
			AAdd(aStrucPtu,{"00806","codigoUnimed"             			,"CD_UNI_PRE"   ,"aDados",.F.,"",3,"N","",.F.,"","",.F.,4,"N"})
			AAdd(aStrucPtu,{"00806","codigoPrestador"          			,"CD_PREST"     ,"aDados",.F.,"",3,"N","",.F.,"","",.F.,8,"N"})
			AAdd(aStrucPtu,{"00806","numeroCBO"                			,"CD_CBO_EXEC"  ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,6,"N"})

			AAdd(aStrucPtu,{"00806","codigoCID"                			,"CD_CID"       ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,4,"N"})
			AAdd(aStrucPtu,{"00806","idUrgenciaEmergencia"     			,"ID_URG_EME"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00806","dataSugeridaInternacao"   			,"DT_PROV_AD"   ,"aDados",.F.,"",2,"D","",.F.,"","",.F.,8,"N"})
			AAdd(aStrucPtu,{"00806","dataValidadeAutorizacao"  			,"DT_VALIDAD"   ,"aDados",.F.,"",2,"D","",.F.,"","",.T.,8,"N"})
			AAdd(aStrucPtu,{"00806","idRN"                     			,"ID_RN"        ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00806","tpInternacao"             			,"TP_INTERNA"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,1,"N"})
			If lPTUOn91
				AAdd(aStrucPtu,{"00806","idAcidente"               		,"ID_ACIDENT"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,1,"N"})
			EndIf
			AAdd(aStrucPtu,{"00806","tpSexo"                   			,"TP_SEXO"      ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,1,"N"})
			AAdd(aStrucPtu,{"00806","nrIdade"                  			,"NR_IDADE"     ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,3,"N"})
			AAdd(aStrucPtu,{"00806","numeroVersaoPTU"          			,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})
			AAdd(aStrucPtu,{"00806","observacao"               			,"DS_OBSERVA"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,999,"N"})
			AAdd(aStrucPtu,{"00806","indicacaoClinica"         			,"DS_IND_CLI"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,999,"N"})
			AAdd(aStrucPtu,{"00806","idLiminar"                			,"ID_LIMINAR"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00806","cdIBGE"                   			,"CD_IBGE"      ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,7,"N"})
			AAdd(aStrucPtu,{"00806","nrVerTiss"                			,"NR_VER_TIS"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,7,"N"})
			AAdd(aStrucPtu,{"00806","tipoGuia"                 			,"TP_GUIA"      ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00806","idCoberturaEspecial"     			,"ID_COBESPE"   ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,1,"N"})
			AAdd(aStrucPtu,{"00806","saudeOcupacional"     	  			,"ID_SAUDEOCUP" ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,1,"N"})
		Else
			AAdd(aStrucPtu,{"00806","numeroTransacaoOrigemBeneficiario"	,"NR_IDENT_B"   ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,10,"N"})

			AAdd(aStrucPtu,{"00806","identificacaoBeneficiario"			,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
			AAdd(aStrucPtu,{"00806","codigoUnimed"             			,"CD_UNI"       ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
			AAdd(aStrucPtu,{"00806","codigoIdentificacao"      			,"ID_BENEF"     ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,13,"N"})
			AAdd(aStrucPtu,{"00806","numeroViaCartao"          			,"NR_VIA_CAR"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
			AAdd(aStrucPtu,{"00806","nomeBeneficiario"         			,"NM_BENEF"     ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,25,"N"})
			AAdd(aStrucPtu,{"00806","codigoCID"                			,"CD_CID"       ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,4,"N"})

			AAdd(aStrucPtu,{"00806","prestadorRequisitante"    			,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
			AAdd(aStrucPtu,{"00806","codigoUnimed"             			,"CD_UNI_REQ"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
			AAdd(aStrucPtu,{"00806","codigoPrestador"          			,"CD_PRE_REQ"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,8,"N"})

			AAdd(aStrucPtu,{"00806","prestadorExecutante"      			,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
			AAdd(aStrucPtu,{"00806","codigoUnimed"             			,"CD_UNI_PRE"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
			AAdd(aStrucPtu,{"00806","codigoPrestador"          			,"CD_PREST"     ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,8,"N"})

			AAdd(aStrucPtu,{"00806","codigoEspecialidadeMedica"			,"CD_ESPEC"     ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,2,"N"})
			AAdd(aStrucPtu,{"00806","idUrgenciaEmergencia"     			,"ID_URG_EME"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00806","dataSugeridaInternacao"   			,"DT_PROV_AD"   ,"aDados",.F.,"",2,"D","",.F.,"","",.F.,8,"N"})
			AAdd(aStrucPtu,{"00806","dataValidadeAutorizacao"  			,"DT_VALIDAD"   ,"aDados",.F.,"",2,"D","",.F.,"","",.T.,8,"N"})
			AAdd(aStrucPtu,{"00806","numeroTransacaoUnimedSolicitante"	,"NR_IDENT_S"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
			AAdd(aStrucPtu,{"00806","codigoUnimedSolicitante"  			,"CD_UNI_SOL"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})
			AAdd(aStrucPtu,{"00806","idRN"                     			,"ID_RN"        ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00806","idAnexo"                  			,"ID_ANEXO"     ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00806","tpSexo"                   			,"TP_SEXO"      ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,1,"N"})
			AAdd(aStrucPtu,{"00806","nrIdade"                  			,"NR_IDADE"     ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,3,"N"})

			AAdd(aStrucPtu,{"00806","conselhoProfissional"         		,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
			AAdd(aStrucPtu,{"00806","siglaConselhoRequisitante"    		,"SG_CONS_PR"   ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,12,"N"})
			AAdd(aStrucPtu,{"00806","numeroConselhoRequisitante"   		,"NR_CONS_PR"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,15,"N"})
			AAdd(aStrucPtu,{"00806","unidadeFederativaRequisitante"		,"UF_CONS_PR"   ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,2,"N"})
			AAdd(aStrucPtu,{"00806","nomePrestadorRequisitante"    		,"NM_PREST"     ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,40,"N"})

			AAdd(aStrucPtu,{"00806","tpInternacao"             			,"TP_INTERNA"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,1,"N"})
			AAdd(aStrucPtu,{"00806","idAcidente"               			,"ID_ACIDENT"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00806","numeroVersaoPTU"          			,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})
			AAdd(aStrucPtu,{"00806","nrVerTiss"                			,"NR_VER_TIS"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,7,"N"})
			AAdd(aStrucPtu,{"00806","tipoGuia"                 			,"TP_GUIA"      ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00806","observacao"               			,"DS_OBSERVA"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,999,"N"})
			AAdd(aStrucPtu,{"00806","indicacaoClinica"         			,"DS_IND_CLI"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,999,"N"})
			AAdd(aStrucPtu,{"00806","idLiminar"                			,"ID_LIMINAR"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
			AAdd(aStrucPtu,{"00806","cdIBGE"                   			,"CD_IBGE"      ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,7,"N"})
		EndIf

		//Bloco de Eventos - Bloco Servico Autorizado
		AAdd(aStrucPtu,{"00806","blocoServicoAutorizado"      			,""             ,"aItens",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00806","servicoAutorizado"           			,""             ,"aItens",.T.,"",3,"C","",.T.,"{||(nItem+1 <= len(aItens))}","nItem",.T.,0,"N"})
		AAdd(aStrucPtu,{"00806","servico"                     			,""             ,"aItens",.T.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00806","sqitem"                      			,"SQ_ITEM"      ,"aItens",.F.,"",5,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00806","tipoTabela"                  			,"TP_TABELA"    ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00806","codigoServico"               			,"CD_SERVICO"   ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00806","quantidadeServico"           			,"QT_AUTORIZ"   ,"aItens",.F.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00806","descricaoServico"            			,"DS_SERVICO"   ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,80,"N"})
		AAdd(aStrucPtu,{"00806","valor"                       			,"VL_SERVICO"   ,"aItens",.F.,"",4,"N2","",.F.,"","",.F.,0,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00806","valorUnitarioServico"        		,"VL_UNI_SER"   ,"aItens",.F.,"",4,"N2","",.F.,"","",.F.,0,"N"})
		EndIf

		AAdd(aStrucPtu,{"00806","codigoAnvisa"                			,"CD_ANVISA"    ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,15,"N"})
		AAdd(aStrucPtu,{"00806","referenciaMaterialFabricante"			,"CD_REF_FAB"   ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,30,"N"})
		AAdd(aStrucPtu,{"00806","tpAnexo"                     			,"TP_ANEXO"     ,"aItens",.F.,"",4,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00806","dataProv"                    			,"DT_PROVAVE"   ,"aItens",.F.,"",4,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00806","totalDosagem"                			,"TOT_DOSAGE"   ,"aItens",.F.,"",4,"N2","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00806","unMedicamento"               			,"UNI_MEDIDA"   ,"aItens",.F.,"",4,"N","",.F.,"","",.F.,3,"N"})
		AAdd(aStrucPtu,{"00806","cdViaAdmin"                  			,"CD_VIA_ADM"   ,"aItens",.F.,"",4,"C","",.F.,"","",.F.,2,"N"})
		AAdd(aStrucPtu,{"00806","qtFrequencia"                			,"QT_FREQUEN"   ,"aItens",.F.,"",4,"N","",.F.,"","",.F.,2,"N"})
		AAdd(aStrucPtu,{"00806","tpOrdem"                     			,"TP_ORDEM"     ,"aItens",.F.,"",4,"N","",.F.,"","",.F.,1,"N"})

		// Dados Anexo OPME
		AAdd(aStrucPtu,{"00806","dadosAnexoOPME"             			,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00806","dsOPME"                     			,"DS_OPME"      ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00806","justificativaTecnica"       			,"DS_JUST_TE"   ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,999,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00806","dsMatSolic"                 		,"DS_MAT_SOL"   ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		Else
			AAdd(aStrucPtu,{"00806","especMatSolic"              		,"DS_MAT_SOL"   ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		EndIf

		AAdd(aStrucPtu,{"00806","ProfissionalSolicitanteOPME"			,""             ,"aDados",.T.,"",3,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00806","nomeProfissional"           			,"NM_SOLIC_O","aDados",.F.,"",4,"C","",.F.,"","",.T.,70,"N"})
		AAdd(aStrucPtu,{"00806","numeroTelefone"             			,"NR_TEL_OPM"   ,"aDados",.F.,"",4,"N","",.F.,"","",.T.,11,"N"})
		AAdd(aStrucPtu,{"00806","enderecoEmail"              			,"END_EM_OPM"   ,"aDados",.F.,"",4,"C","",.F.,"","",.F.,60,"N"})

		// Dados Anexo Quimio
		AAdd(aStrucPtu,{"00806","dadosAnexoQuimio"             			,""             ,"aQuimio",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00806","descricaoDiagCitHist"         			,"DS_DIAG_QU"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00806","informacoesRelevantes"        			,"DS_INF_QUI"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00806","planoTerapeutico"             			,"DS_PL_TERA"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,999,"N"})
		AAdd(aStrucPtu,{"00806","dsQuimio"                     			,"DS_QUIMIO"    ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00806","alturaBenef"                  			,"NR_ALTBENE"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,6,"N"})
		AAdd(aStrucPtu,{"00806","pesoBenef"                    			,"NR_PESOBEN"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,6,"N"})
		AAdd(aStrucPtu,{"00806","supCorp"                      			,"NR_SUPCORP"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,5,"N"})
		AAdd(aStrucPtu,{"00806","dataDiag"                     			,"DT_DIAG"      ,"aQuimio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00806","cdCID"                        			,"CD_CID1"      ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00806","cdCID"                        			,"CD_CID2"      ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00806","cdCID"                        			,"CD_CID3"      ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00806","cdCID"                        			,"CD_CID4"      ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00806","estadTumor"                   			,"CD_ESTADIA"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00806","tpQuimio"                     			,"TP_QUIMIO"    ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00806","cdFinalidade"                 			,"CD_FINALID"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00806","cdEcog"                       			,"CD_ECOG"      ,"aQuimio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00806","clTumor"                      			,"CL_TUMOR"     ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00806","clNodulo"                     			,"CL_NODULO"    ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00806","clMetastase"                  			,"CL_METASTA"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00806","numeroCiclos"                 			,"NR_CICLOS"    ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00806","cicloAtual"                   			,"NR_CL_ATUA"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00806","qtDiasCicloAtual"             			,"QT_DIAS_CI"   ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00806","intervaloCiclos"              			,"NR_INTERV"    ,"aQuimio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00806","dsCirurgia"                   			,"DS_CIRURGI"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
		AAdd(aStrucPtu,{"00806","dtCirurgia"                   			,"DT_CIRURGI"   ,"aQuimio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00806","dsAreaIrrad"                  			,"DS_AREA_IR"   ,"aQuimio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
		AAdd(aStrucPtu,{"00806","dtIrrad"                      			,"DT_IRRAD"     ,"aQuimio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})

		AAdd(aStrucPtu,{"00806","ProfissionalSolicitanteQuimio"			,""             ,"aQuimio",.T.,"",3,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00806","nomeProfissional"             			,"NM_SOL_QUI"   ,"aQuimio",.F.,"",4,"C","",.F.,"","",.T.,70,"N"})
		AAdd(aStrucPtu,{"00806","numeroTelefone"               			,"NR_TEL_QUI"   ,"aQuimio",.F.,"",4,"N","",.F.,"","",.T.,11,"N"})
		AAdd(aStrucPtu,{"00806","enderecoEmail"                			,"END_EM_QUI"   ,"aQuimio",.F.,"",4,"C","",.F.,"","",.F.,60,"N"})

		// Dados Anexo Radio
		AAdd(aStrucPtu,{"00806","dadosAnexoRadio "             			,""             ,"aRadio",.T.,"",2,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00806","descricaoDiagCitHist"         			,"DS_DIAG_RA"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00806","informacoesRelevantes"        			,"DS_INF_RAD"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00806","dsRadio"                      			,"DS_RADIO"     ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})
		AAdd(aStrucPtu,{"00806","dataDiag"                     			,"DT_DIAG"      ,"aRadio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00806","cdCID"                        			,"CD_CID1"      ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00806","cdCID"                        			,"CD_CID2"      ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00806","cdCID"                        			,"CD_CID3"      ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00806","cdCID"                        			,"CD_CID4"      ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00806","estadTumor"                   			,"CD_ESTADIA"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00806","cdFinalidade"                 			,"CD_FINALID"   ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00806","cdEcog"                       			,"CD_ECOG"      ,"aRadio",.F.,"",3,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00806","cdDiagImg"                    			,"CD_DIAG_IM"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,1,"N"})
		AAdd(aStrucPtu,{"00806","qtCampos"                     			,"QT_CAMPOS"    ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00806","qtDoseDia"                    			,"QT_DOSE_DI"   ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00806","qtDoseTotal"                  			,"QT_DOSE_TO"   ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00806","qtDiasTratamento"             			,"QT_DIAS_TR"   ,"aRadio",.F.,"",3,"N","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00806","dtPrevAdmin"                  			,"DT_PREV_AD"   ,"aRadio",.F.,"",3,"D","",.F.,"","",.T.,8,"N"})
		AAdd(aStrucPtu,{"00806","dsCirurgia"                   			,"DS_CIRURGI"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
		AAdd(aStrucPtu,{"00806","dtCirurgia"                   			,"DT_CIRURGI"   ,"aRadio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00806","dsQuimio"                     			,"DS_QUIMIOT"   ,"aRadio",.F.,"",3,"C","",.F.,"","",.F.,40,"N"})
		AAdd(aStrucPtu,{"00806","dtQuimio"                     			,"DT_QUIMIOT"   ,"aRadio",.F.,"",3,"D","",.F.,"","",.F.,8,"N"})

		AAdd(aStrucPtu,{"00806","ProfissionalSolicitanteRadio" 			,""             ,"aRadio",.T.,"",3,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00806","nomeProfissional"             			,"NM_SOL_RAD"   ,"aRadio",.F.,"",4,"C","",.F.,"","",.T.,70,"N"})
		AAdd(aStrucPtu,{"00806","numeroTelefone"               			,"NR_TEL_RAD"   ,"aRadio",.F.,"",4,"N","",.F.,"","",.T.,11,"N"})
		AAdd(aStrucPtu,{"00806","enderecoEmail"                			,"END_EM_RAD"   ,"aRadio",.F.,"",4,"C","",.F.,"","",.F.,60,"N"})

	Case cCodTra == "00807" // Resposta de Ordem de Serviço

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00807","respostaOrdemServicoWS"})
		AAdd(aStrucPtu,{"00807","cabecalhoTransacao"              ,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00807","codigoTransacao"                 ,"CD_TRANS"     ,"aDados",.F.,"00807",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00807","tipoCliente"                 ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00807","codigoUnimedPrestadora"          ,"CD_UNI_BEN"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00807","codigoUnimedOrigemBeneficiario"  ,"CD_UNI_EXE"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad())),2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Resposta Ordem Servico
		AAdd(aStrucPtu,{"00807","respostaOrdemServico"            ,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00807","numeroTransacaoUnimedSolicitante","NR_IDENT_B"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00807","codigoUnimedSolicitante"         ,"CD_UNI_SOL"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00807","numeroTransacaoPrestadora"       ,"NR_IDENT_E"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})

		AAdd(aStrucPtu,{"00807","identificacaoBeneficiario"       ,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00807","codigoUnimed"                    ,"CD_UNI"       ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00807","codigoIdentificacao"             ,"ID_BENEF"     ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,13,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00807","nomePrestador"               ,"NM_PRESTAD"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,25,"N"})
		EndIf

		AAdd(aStrucPtu,{"00807","numeroVersaoPTU"                 ,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00807","observacao"                      ,"DS_OBSERVA"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,999,"N"})

		//Bloco de Eventos - Bloco Servico Aceito
		AAdd(aStrucPtu,{"00807","blocoServicoAceito"          	  ,""             ,"aItens",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00807","servicoAceito"               	  ,""             ,"aItens",.T.,"",3,"C","",.T.,"{||(nItem+1 <= len(aItens))}","nItem",.T.,0,"N"})
		AAdd(aStrucPtu,{"00807","servico"                     	  ,""             ,"aItens",.T.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00807","sqitem"                      	  ,"SQ_ITEM"      ,"aItens",.F.,"",5,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00807","tipoTabela"                  	  ,"TP_TABELA"    ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00807","codigoServico"               	  ,"CD_SERVICO"   ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00807","quantidadeAutorizada"            ,"QT_AUTORIZ"   ,"aItens",.F.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00807","idStatus"                        ,"ID_STATUS"    ,"aItens",.F.,"",4,"N","",.F.,"","",.T.,1,"N"})

		AAdd(aStrucPtu,{"00807","mensagensErro"                   ,""             ,"aItens",.T.,"",4,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00807","codMensagemErro"                 ,"CD_MENS_E1"   ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00807","codMensagemErro"                 ,"CD_MENS_E2"   ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00807","codMensagemErro"                 ,"CD_MENS_E3"   ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00807","codMensagemErro"                 ,"CD_MENS_E4"   ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00807","codMensagemErro"                 ,"CD_MENS_E5"   ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00807","descricaoMensagemEspec"          ,"DS_MENS_ES"   ,"aItens",.F.,"",5,"C","",.F.,"","",.F.,500,"N"})


	Case cCodTra == "00804" // Autorização de Ordem de Serviço

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00804","autorizacaoOrdemServicoWS"})
		AAdd(aStrucPtu,{"00804","cabecalhoTransacao"            		,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00804","codigoTransacao"               		,"CD_TRANS"     ,"aDados",.F.,"00804",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00804","tipoCliente"                   	,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIF

		AAdd(aStrucPtu,{"00804","codigoUnimedPrestadora"        		,"CD_UNI_BEN"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00804","codigoUnimedOrigemBeneficiario"		,"CD_UNI_EXE"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Autorizacao Ordem Servico
		AAdd(aStrucPtu,{"00804","autorizacaoOrdemServico"          		,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00804","codigoUnimedSolicitante"          		,"CD_UNI_SOL"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00804","numeroTransacaoUnimedSolicitante" 		,"NR_IDENT_S"   ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00804","numeroTransacaoPrestadora"        		,"NR_IDENT_E"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00804","numeroTransacaoOrigemBeneficiario"		,"NR_IDENT_B"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00804","dataValidadeAutorizacao"          		,"DT_VALIDAD"   ,"aDados",.F.,"",2,"D","",.F.,"","",.F.,8,"N"})
		AAdd(aStrucPtu,{"00804","numeroVersaoPTU"                  		,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})
		AAdd(aStrucPtu,{"00804","mensagemLivre"                    		,"DS_MENS_LI"   ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,999,"N"})

		// Bloco de Eventos - Resposta Pedido Servico
		AAdd(aStrucPtu,{"00804","blocoServicoAutorizacaoOrdemServico"	,""      		,"aItens",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00804","respostaPedidoServico"       			,""             ,"aItens",.T.,"",3,"C","",.T.,"{||(nItem+1 <= len(aItens))}","nItem",.T.,0,"N"})
		AAdd(aStrucPtu,{"00804","servico"                     			,""             ,"aItens",.T.,"",4,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00804","sqitem"                      			,"SQ_ITEM"      ,"aItens",.F.,"",5,"N","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00804","tipoTabela"                  			,"TP_TABELA"    ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,2,"N"})
		AAdd(aStrucPtu,{"00804","codigoServico"               			,"CD_SERVICO"   ,"aItens",.F.,"",5,"C","",.F.,"","",.T.,10,"N"})
		AAdd(aStrucPtu,{"00804","descricaoServico"            			,"DS_SERVICO"   ,"aItens",.F.,"",5,"C","",.F.,"","",.F.,80,"N"})
		AAdd(aStrucPtu,{"00804","quantidadeAutorizada"        			,"QT_SERVICO"   ,"aItens",.F.,"",4,"C","",.F.,"","",.T.,0,"N"})

		AAdd(aStrucPtu,{"00804","mensagensEspecificas"        			,""             ,"aItens",.T.,"",4,"C","",.F.,"","",.F.,0,"N"})
		AAdd(aStrucPtu,{"00804","mensagem"                    			,"CD_MENS_E1"   ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00804","mensagem"                    			,"CD_MENS_E2"   ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00804","mensagem"                    			,"CD_MENS_E3"   ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00804","mensagem"                    			,"CD_MENS_E4"   ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00804","mensagem"                    			,"CD_MENS_E5"   ,"aItens",.F.,"",5,"N","Val(cConteudo) <> 0" ,.F.,"","",.F.,4,"N"})
		AAdd(aStrucPtu,{"00804","descricaoMensagemEspec"      			,"DS_MENS_ES"   ,"aItens",.F.,"",5,"C","",.F.,"","",.F.,500,"N"})
		AAdd(aStrucPtu,{"00804","indicaAutorizacaoAuditoria"  			,"ID_AUTORIZ"   ,"aItens",.F.,"",4,"N","",.F.,"","",.T.,1,"N"})

	Case cCodTra == "00310" // Erro Inesperado

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00310","erroInesperadoWS"})
		AAdd(aStrucPtu,{"00310","cabecalhoTransacao"            	,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00310","codigoTransacao"               	,"CD_TRANS"     ,"aDados",.F.,"00310",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00310","tipoCliente"                   ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIF

		AAdd(aStrucPtu,{"00310","codigoUnimedPrestadora"        	,"CD_UNI_EXE"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad()))  ,2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00310","codigoUnimedOrigemBeneficiario"	,"CD_UNI_BEN"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Erro Inesperado
		AAdd(aStrucPtu,{"00310","erroInesperado"                   	,""            ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00310","numeroTransacaoPrestadora"        	,"NR_IDENT_E"  ,"aDados",.F.,"",2,"N","",.F.,"","",.F.,10,"N"})
		AAdd(aStrucPtu,{"00310","numeroTransacaoOrigemBeneficiario"	,"NR_IDENT_B"  ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,10,"N"})
		AAdd(aStrucPtu,{"00310","codigoMensagemExcecao"            	,"CD_MENS_EX"  ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,4,"N"})

		If lPTUOn90
			AAdd(aStrucPtu,{"00310","mensagemErro"                  ,"MSG_ERRO"      ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,999,"N"})
		EndIf

	Case cCodTra == "00750" // Comunicação de internação ou alta do beneficiário

		// Cabecalho Transacao
		AAdd(aStrucPtu,{"00750","comunicacaoInternacaoAltaWS"})
		AAdd(aStrucPtu,{"00750","cabecalhoTransacao"            ,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00750","codigoTransacao"               ,"CD_TRANS"     ,"aDados",.F.,"00750",2,"C","",.F.,"","",.T.,5,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00750","tipoCliente"               ,"TP_CLIENTE"   ,"aDados",.F.,"UNIMED",2,"C","",.F.,"","",.T.,15,"N"})
		EndIf

		AAdd(aStrucPtu,{"00750","codigoUnimedPrestadora"		,"CD_UNI_ORI"   ,"aDados",.F.,cValtoChar(Val(PlsIntPad())) ,2,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00750","codigoUnimedOrigemBeneficiario","CD_UNI_DES"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,4,"N"})

		// Corpo - Comunicação de internação ou alta
		AAdd(aStrucPtu,{"00750","comunicacaoInternacaoAlta"		,""             ,"aDados",.T.,"",1,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00750","numeroTransacaoPrestadora"		,"NR_IDENT_O"   ,"aDados",.F.,"",2,"N","",.F.,"","",.T.,10,"N"})

		AAdd(aStrucPtu,{"00750","identificacaoBeneficiario"		,""             ,"aDados",.T.,"",2,"C","",.F.,"","",.T.,0,"N"})
		AAdd(aStrucPtu,{"00750","codigoUnimed"             		,"CD_UNI"       ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,4,"N"})
		AAdd(aStrucPtu,{"00750","codigoIdentificacao"      		,"ID_BENEF" ,"aDados",.F.,"",3,"C","",.F.,"","",.T.,13,"N"})
		AAdd(aStrucPtu,{"00750","identificacaoBiometrica"  		,"DS_BIOMETR"   ,"aDados",.F.,"",3,"C","",.F.,"","",.F.,999,"N"})

		If !lPTUOn90
			AAdd(aStrucPtu,{"00750","numeroViaCartao"      		,"NR_VIA_CAR"   ,"aDados",.F.,"",3,"N","",.F.,"","",.T.,2,"N"})
		EndIf

		AAdd(aStrucPtu,{"00750","idRN"                     		,"ID_RN"        ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00750","dataEvento"               		,"DT_EVENTO"    ,"aDados",.F.,"",2,"D","",.F.,"","",.T.,8,"N"})
		AAdd(aStrucPtu,{"00750","tpEvento"                 		,"TP_EVENTO"    ,"aDados",.F.,"",2,"C","",.F.,"","",.T.,1,"N"})
		AAdd(aStrucPtu,{"00750","motivoEncerramento"       		,"MT_ENCERR"    ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,2,"N"})
		AAdd(aStrucPtu,{"00750","tpInternacao"             		,"TP_INTERN"    ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,1,"N"})
		AAdd(aStrucPtu,{"00750","token"                    		,"TOKEN"        ,"aDados",.F.,"",2,"C","",.F.,"","",.F.,10,"N"})
		AAdd(aStrucPtu,{"00750","numeroVersaoPTU"          		,"NR_VERSAO"    ,"aDados",.F.,cVersao,2,"C","",.F.,"","",.T.,3,"N"})
	EndCase

Return aStrucPtu



//-------------------------------------------------------------------
/*/{Protheus.doc} PLPTUONCOM
Função padrao para realizar a comunicacao PTU Online

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PLPTUONCOM(aDad,aIte,aQuim,aRad,cNomArq,cMsgXsdErr,aAuto)

	Local cTranRet  := ""
	Local cDesTra   := ""
	Local aRet      := {}
	Local aRetAux   := {}
	Local cCodTra   := Alltrim(PlsPtuGet("CD_TRANS",aDad))
	Local cTratMsg   := ""
	Local nMsg      := 0
	Local cAuxMs    := ""
	Default aQuim   := {}
	Default aRad    := {}
	Default cMsgXsdErr := ""
	Default aAuto   := {.F.,""}

	aRetAux := GeraXML(aDad,aIte,aQuim,aRad,@cMsgXsdErr,nil,nil,"2")

	//Realiza comunicacao com o servidor da Brasil
	If aRetAux[1]
		Do Case
		Case cCodTra == "00600"
			cDesTra := "pedidoAutorizacaoWS"

		Case cCodTra == "00605"
			cDesTra := "pedidoComplementoAutorizacaoWS"

		Case cCodTra == "00302"
			cDesTra := "pedidoInsistenciaWS"

		Case cCodTra == "00404"
			cDesTra := "respostaAuditoriaWS"

		Case cCodTra == "00311"
			cDesTra := "cancelamentoWS"

		Case cCodTra == "00412"
			cDesTra := "consultaDadosBeneficiarioWS"

		Case cCodTra == "00418"
			cDesTra := "consultaDadosPrestadorWS"

		Case cCodTra == "00360"
			cDesTra := "statusTransacaoWS"

		Case cCodTra == "00700"
			cDesTra := "comunicacaoDecursoPrazoWS"

		Case cCodTra == "00806"
			cDesTra := "ordemServicoWS"

		Case cCodTra == "00804"
			cDesTra := "autorizacaoOrdemServicoWS"

		Case cCodTra == "00750"
			cDesTra := "comunicacaoInternacaoAltaWS"
		EndCase

		//Ponto de entrada utilizada para testes internos
		If ExistBlock( "PLWSDPTU" ) .And. !aAuto[1]
			aRetAux := ExecBlock( "PLWSDPTU", .F., .F., {cDesTra,aRetAux[2]} )
		Else
			aRetAux := PLPtOnWsdl(cDesTra,aRetAux[2],aAuto)
		EndIf

		If aRetAux[1]

			cCodTrans := 'CODIGOTRANSACAO>'
			nAt := At(cCodTrans,Upper(aRetAux[2]))
			cAux := Substr(aRetAux[2],nAT+len(cCodTrans))
			nAt := At("</",cAux)
			cTranRet   := Substr(cAux,1,nAt-1)

			//Definir variaveis de estrutura de repeticao para respostas
			nItem     := 1
			aDados    := {}
			aItens    := {}
			aQuimio   := {}
			aRadio    := {}

			If !Empty(cTranRet)
				aRetAux := LeSoapXml(cTranRet,aRetAux[2])
				If aRetAux[1]
					aRet := {aClone(aDados),aClone(aItens),aClone(aQuimio),aClone(aRadio)}
				Else
					cMsgXsdErr := aRetAux[2]
				EndIf
			EndIf

			PLLmpArray(aDados)
			PLLmpArray(aItens)
			PLLmpArray(aQuimio)
			PLLmpArray(aRadio)
		Else
			cMsgXsdErr := aRetAux[3]
			cTratMsg  := 'CODIGOMENSAGEMEXCECAO>'
			If LEN(aRetAux[2])>0
				nMsg := At(cTratMsg,Upper(aRetAux[2]))
				cAuxMs := Substr(aRetAux[2],nMsg+len(cTratMsg))

				nMsg   := At("<",cAuxMs)
				If nMsg > 0
					cAuxMs := Substr(cAuxMs,1,nMsg-1)
				EndIf
				cMsgXsdErr:= "ERRO LAYOUT " + Alltrim(cAuxMs) + " - " + alltrim(cMsgXsdErr)
			EndIf
		EndIf
	EndIf

Return(aRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} PLVldXmlPT
Ajusta um soap de recebimento para montagem do objeto de trabalho

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PLVldXmlPT(cErro,cAviso,cSoap,cCodTra)
	Local cSchema    := GetNewPar("MV_PTONXSD","ptu_Transacoes-V70_00.xsd")
	Local cVersion   := GetNewPar("MV_PTONVER","V70_00")
	Local cSoapAux   := ''
	Local cNameSpace := GetNewPar("MV_PTONNAM","v70")
	Local lProc00310 := GetNewPar("MV_PTON310","0") == "1"
	Local nPos       := 0
	Local nPosNamSpc := 0
	Local nX         := 0
	Local lRet       := .T.
	Local oXml
	Local lFindEnd   := .F.
	Local nPosTot    := 0
	Default cCodTra  := ""

	If cCodTra == "00310" .And. lProc00310
		nPos := At("DETAIL",Upper(cSoap))
		cSoapAux := Substr(cSoap,nPos+4,len(cSoap))
		nPos := At(">",Upper(cSoapAux))
		cSoapAux := Substr(cSoapAux,nPos+1,len(cSoapAux))

		nPos := At("DETAIL",Upper(cSoapAux))
		For nX := 1 to nPos
			If Substr(cSoapAux,nPos-nX,1) == "<"
				cSoapAux := Substr(cSoapAux,1,nPos-(nX+1))
				Exit
			EndIf
		Next
	Else
		nPos := At("BODY",Upper(cSoap))
		cSoapAux := Substr(cSoap,nPos+4,len(cSoap))
		nPos := At(">",Upper(cSoapAux))
		cSoapAux := Substr(cSoapAux,nPos+1,len(cSoapAux))

		cSoapEnd  := cSoapAux
		While !lFindEnd
			nPos := At("BODY",Upper(cSoapEnd))
			If nPos > 0
				cSoapEnd := Substr(cSoapEnd,nPos+4,len(cSoapEnd))
				nPosTot += nPos
			Else
				lFindEnd := .T.
			EndIf
		EndDo

		For nX := 1 to nPosTot
			If Substr(cSoapAux,nPosTot-nX,1) == "<"
				cSoapAux := Substr(cSoapAux,1,nPosTot-(nX+1))
				Exit
			EndIf
		Next
	EndIf

	If nPosTot > 0
		nPos:=nPosTot
	EndIf

	If nPos == 0 .Or. Empty(cSoap)
		cErro := "Erro com o pacote Soap recebido"
	EndIf


	//Cria diretorios
	If !ExistDir("\ptuonweb\")
		If MakeDir(GetSrvProfString ("ROOTPATH","")+"\ptuonweb\") == 3
			cErro := "Não foi possivel criar o diretorio \ptuonweb"
		EndIf
	EndIf

	If !ExistDir("\ptuonweb\schemas\")
		If MakeDir(GetSrvProfString ("ROOTPATH","")+"\ptuonweb\schemas\") == 3
			cErro := "Não foi possivel criar o diretorio \ptuonweb\schemas\"
		EndIf
	EndIf

	//Se houve erro fatal finaliza
	If !Empty(cErro)
		Return {.F.}
	EndIf

	//Realiza o parse
	cSoapAux := EncodeUTF8(cSoapAux)
	oXml := XmlParser( cSoapAux ,"_",@cErro,@cAviso )


	//Identificar o namespace
	nPos := At("CABECALHOTRANSACAO",Upper(cSoapAux))
	If Substr(cSoapAux,nPos-1,1) == ":"
		nPosNamSpc := nPos-2
		For nX := 1 to nPosNamSpc
			If Substr(cSoapAux,nPosNamSpc-nX,1) == "<"
				cNameSpace := Substr(cSoapAux,nPosNamSpc - nX +1,nPosNamSpc - (nPosNamSpc - nX))
				Exit
			EndIf
		Next
	EndIf

	//Monta texto para montagem do arquivo para validacao
	nPos := At(">",Upper(cSoapAux))
	cSoapPt1 := Substr(cSoapAux,1,nPos-1)
	cSoapPt2 := Substr(cSoapAux,nPos,len(cSoapAux))
	cSoapXml := cSoapPt1 + ' xmlns:'+cNameSpace+'="http://ptu.unimed.coop.br/schemas/'+cVersion+'"'+cSoapPt2


	//Faz a validação do XML gerado pelo TranXml com o XSD
	If (!XmlSVldSch(cSoapXml, "\ptuonweb\schemas\"+cSchema, @cErro,@cAviso))
		lRet := .F.
	EndIf

	aMatAux 	:= classDataArr(oXml)
	nPos 		:= ( At("_",SubStr( aMatAux[Len(aMatAux),1],2 ) )+1 )
	cNameSpace 	:= Upper( SubStr( aMatAux[Len(aMatAux),1],1,nPos ) )
	cNameEleme 	:= Upper( SubStr( aMatAux[Len(aMatAux),1],(nPos+1) ) )

	//Estrutura bruta
	oObjXml := XmlChildEx(oXml,cNameSpace+cNameEleme)

	oXml := nil

Return {lRet,oObjXml,cNameSpace}



//-------------------------------------------------------------------
/*/{Protheus.doc} PTOnPedAut
Funcao de recebimento de uma solicitacao do WebService pedidoAutorizacaoWS

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PTOnPedAut()


	//Definir aqui arrays de trabalho
	aDados    := {}
	aItens    := {}
	aQuimio   := {}
	aRadio    := {}
	//Definir variaveis de estrutura de repeticao
	nItem     := 1

	cRet := PtOnRecXML("00600","00501")

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PTOnComAut
Funcao de recebimento de uma solicitacao do WebService pedidoComplementoAutorizacaoWS

@author  Lucas Nonato
@version P11
@since   22/09/16
/*/
//-------------------------------------------------------------------
Function PTOnComAut()


	//Definir aqui arrays de trabalho
	aDados    := {}
	aItens    := {}
	aQuimio   := {}
	aRadio    := {}

	//Definir variaveis de estrutura de repeticao
	nItem     := 1

	cRet := PtOnRecXML("00605","00501")

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PTOnPedIns
Funcao de recebimento de uma solicitacao do WebService pedidoInsistenciaWS

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PTOnPedIns()


	//Definir aqui arrays de trabalho
	aDados    := {}
	aItens    := {}
	aQuimio   := {}
	aRadio    := {}

	//Definir variaveis de estrutura de repeticao
	nItem     := 1

	cRet := PtOnRecXML("00302","00309")

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PTOnResAud
Funcao de recebimento de uma solicitacao do WebService respostaAuditoriaWS

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PTOnResAud()


	//Definir aqui arrays de trabalho
	aDados    := {}
	aItens    := {}
	aQuimio   := {}
	aRadio    := {}

	//Definir variaveis de estrutura de repeticao
	nItem     := 1

	cRet := PtOnRecXML("00404","00309")

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PTOnCancel
Funcao de recebimento de uma solicitacao do WebService cancelamentoWS

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PTOnCancel()


	//Definir aqui arrays de trabalho
	aDados    := {}
	aItens    := {}
	aQuimio   := {}
	aRadio    := {}

	//Definir variaveis de estrutura de repeticao
	nItem     := 1

	cRet := PtOnRecXML("00311","00309")

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PTOnDadBen
Funcao de recebimento de uma solicitacao do WebService consultaDadosBeneficiarioWS

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PTOnDadBen()


	//Definir aqui arrays de trabalho
	aDados    := {}
	aItens    := {}
	aQuimio   := {}
	aRadio    := {}

	//Definir variaveis de estrutura de repeticao
	nItem     := 1

	cRet := PtOnRecXML("00412","00413")

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PTOnDadPre
Funcao de recebimento de uma solicitacao do WebService consultaDadosPrestadorWS

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PTOnDadPre()


	//Definir aqui arrays de trabalho
	aDados    := {}
	aItens    := {}
	aQuimio   := {}
	aRadio    := {}

	//Definir variaveis de estrutura de repeticao
	nItem     := 1

	cRet := PtOnRecXML("00418","00419")

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PTOnOrdSer
Funcao de recebimento de uma solicitacao do WebService ordemServicoWS

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PTOnOrdSer()


	//Definir aqui arrays de trabalho
	aDados    := {}
	aItens    := {}
	aQuimio   := {}
	aRadio    := {}

	//Definir variaveis de estrutura de repeticao
	nItem     := 1

	cRet := PtOnRecXML("00806","00807")


Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PTOnStaTra
Funcao de recebimento de uma solicitacao do WebService statusTransacaoWS

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PTOnStaTra()


	//Definir aqui arrays de trabalho
	aDados    := {}
	aItens    := {}
	aQuimio   := {}
	aRadio    := {}

	//Definir variaveis de estrutura de repeticao
	nItem     := 1

	cRet := PtOnRecXML("00360","00361")

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PTOnConBen
Funcao de recebimento de uma solicitacao do WebService respostaRequisicaoContagemBeneficiariosWS

@author  Lucas Nonato
@version P11
@since   22/09/16
/*/
//-------------------------------------------------------------------
Function PTOnConBen()


	//Definir aqui arrays de trabalho
	aDados    := {}
	aItens    := {}
	aQuimio   := {}
	aRadio    := {}

	//Definir variaveis de estrutura de repeticao
	nItem     := 1

	cRet := PtOnRecXML("00430","00431")

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PTOnDecPra
Funcao de recebimento de uma solicitacao do WebService comunicacaoDecursoPrazoWS

@version P11
@since   22/09/16
/*/
//-------------------------------------------------------------------
Function PTOnDecPra()


	//Definir aqui arrays de trabalho
	aDados    := {}
	aItens    := {}
	aQuimio   := {}
	aRadio    := {}

	//Definir variaveis de estrutura de repeticao
	nItem     := 1

	cRet := PtOnRecXML("00700","00309")

Return cRet



//---------------------------------------------------------
/*/{Protheus.doc} PTOnAutOS
Funcao de recebimento de uma solicitacao do WebService autorizacaoOrdemServicoWS

@version P11
@since   22/09/16
/*/
//-------------------------------------------------------------------
Function PTOnAutOS()


	//Definir aqui arrays de trabalho
	aDados    := {}
	aItens    := {}
	aQuimio   := {}
	aRadio    := {}

	//Definir variaveis de estrutura de repeticao
	nItem     := 1

	cRet := PtOnRecXML("00804","00309")

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PTOnComInt
Funcao de recebimento de uma solicitacao do WebService comunicacaoInternacaoAltaWS

@author  PLS TEAM
@version P11
@since   28/06/16
/*/
//-------------------------------------------------------------------
Function PTOnComInt()


	//Definir aqui arrays de trabalho
	aDados    := {}
	aItens    := {}
	aQuimio   := {}
	aRadio    := {}

	//Definir variaveis de estrutura de repeticao
	nItem     := 1

	cRet := PtOnRecXML("00750","00309")

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLRetTagWB
Funcao para retornar um elemento de um Objeto baseado em um XML

Parametros:
	cNameSpace -> Namespace padrao da estrutura
	cPai       -> Tag da estrutura principal
	cTree      -> Estrutura de tags a partir da pai que se deseja obeter a informacao

@author  PLS TEAM
@version P11
@since   21/07/16
/*/
//-------------------------------------------------------------------
Function PLRetTagWB(oObjXml,cNameSpace,cTree,cTpDado,nCompZero)
	Local cString := ""
	Local xRet    := ""
	Local nX      := 0
	Local aAux    := {}

	Default cNameSpace := ""
	Default cTpDado    := "C"
	Default nCompZero  := 0

	aAux := StrTokArr( cTree,"\")
	cString := "oObjXml:" //+cNameSpace+cPai+":"
	For nX := 1 to len(aAux)
		cString += cNameSpace+aAux[nX]+":"
	Next

	If Type(Substr(cString,1,len(cString)-1)) == "O"
		xRet := &(Upper(cString+"TEXT"))

		If cTpDado == "D"
			xRet := Replace(xRet,"-","")
		EndIf
		//Casos onde pode repetir a tag, mas foi enviado somente uma (codigos de glosa por exemplo)
	ElseIf Substr(cString,len(cString)-3,4) == "[1]:"
		cString := Substr(cString,1,len(cString)-4)+":"
		If Type(Substr(cString,1,len(cString)-1)) == "O"
			xRet := &(Upper(cString+"TEXT"))

			If cTpDado == "D"
				xRet := Stod(Replace(xRet,"-",""))
			EndIf
		EndIf
	EndIf

	If nCompZero > 0
		xRet := Strzero(Val(xRet),nCompZero)
	EndIf

Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PtOnRecXML
Processa um arquivo XML e monta os arrays de trabalho

Parametros:
	cCodTra -> Codigo da transacao que sera processada

@author  PLS TEAM
@version P11
@since   21/07/16
/*/
//-------------------------------------------------------------------
Function PtOnRecXML(cCodTraEnv,cCodTraRes,lAuto,cSoapAuto)
	Local cEnv := GetEnvServer()
	Local cEmp := AllTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
	Local cFil := AllTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
	Local cMsgXsdErr := ""
	Local cSoap      := ""
	Local aRetDad    := {}
	Local cXml       := ""
	Local lEnvOk     := .F.
	Default lAuto      := .F.
	Default cSoapAuto  := ""

	//Defino os arrays de trabalho para teste automatizado
	if lAuto
		aDados    := {}
		aItens    := {}
		aQuimio   := {}
		aRadio    := {}
		nItem     := 1
	endIf

	//Variaveis para armazenar dados do envio
	If (!Empty(cEmp) .And. !Empty(cFil)) .Or. lAuto
		if !lAuto
			RpcSetEnv( cEmp,cFil,,,"PLS",,)
		endIf
		lEnvOk := .T.

		if !lAuto
			cXml := HttpOtherContent()
		else
			cXml := cSoapAuto
		endIf

		If Alltrim(GetNewPar("MV_PTUVEON","35")) >= "70" .And. !lAuto
			HttpCtType( "text/html; charset=iso-8859-1") //Indica o Enconding
		Endif

		If GetNewPar("MV_PT60LOG","") == "1"
			PlsPtuLog("-----------------------------------------------")
			PlsPtuLog("Recebendo transacao: " + cCodTraEnv)
			PlsPtuLog(Substr(Dtos(dDataBase),7,2)+"/"+Substr(Dtos(dDataBase),5,2)+"/"+Substr(Dtos(dDataBase),1,4) + " - " + Time())
			PlsPtuLog("-----------------------------------------------")
			PlsPtuLog("Soap Recebido:")
			PlsPtuLog(cXml)
		EndIf

		aRetDad := LeSoapXml(cCodTraEnv,cXml)

		If aRetDad[1]

			//Processo solicitacao PTU
			If ExistBlock("PLSTRTPTU")
				ExecBlock("PLSTRTPTU",.F.,.F.,{lAuto})

				If Alltrim(PlsPtuGet("CD_TRANS",aDados)) == "00310"
					cCodTraRes := "00310"
				EndIf
				aRetDad := GeraXml(aDados,aItens,nil,nil,@cMsgXsdErr,cCodTraRes,.F.,"1")
			EndIf

			//Monta arquivo de resposta
			If !Empty(cMsgXsdErr)
				cSoap := aRetDad[2]
				PlsPtuLog("*************************************************************************")
				PlsPtuLog("FORAM ENCONTRADOS PROBLEMAS NA GERAÇÃO DO ARQUIVO DE RESPOSTA PTU ONLINE")
				PlsPtuLog("TRANSACAO: " + cCodTraEnv)
				PlsPtuLog("*************************************************************************")
				PlsPtuLog(cMsgXsdErr)
				PlsPtuLog("")
			Else
				cSoap := aRetDad[2]
			EndIf
		Else
			cSoap := aRetDad[2]
		EndIf
	Else
		cSoap := soapErro("A ENVIRONMENT ["+cEnv+" ] não tem declarada as variaveis cEmp e cFil.")
	EndIf

	PLLmpArray(aDados)
	PLLmpArray(aItens)
	PLLmpArray(aQuimio)
	PLLmpArray(aRadio)

	If GetNewPar("MV_PT60LOG","") == "1"
		PlsPtuLog("-----------------------------------------------")
		PlsPtuLog(Substr(Dtos(dDataBase),7,2)+"/"+Substr(Dtos(dDataBase),5,2)+"/"+Substr(Dtos(dDataBase),1,4) + " - " + Time())
		PlsPtuLog("-----------------------------------------------")
		PlsPtuLog("Soap Retorno:")
		PlsPtuLog(cSoap)
	EndIf

	if !lAuto
		DelClassIntF()
	endIf

	If lEnvOk .And. !lAuto
		RpcClearEnv()
	EndIf

Return cSoap


//-------------------------------------------------------------------
/*/{Protheus.doc} GeraXml
Funcao generica para criar estrutura XML

@author  PLS TEAM
@version P11
@since   21/07/16
/*/
//-------------------------------------------------------------------
Static Function GeraXml(aDados,aItens,aQuimio,aRadio,cMsgXsdErr,cCodTra,lEnvSoap,cTipoProc)

	Local cSchema   := GetNewPar("MV_PTONXSD","ptu_Transacoes-V60_00.xsd")
	Local cVerPTU   := GetNewPar("MV_PTUVEON","35")
	Local cVersion  := GetNewPar("MV_PTONVER","V60_00")
	Local cXml      := ""
	Local cTag      := ""
	Local cHash     := ""
	Local cErro     := ""
	Local cAviso    := ""
	Local cSoap     := ""
	Local cTagRepeat:= ""
	Local cErroLay  := ""
	Local cNameSpace:= GetNewPar("MV_PTONNAM","v60")
	Local lOkTag    := .T.
	Local lOkLay    := .T.
	Local lRet      := .F.
	Local nNivSkip  := 0
	Local nX        := 0
	Local nDec		:= 1
	Local aTagAux   := {}
	Local aStrucPtu := {}
	Local aLayPTU   := {}
	Local lMntLay   := .F.
	Local cMask		:= ""
	Local aRetornoPE := {}
	Default aQuimio := {}
	Default aRadio  := {}
	Default cMsgXsdErr := ""
	Default lEnvSoap   := .T.
	Default cTipoProc := ""

	If ExistBlock("PLSTRTLAY")
		aRetornoPE := ExecBlock("PLSTRTLAY",.F.,.F.,{aDados, aItens, cTipoProc})

		If Len(aRetornoPE) >= 2
			aDados := aclone(aRetornoPE[1])
			aItens := aclone(aRetornoPE[2])
		EndIf
	EndIf

	//Joga para o aLayPtu a estrutura que sera utilizada
	If Empty(cCodTra)
		cCodTra := Alltrim(PlsPtuGet("CD_TRANS",aDados))
	EndIf

	aStrucPtu := PtuOnLayWB(cCodTra)

	For nX := 1 to len(aStrucPtu)
		lOkLay := .T.
		Aadd(aLayPtu,aStrucPtu[nX])
	Next

	If lOkLay
		//Sempre que criar uma tag de repeticao, indicar a variavel de controle aqui
		nItem := 1

		For nX := 2 to len(aLayPTU)

			//Verifica se ha tags abertas e fecha
			While len(aTagAux) > 0 .And. aLayPTU[nX][7] <= aTagAux[len(aTagAux)][2]

				cXml += "</"+cNameSpace+":"+aTagAux[len(aTagAux)][1]+">"+Chr(10)

				If aTagAux[len(aTagAux)][3] > 0 .And. Eval(&(aTagAux[len(aTagAux)][4]) )
					//nItem ++
					&(aTagAux[len(aTagAux)][6]) := &(aTagAux[len(aTagAux)][6]) + 1
					nX := aTagAux[len(aTagAux)][3]

					If len(aTagAux) > 1
						aDel(aTagAux,len(aTagAux))
						aSize(aTagAux,len(aTagAux)-1)
					Else
						aTagAux := {}
					Endif

					Exit
				EndIf

				If len(aTagAux) > 1
					aDel(aTagAux,len(aTagAux))
					aSize(aTagAux,len(aTagAux)-1)
				Else
					aTagAux := {}
				Endif

			EndDo

			//Indico o array de trabalho
			If UPPER(aLayPTU[nX][4]) == "ADADOS"
				aArrayTrab := aDados
			EndIf

			If UPPER(aLayPTU[nX][4]) == "AQUIMIO"
				aArrayTrab := aQuimio
			EndIf

			If UPPER(aLayPTU[nX][4]) == "ARADIO"
				aArrayTrab := aRadio
			EndIf

			If UPPER(aLayPTU[nX][4]) == "AITENS" .And. len(aItens) > 0
				aArrayTrab := aItens[nItem]
			EndIf

			//Ajusta nivel de skip de tag
			If aLayPtu[nX][7] < nNivSkip
				nNivSkip := 0
			EndIf

			//Se linha de abertura de tag
			If aLayPTU[nX][5] .And. aLayPtu[nX][7] > nNivSkip
				//Vou rodar as tags do nivel superior para verificar se posso gerar a tag de abertura
				nPosLay    := nX //armazeno a posicao que estou
				nNivTagAbe := aLayPTU[nX][7]
				lExistTag  := .F.

				//se tag de abertura obrigatoria, cria automaticamente
				If aLayPTU[nX][13]
					lExistTag := .T.
				Else
					nX ++
					//Primeiro vou verificar se todas a tags obrigatorias foram informadas
					While nX <= len(aLayPtu) .And. aLayPtu[nX][7] > nNivTagAbe
						If aLayPtu[nX][13] .And. (nNivTagAbe+1) == aLayPtu[nX][7] .And. !aLayPtu[nX][5]
							nPos := Ascan(aArrayTrab,{|x|Alltrim(x[1]) == Alltrim(aLayPtu[nX][3])})
							If nPos == 0 .Or. (nPos > 0 .And. Empty(aArrayTrab[nPos][2]) )
								If (Upper(aLayPTU[nX][4]) == "AQUIMIO" .And. len(aQuimio) > 0 ) .Or. (Upper(aLayPTU[nX][4]) == "ARADIO" .And. len(aRadio) > 0 )
									cErroLay += "A tag obrigatória '"+aLayPtu[nX][2]+"' não foi informada." + Chr(10)+Chr(13)
									lOkLay := .F.
								Endif
								nNivSkip := aLayPtu[nX][7]
								Exit
							EndIf
						EndIf
						nX ++
					EndDo

					//Se nao fez o skip, verifica se tem pelo menos uma tag filha preenchida
					If nNivSkip == 0
						nX := nPosLay+1
						While nX <= len(aLayPtu) .And. aLayPtu[nX][7] > nNivTagAbe
							lOkTag := .F.
							nPos := Ascan(aArrayTrab,{|x|x[1] == aLayPtu[nX][3]})
							//Verifica se a tag tem regra
							If nPos > 0 .And. !Empty(aArrayTrab[nPos][2])
								lOkTag := .T.
								cConteudo := aArrayTrab[nPos][2]
								//Verifica se tem regra de preenchimento da tag
								If !Empty(aLayPtu[nX][9]) .And. !(&(aLayPtu[nX][9]))
									lOkTag := .F.
								EndIf
							EndIf

							If lOkTag
								lExistTag := .T.
								Exit
							EndIf
							nX ++
						EndDo
					EndIf
				EndIf
				nX := nPosLay //retorna para o registro inicial

				If lExistTag
					//Tag             //Nivel          //Indica que repete        //Regra repeticao //Var controle qtde //Var controle nome
					Aadd(aTagAux,{Alltrim(aLayPTU[nX][2]), aLayPTU[nX][7], IIF(aLayPTU[nX][10],nX,0), aLayPTU[nX][11],&(aLayPTU[nX][12]) ,aLayPTU[nX][12] })
					cXml += "<"+cNameSpace+":"+aLayPtu[nX][2]+">"+Chr(10)
				EndIf

				//Gera uma tag de dado                     								 ³

			ElseIf aLayPtu[nX][7] < nNivSkip .Or. nNivSkip == 0

				nPos := Ascan(aArrayTrab,{|x|Alltrim(x[1]) == Alltrim(aLayPtu[nX][3])})

				//Verifica tags obrigatórias
				If aLayPtu[nX][13] .And. (nPos == 0 .Or. Empty(aArrayTrab[nPos][2])) .And. Empty(aLayPtu[nX][6])
					cErroLay += "A tag obrigatória '"+aLayPtu[nX][2]+"' não foi informada." + Chr(10)+Chr(13)
					lOkLay := .F.

					//Gera tag normal
				ElseIf nPos > 0	 .And. !Empty(aArrayTrab[nPos][2])
					lOkTag := .T.

					If  aLayPtu[nX][8] == "D"
						cConteudo := Substr(Alltrim(aArrayTrab[nPos][2]),1,4)+"-"+Substr(Alltrim(aArrayTrab[nPos][2]),5,2)+"-"+Substr(Alltrim(aArrayTrab[nPos][2]),7,2)
					ElseIf aLayPtu[nX][8] == "N"
						cConteudo := cValtoChar(Val(aArrayTrab[nPos][2]))
						If cConteudo == "0" .And. !aLayPtu[nX][13] .And. aLayPtu[nX][2] <> "nrIdade"
							lOkTag := .F.
						EndIf
					ElseIf Len(aLayPtu[nX][8]) > 1
						cMask := ""
						For nDec := 1 To Val(SubStr(aLayPtu[nX][8],2,1))
							cMask += '9'
						Next
						cConteudo := AllTrim(cValtoChar(  Transform(Val(aArrayTrab[nPos][2]),"@E 999999999999," + cMask)   ))
						If cConteudo == "0" .And. !aLayPtu[nX][13]
							lOkTag := .F.
						EndIf
					Else
						cConteudo := Alltrim(aArrayTrab[nPos][2])
					EndIf

					//Verifica regra de geracao da tag
					If !Empty(aLayPtu[nX][9]) .And. !(&(aLayPtu[nX][9]))
						lOkTag := .F.
					EndIf

					// Tags que não irá remover caracteres especiais
					If !(aLayPtu[nX][2] $ "enderecoEmail/descricaoServico")
						cConteudo := RemovChar(cConteudo)
					EndIf

					If aLayPtu[nX][14] > 0
						cConteudo := Substr(cConteudo,1,IIf(aLayPtu[nX][8]=="D",aLayPtu[nX][14]+2,aLayPtu[nX][14]))//Data adiciono 2 caracteres por causa do formato YYYY-MM-DD
					EndIf

					If lOkTag
						cXml  += "<"+cNameSpace+":"+Alltrim(aLayPtu[nX][2])+">"+cConteudo+"</"+cNameSpace+":"+Alltrim(aLayPtu[nX][2])+">"+Chr(10)
						cHash += cConteudo
					EndIf

					//Gera tag com valor pre-estabelecido no layout
				ElseIf !Empty(aLayPtu[nX][6])
					If aLayPtu[nX][8] == "N"

						If aLayPtu[nX][14] > 0
							cConteudo := Substr(RemovChar(cValtoChar(Val(aLayPtu[nX][6]))),1,IIF(aLayPtu[nX][8]=="D",aLayPtu[nX][14]+2,aLayPtu[nX][14]))//Data adiciono 2 caracteres por causa do formato YYYY-MM-DD
						EndIf
						cXml  += "<"+cNameSpace+":"+Alltrim(aLayPtu[nX][2])+">"+ cConteudo + "</"+cNameSpace+":"+aLayPtu[nX][2]+">"+Chr(10)
						cHash += cConteudo
					Else
						If aLayPtu[nX][14] > 0
							cConteudo := Substr(RemovChar(aLayPtu[nX][6]),1,IIF(aLayPtu[nX][8]=="D",aLayPtu[nX][14]+2,aLayPtu[nX][14]) )//Data adiciono 2 caracteres por causa do formato YYYY-MM-DD
						EndIf
						cXml  += "<"+cNameSpace+":"+Alltrim(aLayPtu[nX][2])+">"+ cConteudo + "</"+cNameSpace+":"+aLayPtu[nX][2]+">"+Chr(10)
						cHash += cConteudo
					EndIf

					//Gera tag sem informacao no formato < tag />
				ElseIf lExistTag .And. aLayPtu[nX][15] == "S"
					cXml += "<"+aLayPtu[nX][2]+" />"
				EndIf

			EndIf

			//Fecha tags pendentes se houver e for o ultimo registro
			While len(aTagAux) > 0 .And. (nX + 1 > len(aLayPTU))
				cXml += "</"+cNameSpace+":"+aTagAux[len(aTagAux)][1]+">"+Chr(10)

				If aTagAux[len(aTagAux)][3] > 0 .And. Eval(&(aTagAux[len(aTagAux)][4]) )
					//nItem ++
					&(aTagAux[len(aTagAux)][6]) := &(aTagAux[len(aTagAux)][6]) + 1
					nX := aTagAux[len(aTagAux)][3] - 1

					If len(aTagAux) > 1
						aDel(aTagAux,len(aTagAux))
						aSize(aTagAux,len(aTagAux)-1)
					Else
						aTagAux := {}
					Endif

					Exit
				EndIf

				If len(aTagAux) > 1
					aDel(aTagAux,len(aTagAux))
					aSize(aTagAux,len(aTagAux)-1)
				Else
					aTagAux := {}
				Endif

			EndDo
		Next

		PLLmpArray(aArrayTrab)

		If lOkLay .Or. !(lEnvSoap)

			//Adiciona o hash
			cHash := Upper( MD5(cHash,2) )
			cXml  += "<"+cNameSpace+":hash>"+ cHash+ "</"+cNameSpace+":hash>"+Chr(10)

			//Finaliza arquivo
			cXml +='</'+cNameSpace+':'+aLayPTU[1][2]+">"+Chr(10)

			//Grava o arquivo para processamento
			If lEnvSoap
				cSoap := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:'+cNameSpace+'="http://ptu.unimed.coop.br/schemas/'+cVersion+'">'+Chr(10)
				cSoap += '<soapenv:Header/>'+Chr(10)
				cSoap += '<soapenv:Body>'+Chr(10)
				cSoap += '<'+cNameSpace+':'+aLayPTU[1][2]+'>'
				cSoap += cXml+Chr(10)
				cSoap += '</soapenv:Body>'+Chr(10)
				cSoap += '</soapenv:Envelope>'+Chr(10)
			ElseIf !lEnvSoap
				cSoap := '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+Chr(10)
				cSoap += '<soap:Body>'+Chr(10)
				cSoap += '<'+aLayPTU[1][2]+' xmlns="http://ptu.unimed.coop.br/schemas/'+cVersion+'">' + Chr(13)+Chr(10)
				cSoap += cXml+Chr(10)
				cSoap += '</soap:Body>'
				cSoap += '</soap:Envelope>'
				cSoap := Replace(cSoap,cNamespace+":","")
			EndIf

			//Gera arquivo fisico
			cXml := '<'+cNameSpace+':'+aLayPTU[1][2]+ ' xmlns:'+cNameSpace+'="http://ptu.unimed.coop.br/schemas/'+cVersion+'">'+Chr(10) + cXml


			//Faz a validação do XML gerado pelo TranXml com o XSD
			If (!XmlSVldSch( cXml, "\ptuonweb\schemas\"+cSchema, @cErro,@cAviso))
				cMsgXsdErr := Iif( !Empty(cErro),"Erro: " +cErro,"")
				cMsgXsdErr += Iif( !Empty(cAviso),"Aviso: "+cAviso,"")
				lRet := .F.
			Else
				//Arquivo gerado e validado com sucesso
				lRet := .T.
			EndIf
		Else
			cMsgXsdErr := "Erro Layout:" + Chr(10)+Chr(13) + cErroLay
		EndIf
	Else
		cMsgXsdErr := "Não foi encontrado o layout "+cCodTra
	Endif

	If !lRet .And. GetNewPar("MV_PT60LOG","") == "1"
		PlsPtuLog("-----------------------------------------------")
		PlsPtuLog(Substr(Dtos(dDataBase),7,2)+"/"+Substr(Dtos(dDataBase),5,2)+"/"+Substr(Dtos(dDataBase),1,4) + " - " + Time())
		PlsPtuLog("-----------------------------------------------")
		PlsPtuLog("Não foi possível gerar o Soap: "+cMsgXsdErr)
	EndIf

Return {lRet,cSoap}



//-------------------------------------------------------------------
/*/{Protheus.doc} LeSoapXml
Funcao generica para leitura do SOAP

@author  PLS TEAM
@version P11
@since   21/07/16
/*/
//-------------------------------------------------------------------
Static Function LeSoapXml(cCodTra,cSoap)
	Local lRet       := .F.
	Local nX         := 0
	Local nY         := 0
	Local nNivel     := 0
	Local nTotItens  := 0
	Local nPosItem   := 0
	Local cVerPTU    := ""
	Local cErro      := ""
	Local cAviso     := ""
	Local cRet       := ""
	Local cNameSpace := ""
	Local cStrTag    := ""
	Local cSoapRet   := ""
	Local aStrucPtu  := {}
	Local aRet       := {}
	Local aRetObj    := {}
	Local aRetVld    := {}
	Local aNiveis    := {}
	Local aLayPtu    := {}
	Local lRetObj    := .F.
	Local lOkLay     := .F.
	Local lMntLay    := .F.
	Local lRepeat    := .F.
	Local lItemUnic  := .F.

	aRetObj := PLVldXmlPT(@cErro,@cAviso,cSoap,cCodTra)
	If aRetObj[1]
		lRetObj    := aRetObj[1]
		oObjXml    := aRetObj[2]
		cNameSpace := aRetObj[3]
	Else
		cSoapRet := soapErro(cErro)
	EndIf

	//Se tudo ok, processa o arquivo
	If lRetObj
		aStrucPtu := PtuOnLayWB(cCodTra)
		cVerPTU   := GetNewPar("MV_PTUVEON","35")

		For nX := 1 to len(aStrucPtu)
			lOkLay := .T.
			Aadd(aLayPtu,aStrucPtu[nX])
		Next

	EndIf

	//Layout Ok
	If lOkLay
		lRet := .T.

		For nX := 2 to len(aLayPTU)

			//Remove o nivel se a nova tag for inferior
			While len(aNiveis) > 0 .And. aLayPTU[nX][7] <= aNiveis[len(aNiveis)][2]

				//Se houver tag de repeticao
				If aNiveis[len(aNiveis)][3] > 0 .And. aNiveis[len(aNiveis)][5] < aNiveis[len(aNiveis)][4]
					nX := aNiveis[len(aNiveis)][3]
					&(aNiveis[len(aNiveis)][6]) := &(aNiveis[len(aNiveis)][6]) + 1
				EndIf

				//Deleta nivel utilizado
				If len(aNiveis) > 1
					aDel(aNiveis,len(aNiveis))
					aSize(aNiveis,len(aNiveis)-1)
				Else
					aNiveis := {}
				Endif
			EndDo

			//Abertura de tag monta incrementa array de niveis
			If aLayPTU[nX][5]
				nTotItens := 0
				If aLayPTU[nX][10]

					cString := "oObjXml:"
					For nY := 1 to len(aNiveis)
						cString += cNameSpace+aNiveis[nY][1]+":"
					Next
					cString += cNameSpace+aLayPTU[nX][2]
					If Type(cString) <> "O" .And. Type(cString) <> "U"
						nTotItens := len( &(cString) )
					ElseIf !Empty(aLayPtu[nX][12])
						nTotItens := 1
						lItemUnic := .T.
					EndIf

				EndIf
				//Tag            //Nivel         //Posicao repeticao          //Total de itens  //Var controle qtde  //Var controle desc
				Aadd(aNiveis,{aLayPTU[nX][2], aLayPTU[nX][7], IIf(aLayPTU[nX][10],nX,0), nTotItens        ,&(aLayPTU[nX][12])  ,aLayPTU[nX][12] })

			ElseIf len(aNiveis) > 0

				//Monta estrutura dentro do arquivo
				nPosItem := 0
				cStrTag  := ""
				For nY := 1 to len(aNiveis)
					cStrTag += aNiveis[nY][1]+ IIf(aNiveis[nY][4]>0 .And. !lItemUnic,"["+cValToChar(aNiveis[nY][5])+"]","")+"\"
					If aNiveis[nY][4]> 0
						nPosItem := aNiveis[nY][5]
					EndIf
				Next
				cStrTag += aLayPTU[nX][2]

				If Substr(aLayPTU[nX][3],len(aLayPTU[nX][3]),1) $ "123456789"
					cStrTag += "["+Substr(aLayPTU[nX][3],len(aLayPTU[nX][3]),1)+"]"
				EndIf
				//Busca informacao da tag
				cRet := PLRetTagWB(oObjXml,cNameSpace,cStrTag, aLayPTU[nX][8])
				If !Empty(cRet)
					//Adiciona no array informacoes do Item
					If nPosItem > 0
						If len(&(aLayPTU[nX][4])) < nPosItem
							AaDd(&(aLayPTU[nX][4]),{})
						EndIf
						PlsPtuPut(aLayPTU[nX][3], cRet, &(aLayPTU[nX][4])[nPosItem] )
						//Adiciona no array informacoes de Cabecalho, Quimio ou Radio
					Else
						PlsPtuPut(aLayPTU[nX][3], cRet, &(aLayPTU[nX][4]) )
					EndIf
				EndIf
			EndIf

			//Verifica se ha tags abertas pendentes
			While len(aNiveis) > 0 .And. (nX + 1 > len(aLayPTU))

				//Se houver tag de repeticao
				If aNiveis[len(aNiveis)][3] > 0 .And. aNiveis[len(aNiveis)][5] < aNiveis[len(aNiveis)][4]
					nX := aNiveis[len(aNiveis)][3] - 1
					&(aNiveis[len(aNiveis)][6]) := &(aNiveis[len(aNiveis)][6]) + 1
				EndIf

				//Deleta nivel utilizado
				If len(aNiveis) > 1
					aDel(aNiveis,len(aNiveis))
					aSize(aNiveis,len(aNiveis)-1)
				Else
					aNiveis := {}
				Endif

			EndDo
		Next
	EndIf

	If lRetObj
		freeObj(oObjXml)
		oObjXml := nil
	EndIf
Return {lRet,cSoapRet}



//-------------------------------------------------------------------
/*/{Protheus.doc} soapErro
Funcao generica para leitura do SOAP

@author  PLS TEAM
@version P11
@since   21/07/16
/*/
//-------------------------------------------------------------------
Static Function soapErro(cErro)
	Local cRet := ""

	cRet += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+Chr(10)
	cRet += '<soap:Body>'+Chr(10)
	cRet += '<soap:Fault>'+Chr(10)
	cRet += '<faultcode>soap:Unimed</faultcode>'+Chr(10)
	cRet += '<faultstring>'+cErro+'</faultstring>'+Chr(10)
	cRet += '<detail>'

	cRet += cErro+Chr(10)

	cRet += '</detail>'+Chr(10)
	cRet += '</soap:Fault>'+Chr(10)
	cRet += '</soap:Body>'+Chr(10)
	cRet += '</soap:Envelope>'+Chr(10)

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLPtOnWsdl
Gera os arquivos .pem para conectar com o WebService

@author  PLS TEAM
@version P11
@since   06.09.16
/*/
//-------------------------------------------------------------------
Function PLPtOnWsdl(cAcao,cXml,aAuto)
	Local oWsdl
	Local cPFX   := PLSMUDSIS("\ptuonweb\certificados\certificado.p12")
	Local cCA    := PLSMUDSIS("\ptuonweb\certificados\ca.pem")
	Local cCert  := PLSMUDSIS("\ptuonweb\certificados\cert.pem")
	Local cKey   := PLSMUDSIS("\ptuonweb\certificados\key.pem")
	Local cPass  := GetNewPar("MV_PTONSEN","")
	Local lLog   := GetNewPar("MV_PT60LOG","") == "1"
	Local cError := ""
	Local cSoap  := ""
	Local cUrl   := ""
	Local lRet   := .T.
	Local nAt    := 0
	Local lPTUOn80  := Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80"
	Default aAuto   := {.F.,""}

	//Extrai o CA do arquivo PFX
	If !File(cCA) .And. !aAuto[1]
		If !PFXCA2PEM( cPFX, cCA, @cError, cPass )
			cError := "Não foi possível gerar o arquivo CA." + Chr(10)
			lRet := .F.
		EndIf
	EndIf

	//Extrai o Cert do arquivo PFX
	If !File(cCert) .And. !aAuto[1]
		If !PFXCert2PEM( cPFX, cCert, @cError, cPass )
			cError := "Não foi possível gerar o arquivo Cert." + Chr(10)
			lRet := .F.
		EndIf
	EndIf

	//Extrai a Key do arquivo PFX
	If !File(cKey) .And. !aAuto[1]
		If !PFXKey2PEM( cPFX, cKey, @cError, cPass )
			cError := "Não foi possível gerar o arquivo Key." + Chr(10)
			lRet := .F.
		EndIf
	EndIf

	//Seta a operacao e URL                                                    ³

	Do Case

	Case cAcao == "pedidoAutorizacaoWS"
		cOper := "PedidoAutorizacaoOperation"
		cUrl  := GetNewPar("MV_PTOPEAU","https://wsdadminpre.unimed.coop.br/wsdadmin/home/arquivos_ptu_60_pre/pedidoAutorizacao_V60_00.wsdl")

	Case cAcao == "pedidoComplementoAutorizacaoWS"
		cOper := "PedidoComplementoAutorizacaoOperation"
		cUrl  := GetNewPar("MV_PTOPECO","https://wsdadminpre.unimed.coop.br/wsdadmin/home/arquivos_ptu_60_pre/pedidoComplementoAutorizacao_V60_00.wsdl")

	Case cAcao == "pedidoInsistenciaWS"
		cOper := "PedidoInsistenciaOperation"
		cUrl  := GetNewPar("MV_PTOPEIS","https://wsdadminpre.unimed.coop.br/wsdadmin/home/arquivos_ptu_60_pre/pedidoInsistencia_V60_00.wsdl")

	Case cAcao == "respostaAuditoriaWS"
		cOper := "RespostaAuditoriaOperation"
		cUrl  := GetNewPar("MV_PTOREAU","https://wsdadminpre.unimed.coop.br/wsdadmin/home/arquivos_ptu_60_pre/respostaAuditoria_V60_00.wsdl")

	Case cAcao == "cancelamentoWS"
		cOper := "CancelamentoOperation"
		cUrl  := GetNewPar("MV_PTOCANC","https://wsdadminpre.unimed.coop.br/wsdadmin/home/arquivos_ptu_60_pre/cancelamento_V60_00.wsdl")

	Case cAcao == "consultaDadosBeneficiarioWS"
		cOper := "ConsultaDadosBeneficiarioOperation"
		cUrl  := GetNewPar("MV_PTODABE","https://wsdadminpre.unimed.coop.br/wsdadmin/home/arquivos_ptu_60_pre/consultaDadosBeneficiario_V60_00.wsdl")

	Case cAcao == "consultaDadosPrestadorWS"
		cOper := "ConsultaDadosPrestadorOperation"
		cUrl  := GetNewPar("MV_PTODAPR","https://wsdadminpre.unimed.coop.br/wsdadmin/home/arquivos_ptu_60_pre/consultaDadosPrestador_V60_00.wsdl")

	Case cAcao == "comunicacaoDecursoPrazoWS"
		cOper := "comunicacaoDecursoPrazoOperation"
		cUrl  := GetNewPar("MV_PTODEPR","https://wsdadminpre.unimed.coop.br/wsdadmin/home/arquivos_ptu_60_pre/comunicacaoDecursoPrazo_V60_00.wsdl")

	Case cAcao == "ordemServicoWS"
		cOper := "OrdemServicoOperation"
		cUrl  := GetNewPar("MV_PTOORSE","https://wsdadminpre.unimed.coop.br/wsdadmin/home/arquivos_ptu_60_pre/ordemServico_V60_00.wsdl")

	Case cAcao == "autorizacaoOrdemServicoWS"
		cOper := "autorizacaoOrdemServicoOperation"
		cUrl  := GetNewPar("MV_PTOAUOS","https://wsdadminpre.unimed.coop.br/wsdadmin/home/arquivos_ptu_60_pre/autorizacaoOrdemServico_V60_00.wsdl")

	Case cAcao == "statusTransacaoWS"
		cOper := "StatusTransacaoOperation"
		cUrl  := GetNewPar("MV_PTOSTTR","https://wsdadminpre.unimed.coop.br/wsdadmin/home/arquivos_ptu_60_pre/statusTransacao_V60_00.wsdl")

	Case cAcao == "consultaA1100WS"
		cOper := "ConsultaA1100Operation"
		cUrl  := GetNewPar("MV_PTO1100","https://wsdadminpre.unimed.coop.br/wsdadmin/home/arquivos_ptu_60_pre/statusTransacao_V60_00.wsdl")

	Case cAcao == "comunicacaoInternacaoAltaWS"
		cOper := "ComunicacaoInternacaoAltaOperation"
		cUrl  := GetNewPar("MV_PTOINTE","https://wsdadminpre.unimed.coop.br/wsdadmin/home/arquivos_ptu_60_pre/comunicacaoInternacaoAlta_V60_00.wsdl")
	EndCase

	If lRet

		oWsdl := TwsdlManager():New()
		oWsdl:cSSLCACertFile   := cCA
		oWsdl:cSSLCertFile     := cCert
		oWsdl:cSSLKeyFile      := cKey
		oWsdl:cSSLKeyPwd       := cPass
		oWsdl:bNoCheckPeerCert := .T.
		oWsdl:cEncoding        := "iso-8859-1"

		If lPTUOn80
			oWsdl:cChiperList   := "DEFAULT:!DH"
		EndIf

		//Realiza o Parse da URL com o EndPoint
		If aAuto[1] .Or. oWsdl:ParseURL( cURL )

			aOps := IIF(aAuto[1], {{"TESTE AUTO"}}, oWsdl:ListOperations() )

			If len(aOps) > 0
				cOper := aOps[1][1]

				//Seta a Operacao
				If aAuto[1] .Or. oWsdl:SetOperation(cOper)

					//Envia o SOAP
					If lLog
						PlsPtuLog("-----------------------------------------------")
						PlsPtuLog(Substr(Dtos(dDataBase),7,2)+"/"+Substr(Dtos(dDataBase),5,2)+"/"+Substr(Dtos(dDataBase),1,4) + " - " + Time())
						PlsPtuLog("-----------------------------------------------")
						PlsPtuLog("Soap Enviado:")
						PlsPtuLog(EncodeUTF8(cXml))
					EndIf

					if aAuto[1]
						cSoap := aAuto[2]
						If Len(aAuto) > 2
							aAuto[Len(aAuto)] := cXml
						EndIf
					else
						oWsdl:SendSoapMsg(EncodeUTF8(cXml))
						cSoap := (oWsdl:GetSoapResponse() )
					endIf

					If lLog
						PlsPtuLog("-----------------------------------------------")
						PlsPtuLog(Substr(Dtos(dDataBase),7,2)+"/"+Substr(Dtos(dDataBase),5,2)+"/"+Substr(Dtos(dDataBase),1,4) + " - " + Time())
						PlsPtuLog("-----------------------------------------------")
						PlsPtuLog("Soap Resposta:")
						PlsPtuLog(cSoap)
						If !aAuto[1] .And. !Empty(oWsdl:cError)
							PlsPtuLog("")
							PlsPtuLog("Erro WSDL Resposta:")
							PlsPtuLog(oWsdl:cError)
						EndIf
					EndIf

				EndIf
			Else
				lRet   := .F.
				cError := "Não foi possível realizar a comunicacao: Nao foi possivel encontrar a lista de Operacoes do WebService"
			Endif
		EndIf
	EndIf

	//Processa a resposta de erro
	If lRet .And. !Empty(oWsdl:cError)
		If (nAt := At('FAULT STRING:',Upper(oWsdl:cError)) ) > 0
			cError := "Não foi possível realizar a comunicacao: " + Substr(oWsdl:cError,nAt+len('FAULT STRING:'),len(oWsdl:cError))
		Else
			cError := "Não foi possível realizar a comunicacao: " + oWsdl:cError
		EndIf
		lRet := .F.
	EndIf

	freeObj(oWsdl)
	oWsdl := nil

Return({lRet,cSoap,cError})



//-------------------------------------------------------------------
/*/{Protheus.doc} PTUOSV60
Processa Ordem de Servico para a versao 50 ou superior
Gera uma guia e faz uma solicitacao (00600) para a
Operadora Origem do beneficiario
@author  PLS TEAM
@version P11
@since   06.09.16
/*/
//-------------------------------------------------------------------
Function PTUOSV60(cEmp,cFil,aThreads,aDados,aItens,aQuimio,aRadio,lAuto)
	Local cTipo     	:= "2"
	Local cSql      	:= ""
	Local cCodUsu   	:= ""
	LOCAL cCodMed   	:= ""
	Local cUni          := ""
	Local cUniSol       := ""
	Local cIdBenef      := ""
	Local aRet      	:= {}
	Local aIte      	:= {}
	Local aPlPtuIte 	:= {}
	LOCAL aRetRDA   	:= {}
	Local lIntern  	 	:= .F.
	LOCAL lConverProc	:= .F.
	LOCAL lAnexo        := .F.
	Local nI        	:= 0
	Local nPos      	:= 0
	LOCAL dDataAt

	LOCAL aIteAnexo   := {}
	LOCAL cOld	      := '0'
	LOCAL nPosAnexo   := 0
	LOCAL lPlPTUIte   := .F.
	LOCAL cCodPad     := ""
	LOCAL cCodPro     := ""
	LOCAL lPTUOn80
	Default lAuto     := .F.

	if !lAuto
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	endIf

	lPlPTUIte   := ExistBlock("PLPTUITE")
	cCodPad     := SubStr( GETMV("MV_PLSTBPD") ,1,2)
	lConverProc	:= !Empty(GetNewPar("MV_PTUTAB2"," "))
	cCodMed   	:= PadL(PlsPtuGet("CD_PREST",aDados),6,"0") //PlsPtuGet("CD_PREST",aDados)
	dDataAt     := dDataBase //STOD(PlsPtuGet("DT_ATENDIM",aDados))  //Data do atendimento

	cIdUsuResp := GetNewPar( "MV_PLRESRN" , "" )
	cUni       := Strzero(Val(PlsPtuGet("CD_UNI",aDados)),4)
	cUniSol    := Strzero(Val(PlsPtuGet("CD_UNI_SOL",aDados)),4)
	cIdBenef   := PadL(PlsPtuGet("ID_BENEF",aDados),13,"0")
	lPTUOn80   := Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80"

	For nI := 1 to Len(aItens)

		If !lAnexo
			lAnexo	:= PlsPtuGet("TP_ANEXO",aItens[nI]) $ "1,2,3"
		Endif
		//Monta campos
		cCodPro  := PlsPtuGet("CD_SERVICO",aItens[nI])

		//Ponto de entrada para troca de procedimento
		If lPlPTUIte
			aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{cCodPro,"RECENT","",PlsPtuGet("TP_TABELA",aItens[nI]),cCodPad,PlsIntPad(),nil})
			cCodPad := aPlPtuIte[1]
			cCodPro := aPlPtuIte[2]
		Else
			// De-para pela tabela BTU (Terminologia TISS)
			If lPTUOn80
				If PlsPtuGet("TP_TABELA",aItens[nI]) == "98" .And. Val(PlsIntPad()) <> Val(PlsPtuGet("CD_UNI_EXE",aDados))
					aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),Alltrim(GetNewPar("MV_PLPACPT")),nil,.T.,,.T.)
				Else
					aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cCodPro,nil,.T.,,.T.)
				EndIf

				If len(aRetBTU) > 0
					cCodPad := aRetBTU[1]
					cCodPro := aRetBTU[2]
				EndIf
			Else
				//Realiza De/Para AMB/CBHPM
				If lConverProc

					PLBusProTab(cCodPro,.F.,,,lConverProc,,,,cCodPad)

					If BR8->(Found())
						cCodPad := BR8->BR8_CODPAD
						cCodPro := BR8->BR8_CODPSA
					EndIf
					//Realiza De/Para BR8_CODEDI ou tabela B1M
				ElseIf GetNewPar("MV_PTDPION","0") == "1"

					PLBusProTab(cCodPro,.F.,,dDataAt,,,,,)

					If BR8->(Found())
						cCodPad := BR8->BR8_CODPAD
						cCodPro := BR8->BR8_CODPSA
					Endif
					//Realiza De/Para com a tabela de terminologias TISS BTU
				ElseIf GetNewPar("MV_PTDPION","0") == "2"

					aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aItens[nI]),cCodPro,nil,.T.)

					If len(aRetBTU) > 0
						cCodPad := aRetBTU[1]
						cCodPro := aRetBTU[2]
					EndIf
				EndIf
			EndIf
		EndIf

		nQtd := Val(Substr(PlsPtuGet("QT_AUTORIZ",aItens[nI]),1,4)+"."+Substr(PlsPtuGet("QT_AUTORIZ",aItens[nI]),5,4))

		//Verifica se e uma consulta ou sadt
		If Len(aItens) == 1 .And. PLSISCON(cCodPad,cCodPro)
			cTipo := "1"
		EndIf

		//Verifica se o registro enviado e do tipo pacote
		If PlsPtuGet("TP_TABELA",aItens[nI]) == "4" .And. !lPTUOn80

			cSql := " SELECT BLD_CODPRO FROM "+RetSqlName("BLD")+" BLD, "+RetSqlName("BLE")+" BLE WHERE "
			cSql += "     BLD_FILIAL = '"+xFilial("BLD")+"' "
			cSql += " AND BLE_FILIAL = '"+xFilial("BLE")+"' "
			cSql += " AND BLD_CODPRO = BLE_CODPRO "
			cSql += " AND BLE_CODOPC = '"+PlsPtuGet("CD_SERVICO",aItens[nI])+ "' "
			cSql += " AND BLE_PRINCI = '1' "
			cSql += " AND BLD.D_E_L_E_T_ <> '*' "
			cSql += " AND BLE.D_E_L_E_T_ <> '*' "

			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpPac",.T.,.F.)

			TmpPac->(DbGotop())
			While !TmpPac->( Eof() )
				cCodPro := Alltrim(TmpPac->BLD_CODPRO)
				TmpPac->( dbSkip() )
			EndDo
			TmpPac->( dbClosearea() )

		EndIf

		//Nova Matriz
		AaDd(aIte,{})
		AaDd(aIte[nI],{"SEQMOV",StrZero(nI,3) })
		AaDd(aIte[nI],{"CODPAD",cCodPad })
		AaDd(aIte[nI],{"CODPRO",cCodPro })
		AaDd(aIte[nI],{"QTD",nQtd })
		AaDd(aIte[nI],{"QTDAUT",nQtd })

		AaDd(aIte[nI],{"TP_ORDEM",PlsPtuGet("TP_ORDEM",aItens[nI]) })
		AaDd(aIte[nI],{"CD_ANVISA",PlsPtuGet("CD_ANVISA",aItens[nI]) })
		AaDd(aIte[nI],{"CD_REF_FAB",PlsPtuGet("CD_REF_FAB",aItens[nI]) })
		AaDd(aIte[nI],{"CD_VIA_ADM",PlsPtuGet("CD_VIA_ADM",aItens[nI]) })
		AaDd(aIte[nI],{"QT_FREQUEN",Val(PlsPtuGet("QT_FREQUEN",aItens[nI])) })
		AaDd(aIte[nI],{"TP_ANEXO",PlsPtuGet("TP_ANEXO",aItens[nI]) })
		AaDd(aIte[nI],{"UNI_MEDIDA",PlsPtuGet("UNI_MEDIDA",aItens[nI]) })
		AaDd(aIte[nI],{"TOT_DOSAGE",PlsPtuGet("TOT_DOSAGE",aItens[nI]) })

		BR8->(DbSetOrder(1))
		If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) )
			If lPTUOn80 // (Versão 8.0) - PTU Online
				// 18 = TUSS Taxas hospitalares,diárias e gases medicinais
				// 19 = TUSS Materiais
				// 20 = TUSS Medicamentos
				// 22 = TUSS Procedimentos e eventos em saúde(medicina,odonto e demais áreas de saúde)
				// 98 = Tabela Própria de Pacotes
				// 00 = Tabela Própria das Operadoras
				TpTab := PtTpTabTus(,,.T.)
			Else
				//0=Procedimento	(0=AMB)
				//1=Material	    (2=Material)
				//2=Medicamento	(3=Medicamento)
				//3=Taxas			(1=Hospitalar)
				//4=Diarias		(1=Hospitalar)
				//5=Ortese/Protese	(1=Hospitalar)
				//6=Pacote 		(1=Hospitalar)
				TpTab := Iif(BR8->BR8_TPPROC=='0' .Or. BR8->BR8_TPPROC==' ','0',Iif(BR8->BR8_TPPROC=='1','2',Iif(BR8->BR8_TPPROC=='2','3',Iif(BR8->BR8_TPPROC=='6','4','1') ) ) )
			EndIf
			//Se for diraria e uma internacao ou quando o tipo da guia for 3 - Internação
			If BR8->BR8_TPPROC == '4' .Or. PlsPtuGet("TP_GUIA",aDados) == "3"
				lIntern := .T.
				cTipo	:= "3"
			EndIf
			//se e procedimento cirurgico
			AaDd(aIte[nI],{"PROCCI",If(BR8->BR8_TIPEVE$"2,3","1","0") })

		EndIf
	Next

	//Vou buscar o Solicitante
	aRetRda := PLSRTCRDAO( cUniSol,cCodMed )
	If aRetRDA[1]
		PlsPtuPut("CDPFSO",aRetRda[6],aDados)
		PlsPtuPut("CDPFEX",aRetRda[6],aDados)
	Else
		PlsPtuLog("VERIFICAR A RDA")
		PlsPtuLog("*** NAO AUTORIZADO ***")
		PlsPtuLog(aRetRDA[2])
	EndIf

	aRetRda := PLSRTPREST( Substr(cCodMed,len(cCodMed) - len(BAU->BAU_CODIGO)+1,len(cCodMed)),,PlsIntPad() )
	If aRetRDA[1]
		PlsPtuPut("CODRDA",aRetRda[3],aDados)
		PlsPtuPut("CODLOC",aRetRda[4],aDados)
		PlsPtuPut("CODESP",aRetRda[5],aDados)
		PlsPtuPut("TPPRES",aRetRda[6],aDados)
		PlsPtuPut("TPRDA" ,aRetRda[7],aDados)
	Else
		PlsPtuLog("VERIFICAR A RDA")
		PlsPtuLog("*** NAO AUTORIZADO ***")
		PlsPtuLog(aRetRDA[2])
	EndIf

	BA1->(DbSetOrder(5)) //BA1_FILIAL + BA1_MATANT + BA1_TIPANT
	If BA1->(DbSeek(xFilial("BA1")+cUni+cIdBenef))
		PlsPtuPut("USUARIO",BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),aDados)
	Else
		PlsPtuPut("USUARIO",cUni+cIdBenef,aDados)
	Endif

	PlsPtuPut("INTERN",lIntern,aDados)
	PlsPtuPut("TIPO",cTipo,aDados)
	If cTipo <> "3"
		PlsPtuPut("ORIGEM","2",aDados)
	EndIf
	PlsPtuPut("PTUONOS",.T.,aDados)
	PlsPtuPut("NOMUSR",PlsPtuGet("NM_BENEF",aDados),aDados)
	PlsPtuPut("TRANORDSERV",StrZero( Val( PlsPtuGet("NR_IDENT_S",aDados) ),10),aDados)
	PlsPtuPut("DATPRO",dDataAt,aDados)
	PlsPtuPut("OPEMOV",PlsIntPad(),aDados)
	PlsPtuPut("OPESOLOS",Strzero(Val(PlsPtuGet("CD_UNI_SOL",aDados)),4),aDados)

	If lPTUOn80
		PlsPtuPut("TPGUIA"  ,PlsPtuGet("TP_GUIA",aDados),aDados)
		PlsPtuPut("ALIASPTU","BEA",aDados)
		PlsPtuPut("TRANSPTU","00806",aDados)
	EndIf

	If (nPos := aScan(aDados,{|x|x[1] == "PTUONLINE" })) > 0
		aDados[nPos][2] := .F.
	EndIf

	//Grava a guia e envia a transacao 00600, apos o retorno 00501 na orderm de servico/triangulacao tenho que enviar o 00804.
	//Neste momento dentro do xmov a funcao PLSXMOVONL sera acionada que por sua vez aciona a PLSANAINT que
	//faz a comunicacao enviando 00600 e trata o retorno 00501.

	aRet := PLSXAUTP(aDados,aIte)

	//Gera guia de anexo se houver
	If lAnexo .and. PlsAliasExi("B4A")

		nPosAnexo := ascan(aIte[1], {|X|, X[1] == 'TP_ANEXO'})
		aItens 	  := aSort(aIte,,, { |x, y|  x[nPosAnexo,2] < y[nPosAnexo,2] })
		cOld	  := '0'
		aIteAnexo := {}

		For nI := 1 to len(aIte)

			cTpAnexo := PlsPtuGet("TP_ANEXO",aIte[nI])
			If cTpAnexo $ "1,2,3"
				If cTpAnexo <> cOld
					cOld := cTpAnexo
					If len(aIteAnexo)>0
						PLANEPTUOT(nil,nil,nil,aDados,aIteAnexo,aQuimio,aRadio,aRet[2],dDataAt,.F.,"00806",PlsPtuGet("USUARIO",aDados))
					EndIf
					aIteAnexo := {}
				EndIf

				aadd(aIteAnexo,aIte[nI])
			Endif
		Next

		If len(aIteAnexo)>0
			PLANEPTUOT(nil,nil,nil,aDados,aIteAnexo,aQuimio,aRadio,aRet[2],dDataAt,.F.,"00806",PlsPtuGet("USUARIO",aDados))
		EndIf

	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PTUAUTOSV6
Processa triangulacao para a versao 50 Envia a confirmacao 0080

@author  PLS TEAM
@version P11
@since   06.09.16
/*/
//-------------------------------------------------------------------
Function PTUAUTOSV6(cEmp,cFil,aThreads,aDadosCab,aItens,cTraOrig,cTraPrest,cTraOriBen,cDatValAut,cOpeSol)
	Local aDados     := {}
	Local aGrvTraPTU := {}
	Local lWeb       := .T.
	Local nCont      := 0
	local nY		 := 0
	Local cMsgXsdErr := ""
	Local cCodPad    := ""
	Local dDataAt
	Local lPLPtuIte  := .F.
	Local lPTUOn80

	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,,'PLS')

	dDataAt    := stod(PlsPtuGet("DT_ATENDIM",aDados))
	cCodPad    := SubStr( GETMV("MV_PLSTBPD") ,1,2)
	lPLPtuIte  := ExistBlock("PLPTUITE")
	lPTUOn80   := Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80"

	PlsPtuLog("***********************************")
	PlsPtuLog("GERANDO TRANSACAO 00804")
	PlsPtuLog("***********************************")

	PlsPtuLog("CD_TRANS => 00804")
	PlsPtuLog("CD_UNI_EXE => "+PlsIntPad())
	PlsPtuLog("CD_UNI_BEN => "+PlsPtuGet("CD_UNI_DES",aDadosCab))
	PlsPtuLog("CD_UNI_SOL => "+cOpeSol)
	PlsPtuLog("NR_IDENT_E => "+cTraPrest)
	PlsPtuLog("NR_IDENT_B => "+cTraOriBen)
	PlsPtuLog("NR_IDENT_S => "+cTraOrig)
	PlsPtuLog("DT_VALIDAD => "+cDatValAut)
	PlsPtuLog("CUNIDOM => "+cOpeSol)
	PlsPtuLog("")

	PlsPtuPut("CD_TRANS","00804",aDados)
	PlsPtuPut("CD_UNI_EXE",PlsIntPad(),aDados)
	PlsPtuPut("CD_UNI_BEN",PlsPtuGet("CD_UNI_DES",aDadosCab),aDados)
	PlsPtuPut("CD_UNI_SOL",cOpeSol,aDados)
	PlsPtuPut("NR_IDENT_E",cTraPrest,aDados)
	PlsPtuPut("NR_IDENT_B",cTraOriBen,aDados)
	PlsPtuPut("NR_IDENT_S",cTraOrig,aDados)
	PlsPtuPut("DT_VALIDAD",cDatValAut,aDados)
	PlsPtuPut("CUNIDOM",cOpeSol,aDados)

	//procedimentos
	for nCont := 1 to len(aItens)

		cTpAut 	:= PlsPtuGet( "ID_AUTORIZ",aItens[nCont] )
		cTpTab  := PlsPtuGet( "TP_TABELA",aItens[nCont] )
		cCodPro	:= PlsPtuGet( "CD_SERVICO",aItens[nCont] )
		nQtd	:= PlsPtuGet( "QT_SERVICO",aItens[nCont] )

		PlsPtuPut("TP_TABELA",  cTpTab , aItens[nCont])
		PlsPtuPut("CD_SERVICO", cCodPro, aItens[nCont])
		PlsPtuPut("ID_AUTORIZ", cTpAut, aItens[nCont])
		PlsPtuPut("QT_AUTORIZ", nQtd ,aItens[nCont])

		if lPLPtuIte
			aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{cCodPro,"RECDES","",nil,nil,cTraOrig,nil})
			PlsPtuPut("DS_SERVICO",PadR(aPlPtuIte[3],80),aItens[nCont])
		else
			If lPTUOn80 // De-Para pela Tabela BTU (Terminologia TISS)
				aRetBTU := PTUDePaBTU(cCodPad,cCodPro,,.T.,,.T.)
				if len(aRetBTU) > 0
					PlsPtuPut("DS_SERVICO",PadR(Alltrim(aRetBTU[3]),80),aItens[nCont])
				else
					//Se nao achou o De/Para, faz a pesquisa normal do sistema
					if BR8->( DbSeek(xFilial("BR8") + cCodPad + cCodPro ) )
						PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nCont] )
					else
						PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nCont] )
					endIf
				endIf
			Else
				//Utiliza o De/Para BR8_CODEDI ou tabela B1M
				if GetNewPar("MV_PTDPION","0") == "1"

					PLBusProTab(cCodPro,.F.,,dDataAt,,,,,)

					if BR8->(found())

						//Descricao do procedimento
						PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nCont])

					else
						//Se nao achou o De/Para, faz a pesquisa normal do sistema
						if BR8->( dbSeek(xFilial("BR8") + cCodPad + cCodPro ) )
							PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nCont])
						else
							PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nCont] )
						endIf
					endIf

					//Realiza De/Para com a tabela de terminologias TISS BTU
				elseIf GetNewPar("MV_PTDPION","0") == "2"

					aRetBTU := PTUDePaBTU(cCodPad,cCodPro,,.T.)

					if len(aRetBTU) > 0
						PlsPtuPut("DS_SERVICO",PadR(Alltrim(aRetBTU[3]),80),aItens[nCont])
					else
						//Se nao achou o De/Para, faz a pesquisa normal do sistema
						if BR8->( DbSeek(xFilial("BR8") + cCodPad + cCodPro ) )
							PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nCont] )
						else
							PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nCont] )
						endIf
					endIf

				else
					//Busca a descricao do evento
					BR8->(DbSetOrder(1))
					if BR8->( DbSeek( xFilial("BR8")+ cCodPad + cCodPro ) )
						PlsPtuPut("DS_SERVICO",PadR(BR8->BR8_DESCRI,80),aItens[nCont] )
					else
						PlsPtuPut("DS_SERVICO",PadR("PROCEDIMENTO INEXISTENTE",80),aItens[nCont] )
					endIf
				endIf
			EndIf
		endIf

		//Atualiza o procedimento
		if cTpAut != "2"

			for nY := 1 to 5

				//Caso exista criticas
				cCodCri := PlsPtuGet( "CD_MENS_E" + allTrim( str(nY) ) ,aItens[nCont] )

				if val(cCodCri) > 0
					PlsPtuPut( "CD_MENS_E" + allTrim( str(nY) ), cCodCri ,aItens[nCont] )
				endIf

			next

		endIf
	next

	aGrvTraPTU := {AllTrim(cTraOrig),PlsPtuGet("CD_TRANS",aDados),PlsIntPad(),cOpeSol,PlsPtuGet("NM_BENEF",aDadosCab)}

	PlsPtuOln(aDados,aItens,AllTrim(cTraOrig)+"."+Subs(PLSINTPAD(),2,3),,lWeb,aGrvTraPTU,nil,nil,@cMsgXsdErr)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLLmpArray
Limpa de maneira correta o array para evitar estouro de memória

@author  Lucas Nonato
@version P11
@since   04/11/16
/*/
//-------------------------------------------------------------------
Static Function PLLmpArray(aArray)

	While Len(aArray) > 0
		aDel(aArray,len(aArray))
		aSize(aArray, len(aArray)-1)
	EndDo

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} XMLSoapAction
XMLSoapAction

@author  PLS TEAM
@version P11
@since   04/11/16
/*/
//-------------------------------------------------------------------
STATIC Function XMLSoapAction(cSoapAction)
	Local nAt
	cSoapAction := Upper(cSoapAction) //RemAspas() Funções não compiladas 2021
	nAt := rat('/',cSoapAction)
	If nAt > 0
		cSoapAction := substr(cSoapAction,nAt+1)
	Endif

Return cSoapAction



//-------------------------------------------------------------------
/*/{Protheus.doc} PLTagXMLPT
Funcao para retornar um elemento de um Objeto baseado em um XML (utilizado nos WebServices Unimed)

Parametros:
	cNameSpace -> Namespace padrao da estrutura
	cPai       -> Tag da estrutura principal
	cTree      -> Estrutura de tags a partir da pai que se deseja obeter a informacao

@author  PLS TEAM
@version P11
@since   21/07/16
/*/
//-------------------------------------------------------------------
Function PLTagXMLPT(oObjXml,cNameSpace,cPai,cTree,cTpDado)
	Local cString := ""
	Local xRet    := ""
	Local nX      := 0
	Local aAux    := {}

	Default cNameSpace := ""
	Default cTpDado    := "C"

	aAux := StrTokArr( cTree,"\")
	cString := "oObjXml:"+cNameSpace+cPai+":"
	For nX := 1 to len(aAux)
		cString += cNameSpace+aAux[nX]+":"
	Next

	If Type(Substr(cString,1,len(cString)-1)) == "O"
		xRet := &(Upper(cString+"TEXT"))

		If cTpDado == "D"
			xRet := Stod(Replace(xRet,"-",""))
		EndIf
	EndIf

Return xRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PLMntTagPT
Monta uma tag no arquivo Soap de resposta (utilizado nos WebServices Unimed)

@author  PLS TEAM
@version P11
@since   25/07/16
/*/
//-------------------------------------------------------------------
Function PLMntTagPT(cSoapRet,cTag,cConteudo,lOpenTag,lCloseTag,lNameSpace,cHash,cNameSpace)
	Default cConteudo  := ""
	Default lOpenTag   := .F.
	Default lClosetag  := .F.
	Default lNameSpace := .F.
	Default cHash      := ""
	Default cNameSpace := "v1:"

	//Quando e arquivo de resposta nao envia o NameSpace
	If !lNameSpace
		cNameSpace := ""
	EndIf

	If lOpenTag
		cSoapRet += '<'+cNameSpace+cTag+'>' + Chr(13)+Chr(10)
	ElseIf lCloseTag
		cSoapRet += '</'+cNameSpace+cTag+'>'+ Chr(13)+Chr(10)
	ElseIf !Empty(cConteudo)
		cSoapRet += '<'+cNameSpace+cTag+'>' + cConteudo + '</'+cNameSpace+cTag+'>' + Chr(13)+Chr(10)
		If lNameSpace
			cHash += cConteudo
		EndIf
	EndIf

Return cSoapRet


//-------------------------------------------------------------------
/*/{Protheus.doc} RemovChar
Remove caracteres especiais nao permitidos pela Unimed do Brasil

@author  PLS TEAM
@version P11
@since   24/11/16
/*/
//-------------------------------------------------------------------
Static Function RemovChar(cText)
	cText := StrTran(cText,"'","")
	cText := StrTran(cText,'"',"")
	cText := StrTran(cText,"!","")
	cText := StrTran(cText,"@","")
	cText := StrTran(cText,"#","")
	cText := StrTran(cText,"$","")
	cText := StrTran(cText,"%","")
	cText := StrTran(cText,"¨","")
	cText := StrTran(cText,"&","")
	cText := StrTran(cText,"*","")
	cText := StrTran(cText,"(","")
	cText := StrTran(cText,")","")
	cText := StrTran(cText,"_","")
	cText := StrTran(cText,"=","")
	cText := StrTran(cText,"+","")
	cText := StrTran(cText,"´","")
	cText := StrTran(cText,"`","")
	cText := StrTran(cText,"[","")
	cText := StrTran(cText,"]","")
	cText := StrTran(cText,"{","")
	cText := StrTran(cText,"}","")
	cText := StrTran(cText,";","")
	cText := StrTran(cText,":","")
	cText := StrTran(cText,"/","")
	cText := StrTran(cText,"\","")
	cText := StrTran(cText,"|","")
	cText := StrTran(cText,'?',"")
	cText := StrTran(cText,"~","")
	cText := StrTran(cText,"^","")
	cText := StrTran(cText,"","")

	cText := StrTran(cText,"ã","a")
	cText := StrTran(cText,"õ","o")
	cText := StrTran(cText,"Ã","A")
	cText := StrTran(cText,"Õ","O")

	cText := StrTran(cText,"á","a")
	cText := StrTran(cText,"é","e")
	cText := StrTran(cText,"í","i")
	cText := StrTran(cText,"ó","o")
	cText := StrTran(cText,"ú","u")
	cText := StrTran(cText,"Á","A")
	cText := StrTran(cText,"É","E")
	cText := StrTran(cText,"Í","I")
	cText := StrTran(cText,"Ó","O")
	cText := StrTran(cText,"Ú","U")

	cText := StrTran(cText,"à","a")
	cText := StrTran(cText,"è","e")
	cText := StrTran(cText,"ì","i")
	cText := StrTran(cText,"ò","o")
	cText := StrTran(cText,"ù","u")
	cText := StrTran(cText,"À","A")
	cText := StrTran(cText,"È","E")
	cText := StrTran(cText,"Ì","I")
	cText := StrTran(cText,"Ò","O")
	cText := StrTran(cText,"Ù","U")

	cText := StrTran(cText,"ç","c")
	cText := StrTran(cText,"Ç","C")

	cText := StrTran(cText,"ª","")
	cText := StrTran(cText,"º","")
	cText := StrTran(cText,"°","")
	cText := StrTran(cText,"§","")
	cText := StrTran(cText,"¹","")
	cText := StrTran(cText,"²","")
	cText := StrTran(cText,"³","")
	cText := StrTran(cText,"£","")
	cText := StrTran(cText,"¢","")
	cText := StrTran(cText,"¬","")

	If ExistBlock( "PLPTONCH" )
		cText := ExecBlock( "PLPTONCH", .F., .F., {cText} )
	EndIf

Return(cText)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLANEPTUON
Cria guia de anexo para TISS 3.00.00

@author  PLS TEAM
@version P11
@since   06/06/17
/*/
//-------------------------------------------------------------------
Function PLANEPTUOT(cEmp,cFil,aThreads,aDados,aItens,aQuimio,aRadio,cGuiaRef,dDataAt,lThread,cTpTran,cCodUsu)
	Local cSexo      := ""
	Local cTipGui    := ""
	Local cNomSol    := ""
	Local cTelSol    := ""
	Local cEmailSol  := ""
	Local cTpAnexo   := ""
	Local cCidPri    := ""
	Local cCidSec    := ""
	Local cCidTer    := ""
	Local cCidQua    := ""
	Local cDiagHisPa := ""
	Local cInfRelev  := ""
	Local cDescCirur := ""
	Local cFinali    := ""
	Local cEstadi    := ""
	Local cEcog      := ""
	Local cObserv    := ""
	Local nI         := 0
	Local nFor       := 0
	Local aDadUsr    := {}
	Local cSequen    := ""
	Local cCodPad    := ""
	Local cCodPro    := ""
	Local cCodGloAud := '025'
	Local nQtdPro    := 0
	Local dDatPro 	 := ctod("")
	Local dDataCirur := ctod("")
	Local aRetAux    := {}
	Local aRet       := {}
	Local aHisCri  	 := {}
	Local aDadCri    := {}
	Local aCabCri    := {}
	Local aVetCri    := {}
	Local aDadB4A    := {}
	Local aChaveGen  := {}
	Local lAuditoria := .F.
	Local cCodGlo    := ""
	Local cDesGlo    := ""
	Local cCodMot    := ""
	Local cObsMot    := ""
	Local cPartci    := ""
	Local cUniMed    := ""
	Local cTotDosag  := ""
	Local cNivAutCri := ""
	Local cChaveNiv  := ""
	Local cAliasPro  := ""
	Local cAliasCri  := ""
	Local cAliasAut  := ""
	Local cNodulo    := ""
	Local cTumor     := ""
	Local cMetastase := ""
	Local cUnMedida  := ""
	Local cDiaCiclAt := ""
	Local nSeqMov    := 1
	Local nSeqCri    := 1
	Local cSeqB4C    := ""
	Local cTmpPro    := ""
	Local dDatDia	 := ctod("")
	Local dDatPre  	 := ctod("")
	Local lRet       := .F.
	Local cNrtrol    := ""
	Local cNrAope    := ""
	Local aDadBA1    := {}
	Local nVlrEvent  := 0
	PRIVATE aAutForAnx := {}
	DEFAULT lThread   := .F.
	DEFAULT cTpTran   := "00600"
	DEFAULT cCodUsu   := ""

	If lThread
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf
	aDadBA1  := BA1->(GetArea())

	BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	If !BA1->(dbSeek(xFilial("BA1")+cCodUsu))
		BA1->(DbSetOrder(5))
		BA1->(dbSeek(xFilial("BA1")+cCodUsu))
	EndIf

	aDadUsr  := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO),"1", .F., dDataAt)
	aRetAux  := PLSXVLDCAL(dDataBase,PLSINTPAD(),.F.,"","")
	cTmpPro  := Time()
	//Coleta dados para o cabecalho
	If PlsPtuGet("TP_SEXO",aDados) == "1" //Masculino
		cSexo := "1"
	ElseIf PlsPtuGet("TP_SEXO",aDados) == "3" //Feminino
		cSexo := "2"
	EndIf

	//Quimio
	If PlsPtuGet("TP_ANEXO",aItens[1]) == "1"
		cTipGui		:= '07'
		cTpAnexo   	:= "2"
		cNomSol    	:= PlsPtuGet("NM_SOL_QUI",aQuimio)
		cTelSol    	:= PlsPtuGet("NR_TEL_QUI",aQuimio)
		cEmailSol  	:= PlsPtuGet("END_EM_QUI",aQuimio)
		cCidPri    	:= PlsPtuGet("CD_CID1",aQuimio)
		cCidSec    	:= PlsPtuGet("CD_CID2",aQuimio)
		cCidTer    	:= PlsPtuGet("CD_CID3",aQuimio)
		cCidQua    	:= PlsPtuGet("CD_CID4",aQuimio)
		dDataCirur 	:= Stod(PlsPtuGet("DT_CIRURGI",aQuimio))
		dDatDia    	:= StoD(PlsPtuGet("DT_DIAG",aQuimio))
		cFinali    	:= PlsPtuGet("CD_FINALID",aQuimio)
		cEstadi    	:= PlsPtuGet("CD_ESTADIA",aQuimio)
		cEcog      	:= PlsPtuGet("CD_ECOG",aQuimio)
		dDatPre    	:= Stod(PlsPtuGet("DT_IRRAD",aQuimio))
		cObserv    	:= PlsPtuGet("DS_QUIMIO",aQuimio)
		cDiagHisPa 	:= PlsPtuGet("DS_DIAG_QU",aQuimio)
		cInfRelev  	:= PlsPtuGet("DS_INF_QUI",aQuimio)

		cDescCirur 	:= PlsPtuGet("DS_CIRURGI",aQuimio)
		//Versão 6.0
		cNodulo    := PlsPtuGet("CL_NODULO",aQuimio)
		cTumor     := PlsPtuGet("CL_TUMOR",aQuimio)
		cMetastase := PlsPtuGet("CL_METASTA",aQuimio)
		cDiaCiclAt := PlsPtuGet("QT_DIAS_CI",aQuimio)
		//Radio
	ElseIf PlsPtuGet("TP_ANEXO",aItens[1]) == "2"
		cTipGui 	:= '08'
		cTpAnexo   	:= "1"
		cNomSol    	:= PlsPtuGet("NM_SOL_RAD",aRadio)
		cTelSol    	:= PlsPtuGet("NR_TEL_RAD",aRadio)
		cEmailSol  	:= PlsPtuGet("END_EM_RAD",aRadio)
		cCidPri    	:= PlsPtuGet("CD_CID1",aRadio)
		cCidSec    	:= PlsPtuGet("CD_CID2",aRadio)
		cCidTer    	:= PlsPtuGet("CD_CID3",aRadio)
		cCidQua    	:= PlsPtuGet("CD_CID4",aRadio)
		cDescCirur 	:= PlsPtuGet("DS_CIRURGI",aRadio)
		dDataCirur 	:= Stod(PlsPtuGet("DT_CIRURGI",aRadio))
		dDatDia    	:= StoD(PlsPtuGet("DT_DIAG",aRadio))
		cFinali    	:= PlsPtuGet("CD_FINALID",aRadio)
		cEstadi    	:= PlsPtuGet("CD_ESTADIA",aRadio)
		cEcog      	:= PlsPtuGet("CD_ECOG",aRadio)
		dDatPre    	:= Stod(PlsPtuGet("DT_PREV_AD",aRadio))
		cDiagHisPa 	:= PlsPtuGet("DS_DIAG_RA",aRadio)
		cInfRelev  	:= PlsPtuGet("DS_INF_RAD",aRadio)
		cObserv    	:= PlsPtuGet("DS_RADIO",aRadio)


		//OPME
	ElseIf PlsPtuGet("TP_ANEXO",aItens[1]) == "3"
		cTipGui  	:= '09'
		cTpAnexo   	:= "3"
		cNomSol    	:= PlsPtuGet("NM_SOLIC_O",aQuimio)
		cTelSol    	:= PlsPtuGet("NR_TEL_OPM",aQuimio)
		cEmailSol  	:= PlsPtuGet("END_EM_OPM",aQuimio)

		cObserv    	:= PlsPtuGet("DS_OPME",aDados)
		cNomSol    	:= PlsPtuGet("NM_SOLIC_O",aDados)
		cTelSol    	:= PlsPtuGet("NR_TEL_OPM",aDados)
		cEmailSol  	:= PlsPtuGet("END_EM_OPM",aDados)
		dDatPre    	:= ctod("")
	Endif

	//Posiciona indices
	BEA->(DbSetOrder(1))//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
	BEG->(DbSetOrder(1))//BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN
	BE2->(DbSetOrder(1))//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN

	//Posiciona na Operadora
	BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	BA0->(DbSeek(xFilial("BA0")+PlsIntPad()))

	//Monta cabecalho B4A
	aadd(aDadB4A,{"B4A_OPEMOV",PlsIntPad() })
	aadd(aDadB4A,{"B4A_REGANS",Alltrim(BA0->BA0_SUSEP) })
	aadd(aDadB4A,{"B4A_GUIREF",cGuiaRef })
	aadd(aDadB4A,{"B4A_DATPRO",dDataAt })
	aadd(aDadB4A,{"B4A_DATSOL",dDataAt })
	aadd(aDadB4A,{"B4A_GUIOPE",'' })
	aadd(aDadB4A,{"B4A_MATANT",BA1->BA1_MATANT })
	aadd(aDadB4A,{"B4A_OPEUSR",BA1->BA1_CODINT })
	aadd(aDadB4A,{"B4A_CODEMP",BA1->BA1_CODEMP })
	aadd(aDadB4A,{"B4A_CONEMP",BA1->BA1_CONEMP })
	aadd(aDadB4A,{"B4A_SUBCON",BA1->BA1_SUBCON })
	aadd(aDadB4A,{"B4A_VERCON",BA1->BA1_VERCON })
	aadd(aDadB4A,{"B4A_VERSUB",BA1->BA1_VERSUB })
	aadd(aDadB4A,{"B4A_MATRIC",BA1->BA1_MATRIC })
	aadd(aDadB4A,{"B4A_TIPREG",BA1->BA1_TIPREG })
	aadd(aDadB4A,{"B4A_DIGITO",BA1->BA1_DIGITO })
	aadd(aDadB4A,{"B4A_NOMUSR",BA1->BA1_NOMUSR })
	aadd(aDadB4A,{"B4A_CANCEL",'0' })
	aadd(aDadB4A,{"B4A_PESO"  ,Val(PlsPtuGet("NR_PESOBEN",aQuimio))})
	aadd(aDadB4A,{"B4A_ALTURA",Val(PlsPtuGet("NR_ALTBENE",aQuimio))})
	aadd(aDadB4A,{"B4A_SUPCOR",Val(PlsPtuGet("NR_SUPCORP",aQuimio))})
	aadd(aDadB4A,{"B4A_IDADE" ,Val(PlsPtuGet("NR_IDADE",aDados))  })
	aadd(aDadB4A,{"B4A_SEXO"  ,cSexo })
	aadd(aDadB4A,{"B4A_NOMSOL",cNomSol })
	aadd(aDadB4A,{"B4A_TELSOL",cTelSol })
	aadd(aDadB4A,{"B4A_EMASOL",cEmailSol })
	aadd(aDadB4A,{"B4A_TIPANE",cTpAnexo})
	aadd(aDadB4A,{"B4A_TIPGUI",cTipGui})
	aadd(aDadB4A,{"B4A_DATDIA",IIf(!Empty(dDatDia),dDatDia,Stod('')) })
	aadd(aDadB4A,{"B4A_CIDPRI",cCidPri })
	aadd(aDadB4A,{"B4A_CIDSEC",cCidSec })
	aadd(aDadB4A,{"B4A_CIDTER",cCidTer })
	aadd(aDadB4A,{"B4A_CIDQUA",cCidQua })
	aadd(aDadB4A,{"B4A_DIAIMG",PlsPtuGet("CD_DIAG_IM",aRadio) })
	aadd(aDadB4A,{"B4A_ESTADI",cEstadi  })
	aadd(aDadB4A,{"B4A_TIPQUI",PlsPtuGet("TP_QUIMIO",aQuimio) })
	aadd(aDadB4A,{"B4A_ECOG"  ,cEcog })
	aadd(aDadB4A,{"B4A_FINALI",cFinali })
	aadd(aDadB4A,{"B4A_PLATER",PlsPtuGet("DS_PL_TERA",aQuimio) })
	aadd(aDadB4A,{"B4A_DIAGCH",cDiagHisPa })
	aadd(aDadB4A,{"B4A_INFREL",cInfRelev })
	aadd(aDadB4A,{"B4A_CIRURG",cDescCirur})
	aadd(aDadB4A,{"B4A_DATCIR",dDataCirur })
	aadd(aDadB4A,{"B4A_DATIRR",Stod(PlsPtuGet("DT_IRRAD",aQuimio)) })
	aadd(aDadB4A,{"B4A_QUIMIO",PlsPtuGet("DS_QUIMIOT",aRadio) })
	aadd(aDadB4A,{"B4A_DATQUI",Stod(PlsPtuGet("DT_QUIMIOT",aRadio)) })
	aadd(aDadB4A,{"B4A_ANOPAG",aRetAux[4] })
	aadd(aDadB4A,{"B4A_MESPAG",aRetAux[5] })
	aadd(aDadB4A,{"B4A_JUSTTE",PlsPtuGet("DS_JUST_TE",aDados)  })
	aadd(aDadB4A,{"B4A_OBSERV",cObserv })
	aadd(aDadB4A,{"B4A_NROCAM",Val(PlsPtuGet("QT_CAMPOS",aRadio)) })
	aadd(aDadB4A,{"B4A_DOSDIA",Val(PlsPtuGet("QT_DOSE_DI",aRadio)) })
	aadd(aDadB4A,{"B4A_DOSTOT",Val(PlsPtuGet("QT_DOSE_TO",aRadio)) })
	aadd(aDadB4A,{"B4A_NRODIA",Val(PlsPtuGet("QT_DIAS_TR",aRadio)) })
	aadd(aDadB4A,{"B4A_ESPMAT",PlsPtuGet("DS_MAT_SOL",aDados) })
	aadd(aDadB4A,{"B4A_NROCIC",Val(PlsPtuGet("NR_CICLOS",aQuimio)) })
	aadd(aDadB4A,{"B4A_CICATU",Val(PlsPtuGet("NR_CL_ATUA",aQuimio)) })
	aadd(aDadB4A,{"B4A_INTCIC",Val(PlsPtuGet("NR_INTERV",aQuimio)) })
	aadd(aDadB4A,{"B4A_AREA",PlsPtuGet("DS_AREA_IR",aQuimio) })
	aadd(aDadB4A,{"B4A_DATPRE",IIf(!Empty(dDatPre),dDatPre,ctod('')) })

	//PTU 6.0 + TISS 3.03.00(Campos criados no UPDPLSHG referente a TISS 3.03.00)
	If B4A->( FieldPos("B4A_METAST") ) > 0
		aadd(aDadB4A,{"B4A_METAST",cMetastase  })
		aadd(aDadB4A,{"B4A_NODULO",cNodulo  })
		aadd(aDadB4A,{"B4A_TUMOR",cTumor  })
		aadd(aDadB4A,{"B4A_DCICAT",Val(cDiaCiclAt)  })
	EndIf

	//Busca dados da Guia Origem
	If BEA->(DbSeek(xFilial("BEA")+cGuiaRef)) .And. B4A->( FieldPos("B4A_NRTROL") ) > 0 .And. B4A->( FieldPos("B4A_NRAOPE") ) > 0
		cNrTrol := StrZero( Val( PlsPtuGet("NR_IDENT_O",aDados) ),10)
		BQV->(DbSetOrder(1))//BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
		If PlsPtuGet("CD_TRANS",aDados) == "00605" .and. BEA->BEA_TIPGUI == '03'//Evolução de Internação
			If BQV->(MsSeek(xFilial("BQV")+cGuiaRef))
				aadd(aDadB4A,{"B4A_NRAOPE",BQV->BQV_NRAOPE })
				aadd(aDadB4A,{"B4A_NRTROL",BQV->BQV_NRTROL })
				cNrAope	   := BQV->BQV_NRAOPE
				cNrtrol    := BQV->BQV_NRTROL
			EndIf
		Else
			aadd(aDadB4A,{"B4A_NRAOPE",BEA->BEA_NRAOPE })
			aadd(aDadB4A,{"B4A_NRTROL",BEA->BEA_NRTROL })
			cNrAope	   := BEA->BEA_NRAOPE
			cNrtrol    := BEA->BEA_NRTROL
		EndIf
		aadd(aDadB4A,{"B4A_COMUNI","1" })
	EndIf

	//Carrega aHeaders
	aCabProc := PLSA09AHea(cTipGui,'1')//PLSA09AHea(strzero(::AutType,2),'1')
	aDadProc := PLSA09AClB(aCabProc)
	aVetProc := {0}
	cAliasPro:= "B4C"

	aCabCri  := PLSA09HCHe()
	aDadCri  := PLSA09HClB(aCabCri)
	aVetCri  := {0}

	cAliasCri := "BEG"
	Iif(cTpTran == "00605",cAliasAut := "BQV",cAliasAut := "BE2")


	//Monta array de itens
	For nI:=1 to Len(aItens)

		If PlsPtuGet("TP_ANEXO",aItens[nI]) $ "09"
			Loop
		EndIf

		cSequen := PlsPtuGet("SEQMOV",aItens[nI])
		cSeqB4C := StrZero(nSeqMov,3)
		cCodPad := PlsPtuGet("CODPAD",aItens[nI])
		cCodPro := PlsPtuGet("CODPRO",aItens[nI])
		nQtdPro := PlsPtuGet("QTD",aItens[nI])
		dDatPro := dDataAt
		cUnMedida := PlsPtuGet("UNI_MEDIDA",aItens[nI])
		cTotDosag := PlsPtuGet("TOT_DOSAGE",aItens[nI])

		If cAliasAut == "BQV" //BQV busco os itens pelo NRTROL

			cNrTrol := StrZero( Val( PlsPtuGet("NR_IDENT_O",aDados) ),10)
			BQV->(DbSetOrder(5))//BQV_FILIAL+BQV_NRTROL
			If BQV->(MsSeek(xFilial("BQV")+cNrtrol))
				While Alltrim(BQV->BQV_NRTROL) == Alltrim(cNrTrol) .And. !BQV->(Eof())
					If BQV->BQV_CODPAD == cCodPad .And. Alltrim(BQV->BQV_CODPRO) == Alltrim(cCodPro)
						cNivAutCri := &(cAliasAut+"->"+cAliasAut+"_NIVAUT")
						cChaveNiv  := &(cAliasAut+"->"+cAliasAut+"_CHVNIV")
						lAuditoria := &(cAliasAut+"->"+cAliasAut+"_AUDITO") == "1"
						lRet       := &(cAliasAut+"->"+cAliasAut+"_STATUS") == "1"

						BQZ->(DbSetOrder(1))
						If !lRet .And. BQZ->(DbSeek(xFilial("BQZ")+cGuiaRef+BQV->BQV_SEQUEN))
							While BQZ->(BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT+BQZ_SEQUEN) == BQZ->(BQZ_FILIAL)+cGuiaRef+BQV->BQV_SEQUEN .And. !BQZ->(Eof())

								//Adiciona uma linha em branco para Criticas
								If nSeqCri <> 1
									P09ABlank(aDadCri,aCabCri,aVetCri)
								Endif
								aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_SEQUEN",aCabCri)] := cSeqB4C
								aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_CODGLO",aCabCri)] := BQZ->BQZ_CODGLO
								aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_DESGLO",aCabCri)] := BQZ->BQZ_DESGLO
								aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_CODMOT",aCabCri)] := BQZ->BQZ_CODMOT
								aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_OBSMOT",aCabCri)] := BQZ->BQZ_OBSMOT
								aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_PARTIC",aCabCri)] := BQZ->BQZ_PARTIC
								aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_UNIMED",aCabCri)] := BQZ->BQZ_UNIMED
								aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_SEQCRI",aCabCri)] := Strzero(nSeqCri,3)
								cNivAutCri :=  &(cAliasAut+"->"+cAliasAut+"_NIVCRI")

								nSeqCri++
								BQZ->(DbSkip())
							EndDo
						EndIf

						Exit
					EndIf
					BQV->(DbSkip())
				EndDo
			EndIf
		Else //Busco itens pelo Sequen
			If BE2->(DbSeek(xFilial("BE2")+cGuiaRef+cSequen))
				cNivAutCri := &(cAliasAut+"->"+cAliasAut+"_NIVAUT")
				cChaveNiv  := &(cAliasAut+"->"+cAliasAut+"_CHVNIV")
				lAuditoria := &(cAliasAut+"->"+cAliasAut+"_AUDITO") == "1"
				lRet       := &(cAliasAut+"->"+cAliasAut+"_STATUS") == "1"
			EndIf


			If BEA->(DbSeek(xFilial("BEA")+cGuiaRef)) .And. BEG->(DbSeek(xFilial("BEG")+cGuiaRef+cSequen))

				While BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == BEG->(BEG_FILIAL)+cGuiaRef+cSequen .And. !BEG->(Eof())
					lRet := .F. //Indica que o item foi negado

					//Adiciona uma linha em branco para Criticas
					If nSeqCri <> 1
						P09ABlank(aDadCri,aCabCri,aVetCri)
					Endif
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_SEQUEN",aCabCri)] := cSeqB4C
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_CODGLO",aCabCri)] := &(cAliasCri+"->"+cAliasCri+"_CODGLO")
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_DESGLO",aCabCri)] := &(cAliasCri+"->"+cAliasCri+"_DESGLO")
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_CODMOT",aCabCri)] := &(cAliasCri+"->"+cAliasCri+"_CODMOT")
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_OBSMOT",aCabCri)] := &(cAliasCri+"->"+cAliasCri+"_OBSMOT")
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_PARTIC",aCabCri)] := &(cAliasCri+"->"+cAliasCri+"_PARTIC")
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_UNIMED",aCabCri)] := &(cAliasCri+"->"+cAliasCri+"_UNIMED")
					aDadCri[Len(aDadCri)][PLRETPOS(cAliasCri+"_SEQCRI",aCabCri)] := Strzero(nSeqCri,3)
					cNivAutCri :=  &(cAliasAut+"->"+cAliasAut+"_NIVCRI")

					nSeqCri++
					BEG->(DbSkip())
				EndDo
			EndIf
		EndIf

		//Adiciona uma linha em branco para Procedimentos
		If nSeqMov <> 1
			P09ABlank(aDadProc,aCabProc,aVetProc)
		Endif

		BR8->(DbSetOrder(1))
		BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))

		aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_SEQUEN",aCabProc)] := cSeqB4C
		aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_CODPAD",aCabProc)] := cCodPad
		aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_CODPRO",aCabProc)] := cCodPro
		aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_DESPRO",aCabProc)] := BR8->BR8_DESCRI

		If ValType(PlsPtuGet("VLRAPR",aItens[nI])) $ "U-C"
			nVlrEvent := 0
		Else
			nVlrEvent := PlsPtuGet("VLRAPR",aItens[nI])
		EndIf
		If(PLRETPOS(cAliasPro+"_OPCAO",aCabProc )>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_OPCAO",aCabProc)]  := PlsPtuGet("TP_ORDEM",aItens[nI]),nil)
			If(PLRETPOS(cAliasPro+"_QTDSOL",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_QTDSOL",aCabProc)] := nQtdPro,nil)
				If(PLRETPOS(cAliasPro+"_VLRUNT",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_VLRUNT",aCabProc)] := nVlrEvent,nil)
					If(PLRETPOS(cAliasPro+"_QTDPRO",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_QTDPRO",aCabProc)] := nQtdPro,nil)
						If(PLRETPOS(cAliasPro+"_VLRUNA",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_VLRUNA",aCabProc)] := If(lRet,nVlrEvent,0),nil)
							If(PLRETPOS(cAliasPro+"_REGANV",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_REGANV",aCabProc)] := PlsPtuGet("CD_ANVISA",aItens[nI]),nil)
								If(PLRETPOS(cAliasPro+"_REFMAF",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_REFMAF",aCabProc)] := PlsPtuGet("CD_REF_FAB",aItens[nI]),nil)
									If(PLRETPOS(cAliasPro+"_AUTFUN",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_AUTFUN",aCabProc)] := "",nil)
										If(PLRETPOS(cAliasPro+"_VIAADM",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_VIAADM",aCabProc)] := PlsPtuGet("CD_VIA_ADM",aItens[nI]),nil)
											If(PLRETPOS(cAliasPro+"_FREQUE",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_FREQUE",aCabProc)] := PlsPtuGet("QT_FREQUEN",aItens[nI]),nil)
												If(PLRETPOS(cAliasPro+"_DATPRO",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_DATPRO",aCabProc)] := dDataAt,nil)
													If(PLRETPOS(cAliasPro+"_IMGSTA",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_IMGSTA",aCabProc)] := If(lRet,"ENABLE","DISABLE"),nil)
														If(PLRETPOS(cAliasPro+"_STATUS",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_STATUS",aCabProc)] := If(lRet,"1","0"),nil)
															If(PLRETPOS(cAliasPro+"_AUDITO",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_AUDITO",aCabProc)] := If(lAuditoria,'1','0'),nil)
																If(PLRETPOS(cAliasPro+"_SALDO",aCabProc )>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_SALDO",aCabProc)]  := nQtdPro,nil)
																	If(PLRETPOS(cAliasPro+"_NIVEL",aCabProc )>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_NIVEL",aCabProc)]  := BR8->BR8_NIVEL,nil)
																		If(PLRETPOS(cAliasPro+"_NIVAUT",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_NIVAUT",aCabProc)] := If(lRet,cNivAutCri,Space(03)),nil)
																			If(PLRETPOS(cAliasPro+"_NIVCRI",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_NIVCRI",aCabProc)] := If(!lRet,cNivAutCri,Space(03)),nil)
																				If(PLRETPOS(cAliasPro+"_CHVNIV",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_CHVNIV",aCabProc)] := cChaveNiv,nil)
																					If(PLRETPOS(cAliasPro+"_NRAOPE",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_NRAOPE",aCabProc)] := BEA->BEA_NRAOPE,nil)
																						If(PLRETPOS(cAliasPro+"_NRTROL",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_NRTROL",aCabProc)] := BEA->BEA_NRTROL,nil)
																							If(PLRETPOS(cAliasPro+"_COMUNI",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_COMUNI",aCabProc)] := "1",nil)
																								If PlsPtuGet("TP_ANEXO",aItens[1]) == "1"
																									If(PLRETPOS(cAliasPro+"_UNMED",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_UNMED",aCabProc)]   := cUnMedida ,nil)
																										If(PLRETPOS(cAliasPro+"_DOSTOT",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_DOSTOT",aCabProc)] := cTotDosag ,nil)
																											If(PLRETPOS(cAliasPro+"_QTDPRO",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_QTDPRO",aCabProc)] := IIF(Val(cTotDosag)>0,Val(cTotDosag),nQtdPro),nil)
																												If(PLRETPOS(cAliasPro+"_QTDSOL",aCabProc)>0,aDadProc[Len(aDadProc)][PLRETPOS(cAliasPro+"_QTDSOL",aCabProc)] := IIF(Val(cTotDosag)>0,Val(cTotDosag),nQtdPro),nil)
																												EndIf
																												nSeqMov++
																											Next

																											aadd(aDadB4A,{"B4A_AUDITO",IIF(lAuditoria,'1','0')})

																											PlsPtuLog("")
																											PlsPtuLog("***********************************")
																											If lThread
																												PlsPtuLog("Criacao de Guia de Anexos Clinico via Thread (MV_PLTHANE)")
																											EndIf
																											PlsPtuLog("Gerando Guia de anexo para a autorização -> "+cGuiaRef)


																											//Chama funcao para gravar a guia
																											aRetorno := PLSA09AGRV(3,PlsIntPad(),'B4C','B4A','BEG',aDadB4A,aCabProc,aDadProc,aVetProc,aCabCri,aDadCri,aVetCri,;
																												cTipGui,dDataBase,aRetAux[4],aRetAux[5],aChaveGen,.T.)
																											If aRetorno[1]
																												PlsPtuLog("Guia de anexo criada -> "+aRetorno[2]+aRetorno[3]+aRetorno[4]+aRetorno[5])
																											EndIf

																											If lThread
																												PlsPtuLog("Tempo de processamento : "+ElapTime(cTmpPro,Time())+" (Inicio: "+cTmpPro+" Fim : "+Time()+" )")
																											EndIf

																											RestArea(aDadBA1)

																											Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} PTUONPAC
Função responsavel por processar a composição dos pacotes recebidos de outra
Unimed nas transações PTU Online.

@author Vinicius Queiros Teixeira
@since 31/08/2020
/*/
//-------------------------------------------------------------------
Function PTUONPAC(cCodOpe, cGuiaPacote, aAutomacao)

	Local cOpeMov := ""
	Local cUniOri := ""
	Local cSequen := ""
	Local cPacote := ""
	Local cCodRda := ""
	Local dDtAtendi := CToD(" / / ")
	Local aChave := ""
	Local cAlias := ""
	Local cNrTrol := ""
	Local nQtdPacote := 0
	Local cQuery := ""
	Local lB6L_QTDPAC := B6L->(FieldPos("B6L_QTDPAC")) > 0

	Default cCodOpe := ""
	Default cGuiaPacote := ""
	Default aAutomacao := {}

	DBSelectArea("B6L")
	B6L->(DbSetOrder(1))

	If !Empty(cGuiaPacote) // Consulta por Guia
		If B6L->(MsSeek(xFilial("B6L") + cGuiaPacote))

			While B6L->(!Eof()) .And. xFilial("B6L")+B6L->(B6L_OPEMOV+B6L_ANOAUT+B6L_MESAUT+B6L_NUMAUT) == xFilial("B6L")+cGuiaPacote

				If B6L->B6L_COMUNI == "1"
					B6L->(DbSkip())
					Loop
				EndIf

				PlsPtuLog("Guia   => " + cGuiaPacote + "  ["+Time()+"]", LOGSISPAC)
				PlsPtuLog("Pacote => " + B6L->B6L_CODPAC + "  ["+Time()+"]", LOGSISPAC)

				cOpeMov	:= B6L->B6L_OPEMOV
				cUniOri	:= B6L->B6L_UNIORI
				cSequen	:= B6L->B6L_SEQUEN
				cPacote	:= B6L->B6L_CODPAC
				cCodRda	:= B6L->B6L_CODRDA
				dDtAtendi := B6L->B6L_DTATEN
				aChave := {B6L->B6L_OPEMOV, B6L->B6L_ANOAUT, B6L->B6L_MESAUT, B6L->B6L_NUMAUT}
				cAlias := B6L->B6L_ALIAS
				cNrTrol := B6L->B6L_NRTROL
				If lB6L_QTDPAC
					nQtdPacote := B6L->B6L_QTDPAC
				EndIf

				If PLSPACWEB(cOpeMov, cUniOri, cSequen, cPacote, cCodRda, dDtAtendi, aChave, cAlias, cNrTrol, nQtdPacote, aAutomacao)
					B6L->(Reclock("B6L",.F.))
					B6L->B6L_COMUNI := "1" // Comunicação = Sim
					B6L->(MsUnLock())
				Else
					B6L->(Reclock("B6L",.F.))
					B6L->B6L_COMUNI := "2" // Comunicação com Falha
					B6L->(MsUnLock())
				EndIf

				B6L->(DbSkip())
				PlsPtuLog("", LOGSISPAC)
			EndDo
		EndIf
	Else // Consulta via Schedule

		cQuery := " SELECT R_E_C_N_O_ Recno FROM " + RetSQLName("B6L") + " B6L "
		cQuery += " WHERE B6L_FILIAL = '" + xFilial("B6L") + "' "
		cQuery += " AND B6L_OPEMOV = '"+cCodOpe+"' "
		cQuery += " AND B6L_COMUNI = '0' "
		cQuery += " AND B6L.D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TrbB6L",.F.,.T.)

		If !TrbB6L->(Eof())
			While !TrbB6L->(Eof())

				B6L->(DbGoTo(TrbB6L->Recno))

				PlsPtuLog("Guia   => " + B6L->(B6L_OPEMOV+B6L_ANOAUT+B6L_MESAUT+B6L_NUMAUT) + "  ["+Time()+"]", LOGSISPAC)
				PlsPtuLog("Pacote => " + B6L->B6L_CODPAC + "  ["+Time()+"]", LOGSISPAC)

				cOpeMov	:= B6L->B6L_OPEMOV
				cUniOri	:= B6L->B6L_UNIORI
				cSequen	:= B6L->B6L_SEQUEN
				cPacote	:= B6L->B6L_CODPAC
				cCodRda	:= B6L->B6L_CODRDA
				dDtAtendi := B6L->B6L_DTATEN
				If alltrim(B6L->(B6L_ANOAUT+B6L_MESAUT+B6L_NUMAUT)) == ""
					If B6L->( FieldPos("B6L_CODLDP") ) > 0 .and. B6L->( FieldPos("B6L_CODPEG") ) > 0 .and. B6L->( FieldPos("B6L_NUMERO") ) > 0 .and. B6L->( FieldPos("B6L_ORIMOV") ) > 0
						aChave := {B6L->B6L_OPEMOV, B6L->B6L_CODLDP, B6L->B6L_CODPEG, B6L->B6L_NUMERO, B6L->B6L_ORIMOV}
					Else
						TrbB6L->(DbSkip())
						Loop
					Endif
				Else
					aChave := {B6L->B6L_OPEMOV, B6L->B6L_ANOAUT, B6L->B6L_MESAUT, B6L->B6L_NUMAUT}
				Endif
				cAlias := B6L->B6L_ALIAS
				cNrTrol := B6L->B6L_NRTROL
				If lB6L_QTDPAC
					nQtdPacote := B6L->B6L_QTDPAC
				EndIf

				If PLSPACWEB(cOpeMov, cUniOri, cSequen, cPacote, cCodRda, dDtAtendi, aChave, cAlias, cNrTrol, nQtdPacote)
					B6L->(Reclock("B6L",.F.))
					B6L->B6L_COMUNI := "1" // Comunicação = Sim
					B6L->(MsUnLock())
				Else
					B6L->(Reclock("B6L",.F.))
					B6L->B6L_COMUNI := "2" // Comunicação com Falha
					B6L->(MsUnLock())
				EndIf

				TrbB6L->(DbSkip())
				PlsPtuLog("", LOGSISPAC)
			EndDo
		EndIf
		TrbB6L->(DBCloseArea())
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSPACWEB
Realizar a gravação da composição do pacote

@param cOpeMov		Unimed a realizar a consulta do WebService
@param cUniOri		Unimed origem do pacote
@param cSequen  	Sequencial do pacote na guia
@param cPacote  	Codigo do Pacote
@param cCodRda  	Codigo do Prestador do pacote
@param dDtAtendi  	Data do Atendimento
@param aChave  		Chave da Guia
@param cAlias		Tabela do Pacote
@param cNrTrol		Numero da Transação
@param nQtdPacote   Quantiade do Pacote

@return lRetorno	Se foi realizado com sucesso

@author Vinicius Queiros Teixeira
@since 03/09/2020
/*/
//-------------------------------------------------------------------
Function PLSPACWEB(cOpeMov, cUniOri, cSequen, cPacote, cCodRda, dDtAtendi, aChave, cAlias,;
		cNrTrol, nQtdPacote, aAutomacao)

	Local lRetorno := .F.
	Local oPackage as object
	Local cSQL := ""
	Local cNomePacote := ""
	Local nVlrPacote := 0
	// Codigos Genericos
	Local cCodMedGen := GetNewPar("MV_PLMEDPT","")
	Local cCodMatGen := GetNewPar("MV_PLMATPT","")
	Local cCodTaxGen := GetNewPar("MV_PLTAXPT","")
	Local cCodOpmGen := GetNewPar("MV_PLOPMPT","")
	Local cCodTeaGen := GetNewPar("MV_PLTEAPT","")
	Local cPacoteGen := GetNewPar("MV_PLPACPT","")
	// Dados da Composição
	Local cTipo := ""
	Local cCodigo := ""
	Local cCodPro := ""
	Local cCodPad := ""
	Local cDescri := ""
	Local cTpTabela := ""
	Local nQuanti := 0
	Local nValorUn := 0
	Local nValorTotal := 0
	Local aRetBTU := {}
	Local aDadB43 := {}
	Local nVlrB43 := 0
	// Dados da Guia
	Local aChavePeg := {}
	Local cCodOpe := ""
	Local cCodLpd := ""
	Local cCodPeg := ""
	Local cNumGui := ""
	Local cOriMov := ""
	// Dados do Procedimento Principal
	Local cCdPadPrinc := ""
	Local cCodPrinci := ""
	Local cDescriPrinc := ""
	Local cTipoPrinc := ""
	Local nQtdPrinc := 0
	Local nVlrPrinc := 0
	Local nVlrTotPrinc := 0
	Local aDadPrinc := {}
	// Dados para Controle
	Local lPrestador := .T.
	Local lComposicao := .T.
	Local nNz := 0
	Local nNy := 0
	Local lBD6 := .F.
	Local lB43Quantidade := B43->(FieldPos("B43_QTDPRO")) > 0
	// Dados para Regra de Pacote Fechado
	Local nTotMaterial := 0
	Local nTotMedicamento := 0
	Local nTotOPME := 0
	Local nTotTaxasGases := 0
	Local lPacoteFechado := .F.

	Default nQtdPacote := 0
	Default aAutomacao := {}

	oPackage := getPackageSispac(cOpeMov, cUniOri, cPacote, cCodRda, dDtAtendi, aAutomacao)

	If valType(oPackage) == "J"
		// Prestador não informado
		If Empty(cCodRda)
			lPrestador := .F.
		EndIf

		If cAlias <> "BD6"
			aChavePeg := GetChavePeg(aChave)
			If Len(aChavePeg) > 0
				cCodOpe := aChavePeg[1]
				cCodLpd := aChavePeg[2]
				cCodPeg := aChavePeg[3]
				cNumGui := aChavePeg[4]
				cOriMov := aChavePeg[5]
			Else
				lRetorno := .F.
				Return lRetorno
			EndIf
		Else
			cCodOpe := PlsIntPad()
			cCodLpd := aChave[2]
			cCodPeg := aChave[3]
			cNumGui := aChave[4]
			cOriMov := aChave[5]
			lBD6 := .T.
		Endif

		If cAlias == "BQV" // Complemento SADT ou Prorrogação - Pegar o sequencial gravado na BQV para gravar na B43
			BQV->(DbSetOrder(1))
			If BQV->(DbSeek(xFilial("BQV") + aChave[1] + aChave[2] + aChave[3] + aChave[4]))
				While !BQV->(Eof()) .And. xFilial("BQV")+BQV->(BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == xFilial("BQV")+aChave[1] + aChave[2] + aChave[3] + aChave[4]

					If Alltrim(BQV->(BQV_NRTROL)) == Alltrim(cNrTrol) .And. Alltrim(BQV->BQV_CODPRO) == cPacoteGen .And. Val(BQV->BQV_SEQPTU) == Val(cSequen)
						cSequen := BQV->BQV_SEQUEN
						Exit
					EndIf

					BQV->(DbSkip())
				EndDo
			EndIf
		EndIf

		PlsPtuLog("  - Buscando procedimento principal do pacote. ["+Time()+"]", LOGSISPAC)

		nVlrPacote := IIF(ValType(oPackage["vl_pacote"]) <> "U", oPackage["vl_pacote"], 0) // Valor total do Pacote

		cCodPrinci := IIF(ValType(oPackage["cd_item"]) == "N", cValToChar(oPackage["cd_item"]), oPackage["cd_item"])
		nQtdPrinc := oPackage["qt_servico"]
		nVlrPrinc := IIF(ValType(oPackage["vl_servico"]) <> "U", oPackage["vl_servico"], 0)
		nVlrTotPrinc := IIF(ValType(oPackage["vl_total"]) <> "U", oPackage["vl_total"], 0)

		If nVlrPrinc == 0
			If nQtdPrinc < 1
				nVlrPrinc := nVlrTotPrinc
				nQtdPrinc := 1
			Else
				nVlrPrinc := nVlrTotPrinc/nQtdPrinc
			EndIf
		Else
			If nQtdPrinc < 1
				nVlrPrinc *= nQtdPrinc
				nQtdPrinc := 1
			EndIf
		EndIf

		// Retornar os dados do item principal para gravar a B43
		If cAlias <> "BD6"
			aDadPrinc := RetDadPrinc(cCodPrinci, cAlias, aChave, lPrestador)

			If Len(aDadPrinc) > 0
				cCdPadPrinc	:= aDadPrinc[1]
				cDescriPrinc := aDadPrinc[2]
				cTipoPrinc := aDadPrinc[3]
			Else
				PlsPtuLog("  - Falha ao Buscar procedimento principal do pacote na Guia. ["+Time()+"]", LOGSISPAC)
				lRetorno := .F.
				Return lRetorno
			EndIf
		Else
			cSql := " SELECT BR8_CODPAD, BR8_DESCRI, BR8_TPPROC "
			cSql += " FROM " + retSqlName("BR8") + " BR8 "
			cSql += " WHERE BR8_FILIAL = '" + xfilial("BR8") + "' "
			cSql += " AND BR8_CODPSA = '" + cCodPrinci + "' "
			cSql += " AND BR8_BENUTL = '1'  "
			cSql += " AND BR8.D_E_L_E_T_ = ' '  "
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TrbBR8",.T.,.T.)

			If TrbBR8->(!eof())
				cCdPadPrinc	:= TrbBR8->BR8_CODPAD
				cDescriPrinc := TrbBR8->BR8_DESCRI
				cTipoPrinc := iif(empty(TrbBR8->BR8_TPPROC),"0",TrbBR8->BR8_TPPROC)
				TrbBR8->(dbclosearea())
			Else
				PlsPtuLog("  - Falha ao Buscar procedimento principal ["+cCodPrinci+"] na BR8. ["+Time()+"]", LOGSISPAC)
				lRetorno := .F.
				TrbBR8->(dbclosearea())
				Return lRetorno
			EndIf
		Endif

		nVlrPrinc := Round(nVlrPrinc,2)

		// Item Principal do Pacote
		If lB43Quantidade
			aAdd(aDadB43,{	{"B43_SEQUEN", cSequen},;
				{"B43_CODPAD", cCdPadPrinc},;
				{"B43_CODPRO", cCodPrinci},;
				{"B43_DESPRO", cDescriPrinc},;
				{"B43_VALFIX", nVlrPrinc},;
				{"B43_QTDPRO", nQtdPrinc},;
				{"B43_PRINCI", "1"},;
				{"B43_TIPO"  , cTipoPrinc},;
				{"B43_CODOPE", cCodOpe},;
				{"B43_CODLDP", cCodLpd},;
				{"B43_CODPEG", cCodPeg},;
				{"B43_NUMERO", cNumGui},;
				{"B43_ORIMOV", cOriMov},;
				{"B43_NIVPAC", "B6L"}})
			nVlrB43 += nVlrPrinc * nQtdPrinc

			PlsPtuLog("   -> Procedimento Principal: "+cCodPrinci+" ["+Time()+"]", LOGSISPAC)
			PlsPtuLog("   -> Valor: "+cValtoChar(nVlrPrinc)+" ["+Time()+"]", LOGSISPAC)
			PlsPtuLog("   -> Valor acumulado: "+cValtoChar(nVlrB43)+"["+Time()+"]", LOGSISPAC)
		Else
			For nNz := 1 To nQtdPrinc
				aAdd(aDadB43,{	{"B43_SEQUEN", cSequen},;
					{"B43_CODPAD", cCdPadPrinc},;
					{"B43_CODPRO", cCodPrinci},;
					{"B43_DESPRO", cDescriPrinc},;
					{"B43_VALFIX", nVlrPrinc},;
					{"B43_PRINCI", "1"},;
					{"B43_TIPO"  , cTipoPrinc},;
					{"B43_CODOPE", cCodOpe},;
					{"B43_CODLDP", cCodLpd},;
					{"B43_CODPEG", cCodPeg},;
					{"B43_NUMERO", cNumGui},;
					{"B43_ORIMOV", cOriMov},;
					{"B43_NIVPAC", "B6L"}})
				nVlrB43 += nVlrPrinc

				PlsPtuLog("   -> Procedimento Principal: "+cCodPrinci+" ["+Time()+"]", LOGSISPAC)
				PlsPtuLog("   -> Valor: "+cValtoChar(nVlrPrinc)+" ["+Time()+"]", LOGSISPAC)
				PlsPtuLog("   -> Valor acumulado: "+cValtoChar(nVlrB43)+"["+Time()+"]", LOGSISPAC)

			Next nNz
		EndIf

		PlsPtuLog("  - Buscando composição do Pacote. ["+Time()+"]", LOGSISPAC)

		// Composição do Pacote
		For nNy := 1 To Len(oPackage["detalhes"])
			cCodPad := ""
			cCodPro := ""
			cDescri := ""
			cTipo := IIF(ValType(oPackage["detalhes"][nNy]["tp_composicao"]) <> "U", cValToChar(oPackage["detalhes"][nNy]["tp_composicao"]), "")
			cTpTabela := IIF(ValType(oPackage["detalhes"][nNy]["tp_tabela"]) <> "U", cValToChar(oPackage["detalhes"][nNy]["tp_tabela"]), "")
			cCodigo	:= IIF(ValType(oPackage["detalhes"][nNy]["cd_item"]) <> "U", oPackage["detalhes"][nNy]["cd_item"], "")

			aRetBTU := PTUDePaBTU(cTpTabela, cCodigo, nil, .T., nil, .T., cTipo)

			If Len(aRetBTU) > 0
				cCodPad := aRetBTU[1]
				cCodPro := aRetBTU[2]
				// Caso o código seja o mesmo dos genéricos
				If cCodPro $ cCodMedGen+"/"+cCodMatGen+"/"+cCodTaxGen+"/"+cCodOpmGen+"/"+cPacoteGen+"/"+cCodTeaGen
					cDescri := IIF(ValType(oPackage["detalhes"][nNy]["ds_item"]) <> "U", oPackage["detalhes"][nNy]["ds_item"], "")
				Else
					cDescri := aRetBTU[3]
				EndIf
			Else
				PlsPtuLog("  - Falha ao realizar o De-para do item: "+Alltrim(cCodigo)+" ["+Time()+"]", LOGSISPAC)
				lRetorno := .F.
				Return lRetorno
			EndIf

			nQuanti	:= IIF(ValType(oPackage["detalhes"][nNy]["qt_servico"]) <> "U", oPackage["detalhes"][nNy]["qt_servico"], 0)
			nValorUn := IIF(ValType(oPackage["detalhes"][nNy]["vl_servico"]) <> "U", oPackage["detalhes"][nNy]["vl_servico"], 0)
			nValorTotal := IIF(ValType(oPackage["detalhes"][nNy]["vl_total"]) <> "U", oPackage["detalhes"][nNy]["vl_total"], 0)

			cTipo := PLSTpComp(cTipo)

			If nValorUn == 0
				If nQuanti < 1
					nValorUn := nValorTotal
					nQuanti := 1
				Else
					nValorUn := nValorTotal/nQuanti
				EndIf
			Else
				If nQuanti < 1
					nValorUn *= nQuanti
					nQuanti := 1
				EndIf
			EndIf

			nValorUn := Round(nValorUn,2)

			If lB43Quantidade
				aAdd(aDadB43,{	{"B43_SEQUEN", cSequen},;
					{"B43_CODPAD", cCodPad},;
					{"B43_CODPRO", cCodPro},;
					{"B43_DESPRO", cDescri},;
					{"B43_VALFIX", nValorUn},;
					{"B43_QTDPRO", nQuanti},;
					{"B43_PRINCI", "0"},;
					{"B43_TIPO"  , cTipo},;
					{"B43_CODOPE", cCodOpe},;
					{"B43_CODLDP", cCodLpd},;
					{"B43_CODPEG", cCodPeg},;
					{"B43_NUMERO", cNumGui},;
					{"B43_ORIMOV", cOriMov},;
					{"B43_NIVPAC", "B6L"}})
				nVlrB43 += nValorUn * nQuanti

				SomaItensTipo(cTipo, (nValorUn * nQuanti), @nTotMaterial, @nTotMedicamento, @nTotTaxasGases, @nTotOPME)

				PlsPtuLog("   -> Procedimento: "+cCodPro+" ["+Time()+"]", LOGSISPAC)
				PlsPtuLog("   -> Valor: "+cValtoChar(nValorUn)+" ["+Time()+"]", LOGSISPAC)
				PlsPtuLog("   -> Valor acumulado: "+cValtoChar(nVlrB43)+" ["+Time()+"]", LOGSISPAC)
			Else
				For nNz := 1 To nQuanti
					aAdd(aDadB43,{	{"B43_SEQUEN", cSequen},;
						{"B43_CODPAD", cCodPad},;
						{"B43_CODPRO", cCodPro},;
						{"B43_DESPRO", cDescri},;
						{"B43_VALFIX", nValorUn},;
						{"B43_PRINCI", "0"},;
						{"B43_TIPO"  , cTipo},;
						{"B43_CODOPE", cCodOpe},;
						{"B43_CODLDP", cCodLpd},;
						{"B43_CODPEG", cCodPeg},;
						{"B43_NUMERO", cNumGui},;
						{"B43_ORIMOV", cOriMov},;
						{"B43_NIVPAC", "B6L"}})
					nVlrB43 += nValorUn

					SomaItensTipo(cTipo, nValorUn, @nTotMaterial, @nTotMedicamento, @nTotTaxasGases, @nTotOPME)

					PlsPtuLog("   -> Procedimento: "+cCodPro+" ["+Time()+"]", LOGSISPAC)
					PlsPtuLog("   -> Valor: "+cValtoChar(nValorUn)+" ["+Time()+"]", LOGSISPAC)
					PlsPtuLog("   -> Valor acumulado: "+cValtoChar(nVlrB43)+" ["+Time()+"]", LOGSISPAC)

				Next nNz
			EndIf

		Next nNy

		If Len(oPackage["detalhes"]) == 0
			lComposicao := .F.
			PlsPtuLog("  - Pacote não possui composição cadastrada no SISPAC. ["+Time()+"]", LOGSISPAC)
		EndIf

		cNomePacote := Alltrim(cCodPrinci) + " " + Alltrim(oPackage["ds_item"]) // Nome do Pacote : procedimento principal

		// Tratamento para Pacote Fechado
		lPacoteFechado := ChkPacFechado(oPackage, @aDadB43, @nVlrB43, nTotMaterial, nTotMedicamento, nTotTaxasGases, nTotOPME,;
			cSequen, cCodOpe, cCodLpd, cCodPeg, cNumGui, cOriMov)

	Else
		PlsPtuLog("  - Não foi possivel se comunicar com o SISPAC. ["+Time()+"]", LOGSISPAC)
	EndIf

	// Gravação da composição do Pacote
	If Len(aDadB43) > 0 .And. (lComposicao .Or. lPacoteFechado)
		// Verifica o valor total gravado na composição
		If cAlias <> "BD6" .and. nVlrB43 <> nVlrPacote
			PlsPtuLog("  - valor total do pacote (R$ "+cValtoChar(nVlrPacote)+") difere do somatorio dos itens (R$ "+cValtoChar(nVlrB43)+"). ["+Time()+"]", LOGSISPAC)
			lRetorno := .F.
			Return lRetorno
		EndIf

		PlsPtuLog("  - Gravando a composição do Pacote. ["+Time()+"]", LOGSISPAC)

		If nQtdPacote > 1
			aDadB43 := ReplicaComposicao(aDadB43, nQtdPacote)
		EndIf

		If PLSPTUGRV(aDadB43, aChave, "B43", lBD6)
			// Atualiza os dados do Pacote na Guia
			PlsPtuLog("  - Atualizando os dados do Pacote na Guia. ["+Time()+"]", LOGSISPAC)
			AtuGuiaPac(cPacote, cSequen, cCodPrinci, cCdPadPrinc, cNomePacote, aChave, cAlias)
			lRetorno := .T.
		EndIf
	Else
		PlsPtuLog("  - Não foi possivel realizar a gravação da composição do Pacote. ["+Time()+"]", LOGSISPAC)
	EndIf

	If !lComposicao .And. !lPacoteFechado
		lRetorno := .T.
	EndIf

	PlsPtuLog(" - Finalizado a consulta ao SisPac. ["+Time()+"]", LOGSISPAC)
	PlsPtuLog("", LOGSISPAC)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSTpComp
Altera o tipo da composição para o padrão SIGAPLS

@author Vinicius Queiros Teixeira
@since 06/10/2020
/*/
//-------------------------------------------------------------------
Static Function PLSTpComp(cTipo)

	Local cTipoRet := ""

	Default cTipo := ""

	Do Case
	Case cTipo == "1" // Taxas e Gases
		cTipoRet := "3"

	Case cTipo == "2" // Diárias
		cTipoRet := "4"

	Case cTipo == "4" // Materiais de Consumo
		cTipoRet := "1"

	Case cTipo == "5" // Medicamentos
		cTipoRet := "2"

	Case cTipo == "6" // Procedimentos
		cTipoRet := "0"

	Case cTipo == "7" // OPME
		cTipoRet := "5"
	EndCase

Return cTipoRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetDadPrinc
Retorna os dados do tipo de tabela (CODPAD) e tipo de composição
do procedimento principal do pacote na Guia

@author Vinicius Queiros Teixeira
@since 06/10/2020
/*/
//-------------------------------------------------------------------
Static Function RetDadPrinc(cCodPrinc, cAlias, aChave, lPrestador)

	Local cQuery := ""
	Local cCodPad := ""
	Local aRetorno := {}
	Local aDadBTU := {}

	Default cCodPrinc := ""
	Default cAlias := ""
	Default aChave := {}
	Default lPrestador := .T.

	// Prestador informado na Guia
	If lPrestador
		cQuery := " SELECT R_E_C_N_O_ Recno FROM "+RetSQLName(cAlias)+" "+cAlias
		cQuery += " WHERE "+cAlias+"_FILIAL = '"+xFilial(cAlias)+"' "

		If cAlias == "BE2"
			cQuery += " AND BE2_OPEMOV = '"+aChave[1]+"' "
			cQuery += " AND BE2_ANOAUT = '"+aChave[2]+"' "
			cQuery += " AND BE2_MESAUT = '"+aChave[3]+"' "
			cQuery += " AND BE2_NUMAUT = '"+aChave[4]+"' "
		Else // cAlias: BEJ ou BQV
			cQuery += " AND "+cAlias+"_CODOPE = '"+aChave[1]+"' "
			cQuery += " AND "+cAlias+"_ANOINT = '"+aChave[2]+"' "
			cQuery += " AND "+cAlias+"_MESINT = '"+aChave[3]+"' "
			cQuery += " AND "+cAlias+"_NUMINT = '"+aChave[4]+"' "
		EndIf

		cQuery += " AND "+cAlias+"_CODPRO = '"+cCodPrinc+"' "
		cQuery += " AND "+cAlias+".D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TrbTabRef",.F.,.T.)

		If !TrbTabRef->(Eof())
			(cAlias)->(DbGoTo(TrbTabRef->Recno))
			cCodPad := &(cAlias+"->"+cAlias+"_CODPAD")

			BR8->(DbSetOrder(1))
			If BR8->(MsSeek(xFilial("BR8") + cCodPad + cCodPrinc))
				aRetorno := {BR8->BR8_CODPAD, BR8->BR8_DESCRI, IIF(Empty(BR8->BR8_TPPROC),"0",BR8->BR8_TPPROC)}
			EndIf
		EndIf

		TrbTabRef->(DbCloseArea())
	Else
		aDadBTU := PTUDePaBTU("0", cCodPrinc,, .T.)
		If Len(aDadBTU) > 0
			aRetorno := {aDadBTU[1], aDadBTU[3], "0"} // 0 = Procedimento
		EndIf
	EndIf

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuGuiaPac
Atualiza a Guia do Pacote com as informações do SISPAC

@author Vinicius Queiros Teixeira
@since 06/10/2020
/*/
//-------------------------------------------------------------------
Static Function AtuGuiaPac(cPacote, cSequen, cCodPrinc, cCdPadPrinc, cNomePacote, aChave, cAlias)

	Local cQuery := ""

	cQuery := " SELECT R_E_C_N_O_ Recno FROM "+ RetSQLName(cAlias)+" "+cAlias
	cQuery += " WHERE "+cAlias+"_FILIAL = '"+xFilial(cAlias)+"' "

	If cAlias == "BE2"
		cQuery += " AND BE2_OPEMOV = '"+aChave[1]+"' "
		cQuery += " AND BE2_ANOAUT = '"+aChave[2]+"' "
		cQuery += " AND BE2_MESAUT = '"+aChave[3]+"' "
		cQuery += " AND BE2_NUMAUT = '"+aChave[4]+"' "

	Elseif cAlias == "BD6"
		cQuery += " AND BD6_CODOPE = '"+aChave[1]+"' "
		cQuery += " AND BD6_CODLDP = '"+aChave[2]+"' "
		cQuery += " AND BD6_CODPEG = '"+aChave[3]+"' "
		cQuery += " AND BD6_NUMERO = '"+aChave[4]+"' "
		cQuery += " AND BD6_ORIMOV = '"+aChave[5]+"' "

	Else // cAlias: BEJ ou BQV
		cQuery += " AND "+cAlias+"_CODOPE = '"+aChave[1]+"' "
		cQuery += " AND "+cAlias+"_ANOINT = '"+aChave[2]+"' "
		cQuery += " AND "+cAlias+"_MESINT = '"+aChave[3]+"' "
		cQuery += " AND "+cAlias+"_NUMINT = '"+aChave[4]+"' "
	EndIf

	cQuery += " AND "+cAlias+".D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TrbAlias",.F.,.T.)

	If !TrbAlias->(Eof())
		While !TrbAlias->(Eof())

			(cAlias)->(DbGoTo(TrbAlias->Recno))

			// Procedimento Principal marca como Pacote 'Sim' na Guia
			If &(cAlias+"->"+cAlias+"_CODPAD") == Alltrim(cCdPadPrinc) .And. Alltrim(&(cAlias+"->"+cAlias+"_CODPRO")) == Alltrim(cCodPrinc)
				&(cAlias+"->(Reclock('"+cAlias+"',.F.))")
				&(cAlias+"->"+cAlias+"_PACOTE") := "1" // Sim
				&(cAlias+"->( MsUnLock() )")
			EndIf

			// No item do Pacote marca o codigo 'real' e o nome do pacote
			// Não troco o código do pacote no BD6 pois tenho que respeitar o que veio no A500 para contestar no A550
			If cAlias <> "BD6" .and. &(cAlias+"->"+cAlias+"_SEQUEN") == cSequen
				&(cAlias+"->(Reclock('"+cAlias+"',.F.))")
				&(cAlias+"->"+cAlias+"_CDPACO") := cPacote
				&(cAlias+"->"+cAlias+"_DESPAC") := cNomePacote
				&(cAlias+"->( MsUnLock() )")
			EndIf

			TrbAlias->(DbSkip())
		EndDo
	EndIf

	TrbAlias->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PTUPACJOB
JOB para processar e gravar a composição do Pacote Recebido - PTU Online

@author  Vinicius Queiros Teixeira
@version P12
@since   19/10/2020
/*/
//-------------------------------------------------------------------
Function PTUPACJOB(cEmp, cFil, cCodOpera, cGuiaPacote)

	Default cCodOpera := ""
	Default cGuiaPacote := ""

	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,,'PLS')

	PlsPtuLog("[Iniciando JOB] " + Time(), LOGSISPAC)

	PTUONPAC(cCodOpera,cGuiaPacote)

	PlsPtuLog("[Finalizando JOB] " + Time(), LOGSISPAC)
	PlsPtuLog(Replicate('*',50),LOGSISPAC)
	PlsPtuLog("",LOGSISPAC)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReplicaComposicao
Replica a composição do pacote de acordo com a quantidade informada
no PTU Online (QT_SERVICO)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 25/03/2021
/*/
//-------------------------------------------------------------------
Static Function ReplicaComposicao(aDadosB43, nQtdPacote)

	Local nX := 0
	Local nY := 0
	Local aDados := aClone(aDadosB43)

	For nX := 1 To (nQtdPacote - 1)

		For nY := 1 To Len(aDados)
			aAdd(aDadosB43, aDados[nY])
		Next nY

	Next nX

Return aDadosB43

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPacoteSISPAC
Retorna a composição do Pacote Autorizado no SISPAC para gravar a
tabela B43

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 12/05/2021
/*/
//-------------------------------------------------------------------
Static Function GetPacoteSISPAC(cOpeMov, cUniOri, cPacote, cCodRda, dDtAtendi, aAutomacao)

	Local aPacote := {}
	Local cDataReferencia := ""
	Local oRestClient := Nil
	Local aRetorno := {}
	Local aAuxRetorno := {}
	Local nTotPag := 0
	Local nPagina := 0
	Local nX := 0
	Local nY := 0
	Local nPosPacote := 0

	Default aAutomacao := {}

	cDataReferencia := DTOS(dDtAtendi)
	cDataReferencia	:= Substr(cDataReferencia,1,4)+"-"+Substr(cDataReferencia,5,2)+"-"+Substr(cDataReferencia,7,2) // Formatado YYYY-MM-DD

	PlsPtuLog("  - Consultando WebService de Pacotes. ["+Time()+"]", LOGSISPAC)
	oRestClient := PLSPTUSISPAC():New(cOpeMov)

	If Len(aAutomacao) > 0
		oRestClient:setAutoma(aAutomacao[1])
		oRestClient:setRespJson(aAutomacao[2])
	EndIf

	aRetorno := oRestClient:consultapacote(cUniOri, cPacote,,,,,, cDataReferencia, Alltrim(cCodRda),, nTotPag, 15)

	If aRetorno[1]
		// Ordena a composição de maior valor quando houver mais de um Pacote no Retorno (Paginação 1)
		If Len(aRetorno[8]) > 1
			ASORT(aRetorno[8], , , { | x,y | x[25] > y[25] } )
		EndIf

		If Len(aRetorno[8]) > 0
			For nX := 1 To Len(aRetorno[8])
				// Pacote com o Status Aprovado, Aprovado com ressalva e Publicado sem Aprovação
				If aRetorno[8][nX][10] == 2 .Or. aRetorno[8][nX][10] == 3 .Or. aRetorno[8][nX][10] == 1
					aPacote := aClone(aRetorno[8][nX])
					Exit
				EndIf
			Next nX
		EndIf

		// Se houver mais pacotes em outras paginas (limite de 15 pacotes por pagina)
		If aRetorno[5] > 15
			// Calcula mais quantas paginas terá a consulta
			nPagina := Int(aRetorno[5]/15) - 1
			nPagina += IIF((aRetorno[5]/15) - Int(aRetorno[5]/15) > 0, 1, 0)

			For nX := 1 To nPagina
				aAuxRetorno := {}
				nPosPacote := 0
				nTotPag += 15
				aAuxRetorno := oRestClient:consultapacote(cUniOri, cPacote,,,,,, cDataReferencia, Alltrim(cCodRda),, nTotPag, 15)

				If aAuxRetorno[1] .And. Len(aAuxRetorno[8]) > 0
					ASORT(aAuxRetorno[8], , , { | x,y | x[25] > y[25] } )

					For nY := 1 To Len(aAuxRetorno[8])
						// Pacote com o Status Aprovado, Aprovado com ressalva e Publicado sem Aprovação
						If aAuxRetorno[8][nY][10] == 2 .Or. aAuxRetorno[8][nY][10] == 3 .Or. aAuxRetorno[8][nY][10] == 1
							nPosPacote := nY
							Exit
						EndIf
					Next nY

					// Verifica se o pacote mais caro (Aprovado) dessa pagina é mais caro do que o pacote da pagina anterior (Aprovado)
					If nPosPacote > 0
						If Len(aPacote) > 0
							If aAuxRetorno[8][nPosPacote][25] > aPacote[25]
								aPacote := aClone(aAuxRetorno[8][nPosPacote])
							EndIf
						Else
							aPacote := aClone(aAuxRetorno[8][nPosPacote])
						EndIf
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

	FreeObj(oRestClient)
	oRestClient := Nil

Return aPacote

//-------------------------------------------------------------------
/*/{Protheus.doc} GetChavePeg
Retorna a chave da Peg referente ao faturamento para gravar na B43

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 12/05/2021
/*/
//-------------------------------------------------------------------
Static Function GetChavePeg(aChave)

	Local aChavePeg := {}
	Local cQuery := ""
	Local cAlias := ""

	cQuery := " SELECT BEA_CODLDP,BEA_CODPEG,BEA_NUMGUI,BEA_ORIMOV FROM " + RetSQLName("BEA") + " BEA "
	cQuery += " WHERE BEA.BEA_FILIAL = '"+xFilial("BEA")+"' "
	cQuery += "   AND BEA.BEA_OPEMOV = '"+aChave[1]+"' "
	cQuery += "   AND BEA.BEA_ANOAUT = '"+aChave[2]+"' "
	cQuery += "   AND BEA.BEA_MESAUT = '"+aChave[3]+"' "
	cQuery += "   AND BEA.BEA_NUMAUT = '"+aChave[4]+"' "
	cQuery += "   AND BEA.D_E_L_E_T_ = ' ' "

	cAlias := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)

	If (cAlias)->(!Eof())
		aChavePeg := { PlsIntPad(), (cAlias)->BEA_CODLDP, (cAlias)->BEA_CODPEG, (cAlias)->BEA_NUMGUI, (cAlias)->BEA_ORIMOV }
	EndIf

	(cAlias)->(DbCloseArea())

Return aChavePeg


//-------------------------------------------------------------------
/*/{Protheus.doc} SomaItensTipo
Soma os itens por tipo de composição

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 12/06/2021
/*/
//-------------------------------------------------------------------
Static Function SomaItensTipo(cTipo, nValor, nTotMaterial, nTotMedicamento, nTotTaxasGases, nTotOPME)

	Do Case
	Case cTipo == "1" // Materiais
		nTotMaterial += nValor

	Case cTipo == "2" // Medicamentos
		nTotMedicamento += nValor

	Case cTipo == "3" // Taxas e Gases
		nTotTaxasGases += nValor

	Case cTipo == "5" // OPME
		nTotOPME += nValor
	EndCase

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ChkPacFechado
Verifica se o pacote possui itens "Fechado".
(Valores por tipo de composição que constam no pacote mais não estão
detalhados na composição)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 12/06/2021
/*/
//-------------------------------------------------------------------
Static Function ChkPacFechado(oPackage, aDadB43, nVlrB43, nTotMaterial, nTotMedicamento, nTotTaxasGases, nTotOPME,;
		cSequen, cCodOpe, cCodLpd, cCodPeg, cNumGui, cOriMov)

	Local lRetorno := .F.
	Local cCodMedGen := GetNewPar("MV_PLMEDPT","")
	Local cCodMatGen := GetNewPar("MV_PLMATPT","")
	Local cCodTaxGen := GetNewPar("MV_PLTAXPT","")
	Local cCodOpmGen := GetNewPar("MV_PLOPMPT","")
	Local nX := 0
	Local nVlMaterial := 0
	Local nVlMedicamento := 0
	Local nVlOPME := 0
	Local nVlTaxasGases := 0
	Local aDados := {}
	Local aRetBTU := {}
	Local cTpTabela := ""
	Local cTpComposicao := ""
	Local cCodigo := ""
	Local cCodPad := ""
	Local cDescricao := ""
	Local nValor := 0
	Local aDadosCod := {}

	nVlMaterial := IIF(!Empty(oPackage["vl_mat"]), oPackage["vl_mat"], 0)
	nVlMedicamento := IIF(!Empty(oPackage["vl_med"]), oPackage["vl_med"], 0)
	nVlOPME := IIF(!Empty(oPackage["vl_opme"]), oPackage["vl_opme"], 0)
	nVlTaxasGases := IIF(!Empty(oPackage["vl_tax_gas"]), oPackage["vl_tax_gas"], 0)

	// aDados[x][1] = Valor dos Itens no SISPAC
	// aDados[x][2] = Valor Totalizado na Composição
	// aDados[x][3] = Codigo Generico da Composição
	// aDados[x][4] = Tipo da Composição
	// aDados[x][5] = Tipo da Tabela

	aAdd(aDados, {nVlMaterial, nTotMaterial, cCodMatGen, "1", "2"})
	aAdd(aDados, {nVlMedicamento, nTotMedicamento, cCodMedGen, "2", "3"})
	aAdd(aDados, {nVlOPME, nTotOPME, cCodOpmGen, "5", "2"})
	aAdd(aDados, {nVlTaxasGases, nTotTaxasGases, cCodTaxGen, "3", "1"})

	For nX := 1 To Len(aDados)

		If aDados[nX][1] <> 0 .And. aDados[nX][1] > aDados[nX][2]

			cCodigo := aDados[nX][3]
			cTpComposicao := aDados[nX][4]
			cTpTabela := aDados[nX][5]
			nValor := aDados[nX][1] - aDados[nX][2]

			If AT(",", cCodigo) // Quando houver mais de um código no Generico
				aDadosCod := StrTokArr(cCodigo, ",")
				If Len(aDadosCod) > 0
					cCodigo := Alltrim(aDadosCod[1])
				EndIf
			EndIf

			aRetBTU := PTUDePaBTU(cTpTabela, cCodigo,, .T.)

			If Len(aRetBTU) > 0
				cCodPad := aRetBTU[1]
				cDescricao := aRetBTU[3]
			Else
				PlsPtuLog("  - Falha ao realizar o De-para do item: "+Alltrim(cCodigo)+" ["+Time()+"]", LOGSISPAC)
				lRetorno := .F.
				Return lRetorno
			EndIf

			aAdd(aDadB43,{ 	{"B43_SEQUEN", cSequen},;
				{"B43_CODPAD", cCodPad},;
				{"B43_CODPRO", cCodigo},;
				{"B43_DESPRO", cDescricao},;
				{"B43_VALFIX", nValor},;
				{"B43_QTDPRO", 1},;
				{"B43_PRINCI", "0"},;
				{"B43_TIPO"  , cTpComposicao},;
				{"B43_CODOPE", cCodOpe},;
				{"B43_CODLDP", cCodLpd},;
				{"B43_CODPEG", cCodPeg},;
				{"B43_NUMERO", cNumGui},;
				{"B43_ORIMOV", cOriMov},;
				{"B43_NIVPAC", "B6L"}})
			nVlrB43 += nValor
			lRetorno := .T.
		EndIf
	Next nX

Return lRetorno

/*/{Protheus.doc} getPackageSispac
Retorna pacote mais caro encontrado no SISPAC de acordo com os parametros informados

@type function
@version 12.1.2410  
@author vinicius.queiros
@since 12/01/2024
@return json, pacote encontrado no sispac
/*/
static function getPackageSispac(cHealthInsurerCode, cCdUniOri, cCdPacote, cCdPrest, dDtReferencia, aAutomacao)

	local nPages as numeric
	local nX as numeric
	local nY as numeric
	local nPosPackage as numeric
	local oPackage as object
	local oSispac as object
	local oResponse as object
	local nPageSize := 15 as numeric

	default aAutomacao := {}

	plsPtuLog("  - Consultando WebService de Pacotes. ["+time()+"]", LOGSISPAC)

	oSispac := totvs.protheus.health.plan.unimed.PackageSISPAC():new(cHealthInsurerCode)

	oSispac:setPageSize(nPageSize)
	oSispac:setJsonRequest("cd_uni_ori", cCdUniOri, "C")
	oSispac:setJsonRequest("cd_pacote", cCdPacote, "C")
	oSispac:setJsonRequest("dt_referencia", dDtReferencia, "D")
	oSispac:setJsonRequest("cd_prest", cCdPrest, "C")

	if len(aAutomacao) > 0
		oSispac:setRobotTest(aAutomacao[2])
	endif

	if oSispac:packagesQuery()
		oResponse := oSispac:getJsonResponse()

		// Ordena a composição de maior valor quando houver mais de um Pacote no Retorno (Paginação 1)
		if len(oResponse["items"]) > 1
			aSort(oResponse["items"], , , { | x,y | x["vl_pacote"] > y["vl_pacote"] } )
		endif

		if len(oResponse["items"]) > 0
			for nX := 1 to len(oResponse["items"])
				// Pacote com o Status Aprovado, Aprovado com ressalva e Publicado sem Aprovação
				if oResponse["items"][nX]["st_pacote"] == 2 .or. oResponse["items"][nX]["st_pacote"] == 3 .or. oResponse["items"][nX]["st_pacote"] == 1
					oPackage := oResponse["items"][nX]
					exit
				endif
			next nX
		endif

		// Se houver mais pacotes em outras paginas
		if oResponse["hasNext"]
			nPages := int(oResponse["remainingRecords"] + nPageSize / nPageSize) // Calcula mais quantas paginas terá a consulta

			for nX := 2 to nPages
				nPosPackage := 0

				oSispac:setPage(nX)
				if oSispac:packagesQuery()
					if len(oResponse["items"]) > 1
						aSort(oResponse["items"], , , { | x,y | x["vl_pacote"] > y["vl_pacote"] } )
					endif

					for nY := 1 to len(oResponse["items"])
						// Pacote com o Status Aprovado, Aprovado com ressalva e Publicado sem Aprovação
						if oResponse["items"][nY]["st_pacote"] == 2 .or. oResponse["items"][nY]["st_pacote"] == 3 .or. oResponse["items"][nY]["st_pacote"] == 1
							nPosPackage := nY
							exit
						endif
					next nY

					// Verifica se o pacote mais caro (Aprovado) dessa pagina é mais caro do que o pacote da pagina anterior (Aprovado)
					if nPosPackage > 0
						oPackage := iif(valType(oPackage) == "J",;
							iif(oResponse["items"][nPosPackage]["vl_pacote"] > oPackage["vl_pacote"],;
							oResponse["items"][nPosPackage],;
							oPackage),;
							oResponse["items"][nPosPackage])
					endif
				endif
			next nX
		endif
	endif

	oSispac:destroy()

	freeObj(oSispac)
	freeObj(oResponse)

return oPackage
