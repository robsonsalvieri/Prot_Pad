//Função utilizada em formulários
function limparMsg(cElem, cElemMsg)
{
	document.getElementById(cElem).style.backgroundColor = "#FFFFFF";
	document.getElementById(cElem).style.border = "solid 1px #D1D1D1";
	document.getElementById(cElemMsg).innerHTML = "";
}

//Função utilizada no pwsr00b.aph
function DinMenu( idElemento )
{
	if ( document.getElementById( idElemento ).style.display == "none" )
		document.getElementById( idElemento ).style.display = '';
	else
		document.getElementById( idElemento ).style.display = "none";

}