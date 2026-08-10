// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Ferramentas
// Fonte  : DWMakeSite - Rotinas para construção/manipulação dos arquivos estaticos do site
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 30.11.03 | 0548-Alan Candido |
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "dwmaksit.ch"

function dwMakeSite(acHost, acNewHost)
	local aFiles := { "\IntegracaoSigaDW.xla" }
	local nInd, cFileIn, oFileIn, oFileOut, cDados, lOk := .t.
	local nTam, x
	
	acHost := "http://" + acHost
	acNewHost := "http://" + acNewHost
	
	oFileOut := TDWFileIO():New(DwTempPath() + "\wkfile.out")
	
	for nInd := 1 to len(aFiles)
		cFileIn := DWHomePage() + aFiles[nInd]
		oFileIn := TDWFileIO():New(cFileIn)
		
		if (oFileIn:Open())
			cDados := space(oFileIn:Size())
			if (oFileIn:Read(@cDados) > 0)
				oFileIn:Close()
				
				//Qdo for integracao excel, devera ser feita a copia do arquivo
				//original para alterar o host. Sera feita o download da copia
				//para o usuario.
				if right(aFiles[nInd],4) == ".xla" //arquivo de integração
					oFileOut:Filename(DwTempPath() + "\DWExcel" + dwInt2Hex(oUserDW:UserID(),8) + ".xla")  //DWHomePage()
					oFileOut:open()
					if oFileOut:Exists()
						oFileOut:erase()
					endif
				else
					oFileOut:Filename(DwTempPath() + "\wkfile.out")
				endif
				
				if oFileOut:Create()
					/*Arquivo de integração*/
					if right(aFiles[nInd],4) == ".xla" 
						
						for x := 1 to len(cDados)
							 
							/*Monta substring com o tamanho da string do site atual e compara.*/							
							cSubDd := substr(cDados, x, len(acHost)) 
							
							if cSubDd == acHost
								cDados := substr(cDados, 1, x-1) + acNewHost + ;
								replicate(" ", 120 - len(acNewHost)) + ;
								substr(cDados, x + 120)
								
							endif
							
							/*Monta uma substring com sete caracteres e tenta associá-la com um string internacionalizada.*/
							cSubDd := substr(cDados, x, 7)
							
							/*"O objetivo desta ferramenta é permitir ao usuário recuperar suas consultas diretamente do SigaDW."*/
							if cSubDd == 'STR0004'
								cDados := substr(cDados, 1, x-1) + STR0004 +;
								replicate(" ", 110 - Len(STR0004)) + ;
								substr(cDados, x + 110)
							endif
                            
                            /*"Seja bem-vindo"*/
							if cSubDd == 'STR0005'
								cDados := substr(cDados, 1, x-1) + STR0005 +; 
								replicate(" ", 15 - Len(STR0005)) + ;
								substr(cDados, x +15)
							endif
							
							/*"Data Warehouse e Consulta"*/
							if cSubDd == 'STR0006'
								cDados := substr(cDados, 1, x-1) + STR0006 +;
								replicate(" ", 25 - Len(STR0006)) + ;
								substr(cDados, x + 25)
							endif
							
							/*"Consulta"*/
							if cSubDd == 'STR0007'
								cDados := substr(cDados, 1, x-1) + STR0007 +; 
								replicate(" ", 10 - Len(STR0007)) + ;
								substr(cDados, x + 10)
							endif
							 
							/*"Sair"*/
							if cSubDd == 'STR0008'
								cDados := substr(cDados, 1, x-1) + STR0008 +; 
								replicate(" ", 10 - Len(STR0008)) + ;
								substr(cDados, x + 10)
							endif
						          
							/*"Importar"*/
							if cSubDd == 'STR0009'
								cDados := substr(cDados, 1, x-1) + STR0009 +; 
								replicate(" ", 10 - Len(STR0009)) + ;
								substr(cDados, x + 10)
							endif  
							
							/*"Cancelar"*/
							if cSubDd == 'STR0010'
								cDados := substr(cDados, 1, x-1) + STR0010 +; 
								replicate(" ", 10 - Len(STR0010)) + ;
								substr(cDados, x + 10)
							endif     
							
							/*"Não Aplicar"*/
							if cSubDd == 'STR0011'
								cDados := substr(cDados, 1, x-1) + STR0011 +; 
								replicate(" ", 15 - Len(STR0011)) + ;
								substr(cDados, x + 15)
							endif    
							
							/*"Aplicar"*/
							if cSubDd == 'STR0012'
								cDados := substr(cDados, 1, x-1) + STR0012 +; 
								replicate(" ", 10 - Len(STR0012)) + ;
								substr(cDados, x + 10)
							endif  
														
							/*"Seleção"*/
							if cSubDd == 'STR0013'
								cDados := substr(cDados, 1, x-1) + STR0013 +; 
								replicate(" ", 10 - Len(STR0013)) + ;
								substr(cDados, x + 10)
							endif 
									 
							/*"Integração DW-Excel"*/
							if cSubDd == 'STR0014'
								cDados := substr(cDados, 1, x-1) + STR0014 +; 
								replicate(" ", 25 - Len(STR0014)) + ;
								substr(cDados, x + 25)
							endif 
							         
							/*"Senha"*/
							if cSubDd == 'STR0023'
								cDados := substr(cDados, 1, x-1) + STR0023 +; 
								replicate(" ", 15 - Len(STR0023)) + ;
								substr(cDados, x + 15)
							endif   
							
							/*"Usuário"*/
							if cSubDd == 'STR0024'
								cDados := substr(cDados, 1, x-1) + STR0024 +; 
								replicate(" ", 15 - Len(STR0024)) + ;
								substr(cDados, x + 15)
							endif         
							          
							/*Idioma do DW.*/
							if cSubDd == 'STR0000'
								cDados := substr(cDados, 1, x-1) + IDIOMA2 +; 
								replicate(" ", Len('STR0000') - Len(IDIOMA2)) + ;
								substr(cDados, x + Len('STR0000'))
							endif 																		
						Next
						   
						
						oFileOut:write(cDados)
						oFileOut:Close()
					else
						if oFileIn:Erase()
							cDados := strTran(cDados, acHost, acNewHost)
							oFileOut:write(cDados)
							oFileOut:Close()
							oFileOut:Rename(oFileIn:Filename())
						else
							conout("... " + STR0001 + " " + cFileIn)
							lOk := .f.
						endif
					endif
				else
					conout("... " + STR0002 +" " + oFileOut:Filename())
					lOk := .f.
				endif
			else
				conout("... " + STR0003 + " " + cFileIn)
				lOk := .f.
			endif
		oFileIn:Close()
	endif
next

return .t.