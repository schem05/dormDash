from flask import Flask, request, jsonify
import psycopg2
import psycopg2.extras
import requests

app = Flask(__name__)

# Database connection parameters
CONNECTION_STRING = ""

# Function to get database connection


def get_db_connection():
    conn = psycopg2.connect(CONNECTION_STRING)
    return conn


@app.route('/users', methods=['GET'])
def get_users():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cursor.execute("SELECT * FROM users")
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(rows)


@app.route('/received', methods=['POST'])
def received():
    data = request.json
    # The URL to which the request will be sent
    conn = get_db_connection
    conn = get_db_connection()
    cursor = conn.cursor()

    sql = """
        UPDATE rentalRequests
        SET recieved = TRUE
        where requestID = %s
    """
    cursor.execute(sql, (data['requestID'],))



    sql = """
        INSERT INTO allrentals (merchantID, customerID, itemID, term, totalPrice, monthlyPrice, paymentMade, paymentDue, activeStatus)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    cursor.execute(sql, (data['merchantID'], data['customerID'], data['itemID'], data['term'], data['totalPrice'],
                   data['monthlyPrice'], data['paymentMade'], data['paymentDue'], data['activeStatus']))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({"message": "rental inserted successfully"}), 201

    # create customer, account, and merchant


@app.route('/users', methods=['POST'])
def insert_user():
    # Extract data from the POST request
    data = request.json

    # get the customerID
    # The URL to which the request will be sent
    url = ""

    data3 = {
        "first_name": data['firstName'],
        "last_name": data['lastName'],
        "address": {
            "street_number": data['streetNumber'],
            "street_name": data['streetName'],
            "city": data['city'],
            "state": data['stateT'],
            "zip": data['zip']
        }
    }

    # Sending a POST request
    response = requests.post(url, json=data3)
    print(response.text)
    response_data = response.json()

    # Printing the response text (the content of the requested resource)
    customerID2 = response_data['objectCreated']['_id']
    print("customerID")
    print(customerID2)

    # Create Account
    url = ""

    data4 = {
        "type": "Checking",
        "nickname": "Savings",
        "rewards": 0,
        "balance": 100,
        "account_number": "4111111111111111"
    }

    # Sending a POST request
    response = requests.post(url, json=data4)
    print(response.text)
    response_data = response.json()

    # Printing the response text (the content of the requested resource)
    accountID = response_data['objectCreated']['_id']

    # Create Account
    url = ""

    data5 = {
        "name": data['firstName'] + " " + data['lastName'],
        "category": "Misc",
        "address": {
            "street_number": data["streetNumber"],
            "street_name": data["streetName"],
            "city": data["city"],
            "state": data["stateT"],
            "zip": data["zip"]
        },
        "geocode": {
            "lat": 0,
            "lng": 0
        }
    }

    # Sending a POST request
    response = requests.post(url, json=data5)
    print(response.text)
    response_data = response.json()

    # Printing the response text (the content of the requested resource)
    merchantID = response_data['objectCreated']['_id']

    # Create MerchantID

    # The URL to which the request will be sent

    conn = get_db_connection()
    cursor = conn.cursor()
    sql = """
        INSERT INTO users (email, merchantID, customerID, accountID, firstName, lastName, streetNumber, streetName, city, stateT, zip, bio, customerRating, merchantRating, pictureURL, creditScore)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    cursor.execute(sql, (data['email'], merchantID, customerID2, accountID, data['firstName'], data['lastName'], data['streetNumber'], data['streetName'],
                   data['city'], data['stateT'], data['zip'], data['bio'], data['customerRating'], data['merchantRating'], data['pictureURL'], data['creditScore']))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({"message": "User inserted successfully"}), 201

    # create customer, account, and merchant


