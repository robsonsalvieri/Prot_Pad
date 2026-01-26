#Include 'Protheus.ch'             
#INCLUDE "STIDATACHECK.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"

Static oModel 	:= Nil 	// Utilizada para carregar o model
Static aRet 	:= {} 	// Variavel de retorno
Static bPan		:= Nil		// Objeto painel
Static oBtnOk	:= Nil	// Objeto button
Static oBtnCa	:= Nil	// Objeto button
Static nContBtn	:= 1		// Controla os botoes voltar e avancar
Static lEmi		:= .F.		// Controla o checkbox do emitente
Static lNro		:= .F.		// Controla o checkbox do numero sequencial

Static oGetBan		:= Nil								//Objeto get banco
Static oGetNuChk	:= Nil								//Objeto get numero do cheque
Static cGetBan		:= Space(TamSx3("EF_BANCO")[1])		//Banco
Static cGetAge		:= Space(TamSx3("EF_AGENCIA")[1])	//Agencia
Static cGetCon		:= Space(TamSx3("EF_CONTA")[1])		//Conta
Static cGetNum		:= Space(TamSx3("EF_NUM")[1])		//Nro cheque
Static cGetCom		:= Space(TamSx3("EF_COMP")[1])		//Compensacao
Static cGetTel		:= Space(TamSx3("EF_TEL")[1])		//Telefone
Static cGetRg		:= Space(TamSx3("EF_RG")[1])		//Rg
Static cGetEmi		:= Space(TamSx3("A1_NOME")[1])		//Emitente
Static nValBkp		:= 0								//Backup do valor do cheque para validar se o campo foi alterado
Static lLGPD 		:= Iif(ExistFunc("LjPDUse"),LjPDUse(),.F.) //Verifica se a funcionalidade de Dados Protegidos est· sendo utilizada no sistema.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIDataCheck

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIDataCheck(bCreatePan,nContBtn,aRet)

Local oMdl 			:= STIGetMdl()					//Recupera o model ativo
Local oMdlMst		:= oMdl:GetModel("CHECKMASTER")	//Seta o model do master

Local oPnlAdconal	:= Eval(bCreatePan) //Objeto novo painel

Local oLblValor 	:= Nil	//Objeto label valor
Local oGetValor 	:= Nil	//Objeto get valor
Local cGetValTot	:= oMdlMst:GetValue("L4_VALOR")		//Valor Total
Local cGetVal		:= 0									//Valor
Local cGetParc		:= oMdlMst:GetValue("L4_PARCELAS")	//Parcelas

Local oLblDtVen 	:= Nil	//Objeto label data de vencimento
Local oGetDtVen 	:= Nil	//Objeto get data de vencimento
Local cGetDt		:= oMdlMst:GetValue("L4_DATA") //Data de vencimento

Local oLblCheq		:= Nil	//Objeto label cheque
Local oGetCheq		:= Nil	//Objeto get cheque
Local cGetChk		:= ""	//Cheques

Local oLblBan		:= Nil	//Objeto label banco

Local oLblAge		:= Nil	//Objeto label agencia
Local oGetAge		:= Nil //Objeto get agencia

Local oLblConta		:= Nil	//Objeto label conta
Local oGetConta		:= Nil	//Objeto get conta

Local oLblNuChk		:= Nil	//Objeto label numero do cheque

Local oLblComp		:= Nil	//Objeto label compensacao
Local oGetComp		:= Nil	//Objeto get compensacao

Local oLblTel		:= Nil	//Objeto label telefone
Local oGetTel		:= Nil	//Objeto get telefone

Local oLblRg		:= Nil	//Objeto label rg
Local oGetRg		:= Nil	//Objeto get rg

Local oCheckBox		:= Nil	//Objeto checkbox
Local oGrpChk		:= Nil	//Objeto groupbox
Local oCheckNro		:= Nil	//Objeto checkbox

Local nLineCab		:= oPnlAdconal:nHeight/26				// Posicao horizontal da linha de gets do cabecalho
Local nColCab2		:= oPnlAdconal:nWIdth/6.1				// Posicao vertical da segunda coluna de objetos do cabecalho
Local nColCab3		:= oPnlAdconal:nWIdth/3.05				// Posicao vertical da terceira coluna de objetos do cabecalho

