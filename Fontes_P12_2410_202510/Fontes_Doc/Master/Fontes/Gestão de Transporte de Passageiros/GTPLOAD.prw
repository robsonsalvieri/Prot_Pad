#INCLUDE 'PROTHEUS.CH'
#Include 'FWMVCDef.ch'
#INCLUDE 'GTPLOAD.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPLOAD()
Função responsavel para carragmento de dados no momento da abertura do modulo

@sample	GTPLOAD()

@return	null

@author		jacomo.fernandes 
@since		05/07/2017
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Function GTPLOAD()
			
	//Cria parametros do módulo
    If GTPxVldDic('GYF')
	    FwMsgRun( ,{||LoadParamRules()},,STR0001)//"Verificando parametros do Modulo..."
    Endif
	
	//Cria tipos de recursos
    If GTPxVldDic('GYK')
	    FwMsgRun( ,{|| LoadTiposRecursos()},,STR0061)//"Verificando tipos de recursos..."
    Endif

	//Carrega tabela para uso na carta de correç?o de CTE OS
    IF GTPxVldDic('G53')
	    FwMsgRun( ,{||GTPA712LOA()},,STR0064)	// "Carregando tabela de tags CT-e OS..." 
    Endif

	//Atualiza Status do campo G59_STAPRO
	If G59->(FieldPos('G59_STAPRO')) > 0
		FwMsgRun( ,{|| LoadStG59()},,STR0158)//"Verificando status fechamento..."
	EndIf

	//Atualiza Status do campo H6V_TIPCAL
	If H6V->(FieldPos('H6V_TIPCAL')) > 0
		FwMsgRun( ,{|| LoadTipcal()},,STR0158)//"Verificando tipo de calculo da linha..."
	EndIf

    IF GTPxVldDic('H86')
	    FwMsgRun( ,{||CompTableH86()},,STR0159)	// 'Verificando Receitas/Depesas X Tipos de linha' 
    Endif


Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadParamRules()
Função responsavel para criação de parametros de módulo

@sample	LoadParamRules()

@return	null

