#INCLUDE "TTMKR01.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKR01   บAutor  ณVendas Clientes     บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvio de e-mail apos a gravacao do orcamento                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM - Tela de Atendimento Call Center             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TTMKR01()
Local cOriMail   := ""			//e-mail de origem
Local cDesMail   := ""			//e-mail de destino
Local cNomecli   := ""			//Nome do cliente
Local cSenha	 := ""			//Senha do e-mail
Local cDirHtml 	 := ""			//Diretorio onde serao gravados orcamentos
Local cArquivo 	 := ""			//Nome do arquivo	
Local cAssunto	 := ""			//Assunto para o e-mail
Local  _aAreaTR1 := GetArea()  	//Area atual

CHKTEMPLATE("DCM")  

/*
//	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//	//ณVerifica a existencia dos parametrosณ
//	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//	T_DCMSX6()
*/

DbSelectArea("SUA")
DbSetOrder(1)
If !DbSeek(xFilial("SUA")+M->UA_NUM)
	MsgAlert(STR0003+M->UA_NUM) //"Orcamento nao encontrado: "
	RestArea(_aAreaTR1)
	Return
EndIf

DbSelectArea("SA1")
DbSetOrder(1)
If DbSeek(xFilial("SA1")+SUA->UA_CLIENTE)
	cNomeCli := SA1->A1_NOME
	cDesMail := SA1->A1_EMAIL
Else
	DbSelectArea("SUS")
	DbSetOrder(1)
	If DbSeek(xfilial("SUS")+SUA->UA_CLIENTE+SUA->UA_LOJA)
		cNomeCli := SUS->US_NOME
	Else
		cNomeCli := STR0004 //"Nao encontrado"
	EndIf
EndIf


// pega nome/e-mail do vendedor
DbSelectArea("SA3")
DbSetOrder(1)
If DbSeek(xFilial("SA3")+SUA->UA_VEND)
	If !Empty(A3_EMAIL)
		cOriMail := SA3->A3_EMAIL
		cSenha	 := SA3->A3_SENEMAI
	Else
		MsgAlert(STR0006) //"Problemas com o e-mail do vendedor. Contate o administrador da rede."
		RestArea(_aAreaTR1)
		Return
	EndIf
Else
	MsgStop(STR0007) //"Vendedor nao encontrado."
	RestArea(_aAreaTR1)
	Return
EndIf

If MsgBox(STR0008,STR0009,"YESNO") //"Deseja enviar o orcamento por e-mail?"###"Envio de Mail"

	cDirHtml := Rtrim(SuperGetMv("MV_DIRHTML"))
	cArquivo := Rtrim(cDirHtml)+"\OR"+M->UA_NUM+".htm"
	cAssunto := STR0010+M->UA_NUM
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGeracao do arquivo. HTMณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	OrcHtml(cArquivo, cNomeCli) 

	TPLEnvEmail(cOriMail, cDesMail, cAssunto, cArquivo,;
				cSenha) 
EndIf

RestArea(_aAreaTR1)  

