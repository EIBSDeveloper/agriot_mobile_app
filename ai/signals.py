from django.db.models.signals import post_save,pre_save
from .models import * 
from django.db.models import Q
from datetime import datetime
from django.utils import timezone
from django.contrib.auth.signals import user_logged_in
from django.dispatch import receiver
from django.contrib.auth.signals import user_logged_out
from dashboards.models import * 
from django.db.models.signals import post_migrate
from django.dispatch import receiver
from .models import PackageManagement, Duration
from datetime import timedelta
from deep_translator import GoogleTranslator
import threading

# target_language = ['ta', 'hi']
# languages = Languages.objects.filter(status=0).exclude(id=1)
# target_language = [lang.language_code for lang in languages]

# ------------------------------------- Package Manage & Subscription ------------------------------------
@receiver(post_migrate)
def create_default_package_management(sender, **kwargs):
    # Check if the default PackageManagement already exists
    if not PackageManagement.objects.filter(id=1).exists(): 
        duration_instance = Duration.objects.first()   
        
        PackageManagement.objects.create(
            id=1,  # Explicitly setting the id to 1
            name="Free Trail",
            code=101,
            package_validity=10,
            package_duration=duration_instance,
            amount=0,
            offer=True,
            percentage=0,
            sub_amount=0,
            status=0,
            myland_count=10,
            mycrops_count=10,
            myexpense_count=10,
            mysale_count=10,
            customer_count=10,
            is_myfuel=True,
            myfuel_count=10,
            is_myvechicle=True,
            myvechicle_count=10,
            is_mymachinery=True,
            mymachinery_count=10,
            is_mytools=True,
            mytools_count=10,
            is_mypesticides=True,
            mypesticides_count=10,
            is_myfertilizers=True,
            myfertilizers_count=10,
            is_myseeds=True,
            myseeds_count=10,
            is_myinventory=True,
            myinventory_products=10,
            myinventory_purchase=0,
            myinventory_vendors=10,
            is_attendance=True,
            employee_count=10,
            farmer_manager_count=3,
            is_payouts=True,
            is_widget=True,
            created_at=timezone.now(),
            updated_at=timezone.now(), 
        )
 
@receiver(post_save, sender=AddSubcription)
def update_farmer_subscription(sender, instance, created, **kwargs):
    " ""Update Farmer details when an AddSubscription is created or updated."" "
    if instance.farmers:  # Ensure there is a related farmer
        farmer = instance.farmers
        if farmer.status != 7:
            sub_details = AddSubcription.objects.filter(farmers=instance.farmers, status=0).first()
            if sub_details:
                farmer.subscription_package = sub_details.packages
                farmer.subscription_start_date = sub_details.startdate
                farmer.subscription_end_date = sub_details.enddate
                farmer.remaining_days = sub_details.remainingdays
                farmer.amounts = sub_details.packages.amount if sub_details.packages else None
                farmer.sub_amounts = sub_details.packages.sub_amount if sub_details.packages else None
                if sub_details.remainingdays != 0 and sub_details.status != 3 and sub_details.status != 2:
                    farmer.status = 0
                else:
                    farmer.status = 1
                farmer.save()
            else:
                sub_details = AddSubcription.objects.filter(farmers=instance.farmers).order_by('-updated_at').first()
                farmer.subscription_package = sub_details.packages
                farmer.subscription_start_date = sub_details.startdate
                farmer.subscription_end_date = sub_details.enddate
                farmer.remaining_days = sub_details.remainingdays
                farmer.amounts = sub_details.packages.amount if sub_details.packages else None
                farmer.sub_amounts = sub_details.packages.sub_amount if sub_details.packages else None
                if sub_details.remainingdays != 0 and sub_details.status != 3 and sub_details.status != 2:
                    farmer.status = 0
                else:
                    farmer.status = 1
                farmer.save()

            if instance.status == 1:
                farmer.status=1
                farmer.save()
            if instance.status == 3:
                farmer.status=6
                farmer.save()
            if instance.status == 4:
                farmer.status=4
                farmer.save()
            if instance.status == 2:
                # farmer.subscription_package = None
                farmer.subscription_start_date = None
                farmer.subscription_end_date = None
                farmer.remaining_days = 0
                # farmer.amounts = None
                # farmer.sub_amounts = None
                farmer.status = 1
                farmer.save()

@receiver(pre_save, sender=AddSubcription)
def update_old_package_report(sender, instance, **kwargs):
    # Check if the subscription instance is being updated (not newly created)
    if instance.pk:
        # Get the current subscription record from the database
        old_subscription = AddSubcription.objects.get(id=instance.pk)
        
        # Check if the package has changed
        old_package = old_subscription.packages
        new_package = instance.packages
        
        if old_package != new_package:
            # Package has changed, update the old package report
            old_report, created_report = SubscriptionReport.objects.get_or_create(
                package=old_package
            )
            # Decrement farmer count for the old package
            if old_subscription.renewal == True:
                old_report.renewal -= 1
            else:
                old_report.total_farmers -= 1
            # total_revenue = old_report.package.sub_amount * (old_report.total_farmers - 1)
            # print("old rev:",old_report.total_revenue - old_report.package.sub_amount)
            old_report.total_revenue = (old_report.total_revenue - old_report.package.sub_amount)
            old_report.save()  # Save the updated old report
        # print("old pack")

@receiver(post_save, sender=AddSubcription)
def update_subscription_report(sender, instance, created, **kwargs):
    # Check if the package is present for this subscription
    package = instance.packages
    if not package:
        return

    report, created_report = SubscriptionReport.objects.get_or_create(
        package=package
    )

    # Get all subscriptions for the given package, month, and year
    subscriptions = AddSubcription.objects.filter(
        packages=package
    )

    # Calculate the total number of farmers for this month
    total_farmers = subscriptions.count()
    renewal_count = subscriptions.filter(renewal = True).count()
    # Recalculate total revenue for the report
    total_revenue = report.package.sub_amount * total_farmers

    # Update the report's total farmers and total revenue
    report.total_farmers = total_farmers-renewal_count
    report.renewal = renewal_count
    report.total_revenue = total_revenue
    
    # Save the report after updating it
    report.save()

    # Print statement for debugging (optional)
    # print(f"Subscription report {'created' if created_report else 'updated'} for {package.name}  Farmers: {total_farmers}, Revenue: {total_revenue}")

# ---------------------------------------------- Manage Markets ------------------------------------------------------
@receiver(post_save, sender=ManageProduct)
def create_or_update_market_product(sender, instance, created, **kwargs):
    # print("create_or_update_market_product Models")
    if created:
        # Create MarketProduct entries for each associated market
        for market in instance.markets.all():
            # print("create_or_update_market_product if market:",market)
            MarketProduct.objects.get_or_create(
                market=market,
                product=instance,
                price=instance.price,
                available=instance.available
            )
    else:
        # Update MarketProduct entries if the product was updated
        for market in instance.markets.all():
            # print("create_or_update_market_product else market:",market)
            if not MarketProduct.objects.filter(market=market,product=instance).exists():
                # print("yes")
                MarketProduct.objects.update_or_create(
                    market=market,
                    product=instance,
                    defaults={'price': instance.price, 'available': instance.available}
                )

@receiver(pre_save, sender=MarketProduct)
def update_product_price_report(sender, instance, **kwargs):
    '''This signal runs before saving a MarketProduct.
    It checks if the price has changed for the product in a specific market and
    creates or updates the report for that day.
    '''
    if instance.id:  # Only check if the MarketProduct already exists (update scenario)
        original = MarketProduct.objects.get(id=instance.id)
        
        # If the price has changed
        # if original.price != instance.price:
        today = datetime.today().date()

        # Check if a report already exists for this product and market on the current day
        report, created = ProductMarketReport.objects.update_or_create(
            product=instance.product,
            market=instance.market,
            created_day=today,
            defaults={'price': instance.price, 'available': instance.available}
        )

        # if created:
        #     print(f"Report created for {instance.product.name} in {instance.market.name} on {today} with price {instance.price}")
        # else:
        #     print(f"Report updated for {instance.product.name} in {instance.market.name} on {today} with price {instance.price}")

# ---------------------------------------------------- Farmer Authendication ------------------------------------------
@receiver(post_save, sender=Farmer)
def update_farmer_authendication(sender, instance, created, **kwargs):
    # print("signals")
    if instance.status !=0:
        # print("not zero")
        if instance.farmer_user:
            # print("yes custom user")
            user = get_object_or_404(CustomUser, pk=instance.farmer_user.id)
            user.is_active = True
            user.save()
    else:
        # print("zero")
        if instance.farmer_user:
            user = get_object_or_404(CustomUser, pk=instance.farmer_user.id)
            user.is_active = True
            user.save()

# --------------------------------------------------------- User Management ----------------------------------

@receiver(user_logged_in)
def track_user_login(sender, request, user, **kwargs):
    # Create a new session record when the user logs in
    UserSession.objects.create(user=user, login_time=timezone.now())

@receiver(user_logged_out)
def track_user_logout(sender, request, user, **kwargs):
    # Update the session record with logout time when the user logs out
    session = UserSession.objects.filter(user=user, logout_time__isnull=True).order_by('-id').first()
    if session:
        session.logout_time = timezone.now()
        session.save()

