#Include 'protheus.ch'
#Include 'TopConn.ch'

static lCTBA080	:= ( 'CTBA080' == funName() )

/*/{Protheus.doc} PLSCTP05
Busca dinamica da conta, conforme configuracao flexivel
no arquivo especifico BAZ. (Faturamento)          		  
31/10/07   A partir desta data o programa passa a considerar somente  
           movimentos referentes a mensalidade (PP ou CO) e lancamento
           de custo operacional (em planos Demais Modalidades).       
           O tratamento a classe do procedimento passa a ser feito em 
           outro lancamento, pelo programa CTBPLS11. RC.              
26/03/08   A partir desta data o programa passa a considerar somente  
           movimentos referentes a mensalidade (PP ou CO).			  
           Os demais tratamentos passam a ser feitos pelo  programa  
           CTBPLS11. RC.             								  
Este programa fara uma busca de conta conforme a string busca
(cBusca) que será montada. Esta string ira variar conforme a 
combinacao de informacoes que serao avaliadas.              
Alguns arquivos estao sempre posicionados no momento do      
lancamento, portanto somente sera posicionado o arquivo de   
combinacoes de contas e especificos.                         

Inicializa Parametros:                                            
MV_PLCT05 --> Codigo dos Tipos de Planos Individuais / Familiares
MV_PLCT07 --> Codigo dos planos do opcional Usimed.               
MV_PLCT13 --> Conta para contabilizar Tx.Adm. em conta unica     
cNatLct	:= 'D'		Natureza do lançamento: D-Débito / C-Crédito. Esta natureza é relativa ao
					retorno do programa, se deve retornar a conta crédito ou débito.

cTipLct	:= 'I'		Tipo do Lançamento: I-Inclusão / C-Cancelamento / P-Provisão (para títulos excluídos antes de contabilizar) / R - Patrocinadora
lConAnt	:= .t.		Considerar faturamento antecipado? .t. - Considera / .f. - Não Considera

cTipAto	:= ''		Tipo de Ato: 0-Ato Coop Aux / 1-Ato Coop Princ / 2-Ato Nao Coop
					Identifica se deve tratar tipo de ato especifico ou pelo processo normal (não passa parâmetro).
					Utilizado para divisão de atos no BM1 - BM1_VLACP/BM1_VLACA/BM1_VLANC

lConComp := .f.		Contabiliza parcial por competência? .t. - Contabiliza / .f. - Não Contabiliza
					Permite ao usuário contabilizar parte do recebimento na competência atual e parte do recebimento
					na próxima competência. Semelhante ao faturamento antecipado, porém não depende da validação de 
					datas de competência e emissão. 
lB5F	:= .t.  	ativa a verificacao de habitual					
cTipCo  :=			 Tipo de Participação Financeira: 	0-Custo Operacional em Demais Modalidades
   									       	1-Custo Operacional por compras
											2-Co-Participação
											3-Taxa Admin. s/Custo Operacional por compras
											4-Taxa Admin. s/Co-Participação
											5-Taxa Admin. s/Custo Operacional Demais Modal.
@author  PLS TEAM
@version P12
@since   21.03.17
/*/
function PLSCTP05( notUSED, cNatLct, cTipLct, lConAnt, notUSED, cTipAto, lConComp, lB5F, cTipCo)
local aArea 	:= getArea()
local cCtpl07	:= getNewPar('MV_PLCT07','0086')
local cCtpl13	:= getNewPar('MV_PLCT13','3311810100001')
local nInd		:= 0

