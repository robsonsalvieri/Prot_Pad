#Include "Protheus.ch"
#include "rwmake.ch"
#include "TOPCONN.CH"
#include "prtopdef.CH"                                 

/*/{Protheus.doc} PLSATUDIOPS
Atualizar Contas Contabeis no Configurador dos Extrator DIOPS Financeiro
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSATUDIOPS()

Local olDlg			:= Nil
Local olDoc			:= Nil
Local olArq			:= Nil
Local olBtnOk		:= Nil
Local olBtnCa		:= Nil

Private cpDoc		:= Space(09)
Private cpArq		:= Space(50)
Private lpOk		:= .T.

Private aDados := {}

If ApMsgYesNo("Confirma a atualização da configuração de contas contábeis dos Quadros de Detalhamento?")
	
	olDlg:=MSDialog():New(000,000,160,360,"Aguarde",,,,,,,,,.T.)
	
	@ 10,10 Say "Caminho do Arquivo a ser importado" Pixel of olDlg
	@ 18,10 MsGet olArq Var cpArq Size 130,08 Pixel of olDlg
	DEFINE SBUTTON  FROM 18,140 TYPE 14 ACTION (cpArq:=cGetFile("Arquivos CSV (*.CSV) |*.csv|","",1, 'C:\', .F., GETF_LOCALHARD,.T., .T. )) ENABLE OF olDlg PIXEL
	
	@ 60, 105 BUTTON "Importar" SIZE 30,10 ACTION Eval({|| FImport(3),Iif(lpOk,olDlg:End(),olDoc:SetFocus())}) Object olBtnOk
	@ 60, 140 BUTTON "Cancelar" SIZE 30,10 ACTION olDlg:End() Object olBtnCa
	
	olDlg:Activate(,,,.T.,,,)
EndIf

Return Nil

Static Function fProcessa()
Local nPosCod	:= 1
Local nPosIte	:= 2 
Local nPosSeq	:= 3
Local nPosCta	:= 4
Local nI
        
	dbSelectArea("BRK")
    BRK->(dbSetOrder(1))    //BRK_FILIAL+BRK_CODIGO+BRK_ITEM+BRK_SEQUEN

	ProcRegua(Len(aDados))

	For nI := 2 to Len(aDados)
		If !BRK->(dbSeek(xFilial("BRK")+aDados[nI,nPosCod]+aDados[nI,nPosIte]+aDados[nI,nPosSeq]))
			RecLock("BRK",.t.)
			BRK->BRK_FILIAL := xFilial("BRK") 
			BRK->BRK_CODIGO := aDados[nI,nPosCod]
			BRK->BRK_ITEM   := aDados[nI,nPosIte]
			BRK->BRK_SEQUEN := aDados[nI,nPosSeq]
			BRK->BRK_CONTA 	:= aDados[nI,nPosCta]
			BRK->(msUnLock())
		EndIf 	

    	IncProc()
	Next	

    MsgAlert("Processo concluído.")
Return


Static Function FImport(nOpc)

aDados := {}

Processa({|| aDados := FLeCSV(cpArq) }  ,"Carregando arquivo...")


If nOpc == 3
	If ValType(aDados)<>"L"
		Processa({|| fProcessa() },"Importando registros")
	EndIf
EndIf

Return

Static Function FLeCSV(cCaminho)

Local aRet	:= {}
Local nlHandle := FOpen(cCaminho)
Local nI := 0

If nlHandle == -1
	MsgAlert("Nao foi possivel acessar o arquivo!")
	aRet := .F.
Else
	aRet := {}
	ft_FUse(cCaminho)
	ProcRegua(Ft_FLastRec())
	If (ft_FLastRec()-1) >= 0
		ft_FGoTop()
		Do While !Ft_FEof()
			nI ++
			aAdd(aRet,Separa(ft_FReadLn(),";"))
			IncProc("Processando... Total de carregados: " + AllTrim(STR(nI)))
			ft_FSkip()
		EndDo
		ft_FUse()
		FClose(nlHandle)
	Else
		MsgAlert("O arquivo está vazio!")
		aRet := .F.
	EndIf
EndIf

Return aRet
