from django.db import models 
from auth.models import *
from ai.models import * 


#### --------------------------- Notification ----------------------------

class FarmerNotification(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null = True,blank=True)
    name = models.CharField(max_length=255, null=True, blank=True)
    type = models.CharField(null=True,blank=True,max_length=100)
    message = models.CharField(max_length=255, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False) 
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.message
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

# ----------------------------------- my land ------------------------------
class MyLand(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True) #OK
    name = models.CharField(max_length=100) #OK
    measurement_value = models.IntegerField(null=True,blank=True) #(WEB)
    measurement_unit = models.ForeignKey(LandUnit,null=True,blank=True,on_delete=models.CASCADE)  #(WEB)
    soil_type = models.ForeignKey(SoilType,on_delete=models.CASCADE, null=True, blank=True) #OK
    country = models.ForeignKey(Country,on_delete= models.CASCADE,null=True,blank=True) #OK
    state = models.ForeignKey(State, on_delete=models.CASCADE, null=True, blank=True) #OK
    city = models.ForeignKey(City, on_delete= models.CASCADE, null=True, blank=True) #OK
    taluk = models.ForeignKey(Taluk, on_delete=models.CASCADE, null = True, blank=True) #OK
    village = models.ForeignKey(Village, on_delete=models.CASCADE,null=True,blank=True) #OK
    door_no = models.CharField(max_length=500, null=True, blank=True)  #(WEB)
    pincode = models.IntegerField(default=0, null=True, blank=True)
    locations = models.CharField(max_length=200, null=True, blank=True) #OK
    latitude = models.FloatField(null=True, blank=True)  #(Mob) (pass from web)
    longitude = models.FloatField(null=True, blank=True) #(Mob) (pass from web)
    patta_number = models.CharField(max_length=150,null=True, blank=True) #OK
    description = models.TextField(null =True, blank=True)   #(WEB)
    code = models.IntegerField(null=True, blank=True) # not in use for future
    status = models.IntegerField(default=0,null=True,blank=True)   # default
    l_status = models.IntegerField(default=0, null=True, blank=True) # Mob in Future
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  # default
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_land_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)   #default
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_land_updated_by')
    translate_json = models.JSONField(null=True, blank=True)
    manager = models.ForeignKey("ManagerUser", on_delete=models.CASCADE, null=True, blank=True)
    geo_marks = models.JSONField(default=list, null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    
class MyLandSurveyDetails(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True) #Connectiom
    MyLand = models.ForeignKey(MyLand,null=True,blank=True,on_delete=models.CASCADE, related_name='survey_details') #Connectiom
    survey_no = models.CharField(max_length=100, null=True, blank=True) #both
    survey_measurement_value = models.DecimalField(null=True, blank=True,decimal_places=2, max_digits=15) #both
    survey_measurement_unit = models.ForeignKey(LandUnit,null=True,blank=True,on_delete=models.CASCADE) #both
    status = models.IntegerField(default=0,null=True,blank=True)  # default
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)   # default
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_land_survey_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  # default
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_land_survey_updated_by')

    def __str__(self):
        return self.survey_no

class MyLandDocument(models.Model):
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True) #Connectiom
    myland = models.ForeignKey(MyLand,null=True,blank=True,on_delete=models.CASCADE , related_name='documents') #Connectiom
    document_category = models.ForeignKey(DocumentCategory,null=True,blank=True,on_delete=models.CASCADE) #both
    upload_document = models.FileField(upload_to='media/my_land/', null=True, blank=True) #both
    status = models.IntegerField(default=0,null=True,blank=True)  # default
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  # default
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_land_doc_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)   # default
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_land_doc_updated_by')

    def __str__(self):
        # Return created_by or fallback to a description
        return self.created_by if self.created_by else f"MyLandDocument #{self.id}"


# ------------------------------------ my crop  & Schedule --------------------------

CROP_STATUS_CHOICES = [
    (0, 'In Progress'),
    (1, 'Completed'),
]

class MyCrop(models.Model): 
    farmer= models.ForeignKey(Farmer, on_delete=models.CASCADE, null =True, blank=True) # default
    crop_type= models.ForeignKey(CropType, on_delete=models.CASCADE, null =True, blank=True) # both
    crop = models.ForeignKey(Crop, on_delete=models.CASCADE, null =True, blank= True) # both
    # crop_img = models.ImageField(upload_to='media/crop/', null=True, blank=True) # not needed now
    harvesting_type = models.ForeignKey(HarvestingType, on_delete=models.CASCADE, null= True, blank =True) #both
    plantation_date = models.DateField(null= True, blank=True) #both
    land = models.ForeignKey(MyLand, on_delete= models.CASCADE, null=True, blank=True) #both
    soil_type = models. ForeignKey(SoilType, on_delete= models.CASCADE, null=True, blank=True) # web
    taluk = models.ForeignKey(Taluk, on_delete=models.CASCADE, null = True, blank=True) # web
    village = models.ForeignKey(Village, on_delete=models.CASCADE,null=True,blank=True) # web
    measurement_value = models.IntegerField(null=True,blank=True) #both
    measurement_unit = models.ForeignKey(LandUnit,null=True,blank=True,on_delete=models.CASCADE) # both
    survey_details = models.ManyToManyField(MyLandSurveyDetails, blank=True ) # both
    status = models.IntegerField(default=0,null=True,blank=True)   # default
    description= models.TextField(null=True, blank=True) # web
    code = models.IntegerField(null=True, blank=True) # default not in use as of now
    status = models.IntegerField(default=0,null=True,blank=True)  # default
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  #default
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_crop_created_by') #default
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)   #default
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_crop_updated_by') #default
    geo_marks = models.JSONField(default=list, null=True, blank=True) # mob 
    c_status = models.IntegerField(default=0, null=True, blank=True) # mob
    expense = models.CharField(max_length=100, null=True, blank=True) # mob
    sales  = models.CharField(max_length=100, null=True, blank=True) #mob
    crop_status = models.IntegerField(choices=CROP_STATUS_CHOICES, default=0)
    translate_json = models.JSONField(null=True, blank=True)

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

    # def __str__(self):
    #     return f'{self.id}'


