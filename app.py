    import os
from flask import Flask, request, jsonify
import google.generativeai as genai
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for frontend communication

# Securely get Gemini API key from environment variable
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY is not set in the environment.")

genai.configure(api_key=GEMINI_API_KEY)

# Sample Expense Data
EXPENSE_DATA = {
    "expenses": [
        {"id": 1, "amount": 45.00, "category": "Food", "date": "2025-03-15", "notes": "Grocery shopping"},
        {"id": 2, "amount": 30.00, "category": "Transportation", "date": "2025-03-16", "notes": "Uber ride"},
        {"id": 3, "amount": 15.50, "category": "Entertainment", "date": "2025-03-18", "notes": "Movie ticket"},
        {"id": 4, "amount": 120.00, "category": "Food", "date": "2025-03-19", "notes": "Restaurant dinner"},
        {"id": 5, "amount": 50.00, "category": "Shopping", "date": "2025-03-20", "notes": "New shirt"}
    ],
    "budgets": {
        "Food": 200.00,
        "Transportation": 150.00,
        "Entertainment": 100.00,
        "Shopping": 200.00
    }
}

# Helper Functions
def get_total_expense(category=None):
    """Calculates total expenses, optionally filtered by category."""
    return sum(exp["amount"] for exp in EXPENSE_DATA["expenses"] if category is None or exp["category"].lower() == category.lower())

def get_remaining_budget(category):
    """Calculates remaining budget for a category."""
    total_spent = get_total_expense(category)
    budget = EXPENSE_DATA["budgets"].get(category, 0)
    return budget - total_spent, budget

# API Endpoints
@app.route('/')
def home():
    return jsonify({"message": "Flask Backend is Running on Azure!"})

@app.route('/chatbot', methods=['POST'])
def chatbot():
    data = request.json
    user_query = data.get("query", "").lower()

    # Process query to provide direct responses
    if "spent on food" in user_query:
        total_spent = get_total_expense("Food")
        budget = EXPENSE_DATA["budgets"].get("Food", 0)
        response_text = f"You have spent ₹{total_spent} on Food. Your budget limit is ₹{budget}."
    elif "total spending" in user_query:
        total_spent = get_total_expense()
        response_text = f"Your total spending so far is ₹{total_spent}."
    elif "remaining budget for food" in user_query:
        remaining, budget = get_remaining_budget("Food")
        response_text = f"Your remaining budget for Food is ₹{remaining} out of ₹{budget}."
    else:
        # Structured LLM prompt for handling complex queries
        expense_data_str = f"Expense data: {EXPENSE_DATA}"
        prompt = f"""
        You are an AI financial assistant that helps users analyze their expenses.
        Use the given structured expense and budget data to answer queries.

        User Query: {user_query}
        
        {expense_data_str}

        Provide an accurate and helpful response, focusing only on expenses, budgets, and financial insights.
        """
        response = genai.GenerativeModel("gemini-2.0-flash").generate_content(prompt)
        response_text = response.text

    return jsonify({"response": response_text})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)  # Required for Azure Deployment
