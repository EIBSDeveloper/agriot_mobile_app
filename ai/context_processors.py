from .models import ManageUser, Notification
from .models import GeneralSetting
from auth.models import *
from dashboards.models import *
from ai.models import *
from django.core.exceptions import ObjectDoesNotExist
 
def split(value, arg):
    """Split a string by a given delimiter"""
    return value.split(arg) if value else []

def manageuser(request):
    if request.user.is_authenticated:
        try:
            manageuser = ManageUser.objects.get(custom_user_id=request.user.id)
            return {'manageuser': manageuser}
        except ManageUser.DoesNotExist:
            return {'manageuser': None}
    return {'manageuser': None}

def has_view_permission(request):
    has_permission = False
    if request.user.is_authenticated:
        try:
            manage_user = ManageUser.objects.get(custom_user_id=request.user.id)
            if manage_user.can_view_farmer:
                has_permission = True
        except ManageUser.DoesNotExist:
            pass
    return {'has_view_permission': has_permission}

def notifications(request):
    if request.user.is_authenticated:
        latest_notifications = Notification.objects.filter(user=request.user.id).order_by('-created_at') 
        unread_count =  Notification.objects.filter(user=request.user.id, is_read=False).order_by('-created_at').count()
        
        context = {
            'notifications': latest_notifications,
            'unread_count':unread_count
        }
        return context
    return {'notifications': []}

def global_settings(request):
    try:
        settings = GeneralSetting.objects.first()
        date_format = settings.date_format if settings else 'd-M-Y'
        title = settings.title
        if settings.logo:
            logo = '/assets'+settings.logo.url
        else:
            logo = '/assets/images/agri_logo_5.png'
        if settings.favicon:
            favicon = '/assets'+settings.favicon.url
        else:
            favicon = '/assets/images/agriot_favicon_1.png'
    except GeneralSetting.DoesNotExist:
        date_format = 'd-M-Y'  # Default date format
        logo = '/assets/images/agri_logo_5.png'
        title = 'Agriot'
        favicon = '/assets/images/agriot_favicon_1.png'
    except Exception as e:
        date_format = 'd-m-Y'  # Default date format
        logo = '/assets/images/agri_logo_5.png'
        title = 'Agriot'
        favicon = '/assets/images/agriot_favicon_1.png'

    return {
        'GLOBAL_DATE_FORMAT': date_format,
        'logo' : logo,
        'icon' : favicon,
        'title' : title,
    }

def user_profile(request):
    if request.user.is_authenticated:
        user_id = request.user.id
        user = CustomUser.objects.get(id=user_id)
        context = {
            'user': user
            }
        return context
    else:
        context = {
            'user': ''
            }
        return context

def farmer_notifications(request):
    if request.user.is_authenticated:
        user = get_object_or_404(CustomUser, id=request.user.id)
         
        try:
            if user.farmer_user:
                try:
                    farmer = get_object_or_404(Farmer, farmer_user=user)
                except Exception as e:
                    farmer = get_object_or_404(Farmer, sub_admin_user=user) 
            else:
                employee = get_object_or_404(Employee, employee_user=user)
                farmer = employee.farmer
            
            latest_notifications = FarmerNotification.objects.filter(farmer=farmer).order_by('-created_at')
            unread_count =  FarmerNotification.objects.filter(farmer=farmer, is_read=False).order_by('-created_at').count()
            context = {
                'farmer_notifications': latest_notifications,
                'farmer_unread_count':unread_count
            }
        except Exception as e:
            context = {
                'farmer_notifications': '',
                'farmer_unread_count': ''
            }
        return context
    return {'farmer_notifications': [],'farmer_unread_count':''}

# def farmer_profile(request):
#     if request.user.is_authenticated:
#         try:
#             farmer_user_id = request.user.id
#             farmeruser = CustomUser.objects.get(id=farmer_user_id)
#             employee = None
#             if farmeruser.farmer_user:
#                 try:
#                     farmer = get_object_or_404(Farmer, farmer_user=farmeruser)
#                 except ObjectDoesNotExist:
#                     farmer = get_object_or_404(Farmer, sub_admin_user=farmeruser)
#             else:
#                 employee = get_object_or_404(Employee, employee_user=farmeruser)
#                 farmer = employee.farmer


#             # Define all the possible fields for widget_config
#             field_names = [
#                 'total_land', 'total_crops', 'total_schedule', 'total_customer', 'near_me_datas', 
#                 'guidelines', 'expenses', 'sales', 'employee_advanvce', 'regular_payouts', 
#                 'min_max_stock', 'monthly_expense_sales', 'monthly_advance_payouts', 
#                 'total_product_purchase', 'expense_sale_product_purchase_graph', 
#                 'weekly_employee_advance_payouts_graph', 'monthly_based_expense_sales', 'my_schedule'
#             ]
            