@app.route('/insertItems', methods=['POST'])
def create_item():
    # Extract data from the POST request
    data = request.json

    # get the customerID
    # The URL to which the request will be sent
    # url = ""

    conn = get_db_connection()
    cursor = conn.cursor()
    sql = """
        INSERT INTO items (itemID, merchantID, itemName, instructions, price, rating, description, address, city, quality, pictures, reviews, active)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    cursor.execute(sql, (data['itemID'], data['merchantID'], data['itemName'], data['instructions'], data['price'], data["rating"], data['description'], data['address'], data['city'],
                   data['quality'], data['pictures'], data['reviews'], data['active']))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({"message": "item created"}), 201

    # create customer, account, and merchant

@app.route('/getRented', methods=['GET'])
def get_rented():
    conn = get_db_connection()
    cursor = conn.cursor()
    sql = """
            SELECT rentalRequests.totalPrice, items.itemname, items.itemrating
            FROM rentalRequests
            JOIN items ON rentalRequests.itemID = items.itemid
            WHERE rentalRequests.received = TRUE
        """
    cursor.execute(sql)
    results = cursor.fetchall()

    rental_requests = [
        {"totalPrice": row[0], "ItemName": row[1], "itemRating": row[2]}
        for row in results
    ]

    cursor.close()
    conn.close()
    return jsonify(rental_requests)

@app.route('/getRequested', methods=['GET'])
def get_requested():
    conn = get_db_connection()
    cursor = conn.cursor()
    sql = """
            SELECT rentalRequests.totalPrice, items.itemname, items.itemrating, rentalRequests.requestID
            FROM rentalRequests
            JOIN items ON rentalRequests.itemID = items.itemid
            WHERE rentalRequests.status = 'pending'
        """
    cursor.execute(sql)
    results = cursor.fetchall()

    rental_requests = [
        {"totalPrice": row[0], "ItemName": row[1], "itemRating": row[2], "requestID": row[3]}
        for row in results
    ]

    cursor.close()
    conn.close()
    return jsonify(rental_requests)

@app.route('/deleteRequest', methods=['POST'])
def delete_requested():
    data = request.json
    conn = get_db_connection()
    cursor = conn.cursor()
    sql = """
            DELETE FROM rentalRequests where id = %s
        """
    
    cursor.execute(sql, (data['requestID'],))
    cursor.execute(sql)
    conn.commit()
    cursor.close()
    conn.close()


@app.route('/createRequest', methods=['POST'])
def create_rental_request():
    # Extract data from the POST request
    data = request.json

    # get the customerID
    # The URL to which the request will be sent
    # url = """"

    conn = get_db_connection()
    cursor = conn.cursor()
    sql = """
        INSERT INTO rentalRequests (requestID, status, merchantID, customerID, itemID, received, term, totalPrice)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """
    cursor.execute(sql, (data['requestID'], data['status'], data['merchantID'],
                   data['customerID'], data['itemID'], data['received'], data['term'], data['totalPrice']))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({"message": "created request"}), 201

    # create customer, account, and merchant


@app.route('/searchItems', methods=['POST'])
def search_items():
    # Extract search term from the POST request
    data = request.json
    search_term = data['name']
    conn = get_db_connection()
    cursor = conn.cursor()

    # Use ILIKE for case-insensitive search and add '%' wildcards for partial matches
    sql = """
        SELECT itemName, price, itemRating
        FROM items
        WHERE itemName ILIKE %s
    """
    cursor.execute(sql, ('%' + search_term + '%',))

    # Fetch all rows that match the query
    rows = cursor.fetchall()

    # Convert fetched rows to a list of dictionaries to return as JSON
    items = [{
        "itemName": row[0],
        "price": row[1],
        "itemRating": row[2],
        # "instructions": row[3],
        # "price": row[4],
        # "description": row[5],
        # "address": row[6],
        # "city": row[7],
        # "quality": row[8],
        # "pictures": row[9],  # Assuming direct conversion to JSON is possible
        # "reviews": row[10],  # Same assumption as above
        # "active": row[11]
    } for row in rows]

    cursor.close()
    conn.close()

    return jsonify(items), 200


@app.route('/getItemDetails', methods=['POST'])
def get_item_details():
    # Extract itemID from the POST request
    data = request.json
    conn = get_db_connection()
    cursor = conn.cursor()

    sql = """
        SELECT itemID
        FROM items
        WHERE requestID = %s
    """
    cursor.execute(sql, (data['requestID'],))
    row = cursor.fetchone
    item_id = row[0]


    # Assuming your items table has columns as described earlier
    sql = """
        SELECT itemID, merchantID, itemName, instructions, price, description, address, city, quality, pictures, reviews, active
        FROM items
        WHERE itemID = %s
    """
    cursor.execute(sql, (item_id,))

    # Fetch one row
    row = cursor.fetchone()

    if row:
        # Mapping the row data to column names for a clearer response
        response_data = {
            "itemID": row[0],
            "merchantID": row[1],
            "itemName": row[2],
            "instructions": row[3],
            "price": row[4],
            "description": row[5],
            "address": row[6],
            "city": row[7],
            "quality": row[8],
            # Assuming this is stored in a format that can be directly converted to JSON
            "pictures": row[9],
            "reviews": row[10],  # Same assumption as above
            "active": row[11]
        }
        response = jsonify(response_data), 200
    else:
        response = jsonify({"error": "Item not found"}), 404

    cursor.close()
    conn.close()

    return response


