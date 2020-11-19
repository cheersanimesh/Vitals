from flask import Flask, render_template

app = Flask(__name__)

upload = './upload-folder/'
Allowed_Extensions = {}

@app.route('/', methods=["GET"])
def hello():
    return render_template('index.html')

@app.route('/result', methods=["POST"])
def result():
    return render_template('result.html')
if __name__ == '__main__':
    app.run()
