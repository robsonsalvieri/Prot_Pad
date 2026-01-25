#include 'protheus.ch'
#Include 'TopConn.ch'

static lCTBA080	:= ( 'CTBA080' == funName() )

/*/{Protheus.doc} PLSCTP05
Retorna o tipo de faturamento para definir se o lancamento
padronizado deve ou nao ser executado para este registro         		  

MV_PLCT13 --> Conta para contabilizar Tx.Adm. em conta unica      
cTipLct - Tipo do Lançamento: I-Inclusão / C-Cancelamento / B-Baixa / P-Provisão (para títulos excluídos antes de contabilizar)

@author  PLS TEAM
@version P12
@since   21.03.17
/*/
function PLSCTP06(notUSED, cTipLct)
local aArea     := getArea()
local cCtpl13	:= getNewPar('MV_PLCT13','3311810100001')
local cRet      := ''
local cPlano    := ''
local cCodPla   := ''
local cOpeOri   := ''
local cBi3ModPag:= ''
local cBi3ApoSrg:= ''
local cBi3TipCon:= ''
local cBi3Tipo  := ''
local cBi3CodSeg:= ''
local cBi3TpBen := ''
local cTipoBG9	:= ''
local cPatroc	:= ''
local cContac	:= ''
local cGruOpe	:= ''
local lAchouBA1	:= .f.
local aRet      := {}
local lFoundREG := .t.
local cCodPla   := space(4)

default notUSED := nil
default cTipLct	:= 'I'

if lCTBA080
	return('1')
endIf

cAlias	:= 'BM1'

//Inserida verificacao de posicionamento devido alteracao no padrao.
if SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) <> &(cAlias+'->('+cAlias+'_PREFIX+'+cAlias+'_NUMTIT+'+cAlias+'_PARCEL+'+cAlias+'_TIPTIT)')
	
	&(cAlias+'->(dbSetOrder(4))')

	lFoundREG := &( cAlias+'->(msSeek(xFilial("'+cAlias+'")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO),.F.))')
	
endIf

