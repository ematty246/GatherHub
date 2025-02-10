import hashlib
from bs4 import BeautifulSoup
from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import pandas as pd
import requests
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash
import os

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(app.root_path, 'data.db')
app.config['SQLALCHEMY_BINDS'] = {
    'default': 'mysql://root:Manu%402006@localhost/flood_reporter',
    'sdma': 'mysql://root:Manu%402006@localhost/sdma',
    'cgwb': 'mysql://root:Manu%402006@localhost/cgwb',
    'cwc': 'mysql://root:Manu%402006@localhost/cwc',
    'fire_services': 'mysql://root:Manu%402006@localhost/fire_services',
    'imd': 'mysql://root:Manu%402006@localhost/imd',
    'indian_army': 'mysql://root:Manu%402006@localhost/indian_army',
    'indian_navy': 'mysql://root:Manu%402006@localhost/indian_navy',
    'ministry_of_jalshakti': 'mysql://root:Manu%402006@localhost/ministry_of_jalshakti',
    'ndma': 'mysql://root:Manu%402006@localhost/ndma',
    'ndrf': 'mysql://root:Manu%402006@localhost/ndrf',
    'nsra': 'mysql://root:Manu%402006@localhost/nsra',
    'nwda': 'mysql://root:Manu%402006@localhost/nwda',
}  
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['UPLOAD_FOLDER'] = 'uploads'
if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])
db = SQLAlchemy(app)


class User(db.Model):
    __bind_key__ = 'default'
    __tablename__ = 'user'  
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(256), unique=True, nullable=False)  
    password = db.Column(db.String(256), nullable=False)
    username = db.Column(db.String(256), unique=True, nullable=False)  

class Users(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(255), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    department = db.Column(db.String(100), nullable=False)


class Report(db.Model):
    __bind_key__ = 'default'
    __tablename__ = 'report'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), nullable=False)  
    description = db.Column(db.String(500), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    department = db.Column(db.String(120), nullable=False)
    category = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    address = db.Column(db.String(500), nullable=False)

class ReportStateDisasterManagementAuthorities(db.Model):
    __bind_key__ = 'sdma'
    __tablename__ = 'reports'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    category = db.Column(db.String(120), nullable=False)
    department = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    address = db.Column(db.String(500), nullable=False)

class ReportCentralGroundWaterBoard(db.Model):
    __bind_key__ = 'cgwb'
    __tablename__ = 'reports'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    category = db.Column(db.String(120), nullable=False)
    department = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    address = db.Column(db.String(500), nullable=False)


class ReportCentralWaterCommission(db.Model):
    __bind_key__ = 'cwc'
    __tablename__ = 'reports'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    category = db.Column(db.String(120), nullable=False)
    department = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    address = db.Column(db.String(500), nullable=False)


class ReportFireServicesDepartment(db.Model):
    __bind_key__ = 'fire_services'
    __tablename__ = 'reports'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    category = db.Column(db.String(120), nullable=False)
    department = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    address = db.Column(db.String(500), nullable=False)


class ReportIndiaMeteorologicalDepartment(db.Model):
    __bind_key__ = 'imd'
    __tablename__ = 'reports'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    category = db.Column(db.String(120), nullable=False)
    department = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    address = db.Column(db.String(500), nullable=False)


class ReportIndianArmyEngineeringCorps(db.Model):
    __bind_key__ = 'indian_army'
    __tablename__ = 'reports'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    category = db.Column(db.String(120), nullable=False)
    department = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    address = db.Column(db.String(500), nullable=False)


class ReportIndianNavy(db.Model):
    __bind_key__ = 'indian_navy'
    __tablename__ = 'reports'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    category = db.Column(db.String(120), nullable=False)
    department = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    address = db.Column(db.String(500), nullable=False)


class ReportMinistryOfJalShakti(db.Model):
    __bind_key__ = 'ministry_of_jalshakti'
    __tablename__ = 'reports'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    category = db.Column(db.String(120), nullable=False)
    department = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    address = db.Column(db.String(500), nullable=False)


class ReportNationalDisasterManagementAuthority(db.Model):
    __bind_key__ = 'ndma'
    __tablename__ = 'reports'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    category = db.Column(db.String(120), nullable=False)
    department = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    address = db.Column(db.String(500), nullable=False)


class ReportNationalDisasterResponseForce(db.Model):
    __bind_key__ = 'ndrf'
    __tablename__ = 'reports'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    category = db.Column(db.String(120), nullable=False)
    department = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    address = db.Column(db.String(500), nullable=False)


class ReportNationalSearchAndRescueAgency(db.Model):
    __bind_key__ = 'nsra'
    __tablename__ = 'reports'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    category = db.Column(db.String(120), nullable=False)
    department = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    address = db.Column(db.String(500), nullable=False)


class ReportNationalWaterDevelopmentAgency(db.Model):
    __bind_key__ = 'nwda'
    __tablename__ = 'reports'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(120), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    category = db.Column(db.String(120), nullable=False)
    department = db.Column(db.String(120), nullable=False)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    address = db.Column(db.String(500), nullable=False)


@app.route('/')
def index():
    return jsonify({'message': 'Welcome to Water Reporter'})

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'GET':
        return jsonify({'message': 'Use POST method to register a user'}), 405 

    data = request.get_json()
    if not data:
        return jsonify({'error': 'Request must be JSON'}), 400

    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'error': 'Email and password are required'}), 400


    if User.query.filter_by(email=email.lower()).first():
        return jsonify({'error': 'User already exists'}), 409  

    
    hashed_email = generate_password_hash(email.lower(), method='pbkdf2:sha256')
    hashed_password = generate_password_hash(password, method='pbkdf2:sha256')

    new_user = User(email=hashed_email, password=hashed_password)
    db.session.add(new_user)
    db.session.commit()

  
    return jsonify({'message': 'User registered successfully'}), 201

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        return jsonify({'message': 'Use POST method to login'})

    data = request.get_json()
    if not data:
        return jsonify({'error': 'Request must be JSON'}), 400

    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'error': 'Email and password are required'}), 400
    users = User.query.all()
    user = None
    for u in users:
        if check_password_hash(u.email, email.lower()):
            user = u
            break

    if not user or not check_password_hash(user.password, password):
        return jsonify({'error': 'Invalid email or password'}), 401

    return jsonify({'message': 'Login successful'})

