Screen: Sales Details (06b)
Purpose:
Displays an overview of a completed sale with all recorded data including sales details, deductions, uploaded documents, and a description.
UI Elements & Fields
Static:
App bar with logo, app name (Agriot Farm), profile icon, notification icon
Product name with icon (e.g., Tomato )
Label fields: Date, Customer Name, Gross Sales, Deduction, Net Sales, Amount Paid
Labels: Uploaded Documents, Description
Dynamic:
Values for sales fields (e.g., ₹3,500, Aug 20, Rajesh Kumar)
Document preview thumbnails
Free text description
Flutter Layout Recommendations
Top-level: Scaffold
Body: SingleChildScrollView with Column
Section Containers: Use Card or Container with padding (16px) and vertical spacing (10px)
Text Styling: Use theme-based TextStyle for consistent typography
User Interactions & Navigation
Edit icon (pencil) triggers navigation to Edit Sales screen
Back arrow to return to previous screen
Validation Rules
Not applicable (view-only screen)
Optional Packages
cached_network_image (for document thumbnails if from remote source)

Screen: New Sales Entry (06c - New Sales)
Purpose:
Allows users to add a new sales entry including gross sales, deductions, documents, and payment details.
UI Elements & Fields
Static:
App bar, titles
Labels: Gross Sales, Deduction, Net Sales
Dynamic/Input:
Dropdowns: Product (Tomato), Customer Name
Text input: Gross Sales (number, amount per unit), Amount Paid
Add Deduction (+) button
Upload Documents dropdown
Description input
Submit button
Flutter Layout Recommendations
Top-level: Scaffold
Body: SingleChildScrollView with Form inside a Column
Field Wrapping: Use Padding and Wrap for responsive layout
Buttons: Use ElevatedButton or TextButton styled with theme
Input Types & Controls
DropdownButtonFormField for product and customer selection
TextFormField for numeric inputs with input formatters
GestureDetector or file picker widget for document uploads
Multiline TextFormField for description
User Interactions & Navigation
Add Deduction opens overlay modal (see Deduction screen)
Submit button validates and triggers backend call
Success shows confirmation or redirects to Sales Details
Validation Rules
Required: Date, Customer Name, Gross Sales values, Amount Paid
Numeric only for amounts
Document upload optional
Description optional
Optional Packages
flutter_form_builder for form handling
file_picker or image_picker for file uploads
flutter_bloc or provider for state handling

Screen: Edit Sales (06c - Sales Edit)
Purpose:
Enables users to modify an existing sales entry with editable fields and pre-filled data.
UI Elements & Fields
Same as New Sales Entry screen with:
Pre-filled fields (e.g., 35 Kilo, ₹100/unit, Amount Paid: ₹2,000)
Existing uploaded documents with delete/upload icons
Update button instead of Submit
Flutter Layout Recommendations
Same as New Sales Entry, with additional:
ListView.builder or Wrap to list uploaded documents with edit/delete options
Input Types & Controls
As per New Sales Entry
Drag-and-drop or tap-to-replace for documents
User Interactions & Navigation
Edit any field and tap Update
Modify or delete deductions
Remove or re-upload documents
Navigation similar to New Sales flow
Validation Rules
Same as New Sales, but documents already validated unless changed
Optional Packages
Same as New Sales

Screen: Add Deduction (06d)
Purpose:
Allows users to add a deduction to the sales entry by entering a reason and percentage or amount.
UI Elements & Fields
Static:
Title: Add Deduction
Dynamic/Input:
Text input: Reason for Deduction
Numeric input: Percentage or flat amount
Toggle or dropdown for % or fixed value
Auto-calculated Deduction Amount
Add Deduction button
Flutter Layout Recommendations
Top-level: Use showDialog() or modal bottom sheet with AlertDialog or BottomSheet
Body: Column inside Padding
Use Row for input + selector (% or ₹)
Inut Types & Controls
TextFormField for reason and amount
DropdownButton or ToggleButtons for amount type (% or fixed)
Real-time calculation of deduction (bind to gross amount)

User Interactions & Navigation
Tapping Add Deduction appends entry to the deductions list in parent screen
Updates total deduction and recalculates net sales
Validation Rules
Reason is required
Deduction must be > 0
Percentage capped at 100%


Api detailes

Inventory Type List
GET /purchase_list/<Farmer Id>/
Response:{"fuel":{"total_quantity":"20.0"}}

