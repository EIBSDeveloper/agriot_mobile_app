I have a UI screen design that needs to be analyzed and converted into a detailed JSON structure suitable for Flutter development. 

Please provide a comprehensive, screen-by-screen breakdown with no cross-referencing between screens. For each screen, include the following sections in the JSON output:

1. "screen": The screen name or title.
2. "purpose": A brief description of the screen’s function and role in the app flow.
3. "ui_elements": A detailed list of all UI components, differentiating static elements (e.g., labels, icons, images) and dynamic elements (e.g., input fields, dropdowns, buttons).
4. "layout_recommendations": Suggested Flutter widgets and layout strategies (e.g., Scaffold, Column, ListView), including styling tips like padding, alignment, and theming.
5. "input_controls": Describe input widgets (e.g., TextFormField, DropdownButton, DatePicker), expected behaviors, and any special input constraints or conditions.
6. "user_interactions": Describe user interactions such as taps, gestures, navigation flows, and related state changes (e.g., loading states, success messages).
7. "validation_rules": Detail validation logic for inputs or controls, including required fields, formats, constraints, and error handling.
8. "actions": List all action controls (buttons, toggles, etc.) with their labels and intended behaviors.


Please format your response exactly like this example for any screen type:

{
  "screen": "Fuel Entry Screen",
  "purpose": "Record fuel purchases (vendor, type, amount, litres, documents, notes) to track farm fuel usage and costs.",
  "ui_elements": {
    "static": ["AppBar with logo", "Screen title", "Labels", "Icons"],
    "dynamic": ["DatePicker for Date", "Dropdown for Fuel Category", "TextFormField for Purchase Amount", "Radio buttons for Fuel Type"]
  },
  "layout_recommendations": ["Use Scaffold with SingleChildScrollView", "Column for vertical layout", "Padding with EdgeInsets.symmetric(16)", "ThemeData for consistent styling"],
  "input_controls": [
    { "type": "date_picker", "label": "Date", "required": true },
    { "type": "dropdown", "label": "Fuel Category", "options": ["Petrol", "Diesel"], "required": true },
    { "type": "text_field", "label": "Purchase Amount", "keyboard": "number", "required": true }
  ],
  "user_interactions": ["Tap date opens calendar picker", "Select dropdown options", "Submit button triggers form validation and loading indicator"],
  "validation_rules": {
    "date": "required, not_future",
    "purchase_amount": "required, numeric > 0"
  },
  "actions": [
    { "type": "button", "label": "Add", "action": "submit_form" }
  ],
  
}

Please analyze the following UI screen and provide the JSON output in this format.