Local nLine1		:= oPnlAdconal:nHeight/7.8				// Posicao horizontal da primeira linha de objetos (labels)
Local nLine2		:= oPnlAdconal:nHeight/6				// Posicao horizontal da segunda linha de objetos (gets)
Local nLine3		:= oPnlAdconal:nHeight/4.3333333333		// Posicao horizontal da terceira linha de objetos (labels)
Local nLine4		:= oPnlAdconal:nHeight/3.7142857		// Posicao horizontal da quarta linha de objetos (gets)
Local nLine5		:= oPnlAdconal:nHeight/3.1142857		// Posicao horizontal da quinta linha de objetos (labels)
Local nLine6		:= oPnlAdconal:nHeight/2.8142857		// Posicao horizontal da sexta linha de objetos (gets)
Local nCol2			:= oPnlAdconal:nWIdth/8.133333333		// Posicao vertical da segunda coluna de objetos
Local nCol3			:= oPnlAdconal:nWIdth/4.2068965517		// Posicao vertical da terceira coluna de objetos
Local nCol4			:= oPnlAdconal:nWIdth/2.8372093			// Posicao vertical da quarta coluna de objetos
Local nDiferenca	:= 0
Local oPanelMVC		:= STIGetPanel() 
Local oLblEmi		:= Nil	//Objeto label emitente
Local oGetEmi		:= Nil	//Objeto get emitente
Local bEmiTrue 		:= {||oLblEmi:lVisibleControl:=.T., oGetEmi:lVisibleControl:=.T., oGetEmi:SetFocus()}
Local bEmiFalse		:= {||oLblEmi:lVisibleControl:=.F., oGetEmi:lVisibleControl:=.F., oGetBan:SetFocus()}
Local lReadOnly		:= ExistFunc("STIGetPayRO") .AND. STIGetPayRO()	//indica se os campos de pagamento est„o como Somente Leitura (permiss„o Alterar Parcelas do caixa)
Local nI 			:= 0
Local nMvLJINTER	:= SuperGetMV("MV_LJINTER",, 30)
Local lFormaImp 	:= ExistFunc("STBGFormImp") .And. STBIsImpOrc() .And. !Empty( AllTrim(STDGPBasket("SL1","L1_CONDPG")) )
Local aCheqImp		:= {}
Local nPosImp		:= 0
Local aDiasPgChck	:= IIF(ExistFunc("STBGetDPgChck"), STBGetDPgChck(), {} )

Default bCreatePan	:= Nil
Default aRet		:= {}
Default nContBtn	:= 1

If !IsInCallStack("STICANCDTCHK")
	If Len(aRet) > 0
		For nI := 1 To Len(aRet)
			cGetVal := cGetVal + aRet[nI][1][11]
		Next nI
		
		cGetValTot	:= cGetValTot - cGetVal
		cGetParc	:= cGetParc - (nContBtn - 1)
		
		If aRet[nContBtn - 1][1][11] == nValBkp 
			cGetVal := STBRound(oMdlMst:GetValue("L4_VALOR") / oMdlMst:GetValue("L4_PARCELAS"))
		Else 
			cGetVal := STBRound(cGetValTot / cGetParc, 2)
		EndIf
	Else
		cGetVal := STBRound(cGetValTot / cGetParc, 2)
		nValBkp := cGetVal
	EndIf
	
	nDiferenca := oMdlMst:GetValue("L4_VALOR") - (STBRound( oMdlMst:GetValue("L4_VALOR") / oMdlMst:GetValue("L4_PARCELAS"),2) * oMdlMst:GetValue("L4_PARCELAS"))
	
	If nContBtn == oMdlMst:GetValue("L4_PARCELAS") .AND. nDiferenca <> 0 .AND. STBRound(cGetVal, 2) == (STBRound(oMdlMst:GetValue("L4_VALOR") / oMdlMst:GetValue("L4_PARCELAS"),2))
		cGetVal := cGetVal + nDiferenca
	EndIf
Else
	cGetVal := aRet[nContBtn][1][11]
EndIf

/*	Essas variaveis sao utilizadas qdo a
	parcela for maiores do que um */
bPan := bCreatePan

cGetChk	:= AllTrim(Str(nContBtn)) +' '+STR0013+' '+ AllTrim(Str(oMdlMst:GetValue("L4_PARCELAS"))) //Cheques         // de

If Len(aDiasPgChck) > 0
	cGetDt := cGetDt + Val( aDiasPgChck[nContBtn] )