@author		jacomo.fernandes
@since		05/07/2017
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Function LoadParamRules()
//	GTPSetRules(cParameter	, cDataType	, cPicture	, cContent			,cGroupFunc		, cDescription		, cF3, cSeekFil, nOperation)
	GTPSetRules("FILRMD"	, "1"		,""			,FWCodFil()			, "GTPR428"		, STR0003+FwCodEmp(),"")	//"Filial Centralizadora (MATRIZ) Emp:"
	GTPSetRules("VRBCOMISSN", "1"		,""			,"" 				, "GTPA418"		, STR0004			,"")	//"Código da verba referente a comissão Mês"		
	GTPSetRules("VRBCOMIDSR", "1"		,""			,"" 				, "GTPA418"		, STR0005			,"")	//"Código da verba ref DSR sobre comissão"		
	GTPSetRules("BASECOMCTR", "1"		,"@!"		,"1" 				, "GTPA418"		, STR0006			,"")	//"1=NF Agência|2=NF Vend.|3=Bx.Tit.Vend."		
	GTPSetRules("LISTACARGO", "1"		,""			,""					, "GTPA008"		, STR0007			,"SQ3")	//"Cargos de funcionários separados por ;"		
	GTPSetRules("LISTAFUNCA", "1"		,""			,""					, "GTPA008"		, STR0008			,"SRJ")	//"Funções de funcionários separadas por ;"		
	GTPSetRules("GTPEXIBTOT", "3"		,""			,".T." 				, "GTPA302"		, STR0009			,"")	//"Exibe totalizadores-escala colaborador"		
	GTPSetRules("VRBAGCOMSN", "1"		,"@!"		,""					, "GTPA410"		, STR0012			,"SRV")	//"Verba ref.comissão responsável Agência."		
	GTPSetRules("VRBAGCMDSR", "1"		,"@!"		,""					, "GTPA410"		, STR0013			,"SRV")	//"Verba ref DSR s/comissão responsável Ag"		
	GTPSetRules("PREFTITFOR", "1"		,""			,""					, "GTPA410"		, STR0014			,"")	//"Prefixo Titulo pagar p/Ag.Terceirizada"		
	GTPSetRules("TIPOTITFOR", "1"		,""			,""					, "GTPA410"		, STR0015			,"05")	//"Tipo do Titulo pagar p/Ag.Terceirizada"		
	GTPSetRules("NATUTITFOR", "1"		,""			,""					, "GTPA410"		, STR0016			,"SED")	//"Natureza Tit. pagar p/Ag.Terceirizada"		
	GTPSetRules("CDPGTITFOR", "1"		,""			,""					, "GTPA410"		, STR0017			,"SE4")	//"Cond.Pgto.Tit. pagar p/Ag.Terceirizada"		
	GTPSetRules("HISTTITFOR", "1"		,""			,""					, "GTPA410"		, STR0019			,"")	//"Histórico Tit. pagar p/Ag.Terceirzada"		
	GTPSetRules("QTDHRDIA"	, "1"		,"@R 99:99"	,"0800"				, "GTPA302"		, STR0020			,"")	//"QTD. HR. MAX. ESCALA COLABORADOR"				
	GTPSetRules("BLQHRDIA"	, "3"		,""			,".F."				, "GTPA302"		, STR0021			,"")	//"LIMITE HRS BLOQUEIA ESCALA COLABORADOR"		
	GTPSetRules("MONITTIMER", "3"		,""			,".F."				, "GTPC300"		, STR0022			,"")	//"SALVAMENTO AUTOMATICA MONITOR"				
	GTPSetRules("MONITQTDTM", "2"		,"@E 99"	,"15"				, "GTPC300"		, STR0023			,"")	//"TEMPO (SEGUNDOS) SALV. AUT. MONITOR"			
	GTPSetRules("SERIRMD"	, "1"		,""			,FwCodEmp()			, "GTPA500"		, STR0024			,"")	//"Serie utilizada para RMD"						
	GTPSetRules("NATUPAG"	, "1"		,""			,""					, "GTPA700"		, STR0025			,"SED")	//"Natureza para titulo a pagar"					
	GTPSetRules("NATUREC"	, "1"		,""			,""					, "GTPA700"		, STR0026			,"SED")	//"Natureza para titulo a receber"				
	GTPSetRules("BANCOBX"	, "1"		,""			,""					, "GTPA700"		, STR0027			,"")	//"banco para baixar titulo."					
	GTPSetRules("PRODTAR"	, "1"		,""			,""					, "GTPJ001"		, STR0028			,"SB1")	//"Produto utilizado para tarifa"				
	GTPSetRules("PRODTAX"	, "1"		,""			,""					, "GTPJ001"		, STR0029			,"SB1")	//"Produto utilizado para taxa"					
	GTPSetRules("PRODPED"	, "1"		,""			,""					, "GTPJ001"		, STR0030			,"SB1")	//"Produto utilizado para pedágio"				
	GTPSetRules("PROSGFACU"	, "1"		,""			,""					, "GTPJ001"		, STR0031			,"SB1")	//"Produto utilizado Seguro Facultativo"			
	GTPSetRules("PROUTTOT"	, "1"		,""			,""					, "GTPJ001"		, STR0032			,"SB1")	//"Produto utilizado para outros totais"			
	GTPSetRules("ESPECF"	, "1"		,""			,"BPECF"			, "GTPJ001"		, STR0035			,"")	//"Especie para bilhete ECF"						
	GTPSetRules("IDPOLTRONA", "1"		,""			,""					, "GTPA600"		, STR0036			,"")	//"ID DA CARACTERISTICA POLTRONA"				
	GTPSetRules("NATUREZA"	, "1"		,"@!"		,""					, "GTPA421"		, STR0037			,"SED")	//"Código Natureza p/ geração Titulo"			
	GTPSetRules("CTACTBL"	, "1"		,"@!"		,"" 				, "GTPA500"		, STR0042			,"CT1")	//"CONTA CONTÁBIL PARA RMD"						
	GTPSetRules("GERNFDTINI", "1"		,"@D"		,"" 				, "GTPJ001"		, STR0043			,"")	//"Data Inicial para geração de notas"			
	GTPSetRules("GERNFDTFIM", "1"		,"@D"		,"" 				, "GTPJ001"		, STR0044			,"")	//"Data final para geração de notas"				
	GTPSetRules("GERNFAGENC", "1"		,"@!"		,"" 				, "GTPJ001"		, STR0045			,"GI6")	//"Lista de agencias para geração de notas "		
	GTPSetRules("GERNFSERDV", "1"		,""			,"" 				, "GTPJ001"		, STR0046			,"01")	//"Numero da Série da NFE de devolução"			
	GTPSetRules("TIPOESCEXT", "1"		,""			,"" 				, "GTPC300"		, STR0047			,"GZS")	//"Informa o tipo de Escala Extraordinária"		
	GTPSetRules("XMLCONFRJ"	, "1"		,""			,"rjintegra\conf"	, "GTPRJINTEG"	, STR0048			,"")	//"Informa o local do arquivo xml de config"		
	GTPSetRules("TPSRVMNT"	, "1"		,""			,"REV" 				, "GTPA409"		, STR0049			,"ST4")	//"Informa o tipo de serviço da manutenção"		
	GTPSetRules("TPCARDCRED", "1"		,""			,"CC" 				, "GTPA700L"	, STR0051			,"")	//"Informa  tipo titulo para Cartão Credito"	
	GTPSetRules("TPCARDDEBI", "1"		,""			,"CD" 				, "GTPA700L"	, STR0052			,"")	//"Informa  tipo titulo para Cartão Debito"		
	GTPSetRules("TPCARDPARC", "1"		,""			,"CP" 				, "GTPA700L"	, STR0053			,"")	//"Informa  tipo titulo para Cartão Parcela"		
	GTPSetRules("DIVCOMNEG" , "1"		,""			,"  " 				, "GTPA113"	    , STR0063       	,"")	//"Infomar o Tipo de Verba"
    GTPSetRules("TXCONVENIE", "1"		,"@!"		,"  " 				, "GTPA421"		, STR0066       	,"")	//"Contrapartida de taxas (separados por ;)" 
	GTPSetRules("INTTIMEOUT", "2"		,""  		,"120"  			, "GTPA421"		, STR0067       	,"")	//"Informe o Tempo de TimeOut em Segundos"
    GTPSetRules("SERIECTE"  , "1"		,"@R 999"	,"  "  			    , "GTPA801"		, STR0068           ,"01")	//"Informa a serie do CTE" 
    GTPSetRules("SERDEVCTE" , "1"		,"@R 999"	,"  "  			    , "GTPA801"		, STR0069           ,"01")	//"Informa a serie de devolução do CTE" 	
	GTPSetRules("RETSTAEVEN", "2"		,""	        ,""  			    , "GTPA801C"    , STR0070           ,"")	//"Tempo para Retorno do Envio do CTE" 
	GTPSetRules("SERIEMDF"  , "1"		,"@R 999"	,"  "  			    , "GTPA810"		, STR0071           ,"01")  //"Informa a serie do MDF"
	GTPSetRules("ENVIAEMAIL", "3"		,""	        ,".F." 			    , "GTPA814"		, STR0072           ,"")    //"Informa se será enviado e-mail ou não"
	GTPSetRules("SERFATCNTR", "1"		,"@R 999"   ,"  " 			    , "GTPA819"		, STR0074,			"01")   //"Série util. fat. de contr. de encomendas"
	GTPSetRules("SERDEVCNTR", "1"		,"@R 999"   ,"  " 			    , "GTPA819"		, STR0075,			"01")   //"Série util. dev. de contr. de encomendas"
	GTPSetRules("ESPFATCNTR", "1"		,""			,"  "				, "GTPA819"		, STR0076,			"42")	//"Especie util. fat. de contr. encomendas"		
	GTPSetRules("PASTARQDOT", "1"		,""			,"  "				, "GTPR286"		, STR0077,			"")	    //"Pasta de Gravação do arquivo.dot"
	GTPSetRules("NOMEARQDOT", "1"		,""			,"  "				, "GTPR286"		, STR0078,			"")	    //"Nome do arquivo.dot"		
	GTPSetRules("ARQDOTAUTR", "1"		,""			,"autorizacao.dot"	, "GTPR113A"	, STR0079,			"")
	GTPSetRules("DIRDOTAUTR", "1"		,""			,"C:\TEMP\"			, "GTPR113A"	, STR0080,			"")
	GTPSetRules("PREFTITTES", "1"		,""			,"FCH"				, "GTPA700"		, STR0081,			"") 	//"Prefixo de título da tesouraria."
	GTPSetRules("ISENTOIMP" , "1"		,""			," "				, "GTPA281"		, STR0082,			"") 	//tipos de linhas isenção de impostos
	GTPSetRules("TPDOCEXBAG", "1"		,""			,"" 				, "GTPA117"		, STR0083,			"GYA")	//"Informa o código de documento de excesso de bagagem"
	GTPSetRules("VERSAOBPE" , "1"		,""			,"1.00" 			, "GTPA117C"	, STR0084,			"")		//"Versão BP-e"
	GTPSetRules("VERLAYBPE" , "1"		,""			,"1.00"				, "GTPA117C"	, STR0085,			"")		//"Versão Layout BP-e"
	GTPSetRules("VERLAYEVEN", "1"		,""			,"1.00"				, "GTPA117C"	, STR0086,			"")		//"Versão Layout Envento Excesso de Bagagem"
	GTPSetRules("AMBENVBPE",  "2"		,""			,"" 				, "GTPA117C"	, STR0087,			"")		//"Ambiente Envio Evento Exc.Bagagem"
	GTPSetRules("PARCONFRJ"	, "1"		,""			,"StartPath"		, "GTPRJINTEG"	, STR0088,          "")     //Parametro de busca dos arquivos
	GTPSetRules("GRVPEDORC"	, "3"		,""			,".T."				, "GTPA600"		, STR0090,          "")	    //"Gravação automática de pedágio do orçamento."
	GTPSetRules("NUMCOPIAS",  "2"		,""			,"" 				, "GTPX600R"	, STR0089,			"")		//"Numero de copias para impressão"
	GTPSetRules("XXFREFER",   "1"		,""			,"TotalBus"			, "GTPXEAI" 	, STR0091,			"")     //"Referencia da XXF"
	GTPSetRules("VALREFER",   "3"		,""			,".T."	    		, "GTPXEAI" 	, STR0092,			"")     //"Valida se utiliza a função de busca da XXF"
	GTPSetRules("GRUPOSUP",   "1"		,""			,""	 		   		, "AGEWEB" 		, STR0093,			"GRP")  //"Usuários Supervisores das Agências"  	
	GTPSetRules("PATHREST",   "1"		,""			,""		    		, "REST" 		, STR0096,			"")
	GTPSetRules("DIASBOLETO", "2"		,""			,"" 				, "GTPA421"		, STR0094,			"")		//"Numero de copias para impressão"
	GTPSetRules("PREFDEPTER", "1"		,""			,"DEP"				, "GTPA700"		, STR0095,			"") 	//"Prefixo do título de dep. terceiros"
	GTPSetRules("ISGTPPNMTA", "3"		,""			,".T."				, "GTPPNMTAB"	, STR0097,			"")
	GTPSetRules("USEENCSEG",  "3"		,""			,".T."				, "GTPA803"		, STR0098,			"")     //"Usa averbação automatica"
	GTPSetRules("ENCSEGURA",  "1"		,""			,""					, "GTPA803"		, STR0099,			"GTPDL6")//"Código seguradora averbação"
	GTPSetRules("SERIECTEOS", "1"		,"@R 999"	,"  "  			    , "GTPA850"		, STR0100,			"H61SER")	//"Informa a serie do CTEOS" 
	GTPSetRules("AJHRFINESC", "3"		,""			,".F."				, "GTPA302"		, STR0101,			"")
	GTPSetRules("SERIEMANOP", "1"		,"@R 999"	,"000" 			    , "GTPA810"		, STR0102,			"")	//"Informa a serie do Manifesto Operaciona" 
	GTPSetRules("APRVTRMOPE", "3"		,""			,".F."				, "GTPA600"		, "Habil. aprovação oper. contr. turismo",	"")
	GTPSetRules("EXTRETDOT", "1"		,"@!"		,"doc_retirada_bagagem.dot", "GTPR753"		, "Modelo .Dot do documento de Retirada",	"")
	GTPSetRules("DIREXTRET", "1"		,"@!"		,"c:\temp\"			, "GTPR753"		, "Diretório local para salvar o documento de Retirada",	"")
	GTPSetRules("REMBPREFI", "1"       ,"@!"       ,""                 , "GTPR752"     , "Prefixo do Título para Reembolso Extravio de Bagagem",   "")
	GTPSetRules("CONRETDOT", "1"		,"@!"		,"doc_retirada_conserto.dot", "GTPR756D"		, "Modelo .Dot do documento de Retirada",	"")
	GTPSetRules("DIRCONRET", "1"		,"@!"		,"c:\temp\"			, "GTPR756D"		, "Diretório local para salvar o documento de Retirada",	"")
	GTPSetRules("NATCONSERT", "1"		,"@!"		," "				, "GTPR756"			, "Natureza financeira do reembolso de conserto para o título a pagar.","SED")
	GTPSetRules("PRECONSERT", "1"		,"@!"		," "				, "GTPA756"			, "Prefixo do titulo a pagar para reembolso de conserto.","")
	GTPSetRules("TIPCONSERT", "1"		,"@!"		,"TF"				, "GTPA756"			, "Tipo do titulo a pagar para reembolso de conserto.","05")
	GTPSetRules("TIPENTREMP", "1"		,"@!"		,"TF"				, "GTPA424"			, STR0103,"05")//"Tipo do titulo a pagar para entre empresa."
	GTPSetRules("NATENTREMP", "1"		,"@!"		,"" 				, "GTPA424"			, STR0104,"SED")//"Natureza do titulo a pagar para entre empresa."
	GTPSetRules("PREENTREMP", "1"		,"@!"		,"" 				, "GTPA424"			, STR0105,"")//"Prefixo do titulo a pagar para entre empresa."
	GTPSetRules("TPVALECXA", "1"		,"@!"		,""					, "GTPA481"		    , "Tipo de vale utiliz. no caixa do colab.",	"G9A")
	GTPSetRules("VALIDVESP", "3"		,""		    ,".F."				, "GTPC300"		    , STR0106,"")//"Permite Viagens Especiais sem Validação de Pendências Financeiras."
	GTPSetRules("DECLARADOT", "1"		,"@!"		,"doc_declaracao_conteudo_responsabilidade.dot", "GTPR801"		, "Modelo .Dot declaracao de responsabilidade",	"")
	GTPSetRules("DIRDECLARA", "1"		,"@!"		,"c:\temp\"			, "GTPR801"		, "Diretório local para salvar declaracao de responsabilidade",	"")
	GTPSetRules("PERIODRM", "1"		    ,"@!"		,""					, "GTPR410"		, STR0107,	"")  //"Periodo de envio de verba RM"
	GTPSetRules("DIFERENFIC", "3"	    ,""		    ,".F."				, "GTPA421"		, STR0113,	"")  //"PERMITE GERAR TITULO C/DIF NA FICHA"
	GTPSetRules("NRTHIRJ003", "2"	    ,""		    ,"10"				, "GTPIRJ003"	, STR0114,	"")  //"Nr. threads p/proc. limitada a 40"
	GTPSetRules("NRDEXCTEOS", "2"	    ,""		    ,"7"				, "GTPT001"  	, "Dias permitido p/excl.CTEOS",	"")  //"Dias permitido p/excl.CTEOS"
	GTPSetRules("HABFRMAPGT", "3"		,""			,".F."				, "GTPIRJ115"	, STR0115,	"") //"Utiliz. Nova forma pagto nos bilhetes"
	GTPSetRules("HABINTREQ" , "3"		,""			,".F."				, "GTPIRJ115"	, STR0116,	"") //"Ativa integração de requisições de bilhetes"
	GTPSetRules("VALIDLJCLI", "3"		,""			,".F."				, "GTPIRJ115"	, STR0117,	"") //"Valida loja do cli. na integr. de requisições"
	GTPSetRules("HABEMIGIC",  "3"		,""			,".T."				, "GTPA283B"	, STR0118,	"") //"Carrega bilhetes emitidos a + de 30 dias"
	GTPSetRules("HABCTBON",   "3"		,""			,".T."				, "GTPJBPE"		, STR0119,	"") //"Contabilização online"
	GTPSetRules("SEQDESCON",   "1"		,"@!"		,"TAX|PED|SEG|OUT"	, "GTPJBPE"		, STR0120,	"") //"Seq. p/ rateio do desconto"
	GTPSetRules("HABVEIXLIN", "3"		,"" 		,".T."				, "GTPA408"		, STR0121,	"") //"Valida veiculos X linha"
	GTPSetRules("CODREGDER", "1"		,"" 		,"0001"				, "GTPM423"		, STR0122,	"") //"Registro da Empresa no Cadastro do DER"
	GTPSetRules("OPERENCOM", "1"		,"@!" 		,""				    , "GTPXNFS"		, STR0123,	"") //"Operação fiscal p/ encomendas"
	GTPSetRules("MOTBAIXA"	, "1"		,"@!"		,"NOR" 			    , "GTPU015D"	, STR0124, "F7G")	//"Motivos da baixa para despesas"
	GTPSetRules("MOTBAIXARE", "1"		,"@!"		,"NOR" 			    , "GTPU015D"	, STR0125, "F7G")	//"Motivos da baixa para receitas"
	GTPSetRules("PRFTITDEPO", "1"		,"@!"		,"DEP" 			    , "GTPU015C"	, STR0126, "")	//"Prefixo tit. deposito p/ Lancamento"
	GTPSetRules("HABBXDEPOS", "3"		,""		    ,".T." 			    , "GTPU015C"	, STR0127, "")	//"Baixa tit. deposito p/ lancamento"
	GTPSetRules("MOTVBXDEPO", "1"		,"@!"		,"NOR" 			    , "GTPU015C"	, STR0128, "")	//"Motivo Baixa tit. deposito p/ Lancamento"
	GTPSetRules("NATDEPOSIT", "1"		,"@!"		," "				, "GTPU015C"	, STR0129,"SED") //"Nat. financeira tit. deposito p/ Lancamento"
	GTPSetRules("DATAFECHAM", "3"		,"" 		,".F."				, "GTPA421"		, STR0130, "") //"Utiliz. tag dataFechamento p/ficha de remessa"	
	GTPSetRules("PRFTITESTO", "1"		,"@!"		,"EST" 			    , "GTPU015C"	, STR0131, "")	//"Prefixo tit. deposito p/ estorno"
	GTPSetRules("HABBXESTOR", "3"		,""		    ,".T." 			    , "GTPU015C"	, STR0132, "")	//"Baixa tit. deposito p/ estorno"
	GTPSetRules("MOTVBXESTO", "1"		,"@!"		,"NOR" 			    , "GTPU015C"	, STR0133, "")	//"Motivo Baixa tit. deposito p/ Estorno"
	GTPSetRules("NATESTORNO", "1"		,"@!"		," "				, "GTPU015C"	, STR0134,"SED") //"Nat. financeira tit. deposito p/ Estorno"
	GTPSetRules("DIFPLANILH", "3"		,"" 		,".F."				, "GTPA801"		, STR0135, "") //"Permite dif. vlr. serv. c/calculo planilha."	
	GTPSetRules("HISTDEPOSI", "1"		,"@!" 		,""				    , "GTPU015C"	, STR0136, "") //"Historico titulo deposito"	
	GTPSetRules("VALIDMANUT", "3"		,""			,".F." 			    , "WSGTP000"	, STR0137, "")	//"Valida veiculos em manutenção (Urbano - integração com MNT)"
	GTPSetRules("VALIDRH"	, "3"		,""			,".F." 			    , "WSGTP000"	, STR0138, "")	//"Valida situação do RH motorista  (Urbano - integração com RH)"
	GTPSetRules("FILTITCART", "1"		,"@!" 		,""				    , "GTPJ002"	    , STR0139, "SM0") //"Filial conciliação titulo cartao crédito"	
	GTPSetRules("HABESTFCH"	, "3"		,""			,".F." 			    , "GTPA421"	    , STR0140, "")	//"Habilita Deposito de estorno na ficha"
	GTPSetRules("PRFTITENV", "1"		,"@!"		,"" 			    , "GTPA421"		, STR0141, "")	//"Prefixo tit. estorno p/ envelope"
	GTPSetRules("NATTITENV", "1"		,"@!"		," "				, "GTPA421"		, STR0142,"SED") //"Natureza tit. estorno p. envelope"
	GTPSetRules("PRFTITCAI", "1"		,"@!"		,"" 			    , "GTPA421"		, STR0143, "")	//"Prefixo tit. estorno p/ caixa"
	GTPSetRules("NATTITCAI", "1"		,"@!"		," "				, "GTPA421"		, STR0144,"SED") //"Natureza tit. estorno p. caixa"
	GTPSetRules("PRFTITTRA", "1"		,"@!"		,"" 			    , "GTPA421"		, STR0145, "")	//"Prefixo tit. estorno p/ transf."
	GTPSetRules("NATTITTRA", "1"		,"@!"		," "				, "GTPA421"		, STR0146,"SED") //"Natureza tit. estorno p. transf."
	GTPSetRules("PRFTITBOL", "1"		,"@!"		,"" 			    , "GTPA421"		, STR0147, "")	// "Prefixo tit. estorno p/ boleto"
	GTPSetRules("NATTITBOL", "1"		,"@!"		," "				, "GTPA421"		, STR0148,"SED") //"Natureza tit. estorno p. boleto"
	GTPSetRules("PRFTITGTV", "1"		,"@!"		,"" 			    , "GTPA421"		, STR0149, "")	//"Prefixo tit. estorno p/ GTV"
	GTPSetRules("NATTITGTV", "1"		,"@!"		," "				, "GTPA421"		, STR0150,"SED") //"Natureza tit. estorno p. GTV"
	GTPSetRules("PRFTITPIX", "1"		,"@!"		,"" 			    , "GTPA421"		, STR0151, "")	//"Prefixo tit. estorno p/ PIX"
	GTPSetRules("NATTITPIX", "1"		,"@!"		," "				, "GTPA421"		, STR0152,"SED") //"Natureza tit. estorno p. PIX"
	GTPSetRules("HABINTBORI", "3"		,""			,".F." 			    , "GTPJBPE"	    , STR0153, "")	//"Habilita integra. de Bilh. origem"
	GTPSetRules("TPCARDPIX", "1"		,""			,"PX" 				, "GTPJ002"	    , STR0154,"")	//"Informa  tipo titulo para PIX"		
	GTPSetRules("HABREPROH", "3"		,""			,".F." 				, "GTPU015C"    , STR0155,"")	//"Hab. reproduzir hist. Deposito ao titulo"	
	GTPSetRules("VALIDREACX", "3"		,""			,".F." 			    , "GTPA700"	    , STR0156, "")	//"Valida data na reabertura do caixa"		
	GTPSetRules("HABFILUSR", "3"		,""			,".F." 			    , "GTPA500"	    , STR0157, "")	//"Habilita filtro browse por usr. rotina Fech.Arrecadação"		

Return

/*/{Protheus.doc} LoadTiposRecursos
	Função responsavel para criação automática dos tipos padrões de recursos
	@type  Static Function
	@author jacomo.fernandes
	@since 29/05/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function LoadTiposRecursos()

Local oModel	:= FwLoadModel('GTPA010')
Local oMdlGYK	:= oModel:GetModel('GYKMASTER')
Local aArea		:= GetArea()
Local aTipos	:= {}
Local cCodigo	:= ""
Local nX		:= 0

aAdd(aTipos,{STR0055, '1', '1', '1'})//'MOTORISTA'
aAdd(aTipos,{STR0056, '2', '1', '2'})//'COBRADOR'
aAdd(aTipos,{STR0057, '1', '2', '1'})//'MOTORISTA/TREINAMENTO'
aAdd(aTipos,{STR0058, '2', '2', '1'})//'MOTORISTA/PASSAGEIRO'
aAdd(aTipos,{STR0059, '2', '2', '2'})//'COBRADOR/PASSAGEIRO'
aAdd(aTipos,{STR0060, '1', '2', '1'})//'MOTORISTA/PRATICANDO'

GYK->(DbSetOrder(1))//GYK_FILIAL+GYK_CODIGO
For nX := 1 to Len(aTipos)
	cCodigo	:= StrZero(nX,TamSx3('GYK_CODIGO')[1])
	If !GYK->(DbSeek(xFilial('GYK')+cCodigo ))
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If oModel:Activate()
			oMdlGYK:SetValue('GYK_CODIGO'	,cCodigo)
			oMdlGYK:SetValue('GYK_DESCRI'	,aTipos[nX][1])
			oMdlGYK:SetValue('GYK_VALCNH'	,aTipos[nX][2])
			oMdlGYK:SetValue('GYK_PROPRI'	,"S") //Define que esses cadastros foram feito pelo sistema
			oMdlGYK:SetValue('GYK_LIMTIP'	,aTipos[nX][3]) //Define se limita ou não o tipo de recurso
			oMdlGYK:SetValue('GYK_TIPREC'	,aTipos[nX][4]) //Define se limita ou não o tipo de recurso
			
			If oModel:VldData() 
				oModel:CommitData()
			EndIf
		EndIf
		
		oModel:Deactivate()
	Endif
Next

oModel:Destroy()
RestArea(aArea)
GtpDestroy(aTipos)
Return 

/*/{Protheus.doc} LoadStG59
	Função responsavel para por atualizar o campo novo de status criado
	@type  Static Function
	@author karyna.martins
	@since 12/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function LoadStG59()

Local aArea		:= GetArea()
	
	G59->( DBGoTop()() )
	If Empty(G59->G59_STAPRO)
		While G59->( !EOF() )
			
			If Empty(G59->G59_STAPRO)
				RECLOCK('G59',.F.)
				G59->G59_STAPRO := Iif(G59->G59_STATUS,'4','1')
				G59->(MSUNLOCK())
			EndIf

			G59->( DbSkip() )

		EndDo
	EndIf
	
RestArea(aArea)

Return

/*/{Protheus.doc} LoadTipcal
	Função responsavel para por atualizar o campo novo de status criado
	@type  Static Function
	@author karyna.martins
	@since 19/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function LoadTipcal()

Local aArea		:= GetArea()
	
	H6V->( DBGoTop() )
	If Empty(H6V->H6V_TIPCAL)
		While H6V->( !EOF() )
			
			If Empty(H6V->H6V_TIPCAL)
				RECLOCK('H6V',.F.)
				H6V->H6V_TIPCAL := '1'
				H6V->(MSUNLOCK())
			EndIf

			H6V->( DbSkip() )

		EndDo
	EndIf
	
RestArea(aArea)

Return

/*/{Protheus.doc} CompTableH86
	Função responsavel para comptabilizar a tabela H7O com a H86
	@type  Static Function
	@author jose.darocha
	@since 19/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function CompTableH86()
	Local aAreaAtu := GetArea()
	Local cAliasQry:= GetNextAlias()
	Local oModel
	Local oGrid

	BeginSql Alias cAliasQry 

		Select isNull(H86_CODH7O,'NAO') STATUS,H7O_CODIGO,H7O_PREREC,H7O_NATREC,H7O_PREDES,H7O_NATDES   
		From %table:H7O% H7O        
		Left Join %table:H86% H86 On H86_FILIAL = %xFilial:H86% And H86_CODH7O = H7O_CODIGO and H86.%NotDel%
		Where H7O_FILIAL = %xFilial:H7O%       
		And H7O.%NotDel% AND isNull(H86_CODH7O,'NAO') = 'NAO'  

	EndSql 

	If (cAliasQry)->(!Eof())

		oModel := FWLoadModel("GTPU014")		

		H7O->(DbSetOrder(1))

		While (cAliasQry)->(!Eof())

			H7O->(DbSeek(xFilial('H7O')+(cAliasQry)->H7O_CODIGO))
			
			oModel:SetOperation(MODEL_OPERATION_UPDATE)

			If oModel:Activate()
				oGrid := oModel:GetModel("H86DETAIL")
				oGrid:AddLine()
				oGrid:SetValue("H86_FILIAL", xFilial("H86"))
				oGrid:SetValue("H86_CODH7O", (cAliasQry)->H7O_CODIGO)
				oGrid:SetValue("H86_TIPLIN", Space(06))
				oGrid:SetValue("H86_PREREC", (cAliasQry)->H7O_PREREC)
				oGrid:SetValue("H86_NATREC", (cAliasQry)->H7O_NATREC)
				oGrid:SetValue("H86_PREDES", (cAliasQry)->H7O_PREDES)
				oGrid:SetValue("H86_NATDES", (cAliasQry)->H7O_NATDES)
			EndIf 

			If oModel:VldData() 
				oModel:CommitData()
			EndIf

			oModel:Deactivate()

			(cAliasQry)->(DbSkip())
		EndDo 
		
		oModel:Destroy()

	EndIf 

	(cAliasQry)->(DbCloseArea())

	RestArea( aAreaAtu )
Return 