@receiver(user_logged_in) 
def attach_permissions(sender, request, user, **kwargs):
    try:
        # Get the ManageUser instance associated with the logged-in user
        manage_user = ManageUser.objects.get(custom_user_id=user.id)

        # Store the user's permissions in the session

        request.session['can_view_general_setting'] = manage_user.can_view_general_setting
        request.session['can_edit_general_setting'] = manage_user.can_edit_general_setting
        request.session['can_add_country'] = manage_user.can_add_country
        request.session['can_edit_country'] = manage_user.can_edit_country
        request.session['can_view_country'] = manage_user.can_view_country
        request.session['can_delete_country'] = manage_user.can_delete_country
        request.session['can_status_country'] = manage_user.can_status_country
 
        request.session['can_add_state'] = manage_user.can_add_state
        request.session['can_edit_state'] = manage_user.can_edit_state
        request.session['can_view_state'] = manage_user.can_view_state
        request.session['can_delete_state'] = manage_user.can_delete_state
        request.session['can_status_state'] = manage_user.can_status_state

        request.session['can_add_city'] = manage_user.can_add_city
        request.session['can_edit_city'] = manage_user.can_edit_city
        request.session['can_view_city'] = manage_user.can_view_city
        request.session['can_delete_city'] = manage_user.can_delete_city
        request.session['can_status_city'] = manage_user.can_status_city

        request.session['can_add_taluk'] = manage_user.can_add_taluk
        request.session['can_edit_taluk'] = manage_user.can_edit_taluk
        request.session['can_view_taluk'] = manage_user.can_view_taluk
        request.session['can_delete_taluk'] = manage_user.can_delete_taluk
        request.session['can_status_taluk'] = manage_user.can_status_taluk

        request.session['can_add_village'] = manage_user.can_add_village
        request.session['can_edit_village'] = manage_user.can_edit_village
        request.session['can_view_village'] = manage_user.can_view_village
        request.session['can_delete_village'] = manage_user.can_delete_village
        request.session['can_status_village'] = manage_user.can_status_village

        request.session['can_add_land_unit'] = manage_user.can_add_land_unit
        request.session['can_edit_land_unit'] = manage_user.can_edit_land_unit
        request.session['can_view_land_unit'] = manage_user.can_view_land_unit
        request.session['can_delete_land_unit'] = manage_user.can_delete_land_unit
        request.session['can_status_land_unit'] = manage_user.can_status_land_unit

        request.session['can_add_area_unit'] = manage_user.can_add_area_unit
        request.session['can_edit_area_unit'] = manage_user.can_edit_area_unit
        request.session['can_view_area_unit'] = manage_user.can_view_area_unit
        request.session['can_delete_area_unit'] = manage_user.can_delete_area_unit
        request.session['can_status_area_unit'] = manage_user.can_status_area_unit

        request.session['can_add_soil_type'] = manage_user.can_add_soil_type
        request.session['can_edit_soil_type'] = manage_user.can_edit_soil_type
        request.session['can_view_soil_type'] = manage_user.can_view_soil_type
        request.session['can_delete_soil_type'] = manage_user.can_delete_soil_type
        request.session['can_status_soil_type'] = manage_user.can_status_soil_type

        request.session['can_add_crop_type'] = manage_user.can_add_crop_type
        request.session['can_edit_crop_type'] = manage_user.can_edit_crop_type
        request.session['can_view_crop_type'] = manage_user.can_view_crop_type
        request.session['can_delete_crop_type'] = manage_user.can_delete_crop_type
        request.session['can_status_crop_type'] = manage_user.can_status_crop_type
 
        request.session['can_add_quality'] = manage_user.can_add_quality
        request.session['can_edit_quality'] = manage_user.can_edit_quality
        request.session['can_view_quality'] = manage_user.can_view_quality
        request.session['can_delete_quality'] = manage_user.can_delete_quality
        request.session['can_status_quality'] = manage_user.can_status_quality

        request.session['can_add_crop'] = manage_user.can_add_crop
        request.session['can_edit_crop'] = manage_user.can_edit_crop
        request.session['can_view_crop'] = manage_user.can_view_crop
        request.session['can_delete_crop'] = manage_user.can_delete_crop
        request.session['can_status_crop'] = manage_user.can_status_crop

        request.session['can_add_product_type'] = manage_user.can_add_product_type
        request.session['can_edit_product_type'] = manage_user.can_edit_product_type
        request.session['can_view_product_type'] = manage_user.can_view_product_type
        request.session['can_delete_product_type'] = manage_user.can_delete_product_type
        request.session['can_status_product_type'] = manage_user.can_status_product_type

        request.session['can_add_vehicle_category'] = manage_user.can_add_vehicle_category
        request.session['can_edit_vehicle_category'] = manage_user.can_edit_vehicle_category
        request.session['can_view_vehicle_category'] = manage_user.can_view_vehicle_category
        request.session['can_delete_vehicle_category'] = manage_user.can_delete_vehicle_category
        request.session['can_status_vehicle_category'] = manage_user.can_status_vehicle_category

        request.session['can_add_manage_vehicle'] = manage_user.can_add_manage_vehicle
        request.session['can_edit_manage_vehicle'] = manage_user.can_edit_manage_vehicle
        request.session['can_view_manage_vehicle'] = manage_user.can_view_manage_vehicle
        request.session['can_delete_manage_vehicle'] = manage_user.can_delete_manage_vehicle
        request.session['can_status_manage_vehicle'] = manage_user.can_status_manage_vehicle

        request.session['can_add_machinery_category'] = manage_user.can_add_machinery_category
        request.session['can_edit_machinery_category'] = manage_user.can_edit_machinery_category
        request.session['can_view_machinery_category'] = manage_user.can_view_machinery_category
        request.session['can_delete_machinery_category'] = manage_user.can_delete_machinery_category
        request.session['can_status_machinery_category'] = manage_user.can_status_machinery_category

        request.session['can_add_manage_machinery'] = manage_user.can_add_manage_machinery
        request.session['can_edit_manage_machinery'] = manage_user.can_edit_manage_machinery
        request.session['can_view_manage_machinery'] = manage_user.can_view_manage_machinery
        request.session['can_delete_manage_machinery'] = manage_user.can_delete_manage_machinery
        request.session['can_status_manage_machinery'] = manage_user.can_status_manage_machinery
 
        request.session['can_add_tool_category'] = manage_user.can_add_tool_category
        request.session['can_edit_tool_category'] = manage_user.can_edit_tool_category
        request.session['can_view_tool_category'] = manage_user.can_view_tool_category
        request.session['can_delete_tool_category'] = manage_user.can_delete_tool_category
        request.session['can_status_tool_category'] = manage_user.can_status_tool_category

        request.session['can_add_tool'] = manage_user.can_add_tool
        request.session['can_edit_tool'] = manage_user.can_edit_tool
        request.session['can_view_tool'] = manage_user.can_view_tool
        request.session['can_delete_tool'] = manage_user.can_delete_tool
        request.session['can_status_tool'] = manage_user.can_status_tool

        request.session['can_add_expense_category'] = manage_user.can_add_expense_category
        request.session['can_edit_expense_category'] = manage_user.can_edit_expense_category
        request.session['can_view_expense_category'] = manage_user.can_view_expense_category
        request.session['can_delete_expense_category'] = manage_user.can_delete_expense_category
        request.session['can_status_expense_category'] = manage_user.can_status_expense_category

        request.session['can_add_expense'] = manage_user.can_add_expense
        request.session['can_edit_expense'] = manage_user.can_edit_expense
        request.session['can_view_expense'] = manage_user.can_view_expense
        request.session['can_delete_expense'] = manage_user.can_delete_expense
        request.session['can_status_expense'] = manage_user.can_status_expense

        request.session['can_add_harvesting_type'] = manage_user.can_add_harvesting_type
        request.session['can_edit_harvesting_type'] = manage_user.can_edit_harvesting_type
        request.session['can_view_harvesting_type'] = manage_user.can_view_harvesting_type
        request.session['can_delete_harvesting_type'] = manage_user.can_delete_harvesting_type
        request.session['can_status_harvesting_type'] = manage_user.can_status_harvesting_type

        request.session['can_add_detection'] = manage_user.can_add_detection
        request.session['can_edit_detection'] = manage_user.can_edit_detection
        request.session['can_view_detection'] = manage_user.can_view_detection
        request.session['can_delete_detection'] = manage_user.can_delete_detection
        request.session['can_status_detection'] = manage_user.can_status_detection

        #Farmer Management
        request.session['can_view_farmer'] = manage_user.can_view_farmer
        request.session['can_add_farmer'] = manage_user.can_add_farmer
        request.session['can_edit_farmer'] = manage_user.can_edit_farmer
        request.session['can_delete_farmer'] = manage_user.can_delete_farmer
        request.session['can_view_unique_farmer'] = manage_user.can_view_unique_farmer
        request.session['can_update_farmer_status'] = manage_user.can_update_farmer_status
        request.session['can_export_farmer_data'] = manage_user.can_export_farmer_data
        request.session['can_subscribe_farmer_package'] = manage_user.can_subscribe_farmer_package 
        request.session['can_filter_farmer_data'] = manage_user.can_filter_farmer_data 
        request.session['can_unsubscribe_farmer_package'] = manage_user.can_unsubscribe_farmer_package 

        # Package
        request.session['can_view_package'] = manage_user.can_view_package
        request.session['can_add_package'] = manage_user.can_add_package
        request.session['can_edit_package'] = manage_user.can_edit_package
        request.session['can_delete_package'] = manage_user.can_delete_package
        request.session['can_view_unique_package'] = manage_user.can_view_unique_package 

        # Subscription
        request.session['can_view_subscription'] = manage_user.can_view_subscription
        request.session['can_add_subscription'] = manage_user.can_add_subscription
        request.session['can_edit_subscription'] = manage_user.can_edit_subscription
        request.session['can_delete_subscription'] = manage_user.can_delete_subscription
        request.session['can_view_unique_subscription'] = manage_user.can_view_unique_subscription
        request.session['can_export_subscription'] = manage_user.can_export_subscription
        request.session['can_filter_subscription'] = manage_user.can_filter_subscription
        request.session['can_activeplan_subscription'] = manage_user.can_activeplan_subscription
        request.session['can_renewalplan_subscription'] = manage_user.can_renewalplan_subscription 
        request.session['can_unsubscribe_subscription'] = manage_user.can_unsubscribe_subscription 
        request.session['can_update_subscription_status'] = manage_user.can_update_subscription_status 
        
        request.session['can_add_manage_product'] = manage_user.can_add_manage_product
        request.session['can_view_manage_product'] = manage_user.can_view_manage_product
        request.session['can_edit_manage_product'] = manage_user.can_edit_manage_product
        request.session['can_delete_manage_product'] = manage_user.can_delete_manage_product
        request.session['can_filter_manage_product'] = manage_user.can_filter_manage_product
        request.session['can_update_manage_product'] = manage_user.can_update_manage_product
        request.session['can_graph_manage_product'] = manage_user.can_graph_manage_product
        request.session['can_staff_manage_product'] = manage_user.can_staff_manage_product
         
        request.session['can_filter_market_report'] = manage_user.can_filter_market_report
        request.session['can_view_market_report'] = manage_user.can_view_market_report
        request.session['can_edit_market_report'] = manage_user.can_edit_market_report
        request.session['can_graph_market_report'] = manage_user.can_graph_market_report

        request.session['can_filter_product_market_report'] = manage_user.can_filter_product_market_report
        request.session['can_view_product_market_report'] = manage_user.can_view_product_market_report
        request.session['can_edit_product_market_report'] = manage_user.can_edit_product_market_report
        request.session['can_graph_product_market_report'] = manage_user.can_graph_product_market_report
 
        request.session['can_add_market'] = manage_user.can_add_market
        request.session['can_view_market'] = manage_user.can_view_market
        request.session['can_edit_market'] = manage_user.can_edit_market
        request.session['can_delete_market'] = manage_user.can_delete_market
        request.session['can_view_unique_market'] = manage_user.can_view_unique_market
        request.session['can_status_market'] = manage_user.can_status_market
        request.session['can_export_market'] = manage_user.can_export_market
        request.session['can_filter_market'] = manage_user.can_filter_market

        request.session['can_add_allocate_market'] = manage_user.can_add_allocate_market
        request.session['can_view_allocate_market'] = manage_user.can_view_allocate_market
        request.session['can_edit_allocate_market'] = manage_user.can_edit_allocate_market
        request.session['can_delete_allocate_market'] = manage_user.can_delete_allocate_market
        request.session['can_view_unique_allocate_market'] = manage_user.can_view_unique_allocate_market
        request.session['can_status_allocate_market'] = manage_user.can_status_allocate_market 
        request.session['can_export_allocate_market'] = manage_user.can_export_allocate_market
        
        request.session['can_add_schedule_activity_type'] = manage_user.can_add_schedule_activity_type
        request.session['can_edit_schedule_activity_type'] = manage_user.can_edit_schedule_activity_type
        request.session['can_view_schedule_activity_type'] = manage_user.can_view_schedule_activity_type
        request.session['can_delete_schedule_activity_type'] = manage_user.can_delete_schedule_activity_type
        request.session['can_status_schedule_activity_type'] = manage_user.can_status_schedule_activity_type

        #schedule
        request.session['can_add_schedule'] = manage_user.can_add_schedule
        request.session['can_edit_schedule'] = manage_user.can_edit_schedule
        request.session['can_view_schedule'] = manage_user.can_view_schedule
        request.session['can_delete_schedule'] = manage_user.can_delete_schedule
        request.session['can_status_schedule'] = manage_user.can_status_schedule
        request.session['can_view_unique_schedule'] = manage_user.can_view_unique_schedule  
        request.session['can_filter_schedule'] = manage_user.can_filter_schedule  
        request.session['can_import_schedule'] = manage_user.can_import_schedule  
        
        request.session['can_add_schedule_activity_type'] = manage_user.can_add_schedule_activity_type
        request.session['can_edit_schedule_activity_type'] = manage_user.can_edit_schedule_activity_type
        request.session['can_view_schedule_activity_type'] = manage_user.can_view_schedule_activity_type
        request.session['can_delete_schedule_activity_type'] = manage_user.can_delete_schedule_activity_type
        request.session['can_status_schedule_activity_type'] = manage_user.can_status_schedule_activity_type

        request.session['can_add_near_by_location_category'] = manage_user.can_add_near_by_location_category
        request.session['can_edit_near_by_location_category'] = manage_user.can_edit_near_by_location_category
        request.session['can_view_near_by_location_category'] = manage_user.can_view_near_by_location_category
        request.session['can_delete_near_by_location_category'] = manage_user.can_delete_near_by_location_category
        request.session['can_status_near_by_location_category'] = manage_user.can_status_near_by_location_category 
        
        request.session['can_add_near_by_locations'] = manage_user.can_add_near_by_locations
        request.session['can_edit_near_by_locations'] = manage_user.can_edit_near_by_locations
        request.session['can_view_near_by_locations'] = manage_user.can_view_near_by_locations
        request.session['can_delete_near_by_locations'] = manage_user.can_status_near_by_locations
        request.session['can_status_near_by_locations'] = manage_user.can_status_near_by_locations
        request.session['can_export_near_by_locations'] = manage_user.can_export_near_by_locations
        request.session['can_filter_near_by_locations'] = manage_user.can_filter_near_by_locations
        request.session['can_view_unique_near_by_locations'] = manage_user.can_view_unique_near_by_locations
 
        request.session['can_add_workers_type'] = manage_user.can_add_workers_type
        request.session['can_edit_workers_type'] = manage_user.can_edit_workers_type
        request.session['can_view_workers_type'] = manage_user.can_view_workers_type
        request.session['can_delete_workers_type'] = manage_user.can_delete_workers_type
        request.session['can_update_workers_type_status'] = manage_user.can_update_workers_type_status
 
        request.session['can_add_manage_workers'] = manage_user.can_add_manage_workers
        request.session['can_view_manage_workers'] = manage_user.can_view_manage_workers
        request.session['can_edit_manage_workers'] = manage_user.can_edit_manage_workers
        request.session['can_update_manage_workers'] = manage_user.can_update_manage_workers
        request.session['can_delete_manage_workers'] = manage_user.can_delete_manage_workers
        request.session['can_view_unique_manage_workers'] = manage_user.can_view_unique_manage_workers
        request.session['can_update_manage_workers_status'] = manage_user.can_update_manage_workers_status
        request.session['can_export_manage_workers'] = manage_user.can_export_manage_workers

        request.session['can_add_guidelines_category'] = manage_user.can_add_guidelines_category
        request.session['can_view_guidelines_category'] = manage_user.can_view_guidelines_category
        request.session['can_edit_guidelines_category'] = manage_user.can_edit_guidelines_category
        request.session['can_delete_guidelines_category'] = manage_user.can_delete_guidelines_category
        request.session['can_update_guidelines_category_status'] = manage_user.can_update_guidelines_category_status 
         
        request.session['can_add_guidelines'] = manage_user.can_add_guidelines
        request.session['can_view_guidelines'] = manage_user.can_view_guidelines
        request.session['can_edit_guidelines'] = manage_user.can_edit_guidelines
        request.session['can_delete_guidelines'] = manage_user.can_delete_guidelines
        request.session['can_view_unique_guidelines'] = manage_user.can_view_unique_guidelines 
        request.session['can_update_guidelines_status'] = manage_user.can_update_guidelines_status
        request.session['can_export_guidelines'] = manage_user.can_export_guidelines
        request.session['can_filter_guidelines'] = manage_user.can_filter_guidelines

        request.session['can_view_manage_user'] = manage_user.can_view_manage_user
        request.session['can_add_manage_user'] = manage_user.can_add_manage_user
        request.session['can_edit_manage_user'] = manage_user.can_edit_manage_user
        request.session['can_delete_manage_user'] = manage_user.can_delete_manage_user
        request.session['can_export_manage_user'] = manage_user.can_export_manage_user
 
        request.session['can_filter_manage_user'] = manage_user.can_filter_manage_user
        request.session['can_status_manage_user'] = manage_user.can_status_manage_user
        request.session['can_ter_status_manage_user'] = manage_user.can_ter_status_manage_user
        request.session['can_rel_status_manage_user'] = manage_user.can_rel_status_manage_user
        request.session['can_view_unique_manage_user'] = manage_user.can_view_unique_manage_user

        request.session['can_add_manage_user_role'] = manage_user.can_add_manage_user_role
        request.session['can_view_manage_user_role'] = manage_user.can_view_manage_user_role
        request.session['can_status_manage_user_role'] = manage_user.can_status_manage_user_role
        request.session['can_view_unique_manage_user_role'] = manage_user.can_view_unique_manage_user_role
        request.session['can_edit_manage_user_role'] = manage_user.can_edit_manage_user_role
        request.session['can_delete_manage_user_role'] = manage_user.can_delete_manage_user_role 
 
        request.session['can_export_farmer_report'] = manage_user.can_export_farmer_report
        request.session['can_view_farmer_report'] = manage_user.can_view_farmer_report
        request.session['can_filter_farmer_report'] = manage_user.can_filter_farmer_report
        request.session['can_view_unique_report'] = manage_user.can_view_unique_report
        request.session['can_export_subscription_report'] = manage_user.can_export_subscription_report

        request.session['can_view_subscription_report'] = manage_user.can_view_subscription_report
        request.session['can_filter_subscription_report'] = manage_user.can_filter_subscription_report
        request.session['can_view_unique_subscription_report'] = manage_user.can_view_unique_subscription_report 

        request.session['can_dashboard_count'] = manage_user.can_dashboard_count
        request.session['can_dashboard_total_revenue'] = manage_user.can_dashboard_total_revenue
        request.session['can_farmer_graph'] = manage_user.can_farmer_graph
        request.session['can_subscription_graph'] = manage_user.can_subscription_graph
        request.session['can_revenue_graph'] = manage_user.can_revenue_graph
        request.session['can_market_view']  = manage_user.can_market_view
        request.session['can_market_graph'] = manage_user.can_market_graph
        request.session['can_market_view_staff'] = manage_user.can_market_view_staff

        request.session['can_add_email_config']   = manage_user.can_add_email_config
        request.session['can_view_email_config']  = manage_user.can_view_email_config
        request.session['can_status_email_config']  = manage_user.can_status_email_config
        request.session['can_edit_email_config' ] = manage_user.can_edit_email_config
        request.session['can_delete_email_config']  = manage_user.can_delete_email_config

        request.session['can_view_sms_config' ] = manage_user.can_view_sms_config
        request.session['can_status_sms_config' ] = manage_user.can_status_sms_config
        request.session['can_delete_sms_config']  = manage_user.can_delete_sms_config
        request.session['can_edit_sms_config' ]= manage_user.can_edit_sms_config

        request.session['can_add_inventory_category'] =  manage_user.can_add_inventory_category
        request.session['can_edit_inventory_category'] =   manage_user.can_edit_inventory_category
        request.session['can_view_inventory_category'] =   manage_user.can_view_inventory_category
        request.session['can_delete_inventory_category'] =   manage_user.can_delete_inventory_category
        request.session['can_status_inventory_category'] =   manage_user.can_status_inventory_category

        request.session['can_add_inventory_items'] =  manage_user.can_add_inventory_items
        request.session['can_edit_inventory_items'] =   manage_user.can_edit_inventory_items
        request.session['can_view_inventory_items'] =   manage_user.can_view_inventory_items
        request.session['can_delete_inventory_items'] =   manage_user.can_delete_inventory_items
        request.session['can_status_inventory_items'] =   manage_user.can_status_inventory_items

        request.session['can_add_document_category'] =  manage_user.can_add_document_category
        request.session['can_edit_document_category'] =  manage_user.can_edit_document_category
        request.session['can_view_document_category'] =  manage_user.can_view_document_category
        request.session['can_delete_document_category'] =  manage_user.can_delete_document_category
        request.session['can_status_document_category'] =  manage_user.can_status_document_category

        request.session['can_view_rental_availability'] = manage_user.can_view_rental_availability
        request.session['can_filter_rental_availability'] = manage_user.can_filter_rental_availability
        request.session['can_export_rental_availability'] = manage_user.can_export_rental_availability

    except ManageUser.DoesNotExist:
        pass 

