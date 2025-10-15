from django.urls import path
from django.conf import settings
from ai.views import SuperAdminDashboardsView
from.views import *
from . import views
from django.conf.urls.static import static

# app_name = 'dashboards'

urlpatterns = [
    # Super Admin Menu's Start        
         
    path('SA-Dashboards', SuperAdminDashboardsView.as_view(template_name = 'pages/super_admin/dashboards/dashboards.html'), name='sa_dashboards'),

### ----------------------------------------- Farmer Management ----------------------------------------------- ###
    
    path('SA-FarmerManagement', FarmerManagementView.as_view(), name='sa_farmer_management'),
    path('SA-FarmerManagementView/<int:farmer_id>/', FarmerManagementDetailsView.as_view(), name='sa_farmer_management_view'), 
    path('SA-FarmerManagementUsageView/<int:farmer_id>/', FarmerManagementUsageDetails.as_view(), name='sa_farmer_management_usage_view'), 
    path('create_farmer/', FarmerManagementView.as_view(), name='create_farmer'),
    path('api/farmers/registration-data/', views.get_farmers_data, name='farmers_registration_data'),
    path('api/graph/', views.get_data_for_graph, name='get_data_for_graph'),
    path('export-farmer/', views.export_farmer, name='export_farmer'),
    path('api/farmer_details/<int:farmer_id>/', farmer_details, name='farmer_details'),
    path('api/fetch_subscriptions/<int:farmer_id>/', fetch_subscriptions, name='fetch_subscriptions'),
    path('api/land_details/<int:farmer_id>/', views.get_land_details, name='get_land_details'),

# ---------------------------------------------------- Setting ---------------------------------------------------

    path('api/countries/', views.get_countries, name='country'), 
    path('api/states/', views.get_states, name='state'),
    path('api/cities/', views.get_cities, name='city'),
    path('api/taluks/', views.get_taluks, name='taluk'), 
    path('api/villages/', views.get_villages, name='village'),  
    path('check-taluk-exists/', CheckTalukView.as_view(), name='check_taluk_exists'),
    path('SA-Country', CountryView.as_view(), name='sa_country'),
    path('SA-State', StateView.as_view(), name='sa_state'),
    path('SA-City', CityView.as_view(), name='sa_city'),
    path('SA-Taluk', TalukView.as_view(), name='sa_taluk'),
    path('SA-Village', VillageView.as_view(), name='sa_village'),
    path('SA-GeneralSettings', GeneralSettingsView.as_view(), name='sa_general_setting'),
    path('SA-EmailTemplate', EmailTemplateView.as_view(),name='sa_email_config'),
    path('update-email-template/', update_email_template, name='update_email_template'),
    path('get-email-template/<int:template_id>/', views.get_email_template, name='get_email_template'),
    path('SA-EmailConfigUpdate/<int:user_id>', EmailTemplateUpdate.as_view(),name='sa_email_config_update'),
    path('SA-SMSConfig', SMSConfigView.as_view(),name='sa_sms_config'),
    path('SA-Language', LanguageView.as_view(), name='sa_language'),


    path('SA-ManageVehicleCategory',VehicleCategoryView.as_view(),name='sa_manage_vehicle_category'),
    path('SA-ManageVehicle', VehicleManagementView.as_view(), name='sa_manage_vehicle'),
    path('SA-ManageMachineryCategory',MachineryCategoryView.as_view(),name='sa_manage_machinery_category'),
    path('SA-ManageMachinery', MachineryView.as_view(), name='sa_manage_machinery'),
    path('SA-ManageToolsCategory', ToolCategoryView.as_view(), name='sa_manage_tools_category'),
    path('SA-ManageTools',ToolView.as_view(),name='sa_manage_tools'),
    
    path('SA-CropSetType/', CropTypeView.as_view(), name='sa_crop_type'),
    path('SA-Crop/', CropView.as_view(), name='sa_crop'),
    path('SA-SoilType/', SoilTypeView.as_view(), name='sa_soil_type'),
    path('SA-HarvestingType/', HarvestingTypeView.as_view(), name='sa_harvesting_type'),
    path('SA-Unit/', UnitView.as_view(), name='sa_unit'), 
    path('SA-Quality', QualityView.as_view(), name='sa_quality'),
    path('SA-LandUnit', LandUnitView.as_view(), name='sa_land_unit'),
    path('SA-ExpenseCategory', ExpensesCategoryView.as_view(), name='sa_expenses_category'),
    path('SA-TypeofExpense', ExpensesView.as_view(), name='sa_expenses'),
    path('SA-Deduction', DetectionView.as_view(), name='sa_deduction'),
    path('SA-ProductUnit',AreaUnitView.as_view(),name='sa_areaunit'),
    path('SA-DocumentCategory',DocumentCategoryView.as_view(),name='sa_document_category'),

    
    path('check_areaunit_name_exists/', views.check_areaunit_name_exists, name='check_areaunit_name_exists'),
    path('SA-ProductType', ProductTypeView.as_view(),name='sa_product_type'),
    path('SA-ActivityType/', ScheduleActivityTypeView.as_view(), name='sa_schedule_activity_type'),
    path('SA-Schedule/', ScheduleView.as_view(), name='sa_schedule'),
    path('SA-ScheduleView/<int:crop_id>/', ScheduleViewDetails.as_view(), name='sa_schedule_view'),

    path('SA-InventoryCategory', InventoryCategoryView.as_view(), name='sa_inventory_category'),
    path('SA-InventoryItems', InventoryItemsView.as_view(), name='sa_inventory_items'),
    # path('get_inventory_categories/', views.get_inventory_categories, name='get_inventory_categories'),
    path('filter_categories/<int:inventory_type_id>/', views.filter_categories, name='filter_categories'),
    path('import_schedule/', import_schedule, name='import_schedule'),

    # ---------------------------------------------- Edit Translated Fetch ------------------------------------
    path('api/soil-type/translation/<int:pk>/', views.get_soil_type_translation, name='soil_type_translation'),
    path('api/land_unit/translation/<int:pk>/', views.get_land_unit_translation, name='land_unit_translation'),
    path('api/area_unit/translation/<int:pk>/', views.get_product_unit_translation, name='product_unit_translation'),
    path('api/crop_type/translation/<int:pk>/', views.get_crop_type_translation, name='crop_type_translation'),
    path('api/crop/translation/<int:pk>/', views.get_crop_translation, name='crop_translation'),
    path('api/product_type/translation/<int:pk>/', views.get_product_type_translation, name='product_type_translation'),
    path('api/inv_category/translation/<int:pk>/', views.get_inv_catego_translation, name='inv_category_translation'),
    path('api/inv_items/translation/<int:pk>/', views.get_inv_item_translation, name='inv_item_translation'),
    path('api/exp_catego/translation/<int:pk>/', views.get_exp_catego_translation, name='exp_catego_translation'),
    path('api/exp_typ/translation/<int:pk>/', views.get_exp_typ_translation, name='exp_typ_translation'),
    path('api/harvest_typ/translation/<int:pk>/', views.get_harvesting_frequency_translation, name='harv_freq_translation'),
    path('api/reasons/translation/<int:pk>/', views.get_reasons_translation, name='reasons_translation'),
    path('api/scheduletype/translation/<int:pk>/', views.get_schedule_type_translation, name='sch_typ_translation'),
    path('api/location_catego/translation/<int:pk>/', views.get_location_category_translation, name='location_catego_translation'),
    path('api/wrk_type/translation/<int:pk>/', views.get_work_typ_translation, name='wrk_typ_translation'),
    path('api/guideline_category/translation/<int:pk>/', views.get_guideline_category_translation, name='guideline_category_translation'),
    path('api/doc_catego/translation/<int:pk>/', views.get_document_category_translation, name='doc_category_translation'),

    path('api/country/translation/<int:pk>/', views.get_country_translation, name='country_translation'),
    path('api/state/translation/<int:pk>/', views.get_state_translation, name='state_translation'),
    path('api/city/translation/<int:pk>/', views.get_city_translation, name='city_translation'),
    path('api/taluk/translation/<int:pk>/', views.get_taluk_translation, name='taluk_translation'),
    path('api/village/translation/<int:pk>/', views.get_village_translation, name='village_translation'),

    # ------------------------------------------------------- Package Management ---------------------------------------

    path('SA-PackageManagement', ManagePackageView.as_view(), name='sa_manage_package'),
    path('SA-PackageManagementCreate', ManagePackageCreateView.as_view(), name='sa_create_package'),
    path('SA-PackageManagementUpdate/<int:pk>/', ManagePackageUpdateView.as_view(), name='sa_update_package'),
    path('api/package-details/<int:package_id>/', get_package_details, name='get_package_details'),
    path('api/farmers_info/<int:package_id>/', get_farmer_from_package, name='farmer-info'),
 
    # ------------------------------------------------------ Subscription Management -----------------------------------------------

    path('api/subscriptions-data/', views.get_subscriptions_data, name='subscriptions_data'),
    path('api/subscription/<int:subscription_id>/', SubscriptionManagementView.as_view(), name='subscription_detail'),
    path('subscribe/details/<int:subscription_id>/', SubscriptionManagementView.as_view(), name='subscription_details'),
    path('SA-SubscriptionManagement', SubscriptionManagementView.as_view(), name='sa_subscription_management'),
    path('api/subscription/<int:subscription_id>/', SubscriptionManagementView.as_view(), name='sa_subscription_management'),
    path('api/subscriptiondetails/<int:subscription_id>/', subscription_details, name='subscription_details'),
    path('export-subscription/', views.export_subscription, name='export_subscription'),
    path('import_schedule/', import_schedule, name='import_schedule'),
    ### ---------------------------------------------------- Market Price Chart Views ---------------------------------------------

    path('SA-ProductVsPrice', ProductVsPriceView.as_view(), name='sa_product_vs_price'),
    path('SA-ProductVsPriceUpdate/<int:market_id>/', ProductVsPriceUpdatePriceView.as_view(), name='sa_product_vs_price_update'),
    path('SA-ProductBased', ProductBasedView.as_view(), name='sa_product_based'),
    path('SA-MarketBased', MarketBasedView.as_view(), name='sa_market_based'),
    path('SA-MarketBasedUpdate/<int:market_id>/', MarketBasedUpdateView.as_view(), name='sa_market_based_update'),
    path('SA-ProductBasedUpdate/<int:product_id>/', ProductBasedUpdateView.as_view(), name='sa_product_based_update'),
    path('api/product-price-data/<int:product_id>/', product_price_data, name='product_price_data'),
    path('export-market/', export_market, name='export_market'),
    path('export-staffs/', export_staff, name='export_staffs'),
    path('api/market-price-data/<int:product_id>/<int:market_id>/', market_product_price_data, name='market_price_data'),


    # ------------------------------------------------------- Market Management --------------------------------------------------    
        
    # path('SA-ManageMarket', ManageMarketView.as_view(), name='sa_manage_market'),
    # path('SA-ManageAllocatedMarket', AllocateMarketView.as_view(), name='sa_manage_allocated_market'), 

    path('SA-ManageMarket', ManageMarketView.as_view(), name='sa_manage_market'),
    path('SA-ManageAllocatedMarket', AllocateMarketView.as_view(), name='sa_manage_allocated_market'), 
    path("get-allocated-markets/", get_allocated_markets, name="get_allocated_markets"),

    # ------------------------------------------------------- Worker Management --------------------------------------------------    

    path('SA-ManPowerWorkType', ManPowerWorkTypeView.as_view(), name='sa_man_power_work_type'),
    path('SA-ManageWorkers', ManageWorkersView.as_view(), name='sa_manage_workers'),
    path('SA-ManageWorkersCreate', ManageWorkersCreateView.as_view(), name='sa_manage_workers_create'),
    path('get-worker-details/<int:worker_id>/', get_worker_details, name='get_worker_details'),
    path('worker-details/<int:worker_id>/', get_workers_details, name='worker_details'),
    path('worker_edit_details/<int:worker_id>/', get_workers_edit_details, name='worker_edit_details'),
    path('SA-ManageWorkersUpdate/<int:worker_id>/', ManageWorkerUpdateView.as_view(), name='sa_manage_workers_update'),
    path('export-manage-workers/', export_manage_workers, name='export_manage_workers'),
    # ------------------------------------------------------------ Reports -----------------------------------------------------------
        
    path('SA-FarmersRegistrationReport', FarmersRegistrationReportView.as_view(), name='sa_farmers_registration_report'),
    path('farmer_report_details/<int:farmer_id>/', views.farmer_report_details, name='farmer_details'),
    path('SA-PackageRevenueReport', PackageRevenueReportView.as_view(), name='sa_package_revenue_report'),
    path('SA-PackageRevenueReportView/<int:package_id>', PackageRevenueView.as_view(), name='sa_package_revenue_report_view'),
    path('reports/subscription-report/data/<int:year>/', subscription_report_data, name='subscription_report_data'), 
    path('export_farmer_report/', views.export_farmer_report, name='export_farmer_report'),

    # --------------------------------------------------------- User Management ---------------------------------------------------

    path('SA-ManageUsers/', ManageUserView.as_view(), name='sa_manage_users'),
    path('export-userData/', export_userData, name='export_data'),
    path('export_filtered_data/', views.export_filtered_data, name='export_filtered_data'),
    path('SA-ManageUsersView/<int:user_id>', UserView.as_view(), name='sa_manage_users_view'),
    path('SA-ManageUsersUpdate/<int:user_id>', ManageUserUpdate.as_view(), name='sa_manage_users_update'),
    path('SA-ManageUsersCreate', ManageUsersCreate.as_view(), name='sa_manage_users_create'),
    path('get_role_permissions/', views.get_role_permissions, name='get_role_permissions'),

    path('SA-ManageUserRole', ManageUserRoleView.as_view(), name='sa_manage_role'),
    path('SA-ManageUserRoleView/<int:user_id>', UserRoleView.as_view(), name='sa_manage_role_view'),
    path('SA-ManageUserRoleUpdate/<int:user_id>', UserRoleUpdate.as_view(), name='sa_manage_role_update'),
    path('SA-ManageUserRoleCreate', UserRoleCreate.as_view(), name='sa_manage_role_create'),

    # --------------------------------------------------------- Guideline Management ---------------------------------------------------

    path('update_guideline',views.update_guideline,name="update_guideline"),
    path('SA-ManageGuidelines', ManageGuidelinesView.as_view(), name='sa_manage_guidelines'),
    path('get-guideline-data/', views.get_guideline_data, name='get_guideline_data'),
    path('get-guidelines-data/', views.get_guidelines_data, name='get_guidelines_data'),
    path('SA-GuidelinesCategory', GuidelinesCategoryView.as_view(), name='sa_guidelines_category'),
    # path('export_guidelines/', views.export_guidelines, name='export_guidelines'),

    # --------------------------------------------------------- Nearby Location Category ---------------------------------------------------

    path('SA-LocationCategory', NearByLocationCategoryView.as_view(), name='sa_manage_near_by_locations_category'),
    path('SA-ManageNearByLocations', NearByLocationView.as_view(), name='sa_manage_near_by_locations'),
    path('export_nearby_locations/', export_nearby_locations, name='export_nearby_locations'),
 

    path('user_not_allowed/',user_not_allowed,name="user_not_allowed"),

    # path('api/get_inventory_categories/', views.get_inventory_categories, name='get_inventory_categories'),

    #------------------------------------------------------------- Rental ----------------------------------------------------
    path('SA-RentalAvailability', RentalAvailabilityView.as_view(), name='sa_rental_availability'),
    path('api/get_inventory_items/', views.get_inventory_items, name='get_inventory_items'),

    # ------------------------------------------------- Ui Fields ------------------------------------------

    path('logout/', CustomLogoutView.as_view(), name='logout'), 
    path('mark-all-as-read/', mark_all_as_read, name='mark_all_as_read'),
    path('mark-notification-read/', views.mark_notification_as_read, name='mark_notification_as_read'),


    # path('test-404/', views.handler404, name='test_404'),
    path('test-404/', views.test_404_view, name='test_404'),

] 

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

 