Else
	cGetDt := cGetDt + ((nContBtn - 1) * nMvLJINTER)
EndIf

//Tratamento para guardar as informaÁıes dos pagamentos em CH do orÁamento importado, para que seus valores sejam mantidos no PDV.
If lFormaImp
	aCheqImp := STBGFormImp()
	If (nPosImp := aScan(aCheqImp, {|x| AllTrim(x[1])=="CH" .And. x[4]==nContBtn  })) > 0
		cGetVal := aCheqImp[nPosImp][2] 		//Valor do cheque
		cGetDt	:= SToD(aCheqImp[nPosImp][3])	//Vencimento do cheque
	EndIf
EndIf

/* Label e Get: Valor */
oLblValor 	:= TSay():New(000, POSHOR_1, {||STR0001}, oPnlAdconal,,,,,,.T.,,,,8) //'Valor'

oGetValor 	:= TGet():New(nLineCab,POSHOR_1,{|u| If(PCount()>0,cGetVal:=u,cGetVal)},oPnlAdconal,,ALTURAGET,"@E 99,999,999.99",/*bValid*/,/*nClrFore*/,/*nClrBack*/,/*oFont*/,/*uParam12*/,/*uParam13*/,.T./*lPixel*/,/*uParam15*/,/*uParam16*/,/*bWhen*/,/*lCenter*/,/*lRight*/,/*bChange*/,lReadOnly /*readonly*/)

oLblValor:SetCSS( POSCSS (GetClassName(oLblValor), CSS_LABEL_FOCAL )) 
oGetValor:SetCSS( POSCSS (GetClassName(oGetValor), CSS_GET_NORMAL )) 

/* Label e Get: Dt Vencimento */
oLblDtVen := TSay():New(000, nColCab2, {||STR0002}, oPnlAdconal,,,,,,.T.,,,,8) //'Dt. Vencimento'
oGetDtVen := TGet():New(nLineCab,nColCab2,{|u| If(PCount()>0,cGetDt:=u,cGetDt)},oPnlAdconal,60,ALTURAGET,/*cPicture*/,/*bValid*/,/*nClrFore*/,/*nClrBack*/,/*oFont*/,/*uParam12*/,/*uParam13*/,.T./*lPixel*/,/*uParam15*/,/*uParam16*/,/*bWhen*/,/*lCenter*/,/*lRight*/,/*bChange*/,lReadOnly /*readonly*/) 


oLblDtVen:SetCSS( POSCSS (GetClassName(oLblDtVen), CSS_LABEL_FOCAL )) 
oGetDtVen:SetCSS( POSCSS (GetClassName(oGetDtVen), CSS_GET_NORMAL )) 

/* Label e Get: Cheque */
oLblCheq := TSay():New(000, nColCab3, {||STR0003}, oPnlAdconal,,,,,,.T.,,,,8) //'Cheque'
oGetCheq := TGet():New(nLineCab,nColCab3,{|u| If(PCount()>0,cGetChk:=u,cGetChk)},oPnlAdconal,50,ALTURAGET,/*cPicture*/,/*bValid*/,/*nClrFore*/,/*nClrBack*/,/*oFont*/,/*uParam12*/,/*uParam13*/,.T./*lPixel*/,/*uParam15*/,/*uParam16*/,/*bWhen*/,/*lCenter*/,/*lRight*/,/*bChange*/,.T. /*readonly*/)

oLblCheq:SetCSS( POSCSS (GetClassName(oLblCheq), CSS_LABEL_FOCAL )) 
oGetCheq:SetCSS( POSCSS (GetClassName(oGetCheq), CSS_GET_NORMAL )) 

/* Objeto TGroup */
oGrpChk := TGroup():Create(oPnlAdconal, oPnlAdconal:nHeight/9.75, oPanelMVC:nWidth/65.5, oPnlAdconal:nHeight/2.55, oPnlAdconal:nWIdth/2.02995, '',,,.T.)

/* Label e Get: Banco */
oLblBan := TSay():New(nLine1,POSHOR_1, {||STR0004}, oGrpChk,,,,,,.T.,,,,8)   //'Banco'
oGetBan := TGet():New(nLine2,POSHOR_1,{|u| If(PCount()>0,cGetBan:=u,cGetBan)},oGrpChk,,ALTURAGET,"@!",,,,,,,.T.)
If lLGPD .And. LjPDCmpPrt("EF_BANCO")
	LjPDOfuscar(oGetBan, "EF_BANCO")