@receiver(post_save, sender=ManageUserRole)
def update_manage_user_on_role_change(sender, instance, created, **kwargs):
    if not created: 
        manage_users = ManageUser.objects.filter(role=instance)
        
        for manage_user in manage_users: 
            manage_user.can_view_general_setting  = instance.can_view_general_setting
            manage_user.can_edit_general_setting = instance.can_edit_general_setting 

            manage_user.can_add_country =instance.can_add_country
            manage_user.can_edit_country =instance.can_edit_country
            manage_user.can_view_country = instance.can_view_country
            manage_user.can_delete_country =  instance.can_delete_country
            manage_user.can_status_country =  instance.can_status_country

            manage_user.can_add_state =  instance.can_add_state
            manage_user.can_edit_state =  instance.can_edit_state
            manage_user.can_view_state =  instance.can_view_state
            manage_user.can_delete_state =  instance.can_delete_state
            manage_user.can_status_state =  instance.can_status_state

            manage_user.can_add_city = instance.can_add_city
            manage_user.can_edit_city =  instance.can_edit_city
            manage_user.can_view_city =  instance.can_view_city
            manage_user.can_delete_city =  instance.can_delete_city
            manage_user.can_status_city = instance.can_status_city

            manage_user.can_add_taluk = instance.can_add_taluk
            manage_user.can_edit_taluk = instance.can_edit_taluk
            manage_user.can_view_taluk =instance.can_view_taluk
            manage_user.can_delete_taluk = instance.can_delete_taluk
            manage_user.can_status_taluk = instance.can_status_taluk

            manage_user.can_add_village = instance.can_add_village
            manage_user.can_edit_village =  instance.can_edit_village
            manage_user.can_view_village =  instance.can_view_village
            manage_user.can_delete_village =  instance.can_delete_village
            manage_user.can_status_village =  instance.can_status_village

            # Data Management

            manage_user.can_add_land_unit =  instance.can_add_land_unit
            manage_user.can_edit_land_unit =  instance.can_edit_land_unit
            manage_user.can_view_land_unit =  instance.can_view_land_unit
            manage_user.can_delete_land_unit =  instance.can_delete_land_unit
            manage_user.can_status_land_unit =  instance.can_status_land_unit

            manage_user.can_add_area_unit = instance.can_add_area_unit
            manage_user.can_edit_area_unit =  instance.can_edit_area_unit
            manage_user.can_view_area_unit =  instance.can_view_area_unit
            manage_user.can_delete_area_unit =  instance.can_delete_area_unit
            manage_user.can_status_area_unit =  instance.can_status_area_unit

            manage_user.can_add_soil_type =  instance.can_add_soil_type
            manage_user.can_edit_soil_type =  instance.can_edit_soil_type
            manage_user.can_view_soil_type =  instance.can_view_soil_type
            manage_user.can_delete_soil_type = instance.can_delete_soil_type
            manage_user.can_status_soil_type = instance.can_status_soil_type

            manage_user.can_add_crop_type =  instance.can_add_crop_type
            manage_user.can_edit_crop_type =  instance.can_edit_crop_type
            manage_user.can_view_crop_type =  instance.can_view_crop_type
            manage_user.can_delete_crop_type =  instance.can_delete_crop_type
            manage_user.can_status_crop_type = instance.can_status_crop_type

            manage_user.can_add_quality =  instance.can_add_quality
            manage_user.can_edit_quality =  instance.can_edit_quality
            manage_user.can_view_quality = instance.can_view_quality
            manage_user.can_delete_quality =  instance.can_delete_quality
            manage_user.can_status_quality =  instance.can_status_quality

            manage_user.can_add_crop =  instance.can_add_crop
            manage_user.can_edit_crop =  instance.can_edit_crop
            manage_user.can_view_crop =  instance.can_view_crop
            manage_user.can_delete_crop =  instance. can_delete_crop
            manage_user.can_status_crop =  instance.can_status_crop

            manage_user.can_add_product_type =  instance.can_add_product_type
            manage_user.can_edit_product_type =  instance.can_edit_product_type
            manage_user.can_view_product_type =  instance.can_view_product_type
            manage_user.can_delete_product_type =  instance.can_delete_product_type
            manage_user.can_status_product_type =  instance.can_status_product_type

            manage_user.can_add_vehicle_category = instance.can_add_vehicle_category
            manage_user.can_edit_vehicle_category =  instance.can_edit_vehicle_category
            manage_user.can_view_vehicle_category = instance.can_view_vehicle_category
            manage_user.can_delete_vehicle_category = instance.can_delete_vehicle_category
            manage_user.can_status_vehicle_category =  instance.can_status_vehicle_category

            manage_user.can_add_manage_vehicle =  instance.can_add_manage_vehicle
            manage_user.can_edit_manage_vehicle =  instance.can_edit_manage_vehicle
            manage_user.can_view_manage_vehicle =  instance.can_view_manage_vehicle
            manage_user.can_delete_manage_vehicle = instance.can_delete_manage_vehicle
            manage_user.can_status_manage_vehicle =  instance.can_status_manage_vehicle

            manage_user.can_add_machinery_category =  instance.can_add_machinery_category
            manage_user.can_edit_machinery_category = instance.can_edit_machinery_category
            manage_user.can_view_machinery_category =  instance.can_view_machinery_category
            manage_user.can_delete_machinery_category =  instance.can_delete_machinery_category
            manage_user.can_status_machinery_category =  instance.can_status_machinery_category

            manage_user.can_add_manage_machinery =  instance.can_add_manage_machinery
            manage_user.can_edit_manage_machinery =  instance.can_edit_manage_machinery
            manage_user.can_view_manage_machinery =  instance.can_view_manage_machinery
            manage_user.can_delete_manage_machinery =  instance.can_delete_manage_machinery
            manage_user.can_status_manage_machinery =  instance.can_status_manage_machinery

            manage_user.can_add_tool_category = instance.can_add_tool_category
            manage_user.can_edit_tool_category =  instance.can_edit_tool_category
            manage_user.can_view_tool_category = instance.can_view_tool_category
            manage_user.can_delete_tool_category = instance.can_delete_tool_category
            manage_user.can_status_tool_category =  instance.can_status_tool_category

            manage_user.can_add_tool =  instance.can_add_tool
            manage_user.can_edit_tool =  instance.can_edit_tool
            manage_user.can_view_tool =  instance.can_view_tool
            manage_user.can_delete_tool =  instance.can_delete_tool
            manage_user.can_status_tool =  instance.can_status_tool

            manage_user.can_add_expense_category =  instance.can_add_expense_category
            manage_user.can_edit_expense_category =  instance.can_edit_expense_category
            manage_user.can_view_expense_category =  instance.can_view_expense_category
            manage_user.can_delete_expense_category =  instance.can_delete_expense_category
            manage_user.can_status_expense_category =  instance.can_status_expense_category

            manage_user.can_add_expense =  instance.can_add_expense
            manage_user.can_edit_expense = instance.can_edit_expense
            manage_user.can_view_expense = instance.can_view_expense
            manage_user.can_delete_expense = instance.can_delete_expense
            manage_user.can_status_expense = instance.can_status_expense

            manage_user.can_add_harvesting_type = instance.can_add_harvesting_type
            manage_user.can_edit_harvesting_type =instance.can_edit_harvesting_type
            manage_user.can_view_harvesting_type = instance.can_view_harvesting_type
            manage_user.can_delete_harvesting_type = instance.can_delete_harvesting_type
            manage_user.can_status_harvesting_type = instance.can_status_harvesting_type

            manage_user.can_add_detection = instance.can_add_detection
            manage_user.can_edit_detection = instance.can_edit_detection
            manage_user.can_view_detection = instance.can_view_detection
            manage_user.can_delete_detection = instance.can_delete_detection
            manage_user.can_status_detection = instance.can_status_detection

            # farmer management
            manage_user.can_add_farmer = instance.can_add_farmer
            manage_user.can_view_farmer = instance.can_view_farmer
            manage_user.can_edit_farmer = instance.can_edit_farmer
            manage_user.can_delete_farmer = instance.can_delete_farmer
            manage_user.can_view_unique_farmer =instance.can_view_unique_farmer
            manage_user.can_update_farmer_status = instance.can_update_farmer_status
            manage_user.can_export_farmer_data = instance.can_export_farmer_data
            manage_user.can_filter_farmer_data = instance.can_filter_farmer_data

            # package management
            manage_user.can_add_package =instance.can_add_package
            manage_user.can_view_package = instance.can_view_package
            manage_user.can_edit_package = instance.can_edit_package
            manage_user.can_delete_package = instance.can_delete_package
            manage_user.can_view_unique_package = instance.can_view_unique_package

            # subscription management
            manage_user.can_add_subscription = instance.can_add_subscription
            manage_user.can_view_subscription = instance.can_view_subscription
            manage_user.can_edit_subscription = instance.can_edit_subscription
            manage_user.can_delete_subscription = instance.can_delete_subscription
            manage_user.can_view_unique_subscription =instance.can_view_unique_subscription
            manage_user.can_export_subscription = instance.can_export_subscription
            manage_user.can_filter_subscription =instance.can_filter_subscription
            manage_user.can_activeplan_subscription = instance.can_activeplan_subscription
            manage_user.can_renewalplan_subscription = instance.can_renewalplan_subscription

            # --> Market Price 
            manage_user.can_add_manage_product =  instance.can_add_manage_product
            manage_user.can_view_manage_product =  instance.can_view_manage_product
            manage_user.can_edit_manage_product =  instance.can_edit_manage_product
            manage_user.can_delete_manage_product =  instance.can_delete_manage_product
            manage_user.can_filter_manage_product =  instance.can_filter_manage_product
            manage_user.can_update_manage_product =  instance.can_update_manage_product
            manage_user.can_graph_manage_product =  instance.can_graph_manage_product
            manage_user.can_staff_manage_product = instance.can_staff_manage_product

            manage_user.can_filter_market_report  = instance.can_filter_market_report
            manage_user.can_view_market_report = instance.can_view_market_report
            manage_user.can_edit_market_report = instance.can_edit_market_report
            manage_user.can_graph_market_report = instance.can_graph_market_report

            manage_user.can_filter_product_market_report  =instance.can_filter_product_market_report
            manage_user.can_view_product_market_report =  instance.can_view_product_market_report
            manage_user.can_edit_product_market_report =  instance.can_edit_product_market_report
            manage_user.can_graph_product_market_report =  instance.can_graph_product_market_report

            # --> Market Management

            manage_user.can_add_market =  instance.can_add_market
            manage_user.can_view_market =  instance.can_view_market
            manage_user.can_edit_market = instance.can_edit_market
            manage_user.can_delete_market =  instance.can_delete_market
            manage_user.can_view_unique_market =  instance.can_view_unique_market
            manage_user.can_status_market =  instance.can_status_market
            manage_user.can_export_market =  instance.can_export_market
            manage_user.can_filter_market =  instance.can_filter_market

            manage_user.can_add_allocate_market =  instance.can_add_allocate_market
            manage_user.can_view_allocate_market =  instance.can_view_allocate_market
            manage_user.can_edit_allocate_market =  instance.can_edit_allocate_market
            manage_user.can_delete_allocate_market =  instance.can_delete_allocate_market
            manage_user.can_view_unique_allocate_market =  instance.can_view_unique_allocate_market
            manage_user.can_status_allocate_market =  instance.can_status_allocate_market
            manage_user.can_export_allocate_market = instance.can_export_allocate_market

            # --> Schedule Management

            manage_user.can_add_schedule_activity_type = instance.can_add_schedule_activity_type
            manage_user.can_edit_schedule_activity_type = instance.can_edit_schedule_activity_type
            manage_user.can_view_schedule_activity_type = instance.can_view_schedule_activity_type
            manage_user.can_delete_schedule_activity_type = instance.can_delete_schedule_activity_type
            manage_user.can_status_schedule_activity_type = instance.can_status_schedule_activity_type

            manage_user.can_add_schedule  =  instance.can_add_schedule
            manage_user.can_edit_schedule  =  instance.can_edit_schedule
            manage_user.can_view_schedule =  instance.can_view_schedule
            manage_user.can_delete_schedule =  instance.can_delete_schedule
            manage_user.can_status_schedule =  instance.can_status_schedule
            manage_user.can_view_unique_schedule =  instance.can_view_unique_schedule

            # --> NearBy Locations

            manage_user.can_add_near_by_location_category =  instance.can_add_near_by_location_category
            manage_user.can_edit_near_by_location_category =  instance.can_edit_near_by_location_category
            manage_user.can_view_near_by_location_category =  instance.can_view_near_by_location_category
            manage_user.can_delete_near_by_location_category =  instance.can_delete_near_by_location_category
            manage_user.can_status_near_by_location_category =  instance.can_status_near_by_location_category

            manage_user.can_add_near_by_locations =  instance.can_add_near_by_locations
            manage_user.can_edit_near_by_locations =  instance.can_edit_near_by_locations
            manage_user.can_view_near_by_locations =  instance.can_view_near_by_locations
            manage_user.can_delete_near_by_locations =  instance.can_delete_near_by_locations
            manage_user.can_status_near_by_locations =  instance.can_status_near_by_locations
            manage_user.can_export_near_by_locations =  instance.can_export_near_by_locations
            manage_user.can_filter_near_by_locations =  instance.can_filter_near_by_locations
            manage_user.can_view_unique_near_by_locations =  instance.can_view_unique_near_by_locations

            # --> Workers Availability

            manage_user.can_add_workers_type =  instance.can_add_workers_type
            manage_user.can_edit_workers_type =  instance.can_edit_workers_type
            manage_user.can_view_workers_type =  instance.can_view_workers_type
            manage_user.can_delete_workers_type =  instance.can_delete_workers_type
            manage_user.can_update_workers_type_status = instance.can_update_workers_type_status

            manage_user.can_add_manage_workers = instance.can_add_manage_workers
            manage_user.can_view_manage_workers = instance.can_view_manage_workers
            manage_user.can_edit_manage_workers = instance.can_edit_manage_workers
            manage_user.can_update_manage_workers = instance.can_update_manage_workers
            manage_user.can_delete_manage_workers = instance.can_delete_manage_workers
            manage_user.can_view_unique_manage_workers= instance.can_view_unique_manage_workers
            manage_user.can_update_manage_workers_status =  instance.can_update_manage_workers_status
            manage_user.can_export_manage_workers= instance.can_export_manage_workers
            manage_user.can_filter_manage_workers = instance.can_filter_manage_workers

            # ---> Guidelines Management 

            manage_user.can_add_guidelines_category = instance.can_add_guidelines_category
            manage_user.can_view_guidelines_category = instance.can_edit_guidelines_category
            manage_user.can_edit_guidelines_category = instance.can_delete_guidelines_category
            manage_user.can_delete_guidelines_category = instance.can_delete_guidelines_category
            manage_user.can_update_guidelines_category_status =  instance.can_update_guidelines_category_status

            manage_user.can_add_guidelines = instance.can_add_guidelines
            manage_user.can_view_guidelines = instance.can_view_guidelines
            manage_user.can_edit_guidelines = instance.can_edit_guidelines
            manage_user.can_delete_guidelines = instance.can_delete_guidelines
            manage_user.can_view_unique_guidelines= instance.can_view_unique_guidelines
            manage_user.can_update_guidelines_status = instance.can_update_guidelines_status
            manage_user.can_export_guidelines = instance.can_export_guidelines
            manage_user.can_filter_guidelines = instance.can_filter_guidelines

            # ---> User Management

            manage_user.can_view_manage_user = instance.can_view_manage_user
            manage_user.can_add_manage_user = instance.can_add_manage_user
            manage_user.can_edit_manage_user = instance.can_edit_manage_user
            manage_user.can_delete_manage_user = instance.can_delete_manage_user
            manage_user.can_export_manage_user = instance.can_export_manage_user
            manage_user.can_filter_manage_user = instance.can_filter_manage_user
            manage_user.can_status_manage_user = instance.can_status_manage_user
            manage_user.can_ter_status_manage_user = instance.can_ter_status_manage_user
            manage_user.can_rel_status_manage_user =instance.can_rel_status_manage_user
            manage_user.can_view_unique_manage_user = instance.can_view_unique_manage_user

            manage_user.can_add_manage_user_role = instance.can_add_manage_user_role
            manage_user.can_view_manage_user_role = instance.can_view_manage_user_role
            manage_user.can_status_manage_user_role = instance.can_status_manage_user_role
            manage_user.can_view_unique_manage_user_role = instance.can_view_unique_manage_user_role
            manage_user.can_edit_manage_user_role = instance.can_edit_manage_user_role
            manage_user.can_delete_manage_user_role = instance.can_delete_manage_user_role

            # --> Report

            manage_user.can_export_farmer_report = instance.can_export_farmer_report
            manage_user.can_view_farmer_report = instance.can_view_farmer_report
            manage_user.can_filter_farmer_report = instance.can_filter_farmer_report
            manage_user.can_view_unique_report = instance.can_view_unique_report

            manage_user.can_export_subscription_report =instance.can_export_subscription_report
            manage_user.can_view_subscription_report = instance.can_view_subscription_report
            manage_user.can_filter_subscription_report = instance.can_filter_subscription_report
            manage_user.can_view_unique_subscription_report =instance.can_view_unique_subscription_report
 
            manage_user.can_dashboard_count = instance.can_dashboard_count
            manage_user.can_dashboard_total_revenue = instance.can_dashboard_total_revenue
            manage_user.can_farmer_graph = instance.can_farmer_graph
            manage_user.can_subscription_graph = instance.can_subscription_graph
            manage_user.can_revenue_graph = instance.can_revenue_graph
            manage_user.can_market_view  = instance.can_market_view
            manage_user.can_market_graph = instance.can_market_graph
            manage_user.can_market_view_staff = instance.can_market_view_staff
 
            manage_user.can_add_email_config   = instance.can_add_email_config
            manage_user.can_view_email_config  = instance.can_view_email_config
            manage_user.can_status_email_config  = instance.can_status_email_config
            manage_user.can_edit_email_config  = instance.can_edit_email_config
            manage_user.can_delete_email_config  = instance.can_delete_email_config

            manage_user.can_view_sms_config  = instance.can_view_sms_config
            manage_user.can_status_sms_config  = instance.can_status_sms_config
            manage_user.can_delete_sms_config  = instance.can_delete_sms_config
            manage_user.can_edit_sms_config = instance.can_edit_sms_config

            manage_user.can_add_inventory_category  =  instance.can_add_inventory_category
            manage_user.can_edit_inventory_category  =   instance.can_edit_inventory_category
            manage_user.can_view_inventory_category =   instance.can_view_inventory_category
            manage_user.can_delete_inventory_category =   instance.can_delete_inventory_category
            manage_user.can_status_inventory_category =   instance.can_status_inventory_category

            manage_user.can_add_inventory_items  =  instance.can_add_inventory_items
            manage_user.can_edit_inventory_items =   instance.can_edit_inventory_items
            manage_user.can_view_inventory_items  =   instance.can_view_inventory_items
            manage_user.can_delete_inventory_items  =   instance.can_delete_inventory_items
            manage_user.can_status_inventory_items  =   instance.can_status_inventory_items

            manage_user.can_add_document_category =  instance.can_add_document_category
            manage_user.can_edit_document_category =  instance.can_edit_document_category
            manage_user.can_view_document_category =  instance.can_view_document_category
            manage_user.can_delete_document_category =  instance.can_delete_document_category
            manage_user.can_status_document_category =  instance.can_status_document_category

            manage_user.save()


