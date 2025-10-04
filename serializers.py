from rest_framework import serializers 
from ai.models import *
from dashboards.models import *
import re

class OTPSerializer(serializers.ModelSerializer):
    class Meta:
        model = FarmerOTP
        fields = ['mobile_number', 'otp']

    def validate_mobile_number(self, value):
        if not re.match(r'^\d{10}$', value):
            raise serializers.ValidationError("Mobile number must be exactly 10 digits.")
        return value

# class CountrySerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Country
#         fields = ['id', 'name', ]

# class StateSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = State
#         fields = ['id', 'name', 'country', ]

# class CitySerializer(serializers.ModelSerializer):
#     class Meta:
#         model = City
#         fields = ['id', 'name',  ]

# class TalukSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Taluk
#         fields = ['id', 'name',  ]

# class VillageSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Village
#         fields = ['id', 'name', ]

class CountrySerializer(serializers.ModelSerializer):
    class Meta:
        model = Country
        fields = ['id', 'name', ]

    def to_representation(self, instance):
        # Get the language code from the context (passed from the view)
        language_code = self.context.get('language_code', 'en')

        # Get the default representation
        representation = super().to_representation(instance)

        # Translate the 'name' field if possible
        translated_name = instance.get_translated_value('name', language_code)
        representation['name'] = translated_name  # Override the 'name' with the translated value
        
        return representation

class StateSerializer(serializers.ModelSerializer):
    class Meta:
        model = State
        fields = ['id', 'name', 'country', ]

    def to_representation(self, instance):
        language_code = self.context.get('language_code', 'en')  # Get lang from context
        representation = super().to_representation(instance)
        representation['name'] = instance.get_translated_value('name', language_code)  # Translate name
        return representation

class CitySerializer(serializers.ModelSerializer):
    class Meta:
        model = City
        fields = ['id', 'name',  ]

    def to_representation(self, instance):
        language_code = self.context.get('language_code', 'en')
        representation = super().to_representation(instance)
        representation['name'] = instance.get_translated_value('name', language_code)
        return representation

class TalukSerializer(serializers.ModelSerializer):
    class Meta:
        model = Taluk
        fields = ['id', 'name',  ]

    def to_representation(self, instance):
        language_code = self.context.get('language_code', 'en')
        representation = super().to_representation(instance)
        representation['name'] = instance.get_translated_value('name', language_code)
        return representation

class VillageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Village
        fields = ['id', 'name', ]

    def to_representation(self, instance):
        language_code = self.context.get('language_code', 'en')
        representation = super().to_representation(instance)
        representation['name'] = instance.get_translated_value('name', language_code)
        return representation





class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'user', 'name', 'image', 'message', 'created_at', 'is_read']

# class CropTypeSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = CropType
#         fields = ['id', 'name', 'description', ]

# class CropSerializer(serializers.ModelSerializer):
#     croptype = CropTypeSerializer(read_only=True)

#     class Meta:
#         model = Crop
#         fields = ['id', 'name', 'description', 'croptype', 'img', ]

# class SoilTypeSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = SoilType
#         fields = ['id', 'name', 'description', ]

# class AreaUnitSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = AreaUnit
#         fields = ['id', 'name', 'areaunitdef', 'description', ]

# class ProductTypeSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = ProductType
#         fields = ['id', 'name', 'description', ]

# class LandUnitSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = LandUnit
#         fields = ['id', 'name', 'landunitdef', 'description', ]


# class ExpensesCategorySerializer(serializers.ModelSerializer):
#     class Meta:
#         model = ExpensesCategory
#         fields = ['id', 'name', 'description', ]

# class ExpensesSerializer(serializers.ModelSerializer):
#     expenses_category = ExpensesCategorySerializer(read_only=True)

#     class Meta:
#         model = Expenses
#         fields = ['id', 'name', 'description', 'expenses_category', ]

# class InventoryTypeSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = InventoryType
#         fields = ['id', 'name']

# class InventoryCategorySerializer(serializers.ModelSerializer):
#     class Meta:
#         model = InventoryCategory
#         fields = ['id', 'name']

# class InventoryItemsSerializer(serializers.ModelSerializer):

#     class Meta:
#         model = InventoryItems
#         fields = ['id', 'name']

class CropTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = CropType
        fields = ['id', 'name', 'description', ]

    def to_representation(self, instance):
        # Get the language code from the context (passed from the view)
        language_code = self.context.get('language_code', 'en')

        # Get the default representation (without translation)
        representation = super().to_representation(instance)

        # Translate the 'name' field
        translated_name = instance.get_translated_value('name', language_code)
        representation['name'] = translated_name  # Override 'name' with translated value

        translated_description = instance.get_translated_value('description', language_code)
        representation['description'] = translated_description  # Override 'description' with translated value

        return representation

class CropSerializer(serializers.ModelSerializer):
    croptype = CropTypeSerializer(read_only=True)

    class Meta:
        model = Crop
        fields = ['id', 'name', 'description', 'croptype', 'img', ]

class SoilTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = SoilType
        fields = ['id', 'name', 'description', ]

    def to_representation(self, instance):
        # Get the language code from the context (passed from the view)
        language_code = self.context.get('language_code', 'en')

        # Get the default representation (without translation)
        representation = super().to_representation(instance)

        # Translate the 'name' field
        translated_name = instance.get_translated_value('name', language_code)
        representation['name'] = translated_name  # Override 'name' with translated value

        translated_description = instance.get_translated_value('description', language_code)
        representation['description'] = translated_description  # Override 'description' with translated value

        return representation

class AreaUnitSerializer(serializers.ModelSerializer):
    class Meta:
        model = AreaUnit
        fields = ['id', 'name', 'areaunitdef', 'description', ]

class ProductTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductType
        fields = ['id', 'name', 'description', ]

    def to_representation(self, instance):
        language_code = self.context.get('language_code', 'en')
        rep = super().to_representation(instance)
        rep['name'] = instance.get_translated_value('name', language_code)
        rep['description'] = instance.get_translated_value('description', language_code)
        return rep

class LandUnitSerializer(serializers.ModelSerializer):
    class Meta:
        model = LandUnit
        fields = ['id', 'name', 'landunitdef', 'description', ]

    def to_representation(self, instance):
        # Get the language code from the context (passed from the view)
        language_code = self.context.get('language_code', 'en')

        # Get the default representation (without translation)
        representation = super().to_representation(instance)

        # Translate the 'name' field
        translated_name = instance.get_translated_value('name', language_code)
        representation['name'] = translated_name  # Override 'name' with translated value

        # Translate the 'landunitdef' field
        translated_landunitdef = instance.get_translated_value('landunitdef', language_code)
        representation['landunitdef'] = translated_landunitdef  # Override 'landunitdef' with translated value

        # Translate the 'description' field
        translated_description = instance.get_translated_value('description', language_code)
        representation['description'] = translated_description  # Override 'description' with translated value

        return representation

class ExpensesCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = ExpensesCategory
        fields = ['id', 'name', 'description', ]

    def to_representation(self, instance):
        language_code = self.context.get('language_code', 'en')
        rep = super().to_representation(instance)
        rep['name'] = instance.get_translated_value('name', language_code)
        rep['description'] = instance.get_translated_value('description', language_code)
        return rep

class ExpensesSerializer(serializers.ModelSerializer):
    expenses_category = ExpensesCategorySerializer(read_only=True)

    class Meta:
        model = Expenses
        fields = ['id', 'name', 'description', 'expenses_category', ]

class InventoryTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = InventoryType
        fields = ['id', 'name']

class InventoryCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = InventoryCategory
        fields = ['id', 'name']

class InventoryItemsSerializer(serializers.ModelSerializer):

    class Meta:
        model = InventoryItems
        fields = ['id', 'name']



# class InventoryTypeSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = InventoryType
#         fields = ['id', 'name', 'code', ]

# class InventoryCategorySerializer(serializers.ModelSerializer):
#     inventory_type = InventoryTypeSerializer(read_only=True)

#     class Meta:
#         model = InventoryCategory
#         fields = ['id', 'name', 'inventory_type',]

# class InventoryItemsSerializer(serializers.ModelSerializer):
#     inventory_type = InventoryTypeSerializer(read_only=True)
#     inventory_category = InventoryCategorySerializer(read_only=True)

#     class Meta:
#         model = InventoryItems
#         fields = ['id', 'name', 'inventory_type', 'inventory_category',]

# class HarvestingTypeSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = HarvestingType
#         fields = ['id', 'name', 'description', ]

# class ScheduleActivityTypeSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = ScheduleActivityType
#         fields = ['id', 'name', 'description', ]

# class ScheduleSerializer(serializers.ModelSerializer):
#     crop = CropSerializer(read_only=True)
#     activity_type = ScheduleActivityTypeSerializer(read_only=True)

#     class Meta:
#         model = Schedule
#         fields = ['id', 'crop', 'days', 'activity_type', 'description', ]

class HarvestingTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = HarvestingType
        fields = ['id', 'name', 'description', ]

    def to_representation(self, instance):
        # Get the language code from the context
        language_code = self.context.get('language_code', 'en')

        # Get the default representation (without translation)
        representation = super().to_representation(instance)

        # Translate 'name' and 'description' fields
        translated_name = instance.get_translated_value('name', language_code)
        translated_description = instance.get_translated_value('description', language_code)

        # Update the representation with the translated values
        representation['name'] = translated_name
        representation['description'] = translated_description

        return representation

class ScheduleActivityTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ScheduleActivityType
        fields = ['id', 'name', 'description', ]

    def to_representation(self, instance):
        language_code = self.context.get('language_code', 'en')
        representation = super().to_representation(instance)

        # Translate using get_translated_value method
        representation['name'] = instance.get_translated_value('name', language_code)
        representation['description'] = instance.get_translated_value('description', language_code)

        return representation

class ScheduleSerializer(serializers.ModelSerializer):
    crop = CropSerializer(read_only=True)
    activity_type = ScheduleActivityTypeSerializer(read_only=True)

    class Meta:
        model = Schedule
        fields = ['id', 'crop', 'days', 'activity_type', 'description', ]
    
class ReasonsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reasons
        fields = ['id', 'name', ]

    def to_representation(self, instance):
        language_code = self.context.get('language_code', 'en')
        representation = super().to_representation(instance)

        # Translate fields using instance.get_translated_value
        representation['name'] = instance.get_translated_value('name', language_code)
        # 'description'
        # representation['description'] = instance.get_translated_value('description', language_code)

        return representation

