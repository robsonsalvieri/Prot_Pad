from flask import Flask, request, render_template
from iniciais import findPattern # Importa a função findPattern que está dentro do arquivo iniciais.py

sigajuri = Flask(__name__)

@sigajuri.route("/")
def home():
    return render_template("home.html")

@sigajuri.route('/inicial', methods=['POST'])
    
def retornoInicial():
    data = request.data # Conteúdo recebido através do body da requisição
    data = data.decode('utf-8') 
    oJson = findPattern(data)
    return oJson, 200

if __name__ == '__main__':
    sigajuri.run(debug=True)