# ------------------------------------------------------- Attendance & Payouts ---------------------------------------

@receiver(post_save, sender=Employee)
def create_attendance(sender, instance, created, **kwargs):
    if created:
        Attendance.objects.get_or_create(employee=instance,
                                         farmer=instance.farmer,
                                         present=False,
                                         created_by = instance.created_by
                                         )
    # else:
    #     Attendance.objects.update_or_create(employee=instance,
    #                                      farmer=instance.farmer,
    #                                      present=False,
    #                                      created_by = instance.created_by
    #                                      )

@receiver(post_save, sender=EmployeeAdvance)
def update_employee(sender, instance, created, **kwargs):
    if created:
        emp = get_object_or_404(Employee, pk=instance.employee.id)
        if emp.advance != instance.previous_advance_amount:
            emp.advance = instance.previous_advance_amount
            emp.save()
        translation_thread = threading.Thread(target=translate_description, args=(instance,))
        translation_thread.start()

@receiver(post_save, sender=EmployeePayouts)
def update_employee(sender, instance, created, **kwargs):
    emp = get_object_or_404(Employee, pk=instance.employee.id)
    advances = EmployeeAdvance.objects.filter(employee=emp)
    for adv in advances:
        adv.status = 1
        adv.save()
    emp.advance = instance.balance_advance
    emp.topay = instance.topay
    emp.save()
    
    if created:
        translation_thread = threading.Thread(target=translate_description, args=(instance,))
        translation_thread.start()

@receiver(post_save, sender=AttendanceReport)
def update_employee_topay_create_attendance(sender, instance, created, **kwargs):
    if created:
        if instance.salary_status == False:
            emp = get_object_or_404(Employee, pk=instance.employee.id)
            emp.topay = float(emp.topay) + float(instance.salary)
            emp.save()

@receiver(pre_save, sender=AttendanceReport)
def update_employee_topay_update_attendance(sender, instance, **kwargs):
    if instance.pk:
        if instance.salary_status == False:
            # Retrieve the old instance of the AttendanceReport to access the previous salary
            old_instance = AttendanceReport.objects.get(pk=instance.pk)
            # print("old:",old_instance.salary)
            # print("current:",instance.salary)
            if old_instance.salary_status != instance.salary_status:
                emp = get_object_or_404(Employee, pk=instance.employee.id)
                emp.topay = float(emp.topay) + float(instance.salary)
                emp.save()
            elif old_instance.salary != instance.salary:
                emp = get_object_or_404(Employee, pk=instance.employee.id)
                emp.topay = float(emp.topay) - float(old_instance.salary) + float(instance.salary)
                emp.save()
        else:
            print("paid")
            old_instance = AttendanceReport.objects.get(pk=instance.pk)
            # print("old paid:",old_instance.salary)
            # print("current paid:",instance.salary)
            if old_instance.salary_status != instance.salary_status:
                emp = get_object_or_404(Employee, pk=instance.employee.id)
                emp.topay = float(emp.topay) -  float(instance.salary)
                emp.save()


 