EndIf

oLblBan:SetCSS( POSCSS (GetClassName(oLblBan), CSS_LABEL_FOCAL )) 

/* Label e Get: Agencia */
oLblAge := TSay():New(nLine1, nCol2, {||STR0005}, oGrpChk,,,,,,.T.,,,,8)  //'Agencia'
oGetAge := TGet():New(nLine2,nCol2,{|u| If(PCount()>0,cGetAge:=u,cGetAge)},oGrpChk,,ALTURAGET,"@!",,,,,,,.T.)
If lLGPD .And. LjPDCmpPrt("EF_AGENCIA")
	LjPDOfuscar(oGetAge, "EF_AGENCIA")
EndIf

oLblAge:SetCSS( POSCSS (GetClassName(oLblAge), CSS_LABEL_FOCAL )) 

/* Label e Get: Conta */
oLblConta := TSay():New(nLine1, nCol3, {||STR0006}, oGrpChk,,,,,,.T.,,,,8) //'Conta'
oGetConta := TGet():New(nLine2,nCol3,{|u| If(PCount()>0,cGetCon:=u,cGetCon)},oGrpChk,50,ALTURAGET,"@!",,,,,,,.T.)
If lLGPD .And. LjPDCmpPrt("EF_CONTA")
	LjPDOfuscar(oGetConta, "EF_CONTA")
EndIf

oLblConta:SetCSS( POSCSS (GetClassName(oLblConta), CSS_LABEL_FOCAL )) 

/* Label e Get: Nro Cheque */
oLblNuChk := TSay():New(nLine1, nCol4, {||STR0007}, oGrpChk,,,,,,.T.,,,,8) //'Nro Cheque'
oGetNuChk := TGet():New(nLine2,nCol4,{|u| If(PCount()>0,cGetNum:=u,cGetNum)},oGrpChk,50,ALTURAGET,"@!",,,,,,,.T.)
If lLGPD .And. LjPDCmpPrt("EF_NUM")
	LjPDOfuscar(oGetNuChk, "EF_NUM")
EndIf

oLblNuChk:SetCSS( POSCSS (GetClassName(oLblNuChk), CSS_LABEL_FOCAL )) 

/* Label e Get: Compensacao */
oLblComp := TSay():New(nLine3, POSHOR_1, {||STR0008}, oGrpChk,,,,,,.T.,,,,8)  //'CompensaÁ„o'
oGetComp := TGet():New(nLine4,POSHOR_1,{|u| If(PCount()>0,cGetCom:=u,cGetCom)},oGrpChk,,ALTURAGET,,,,,,,,.T.)

oLblComp:SetCSS( POSCSS (GetClassName(oLblComp), CSS_LABEL_FOCAL )) 

/* Label e Get: Telefone */
oLblTel := TSay():New(nLine3, nCol2, {||STR0009}, oGrpChk,,,,,,.T.,,,,8)// 'Telefone'
oGetTel := TGet():New(nLine4,nCol2,{|u| If(PCount()>0,cGetTel:=u,cGetTel)},oGrpChk,50,ALTURAGET,"@!",,,,,,,.T.)
If lLGPD .And. LjPDCmpPrt("EF_TEL")
	LjPDOfuscar(oGetTel, "EF_TEL")
EndIf

oLblTel:SetCSS( POSCSS (GetClassName(oLblTel), CSS_LABEL_FOCAL )) 

/* Label e Get: Rg */
oLblRg := TSay():New(nLine3, nCol3, {||STR0018}, oGrpChk,,,,,,.T.,,,,8)  //Rg
oGetRg := TGet():New(nLine4,nCol3,{|u| If(PCount()>0,cGetRg:=u,cGetRg)},oGrpChk,50,ALTURAGET,"@!",,,,,,,.T.)
If lLGPD .And. LjPDCmpPrt("EF_RG")
	LjPDOfuscar(oGetRg, "EF_RG")
EndIf

oLblRg:SetCSS( POSCSS (GetClassName(oLblRg), CSS_LABEL_FOCAL )) 