local cOpeRda	:= plsIntPad()
local cCodPla   := space(4)
local cPatroc	:= ''
local cCompBus	:= ''
local cPlano    := ''
local cOpeOri   := ''
local cCodInt	:= ''
local cContac	:= ''
local cGruOpe	:= ''
local cRet		:= ''
local cBusca	:= ''
local cDtEmis	:= ''
local cDtComp	:= ''
local cBi3ModPag:= ''
local cBi3ApoSrg:= ''
local cBi3TipCon:= ''
local cBi3Tipo	:= ''
local cBi3CodSeg:= ''
local cTipoBG9	:= ''
local cBi3TpBen	:= ''
local cProc		:= ''
local cMatUsu	:= ''
local cRotina	:= 'PLSCTP05'
local cSql		:= ''
local lProcPatr := iIf(BAZ->(fieldPos("BAZ_CPATCR")) > 0, .t., .f.) .and. iIf(BAZ->(fieldPos("BAZ_CPATDB")) > 0, .t., .f.)
local aRet		:= {}
local lAchouBA1	:= .f.
local lMensal	:= .f.
local lMesFat	:= .t.
local dData		:= ctod('')

default notUSED  := nil
default lConAnt	 := .t.
default lConComp := .f.
default cNatLct	 := 'D'
default cTipLct	 := 'I'
default cTipAto	 := ''

if lCTBA080
	return('1')
endIf

BAZ->(dbSetOrder(1))//BAZ_FILIAL+BAZ_TPBENE+BAZ_TPFATU+BAZ_TPUNIM+BAZ_TPATO+BAZ_REGPLN+BAZ_TPPLN+BAZ_PATROC+BAZ_SEGMEN+BAZ_CODPLA+BAZ_GRUOPE

cAlias := 'BM1'

//busca plano do beneficiario
aRet 		:= plctpBA1( xFilial('BA1') + &(cAlias+'->('+cAlias+'_CODINT +'+cAlias+'_CODEMP+ '+cAlias+'_MATRIC + '+cAlias+'_TIPREG)'), xFilial('BA1')+&(cAlias+'->'+cAlias+'_MATUSU') )
cPlano     	:= aRet[1]
cCodPla    	:= aRet[2]
cCodInt    	:= aRet[3]
cBi3ModPag 	:= aRet[4]
cBi3ApoSrg 	:= aRet[5]
cBi3TipCon 	:= aRet[6]
cBi3Tipo   	:= aRet[7]
cBi3CodSeg 	:= aRet[8]
cBi3TpBen  	:= aRet[9]
cTipoBG9	:= aRet[10]
cPatroc		:= aRet[11]
cContac		:= aRet[12]
cGruOpe		:= aRet[13]
lAchouBA1	:= aRet[14]
cMatUsu		:= aRet[15]
cOpeOri		:= aRet[16]

//pega a operadora da RDA se for meu usuario sendo atendido fora.
//Preciso saber qual RDA atendeu e pegar a operadora da RDA.
if cOpeOri == cOpeRda .and. (cAlias)->&(cAlias + '_TIPREG') == '1'

	cSql := " SELECT BD6_CODRDA "
	cSql += "   FROM " + retSQLName('BD6') 
	cSql += "  WHERE BD6_FILIAL = '" + xFilial('BD6') + "' "
	cSql += "    AND BD6_OPEFAT = '" + left((cAlias)->&(cAlias + '_PLNUCO'), 4) + "' "
	cSql += "    AND BD6_NUMFAT = '" + (cAlias)->&(cAlias + '_PLNUCO') + "' "
	cSql += "    AND BD6_PREFIX = '" + (cAlias)->&(cAlias + '_PREFIX') + "' "
	cSql += "    AND BD6_NUMTIT = '" + (cAlias)->&(cAlias + '_NUMTIT') + "' "
	cSql += "    AND BD6_PARCEL = '" + (cAlias)->&(cAlias + '_PARCEL') + "' "
	cSql += "    AND BD6_TIPTIT = '" + (cAlias)->&(cAlias + '_TIPTIT') + "' "
	cSql += "    AND BD6_OPEUSR = '" + (cAlias)->&(cAlias + '_CODINT') + "' "
	cSql += "    AND BD6_CODEMP = '" + (cAlias)->&(cAlias + '_CODEMP') + "' "
	cSql += "    AND BD6_MATRIC = '" + (cAlias)->&(cAlias + '_MATRIC') + "' "
	cSql += "    AND BD6_TIPREG = '" + (cAlias)->&(cAlias + '_TIPREG') + "' "
	cSql += "    AND BD6_INTERC = '1' "
	cSql += "    AND D_E_L_E_T_ = ' ' "

	MPSysOpenQuery( cSql, 'TRBHAB' )

	if ! TRBHAB->(eof())
		aRet 	:= plctpBAU(TRBHAB->BD6_CODRDA)
		cOpeRda	:= aRet[6]
	endIf

	TRBHAB->(dbCloseArea())