# ------------------------------------------ My Purchase ---------------------------------------------


@receiver(post_save, sender=MyFuel)
def create_fuel_inventory(sender, instance, created, **kwargs):
    if created:
        inventory = MyInventory.objects.create(
            date_of_consumption = instance.date_of_consumption,
            # crop = crop,
            inventory_type = instance.inventory_type,
            inventory_category = instance.inventory_category,
            inventory_items = instance.inventory_items,
            quantity_utilized = 0,
            # description = description,
            available_quans = instance.available_quans,
            created_at = timezone.now(),
            farmer=instance.farmer,
            created_by=instance.created_by,
            fuel_purchase=instance,
            status = instance.status,
        )
        translated_json = {
            "description": {}
        }
        try:
            languages = Languages.objects.filter(status=0).exclude(id=1)
            target_language = [lang.language_code for lang in languages]
            for lang in target_language:
                if instance.description:
                    translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
                    translated_json["description"][lang] = translated_text
        except Exception as e:
            print(e)
            print("Error in translating Purchase")
        instance.translate_json = translated_json
        instance.save()
    else: 
        try:
            inventory = MyInventory.objects.get(
                Q(fuel_purchase=instance) & Q(crop__isnull=True) & Q(quantity_utilized=0)
            )
            # print('found the record',inventory.date_of_consumption, inventory.available_quans, instance.available_quans)
            inventory.date_of_consumption = instance.date_of_consumption
            inventory.inventory_type = instance.inventory_type
            inventory.inventory_category = instance.inventory_category
            inventory.inventory_items = instance.inventory_items
            inventory.available_quans = instance.available_quans
            # inventory.updated_at = timezone.now()  # Optional: if you want to track when it was updated
            inventory.save()

            if instance.status != 1:
                try:
                    outstanding = Outstanding.objects.filter(fuel_purchase=instance).order_by('-id').first()
                except Exception as e:
                    outstanding = None
                
                if outstanding and instance.status != 2:
                    # reset old value
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)

                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True

                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)
                        
                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                        
                    # create new record
                    if float(instance.purchase_amount) != float(instance.paid_amount):
                        outstanding.delete()
                        if float(instance.purchase_amount) > float(instance.paid_amount): # payables
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                fuel_purchase=instance,
                                balance=instance.purchase_amount,
                                paid=instance.paid_amount,
                                to_pay= float(instance.purchase_amount) - float(instance.paid_amount),
                                paid_date = instance.date_of_consumption,
                                total_paid=instance.paid_amount,
                                identify=1,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_pay) > 0:
                                vendor.payables = float(vendor.payables) + float(new_outstanding.to_pay)

                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_pay):
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_pay)
                                    else:
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(new_outstanding.to_pay) - float(vendor.opening_balance)
                                
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                
                                vendor.save()
                                
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.payables = vendor.payables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()
                        
                        else:
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                fuel_purchase=instance,
                                balance= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid=instance.paid_amount,
                                to_receive= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid_date = instance.date_of_consumption,
                                received_date = instance.date_of_consumption,
                                total_received=instance.paid_amount,
                                identify=1,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_receive) > 0:
                                vendor.receivables = float(vendor.receivables) + float(new_outstanding.to_receive)

                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_receive):
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_receive)
                                    else:
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(new_outstanding.to_receive) - float(vendor.opening_balance)
                                
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                
                                vendor.save()
                                
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.receivables = vendor.receivables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()

                    else:
                        outstanding.to_pay = 0
                        outstanding.to_receive = 0
                        outstanding.status = 2
                        outstanding.save()

                elif outstanding and instance.status == 2:
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)

                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            if float(vendor.opening_balance) > float(outstanding.to_receive):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_receive)
                                vendor.credit = True
                                vendor.debit = False
                            else:
                                vendor.opening_balance = float(outstanding.to_receive) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            vendor.credit = False
                            vendor.debit = True
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_receive)
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)

                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            vendor.credit = True
                            vendor.debit = False
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_pay)
                            
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            if float(vendor.opening_balance) > float(outstanding.to_pay):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_pay)
                                vendor.credit = False
                                vendor.debit = True
                            else:
                                vendor.opening_balance = float(outstanding.to_pay) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()

                    outstanding.status = 2
                    outstanding.save()
                    all_outstanding = Outstanding.objects.filter(fuel_purchase=instance)
                    for ao in all_outstanding:
                        ao.status = 2
                        ao.save()
                
        except MyInventory.DoesNotExist:
            # Handle case where the inventory record is not found
            pass

@receiver(post_save, sender=MyVehicle)
def create_vehicle_inventory(sender, instance, created, **kwargs):
    if created:
        inventory = MyInventory.objects.create(
            date_of_consumption = instance.date_of_consumption,
            # crop = crop,
            inventory_type = instance.inventory_type,
            inventory_category = instance.inventory_category,
            inventory_items = instance.inventory_items,
            quantity_utilized = 0,
            # description = description,
            # available_quans = instance.quantity,
            created_at = timezone.now(),
            farmer=instance.farmer,
            created_by=instance.created_by,
            vehicle_purchase=instance,
            status = instance.status,
        )
        translated_json = {
            "owner_name": {},
            "company_name": {},
            "description": {}
        }
        try:
            languages = Languages.objects.filter(status=0).exclude(id=1)
            target_language = [lang.language_code for lang in languages]
            for lang in target_language:
                if instance.owner_name:
                    translated_json["owner_name"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.owner_name)
                if instance.company_name:
                    translated_json["company_name"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.company_name)
                if instance.description:
                    translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
                    translated_json["description"][lang] = translated_text
        except Exception as e:
            print(e)
            print("Error in translating Purchase")
        instance.translate_json = translated_json
        instance.save()
    else:
        try:
            if instance.status != 1:
                try:
                    outstanding = Outstanding.objects.filter(vehicle_purchase=instance).first()
                except Exception as e:
                    outstanding = None
                
                if outstanding and instance.status != 2:
                    # reset old value
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)

                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True

                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)
                        
                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                        
                    # create new record
                    if float(instance.purchase_amount) != float(instance.paid_amount):
                        outstanding.delete()
                        if float(instance.purchase_amount) > float(instance.paid_amount): # payables
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                vehicle_purchase=instance,
                                balance=instance.purchase_amount,
                                paid=instance.paid_amount,
                                to_pay= float(instance.purchase_amount) - float(instance.paid_amount),
                                paid_date = instance.date_of_consumption,
                                total_paid=instance.paid_amount,
                                identify=2,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_pay) > 0:
                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_pay):
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_pay)
                                    else:
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(new_outstanding.to_pay) - float(vendor.opening_balance)
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                vendor.save()
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.payables = vendor.payables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()
                        else:
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                vehicle_purchase=instance,
                                balance= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid=instance.paid_amount,
                                to_receive= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid_date = instance.date_of_consumption,
                                received_date = instance.date_of_consumption,
                                total_paid=instance.paid_amount,
                                identify=2,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_receive) > 0:
                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_receive):
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_receive)
                                    else:
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(new_outstanding.to_receive) - float(vendor.opening_balance)
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                vendor.save()
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.receivables = vendor.receivables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()

                    else:
                        outstanding.to_pay = 0
                        outstanding.to_receive = 0
                        outstanding.status = 2
                        outstanding.save()
            
                elif outstanding and instance.status == 2:
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)
                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            if float(vendor.opening_balance) > float(outstanding.to_receive):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_receive)
                                vendor.credit = True
                                vendor.debit = False
                            else:
                                vendor.opening_balance = float(outstanding.to_receive) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            vendor.credit = False
                            vendor.debit = True
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_receive)
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)
                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            vendor.credit = True
                            vendor.debit = False
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_pay)
                            
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            if float(vendor.opening_balance) > float(outstanding.to_pay):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_pay)
                                vendor.credit = False
                                vendor.debit = True
                            else:
                                vendor.opening_balance = float(outstanding.to_pay) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()

                    outstanding.status = 2
                    outstanding.save()
                    all_outstanding = Outstanding.objects.filter(vehicle_purchase=instance)
                    for ao in all_outstanding:
                        ao.status = 2
                        ao.save()
                
        except Exception as e:
            pass

@receiver(post_save, sender=MyMachinery)
def create_machinery_inventory(sender, instance, created, **kwargs):
    if created:
        inventory = MyInventory.objects.create(
            date_of_consumption = instance.date_of_consumption,
            # crop = crop,
            inventory_type = instance.inventory_type,
            inventory_category = instance.inventory_category,
            inventory_items = instance.inventory_items,
            quantity_utilized = 0,
            # description = description,
            # available_quans = instance.quantity,
            created_at = timezone.now(),
            farmer=instance.farmer,
            created_by=instance.created_by,
            machinery_purchase=instance,
            status = instance.status,
        )
        translated_json = {
            "description": {}
        }
        try:
            languages = Languages.objects.filter(status=0).exclude(id=1)
            target_language = [lang.language_code for lang in languages]
            for lang in target_language:
                if instance.description:
                    translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
                    translated_json["description"][lang] = translated_text
        except Exception as e:
            print(e)
            print("Error in translating Purchase")
        instance.translate_json = translated_json
        instance.save()
    else:
        try:
            if instance.status != 1:
                try:
                    outstanding = Outstanding.objects.filter(machinery_purchase=instance).first()
                except Exception as e:
                    outstanding = None
                
                if outstanding and instance.status != 2:
                    # reset old value
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)

                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True

                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)
                        
                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                           
                    # create new record
                    if float(instance.purchase_amount) != float(instance.paid_amount):
                        outstanding.delete()
                        if float(instance.purchase_amount) > float(instance.paid_amount): # payables
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                machinery_purchase=instance,
                                balance=instance.purchase_amount,
                                paid=instance.paid_amount,
                                to_pay= float(instance.purchase_amount) - float(instance.paid_amount),
                                paid_date = instance.date_of_consumption,
                                total_paid=instance.paid_amount,
                                identify=3,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_pay) > 0:
                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_pay):
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_pay)
                                    else:
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(new_outstanding.to_pay) - float(vendor.opening_balance)
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                vendor.save()
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.payables = vendor.payables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()
                        else:
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                machinery_purchase=instance,
                                balance= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid=instance.paid_amount,
                                to_receive= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid_date = instance.date_of_consumption,
                                received_date = instance.date_of_consumption,
                                total_paid=instance.paid_amount,
                                identify=3,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_receive) > 0:
                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_receive):
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_receive)
                                    else:
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(new_outstanding.to_receive) - float(vendor.opening_balance)
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                vendor.save()
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.receivables = vendor.receivables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()

                    else:
                        outstanding.to_pay = 0
                        outstanding.to_receive = 0
                        outstanding.status = 2
                        outstanding.save()
            
                elif outstanding and instance.status == 2:
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)
                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            if float(vendor.opening_balance) > float(outstanding.to_receive):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_receive)
                                vendor.credit = True
                                vendor.debit = False
                            else:
                                vendor.opening_balance = float(outstanding.to_receive) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            vendor.credit = False
                            vendor.debit = True
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_receive)
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)
                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            vendor.credit = True
                            vendor.debit = False
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_pay)
                            
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            if float(vendor.opening_balance) > float(outstanding.to_pay):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_pay)
                                vendor.credit = False
                                vendor.debit = True
                            else:
                                vendor.opening_balance = float(outstanding.to_pay) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()

                    outstanding.status = 2
                    outstanding.save()
                    all_outstanding = Outstanding.objects.filter(machinery_purchase=instance)
                    for ao in all_outstanding:
                        ao.status = 2
                        ao.save()

        except Exception as e:
            pass

