function beforeStateEntry(sequenceId)
{
var ABRIR = 2;
var RESPENVIADA	= 8;

var step  = parseInt(getValue("WKCurrentState"));
	
	log.info("*** beforeStateEntry Consultivo: Iniciando. Atividade: " + step + "/Sequence Id: " + sequenceId);
	
	switch(step)
	{
		case ABRIR:	
						
			hAPI.setCardValue("numSolic", getValue("WKNumProces"));
			hAPI.setCardValue("sStatusResp","1");
			hAPI.setCardValue("sStatusProc","1");
			hAPI.setCardValue("sRevisao","false");
			
			//configura o responsável pela tarefa
			log.info("*** beforeStateEntry Consultivo: Tenta Configurar o Responsável");
			
			if ( setInfoConfig() )
			{
				log.info("*** beforeStateEntry ConsultivoResp: Advogado: " + hAPI.getCardValue("sAdvogado"));
				
			}else
			{
				log.error("*** beforeStateEntry Consultivo: Não foi possível determinar o responsável pela Consulta/Parecer");
				throw "Não foi possível determinar o responsável pela Consulta/Parecer";
				
			}
			
			break;				

		case RESPENVIADA:	

			log.info("*** beforeStateEntry Consultivo: RESPENVIADA. ");
			hAPI.setCardValue("sUserGroup",getMailByUserId(getValue('WKUser')));
			
			break;			
			
		default:
			break;	
	}
	log.info("*** beforeStateEntry Consultivo: Fim.")
}

