from django.db import models
from django.forms import ValidationError
from django.contrib.auth.models import User
from django.db.utils import IntegrityError
import random
import string
from django.db.models.signals import post_save, pre_save
from django.dispatch import receiver
from datetime import date, datetime
from auth.models import *
from datetime import timedelta
from dateutil.relativedelta import relativedelta
from django.utils import timezone
import calendar
from django.db.models import Sum
from django.shortcuts import get_object_or_404
from django.views import View
from django.db.models import Sum
from django.utils import timezone
from datetime import timedelta
import calendar 
import json
from django.conf import settings
from django.contrib.auth import get_user_model 
from .models import * 
from django.utils.text import slugify
import os 
# ---------------------------------------> Settings:

class Country(models.Model):
    name = models.CharField(max_length=50)
    status = models.IntegerField(default=0,null=True,blank=True)  
    translate_json = models.JSONField(null=True, blank=True)
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='country_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)  

    def __str__(self):
        return self.name 
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    
class State(models.Model):
    name = models.CharField(max_length=50)
    country = models.ForeignKey(Country, on_delete=models.CASCADE,null=True,blank=True)
    translate_json = models.JSONField(null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='state_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    
class City(models.Model):
    name = models.CharField(max_length=50)
    country = models.ForeignKey(Country, on_delete=models.CASCADE,null=True,blank=True)
    state = models.ForeignKey(State,on_delete=models.CASCADE,null=True,blank=True)
    translate_json = models.JSONField(null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='city_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    
class Taluk(models.Model):
    name = models.CharField(max_length=50)
    country = models.ForeignKey(Country, on_delete=models.CASCADE,null=True,blank=True)
    state = models.ForeignKey(State,on_delete=models.CASCADE,null=True,blank=True)
    city = models.ForeignKey(City,on_delete=models.CASCADE,null=True,blank=True)
    translate_json = models.JSONField(null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='taluk_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    
class Village(models.Model):
    name = models.CharField(max_length=50)
    country = models.ForeignKey(Country, on_delete=models.CASCADE,null=True,blank=True)
    state = models.ForeignKey(State,on_delete=models.CASCADE,null=True,blank=True)
    city = models.ForeignKey(City,on_delete=models.CASCADE,null=True,blank=True)
    taluk = models.ForeignKey(Taluk,on_delete=models.CASCADE,null=True,blank=True)
    translate_json = models.JSONField(null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='village_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class EmailTemplate(models.Model):
    email_template_name = models.CharField(max_length=100)
    email_subject = models.CharField(max_length=200,null=True,blank=True) 
    email_template_content = models.TextField(null=True,blank=True)
    code = models.IntegerField(default=0,null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='emailtemp_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    
    def __str__(self):
        return self.email_template_name

class EmailConfig(models.Model):
    email = models.EmailField(null=True,blank=True)
    username = models.CharField(max_length=255,null=True,blank=True)
    password = models.CharField(max_length=255,null=True,blank=True)
    port = models.CharField(max_length=255,null=True,blank=True)
    smtp = models.CharField(max_length=255,null=True,blank=True)
    host = models.CharField(max_length=255,null=True,blank=True)
    mail_content = models.CharField(max_length=255,null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='email_config_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return self.email

class SMSConfig(models.Model):
    sms_Template = models.CharField(max_length=255 ,null=True,blank=True)
    Template_id = models.IntegerField(null=True,blank=True)
    sms_type = models.IntegerField(null=True,blank=True)
    sender_id = models.CharField(max_length=255,null=True,blank=True)
    DLT_TE_ID = models.CharField(max_length=255,null=True,blank=True)
    country_code = models.IntegerField(null=True,blank=True)
    api_key = models.CharField(max_length=255,null=True,blank=True)
    message_content = models.CharField(max_length=255,null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='sms_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return self.sms_Template

class GeneralSetting(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    logo = models.ImageField(upload_to='upload/GeneralSettings',null=True,blank=True)
    favicon = models.ImageField(upload_to='upload/GeneralSettings',null=True,blank=True)
    title = models.CharField(max_length=200, null=True,blank=True)
    website = models.CharField(max_length=250,null=True,blank=True)
    contact_person_name = models.CharField(max_length=100, null=True,blank=True)
    personal_email = models.EmailField(null=True,blank=True)
    date_format = models.CharField(max_length=20,null=True,blank=True)
    time_format = models.CharField(max_length=250,null=True,blank=True)
    country = models.ForeignKey(Country, on_delete=models.CASCADE, null=True, blank=True)
    state = models.ForeignKey(State, on_delete=models.CASCADE, null=True, blank=True)
    city = models.ForeignKey(City, on_delete=models.CASCADE, null=True, blank=True)
    area_street = models.CharField(max_length=200, null=True,blank=True)
    flat_no = models.CharField(max_length=200, null=True,blank=True)
    pincode = models.IntegerField(null=True,blank=True)
    cgst = models.DecimalField(max_digits=5, decimal_places=2,null=True,blank=True)
    sgst = models.DecimalField(max_digits=5, decimal_places=2,null=True,blank=True) 
    gst_number = models.CharField(max_length=200, null=True,blank=True)
    cin = models.CharField(max_length=250, null=True,blank=True)
    weather_api_key = models.CharField(max_length=250,null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='gs_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='gs_updated_by')
    address = models.CharField(max_length=200, null=True, blank=True)
    locations = models.CharField(max_length=200, null=True, blank=True) #OK
    latitude = models.FloatField(null=True, blank=True)  #(Mob) (pass from web)
    longitude = models.FloatField(null=True, blank=True) #(Mob) (pass from web)

    def __str__(self):
        return f"{self.user} - {self.title}"

class Notification(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null = True,blank=True)
    name = models.CharField(max_length=255, null=True, blank=True)
    image = models.ImageField(upload_to='upload/Notification',null=True,blank=True)
    message = models.CharField(max_length=255, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)

    def __str__(self):
        return self.message

class Languages(models.Model):
    name = models.CharField(max_length=50)
    language_code = models.CharField(max_length=10)
    status = models.IntegerField(default=0,null=True,blank=True)
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='language_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)  

# --------------------------------------------> Data Management

class CropType(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='crop_type_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class Crop(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(null=True,blank=True)
    croptype = models.ForeignKey(CropType, on_delete=models.CASCADE,null=True,blank=True,related_name='crops')
    img = models.ImageField(upload_to='media/crop/', null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='crop_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class SoilType(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='soil_type_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class Unit(models.Model):
    name = models.CharField(max_length=50)
    unitdef = models.CharField(max_length=150)
    description = models.TextField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)   
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='unit_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.name
    
class AreaUnit(models.Model):
    name = models.CharField(max_length=50)
    areaunitdef = models.CharField(max_length=150)
    description = models.TextField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='areaunit_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        if field_name == 'areaunitdef' or 'slug_name' in self.translate_json:
            return self.translate_json['slug_name'].get(language_code, getattr(self, 'name'))
        return getattr(self, field_name)
    
class ProductType(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='product_type_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class Schedule(models.Model):
    crop = models.ForeignKey(Crop, on_delete=models.CASCADE,null=True,blank=True)
    days = models.IntegerField(null=True,blank=True)
    activity_type = models.ForeignKey('ScheduleActivityType', on_delete=models.CASCADE,null=True,blank=True)
    description = models.TextField(blank=True, null=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='shedule_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)
 
    def __str__(self):
        return f"{self.crop} - {self.activity_type} ({self.days} days)"
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
 
    


class EmployeeType(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    code = models.IntegerField(null=True, blank=True) 
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='emp_type_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class LandUnit(models.Model):
    name = models.CharField(max_length=50)
    landunitdef = models.CharField(max_length=150)
    description = models.TextField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='land_unit_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    factor_to_sq_m = models.FloatField(default=0)
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        # if field_name == 'landunitdef' and 'slug_name' in self.translate_json:
            # return self.translate_json['slug_name'].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    
class Quality(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='quality_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.name
    
class ExpensesCategory(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='expenses_category_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    
class Expenses(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(null=True,blank=True)
    expenses_category = models.ForeignKey(ExpensesCategory, on_delete=models.CASCADE, blank=True, null=True) 
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='exp_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
  
class InventoryType(models.Model):
    name = models.CharField(max_length=200)
    code = models.IntegerField(null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.CharField(max_length=200,null=True,blank=True)
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.CharField(max_length=200,null=True,blank=True)
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class InventoryCategory(models.Model):
    name = models.CharField(max_length=200)
    inventory_type = models.ForeignKey(InventoryType, null=True, blank=True, on_delete=models.CASCADE)
    code = models.IntegerField(null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    description = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='inventory_category')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    
class InventoryItems(models.Model):
    name = models.CharField(max_length=200)
    inventory_type = models.ForeignKey(InventoryType, null=True, blank=True, on_delete=models.CASCADE)
    inventory_category = models.ForeignKey(InventoryCategory, null=True, blank=True, on_delete=models.CASCADE)
    code = models.IntegerField(null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    description = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='inventory_items')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)  
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name  
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
 


class HarvestingType(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='harvest_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class ScheduleActivityType(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(null=True,blank=True) 
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='shedule_act_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class Detection(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='deduction_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class DocumentCategory(models.Model):
    name = models.CharField(max_length=50)
    doctype = models.IntegerField(null=True,blank=True)
    description = models.TextField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)   
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='document_category_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self): 
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class NearByLocationCategory(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='nearby_category_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)
    
    def __str__(self):
        return self.name

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    
class WorkersType(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='wrk_type_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class GuidelinesCategory(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='guideline_categ_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    

# -------------------------- User Language Preference ------------------------------
class UserLanguagePreference(models.Model):
    user = models.ForeignKey('Farmer', on_delete=models.CASCADE, null=True, blank=True)
    language_name = models.CharField(max_length=100,null=True, blank=True)
    language_code = models.CharField(max_length=50,null=True, blank=True)
    status = models.IntegerField(default=0, null=True, blank=True)
    created_at = models.DateTimeField(null=True, blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)

# ---------------------------------------------------------------> Farmer Management

class FarmerType(models.Model):
    name = models.CharField(max_length=200)
    code = models.IntegerField(null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='farmer_type_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.name

def farmer_image_upload_to(instance, filename):
    # Safely generate the filename, using the farmer's ID and name
    farmer_id = instance.id if instance.id else 'new_farmer'  # In case the farmer is not saved yet
    farmer_name = slugify(instance.name) if instance.name else 'no_name'
    
    # Construct the file name and path
    return os.path.join('farmer_img', f"{farmer_id}_{farmer_name}_{filename}")

class Farmer(models.Model):
    farmertype = models.ForeignKey('FarmerType', on_delete=models.CASCADE, null=True, blank=True)
    name = models.CharField(max_length=200,null=True,blank=True)
    phone = models.CharField(max_length=15) 
    email = models.EmailField(null=True, blank=True)
    country = models.ForeignKey('Country',on_delete=models.CASCADE,null=True, blank= True)
    state = models.ForeignKey('State', on_delete=models.CASCADE,null=True,blank=True) 
    city = models.ForeignKey('City', on_delete=models.CASCADE, null=True, blank=True)
    taluk = models.ForeignKey('Taluk', on_delete=models.CASCADE, null=True, blank=True)
    village = models.ForeignKey('Village', on_delete=models.CASCADE, null=True, blank=True)
    door_no = models.CharField(max_length=200, null=True, blank=True)
    pincode = models.IntegerField(default=0, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    img = models.ImageField(upload_to=farmer_image_upload_to, null=True, blank=True)
    status = models.IntegerField(default=0, null=True, blank=True)
    created_at = models.DateTimeField(null=True, blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='farmer_created_by')
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    company_name = models.CharField(max_length=200, null=True, blank=True)
    tax_no = models.CharField(max_length=50, null=True, blank=True)
    username = models.CharField(max_length=150, null=True, blank=True)
    password = models.CharField(max_length=150, null=True, blank=True)
    sub_admin_username = models.CharField(max_length=150, null=True, blank=True)
    sub_admin_password = models.CharField(max_length=150, null=True, blank=True)
    farmer = models.BooleanField(default=True)
    farmer_user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='farmer_profile', null=True, blank=True)
    # sub_admin_user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='sub_admin_profile', null=True, blank=True)
    subscription_package = models.ForeignKey('PackageManagement', on_delete=models.CASCADE, null=True, blank=True)
    subscription_end_date = models.DateField(null=True, blank=True)
    subscription_start_date = models.DateField(null=True, blank=True)
    remaining_days = models.IntegerField(null=True, blank=True)
    amounts = models.IntegerField(default=0, null=True, blank = True) 
    sub_amounts = models.IntegerField(default=0, null=True, blank = True)
    # add_on_details = models.ManyToManyField('AddOnDetails', blank=True)
    refresh_token = models.TextField(null=True, blank=True)  
    # expiry = models.DateTimeField(null=True, blank=True)
    translate_json = models.JSONField(null=True, blank=True)
    fcm_token = models.CharField(max_length=255, null=True, blank=True)
    google_login = models.BooleanField(default=False, null=True, blank=True)
    locations = models.CharField(max_length=250, null=True, blank=True) #OK
    latitude = models.FloatField(null=True, blank=True)  #(Mob) (pass from web)
    longitude = models.FloatField(null=True, blank=True) #(Mob) (pass from web)

    # def __str__(self):
    #     return self.name

    def __str__(self):
        if self.name:
            return self.name
        return f"Farmer #{self.pk}"


    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

    @property
    def subscription_details(self):
        subscription = AddSubcription.objects.filter(farmers=self).last()
        if subscription:
            expired = self.is_subscription_expired
            subscription_status = "Expired" if expired else "Active"
            return {
                'package_name': subscription.packages.name,
                'package_duration': subscription.packages.package_duration.name,
                'validity': subscription.packages.package_validity,
                'start_date': subscription.startdate,
                'end_date': subscription.enddate,
                'remaining_days': subscription.remainingdays,
                'amount': subscription.amount,
                'sub_amount': subscription.sub_amount,
                'status': subscription_status,
                'created_at': subscription.created_at,
                'myland_count': subscription.packages.myland_count,
                'mycrops_count': subscription.packages.mycrops_count,
                'myexpense_count': subscription.packages.myexpense_count,
                'mysale_count': subscription.packages.mysale_count,
                'customer_count': subscription.packages.customer_count, 
                'myvechicle_count': subscription.packages.myvechicle_count, 
                'mymachinery_count': subscription.packages.mymachinery_count, 
                'mytools_count': subscription.packages.mytools_count, 
                'myinventory_products': subscription.packages.myinventory_products,
                'myinventory_purchase': subscription.packages.myinventory_purchase,
                'myinventory_vendors': subscription.packages.myinventory_vendors, 
                'employee_count': subscription.packages.employee_count,
                'is_payouts': subscription.packages.is_payouts,
                'is_widget': subscription.packages.is_widget,
                'farmer_manager_count': subscription.packages.farmer_manager_count,
            }
        return None

    @property
    def active_subscription(self): 
        return AddSubcription.objects.filter(farmers=self, status=0).last()

    @property
    def is_subscription_expired(self): 
        active_subscription = self.active_subscription
        if active_subscription:
            if active_subscription.remainingdays == 0:
                self.status = 4
                self.save()
                active_subscription.status = 4
                active_subscription.save()
                return False
        return False

    def create_or_update_farmer_report(self): 
        subscription = self.active_subscription

        if subscription:
            subscription_details = {
                'package_name': subscription.packages.name,
                # 'package_duration': subscription.packages.package_duration.name,
                'validity': subscription.packages.package_validity,
                'start_date': subscription.startdate.isoformat() if isinstance(subscription.startdate, (datetime, date)) else subscription.startdate,
                'end_date': subscription.enddate.isoformat() if isinstance(subscription.enddate, (datetime, date)) else subscription.enddate,
                'remaining_days': subscription.remainingdays,
                'amount': subscription.amount,
                'sub_amount': subscription.sub_amount,
                # 'add_on_details': [add_on.name for add_on in subscription.packages.add_on_details.all()],
                'status': "Expired" if subscription.remainingdays == 0 else "Active"
            }
        else:
            subscription_details = None

        farmer_report, created = FarmerReport.objects.get_or_create(farmer=self)
        farmer_report.subscription_details = subscription_details
        farmer_report.save()

 

    @property
    def sub_amount(self): 
        subscription = self.active_subscription
        if subscription:
            return subscription.sub_amount
        return None

    @property
    def amount(self): 
        subscription = self.active_subscription
        if subscription:
            return subscription.amount
        return None
 

 
    def create_user(self):
        """
        Create a CustomUser for this Farmer.
        Uses phone if available, otherwise generates a dummy unique phone based on timestamp.
        """
        if not self.phone:
            # Generate a unique placeholder phone_number without '999' prefix
            self.phone = str(int(timezone.now().timestamp()))[:50]  # max length 50

        phone_number = self.phone.strip()
        email = self.email.strip().lower() if self.email else None

        # Ensure unique phone number
        base_phone = phone_number
        while CustomUser.objects.filter(phone_number=phone_number).exists():
            random_suffix = ''.join(random.choices(string.ascii_lowercase + string.digits, k=6))
            phone_number = f"{base_phone[:44]}{random_suffix}"  # 50 chars max

        # Password fallback
        password = self.phone or "defaultpassword123"

        # Create the user
        user = CustomUser.objects.create_user(
            phone_number=phone_number,
            email=email,
            password=password,
            name=self.name
        )

        user.is_active = True
        user.farmer_user = True
        if self.img:
            user.image = self.img
        user.save()
        return user


    def save(self, *args, **kwargs):
        if self.subscription_end_date:
            today = date.today()
            remaining_days = (self.subscription_end_date - today).days
            self.remaining_days = max(remaining_days, 0)

        # Farmer type validation
        if self.farmertype and self.farmertype.code == 1:
            if not self.company_name:
                raise ValueError("Company name must be provided for Company farmers.")
            if not self.tax_no:
                raise ValueError("Tax number must be provided for Company farmers.")

        elif self.farmertype and self.farmertype.code == 0:
            pass  

    

        # Ensure sub-admin user is created
        if not self.farmer_user:
            user = self.create_user()
            self.farmer_user = user 
            self.phone_number = user.phone_number
            self.password = self.phone  
            if not self.username:
                self.username = user.phone_number  

        super(Farmer, self).save(*args, **kwargs)

        # Update farmer report
        self.create_or_update_farmer_report()


# -----------------------------------------------------> Package Management

class Duration(models.Model):
    name = models.CharField(max_length=200)
    code = models.IntegerField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='duration_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
   
class PackageManagement(models.Model): 
    name = models.CharField(max_length=200)
    code = models.IntegerField(null=True,blank=True)
    package_validity = models.IntegerField(null=True,blank=True)
    package_duration = models.ForeignKey(Duration,null=True,blank=True,on_delete=models.CASCADE)
    # add_on_details = models.ManyToManyField(AddOnDetails,related_name='packages')
    amount = models.IntegerField(default=0, null=True, blank = True)
    offer = models.BooleanField(default=0,null=True,blank=True)
    percentage = models.IntegerField(default=0, null=True, blank = True)
    sub_amount = models.IntegerField(default=0, null=True, blank = True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    myland_count = models.IntegerField(default=0,null=True,blank=True)
    mycrops_count = models.IntegerField(default=0,null=True,blank=True)
    myexpense_count = models.IntegerField(default=0,null=True,blank=True)
    mysale_count = models.IntegerField(default=0,null=True,blank=True)
    customer_count = models.IntegerField(default=0,null=True,blank=True)
    is_myfuel = models.BooleanField(default=False)
    myfuel_count = models.IntegerField(default=0,null=True,blank=True)
    is_myvechicle = models.BooleanField(default=False)
    myvechicle_count = models.IntegerField(default=0,null=True,blank=True)
    is_mymachinery = models.BooleanField(default=False)
    mymachinery_count = models.IntegerField(default=0,null=True,blank=True)
    is_mytools = models.BooleanField(default=False)
    mytools_count = models.IntegerField(default=0,null=True,blank=True)
    is_mypesticides = models.BooleanField(default=False)
    mypesticides_count = models.IntegerField(default=0,null=True,blank=True)
    is_myfertilizers = models.BooleanField(default=False)
    myfertilizers_count = models.IntegerField(default=0,null=True,blank=True)
    is_myseeds = models.BooleanField(default=False)
    myseeds_count = models.IntegerField(default=0,null=True,blank=True)
    is_myinventory = models.BooleanField(default=False)
    myinventory_products = models.IntegerField(default=0,null=True,blank=True)
    myinventory_purchase = models.IntegerField(default=0,null=True,blank=True)
    myinventory_vendors = models.IntegerField(default=0,null=True,blank=True) 
    is_attendance = models.BooleanField(default=False)
    employee_count = models.IntegerField(default=0,null=True,blank=True)
    is_payouts = models.BooleanField(default=False)
    is_widget = models.BooleanField(default=False)
    farmer_manager_count = models.IntegerField(default=0,null=True,blank=True)
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='package_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    # def get_add_ons(self):
    #     return self.add_on_details.all()

    def __str__(self):
        return f"{self.name} (Validity: {self.package_validity} {self.package_duration.name}, Amount: {self.sub_amount}, Ends on: {self.calculate_end_date() if self.calculate_end_date() else 'Lifetime'})"

    def save(self, *args, **kwargs):
        if self.offer and self.percentage is not None:
            discount = (self.amount * self.percentage) / 100
            self.sub_amount = self.amount - discount  
        else:
            self.sub_amount = self.amount  
        
        super().save(*args, **kwargs)  

    def calculate_end_date(self):
        if self.package_duration and self.package_validity:
            current_date = timezone.now()

            if self.package_duration.code == 0:  
                return current_date + timedelta(days=self.package_validity)
            elif self.package_duration.code == 1:  
                return current_date + timedelta(days=30 * self.package_validity)  
            elif self.package_duration.code == 2:  
                return current_date + timedelta(days=365 * self.package_validity)  
            elif self.package_duration.code == 3: 
                return None  

        return None  

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
 

# ------------------------------------------> Subcription Management 

class AddSubcription(models.Model): 
    farmers = models.ForeignKey(Farmer,on_delete=models.CASCADE,null=True,blank=True,related_name='subscriptions')
    packages = models.ForeignKey(PackageManagement,on_delete=models.CASCADE,null=True,blank=True)
    startdate =models.DateField(null=True,blank=True)
    enddate = models.DateField(null=True,blank=True)
    remainingdays = models.IntegerField(null =True,blank=True)
    renewal = models.BooleanField(default=False) 
    payment_mode = models.IntegerField(null=True, blank=True)
    payment_status = models.IntegerField(null=True, blank=True)
    transaction_id = models.CharField(null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='subscrib_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    @property
    def package_subamount(self):
        return self.packages.sub_amount if self.packages else 0

    @property
    def package_name(self):
        return self.packages.name if self.packages else "No Package"

    @property
    def package_duration(self):
        return self.packages.package_duration.name if self.packages else "N/A"

    @property
    def package_validity(self):
        return self.packages.package_validity if self.packages else "N/A"


    def renew_subscription(self,package_id, user): 
        package = get_object_or_404(PackageManagement,id=package_id)
        package_validity = package.package_validity
        package_duration_code = package.package_duration.code
         

        startdate = timezone.now().date() 
        if package_duration_code == 0:  # Days
            enddate = startdate + timedelta(days=package_validity)
        elif package_duration_code == 1:  # Months
            enddate = startdate + relativedelta(months=package_validity)
        elif package_duration_code == 2:  # Years
            enddate = startdate + relativedelta(years=package_validity)
        elif package_duration_code == 3:  # No end date
            enddate = None
        # print("renew enddate",enddate)
        if enddate:
            remaining = (enddate - timezone.now().date()).days
            remainingdays = max(remaining, 0)
            # status = 0
        else:
            remainingdays = None
        # print("rem:",remainingdays)
        subscription = AddSubcription.objects.create(
                    farmers=self.farmers,
                    packages=package,
                    status=0,  # Default status, change if needed 
                    startdate=startdate,
                    enddate=enddate,
                    remainingdays = remainingdays,
                    renewal = True,
                    created_by = user,
                    created_at= timezone.now()
                )
        # Call save to update the record in the database
        # self.save()

    def package_details_update(self,user):
        if self.packages:
            package_validity = self.packages.package_validity
            package_duration_code = self.packages.package_duration.code

            # if not self.startdate:
            #     self.startdate = timezone.now().date()

            # startdate = self.startdate 
            startdate = timezone.now().date()
            self.startdate = startdate
            
            if package_duration_code == 0:  
                self.enddate = startdate + timedelta(days=package_validity)
            elif package_duration_code == 1: 
                self.enddate = startdate + relativedelta(months=package_validity)
            elif package_duration_code == 2:  
                self.enddate = startdate + relativedelta(years=package_validity)
            elif package_duration_code == 3:  
                self.enddate = None

            if self.enddate:
                remaining = (self.enddate - self.startdate).days
                self.remainingdays = max(remaining, 0)
            else:
                self.remainingdays = None
            self.updated_by = user
            self.status = 0
            self.save()

    def __str__(self):
        return f"Subscription for {self.farmers.name}"
    
    @property
    def sub_amount(self):
        """Get the sub amount from the related PackageManagement."""
        if self.packages:
            return self.packages.sub_amount
        return None

    @property
    def amount(self):
        """Get the original package amount from the related PackageManagement."""
        if self.packages:
            return self.packages.amount
        return None

# --------------------------------------------------------> Market Management

class MarketType(models.Model):
    name = models.CharField(max_length=200)
    code = models.IntegerField(null=True,blank=True) 
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='market_type_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.name
    
class Days(models.Model):
    name = models.CharField(max_length=200)
    code = models.IntegerField(null=True, blank=True) 
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='days_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
       
class ManageProduct(models.Model):
    name = models.CharField(max_length=200)
    markets = models.ManyToManyField('ManageMarket', blank=True,related_name='product_market_set') 
    img = models.ImageField(upload_to='manage product/', null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, default=0, null=True, blank=True)
    available = models.BooleanField( null =True, blank =True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='manage_product_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)
    
    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

    
    def update_price_and_availability(self, market, price, available):
        print("update_price_and_availability")
        if market in self.markets.all():
            self.price = price
            self.available = available
            self.save()

    def get_full_market_details(self): 
        print("get_full_market_details")
        markets = self.markets.all()
        print("markets",markets)

        market_details = []
        for market in markets:
            market_data = {
                'id': market.id,
                'name': market.name,
                'openingtime': market.openingtime,
                'closingtime': market.closingtime,
                'description': market.description,
                'phone': market.phone,
                'address': market.address,
                'status': market.status,
                'latitude': market.latitude,
                'longitude': market.longitude,
                'markettype': market.markettype.name if market.markettype else None,   
                'img': market.img.url if market.img else None,  
                'created_at': market.created_at,
                'created_by': market.created_by,
                'updated_at': market.updated_at,
                'updated_by': market.updated_by,
                'days': [day.day_name for day in market.days.all()]  
            }
            market_details.append(market_data)
        print("func: market detaisls:",market_details)
        return market_details

def market_image_upload_to(instance, filename):
    # Safely generate the filename, using the farmer's ID and name
    farmer_id = instance.id if instance.id else 'new_market'  # In case the farmer is not saved yet
    farmer_name = slugify(instance.name) if instance.name else 'no_name'
    
    # Construct the file name and path
    return os.path.join('upload/market/', f"{farmer_id}_{farmer_name}_{filename}")

class ManageMarket(models.Model):
    name = models.CharField(max_length=200)
    markettype = models.ForeignKey(MarketType, on_delete=models.CASCADE, null=True, blank=True)
    products = models.ManyToManyField(ManageProduct, blank=True, related_name='market_product_set')
    openingtime = models.TimeField(null=True, blank=True)
    closingtime = models.TimeField(null=True, blank=True)
    days = models.ManyToManyField(Days, blank=True)
    description = models.TextField(null=True, blank=True)
    img = models.ImageField(upload_to=market_image_upload_to, null=True, blank=True)
    phone = models.CharField(max_length=200, null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='market_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    latitude = models.TextField(max_length=50,null=True,blank=True)
    longitude = models.TextField(max_length=50,null=True,blank=True)
    country = models.ForeignKey('Country',on_delete=models.CASCADE,null=True, blank= True)
    state = models.ForeignKey('State', on_delete=models.CASCADE,null=True,blank=True)
    city = models.ForeignKey('City', on_delete=models.CASCADE, null=True, blank=True)
    taluk = models.ForeignKey('Taluk', on_delete=models.CASCADE, null=True, blank=True)
    village = models.ForeignKey('Village', on_delete=models.CASCADE, null=True, blank=True)
    door_no = models.CharField(max_length=200, null=True, blank=True)
    pincode = models.IntegerField(default=0, null=True, blank=True)
    translate_json = models.JSONField(null=True, blank=True)
    locations = models.CharField(max_length=200, null=True, blank=True) #OK

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)

        if self.products.exists():
            for product in self.products.all():
                if self not in product.markets.all():
                    product.markets.add(self)  
            super().save(*args, **kwargs)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    

    # def clean(self):
    #     if self.markettype:
    #         if self.markettype.code == 1:  
    #             if self.phone or self.address:
    #                 raise ValidationError("Phone and address should not be filled for online markets.")
    #         elif self.markettype.code == 0: 
    #             if not self.phone or not self.address:
    #                 raise ValidationError("Phone and address are required for physical markets.")

class AllocateMarket(models.Model):
    staff = models.ForeignKey('ManageUser', on_delete=models.CASCADE, null=True, blank=True)
    markets = models.ManyToManyField(ManageMarket, blank=True)  # Changed to ManyToManyField
    description = models.TextField(null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='allocate_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        markets_list = ", ".join([market.name for market in self.markets.all()])
        return f"{self.staff.name} allocated to: {markets_list if markets_list else 'No Markets'}"

class ProductMarketReport(models.Model):
    product = models.ForeignKey('ManageProduct', on_delete=models.CASCADE, null=True, blank=True)
    market = models.ForeignKey('ManageMarket', on_delete=models.CASCADE, null=True, blank=True)
    available = models.BooleanField(default=False,null=True, blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, default=0, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True,null=True, blank=True)
    created_day = models.DateField( null=True, blank=True)
    staff = models.ForeignKey('ManageUser', on_delete=models.CASCADE, null=True, blank=True)


    class Meta:
        unique_together = ('product', 'market', 'created_day')  # Ensure only one report per product/market/day

    def __str__(self):
        return f"{self.product.name} - {self.market.name} on {self.created_day} - Price: {self.price}"

    def save(self, *args, **kwargs):
        # If created_day is not set, set it to the current date
        if not self.created_day:
            self.created_day = self.created_at.date()

        # Automatically set the staff for the report
        if not self.staff:
            self.staff = self.get_staff_for_market(self.market)

        super(ProductMarketReport, self).save(*args, **kwargs)

    def get_staff_for_market(self, market):
        '''
        Fetches the staff allocated to the given market for the current day.
        Assumes that the staff assigned to the market on the day of the report is the one needed.
        '''
        # Get the staff allocated to the market on the current date
        allocated_market = AllocateMarket.objects.filter(markets=market).first()
        if allocated_market:
            return allocated_market.staff  # Return the first staff assigned to this market
        return None  # If no staff is assigned, return None

    def get_formatted_created_at(self):
        return self.created_at.strftime("%A, %b. %d, %Y, %I:%M %p")

class MarketProduct(models.Model):
    market = models.ForeignKey(ManageMarket, on_delete=models.CASCADE,null=True, blank=True)
    product = models.ForeignKey(ManageProduct, on_delete=models.CASCADE,null=True, blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, default=0, null=True, blank=True)
    available = models.BooleanField(default=True,null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='market_product_created_by')
    updated_at = models.DateTimeField(null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    class Meta:
        unique_together = ('market', 'product') 

    def __str__(self):
        return f'{self.product.name} at {self.market.name}'

# --------------------------------------------------> Near By Location

def nearby_image_upload_to(instance, filename):
    # Safely generate the filename, using the farmer's ID and name
    farmer_id = instance.id if instance.id else 'new_location'  # In case the farmer is not saved yet
    farmer_name = slugify(instance.name) if instance.name else 'no_name'
    
    # Construct the file name and path
    return os.path.join('locations', f"{farmer_id}_{farmer_name}_{filename}")

class ManageNearByLocations(models.Model):
    category = models.ForeignKey(NearByLocationCategory, on_delete=models.CASCADE, null=True, blank=True)
    name = models.CharField(max_length= 200)
    contact = models.CharField(max_length=15,null=True,blank=True)
    address = models.TextField(null=True,blank=True)
    description = models.TextField(null=True,blank=True)
    openingtime = models.TimeField(null=True, blank=True)
    closingtime = models.TimeField(null=True, blank=True)
    days = models.ManyToManyField(Days, blank=True)
    latitude = models.TextField(max_length=50,null=True,blank=True)
    longitude = models.TextField(max_length=50,null=True,blank=True)
    img = models.ImageField(upload_to=nearby_image_upload_to, null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='manage_nearby_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    country = models.ForeignKey('Country',on_delete=models.CASCADE,null=True, blank= True)
    state = models.ForeignKey('State', on_delete=models.CASCADE,null=True,blank=True)
    city = models.ForeignKey('City', on_delete=models.CASCADE, null=True, blank=True)
    taluk = models.ForeignKey('Taluk', on_delete=models.CASCADE, null=True, blank=True)
    village = models.ForeignKey('Village', on_delete=models.CASCADE, null=True, blank=True)
    door_no = models.CharField(max_length=200, null=True, blank=True)
    pincode = models.IntegerField(default=0, null=True, blank=True)
    translate_json = models.JSONField(null=True, blank=True) 
    locations = models.CharField(max_length=200, null=True, blank=True) #OK
    
    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

# -----------------------------------------------------> Vehicle Management

class VehicleCategory(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='veh_categ_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.name

class VehicleManagement(models.Model):
    name = models.CharField(max_length=255)
    category = models.ForeignKey(VehicleCategory, on_delete=models.CASCADE,blank=True, null=True)
    description = models.TextField(blank=True, null=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='vehi_manage_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.name
    
# ------------------------------------------------> Machinery Management 
    
class MachineryCategory(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='machine_categ_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.name

class Machinery(models.Model):
    category = models.ForeignKey(MachineryCategory, on_delete=models.CASCADE,blank=True, null=True)
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True) 
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='machinery_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.name

# ------------------------------------------------> Tool Management 

class ToolCategory(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='tool_categ_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.name

class Tool(models.Model):
    category = models.ForeignKey(ToolCategory, on_delete=models.CASCADE,blank=True, null=True)
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='tools_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.name
    
# ---------------------------------------------------->  Workers Availability

class ManageWorkers(models.Model):
    worker = models.ForeignKey('ManageUser', on_delete=models.CASCADE, null=True, blank=True)
    workerstype = models.ForeignKey(WorkersType, on_delete=models.CASCADE, blank=True, null=True)
    person = models.IntegerField(null=True, blank=True)
    status = models.IntegerField(default=0, null=True, blank=True)
    created_at = models.DateTimeField(null=True, blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='manage_worker_created_by')
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return f"{self.worker.name}"
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

    def get_worker_details(self): 
        worker = self.worker
        if worker:
            details = {
                'name': worker.name,
                'mobile_no': worker.mobile_no,
                'village': worker.village.name if worker.village else None,
                'taluk': worker.taluk.name if worker.taluk else None,
                'employee_type': worker.employee_type.name if worker.employee_type else None
            }
            return details
        return None

class WorkerWorkType(models.Model):
    worker = models.ForeignKey('ManageWorkers', on_delete=models.CASCADE)
    work_type = models.ForeignKey('WorkersType', on_delete=models.CASCADE)  # Link to work type
    person_count = models.IntegerField(null=True, blank=True)  # The number of persons for the work type
    created_at = models.DateTimeField(null=True, blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='worker_wrktype_created_by')
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return f"{self.worker.worker.name} - {self.work_type.name} - {self.person_count}"

    class Meta:
        unique_together = ('worker', 'work_type')
     
# ------------------------------------------------> Guidelines Management -------------------------------------


class GuidelinesType(models.Model):
    name = models.CharField(max_length=255)
    code = models.CharField(max_length=10, null=True, blank=True)
    description = models.TextField(blank=True, null=True)
    status = models.IntegerField(default=0, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='guideline_typ_created_by')
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class Guidelines(models.Model): 
    name = models.CharField(max_length=255)
    guidelinestype = models.ForeignKey(GuidelinesType, on_delete=models.CASCADE, blank=True, null=True)
    guidelinescategory = models.ForeignKey('GuidelinesCategory', on_delete=models.CASCADE, blank=True, null=True)
    crop = models.ForeignKey('Crop', on_delete=models.CASCADE, blank=True, null=True)
    description = models.TextField(blank=True, null=True)
    status = models.IntegerField(default=0, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, blank=True, null=True)
    updated_at = models.DateTimeField(auto_now=True, blank=True, null=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='guidelines_created_by')
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    video_url = models.URLField(blank=True, null=True)
    document = models.FileField(upload_to='guidelines_documents/', blank=True, null=True) 
    media_type = models.CharField(max_length=10, choices=[('video', 'Video'), ('document', 'Document')], default='document')
    translate_json = models.JSONField(null=True, blank=True)

    @classmethod
    def get_guideline_types(cls): 
        return [(g.id, g.name) for g in GuidelinesType.objects.all()]

    def clean(self): 
        if self.guidelinestype and self.guidelinestype.code == '1' and not self.crop:
            raise ValidationError({'crop': 'This field is required when the guidelines are based on crop.'})
        elif self.guidelinestype and self.guidelinestype.code == '0' and self.crop:
            raise ValidationError({'crop': 'Crop should not be specified for general guidelines.'}) 
        if self.media_type == 'video' and not self.video_url:
            raise ValidationError("Video URL must be provided for video type.")
        if self.media_type == 'document' and not self.document:
            raise ValidationError("Document must be uploaded for document type.")
        if self.media_type == 'document' and self.video_url:
            raise ValidationError("You cannot provide both video URL and document. Please select one.")
        if self.media_type == 'video' and self.document:
            raise ValidationError("You cannot provide both video URL and document. Please select one.")
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class GuidelineFile(models.Model):
    guideline = models.ForeignKey(Guidelines, on_delete=models.CASCADE, related_name='files')
    file = models.FileField(upload_to='upload/guideline_files/')
    is_main = models.BooleanField(default=False)  # To indicate if it's the main file
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.file.name
 
# -----------------------------------------------------------------> User Management ---------------------------------------

class UserType(models.Model):
    name = models.CharField(max_length=200)
    code = models.IntegerField(null=True, blank=True) 
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)   
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='user_type_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.name

class Gender(models.Model):
    gender = models.CharField(max_length=20)
    code = models.IntegerField(null=True, blank=True) 
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='gender_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    
    def __str__(self):
        return self.gender

class Role(models.Model):
    role = models.CharField(max_length=100)
    description = models.CharField(max_length=250, null=True, blank=True)
    code = models.IntegerField(null=True, blank=True) 
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='role_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    
    def __str__(self):
        return self.role

class ManageUser(models.Model):
    usertype = models.ForeignKey(UserType, on_delete=models.CASCADE, null=True, blank=True)
    name = models.CharField(max_length=25)
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.ForeignKey(Gender, on_delete=models.CASCADE, null=True, blank=True)
    mobile_no = models.BigIntegerField(null=True, blank=True)
    alter_no = models.BigIntegerField(null=True, blank=True)
    email = models.EmailField(null=True, blank=True)
    date_of_join = models.DateField(null=True, blank=True)
    employee_type = models.ForeignKey(EmployeeType, on_delete=models.CASCADE, null=True, blank=True)
    address = models.CharField(max_length=200, null=True, blank=True)
    role = models.ForeignKey('ManageUserRole', on_delete=models.CASCADE, null=True, blank=True)
    img = models.ImageField(upload_to='upload/user/', null=True, blank=True)
    status = models.IntegerField(default=0, null=True, blank=True)
    country = models.ForeignKey(Country, on_delete=models.CASCADE, null=True, blank=True)
    state = models.ForeignKey(State, on_delete=models.CASCADE, null=True, blank=True)
    city = models.ForeignKey(City, on_delete=models.CASCADE, null=True, blank=True)
    taluk = models.ForeignKey(Taluk, on_delete=models.CASCADE, null=True, blank=True)
    village = models.ForeignKey(Village, on_delete=models.CASCADE, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='user_created_by')
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 
    username = models.CharField(max_length=150, null=True, blank=True)
    password = models.CharField(max_length=150, null=True, blank=True)

    staff_user = models.BooleanField(default=False)
    worker_availability_provider = models.BooleanField(default=False)
    market_price_updater = models.BooleanField(default=False)

    custom_user_id = models.PositiveIntegerField(null=True, blank=True)

    # Settings

    can_view_general_setting  = models.BooleanField(default=False, null=True, blank=True)
    can_edit_general_setting = models.BooleanField(default=False,null=True, blank =True) 

    can_add_country = models.BooleanField(default = False, null= True, blank=True)
    can_edit_country = models.BooleanField(default = False, null= True, blank=True)
    can_view_country = models.BooleanField(default = False, null= True, blank=True)
    can_delete_country = models.BooleanField(default = False, null= True, blank=True)
    can_status_country = models.BooleanField(default = False, null= True, blank=True)

    can_add_state = models.BooleanField(default = False, null= True, blank=True)
    can_edit_state = models.BooleanField(default = False, null= True, blank=True)
    can_view_state = models.BooleanField(default = False, null= True, blank=True)
    can_delete_state = models.BooleanField(default = False, null= True, blank=True)
    can_status_state = models.BooleanField(default = False, null= True, blank=True)

    can_add_city = models.BooleanField(default = False, null= True, blank=True)
    can_edit_city = models.BooleanField(default = False, null= True, blank=True)
    can_view_city = models.BooleanField(default = False, null= True, blank=True)
    can_delete_city = models.BooleanField(default = False, null= True, blank=True)
    can_status_city = models.BooleanField(default = False, null= True, blank=True)

    can_add_taluk = models.BooleanField(default = False, null= True, blank=True)
    can_edit_taluk = models.BooleanField(default = False, null= True, blank=True)
    can_view_taluk = models.BooleanField(default = False, null= True, blank=True)
    can_delete_taluk = models.BooleanField(default = False, null= True, blank=True)
    can_status_taluk = models.BooleanField(default = False, null= True, blank=True)

    can_add_village = models.BooleanField(default = False, null= True, blank=True)
    can_edit_village = models.BooleanField(default = False, null= True, blank=True)
    can_view_village = models.BooleanField(default = False, null= True, blank=True)
    can_delete_village = models.BooleanField(default = False, null= True, blank=True)
    can_status_village = models.BooleanField(default = False, null= True, blank=True)

    # Data Management

    can_add_land_unit = models.BooleanField(default = False, null= True, blank=True)
    can_edit_land_unit = models.BooleanField(default = False, null= True, blank=True)
    can_view_land_unit = models.BooleanField(default = False, null= True, blank=True)
    can_delete_land_unit = models.BooleanField(default = False, null= True, blank=True)
    can_status_land_unit = models.BooleanField(default = False, null= True, blank=True)
    
    can_add_area_unit = models.BooleanField(default = False, null= True, blank=True)
    can_edit_area_unit = models.BooleanField(default = False, null= True, blank=True)
    can_view_area_unit = models.BooleanField(default = False, null= True, blank=True)
    can_delete_area_unit = models.BooleanField(default = False, null= True, blank=True)
    can_status_area_unit = models.BooleanField(default = False, null= True, blank=True)

    can_add_soil_type = models.BooleanField(default = False, null= True, blank=True)
    can_edit_soil_type = models.BooleanField(default = False, null= True, blank=True)
    can_view_soil_type = models.BooleanField(default = False, null= True, blank=True)
    can_delete_soil_type = models.BooleanField(default = False, null= True, blank=True)
    can_status_soil_type = models.BooleanField(default = False, null= True, blank=True)

    can_add_crop_type = models.BooleanField(default = False, null= True, blank=True)
    can_edit_crop_type = models.BooleanField(default = False, null= True, blank=True)
    can_view_crop_type = models.BooleanField(default = False, null= True, blank=True)
    can_delete_crop_type = models.BooleanField(default = False, null= True, blank=True)
    can_status_crop_type = models.BooleanField(default = False, null= True, blank=True)

    can_add_quality = models.BooleanField(default = False, null= True, blank=True)
    can_edit_quality = models.BooleanField(default = False, null= True, blank=True)
    can_view_quality = models.BooleanField(default = False, null= True, blank=True)
    can_delete_quality = models.BooleanField(default = False, null= True, blank=True)
    can_status_quality = models.BooleanField(default = False, null= True, blank=True)

    can_add_crop = models.BooleanField(default = False, null= True, blank=True)
    can_edit_crop = models.BooleanField(default = False, null= True, blank=True)
    can_view_crop = models.BooleanField(default = False, null= True, blank=True)
    can_delete_crop = models.BooleanField(default = False, null= True, blank=True)
    can_status_crop = models.BooleanField(default = False, null= True, blank=True)

    can_add_product_type = models.BooleanField(default = False, null= True, blank=True)
    can_edit_product_type = models.BooleanField(default = False, null= True, blank=True)
    can_view_product_type = models.BooleanField(default = False, null= True, blank=True)
    can_delete_product_type = models.BooleanField(default = False, null= True, blank=True)
    can_status_product_type = models.BooleanField(default = False, null= True, blank=True)

    can_add_vehicle_category = models.BooleanField(default = False, null= True, blank=True)
    can_edit_vehicle_category = models.BooleanField(default = False, null= True, blank=True)
    can_view_vehicle_category = models.BooleanField(default = False, null= True, blank=True)
    can_delete_vehicle_category = models.BooleanField(default = False, null= True, blank=True)
    can_status_vehicle_category = models.BooleanField(default = False, null= True, blank=True)

    can_add_manage_vehicle = models.BooleanField(default = False, null= True, blank=True)
    can_edit_manage_vehicle = models.BooleanField(default = False, null= True, blank=True)
    can_view_manage_vehicle = models.BooleanField(default = False, null= True, blank=True)
    can_delete_manage_vehicle = models.BooleanField(default = False, null= True, blank=True)
    can_status_manage_vehicle = models.BooleanField(default = False, null= True, blank=True)

    can_add_machinery_category = models.BooleanField(default = False, null= True, blank=True)
    can_edit_machinery_category = models.BooleanField(default = False, null= True, blank=True)
    can_view_machinery_category = models.BooleanField(default = False, null= True, blank=True)
    can_delete_machinery_category = models.BooleanField(default = False, null= True, blank=True)
    can_status_machinery_category = models.BooleanField(default = False, null= True, blank=True)

    can_add_manage_machinery = models.BooleanField(default = False, null= True, blank=True)
    can_edit_manage_machinery = models.BooleanField(default = False, null= True, blank=True)
    can_view_manage_machinery = models.BooleanField(default = False, null= True, blank=True)
    can_delete_manage_machinery = models.BooleanField(default = False, null= True, blank=True)
    can_status_manage_machinery = models.BooleanField(default = False, null= True, blank=True)

    can_add_tool_category = models.BooleanField(default = False, null= True, blank=True)
    can_edit_tool_category = models.BooleanField(default = False, null= True, blank=True)
    can_view_tool_category = models.BooleanField(default = False, null= True, blank=True)
    can_delete_tool_category = models.BooleanField(default = False, null= True, blank=True)
    can_status_tool_category = models.BooleanField(default = False, null= True, blank=True)

    can_add_tool = models.BooleanField(default = False, null= True, blank=True)
    can_edit_tool = models.BooleanField(default = False, null= True, blank=True)
    can_view_tool = models.BooleanField(default = False, null= True, blank=True)
    can_delete_tool = models.BooleanField(default = False, null= True, blank=True)
    can_status_tool = models.BooleanField(default = False, null= True, blank=True)

    can_add_expense_category = models.BooleanField(default = False, null= True, blank=True)
    can_edit_expense_category = models.BooleanField(default = False, null= True, blank=True)
    can_view_expense_category = models.BooleanField(default = False, null= True, blank=True)
    can_delete_expense_category = models.BooleanField(default = False, null= True, blank=True)
    can_status_expense_category = models.BooleanField(default = False, null= True, blank=True)

    can_add_expense = models.BooleanField(default = False, null= True, blank=True)
    can_edit_expense = models.BooleanField(default = False, null= True, blank=True)
    can_view_expense = models.BooleanField(default = False, null= True, blank=True)
    can_delete_expense = models.BooleanField(default = False, null= True, blank=True)
    can_status_expense = models.BooleanField(default = False, null= True, blank=True)

    can_add_harvesting_type = models.BooleanField(default = False, null= True, blank=True)
    can_edit_harvesting_type = models.BooleanField(default = False, null= True, blank=True)
    can_view_harvesting_type = models.BooleanField(default = False, null= True, blank=True)
    can_delete_harvesting_type = models.BooleanField(default = False, null= True, blank=True)
    can_status_harvesting_type = models.BooleanField(default = False, null= True, blank=True)

    can_add_detection = models.BooleanField(default = False, null= True, blank=True)
    can_edit_detection = models.BooleanField(default = False, null= True, blank=True)
    can_view_detection = models.BooleanField(default = False, null= True, blank=True)
    can_delete_detection = models.BooleanField(default = False, null= True, blank=True)
    can_status_detection = models.BooleanField(default = False, null= True, blank=True)

    # farmer management
    can_add_farmer = models.BooleanField(default=False, null=True, blank=True)
    can_view_farmer = models.BooleanField(default=False, null=True, blank=True)
    can_edit_farmer = models.BooleanField(default=False, null=True, blank=True) 
    can_delete_farmer = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_farmer = models.BooleanField(default=False, null=True, blank=True)
    can_update_farmer_status = models.BooleanField(default=False, null=True, blank=True)  
    can_export_farmer_data = models.BooleanField(default=False, null=True, blank=True)  
    can_filter_farmer_data = models.BooleanField(default=False, null=True, blank=True)
    can_subscribe_farmer_package = models.BooleanField(default=False, null=True, blank=True)
    can_unsubscribe_farmer_package = models.BooleanField(default=False, null=True, blank=True)

    # package management
    can_add_package = models.BooleanField(default=False, null=True, blank=True)
    can_view_package = models.BooleanField(default=False, null=True, blank=True)
    can_edit_package = models.BooleanField(default=False, null=True, blank=True)
    can_delete_package = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_package = models.BooleanField(default=False, null=True, blank=True)

    # subscription management
    can_add_subscription = models.BooleanField(default=False, null=True, blank=True)
    can_view_subscription = models.BooleanField(default=False, null=True, blank=True)
    can_edit_subscription = models.BooleanField(default=False, null=True, blank=True)
    can_delete_subscription = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_subscription = models.BooleanField(default=False, null=True, blank=True)
    can_export_subscription = models.BooleanField(default=False, null=True,blank=True)
    can_filter_subscription = models.BooleanField(default = False, null=True, blank =True)
    can_activeplan_subscription = models.BooleanField(default =False, null =True, blank =True)
    can_renewalplan_subscription = models.BooleanField(default=False, null =True, blank=True)
    can_unsubscribe_subscription = models.BooleanField(default=False, null =True, blank=True)
    can_update_subscription_status = models.BooleanField(default=False, null=True, blank=True)  

    # --> Market Price

    can_add_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_view_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_edit_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_delete_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_filter_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_update_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_graph_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_staff_manage_product = models.BooleanField(default=False, null=True, blank=True)

    can_filter_market_report  = models.BooleanField(default=False, null=True, blank=True)
    can_view_market_report = models.BooleanField(default=False, null=True, blank=True)
    can_edit_market_report = models.BooleanField(default=False, null=True, blank=True) 
    can_graph_market_report = models.BooleanField(default=False, null=True, blank=True)

    can_filter_product_market_report  = models.BooleanField(default=False, null=True, blank=True)
    can_view_product_market_report = models.BooleanField(default=False, null=True, blank=True)
    can_edit_product_market_report = models.BooleanField(default=False, null=True, blank=True) 
    can_graph_product_market_report = models.BooleanField(default=False, null=True, blank=True)

    # --> Market Management

    can_add_market = models.BooleanField(default=False, null=True, blank=True)
    can_view_market = models.BooleanField(default=False, null=True, blank=True)
    can_edit_market = models.BooleanField(default=False, null=True, blank=True)
    can_delete_market = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_market = models.BooleanField(default=False, null=True, blank=True)
    can_status_market = models.BooleanField(default=False, null=True, blank=True)
    can_export_market = models.BooleanField(default=False, null=True, blank=True)
    can_filter_market = models.BooleanField(default=False, null=True, blank=True)

    can_add_allocate_market = models.BooleanField(default=False, null=True, blank=True)
    can_view_allocate_market = models.BooleanField(default=False, null=True, blank=True)
    can_edit_allocate_market = models.BooleanField(default=False, null=True, blank=True)
    can_delete_allocate_market = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_allocate_market = models.BooleanField(default=False, null=True, blank=True)
    can_status_allocate_market = models.BooleanField(default=False, null=True, blank=True)
    can_export_allocate_market = models.BooleanField(default=False, null=True, blank=True)

    # --> Schedule Management

    can_add_schedule_activity_type = models.BooleanField(default=False, null=True, blank=True)
    can_edit_schedule_activity_type = models.BooleanField(default=False, null=True, blank=True)
    can_view_schedule_activity_type = models.BooleanField(default=False, null=True, blank=True)
    can_delete_schedule_activity_type = models.BooleanField(default=False, null=True, blank=True)
    can_status_schedule_activity_type = models.BooleanField(default=False, null=True, blank=True)

    can_add_schedule  = models.BooleanField(default=False, null=True, blank=True)
    can_edit_schedule  = models.BooleanField(default=False, null=True, blank=True)
    can_view_schedule = models.BooleanField(default=False, null=True, blank=True)
    can_delete_schedule = models.BooleanField(default=False, null=True, blank=True)
    can_status_schedule = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_schedule = models.BooleanField(default=False, null=True, blank=True)
    can_filter_schedule = models.BooleanField(default=False, null =True, blank=True)
    can_import_schedule = models.BooleanField(default=False, null =True, blank=True)

    # --> NearBy Locations

    can_add_near_by_location_category = models.BooleanField(default=False, null=True, blank=True)
    can_edit_near_by_location_category = models.BooleanField(default=False, null=True, blank=True)
    can_view_near_by_location_category = models.BooleanField(default=False, null=True, blank=True)
    can_delete_near_by_location_category = models.BooleanField(default=False, null=True, blank=True)
    can_status_near_by_location_category = models.BooleanField(default=False, null=True, blank=True)

    can_add_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_edit_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_view_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_delete_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_status_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_export_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_filter_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_near_by_locations = models.BooleanField(default=False, null=True, blank=True)

    # --> Workers Availability

    can_add_workers_type = models.BooleanField(default=False, null=True, blank=True)
    can_edit_workers_type = models.BooleanField(default=False, null=True, blank=True)
    can_view_workers_type = models.BooleanField(default=False, null=True, blank=True)
    can_delete_workers_type = models.BooleanField(default=False, null=True, blank=True)
    can_update_workers_type_status = models.BooleanField(default=False, null=True, blank=True)  
    
    can_add_manage_workers = models.BooleanField(default=False, null=True, blank=True)
    can_view_manage_workers = models.BooleanField(default=False, null=True, blank=True)
    can_edit_manage_workers = models.BooleanField(default=False, null=True, blank=True)
    can_update_manage_workers = models.BooleanField(default=False, null=True,blank=True)
    can_delete_manage_workers = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_manage_workers= models.BooleanField(default=False, null=True, blank=True)
    can_update_manage_workers_status = models.BooleanField(default=False, null=True, blank=True)  
    can_export_manage_workers= models.BooleanField(default=False, null=True, blank=True)  
    can_filter_manage_workers = models.BooleanField(default=False, null=True, blank=True)

    # ---> Guidelines Management 

    can_add_guidelines_category = models.BooleanField(default=False, null=True, blank=True)
    can_view_guidelines_category = models.BooleanField(default=False, null=True, blank=True)
    can_edit_guidelines_category = models.BooleanField(default=False, null=True, blank=True) 
    can_delete_guidelines_category = models.BooleanField(default=False, null=True, blank=True)
    can_update_guidelines_category_status = models.BooleanField(default=False, null=True, blank=True)  
    
    can_add_guidelines = models.BooleanField(default=False, null=True, blank=True)
    can_view_guidelines = models.BooleanField(default=False, null=True, blank=True)
    can_edit_guidelines = models.BooleanField(default=False, null=True, blank=True)
    can_delete_guidelines = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_guidelines= models.BooleanField(default=False, null=True, blank=True)
    can_update_guidelines_status = models.BooleanField(default=False, null=True, blank=True)  
    can_export_guidelines = models.BooleanField(default=False, null=True, blank=True)  
    can_filter_guidelines = models.BooleanField(default=False, null=True, blank=True)

    # ---> User Management

    can_view_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_add_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_edit_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_delete_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_export_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_filter_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_status_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_ter_status_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_rel_status_manage_user = models.BooleanField(default = False, null =True, blank= True)
    can_view_unique_manage_user = models.BooleanField(default=False, null=True, blank=True)

    can_add_manage_user_role = models.BooleanField(default=False, null=True, blank=True)
    can_view_manage_user_role = models.BooleanField(default=False, null=True, blank=True)
    can_status_manage_user_role = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_manage_user_role = models.BooleanField(default=False, null=True, blank=True)
    can_edit_manage_user_role = models.BooleanField(default=False, null=True, blank=True)
    can_delete_manage_user_role = models.BooleanField(default=False, null=True, blank=True)

    # --> Report

    can_export_farmer_report = models.BooleanField(default=False, null=True, blank=True)
    can_view_farmer_report = models.BooleanField(default=False, null=True, blank=True)
    can_filter_farmer_report = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_report = models.BooleanField(default=False, null=True, blank=True)

    can_export_subscription_report = models.BooleanField(default=False, null=True, blank=True)
    can_view_subscription_report = models.BooleanField(default=False, null=True, blank=True)
    can_filter_subscription_report = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_subscription_report = models.BooleanField(default=False, null=True, blank=True)

    can_dashboard_count = models.BooleanField(default=False, null=True, blank=True)
    can_dashboard_total_revenue = models.BooleanField(default=False, null=True, blank=True)
    can_farmer_graph = models.BooleanField(default=False, null=True, blank=True)
    can_subscription_graph = models.BooleanField(default=False, null=True, blank=True)
    can_revenue_graph = models.BooleanField(default=False, null=True, blank=True)
    can_market_view  = models.BooleanField(default=False, null=True, blank=True)
    can_market_graph = models.BooleanField(default=False, null=True, blank=True)
    can_market_view_staff = models.BooleanField(default=False, null=True, blank=True)

    can_add_email_config   = models.BooleanField(default=False, null=True, blank=True)
    can_view_email_config  = models.BooleanField(default=False, null=True, blank=True)
    can_status_email_config  = models.BooleanField(default=False, null=True, blank=True)
    can_edit_email_config  = models.BooleanField(default=False, null=True, blank=True)
    can_delete_email_config  = models.BooleanField(default=False, null=True, blank=True)

    can_view_sms_config  = models.BooleanField(default=False, null=True, blank=True)
    can_status_sms_config  = models.BooleanField(default=False, null=True, blank=True)
    can_delete_sms_config  = models.BooleanField(default=False, null=True, blank=True)
    can_edit_sms_config = models.BooleanField(default=False,null =True, blank=True)

    can_add_inventory_category = models.BooleanField(default = False, null= True, blank=True)
    can_edit_inventory_category = models.BooleanField(default = False, null= True, blank=True)
    can_view_inventory_category = models.BooleanField(default = False, null= True, blank=True)
    can_delete_inventory_category = models.BooleanField(default = False, null= True, blank=True)
    can_status_inventory_category = models.BooleanField(default = False, null= True, blank=True)

    can_add_inventory_items = models.BooleanField(default = False, null= True, blank=True)
    can_edit_inventory_items = models.BooleanField(default = False, null= True, blank=True)
    can_view_inventory_items = models.BooleanField(default = False, null= True, blank=True)
    can_delete_inventory_items = models.BooleanField(default = False, null= True, blank=True)
    can_status_inventory_items = models.BooleanField(default = False, null= True, blank=True)

    can_add_document_category = models.BooleanField(default = False, null= True, blank=True)
    can_edit_document_category = models.BooleanField(default = False, null= True, blank=True)
    can_view_document_category = models.BooleanField(default = False, null= True, blank=True)
    can_delete_document_category = models.BooleanField(default = False, null= True, blank=True)
    can_status_document_category = models.BooleanField(default = False, null= True, blank=True)

    # ---> Rental Availability
    can_view_rental_availability = models.BooleanField(default=False, null=True, blank=True)
    can_filter_rental_availability = models.BooleanField(default=False, null=True, blank=True)
    can_export_rental_availability = models.BooleanField(default=False, null=True, blank=True) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    class Meta:
        verbose_name = "Manage User"
        verbose_name_plural = "Manage Users"

    
    def create_user(self):
        if not self.email:
            raise ValueError("Email must be provided to create a user.")
        if not self.mobile_no:
            raise ValueError("Phone No must be provided to create a user.")

        # If custom_user_id is set, it indicates an update scenario
        if self.custom_user_id:
            user = CustomUser.objects.get(id=self.custom_user_id)
        else:
            user = CustomUser(
                email=self.email,
                name=self.name,
                phone_number=self.mobile_no,
                is_active=True
            )
            user.set_password(str(self.mobile_no))  # Convert to string for password
            user.save()  # Create new user

        # Set user flags based on usertype
        if self.usertype.code == 0:
            user.staff_user = True
            self.staff_user = True
        elif self.usertype.code == 1:
            user.worker_user = True
            self.worker_availability_provider = True
        elif self.usertype.code == 2:
            user.market_user = True
            self.market_price_updater = True

        if self.img:
            user.image = self.img

        user.save()  # Save any changes to the user

        self.custom_user_id = user.id  # Set custom_user_id
        self.username = str(self.mobile_no)  # Store username as mobile_no string
        self.password = str(self.mobile_no)  # Store password as string (though not ideal for security)
        self.save()  # Save the ManageUser instance

    def update_from_role(self):
        self.can_view_general_setting  = self.role.can_view_general_setting
        self.can_edit_general_setting = self.role.can_edit_general_setting 

        self.can_add_country =self.role.can_add_country
        self.can_edit_country =self.role.can_edit_country
        self.can_view_country = self.role.can_view_country
        self.can_delete_country =  self.role.can_delete_country
        self.can_status_country =  self.role.can_status_country

        self.can_add_state =  self.role.can_add_state
        self.can_edit_state =  self.role.can_edit_state
        self.can_view_state =  self.role.can_view_state
        self.can_delete_state =  self.role.can_delete_state
        self.can_status_state =  self.role.can_status_state

        self.can_add_city = self.role.can_add_city
        self.can_edit_city =  self.role.can_edit_city
        self.can_view_city =  self.role.can_view_city
        self.can_delete_city =  self.role.can_delete_city
        self.can_status_city = self.role.can_status_city

        self.can_add_taluk = self.role.can_add_taluk
        self.can_edit_taluk = self.role.can_edit_taluk
        self.can_view_taluk =self.role.can_view_taluk
        self.can_delete_taluk = self.role.can_delete_taluk
        self.can_status_taluk = self.role.can_status_taluk

        self.can_add_village = self.role.can_add_village
        self.can_edit_village =  self.role.can_edit_village
        self.can_view_village =  self.role.can_view_village
        self.can_delete_village =  self.role.can_delete_village
        self.can_status_village =  self.role.can_status_village

        # Data Management

        self.can_add_land_unit =  self.role.can_add_land_unit
        self.can_edit_land_unit =  self.role.can_edit_land_unit
        self.can_view_land_unit =  self.role.can_view_land_unit
        self.can_delete_land_unit =  self.role.can_delete_land_unit
        self.can_status_land_unit =  self.role.can_status_land_unit
        
        self.can_add_area_unit = self.role.can_add_area_unit
        self.can_edit_area_unit =  self.role.can_edit_area_unit
        self.can_view_area_unit =  self.role.can_view_area_unit
        self.can_delete_area_unit =  self.role.can_delete_area_unit
        self.can_status_area_unit =  self.role.can_status_area_unit

        self.can_add_soil_type =  self.role.can_add_soil_type
        self.can_edit_soil_type =  self.role.can_edit_soil_type
        self.can_view_soil_type =  self.role.can_view_soil_type
        self.can_delete_soil_type = self.role.can_delete_soil_type
        self.can_status_soil_type = self.role.can_status_soil_type

        self.can_add_crop_type =  self.role.can_add_crop_type
        self.can_edit_crop_type =  self.role.can_edit_crop_type
        self.can_view_crop_type =  self.role.can_view_crop_type
        self.can_delete_crop_type =  self.role.can_delete_crop_type
        self.can_status_crop_type = self.role.can_status_crop_type

        self.can_add_quality =  self.role.can_add_quality
        self.can_edit_quality =  self.role.can_edit_quality
        self.can_view_quality = self.role.can_view_quality
        self.can_delete_quality =  self.role.can_delete_quality
        self.can_status_quality =  self.role.can_status_quality

        self.can_add_crop =  self.role.can_add_crop
        self.can_edit_crop =  self.role.can_edit_crop
        self.can_view_crop =  self.role.can_view_crop
        self.can_delete_crop =  self.role. can_delete_crop
        self.can_status_crop =  self.role.can_status_crop

        self.can_add_product_type =  self.role.can_add_product_type
        self.can_edit_product_type =  self.role.can_edit_product_type
        self.can_view_product_type =  self.role.can_view_product_type
        self.can_delete_product_type =  self.role.can_delete_product_type
        self.can_status_product_type =  self.role.can_status_product_type

        self.can_add_vehicle_category = self.role.can_add_vehicle_category
        self.can_edit_vehicle_category =  self.role.can_edit_vehicle_category
        self.can_view_vehicle_category = self.role.can_view_vehicle_category
        self.can_delete_vehicle_category = self.role.can_delete_vehicle_category
        self.can_status_vehicle_category =  self.role.can_status_vehicle_category

        self.can_add_manage_vehicle =  self.role.can_add_manage_vehicle
        self.can_edit_manage_vehicle =  self.role.can_edit_manage_vehicle
        self.can_view_manage_vehicle =  self.role.can_view_manage_vehicle
        self.can_delete_manage_vehicle = self.role.can_delete_manage_vehicle
        self.can_status_manage_vehicle =  self.role.can_status_manage_vehicle

        self.can_add_machinery_category =  self.role.can_add_machinery_category
        self.can_edit_machinery_category = self.role.can_edit_machinery_category
        self.can_view_machinery_category =  self.role.can_view_machinery_category
        self.can_delete_machinery_category =  self.role.can_delete_machinery_category
        self.can_status_machinery_category =  self.role.can_status_machinery_category

        self.can_add_manage_machinery =  self.role.can_add_manage_machinery
        self.can_edit_manage_machinery =  self.role.can_edit_manage_machinery
        self.can_view_manage_machinery =  self.role.can_view_manage_machinery
        self.can_delete_manage_machinery =  self.role.can_delete_manage_machinery
        self.can_status_manage_machinery =  self.role.can_status_manage_machinery

        self.can_add_tool_category = self.role.can_add_tool_category
        self.can_edit_tool_category =  self.role.can_edit_tool_category
        self.can_view_tool_category = self.role.can_view_tool_category
        self.can_delete_tool_category = self.role.can_delete_tool_category
        self.can_status_tool_category =  self.role.can_status_tool_category

        self.can_add_tool =  self.role.can_add_tool
        self.can_edit_tool =  self.role.can_edit_tool
        self.can_view_tool =  self.role.can_view_tool
        self.can_delete_tool =  self.role.can_delete_tool
        self.can_status_tool =  self.role.can_status_tool

        self.can_add_expense_category =  self.role.can_add_expense_category
        self.can_edit_expense_category =  self.role.can_edit_expense_category
        self.can_view_expense_category =  self.role.can_view_expense_category
        self.can_delete_expense_category =  self.role.can_delete_expense_category
        self.can_status_expense_category =  self.role.can_status_expense_category

        self.can_add_expense =  self.role.can_add_expense
        self.can_edit_expense = self.role.can_edit_expense
        self.can_view_expense = self.role.can_view_expense
        self.can_delete_expense = self.role.can_delete_expense
        self.can_status_expense = self.role.can_status_expense

        self.can_add_harvesting_type = self.role.can_add_harvesting_type
        self.can_edit_harvesting_type =self.role.can_edit_harvesting_type
        self.can_view_harvesting_type = self.role.can_view_harvesting_type
        self.can_delete_harvesting_type = self.role.can_delete_harvesting_type
        self.can_status_harvesting_type = self.role.can_status_harvesting_type

        self.can_add_detection = self.role.can_add_detection
        self.can_edit_detection = self.role.can_edit_detection
        self.can_view_detection = self.role.can_view_detection
        self.can_delete_detection = self.role.can_delete_detection
        self.can_status_detection = self.role.can_status_detection

        # farmer management
        self.can_add_farmer = self.role.can_add_farmer
        self.can_view_farmer = self.role.can_view_farmer
        self.can_edit_farmer = self.role.can_edit_farmer
        self.can_delete_farmer = self.role.can_delete_farmer
        self.can_view_unique_farmer =self.role.can_view_unique_farmer
        self.can_update_farmer_status = self.role.can_update_farmer_status
        self.can_export_farmer_data = self.role.can_export_farmer_data
        self.can_filter_farmer_data = self.role.can_filter_farmer_data
        self.can_subscribe_farmer_package = self.role.can_subscribe_farmer_package
        self.can_unsubscribe_farmer_package = self.role.can_unsubscribe_farmer_package

        # package management
        self.can_add_package =self.role.can_add_package
        self.can_view_package = self.role.can_view_package
        self.can_edit_package = self.role.can_edit_package
        self.can_delete_package = self.role.can_delete_package
        self.can_view_unique_package = self.role.can_view_unique_package

        # subscription management
        self.can_add_subscription = self.role.can_add_subscription
        self.can_view_subscription = self.role.can_view_subscription
        self.can_edit_subscription = self.role.can_edit_subscription
        self.can_delete_subscription = self.role.can_delete_subscription
        self.can_view_unique_subscription =self.role.can_view_unique_subscription
        self.can_export_subscription = self.role.can_export_subscription
        self.can_filter_subscription =self.role.can_filter_subscription
        self.can_activeplan_subscription = self.role.can_activeplan_subscription
        self.can_renewalplan_subscription = self.role.can_renewalplan_subscription
        self.can_unsubscribe_subscription = self.role.can_unsubscribe_subscription
        self.can_update_subscription_status = self.role.can_update_subscription_status

        # --> Market Price

        self.can_add_manage_product =  self.role.can_add_manage_product
        self.can_view_manage_product =  self.role.can_view_manage_product
        self.can_edit_manage_product =  self.role.can_edit_manage_product
        self.can_delete_manage_product =  self.role.can_delete_manage_product
        self.can_filter_manage_product =  self.role.can_filter_manage_product
        self.can_update_manage_product =  self.role.can_update_manage_product
        self.can_graph_manage_product =  self.role.can_graph_manage_product
        self.can_staff_manage_product = self.role.can_staff_manage_product

        self.can_filter_market_report  = self.role.can_filter_market_report
        self.can_view_market_report = self.role.can_view_market_report
        self.can_edit_market_report = self.role.can_edit_market_report
        self.can_graph_market_report = self.role.can_graph_market_report

        self.can_filter_product_market_report  =self.role.can_filter_product_market_report
        self.can_view_product_market_report =  self.role.can_view_product_market_report
        self.can_edit_product_market_report =  self.role.can_edit_product_market_report
        self.can_graph_product_market_report =  self.role.can_graph_product_market_report

        # --> Market Management

        self.can_add_market =  self.role.can_add_market
        self.can_view_market =  self.role.can_view_market
        self.can_edit_market = self.role.can_edit_market
        self.can_delete_market =  self.role.can_delete_market
        self.can_view_unique_market =  self.role.can_view_unique_market
        self.can_status_market =  self.role.can_status_market
        self.can_export_market =  self.role.can_export_market
        self.can_filter_market =  self.role.can_filter_market

        self.can_add_allocate_market =  self.role.can_add_allocate_market
        self.can_view_allocate_market =  self.role.can_view_allocate_market
        self.can_edit_allocate_market =  self.role.can_edit_allocate_market
        self.can_delete_allocate_market =  self.role.can_delete_allocate_market
        self.can_view_unique_allocate_market =  self.role.can_view_unique_allocate_market
        self.can_status_allocate_market =  self.role.can_status_allocate_market
        self.can_export_allocate_market = self.role.can_export_allocate_market

        # --> Schedule Management

        self.can_add_schedule_activity_type = self.role.can_add_schedule_activity_type
        self.can_edit_schedule_activity_type = self.role.can_edit_schedule_activity_type
        self.can_view_schedule_activity_type = self.role.can_view_schedule_activity_type
        self.can_delete_schedule_activity_type = self.role.can_delete_schedule_activity_type
        self.can_status_schedule_activity_type = self.role.can_status_schedule_activity_type

        self.can_add_schedule  =  self.role.can_add_schedule
        self.can_edit_schedule  =  self.role.can_edit_schedule
        self.can_view_schedule =  self.role.can_view_schedule
        self.can_delete_schedule =  self.role.can_delete_schedule
        self.can_status_schedule =  self.role.can_status_schedule
        self.can_view_unique_schedule =  self.role.can_view_unique_schedule
        self.can_filter_schedule =  self.role.can_filter_schedule
        self.can_import_schedule =  self.role.can_import_schedule

        # --> NearBy Locations

        self.can_add_near_by_location_category =  self.role.can_add_near_by_location_category
        self.can_edit_near_by_location_category =  self.role.can_edit_near_by_location_category
        self.can_view_near_by_location_category =  self.role.can_view_near_by_location_category
        self.can_delete_near_by_location_category =  self.role.can_delete_near_by_location_category
        self.can_status_near_by_location_category =  self.role.can_status_near_by_location_category

        self.can_add_near_by_locations =  self.role.can_add_near_by_locations
        self.can_edit_near_by_locations =  self.role.can_edit_near_by_locations
        self.can_view_near_by_locations =  self.role.can_view_near_by_locations
        self.can_delete_near_by_locations =  self.role.can_delete_near_by_locations
        self.can_status_near_by_locations =  self.role.can_status_near_by_locations
        self.can_export_near_by_locations =  self.role.can_export_near_by_locations
        self.can_filter_near_by_locations =  self.role.can_filter_near_by_locations
        self.can_view_unique_near_by_locations =  self.role.can_view_unique_near_by_locations

        # --> Workers Availability

        self.can_add_workers_type =  self.role.can_add_workers_type
        self.can_edit_workers_type =  self.role.can_edit_workers_type
        self.can_view_workers_type =  self.role.can_view_workers_type
        self.can_delete_workers_type =  self.role.can_delete_workers_type
        self.can_update_workers_type_status = self.role.can_update_workers_type_status
        
        self.can_add_manage_workers = self.role.can_add_manage_workers
        self.can_view_manage_workers = self.role.can_view_manage_workers
        self.can_edit_manage_workers = self.role.can_edit_manage_workers
        self.can_update_manage_workers = self.role.can_update_manage_workers
        self.can_delete_manage_workers = self.role.can_delete_manage_workers
        self.can_view_unique_manage_workers= self.role.can_view_unique_manage_workers
        self.can_update_manage_workers_status =  self.role.can_update_manage_workers_status
        self.can_export_manage_workers= self.role.can_export_manage_workers
        self.can_filter_manage_workers = self.role.can_filter_manage_workers

        # ---> Guidelines Management 

        self.can_add_guidelines_category = self.role.can_add_guidelines_category
        self.can_view_guidelines_category = self.role.can_edit_guidelines_category
        self.can_edit_guidelines_category = self.role.can_delete_guidelines_category
        self.can_delete_guidelines_category = self.role.can_delete_guidelines_category
        self.can_update_guidelines_category_status =  self.role.can_update_guidelines_category_status
        
        self.can_add_guidelines = self.role.can_add_guidelines
        self.can_view_guidelines = self.role.can_view_guidelines
        self.can_edit_guidelines = self.role.can_edit_guidelines
        self.can_delete_guidelines = self.role.can_delete_guidelines
        self.can_view_unique_guidelines= self.role.can_view_unique_guidelines
        self.can_update_guidelines_status = self.role.can_update_guidelines_status
        self.can_export_guidelines = self.role.can_export_guidelines
        self.can_filter_guidelines = self.role.can_filter_guidelines

        # ---> User Management

        self.can_view_manage_user = self.role.can_view_manage_user
        self.can_add_manage_user = self.role.can_add_manage_user
        self.can_edit_manage_user = self.role.can_edit_manage_user
        self.can_delete_manage_user = self.role.can_delete_manage_user
        self.can_export_manage_user = self.role.can_export_manage_user
        self.can_filter_manage_user = self.role.can_filter_manage_user
        self.can_status_manage_user = self.role.can_status_manage_user
        self.can_ter_status_manage_user = self.role.can_ter_status_manage_user
        self.can_rel_status_manage_user =self.role.can_rel_status_manage_user
        self.can_view_unique_manage_user = self.role.can_view_unique_manage_user

        self.can_add_manage_user_role = self.role.can_add_manage_user_role
        self.can_view_manage_user_role = self.role.can_view_manage_user_role
        self.can_status_manage_user_role = self.role.can_status_manage_user_role
        self.can_view_unique_manage_user_role = self.role.can_view_unique_manage_user_role
        self.can_edit_manage_user_role = self.role.can_edit_manage_user_role
        self.can_delete_manage_user_role = self.role.can_delete_manage_user_role

        # --> Report

        self.can_export_farmer_report = self.role.can_export_farmer_report
        self.can_view_farmer_report = self.role.can_view_farmer_report
        self.can_filter_farmer_report = self.role.can_filter_farmer_report
        self.can_view_unique_report = self.role.can_view_unique_report

        self.can_export_subscription_report =self.role.can_export_subscription_report
        self.can_view_subscription_report = self.role.can_view_subscription_report
        self.can_filter_subscription_report = self.role.can_filter_subscription_report
        self.can_view_unique_subscription_report =self.role.can_view_unique_subscription_report

        self.can_dashboard_count = self.role.can_dashboard_count
        self.can_dashboard_total_revenue = self.role.can_dashboard_total_revenue
        self.can_farmer_graph = self.role.can_farmer_graph
        self.can_subscription_graph = self.role.can_subscription_graph
        self.can_revenue_graph = self.role.can_revenue_graph
        self.can_market_view  = self.role.can_market_view
        self.can_market_graph = self.role.can_market_graph
        self.can_market_view_staff = self.role.can_market_view_staff

        self.can_add_email_config   = self.role.can_add_email_config
        self.can_view_email_config  = self.role.can_view_email_config
        self.can_status_email_config  = self.role.can_status_email_config
        self.can_edit_email_config  = self.role.can_edit_email_config
        self.can_delete_email_config  = self.role.can_delete_email_config

        self.can_view_sms_config  = self.role.can_view_sms_config
        self.can_status_sms_config  = self.role.can_status_sms_config
        self.can_delete_sms_config  = self.role.can_delete_sms_config
        self.can_edit_sms_config = self.role.can_edit_sms_config

        self.can_add_inventory_category = self.role.can_add_inventory_category
        self.can_edit_inventory_category =  self.role.can_edit_inventory_category
        self.can_view_inventory_category =  self.role.can_view_inventory_category
        self.can_delete_inventory_category =  self.role.can_delete_inventory_category
        self.can_status_inventory_category =  self.role.can_status_inventory_category

        self.can_add_inventory_items =  self.role.can_add_inventory_items
        self.can_edit_inventory_items =  self.role.can_edit_inventory_items
        self.can_view_inventory_items =  self.role.can_view_inventory_items
        self.can_delete_inventory_items =  self.role.can_delete_inventory_items
        self.can_status_inventory_items =  self.role.can_status_inventory_items

        self.can_add_document_category = self.role.can_add_document_category
        self.can_edit_document_category = self.role.can_edit_document_category
        self.can_view_document_category = self.role.can_view_document_category
        self.can_delete_document_category = self.role.can_delete_document_category
        self.can_status_document_category = self.role.can_status_document_category

        self.can_view_rental_availability = self.role.can_view_rental_availability
        self.can_filter_rental_availability = self.role.can_filter_rental_availability
        self.can_export_rental_availability = self.role.can_export_rental_availability


        self.save()

    def save(self, *args, **kwargs):
        # Automatically update fields before saving
        self.update_from_role()
        super(ManageUser, self).save(*args, **kwargs)
 
    def update_permissions_from_role(self):
        """
        Update the permissions of this ManageUser instance based on the selected role.
        This will set boolean fields based on the selected ManageUserRole.
        """
        if self.role:  

            # Settings

            self.can_view_general_setting  = self.role.can_view_general_setting
            self.can_edit_general_setting = self.role.can_edit_general_setting 

            self.can_add_country =self.role.can_add_country
            self.can_edit_country =self.role.can_edit_country
            self.can_view_country = self.role.can_view_country
            self.can_delete_country =  self.role.can_delete_country
            self.can_status_country =  self.role.can_status_country

            self.can_add_state =  self.role.can_add_state
            self.can_edit_state =  self.role.can_edit_state
            self.can_view_state =  self.role.can_view_state
            self.can_delete_state =  self.role.can_delete_state
            self.can_status_state =  self.role.can_status_state

            self.can_add_city = self.role.can_add_city
            self.can_edit_city =  self.role.can_edit_city
            self.can_view_city =  self.role.can_view_city
            self.can_delete_city =  self.role.can_delete_city
            self.can_status_city = self.role.can_status_city

            self.can_add_taluk = self.role.can_add_taluk
            self.can_edit_taluk = self.role.can_edit_taluk
            self.can_view_taluk =self.role.can_view_taluk
            self.can_delete_taluk = self.role.can_delete_taluk
            self.can_status_taluk = self.role.can_status_taluk

            self.can_add_village = self.role.can_add_village
            self.can_edit_village =  self.role.can_edit_village
            self.can_view_village =  self.role.can_view_village
            self.can_delete_village =  self.role.can_delete_village
            self.can_status_village =  self.role.can_status_village

            # Data Management

            self.can_add_land_unit =  self.role.can_add_land_unit
            self.can_edit_land_unit =  self.role.can_edit_land_unit
            self.can_view_land_unit =  self.role.can_view_land_unit
            self.can_delete_land_unit =  self.role.can_delete_land_unit
            self.can_status_land_unit =  self.role.can_status_land_unit
            
            self.can_add_area_unit = self.role.can_add_area_unit
            self.can_edit_area_unit =  self.role.can_edit_area_unit
            self.can_view_area_unit =  self.role.can_view_area_unit
            self.can_delete_area_unit =  self.role.can_delete_area_unit
            self.can_status_area_unit =  self.role.can_status_area_unit

            self.can_add_soil_type =  self.role.can_add_soil_type
            self.can_edit_soil_type =  self.role.can_edit_soil_type
            self.can_view_soil_type =  self.role.can_view_soil_type
            self.can_delete_soil_type = self.role.can_delete_soil_type
            self.can_status_soil_type = self.role.can_status_soil_type

            self.can_add_crop_type =  self.role.can_add_crop_type
            self.can_edit_crop_type =  self.role.can_edit_crop_type
            self.can_view_crop_type =  self.role.can_view_crop_type
            self.can_delete_crop_type =  self.role.can_delete_crop_type
            self.can_status_crop_type = self.role.can_status_crop_type

            self.can_add_quality =  self.role.can_add_quality
            self.can_edit_quality =  self.role.can_edit_quality
            self.can_view_quality = self.role.can_view_quality
            self.can_delete_quality =  self.role.can_delete_quality
            self.can_status_quality =  self.role.can_status_quality

            self.can_add_crop =  self.role.can_add_crop
            self.can_edit_crop =  self.role.can_edit_crop
            self.can_view_crop =  self.role.can_view_crop
            self.can_delete_crop =  self.role. can_delete_crop
            self.can_status_crop =  self.role.can_status_crop

            self.can_add_product_type =  self.role.can_add_product_type
            self.can_edit_product_type =  self.role.can_edit_product_type
            self.can_view_product_type =  self.role.can_view_product_type
            self.can_delete_product_type =  self.role.can_delete_product_type
            self.can_status_product_type =  self.role.can_status_product_type

            self.can_add_vehicle_category = self.role.can_add_vehicle_category
            self.can_edit_vehicle_category =  self.role.can_edit_vehicle_category
            self.can_view_vehicle_category = self.role.can_view_vehicle_category
            self.can_delete_vehicle_category = self.role.can_delete_vehicle_category
            self.can_status_vehicle_category =  self.role.can_status_vehicle_category

            self.can_add_manage_vehicle =  self.role.can_add_manage_vehicle
            self.can_edit_manage_vehicle =  self.role.can_edit_manage_vehicle
            self.can_view_manage_vehicle =  self.role.can_view_manage_vehicle
            self.can_delete_manage_vehicle = self.role.can_delete_manage_vehicle
            self.can_status_manage_vehicle =  self.role.can_status_manage_vehicle

            self.can_add_machinery_category =  self.role.can_add_machinery_category
            self.can_edit_machinery_category = self.role.can_edit_machinery_category
            self.can_view_machinery_category =  self.role.can_view_machinery_category
            self.can_delete_machinery_category =  self.role.can_delete_machinery_category
            self.can_status_machinery_category =  self.role.can_status_machinery_category

            self.can_add_manage_machinery =  self.role.can_add_manage_machinery
            self.can_edit_manage_machinery =  self.role.can_edit_manage_machinery
            self.can_view_manage_machinery =  self.role.can_view_manage_machinery
            self.can_delete_manage_machinery =  self.role.can_delete_manage_machinery
            self.can_status_manage_machinery =  self.role.can_status_manage_machinery

            self.can_add_tool_category = self.role.can_add_tool_category
            self.can_edit_tool_category =  self.role.can_edit_tool_category
            self.can_view_tool_category = self.role.can_view_tool_category
            self.can_delete_tool_category = self.role.can_delete_tool_category
            self.can_status_tool_category =  self.role.can_status_tool_category

            self.can_add_tool =  self.role.can_add_tool
            self.can_edit_tool =  self.role.can_edit_tool
            self.can_view_tool =  self.role.can_view_tool
            self.can_delete_tool =  self.role.can_delete_tool
            self.can_status_tool =  self.role.can_status_tool

            self.can_add_expense_category =  self.role.can_add_expense_category
            self.can_edit_expense_category =  self.role.can_edit_expense_category
            self.can_view_expense_category =  self.role.can_view_expense_category
            self.can_delete_expense_category =  self.role.can_delete_expense_category
            self.can_status_expense_category =  self.role.can_status_expense_category

            self.can_add_expense =  self.role.can_add_expense
            self.can_edit_expense = self.role.can_edit_expense
            self.can_view_expense = self.role.can_view_expense
            self.can_delete_expense = self.role.can_delete_expense
            self.can_status_expense = self.role.can_status_expense

            self.can_add_harvesting_type = self.role.can_add_harvesting_type
            self.can_edit_harvesting_type =self.role.can_edit_harvesting_type
            self.can_view_harvesting_type = self.role.can_view_harvesting_type
            self.can_delete_harvesting_type = self.role.can_delete_harvesting_type
            self.can_status_harvesting_type = self.role.can_status_harvesting_type

            self.can_add_detection = self.role.can_add_detection
            self.can_edit_detection = self.role.can_edit_detection
            self.can_view_detection = self.role.can_view_detection
            self.can_delete_detection = self.role.can_delete_detection
            self.can_status_detection = self.role.can_status_detection

            # farmer management
            self.can_add_farmer = self.role.can_add_farmer
            self.can_view_farmer = self.role.can_view_farmer
            self.can_edit_farmer = self.role.can_edit_farmer
            self.can_delete_farmer = self.role.can_delete_farmer
            self.can_view_unique_farmer =self.role.can_view_unique_farmer
            self.can_update_farmer_status = self.role.can_update_farmer_status
            self.can_export_farmer_data = self.role.can_export_farmer_data
            self.can_filter_farmer_data = self.role.can_filter_farmer_data
            self.can_subscribe_farmer_package = self.role.can_subscribe_farmer_package
            self.can_unsubscribe_farmer_package = self.role.can_unsubscribe_farmer_package

            # package management
            self.can_add_package =self.role.can_add_package
            self.can_view_package = self.role.can_view_package
            self.can_edit_package = self.role.can_edit_package
            self.can_delete_package = self.role.can_delete_package
            self.can_view_unique_package = self.role.can_view_unique_package

            # subscription management
            self.can_add_subscription = self.role.can_add_subscription
            self.can_view_subscription = self.role.can_view_subscription
            self.can_edit_subscription = self.role.can_edit_subscription
            self.can_delete_subscription = self.role.can_delete_subscription
            self.can_view_unique_subscription =self.role.can_view_unique_subscription
            self.can_export_subscription = self.role.can_export_subscription
            self.can_filter_subscription =self.role.can_filter_subscription
            self.can_activeplan_subscription = self.role.can_activeplan_subscription
            self.can_renewalplan_subscription = self.role.can_renewalplan_subscription
            self.can_unsubscribe_subscription = self.role.can_unsubscribe_subscription
            self.can_update_subscription_status = self.role.can_update_subscription_status

            # --> Market Price

            self.can_add_manage_product =  self.role.can_add_manage_product
            self.can_view_manage_product =  self.role.can_view_manage_product
            self.can_edit_manage_product =  self.role.can_edit_manage_product
            self.can_delete_manage_product =  self.role.can_delete_manage_product
            self.can_filter_manage_product =  self.role.can_filter_manage_product
            self.can_update_manage_product =  self.role.can_update_manage_product
            self.can_graph_manage_product =  self.role.can_graph_manage_product
            self.can_staff_manage_product = self.role.can_staff_manage_product

            self.can_filter_market_report  = self.role.can_filter_market_report
            self.can_view_market_report = self.role.can_view_market_report
            self.can_edit_market_report = self.role.can_edit_market_report
            self.can_graph_market_report = self.role.can_graph_market_report

            self.can_filter_product_market_report  =self.role.can_filter_product_market_report
            self.can_view_product_market_report =  self.role.can_view_product_market_report
            self.can_edit_product_market_report =  self.role.can_edit_product_market_report
            self.can_graph_product_market_report =  self.role.can_graph_product_market_report

            # --> Market Management

            self.can_add_market =  self.role.can_add_market
            self.can_view_market =  self.role.can_view_market
            self.can_edit_market = self.role.can_edit_market
            self.can_delete_market =  self.role.can_delete_market
            self.can_view_unique_market =  self.role.can_view_unique_market
            self.can_status_market =  self.role.can_status_market
            self.can_export_market =  self.role.can_export_market
            self.can_filter_market =  self.role.can_filter_market

            self.can_add_allocate_market =  self.role.can_add_allocate_market
            self.can_view_allocate_market =  self.role.can_view_allocate_market
            self.can_edit_allocate_market =  self.role.can_edit_allocate_market
            self.can_delete_allocate_market =  self.role.can_delete_allocate_market
            self.can_view_unique_allocate_market =  self.role.can_view_unique_allocate_market
            self.can_status_allocate_market =  self.role.can_status_allocate_market
            self.can_export_allocate_market = self.role.can_export_allocate_market

            # --> Schedule Management

            self.can_add_schedule_activity_type = self.role.can_add_schedule_activity_type
            self.can_edit_schedule_activity_type = self.role.can_edit_schedule_activity_type
            self.can_view_schedule_activity_type = self.role.can_view_schedule_activity_type
            self.can_delete_schedule_activity_type = self.role.can_delete_schedule_activity_type
            self.can_status_schedule_activity_type = self.role.can_status_schedule_activity_type

            self.can_add_schedule  =  self.role.can_add_schedule
            self.can_edit_schedule  =  self.role.can_edit_schedule
            self.can_view_schedule =  self.role.can_view_schedule
            self.can_delete_schedule =  self.role.can_delete_schedule
            self.can_status_schedule =  self.role.can_status_schedule
            self.can_view_unique_schedule =  self.role.can_view_unique_schedule
            self.can_filter_schedule =  self.role.can_filter_schedule
            self.can_import_schedule =  self.role.can_import_schedule

            # --> NearBy Locations

            self.can_add_near_by_location_category =  self.role.can_add_near_by_location_category
            self.can_edit_near_by_location_category =  self.role.can_edit_near_by_location_category
            self.can_view_near_by_location_category =  self.role.can_view_near_by_location_category
            self.can_delete_near_by_location_category =  self.role.can_delete_near_by_location_category
            self.can_status_near_by_location_category =  self.role.can_status_near_by_location_category

            self.can_add_near_by_locations =  self.role.can_add_near_by_locations
            self.can_edit_near_by_locations =  self.role.can_edit_near_by_locations
            self.can_view_near_by_locations =  self.role.can_view_near_by_locations
            self.can_delete_near_by_locations =  self.role.can_delete_near_by_locations
            self.can_status_near_by_locations =  self.role.can_status_near_by_locations
            self.can_export_near_by_locations =  self.role.can_export_near_by_locations
            self.can_filter_near_by_locations =  self.role.can_filter_near_by_locations
            self.can_view_unique_near_by_locations =  self.role.can_view_unique_near_by_locations

            # --> Workers Availability

            self.can_add_workers_type =  self.role.can_add_workers_type
            self.can_edit_workers_type =  self.role.can_edit_workers_type
            self.can_view_workers_type =  self.role.can_view_workers_type
            self.can_delete_workers_type =  self.role.can_delete_workers_type
            self.can_update_workers_type_status = self.role.can_update_workers_type_status
            
            self.can_add_manage_workers = self.role.can_add_manage_workers
            self.can_view_manage_workers = self.role.can_view_manage_workers
            self.can_edit_manage_workers = self.role.can_edit_manage_workers
            self.can_update_manage_workers = self.role.can_update_manage_workers
            self.can_delete_manage_workers = self.role.can_delete_manage_workers
            self.can_view_unique_manage_workers= self.role.can_view_unique_manage_workers
            self.can_update_manage_workers_status =  self.role.can_update_manage_workers_status
            self.can_export_manage_workers= self.role.can_export_manage_workers
            self.can_filter_manage_workers = self.role.can_filter_manage_workers

            # ---> Guidelines Management 

            self.can_add_guidelines_category = self.role.can_add_guidelines_category
            self.can_view_guidelines_category = self.role.can_edit_guidelines_category
            self.can_edit_guidelines_category = self.role.can_delete_guidelines_category
            self.can_delete_guidelines_category = self.role.can_delete_guidelines_category
            self.can_update_guidelines_category_status =  self.role.can_update_guidelines_category_status
            
            self.can_add_guidelines = self.role.can_add_guidelines
            self.can_view_guidelines = self.role.can_view_guidelines
            self.can_edit_guidelines = self.role.can_edit_guidelines
            self.can_delete_guidelines = self.role.can_delete_guidelines
            self.can_view_unique_guidelines= self.role.can_view_unique_guidelines
            self.can_update_guidelines_status = self.role.can_update_guidelines_status
            self.can_export_guidelines = self.role.can_export_guidelines
            self.can_filter_guidelines = self.role.can_filter_guidelines

            # ---> User Management

            self.can_view_manage_user = self.role.can_view_manage_user
            self.can_add_manage_user = self.role.can_add_manage_user
            self.can_edit_manage_user = self.role.can_edit_manage_user
            self.can_delete_manage_user = self.role.can_delete_manage_user
            self.can_export_manage_user = self.role.can_export_manage_user
            self.can_filter_manage_user = self.role.can_filter_manage_user
            self.can_status_manage_user = self.role.can_status_manage_user
            self.can_ter_status_manage_user = self.role.can_ter_status_manage_user
            self.can_rel_status_manage_user =self.role.can_rel_status_manage_user
            self.can_view_unique_manage_user = self.role.can_view_unique_manage_user

            self.can_add_manage_user_role = self.role.can_add_manage_user_role
            self.can_view_manage_user_role = self.role.can_view_manage_user_role
            self.can_status_manage_user_role = self.role.can_status_manage_user_role
            self.can_view_unique_manage_user_role = self.role.can_view_unique_manage_user_role
            self.can_edit_manage_user_role = self.role.can_edit_manage_user_role
            self.can_delete_manage_user_role = self.role.can_delete_manage_user_role

            # --> Report

            self.can_export_farmer_report = self.role.can_export_farmer_report
            self.can_view_farmer_report = self.role.can_view_farmer_report
            self.can_filter_farmer_report = self.role.can_filter_farmer_report
            self.can_view_unique_report = self.role.can_view_unique_report

            self.can_export_subscription_report =self.role.can_export_subscription_report
            self.can_view_subscription_report = self.role.can_view_subscription_report
            self.can_filter_subscription_report = self.role.can_filter_subscription_report
            self.can_view_unique_subscription_report =self.role.can_view_unique_subscription_report


            self.can_dashboard_count = self.role.can_dashboard_count
            self.can_dashboard_total_revenue = self.role.can_dashboard_total_revenue
            self.can_farmer_graph = self.role.can_farmer_graph
            self.can_subscription_graph = self.role.can_subscription_graph
            self.can_revenue_graph = self.role.can_revenue_graph
            self.can_market_view  = self.role.can_market_view
            self.can_market_graph = self.role.can_market_graph
            self.can_market_view_staff = self.role.can_market_view_staff

            self.can_add_email_config   = self.role.can_add_email_config
            self.can_view_email_config  = self.role.can_view_email_config
            self.can_status_email_config  = self.role.can_status_email_config
            self.can_edit_email_config  = self.role.can_edit_email_config
            self.can_delete_email_config  = self.role.can_delete_email_config

            self.can_view_sms_config  = self.role.can_view_sms_config
            self.can_status_sms_config  = self.role.can_status_sms_config
            self.can_delete_sms_config  = self.role.can_delete_sms_config
            self.can_edit_sms_config = self.role.can_edit_sms_config

            self.can_add_inventory_category = self.role.can_add_inventory_category
            self.can_edit_inventory_category =  self.role.can_edit_inventory_category
            self.can_view_inventory_category =  self.role.can_view_inventory_category
            self.can_delete_inventory_category =  self.role.can_delete_inventory_category
            self.can_status_inventory_category =  self.role.can_status_inventory_category

            self.can_add_inventory_items =  self.role.can_add_inventory_items
            self.can_edit_inventory_items =  self.role.can_edit_inventory_items
            self.can_view_inventory_items =  self.role.can_view_inventory_items
            self.can_delete_inventory_items =  self.role.can_delete_inventory_items
            self.can_status_inventory_items =  self.role.can_status_inventory_items

            self.can_add_document_category = self.role.can_add_document_category
            self.can_edit_document_category = self.role.can_edit_document_category
            self.can_view_document_category = self.role.can_view_document_category
            self.can_delete_document_category = self.role.can_delete_document_category
            self.can_status_document_category = self.role.can_status_document_category

            self.can_view_rental_availability = self.role.can_view_rental_availability
            self.can_filter_rental_availability = self.role.can_filter_rental_availability
            self.can_export_rental_availability = self.role.can_export_rental_availability

    def save(self, *args, **kwargs):
        if self.pk is None:  # New instance
            super().save(*args, **kwargs)  # Save to get ID
            self.create_user()  # Create CustomUser
            
        else:  # Existing instance  
            try:
                user = CustomUser.objects.get(id=self.custom_user_id)
                user.name = self.name
                user.email = self.email
                user.phone_number = self.mobile_no
                # user.set_password(str(self.password))  # Ensure password is hashed   
                user.save()  # Update existing user
            except CustomUser.DoesNotExist:
                raise ValueError(f"User with ID '{self.custom_user_id}' does not exist.")
            
            self.update_permissions_from_role()   

        super().save(*args, **kwargs) 

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class ManageUserRole(models.Model):
    name = models.CharField(max_length=100, null=True,blank=True)
    map_role = models.ForeignKey(Role, on_delete=models.CASCADE, null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='user_role_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    # Settings

    can_view_general_setting  = models.BooleanField(default=False, null=True, blank=True)
    can_edit_general_setting = models.BooleanField(default=False,null=True, blank =True) 

    can_add_country = models.BooleanField(default = False, null= True, blank=True)
    can_edit_country = models.BooleanField(default = False, null= True, blank=True)
    can_view_country = models.BooleanField(default = False, null= True, blank=True)
    can_delete_country = models.BooleanField(default = False, null= True, blank=True)
    can_status_country = models.BooleanField(default = False, null= True, blank=True)

    can_add_state = models.BooleanField(default = False, null= True, blank=True)
    can_edit_state = models.BooleanField(default = False, null= True, blank=True)
    can_view_state = models.BooleanField(default = False, null= True, blank=True)
    can_delete_state = models.BooleanField(default = False, null= True, blank=True)
    can_status_state = models.BooleanField(default = False, null= True, blank=True)

    can_add_city = models.BooleanField(default = False, null= True, blank=True)
    can_edit_city = models.BooleanField(default = False, null= True, blank=True)
    can_view_city = models.BooleanField(default = False, null= True, blank=True)
    can_delete_city = models.BooleanField(default = False, null= True, blank=True)
    can_status_city = models.BooleanField(default = False, null= True, blank=True)

    can_add_taluk = models.BooleanField(default = False, null= True, blank=True)
    can_edit_taluk = models.BooleanField(default = False, null= True, blank=True)
    can_view_taluk = models.BooleanField(default = False, null= True, blank=True)
    can_delete_taluk = models.BooleanField(default = False, null= True, blank=True)
    can_status_taluk = models.BooleanField(default = False, null= True, blank=True)

    can_add_village = models.BooleanField(default = False, null= True, blank=True)
    can_edit_village = models.BooleanField(default = False, null= True, blank=True)
    can_view_village = models.BooleanField(default = False, null= True, blank=True)
    can_delete_village = models.BooleanField(default = False, null= True, blank=True)
    can_status_village = models.BooleanField(default = False, null= True, blank=True)

    # Data Management

    can_add_land_unit = models.BooleanField(default = False, null= True, blank=True)
    can_edit_land_unit = models.BooleanField(default = False, null= True, blank=True)
    can_view_land_unit = models.BooleanField(default = False, null= True, blank=True)
    can_delete_land_unit = models.BooleanField(default = False, null= True, blank=True)
    can_status_land_unit = models.BooleanField(default = False, null= True, blank=True)
    
    can_add_area_unit = models.BooleanField(default = False, null= True, blank=True)
    can_edit_area_unit = models.BooleanField(default = False, null= True, blank=True)
    can_view_area_unit = models.BooleanField(default = False, null= True, blank=True)
    can_delete_area_unit = models.BooleanField(default = False, null= True, blank=True)
    can_status_area_unit = models.BooleanField(default = False, null= True, blank=True)

    can_add_soil_type = models.BooleanField(default = False, null= True, blank=True)
    can_edit_soil_type = models.BooleanField(default = False, null= True, blank=True)
    can_view_soil_type = models.BooleanField(default = False, null= True, blank=True)
    can_delete_soil_type = models.BooleanField(default = False, null= True, blank=True)
    can_status_soil_type = models.BooleanField(default = False, null= True, blank=True)

    can_add_crop_type = models.BooleanField(default = False, null= True, blank=True)
    can_edit_crop_type = models.BooleanField(default = False, null= True, blank=True)
    can_view_crop_type = models.BooleanField(default = False, null= True, blank=True)
    can_delete_crop_type = models.BooleanField(default = False, null= True, blank=True)
    can_status_crop_type = models.BooleanField(default = False, null= True, blank=True)

    can_add_quality = models.BooleanField(default = False, null= True, blank=True)
    can_edit_quality = models.BooleanField(default = False, null= True, blank=True)
    can_view_quality = models.BooleanField(default = False, null= True, blank=True)
    can_delete_quality = models.BooleanField(default = False, null= True, blank=True)
    can_status_quality = models.BooleanField(default = False, null= True, blank=True)

    can_add_crop = models.BooleanField(default = False, null= True, blank=True)
    can_edit_crop = models.BooleanField(default = False, null= True, blank=True)
    can_view_crop = models.BooleanField(default = False, null= True, blank=True)
    can_delete_crop = models.BooleanField(default = False, null= True, blank=True)
    can_status_crop = models.BooleanField(default = False, null= True, blank=True)

    can_add_product_type = models.BooleanField(default = False, null= True, blank=True)
    can_edit_product_type = models.BooleanField(default = False, null= True, blank=True)
    can_view_product_type = models.BooleanField(default = False, null= True, blank=True)
    can_delete_product_type = models.BooleanField(default = False, null= True, blank=True)
    can_status_product_type = models.BooleanField(default = False, null= True, blank=True)

    can_add_vehicle_category = models.BooleanField(default = False, null= True, blank=True)
    can_edit_vehicle_category = models.BooleanField(default = False, null= True, blank=True)
    can_view_vehicle_category = models.BooleanField(default = False, null= True, blank=True)
    can_delete_vehicle_category = models.BooleanField(default = False, null= True, blank=True)
    can_status_vehicle_category = models.BooleanField(default = False, null= True, blank=True)

    can_add_manage_vehicle = models.BooleanField(default = False, null= True, blank=True)
    can_edit_manage_vehicle = models.BooleanField(default = False, null= True, blank=True)
    can_view_manage_vehicle = models.BooleanField(default = False, null= True, blank=True)
    can_delete_manage_vehicle = models.BooleanField(default = False, null= True, blank=True)
    can_status_manage_vehicle = models.BooleanField(default = False, null= True, blank=True)

    can_add_machinery_category = models.BooleanField(default = False, null= True, blank=True)
    can_edit_machinery_category = models.BooleanField(default = False, null= True, blank=True)
    can_view_machinery_category = models.BooleanField(default = False, null= True, blank=True)
    can_delete_machinery_category = models.BooleanField(default = False, null= True, blank=True)
    can_status_machinery_category = models.BooleanField(default = False, null= True, blank=True)

    can_add_manage_machinery = models.BooleanField(default = False, null= True, blank=True)
    can_edit_manage_machinery = models.BooleanField(default = False, null= True, blank=True)
    can_view_manage_machinery = models.BooleanField(default = False, null= True, blank=True)
    can_delete_manage_machinery = models.BooleanField(default = False, null= True, blank=True)
    can_status_manage_machinery = models.BooleanField(default = False, null= True, blank=True)

    can_add_tool_category = models.BooleanField(default = False, null= True, blank=True)
    can_edit_tool_category = models.BooleanField(default = False, null= True, blank=True)
    can_view_tool_category = models.BooleanField(default = False, null= True, blank=True)
    can_delete_tool_category = models.BooleanField(default = False, null= True, blank=True)
    can_status_tool_category = models.BooleanField(default = False, null= True, blank=True)

    can_add_tool = models.BooleanField(default = False, null= True, blank=True)
    can_edit_tool = models.BooleanField(default = False, null= True, blank=True)
    can_view_tool = models.BooleanField(default = False, null= True, blank=True)
    can_delete_tool = models.BooleanField(default = False, null= True, blank=True)
    can_status_tool = models.BooleanField(default = False, null= True, blank=True)

    can_add_expense_category = models.BooleanField(default = False, null= True, blank=True)
    can_edit_expense_category = models.BooleanField(default = False, null= True, blank=True)
    can_view_expense_category = models.BooleanField(default = False, null= True, blank=True)
    can_delete_expense_category = models.BooleanField(default = False, null= True, blank=True)
    can_status_expense_category = models.BooleanField(default = False, null= True, blank=True)

    can_add_expense = models.BooleanField(default = False, null= True, blank=True)
    can_edit_expense = models.BooleanField(default = False, null= True, blank=True)
    can_view_expense = models.BooleanField(default = False, null= True, blank=True)
    can_delete_expense = models.BooleanField(default = False, null= True, blank=True)
    can_status_expense = models.BooleanField(default = False, null= True, blank=True)

    can_add_harvesting_type = models.BooleanField(default = False, null= True, blank=True)
    can_edit_harvesting_type = models.BooleanField(default = False, null= True, blank=True)
    can_view_harvesting_type = models.BooleanField(default = False, null= True, blank=True)
    can_delete_harvesting_type = models.BooleanField(default = False, null= True, blank=True)
    can_status_harvesting_type = models.BooleanField(default = False, null= True, blank=True)

    can_add_detection = models.BooleanField(default = False, null= True, blank=True)
    can_edit_detection = models.BooleanField(default = False, null= True, blank=True)
    can_view_detection = models.BooleanField(default = False, null= True, blank=True)
    can_delete_detection = models.BooleanField(default = False, null= True, blank=True)
    can_status_detection = models.BooleanField(default = False, null= True, blank=True)

    # farmer management
    can_add_farmer = models.BooleanField(default=False, null=True, blank=True)
    can_view_farmer = models.BooleanField(default=False, null=True, blank=True)
    can_edit_farmer = models.BooleanField(default=False, null=True, blank=True)
    can_delete_farmer = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_farmer = models.BooleanField(default=False, null=True, blank=True)
    can_update_farmer_status = models.BooleanField(default=False, null=True, blank=True)  
    can_export_farmer_data = models.BooleanField(default=False, null=True, blank=True)  
    can_filter_farmer_data = models.BooleanField(default=False, null=True, blank=True)
    can_subscribe_farmer_package = models.BooleanField(default=False, null=True, blank=True)
    can_unsubscribe_farmer_package = models.BooleanField(default=False, null=True, blank=True)

    # package management
    can_add_package = models.BooleanField(default=False, null=True, blank=True)
    can_view_package = models.BooleanField(default=False, null=True, blank=True)
    can_edit_package = models.BooleanField(default=False, null=True, blank=True)
    can_delete_package = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_package = models.BooleanField(default=False, null=True, blank=True)

    # subscription management
    can_add_subscription = models.BooleanField(default=False, null=True, blank=True)
    can_view_subscription = models.BooleanField(default=False, null=True, blank=True)
    can_edit_subscription = models.BooleanField(default=False, null=True, blank=True)
    can_delete_subscription = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_subscription = models.BooleanField(default=False, null=True, blank=True)
    can_export_subscription = models.BooleanField(default=False, null=True,blank=True)
    can_filter_subscription = models.BooleanField(default = False, null=True, blank =True)
    can_activeplan_subscription = models.BooleanField(default =False, null =True, blank =True)
    can_renewalplan_subscription = models.BooleanField(default=False, null =True, blank=True)
    can_unsubscribe_subscription = models.BooleanField(default=False, null =True, blank=True)
    can_update_subscription_status = models.BooleanField(default=False, null=True, blank=True)  

    # --> Market Price

    can_add_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_view_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_edit_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_delete_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_filter_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_update_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_graph_manage_product = models.BooleanField(default=False, null=True, blank=True)
    can_staff_manage_product = models.BooleanField(default=False, null=True, blank=True)

    can_filter_market_report  = models.BooleanField(default=False, null=True, blank=True)
    can_view_market_report = models.BooleanField(default=False, null=True, blank=True)
    can_edit_market_report = models.BooleanField(default=False, null=True, blank=True) 
    can_graph_market_report = models.BooleanField(default=False, null=True, blank=True)

    can_filter_product_market_report  = models.BooleanField(default=False, null=True, blank=True)
    can_view_product_market_report = models.BooleanField(default=False, null=True, blank=True)
    can_edit_product_market_report = models.BooleanField(default=False, null=True, blank=True) 
    can_graph_product_market_report = models.BooleanField(default=False, null=True, blank=True)

    # --> Market Management

    can_add_market = models.BooleanField(default=False, null=True, blank=True)
    can_view_market = models.BooleanField(default=False, null=True, blank=True)
    can_edit_market = models.BooleanField(default=False, null=True, blank=True)
    can_delete_market = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_market = models.BooleanField(default=False, null=True, blank=True)
    can_status_market = models.BooleanField(default=False, null=True, blank=True)
    can_export_market = models.BooleanField(default=False, null=True, blank=True)
    can_filter_market = models.BooleanField(default=False, null=True, blank=True)

    can_add_allocate_market = models.BooleanField(default=False, null=True, blank=True)
    can_view_allocate_market = models.BooleanField(default=False, null=True, blank=True)
    can_edit_allocate_market = models.BooleanField(default=False, null=True, blank=True)
    can_delete_allocate_market = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_allocate_market = models.BooleanField(default=False, null=True, blank=True)
    can_status_allocate_market = models.BooleanField(default=False, null=True, blank=True)
    can_export_allocate_market = models.BooleanField(default=False, null=True, blank=True)

    # --> Schedule Management

    can_add_schedule_activity_type = models.BooleanField(default=False, null=True, blank=True)
    can_edit_schedule_activity_type = models.BooleanField(default=False, null=True, blank=True)
    can_view_schedule_activity_type = models.BooleanField(default=False, null=True, blank=True)
    can_delete_schedule_activity_type = models.BooleanField(default=False, null=True, blank=True)
    can_status_schedule_activity_type = models.BooleanField(default=False, null=True, blank=True)

    can_add_schedule  = models.BooleanField(default=False, null=True, blank=True)
    can_edit_schedule  = models.BooleanField(default=False, null=True, blank=True)
    can_view_schedule = models.BooleanField(default=False, null=True, blank=True)
    can_delete_schedule = models.BooleanField(default=False, null=True, blank=True)
    can_status_schedule = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_schedule = models.BooleanField(default=False, null=True, blank=True)
    can_filter_schedule = models.BooleanField(default=False, null =True, blank=True)
    can_import_schedule = models.BooleanField(default=False, null =True, blank=True)

    # --> NearBy Locations

    can_add_near_by_location_category = models.BooleanField(default=False, null=True, blank=True)
    can_edit_near_by_location_category = models.BooleanField(default=False, null=True, blank=True)
    can_view_near_by_location_category = models.BooleanField(default=False, null=True, blank=True)
    can_delete_near_by_location_category = models.BooleanField(default=False, null=True, blank=True)
    can_status_near_by_location_category = models.BooleanField(default=False, null=True, blank=True)

    can_add_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_edit_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_view_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_delete_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_status_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_export_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_filter_near_by_locations = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_near_by_locations = models.BooleanField(default=False, null=True, blank=True)

    # --> Workers Availability

    can_add_workers_type = models.BooleanField(default=False, null=True, blank=True)
    can_edit_workers_type = models.BooleanField(default=False, null=True, blank=True)
    can_view_workers_type = models.BooleanField(default=False, null=True, blank=True)
    can_delete_workers_type = models.BooleanField(default=False, null=True, blank=True)
    can_update_workers_type_status = models.BooleanField(default=False, null=True, blank=True)  
    
    can_add_manage_workers = models.BooleanField(default=False, null=True, blank=True)
    can_view_manage_workers = models.BooleanField(default=False, null=True, blank=True)
    can_edit_manage_workers = models.BooleanField(default=False, null=True, blank=True)
    can_update_manage_workers = models.BooleanField(default=False, null=True,blank=True)
    can_delete_manage_workers = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_manage_workers= models.BooleanField(default=False, null=True, blank=True)
    can_update_manage_workers_status = models.BooleanField(default=False, null=True, blank=True)  
    can_export_manage_workers= models.BooleanField(default=False, null=True, blank=True)  
    can_filter_manage_workers = models.BooleanField(default=False, null=True, blank=True)

    # ---> Guidelines Management 

    can_add_guidelines_category = models.BooleanField(default=False, null=True, blank=True)
    can_view_guidelines_category = models.BooleanField(default=False, null=True, blank=True)
    can_edit_guidelines_category = models.BooleanField(default=False, null=True, blank=True) 
    can_delete_guidelines_category = models.BooleanField(default=False, null=True, blank=True)
    can_update_guidelines_category_status = models.BooleanField(default=False, null=True, blank=True)  
    
    can_add_guidelines = models.BooleanField(default=False, null=True, blank=True)
    can_view_guidelines = models.BooleanField(default=False, null=True, blank=True)
    can_edit_guidelines = models.BooleanField(default=False, null=True, blank=True)
    can_delete_guidelines = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_guidelines= models.BooleanField(default=False, null=True, blank=True)
    can_update_guidelines_status = models.BooleanField(default=False, null=True, blank=True)  
    can_export_guidelines = models.BooleanField(default=False, null=True, blank=True)  
    can_filter_guidelines = models.BooleanField(default=False, null=True, blank=True)

    # ---> User Management

    can_view_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_add_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_edit_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_delete_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_export_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_filter_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_status_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_ter_status_manage_user = models.BooleanField(default=False, null=True, blank=True)
    can_rel_status_manage_user = models.BooleanField(default = False, null =True, blank= True)
    can_view_unique_manage_user = models.BooleanField(default=False, null=True, blank=True)

    can_add_manage_user_role = models.BooleanField(default=False, null=True, blank=True)
    can_view_manage_user_role = models.BooleanField(default=False, null=True, blank=True)
    can_status_manage_user_role = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_manage_user_role = models.BooleanField(default=False, null=True, blank=True)
    can_edit_manage_user_role = models.BooleanField(default=False, null=True, blank=True)
    can_delete_manage_user_role = models.BooleanField(default=False, null=True, blank=True)

    # --> Report

    can_export_farmer_report = models.BooleanField(default=False, null=True, blank=True)
    can_view_farmer_report = models.BooleanField(default=False, null=True, blank=True)
    can_filter_farmer_report = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_report = models.BooleanField(default=False, null=True, blank=True)

    can_export_subscription_report = models.BooleanField(default=False, null=True, blank=True)
    can_view_subscription_report = models.BooleanField(default=False, null=True, blank=True)
    can_filter_subscription_report = models.BooleanField(default=False, null=True, blank=True)
    can_view_unique_subscription_report = models.BooleanField(default=False, null=True, blank=True)


    can_dashboard_count = models.BooleanField(default=False, null=True, blank=True)
    can_dashboard_total_revenue = models.BooleanField(default=False, null=True, blank=True)
    can_farmer_graph = models.BooleanField(default=False, null=True, blank=True)
    can_subscription_graph = models.BooleanField(default=False, null=True, blank=True)
    can_revenue_graph = models.BooleanField(default=False, null=True, blank=True)
    can_market_view  = models.BooleanField(default=False, null=True, blank=True)
    can_market_graph = models.BooleanField(default=False, null=True, blank=True)
    can_market_view_staff = models.BooleanField(default=False, null=True, blank=True)

    can_add_email_config   = models.BooleanField(default=False, null=True, blank=True)
    can_view_email_config  = models.BooleanField(default=False, null=True, blank=True)
    can_status_email_config  = models.BooleanField(default=False, null=True, blank=True)
    can_edit_email_config  = models.BooleanField(default=False, null=True, blank=True)
    can_delete_email_config  = models.BooleanField(default=False, null=True, blank=True)

    can_view_sms_config  = models.BooleanField(default=False, null=True, blank=True)
    can_status_sms_config  = models.BooleanField(default=False, null=True, blank=True)
    can_delete_sms_config  = models.BooleanField(default=False, null=True, blank=True)
    can_edit_sms_config = models.BooleanField(default=False,null =True, blank=True)

    can_add_inventory_category = models.BooleanField(default = False, null= True, blank=True)
    can_edit_inventory_category = models.BooleanField(default = False, null= True, blank=True)
    can_view_inventory_category = models.BooleanField(default = False, null= True, blank=True)
    can_delete_inventory_category = models.BooleanField(default = False, null= True, blank=True)
    can_status_inventory_category = models.BooleanField(default = False, null= True, blank=True)

    can_add_inventory_items = models.BooleanField(default = False, null= True, blank=True)
    can_edit_inventory_items = models.BooleanField(default = False, null= True, blank=True)
    can_view_inventory_items = models.BooleanField(default = False, null= True, blank=True)
    can_delete_inventory_items = models.BooleanField(default = False, null= True, blank=True)
    can_status_inventory_items = models.BooleanField(default = False, null= True, blank=True)

    can_add_document_category = models.BooleanField(default = False, null= True, blank=True)
    can_edit_document_category = models.BooleanField(default = False, null= True, blank=True)
    can_view_document_category = models.BooleanField(default = False, null= True, blank=True)
    can_delete_document_category = models.BooleanField(default = False, null= True, blank=True)
    can_status_document_category = models.BooleanField(default = False, null= True, blank=True)

    # ---> Rental Availability
    can_view_rental_availability = models.BooleanField(default=False, null=True, blank=True)
    can_filter_rental_availability = models.BooleanField(default=False, null=True, blank=True)
    can_export_rental_availability = models.BooleanField(default=False, null=True, blank=True) 


    def __str__(self):
        return self.name

class UserProfileStatus(models.Model):
    name = models.ForeignKey(ManageUser, on_delete=models.CASCADE, null=True, blank=True)
    terminate = models.IntegerField(null=True, blank=True, default=0)
    releave = models.IntegerField(null=True, blank=True, default=0)
    active = models.IntegerField(default=1, null=True, blank=True)
    description = models.CharField(max_length=200, null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='profile_status_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
 
# -------------------------------------------------------------------> Reports --------------

class FarmerReport(models.Model):
    farmer = models.OneToOneField(Farmer, on_delete=models.CASCADE, related_name='report')
    subscription_details = models.JSONField(null=True, blank=True)
    package_details = models.JSONField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Report for {self.farmer.name}"

class SubscriptionReport(models.Model):
    package = models.ForeignKey(PackageManagement, on_delete=models.CASCADE, null=True, blank=True)
    renewal = models.IntegerField(default=0,null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    total_revenue = models.DecimalField(max_digits=10, decimal_places=2, default=0, null=True, blank=True)
    total_farmers = models.IntegerField(default=0, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)


    def __str__(self):
        return f"Report for {self.package.name} - {self.total_revenue} - {self.total_farmers}"

    # def generate_report(self):
    #     """Generates the report for a specific package and month."""
    #     start_of_month = timezone.datetime(self.year, self.month, 1)
    #     end_of_month = timezone.datetime(self.year, self.month + 1, 1) - timedelta(days=1)

    #     subscriptions = AddSubcription.objects.filter(
    #         packages=self.package,
    #         startdate__gte=start_of_month,
    #         startdate__lte=end_of_month
    #     )

    #     total_farmers = subscriptions.count()

    #     self.total_farmers = total_farmers
    #     self.save() 

    #     return {
    #         "package_name": self.package.name,
    #         "total_farmers": total_farmers,
    #         "farmers_details": self.get_farmers_details(subscriptions),
    #         "today_revenue": self.get_today_revenue(),
    #         "month_revenue": self.get_month_revenue(),
    #         "year_revenue": self.get_year_revenue(),
    #     }

    # def get_farmers_details(self, subscriptions):
    #     """Fetches farmer details for the subscriptions."""
    #     farmers_data = []
    #     for subscription in subscriptions:
    #         farmer_data = {
    #             'farmer_name': subscription.farmers.name,
    #             'farmer_email': subscription.farmers.email,
    #             'farmer_phone': subscription.farmers.phone,
    #             'subscription_amount': subscription.amount,
    #             'remaining_days': subscription.remainingdays,
    #             'subscription_start_date': subscription.startdate,
    #             'subscription_end_date': subscription.enddate,
    #         }
    #         farmers_data.append(farmer_data)
    #     return farmers_data
 
CustomUser = get_user_model()  

class UserSession(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    login_time = models.DateTimeField(null=True, blank=True)
    logout_time = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"Session for {self.user.name} at {self.login_time}"

    @property
    def duration(self):
        if self.logout_time:
            return self.logout_time - self.login_time
        return None
    


class ThemeSetting(models.Model):
    primary_color = models.CharField(max_length=7, default='{{ primary_color }}')  # e.g., {{ primary_color }}
    primary_color_rgb = models.CharField(max_length=20, default='107, 140, 40')  # e.g., "107, 140, 40"
    test_field = models.CharField(max_length=20, default='test')

    def __str__(self):
        return f"Theme - {self.primary_color}"