@app.route('/report', methods=['GET', 'POST'])
def report():
    if request.method == 'GET':
        return jsonify({'message': 'Use POST method to submit a report'})


    username = request.form.get('username')  
    description = request.form.get('description')
    image = request.files.get('image')
    department = request.form.get('department')
    category = request.form.get('category')
    latitude = request.form.get('latitude')
    longitude = request.form.get('longitude')
    address = request.form.get('address')

    if not username or not description or not image or not department or not category:
        return jsonify({'error': 'Username, description, image, department, and category are required'}), 400

    try:
        image_url = os.path.join(app.config['UPLOAD_FOLDER'], secure_filename(image.filename))
        image.save(image_url)
    except Exception as e:
        return jsonify({'error': f'Failed to save the image: {str(e)}'}), 500

    class_name = f"Report{department.replace(' ', '').replace('&', '').replace('-', '')}"
    report_class = globals().get(class_name)

    if not report_class:
        return jsonify({'error': f'Invalid department model: {department}'}), 400

    report_instance = report_class(
        username=username,  
        description=description,
        image_url=image_url,
        category=category,
        department=department,
        latitude=latitude,
        longitude=longitude,
        address=address
    )

    try:
        db.session.add(report_instance)
        db.session.commit()
        return jsonify({'message': 'Report submitted successfully'}), 200
    except Exception as e:
        print(f"Failed to submit the report: {str(e)}")
        return jsonify({'error': f'Failed to submit the report: {str(e)}'}), 500
@app.route('/reports', methods=['GET'])
def get_reports():

    report_classes = [
        ReportStateDisasterManagementAuthorities,
        ReportCentralGroundWaterBoard,
        ReportCentralWaterCommission,
        ReportFireServicesDepartment,
        ReportIndiaMeteorologicalDepartment,
        ReportIndianArmyEngineeringCorps,
        ReportIndianNavy,
        ReportMinistryOfJalShakti,
        ReportNationalDisasterManagementAuthority,
        ReportNationalDisasterResponseForce,
        ReportNationalSearchAndRescueAgency,
        ReportNationalWaterDevelopmentAgency
    ]

    reports_list = []
    for report_class in report_classes:
        reports = report_class.query.all()
        for report in reports:
            reports_list.append({
                'id': report.id,
                'username': report.username, 
                'description': report.description,
                'category': report.category,
                'department': report.department,
                'image_url': report.image_url,
                'latitude': report.latitude,
                'longitude': report.longitude,
                'address': report.address 
            })

    return jsonify(reports_list), 200
@app.route('/reports/<int:report_id>', methods=['DELETE'])
def delete_report(report_id):

    report_classes = [
        ReportStateDisasterManagementAuthorities,
        ReportCentralGroundWaterBoard,
        ReportCentralWaterCommission,
        ReportFireServicesDepartment,
        ReportIndiaMeteorologicalDepartment,
        ReportIndianArmyEngineeringCorps,
        ReportIndianNavy,
        ReportMinistryOfJalShakti,
        ReportNationalDisasterManagementAuthority,
        ReportNationalDisasterResponseForce,
        ReportNationalSearchAndRescueAgency,
        ReportNationalWaterDevelopmentAgency
    ]

    for report_class in report_classes:
        report = report_class.query.get(report_id)
        if report:
            db.session.delete(report)
            db.session.commit()
            return jsonify({"message": "Report deleted successfully"}), 200

    return jsonify({"message": "Report not found"}), 404