function setInfoConfig()
{	
var cdTipoSol     = hAPI.getCardValue("cdTipoSol");
var configs       = null;
var nPerc         = 0; //porcentagem de atribuição do usuário
var cdUser        = 0;
var sUser         = 0;
var lRet          = false;
var sPrazo        = 0;
var nMenor        = 9999;
var nMenorAux     = 9999;
var idMenor       = -1;
var idMenorAux    = -1;
var qtdSol        = -1;
var qtdUser       = 0;
var sResponsavel  = '';
var cdResponsavel = '';
var lGrupo        = false;
var sPrazoEnc     = 0;
var cdAssJur   ;




var order = new Array("sPrioridade");
var fields = new Array("metadata#id", "sPrioridade","cdAssJur", "sPrazo", "cdGrupo", "sGrupo", "cdUser", "sUser", "cdTipoSol", "sPrazoEnc" );
var constraints = new Array();


	constraints.push(DatasetFactory.createConstraint("metadata#active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdTipoSol", cdTipoSol, cdTipoSol, ConstraintType.MUST));

	try 
	{	
		configs = DatasetFactory.getDataset("wcmSIGAJURI_Consultivo", fields, constraints, order);
	}
	catch(e)
	{
		log.error("*** beforeStateEntry ConsultivoResp: Falha ao buscar dataset.");
		log.error("*** beforeStateEntry ConsultivoResp: ERRO: " + e.message);
	}
	
	if (!configs || configs.rowsCount <= 0)
	{
		log.info("*** beforeStateEntry ConsultivoResp: Nenhuma configuração encontrada. Não irá para o SIGAJURI.");
		return false;
	}
	
	log.info("*** beforeStateEntry ConsultivoResp: Processando dados encontrados: " + configs.rowsCount);
	
	for (var i = 0; i < configs.rowsCount; i++)
	{
		log.info("*** beforeStateEntry ConsultivoResp: Avaliando " + configs.getValue(i, "cdTipoSol"));
		//definição da prioridade
		if (configs.rowsCount==1)
		{
			nPerc = 10;
		} else {
			nPerc = Number(configs.getValue(i, "sPrioridade"));
		}
		
		//se o campo está igual a 10, deve receber todas as solicitações.
		if (nPerc == 10)
		{
			idMenor = i;
			
			lRet = true;
			break; //sai do loop 
		} else {
			cdResponsavel = configs.getValue(i,"cdUser");
			sResponsavel  = configs.getValue(i,"sUser");

			if ((cdResponsavel == null) || (cdResponsavel == '')){
				cdResponsavel =  configs.getValue(i,"cdGrupo");
				sResponsavel = configs.getValue(i,"sGrupo");
			}

			//pega a quantidade de solicitações ativas para determinado tipo de solicitação
			if (qtdSol==-1)
			{
				qtdSol = getCardsBySol(configs.getValue(i, "cdTipoSol"));
			}
			
			log.info("*** beforeStateEntry ConsultivoResp: qtdSol " + qtdSol);
			qtdUser = getCardsByUser(configs.getValue(i, "cdTipoSol"),cdResponsavel);
			log.info("*** beforeStateEntry ConsultivoResp: qtdUser " + qtdUser);
			
			log.info("*** beforeStateEntry ConsultivoResp: valida menor (qtdUser < nMenorAux):(" + qtdUser + " < " + nMenorAux) +")";
			//preenche o menor, independete se for elegível ou não.
			if (qtdUser < nMenorAux)
			{
				nMenorAux = qtdUser;
				idMenorAux = i;
			}
			
			log.info("*** beforeStateEntry ConsultivoResp idMenorAux:" + idMenorAux);
			
			log.info("*** beforeStateEntry ConsultivoResp: (((qtdSol/10)*nPerc) ) = " +((qtdSol/10)*nPerc));
			
			//valida se o usuário deve receber a tarefa atual, baseado no campo prioridade
			if ((qtdUser < ((qtdSol/10)*nPerc)) || qtdUser == 0 || ((qtdSol/10)*nPerc) < 1 )
			{
				if (qtdUser < nMenor)
				{
					nMenor = qtdUser;
					idMenor = i;
				}
				
				lRet = true;
			}
		}
	}
			
	log.info("*** beforeStateEntry: Fim laço: lRet =" + lRet + ", idMenorAux=" + idMenorAux);
	
	if ((lRet==false) && (idMenorAux > -1))
	{
		lRet = true;
		idMenor = idMenorAux;
		nMenor = nMenorAux;
	}
	
	//Usuário válido como executor
	if (lRet)
	{
		
		log.info("*** beforeStateEntry ConsultivoResp: menor = " + idMenor + ", qtd:" + nMenor );
		
		cdResponsavel = configs.getValue(idMenor, "cdUser");
		sResponsavel = configs.getValue(idMenor, "sUser");
		
		if ((cdResponsavel == null) || (cdResponsavel == '')){
			sResponsavel  = configs.getValue(idMenor,"sGrupo");
			cdResponsavel = configs.getValue(idMenor,"cdGrupo");
			lGrupo        = true;
		}

		log.info("*** beforeStateEntry ConsultivoResp: cdResponsavel = " + cdResponsavel + ", sResponsavel:" + sResponsavel );

		sPrazo = configs.getValue(idMenor, "sPrazo");
		cdAssJur = configs.getValue(idMenor, "cdAssJur");
		sPrazoEnc = configs.getValue(idMenor, "sPrazoEnc");
		
		
		hAPI.setCardValue("sAdvogado",sResponsavel);
		hAPI.setCardValue("cdAssJur",cdAssJur);
		hAPI.setCardValue("sPrazoEnc",sPrazoEnc);
		
		log.info("*** beforeStateEntry ConsultivoResp: cdResponsavel = " + cdResponsavel + ", sResponsavel:" + sResponsavel + ", lGrupo:" + lGrupo);
		
		if (!lGrupo){
			hAPI.setCardValue("cdAdvogado",getColleagueIdByMail(cdResponsavel));
			hAPI.setCardValue("sMailAdvogado",getMailByUserId(cdResponsavel));
		} else {
			hAPI.setCardValue("cdAdvogado","Pool:Group:" + cdResponsavel);
			hAPI.setCardValue("sMailAdvogado",cdResponsavel);
		}

		hAPI.setCardValue("dtPrazoTarefa", getCurrentDate(Number(sPrazo)));

	}

	return lRet;
	
}