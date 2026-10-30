#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#INCLUDE "PROTHEUS.CH"
#DEFINE _DEBUG   .F.   // Flag para Debuggear el codigo
#DEFINE _NOMIMPOST 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M100IRF  ³ Autor ³ Camila Januário     ³ Data ³ 23.01.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do IRF - Entrada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota),³±±
±±³          ³          B (base), V (valor).                              ³±±
±±³          ³ nPar02 - Item do documento fiscal.                         ³±±
±±³          ³ aPar03 - Array com as informacoes do imposto.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xRet - Retorna o valor solicitado pelo paremetro cPar01    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATXFIS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³31/07/2019³ARodriguez     ³DMINA-6748 CalcRetFis() obtiene CFO de      ³±±
±±³          ³               ³MaFisRet() COL                              ³±±
±±³04/09/2019³Oscar G.       ³DMINA-6870 CalcRetFis() redondeo de deci-   ³±±
±±³          ³               ³males COL                                   ³±±
±±³27/03/2020³Eduardo P.     ³DMINA-8462 CalcRetFis() ajuste para aplicar ³±±
±±³          ³               ³correctamente descuento COL                 ³±±
±±³10/01/2021³Luis Enríquez  ³DMINA-10739 CalcRetFis() corrección p/calcu-³±±
±±³          ³               ³culo de base de Ret. de Fuente en NCC cuando³±±
±±³          ³               ³se aplica descuento por ítem (COL)          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function M100IRF(cCalculo,nItem,aInfo) 

Local aRet
Local cFunct   := ""
Local aCountry := {}
Local lXFis    := .T.
Local aArea    := GetArea()
	
lXFis    := ( MafisFound() .And. ProcName(1)!="EXECBLOCK" )
aCountry := GetCountryList()
cFunct   := "M100IRF" + aCountry[aScan( aCountry, { |x| x[1] == cPaisLoc } )][3] //monta nome da funcao
aRet     := &(cFunct)(cCalculo,nItem,aInfo,lXFis) //executa a funcao do pais

RestArea(aArea)

Return aRet    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M100IRFUR ³ Autor ³ Camila Januário     ³ Data ³ 23.01.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do IRF - Entrada - Uruguai			               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ³±±
±±³          ³          B (base), V (valor).                               ³±±
±±³          ³ nPar02 - Item do documento fiscal.                          ³±±
±±³          ³ aPar03 - Array com as informacoes do imposto.               ³±±
±±³          ³ lPar04 - Define se e rotina automaticao ou nao.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xRet - Retorna o valor solicitado pelo paremetro cPar01     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Uruguai 					                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function M100IRFUR(cCalculo,nItem,aInfo,lXFadminis)

Local xRet
Local cRetFuent := ""
Local nDesconto,nBase,nAliq,nOrdSFC,nRegSFC,nVal,nVRet,nBaseAtu, nMoeda, nTaxaMoed
Local lRet, cGrpIRPF 
Local cTotal
Private clTipo	:= ""  


SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,")
SetPrvt("CCLASCLI,CCLASFORN,CMVAGENTE,NPOSFORN,NPOSLOJA,NTOTBASE,LRETCF")

lRet    := .F.
lRetCF  := .T. 
llRetIVA:= If(cPaisLoc == "URU", .F., llRetIVA)
cAliasRot  := Alias()                                            
cOrdemRot  := IndexOrd()
cTipo 	:= Iif( Type("cTipo")=="U","N",cTipo)
xRet	:=0

If cModulo$'FAT|TMK|LOJA|FRT'
	If FieldPos("A1_RETIRPF")>0     
		cRetFuent	:= Alltrim(SA1->A1_RETIRPF)
	Endif
	clTipo	 	:= Alltrim(SA1->A1_TIPO)	
Else
	cRetFuent   := Alltrim(SA2->A2_RETIRPF)
	clTipo		:= Alltrim(SA2->A2_TIPO)	
Endif	

If cRetFuent == "S" .And. clTipo$"1|2|3"
	
	nBase:=0
	nAliq:=0
	nDesconto:=0
	nVRet:=0
	cGrpIRPF:=""
	aValRet := {0,0}
	
	cZonFis := Space(02)
	If cModulo$'COM'
		cZonfis    := SA2->A2_EST
	ElseIf cModulo$'FAT'
		cZonfis    := SM0->M0_ESTENT
	EndIf
	
	cCFO := MaFisRet(nItem,"IT_CF")
	cTotal := MaFisRet(nItem,"IT_TOTAL")     
	