@receiver(post_save, sender=MyTools)
def create_tools_inventory(sender, instance, created, **kwargs):
    if created:
        inventory = MyInventory.objects.create(
            date_of_consumption = instance.date_of_consumption,
            # crop = crop,
            inventory_type = instance.inventory_type,
            inventory_category = instance.inventory_category,
            inventory_items = instance.inventory_items,
            quantity_utilized = 0,
            # description = description,
            available_quans = instance.available_quans,
            created_at = timezone.now(),
            farmer=instance.farmer,
            created_by=instance.created_by,
            tool_purchase=instance,
            status = instance.status,
        )
        translated_json = {
            "description": {}
        }
        try:
            languages = Languages.objects.filter(status=0).exclude(id=1)
            target_language = [lang.language_code for lang in languages]
            for lang in target_language:
                if instance.description:
                    translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
                    translated_json["description"][lang] = translated_text
        except Exception as e:
            print(e)
            print("Error in translating Purchase")
        instance.translate_json = translated_json
        instance.save()
    else:
        try:
            inventory = MyInventory.objects.get(
                Q(tool_purchase=instance) & Q(crop__isnull=True) & Q(quantity_utilized=0)
            )
            # print('found the record',inventory.date_of_consumption, inventory.available_quans, instance.available_quans)
            inventory.date_of_consumption = instance.date_of_consumption
            inventory.inventory_type = instance.inventory_type
            inventory.inventory_category = instance.inventory_category
            inventory.inventory_items = instance.inventory_items
            inventory.available_quans = instance.available_quans
            inventory.save()

            if instance.status != 1:
                try:
                    outstanding = Outstanding.objects.filter(tool_purchase=instance).first()
                except Exception as e:
                    outstanding = None
                
                if outstanding and instance.status != 2:
                    # reset old value
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)

                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True

                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)
                        
                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                      
                    # create new record
                    if float(instance.purchase_amount) != float(instance.paid_amount):
                        outstanding.delete()
                        if float(instance.purchase_amount) > float(instance.paid_amount): # payables
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                tool_purchase=instance,
                                balance=instance.purchase_amount,
                                paid=instance.paid_amount,
                                to_pay= float(instance.purchase_amount) - float(instance.paid_amount),
                                paid_date = instance.date_of_consumption,
                                total_paid=instance.paid_amount,
                                identify=4,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_pay) > 0:
                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_pay):
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_pay)
                                    else:
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(new_outstanding.to_pay) - float(vendor.opening_balance)
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                vendor.save()
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.payables = vendor.payables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()
                        else:
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                tool_purchase=instance,
                                balance= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid=instance.paid_amount,
                                to_receive= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid_date = instance.date_of_consumption,
                                received_date = instance.date_of_consumption,
                                total_paid=instance.paid_amount,
                                identify=4,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_receive) > 0:
                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_receive):
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_receive)
                                    else:
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(new_outstanding.to_receive) - float(vendor.opening_balance)
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                vendor.save()
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.receivables = vendor.receivables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()

                    else:
                        outstanding.to_pay = 0
                        outstanding.to_receive = 0
                        outstanding.status = 2
                        outstanding.save()

                elif outstanding and instance.status == 2:
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)
                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            if float(vendor.opening_balance) > float(outstanding.to_receive):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_receive)
                                vendor.credit = True
                                vendor.debit = False
                            else:
                                vendor.opening_balance = float(outstanding.to_receive) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            vendor.credit = False
                            vendor.debit = True
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_receive)
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)
                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            vendor.credit = True
                            vendor.debit = False
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_pay)
                            
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            if float(vendor.opening_balance) > float(outstanding.to_pay):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_pay)
                                vendor.credit = False
                                vendor.debit = True
                            else:
                                vendor.opening_balance = float(outstanding.to_pay) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()

                    outstanding.status = 2
                    outstanding.save()
                    all_outstanding = Outstanding.objects.filter(tool_purchase=instance)
                    for ao in all_outstanding:
                        ao.status = 2
                        ao.save()

        except MyInventory.DoesNotExist:
            pass

@receiver(post_save, sender=MyPesticides)
def create_pesticides_inventory(sender, instance, created, **kwargs):
    if created:
        inventory = MyInventory.objects.create(
            date_of_consumption = instance.date_of_consumption,
            # crop = crop,
            inventory_type = instance.inventory_type,
            inventory_category = instance.inventory_category,
            inventory_items = instance.inventory_items,
            quantity_utilized = 0,
            # description = description,
            available_quans = instance.available_quans,
            created_at = timezone.now(),
            farmer=instance.farmer,
            created_by=instance.created_by,
            pesticide_purchase=instance,
            status = instance.status,
        )
        translated_json = {
            "description": {}
        }
        try:
            languages = Languages.objects.filter(status=0).exclude(id=1)
            target_language = [lang.language_code for lang in languages]
            for lang in target_language:
                if instance.description:
                    translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
                    translated_json["description"][lang] = translated_text
        except Exception as e:
            print(e)
            print("Error in translating Purchase")
        instance.translate_json = translated_json
        instance.save()
    else:
        try:
            inventory = MyInventory.objects.get(
                Q(pesticide_purchase=instance) & Q(crop__isnull=True) & Q(quantity_utilized=0)
            )
            # print('found the record',inventory.date_of_consumption, inventory.available_quans, instance.available_quans)
            inventory.date_of_consumption = instance.date_of_consumption
            inventory.inventory_type = instance.inventory_type
            inventory.inventory_category = instance.inventory_category
            inventory.inventory_items = instance.inventory_items
            inventory.available_quans = instance.available_quans
            inventory.save()

            if instance.status != 1:
                try:
                    outstanding = Outstanding.objects.filter(pesticide_purchase=instance).first()
                except Exception as e:
                    outstanding = None
                
                if outstanding and instance.status != 2:
                    # reset old value
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)

                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True

                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)
                        
                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                       
                    # create new record
                    if float(instance.purchase_amount) != float(instance.paid_amount):
                        outstanding.delete()
                        if float(instance.purchase_amount) > float(instance.paid_amount): # payables
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                pesticide_purchase=instance,
                                balance=instance.purchase_amount,
                                paid=instance.paid_amount,
                                to_pay= float(instance.purchase_amount) - float(instance.paid_amount),
                                paid_date = instance.date_of_consumption,
                                total_paid=instance.paid_amount,
                                identify=5,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_pay) > 0:
                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_pay):
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_pay)
                                    else:
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(new_outstanding.to_pay) - float(vendor.opening_balance)
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                vendor.save()
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.payables = vendor.payables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()
                        else:
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                pesticide_purchase=instance,
                                balance= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid=instance.paid_amount,
                                to_receive= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid_date = instance.date_of_consumption,
                                received_date = instance.date_of_consumption,
                                total_paid=instance.paid_amount,
                                identify=5,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_receive) > 0:
                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_receive):
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_receive)
                                    else:
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(new_outstanding.to_receive) - float(vendor.opening_balance)
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                vendor.save()
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.receivables = vendor.receivables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()

                    else:
                        outstanding.to_pay = 0
                        outstanding.to_receive = 0
                        outstanding.status = 2
                        outstanding.save()

                elif outstanding and instance.status == 2:
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)
                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            if float(vendor.opening_balance) > float(outstanding.to_receive):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_receive)
                                vendor.credit = True
                                vendor.debit = False
                            else:
                                vendor.opening_balance = float(outstanding.to_receive) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            vendor.credit = False
                            vendor.debit = True
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_receive)
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)
                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            vendor.credit = True
                            vendor.debit = False
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_pay)
                            
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            if float(vendor.opening_balance) > float(outstanding.to_pay):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_pay)
                                vendor.credit = False
                                vendor.debit = True
                            else:
                                vendor.opening_balance = float(outstanding.to_pay) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()

                    outstanding.status = 2
                    outstanding.save()
                    all_outstanding = Outstanding.objects.filter(pesticide_purchase=instance)
                    for ao in all_outstanding:
                        ao.status = 2
                        ao.save()

        except MyInventory.DoesNotExist:
            pass

@receiver(post_save, sender=MyFertilizers)
def create_fertilizers_inventory(sender, instance, created, **kwargs):
    if created:
        inventory = MyInventory.objects.create(
            date_of_consumption = instance.date_of_consumption,
            # crop = crop,
            inventory_type = instance.inventory_type,
            inventory_category = instance.inventory_category,
            inventory_items = instance.inventory_items,
            quantity_utilized = 0,
            # description = description,
            available_quans = instance.available_quans,
            created_at = timezone.now(),
            farmer=instance.farmer,
            created_by=instance.created_by,
            fertilizer_purchase=instance,
            status = instance.status,
        )
        translated_json = {
            "description": {}
        }
        try:
            languages = Languages.objects.filter(status=0).exclude(id=1)
            target_language = [lang.language_code for lang in languages]
            for lang in target_language:
                if instance.description:
                    translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
                    translated_json["description"][lang] = translated_text
        except Exception as e:
            print(e)
            print("Error in translating Purchase")
        instance.translate_json = translated_json
        instance.save()
    else:
        try:
            inventory = MyInventory.objects.get(
                Q(fertilizer_purchase=instance) & Q(crop__isnull=True) & Q(quantity_utilized=0)
            )
            # print('found the record',inventory.date_of_consumption, inventory.available_quans, instance.available_quans)
            inventory.date_of_consumption = instance.date_of_consumption
            inventory.inventory_type = instance.inventory_type
            inventory.inventory_category = instance.inventory_category
            inventory.inventory_items = instance.inventory_items
            inventory.available_quans = instance.available_quans
            inventory.save()

            if instance.status != 1:
                try:
                    outstanding = Outstanding.objects.filter(fertilizer_purchase=instance).first()
                except Exception as e:
                    outstanding = None
                
                if outstanding and instance.status != 2:
                    # reset old value
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)

                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True

                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)
                        
                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                         
                    # create new record
                    if float(instance.purchase_amount) != float(instance.paid_amount):
                        outstanding.delete()
                        if float(instance.purchase_amount) > float(instance.paid_amount): # payables
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                fertilizer_purchase=instance,
                                balance=instance.purchase_amount,
                                paid=instance.paid_amount,
                                to_pay= float(instance.purchase_amount) - float(instance.paid_amount),
                                paid_date = instance.date_of_consumption,
                                total_paid=instance.paid_amount,
                                identify=6,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_pay) > 0:
                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_pay):
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_pay)
                                    else:
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(new_outstanding.to_pay) - float(vendor.opening_balance)
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                vendor.save()
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.payables = vendor.payables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()
                        else:
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                fertilizer_purchase=instance,
                                balance= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid=instance.paid_amount,
                                to_receive= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid_date = instance.date_of_consumption,
                                received_date = instance.date_of_consumption,
                                total_paid=instance.paid_amount,
                                identify=6,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_receive) > 0:
                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_receive):
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_receive)
                                    else:
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(new_outstanding.to_receive) - float(vendor.opening_balance)
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                vendor.save()
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.receivables = vendor.receivables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()

                    else:
                        outstanding.to_pay = 0
                        outstanding.to_receive = 0
                        outstanding.status = 2
                        outstanding.save()

                elif outstanding and instance.status == 2:
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)
                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            if float(vendor.opening_balance) > float(outstanding.to_receive):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_receive)
                                vendor.credit = True
                                vendor.debit = False
                            else:
                                vendor.opening_balance = float(outstanding.to_receive) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            vendor.credit = False
                            vendor.debit = True
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_receive)
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)
                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            vendor.credit = True
                            vendor.debit = False
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_pay)
                            
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            if float(vendor.opening_balance) > float(outstanding.to_pay):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_pay)
                                vendor.credit = False
                                vendor.debit = True
                            else:
                                vendor.opening_balance = float(outstanding.to_pay) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()

                    outstanding.status = 2
                    outstanding.save()
                    all_outstanding = Outstanding.objects.filter(fertilizer_purchase=instance)
                    for ao in all_outstanding:
                        ao.status = 2
                        ao.save()

        except MyInventory.DoesNotExist:
            pass

@receiver(post_save, sender=MySeeds)
def create_seeds_inventory(sender, instance, created, **kwargs):
    if created:
        inventory = MyInventory.objects.create(
            date_of_consumption = instance.date_of_consumption,
            # crop = crop,
            inventory_type = instance.inventory_type,
            inventory_category = instance.inventory_category,
            inventory_items = instance.inventory_items,
            quantity_utilized = 0,
            available_quans = instance.available_quans,
            created_at = timezone.now(),
            farmer=instance.farmer,
            created_by=instance.created_by,
            seeds_purchase=instance,
            status = instance.status,
        )
        translated_json = {
            "description": {}
        }
        try:
            languages = Languages.objects.filter(status=0).exclude(id=1)
            target_language = [lang.language_code for lang in languages]
            for lang in target_language:
                if instance.description:
                    translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
                    translated_json["description"][lang] = translated_text
        except Exception as e:
            print(e)
            print("Error in translating Purchase")
        instance.translate_json = translated_json
        instance.save()
    else:
        try:
            inventory = MyInventory.objects.get(
                Q(seeds_purchase=instance) & Q(crop__isnull=True) & Q(quantity_utilized=0)
            )
            # print('found the record',inventory.date_of_consumption, inventory.available_quans, instance.available_quans)
            inventory.date_of_consumption = instance.date_of_consumption
            inventory.inventory_type = instance.inventory_type
            inventory.inventory_category = instance.inventory_category
            inventory.inventory_items = instance.inventory_items
            inventory.available_quans = instance.available_quans
            inventory.save()

            if instance.status != 1:
                try:
                    outstanding = Outstanding.objects.filter(seeds_purchase=instance).first()
                except Exception as e:
                    outstanding = None
                
                if outstanding and instance.status != 2:
                    # reset old value
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)

                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True

                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)
                        
                        if float(vendor.receivables) >= float(vendor.payables):
                            vendor.opening_balance = float(vendor.receivables) - float(vendor.payables)
                            vendor.credit = True
                            vendor.debit = False
                        elif float(vendor.receivables) < float(vendor.payables):
                            vendor.opening_balance = float(vendor.payables) - float(vendor.receivables)
                            vendor.credit = False
                            vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    # create new record
                    if float(instance.purchase_amount) != float(instance.paid_amount):
                        outstanding.delete()
                        if float(instance.purchase_amount) > float(instance.paid_amount): # payables
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                seeds_purchase=instance,
                                balance=instance.purchase_amount,
                                paid=instance.paid_amount,
                                to_pay= float(instance.purchase_amount) - float(instance.paid_amount),
                                paid_date = instance.date_of_consumption,
                                total_paid=instance.paid_amount,
                                identify=7,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_pay) > 0:
                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_pay):
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_pay)
                                    else:
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(new_outstanding.to_pay) - float(vendor.opening_balance)
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_pay)
                                    vendor.credit = False
                                    vendor.debit = True
                                vendor.save()
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.payables = vendor.payables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()
                        else:
                            new_outstanding = Outstanding.objects.create(
                                farmer=instance.farmer,
                                vendor=instance.vendor,
                                seeds_purchase=instance,
                                balance= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid=instance.paid_amount,
                                to_receive= float(instance.paid_amount) - float(instance.purchase_amount),
                                paid_date = instance.date_of_consumption,
                                received_date = instance.date_of_consumption,
                                total_paid=instance.paid_amount,
                                identify=7,
                                created_by=instance.created_by,
                                created_at=timezone.now()
                            )
                            if float(new_outstanding.to_receive) > 0:
                                if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                                    vendor.opening_balance = float(vendor.opening_balance) + float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                                    if float(vendor.opening_balance) > float(new_outstanding.to_receive):
                                        vendor.credit = False
                                        vendor.debit = True
                                        vendor.opening_balance = float(vendor.opening_balance) - float(new_outstanding.to_receive)
                                    else:
                                        vendor.credit = True
                                        vendor.debit = False
                                        vendor.opening_balance = float(new_outstanding.to_receive) - float(vendor.opening_balance)
                                else:
                                    vendor.opening_balance = float(new_outstanding.to_receive)
                                    vendor.credit = True
                                    vendor.debit = False
                                vendor.save()
                                if vendor.is_customer_is_vendor:
                                    customer = vendor.customer
                                    customer.opening_balance = vendor.opening_balance
                                    customer.receivables = vendor.receivables
                                    if vendor.credit:
                                        customer.is_credit = True
                                    else:
                                        customer.is_credit = False
                                    customer.save()

                    else:
                        outstanding.to_pay = 0
                        outstanding.to_receive = 0
                        outstanding.status = 2
                        outstanding.save()

                elif outstanding and instance.status == 2:
                    vendor = get_object_or_404(MyVendor, pk=outstanding.vendor.id)
                    if outstanding.to_receive:
                        vendor.receivables = float(vendor.receivables) - float(outstanding.to_receive)
                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            if float(vendor.opening_balance) > float(outstanding.to_receive):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_receive)
                                vendor.credit = True
                                vendor.debit = False
                            else:
                                vendor.opening_balance = float(outstanding.to_receive) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            vendor.credit = False
                            vendor.debit = True
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_receive)
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.receivables = vendor.receivables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()
                    
                    elif outstanding.to_pay:
                        vendor.payables = float(vendor.payables) - float(outstanding.to_pay)
                        if vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit:
                            vendor.credit = True
                            vendor.debit = False
                            vendor.opening_balance = float(vendor.opening_balance) + float(outstanding.to_pay)
                            
                        elif vendor.opening_balance and vendor.opening_balance != 0 and vendor.credit == False and vendor.debit:
                            if float(vendor.opening_balance) > float(outstanding.to_pay):
                                vendor.opening_balance = float(vendor.opening_balance) - float(outstanding.to_pay)
                                vendor.credit = False
                                vendor.debit = True
                            else:
                                vendor.opening_balance = float(outstanding.to_pay) - float(vendor.opening_balance)
                                vendor.credit = False
                                vendor.debit = True
                        
                        vendor.save()
                        if vendor.is_customer_is_vendor:
                            customer = vendor.customer
                            customer.opening_balance = vendor.opening_balance
                            customer.payables = vendor.payables
                            if vendor.credit:
                                customer.is_credit = True
                            else:
                                customer.is_credit = False
                            customer.save()

                    outstanding.status = 2
                    outstanding.save()
                    all_outstanding = Outstanding.objects.filter(seeds_purchase=instance)
                    for ao in all_outstanding:
                        ao.status = 2
                        ao.save()

        except MyInventory.DoesNotExist:
            pass