Sales List
POST /get_sales_by_crop/<Farmer Id>/
Request Body:{"crop_id":11,"type":"month"}
Response:{"crop_id":11,"crop_name":"Coffee","crop_land_id":1,"crop_land":"Dharshan'sFarm","crop_img":"http://192.168.3.24:1710/SuperAdmin/media/media/crop/coffee_img_AL7lPRH.png","total_sales_amount":10000.0,"sales":[{"sales_id":1,"dates_of_sales":"2025-03-21","sales_quantity":10,"sales_unit":{"id":1,"name":"Pieces"},"quantity_amount":"1000","total_amount":"10000.0","sales_amount":10000.0,"deduction_amount":"10","total_sales_amount":9990.0,"description":"","status":0,"farmer":{"id":1,"name":"Dharshan"},"my_customer":{"id":1,"name":"JohnDoe","village":"Pavoorchatram"},"created_at":"2025-03-21T13:03:18.818585Z","updated_at":"2025-03-21T13:03:18.818597Z"}]}

Sales Details
POST /get_sales_details/<Farmer Id>/
Request Body:{"sales_id":1}
Response:{"sales_id":1,"farmer":{"id":1,"name":"Dharshan"},"dates_of_sales":"2025-03-21","my_crop":{"id":11,"name":"Coffee","img":"http://192.168.3.:1710/tt.png"},"my_customer":{"id":1,"name":"JohnDoe"},"sales_quantity":10,"sales_unit":{"id":1,"name":"Pieces"},"quantity_amount":"1000","total_amount":"10000.0","sales_amount":10000.0,"deduction_amount":"8","total_sales_amount":9992.0,"amount_paid":10.0,"description":null,"status":0,"created_at":"2025-03-21T13:03:18.818585Z","updated_at":"2025-03-22T05:07:46.210131Z","deductions":[{"deduction_id":1,"reason":{"id":1,"name":"TransportCosts"},"charges":"8","rupee":{"id":1,"name":"Rupee"}}],"documents":[{"category_id":"2","documents":[{"id":1,"document_category":{"id":2,"name":"Salesssss"},"file_upload":"http://192.168/mat_img.png"}]},{"category_id":"3","documents":[{"id":4,"document_category":{"id":3,"name":"Bill"},"file_upload":"http://192.16/ent/tea_img_lj7eAOw.png"}]}]}

Sales Add
POST /add_sales_with_deductions/<Farmer Id>/
Request Body:{"dates_of_sales":"2025-03-22","my_crop":1,"my_customer":1,"sales_quantity":100,"sales_unit":1,"quantity_amount":"20","sales_amount":"","deduction_amount":"0","description":"New...","amount_paid":"100","deductions":[{"new_reason":"bil","charges":"10","rupee":"2"},{"reason":1,"charges":"40","rupee":"1"},{"reason":1,"charges":"10","rupee":"1"}],"file_data":[{"file_type":2,"documents":["data:image/png;base64,iVBORw0kw0f5ErkJggg==","data:application/pdf;base64,JVBERJUVPRg=="]}]}
Response:{"success":true,"message":"Sales,deductions,anddocumentsaddedsuccessfully!",}

Sales Edit
POST /update_sales_with_deductions/<Farmer Id>/<Sales Id>/
Request Body:{"id":"2","dates_of_sales":"2025-01-11","my_crop":1,"my_customer":1,"sales_quantity":400,"sales_unit":1,"quantity_amount":"20","sales_amount":"","deduction_amount":"0","description":"New...","amount_paid":"100","deductions":[{"id":192,"reason":1,"charges":"10","rupee":"1"},{"reason":"newRescopn","charges":"10","rupee":"1"}],"file_data":[{"document_id":2,"file_type":2,"documents":["data:image/png;base64,iVBORwRg=="]},{"file_type":3,"documents":["data:image/png;base64,iVBORw0Rg=="]}]}
Response:{"success":true,"message":"Sales,deductions,anddocumentsupdatedsuccessfully!",}

Sales Delete
POST /deactivate_my_sale/<Farmer Id>/
Request Body:{"id":1}
Response:{"message":"Saledeactivatedsuccessfully"}

Reason Dropdown
GET /reasons/
Response:[{"id":1,"name":"TransportCosts"}]

Rupee Dropdown
GET /rupees/
Response:[{"id":1,"name":"Rupee"},{"id":2,"name":"%"}]

Customer List
GET /get_customer_list/<Farmer Id>/
Response:[{"id":1,"customer_name":"JohnDoe","shop_name":"DoeMart"},{"id":2,"customer_name":"Mahesh","shop_name":"DoeMart"}]