# class DocumentCategorySerializer(serializers.ModelSerializer):
    
#     class Meta:
#         model = DocumentCategory
#         fields = ['id','doctype', 'name', 'description', ]
        
class DocumentCategorySerializer(serializers.ModelSerializer):
    
    class Meta:
        model = DocumentCategory
        fields = ['id','doctype', 'name', 'description', ]
        
    def to_representation(self, instance):
        language_code = self.context.get('language_code', 'en')
        representation = super().to_representation(instance)

        # Translate using get_translated_value method
        representation['name'] = instance.get_translated_value('name', language_code)
        representation['description'] = instance.get_translated_value('description', language_code)

        return representation

class DetectionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Detection
        fields = ['id', 'name', 'description', ]

# class DocumentCategorySerializer(serializers.ModelSerializer):
#     class Meta:
#         model = DocumentCategory
#         fields = ['id','doctype', 'name', 'description', ]

# class NearByLocationCategorySerializer(serializers.ModelSerializer):
#     class Meta:
#         model = NearByLocationCategory
#         fields = ['id', 'name', 'description', ]

# class GuidelinesCategorySerializer(serializers.ModelSerializer):
#     class Meta:
#         model = GuidelinesCategory
#         fields = ['id', 'name', 'description', ]

class NearByLocationCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = NearByLocationCategory
        fields = ['id', 'name', 'description', ]

    def to_representation(self, instance):
        language_code = self.context.get('language_code', 'en')
        representation = super().to_representation(instance)

        # Apply translations
        representation['name'] = instance.get_translated_value('name', language_code)
        representation['description'] = instance.get_translated_value('description', language_code)

        return representation

class GuidelinesCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = GuidelinesCategory
        fields = ['id', 'name', 'description', ]

    def to_representation(self, instance):
        language_code = self.context.get('language_code', 'en')
        representation = super().to_representation(instance)

        # Apply translations
        representation['name'] = instance.get_translated_value('name', language_code)
        representation['description'] = instance.get_translated_value('description', language_code)

        return representation


class FarmerSerializer(serializers.ModelSerializer):
    subscription_package = serializers.StringRelatedField()
    class Meta:
        model = Farmer
        fields = [
           'name', 'phone', 'email', 'country', 'state', 
            'city', 'taluk', 'village', 'door_no', 'pincode', 'description', 
            'img', 'company_name', 'tax_no',  'subscription_package', 
            'subscription_end_date', 'subscription_start_date', 'remaining_days', 
            'amounts', 'sub_amounts', 'refresh_token', 
        ]
        
# Serializer for MyLandSurveyDetails
# class MyLandSurveyDetailsSerializer(serializers.ModelSerializer):
#     survey_measurement_unit = serializers.StringRelatedField()
#     MyLand =serializers.StringRelatedField()

#     class Meta:
#         model = MyLandSurveyDetails
#         fields = [
#             'id', 'farmer', 'MyLand', 'survey_no', 'survey_measurement_value', 
#             'survey_measurement_unit'
#         ]


# Serializer for MyLandDocument
# class MyLandDocumentSerializer(serializers.ModelSerializer):
#     # document_category = serializers.StringRelatedField()  # Display category name instead of ID
#     document_category = serializers.PrimaryKeyRelatedField(queryset=DocumentCategory.objects.all())

#     class Meta:
#         model = MyLandDocument
#         fields = [
#             'id', 'farmer', 'myland', 'document_category', 'upload_document',
#         ]

# class MyLandInsertionSerializer(serializers.ModelSerializer):
#     survey_details = MyLandSurveyDetailsSerializer(many=True)
#     documents = MyLandDocumentSerializer(many=True, read_only=True)  # Serialize land documents
    
#     class Meta:
#         model = MyLand
#         fields = [
#             'farmer', 'name', 'measurement_value', 'measurement_unit', 
#             'soil_type', 'country', 'state', 'city', 'taluk', 'village', 'door_no', 
#             'locations', 'latitude', 'longitude', 'survey_number', 
#             'patta_number', 'description', 'l_status', 'map_data', 
#             'survey_details', 'documents'
#         ]

# class MyLandInsertionSerializer(serializers.ModelSerializer):
#     survey_details = MyLandSurveyDetailsSerializer(many=True)
#     documents = MyLandDocumentSerializer(many=True)

#     class Meta:
#         model = MyLand
#         fields = [
#             'farmer', 'name', 'measurement_value', 'measurement_unit',
#             'soil_type', 'country', 'state', 'city', 'taluk', 'village', 'door_no',
#             'locations', 'latitude', 'longitude', 'survey_number',
#             'patta_number', 'description', 'l_status', 'map_data',
#             'survey_details', 'documents'
#         ]

#     def create(self, validated_data):
#         # Extract survey_details and documents data
#         survey_details_data = validated_data.pop('survey_details', [])
#         documents_data = validated_data.pop('documents', [])

#         # Create the MyLand instance
#         my_land = MyLand.objects.create(**validated_data)

#         # Create the nested survey_details
#         for survey_data in survey_details_data:
#             # Add the my_land instance reference to each survey_detail
#             survey_data['my_land'] = my_land
#             MyLandSurveyDetails.objects.create(**survey_data)  # Create survey detail instance

#         # Create documents if provided
#         for document_data in documents_data:
#             # Add the my_land instance reference to each document
#             document_data['my_land'] = my_land
#             MyLandDocument.objects.create(**document_data)  # Create document instance

#         return my_land



# Serializer for MyLand
# class MyLandDetailsSerializer(serializers.ModelSerializer):
#     farmer = serializers.StringRelatedField()  # For displaying farmer's name instead of ID
#     soil_type = serializers.StringRelatedField()  # Display soil type name instead of ID
#     country = serializers.StringRelatedField()  # Display country name instead of ID
#     state = serializers.StringRelatedField()  # Display state name instead of ID
#     city = serializers.StringRelatedField()  # Display city name instead of ID
#     taluk = serializers.StringRelatedField()  # Display taluk name instead of ID
#     village = serializers.StringRelatedField()  # Display village name instead of ID
#     measurement_unit = serializers.StringRelatedField()  # Display measurement unit name instead of ID
#     # survey_details = MyLandSurveyDetailsSerializer(many=True, read_only=True)  # Serialize survey details
#     documents = MyLandDocumentSerializer(many=True, read_only=True)  # Serialize land documents
    
#     class Meta:
#         model = MyLand
#         fields = [
#             'farmer', 'name', 'measurement_value', 'measurement_unit', 
#             'soil_type', 'country', 'state', 'city', 'taluk', 'village', 'door_no', 
#             'locations', 'latitude', 'longitude', 'survey_number', 
#             'patta_number', 'description', 'l_status', 'map_data', 
#               'documents'
#         ]

# class MyCropInsertionSerializer(serializers.ModelSerializer):
   

#     class Meta:
#         model = MyCrop
#         fields = [
#             'id', 'farmer', 'crop_type', 'crop', 'crop_img', 'harvesting_type', 
#             'plantation_date', 'land', 'soil_type', 'taluk', 'village', 
#             'measurement_value', 'measurement_unit','geo_marks', 'c_status', 'expense', 'sales',
#             'survey_details', 'status', 
#             'description'  
#         ]



# class MyCropDetailsSerializer(serializers.ModelSerializer):
#     farmer = serializers.StringRelatedField()
#     crop_type = serializers.StringRelatedField()
#     crop = serializers.StringRelatedField()
#     land = serializers.StringRelatedField()  # Display crop name instead of ID
#     harvesting_type = serializers.StringRelatedField()  # Display harvesting type name instead of ID
#     soil_type = serializers.StringRelatedField()  # Display soil type name instead of ID
#     taluk = serializers.StringRelatedField()  # Display taluk name instead of ID
#     village = serializers.StringRelatedField()  # Display village name instead of ID
#     measurement_unit = serializers.StringRelatedField()  # Display measurement unit name instead of ID
#     # survey_details = MyLandSurveyDetailsSerializer(many=True, read_only=True)  # Serialize survey details
    
#     # Add a custom field to calculate days since plantation
#     days_since_plantation = serializers.SerializerMethodField()

#     class Meta:
#         model = MyCrop
#         fields = [
#             'id', 'farmer', 'crop_type', 'crop', 'crop_img', 'harvesting_type', 
#             'plantation_date', 'land', 'soil_type', 'taluk', 'village', 
#             'measurement_value', 'measurement_unit','geo_marks', 'c_status', 'expense', 'sales',
#             'days_since_plantation'   'status', 
#             'description'  
#         ]

#     def get_days_since_plantation(self, obj):
#         # Get the plantation date from the crop instance
#         plantation_date = obj.plantation_date
        
#         if plantation_date:
#             # Calculate the difference between today's date and the plantation date
#             today = datetime.now().date()
#             days_diff = (today - plantation_date).days
#             return days_diff
#         return None  # Return None if plantation_date is not available

# class MyCustomerInsertionSerializer(serializers.ModelSerializer):

#     class Meta:
#         model = MyCustomer
#         fields = [
#             'id',
#             'farmer',  # primary key of farmer
#             'customer_name',
#             'shop_name',
#             'mobile_no',
#             'email',
#             'market',  # primary key of market
#             'door_no',
#             'country',  # primary key of country
#             'state',  # primary key of state
#             'city',  # primary key of city
#             'taluk',  # primary key of taluk
#             'village',  # primary key of village
#             'post_code',
#             'gst_no',
#             'tax_no',
#             'is_credit',
#             'opening_balance',
#             'customer_img',
#             'description',
#             'is_customer_is_vendor'
#         ]

#     def get_type(self, obj):
#         return 'customer'


class MyCustomerInsertionSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyCustomer
        fields = [
            'id',
            'farmer',
            'customer_name',
            'shop_name',
            'mobile_no',
            'email',
            'market',
            'door_no',
            'country',
            'state',
            'city',
            'taluk',
            'village',
            'post_code',
            'gst_no',
            'tax_no',
            'is_credit',
            'opening_balance',
            'customer_img',
            'description',
            'is_customer_is_vendor'
        ]
        extra_kwargs = {
            'market': {'required': False},  # 👈 This is the fix
        }

    def get_type(self, obj):
        return 'customer'


