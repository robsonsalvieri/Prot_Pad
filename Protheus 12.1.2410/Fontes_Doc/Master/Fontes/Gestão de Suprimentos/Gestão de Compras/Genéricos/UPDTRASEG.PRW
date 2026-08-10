#Include "Protheus.ch"

//-----------------------------------------------------------------
/*/{Protheus.doc} IMPTRASEG
Execucao do processo de leitura dos arquivos recebidos via TOTVS Colaboração 2.0.

@author  Rodrigo M Pontes
@since   24/07/2023
@version 11.8
/*/
//-----------------------------------------------------------------
Function UPDTRASEG(aParam) 

Local cCLogAgend  := ""

Private aImpTraTool := {}
Private oCamLog      := ComTransmite():New()

cCLogAgend := oCamLog:LogSegPlan()

aAdd(aImpTraTool,'inicio: ' + Time() + CRLF)

SCHEDUPDTRA()

aAdd(aImpTraTool,'Fim: ' + Time() + CRLF)

ImpTraPrint("UPD",.T.,cCLogAgend)

FwFreeArray(aImpTraTool)
FreeObj(oCamLog)
		
return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna as perguntas definidas no schedule.

@return aReturn			Array com os parametros

@author  Rafael Iaquinto
@since   24/07/2014
@version 12
/*/
//-------------------------------------------------------------------

Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;	//Tipo R para relatorio P para processo
            "",;	//Pergunte do relatorio, caso nao use passar ParamDef
            ,;		//Alias
            ,;		//Array de ordens
            }		//Titulo

Return aParam
