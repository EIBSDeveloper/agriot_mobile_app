Vehicle Fuel/KM Consumption – Implementation Guide
Screen 11g: Vehicle List
UI Elements
Header: Back arrow, logo, profile, notification
Title: Vehicles
List of vehicles with:
Name (e.g., Mahindra 265 D..)
Registration number (e.g., TN 59 C 2725)
Flutter Layout
AppBar
ListView or Column with ListTile or Card per vehicle
Style name and reg. no distinctly
User Interaction
Tap on a vehicle navigates to consumption log screen

Screen 11i: Vehicle Consumption – List
UI Elements
Vehicle name + reg. no at top
Warning: “Service due soon” (red text, optional icon)
Consumption history entries:
Date
Crop Name
KM Used (e.g., 4 KM)
Flutter Layout
Column + ListView.builder
Use Card or styled ListTile for each entry
Floating action button or bottom icon for Add
User Interaction
Tap entry → detail/edit screen
Add icon → opens new form

Screen 11h: Add Vehicle Consumption
UI Form Fields
Date Picker – default: today
Crop Dropdown – required
Vehicle Category Dropdown – e.g., Agricultural Tractors
Vehicle Dropdown – filtered by category
Start KM – numeric input
End KM – numeric input
Total KM Usage – auto-calculated (end - start)
Upload Documents – optional (images/files)
Description – optional multiline
Input Types
Date: showDatePicker
Dropdowns: DropdownButtonFormField
KM fields: TextFormField (keyboardType: TextInputType.number)
Upload: Use image/file picker with preview
Validation Rules
Crop, Vehicle, Start & End KM: required
End KM > Start KM
KM fields: only positive integers
Flutter Layout
Use Form with validation
Scrollable Column or SingleChildScrollView
ElevatedButton: Save

Screen 11j: View/Edit Vehicle Consumption
UI Elements
Same structure as form but:
Fields are read-only in view mode
Editable when clicking edit (pencil icon)
Info:
Crop name
Inventory type & category
Start & End KM
Total KM
Uploaded files
Description

Flutter Layout
Read-only: Text or disabled fields
Edit icon enables fields → opens same form
Uploaded images: horizontal scrollable preview

User Interaction
Tap edit → fields become editable
Update button replaces Save
Suggested Flutter Packages
flutter_form_builder – for complex form handling
file_picker or image_picker – upload support
intl – date formatting
provider / riverpod – state management
fluttertoast or snackbar – validation/error messages

Navigation Flow Summary
Vehicle List (11g) → tap vehicle →
Consumption List (11i) →
Tap entry → view/edit (11j)
Add button → new form (11h)

Api details


Machinery - List
GET - machinery_list/1?inventory_type=2
Request Params:
farmer_id: 1
inventory_type: 2
Response:{"machinery":[{"id":1,"vendor":{"id":1,"name":"UpdatedVendorName"},"inventory_type":{"id":2,"name":"Machinery"},"inventory_category":{"id":2,"name":"NNNMachinery"},"inventory_items":{"id":2,"name":"TNAURegionalResearchStation"},"machinery_type":0,"fuel_capacity":"20.00","purchase_amount":"2000.00","language":{"default":"en"}}]}


 Machinery - Add
POST - add_machinery/1
Payload:{"date_of_consumption":"2025-03-25","vendor":"1","inventory_type":"2","inventory_category":"2","inventory_items":"2","machinery_type":"1","fuel_capacity":"20","warranty_start_date":"2025-03-25","warranty_end_date":"2025-03-25","purchase_amount":"300","description":"AddMachinery","documents":[{"file_type":4,"documents":["data:image/png;base64,...","data:image/jpeg;base64,..."]},{"file_type":2,"documents":["data:image/png;base64,...","data:image/jpeg;base64,..."]}]}

