from django.contrib import admin
from .models import *

admin.site.register(Notification)
admin.site.register(EmployeeType)
admin.site.register(Gender) 
admin.site.register(UserLanguagePreference) 
admin.site.register(UserType)
# --> Setting 

@admin.register(Languages)
class LanguageAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'status','language_code')

@admin.register(Country)
class CountryAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'status',)
    search_fields = ('name',)

@admin.register(State)
class StateAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'country', 'status',)
    search_fields = ('name',)
    list_filter = ('country',)

@admin.register(City)
class CityAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'state', 'country', 'status',)
    search_fields = ('name',)
    list_filter = ('state', 'country')

@admin.register(Taluk)
class TalukAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'city', 'state', 'country', 'status',)
    search_fields = ('name',)
    list_filter = ('city', 'state', 'country')

@admin.register(Village)
class VillageAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'taluk', 'city', 'state', 'country', 'status',)
    search_fields = ('name',)
    list_filter = ('taluk', 'city', 'state', 'country')

admin.site.register(GeneralSetting)
admin.site.register(EmailConfig)
# admin.site.register(EmailTemplate)
admin.site.register(SMSConfig)

@admin.register(EmailTemplate)
class EmailTemplateAdmin(admin.ModelAdmin):
    list_display = ('email_template_name','code', 'email_subject','id')

# --> Data Management
  
@admin.register(CropType)
class CropTypeAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'status',)
    search_fields = ('name',)

@admin.register(Crop)
class CropAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'croptype', 'status',)
    search_fields = ('name',)
    list_filter = ('croptype',)

@admin.register(SoilType)
class SoilTypeAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'status',)
    search_fields = ('name',)

@admin.register(HarvestingType)
class HarvestingTypeAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'status',)
    search_fields = ('name',)

@admin.register(Unit)
class UnitAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'unitdef', 'status',)
    search_fields = ('name',)

@admin.register(AreaUnit)
class AreaUnitAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'areaunitdef', 'status',)
    search_fields = ('name',)

@admin.register(ProductType)
class ProductTypeAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'status',)
    search_fields = ('name',)

@admin.register(ScheduleActivityType)
class ScheduleActivityTypeAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'status',)
    search_fields = ('name',)

@admin.register(Schedule)
class ScheduleAdmin(admin.ModelAdmin):
    list_display = ('id','crop', 'activity_type', 'days', 'status',)
    search_fields = ('crop__name', 'activity_type__name')
    list_filter = ('crop', 'activity_type')


@admin.register(LandUnit)
class LandUnitTypeAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'status',)
    
admin.site.register(Quality)
admin.site.register(ExpensesCategory)
admin.site.register(Expenses)
admin.site.register(Detection)
# admin.site.register(UserSession)

@admin.register(UserSession)
class UserAdmin(admin.ModelAdmin):
    list_display =('id','user','login_time', 'logout_time')


# --> Farmer Management
 
 
@admin.register(Farmer)
class FarmerAdmin(admin.ModelAdmin):
    list_display =('id','name','created_at', 'updated_at','email',)

# --> Package Management

@admin.register(PackageManagement)
class PackageManagementAdmin(admin.ModelAdmin):
    list_display = ('id','name',)
 

# --> Subscription Management

@admin.register(AddSubcription)
class AddSubcriptionAdmin(admin.ModelAdmin):
    list_display = ('id','farmers','packages','remainingdays',)

# --> Market Price Chart

@admin.register(ManageProduct)
class ManageProductAdmin(admin.ModelAdmin):
    list_display = ('id','name',)
    search_fields = ('name',)

@admin.register(MarketProduct)
class MarketProductAdmin(admin.ModelAdmin):
    list_display = ('id', 'product', 'market', 'price', 'available',)

@admin.register(ProductMarketReport)
class ProductMarketReportAdmin(admin.ModelAdmin):
    list_display = ('id', 'product', 'market','available', 'price', 'created_day')


# ---> Market Management
  