Return (.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTPLEnvEmailบAutor  ณVendas Clientes     บ Data ณ  09/02/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela para o envio de e-mail                                  บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM - Tela de Atendimento Call Center              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TPLEnvEmail( cDe, cPara, cAssunto, cAnexo,;
							 cSenha )

Local cServMail   := Rtrim(SuperGetMv("MV_RELSERV")) 			//Servidor SMTP
Local cCC 	      := Space(250)									//Copia Com
Local lSairTela   := .F.										//Controla se a tela de envio de e-mails foi fechada
Local cContaMail  := AllTrim(SubStr(cDe,1,At("@",cDe)-1))		//Conta de e-mail
Local cCorpo	  := ""											//Corpo do e-mail	

cPara      += Space(250)
cAssunto   += Space(250)

// cria interface
@ 122,67 TO 531,733 DIALOG MAILDLG TITLE STR0011 //"ENVIO DE E-MAIL "
@ 02,4   TO 078,324
@ 80,4   TO 182,324
@ 11,15 SAY STR0012  SIZE 30,8 //"DE: "
@ 10,40 GET cDe      SIZE 270,10 WHEN .F.

@ 23,15 SAY STR0013  SIZE 25,8 //"PARA: "
@ 22,40 GET cPara    SIZE 270,10 OBJECT oPara

@ 35,15 SAY "*Caso necessite enviar este e-mail para mais de um destinatแrio, utilizar o separador ';'" SIZE 270,8 //"CC: "           


@ 47,15 SAY STR0015  SIZE 30,8 //"ASSUNTO: "
@ 46,40 GET cAssunto SIZE 270,10

@ 59,15 SAY STR0016  SIZE 30,8 //"ANEXAR: "
@ 58,40 GET cAnexo  SIZE 270,10 WHEN .F.

@ 88,09 GET cCorpo MEMO  SIZE 310,90

@ 187,226 BUTTON STR0017 SIZE 36,16 ACTION If(!Empty(cPara),Close(MAILDLG),MsgAlert(STR0018)) 	//"_Enviar"###"E-Mail sem destinatario."
@ 187,276 BUTTON STR0019 SIZE 36,16 ACTION (lSairTela := .T., Close(MAILDLG)) 					//"_Sair"

ACTIVATE DIALOG MAILDLG CENTERED

If !lSairTela
	cContaMail  := Rtrim(cContaMail)
	cSenha	 	:= Rtrim(cSenha)
	cServMail 	:= Rtrim(cServMail)
	cPara    	:= Rtrim(cPara)
	cDe 	 	:= Rtrim(cDe)
	cAssunto 	:= Rtrim(cAssunto)
	
	TkSendMail( cContaMail, cSenha  , cServMail, cDe,;
			    cPara	  , cAssunto, cCorpo   , cAnexo)
EndIf

Return (Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOrcHtml   บAutor  ณVendas Clientes     บ Data ณ  09/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao do arquivo .HTM que sera' anexado no e-mail         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM - Tela de Atendimento Call Center             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OrcHtml( cArquivo, cNomeCli )
Local cEndLogo := SuperGetMv("MV_ENDIMAG")
Local nTotOrc  := 0
Local nHdl     := FCreate(cArquivo)
Local _cMarca  := ""

Private nLin    := 0

cLin :=            "<html>"+chr(13)+chr(10)
cLin :=cLin       +"   <head><title>Orcamento</title></head>"+chr(13)+chr(10)
cLin :=cLin       +"   <body>"+chr(13)+chr(10)
cLin :=cLin       +"      <table border=0 width=100%>"+chr(13)+chr(10)
cLin :=cLin       +"         <tr>"+chr(13)+chr(10)
cLin :=cLin       +"            <td><img src="+cEndLogo+ " width=274 height=129></td>"+chr(13)+chr(10)
cLin :=cLin       +"            <td><font size='5' face='Verdana, Arial, Helvetica, sans-serif'><b>"+(SM0->M0_NOMECOM)+"</b></font></td>"+chr(13)+chr(10)
cLin :=cLin       +"         </tr>"+chr(13)+chr(10)
cLin :=cLin       +"      </table>"+chr(13)+chr(10)
cLin :=cLin       +"      <hr width=100%>"+chr(13)+chr(10)

cLin :=cLin       +"      <table border=0 cellspacing=0 width=100%>"+chr(13)+chr(10)
cLin :=cLin       +"         <tr>"+chr(13)+chr(10)
cLin :=cLin       +"            <td width=12%><font face='ms sans serif' size=2>Orcamento</font></td>"+chr(13)+chr(10)
cLin :=cLin       +"            <td><font face='ms sans serif' size=2>: <b>"+M->UA_NUM+"</b> - "+dtoc(SUA->UA_EMISSAO)+"</font></td>"+chr(13)+chr(10)
cLin :=cLin       +"         </tr>"+chr(13)+chr(10)
cLin :=cLin       +"         <tr>"+chr(13)+chr(10)
cLin :=cLin       +"            <td width=12%><font face='ms sans serif' size=2>Cliente</font></td>"+chr(13)+chr(10)
cLin :=cLin       +"            <td><font face='ms sans serif' size=2>: "+(SUA->UA_CLIENTE)+" "+cNomeCli+"</font></td>"+chr(13)+chr(10)
cLin :=cLin       +"         </tr>"+chr(13)+chr(10)
cLin :=cLin       +"         <tr>"+chr(13)+chr(10)
cLin :=cLin       +"            <td width=12%><font face='ms sans serif' size=2>Requisitante</font></td>"+chr(13)+chr(10)
cLin :=cLin       +"            <td><font face='ms sans serif' size=2>: "+(SUA->UA_DESCNT)+"</font></td>"+chr(13)+chr(10)
cLin :=cLin       +"         </tr>"+chr(13)+chr(10)
cLin :=cLin       +"      </table>"+chr(13)+chr(10)
cLin :=cLin       +"      <hr width=100%>"+chr(13)+chr(10)

cLin :=cLin       +"      <table border=0 cellspacing=0 width=100%>"+chr(13)+chr(10)
cLin :=cLin       +"         <tr>"+chr(13)+chr(10)
cLin :=cLin       +"            <td width=12%><font face='ms sans serif' size=2>Vendedor(a)</font></td>"+chr(13)+chr(10)
cLin :=cLin       +"            <td><font face='ms sans serif' size=2>: "+SA3->A3_NOME+"</font></td>"+chr(13)+chr(10)
cLin :=cLin       +"         </tr>"+chr(13)+chr(10)
cLin :=cLin       +"         <tr>"+chr(13)+chr(10)
cLin :=clin       +"            <td width=12%><font face='ms sans serif' size=2>e-mail</font></td>"+chr(13)+chr(10)
cLin :=cLin       +"            <td><font face='ms sans serif' size=2>: <a href='mailto:"+Rtrim(SA3->A3_EMAIL)+"'>"+Rtrim(SA3->A3_EMAIL)+"</a></font></td>"+chr(13)+chr(10)
cLin :=cLin       +"         </tr>"+chr(13)+chr(10)
cLin :=cLin       +"      </table>"+chr(13)+chr(10)
cLin :=cLin       +"      <hr width=100%>"+chr(13)+chr(10)

DbSelectArea("SUB")
DbSetOrder(1)

If DbSeek(xfilial("SUB")+M->UA_NUM)
	cLin :=cLin    +"      <table border=0 cellspacing=2 width=100%>"+chr(13)+chr(10)
	cLin :=cLin    +"         <tr bgcolor='#669999'>"+chr(13)+chr(10)
	cLin :=cLin    +"            <td width=20%><font face='ms sans serif' size=2 color='#ffffff'>Codigo</font></td>"+chr(13)+chr(10)
	cLin :=cLin    +"            <td width=45%><font face='ms sans serif' size=2 color='#ffffff'>Marca/Descricao do Produto</font></td>"+chr(13)+chr(10)
	cLin :=cLin    +"            <td width=05% align='center'><font face='ms sans serif' size=2 color='#ffffff'>UN</font></td>"+chr(13)+chr(10)
	cLin :=cLin    +"            <td width=10%><font face='ms sans serif' size=2 color='#ffffff'>Quantidade</font></td>"+chr(13)+chr(10)
	cLin :=cLin    +"            <td width=10%><font face='ms sans serif' size=2 color='#ffffff'>Preco</font></td>"+chr(13)+chr(10)
	cLin :=cLin    +"            <td width=10%><font face='ms sans serif' size=2 color='#ffffff'>Subtotal</font></td>"+chr(13)+chr(10)
	cLin :=cLin    +"         </tr>"+chr(13)+chr(10)
	cLin :=cLin    +"      </table>"+chr(13)+chr(10)
	
	While SUB->(! Eof()) .AND. SUB->UB_FILIAL == xFilial("SUB") .AND. SUB->UB_NUM == M->UA_NUM
		DbSelectArea("SB1")
		DbSetOrder(1)
		If !DbSeek(xfilial("SB1")+SUB->UB_PRODUTO)
			MsgBox(STR0022+SUB->UB_PRODUTO) //"Produto nao encontrado."
			_cMarca :=""
		Else
			_cMarca :=SB1->B1_FABRIC
		EndIf
		DbSelectArea("SUB")
		cLin :=cLin +"      <table border=0 cellspacing=2 width=100%>"+chr(13)+chr(10)
		cLin :=cLin +"         <tr bgcolor='#cccccc'>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=20%><font face='ms sans serif' size=2>"+UB_PRODUTO+"</font></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=45%><font face='ms sans serif' size=2>"+SB1->B1_DESC+"</font></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=05% align='center'><font face='ms sans serif' size=2>"+UB_UM+"</font></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=10% align='right'><font face='ms sans serif' size=2>"+if(Empty(UB_UNSVEN),Transform(UB_QUANT,"@E 999,999.99"),Transform(UB_SEGUM,"@E 999,999.99"))+"</font></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=10% align='right'><font face='ms sans serif' size=2>"+if(Empty(UB_UNSVEN),Transform(UB_VRUNIT,"@E 999,999.99"),Transform(UB_VRUNIT*UB_UNSVEN,"@E 999,999.99"))+"</font></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=10% align='right'><font face='ms sans serif' size=2>"+Transform(UB_VLRITEM,"@E 999,999.99")+"</font></td>"+chr(13)+chr(10)
		cLin :=cLin +"         </tr>"+chr(13)+chr(10)
		cLin :=cLin +"         <tr>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=20%></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=45%><font face='ms sans serif' size=1>"+if(!Empty(_cMarca),+_cMarca,"")+"</font></td>"+chr(13)+chr(10)
		cLin :=cLin +"         </tr>"+chr(13)+chr(10)
		cLin :=cLin +"      </table>"+chr(13)+chr(10)
		nTotOrc +=UB_VLRITEM
		DbSkip()
	End
	
	If !Empty(SUA->UA_DESCONT)
		cLin :=cLin +"      <table border=0 cellspacing=2 width=100%>"+chr(13)+chr(10)
		cLin :=cLin +"         <tr>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=20%></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=45%></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=05%></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=10%></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=10% align='right' bgcolor='#cccccc'><font face='ms sans serif' size=2>Subtotal</font></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=10% align='right' bgcolor='#cccccc'><font face='ms sans serif' size=2>"+Transform(nTotOrc,"@E 99,999,999.99")+"</font></td>"+chr(13)+chr(10)
		cLin :=cLin +"         </tr>"+chr(13)+chr(10)
		cLin :=cLin +"         <tr>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=20%></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=45%></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=05%></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=10%></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=10% align='right' bgcolor='#cccccc'><font face='ms sans serif' size=2>Desconto</font></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=10% align='right' bgcolor='#cccccc'><font face='ms sans serif' size=2>"+Transform(SUA->UA_DESCONT,"@E 99,999,999.99")+"</font></td>"+chr(13)+chr(10)
		cLin :=cLin +"         </tr>"+chr(13)+chr(10)
		cLin :=cLin +"      </table>"+chr(13)+chr(10)
		nTotOrc -=SUA->UA_DESCONT
	EndIf
	
	cLin :=cLin    +"      <table border=0 cellspacing=2 width=100%>"+chr(13)+chr(10)
	cLin :=cLin    +"         <tr>"+chr(13)+chr(10)
	cLin :=cLin    +"            <td width=20%></td>"+chr(13)+chr(10)
	cLin :=cLin    +"            <td width=45%></td>"+chr(13)+chr(10)
	cLin :=cLin    +"            <td width=05%></td>"+chr(13)+chr(10)
	cLin :=cLin    +"            <td width=10%></td>"+chr(13)+chr(10)
	cLin :=cLin    +"            <td width=10% align='right' bgcolor='#cccccc'><font face='ms sans serif' size=2>Valor Total</font></td>"+chr(13)+chr(10)
	cLin :=cLin    +"            <td width=10% align='right' bgcolor='#cccccc'><font face='ms sans serif' size=2>"+Transform(nTotOrc,"@E 99,999,999.99")+"</font></td>"+chr(13)+chr(10)
	cLin :=cLin    +"         </tr>"+chr(13)+chr(10)
	cLin :=cLin    +"      </table>"+chr(13)+chr(10)
	cLin :=cLin    +"      <hr width=100%>"+chr(13)+chr(10)
	
EndIf

DbSelectArea("SYP") // cbservacao
DbSetOrder(1)

If DbSeek(xFilial("SYP")+SUA->UA_CODOBS)
	While SYP->(! Eof()) .AND. SYP->YP_FILIAL == xFilial("SYP") .AND. SYP->YP_CHAVE == SUA->UA_NUM
		cLin :=cLin +"      <table border=0 width=100%>"+chr(13)+chr(10)
		cLin :=cLin +"         <tr>"+chr(13)+chr(10)
		cLin :=cLin +"            <td width=12%><b>Observacoes</b></td>"+chr(13)+chr(10)
		cLin :=cLin +"            <td><font face='ms sans serif' size=2>: "+stuff(YP_TEXTO,-6,6,"")+"</font></td>"+chr(13)+chr(10)
		cLin :=cLin +"         </tr>"+chr(13)+chr(10)
		cLin :=cLin +"      </table>"+chr(13)+chr(10)
		cLin :=cLin +"      <br>"+chr(13)+chr(10)
		SYP->(DbSkip())
	End
EndIf

DbSelectArea("SE4")
If !DbSeek(xfilial("SE4")+SUA->UA_CONDPG)
	MsgStop(STR0023) //"Condicao de pagamento nao encontrada."
EndIf

cLin :=cLin       +"      <table border=0 width=100%>"+chr(13)+chr(10)
cLin :=cLin       +"         <tr>"+chr(13)+chr(10)
cLin :=cLin       +"            <td colspan=3><font face='ms sans serif' size=2>Condicoes:</font></td>"+chr(13)+chr(10)
cLin :=cLin       +"         </tr>"+chr(13)+chr(10)
cLin :=cLin       +"         <tr>"+chr(13)+chr(10)
cLin :=cLin       +"            <td width=20%><font face='ms sans serif' size=2><u>Prazo p/Pagto</u></font></td>"+chr(13)+chr(10)
cLin :=cLin       +"            <td width=20%><font face='ms sans serif' size=2><u>Prazo de Validade</u></font></td>"+chr(13)+chr(10)
cLin :=cLin       +"            <td width=20%><font face='ms sans serif' size=2><u>Prazo p/Entrega</u></font></td>"+chr(13)+chr(10)
cLin :=cLin       +"         </tr>"+chr(13)+chr(10)
cLin :=cLin       +"         <tr>"+chr(13)+chr(10)
cLin :=cLin       +"            <td width=20%><font face='ms sans serif' size=2><b>"+SE4->E4_DESCRI+"</b></font></td>"+chr(13)+chr(10)
cLin :=cLin       +"            <td width=20%><font face='ms sans serif' size=2><b>"+str(MV_PAR01,2)+" dias</b></font></td>"+chr(13)+chr(10)
cLin :=cLin       +"            <td width=20%><font face='ms sans serif' size=2><b>"+str(MV_PAR02,2)+" dias</b></font></td>"+chr(13)+chr(10)
cLin :=cLin       +"            <td width=05%></td>"+chr(13)+chr(10)
cLin :=cLin       +"         </tr>"+chr(13)+chr(10)
cLin :=cLin       +"      </table>"+chr(13)+chr(10)
cLin :=cLIn       +"      <hr width=100%>"+chr(13)+chr(10)

cLin :=cLin       +"      <br>"+chr(13)+chr(10)
cLin :=cLin       +"   </body>"+CHR(13)+CHR(10) // Fim
cLin :=cLin       +"</html>"+CHR(13)+CHR(10) //

FWrite(nHdl,cLin)
FClose(nHdl)

Return (.T.)