# # ------------------------------- Translate ---------------------------------

# def translate_farmer(instance):
#     translated_json = {
#         "name": {},
#         "company_name": {},
#         "door_no": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_json["name"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             if instance.company_name:
#                 translated_json["company_name"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.company_name)
#             if instance.door_no:
#                 translated_json["door_no"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.door_no)
#             if instance.description:
#                 translated_json["description"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.description)

#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Farmer")

# @receiver(post_save, sender=Farmer)
# def translate_inputs(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_farmer, args=(instance,))
#         translation_thread.start()


# def translate_package_name(instance):
#     translated_json = {
#         "name": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Package")

# @receiver(post_save, sender=PackageManagement)
# def translate_package(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_package_name, args=(instance,))
#         translation_thread.start()


# def translate_country_name(instance):
#     translated_json = {
#         "name": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Country")

# @receiver(post_save, sender=Country)
# def translate_country(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_country_name, args=(instance,))
#         translation_thread.start()


# def translate_state_name(instance):
#     translated_json = {
#         "name": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating State")

# @receiver(post_save, sender=State)
# def translate_state(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_state_name, args=(instance,))
#         translation_thread.start()


# def trnaslate_city_name(instance):
#     translated_json = {
#         "name": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating City")

# @receiver(post_save, sender=City)
# def translate_city(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=trnaslate_city_name, args=(instance,))
#         translation_thread.start()


# def translate_taluk_name(instance):
#     translated_json = {
#         "name": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Taluk")

# @receiver(post_save, sender=Taluk)
# def translate_taluk(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_taluk_name, args=(instance,))
#         translation_thread.start()


# def translate_village_name(instance):
#     translated_json = {
#         "name": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Village")

# @receiver(post_save, sender=Village)
# def translate_village(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_village_name, args=(instance,))
#         translation_thread.start()


# def translate_market_details(instance):
#     translated_json = {
#         "name": {},
#         "door_no": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#             if instance.door_no:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.door_no)
#                 translated_json["door_no"][lang] = translated_text
#             if instance.description:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#                 translated_json["description"][lang] = translated_text
            
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Market")

# @receiver(post_save, sender=ManageMarket)
# def translate_markets(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_market_details, args=(instance,))
#         translation_thread.start()


# def translate_schedule_details(instance):
#     translated_json = {
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             if instance.description:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#                 translated_json["description"][lang] = translated_text
            
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Schedule")

# @receiver(post_save, sender=Schedule)
# def translate_schedule(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_schedule_details, args=(instance,))
#         translation_thread.start()


# def translate_nearby_details(instance):
#     translated_json = {
#         "name": {},
#         "door_no": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#             if instance.description:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#                 translated_json["description"][lang] = translated_text
#             if instance.door_no:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.door_no)
#                 translated_json["door_no"][lang] = translated_text
            
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Near by Location")

# @receiver(post_save, sender=ManageNearByLocations)
# def translate_nearby(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_nearby_details, args=(instance,))
#         translation_thread.start()


# def translate_product_name(instance):
#     translated_json = {
#         "name": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Product Name")

# @receiver(post_save, sender=ManageProduct)
# def translate_product(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_product_name, args=(instance,))
#         translation_thread.start()


# def translate_location_category(instance):
#     translated_json = {
#         "name": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#             if instance.description:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#                 translated_json["description"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating location category")

# @receiver(post_save, sender=NearByLocationCategory)
# def translate_locationcategory(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_location_category, args=(instance,))
#         translation_thread.start()


# def translate_schedule_activity(instance):
#     translated_json = {
#         "name": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#             if instance.description:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#                 translated_json["description"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in TranslatingSchedule Activity Type")

# @receiver(post_save, sender=ScheduleActivityType)
# def translate_scheduleactivity(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_schedule_activity, args=(instance,))
#         translation_thread.start()


# def translate_land_unit(instance):
#     translated_json = {
#         "name": {},
#         "slug_name": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#             if instance.landunitdef:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.landunitdef)
#                 translated_json["slug_name"][lang] = translated_text
#             if instance.description:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#                 translated_json["description"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating land unit")

# @receiver(post_save, sender=LandUnit)
# def translate_landunit(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_land_unit, args=(instance,))
#         translation_thread.start()



# def translate_areaunit_details(instance):
#     translated_json = {
#         "name": {},
#         "slug_name": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#             if instance.areaunitdef:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.areaunitdef)
#                 translated_json["slug_name"][lang] = translated_text
#             if instance.description:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#                 translated_json["description"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating area unit")

# @receiver(post_save, sender=AreaUnit)
# def translate_areaunit(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_areaunit_details, args=(instance,))
#         translation_thread.start()



# def translate_soil_type(instance):
#     translated_json = {
#         "name": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#             if instance.description:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#                 translated_json["description"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating soil type")

# @receiver(post_save, sender=SoilType)
# def translate_soiltype(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_soil_type, args=(instance,))
#         translation_thread.start()



# def translate_crop_type(instance):
#     translated_json = {
#         "name": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#             if instance.description:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#                 translated_json["description"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Crop Type")

# @receiver(post_save, sender=CropType)
# def translate_croptype(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_crop_type, args=(instance,))
#         translation_thread.start()



# def translate_crop_details(instance):
#     translated_json = {
#         "name": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#             if instance.description:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#                 translated_json["description"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Crop")

# @receiver(post_save, sender=Crop)
# def translate_crop(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_crop_details, args=(instance,))
#         translation_thread.start()


# # -------- Name & description Translate

# def translate_name_description(instance):
#     translated_json = {
#         "name": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#             if instance.description:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#                 translated_json["description"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating data")

# @receiver(post_save, sender=ProductType)
# def translate_producttype(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_name_description, args=(instance,))
#         translation_thread.start()

# @receiver(post_save, sender=InventoryCategory)
# def translate_inventorycategory(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_name_description, args=(instance,))
#         translation_thread.start()
#         # translated_json = {
#         #     "name": {},
#         #     "description": {}
#         # }
#         # for lang in target_language:
#         #     translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#         #     translated_json["name"][lang] = translated_text
#         #     if instance.description:
#         #         translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#         #         translated_json["description"][lang] = translated_text
#         # instance.translate_json = translated_json
#         # instance.save()

# @receiver(post_save, sender=InventoryItems)
# def translate_inventoryitems(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_name_description, args=(instance,))
#         translation_thread.start()
#         # translated_json = {
#         #     "name": {},
#         #     "description": {}
#         # }
#         # for lang in target_language:
#         #     translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#         #     translated_json["name"][lang] = translated_text
#         #     if instance.description:
#         #         translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#         #         translated_json["description"][lang] = translated_text
#         # instance.translate_json = translated_json
#         # instance.save()

# @receiver(post_save, sender=ExpensesCategory)
# def translate_expensecategory(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_name_description, args=(instance,))
#         translation_thread.start()
#         # translated_json = {
#         #     "name": {},
#         #     "description": {}
#         # }
#         # for lang in target_language:
#         #     translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#         #     translated_json["name"][lang] = translated_text
#         #     if instance.description:
#         #         translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#         #         translated_json["description"][lang] = translated_text
#         # instance.translate_json = translated_json
#         # instance.save()

# @receiver(post_save, sender=Expenses)
# def translate_expense(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_name_description, args=(instance,))
#         translation_thread.start()
#         # translated_json = {
#         #     "name": {},
#         #     "description": {}
#         # }
#         # for lang in target_language:
#         #     translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#         #     translated_json["name"][lang] = translated_text
#         #     if instance.description:
#         #         translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#         #         translated_json["description"][lang] = translated_text
#         # instance.translate_json = translated_json
#         # instance.save()

# @receiver(post_save, sender=HarvestingType)
# def translate_harvestingtype(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_name_description, args=(instance,))
#         translation_thread.start()
#         # translated_json = {
#         #     "name": {},
#         #     "description": {}
#         # }
#         # for lang in target_language:
#         #     translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#         #     translated_json["name"][lang] = translated_text
#         #     if instance.description:
#         #         translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#         #         translated_json["description"][lang] = translated_text
#         # instance.translate_json = translated_json
#         # instance.save()

# @receiver(post_save, sender=WorkersType)
# def translate_workertype(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_name_description, args=(instance,))
#         translation_thread.start()
#         # translated_json = {
#         #     "name": {},
#         #     "description": {}
#         # }
#         # for lang in target_language:
#         #     translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#         #     translated_json["name"][lang] = translated_text
#         #     if instance.description:
#         #         translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#         #         translated_json["description"][lang] = translated_text
#         # instance.translate_json = translated_json
#         # instance.save()

# @receiver(post_save, sender=GuidelinesCategory)
# def translate_guidelinescategory(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_name_description, args=(instance,))
#         translation_thread.start()
#         # translated_json = {
#         #     "name": {},
#         #     "description": {}
#         # }
#         # for lang in target_language:
#         #     translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#         #     translated_json["name"][lang] = translated_text
#         #     if instance.description:
#         #         translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#         #         translated_json["description"][lang] = translated_text
#         # instance.translate_json = translated_json
#         # instance.save()

# @receiver(post_save, sender=DocumentCategory)
# def translate_documentcategory(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_name_description, args=(instance,))
#         translation_thread.start()
#         # translated_json = {
#         #     "name": {},
#         #     "description": {}
#         # }
#         # for lang in target_language:
#         #     translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#         #     translated_json["name"][lang] = translated_text
#         #     if instance.description:
#         #         translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#         #         translated_json["description"][lang] = translated_text
#         # instance.translate_json = translated_json
#         # instance.save()

# @receiver(post_save, sender=Guidelines)
# def translate_guidelines(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_name_description, args=(instance,))
#         translation_thread.start()


# # --------- only translate description


def translate_description(instance):
    translated_json = {
        "description": {}
    }
    try:
        languages = Languages.objects.filter(status=0).exclude(id=1)
        target_language = [lang.language_code for lang in languages]
        if instance.description:
            for lang in target_language:
                translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
                translated_json["description"][lang] = translated_text
        instance.translate_json = translated_json
        instance.save()
    except Exception as e:
        print("Error in Translating Data")

# @receiver(post_save, sender=MyCrop)
# def translate_crop(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_description, args=(instance,))
#         translation_thread.start()
#         # translated_json = {
#         #     "description": {}
#         # }
#         # if instance.description:
#         #     for lang in target_language:
#         #         translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#         #         translated_json["description"][lang] = translated_text
#         # instance.translate_json = translated_json
#         # instance.save()

