#Include 'protheus.ch'
#Include 'TopConn.ch'

static lCTBA080	:= ( 'CTBA080' == funName() )

/*/{Protheus.doc} PLRETDAD
Busca dinamica da conta, conforme configuracao flexivel
no arquivo especifico BAZ. (Faturamento)    

Este programa fara uma busca de conta conforme a string busca
(cBusca) que será montada. Esta string ira variar conforme a 
combinacao de informacoes que serao avaliadas.               
Os arquivos estao sempre posicionados no momento do          
lancamento, portanto somente sera posicionado o arquivo de   
combinacoes de contas.                                       
cNatLct - Natureza do lançamento: D-Débito / C-Crédito
cTipLct - Tipo do Lançamento: I-Inclusão / P-Provisão / C-Cancelamento
cTipCo  - Tipo de Participação Financeira: 	0-Custo Operacional em Demais Modalidades
   									       	1-Custo Operacional por compras
											2-Co-Participação
											3-Taxa Admin. s/Custo Operacional por compras
											4-Taxa Admin. s/Co-Participação
											5-Taxa Admin. s/Custo Operacional Demais Modal.
cTipAto	- Tipo de Ato: 	0-Ato Coop Aux / 1-Ato Coop Princ / 2-Ato Nao Coop
						Identifica se deve tratar tipo de ato especifico ou pelo processo normal (não passa parâmetro).
						Utilizado para divisão de atos no BM1 - BM1_VLACP/BM1_VLACA/BM1_VLANC

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
function PLSCTP11(notUSED, cNatLct, cTipLct, cTipCo, cTipAto, lB5F)
local aArea		:= getArea()
local nTmp		:= 0
local cCtpl06 	:= getNewPar('MV_PLCT06','000010014')
local cCtpl11 	:= getNewPar('MV_PLCT11','000004')
local cGruGen 	:= getNewPar('MV_PLSCTGR','0001')

local cOpeRda	:= ''
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
local cGruOpe 	:= ''
local cPlano    := ''
local cOpeOri   := ''
local cCodInt	:= ''
local cPatroc	:= ''
local cContac	:= ''
local cCodRda	:= ''
local cAlias	:= 'BD6'
local cCodPla 	:= space(4)
local cRotina	:= 'PLSCTP11'
local dData		:= ctod('')
local lAchouBA1	:= .f.
local aRet		:= {}
local aRetAux	:= {}
local lMesFat 	:= .F.

default lLogUsu	:= .f.
default cNatLct	:= 'D'
default cTipLct	:= 'I'
default cTipCo	:= '0'
default cTipAto	:= ''

if lCTBA080
	return('1')
endIf

BFA->(DbSetOrder(2))//BFA_FILIAL+BFA_CODPSA+BFA_GRUGEN+BFA_CODIGO
BF0->(DbSetOrder(1))//BF0_FILIAL+BF0_GRUGEN+BF0_CODIGO
BAZ->(dbSetOrder(1))//BAZ_FILIAL+BAZ_TPBENE+BAZ_TPFATU+BAZ_TPUNIM+BAZ_TPATO+BAZ_REGPLN+BAZ_TPPLN+BAZ_PATROC+BAZ_SEGMEN+BAZ_CODPLA+BAZ_GRUOPE

//busca plano do beneficiario
aRet 		:= plctpBA1( xFilial('BA1') + &(cAlias+'->('+cAlias+'_CODOPE +'+cAlias+'_CODEMP+ '+cAlias+'_MATRIC + '+cAlias+'_TIPREG)'),;
						 xFilial('BA1') + &(cAlias+'->('+cAlias+'_CODOPE +'+cAlias+'_CODEMP+ '+cAlias+'_MATRIC + '+cAlias+'_TIPREG + '+cAlias+'_DIGITO)') )
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
cOpeOri		:= aRet[16]

cCodPad		:= &(cAlias+'->'+cAlias+'_CODPAD')
cCodPro		:= &(cAlias+'->'+cAlias+'_CODPRO')
cCodRda		:= &(cAlias+'->'+cAlias+'_CODRDA')

aRet 	:= plctpBR8(cCodPad, cCodPro)
cClasse	:= aRet[1]
cTpProc	:= aRet[2]

aRet 		:= plctpBAU(cCodRDA)
cBauEst		:= aRet[1]
cBauTipPre	:= aRet[2]
cBauCopCre	:= aRet[3]
cBauRecPro	:= aRet[4]
cBauTPPag	:= aRet[5]
cOpeRda		:= aRet[6]

if lAchouBA1

	dData := ctod( '01/' + (cAlias)->&(cAlias + '_MESPAG') + '/' + (cAlias)->&(cAlias + '_ANOPAG') )

	//tipo de beneficiario
	cBusca := plctpTPB(cBi3TpBen, dData, lB5F, cOpeRda)		

	plLogDet( cBusca, 'BAZ_TPBENE', 'BI3_TPBEN', 'Tipo de Beneficiario', nil, cRotina )

	//Tipo do Contrato para Faturamento
	aRet 	:= plctpTCF(nil, nil, nil, nil, cTipCo)
	cBusca  := aRet[3]

	plLogDet( cBusca, 'BAZ_TPFATU', 'cTipCo', 'Tipo do Contrato para Faturamento', nil, cRotina )

	//tipo de servico                                          
	//Este campo analisa condicoes para classificar o tipo de servico,    
	//conforme segue:                                                     
	//1 - AMBULATORIAL													   
	//No caso de guias ambulatoriais, deve-se localizar o procedimento ou 
	//o seu grupo no cadastro de Natureza de Saude.					   
	//2 - INTERNACAO													   
	//No caso de guias de internacao, deve-se obedecer as regras abaixo:  
	//- Honorario Medico: Todo procedimento pago a Rda PF.				   
	//- Exames: Procedimentos classificados cfme natureza de saude		   
	//- Terapias: Procedimentos classificados cfme natureza de saude      
	//- Material: Procedimentos da classe do parametro MV_PLCT06		   
	//- Medicamento: Procedimentos da classe do parametro MV_PLCT09	   
	//- Outros: Caso nao se enquadre em nenhuma das combinacoes anteriores
	//                                                                    
	//Obs.: Caso o material ou medicamento seja pago para um rda que foi  
	//      pago um procedimento, o material ou medicamento deve ser con- 
	//      tabilizado na mesma conta do procedimento. Regra valida para  
	//      guias Ambulatoriais e guias de Internacao.                    

	// Fixo espaço duplo para o Tipo de Faturamento, que só é utilizado nos lançamentos
	// do tipo 4-CO em PP e tipo 5-Co-Participação.
	if cTipCO $ '0/5'

		cBusca	+= space(2)
	
	//Guias Ambulatoriais
	elseIf &(cAlias+'->'+cAlias+'_ORIMOV') == "1" .and. cAlias == 'BD6'			
		
		// Se for Mat/Med/Txas e Consulta
		if cTpProc $ '1/2/3/4/5/7/8' .and. cCodPro $ cCtpl06
			
			cBusca += "13" //Demais despesas

		else
			
			if BFA->(msSeek(xFilial("BFA")+cCodPro+cGruGen))
				
				if BF0->(msSeek(xFilial("BF0")+cGruGen+BFA->BFA_CODIGO))
					cBusca += BF0->BF0_TPUNIM
				else
					cBusca += space(2)
				endIf

			else

				lAchou  := .f.
				aNivPro := PLSESPNIV(cCodPad)
				
				for nTmp := 1 to aNivPro[1]
					
					cTmp := subStr(cCodPro,aNivPro[2][nTmp][1],aNivPro[2][nTmp][2])
					cTmp += replicate("0",(7 - aNivPro[2][nTmp][2]))
					
					if BFA->(msSeek(xFilial("BFA")+cTmp+cGruGen))
						
						if BF0->(msSeek(xFilial("BF0")+cGruGen+BFA->BFA_CODIGO))
							cBusca += BF0->BF0_TPUNIM
							lAchou := .t.
							exit
						endIf

					endIf
					
				next
				
				if ! lAchou
					cBusca += "12" //Outros Atendimentos Ambulatoriais
				endIf
				
			endIf
			
		endIf

	//Guias de Internacao	
	else 
		
		lAchou  := .f.

		// Classe de Procedimentos para HM
		if cClasse $ cCtpl11			
			cBusca += "06" //Honorario Medico
			lAchou  := .t.
		endIf
		
		if ! lAchou
			
			if BFA->(msSeek(xFilial("BFA")+cCodPro+cGruGen))

				if BF0->(msSeek(xFilial("BF0")+cGruGen+BFA->BFA_CODIGO))
			
					if subStr(BF0->BF0_CODIGO,1,3) == "1.2"
						
						cBusca += "07" //Exames
						lAchou := .t.

					elseIf subStr(BF0->BF0_CODIGO,1,3) == "1.3"
						
						cBusca += "08" //Terapias
						lAchou := .t.
						
					//Inserida em 19/02/08 para contemplar personalização
					elseIf ! empty(BF0->BF0_TPUNIM)
					
						cBusca += BF0->BF0_TPUNIM
						lAchou := .t.

					endIf

				endIf

			endIf
			
			if ! lAchou

				aNivPro := PLSESPNIV(cCodPad)
				
				for nTmp := 1 to aNivPro[1]
					
					cTmp := subStr(cCodPro,aNivPro[2][nTmp][1],aNivPro[2][nTmp][2])
					cTmp += replicate("0",(7 - aNivPro[2][nTmp][2]))
					
					if BFA->(msSeek(xFilial("BFA")+cTmp+cGruGen))

						if BF0->(msSeek(xFilial("BF0")+cGruGen+BFA->BFA_CODIGO))
					
							if subStr(BF0->BF0_CODIGO,1,3) == "1.2"
								
								cBusca += "07" //Exames
								lAchou := .t.
								exit

							elseIf subStr(BF0->BF0_CODIGO,1,3) == "1.3"
								
								cBusca += "08" //Terapias
								lAchou := .t.
								exit
								
							//Inserida em 19/02/08 para contemplar personalização
							elseIf ! empty(BF0->BF0_TPUNIM)
							
								cBusca += BF0->BF0_TPUNIM
								lAchou := .t.
								exit
								
							endIf

						endIf

					endIf
					
				next
				
			endIf
			
		endIf
		
		if ! lAchou

			do case
				case cTpProc == '1/5/7'
					cBusca += "09" //Materiais Medicos
				case cTpProc == "2"
					cBusca += "10" //Medicamentos
				otherWise
					cBusca += "11" //Outras Despesas
			endCase

		endIf
		
	endIf
	
	plLogDet( cBusca, 'BAZ_TPUNIM', '', 'Tipo de Procedimento Contratado', nil, cRotina )

	//tipo de ato                                                          
	cBusca += plctpTPA(nil, nil, nil, cTipAto, nil, nil, nil, 'BFQ')
	
	plLogDet( cBusca, 'BAZ_TPATO', 'BFQ_ATOCOO', 'Tipo de Ato', nil, cRotina )

	//plano regulamentado
	cBusca += plctpPLR(cBi3ApoSrg)
	
	plLogDet( cBusca, 'BAZ_REGPLN', 'BI3_APOSRG', 'Plano Regulamentado', nil, cRotina )

	//tipo de plano/contrato
	cBusca += plctpPLC(cBi3Tipo, cBi3TipCon)

	plLogDet( cBusca, 'BAZ_TPPLN', 'BI3_TIPO|BI3_TIPCON', 'Tipo de Plano/Contrato', nil, cRotina )

	//patrocino                                              
	cBusca += plctpPTC(cBi3Tipo, cTipoBG9, cPatroc)
	
	plLogDet( cBusca, 'BAZ_PATROC', 'BQC_PATROC|BG9_TIPO|BI3_TIPO', 'Patrocinio', nil, cRotina )

	//segmentacao
	cBusca	+= plctpSEG(cBi3CodSeg)

	plLogDet( cBusca, 'BAZ_SEGMEN', 'BI3_CODSEG', 'Segmentacao', nil, cRotina )

	plLogDet( cBusca+cCodPla, 'BAZ_CODPLA', 'BA1_CODPLA|BA3_CODPLA', 'Plano', nil, cRotina )
	plLogDet( cBusca+cCodPla+cGruOpe, 'BAZ_GRUOPE', 'BA0_GRUOPE', 'Grupo Operadora', nil, cRotina )

	//Analisa condição do faturamento, se foi realizado no mês da competência, 
	//se foi adiantado ou postergado, para definir qual conta pegar, conforme a
	//condição da variável lMesFat.                                            
	lMesFat	:= .t.

	// Em lançamento a débito, verifica se a guia é de competência anterior a emissão do título
	// ou seja, faturamento postergado.
	// A crédito, seria utilizado para faturamento antecipado de mensalidades, não aplicável neste programa.
	if cNatLct == 'D'

		// PARAMETROS: DATA / OPERADORA / EXIBE HELP / TABELA / PROCEDIMENTO
		aRetAux := PLSXVLDCAL(SE1->E1_EMISSAO,PLSINTPAD(),.f.,&(cAlias+'->'+cAlias+'_CODPAD'),&(cAlias+'->'+cAlias+'_CODPRO'))
	
		// Retorno
		// cAno := aRetAux[4]
		// cMes := aRetAux[5]
		
		// Verifica se foi possível obter a competência com base na data enviada, senão mantém lMesFat = TRUE
		if Len(aRetAux) >= 5

			cDtEmis	:= aRetAux[4]+aRetAux[5]
			cDtComp	:= &(cAlias+'->('+cAlias+'_ANOPAG+'+cAlias+'_MESPAG)')
		
			if cDtComp < cDtEmis
				lMesFat	:= .f.
			endIf

		endIf

	endIf

	lAchou	:= .f.
	lLocBAZ := .f.
	
	//Tratamento ao Grupo de Operadoras.                        
	//Valido somente para Tipo de Beneficiario igual a          
	//Exposto Nao Beneficiario (2) ou Prestacao de Servicos (4).
	//RC - 06/08/07                                             
	if cBi3TpBen $ '2/4'

		// Procura combinacao com Grupo de Operadora
		if !(lLocBAZ := BAZ->(msSeek(xFilial("BAZ")+cBusca+cCodPla+cGruOpe, .f.)))
			lLocBAZ := BAZ->(msSeek(xFilial("BAZ")+cBusca+space(4)+cGruOpe, .f.))
		endIf

		if lLocBAZ

			do case
				case cNatLct == 'D' .and. cTipLct $ 'I/P' .and. lMesFat
					cRet := iIf(empty(BAZ->BAZ_CTADB1), 'C->'+cBusca, BAZ->BAZ_CTADB1 )
				case cNatLct == 'D' .and. cTipLct $ 'I/P' .and. !lMesFat
					cRet := iIf(empty(BAZ->BAZ_CTADB2), 'C->'+cBusca, BAZ->BAZ_CTADB2 )
				case cNatLct == 'C' .and. cTipLct $ 'I/P'
					cRet := iIf(empty(BAZ->BAZ_CTACR1), 'C->'+cBusca, BAZ->BAZ_CTACR1 )
				case cNatLct == 'D' .and. cTipLct == 'C' .and. lMesFat
					cRet := iIf(empty(BAZ->BAZ_CANDB1), 'C->'+cBusca, BAZ->BAZ_CANDB1 )
				case cNatLct == 'D' .and. cTipLct == 'C' .and. !lMesFat
					cRet := iIf(empty(BAZ->BAZ_CANDB2), 'C->'+cBusca, BAZ->BAZ_CANDB2 )
				case cNatLct == 'C' .and. cTipLct == 'C'
					cRet := iIf(empty(BAZ->BAZ_CANCR1), 'C->'+cBusca, BAZ->BAZ_CANCR1 )
				otherWise
					cRet := "L->"+cBusca+"|Param.Invalida:|Nat.Lancto:|'"+cNatLct+"'|Tipo Lancto:|'"+cTipLct+"'|"
			endCase

		else                   
			cRet	:= 'N->'+cBusca
			lAchou	:= .f.
		endIf
		
	endIf

	lLocBAZ := .f.
	
	// Se não achou, procura combinacao sem Grupo de Operadora
	if !lAchou

		if !(lLocBAZ := BAZ->(msSeek(xFilial('BAZ')+cBusca+cCodPla, .f.)))
			lLocBAZ := BAZ->(msSeek(xFilial('BAZ')+cBusca+space(4), .f.))
		endIf
		
		if lLocBAZ

			do case
				case cNatLct == 'D' .and. cTipLct $ 'I/P' .and. lMesFat
					cRet := iIf(empty(BAZ->BAZ_CTADB1), 'C->'+cBusca, BAZ->BAZ_CTADB1 )
				case cNatLct == 'D' .and. cTipLct $ 'I/P' .and. !lMesFat
					cRet := iIf(empty(BAZ->BAZ_CTADB2), 'C->'+cBusca, BAZ->BAZ_CTADB2 )
				case cNatLct == 'C' .and. cTipLct $ 'I/P' //.and. lMesFat
					cRet := iIf(empty(BAZ->BAZ_CTACR1), 'C->'+cBusca, BAZ->BAZ_CTACR1 )
				case cNatLct == 'D' .and. cTipLct == 'C' .and. lMesFat
					cRet := iIf(empty(BAZ->BAZ_CANDB1), 'C->'+cBusca, BAZ->BAZ_CANDB1 )
				case cNatLct == 'D' .and. cTipLct == 'C' .and. !lMesFat
					cRet := iIf(empty(BAZ->BAZ_CANDB2), 'C->'+cBusca, BAZ->BAZ_CANDB2 )
				case cNatLct == 'C' .and. cTipLct == 'C' //.and. lMesFat
					cRet := iIf(empty(BAZ->BAZ_CANCR1), 'C->'+cBusca, BAZ->BAZ_CANCR1 )
				otherWise
					cRet := "L->"+cBusca+"|Param.Invalida:|Nat.Lancto:|'"+cNatLct+"'|Tipo Lancto:|'"+cTipLct+"'|"
			endCase

		else

			if 'X' $ cBusca
				cRet := 'L->'+cBusca
			else
				cRet := 'N->'+cBusca
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
	
	cProc	:= 'Lt.Cobr:'+AllTrim(Subs(&(cAlias+'->'+cAlias+'_NUMFAT'),5,8))+'|Tit:'+AllTrim(&(cAlias+'->'+cAlias+'_PREFIX'))+AllTrim(&(cAlias+'->'+cAlias+'_NUMTIT'))+AllTrim(&(cAlias+'->'+cAlias+'_PARCEL'))+AllTrim(&(cAlias+'->'+cAlias+'_TIPTIT'))
	cProc	+= '|Matr:'+AllTrim(&(cAlias+'->('+cAlias+'_OPEUSR+'+cAlias+'_CODEMP+'+cAlias+'_MATRIC+'+cAlias+'_TIPREG)') )+iIf(cAlias=='BD6','|Nome:'+AllTrim(Subs(&(cAlias+'->'+cAlias+'_NOMUSR'),1,40)),'')
	cProc	+= '|Prod: N/Enc. |Grp.Emp:'+AllTrim(&(cAlias+'->'+cAlias+'_CODEMP'))
	cProc	+= '|Contr:'+AllTrim(BA1->BA1_CONEMP)+'/'+AllTrim(BA1->BA1_VERCON)+'|Sub:'+AllTrim(BA1->BA1_SUBCON)+'/'+AllTrim(BA1->BA1_VERSUB)
	cProc	+= '|Vl.Tit.:'+StrZero(SE1->E1_VALOR,10,2)
	cProc	+= '|Usuario nao encontrado-CTBPLS11'
	cRet	:= 'L->'

else
	
	cProc	:= 'Lt.Cobr:'+AllTrim(Subs(&(cAlias+'->'+cAlias+'_NUMFAT'),5,8))+'|Tit:'+AllTrim(&(cAlias+'->'+cAlias+'_PREFIX'))+AllTrim(&(cAlias+'->'+cAlias+'_NUMTIT'))+AllTrim(&(cAlias+'->'+cAlias+'_PARCEL'))+AllTrim(&(cAlias+'->'+cAlias+'_TIPTIT'))
	cProc	+= '|Matr:'+AllTrim(&(cAlias+'->('+cAlias+'_OPEUSR+'+cAlias+'_CODEMP+'+cAlias+'_MATRIC+'+cAlias+'_TIPREG)') )+iIf(cAlias=='BD6','|Nome:'+AllTrim(Subs(&(cAlias+'->'+cAlias+'_NOMUSR'),1,40)),'')
	cProc	+= '|Prod:'+Subs(cPlano,1,4)+'/'+Subs(cPlano,5,3)+'|Grp.Emp:'+AllTrim(&(cAlias+'->'+cAlias+'_CODEMP'))
	cProc	+= '|Contr:'+AllTrim(BA1->BA1_CONEMP)+'/'+AllTrim(BA1->BA1_VERCON)+'|Sub:'+AllTrim(BA1->BA1_SUBCON)+'/'+AllTrim(BA1->BA1_VERSUB)
	//cProc	+= '|Vl.Evto:'+StrZero(iIf(cAlias=='BD6',iIf(cTipCo$'0/1/2', aRetVlr[nPosLct], aRetTxa[nPosLct]),BD6->BD6_VLRMAN),10,2)
	cProc	+= '|Vl.Tit.:'+StrZero(SE1->E1_VALOR,10,2)
	cProc	+= iIf(cTipLct=='D','|Deb/Cred:D',iIf(cTipLct=='C','|Deb/Cred:C',''))

endIf

// Aciona gravacao de Log
if Subs(cRet,1,1) $ 'CLN'

	cProc += iIf(!empty(cGruOpe),'|Grupo Oper:'+cGruOpe,'')
	cProc += iIf(lMesFat, '|Mes Faturamento', '|Mes Faturamento Postergado')

	if Subs(cRet,1,1) $ 'C'
		cProc += '|Chave:'+cBusca+'|Sem Conta na Combinacao     |Retorno:'+cRet
	elseIf Subs(cRet,1,1) $ 'N'
		cProc += '|Chave:'+cBusca+'|Falta Cadastrar Combinacao  |Retorno:'+cRet
	else
		cProc += '|Chave:'+cBusca+'|Impossivel Montar Combinacao|Retorno:'+cRet
	endIf

	// Grava log de registro com problema
	PlGrvLog(cProc, 'FAT', 1)
	
endIf

//Grava detalhamento
plLogDet(nil, nil, nil, nil, nil, cRotina, ( subs(cRet,1,1) $ 'CLN' ) )

restArea(aArea)

return(cRet)
