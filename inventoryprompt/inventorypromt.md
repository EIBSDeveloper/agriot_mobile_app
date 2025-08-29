Screen 11c: Fuel Inventory List
UI Elements
Header Bar:
App logo and name ("Agriot")
Notification icon
User profile icon
Screen Title: Fuel
Fuel List:
Two rows:
Petrol: 21 Ltr
Diesel: 22 Ltr
Flutter Widgets Suggestion
AppBar (with logo, icons)
ListView or Column with ListTile or custom Card for each fuel type
Text styling to highlight type (green text)
User Interaction
Tapping on a fuel type navigates to its consumption and purchase detail screen

Screen 11f: Fuel Consumption & Purchase List
UI Elements
Header: Fuel Type + Available Quantity (e.g., Petrol | 21 Ltr)
Tabs/Sections:
Consumption (selected by default)
Purchase
Fuel Consumption Log:
Date-wise entries (e.g., Dec 26, Tomato, 5 Ltr)
Category: Crop name + fuel type
Flutter Widgets Suggestion
AppBar or SliverAppBar (for scrolling effect)
TabBar and TabBarView (Consumption, Purchase)
ListView.builder for log entries
FloatingActionButton or IconButton for Add
User Interaction
Tapping a log entry opens detailed view/edit screen
Add button opens new entry form