endIf

if lAchouBA1

	dData := ctod( '01/' + (cAlias)->&(cAlias + '_MES') + '/' + (cAlias)->&(cAlias + '_ANO') )

	//tipo de beneficiario
	cBusca := plctpTPB(cBi3TpBen, dData, lB5F, cOpeRda)		
	
	plLogDet( cBusca, 'BAZ_TPBENE', 'BI3_TPBEN', 'Tipo de Beneficiario', nil, cRotina )
	
	//Tipo do Contrato para Faturamento
	aRet 	:= plctpTCF(cAlias, cBi3ModPag, cCtPl07, cCtpl13, cTipCo)
	lMensal := aRet[1]
	cRet 	:= aRet[2]
	cBusca  += aRet[3]
	
	plLogDet( cBusca, 'BAZ_TPFATU', cAlias+'_CODTIP', 'Tipo do Contrato para Faturamento', nil, cRotina )

	if empty(cRet)

		// Fixo espaço duplo para o Tipo de Faturamento, que só é utilizado nos lançamentos
		// do tipo 4-CO em PP e tipo 5-Co-Participação, QUE SÃO CONTABILIZADOS NO PROGRAMA CTBPLS11.
		cBusca	+= space(2)

		plLogDet( cBusca, 'BAZ_TPUNIM', '', 'Tipo de Procedimento Contratado', nil, cRotina )

		//tipo de ato                                                          
		cBusca += plctpTPA(nil, nil, nil, cTipAto, nil, nil, nil, cAlias)

		plLogDet( cBusca, 'BAZ_TPATO', cAlias+'_ATOCOO', 'Tipo de Ato', nil, cRotina )

		//plano regulamentado
		cBusca += plctpPLR(cBi3ApoSrg)

		plLogDet( cBusca, 'BAZ_REGPLN', 'BI3_APOSRG', 'Plano Regulamentado', nil, cRotina )

		//tipo de plano/contrato
		cBusca += plctpPLC(cBi3Tipo, cBi3TipCon)

		plLogDet( cBusca, 'BAZ_TPPLN', 'BI3_TIPO|BI3_TIPCON', 'Tipo de Plano/Contrato', nil, cRotina )

		//patrocino                                              
		cBusca += plctpPTC(cBi3Tipo, cTipoBG9, cPatroc)

		plLogDet( cBusca, 'BAZ_PATROC', 'BQC_PATROC|BG9_TIPO|BI3_TIPO', 'Patrocinio', nil, cRotina )
	
		plLogDet( cBusca+cBi3CodSeg, 'BAZ_SEGMEN', 'BI3_CODSEG', 'Segmentacao', nil, cRotina )
		plLogDet( cBusca+cBi3CodSeg+cCodPla, 'BAZ_CODPLA', 'BA1_CODPLA|BA3_CODPLA', 'Plano', nil, cRotina )
		plLogDet( cBusca+cBi3CodSeg+cCodPla+cGruOpe, 'BAZ_GRUOPE', 'BA0_GRUOPE', 'Grupo Operadora', nil, cRotina )

		//Analisa condição do faturamento, se foi realizado no mês da competência, 
		//se foi adiantado ou postergado, para definir qual conta pegar, conforme a
		//condição da variável lMesFat.                                            
		lMesFat	:= .t.

		// Verifica se o faturamento é de competência posterior a emissão do título, ou seja, faturamento antecipado.
		// A débito é utilizado somente em guias, não aplicável neste programa.
		// Incluído tratamento opcional, para contemplar lançamento P03 criado em 19/12/07. RC.
		if lConAnt .and. ! lConComp		

			cDtEmis	:= strZero( year(SE1->E1_EMISSAO), 4 ) + strZero( month(SE1->E1_EMISSAO), 2 )
			cDtComp	:= SE1->(E1_ANOBASE + E1_MESBASE)

			if cDtComp > cDtEmis
				lMesFat	:= .f.
			endIf

		// Se contabiliza competência parcial, vai pegar conta do faturamento antecipado
		elseIf lConComp						
			
			lMesFat := .f.

		endIf

		lAchou := .f.

		//Ponto de entrada para complementar a busca
		if existBlock("PCTP05COM")

			aRetPE := Execblock("PCTP05COM",.f.,.f.)

			if Valtype(aRetPE) == "A"
				
				cCompbus := aRetPE[1]
				nInd     := aRetPE[2]
				BAZ->(dbsetOrder(nInd))

			endIf

		endIf

		//Tratamento ao Grupo de Operadoras.                        
		//Valido somente para Tipo de Beneficiario igual a          
		//Exposto Nao Beneficiario (2) ou Prestacao de Servicos (4).
		//RC - 06/08/07                                             
		if cBi3TpBen $ '2/4'

			// Procura combinacao com Grupo de Operadora
			if ! ( lLocBAZ := BAZ->(msSeek(xFilial("BAZ")+cBusca+cBi3CodSeg+cCodPla+cGruOpe+cCompbus, .f.) ) )
				
				if !( lLocBAZ := BAZ->(msSeek(xFilial("BAZ")+cBusca+space(3)+cCodPla+cGruOpe+cCompbus, .f.) ) )
					lLocBAZ := BAZ->(msSeek(xFilial("BAZ")+cBusca+space(7)+cGruOpe+cCompbus, .f.) )
				endIf

			endIf
			
			if lLocBAZ
			
				do case
					Case cNatLct == 'D' .and. cTipLct $ 'I/P' .and. lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CTADB1), 'C->'+cBusca, BAZ->BAZ_CTADB1 )
					Case cNatLct == 'D' .and. cTipLct == 'C' .and. lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CANDB1), 'C->'+cBusca, BAZ->BAZ_CANDB1 )
					Case cNatLct == 'D' .and. cTipLct $ 'I/P' .and. !lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CTADB2), 'C->'+cBusca, BAZ->BAZ_CTADB2 )
					Case cNatLct == 'D' .and. cTipLct == 'C' .and. !lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CANDB2), 'C->'+cBusca, BAZ->BAZ_CANDB2 )
					case lProcPatr .and. cNatLct == 'D' .and. cTipLct == 'R'
						cRet	:= iIf(empty(BAZ->BAZ_CPATDB), 'C->'+cBusca, BAZ->BAZ_CPATDB)		   
					Case cNatLct == 'C' .and. cTipLct $ 'I/P' .and. lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CTACR1), 'C->'+cBusca, BAZ->BAZ_CTACR1 )
					Case cNatLct == 'C' .and. cTipLct $ 'I/P' .and. !lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CTACR2), 'C->'+cBusca, BAZ->BAZ_CTACR2 )
					Case cNatLct == 'C' .and. cTipLct == 'C' .and. lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CANCR1), 'C->'+cBusca, BAZ->BAZ_CANCR1 )
					Case cNatLct == 'C' .and. cTipLct == 'C' .and. !lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CANCR2), 'C->'+cBusca, BAZ->BAZ_CANCR2 )
					case lProcPatr .and. cNatLct == 'C' .and. cTipLct == 'R'
						cRet	:= iIf(empty(BAZ->BAZ_CPATCR), 'C->'+cBusca, BAZ->BAZ_CPATCR)
					otherWise
						cRet	:= "L->"+cBusca+"|Param.Invalida:|Nat.Lancto:|'"+cNatLct+"'|Tipo Lancto:|'"+cTipLct+"'|"
				EndCase

				lAchou := .t.

			else
				cRet	:= 'N->'+cBusca
				lAchou 	:= .f.
			endIf
			
		endIf

		// Se não achou, procura combinacao sem Grupo de Operadora
		if ! lAchou

			lLocBAZ := .f.

			//Procura combinacao com Produto
			if ! ( lLocBAZ := BAZ->(msSeek(xFilial("BAZ")+cBusca+cBi3CodSeg+cCodPla+space(2)+cCompbus, .f.)) )
				
				if ! ( lLocBAZ := BAZ->(msSeek(xFilial("BAZ")+cBusca+space(3)+cCodPla+space(2)+cCompbus, .f.)) )
					lLocBAZ := BAZ->(msSeek(xFilial("BAZ")+cBusca+space(9)+cCompbus, .f.))
				endIf

			endIf
			
			if lLocBAZ

				do case
					Case cNatLct == 'D' .and. cTipLct $ 'I/P' .and. lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CTADB1), 'C->'+cBusca, BAZ->BAZ_CTADB1 )
					Case cNatLct == 'D' .and. cTipLct == 'C' .and. lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CANDB1), 'C->'+cBusca, BAZ->BAZ_CANDB1 )  
					Case cNatLct == 'D' .and. cTipLct $ 'I/P' .and. !lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CTADB2), 'C->'+cBusca, BAZ->BAZ_CTADB2 )
					Case cNatLct == 'D' .and. cTipLct == 'C' .and. !lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CANDB2), 'C->'+cBusca, BAZ->BAZ_CANDB2 )
					case lProcPatr .and. cNatLct == 'D' .and. cTipLct == 'R'
						cRet	:= iIf(empty(BAZ->BAZ_CPATDB), 'C->'+cBusca, BAZ->BAZ_CPATDB)		   	
					Case cNatLct == 'C' .and. cTipLct $ 'I/P' .and. lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CTACR1), 'C->'+cBusca, BAZ->BAZ_CTACR1 )
					Case cNatLct == 'C' .and. cTipLct $ 'I/P' .and. !lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CTACR2), 'C->'+cBusca, BAZ->BAZ_CTACR2 )
					Case cNatLct == 'C' .and. cTipLct == 'C' .and. lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CANCR1), 'C->'+cBusca, BAZ->BAZ_CANCR1 )
					Case cNatLct == 'C' .and. cTipLct == 'C' .and. !lMesFat
						cRet	:= iIf(empty(BAZ->BAZ_CANCR2), 'C->'+cBusca, BAZ->BAZ_CANCR2 )
					case lProcPatr .and. cNatLct == 'C' .and. cTipLct == 'R'
						cRet	:= iIf(empty(BAZ->BAZ_CPATCR), 'C->'+cBusca, BAZ->BAZ_CPATCR)
					otherWise
						cRet	:= "L->"+cBusca+"|Param.Invalida:|Nat.Lancto:|'"+cNatLct+"'|Tipo Lancto:|'"+cTipLct+"'|"
				endCase

			else
				
				if ' ' $ subs(cBusca,1,2)+subs(cBusca,5)
					cRet := 'L->'+cBusca
				else
					cRet := 'N->'+cBusca
				endIf

			endIf

		endIf

	endIf

