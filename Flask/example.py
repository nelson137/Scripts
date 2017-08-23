from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def index():
	return '<h1>Index Page</h1>'

@app.route('/example', methods=['GET', 'POST'])
def example():
	links = ['https://www.youtube.com', 'https://www.reddit.com', 'https://www.google.com']
	return render_template('example.html', var='VARIABLE PASSED IN', links=links)

if __name__ == '__main__':
	app.run(debug=True)
