General Context:
The app is a Vendor/Customer management system with views for listing, detail display, and interaction on both Vendor and Customer entities.

Screen 1: Vendor/Customer Listing Screen
Fields & Elements:
Header: App logo, notification bell icon, user profile avatar.
Toggle Tabs: "Both", "Customer", "Vendor" (toggle button for filtering list).
Search/Back button (left arrow).
List of entities with:
Name
Location or role description (e.g., “Ulavarsandhai”)
Mobile number
Layout & Widgets:
Scaffold with AppBar containing logo, notification icon, profile avatar.
TabBar or ToggleButtons for "Both", "Customer", "Vendor".
ListView.builder for dynamic list.
ListTile or custom Card for each list item.
User Interaction:
Tapping on list item navigates to Vendor/Customer detail screen.
Toggle changes the list filter dynamically.
Back button navigates to the previous screen.

Screen 2 & 3: Vendor Page and Vendor Details (Two Screens)
Vendor Page
Fields & Elements:
Header same as above.
Back button.
Entity name and category (e.g., "Prabhu, Machinery").
Tabs or segments: Sales, Purchase.
List of sales/purchase entries with:
Date
Item/Product name (partially truncated)
Amount (currency format)
Layout & Widgets:
Scaffold with AppBar.
TabBar for Sales and Purchase (or toggle buttons).
ListView for transaction entries.
Each entry: Row widget showing date, product name, amount.
User Interaction:
Tap entry to view detailed vendor info.
Vendor Details
Fields & Elements:
Header same as above.
Back button.
Editable icon (pencil) and delete icon (trash).
Vendor info fields:
Mobile No (phone number)
Email ID (email)
Shop Name (text)
Address (text)
Pincode (number)
Total Outstanding (with +/- sign and amount in green for credit, red for debit)
Vendor photo (displayed image)
Description (multiline text)
Layout & Widgets:
Scrollable Column.
TextFormFields or ReadOnly Text widgets for details.
Photo displayed with CircleAvatar or Image widget.
Edit and Delete buttons as IconButton.
Description: TextField multiline or read-only Text.
Input Types:
Mobile No: phone number input type.
Email ID: email input type.
Shop Name, Address: text input.
Pincode: numeric input.
Total Outstanding: display only, no direct input.
Description: multiline text input.
User Interaction:
Tap edit icon to enable editing fields.
Tap delete to remove vendor (confirmation dialog recommended).
Editing updates saved via Save button (assumed, though not shown).
Photo upload/change (optional feature).
Validation Rules:
Mobile No: numeric, valid phone number format.
Email: valid email format.
Pincode: numeric, length 6 (typical Indian pincode).
Mandatory fields: Mobile No, Email, Shop Name, Address.

Screen 4 & 5: Customer Page and Customer Details (Two Screens)
Customer Page
Fields & Elements:
Header same as above.
Back button.
Customer name and location.
List of recent purchases with:
Date
Product name
Amount (currency)
Layout & Widgets:
Similar to Vendor Page layout.
ListView for transactions.
ListTile or Row for each purchase item.
User Interaction:
Tap to open Customer Details.
Customer Details
Fields & Elements:
Same structure as Vendor Details, but specific to customer:
Mobile No, Email ID, Shop Name, Address, Pincode
Total Outstanding (amount in red indicating debt)
Customer Photo
Description
Layout & Widgets:
Similar to Vendor Details screen.
Editable fields and icons.
Photo and description area.
Input Types & Validation:
Same as Vendor Details.
User Interaction:
Edit, delete, save as with vendor details.

Navigation Flow:
Landing screen: Vendor/Customer listing with toggles.
Select a Vendor or Customer from the list.
Navigate to Vendor Page or Customer Page showing transaction history.
Tap on transaction or info icon to open detailed Vendor or Customer Details.
Edit or delete actions available on detail screen.
Back button returns to previous screen.
Notification icon and profile avatar likely open respective sections (not detailed here).

Recommended Flutter Widgets Summary:


TabBar or ToggleButtons for category filtering
ListView.builder for dynamic lists
ListTile or Card for list items
TextFormField for editable inputs
IconButton for edit/delete
CircleAvatar or Image for photos
SingleChildScrollView or CustomScrollView for detail screens
Input Widget Suggestions:
Date Picker: For transaction dates (if adding/editing)
Dropdown: For selecting categories or roles if needed (not in current UI)
Multiline TextField: For description
TextInputType.phone/email/number for respective fields
Validation Rules Summary:
Mobile No: required, valid phone format.
Email ID: required, valid email format.
Pincode: required, numeric, fixed length.
Mandatory fields cannot be empty.
Amount fields display only, no direct input.
Optional Flutter Packages Suggestions:
flutter_form_builder – for advanced forms & validation.
intl – for date formatting and currency formatting.
cached_network_image – for efficient photo loading if images are remote.
flutter_slidable – for swipe actions on lists (optional enhancement).
provider or bloc – for state management of filtering and editing.
image_picker – for photo upload functionality.

