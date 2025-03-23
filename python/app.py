import os
from flask import Flask, request, jsonify
import google.generativeai as genai
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for frontend API calls

# Configure Gemini API securely
API_KEY = os.getenv("GEMINI_API_KEY")
if not API_KEY:
    raise ValueError("GEMINI_API_KEY environment variable not set")
genai.configure(api_key=API_KEY)

# Realistic Sample Expense Data (INR)
EXPENSE_DATA = {
    "expenses": [
        {"id": 1, "amount": 850.00, "category": "Food", "date": "2025-03-15", "notes": "Dinner at a mid-range restaurant"},
        {"id": 2, "amount": 300.00, "category": "Transportation", "date": "2025-03-16", "notes": "Local taxi ride"},
        {"id": 3, "amount": 1200.00, "category": "Entertainment", "date": "2025-03-18", "notes": "Concert ticket"},
        {"id": 4, "amount": 25000.00, "category": "Travel", "date": "2025-03-19", "notes": "Round-trip domestic flight"},
        {"id": 5, "amount": 2500.00, "category": "Shopping", "date": "2025-03-20", "notes": "Clothing and accessories"},
        {"id": 6, "amount": 450.00, "category": "Food", "date": "2025-03-21", "notes": "Lunch at a café"},
        {"id": 7, "amount": 200.00, "category": "Transportation", "date": "2025-03-22", "notes": "Metro pass"},
        {"id": 8, "amount": 5000.00, "category": "Health", "date": "2025-03-22", "notes": "Doctor consultation and medicines"}
    ],
    "budgets": {
        "Food": 5000.00,
        "Transportation": 3000.00,
        "Entertainment": 5000.00,
        "Shopping": 10000.00,
        "Travel": 30000.00,
        "Health": 7000.00
    }
}

def get_total_expense(category=None):
    """Calculates total expenses, optionally filtered by category."""
    return sum(exp["amount"] for exp in EXPENSE_DATA["expenses"] if category is None or exp["category"].lower() == category.lower())

def get_remaining_budget(category):
    """Calculates remaining budget for a category."""
    total_spent = get_total_expense(category)
    budget = EXPENSE_DATA["budgets"].get(category, 0)
    remaining_budget = budget - total_spent
    return remaining_budget, budget

@app.route('/chatbot', methods=['POST'])
def chatbot():
    data = request.json
    user_query = data.get("query", "")

    if not user_query:
        return jsonify({"error": "Query is required"}), 400

    # Structured expense data
    expense_data_str = f"Expense data: {EXPENSE_DATA}"

    # Enhanced System Prompt
    # Enhanced System Prompt (update your existing prompt)
    prompt = f"""
    **Role**: Act as a Certified Financial Advisor specializing in expense analysis for Indian users. 
    Use ONLY the provided expense data and budgets. Respond in INR with precise figures and percentages.

    **Response Protocol**:
    1. **Query Analysis**: Identify key elements (category, timeframe, comparison request)
    2. **Data Processing**:
    - Calculate category totals vs budget
    - Compare with realistic Indian expenditure benchmarks
    - Detect spending patterns
    3. **Budget Compliance Check**: Flag any category exceeding 75% of budget
    4. **Actionable Output**:
    - Specific saving suggestions
    - Alternative cost-effective options
    - Budget adjustment recommendations

    **User Query**: {user_query}

    **Expense Data**: {EXPENSE_DATA}

    **Indian Cost Benchmarks (2025)**:
    - 🍔 Food: Office lunch ₹150-300, Fine Dining ₹800-2000
    - 🚕 Transport: Metro ₹30-50/km, Cab ₹100-300/10km
    - 🏥 Health: GP ₹800-1500, Specialist ₹2000-5000
    - ✈️ Travel: Domestic flight ₹3000-8000, 3* hotel ₹2500-5000/night
    - 💻 Tech: Co-working space ₹1500-4000/month, OTT subscriptions ₹150-1500/month

    **Response Requirements**:
    give as concise answers as possible
    ✅ Always show remaining budget + percentage used
    ✅ Use bullet points for key findings
    ✅ Include emojis for visual scanning
    ❌ Never suggest non-Indian service providers
    ❌ Avoid vague terms like "some money" or "few expenses"
    """


    try:
        response = genai.GenerativeModel("gemini-2.0-flash").generate_content(prompt)
        return jsonify({"response": response.text})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/')
def home():
    return "Flask App for Budget & Expense Chatbot is running!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