class MyCustomerDetailsSerializer(serializers.ModelSerializer):
    # Use StringRelatedField for fields that should return a string value instead of a primary key
    farmer = serializers.StringRelatedField()  # StringRelatedField for farmer (name)
    market = serializers.StringRelatedField(many=True)  # StringRelatedField for market (names)
    country = serializers.StringRelatedField()  # StringRelatedField for country (name)
    state = serializers.StringRelatedField()  # StringRelatedField for state (name)
    city = serializers.StringRelatedField()  # StringRelatedField for city (name)
    taluk = serializers.StringRelatedField()  # StringRelatedField for taluk (name)
    village = serializers.StringRelatedField() 
    type = serializers.SerializerMethodField()

    class Meta:
        model = MyCustomer
        fields = [
            'id',
            'farmer',  # primary key of farmer
            'customer_name',
            'type',
            'shop_name',
            'mobile_no',
            'email',
            'market',  # primary key of market
            'door_no',
            'country',  # primary key of country
            'state',  # primary key of state
            'city',  # primary key of city
            'taluk',  # primary key of taluk
            'village',  # primary key of village
            'post_code',
            'gst_no',
            'tax_no',
            'is_credit',
            'opening_balance',
            'customer_img',
            'description',
            'is_customer_is_vendor'
        ]

    def get_type(self, obj):
        return 'customer'
    
class MyVendorInsertionSerializer(serializers.ModelSerializer):
  
    class Meta:
        model = MyVendor
        fields = [
            'id',
            'farmer', 
            'name',
            'business_name',
            'inventory_type',  # primary key of inventory_type
            'email',
            'mobile_no',
            'alter_mobile_no',
            'door_no',
            'country',  # primary key of country
            'state',  # primary key of state
            'city',  # primary key of city
            'taluk',  # primary key of taluk
            'village',  # primary key of village
            'pincode',
            'gst_number',
            'tax_number',
            'credit',
            'debit',
            'opening_balance',
            'vendor_image',
            'description',
            # 'is_customer_is_vendor'
        ]

    def get_type(self, obj):
        return 'vendor'
       
class MyVendorDetailsSerializer(serializers.ModelSerializer):
    # Use StringRelatedField for fields that should return a string value (name) instead of a primary key
    farmer = serializers.StringRelatedField()  # StringRelatedField for farmer (name)
    inventory_type = serializers.StringRelatedField()  # StringRelatedField for inventory_type (names)
    country = serializers.StringRelatedField()  # StringRelatedField for country (name)
    state = serializers.StringRelatedField()  # StringRelatedField for state (name)
    city = serializers.StringRelatedField()  # StringRelatedField for city (name)
    taluk = serializers.StringRelatedField()  # StringRelatedField for taluk (name)
    village = serializers.StringRelatedField()  # StringRelatedField for village (name)
    type = serializers.SerializerMethodField()

    class Meta:
        model = MyVendor
        fields = [
            'id',
            'farmer',
            'type',  # primary key of farmer
            'name',
            'business_name',
            'inventory_type',  # primary key of inventory_type
            'email',
            'mobile_no',
            'alter_mobile_no',
            'door_no',
            'country',  # primary key of country
            'state',  # primary key of state
            'city',  # primary key of city
            'taluk',  # primary key of taluk
            'village',  # primary key of village
            'pincode',
            'gst_number',
            'tax_number',
            'credit',
            'debit',
            'opening_balance',
            'vendor_image',
            'description',
            # 'is_customer_is_vendor'
        ]

    def get_type(self, obj):
        return 'vendor'
             
class FuelPurchaseSerializer(serializers.ModelSerializer):
    # Serialize related fields
    fuel_name = serializers.CharField(source='fuel.name')  # Assuming the Fuel model has a `name` field
    fuel_quantity = serializers.IntegerField(source='fuel.quantity')  # Assuming the Fuel model has a `quantity` field
    fuel_price = serializers.DecimalField(source='fuel.price', max_digits=10, decimal_places=2)  # Assuming the Fuel model has `price`
    created_by_username = serializers.CharField(source='created_by.username')  # Assuming CustomUser has a `username` field
    
    class Meta:
        model = Purchase
        fields = [
            'id',
            'created_at',
            'status',
            'fuel_name',
            'fuel_quantity',
            'fuel_price',
            'created_by_username'
        ]

#----------------------------------------Market
class ManageMarketSerializer(serializers.ModelSerializer):
    market_name = serializers.CharField(source='name', read_only=True)  # Market name as a field
    market_id = serializers.IntegerField(source='id', read_only=True)  # Market ID as a field

    class Meta:
        model = ManageMarket
        fields = [
            'market_id',  # Market ID
            'market_name',  # Market Name
            'markettype',  # Market Type (as a ForeignKey)
            'products',  # Products (many-to-many field)
            'openingtime',  # Opening Time
            'closingtime',  # Closing Time
            'days',  # Days of operation (many-to-many field)
            'description',  # Market description
            'img',  # Market image
            'phone',  # Contact phone
            'address',  # Market address
            'latitude',  # Latitude
            'longitude',  # Longitude
        ]
        
    @staticmethod
    def get_market_names():
        # Get all markets and return a list of dictionaries with 'id' and 'name'
        markets = ManageMarket.objects.all()
        return [{'id': market.id, 'name': market.name} for market in markets]

#----------------------------------------Inventory
class MyInventoryDocumentsSerializer(serializers.ModelSerializer):
    class Meta:
        model ='MyInventoryDocuments'
        fields = ['id', 'document', 'my_inventory']




class MyFuelDocumentsSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    fuel = serializers.StringRelatedField()
    class Meta:
        model = MyFuelDocuments
        fields = [
            'farmer', 'document', 'fuel', 'file_type', 'status',  
        ]

# class MyVehicleDocumentsSerializer(serializers.ModelSerializer):
#     farmer = serializers.StringRelatedField()
#     vehicle = serializers.StringRelatedField()
#     farmer = serializers.StringRelatedField()
#     tools = serializers.StringRelatedField()
#     class Meta:
#         model = MyVehicleDocuments
#         fields = [
#             'farmer', 'document', 'vehicle', 'file_type', 'status', 
        
#         ]

# class MyVehicleDocumentsSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = MyVehicleDocuments
#         fields = '__all__'  # Specify fields as needed

class MyMachineryDocumentsSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    vendor = serializers.StringRelatedField()
    inventory_type = serializers.StringRelatedField()
    inventory_category = serializers.StringRelatedField()
    machinery = serializers.StringRelatedField()
    class Meta:
        model = MyMachineryDocuments
        fields = [
            'farmer', 'document', 'machinery', 'file_type',        ]
        
class MyPesticidesDocumentsSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    pesticides = serializers.StringRelatedField()
    
    class Meta:
        model = MyPesticidesDocuments
        fields = [
            'farmer', 'document', 'pest', 'file_type', 'status', 
          
        ]

class MyFertilizersDocumentsSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    fertilizers = serializers.StringRelatedField()
    class Meta:
        model = MyFertilizersDocuments
        fields = [
            'farmer', 'document', 'fertilizers', 'file_type', 
        ]

class MySeedsDocumentsSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    seeds = serializers.StringRelatedField()

    class Meta:
        model = MyseedsDocuments
        fields = [
            'farmer', 'document', 'seeds', 'file_type', 
        ]

 



# class MyFuelSerializer(serializers.ModelSerializer):
#     farmer = serializers.StringRelatedField()
#     vendor = serializers.StringRelatedField()
#     inventory_type = serializers.StringRelatedField()
#     inventory_category = serializers.StringRelatedField()
#     inventory_items = serializers.SerializerMethodField()
 
#     # documents = MyFuelDocumentsSerializer()
#     class Meta:
#         model = MyFuel
#         fields = [
#             'farmer', 'date_of_consumption', 'vendor', 'inventory_type',  'inventory_items',
#             'inventory_category', 'inventory_items', 'quantity', 'purchase_amount', 
#             'description', 'is_empty',
#             # 'documents'
#         ]
#     def get_inventory_type(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_type:
#             return obj.inventory_type.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists

#     def get_inventory_category(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_category:
#             return obj.inventory_category.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists
    
#     def get_inventory_items(self, obj):
#         # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
#         if obj.inventory_items:
#             # If it's a ForeignKey, return the name of the related item
#             return obj.inventory_items.name
#         return []  # Return an empty list if no related items exist

# class MyVehicleSerializer(serializers.ModelSerializer):
#     farmer = serializers.StringRelatedField()
#     vendor = serializers.StringRelatedField()
#     inventory_type = serializers.StringRelatedField()
#     inventory_category = serializers.StringRelatedField()
#     inventory_items = serializers.SerializerMethodField()

   

#     class Meta:
#         model = MyVehicle
#         fields = [
#             'farmer', 'date_of_consumption', 'vendor', 'inventory_type',  'inventory_items',
#             'inventory_category', 'register_number', 
#             'owner_name', 'date_of_registration', 'registration_valid_till', 
#             'date', 'engine_number', 'chasis_number', 'running_kilometer', 
#             'service_frequency', 'service_frequency_unit', 'fuel_capacity', 
#             'average_mileage', 'purchase_amount', 'insurance', 'company_name', 
#             'insurance_no', 'insurance_amount', 'insurance_start_date', 
#             'insurance_end_date', 'insurance_renewal_date', 'description',
#         ]
#     def get_inventory_type(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_type:
#             return obj.inventory_type.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists

#     def get_inventory_category(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_category:
#             return obj.inventory_category.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists
    
    
#     def get_inventory_items(self, obj):
#         # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
#         if obj.inventory_items:
#             # If it's a ForeignKey, return the name of the related item
#             return obj.inventory_items.name
#         return []  # Return an empty list if no related items exist

# class MyMachinerySerializer(serializers.ModelSerializer):
#     farmer = serializers.StringRelatedField()
#     vendor = serializers.StringRelatedField()
#     inventory_type = serializers.StringRelatedField()
#     inventory_category = serializers.StringRelatedField()
#     inventory_items = serializers.SerializerMethodField()
#     class Meta:
#         model = MyMachinery
#         fields = [
#             'id','farmer', 'date_of_consumption', 'vendor', 'inventory_type','inventory_items',
#             'inventory_category','fuel_type',  
#             'fuel_capacity', 'purchase_amount', 'warranty_start_date', 
#             'warranty_end_date', 'description',
#         ]

      
#     def get_inventory_type(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_type:
#             return obj.inventory_type.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists

#     def get_inventory_category(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_category:
#             return obj.inventory_category.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists
    
#     def get_inventory_items(self, obj):
#         # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
#         if obj.inventory_items:
#             # If it's a ForeignKey, return the name of the related item
#             return obj.inventory_items.name
#         return []  # Return an empty list if no related items exist
      