Screen 11e: Add/Edit Fuel Consumption
UI Elements
Form Fields:
Date Picker (Date)
Dropdown: Crop (required)
Dropdown: Fuel (readonly or auto-selected)
Dropdown: Fuel Category (e.g., Petrol, Diesel)
TextField: Quantity (Litre) (number input)
File Upload: Upload Documents (images, optional)
TextField: Description (multi-line)
Action Button: Save (or Update on edit)
Flutter Widgets Suggestion
Form with TextFormField, DropdownButtonFormField, DatePicker, FilePicker
ElevatedButton for Save/Update
Image preview for uploaded documents (use a scrollable Row)
Input Types
Date: Show date picker (Flutter's showDatePicker)
Dropdowns: Use DropdownButtonFormField for Crop and Fuel Category
Quantity: Numeric only (use keyboardType: TextInputType.number)
Description: Multiline text input
Upload: Image picker (use Flutter file/image picker)
Form Validation Rules
Crop: Required
Quantity: Must be numeric and > 0
Fuel Category: Required
Date: Must not be empty or future-dated
Description: Optional but recommended
Screen: Fuel Consumption Detail View
UI Elements
Read-only View
Date
Inventory Type: Fuel
Inventory Category: e.g., Petrol
Quantity: e.g., 5 Litre
Uploaded Documents (Image preview)
Description
Edit/Delete Icons (top right)
Flutter Widgets Suggestion
Card or Column layout
Image preview widgets
IconButton for edit and delete
Navigator.push to open edit form
User Interaction

User can:
View fuel consumption record
Tap edit icon to modify details
Tap delete (confirm dialog before action)
Recommended Flutter Packages (Optional)
image_picker: For document/image uploads
file_picker: For multiple file formats
flutter_form_builder: Advanced form control
intl: For date formatting
dropdown_search: Better dropdowns with search

Navigation Flow Summary
Fuel List (11c) → tap fuel type →
Fuel Consumption/Purchase Logs (11f) →
Add: Opens Add Form (11e)
Tap entry: Opens View/Detail
Edit/View: Opens Edit Form



Api details 

Inventory Type(Fuel) - List
fuel_list/1?inventory_type=6
{"fuels":[{"id":1,"date_of_consumption":"2025-03-21","vendor":2,"inventory_type":6,"inventory_category":6,"inventory_items":6,"quantity":"10.00","purchase_amount":"200.00"},{"id":2,"date_of_consumption":"2025-03-25","vendor":2,"inventory_type":6,"inventory_category":6,"inventory_items":6,"quantity":"10.00","purchase_amount":"1000.00"}]}

Fuel Consumption (Add)
POST - add_fuel/1
Request:{"date_of_consumption":"2025-03-25","vendor":"1","inventory_type":"6","inventory_category":"6","inventory_items":"6","quantity":"20","purchase_amount":"300","description":"AddFuel","documents":[{"file_type":4,"documents":["data:image/png;base64,/9j/2NCWiCNCR...","data:image/jpeg;base64,/9j/2wBgBlKD..."]},{"file_type":2,"documents":["data:image/png;base64,/9j/2wreJSCC...","data:image/jpeg;base64,/Riib0AShRj..."]}]}
Response:{"success":true,"message":"Fueladdedsuccessfully!","data":{"id":9,"date_of_consumption":"2025-03-25","quantity":"20.00","purchase_amount":"300.00","description":"AddFuel","status":0,"available_quans":"160.00","farmer":1,"vendor":1,"inventory_type":6,"inventory_category":6,"inventory_items":6},"documents":[{"category_id":4,"documents":[{"document_id":1,"upload_document":"http://192.168.3.24:1710/SuperAdminfuel_1_4_0.png"},{"document_id":2,"upload_document":"http://192.168.3.24:1710/SuperAdminfuel_1_4_1.jpeg"}]},{"category_id":2,"documents":[{"document_id":3,"upload_document":"http://192.168.3.24:1710/SuperAdminfuel_1_2_0.png"},{"document_id":4,"upload_document":"http://192.168.3.24:1710/SuperAdminfuel_1_2_1.jpeg"}]}]}


Fuel Consumption (View)
POST - get_myfuel/1/
Request:{"my_fuel": 9}
Response:{"fuel_data":{"fuel_id":9,"date":"2025-03-25","quantity":20.0,"purchase_amount":300.0,"description":"AddFuel","farmer":{"id":1,"name":"Dharshan"},"vendor":{"id":1,"name":"UpdatedVendorName"},"inventory_type":{"id":6,"name":"Fuel"},"inventory_category":{"id":6,"name":"MFuel"},"inventory_item":{"id":6,"name":"MMFuel"},"documents":[{"category_id":4,"documents":[{"id":1,"upload_document":"http://192.168.3.24:1710/SuperAdmin/media/myFuel_documents/fuel_1_4_0.png"},{"id":2,"upload_document":"http://192.168.3.24:1710/SuperAdmin/media/myFuel_documents/fuel_1_4_1.jpeg"}]},{"category_id":2,"documents":[{"id":3,"upload_document":"http://192.168.3.24:1710/SuperAdmin/media/myFuel_documents/fuel_1_2_0.png"},{"id":4,"upload_document":"http://192.168.3.24:1710/SuperAdmin/media/myFuel_documents/fuel_1_2_1.jpeg"}]}]}}


Fuel Consumption (Edit)
PUT - update_fuel/1/
Request:{"fuel_id":10,"date_of_consumption":"2025-02-16","vendor":1,"inventory_type":6,"inventory_category":6,"inventory_items":6,"quantity":100,"purchase_amount":2500,"description":"Updatedfuelrecord.","documents":[{"id":9,"file_type":3,"documents":["data:image/png;base64,iVBORw0KGgoAVq8yuH5vSR..."]}]}

Response:{"success":true,"message":"Fuelupdatedsuccessfully!","data":{"id":10,"farmer":1,"vendor":{"id":1,"name":"UpdatedVendorName"},"inventory_type":{"id":6,"name":"Fuel"},"inventory_category":{"id":6,"name":"MFuel"},"inventory_item":{"id":6,"name":"MMFuel"},"quantity":100,"purchase_amount":2500,"description":"Updatedfuelrecord.","available_quantity":260.0,"documents":[{"id":11,"document":"http://192.168.3.24:1710/SuperAdminmyFuel_documents/fuel_1_3_0_CnZI2Ho.png","file_type":"Bill"}]}}

Fuel Consumption (Delete)
POST - deactivate_fuel/1/
Request:{"my_fuel_id": 1}
Response:{"message": "MyFuel Deleted successfully"}