class ScheduleStatus(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    name = models.CharField(max_length=100)
    code = models.CharField(max_length=200, null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)   
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_schedulestatue_created_by') #default
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_schedulestatus_updated_by') #default
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    
    
SCHEDULE_CHOICES = [
    (0, 'Daily'),
    (1, 'Weekly'),
    (2, 'Monthly'),
]

SCHEDULE_WEEKLY =[
    (0, 'Sunday'),
    (1,'Monday'),
    (2,'Tuesday'),
    (3,'Wednesday'),
    (4,'Thursday'),
    (5,'Friday'),
    (6,'Saturday'),
]

SCHEDULE_MONTHLY =[
    (0,'January'),
    (1,'February'),
    (2,'March'),
    (3,'April'),
    (4,'May'),
    (5,'June'),
    (6,'July'),
    (7,'Augest'),
    (8,'September'),
    (9,'October'),
    (10,'November'),
    (11,'December'),
    
]

SCHEDULE_YEAR =[
    (0,'01-2025'),
    (1,'02-2025'),
    (2,'03-2025'),
    (3,'04-2025'),
    (4,'05-2025'),
    (5,'06-2025'),
    (6,'07-2025'),
    (7,'08-2025'),
    (8,'09-2025'),
    (9,'10-2025'),
    (10,'11-2025'),
    (11,'12-2025'),
    (12,'13-2025'),
    (13,'14-2025'),
    (14,'15-2025'),
    (15,'16-2025'),
    (16,'17-2025'),
    (17,'18-2025'),
    (18,'19-2025'),
    (19,'20-2025'),
    (20,'21-2025'),
    (21,'22-2025'),
    (22,'23-2025'),
    (23,'24-2025'),
    (24,'25-2025'),
    (25,'26-2025'),
    (26,'27-2025'),
    (27,'28-2025'),
    (28,'29-2025'),
    (29,'30-2025'),
    (30,'31-2025'), 
]

class ScheduleWeekly(models.Model):
    name = models.CharField(max_length=100)
    status = models.IntegerField(default=0,null=True,blank=True)  #default
    code = models.IntegerField(null=True,blank=True)
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  # default
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True ) #default
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  # default
    
    def __str__(self):
        return self.name

class ScheduleMonthly(models.Model):
    name = models.CharField(max_length=100)
    code = models.IntegerField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  #default
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  # default
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True ) #default
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  # default
    
    def __str__(self):
        return self.name

class ScheduleYear(models.Model):
    name = models.CharField(max_length=100)
    code = models.IntegerField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  #default
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  # default
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True ) #default
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  # default
 

    def __str__(self):
        return self.name

class MySchedule(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True) # default
    manage_schedule = models.ForeignKey(Schedule,on_delete=models.CASCADE, null=True, blank=True) # web
    my_land = models.ForeignKey(MyLand, on_delete=models.CASCADE, null=True, blank=True) # web
    my_crop = models.ForeignKey(MyCrop, on_delete=models.CASCADE, null=True, blank=True) # default
    schedule_activity_type = models.ForeignKey(ScheduleActivityType, on_delete=models.CASCADE, null=True, blank=True) # both
    start_date = models.DateField(null=True, blank=True) # both
    end_date = models.DateField(null=True, blank=True) # both
    schedule_status = models.ForeignKey(ScheduleStatus,null=True, blank=True, on_delete=models.CASCADE)  # both
    status = models.IntegerField(default=0,null=True,blank=True)  #default
    schedule = models.CharField(max_length=2000, null=True, blank=True) # both (!!!! Description for mobile !!!!!)
    comment = models.TextField(null=True, blank=True) # mob
    schedule_choice = models.IntegerField(choices=SCHEDULE_CHOICES, default=0)
    schedule_weekly = models.ManyToManyField('ScheduleWeekly', blank=True)  # Checkboxes for weekly choices
    schedule_monthly = models.ManyToManyField('ScheduleMonthly', blank=True)  # Checkboxes for monthly choices
    schedule_year = models.ManyToManyField('ScheduleYear', blank=True)
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  # default
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_schedule_created_by') #default
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  # default
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_schedule_updated_by') #default
    translate_json = models.JSONField(null=True, blank=True)

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

    # def __str__(self):
    #     return f"Schedule for {self.my_crop} from {self.start_date} to {self.end_date}"

# ------------------------------------------------- Sales & Customer ------------------------------------

class MyCustomer(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True, related_name='customers')
    customer_name = models.CharField(max_length=200)
    shop_name = models.CharField(max_length=200, null =True, blank=True) 
    mobile_no = models.CharField(max_length= 15, null=True, blank=True)
    email = models.EmailField(null=True,blank=True)
    market = models.ManyToManyField(ManageMarket)
    door_no = models.CharField(max_length= 100, null=True, blank=True)  
    country = models.ForeignKey(Country,on_delete= models.CASCADE,null=True,blank=True)
    state = models.ForeignKey(State, on_delete=models.CASCADE, null=True, blank=True)
    city = models.ForeignKey(City, on_delete= models.CASCADE, null=True, blank=True)    
    taluk = models.ForeignKey(Taluk, on_delete=models.CASCADE, null = True, blank=True)
    village = models.ForeignKey(Village, on_delete=models.CASCADE,null=True,blank=True)  
    post_code = models.IntegerField(null=True,blank=True)
    gst_no = models.CharField(max_length=200, null=True,blank=True)
    tax_no = models.CharField(max_length=200, null=True,blank=True)
    is_credit = models.BooleanField(default=True,null=True,blank=True) 
    opening_balance = models.IntegerField(null=True,blank=True) 
    receivables = models.IntegerField(default=0,null=True,blank=True)
    payables = models.IntegerField(default=0,null=True,blank=True)
    customer_img = models.ImageField(upload_to='media/customer_img/', null=True, blank=True)
    description= models.TextField(null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_customer')
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True )
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True) 
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    is_customer_is_vendor = models.BooleanField(default=False, null=True, blank=True) 
    vendor = models.ForeignKey('MyVendor', on_delete=models.CASCADE, null=True, blank=True, related_name='vendors_connection')
    translate_json = models.JSONField(null=True, blank=True)
    locations = models.CharField(max_length=200, null=True, blank=True) #OK
    latitude = models.FloatField(null=True, blank=True)  #(Mob) (pass from web)
    longitude = models.FloatField(null=True, blank=True) #(Mob) (pass from web)

    def __str__(self):
        return self.customer_name

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    
    # def save(self, *args, **kwargs):
    #     if not self.is_credit:  # Debit
    #         self.opening_balance = -abs(self.opening_balance)  # Make debit values negative
    #     else:  # Credit
    #         self.opening_balance = abs(self.opening_balance)  # Ensure credit values are positive
    #     super(MyCustomer, self).save(*args, **kwargs)
    