if lFoundREG

    //busca plano do beneficiario
    aRet 		:= plctpBA1( xFilial('BA1') + &(cAlias+'->('+cAlias+'_CODINT +'+cAlias+'_CODEMP+ '+cAlias+'_MATRIC + '+cAlias+'_TIPREG)'), xFilial('BA1')+&(cAlias+'->'+cAlias+'_MATUSU') )
    cPlano     	:= aRet[1]
    cCodPla    	:= aRet[2]
    cOpeOri    	:= aRet[3]
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

    if lAchouBA1

        //Tipo do Lancamento
        //1 - Demais modalidades (Custo Operacional)		                 
        //2 - Mensalidade PP                                                
        //3 - Mensalidade CO                                                
        //4 - Custo Operacional (CO em PP)                                  
        //5 - Co-Participação				                                 
        //6 - Debitos / Creditos                                            

        Do Case

            Case allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '104,127,134,137,138,139,140,141,142,143,144,145,156,157,158,159,160,161,162,163,164,165,166,167'
                // Lancamentos de Custo Operacional -> retorna 1-Demais modalidades
                // 104	Custo Operac. Servicos Medicos
                // 127- Custo Operacional Serv.Acessorios
                // 134- Custo Operacional outros servicos
                // 137-	Producao de coop / PF
                // 138-	Producao de coop / PJ
                // 139- Servico coop PF outras operadoras
                // 140-	Servico coop PJ outras operadoras
                // 141-	SERV.AUXILI.DE DIAGN. E TER
                // 142-	SERV.AUXILIARES OUTRAS UNIM
                // 143-	Prod nao cooperados
                // 144- Prod nao coop outras operadoras
                // 145- Custos em servicos proprios
                // 156- Taxa custo oper serv medicos
                // 157- Taxa adm serv acessorios
                // 158- Taxa outros servicos
                // 159- Taxa prod coop / PF
                // 160- Taxa prod coop / PJ
                // 161- Taxa serv coop PF / outras operadoras
                // 162- Taxa serv coop PJ / outras operadoras
                // 163- Taxa SADT
                // 164- Taxa SADT / outras operadoras
                // 165- Taxa prod nao coop
                // 166- Taxa prod nao coop / outras operadoras
                // 167- Taxa custo serv proprios

                //MODALIDADE DE COBRANCA                                      
                //Verifica se a modalidade eh Pre Pagamento, senao classifica 
                //como compra de Custo Operacional.			       		   
                //Variavel cBi3Modpag:                                        
                //1 - Pre-Pagamento                                           
                //2 - Demais modalidades									   
                //Retorno do programa:                                        
                //1 - Demais Modalidades (C.O.)                               
                //4 - Compra de procedimentos (C.O.) em pré-pagamento		   
                
                //Modificado em 05/03/08 pois gerava duplicidade em casos de   
                //compra de procedimento em C.O., onde contabilizava no lancto 
                //P01-002 e posteriormente no lancto P07-nnn.                  
                //Força retorno 4 (compra em CO) para ser contabilizado somente
                //no momento da abertura da guia (P07). Roger C.               
                cRet := '4'
                
            // revisado RN136 - 30/10/07 - RC
            Case allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '101,102,103,107,110,118,133,146'

                // Lancamentos de Mensalidades PP ou CO, retorna 2-Mensalidade PP ou 3-Mensalidade CO
                // 101- Mensalidade
                // 102- Opcional
                // 103- Taxa de Inscricao
                // 107- Cartao de Identificacao
                // 110- Valor do Agravo
                // 118- Mensalidade Retroativa
                // 133- Taxa de Adesao do Opcional
                // 146- Opcional Retroativo
                
                //MODALIDADE DE COBRANCA                                      
                //Verifica se a modalidade eh Pre Pagamento, senao classifica 
                //como mensalidade sobre Custo Operacional.			       
                //Variavel cBi3Modpag:                                        
                //1 - Pre-Pagamento                                           
                //2 - Demais modalidades									   
                //Retorno do programa:                                        
                //2 - Mensalidade PP                                          
                //3 - Mensalidade C.O.										   
                cRet := Iif( allTrim(cBi3ModPag) $ '1', '2', '3' )
                
            // revisado RN136 - 31/10/07 - RC
            Case allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '120,123'

                // Lancamentos de Custo operacional em pre-pagamento (CO em PP)
                // 120- Custo operacional compras pagamento no ato
                // 123- Custo operacional compras pagamento a faturar
                cRet := '4'
                
            // Taxas administrativas
            Case allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '117,122,125'

                // Analisa se tem conta fixa para lancamentos de Taxa Adm. Se houver, retorna 2-Mensalidade PP somente
                // para entrar no programa CTBPLS05 e se não houver retorna "4-Custo Oper em PP" para não entrar nesse
                // programa, pois será contabilizado no CTBPLS11.
                // 117- Taxa Administrativa
                // 122- Taxa Administrativa compras pagamento no ato
                // 125- Taxa Administrativa compras pagamento a faturar

                cRet := Iif(!Empty(cCtpl13), '2', '4')
                
            // revisado RN136 - 31/10/07 - RC
            Case allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '116,121,124,147,148,149,150,151,152,153,154,155,168,169,170,171,172,173,174,175,176,177'

                // Lancamentos exclusivos de Co-Participacao
                // 116	Ft Moderador/Co-Participacao
                // 121- co-part compras pagto ato
                // 124- co-part compra a faturar
                // 147	PAR-SERV.MEDICOS COOPERADOS PF
                // 148	PAR-SERV.MEDICOS COOPERADOS-PJ
                // 149	PAR-SERV.COOP.PF-OUTRAS operadoras
                // 150	PAR-SERV. COOP. PJ OUTRAS operadoras
                // 151	PAR-SERV.AUXILI.OUTRAS operadoras
                // 152	PAR-SERV.AUX.SADT OUTRAS operadoras
                // 153	PAR-SERV.MEDICOS NAO COOPERADO
                // 154- prod nao coop / outras operadoras
                // 155- co-part serv proprios
                // 168- taxa ft / co-participacao
                // 169- taxa prod coop / PF
                // 170- taxa prod coop / PJ
                // 171- taxa serv coop / PF
                // 172- taxa serv coop / PJ
                // 173- taxa serv SADT
                // 174- taxa serv SADT / outras operadoras
                // 175- taxa prod nao coop
                // 176- taxa prod nao coop / outras operadoras
                // 177- taxa custos serv proprios
                cRet := '5'
                
            // revisado RN136 - 31/10/07 - RC ==> NECESSITA ALTERACAO, AGUARDANDO REGRA UVS
            Case allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '108'

                // 108- Reembolso de livre escolha -- arquivos BKD / BKE
                cRet := 'X'
                
            // revisado RN136 - 31/10/07 - RC ==> NECESSITA ALTERACAO, VALIDAR REGRA COM UVS
            Case allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '109'
            
                // 109- Via de boleto -- arquivo BEE
                //MODALIDADE DE COBRANCA                                      
                //Verifica se a modalidade eh Pre Pagamento, senao classifica 
                //como mensalidade sobre Custo Operacional.			       
                //Variavel cBi3Modpag:                                        
                //1 - Pre-Pagamento                                           
                //2 - Demais modalidades									   
                //Retorno do programa:                                        
                //2 - Mensalidade PP                                          
                //3 - Mensalidade C.O.										   
                cRet := Iif( allTrim(cBi3ModPag) $ '1', '2', '3' )
                
            // revisado RN136 - 31/10/07 - RC
            Case Subs(&(cAlias+'->'+cAlias+'_CODTIP'),1,1) = '9' .or. allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '111,113,128,129,130,131,132,135,136,180'
            
                // Trata lançamentos de faturamento de propriedade do cliente OU
                // Debitos e Creditos diversos - retorna 6 e busca conta na tabela BSQ ou BSP
                // 111- Juros do Mes Anterior
                // 113- Debitos servicos medicos
                // 128- Debito servicos acessorios
                // 129- Credito servicos medicos
                // 130- Credito servicos acessorios
                // 131- Credito odontologico
                // 132- Debito odontologico
                // 135- Debito outros servicos
                // 136- Credito outros servicos
                // 180- Debito servicos medicos

                cRet := '6'
                
            Otherwise
                cRet :=  'L->'
        EndCase

    endIf