# class MyToolsSerializer(serializers.ModelSerializer):
 

#     farmer = serializers.StringRelatedField()  
#     vendor = serializers.StringRelatedField()  
#     inventory_type = serializers.StringRelatedField() 
#     inventory_category = serializers.StringRelatedField() 

#     class Meta:
#         model = MyTools
#         fields = [
#             'id', 'farmer', 'date_of_consumption', 'vendor', 'inventory_type',  'inventory_items',
#             'inventory_category',  'quantity', 'purchase_amount', 
#             'description'
#         ]
#     def get_inventory_type(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_type:
#             return obj.inventory_type.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists

#     def get_inventory_category(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_category:
#             return obj.inventory_category.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists
    
    
#     def get_inventory_items(self, obj):
#         # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
#         if obj.inventory_items:
#             # If it's a ForeignKey, return the name of the related item
#             return obj.inventory_items.name
#         return []  # Return an empty list if no related items exist

# class MyPesticidesSerializer(serializers.ModelSerializer):
#     farmer = serializers.StringRelatedField()
#     vendor = serializers.StringRelatedField()
#     inventory_type = serializers.StringRelatedField()
#     inventory_category = serializers.StringRelatedField()
#     inventory_items = serializers.SerializerMethodField()
#     class Meta:
#         model = MyPesticides
#         fields = [
#             'farmer', 'date_of_consumption', 'vendor', 'inventory_type',  'inventory_items',
#             'inventory_category', 'quantity', 
#             'quantity_unit', 'purchase_amount', 'description', 
            
#         ]
#     def get_inventory_type(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_type:
#             return obj.inventory_type.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists

#     def get_inventory_category(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_category:
#             return obj.inventory_category.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists
    
    
#     def get_inventory_items(self, obj):
#         # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
#         if obj.inventory_items:
#             # If it's a ForeignKey, return the name of the related item
#             return obj.inventory_items.name
#         return []  # Return an empty list if no related items exist

# class MyFertilizersSerializer(serializers.ModelSerializer):
#     farmer = serializers.StringRelatedField()
#     vendor = serializers.StringRelatedField()
#     inventory_type = serializers.StringRelatedField()
#     inventory_category = serializers.StringRelatedField()
#     inventory_items = serializers.SerializerMethodField()

#     class Meta:
#         model = MyFertilizers
#         fields = [
#             'farmer', 'date_of_consumption', 'vendor', 'inventory_type',  'inventory_items',
#             'inventory_category',  'quantity', 
#             'quantity_unit', 'purchase_amount', 'description', 
         
#         ]
#     def get_inventory_type(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_type:
#             return obj.inventory_type.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists

#     def get_inventory_category(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_category:
#             return obj.inventory_category.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists
    
#     def get_inventory_items(self, obj):
#         # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
#         if obj.inventory_items:
#             # If it's a ForeignKey, return the name of the related item
#             return obj.inventory_items.name
#         return []  # Return an empty list if no related items exist

# class MySeedsSerializer(serializers.ModelSerializer):
#     farmer = serializers.StringRelatedField()
#     vendor = serializers.StringRelatedField()
#     inventory_type = serializers.StringRelatedField()
#     inventory_category = serializers.StringRelatedField()
#     inventory_items = serializers.SerializerMethodField()
#     class Meta:
#         model = MySeeds
#         fields = [
#             'farmer', 'date_of_consumption', 'vendor', 'inventory_type', 'inventory_items',
#             'inventory_category', 'quantity', 
#             'quantity_unit', 'purchase_amount', 'description', 
           
#         ]
#     def get_inventory_type(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_type:
#             return obj.inventory_type.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists

#     def get_inventory_category(self, obj):
#         # If inventory_items is a ForeignKey, access the related object directly
#         if obj.inventory_category:
#             return obj.inventory_category.name  # Return the name of the related InventoryItem
#         return None  # Return None or appropriate value if no related item exists
    
#     def get_inventory_items(self, obj):
#         # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
#         if obj.inventory_items:
#             # If it's a ForeignKey, return the name of the related item
#             return obj.inventory_items.name
#         return []  # Return an empty list if no related items exist



class MyFuelSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    vendor = serializers.StringRelatedField()
    inventory_type = serializers.StringRelatedField()
    inventory_category = serializers.StringRelatedField()
    inventory_items = serializers.SerializerMethodField()
 
    # documents = MyFuelDocumentsSerializer()
    class Meta:
        model = MyFuel
        fields = [
            'id',
            'farmer', 'date_of_consumption', 'vendor', 'inventory_type',  'inventory_items',
         'inventory_items', 'quantity', 'purchase_amount', 
            'description'
            # 'documents'
        ]
    def get_inventory_type(self, obj):
        # If inventory_items is a ForeignKey, access the related object directly
        if obj.inventory_type:
            return obj.inventory_type.name  # Return the name of the related InventoryItem
        return None  # Return None or appropriate value if no related item exists

    # def get_inventory_category(self, obj):
    #     # If inventory_items is a ForeignKey, access the related object directly
    #     if obj.inventory_category:
    #         return obj.inventory_category.name  # Return the name of the related InventoryItem
    #     return None  # Return None or appropriate value if no related item exists
    
    def get_inventory_items(self, obj):
        # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
        if obj.inventory_items:
            # If it's a ForeignKey, return the name of the related item
            return obj.inventory_items.name
        return []  # Return an empty list if no related items exist

class MyVehicleSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    vendor = serializers.StringRelatedField()
    inventory_type = serializers.StringRelatedField()
    inventory_category = serializers.StringRelatedField()
    inventory_items = serializers.SerializerMethodField()

   

    class Meta:
        model = MyVehicle
        fields = [
            'id',
            'farmer', 'date_of_consumption', 'vendor', 'inventory_type',  'inventory_items',
            'inventory_category', 'register_number', 
            'owner_name', 'date_of_registration', 'registration_valid_till', 
             'engine_number', 'chasis_number', 'running_kilometer', 
            'service_frequency', 'service_frequency_unit', 'fuel_capacity', 
            'average_mileage', 'purchase_amount', 'insurance', 'company_name', 
            'insurance_no', 'insurance_amount', 'insurance_start_date', 
            'insurance_end_date', 'insurance_renewal_date', 'description',
        ]
    def get_inventory_type(self, obj):
        # If inventory_items is a ForeignKey, access the related object directly
        if obj.inventory_type:
            return obj.inventory_type.name  # Return the name of the related InventoryItem
        return None  # Return None or appropriate value if no related item exists

    def get_inventory_category(self, obj):
        # If inventory_items is a ForeignKey, access the related object directly
        if obj.inventory_category:
            return obj.inventory_category.name  # Return the name of the related InventoryItem
        return None  # Return None or appropriate value if no related item exists
    
    
    def get_inventory_items(self, obj):
        # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
        if obj.inventory_items:
            # If it's a ForeignKey, return the name of the related item
            return obj.inventory_items.name
        return []  # Return an empty list if no related items exist

class MyMachinerySerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    vendor = serializers.StringRelatedField()
    inventory_type = serializers.StringRelatedField()
    inventory_category = serializers.StringRelatedField()
    inventory_items = serializers.SerializerMethodField()
    class Meta:
        model = MyMachinery
        fields = [
            'id','farmer', 'date_of_consumption', 'vendor', 'inventory_type','inventory_items',
            'inventory_category',
            'fuel_capacity', 'purchase_amount', 'warranty_start_date', 
            'warranty_end_date', 'description',
        ]

      
    def get_inventory_type(self, obj):
        # If inventory_items is a ForeignKey, access the related object directly
        if obj.inventory_type:
            return obj.inventory_type.name  # Return the name of the related InventoryItem
        return None  # Return None or appropriate value if no related item exists

    def get_inventory_category(self, obj):
        # If inventory_items is a ForeignKey, access the related object directly
        if obj.inventory_category:
            return obj.inventory_category.name  # Return the name of the related InventoryItem
        return None  # Return None or appropriate value if no related item exists
    
    def get_inventory_items(self, obj):
        # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
        if obj.inventory_items:
            # If it's a ForeignKey, return the name of the related item
            return obj.inventory_items.name
        return []  # Return an empty list if no related items exist
      
class MyToolsSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()  
    vendor = serializers.StringRelatedField()  
    inventory_type = serializers.StringRelatedField() 
    inventory_category = serializers.StringRelatedField() 
    inventory_items = serializers.SerializerMethodField()

    class Meta:
        model = MyTools
        fields = [
            'id', 'farmer', 'date_of_consumption', 'vendor', 'inventory_type',  'inventory_items',
            'inventory_category',  'quantity', 'purchase_amount', 
            'description'
        ]
    def get_inventory_type(self, obj):
        # If inventory_items is a ForeignKey, access the related object directly
        if obj.inventory_type:
            return obj.inventory_type.name  # Return the name of the related InventoryItem
        return None  # Return None or appropriate value if no related item exists

    def get_inventory_category(self, obj):
        # If inventory_items is a ForeignKey, access the related object directly
        if obj.inventory_category:
            return obj.inventory_category.name  # Return the name of the related InventoryItem
        return None  # Return None or appropriate value if no related item exists
    
    def get_inventory_items(self, obj):
        # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
        if obj.inventory_items:
            # If it's a ForeignKey, return the name of the related item
            return obj.inventory_items.name
        return []  # Return an empty list if no related items exist

class MyPesticidesSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    vendor = serializers.StringRelatedField()
    inventory_type = serializers.StringRelatedField()
    inventory_category = serializers.StringRelatedField()
    inventory_items = serializers.SerializerMethodField()
    class Meta:
        model = MyPesticides
        fields = [
            'id', 'farmer', 'date_of_consumption', 'vendor', 'inventory_type',  'inventory_items',
            'inventory_category', 'quantity', 
            'quantity_unit', 'purchase_amount', 'description', 
            
        ]
    def get_inventory_type(self, obj):
        # If inventory_items is a ForeignKey, access the related object directly
        if obj.inventory_type:
            return obj.inventory_type.name  # Return the name of the related InventoryItem
        return None  # Return None or appropriate value if no related item exists

    def get_inventory_category(self, obj):
        # If inventory_items is a ForeignKey, access the related object directly
        if obj.inventory_category:
            return obj.inventory_category.name  # Return the name of the related InventoryItem
        return None  # Return None or appropriate value if no related item exists
    
    
    def get_inventory_items(self, obj):
        # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
        if obj.inventory_items:
            # If it's a ForeignKey, return the name of the related item
            return obj.inventory_items.name
        return []  # Return an empty list if no related items exist

class MyFertilizersSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    vendor = serializers.StringRelatedField()
    inventory_type = serializers.StringRelatedField()
    inventory_category = serializers.StringRelatedField()
    inventory_items = serializers.SerializerMethodField()

    class Meta:
        model = MyFertilizers
        fields = [
            'id', 'farmer', 'date_of_consumption', 'vendor', 'inventory_type',  'inventory_items',
            'inventory_category',  'quantity', 
            'quantity_unit', 'purchase_amount', 'description', 
         
        ]
    def get_inventory_type(self, obj): 
        if obj.inventory_type:
            return obj.inventory_type.name  # Return the name of the related InventoryItem
        return None  # Return None or appropriate value if no related item exists

    def get_inventory_category(self, obj):
        # If inventory_items is a ForeignKey, access the related object directly
        if obj.inventory_category:
            return obj.inventory_category.name  # Return the name of the related InventoryItem
        return None  # Return None or appropriate value if no related item exists
    
    def get_inventory_items(self, obj):
        # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
        if obj.inventory_items:
            # If it's a ForeignKey, return the name of the related item
            return obj.inventory_items.name
        return []  # Return an empty list if no related items exist




class MySeedsSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    vendor = serializers.StringRelatedField()
    inventory_type = serializers.StringRelatedField()
    inventory_category = serializers.StringRelatedField()
    inventory_items = serializers.SerializerMethodField()
    class Meta:
        model = MySeeds
        fields = [
            'id', 'farmer', 'date_of_consumption', 'vendor', 'inventory_type', 'inventory_items',
            'inventory_category', 'quantity', 
            'quantity_unit', 'purchase_amount', 'description', 
           
        ]
    def get_inventory_type(self, obj):
        # If inventory_items is a ForeignKey, access the related object directly
        if obj.inventory_type:
            return obj.inventory_type.name  # Return the name of the related InventoryItem
        return None  # Return None or appropriate value if no related item exists

    def get_inventory_category(self, obj):
        # If inventory_items is a ForeignKey, access the related object directly
        if obj.inventory_category:
            return obj.inventory_category.name  # Return the name of the related InventoryItem
        return None  # Return None or appropriate value if no related item exists
    
    def get_inventory_items(self, obj):
        # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
        if obj.inventory_items:
            # If it's a ForeignKey, return the name of the related item
            return obj.inventory_items.name
        return []  # Return an empty list if no related items exist












class ProductMarketReportSerializer(serializers.ModelSerializer):
    product = serializers.StringRelatedField()  # This will display the product name instead of the ID
    market = serializers.StringRelatedField()  # This will display the market name instead of the ID

    class Meta:
        model = ProductMarketReport
        fields = ['product', 'market', 'available', 'price']


class MyScheduleInsertionSerilaizer(serializers.ModelSerializer):
    class Meta:
        model = MySchedule
        fields = ['id', 'farmer', 'manage_schedule',  'my_crop', 'schedule_activity_type', 
                  'start_date', 'end_date', 'schedule']
 
class MyConsumptionCropsDetailsSerilaizer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    crop = serializers.StringRelatedField()
    land = serializers.StringRelatedField() 

    class Meta:
        model = MyCrop
        fields = [
            'id', 'farmer', 'crop_img', 'land', 'crop'
        ]








































































class MyExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyExpense
        fields = ['my_crop','amount','type_expenses','created_day','description'] 


# class MyFuelSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = MyFuel
#         fields = ['vendor','purchase_amount','inventory_items'] 

# class MyVehicleSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = MyVehicle
#         fields = ['vendor','purchase_amount','inventory_items'] 

# class MyMachinerySerializer(serializers.ModelSerializer):
#     class Meta:
#         model = MyMachinery
#         fields = ['vendor','purchase_amount','inventory_items'] 

# class MyToolsSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = MyTools
#         fields = ['vendor','purchase_amount','inventory_items'] 

# class MyPesticidesSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = MyPesticides
#         fields = ['vendor','purchase_amount','inventory_items'] 

# class MyFertilizersSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = MyFertilizers
#         fields = ['vendor','purchase_amount','inventory_items'] 

# class MySeedsSerializer(serializers.ModelSerializer): 
#     class Meta:
#         model = MySeeds
#         fields = ['vendor','purchase_amount','inventory_items'] 

class MyInventoryItemsSerializer(serializers.ModelSerializer):
    class Meta:
        model = InventoryItems
        fields = ['name','inventory_type'] 

class MyVendorItemsSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyVendor
        fields = ['name','business_name'] 


# class MyFuelDocumentsSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = MyFuelDocuments
#         fields = ['__all__']


class MyVehicleDocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyVehicleDocuments
        fields = ['document', 'file_type', 'status']  # Include the necessary fields

# class MyFuelAddSerializer(serializers.ModelSerializer):

#     class Meta:
#         model = MyFuel
#         fields = '__all__'


class MyFuelAddSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyFuel
        fields = [
            'date_of_consumption',
            'vendor',
            'inventory_type',
            'inventory_items',
            'quantity',
            'purchase_amount',
            'paid_amount',
            'description',  # Optional
            'farmer',       # Provided in view, but needs to be included here
            'created_at',
            'created_by',
            'status',
            'available_quans',
            'identify',
            'translate_json'
        ]
    # Required Fields 
    date_of_consumption = serializers.DateField(required=True)
    vendor = serializers.PrimaryKeyRelatedField(
        queryset=MyVendor.objects.all(),
        required=False,
        allow_null=True
    )
    inventory_type = serializers.PrimaryKeyRelatedField(queryset=InventoryType.objects.all(), required=True)
    inventory_items = serializers.PrimaryKeyRelatedField(queryset=InventoryItems.objects.all(), required=True)
    quantity = serializers.DecimalField(required=True, max_digits=10, decimal_places=2)
    purchase_amount = serializers.DecimalField(required=True, max_digits=10, decimal_places=2)
    paid_amount = serializers.DecimalField(required=True, max_digits=10, decimal_places=2)

    # Optional Fields
    description = serializers.CharField(required=False, allow_blank=True, allow_null=True)


class MyVehicleAddSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyVehicle
        fields = ['__all__'] 


class MyVehicleAddSerializer(serializers.ModelSerializer):
    # documents = MyVehicleDocumentSerializer(many=True, write_only=True)  # Changed to 'documents'
    
    class Meta:
        model = MyVehicle
        fields = '__all__'  # Include all model fields
        # extra_fields = ['documents']  # Include explicitly defined fields

    def create(self, validated_data):
        documents_data = validated_data.pop('documents', [])  # Changed to 'documents'
        vehicle = MyVehicle.objects.create(**validated_data)
        for document_data in documents_data:
            MyVehicleDocuments.objects.create(vehicle=vehicle, **document_data)
        return vehicle
    

class MyMachineryAddSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyMachinery
        fields = '__all__'

class MyToolsAddSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyTools
        fields = '__all__'

class MyPesticidesAddSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyPesticides
        fields = '__all__'


class MyFertilizersAddSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyFertilizers
        fields = '__all__'

class MySeedsAddSerializer(serializers.ModelSerializer):
    class Meta:
        model = MySeeds
        fields = '__all__'




class InventoryItemsSerializer(serializers.ModelSerializer):
    class Meta:
        model = InventoryItems
        fields = '__all__'

class InventoryCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = InventoryCategory
        fields = '__all__'


class ExpensesSerializer(serializers.ModelSerializer):
    class Meta:
        model = Expenses
        fields = '__all__'

# class MyVendorSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = MyVendor
#         fields = ['name','id'] 

# class MyCustomerSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = MyCustomer
#         fields = ['customer_name','id'] 

class CropSerializer(serializers.ModelSerializer):
    class Meta:
        model = Crop
        fields = ['name','id'] 

class AreaUnitSerializer(serializers.ModelSerializer):
    class Meta:
        model = AreaUnit
        fields = ['name','id']

class ManageMarketSerializer(serializers.ModelSerializer):
    class Meta:
        model = ManageMarket
        fields = ['name','id']

class MySalesListSerializer(serializers.ModelSerializer):
    class Meta:
        model = MySales
        fields = '__all__'

class MySalesAddSerializer(serializers.ModelSerializer):
    class Meta:
        model = MySales
        fields = '__all__'


class MySalesSerializer(serializers.ModelSerializer):
    class Meta:
        model = MySales
        fields = '__all__'

        
# class MyCustomerAddSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = MyCustomer
#         fields = '__all__'

class MyCustomerAddSerializer(serializers.ModelSerializer):

    # email = serializers.EmailField(required=True, error_messages={'required': 'Email is required.'})
    market = serializers.PrimaryKeyRelatedField(
        queryset=ManageMarket.objects.all(),
        many=True,
        required=False  # <- This makes it optional
    )

    class Meta:
        model = MyCustomer
        fields = '__all__'

    # def validate_mobile_no(self, value):
    #     if MyCustomer.objects.filter(mobile_no=value).exists():
    #         raise serializers.ValidationError("A customer with this mobile number already exists.")
    #     return value


 

# class MyCustomerAddSerializer(serializers.ModelSerializer):
#     customer_name = serializers.CharField(required=True, error_messages={'required': 'Customer name is required.'})
#     mobile_no = serializers.CharField(required=True, error_messages={'required': 'Mobile number is required.'})
#     email = serializers.EmailField(required=True, error_messages={'required': 'Email is required.'})
#     shop_name = serializers.CharField(required=True, error_messages={'required': 'Shop name is required.'})
#     country = serializers.PrimaryKeyRelatedField(queryset=Country.objects.all(), required=True, error_messages={'required': 'Country is required.'})
#     state = serializers.PrimaryKeyRelatedField(queryset=State.objects.all(), required=True, error_messages={'required': 'State is required.'})
#     city = serializers.PrimaryKeyRelatedField(queryset=City.objects.all(), required=True, error_messages={'required': 'City is required.'})
#     taluk = serializers.PrimaryKeyRelatedField(queryset=Taluk.objects.all(), required=True, error_messages={'required': 'Taluk is required.'})
#     village = serializers.PrimaryKeyRelatedField(queryset=Village.objects.all(), required=True, error_messages={'required': 'Village is required.'})
#     post_code = serializers.IntegerField(required=True, error_messages={'required': 'Pincode is required.'})
#     market = serializers.PrimaryKeyRelatedField(queryset=ManageMarket.objects.all(), many=True, required=True, error_messages={'required': 'Market is required.'})
#     opening_balance = serializers.IntegerField(required=True, error_messages={'required': 'Opening balance is required.'})