class MySales(models.Model):
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True)
    dates_of_sales = models.DateField(null=True, blank=True)
    sale_type = models.BooleanField(default=False) # 0 -wholesale, 1 - Retail
    land = models.ForeignKey(MyLand, on_delete= models.CASCADE, null=True, blank=True)
    my_crop = models.ForeignKey(MyCrop, null=True, blank=True, on_delete=models.CASCADE)
    my_customer = models.ForeignKey(MyCustomer, null=True, blank=True, on_delete=models.CASCADE)
    sales_quantity = models.IntegerField(null=True, blank=True)
    sales_unit = models.ForeignKey(AreaUnit, null=True, blank=True, on_delete=models.CASCADE)
    quantity_amount = models.CharField(max_length=100, null=True, blank=True)
    total_amount = models.CharField(max_length=100, null=True, blank=True)
    sales_amount = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    deduction_amount = models.CharField(default=0,max_length=100, null=True, blank=True)
    total_sales_amount = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    amount_paid = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_sales')
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True )
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True) 
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    translate_json = models.JSONField(null=True, blank=True)

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

    def save(self, *args, **kwargs): 
        if self.sales_quantity is not None and self.quantity_amount:
            try:
                self.total_amount = str(int(self.sales_quantity) * float(self.quantity_amount))   
            except ValueError:
                self.total_amount = "0"
         
        self.sales_amount = self.total_amount
         
        try:
            self.total_sales_amount = str(float(self.sales_amount) - float(self.deduction_amount))  
        except (ValueError, TypeError):   
            self.total_sales_amount = "0"
 
        super(MySales, self).save(*args, **kwargs)

class Reasons(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    name = models.CharField(max_length=200)
    code = models.CharField(max_length =200, null=True, blank=True)
    description = models.TextField(null=True,blank=True)
    translate_json = models.JSONField(null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='reason')
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True )
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True) 
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class Rupee(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    name = models.CharField(max_length=200)
    code = models.CharField(max_length =200, null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='rupee_created_by')
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True )
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True) 
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    
    def __str__(self):
        return self.name

class DeductionReasons(models.Model):
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True)
    my_sales = models.ForeignKey(MySales, null=True, blank=True, on_delete=models.CASCADE)
    reason = models.ForeignKey(Reasons, null=True, blank=True, on_delete=models.CASCADE)
    charges = models.CharField(max_length=200, null=True, blank=True)
    rupee = models.ForeignKey(Rupee, null=True, blank=True, on_delete=models.CASCADE)
    code = models.CharField(max_length =200, null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True) 
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='deduction_reason')
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True )
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True) 
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    translate_json = models.JSONField(null=True, blank=True)

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)


class SalesDocument(models.Model): 
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)   
    my_sales = models.ForeignKey(MySales, null=True, blank=True, on_delete=models.CASCADE)
    document_category = models.ForeignKey(DocumentCategory, null=True, blank=True, on_delete= models.CASCADE)
    file_upload = models.FileField(upload_to='media/sales_document/', null=True, blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='sales_document')
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True )
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True) 
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  


#----------------------------------Expenses---------------------------------