endIf

//ponto de entrada para corrigir ou implemnetar a chave de busca
if existBlock("PLCTPBUS")

	cRet := execBlock("PLCTPBUS", .f., .f., { 'PLSCTP06', cAlias, '', cRet } )
	
	plLogDet( cRet, 'PLCTPBUS', '', 'Ajustado por ponto de entrada', nil, 'PLSCTP06' )		
	
endIf

if ( ! lFoundREG .or. ! lAchouBA1 )
    
    cProc	:= 'Lt.Cobr:'+subs(&(cAlias+'->'+cAlias+'_PLNUCO'),5,8)+'|Seq:'+&(cAlias+'->'+cAlias+'_SEQ')+'|Tit:'+&(cAlias+'->'+cAlias+'_NUMTIT')
    cProc	+= '|Matr:'+&(cAlias+'->('+cAlias+'_CODINT+'+cAlias+'_CODEMP+'+cAlias+'_MATRIC+'+cAlias+'_TIPREG+'+cAlias+'_DIGITO)')+'|Nome:'+Subs(&(cAlias+'->'+cAlias+'_NOMUSR'),1,20)
    cProc	+= '|Prod: N/Enc. |Grp.Emp:'+&(cAlias+'->'+cAlias+'_CODEMP')
    cProc	+= '|Contr:'+BA1->BA1_CONEMP+'/'+BA1->BA1_VERCON+'|Sub:'+BA1->BA1_SUBCON+'/'+BA1->BA1_VERSUB
    cProc	+= '|Tp.Fat:'+&(cAlias+'->'+cAlias+'_CODTIP')+'|Evto:'+&(cAlias+'->'+cAlias+'_CODEVE')
    cProc	+= '|Vl.Evto:'+strZero(&(cAlias+'->'+cAlias+'_VALOR'),9,2)+'|Vl.Tit.:|'+'0'
    cProc	+= '|Titulo nao Encontrado-PLSCTP06/'+CT5->(CT5_LANPAD+'-'+CT5_SEQUEN)+'/'+cAlias
    cRet	:=  'L->'
    
    PlgrvLog( cProc, 'PLSCTP06', 1 )

endIf

RestArea(aArea)

return(cRet)