// constantes de dimensionamento/posicionamento (em caso de alteração, favor revisar dwToolMeta.aph)
//http://www.adobe.com/svg/viewer/install/
// constantes de uso geral
var TEXT_COLOR = 'rgb(255, 255, 255)';
var TITLE_COLOR = 'rgb(0, 0, 0)';
var PAT_HEIGHT = 22;
var PAT_WIDTH = 155;
var PAD_TEXT_LEFT = 5;
var PAD_TEXT_TOP = 3
var SHADOW_COLOR = 'silver';
var SHADOW_OFFSET_X = 3;
var SHADOW_OFFSET_Y = 3;

// DIMENSAO: constantes de uso 
var DIM_WIDTH = PAT_WIDTH;
var DIM_HEIGHT = PAT_HEIGHT;
var DIM_COLOR = 'rgb(181, 198, 219)';
var DIM_BORDER_COLOR = 'rgb(195, 205, 223)';
var BORDER_WIDTH = 4;
var DIM_IN_CUBE_COLOR = 'rgb(123, 160, 202)';

// CUBO: constantes de uso 
var CUB_WIDTH = PAT_WIDTH;
var CUB_HEIGHT = PAT_HEIGHT;
var CUB_COLOR = 'rgb(181, 198, 219)';
var CUB_BORDER_COLOR = 'rgb(195, 205, 223)';

// ATRIBUTOS: constantes de uso 
var ATT_WIDTH = PAT_WIDTH - 10;
var ATT_HEIGHT = PAT_HEIGHT;
var ATT_COLOR = 'rgb(136, 167, 203)';
var ATT_KEY_COLOR = 'rgb(99, 139, 203)';
var ATT_MARGIN_BOTTOM = 4;
var ATT_KEY_CUBE_COLOR = 'rgb(156, 184, 215)';

// INDICADORES: constantes de uso 
var IND_COLOR = 'rgb(99, 139, 188)';
var IND_VIRT_COLOR = 'rgb(142, 175, 212)';


// FONTE DE DADOS (servidores): constantes de uso 
var DSN_WIDTH = PAT_WIDTH;
var DSN_HEIGHT = PAT_HEIGHT;
var DSN_COLOR = 'rgb(123, 160, 202)';

// LINKS: constantes de uso
var ARROW_COLOR = "rgb(190, 192, 211)";
var ARROW_PADDING = 8;
var ARROW_WIDTH = 10;

var ctx;
var objPos;

function setCurrentContext(acID)
{
	ctx = getElement(acID).getContext('2d');
	objPos = new Array();
}

function registerPos(acID, anX, anY, anW, anH)
{                               
	var obj = { x:anX, y:anY, w:anW, h:anH, cx: 0, cy: 0, left:0, right:0, target: null};
	
	obj.cx = Math.ceil(anW/2)+anX;
	obj.cy = Math.ceil(anH/2)+anY;

	obj.left = anX;
	obj.right = anX + anW;
	
	objPos[acID] = obj;
}

function linkTo(acSourceID, acTargetID)
{
  var oSource = objPos[acSourceID];
  var oTarget = objPos[acTargetID];

	if (oSource)
		oSource.target = acTargetID;
	else
		alert('Elemento origem ['+acSourceID+'] não registrado.');
}

function drawArrow(anX1, anY1, anX2, anY2, acColor)
{                 
  // considerar ARROW_PADDING
  ctx.save();
	ctx.strokeStyle = acColor;
	ctx.moveTo(anX1, anY1);
	ctx.lineTo(anX2, anY2);
	ctx.stroke();
  ctx.restore();
}
  
function drawLinks()
{
	for (var o in objPos)           
		if (objPos[o].target)
			drawLink(objPos[o], objPos[objPos[o].target]);
}

function drawLink(oSource, oTarget)
{
	ctx.save();
	ctx.beginPath();
	if (oSource.left > oTarget.x)
		drawArrow(oSource.left, oSource.cy, oTarget.right, oTarget.cy, ARROW_COLOR);
	else                              
		drawArrow(oTarget.left, oTarget.cy, oSource.right, oSource.cy, ARROW_COLOR);
	ctx.closePath();

	ctx.restore();
}