/* CheckBox */
oCheckBox := TCheckBox():New(nLine6,POSHOR_1,STR0010,{|| lEmi},oGrpChk,80,/*nHeight*/,/*uParam8*/,{||IIF(lEmi,lEmi:=.F.,lEmi:=.T.),IIF(lEmi,Eval(bEmiTrue),Eval(bEmiFalse))},,/*bValid*/,/*nClrText*/,/*nClrPane*/,/*uParam14*/) //Cheque de terceiro
oCheckNro := TCheckBox():New(nLine4,nCol4,STR0014,{|| lNro},oGrpChk,80,/*nHeight*/,/*uParam8*/,{||IIF(lNro,lNro:=.F.,lNro:=.T.), STIValButton()},,/*bValid*/,/*nClrText*/,/*nClrPane*/,/*uParam14*/, /*lPixel*/ , /*cMsg*/ , /*uParam17*/ , { || IIf( nContBtn == oMdlMst:GetValue("L4_PARCELAS") .Or. lFormaImp, .F., .T.) }/*bWhen*/ ) //Nro cheque sequencial

/* Label e Get: Emitente */
oLblEmi := TSay():New(nLine5, oPnlAdconal:nWIdth/6.133333333, {||STR0012}, oGrpChk,,,,,,.T.,,,,8)//"Emitente"
oGetEmi := TGet():New(nLine6,oPnlAdconal:nWIdth/6.133333333,{|u| If(PCount()>0,cGetEmi:=u,cGetEmi)},oGrpChk,150,ALTURAGET,"@!",,,,,,,.T.,,,)
If lLGPD .And. LjPDCmpPrt("EF_EMITENT")
	LjPDOfuscar(oGetEmi, "EF_EMITENT")
EndIf

oGetEmi:lVisibleControl := .F.
oLblEmi:lVisibleControl := .F.

oLblEmi:SetCSS( POSCSS (GetClassName(oLblEmi), CSS_LABEL_FOCAL ))

/* Button: OK */
oBtnOk := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0017,oPnlAdconal,{|| STIDtChkCon(cGetBan,cGetAge,cGetCon,cGetNum,cGetCom,cGetTel,cGetRg,cGetEmi,oCheckBox,oCheckNro,oPnlAdconal,cGetDt,cGetVal,cGetValTot) },LARGBTN,ALTURABTN,,,,.T.) //OK

/* Button: Cancelar */
oBtnCa	:= TButton():New(POSVERT_BTNFOCAL,POSHOR_1,STR0011,oPnlAdconal,{|| STICancDtChk(oPnlAdconal) },LARGBTN,ALTURABTN,,,,.T.) //Cancelar

oBtnOk:SetCSS( POSCSS (GetClassName(oBtnOk), CSS_BTN_FOCAL )) 
oBtnCa:SetCSS( POSCSS (GetClassName(oBtnCa), CSS_BTN_ATIVO )) 

oGetBan:SetFocus()

// Desabilita os botoes de atalhos F3 ao F8
STIBtnDeActivate()

/* Verifica como deve ser apresentado o label dos botoes */
STIValButton()

Return .T.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIDtChkCon
Retorna os dados do cheque digitados pelo usuario

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	05/03/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIDtChkCon(cGetBan		,cGetAge		,cGetCon		,cGetNum	,;
					 cGetCom		,cGetTel		,cGetRg 		,cGetEmi	,;
					 oCheckBox		,oCheckNro		,oPnlAdconal	,cGetDt 	,;
					 cGetVal		,cGetValTot) 

Local oMdl 			:= STIGetMdl()					//Recupera o model ativo
Local oMdlMst		:= oMdl:GetModel("CHECKMASTER")	//Seta o model do master
Local cNroCheq		:= ''							//Numeracao do cheque
Local nI			:= 0							//Variavel de loop
Local nValParc		:= 0
Local lValField		:= ExistFunc("STWValField")
Local lReajusta		:= .F.							// Verifica se redimensiona o array aRet quando houver erro
Local nContBtnBkp	:= 1							// Variavel para guardar a tela que foi clicado em Nro Sequencial  
Local nDiferenca	:= 0							// Verifica se h· diferenca nas parcelas quando a divisao for dizima
Local nParcelas		:= 0							// Armazena quantidade de parcelas restantes
Local nIntervalo	:= SuperGetMV("MV_LJINTER") 	//Intervalo das parcelas
Local nDataNSeq		:= 0							// Calculo data para CH com numero sequencial

Default cGetDt := ""