If cTotal > 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico no SFB existe SFB->ALIQ e nao apresenta tabela SFB->TABELA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SFB")
	dbSetOrder(1)
	If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
		If cCalculo$"AB"
			//Tira os descontos se for pelo liquido
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
				If SFC->FC_LIQUIDO=="S"
					nDesconto:=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				Endif
			Endif
			SFC->(DbSetOrder(nOrdSFC))
			SFC->(DbGoto(nRegSFC))
			nVal:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			nVal-=nDesconto
			nAliq:=SFB->FB_ALIQ		
			lRet := .F.
			If (clTipo=="3" .And. Alltrim(aInfo[X_IMPOSTO])=="IRN") .Or. Alltrim(aInfo[X_IMPOSTO])=="IR2"
				DbSelectArea("SFF")
				SFF->(DbSetOrder(5))
				SFF->(DbGoTop())
				If dbSeek(xFilial("SFF") + aInfo[X_IMPOSTO] + cCFO + cZonFis) 
					nAliq:=SFF->FF_ALIQ                
				Endif
				lRet := .T.			
			Else
				//Verifica na SFF se existe Imposto e Grupo correspondente para realizacao do calculo
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(DbGoTop())
				If FieldPos("B1_GRPIRPF")>0     
					If DbSeek(xFilial("SB1") + AvKey(MaFisRet(nItem,"IT_PRODUTO"),"B1_COD") )
						cGrpIRPF:=SB1->B1_GRPIRPF
						DbSelectArea("SFF")
						SFF->(DbSetOrder(9))
						SFF->(DbGoTop())
						If DbSeek(xFilial("SFF") + AvKey(aInfo[X_IMPOSTO],"FF_IMPOSTO") + AvKey(cGrpIRPF,"FF_GRUPO"))
							nAliq:=SFF->FF_ALIQ
							lRet := .T.
						Endif		
					Endif
				Endif		
			Endif				
		Else
			lRet:=.T.
		Endif
	Endif
EndIf	