#     # If you want to add custom validation, you can do so
#     def validate_mobile_no(self, value):
#         if MyCustomer.objects.filter(mobile_no=value).exists():
#             raise serializers.ValidationError("A customer with this mobile number already exists.")
#         return value

#     class Meta:
#         model = MyCustomer
#         fields = ['customer_name', 'mobile_no', 'email', 'shop_name', 'country', 'state', 'city', 'taluk', 'village', 
#                   'post_code', 'market', 'opening_balance', 'customer_img', 'description', 'status', 'created_by', 'updated_by']

#     # Override `create` or `update` method if needed
#     def create(self, validated_data):
#         markets = validated_data.pop('market', None)  # Get markets if any
#         instance = super().create(validated_data)  # Create the MyCustomer instance

#         if markets:
#             instance.market.set(markets)  # Set the many-to-many relationship

#         return instance

#     def update(self, instance, validated_data):
#         markets = validated_data.pop('market', None)  # Get markets if any
#         instance = super().update(instance, validated_data)  # Update the MyCustomer instance

#         if markets:
#             instance.market.set(markets)  # Set the many-to-many relationship

#         return instance
    

class MyVendorSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyVendor
        fields = '__all__'

    # def validate_mobile_no(self, value):
    #     if MyVendor.objects.filter(mobile_no=value).exists():
    #         raise serializers.ValidationError("A vendor with this mobile number already exists.")
    #     return value

# class DeductionReasonsSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = DeductionReasons
#         fields = '__all__'

class DeductionReasonsSerializer(serializers.ModelSerializer):
    reason = serializers.PrimaryKeyRelatedField(queryset=Reasons.objects.all())
    rupee = serializers.PrimaryKeyRelatedField(queryset=Rupee.objects.all())

    class Meta:
        model = DeductionReasons
        fields = '__all__'

        
class HelpDeskSerializer(serializers.ModelSerializer):
    class Meta:
        model = HelpDesk
        fields = '__all__'  # Include all model fields


class ReasonsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reasons
        fields = ['id', 'name', ]

    def to_representation(self, instance):
        language_code = self.context.get('language_code', 'en')
        representation = super().to_representation(instance)

        # Translate fields using instance.get_translated_value
        representation['name'] = instance.get_translated_value('name', language_code)
        # 'description'
        # representation['description'] = instance.get_translated_value('description', language_code)

        return representation




class FarmerOTPCreatorSerializer(serializers.ModelSerializer):
    class Meta:
        model = FarmerOTP
        fields = ['mobile_number', 'otp']
        read_only_fields = ['otp']

    def create(self, validated_data):
        # Generate a random 4-digit OTP
        import random
        otp = random.randint(1000, 9999)  # Generate 4-digit OTP

        # Store OTP in the FarmerOTP model
        farmer_otp = FarmerOTP.objects.create(
            mobile_number=validated_data['mobile_number'],
            otp=otp
        )
        return farmer_otp
    











 

 

 

# class MyLandSurveyInsertionSerializer(serializers.ModelSerializer):

#     class Meta:
#         model = MyLandSurveyDetails
#         fields = [
#             'id', 'farmer', 'MyLand', 'survey_no', 'survey_measurement_value', 
#             'survey_measurement_unit'
#         ]
 
# class MyLandSurveyDetailsSerializer(serializers.ModelSerializer):
#     farmer = serializers.StringRelatedField()
#     MyLand = serializers.StringRelatedField()
#     survey_measurement_unit = serializers.StringRelatedField()

#     class Meta:
#         model = MyLandSurveyDetails
#         fields = [
#             'id', 'farmer', 'MyLand', 'survey_no', 'survey_measurement_value', 
#             'survey_measurement_unit',
#         ]
 
# class MyLandInsertionSerializer(serializers.ModelSerializer):
#     survey_details = MyLandSurveyDetailsSerializer(many=True, read_only=True)
#     documents = MyLandDocumentSerializer(many=True, read_only=True)

#     class Meta:
#         model = MyLand
#         fields = [
#             'id',
#             'farmer',
#             'name',
#             'measurement_value',
#             'measurement_unit',
#             'soil_type',
#             'country',
#             'state',
#             'city',
#             'taluk',
#             'village',
#             'door_no',
#             'locations',
#             'latitude',
#             'longitude',
#             'patta_number',
#             'description',
#             'l_status',
#             'survey_details',
#             'documents'
#         ]
    
# class MyLandDetailsSerializer(serializers.ModelSerializer):
#     farmer = serializers.StringRelatedField()
#     soil_type = serializers.StringRelatedField()
#     country = serializers.StringRelatedField()
#     state = serializers.StringRelatedField()
#     city = serializers.StringRelatedField()
#     taluk = serializers.StringRelatedField()
#     village = serializers.StringRelatedField()
#     measurement_unit = serializers.StringRelatedField()
#     survey_details = MyLandSurveyDetailsSerializer(many=True, read_only=True)
#     documents = MyLandDocumentSerializer(many=True, read_only=True)

#     class Meta:
#             model = MyLand
#             fields = [
#                 'id',
#                 'farmer',
#                 'name',
#                 'measurement_value',
#                 'measurement_unit',
#                 'soil_type',
#                 'country',
#                 'state',
#                 'city',
#                 'taluk',
#                 'village',
#                 'door_no',
#                 'locations',
#                 'latitude',
#                 'longitude',
#                 'patta_number',
#                 'description',
#                 'l_status',
#                 'survey_details',
#                 'documents'
#             ]
     
class MyLandSurveyInsertionSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyLandSurveyDetails
        fields = ['id', 'farmer', 'MyLand', 'survey_no', 'survey_measurement_value', 'survey_measurement_unit']

    def create(self, validated_data):
        # Ensure proper handling of fields during create
        return MyLandSurveyDetails.objects.create(**validated_data)

    def update(self, instance, validated_data):
        # Ensure proper handling of fields during update
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance

class MyLandSurveyDetailsSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    MyLand = serializers.StringRelatedField()
    survey_measurement_unit = serializers.StringRelatedField()

    class Meta:
        model = MyLandSurveyDetails
        fields = [
            'id', 'farmer', 'MyLand', 'survey_no', 'survey_measurement_value', 
            'survey_measurement_unit',
        ]


class MyLandDocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyLandDocument
        fields = ['id', 'farmer', 'myland', 'document_category', 'upload_document', 'status']

    def create(self, validated_data):
        return MyLandDocument.objects.create(**validated_data)

    def update(self, instance, validated_data):
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance

class MyLandInsertionSerializer(serializers.ModelSerializer):
    survey_details = MyLandSurveyInsertionSerializer(many=True)
    documents = MyLandDocumentSerializer(many=True)

    class Meta:
        model = MyLand
        fields = ['id', 'farmer', 'name', 'measurement_value', 'measurement_unit', 'soil_type', 
                  'country', 'state', 'city', 'taluk', 'village', 'door_no', 'locations', 
                  'latitude', 'longitude', 'patta_number', 'description', 'l_status', 
                  'survey_details', 'documents']

    def create(self, validated_data):
        survey_details_data = validated_data.pop('survey_details', [])
        documents_data = validated_data.pop('documents', [])
        
        # Create the MyLand instance
        myland = MyLand.objects.create(**validated_data)

        # Create nested survey details
        for survey_data in survey_details_data:
            MyLandSurveyDetails.objects.create(MyLand=myland, **survey_data)
        
        # Create nested documents
        for document_data in documents_data:
            MyLandDocument.objects.create(myland=myland, **document_data)
        
        return myland

    def update(self, instance, validated_data):
        survey_details_data = validated_data.pop('survey_details', [])
        documents_data = validated_data.pop('documents', [])
        
        # Update the MyLand instance
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        # Update nested survey details
        for survey_data in survey_details_data:
            survey_instance = MyLandSurveyDetails.objects.get(id=survey_data['id'])
            for attr, value in survey_data.items():
                setattr(survey_instance, attr, value)
            survey_instance.save()

        # Update nested documents
        for document_data in documents_data:
            document_instance = MyLandDocument.objects.get(id=document_data['id'])
            for attr, value in document_data.items():
                setattr(document_instance, attr, value)
            document_instance.save()

        return instance
class MyLandDetailsSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    soil_type = serializers.StringRelatedField()
    country = serializers.StringRelatedField()
    state = serializers.StringRelatedField()
    city = serializers.StringRelatedField()
    taluk = serializers.StringRelatedField()
    village = serializers.StringRelatedField()
    measurement_unit = serializers.StringRelatedField()
    survey_details = MyLandSurveyDetailsSerializer(many=True, read_only=True)
    documents = MyLandDocumentSerializer(many=True, read_only=True)

    class Meta:
        model = MyLand
        fields = [
            'id',
            'farmer',
            'name',
            'measurement_value',
            'measurement_unit',
            'soil_type',
            'country',
            'state',
            'city',
            'taluk',
            'village',
            'door_no',
            'locations',
            'latitude',
            'longitude',
            'patta_number',
            'description',
            'l_status',
            'survey_details',
            'documents'
        ]




# class MyCropInsertionSerializer(serializers.ModelSerializer):
#     # Modify survey_details to accept a list of primary keys (IDs)
#     survey_details = serializers.PrimaryKeyRelatedField(queryset=MyLandSurveyDetails.objects.all(), many=True, required=False)

#     class Meta:
#         model = MyCrop
#         fields = [
#             'crop_type',
#             'crop',
#             'harvesting_type',
#             'plantation_date',
#             'land',
#             'soil_type',
#             'taluk',
#             'village',
#             'measurement_value',
#             'measurement_unit',
#             'geo_marks',
#             'c_status',
#             'expense',
#             'sales',
#             'survey_details',  # Include survey_details as a list of IDs
#             'status',
#             'description',
#             'code',
#             'created_at',
#             'created_by',
#             'updated_at',
#             'updated_by',
#             'geo_marks',
#             'c_status',
#             'expense',
#             'sales',
#             'crop_status'
#         ]

 
# class MyCropInsertionSerializer(serializers.ModelSerializer): 
#     survey_details = serializers.PrimaryKeyRelatedField(queryset=MyLandSurveyDetails.objects.filter(status=0), many=True, required=False)
#     geo_marks = serializers.ListField(
#         child=serializers.ListField(
#             child=serializers.FloatField()
#         )
#     )
#     class Meta:
#         model = MyCrop
#         fields = [
#             'crop_type',
#             'crop',
#             'harvesting_type',
#             'plantation_date',
#             'land',
#             'soil_type',
#             'taluk',
#             'village',
#             'measurement_value',
#             'measurement_unit',
#             'geo_marks',
#             'c_status',
#             'expense',
#             'sales',
#             'survey_details',
#             'status',
#             'description',
#             'code',
#             'created_at',
#             'created_by',
#             'updated_at',
#             'updated_by',
#             'geo_marks',
#             'c_status',
#             'expense',
#             'sales',
#             'crop_status'
#         ]

