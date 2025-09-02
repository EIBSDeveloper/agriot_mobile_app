Screen 1: Add Vehicle Form
Screen Name & Purpose
AddVehicleScreen
This screen allows users to add a new vehicle to the inventory by inputting vehicle-related data, including vendor info, registration details, and optional insurance information.
UI Elements & Fields
Date Picker (static - defaults to current date): 20/08/2024
Dropdowns (dynamic):
Inventory Category (e.g., Agricultural Tractors)
Inventory Item
Vendor (with add new button)
Service Frequency
Text Input Fields (dynamic, user-filled):
Reg No
Owner Name
Date of Reg (Date Picker)
Reg Valid Till (Date Picker)
Engine No
Chassis No
Running KM (marked mandatory)
Fuel Capacity (Litres)
Average Mileage
Purchase Amount
Description
File Upload Dropdown (dynamic): For uploading documents
Checkbox: Insurance Details (expands section)
Button: Add (submits the form)
Flutter Layout Recommendations
Scaffold → with AppBar for title ("Vehicle")
SingleChildScrollView → To handle smaller screen sizes
Column or ListView → For stacking fields vertically
Use Padding and SizedBox between fields for spacing
Use Card or Container with BoxDecoration for grouping form
Input Types & Controls
TextFormField: For text fields (e.g., Reg No, Chassis No)
DropdownButtonFormField: For dropdowns
CheckboxListTile: For “Insurance Details” toggle
ElevatedButton or OutlinedButton: For “Add” button
Date Picker: Use showDatePicker for all date fields
File Picker Integration: For document uploads (e.g., file_picker)
User Interactions & Navigation
Tapping "Add" → triggers form validation → if successful, submit and navigate to listing or show confirmation
Tapping “+” beside Vendor opens modal/form to add new vendor
Checking Insurance Details → expands insurance section (toggle visibility)
Validation Rules (for forms)
Required Fields:
Inventory Category
Inventory Item
Vendor
Reg No
Running KM
Format Validation:
Dates must be valid and future-proof
Fuel Capacity and Mileage must be numeric
Error Messaging:
Inline validation error messages (e.g., “This field is required”)
Highlight borders in red for invalid inputs


🔹 Screen 2: Vehicle Details & Edit
Screen Name & Purpose
VehicleDetailScreen
Displays a detailed view of a saved vehicle's information and allows editing. Includes uploaded documents and insurance data.
UI Elements & Fields
Header Section:
Vehicle Name (e.g., Mahindra 265 DI 2WD)
Reg No (e.g., TN 59 CE 2865)
Form Fields (editable):
All fields from AddVehicleScreen, pre-filled
Date Fields: For registration, insurance, and renewal
Text Fields: Engine No, Chassis No, etc.
Dropdowns: Editable (Inventory Category, Item, Vendor)
Uploaded Documents Section:
Thumbnails with labels (e.g., RC, Insurance)
File upload buttons
Insurance Details section (expanded by default):
Company Name
Insurance No
Insurance Amount
Start, End, Renewal Dates
Button: Update (to save changes)
Flutter Layout Recommendations
Scaffold with AppBar including back button and title
Use ListView to allow scrolling
Group sections using Card or Container with BoxDecoration
Use Row + Expanded for side-by-side fields where space allows
Ensure consistent theming and text styling for data readability
Input Types & Controls
Same as AddVehicleScreen (TextFormField, DropdownButtonFormField, etc.)
Image/File Upload for documents: Include preview and replace options
Calendar Pickers for all dates
User Interactions & Navigation
Users can edit any field directly
Clicking on a document thumbnail → expand for full view or re-upload
"Update" button → triggers validation → updates vehicle info
Back arrow → returns to list or dashboard
All fields are editable except possibly the ID/auto-generated values
Validation Rules (for forms)
Same validations as AddVehicleScreen
Additional validation for:
Insurance Amount must be numeric
Start Date must be before End Date
Renewal Date must be on or after End Date


