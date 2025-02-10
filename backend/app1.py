from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
import requests
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root:Manu%402006@localhost/dbname'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(255), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    department = db.Column(db.String(100), nullable=False)

with app.app_context():
    db.create_all()


@app.route('/register/<department>', methods=['POST'])
def register_user(department):
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'error': 'Username and password are required'}), 400

    hashed_password = generate_password_hash(password)

    new_user = User(username=username, password=hashed_password, department=department)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({'message': 'User registered successfully'}), 201

@app.route('/login/<department>', methods=['POST'])
def login_user(department):
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    user = User.query.filter_by(username=username, department=department).first()
    if not user or not check_password_hash(user.password, password):
        return jsonify({'error': 'Invalid username or password'}), 401

    return jsonify({'message': 'Login successful'}), 200

@app.route('/get_credentials/<department>', methods=['GET'])
def get_credentials(department):
    users = User.query.filter_by(department=department).all()
    if not users:
        return jsonify({'error': 'No users found for this department'}), 404
    return jsonify([{'username': u.username, 'department': u.department} for u in users]), 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5001, debug=True)