function drawAtt(anX, anY, acName, acColor)
{
  var nBaseX = anX;
  var nBaseY = anY;

	ctx.save();
                                                
	ctx.fillStyle = acColor
	ctx.fillRect (nBaseX, nBaseY, ATT_WIDTH, ATT_HEIGHT);

	ctx.color = TEXT_COLOR;
	ctx.drawText(anX + PAD_TEXT_LEFT, anY + PAD_TEXT_TOP, acName);

	ctx.restore();
}

function drawDimension(acID, anX, anY, acName, acDescription, aaKeys, aaAtts, acColor)
{                                             
	var lDesc = ((acDescription.length > 0 ))?true:false;
  var nDesloc = ATT_HEIGHT + ATT_MARGIN_BOTTOM
	var nHeight = DIM_HEIGHT + (aaKeys.length * nDesloc) + (aaAtts.length * nDesloc) + (ATT_HEIGHT * (lDesc?1.5:1));
  var nBaseX = anX;
  var nBaseY = anY;      

	ctx.save();
	
	if (acColor)
	{
		ctx.save();
		ctx.fillStyle = acColor;
		ctx.shadowColor = SHADOW_COLOR;
		ctx.shadowOffsetX = SHADOW_OFFSET_X;
		ctx.shadowOffsetY = SHADOW_OFFSET_Y;
		ctx.fillRect(nBaseX, nBaseY, DIM_WIDTH, nHeight);
		ctx.restore();
	} else
	{
		ctx.save();
		ctx.fillStyle = DIM_BORDER_COLOR;
		ctx.shadowColor = SHADOW_COLOR;
		ctx.shadowOffsetX = SHADOW_OFFSET_X;
		ctx.shadowOffsetY = SHADOW_OFFSET_Y;
		ctx.fillRect(nBaseX - BORDER_WIDTH, nBaseY - BORDER_WIDTH, DIM_WIDTH + BORDER_WIDTH * 2, nHeight + BORDER_WIDTH * 2);
		ctx.restore();
		ctx.fillStyle = DIM_COLOR;
		ctx.fillRect(nBaseX, nBaseY, DIM_WIDTH, nHeight);
  }
                    
	ctx.save();
	ctx.color = TITLE_COLOR;                
	nBaseY += PAD_TEXT_TOP;
	ctx.drawText(anX + PAD_TEXT_LEFT, nBaseY, "<b>" + acName + "</b>");
	if (lDesc)
	{
		nBaseY += nDesloc / 2;
		ctx.drawText(anX + PAD_TEXT_LEFT, nBaseY, "<div style='font-size: small; height: 20px; width: "+DIM_WIDTH+"px; overflow: hidden;'>"+acDescription+"</div>");
	}
	ctx.restore();

	nBaseY += nDesloc * 1.2;
	
	for (var i=0;i<aaKeys.length;i++)
	{        
		drawAtt(nBaseX + 5, nBaseY, aaKeys[i], acColor?ATT_KEY_CUBE_COLOR:ATT_KEY_COLOR);
		nBaseY += nDesloc;
	}
                       
	if (aaAtts.length > 0)
	{
		nBaseY += ATT_HEIGHT * 0.3;
	
		for (var i=0;i<aaAtts.length;i++)
		{
			drawAtt(nBaseX + 5, nBaseY, aaAtts[i], ATT_COLOR);
			nBaseY += nDesloc;
		}
	}
	
	registerPos(acID, anX, anY, DIM_WIDTH, nHeight);
}