#     def validate(self, data):
#         # Custom validation for required fields and their types
#         errors = {}

#         required_fields = {
#             'crop_type': 'This field is required.',
#             'crop': 'This field is required.', 
#             'plantation_date': 'This field is required.',
#             'land': 'This field is required.',   
#             'measurement_value': 'This field is required.',
#             'measurement_unit': 'This field is required.',  
#             'survey_details': 'This field is required.',
#             'geo_marks': 'This field is required.'
#         }

#         # Check if required fields are present and validate their types
#         for field, message in required_fields.items():
#             if field not in data or not data.get(field):
#                 errors[field] = message
#             else:
#                 # Check for specific field type validation
#                 if field == 'measurement_value' and not isinstance(data.get('measurement_value'), int):
#                     errors[field] = 'measurement_value should be an integer.'
#                 elif field == 'plantation_date' and not isinstance(data.get('plantation_date'), str):
#                     # Validate plantation_date string format (e.g., "YYYY-MM-DD")
#                     pass
#                 elif field == 'survey_details':
#                     # Check if the provided survey_details are valid
#                     survey_details = data.get('survey_details', [])
#                     invalid_surveys = []
#                     for survey in survey_details:
#                         try:
#                             MyLandSurveyDetails.objects.get(id=survey.id)  # Check if it exists
#                         except MyLandSurveyDetails.DoesNotExist:
#                             invalid_surveys.append(survey.id)

#                     if invalid_surveys:
#                         errors['survey_details'] = f"The following survey details are invalid: {', '.join(map(str, invalid_surveys))}"

#                 elif field == 'geo_marks': 
#                     geo_marks = data.get('geo_marks')
#                     if not isinstance(geo_marks, list):
#                         errors['geo_marks'] = 'geo_marks should be a list.'
#                     elif len(geo_marks) < 3:
#                         errors['geo_marks'] = 'geo_marks must contain at least three coordinate sets.'
#                     else: 
#                         for coords in geo_marks:
#                             if not isinstance(coords, list) or len(coords) < 2:
#                                 errors['geo_marks'] = 'Each coordinate should have at least two values (latitude, longitude).'
#                             else:
#                                 for val in coords:
#                                     if not isinstance(val, (float, int)):
#                                         errors['geo_marks'] = 'Each coordinate should contain valid float or integer values.'   

#         if errors:
#             raise serializers.ValidationError(errors)

#         return data

# class MyCropInsertionSerializer(serializers.ModelSerializer):
#     survey_details = serializers.PrimaryKeyRelatedField(
#         queryset=MyLandSurveyDetails.objects.filter(status=0), 
#         many=True, 
#         required=False
#     )
#     geo_marks = serializers.ListField(
#         child=serializers.ListField(
#             child=serializers.FloatField()
#         )
#     )

#     class Meta:
#         model = MyCrop
#         fields = [
#             'crop_type',
#             'crop',
#             'harvesting_type',
#             'plantation_date',
#             'land',
#             'soil_type',
#             'taluk',
#             'village',
#             'measurement_value',
#             'measurement_unit',
#             'geo_marks',
#             'c_status',
#             'expense',
#             'sales',
#             'survey_details',
#             'status',
#             'description',
#             'code',
#             'created_at',
#             'created_by',
#             'updated_at',
#             'updated_by',
#             'geo_marks',
#             'c_status',
#             'expense',
#             'sales',
#             'crop_status'
#         ]

#     def validate(self, data):
#         errors = {}

#         required_fields = {
#             'crop_type': 'This field is required.',
#             'crop': 'This field is required.',
#             'plantation_date': 'This field is required.',
#             'land': 'This field is required.',
#             'measurement_value': 'This field is required.',
#             'measurement_unit': 'This field is required.',
#             'survey_details': 'This field is required.',
#             'geo_marks': 'This field is required.'
#         }

#         # Check if required fields are present and validate their types
#         for field, message in required_fields.items():
#             if field not in data or not data.get(field):
#                 errors[field] = message
#             else:
#                 if field == 'measurement_value' and not isinstance(data.get('measurement_value'), int):
#                     errors[field] = 'measurement_value should be an integer.'
#                 elif field == 'plantation_date' and not isinstance(data.get('plantation_date'), str):
#                     pass
#                 elif field == 'survey_details':
#                     # Ensure that the provided survey_details are valid
#                     survey_details = data.get('survey_details', [])
#                     invalid_surveys = []
#                     for survey in survey_details:
#                         try:
#                             MyLandSurveyDetails.objects.get(id=survey.id)  # Check if it exists
#                         except MyLandSurveyDetails.DoesNotExist:
#                             invalid_surveys.append(survey.id)

#                     if invalid_surveys:
#                         errors['survey_details'] = f"The following survey details are invalid: {', '.join(map(str, invalid_surveys))}"
#                 elif field == 'geo_marks':
#                     geo_marks = data.get('geo_marks')
#                     if not isinstance(geo_marks, list):
#                         errors['geo_marks'] = 'geo_marks should be a list.'
#                     elif len(geo_marks) < 3:
#                         errors['geo_marks'] = 'geo_marks must contain at least three coordinate sets.'
#                     else:
#                         for coords in geo_marks:
#                             if not isinstance(coords, list) or len(coords) < 2:
#                                 errors['geo_marks'] = 'Each coordinate should have at least two values (latitude, longitude).'
#                             else:
#                                 for val in coords:
#                                     if not isinstance(val, (float, int)):
#                                         errors['geo_marks'] = 'Each coordinate should contain valid float or integer values.'

#         if errors:
#             raise serializers.ValidationError(errors)

#         return data

 
 
class MyCropInsertionSerializer(serializers.ModelSerializer):
    survey_details = serializers.PrimaryKeyRelatedField(
        queryset=MyLandSurveyDetails.objects.filter(status=0), 
        many=True, 
        required=False
    )
    geo_marks = serializers.ListField(
        child=serializers.ListField(
            child=serializers.FloatField()
        )
    )
    new_crop = serializers.CharField(required=False, write_only=True)  # Add this for new crop handling

    class Meta:
        model = MyCrop
        fields = [
            'crop_type',
            'crop',
            'harvesting_type',
            'plantation_date',
            'land',
            'soil_type',
            'taluk',
            'village',
            'measurement_value',
            'measurement_unit',
            'geo_marks',
            'c_status',
            'expense',
            'sales',
            'survey_details',
            'status',
            'description',
            'code',
            'created_at',
            'created_by',
            'updated_at',
            'updated_by',
            'geo_marks',
            'c_status',
            'expense',
            'sales',
            'crop_status',
            'new_crop',  # Add the new crop here to capture from the request
        ]

    def validate(self, data):
        # Additional validation logic if needed
        return data



class MyCropDetailsSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    crop_type = serializers.StringRelatedField()
    crop = serializers.StringRelatedField()
    land = serializers.StringRelatedField()
    harvesting_type = serializers.StringRelatedField()
    soil_type = serializers.StringRelatedField()
    taluk = serializers.StringRelatedField()
    village = serializers.StringRelatedField()
    measurement_unit = serializers.StringRelatedField()
    survey_details = MyLandSurveyDetailsSerializer(many=True, read_only=True)
    days_since_plantation = serializers.SerializerMethodField()

    class Meta:
        model = MyCrop
        fields = [
            'id',
            'farmer',
            'crop_type',
            'crop',
            'harvesting_type',
            'plantation_date',
            'land',
            'soil_type',
            'taluk',
            'village',
            'measurement_value',
            'measurement_unit',
            'geo_marks',
            'c_status',
            'expense',
            'sales',
            'days_since_plantation',
            'survey_details',
        ]

    def get_days_since_plantation(self, obj):
        plantation_date = obj.plantation_date
        if plantation_date:
            today = datetime.now().date()
            days_diff = (today - plantation_date).days
            return days_diff
        return None
    

# class MyInventoryInsertionsSerializer(serializers.ModelSerializer):
  

#     class Meta:
#         model = MyInventory
#         fields = [
#             'id', 'date_of_consumption', 'inventory_type', 'inventory_category','inventory_items', 
#             'available_quans', 'quantity_utilized', 'description',
#             'start_kilometer', 'end_kilometer', 'usage_hours', 'vendor', 'price', 'crop', 'document'
#              # Added fields
#         ]


# class MyInventoryInsertionsSerializer(serializers.ModelSerializer):
#     inventory_category = serializers.SerializerMethodField()
#     inventory_items = serializers.SerializerMethodField()

#     class Meta:
#         model = MyInventory
#         fields = [
#             'id', 'date_of_consumption', 'inventory_type', 'inventory_category', 'inventory_items',
#             'available_quans', 'quantity_utilized', 'description',
#             'start_kilometer', 'end_kilometer', 'usage_hours', 'vendor', 'price', 'crop', 'document',"measurement_type"
#         ]

#     def get_inventory_category(self, obj):
#         # Ensure 'obj' is an individual instance of MyInventory
#         return obj.inventory_category.name if obj.inventory_category else None

#     def get_inventory_items(self, obj):
#         # Ensure 'obj' is an individual instance of MyInventory
#         return obj.inventory_items.name if obj.inventory_items else None

class MyInventoryInsertionsSerializer(serializers.ModelSerializer):
    inventory_category = serializers.PrimaryKeyRelatedField(queryset=InventoryCategory.objects.all(), required=False)
    inventory_items = serializers.PrimaryKeyRelatedField(queryset=InventoryItems.objects.all(), required=False)

    class Meta:
        model = MyInventory
        fields = [
            'id', 'date_of_consumption', 'inventory_type', 'inventory_category', 'inventory_items',
            'available_quans', 'quantity_utilized', 'description',
            'start_kilometer', 'end_kilometer', 'usage_hours', 'crop'
        ]

    def to_representation(self, instance):
        # Override the to_representation method to convert empty fields to ""
        representation = super().to_representation(instance)

        # Loop through each field in the representation and check if it's None
        for field, value in representation.items():
            if value is None:
                representation[field] = ""  # Replace None with an empty string

        return representation



   

