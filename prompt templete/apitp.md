Convert raw API endpoint details into a well-structured markdown format with clear sections for: Endpoint Name HTTP Method URL Path (with parameters in <angle_brackets>)
Request Body (if applicable)
Response Body (formatted JSON)
Format Rules: Remove unnecessary quotation mark escapes (\" → ") Keep JSON responses properly indented Use code blocks for request/response bodies Replace IDs in URLs with <parameter> notation (e.g., /user/<id>/) Example Input: plaintext
Inventory Type List  GET  purchase_list/1  Farmer Id    "{""fuel"":{""total_quantity"":""20.0""}}"
Expected Output: markdown
### Inventory Type List  
**GET** `/purchase_list/<Farmer Id>/`  
**Response:**  
```json
{
  "fuel": {
    "total_quantity": "20.0"
  }
}
Additional Notes (if any): Include query parameters (e.g., ?inventory_type=6) Highlight required fields in requests Add descriptions for complex fields