#             # Count how many checkboxes are selected across all widget_config entries
#             selected_count = 0
#             total_fields = len(field_names)  # Total fields
#             all_selected = True  # Flag to track if all checkboxes are selected

#             context = {
#                 'farmeruser': farmeruser,
#                 'farmer': farmer,
#                 'selected_count': selected_count,
#                 'total_fields': total_fields,
#                 'all_selected': all_selected,  # True if all selected, False otherwise
#                 'employee_logedin': employee,
#             }
#             widget_config, created = WidgetConfig.objects.get_or_create(farmer=farmer)
#             context['widget_config'] = widget_config

#             if widget_config.total_land and widget_config.total_crops and widget_config.total_schedule and widget_config.total_customer and widget_config.near_me_datas and widget_config.guidelines and widget_config.expenses and widget_config.sales and widget_config.employee_advanvce and widget_config.regular_payouts and widget_config.min_max_stock and widget_config.monthly_expense_sales and widget_config.monthly_advance_payouts and widget_config.total_product_purchase and widget_config.expense_sale_product_purchase_graph and widget_config.weekly_employee_advance_payouts_graph and  widget_config.monthly_based_expense_sales and widget_config.my_schedule:
#                 context['all_widget'] = '0'
#             else :
#                 context['all_widget'] = '1'

#             return context
        
#         except Exception as e:
#             context = {
#                 'farmeruser': None,
#                 'farmer': None,
#                 'widget_config': None,
#                 'all_widget': '1',
#                 'profile': None,
#                 'employee_logedin': None,
#             }
#             return context
        
#     else:
#         return {
#             'farmeruser': None,
#             'farmer': None,
#             'widget_config': None,
#             'all_widget': '1',
#             'profile': None,
#             'employee_logedin': None,
#         }

def farmer_profile(request):
    if request.user.is_authenticated:
        try:
            farmer_user_id = request.user.id
            farmeruser = CustomUser.objects.get(id=farmer_user_id)
            employee = None
            if farmeruser.farmer_user:
                try:
                    farmer = get_object_or_404(Farmer, farmer_user=farmeruser)
                except ObjectDoesNotExist:
                    farmer = get_object_or_404(Farmer, sub_admin_user=farmeruser)
            else:
                employee = get_object_or_404(Employee, employee_user=farmeruser)
                farmer = employee.farmer


            # Define all the possible fields for widget_config
            field_names = [
                'total_land', 'total_crops', 'total_schedule', 'total_customer', 'near_me_datas', 
                'guidelines', 'expenses', 'sales', 'employee_advanvce', 'regular_payouts', 
                'min_max_stock', 'monthly_expense_sales', 'monthly_advance_payouts', 
                'total_product_purchase', 'expense_sale_product_purchase_graph', 
                'weekly_employee_advance_payouts_graph', 'monthly_based_expense_sales', 'my_schedule'
            ]
            
            # Count how many checkboxes are selected across all widget_config entries
            selected_count = 0
            total_fields = len(field_names)  # Total fields
            all_selected = True  # Flag to track if all checkboxes are selected
            con = Country.objects.filter(status=0)
            con = Country.objects.filter(status=0)
            sta = State.objects.filter(status=0)
            dis = City.objects.filter(status=0)
            tal = Taluk.objects.filter(status=0)
            vil = Village.objects.filter(status=0)
            context = {
                'profile_contry' : con,
                'profile_state' : sta,
                'profile_district' : dis,
                'profile_taluk' : tal,
                'profile_village' : vil,
                'farmeruser': farmeruser,
                'farmer': farmer,
                'selected_count': selected_count,
                'total_fields': total_fields,
                'all_selected': all_selected,  # True if all selected, False otherwise
                'employee_logedin': employee,
            }
            widget_config, created = WidgetConfig.objects.get_or_create(farmer=farmer)
            context['widget_config'] = widget_config

            if widget_config.total_land and widget_config.total_crops and widget_config.total_schedule and widget_config.total_customer and widget_config.near_me_datas and widget_config.guidelines and widget_config.expenses and widget_config.sales and widget_config.employee_advanvce and widget_config.regular_payouts and widget_config.min_max_stock and widget_config.monthly_expense_sales and widget_config.monthly_advance_payouts and widget_config.total_product_purchase and widget_config.expense_sale_product_purchase_graph and widget_config.weekly_employee_advance_payouts_graph and  widget_config.monthly_based_expense_sales and widget_config.my_schedule:
                context['all_widget'] = '0'
            else :
                context['all_widget'] = '1'

            return context
        
        except Exception as e:
            context = {
                'farmeruser': None,
                'farmer': None,
                'widget_config': None,
                'all_widget': '1',
                'profile': None,
                'employee_logedin': None,
            }
            return context
        
    else:
        return {
            'farmeruser': None,
            'farmer': None,
            'widget_config': None,
            'all_widget': '1',
            'profile': None,
            'employee_logedin': None,
        }