endIf

//ponto de entrada para corrigir ou implemnetar a chave de busca
if existBlock("PLCTPBUS")

	cRet := execBlock("PLCTPBUS", .f., .f., { cRotina, 'BAZ', cBusca, cRet } )
	
	plLogDet( cRet, 'PLCTPBUS', '', 'Ajustado por ponto de entrada', nil, cRotina )		
	
endIf

//Grava em memoria a composicao da cobranca.
if ! lAchouBA1
	cProc	:= 'Lt.Cobr:'+subs(&(cAlias+'->'+cAlias+'_PLNUCO'),5,8)+'|Seq:'+&(cAlias+'->'+cAlias+'_SEQ')+'|Tit:'+&(cAlias+'->'+cAlias+'_NUMTIT')
	cProc	+= '|Matr:'+&(cAlias+'->('+cAlias+'_CODINT+'+cAlias+'_CODEMP+'+cAlias+'_MATRIC+'+cAlias+'_TIPREG+'+cAlias+'_DIGITO)')+'|Nome:'+subs(&(cAlias+'->'+cAlias+'_NOMUSR'),1,20)
	cProc	+= '|Prod: N/Enc. |Grp.Emp:'+&(cAlias+'->'+cAlias+'_CODEMP')
	cProc	+= '|Contr:'+BA1->BA1_CONEMP+'/'+BA1->BA1_VERCON+'|Sub:'+BA1->BA1_SUBCON+'/'+BA1->BA1_VERSUB
	cProc	+= '|Tp.Fat:'+&(cAlias+'->'+cAlias+'_CODTIP')+'|Evto:'+&(cAlias+'->'+cAlias+'_CODEVE')
	cProc	+= '|Vl.Evto:'+strZero(&(cAlias+'->'+cAlias+'_VALOR'),10,2)+'|Vl.Tit.:'+strZero(SE1->E1_VALOR,10,2)
	cProc	+= iIf(&(cAlias+'->'+cAlias+'_TIPO')=='1','|Deb/Cred:D',iIf(&(cAlias+'->'+cAlias+'_TIPO')=='2','|Deb/Cred:C',''))
	cProc	+= '|Usuario nao encontrado-CTBPLS05'
	cRet	:= 'L->'