@app.route('/reports/<department>', methods=['GET'])
def get_reports_by_department(department):
    class_name = f"Report{department.replace(' ', '').replace('&', '').replace('-', '')}"
    report_class = globals().get(class_name)

    if not report_class:
        return jsonify({'error': f'Invalid department model: {department}'}), 400

    reports = report_class.query.all()
    report_list = [
        {
            'id': report.id,
            'username': report.username,
            'description': report.description,
            'image_url': report.image_url,
            'category': report.category,
            'department': report.department,
            'latitude': report.latitude,
            'longitude': report.longitude,
            'address': report.address 
        }
        for report in reports
    ]
    return jsonify(report_list), 200
@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/report_count', methods=['GET'])
def get_report_count():
    try:
        response = requests.get("http://192.168.208.86:5000/reports")
        if response.status_code != 200:
            return jsonify({"error": "Failed to fetch reports"}), 500
        
        reports = response.json()
        report_count = {} 
        
        for report in reports:
            username = report.get("username", "").strip()
            if username:
                report_count[username] = report_count.get(username, 0) + 1
        
        return jsonify(report_count)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

volunteers = []


@app.route('/registervolunteer', methods=['POST'])
def register_volunteer():
    data = request.get_json()


    full_name = data.get('full_name')
    contact_number = data.get('contact_number')
    email = data.get('email')
    address = data.get('address')
    preferred_role = data.get('preferred_role')
    available_times = data.get('available_times')

    if not all([full_name, contact_number, email, address, preferred_role, available_times]):
        return jsonify({"message": "All fields are required"}), 400


    new_volunteer = {
        "full_name": full_name,
        "contact_number": contact_number,
        "email": email,
        "address": address,
        "preferred_role": preferred_role,
        "available_times": available_times,
    }


    volunteers.append(new_volunteer)
    return jsonify({"message": "Volunteer registered successfully"}), 201


@app.route('/volunteers', methods=['GET'])
def get_volunteers():
    return jsonify({"volunteers": volunteers}), 200

@app.route('/volunteer_names', methods=['GET'])
def get_volunteer_names():
    names = [volunteer["full_name"] for volunteer in volunteers]
    return jsonify({"volunteer_names": names}), 200

OPENWEATHER_API_KEY = "0c8fb6ec6498bacdba8143d3553b2561"
GEMINI_API_KEY = "AIzaSyBoX9bHUASoIB-EmElOZg7DaBvnwAJHnOY"

def get_city_name(lat, lon):
    """Get city name using OpenStreetMap Nominatim Reverse Geocoding"""
    url = f"https://nominatim.openstreetmap.org/reverse?format=json&lat={lat}&lon={lon}"
    response = requests.get(url)

    print("OSM API Response Status Code:", response.status_code)
    print("OSM API Response:", response.text)  

    try:
        data = response.json()
        return data.get("address", {}).get("city", "Unknown City")
    except requests.exceptions.JSONDecodeError:
        print("Error: Received invalid JSON response")
        return "Unknown City"

def get_aqi_data(lat, lon):
    """Fetch AQI data from OpenWeather API using lat/lon."""
    url = f"http://api.openweathermap.org/data/2.5/air_pollution?lat={lat}&lon={lon}&appid={OPENWEATHER_API_KEY}"
    response = requests.get(url)
    data = response.json()

    if "list" not in data:
        return None

    pollution = data["list"][0]["components"]
    return {
        "PM2_5": pollution["pm2_5"],
        "CO": pollution["co"],
        "NO2": pollution["no2"],
        "SO2": pollution["so2"]
    }


def get_gemini_suggestion(pm25, co, no2, so2):
    """Get AI-based outdoor activity suggestion from Gemini"""
    prompt = f"Based on air quality levels PM2.5: {pm25}, CO: {co}, NO2: {no2}, SO2: {so2},analyze and suggest the best outdoor activity times and give me in 5 lines"

    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={GEMINI_API_KEY}"
    headers = {"Content-Type": "application/json"}
    data = {"contents": [{"parts": [{"text": prompt}]}]}

    response = requests.post(url, json=data, headers=headers)
    
    print("Gemini API Response Status Code:", response.status_code)
    print("Gemini API Response:", response.text) 

    try:
        result = response.json()
        return result.get("candidates", [{}])[0].get("content", "No suggestion available.")
    except requests.exceptions.JSONDecodeError:
        return "No suggestion available."

@app.route('/aqi', methods=['GET'])
def get_aqi():
    lat = request.args.get("lat")
    lon = request.args.get("lon")

    if not lat or not lon:
        return jsonify({"error": "Latitude and longitude are required"}), 400

    aqi_data = get_aqi_data(lat, lon)
    if not aqi_data:
        return jsonify({"error": "AQI data not found"}), 400

    suggestion = get_gemini_suggestion(aqi_data["PM2_5"], aqi_data["CO"], aqi_data["NO2"], aqi_data["SO2"])
    aqi_data["suggestion"] = suggestion

    return jsonify(aqi_data)

if __name__ == '__main__':
    with app.app_context():
        db.create_all()

    app.run(host="0.0.0.0", port=5000, debug=True)