function drawCube(acID, anX, anY, acName, acDescription, aaInds, aaVirts)
{
  var nDesloc = ATT_HEIGHT + ATT_MARGIN_BOTTOM
	var nHeight = CUB_HEIGHT + (aaInds.length * nDesloc) + (aaVirts.length * nDesloc) + nDesloc;
  var nBaseX = anX;
  var nBaseY = anY;

	ctx.save();

	ctx.save();
	ctx.shadowColor = SHADOW_COLOR;
	ctx.shadowOffsetX = SHADOW_OFFSET_X;
	ctx.shadowOffsetY = SHADOW_OFFSET_Y;
	ctx.fillStyle = CUB_BORDER_COLOR;
	ctx.fillRect(nBaseX - BORDER_WIDTH, nBaseY - BORDER_WIDTH, CUB_WIDTH + BORDER_WIDTH * 2, nHeight + BORDER_WIDTH * 2);
	ctx.restore();
	
	ctx.fillStyle = CUB_COLOR;
	ctx.fillRect(nBaseX, nBaseY, CUB_WIDTH, nHeight);
		
	nBaseY += nDesloc * 1.2;

	for (var i=0;i<aaInds.length;i++)
	{
		drawAtt(nBaseX + 5, nBaseY, aaInds[i], IND_COLOR);
		nBaseY += nDesloc;
	}

	if (aaInds.length > 0)
	{
		for (var i=0;i<aaVirts.length;i++)
		{
			drawAtt(nBaseX + 5, nBaseY, aaVirts[i], IND_VIRT_COLOR);
			nBaseY += nDesloc;
		}
	}
	
	ctx.color = TITLE_COLOR;
	ctx.drawText(anX + PAD_TEXT_LEFT, anY + PAD_TEXT_TOP, acName);

	ctx.restore();

	registerPos(acID, anX, anY, CUB_WIDTH, nHeight);
}

function drawServer(acID, anX, anY, acConector, acServer)
{
  var nBaseX = anX;
  var nBaseY = anY;

	ctx.save();

	ctx.fillStyle = DSN_COLOR;
	ctx.shadowColor = SHADOW_COLOR;
	ctx.shadowOffsetX = SHADOW_OFFSET_X;
	ctx.shadowOffsetY = SHADOW_OFFSET_Y;
	ctx.fillRect(nBaseX, nBaseY, DSN_WIDTH, DSN_HEIGHT);
	ctx.color = TEXT_COLOR;
	ctx.drawText(anX + PAD_TEXT_LEFT, anY + PAD_TEXT_TOP, acServer +':' + acConector);

	ctx.restore();

	registerPos(acID, anX, anY, DSN_WIDTH, DSN_HEIGHT);
}

function drawAlign(acID, acAlign) //'left/center/right'
{
  var oCanvas = getElement(acID);
  var nLeft = 9999;
  var nRight = 0;
	
	if (!acAlign)
		acAlign = 'center';
		
	for (var o in objPos)
	{
		nLeft = Math.min(nLeft, objPos[o].x);
		nRight = Math.max(nRight, objPos[o].right);
	}		

	if (acAlign == 'center')
		ctx.translate(0, Math.ceil((oCanvas.style.pixelWidth - nRight) / 2));
	else if (acAlign == 'right')
		ctx.translate(0, oCanvas.style.pixelWidth - nRight);
}

// faz uma linha de contorno
//	ctx.strokeRect(anX, axY, DIM_WIDTH, nHeight);

// traça uma linha a partir da posição correte
//	ctx.lineTo(anX, axY);

// desloca a posição correte
//	ctx.moveTo(anX, axY);

// estilos de linha
//	ctx.lineWidth = value
//	ctx.lineCap = type
//	ctx.lineJoin = type
//	ctx.miterLimit = value


// salva/restore de estatdos
//	ctx.save()
//	ctx.restore()


// desloca o eixo x/y, rotação, escala
//	ctx.translate(x, y)        
//	ctx.rotate(angle)
//	ctx.scale(x, y)        
  
// quadrilatero
//	ctx.fillStyle = 'rgba(0, 0, 200, 0.5)';
//	ctx.fillRect (30, 30, 55, 50);
	
// beginPath (poligono irretular)
//	ctx.fillStyle = 'red';
//	ctx.beginPath();
//	ctx.moveTo(30, 30);
//	ctx.lineTo(150, 150);
//	ctx.quadraticCurveTo(60, 70, 70, 150);
//	ctx.lineTo(30, 30);
//	ctx.fill();
