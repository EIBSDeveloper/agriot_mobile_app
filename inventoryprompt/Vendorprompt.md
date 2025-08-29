Vendor/Customer Module Specification
08a – Vendor/Customer List
Purpose: Display all vendors and customers, filterable by type.
UI Elements:
Header:
Title/Filter Row: Segmented buttons → Both, Customer, Vendor (active state highlighted)
List Items:
Name (bold)
Business type (small subtitle, e.g., "Uooranvanchal", "Machinery")
Mobile number (right-aligned)
Floating Action Button: Circular + for adding new vendor/customer
Interactions:
Tap filter → list updates based on selection
Tap contact row → view/edit contact details
Tap FAB → navigate to Add Customer (08b) or Add Vendor (08c) based on user choice

08b – Add Customer
Purpose: Capture complete customer details.
UI Fields:
Customer Name (required, text input)
Mobile No (required, numeric, 10–15 digits)
Email ID (optional, email format)
Shop Name (optional)
Country (required, dropdown)
State (required, dropdown)
City (required, dropdown)
Taluk (required, dropdown)
Village (required, dropdown)
Door No / Street Name (optional, text)
Pincode (*required, numeric, 6 digits in India)
Market Name (optional, dropdown)
Opening Balance (numeric with +/- buttons to adjust amount)
Customer Photo (optional, file upload: image)
Description (optional, multi-line text)
Validation Rules:
Required fields must be filled
Email must be valid if provided
Pincode must be exactly 6 digits (India)
Mobile number length and format validation

08c – Add Vendor
Purpose: Capture vendor details with inventory type selection.
UI Fields:
Inventory Type (required, dropdown)
Vendor Name (required, text input)
Mobile No (required, numeric)
Email ID (optional, email format)
Shop Name (optional)
Country (required, dropdown)
State (required, dropdown)
City (required, dropdown)
Taluk (required, dropdown)
Village (required, dropdown)
Door No / Street Name (optional)
Pincode (required, numeric)
Opening Balance (numeric with +/- buttons)
Vendor Photo (optional, file upload: image)
Description (optional)
Validation: Same rules as customer form, plus ensure Inventory Type is selected.

08d – Add Customer/Vendor (Inventory-Specific)
Purpose: Add a customer or vendor linked to specific inventory items.
UI Fields:
Inventory tags at top (e.g., Fertilizers, Seeds) — selectable chips
Customer/Vendor Name (required)
Mobile No (required, numeric)
Email ID (optional)
Shop Name (optional)
Country (required)
State (required)
City (required)
Taluk (required)
Village (required)
Door No / Street Name (optional)
Pincode (required, numeric)
Opening Balance (+/- buttons)
Photo (optional)
Description (optional)
Interaction:
Selecting an inventory tag changes which inventory this contact is linked to.

Navigation Flow
08a Vendor/Customer list → FAB → Choose Add Customer (08b), Add Vendor (08c), or Add Customer/Vendor (08d)
Fill form → Submit → Return to list (08a) with updated entry
Filters in 08a let user quickly switch between Both / Customer / Vendor

Developer Implementation Notes
All dropdowns should be searchable if list length > 10
Dependent dropdowns (e.g., Country → State → City → Taluk → Village) must dynamically update options
Opening Balance can be a number input with ± step buttons
Upload Photo should support camera and gallery
Required fields marked with red asterisk
Disable Submit until all required validations pass
Show confirmation/tost on successful save

Enhancements
Add “View Details” screen for each contact with edit/delete
Allow quick call in list view


Api Details
Both Customer & Vendor List
 Get = /both_customers_and_vendors/<former id>
 Response =[{"id":5,"farmer_id":1,"farmer":"Dharshan","customer_name":"Mohan","type":"customer","shop_name":"DoeMart","mobile_no":"1876543222","email":"toh@exdsfample.com","door_no":"123","country_id":1,"country":"India","state_id":1,"state":"TamilNadu","city_id":1,"city":"Tenkasi","taluk_id":1,"taluk":"Sengottai","village_id":1,"village":"Pavoorchatram","gst_no":"29ABCDE1234F2Z5","tax_no":"TX123456789","post_code":560001,"is_credit":true,"opening_balance":5000,"description":null,"is_customer_is_vendor":true,"market_id":1,"market":"AMUTHUMARI","language":{"default":"en"}}]

Customer List
 Get = /get_customer_list/<former id>
 Response =[{"id":1,"farmer":"Dharshan","customer_name":"JohnDoe","type":"customer","shop_name":"DoeMart","mobile_no":"9654984148","email":"john.doe@example.com","market":["AMUTHUMARI","MUTHUMARI"],"door_no":"123","country":"India","state":"TamilNadu","city":"Tenkasi","taluk":"Sengottai","village":"Pavoorchatram","post_code":560001,"gst_no":"29ABCDE1234F2Z5","tax_no":"TX123456789","is_credit":false,"opening_balance":2600,"customer_img":"","description":"None","is_customer_is_vendor":false,"language":{"default":"en"}}]

 Vendor List
 get = /get_vendor/<former id>
 response = [{"id":2,"farmer":"Dharshan","type":"vendor","name":"Swetha","business_name":"SMManagement","inventory_type":"Vehicle,Machinery,Tools","email":"swetha@gmail.com","mobile_no":9875647892,"alter_mobile_no":"","door_no":"230ChurchRoad","country":"India","state":"TamilNadu","city":"Tenkasi","taluk":"Sengottai","village":"Pavoorchatram","pincode":625020,"gst_number":"","tax_number":"","credit":"+","opening_balance":50000,"vendor_image":"http://192.168.3.24:1710/SuperAdmin/media/myvendors/user_3.png","description":"","language":{"default":"en"}}]

Add Both Customer & Vendor List
post = /add_customer/<former id>
post data = {"customer_name":"Meghna","shop_name":"DoeMart","mobile_no":"6876543222","email":"toh@exdsfample.com","market":[1,2],"door_no":"123","country":1,"state":1,"city":1,"taluk":1,"village":1,"post_code":560001,"gst_no":"29ABCDE1234F2Z5","tax_no":"TX123456789","is_credit":true,//example+meanstrueifnotfalse-"opening_balance":5000,"customer_img":"data:image/png;base64,iVBORw0KGentory_type":[1,2],"description":"new"}

Add Customer
post = /add_customer_sales/<former id>
post data = {"customer_name":"Arun","shop_name":"DoeMart","mobile_no":"9855577445","email":"jondavid.doe@example.com","market":[1],"door_no":"123","country":1,"state":1,"city":1,"taluk":1,"village":1,"post_code":560001,"gst_no":"29ABCDE1234F2Z5","tax_no":"TX123456789","is_credit":true,//example+meanstrueifnotfalse-"opening_balance":5000,"customer_img":"data:image/png;base64,iVBORw8AAAAASUVORK5CYII="}

Add Vendor
post = /add_vendor/<former id>
post data = {"farmer":1,"name":"Angela","business_name":"Angela'sGrocery","mobile_no":"9876543200","email":"",//"alter_mobile_no":"","door_no":"25B","country":1,"state":1,"city":1,"taluk":1,"village":1,"market":1,"pincode":654321,"gst_no":"","tax_no":"","is_credit":true,"opening_balance":500,"vendor_img":"data:image/png;base64,/9j/2wBDAAQDAwQDAwQEAwQFBAQaHxgaGxr/2wBDAQQFBQYFBgwHBwwaEQ8RGhoaGhoaIw5BBCF/9k=","description":"","inventory_type":[1,2]}
