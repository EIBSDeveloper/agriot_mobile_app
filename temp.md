

"Here is my full code for the form screen. Please refactor it to use the ValidationMessage widget pattern from Option 2 for all form fields (text fields, dropdowns, etc.). Replace the inline validators with a separate validation message displayed below each field.

[PASTE YOUR FULL CODE HERE]

Please show me the complete updated code after the changes."

What I Will Do For You:
Once you provide your code, I will:

Create the reusable ValidationMessage widget.

Identify all your form fields (like _buildTextField, _buildDropdown, etc.).

Remove the validator property from each field and replace it with logic to handle validation on change or via a button press.

Place the ValidationMessage widget below each corresponding form field, passing it the appropriate error.

Ensure the validation logic is triggered correctly (e.g., when the user submits the form).

Preview of What to Expect (Example Snippet):
Your current code for a field probably looks like this:

dart
_buildTextField(
  controller: controller.landIdController,
  label: 'Land Identification *',
  validator: (value) => value!.isEmpty ? 'Required field' : null, // This will be removed
),
I will transform it into something like this:

dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    _buildTextField(
      controller: controller.landIdController,
      label: 'Land Identification *',
      onChanged: (value) {
        // This will update the error state for this field
        _updateLandIdError(value);
      },
    ),
    ValidationMessage(
      error: _landIdError, // The error for this specific field
    ),
  ],
),
Please go ahead and share your full code, and I will implement the changes for you immediately.