nParcelas := oMdlMst:GetValue("L4_PARCELAS") - ( nContBtn - 1 )

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Estrutura do array aRet ≥
//≥1 - Banco do Cheque     ≥			
//≥2 - Numero do Cheque    ≥						
//≥3 - Agencia do Cheque   ≥			
//≥4 - Conta do Cheque     ≥									
//≥5 - Compensacao         ≥			
//≥6 - Emitente            ≥						
//≥7 - Telefone            ≥									
//≥8 - RG                  ≥
//≥9 - Checkbox Emitente   ≥
//≥10- Data                ≥					
//≥11- Valor               ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ		

If !lNro
	nContBtn += 1
	If 	Len(aRet) == 0 .OR. Len(aRet) < oMdlMst:GetValue("L4_PARCELAS")  
		If Len(aRet) < (nContBtn - 1)
			Aadd(aRet, {{cGetBan, cGetNum, cGetAge, cGetCon, cGetCom, cGetEmi, cGetTel, cGetRg, lEmi, cGetDt, cGetVal}}) 
		EndIf
	EndIf
Else
	For nI := 1 To nParcelas
		If nI == 1
			cNroCheq := AllTrim(cGetNum)
		Else
			cNroCheq := Soma1(AllTrim(cNroCheq), Len(AllTrim(cNroCheq)))
		EndIf
		
		If nContBtn == nParcelas .AND. (cGetVal * nParcelas) <> cGetValTot
			nDiferenca := STBRound( oMdlMst:GetValue("L4_VALOR") - (( STBRound( oMdlMst:GetValue("L4_VALOR") / oMdlMst:GetValue("L4_PARCELAS"),2) ) * oMdlMst:GetValue("L4_PARCELAS")), 2)
			cGetVal := cGetVal + nDiferenca  
		EndIf
		
		nDataNSeq := cGetDt + If(nI = 1, 0, nIntervalo * (nI - 1))
							
		Aadd(aRet, {{cGetBan, cNroCheq, cGetAge, cGetCon, cGetCom, cGetEmi, cGetTel, cGetRg, lEmi, nDataNSeq, cGetVal}}) 
		
		nConTBtn += 1
	Next nI
	
	nContBtnBkp := nParcelas
	
	nContBtn := oMdlMst:GetValue("L4_PARCELAS") + 1
EndIf

For nI := 1 To Len(aRet)
	If Len(aRet[nI][1]) >= 11
		nValParc := nValParc + aRet[nI][1][11]
	Else
		nValParc := nValParc + aRet[nI][1][10]
	EndIf
Next nI

If (nValParc <= oMdlMst:GetValue("L4_VALOR")) 	
	If !lValField .OR. (STWValField(STR0004, cGetBan) .AND. STWValField(STR0005, cGetAge) .AND. STWValField(STR0006, cGetCon) .AND. STWValField(STR0007, cGetNum))	//Valida o preechimeto dos dados do cheque		
	
		If (nContBtn - 1) == oMdlMst:GetValue("L4_PARCELAS") .And. nValParc == oMdlMst:GetValue("L4_VALOR")
			oPnlAdconal:Hide()
			
			STWSetCkRet(aRet)
			STIClearVar()
			STWConChk()	

			STIEnblPaymentOptions()
			
			If ! (ExistFunc("STIBlqMnTef") .And. !STIBlqMnTef())
				STIBtnActivate()
			EndIf
		ElseIf (nContBtn - 1) < oMdlMst:GetValue("L4_PARCELAS")
			oPnlAdconal:Hide()
			
			STIDataCheck(bPan, nContBtn,aRet)
			oGetBan:SetFocus()

			STIEnblPaymentOptions()
		Else
			lReajusta := .T.
			
			STFMessage( ProcName(),"ALERT", STR0021) // Valor total da forma È inferior ao valor da venda.
			STFShowMessage( ProcName() )
		EndIf
	Else
		lReajusta := .T.
	EndIf	
Else
	lReajusta := .T.

	STFMessage( ProcName(),"ALERT", STR0020) // Valor total da forma ultrapassa valor da venda.
	STFShowMessage( ProcName() )
EndIf

If lReajusta
	If lNro
		For nI := 1 To nContBtnBkp
			ADel(aRet, Len(aRet))			
			ASize(aRet, ( Len(aRet) - 1) )	//Redimensiona array, excluindo a ultima parcela digitada
			
			nContBtn -= 1
		Next nI
	Else
		ADel(aRet, Len(aRet))			
		ASize(aRet, ( Len(aRet) - 1) )	//Redimensiona array, excluindo a ultima parcela digitada
		
		nContBtn -= 1
	EndIf
