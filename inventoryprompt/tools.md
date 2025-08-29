Tools Consumption UI – Flutter Developer Guide
1. Screen: Tools List
Fields/Elements:
Header with back button, logo, notification bell, profile icon
Title: "Tools"
Search input field with clear & search icon
List of tools with name and quantity/unit (e.g., "Plough" - 6)
Layout:
AppBar with leading back button
Column with TextField for search and ListView.builder for the tools list
Each tool as a ListTile or Card showing name and quantity aligned right
Interactions:
Typing in search filters the tools list dynamically
Tap on a tool navigates to Tools Consumption List

2. Screen: Tools Consumption List
Fields/Elements:
Header with back button and tool name (e.g., "Plough")
List of consumption records showing date, crop, usage hours (e.g., "2.5 Hrs")
Add button (floating or icon) to add new consumption record
Layout:
ListView for records with each item as a ListTile showing date, crop, usage hours
Interactions:
Tap consumption record → opens Consumption Detail view
Tap add button → opens Consumption Form modal

3. Screen: Consumption Form (Add/Edit)
Fields:
Date (required) → Date picker widget
Crop (required) → Dropdown selection
Inventory Type (fixed "Tools") → Display only
Inventory Category (fixed "Soil Preparation") → Display only
Tool name (e.g., "Plough") → Display only or dropdown if editing multiple
Usage Hours (required) → Numeric input
Quantity (required) → Numeric input
Upload Documents → File/Image picker with preview
Description → Multiline text field
Layout:
Scrollable Form using SingleChildScrollView
Form fields as TextFormField and DropdownButtonFormField
File upload button with thumbnails of selected files
Save/Update button at the bottom
Validation:
Date, Crop, Usage Hours, and Quantity are mandatory
Usage Hours and Quantity must be positive numbers
Interactions:
Date picker pops calendar widget
Dropdown opens list of crop options
Upload documents opens native file/image picker
Save validates and submits form data

4. Screen: Consumption Detail View
Fields:
Read-only display of Date, Crop, Inventory Type, Inventory Category, Usage Hours, Quantity
Uploaded Documents shown as thumbnails with preview icon
Description text
Edit and Delete icons on header
Layout:
Column layout for clear visibility
Document thumbnails scrollable horizontally if many
Interactions:
Edit icon opens Consumption Form pre-filled for editing
Delete icon triggers confirmation modal for deletion
Recommended Flutter Widgets & Packages:
AppBar, ListView, ListTile for lists
TextField with onChanged for search filter
Form, TextFormField, DropdownButtonFormField for forms
showDatePicker for date selection
image_picker or file_picker for document uploads
provider or riverpod for state management
intl for date formatting and validation

Navigation Flow Summary:
Tools List → Tools Consumption List → Consumption Detail View (Edit/Delete)
Consumption Form used for both Add and Edit modes as modal or full screen


Api details 
Tools Add
POST /add_tools/{farmer_id}
Request Body:{"date_of_consumption":"2025-03-25","vendor":"1","inventory_type":"3","inventory_category":"3","inventory_items":"3","quantity":"30","quantity_unit":1,"purchase_amount":"300","description":"AddTools","reusable":true,"documents":[{"file_type":4,"documents":["data:image/png;base64,...","data:image/jpeg;base64,..."]},{"file_type":2,"documents":["data:image/png;base64,...","data:image/jpeg;base64,..."]}]}

Response:{"success":true,"message":"Tooladdedsuccessfully!"}


37. Tools View
POST /get_my_tools/{farmer_id}/
Request Body:{"my_tools": 1}
Response: 

{
  "tools_data": {
    "farmer": { "id": 1, "name": "Dharshan" },
    "tools_id": 1,
    "vendor": { "id": 1, "name": "Updated Vendor Name" },
    "inventory_item": { "id": 3, "name": "Acre" },
    "inventory_type": { "id": 3, "name": "Tools" },
    "inventory_category": { "id": 3, "name": "MTools" },
    "quantity": 10.0,
    "purchase_amount": 200.0,
    "description": "",
    "status": 0,
    "available_quantity": 10.0,
    "documents": [
      {
        "id": 1,
        "document_name": "http://192.168.3.24:1710/SuperAdmin/media/myTools_documents/coffee_img_bXlCwX1.png",
        "file_type": "Expense"
      }
    ],
    "language": { "default": "en" }
  }
}
38. Tools Edit
PUT /update_tools/{farmer_id}/{tools_id}
Request Body (optional fields, update any):


{
  "date_of_consumption": "2025-03-26",
  "vendor": 1,
  "inventory_type": 3,
  "inventory_items": 3,
  "inventory_category": 3,
  "quantity": 50,
  "purchase_amount": 1000.00,
  "description": "A tool for farming",
  "documents": [
    {
      "file_type": 4,
      "documents": [
        "data:image/png;base64,...",
        "data:image/jpeg;base64,..."
      ]
    },
    {
      "file_type": 2,
      "documents": [
        "data:image/png;base64,...",
        "data:image/jpeg;base64,..."
      ]
    }
  ]
}
Response:


{
  "success": true,
  "message": "Tool updated successfully!",
  "data": {
    "id": 2,
    "tool_name": "Acre",
    "tool_type": { "id": 3, "name": "Tools" },
    "quantity": 50,
    "purchase_amount": 1000.0,
    "description": "A tool for farming",
    "reusable": true,
    "status": 0,
    "available_quantity": 40.0,
    "documents": [
      {
        "id": 10,
        "document": "http://192.168.3.24:1710/SuperAdminmyTools_documents/tool_2_4_0_npgk9jl.png",
        "file_type": "Expense"
      },
      ...
    ]
  },
  "language": { "default": "en" }
}
39. Tools Delete
POST /deactivate_tools/{farmer_id}/
Request Body:


{
  "my_tools_id": 1
}
Response:


{
  "message": "MyTools deactivated successfully",
  "language": { "default": "en" }
}