# @receiver(post_save, sender=MyExpense)
# def translate_crop(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_description, args=(instance,))
#         translation_thread.start()
#         # translated_json = {
#         #     "description": {}
#         # }
#         # if instance.description:
#         #     for lang in target_language:
#         #         translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#         #         translated_json["description"][lang] = translated_text
#         # instance.translate_json = translated_json
#         # instance.save()

# @receiver(post_save, sender=MySales)
# def translate_crop(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_description, args=(instance,))
#         translation_thread.start()
#         # translated_json = {
#         #     "description": {}
#         # }
#         # if instance.description:
#         #     for lang in target_language:
#         #         translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#         #         translated_json["description"][lang] = translated_text
#         # instance.translate_json = translated_json
#         # instance.save()

# @receiver(post_save, sender=MyInventory)
# def translate_inventory(instance, created, **kwargs):
#     if created:
#         if instance.description:
#             translation_thread = threading.Thread(target=translate_description, args=(instance,))
#             translation_thread.start()
#         # translated_json = {
#         #     "description": {}
#         # }
#         # if instance.description:
#         #     for lang in target_language:
#         #         translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#         #         translated_json["description"][lang] = translated_text
#         # instance.translate_json = translated_json
#         # instance.save()


# # ------- individual translate ------

# def translate_land_details(instance):
#     translated_json = {
#         "name": {},
#         "door_no": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#             if instance.door_no:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.door_no)
#                 translated_json["door_no"][lang] = translated_text
#             if instance.description:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.description)
#                 translated_json["description"][lang] = translated_text
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Land details")

# @receiver(post_save, sender=MyLand)
# def translate_land(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_land_details, args=(instance,))
#         translation_thread.start()



# @receiver(post_save, sender=FarmerNotification)
# def translate_notification(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_notification_background, args=(instance,))
#         translation_thread.start()

# def translate_notification_background(instance):
#     translated_json = {
#         "name": {},
#         'message': {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             # Using Google Translator to translate
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             translated_json["name"][lang] = translated_text
#             translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.message)
#             translated_json["message"][lang] = translated_text
#     except Exception as e:
#         print(e)
#         print("Error in translating notification")
    
#     # Save the translation to the instance
#     instance.translate_json = translated_json
#     instance.save()



# def translate_vendor_details(instance):
#     translated_json = {
#         "name": {},
#         "business_name": {},
#         "door_no": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_json["name"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             if instance.business_name:
#                 translated_json["business_name"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.business_name)
#             if instance.door_no:
#                 translated_json["door_no"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.door_no)
#             if instance.description:
#                 translated_json["description"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.description)

#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Vendor")

# @receiver(post_save, sender=MyVendor)
# def translate_vendor(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_vendor_details, args=(instance,))
#         translation_thread.start()



# def translate_cutomer_details(instance):
#     translated_json = {
#         "customer_name": {},
#         "shop_name": {},
#         "door_no": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_json["customer_name"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.customer_name)
#             if instance.shop_name:
#                 translated_json["shop_name"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.shop_name)
#             if instance.door_no:
#                 translated_json["door_no"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.door_no)
#             if instance.description:
#                 translated_json["description"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.description)

#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print(e)
#         print("Error in Translating Customer")

# @receiver(post_save, sender=MyCustomer)
# def translate_customer(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_cutomer_details, args=(instance,))
#         translation_thread.start()



# def translate_employee_details(instance):
#     translated_json = {
#         "name": {},
#         "door_no": {},
#         "description": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             translated_json["name"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#             if instance.door_no:
#                 translated_json["door_no"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.door_no)
#             if instance.description:
#                 translated_json["description"][lang] = GoogleTranslator(source='auto', target=lang).translate(instance.description)

#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Employee")

# @receiver(post_save, sender=Employee)
# def translate_employee(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_employee_details, args=(instance,))
#         translation_thread.start()


# @receiver(post_save, sender=Reasons)
# def translate_salesdeduction(instance, created, **kwargs):
#     if created:
#         translated_json = {
#             "name": {}
#         }
#         try:
#             languages = Languages.objects.filter(status=0).exclude(id=1)
#             target_language = [lang.language_code for lang in languages]
#             for lang in target_language:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#                 translated_json["name"][lang] = translated_text
#             instance.translate_json = translated_json
#             instance.save()
#         except Exception as e:
#             print("Error in translation deduction")

# def translate_help_desk(instance):
#     translated_json = {
#         "name": {}
#     }
#     try:
#         languages = Languages.objects.filter(status=0).exclude(id=1)
#         target_language = [lang.language_code for lang in languages]
#         for lang in target_language:
#             if instance.name:
#                 translated_text = GoogleTranslator(source='auto', target=lang).translate(instance.name)
#                 translated_json["name"][lang] = translated_text
            
#         instance.translate_json = translated_json
#         instance.save()
#     except Exception as e:
#         print("Error in Translating Help Desk")

# @receiver(post_save, sender=HelpDesk)
# def translate_helpdesk(instance, created, **kwargs):
#     if created:
#         translation_thread = threading.Thread(target=translate_help_desk, args=(instance,))
#         translation_thread.start()


# ---------------------------------------------------------------- Outstanding -------------------------------------

@receiver(post_save, sender=MySales)
def create_outstanding(instance, created, **kwargs):
    if created:
        if float(instance.total_sales_amount) > float(instance.amount_paid): #receivables
            outstanding = Outstanding.objects.create(
                farmer = instance.farmer,
                customer = instance.my_customer,
                sale = instance,
                balance = instance.total_sales_amount,
                received = instance.amount_paid,
                to_receive = float(instance.total_sales_amount) - float(instance.amount_paid),
                received_date = instance.dates_of_sales,
                total_received = instance.amount_paid,
                created_by = instance.created_by,
                created_at = timezone.now()
            )
            if float(outstanding.to_receive) > 0:
                customer = get_object_or_404(MyCustomer, pk=outstanding.customer.id)
                customer.receivables = float(customer.receivables) + float(outstanding.to_receive)
                if customer.opening_balance and customer.opening_balance != 0 and customer.is_credit:
                    customer.opening_balance = float(customer.opening_balance) + float(outstanding.to_receive)
                    customer.is_credit = True
                elif customer.opening_balance and customer.opening_balance != 0 and customer.is_credit == False:
                    if float(customer.opening_balance) > float(outstanding.to_receive):
                        customer.is_credit = False
                        customer.opening_balance = float(customer.opening_balance) - float(outstanding.to_receive)
                    else:
                        customer.is_credit = True
                        customer.opening_balance = float(outstanding.to_receive) - float(customer.opening_balance)
                else:
                    customer.opening_balance = float(outstanding.to_receive)
                    customer.is_credit = True
                customer.save()
                if customer.is_customer_is_vendor:
                    vendor = customer.vendor
                    vendor.opening_balance = customer.opening_balance
                    vendor.receivables = customer.receivables
                    if customer.is_credit:
                        vendor.credit = True
                        vendor.debit = False
                    else:
                        vendor.credit = False
                        vendor.debit = True
                    vendor.save()

        elif float(instance.total_sales_amount) < float(instance.amount_paid): # payables
            outstanding = Outstanding.objects.create(
                farmer = instance.farmer,
                customer = instance.my_customer,
                sale = instance,
                balance = float(instance.amount_paid) - float(instance.total_sales_amount),
                received = instance.amount_paid,
                to_pay = float(instance.amount_paid) - float(instance.total_sales_amount),
                paid_date = instance.dates_of_sales,
                received_date = instance.dates_of_sales,
                created_by = instance.created_by,
                created_at = timezone.now()
            )
            if float(outstanding.to_pay) > 0:
                customer = get_object_or_404(MyCustomer, pk=outstanding.customer.id)
                customer.payables = float(customer.payables) + float(outstanding.to_pay)
                if customer.opening_balance and customer.opening_balance != 0 and customer.is_credit:
                    if float(customer.opening_balance) > float(outstanding.to_pay):
                        customer.is_credit = True
                        customer.opening_balance = float(customer.opening_balance) - float(outstanding.to_pay)
                    else:
                        customer.is_credit = False
                        customer.opening_balance = float(outstanding.to_pay) - float(customer.opening_balance)

                elif customer.opening_balance and customer.opening_balance != 0 and customer.is_credit == False:
                    customer.opening_balance = float(customer.opening_balance) + float(outstanding.to_pay)
                    customer.is_credit = False
                else:
                    customer.opening_balance = float(outstanding.to_pay)
                    customer.is_credit = False
                customer.save()
                if customer.is_customer_is_vendor:
                    vendor = customer.vendor
                    vendor.opening_balance = customer.opening_balance
                    vendor.payables = customer.payables
                    if customer.is_credit:
                        vendor.credit = True
                        vendor.debit = False
                    else:
                        vendor.credit = False
                        vendor.debit = True
                    vendor.save()

    else:
        try:
            try:
                outstanding = Outstanding.objects.filter(sale = instance).order_by('-id').first()
            except Exception as e:
                outstanding = None
            
            if outstanding and instance.status == 2:
                customer = get_object_or_404(MyCustomer, pk=outstanding.customer.id)
                if outstanding.to_receive:
                    customer.receivables = float(customer.receivables) - float(outstanding.to_receive)
                    if customer.opening_balance and customer.opening_balance != 0 and customer.is_credit:
                        if float(customer.opening_balance) > float(outstanding.to_receive):
                            customer.opening_balance = float(customer.opening_balance) - float(outstanding.to_receive)
                            customer.is_credit = True
                        else:
                            customer.opening_balance = float(outstanding.to_receive) - float(customer.opening_balance)
                            customer.is_credit = False
                    
                    elif customer.opening_balance and customer.opening_balance != 0 and customer.is_credit == False:
                        customer.is_credit = False
                        customer.opening_balance = float(customer.opening_balance) + float(outstanding.to_receive)
                    
                    customer.save()
                    if customer.is_customer_is_vendor:
                        vendor = customer.vendor
                        vendor.opening_balance = customer.opening_balance
                        vendor.receivables = customer.receivables
                        if customer.is_credit:
                            vendor.credit = True
                            vendor.debit = False
                        else:
                            vendor.credit = False
                            vendor.debit = True
                        vendor.save()
                
                elif outstanding.to_pay:
                    customer.payables = float(customer.payables) - float(outstanding.to_pay)
                    if customer.opening_balance and customer.opening_balance != 0 and customer.is_credit:
                        customer.is_credit = True
                        customer.opening_balance = float(customer.opening_balance) + float(outstanding.to_pay)
                        
                    elif customer.opening_balance and customer.opening_balance != 0 and customer.is_credit == False:
                        if float(customer.opening_balance) > float(outstanding.to_pay):
                            customer.opening_balance = float(customer.opening_balance) - float(outstanding.to_pay)
                            customer.is_credit = False
                        else:
                            customer.opening_balance = float(outstanding.to_pay) - float(customer.opening_balance)
                            customer.is_credit = True
                    
                    customer.save()
                    if customer.is_customer_is_vendor:
                        vendor = customer.vendor
                        vendor.opening_balance = customer.opening_balance
                        vendor.payables = customer.payables
                        if customer.is_credit:
                            vendor.credit = True
                            vendor.debit = False
                        else:
                            vendor.credit = False
                            vendor.debit = True
                        vendor.save()

                outstanding.status = 2
                outstanding.save()
                all_outstanding = Outstanding.objects.filter(customer=customer, sale=instance)
                for ao in all_outstanding:
                    ao.status = 2
                    ao.save()
        except Exception as e:
            print("Error in sales edit outstanding calculation")
            pass



# @receiver(post_save, sender=MyVendor)
# def outstanding_vendor(instance, created, **kwargs):
#     if not created:
#         if instance.opening_balance == 0 and (instance.receivables > 0  or instance.payables > 0 ):
#             instance.receivables = 0
#             instance.payables = 0
#             instance.save()

#             if instance.is_customer_is_vendor:
#                 customer = get_object_or_404(MyCustomer, pk=instance.customer.id)
#                 customer.receivables = 0
#                 customer.payables = 0
#                 customer.save()
#                 coust = Outstanding.objects.filter(customer=customer, status__in=[0,1])
#                 for ost in coust:
#                     ost.to_receive = 0
#                     ost.to_pay = 0
#                     ost.status = 2
#                     ost.save()

#             outst = Outstanding.objects.filter(vendor=instance, status__in=[0,1])
#             for ost in outst:
#                 ost.status = 2
#                 ost.to_receive = 0
#                 ost.to_pay = 0
#                 ost.save()

# @receiver(post_save, sender=MyCustomer)
# def outstanding_vendor(instance, created, **kwargs):
#     if not created:
#         if instance.opening_balance == 0 and (instance.receivables > 0  or instance.payables > 0 ):
#             instance.receivables = 0
#             instance.payables = 0
#             instance.save()

#             if instance.is_customer_is_vendor:
#                 vendor = get_object_or_404(MyVendor, pk=instance.vendor.id)
#                 vendor.receivables = 0
#                 vendor.payables = 0
#                 vendor.save()
#                 coust = Outstanding.objects.filter(vendor=vendor, status__in=[0,1])
#                 for ost in coust:
#                     ost.to_receive = 0
#                     ost.to_pay = 0
#                     ost.status = 2
#                     ost.save()

#             outst = Outstanding.objects.filter(customer=instance, status__in=[0,1])
#             for ost in outst:
#                 ost.status = 2
#                 ost.to_receive = 0
#                 ost.to_pay = 0
#                 ost.save()