class MyExpense(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    my_crop = models.ForeignKey(MyCrop, on_delete=models.CASCADE, null=True, blank=True) 
    type_expenses = models.ForeignKey(Expenses , on_delete=models.CASCADE , null=True, blank=True)
    vendor = models.ForeignKey('MyVendor', on_delete=models.CASCADE, null=True, blank=True)
    amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    paid_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    description = models.TextField(null=True, blank=True)
    code = models.IntegerField(null=True, blank=True)
    status = models.IntegerField(default=0, null=True, blank=True)  
    created_day = models.DateField(null=True, blank=True)  
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_expense_created_at')
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_expense_updated_by')
    identify = models.IntegerField(null=True, blank=True,default=0)
    translate_json = models.JSONField(null=True, blank=True)
    # document = models.FileField(upload_to='my_expense/', blank=True, null=True) 

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    
    def clean(self):
        if self.created_by and not CustomUser.objects.filter(id=self.created_by.id).exists():
            raise ValidationError(f"User with ID {self.created_by.id} does not exist.")

    @property
    def crop_type_and_crop(self): 
        if self.my_crop:
            crop_type_name = self.my_crop.crop_type.name if self.my_crop.crop_type else None
            crop_name = self.my_crop.crop.name if self.my_crop.crop else None
            crop_img = self.my_crop.crop_img if self.my_crop.crop_img else None
            land_name = self.my_crop.land.name if self.my_crop.land else None
            measurement_value = self.my_crop.measurement_value if self.my_crop.measurement_value else None
            measurement_unit = self.my_crop.measurement_unit.name if self.my_crop.measurement_unit else None
            taluk = self.my_crop.taluk if self.my_crop.taluk else None
            village = self.my_crop.village if self.my_crop.village else None
             
            return {
                "crop_type": crop_type_name,
                "crop": crop_name,
                "land_name": land_name,
                "measurement_value": measurement_value,
                "measurement_unit": measurement_unit,
                "taluk": taluk,
                "village": village,
                "crop_img": crop_img,
            }
        return None

class ExpenseFile(models.Model): 
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    my_expense = models.ForeignKey(MyExpense, related_name='expense_files', on_delete=models.CASCADE)  
    file_type = models.ForeignKey(DocumentCategory , on_delete=models.CASCADE , null=True, blank=True)
    file = models.FileField(upload_to='expense_files/', null=True, blank=True)   
    uploaded_at = models.DateTimeField(auto_now_add=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_expense_file_created_at')
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_expense_file_updated_by')

    def __str__(self):
        return f"File for {self.my_expense} uploaded on {self.uploaded_at}"

# ----------------------------My Vendors --------------------------------

class MyVendor(models.Model):
    customer = models.ForeignKey('MyCustomer', on_delete=models.CASCADE, null=True, blank=True, related_name='vendors')
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True, related_name='vendors')
    name = models.CharField(max_length=50)
    business_name = models.CharField(max_length=50, null=True, blank=True)
    inventory_type = models.ManyToManyField(InventoryType, blank=True)
    email = models.EmailField(null=True, blank=True)
    mobile_no = models.BigIntegerField(null=True, blank=True)
    alter_mobile_no = models.BigIntegerField(null=True, blank=True)
    door_no = models.CharField(max_length=200, null=True, blank=True)
    country = models.ForeignKey(Country,on_delete= models.CASCADE,null=True,blank=True)
    state = models.ForeignKey(State, on_delete=models.CASCADE, null=True, blank=True)
    city = models.ForeignKey(City, on_delete= models.CASCADE, null=True, blank=True)
    taluk = models.ForeignKey(Taluk, on_delete=models.CASCADE, null = True, blank=True)
    village = models.ForeignKey(Village, on_delete=models.CASCADE,null=True,blank=True)
    pincode = models.IntegerField(default=0, null=True, blank=True)
    gst_number = models.CharField(max_length=200, null=True,blank=True)
    tax_number = models.CharField(max_length=200, null=True,blank=True)
    credit = models.BooleanField(default=False)
    debit = models.BooleanField(default=False)
    opening_balance = models.IntegerField(default=0,null=True,blank=True)
    receivables = models.IntegerField(default=0,null=True,blank=True)
    payables = models.IntegerField(default=0,null=True,blank=True)
    vendor_image = models.ImageField(upload_to='myvendors/', null=True, blank=True)
    description = models.TextField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)  
    created_at = models.DateTimeField(null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='myvendor_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='updated_by')
    translate_json = models.JSONField(null=True, blank=True)
    is_customer_is_vendor = models.BooleanField(default=False, null=True, blank=True) 
    locations = models.CharField(max_length=200, null=True, blank=True) #OK
    latitude = models.FloatField(null=True, blank=True)  #(Mob) (pass from web)
    longitude = models.FloatField(null=True, blank=True) #(Mob) (pass from web)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
 
# --------------------------------------------------My Purchase -----------------------


class MyFuel(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    date_of_consumption = models.DateField(null=True,blank=True)
    vendor = models.ForeignKey(MyVendor, on_delete=models.CASCADE, null=True, blank=True)
    inventory_type = models.ForeignKey(InventoryType, on_delete=models.CASCADE, null=True, blank=True)
    inventory_category = models.ForeignKey(InventoryCategory, on_delete=models.CASCADE, null=True, blank=True)
    inventory_items = models.ForeignKey(InventoryItems, on_delete=models.CASCADE, null=True, blank=True)
    quantity = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    purchase_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    paid_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    description = models.TextField(null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='myfuel_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    identify = models.IntegerField(null=True, blank=True,default=1)
    available_quans = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    translate_json = models.JSONField(null=True, blank=True)

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

    # def __str__(self):
    #     return self.inventory_items.name

class MyFuelDocuments(models.Model):
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True)
    document = models.FileField(upload_to='myFuel_documents/', null=True, blank=True)
    fuel = models.ForeignKey(MyFuel, on_delete=models.CASCADE, null=True, blank=True)
    file_type = models.ForeignKey(DocumentCategory , on_delete=models.CASCADE , null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='myfuel_document_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return self.document.name


class MyVehicle(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    date_of_consumption = models.DateField(null=True,blank=True)
    vendor = models.ForeignKey(MyVendor, on_delete=models.CASCADE, null=True, blank=True)
    inventory_type = models.ForeignKey(InventoryType, on_delete=models.CASCADE, null=True, blank=True)
    inventory_category = models.ForeignKey(InventoryCategory, on_delete=models.CASCADE, null=True, blank=True)
    inventory_items = models.ForeignKey(InventoryItems, on_delete=models.CASCADE, null=True, blank=True)
    register_number = models.CharField(null=True,blank=True,max_length=50)
    owner_name = models.CharField(null=True,blank=True,max_length=150)
    date_of_registration = models.DateField(null=True,blank=True)
    registration_valid_till = models.DateField(null=True,blank=True)
    engine_number = models.CharField(null=True,blank=True,max_length=100)
    chasis_number = models.CharField(null=True,blank=True,max_length=100)
    running_kilometer = models.DecimalField(null=True,blank=True, decimal_places=2, max_digits=10)
    service_frequency = models.DecimalField(null=True,blank=True, decimal_places=2, max_digits=10)
    service_frequency_unit = models.IntegerField(null=True,blank=True, default=0)
    fuel_capacity = models.DecimalField(null=True,blank=True, decimal_places=2, max_digits=10)
    average_mileage = models.DecimalField(null=True,blank=True, decimal_places=2, max_digits=10) 
    purchase_amount = models.DecimalField(null=True,blank=True, decimal_places=2, max_digits=10)
    paid_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    insurance = models.BooleanField(default=False)
    company_name = models.CharField(null=True,blank=True,max_length=100)
    insurance_no = models.CharField(null=True,blank=True,max_length=100)
    insurance_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    insurance_start_date = models.DateField(null=True,blank=True)
    insurance_end_date = models.DateField(null=True,blank=True)
    insurance_renewal_date = models.DateField(null=True,blank=True)
    description = models.TextField(null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='myVehicle_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    identify = models.IntegerField(null=True, blank=True,default=2)
    available_quans = models.CharField(max_length=150, null=True,blank=True)
    translate_json = models.JSONField(null=True, blank=True)

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)
    
    # def __str__(self):
    #     return self.inventory_items.name

class MyVehicleDocuments(models.Model):
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True)
    document = models.FileField(upload_to='myVehicle_documents/', null=True, blank=True)
    vehicle = models.ForeignKey(MyVehicle, on_delete=models.CASCADE, null=True, blank=True)
    file_type = models.ForeignKey(DocumentCategory , on_delete=models.CASCADE , null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='myvehicle_document_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return self.document.name


class MyMachinery(models.Model):
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True)
    date_of_consumption = models.DateField(null=True,blank=True)
    vendor = models.ForeignKey(MyVendor, on_delete=models.CASCADE, null=True, blank=True)
    inventory_type = models.ForeignKey(InventoryType, on_delete=models.CASCADE, null=True, blank=True)
    inventory_category = models.ForeignKey(InventoryCategory, on_delete=models.CASCADE, null=True, blank=True)
    inventory_items = models.ForeignKey(InventoryItems, on_delete=models.CASCADE, null=True, blank=True)
    machinery_type = models.IntegerField(null=True,blank=True)
    fuel_capacity = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    purchase_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    paid_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    warranty_start_date = models.DateField(null=True,blank=True)
    warranty_end_date = models.DateField(null=True,blank=True)
    description = models.TextField(null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='mymachinery_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    identify = models.IntegerField(null=True, blank=True,default=3)
    available_quans = models.CharField(max_length=150, null=True,blank=True)
    translate_json = models.JSONField(null=True, blank=True)

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

    # def __str__(self):
    #     return self.inventory_items.name

class MyMachineryDocuments(models.Model):
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True)
    document = models.FileField(upload_to='myMachinary_documents/', null=True, blank=True)
    machinary = models.ForeignKey(MyMachinery, on_delete=models.CASCADE, null=True, blank=True)
    file_type = models.ForeignKey(DocumentCategory , on_delete=models.CASCADE , null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='mymachinery_document_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return self.document.name


class MyTools(models.Model):
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True)
    date_of_consumption = models.DateField(null=True,blank=True)
    vendor = models.ForeignKey(MyVendor, on_delete=models.CASCADE, null=True, blank=True)
    inventory_type = models.ForeignKey(InventoryType, on_delete=models.CASCADE, null=True, blank=True)
    inventory_category = models.ForeignKey(InventoryCategory, on_delete=models.CASCADE, null=True, blank=True)
    inventory_items = models.ForeignKey(InventoryItems, on_delete=models.CASCADE, null=True, blank=True)
    quantity = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    purchase_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    paid_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    description = models.TextField(null=True, blank=True)
    reusable = models.BooleanField(null=True, blank=True, default=False)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='mytool_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    identify = models.IntegerField(null=True, blank=True,default=4)
    available_quans = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    translate_json = models.JSONField(null=True, blank=True)

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

    # def __str__(self):
    #     return self.inventory_items.name

class MyToolsDocuments(models.Model):
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True)
    document = models.FileField(upload_to='myTools_documents/', null=True, blank=True)
    tools = models.ForeignKey(MyTools, on_delete=models.CASCADE, null=True, blank=True)
    file_type = models.ForeignKey(DocumentCategory , on_delete=models.CASCADE , null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='mytools_document_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    
    def __str__(self):
        return self.document.name

# both pesticides & fertilizers are now stored in here.
class MyPesticides(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    date_of_consumption = models.DateField(null=True,blank=True)
    vendor = models.ForeignKey(MyVendor, on_delete=models.CASCADE, null=True, blank=True)
    inventory_type = models.ForeignKey(InventoryType, on_delete=models.CASCADE, null=True, blank=True)
    inventory_category = models.ForeignKey(InventoryCategory, on_delete=models.CASCADE, null=True, blank=True)
    inventory_items = models.ForeignKey(InventoryItems, on_delete=models.CASCADE, null=True, blank=True)
    quantity = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    quantity_unit = models.ForeignKey(AreaUnit, on_delete=models.CASCADE,null=True,blank=True)
    purchase_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    paid_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    description = models.TextField(null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='mypesticides_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    identify = models.IntegerField(null=True, blank=True,default=5)
    available_quans = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    translate_json = models.JSONField(null=True, blank=True)

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

    # def __str__(self):
    #     return self.inventory_items.name

class MyPesticidesDocuments(models.Model):
    farmer = models.ForeignKey(Farmer,   on_delete=models.CASCADE, null=True, blank=True)
    document = models.FileField(upload_to='mypesticides_documents/', null=True, blank=True)
    pest = models.ForeignKey(MyPesticides, on_delete=models.CASCADE, null=True, blank=True)
    file_type = models.ForeignKey(DocumentCategory , on_delete=models.CASCADE , null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='mypest_document_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return self.document.name

# old db curently not in use
class MyFertilizers(models.Model):
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True)
    date_of_consumption = models.DateField(null=True,blank=True)
    vendor = models.ForeignKey(MyVendor, on_delete=models.CASCADE, null=True, blank=True)
    inventory_type = models.ForeignKey(InventoryType, on_delete=models.CASCADE, null=True, blank=True)
    inventory_category = models.ForeignKey(InventoryCategory, on_delete=models.CASCADE, null=True, blank=True)
    inventory_items = models.ForeignKey(InventoryItems, on_delete=models.CASCADE, null=True, blank=True)
    quantity = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    quantity_unit = models.ForeignKey(AreaUnit, on_delete=models.CASCADE,null=True,blank=True)
    purchase_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    paid_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    description = models.TextField(null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='myfertilizers_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    identify = models.IntegerField(null=True, blank=True,default=6)
    available_quans = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    translate_json = models.JSONField(null=True, blank=True)

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

    # def __str__(self):
    #     return self.inventory_items.name

class MyFertilizersDocuments(models.Model):
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True)
    document = models.FileField(upload_to='myfertilizers_documents/', null=True, blank=True)
    fertilizers = models.ForeignKey(MyFertilizers, on_delete=models.CASCADE, null=True, blank=True)
    file_type = models.ForeignKey(DocumentCategory , on_delete=models.CASCADE , null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='myfertilizers_document_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return self.document.name


class MySeeds(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    date_of_consumption = models.DateField(null=True,blank=True)
    vendor = models.ForeignKey(MyVendor, on_delete=models.CASCADE, null=True, blank=True)
    inventory_type = models.ForeignKey(InventoryType, on_delete=models.CASCADE, null=True, blank=True)
    inventory_category = models.ForeignKey(InventoryCategory, on_delete=models.CASCADE, null=True, blank=True)
    inventory_items = models.ForeignKey(InventoryItems, on_delete=models.CASCADE, null=True, blank=True)
    quantity = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    quantity_unit = models.ForeignKey(AreaUnit, on_delete=models.CASCADE,null=True,blank=True)
    purchase_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    paid_amount = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    description = models.TextField(null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='myseeds_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    identify = models.IntegerField(null=True, blank=True,default=7)
    available_quans = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    translate_json = models.JSONField(null=True, blank=True)

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

    # def __str__(self):
    #     return self.inventory_items.name

class MyseedsDocuments(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    document = models.FileField(upload_to='myseeds_documents/', null=True, blank=True)
    seeds = models.ForeignKey(MySeeds, on_delete=models.CASCADE, null=True, blank=True)
    file_type = models.ForeignKey(DocumentCategory , on_delete=models.CASCADE , null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='myseeds_document_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return self.document.name

# --------------------------- My Inventory -------------------------------

class MyInventory(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    date_of_consumption = models.DateField(null=True,blank=True)
    crop = models.ForeignKey(MyCrop,on_delete=models.CASCADE, null=True, blank=True)
    inventory_type = models.ForeignKey(InventoryType, on_delete=models.CASCADE, null=True, blank=True)
    inventory_category = models.ForeignKey(InventoryCategory, on_delete=models.CASCADE, null=True, blank=True)
    inventory_items = models.ForeignKey(InventoryItems, on_delete=models.CASCADE, null=True, blank=True)
    available_quans = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    quantity_utilized = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    quantity_unit = models.ForeignKey(AreaUnit, on_delete=models.CASCADE,null=True,blank=True)
    description = models.TextField(null=True, blank=True)
    start_kilometer = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    end_kilometer = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    usage_hours = models.DecimalField(null=True, blank=True, decimal_places=2, max_digits=10)
    tool_items = models.CharField(max_length=150, null=True, blank=True)

    rental = models.IntegerField(null=True,blank=True, default=1)
    vehicle_purchase = models.ForeignKey(MyVehicle, on_delete=models.CASCADE, null=True, blank=True)
    machinery_purchase = models.ForeignKey(MyMachinery, on_delete=models.CASCADE, null=True, blank=True)
    tool_purchase = models.ForeignKey(MyTools, on_delete=models.CASCADE, null=True, blank=True)
    fuel_purchase = models.ForeignKey(MyFuel, on_delete=models.CASCADE, null=True, blank=True)
    fertilizer_purchase = models.ForeignKey(MyFertilizers, on_delete=models.CASCADE, null=True, blank=True)
    pesticide_purchase = models.ForeignKey(MyPesticides, on_delete=models.CASCADE, null=True, blank=True)
    seeds_purchase = models.ForeignKey(MySeeds, on_delete=models.CASCADE, null=True, blank=True)

    # document = models.FileField(upload_to='myinventory_documents/', null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='myinventory_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    translate_json = models.JSONField(null=True, blank=True)

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

    # def __str__(self):
    #     return self.crop.crop.name + ' ' + self.inventory_items.name 

class MyInventoryDocuments(models.Model):
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True)
    file_type = models.ForeignKey(DocumentCategory , on_delete=models.CASCADE , null=True, blank=True)
    document = models.FileField(upload_to='myinventory_documents/', null=True, blank=True)
    my_inventory = models.ForeignKey(MyInventory, on_delete=models.CASCADE, null=True, blank=True)
    status = models.IntegerField(null=True,blank=True, default=0)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='myinventory_document_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return self.document.name

# ------------------------------ Attendance & Payouts ------------------

class Employee(models.Model):
    name = models.CharField(max_length=50)
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    manager = models.ForeignKey('ManagerUser', on_delete=models.CASCADE, null=True, blank=True)
    mobile_no = models.BigIntegerField(null=True, blank=True)
    employee_type = models.ForeignKey(EmployeeType, on_delete=models.CASCADE, null=True, blank=True)
    work_type = models.ForeignKey(WorkersType, on_delete=models.CASCADE, null=True, blank=True)
    salary = models.DecimalField(max_digits=15, decimal_places=2, default=0, null=True, blank=True)
    advance =  models.DecimalField(max_digits=15, decimal_places=2, default=0)
    topay = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    locations = models.CharField(max_length=200, null=True, blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    country = models.ForeignKey(Country, on_delete=models.CASCADE, null=True, blank=True)
    state = models.ForeignKey(State, on_delete=models.CASCADE, null=True, blank=True)
    city = models.ForeignKey(City, on_delete=models.CASCADE, null=True, blank=True)
    taluk = models.ForeignKey(Taluk, on_delete=models.CASCADE, null=True, blank=True)
    village = models.ForeignKey(Village, on_delete=models.CASCADE, null=True, blank=True)
    image = models.ImageField(upload_to='employee_images/', null=True, blank=True)
    door_no = models.CharField(max_length=200, null=True, blank=True)
    pincode = models.IntegerField(null=True,blank=True)
    description =  models.TextField(null=True,blank=True)
    authority_users = models.BooleanField(default=False, null=True, blank=True)
    my_farms = models.BooleanField(default=False, null=True, blank=True)
    my_sales = models.BooleanField(default=False, null=True, blank=True)
    my_expense = models.BooleanField(default=False, null=True, blank=True)
    my_inventory = models.BooleanField(default=False, null=True, blank=True)
    attendance_payouts = models.BooleanField(default=False, null=True, blank=True)
    username = models.CharField(max_length=150, null=True, blank=True)
    password = models.CharField(max_length=150, null=True, blank=True)
    employee_user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='employee_profile', null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='employee_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class EmployeeDocument(models.Model): 
    employee = models.ForeignKey(Employee,null=True,blank=True,on_delete=models.CASCADE , related_name='documents') #Connectiom 
    upload_document = models.FileField(upload_to='media/employee/', null=True, blank=True) #both
    status = models.IntegerField(default=0,null=True,blank=True)  # default
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  # default
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='employee_documents_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)   # default
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='employee_documents_updated_by')


class Attendance(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, null=True, blank=True)
    present = models.BooleanField(null=True, blank=True, default=False)
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)  
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='attendance_created_by')
    updated_at = models.DateTimeField(null=True,blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True) 

    def __str__(self):
        return self.employee.name
    
class AttendanceReport(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, null=True, blank=True)
    present = models.BooleanField(null=True, blank=True, default=False)
    created_at = models.DateTimeField(null=True, blank=True)
    created_day = models.DateField( null=True, blank=True)
    general_work = models.DecimalField(max_digits=10, decimal_places=2, default=0, null=True, blank=True)
    salary = models.DecimalField(max_digits=15, decimal_places=2, default=0, null=True, blank=True)
    total_hour = models.DecimalField(max_digits=15, decimal_places=2, default=0, null=True, blank=True)
    salary_status = models.BooleanField(null=True, blank=True, default=False)
    login_time = models.TimeField(null=True, blank=True)
    logout_time = models.TimeField(null=True, blank=True)

    def __str__(self):
        return self.employee.name

class CropReport(models.Model):
    crop = models.ForeignKey(MyCrop, on_delete=models.CASCADE, null=True, blank=True)
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, null=True, blank=True)
    attendance_report = models.ForeignKey(AttendanceReport, on_delete=models.CASCADE, null=True, blank=True)
    work_hour = models.DecimalField(max_digits=10, decimal_places=2, default=0, null=True, blank=True)
    created_at = models.DateTimeField(null=True, blank=True)
    created_day = models.DateField( null=True, blank=True)

    def __str__(self):
        return self.employee.name

class EmployeeAdvance(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, null=True, blank=True)
    employee_type = models.ForeignKey(EmployeeType, on_delete=models.CASCADE, null=True, blank=True) 
    advance_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    previous_advance_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    description = models.TextField(null=True, blank=True)
    created_day = models.DateField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='advance_created_by')
    updated_at = models.DateTimeField(null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.employee.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class EmployeePayouts(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, null=True, blank=True)
    paid_salary = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    unpaid_salary = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    advance_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    deduction_advance = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    balance_advance = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    payout_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    topay = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    description = models.TextField(null=True, blank=True)
    created_day = models.DateField(null=True,blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='payouts_created_by')
    updated_at = models.DateTimeField(null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.employee.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

# =-=-------------------------- Widget-----------------------
class WidgetConfig(models.Model):
    farmer = models.ForeignKey(Farmer,  on_delete=models.CASCADE, null=True, blank=True)
    # --------------------mobile----------------
    weather_date = models.BooleanField(default=True)
    receivables_payables = models.BooleanField(default=True)
    expenses_sales = models.BooleanField(default=True)
    near_by_market_price = models.BooleanField(default=True)
    schedulr_task = models.BooleanField(default=True)
    guideliness = models.BooleanField(default=True)
    vendor = models.BooleanField(default=True)
    # ------------------ Web ---------------------
    total_land = models.BooleanField(default=True)
    total_crops = models.BooleanField(default=True)
    total_schedule = models.BooleanField(default=True)
    total_customer = models.BooleanField(default=True)
    near_me_datas = models.BooleanField(default=True)
    guidelines = models.BooleanField(default=True)
    expenses = models.BooleanField(default=True)
    sales = models.BooleanField(default=True)
    employee_advanvce = models.BooleanField(default=True)
    regular_payouts = models.BooleanField(default=True)
    min_max_stock = models.BooleanField(default=True)
    monthly_expense_sales = models.BooleanField(default=True)
    monthly_advance_payouts = models.BooleanField(default=True)
    total_product_purchase = models.BooleanField(default=True)
    expense_sale_product_purchase_graph = models.BooleanField(default=True)
    weekly_employee_advance_payouts_graph = models.BooleanField(default=True)
    monthly_based_expense_sales = models.BooleanField(default=True)
    my_schedule = models.BooleanField(default=True)
    status = models.IntegerField(default=0, null=True, blank=True)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='widget')
    updated_at = models.DateTimeField(null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return self.farmer.name

# ------------------------------------- Mobile ----------------------------

class Purchase(models.Model):
    farmer = models.ForeignKey(Farmer,   on_delete=models.CASCADE, null=True, blank=True)
    fuel = models.ForeignKey('MyFuel', on_delete=models.CASCADE, null=True, blank=True, related_name='purchases_fuel')
    tools = models.ForeignKey('MyTools', on_delete=models.CASCADE, null=True, blank=True, related_name='purchases_tools')
    vehicle = models.ForeignKey('MyVehicle', on_delete=models.CASCADE, null=True, blank=True, related_name='purchases_vehicle')
    pesticides = models.ForeignKey('MyPesticides', on_delete=models.CASCADE, null=True, blank=True, related_name='purchases_pesticides')
    fertilizers = models.ForeignKey('MyFertilizers', on_delete=models.CASCADE, null=True, blank=True, related_name='purchases_fertilizers')
    seeds = models.ForeignKey('MySeeds', on_delete=models.CASCADE, null=True, blank=True, related_name='purchases_seeds')
    machinery = models.ForeignKey('MyMachinery', on_delete=models.CASCADE, null=True, blank=True, related_name='purchases_machinery')
    status = models.IntegerField(default=0, null=True, blank=True)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='purchase_created_by')
    updated_at = models.DateTimeField(null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    
    def __str__(self):
        return f"Purchase: {self.id}"

class HelpDesk(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    name = models.CharField(max_length=100, null=True, blank=True)
    number = models.CharField(max_length=100, null=True,blank=True)
    status = models.IntegerField(default=0, null=True, blank=True)
    created_at = models.DateTimeField(null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True , related_name='help_desk')
    updated_at = models.DateTimeField(null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name

    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class SoilTest(models.Model): 
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    my_land = models.ForeignKey(MyLand, related_name='my_ld_details', on_delete=models.CASCADE, null=True, blank=True)
    my_crop = models.ForeignKey(MyCrop, related_name='my_crp_details', on_delete=models.CASCADE, null=True, blank=True)  
    file_type = models.ForeignKey(DocumentCategory , on_delete=models.CASCADE , null=True, blank=True)
    file = models.FileField(upload_to='soil_test_files/', null=True, blank=True)   
    uploaded_at = models.DateTimeField(auto_now_add=True)  
    status= models.IntegerField(default=0, null=True, blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_soil_test_created_at')
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='my_soil_test_updated_by')

class SmsTemplateModel(models.Model): 
    template_name = models.CharField(max_length=255)
    authkey = models.CharField(max_length=255)
    sender_id = models.CharField(max_length=255)
    template_id = models.CharField(max_length=255)
    country_code = models.CharField(max_length=10)
    sms_template_messagecontent = models.TextField()
    status = models.IntegerField(default=0)   

    def __str__(self):
        return self.template_name
    
class Test(models.Model): 
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    my_land = models.ForeignKey(MyLand, on_delete=models.CASCADE, null=True, blank=True)
    my_crop = models.ForeignKey(MyCrop, on_delete=models.CASCADE, null=True, blank=True)  
    file_type = models.ForeignKey(DocumentCategory , on_delete=models.CASCADE , null=True, blank=True)
    file = models.FileField(upload_to='test_files/', null=True, blank=True)   
    uploaded_at = models.DateTimeField(auto_now_add=True)  
    status= models.IntegerField(default=0, null=True, blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='test_created_at')
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)  
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='test_updated_by')

    class Meta:
        db_table = 'dashboards_test'

class Soil_Test(models.Model): 
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    my_land = models.ForeignKey(MyLand, on_delete=models.CASCADE, null=True, blank=True)
    my_crop = models.ForeignKey(MyCrop, on_delete=models.CASCADE, null=True, blank=True)  
    file_type = models.ForeignKey(DocumentCategory , on_delete=models.CASCADE , null=True, blank=True)
    file = models.FileField(upload_to='upload_report/', null=True, blank=True)   
    uploaded_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)  
    status= models.IntegerField(default=0, null=True, blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True) 

# -------------------------------------------------------------- Outstanding -------------------------------------------

class Outstanding(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    customer = models.ForeignKey(MyCustomer, on_delete=models.CASCADE, null=True, blank=True)
    sale = models.ForeignKey(MySales, on_delete=models.CASCADE, null=True, blank=True)
    vendor = models.ForeignKey(MyVendor, on_delete=models.CASCADE, null=True, blank=True)
    expense = models.ForeignKey(MyExpense, on_delete=models.CASCADE, null=True, blank=True)
    vehicle_purchase = models.ForeignKey(MyVehicle, on_delete=models.CASCADE, null=True, blank=True)
    machinery_purchase = models.ForeignKey(MyMachinery, on_delete=models.CASCADE, null=True, blank=True)
    tool_purchase = models.ForeignKey(MyTools, on_delete=models.CASCADE, null=True, blank=True)
    fuel_purchase = models.ForeignKey(MyFuel, on_delete=models.CASCADE, null=True, blank=True)
    fertilizer_purchase = models.ForeignKey(MyFertilizers, on_delete=models.CASCADE, null=True, blank=True)
    pesticide_purchase = models.ForeignKey(MyPesticides, on_delete=models.CASCADE, null=True, blank=True)
    seeds_purchase = models.ForeignKey(MySeeds, on_delete=models.CASCADE, null=True, blank=True)
    balance = models.DecimalField(max_digits=15, decimal_places=2, default=0) # both
    paid = models.DecimalField(max_digits=15, decimal_places=2, default=0) # payables
    to_pay = models.DecimalField(max_digits=15, decimal_places=2, default=0) # payables
    paid_date = models.DateTimeField(null=True, blank=True) # payables
    total_paid = models.DecimalField(max_digits=15, decimal_places=2, default=0) # payables
    received = models.DecimalField(max_digits=15, decimal_places=2, default=0) # receivables
    to_receive = models.DecimalField(max_digits=15, decimal_places=2, default=0) # receivables
    received_date = models.DateTimeField(null=True, blank=True) # receivables
    total_received = models.DecimalField(max_digits=15, decimal_places=2, default=0) # receivables
    payment_amount = models.DecimalField(max_digits=15, decimal_places=2, default=0) # payment amount
    description = models.TextField(null=True, blank=True)
    status = models.IntegerField(default=0, null=True,blank=True)
    identify = models.IntegerField(default=0, null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='outstanding_created_by')
    updated_at = models.DateTimeField(null=True, blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    created_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return self.farmer.name

class OutstandingDocuments(models.Model): 
    outstanding = models.ForeignKey(Outstanding, on_delete=models.CASCADE, null=True, blank=True, related_name='documents_outstanding')
    document_type = models.ForeignKey(DocumentCategory, on_delete=models.CASCADE, null=True, blank=True)
    document = models.FileField(upload_to='outstanding_documents/', null=True, blank=True)
    uploaded_at = models.DateTimeField(null=True, blank=True)
    status = models.IntegerField(default=0, null=True, blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='document_created_by')
    updated_at = models.DateTimeField(null=True, blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    created_at = models.DateTimeField(null=True, blank=True)

# --------------------------------------------------------------------- Manager User --------------------------------------------

class ManagerUser(models.Model):
    name = models.CharField(max_length=100)
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    mobile_no = models.BigIntegerField(null=True, blank=True)
    alter_no = models.BigIntegerField(null=True, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.ForeignKey(Gender, on_delete=models.CASCADE, null=True, blank=True)
    email = models.EmailField(null=True, blank=True)
    date_of_join = models.DateField(null=True, blank=True)
    employee_type = models.ForeignKey(EmployeeType, on_delete=models.CASCADE, null=True, blank=True)
    image = models.ImageField(upload_to='manager_images/', null=True, blank=True)
    address = models.CharField(max_length=200, null=True, blank=True)
    pincode = models.IntegerField(null=True,blank=True)
    locations = models.CharField(max_length=200, null=True, blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    role = models.ForeignKey('ManagerUserRole', on_delete=models.CASCADE, null=True, blank=True)
    description =  models.TextField(null=True,blank=True)
    username = models.CharField(max_length=150, null=True, blank=True)
    password = models.CharField(max_length=150, null=True, blank=True)
    manager_user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='manager_profile', null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True) # 0 - active, 1 - inactive, 2 - delete, 3 - terminated, 4 - releaved
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='manager_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    translate_json = models.JSONField(null=True, blank=True)
    permissions = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
    def get_translated_value(self, field_name, language_code):
        if self.translate_json and field_name in self.translate_json:
            return self.translate_json[field_name].get(language_code, getattr(self, field_name))
        return getattr(self, field_name)

class ManagerUserRole(models.Model):
    name = models.CharField(max_length=100)
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null=True, blank=True)
    map_role = models.ForeignKey(Role, on_delete=models.CASCADE, null=True, blank=True)
    limitation_sorting = models.IntegerField(default=0, null=True, blank=True)
    employee_count_from = models.IntegerField(default=0, null=True, blank=True)
    employee_count_to = models.IntegerField(default=0, null=True, blank=True)
    land_count_from = models.IntegerField(default=0, null=True, blank=True)
    land_count_to = models.IntegerField(default=0, null=True, blank=True)
    status = models.IntegerField(default=0,null=True,blank=True)
    created_at = models.DateTimeField(auto_now_add=True,null=True,blank=True)
    created_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True, related_name='manager_role_created_by')
    updated_at = models.DateTimeField(auto_now=True,null=True,blank=True)
    updated_by = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)
    translate_json = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.name
    