Response:{"success":true,"message":"Machineryaddedsuccessfully!","data":{"id":9,"date_of_consumption":"2025-03-25","machinery_type":1,"fuel_capacity":"20.00","purchase_amount":"300.00","warranty_start_date":"2025-03-25","warranty_end_date":"2025-03-25","description":"AddMachinery","status":0,"available_quans":"180.00","farmer":1,"vendor":1,"inventory_type":2,"inventory_category":2,"inventory_items":2},"documents":[{"category_id":4,"documents":[{"document_id":13,"upload_document":"http://.../machinery_1_4_0.png","file_type":"Expense"},{"document_id":14,"upload_document":"http://.../machinery_1_4_1.jpeg","file_type":"Expense"}]},{"category_id":2,"documents":[{"document_id":15,"upload_document":"http://.../machinery_1_2_0.png","file_type":"Salesssss"},{"document_id":16,"upload_document":"http://.../machinery_1_2_1.jpeg","file_type":"Salesssss"}]}]}

Machinery - View
POST - get_my_machinery/1/

Payload:{  "my_machinery": 9}
Response:{"machinery_data":{"machinery_id":9,"farmer":{"id":1,"name":"Dharshan"},"vendor":{"id":1,"name":"UpdatedVendorName"},"inventory_item":{"id":2,"name":"TNAURegionalResearchStation"},"inventory_type":{"id":2,"name":"Machinery"},"inventory_category":{"id":2,"name":"NNNMachinery"},"machinery_type":1,"fuel_capacity":20.0,"purchase_amount":300.0,"warranty_start_date":"2025-03-25","warranty_end_date":"2025-03-25","description":"AddMachinery","status":0,"available_quantity":"180.00","documents":[{"id":13,"document_name":"http://.../machinery_1_4_0_4xDsAOx.png","file_type":"Expense"},{"id":14,"document_name":"http://.../machinery_1_4_1_HSQ9Egp.jpeg","file_type":"Expense"},{"id":15,"document_name":"http://.../machinery_1_2_0_j69aEjA.png","file_type":"Salesssss"},{"id":16,"document_name":"http://.../machinery_1_2_1_QDAuPzO.jpeg","file_type":"Salesssss"}]}}


 Machinery - Edit
PUT - update_machinery/1/

Payload:{"machinery_id":9,"date_of_consumption":"2025-03-25","vendor":"1","inventory_type":"2","inventory_category":"2","inventory_items":"2","machinery_type":"0","fuel_capacity":"20","warranty_start_date":"2025-03-25","warranty_end_date":"2025-03-25","purchase_amount":"300","description":"AddMachinery","documents":[{"file_type":4,"documents":["data:image/png;base64,...","data:image/jpeg;base64,..."]},{"file_type":2,"documents":["data:image/png;base64,...","data:image/jpeg;base64,..."]}]}


Response:{"success":true,"message":"Machineryupdatedsuccessfully!","data":{"id":9,"farmer":1,"vendor":1,"inventory_item":"TNAURegionalResearchStation","inventory_type":"Machinery","inventory_category":"NNNMachinery","machinery_type":"0","fuel_capacity":"20","purchase_amount":"300","warranty_start_date":"2025-03-25","warranty_end_date":"2025-03-25","description":"AddMachinery","status":2,"available_quantity":"180.00","documents":[{"id":21,"document":"http://.../machinery_1_4_0_rVCDRJx.png","file_type":"Expense"},{"id":22,"document":"http://.../machinery_1_4_1_KxzRwFj.jpeg","file_type":"Expense"},{"id":23,"document":"http://.../machinery_1_2_0_mo2HYk3.png","file_type":"Salesssss"},{"id":24,"document":"http://.../machinery_1_2_1_WKShu88.jpeg","file_type":"Salesssss"}]}}

Machinery - Delete
POST - deactivate_machinery/1/

Payload:{  "my_machinery_id": 9}
Response:{"message":"MyMachinerydeactivatedsuccessfully","language":{"default":"en"}}