else
	cProc	:= 'Lt.Cobr:'+subs(&(cAlias+'->'+cAlias+'_PLNUCO'),5,8)+'|Seq:'+&(cAlias+'->'+cAlias+'_SEQ')+'|Tit:'+&(cAlias+'->'+cAlias+'_NUMTIT')
	cProc	+= '|Matr:'+&(cAlias+'->('+cAlias+'_CODINT+'+cAlias+'_CODEMP+'+cAlias+'_MATRIC+'+cAlias+'_TIPREG+'+cAlias+'_DIGITO)')+'|Nome:'+subs(BA1->BA1_NOMUSR,1,20)
	cProc	+= '|Prod:'+subs(cPlano,1,4)+'/'+subs(cPlano,5,3)+'|Grp.Emp:'+BA1->BA1_CODEMP
	cProc	+= '|Contr:'+BA1->BA1_CONEMP+'/'+BA1->BA1_VERCON+'|Sub:'+BA1->BA1_SUBCON+'/'+BA1->BA1_VERSUB
	cProc	+= '|Tp.Fat:'+&(cAlias+'->'+cAlias+'_CODTIP')+'|Evto:'+&(cAlias+'->'+cAlias+'_CODEVE')
	cProc	+= '|Vl.Evto:'+strZero(&(cAlias+'->'+cAlias+'_VALOR'),10,2)+'|Vl.Tit.:|'+strZero(SE1->E1_VALOR,10,2)
	cProc	+= iIf(&(cAlias+'->'+cAlias+'_TIPO')=='1','|Deb/Cred:D',iIf(&(cAlias+'->'+cAlias+'_TIPO')=='2','|Deb/Cred:C',''))
endIf

// Aciona gravacao de Log
if subStr(cRet,1,1) $ 'CLN'

	if subStr(cRet,1,1) $ 'C'
		cProc += '|Chave:'+cBusca+cCompbus+'|Sem Cta Combinacao'
	elseIf subStr(cRet,1,1) $ 'N'
		cProc += '|Chave:'+cBusca+cCompbus+'|Falta Combinacao  '
	else
		cProc += '|Chave:'+cBusca+cCompbus+'|Impossivel Montar Combinacao'
	endIf

	// Grava log de registro com problema
	PlGrvLog(cProc, 'FAT', 1)

endIf
	
//Grava detalhamento
plLogDet(nil, nil, nil, nil, nil, cRotina, ( subs(cRet,1,1) $ 'CLN' ) )

restArea(aArea)

return(cRet)