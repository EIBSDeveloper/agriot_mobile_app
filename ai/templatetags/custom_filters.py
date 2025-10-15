from django import template

register = template.Library()

@register.filter
def get_item(dictionary, key):
    return dictionary.get(key)

@register.filter
def get_item_from_list(lst, index):
    if isinstance(lst, list) and 0 <= index < len(lst):
        return lst[index]
    return None  
 
@register.filter
def map_name(queryset):
    """ Custom filter to extract 'name' from a queryset of AddOnDetails objects """
    return [add_on.name for add_on in queryset]

@register.filter
def get_value(dictionary, key):
    """Return the value of the dictionary for the given key, or 0 if not found."""
    return dictionary.get(key, 0)

@register.filter
def split_extension(value):
    """Custom filter to return the file extension from the filename"""
    if isinstance(value, str):
        # Split the string by the period and return the last part as the extension
        return value.split('.')[-1].lower() if '.' in value else ''
    return ''

@register.filter
def display_as_int(value):
    try:
        if value == int(value):
            return int(value)
        return value
    except (ValueError, TypeError):
        return value  # If not a valid float, return the value as is
    
@register.filter
def get_str_item(dictionary, key):
    return dictionary.get(str(key), None)

@register.filter
def display_str_as_int(value):
    try:
        if float(value) == int(float(value)):
            return int(float(value))
        return value
    except (ValueError, TypeError):
        return value


@register.filter
def some(value, arg):
    """
    Returns True if any permission in `value` exists in `arg`.
    """
    return any(value.get(item) for item in arg)



# @register.filter
# def indian_commas(value):
#     try:
#         value = int(value)
#         str_value = str(value)
        
#         reversed_str_value = str_value[::-1]
        
#         parts = []
#         first_group = reversed_str_value[:3]
#         parts.append(first_group)
        
#         remaining = reversed_str_value[3:]
#         for i in range(0, len(remaining), 2):
#             parts.append(remaining[i:i+2])
        
#         formatted_value = ','.join(parts)[::-1]
#         return formatted_value
    
#     except (ValueError, TypeError):
#         return value

@register.filter
def indian_commas(value):
    try:
        # Convert the value to a string
        str_value = str(value)
        
        # Check if the value is a decimal number (contains a dot)
        if '.' in str_value:
            integer_part, decimal_part = str_value.split('.', 1)
        else:
            integer_part = str_value
            decimal_part = ''
        
        # Reverse the integer part to start formatting from the right
        reversed_integer_part = integer_part[::-1]
        
        # Format the integer part with commas
        parts = []
        first_group = reversed_integer_part[:3]
        parts.append(first_group)
        
        remaining = reversed_integer_part[3:]
        for i in range(0, len(remaining), 2):
            parts.append(remaining[i:i+2])
        
        formatted_integer_part = ','.join(parts)[::-1]
        
        # Combine the formatted integer part with the decimal part
        if decimal_part:
            formatted_value = f"{formatted_integer_part}.{decimal_part}"
        else:
            formatted_value = formatted_integer_part
        
        return formatted_value
    
    except (ValueError, TypeError):
        return value

