#include 'protheus.ch'
#include 'topconn.ch'

static lCTBA080	:= ( 'CTBA080' == funName() )

/*/{Protheus.doc} PLRETDAD
Busca dinamica da conta, conforme configuracao flexivel
no arquivo especifico BAV para contabilizar comissoes.   

Este programa fara uma busca de conta conforme a string busca
(cBusca) que será montada. Esta string ira variar conforme a 
combinacao de informacoes que serao avaliadas.               
Os arquivos estao sempre posicionados no momento do          
lancamento, portanto somente sera posicionado o arquivo de   
combinacoes de contas.                                       

Esta variável nTipo identifica se o campo tratado para retorno da conta 
será:                                                                   
1 --> BAV_CONTA - conta débito contra-partida da transitória do controle
de comissões na geração das faturas.                                    
2 --> BAV_CTAENC - conta débito contra-partida dos encargos na baixa    
dos títulos.                                                            
3 --> BAV_CONTA -conta crédito contra-partida da transitória do controle
de comissões na exclsão das faturas. Para este caso, em relação a opção 
do código 1, somente modifica o log.                                    

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
function PLSCTP04(notUSED, nTipo, notUSED, cCtaFix, cDebCre, lB5F)
local aArea     := getArea()
local cCodPla   := space(4)
local cCodSeg	:= Space(3)
local cRet		:= ''
local cBusca	:= ''
local cOpeOri   := ''
local cCodInt	:= ''
local cPatroc	:= ''
local cContac	:= ''
local cGruOpe	:= ''

local cBi3ModPag:= ''
local cBi3ApoSrg:= ''
local cBi3TipCon:= ''
local cBi3Tipo	:= ''
local cBi3CodSeg:= ''
local cTipoBG9	:= ''
local cLog		:= ''
local cLog1		:= ''
local cPlano	:= ''
local cBi3TpBen	:= ''
local cBG9Tipo	:= ''
local cRotina	:= 'PLSCTP04'

default notUSED 	:= nil
default nTipo 	:= 1
default cCtaFix	:= ''
default cDebCre	:= 'D'

if lCTBA080
	return('1')
endIf

//busca plano do beneficiario
aRet 		:= plctpBA1( xFilial('BA1') + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) )
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
cOpeOri		:= aRet[16]

//tipo de beneficiario
cBusca := plctpTPB(cBi3TpBen, dDataBase, lB5F)

plLogDet( cBusca, 'BAV_TPBENE', 'BI3_TPBEN', 'Tipo do Beneficiario', nil, cRotina )

//modalidade de cobranca                                      
cBusca += plctpMDC(cBi3ModPag)

plLogDet( cBusca, 'BAV_MODCOB', 'BI3_MODPAG', 'Modalidade de Cobranca', nil, cRotina )

//plano regulamentado
cBusca	+= plctpPLR(cBi3ApoSrg)

plLogDet( cBusca, 'BAV_REGPLN', 'BI3_APOSRG', 'Plano Regulamentado', nil, cRotina )

//tipo de plano/contrato
cBusca += plctpPLC(cBi3Tipo, cBi3TipCon)

plLogDet( cBusca, 'BAV_TPPLN', 'BI3_TIPO|BI3_TIPCON', 'Tipo de Plano/Contrato', nil, cRotina )

//patrocino                                              
cBusca += plctpPTC(cBi3Tipo, cTipoBG9, cPatroc)

plLogDet( cBusca, 'BAV_PATROC', 'BQC_PATROC|BG9_TIPO|BI3_TIPO', 'Patrocinio', nil, cRotina )

//segmentacao
cCodSeg	:= plctpSEG(cBi3CodSeg)

plLogDet( cBusca+cCodSeg, 'BAV_SEGMEN', 'BI3_CODSEG', 'Segmentacao', nil, cRotina )

plLogDet( cBusca+cCodSeg+cCodPla, 'BAV_CODPLA', 'BA1_CODPLA|BA3_CODPLA', 'Plano', nil, cRotina )

if nTipo == 0
	cRet := cCtaFix
else
	BAV->(dbSetOrder(1))
	if BAV->(msSeek(xFilial('BAV')+cBusca+cCodSeg+cCodPla, .f.))

		if nTipo == 2
			cRet := if(empty(BAV->BAV_CTAENC), 'C->'+cBusca+cCodSeg+cCodPla, BAV->BAV_CTAENC)
		else
			cRet := if(empty(BAV->BAV_CONTA), 'C->'+cBusca+cCodSeg+cCodPla, BAV->BAV_CONTA)
		endIf

	elseif BAV->(msSeek(xFilial('BAV')+cBusca+cCodSeg+Space(4), .f.))

		if nTipo == 2
			cRet := if(empty(BAV->BAV_CTAENC), 'C->'+cBusca+cCodSeg, BAV->BAV_CTAENC)
		else
			cRet := if(empty(BAV->BAV_CONTA), 'C->'+cBusca+cCodSeg, BAV->BAV_CONTA)
		endIf

	elseIf BAV->(msSeek(xFilial('BAV')+cBusca+Space(3)+Space(4), .f.))

		if nTipo == 2
			cRet := iIf(empty(BAV->BAV_CTAENC), 'C->'+cBusca, BAV->BAV_CTAENC )
		else
			cRet := iIf(empty(BAV->BAV_CONTA),  'C->'+cBusca, BAV->BAV_CONTA  )
		endIf

	else

		if ' ' $ cBusca
			cRet := 'L->'+cBusca+cCodSeg+cCodPla
		else
			cRet := 'N->'+cBusca+cCodSeg+cCodPla
		endIf

	endIf

endIf

//ponto de entrada para corrigir ou implemnetar a chave de busca
if existBlock("PLCTPBUS")

	cRet := execBlock("PLCTPBUS", .f., .f., { cRotina, 'BAV', cBusca+cCodSeg+cCodPla, cRet } )
	
	plLogDet( cRet, 'PLCTPBUS', '', 'Ajustado por ponto de entrada', nil, cRotina )		
	
endIf


// Aciona gravacao de Log
cLog	:= 'Chave:'+cBusca+cCodSeg+cCodPla+'|Conta:'+cRet
cLog	+= '|Comp:'+BXQ->BXQ_MES+'/'+BXQ->BXQ_ANO+'|Titulo:'+BXQ->(BXQ_PREFIX+BXQ_NUM+BXQ_PARC+BXQ_TIPO)
cLog	+= '|Cod.Vend:'+BXQ->BXQ_CODVEN+'|Cod.Eqp:'+BXQ->BXQ_CODEQU+'|Parcela:'+BXQ->BXQ_NUMPAR
cLog	+= '|Dt.Ger.:'+dToC(BXQ->BXQ_DATA)

cLog1	:= '|Matric:'+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
cLog1	+= '|MatAnt:'+BA1->BA1_MATANT
cLog1	+= '|Cod.Plano:'+BI3->BI3_CODIGO+'/'+BI3->BI3_VERSAO

if cBG9Tipo == "1" //Pessoa Fisica
	cLog1	+= '|Grp.Fis:'+BA1->BA1_CODEMP
else
	cLog1	+= '|Grp.Emp:'+BA1->BA1_CODEMP+'|Contr:'+BQC->BQC_NUMCON+'/'+BQC->BQC_VERCON
	cLog1	+= '|Subcont:'+BQC->BQC_SUBCON+'/'+BQC->BQC_VERSUB
endIf

cLog1 += '|Tipo:'
cLog1 += '|Deb/Cre:'+iIf(cDebCre=="D","Débito","Crédito")

if subs(cRet,1,1) $ 'CLN'
	
	if subs(cRet,1,1) $ 'C'
		cLog1	+= '|Falta Conta para Combinacao'
	elseIf subs(cRet,1,1) $ 'N'
		cLog1	+= '|Falta Combinacao'
	else
		cLog1	+= '|Combinacao Invalida'
	endIf

	// Grava log de registro com problema
	PlgrvLog( cLog+cLog1, iIf(nTipo==2,"COM|ENC", iIf(nTipo==3,"COM|EXC", "COM|GER" ) ), 1 )
	
endIf

//Grava detalhamento
plLogDet(nil, nil, nil, nil, nil, cRotina, ( subs(cRet,1,1) $ 'CLN' ) )

restArea(aArea)

return(cRet)