EndIf

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STICancDtChk
Retornar a tela do cheque

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	15/04/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STICancDtChk(oPnlAdconal)

If ( ExistFunc("STIGetPayRO") .AND. STIGetPayRO() )
	STFMessage( ProcName(),"ALERT", STR0019)	//"Sem permiss„o para Alterar Parcelas"
	STFShowMessage( ProcName() )
ElseIf nContBtn == 1 
	STIClearVar()
	oPnlAdconal:Hide()
	STIEnblPaymentOptions()
	If !(ExistFunc("STIBlqMnTef") .And. !STIBlqMnTef())
		STIBtnActivate()
	EndIf
Else
	nContBtn -= 1
	
	oPnlAdconal:Hide()
	STIDataCheck(bPan, nContBtn, aRet)
	
	ADel(aRet, Len(aRet))			
	ASize(aRet, ( Len(aRet) - 1) )	//Redimensiona array, excluindo a ultima parcela digitada para nao gerar error log de array out o bound
	
	oGetBan:SetFocus()
EndIf

Return .T.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIValButton
Valida como deve ser apresentado o label dos botoes

@param   	
@author  	Varejo
@version 	P12
@since   	15/04/2013
@return  	.T.
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIValButton()

Local oMdl 	:= STIGetMdl()						//Recupera o model ativo
Local oMdlMst	:= oMdl:GetModel("CHECKMASTER")	//Seta o model do master

Do Case
	Case oMdlMst:GetValue("L4_PARCELAS") == 1 .OR. lNro
  		oBtnOk:cCaption := STR0017  //OK
  		oBtnCa:cCaption := STR0011 //Cancelar
  	Case nContBtn == 1
  		oBtnOk:cCaption := STR0015  //AvanÁar
  		oBtnCa:cCaption := STR0011 //Cancelar 	
  		STILoadGet()
  	Case nContBtn == oMdlMst:GetValue("L4_PARCELAS")
  		oBtnOk:cCaption := STR0017  //OK
  		oBtnCa:cCaption := STR0016	 //Voltar
  		STILoadGet()  	
	Case nContBtn < oMdlMst:GetValue("L4_PARCELAS")  		
  		oBtnOk:cCaption := STR0015  //AvanÁar
  		oBtnCa:cCaption := STR0016	 //Voltar
  		STILoadGet()	
EndCase

Return .T.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STILoadGet
Carrega os Gets com os valores da tela anterior

@param   	
@author  	Varejo
@version 	P12
@since   	15/04/2013
@return  	.T.
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STILoadGet()

Local nPos := IIf( IsInCallStack('STWPAYCHECK') .Or. nContBtn == 1, nContBtn, nContBtn - 1 )	// Valisa posicao do aRet para pegar os dados quando voltar para a parcela anterior

If Len(aRet) > 0
	cGetBan 	:= aRet[nPos][1][1]
	cGetAge 	:= aRet[nPos][1][3]
	cGetCon 	:= aRet[nPos][1][4]
	If nContBtn <> 1  
		cGetNum := Soma1(AllTrim(aRet[nPos][1][2]), Len(AllTrim(aRet[nPos][1][2])))
	Else
		cGetNum := aRet[nPos][1][2]
	EndIf
	cGetCom 	:= aRet[nPos][1][5]
	cGetTel 	:= aRet[nPos][1][7]
	cGetRg		:= aRet[nPos][1][8]
	cGetEmi		:= aRet[nPos][1][6]
EndIf

Return .T.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIClearVar
Limpa as variaveis de objeto

@param   	
@author  	Varejo
@version 	P12
@since   	15/04/2013
@return  	.T.
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIClearVar()

cGetBan	:= Space(TamSx3("EF_BANCO")[1])		
cGetAge	:= Space(TamSx3("EF_AGENCIA")[1])	
cGetCon	:= Space(TamSx3("EF_CONTA")[1])		
cGetNum	:= Space(TamSx3("EF_NUM")[1])		
cGetCom	:= Space(TamSx3("EF_COMP")[1])		
cGetTel	:= Space(TamSx3("EF_TEL")[1])		
cGetRg		:= Space(TamSx3("EF_RG")[1])		
cGetEmi	:= Space(TamSx3("A1_NOME")[1])		

lEmi	:= .F.
lNro	:= .F.

nContBtn := 1

aRet := {}
nValBkp:= 0

Return .T.