@admin.register(ManageMarket)
class ManageMarketAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'markettype', 'openingtime', 'closingtime', 'status',)
    search_fields = ('name', 'description')
    list_filter = ('markettype', 'status') 

@admin.register(AllocateMarket)
class AllocateMarketAdmin(admin.ModelAdmin):
    list_display = ('id','staff','status',)
    search_fields = ('staff__name',)
    filter_horizontal = ('markets',)
# admin.site.register(MarketType) 

# --> Near By Location

@admin.register(NearByLocationCategory)
class NearByLocationCategoryAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'status',)
    search_fields = ('name',)

@admin.register(ManageNearByLocations)
class ManageNearByLocationsAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'category', 'contact',)
    search_fields = ('name', 'address')

# --> Vehicle Management

@admin.register(VehicleCategory)
class VehicleCategoryAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'status',)
    search_fields = ('name',)

@admin.register(VehicleManagement)
class VehicleManagementAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'category', 'status',)
    search_fields = ('name',)

# --> Machinery Management

@admin.register(MachineryCategory)
class MachineryCategoryAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'status',)
    search_fields = ('name',)

@admin.register(Machinery)
class MachineryAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'category', 'status',)
    search_fields = ('name',)

# --> Tool Management

@admin.register(ToolCategory)
class ToolCategoryAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'status',)
    search_fields = ('name',)

@admin.register(Tool)
class ToolAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'category', 'status',)
    search_fields = ('name',)

# --> Workers Availability

@admin.register(WorkersType)
class WorkersTypeAdmin(admin.ModelAdmin):
    list_display = ('name', 'status',)
    search_fields = ('name',)
    list_filter = ('status',)

# @admin.register(WorkStatus)
# class WorkStatusAdmin(admin.ModelAdmin):
#     list_display = ('name', 'code',)
#     search_fields = ('name',)

@admin.register(ManageWorkers)
class ManageWorkersAdmin(admin.ModelAdmin):
    list_display = ('id', 'worker',)  

@admin.register(WorkerWorkType)
class ManageWorkersAdmin(admin.ModelAdmin):
    list_display = ('id', 'worker', 'work_type', 'person_count',)  


# --> Guidelines Management

@admin.register(GuidelinesCategory)
class GuidelinesCategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'status',)
    search_fields = ('name',)

@admin.register(Guidelines)
class GuidelinesAdmin(admin.ModelAdmin):
    list_display = ('name', 'guidelinestype', 'guidelinescategory', 'status',)
    search_fields = ('name',)
    list_filter = ('guidelinestype', 'guidelinescategory', 'status')

admin.site.register(GuidelineFile)

# --> User Management 
@admin.register(ManageUser)
class ManageUserAdmin(admin.ModelAdmin):
    list_display = ('name', 'status',  'usertype', 'custom_user_id')

@admin.register(UserProfileStatus)
class UserProfileStatusAdmin(admin.ModelAdmin):
    list_display = ('name', 'terminate', 'releave','active',)

@admin.register(ManageUserRole)
class ManageUserRoleAdmin(admin.ModelAdmin):
    list_display = ('name', 'map_role','status',)


# --> Reports

@admin.register(FarmerReport)
class FarmerReportAdmin(admin.ModelAdmin):
    list_display = ('id','farmer')

@admin.register(SubscriptionReport)
class SubscriptionReportAdmin(admin.ModelAdmin):
    list_display = ('id','package')

@admin.register(InventoryType)
class InventoryTypeAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'code')

@admin.register(InventoryCategory)
class InventoryCategoryAdmin(admin.ModelAdmin):
    list_display = ('id','name')

@admin.register(InventoryItems)
class InventoryItemsAdmin(admin.ModelAdmin):
    list_display = ('id','name')

@admin.register(DocumentCategory)
class DocumentCategoryAdmin(admin.ModelAdmin):
    list_display = ('id','name')

admin.site.register(Days)
admin.site.register(Role)

admin.site.site_header = "AgrIOT"
admin.site.site_title = "AgrIOT  Management Admin Portal"
admin.site.index_title = "Welcome to AgrIOT Management"

