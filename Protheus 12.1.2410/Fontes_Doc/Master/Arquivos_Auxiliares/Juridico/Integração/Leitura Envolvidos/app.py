from flask import Flask, request, redirect, render_template  # necessário instalar o flask (pip install -U Flask)
from iniciais import findPattern # Importa a função findPattern que está dentro do arquivo iniciais.py

app = Flask(__name__)

@app.route("/")
def home():
    return  redirect("https://tdn.totvs.com/pages/releaseview.action?pageId=497910397")

@app.route('/inicial', methods=['POST'])
    
def retornoInicial():
    data = request.data # Conteúdo recebido através do body da requisição
    data = data.decode('utf-8') 
    oJson = findPattern(data)
    return oJson, 200

if __name__ == '__main__':
    app.run()