class MyInventoryDetailsSerializer(serializers.ModelSerializer):
    crop = MyCropDetailsSerializer()  # Use MyCropSerializer for crop details
    inventory_type = serializers.SerializerMethodField()  # Use a method to get inventory type name
    inventory_category = serializers.SerializerMethodField()  
    inventory_items = serializers.SerializerMethodField()# Use a method to get inventory category name
    vendor = serializers.SerializerMethodField()  # Static vendor field (name)
    price = serializers.SerializerMethodField()  # Static purchase amount field (price)

    class Meta:
        model = MyInventory
        fields = [
            'id', 'date_of_consumption', 'inventory_type', 'inventory_category','inventory_items', 
            'available_quans', 'quantity_utilized', 'description',
            'start_kilometer', 'end_kilometer', 'usage_hours', 'vendor', 'price', 'crop', 'document'
             # Added fields
        ]

    def get_inventory_type(self, obj):
        # Return the name of the related InventoryType
        if obj.inventory_type:
            return obj.inventory_type.name
        return None

    def get_inventory_category(self, obj):
        # Return the name of the related InventoryCategory
        if obj.inventory_category:
            return obj.inventory_category.name
        return None

    def get_vendor(self, obj):
        # Assuming vendor details are stored in a related model
        vendor = obj.vendor  # Assuming there's a `vendor` field in `MyInventory`
        if vendor:
            return vendor.name  # Assuming the `vendor` model has a `name` field
        return "Dinesh"  # Default value if no vendor found

    def get_price(self, obj):
        # Assuming the `purchase_amount` field in MyInventory has a `price`
        return obj.price if obj.price else 15000.0  # Retur

    def get_inventory_type(self, obj):
        # If inventory_type is a ForeignKey, return the name of the related InventoryType
        if obj.inventory_type:
            return obj.inventory_type.name  # Return the name of the related InventoryType
        return None  # Return None if no related InventoryType exists

    def get_inventory_category(self, obj):
        # If inventory_category is a ForeignKey, return the name of the related InventoryCategory
        if obj.inventory_category:
            return obj.inventory_category.name  # Return the name of the related InventoryCategory
        return None  # Return None if no related InventoryCategory exists

    def get_inventory_items(self, obj):
        # If inventory_items is a ForeignKey or ManyToManyField, handle accordingly
        if obj.inventory_items:
            # If it's a ForeignKey, return the name of the related item
            return obj.inventory_items.name
        return []  # Return an empty list if no related items exist


 
class MyScheduleInsertionSerializer(serializers.ModelSerializer):
    # end_date = serializers.DateField(
    #     required=False,  # Not required
    #     allow_null=True,  # Can be null (equivalent to None in Python)
    #     input_formats=['%Y-%m-%d'],  # Valid date format
    #     default=None,  # Default to None if not provided
    # )

    class Meta:
        model = MySchedule
        fields = [
            'farmer', 
            'my_crop',
            'schedule_activity_type',
            'start_date',
            # 'end_date',
            'schedule_status',  
            'schedule',
        ]

    # def validate_end_date(self, value):
    #     # If the value is an empty string, return None (null)
    #     if value == "":
    #         return None
    #     return value


# class MyScheduleDetailsSerializer(serializers.ModelSerializer):
#     farmer = serializers.StringRelatedField()
#     manage_schedule = serializers.StringRelatedField()
#     my_land = serializers.StringRelatedField()
#     my_crop = serializers.StringRelatedField()
#     schedule_activity_type = serializers.StringRelatedField()
#     schedule_status = serializers.StringRelatedField()

#     class Meta:
#         model = MySchedule
#         fields = ['id', 'farmer', 'manage_schedule', 'my_land', 'my_crop', 'schedule_activity_type', 
#                   'start_date', 'end_date', 'schedule_status', 'schedule']

    

# class MyScheduleDetailsSerializer(serializers.ModelSerializer):
#     farmer = serializers.StringRelatedField()
#     # Safely access 'my_land.id' using getattr to handle None
#     my_land_id = serializers.SerializerMethodField()
#     my_land = serializers.SerializerMethodField()  # Get 'my_land' name

#     my_crop_id = serializers.IntegerField(source='my_crop.id')   
#     my_crop = serializers.SerializerMethodField()  
#     schedule_activity_id = serializers.IntegerField(source='schedule_activity_type.id')  
#     schedule_activity_type = serializers.CharField(source='schedule_activity_type.name')   
#     schedule_status = serializers.StringRelatedField()   

#     class Meta:
#         model = MySchedule
#         fields = [
#             'id',
#             'farmer',
#             'my_land_id',
#             'my_land',
#             'my_crop_id',
#             'my_crop',
#             'schedule_activity_id',
#             'schedule_activity_type',
#             'start_date',
#             'end_date',
#             'schedule_status',
#             'status',
#             'schedule',
#             'comment'
#         ]
    
#     def get_my_land_id(self, obj):
#         # Return None if my_land is None, otherwise return its ID
#         return getattr(obj.my_land, 'id', '')
    
#     def get_my_land(self, obj):
#         # Return name if my_land is not None, otherwise return an empty string
#         return getattr(obj.my_land, 'name', '')

#     def get_my_crop(self, obj):
#         # Access both my_land and my_crop safely
#         return f"{obj.my_crop.crop}" if obj.my_crop else ''

class MyScheduleDetailsSerializer(serializers.ModelSerializer):
    farmer = serializers.StringRelatedField()
    # Safely access 'my_land.id' using getattr to handle None
    my_land_id = serializers.SerializerMethodField()
    my_land = serializers.SerializerMethodField()  # Get 'my_land' name

    my_crop_id = serializers.IntegerField(source='my_crop.id')   
    my_crop = serializers.SerializerMethodField()  
    schedule_activity_id = serializers.IntegerField(source='schedule_activity_type.id')  
    schedule_activity_type = serializers.CharField(source='schedule_activity_type.name')   
    schedule_status = serializers.StringRelatedField()   

    class Meta:
        model = MySchedule
        fields = [
            'id',
            'farmer',
            'my_land_id',
            'my_land',
            'my_crop_id',
            'my_crop',
            'schedule_activity_id',
            'schedule_activity_type',
            'start_date',
            'end_date',
            'schedule_status',
            'status',
            'schedule',
            'comment'
        ]
    
    def get_my_land_id(self, obj):
        # Return None if my_land is None, otherwise return its ID
        return getattr(obj.my_land, 'id', '')
    
    def get_my_land(self, obj):
        # Return name if my_land is not None, otherwise return an empty string
        return getattr(obj.my_land, 'name', '')

    def get_my_crop(self, obj):
        # Access both my_land and my_crop safely
        return f"{obj.my_crop.crop}" if obj.my_crop else ''

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        language_code = self.context.get('language_code', 'en')

        if instance.schedule_activity_type:
            representation['schedule_activity_type'] = instance.schedule_activity_type.get_translated_value('name', language_code)

        if instance.my_land:
            representation['my_land'] = instance.my_land.get_translated_value('name', language_code)

        if instance.schedule:
            # Optional: if you want to translate the schedule field
            translated = instance.get_translated_value('schedule', language_code)
            representation['schedule'] = translated

        return representation 

class SalesDocumentSerializer(serializers.ModelSerializer):
    file_upload = serializers.FileField(required=False)  # Optional, since the file can be empty if updating without a new file

    class Meta:
        model = SalesDocument
        fields = ['id', 'farmer', 'my_sales', 'document_category', 'file_upload', 'created_by', 'updated_by', 'created_at', 'updated_at']

    def create(self, validated_data):
        # If file_upload is not provided, remove it from validated data
        file = validated_data.pop('file_upload', None)
        
        # Create the SalesDocument instance
        sales_document = SalesDocument.objects.create(**validated_data)
        
        # If a file is provided, handle the file upload
        if file:
            sales_document.file_upload = file
            sales_document.save()
        
        return sales_document

    def update(self, instance, validated_data):
        # If file_upload is not provided, remove it from validated data
        file = validated_data.pop('file_upload', None)
        
        # Update the instance fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        
        # If a file is provided, update the file
        if file:
            instance.file_upload = file
        
        instance.save()
        return instance
 
 



def ExpneseSerializeRecord(record, language_code, date_field, extra_fields=None):
    """
    Generic serializer for inventory/expense/sales records.
    """
    data = {
        "id": record.id,
        "date": record.__dict__.get(date_field).strftime('%d-%m-%Y') if getattr(record, date_field, None) else "",
        "vendor": {
            "id": record.vendor.id if getattr(record, "vendor", None) else "",
            "name": record.vendor.get_translated_value("name", language_code) if getattr(record, "vendor", None) else ""
        } if hasattr(record, "vendor") else {},
        "item": {
            "id": record.inventory_items.id if getattr(record, "inventory_items", None) else getattr(record, "my_crop", None).id if getattr(record, "my_crop", None) else "",
            "name": (
                record.inventory_items.get_translated_value("name", language_code)
                if getattr(record, "inventory_items", None)
                else record.my_crop.crop.get_translated_value("name", language_code)
                if getattr(record, "my_crop", None)
                else ""
            ),
        } if hasattr(record, "inventory_items") or hasattr(record, "my_crop") else {},
        "amount": str(getattr(record, "purchase_amount", getattr(record, "amount", getattr(record, "total_sales_amount", "")))),
    }

    # Merge extra fields if given
    if extra_fields:
        data.update(extra_fields)

    return data


class EmployeeSerializer(serializers.ModelSerializer):
    employee_type_name = serializers.CharField(source="employee_type.name", read_only=True)
    work_type_name = serializers.CharField(source="work_type.name", read_only=True)  # optional if you also want work_type name

    class Meta:
        model = Employee
        fields = [
            "id", "name", "mobile_no",
            "employee_type", "employee_type_name",   # both id + name
            "work_type", "work_type_name",           # both id + name
            "status", "door_no"
        ]

class ManagerSerializer(serializers.ModelSerializer):
    employee_type_name = serializers.CharField(source="employee_type.name", read_only=True)
    role_name = serializers.CharField(source="role.name", read_only=True)

    class Meta:
        model = ManagerUser
        fields = [
            "id", "name", "mobile_no", "email", "address",
            "employee_type", "employee_type_name",
            "role", "role_name"
        ]