@app.route('/getUserDetails', methods=['POST'])
def get_user_details():
    # Extract itemID from the POST request
    data = request.json
    customerID = data['customerID']

    conn = get_db_connection()
    cursor = conn.cursor()

    # Assuming your items table has columns as described earlier
    sql = """
        SELECT email, merchantID, customerID, accountID, firstName, lastName, streetNumber, streetName, city, stateT, zip, bio, customerRating, merchantRating, pictureURL, creditScore
        FROM users
        WHERE customerID = %s
    """
    cursor.execute(sql, (customerID,))

    # Fetch one row
    row = cursor.fetchone()

    if row:
        # Mapping the row data to column names for users
        response_data = {
            "email": row[0],
            "merchantID": row[1],
            "customerID": row[2],
            "accountID": row[3],
            "firstName": row[4],
            "lastName": row[5],
            "streetNumber": row[6],
            "streetName": row[7],
            "city": row[8],
            "stateT": row[9],
            "zip": row[10],
            "bio": row[11],
            "customerRating": row[12],
            "merchantRating": row[13],
            "pictureURL": row[14],
            "creditScore": row[15]
        }
        response = jsonify(response_data), 200
    else:
        response = jsonify({"error": "Item not found"}), 404

    cursor.close()
    conn.close()

    return response


@app.route('/updateRequest', methods=['POST'])
def update_rental_request():
    # Extract data from the POST request
    data = request.json
    conn = get_db_connection()
    cursor = conn.cursor()
    sql = """
        UPDATE rentalRequests
        SET status = %s
        WHERE requestID = %s
    """
    cursor.execute(sql, (data['status'], data['requestID']))

    sql = """
        select itemID
        from rentalRequests
        WHERE requestID = %s
    """
    cursor.execute(sql, (data['requestID'],))
    row = cursor.fetchone
    itemID = row[0]

    sql = """
        UPDATE items
        SET active = %s
        WHERE itemID = %s
    """
    cursor.execute(sql, (itemID,))

    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({"message": "Request status updated successfully"}), 200


@app.route('/makePurchase', methods=['POST'])
def make_purchase():
    # Extract data from the POST request
    data = request.json

    # get the customerID
    # The URL to which the request will be sent
    url =  ""

    data3 = {

        "merchant_id": data['merchantID'],
        "medium": "balance",
        "purchase_date": data['paymentMade'],
        "amount": data['price'],
        "status": "pending",
        "description": "Purchase Made"

    }

    # Sending a POST request
    response = requests.post(url, json=data3)
    print(response.text)
    response_data = response.json()

    # second Half

    conn = get_db_connection()
    cursor = conn.cursor()
    # Assuming your items table has columns as described earlier
    sql = """
        SELECT accountID
        FROM users
        WHERE merchantID = %s
    """
    cursor.execute(sql, (data['merchantID'],))

    # Fetch one row
    row = cursor.fetchone()
    accountID = row[0]

    url = ""

    data3 = {
        "medium": "balance",
        "transaction_date": data['paymentMade'],
        "status": "pending",
        "amount": data['price'],
        "description": "string"
    }

    # Sending a POST request
    response = requests.post(url, json=data3)
    print(response.text)

    response_data = {
        "success": "Purchase Completed Successfully"
    }
    response = jsonify(response_data), 200

    cursor.close()
    conn.close()
    return response

@app.route('/getBalance', methods=['GET'])
def getBalance():
    accountID = "" 
    requestURL = ""
    response = requests.get(requestURL)
    return response.json()["balance"]


@app.route('/runSentimentAnalysis', methods=['POST'])
def runSentimentAnalysis():

    conn = get_db_connection()
    cursor = conn.cursor()

    data = request.json
    API_URL = "https://api-inference.huggingface.co/models/LiYuan/amazon-review-sentiment-analysis"
    headers = {"Authorization": ""}

    sql = "SELECT reviews FROM items WHERE itemid = %s;"
    
    cursor.execute(sql, (data['itemID'],))
    payload = cursor.fetchone()
    print(payload)

    response = requests.post(API_URL, headers=headers, json=payload[0])
    updatedRating = response.json()

    max = 0

    conn = get_db_connection()
    cursor = conn.cursor()
    sql = """
        UPDATE items
        SET itemrating = %s
        WHERE itemid = %s
    """

    
    cursor.execute(sql, (updatedRating[0][0]["label"][:1], data['itemID'],))
    print(data['itemID'])
    print(updatedRating[0][0]["label"][:1])

    conn.commit()
    cursor.close()
    conn.close()
    
    
    return updatedRating[0][0]["label"][:1]

    





if __name__ == '__main__':
    app.run(debug=True)

