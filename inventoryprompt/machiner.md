Machinery Usage Tracking – Flutter Implementation Guide
Screen 11k: Machinery List
UI Elements
Title: Machinery

List of machinery items with:

Name (e.g., Threshers)

Category (e.g., Fuel, Manual)

Flutter Layout
AppBar with back icon, app logo, profile icon, notification icon

ListView.builder or Column with ListTile or custom Card

Style category text subtly (e.g., grey)

User Interaction
Tap on a machinery item → navigates to its usage log screen

Screen 11m: Machinery Consumption Log
UI Elements
Title: Selected machinery (e.g., Threshers)

List of usage entries:

Date

Crop

Usage Hours (e.g., 2.5 Hrs)

Flutter Layout
Column + ListView

Each item: Use Card or styled Container for log

FAB or bottom icon for adding usage entry

User Interaction
Tap on an entry → opens detailed usage view/edit

Tap add icon → opens new usage form

Screen 11l: Add Machinery Consumption
Form Fields
Date Picker – default to today

Crop Dropdown – required

Category: Fixed to Machinery

Sub-category (Dropdown) – e.g., Threshers

Usage Hours – required numeric input (decimal allowed)

Upload Documents – optional (images/files)

Description – optional multiline

Input Types
Date: showDatePicker

Dropdowns: DropdownButtonFormField

Hours: TextFormField (keyboardType: decimal)

Upload: Image/file picker with preview

Description: Multiline

Validation Rules
Crop: Required

Machinery Sub-category: Required

Usage Hours: Required, positive decimal (e.g., 1.5)

Date: Required, not in the future

Flutter Layout
Form, inside SingleChildScrollView

Use padding and spacing between fields

ElevatedButton: Save

Screen 11n: Machinery Usage Detail View
UI Elements
Read-only view with:

Date

Crop

Inventory Type: Machinery

Inventory Category: Fuel

Usage Hours

Uploaded Documents (Image preview)

Description

Edit and delete icons at the top
Flutter Layout
Column with Card or structured Container
Image preview using ListView or Row with thumbnails
Edit icon opens same form in edit mode

Screen 11l (Edit Mode)
Identical to Add Form, but:
Populated with existing data
Button label changes to Update

Suggested Flutter Packages
image_picker / file_picker – Upload support
intl – Date formatting
flutter_form_builder – For cleaner form handling
provider or riverpod – State management

 Navigation Flow Summary
Machinery List (11k) → Tap item →
Usage Log (11m) →
Tap entry → View/edit screen (11n)
Tap add → Add usage (11l)



Api details 
1. Vehicle Add
Method: POST

Endpoint: add_vehicle/<farmer_id>/

Payload Example:


{
  "farmer_id": 1,
  "date_of_consumption": "2025-03-26",
  "vendor": 2,
  "inventory_type": 1,
  "inventory_category": 1,
  "inventory_items": 1,
  "register_number": "ABC1234",
  "owner_name": "John Doe",
  "date_of_registration": "2025-01-15",
  "registration_valid_till": "2026-01-15",
  "engine_number": "ENG123456",
  "chasis_number": "CHS123456789",
  "running_kilometer": 15000.5,
  "service_frequency": 1000,
  "service_frequency_unit": 0,
  "fuel_capacity": 50.75,
  "average_mileage": 15.25,
  "purchase_amount": 200000.0,
  "insurance": true,
  "company_name": "Insurance Co.",
  "insurance_no": "INS123456",
  "insurance_amount": 5000.0,
  "insurance_start_date": "2025-02-01",
  "insurance_end_date": "2026-02-01",
  "insurance_renewal_date": "2025-12-01",
  "description": "This is a test vehicle for farming operations.",
  "documents": [
    {
      "file_type": 4,
      "documents": ["<base64_image1>", "<base64_image2>"]
    },
    {
      "file_type": 2,
      "documents": ["<base64_image3>", "<base64_image4>"]
    }
  ]
}
Success Response: Vehicle added with ID and list of uploaded document URLs grouped by category.

🔹 2. Vehicle View
Method: POST

Endpoint: get_myvehicle/<farmer_id>/

Payload: (No payload required other than farmer ID)

Response:


{
  "vehicle_data": {
    "farmer": { "id": 1, "name": "Dharshan" },
    "vehicle_id": 1,
    "register_number": "10165484",
    "owner_name": "New",
    "running_kilometer": 100.0,
    "purchase_amount": 1000.0,
    "insurance": false,
    ...
    "vendor": { "id": 1, "name": "Updated Vendor Name" },
    "inventory_type": { "id": 1, "name": "Vehicle" },
    "inventory_category": { "id": 1, "name": "new Vehicle" },
    "inventory_item": { "id": 1, "name": "Department of Agriculture" },
    "documents": []
  }
}
🔹 3. Vehicle Edit
Method: PUT

Endpoint: update_vehicle/<farmer_id>/

Payload:


{
  "id": 4,
  "farmer": 1,
  "vendor": 5,
  ...
  "register_number": "ABC123",
  "owner_name": "John Doe",
  ...
  "documents": [
    {
      "id": 17,
      "document": "http://<url>/vehicle_1_4_0.png",
      "file_type": "Expense"
    },
    ...
  ]
}
Success Response: "message": "Vehicle updated successfully!"

🔹 4. Vehicle Delete
Method: POST

Endpoint: deactivate_vehicle/<farmer_id>/

Payload:


{
  "my_vehicle_id": 1
}
Response:


{
  "message": "MyVehicle deactivated successfully"
}

Inventory Type (Vehicle) - List
Method: GET
Endpoint: vehicle_list/<farmer_id>?inventory_type=<inventory_type_id>
Query Parameters:
inventory_type — Integer (e.g., 1 for Vehicle)
Purpose:
Get all vehicles for a given farmer filtered by inventory type.

Example Request

GET vehicle_list/1?inventory_type=1
Example Response

{
  "vehicles": [
    {
      "id": 1,
      "fuel_capacity": "None",
      "date_of_consumption": "2025-03-21",
      "vendor": {
        "id": 1,
        "name": "Updated Vendor Name"
      },
      "inventory_type": {
        "id": 1,
        "name": "Vehicle"
      },
      "inventory_category": {
        "id": 1,
        "name": "new Vehicle"
      },
      "inventory_items": {
        "id": 1,
        "name": "Department of Agriculture"
      },
      "language": {
        "default": "en"
      }
    }
  ]
}