If lRet
	Do Case
		Case cCalculo=="B"
			nVRet:= nVal
		Case cCalculo=="A"
			nVRet:=nAliq
		Case cCalculo=="V"
			nBase:=MaRetBasT(aInfo[X_NUMIMP],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[X_NUMIMP]))
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])		
			nTaxaMoed := 0
			nMoeda := 1
		   	If Type("M->F1_MOEDA")<>"U" 			   	
			    nMoeda := M->F1_MOEDA
			    nTaxaMoed := M->F1_TXMOEDA
			ElseIf Type("M->C7_MOEDA")<>"U"
				nMoeda := M->C7_MOEDA
			    nTaxaMoed := M->C7_TXMOEDA				
	        ElseIf Type("M->F2_MOEDA")<>"U"
	        	nMoeda := M->F2_MOEDA
			    nTaxaMoed := M->F2_TXMOEDA				
			ElseIf Type("M->C5_MOEDA")<>"U" 
				nMoeda := M->C5_MOEDA
			    nTaxaMoed := M->C5_TXMOEDA				
	        EndIf	        
	        nBaseAtu := xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed)        						
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   	   	//³Verifica o valor das retenções e base de IR acumulados ³
	   	   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÄÙ			
			aValRet := RetValIR()
			//aValRet[01] = base acumulada
			//aValRet[02] = retencao acumulada 				
			If (SFF->(FieldPos("FF_IMPORTE")) > 0) .and. (nBaseAtu+aValRet[1]) >= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)
				aValRet[1] := xMoeda(aValRet[1],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
				aValRet[2] := xMoeda(aValRet[2],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
				nVret := ((nBase + aValRet[1])*(nAliq/100))-aValRet[2]
				nVret := IIf(nVret>0,nVret,0) 			   		
			Else
				nVret := 0
			EndIF				
	EndCase
 Endif  
EndIf
  
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return(nVRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M100IRFCO ³ Autor ³ Camila Januário     ³ Data ³ 23.01.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do IRF - Entrada - Colômbia			               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ³±±
±±³          ³          B (base), V (valor).                               ³±±
±±³          ³ nPar02 - Item do documento fiscal.                          ³±±
±±³          ³ aPar03 - Array com as informacoes do imposto.               ³±±
±±³          ³ lPar04 - Define se e rotina automaticao ou nao.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xRet - Retorna o valor solicitado pelo paremetro cPar01     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Costa Rica				                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function M100IRFCO(cCalculo,nItem,aInfo,lXFis)

Local xRet
Local llRetIVA	:= .T.
Local clAgen	:= SuperGetMv( 'MV_AGENTE' , .F., , '' )
Local cRetFuent := ""
Local cContrib  := ""
Private clTipo	:= ""

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,")
SetPrvt("CCLASCLI,CCLASFORN,CMVAGENTE,NPOSFORN,NPOSLOJA,NTOTBASE,LRETCF")

lRet    := .F.
lRetCF  := .T.
cAliasRot  := Alias()
cOrdemRot  := IndexOrd()
cTipo 	:= Iif( Type("cTipo")=="U","N",cTipo)
xRet	:=0

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")
	
If !lXFis
	aItemINFO  := ParamIxb[1]
	aImposto   := ParamIxb[2]
	xRet:=aImposto
Else
	xRet:=0
Endif
nBase      := 0
clTipo	   := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Deve-se verificar se cEspecie pertence a NCC/NCE/NDC/NDE para que ocor-³
//³ra busca no SA1, caso contrario deve-se buscar no SA2(Arq.Proveedores) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo = "D"   // devolucao de venda 
	cTipoCliFor := SA1->A1_TPESSOA
	cRetFuent   := SA1->A1_RETFUEN
	cContrib    := SA1->A1_CONTRBE //CONTRIBUINTE    
	cAgRet      := SA1->A1_RETENED
Else
	cTipoCliFor := SA2->A2_TPESSOA
	cRetFuent   := Alltrim(SubStr(clAgen,3,1))
	cContrib    := SA2->A2_CONTRBE //CONTRIBUINTE
	cAgRet      := SA2->A2_RETENED
Endif
cZonFis := Space(02)
If cModulo$'COM'
	If SubStr(clAgen,3,1) != "S"                                                                                                                        
		llRetIVA	:= .F.
	EndIf		
	cZonfis    := SA2->A2_EST
ElseIf cModulo$'FAT'
	If SA1->A1_RETFUEN != 'S'
		llRetIVA	:= .F.
	EndIf		
	cZonfis    := SM0->M0_ESTENT
EndIf
	
//Cliente Tipo Persona Natural 
//1. Se for um proveedor "Regimen Comum" somente pode reter fuente se não for " Gran Contribuyente" 
/*If  (cTipoCliFor == "1" .AND. cContrib == "1")
	lRetCF := .F.
Else
	lRetCF := .T.
Endif COMENTADO DEVIDO A FNC 000000199602012*/ 
 /*
    1. Se for um proveedor "Regimen Comum" somente pode reter fuente se não for " Gran Contribuyente" 
	2. O proveedor quando é 'Regimen Simplificado" quando tem retenção de fuente é obrigatorio ter Retenção de IVA. 
    3. Se o proveedor é "Gran Contribuyente" somente pode reter fuente, não pode reter IVA. 
*/	
	
If  (cAgRet == "S") .OR. (cAgRet == "1")
	lRetCF := .T.
Else
	lRetCF := .F.           
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³             Verifica se Calcula Retencao en la Fuente:              ³
//³                        Cliente / Proveedor                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetCF
	If cRetFuent == "S"
		If !lXFis
			If llRetIVA
				CalcRetenEnt()
				xRet:=aImposto
			EndIf
		Else
			If llRetIVA
				xRet:=CalcRetFis(cCalculo,nItem,aInFo)
			EndIf
		Endif
	Endif
Endif

Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CALCRETEN ºAutor  ³Denis Martins       º Data ³  11/12/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao do Imposto X Tes - Entrada              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA460,MATA100                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CalcRetenEnt()
Local nDesconto	:=	0
Local nMoeda  := Max(SF2->F2_MOEDA,1)
Local nTotBase := 0
SetPrvt("NBASE,NFAXDE,NFAXATE")

nMoeda := IIf(Type("nMoedSel")	=="U", nMoeda ,Max(nMoedSel,1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca o CFO informado no PV - pode ter sido alt. devido o concepto  ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// CFO do pedido pode ter sido alterado, devido o concepto.
cCFO := SC6->C6_CF 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico no SFB existe SFB->ALIQ e nao apresenta tabela SFB->TABELA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Tira os descontos se for pelo liquido .Bruno
If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
	nDesconto	:=	aImposto[18]
Else
	nDesconto	:=	0
Endif

dbSelectArea("SFF")
dbGoTop()
dbSetOrder(5)
If dbSeek(xFilial("SFF") + aImposto[1] + cCFO)
	If FF_FLAG != "1"
		RecLock("SFF",.F.)
		Replace FF_FLAG With "1"
		Endif
		nFaxde  := SFF->FF_FXDE
		
		aImp:=ParamIxb[2]
		cImp:=aImp[1]
		cImpIncid:=aImp[10]
		If Len(Alltrim(cImpIncid)) >0 
			nTotBase:= 0
			nI:=At(cImpIncid,";" )
			nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
			nI:=At(cImpIncid,";" )
			nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
		
			While nI>1
				nE:=AScan(aItemINFO[6],{|x| x[1]==Left(cImpIncid,nI-1)})
				If nE>0
					nTotBase+=aItemINFO[6,nE,4]
				End
				cImpIncid:=Stuff(cImpIncid,1,nI,"")
				nI:=At(cImpIncid,";")
				nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
			End
		Else
				nTotBase := ( aItemINFO[3] + aItemINFO[4] + aItemINFO[5] - nDesconto ) //* nBase
		EndIf		
	
		If xMoeda(nTotBase,nMoeda,1)>= xMoeda(nFaxde,SFF->FF_MOEDA,1)
			nAliq   := SFF->FF_ALIQ
			nBase   := (SFF->FF_PERC / 100)
			aImposto[3]  := ( aItemINFO[3] + aItemINFO[4] + aItemINFO[5] - nDesconto ) //* nBase
			aImposto[2]  := nAliq
			lRet := .T.
		Else
			lRet := .F.
		Endif
	Endif

If lRet
	aImposto[4] := aImposto[3] * (aImposto[2]/100)
Endif
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CALCRETFISºAutor  ³Denis Martins       º Data ³ 11/12/1999  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao do Imposto X Tes - Entrada              º±±
±±º          ³Alterado para o uso da funcao MATXFIS (Marcello)            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA460,MATA100                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcRetFis(cCalculo,nItem,aInfo)
Local aConfTES   := {}
Local aDatosSFF  := {}
Local aImpRef    := {}
Local aImpVal    := {}
Local cCFO       := ""
Local cClaveSFF  := ""
Local cCpoLivro  := ""
Local cImpIncid  := ""
Local cImpuesto  := ""
Local cMvDescSai := SuperGetMv( 'MV_DESCSAI' , .F., , '1' )
Local cTes       := ""
Local lAplDesc   := .T.
Local lCalcItem  := .F.
Local lRet       := .F.
Local nAliq      := 0
Local nDesconto  := 0
Local nI         := 1
Local nImporte   := 0
Local nMoeda     := 1
Local nMoedaSFF  := 1
Local nTaxaMoed  := 1
Local nTotBase   := 0
Local nVal       := 0
Local nVRet      := 0
Local nBaseAUI	:=0
Local aAreaSFC := {}
Local aAreaSFB := {}
Local nAlqAUI  := SuperGetMv("MV_PERAUI",,0)

Static lRatVICol := FindFunction("RatVICol")
Static oJConfImp := JsonObject():New()
Static lCpoAlqAIU := SA1->(ColumnPos("A1_ALQAIU"))>0 .And. SA2->(ColumnPos("A2_ALQAIU"))>0

Default cCalculo := ""
Default nItem    := 0
Default aInfo    := {}

If MaFisRet(, "NF_CLIFOR") == 'C' .And. cMvDescSai == '1'
	lAplDesc := .F.
EndIf
                                              
If Type("M->F1_MOEDA")<>"U" 
	nMoeda:= M->F1_MOEDA      
	nTaxaMoed := M->F1_TXMOEDA	
ElseIf Type("M->C7_MOEDA")<>"U"
	nMoeda:= M->C7_MOEDA    
    nTaxaMoed := M->C7_TXMOEDA	
ElseIf Type("nMoedaPed")<>"U"	 .And. Type("nTxMoeda")<>"U"
	nMoeda:= nMoedaPed         
    nTaxaMoed := nTxMoeda
EndIf		

If nTaxaMoed==0
	nTaxaMoed:= RecMoeda(nMoeda)
EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³           Busca o CFO correspondente do documento                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCFO := MaFisRet(nItem,"IT_CF")
	cTes := MaFisRet(nItem, 'IT_TES' )

	If Len(aInfo) >= 2
		cImpuesto := aInfo[01] //Código de impuesto
		cCpoLivro := aInfo[02] //Campo libro
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico no SFB existe SFB->ALIQ e nao apresenta tabela SFB->TABELA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !oJConfImp:hasProperty(cImpuesto)
		oJConfImp[cImpuesto] := JsonObject():New()
		oJConfImp[cImpuesto]['FB_ALIQ'] := M100AlqSFB(cImpuesto) //Obtiene alícuota de tabla SFB
	EndIf

	nAliq := oJConfImp[cImpuesto]['FB_ALIQ']

	If !oJConfImp:hasProperty(cTES+cImpuesto)
		aConfTES := VldImpxTES(cTES, cImpuesto) //Obtiene información del impuesto configurado en la TES.
		oJConfImp[cTES+cImpuesto] := JsonObject():New()
		oJConfImp[cTES+cImpuesto]['FC_LIQUIDO'] := aConfTES[1]
		oJConfImp[cTES+cImpuesto]['FC_CALCULO'] := aConfTES[2]
		oJConfImp[cTES+cImpuesto]['FC_INCIMP'] := aConfTES[3]
	EndIf

	If oJConfImp[cTES+cImpuesto]['FC_LIQUIDO'] == "S"	
		nDesconto:=MaFisRet(nItem,"IT_DESCONTO")		
	Endif

	cImpIncid := Alltrim(oJConfImp[cTES+cImpuesto]['FC_INCIMP'])
	If !Empty(cImpIncid)
		aImpRef:= aClone(MaFisRet(nItem,"IT_DESCIV"))
		aImpVal:= aClone(MaFisRet(nItem,"IT_VALIMP"))
		For nI:=1 to Len(aImpRef)
		    If !Empty(aImpRef[nI])
			      
				IF Trim(aImpRef[nI][1])$cImpIncid 
					IF Trim(aImpRef[nI][1]) <> "AUI"  .Or. (Trim(aImpRef[nI][1]) == "AUI" .And. !lCpoAlqAIU)
						nVal+=aImpVal[nI]
					Else
						aAreaSFC := SFC->(GetArea())
						aAreaSFB := SFB->(GetArea())

						If SFC->(MsSeek(xFilial("SFC")+SF4->F4_CODIGO+"AUI"))
							dbSelectArea("SFB")
							SFB->(dbSetOrder(1))
							If SFB->(MsSeek(xFilial("SFB") + "AUI"))
								nBaseAUI := MaFisRet(nItem,"IT_VALMERC") + MaFisRet(nItem,"IT_FRETE") + MaFisRet(nItem,"IT_DESPESA") + MaFisRet(nItem,"IT_SEGURO")

								If cMvDescSai == '1' .And. MaFisRet(, "NF_CLIFOR") == 'C'
									nBaseAUI += MaFisRet(nItem,"IT_DESCONTO")
								Endif

								If oJConfImp[cTES+cImpuesto]['FC_LIQUIDO'] == "S"
									nBaseAUI -= MaFisRet(nItem,"IT_DESCONTO")
								Endif

								nBaseAUI := nBaseAUI * (SFB->FB_ALIQ/100)
								nBaseAUI := nBaseAUI * (nAlqAUI/100)

								nVal += nBaseAUI
							Endif
						SFB->(RestArea(aAreaSFB))
						Endif
						SFC->(RestArea(aAreaSFC))
					EndIf	
				  
				EndIf
			Endif
		Next	
	Else
		nVal:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If lAplDesc
			nVal -= nDesconto
		EndIf 
	Endif

	cClaveSFF := cImpuesto + cCFO //Impuesto + Código fiscal
	If !oJConfImp:hasProperty(cClaveSFF)
		aDatosSFF := M100CfgSFF(cImpuesto, cCFO) //Obtiene datos de configuración de impuestos SFF
		oJConfImp[cClaveSFF]               := JsonObject():New()
		oJConfImp[cClaveSFF]['FF_ALIQ']    := aDatosSFF[1]
		oJConfImp[cClaveSFF]['FF_FLAG']    := aDatosSFF[2]
		oJConfImp[cClaveSFF]['FF_IMPORTE'] := aDatosSFF[3]
		oJConfImp[cClaveSFF]['FF_MOEDA']   := aDatosSFF[4]
		oJConfImp[cClaveSFF]['R_E_C_N_O_'] := aDatosSFF[5]

		If !(oJConfImp[cClaveSFF]['FF_FLAG'] == "1")
			UpdRecSFF(oJConfImp[cClaveSFF]['R_E_C_N_O_']) //Actualiza campo FF_FLAG
		EndIf
	EndIf

	If oJConfImp[cClaveSFF]['R_E_C_N_O_'] > 0
		nAliq    := oJConfImp[cClaveSFF]['FF_ALIQ']
		nImporte := oJConfImp[cClaveSFF]['FF_IMPORTE']
		nMoedaSFF := oJConfImp[cClaveSFF]['FF_MOEDA']
		lRet     := .T.

		If cCalculo == "V"

			If oJConfImp[cTES+cImpuesto]['FC_CALCULO'] == "T"
				If MaFisRet(,'NF_BASEIV'+cCpoLivro)+ MaFisRet(nItem,'IT_BASEIV'+ cCpoLivro) > MaFisRet(,"NF_MINIV"+cCpoLivro)
					nVal		:=MaRetBasT(cCpoLivro,nItem,MaFisRet(nItem,'IT_ALIQIV'+cCpoLivro))              
				Endif
			Else
				If MaFisRet(nItem,'IT_BASEIV'+cCpoLivro) >   MaFisRet(,"NF_MINIV"+cCpoLivro)
					nVal	:=	MaFisRet(nItem,'IT_BASEIV'+cCpoLivro)   
				Endif
			Endif

		ElseIf cCalculo $ "BA" 							

			nTotBase := xMoeda(nVal,nMoeda,1,Nil,Nil,nTaxaMoed)

		Endif           
	Endif                                    

	If lRet
		Do Case
			Case cCalculo=="B"
				nVRet := nVal
			Case cCalculo=="A"
				nVRet := nAliq
			Case cCalculo=="V"
			
				If oJConfImp[cTES+cImpuesto]['FC_CALCULO'] == "I"
					lCalcItem := .T. //Calcula por item
				EndIf

				nAliq:=MaFisRet(nItem,"IT_ALIQIV"+cCpoLivro)		
				If xMoeda(nVal,nMoeda,1,Nil,Nil,nTaxaMoed) > xMoeda(nImporte,nMoedaSFF,1)
					If lRatVICol .And. lCalcItem
						nVRet := RatVICol(aInfo, nItem, nAliq, nVal, nMoeda, 100)
					Else
						nVRet := Round( nVal * (nAliq/100), 2)
					EndIf
				Else
					nVRet:= 0	   	   				
				EndIf			  	   			   		   	   		   	   		
		EndCase
	Endif

	FwFreeArray(aConfTES)
	FwFreeArray(aDatosSFF)
	FwFreeArray(aImpRef)
	FwFreeArray(aImpVal)

Return(nVRet)

/*/{Protheus.doc} M100CfgSFF
Obtiene la configuración por impuesto, municipio y tipo de actividad registrada en SFF.
@type function
@version 12.1.2410
@author luis.samaniego
@since 16/08/2025
@param cImpuesto, character, Código de impuesto.
@param cCodFiscal, character, Código fiscal.
@return Array, Valores de los campos: FF_ALIQ, FF_FLAG, FF_IMPORTE, FF_MOEDA y R_E_C_N_O_.
/*/
Static Function M100CfgSFF(cImpuesto, cCodFiscal)
Local cQuery      := ""
Local nOrd        := 1
Local oQryExec := Nil
Local aDatosSFF := {0, "", 0, 0, 0}

Default cImpuesto := ""
Default cCodFiscal   := ""

	cQuery := " SELECT "
	cQuery += " SFF.FF_ALIQ, SFF.FF_FLAG, SFF.FF_IMPORTE, SFF.FF_MOEDA, SFF.R_E_C_N_O_ "
	cQuery += " FROM " +  RetSqlName("SFF") + " SFF "
	cQuery += " WHERE "
	cQuery += " SFF.FF_FILIAL = ? "
	cQuery += " AND SFF.FF_IMPOSTO = ? "
	cQuery += " AND SFF.FF_CFO_C = ? "
	cQuery += " AND SFF.D_E_L_E_T_ = ? "

	cQuery := ChangeQuery(cQuery)
	oQryExec := FwExecStatement():New(cQuery)

    oQryExec:SetString(nOrd++, xFilial("SFF")) //Filial
    oQryExec:SetString(nOrd++, cImpuesto) //Impuesto
    oQryExec:SetString(nOrd++, cCodFiscal) //Código Fiscal
    oQryExec:SetString(nOrd++, ' ') //Delete

	aDatosSFF[1] := oQryExec:ExecScalar("FF_ALIQ") //Alícuota
	aDatosSFF[2] := oQryExec:ExecScalar("FF_FLAG") //Flag
	aDatosSFF[3] := oQryExec:ExecScalar("FF_IMPORTE") //Importe
	aDatosSFF[4] := oQryExec:ExecScalar("FF_MOEDA") //Moneda
	aDatosSFF[5] := oQryExec:ExecScalar("R_E_C_N_O_") //Recno

	oQryExec:Destroy()
	FwFreeObj(oQryExec)

Return aClone(aDatosSFF)

/*/{Protheus.doc} VldImpxTES
Obtiene configuración de los impuestos en la TES.
@type function
@version 12.1.2410
@author luis.samaniego
@since 16/08/2025
@param cTES, character, Código de la TES.
@param cImpuesto, character, Código del impuesto.
@return Array, Valores de los campos: FC_LIQUIDO, FC_CALCULO y FC_INCIMP.
/*/
Static Function VldImpxTES(cTES, cImpuesto)
Local aAreaSFC := {}
Local aConfTES := {"","", ""} //[1]=FC_LIQUIDO; [2]=FC_CALCULO; [3]=FC_INCIMP

Default cTES := ""
Default cImpuesto := ""

	aAreaSFC := GetArea()
	dbSelectArea("SFC")
	SFC->(DbSetOrder(2))
	If (SFC->(MsSeek(xFilial("SFC") + cTES + cImpuesto)))
		aConfTES[1] := SFC->FC_LIQUIDO
		aConfTES[2] := SFC->FC_CALCULO
		aConfTES[3] := Alltrim(SFC->FC_INCIMP)
	Endif
	RestArea(aAreaSFC)
	FwFreeArray(aAreaSFC)

Return aClone(aConfTES)

/*/{Protheus.doc} UpdRecSFF
Actualización del registro en la tabla SFF.
@type function
@version 12.1.2410
@author luis.samaniego
@since 16/08/2025
@param nRecnoSFF, numeric, Número de recno del registro en SFF.
/*/
Static Function UpdRecSFF(nRecnoSFF)
Local aAreaSFF := {}

Default nRecnoSFF := 0

	If nRecnoSFF > 0
		aAreaSFF := GetArea()
		dbSelectArea("SFF")
		dbSetOrder(1)
		SFF->(dbGoTo(nRecnoSFF))
		RecLock("SFF",.F.)
			Replace FF_FLAG With "1"
		SFF->(MsUnlock())
		RestArea(aAreaSFF)
	EndIf

	FwFreeArray(aAreaSFF)
	
Return

/*/{Protheus.doc} M100AlqSFB
Consulta la tabla SFB para obtener la alícuota.
@type function
@version 12.1.2410
@author luis.samaniego
@since 16/08/2025
@param cImpuesto, character, Código de impuesto.
@return numeric, Alícuota informada en tabla SFB.
/*/
Static Function M100AlqSFB(cImpuesto)
Local nAliqSFB := 0
Local aAreaSFB := {}

Default cImpuesto := ""

	aAreaSFB := GetArea()
	dbSelectArea("SFB")
	dbSetOrder(1)
	If MsSeek(xFilial("SFB") + cImpuesto)
		nAliqSFB := SFB->FB_ALIQ //Aliquota
	EndIf
	RestArea(aAreaSFB)
	FwFreeArray(aAreaSFB)

Return nAliqSFB
