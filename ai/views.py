from django.db.models import Max
from _keenthemes.libs.theme import KTTheme
from pprint import pprint 
import openpyxl 
import pandas as pd
from django.db import IntegrityError
import os
from datetime import date, datetime
from django.utils import timezone
from django.utils import timezone
from django.utils.timezone import localtime 
from django.contrib.auth.decorators import login_required
from datetime import timedelta
import json
from django.core.exceptions import ObjectDoesNotExist
import logging
from django.utils.decorators import method_decorator
import csv
import re
from django.utils.dateparse import parse_date
from django.contrib.auth.hashers import make_password
from django.core.exceptions import ObjectDoesNotExist
from collections import defaultdict
logger = logging.getLogger(__name__)
from django.contrib.auth.mixins import PermissionRequiredMixin
# from .base_permission_view import BasePermissionView
from django.views.generic import TemplateView
from django.http import Http404, HttpResponse, HttpResponseBadRequest, HttpResponseForbidden
from django.conf import settings
from django.urls import resolve
from _keenthemes.__init__ import KTLayout 
from _keenthemes.libs.theme import KTTheme
from django.shortcuts import render, redirect, get_object_or_404
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger 
from django.utils import timezone
from.models import *
from django.views import View
from django.contrib import messages 
from django.http import JsonResponse
from django.urls import reverse
from django.db.models import Max, Q
from django.db.models import OuterRef, Subquery
from django.db.models import Count
from django.template.loader import render_to_string 
from django.core.serializers import serialize
from django.db.models.functions import TruncMonth
import calendar
from django.contrib.auth import logout
from django.contrib.auth.mixins import LoginRequiredMixin
from auth.models import *
from django.http import HttpResponse
import sqlite3 
from django.core.exceptions import PermissionDenied
from django.contrib.auth.decorators import user_passes_test
from django.http import HttpResponseForbidden
from functools import wraps
import subprocess
import pytz  
from pytz import timezone as pytz_timezone
from dashboards.models import *
import io
from PIL import Image
from django.core.files.uploadedfile import InMemoryUploadedFile
from deep_translator import GoogleTranslator
from django.core.mail import send_mail
import requests 
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.views.decorators.csrf import csrf_exempt
import logging
from django.http import Http404
import os
import pandas as pd
from docx2pdf import convert as docx2pdf_convert
from django.core.files.base import ContentFile
from io import BytesIO
logger = logging.getLogger('ai')


# target_language = ['ta', 'hi']
# languages = Languages.objects.filter(status=0).exclude(id=1)
# target_language = [lang.language_code for lang in languages]
def get_target_languages():
    languages = Languages.objects.filter(status=0)
    return [lang.language_code for lang in languages]

def convert_uploaded_file(file, media_type):
    """
    Converts uploaded file if needed:
    - CSV → XLSX
    - DOCX → PDF
    Returns a Django ContentFile for saving to model.
    """
    filename = file.name
    ext = filename.split('.')[-1].lower()

    if ext == 'csv':
        # Convert CSV to XLSX
        df = pd.read_csv(file)
        output = BytesIO()
        df.to_excel(output, index=False, engine='openpyxl')
        new_filename = filename.rsplit('.', 1)[0] + '.xlsx'
        return ContentFile(output.getvalue(), new_filename)

    elif ext in ['docx', 'doc']: 
        # Convert Word to PDF
        # Save uploaded file temporarily
        temp_docx = f'/tmp/{filename}'
        with open(temp_docx, 'wb') as f:
            f.write(file.read())

        pdf_filename = filename.rsplit('.', 1)[0] + '.pdf'
        temp_pdf = f'/tmp/{pdf_filename}'

        docx2pdf_convert(temp_docx, temp_pdf)

        with open(temp_pdf, 'rb') as f:
            pdf_file = ContentFile(f.read(), pdf_filename)

        # Clean up temp files
        os.remove(temp_docx)
        os.remove(temp_pdf)

        return pdf_file

    else:
        # No conversion needed
        return file

def mark_all_as_read(request):
    if request.user.is_authenticated:
        Notification.objects.filter(is_read=False).update(is_read=True)
        return JsonResponse({'success': True})
    return JsonResponse({'success': False}, status=403)

class CustomLogoutView(View):
    def get(self, request):
        logout(request)
        return redirect('sa_login')  

def backup_db(request):
    db_name = settings.DATABASES['default']['NAME']
    db_user = settings.DATABASES['default']['USER']
    db_password = settings.DATABASES['default']['PASSWORD']
    db_host = settings.DATABASES['default']['HOST']
    db_port = settings.DATABASES['default']['PORT']
    backup_file = 'backup30(1).sql'  

    os.environ['PGPASSWORD'] = db_password

    try:
     
        pg_dump_path = r"C:\Program Files\PostgreSQL\17\bin\pg_dump.exe"  

        command = [
            pg_dump_path,
            '-h', db_host,
            '-p', str(db_port),
            '-U', db_user,
            '-F', 'p',  
            '-f', backup_file,
            db_name
        ]

        subprocess.run(command, check=True)

        return HttpResponse(f'Successfully backed up PostgreSQL database to {backup_file}')

    except subprocess.CalledProcessError as e:
        return HttpResponse(f'Error backing up database: {str(e)}')
    except Exception as e:
        return HttpResponse(f'Unexpected error: {str(e)}')

# def trigger_subscription():
#      # Get the current date (without time part)
#     today = timezone.now().date()

#     # Fetch subscriptions that were last updated today
#     sub = AddSubcription.objects.all()

#     for subscription in sub:
#         # Check if the subscription was last updated today
#         if subscription.updated_at.date() != today:
#             # Calculate remaining days if the subscription was not updated today
#             if subscription.remainingdays != 0:
#                 # remaining = (subscription.enddate - timezone.now().date()).days
#                 remaining = (subscription.enddate - today).days
#                 subscription.remainingdays = max(remaining, 0)
                
#                 if subscription.startdate == today:
#                     subscription.status = 0

#                 if subscription.remainingdays == 0:
#                     subscription.status = 4
#                     # print("Remaining days 0 for user:", subscription.farmers, "with subscription:", subscription.packages)

#                 # Save the updated subscription
#                 subscription.save()

def trigger_subscription():
    today = timezone.now().date()
    sub = AddSubcription.objects.all()

    for subscription in sub:
        # Skip subscriptions missing enddate
        if not subscription.enddate:
            continue

        if subscription.updated_at.date() != today:
            if subscription.remainingdays != 0:
                # Calculate remaining days only if enddate is present
                remaining = (subscription.enddate - today).days
                subscription.remainingdays = max(remaining, 0)

                # Check startdate is not None and equals today
                if subscription.startdate and subscription.startdate == today:
                    subscription.status = 0

                if subscription.remainingdays == 0:
                    subscription.status = 4
                    # Optional: log or print
                    # print("Remaining days 0 for user:", subscription.farmers, "with subscription:", subscription.packages)

                subscription.save()



def convert_png_to_jpeg(image_file):
    # Open the PNG image using Pillow
    img = Image.open(image_file)
    
    # Convert to RGB (JPEG doesn't support transparency like PNG does)
    img = img.convert("RGB")

    # Create a BytesIO object to hold the new JPEG image
    img_io = io.BytesIO()

    # Save the image as JPEG into the BytesIO object
    img.save(img_io, 'JPEG', quality=95)

    # Get the byte data
    img_io.seek(0)
    
    return img_io

def mark_notification_as_read(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            notification_id = data.get('notificationId')

            if not notification_id:
                return JsonResponse({'error': 'Notification ID is required'}, status=400)
            
            Notification.objects.filter(pk=notification_id).update(is_read=True)
           
            return JsonResponse({'message': 'Notification marked as read'}, status=200)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)


#---------------------------------------------------------------------- Dashboard ------------------------------------------------------  

class SuperAdminDashboardsView(LoginRequiredMixin, TemplateView):
    template_name = 'pages/super_admin/dashboards/dashboards.html'

    def dispatch(self, request, *args, **kwargs): 
        if not request.user.is_superuser:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=request.user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                # return redirect('user_not_allowed')

            # if manage_user and not manage_user.can_dashboard_count:
            #     return redirect('user_not_allowed')   

        return super().dispatch(request, *args, **kwargs)  # Continue normal flow if no redirect

    def get_context_data(self, **kwargs):
        trigger_subscription()
        context = super().get_context_data(**kwargs)
        user = self.request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_dashboard_count': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                # return redirect('user_not_allowed')

            # if manage_user and not manage_user.can_dashboard_count:
            #     return redirect('user_not_allowed')

        # Other business logic for statistics
        farmer_count = Farmer.objects.filter(status__in=[0,1,3,4,5,6]).count()
        package_count = PackageManagement.objects.filter(Q(status=0) | Q(status=1)).count()
        subscription_count = AddSubcription.objects.filter(Q(status=0) | Q(status=1)).count()
        total_workers = ManageWorkers.objects.filter(Q(status=0) | Q(status=1)).count()
        total_workers_count = 0
        workers = ManageWorkers.objects.filter(status__in=[0, 1])
        for w in workers:
            total_workers_count += w.person
        
        total_markets = ManageMarket.objects.filter(Q(status=0) | Q(status=1)).count()
        total_users = ManageUser.objects.all().count()
        staff_count = ManageUser.objects.filter(usertype__code=0).count()
        workers_availability_count = ManageUser.objects.filter(usertype__code=1).count()
        market_price_count = ManageUser.objects.filter(usertype__code=2).count()

        #------------------ Market price table starts-------------------
        products = ManageProduct.objects.all().order_by('id')
        markets = ManageMarket.objects.all().order_by('-id')
        market_ids = []
        product_market_data = []
        for product in products: 
            product_data = {
                "id": product.id,
                "name": product.name,
                "market_ids": ', '.join(map(str, market_ids)),
                "market": [
                        market.id for market in product.markets.all()
                ]
            }
            product_market_data.append(product_data)

        # Pricing and market info
        product_market_prices = {}
        for product in products:
            for market in markets:
                market_product = MarketProduct.objects.filter(market=market, product=product).order_by('-updated_at').first()
                if market_product:
                    product_market_prices[(product.id, market.id)] = {
                        'product_id': product.id,
                        'product_name': product.name,
                        'market_id': market.id,
                        'market_name': market.name,
                        'price': market_product.price,
                        'available': market_product.available,
                        'updated_at': market_product.updated_at,  # This should point to the market product's updated_at
                    }
                else:
                    product_market_prices[(product.id, market.id)] = {
                        'product_id': product.id,
                        'product_name': product.name,
                        'market_id': market.id,
                        'market_name': market.name,
                        'price': 0,
                        'available': False,
                        'updated_at': None,
                    }
        
        product_market_prices = list(product_market_prices.values())

        # Additional details
        market_staff = {}
        allocations = AllocateMarket.objects.prefetch_related('staff', 'markets').all()
        for allocation in allocations:
            for market in allocation.markets.all():
                if market.id not in market_staff:
                    market_staff[market.id] = []
                if allocation.staff:
                    market_staff[market.id].append(allocation.staff.name)

        market_staff_list = [(market_id, staff_names) for market_id, staff_names in market_staff.items()]

        # Market updates
        market_updates = {}
        market_price_update = {}
        mar_product = MarketProduct.objects.all()
        for i in mar_product:
            if i.updated_at != None:
                market_updates[i.market.name] = i.updated_at
            else:
                market_updates[i.market.name] = i.created_at
            if i.market.name not in market_price_update:
                if i.available:
                    market_price_update[i.market.name] = 1
                else:
                    market_price_update[i.market.name] = i.price
            else:
                if i.price > market_price_update[i.market.name]:
                    market_price_update[i.market.name] = i.price
       
        marketss_details ={}
        all_markets = ManageMarket.objects.all()
        for i in all_markets:
            marketss_details[i.id] = {
                'name': i.name,
                # 'type': i.markettype.name,
                'phone': i.phone,
                'address': i.address,
            }

        # ---------------- End Market price table -------------

        #------------ Revenue for current month -------------
        today = timezone.now().date()
        start_of_month = today.replace(day=1)
        last_day_of_month = calendar.monthrange(today.year, today.month)[1]
        end_of_month = today.replace(day=last_day_of_month)

        subrep = AddSubcription.objects.filter(
            status=0,
            created_at__gte=start_of_month,
            created_at__lte=end_of_month
        )
        total_revenue_current_month = 0
        for s in subrep:
            total_revenue_current_month += s.packages.sub_amount

        context.update({
            #------------Market table details
            'markets': markets,
            'products': products,
            'market_staff_list': market_staff_list,
            'product_market_prices': product_market_prices,
            'product_market_data': product_market_data, 
            'market_updates': market_updates,
            'market_price_update': market_price_update,
            'marketss_details': marketss_details,
            #-------- end market table details

            'farmer_count': farmer_count,
            'package_count': package_count,
            'subscription_count': subscription_count,
            'total_workers': total_workers,
            'total_markets': total_markets,
            'total_users': total_users,
            'staff_count': staff_count,
            'workers_availability_count': workers_availability_count,
            'market_price_count': market_price_count,
            'total_revenue_current_month': total_revenue_current_month,
            'total_workers_count': total_workers_count
        })

        # context = KTLayout.init(context)
        
        context = KTLayout.init(context)
        context.update({
            'layout': KTTheme.setLayout('partials/super_admin/base_page.html', context),
        })
        KTTheme.addVendors(['amcharts', 'amcharts-maps', 'amcharts-stock']) 

        return context
    
    def post(self, request):
        action = request.POST.get('action')
        if action == 'update':
            pk = request.POST.get('id')
            user = get_object_or_404(CustomUser, pk=pk)
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except Exception as e:
                print(e)
                print("No Manage user found")
            
            img = request.FILES.get('avatar')
            name = request.POST.get('name')
            # phone = request.POST.get('mob_no')
            email = request.POST.get('email')
            # username = request.POST.get('username')

            # if phone and CustomUser.objects.filter(phone_number=phone).exclude(pk=user.pk).exists():
            #     messages.error(request,"This phone number is already registered.")
            #     return redirect('sa_dashboards')

            if email and CustomUser.objects.filter(email=email).exclude(pk=user.pk).exists():
                messages.error(request,"This email is already registered.")
                return redirect('sa_dashboards')

            if img:
                user.image = img
                if manage_user:
                    manage_user.img = img
                    manage_user.save()
            if user.name != name:
                user.name = name
                if manage_user:
                    manage_user.name = name
                    manage_user.save()
            # user.phone_number = phone
            if user.email != email:
                user.email = email
                if manage_user:
                    manage_user.email = email
                    manage_user.save()
            user.save()
            messages.success(request, "User Profile Updated Successfully.")
            return redirect('sa_dashboards')

def get_farmers_data(request):
    current_year = datetime.now().year

    farmers_by_month = Farmer.objects.filter(created_at__year=current_year, status= 0) \
        .annotate(month=TruncMonth('created_at')) \
        .values('month') \
        .annotate(farmer_count=Count('id')) \
        .order_by('month')

    month_labels = [calendar.month_name[i] for i in range(1, 13)]
    farmer_counts = []

    for month in range(1, 13):
        month_str = f'{current_year}-{month:02d}-01' 
        farmers_for_month = next(
            (item['farmer_count'] for item in farmers_by_month if item['month'].strftime('%Y-%m') == month_str[:7]), 0)
        farmer_counts.append(farmers_for_month)

    return JsonResponse({
        'month_labels': month_labels,
        'farmer_counts': farmer_counts,
    })

# ---------------------------------------------------------------------- Settings Filter ------------------------------------------------

def get_countries(request):
    countries = Country.objects.filter(status=0).values('id', 'name') 
    return JsonResponse({'status': 200, 'data': list(countries)})

def get_states(request):
    country_id = request.GET.get('country_id')
    if country_id:
        states = State.objects.filter(country_id=country_id, status=0).values('id', 'name')  # Assuming `id`, `name`, and `country_id`
        return JsonResponse({'status': 200, 'data': list(states)})
    return JsonResponse({'status': 400, 'message': 'Country ID is required'})

def get_cities(request):
    state_id = request.GET.get('state_id')  # We only need state_id now
    if state_id:
        cities = City.objects.filter(state_id=state_id, status=0).values('id', 'name')  # Assuming `id` and `name` fields in City model
        return JsonResponse({'status': 200, 'data': list(cities)})
    return JsonResponse({'status': 400, 'message': 'State ID is required'})

def get_taluks(request):
    city_id = request.GET.get('city_id')  # We need city_id for fetching taluks
    if city_id:
        taluks = Taluk.objects.filter(city_id=city_id, status=0).values('id', 'name')  # Assuming `id` and `name` fields in Taluk model
        return JsonResponse({'status': 200, 'data': list(taluks)})
    return JsonResponse({'status': 400, 'message': 'City ID is required'})

def get_villages(request):
    taluk_id = request.GET.get('taluk_id')  # We need taluk_id for fetching villages
    if taluk_id:
        villages = Village.objects.filter(taluk_id=taluk_id, status=0).values('id', 'name')  # Assuming `id` and `name` fields in Village model
        return JsonResponse({'status': 200, 'data': list(villages)})
    return JsonResponse({'status': 400, 'message': 'Taluk ID is required'})

# ------------------------------------------------------------------------------- Settings ---------------------------------------------------

def get_country_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = Country.objects.get(pk=pk)
    except Country.DoesNotExist:
        return JsonResponse({'error': 'Soil Type not found'}, status=404)

    if language == 'en':
        name = soil_type.name
    else:
        name = soil_type.get_translated_value('name', language)

    return JsonResponse({
        'name': name,
    })

class CountryView(LoginRequiredMixin,View):
    def get(self, request): 
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_country': True,
                'can_view_country': True,
                'can_edit_country': True,
                'can_delete_country': True, 
                'can_status_country': True, 

            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_country:
                return redirect('user_not_allowed') 
            
        countries = Country.objects.filter(
            Q(status=0) | Q(status=1),
        ).order_by('-id') 

        show_per_page = request.GET.get('show', 25)
        show_per_page = int(show_per_page)  # Convert it to an integer

        # Pagination setup
        paginator = Paginator(countries, show_per_page)  # Show the selected number of farmers per page 
        page_number = request.GET.get('page')  # Get the page number from the request
        page_obj = paginator.get_page(page_number)
        country_count = 0
        for i in page_obj:
            country_count += 1

        languages = Languages.objects.filter(status=0).order_by('id')
        context = {
            'languages': languages,
            'countries': page_obj,
            'entries_count': country_count,
            'show_per_page': show_per_page,
            'can_add_country': manage_user.can_add_country if manage_user else False,
            'can_view_country': manage_user.can_view_country if manage_user else False,
            'can_edit_country': manage_user.can_edit_country if manage_user else False,
            'can_delete_country': manage_user.can_delete_country if manage_user else False,
            'can_status_country': manage_user.can_status_country if manage_user else False,
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/country/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')
        
        if action == 'create':
            name = request.POST.get('name')
            countries = Country.objects.all() 

            if not name:
                context = {
                    'countries': countries,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/country/list.html', context)

            if Country.objects.filter(name=name, status__in=[0, 1]).exists():
                context = {
                    'countries': countries,
                    'error': f'Country "{name}" already exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/country/list.html', context)
            
            add_country = Country.objects.create(name=name, status=0, created_by=user, created_at=timezone.now())
            add_country.save()
            messages.success(request, "Country created successfully.")
            return redirect('sa_country')

        elif action == 'update':
            pk = request.POST.get('id')
            country = get_object_or_404(Country, pk=pk)
            name = request.POST.get('name')
            translated_json = country.translate_json or {
                'name' : {}
            }
            language = request.POST.get('language')

            if name:
                if language == "en":
                    if name != country.name:
                        country.name = name
                        try:
                            for lang in target_language:
                                translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                                translated_json["name"][lang] = translated_text
                        except Exception as e:
                            print(e)
                            print("Error in translation")
                else:
                    translated_json["name"][language] = name
                country.updated_by = user
                country.translate_json = translated_json
                country.save()
                messages.success(request, "Country updated successfully.")
            else:
                messages.error(request, "Country name cannot be empty.")

            return redirect('sa_country') 

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                country = get_object_or_404(Country, pk=pk)
                
                status = request.POST.get('status')

                if status == '0':
                    country.status = 0  
                    country.updated_by = user
                    country.save()
                    messages.success(request, "Country has been Activated.")
                elif status == '1':
                    country.status = 1  
                    country.updated_by = user
                    country.save()
                    messages.success(request, "Country has been Deactivated.")
                else:
                    messages.error(request, "Invalid Status Value.")
                
            return redirect('sa_country') 

        elif action == 'delete':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                country = get_object_or_404(Country, pk=pk)
                
                # country.status = 2 
                # country.updated_by = user
                country.delete()
                messages.success(request, "Country has been Deleted successfully.")
            
            return redirect('sa_country')

        return redirect('sa_country')

def get_state_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = State.objects.get(pk=pk)
    except State.DoesNotExist:
        return JsonResponse({'error': 'Soil Type not found'}, status=404)

    if language == 'en':
        name = soil_type.name
    else:
        name = soil_type.get_translated_value('name', language)

    return JsonResponse({
        'name': name,
    })

class StateView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_state': True,
                'can_view_state': True,
                'can_edit_state': True,
                'can_delete_state': True, 
                'can_status_state': True, 

            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_state:
                return redirect('user_not_allowed') 
            
        # search_query = request.GET.get('search', '')
        states = State.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')


        show_per_page = request.GET.get('show', 25)
        show_per_page = int(show_per_page)  # Convert it to an integer

        # Pagination setup
        paginator = Paginator(states, show_per_page)  # Show the selected number of farmers per page 
        page_number = request.GET.get('page')  # Get the page number from the request
        page_obj = paginator.get_page(page_number)
        state_count = 0
        for i in page_obj:
            state_count += 1

        countries = Country.objects.filter(status=0).order_by('-id')

        languages = Languages.objects.filter(status=0).order_by('id')
        context = {
            'languages': languages,
            'states': page_obj,
            'countries': countries, 
            'entries_count': state_count,
            'show_per_page': show_per_page, 
            'can_add_state': manage_user.can_add_state if manage_user else False,
            'can_view_state': manage_user.can_view_state if manage_user else False,
            'can_edit_state': manage_user.can_edit_state if manage_user else False,
            'can_delete_state': manage_user.can_delete_state if manage_user else False,
            'can_status_state': manage_user.can_status_state if manage_user else False,
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/state/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            country_id = request.POST.get('country')

            if name and country_id:
                country = get_object_or_404(Country, pk=country_id)

                # Check if the state already exists
                if State.objects.filter(name=name, country= country, status__in=[0, 1]).exists():
                    messages.error(request,'State with this name already exists in the selected country.')
                    return redirect('sa_state')
                else:
                    # Create the state with status set to True
                    State.objects.create(name=name, country=country, status=0, created_by=user, created_at=timezone.now())
                    messages.success(request,"State created successfully.")
                    return redirect('sa_state')
            else:
                messages.error(request,'State name and country are required.')
                return redirect('sa_state')

        elif action == 'update':
            pk = request.POST.get('id')
            state = get_object_or_404(State, pk=pk)
            name = request.POST.get('name')
            country_id = request.POST.get('country')
            translated_json = state.translate_json or {
                'name' : {}
            }
            language = request.POST.get('language')

            if not name and not country_id:
                messages.success(request,"State name and country are required.")
            elif not name:
                messages.success(request,"State name is required.")
            elif not country_id:
                messages.success(request,"Country selection is required.")
            else:
                if language == "en":
                    if name != state.name:
                        state.name = name
                        try:
                            for lang in target_language:
                                translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                                translated_json["name"][lang] = translated_text
                        except Exception as e:
                            print(e)
                            print("Error in translation")
                else:
                    translated_json["name"][language] = name
                country = get_object_or_404(Country, pk=country_id)
                state.country = country
                state.updated_by = user
                state.translate_json = translated_json
                state.save()
                messages.success(request,"State updated successfully.")
                return redirect('sa_state')

        elif action == 'update_status': 
            pk = request.POST.get('id') 
            
            if not pk:
                messages.error(request, "ID cannot be empty.") 
            else:
                state = get_object_or_404(State, pk=pk)
                
                status = request.POST.get('status')  

                if status == '0':
                    state.status = 0  
                    state.updated_by = user
                    state.save()
                    messages.success(request, "State Has Been Activated.")
                elif status == '1':
                    state.status = 1 
                    state.updated_by = user 
                    state.save()
                    messages.success(request, "State Has Been Deactivated.")
                elif status == '2':
                    state.status = 2  
                    state.updated_by = user
                    state.save()
                    messages.info(request, "State Has Been Marked as Inactive.")
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_state') 

        elif action == 'delete': 
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.") 
            else:
                state = get_object_or_404(State, pk=pk)
                
                # state.status = 2  
                # state.updated_by = user
                state.delete()
                
                messages.success(request, "State Has Been Deleted Successfully.") 
            
            return redirect('sa_state')

        else:
            messages.error(request,"Invalid action.")
            return redirect('sa_state')

def get_city_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = City.objects.get(pk=pk)
    except City.DoesNotExist:
        return JsonResponse({'error': 'Soil Type not found'}, status=404)

    if language == 'en':
        name = soil_type.name
    else:
        name = soil_type.get_translated_value('name', language)

    return JsonResponse({
        'name': name,
    })

class CityView(LoginRequiredMixin,View):
    def get(self, request): 
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_city': True,
                'can_view_city': True,
                'can_edit_city': True,
                'can_delete_city': True, 
                'can_status_city': True, 

            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_city:
                return redirect('user_not_allowed')  
            
        cities = City.objects.filter(
            Q(status=0) | Q(status=1),
        ).order_by('-id')

        show_per_page = request.GET.get('show', 25)
        show_per_page = int(show_per_page)  # Convert it to an integer

        # Pagination setup
        paginator = Paginator(cities, show_per_page)  # Show the selected number of farmers per page 
        page_number = request.GET.get('page')  # Get the page number from the request
        page_obj = paginator.get_page(page_number)
        city_count = 0
        for i in page_obj:
            city_count += 1

        
        states = State.objects.filter(status=0).order_by('-id') 
        countries = Country.objects.filter(status=0).order_by('-id') 

        languages = Languages.objects.filter(status=0).order_by('id')
            
        return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/city/list.html', {
            'languages': languages,
            'cities': page_obj,
            'states': states,
            'countries': countries, 
            'entries_count': city_count,
            'show_per_page': show_per_page,
            'can_add_city': manage_user.can_add_city if manage_user else False,
            'can_view_city': manage_user.can_view_city if manage_user else False,
            'can_edit_city': manage_user.can_edit_city if manage_user else False,
            'can_delete_city': manage_user.can_delete_city if manage_user else False,
            'can_status_city': manage_user.can_status_city if manage_user else False,
            'messages': messages.get_messages(request)  # Get any messages to display
        })

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)

        action = request.POST.get('action')

        cities = City.objects.all()
        states = State.objects.filter(status=0).order_by('-id')
        countries = Country.objects.filter(status=0).order_by('-id')

        if action == 'create':
            name = request.POST.get('name')
            country_id = request.POST.get('country')
            state_id = request.POST.get('state')

            # Initialize a dictionary to hold error messages
            errors = {
                'name': None,
                'country': None,
                'state': None,
                'city_exists': None
            }

            # Check for required fields
            if not name:
                errors['name'] = 'District name is required.'
            if not country_id:
                errors['country'] = 'Country is required.'
            if not state_id:
                errors['state'] = 'State is required.'

            # Check if the city already exists in the selected state and country
            if not errors and City.objects.filter(name=name, state_id=state_id, country_id=country_id, status__in =[0,1]).exists():
                errors['city_exists'] = 'District Name Already Exists.'

            # If there are errors, re-render the form with error messages
            if any(errors.values()):
                return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/city/list.html', {
                    'cities': cities,
                    'states': states,
                    'countries': countries,
                    'errors': errors  # Pass error messages to the template
                })

            # If no errors, create the city
            country = get_object_or_404(Country, pk=country_id)
            state = get_object_or_404(State, pk=state_id)
            City.objects.create(name=name, country=country, state=state, status=0, created_by=user, created_at=timezone.now())
            messages.success(request, "District created successfully.")
            return redirect('sa_city')

        elif action == 'update':
            pk = request.POST.get('id')
            city = get_object_or_404(City, pk=pk)
            name = request.POST.get('name')
            state_id = request.POST.get('state')
            country_id = request.POST.get('country')
            translated_json = city.translate_json or {
                'name' : {}
            }
            language = request.POST.get('language')

            if name and state_id and country_id:
                state = get_object_or_404(State, pk=state_id)
                country = get_object_or_404(Country, pk=country_id)

                if language == "en":
                    if name != city.name:
                        city.name = name
                        try:
                            for lang in target_language:
                                translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                                translated_json["name"][lang] = translated_text
                        except Exception as e:
                            print(e)
                            print("Error in translation")
                else:
                    translated_json["name"][language] = name
                
                city.country = country
                city.updated_by = user
                city.translate_json = translated_json
                city.save()
                messages.success(request, "District updated successfully.")
                return redirect('sa_city')

        elif action == 'update_status':   
            pk = request.POST.get('id')  

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else: 
                city = get_object_or_404(City, pk=pk)
                
                status = request.POST.get('status')  

                if status == '0':   
                    city.status = 0
                    city.updated_by = user
                    city.save()   
                    messages.success(request, "District has been Activated.")
                elif status == '1':  
                    city.status = 1
                    city.updated_by = user
                    city.save()  
                    messages.success(request, "District has been Deactivated.")
                else:
                    messages.error(request, "Invalid status value.")   
                
            return redirect('sa_city') 
        
        elif action == 'delete':   
            pk = request.POST.get('id')   
            
            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else: 
                city = get_object_or_404(City, pk=pk)
                
                # city.status = 2   
                # city.updated_by = user
                city.delete(0)
                messages.success(request, "District has been Deleted successfully.")
            
            return redirect('sa_city') 

        return redirect('sa_city')

def get_taluk_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = Taluk.objects.get(pk=pk)
    except Taluk.DoesNotExist:
        return JsonResponse({'error': 'data not found'}, status=404)

    if language == 'en':
        name = soil_type.name
    else:
        name = soil_type.get_translated_value('name', language)

    return JsonResponse({
        'name': name,
    })

class TalukView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_taluk': True,
                'can_view_taluk': True,
                'can_edit_taluk': True,
                'can_delete_taluk': True, 
                'can_status_taluk': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_taluk:
                return redirect('user_not_allowed')
        
        taluk = Taluk.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')

        show_per_page = request.GET.get('show', 25)
        show_per_page = int(show_per_page)  # Convert it to an integer

        # Pagination setup
        paginator = Paginator(taluk, show_per_page)  # Show the selected number of farmers per page 
        page_number = request.GET.get('page')  # Get the page number from the request
        page_obj = paginator.get_page(page_number)
        taluk_count = 0
        for i in page_obj:
            taluk_count += 1

        cities = City.objects.filter(status=0).order_by('-id')
        states = State.objects.filter(status=0).order_by('-id')
        countries = Country.objects.filter(status=0).order_by('-id')

        languages = Languages.objects.filter(status=0).order_by('id')
        context = {
            'languages': languages,
            'cities': cities,
            'states': states,
            'countries': countries,
            'taluk': page_obj, 
            'entries_count': taluk_count,
            'show_per_page': show_per_page,
            'can_add_taluk': manage_user.can_add_taluk if manage_user else False,
            'can_view_taluk': manage_user.can_view_taluk if manage_user else False,
            'can_edit_taluk': manage_user.can_edit_taluk if manage_user else False,
            'can_delete_taluk': manage_user.can_delete_taluk if manage_user else False,
            'can_status_taluk': manage_user.can_status_taluk if manage_user else False,
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/taluk/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            # Retrieve form data first
            name = request.POST.get('name')
            country_id = request.POST.get('country')
            state_id = request.POST.get('state')
            city_id = request.POST.get('city')

            # Initialize variables for cities, states, countries, and taluks
            cities = City.objects.all()
            states = State.objects.all()
            countries = Country.objects.all()
            taluk_list = Taluk.objects.all()

            # Check if the name and other fields are filled
            if not name:
                error_message = 'This field is required.'
            elif not country_id or not state_id or not city_id:
                error_message = 'All fields are required.'
            else:
                # Check if the Taluk already exists
                if Taluk.objects.filter(name=name, city_id=city_id, state_id=state_id, country_id=country_id, status__in=[0, 1]).exists():
                    error_message = 'Taluk Name Already Exists'
                else:
                    try:
                        city = get_object_or_404(City, pk=city_id)
                        country = get_object_or_404(Country, pk=country_id)
                        state = get_object_or_404(State, pk=state_id)
                        # Create the new Taluk
                        Taluk.objects.create(name=name, country=country, state=state, city=city, status=0, created_by=user, created_at=timezone.now())
                        messages.success(request, "Taluk created successfully.")
                        return redirect('sa_taluk')
                    except Http404:
                        error_message = 'City, State, or Country not found.'

            # Pass the error message to the context if validation fails
            context = {
                'cities': cities,
                'states': states,
                'countries': countries,
                'taluk': taluk_list,
                'error_message': error_message,  # Pass the error message here
            }
            return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/taluk/list.html', context)

        elif action == 'update':
            pk = request.POST.get('id')
            taluk = get_object_or_404(Taluk, pk=pk)
            name = request.POST.get('name')
            state_id = request.POST.get('edit_state')
            country_id = request.POST.get('edit_country')
            city_id = request.POST.get('edit_city')
            translated_json = taluk.translate_json or {
                'name' : {}
            }
            language = request.POST.get('language')

            if name and state_id and country_id and city_id:  
                state = get_object_or_404(State, pk=state_id)
                country = get_object_or_404(Country, pk=country_id)
                city = get_object_or_404(City, pk=city_id)
                
                if language == "en":
                    if name != taluk.name:
                        taluk.name = name
                        try:
                            for lang in target_language:
                                translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                                translated_json["name"][lang] = translated_text
                        except Exception as e:
                            print(e)
                            print("Error in translation")
                else:
                    translated_json["name"][language] = name

                # taluk.name = name
                taluk.state = state
                taluk.country = country
                taluk.city = city
                taluk.updated_by = user
                taluk.translate_json = translated_json
                taluk.save()
                messages.success(request, "Taluk status updated successfully.")
                return redirect('sa_taluk')
                
        elif action == 'update_status': 
            pk = request.POST.get('id')  

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                taluk = get_object_or_404(Taluk, pk=pk)
                
                status = request.POST.get('status')   

                if status == '0':  
                    taluk.status = 0
                    taluk.updated_by = user
                    taluk.save() 
                    messages.success(request, "Taluk has been Activated.")
                elif status == '1':   
                    taluk.status = 1
                    taluk.updated_by = user
                    taluk.save()  
                    messages.success(request, "Taluk has been Deactivated.")
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_taluk')  
        
        elif action == 'delete':   
            pk = request.POST.get('id')   
            
            if not pk:
                messages.error(request, "ID cannot be empty.") 
            else: 
                taluk = get_object_or_404(Taluk, pk=pk)
                 
                # taluk.status = 2  
                # taluk.updated_by = user 
                taluk.delete()
                messages.success(request, "Taluk has been Deleted successfully.")
            
            return redirect('sa_taluk') 

        return redirect('sa_taluk')

class CheckTalukView(LoginRequiredMixin,View):
    def post(self, request):
        trigger_subscription()
        data = json.loads(request.body)
        name = data.get('name')
        country_id = data.get('country')
        state_id = data.get('state')
        city_id = data.get('city')

        exists = Taluk.objects.filter(name=name, city_id=city_id, state_id=state_id, country_id=country_id).exists()
        return JsonResponse({'exists': exists})

def get_village_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = Village.objects.get(pk=pk)
    except Village.DoesNotExist:
        return JsonResponse({'error': 'data not found'}, status=404)

    if language == 'en':
        name = soil_type.name
    else:
        name = soil_type.get_translated_value('name', language)

    return JsonResponse({
        'name': name,
    })

class VillageView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_village': True,
                'can_view_village': True,
                'can_edit_village': True,
                'can_delete_village': True, 
                'can_status_village': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_village:
                return redirect('user_not_allowed') 
            
        villages = Village.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')

        show_per_page = request.GET.get('show', 25)
        show_per_page = int(show_per_page)  # Convert it to an integer

        # Pagination setup
        paginator = Paginator(villages, show_per_page)  # Show the selected number of farmers per page 
        page_number = request.GET.get('page')  # Get the page number from the request
        page_obj = paginator.get_page(page_number)
        villages_count = 0
        for i in page_obj:
            villages_count += 1

        cities = City.objects.filter(status=0).order_by('-id')
        states = State.objects.filter(status=0).order_by('-id')
        countries = Country.objects.filter(status=0).order_by('-id')
        taluks = Taluk.objects.filter(status=0).order_by('-id')

        languages = Languages.objects.filter(status=0).order_by('id')
        context = {
            'languages': languages,
            'cities': cities,
            'states': states,
            'countries': countries,
            'taluks': taluks,  # Pass taluks to context
            'villages': page_obj,
            'entries_count': villages_count,
            'show_per_page': show_per_page,
            'can_add_village': manage_user.can_add_village if manage_user else False,
            'can_view_village': manage_user.can_view_village if manage_user else False,
            'can_edit_village': manage_user.can_edit_village if manage_user else False,
            'can_delete_village': manage_user.can_delete_village if manage_user else False,
            'can_status_village': manage_user.can_status_village if manage_user else False,
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', context)

    # def post(self, request):
    #     user_id = self.request.user.id
    #     user = get_object_or_404(CustomUser, id=user_id)
    #     action = request.POST.get('action')

    #     # if action == 'create':
    #     #     name = request.POST.get('name')
    #     #     country_id = request.POST.get('country')
    #     #     state_id = request.POST.get('state')
    #     #     city_id = request.POST.get('city')
    #     #     taluk_id = request.POST.get('taluk')
        
    #     #     # Check if all fields are filled
    #     #     if not all([name, country_id, state_id, city_id, taluk_id]):
    #     #         return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', {
    #     #             'error': 'All fields are required.',
    #     #             'cities': City.objects.all(),
    #     #             'states': State.objects.all(),
    #     #             'countries': Country.objects.all(),
    #     #             'taluks': Taluk.objects.all(),
    #     #             'villages': Village.objects.all(),
    #     #         })

    #     #     # Check if the village name already exists
    #     #     if Village.objects.filter(name=name,status__in=[0,1]).exists():
    #     #         return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', {
    #     #             'duplicate_error': 'Village Name Already Exists.',
    #     #             'cities': City.objects.all(),
    #     #             'states': State.objects.all(),
    #     #             'countries': Country.objects.all(),
    #     #             'taluks': Taluk.objects.all(),
    #     #             'villages': Village.objects.all(),
    #     #         })

    #     #     # Create the village with the associated fields
    #     #     village = Village(
    #     #         name=name,
    #     #         country_id=country_id,
    #     #         state_id=state_id,
    #     #         city_id=city_id,
    #     #         taluk_id=taluk_id,
    #     #         created_by=user,
    #     #         created_at=timezone.now()
    #     #     )
    #     #     village.save()

    #     #     messages.success(request, 'Village created successfully.')
    #     #     return redirect('sa_village')

    #     if action == 'create':
    #         print("=== Village Creation Started ===")

    #         name = request.POST.get('name')
    #         country_id = request.POST.get('country')
    #         state_id = request.POST.get('state')
    #         city_id = request.POST.get('city')
    #         taluk_id = request.POST.get('taluk')
    #         new_taluk_name = request.POST.get('new_taluk')  # Optional new taluk field

    #         print(f"Received Data - Name: {name}, Country ID: {country_id}, State ID: {state_id}, City ID: {city_id}, Taluk ID: {taluk_id}, New Taluk: {new_taluk_name}")

    #         # Validate required fields
    #         if not all([name, country_id, state_id, city_id]):
    #             print("Error: Missing required fields.")
    #             return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', {
    #                 'error': 'All fields except Taluk are required.',
    #                 'cities': City.objects.all(),
    #                 'states': State.objects.all(),
    #                 'countries': Country.objects.all(),
    #                 'taluks': Taluk.objects.all(),
    #                 'villages': Village.objects.all(),
    #             })

    #         # Check for duplicate village name
    #         if Village.objects.filter(name=name, status__in=[0, 1]).exists():
    #             print("Error: Duplicate village name.")
    #             return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', {
    #                 'duplicate_error': 'Village Name Already Exists.',
    #                 'cities': City.objects.all(),
    #                 'states': State.objects.all(),
    #                 'countries': Country.objects.all(),
    #                 'taluks': Taluk.objects.all(),
    #                 'villages': Village.objects.all(),
    #             })

    #         # If new Taluk is provided
    #         if new_taluk_name:
    #             print(f"Creating or getting Taluk with name: {new_taluk_name}")
    #             taluk, created = Taluk.objects.get_or_create(
    #                 name=new_taluk_name,
    #                 defaults={
    #                     'country_id': country_id,
    #                     'state_id': state_id,
    #                     'city_id': city_id,
    #                     'created_by': user,
    #                     'created_at': timezone.now()
    #                 }
    #             )
    #             taluk_id = taluk.id
    #             print(f"{'Created' if created else 'Found existing'} Taluk with ID: {taluk_id}")
    #         elif not taluk_id:
    #             print("Error: No Taluk selected or entered.")
    #             return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', {
    #                 'error': 'Please select an existing Taluk or enter a new one.',
    #                 'cities': City.objects.all(),
    #                 'states': State.objects.all(),
    #                 'countries': Country.objects.all(),
    #                 'taluks': Taluk.objects.all(),
    #                 'villages': Village.objects.all(),
    #             })

    #         # Create the village
    #         print("Creating Village...")
    #         village = Village(
    #             name=name,
    #             country_id=country_id,
    #             state_id=state_id,
    #             city_id=city_id,
    #             taluk_id=taluk_id,
    #             created_by=user,
    #             created_at=timezone.now()
    #         )
    #         village.save()

    #         print(f"Village '{village.name}' created successfully with ID: {village.id}")
    #         messages.success(request, 'Village created successfully.')
    #         print("=== Village Creation Finished ===")
    #         return redirect('sa_village')

         
    #     elif action == 'update':
    #         pk = request.POST.get('id')
    #         village = get_object_or_404(Village, pk=pk)
    #         name = request.POST.get('name')
    #         state_id = request.POST.get('state')
    #         country_id = request.POST.get('country')
    #         city_id = request.POST.get('city')
    #         taluk_id = request.POST.get('taluk')
    #         translated_json = village.translate_json or {
    #             'name' : {}
    #         }
    #         language = request.POST.get('language')

    #         if name and state_id and country_id and city_id and taluk_id:
    #             if Village.objects.filter(name=name).exclude(pk=pk).exists():
    #                 return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', {
    #                     'error': 'Village with this name already exists.',
    #                     'is_form_submitted': True,  # Set form submitted flag for error display
    #                     'cities': City.objects.all(),
    #                     'states': State.objects.all(),
    #                     'countries': Country.objects.all(),
    #                     'taluks': Taluk.objects.all(),
    #                     'villages': Village.objects.all(),
    #                 })

    #             # Proceed to update the village
    #             state = get_object_or_404(State, pk=state_id)
    #             country = get_object_or_404(Country, pk=country_id)
    #             city = get_object_or_404(City, pk=city_id)
    #             taluk = get_object_or_404(Taluk, pk=taluk_id)

    #             if language == "en":
    #                 if name != village.name:
    #                     village.name = name
    #                     try:
    #                         for lang in target_language:
    #                             translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
    #                             translated_json["name"][lang] = translated_text
    #                     except Exception as e:
    #                         print(e)
    #                         print("Error in translation")
    #             else:
    #                 translated_json["name"][language] = name
                
    #             # village.name = name
    #             village.state = state
    #             village.country = country
    #             village.city = city
    #             village.taluk = taluk
    #             village.updated_by = user
    #             village.translate_json = translated_json
    #             village.save()

    #             messages.success(request, 'Village updated successfully.')
    #             return redirect('sa_village')

    #         return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', {
    #             'error': 'All fields are required.',
    #             'is_form_submitted': True,  # Set form submitted flag for error display
    #             'cities': City.objects.all(),
    #             'states': State.objects.all(),
    #             'countries': Country.objects.all(),
    #             'taluks': Taluk.objects.all(),
    #             'villages': Village.objects.all(),
    #         })

    #     elif action == 'update_status': 
    #         pk = request.POST.get('id')  

    #         if not pk:
    #             messages.error(request, "ID cannot be empty.")
    #         else:
    #             village = get_object_or_404(Village, pk=pk)
                
    #             status = request.POST.get('status')   

    #             if status == '0':  
    #                 village.status = 0
    #                 village.updated_by = user
    #                 village.save() 
    #                 messages.success(request, "Village has been Activated.")
    #             elif status == '1':   
    #                 village.status = 1
    #                 village.updated_by = user
    #                 village.save()  
    #                 messages.success(request, "Village has been Deactivated.")
    #             else:
    #                 messages.error(request, "Invalid status value.")  
                
    #         return redirect('sa_village')  

    #     elif action == 'delete':   
    #         pk = request.POST.get('id')   
            
    #         if not pk:
    #             messages.error(request, "ID cannot be empty.") 
    #         else: 
    #             village = get_object_or_404(Village, pk=pk)
                
    #             village.status = 2  
    #             village.updated_by = user 
    #             village.save()   
                
    #             # If Village has related entities, you may need to handle them here
    #             # Example: If Village has any related State, City, etc. you can manage those relationships
                
    #             states = State.objects.filter(village=village)  # Check if Village is related to any States
                
    #             if states.exists():
    #                 for state in states: 
    #                     pass  # Add any logic if needed, like deactivating related entities or handling specific actions.
                
    #             messages.success(request, "Village has been Deleted successfully.")
            
    #         return redirect('sa_village')
        
    #     return redirect('sa_village')


    def post(self, request):
        print("\n=== Village Creation Started ===")
        
        user_id = request.user.id
        user = get_object_or_404(CustomUser, id=user_id)

        action = request.POST.get('action')
        name = request.POST.get('name', '').strip()
        country_id = request.POST.get('country')
        state_id = request.POST.get('state')
        city_id = request.POST.get('city')
        taluk_id = request.POST.get('taluk')
        new_taluk_name = request.POST.get('new_taluk', '').strip()

        print(f"Received Data - Name: {name}, Country ID: {country_id}, State ID: {state_id}, City ID: {city_id}, Taluk ID: {taluk_id}, New Taluk: {new_taluk_name}")

        if action == 'create':
            # Validate mandatory fields except taluk for now
            if not all([name, country_id, state_id, city_id]):
                print("Error: Missing required fields.")
                context = self.get_context_data(error='All fields except Taluk are required.')
                return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', context)

            # Check if village name already exists (case insensitive)
            if Village.objects.filter(name__iexact=name, status__in=[0,1]).exists():
                print("Error: Village Name Already Exists.")
                context = self.get_context_data(duplicate_error='Village Name Already Exists.')
                return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', context)

            # === Taluk Handling ===
            if new_taluk_name:
                normalized_new_taluk = new_taluk_name.lower()

                existing_taluk = Taluk.objects.filter(
                    name__iexact=normalized_new_taluk,
                    country_id=country_id,
                    state_id=state_id,
                    city_id=city_id
                ).first()

                if existing_taluk:
                    print(f"Error: Taluk '{new_taluk_name}' already exists with ID: {existing_taluk.id}")
                    context = self.get_context_data(error=f"Taluk '{new_taluk_name}' already exists.")
                    return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', context)

                # Create new Taluk
                taluk = Taluk.objects.create(
                    name=new_taluk_name,
                    country_id=country_id,
                    state_id=state_id,
                    city_id=city_id,
                    created_by=user,
                    created_at=timezone.now()
                )
                taluk_id = taluk.id
                print(f"New Taluk '{new_taluk_name}' created with ID: {taluk.id}")

            elif taluk_id:
                print(f"Using existing Taluk ID: {taluk_id}")
            else:
                print("Error: Taluk not selected and no new taluk provided.")
                context = self.get_context_data(error='Please select a Taluk or enter a new one.')
                return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', context)

            # Create Village
            print("Creating Village...")
            village = Village(
                name=name,
                country_id=country_id,
                state_id=state_id,
                city_id=city_id,
                taluk_id=taluk_id,
                created_by=user,
                created_at=timezone.now()
            )
            village.save()
            print(f"Village '{name}' created successfully with ID: {village.id}")
            print("=== Village Creation Finished ===")

            messages.success(request, 'Village created successfully.')
            return redirect('sa_village')

     
        elif action == 'update':
            pk = request.POST.get('id')
            village = get_object_or_404(Village, pk=pk)
            name = request.POST.get('name')
            state_id = request.POST.get('state')
            country_id = request.POST.get('country')
            city_id = request.POST.get('city')
            taluk_id = request.POST.get('taluk')
            translated_json = village.translate_json or {
                'name' : {}
            }
            language = request.POST.get('language')

            if name and state_id and country_id and city_id and taluk_id:
                if Village.objects.filter(name=name).exclude(pk=pk).exists():
                    return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', {
                        'error': 'Village with this name already exists.',
                        'is_form_submitted': True,  # Set form submitted flag for error display
                        'cities': City.objects.all(),
                        'states': State.objects.all(),
                        'countries': Country.objects.all(),
                        'taluks': Taluk.objects.all(),
                        'villages': Village.objects.all(),
                    })

                # Proceed to update the village
                state = get_object_or_404(State, pk=state_id)
                country = get_object_or_404(Country, pk=country_id)
                city = get_object_or_404(City, pk=city_id)
                taluk = get_object_or_404(Taluk, pk=taluk_id)

                if language == "en":
                    if name != village.name:
                        village.name = name
                        try:
                            for lang in target_language:
                                translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                                translated_json["name"][lang] = translated_text
                        except Exception as e:
                            print(e)
                            print("Error in translation")
                else:
                    translated_json["name"][language] = name
                
                # village.name = name
                village.state = state
                village.country = country
                village.city = city
                village.taluk = taluk
                village.updated_by = user
                village.translate_json = translated_json
                village.save()

                messages.success(request, 'Village updated successfully.')
                return redirect('sa_village')

            return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', {
                'error': 'All fields are required.',
                'is_form_submitted': True,  # Set form submitted flag for error display
                'cities': City.objects.all(),
                'states': State.objects.all(),
                'countries': Country.objects.all(),
                'taluks': Taluk.objects.all(),
                'villages': Village.objects.all(),
            })


        # elif action == 'update':
        #     pk = request.POST.get('id')
        #     village = get_object_or_404(Village, pk=pk)
        #     language = request.POST.get('language')  # <----- Add this line
        #     # Validation for mandatory fields on update
        #     if not all([name, country_id, state_id, city_id]):
        #         print("Error: Missing required fields for update.")
        #         context = self.get_context_data(error='All fields are required for update.')
        #         return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', context)

        #     # Taluk Handling for update: same as create
        #     if new_taluk_name:
        #         normalized_new_taluk = new_taluk_name.lower()

        #         existing_taluk = Taluk.objects.filter(
        #             name__iexact=normalized_new_taluk,
        #             country_id=country_id,
        #             state_id=state_id,
        #             city_id=city_id
        #         ).first()

        #         if existing_taluk:
        #             print(f"Error: Taluk '{new_taluk_name}' already exists with ID: {existing_taluk.id}")
        #             context = self.get_context_data(taluk_error=f"Taluk '{new_taluk_name}' already exists.")
        #             return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', context)

        #         # Create new Taluk for update
        #         taluk = Taluk.objects.create(
        #             name=new_taluk_name,
        #             country_id=country_id,
        #             state_id=state_id,
        #             city_id=city_id,
        #             created_by=user,
        #             created_at=timezone.now()
        #         )
        #         taluk_id = taluk.id
        #         print(f"New Taluk '{new_taluk_name}' created with ID: {taluk.id}")

        #     elif taluk_id:
        #         print(f"Using existing Taluk ID: {taluk_id}")
        #     else:
        #         print("Error: Taluk not selected and no new taluk provided for update.")
        #         context = self.get_context_data(taluk_error='Please select a Taluk or enter a new one.')
        #         return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', context)

        #     # Check duplicate village name on update (exclude self)
        #     if Village.objects.filter(name__iexact=name).exclude(pk=pk).exists():
        #         print("Error: Village name already exists for another record.")
        #         context = self.get_context_data(error='Village with this name already exists.')
        #         return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/village/list.html', context)

        #     # Fetch related objects
        #     state = get_object_or_404(State, pk=state_id)
        #     country = get_object_or_404(Country, pk=country_id)
        #     city = get_object_or_404(City, pk=city_id)
        #     taluk = get_object_or_404(Taluk, pk=taluk_id)

        #     translated_json = village.translate_json or {'name': {}}

        #     if language == "en":
        #         if name != village.name:
        #             village.name = name
        #             try:
        #                 # target_language needs to be defined somewhere in your code
        #                 for lang in target_language:
        #                     translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
        #                     translated_json["name"][lang] = translated_text
        #             except Exception as e:
        #                 print(e)
        #                 print("Error in translation")
        #     else:
        #         translated_json["name"][language] = name

        #     village.state = state
        #     village.country = country
        #     village.city = city
        #     village.taluk = taluk
        #     village.updated_by = user
        #     village.translate_json = translated_json
        #     village.save()

        #     messages.success(request, 'Village updated successfully.')
        #     return redirect('sa_village')



        elif action == 'update_status': 
            pk = request.POST.get('id')  

            if not pk:  
                messages.error(request, "ID cannot be empty.")
            else:
                village = get_object_or_404(Village, pk=pk)
                
                status = request.POST.get('status')   

                if status == '0':  
                    village.status = 0
                    village.updated_by = user
                    village.save() 
                    messages.success(request, "Village has been Activated.")
                elif status == '1':   
                    village.status = 1
                    village.updated_by = user
                    village.save()  
                    messages.success(request, "Village has been Deactivated.")
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_village')  

        elif action == 'delete':   
            pk = request.POST.get('id')   
            
            if not pk:
                messages.error(request, "ID cannot be empty.") 
            else: 
                village = get_object_or_404(Village, pk=pk)
                
                village.status = 2  
                village.updated_by = user 
                village.save()   
                
                # If Village has related entities, you may need to handle them here
                # Example: If Village has any related State, City, etc. you can manage those relationships
                
                states = State.objects.filter(village=village)  # Check if Village is related to any States
                
                if states.exists():
                    for state in states: 
                        pass  # Add any logic if needed, like deactivating related entities or handling specific actions.
                
                messages.success(request, "Village has been Deleted successfully.")
            
            return redirect('sa_village')
        
        return redirect('sa_village')



    def get_context_data(self, **kwargs):
        context = {
            'cities': City.objects.all(),
            'states': State.objects.all(),
            'countries': Country.objects.all(),
            'taluks': Taluk.objects.all(),
            'villages': Village.objects.all(),
        }
        context.update(kwargs)
        return context


def get_email_template(request, template_id):
    try:
        template = EmailTemplate.objects.get(id=template_id)
        data = {
            'name': template.email_template_name,
            'subject': template.email_subject,
            'content': template.email_template_content,
        }
        return JsonResponse({'status': 'success', 'data': data})
    except EmailTemplate.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Invalid request'}, status=400)

@csrf_exempt
def update_email_template(request):
    # if request.method == 'POST':
    try:
        data = json.loads(request.body)

        template_id = data.get('id')
        name = data.get('name')
        subject = data.get('subject')
        content = data.get('content')
        
        # Optional: You may want to use the user who created/updated the template
        user = request.user  # Assuming user is logged in

        # Check if the template already exists
        if template_id:
            # Update existing template
            email_template = EmailTemplate.objects.get(id=template_id)
            email_template.email_template_name = name
            email_template.email_subject = subject
            email_template.email_template_content = content
            email_template.updated_at = timezone.now()
            email_template.updated_by = user
            email_template.save()
            messages.success(request, 'Email Template Updated successfully.')
            return JsonResponse({"status": "success", "message": "Template updated successfully!"})
        
    except Exception as e:
        return JsonResponse({"status": "error", "message": f"Failed to process the request: {str(e)}"})

    # return JsonResponse({"status": "error", "message": "Invalid request method"})

class EmailTemplateView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_view_email_config': True,
                'can_add_email_config': True,
                'can_status_email_config': True,
                'can_edit_email_config': True, 
                'can_delete_email_config': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_email_config:
                return redirect('user_not_allowed') 
            
        emailT = EmailTemplate.objects.filter(
            Q(status=0) | Q(status=1),
        ).order_by('-id')

        context = {
            'emailTemplate': emailT, 
            'can_view_email_config': manage_user.can_view_email_config if manage_user else False,
            'can_add_email_config': manage_user.can_add_email_config if manage_user else False,
            'can_status_email_config': manage_user.can_status_email_config if manage_user else False,
            'can_edit_email_config': manage_user.can_edit_email_config if manage_user else False,
            'can_delete_email_config': manage_user.can_delete_email_config if manage_user else False,
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/email_config/list.html',context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                emailTemp = get_object_or_404(EmailTemplate, pk=pk)     
                status = request.POST.get('status') 

                if status == '0':
                    emailTemp.status = 0
                    emailTemp.updated_by = user
                    emailTemp.save()
                    messages.success(request, "Email Template has been Activated.") 
                elif status == '1':
                    emailTemp.status = 1  
                    emailTemp.updated_by = user
                    emailTemp.save()
                    messages.success(request, "Email Template has been Deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_email_config')   

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    emailTemp = get_object_or_404(EmailTemplate, pk=pk)   
                    emailTemp.status = 2  
                    emailTemp.updated_by = user
                    emailTemp.save()

                    messages.success(request, "Email template has been deactivated successfully.")  
                except Detection.DoesNotExist:
                    messages.error(request, "Email template not found.")  

            return redirect('sa_email_config') 
        
        elif action == 'update':
            pk = request.POST.get('update_tempalte_id')
            emailTemp = get_object_or_404(EmailTemplate, pk=pk)
            email_TName = request.POST.get('name')
            email_Subject = request.POST.get('subject')
            email_Body = request.POST.get('content')

            emailTemp.email_template_name = email_TName
            emailTemp.email_subject = email_Subject
            emailTemp.updated_by = user
            if email_Body:
                emailTemp.email_template_content = email_Body
            emailTemp.save()
            messages.success(request, 'Email Template Updated successfully.')
            return redirect('sa_email_config') 

        elif action == 'create':
            smtpInput = request.POST.get('smtp')
            hostInput = request.POST.get('host')
            portInput = request.POST.get('port')
            emailInput = request.POST.get('email')
            userInput = request.POST.get('username')
            passInput = request.POST.get('config_password')
            EmailConfig.objects.create(email=emailInput, username=userInput, password=passInput, port=portInput, smtp=smtpInput, host=hostInput, status=0, created_by=user, created_at=timezone.now())
            messages.success(request, 'Email Config created successfully.')
            return redirect('sa_email_config')

class EmailTemplateUpdate(LoginRequiredMixin,View):
    def get(self, request, user_id):
        trigger_subscription()
        E_Template = get_object_or_404(EmailTemplate, id=user_id)
        context = {
            'emailTemplate': E_Template,
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/email_config/edit.html', context)
    
class SMSConfigView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_view_sms_config': True,
                'can_status_sms_config': True, 
                'can_edit_sms_config': True, 
                'can_delete_sms_config': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_sms_config:
                return redirect('user_not_allowed') 
            

        sms = SMSConfig.objects.filter(Q(status=0) | Q(status=1))
        paginator = Paginator(sms, 10) 
        page_number = request.GET.get('page')  
        page_obj = paginator.get_page(page_number)  
        context = {
            'sms': page_obj,
            'can_view_sms_config': manage_user.can_view_sms_config if manage_user else False,
            'can_status_sms_config': manage_user.can_status_sms_config if manage_user else False, 
            'can_edit_sms_config': manage_user.can_edit_sms_config if manage_user else False,
            'can_delete_sms_config': manage_user.can_delete_sms_config if manage_user else False,
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/sms_config/list.html', context)
    
    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                sms = get_object_or_404(SMSConfig, pk=pk)     
                status = request.POST.get('status') 

                if status == '0':
                    sms.status = 0  
                    sms.updated_by = user
                    sms.save()
                    messages.success(request, "SMS Template has been Activated.") 
                elif status == '1':
                    sms.status = 1  
                    sms.updated_by = user
                    sms.save()
                    messages.success(request, "SMS Template has been Deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_sms_config')   

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    sms = get_object_or_404(SMSConfig, pk=pk)   
                    sms.status = 2  
                    sms.updated_by = user
                    sms.save()

                    messages.success(request, "SMS template has been deactivated successfully.")  
                except Detection.DoesNotExist:
                    messages.error(request, "SMS template not found.")  

            return redirect('sa_sms_config') 
        
        elif action == 'update':
            pk = request.POST.get('id')
            updateName = request.POST.get('update_name')
            updateSender = request.POST.get('update_sender')
            updateTempID = request.POST.get('update_Temp_id')
            updateCountry = request.POST.get('update_country')
            updateAPI = request.POST.get('update_api')
            updateMessage = request.POST.get('update_message')
            sms = get_object_or_404(SMSConfig, pk=pk)
            sms.sms_Template = updateName
            sms.sender_id = updateSender
            sms.Template_id = updateTempID
            sms.country_code = updateCountry
            sms.api_key = updateAPI
            sms.message_content = updateMessage
            sms.updated_by = user
            sms.save()
            return redirect('sa_sms_config') 

class GeneralSettingsView(LoginRequiredMixin, View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
         
        if user.is_superuser:
            context = {
                'can_view_general_setting': True,
                'can_edit_general_setting': True, 
            }
        else: 
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
 
            if manage_user and not manage_user.can_view_general_setting: 
                return redirect('user_not_allowed') 
            
        try:
            settings = GeneralSetting.objects.first()
        except Exception as e:
            # print(e)
            settings = None
        country = Country.objects.filter(Q(status=0) | Q(status=1))
        state = State.objects.filter(Q(status=0) | Q(status=1))
        city = City.objects.filter(Q(status=0) | Q(status=1))
        timezones = pytz.all_timezones
        # print(timezones)
        # print(datetime.now())
        context = {
            'settings': settings,
            'country': country,
            'state': state,
            'city': city,
            'can_view_general_setting': manage_user.can_view_general_setting if manage_user else False,
            'can_edit_general_setting': manage_user.can_edit_general_setting if manage_user else False, 
            'timezones': timezones,
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/general_settings/general_settings.html', context)

    def post(self, request):
        action = request.POST.get('action')
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        if action == 'update':
            try:
                settings = GeneralSetting.objects.first() 
            except Exception as e:
                # print(e)
                settings = GeneralSetting.objects.create(title=request.POST.get('title_name'))
            
            if not settings:
                settings = GeneralSetting.objects.create(title=request.POST.get('title_name'))
            # Update settings with new data
            settings.title = request.POST.get('title_name')
            settings.website = request.POST.get('website_name')
            settings.contact_person_name = request.POST.get('cont_per_name')
            settings.personal_email = request.POST.get('cont_per_email')
            settings.date_format = request.POST.get('date_format')
            settings.time_format = request.POST.get('timezone')
            settings.pincode = request.POST.get('pincode')
            settings.weather_api_key = request.POST.get('api_key')
            country_id = request.POST.get('country')
            settings.country = Country.objects.get(id=country_id)
            state_id = request.POST.get('state')
            settings.state = State.objects.get(id=state_id)
            city_id = request.POST.get('city')
            settings.city = City.objects.get(id=city_id)
            settings.area_street = request.POST.get('area', '')
            settings.flat_no = request.POST.get('flatNo', '')
            # settings.cgst = request.POST.get('cgst_per', None)
            # settings.sgst = request.POST.get('sgst_per', None)
            cgst = request.POST.get('cgst_per')
            if cgst:
                settings.cgst = cgst
            sgst = request.POST.get('sgst_per')
            if sgst:
                settings.sgst = sgst

            settings.gst_number = request.POST.get('gst_no', '')
            settings.cin = request.POST.get('cin_no', '')
            settings.updated_by = user
            # Handle file uploads for logo and favicon
            if request.FILES.get('logo'):
                settings.logo = request.FILES['logo']

            if request.POST.get('avatar_remove'):
                settings.logo = ''

            if request.FILES.get('favicon'):
                settings.favicon = request.FILES['favicon']

            if request.POST.get('fav_remove'):
                settings.favicon = ''

            # Save settings
            settings.save()
            messages.success(request, "Settings Updated Successfully.")
            timezone.activate(pytz.timezone(settings.time_format))
            return redirect('sa_general_setting')

    def update_global_settings(self, settings):
        # Update global settings for the date format and timezone
        # if settings.date_format:
        #     settings.DATE_FORMAT = settings.date_format

        # if settings.time_format:
        #     settings.TIME_ZONE = settings.time_format

        # Apply the time zone using Django's timezone utility
        timezone.activate(pytz_timezone(settings))
        
        # Optionally, set date format globally, if you are using custom format
        # settings.DATE_FORMAT = settings.date_format

def get_language_code(user_input_language):
    translator = GoogleTranslator()
    supported = translator.get_supported_languages(as_dict=True)
    lang_code = supported.get(user_input_language.lower())
    if lang_code:
        return lang_code
    else:
        return ''

class LanguageView(LoginRequiredMixin, View):
    def get(self, request):

        languages = Languages.objects.filter(
            Q(status=0) | Q(status=1),
        ).order_by('-id') 

        show_per_page = request.GET.get('show', 25)
        show_per_page = int(show_per_page)

        paginator = Paginator(languages, show_per_page)
        page_number = request.GET.get('page')
        page_obj = paginator.get_page(page_number)
        language_count = 0
        for i in page_obj:
            language_count += 1
        
        translator = GoogleTranslator()
        SUPPORTED_LANGUAGES = translator.get_supported_languages(as_dict=True)

        context = {
            'languages': page_obj,
            'show_per_page': show_per_page,
            'entries_count': language_count,
            'supportedlang': SUPPORTED_LANGUAGES,
        }

        return render(request, 'layout/partials/super_admin/layout/header/_menu/settings/languages/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')
        
        if action == 'create':
            name = request.POST.get('name')

            if not name:
                return redirect('sa_language')
            
            code = get_language_code(name)

            add_country = Languages.objects.create(name=name, language_code=code, status=0, created_by=user, created_at=timezone.now())
            add_country.save()
            messages.success(request, "Language created successfully.")
            return redirect('sa_language')

        elif action == 'update':
            pk = request.POST.get('id')
            country = get_object_or_404(Country, pk=pk)
            name = request.POST.get('name')
            translated_json = country.translate_json or {
                'name' : {}
            }

            if name:
                if name != country.name:
                    country.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
                country.updated_by = user
                country.translate_json = translated_json
                country.save()
                messages.success(request, "Country updated successfully.")
            else:
                messages.error(request, "Country name cannot be empty.")

            return redirect('sa_country') 

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                country = get_object_or_404(Languages, pk=pk)
                
                status = request.POST.get('status')

                if status == '0':
                    country.status = 0  
                    country.updated_by = user
                    country.save()
                    messages.success(request, "Language has been Activated.")
                elif status == '1':
                    country.status = 1  
                    country.updated_by = user
                    country.save()
                    messages.success(request, "Language has been Deactivated.")
                else:
                    messages.error(request, "Invalid Status Value.")
                
            return redirect('sa_language') 

        elif action == 'delete':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                country = get_object_or_404(Languages, pk=pk)
                country.status = 2 
                country.updated_by = user
                country.save()
                messages.success(request, "Language has been Deleted successfully.")
            
            return redirect('sa_language')

        return redirect('sa_language')
# ---------------------------------------------------------------- Data Management --------------------------------------------

def get_crop_type_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = CropType.objects.get(pk=pk)
    except CropType.DoesNotExist:
        return JsonResponse({'error': 'Soil Type not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)

    return JsonResponse({
        'name': name,  
        'description': description
    })

class CropTypeView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_crop_type': True,
                'can_view_crop_type': True,
                'can_edit_crop_type': True,
                'can_delete_crop_type': True, 
                'can_status_crop_type': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_crop_type:
                return redirect('user_not_allowed') 
            
        crop_types = CropType.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')

        languages = Languages.objects.filter(status=0).order_by('id') 

        context = {
            'crop_types': crop_types,
            'can_add_crop_type': manage_user.can_add_crop_type if manage_user else False,
            'can_view_crop_type': manage_user.can_view_crop_type if manage_user else False,
            'can_edit_crop_type': manage_user.can_edit_crop_type if manage_user else False,
            'can_delete_crop_type': manage_user.can_delete_crop_type if manage_user else False,
            'can_status_crop_type': manage_user.can_status_crop_type if manage_user else False,
            'messages': messages.get_messages(request),  # Pass messages to the template
            'languages': languages,
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/crop_type/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            crop_types = CropType.objects.all()


            if not name:
                context = {
                    'crop_types': crop_types,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/crop_type/list.html', context)

            if CropType.objects.filter(name=name,status__in=[0, 1]).exists():
                context = {
                    'crop_types': crop_types,
                    'error': f'Crop Type "{name}" already exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/crop_type/list.html', context)

            CropType.objects.create(name=name, description=description, status=0, created_by=user,created_at=timezone.now())
            messages.success(request, 'Crop type created successfully.')
            return redirect('sa_crop_type')

        elif action == 'update':
            pk = request.POST.get('id')
            crop_type = get_object_or_404(CropType, pk=pk)
            translated_json = crop_type.translate_json or {
                "name": {},
                "description": {}
            }
            name = request.POST.get('name')
            description = request.POST.get('description')
            language = request.POST.get('language')
            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_crop_type')

            # crop_type.name = name
            # crop_type.description = description
            crop_type.updated_by = user

            if language == "en":
                if crop_type.name != name:
                    crop_type.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                            print(e)
                            print("Error in translation")
                if crop_type.description != description:
                    crop_type.description = description
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                            translated_json["description"][lang] = translated_text
                    except Exception as e:
                            print(e)
                            print("Error in translation")
            else:
                translated_json["name"][language] = name
                if description:
                    translated_json["description"][language] = description
            crop_type.translate_json = translated_json
            crop_type.save()
            messages.success(request, 'Crop type updated successfully.')
            return redirect('sa_crop_type')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                crop_type = get_object_or_404(CropType, pk=pk)  
                
                status = request.POST.get('status')  

                if status == '0':
                    crop_type.status = 0 
                    crop_type.updated_by = user
                    crop_type.save()
                    messages.success(request, "Crop Type has been Activated.")
                elif status == '1':
                    crop_type.status = 1  
                    crop_type.updated_by = user
                    crop_type.save()
                    messages.success(request, "Crop Type has been Deactivated.")
                else:
                    messages.error(request, "Invalid status value.")
                
            return redirect('sa_crop_type')  

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                try:
                    crop_type = get_object_or_404(CropType, pk=pk)
                    crop_type.status = 2  
                    crop_type.updated_by = user
                    crop_type.save()

                    messages.success(request, "Crop Type has been Deleted successfully.")
                except CropType.DoesNotExist:
                    messages.error(request, "Crop Type not found.")

            return redirect('sa_crop_type')
        
        return redirect('sa_crop_type')

def get_crop_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = Crop.objects.get(pk=pk)
    except Crop.DoesNotExist:
        return JsonResponse({'error': 'Soil Type not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)
    
    return JsonResponse({
        'name': name,
        'description': description
    })

class CropView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_crop': True,
                'can_view_crop': True,
                'can_edit_crop': True,
                'can_delete_crop': True, 
                'can_status_crop': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_crop:
                return redirect('user_not_allowed')  
            

        crops = Crop.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')
        crop_types = CropType.objects.filter(status=0).order_by('-id')  # Still needed for dropdowns
        languages = Languages.objects.filter(status=0).order_by('id') 
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/crop/list.html', {
            'crops': crops,
            'crop_types': crop_types,
            'can_add_crop': manage_user.can_add_crop if manage_user else False,
            'can_view_crop': manage_user.can_view_crop if manage_user else False,
            'can_edit_crop': manage_user.can_edit_crop if manage_user else False,
            'can_delete_crop': manage_user.can_delete_crop if manage_user else False,
            'can_status_crop': manage_user.can_status_crop if manage_user else False,
            'languages': languages,
        })

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            # Get form data
            name = request.POST.get('name')
            croptype_id = request.POST.get('croptype')
            description = request.POST.get('description')
            img = request.FILES.get('img')  # Get the image file from the form
            crop = Crop.objects.all()

            # Check if the name is provided
            if not name:
                context = {
                    'crop': crop,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/crop/list.html', context)

            # Check if the crop already exists
            if Crop.objects.filter(name=name, status__in=[0, 1]).exists():
                context = {
                    'crop': crop,
                    'error': f'Crop Type "{name}" already exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/crop/list.html', context)

            # Ensure that both name and crop type are provided
            if name and croptype_id:
                croptype = get_object_or_404(CropType, pk=croptype_id)
                
                # If no image is uploaded, use a default image (or leave it as None)
                # if not img:
                #     img = '/path/to/default/image.png'  # Set your default image URL or leave as None

                # Create the crop object
                Crop.objects.create(
                    name=name,
                    description=description,
                    croptype=croptype,
                    status=0,
                    img=img if img else None,  # Save the image (or default if not uploaded)
                    created_by = user,created_at=timezone.now()
                )
                messages.success(request, "Crop created successfully.")
                return redirect('sa_crop')

            # If name or crop type is missing, show an error message
            messages.error(request, 'Name and Crop Type are required.')
            return redirect('sa_crop')

        elif action == 'update':
            pk = request.POST.get('id')
            crop = get_object_or_404(Crop, pk=pk)
            translated_json = crop.translate_json or {
                "name": {},
                "description": {}
            }
            name = request.POST.get('name')
            croptype_id = request.POST.get('croptype')
            description = request.POST.get('description')
            image = request.FILES.get('avatar')
            language = request.POST.get('language')

            if name and croptype_id:
                croptype = get_object_or_404(CropType, pk=croptype_id)
                crop.croptype = croptype
                crop.updated_by = user
                if language == "en":
                    if crop.name != name:
                        crop.name = name
                        try:
                            for lang in target_language:
                                translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                                translated_json["name"][lang] = translated_text
                        except Exception as e:
                            print(e)
                            print("Error in translation")
                    if crop.description != description:
                        crop.description = description
                        try:
                            for lang in target_language:
                                translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                                translated_json["description"][lang] = translated_text
                        except Exception as e:
                            print(e)
                            print("Error in translation")
                else:
                    translated_json["name"][language] = name
                    if description:
                        translated_json["description"][language] = description
                crop.translate_json = translated_json
                if image:
                    crop.img = image

                crop.save()
                messages.success(request, "Crop updated successfully.")
                return redirect('sa_crop')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                crop = get_object_or_404(Crop, pk=pk)  
                
                status = request.POST.get('status')   

                if status == '0':
                    crop.status = 0  
                    crop.updated_by = user
                    crop.save()
                    messages.success(request, "Crop has been Activated.")
                elif status == '1':
                    crop.status = 1  
                    crop.updated_by = user 
                    crop.save()
                    messages.success(request, "Crop has been Deactivated.")
                else:
                    messages.error(request, "Invalid status value.")
            
            return redirect('sa_crop')  

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk: 
                messages.error(request, "ID cannot be empty.")
            else:
                try:
                    crop = get_object_or_404(Crop, pk=pk)   
                    crop.status = 2   
                    crop.updated_by = user
                    crop.save()

                    messages.success(request, "Crop has been Deleted successfully.")
                except Crop.DoesNotExist: 
                    messages.error(request, "Crop not found.")
 
            return redirect('sa_crop')   

        return redirect('sa_crop')

def get_soil_type_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = SoilType.objects.get(pk=pk)
    except SoilType.DoesNotExist:
        return JsonResponse({'error': 'Soil Type not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)

    return JsonResponse({
        'name': name,
        'description': description
    })

class SoilTypeView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_soil_type': True,
                'can_view_soil_type': True,
                'can_edit_soil_type': True,
                'can_delete_soil_type': True, 
                'can_status_soil_type': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_soil_type:
                return redirect('user_not_allowed') 
            
        soil_types = SoilType.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')

        languages = Languages.objects.filter(status=0).order_by('id') 

        context = {
            'soil_types': soil_types,
            'can_add_soil_type': manage_user.can_add_soil_type if manage_user else False,
            'can_view_soil_type': manage_user.can_view_soil_type if manage_user else False,
            'can_edit_soil_type': manage_user.can_edit_soil_type if manage_user else False,
            'can_delete_soil_type': manage_user.can_delete_soil_type if manage_user else False,
            'can_status_soil_type': manage_user.can_status_soil_type if manage_user else False,
            'messages': messages.get_messages(request),  # Pass messages to the template
            'languages': languages,
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/soil_type/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            soil_types = SoilType.objects.all()

            if not name:
                context = {
                    'soil_types': soil_types,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/soil_type/list.html', context)

            if SoilType.objects.filter(name=name, status__in=[0,1]).exists():
                context = {
                    'soil_types': soil_types,
                    'error': f'Soil Type "{name}" already exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/soil_type/list.html', context)

            SoilType.objects.create(name=name, description=description,status=0, created_by=user,created_at=timezone.now())
            messages.success(request, 'Soil type created successfully.')
            return redirect('sa_soil_type')

        elif action == 'update':
            pk = request.POST.get('id')
            language = request.POST.get('language')
            soil_type = get_object_or_404(SoilType, pk=pk)
            translated_json = soil_type.translate_json or {
                'name' : {},
                'description': {}
            }
            name = request.POST.get('name')
            description = request.POST.get('description')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_soil_type')

            # soil_type.name = name
            # soil_type.description = description
            soil_type.updated_by = user

            if language == 'en':
                if soil_type.name != name:
                    soil_type.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
                if soil_type.description != description:
                    soil_type.description = description
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                            translated_json["description"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")

                soil_type.translate_json = translated_json
                soil_type.save()
                messages.success(request, 'Soil type updated successfully.')
                return redirect('sa_soil_type')
            else:
                translated_json["name"][language] = name
                if description:
                    translated_json["description"][language] = description
                soil_type.translate_json = translated_json
                soil_type.save()
                messages.success(request, 'Soil type updated successfully.')
                return redirect('sa_soil_type')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                soil_type = get_object_or_404(SoilType, pk=pk) 
                
                status = request.POST.get('status') 

                if status == '0':
                    soil_type.status = 0   
                    soil_type.updated_by = user
                    soil_type.save()
                    messages.success(request, "Soil Type has been Activated.") 
                elif status == '1':
                    soil_type.status = 1  
                    soil_type.updated_by = user
                    soil_type.save()
                    messages.success(request, "Soil Type has been Deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_soil_type')   

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    soil_type = get_object_or_404(SoilType, pk=pk)   
                    soil_type.status = 2  
                    soil_type.updated_by = user
                    soil_type.save()

                    messages.success(request, "Soil Type has been Deleted successfully.")  
                except SoilType.DoesNotExist:
                    messages.error(request, "Soil Type not found.")  

            return redirect('sa_soil_type') 

        return redirect('sa_soil_type')

def get_harvesting_frequency_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = HarvestingType.objects.get(pk=pk)
    except HarvestingType.DoesNotExist:
        return JsonResponse({'error': 'Data not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)

    return JsonResponse({
        'name': name,
        'description': description
    })

class HarvestingTypeView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_harvesting_type': True,
                'can_view_harvesting_type': True,
                'can_edit_harvesting_type': True,
                'can_delete_harvesting_type': True, 
                'can_status_harvesting_type': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_harvesting_type:
                return redirect('user_not_allowed')  
            
        harvesting_types = HarvestingType.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')
        
        languages = Languages.objects.filter(status=0).order_by('id') 
        
        context = {
            'languages': languages,
            'harvesting_types': harvesting_types,
            'can_add_harvesting_type': manage_user.can_add_harvesting_type if manage_user else False,
            'can_view_harvesting_type': manage_user.can_view_harvesting_type if manage_user else False,
            'can_edit_harvesting_type': manage_user.can_edit_harvesting_type if manage_user else False,
            'can_delete_harvesting_type': manage_user.can_delete_harvesting_type if manage_user else False,
            'can_status_harvesting_type': manage_user.can_status_harvesting_type if manage_user else False,
            'messages': messages.get_messages(request),  # Pass messages to the template
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/harvesting_type/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            harvesting_types = HarvestingType.objects.all()

            if not name:
                context = {
                    'harvesting_types': harvesting_types,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/harvesting_type/list.html', context)

            if HarvestingType.objects.filter(name=name, status__in=[0,1]).exists():
                context = {
                    'harvesting_types': harvesting_types,
                    'error': f'Harvesting Type Already Exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/harvesting_type/list.html', context)

            HarvestingType.objects.create(name=name, description=description,status=0, created_by=user, created_at=timezone.now())
            messages.success(request, 'Harvesting Frequency created successfully.')
            return redirect('sa_harvesting_type')

        elif action == 'update':
            pk = request.POST.get('id')
            harvesting_type = get_object_or_404(HarvestingType, pk=pk)
            translated_json = harvesting_type.translate_json or {
                "name": {},
                "description": {}
            }
            name = request.POST.get('name')
            description = request.POST.get('description')
            language = request.POST.get('language')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_harvesting_type')

            # harvesting_type.name = name
            # harvesting_type.description = description
            harvesting_type.updated_by = user

            if language == 'en':
                if harvesting_type.name != name:
                    harvesting_type.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
                if harvesting_type.description != description:
                    harvesting_type.description = description
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                            translated_json["description"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
            else:
                translated_json["name"][language] = name
                if description:
                    translated_json["description"][language] = description
            
            harvesting_type.translate_json = translated_json
            harvesting_type.save()
            messages.success(request, 'Harvesting Frequency updated successfully.')
            return redirect('sa_harvesting_type')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                harvesting_type = get_object_or_404(HarvestingType, pk=pk)  
                
                status = request.POST.get('status')  

                if status == '0':
                    harvesting_type.status = 0   
                    harvesting_type.updated_by = user
                    harvesting_type.save()
                    messages.success(request, "Harvesting Frequency has been Activated.")   
                elif status == '1':
                    harvesting_type.status = 1  
                    harvesting_type.updated_by = user
                    harvesting_type.save()
                    messages.success(request, "Harvesting Frequency has been Deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  
                    
            return redirect('sa_harvesting_type')   

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    harvesting_type = get_object_or_404(HarvestingType, pk=pk)  
                    harvesting_type.status = 2   
                    harvesting_type.updated_by = user
                    harvesting_type.save()

                    messages.success(request, "Harvesting Frequency has been Deleted successfully.")  
                except HarvestingType.DoesNotExist:
                    messages.error(request, "Harvesting Frequency not found.")   

            return redirect('sa_harvesting_type')   

        return redirect('sa_harvesting_type')

class UnitView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        units = Unit.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')

        context = {
            'units': units,
            'messages': messages.get_messages(request),  # Pass messages to the template
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/unit/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            unitdef = request.POST.get('unitdef')
            description = request.POST.get('description')
            units = Unit.objects.all()

            if not name:
                context = {
                    'units': units,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/unit/list.html', context)

            if Unit.objects.filter(name=name, status__in=[0,1]).exists():
                context = {
                    'units': units,
                    'error': f'Unit "{name}" already exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/unit/list.html', context)

            Unit.objects.create(name=name, unitdef=unitdef, description=description,status=0, created_by=user)
            messages.success(request, 'Unit created successfully.')
            return redirect('sa_unit')

        elif action == 'update':
            pk = request.POST.get('id')
            unit = get_object_or_404(Unit, pk=pk)
            name = request.POST.get('name')
            unitdef = request.POST.get('unitdef')
            description = request.POST.get('description')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_unit')

            unit.name = name
            unit.unitdef = unitdef
            unit.description = description
            unit.updated_by = user
            unit.save()
            messages.success(request, 'Unit updated successfully.')
            return redirect('sa_unit')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                unit = get_object_or_404(Unit, pk=pk)   
                
                status = request.POST.get('status')   

                if status == '0':
                    unit.status = 0  
                    unit.updated_by = user 
                    unit.save()
                    messages.success(request, "Unit has been Activated.")  
                elif status == '1':
                    unit.status = 1  
                    unit.updated_by = user
                    unit.save()
                    messages.success(request, "Unit has been Deactivated.")   
                else:
                    messages.error(request, "Invalid status value.")   
                    
            return redirect('sa_unit')   

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")   
            else:
                try:
                    unit = get_object_or_404(Unit, pk=pk)   
                    unit.status = 2  
                    unit.updated_by = user 
                    unit.save()

                    messages.success(request, "Unit has been Deleted successfully.")   
                except Unit.DoesNotExist:
                    messages.error(request, "Unit not found.")   

            return redirect('sa_unit')   

        return redirect('sa_unit')

def get_land_unit_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = LandUnit.objects.get(pk=pk)
    except LandUnit.DoesNotExist:
        return JsonResponse({'error': 'Soil Type not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        slugname = soil_type.landunitdef
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        slugname = soil_type.get_translated_value('landunitdef', language)
        description = soil_type.get_translated_value('description', language)

    return JsonResponse({
        'name': name,
        'slug_name': slugname,
        'description': description
    })

class LandUnitView(LoginRequiredMixin,View):
    def get(self, request):
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_land_unit': True,
                'can_view_land_unit': True,
                'can_edit_land_unit': True,
                'can_delete_land_unit': True, 
                'can_status_land_unit': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_land_unit:
                return redirect('user_not_allowed')  

        land_unit = LandUnit.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')

        languages = Languages.objects.filter(status=0).order_by('id')

        context = {
            'land_unit': land_unit,
            'can_add_land_unit': manage_user.can_add_land_unit if manage_user else False,
            'can_view_land_unit': manage_user.can_view_land_unit if manage_user else False,
            'can_edit_land_unit': manage_user.can_edit_land_unit if manage_user else False,
            'can_delete_land_unit': manage_user.can_delete_land_unit if manage_user else False,
            'can_status_land_unit': manage_user.can_status_land_unit if manage_user else False,
            'messages': messages.get_messages(request),  # Pass messages to the template
            'languages': languages,
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/land_unit/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            landunitdef = request.POST.get('landunitdef')
            description = request.POST.get('description')
            land_unit = LandUnit.objects.all()

            if not name:
                context = {
                    'land_unit': land_unit,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/land_unit/list.html', context)

            if LandUnit.objects.filter(name=name, status__in=[0, 1]).exists():
                context = {
                    'land_unit': land_unit,
                    'error': f'Land Unit "{name}" already exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/land_unit/list.html', context)

            LandUnit.objects.create(name=name, landunitdef=landunitdef, description=description,status=0,created_by=user,created_at=timezone.now())
            messages.success(request, 'Land Unit created successfully.')
            return redirect('sa_land_unit')

        elif action == 'update':
            pk = request.POST.get('id')
            land_unit = get_object_or_404(LandUnit, pk=pk)
            translated_json = land_unit.translate_json or {
                "name": {},
                "slug_name": {},
                "description": {}
            }
            name = request.POST.get('name')
            landunitdef = request.POST.get('landunitdef')
            description = request.POST.get('description')
            language = request.POST.get('language')
            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_land_unit')
            
            if language == 'en':
                if land_unit.name != name:
                    land_unit.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
                if land_unit.description != description:
                    land_unit.description = description
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                            translated_json["description"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
                if land_unit.landunitdef != landunitdef:
                    land_unit.landunitdef = landunitdef
                try:
                    for lang in target_language:
                        translated_text = GoogleTranslator(source='auto', target=lang).translate(landunitdef)
                        translated_json["slug_name"][lang] = translated_text
                except Exception as e:
                    print(e)
                    print("Error in translation")
            else:
                translated_json["name"][language] = name
                translated_json["slug_name"][language] = landunitdef
                if description:
                    translated_json["description"][language] = description
            
            land_unit.updated_by = user
            land_unit.translate_json = translated_json
            land_unit.save()
            messages.success(request, 'Land Unit updated successfully.')
            return redirect('sa_land_unit')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                land_unit = get_object_or_404(LandUnit, pk=pk) 
                
                status = request.POST.get('status') 

                if status == '0':
                    land_unit.status = 0   
                    land_unit.updated_by = user
                    land_unit.save()
                    messages.success(request, "Land Unit has been Activated.") 
                elif status == '1':
                    land_unit.status = 1  
                    land_unit.updated_by = user
                    land_unit.save()
                    messages.success(request, "Land Unit has been Deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_land_unit')   

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    land_unit = get_object_or_404(LandUnit, pk=pk)   
                    land_unit.status = 2  
                    land_unit.updated_by = user
                    land_unit.save()
                    messages.success(request, "Land Unit has been Deleted successfully.")  
                except LandUnit.DoesNotExist:
                    messages.error(request, "Land Unit not found.")  

            return redirect('sa_land_unit') 

        return redirect('sa_land_unit')

class QualityView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_quality': True,
                'can_view_quality': True,
                'can_edit_quality': True,
                'can_delete_quality': True, 
                'can_status_quality': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_quality:
                return redirect('user_not_allowed')
            
        quality = Quality.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')

        context = {
            'quality': quality,
            'can_add_quality': manage_user.can_add_quality if manage_user else False,
            'can_view_quality': manage_user.can_view_quality if manage_user else False,
            'can_edit_quality': manage_user.can_edit_quality if manage_user else False,
            'can_delete_quality': manage_user.can_delete_quality if manage_user else False,
            'can_status_quality': manage_user.can_status_quality if manage_user else False,
            'messages': messages.get_messages(request),  # Pass messages to the template
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/quality/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            quality = Quality.objects.all()

            if not name:
                context = {
                    'quality': quality,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/quality/list.html', context)

            if Quality.objects.filter(name=name, status__in=[0, 1]).exists():
                context = {
                    'quality': quality,
                    'error': f'Quality "{name}" already exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/quality/list.html', context)

            Quality.objects.create(name=name, description=description,status=0,created_by=user,created_at=timezone.now())
            messages.success(request, 'Quality created successfully.')
            return redirect('sa_quality')

        elif action == 'update':
            pk = request.POST.get('id')
            quality = get_object_or_404(Quality, pk=pk)
            name = request.POST.get('name')
            description = request.POST.get('description')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_quality')

            quality.name = name
            quality.description = description
            quality.updated_by = user
            quality.save()
            messages.success(request, 'Quality updated successfully.')
            return redirect('sa_quality')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                quality = get_object_or_404(Quality, pk=pk) 
                
                status = request.POST.get('status') 

                if status == '0':
                    quality.status = 0   
                    quality.updated_by = user
                    quality.save()
                    messages.success(request, "Quality has been Activated.") 
                elif status == '1':
                    quality.status = 1  
                    quality.updated_by = user
                    quality.save()
                    messages.success(request, "Quality has been Deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_quality')   

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    quality = get_object_or_404(Quality, pk=pk)   
                    quality.status = 2  
                    quality.updated_by = user
                    quality.save()

                    messages.success(request, "Quality has been Deleted successfully.")  
                except Quality.DoesNotExist:
                    messages.error(request, "Quality not found.")  

            return redirect('sa_quality') 

        return redirect('sa_quality')

def get_exp_catego_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = ExpensesCategory.objects.get(pk=pk)
    except ExpensesCategory.DoesNotExist:
        return JsonResponse({'error': 'Soil Type not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)
    
    return JsonResponse({
        'name': name,
        'description': description
    })

class ExpensesCategoryView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_expense_category': True,
                'can_view_expense_category': True,
                'can_edit_expense_category': True,
                'can_delete_expense_category': True, 
                'can_status_expense_category': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_expense_category:
                return redirect('user_not_allowed') 


        expenses_category = ExpensesCategory.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')

        languages = Languages.objects.filter(status=0).order_by('id') 
        context = {
            'languages': languages,
            'expenses_category': expenses_category,
            'can_add_expense_category': manage_user.can_add_expense_category if manage_user else False,
            'can_view_expense_category': manage_user.can_view_expense_category if manage_user else False,
            'can_edit_expense_category': manage_user.can_edit_expense_category if manage_user else False,
            'can_delete_expense_category': manage_user.can_delete_expense_category if manage_user else False,
            'can_status_expense_category': manage_user.can_status_expense_category if manage_user else False,
            'messages': messages.get_messages(request),  # Pass messages to the template
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/expenses_category/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            expenses_category = ExpensesCategory.objects.all()

            if not name:
                context = {
                    'expenses_category': expenses_category,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/expenses_category/list.html', context)

            if ExpensesCategory.objects.filter(name=name, status__in=[0, 1]).exists():
                context = {
                    'expenses_category': expenses_category,
                    'error': f'Expenses Category "{name}" already exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/expenses_category/list.html', context)

            ExpensesCategory.objects.create(name=name, description=description,status=0,created_by=user,created_at=timezone.now())
            messages.success(request, 'Expenses Category created successfully.')
            return redirect('sa_expenses_category')

        elif action == 'update':
            pk = request.POST.get('id')
            expenses_category = get_object_or_404(ExpensesCategory, pk=pk)
            translated_json = expenses_category.translate_json or {
                "name": {},
                "description": {}
            }
            name = request.POST.get('name')
            description = request.POST.get('description')
            language = request.POST.get('language')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_expenses_category')

            # expenses_category.name = name
            # expenses_category.description = description
            expenses_category.updated_by = user
            if language == "en":
                if expenses_category.name != name:
                    expenses_category.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
                if expenses_category.description != description:
                    expenses_category.description = description
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                            translated_json["description"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
            else:
                translated_json["name"][language] = name
                if description:
                    translated_json["description"][language] = description  
            expenses_category.translate_json = translated_json
            expenses_category.save()
            messages.success(request, 'Expenses Category updated successfully.')
            return redirect('sa_expenses_category')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                expenses_category = get_object_or_404(ExpensesCategory, pk=pk) 
                
                status = request.POST.get('status') 

                if status == '0':
                    expenses_category.status = 0   
                    expenses_category.updated_by = user
                    expenses_category.save()
                    messages.success(request, "Expenses Category has been Activated.") 
                elif status == '1':
                    expenses_category.status = 1  
                    expenses_category.updated_by = user
                    expenses_category.save()
                    messages.success(request, "Expenses Category has been Deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_expenses_category')   

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    expenses_category = get_object_or_404(ExpensesCategory, pk=pk)   
                    expenses_category.status = 2  
                    expenses_category.updated_by = user
                    expenses_category.save()

                    messages.success(request, "Expenses Category has been Deleted successfully.")  
                except ExpensesCategory.DoesNotExist:
                    messages.error(request, "Expenses Category not found.")  

            return redirect('sa_expenses_category') 

        return redirect('sa_expenses_category')

def get_exp_typ_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = Expenses.objects.get(pk=pk)
    except Expenses.DoesNotExist:
        return JsonResponse({'error': 'Soil Type not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)
    
    return JsonResponse({
        'name': name,
        'description': description
    })

class ExpensesView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_expense': True,
                'can_view_expense': True,
                'can_edit_expense': True,
                'can_delete_expense': True, 
                'can_status_expense': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_expense:
                return redirect('user_not_allowed') 
            
        expenses = Expenses.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')
        expenses_category = ExpensesCategory.objects.filter(status=0)  # Still needed for dropdowns
        languages = Languages.objects.filter(status=0).order_by('id') 

        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/expenses/list.html', {
            'languages': languages,
            'expenses': expenses,
            'expenses_category': expenses_category,
            'can_add_expense': manage_user.can_add_expense if manage_user else False,
            'can_view_expense': manage_user.can_view_expense if manage_user else False,
            'can_edit_expense': manage_user.can_edit_expense if manage_user else False,
            'can_delete_expense': manage_user.can_delete_expense if manage_user else False,
            'can_status_expense': manage_user.can_status_expense if manage_user else False,
        })

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            category_id = request.POST.get('croptype')
            description = request.POST.get('description')
            expenses = Expenses.objects.all()

            if not name:
                context = {
                    'expenses': expenses,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/expenses/list.html', context)

            if Expenses.objects.filter(name=name, status__in=[0, 1]).exists():
                context = {
                    'expenses': expenses,
                    'error': f'Expenses "{name}" already exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/expenses/list.html', context)

            if name and category_id:
                category = get_object_or_404(ExpensesCategory, pk=category_id)
                # Change 'category' to 'expenses_category' to match the model field name
                Expenses.objects.create(name=name, description=description, expenses_category=category, status=0,created_by=user)
                messages.success(request, "Expenses created successfully.")
                return redirect('sa_expenses')

            messages.error(request, 'Name and Expenses Type are required.')
            return redirect('sa_expenses')

        elif action == 'update':
            pk = request.POST.get('id')
            expenses = get_object_or_404(Expenses, pk=pk)
            translated_json = expenses.translate_json or {
                "name": {},
                "description": {}
            }
            name = request.POST.get('name')
            expenses_category_id = request.POST.get('croptype')
            description = request.POST.get('description')
            language = request.POST.get('language')

            if name and expenses_category_id:
                expenses_category = get_object_or_404(ExpensesCategory, pk=expenses_category_id)
                # expenses.name = name
                # expenses.description = description
                expenses.expenses_category = expenses_category
                expenses.updated_by = user
                if language == "en":
                    if expenses.name != name:
                        expenses.name = name
                        try:
                            for lang in target_language:
                                translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                                translated_json["name"][lang] = translated_text
                        except Exception as e:
                            print(e)
                            print("Error in translation")
                    if expenses.description != description:
                        expenses.description = description
                        try:
                            for lang in target_language:
                                translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                                translated_json["description"][lang] = translated_text
                        except Exception as e:
                            print(e)
                            print("Error in translation")
                else:
                    translated_json["name"][language] = name
                    if description:
                        translated_json["description"][language] = description   
                expenses.translate_json = translated_json

                expenses.save()
                messages.success(request, "Expenses updated successfully.")
                return redirect('sa_expenses')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                crop = get_object_or_404(Expenses, pk=pk)  
                
                status = request.POST.get('status')   

                if status == '0':
                    crop.status = 0  
                    crop.updated_by = user
                    crop.save()
                    messages.success(request, "Expenses has been activated.")
                elif status == '1':
                    crop.status = 1   
                    crop.updated_by = user
                    crop.save()
                    messages.success(request, "Expenses has been deactivated.")
                else:
                    messages.error(request, "Invalid status value.")
            
            return redirect('sa_expenses')  

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk: 
                messages.error(request, "ID cannot be empty.")
            else:
                try:
                    crop = get_object_or_404(Expenses, pk=pk)   
                    crop.status = 2   
                    crop.updated_by = user
                    crop.save()
                    messages.success(request, "Expenses has been Deleted successfully.")
                except Expenses.DoesNotExist: 
                    messages.error(request, "Expenses not found.")
            return redirect('sa_expenses')   
        
        return redirect('sa_expenses')

def get_reasons_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = Reasons.objects.get(pk=pk)
    except Reasons.DoesNotExist:
        return JsonResponse({'error': 'data not found'}, status=404)

    if language == 'en':
        name = soil_type.name
    else:
        name = soil_type.get_translated_value('name', language)
    
    return JsonResponse({
        'name': name
    })

class DetectionView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_detection': True,
                'can_view_detection': True,
                'can_edit_detection': True,
                'can_delete_detection': True, 
                'can_status_detection': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_detection:
                return redirect('user_not_allowed') 

        detections = Reasons.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')

        languages = Languages.objects.filter(status=0).order_by('id')
        context = {
            'languages': languages,
            'detections': detections,
            'can_add_detection': manage_user.can_add_detection if manage_user else False,
            'can_view_detection': manage_user.can_view_detection if manage_user else False,
            'can_edit_detection': manage_user.can_edit_detection if manage_user else False,
            'can_delete_detection': manage_user.can_delete_detection if manage_user else False,
            'can_status_detection': manage_user.can_status_detection if manage_user else False,
            'messages': messages.get_messages(request),  # Pass messages to the template
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/detection/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            detections = Reasons.objects.all()

            if not name:
                context = {
                    'detections': detections,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/detection/list.html', context)

            if Reasons.objects.filter(name=name,status__in=[0,1]).exists():
                context = {
                    'detections': detections,
                    'error': f'Detection Name Already Exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/detection/list.html', context)

            Reasons.objects.create(name=name, description=description,status=0,created_by=user, created_at=timezone.now())
            messages.success(request, 'Sales Deduction created successfully.')
            return redirect('sa_deduction')

        elif action == 'update':
            pk = request.POST.get('id')
            soil_type = get_object_or_404(Reasons, pk=pk)
            translated_json = soil_type.translate_json or {
                "name": {}
            }
            name = request.POST.get('name')
            description = request.POST.get('description')
            language = request.POST.get('language')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_deduction')
            
            if language == 'en':
                if soil_type.name != name:
                    soil_type.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
            else:
                translated_json["name"][language] = name

            soil_type.description = description
            soil_type.translate_json = translated_json
            soil_type.updated_by = user
            soil_type.save()
            messages.success(request, 'Sales Deduction updated successfully.')
            return redirect('sa_deduction')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                soil_type = get_object_or_404(Reasons, pk=pk) 
                
                status = request.POST.get('status') 

                if status == '0':
                    soil_type.status = 0  
                    soil_type.updated_by = user 
                    soil_type.save()
                    messages.success(request, "Sales Deduction has been activated.") 
                elif status == '1':
                    soil_type.status = 1  
                    soil_type.updated_by = user
                    soil_type.save()
                    messages.success(request, "Sales Deduction has been deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_deduction')   

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    soil_type = get_object_or_404(Reasons, pk=pk)   
                    soil_type.status = 2  
                    soil_type.updated_by = user
                    soil_type.save()

                    messages.success(request, "Sales Deduction has been Deleted successfully.")  
                except Reasons.DoesNotExist:
                    messages.error(request, "Sales Deduction not found.")  

            return redirect('sa_deduction') 

        return redirect('sa_deduction')

def get_product_unit_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = AreaUnit.objects.get(pk=pk)
    except AreaUnit.DoesNotExist:
        return JsonResponse({'error': 'Soil Type not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        slugname = soil_type.areaunitdef
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        slugname = soil_type.get_translated_value('areaunitdef', language)
        description = soil_type.get_translated_value('description', language)

    return JsonResponse({
        'name': name,
        'slug_name': slugname,
        'description': description
    })

class AreaUnitView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_area_unit': True,
                'can_view_area_unit': True,
                'can_edit_area_unit': True,
                'can_delete_area_unit': True, 
                'can_status_area_unit': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_area_unit:
                return redirect('user_not_allowed') 
            
        areaunits = AreaUnit.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')

        languages = Languages.objects.filter(status=0).order_by('id') 
        context = {
            'areaunits': areaunits,
            'can_add_area_unit': manage_user.can_add_area_unit if manage_user else False,
            'can_view_area_unit': manage_user.can_view_area_unit if manage_user else False,
            'can_edit_area_unit': manage_user.can_edit_area_unit if manage_user else False,
            'can_delete_area_unit': manage_user.can_delete_area_unit if manage_user else False,
            'can_status_area_unit': manage_user.can_status_area_unit if manage_user else False,
            'messages': messages.get_messages(request),  # Pass messages to the template
            'languages': languages,
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/area_unit/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            areaunitdef = request.POST.get('areaunitdef')
            description = request.POST.get('description')
            area_units = AreaUnit.objects.all()

            # Check if the Area Unit name is provided
            if not name:
                context = {
                    'area_units': area_units,
                    'error': 'Product Unit Name is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/area_unit/list.html', context)

            # Check if the Area Unit already exists
            if AreaUnit.objects.filter(name=name, status__in=[0, 1]).exists():
                context = {
                    'area_units': area_units,
                    'error': f'Product Unit "{name}" already exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/area_unit/list.html', context)

            # Create a new Area Unit
            AreaUnit.objects.create(name=name, areaunitdef=areaunitdef, description=description, status=0,created_by=user,created_at=timezone.now())
            messages.success(request, 'Product Unit created successfully.')
            return redirect('sa_areaunit')

        elif action == 'update':
            pk = request.POST.get('id')
            language = request.POST.get('language')
            areaunit = get_object_or_404(AreaUnit, pk=pk)
            translated_json = areaunit.translate_json or {
                "name": {},
                "slug_name": {},
                "description": {}
            }
            name = request.POST.get('name')
            areaunitdef = request.POST.get('areaunitdef')
            description = request.POST.get('description')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_areaunit')

            # areaunit.name = name
            # areaunit.areaunitdef = areaunitdef
            # areaunit.description = description
            areaunit.updated_by = user
            if language == 'en':
                if areaunit.name != name:
                    areaunit.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
                if areaunit.description != description:
                    areaunit.description = description
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                            translated_json["description"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
                if areaunit.areaunitdef != areaunitdef:
                    areaunit.areaunitdef = areaunitdef
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(areaunitdef)
                            translated_json["slug_name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
            else:
                translated_json["name"][language] = name
                translated_json["slug_name"][language] = areaunitdef
                if description:
                    translated_json["description"][language] = description
            
            areaunit.translate_json = translated_json
            areaunit.save()
            messages.success(request, 'Product Unit updated successfully.')
            return redirect('sa_areaunit')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                areaunit = get_object_or_404(AreaUnit, pk=pk)   
                
                status = request.POST.get('status')   

                if status == '0':
                    areaunit.status = 0   
                    areaunit.updated_by = user
                    areaunit.save()
                    messages.success(request, "Product Unit has been activated.")  
                elif status == '1':
                    areaunit.status = 1  
                    areaunit.updated_by = user
                    areaunit.save()
                    messages.success(request, "Product Unit has been deactivated.")   
                else:
                    messages.error(request, "Invalid status value.")   
                    
            return redirect('sa_areaunit')   

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")   
            else:
                try:
                    areaunit = get_object_or_404(AreaUnit, pk=pk)   
                    areaunit.status = 2   
                    areaunit.updated_by = user
                    areaunit.save()

                    messages.success(request, "Product Unit has been Deleted successfully.")   
                except AreaUnit.DoesNotExist:
                    messages.error(request, "Product Unit not found.")   

            return redirect('sa_areaunit')   
        
        return redirect('sa_areaunit')

def check_areaunit_name_exists(request):
    if request.method == "POST":
        name = request.POST.get('name')
        exists = AreaUnit.objects.filter(name=name).exists()
        return JsonResponse({'exists': exists})

def get_product_type_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = ProductType.objects.get(pk=pk)
    except ProductType.DoesNotExist:
        return JsonResponse({'error': 'Soil Type not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)
    
    return JsonResponse({
        'name': name,
        'description': description
    })

class ProductTypeView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_product_type': True,
                'can_view_product_type': True,
                'can_edit_product_type': True,
                'can_delete_product_type': True, 
                'can_status_product_type': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_product_type:
                return redirect('user_not_allowed') 
            
        product_types = ProductType.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')

        languages = Languages.objects.filter(status=0).order_by('id') 
        context = {
            'languages': languages,
            'product_types': product_types,
            'can_add_product_type': manage_user.can_add_product_type if manage_user else False,
            'can_view_product_type': manage_user.can_view_product_type if manage_user else False,
            'can_edit_product_type': manage_user.can_edit_product_type if manage_user else False,
            'can_delete_product_type': manage_user.can_delete_product_type if manage_user else False,
            'can_status_product_type': manage_user.can_status_product_type if manage_user else False,
            'messages': messages.get_messages(request),  
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/product_type/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            product_types = ProductType.objects.all()

            if not name:
                context = {
                    'product_types': product_types,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/product_type/list.html', context)

            if ProductType.objects.filter(name=name, status__in=[0, 1]).exists():
                context = {
                    'product_types': product_types,
                    'error': f'Product Type "{name}" already exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/product_type/list.html', context)

            ProductType.objects.create(name=name, description=description, status=0,created_by=user,created_at=timezone.now())  # Assuming status defaults to 0
            messages.success(request, 'Product Type created successfully.')
            return redirect('sa_product_type')

        elif action == 'update':
            # Get the id from the form
            pk = request.POST.get('id')

            # Ensure the id is valid (must be a positive integer)
            if not pk or not pk.isdigit():
                messages.error(request, 'Invalid Product Type ID.')
                return redirect('sa_product_type')

            # Fetch the ProductType object or return a 404 error if not found
            product_type = get_object_or_404(ProductType, pk=int(pk))
            translated_json = product_type.translate_json or {
                "name": {},
                "description": {}
            }
            # Get other fields from the form
            name = request.POST.get('name')
            description = request.POST.get('description')
            language = request.POST.get('language')
            # Validate the name field
            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_product_type')

            # Update the ProductType object
            # product_type.name = name
            # product_type.description = description
            product_type.updated_by = user

            if language == "en":
                if product_type.name != name:
                    product_type.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
                if product_type.description != description:
                    product_type.description = description
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                            translated_json["description"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
            else:
                translated_json["name"][language] = name
                if description:
                    translated_json["description"][language] = description 
            product_type.translate_json = translated_json

            product_type.save()

            messages.success(request, 'Product Type updated successfully.')
            return redirect('sa_product_type')

        elif action == 'update_status':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                product_type = get_object_or_404(ProductType, pk=pk)

                status = request.POST.get('status')

                if status == '0':
                    product_type.status = 0
                    product_type.updated_by = user
                    product_type.save()
                    messages.success(request, "Product Type has been activated.")
                elif status == '1':
                    product_type.status = 1
                    product_type.updated_by = user
                    product_type.save()
                    messages.success(request, "Product Type has been deactivated.")
                else:
                    messages.error(request, "Invalid status value.")

            return redirect('sa_product_type')

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                try:
                    product_type = get_object_or_404(ProductType, pk=pk)
                    product_type.status = 2  
                    product_type.updated_by = user
                    product_type.save()

                    messages.success(request, "Product Type has been deleted successfully.")
                except ProductType.DoesNotExist:
                    messages.error(request, "Product Type not found.")

            return redirect('sa_product_type')

        return redirect('sa_product_type')


def get_document_category_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = DocumentCategory.objects.get(pk=pk)
    except DocumentCategory.DoesNotExist:
        return JsonResponse({'error': 'data not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)
    
    return JsonResponse({
        'name': name,
        'description': description
    })

class DocumentCategoryView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_document_category': True,
                'can_view_document_category': True,
                'can_edit_document_category': True,
                'can_delete_document_category': True, 
                'can_status_document_category': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_document_category:
                return redirect('user_not_allowed')  
            
        document_category = DocumentCategory.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')

        languages = Languages.objects.filter(status=0).order_by('id') 
        context = {
            'languages': languages,
            'document_category': document_category,
            'can_add_document_category': manage_user.can_add_document_category if manage_user else False,
            'can_view_document_category': manage_user.can_view_document_category if manage_user else False,
            'can_edit_document_category': manage_user.can_edit_document_category if manage_user else False,
            'can_delete_document_category': manage_user.can_delete_document_category if manage_user else False,
            'can_status_document_category': manage_user.can_status_document_category if manage_user else False,
            'messages': messages.get_messages(request),  # Pass messages to the template
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/document_category/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            doctype = request.POST.get('doctype')
            description = request.POST.get('description')
            document_category = DocumentCategory.objects.all()

            if not name:
                context = {
                    'document_category': document_category,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/document_category/list.html', context)

            if DocumentCategory.objects.filter(name=name, status__in=[0,1]).exists():
                context = {
                    'document_category': document_category,
                    'error': f'Document Category Already Exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/document_category/list.html', context)

            DocumentCategory.objects.create(name=name,doctype = int(doctype), description=description,status=0, created_by=user)

            messages.success(request, 'Document Category Created Successfully.')
            return redirect('sa_document_category')

        elif action == 'update':
            pk = request.POST.get('id')
            doctype = request.POST.get('doctype')
            document_category = get_object_or_404(DocumentCategory, pk=pk)
            translated_json = document_category.translate_json or {
                "name": {},
                "description": {}
            }
            name = request.POST.get('name')
            description = request.POST.get('description')
            language = request.POST.get('language')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_document_category')

            # document_category.name = name
            # document_category.description = description
            document_category.updated_by = user
            document_category.doctype = int(doctype)
            if language == "en":
                if document_category.name != name:
                    document_category.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
                if document_category.description != description:
                    document_category.description = description
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                            translated_json["description"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
            else:
                translated_json["name"][language] = name
                if description:
                    translated_json["description"][language] = description 
               
            document_category.translate_json = translated_json
            document_category.save()
            messages.success(request, 'Document Category Updated Successfully.')
            return redirect('sa_document_category')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                document_category = get_object_or_404(DocumentCategory, pk=pk)  
                
                status = request.POST.get('status')  

                if status == '0':
                    document_category.status = 0   
                    document_category.updated_by = user
                    document_category.save()
                    messages.success(request, "Document Category Has Been Activated.")   
                elif status == '1':
                    document_category.status = 1  
                    document_category.updated_by = user
                    document_category.save()
                    messages.success(request, "Document Category Has Been Deactivated.")  
                else:
                    messages.error(request, "Invalid Status Value.")  
                    
            return redirect('sa_document_category')   

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    document_category = get_object_or_404(DocumentCategory, pk=pk)  
                    document_category.status = 2   
                    document_category.updated_by = user
                    document_category.save()

                    messages.success(request, "Document Category has been Deleted Successfully.")  
                except DocumentCategory.DoesNotExist:
                    messages.error(request, "Document Category Not Found.")   

            return redirect('sa_document_category')   

        return redirect('sa_document_category')

def get_schedule_type_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = ScheduleActivityType.objects.get(pk=pk)
    except ScheduleActivityType.DoesNotExist:
        return JsonResponse({'error': 'data not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)
    
    return JsonResponse({
        'name': name,
        'description': description
    })

class ScheduleActivityTypeView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_schedule_activity_type': True,
                'can_view_schedule_activity_type': True,
                'can_edit_schedule_activity_type': True,
                'can_delete_schedule_activity_type': True, 
                'can_status_schedule_activity_type': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_schedule_activity_type:
                return redirect('user_not_allowed') 
            
        schedule_activity_types = ScheduleActivityType.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')

        languages = Languages.objects.filter(status=0).order_by('id')
        context = {
            'languages': languages,
            'schedule_activity_types': schedule_activity_types,
            'can_add_schedule_activity_type': manage_user.can_add_schedule_activity_type if manage_user else False,
            'can_view_schedule_activity_type': manage_user.can_view_schedule_activity_type if manage_user else False,
            'can_edit_schedule_activity_type': manage_user.can_edit_schedule_activity_type if manage_user else False,
            'can_delete_schedule_activity_type': manage_user.can_delete_schedule_activity_type if manage_user else False,
            'can_status_schedule_activity_type': manage_user.can_status_schedule_activity_type if manage_user else False,
            'messages': messages.get_messages(request),  # Pass messages to the template
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/schedule_activity_type/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            schedule_activity_types = ScheduleActivityType.objects.all()

            if not name:
                context = {
                    'schedule_activity_types': schedule_activity_types,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/schedule_activity_type/list.html', context)

            if ScheduleActivityType.objects.filter(name=name, status__in=[0,1]).exists():
                context = {
                    'schedule_activity_types': schedule_activity_types,
                    'error': f'Schedule Activity Type "{name}" already exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/schedule_activity_type/list.html', context)

            ScheduleActivityType.objects.create(name=name, description=description,status=0,created_by=user, created_at=timezone.now())
            messages.success(request, 'Schedule Activity Type created successfully.')
            return redirect('sa_schedule_activity_type')

        elif action == 'update':
            pk = request.POST.get('id')
            schedule_activity_type = get_object_or_404(ScheduleActivityType, pk=pk)
            translated_json = schedule_activity_type.translate_json or {
                'name' : {},
                "description": {}
            }
            name = request.POST.get('name')
            description = request.POST.get('description')
            language = request.POST.get('language')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_schedule_activity_type')
            
            if language == "en":
                if schedule_activity_type.name != name:
                    schedule_activity_type.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
                if schedule_activity_type.description != description:
                    schedule_activity_type.description = description
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                            translated_json["description"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
            else:
                translated_json["name"][language] = name
                if description:
                    translated_json["description"][language] = description 

            schedule_activity_type.updated_by = user
            schedule_activity_type.translate_json = translated_json
            schedule_activity_type.save()
            messages.success(request, 'Schedule Activity Type updated successfully.')
            return redirect('sa_schedule_activity_type')
        
        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                # Update the model from HarvestingType to ScheduleActivityType
                schedule_activity_type = get_object_or_404(ScheduleActivityType, pk=pk)  

                status = request.POST.get('status')  

                if status == '0':
                    schedule_activity_type.status = 0   
                    schedule_activity_type.updated_by = user
                    schedule_activity_type.save()
                    messages.success(request, "Schedule Activity Type has been activated.")   
                elif status == '1':
                    schedule_activity_type.status = 1  
                    schedule_activity_type.updated_by = user
                    schedule_activity_type.save()
                    messages.success(request, "Schedule Activity Type has been deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  

            return redirect('sa_schedule_activity_type') 

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    schedule_activity_type = get_object_or_404(ScheduleActivityType, pk=pk)  
                    schedule_activity_type.status = 2  
                    schedule_activity_type.updated_by = user
                    schedule_activity_type.save()

                    messages.success(request, "Schedule Activity Type has been Deleted successfully.")  
                except ScheduleActivityType.DoesNotExist:
                    messages.error(request, "Schedule Activity Type not found.")  

            return redirect('sa_schedule_activity_type') 
        
        return redirect('sa_schedule_activity_type')


# ----------------------------------------------------------------------------- Tool Management -----------------------------------------

class ToolCategoryView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_tool_category': True,
                'can_view_tool_category': True,
                'can_edit_tool_category': True,
                'can_delete_tool_category': True, 
                'can_status_tool_category': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_tool_category:
                return redirect('user_not_allowed') 
            
        tool_categories = ToolCategory.objects.filter(Q(status=0) | Q(status=1)).order_by('-id')
        context = {
            'tool_categories': tool_categories,
            'can_add_tool_category': manage_user.can_add_tool_category if manage_user else False,
            'can_view_tool_category': manage_user.can_view_tool_category if manage_user else False,
            'can_edit_tool_category': manage_user.can_edit_tool_category if manage_user else False,
            'can_delete_tool_category': manage_user.can_delete_tool_category if manage_user else False,
            'can_status_tool_category': manage_user.can_status_tool_category if manage_user else False,

            'messages': messages.get_messages(request),  # Pass messages to the template
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/tools_category/list.html', context)
   
    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            tool_categories = ToolCategory.objects.all()

            # Validate name
            if not name:
                context = {
                    'tool_categories': tool_categories,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/tools_category/list.html', context)

            # Check for duplicates
            if ToolCategory.objects.filter(name=name, status__in=[0,1]).exists():
                context = {
                    'tool_categories': tool_categories,
                    'error': 'Tool Category Already Exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/tools_category/list.html', context)

            # Create the Tool Category
            ToolCategory.objects.create(name=name, description=description,status=0,created_by=user)
            messages.success(request, 'Tool category created successfully.')
            return redirect('sa_manage_tools_category')

        elif action == 'update':
            # print(request.POST)  
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, 'No ID provided for update.')
                return redirect('sa_manage_tools_category')
            
            tool_category = get_object_or_404(ToolCategory, pk=pk)
            name = request.POST.get('name')
            description = request.POST.get('description')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_manage_tools_category')

            tool_category.name = name
            tool_category.description = description
            tool_category.updated_by = user
            tool_category.save()
            
            messages.success(request, 'Tool category updated successfully.')
            return redirect('sa_manage_tools_category')
        
        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                # Update the model from EmployeeType to ToolCategory
                tool_category = get_object_or_404(ToolCategory, pk=pk)  

                status = request.POST.get('status')  

                if status == '0':
                    tool_category.status = 0   
                    tool_category.updated_by = user
                    tool_category.save()
                    messages.success(request, "Tool Category has been activated.")   
                elif status == '1':
                    tool_category.status = 1  
                    tool_category.updated_by = user
                    tool_category.save()
                    messages.success(request, "Tool Category has been deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  

            return redirect('sa_manage_tools_category')  # Updated redirect URL for Tool Category

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    tool_category = get_object_or_404(ToolCategory, pk=pk)  
                    tool_category.status = 2  # Assuming 2 means deactivated or deleted
                    tool_category.updated_by = user
                    tool_category.save()
                    messages.success(request, "Tool Category has been Deleted successfully.")  
                except ToolCategory.DoesNotExist:
                    messages.error(request, "Tool Category not found.")  

            return redirect('sa_manage_tools_category')



        return redirect('sa_manage_tools_category')        

class ToolView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_tool': True,
                'can_view_tool': True,
                'can_edit_tool': True,
                'can_delete_tool': True, 
                'can_status_tool': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_tool:
                return redirect('user_not_allowed') 
            
        tools = Tool.objects.filter(Q(status=0) | Q(status=1)).order_by('-id')
        tool_categories = ToolCategory.objects.filter(status=0).order_by('-id')  # Get all tool categories for dropdown
        context = {
            'tools': tools,
            'tool_categories': tool_categories,
            'can_add_tool': manage_user.can_add_tool if manage_user else False,
            'can_view_tool': manage_user.can_view_tool if manage_user else False,
            'can_edit_tool': manage_user.can_edit_tool if manage_user else False,
            'can_delete_tool': manage_user.can_delete_tool if manage_user else False,
            'can_status_tool': manage_user.can_status_tool if manage_user else False,
            'messages': messages.get_messages(request),  # Pass messages to the template
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/manage_tools/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            category_id = request.POST.get('tool_category')  # Change to match your form name
            tools = Tool.objects.filter(status=0)

            # Validate name
            if not name:
                context = {
                    'tools': tools,
                    'tool_categories': ToolCategory.objects.filter(status=0),
                    'error': 'This Field is Required.',
                    'category_id': category_id  # Pass the selected category back
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/manage_tools/list.html', context)

            # Check for duplicates
            if Tool.objects.filter(name=name, status__in=[0,1]).exists():
                context = {
                    'tools': tools,
                    'tool_categories': ToolCategory.objects.all(),
                    'error': f'Tool Already Exists.',
                    'category_id': category_id  # Pass the selected category back
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/manage_tools/list.html', context)

            # Create the Tool
            Tool.objects.create(name=name, description=description, category_id=category_id,status=0,created_by=user)
            messages.success(request, 'Tool created successfully.')
            return redirect('sa_manage_tools')

        elif action == 'update':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, 'No ID provided for update.')
                return redirect('sa_manage_tools')

            tool = get_object_or_404(Tool, pk=pk)
            name = request.POST.get('name')
            description = request.POST.get('description')
            category_id = request.POST.get('category')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_manage_tools')

            tool.name = name
            tool.description = description
            tool.category_id = category_id
            tool.updated_by = user
            tool.save()

            messages.success(request, 'Tool updated successfully.')
            return redirect('sa_manage_tools')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                # Update the model from ToolCategory to ManageTool
                manage_tool = get_object_or_404(Tool, pk=pk)  

                status = request.POST.get('status')  

                if status == '0':
                    manage_tool.status = 0   
                    manage_tool.updated_by = user
                    manage_tool.save()
                    messages.success(request, "Manage Tool has been activated.")   
                elif status == '1':
                    manage_tool.status = 1  
                    manage_tool.updated_by = user
                    manage_tool.save()
                    messages.success(request, "Manage Tool has been deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  

            return redirect('sa_manage_tools')  # Updated redirect URL for Manage Tool

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    # Update the model from ToolCategory to ManageTool
                    manage_tool = get_object_or_404(Tool, pk=pk)  
                    manage_tool.status = 2  # Assuming 2 means deactivated or deleted
                    manage_tool.updated_by = user
                    manage_tool.save()

                    messages.success(request, "Manage Tool has been Deleted successfully.")  
                except Tool.DoesNotExist:
                    messages.error(request, "Manage Tool not found.")  

            return redirect('sa_manage_tools')

        return redirect('sa_manage_tools')    

# -------------------------------------------------------------------------- Machinery Management ----------------------------------------

class MachineryCategoryView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_machinery_category': True,
                'can_view_machinery_category': True,
                'can_edit_machinery_category': True,
                'can_delete_machinery_category': True, 
                'can_status_machinery_category': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_machinery_category:
                return redirect('user_not_allowed') 
            
        machinery_categories = MachineryCategory.objects.filter(Q(status=0) | Q(status=1)).order_by('-created_at')
        context = {
            'machinery_categories': machinery_categories,
            'can_add_machinery_category': manage_user.can_add_machinery_category if manage_user else False,
            'can_view_machinery_category': manage_user.can_view_machinery_category if manage_user else False,
            'can_edit_machinery_category': manage_user.can_edit_machinery_category if manage_user else False,
            'can_delete_machinery_category': manage_user.can_delete_machinery_category if manage_user else False,
            'can_status_machinery_category': manage_user.can_status_machinery_category if manage_user else False,
            'messages': messages.get_messages(request), 
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/machinery_category/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            machinery_categories = MachineryCategory.objects.all()

            # Validate name
            if not name:
                context = {
                    'machinery_categories': machinery_categories,
                    'error': 'This Field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/machinery_category/list.html', context)

            # Check for duplicates
            if MachineryCategory.objects.filter(name=name, status__in=[0,1]).exists():
                context = {
                    'machinery_categories': machinery_categories,
                    'error': 'Machinery Category Already Exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/machinery_category/list.html', context)

            # Create the Machinery Category
            MachineryCategory.objects.create(name=name, description=description,status=0, created_by=user)
            messages.success(request, 'Machinery category created successfully.')
            return redirect('sa_manage_machinery_category')

        elif action == 'update':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, 'No ID provided for update.')
                return redirect('sa_manage_machinery_category')
            
            machinery_category = get_object_or_404(MachineryCategory, pk=pk)
            name = request.POST.get('name')
            description = request.POST.get('description')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_manage_machinery_category')

            machinery_category.name = name
            machinery_category.description = description
            machinery_category.updated_by = user
            machinery_category.save()
            
            messages.success(request, 'Machinery category updated successfully.')
            return redirect('sa_manage_machinery_category')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                machinery_category = get_object_or_404(MachineryCategory, pk=pk)  

                status = request.POST.get('status')  

                if status == '0':
                    machinery_category.status = 0   
                    machinery_category.updated_by = user
                    machinery_category.save()
                    messages.success(request, "Machinery Category has been activated.")   
                elif status == '1':
                    machinery_category.status = 1 
                    machinery_category.updated_by = user 
                    machinery_category.save()
                    messages.success(request, "Machinery Category has been deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  

            return redirect('sa_manage_machinery_category')  

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    machinery_category = get_object_or_404(MachineryCategory, pk=pk)  
                    machinery_category.status = 2  
                    machinery_category.updated_by = user
                    machinery_category.save()

                    messages.success(request, "Machinery Category has been Deleted successfully.")  
                except MachineryCategory.DoesNotExist:
                    messages.error(request, "Machinery Category not found.")  

            return redirect('sa_manage_machinery_category')

        return redirect('sa_manage_machinery_category')

class MachineryView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_manage_machinery': True,
                'can_view_manage_machinery': True,
                'can_edit_manage_machinery': True,
                'can_delete_manage_machinery': True, 
                'can_status_manage_machinery': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_manage_machinery:
                return redirect('user_not_allowed') 
            
        machinery_items = Machinery.objects.filter(Q(status=0) | Q(status=1)).order_by('-created_at')
        machinery_categories = MachineryCategory.objects.filter(status=0)  
        context = {
            'machinery_items': machinery_items,
            'machinery_categories': machinery_categories,
            'can_add_manage_machinery': manage_user.can_add_manage_machinery if manage_user else False,
            'can_view_manage_machinery': manage_user.can_view_manage_machinery if manage_user else False,
            'can_edit_manage_machinery': manage_user.can_edit_manage_machinery if manage_user else False,
            'can_delete_manage_machinery': manage_user.can_delete_manage_machinery if manage_user else False,
            'can_status_manage_machinery': manage_user.can_status_manage_machinery if manage_user else False,
            'messages': messages.get_messages(request),  
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/manage_machinery/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            category_id = request.POST.get('machinery_category') 
            machinery_items = Machinery.objects.all()

            # Validate machinery category
            if not category_id:
                context = {
                    'machinery_items': machinery_items,
                    'machinery_categories': MachineryCategory.objects.all(),
                    'error': 'Machinery category is required.',
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/anage_machinery/list.html', context)

            # Validate name
            if not name:
                context = {
                    'machinery_items': machinery_items,
                    'machinery_categories': MachineryCategory.objects.all(),
                    'error': 'Machinery name is required.',
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/manage_machinery/list.html', context)

            # Check for duplicates
            if Machinery.objects.filter(name=name, status__in=[0,1]).exists():
                context = {
                    'machinery_items': machinery_items,
                    'machinery_categories': MachineryCategory.objects.all(),
                    'error': f'Machinery "{name}" already exists.',
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/manage_machinery/list.html', context)

            # Create the Machinery
            Machinery.objects.create(name=name, description=description, category_id=category_id,status=0,created_by=user)
            messages.success(request, 'Machinery created successfully.')
            return redirect('sa_manage_machinery')
 
        elif action == 'update':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, 'No ID provided for update.')
                return redirect('sa_manage_machinery') 

            machinery = get_object_or_404(Machinery, pk=pk)
            name = request.POST.get('name')
            description = request.POST.get('description')
            category_id = request.POST.get('machinery_category')  

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_manage_machinery')  

            machinery.name = name
            machinery.description = description
            machinery.category_id = category_id
            machinery.updated_by = user
            machinery.save()

            messages.success(request, 'Machinery updated successfully.')
            return redirect('sa_manage_machinery')  

        elif action == 'update_status':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                # Update the model from EmployeeType to MachineryCategory
                machinery_category = get_object_or_404(Machinery, pk=pk)

                status = request.POST.get('status')

                if status == '0':
                    machinery_category.status = 0   
                    machinery_category.updated_by = user
                    machinery_category.save()
                    messages.success(request, "Machinery Category has been activated.")
                elif status == '1':
                    machinery_category.status = 1  
                    machinery_category.updated_by = user
                    machinery_category.save()
                    messages.success(request, "Machinery Category has been deactivated.")
                else:
                    messages.error(request, "Invalid status value.")

            return redirect('sa_manage_machinery') 

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                try:
                    machinery_category = get_object_or_404(Machinery, pk=pk)  
                    machinery_category.status = 2  
                    machinery_category.updated_by = user
                    machinery_category.save()

                    messages.success(request, "Machinery Category has been Deleted successfully.")
                except MachineryCategory.DoesNotExist:
                    messages.error(request, "Machinery Category not found.")

            return redirect('sa_manage_machinery')

        return redirect('sa_manage_machinery')  

# ------------------------------------------------------------------------- vehicle Management --------------------------------------------

class VehicleCategoryView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_vehicle_category': True,
                'can_view_vehicle_category': True,
                'can_edit_vehicle_category': True,
                'can_delete_vehicle_category': True, 
                'can_status_vehicle_category': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_vehicle_category:
                return redirect('user_not_allowed')
            
        search_query = request.GET.get('search', '')
        vehicle_categories = VehicleCategory.objects.filter(
            Q(status=0) | Q(status=1),
            Q(name__icontains=search_query) | Q(description__icontains=search_query)
        ).order_by('-created_at')

        paginator = Paginator(vehicle_categories, 10) 
        page_number = request.GET.get('page')  
        page_obj = paginator.get_page(page_number) 

        context = {
            'vehicle_categories': page_obj,
            'can_add_vehicle_category': manage_user.can_add_vehicle_category if manage_user else False,
            'can_view_vehicle_category': manage_user.can_view_vehicle_category if manage_user else False,
            'can_edit_vehicle_category': manage_user.can_edit_vehicle_category if manage_user else False,
            'can_delete_vehicle_category': manage_user.can_delete_vehicle_category if manage_user else False,
            'can_status_vehicle_category': manage_user.can_status_vehicle_category if manage_user else False,
            'messages': messages.get_messages(request), 
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/vehicle_category/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            vehicle_categories = VehicleCategory.objects.all()

            # Validate name
            if not name:
                messages.error(request, 'This field is required.')
                return redirect('sa_manage_vehicle_category')

            # Check for duplicates
            if VehicleCategory.objects.filter(name=name, status__in=[0,1]).exists():
                messages.error(request, f'Vehicle Category "{name}" already exists.')
                return redirect('sa_manage_vehicle_category')

            # Create the Vehicle Category
            VehicleCategory.objects.create(name=name, description=description,status=0,created_by=user)
            messages.success(request, 'Vehicle category created successfully.')
            return redirect('sa_manage_vehicle_category')

        elif action == 'update':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, 'No ID provided for update.')
                return redirect('sa_manage_vehicle_category')
            
            vehicle_category = get_object_or_404(VehicleCategory, pk=pk)
            name = request.POST.get('name')
            description = request.POST.get('description')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_manage_vehicle_category')

            vehicle_category.name = name
            vehicle_category.description = description
            vehicle_category.updated_by = user
            vehicle_category.save()
            
            messages.success(request, 'Vehicle category updated successfully.')
            return redirect('sa_manage_vehicle_category')

        elif action == 'update_status':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                # Update the model from Machinery to VehicleCategory
                vehicle_category = get_object_or_404(VehicleCategory, pk=pk)

                status = request.POST.get('status')

                if status == '0':
                    vehicle_category.status = 0
                    vehicle_category.updated_by = user
                    vehicle_category.save()
                    messages.success(request, "Vehicle Category has been activated.")
                elif status == '1':
                    vehicle_category.status = 1
                    vehicle_category.updated_by = user
                    vehicle_category.save()
                    messages.success(request, "Vehicle Category has been deactivated.")
                else:
                    messages.error(request, "Invalid status value.")

            return redirect('sa_manage_vehicle_category')  

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                try:
                    vehicle_category = get_object_or_404(VehicleCategory, pk=pk)
                    vehicle_category.status = 2  
                    vehicle_category.updated_by = user
                    vehicle_category.save()

                    messages.success(request, "Vehicle Category has been Deleted successfully.")
                except VehicleCategory.DoesNotExist:
                    messages.error(request, "Vehicle Category not found.")

            return redirect('sa_manage_vehicle_category')

        return redirect('sa_manage_vehicle_category')

class VehicleManagementView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_manage_vehicle': True,
                'can_view_manage_vehicle': True,
                'can_edit_manage_vehicle': True,
                'can_delete_manage_vehicle': True, 
                'can_status_manage_vehicle': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_manage_vehicle:
                return redirect('user_not_allowed') 
            
        search_query = request.GET.get('search', '')

        vehicle_items = VehicleManagement.objects.filter(
            Q(status=0) | Q(status=1),
            Q(name__icontains=search_query) | Q(description__icontains=search_query)
        ).order_by('-created_at')

        paginator = Paginator(vehicle_items, 10) 
        page_number = request.GET.get('page')  
        page_obj = paginator.get_page(page_number)  

        vehicle_categories = VehicleCategory.objects.filter(status=0)

        context = {
            'vehicle_items': page_obj,  
            'vehicle_categories': vehicle_categories,
            'can_add_manage_vehicle': manage_user.can_add_manage_vehicle if manage_user else False,
            'can_view_manage_vehicle': manage_user.can_view_manage_vehicle if manage_user else False,
            'can_edit_manage_vehicle': manage_user.can_edit_manage_vehicle if manage_user else False,
            'can_delete_manage_vehicle': manage_user.can_delete_manage_vehicle if manage_user else False,
            'can_status_manage_vehicle': manage_user.can_status_manage_vehicle if manage_user else False,
            'messages': messages.get_messages(request),
        }
        
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/manage_vehicle/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            category_id = request.POST.get('vehicle_category') 
            vehicle_items = VehicleManagement.objects.all()

            # Validate vehicle category
            if not category_id:
                messages.error(request, 'Vehicle category is required.')
                return redirect('sa_manage_vehicle')

            # Validate name
            if not name:
                messages.error(request, 'Vehicle name is required.')
                return redirect('sa_manage_vehicle')

            # Check for duplicates
            if VehicleManagement.objects.filter(name=name, status__in=[0,1]).exists():
                messages.error(request, f'Vehicle "{name}" already exists.')
                return redirect('sa_manage_vehicle')

            # Create the Vehicle
            VehicleManagement.objects.create(name=name, description=description, category_id=category_id,status=0, created_by=user)
            messages.success(request, 'Vehicle created successfully.')
            return redirect('sa_manage_vehicle')

        elif action == 'update':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, 'No ID provided for update.')
                return redirect('sa_manage_vehicle') 

            vehicle = get_object_or_404(VehicleManagement, pk=pk)
            name = request.POST.get('name')
            description = request.POST.get('description')
            category_id = request.POST.get('vehicle_category')  

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_manage_vehicle')  

            vehicle.name = name
            vehicle.description = description
            vehicle.category_id = category_id
            vehicle.updated_by = user
            vehicle.save()

            messages.success(request, 'Vehicle updated successfully.')
            return redirect('sa_manage_vehicle')  

        elif action == 'update_status':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                # Update the model from VehicleCategory to Vehicle
                vehicle = get_object_or_404(VehicleManagement, pk=pk)

                status = request.POST.get('status')

                if status == '0':
                    vehicle.status = 0
                    vehicle.updated_by = user
                    vehicle.save()
                    messages.success(request, "Vehicle has been activated.")
                elif status == '1':
                    vehicle.status = 1
                    vehicle.updated_by = user
                    vehicle.save()
                    messages.success(request, "Vehicle has been deactivated.")
                else:
                    messages.error(request, "Invalid status value.")

            return redirect('sa_manage_vehicle')  

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                try:
                    vehicle = get_object_or_404(VehicleManagement, pk=pk)
                    vehicle.status = 2  # Assuming 2 means deactivated or deleted
                    vehicle.updated_by = user
                    vehicle.save()

                    messages.success(request, "Vehicle has been Deleted successfully.")
                except VehicleManagement.DoesNotExist:
                    messages.error(request, "Vehicle not found.")

            return redirect('sa_manage_vehicle')

        return redirect('sa_manage_vehicle')


# ------------------------------------------------------------------------- Package Management --------------------------------------

def get_package_details(request, package_id):
    try:
        # Fetch the package details by ID
        # print("api")
        package = PackageManagement.objects.get(id=package_id)
        count = 5
        if package.is_myvechicle:
            count += 1
        if package.is_mymachinery:
            count += 1
        if package.is_mytools:
            count += 1
        if package.is_myinventory:
            count += 3
        if package.is_attendance:
            count += 1
        if package.is_payouts:
            count += 1
        if package.is_widget:
            count += 1
        # Prepare the response data
        response_data = {
            'id': package.id,
            'name': package.name,
            'amount': package.amount,
            'sub_amount' : package.sub_amount,
            'package_duration': package.package_duration.name,
            'pack_duration_code' : package.package_duration.code,
            'package_validity' : package.package_validity,
            'farmer_manager_count': package.farmer_manager_count,
            'myland_count': package.myland_count,
            'mycrops_count': package.mycrops_count,
            'myexpense_count': package.myexpense_count,
            'mysale_count': package.mysale_count,
            'customer_count': package.customer_count,
            'is_fuel' : package.is_myfuel,
            'fuel_count' : package.myfuel_count,
            'is_vechile' : package.is_myvechicle,
            'vechicle_count' : package.myvechicle_count,
            'is_machinery' : package.is_mymachinery,
            'machinery_count' : package.mymachinery_count,
            'is_tools' : package.is_mytools,
            'tools_count' : package.mytools_count,
            'is_pesticides' : package.is_mypesticides,
            'pesticides_count' : package.mypesticides_count,
            'is_fertilizers' : package.is_myfertilizers,
            'fertilizers_count' : package.myfertilizers_count,
            'is_seeds' : package.is_myseeds,
            'seeds_count' : package.myseeds_count,
            'is_inventory' : package.is_myinventory,
            'products_count' : package.myinventory_products,
            'purchase_count' : package.myinventory_purchase,
            'vendors_count' : package.myinventory_vendors,
            'is_attendance' : package.is_attendance,
            'employee_count' : package.employee_count,
            'is_payouts' : package.is_payouts,
            'is_widget' : package.is_widget,
            'count' : count,
        }
        
        return JsonResponse(response_data)
    
    except PackageManagement.DoesNotExist:
        return JsonResponse({'error': 'Package not found'}, status=404)

def get_farmer_from_package(request, package_id):
    try:
        farmers = Farmer.objects.filter(subscription_package__id = package_id)
        if not farmers.exists():
            return JsonResponse({"error": "No farmers found for the given package ID"}, status=200)

        try:
            settings = GeneralSetting.objects.first()
            date_format = convert_to_strftime_format(settings.date_format)
        except Exception as e:
            date_format = '%d-%m-%Y'
        
        response_data = []
        for farmer in farmers:
            response_data.append({
                "name": farmer.name,
                "subscription_end_date": farmer.subscription_end_date.strftime(date_format)
            })
        return JsonResponse(response_data, safe=False, status=200)
    except Exception as e:
        print(e)
        return JsonResponse({"error": f"An error occurred: {str(e)}"}, status=500)

class ManagePackageView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_package': True,
                'can_view_package': True,
                'can_edit_package': True,
                'can_delete_package': True,
                'can_view_unique_package': True,

            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_package:
                return redirect('user_not_allowed') 
            
        # search_query = request.GET.get('search', '')
        packages = PackageManagement.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')
        durations = Duration.objects.filter(status=0)

        package_list = []
        farmers_list = Farmer.objects.filter(status__in=[0,1,3,5,6]) 
        for j in farmers_list:
            if j.subscription_package:
                if j.subscription_package.id not in package_list:
                    package_list.append(j.subscription_package.id)
                
        print(package_list)
        return render(request, 'pages/super_admin/package_management/list.html', {
            'packages': packages,
            'can_add_package': manage_user.can_add_package if manage_user else False,
            'can_view_package': manage_user.can_view_package if manage_user else False,
            'can_edit_package': manage_user.can_edit_package if manage_user else False,
            'can_delete_package': manage_user.can_delete_package if manage_user else False,
            'can_view_unique_package': manage_user.can_view_unique_package if manage_user else False,
            'durations': durations,
            'package_list': package_list,
        })

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')
        if action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
                return redirect('sa_manage_package')

            try:
                package = get_object_or_404(PackageManagement, pk=pk)
                package.status = 2  # Soft delete (mark as deleted)
                package.updated_by = user
                package.save()

                messages.success(request, "Package has been deleted successfully.")
            except PackageManagement.DoesNotExist:
                messages.error(request, "Package not found.")
           
            return redirect('sa_manage_package')

class ManagePackageCreateView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        packages = PackageManagement.objects.all().order_by('-id')
        durations = Duration.objects.all()
        return render(request, 'pages/super_admin/package_management/add.html', {
            'durations': durations,
            'packages': packages
        })
   
    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        package_name = request.POST.get('name')
        package_validity = int(request.POST.get('package_validity'))
        package_duration_id = request.POST.get('package_duration')
        amount = float(request.POST.get('amount'))
        offer_percentage = float(request.POST.get('offer_percentage', 0))
        farmer_manager_count = request.POST.get('farmer_manager_count', 0)
        land_count = request.POST.get('land_count', 0)
        crop_count = request.POST.get('crops_count', 0)
        expense_count = request.POST.get('expense_count', 0)
        sales_count = request.POST.get('sales_count', 0)
        customer_count = request.POST.get('customer_count', 0)

        is_fuel = request.POST.get('fuelCheckbox')
        is_fue=False
        if is_fuel == 'on':
            is_fue = True
        fuel_count = request.POST.get('fuel_count', 0)

        is_vechile = request.POST.get('vehicleCheckbox')
        is_ve=False
        if is_vechile == 'on':
            is_ve = True
        vechile_count = request.POST.get('vechile_count', 0)

        is_machinery = request.POST.get('machineryCheckbox')
        is_machine=False
        if is_machinery == 'on':
            is_machine = True
        machinery_count = request.POST.get('machinery_count', 0)
        
        is_tools = request.POST.get('toolsCheckbox')
        is_tool=False
        if is_tools == 'on':
            is_tool = True
        tools_count = request.POST.get('tools_count', 0)
        
        is_pesticides = request.POST.get('pesticidesCheckbox')
        is_pest=False
        if is_pesticides == 'on':
            is_pest = True
        pest_count = request.POST.get('pesticides_count', 0)

        is_fertilizers = request.POST.get('fertilizersCheckbox')
        is_ferti = False
        if is_fertilizers == 'on':
            is_ferti = True
        ferti_count = request.POST.get('fertilizers_count', 0)

        is_seeds = request.POST.get('seedsCheckbox')
        is_seed = False
        if is_seeds == 'on':
            is_seed = True
        seed_count = request.POST.get('seeds_count', 0)

        is_inventory = request.POST.get('inventoryCheckbox')
        is_inven=False
        if is_inventory == 'on':
            is_inven = True
        products_count = request.POST.get('products_count', 0)
        purchase_count = request.POST.get('purchase_count', 0)
        vendors_count = request.POST.get('vendors_count', 0)

        is_attendance = request.POST.get('attendanceCheckbox')
        is_atte=False
        is_pay=False
        if is_attendance == 'on':
            is_atte = True
            is_payots = request.POST.get('payoutsCheckbox')
            if is_payots == 'on':
                is_pay = True
        
        employee_count = request.POST.get('employee_count', 0)
        
        is_widget = request.POST.get('widgetCheckbox')
        is_wid=False
        if is_widget == 'on':
            is_wid = True
        # package_validity = int(request.POST.get('package_validity'))

        package_duration = Duration.objects.get(id=package_duration_id)

        if offer_percentage:
            discount = (amount * offer_percentage) / 100
            sub_amount = amount - discount
        else:
            sub_amount = amount

        package = PackageManagement.objects.create(
            name=package_name,
            package_validity=package_validity,
            package_duration=package_duration,
            amount=amount,
            offer=True if offer_percentage > 0 else False,
            percentage=offer_percentage,
            sub_amount=sub_amount,
            status=0 ,
            farmer_manager_count = farmer_manager_count,
            myland_count = land_count,
            mycrops_count = crop_count,
            myexpense_count = expense_count,
            mysale_count = sales_count,
            customer_count = customer_count,
            is_myfuel = is_fue,
            myfuel_count = fuel_count,
            is_myvechicle = is_ve,
            myvechicle_count = vechile_count,
            is_mymachinery = is_machine,
            mymachinery_count = machinery_count,
            is_mytools = is_tool,
            mytools_count = tools_count,
            is_mypesticides = is_pest,
            mypesticides_count = pest_count,
            is_myfertilizers = is_ferti,
            myfertilizers_count = ferti_count,
            is_myseeds = is_seed,
            myseeds_count = seed_count,
            is_myinventory = is_inven,
            myinventory_products = products_count,
            myinventory_purchase = purchase_count if purchase_count else 0,
            myinventory_vendors = vendors_count,
            is_attendance = is_atte,
            employee_count = employee_count,
            is_payouts = is_pay,
            is_widget = is_wid,
            created_by=user,
            created_at=timezone.now()
        )

        messages.success(request, 'Package has been created successfully!')

        return redirect('sa_manage_package')

class ManagePackageUpdateView(LoginRequiredMixin,View):
    def get(self, request, pk):
        trigger_subscription()
        package = get_object_or_404(PackageManagement, pk=pk)
        durations = Duration.objects.all()
        return render(request, 'pages/super_admin/package_management/edit.html', {
            'package': package,
            'durations': durations
        })

    def post(self, request, pk):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        package = get_object_or_404(PackageManagement, pk=pk)
        translated_json = package.translate_json or {
            'name' : {}
        }
        package_name = request.POST.get('name')
        package_validity = int(request.POST.get('package_validity'))
        package_duration_id = request.POST.get('package_duration')
        amount = float(request.POST.get('amount'))
        off_per = request.POST.get('offer_percentage')
        if off_per:
            offer_percentage = float(off_per) 
        else:
            offer_percentage = None
        farmer_manager_count = request.POST.get('farmer_manager_count', 0)
        package.farmer_manager_count = farmer_manager_count
        land_count = request.POST.get('land_count', 0)
        package.myland_count = land_count
        crop_count = request.POST.get('crops_count', 0)
        package.mycrops_count = crop_count
        expense_count = request.POST.get('expense_count', 0)
        package.myexpense_count = expense_count
        sales_count = request.POST.get('sales_count', 0)
        package.mysale_count = sales_count
        customer_count = request.POST.get('customer_count', 0)
        package.customer_count = customer_count

        is_fuel = request.POST.get('fuelCheckbox')
        if is_fuel == 'on':
            package.is_myfuel = True
        else:
            package.is_myfuel = False
        fuel_count = request.POST.get('fuel_count', 0)
        package.myfuel_count = fuel_count

        is_vechile = request.POST.get('vehicleCheckbox')
        if is_vechile == 'on':
            package.is_myvechicle = True
        else:
            package.is_myvechicle = False
        vechile_count = request.POST.get('vechile_count', 0)
        package.myvechicle_count = vechile_count

        is_machinery = request.POST.get('machineryCheckbox')
        if is_machinery == 'on':
            package.is_mymachinery = True
        else:
            package.is_mymachinery = False
        machinery_count = request.POST.get('machinery_count', 0)
        package.mymachinery_count = machinery_count

        is_tools = request.POST.get('toolsCheckbox')
        if is_tools == 'on':
            package.is_mytools = True
        else:
            package.is_mytools = False
        tools_count = request.POST.get('tools_count', 0)
        package.mytools_count = tools_count

        is_pesticides = request.POST.get('pesticidesCheckbox')
        if is_pesticides == 'on':
            package.is_mypesticides = True
        else:
            package.is_mypesticides = False
        pest_count = request.POST.get('pesticides_count', 0)
        package.mypesticides_count = pest_count

        is_fertilizers = request.POST.get('fertilizersCheckbox')
        if is_fertilizers == 'on':
            package.is_myfertilizers = True
        else:
            package.is_myfertilizers = False
        ferti_count = request.POST.get('fertilizers_count', 0)
        package.myfertilizers_count = ferti_count

        is_seeds = request.POST.get('seedsCheckbox')
        if is_seeds == 'on':
            package.is_myseeds = True
        else:
            package.is_myseeds = False
        seed_count = request.POST.get('seeds_count', 0)
        package.myseeds_count = seed_count

        is_inventory = request.POST.get('inventoryCheckbox')
        if is_inventory == 'on':
            package.is_myinventory = True
        else:
            package.is_myinventory = False
        # products_count = request.POST.get('products_count', 0)
        products_count = request.POST.get(('products_count') or 0)
        package.myinventory_products = products_count
        # purchase_count = request.POST.get('purchase_count', 0)
        purchase_count = int(request.POST.get('purchase_count') or 0)
        package.myinventory_purchase = purchase_count
        vendors_count = request.POST.get(('vendors_count') or 0)
        # vendors_count = request.POST.get('vendors_count', 0)
        package.myinventory_vendors = vendors_count
        
        is_attendance = request.POST.get('attendanceCheckbox')
        if is_attendance == 'on':
            package.is_attendance = True
            is_payots = request.POST.get('payoutsCheckbox')
            if is_payots == 'on':
                package.is_payouts = True
            else:
                package.is_payouts = False
        else:
            package.is_attendance = False
            package.is_payouts = False
        
        employee_count = request.POST.get('employee_count', 0)
        package.employee_count = employee_count
        
        is_widget = request.POST.get('widgetCheckbox')
        if is_widget == 'on':
            package.is_widget = True  
        else:
            package.is_widget = False

        package_duration = Duration.objects.get(id=package_duration_id)

        if offer_percentage:
            discount = (amount * offer_percentage) / 100
            sub_amount = amount - discount
        else:
            sub_amount = amount
        if package.name != package_name:
            package.name = package_name
            try:
                for lang in target_language:
                    translated_text = GoogleTranslator(source='auto', target=lang).translate(package_name)
                    translated_json["name"][lang] = translated_text
            except Exception as e:
                    print(e)
                    print("Error in translation")
        package.package_validity = package_validity
        package.package_duration = package_duration
        package.amount = amount
        package.offer = True if offer_percentage != None else False
        package.percentage = offer_percentage
        package.sub_amount = sub_amount
        package.updated_by = user
        package.translate_json = translated_json
        package.save() 

        messages.success(request, 'Package has been updated successfully!')

        return redirect('sa_manage_package')    

# ------------------------------------------------------------------------ Subscription Management ----------------------------------

def convert_to_strftime_format(date_str):
    # Define a mapping from custom formats to strftime compatible formats
    format_mapping = {
        'd': '%d',      # Day of the month (01 to 31)
        'D': '%a',      # Abbreviated weekday name
        'm': '%m',      # Month (01 to 12)
        'M': '%b',      # Abbreviated month name
        'Y': '%Y',      # Four-digit year (e.g., 2024)
        'y': '%y',      # Two-digit year (e.g., 24 for 2024)
    }
    
    # Match formats like 'd/m/y', 'd-M-Y', 'y/m/d', etc.
    date_str = date_str.lower()  # Make it case-insensitive

    # Replace format parts with strftime equivalent
    for key, value in format_mapping.items():
        # Replace the key with the corresponding strftime format
        date_str = re.sub(r'\b' + key + r'\b', value, date_str)

    # Handle cases where the format might use slashes or other separators
    # Make sure to preserve separators like d-M-Y -> %d-%m-%Y
    date_str = date_str.replace('/', '-').replace(' ', '-')  # You can replace more separators as needed

    return date_str

class SubscriptionManagementView(LoginRequiredMixin, View):
    def get(self, request, id=None):
        trigger_subscription()
        # Get the current date (without time part)
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_subscription': True,
                'can_view_subscription': True,
                'can_edit_subscription': True,
                'can_delete_subscription': True, 
                'can_view_unique_subscription': True, 
                'can_export_subscription':True,
                'can_filter_subscription':True,
                'can_activeplan_subscription':True,
                'can_renewalplan_subscription':True
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_subscription:
                return redirect('user_not_allowed') 
        
        # farmer_types = FarmerType.objects.all()
        # Get subscriptions based on status

        latest_active_inactive_expired = AddSubcription.objects.filter(
            Q(status__in=[0, 1, 3, 4]),
            farmers=OuterRef('farmers')
        ).values('farmers').annotate(
            latest_created=Max('created_at')
        ).values('latest_created')

        # Query to get all the records for each farmer
        subscriptions = AddSubcription.objects.filter(
            Q(status=5) | 
            Q(status__in=[0, 1, 3, 4], created_at__in=Subquery(latest_active_inactive_expired))
        ).order_by('-id')
        
        filter_status = request.GET.get('filter_status')
        selected_package = request.GET.get('Filter_Packages')
        filter_paymentstatus = request.GET.get('filter_paymentstatus')
        date_filter = request.GET.get('dt_fill_issue_rpt')
        
        if selected_package:
            package = PackageManagement.objects.get(id=selected_package)
            subscriptions = subscriptions.filter(packages=package)
        if filter_status:
            subscriptions = subscriptions.filter(status=int(filter_status))
        if filter_paymentstatus:
            subscriptions = subscriptions.filter(payment_status=int(filter_paymentstatus))

        if date_filter == 'today':
            subscriptions = subscriptions.filter(created_at__date=datetime.today())
        elif date_filter == 'week':
            subscriptions = subscriptions.filter(created_at__gte=datetime.today() - timedelta(days=7))
        elif date_filter == 'monthly':
            subscriptions = subscriptions.filter(created_at__month=datetime.today().month)
        elif date_filter == 'custom_date':
            custom_from_date = request.GET.get('filter_date_cfrom')
            custom_to_date = request.GET.get('filter_date_cto')
            if custom_from_date and custom_to_date:
                custom_from_date = datetime.strptime(custom_from_date, '%d-%m-%Y').date()
                custom_to_date = datetime.strptime(custom_to_date, '%d-%m-%Y').date()
                subscriptions = subscriptions.filter(created_at__date__range=[custom_from_date, custom_to_date])

        show_per_page = request.GET.get('show', 25)
        show_per_page = int(show_per_page)  # Convert it to an integer

        # Pagination setup
        paginator = Paginator(subscriptions, show_per_page)  # Show the selected number of farmers per page 
        page_number = request.GET.get('page')  # Get the page number from the request
        page_obj = paginator.get_page(page_number)

        subscription_count = 0
        for i in page_obj:
            subscription_count += 1
        
        
        packages = PackageManagement.objects.filter(status=0).order_by('-id')
        packages_data = []
        for package in packages:
            package_data = {
                'id': package.id,
                'name': package.name,
                'amount': package.amount,
                'sub_amount': package.sub_amount,
                'package_validity': package.package_validity,
                'package_duration': package.package_duration.name if package.package_duration else '-',
            }
            packages_data.append(package_data)

        subscription_id = request.GET.get('subscription_id')

        subscription = None
        if subscription_id:
            try:
                subscription = AddSubcription.objects.get(id=subscription_id)
            except AddSubcription.DoesNotExist:
                raise Http404("Subscription not found")

        # Prepare context with the relevant data
        create_subs = Farmer.objects.filter(Q(status=6) | Q(remaining_days=0, status__in=[0, 1, 3, 4, 5,6])).order_by('-id')
        all_farmers = Farmer.objects.filter(status__in=[0, 1, 3, 4, 5, 6])
        context = {
            # 'farmer_types': farmer_types,
            'farmers': page_obj,  # Paginated farmers list
            'entries_count': subscription_count,
            'show_per_page': show_per_page,
            'all_farmers' : all_farmers,
            'create_subs': create_subs,
            'packages': packages_data,  # Packages data with add-ons 
            'selected_package': selected_package if selected_package else "",
            'filter_status': filter_status if filter_status else "",
            'filter_paymentstatus' : filter_paymentstatus if filter_paymentstatus else '',
            'date_filter': date_filter if date_filter else '',
            'subscriptions_list': page_obj,  # List of subscriptions
            'subscription': subscription,  # Single subscription based on ID
            'farmers_for_subscription': subscription.farmer if subscription else None,  # Farmers related to the subscription
            'packages_for_subscription': subscription.packages if subscription else None,  # Packages related to the subscription
            'can_add_subscription': manage_user.can_add_subscription if manage_user else False,
            'can_view_subscription': manage_user.can_view_subscription if manage_user else False,
            'can_edit_subscription': manage_user.can_edit_subscription if manage_user else False,
            'can_delete_subscription': manage_user.can_delete_subscription if manage_user else False,
            'can_view_unique_subscription': manage_user.can_view_unique_subscription if manage_user else False,
            'can_export_subscription': manage_user.can_export_subscription if manage_user else False,
            'can_filter_subscription': manage_user.can_filter_subscription if manage_user else False,
            'can_activeplan_subscription': manage_user.can_activeplan_subscription if manage_user else False,
            'can_renewalplan_subscription': manage_user.can_renewalplan_subscription if manage_user else False,
            'can_update_subscription_status': manage_user.can_update_subscription_status if manage_user else False,
            'package_without_free_trail': PackageManagement.objects.filter(status=0).exclude(id=1).order_by('-id')
        }
        
        # Render the page with the context
        return render(request, 'pages/super_admin/subscription_management/list.html', context)

    def post(self, request, id=None):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')
        
        if not action:  # If no action is provided, it's invalid.
            messages.error(request, "Action is required.")
            return redirect('sa_subscription_management')

        if action == 'create':
            selected_farmer = request.POST.get('farmers')
            selected_package_id = request.POST.get('packages')
            paymentMode = request.POST.get('paymentMode')
            transactionId = request.POST.get('transactionId')
            paymentstatus = request.POST.get('paymentstatus')

            if not selected_farmer or not selected_package_id:
                messages.error(request, "Please fill in all required fields.")
                return redirect('sa_subscription_management')

            try:
                farmer = Farmer.objects.get(id=selected_farmer)
                package = PackageManagement.objects.get(id=selected_package_id)
                existing_subscription = AddSubcription.objects.filter(farmers=farmer, status__in=[0, 5]).order_by('-created_at').first()

                if existing_subscription:
                    status = 5
                    new_start_date = existing_subscription.enddate
                    renewal = True
                else:
                    status = 0
                    new_start_date = timezone.now().date()
                    renewal = False

                subscription = AddSubcription.objects.create(
                    farmers=farmer,
                    packages=package,
                    status=status,
                    startdate=new_start_date,
                    renewal=renewal,
                    created_by=user,
                    created_at=timezone.now()
                )
                if paymentMode == 'online':
                    subscription.payment_mode=0
                    subscription.transaction_id=transactionId
                    subscription.payment_status=0
                    subscription.save()
                elif paymentMode == 'pos':
                    subscription.payment_mode=2
                    subscription.transaction_id=transactionId
                    subscription.payment_status=0
                    subscription.save()
                else:
                    subscription.payment_mode=1
                    if paymentstatus == "0":
                        subscription.payment_status=0
                    else:
                        subscription.payment_status=1
                    subscription.save()
                
                # After creating the subscription, call the package_details_update method to set enddate and remainingdays.
                subscription.package_details_update(user) 

                messages.success(request, "Subscription created successfully!")
                return redirect('sa_subscription_management')

            except Farmer.DoesNotExist:
                messages.error(request, "Selected farmer not found.")
            except PackageManagement.DoesNotExist:
                messages.error(request, "Selected package not found.")
            except Exception as e:
                messages.error(request, f"An error occurred: {str(e)}")

            return redirect('sa_subscription_management')

        elif action == 'update_status':
            pk = request.POST.get('id')
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                # Fetch the Farmer object based on the provided primary key (id)
                subscription = get_object_or_404(AddSubcription, pk=pk)
                
                # Get the status from the POST data (whether it's checked or unchecked)
                if subscription.remainingdays == 0:
                    subscription.status = 4
                    subscription.updated_by = user
                    subscription.save()
                    messages.success(request, "Subscription Expired ...")
                else:
                    # Get the status from the POST data (whether it's checked or unchecked)
                    status = request.POST.get('status')
                
                if status == '0':  # Deactivate the farmer (status = 0)
                    subscription.status = 0  
                    subscription.updated_by = user
                    subscription.save()
                    messages.success(request, "Subscription has been activated.")  # Success message for activation
                elif status == '1':  # Activate the farmer (status = 1)
                    subscription.status = 1  
                    subscription.updated_by = user
                    subscription.save()
                    messages.success(request, "Subscription has been deactivated.")  # Success message for deactivation
                else:
                    messages.error(request, "Invalid status value.")  # In case the status value is neither '0' nor '1'
                
            return redirect('sa_subscription_management')
        
        elif action == 'update':  
            # Get the subscription ID from the form
            subscription_id = request.POST.get('id')
            if not subscription_id:
                messages.error(request, "Subscription ID is required.")
                return redirect('sa_subscription_management')

            try:
                # Get the subscription object to update
                subscription = get_object_or_404(AddSubcription, id=subscription_id)

                # Get the other data for updating
                farmer_id = request.POST.get('farmers')
                # farmer_type_id = request.POST.get('farmer_type')
                package_id = request.POST.get('packages')
                paymentMode = request.POST.get('editpaymentMode')
                transactionId = request.POST.get('transactionId')
                paymentstatus = request.POST.get('editpaymentstatus')

                # Get the related objects
                farmer = Farmer.objects.get(id=farmer_id) if farmer_id else None
                package = PackageManagement.objects.get(id=package_id) if package_id else None
                old_pack = subscription.packages

                subscription.farmers = farmer
                subscription.packages = package
                subscription.updated_by = user
                subscription.save()
                print(paymentMode)

                if paymentMode == 'online':
                    subscription.payment_mode=0
                    subscription.transaction_id=transactionId
                    subscription.payment_status=0
                    subscription.save()
                elif paymentMode == 'pos':
                    subscription.payment_mode=2
                    subscription.transaction_id=transactionId
                    subscription.payment_status=0
                    subscription.save()
                else:
                    subscription.payment_mode=1
                    if paymentstatus == "0":
                        subscription.payment_status=0
                    else:
                        subscription.payment_status=1
                    subscription.save()
                if old_pack != package:
                    subscription.package_details_update(user)

                messages.success(request, "Subscription Updated Successfully!")
                return redirect('sa_subscription_management')

            except AddSubcription.DoesNotExist:
                messages.error(request, "Subscription not found.")
            except Farmer.DoesNotExist:
                messages.error(request, "Selected farmer not found.")
            except PackageManagement.DoesNotExist:
                messages.error(request, "Selected package not found.")
            except FarmerType.DoesNotExist:
                messages.error(request, "Selected farmer type not found.")
            except Exception as e:
                messages.error(request, f"An error occurred: {str(e)}")

            return redirect('sa_subscription_management')
        
        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                try:
                    subscription = get_object_or_404(AddSubcription, pk=pk)

                    subscription.status = 2  
                    subscription.updated_by = user
                    subscription.save()

                    messages.success(request, "Subscription has been deleted successfully.")
                except AddSubcription.DoesNotExist:
                    messages.error(request, "subscription not found.")

            return redirect('sa_subscription_management')
        
        elif action == 'renew_subscription':
            subscription_id = request.POST.get('id')
            package_id = request.POST.get('re_pckg')

            if not subscription_id:
                messages.error(request, "Subscription ID is required for renewal.")
                return redirect('sa_subscription_management')

            try:
                subscription = AddSubcription.objects.get(id=subscription_id)

                subscription.renew_subscription(package_id, user)

                messages.success(request, "Subscription renewed successfully!")
            except AddSubcription.DoesNotExist:
                messages.error(request, "Subscription not found.")
            # except Exception as e:
            #     messages.error(request, f"An error occurred: {str(e)}")

            return redirect('sa_subscription_management')

        elif action == 'activate_plan':
            subscription_id = request.POST.get('id')

            if not subscription_id:
                messages.error(request, "Subscription ID is required for renewal.")
                return redirect('sa_subscription_management')
            try:
                subscription = AddSubcription.objects.get(id=subscription_id)
                existing_subscription = AddSubcription.objects.filter(farmers=subscription.farmers, status=0).first()
                existing_subscription.status=3
                existing_subscription.save()
                subscription.status = 0
                subscription.startdate = timezone.now().date()
                subscription.updated_by = user
                subscription.save()
                subscription.package_details_update()
                messages.success(request, "Subscription activated successfully!")
            except AddSubcription.DoesNotExist:
                messages.error(request, "Subscription not found.")
            except Exception as e:
                messages.error(request, f"An error occurred: {str(e)}")

            return redirect('sa_subscription_management')

        elif action == 'filter_sub':
            filter_status = request.POST.get('filter_status')
            selected_package = request.POST.get('Filter_Packages')
            filter_paymentstatus = request.POST.get('filter_paymentstatus')
            date_filter = request.POST.get('dt_fill_issue_rpt')

            if not filter_status and not selected_package and not filter_paymentstatus and date_filter == 'all':
                return redirect('sa_subscription_management')

            user = request.user
            manage_user = None
            if user.is_superuser:
                context = {
                    'can_add_subscription': True,
                    'can_view_subscription': True,
                    'can_edit_subscription': True,
                    'can_delete_subscription': True, 
                    'can_view_unique_subscription': True, 
                    'can_export_subscription':True,
                    'can_filter_subscription':True,
                    'can_activeplan_subscription':True,
                    'can_renewalplan_subscription':True
                }
            else:
                try:
                    manage_user = ManageUser.objects.get(custom_user_id=user.id)
                except ManageUser.DoesNotExist:
                    manage_user = None

                if manage_user and not manage_user.can_view_subscription:
                    return redirect('user_not_allowed') 
            
            latest_active_inactive_expired = AddSubcription.objects.filter(
                Q(status__in=[0, 1, 3, 4]),
                farmers=OuterRef('farmers')
            ).values('farmers').annotate(
                latest_created=Max('created_at')
            ).values('latest_created')

            # Query to get all the records for each farmer
            subscriptions = AddSubcription.objects.filter(
                Q(status=5) | 
                Q(status__in=[0, 1, 3, 4], created_at__in=Subquery(latest_active_inactive_expired))
            ).order_by('-created_at')
            
                        
            if selected_package:
                package = PackageManagement.objects.get(id=selected_package)
                subscriptions = subscriptions.filter(packages=package)
            if filter_status:
                subscriptions = subscriptions.filter(status=int(filter_status))
            if filter_paymentstatus:
                subscriptions = subscriptions.filter(payment_status=int(filter_paymentstatus))

            if date_filter == 'today':
                subscriptions = subscriptions.filter(created_at__date=datetime.today())
            elif date_filter == 'week':
                subscriptions = subscriptions.filter(created_at__gte=datetime.today() - timedelta(days=7))
            elif date_filter == 'monthly':
                subscriptions = subscriptions.filter(created_at__month=datetime.today().month)
            elif date_filter == 'custom_date':
                custom_from_date = request.GET.get('filter_date_cfrom')
                custom_to_date = request.GET.get('filter_date_cto')
                if custom_from_date and custom_to_date:
                    custom_from_date = datetime.strptime(custom_from_date, '%d-%m-%Y').date()
                    custom_to_date = datetime.strptime(custom_to_date, '%d-%m-%Y').date()
                    subscriptions = subscriptions.filter(created_at__date__range=[custom_from_date, custom_to_date])

            show_per_page = request.GET.get('show', 25)
            show_per_page = int(show_per_page)

            # Pagination setup
            paginator = Paginator(subscriptions, show_per_page)
            page_number = request.GET.get('page')
            page_obj = paginator.get_page(page_number)

            subscription_count = 0
            for i in page_obj:
                subscription_count += 1
            
            packages = PackageManagement.objects.filter(status=0).order_by('-id')
            packages_data = []
            for package in packages:
                package_data = {
                    'id': package.id,
                    'name': package.name,
                    'amount': package.amount,
                    'sub_amount': package.sub_amount,
                    'package_validity': package.package_validity,
                    'package_duration': package.package_duration.name if package.package_duration else '-',
                }
                packages_data.append(package_data)

            subscription_id = request.GET.get('subscription_id')

            subscription = None
            if subscription_id:
                try:
                    subscription = AddSubcription.objects.get(id=subscription_id)
                except AddSubcription.DoesNotExist:
                    raise Http404("Subscription not found")

            # Prepare context with the relevant data
            create_subs = Farmer.objects.filter(Q(status=6) | Q(remaining_days=0, status__in=[0, 1, 3, 4, 5,6])).order_by('-id')
            all_farmers = Farmer.objects.filter(status__in=[0, 1, 3, 4, 5, 6])
            context = {
                # 'farmer_types': farmer_types,
                'farmers': page_obj,  # Paginated farmers list
                'entries_count': subscription_count,
                'show_per_page': show_per_page,
                'all_farmers' : all_farmers,
                'create_subs': create_subs,
                'packages': packages_data,  # Packages data with add-ons 
                'selected_package': selected_package if selected_package else "",
                'filter_status': filter_status if filter_status else "",
                'filter_paymentstatus' : filter_paymentstatus if filter_paymentstatus else '',
                'date_filter': date_filter if date_filter else '',
                'subscriptions_list': page_obj,  # List of subscriptions
                'subscription': subscription,  # Single subscription based on ID
                'farmers_for_subscription': subscription.farmer if subscription else None,  # Farmers related to the subscription
                'packages_for_subscription': subscription.packages if subscription else None,  # Packages related to the subscription
                'can_add_subscription': manage_user.can_add_subscription if manage_user else False,
                'can_view_subscription': manage_user.can_view_subscription if manage_user else False,
                'can_edit_subscription': manage_user.can_edit_subscription if manage_user else False,
                'can_delete_subscription': manage_user.can_delete_subscription if manage_user else False,
                'can_view_unique_subscription': manage_user.can_view_unique_subscription if manage_user else False,
                'can_export_subscription': manage_user.can_export_subscription if manage_user else False,
                'can_filter_subscription': manage_user.can_filter_subscription if manage_user else False,
                'can_activeplan_subscription': manage_user.can_activeplan_subscription if manage_user else False,
                'can_renewalplan_subscription': manage_user.can_renewalplan_subscription if manage_user else False,
            }
            
            return render(request, 'pages/super_admin/subscription_management/list.html', context)

        elif action == 'unsubscribe':
            farmer_id = request.POST.get('farmer_id')
            pack_id = request.POST.get('pack_id')
            sub_id = request.POST.get('sub_id')
            print(farmer_id,sub_id)

            if farmer_id and pack_id and sub_id:

                sub = get_object_or_404(AddSubcription, pk=sub_id)
                if sub:
                    sub.status = 3
                    sub.save()

                farmer = get_object_or_404(Farmer, pk=sub.farmers.id)
                farmer.status = 6
                farmer.remaining_days = None
                farmer.subscription_start_date = None
                farmer.subscription_end_date = None
                farmer.save()
                                
                messages.success(request, "Un Subscribed Successfully!")
            else:
                messages.success(request, "Issue in Un Subscription")

            return redirect('sa_subscription_management')

def subscription_details(request, subscription_id):
    try:
        try:
            settings = GeneralSetting.objects.first()
            date_format = convert_to_strftime_format(settings.date_format)
        except Exception as e:
            date_format = '%d-%m-%Y'
        subscription = AddSubcription.objects.get(id=subscription_id)

        farmer = subscription.farmers
        package = subscription.packages
        farmer_type = farmer.farmertype if farmer else None

        purchase_date = subscription.created_at.strftime(date_format) if subscription.created_at else '-'
        start_date = subscription.startdate.strftime(date_format) if subscription.startdate else '-'
        end_date = subscription.enddate.strftime(date_format) if subscription.enddate else '-'

        # add_on_details = [addon.name for addon in package.get_add_ons()] if package else 'No Add-Ons Available'
        farmer_img = farmer.img.url if farmer and farmer.img else None

        data = {
            'farmer_name': farmer.name if farmer else 'No Farmer Selected',
            'farmer_type': farmer_type.name if farmer_type else '-',
            'phone': farmer.phone if farmer else '-',
            'email': farmer.email if farmer else '-',
            'package_id' : package.id,
            'package_name': package.name if package else '-',
            'package_validity': package.package_validity if package else '-',
            'package_duration': package.package_duration.name if package and package.package_duration else '-',
            'package_amount': subscription.packages.amount if subscription.packages.amount else 0,
            'sub_amount': subscription.packages.sub_amount if subscription.packages.sub_amount else 0,
            'remainingdays' : subscription.remainingdays if subscription.remainingdays else 0,
            'farmer_img': farmer_img ,
            'start_date': start_date,
            'end_date': end_date,
            'purchase_date' : purchase_date,
            # 'add_on_details': add_on_details
        }

        # print(f"Data: {data}")  

        return JsonResponse(data)

    except AddSubcription.DoesNotExist:
        return JsonResponse({'error': 'Subscription not found'}, status=404)

def get_subscriptions_data(request):
    current_year = datetime.now().year

    subscriptions_by_month = AddSubcription.objects.filter(created_at__year=current_year, status= 0) \
        .annotate(month=TruncMonth('created_at')) \
        .values('month') \
        .annotate(subscription_count=Count('id')) \
        .order_by('month')

    month_labels = [calendar.month_name[i] for i in range(1, 13)]

    subscription_counts = [0] * 12  # Array for 12 months
    c=0
    for i in range(1,13):
        sub = AddSubcription.objects.filter(
            status=0,
            created_at__year=current_year,  # Filter by current year
            created_at__month=i  # Filter by current month
        )
        subscription_counts[c] = sub.count()
        c+=1

    return JsonResponse({
        'month_labels': month_labels,
        'subscription_counts': subscription_counts,
    })

def export_subscription(request):
    filter_status = request.GET.get('filter_status')
    selected_package = request.GET.get('Filter_Packages')
    filter_paymentstatus = request.GET.get('filter_paymentstatus')
    date_filter = request.GET.get('dt_fill_issue_rpt')

    latest_active_inactive_expired = AddSubcription.objects.filter(
        Q(status__in=[0, 1, 3, 4]),
        farmers=OuterRef('farmers')
    ).values('farmers').annotate(
        latest_created=Max('created_at')
    ).values('latest_created')

    # Query to get all the records for each farmer
    subscriptions = AddSubcription.objects.filter(
        Q(status=5) | 
        Q(status__in=[0, 1, 3, 4], created_at__in=Subquery(latest_active_inactive_expired))
    ).order_by('-created_at')

    

    if selected_package:
        package = PackageManagement.objects.get(id=selected_package)
        subscriptions = subscriptions.filter(packages=package)  # Assuming there's a many-to-many relationship

    if filter_status:
        subscriptions = subscriptions.filter(status=int(filter_status))

    if filter_paymentstatus:
        subscriptions = subscriptions.filter(payment_status=int(filter_paymentstatus))

    # Handle date filtering logic
    if date_filter == 'today':
        subscriptions = subscriptions.filter(created_at__date=datetime.today())
    elif date_filter == 'week':
        subscriptions = subscriptions.filter(created_at__gte=datetime.today() - timedelta(days=7))
    elif date_filter == 'monthly':
        subscriptions = subscriptions.filter(created_at__month=datetime.today().month)
    elif date_filter == 'custom_date':
        custom_from_date = request.GET.get('filter_date_cfrom')
        custom_to_date = request.GET.get('filter_date_cto')
        if custom_from_date and custom_to_date:
            # Convert the date format from DD-MM-YYYY to YYYY-MM-DD
            custom_from_date = datetime.strptime(custom_from_date, '%d-%m-%Y').date()
            custom_to_date = datetime.strptime(custom_to_date, '%d-%m-%Y').date()
            subscriptions = subscriptions.filter(created_at__date__range=[custom_from_date, custom_to_date])

    # Create a CSV response
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="subscriptions.csv"'

    writer = csv.writer(response)
    # Write the header row
    writer.writerow([
        'Farmers', 'Packages', 'Start Date', 'End Date', 'Amount', 'Remaining Days', 'Status'
    ])

    # Write the worker data
    for sub in subscriptions:
        if sub.status == 0:
            status = 'Active'
        elif sub.status == 1:
            status = 'InActive'
        elif sub.status == 4:
            status = 'Expired'
        elif sub.status == 5:
            status = 'Pending'
        else:
            status = sub.status

        writer.writerow([
            sub.farmers.name,
            sub.packages.name if sub.packages else '-',
            sub.startdate if sub.startdate else '-',
            sub.enddate if sub.enddate else '-',
            sub.packages.sub_amount if sub.packages else '-',
            sub.remainingdays if sub.remainingdays else '0',
            status
        ])

    return response


# ----------------------------------------------------------------------------- Manage Market ---------------------------------------------

def parse_time(time_str):
    time_formats = [
        "%I %p",     # 1 AM or 1 A.M.
        "%I:%M %p",  # 12:00 AM or 12:00 A.M.
        "%I %p",     # 1 a.m. or 1 A.M.
        "%I:%M %p"   # 12:00 a.m. or 12:00 A.M.
    ]
    
    for fmt in time_formats:
        try:
            # Normalize the input by stripping spaces and making it uppercase
            normalized_time_str = time_str.strip().upper().replace('.', '')
            return datetime.strptime(normalized_time_str, fmt).time()
        except ValueError:
            continue  # Try the next format

    raise ValueError(f"Time format not recognized: {time_str}")

def export_market(request):
    markets = ManageMarket.objects.filter(Q(status=0) | Q(status=1))
    # markettype = MarketType.objects.filter(Q(status=0) | Q(status=1))
    # days = Days.objects.filter(Q(status=0) | Q(status=1))

    filter_type = request.GET.get('filter_type', '')
    filter_id = request.GET.get('filter_id', '')
    filter_name = request.GET.get('filter_name', '')
    filter_phone = request.GET.get('filter_phone', '')
    filter_day = request.GET.get('filter_day', '')

    # Apply filters
    if filter_type:
        markets = markets.filter(markettype__code=filter_type)
    if filter_id:
        markets = markets.filter(id=filter_id)
    if filter_name:
        markets = markets.filter(name__icontains=filter_name)
    if filter_phone:
        markets = markets.filter(phone__icontains=filter_phone)
    if filter_day:
        markets = markets.filter(days__code=filter_day).distinct()

    # Create a CSV response
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="markets.csv"'

    writer = csv.writer(response)
    writer.writerow([
        'Name', 'Phone Number','Address', 'Country', 'State', 'District', 'Taluk', 'Village', 'Days', 'Open Time', 'Close Time', 'Market Status'
    ])

    # Write the worker data
    for market in markets:
        days_list = ', '.join(str(day) for day in market.days.all())  # Assuming days is a ManyToMany field
        writer.writerow([
            market.name,
            market.phone if market.phone else '',
            market.address if market.address else '',
            market.country.name if market.country else '',
            market.state.name if market.country else '',
            market.city.name if market.country else '',
            market.taluk.name if market.country else '',
            market.village.name if market.country else '',
            days_list,
            market.openingtime,
            market.closingtime,
            'Active' if market.status == 0 else 'InActive'
        ])

    return response

def export_staff(request):
    staffs = ManageUser.objects.filter(Q(status=0) | Q(status=1)).annotate(
        allocated_market_count=Count('allocatemarket__markets')
    ).filter(allocated_market_count__gt=0)

    # Create a CSV response
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="Allocated_Markets.csv"'

    writer = csv.writer(response)
    # Write the header row
    writer.writerow([
        'Staff Name','Staff Phone Number', 'Status', 'Market Name','Market Address', 'Market Country', 'Market State', 'Market District', 'Market Taluk', 'Market Village', 'Market Phone Number', 'Market Days', 'Market Open Time', 'Market Close Time'
    ])

    # Write the worker data
    for s in staffs:
        if s.status == 0:
            status = 'Active'
        elif s.status == 1:
            status = 'Inactive'
        else:
            status = s.status
        
        for allocation in s.allocatemarket_set.filter(status=0):
            for market in allocation.markets.all():
                writer.writerow([
                    s.name,
                    s.mobile_no,
                    status,
                    market.name,
                    market.address if market.address else '',
                    market.country.name if market.country else '',
                    market.state.name if market.country else '',
                    market.city.name if market.country else '',
                    market.taluk.name if market.country else '',
                    market.village.name if market.country else '',
                    market.phone if market.phone else '',
                    ', '.join([day.name for day in market.days.all()]),
                    market.openingtime.strftime('%I:%M %p') if market.openingtime else '-',
                    market.closingtime.strftime('%I:%M %p') if market.closingtime else '-',
                ])

    return response

class ManageMarketView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_market': True,
                'can_view_market': True,
                'can_edit_market': True,
                'can_delete_market': True, 
                'can_view_unique_market': True, 
                'can_export_market':True,
                'can_filter_market':True,
                'can_status_market':True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_market:
                return redirect('user_not_allowed') 
            
        search_query = request.GET.get('search', '')
        markets = ManageMarket.objects.filter(
            Q(status=0) | Q(status=1),
            Q(name__icontains=search_query) | Q(description__icontains=search_query)
        ).order_by('-id') 
        days = Days.objects.filter(Q(status=0) | Q(status=1))
 
        filter_name = request.GET.get('filter_name', '')
        filter_phone = request.GET.get('filter_phone', '')
        filter_day = request.GET.get('filter_day', '')

        
        if filter_name:
            markets = markets.filter(name__icontains=filter_name)
        if filter_phone:
            markets = markets.filter(phone__icontains=filter_phone)
        if filter_day:
            markets = markets.filter(days__code=filter_day).distinct()
        
        show_per_page = request.GET.get('show',25)
        show_per_page = int(show_per_page)
        paginator = Paginator(markets, show_per_page)   
        page_number = request.GET.get('page')
        page_obj = paginator.get_page(page_number)

        markets_count = 0
        for i in page_obj:
            markets_count += 1
        
        total_market_count = ManageMarket.objects.filter(status__in=[0, 1]).count()

        context = {
            'markets': page_obj,
            'total_market_count': total_market_count,
            'entries_count': markets_count,
            'show_per_page': show_per_page,
            'days': days, 
            'filter_name': filter_name if filter_name else '',
            'filter_phone': filter_phone if filter_phone else '',
            'filter_day': filter_day if filter_day else '',
            'countries': list(Country.objects.values('id', 'name')),
            'states': list(State.objects.values('id', 'name')),
            'cities': list(City.objects.values('id', 'name')),
            'taluks' : list(Taluk.objects.values('id', 'name')),
            'villages' : list(Village.objects.values('id', 'name')),
            'can_add_market': manage_user.can_add_market if manage_user else False,
            'can_view_market': manage_user.can_view_market if manage_user else False,
            'can_edit_market': manage_user.can_edit_market if manage_user else False,
            'can_delete_market': manage_user.can_delete_market if manage_user else False,
            'can_view_unique_market': manage_user.can_view_unique_market if manage_user else False,
            'can_export_market': manage_user.can_export_market if manage_user else False,
            'can_filter_market': manage_user.can_filter_market if manage_user else False,
            'can_status_market': manage_user.can_status_market if manage_user else False, 
        }
        return render(request, 'pages/super_admin/market_management/manage_market/list.html', context)

    def post(self, request):
        # user_id = self.request.user.id
        # user = get_object_or_404(CustomUser, id=user_id)
        markets = ManageMarket.objects.filter(Q(status=0) | Q(status=1))
        # markettype = MarketType.objects.filter(Q(status=0) | Q(status=1))
        days = Days.objects.filter(Q(status=0) | Q(status=1))
        action = request.POST.get('action')
        lat_log = ['°','N', 'E', 'S', 'W']

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            # market_type = request.POST.get('market_type')
            # if market_type:
            #     type =  get_object_or_404(MarketType, code=market_type)
            open_time = request.POST.get('opening_time')
            close_time = request.POST.get('closing_time')
            add_days = request.POST.getlist('add_days')
            # add_latitude = request.POST.get('add_latitude')
            # add_longitude = request.POST.get('add_longitude')
            # if contains_lat_log(lat_log, add_latitude) == False and contains_lat_log(lat_log, add_longitude) == False:
            #     add_latitude, add_longitude = convert_to_simplified_format(add_latitude, add_longitude)
            add_phone = request.POST.get('add_phone')
            add_address = request.POST.get('add_address')
            market_image =request.FILES.get('market_image') 
            door_no = request.POST.get('door_no', '')
            pincode = request.POST.get('pincode', '')
            village_id = request.POST.get('village')
            if not village_id:
                # messages.error(request, "Village is required.")
                return redirect('sa_manage_market')

            try:
                village = Village.objects.get(id=village_id)
            except Village.DoesNotExist:
                messages.error(request, "The selected village does not exist.")
                return redirect('sa_manage_market')

            # Validate taluk, city, state, and country
            taluk_id = request.POST.get('taluk')
            city_id = request.POST.get('city')
            state_id = request.POST.get('state')
            country_id = request.POST.get('country')

            if not taluk_id or not city_id or not state_id or not country_id:
                messages.error(request, "Taluk, city, state, and country are required.")
                return redirect('sa_manage_market')

            try:
                taluk = Taluk.objects.get(id=taluk_id)
                city = City.objects.get(id=city_id)
                state = State.objects.get(id=state_id)
                country = Country.objects.get(id=country_id)
            except (Taluk.DoesNotExist, City.DoesNotExist, State.DoesNotExist, Country.DoesNotExist):
                messages.error(request, "Invalid taluk, city, state, or country.")
                return redirect('sa_manage_market')
            
            markets = ManageMarket.objects.all()
            products = ManageProduct.objects.all() 
            if not name:
                context = {
                    'markets': markets,
                    'error': 'This field is required.'
                }
                return render(request, 'pages/super_admin/market_management/manage_market/list.html', context)

            if ManageMarket.objects.filter(name=name).exists():
                context = {
                    'markets': markets,
                    'error': f'Market "{name}" already exists.'
                }
                return render(request, 'pages/super_admin/market_management/manage_market/list.html', context)

            if open_time:
                open_time = datetime.strptime(open_time, '%I:%M %p').strftime('%H:%M:%S')
            if close_time:
                close_time = datetime.strptime(close_time, '%I:%M %p').strftime('%H:%M:%S')
            ManageMarket.objects.create(name=name,   openingtime=open_time,
                                        city=city,state=state,country=country,village=village,taluk=taluk,
                                        closingtime=close_time,  description=description,
                                        # latitude=add_latitude, longitude=add_longitude,
                                        status=0, phone=add_phone,door_no=door_no, pincode=pincode,created_at=timezone.now() )
            
            for day_code in add_days:
                market = get_object_or_404(ManageMarket, name=name)
                day = Days.objects.get(code=day_code)
                market.days.add(day)
            if market_image:
                market = get_object_or_404(ManageMarket, name=name)
                market.img =market_image
                market.save()
            if add_phone:
                market = get_object_or_404(ManageMarket, name=name)
                market.phone =add_phone
                market.save()
            if add_address:
                market = get_object_or_404(ManageMarket, name=name)
                market.address =add_address
                market.save()
            
            address_parts = []
            if market.door_no:
                address_parts.append(door_no)
            if market.village:
                address_parts.append(village.name)
            if market.taluk:
                address_parts.append(taluk.name)
            if market.city:
                address_parts.append(city.name)
            if market.state:
                address_parts.append(state.name)
            if market.country:
                address_parts.append(country.name)
            if market.pincode:
                address_parts.append(pincode)

            full_address = ', '.join(address_parts)
            market.address = full_address
            market.save()
            
            if products:
                for i in products:
                    market.products.add(i)
                    product = get_object_or_404(ManageProduct, id=i.id)
                    product.markets.add(market)
                    # product.updated_by = user
                    product.save()
                market.save()
            
            messages.success(request, 'Market created successfully.')
            return redirect('sa_manage_market')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                markets = get_object_or_404(ManageMarket, pk=pk) 
                status = request.POST.get('status') 
                if status == '0':
                    markets.status = 0   
                    # markets.updated_by=user
                    markets.save()
                    messages.success(request, "Market has been activated.") 
                elif status == '1':
                    markets.status = 1  
                    # markets.updated_by=user
                    markets.save()
                    messages.success(request, "Market has been deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_manage_market')   
        
        elif action == 'update':
            pk = request.POST.get('id')
            market = get_object_or_404(ManageMarket, pk=pk)
            translated_json = market.translate_json or {
                'name' : {},
                "door_no": {},
                "description": {}
            }
            name = request.POST.get('update_name')
            description = request.POST.get('update_description') 
            open_time = request.POST.get('edit_open_time')
            try:
                parsed_time = parse_time(open_time)
                formatted_Otime = parsed_time.strftime("%H:%M:%S")
            except ValueError as e: 
                pass
            
            close_time = request.POST.get('edit_close_time')
            try:
                parsed_time = parse_time(close_time)
                formatted_Ctime = parsed_time.strftime("%H:%M:%S")
            except ValueError as e: 
                pass

            add_days = request.POST.getlist('update_days')
            # add_latitude = request.POST.get('edit_latitude')
            # add_longitude = request.POST.get('edit_longitude')
            # if contains_lat_log(lat_log, add_latitude) == False and contains_lat_log(lat_log, add_longitude) == False:
            #     add_latitude, add_longitude = convert_to_simplified_format(add_latitude, add_longitude)
            market_image =request.FILES.get('update_image')
            markets = ManageMarket.objects.all()
            add_phone = request.POST.get('edit_phone')
            add_address = request.POST.get('edit_address')

            if not name:
                context = {
                    'markets': markets,
                    'error': 'This field is required.'
                }
                return render(request, 'pages/super_admin/market_management/manage_market/list.html', context)
            
            door_no = request.POST.get('door_no')
            village_id = request.POST.get('edit_village')
            taluk_id = request.POST.get('edit_taluk')
            city_id = request.POST.get('edit_city')
            state_id = request.POST.get('edit_state')
            country_id = request.POST.get('edit_country')
            pincode = request.POST.get('pincode')

            village = Village.objects.get(id=village_id)
            taluk = Taluk.objects.get(id=taluk_id)
            city = City.objects.get(id=city_id)
            state = State.objects.get(id=state_id)
            country = Country.objects.get(id=country_id) 
            if market.name != name:
                market.name = name 
                try:
                    for lang in target_language:
                        translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                        translated_json["name"][lang] = translated_text
                except Exception as e:
                    print(e)
                    print("Error in translation")
            # market.latitude = add_latitude
            # market.longitude = add_longitude
            market.phone = add_phone
            market.address = add_address
            market.openingtime = formatted_Otime
            market.closingtime = formatted_Ctime
            if market.description != description:
                market.description = description
                try:
                    for lang in target_language:
                        translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                        translated_json["description"][lang] = translated_text
                except Exception as e:
                    print(e)
                    print("Error in translation")
            if door_no:
                if market.door_no != door_no:
                    market.door_no = door_no
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(door_no)
                            translated_json["door_no"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translation")
            else:
                market.door_no = ''
            market.country = country
            market.village = village
            market.taluk = taluk
            market.city = city
            market.state = state
            market.pincode = pincode
            market.status = 0 
            market.translate_json = translated_json
            market.save()

            market.days.clear()
            for day_code in add_days:
                day = Days.objects.get(code=day_code)
                market.days.add(day)
            if market_image:
                market.img =market_image
                market.save()
            if add_phone:
                market.phone = add_phone
                market.save()
            if add_address:
                market.address = add_address
                market.save()

            address_parts = []
            if market.door_no:
                address_parts.append(door_no)
            if market.village:
                address_parts.append(village.name)
            if market.taluk:
                address_parts.append(taluk.name)
            if market.city:
                address_parts.append(city.name)
            if market.state:
                address_parts.append(state.name)
            if market.country:
                address_parts.append(country.name)
            if market.pincode:
                address_parts.append(pincode)

            full_address = ', '.join(address_parts)
            market.address = full_address
            market.save()
            
            messages.success(request, 'Market Updated successfully.')
            return redirect('sa_manage_market')

        elif action == 'delete':
            pk = request.POST.get('id')
            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    markets = get_object_or_404(ManageMarket, pk=pk)   
                    markets.delete()
                    # markets.status = 2  
                    # markets.updated_by=user
                    # markets.save()

                    messages.success(request, "Market has been deleted successfully.")  
                except ManageMarket.DoesNotExist:
                    messages.error(request, "Market not found.")  

            return redirect('sa_manage_market') 

        elif action == 'filter':
            user = request.user
            manage_user = None
            if user.is_superuser:
                context = {
                    'can_add_market': True,
                    'can_view_market': True,
                    'can_edit_market': True,
                    'can_delete_market': True, 
                    'can_view_unique_market': True, 
                    'can_export_market':True,
                    'can_filter_market':True,
                    'can_status_market':True, 
                }
            else:
                try:
                    manage_user = ManageUser.objects.get(custom_user_id=user.id)
                except ManageUser.DoesNotExist:
                    manage_user = None

                if manage_user and not manage_user.can_view_market:
                    return redirect('user_not_allowed') 
                
            search_query = request.GET.get('search', '')
            markets = ManageMarket.objects.filter(
                Q(status=0) | Q(status=1),
                Q(name__icontains=search_query) | Q(description__icontains=search_query)
            ).order_by('-id') 
            days = Days.objects.filter(Q(status=0) | Q(status=1))
    
            filter_id = request.GET.get('filter_id', '')
            filter_name = request.POST.get('filter_name', '')
            filter_phone = request.POST.get('filter_phone', '')
            filter_day = request.POST.get('filter_day', '')
            # print("Filter Type:", filter_type)
            # print("Filter Day:", filter_day) 

            if not filter_name and not filter_phone and not filter_day:
                return redirect('sa_manage_market') 

    
            if filter_id:
                markets = markets.filter(id=filter_id)
            if filter_name:
                markets = markets.filter(name__icontains=filter_name)
            if filter_phone:
                markets = markets.filter(phone__icontains=filter_phone)
            if filter_day:
                markets = markets.filter(days__code=filter_day).distinct()

            paginator = Paginator(markets, 10) 
            page_number = request.GET.get('page')  
            page_obj = paginator.get_page(page_number) 

            # Prepare context including filter values
            total_market_count = ManageMarket.objects.filter(status__in=[0, 1]).count()
            context = {
                'markets': page_obj,
                # 'markettype': markettype,
                'total_market_count': total_market_count,
                'days': days, 
                'filter_id': filter_id,
                'filter_name': filter_name if filter_name else '',
                'filter_phone': filter_phone if filter_phone else '',
                'filter_day': filter_day if filter_day else '',
                'countries': list(Country.objects.values('id', 'name')),
                'states': list(State.objects.values('id', 'name')),
                'cities': list(City.objects.values('id', 'name')),
                'taluks' : list(Taluk.objects.values('id', 'name')),
                'villages' : list(Village.objects.values('id', 'name')),
                
                'can_add_market': manage_user.can_add_market if manage_user else False,
                'can_view_market': manage_user.can_view_market if manage_user else False,
                'can_edit_market': manage_user.can_edit_market if manage_user else False,
                'can_delete_market': manage_user.can_delete_market if manage_user else False,
                'can_view_unique_market': manage_user.can_view_unique_market if manage_user else False,
                'can_export_market': manage_user.can_export_market if manage_user else False,
                'can_filter_market': manage_user.can_filter_market if manage_user else False,
                'can_status_market': manage_user.can_status_market if manage_user else False, 
            }
            return render(request, 'pages/super_admin/market_management/manage_market/list.html', context)

        return redirect('sa_manage_market') 
 
class AllocateMarketView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_allocate_market': True,
                'can_view_allocate_market': True,
                'can_edit_allocate_market': True,
                'can_delete_allocate_market': True, 
                'can_view_unique_allocate_market': True, 
                'can_export_allocate_market':True, 
                'can_status_allocate_market':True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_allocate_market:
                return redirect('user_not_allowed')  
            
        # search_query = request.GET.get('search', '')
        all_staffs = ManageUser.objects.filter(
            market_price_updater=True
        ).filter(
            Q(status=0)
        ).order_by('-id')
        
        staffs = ManageUser.objects.filter(status__in=[0,1,3,4]).annotate(
            allocated_market_count=Count('allocatemarket__markets')
        ).filter(allocated_market_count__gt=0).order_by('-id')

        allocatedmarkert = AllocateMarket.objects.filter(
            Q(status=0) | Q(status=1)
            
        ).order_by('-id')

        managemarket = ManageMarket.objects.filter(Q(status=0))

        # Prepare a dictionary to store allocated markets for each staff
        staff_market_data = {}
        for staff in staffs:
            markets = []
            description = ''
            for allocation in staff.allocatemarket_set.filter(status=0):
                description = allocation.description if allocation.status == 0 else ''
                for market in allocation.markets.all():
                    markets.append({
                        'id':market.id,
                        'name': market.name,
                        'address': market.address if market.address else '',
                        'phone': market.phone if market.phone else '',
                        'days': ', '.join([day.name for day in market.days.all()]),
                        'opening_time': market.openingtime.strftime('%I:%M %p') if market.openingtime else '-',
                        'closing_time': market.closingtime.strftime('%I:%M %p') if market.closingtime else '-',
                        'img_url': market.img.url if market.img else '/images/default.png',
                        # 'type': 'Physical' if market.markettype.code == 0 else 'Online'
                    })
            staff_market_data[staff.id] = {
                'name': staff.name,
                'phone' : staff.mobile_no,
                'date' : staff.created_at.strftime('%d-%m-%Y'),
                'markets': markets,
                'description': description,
            }

        # Create a simplified version for the modal
        staff_modal_data = {
            staff.id: {
                'description': data['description'],
                'markets': data['markets'],
            }
            for staff_id, data in staff_market_data.items()
        }
        # print(staff_market_data)

        show_per_page = request.GET.get('show',25)
        show_per_page = int(show_per_page)
        paginator = Paginator(staffs, show_per_page)
        page_number = request.GET.get('page')
        page_obj = paginator.get_page(page_number)

        staffs_count = 0
        staff_market_names = {}
        for staff in page_obj:
            staffs_count += 1
            market_names = []
            for allocation in staff.allocatemarket_set.filter(status=0):
                for market in allocation.markets.all():
                    market_names.append(market.name)
            staff_market_names[staff.id] = market_names
        
        context = {
            'all_staffs': all_staffs,
            'staff_market_names': staff_market_names,
            'staffs': page_obj,
            'entries_count': staffs_count,
            'show_per_page': show_per_page,
            'managemarket': managemarket,
            'staff_market_data': staff_market_data,
            'staff_modal_data': staff_modal_data,
            'can_add_allocate_market': manage_user.can_add_allocate_market if manage_user else False,
            'can_view_allocate_market': manage_user.can_view_allocate_market if manage_user else False,
            'can_edit_allocate_market': manage_user.can_edit_allocate_market if manage_user else False,
            'can_delete_allocate_market': manage_user.can_delete_allocate_market if manage_user else False,
            'can_view_unique_allocate_market': manage_user.can_view_unique_allocate_market if manage_user else False,
            'can_export_allocate_market': manage_user.can_export_allocate_market if manage_user else False, 
            'can_status_allocate_market': manage_user.can_status_allocate_market if manage_user else False, 
        }
        return render(request, 'pages/super_admin/market_management/manage_allocated_market/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            staff_id = request.POST.get('add_staff_name')
            staff = get_object_or_404(ManageUser, id=staff_id)
            description = request.POST.get('add_description')
            selected_markets = request.POST.getlist('add_check_market')
            print("list:",selected_markets)

            if not staff_id:
                 messages.error(request, "Invalid Input") 
            
            # old_allocated = AllocateMarket.objects.filter(staff=staff,markets__in=selected_markets)
            old_allocated = AllocateMarket.objects.filter(staff=staff)
            if old_allocated:
                for a in old_allocated:
                    a.delete()

            allocate_market_instance = AllocateMarket.objects.create(staff=staff, description=description,created_by=user, created_at=timezone.now())
            # Now set the markets using the set() method
            allocate_market_instance.markets.set(selected_markets)
            messages.success(request, "Allocated Markets Created Successfully.")  

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                staffs = get_object_or_404(ManageUser, pk=pk) 
                
                status = request.POST.get('status') 

                if status == '0':
                    staffs.status = 0   
                    staffs.updated_by=user
                    staffs.save()
                    messages.success(request, "Staffs has been activated.") 
                elif status == '1':
                    staffs.status = 1  
                    staffs.updated_by=user
                    staffs.save()
                    messages.success(request, "Staffs has been deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_manage_allocated_market')   

        elif action == 'delete':
            pk = request.POST.get('id')
            # print(pk)
            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    staffs = get_object_or_404(ManageUser, pk=pk)   
                    allocated = AllocateMarket.objects.filter(staff=staffs)
                    for i in allocated:
                        i.delete()

                    messages.success(request, "Staff has been deactivated successfully.")  
                except Detection.DoesNotExist:
                    messages.error(request, "Staff not found.")  

            return redirect('sa_manage_allocated_market') 

        elif action == 'update':
            staff_id = request.POST.get('edit_staff_name')
            staff = get_object_or_404(ManageUser, id=staff_id)
            description = request.POST.get('edit_allocated_description')
            selected_markets = request.POST.getlist('check_allocated_market')

            if not staff_id:
                 messages.error(request, "Invalid Input") 

            AllocateMarket.objects.filter(staff=staff).delete()  # Clear previous allocations
            allocate_market_instance = AllocateMarket.objects.create(staff=staff, description=description,created_by=user,updated_by=user)
            allocate_market_instance.markets.set(selected_markets)
            messages.success(request, "Allocated Markets Updated successfully.")  
            return redirect('sa_manage_allocated_market')
        
        return redirect('sa_manage_allocated_market')
    
def get_allocated_markets(request):
    staff_id = request.GET.get("staff_id")
    if staff_id:
        allocated_markets = AllocateMarket.objects.filter(Q(staff_id=staff_id)).values_list("markets__id", flat=True)
        return JsonResponse(list(allocated_markets), safe=False)
    return JsonResponse([], safe=False)

def filter_markets_by_type(request):
    market_type_id = request.GET.get('market_type', None)
    if market_type_id:
        markets = ManageMarket.objects.filter(markettype__id=market_type_id)
    else:
        markets = ManageMarket.objects.all()
    markets_data = []
    for market in markets:
        market_data = {
            'id': market.id,
            'name': market.name,
        }
        markets_data.append(market_data)
    return JsonResponse({'status': 200,
        'markets': markets_data
    })

def contains_lat_log(symbol_list, value):
    for symbol in symbol_list:
        if symbol in value:
            return True
    return False

def convert_to_simplified_format(latitude, longitude):
    # Round latitude and longitude to 4 decimal places
    # latitude_simplified = round(latitude, 4)
    # longitude_simplified = round(longitude, 4)

    # Prepare the formatted string
    latitude_result = f"{latitude}° N"
    longitude_result = f"{longitude}° E"

    return latitude_result, longitude_result

# --------------------------------------------------------------------------- Market Price Chart --------------------------------------

class ProductVsPriceView(LoginRequiredMixin,View):
    def post(self, request, *args, **kwargs):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        product_id = request.POST.get('id')  
        name = request.POST.get('name')
        # market_ids = request.POST.getlist('markets') 

        action = request.POST.get('action', '')
        if action == 'filter':
            user = request.user
            manage_user = None
            if user.is_superuser:
                context = { 
                    'can_add_manage_product' : True,
                    'can_view_manage_product' : True,
                    'can_edit_manage_product' : True,
                    'can_delete_manage_product' : True,
                    'can_filter_manage_product' : True,
                    'can_update_manage_product' : True,
                    'can_graph_manage_product' : True,
                    'can_staff_manage_product': True,
                }
            else:
                try:
                    manage_user = ManageUser.objects.get(custom_user_id=user.id)
                except ManageUser.DoesNotExist:
                    manage_user = None

                if manage_user and not manage_user.can_view_manage_product:
                    return redirect('user_not_allowed') 
                
            product_ids = request.POST.get('product_id') 
            market_id = request.POST.get('market_id')
            user_id = request.POST.get('user_id')

            products = ManageProduct.objects.all()
            # allproducts = ManageProduct.objects.all()
            markets = ManageMarket.objects.all()
    
            if product_ids:
                try:
                    product = ManageProduct.objects.get(id=product_ids)
                    products = products.filter(id=product.id)
                    market_ids = product.markets.values_list('id', flat=True)
                except ManageProduct.DoesNotExist:
                    messages.error(request, "Product not found.")
                    return redirect('sa_product_vs_price')
            else:
                market_ids = []
    

            product_market_data = []

            for product in products: 
                product_data = {
                    "id": product.id,
                    "name": product.name,
                    "market_ids": ', '.join(map(str, market_ids)),
                    "market": [
                            market.id for market in product.markets.all()
                    ]
                }
                
                product_market_data.append(product_data)
    

    
            if market_id and market_id != 'None':   
                markets = markets.filter(id=market_id)

            if market_ids:
                markets = markets.filter(id__in=market_ids)
    

            product_market_prices = {}
            for product in products:
                for market in markets:
                    market_product = MarketProduct.objects.filter(market=market, product=product).order_by('-updated_at').first()
                    if market_product:
                        product_market_prices[(product.id, market.id)] = {
                            'product_id': product.id,
                            'product_name': product.name,
                            'market_id': market.id,
                            'market_name': market.name,
                            'price': market_product.price,
                            'available': market_product.available,
                            'updated_at': market_product.updated_at,  # This should point to the market product's updated_at
                        }
                    else:
                        product_market_prices[(product.id, market.id)] = {
                            'product_id': product.id,
                            'product_name': product.name,
                            'market_id': market.id,
                            'market_name': market.name,
                            'price': 0,
                            'available': False,
                            'updated_at': None,
                        }

            # **New User Filtering Logic**
            if user_id:
                allocations = AllocateMarket.objects.filter(staff__id=user_id)
                markets = markets.filter(id__in=allocations.values_list('markets', flat=True))
                # product_market_prices = list(product_market_prices.values())

            product_market_prices = list(product_market_prices.values())

            market_staff = {}
            allocations = AllocateMarket.objects.prefetch_related('staff', 'markets').all()
            for allocation in allocations:
                for market in allocation.markets.all():
                    if market.id not in market_staff:
                        market_staff[market.id] = []
                    if allocation.staff:
                        market_staff[market.id].append(allocation.staff.name)

            market_staff_list = [(market_id, staff_names) for market_id, staff_names in market_staff.items()]

        # Staff filtering logic
            staff = ManageUser.objects.none()
            if market_id:
                staff_allocations = AllocateMarket.objects.filter(markets__id=market_id)
                staff = ManageUser.objects.filter(allocatemarket__in=staff_allocations)

            if not user_id:
                all_staff = ManageUser.objects.all()
            else:
                all_staff = staff.filter(id=user_id)


            # market_types = MarketType.objects.all()

            # print(product_data['market'])
            # print("val:",allproducts)

            market_updates = {}
            market_price_update = {}
            mar_product = MarketProduct.objects.all()
            for i in mar_product:
                    # print(i,i.price)
                    if i.updated_at != None:
                        market_updates[i.market.name] = i.updated_at
                    else:
                        market_updates[i.market.name] = i.created_at
                    # print("mar:",i.market.name," up:",i.updated_at)
                    if i.market.name not in market_price_update:
                        if i.available:
                            market_price_update[i.market.name] = 1
                        else:
                            market_price_update[i.market.name] = i.price
                    else:
                        if i.price > market_price_update[i.market.name]:
                            market_price_update[i.market.name] = i.price
            # print("mar up:",market_updates)
            # print(market_price_update)
            all_products = ManageProduct.objects.all()
            all_users = ManageUser.objects.filter(market_price_updater=True)
            # selected_market_ids = product.markets.values_list('id', flat=True)
            marketss_details ={}
            all_markets = ManageMarket.objects.all()
            for i in all_markets:
                marketss_details[i.id] = {
                    'name': i.name,
                    # 'type': i.markettype.name,
                    'phone': i.phone,
                    'address': i.address,
                }
            context = {
                'product_count': products.count(),
                'market_count': markets.count(),
                'markets': markets,
                'products': products,
                'market_staff_list': market_staff_list,
                'product_market_prices': product_market_prices,
                # 'market_types': market_types,
                'staff': all_staff,
                'selected_product': product_ids if product_ids else '',
                # 'selected_market_type': market_type_id if market_type_id else '',
                'selected_market': market_id if market_id else '',
                'selected_staff': user_id if user_id else '',
                'product_market_data': product_market_data, 
                'market_updates': market_updates,
                'market_price_update': market_price_update,
                'market_ids': market_ids,
                # 'selected_market_ids': list(selected_market_ids),
                'all_markets': all_markets,
                'all_products': all_products,
                'all_staff': all_users,
                'marketss_details': marketss_details,
                'today' : datetime.now(),
                'can_add_manage_product': manage_user.can_add_manage_product if manage_user else False,
                'can_view_manage_product': manage_user.can_view_manage_product if manage_user else False, 
                'can_edit_manage_product': manage_user.can_edit_manage_product if manage_user else False,
                'can_delete_manage_product': manage_user.can_delete_manage_product if manage_user else False,
                'can_filter_manage_product': manage_user.can_filter_manage_product if manage_user else False,
                'can_update_manage_product': manage_user.can_update_manage_product if manage_user else False, 
                'can_graph_manage_product': manage_user.can_graph_manage_product if manage_user else False,
                'can_staff_manage_product': manage_user.can_staff_manage_product if manage_user else False,
            }
            # print("marketsssss:",context['product_market_data'])
            return render(request, 'pages/super_admin/market_price_chart/product_vs_price/list.html', context)

        if not name:
            messages.error(request, "Product name is required.")
            return redirect('sa_product_vs_price')

        if product_id:
            try:
                product = ManageProduct.objects.get(id=product_id)
            except ManageProduct.DoesNotExist:
                messages.error(request, "Product not found.")
                return redirect('sa_product_vs_price')

            if ManageProduct.objects.filter(name=name).exclude(id=product.id).exists():
                messages.error(request, "A product with this name already exists.")
                return redirect('sa_product_vs_price')

            translated_json = product.translate_json or {
                'name' : {}
            }

            if product.name != name:
                product.name = name
                try:
                    for lang in target_language:
                        translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                        translated_json["name"][lang] = translated_text
                except Exception as e:
                    print(e)
                    print("Error in translation")
            product.updated_by = user
            product.translate_json = translated_json
            product.save()
            messages.success(request, "Product updated successfully.")

        else:
            if ManageProduct.objects.filter(name=name).exists():
                messages.error(request, "A product with this name already exists.")
                return redirect('sa_product_vs_price')

            market = ManageMarket.objects.filter(status=0)

            product = ManageProduct.objects.create(
                name=name,
                created_by= user,
                created_at=timezone.now()
            )
            market_ids = []
            for m in market:
                product.markets.add(m)
                market_ids.append(m.id)

            for market_id in market_ids:
                try:
                    market = ManageMarket.objects.get(id=market_id)
                    if product not in market.products.all():
                        market.products.add(product)
                except ManageMarket.DoesNotExist:
                    continue
            
            product.save()
            messages.success(request, "Product created successfully.")

        return redirect('sa_product_vs_price')

    def get(self, request, *args, **kwargs):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = { 
                'can_add_manage_product' : True,
                'can_view_manage_product' : True,
                'can_edit_manage_product' : True,
                'can_delete_manage_product' : True,
                'can_filter_manage_product' : True,
                'can_update_manage_product' : True,
                'can_graph_manage_product' : True,
                'can_staff_manage_product': True,
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_manage_product:
                return redirect('user_not_allowed') 
          
        product_ids = request.GET.get('product_id') 
        market_id = request.GET.get('market_id')
        user_id = request.GET.get('user_id')

        products = ManageProduct.objects.all().order_by('id')
        markets = ManageMarket.objects.all().order_by('-id')
 
        if product_ids:
            try:
                product = ManageProduct.objects.get(id=product_ids)
                products = products.filter(id=product.id)
                market_ids = product.markets.values_list('id', flat=True)
            except ManageProduct.DoesNotExist:
                messages.error(request, "Product not found.")
                return redirect('sa_product_vs_price')
        else:
            market_ids = []

        product_market_data = []
        for product in products: 
            product_data = {
                "id": product.id,
                "name": product.name,
                "market_ids": ', '.join(map(str, market_ids)),
                "market": [
                        market.id for market in product.markets.all()
                ]
            }
            product_market_data.append(product_data)

        if market_id and market_id != 'None':   
            markets = markets.filter(id=market_id)

        if market_ids:
            markets = markets.filter(id__in=market_ids)

        product_market_prices = {}
        for product in products:
            for market in markets:
                market_product = MarketProduct.objects.filter(market=market, product=product).order_by('-updated_at').first()
                if market_product:
                    product_market_prices[(product.id, market.id)] = {
                        'product_id': product.id,
                        'product_name': product.name,
                        'market_id': market.id,
                        'market_name': market.name,
                        'price': market_product.price,
                        'available': market_product.available,
                        'updated_at': market_product.updated_at,  # This should point to the market product's updated_at
                    }
                else:
                    product_market_prices[(product.id, market.id)] = {
                        'product_id': product.id,
                        'product_name': product.name,
                        'market_id': market.id,
                        'market_name': market.name,
                        'price': 0,
                        'available': False,
                        'updated_at': None,
                    }

         # **New User Filtering Logic**
        
        if user_id:
            allocations = AllocateMarket.objects.filter(staff__id=user_id)
            markets = markets.filter(id__in=allocations.values_list('markets', flat=True))
            # product_market_prices = list(product_market_prices.values())

        product_market_prices = list(product_market_prices.values())

        allowed_edit_market_ids = []
        if user.is_superuser:
            for i in markets:
                allowed_edit_market_ids.append(i.id)

        market_staff = {}
        allocations = AllocateMarket.objects.prefetch_related('staff', 'markets').all()
        for allocation in allocations:
            for market in allocation.markets.all():
                if market.id not in market_staff:
                    market_staff[market.id] = []
                if allocation.staff:
                    market_staff[market.id].append(allocation.staff.name)
                    if manage_user:
                        if manage_user.id == allocation.staff.id:
                            allowed_edit_market_ids.append(market.id)

        market_staff_list = [(market_id, staff_names) for market_id, staff_names in market_staff.items()]

        # Staff filtering logic
        staff = ManageUser.objects.none()
        if market_id:
            staff_allocations = AllocateMarket.objects.filter(markets__id=market_id)
            staff = ManageUser.objects.filter(allocatemarket__in=staff_allocations)

        if not user_id:
            all_staff = ManageUser.objects.all()
        else:
            all_staff = staff.filter(id=user_id)


        # market_types = MarketType.objects.all()

        # print(product_data['market'])
        # print("val:",allproducts)

        market_updates = {}
        market_price_update = {}
        mar_product = MarketProduct.objects.all()
        for i in mar_product:
            # print(i,i.price)
            if i.updated_at != None:
                market_updates[i.market.name] = i.updated_at
            else:
                market_updates[i.market.name] = i.created_at
            # print("mar:",i.market.name," up:",i.updated_at)
            if i.market.name not in market_price_update:
                if i.available:
                    market_price_update[i.market.name] = 1
                else:
                    market_price_update[i.market.name] = i.price
            else:
                if i.price > market_price_update[i.market.name]:
                    market_price_update[i.market.name] = i.price
       
        all_products = ManageProduct.objects.all()
        all_users = ManageUser.objects.filter(market_price_updater=True)
        # selected_market_ids = product.markets.values_list('id', flat=True)
        marketss_details ={}
        all_markets = ManageMarket.objects.all()
        for i in all_markets:
            marketss_details[i.id] = {
                'name': i.name,
                # 'type': i.markettype.name,
                'phone': i.phone,
                'address': i.address,
            }
        context = {
            'product_count': products.count(),
            'market_count': markets.count(),
            'markets': markets,
            'products': products,
            'market_staff_list': market_staff_list,
            'product_market_prices': product_market_prices,
            # 'market_types': market_types,
            'staff': all_staff,
            'selected_product': product_ids if product_ids else '',
            # 'selected_market_type': market_type_id if market_type_id else '',
            'selected_market': market_id if market_id else '',
            'selected_staff': user_id if user_id else '',
            'product_market_data': product_market_data, 
            'market_updates': market_updates,
            'market_price_update': market_price_update,
            'market_ids': market_ids,
            # 'selected_market_ids': list(selected_market_ids),
            'all_markets': all_markets,
            'all_products': all_products,
            'all_staff': all_users,
            'marketss_details': marketss_details,
            'today' : datetime.now(),
            'can_add_manage_product': manage_user.can_add_manage_product if manage_user else False,
            'can_view_manage_product': manage_user.can_view_manage_product if manage_user else False, 
            'can_edit_manage_product': manage_user.can_edit_manage_product if manage_user else False,
            'can_delete_manage_product': manage_user.can_delete_manage_product if manage_user else False,
            'can_filter_manage_product': manage_user.can_filter_manage_product if manage_user else False,
            'can_update_manage_product': manage_user.can_update_manage_product if manage_user else False, 
            'can_graph_manage_product': manage_user.can_graph_manage_product if manage_user else False,
            'can_staff_manage_product': manage_user.can_staff_manage_product if manage_user else False,
            'allowed_edit_market_ids': allowed_edit_market_ids,
        }
        return render(request, 'pages/super_admin/market_price_chart/product_vs_price/list.html', context)

class ProductVsPriceUpdatePriceView(LoginRequiredMixin,View):
    def get(self, request, *args, **kwargs):
        trigger_subscription()
        market_id = kwargs.get('market_id')
        market = get_object_or_404(ManageMarket, id=market_id)
        products = market.products.all().order_by('id')

        market_products = MarketProduct.objects.filter(market=market).select_related('product')

        # print(market_products)

        return render(request, 'pages/super_admin/market_price_chart/product_vs_price/edit.html', {
            'market': market,
            'products': products,
            'market_products': market_products,
            'today' : datetime.now(), 
        })

    def post(self, request, *args, **kwargs):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        market_id = kwargs.get('market_id')
        market = get_object_or_404(ManageMarket, id=market_id)

        for product in market.products.all():
            price = request.POST.get(f'price_{product.id}')
            available = request.POST.get(f'available_{product.id}')

            try:
                price = float(price) if price else None
            except ValueError:
                price = None

            available = True if available == 'on' else False
            if available:
                price = 0

            # Explicitly check if a MarketProduct entry already exists
            try:
                market_product, created = MarketProduct.objects.update_or_create(
                    market=market,
                    product=product,
                    created_by=user,
                    updated_by=user,
                    defaults={
                        'price': price,
                        'available': available,
                        'updated_at': timezone.now()
                    }
                )
            except IntegrityError:
                # Handle the case where the unique constraint is violated
                # If a duplicate entry exists, you can either skip or update it manually
                market_product = MarketProduct.objects.get(market=market, product=product)
                market_product.price = price
                market_product.available = available
                market_product.updated_at = timezone.now()
                market_product.updated_by = user
                market_product.save()

        messages.success(request, "Prices and availability updated successfully!")
        return redirect('sa_product_vs_price')

class ProductBasedView(LoginRequiredMixin, View): 
    def get(self, request, *args, **kwargs):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = { 
                'can_filter_market_report' : True,
                'can_view_market_report' : True,
                'can_edit_market_report' : True,
                'can_graph_market_report' : True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_market_report:
                return redirect('user_not_allowed') 
            
        # Get query parameters (optional filters)
        product_id = request.GET.get('product_id')
        # print("product id : ",product_id)
        if not product_id:
            first_product = ManageProduct.objects.order_by('created_at').first()
            if first_product:
                product_id = first_product.id
        # Initialize querysets
        selected_product = ManageProduct.objects.filter(id=product_id).first()
        products = ManageProduct.objects.all()
        # Get current year and month
        current_year = datetime.now().year
        current_month = datetime.now().month

        # Filter reports for the current month and year
        reports = ProductMarketReport.objects.filter(
            created_at__year=current_year, created_at__month=current_month
        )
        # print("reports:",reports)
        # Filter reports based on selected market
        if product_id:
            reports = reports.filter(product_id=product_id).order_by('created_at')

        # Pagination logic
        page = request.GET.get('page', 1)  # Default to page 1 if no page is specified
        paginator = Paginator(reports, 10)  # Show 10 reports per page
        # print("pag:",paginator)
        try:
            paginated_reports = paginator.page(page)
        except PageNotAnInteger:
            # If page is not an integer, deliver the first page
            paginated_reports = paginator.page(1)
        except EmptyPage:
            # If page is out of range, deliver the last page
            paginated_reports = paginator.page(paginator.num_pages)

        # Prepare the report data for the selected market
        report_data = defaultdict(list)  # Dictionary where product name is the key, and value is a list of price data
        report_ids = defaultdict(list)
        for report in reports:
            # print("rep:",report)
            product = report.product
            market = report.market
            created_at = report.created_at
            created_day = created_at.day
            created_day_name = created_at.strftime('%a')
            if report.available == False:
                product_data = report.price
            else:
                product_data = -1
            # print("report\nproduct:",product.name,"\nmarket:",market.name,"\nprice:",product_data)

            key = f"{market.name}"
            
            # Initialize the list if not already present
            if key not in report_data:
                report_data[key] = []
                report_ids[key] = []

            # Fill None for missing days
            while len(report_data[key]) < created_day-1:
                report_data[key].append(None)

            # Append the product data for the current day
            report_data[key].append(product_data)
            if len(report_ids[key]) <= 1:
                report_ids[key].append(market.id)
                report_ids[key].append(product.id)


        # Debugging: Check the final structure of report_data
        # print(f"Final report_data: {dict(report_data)}")
        # print(f"Final report_ids: {dict(report_ids)}")
        keyvalue = []
        for i in report_data:
            keyvalue.append(i)
        # for i in keyvalue:
        #     print("vals:",report_ids[i[0]])
        #     print("vals:",report_ids[i[1]])
        today = timezone.now()
        first_day_of_month = today.replace(day=1)
        last_day_of_month = (first_day_of_month + timedelta(days=32)).replace(day=1) - timedelta(days=1)

        # report_data_json = json.dumps(report_data)

        context = {
            'products' : products,
            'selected_product_id': product_id,
            'selected_product' : selected_product,
            'messages': messages.get_messages(request),
            'current_month_year': today.strftime('%b-%Y'),
            'first_day_of_month': first_day_of_month,
            'last_day_of_month': last_day_of_month,
            'report_data': report_data,  # Pass the grouped data
            'report_ids': report_ids,  # Pass the grouped ids
            'keyvalue': keyvalue,
            'days_in_month': [first_day_of_month + timedelta(days=i) for i in range((last_day_of_month - first_day_of_month).days + 1)],
            'paginated_reports': paginated_reports,  # Add paginated reports to context
            'page_obj': paginated_reports,
            'is_paginated': paginated_reports.has_other_pages(),  # True if pagination is available
            'paginator': paginator,  # Add paginator to context 
            'can_filter_market_report': manage_user.can_filter_market_report if manage_user else False,
            'can_view_market_report': manage_user.can_view_market_report if manage_user else False, 
            'can_edit_market_report': manage_user.can_edit_market_report if manage_user else False,
            'can_graph_market_report': manage_user.can_graph_market_report if manage_user else False, 
        }

        return render(request, 'pages/super_admin/market_price_chart/product_based/list.html', context)

class ProductBasedUpdateView(LoginRequiredMixin,View):
    def get(self, request, *args, **kwargs):
        trigger_subscription()
        user = request.user
        product_id = kwargs.get('product_id')
        product = get_object_or_404(ManageProduct, id=product_id)
        if user.is_superuser:
            markets = product.markets.all().order_by('-id')
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                markets = ManageMarket.objects.none()
            if manage_user:
                allocated_markets = AllocateMarket.objects.filter(staff=manage_user)
                markets = ManageMarket.objects.filter(id__in=allocated_markets.values('markets')).order_by('-id')
        
        market_products = MarketProduct.objects.filter(product=product).select_related('market')

        return render(request, 'pages/super_admin/market_price_chart/product_based/edit.html', {
            'product': product,
            'markets': markets,
            'market_products': market_products, 
            'today' : datetime.now(), 
        })

    def post(self, request, *args, **kwargs):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        product_id = kwargs.get('product_id') 
        product = get_object_or_404(ManageProduct, id=product_id) 

        for market in product.markets.all():
            price = request.POST.get(f'price_{market.id}') 
            available = request.POST.get(f'available_{market.id}') 

            try:
                price = float(price) if price else None  
            except ValueError:
                price = None 

            available = True if available == 'on' else False
            if available:
                price = 0
            try:
                market_product, created = MarketProduct.objects.update_or_create(
                    market=market,
                    product=product,
                    created_by = user,
                    updated_by = user,
                    defaults={
                        'price': price,
                        'available': available,
                        'updated_at': timezone.now()  
                    }
                )
            except IntegrityError:
                # Handle the case where the unique constraint is violated
                # If a duplicate entry exists, you can either skip or update it manually
                market_product = MarketProduct.objects.get(market=market, product=product)
                market_product.price = price
                market_product.available = available
                market_product.updated_at = timezone.now()
                market_product.updated_by = user
                market_product.save()
            
        messages.success(request, "Prices and availability updated successfully!")
        return redirect('sa_product_based')

class MarketBasedView(LoginRequiredMixin, View):
    def get(self, request, *args, **kwargs):
        trigger_subscription()
        # Get query parameters (optional filters)
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = { 
                'can_filter_product_market_report' : True,
                'can_view_product_market_report' : True,
                'can_edit_product_market_report' : True,
                'can_graph_product_market_report' : True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_product_market_report:
                return redirect('user_not_allowed') 
        
        market_idss = []
        if manage_user:
            allocated_markets = AllocateMarket.objects.filter(staff=manage_user)
            mark = ManageMarket.objects.filter(id__in=allocated_markets.values('markets'))
            for i in mark:
                market_idss.append(i.id)
        
        market_id = request.GET.get('market_id')
        if not market_id:
            first_market = ManageMarket.objects.order_by('created_at').first()
            if first_market:
                market_id = first_market.id
        if market_id:
            if int(market_id) in market_idss and manage_user:
                edit_market = True
            elif user.is_superuser:
                edit_market = True
            else:
                edit_market = False
        else:
            edit_market = False
        
        # Initialize querysets
        markets = ManageMarket.objects.all()
        current_year = datetime.now().year
        current_month = datetime.now().month

        # Filter reports for the current month and year
        reports = ProductMarketReport.objects.filter(
            created_at__year=current_year, created_at__month=current_month
        ).order_by('product__id')
        # print("reports:",reports)
        # Filter reports based on selected market
        if market_id:
            reports = reports.filter(market_id=market_id).order_by('created_at')

        # Get the market object for further use in the context
        selected_market = ManageMarket.objects.get(id=market_id) if market_id else None

        # Get staff names for the selected market
        staff_names = []
        if market_id:
            allocations = AllocateMarket.objects.filter(markets__id=market_id)
            staff_names = [allocation.staff.name for allocation in allocations]

        # Pagination logic
        page = request.GET.get('page', 1)  # Default to page 1 if no page is specified
        paginator = Paginator(reports, 10)  # Show 10 reports per page
        # print("pag:",paginator)
        try:
            paginated_reports = paginator.page(page)
        except PageNotAnInteger:
            # If page is not an integer, deliver the first page
            paginated_reports = paginator.page(1)
        except EmptyPage:
            # If page is out of range, deliver the last page
            paginated_reports = paginator.page(paginator.num_pages)

        # Prepare the report data for the selected market
        report_data = defaultdict(list)  # Dictionary where product name is the key, and value is a list of price data
        report_ids = defaultdict(list)
        for report in reports:
            # print("rep:",report)
            product = report.product
            market = report.market
            created_at = report.created_at
            created_day = created_at.day
            created_day_name = created_at.strftime('%a')

            if report.available == False:
                product_data = report.price
            else:
                product_data = -1
            # print("report\nproduct:",product.name,"\nmarket:",market.name,"\nprice:",product_data)

            key = f"{product.name}"
            
            # Initialize the list if not already present
            if key not in report_data:
                report_data[key] = []
                report_ids[key] = []

            # Fill None for missing days
            while len(report_data[key]) < created_day-1:
                report_data[key].append(None)

            # Append the product data for the current day
            report_data[key].append(product_data)
            if len(report_ids[key]) <= 1:
                report_ids[key].append(market.id)
                report_ids[key].append(product.id)


        # Debugging: Check the final structure of report_data
        # print(f"Final report_data: {dict(report_data)}")
        # print(f"Final report_ids: {dict(report_ids)}")
        keyvalue = []
        for i in report_data:
            keyvalue.append(i)
        # for i in keyvalue:
        #     print("vals:",report_ids[i[0]])
        #     print("vals:",report_ids[i[1]])
        today = timezone.now()
        first_day_of_month = today.replace(day=1)
        last_day_of_month = (first_day_of_month + timedelta(days=32)).replace(day=1) - timedelta(days=1)

        # report_data_json = json.dumps(report_data)
        
        context = {
            'markets': markets,
            'edit_market': edit_market,
            'selected_market_id': market_id,
            'messages': messages.get_messages(request),
            'selected_market': selected_market,
            'staff_names': ', '.join(staff_names),
            'current_month_year': today.strftime('%b-%Y'),
            'first_day_of_month': first_day_of_month,
            'last_day_of_month': last_day_of_month,
            'report_data': report_data,  # Pass the grouped data
            'report_ids': report_ids,  # Pass the grouped ids
            'keyvalue': keyvalue,
            'days_in_month': [first_day_of_month + timedelta(days=i) for i in range((last_day_of_month - first_day_of_month).days + 1)],
            'paginated_reports': paginated_reports,  # Add paginated reports to context
            'page_obj': paginated_reports,
            'is_paginated': paginated_reports.has_other_pages(),  # True if pagination is available
            'paginator': paginator,  # Add paginator to context
            'can_filter_product_market_report': manage_user.can_filter_product_market_report if manage_user else False,
            'can_view_product_market_report': manage_user.can_view_product_market_report if manage_user else False, 
            'can_edit_product_market_report': manage_user.can_edit_product_market_report if manage_user else False,
            'can_graph_product_market_report': manage_user.can_graph_product_market_report if manage_user else False, 
        }

        return render(request, 'pages/super_admin/market_price_chart/market_based/list.html', context)

class MarketBasedUpdateView(LoginRequiredMixin,View):
    def get(self, request, *args, **kwargs):
        trigger_subscription()
        market_id = kwargs.get('market_id')
        market = get_object_or_404(ManageMarket, id=market_id)
        products = market.products.all().order_by('id')

        market_products = MarketProduct.objects.filter(market=market).select_related('product')

        # print(market_products)

        return render(request, 'pages/super_admin/market_price_chart/market_based/edit.html', {
            'market': market,
            'products': products,
            'market_products': market_products, 
            'today' : datetime.now(), 
        })

    def post(self, request, *args, **kwargs):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        market_id = kwargs.get('market_id') 
        market = get_object_or_404(ManageMarket, id=market_id) 

        for product in market.products.all():
            price = request.POST.get(f'price_{product.id}') 
            available = request.POST.get(f'available_{product.id}') 

            try:
                price = float(price) if price else None  
            except ValueError:
                price = None 

            available = True if available == 'on' else False
            if available:
                price = 0
            try:
                market_product, created = MarketProduct.objects.update_or_create(
                    market=market,
                    product=product,
                    created_by = user,
                    updated_by = user,
                    defaults={
                        'price': price,
                        'available': available,
                        'updated_at': timezone.now()  
                    }
                )
            except IntegrityError:
                # Handle the case where the unique constraint is violated
                # If a duplicate entry exists, you can either skip or update it manually
                market_product = MarketProduct.objects.get(market=market, product=product)
                market_product.price = price
                market_product.available = available
                market_product.updated_at = timezone.now()
                market_product.updated_by = user
                market_product.save()
        
        messages.success(request, "Prices and availability updated successfully!")
        return redirect('sa_market_based')
 
def product_price_data(request, product_id):
    product = get_object_or_404(ManageProduct, id=product_id)
    today = datetime.now().date()
    
    market_products = MarketProduct.objects.filter(product=product, updated_at__date=today).order_by('-market__id')
    
    prices = []
    
    for market_product in market_products:
        prices.append({
            'product_id': product.id, 
            'product_name': product.name.title(),  
            'market_id': market_product.market.id,  
            'market_name': market_product.market.name.title(),  
            'price': market_product.price,  
        })
        
        # print(f"Product ID: {product.id}, Product Name: {product.name}")
        # print(f"Market ID: {market_product.market.id}, Market Name: {market_product.market.name}")
        # print(f"Price: {market_product.price}")
    
    return JsonResponse({'product_name': product.name, 'prices': prices})
 
def export_market_price_chart_product(request):
    # Get query parameters (same as in your get function)
    product_ids = request.GET.get('product_id')
    market_type_id = request.GET.get('market_type_id')
    market_id = request.GET.get('market_id')
    user_id = request.GET.get('user_id')

    # Fetch all products initially
    products = ManageProduct.objects.prefetch_related('markets').all()

    # Apply filters based on the query parameters if they exist
    if product_ids:
        try:
            product = ManageProduct.objects.get(id=product_ids)
            products = products.filter(id=product.id)
        except ManageProduct.DoesNotExist:
            messages.error(request, "Product not found.")
            return redirect('sa_market_price_chart_product')

    # Only apply the market_id filter if it's provided (not None or empty)
    if market_id and market_id != 'None':  # Ensure 'None' or empty values are handled
        products = products.filter(markets__id=market_id)

    # Handle market_type_id filter if it's provided
    if market_type_id and market_type_id != 'None':  # Ensure 'None' or empty values are handled
        products = products.filter(markets__markettype_id=market_type_id)

    # Handle the export functionality
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="product_prices.csv"'

    writer = csv.writer(response)
    
    # Write the CSV header
    writer.writerow([
        'Product ID', 'Product Name', 'Market ID', 'Market Name', 'Price', 'Available', 'Updated At'
    ])

    # Fetch the data for each product and each market
    for product in products:
        # Loop through each market associated with the product
        for market in product.markets.all():
            market_product = MarketProduct.objects.filter(product=product, market=market).order_by('-updated_at').first()

            if market_product:
                # Write the product data for this market
                writer.writerow([
                    product.id,
                    product.name,
                    market.id,
                    market.name,
                    market_product.price,
                    market_product.available,
                    market_product.updated_at.strftime('%d-%b-%Y %H:%M')
                ])
            else:
                # If no market product exists, write a row with 0 values
                writer.writerow([
                    product.id,
                    product.name,
                    market.id,
                    market.name,
                    0,
                    False,
                    '-'
                ])

    return response

def export_to_csv(request):
    # Get query parameters for CSV export (you can use the same filters from the GET method)
    market_id = request.GET.get('market_id')

    # Initialize querysets and filter based on the market_id
    reports = ProductMarketReport.objects.all()
    if market_id:
        reports = reports.filter(market_id=market_id)

    # Prepare the report data for the selected market
    report_data = defaultdict(list)

    for report in reports:
        product = report.product
        created_at = report.created_at
        created_day = created_at.day
        created_day_name = created_at.strftime('%a')  # Get the day of the week

        # Store the price in the correct day slot
        product_data = {
            'name': product.name,
            'price': report.price,
            'created_at': created_at.strftime('%d-%b'),
            'created_day': created_day_name
        }

        while len(report_data[product.name]) < created_day:
            report_data[product.name].append(None)

        report_data[product.name].append(product_data)

    # Prepare the response with the correct CSV format
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="market_price_report.csv"'

    # Create the CSV writer
    writer = csv.writer(response)
    # Write the header row
    header = ['Product Name'] + [f'Day {i+1}' for i in range(len(report_data))]
    writer.writerow(header)

    # Write product data to CSV
    for product_name, days_data in report_data.items():
        row = [product_name]
        for day_data in days_data:
            if day_data:
                row.append(f"₹ {day_data['price']}")
            else:
                row.append('-')
        writer.writerow(row)

    return response
    
def market_product_price_data(request, product_id, market_id):
    # Get the product object (Product)
    product = get_object_or_404(ManageProduct, id=product_id)
    
    # Get the market object (Market)
    market = get_object_or_404(ManageMarket, id=market_id)
    
    # Get the selected month, if provided (defaults to current month if not provided)
    today = timezone.now()
    first_day_of_month = today.replace(day=1)
    last_day_of_month = (first_day_of_month + timedelta(days=32)).replace(day=1) - timedelta(days=1)
    days_in_month = [first_day_of_month + timedelta(days=i) for i in range((last_day_of_month - first_day_of_month).days + 1)]
    formatted_days = []
    for day in days_in_month:
        formatted_days.append(day.strftime("%d-%b (%a)"))  # Format as "01-Nov (Fri)"
    # print(formatted_days)
    # # Get all reports for the product in the selected market and selected month
    reports = ProductMarketReport.objects.filter(
        market_id=market.id,
        product_id=product.id,
        created_at__date__gte=first_day_of_month.date(),
        created_at__lte=last_day_of_month
    ).order_by('created_at')
    price = []
    for report in reports:
        created_at = report.created_at
        created_day = created_at.day

        product_data = report.price
        # Fill None for missing days
        while len(price) < created_day-1:
            price.append(0)

        # Append the product data for the current day
        price.append(product_data)

    for i in range(len(price),len(formatted_days)):
        price.append(0)

    return JsonResponse({
        'product' : product.name,
        'market' : market.name,
        'days' : formatted_days,
        'price' : price
    })

# ------------------------------------------------------------------------- Farmer Management ----------------------------------------------

def send_welcome_email(email, name, username, password):
    print(f"Sending Welcome Mail")  # Debugging line

    try:
        template = get_object_or_404(EmailTemplate, code=1)
        if template.status == 0:
            content = template.email_template_content

            content = content.replace('#$%Name#$%', name)
            content = content.replace('#$%username#$%', username)
            content = content.replace('#$%password#$%', password)

            subject = template.email_subject
            from_email = settings.DEFAULT_FROM_EMAIL
            to_email = [email]

            msg = EmailMultiAlternatives(subject, '', from_email, to_email)
            msg.attach_alternative(content, "text/html")
            msg.send()
            
            print(f"Welcome mail sent successfully to {email}!") 
        else:
            print("Email not Sent! Issue in Email Template")
    except Exception as e:
        print(f"Error sending email: {e}") 

def send_welcome_sms(mobile_number, name, username, password):
    print("Sending Welcome SMS")
    SMS_TEMPLATE = {
        'authkey': '155099Ajzgw9B8dfq6737236aP1',  
        'sender_id': 'ELYSIU',  
        'template_id': '1007049094377493090',   
        'country_code': '91',  
        'message_content': 
            f"""Dear {name},

            Thank you for choosing AgriOT, your all-in-one farming companion! 🚜🌱

            With AgriOT, you can:
            ✅ Store and manage expenses, sales, land, crop, and inventory details.
            ✅ Get guidelines for best crop schedule practices.
            ✅ Plan and follow crop schedules in a calendar format.
            ✅ Enjoy a pocket-friendly and efficient farm management experience.

            Your Login Credentials:
            📧 Username: {username}
            🔑 Password: {password}

            🔒 Please keep your email and password safe and secure.

            👉 Login now to start managing your farm smarter:
            http://147.93.19.253:5000/

            We look forward to helping you grow your farm with AgriOT! 🚀

            Best Regards,
            AgriOT Team"""  # Define your message content with placeholder
    }

    mobile_number = SMS_TEMPLATE['country_code'] + str(mobile_number)

    message_content = SMS_TEMPLATE['message_content']

    # print(f"Message Content: {message_content}")  # Debugging line

    # Build the API URL for sending SMS
    url = f"https://api.msg91.com/api/sendhttp.php?authkey={SMS_TEMPLATE['authkey']}&sender={SMS_TEMPLATE['sender_id']}&route=default&message={message_content}&mobiles={mobile_number}&DLT_TE_ID={SMS_TEMPLATE['template_id']}"

    try:
        # Make the GET request to send the SMS
        response = requests.get(url)

        # Log the response (for debugging purposes)
        print(f"API Response: {response.text}")

        # Check if the request was successful
        if response.status_code == 200:
            print(f"Welcome SMS sent successfully to {mobile_number}!")  # Debugging line
        else:
            print(f"Failed to send Welcome SMS. Status code: {response.status_code}")
            print(f"Error details: {response.text}")

    except requests.exceptions.RequestException as e:
        # Catch any request exceptions and log the error
        print(f"Error occurred while sending OTP: {e}")

def get_data_for_graph(request):
    farmer_id = request.GET.get('farmer_id')
    module = request.GET.get('module')  # Get the 'module' query parameter
    duration = request.GET.get('duration')  # Get the 'duration' query parameter
    sweek_date = request.GET.get('sweek_date')
    eweek_date = request.GET.get('eweek_date')
    month_date = request.GET.get('month_date')
    year_date = request.GET.get('year_date')

    result = defaultdict(int)
    
    if module == '0':
        model = MyLand
    elif module == '1':
        model = MyCrop
    elif module == '2':
        model = MyExpense
    elif module == '3':
        model = MySales
    elif module == '4':
        model = MySchedule
    elif module == '5':
        model = MyVendor
    elif module == '6':
        model = MyCustomer
    elif module == '7':
        model = Employee
    elif module == '8':
        models = [MyFuel, MyVehicle, MyMachinery, MyTools, MyPesticides, MyFertilizers, MySeeds]
    else:
        return JsonResponse({"error": "Invalid module selected"}, status=400)
    
    if duration == 'week':
        sweek_date = datetime.strptime(sweek_date, '%d-%m-%Y').date()
        eweek_date = datetime.strptime(eweek_date, '%d-%m-%Y').date()
        
        if module != '8':
            records = model.objects.filter(farmer__id=farmer_id, status__in=[0,1], created_at__gte=sweek_date, created_at__lte=eweek_date)
            for record in records:
                day_of_week = record.created_at.weekday()  # 0 = Monday, 6 = Sunday
                # Adjust so that Sunday = 0, Saturday = 6
                adjusted_day_of_week = (day_of_week + 1) % 7  # Shift by 1 and wrap around to keep within the range [0, 6]
                result[adjusted_day_of_week] += 1
        else:
            for m in models:
                records = m.objects.filter(
                    farmer__id=farmer_id, status__in=[0,1],
                    created_at__gte=sweek_date,
                    created_at__lte=eweek_date
                )

                for record in records:
                    day_of_week = record.created_at.weekday()
                    adjusted_day_of_week = (day_of_week + 1) % 7
                    result[adjusted_day_of_week] += 1
        
        result = {days_of_week(i): result.get(i, 0) for i in range(7)}
        return JsonResponse(result)
        
    elif duration == 'monthly':
        parsed_date = datetime.strptime(month_date, '%m-%Y')
        current_month = parsed_date.month
        current_year = parsed_date.year
        
        first_day_of_month = datetime(current_year, current_month, 1).date()
        last_day_of_month = (datetime(current_year, current_month + 1, 1) - timedelta(days=1)).date()
        
        formatted_days = []
        days_in_month = [first_day_of_month + timedelta(days=i) for i in range((last_day_of_month - first_day_of_month).days + 1)]
        for day in days_in_month:
            formatted_day = day.strftime("%d-%b")  # Format day as "01-Jan (Mon)"
            formatted_days.append(formatted_day)
        
        formatted_result = [0] * len(formatted_days)
        if module == '8':
            for m in models:
                records = m.objects.filter(
                    farmer__id=farmer_id, status__in=[0,1],
                    created_at__gte=first_day_of_month,
                    created_at__lte=last_day_of_month
                )
                for record in records:
                    day_of_month = record.created_at.day
                    formatted_result[day_of_month - 1] += 1
        else:
            records = model.objects.filter(farmer__id=farmer_id, status__in=[0,1], created_at__gte=first_day_of_month, created_at__lte=last_day_of_month)
            for record in records:
                day_of_month = record.created_at.day
                formatted_result[(day_of_month - 1)] += 1
        
        return JsonResponse({
            'days': formatted_days,
            'result': formatted_result
        })
    
    elif duration == 'year':
        # Get the current year
        current_year = int(year_date)
                
        # Query the model for records in the selected year
        first_day_of_year = datetime(current_year, 1, 1).date()
        last_day_of_year = datetime(current_year, 12, 31).date()
        result_count = [0] * 12

        if module == '8':
            for m in models:
                records = m.objects.filter(
                    farmer__id=farmer_id, status__in=[0,1],
                    created_at__gte=first_day_of_year,
                    created_at__lte=last_day_of_year
                )

                for record in records:
                    month_of_year = record.created_at.month
                    result_count[month_of_year - 1] += 1
        else:
            records = model.objects.filter(farmer__id=farmer_id, status__in=[0,1], created_at__gte=first_day_of_year, created_at__lte=last_day_of_year)
            
            for record in records:
                month_of_year = record.created_at.month
                result_count[(month_of_year - 1)] += 1
        
        return JsonResponse({
            'result_count': result_count
            })
    
    else:
        return JsonResponse({"error": "Invalid duration selected"}, status=400)
    
def days_of_week(day):
    days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    return days[day]

class FarmerManagementView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        # Fetch filter parameters from the GET request
        user = request.user
        manage_user = None

        if user.is_superuser:
            context = {
                'can_add_farmer': True,
                'can_view_farmer': True,
                'can_edit_farmer': True,
                'can_delete_farmer': True,
                'can_view_unique_farmer': True,
                'can_update_farmer_status': True,
                'can_export_farmer_data': True,
                'can_filter_farmer_data': True,

            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_farmer:
                return redirect('user_not_allowed') 
         
        farmer_id = request.GET.get('farmer', '')
        phone = request.GET.get('phone', '')
        email = request.GET.get('email', '')
        city_id = request.GET.get('city', '')
        taluk_id = request.GET.get('filter_taluk', '')
        village_id = request.GET.get('filter_village', '')
        package_id = request.GET.get('package', '')
        rem_days = request.GET.get('rem_days', '')
        date_filter = request.GET.get('date_filter', 'all')
        custom_date_from = request.GET.get('custom_date_from', '')
        custom_date_to = request.GET.get('custom_date_to', '')
        filter_status = request.GET.get('status', '')

        # Initialize the base queryset for farmers
        farmers = Farmer.objects.filter(Q(status=0) | Q(status=1) | Q(status=4) | Q(status=6)).order_by('-id')   

        if farmer_id:
            farmers = farmers.filter(id=farmer_id)

        if phone:
            farmers = farmers.filter(phone__icontains=phone)

        if email:
            farmers = farmers.filter(email__icontains=email)

        if city_id:
            farmers = farmers.filter(city_id=city_id)
        
        if taluk_id:
            farmers = farmers.filter(taluk_id=taluk_id)
        
        if village_id:
            farmers = farmers.filter(village_id=village_id)
        
        if package_id:
            farmers = farmers.filter(subscription_package_id=package_id)
        
        if rem_days:
            farmers = farmers.filter(remaining_days=rem_days)

        if filter_status:
            if filter_status == '0':
                farmers = farmers.filter(remaining_days=0)
            else:
                farmers = farmers.filter(status=0).exclude(remaining_days=0)

        if date_filter == 'today':
            farmers = farmers.filter(created_at__date=timezone.now().date())
        elif date_filter == 'week':
            start_of_week = today_date - timedelta(days=today_date.weekday())  # Monday
            farmers = farmers.filter(created_at__date__range=[start_of_week, today_date])
        elif date_filter == 'monthly':
            farmers = farmers.filter(created_at__year=today_date.year, created_at__month=today_date.month)
        elif date_filter == 'custom_date':
            if custom_date_from and custom_date_to:
                custom_from_date = datetime.strptime(custom_date_from, '%d-%m-%Y').date()
                custom_to_date = datetime.strptime(custom_date_to, '%d-%m-%Y').date()
                farmers = farmers.filter(created_at__date__range=[custom_from_date, custom_to_date])
       

        show_per_page = request.GET.get('show', 25)
        show_per_page = int(show_per_page)  # Convert it to an integer

        # Pagination setup
        paginator = Paginator(farmers, show_per_page)  # Show the selected number of farmers per page 
        page_number = request.GET.get('page')  # Get the page number from the request
        page_obj = paginator.get_page(page_number)

        # Prepare the farmers data to display
        farmer_subscription_map = {
            farmer.id: farmer.subscription_details for farmer in farmers
        }

        farmers_data = []
        entries = 0
        for farmer in page_obj:
            entries += 1
            subscription_details = farmer_subscription_map.get(farmer.id)

            farmer_data = {
                'id': farmer.id,
                'name': farmer.name,
                'phone': farmer.phone,
                'email': farmer.email,
                'city': farmer.city.name if farmer.city else '-',
                'city_id': farmer.city.id if farmer.city else '-',
                'taluk': farmer.taluk.name if farmer.taluk else '-',
                'taluk_id': farmer.taluk.id if farmer.taluk else '-',
                'village': farmer.village.name if farmer.village else '-',
                'village_id': farmer.village.id if farmer.village else '-',
                'description': farmer.description,
                'status': farmer.status,
                'company_name': farmer.company_name,
                'tax_no': farmer.tax_no,
                'username': farmer.username,
                'password': farmer.password,
                'sub_admin_username': farmer.sub_admin_username,
                'sub_admin_password': farmer.sub_admin_password,
                'created_at': farmer.created_at,
                'farmer': farmer.farmer,
                # 'farmertype': farmer.farmertype,
                'subscription_details': {},
                'img': farmer.img if farmer.img else 'assets/images/user_1.png'
            }

            if subscription_details:
                start_date = subscription_details.get('start_date', '-')
                end_date = subscription_details.get('end_date', '-')

                if isinstance(start_date, date):
                    start_date = start_date.strftime('%Y-%m-%d')
                if isinstance(end_date, date):
                    end_date = end_date.strftime('%Y-%m-%d')

                farmer_data['subscription_details'] = {
                    'package_name': subscription_details.get('package_name', 'No Package'),
                    'package_duration': subscription_details.get('package_duration', '-'),
                    'package_validity': subscription_details.get('validity', '-'),
                    'start_date': start_date,
                    'end_date': end_date,
                    'remaining_days': subscription_details.get('remaining_days', '-'),
                    'amount': subscription_details.get('amount', '-'),
                    'sub_amount': subscription_details.get('sub_amount', '-'),
                    # 'add_on_details': subscription_details.get('add_on_details')
                }
            else:
                farmer_data['subscription_details'] = {
                    'package_name': 'No Package',
                    'package_duration': '-',
                    'package_validity': '-',
                    'start_date': '-',
                    'end_date': '-',
                    'remaining_days': '-',
                    'amount': '-',
                    'sub_amount': '-',
                    # 'add_on_details': []
                }

            farmers_data.append(farmer_data)

        packages = PackageManagement.objects.filter(status=0).order_by('-id')
        packages_data = []
        for package in packages:
            # add_ons = package.add_on_details.all()
            package_data = {
                'id': package.id,
                'name': package.name,
                'amount': package.amount,
                'sub_amount': package.sub_amount,
                'package_validity': package.package_validity,
                'package_duration': package.package_duration.name if package.package_duration else '-',
                # 'add_ons': [{'id': addon.id, 'name': addon.name} for addon in add_ons],
            }
            packages_data.append(package_data)

        all_farmers = Farmer.objects.filter(status__in=[0,1,3,4,5,6])
        total_farmer = all_farmers.count()
        exp_farmers = 0
        for f in all_farmers:
            if f.remaining_days == 0:
                exp_farmers += 1

        # Pass data to the template
        context = {
            'farmers': page_obj,
            'entries_count': entries,
            'show_per_page': show_per_page,
            'total_farmer': total_farmer,
            'exp_farmers': exp_farmers,
            # 'farmertype': farmertype,
            # 'farmer_id': farmer_id,
            # 'phone': phone,
            # 'email': email,
            'package_id' : package_id if package_id else '',
            # 'rem_days' : rem_days,
            'city_id': int(city_id) if city_id else '',
            'taluk_id': int(taluk_id) if taluk_id else '',
            'village_id' :int(village_id) if village_id else '',
            'date_filter': date_filter,
            'custom_date_from': custom_date_from,
            'custom_date_to': custom_date_to,
            # 'farmer_types': list(FarmerType.objects.values('id', 'name')),
            'packages' : list(PackageManagement.objects.values('id', 'name')),
            'countries': list(Country.objects.values('id', 'name')),
            'states': list(State.objects.values('id', 'name')),
            'cities': list(City.objects.values('id', 'name')),
            'taluks' : list(Taluk.objects.values('id', 'name')),
            'villages' : list(Village.objects.values('id', 'name')),
            'filter_status' : filter_status,
            'users_details': CustomUser.objects.all(), 
            'can_add_farmer': manage_user.can_add_farmer if manage_user else False,
            'can_view_farmer': manage_user.can_view_farmer if manage_user else False,
            'can_edit_farmer': manage_user.can_edit_farmer if manage_user else False,
            'can_delete_farmer': manage_user.can_delete_farmer if manage_user else False,
            'can_view_unique_farmer': manage_user.can_view_unique_farmer if manage_user else False,
            'can_update_farmer_status': manage_user.can_update_farmer_status if manage_user else False,
            'can_export_farmer_data': manage_user.can_export_farmer_data if manage_user else False,
            'can_filter_farmer_data': manage_user.can_filter_farmer_data if manage_user else False,
            'packages': packages_data,  # Packages data with add-ons 
        }

        return render(request, 'pages/super_admin/farmer_management/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')
        
        if action == 'create':
            name = request.POST.get('name')  
            phone = request.POST.get('phone')
            email = request.POST.get('email')
            city_id = request.POST.get('city')
            taluk_id = request.POST.get('taluk')
            village_id = request.POST.get('village')
            state_id = request.POST.get('state')
            country_id = request.POST.get('country')
            description = request.POST.get('description', '')
            company_name = request.POST.get('company_name', '')
            tax_no = request.POST.get('tax_no', '')
            door_no = request.POST.get('door_no', '')
            pincode = request.POST.get('pincode', '')
            img = request.FILES.get('img')

            # Check for missing required fields
            if not name or not phone or not city_id or not state_id or not country_id:
                messages.error(request, "Please fill in all required fields.")
                return redirect('sa_farmer_management')  
 
            if Farmer.objects.filter(phone=phone, status__in=[0, 1]).exists():
                messages.error(request, "A farmer with this phone number already exists.")
                return redirect('sa_farmer_management')
       
            try:
                city = City.objects.get(id=city_id)
                taluk = Taluk.objects.get(id=taluk_id)
                village = Village.objects.get(id=village_id)
            except (City.DoesNotExist, Taluk.DoesNotExist, Village.DoesNotExist):
                messages.error(request, "Invalid District, taluk, or village selected.")
                return redirect('sa_farmer_management')
 
            try:
                state = State.objects.get(id=state_id)  # Assuming 'State' model exists
                country = Country.objects.get(id=country_id)  # Assuming 'Country' model exists
            except (State.DoesNotExist, Country.DoesNotExist):
                messages.error(request, "Invalid state or country selected.")
                return redirect('sa_farmer_management')

            # Create farmer object
            farmer = Farmer(
                name=name,
                phone=phone,
                # email=email,
                city=city,
                state=state,
                country=country,
                taluk=taluk,
                village=village,
                description=description,
                company_name=company_name,
                tax_no=tax_no,
                created_by=user,
                created_at=timezone.now()
            )
            
            if img:
                # Convert the image to JPEG
                img_io = convert_png_to_jpeg(img)
                
                # Save the JPEG image as an InMemoryUploadedFile object
                img_name = f"{img.name.split('.')[0]}.jpg"  # Modify the name to have .jpg extension
                img_file = InMemoryUploadedFile(img_io, None, img_name, 'image/jpeg', img_io.getbuffer().nbytes, None)
                farmer.img=img_file
            
            # Optional fields
            if email:
                farmer.email =email
            if door_no:
                farmer.door_no = door_no
            if pincode:
                farmer.pincode = pincode
            
            farmer.save()

            package = PackageManagement.objects.get(id=1)

            subscription = AddSubcription.objects.create(
                farmers=farmer,
                packages=package,
                status=0,
                startdate=timezone.now().date(),
                renewal=False,
                created_by=user,
                created_at=timezone.now()
            )
            subscription.package_details_update(user) 

            Notification.objects.create(user=user, message=f"New Farmer Created: {farmer.name}", image=farmer.img, name=farmer.name)

            translated_json = {
                "name": {},
                "company_name": {},
                "door_no": {},
                "description": {}
            }
            try:
                for lang in target_language:
                    translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                    translated_json["name"][lang] = translated_text
                    translated_text = GoogleTranslator(source='auto', target=lang).translate(company_name)
                    translated_json["company_name"][lang] = translated_text
                    translated_text = GoogleTranslator(source='auto', target=lang).translate(door_no)
                    translated_json["door_no"][lang] = translated_text
                    translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                    translated_json["description"][lang] = translated_text

                farmer.translate_json = translated_json
                farmer.save()
            except Exception as e:
                print(e)
                print("Error in translating ")

            try:
                if farmer.email:
                    send_welcome_email(email,name,email,phone)
                # else:
                #     send_welcome_sms(phone,name,phone,phone)
            except Exception as e:
                print(e)
                print("Error in sending welcome mail")

            messages.success(request, "Farmer created successfully!")
            return redirect('sa_farmer_management')
       
        if action == 'update_status':
            pk = request.POST.get('id')
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                # Fetch the Farmer object based on the provided primary key (id)
                farmer = get_object_or_404(Farmer, pk=pk)
                
                # Get the status from the POST data (whether it's checked or unchecked)
                status = request.POST.get('status')

                if status == '0':  # Deactivate the farmer (status = 0)
                    farmer.status = 0  
                    farmer.updated_by = user
                    farmer.save()
                    custom_user = get_object_or_404(CustomUser, pk=farmer.farmer_user.id)
                    custom_user.is_active = True
                    custom_user.save()
                    Notification.objects.create(user=user, message=f"Farmer Status Activated: {farmer.name}", image=farmer.img, name=farmer.name)
                    messages.success(request, "Farmer Has Been Activated.")  # Success message for activation
                elif status == '1':  # Activate the farmer (status = 1)
                    farmer.status = 1  
                    farmer.updated_by = user
                    farmer.save()
                    custom_user = get_object_or_404(CustomUser, pk=farmer.farmer_user.id)
                    custom_user.is_active = False
                    custom_user.save()
                    Notification.objects.create(user=user, message=f"Farmer Status Deactivated: {farmer.name}", image=farmer.img, name=farmer.name)
                    messages.success(request, "Farmer Has Been Deactivated.")  # Success message for deactivation
                else:
                    messages.error(request, "Invalid status value.")  # In case the status value is neither '0' nor '1'
                
            return redirect('sa_farmer_management')  # Redirect back to the farmer management page

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
                logger.warning("Delete action failed: ID was empty.")
            else:
                try:
                    farmer = get_object_or_404(Farmer, pk=pk)

                    custom_user = get_object_or_404(CustomUser, pk=farmer.farmer_user.id)
                    custom_user.is_active = False
                    custom_user.save()

                    subss = AddSubcription.objects.filter(farmers=farmer)
                    for s in subss:
                        s.status=2
                        s.save()
                    
                    farmer.status = 2  
                    farmer.updated_by = user
                    farmer.save()
                    Notification.objects.create(user=user, message=f"Farmer Deleted: {farmer.name}", image=farmer.img, name=farmer.name)
                    logger.info(f"User ID {user.id} deleted farmer '{farmer.name}' (ID: {pk}).")

                    messages.success(request, "Farmer Has Been Deleted Successfully.")
                except Farmer.DoesNotExist:
                    messages.error(request, "Farmer not found.")
                    logger.error(f"Delete action failed: Farmer with ID {pk} not found.")

            return redirect('sa_farmer_management')

        elif action == 'update':
            pk = request.POST.get('id')
            farmer = get_object_or_404(Farmer, pk=pk)
            translate_json = farmer.translate_json or {
                "name": {},
                "company_name": {},
                "door_no": {},
                "description": {}
            }
            farmer_name = request.POST.get('farmer_name')
            if farmer_name != farmer.name:
                farmer.name = farmer_name
                try:
                    for lang in target_language:
                        translate_json["name"][lang] = GoogleTranslator(source='auto', target=lang).translate(farmer_name)
                except Exception as e:
                    print(e)
                    print("Error in translation")
            # mobile_no = request.POST.get('mobile_no')
            # farmer.phone = mobile_no
            email_id = request.POST.get('email_id')
            if email_id:
                farmer.email = email_id
            else:
                farmer.email = ''
            company_name = request.POST.get('company_name')
            if company_name != farmer.company_name:
                if company_name:
                    farmer.company_name = company_name
                    try:
                        for lang in target_language:
                            translate_json["company_name"][lang] = GoogleTranslator(source='auto', target=lang).translate(company_name)
                    except Exception as e:
                        print(e)
                        print("Error in translation")
                else:
                    farmer.company_name = ''
            tax_no = request.POST.get('tax_no')
            if tax_no:
                farmer.tax_no = tax_no
            else:
                farmer.tax_no = ''
            # city_id = request.POST.get('city')
            # city = City.objects.get(id=city_id)
            # farmer.city = city
            city_id = request.POST.get('update_city')
            try:
                # Attempt to retrieve the city by ID
                city = City.objects.get(id=city_id)
                farmer.city = city
            except City.DoesNotExist:
                # Handle the case where the city does not exist
                messages.error(request, "The selected District does not exist.")
                return redirect('sa_farmer_management') 

         

            state_id = request.POST.get('update_state')
            try:
                state = State.objects.get(id=state_id)
                farmer.state = state
            except State.DoesNotExist:
                messages.error(request, "The selected state does not exist.")
                return redirect('sa_farmer_management')

            country_id = request.POST.get('update_country')
            try:
                country = Country.objects.get(id=country_id)
                farmer.country = country
            except Country.DoesNotExist:
                messages.error(request, "The selected country does not exist.")
                return redirect('sa_farmer_management')

            taluk_id = request.POST.get('update_taluk')
            try:
                taluk = Taluk.objects.get(id=taluk_id)
                farmer.taluk = taluk
            except Taluk.DoesNotExist:
                messages.error(request, "The selected taluk does not exist.")
                return redirect('sa_farmer_management')

            village_id = request.POST.get('update_village')
            try:
                village = Village.objects.get(id=village_id)
                farmer.village = village
            except Village.DoesNotExist:
                messages.error(request, "The selected village does not exist.")
                return redirect('sa_farmer_management')
            
            username = request.POST.get('username')
            farmer.username = username
            password = request.POST.get('password')
            farmer.password = password
            sub_admin_username = request.POST.get('sub_admin_username')
            farmer.sub_admin_username = sub_admin_username
            sub_admin_password = request.POST.get('sub_admin_password')
            farmer.sub_admin_password = sub_admin_password
            description = request.POST.get('description')
            if description != farmer.description:
                if description:
                    farmer.description = description
                    try:
                        for lang in target_language:
                            translate_json["description"][lang] = GoogleTranslator(source='auto', target=lang).translate(description)
                    except Exception as e:
                        print(e)
                        print("Error in translating ")
                else:
                    farmer.description = ''
            door = request.POST.get('door_no')
            if door != farmer.door_no:
                if door:
                    farmer.door_no = door
                    try:
                        for lang in target_language:
                            translate_json["door_no"][lang] = GoogleTranslator(source='auto', target=lang).translate(door)
                    except Exception as e:
                        print(e)
                        print("Error in translating ")
                else:
                    farmer.door_no = ''
            pincode = request.POST.get('pincode')
            if pincode:
                farmer.pincode = pincode
            else:
                farmer.pincode = ''
            
            img = request.FILES.get('img')
            if img:
                img_io = convert_png_to_jpeg(img)
                img_name = f"{img.name.split('.')[0]}.jpg"
                img_file = InMemoryUploadedFile(img_io, None, img_name, 'image/jpeg', img_io.getbuffer().nbytes, None)
                farmer.img=img_file
            
            farmer.translate_json = translate_json
            farmer.updated_by = user
            farmer.save()
            Notification.objects.create(user=user, message=f"Farmer Details Updated: {farmer.name}", image=farmer.img, name=farmer.name)
            messages.success(request, "Farmer has been Updated successfully.")
            return redirect('sa_farmer_management')

        elif action == 'activate_plan':
            subscription_id = request.POST.get('id')

            if not subscription_id:
                messages.error(request, "Subscription ID is required for renewal.")
                return redirect('sa_farmer_management')
            try:
                subscription = AddSubcription.objects.get(id=subscription_id)
                existing_subscription = AddSubcription.objects.filter(farmers=subscription.farmers, status=0).first()
                existing_subscription.status=3
                existing_subscription.save()
                subscription.status = 0
                subscription.startdate = timezone.now().date()
                subscription.updated_by = user
                subscription.save()
                subscription.package_details_update(user)
                messages.success(request, "Subscription Activated Successfully!")
            except AddSubcription.DoesNotExist:
                messages.error(request, "Subscription not Found.")
            except Exception as e:
                print(e)
                messages.error(request, "An Error Occured.")

            return redirect('sa_farmer_management')

        elif action == 'renew_subscription':
            subscription_id = request.POST.get('id')
            package_id = request.POST.get('re_pckg')
            paymentMode = request.POST.get('paymentMode')
            transactionId = request.POST.get('transactionId')
            paymentstatus = request.POST.get('paymentstatus')

            if not subscription_id:
                messages.error(request, "Previous Subscription is Required for Renewal.")
                return redirect('sa_subscription_management')

            try:
                farmer = Farmer.objects.get(id=subscription_id)

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
                
                subscription = AddSubcription.objects.create(
                    farmers=farmer,
                    packages=package,
                    status=0,  # Default status, change if needed 
                    startdate=startdate,
                    enddate=enddate,
                    remainingdays = remainingdays,
                    renewal = True,
                    created_by = user,
                    created_at= timezone.now()
                )

                custom_user = get_object_or_404(CustomUser, pk=farmer.farmer_user.id)
                custom_user.is_active = True
                custom_user.save()

                if paymentMode == 'online':
                    subscription.payment_mode=0
                    subscription.transaction_id=transactionId
                    subscription.payment_status=0
                    subscription.save()
                elif paymentMode == 'pos':
                    subscription.payment_mode=2
                    subscription.transaction_id=transactionId
                    subscription.payment_status=0
                    subscription.save()
                else:
                    subscription.payment_mode=1
                    if paymentstatus == "0":
                        subscription.payment_status=0
                    else:
                        subscription.payment_status=1
                    subscription.save()

                messages.success(request, "Subscription Updated Successfully!")
            
            except Exception as e:
                print(e)
                messages.error(request, "An Error Occurred")

            return redirect('sa_farmer_management')

        elif action == 'unsubscribe':
            farmer_id = request.POST.get('farmer_id')
            pack_id = request.POST.get('pack_id')

            if farmer_id:
                farmer = get_object_or_404(Farmer, pk=farmer_id)
                # farmer.status = 6
                # farmer.remaining_days = None
                # farmer.subscription_start_date = None
                # farmer.subscription_end_date = None
                # farmer.save()

            if farmer_id and pack_id:
                package = get_object_or_404(PackageManagement, pk=pack_id)
                sub = AddSubcription.objects.filter(farmers=farmer,packages=package, status=0).first()
                if sub:
                    sub.status = 3
                    sub.save()
                
                farmer.status = 6
                farmer.remaining_days = None
                farmer.subscription_start_date = None
                farmer.subscription_end_date = None
                farmer.save()
                
                custom_user = get_object_or_404(CustomUser, pk=farmer.farmer_user.id)
                custom_user.is_active = False
                custom_user.save()

            messages.success(request, "Un Subscribed Successfully!")
            return redirect('sa_farmer_management')

        elif action == 'filter':
            user = request.user
            manage_user = None

            if user.is_superuser:
                context = {
                    'can_add_farmer': True,
                    'can_view_farmer': True,
                    'can_edit_farmer': True,
                    'can_delete_farmer': True,
                    'can_view_unique_farmer': True,
                    'can_update_farmer_status': True,
                    'can_export_farmer_data': True,
                    'can_filter_farmer_data': True,
                }
            else:
                try:
                    manage_user = ManageUser.objects.get(custom_user_id=user.id)
                except ManageUser.DoesNotExist:
                    manage_user = None

                if manage_user and not manage_user.can_view_farmer:
                    return redirect('user_not_allowed')

            # Get filter parameters from the POST request
            farmer_id = request.POST.get('farmer', '')
            phone = request.POST.get('phone', '')
            email = request.POST.get('email', '')
            city_id = request.POST.get('city', '')
            taluk_id = request.POST.get('filter_taluk', '')
            village_id = request.POST.get('filter_village', '')
            package_id = request.POST.get('package', '')
            rem_days = request.POST.get('rem_days', '')
            date_filter = request.POST.get('date_filter', 'all')
            custom_date_from = request.POST.get('custom_date_from', '')
            custom_date_to = request.POST.get('custom_date_to', '')
            filter_status = request.POST.get('status', '')

            # Initialize the base queryset for farmers
            farmers = Farmer.objects.filter(Q(status=0) | Q(status=1) | Q(status=4) | Q(status=6)).order_by('-id')

            # Apply filters as before, using the POST data
            if farmer_id:
                farmers = farmers.filter(id=farmer_id)

            if phone:
                farmers = farmers.filter(phone__icontains=phone)

            if email:
                farmers = farmers.filter(email__icontains=email)

            if city_id:
                farmers = farmers.filter(city_id=city_id)
            
            if taluk_id:
                farmers = farmers.filter(taluk_id=taluk_id)
            
            if village_id:
                farmers = farmers.filter(village_id=village_id)
            
            if package_id:
                farmers = farmers.filter(subscription_package_id=package_id)
            
            if rem_days:
                farmers = farmers.filter(remaining_days=rem_days)

            if filter_status:
                if filter_status == '0':
                    farmers = farmers.filter(remaining_days=0)
                else:
                    farmers = farmers.exclude(remaining_days=0)

            if date_filter == 'today':
                farmers = farmers.filter(created_at__date=today_date)
            elif date_filter == 'week':
                start_of_week = today_date - timedelta(days=today_date.weekday())  # Monday
                farmers = farmers.filter(created_at__date__range=[start_of_week, today_date])
            elif date_filter == 'monthly':
                farmers = farmers.filter(created_at__year=today_date.year, created_at__month=today_date.month)
            elif date_filter == 'custom_date':
                if custom_date_from and custom_date_to:
                    custom_from_date = datetime.strptime(custom_date_from, '%d-%m-%Y').date()
                    custom_to_date = datetime.strptime(custom_date_to, '%d-%m-%Y').date()
                    farmers = farmers.filter(created_at__date__range=[custom_from_date, custom_to_date])

            show_per_page = request.POST.get('show', 25)
            show_per_page = int(show_per_page)  # Convert it to an integer

            # Pagination setup
            paginator = Paginator(farmers, show_per_page)  # Show the selected number of farmers per page 
            page_number = request.POST.get('page')  # Get the page number from the request
            page_obj = paginator.get_page(page_number)

            # Prepare the farmers data to display
            farmer_subscription_map = {
                farmer.id: farmer.subscription_details for farmer in farmers
            }

            farmers_data = []
            entries = 0
            for farmer in page_obj:
                entries += 1
                subscription_details = farmer_subscription_map.get(farmer.id)

                farmer_data = {
                    'id': farmer.id,
                    'name': farmer.name,
                    'phone': farmer.phone,
                    'email': farmer.email,
                    'city': farmer.city.name if farmer.city else '-',
                    'city_id': farmer.city.id if farmer.city else '-',
                    'taluk': farmer.taluk.name if farmer.taluk else '-',
                    'taluk_id': farmer.taluk.id if farmer.taluk else '-',
                    'village': farmer.village.name if farmer.village else '-',
                    'village_id': farmer.village.id if farmer.village else '-',
                    'description': farmer.description,
                    'status': farmer.status,
                    'company_name': farmer.company_name,
                    'tax_no': farmer.tax_no,
                    'username': farmer.username,
                    'password': farmer.password,
                    'sub_admin_username': farmer.sub_admin_username,
                    'sub_admin_password': farmer.sub_admin_password,
                    'created_at': farmer.created_at,
                    'farmer': farmer.farmer,
                    # 'farmertype': farmer.farmertype,
                    'subscription_details': {},
                    'img': farmer.img if farmer.img else 'assets/images/user_1.png'
                }

                if subscription_details:
                    start_date = subscription_details.get('start_date', '-')
                    end_date = subscription_details.get('end_date', '-')

                    if isinstance(start_date, date):
                        start_date = start_date.strftime('%Y-%m-%d')
                    if isinstance(end_date, date):
                        end_date = end_date.strftime('%Y-%m-%d')

                    farmer_data['subscription_details'] = {
                        'package_name': subscription_details.get('package_name', 'No Package'),
                        'package_duration': subscription_details.get('package_duration', '-'),
                        'package_validity': subscription_details.get('validity', '-'),
                        'start_date': start_date,
                        'end_date': end_date,
                        'remaining_days': subscription_details.get('remaining_days', '-'),
                        'amount': subscription_details.get('amount', '-'),
                        'sub_amount': subscription_details.get('sub_amount', '-'),
                        # 'add_on_details': subscription_details.get('add_on_details')
                    }
                else:
                    farmer_data['subscription_details'] = {
                        'package_name': 'No Package',
                        'package_duration': '-',
                        'package_validity': '-',
                        'start_date': '-',
                        'end_date': '-',
                        'remaining_days': '-',
                        'amount': '-',
                        'sub_amount': '-',
                        # 'add_on_details': []
                    }

                farmers_data.append(farmer_data)

            packages = PackageManagement.objects.filter(status=0).order_by('-id')
            packages_data = []
            for package in packages:
                # add_ons = package.add_on_details.all()
                package_data = {
                    'id': package.id,
                    'name': package.name,
                    'amount': package.amount,
                    'sub_amount': package.sub_amount,
                    'package_validity': package.package_validity,
                    'package_duration': package.package_duration.name if package.package_duration else '-',
                    # 'add_ons': [{'id': addon.id, 'name': addon.name} for addon in add_ons],
                }
                packages_data.append(package_data)

            all_farmers = Farmer.objects.filter(status__in=[0,1,3,4,5,6])
            total_farmer = all_farmers.count()
            exp_farmers = 0
            for f in all_farmers:
                if f.remaining_days == 0:
                    exp_farmers += 1

            # Pass data to the template
            context = {
                'farmers': page_obj,
                'entries_count': entries,
                'show_per_page': show_per_page,
                'total_farmer': total_farmer,
                'exp_farmers': exp_farmers,
                # 'farmertype': farmertype,
                # 'farmer_id': farmer_id,
                # 'phone': phone,
                # 'email': email,
                'package_id' : package_id if package_id else '',
                # 'rem_days' : rem_days,
                'city_id': int(city_id) if city_id else '',
                'taluk_id': int(taluk_id) if taluk_id else '',
                'village_id' :int(village_id) if village_id else '',
                'date_filter': date_filter,
                'custom_date_from': custom_date_from,
                'custom_date_to': custom_date_to,
                # 'farmer_types': list(FarmerType.objects.values('id', 'name')),
                'packages' : list(PackageManagement.objects.values('id', 'name')),
                'countries': list(Country.objects.values('id', 'name')),
                'states': list(State.objects.values('id', 'name')),
                'cities': list(City.objects.values('id', 'name')),
                'taluks' : list(Taluk.objects.values('id', 'name')),
                'villages' : list(Village.objects.values('id', 'name')),
                'filter_status' : filter_status,
                'users_details': CustomUser.objects.all(), 
                'can_add_farmer': manage_user.can_add_farmer if manage_user else False,
                'can_view_farmer': manage_user.can_view_farmer if manage_user else False,
                'can_edit_farmer': manage_user.can_edit_farmer if manage_user else False,
                'can_delete_farmer': manage_user.can_delete_farmer if manage_user else False,
                'can_view_unique_farmer': manage_user.can_view_unique_farmer if manage_user else False,
                'can_update_farmer_status': manage_user.can_update_farmer_status if manage_user else False,
                'can_export_farmer_data': manage_user.can_export_farmer_data if manage_user else False,
                'can_filter_farmer_data': manage_user.can_filter_farmer_data if manage_user else False,
                'packages': packages_data,  # Packages data with add-ons 
            }

            return render(request, 'pages/super_admin/farmer_management/list.html', context)

class FarmerManagementDetailsView(View):
    def get(self, request, farmer_id): 
        trigger_subscription()
        farmer = get_object_or_404(Farmer, id=farmer_id)
 
        farmer_data = {
            'id': farmer.id,
            'name': farmer.name,
            'phone': farmer.phone,
            'email': farmer.email,
            'country': farmer.country.name if farmer.country else '-',
            'state': farmer.state.name if farmer.state else '-',
            'city': farmer.city.name if farmer.city else '-',
            'taluk': farmer.taluk.name if farmer.taluk else '-',
            'village': farmer.village.name if farmer.village else '-',
            'description': farmer.description,
            'status': farmer.status,
            'company_name': farmer.company_name,
            'tax_no': farmer.tax_no,
            'door' : farmer.door_no,
            'pincode' : farmer.pincode,
            'username': farmer.username,
            'password': farmer.password,
            'sub_admin_username': farmer.sub_admin_username,
            'sub_admin_password': farmer.sub_admin_password,
            'created_at': farmer.created_at,
            'img': farmer.img if farmer.img else 'assets/images/user_1.png',
            'farmertype': farmer.farmertype.name if farmer.farmertype else '-',
        }
         
        if farmer.farmer_user:
            all_sessions = UserSession.objects.filter(user=farmer.farmer_user).order_by('-login_time')
 
            session_data = []
            for session in all_sessions:
                login_time = session.login_time
                logout_time = session.logout_time if session.logout_time else None
                duration = session.duration if session.duration else '-'

                session_data.append({
                    'login_time': login_time,
                    'logout_time': logout_time,
                    'duration': duration,
                })
 
            farmer_data['sessions'] = session_data
        
        subscriptions = farmer.subscriptions.all()

        subscription_data = []
        for subscription in subscriptions:
            subscription_data.append({
                'id' : subscription.id,
                'pack_id' : subscription.packages.id,
                'package_name': subscription.package_name,
                'package_duration': subscription.package_duration,
                'package_validity': subscription.package_validity,
                'start_date': subscription.startdate ,
                'end_date': subscription.enddate ,
                'remaining_days': subscription.remainingdays,
                'amount': subscription.amount,
                'sub_amount': subscription.sub_amount,
                'status' : subscription.status,
            })
 
        farmer_data['subscriptions'] = subscription_data
 
        context = {
            'farmer': farmer_data,
            'far': farmer,
        }
 
        return render(request, 'pages/super_admin/farmer_management/view.html', context)

class FarmerManagementUsageDetails(LoginRequiredMixin, View):
    def get(self, request, farmer_id):
        farmer = Farmer.objects.get(id=farmer_id)

        now = timezone.now()
        month_exp = 0
        today_exp = 0
        today = date.today()
        current_month = today.month
        current_year = today.year
        today_week = datetime.today()
        start_of_week = today_week - timedelta(days=today_week.weekday())  # Monday
        end_of_week = start_of_week + timedelta(days=6)  # Sunday

        # Filter expenses for the current month
        month_exp = MyExpense.objects.filter(
            farmer=farmer,
            status=0,
            created_at__year=today.year,
            created_at__month=today.month
        ).aggregate(Sum('amount'))['amount__sum'] or 0

        exp_month = month_exp
        # Filter expenses for the current day
        today_exp = MyExpense.objects.filter(
            farmer=farmer,
            status=0,
            created_day=today
        ).aggregate(Sum('amount'))['amount__sum'] or 0


        # Fuel expenses for the current month and today
        month_exp += MyFuel.objects.filter(
            farmer=farmer,
            status=0,
            date_of_consumption__year=today.year,
            date_of_consumption__month=today.month
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0

        today_exp += MyFuel.objects.filter(
            farmer=farmer,
            status=0,
            date_of_consumption=today
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0

        # Vehicle expenses for the current month and today
        month_exp += MyVehicle.objects.filter(
            farmer=farmer,
            status=0,
            date_of_consumption__year=today.year,
            date_of_consumption__month=today.month
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0

        today_exp += MyVehicle.objects.filter(
            status=0,
            farmer=farmer,
            date_of_consumption=today
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0


        # Machinery expenses for the current month and today
        month_exp += MyMachinery.objects.filter(
            farmer=farmer,
            status=0,
            date_of_consumption__year=today.year,
            date_of_consumption__month=today.month
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0

        today_exp += MyMachinery.objects.filter(
            farmer=farmer,
            status=0,
            date_of_consumption=today
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0

        # Tools expenses for the current month and today
        month_exp += MyTools.objects.filter(
            farmer=farmer,
            status=0,
            date_of_consumption__year=today.year,
            date_of_consumption__month=today.month
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0

        today_exp += MyTools.objects.filter(
            farmer=farmer,
            status=0,
            date_of_consumption=today
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0

        # Pesticides expenses for the current month and today
        month_exp += MyPesticides.objects.filter(
            farmer=farmer,
            status=0,
            date_of_consumption__year=today.year,
            date_of_consumption__month=today.month
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0

        today_exp += MyPesticides.objects.filter(
            farmer=farmer,
            status=0,
            date_of_consumption=today
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0

        # Fertilizers expenses for the current month and today
        month_exp += MyFertilizers.objects.filter(
            farmer=farmer,
            status=0,
            date_of_consumption__year=today.year,
            date_of_consumption__month=today.month
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0

        today_exp += MyFertilizers.objects.filter(
            farmer=farmer,
            status=0,
            date_of_consumption=today
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0

        # Seeds expenses for the current month and today
        month_exp += MySeeds.objects.filter(
            farmer=farmer,
            status=0,
            date_of_consumption__year=today.year,
            date_of_consumption__month=today.month
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0

        today_exp += MySeeds.objects.filter(
            farmer=farmer,
            status=0,
            date_of_consumption=today
        ).aggregate(Sum('purchase_amount'))['purchase_amount__sum'] or 0
       
        land_count = MyLand.objects.filter(farmer=farmer, status__in=[0,1]).count()
        crop_count = MyCrop.objects.filter(farmer=farmer, status__in=[0,1]).count()
        schedule_count = MySchedule.objects.filter(
            farmer=farmer,
            status__in=[0, 1],
            start_date__year=now.year,
            start_date__month=now.month
        ).count()

        total_sales_today = MySales.objects.filter(
            farmer=farmer,
            status__in=[0, 1],
            dates_of_sales=today
        ).aggregate(total_sales_today=Sum('total_sales_amount'))['total_sales_today'] or 0

        total_sales_month = MySales.objects.filter(
            farmer=farmer,
            status__in=[0, 1],
            dates_of_sales__year=current_year,
            dates_of_sales__month=current_month
        ).aggregate(total_sales_month=Sum('total_sales_amount'))['total_sales_month'] or 0

        customer_count = MyCustomer.objects.filter(farmer=farmer, status__in=[0,1]).count()
        # market_count = ManageMarket.objects.filter(village=farmer.village, status__in=[0,1]).count()
        nearby_count = ManageNearByLocations.objects.filter(village=farmer.village, status__in=[0,1]).count()
        
        # nearby_full_count = market_count + nearby_count 
        guidelines_count = Guidelines.objects.filter(status__in=[0]).count()
        total_purchase_amount_month = month_exp - exp_month

        advance_amount_today = EmployeeAdvance.objects.filter(
            farmer=farmer,
            created_day=today
        ).aggregate(total_advance_amount=Sum('advance_amount'))['total_advance_amount'] or 0

        advance_amount_month = EmployeeAdvance.objects.filter(
            farmer=farmer,
            created_day__year=current_year,
            created_day__month=current_month
        ).aggregate(total_advance_amount=Sum('advance_amount'))['total_advance_amount'] or 0
        
        payouts_amount_today = EmployeePayouts.objects.filter(
            farmer=farmer,
            created_day=today
        ).aggregate(total_payouts_amount=Sum('payout_amount'))['total_payouts_amount'] or 0

        payouts_amount_month = EmployeePayouts.objects.filter(
            farmer=farmer,
            created_day__year=current_year,
            created_day__month=current_month
        ).aggregate(total_payouts_amount=Sum('payout_amount'))['total_payouts_amount'] or 0


        context = {
            'farmer_id': farmer_id,
            'land_count' : land_count,
            'crop_count' : crop_count,
            'schedule_count' : schedule_count,
            'customer_count' : customer_count,
            'nearby_full_count' : nearby_count,
            'guidelines_count' : guidelines_count,
            'month_exp': month_exp,
            'today_exp': today_exp,
            'total_sales_today': total_sales_today,
            'total_sales_month': total_sales_month,
            'advance_amount_today' : advance_amount_today,
            'payouts_amount_today' : payouts_amount_today,
            'advance_amount_month' : advance_amount_month,
            'payouts_amount_month' : payouts_amount_month,
            'total_purchase_amount_month' : total_purchase_amount_month,
            'start_of_week' : start_of_week,
            'end_of_week' : end_of_week,
            'nearby_count':nearby_count,
        }
        return render(request,'pages/super_admin/farmer_management/details.html', context)

def export_farmer(request):
    farmer_id = request.GET.get('farmer', '')
    phone = request.GET.get('phone', '')
    email = request.GET.get('email', '')
    city_id = request.GET.get('city', '')
    package_id = request.GET.get('package', '')
    rem_days = request.GET.get('rem_days', '')
    date_filter = request.GET.get('date_filter', 'all')
    filter_status = request.GET.get('status', '')

    farmers = Farmer.objects.filter(Q(status=0) | Q(status=1) | Q(status=4)).order_by('-id')  # Active farmers

    if farmer_id:
        farmers = farmers.filter(id=farmer_id)

    if phone:
        farmers = farmers.filter(phone__icontains=phone)

    if email:
        farmers = farmers.filter(email__icontains=email)

    if city_id:
        farmers = farmers.filter(city_id=city_id)
    
    if package_id:
        farmers = farmers.filter(subscription_package_id=package_id)
    
    if rem_days:
        farmers = farmers.filter(remaining_days=rem_days)

    if filter_status:
            if filter_status == '0':
                farmers = farmers.filter(remaining_days=0)
            else:
                farmers = farmers.filter(status=0).exclude(remaining_days=0)

    if date_filter == 'today':
        farmers = farmers.filter(created_at__date=today_date)
    elif date_filter == 'week':
        start_of_week = today_date - timedelta(days=today_date.weekday())  # Monday
        farmers = farmers.filter(created_at__date__range=[start_of_week, today_date])
    elif date_filter == 'monthly':
        farmers = farmers.filter(created_at__year=today_date.year, created_at__month=today_date.month)
    elif date_filter == 'custom_date':
        custom_from_date = request.GET.get('custom_date_from')
        custom_to_date = request.GET.get('custom_date_to')
        if custom_from_date and custom_to_date:
            # Convert the date format from DD-MM-YYYY to YYYY-MM-DD
            custom_from_date = datetime.strptime(custom_from_date, '%d-%m-%Y').date()
            custom_to_date = datetime.strptime(custom_to_date, '%d-%m-%Y').date()
            farmers = farmers.filter(created_at__date__range=[custom_from_date, custom_to_date])

    # Create a CSV response
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="farmers.csv"'

    writer = csv.writer(response)
    # Write the header row
    writer.writerow([
        'Farmers', 'Phone Number', 'Email', 'Packages', 'Start Date', 'End Date', 'Remaining Days', 'Status'
    ])

    # Write the worker data
    for far in farmers:
        writer.writerow([
            far.name,
            far.phone if far.phone else '-',
            far.email if far.email else '-',
            far.subscription_package if far.subscription_package else '-',
            far.subscription_start_date if far.subscription_start_date else '-',
            far.subscription_end_date if far.subscription_end_date else '-',
            far.remaining_days if far.remaining_days else '0',
            'Active' if far.status == 0 else "In Active"
        ])

    return response

def farmer_details(request, farmer_id):
    try:
        try:
            settings = GeneralSetting.objects.first()
            date_format = convert_to_strftime_format(settings.date_format)
        except Exception as e:
            date_format = '%d-%M-%Y'
        farmer = Farmer.objects.get(id=farmer_id)

        # farmer = subscription.farmers
        # package = subscription.packages
        # farmer_type = farmer.farmertype if farmer else None

        # purchase_date = subscription.created_at.strftime(date_format) if subscription.created_at else '-'
        # start_date = subscription.startdate.strftime(date_format) if subscription.startdate else '-'
        # end_date = subscription.enddate.strftime(date_format) if subscription.enddate else '-'

        # add_on_details = [addon.name for addon in package.get_add_ons()] if package else 'No Add-Ons Available'
        farmer_img = farmer.img.url if farmer and farmer.img else None


        data = {
            'farmer_name': farmer.name if farmer else '-',
            'phone': farmer.phone if farmer.phone else '-',
            'email': farmer.email if farmer.email else '-',
            'farmer_img': farmer_img ,
            'sub_amount': farmer.sub_amounts if farmer.sub_amounts else 0,
            'package_amount': farmer.amounts if farmer.amounts else 0,
            'package_validity': farmer.subscription_package.package_validity if farmer.subscription_package else '-',
            'package_duration': farmer.subscription_package.package_duration.name if farmer.subscription_package and farmer.subscription_package.package_duration else '-',
            'start_date': farmer.subscription_start_date if farmer.subscription_start_date else '-',
            'end_date': farmer.subscription_end_date if farmer.subscription_end_date else '-',
        }

        # print(f"Data: {data}")  

        return JsonResponse(data)

    except AddSubcription.DoesNotExist:
        return JsonResponse({'error': 'farmer not found'}, status=404)

def fetch_subscriptions(request, farmer_id):
    # Get the farmer object
    farmer = get_object_or_404(Farmer, id=farmer_id)
    # Get subscriptions for this farmer
    subscriptions = farmer.subscriptions.filter(status__in = [0,1,3,4,5])
    
    # Create a list of subscriptions to send as JSON
    subscription_data = []
    for subscription in subscriptions:
        subscription_data.append({
            'package_name': subscription.packages.name,
            'package_validity': subscription.packages.package_validity,
            'package_duration': subscription.packages.package_duration.name,
            'start_date': subscription.startdate.strftime('%d-%m-%Y'),
            'end_date': subscription.enddate.strftime('%d-%m-%Y'),
            'amount': subscription.packages.sub_amount,
            'remaining_days': subscription.remainingdays,
            'status': subscription.status
        })

    session_data = []
    if farmer.farmer_user:
        all_sessions = UserSession.objects.filter(user=farmer.farmer_user).order_by('-id')

        for session in all_sessions:
            login_time = session.login_time
            # print(timezone.localtime(login_time))
            logout_time = session.logout_time if session.logout_time else None
            duration = logout_time - login_time if session.logout_time and session.login_time else '-'
            
            # Format the login time and logout time
            formatted_login_time = {
                'date': timezone.localtime(login_time).strftime('%d-%m-%Y'),   # Date format: DD-MM-YYYY
                'time': timezone.localtime(login_time).strftime('%H:%M:%S')    # Time format: HH:mm:ss
            }
            formatted_logout_time = None
            if logout_time:
                formatted_logout_time = {
                    'date': timezone.localtime(logout_time).strftime('%d-%m-%Y'),  # Date format: DD-MM-YYYY
                    'time': timezone.localtime(logout_time).strftime('%H:%M:%S')   # Time format: HH:mm:ss
                }
            duration_str = format_duration(duration)

            session_data.append({
                'login_time': formatted_login_time,
                'logout_time': formatted_logout_time,
                'duration': duration_str,
            })
    
    return JsonResponse({'subscriptions': subscription_data, 'session_data': session_data})

def format_duration(duration):
    """Format timedelta duration into HH:mm:ss"""
    if isinstance(duration, timedelta):
        total_seconds = int(duration.total_seconds())
        
        # Get the number of days, hours, minutes, and seconds
        days = total_seconds // 86400
        hours = (total_seconds % 86400) // 3600
        minutes = (total_seconds % 3600) // 60
        seconds = total_seconds % 60

        # If days > 0, add them to the hour calculation
        hours += days * 24
        
        # Return formatted duration as HH:mm:ss
        return f"{hours:02}:{minutes:02}:{seconds:02}"
    
    return "-"

def get_land_details(request, farmer_id):
    try:
        # Fetch land details for the given farmer ID
        lands = MyLand.objects.filter(farmer_id=farmer_id, status=0)

        if not lands:
            return JsonResponse({"message": "No land details found for this farmer"}, status=404)
        
        # Prepare the land details in the desired format
        land_data = []
        for land in lands:
            land_info = {
                "name": land.name.title() if land.name else '-',
                "measurement_value": land.measurement_value if land.measurement_value else '-',
                "measurement_unit": land.measurement_unit.name if land.measurement_unit else '-',
                "soil_type": land.soil_type.name.title() if land.soil_type else '-',
                "village": land.village.name.title() if land.village else '-',
                "taluk": land.taluk.name.title() if land.taluk else '-',
                "patta_number": land.patta_number if land.patta_number else '-',
                "locations": land.locations,
                "latitude": land.latitude,
                "longitude": land.longitude
            }
            land_data.append(land_info)

        return JsonResponse(land_data, safe=False)  # Return the land data as a JSON response

    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)


# ------------------------------------------------------------ Schedule Management --------------------------------------------------

class ScheduleView(LoginRequiredMixin,View):
    def get(self, request):
        type_id = request.GET.get('filter_crop_type_id')
        crop_id = request.GET.get('filter_crop_id')
            
        # crop_schedules = Schedule.objects.filter(status__in=[0, 1]) \
        #                                 .values('crop', 'status') \
        #                                 .annotate(schedule_count=Count('id')) \
        #                                 .order_by('crop')

        crop_schedules = Schedule.objects.filter(status__in=[0, 1]) \
            .values('crop','status', 'crop__croptype__name').annotate(schedule_count=Count('id'), latest_created_at=Max('created_at')) \
            .order_by('-latest_created_at')
        
        if type_id:
            crop_schedules = crop_schedules.filter(crop__croptype__id=int(type_id))
        if crop_id:
            crop_schedules = crop_schedules.filter(crop__id=int(crop_id))

        result = []
        for idx, schedule in enumerate(crop_schedules, start=1):
            crop = schedule['crop']
            schedule_count = schedule['schedule_count']
            status = schedule['status'] 
            
            # You can also retrieve crop details (like type) if needed
            crop_obj = Crop.objects.get(id=crop)
            crop_type = crop_obj.croptype.name if crop_obj.croptype else 'Unknown'

            result.append({
                'SNO': idx,
                'CropID': crop_obj.id,
                'Crop': crop_obj.name,
                'Crop_Type': crop_type,
                'Schedules_counts': schedule_count,
                'status': status,
                # 'id': schedule.id,
            })

        crops = Crop.objects.filter(status=0)
        crop_types = CropType.objects.filter(status=0)
        activity_types = ScheduleActivityType.objects.filter(status=0)

        crop_types_dict = {}
        for crop in crops:
            if crop.croptype:
                if crop.croptype.name not in crop_types_dict:
                    crop_types_dict[crop.croptype.name] = []
                crop_types_dict[crop.croptype.name].append(crop) 

        show_per_page = request.GET.get('show',25)
        show_per_page = int(show_per_page)  # Convert it to an integer

        # Pagination setup
        paginator = Paginator(result, show_per_page)  # Show the selected number of farmers per page 
        page_number = request.GET.get('page')  # Get the page number from the request
        page_obj = paginator.get_page(page_number)

        result_count = 0
        for i in page_obj:
            result_count += 1
        
        context = {
            'result': page_obj,
            'entries_count': result_count,
            'show_per_page': show_per_page,
            # 'schedules': schedules,
            'crops': crops,
            'crop_types': crop_types,
            'activity_types': activity_types,
            'crop_types_dict': crop_types_dict, 
            'messages': messages.get_messages(request),  # Pass messages to the template
            'type_id': int(type_id) if type_id else '',
            'crop_id': int(crop_id) if crop_id else '',
        }
        return render(request, 'pages/super_admin/schedule_management/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            crop_id = request.POST.get('crop')
            days = request.POST.get('days') 
            activity_type_id = request.POST.get('activity_type')
            description = request.POST.get('description')
 
            if not Crop.objects.filter(id=crop_id).exists():
                messages.error(request, 'Invalid Crop ID.')
                return redirect('sa_schedule')

            # if not ScheduleActivityType.objects.filter(id=activity_type_id).exists():
            #     messages.error(request, 'Invalid Activity Type ID.')
            #     return redirect('sa_schedule')
 
            if not crop_id or not days  :
                messages.error(request, 'Crop, Days, are required.')
                return redirect('sa_schedule')
 
            if Schedule.objects.filter(crop_id=crop_id, days=days, status__in=[0, 1]).exists():
                context = {
                    'schedules': Schedule.objects.all(),
                    'crops': Crop.objects.all(),
                    'activity_types': ScheduleActivityType.objects.all(),
                    'error': 'Schedule already exists for this crop and activity type.'
                }
                return render(request, 'pages/super_admin/schedule_management/list.html', context)
 
            sch = Schedule.objects.create(
                crop_id=crop_id,
                days=days,
                description=description,status=0,
                created_by=user,
                created_at=timezone.now()
            )
            if activity_type_id:
                sch.activity_type_id=activity_type_id
                sch.save()
            messages.success(request, 'Schedule Created Successfully.')
            return redirect('sa_schedule')
        
        elif action == 'update':
            pk = request.POST.get('id')
            
            if not pk:  # Check if the id is empty
                messages.error(request, 'Schedule ID is required for update.')
                return redirect('sa_schedule')

            schedule = get_object_or_404(Schedule, pk=pk)
            translated_json = schedule.translate_json or {
                "description": {}
            }
            crop_id = request.POST.get('crop')
            days = request.POST.get('days')
            activity_type_id = request.POST.get('activity_type')
            description = request.POST.get('description')

            if not crop_id or not days:
                messages.error(request, 'Crop, Days are Required.')
                return redirect('sa_schedule')

            schedule.crop_id = crop_id
            schedule.days = days
            if activity_type_id:
                schedule.activity_type_id = activity_type_id
            if schedule.description != description:
                schedule.description = description
                try:
                    for lang in target_language:
                        translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                        translated_json["description"][lang] = translated_text
                except Exception as e:
                    print(e)
                    print("Error in translating ")
            schedule.updated_by = user
            schedule.translate_json = translated_json
            schedule.save()
            messages.success(request, 'Schedule Updated Successfully.')
            return redirect('sa_schedule')

        elif action == 'update_status':
            pk = request.POST.get('id')
            crop_id = request.POST.get('crop_id')

            status = request.POST.get('status')  

            if status == '0':
                # schedule.status = 0  
                # schedule.updated_by = user 
                # schedule.save()

                sch = Schedule.objects.filter(crop__id=int(crop_id), status__in=[0,1])
                for i in sch:
                    i.status=0
                    i.save()
                
                messages.success(request, "Schedule Has Been Activated.")   
            elif status == '1':
                # schedule.status = 1  
                # schedule.updated_by = user
                # schedule.save()

                sch = Schedule.objects.filter(crop__id=int(crop_id), status__in=[0,1])
                for i in sch:
                    i.status=1
                    i.save()

                messages.success(request, "Schedule Has Been Deactivated.")  

            # if not pk:
            #     messages.error(request, "ID cannot be empty.")
            # else:
            #     # Update the model from ScheduleActivityType to Schedule
            #     schedule = get_object_or_404(Schedule, pk=pk)  

            #     status = request.POST.get('status')  

            #     if status == '0':
            #         schedule.status = 0  
            #         schedule.updated_by = user 
            #         schedule.save()

            #         sch = Schedule.objects.filter(crop__id=int(crop_id), status__in=[0,1])
            #         for i in sch:
            #             i.status=0
            #             i.save()
                    
            #         messages.success(request, "Schedule has been activated.")   
            #     elif status == '1':
            #         schedule.status = 1  
            #         schedule.updated_by = user
            #         schedule.save()

            #         sch = Schedule.objects.filter(crop__id=int(crop_id), status__in=[0,1])
            #         for i in sch:
            #             i.status=1
            #             i.save()

            #         messages.success(request, "Schedule has been deactivated.")  
            #     else:
            #         messages.error(request, "Invalid status value.")  

            return redirect('sa_schedule')  

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    schedule = get_object_or_404(Schedule, pk=pk)  
                    schedule.status = 2  
                    schedule.updated_by = user
                    schedule.save()

                    messages.success(request, "Schedule Has Been Deleted Successfully.")  
                except Schedule.DoesNotExist:
                    messages.error(request, "Schedule Not Found.")  

            return redirect('sa_schedule')

        elif action == 'filter':
            type_id = request.POST.get('filter_crop_type_id')
            crop_id = request.POST.get('filter_crop_id')

            if not type_id and  not crop_id:
                return redirect('sa_schedule')

            crop_schedules = Schedule.objects.filter(status__in=[0, 1]) \
                            .values('crop', 'status') \
                            .annotate(schedule_count=Count('id')) \
                            .order_by('crop')
            
            if type_id:
                crop_schedules = crop_schedules.filter(crop__croptype__id=int(type_id))
            if crop_id:
                crop_schedules = crop_schedules.filter(crop__id=int(crop_id))

            result = []
            for idx, schedule in enumerate(crop_schedules, start=1):
                crop = schedule['crop']
                schedule_count = schedule['schedule_count']
                status = schedule['status'] 
                
                crop_obj = Crop.objects.get(id=crop)
                crop_type = crop_obj.croptype.name if crop_obj.croptype else 'Unknown'

                result.append({
                    'SNO': idx,
                    'CropID': crop_obj.id,
                    'Crop': crop_obj.name,
                    'Crop_Type': crop_type,
                    'Schedules_counts': schedule_count,
                    'status': status,
                })
  
            crops = Crop.objects.filter(status=0)
            crop_types = CropType.objects.filter(status=0)
            activity_types = ScheduleActivityType.objects.filter(status=0)

            crop_types_dict = {}
            for crop in crops:
                if crop.croptype:
                    if crop.croptype.name not in crop_types_dict:
                        crop_types_dict[crop.croptype.name] = []
                    crop_types_dict[crop.croptype.name].append(crop) 

            context = {
                'result': result,
                'crops': crops,
                'crop_types': crop_types,
                'activity_types': activity_types,
                'crop_types_dict': crop_types_dict, 
                'messages': messages.get_messages(request),  # Pass messages to the template
                'type_id': int(type_id) if type_id else '',
                'crop_id': int(crop_id) if crop_id else '',
            }
            return render(request, 'pages/super_admin/schedule_management/list.html', context)


        return redirect('sa_schedule')

class ScheduleViewDetails(LoginRequiredMixin, View):
    def get(self, request, crop_id):
        schedule = Schedule.objects.filter(crop__id=crop_id,status=0).order_by('days')
        activity_types = ScheduleActivityType.objects.filter(status=0)
        crop = get_object_or_404(Crop, pk=crop_id)
        context = {
            'schedule': schedule,
            'activity_types': activity_types,
            'crop_id': crop_id,
            'crop': crop,
        }
        return render(request, 'pages/super_admin/schedule_management/view.html', context)

    def post(self, request, crop_id):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)

        action = request.POST.get('action')
        crop = get_object_or_404(Crop, pk=crop_id)

        if action == 'update':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, 'Schedule ID is required for Update.')
                return redirect('sa_schedule')

            schedule = get_object_or_404(Schedule, pk=pk,status=0)
            days = request.POST.get('days')
            activity_type_id = request.POST.get('activity_type')
            description = request.POST.get('description')

            schedule.crop_id = crop.id
            schedule.days = days
            if activity_type_id:
                schedule.activity_type_id = activity_type_id
            else:
                schedule.activity_type_id = None
            schedule.description = description
            schedule.updated_by = user
            schedule.save()
            messages.success(request, 'Schedule Updated Successfully.')
            return redirect('sa_schedule')

        elif action == 'filter':
            filter_activity = request.POST.get('filter_schedule')

            if not filter_activity:
                return redirect('sa_schedule')

            schedule = Schedule.objects.filter(crop__id=crop_id).order_by('days')

            if filter_activity:
                schedule = schedule.filter(activity_type__id=int(filter_activity))

            activity_types = ScheduleActivityType.objects.filter(status=0)
            crop = get_object_or_404(Crop, pk=crop_id)
            context = {
                'schedule': schedule,
                'activity_types': activity_types,
                'crop_id': crop_id,
                'crop': crop,
                'filter_activity': int(filter_activity) if filter_activity else '',
            }
            return render(request, 'pages/super_admin/schedule_management/view.html', context)

# Import schedule with new crop and crop types accepted.
def import_schedule(request):
    if request.method == 'POST' and request.FILES.get('file_upload'):
        file = request.FILES['file_upload']
        
        # Handling CSV file upload
        if file.name.endswith('.csv'):
            try:
                file_data = file.read().decode('utf-8').splitlines()
                reader = csv.DictReader(file_data)

                # Process each row in the CSV
                for row in reader:
                    crop_name_from_file = row['Crop'].strip().lower()
                    days_from_file = row['Days']
                    activity_type_from_file = row['Schedule Activity Type'].strip().lower()
                    description_from_file = row['Description'].strip()
                    crop_type_from_file = row['Crop Type'].strip().lower()  # Crop Type from the file

                    # Get or create CropType, considering if it already exists
                    if not crop_name_from_file and not days_from_file and not description_from_file:
                        continue

                    # Get or create Crop, considering if it's marked as deleted (status=2)
                    crop = Crop.objects.filter(name__iexact=crop_name_from_file).first()

                    # Check if the crop exists and its status is 2 (deleted)
                    if crop and crop.status == 2:
                        crop_type = CropType.objects.filter(name__iexact=crop_type_from_file).first()
                        if not crop_type:
                            crop_type = CropType.objects.create(name=crop_type_from_file)
                        crop = Crop.objects.create(name=crop_name_from_file, croptype=crop_type)
                    elif not crop:
                        crop_type = CropType.objects.filter(name__iexact=crop_type_from_file).first()
                        if not crop_type:
                            crop_type = CropType.objects.create(name=crop_type_from_file)
                        crop = Crop.objects.create(name=crop_name_from_file, croptype=crop_type)

                    # Validate and get or create ScheduleActivityType
                    activity_type = ScheduleActivityType.objects.filter(name__iexact=activity_type_from_file).first()
                    if not activity_type and activity_type_from_file:
                        activity_type = ScheduleActivityType.objects.create(name=activity_type_from_file)

                    if not activity_type:
                        continue

                    # Check if schedule already exists
                    if Schedule.objects.filter(crop=crop, days=days_from_file, status__in=[0, 1]).exists():
                        continue

                    # Create new Schedule record
                    schedule = Schedule.objects.create(
                        crop=crop,
                        days=days_from_file,
                        description=description_from_file,
                        status=0,
                        activity_type=activity_type,
                        created_at = timezone.now()
                    )

                messages.success(request, 'Schedules Created From CSV File Successfully.')
                return redirect('sa_schedule')

            except Exception as e:
                messages.error(request, "Error Processing The CSV File")
                return redirect('sa_schedule')

        # Handling Excel file upload
        elif file.name.endswith(('.xlsx', '.xls')):
            try:
                df = pd.read_excel(file, engine='openpyxl')

                # Process each row in the Excel file
                for index, row in df.iterrows():
                    crop_name_from_file = row['Crop'].strip().lower()
                    days_from_file = row['Days']
                    activity_type_from_file = row['Schedule Activity Type'].strip().lower()
                    description_from_file = row['Description'].strip()
                    crop_type_from_file = row['Crop Type'].strip().lower() 

                    if not crop_name_from_file and not days_from_file and not description_from_file:
                        continue

                    crop = Crop.objects.filter(name__iexact=crop_name_from_file).first()

                    # Check if the crop exists and its status is 2 (deleted)
                    if crop and crop.status == 2:
                        crop_type = CropType.objects.filter(name__iexact=crop_type_from_file).first()
                        if not crop_type:
                            crop_type = CropType.objects.create(name=crop_type_from_file)
                        crop = Crop.objects.create(name=crop_name_from_file, croptype=crop_type)
                    elif not crop:
                        crop_type = CropType.objects.filter(name__iexact=crop_type_from_file).first()
                        if not crop_type:
                            crop_type = CropType.objects.create(name=crop_type_from_file)
                        crop = Crop.objects.create(name=crop_name_from_file, croptype=crop_type)

                    # Validate and get or create ScheduleActivityType
                    activity_type = ScheduleActivityType.objects.filter(name__iexact=activity_type_from_file).first()
                    if not activity_type and activity_type_from_file:
                        activity_type = ScheduleActivityType.objects.create(name=activity_type_from_file)
                    
                    if not activity_type:
                        continue

                    # Check if schedule already exists
                    if Schedule.objects.filter(crop=crop, days=days_from_file, status__in=[0, 1]).exists():
                        continue

                    # Create new Schedule record
                    schedule = Schedule.objects.create(
                        crop=crop,
                        days=days_from_file,
                        description=description_from_file,
                        status=0,
                        activity_type=activity_type,
                        created_at = timezone.now()
                    )

                messages.success(request, 'Schedules Created From Excel File Successfully.')
                return redirect('sa_schedule')

            except Exception as e:
                messages.error(request, "Error processing the Excel file")
                return redirect('sa_schedule')

        else:
            messages.error(request, 'Invalid file format. Please upload a CSV or Excel file.')
            return redirect('sa_schedule')
    else:
        messages.error(request, 'No File Uploaded.')
        return redirect('sa_schedule')

# ---------------------------------------------------------------------------- Manage Workers --------------------------------------------------

def get_work_typ_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = WorkersType.objects.get(pk=pk)
    except WorkersType.DoesNotExist:
        return JsonResponse({'error': 'data not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)
    
    return JsonResponse({
        'name': name,
        'description': description
    })

class ManPowerWorkTypeView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_workers_type': True,
                'can_view_workers_type': True,
                'can_edit_workers_type': True,
                'can_delete_workers_type': True,  
                'can_update_workers_type_status': True,   
        
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_workers_type:
                return redirect('user_not_allowed')   

        work_types = WorkersType.objects.filter(Q(status=0) | Q(status=1)).order_by('-created_at')

        languages = Languages.objects.filter(status=0).order_by('id')
        context = {
            'languages': languages,
            'work_types': work_types,
            'messages': messages.get_messages(request),  
            'can_add_workers_type': manage_user.can_add_workers_type if manage_user else False,
            'can_view_workers_type': manage_user.can_view_workers_type if manage_user else False,
            'can_edit_workers_type': manage_user.can_edit_workers_type if manage_user else False,
            'can_delete_workers_type': manage_user.can_delete_workers_type if manage_user else False,
            'can_update_workers_type_status': manage_user.can_update_workers_type_status if manage_user else False, 
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/man_power_work_type/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')
            work_types = WorkersType.objects.all()

            # Validate name
            if not name:
                context = {
                    'work_types': work_types,
                    'error': 'This field is required.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/man_power_work_type/list.html', context)

            # Check for duplicates
            if WorkersType.objects.filter(name=name, status__in=[0,1]).exists():
                context = {
                    'work_types': work_types,
                    'error': f'Work Type "{name}" already exists.'
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/man_power_work_type/list.html', context)

            # Create the ManPower Work Type
            WorkersType.objects.create(name=name, description=description, status=0,created_by = user)
            messages.success(request, 'Work Type created successfully.')
            return redirect('sa_man_power_work_type')

        elif action == 'update':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, 'No ID provided for update.')
                return redirect('sa_man_power_work_type')
            
            work_type = get_object_or_404(WorkersType, pk=pk)
            translated_json = work_type.translate_json or {
                "name": {},
                "description": {}
            }
            name = request.POST.get('name')
            description = request.POST.get('description')
            language = request.POST.get('language')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_man_power_work_type')

            # work_type.name = name
            # work_type.description = description
            work_type.updated_by = user
            if language == "en":
                if work_type.name != name:
                    work_type.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translating ")
                if work_type.description != description:
                    work_type.description = description
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                            translated_json["description"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translating ")
            else:
                translated_json["name"][language] = name
                if description:
                    translated_json["description"][language] = description 
            
            work_type.translate_json = translated_json
            work_type.save()
            
            messages.success(request, 'Work Type updated successfully.')
            return redirect('sa_man_power_work_type')

        elif action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                work_type = get_object_or_404(WorkersType, pk=pk)

                status = request.POST.get('status')  # Expected status: '0' or '1'

                if status == '0':
                    work_type.status = 0  
                    work_type.updated_by = user 
                    work_type.save()
                    messages.success(request, "Work Type has been activated.")   
                elif status == '1':
                    work_type.status = 1  
                    work_type.updated_by = user
                    work_type.save()
                    messages.success(request, "Work Type has been deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  

            return redirect('sa_man_power_work_type')  

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    work_type = get_object_or_404(WorkersType, pk=pk)  
                    work_type.status = 2  # Deactivate the work type
                    work_type.updated_by = user
                    work_type.save()
                    messages.success(request, "Work Type has been Deleted successfully.")  
                except WorkersType.DoesNotExist:
                    messages.error(request, "Work Type not found.")  

            return redirect('sa_man_power_work_type')

        return redirect('sa_man_power_work_type')

class ManageWorkersView(LoginRequiredMixin, View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_manage_workers': True,
                'can_view_manage_workers': True,
                'can_edit_manage_workers': True,
                'can_delete_manage_workers': True,  
                'can_view_unique_manage_workers':True,
                'can_update_manage_workers_status': True,   
                'can_export_manage_workers': True,  
                'can_update_manage_workers':True,
                'can_filter_manage_workers': True,   
  
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_manage_workers:
                return redirect('user_not_allowed') 
        
        all_emp_type = EmployeeType.objects.all()
        all_state = State.objects.filter(status=0)
        all_city = City.objects.filter(status=0)
        all_village = Village.objects.filter(status=0)
        all_taluk = Taluk.objects.filter(status=0)
        workers_types = WorkersType.objects.filter(status=0)
        sers = ManageUser.objects.filter(usertype__code=1)

        # Initialize query for workers
        workers = ManageWorkers.objects.filter(Q(status=0) | Q(status=1)).order_by('-id')  

        # Handle GET request parameters for filtering
        worker_id = request.GET.get('worker_id', None)
        mobile_no = request.GET.get('mobile_no', None)
        work_type_id = request.GET.get('work_type_id', None)
        emp_type_id = request.GET.get('emp_type_id', None)
        state_id = request.GET.get('state_id', None)
        city_id = request.GET.get('city_id', None)
        taluk_id = request.GET.get('taluk_id', None)
        village_id = request.GET.get('village_id', None)
        # work_status = request.GET.get('work_status', None)

        # Apply filters based on the GET parameters
        if worker_id:
            workers = workers.filter(worker_id=worker_id)
        if mobile_no:
            # usersss = ManageUser.objects.filter(mobile_no=mobile_no)
            workers = workers.filter(worker__mobile_no__icontains=mobile_no)
        if work_type_id:
            workers = workers.filter(workerstype__id=work_type_id)
        if emp_type_id:
            workers = workers.filter(worker__employee_type__id=emp_type_id)
        if state_id:
            workers = workers.filter(worker__state_id=state_id)
        if city_id:
            workers = workers.filter(worker__city_id=city_id)
        if taluk_id:
            workers = workers.filter(worker__taluk_id=taluk_id)
        if village_id:
            workers = workers.filter(worker__village_id=village_id)
        
        workers_count_by_type = workers.values('workerstype').annotate(worker_count=Count('id')).order_by('-worker_count')
        sers = ManageUser.objects.filter(usertype__code=1)
        workers_types = WorkersType.objects.filter(status=0)
        wrk_typ_name = []
        for i in workers_types:
            wrk_typ_name.append(i.name.replace(' Work',''))

        show_per_page = request.GET.get('show',25)
        show_per_page = int(show_per_page)

        paginator = Paginator(workers, show_per_page)
        page_number = request.GET.get('page')
        page_obj = paginator.get_page(page_number)

        wrk_count = 0
        worker_data = {}
        worker_count = {}
        for worker in page_obj:
            wrk_count += 1
            # Get all work types and their respective person counts for this worker
            worker_work_types = WorkerWorkType.objects.filter(worker=worker,work_type__in=workers_types)
            
            worker_count[worker.id] = sum(wt.person_count for wt in worker_work_types)
            
            # Store the person count per work type for the worker
            worker_data[worker.id] = {wt.work_type.name.replace(' Work',''): wt.person_count for wt in worker_work_types}

        context = {
            'worker_count':worker_count,
            'emp_type' : all_emp_type,
            'state' : all_state,
            'city' : all_city,
            'show_per_page': show_per_page,
            'wrk_count': wrk_count,
            'village' : all_village,
            'taluk' : all_taluk,
            'workers': page_obj,
            'workers_types':wrk_typ_name,
            'wts' : workers_types,
            'users': sers,
            'worker_data': worker_data,  # Pass the worker data to the template
            'messages': messages.get_messages(request), 
           'worker_id': int(worker_id) if worker_id else '',
            'mobile_no' : mobile_no if mobile_no else '',
            'work_type_id': int(work_type_id) if work_type_id else '',
            'emp_type_id': int(emp_type_id) if emp_type_id else '',
            'state_id': int(state_id) if state_id else '',
            'city_id': int(city_id) if city_id else '',
            'taluk_id': int(taluk_id) if taluk_id else '',
            'village_id': int(village_id) if village_id else '',
            # 'work_status':work_status if work_status else '',
            'workers_count_by_type': workers_count_by_type,
            'can_add_manage_workers': manage_user.can_add_manage_workers if manage_user else False,
            'can_view_manage_workers': manage_user.can_view_manage_workers if manage_user else False,
            'can_edit_manage_workers': manage_user.can_edit_manage_workers if manage_user else False,
            'can_delete_manage_workers': manage_user.can_delete_manage_workers if manage_user else False,
            'can_update_manage_workers_status': manage_user.can_update_manage_workers_status if manage_user else False, 
            'can_view_unique_manage_workers': manage_user.can_view_unique_manage_workers if manage_user else False,
            'can_export_manage_workers': manage_user.can_export_manage_workers if manage_user else False,
            'can_update_manage_workers': manage_user.can_update_manage_workers if manage_user else False,
            'can_filter_manage_workers': manage_user.can_filter_manage_workers if manage_user else False, 
        
        }
        
        return render(request, 'pages/super_admin/workers_availability_provider/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                workers = get_object_or_404(ManageWorkers, pk=pk)
                status = request.POST.get('status')  # Expected status: '0' or '1'
                if status == '0':
                    workers.status = 0   
                    workers.updated_by = user
                    workers.save()
                    messages.success(request, "Workers has been activated.")   
                elif status == '1':
                    workers.status = 1  
                    workers.updated_by = user
                    workers.save()
                    messages.success(request, "Workers has been deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  

            return redirect('sa_manage_workers')  

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                try:
                    workers = get_object_or_404(ManageWorkers, pk=pk)
                    workers.status = 2  
                    workers.updated_by = user
                    workers.save()

                    messages.success(request, "Workers has been Deleted successfully.")
                except ManageWorkers.DoesNotExist:
                    messages.error(request, "Workers not found.")

            return redirect('sa_manage_workers')

        elif action == 'filter':
            user = request.user
            manage_user = None
            if user.is_superuser:
                context = {
                    'can_add_manage_workers': True,
                    'can_view_manage_workers': True,
                    'can_edit_manage_workers': True,
                    'can_delete_manage_workers': True,  
                    'can_view_unique_manage_workers':True,
                    'can_update_manage_workers_status': True,   
                    'can_export_manage_workers': True,  
                    'can_update_manage_workers':True,
                    'can_filter_manage_workers': True,   
    
                }
            else:
                try:
                    manage_user = ManageUser.objects.get(custom_user_id=user.id)
                except ManageUser.DoesNotExist:
                    manage_user = None

                if manage_user and not manage_user.can_view_manage_workers:
                    return redirect('user_not_allowed') 
            
            all_emp_type = EmployeeType.objects.all()
            all_state = State.objects.filter(status=0)
            all_city = City.objects.filter(status=0)
            all_village = Village.objects.filter(status=0)
            all_taluk = Taluk.objects.filter(status=0)
            workers_types = WorkersType.objects.filter(status=0)
            sers = ManageUser.objects.filter(usertype__code=1)

            # Initialize query for workers
            workers = ManageWorkers.objects.filter(Q(status=0) | Q(status=1)).order_by('-id')  

            # Handle GET request parameters for filtering
            worker_id = request.POST.get('worker_id', None)
            mobile_no = request.POST.get('mobile_no', None)
            work_type_id = request.POST.get('work_type_id', None)
            emp_type_id = request.POST.get('emp_type_id', None)
            state_id = request.POST.get('state_id', None)
            city_id = request.POST.get('city_id', None)
            taluk_id = request.POST.get('taluk_id', None)
            village_id = request.POST.get('village_id', None)

            if not worker_id and not mobile_no and not work_type_id and not emp_type_id and not state_id and not city_id and not taluk_id and not village_id:
                return redirect('sa_manage_workers')

            # Apply filters based on the GET parameters
            if worker_id:
                workers = workers.filter(worker_id=worker_id)
            if mobile_no:
                # usersss = ManageUser.objects.filter(mobile_no=mobile_no)
                workers = workers.filter(worker__mobile_no__icontains=mobile_no)
            if work_type_id:
                workers = workers.filter(workerstype__id=work_type_id)
            if emp_type_id:
                workers = workers.filter(worker__employee_type__id=emp_type_id)
            if state_id:
                workers = workers.filter(worker__state_id=state_id)
            if city_id:
                workers = workers.filter(worker__city_id=city_id)
            if taluk_id:
                workers = workers.filter(worker__taluk_id=taluk_id)
            if village_id:
                workers = workers.filter(worker__village_id=village_id)
            
            workers_count_by_type = workers.values('workerstype').annotate(worker_count=Count('id')).order_by('-worker_count')
            sers = ManageUser.objects.filter(usertype__code=1)
            workers_types = WorkersType.objects.filter(status=0)
            wrk_typ_name = []
            for i in workers_types:
                wrk_typ_name.append(i.name.replace(' Work',''))

            # Fetch work type-person count relationship for each worker
            worker_data = {}
            for worker in workers:
                # Get all work types and their respective person counts for this worker
                worker_work_types = WorkerWorkType.objects.filter(worker=worker)
                
                # Store the person count per work type for the worker
                worker_data[worker.id] = {wt.work_type.name.replace(' Work',''): wt.person_count for wt in worker_work_types}

            context = {
                'emp_type' : all_emp_type,
                'state' : all_state,
                'city' : all_city,
                'village' : all_village,
                'taluk' : all_taluk,
                'workers': workers,
                'workers_types':wrk_typ_name,
                'wts' : workers_types,
                'users': sers,
                'worker_data': worker_data,  # Pass the worker data to the template
                'messages': messages.get_messages(request), 
                'worker_id': int(worker_id) if worker_id else '',
                'mobile_no' : mobile_no if mobile_no else '',
                'work_type_id': int(work_type_id) if work_type_id else '',
                'emp_type_id': int(emp_type_id) if emp_type_id else '',
                'state_id': int(state_id) if state_id else '',
                'city_id': int(city_id) if city_id else '',
                'taluk_id': int(taluk_id) if taluk_id else '',
                'village_id': int(village_id) if village_id else '',
                'workers_count_by_type': workers_count_by_type,
                'can_add_manage_workers': manage_user.can_add_manage_workers if manage_user else False,
                'can_view_manage_workers': manage_user.can_view_manage_workers if manage_user else False,
                'can_edit_manage_workers': manage_user.can_edit_manage_workers if manage_user else False,
                'can_delete_manage_workers': manage_user.can_delete_manage_workers if manage_user else False,
                'can_update_manage_workers_status': manage_user.can_update_manage_workers_status if manage_user else False, 
                'can_view_unique_manage_workers': manage_user.can_view_unique_manage_workers if manage_user else False,
                'can_export_manage_workers': manage_user.can_export_manage_workers if manage_user else False,
                'can_update_manage_workers': manage_user.can_update_manage_workers if manage_user else False,
                'can_filter_manage_workers': manage_user.can_filter_manage_workers if manage_user else False, 
            
            }
            
            return render(request, 'pages/super_admin/workers_availability_provider/list.html', context)

        return redirect('sa_manage_workers')
    
class ManageWorkersCreateView(LoginRequiredMixin, View):
    def get(self, request):
        trigger_subscription()
        users = ManageUser.objects.filter(usertype__code=1)  
        work_types = WorkersType.objects.filter(status=0)
        previous_workers = ManageWorkers.objects.filter(status__in=[0, 1]).values_list('worker', flat=True)
        
        context = {
            'users': users,
            'previous_workers': previous_workers,
            'work_types': work_types,
            'messages': messages.get_messages(request),
        }
        return render(request, 'pages/super_admin/workers_availability_provider/add_worker.html', context)
 
    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)

        worker_id = request.POST.get('worker')
        try:
            worker = ManageUser.objects.get(id=worker_id)
        except ManageUser.DoesNotExist:
            messages.error(request, 'Selected worker does not exist.')
            return redirect('sa_manage_workers_create')

        try:
            manage_worker = ManageWorkers.objects.get(worker=worker)
        except ManageWorkers.DoesNotExist:
            # Create new ManageWorkers entry if it doesn't exist
            manage_worker = ManageWorkers.objects.create(worker=worker, created_at = timezone.now())

        today = timezone.now().date()

        work_types = WorkersType.objects.all() 
        total_count = 0
        for work_type in work_types:
            person_count = request.POST.get(f'worktype_{work_type.id}') or '0'
            
            # Check if person_count is provided and is a valid number
            if person_count:
                try:
                    total_count += int(person_count)  # Try to convert to int
                except ValueError:
                    messages.error(request, f"Invalid number for {work_type.name}")
                    return redirect('sa_manage_workers_create')
            else:
                person_count = 0  # If not provided, assume 0

            if person_count:  # Only proceed if there was a valid person_count
                existing_entry = WorkerWorkType.objects.filter(
                    Q(worker=manage_worker) &
                    Q(work_type=work_type) 
                ).first()

                if existing_entry:
                    existing_entry.person_count = int(person_count)
                    existing_entry.updated_at = timezone.now()
                    existing_entry.updated_by = user
                    existing_entry.save()
                else:
                    try:
                        WorkerWorkType.objects.create(
                            worker=manage_worker,
                            work_type=work_type,
                            person_count=int(person_count),
                            created_by=user,
                            created_at = timezone.now()
                        )
                    except Exception as e:
                        messages.error(request, f"Error creating work entry for {work_type.name}: {str(e)}")
                        return redirect('sa_manage_workers_create')

        # Update the ManageWorkers entry
        manage_worker.person = total_count
        manage_worker.status = 0  
        manage_worker.updated_by = user
        manage_worker.save()

        messages.success(request, 'Workers Availability Created Successfully!')
        return redirect('sa_manage_workers')
 
def export_manage_workers(request): 
    workers = ManageWorkers.objects.filter(Q(status=0) | Q(status=1))
    
    worker_id = request.GET.get('worker_id', None)
    # mobile_no = request.GET.get('mobile_no', None)
    work_type_id = request.GET.get('work_type_id', None)
    emp_type_id = request.GET.get('emp_type_id', None)
    state_id = request.GET.get('state_id', None)
    city_id = request.GET.get('city_id', None)
    taluk_id = request.GET.get('taluk_id', None)
    village_id = request.GET.get('village_id', None)
    # work_status = request.GET.get('work_status', None)

    # Apply filters based on the GET parameters
    if worker_id:
        workers = workers.filter(worker_id=worker_id)
    # if mobile_no:
    #     # usersss = ManageUser.objects.filter(mobile_no=mobile_no)
    #     workers = workers.filter(worker__mobile_no__icontains=mobile_no)
    if work_type_id:
        workers = workers.filter(workerstype__id=work_type_id)
    if emp_type_id:
        workers = workers.filter(worker__employee_type__id=emp_type_id)
    if state_id:
        workers = workers.filter(worker__state_id=state_id)
    if city_id:
        workers = workers.filter(worker__city_id=city_id)
    if taluk_id:
        workers = workers.filter(worker__taluk_id=taluk_id)
    if village_id:
        workers = workers.filter(worker__village_id=village_id)

    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename=manage_workers.csv'
 
    writer = csv.writer(response)
 
    writer.writerow([
        'Worker Name','Person Count', 'Status',
        'Mobile No', 'Village', 'Taluk', 'Employee Type',
        'Work Type', 'Person Count (Work Type)'
    ])
    
    for worker in workers: 
        worker_details = [
            worker.worker.name if worker.worker else '',
            # worker.workerstype.name if worker.workerstype else '',
            worker.person if worker.person else '',
            'Active' if worker.status == 0 else 'In Active',
            # worker.created_at,
            # worker.created_by.username if worker.created_by else '',
            # worker.updated_at,
            # worker.updated_by.username if worker.updated_by else '',
            worker.worker.mobile_no if worker.worker and worker.worker.mobile_no else '',
            worker.worker.village.name if worker.worker and worker.worker.village else '',
            worker.worker.taluk.name if worker.worker and worker.worker.taluk else '',
            worker.worker.employee_type.name if worker.worker and worker.worker.employee_type else '',
        ]
 
        writer.writerow(worker_details)
 
        work_types = WorkerWorkType.objects.filter(worker=worker)
        for work_type in work_types:
            writer.writerow([
                '',  # Empty space for Status (already written in worker_details)
                '',  # Empty space for Created At (already written in worker_details)
                # '',  # Empty space for Created By (already written in worker_details)
                '',  # Empty space for Updated At (already written in worker_details)
                # '',  # Empty space for Updated By (already written in worker_details)
                '',  # Empty space for Mobile No (already written in worker_details)
                '',  # Empty space for Village (already written in worker_details)
                '',  # Empty space for Taluk (already written in worker_details)
                '',  # Empty space for Employee Type (already written in worker_details)
                work_type.work_type.name if work_type.work_type else '',   
                work_type.person_count if work_type.person_count else ''   
            ])

    return response

#create
def get_worker_details(request, worker_id):
    try:
        # Retrieve the worker by ID or 404 if not found
        worker = get_object_or_404(ManageUser, id=worker_id)
        
        # Prepare the worker details in a dictionary
        data = {
            'mobile_no': worker.mobile_no,
            'village_name': worker.village.name if worker.village else '-',
            'taluk_name': worker.taluk.name if worker.taluk else '-',
            'employee_type_name': worker.employee_type.name if worker.employee_type else '-',
        }
        
        return JsonResponse(data)
    except ManageUser.DoesNotExist:
        return JsonResponse({'error': 'Worker not found'}, status=404)

#View
def get_workers_details(request, worker_id):
    try: 
        # worker = get_object_or_404(ManageUser, id=worker_id)
        # manage_worker = ManageUser.objects.get(id=worker_id)
        
        # Retrieve the actual worker (ManageUser) associated with this ManageWorkers entry
        # worker = manage_worker.worker

        manage_worker = ManageWorkers.objects.get(pk=worker_id)
        worker = manage_worker.worker
        work_typesss = WorkersType.objects.filter(status=0)
        worker_details = {
            'name': worker.name,
            'mobile_no': worker.mobile_no,
            'village_name': worker.village.name if worker.village else '-',
            'taluk_name': worker.taluk.name if worker.taluk else '-',
            'employee_type_name': worker.employee_type.name if worker.employee_type else '-',
            'count': manage_worker.person if manage_worker.person else 0,
        }
        
        worker_work_types = WorkerWorkType.objects.filter(worker=manage_worker,work_type__in=work_typesss)
        
        work_types = []
        for work_type in worker_work_types:
            work_types.append({
                'name': work_type.work_type.name,
                'person_count': work_type.person_count
            })
         
        worker_details['work_types'] = work_types
        
        return JsonResponse(worker_details)
    
    except ManageWorkers.DoesNotExist:
        return JsonResponse({'error': 'Worker not found'}, status=404)

# update
def get_workers_edit_details(request, worker_id):
    try: 
        worker = get_object_or_404(ManageUser, id=worker_id)
        worker_details = {
            'name': worker.name,
            'mobile_no': worker.mobile_no,
            'village_name': worker.village.name if worker.village else '-',
            'taluk_name': worker.taluk.name if worker.taluk else '-',
            'employee_type_name': worker.employee_type.name if worker.employee_type else '-',
        }
        return JsonResponse(worker_details)
    
    except ManageWorkers.DoesNotExist:
        return JsonResponse({'error': 'Worker not found'}, status=404)

class ManageWorkerUpdateView(LoginRequiredMixin, View):
    def get(self, request, worker_id):
        trigger_subscription()
        work_types = WorkersType.objects.filter(status=0)
        manage_worker = get_object_or_404(ManageWorkers, id=worker_id)
        users = ManageUser.objects.filter(usertype__code=1)  
        work_types_count = WorkerWorkType.objects.filter(worker=manage_worker,work_type__in=work_types)

        context = {
            'users': users,
            'work_types': work_types,
            'manage_worker': manage_worker,
            'work_types_count':work_types_count,
            'messages': messages.get_messages(request),
        }
        return render(request, 'pages/super_admin/workers_availability_provider/update_worker.html', context)
    
    def post(self, request, worker_id):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        manage_worker = ManageWorkers.objects.get(pk=worker_id)
        # worker_id = request.POST.get('worker')
        # usr = get_object_or_404(ManageUser, pk=worker_id)
        # manage_worker.worker = usr

        work_types = WorkerWorkType.objects.filter(worker=manage_worker) 
        total_count = 0
        for work_type in work_types:
            person_count = request.POST.get(f'worktype_{work_type.id}')
            total_count += int(person_count)
            if person_count:

                existing_entry = WorkerWorkType.objects.filter(
                    pk=work_type.id).first()

                if existing_entry:
                    existing_entry.person_count = int(person_count)
                    existing_entry.updated_at = timezone.now()
                    existing_entry.updated_by = user
                    existing_entry.save()
                    # messages.success(request, f"Updated work entry for {work_type.name} successfully!")
                else:
                    try:
                        WorkerWorkType.objects.create(
                            worker=manage_worker,
                            work_type=work_type,
                            person_count=int(person_count),
                            created_by = user
                        )
                        # messages.success(request, f"Created work entry for {work_type.name} successfully!")
                    except Exception as e:
                        messages.error(request, f"Error creating work entry for {work_type.name}: {str(e)}")
                        return redirect('sa_manage_workers_create')
        
        manage_worker.person=total_count
        manage_worker.updated_by = user
        manage_worker.save()
        messages.success(request, 'Worker work entries processed successfully!')
        return redirect('sa_manage_workers')
  
#------------------------------------------------------------------------------- Inventory Category & Item ------------------------------------------- 

def get_inv_catego_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = InventoryCategory.objects.get(pk=pk)
    except InventoryCategory.DoesNotExist:
        return JsonResponse({'error': 'Soil Type not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)
    
    return JsonResponse({
        'name': name,
        'description': description
    })

class InventoryCategoryView(LoginRequiredMixin, View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        
        # Check permissions for superuser and regular users
        if user.is_superuser:
            context = {
                'can_add_inventory_category': True,
                'can_edit_inventory_category': True,
                'can_view_inventory_category': True,
                'can_delete_inventory_category': True,
                'can_status_inventory_category': True,
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_inventory_category:
                return redirect('user_not_allowed')

        # Get the inventory_type_id from query parameters (if available)
        inventory_type_id = request.GET.get('inventory_type_id')

        # Filter categories based on the provided inventory_type_id
        inventory_categories = InventoryCategory.objects.filter(status__in=[0,1]).order_by('-id')

        if inventory_type_id:
            inventory_categories = inventory_categories.filter(inventory_type_id=inventory_type_id)


        # Get inventory types for the dropdown
        inventory_type = InventoryType.objects.filter(status=0)
        languages = Languages.objects.filter(status=0).order_by('id') 
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/inventory_category/list.html', {
            'languages': languages,
            'inventory_categories': inventory_categories,
            'can_add_inventory_category': manage_user.can_add_inventory_category if manage_user else False,
            'can_edit_inventory_category': manage_user.can_edit_inventory_category if manage_user else False,
            'can_view_inventory_category': manage_user.can_view_inventory_category if manage_user else False,
            'can_delete_inventory_category': manage_user.can_delete_inventory_category if manage_user else False,
            'can_status_inventory_category': manage_user.can_status_inventory_category if manage_user else False,
            'inventory_type': inventory_type,
        })

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            inventory_type_id = request.POST.get('inventory_type')
            description = request.POST.get('description')
            inventory_categories = InventoryCategory.objects.all()

            if not name:
                context = {
                    'inventory_categories': inventory_categories,
                    'error': 'Inventory Category Name is required.',
                    'inventory_type': InventoryType.objects.filter(status=0),  # ensure this is available for dropdown
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/inventory_category/list.html', context)

            if InventoryCategory.objects.filter(name=name, status__in=[0, 1]).exists():
                context = {
                    'inventory_categories': inventory_categories,
                    'error': f'Inventory Category "{name}" already exists.',
                    'inventory_type': InventoryType.objects.filter(status=0),  # ensure this is available for dropdown
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/inventory_category/list.html', context)

            if name and inventory_type_id:
                inventory_type = get_object_or_404(InventoryType, pk=inventory_type_id)
                InventoryCategory.objects.create(
                    name=name, description=description, inventory_type=inventory_type, status=0, created_by=user
                )
                messages.success(request, "Inventory Category created successfully.")
                return redirect('sa_inventory_category')

            messages.error(request, 'Name and Inventory Type are required.')
            return redirect('sa_inventory_category')

        elif action == 'update':
            pk = request.POST.get('id')
            inventory_category = get_object_or_404(InventoryCategory, pk=pk)
            translated_json = inventory_category.translate_json or {
                "name": {},
                "description": {}
            }
            name = request.POST.get('name')
            inventory_type_id = request.POST.get('inventory_type')
            description = request.POST.get('description')
            language = request.POST.get('language')

            if name and inventory_type_id:
                inventory_type = get_object_or_404(InventoryType, pk=inventory_type_id)
                # inventory_category.name = name
                # inventory_category.description = description
                inventory_category.inventory_type = inventory_type
                inventory_category.updated_by = user
                if language == "en":
                    if inventory_category.name != name:
                        inventory_category.name = name
                        try:
                            for lang in target_language:
                                translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                                translated_json["name"][lang] = translated_text
                        except Exception as e:
                            print(e)
                            print("Error in translating ")
                    if inventory_category.description != description:
                        inventory_category.description = description
                        try:
                            for lang in target_language:
                                translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                                translated_json["description"][lang] = translated_text
                        except Exception as e:
                            print(e)
                            print("Error in translating ")
                else:
                    translated_json["name"][language] = name
                    if description:
                        translated_json["description"][language] = description
                inventory_category.translate_json = translated_json
                inventory_category.save()
                messages.success(request, "Inventory Category updated successfully.")
                return redirect('sa_inventory_category')

        elif action == 'update_status':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                inventory_category = get_object_or_404(InventoryCategory, pk=pk)
                status = request.POST.get('status')

                if status == '0':
                    inventory_category.status = 0
                    inventory_category.updated_by = user
                    inventory_category.save()
                    messages.success(request, "Inventory Category has been activated.")
                elif status == '1':
                    inventory_category.status = 1
                    inventory_category.updated_by = user
                    inventory_category.save()
                    messages.success(request, "Inventory Category has been deactivated.")
                else:
                    messages.error(request, "Invalid status value.")

            return redirect('sa_inventory_category')

        elif action == 'delete':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                try:
                    inventory_category = get_object_or_404(InventoryCategory, pk=pk)
                    inventory_category.status = 2
                    inventory_category.updated_by = user
                    inventory_category.save()
                    messages.success(request, "Inventory Category has been Deleted successfully.")
                except InventoryCategory.DoesNotExist:
                    messages.error(request, "Inventory Category not found.")

            return redirect('sa_inventory_category')

        return redirect('sa_inventory_category')

def get_inv_item_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = InventoryItems.objects.get(pk=pk)
    except InventoryItems.DoesNotExist:
        return JsonResponse({'error': 'Soil Type not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)
    
    return JsonResponse({
        'name': name,
        'description': description
    })

class InventoryItemsView(LoginRequiredMixin, View):
    def get(self, request):
        trigger_subscription()

        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_inventory_items': True,
                'can_edit_inventory_items': True,
                'can_view_inventory_items': True,
                'can_delete_inventory_items': True,  
                'can_status_inventory_items': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_inventory_items:
                return redirect('user_not_allowed') 

        inventory_items = InventoryItems.objects.filter(
            Q(status=0) | Q(status=1)
        ).order_by('-id')
        inventory_categories = InventoryCategory.objects.filter(status=0)  # For dropdown options
        inventory_type = InventoryType.objects.filter(status=0)  
        languages = Languages.objects.filter(status=0).order_by('id') 
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/inventory_items/list.html', {
            'languages': languages,
            'inventory_items': inventory_items,
            'inventory_categories': inventory_categories,
            'inventory_types': inventory_type,
            'can_add_inventory_items': manage_user.can_add_inventory_items if manage_user else False,
            'can_edit_inventory_items': manage_user.can_edit_inventory_items if manage_user else False,
            'can_view_inventory_items': manage_user.can_view_inventory_items if manage_user else False,
            'can_delete_inventory_items': manage_user.can_delete_inventory_items if manage_user else False,
            'can_status_inventory_items': manage_user.can_status_inventory_items if manage_user else False,
        })

    def post(self, request):
        # Fetch the inventory types and categories
        inventory_types = InventoryType.objects.filter(status=0)
        inventory_categories = InventoryCategory.objects.filter(status=0)

        # Get the currently logged-in user
        user = request.user

        # Get the action type (e.g., 'create', 'update_status', 'delete', 'update')
        action = request.POST.get('action')

        if action == 'create':
            # Handle the creation of a new inventory item
            name = request.POST.get('name')
            inventory_category_id = request.POST.get('inventory_category')
            inventory_type_id = request.POST.get('inventory_type')
            description = request.POST.get('description')

            # Get the selected category and type from the IDs
            inventory_category = InventoryCategory.objects.get(id=inventory_category_id) if inventory_category_id else None
            selected_type = InventoryType.objects.get(id=inventory_type_id) if inventory_type_id else None

            # Validate required fields
            if not name or not inventory_category or not selected_type:
                return HttpResponse("Error: Missing required fields.", status=400)

            # Check if an inventory item with the same name already exists
            if InventoryItems.objects.filter(name=name, status__in=[0, 1]).exists():
                context = {
                    'error': f'Inventory Item "{name}" already exists.',
                    'inventory_categories': inventory_categories,
                    'inventory_types': inventory_types,
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/inventory_items/list.html', context)

            # Create the new inventory item
            InventoryItems.objects.create(
                name=name,
                inventory_type=selected_type,
                inventory_category=inventory_category,
                description=description,
                status=0,  # Assuming 0 means active
                created_by=user
            )
            messages.success(request, "Inventory Item created successfully.")
            return redirect('sa_inventory_items')

        elif action == 'update_status':
            # Handle the status update (e.g., activate or deactivate the item)
            pk = request.POST.get('id')
            status = request.POST.get('status')

            # Ensure the status and id are provided
            if not pk or status is None:
                messages.error(request, "ID and status are required.")
                return redirect('sa_inventory_items')

            # Retrieve the inventory item
            inventory_item = get_object_or_404(InventoryItems, pk=pk)

            # Update the status based on the provided status value
            if status == '0':
                inventory_item.status = 0  # Activate the item
                inventory_item.updated_by = user
                inventory_item.save()
                messages.success(request, "Inventory Item activated successfully.")
            elif status == '1':
                inventory_item.status = 1  # Deactivate the item
                inventory_item.updated_by = user
                inventory_item.save()
                messages.success(request, "Inventory Item deactivated.")
            else:
                messages.error(request, "Invalid status value.")

            return redirect('sa_inventory_items')

        elif action == 'delete':
            # Handle the deletion (soft delete) of the inventory item
            pk = request.POST.get('id')

            # Ensure the ID is provided
            if not pk:
                messages.error(request, "ID is required.")
                return redirect('sa_inventory_items')

            # Retrieve the inventory item
            inventory_item = get_object_or_404(InventoryItems, pk=pk)

            # Soft delete: Set the status to 2 (deleted)
            inventory_item.status = 2  # Assuming 2 means deleted
            inventory_item.updated_by = user
            inventory_item.save()

            messages.success(request, "Inventory Item deleted successfully.")
            return redirect('sa_inventory_items')

        elif action == 'update':
            # Handle updating the inventory item details
            inventory_item_id = request.POST.get('id')
            name = request.POST.get('name')
            inventory_category_id = request.POST.get('inventory_category')
            inventory_type_id = request.POST.get('inventory_type')
            description = request.POST.get('description')
            language = request.POST.get('language')
            # Retrieve the inventory item to be updated
            inventory_item = get_object_or_404(InventoryItems, id=inventory_item_id)
            translated_json = inventory_item.translate_json or {
                "name": {},
                "description": {}
            }

            # Get the inventory category and type based on their IDs
            inventory_category = get_object_or_404(InventoryCategory, id=inventory_category_id)
            inventory_type = get_object_or_404(InventoryType, id=inventory_type_id)

            # Validate required fields
            if not name or not inventory_category or not inventory_type:
                context = {
                    'error': 'Name, Inventory Type, and Inventory Category are required fields.',
                    'inventory_item': inventory_item,
                    'inventory_categories': InventoryCategory.objects.filter(status=0),
                    'inventory_types': InventoryType.objects.filter(status=0),
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/inventory_items/list.html', context)

            # Check if an inventory item with the same name already exists (excluding the current item)
            if InventoryItems.objects.filter(name=name, status__in=[0, 1]).exclude(id=inventory_item.id).exists():
                context = {
                    'error': f'Inventory Item "{name}" already exists.',
                    'inventory_item': inventory_item,
                    'inventory_categories': InventoryCategory.objects.filter(status=0),
                    'inventory_types': InventoryType.objects.filter(status=0),
                }
                return render(request, 'layout/partials/super_admin/layout/header/_menu/data/inventory_items/list.html', context)

            # Update the inventory item
            # inventory_item.name = name
            inventory_item.inventory_category = inventory_category
            inventory_item.inventory_type = inventory_type
            # inventory_item.description = description
            inventory_item.updated_by = user

            if language == "en":
                if inventory_item.name != name:
                    inventory_item.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translating ")
                if inventory_item.description != description:
                    inventory_item.description = description
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                            translated_json["description"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translating ")
            else:
                translated_json["name"][language] = name
                if description:
                    translated_json["description"][language] = description
            
            inventory_item.translate_json = translated_json
            inventory_item.save()

            # Success message
            messages.success(request, "Inventory Item updated successfully.")
            return redirect('sa_inventory_items')

        # If no recognized action, render the form again
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/inventory_items/list.html', {
            'inventory_types': inventory_types,
            'inventory_categories': inventory_categories,
        })
 
def filter_categories(request, inventory_type_id): 
    inventory_type = get_object_or_404(InventoryType, id=inventory_type_id)
 
    categories = InventoryCategory.objects.filter(inventory_type=inventory_type, status=0)  # Assuming 'status=0' means active categories
 
    categories_data = [{"id": category.id, "name": category.name} for category in categories]
 
    return JsonResponse({"categories": categories_data})

# ------------------------------------------------------------------------- Report ----------------------------------------------------

class FarmersRegistrationReportView(LoginRequiredMixin,View):
    def get(self, request, *args, **kwargs):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_export_farmer_report': True,
                'can_view_farmer_report': True,
                'can_filter_farmer_report': True,
                'can_view_unique_report': True,  
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_farmer_report:
                return redirect('user_not_allowed') 
            
        search_query = request.GET.get('search', '')
        farmertype = request.GET.get('farmertype', '')
        farmer_id = request.GET.get('farmer', '')
        phone = request.GET.get('phone', '')
        email = request.GET.get('email', '')
        city_id = request.GET.get('city', '')
        state_id = request.GET.get('state', '')
        taluk_id = request.GET.get('taluk', '')
        village_id = request.GET.get('village', '')
        package_id = request.GET.get('package', '')
        date_filter = request.GET.get('date_filter', 'all')
        custom_date_from = request.GET.get('custom_date_from', '')
        custom_date_to = request.GET.get('custom_date_to', '')

        # Initialize the base queryset for farmers
        farmers = Farmer.objects.filter(
            Q(status=0) | Q(status=4) | Q(status=6),
            Q(name__icontains=search_query) | Q(description__icontains=search_query)
        ).order_by('-id')
        # print("fm",farmers)
        # Apply filters
        if farmertype:
            farmers = farmers.filter(farmertype_id=farmertype)

        if farmer_id:
            farmers = farmers.filter(id=farmer_id)

        if phone:
            farmers = farmers.filter(phone__icontains=phone)

        if email:
            farmers = farmers.filter(email__icontains=email)

        if city_id:
            farmers = farmers.filter(city_id=city_id)

        if state_id:
            farmers = farmers.filter(city__state_id=state_id)  # Assuming state is a field in the City model

        if taluk_id:
            farmers = farmers.filter(taluk_id=taluk_id)

        if village_id:
            farmers = farmers.filter(village_id=village_id)

        if package_id:
            package = get_object_or_404(PackageManagement, id=package_id)
            farmers = farmers.filter(subscription_package=package)

        # Date filter handling
        custom_to_date = None
        today_date = datetime.today().date()
        if date_filter == 'today':
            farmers = farmers.filter(created_at__date=today_date)
        elif date_filter == 'week':
            start_of_week = today_date - timedelta(days=today_date.weekday())  # Monday
            farmers = farmers.filter(created_at__date__range=[start_of_week, today_date])
        elif date_filter == 'monthly':
            farmers = farmers.filter(created_at__year=today_date.year, created_at__month=today_date.month)
        elif date_filter == 'custom_date':
            if custom_date_from and custom_date_to:
                # Convert the date format from DD-MM-YYYY to YYYY-MM-DD
                custom_from_date = datetime.strptime(custom_date_from, '%d-%m-%Y').date()
                custom_to_date = datetime.strptime(custom_date_to, '%d-%m-%Y').date()
                farmers = farmers.filter(created_at__date__range=[custom_from_date, custom_to_date])

        # Pagination setup
        show_per_page = request.GET.get('show', 25)
        show_per_page = int(show_per_page)

        # Pagination setup
        paginator = Paginator(farmers, show_per_page)
        page_number = request.GET.get('page')
        page_obj = paginator.get_page(page_number)

        # Prepare data for the report
        entries_count = 0
        farmer_reports = []
        for farmer in page_obj:
            entries_count += 1
            subscription = farmer.active_subscription  # Assuming `active_subscription` is a related field
            subscription_details = None
            
            if subscription:
                # Extract subscription details
                package_name = subscription.packages.name if subscription.packages else '-'
                package_duration = subscription.packages.package_duration.name if subscription.packages and subscription.packages.package_duration else '-'
                package_validity = subscription.packages.package_validity if subscription.packages else '-'
                start_date = subscription.startdate
                end_date = subscription.enddate
                remaining_days = subscription.remainingdays
                # add_on_details = [add_on.name for add_on in subscription.packages.add_on_details.all()] if subscription.packages else []

                # Prepare subscription details dictionary
                subscription_details = {
                    'package_name': package_name,
                    'package_duration': package_duration,
                    'package_validity': package_validity,
                    'start_date': start_date,
                    'end_date': end_date,
                    'remaining_days': remaining_days,
                    # 'add_on_details': add_on_details
                }

            # Prepare the farmer report
            farmer_report = {
                'farmer_id': farmer.id,
                'farmer_name': farmer.name,
                'farmer_type': farmer.farmertype.name if farmer.farmertype else '-',
                'farmer_city': farmer.city.name if farmer.city else '-',
                'farmer_village': farmer.village.name if farmer.village else '-',
                'farmer_taluk': farmer.taluk.name if farmer.taluk else '-',
                'email': farmer.email,
                'phone': farmer.phone,
                'created_at': farmer.created_at,
                'subscription_details': subscription_details,
                'farmer_image': farmer.img.url if farmer.img else None,
            }

            farmer_reports.append(farmer_report)

        # Fetch data for the filters (such as farm types, cities, etc.)
        farmertype_choices = FarmerType.objects.all()
        cities = City.objects.all()
        states = State.objects.all()  # Assuming you have a State model
        taluks = Taluk.objects.all()
        villages = Village.objects.all()
        packages = PackageManagement.objects.all()  # Assuming you have a Package model

        # Count of farmers
        farmer_count = Farmer.objects.filter(status__in=[0,1,3,4,5,6]).count()
        active_farmer_count = Farmer.objects.filter(status=0).count()
        all_farmers = Farmer.objects.filter(Q(status=0))
        
        # Render the page with pagination and search results
        return render(request, 'pages/super_admin/reports/farmers_registration/list.html', {
            'farmer_reports': farmer_reports,
            'farmers' : page_obj,
            'entries_count': entries_count,
            'show_per_page': show_per_page,
            'all_farmers' : all_farmers,
            'search_query': request.GET.get('search', ''),
            'farmer_count': farmer_count,
            'active_farmer_count': active_farmer_count,
            'farmertype_choices': farmertype_choices,
            'cities': cities,
            'states': states,  # Add states to the context
            'taluks': taluks,
            'villages': villages,
            'packages': packages,  # Add packages to the context
            'selected_farmertype': farmertype if farmertype else "",
            'selected_farmer_id': farmer_id if farmer_id else "",
            'selected_phone': phone if phone else "",
            'selected_email': email if email else "",
            'selected_city_id': city_id if city_id else "",
            'selected_state_id': state_id if state_id else "",  # Add state_id to the context
            'selected_taluk_id': taluk_id if taluk_id else "",  # Add taluk_id to the context
            'selected_village_id': village_id if village_id else "",  # Add village_id to the context
            'selected_package_id': package_id if package_id else "",  # Add package_id to the context
            'selected_date_filter': date_filter,
            'selected_custom_date_from': custom_date_from if custom_date_from else '',
            'selected_custom_date_to': custom_to_date if custom_to_date else '', 
            'can_export_farmer_report': manage_user.can_export_farmer_report if manage_user else False,
            'can_view_farmer_report': manage_user.can_view_farmer_report if manage_user else False,
            'can_filter_farmer_report': manage_user.can_filter_farmer_report if manage_user else False,
            'can_view_unique_report': manage_user.can_view_unique_report if manage_user else False,
        })

def farmer_report_details(request, farmer_id):
    try:
        # Fetch the farmer object
        farmer = Farmer.objects.get(id=farmer_id)
        
        # Fetch the subscription details for the farmer
        subscription = AddSubcription.objects.filter(farmers_id=farmer.id, status=0).first()
        
        if not subscription:
            # If no subscription with status=0, fetch the most recent one (by updated_at or created_at)
            subscription = AddSubcription.objects.filter(farmers_id=farmer.id).order_by('-updated_at').first()


        
        # Get subscription details if available, otherwise provide defaults
        subscription_data = {}
        if subscription:
            # Fetch the package details and add-ons
            package = subscription.packages  # Assuming the package is related to the subscription

            subscription_data = {
                'subscription_package': package.name if package else 'Unknown', 
                'subscription_amount': subscription.amount,
                'subscription_sub_amount': subscription.sub_amount,  # Assuming subscription amount and sub amount are different
                'subscription_duration': f"{subscription.packages.package_duration.name} " if subscription.packages else 'Unknown',
                'subscription_validity': subscription.packages.package_validity if subscription.packages else 'Unknown',
                'subscription_start_date': subscription.startdate.strftime('%d-%m-%Y') if subscription.startdate else 'Unknown',
                'subscription_end_date': subscription.enddate.strftime('%d-%m-%Y') if subscription.enddate else 'Unknown',
                'remaining_days': f"{subscription.remainingdays} Days " if subscription.remainingdays else 0,
                # 'add_on_details': add_on_details
            }
        else:
            # Default values if no subscription exists
            subscription_data = {
                'subscription_package': '-',
                'subscription_amount': '-',
                'subscription_sub_amount': '-',
                'subscription_duration': '-',
                'subscription_validity': '-',
                'subscription_start_date': '-',
                'subscription_end_date': '-',
                'remaining_days': '-',
                # 'add_on_details': []
            }

 
        # print(subscription_data)
        # Prepare the farmer data with subscription details and farmer count
        farmer_data = {
            'farmer_name': farmer.name,
            'farmer_type': farmer.farmertype.name if farmer.farmertype else 'Unknown',
            'farmer_phone': farmer.phone,
            'farmer_email': farmer.email,
            'farmer_description': farmer.description,
            'farmer_created_at': farmer.created_at.strftime('%d-%m-%Y'),
            'farmer_city': farmer.city.name if farmer.city else 'Unknown',
            'farmer_taluk': farmer.taluk.name if farmer.taluk else 'Unknown',
            'farmer_village': farmer.village.name if farmer.village else 'Unknown',
            'farmer_image_url': farmer.img.url if farmer.img else '',
            
            # Subscription details
            'subscription_package': subscription_data['subscription_package'],
            'subscription_amount': subscription_data['subscription_amount'],
            'subscription_sub_amount': subscription_data['subscription_sub_amount'],
            'subscription_duration': subscription_data['subscription_duration'],
            'subscription_validity': subscription_data['subscription_validity'],
            'subscription_start_date': subscription_data['subscription_start_date'],
            'subscription_end_date': subscription_data['subscription_end_date'],
            'remaining_days': subscription_data['remaining_days'],
            # 'add_on_details': subscription_data['add_on_details'],
           
        }
        
        # Return the farmer data with subscription details as JSON
        return JsonResponse(farmer_data)
    
    except Farmer.DoesNotExist:
        return JsonResponse({'error': 'Farmer not found'}, status=404)

class PackageRevenueReportView(LoginRequiredMixin,View):
    def get(self, request, *args, **kwargs):
        trigger_subscription()
        # Get filter parameters
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_export_subscription_report': True,
                'can_view_subscription_report': True,
                'can_filter_subscription_report': True,
                'can_view_unique_subscription_report': True,  
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_subscription_report:
                return redirect('user_not_allowed') 
            
        package_id = request.GET.get('package', '')
        date_filter = request.GET.get('dt_fill_issue_rpt', 'all')
        custom_start_date = request.GET.get('custom_start_date', '')
        custom_end_date = request.GET.get('custom_end_date', '')
        month = request.GET.get('month', '')
        view_today_date = ''
        start_of_week = ''
        end_of_week = ''
        if month:
            try:
                # Try parsing the 'MM-YYYY' format (e.g., '11-2024')
                # print('Trying MM-YYYY format')
                month, year = map(int, month.split('-'))
                start_of_month = timezone.datetime(year, month, 1).date()
            except ValueError:
                try:
                    # Try parsing the 'MMM-YYYY' format (e.g., 'Dec-2024')
                    # print('Trying MMM-YYYY format')
                    month_name, year = month.split('-')
                    month = datetime.strptime(month_name, '%b').month  # Convert month name to month number
                    start_of_month = timezone.datetime(int(year), month, 1).date()
                except ValueError:
                    # Handle the case where the input is neither a valid 'MM-YYYY' nor 'MMM-YYYY'
                    start_of_month = ''
                    end_of_month = ''
                    # print('Invalid month format')
            # After we successfully get the start date, calculate the end date
            last_day_of_month = calendar.monthrange(start_of_month.year, start_of_month.month)[1]
            end_of_month = timezone.datetime(start_of_month.year, start_of_month.month, last_day_of_month, 23, 59, 59).date()

        else:
            start_of_month = ''
            end_of_month = ''

        # Initialize the queryset for subscription reports
        subscription_reports = SubscriptionReport.objects.all()
        sub = AddSubcription.objects.all()
        # Apply package filter if specified
        if package_id:
            subscription_reports = subscription_reports.filter(package_id=package_id)
            sub = sub.filter(packages_id=package_id)

        # Handle the date filter logic
        if date_filter == 'today':
            today = timezone.now().date()
            view_today_date = today
            # subscription_reports = subscription_reports.filter(created_at__date=today)
            sub = sub.filter(created_at__date=today)
        elif date_filter == 'week':
            today = timezone.now().date()
            start_of_week = today - timedelta(days=today.weekday())  # Monday
            end_of_week = start_of_week + timedelta(days=6)  # Sunday

            sub = sub.filter(
                created_at__date__gte=start_of_week,
                created_at__date__lte=end_of_week
            )
        elif date_filter == 'monthly':
            sub = sub.filter(
                created_at__date__gte=start_of_month,
                created_at__date__lte=end_of_month
            )
        elif date_filter == 'custom_date' and custom_start_date and custom_end_date:
            try:
                start_date = timezone.datetime.strptime(custom_start_date, '%d-%m-%Y').date()  # Updated format
                end_date = timezone.datetime.strptime(custom_end_date, '%d-%m-%Y').date()  # Updated format
                # subscription_reports = subscription_reports.filter(
                #     created_at__date__gte=start_date,
                #     created_at__date__lte=end_date
                # )
                sub = sub.filter(
                    created_at__date__gte=start_date,
                    created_at__date__lte=end_date
                )
            except ValueError:
                pass 
                
        # Prepare data for the subscription report table
        # for s in sub:
        #     print("name:",s.farmers.name)
        #     print("pack:",s.packages.name)
        #     print("end:",s.enddate)
        subscription_data = []
        all_rev = 0
        for report in subscription_reports:
            package = report.package
            package_name = package.name if package else '-'
            package_duration = package.package_duration.name if package and package.package_duration else '-'
            package_validity = package.package_validity if package else '-'
            package_sub_amount = package.sub_amount if package else '-'
            rev = package_sub_amount * (sub.filter(packages=package).count())
            report_data = {
                'id' : package.id,
                'package_name': package_name, 
                'package_duration': f'{package_duration}' if package_duration else '-',
                'package_validity': package_validity,
                'package_sub_amount': package_sub_amount,
                'total_sub' : sub.filter(packages=package).count(),
                'farmers_count': sub.filter(packages=package,status=0).count(),
                'total_renewal' :sub.filter(packages=package,renewal=True).count(),
                'total_revenue': rev,
                # 'month': report.month,
                # 'year': report.year,
            }
            subscription_data.append(report_data)
            all_rev += rev
        # print("sub rep:",subscription_data)
        # Fetch all packages for the filter dropdown
        packages = PackageManagement.objects.all()

        # Generate graph data for monthly revenue for the selected year
        # graph_data = self.get_monthly_revenue_for_year(year)

        # Render the page with pagination and filter results
        return render(request, 'pages/super_admin/reports/package_revenue/list.html', {
            'subscription_data': subscription_data,
            'packages': packages,
            'package_id': package_id if package_id else "",
            'month': month,
            'date_filter': date_filter,
            'today' : view_today_date,
            'start_of_week' : start_of_week,
            'end_of_week' : end_of_week,
            'custom_start_date': custom_start_date,
            'custom_end_date': custom_end_date,
            'start_of_month' : start_of_month,
            'end_of_month' : end_of_month,
            'all_rev' : all_rev, 
            'can_export_subscription_report': manage_user.can_export_subscription_report if manage_user else False,
            'can_view_subscription_report': manage_user.can_view_subscription_report if manage_user else False,
            'can_filter_subscription_report': manage_user.can_filter_subscription_report if manage_user else False,
            'can_view_unique_subscription_report': manage_user.can_view_unique_subscription_report if manage_user else False,
            # 'graph_data': json.dumps(graph_data)  # Pass graph data as JSON
        })

class PackageRevenueView(LoginRequiredMixin,View):
    def get(self, request, package_id):
        trigger_subscription()
        # Fetch package details
        package = PackageManagement.objects.get(id=package_id)
        farmers = AddSubcription.objects.filter(packages=package)
        context = {
            'package': package,
            'farmers' : farmers,
        }
        return render(request, 'pages/super_admin/reports/package_revenue/view.html',context)

def subscription_report_data(request, year):
    monthly_revenues = [0] * 12  # Array for 12 months
    c=0
    for i in range(1,13):
        sub = AddSubcription.objects.filter(
            created_at__year=year,  # Filter by current year
            created_at__month=i  # Filter by current month
        )
        sums = 0
        for s in sub:
            sums += s.package_subamount
            monthly_revenues[c] = sums
        c+=1

    return JsonResponse({'monthly_revenues': monthly_revenues})
 
def export_farmer_report(request):
    city_id = request.GET.get('city', '')
    state_id = request.GET.get('state', '')
    taluk_id = request.GET.get('taluk', '')
    village_id = request.GET.get('village', '')
    package_id = request.GET.get('package', '')
    date_filter = request.GET.get('date_filter', 'all')
    custom_date_from = request.GET.get('custom_date_from', '')
    custom_date_to = request.GET.get('custom_date_to', '')

    farmers = Farmer.objects.filter(
        Q(status=0) | Q(status=4) | Q(status=6)
    ).order_by('-id')
    
    # Apply filters
    if city_id:
        farmers = farmers.filter(city_id=city_id)

    if state_id:
        farmers = farmers.filter(city__state_id=state_id)  # Assuming state is a field in the City model

    if taluk_id:
        farmers = farmers.filter(taluk_id=taluk_id)

    if village_id:
        farmers = farmers.filter(village_id=village_id)

    if package_id:
        package = get_object_or_404(PackageManagement, id=package_id)
        farmers = farmers.filter(subscription_package=package)

    # Date filter handling
    custom_to_date = None
    today_date = datetime.today().date()
    if date_filter == 'today':
        farmers = farmers.filter(created_at__date=today_date)
    elif date_filter == 'week':
        start_of_week = today_date - timedelta(days=today_date.weekday())  # Monday
        farmers = farmers.filter(created_at__date__range=[start_of_week, today_date])
    elif date_filter == 'monthly':
        farmers = farmers.filter(created_at__year=today_date.year, created_at__month=today_date.month)
    elif date_filter == 'custom_date':
        if custom_date_from and custom_date_to:
            # Convert the date format from DD-MM-YYYY to YYYY-MM-DD
            custom_from_date = datetime.strptime(custom_date_from, '%d-%m-%Y').date()
            custom_to_date = datetime.strptime(custom_date_to, '%d-%m-%Y').date()
            farmers = farmers.filter(created_at__date__range=[custom_from_date, custom_to_date])


    # Create a CSV response
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="farmer_report.csv"'

    writer = csv.writer(response)
    # Write the header row
    writer.writerow([
        'Farmers', 'Phone Number', 'Email', 'Packages', 'Start Date', 'End Date', 'Remaining Days', 'Status'
    ])

    # Write the worker data
    for far in farmers:
        writer.writerow([
            far.name,
            far.phone if far.phone else '-',
            far.email if far.email else '-',
            far.subscription_package if far.subscription_package else '-',
            far.subscription_start_date if far.subscription_start_date else '-',
            far.subscription_end_date if far.subscription_end_date else '-',
            far.remaining_days if far.remaining_days else '0',
            'Active' if far.status == 0 else "In Active"
        ])

    return response


# --------------------------------------------------------------------- User Management ----------------------------------------------------
# ---------------------- User Role -------------------------

class ManageUserRoleView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user_role = None
        if user.is_superuser:
            context = { 
                'can_view_manage_user_role': True, 
                'can_add_manage_user_role': True,  
                'can_edit_manage_user_role': True,
                'can_delete_manage_user_role': True,
                'can_status_manage_user_role': True, 
                'can_view_unique_manage_user_role': True, 
            }
        else:
            try:
                manage_user_role = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user_role = None
                return redirect('sa_login')

            if manage_user_role and not manage_user_role.can_view_manage_user_role:
                return redirect('user_not_allowed') 


        user_roles = ManageUserRole.objects.filter(Q(status=0) | Q(status=1)).order_by('-id')
        context = {
            'userRoles': user_roles,
            'can_view_manage_user_role': manage_user_role.can_view_manage_user_role if manage_user_role else False,
            'can_add_manage_user_role': manage_user_role.can_add_manage_user_role if manage_user_role else False,
            'can_edit_manage_user_role': manage_user_role.can_edit_manage_user_role if manage_user_role else False,
            'can_delete_manage_user_role': manage_user_role.can_delete_manage_user_role if manage_user_role else False,
            'can_status_manage_user_role': manage_user_role.can_status_manage_user_role if manage_user_role else False,
            'can_view_unique_manage_user_role': manage_user_role.can_view_unique_manage_user_role if manage_user_role else False,
        }
        return render(request, 'pages/super_admin/users_management/manage_role/list.html', context)
    
    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                users = get_object_or_404(ManageUserRole, pk=pk) 
                status = request.POST.get('status') 

                if status == '0':
                    users.status = 0   
                    users.updated_by = user
                    users.save()
                    messages.success(request, "User Role has been activated.") 
                elif status == '1':
                    users.status = 1  
                    users.updated_by = user
                    users.save()
                    messages.success(request, "User Role has been deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_manage_role')
        
        elif action == 'delete':
            pk = request.POST.get('id')
            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    users = get_object_or_404(ManageUserRole, pk=pk)   
                    users.status = 2  
                    users.updated_by = user
                    users.save()
                    messages.success(request, "User Role has been deactivated successfully.")  
                except Detection.DoesNotExist:
                    messages.error(request, "User Role not found.")  

            return redirect('sa_manage_role') 

        elif action == 'update':
            # Get the user role to update
            pk = request.POST.get('id')
            user_role = get_object_or_404(ManageUserRole, pk=pk)  # Get the user role using its ID

            # Get role name from form data
            name = request.POST.get('role_name')
            user_role.name = name

            # Get the map_role (associated role) from form
            role_id = request.POST.get('map_role')
            if role_id == '0':  # If role_id is 0, set map_role to None
                user_role.map_role = None
            else:
                # Otherwise, fetch the Role object
                role = get_object_or_404(Role, id=role_id)
                user_role.map_role = role

            # Define permissions for different pages
            permissions_by_page = {
                'Settings':[
                    {'id': 1, 'name': 'List', 'permission': 'can_view_general_setting'},
                    {'id': 2, 'name': 'Edit', 'permission': 'can_edit_general_setting'},

                    {'id': 3, 'name': 'Add', 'permission': 'can_add_country'},
                    {'id': 4, 'name': 'Edit', 'permission': 'can_edit_country'},
                    {'id': 5, 'name': 'View', 'permission': 'can_view_country'},
                    {'id': 6, 'name': 'Delete', 'permission': 'can_delete_country'},
                    {'id': 7, 'name': 'Status', 'permission': 'can_status_country'},

                    {'id': 8, 'name': 'Add', 'permission': 'can_add_state'},
                    {'id': 9, 'name': 'Edit', 'permission': 'can_edit_state'},
                    {'id': 10, 'name': 'View', 'permission': 'can_view_state'},
                    {'id': 11, 'name': 'Delete', 'permission': 'can_delete_state'},
                    {'id': 12, 'name': 'Status', 'permission': 'can_status_state'},

                    {'id': 13, 'name': 'Add', 'permission': 'can_add_city'},
                    {'id': 14, 'name': 'Edit', 'permission': 'can_edit_city'},
                    {'id': 15, 'name': 'View', 'permission': 'can_view_city'},
                    {'id': 16, 'name': 'Delete', 'permission': 'can_delete_city'},
                    {'id': 17, 'name': 'Status', 'permission': 'can_status_city'},

                    {'id': 18, 'name': 'Add', 'permission': 'can_add_taluk'},
                    {'id': 19, 'name': 'Edit', 'permission': 'can_edit_taluk'},
                    {'id': 20, 'name': 'View', 'permission': 'can_view_taluk'},
                    {'id': 21, 'name': 'Delete', 'permission': 'can_delete_taluk'},
                    {'id': 22, 'name': 'Status', 'permission': 'can_status_taluk'},

                    {'id': 23, 'name': 'Add', 'permission': 'can_add_village'},
                    {'id': 24, 'name': 'Edit', 'permission': 'can_edit_village'},
                    {'id': 25, 'name': 'View', 'permission': 'can_view_village'},
                    {'id': 26, 'name': 'Delete', 'permission': 'can_delete_village'},
                    {'id': 27, 'name': 'Status', 'permission': 'can_status_village'},
                
                ],

                'Data Management':[

                    {'id': 28, 'name': 'Add', 'permission': 'can_add_land_unit'},
                    {'id': 29, 'name': 'Edit', 'permission': 'can_edit_land_unit'},
                    {'id': 30, 'name': 'View', 'permission': 'can_view_land_unit'},
                    {'id': 31, 'name': 'Delete', 'permission': 'can_delete_land_unit'},
                    {'id': 32, 'name': 'Status', 'permission': 'can_status_land_unit'},
                
                    {'id': 33, 'name': 'Add', 'permission': 'can_add_area_unit'},
                    {'id': 34, 'name': 'Edit', 'permission': 'can_edit_area_unit'},
                    {'id': 35, 'name': 'View', 'permission': 'can_view_area_unit'},
                    {'id': 36, 'name': 'Delete', 'permission': 'can_delete_area_unit'},
                    {'id': 37, 'name': 'Status', 'permission': 'can_status_area_unit'},
                

                    {'id': 38, 'name': 'Add', 'permission': 'can_add_soil_type'},
                    {'id': 39, 'name': 'Edit', 'permission': 'can_edit_soil_type'},
                    {'id': 40, 'name': 'View', 'permission': 'can_view_soil_type'},
                    {'id': 41, 'name': 'Delete', 'permission': 'can_delete_soil_type'},
                    {'id': 42, 'name': 'Status', 'permission': 'can_status_soil_type'},
                

                    {'id': 43, 'name': 'Add', 'permission': 'can_add_crop_type'},
                    {'id': 44, 'name': 'Edit', 'permission': 'can_edit_crop_type'},
                    {'id': 45, 'name': 'View', 'permission': 'can_view_crop_type'},
                    {'id': 46, 'name': 'Delete', 'permission': 'can_delete_crop_type'},
                    {'id': 47, 'name': 'Status', 'permission': 'can_status_crop_type'},
                

                    {'id': 48, 'name': 'Add', 'permission': 'can_add_quality'},
                    {'id': 49, 'name': 'Edit', 'permission': 'can_edit_quality'},
                    {'id': 50, 'name': 'View', 'permission': 'can_view_quality'},
                    {'id': 51, 'name': 'Delete', 'permission': 'can_delete_quality'},
                    {'id': 52, 'name': 'Status', 'permission': 'can_status_quality'},
                

                    {'id': 53, 'name': 'Add', 'permission': 'can_add_crop'},
                    {'id': 54, 'name': 'Edit', 'permission': 'can_edit_crop'},
                    {'id': 55, 'name': 'View', 'permission': 'can_view_crop'},
                    {'id': 56, 'name': 'Delete', 'permission': 'can_delete_crop'},
                    {'id': 57, 'name': 'Status', 'permission': 'can_status_crop'},
                

                    {'id': 58, 'name': 'Add', 'permission': 'can_add_product_type'},
                    {'id': 59, 'name': 'Edit', 'permission': 'can_edit_product_type'},
                    {'id': 60, 'name': 'View', 'permission': 'can_view_product_type'},
                    {'id': 61, 'name': 'Delete', 'permission': 'can_delete_product_type'},
                    {'id': 62, 'name': 'Status', 'permission': 'can_status_product_type'},
                

                    {'id': 63, 'name': 'Add', 'permission': 'can_add_vehicle_category'},
                    {'id': 64, 'name': 'Edit', 'permission': 'can_edit_vehicle_category'},
                    {'id': 65, 'name': 'View', 'permission': 'can_view_vehicle_category'},
                    {'id': 66, 'name': 'Delete', 'permission': 'can_delete_vehicle_category'},
                    {'id': 67, 'name': 'Status', 'permission': 'can_status_vehicle_category'},
                

                    {'id': 68, 'name': 'Add', 'permission': 'can_add_manage_vehicle'},
                    {'id': 69, 'name': 'Edit', 'permission': 'can_edit_manage_vehicle'},
                    {'id': 70, 'name': 'View', 'permission': 'can_view_manage_vehicle'},
                    {'id': 71, 'name': 'Delete', 'permission': 'can_delete_manage_vehicle'},
                    {'id': 72, 'name': 'Status', 'permission': 'can_status_manage_vehicle'},
                

                    {'id': 73, 'name': 'Add', 'permission': 'can_add_machinery_category'},
                    {'id': 74, 'name': 'Edit', 'permission': 'can_edit_machinery_category'},
                    {'id': 75, 'name': 'View', 'permission': 'can_view_machinery_category'},
                    {'id': 76, 'name': 'Delete', 'permission': 'can_delete_machinery_category'},
                    {'id': 77, 'name': 'Status', 'permission': 'can_status_machinery_category'},
                

                    {'id': 78, 'name': 'Add', 'permission': 'can_add_manage_machinery'},
                    {'id': 79, 'name': 'Edit', 'permission': 'can_edit_manage_machinery'},
                    {'id': 80, 'name': 'View', 'permission': 'can_view_manage_machinery'},
                    {'id': 81, 'name': 'Delete', 'permission': 'can_delete_manage_machinery'},
                    {'id': 82, 'name': 'Status', 'permission': 'can_status_manage_machinery'},
                

                    {'id': 83, 'name': 'Add', 'permission': 'can_add_tool_category'},
                    {'id': 84, 'name': 'Edit', 'permission': 'can_edit_tool_category'},
                    {'id': 85, 'name': 'View', 'permission': 'can_view_tool_category'},
                    {'id': 86, 'name': 'Delete', 'permission': 'can_delete_tool_category'},
                    {'id': 87, 'name': 'Status', 'permission': 'can_status_tool_category'},
                

                    {'id': 88, 'name': 'Add', 'permission': 'can_add_tool'},
                    {'id': 89, 'name': 'Edit', 'permission': 'can_edit_tool'},
                    {'id': 90, 'name': 'View', 'permission': 'can_view_tool'},
                    {'id': 91, 'name': 'Delete', 'permission': 'can_delete_tool'},
                    {'id': 92, 'name': 'Status', 'permission': 'can_status_tool'},
                

                    {'id': 93, 'name': 'Add', 'permission': 'can_add_expense_category'},
                    {'id': 94, 'name': 'Edit', 'permission': 'can_edit_expense_category'},
                    {'id': 95, 'name': 'View', 'permission': 'can_view_expense_category'},
                    {'id': 96, 'name': 'Delete', 'permission': 'can_delete_expense_category'},
                    {'id': 97, 'name': 'Status', 'permission': 'can_status_expense_category'},
                

                    {'id': 98, 'name': 'Add', 'permission': 'can_add_expense'},
                    {'id': 99, 'name': 'Edit', 'permission': 'can_edit_expense'},
                    {'id': 100, 'name': 'View', 'permission': 'can_view_expense'},
                    {'id': 101, 'name': 'Delete', 'permission': 'can_delete_expense'},
                    {'id': 102, 'name': 'Status', 'permission': 'can_status_expense'},
                

                    {'id': 103, 'name': 'Add', 'permission': 'can_add_harvesting_type'},
                    {'id': 104, 'name': 'Edit', 'permission': 'can_edit_harvesting_type'},
                    {'id': 105, 'name': 'View', 'permission': 'can_view_harvesting_type'},
                    {'id': 106, 'name': 'Delete', 'permission': 'can_delete_harvesting_type'},
                    {'id': 107, 'name': 'Status', 'permission': 'can_status_harvesting_type'},
                

                    {'id': 108, 'name': 'Add', 'permission': 'can_add_detection'},
                    {'id': 109, 'name': 'Edit', 'permission': 'can_edit_detection'},
                    {'id': 110, 'name': 'View', 'permission': 'can_view_detection'},
                    {'id': 111, 'name': 'Delete', 'permission': 'can_delete_detection'},
                    {'id': 112, 'name': 'Status', 'permission': 'can_status_detection'},
                

                ],

                'Farmer': [
                    {'id': 113, 'name': 'List', 'permission': 'can_view_farmer'},
                    {'id': 114, 'name': 'Add', 'permission': 'can_add_farmer'},
                    {'id': 115, 'name': 'Edit', 'permission': 'can_edit_farmer'},
                    {'id': 116, 'name': 'Delete', 'permission': 'can_delete_farmer'},
                    {'id': 117, 'name': 'View', 'permission': 'can_view_unique_farmer'},
                    {'id': 118, 'name': 'Export', 'permission': 'can_export_farmer_data'},
                    {'id': 119, 'name': 'Filter', 'permission': 'can_filter_farmer_data'},
                    {'id': 120, 'name': 'Status', 'permission': 'can_update_farmer_status'},
                    {'id': 270, 'name': 'Subscribe', 'permission': 'can_subscribe_farmer_package'},
                    {'id': 271, 'name': 'Subscribe', 'permission': 'can_unsubscribe_farmer_package'},
                ],

                'Package': [
                    {'id': 121, 'name': 'List', 'permission': 'can_view_package'},
                    {'id': 122, 'name': 'Add', 'permission': 'can_add_package'},
                    {'id': 123, 'name': 'Edit', 'permission': 'can_edit_package'},
                    {'id': 124, 'name': 'Delete', 'permission': 'can_delete_package'},
                    {'id': 125, 'name': 'View', 'permission': 'can_view_unique_package'},
                ],

                'Subscription': [
                    {'id': 126, 'name': 'List', 'permission': 'can_view_subscription'},
                    {'id': 127, 'name': 'Add', 'permission': 'can_add_subscription'},
                    {'id': 128, 'name': 'Edit', 'permission': 'can_edit_subscription'},
                    {'id': 129, 'name': 'Delete', 'permission': 'can_delete_subscription'},
                    {'id': 130, 'name': 'View', 'permission': 'can_view_unique_subscription'},
                    {'id': 131, 'name': 'Active Plan', 'permission': 'can_activeplan_subscription'},
                    {'id': 132, 'name': 'Renewal Plan', 'permission': 'can_renewalplan_subscription'},
                    {'id': 133, 'name': 'Filter', 'permission': 'can_filter_subscription'},
                    {'id': 134, 'name': 'Export', 'permission': 'can_export_subscription'},     
                    {'id': 272, 'name': 'Un subscribe', 'permission': 'can_unsubscribe_subscription'},    
                    {'id': 280, 'name': 'Status', 'permission': 'can_update_subscription_status'},        
                ],

                'MarketPriceChart': [

                    {'id': 135, 'name': 'List', 'permission': 'can_view_manage_product'},
                    {'id': 136, 'name': 'Add', 'permission': 'can_add_manage_product'},
                    {'id': 137, 'name': 'Edit', 'permission': 'can_edit_manage_product'},
                    {'id': 138, 'name': 'Delete', 'permission': 'can_delete_manage_product'},
                    {'id': 139, 'name': 'Update', 'permission': 'can_update_manage_product'},
                    {'id': 140, 'name': 'Graph', 'permission': 'can_graph_manage_product'},
                    {'id': 141, 'name': 'Filter', 'permission': 'can_filter_manage_product'},
                    {'id': 142, 'name': 'Staff', 'permission': 'can_staff_manage_product'},

                    {'id': 143, 'name': 'List', 'permission': 'can_view_market_report'},
                    {'id': 144, 'name': 'Edit', 'permission': 'can_edit_market_report'},
                    {'id': 145, 'name': 'Graph', 'permission': 'can_graph_market_report'},
                    {'id': 146, 'name': 'Filter', 'permission': 'can_filter_market_report'},

                    {'id': 147, 'name': 'List', 'permission': 'can_view_product_market_report'},
                    {'id': 148, 'name': 'Edit', 'permission': 'can_edit_product_market_report'},
                    {'id': 149, 'name': 'Graph', 'permission': 'can_graph_product_market_report'},
                    {'id': 150, 'name': 'Filter', 'permission': 'can_filter_product_market_report'},
                ],
                
                'Market Management': [
                    {'id': 151, 'name': 'List', 'permission': 'can_view_market'},
                    {'id': 152, 'name': 'Add', 'permission': 'can_add_market'},
                    {'id': 153, 'name': 'Edit', 'permission': 'can_edit_market'},
                    {'id': 154, 'name': 'Delete', 'permission': 'can_delete_market'},
                    {'id': 155, 'name': 'List', 'permission': 'can_view_unique_market'},
                    {'id': 156, 'name': 'Status', 'permission': 'can_status_market'},
                    {'id': 157, 'name': 'Export', 'permission': 'can_export_market'},
                    {'id': 158, 'name': 'Filter', 'permission': 'can_filter_market'},

                    {'id': 159, 'name': 'View', 'permission': 'can_view_allocate_market'},
                    {'id': 160, 'name': 'Status', 'permission': 'can_add_allocate_market'},
                    {'id': 161, 'name': 'Export', 'permission': 'can_edit_allocate_market'},
                    {'id': 162, 'name': 'Filter', 'permission': 'can_delete_allocate_market'},
                    {'id': 163, 'name': 'View', 'permission': 'can_view_unique_allocate_market'},
                    {'id': 164, 'name': 'Status', 'permission': 'can_status_allocate_market'},
                    {'id': 165, 'name': 'Export', 'permission': 'can_export_allocate_market'}, 
                
                ],

                'Schedule Management': [
                    {'id': 166, 'name': 'List', 'permission': 'can_view_schedule_activity_type'},
                    {'id': 167, 'name': 'Add', 'permission': 'can_add_schedule_activity_type'},
                    {'id': 168, 'name': 'Edit', 'permission': 'can_edit_schedule_activity_type'},
                    {'id': 169, 'name': 'Delete', 'permission': 'can_delete_schedule_activity_type'},
                    {'id': 170, 'name': 'Status', 'permission': 'can_status_schedule_activity_type'},

                    {'id': 171, 'name': 'List', 'permission': 'can_view_schedule'},
                    {'id': 172, 'name': 'Add', 'permission': 'can_add_schedule'},
                    {'id': 173, 'name': 'Edit', 'permission': 'can_edit_schedule'},
                    {'id': 174, 'name': 'Delete', 'permission': 'can_delete_schedule'},
                    {'id': 175, 'name': 'View', 'permission': 'can_view_unique_schedule'},
                    {'id': 176, 'name': 'Status', 'permission': 'can_status_schedule'},
                    {'id': 273, 'name': 'Filter', 'permission': 'can_filter_schedule'},
                    {'id': 274, 'name': 'Import', 'permission': 'can_import_schedule'},
                ],

                "NearByLocations": [
                    {"id": 177, "name": "List", "permission": "can_view_near_by_location_category"},
                    {"id": 178, "name": "Add", "permission": "can_add_near_by_location_category"},
                    {"id": 179, "name": "Edit", "permission": "can_edit_near_by_location_category"},
                    {"id": 180, "name": "Delete", "permission": "can_delete_near_by_location_category"},
                    {"id": 181, "name": "Status", "permission": "can_status_near_by_location_category"},

                    {"id": 182, "name": "List", "permission": "can_view_near_by_locations"},
                    {"id": 183, "name": "Add", "permission": "can_add_near_by_locations"},
                    {"id": 184, "name": "Edit", "permission": "can_edit_near_by_locations"},
                    {"id": 185, "name": "Delete", "permission": "can_delete_near_by_locations"},
                    {"id": 186, "name": "View", "permission": "can_view_unique_near_by_locations"},
                    {"id": 187, "name": "Status", "permission": "can_status_near_by_locations"},
                    {"id": 188, "name": "Export", "permission": "can_export_near_by_locations"},
                    {"id": 189, "name": "Filter", "permission": "can_filter_near_by_locations"},
                    
                ],

                "Workers Management": [

                    {"id": 190, "name": "List", "permission": "can_view_workers_type"},
                    {"id": 191, "name": "Add", "permission": "can_add_workers_type"},
                    {"id": 192, "name": "Edit", "permission": "can_edit_workers_type"},
                    {"id": 193, "name": "Delete", "permission": "can_delete_workers_type"},
                    {"id": 194, "name": "Status", "permission": "can_update_workers_type_status"},
                
                    {"id": 195, "name": "List", "permission": "can_view_manage_workers"},
                    {"id": 196, "name": "Add", "permission": "can_add_manage_workers"},
                    {"id": 197, "name": "Edit", "permission": "can_edit_manage_workers"},
                    {"id": 198, "name": "Delete", "permission": "can_delete_manage_workers"},
                    {"id": 199, "name": "Update", "permission": "can_update_manage_workers"},
                    {"id": 200, "name": "View", "permission": "can_view_unique_manage_workers"},
                    {"id": 201, "name": "Status", "permission": "can_update_manage_workers_status"},
                    {"id": 202, "name": "Export", "permission": "can_export_manage_workers"},                
                    {"id": 203, "name": "Filter", "permission": "can_filter_manage_workers"},
                
                ],
                
                "Guidelines Management": [

                    {"id": 204, "name": "List", "permission": "can_view_guidelines_category"},
                    {"id": 205, "name": "Add", "permission": "can_add_guidelines_category"},
                    {"id": 206, "name": "Edit", "permission": "can_edit_guidelines_category"},
                    {"id": 207, "name": "Delete", "permission": "can_delete_guidelines_category"},
                    {"id": 208, "name": "Status", "permission": "can_update_guidelines_category_status"},
                
                    {"id": 209, "name": "List", "permission": "can_view_guidelines"},
                    {"id": 210, "name": "Add", "permission": "can_add_guidelines"},
                    {"id": 211, "name": "Edit", "permission": "can_edit_guidelines"},
                    {"id": 212, "name": "Delete", "permission": "can_delete_guidelines"},
                    {"id": 213, "name": "View", "permission": "can_view_unique_guidelines"},
                    {"id": 214, "name": "Status", "permission": "can_update_guidelines_status"},
                    {"id": 215, "name": "Export", "permission": "can_export_guidelines"},                
                    {"id": 216, "name": "Filter", "permission": "can_filter_guidelines"},

                ],

                "User Management": [
                    
                    {"id": 217, "name": "List", "permission": "can_view_manage_user"},
                    {"id": 218, "name": "Add", "permission": "can_add_manage_user"},
                    {"id": 219, "name": "Edit", "permission": "can_edit_manage_user"},
                    {"id": 220, "name": "Delete", "permission": "can_delete_manage_user"},
                    {"id": 221, "name": "Status", "permission": "can_view_unique_manage_user"},
                    {"id": 222, "name": "List", "permission": "can_status_manage_user"},
                    {"id": 223, "name": "Add", "permission": "can_ter_status_manage_user"},
                    {"id": 224, "name": "Edit", "permission": "can_rel_status_manage_user"},
                    {"id": 225, "name": "Delete", "permission": "can_filter_manage_user"},
                    {"id": 226, "name": "View", "permission": "can_export_manage_user"}, 

                    {"id": 227, "name": "List", "permission": "can_view_manage_user_role"},
                    {"id": 228, "name": "Add", "permission": "can_add_manage_user_role"},
                    {"id": 229, "name": "Edit", "permission": "can_edit_manage_user_role"},
                    {"id": 230, "name": "Delete", "permission": "can_delete_manage_user_role"},
                    {"id": 231, "name": "View", "permission": "can_view_unique_manage_user_role"},
                    {"id": 232, "name": "Status", "permission": "can_status_manage_user_role"},
                
                ],

                "Report": [

                    {"id": 233, "name": "List", "permission": "can_view_farmer_report"},
                    {"id": 234, "name": "View", "permission": "can_view_unique_report"},
                    {"id": 235, "name": "Filter", "permission": "can_filter_farmer_report"},
                    {"id": 236, "name": "Export", "permission": "can_export_farmer_report"},


                    {"id": 237, "name": "List", "permission": "can_view_subscription_report"},
                    {"id": 238, "name": "View", "permission": "can_view_unique_subscription_report"},
                    {"id": 237, "name": "Filter", "permission": "can_filter_subscription_report"},
                    {"id": 238, "name": "Export", "permission": "can_export_subscription_report"},
                
                ],

                "Dashboard": [
                {"id": 241, "name": "View", "permission": "can_dashboard_count"}, 
                ],

                "Email Config": [ 
                    {"id": 242, "name": "List", "permission": "can_view_email_config"},
                    {"id": 243, "name": "Add", "permission": "can_add_email_config"},
                    {"id": 244, "name": "Status", "permission": "can_status_email_config"},
                    {"id": 245, "name": "Edit", "permission": "can_edit_email_config"},
                    {"id": 246, "name": "Delete", "permission": "can_delete_email_config"},
    
                ],

                "SMS Config": [  

                    {"id": 247, "name": "List", "permission": "can_view_sms_config"},
                    {"id": 248, "name": "Edit", "permission": "can_edit_sms_config"},
                    {"id": 249, "name": "Status", "permission": "can_status_sms_config"},
                    {"id": 250, "name": "Delete", "permission": "can_delete_sms_config"},
                
                ], 

                "Inventory Category":[
                    {"id": 251, "name": "List", "permission": "can_view_inventory_category"},
                    {"id": 252, "name": "Add", "permission": "can_add_inventory_category"},
                    {"id": 253, "name": "Status", "permission": "can_status_inventory_category"},
                    {"id": 254, "name": "Edit", "permission": "can_edit_inventory_category"},
                    {"id": 255, "name": "Delete", "permission": "can_delete_inventory_category"},
                ],
                "Inventory Items":[
                    {"id": 256, "name": "List", "permission": "can_view_inventory_items"},
                    {"id": 257, "name": "Add", "permission": "can_add_inventory_items"},
                    {"id": 258, "name": "Status", "permission": "can_status_inventory_items"},
                    {"id": 259, "name": "Edit", "permission": "can_edit_inventory_items"},
                    {"id": 260, "name": "Delete", "permission": "can_delete_inventory_items"},
                ],

                 "Document Category":[
                    {"id": 261, "name": "List", "permission": "can_view_document_category"},
                    {"id": 262, "name": "Add", "permission": "can_add_document_category"},
                    {"id": 263, "name": "Status", "permission": "can_status_document_category"},
                    {"id": 264, "name": "Edit", "permission": "can_edit_document_category"},
                    {"id": 265, "name": "Delete", "permission": "can_delete_document_category"},
                ],

                "Rental Availability":[
                    {"id": 266, "name": "List", "permission": "can_view_rental_availability"},
                    {"id": 267, "name": "Filter", "permission": "can_filter_rental_availability"},
                    {"id": 268, "name": "Export", "permission": "can_export_rental_availability"}
                ],
            }

            # Update permissions based on form input (checkboxes)
            for page, permissions in permissions_by_page.items():
                for permission in permissions:
                    permission_key = permission['permission']
                    # If the checkbox for this permission is checked, set it to True
                    if request.POST.get(permission_key):  # If checked, set to True
                        setattr(user_role, permission_key, True)
                    else:  # Otherwise, set to False
                        setattr(user_role, permission_key, False)

            # Save the updated user role
            user_role.updated_by = user
            user_role.save()
            messages.success(request, "User Role Updated Successfully.") 

            # Redirect to the role management page
            return redirect('sa_manage_role')

        elif action == 'create':
                # Get role details from the form
                role_name = request.POST.get('role_name')  # Get the role name from the form
                map_role_id = request.POST.get('map_role')  # Get selected map_role from the form
                selected_permissions = request.POST.getlist('permissions')  # Get selected permission IDs (as a list)

                # print(selected_permissions)
                # Fetch the associated role if it exists, otherwise None
                if map_role_id:
                    if map_role_id == '0':  # If '0' is selected, it means no map_role
                        map_role = None
                    else:
                        map_role = get_object_or_404(Role, id=map_role_id)
                else:
                    map_role = None

                # Create ManageUserRole instance
                manage_user_role = ManageUserRole.objects.create(
                    name=role_name,
                    map_role=map_role,
                    created_by = user
                )

                permissions_by_page = {
                    'Settings':[
                        {'id': 1, 'name': 'List', 'permission': 'can_view_general_setting'},
                        {'id': 2, 'name': 'Edit', 'permission': 'can_edit_general_setting'},

                        {'id': 3, 'name': 'Add', 'permission': 'can_add_country'},
                        {'id': 4, 'name': 'Edit', 'permission': 'can_edit_country'},
                        {'id': 5, 'name': 'View', 'permission': 'can_view_country'},
                        {'id': 6, 'name': 'Delete', 'permission': 'can_delete_country'},
                        {'id': 7, 'name': 'Status', 'permission': 'can_status_country'},

                        {'id': 8, 'name': 'Add', 'permission': 'can_add_state'},
                        {'id': 9, 'name': 'Edit', 'permission': 'can_edit_state'},
                        {'id': 10, 'name': 'View', 'permission': 'can_view_state'},
                        {'id': 11, 'name': 'Delete', 'permission': 'can_delete_state'},
                        {'id': 12, 'name': 'Status', 'permission': 'can_status_state'},

                        {'id': 13, 'name': 'Add', 'permission': 'can_add_city'},
                        {'id': 14, 'name': 'Edit', 'permission': 'can_edit_city'},
                        {'id': 15, 'name': 'View', 'permission': 'can_view_city'},
                        {'id': 16, 'name': 'Delete', 'permission': 'can_delete_city'},
                        {'id': 17, 'name': 'Status', 'permission': 'can_status_city'},

                        {'id': 18, 'name': 'Add', 'permission': 'can_add_taluk'},
                        {'id': 19, 'name': 'Edit', 'permission': 'can_edit_taluk'},
                        {'id': 20, 'name': 'View', 'permission': 'can_view_taluk'},
                        {'id': 21, 'name': 'Delete', 'permission': 'can_delete_taluk'},
                        {'id': 22, 'name': 'Status', 'permission': 'can_status_taluk'},

                        {'id': 23, 'name': 'Add', 'permission': 'can_add_village'},
                        {'id': 24, 'name': 'Edit', 'permission': 'can_edit_village'},
                        {'id': 25, 'name': 'View', 'permission': 'can_view_village'},
                        {'id': 26, 'name': 'Delete', 'permission': 'can_delete_village'},
                        {'id': 27, 'name': 'Status', 'permission': 'can_status_village'},
                    
                    ],

                    'Data Management':[

                        {'id': 28, 'name': 'Add', 'permission': 'can_add_land_unit'},
                        {'id': 29, 'name': 'Edit', 'permission': 'can_edit_land_unit'},
                        {'id': 30, 'name': 'View', 'permission': 'can_view_land_unit'},
                        {'id': 31, 'name': 'Delete', 'permission': 'can_delete_land_unit'},
                        {'id': 32, 'name': 'Status', 'permission': 'can_status_land_unit'},
                    
                        {'id': 33, 'name': 'Add', 'permission': 'can_add_area_unit'},
                        {'id': 34, 'name': 'Edit', 'permission': 'can_edit_area_unit'},
                        {'id': 35, 'name': 'View', 'permission': 'can_view_area_unit'},
                        {'id': 36, 'name': 'Delete', 'permission': 'can_delete_area_unit'},
                        {'id': 37, 'name': 'Status', 'permission': 'can_status_area_unit'},
                    

                        {'id': 38, 'name': 'Add', 'permission': 'can_add_soil_type'},
                        {'id': 39, 'name': 'Edit', 'permission': 'can_edit_soil_type'},
                        {'id': 40, 'name': 'View', 'permission': 'can_view_soil_type'},
                        {'id': 41, 'name': 'Delete', 'permission': 'can_delete_soil_type'},
                        {'id': 42, 'name': 'Status', 'permission': 'can_status_soil_type'},
                    

                        {'id': 43, 'name': 'Add', 'permission': 'can_add_crop_type'},
                        {'id': 44, 'name': 'Edit', 'permission': 'can_edit_crop_type'},
                        {'id': 45, 'name': 'View', 'permission': 'can_view_crop_type'},
                        {'id': 46, 'name': 'Delete', 'permission': 'can_delete_crop_type'},
                        {'id': 47, 'name': 'Status', 'permission': 'can_status_crop_type'},
                    

                        {'id': 48, 'name': 'Add', 'permission': 'can_add_quality'},
                        {'id': 49, 'name': 'Edit', 'permission': 'can_edit_quality'},
                        {'id': 50, 'name': 'View', 'permission': 'can_view_quality'},
                        {'id': 51, 'name': 'Delete', 'permission': 'can_delete_quality'},
                        {'id': 52, 'name': 'Status', 'permission': 'can_status_quality'},
                    

                        {'id': 53, 'name': 'Add', 'permission': 'can_add_crop'},
                        {'id': 54, 'name': 'Edit', 'permission': 'can_edit_crop'},
                        {'id': 55, 'name': 'View', 'permission': 'can_view_crop'},
                        {'id': 56, 'name': 'Delete', 'permission': 'can_delete_crop'},
                        {'id': 57, 'name': 'Status', 'permission': 'can_status_crop'},
                    

                        {'id': 58, 'name': 'Add', 'permission': 'can_add_product_type'},
                        {'id': 59, 'name': 'Edit', 'permission': 'can_edit_product_type'},
                        {'id': 60, 'name': 'View', 'permission': 'can_view_product_type'},
                        {'id': 61, 'name': 'Delete', 'permission': 'can_delete_product_type'},
                        {'id': 62, 'name': 'Status', 'permission': 'can_status_product_type'},
                    

                        {'id': 63, 'name': 'Add', 'permission': 'can_add_vehicle_category'},
                        {'id': 64, 'name': 'Edit', 'permission': 'can_edit_vehicle_category'},
                        {'id': 65, 'name': 'View', 'permission': 'can_view_vehicle_category'},
                        {'id': 66, 'name': 'Delete', 'permission': 'can_delete_vehicle_category'},
                        {'id': 67, 'name': 'Status', 'permission': 'can_status_vehicle_category'},
                    

                        {'id': 68, 'name': 'Add', 'permission': 'can_add_manage_vehicle'},
                        {'id': 69, 'name': 'Edit', 'permission': 'can_edit_manage_vehicle'},
                        {'id': 70, 'name': 'View', 'permission': 'can_view_manage_vehicle'},
                        {'id': 71, 'name': 'Delete', 'permission': 'can_delete_manage_vehicle'},
                        {'id': 72, 'name': 'Status', 'permission': 'can_status_manage_vehicle'},
                    

                        {'id': 73, 'name': 'Add', 'permission': 'can_add_machinery_category'},
                        {'id': 74, 'name': 'Edit', 'permission': 'can_edit_machinery_category'},
                        {'id': 75, 'name': 'View', 'permission': 'can_view_machinery_category'},
                        {'id': 76, 'name': 'Delete', 'permission': 'can_delete_machinery_category'},
                        {'id': 77, 'name': 'Status', 'permission': 'can_status_machinery_category'},
                    

                        {'id': 78, 'name': 'Add', 'permission': 'can_add_manage_machinery'},
                        {'id': 79, 'name': 'Edit', 'permission': 'can_edit_manage_machinery'},
                        {'id': 80, 'name': 'View', 'permission': 'can_view_manage_machinery'},
                        {'id': 81, 'name': 'Delete', 'permission': 'can_delete_manage_machinery'},
                        {'id': 82, 'name': 'Status', 'permission': 'can_status_manage_machinery'},
                    

                        {'id': 83, 'name': 'Add', 'permission': 'can_add_tool_category'},
                        {'id': 84, 'name': 'Edit', 'permission': 'can_edit_tool_category'},
                        {'id': 85, 'name': 'View', 'permission': 'can_view_tool_category'},
                        {'id': 86, 'name': 'Delete', 'permission': 'can_delete_tool_category'},
                        {'id': 87, 'name': 'Status', 'permission': 'can_status_tool_category'},
                    

                        {'id': 88, 'name': 'Add', 'permission': 'can_add_tool'},
                        {'id': 89, 'name': 'Edit', 'permission': 'can_edit_tool'},
                        {'id': 90, 'name': 'View', 'permission': 'can_view_tool'},
                        {'id': 91, 'name': 'Delete', 'permission': 'can_delete_tool'},
                        {'id': 92, 'name': 'Status', 'permission': 'can_status_tool'},
                    

                        {'id': 93, 'name': 'Add', 'permission': 'can_add_expense_category'},
                        {'id': 94, 'name': 'Edit', 'permission': 'can_edit_expense_category'},
                        {'id': 95, 'name': 'View', 'permission': 'can_view_expense_category'},
                        {'id': 96, 'name': 'Delete', 'permission': 'can_delete_expense_category'},
                        {'id': 97, 'name': 'Status', 'permission': 'can_status_expense_category'},
                    

                        {'id': 98, 'name': 'Add', 'permission': 'can_add_expense'},
                        {'id': 99, 'name': 'Edit', 'permission': 'can_edit_expense'},
                        {'id': 100, 'name': 'View', 'permission': 'can_view_expense'},
                        {'id': 101, 'name': 'Delete', 'permission': 'can_delete_expense'},
                        {'id': 102, 'name': 'Status', 'permission': 'can_status_expense'},
                    

                        {'id': 103, 'name': 'Add', 'permission': 'can_add_harvesting_type'},
                        {'id': 104, 'name': 'Edit', 'permission': 'can_edit_harvesting_type'},
                        {'id': 105, 'name': 'View', 'permission': 'can_view_harvesting_type'},
                        {'id': 106, 'name': 'Delete', 'permission': 'can_delete_harvesting_type'},
                        {'id': 107, 'name': 'Status', 'permission': 'can_status_harvesting_type'},
                    

                        {'id': 108, 'name': 'Add', 'permission': 'can_add_detection'},
                        {'id': 109, 'name': 'Edit', 'permission': 'can_edit_detection'},
                        {'id': 110, 'name': 'View', 'permission': 'can_view_detection'},
                        {'id': 111, 'name': 'Delete', 'permission': 'can_delete_detection'},
                        {'id': 112, 'name': 'Status', 'permission': 'can_status_detection'},
                    

                    ],

                    'Farmer': [
                        {'id': 113, 'name': 'List', 'permission': 'can_view_farmer'},
                        {'id': 114, 'name': 'Add', 'permission': 'can_add_farmer'},
                        {'id': 115, 'name': 'Edit', 'permission': 'can_edit_farmer'},
                        {'id': 116, 'name': 'Delete', 'permission': 'can_delete_farmer'},
                        {'id': 117, 'name': 'View', 'permission': 'can_view_unique_farmer'},
                        {'id': 118, 'name': 'Export', 'permission': 'can_export_farmer_data'},
                        {'id': 119, 'name': 'Filter', 'permission': 'can_filter_farmer_data'},
                        {'id': 120, 'name': 'Status', 'permission': 'can_update_farmer_status'},
                        {'id': 270, 'name': 'Subscribe', 'permission': 'can_subscribe_farmer_package'},
                        {'id': 271, 'name': 'Subscribe', 'permission': 'can_unsubscribe_farmer_package'},
                    ],

                    'Package': [
                        {'id': 121, 'name': 'List', 'permission': 'can_view_package'},
                        {'id': 122, 'name': 'Add', 'permission': 'can_add_package'},
                        {'id': 123, 'name': 'Edit', 'permission': 'can_edit_package'},
                        {'id': 124, 'name': 'Delete', 'permission': 'can_delete_package'},
                        {'id': 125, 'name': 'View', 'permission': 'can_view_unique_package'},
                    ],

                    'Subscription': [
                        {'id': 126, 'name': 'List', 'permission': 'can_view_subscription'},
                        {'id': 127, 'name': 'Add', 'permission': 'can_add_subscription'},
                        {'id': 128, 'name': 'Edit', 'permission': 'can_edit_subscription'},
                        {'id': 129, 'name': 'Delete', 'permission': 'can_delete_subscription'},
                        {'id': 130, 'name': 'View', 'permission': 'can_view_unique_subscription'},
                        {'id': 131, 'name': 'Active Plan', 'permission': 'can_activeplan_subscription'},
                        {'id': 132, 'name': 'Renewal Plan', 'permission': 'can_renewalplan_subscription'},
                        {'id': 133, 'name': 'Filter', 'permission': 'can_filter_subscription'},
                        {'id': 134, 'name': 'Export', 'permission': 'can_export_subscription'},       
                        {'id': 272, 'name': 'Un subscribe', 'permission': 'can_unsubscribe_subscription'},     
                        {'id': 280, 'name': 'Status', 'permission': 'can_update_subscription_status'},       
                    ],

                    'MarketPriceChart': [

                        {'id': 135, 'name': 'List', 'permission': 'can_view_manage_product'},
                        {'id': 136, 'name': 'Add', 'permission': 'can_add_manage_product'},
                        {'id': 137, 'name': 'Edit', 'permission': 'can_edit_manage_product'},
                        {'id': 138, 'name': 'Delete', 'permission': 'can_delete_manage_product'},
                        {'id': 139, 'name': 'Update', 'permission': 'can_update_manage_product'},
                        {'id': 140, 'name': 'Graph', 'permission': 'can_graph_manage_product'},
                        {'id': 141, 'name': 'Filter', 'permission': 'can_filter_manage_product'},
                        {'id': 142, 'name': 'Staff', 'permission': 'can_staff_manage_product'},

                        {'id': 143, 'name': 'List', 'permission': 'can_view_market_report'},
                        {'id': 144, 'name': 'Edit', 'permission': 'can_edit_market_report'},
                        {'id': 145, 'name': 'Graph', 'permission': 'can_graph_market_report'},
                        {'id': 146, 'name': 'Filter', 'permission': 'can_filter_market_report'},

                        {'id': 147, 'name': 'List', 'permission': 'can_view_product_market_report'},
                        {'id': 148, 'name': 'Edit', 'permission': 'can_edit_product_market_report'},
                        {'id': 149, 'name': 'Graph', 'permission': 'can_graph_product_market_report'},
                        {'id': 150, 'name': 'Filter', 'permission': 'can_filter_product_market_report'},
                    ],
                    
                    'Market Management': [
                        {'id': 151, 'name': 'List', 'permission': 'can_view_market'},
                        {'id': 152, 'name': 'Add', 'permission': 'can_add_market'},
                        {'id': 153, 'name': 'Edit', 'permission': 'can_edit_market'},
                        {'id': 154, 'name': 'Delete', 'permission': 'can_delete_market'},
                        {'id': 155, 'name': 'List', 'permission': 'can_view_unique_market'},
                        {'id': 156, 'name': 'Status', 'permission': 'can_status_market'},
                        {'id': 157, 'name': 'Export', 'permission': 'can_export_market'},
                        {'id': 158, 'name': 'Filter', 'permission': 'can_filter_market'},

                        {'id': 159, 'name': 'View', 'permission': 'can_view_allocate_market'},
                        {'id': 160, 'name': 'Status', 'permission': 'can_add_allocate_market'},
                        {'id': 161, 'name': 'Export', 'permission': 'can_edit_allocate_market'},
                        {'id': 162, 'name': 'Filter', 'permission': 'can_delete_allocate_market'},
                        {'id': 163, 'name': 'View', 'permission': 'can_view_unique_allocate_market'},
                        {'id': 164, 'name': 'Status', 'permission': 'can_status_allocate_market'},
                        {'id': 165, 'name': 'Export', 'permission': 'can_export_allocate_market'}, 
                    
                    ],

                    'Schedule Management': [
                        {'id': 166, 'name': 'List', 'permission': 'can_view_schedule_activity_type'},
                        {'id': 167, 'name': 'Add', 'permission': 'can_add_schedule_activity_type'},
                        {'id': 168, 'name': 'Edit', 'permission': 'can_edit_schedule_activity_type'},
                        {'id': 169, 'name': 'Delete', 'permission': 'can_delete_schedule_activity_type'},
                        {'id': 170, 'name': 'Status', 'permission': 'can_status_schedule_activity_type'},

                        {'id': 171, 'name': 'List', 'permission': 'can_view_schedule'},
                        {'id': 172, 'name': 'Add', 'permission': 'can_add_schedule'},
                        {'id': 173, 'name': 'Edit', 'permission': 'can_edit_schedule'},
                        {'id': 174, 'name': 'Delete', 'permission': 'can_delete_schedule'},
                        {'id': 175, 'name': 'View', 'permission': 'can_view_unique_schedule'},
                        {'id': 176, 'name': 'Status', 'permission': 'can_status_schedule'},
                        {'id': 273, 'name': 'Filter', 'permission': 'can_filter_schedule'},
                        {'id': 274, 'name': 'Import', 'permission': 'can_import_schedule'},
                    ],

                    "NearByLocations": [
                        {"id": 177, "name": "List", "permission": "can_view_near_by_location_category"},
                        {"id": 178, "name": "Add", "permission": "can_add_near_by_location_category"},
                        {"id": 179, "name": "Edit", "permission": "can_edit_near_by_location_category"},
                        {"id": 180, "name": "Delete", "permission": "can_delete_near_by_location_category"},
                        {"id": 181, "name": "Status", "permission": "can_status_near_by_location_category"},

                        {"id": 182, "name": "List", "permission": "can_view_near_by_locations"},
                        {"id": 183, "name": "Add", "permission": "can_add_near_by_locations"},
                        {"id": 184, "name": "Edit", "permission": "can_edit_near_by_locations"},
                        {"id": 185, "name": "Delete", "permission": "can_delete_near_by_locations"},
                        {"id": 186, "name": "View", "permission": "can_view_unique_near_by_locations"},
                        {"id": 187, "name": "Status", "permission": "can_status_near_by_locations"},
                        {"id": 188, "name": "Export", "permission": "can_export_near_by_locations"},
                        {"id": 189, "name": "Filter", "permission": "can_filter_near_by_locations"},
                        
                    ],

                    "Workers Management": [

                        {"id": 190, "name": "List", "permission": "can_view_workers_type"},
                        {"id": 191, "name": "Add", "permission": "can_add_workers_type"},
                        {"id": 192, "name": "Edit", "permission": "can_edit_workers_type"},
                        {"id": 193, "name": "Delete", "permission": "can_delete_workers_type"},
                        {"id": 194, "name": "Status", "permission": "can_update_workers_type_status"},
                    
                        {"id": 195, "name": "List", "permission": "can_view_manage_workers"},
                        {"id": 196, "name": "Add", "permission": "can_add_manage_workers"},
                        {"id": 197, "name": "Edit", "permission": "can_edit_manage_workers"},
                        {"id": 198, "name": "Delete", "permission": "can_delete_manage_workers"},
                        {"id": 199, "name": "Update", "permission": "can_update_manage_workers"},
                        {"id": 200, "name": "View", "permission": "can_view_unique_manage_workers"},
                        {"id": 201, "name": "Status", "permission": "can_update_manage_workers_status"},
                        {"id": 202, "name": "Export", "permission": "can_export_manage_workers"},                
                        {"id": 203, "name": "Filter", "permission": "can_filter_manage_workers"},
                    
                    ],
                    
                    "Guidelines Management": [

                        {"id": 204, "name": "List", "permission": "can_view_guidelines_category"},
                        {"id": 205, "name": "Add", "permission": "can_add_guidelines_category"},
                        {"id": 206, "name": "Edit", "permission": "can_edit_guidelines_category"},
                        {"id": 207, "name": "Delete", "permission": "can_delete_guidelines_category"},
                        {"id": 208, "name": "Status", "permission": "can_update_guidelines_category_status"},
                    
                        {"id": 209, "name": "List", "permission": "can_view_guidelines"},
                        {"id": 210, "name": "Add", "permission": "can_add_guidelines"},
                        {"id": 211, "name": "Edit", "permission": "can_edit_guidelines"},
                        {"id": 212, "name": "Delete", "permission": "can_delete_guidelines"},
                        {"id": 213, "name": "View", "permission": "can_view_unique_guidelines"},
                        {"id": 214, "name": "Status", "permission": "can_update_guidelines_status"},
                        {"id": 215, "name": "Export", "permission": "can_export_guidelines"},                
                        {"id": 216, "name": "Filter", "permission": "can_filter_guidelines"},

                    ],

                    "User Management": [
                        
                        {"id": 217, "name": "List", "permission": "can_view_manage_user"},
                        {"id": 218, "name": "Add", "permission": "can_add_manage_user"},
                        {"id": 219, "name": "Edit", "permission": "can_edit_manage_user"},
                        {"id": 220, "name": "Delete", "permission": "can_delete_manage_user"},
                        {"id": 221, "name": "Status", "permission": "can_view_unique_manage_user"},
                        {"id": 222, "name": "List", "permission": "can_status_manage_user"},
                        {"id": 223, "name": "Add", "permission": "can_ter_status_manage_user"},
                        {"id": 224, "name": "Edit", "permission": "can_rel_status_manage_user"},
                        {"id": 225, "name": "Delete", "permission": "can_filter_manage_user"},
                        {"id": 226, "name": "View", "permission": "can_export_manage_user"}, 

                        {"id": 227, "name": "List", "permission": "can_view_manage_user_role"},
                        {"id": 228, "name": "Add", "permission": "can_add_manage_user_role"},
                        {"id": 229, "name": "Edit", "permission": "can_edit_manage_user_role"},
                        {"id": 230, "name": "Delete", "permission": "can_delete_manage_user_role"},
                        {"id": 231, "name": "View", "permission": "can_view_unique_manage_user_role"},
                        {"id": 232, "name": "Status", "permission": "can_status_manage_user_role"},
                    
                    ],

                    "Report": [

                        {"id": 233, "name": "List", "permission": "can_view_farmer_report"},
                        {"id": 234, "name": "View", "permission": "can_view_unique_report"},
                        {"id": 235, "name": "Filter", "permission": "can_filter_farmer_report"},
                        {"id": 236, "name": "Export", "permission": "can_export_farmer_report"},


                        {"id": 237, "name": "List", "permission": "can_view_subscription_report"},
                        {"id": 238, "name": "View", "permission": "can_view_unique_subscription_report"},
                        {"id": 239, "name": "Filter", "permission": "can_filter_subscription_report"},
                        {"id": 240, "name": "Export", "permission": "can_export_subscription_report"},
                    
                    ],
                    
                    "Dashboard": [
                        {"id": 241, "name": "View", "permission": "can_dashboard_count"}, 
                    ],

                    "Email Config": [ 
                        {"id": 242, "name": "List", "permission": "can_view_email_config"},
                        {"id": 243, "name": "Add", "permission": "can_add_email_config"},
                        {"id": 244, "name": "Status", "permission": "can_status_email_config"},
                        {"id": 245, "name": "Edit", "permission": "can_edit_email_config"},
                        {"id": 246, "name": "Delete", "permission": "can_delete_email_config"},
        
                    ],

                    "SMS Config": [  

                        {"id": 247, "name": "List", "permission": "can_view_sms_config"},
                        {"id": 248, "name": "Edit", "permission": "can_edit_sms_config"},
                        {"id": 249, "name": "Status", "permission": "can_status_sms_config"},
                        {"id": 250, "name": "Delete", "permission": "can_delete_sms_config"},
                    
                    ],

                    "Inventory Category":[
                    {"id": 251, "name": "List", "permission": "can_view_inventory_category"},
                    {"id": 252, "name": "Add", "permission": "can_add_inventory_category"},
                    {"id": 253, "name": "Status", "permission": "can_status_inventory_category"},
                    {"id": 254, "name": "Edit", "permission": "can_edit_inventory_category"},
                    {"id": 255, "name": "Delete", "permission": "can_delete_inventory_category"},
                ],
                
                    "Inventory Items":[
                        {"id": 256, "name": "List", "permission": "can_view_inventory_items"},
                        {"id": 257, "name": "Add", "permission": "can_add_inventory_items"},
                        {"id": 258, "name": "Status", "permission": "can_status_inventory_items"},
                        {"id": 259, "name": "Edit", "permission": "can_edit_inventory_items"},
                        {"id": 260, "name": "Delete", "permission": "can_delete_inventory_items"},
                    ],

                    "Document Category":[
                        {"id": 261, "name": "List", "permission": "can_view_document_category"},
                        {"id": 262, "name": "Add", "permission": "can_add_document_category"},
                        {"id": 263, "name": "Status", "permission": "can_status_document_category"},
                        {"id": 264, "name": "Edit", "permission": "can_edit_document_category"},
                        {"id": 265, "name": "Delete", "permission": "can_delete_document_category"},
                    ],

                    "Rental Availability":[
                        {"id": 266, "name": "List", "permission": "can_view_rental_availability"},
                        {"id": 267, "name": "Filter", "permission": "can_filter_rental_availability"},
                        {"id": 268, "name": "Export", "permission": "can_export_rental_availability"}
                    ],
                    
                }
 
                # Loop through selected permissions and set the corresponding fields
                for permission_id in selected_permissions:
                    # For each permission_id, check which permission is selected and set the corresponding field to True
                    if permission_id == '1':  # For View Farmer permission
                        setattr(manage_user_role, 'can_view_general_setting', True)
                    elif permission_id == '2':  # For Add Farmer permission
                        setattr(manage_user_role, 'can_edit_general_setting', True)
                    elif permission_id == '3':  # For Edit Farmer permission
                        setattr(manage_user_role, 'can_add_country', True)
                    elif permission_id == '4':  # For Delete Farmer permission
                        setattr(manage_user_role, 'can_edit_country', True)
                    elif permission_id == '5':  # For View Unique Farmer permission
                        setattr(manage_user_role, 'can_view_country', True)
                    
                    elif permission_id == '6':
                        setattr(manage_user_role,'can_delete_country',True)
                    elif permission_id == '7':
                        setattr(manage_user_role,'can_status_country',True)
                    elif permission_id == '8':
                        setattr(manage_user_role,'can_add_state',True)


                    # For Package Permissions
                    elif permission_id == '9':  # For View Package permission
                        setattr(manage_user_role, 'can_edit_state', True)
                    elif permission_id == '10':  # For Add Package permission
                        setattr(manage_user_role, 'can_view_state', True)
                    elif permission_id == '11':  # For Edit Package permission
                        setattr(manage_user_role, 'can_delete_state', True)
                    elif permission_id == '12':  # For Delete Package permission
                        setattr(manage_user_role, 'can_status_state', True)
                    elif permission_id == '13':  # For View Unique Package permission
                        setattr(manage_user_role, 'can_add_city', True)

                    # For Subscription Permissions
                    elif permission_id == '14':  # For View Subscription permission
                        setattr(manage_user_role, 'can_edit_city', True)
                    elif permission_id == '15':  # For Add Subscription permission
                        setattr(manage_user_role, 'can_view_city', True)
                    elif permission_id == '16':  # For Edit Subscription permission
                        setattr(manage_user_role, 'can_delete_city', True)
                    elif permission_id == '17':  # For Delete Subscription permission
                        setattr(manage_user_role, 'can_status_city', True)
                    elif permission_id == '18':  # For View Unique Subscription permission
                        setattr(manage_user_role, 'can_add_taluk', True) 

                    elif permission_id =='19':
                        setattr(manage_user_role,'can_edit_taluk', True)
                    elif permission_id =='20':
                        setattr(manage_user_role, 'can_view_taluk', True)
                    elif permission_id =='21':
                        setattr(manage_user_role,'can_delete_taluk',True)
                    elif permission_id == '22':
                        setattr(manage_user_role,'can_status_taluk', True)

                    elif permission_id == '23':
                        setattr(manage_user_role,'can_add_village',True)
                    elif permission_id == '24':
                        setattr(manage_user_role,'can_edit_village',True)
                    elif permission_id == '25':
                        setattr(manage_user_role, 'can_view_village',True)
                    elif permission_id == '26':
                        setattr(manage_user_role,'can_delete_village', True)

                    # For Market Permissions
                    elif permission_id == '27':  # For View Market permission
                        setattr(manage_user_role, 'can_status_village', True)
                    elif permission_id == '28':  # For Add Market permission
                        setattr(manage_user_role, 'can_add_land_unit', True)
                    elif permission_id == '29':  # For Edit Market permission
                        setattr(manage_user_role, 'can_edit_land_unit', True)
                    elif permission_id == '30':  # For Delete Market permission
                        setattr(manage_user_role, 'can_view_land_unit', True)
                    elif permission_id == '31':  # For View Unique Market permission
                        setattr(manage_user_role, 'can_delete_land_unit', True)
                    elif permission_id == '32':  # For Edit Market permission
                        setattr(manage_user_role, 'can_status_land_unit', True)
                    elif permission_id == '33':  # For Delete Market permission
                        setattr(manage_user_role, 'can_add_area_unit', True)
                    elif permission_id == '34':  # For View Unique Market permission
                        setattr(manage_user_role, 'can_edit_area_unit', True)

                    elif permission_id == '35':
                        setattr(manage_user_role, 'can_view_area_unit', True)
                    elif permission_id == '36':
                        setattr(manage_user_role, 'can_delete_area_unit', True)
                    elif permission_id == '37':
                        setattr(manage_user_role, 'can_status_area_unit', True)
                    elif permission_id == '38':
                        setattr(manage_user_role, 'can_add_soil_type', True)
                    elif permission_id == '39':
                        setattr(manage_user_role, 'can_edit_soil_type', True)
                    elif permission_id == '40':
                        setattr(manage_user_role, 'can_view_soil_type', True)
                    elif permission_id == '41':
                        setattr(manage_user_role, 'can_delete_soil_type', True)

                    elif permission_id == '42':
                        setattr(manage_user_role, 'can_status_soil_type', True)
                    elif permission_id == '43':
                        setattr(manage_user_role, 'can_add_crop_type', True)
                    elif permission_id == '44':
                        setattr(manage_user_role, 'can_edit_crop_type', True)
                    elif permission_id == '45':
                        setattr(manage_user_role, 'can_view_crop_type', True)
                    elif permission_id == '46':
                        setattr(manage_user_role, 'can_delete_crop_type', True)

                    elif permission_id == '47':
                        setattr(manage_user_role, 'can_status_crop_type', True)
                    elif permission_id == '48':
                        setattr(manage_user_role, 'can_add_quality', True)
                    elif permission_id == '49':
                        setattr(manage_user_role, 'can_edit_quality', True)
                    elif permission_id == '50':
                        setattr(manage_user_role, 'can_view_quality', True)
                    elif permission_id == '51':
                        setattr(manage_user_role, 'can_delete_quality', True)
                    elif permission_id == '52':
                        setattr(manage_user_role, 'can_status_quality', True)
                    elif permission_id == '53':
                        setattr(manage_user_role, 'can_add_crop', True)
                    elif permission_id == '54':
                        setattr(manage_user_role, 'can_edit_crop', True)

                    elif permission_id == '55':
                        setattr(manage_user_role, 'can_view_crop', True)
                    elif permission_id == '56':
                        setattr(manage_user_role, 'can_delete_crop', True)
                    elif permission_id == '57':
                        setattr(manage_user_role, 'can_status_crop', True)
                    elif permission_id == '58':
                        setattr(manage_user_role, 'can_add_product_type', True)
                    elif permission_id == '59':
                        setattr(manage_user_role, 'can_edit_product_type', True)
                    elif permission_id == '60':
                        setattr(manage_user_role, 'can_view_product_type', True)
                    elif permission_id == '61':
                        setattr(manage_user_role, 'can_delete_product_type', True)
                    elif permission_id == '62':
                        setattr(manage_user_role, 'can_status_product_type', True)
                    elif permission_id == '63':
                        setattr(manage_user_role, 'can_add_vehicle_category', True) 
                    elif permission_id == '64':
                        setattr(manage_user_role, 'can_edit_vehicle_category', True)
                    elif permission_id == '65':
                        setattr(manage_user_role, 'can_view_vehicle_category', True)
                    elif permission_id == '66':
                        setattr(manage_user_role, 'can_delete_vehicle_category', True)
                    elif permission_id == '67':
                        setattr(manage_user_role, 'can_status_vehicle_category', True)
                    elif permission_id == '68':
                        setattr(manage_user_role, 'can_add_manage_vehicle', True)   

                    # For Market Permissions
                    elif permission_id == '69':  # For View Market permission
                        setattr(manage_user_role, 'can_edit_manage_vehicle', True)
                    elif permission_id == '70':  # For Add Market permission
                        setattr(manage_user_role, 'can_view_manage_vehicle', True)
                    elif permission_id == '71':  # For Edit Market permission
                        setattr(manage_user_role, 'can_delete_manage_vehicle', True)
                    elif permission_id == '72':  # For Delete Market permission
                        setattr(manage_user_role, 'can_status_manage_vehicle', True)
                    elif permission_id == '73':  # For View Unique Market permission
                        setattr(manage_user_role, 'can_add_machinery_category', True) 

                    elif permission_id == '74':
                        setattr(manage_user_role, 'can_edit_machinery_category', True)
                    elif permission_id == '75':
                        setattr(manage_user_role, 'can_view_machinery_category', True)
                    elif permission_id == '76':
                        setattr(manage_user_role, 'can_delete_machinery_category', True)
                    elif permission_id == '77':
                        setattr(manage_user_role, 'can_status_machinery_category', True)
                    elif permission_id == '78':
                        setattr(manage_user_role, 'can_add_manage_machinery', True)
                    elif permission_id == '79':
                        setattr(manage_user_role, 'can_edit_manage_machinery', True)
                    elif permission_id == '80':
                        setattr(manage_user_role, 'can_view_manage_machinery', True)
                    elif permission_id == '81':
                        setattr(manage_user_role, 'can_delete_manage_machinery', True)

                    elif permission_id == '82':
                        setattr(manage_user_role, 'can_status_manage_machinery', True)
                    elif permission_id == '83':
                        setattr(manage_user_role, 'can_add_tool_category', True)
                    elif permission_id == '84':
                        setattr(manage_user_role, 'can_edit_tool_category', True)
                    elif permission_id == '85':
                        setattr(manage_user_role, 'can_view_tool_category', True)
                    elif permission_id == '86':
                        setattr(manage_user_role, 'can_delete_tool_category', True)

                    elif permission_id == '87':
                        setattr(manage_user_role, 'can_status_tool_category', True)
                    elif permission_id == '88':
                        setattr(manage_user_role, 'can_add_tool', True)
                    elif permission_id == '89':
                        setattr(manage_user_role, 'can_edit_tool', True)
                    elif permission_id == '90':
                        setattr(manage_user_role, 'can_view_tool', True)
                    elif permission_id == '91':
                        setattr(manage_user_role, 'can_delete_tool', True)
                    elif permission_id == '92':
                        setattr(manage_user_role, 'can_status_tool', True)

                    elif permission_id == '93':  # For View Market permission
                        setattr(manage_user_role, 'can_add_expense_category', True)
                    elif permission_id == '94':  # For Add Market permission
                        setattr(manage_user_role, 'can_edit_expense_category', True)
                    elif permission_id == '95':  # For Edit Market permission
                        setattr(manage_user_role, 'can_view_expense_category', True)
                    elif permission_id == '96':  # For Delete Market permission
                        setattr(manage_user_role, 'can_delete_expense_category', True)
                    elif permission_id == '97':  # For View Unique Market permission
                        setattr(manage_user_role, 'can_status_expense_category', True)
                    elif permission_id == '98':  # For Edit Market permission
                        setattr(manage_user_role, 'can_add_expense', True)
                    elif permission_id == '99':  # For Delete Market permission
                        setattr(manage_user_role, 'can_edit_expense', True)
                    elif permission_id == '100':  # For View Unique Market permission
                        setattr(manage_user_role, 'can_view_expense', True)

                    elif permission_id == '101':
                        setattr(manage_user_role, 'can_delete_expense', True)
                    elif permission_id == '102':
                        setattr(manage_user_role, 'can_status_expense', True)
                    elif permission_id == '103':
                        setattr(manage_user_role, 'can_add_harvesting_type', True)
                    elif permission_id == '104':
                        setattr(manage_user_role, 'can_edit_harvesting_type', True)
                    elif permission_id == '105':
                        setattr(manage_user_role, 'can_view_harvesting_type', True)
                    elif permission_id == '106':
                        setattr(manage_user_role, 'can_delete_harvesting_type', True)
                    elif permission_id == '107':
                        setattr(manage_user_role, 'can_status_harvesting_type', True)

                    elif permission_id == '108':
                        setattr(manage_user_role, 'can_add_detection', True)
                    elif permission_id == '109':
                        setattr(manage_user_role, 'can_edit_detection', True)
                    elif permission_id == '110':
                        setattr(manage_user_role, 'can_view_detection', True)
                    elif permission_id == '111':
                        setattr(manage_user_role, 'can_delete_detection', True)
                    elif permission_id == '112':
                        setattr(manage_user_role, 'can_status_detection', True)
                    
                    # Farmer Management
                    elif permission_id == '113':
                        setattr(manage_user_role, 'can_view_farmer', True)
                    elif permission_id == '114':
                        setattr(manage_user_role, 'can_add_farmer', True)
                    elif permission_id == '115':
                        setattr(manage_user_role, 'can_edit_farmer', True)
                    elif permission_id == '116':
                        setattr(manage_user_role, 'can_delete_farmer', True)
                    elif permission_id == '117':
                        setattr(manage_user_role, 'can_view_unique_farmer', True)
                    elif permission_id == '118':
                        setattr(manage_user_role, 'can_export_farmer_data', True)
                    elif permission_id == '119':
                        setattr(manage_user_role, 'can_filter_farmer_data', True)
                    elif permission_id == '120':
                        setattr(manage_user_role, 'can_update_farmer_status', True)
                    elif permission_id == '270':
                        setattr(manage_user_role, 'can_subscribe_farmer_package', True)
                    elif permission_id == '271':
                        setattr(manage_user_role, 'can_unsubscribe_farmer_package', True)

                    # package management
                    elif permission_id == '121':
                        setattr(manage_user_role, 'can_view_package', True)
                    elif permission_id == '122':
                        setattr(manage_user_role, 'can_add_package', True)
                    elif permission_id == '123':
                        setattr(manage_user_role, 'can_edit_package', True)
                    elif permission_id == '124':
                        setattr(manage_user_role, 'can_delete_package', True)
                    elif permission_id == '125':
                        setattr(manage_user_role, 'can_view_unique_package', True)
                    elif permission_id == '126':
                        setattr(manage_user_role, 'can_view_subscription', True)
                    elif permission_id == '127':
                        setattr(manage_user_role, 'can_add_subscription', True)
                    elif permission_id == '128':
                        setattr(manage_user_role, 'can_edit_subscription', True)
                    elif permission_id == '129':
                        setattr(manage_user_role, 'can_delete_subscription', True) 
                    elif permission_id == '130':
                        setattr(manage_user_role, 'can_view_unique_subscription', True)
                    elif permission_id == '131':
                        setattr(manage_user_role, 'can_activeplan_subscription', True)
                    elif permission_id == '132':
                        setattr(manage_user_role, 'can_renewalplan_subscription', True)
                    elif permission_id == '133':
                        setattr(manage_user_role, 'can_filter_subscription', True)
                    elif permission_id == '134':
                        setattr(manage_user_role, 'can_export_subscription', True) 
                    elif permission_id == '272':
                        setattr(manage_user_role, 'can_unsubscribe_subscription', True) 
                     
                    # For Market Permissions
                    elif permission_id == '135':  # For View Market permission
                        setattr(manage_user_role, 'can_view_manage_product', True)
                    elif permission_id == '136':  # For Add Market permission
                        setattr(manage_user_role, 'can_add_manage_product', True)
                    elif permission_id == '137':  # For Edit Market permission
                        setattr(manage_user_role, 'can_edit_manage_product', True)
                    elif permission_id == '138':  # For Delete Market permission
                        setattr(manage_user_role, 'can_delete_manage_product', True)
                    elif permission_id == '139':  # For View Unique Market permission
                        setattr(manage_user_role, 'can_update_manage_product', True) 
                    elif permission_id == '140':
                        setattr(manage_user_role, 'can_graph_manage_product', True)
                    elif permission_id == '141':
                        setattr(manage_user_role, 'can_filter_manage_product', True)
                    elif permission_id == '142':
                        setattr(manage_user_role, 'can_staff_manage_product', True)

                    elif permission_id == '143':
                        setattr(manage_user_role, 'can_view_market_report', True)
                    elif permission_id == '144':
                        setattr(manage_user_role, 'can_edit_market_report', True)
                    elif permission_id == '145':
                        setattr(manage_user_role, 'can_graph_market_report', True)
                    elif permission_id == '146':
                        setattr(manage_user_role, 'can_filter_market_report', True)
 
                    elif permission_id == '147':
                        setattr(manage_user_role, 'can_view_product_market_report', True)
                    elif permission_id == '148':
                        setattr(manage_user_role, 'can_edit_product_market_report', True)
                    elif permission_id == '149':
                        setattr(manage_user_role, 'can_graph_product_market_report', True)
                    elif permission_id == '150':
                        setattr(manage_user_role, 'can_filter_product_market_report', True)

                    elif permission_id == '151':  # For Add Market permission
                        setattr(manage_user_role, 'can_view_market', True)
                    elif permission_id == '152':  # For Edit Market permission
                        setattr(manage_user_role, 'can_add_market', True)
                    elif permission_id == '153':  # For Delete Market permission
                        setattr(manage_user_role, 'can_edit_market', True)
                    elif permission_id == '154':  # For View Unique Market permission
                        setattr(manage_user_role, 'can_delete_market', True) 

                    elif permission_id == '155':
                        setattr(manage_user_role, 'can_view_unique_market', True)
                    elif permission_id == '156':
                        setattr(manage_user_role, 'can_status_market', True)
                    elif permission_id == '157':
                        setattr(manage_user_role, 'can_export_market', True)
                    elif permission_id == '158':
                        setattr(manage_user_role, 'can_filter_market', True)
                    elif permission_id == '159':
                        setattr(manage_user_role, 'can_view_allocate_market', True)
                    elif permission_id == '160':
                        setattr(manage_user_role, 'can_add_allocate_market', True)
                    elif permission_id == '161':
                        setattr(manage_user_role, 'can_edit_allocate_market', True)
                    elif permission_id == '162':
                        setattr(manage_user_role, 'can_delete_allocate_market', True)
                    elif permission_id == '163':
                        setattr(manage_user_role, 'can_view_unique_allocate_market', True)
                    elif permission_id == '164':
                        setattr(manage_user_role, 'can_status_allocate_market', True)
                    elif permission_id == '165':
                        setattr(manage_user_role, 'can_export_allocate_market', True) 

                    elif permission_id == '166':
                        setattr(manage_user_role, 'can_view_schedule_activity_type', True)
                    elif permission_id == '167':
                        setattr(manage_user_role, 'can_add_schedule_activity_type', True)
                    elif permission_id == '168':
                        setattr(manage_user_role, 'can_edit_schedule_activity_type', True)
                    elif permission_id == '169':
                        setattr(manage_user_role, 'can_delete_schedule_activity_type', True)
                    elif permission_id == '170':
                        setattr(manage_user_role, 'can_status_schedule_activity_type', True)

                    elif permission_id == '171':
                        setattr(manage_user_role, 'can_view_schedule', True)
                    elif permission_id == '172':
                        setattr(manage_user_role, 'can_add_schedule', True)
                    elif permission_id == '173':
                        setattr(manage_user_role, 'can_edit_schedule', True)
                    elif permission_id == '174':
                        setattr(manage_user_role, 'can_delete_schedule', True)
                    elif permission_id == '175':
                        setattr(manage_user_role, 'can_view_unique_schedule', True)
                    elif permission_id == '176':
                        setattr(manage_user_role, 'can_status_schedule', True) 
                    elif permission_id == '273':
                        setattr(manage_user_role, 'can_filter_schedule', True)
                    elif permission_id == '274':
                        setattr(manage_user_role, 'can_import_schedule', True) 

                    elif permission_id == '177':
                        setattr(manage_user_role, 'can_view_near_by_location_category', True)
                    elif permission_id == '178':
                        setattr(manage_user_role, 'can_add_near_by_location_category', True)
                    elif permission_id == '179':
                        setattr(manage_user_role, 'can_edit_near_by_location_category', True)
                    elif permission_id == '180':
                        setattr(manage_user_role, 'can_delete_near_by_location_category', True)
                    elif permission_id == '181':
                        setattr(manage_user_role, 'can_status_near_by_location_category', True)

                    elif permission_id == '182':
                        setattr(manage_user_role, 'can_view_near_by_locations', True)
                    elif permission_id == '183':
                        setattr(manage_user_role, 'can_add_near_by_locations', True)
                    elif permission_id == '184':
                        setattr(manage_user_role, 'can_edit_near_by_locations', True)
                    elif permission_id == '185':
                        setattr(manage_user_role, 'can_delete_near_by_locations', True)
                    elif permission_id == '186':
                        setattr(manage_user_role, 'can_view_unique_near_by_locations', True)
                    elif permission_id == '187':
                        setattr(manage_user_role, 'can_status_near_by_locations', True)


                    elif permission_id == '188':
                        setattr(manage_user_role, 'can_export_near_by_locations', True)
                    elif permission_id == '189':
                        setattr(manage_user_role, 'can_filter_near_by_locations', True)
                    elif permission_id == '190':
                        setattr(manage_user_role, 'can_view_workers_type', True)
                    elif permission_id == '191':
                        setattr(manage_user_role, 'can_add_workers_type', True)
                    elif permission_id == '192':
                        setattr(manage_user_role, 'can_edit_workers_type', True)

                    elif permission_id == '193':
                        setattr(manage_user_role, 'can_delete_workers_type', True)
                    elif permission_id == '194':
                        setattr(manage_user_role, 'can_update_workers_type_status', True)
                    elif permission_id == '195':
                        setattr(manage_user_role, 'can_view_manage_workers', True)
                    elif permission_id == '196':
                        setattr(manage_user_role, 'can_add_manage_workers', True)
                    elif permission_id == '197':
                        setattr(manage_user_role, 'can_edit_manage_workers', True)
                    elif permission_id == '198':
                        setattr(manage_user_role, 'can_delete_manage_workers', True)

                    elif permission_id == '199':
                        setattr(manage_user_role, 'can_update_manage_workers', True)
                    elif permission_id == '200':
                        setattr(manage_user_role, 'can_view_unique_manage_workers', True)
                    elif permission_id == '201':
                        setattr(manage_user_role, 'can_update_manage_workers_status', True)
                    elif permission_id == '202':
                        setattr(manage_user_role, 'can_export_manage_workers', True)
                    elif permission_id == '203':
                        setattr(manage_user_role, 'can_filter_manage_workers', True)


                    elif permission_id == '204':
                        setattr(manage_user_role, 'can_view_guidelines_category', True)
                    elif permission_id == '205':
                        setattr(manage_user_role, 'can_add_guidelines_category', True)
                    elif permission_id == '206':
                        setattr(manage_user_role, 'can_edit_guidelines_category', True)
                    elif permission_id == '207':
                        setattr(manage_user_role, 'can_delete_guidelines_category', True)
                    elif permission_id == '208':
                        setattr(manage_user_role, 'can_update_guidelines_category_status', True)

                    elif permission_id == '209':
                        setattr(manage_user_role, 'can_view_guidelines', True)
                    elif permission_id == '210':
                        setattr(manage_user_role, 'can_add_guidelines', True)
                    elif permission_id == '211':
                        setattr(manage_user_role, 'can_edit_guidelines', True)
                    elif permission_id == '212':
                        setattr(manage_user_role, 'can_delete_guidelines', True)
                    elif permission_id == '213':
                        setattr(manage_user_role, 'can_view_unique_guidelines', True)
                    elif permission_id == '214':
                        setattr(manage_user_role, 'can_update_guidelines_status', True)

                    elif permission_id == '215':
                        setattr(manage_user_role, 'can_export_guidelines', True)
                    elif permission_id == '216':
                        setattr(manage_user_role, 'can_filter_guidelines', True) 

                    elif permission_id == '217':
                        setattr(manage_user_role, 'can_view_manage_user', True)
                    elif permission_id == '218':
                        setattr(manage_user_role, 'can_add_manage_user', True)
                    elif permission_id == '219':
                        setattr(manage_user_role, 'can_edit_manage_user', True) 
                    elif permission_id == '220':
                        setattr(manage_user_role, 'can_delete_manage_user', True)
                    elif permission_id == '221':
                        setattr(manage_user_role, 'can_view_unique_manage_user', True)
                    elif permission_id == '222':
                        setattr(manage_user_role, 'can_status_manage_user', True)
                    elif permission_id == '223':
                        setattr(manage_user_role, 'can_ter_status_manage_user', True)
                    elif permission_id == '224':
                        setattr(manage_user_role, 'can_rel_status_manage_user', True)
                    elif permission_id == '225':
                        setattr(manage_user_role, 'can_filter_manage_user', True)
                    elif permission_id == '226':
                        setattr(manage_user_role, 'can_export_manage_user', True)


                    elif permission_id == '227':
                        setattr(manage_user_role, 'can_view_manage_user_role', True)
                    elif permission_id == '228':
                        setattr(manage_user_role, 'can_add_manage_user_role', True)
                    elif permission_id == '229':
                        setattr(manage_user_role, 'can_edit_manage_user_role', True)
                    elif permission_id == '230':
                        setattr(manage_user_role, 'can_delete_manage_user_role', True)
                    elif permission_id == '231':
                        setattr(manage_user_role, 'can_view_unique_manage_user_role', True)
                    elif permission_id == '232':
                        setattr(manage_user_role, 'can_status_manage_user_role', True)


                    elif permission_id == '233':
                        setattr(manage_user_role, 'can_view_farmer_report', True)
                    elif permission_id == '234':
                        setattr(manage_user_role, 'can_view_unique_report', True)
                    elif permission_id == '235':
                        setattr(manage_user_role, 'can_filter_farmer_report', True)
                    elif permission_id == '236':
                        setattr(manage_user_role, 'can_export_farmer_report', True)

                    elif permission_id == '237':
                        setattr(manage_user_role, 'can_view_subscription_report', True)
                    elif permission_id == '238':
                        setattr(manage_user_role, 'can_view_unique_subscription_report', True)
                    elif permission_id == '239':
                        setattr(manage_user_role, 'can_filter_subscription_report', True)
                    elif permission_id == '240':
                        setattr(manage_user_role, 'can_export_subscription_report', True)

                    elif permission_id == '241':
                        setattr(manage_user_role, 'can_dashboard_count', True)
                    elif permission_id == '242':
                        setattr(manage_user_role, 'can_view_email_config', True)


                    elif permission_id == '243':
                        setattr(manage_user_role, 'can_add_email_config', True)
                    elif permission_id == '244':
                        setattr(manage_user_role, 'can_status_email_config', True)
                    elif permission_id == '245':
                        setattr(manage_user_role, 'can_edit_email_config', True)
                    elif permission_id == '246':
                        setattr(manage_user_role, 'can_delete_email_config', True)

                    elif permission_id == '247':
                        setattr(manage_user_role, 'can_view_sms_config', True)
                    elif permission_id == '248':
                        setattr(manage_user_role, 'can_edit_sms_config', True)
                    elif permission_id == '249':
                        setattr(manage_user_role, 'can_status_sms_config', True)
                    elif permission_id == '250':
                        setattr(manage_user_role, 'can_delete_sms_config', True)

 
                    elif permission_id == '251':
                        setattr(manage_user_role, 'can_view_inventory_category', True)
                    elif permission_id == '252':
                        setattr(manage_user_role, 'can_add_inventory_category', True)
                    elif permission_id == '253':
                        setattr(manage_user_role, 'can_status_inventory_category', True)
                    elif permission_id == '254':
                        setattr(manage_user_role, 'can_edit_inventory_category', True)
                    elif permission_id == '255':
                        setattr(manage_user_role, 'can_delete_inventory_category', True)


                    elif permission_id == '256':
                        setattr(manage_user_role, 'can_view_inventory_items', True)
                    elif permission_id == '257':
                        setattr(manage_user_role, 'can_add_inventory_items', True)
                    elif permission_id == '258':
                        setattr(manage_user_role, 'can_status_inventory_items', True)
                    elif permission_id == '259':
                        setattr(manage_user_role, 'can_edit_inventory_items', True)
                    elif permission_id == '260':
                        setattr(manage_user_role, 'can_delete_inventory_items', True)

                    elif permission_id == '261':
                        setattr(manage_user_role, 'can_view_document_category', True)
                    elif permission_id == '262':
                        setattr(manage_user_role, 'can_add_document_category', True)
                    elif permission_id == '263':
                        setattr(manage_user_role, 'can_status_document_category', True)
                    elif permission_id == '264':
                        setattr(manage_user_role, 'can_edit_document_category', True)
                    elif permission_id == '265':
                        setattr(manage_user_role, 'can_delete_document_category', True)
                    elif permission_id == '266':
                        setattr(manage_user_role, 'can_view_rental_availability', True)
                    elif permission_id == '267':
                        setattr(manage_user_role, 'can_filter_rental_availability', True)
                    elif permission_id == '268':
                        setattr(manage_user_role, 'can_export_rental_availability', True)

                # Save the manage user role with updated permissions
                manage_user_role.save()
                messages.success(request, "User Role Created Successfully.") 

                # Redirect to the role management page after saving the new role
                return redirect('sa_manage_role')

class UserRoleView(LoginRequiredMixin, View):
    def get(self, request, user_id):
        trigger_subscription()
        user_role = get_object_or_404(ManageUserRole, id=user_id)
        
        permissions_by_page = {
            'Settings':[
                {'id': 1, 'name': 'List', 'permission': 'can_view_general_setting'},
                {'id': 2, 'name': 'Edit', 'permission': 'can_edit_general_setting'},

                {'id': 3, 'name': 'Add', 'permission': 'can_add_country'},
                {'id': 4, 'name': 'Edit', 'permission': 'can_edit_country'},
                {'id': 5, 'name': 'View', 'permission': 'can_view_country'},
                {'id': 6, 'name': 'Delete', 'permission': 'can_delete_country'},
                {'id': 7, 'name': 'Status', 'permission': 'can_status_country'},

                {'id': 8, 'name': 'Add', 'permission': 'can_add_state'},
                {'id': 9, 'name': 'Edit', 'permission': 'can_edit_state'},
                {'id': 10, 'name': 'View', 'permission': 'can_view_state'},
                {'id': 11, 'name': 'Delete', 'permission': 'can_delete_state'},
                {'id': 12, 'name': 'Status', 'permission': 'can_status_state'},

                {'id': 13, 'name': 'Add', 'permission': 'can_add_city'},
                {'id': 14, 'name': 'Edit', 'permission': 'can_edit_city'},
                {'id': 15, 'name': 'View', 'permission': 'can_view_city'},
                {'id': 16, 'name': 'Delete', 'permission': 'can_delete_city'},
                {'id': 17, 'name': 'Status', 'permission': 'can_status_city'},

                {'id': 18, 'name': 'Add', 'permission': 'can_add_taluk'},
                {'id': 19, 'name': 'Edit', 'permission': 'can_edit_taluk'},
                {'id': 20, 'name': 'View', 'permission': 'can_view_taluk'},
                {'id': 21, 'name': 'Delete', 'permission': 'can_delete_taluk'},
                {'id': 22, 'name': 'Status', 'permission': 'can_status_taluk'},

                {'id': 23, 'name': 'Add', 'permission': 'can_add_village'},
                {'id': 24, 'name': 'Edit', 'permission': 'can_edit_village'},
                {'id': 25, 'name': 'View', 'permission': 'can_view_village'},
                {'id': 26, 'name': 'Delete', 'permission': 'can_delete_village'},
                {'id': 27, 'name': 'Status', 'permission': 'can_status_village'},
              
            ],

            'Data Management':[

                {'id': 28, 'name': 'Add', 'permission': 'can_add_land_unit'},
                {'id': 29, 'name': 'Edit', 'permission': 'can_edit_land_unit'},
                {'id': 30, 'name': 'View', 'permission': 'can_view_land_unit'},
                {'id': 31, 'name': 'Delete', 'permission': 'can_delete_land_unit'},
                {'id': 32, 'name': 'Status', 'permission': 'can_status_land_unit'},
              
                {'id': 33, 'name': 'Add', 'permission': 'can_add_area_unit'},
                {'id': 34, 'name': 'Edit', 'permission': 'can_edit_area_unit'},
                {'id': 35, 'name': 'View', 'permission': 'can_view_area_unit'},
                {'id': 36, 'name': 'Delete', 'permission': 'can_delete_area_unit'},
                {'id': 37, 'name': 'Status', 'permission': 'can_status_area_unit'},
              

                {'id': 38, 'name': 'Add', 'permission': 'can_add_soil_type'},
                {'id': 39, 'name': 'Edit', 'permission': 'can_edit_soil_type'},
                {'id': 40, 'name': 'View', 'permission': 'can_view_soil_type'},
                {'id': 41, 'name': 'Delete', 'permission': 'can_delete_soil_type'},
                {'id': 42, 'name': 'Status', 'permission': 'can_status_soil_type'},
              

                {'id': 43, 'name': 'Add', 'permission': 'can_add_crop_type'},
                {'id': 44, 'name': 'Edit', 'permission': 'can_edit_crop_type'},
                {'id': 45, 'name': 'View', 'permission': 'can_view_crop_type'},
                {'id': 46, 'name': 'Delete', 'permission': 'can_delete_crop_type'},
                {'id': 47, 'name': 'Status', 'permission': 'can_status_crop_type'},
              

                {'id': 48, 'name': 'Add', 'permission': 'can_add_quality'},
                {'id': 49, 'name': 'Edit', 'permission': 'can_edit_quality'},
                {'id': 50, 'name': 'View', 'permission': 'can_view_quality'},
                {'id': 51, 'name': 'Delete', 'permission': 'can_delete_quality'},
                {'id': 52, 'name': 'Status', 'permission': 'can_status_quality'},
              

                {'id': 53, 'name': 'Add', 'permission': 'can_add_crop'},
                {'id': 54, 'name': 'Edit', 'permission': 'can_edit_crop'},
                {'id': 55, 'name': 'View', 'permission': 'can_view_crop'},
                {'id': 56, 'name': 'Delete', 'permission': 'can_delete_crop'},
                {'id': 57, 'name': 'Status', 'permission': 'can_status_crop'},
              

                {'id': 58, 'name': 'Add', 'permission': 'can_add_product_type'},
                {'id': 59, 'name': 'Edit', 'permission': 'can_edit_product_type'},
                {'id': 60, 'name': 'View', 'permission': 'can_view_product_type'},
                {'id': 61, 'name': 'Delete', 'permission': 'can_delete_product_type'},
                {'id': 62, 'name': 'Status', 'permission': 'can_status_product_type'},
              

                {'id': 63, 'name': 'Add', 'permission': 'can_add_vehicle_category'},
                {'id': 64, 'name': 'Edit', 'permission': 'can_edit_vehicle_category'},
                {'id': 65, 'name': 'View', 'permission': 'can_view_vehicle_category'},
                {'id': 66, 'name': 'Delete', 'permission': 'can_delete_vehicle_category'},
                {'id': 67, 'name': 'Status', 'permission': 'can_status_vehicle_category'},
              

                {'id': 68, 'name': 'Add', 'permission': 'can_add_manage_vehicle'},
                {'id': 69, 'name': 'Edit', 'permission': 'can_edit_manage_vehicle'},
                {'id': 70, 'name': 'View', 'permission': 'can_view_manage_vehicle'},
                {'id': 71, 'name': 'Delete', 'permission': 'can_delete_manage_vehicle'},
                {'id': 72, 'name': 'Status', 'permission': 'can_status_manage_vehicle'},
              

                {'id': 73, 'name': 'Add', 'permission': 'can_add_machinery_category'},
                {'id': 74, 'name': 'Edit', 'permission': 'can_edit_machinery_category'},
                {'id': 75, 'name': 'View', 'permission': 'can_view_machinery_category'},
                {'id': 76, 'name': 'Delete', 'permission': 'can_delete_machinery_category'},
                {'id': 77, 'name': 'Status', 'permission': 'can_status_machinery_category'},
              

                {'id': 78, 'name': 'Add', 'permission': 'can_add_manage_machinery'},
                {'id': 79, 'name': 'Edit', 'permission': 'can_edit_manage_machinery'},
                {'id': 80, 'name': 'View', 'permission': 'can_view_manage_machinery'},
                {'id': 81, 'name': 'Delete', 'permission': 'can_delete_manage_machinery'},
                {'id': 82, 'name': 'Status', 'permission': 'can_status_manage_machinery'},
              

                {'id': 83, 'name': 'Add', 'permission': 'can_add_tool_category'},
                {'id': 84, 'name': 'Edit', 'permission': 'can_edit_tool_category'},
                {'id': 85, 'name': 'View', 'permission': 'can_view_tool_category'},
                {'id': 86, 'name': 'Delete', 'permission': 'can_delete_tool_category'},
                {'id': 87, 'name': 'Status', 'permission': 'can_status_tool_category'},
              

                {'id': 88, 'name': 'Add', 'permission': 'can_add_tool'},
                {'id': 89, 'name': 'Edit', 'permission': 'can_edit_tool'},
                {'id': 90, 'name': 'View', 'permission': 'can_view_tool'},
                {'id': 91, 'name': 'Delete', 'permission': 'can_delete_tool'},
                {'id': 92, 'name': 'Status', 'permission': 'can_status_tool'},
              

                {'id': 93, 'name': 'Add', 'permission': 'can_add_expense_category'},
                {'id': 94, 'name': 'Edit', 'permission': 'can_edit_expense_category'},
                {'id': 95, 'name': 'View', 'permission': 'can_view_expense_category'},
                {'id': 96, 'name': 'Delete', 'permission': 'can_delete_expense_category'},
                {'id': 97, 'name': 'Status', 'permission': 'can_status_expense_category'},
              

                {'id': 98, 'name': 'Add', 'permission': 'can_add_expense'},
                {'id': 99, 'name': 'Edit', 'permission': 'can_edit_expense'},
                {'id': 100, 'name': 'View', 'permission': 'can_view_expense'},
                {'id': 101, 'name': 'Delete', 'permission': 'can_delete_expense'},
                {'id': 102, 'name': 'Status', 'permission': 'can_status_expense'},
              

                {'id': 103, 'name': 'Add', 'permission': 'can_add_harvesting_type'},
                {'id': 104, 'name': 'Edit', 'permission': 'can_edit_harvesting_type'},
                {'id': 105, 'name': 'View', 'permission': 'can_view_harvesting_type'},
                {'id': 106, 'name': 'Delete', 'permission': 'can_delete_harvesting_type'},
                {'id': 107, 'name': 'Status', 'permission': 'can_status_harvesting_type'},
              

                {'id': 108, 'name': 'Add', 'permission': 'can_add_detection'},
                {'id': 109, 'name': 'Edit', 'permission': 'can_edit_detection'},
                {'id': 110, 'name': 'View', 'permission': 'can_view_detection'},
                {'id': 111, 'name': 'Delete', 'permission': 'can_delete_detection'},
                {'id': 112, 'name': 'Status', 'permission': 'can_status_detection'},
              

            ],

            'Farmer': [
                {'id': 113, 'name': 'List', 'permission': 'can_view_farmer'},
                {'id': 114, 'name': 'Add', 'permission': 'can_add_farmer'},
                {'id': 115, 'name': 'Edit', 'permission': 'can_edit_farmer'},
                {'id': 116, 'name': 'Delete', 'permission': 'can_delete_farmer'},
                {'id': 117, 'name': 'View', 'permission': 'can_view_unique_farmer'},
                {'id': 118, 'name': 'Export', 'permission': 'can_export_farmer_data'},
                {'id': 119, 'name': 'Filter', 'permission': 'can_filter_farmer_data'},
                {'id': 120, 'name': 'Status', 'permission': 'can_update_farmer_status'},
            ],

            'Package': [
                {'id': 121, 'name': 'List', 'permission': 'can_view_package'},
                {'id': 122, 'name': 'Add', 'permission': 'can_add_package'},
                {'id': 123, 'name': 'Edit', 'permission': 'can_edit_package'},
                {'id': 124, 'name': 'Delete', 'permission': 'can_delete_package'},
                {'id': 125, 'name': 'View', 'permission': 'can_view_unique_package'},
            ],
            'Subscription': [
                {'id': 126, 'name': 'List', 'permission': 'can_view_subscription'},
                {'id': 127, 'name': 'Add', 'permission': 'can_add_subscription'},
                {'id': 128, 'name': 'Edit', 'permission': 'can_edit_subscription'},
                {'id': 129, 'name': 'Delete', 'permission': 'can_delete_subscription'},
                {'id': 130, 'name': 'View', 'permission': 'can_view_unique_subscription'},
                {'id': 131, 'name': 'Active Plan', 'permission': 'can_activeplan_subscription'},
                {'id': 132, 'name': 'Renewal Plan', 'permission': 'can_renewalplan_subscription'},
                {'id': 133, 'name': 'Filter', 'permission': 'can_filter_subscription'},
                {'id': 134, 'name': 'Export', 'permission': 'can_export_subscription'},                
            ],
            'MarketPriceChart': [

                {'id': 135, 'name': 'List', 'permission': 'can_view_manage_product'},
                {'id': 136, 'name': 'Add', 'permission': 'can_add_manage_product'},
                {'id': 137, 'name': 'Edit', 'permission': 'can_edit_manage_product'},
                {'id': 138, 'name': 'Delete', 'permission': 'can_delete_manage_product'},
                {'id': 139, 'name': 'Update', 'permission': 'can_update_manage_product'},
                {'id': 140, 'name': 'Graph', 'permission': 'can_graph_manage_product'},
                {'id': 141, 'name': 'Filter', 'permission': 'can_filter_manage_product'},
                {'id': 142, 'name': 'Staff', 'permission': 'can_staff_manage_product'},

                {'id': 143, 'name': 'List', 'permission': 'can_view_market_report'},
                {'id': 144, 'name': 'Edit', 'permission': 'can_edit_market_report'},
                {'id': 145, 'name': 'Graph', 'permission': 'can_graph_market_report'},
                {'id': 146, 'name': 'Filter', 'permission': 'can_filter_market_report'},

                {'id': 147, 'name': 'List', 'permission': 'can_view_product_market_report'},
                {'id': 148, 'name': 'Edit', 'permission': 'can_edit_product_market_report'},
                {'id': 149, 'name': 'Graph', 'permission': 'can_graph_product_market_report'},
                {'id': 150, 'name': 'Filter', 'permission': 'can_filter_product_market_report'},
            ],
            'Market Management': [
                {'id': 151, 'name': 'List', 'permission': 'can_view_market'},
                {'id': 152, 'name': 'Add', 'permission': 'can_add_market'},
                {'id': 153, 'name': 'Edit', 'permission': 'can_edit_market'},
                {'id': 154, 'name': 'Delete', 'permission': 'can_delete_market'},
                {'id': 155, 'name': 'List', 'permission': 'can_view_unique_market'},
                {'id': 156, 'name': 'Status', 'permission': 'can_status_market'},
                {'id': 157, 'name': 'Export', 'permission': 'can_export_market'},
                {'id': 158, 'name': 'Filter', 'permission': 'can_filter_market'},

                {'id': 159, 'name': 'View', 'permission': 'can_view_allocate_market'},
                {'id': 160, 'name': 'Status', 'permission': 'can_add_allocate_market'},
                {'id': 161, 'name': 'Export', 'permission': 'can_edit_allocate_market'},
                {'id': 162, 'name': 'Filter', 'permission': 'can_delete_allocate_market'},
                {'id': 163, 'name': 'View', 'permission': 'can_view_unique_allocate_market'},
                {'id': 164, 'name': 'Status', 'permission': 'can_status_allocate_market'},
                {'id': 165, 'name': 'Export', 'permission': 'can_export_allocate_market'}, 
            
            ],

            'Schedule Management': [
                {'id': 166, 'name': 'List', 'permission': 'can_view_schedule_activity_type'},
                {'id': 167, 'name': 'Add', 'permission': 'can_add_schedule_activity_type'},
                {'id': 168, 'name': 'Edit', 'permission': 'can_edit_schedule_activity_type'},
                {'id': 169, 'name': 'Delete', 'permission': 'can_delete_schedule_activity_type'},
                {'id': 170, 'name': 'Status', 'permission': 'can_status_schedule_activity_type'},

                {'id': 171, 'name': 'List', 'permission': 'can_view_schedule'},
                {'id': 172, 'name': 'Add', 'permission': 'can_add_schedule'},
                {'id': 173, 'name': 'Edit', 'permission': 'can_edit_schedule'},
                {'id': 174, 'name': 'Delete', 'permission': 'can_delete_schedule'},
                {'id': 175, 'name': 'View', 'permission': 'can_view_unique_schedule'},
                {'id': 176, 'name': 'Status', 'permission': 'can_status_schedule'},
            ],

            "NearByLocations": [
                {"id": 177, "name": "List", "permission": "can_view_near_by_location_category"},
                {"id": 178, "name": "Add", "permission": "can_add_near_by_location_category"},
                {"id": 179, "name": "Edit", "permission": "can_edit_near_by_location_category"},
                {"id": 180, "name": "Delete", "permission": "can_delete_near_by_location_category"},
                {"id": 181, "name": "Status", "permission": "can_status_near_by_location_category"},

                {"id": 182, "name": "List", "permission": "can_view_near_by_locations"},
                {"id": 183, "name": "Add", "permission": "can_add_near_by_locations"},
                {"id": 184, "name": "Edit", "permission": "can_edit_near_by_locations"},
                {"id": 185, "name": "Delete", "permission": "can_delete_near_by_locations"},
                {"id": 186, "name": "View", "permission": "can_view_unique_near_by_locations"},
                {"id": 187, "name": "Status", "permission": "can_status_near_by_locations"},
                {"id": 188, "name": "Export", "permission": "can_export_near_by_locations"},
                {"id": 189, "name": "Filter", "permission": "can_filter_near_by_locations"},
                
            ],

            "Workers Management": [

                {"id": 190, "name": "List", "permission": "can_view_workers_type"},
                {"id": 191, "name": "Add", "permission": "can_add_workers_type"},
                {"id": 192, "name": "Edit", "permission": "can_edit_workers_type"},
                {"id": 193, "name": "Delete", "permission": "can_delete_workers_type"},
                {"id": 194, "name": "Status", "permission": "can_update_workers_type_status"},
            
                {"id": 195, "name": "List", "permission": "can_view_manage_workers"},
                {"id": 196, "name": "Add", "permission": "can_add_manage_workers"},
                {"id": 197, "name": "Edit", "permission": "can_edit_manage_workers"},
                {"id": 198, "name": "Delete", "permission": "can_delete_manage_workers"},
                {"id": 199, "name": "Update", "permission": "can_update_manage_workers"},
                {"id": 200, "name": "View", "permission": "can_view_unique_manage_workers"},
                {"id": 201, "name": "Status", "permission": "can_update_manage_workers_status"},
                {"id": 202, "name": "Export", "permission": "can_export_manage_workers"},                
                {"id": 203, "name": "Filter", "permission": "can_filter_manage_workers"},
            
            ],
            "Guidelines Management": [

                {"id": 204, "name": "List", "permission": "can_view_guidelines_category"},
                {"id": 205, "name": "Add", "permission": "can_add_guidelines_category"},
                {"id": 206, "name": "Edit", "permission": "can_edit_guidelines_category"},
                {"id": 207, "name": "Delete", "permission": "can_delete_guidelines_category"},
                {"id": 208, "name": "Status", "permission": "can_update_guidelines_category_status"},
            
                {"id": 209, "name": "List", "permission": "can_view_guidelines"},
                {"id": 210, "name": "Add", "permission": "can_add_guidelines"},
                {"id": 211, "name": "Edit", "permission": "can_edit_guidelines"},
                {"id": 212, "name": "Delete", "permission": "can_delete_guidelines"},
                {"id": 213, "name": "View", "permission": "can_view_unique_guidelines"},
                {"id": 214, "name": "Status", "permission": "can_update_guidelines_status"},
                {"id": 215, "name": "Export", "permission": "can_export_guidelines"},                
                {"id": 216, "name": "Filter", "permission": "can_filter_guidelines"},

            ],

             "User Management": [
                 
                {"id": 217, "name": "List", "permission": "can_view_manage_user"},
                {"id": 218, "name": "Add", "permission": "can_add_manage_user"},
                {"id": 219, "name": "Edit", "permission": "can_edit_manage_user"},
                {"id": 220, "name": "Delete", "permission": "can_delete_manage_user"},
                {"id": 221, "name": "Status", "permission": "can_view_unique_manage_user"},
                {"id": 222, "name": "List", "permission": "can_status_manage_user"},
                {"id": 223, "name": "Add", "permission": "can_ter_status_manage_user"},
                {"id": 224, "name": "Edit", "permission": "can_rel_status_manage_user"},
                {"id": 225, "name": "Delete", "permission": "can_filter_manage_user"},
                {"id": 226, "name": "View", "permission": "can_export_manage_user"}, 

                {"id": 227, "name": "List", "permission": "can_view_manage_user_role"},
                {"id": 228, "name": "Add", "permission": "can_add_manage_user_role"},
                {"id": 229, "name": "Edit", "permission": "can_edit_manage_user_role"},
                {"id": 230, "name": "Delete", "permission": "can_delete_manage_user_role"},
                {"id": 231, "name": "View", "permission": "can_view_unique_manage_user_role"},
                {"id": 232, "name": "Status", "permission": "can_status_manage_user_role"},
            
            ],

            "Report": [

                {"id": 233, "name": "List", "permission": "can_view_farmer_report"},
                {"id": 234, "name": "View", "permission": "can_view_unique_report"},
                {"id": 235, "name": "Filter", "permission": "can_filter_farmer_report"},
                {"id": 236, "name": "Export", "permission": "can_export_farmer_report"},


                {"id": 237, "name": "List", "permission": "can_view_subscription_report"},
                {"id": 238, "name": "View", "permission": "can_view_unique_subscription_report"},
                {"id": 237, "name": "Filter", "permission": "can_filter_subscription_report"},
                {"id": 238, "name": "Export", "permission": "can_export_subscription_report"},
            
            ],

            "Dashboard": [
                {"id": 241, "name": "View", "permission": "can_dashboard_count"}, 
            ],

            "Email Config": [ 
                {"id": 242, "name": "List", "permission": "can_view_email_config"},
                {"id": 243, "name": "Add", "permission": "can_add_email_config"},
                {"id": 244, "name": "Status", "permission": "can_status_email_config"},
                {"id": 245, "name": "Edit", "permission": "can_edit_email_config"},
                {"id": 246, "name": "Delete", "permission": "can_delete_email_config"},
 
            ],

            "SMS Config": [  

                {"id": 247, "name": "List", "permission": "can_view_sms_config"},
                {"id": 248, "name": "Edit", "permission": "can_edit_sms_config"},
                {"id": 249, "name": "Status", "permission": "can_status_sms_config"},
                {"id": 250, "name": "Delete", "permission": "can_delete_sms_config"},
            
            ],

            "Inventory Category":[
                    {"id": 251, "name": "List", "permission": "can_view_inventory_category"},
                    {"id": 252, "name": "Add", "permission": "can_add_inventory_category"},
                    {"id": 253, "name": "Status", "permission": "can_status_inventory_category"},
                    {"id": 254, "name": "Edit", "permission": "can_edit_inventory_category"},
                    {"id": 255, "name": "Delete", "permission": "can_delete_inventory_category"},
            ],
            "Inventory Items":[
                {"id": 256, "name": "List", "permission": "can_view_inventory_items"},
                {"id": 257, "name": "Add", "permission": "can_add_inventory_items"},
                {"id": 258, "name": "Status", "permission": "can_status_inventory_items"},
                {"id": 259, "name": "Edit", "permission": "can_edit_inventory_items"},
                {"id": 260, "name": "Delete", "permission": "can_delete_inventory_items"},
            ],

                "Document Category":[
                {"id": 261, "name": "List", "permission": "can_view_document_category"},
                {"id": 262, "name": "Add", "permission": "can_add_document_category"},
                {"id": 263, "name": "Status", "permission": "can_status_document_category"},
                {"id": 264, "name": "Edit", "permission": "can_edit_document_category"},
                {"id": 265, "name": "Delete", "permission": "can_delete_document_category"},
            ],
            "Rental Availability":[
                {"id": 266, "name": "List", "permission": "can_view_rental_availability"},
                {"id": 267, "name": "Filter", "permission": "can_filter_rental_availability"},
                {"id": 268, "name": "Export", "permission": "can_export_rental_availability"}
            ],
        }


        # Retrieve the role's permissions and prepare a dictionary for them
        role_permissions = {}
        for page, permissions in permissions_by_page.items():
            for permission in permissions:
                permission_key = permission['permission']
                # Check if the ManageUserRole for the user has this permission
                current_permission = getattr(user_role, permission_key, False)
                role_permissions[permission_key] = current_permission

        # Prepare context to send to the template
        context = {
            'user_role': user_role,
            'permissions_by_page': permissions_by_page,
            'role_permissions': role_permissions,  # Current permissions for the role
        }

        # Render the page with user role details and permissions
        return render(request, 'pages/super_admin/users_management/manage_role/view.html', context)

class UserRoleUpdate(LoginRequiredMixin,View):
    def get(self, request, user_id):
        trigger_subscription()
        user_role = get_object_or_404(ManageUserRole, id=user_id)
        roles = Role.objects.filter(Q(status=0) | Q(status=1))

              # Permissions structure
        permissions_by_page = {
            'Settings':[
                {'id': 1, 'name': 'List', 'permission': 'can_view_general_setting'},
                {'id': 2, 'name': 'Edit', 'permission': 'can_edit_general_setting'},

                {'id': 3, 'name': 'Add', 'permission': 'can_add_country'},
                {'id': 4, 'name': 'Edit', 'permission': 'can_edit_country'},
                {'id': 5, 'name': 'View', 'permission': 'can_view_country'},
                {'id': 6, 'name': 'Delete', 'permission': 'can_delete_country'},
                {'id': 7, 'name': 'Status', 'permission': 'can_status_country'},

                {'id': 8, 'name': 'Add', 'permission': 'can_add_state'},
                {'id': 9, 'name': 'Edit', 'permission': 'can_edit_state'},
                {'id': 10, 'name': 'View', 'permission': 'can_view_state'},
                {'id': 11, 'name': 'Delete', 'permission': 'can_delete_state'},
                {'id': 12, 'name': 'Status', 'permission': 'can_status_state'},

                {'id': 13, 'name': 'Add', 'permission': 'can_add_city'},
                {'id': 14, 'name': 'Edit', 'permission': 'can_edit_city'},
                {'id': 15, 'name': 'View', 'permission': 'can_view_city'},
                {'id': 16, 'name': 'Delete', 'permission': 'can_delete_city'},
                {'id': 17, 'name': 'Status', 'permission': 'can_status_city'},

                {'id': 18, 'name': 'Add', 'permission': 'can_add_taluk'},
                {'id': 19, 'name': 'Edit', 'permission': 'can_edit_taluk'},
                {'id': 20, 'name': 'View', 'permission': 'can_view_taluk'},
                {'id': 21, 'name': 'Delete', 'permission': 'can_delete_taluk'},
                {'id': 22, 'name': 'Status', 'permission': 'can_status_taluk'},

                {'id': 23, 'name': 'Add', 'permission': 'can_add_village'},
                {'id': 24, 'name': 'Edit', 'permission': 'can_edit_village'},
                {'id': 25, 'name': 'View', 'permission': 'can_view_village'},
                {'id': 26, 'name': 'Delete', 'permission': 'can_delete_village'},
                {'id': 27, 'name': 'Status', 'permission': 'can_status_village'},
              
            ],

            'Data Management':[

                {'id': 28, 'name': 'Add', 'permission': 'can_add_land_unit'},
                {'id': 29, 'name': 'Edit', 'permission': 'can_edit_land_unit'},
                {'id': 30, 'name': 'View', 'permission': 'can_view_land_unit'},
                {'id': 31, 'name': 'Delete', 'permission': 'can_delete_land_unit'},
                {'id': 32, 'name': 'Status', 'permission': 'can_status_land_unit'},
              
                {'id': 33, 'name': 'Add', 'permission': 'can_add_area_unit'},
                {'id': 34, 'name': 'Edit', 'permission': 'can_edit_area_unit'},
                {'id': 35, 'name': 'View', 'permission': 'can_view_area_unit'},
                {'id': 36, 'name': 'Delete', 'permission': 'can_delete_area_unit'},
                {'id': 37, 'name': 'Status', 'permission': 'can_status_area_unit'},
              

                {'id': 38, 'name': 'Add', 'permission': 'can_add_soil_type'},
                {'id': 39, 'name': 'Edit', 'permission': 'can_edit_soil_type'},
                {'id': 40, 'name': 'View', 'permission': 'can_view_soil_type'},
                {'id': 41, 'name': 'Delete', 'permission': 'can_delete_soil_type'},
                {'id': 42, 'name': 'Status', 'permission': 'can_status_soil_type'},
              

                {'id': 43, 'name': 'Add', 'permission': 'can_add_crop_type'},
                {'id': 44, 'name': 'Edit', 'permission': 'can_edit_crop_type'},
                {'id': 45, 'name': 'View', 'permission': 'can_view_crop_type'},
                {'id': 46, 'name': 'Delete', 'permission': 'can_delete_crop_type'},
                {'id': 47, 'name': 'Status', 'permission': 'can_status_crop_type'},
              

                {'id': 48, 'name': 'Add', 'permission': 'can_add_quality'},
                {'id': 49, 'name': 'Edit', 'permission': 'can_edit_quality'},
                {'id': 50, 'name': 'View', 'permission': 'can_view_quality'},
                {'id': 51, 'name': 'Delete', 'permission': 'can_delete_quality'},
                {'id': 52, 'name': 'Status', 'permission': 'can_status_quality'},
              

                {'id': 53, 'name': 'Add', 'permission': 'can_add_crop'},
                {'id': 54, 'name': 'Edit', 'permission': 'can_edit_crop'},
                {'id': 55, 'name': 'View', 'permission': 'can_view_crop'},
                {'id': 56, 'name': 'Delete', 'permission': 'can_delete_crop'},
                {'id': 57, 'name': 'Status', 'permission': 'can_status_crop'},
              

                {'id': 58, 'name': 'Add', 'permission': 'can_add_product_type'},
                {'id': 59, 'name': 'Edit', 'permission': 'can_edit_product_type'},
                {'id': 60, 'name': 'View', 'permission': 'can_view_product_type'},
                {'id': 61, 'name': 'Delete', 'permission': 'can_delete_product_type'},
                {'id': 62, 'name': 'Status', 'permission': 'can_status_product_type'},
              

                {'id': 63, 'name': 'Add', 'permission': 'can_add_vehicle_category'},
                {'id': 64, 'name': 'Edit', 'permission': 'can_edit_vehicle_category'},
                {'id': 65, 'name': 'View', 'permission': 'can_view_vehicle_category'},
                {'id': 66, 'name': 'Delete', 'permission': 'can_delete_vehicle_category'},
                {'id': 67, 'name': 'Status', 'permission': 'can_status_vehicle_category'},
              

                {'id': 68, 'name': 'Add', 'permission': 'can_add_manage_vehicle'},
                {'id': 69, 'name': 'Edit', 'permission': 'can_edit_manage_vehicle'},
                {'id': 70, 'name': 'View', 'permission': 'can_view_manage_vehicle'},
                {'id': 71, 'name': 'Delete', 'permission': 'can_delete_manage_vehicle'},
                {'id': 72, 'name': 'Status', 'permission': 'can_status_manage_vehicle'},
              

                {'id': 73, 'name': 'Add', 'permission': 'can_add_machinery_category'},
                {'id': 74, 'name': 'Edit', 'permission': 'can_edit_machinery_category'},
                {'id': 75, 'name': 'View', 'permission': 'can_view_machinery_category'},
                {'id': 76, 'name': 'Delete', 'permission': 'can_delete_machinery_category'},
                {'id': 77, 'name': 'Status', 'permission': 'can_status_machinery_category'},
              

                {'id': 78, 'name': 'Add', 'permission': 'can_add_manage_machinery'},
                {'id': 79, 'name': 'Edit', 'permission': 'can_edit_manage_machinery'},
                {'id': 80, 'name': 'View', 'permission': 'can_view_manage_machinery'},
                {'id': 81, 'name': 'Delete', 'permission': 'can_delete_manage_machinery'},
                {'id': 82, 'name': 'Status', 'permission': 'can_status_manage_machinery'},
              

                {'id': 83, 'name': 'Add', 'permission': 'can_add_tool_category'},
                {'id': 84, 'name': 'Edit', 'permission': 'can_edit_tool_category'},
                {'id': 85, 'name': 'View', 'permission': 'can_view_tool_category'},
                {'id': 86, 'name': 'Delete', 'permission': 'can_delete_tool_category'},
                {'id': 87, 'name': 'Status', 'permission': 'can_status_tool_category'},
              

                {'id': 88, 'name': 'Add', 'permission': 'can_add_tool'},
                {'id': 89, 'name': 'Edit', 'permission': 'can_edit_tool'},
                {'id': 90, 'name': 'View', 'permission': 'can_view_tool'},
                {'id': 91, 'name': 'Delete', 'permission': 'can_delete_tool'},
                {'id': 92, 'name': 'Status', 'permission': 'can_status_tool'},
              

                {'id': 93, 'name': 'Add', 'permission': 'can_add_expense_category'},
                {'id': 94, 'name': 'Edit', 'permission': 'can_edit_expense_category'},
                {'id': 95, 'name': 'View', 'permission': 'can_view_expense_category'},
                {'id': 96, 'name': 'Delete', 'permission': 'can_delete_expense_category'},
                {'id': 97, 'name': 'Status', 'permission': 'can_status_expense_category'},
              

                {'id': 98, 'name': 'Add', 'permission': 'can_add_expense'},
                {'id': 99, 'name': 'Edit', 'permission': 'can_edit_expense'},
                {'id': 100, 'name': 'View', 'permission': 'can_view_expense'},
                {'id': 101, 'name': 'Delete', 'permission': 'can_delete_expense'},
                {'id': 102, 'name': 'Status', 'permission': 'can_status_expense'},
              

                {'id': 103, 'name': 'Add', 'permission': 'can_add_harvesting_type'},
                {'id': 104, 'name': 'Edit', 'permission': 'can_edit_harvesting_type'},
                {'id': 105, 'name': 'View', 'permission': 'can_view_harvesting_type'},
                {'id': 106, 'name': 'Delete', 'permission': 'can_delete_harvesting_type'},
                {'id': 107, 'name': 'Status', 'permission': 'can_status_harvesting_type'},
              

                {'id': 108, 'name': 'Add', 'permission': 'can_add_detection'},
                {'id': 109, 'name': 'Edit', 'permission': 'can_edit_detection'},
                {'id': 110, 'name': 'View', 'permission': 'can_view_detection'},
                {'id': 111, 'name': 'Delete', 'permission': 'can_delete_detection'},
                {'id': 112, 'name': 'Status', 'permission': 'can_status_detection'},
              

            ],

            'Farmer': [
                {'id': 113, 'name': 'List', 'permission': 'can_view_farmer'},
                {'id': 114, 'name': 'Add', 'permission': 'can_add_farmer'},
                {'id': 115, 'name': 'Edit', 'permission': 'can_edit_farmer'},
                {'id': 116, 'name': 'Delete', 'permission': 'can_delete_farmer'},
                {'id': 117, 'name': 'View', 'permission': 'can_view_unique_farmer'},
                {'id': 118, 'name': 'Export', 'permission': 'can_export_farmer_data'},
                {'id': 119, 'name': 'Filter', 'permission': 'can_filter_farmer_data'},
                {'id': 120, 'name': 'Status', 'permission': 'can_update_farmer_status'},
            ],

            'Package': [
                {'id': 121, 'name': 'List', 'permission': 'can_view_package'},
                {'id': 122, 'name': 'Add', 'permission': 'can_add_package'},
                {'id': 123, 'name': 'Edit', 'permission': 'can_edit_package'},
                {'id': 124, 'name': 'Delete', 'permission': 'can_delete_package'},
                {'id': 125, 'name': 'View', 'permission': 'can_view_unique_package'},
            ],
            'Subscription': [
                {'id': 126, 'name': 'List', 'permission': 'can_view_subscription'},
                {'id': 127, 'name': 'Add', 'permission': 'can_add_subscription'},
                {'id': 128, 'name': 'Edit', 'permission': 'can_edit_subscription'},
                {'id': 129, 'name': 'Delete', 'permission': 'can_delete_subscription'},
                {'id': 130, 'name': 'View', 'permission': 'can_view_unique_subscription'},
                {'id': 131, 'name': 'Active Plan', 'permission': 'can_activeplan_subscription'},
                {'id': 132, 'name': 'Renewal Plan', 'permission': 'can_renewalplan_subscription'},
                {'id': 133, 'name': 'Filter', 'permission': 'can_filter_subscription'},
                {'id': 134, 'name': 'Export', 'permission': 'can_export_subscription'},                
            ],
            'MarketPriceChart': [

                {'id': 135, 'name': 'List', 'permission': 'can_view_manage_product'},
                {'id': 136, 'name': 'Add', 'permission': 'can_add_manage_product'},
                {'id': 137, 'name': 'Edit', 'permission': 'can_edit_manage_product'},
                {'id': 138, 'name': 'Delete', 'permission': 'can_delete_manage_product'},
                {'id': 139, 'name': 'Update', 'permission': 'can_update_manage_product'},
                {'id': 140, 'name': 'Graph', 'permission': 'can_graph_manage_product'},
                {'id': 141, 'name': 'Filter', 'permission': 'can_filter_manage_product'},
                {'id': 142, 'name': 'Staff', 'permission': 'can_staff_manage_product'},

                {'id': 143, 'name': 'List', 'permission': 'can_view_market_report'},
                {'id': 144, 'name': 'Edit', 'permission': 'can_edit_market_report'},
                {'id': 145, 'name': 'Graph', 'permission': 'can_graph_market_report'},
                {'id': 146, 'name': 'Filter', 'permission': 'can_filter_market_report'},

                {'id': 147, 'name': 'List', 'permission': 'can_view_product_market_report'},
                {'id': 148, 'name': 'Edit', 'permission': 'can_edit_product_market_report'},
                {'id': 149, 'name': 'Graph', 'permission': 'can_graph_product_market_report'},
                {'id': 150, 'name': 'Filter', 'permission': 'can_filter_product_market_report'},
            ],
            'Market Management': [
                {'id': 151, 'name': 'List', 'permission': 'can_view_market'},
                {'id': 152, 'name': 'Add', 'permission': 'can_add_market'},
                {'id': 153, 'name': 'Edit', 'permission': 'can_edit_market'},
                {'id': 154, 'name': 'Delete', 'permission': 'can_delete_market'},
                {'id': 155, 'name': 'List', 'permission': 'can_view_unique_market'},
                {'id': 156, 'name': 'Status', 'permission': 'can_status_market'},
                {'id': 157, 'name': 'Export', 'permission': 'can_export_market'},
                {'id': 158, 'name': 'Filter', 'permission': 'can_filter_market'},

                {'id': 159, 'name': 'View', 'permission': 'can_view_allocate_market'},
                {'id': 160, 'name': 'Status', 'permission': 'can_add_allocate_market'},
                {'id': 161, 'name': 'Export', 'permission': 'can_edit_allocate_market'},
                {'id': 162, 'name': 'Filter', 'permission': 'can_delete_allocate_market'},
                {'id': 163, 'name': 'View', 'permission': 'can_view_unique_allocate_market'},
                {'id': 164, 'name': 'Status', 'permission': 'can_status_allocate_market'},
                {'id': 165, 'name': 'Export', 'permission': 'can_export_allocate_market'}, 
            
            ],

            'Schedule Management': [
                {'id': 166, 'name': 'List', 'permission': 'can_view_schedule_activity_type'},
                {'id': 167, 'name': 'Add', 'permission': 'can_add_schedule_activity_type'},
                {'id': 168, 'name': 'Edit', 'permission': 'can_edit_schedule_activity_type'},
                {'id': 169, 'name': 'Delete', 'permission': 'can_delete_schedule_activity_type'},
                {'id': 170, 'name': 'Status', 'permission': 'can_status_schedule_activity_type'},

                {'id': 171, 'name': 'List', 'permission': 'can_view_schedule'},
                {'id': 172, 'name': 'Add', 'permission': 'can_add_schedule'},
                {'id': 173, 'name': 'Edit', 'permission': 'can_edit_schedule'},
                {'id': 174, 'name': 'Delete', 'permission': 'can_delete_schedule'},
                {'id': 175, 'name': 'View', 'permission': 'can_view_unique_schedule'},
                {'id': 176, 'name': 'Status', 'permission': 'can_status_schedule'},
            ],

            "NearByLocations": [
                {"id": 177, "name": "List", "permission": "can_view_near_by_location_category"},
                {"id": 178, "name": "Add", "permission": "can_add_near_by_location_category"},
                {"id": 179, "name": "Edit", "permission": "can_edit_near_by_location_category"},
                {"id": 180, "name": "Delete", "permission": "can_delete_near_by_location_category"},
                {"id": 181, "name": "Status", "permission": "can_status_near_by_location_category"},

                {"id": 182, "name": "List", "permission": "can_view_near_by_locations"},
                {"id": 183, "name": "Add", "permission": "can_add_near_by_locations"},
                {"id": 184, "name": "Edit", "permission": "can_edit_near_by_locations"},
                {"id": 185, "name": "Delete", "permission": "can_delete_near_by_locations"},
                {"id": 186, "name": "View", "permission": "can_view_unique_near_by_locations"},
                {"id": 187, "name": "Status", "permission": "can_status_near_by_locations"},
                {"id": 188, "name": "Export", "permission": "can_export_near_by_locations"},
                {"id": 189, "name": "Filter", "permission": "can_filter_near_by_locations"},
                
            ],

            "Workers Management": [

                {"id": 190, "name": "List", "permission": "can_view_workers_type"},
                {"id": 191, "name": "Add", "permission": "can_add_workers_type"},
                {"id": 192, "name": "Edit", "permission": "can_edit_workers_type"},
                {"id": 193, "name": "Delete", "permission": "can_delete_workers_type"},
                {"id": 194, "name": "Status", "permission": "can_update_workers_type_status"},
            
                {"id": 195, "name": "List", "permission": "can_view_manage_workers"},
                {"id": 196, "name": "Add", "permission": "can_add_manage_workers"},
                {"id": 197, "name": "Edit", "permission": "can_edit_manage_workers"},
                {"id": 198, "name": "Delete", "permission": "can_delete_manage_workers"},
                {"id": 199, "name": "Update", "permission": "can_update_manage_workers"},
                {"id": 200, "name": "View", "permission": "can_view_unique_manage_workers"},
                {"id": 201, "name": "Status", "permission": "can_update_manage_workers_status"},
                {"id": 202, "name": "Export", "permission": "can_export_manage_workers"},                
                {"id": 203, "name": "Filter", "permission": "can_filter_manage_workers"},
            
            ],
            "Guidelines Management": [

                {"id": 204, "name": "List", "permission": "can_view_guidelines_category"},
                {"id": 205, "name": "Add", "permission": "can_add_guidelines_category"},
                {"id": 206, "name": "Edit", "permission": "can_edit_guidelines_category"},
                {"id": 207, "name": "Delete", "permission": "can_delete_guidelines_category"},
                {"id": 208, "name": "Status", "permission": "can_update_guidelines_category_status"},
            
                {"id": 209, "name": "List", "permission": "can_view_guidelines"},
                {"id": 210, "name": "Add", "permission": "can_add_guidelines"},
                {"id": 211, "name": "Edit", "permission": "can_edit_guidelines"},
                {"id": 212, "name": "Delete", "permission": "can_delete_guidelines"},
                {"id": 213, "name": "View", "permission": "can_view_unique_guidelines"},
                {"id": 214, "name": "Status", "permission": "can_update_guidelines_status"},
                {"id": 215, "name": "Export", "permission": "can_export_guidelines"},                
                {"id": 216, "name": "Filter", "permission": "can_filter_guidelines"},

            ],

             "User Management": [
                 
                {"id": 217, "name": "List", "permission": "can_view_manage_user"},
                {"id": 218, "name": "Add", "permission": "can_add_manage_user"},
                {"id": 219, "name": "Edit", "permission": "can_edit_manage_user"},
                {"id": 220, "name": "Delete", "permission": "can_delete_manage_user"},
                {"id": 221, "name": "Status", "permission": "can_view_unique_manage_user"},
                {"id": 222, "name": "List", "permission": "can_status_manage_user"},
                {"id": 223, "name": "Add", "permission": "can_ter_status_manage_user"},
                {"id": 224, "name": "Edit", "permission": "can_rel_status_manage_user"},
                {"id": 225, "name": "Delete", "permission": "can_filter_manage_user"},
                {"id": 226, "name": "View", "permission": "can_export_manage_user"}, 

                {"id": 227, "name": "List", "permission": "can_view_manage_user_role"},
                {"id": 228, "name": "Add", "permission": "can_add_manage_user_role"},
                {"id": 229, "name": "Edit", "permission": "can_edit_manage_user_role"},
                {"id": 230, "name": "Delete", "permission": "can_delete_manage_user_role"},
                {"id": 231, "name": "View", "permission": "can_view_unique_manage_user_role"},
                {"id": 232, "name": "Status", "permission": "can_status_manage_user_role"},
            
            ],

            "Report": [

                {"id": 233, "name": "List", "permission": "can_view_farmer_report"},
                {"id": 234, "name": "View", "permission": "can_view_unique_report"},
                {"id": 235, "name": "Filter", "permission": "can_filter_farmer_report"},
                {"id": 236, "name": "Export", "permission": "can_export_farmer_report"},


                {"id": 237, "name": "List", "permission": "can_view_subscription_report"},
                {"id": 238, "name": "View", "permission": "can_view_unique_subscription_report"},
                {"id": 239, "name": "Filter", "permission": "can_filter_subscription_report"},
                {"id": 240, "name": "Export", "permission": "can_export_subscription_report"},
            
            ],

            "Dashboard": [
                {"id": 241, "name": "View", "permission": "can_dashboard_count"}, 
            ],

            "Email Config": [ 
                {"id": 242, "name": "List", "permission": "can_view_email_config"},
                {"id": 243, "name": "Add", "permission": "can_add_email_config"},
                {"id": 244, "name": "Status", "permission": "can_status_email_config"},
                {"id": 245, "name": "Edit", "permission": "can_edit_email_config"},
                {"id": 246, "name": "Delete", "permission": "can_delete_email_config"},
 
            ],

            "SMS Config": [  

                {"id": 247, "name": "List", "permission": "can_view_sms_config"},
                {"id": 248, "name": "Edit", "permission": "can_edit_sms_config"},
                {"id": 249, "name": "Status", "permission": "can_status_sms_config"},
                {"id": 250, "name": "Delete", "permission": "can_delete_sms_config"},
            
            ],

            "Inventory Category":[
                    {"id": 251, "name": "List", "permission": "can_view_inventory_category"},
                    {"id": 252, "name": "Add", "permission": "can_add_inventory_category"},
                    {"id": 253, "name": "Status", "permission": "can_status_inventory_category"},
                    {"id": 254, "name": "Edit", "permission": "can_edit_inventory_category"},
                    {"id": 255, "name": "Delete", "permission": "can_delete_inventory_category"},
                ],
            "Inventory Items":[
                {"id": 256, "name": "List", "permission": "can_view_inventory_items"},
                {"id": 257, "name": "Add", "permission": "can_add_inventory_items"},
                {"id": 258, "name": "Status", "permission": "can_status_inventory_items"},
                {"id": 259, "name": "Edit", "permission": "can_edit_inventory_items"},
                {"id": 260, "name": "Delete", "permission": "can_delete_inventory_items"},
            ],

                "Document Category":[
                {"id": 261, "name": "List", "permission": "can_view_document_category"},
                {"id": 262, "name": "Add", "permission": "can_add_document_category"},
                {"id": 263, "name": "Status", "permission": "can_status_document_category"},
                {"id": 264, "name": "Edit", "permission": "can_edit_document_category"},
                {"id": 265, "name": "Delete", "permission": "can_delete_document_category"},
            ],
            "Rental Availability":[
                {"id": 266, "name": "List", "permission": "can_view_rental_availability"},
                {"id": 267, "name": "Filter", "permission": "can_filter_rental_availability"},
                {"id": 268, "name": "Export", "permission": "can_export_rental_availability"}
            ],
        }


        context = {
            'userRole': user_role,
            'roles': roles,
            # 'date': auth_user_setings.date_format
            'permissions_by_page': permissions_by_page,
            'role_permissions': {permission['permission']: getattr(user_role, permission['permission'], False) for page in permissions_by_page.values() for permission in page},
        }
        return render(request, 'pages/super_admin/users_management/manage_role/edit.html', context)

class UserRoleCreate(LoginRequiredMixin, View):
    def get(self, request):
        trigger_subscription()
        roles = Role.objects.filter(Q(status=0) | Q(status=1))

        permissions_by_page = {
            'Settings':[
                {'id': 1, 'name': 'List', 'permission': 'can_view_general_setting'},
                {'id': 2, 'name': 'Edit', 'permission': 'can_edit_general_setting'},

                {'id': 3, 'name': 'Add', 'permission': 'can_add_country'},
                {'id': 4, 'name': 'Edit', 'permission': 'can_edit_country'},
                {'id': 5, 'name': 'View', 'permission': 'can_view_country'},
                {'id': 6, 'name': 'Delete', 'permission': 'can_delete_country'},
                {'id': 7, 'name': 'Status', 'permission': 'can_status_country'},

                {'id': 8, 'name': 'Add', 'permission': 'can_add_state'},
                {'id': 9, 'name': 'Edit', 'permission': 'can_edit_state'},
                {'id': 10, 'name': 'View', 'permission': 'can_view_state'},
                {'id': 11, 'name': 'Delete', 'permission': 'can_delete_state'},
                {'id': 12, 'name': 'Status', 'permission': 'can_status_state'},

                {'id': 13, 'name': 'Add', 'permission': 'can_add_city'},
                {'id': 14, 'name': 'Edit', 'permission': 'can_edit_city'},
                {'id': 15, 'name': 'View', 'permission': 'can_view_city'},
                {'id': 16, 'name': 'Delete', 'permission': 'can_delete_city'},
                {'id': 17, 'name': 'Status', 'permission': 'can_status_city'},

                {'id': 18, 'name': 'Add', 'permission': 'can_add_taluk'},
                {'id': 19, 'name': 'Edit', 'permission': 'can_edit_taluk'},
                {'id': 20, 'name': 'View', 'permission': 'can_view_taluk'},
                {'id': 21, 'name': 'Delete', 'permission': 'can_delete_taluk'},
                {'id': 22, 'name': 'Status', 'permission': 'can_status_taluk'},

                {'id': 23, 'name': 'Add', 'permission': 'can_add_village'},
                {'id': 24, 'name': 'Edit', 'permission': 'can_edit_village'},
                {'id': 25, 'name': 'View', 'permission': 'can_view_village'},
                {'id': 26, 'name': 'Delete', 'permission': 'can_delete_village'},
                {'id': 27, 'name': 'Status', 'permission': 'can_status_village'},
              
            ],

            'Data Management':[

                {'id': 28, 'name': 'Add', 'permission': 'can_add_land_unit'},
                {'id': 29, 'name': 'Edit', 'permission': 'can_edit_land_unit'},
                {'id': 30, 'name': 'View', 'permission': 'can_view_land_unit'},
                {'id': 31, 'name': 'Delete', 'permission': 'can_delete_land_unit'},
                {'id': 32, 'name': 'Status', 'permission': 'can_status_land_unit'},
              
                {'id': 33, 'name': 'Add', 'permission': 'can_add_area_unit'},
                {'id': 34, 'name': 'Edit', 'permission': 'can_edit_area_unit'},
                {'id': 35, 'name': 'View', 'permission': 'can_view_area_unit'},
                {'id': 36, 'name': 'Delete', 'permission': 'can_delete_area_unit'},
                {'id': 37, 'name': 'Status', 'permission': 'can_status_area_unit'},
              

                {'id': 38, 'name': 'Add', 'permission': 'can_add_soil_type'},
                {'id': 39, 'name': 'Edit', 'permission': 'can_edit_soil_type'},
                {'id': 40, 'name': 'View', 'permission': 'can_view_soil_type'},
                {'id': 41, 'name': 'Delete', 'permission': 'can_delete_soil_type'},
                {'id': 42, 'name': 'Status', 'permission': 'can_status_soil_type'},
              

                {'id': 43, 'name': 'Add', 'permission': 'can_add_crop_type'},
                {'id': 44, 'name': 'Edit', 'permission': 'can_edit_crop_type'},
                {'id': 45, 'name': 'View', 'permission': 'can_view_crop_type'},
                {'id': 46, 'name': 'Delete', 'permission': 'can_delete_crop_type'},
                {'id': 47, 'name': 'Status', 'permission': 'can_status_crop_type'},
              

                {'id': 48, 'name': 'Add', 'permission': 'can_add_quality'},
                {'id': 49, 'name': 'Edit', 'permission': 'can_edit_quality'},
                {'id': 50, 'name': 'View', 'permission': 'can_view_quality'},
                {'id': 51, 'name': 'Delete', 'permission': 'can_delete_quality'},
                {'id': 52, 'name': 'Status', 'permission': 'can_status_quality'},
              

                {'id': 53, 'name': 'Add', 'permission': 'can_add_crop'},
                {'id': 54, 'name': 'Edit', 'permission': 'can_edit_crop'},
                {'id': 55, 'name': 'View', 'permission': 'can_view_crop'},
                {'id': 56, 'name': 'Delete', 'permission': 'can_delete_crop'},
                {'id': 57, 'name': 'Status', 'permission': 'can_status_crop'},
              

                {'id': 58, 'name': 'Add', 'permission': 'can_add_product_type'},
                {'id': 59, 'name': 'Edit', 'permission': 'can_edit_product_type'},
                {'id': 60, 'name': 'View', 'permission': 'can_view_product_type'},
                {'id': 61, 'name': 'Delete', 'permission': 'can_delete_product_type'},
                {'id': 62, 'name': 'Status', 'permission': 'can_status_product_type'},
              

                {'id': 63, 'name': 'Add', 'permission': 'can_add_vehicle_category'},
                {'id': 64, 'name': 'Edit', 'permission': 'can_edit_vehicle_category'},
                {'id': 65, 'name': 'View', 'permission': 'can_view_vehicle_category'},
                {'id': 66, 'name': 'Delete', 'permission': 'can_delete_vehicle_category'},
                {'id': 67, 'name': 'Status', 'permission': 'can_status_vehicle_category'},
              

                {'id': 68, 'name': 'Add', 'permission': 'can_add_manage_vehicle'},
                {'id': 69, 'name': 'Edit', 'permission': 'can_edit_manage_vehicle'},
                {'id': 70, 'name': 'View', 'permission': 'can_view_manage_vehicle'},
                {'id': 71, 'name': 'Delete', 'permission': 'can_delete_manage_vehicle'},
                {'id': 72, 'name': 'Status', 'permission': 'can_status_manage_vehicle'},
              

                {'id': 73, 'name': 'Add', 'permission': 'can_add_machinery_category'},
                {'id': 74, 'name': 'Edit', 'permission': 'can_edit_machinery_category'},
                {'id': 75, 'name': 'View', 'permission': 'can_view_machinery_category'},
                {'id': 76, 'name': 'Delete', 'permission': 'can_delete_machinery_category'},
                {'id': 77, 'name': 'Status', 'permission': 'can_status_machinery_category'},
              

                {'id': 78, 'name': 'Add', 'permission': 'can_add_manage_machinery'},
                {'id': 79, 'name': 'Edit', 'permission': 'can_edit_manage_machinery'},
                {'id': 80, 'name': 'View', 'permission': 'can_view_manage_machinery'},
                {'id': 81, 'name': 'Delete', 'permission': 'can_delete_manage_machinery'},
                {'id': 82, 'name': 'Status', 'permission': 'can_status_manage_machinery'},
              

                {'id': 83, 'name': 'Add', 'permission': 'can_add_tool_category'},
                {'id': 84, 'name': 'Edit', 'permission': 'can_edit_tool_category'},
                {'id': 85, 'name': 'View', 'permission': 'can_view_tool_category'},
                {'id': 86, 'name': 'Delete', 'permission': 'can_delete_tool_category'},
                {'id': 87, 'name': 'Status', 'permission': 'can_status_tool_category'},
              

                {'id': 88, 'name': 'Add', 'permission': 'can_add_tool'},
                {'id': 89, 'name': 'Edit', 'permission': 'can_edit_tool'},
                {'id': 90, 'name': 'View', 'permission': 'can_view_tool'},
                {'id': 91, 'name': 'Delete', 'permission': 'can_delete_tool'},
                {'id': 92, 'name': 'Status', 'permission': 'can_status_tool'},
              

                {'id': 93, 'name': 'Add', 'permission': 'can_add_expense_category'},
                {'id': 94, 'name': 'Edit', 'permission': 'can_edit_expense_category'},
                {'id': 95, 'name': 'View', 'permission': 'can_view_expense_category'},
                {'id': 96, 'name': 'Delete', 'permission': 'can_delete_expense_category'},
                {'id': 97, 'name': 'Status', 'permission': 'can_status_expense_category'},
              

                {'id': 98, 'name': 'Add', 'permission': 'can_add_expense'},
                {'id': 99, 'name': 'Edit', 'permission': 'can_edit_expense'},
                {'id': 100, 'name': 'View', 'permission': 'can_view_expense'},
                {'id': 101, 'name': 'Delete', 'permission': 'can_delete_expense'},
                {'id': 102, 'name': 'Status', 'permission': 'can_status_expense'},
              

                {'id': 103, 'name': 'Add', 'permission': 'can_add_harvesting_type'},
                {'id': 104, 'name': 'Edit', 'permission': 'can_edit_harvesting_type'},
                {'id': 105, 'name': 'View', 'permission': 'can_view_harvesting_type'},
                {'id': 106, 'name': 'Delete', 'permission': 'can_delete_harvesting_type'},
                {'id': 107, 'name': 'Status', 'permission': 'can_status_harvesting_type'},
              

                {'id': 108, 'name': 'Add', 'permission': 'can_add_detection'},
                {'id': 109, 'name': 'Edit', 'permission': 'can_edit_detection'},
                {'id': 110, 'name': 'View', 'permission': 'can_view_detection'},
                {'id': 111, 'name': 'Delete', 'permission': 'can_delete_detection'},
                {'id': 112, 'name': 'Status', 'permission': 'can_status_detection'},
              

            ],

            'Farmer': [
                {'id': 113, 'name': 'List', 'permission': 'can_view_farmer'},
                {'id': 114, 'name': 'Add', 'permission': 'can_add_farmer'},
                {'id': 115, 'name': 'Edit', 'permission': 'can_edit_farmer'},
                {'id': 116, 'name': 'Delete', 'permission': 'can_delete_farmer'},
                {'id': 117, 'name': 'View', 'permission': 'can_view_unique_farmer'},
                {'id': 118, 'name': 'Export', 'permission': 'can_export_farmer_data'},
                {'id': 119, 'name': 'Filter', 'permission': 'can_filter_farmer_data'},
                {'id': 120, 'name': 'Status', 'permission': 'can_update_farmer_status'},
            ],

            'Package': [
                {'id': 121, 'name': 'List', 'permission': 'can_view_package'},
                {'id': 122, 'name': 'Add', 'permission': 'can_add_package'},
                {'id': 123, 'name': 'Edit', 'permission': 'can_edit_package'},
                {'id': 124, 'name': 'Delete', 'permission': 'can_delete_package'},
                {'id': 125, 'name': 'View', 'permission': 'can_view_unique_package'},
            ],
            'Subscription': [
                {'id': 126, 'name': 'List', 'permission': 'can_view_subscription'},
                {'id': 127, 'name': 'Add', 'permission': 'can_add_subscription'},
                {'id': 128, 'name': 'Edit', 'permission': 'can_edit_subscription'},
                {'id': 129, 'name': 'Delete', 'permission': 'can_delete_subscription'},
                {'id': 130, 'name': 'View', 'permission': 'can_view_unique_subscription'},
                {'id': 131, 'name': 'Active Plan', 'permission': 'can_activeplan_subscription'},
                {'id': 132, 'name': 'Renewal Plan', 'permission': 'can_renewalplan_subscription'},
                {'id': 133, 'name': 'Filter', 'permission': 'can_filter_subscription'},
                {'id': 134, 'name': 'Export', 'permission': 'can_export_subscription'},                
            ],
            'MarketPriceChart': [

                {'id': 135, 'name': 'List', 'permission': 'can_view_manage_product'},
                {'id': 136, 'name': 'Add', 'permission': 'can_add_manage_product'},
                {'id': 137, 'name': 'Edit', 'permission': 'can_edit_manage_product'},
                {'id': 138, 'name': 'Delete', 'permission': 'can_delete_manage_product'},
                {'id': 139, 'name': 'Update', 'permission': 'can_update_manage_product'},
                {'id': 140, 'name': 'Graph', 'permission': 'can_graph_manage_product'},
                {'id': 141, 'name': 'Filter', 'permission': 'can_filter_manage_product'},
                {'id': 142, 'name': 'Staff', 'permission': 'can_staff_manage_product'},

                {'id': 143, 'name': 'List', 'permission': 'can_view_market_report'},
                {'id': 144, 'name': 'Edit', 'permission': 'can_edit_market_report'},
                {'id': 145, 'name': 'Graph', 'permission': 'can_graph_market_report'},
                {'id': 146, 'name': 'Filter', 'permission': 'can_filter_market_report'},

                {'id': 147, 'name': 'List', 'permission': 'can_view_product_market_report'},
                {'id': 148, 'name': 'Edit', 'permission': 'can_edit_product_market_report'},
                {'id': 149, 'name': 'Graph', 'permission': 'can_graph_product_market_report'},
                {'id': 150, 'name': 'Filter', 'permission': 'can_filter_product_market_report'},
            ],
            'Market Management': [
                {'id': 151, 'name': 'List', 'permission': 'can_view_market'},
                {'id': 152, 'name': 'Add', 'permission': 'can_add_market'},
                {'id': 153, 'name': 'Edit', 'permission': 'can_edit_market'},
                {'id': 154, 'name': 'Delete', 'permission': 'can_delete_market'},
                {'id': 155, 'name': 'List', 'permission': 'can_view_unique_market'},
                {'id': 156, 'name': 'Status', 'permission': 'can_status_market'},
                {'id': 157, 'name': 'Export', 'permission': 'can_export_market'},
                {'id': 158, 'name': 'Filter', 'permission': 'can_filter_market'},

                {'id': 159, 'name': 'View', 'permission': 'can_view_allocate_market'},
                {'id': 160, 'name': 'Status', 'permission': 'can_add_allocate_market'},
                {'id': 161, 'name': 'Export', 'permission': 'can_edit_allocate_market'},
                {'id': 162, 'name': 'Filter', 'permission': 'can_delete_allocate_market'},
                {'id': 163, 'name': 'View', 'permission': 'can_view_unique_allocate_market'},
                {'id': 164, 'name': 'Status', 'permission': 'can_status_allocate_market'},
                {'id': 165, 'name': 'Export', 'permission': 'can_export_allocate_market'}, 
            
            ],

            'Schedule Management': [
                {'id': 166, 'name': 'List', 'permission': 'can_view_schedule_activity_type'},
                {'id': 167, 'name': 'Add', 'permission': 'can_add_schedule_activity_type'},
                {'id': 168, 'name': 'Edit', 'permission': 'can_edit_schedule_activity_type'},
                {'id': 169, 'name': 'Delete', 'permission': 'can_delete_schedule_activity_type'},
                {'id': 170, 'name': 'Status', 'permission': 'can_status_schedule_activity_type'},

                {'id': 171, 'name': 'List', 'permission': 'can_view_schedule'},
                {'id': 172, 'name': 'Add', 'permission': 'can_add_schedule'},
                {'id': 173, 'name': 'Edit', 'permission': 'can_edit_schedule'},
                {'id': 174, 'name': 'Delete', 'permission': 'can_delete_schedule'},
                {'id': 175, 'name': 'View', 'permission': 'can_view_unique_schedule'},
                {'id': 176, 'name': 'Status', 'permission': 'can_status_schedule'},
            ],

            "NearByLocations": [
                {"id": 177, "name": "List", "permission": "can_view_near_by_location_category"},
                {"id": 178, "name": "Add", "permission": "can_add_near_by_location_category"},
                {"id": 179, "name": "Edit", "permission": "can_edit_near_by_location_category"},
                {"id": 180, "name": "Delete", "permission": "can_delete_near_by_location_category"},
                {"id": 181, "name": "Status", "permission": "can_status_near_by_location_category"},

                {"id": 182, "name": "List", "permission": "can_view_near_by_locations"},
                {"id": 183, "name": "Add", "permission": "can_add_near_by_locations"},
                {"id": 184, "name": "Edit", "permission": "can_edit_near_by_locations"},
                {"id": 185, "name": "Delete", "permission": "can_delete_near_by_locations"},
                {"id": 186, "name": "View", "permission": "can_view_unique_near_by_locations"},
                {"id": 187, "name": "Status", "permission": "can_status_near_by_locations"},
                {"id": 188, "name": "Export", "permission": "can_export_near_by_locations"},
                {"id": 189, "name": "Filter", "permission": "can_filter_near_by_locations"},
                
            ],

            "Workers Management": [

                {"id": 190, "name": "List", "permission": "can_view_workers_type"},
                {"id": 191, "name": "Add", "permission": "can_add_workers_type"},
                {"id": 192, "name": "Edit", "permission": "can_edit_workers_type"},
                {"id": 193, "name": "Delete", "permission": "can_delete_workers_type"},
                {"id": 194, "name": "Status", "permission": "can_update_workers_type_status"},
            
                {"id": 195, "name": "List", "permission": "can_view_manage_workers"},
                {"id": 196, "name": "Add", "permission": "can_add_manage_workers"},
                {"id": 197, "name": "Edit", "permission": "can_edit_manage_workers"},
                {"id": 198, "name": "Delete", "permission": "can_delete_manage_workers"},
                {"id": 199, "name": "Update", "permission": "can_update_manage_workers"},
                {"id": 200, "name": "View", "permission": "can_view_unique_manage_workers"},
                {"id": 201, "name": "Status", "permission": "can_update_manage_workers_status"},
                {"id": 202, "name": "Export", "permission": "can_export_manage_workers"},                
                {"id": 203, "name": "Filter", "permission": "can_filter_manage_workers"},
            
            ],
            "Guidelines Management": [

                {"id": 204, "name": "List", "permission": "can_view_guidelines_category"},
                {"id": 205, "name": "Add", "permission": "can_add_guidelines_category"},
                {"id": 206, "name": "Edit", "permission": "can_edit_guidelines_category"},
                {"id": 207, "name": "Delete", "permission": "can_delete_guidelines_category"},
                {"id": 208, "name": "Status", "permission": "can_update_guidelines_category_status"},
            
                {"id": 209, "name": "List", "permission": "can_view_guidelines"},
                {"id": 210, "name": "Add", "permission": "can_add_guidelines"},
                {"id": 211, "name": "Edit", "permission": "can_edit_guidelines"},
                {"id": 212, "name": "Delete", "permission": "can_delete_guidelines"},
                {"id": 213, "name": "View", "permission": "can_view_unique_guidelines"},
                {"id": 214, "name": "Status", "permission": "can_update_guidelines_status"},
                {"id": 215, "name": "Export", "permission": "can_export_guidelines"},                
                {"id": 216, "name": "Filter", "permission": "can_filter_guidelines"},

            ],

             "User Management": [
                 
                {"id": 217, "name": "List", "permission": "can_view_manage_user"},
                {"id": 218, "name": "Add", "permission": "can_add_manage_user"},
                {"id": 219, "name": "Edit", "permission": "can_edit_manage_user"},
                {"id": 220, "name": "Delete", "permission": "can_delete_manage_user"},
                {"id": 221, "name": "Status", "permission": "can_view_unique_manage_user"},
                {"id": 222, "name": "List", "permission": "can_status_manage_user"},
                {"id": 223, "name": "Add", "permission": "can_ter_status_manage_user"},
                {"id": 224, "name": "Edit", "permission": "can_rel_status_manage_user"},
                {"id": 225, "name": "Delete", "permission": "can_filter_manage_user"},
                {"id": 226, "name": "View", "permission": "can_export_manage_user"}, 

                {"id": 227, "name": "List", "permission": "can_view_manage_user_role"},
                {"id": 228, "name": "Add", "permission": "can_add_manage_user_role"},
                {"id": 229, "name": "Edit", "permission": "can_edit_manage_user_role"},
                {"id": 230, "name": "Delete", "permission": "can_delete_manage_user_role"},
                {"id": 231, "name": "View", "permission": "can_view_unique_manage_user_role"},
                {"id": 232, "name": "Status", "permission": "can_status_manage_user_role"},
            
            ],

             

            "Report": [

                {"id": 233, "name": "List", "permission": "can_view_farmer_report"},
                {"id": 234, "name": "View", "permission": "can_view_unique_report"},
                {"id": 235, "name": "Filter", "permission": "can_filter_farmer_report"},
                {"id": 236, "name": "Export", "permission": "can_export_farmer_report"},


                {"id": 237, "name": "List", "permission": "can_view_subscription_report"},
                {"id": 238, "name": "View", "permission": "can_view_unique_subscription_report"},
                {"id": 239, "name": "Filter", "permission": "can_filter_subscription_report"},
                {"id": 240, "name": "Export", "permission": "can_export_subscription_report"},
            
            ],

            "Dashboard": [
                {"id": 241, "name": "View", "permission": "can_dashboard_count"}, 
            ],

            "Email Config": [ 
                {"id": 242, "name": "List", "permission": "can_view_email_config"},
                {"id": 243, "name": "Add", "permission": "can_add_email_config"},
                {"id": 244, "name": "Status", "permission": "can_status_email_config"},
                {"id": 245, "name": "Edit", "permission": "can_edit_email_config"},
                {"id": 246, "name": "Delete", "permission": "can_delete_email_config"},
 
            ],

            "SMS Config": [  

                {"id": 247, "name": "List", "permission": "can_view_sms_config"},
                {"id": 248, "name": "Edit", "permission": "can_edit_sms_config"},
                {"id": 249, "name": "Status", "permission": "can_status_sms_config"},
                {"id": 250, "name": "Delete", "permission": "can_delete_sms_config"},
            
            ],

            "Inventory Category":[
                    {"id": 251, "name": "List", "permission": "can_view_inventory_category"},
                    {"id": 252, "name": "Add", "permission": "can_add_inventory_category"},
                    {"id": 253, "name": "Status", "permission": "can_status_inventory_category"},
                    {"id": 254, "name": "Edit", "permission": "can_edit_inventory_category"},
                    {"id": 255, "name": "Delete", "permission": "can_delete_inventory_category"},
                ],
            "Inventory Items":[
                {"id": 256, "name": "List", "permission": "can_view_inventory_items"},
                {"id": 257, "name": "Add", "permission": "can_add_inventory_items"},
                {"id": 258, "name": "Status", "permission": "can_status_inventory_items"},
                {"id": 259, "name": "Edit", "permission": "can_edit_inventory_items"},
                {"id": 260, "name": "Delete", "permission": "can_delete_inventory_items"},
            ],

                "Document Category":[
                {"id": 261, "name": "List", "permission": "can_view_document_category"},
                {"id": 262, "name": "Add", "permission": "can_add_document_category"},
                {"id": 263, "name": "Status", "permission": "can_status_document_category"},
                {"id": 264, "name": "Edit", "permission": "can_edit_document_category"},
                {"id": 265, "name": "Delete", "permission": "can_delete_document_category"},
            ],
            "Rental Availability":[
                {"id": 266, "name": "List", "permission": "can_view_rental_availability"},
                {"id": 267, "name": "Filter", "permission": "can_filter_rental_availability"},
                {"id": 268, "name": "Export", "permission": "can_export_rental_availability"}
            ],

        }



        # Fetch existing roles and their current permissions if any
        role_permissions = {}

        for role in roles:
            try:
                # Retrieve all ManageUserRole for each role
                manage_user_roles = ManageUserRole.objects.filter(map_role=role)

                # Initialize permission dictionary for the role
                role_permissions[role.id] = {}

                # Check if ManageUserRole exists for the role
                if manage_user_roles.exists():
                    # Aggregate permissions from all ManageUserRoles (if there are multiple)
                    for manage_user_role in manage_user_roles:
                        # Add permissions dynamically based on the `permissions_by_page`
                        for page, permissions in permissions_by_page.items():
                            for permission in permissions:
                                # If permission is set to True for any ManageUserRole, keep it as True
                                current_permission = getattr(manage_user_role, permission['permission'], False)
                                # Combine permissions using OR (if any of the roles have the permission, it's True)
                                role_permissions[role.id][permission['permission']] = role_permissions[role.id].get(permission['permission'], False) or current_permission
                else:
                    # If no ManageUserRole exists for the role, set all permissions to False
                    role_permissions[role.id] = {permission['permission']: False for page in permissions_by_page.values() for permission in page}

            except Exception as e:
                # Log or handle any unexpected errors gracefully
                print(f"Error fetching ManageUserRole for role {role.id}: {str(e)}")
                role_permissions[role.id] = {permission['permission']: False for page in permissions_by_page.values() for permission in page}

        # Prepare context to send to the template
        all_roles = ManageUserRole.objects.all()
        context = {
            'all_roles': all_roles,
            'roles': roles,
            'permissions_by_page': permissions_by_page,
            'role_permissions': role_permissions,  # Include the current permissions
        }

        # Render the page to create/manage the role and permissions
        return render(request, 'pages/super_admin/users_management/manage_role/add.html', context)

# ---------------------- Manage User ---------------------


def send_welcome_email_admin(email, name, username, password,role):
    print(f"Sending Welcome Mail")  # Debugging line

    try:
        print(role)
        if role == 0:
            template = get_object_or_404(EmailTemplate, code=2)
        elif role == 1:
            template = get_object_or_404(EmailTemplate, code=4)
        elif role == 2:
            template = get_object_or_404(EmailTemplate, code=3)
        else:
            template = get_object_or_404(EmailTemplate, code=2)
        if template.status == 0:
            content = template.email_template_content

            content = content.replace('#$%Name#$%', name)
            content = content.replace('#$%username#$%', username)
            content = content.replace('#$%password#$%', password)

            subject = template.email_subject
            from_email = settings.DEFAULT_FROM_EMAIL
            to_email = [email]

            msg = EmailMultiAlternatives(subject, '', from_email, to_email)
            msg.attach_alternative(content, "text/html")
            msg.send()
            
            print(f"Welcome mail sent successfully to {email}!") 
        else:
            print("Email not Sent! Issue in Email Template")
        
        # send_mail(
        #     'Welcome to AgriOT, Your Admin Dashboard Awaits! 🚜🌱',  # Subject of the email
        #     f"""Dear {name},

        #     Thank you for becoming part of the AgriOT Admin team! We are excited to have you on board as you help drive the success of our farming community as a {role}.

        #     Your Features and Responsibilities:
        #     ✅ Assist in day-to-day farm management tasks and operations.

        #     ✅ Manage and update market prices for various agricultural products.

        #     ✅ Monitor and adjust pricing based on market trends.

        #     ✅ Provide up-to-date price information to ensure accurate sales and purchase decisions.

        #     ✅ Submit and update worker availability and count.

        #     ✅ Track and manage worker assignments based on availability.

        #     ✅ Access administrative tools under the supervision of the Super Admin.

        #     Your Login Credentials:
        #     📧 Username: {username}
        #     🔑 Password: {password}

        #     🔒 Please keep your email and password safe and secure.

        #     👉 To begin managing and overseeing your farming operations:
        #     http://147.93.19.253:5000/SuperAdmin

        #     We are thrilled to have you on the AgriOT team and look forward to empowering you with the tools needed for farm management success!

        #     Best Regards,
        #     AgriOT Team""",  # Body of the email
        #     settings.DEFAULT_FROM_EMAIL,  # Send from the user's email (email parameter from CustomUser)
        #     [email],  # Recipient email address
        #     fail_silently=False,  # Ensure any failure is raised as an exception
        # )
        
    except Exception as e:
        print(f"Error sending email: {e}") 

def send_welcome_sms_admin(mobile_number, name, username, password, role):
    print("Sending Welcome SMS")
    SMS_TEMPLATE = {
        'authkey': '155099Ajzgw9B8dfq6737236aP1',  
        'sender_id': 'ELYSIU',  
        'template_id': '1007049094377493090',   
        'country_code': '91',  
        'message_content': 
            f"""Dear {name},

            Thank you for becoming part of the AgriOT Admin team! We are excited to have you on board as you help drive the success of our farming community as a {role}.

            Your Features and Responsibilities:
            ✅ Assist in day-to-day farm management tasks and operations.

            ✅ Manage and update market prices for various agricultural products.

            ✅ Monitor and adjust pricing based on market trends.

            ✅ Provide up-to-date price information to ensure accurate sales and purchase decisions.

            ✅ Submit and update worker availability and count.

            ✅ Track and manage worker assignments based on availability.

            ✅ Access administrative tools under the supervision of the Super Admin.

            Your Login Credentials:
            📧 Username: {username}
            🔑 Password: {password}

            🔒 Please keep your email and password safe and secure.

            👉 To begin managing and overseeing your farming operations:
            http://147.93.19.253:5000/SuperAdmin

             We are thrilled to have you on the AgriOT team and look forward to empowering you with the tools needed for farm management success!

            Best Regards,
            AgriOT Team"""
    }

    mobile_number = SMS_TEMPLATE['country_code'] + str(mobile_number)

    message_content = SMS_TEMPLATE['message_content']

    # print(f"Message Content: {message_content}")  # Debugging line

    # Build the API URL for sending SMS
    url = f"https://api.msg91.com/api/sendhttp.php?authkey={SMS_TEMPLATE['authkey']}&sender={SMS_TEMPLATE['sender_id']}&route=default&message={message_content}&mobiles={mobile_number}&DLT_TE_ID={SMS_TEMPLATE['template_id']}"

    try:
        # Make the GET request to send the SMS
        response = requests.get(url)

        # Log the response (for debugging purposes)
        print(f"API Response: {response.text}")

        # Check if the request was successful
        if response.status_code == 200:
            print(f"Welcome SMS sent successfully to {mobile_number}!")  # Debugging line
        else:
            print(f"Failed to send Welcome SMS. Status code: {response.status_code}")
            print(f"Error details: {response.text}")

    except requests.exceptions.RequestException as e:
        # Catch any request exceptions and log the error
        print(f"Error occurred while sending OTP: {e}")

def export_userData(request):
    # Get filter parameters from the request
    users = ManageUser.objects.filter(Q(status=0) | Q(status=1))
    
    releave_users = UserProfileStatus.objects.filter(releave=1).values_list('name_id', flat=True)
    terminated_users = UserProfileStatus.objects.filter(terminate=1).values_list('name_id', flat=True)

    user_profile_status = UserProfileStatus.objects.filter(Q(terminate=1) | Q(releave=1))
    user_status_map = {status.name.id: {'terminate': status.terminate, 'releave': status.releave} for status in user_profile_status}

    # Get filter values from the request
    filter_type = request.GET.get('filter_type')
    filter_user = request.GET.get('filter_user')
    filter_mob = request.GET.get('filter_mob')
    filter_role = request.GET.get('filter_role')
    filter_status = request.GET.get('filter_status')
    date_filter = request.GET.get('dt_fill_issue_rpt')
    filter_date_cfrom = request.GET.get('filter_date_cfrom')
    filter_date_cto = request.GET.get('filter_date_cto')
    today_date = timezone.now().date()

    # Apply filters based on the form inputs
    if filter_type:
        users = users.filter(usertype__code=filter_type)
    if filter_user:
        users = users.filter(id=filter_user)
    if filter_mob:
        users = users.filter(mobile_no=filter_mob)
    if filter_role:
        users = users.filter(role__code=filter_role)
    if filter_status:
        if filter_status == '1':  # Active
            users = users.exclude(id__in=user_status_map.keys())
        elif filter_status == '2':  # Terminated
            users = users.filter(id__in=terminated_users)
        elif filter_status == '3':  # Releaved
            users = users.filter(id__in=releave_users)

            # Date filtering
    if date_filter == 'today':
        users = users.filter(created_at__date=today_date)
    elif date_filter == 'week':
        start_of_week = today_date - timedelta(days=today_date.weekday())  # Monday
        users = users.filter(created_at__date__range=[start_of_week, today_date])
    elif date_filter == 'monthly':
        users = users.filter(created_at__year=today_date.year, created_at__month=today_date.month)
    elif date_filter == 'custom_date':
        custom_from_date = request.GET.get('filter_date_cfrom')
        custom_to_date = request.GET.get('filter_date_cto')
        if custom_from_date and custom_to_date:
            # Convert the date format from DD-MM-YYYY to YYYY-MM-DD
            custom_from_date = datetime.strptime(custom_from_date, '%d-%m-%Y').date()
            custom_to_date = datetime.strptime(custom_to_date, '%d-%m-%Y').date()
            users = users.filter(created_at__date__range=[custom_from_date, custom_to_date])

    # Create the CSV response
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="userdata.csv"'

    writer = csv.writer(response)
    # Write the header row with the specified fields
    writer.writerow(['Name', 'User Type', 'Mobile No', 'Date of Birth', 'Village', 'Taluk', 'Role'])

    for user in users:
        writer.writerow([
            user.name,
            user.usertype.name,  # Assuming usertype is a ForeignKey to UserType
            user.mobile_no,
            user.date_of_birth,
            user.village.name if user.village else '',  # Assuming village is a ForeignKey to Village
            user.taluk.name if user.taluk else '',    # Assuming taluk is a ForeignKey to Taluk
            user.role.role  # Assuming role is a ForeignKey to Role
        ])

    return response

class ManageUserView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_export_manage_user': True,
                'can_view_manage_user': True,
                'can_filter_manage_user': True,
                'can_add_manage_user': True,  
                'can_edit_manage_user': True,
                'can_delete_manage_user': True,
                'can_status_manage_user': True,
                'can_ter_status_manage_user': True, 
                'can_rel_status_manage_user': True,
                'can_view_unique_manage_user': True, 
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_manage_user:
                return redirect('user_not_allowed') 
 
        # Get the list of ManageUser instances
        users = ManageUser.objects.filter(status__in=[0,1,3,4]).order_by('-id')
        all_users = ManageUser.objects.filter(Q(status=0) | Q(status=1))
        user_types = UserType.objects.filter(Q(status=0) | Q(status=1))
        roles = ManageUserRole.objects.filter(Q(status=0) | Q(status=1))
        
        # Get users who have releave = 1
        releave_users = UserProfileStatus.objects.filter(releave=1).values_list('name_id', flat=True)
        terminated_users = UserProfileStatus.objects.filter(terminate=1).values_list('name_id', flat=True)

        user_counts = UserType.objects.annotate(user_count=Count('manageuser', filter=Q(manageuser__status__in=[0, 1])))

        user_profile_status = UserProfileStatus.objects.filter(Q(terminate=1) | Q(releave=1))
        user_status_map = {status.name.id: {'terminate': status.terminate, 'releave': status.releave} for status in user_profile_status}

        # Get filter values from the request
        filter_type = request.GET.get('filter_type')
        filter_user = request.GET.get('filter_user')
        filter_mob = request.GET.get('filter_mob')
        filter_role = request.GET.get('filter_role')
        filter_status = request.GET.get('filter_status')
        date_filter = request.GET.get('dt_fill_issue_rpt')
        filter_date_cfrom = request.GET.get('filter_date_cfrom')
        filter_date_cto = request.GET.get('filter_date_cto')
        today_date = timezone.now().date()

        # Apply filters based on the form inputs
        if filter_type:
            users = users.filter(usertype__code=filter_type)
        if filter_user:
            users = users.filter(id=filter_user)
        if filter_mob:
            users = users.filter(mobile_no=filter_mob)
        if filter_role:
            users = users.filter(role__id=filter_role)
        if filter_status:
            if filter_status == '1':  # Active
                users = users.exclude(id__in=user_status_map.keys())
            elif filter_status == '2':  # Terminated
                users = users.filter(id__in=terminated_users)
            elif filter_status == '3':  # Releaved
                users = users.filter(id__in=releave_users)

                # Date filtering
        if date_filter == 'today':
            users = users.filter(created_at__date=today_date)
        elif date_filter == 'week':
            start_of_week = today_date - timedelta(days=today_date.weekday())  # Monday
            users = users.filter(created_at__date__range=[start_of_week, today_date])
        elif date_filter == 'monthly':
            users = users.filter(created_at__year=today_date.year, created_at__month=today_date.month)
        elif date_filter == 'custom_date':
            custom_from_date = request.GET.get('filter_date_cfrom')
            custom_to_date = request.GET.get('filter_date_cto')
            if custom_from_date and custom_to_date:
                # Convert the date format from DD-MM-YYYY to YYYY-MM-DD
                custom_from_date = datetime.strptime(custom_from_date, '%d-%m-%Y').date()
                custom_to_date = datetime.strptime(custom_to_date, '%d-%m-%Y').date()
                users = users.filter(created_at__date__range=[custom_from_date, custom_to_date])

        show_per_page = request.GET.get('show', 25)
        show_per_page = int(show_per_page)

        # Pagination setup
        paginator = Paginator(users, show_per_page) 
        page_number = request.GET.get('page') 
        page_obj = paginator.get_page(page_number)
        entries = 0
        for i in page_obj:
            entries += 1
        
        context = {
            'all_users': all_users,
            'user_types': user_types,
            'roles': roles,
            'users': page_obj,
            'entries_count': entries,
            'show_per_page': show_per_page,
            'user_status_map': user_status_map,
            'user_counts': user_counts,
            'releave_users': releave_users,
            'terminated_users': terminated_users,
            'filter_type': filter_type if filter_type else '',
            'filter_user': filter_user if filter_user else '',
            'filter_mob': filter_mob if filter_mob else '',
            'filter_role': filter_role if filter_role else '',
            'filter_status': filter_status if filter_status else '',
            'date_filter': date_filter if date_filter else 'all',
            'filter_date_cfrom': filter_date_cfrom if filter_date_cfrom else '',
            'filter_date_cto': filter_date_cto if filter_date_cto else '',
            'can_export_manage_user': manage_user.can_export_manage_user if manage_user else False,
            'can_view_manage_user': manage_user.can_view_manage_user if manage_user else False,
            'can_filter_manage_user': manage_user.can_filter_manage_user if manage_user else False,
            'can_add_manage_user': manage_user.can_add_manage_user if manage_user else False,
            'can_edit_manage_user': manage_user.can_edit_manage_user if manage_user else False,
            'can_delete_manage_user': manage_user.can_delete_manage_user if manage_user else False,
            'can_status_manage_user': manage_user.can_status_manage_user if manage_user else False,
            'can_ter_status_manage_user': manage_user.can_ter_status_manage_user if manage_user else False,
            'can_rel_status_manage_user': manage_user.can_rel_status_manage_user if manage_user else False,
            'can_view_unique_manage_user': manage_user.can_view_unique_manage_user if manage_user else False,
        }
        return render(request, 'pages/super_admin/users_management/manage_users/list.html', context)
    
    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                users = get_object_or_404(ManageUser, pk=pk) 
                status = request.POST.get('status') 

                if status == '0':
                    users.status = 0   
                    users.updated_by = user
                    users.save()
                    Notification.objects.create(user=user,name=users.name, message=f"User Status Activated: {users.name}", image=users.img)
                    cs = CustomUser.objects.get(pk=users.custom_user_id)
                    cs.is_active = True
                    cs.save()
                    messages.success(request, "Staffs has been activated.") 
                elif status == '1':
                    users.status = 1  
                    users.updated_by = user
                    users.save()
                    Notification.objects.create(user=user,name=users.name, message=f"User Status Deactivated: {users.name}", image=users.img)
                    cs = CustomUser.objects.get(pk=users.custom_user_id)
                    cs.is_active = False
                    cs.save()
                    messages.success(request, "Staffs has been deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_manage_users')
        
        elif action == 'delete':
            pk = request.POST.get('id')
            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    users = get_object_or_404(ManageUser, pk=pk)   
                    users.status = 2  
                    users.updated_by = user
                    users.save()
                    Notification.objects.create(user=user,name=users.name, message=f"User Deleted: {users.name}", image=users.img,created_at=timezone.now())
                    cs = CustomUser.objects.get(pk=users.custom_user_id)
                    cs.is_active = False
                    cs.save()
                    messages.success(request, "User has been deactivated successfully.")  
                except Detection.DoesNotExist:
                    messages.error(request, "User not found.")  

            return redirect('sa_manage_users') 
        
        elif action == 'terminate':
            pk = request.POST.get('id')
            desceription = request.POST.get('description')
            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    users = get_object_or_404(ManageUser, pk=pk)
                    users.status=3
                    users.updated_by = user
                    users.save()
                    UserProfileStatus.objects.create(name=users, terminate=1, active=0, description=desceription,created_by=user)

                    cs = CustomUser.objects.get(pk=users.custom_user_id)
                    cs.is_active = False
                    cs.save()

                    Notification.objects.create(user=user,name=users.name, message=f"User Terminated: {users.name}", image=users.img)
                    messages.success(request, "User has been Terminated successfully.")  
                except Detection.DoesNotExist:
                    messages.error(request, "User not found.")  

            return redirect('sa_manage_users')
        
        elif action == 'releave':
            pk = request.POST.get('id')
            desceription = request.POST.get('description')
            if not pk:
                messages.error(request, "ID cannot be empty.")  
            else:
                try:
                    users = get_object_or_404(ManageUser, pk=pk)
                    users.status=4
                    users.updated_by = user
                    users.save()
                    UserProfileStatus.objects.create(name=users, releave=1, active=0, description=desceription,created_by=user)
                    Notification.objects.create(user=user,name=users.name, message=f"User Releaved: {users.name}", image=users.img)

                    cs = CustomUser.objects.get(pk=users.custom_user_id)
                    cs.is_active = False
                    cs.save()

                    messages.success(request, "User has been Releaved successfully.")  
                except Detection.DoesNotExist:
                    messages.error(request, "User not found.")  

            return redirect('sa_manage_users')

        elif action == 'update':
            pk = request.POST.get('id')
            user_type_code = request.POST.get('users_type_edit')
            userType = get_object_or_404(UserType, code=user_type_code)
            name = request.POST.get('update_name')
            dob_str = request.POST.get('update_date')
            gender_code = request.POST.get('update_gender')
            gender = get_object_or_404(Gender, code=gender_code)
            mob_no = request.POST.get('update_phone')
            altt_mob_no = request.POST.get('update_alt_phone')
            email = request.POST.get('update_email')
            doj_str = request.POST.get('update_join')
            emp_type_id = request.POST.get('update_emp_type')
            emp_type = get_object_or_404(EmployeeType, id=emp_type_id)
            country_id = request.POST.get('update_country')
            state_id = request.POST.get('update_state')
            city_id = request.POST.get('update_city')
            taluk_id = request.POST.get('update_taluk')
            village_id = request.POST.get('update_village')
            address = request.POST.get('update_address')
            img = request.FILES.get('update_img')
            role_id = request.POST.get('update_role')

            # Debugging: Check if the role_id is correct
            print(f"Role ID from POST: '{role_id}'")

            if not role_id:
                return HttpResponse("Error: Role ID is required and cannot be empty.")

            try:
                role = ManageUserRole.objects.get(id=role_id)
            except ManageUserRole.DoesNotExist:
                return HttpResponse(f"Error: The role with ID {role_id} does not exist.")

            username = request.POST.get('update_username')
            password = request.POST.get('sub_admin_pswd')
            
            users = get_object_or_404(ManageUser, pk=pk)
            customuser = get_object_or_404(CustomUser, id=users.custom_user_id)

            users.usertype = userType
            users.name = name
            users.gender = gender
            users.mobile_no = mob_no
            users.employee_type = emp_type

            if dob_str:
                users.date_of_birth = datetime.strptime(dob_str, '%d-%m-%Y').date()
            
            if email:
                users.email = email
            
            if altt_mob_no:
                users.alter_no = altt_mob_no

            if doj_str:
                users.date_of_join = datetime.strptime(doj_str, '%d-%m-%Y').date()

            if country_id:
                users.country = get_object_or_404(Country, id=country_id)
            if state_id:
                users.state = get_object_or_404(State, id=state_id)
            if city_id:
                users.city = get_object_or_404(City, id=city_id)
            if taluk_id:
                users.taluk = get_object_or_404(Taluk, id=taluk_id)
            if village_id:
                users.village = get_object_or_404(Village, id=village_id)

            users.address = address
            users.role = role
            users.username = username

            if users.password != password:
                users.password = password
                customuser.set_password(password)

            if img:
                users.img = img

            users.updated_by = user

            if userType.code == 0:
                users.staff_user = True
                users.worker_availability_provider = False
                users.market_price_updater = False
            elif userType.code == 1:
                users.worker_availability_provider = True
                users.staff_user = False
                users.market_price_updater = False
            elif userType.code == 2:
                users.market_price_updater = True
                users.staff_user = False
                users.worker_availability_provider = False

            users.save()
            
            customuser.name = users.name
            customuser.email = users.email
            customuser.phone_number = users.mobile_no
            customuser.save()

            Notification.objects.create(user=user,name=users.name, message=f"User Details Updated: {users.name}", image=users.img)
            messages.success(request, "Users Updated Successfully") 
            return redirect('sa_manage_users')

        elif action == 'create':
            user_type_code = request.POST.get('users_type')
            try:
                userType = get_object_or_404(UserType, code=user_type_code)
            except UserType.DoesNotExist:
                # Handle error if userType does not exist, maybe return a message to the user
                return redirect('error_page')

            name = request.POST.get('add_name')
            dob_str = request.POST.get('add_dob')
            formatted_dob = None
            if dob_str:
                try:
                    dob = datetime.strptime(dob_str, '%d-%m-%Y')
                    formatted_dob = dob.strftime('%Y-%m-%d')
                except ValueError:
                    # Handle invalid date format
                    return redirect('error_page')

            gender_code = request.POST.get('add_gender')
            gender = get_object_or_404(Gender, code=gender_code)
            
            mob_no = request.POST.get('add_phone')
            altt_mob_no = request.POST.get('add_alt_phone')
            email = request.POST.get('add_email')

            doj_str = request.POST.get('add_doj')
            formatted_doj = None
            if doj_str:
                try:
                    doj = datetime.strptime(doj_str, '%d-%m-%Y')
                    formatted_doj = doj.strftime('%Y-%m-%d')
                except ValueError:
                    return redirect('error_page')

            emp_type_id = request.POST.get('add_emp_type')
            emp_type = get_object_or_404(EmployeeType, id=emp_type_id)

            # Location Information
            country_id = request.POST.get('add_country')
            state_id = request.POST.get('add_state')
            city_id = request.POST.get('add_city')
            taluk_id = request.POST.get('add_taluk')
            village_id = request.POST.get('add_village')
            address = request.POST.get('add_address')

            img = request.FILES.get('add_img')  # Image field

            role_id = request.POST.get('add_role')
            role = get_object_or_404(ManageUserRole, id=role_id)  # Get the selected role

            # Create the new ManageUser instance
            new_user = ManageUser(
                usertype=userType,
                name=name,
                email=email,
                gender=gender,
                mobile_no=mob_no,
                employee_type=emp_type,
                role=role,
                date_of_birth=formatted_dob,
                alter_no=int(altt_mob_no) if altt_mob_no else None,
                date_of_join=formatted_doj,
                country=get_object_or_404(Country, id=country_id) if country_id else None,
                state=get_object_or_404(State, id=state_id) if state_id else None,
                city=get_object_or_404(City, id=city_id) if city_id else None,
                taluk=get_object_or_404(Taluk, id=taluk_id) if taluk_id else None,
                village=get_object_or_404(Village, id=village_id) if village_id else None,
                img=img if img else None,
                address=address,
                created_by = user,
                created_at=timezone.now(),
            )

            new_user.save()  # Save the new user

            # new_user.can_view_general_setting = role.can_view_general_setting
            # new_user.can_edit_general_setting = role.can_edit_general_setting

            # new_user.save()


            # Create a notification for the new user
            try:
                Notification.objects.create(user=user, message=f"New User Created: {new_user.name}", image=new_user.img, name=new_user.name)  #name=users.name,
                messages.success(request, "User Created Successfully.") 
            except CustomUser.DoesNotExist:
                # Handle the case where the linked CustomUser doesn't exist
                return redirect('error_page')

            try:
                if new_user.email:
                    send_welcome_email_admin(email,name,mob_no,mob_no,userType.code)
                # else:
                #     send_welcome_sms_admin(mob_no,name,mob_no,mob_no,userType.name.title())
            except Exception as e:
                print(e)
                print("Error in sending welcome mail")

            # Redirect to the user management page
            return redirect('sa_manage_users')

        elif action == 'filter':
            user = request.user
            manage_user = None
            if user.is_superuser:
                context = {
                    'can_export_manage_user': True,
                    'can_view_manage_user': True,
                    'can_filter_manage_user': True,
                    'can_add_manage_user': True,  
                    'can_edit_manage_user': True,
                    'can_delete_manage_user': True,
                    'can_status_manage_user': True,
                    'can_ter_status_manage_user': True, 
                    'can_rel_status_manage_user': True,
                    'can_view_unique_manage_user': True, 
                }
            else:
                try:
                    manage_user = ManageUser.objects.get(custom_user_id=user.id)
                except ManageUser.DoesNotExist:
                    manage_user = None

                if manage_user and not manage_user.can_view_manage_user:
                    return redirect('user_not_allowed') 
    
            # Get the list of ManageUser instances
            users = ManageUser.objects.filter(Q(status=0) | Q(status=1)).order_by('-id')
            all_users = ManageUser.objects.filter(Q(status=0) | Q(status=1))
            user_types = UserType.objects.filter(Q(status=0) | Q(status=1))
            roles = ManageUserRole.objects.filter(Q(status=0) | Q(status=1))
            
            # Get users who have releave = 1
            releave_users = UserProfileStatus.objects.filter(releave=1).values_list('name_id', flat=True)
            terminated_users = UserProfileStatus.objects.filter(terminate=1).values_list('name_id', flat=True)

            user_counts = UserType.objects.annotate(user_count=Count('manageuser', filter=Q(manageuser__status__in=[0, 1])))

            user_profile_status = UserProfileStatus.objects.filter(Q(terminate=1) | Q(releave=1))
            user_status_map = {status.name.id: {'terminate': status.terminate, 'releave': status.releave} for status in user_profile_status}

            # Get filter values from the request
            filter_type = request.POST.get('filter_type')
            filter_user = request.POST.get('filter_user')
            filter_mob = request.POST.get('filter_mob')
            filter_role = request.POST.get('filter_role')
            filter_status = request.POST.get('filter_status')
            date_filter = request.POST.get('dt_fill_issue_rpt')
            filter_date_cfrom = request.POST.get('filter_date_cfrom')
            filter_date_cto = request.POST.get('filter_date_cto')

            if not filter_type and not filter_user and not filter_mob and not filter_role and not filter_role and not filter_status and date_filter == 'all':
                return redirect('sa_manage_users')

            today_date = timezone.now().date()

            # Apply filters based on the form inputs
            if filter_type:
                users = users.filter(usertype__code=filter_type)
            if filter_user:
                users = users.filter(id=filter_user)
            if filter_mob:
                users = users.filter(mobile_no=filter_mob)
            if filter_role:
                users = users.filter(role__id=filter_role)
            if filter_status:
                if filter_status == '1':  # Active
                    users = users.exclude(id__in=user_status_map.keys())
                elif filter_status == '2':  # Terminated
                    users = users.filter(id__in=terminated_users)
                elif filter_status == '3':  # Releaved
                    users = users.filter(id__in=releave_users)

                    # Date filtering
            if date_filter == 'today':
                users = users.filter(created_at__date=today_date)
            elif date_filter == 'week':
                start_of_week = today_date - timedelta(days=today_date.weekday())  # Monday
                users = users.filter(created_at__date__range=[start_of_week, today_date])
            elif date_filter == 'monthly':
                users = users.filter(created_at__year=today_date.year, created_at__month=today_date.month)
            elif date_filter == 'custom_date':
                custom_from_date = request.GET.get('filter_date_cfrom')
                custom_to_date = request.GET.get('filter_date_cto')
                if custom_from_date and custom_to_date:
                    # Convert the date format from DD-MM-YYYY to YYYY-MM-DD
                    custom_from_date = datetime.strptime(custom_from_date, '%d-%m-%Y').date()
                    custom_to_date = datetime.strptime(custom_to_date, '%d-%m-%Y').date()
                    users = users.filter(created_at__date__range=[custom_from_date, custom_to_date])


            context = {
                'all_users': all_users,
                'user_types': user_types,
                'roles': roles,
                'users': users,
                'user_status_map': user_status_map,
                'user_counts': user_counts,
                'releave_users': releave_users,
                'terminated_users': terminated_users,
                'filter_type': filter_type if filter_type else '',
                'filter_user': int(filter_user) if filter_user else '',
                'filter_mob': filter_mob if filter_mob else '',
                'filter_role': int(filter_role) if filter_role else '',
                'filter_status': int(filter_status) if filter_status else '',
                'date_filter': date_filter if date_filter else 'all',
                'filter_date_cfrom': filter_date_cfrom if filter_date_cfrom else '',
                'filter_date_cto': filter_date_cto if filter_date_cto else '',
                'can_export_manage_user': manage_user.can_export_manage_user if manage_user else False,
                'can_view_manage_user': manage_user.can_view_manage_user if manage_user else False,
                'can_filter_manage_user': manage_user.can_filter_manage_user if manage_user else False,
                'can_add_manage_user': manage_user.can_add_manage_user if manage_user else False,
                'can_edit_manage_user': manage_user.can_edit_manage_user if manage_user else False,
                'can_delete_manage_user': manage_user.can_delete_manage_user if manage_user else False,
                'can_status_manage_user': manage_user.can_status_manage_user if manage_user else False,
                'can_ter_status_manage_user': manage_user.can_ter_status_manage_user if manage_user else False,
                'can_rel_status_manage_user': manage_user.can_rel_status_manage_user if manage_user else False,
                'can_view_unique_manage_user': manage_user.can_view_unique_manage_user if manage_user else False,

                # 'can_export_manage_user': manage_user.can_export_manage_user,
                # 'can_view_manage_user': manage_user.can_view_manage_user,
                # 'can_filter_manage_user': manage_user.can_filter_manage_user,
                # 'can_add_manage_user': manage_user.can_add_manage_user,
                # 'can_edit_manage_user': manage_user.can_edit_manage_user,
                # 'can_delete_manage_user': manage_user.can_delete_manage_user,
                # 'can_status_manage_user': manage_user.can_status_manage_user,
                # 'can_ter_status_manage_user': manage_user.can_ter_status_manage_user,
                # 'can_rel_status_manage_user': manage_user.can_rel_status_manage_user,
                # 'can_view_unique_manage_user': manage_user.can_view_unique_manage_user,
                # 'date': auth_user_setings.date_format
            }
            return render(request, 'pages/super_admin/users_management/manage_users/list.html', context)

class ManageUsersCreate(LoginRequiredMixin, View):
    def get(self, request):
        trigger_subscription()
        users = ManageUser.objects.filter(Q(status=0) | Q(status=1))
        gender = Gender.objects.filter(Q(status=0) | Q(status=1))
        employee_type = EmployeeType.objects.filter(Q(status=0) | Q(status=1))
        country = Country.objects.filter(Q(status=0) | Q(status=1))
        state = State.objects.filter(Q(status=0) | Q(status=1))
        city = City.objects.filter(Q(status=0) | Q(status=1))
        taluk = Taluk.objects.filter(Q(status=0) | Q(status=1))
        village = Village.objects.filter(Q(status=0) | Q(status=1))
        role = ManageUserRole.objects.filter(status=0)

        role_permissions = None  
        selected_role = request.GET.get('role', None)  

        users_with_numeric_phone_numbers = CustomUser.objects.filter(
            phone_number__regex=r'^\d+$'
        )

        users_with_email = CustomUser.objects.filter(email__isnull=False)

        if selected_role:
            try:
                role_obj = ManageUserRole.objects.get(id=selected_role) 
                role_permissions = {
 
                    'can_view_general_setting'  : role_obj.can_view_general_setting,
                    'can_edit_general_setting' : role_obj.can_edit_general_setting ,

                    'can_add_country' :role_obj.can_add_country,
                    'can_edit_country' :role_obj.can_edit_country,
                    'can_view_country' : role_obj.can_view_country,
                    'can_delete_country' :  role_obj.can_delete_country,
                    'can_status_country' :  role_obj.can_status_country,

                    'can_add_state' :  role_obj.can_add_state,
                    'can_edit_state' :  role_obj.can_edit_state,
                    'can_view_state' :  role_obj.can_view_state,
                    'can_delete_state' :  role_obj.can_delete_state,
                    'can_status_state' :  role_obj.can_status_state,

                    'can_add_city' : role_obj.can_add_city,
                    'can_edit_city' :  role_obj.can_edit_city,
                    'can_view_city' :  role_obj.can_view_city,
                    'can_delete_city' :  role_obj.can_delete_city,
                    'can_status_city' : role_obj.can_status_city,

                    'can_add_taluk' : role_obj.can_add_taluk,
                    'can_edit_taluk' : role_obj.can_edit_taluk,
                    'can_view_taluk' :role_obj.can_view_taluk,
                    'can_delete_taluk' : role_obj.can_delete_taluk,
                    'can_status_taluk' : role_obj.can_status_taluk,

                    'can_add_village' : role_obj.can_add_village,
                    'can_edit_village' :  role_obj.can_edit_village,
                    'can_view_village' :  role_obj.can_view_village,
                    'can_delete_village' :  role_obj.can_delete_village,
                    'can_status_village' :  role_obj.can_status_village,

                    # Data Management

                    'can_add_land_unit' :  role_obj.can_add_land_unit,
                    'can_edit_land_unit' :  role_obj.can_edit_land_unit,
                    'can_view_land_unit' :  role_obj.can_view_land_unit,
                    'can_delete_land_unit' :  role_obj.can_delete_land_unit,
                    'can_status_land_unit' :  role_obj.can_status_land_unit,

                    'can_add_area_unit' : role_obj.can_add_area_unit,
                    'can_edit_area_unit' :  role_obj.can_edit_area_unit,
                    'can_view_area_unit' :  role_obj.can_view_area_unit,
                    'can_delete_area_unit' :  role_obj.can_delete_area_unit,
                    'can_status_area_unit' :  role_obj.can_status_area_unit,

                    'can_add_soil_type' :  role_obj.can_add_soil_type,
                    'can_edit_soil_type' :  role_obj.can_edit_soil_type,
                    'can_view_soil_type' :  role_obj.can_view_soil_type,
                    'can_delete_soil_type' : role_obj.can_delete_soil_type,
                    'can_status_soil_type' : role_obj.can_status_soil_type,

                    'can_add_crop_type' :  role_obj.can_add_crop_type,
                    'can_edit_crop_type' :  role_obj.can_edit_crop_type,
                    'can_view_crop_type' :  role_obj.can_view_crop_type,
                    'can_delete_crop_type' :  role_obj.can_delete_crop_type,
                    'can_status_crop_type' : role_obj.can_status_crop_type,

                    'can_add_quality' :  role_obj.can_add_quality,
                    'can_edit_quality' :  role_obj.can_edit_quality,
                    'can_view_quality' : role_obj.can_view_quality,
                    'can_delete_quality' :  role_obj.can_delete_quality,
                    'can_status_quality' :  role_obj.can_status_quality,

                    'can_add_crop' :  role_obj.can_add_crop,
                    'can_edit_crop' :  role_obj.can_edit_crop,
                    'can_view_crop' :  role_obj.can_view_crop,
                    'can_delete_crop' :  role_obj. can_delete_crop,
                    'can_status_crop' :  role_obj.can_status_crop,

                    'can_add_product_type' :  role_obj.can_add_product_type,
                    'can_edit_product_type' :  role_obj.can_edit_product_type,
                    'can_view_product_type' :  role_obj.can_view_product_type,
                    'can_delete_product_type' :  role_obj.can_delete_product_type,
                    'can_status_product_type' :  role_obj.can_status_product_type,

                    'can_add_vehicle_category' : role_obj.can_add_vehicle_category,
                    'can_edit_vehicle_category' :  role_obj.can_edit_vehicle_category,
                    'can_view_vehicle_category' : role_obj.can_view_vehicle_category,
                    'can_delete_vehicle_category' : role_obj.can_delete_vehicle_category,
                    'can_status_vehicle_category' :  role_obj.can_status_vehicle_category,

                    'can_add_manage_vehicle' :  role_obj.can_add_manage_vehicle,
                    'can_edit_manage_vehicle' :  role_obj.can_edit_manage_vehicle,
                    'can_view_manage_vehicle' :  role_obj.can_view_manage_vehicle,
                    'can_delete_manage_vehicle' : role_obj.can_delete_manage_vehicle,
                    'can_status_manage_vehicle' :  role_obj.can_status_manage_vehicle,

                    'can_add_machinery_category' :  role_obj.can_add_machinery_category,
                    'can_edit_machinery_category' : role_obj.can_edit_machinery_category,
                    'can_view_machinery_category' :  role_obj.can_view_machinery_category,
                    'can_delete_machinery_category' :  role_obj.can_delete_machinery_category,
                    'can_status_machinery_category' :  role_obj.can_status_machinery_category,

                    'can_add_manage_machinery' :  role_obj.can_add_manage_machinery,
                    'can_edit_manage_machinery' :  role_obj.can_edit_manage_machinery,
                    'can_view_manage_machinery' :  role_obj.can_view_manage_machinery,
                    'can_delete_manage_machinery' :  role_obj.can_delete_manage_machinery,
                    'can_status_manage_machinery' :  role_obj.can_status_manage_machinery,

                    'can_add_tool_category' : role_obj.can_add_tool_category,
                    'can_edit_tool_category' :  role_obj.can_edit_tool_category,
                    'can_view_tool_category' : role_obj.can_view_tool_category,
                    'can_delete_tool_category' : role_obj.can_delete_tool_category,
                    'can_status_tool_category' :  role_obj.can_status_tool_category,

                    'can_add_tool' :  role_obj.can_add_tool,
                    'can_edit_tool' :  role_obj.can_edit_tool,
                    'can_view_tool' :  role_obj.can_view_tool,
                    'can_delete_tool' :  role_obj.can_delete_tool,
                    'can_status_tool' :  role_obj.can_status_tool,

                    'can_add_expense_category' :  role_obj.can_add_expense_category,
                    'can_edit_expense_category' :  role_obj.can_edit_expense_category,
                    'can_view_expense_category' :  role_obj.can_view_expense_category,
                    'can_delete_expense_category' :  role_obj.can_delete_expense_category,
                    'can_status_expense_category' :  role_obj.can_status_expense_category,

                    'can_add_expense' :  role_obj.can_add_expense,
                    'can_edit_expense' : role_obj.can_edit_expense,
                    'can_view_expense' : role_obj.can_view_expense,
                    'can_delete_expense' : role_obj.can_delete_expense,
                    'can_status_expense' : role_obj.can_status_expense,

                    'can_add_harvesting_type' : role_obj.can_add_harvesting_type,
                    'can_edit_harvesting_type' :role_obj.can_edit_harvesting_type,
                    'can_view_harvesting_type' : role_obj.can_view_harvesting_type,
                    'can_delete_harvesting_type' : role_obj.can_delete_harvesting_type,
                    'can_status_harvesting_type' : role_obj.can_status_harvesting_type,

                    'can_add_detection' : role_obj.can_add_detection,
                    'can_edit_detection' : role_obj.can_edit_detection,
                    'can_view_detection' : role_obj.can_view_detection,
                    'can_delete_detection' : role_obj.can_delete_detection,
                    'can_status_detection' : role_obj.can_status_detection,

                    # farmer management
                    'can_add_farmer' : role_obj.can_add_farmer,
                    'can_view_farmer' : role_obj.can_view_farmer,
                    'can_edit_farmer' : role_obj.can_edit_farmer,
                    'can_delete_farmer' : role_obj.can_delete_farmer,
                    'can_view_unique_farmer' :role_obj.can_view_unique_farmer,
                    'can_update_farmer_status' : role_obj.can_update_farmer_status,
                    'can_export_farmer_data' : role_obj.can_export_farmer_data,
                    'can_filter_farmer_data' : role_obj.can_filter_farmer_data,

                    # package management
                    'can_add_package' :role_obj.can_add_package,
                    'can_view_package' : role_obj.can_view_package,
                    'can_edit_package' : role_obj.can_edit_package,
                    'can_delete_package' : role_obj.can_delete_package,
                    'can_view_unique_package' : role_obj.can_view_unique_package,

                    # subscription management
                    'can_add_subscription' : role_obj.can_add_subscription,
                    'can_view_subscription' : role_obj.can_view_subscription,
                    'can_edit_subscription' : role_obj.can_edit_subscription,
                    'can_delete_subscription' : role_obj.can_delete_subscription,
                    'can_view_unique_subscription' :role_obj.can_view_unique_subscription,
                    'can_export_subscription' : role_obj.can_export_subscription,
                    'can_filter_subscription' :role_obj.can_filter_subscription,
                    'can_activeplan_subscription' : role_obj.can_activeplan_subscription,
                    'can_renewalplan_subscription' : role_obj.can_renewalplan_subscription,

                    # --> Market Price

                    'can_add_manage_product' :  role_obj.can_add_manage_product,
                    'can_view_manage_product' :  role_obj.can_view_manage_product,
                    'can_edit_manage_product' :  role_obj.can_edit_manage_product,
                    'can_delete_manage_product' :  role_obj.can_delete_manage_product,
                    'can_filter_manage_product' :  role_obj.can_filter_manage_product,
                    'can_update_manage_product' :  role_obj.can_update_manage_product,
                    'can_graph_manage_product' :  role_obj.can_graph_manage_product,
                    'can_staff_manage_product' : role_obj.can_staff_manage_product,

                    'can_filter_market_report'  : role_obj.can_filter_market_report,
                    'can_view_market_report' : role_obj.can_view_market_report,
                    'can_edit_market_report' : role_obj.can_edit_market_report,
                    'can_graph_market_report' : role_obj.can_graph_market_report,

                    'can_filter_product_market_report'  :role_obj.can_filter_product_market_report,
                    'can_view_product_market_report' :  role_obj.can_view_product_market_report,
                    'can_edit_product_market_report' :  role_obj.can_edit_product_market_report,
                    'can_graph_product_market_report' :  role_obj.can_graph_product_market_report,

                    # --> Market Management

                    'can_add_market' :  role_obj.can_add_market,
                    'can_view_market' :  role_obj.can_view_market,
                    'can_edit_market' : role_obj.can_edit_market,
                    'can_delete_market' :  role_obj.can_delete_market,
                    'can_view_unique_market' :  role_obj.can_view_unique_market,
                    'can_status_market' :  role_obj.can_status_market,
                    'can_export_market' :  role_obj.can_export_market,
                    'can_filter_market' :  role_obj.can_filter_market,

                    'can_add_allocate_market' :  role_obj.can_add_allocate_market,
                    'can_view_allocate_market' :  role_obj.can_view_allocate_market,
                    'can_edit_allocate_market' :  role_obj.can_edit_allocate_market,
                    'can_delete_allocate_market' :  role_obj.can_delete_allocate_market,
                    'can_view_unique_allocate_market' :  role_obj.can_view_unique_allocate_market,
                    'can_status_allocate_market' :  role_obj.can_status_allocate_market,
                    'can_export_allocate_market' : role_obj.can_export_allocate_market,

                    # --> Schedule Management

                    'can_add_schedule_activity_type' : role_obj.can_add_schedule_activity_type,
                    'can_edit_schedule_activity_type' : role_obj.can_edit_schedule_activity_type,
                    'can_view_schedule_activity_type' : role_obj.can_view_schedule_activity_type,
                    'can_delete_schedule_activity_type' : role_obj.can_delete_schedule_activity_type,
                    'can_status_schedule_activity_type' : role_obj.can_status_schedule_activity_type,

                    'can_add_schedule'  :  role_obj.can_add_schedule,
                    'can_edit_schedule'  :  role_obj.can_edit_schedule,
                    'can_view_schedule' :  role_obj.can_view_schedule,
                    'can_delete_schedule' :  role_obj.can_delete_schedule,
                    'can_status_schedule' :  role_obj.can_status_schedule,
                    'can_view_unique_schedule' :  role_obj.can_view_unique_schedule,

                    # --> NearBy Locations

                    'can_add_near_by_location_category' :  role_obj.can_add_near_by_location_category,
                    'can_edit_near_by_location_category' :  role_obj.can_edit_near_by_location_category,
                    'can_view_near_by_location_category' :  role_obj.can_view_near_by_location_category,
                    'can_delete_near_by_location_category' :  role_obj.can_delete_near_by_location_category,
                    'can_status_near_by_location_category' :  role_obj.can_status_near_by_location_category,

                    'can_add_near_by_locations' :  role_obj.can_add_near_by_locations,
                    'can_edit_near_by_locations' :  role_obj.can_edit_near_by_locations,
                    'can_view_near_by_locations' :  role_obj.can_view_near_by_locations,
                    'can_delete_near_by_locations' :  role_obj.can_delete_near_by_locations,
                    'can_status_near_by_locations' :  role_obj.can_status_near_by_locations,
                    'can_export_near_by_locations' :  role_obj.can_export_near_by_locations,
                    'can_filter_near_by_locations' :  role_obj.can_filter_near_by_locations,
                    'can_view_unique_near_by_locations' :  role_obj.can_view_unique_near_by_locations,

                    # --> Workers Availability

                    'can_add_workers_type' :  role_obj.can_add_workers_type,
                    'can_edit_workers_type' :  role_obj.can_edit_workers_type,
                    'can_view_workers_type' :  role_obj.can_view_workers_type,
                    'can_delete_workers_type' :  role_obj.can_delete_workers_type,
                    'can_update_workers_type_status' : role_obj.can_update_workers_type_status,

                    'can_add_manage_workers' : role_obj.can_add_manage_workers,
                    'can_view_manage_workers' : role_obj.can_view_manage_workers,
                    'can_edit_manage_workers' : role_obj.can_edit_manage_workers,
                    'can_update_manage_workers' : role_obj.can_update_manage_workers,
                    'can_delete_manage_workers' : role_obj.can_delete_manage_workers,
                    'can_view_unique_manage_workers': role_obj.can_view_unique_manage_workers,
                    'can_update_manage_workers_status' :  role_obj.can_update_manage_workers_status,
                    'can_export_manage_workers': role_obj.can_export_manage_workers,
                    'can_filter_manage_workers' : role_obj.can_filter_manage_workers,

                    # ---> Rental Availability

                    'can_view_rental_availability' : role_obj.can_view_rental_availability,
                    'can_filter_rental_availability' : role_obj.can_filter_rental_availability,
                    'can_export_rental_availability' : role_obj.can_export_rental_availability,
                   
                    
                    # ---> Guidelines Management 

                    'can_add_guidelines_category' : role_obj.can_add_guidelines_category,
                    'can_view_guidelines_category' : role_obj.can_edit_guidelines_category,
                    'can_edit_guidelines_category' : role_obj.can_delete_guidelines_category,
                    'can_delete_guidelines_category' : role_obj.can_delete_guidelines_category,
                    'can_update_guidelines_category_status' :  role_obj.can_update_guidelines_category_status,

                    'can_add_guidelines' : role_obj.can_add_guidelines,
                    'can_view_guidelines' : role_obj.can_view_guidelines,
                    'can_edit_guidelines' : role_obj.can_edit_guidelines,
                    'can_delete_guidelines' : role_obj.can_delete_guidelines,
                    'can_view_unique_guidelines': role_obj.can_view_unique_guidelines,
                    'can_update_guidelines_status' : role_obj.can_update_guidelines_status,
                    'can_export_guidelines' : role_obj.can_export_guidelines,
                    'can_filter_guidelines' : role_obj.can_filter_guidelines,

                    # ---> User Management

                    'can_view_manage_user' : role_obj.can_view_manage_user,
                    'can_add_manage_user' : role_obj.can_add_manage_user,
                    'can_edit_manage_user' : role_obj.can_edit_manage_user,
                    'can_delete_manage_user' : role_obj.can_delete_manage_user,
                    'can_export_manage_user' : role_obj.can_export_manage_user,
                    'can_filter_manage_user' : role_obj.can_filter_manage_user,
                    'can_status_manage_user' : role_obj.can_status_manage_user,
                    'can_ter_status_manage_user' : role_obj.can_ter_status_manage_user,
                    'can_rel_status_manage_user' : role_obj.can_rel_status_manage_user,
                    'can_view_unique_manage_user' : role_obj.can_view_unique_manage_user,

                    'can_add_manage_user_role' : role_obj.can_add_manage_user_role,
                    'can_view_manage_user_role' : role_obj.can_view_manage_user_role,
                    'can_status_manage_user_role' : role_obj.can_status_manage_user_role,
                    'can_view_unique_manage_user_role' : role_obj.can_view_unique_manage_user_role,
                    'can_edit_manage_user_role' : role_obj.can_edit_manage_user_role,
                    'can_delete_manage_user_role' : role_obj.can_delete_manage_user_role,

                    # --> Report

                    'can_export_farmer_report' : role_obj.can_export_farmer_report,
                    'can_view_farmer_report' : role_obj.can_view_farmer_report,
                    'can_filter_farmer_report' : role_obj.can_filter_farmer_report,
                    'can_view_unique_report' : role_obj.can_view_unique_report,


                    'can_export_subscription_report' :role_obj.can_export_subscription_report,
                    'can_view_subscription_report' : role_obj.can_view_subscription_report,
                    'can_filter_subscription_report' : role_obj.can_filter_subscription_report,
                    'can_view_unique_subscription_report' :role_obj.can_view_unique_subscription_report,

                    'can_dashboard_count':role_obj.can_dashboard_count,
                    # 'can_dashboard_total_revenue' = role.can_dashboard_total_revenue
                    # 'can_farmer_graph' = role.can_farmer_graph
                    # 'can_subscription_graph' = role.can_subscription_graph
                    # 'can_revenue_graph' = role.can_revenue_graph
                    # 'can_market_view'  = role.can_market_view
                    # 'can_market_graph' = role.can_market_graph
                    # 'can_market_view_staff' = role.can_market_view_staff

                    'can_add_email_config'  : role_obj.can_add_email_config,
                    'can_view_email_config' : role_obj.can_view_email_config,
                    'can_status_email_config'  :role_obj.can_status_email_config,
                    'can_edit_email_config'  : role_obj.can_edit_email_config,
                    'can_delete_email_config' : role_obj.can_delete_email_config,

                    'can_view_sms_config' : role_obj.can_view_sms_config,
                    'can_status_sms_config' :role_obj.can_status_sms_config,
                    'can_delete_sms_config' :role_obj.can_delete_sms_config,
                    'can_edit_sms_config' : role_obj.can_edit_sms_config,

                    'can_view_inventory_category':role_obj.can_view_inventory_category,
                    'can_add_inventory_category':role_obj.can_add_inventory_category,
                    'can_status_inventory_category':role_obj.can_status_inventory_category,
                    'can_edit_inventory_category':role_obj.can_edit_inventory_category,
                    'can_delete_inventory_category':role_obj.can_delete_inventory_category,
            
                    'can_view_inventory_items':role_obj.can_view_inventory_items,
                    'can_add_inventory_items':role_obj.can_add_inventory_items,
                    'can_status_inventory_items':role_obj.can_status_inventory_items,
                    'can_edit_inventory_items':role_obj.can_edit_inventory_items,
                    'can_delete_inventory_items':role_obj.can_delete_inventory_items,
                

                    'can_view_document_category':role_obj.can_view_document_category,
                    'can_add_document_category':role_obj.can_add_document_category,
                    'can_status_document_category':role_obj.can_status_document_category,
                    'can_edit_document_category':role_obj.can_edit_document_category,
                    'can_delete_document_category':role_obj.can_delete_document_category,


                }
            except ManageUserRole.DoesNotExist:
                role_permissions = None  


            users_permissions = []
            for user in users:
                user_permissions = {
                    'id': user.id,
                    'name': user.name,
                    'permissions': {
                    'can_view_general_setting'  : user.can_view_general_setting,
                    'can_edit_general_setting' : user.can_edit_general_setting ,

                    'can_add_country' :user.can_add_country,
                    'can_edit_country' :user.can_edit_country,
                    'can_view_country' : user.can_view_country,
                    'can_delete_country' :  user.can_delete_country,
                    'can_status_country' :  user.can_status_country,

                    'can_add_state' :  user.can_add_state,
                    'can_edit_state' :  user.can_edit_state,
                    'can_view_state' :  user.can_view_state,
                    'can_delete_state' :  user.can_delete_state,
                    'can_status_state' :  user.can_status_state,

                    'can_add_city' : user.can_add_city,
                    'can_edit_city' :  user.can_edit_city,
                    'can_view_city' :  user.can_view_city,
                    'can_delete_city' :  user.can_delete_city,
                    'can_status_city' : user.can_status_city,

                    'can_add_taluk' : user.can_add_taluk,
                    'can_edit_taluk' : user.can_edit_taluk,
                    'can_view_taluk' :user.can_view_taluk,
                    'can_delete_taluk' : user.can_delete_taluk,
                    'can_status_taluk' : user.can_status_taluk,

                    'can_add_village' : user.can_add_village,
                    'can_edit_village' :  user.can_edit_village,
                    'can_view_village' :  user.can_view_village,
                    'can_delete_village' :  user.can_delete_village,
                    'can_status_village' :  user.can_status_village,

                    # Data Management

                    'can_add_land_unit' :  user.can_add_land_unit,
                    'can_edit_land_unit' :  user.can_edit_land_unit,
                    'can_view_land_unit' :  user.can_view_land_unit,
                    'can_delete_land_unit' :  user.can_delete_land_unit,
                    'can_status_land_unit' :  user.can_status_land_unit,

                    'can_add_area_unit' : user.can_add_area_unit,
                    'can_edit_area_unit' :  user.can_edit_area_unit,
                    'can_view_area_unit' :  user.can_view_area_unit,
                    'can_delete_area_unit' :  user.can_delete_area_unit,
                    'can_status_area_unit' :  user.can_status_area_unit,

                    'can_add_soil_type' :  user.can_add_soil_type,
                    'can_edit_soil_type' :  user.can_edit_soil_type,
                    'can_view_soil_type' :  user.can_view_soil_type,
                    'can_delete_soil_type' : user.can_delete_soil_type,
                    'can_status_soil_type' : user.can_status_soil_type,

                    'can_add_crop_type' :  user.can_add_crop_type,
                    'can_edit_crop_type' :  user.can_edit_crop_type,
                    'can_view_crop_type' :  user.can_view_crop_type,
                    'can_delete_crop_type' :  user.can_delete_crop_type,
                    'can_status_crop_type' : user.can_status_crop_type,

                    'can_add_quality' :  user.can_add_quality,
                    'can_edit_quality' :  user.can_edit_quality,
                    'can_view_quality' : user.can_view_quality,
                    'can_delete_quality' :  user.can_delete_quality,
                    'can_status_quality' :  user.can_status_quality,

                    'can_add_crop' :  user.can_add_crop,
                    'can_edit_crop' :  user.can_edit_crop,
                    'can_view_crop' :  user.can_view_crop,
                    'can_delete_crop' :  user. can_delete_crop,
                    'can_status_crop' :  user.can_status_crop,

                    'can_add_product_type' :  user.can_add_product_type,
                    'can_edit_product_type' :  user.can_edit_product_type,
                    'can_view_product_type' :  user.can_view_product_type,
                    'can_delete_product_type' :  user.can_delete_product_type,
                    'can_status_product_type' :  user.can_status_product_type,

                    'can_add_vehicle_category' : user.can_add_vehicle_category,
                    'can_edit_vehicle_category' :  user.can_edit_vehicle_category,
                    'can_view_vehicle_category' : user.can_view_vehicle_category,
                    'can_delete_vehicle_category' : user.can_delete_vehicle_category,
                    'can_status_vehicle_category' :  user.can_status_vehicle_category,

                    'can_add_manage_vehicle' :  user.can_add_manage_vehicle,
                    'can_edit_manage_vehicle' :  user.can_edit_manage_vehicle,
                    'can_view_manage_vehicle' :  user.can_view_manage_vehicle,
                    'can_delete_manage_vehicle' : user.can_delete_manage_vehicle,
                    'can_status_manage_vehicle' :  user.can_status_manage_vehicle,

                    'can_add_machinery_category' :  user.can_add_machinery_category,
                    'can_edit_machinery_category' : user.can_edit_machinery_category,
                    'can_view_machinery_category' :  user.can_view_machinery_category,
                    'can_delete_machinery_category' :  user.can_delete_machinery_category,
                    'can_status_machinery_category' :  user.can_status_machinery_category,

                    'can_add_manage_machinery' :  user.can_add_manage_machinery,
                    'can_edit_manage_machinery' :  user.can_edit_manage_machinery,
                    'can_view_manage_machinery' :  user.can_view_manage_machinery,
                    'can_delete_manage_machinery' :  user.can_delete_manage_machinery,
                    'can_status_manage_machinery' :  user.can_status_manage_machinery,

                    'can_add_tool_category' : user.can_add_tool_category,
                    'can_edit_tool_category' :  user.can_edit_tool_category,
                    'can_view_tool_category' : user.can_view_tool_category,
                    'can_delete_tool_category' : user.can_delete_tool_category,
                    'can_status_tool_category' :  user.can_status_tool_category,

                    'can_add_tool' :  user.can_add_tool,
                    'can_edit_tool' :  user.can_edit_tool,
                    'can_view_tool' :  user.can_view_tool,
                    'can_delete_tool' :  user.can_delete_tool,
                    'can_status_tool' :  user.can_status_tool,

                    'can_add_expense_category' :  user.can_add_expense_category,
                    'can_edit_expense_category' :  user.can_edit_expense_category,
                    'can_view_expense_category' :  user.can_view_expense_category,
                    'can_delete_expense_category' :  user.can_delete_expense_category,
                    'can_status_expense_category' :  user.can_status_expense_category,

                    'can_add_expense' :  user.can_add_expense,
                    'can_edit_expense' : user.can_edit_expense,
                    'can_view_expense' : user.can_view_expense,
                    'can_delete_expense' : user.can_delete_expense,
                    'can_status_expense' : user.can_status_expense,

                    'can_add_harvesting_type' : user.can_add_harvesting_type,
                    'can_edit_harvesting_type' :user.can_edit_harvesting_type,
                    'can_view_harvesting_type' : user.can_view_harvesting_type,
                    'can_delete_harvesting_type' : user.can_delete_harvesting_type,
                    'can_status_harvesting_type' : user.can_status_harvesting_type,

                    'can_add_detection' : user.can_add_detection,
                    'can_edit_detection' : user.can_edit_detection,
                    'can_view_detection' : user.can_view_detection,
                    'can_delete_detection' : user.can_delete_detection,
                    'can_status_detection' : user.can_status_detection,

                    # farmer management
                    'can_add_farmer' : user.can_add_farmer,
                    'can_view_farmer' : user.can_view_farmer,
                    'can_edit_farmer' : user.can_edit_farmer,
                    'can_delete_farmer' : user.can_delete_farmer,
                    'can_view_unique_farmer' :user.can_view_unique_farmer,
                    'can_update_farmer_status' : user.can_update_farmer_status,
                    'can_export_farmer_data' : user.can_export_farmer_data,
                    'can_filter_farmer_data' : user.can_filter_farmer_data,

                    # package management
                    'can_add_package' :user.can_add_package,
                    'can_view_package' : user.can_view_package,
                    'can_edit_package' : user.can_edit_package,
                    'can_delete_package' : user.can_delete_package,
                    'can_view_unique_package' : user.can_view_unique_package,

                    # subscription management
                    'can_add_subscription' : user.can_add_subscription,
                    'can_view_subscription' : user.can_view_subscription,
                    'can_edit_subscription' : user.can_edit_subscription,
                    'can_delete_subscription' : user.can_delete_subscription,
                    'can_view_unique_subscription' :user.can_view_unique_subscription,
                    'can_export_subscription' : user.can_export_subscription,
                    'can_filter_subscription' :user.can_filter_subscription,
                    'can_activeplan_subscription' : user.can_activeplan_subscription,
                    'can_renewalplan_subscription' : user.can_renewalplan_subscription,

                    # --> Market Price

                    'can_add_manage_product' :  user.can_add_manage_product,
                    'can_view_manage_product' :  user.can_view_manage_product,
                    'can_edit_manage_product' :  user.can_edit_manage_product,
                    'can_delete_manage_product' :  user.can_delete_manage_product,
                    'can_filter_manage_product' :  user.can_filter_manage_product,
                    'can_update_manage_product' :  user.can_update_manage_product,
                    'can_graph_manage_product' :  user.can_graph_manage_product,
                    'can_staff_manage_product' : user.can_staff_manage_product,

                    'can_filter_market_report'  : user.can_filter_market_report,
                    'can_view_market_report' : user.can_view_market_report,
                    'can_edit_market_report' : user.can_edit_market_report,
                    'can_graph_market_report' : user.can_graph_market_report,

                    'can_filter_product_market_report'  :user.can_filter_product_market_report,
                    'can_view_product_market_report' :  user.can_view_product_market_report,
                    'can_edit_product_market_report' :  user.can_edit_product_market_report,
                    'can_graph_product_market_report' :  user.can_graph_product_market_report,

                    # --> Market Management

                    'can_add_market' :  user.can_add_market,
                    'can_view_market' :  user.can_view_market,
                    'can_edit_market' : user.can_edit_market,
                    'can_delete_market' :  user.can_delete_market,
                    'can_view_unique_market' :  user.can_view_unique_market,
                    'can_status_market' :  user.can_status_market,
                    'can_export_market' :  user.can_export_market,
                    'can_filter_market' :  user.can_filter_market,

                    'can_add_allocate_market' :  user.can_add_allocate_market,
                    'can_view_allocate_market' :  user.can_view_allocate_market,
                    'can_edit_allocate_market' :  user.can_edit_allocate_market,
                    'can_delete_allocate_market' :  user.can_delete_allocate_market,
                    'can_view_unique_allocate_market' :  user.can_view_unique_allocate_market,
                    'can_status_allocate_market' :  user.can_status_allocate_market,
                    'can_export_allocate_market' : user.can_export_allocate_market,

                    # --> Schedule Management

                    'can_add_schedule_activity_type' : user.can_add_schedule_activity_type,
                    'can_edit_schedule_activity_type' : user.can_edit_schedule_activity_type,
                    'can_view_schedule_activity_type' : user.can_view_schedule_activity_type,
                    'can_delete_schedule_activity_type' : user.can_delete_schedule_activity_type,
                    'can_status_schedule_activity_type' : user.can_status_schedule_activity_type,

                    'can_add_schedule'  :  user.can_add_schedule,
                    'can_edit_schedule'  :  user.can_edit_schedule,
                    'can_view_schedule' :  user.can_view_schedule,
                    'can_delete_schedule' :  user.can_delete_schedule,
                    'can_status_schedule' :  user.can_status_schedule,
                    'can_view_unique_schedule' :  user.can_view_unique_schedule,

                    # --> NearBy Locations

                    'can_add_near_by_location_category' :  user.can_add_near_by_location_category,
                    'can_edit_near_by_location_category' :  user.can_edit_near_by_location_category,
                    'can_view_near_by_location_category' :  user.can_view_near_by_location_category,
                    'can_delete_near_by_location_category' :  user.can_delete_near_by_location_category,
                    'can_status_near_by_location_category' :  user.can_status_near_by_location_category,

                    'can_add_near_by_locations' :  user.can_add_near_by_locations,
                    'can_edit_near_by_locations' :  user.can_edit_near_by_locations,
                    'can_view_near_by_locations' :  user.can_view_near_by_locations,
                    'can_delete_near_by_locations' :  user.can_delete_near_by_locations,
                    'can_status_near_by_locations' :  user.can_status_near_by_locations,
                    'can_export_near_by_locations' :  user.can_export_near_by_locations,
                    'can_filter_near_by_locations' :  user.can_filter_near_by_locations,
                    'can_view_unique_near_by_locations' :  user.can_view_unique_near_by_locations,

                    # --> Workers Availability

                    'can_add_workers_type' :  user.can_add_workers_type,
                    'can_edit_workers_type' :  user.can_edit_workers_type,
                    'can_view_workers_type' :  user.can_view_workers_type,
                    'can_delete_workers_type' :  user.can_delete_workers_type,
                    'can_update_workers_type_status' : user.can_update_workers_type_status,

                    'can_add_manage_workers' : user.can_add_manage_workers,
                    'can_view_manage_workers' : user.can_view_manage_workers,
                    'can_edit_manage_workers' : user.can_edit_manage_workers,
                    'can_update_manage_workers' : user.can_update_manage_workers,
                    'can_delete_manage_workers' : user.can_delete_manage_workers,
                    'can_view_unique_manage_workers': user.can_view_unique_manage_workers,
                    'can_update_manage_workers_status' :  user.can_update_manage_workers_status,
                    'can_export_manage_workers': user.can_export_manage_workers,
                    'can_filter_manage_workers' : user.can_filter_manage_workers,


                     # ---> Rental Availability

                    'can_view_rental_availability' : role_obj.can_view_rental_availability,
                    'can_filter_rental_availability' : role_obj.can_filter_rental_availability,
                    'can_export_rental_availability' : role_obj.can_export_rental_availability,
                   
                    # ---> Guidelines Management 

                    'can_add_guidelines_category' : user.can_add_guidelines_category,
                    'can_view_guidelines_category' : user.can_edit_guidelines_category,
                    'can_edit_guidelines_category' : user.can_delete_guidelines_category,
                    'can_delete_guidelines_category' : user.can_delete_guidelines_category,
                    'can_update_guidelines_category_status' :  user.can_update_guidelines_category_status,

                    'can_add_guidelines' : user.can_add_guidelines,
                    'can_view_guidelines' : user.can_view_guidelines,
                    'can_edit_guidelines' : user.can_edit_guidelines,
                    'can_delete_guidelines' : user.can_delete_guidelines,
                    'can_view_unique_guidelines': user.can_view_unique_guidelines,
                    'can_update_guidelines_status' : user.can_update_guidelines_status,
                    'can_export_guidelines' : user.can_export_guidelines,
                    'can_filter_guidelines' : user.can_filter_guidelines,

                    # ---> User Management

                    'can_view_manage_user' : user.can_view_manage_user,
                    'can_add_manage_user' : user.can_add_manage_user,
                    'can_edit_manage_user' : user.can_edit_manage_user,
                    'can_delete_manage_user' : user.can_delete_manage_user,
                    'can_export_manage_user' : user.can_export_manage_user,
                    'can_filter_manage_user' : user.can_filter_manage_user,
                    'can_status_manage_user' : user.can_status_manage_user,
                    'can_ter_status_manage_user' : user.can_ter_status_manage_user,
                    'can_rel_status_manage_user' : user.can_rel_status_manage_user,
                    'can_view_unique_manage_user' : user.can_view_unique_manage_user,

                    'can_add_manage_user_role' : user.can_add_manage_user_role,
                    'can_view_manage_user_role' : user.can_view_manage_user_role,
                    'can_status_manage_user_role' : user.can_status_manage_user_role,
                    'can_view_unique_manage_user_role' : user.can_view_unique_manage_user_role,
                    'can_edit_manage_user_role' : user.can_edit_manage_user_role,
                    'can_delete_manage_user_role' : user.can_delete_manage_user_role,

                    # --> Report

                    'can_export_farmer_report' : user.can_export_farmer_report,
                    'can_view_farmer_report' : user.can_view_farmer_report,
                    'can_filter_farmer_report' : user.can_filter_farmer_report,
                    'can_view_unique_report' : user.can_view_unique_report,


                    'can_export_subscription_report' :user.can_export_subscription_report,
                    'can_view_subscription_report' : user.can_view_subscription_report,
                    'can_filter_subscription_report' : user.can_filter_subscription_report,
                    'can_view_unique_subscription_report' :user.can_view_unique_subscription_report,

                    'can_dashboard_count':user.can_dashboard_count,
                    # 'can_dashboard_total_revenue' = role.can_dashboard_total_revenue
                    # 'can_farmer_graph' = role.can_farmer_graph
                    # 'can_subscription_graph' = role.can_subscription_graph
                    # 'can_revenue_graph' = role.can_revenue_graph
                    # 'can_market_view'  = role.can_market_view
                    # 'can_market_graph' = role.can_market_graph
                    # 'can_market_view_staff' = role.can_market_view_staff

                    'can_add_email_config'  : user.can_add_email_config,
                    'can_view_email_config' : user.can_view_email_config,
                    'can_status_email_config'  :user.can_status_email_config,
                    'can_edit_email_config'  : user.can_edit_email_config,
                    'can_delete_email_config' : user.can_delete_email_config,

                    'can_view_sms_config' : user.can_view_sms_config,
                    'can_status_sms_config' :user.can_status_sms_config,
                    'can_delete_sms_config' :user.can_delete_sms_config,
                    'can_edit_sms_config' : user.can_edit_sms_config,

                    'can_view_inventory_category':user.can_view_inventory_category,
                    'can_add_inventory_category':user.can_add_inventory_category,
                    'can_status_inventory_category':user.can_status_inventory_category,
                    'can_edit_inventory_category':user.can_edit_inventory_category,
                    'can_delete_inventory_category':user.can_delete_inventory_category,
            
                    'can_view_inventory_items':user.can_view_inventory_items,
                    'can_add_inventory_items':user.can_add_inventory_items,
                    'can_status_inventory_items':user.can_status_inventory_items,
                    'can_edit_inventory_items':user.can_edit_inventory_items,
                    'can_delete_inventory_items':user.can_delete_inventory_items,
               

                    'can_view_document_category':user.can_view_document_category,
                    'can_add_document_category':user.can_add_document_category,
                    'can_status_document_category':user.can_status_document_category,
                    'can_edit_document_category':user.can_edit_document_category,
                    'can_delete_document_category':user.can_delete_document_category,

                }

                }
                users_permissions.append(user_permissions)

            print(users_permissions)

        context = {
            'users': users,
            'gender': gender,
            'employee_type': employee_type,
            'country': country,
            'state': state,
            'city': city,
            'taluk': taluk,
            'village': village,
            'role': role,
            'role_permissions': role_permissions  ,
            'mb_no': users_with_numeric_phone_numbers,
            'em': users_with_email,
        }

        return render(request, 'pages/super_admin/users_management/manage_users/add.html', context)

def get_role_permissions(request):
    role_id = request.GET.get('role')
    print(role_id)
    if role_id:
        try:
            # Fetch the selected role
            role = get_object_or_404(ManageUserRole, id=role_id)

            role_permissions = {
                'can_view_general_setting'  : role.can_view_general_setting,
                'can_edit_general_setting' : role.can_edit_general_setting ,

                'can_add_country' :role.can_add_country,
                'can_edit_country' :role.can_edit_country,
                'can_view_country' : role.can_view_country,
                'can_delete_country' :  role.can_delete_country,
                'can_status_country' :  role.can_status_country,

                'can_add_state' :  role.can_add_state,
                'can_edit_state' :  role.can_edit_state,
                'can_view_state' :  role.can_view_state,
                'can_delete_state' :  role.can_delete_state,
                'can_status_state' :  role.can_status_state,

                'can_add_city' : role.can_add_city,
                'can_edit_city' :  role.can_edit_city,
                'can_view_city' :  role.can_view_city,
                'can_delete_city' :  role.can_delete_city,
                'can_status_city' : role.can_status_city,

                'can_add_taluk' : role.can_add_taluk,
                'can_edit_taluk' : role.can_edit_taluk,
                'can_view_taluk' :role.can_view_taluk,
                'can_delete_taluk' : role.can_delete_taluk,
                'can_status_taluk' : role.can_status_taluk,

                'can_add_village' : role.can_add_village,
                'can_edit_village' :  role.can_edit_village,
                'can_view_village' :  role.can_view_village,
                'can_delete_village' :  role.can_delete_village,
                'can_status_village' :  role.can_status_village,

                # Data Management

                'can_add_land_unit' :  role.can_add_land_unit,
                'can_edit_land_unit' :  role.can_edit_land_unit,
                'can_view_land_unit' :  role.can_view_land_unit,
                'can_delete_land_unit' :  role.can_delete_land_unit,
                'can_status_land_unit' :  role.can_status_land_unit,

                'can_add_area_unit' : role.can_add_area_unit,
                'can_edit_area_unit' :  role.can_edit_area_unit,
                'can_view_area_unit' :  role.can_view_area_unit,
                'can_delete_area_unit' :  role.can_delete_area_unit,
                'can_status_area_unit' :  role.can_status_area_unit,

                'can_add_soil_type' :  role.can_add_soil_type,
                'can_edit_soil_type' :  role.can_edit_soil_type,
                'can_view_soil_type' :  role.can_view_soil_type,
                'can_delete_soil_type' : role.can_delete_soil_type,
                'can_status_soil_type' : role.can_status_soil_type,

                'can_add_crop_type' :  role.can_add_crop_type,
                'can_edit_crop_type' :  role.can_edit_crop_type,
                'can_view_crop_type' :  role.can_view_crop_type,
                'can_delete_crop_type' :  role.can_delete_crop_type,
                'can_status_crop_type' : role.can_status_crop_type,

                'can_add_quality' :  role.can_add_quality,
                'can_edit_quality' :  role.can_edit_quality,
                'can_view_quality' : role.can_view_quality,
                'can_delete_quality' :  role.can_delete_quality,
                'can_status_quality' :  role.can_status_quality,

                'can_add_crop' :  role.can_add_crop,
                'can_edit_crop' :  role.can_edit_crop,
                'can_view_crop' :  role.can_view_crop,
                'can_delete_crop' :  role. can_delete_crop,
                'can_status_crop' :  role.can_status_crop,

                'can_add_product_type' :  role.can_add_product_type,
                'can_edit_product_type' :  role.can_edit_product_type,
                'can_view_product_type' :  role.can_view_product_type,
                'can_delete_product_type' :  role.can_delete_product_type,
                'can_status_product_type' :  role.can_status_product_type,

                'can_add_vehicle_category' : role.can_add_vehicle_category,
                'can_edit_vehicle_category' :  role.can_edit_vehicle_category,
                'can_view_vehicle_category' : role.can_view_vehicle_category,
                'can_delete_vehicle_category' : role.can_delete_vehicle_category,
                'can_status_vehicle_category' :  role.can_status_vehicle_category,

                'can_add_manage_vehicle' :  role.can_add_manage_vehicle,
                'can_edit_manage_vehicle' :  role.can_edit_manage_vehicle,
                'can_view_manage_vehicle' :  role.can_view_manage_vehicle,
                'can_delete_manage_vehicle' : role.can_delete_manage_vehicle,
                'can_status_manage_vehicle' :  role.can_status_manage_vehicle,

                'can_add_machinery_category' :  role.can_add_machinery_category,
                'can_edit_machinery_category' : role.can_edit_machinery_category,
                'can_view_machinery_category' :  role.can_view_machinery_category,
                'can_delete_machinery_category' :  role.can_delete_machinery_category,
                'can_status_machinery_category' :  role.can_status_machinery_category,

                'can_add_manage_machinery' :  role.can_add_manage_machinery,
                'can_edit_manage_machinery' :  role.can_edit_manage_machinery,
                'can_view_manage_machinery' :  role.can_view_manage_machinery,
                'can_delete_manage_machinery' :  role.can_delete_manage_machinery,
                'can_status_manage_machinery' :  role.can_status_manage_machinery,

                'can_add_tool_category' : role.can_add_tool_category,
                'can_edit_tool_category' :  role.can_edit_tool_category,
                'can_view_tool_category' : role.can_view_tool_category,
                'can_delete_tool_category' : role.can_delete_tool_category,
                'can_status_tool_category' :  role.can_status_tool_category,

                'can_add_tool' :  role.can_add_tool,
                'can_edit_tool' :  role.can_edit_tool,
                'can_view_tool' :  role.can_view_tool,
                'can_delete_tool' :  role.can_delete_tool,
                'can_status_tool' :  role.can_status_tool,

                'can_add_expense_category' :  role.can_add_expense_category,
                'can_edit_expense_category' :  role.can_edit_expense_category,
                'can_view_expense_category' :  role.can_view_expense_category,
                'can_delete_expense_category' :  role.can_delete_expense_category,
                'can_status_expense_category' :  role.can_status_expense_category,

                'can_add_expense' :  role.can_add_expense,
                'can_edit_expense' : role.can_edit_expense,
                'can_view_expense' : role.can_view_expense,
                'can_delete_expense' : role.can_delete_expense,
                'can_status_expense' : role.can_status_expense,

                'can_add_harvesting_type' : role.can_add_harvesting_type,
                'can_edit_harvesting_type' :role.can_edit_harvesting_type,
                'can_view_harvesting_type' : role.can_view_harvesting_type,
                'can_delete_harvesting_type' : role.can_delete_harvesting_type,
                'can_status_harvesting_type' : role.can_status_harvesting_type,

                'can_add_detection' : role.can_add_detection,
                'can_edit_detection' : role.can_edit_detection,
                'can_view_detection' : role.can_view_detection,
                'can_delete_detection' : role.can_delete_detection,
                'can_status_detection' : role.can_status_detection,

                # farmer management
                'can_add_farmer' : role.can_add_farmer,
                'can_view_farmer' : role.can_view_farmer,
                'can_edit_farmer' : role.can_edit_farmer,
                'can_delete_farmer' : role.can_delete_farmer,
                'can_view_unique_farmer' :role.can_view_unique_farmer,
                'can_update_farmer_status' : role.can_update_farmer_status,
                'can_export_farmer_data' : role.can_export_farmer_data,
                'can_filter_farmer_data' : role.can_filter_farmer_data,
                'can_subscribe_farmer_package': role.can_subscribe_farmer_package,
                'can_unsubscribe_farmer_package': role.can_unsubscribe_farmer_package,

                # package management
                'can_add_package' :role.can_add_package,
                'can_view_package' : role.can_view_package,
                'can_edit_package' : role.can_edit_package,
                'can_delete_package' : role.can_delete_package,
                'can_view_unique_package' : role.can_view_unique_package,

                # subscription management
                'can_add_subscription' : role.can_add_subscription,
                'can_view_subscription' : role.can_view_subscription,
                'can_edit_subscription' : role.can_edit_subscription,
                'can_delete_subscription' : role.can_delete_subscription,
                'can_view_unique_subscription' :role.can_view_unique_subscription,
                'can_export_subscription' : role.can_export_subscription,
                'can_filter_subscription' :role.can_filter_subscription,
                'can_activeplan_subscription' : role.can_activeplan_subscription,
                'can_renewalplan_subscription' : role.can_renewalplan_subscription,
                'can_unsubscribe_subscription': role.can_unsubscribe_subscription,
                'can_update_subscription_status': role.can_update_subscription_status,

                # --> Market Price

                'can_add_manage_product' :  role.can_add_manage_product,
                'can_view_manage_product' :  role.can_view_manage_product,
                'can_edit_manage_product' :  role.can_edit_manage_product,
                'can_delete_manage_product' :  role.can_delete_manage_product,
                'can_filter_manage_product' :  role.can_filter_manage_product,
                'can_update_manage_product' :  role.can_update_manage_product,
                'can_graph_manage_product' :  role.can_graph_manage_product,
                'can_staff_manage_product' : role.can_staff_manage_product,

                'can_filter_market_report'  : role.can_filter_market_report,
                'can_view_market_report' : role.can_view_market_report,
                'can_edit_market_report' : role.can_edit_market_report,
                'can_graph_market_report' : role.can_graph_market_report,

                'can_filter_product_market_report'  :role.can_filter_product_market_report,
                'can_view_product_market_report' :  role.can_view_product_market_report,
                'can_edit_product_market_report' :  role.can_edit_product_market_report,
                'can_graph_product_market_report' :  role.can_graph_product_market_report,

                # --> Market Management

                'can_add_market' :  role.can_add_market,
                'can_view_market' :  role.can_view_market,
                'can_edit_market' : role.can_edit_market,
                'can_delete_market' :  role.can_delete_market,
                'can_view_unique_market' :  role.can_view_unique_market,
                'can_status_market' :  role.can_status_market,
                'can_export_market' :  role.can_export_market,
                'can_filter_market' :  role.can_filter_market,

                'can_add_allocate_market' :  role.can_add_allocate_market,
                'can_view_allocate_market' :  role.can_view_allocate_market,
                'can_edit_allocate_market' :  role.can_edit_allocate_market,
                'can_delete_allocate_market' :  role.can_delete_allocate_market,
                'can_view_unique_allocate_market' :  role.can_view_unique_allocate_market,
                'can_status_allocate_market' :  role.can_status_allocate_market,
                'can_export_allocate_market' : role.can_export_allocate_market,

                # --> Schedule Management

                'can_add_schedule_activity_type' : role.can_add_schedule_activity_type,
                'can_edit_schedule_activity_type' : role.can_edit_schedule_activity_type,
                'can_view_schedule_activity_type' : role.can_view_schedule_activity_type,
                'can_delete_schedule_activity_type' : role.can_delete_schedule_activity_type,
                'can_status_schedule_activity_type' : role.can_status_schedule_activity_type,
                
                'can_add_schedule'  :  role.can_add_schedule,
                'can_edit_schedule'  :  role.can_edit_schedule,
                'can_view_schedule' :  role.can_view_schedule,
                'can_delete_schedule' :  role.can_delete_schedule,
                'can_status_schedule' :  role.can_status_schedule,
                'can_view_unique_schedule' :  role.can_view_unique_schedule,
                'can_filter_schedule': role.can_filter_schedule,
                'can_import_schedule': role.can_import_schedule,

                # --> NearBy Locations

                'can_add_near_by_location_category' :  role.can_add_near_by_location_category,
                'can_edit_near_by_location_category' :  role.can_edit_near_by_location_category,
                'can_view_near_by_location_category' :  role.can_view_near_by_location_category,
                'can_delete_near_by_location_category' :  role.can_delete_near_by_location_category,
                'can_status_near_by_location_category' :  role.can_status_near_by_location_category,

                'can_add_near_by_locations' :  role.can_add_near_by_locations,
                'can_edit_near_by_locations' :  role.can_edit_near_by_locations,
                'can_view_near_by_locations' :  role.can_view_near_by_locations,
                'can_delete_near_by_locations' :  role.can_delete_near_by_locations,
                'can_status_near_by_locations' :  role.can_status_near_by_locations,
                'can_export_near_by_locations' :  role.can_export_near_by_locations,
                'can_filter_near_by_locations' :  role.can_filter_near_by_locations,
                'can_view_unique_near_by_locations' :  role.can_view_unique_near_by_locations,

                # --> Workers Availability

                'can_add_workers_type' :  role.can_add_workers_type,
                'can_edit_workers_type' :  role.can_edit_workers_type,
                'can_view_workers_type' :  role.can_view_workers_type,
                'can_delete_workers_type' :  role.can_delete_workers_type,
                'can_update_workers_type_status' : role.can_update_workers_type_status,

                'can_add_manage_workers' : role.can_add_manage_workers,
                'can_view_manage_workers' : role.can_view_manage_workers,
                'can_edit_manage_workers' : role.can_edit_manage_workers,
                'can_update_manage_workers' : role.can_update_manage_workers,
                'can_delete_manage_workers' : role.can_delete_manage_workers,
                'can_view_unique_manage_workers': role.can_view_unique_manage_workers,
                'can_update_manage_workers_status' :  role.can_update_manage_workers_status,
                'can_export_manage_workers': role.can_export_manage_workers,
                'can_filter_manage_workers' : role.can_filter_manage_workers,

                 # ---> Rental Availability
                'can_view_rental_availability' : role.can_view_rental_availability,
                'can_filter_rental_availability' : role.can_filter_rental_availability,
                'can_export_rental_availability' : role.can_export_rental_availability,


                # ---> Guidelines Management 

                'can_add_guidelines_category' : role.can_add_guidelines_category,
                'can_view_guidelines_category' : role.can_edit_guidelines_category,
                'can_edit_guidelines_category' : role.can_delete_guidelines_category,
                'can_delete_guidelines_category' : role.can_delete_guidelines_category,
                'can_update_guidelines_category_status' :  role.can_update_guidelines_category_status,

                'can_add_guidelines' : role.can_add_guidelines,
                'can_view_guidelines' : role.can_view_guidelines,
                'can_edit_guidelines' : role.can_edit_guidelines,
                'can_delete_guidelines' : role.can_delete_guidelines,
                'can_view_unique_guidelines': role.can_view_unique_guidelines,
                'can_update_guidelines_status' : role.can_update_guidelines_status,
                'can_export_guidelines' : role.can_export_guidelines,
                'can_filter_guidelines' : role.can_filter_guidelines,

                # ---> User Management

                'can_view_manage_user' : role.can_view_manage_user,
                'can_add_manage_user' : role.can_add_manage_user,
                'can_edit_manage_user' : role.can_edit_manage_user,
                'can_delete_manage_user' : role.can_delete_manage_user,
                'can_export_manage_user' : role.can_export_manage_user,
                'can_filter_manage_user' : role.can_filter_manage_user,
                'can_status_manage_user' : role.can_status_manage_user,
                'can_ter_status_manage_user' : role.can_ter_status_manage_user,
                'can_rel_status_manage_user' : role.can_rel_status_manage_user,
                'can_view_unique_manage_user' : role.can_view_unique_manage_user,

                'can_add_manage_user_role' : role.can_add_manage_user_role,
                'can_view_manage_user_role' : role.can_view_manage_user_role,
                'can_status_manage_user_role' : role.can_status_manage_user_role,
                'can_view_unique_manage_user_role' : role.can_view_unique_manage_user_role,
                'can_edit_manage_user_role' : role.can_edit_manage_user_role,
                'can_delete_manage_user_role' : role.can_delete_manage_user_role,

                # --> Report

                'can_export_farmer_report' : role.can_export_farmer_report,
                'can_view_farmer_report' : role.can_view_farmer_report,
                'can_filter_farmer_report' : role.can_filter_farmer_report,
                'can_view_unique_report' : role.can_view_unique_report,


                'can_export_subscription_report' :role.can_export_subscription_report,
                'can_view_subscription_report' : role.can_view_subscription_report,
                'can_filter_subscription_report' : role.can_filter_subscription_report,
                'can_view_unique_subscription_report' :role.can_view_unique_subscription_report,

                'can_dashboard_count':role.can_dashboard_count,
                # 'can_dashboard_total_revenue' = role.can_dashboard_total_revenue
                # 'can_farmer_graph' = role.can_farmer_graph
                # 'can_subscription_graph' = role.can_subscription_graph
                # 'can_revenue_graph' = role.can_revenue_graph
                # 'can_market_view'  = role.can_market_view
                # 'can_market_graph' = role.can_market_graph
                # 'can_market_view_staff' = role.can_market_view_staff

                'can_add_email_config'  : role.can_add_email_config,
                'can_view_email_config' : role.can_view_email_config,
                'can_status_email_config'  :role.can_status_email_config,
                'can_edit_email_config'  : role.can_edit_email_config,
                'can_delete_email_config' : role.can_delete_email_config,

                'can_view_sms_config' : role.can_view_sms_config,
                'can_status_sms_config' : role.can_status_sms_config,
                'can_delete_sms_config' : role.can_delete_sms_config,
                'can_edit_sms_config' : role.can_edit_sms_config,

                'can_view_inventory_category':role.can_view_inventory_category,
                'can_add_inventory_category':role.can_add_inventory_category,
                'can_status_inventory_category':role.can_status_inventory_category,
                'can_edit_inventory_category':role.can_edit_inventory_category,
                'can_delete_inventory_category':role.can_delete_inventory_category,
        
                'can_view_inventory_items':role.can_view_inventory_items,
                'can_add_inventory_items':role.can_add_inventory_items,
                'can_status_inventory_items':role.can_status_inventory_items,
                'can_edit_inventory_items':role.can_edit_inventory_items,
                'can_delete_inventory_items':role.can_delete_inventory_items,
            

                'can_view_document_category':role.can_view_document_category,
                'can_add_document_category':role.can_add_document_category,
                'can_status_document_category':role.can_status_document_category,
                'can_edit_document_category':role.can_edit_document_category,
                'can_delete_document_category':role.can_delete_document_category,

            }

            return JsonResponse({'role_permissions': role_permissions})

        except ManageUserRole.DoesNotExist:
            # Return an error response if the role doesn't exist
            return JsonResponse({'error': 'Role not found'}, status=404)

    # If no role_id is passed, return an error
    return JsonResponse({'error': 'No role ID provided'}, status=400)

class UserView(LoginRequiredMixin, View):
    def get(self, request, user_id):
        trigger_subscription()
        user = get_object_or_404(ManageUser, id=user_id)
        auth_user_id = request.user.id
        auth_user = get_object_or_404(CustomUser, pk=auth_user_id)

        try:
            auth_user_settings = GeneralSetting.objects.get(user=auth_user)
        except GeneralSetting.DoesNotExist:
            # If no settings found, you can provide a default or handle the error
            auth_user_settings = None  # or create a default value

        if auth_user_settings:
            print(auth_user_settings.date_format)
        else:
            print("No GeneralSetting found for the user")

        role = user.role  
        role_permissions = {
            'can_view_general_setting'  : role.can_view_general_setting,
            'can_edit_general_setting' : role.can_edit_general_setting ,

            'can_add_country' :role.can_add_country,
            'can_edit_country' :role.can_edit_country,
            'can_view_country' : role.can_view_country,
            'can_delete_country' :  role.can_delete_country,
            'can_status_country' :  role.can_status_country,

            'can_add_state' :  role.can_add_state,
            'can_edit_state' :  role.can_edit_state,
            'can_view_state' :  role.can_view_state,
            'can_delete_state' :  role.can_delete_state,
            'can_status_state' :  role.can_status_state,

            'can_add_city' : role.can_add_city,
            'can_edit_city' :  role.can_edit_city,
            'can_view_city' :  role.can_view_city,
            'can_delete_city' :  role.can_delete_city,
            'can_status_city' : role.can_status_city,

            'can_add_taluk' : role.can_add_taluk,
            'can_edit_taluk' : role.can_edit_taluk,
            'can_view_taluk' :role.can_view_taluk,
            'can_delete_taluk' : role.can_delete_taluk,
            'can_status_taluk' : role.can_status_taluk,

            'can_add_village' : role.can_add_village,
            'can_edit_village' :  role.can_edit_village,
            'can_view_village' :  role.can_view_village,
            'can_delete_village' :  role.can_delete_village,
            'can_status_village' :  role.can_status_village,

            # Data Management

            'can_add_land_unit' :  role.can_add_land_unit,
            'can_edit_land_unit' :  role.can_edit_land_unit,
            'can_view_land_unit' :  role.can_view_land_unit,
            'can_delete_land_unit' :  role.can_delete_land_unit,
            'can_status_land_unit' :  role.can_status_land_unit,

            'can_add_area_unit' : role.can_add_area_unit,
            'can_edit_area_unit' :  role.can_edit_area_unit,
            'can_view_area_unit' :  role.can_view_area_unit,
            'can_delete_area_unit' :  role.can_delete_area_unit,
            'can_status_area_unit' :  role.can_status_area_unit,

            'can_add_soil_type' :  role.can_add_soil_type,
            'can_edit_soil_type' :  role.can_edit_soil_type,
            'can_view_soil_type' :  role.can_view_soil_type,
            'can_delete_soil_type' : role.can_delete_soil_type,
            'can_status_soil_type' : role.can_status_soil_type,

            'can_add_crop_type' :  role.can_add_crop_type,
            'can_edit_crop_type' :  role.can_edit_crop_type,
            'can_view_crop_type' :  role.can_view_crop_type,
            'can_delete_crop_type' :  role.can_delete_crop_type,
            'can_status_crop_type' : role.can_status_crop_type,

            'can_add_quality' :  role.can_add_quality,
            'can_edit_quality' :  role.can_edit_quality,
            'can_view_quality' : role.can_view_quality,
            'can_delete_quality' :  role.can_delete_quality,
            'can_status_quality' :  role.can_status_quality,

            'can_add_crop' :  role.can_add_crop,
            'can_edit_crop' :  role.can_edit_crop,
            'can_view_crop' :  role.can_view_crop,
            'can_delete_crop' :  role. can_delete_crop,
            'can_status_crop' :  role.can_status_crop,

            'can_add_product_type' :  role.can_add_product_type,
            'can_edit_product_type' :  role.can_edit_product_type,
            'can_view_product_type' :  role.can_view_product_type,
            'can_delete_product_type' :  role.can_delete_product_type,
            'can_status_product_type' :  role.can_status_product_type,

            'can_add_vehicle_category' : role.can_add_vehicle_category,
            'can_edit_vehicle_category' :  role.can_edit_vehicle_category,
            'can_view_vehicle_category' : role.can_view_vehicle_category,
            'can_delete_vehicle_category' : role.can_delete_vehicle_category,
            'can_status_vehicle_category' :  role.can_status_vehicle_category,

            'can_add_manage_vehicle' :  role.can_add_manage_vehicle,
            'can_edit_manage_vehicle' :  role.can_edit_manage_vehicle,
            'can_view_manage_vehicle' :  role.can_view_manage_vehicle,
            'can_delete_manage_vehicle' : role.can_delete_manage_vehicle,
            'can_status_manage_vehicle' :  role.can_status_manage_vehicle,

            'can_add_machinery_category' :  role.can_add_machinery_category,
            'can_edit_machinery_category' : role.can_edit_machinery_category,
            'can_view_machinery_category' :  role.can_view_machinery_category,
            'can_delete_machinery_category' :  role.can_delete_machinery_category,
            'can_status_machinery_category' :  role.can_status_machinery_category,

            'can_add_manage_machinery' :  role.can_add_manage_machinery,
            'can_edit_manage_machinery' :  role.can_edit_manage_machinery,
            'can_view_manage_machinery' :  role.can_view_manage_machinery,
            'can_delete_manage_machinery' :  role.can_delete_manage_machinery,
            'can_status_manage_machinery' :  role.can_status_manage_machinery,

            'can_add_tool_category' : role.can_add_tool_category,
            'can_edit_tool_category' :  role.can_edit_tool_category,
            'can_view_tool_category' : role.can_view_tool_category,
            'can_delete_tool_category' : role.can_delete_tool_category,
            'can_status_tool_category' :  role.can_status_tool_category,

            'can_add_tool' :  role.can_add_tool,
            'can_edit_tool' :  role.can_edit_tool,
            'can_view_tool' :  role.can_view_tool,
            'can_delete_tool' :  role.can_delete_tool,
            'can_status_tool' :  role.can_status_tool,

            'can_add_expense_category' :  role.can_add_expense_category,
            'can_edit_expense_category' :  role.can_edit_expense_category,
            'can_view_expense_category' :  role.can_view_expense_category,
            'can_delete_expense_category' :  role.can_delete_expense_category,
            'can_status_expense_category' :  role.can_status_expense_category,

            'can_add_expense' :  role.can_add_expense,
            'can_edit_expense' : role.can_edit_expense,
            'can_view_expense' : role.can_view_expense,
            'can_delete_expense' : role.can_delete_expense,
            'can_status_expense' : role.can_status_expense,

            'can_add_harvesting_type' : role.can_add_harvesting_type,
            'can_edit_harvesting_type' :role.can_edit_harvesting_type,
            'can_view_harvesting_type' : role.can_view_harvesting_type,
            'can_delete_harvesting_type' : role.can_delete_harvesting_type,
            'can_status_harvesting_type' : role.can_status_harvesting_type,

            'can_add_detection' : role.can_add_detection,
            'can_edit_detection' : role.can_edit_detection,
            'can_view_detection' : role.can_view_detection,
            'can_delete_detection' : role.can_delete_detection,
            'can_status_detection' : role.can_status_detection,

            # farmer management
            'can_add_farmer' : role.can_add_farmer,
            'can_view_farmer' : role.can_view_farmer,
            'can_edit_farmer' : role.can_edit_farmer,
            'can_delete_farmer' : role.can_delete_farmer,
            'can_view_unique_farmer' :role.can_view_unique_farmer,
            'can_update_farmer_status' : role.can_update_farmer_status,
            'can_export_farmer_data' : role.can_export_farmer_data,
            'can_filter_farmer_data' : role.can_filter_farmer_data,

            # package management
            'can_add_package' :role.can_add_package,
            'can_view_package' : role.can_view_package,
            'can_edit_package' : role.can_edit_package,
            'can_delete_package' : role.can_delete_package,
            'can_view_unique_package' : role.can_view_unique_package,

            # subscription management
            'can_add_subscription' : role.can_add_subscription,
            'can_view_subscription' : role.can_view_subscription,
            'can_edit_subscription' : role.can_edit_subscription,
            'can_delete_subscription' : role.can_delete_subscription,
            'can_view_unique_subscription' :role.can_view_unique_subscription,
            'can_export_subscription' : role.can_export_subscription,
            'can_filter_subscription' :role.can_filter_subscription,
            'can_activeplan_subscription' : role.can_activeplan_subscription,
            'can_renewalplan_subscription' : role.can_renewalplan_subscription,

            # --> Market Price

            'can_add_manage_product' :  role.can_add_manage_product,
            'can_view_manage_product' :  role.can_view_manage_product,
            'can_edit_manage_product' :  role.can_edit_manage_product,
            'can_delete_manage_product' :  role.can_delete_manage_product,
            'can_filter_manage_product' :  role.can_filter_manage_product,
            'can_update_manage_product' :  role.can_update_manage_product,
            'can_graph_manage_product' :  role.can_graph_manage_product,
            'can_staff_manage_product' : role.can_staff_manage_product,

            'can_filter_market_report'  : role.can_filter_market_report,
            'can_view_market_report' : role.can_view_market_report,
            'can_edit_market_report' : role.can_edit_market_report,
            'can_graph_market_report' : role.can_graph_market_report,

            'can_filter_product_market_report'  :role.can_filter_product_market_report,
            'can_view_product_market_report' :  role.can_view_product_market_report,
            'can_edit_product_market_report' :  role.can_edit_product_market_report,
            'can_graph_product_market_report' :  role.can_graph_product_market_report,

            # --> Market Management

            'can_add_market' :  role.can_add_market,
            'can_view_market' :  role.can_view_market,
            'can_edit_market' : role.can_edit_market,
            'can_delete_market' :  role.can_delete_market,
            'can_view_unique_market' :  role.can_view_unique_market,
            'can_status_market' :  role.can_status_market,
            'can_export_market' :  role.can_export_market,
            'can_filter_market' :  role.can_filter_market,

            'can_add_allocate_market' :  role.can_add_allocate_market,
            'can_view_allocate_market' :  role.can_view_allocate_market,
            'can_edit_allocate_market' :  role.can_edit_allocate_market,
            'can_delete_allocate_market' :  role.can_delete_allocate_market,
            'can_view_unique_allocate_market' :  role.can_view_unique_allocate_market,
            'can_status_allocate_market' :  role.can_status_allocate_market,
            'can_export_allocate_market' : role.can_export_allocate_market,

            # --> Schedule Management

            'can_add_schedule_activity_type' : role.can_add_schedule_activity_type,
            'can_edit_schedule_activity_type' : role.can_edit_schedule_activity_type,
            'can_view_schedule_activity_type' : role.can_view_schedule_activity_type,
            'can_delete_schedule_activity_type' : role.can_delete_schedule_activity_type,
            'can_status_schedule_activity_type' : role.can_status_schedule_activity_type,

            'can_add_schedule'  :  role.can_add_schedule,
            'can_edit_schedule'  :  role.can_edit_schedule,
            'can_view_schedule' :  role.can_view_schedule,
            'can_delete_schedule' :  role.can_delete_schedule,
            'can_status_schedule' :  role.can_status_schedule,
            'can_view_unique_schedule' :  role.can_view_unique_schedule,

            # --> NearBy Locations

            'can_add_near_by_location_category' :  role.can_add_near_by_location_category,
            'can_edit_near_by_location_category' :  role.can_edit_near_by_location_category,
            'can_view_near_by_location_category' :  role.can_view_near_by_location_category,
            'can_delete_near_by_location_category' :  role.can_delete_near_by_location_category,
            'can_status_near_by_location_category' :  role.can_status_near_by_location_category,

            'can_add_near_by_locations' :  role.can_add_near_by_locations,
            'can_edit_near_by_locations' :  role.can_edit_near_by_locations,
            'can_view_near_by_locations' :  role.can_view_near_by_locations,
            'can_delete_near_by_locations' :  role.can_delete_near_by_locations,
            'can_status_near_by_locations' :  role.can_status_near_by_locations,
            'can_export_near_by_locations' :  role.can_export_near_by_locations,
            'can_filter_near_by_locations' :  role.can_filter_near_by_locations,
            'can_view_unique_near_by_locations' :  role.can_view_unique_near_by_locations,

            # --> Workers Availability

            'can_add_workers_type' :  role.can_add_workers_type,
            'can_edit_workers_type' :  role.can_edit_workers_type,
            'can_view_workers_type' :  role.can_view_workers_type,
            'can_delete_workers_type' :  role.can_delete_workers_type,
            'can_update_workers_type_status' : role.can_update_workers_type_status,

            'can_add_manage_workers' : role.can_add_manage_workers,
            'can_view_manage_workers' : role.can_view_manage_workers,
            'can_edit_manage_workers' : role.can_edit_manage_workers,
            'can_update_manage_workers' : role.can_update_manage_workers,
            'can_delete_manage_workers' : role.can_delete_manage_workers,
            'can_view_unique_manage_workers': role.can_view_unique_manage_workers,
            'can_update_manage_workers_status' :  role.can_update_manage_workers_status,
            'can_export_manage_workers': role.can_export_manage_workers,
            'can_filter_manage_workers' : role.can_filter_manage_workers,

            # ---> Guidelines Management 

            'can_add_guidelines_category' : role.can_add_guidelines_category,
            'can_view_guidelines_category' : role.can_edit_guidelines_category,
            'can_edit_guidelines_category' : role.can_delete_guidelines_category,
            'can_delete_guidelines_category' : role.can_delete_guidelines_category,
            'can_update_guidelines_category_status' :  role.can_update_guidelines_category_status,

            'can_add_guidelines' : role.can_add_guidelines,
            'can_view_guidelines' : role.can_view_guidelines,
            'can_edit_guidelines' : role.can_edit_guidelines,
            'can_delete_guidelines' : role.can_delete_guidelines,
            'can_view_unique_guidelines': role.can_view_unique_guidelines,
            'can_update_guidelines_status' : role.can_update_guidelines_status,
            'can_export_guidelines' : role.can_export_guidelines,
            'can_filter_guidelines' : role.can_filter_guidelines,

            # ---> User Management

            'can_view_manage_user' : role.can_view_manage_user,
            'can_add_manage_user' : role.can_add_manage_user,
            'can_edit_manage_user' : role.can_edit_manage_user,
            'can_delete_manage_user' : role.can_delete_manage_user,
            'can_export_manage_user' : role.can_export_manage_user,
            'can_filter_manage_user' : role.can_filter_manage_user,
            'can_status_manage_user' : role.can_status_manage_user,
            'can_ter_status_manage_user' : role.can_ter_status_manage_user,
            'can_rel_status_manage_user' : role.can_rel_status_manage_user,
            'can_view_unique_manage_user' : role.can_view_unique_manage_user,

            'can_add_manage_user_role' : role.can_add_manage_user_role,
            'can_view_manage_user_role' : role.can_view_manage_user_role,
            'can_status_manage_user_role' : role.can_status_manage_user_role,
            'can_view_unique_manage_user_role' : role.can_view_unique_manage_user_role,
            'can_edit_manage_user_role' : role.can_edit_manage_user_role,
            'can_delete_manage_user_role' : role.can_delete_manage_user_role,

            # --> Report

            'can_export_farmer_report' : role.can_export_farmer_report,
            'can_view_farmer_report' : role.can_view_farmer_report,
            'can_filter_farmer_report' : role.can_filter_farmer_report,
            'can_view_unique_report' : role.can_view_unique_report,


            'can_export_subscription_report' :role.can_export_subscription_report,
            'can_view_subscription_report' : role.can_view_subscription_report,
            'can_filter_subscription_report' : role.can_filter_subscription_report,
            'can_view_unique_subscription_report' :role.can_view_unique_subscription_report,

            'can_dashboard_count':role.can_dashboard_count,
            # 'can_dashboard_total_revenue' = role.can_dashboard_total_revenue
            # 'can_farmer_graph' = role.can_farmer_graph
            # 'can_subscription_graph' = role.can_subscription_graph
            # 'can_revenue_graph' = role.can_revenue_graph
            # 'can_market_view'  = role.can_market_view
            # 'can_market_graph' = role.can_market_graph
            # 'can_market_view_staff' = role.can_market_view_staff

            'can_add_email_config'  : role.can_add_email_config,
            'can_view_email_config' : role.can_view_email_config,
            'can_status_email_config'  :role.can_status_email_config,
            'can_edit_email_config'  : role.can_edit_email_config,
            'can_delete_email_config' : role.can_delete_email_config,

            'can_view_sms_config' : role.can_view_sms_config,
            'can_status_sms_config' : role.can_status_sms_config,
            'can_delete_sms_config' : role.can_delete_sms_config,
            'can_edit_sms_config' : role.can_edit_sms_config,

            'can_view_inventory_category':role.can_view_inventory_category,
            'can_add_inventory_category':role.can_add_inventory_category,
            'can_status_inventory_category':role.can_status_inventory_category,
            'can_edit_inventory_category':role.can_edit_inventory_category,
            'can_delete_inventory_category':role.can_delete_inventory_category,
    
            'can_view_inventory_items':role.can_view_inventory_items,
            'can_add_inventory_items':role.can_add_inventory_items,
            'can_status_inventory_items':role.can_status_inventory_items,
            'can_edit_inventory_items':role.can_edit_inventory_items,
            'can_delete_inventory_items':role.can_delete_inventory_items,
        

            'can_view_document_category':role.can_view_document_category,
            'can_add_document_category':role.can_add_document_category,
            'can_status_document_category':role.can_status_document_category,
            'can_edit_document_category':role.can_edit_document_category,
            'can_delete_document_category':role.can_delete_document_category,
        }

        context = {
            'users': user,
            'date': auth_user_settings.date_format if auth_user_settings else "Default Date Format",
            'role_permissions': role_permissions,
            'user_role': role,
        }
        return render(request, 'pages/super_admin/users_management/manage_users/view.html', context)

class ManageUserUpdate(LoginRequiredMixin, View):
    def get(self, request, user_id):
        trigger_subscription()
        user = get_object_or_404(ManageUser, id=user_id)
 
        role = get_object_or_404(ManageUserRole, id=user.role_id)

        # Prepare the permissions data as a dictionary
        role_permissions = {
            'can_view_general_setting'  : role.can_view_general_setting,
            'can_edit_general_setting' : role.can_edit_general_setting ,

            'can_add_country' :role.can_add_country,
            'can_edit_country' :role.can_edit_country,
            'can_view_country' : role.can_view_country,
            'can_delete_country' :  role.can_delete_country,
            'can_status_country' :  role.can_status_country,

            'can_add_state' :  role.can_add_state,
            'can_edit_state' :  role.can_edit_state,
            'can_view_state' :  role.can_view_state,
            'can_delete_state' :  role.can_delete_state,
            'can_status_state' :  role.can_status_state,

            'can_add_city' : role.can_add_city,
            'can_edit_city' :  role.can_edit_city,
            'can_view_city' :  role.can_view_city,
            'can_delete_city' :  role.can_delete_city,
            'can_status_city' : role.can_status_city,

            'can_add_taluk' : role.can_add_taluk,
            'can_edit_taluk' : role.can_edit_taluk,
            'can_view_taluk' :role.can_view_taluk,
            'can_delete_taluk' : role.can_delete_taluk,
            'can_status_taluk' : role.can_status_taluk,

            'can_add_village' : role.can_add_village,
            'can_edit_village' :  role.can_edit_village,
            'can_view_village' :  role.can_view_village,
            'can_delete_village' :  role.can_delete_village,
            'can_status_village' :  role.can_status_village,

            # Data Management

            'can_add_land_unit' :  role.can_add_land_unit,
            'can_edit_land_unit' :  role.can_edit_land_unit,
            'can_view_land_unit' :  role.can_view_land_unit,
            'can_delete_land_unit' :  role.can_delete_land_unit,
            'can_status_land_unit' :  role.can_status_land_unit,

            'can_add_area_unit' : role.can_add_area_unit,
            'can_edit_area_unit' :  role.can_edit_area_unit,
            'can_view_area_unit' :  role.can_view_area_unit,
            'can_delete_area_unit' :  role.can_delete_area_unit,
            'can_status_area_unit' :  role.can_status_area_unit,

            'can_add_soil_type' :  role.can_add_soil_type,
            'can_edit_soil_type' :  role.can_edit_soil_type,
            'can_view_soil_type' :  role.can_view_soil_type,
            'can_delete_soil_type' : role.can_delete_soil_type,
            'can_status_soil_type' : role.can_status_soil_type,

            'can_add_crop_type' :  role.can_add_crop_type,
            'can_edit_crop_type' :  role.can_edit_crop_type,
            'can_view_crop_type' :  role.can_view_crop_type,
            'can_delete_crop_type' :  role.can_delete_crop_type,
            'can_status_crop_type' : role.can_status_crop_type,

            'can_add_quality' :  role.can_add_quality,
            'can_edit_quality' :  role.can_edit_quality,
            'can_view_quality' : role.can_view_quality,
            'can_delete_quality' :  role.can_delete_quality,
            'can_status_quality' :  role.can_status_quality,

            'can_add_crop' :  role.can_add_crop,
            'can_edit_crop' :  role.can_edit_crop,
            'can_view_crop' :  role.can_view_crop,
            'can_delete_crop' :  role. can_delete_crop,
            'can_status_crop' :  role.can_status_crop,

            'can_add_product_type' :  role.can_add_product_type,
            'can_edit_product_type' :  role.can_edit_product_type,
            'can_view_product_type' :  role.can_view_product_type,
            'can_delete_product_type' :  role.can_delete_product_type,
            'can_status_product_type' :  role.can_status_product_type,

            'can_add_vehicle_category' : role.can_add_vehicle_category,
            'can_edit_vehicle_category' :  role.can_edit_vehicle_category,
            'can_view_vehicle_category' : role.can_view_vehicle_category,
            'can_delete_vehicle_category' : role.can_delete_vehicle_category,
            'can_status_vehicle_category' :  role.can_status_vehicle_category,

            'can_add_manage_vehicle' :  role.can_add_manage_vehicle,
            'can_edit_manage_vehicle' :  role.can_edit_manage_vehicle,
            'can_view_manage_vehicle' :  role.can_view_manage_vehicle,
            'can_delete_manage_vehicle' : role.can_delete_manage_vehicle,
            'can_status_manage_vehicle' :  role.can_status_manage_vehicle,

            'can_add_machinery_category' :  role.can_add_machinery_category,
            'can_edit_machinery_category' : role.can_edit_machinery_category,
            'can_view_machinery_category' :  role.can_view_machinery_category,
            'can_delete_machinery_category' :  role.can_delete_machinery_category,
            'can_status_machinery_category' :  role.can_status_machinery_category,

            'can_add_manage_machinery' :  role.can_add_manage_machinery,
            'can_edit_manage_machinery' :  role.can_edit_manage_machinery,
            'can_view_manage_machinery' :  role.can_view_manage_machinery,
            'can_delete_manage_machinery' :  role.can_delete_manage_machinery,
            'can_status_manage_machinery' :  role.can_status_manage_machinery,

            'can_add_tool_category' : role.can_add_tool_category,
            'can_edit_tool_category' :  role.can_edit_tool_category,
            'can_view_tool_category' : role.can_view_tool_category,
            'can_delete_tool_category' : role.can_delete_tool_category,
            'can_status_tool_category' :  role.can_status_tool_category,

            'can_add_tool' :  role.can_add_tool,
            'can_edit_tool' :  role.can_edit_tool,
            'can_view_tool' :  role.can_view_tool,
            'can_delete_tool' :  role.can_delete_tool,
            'can_status_tool' :  role.can_status_tool,

            'can_add_expense_category' :  role.can_add_expense_category,
            'can_edit_expense_category' :  role.can_edit_expense_category,
            'can_view_expense_category' :  role.can_view_expense_category,
            'can_delete_expense_category' :  role.can_delete_expense_category,
            'can_status_expense_category' :  role.can_status_expense_category,

            'can_add_expense' :  role.can_add_expense,
            'can_edit_expense' : role.can_edit_expense,
            'can_view_expense' : role.can_view_expense,
            'can_delete_expense' : role.can_delete_expense,
            'can_status_expense' : role.can_status_expense,

            'can_add_harvesting_type' : role.can_add_harvesting_type,
            'can_edit_harvesting_type' :role.can_edit_harvesting_type,
            'can_view_harvesting_type' : role.can_view_harvesting_type,
            'can_delete_harvesting_type' : role.can_delete_harvesting_type,
            'can_status_harvesting_type' : role.can_status_harvesting_type,

            'can_add_detection' : role.can_add_detection,
            'can_edit_detection' : role.can_edit_detection,
            'can_view_detection' : role.can_view_detection,
            'can_delete_detection' : role.can_delete_detection,
            'can_status_detection' : role.can_status_detection,

            # farmer management
            'can_add_farmer' : role.can_add_farmer,
            'can_view_farmer' : role.can_view_farmer,
            'can_edit_farmer' : role.can_edit_farmer,
            'can_delete_farmer' : role.can_delete_farmer,
            'can_view_unique_farmer' :role.can_view_unique_farmer,
            'can_update_farmer_status' : role.can_update_farmer_status,
            'can_export_farmer_data' : role.can_export_farmer_data,
            'can_filter_farmer_data' : role.can_filter_farmer_data,

            # package management
            'can_add_package' :role.can_add_package,
            'can_view_package' : role.can_view_package,
            'can_edit_package' : role.can_edit_package,
            'can_delete_package' : role.can_delete_package,
            'can_view_unique_package' : role.can_view_unique_package,

            # subscription management
            'can_add_subscription' : role.can_add_subscription,
            'can_view_subscription' : role.can_view_subscription,
            'can_edit_subscription' : role.can_edit_subscription,
            'can_delete_subscription' : role.can_delete_subscription,
            'can_view_unique_subscription' :role.can_view_unique_subscription,
            'can_export_subscription' : role.can_export_subscription,
            'can_filter_subscription' :role.can_filter_subscription,
            'can_activeplan_subscription' : role.can_activeplan_subscription,
            'can_renewalplan_subscription' : role.can_renewalplan_subscription,

            # --> Market Price

            'can_add_manage_product' :  role.can_add_manage_product,
            'can_view_manage_product' :  role.can_view_manage_product,
            'can_edit_manage_product' :  role.can_edit_manage_product,
            'can_delete_manage_product' :  role.can_delete_manage_product,
            'can_filter_manage_product' :  role.can_filter_manage_product,
            'can_update_manage_product' :  role.can_update_manage_product,
            'can_graph_manage_product' :  role.can_graph_manage_product,
            'can_staff_manage_product' : role.can_staff_manage_product,

            'can_filter_market_report'  : role.can_filter_market_report,
            'can_view_market_report' : role.can_view_market_report,
            'can_edit_market_report' : role.can_edit_market_report,
            'can_graph_market_report' : role.can_graph_market_report,

            'can_filter_product_market_report'  :role.can_filter_product_market_report,
            'can_view_product_market_report' :  role.can_view_product_market_report,
            'can_edit_product_market_report' :  role.can_edit_product_market_report,
            'can_graph_product_market_report' :  role.can_graph_product_market_report,

            # --> Market Management

            'can_add_market' :  role.can_add_market,
            'can_view_market' :  role.can_view_market,
            'can_edit_market' : role.can_edit_market,
            'can_delete_market' :  role.can_delete_market,
            'can_view_unique_market' :  role.can_view_unique_market,
            'can_status_market' :  role.can_status_market,
            'can_export_market' :  role.can_export_market,
            'can_filter_market' :  role.can_filter_market,

            'can_add_allocate_market' :  role.can_add_allocate_market,
            'can_view_allocate_market' :  role.can_view_allocate_market,
            'can_edit_allocate_market' :  role.can_edit_allocate_market,
            'can_delete_allocate_market' :  role.can_delete_allocate_market,
            'can_view_unique_allocate_market' :  role.can_view_unique_allocate_market,
            'can_status_allocate_market' :  role.can_status_allocate_market,
            'can_export_allocate_market' : role.can_export_allocate_market,

            # --> Schedule Management

            'can_add_schedule_activity_type' : role.can_add_schedule_activity_type,
            'can_edit_schedule_activity_type' : role.can_edit_schedule_activity_type,
            'can_view_schedule_activity_type' : role.can_view_schedule_activity_type,
            'can_delete_schedule_activity_type' : role.can_delete_schedule_activity_type,
            'can_status_schedule_activity_type' : role.can_status_schedule_activity_type,

            'can_add_schedule'  :  role.can_add_schedule,
            'can_edit_schedule'  :  role.can_edit_schedule,
            'can_view_schedule' :  role.can_view_schedule,
            'can_delete_schedule' :  role.can_delete_schedule,
            'can_status_schedule' :  role.can_status_schedule,
            'can_view_unique_schedule' :  role.can_view_unique_schedule,

            # --> NearBy Locations

            'can_add_near_by_location_category' :  role.can_add_near_by_location_category,
            'can_edit_near_by_location_category' :  role.can_edit_near_by_location_category,
            'can_view_near_by_location_category' :  role.can_view_near_by_location_category,
            'can_delete_near_by_location_category' :  role.can_delete_near_by_location_category,
            'can_status_near_by_location_category' :  role.can_status_near_by_location_category,

            'can_add_near_by_locations' :  role.can_add_near_by_locations,
            'can_edit_near_by_locations' :  role.can_edit_near_by_locations,
            'can_view_near_by_locations' :  role.can_view_near_by_locations,
            'can_delete_near_by_locations' :  role.can_delete_near_by_locations,
            'can_status_near_by_locations' :  role.can_status_near_by_locations,
            'can_export_near_by_locations' :  role.can_export_near_by_locations,
            'can_filter_near_by_locations' :  role.can_filter_near_by_locations,
            'can_view_unique_near_by_locations' :  role.can_view_unique_near_by_locations,

            # --> Workers Availability

            'can_add_workers_type' :  role.can_add_workers_type,
            'can_edit_workers_type' :  role.can_edit_workers_type,
            'can_view_workers_type' :  role.can_view_workers_type,
            'can_delete_workers_type' :  role.can_delete_workers_type,
            'can_update_workers_type_status' : role.can_update_workers_type_status,

            'can_add_manage_workers' : role.can_add_manage_workers,
            'can_view_manage_workers' : role.can_view_manage_workers,
            'can_edit_manage_workers' : role.can_edit_manage_workers,
            'can_update_manage_workers' : role.can_update_manage_workers,
            'can_delete_manage_workers' : role.can_delete_manage_workers,
            'can_view_unique_manage_workers': role.can_view_unique_manage_workers,
            'can_update_manage_workers_status' :  role.can_update_manage_workers_status,
            'can_export_manage_workers': role.can_export_manage_workers,
            'can_filter_manage_workers' : role.can_filter_manage_workers,

            # ---> Rental Availability

            'can_view_rental_availability' : role.can_view_rental_availability,
            'can_filter_rental_availability' : role.can_filter_rental_availability,
            'can_export_rental_availability' : role.can_export_rental_availability,


            # ---> Guidelines Management 

            'can_add_guidelines_category' : role.can_add_guidelines_category,
            'can_view_guidelines_category' : role.can_edit_guidelines_category,
            'can_edit_guidelines_category' : role.can_delete_guidelines_category,
            'can_delete_guidelines_category' : role.can_delete_guidelines_category,
            'can_update_guidelines_category_status' :  role.can_update_guidelines_category_status,

            'can_add_guidelines' : role.can_add_guidelines,
            'can_view_guidelines' : role.can_view_guidelines,
            'can_edit_guidelines' : role.can_edit_guidelines,
            'can_delete_guidelines' : role.can_delete_guidelines,
            'can_view_unique_guidelines': role.can_view_unique_guidelines,
            'can_update_guidelines_status' : role.can_update_guidelines_status,
            'can_export_guidelines' : role.can_export_guidelines,
            'can_filter_guidelines' : role.can_filter_guidelines,

            # ---> User Management

            'can_view_manage_user' : role.can_view_manage_user,
            'can_add_manage_user' : role.can_add_manage_user,
            'can_edit_manage_user' : role.can_edit_manage_user,
            'can_delete_manage_user' : role.can_delete_manage_user,
            'can_export_manage_user' : role.can_export_manage_user,
            'can_filter_manage_user' : role.can_filter_manage_user,
            'can_status_manage_user' : role.can_status_manage_user,
            'can_ter_status_manage_user' : role.can_ter_status_manage_user,
            'can_rel_status_manage_user' : role.can_rel_status_manage_user,
            'can_view_unique_manage_user' : role.can_view_unique_manage_user,

            'can_add_manage_user_role' : role.can_add_manage_user_role,
            'can_view_manage_user_role' : role.can_view_manage_user_role,
            'can_status_manage_user_role' : role.can_status_manage_user_role,
            'can_view_unique_manage_user_role' : role.can_view_unique_manage_user_role,
            'can_edit_manage_user_role' : role.can_edit_manage_user_role,
            'can_delete_manage_user_role' : role.can_delete_manage_user_role,

            # --> Report

            'can_export_farmer_report' : role.can_export_farmer_report,
            'can_view_farmer_report' : role.can_view_farmer_report,
            'can_filter_farmer_report' : role.can_filter_farmer_report,
            'can_view_unique_report' : role.can_view_unique_report,


            'can_export_subscription_report' :role.can_export_subscription_report,
            'can_view_subscription_report' : role.can_view_subscription_report,
            'can_filter_subscription_report' : role.can_filter_subscription_report,
            'can_view_unique_subscription_report' :role.can_view_unique_subscription_report,


            'can_dashboard_count':role.can_dashboard_count,
            # 'can_dashboard_total_revenue' = role.can_dashboard_total_revenue
            # 'can_farmer_graph' = role.can_farmer_graph
            # 'can_subscription_graph' = role.can_subscription_graph
            # 'can_revenue_graph' = role.can_revenue_graph
            # 'can_market_view'  = role.can_market_view
            # 'can_market_graph' = role.can_market_graph
            # 'can_market_view_staff' = role.can_market_view_staff

            'can_add_email_config'  : role.can_add_email_config,
            'can_view_email_config' : role.can_view_email_config,
            'can_status_email_config'  :role.can_status_email_config,
            'can_edit_email_config'  : role.can_edit_email_config,
            'can_delete_email_config' : role.can_delete_email_config,

            'can_view_sms_config' : role.can_view_sms_config,
            'can_status_sms_config' : role.can_status_sms_config,
            'can_delete_sms_config' : role.can_delete_sms_config,
            'can_edit_sms_config' : role.can_edit_sms_config,

            'can_view_inventory_category':role.can_view_inventory_category,
            'can_add_inventory_category':role.can_add_inventory_category,
            'can_status_inventory_category':role.can_status_inventory_category,
            'can_edit_inventory_category':role.can_edit_inventory_category,
            'can_delete_inventory_category':role.can_delete_inventory_category,
    
            'can_view_inventory_items':role.can_view_inventory_items,
            'can_add_inventory_items':role.can_add_inventory_items,
            'can_status_inventory_items':role.can_status_inventory_items,
            'can_edit_inventory_items':role.can_edit_inventory_items,
            'can_delete_inventory_items':role.can_delete_inventory_items,
        

            'can_view_document_category':role.can_view_document_category,
            'can_add_document_category':role.can_add_document_category,
            'can_status_document_category':role.can_status_document_category,
            'can_edit_document_category':role.can_edit_document_category,
            'can_delete_document_category':role.can_delete_document_category,
        }

        # Querying other objects for dropdown fields (gender, countries, etc.)
        gender = Gender.objects.filter(status=0)
        employee_type = EmployeeType.objects.filter(status=0)
        country = Country.objects.filter(status=0)
        state = State.objects.filter(status=0)
        city = City.objects.filter(status=0)
        taluk = Taluk.objects.filter(status=0)
        village = Village.objects.filter(status=0)
        role = ManageUserRole.objects.filter(status=0)

        context = {
            'users': user,
            'gender': gender,
            'employee_type': employee_type,
            'country': country,
            'state': state,
            'city': city,
            'taluk': taluk,
            'village': village,
            'role': role,
            'role_permissions': role_permissions,
        }

        return render(request, 'pages/super_admin/users_management/manage_users/edit.html', context)

def user_not_allowed(request):
    return render(request, 'layout/partials/user_not_allowed.html',{})

# manage_user Export
def export_filtered_data(request):
    # Query the filtered data (you can modify this to reflect the filters you are using)
    users = ManageUser.objects.filter(status__in=[0,1])

    filter_type = request.GET.get('filter_type')
    filter_user = request.GET.get('filter_user')
    filter_mob = request.GET.get('filter_mob')
    filter_role = request.GET.get('filter_role')
    filter_status = request.GET.get('filter_status')
    date_filter = request.GET.get('dt_fill_issue_rpt')
    today_date = timezone.now().date()

    print(filter_type)

    releave_users = UserProfileStatus.objects.filter(releave=1).values_list('name_id', flat=True)
    terminated_users = UserProfileStatus.objects.filter(terminate=1).values_list('name_id', flat=True)

    user_profile_status = UserProfileStatus.objects.filter(Q(terminate=1) | Q(releave=1))
    user_status_map = {status.name.id: {'terminate': status.terminate, 'releave': status.releave} for status in user_profile_status}

    # Apply filters based on the form inputs
    if filter_type:
        users = users.filter(usertype__code=filter_type)
    if filter_user:
        users = users.filter(id=filter_user)
    if filter_mob:
        users = users.filter(mobile_no=filter_mob)
    if filter_role:
        users = users.filter(role__id=filter_role)
    if filter_status:
        if filter_status == '1':  # Active
            users = users.exclude(id__in=user_status_map.keys())
        elif filter_status == '2':  # Terminated
            users = users.filter(id__in=terminated_users)
        elif filter_status == '3':  # Releaved
            users = users.filter(id__in=releave_users)

            # Date filtering
    if date_filter == 'today':
        users = users.filter(created_at__date=today_date)
    elif date_filter == 'week':
        start_of_week = today_date - timedelta(days=today_date.weekday())  # Monday
        users = users.filter(created_at__date__range=[start_of_week, today_date])
    elif date_filter == 'monthly':
        users = users.filter(created_at__year=today_date.year, created_at__month=today_date.month)
    elif date_filter == 'custom_date':
        custom_from_date = request.GET.get('filter_date_cfrom')
        custom_to_date = request.GET.get('filter_date_cto')
        if custom_from_date and custom_to_date:
            # Convert the date format from DD-MM-YYYY to YYYY-MM-DD
            custom_from_date = datetime.strptime(custom_from_date, '%d-%m-%Y').date()
            custom_to_date = datetime.strptime(custom_to_date, '%d-%m-%Y').date()
            users = users.filter(created_at__date__range=[custom_from_date, custom_to_date])


    # Create an HTTP response with CSV headers
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="manage_users.csv"'

    writer = csv.writer(response)
    writer.writerow([
        'Name', 'Date of Birth',   'Mobile No', 'Email', 'Employee Type', 
        'Address', 'Role', 'Country', 'State', 'City', 'Taluk', 'Village', 
        'Status'
    ])

    for user in users:
        writer.writerow([
            # user.id, 
            user.name, user.date_of_birth, 
            # user.gender.name if user.gender else '-',
            user.mobile_no, user.email,
            user.employee_type.name if user.employee_type else '-',
            user.address, 
            user.role.name if user.role else '-',
            user.country.name if user.country else '-', user.state.name if user.state else '-',
            user.city.name if user.city else '-', user.taluk.name if user.taluk else '-', 
            user.village.name if user.village else '-', 
            # user.created_by.username if user.created_by else '-',
            # user.updated_by.username if user.updated_by else '-', user.username, user.password,
            # user.staff_user, user.worker_availability_provider, user.market_price_updater,
            'Active' if user.status == 0 else 'In-Active',
            # user.created_at, user.updated_at
        ])

    return response

# -------------------------------------------------------------------- Guidelines Management -------------------------------------------

def get_guideline_category_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = GuidelinesCategory.objects.get(pk=pk)
    except GuidelinesCategory.DoesNotExist:
        return JsonResponse({'error': 'data not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)
    
    return JsonResponse({
        'name': name,
        'description': description
    })

class GuidelinesCategoryView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_guidelines_category': True,
                'can_view_guidelines_category': True,
                'can_edit_guidelines_category': True,
                'can_delete_guidelines_category': True,  
                'can_update_guidelines_category_status': True, 
        
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_guidelines_category:
                return redirect('user_not_allowed') 
            
        category = GuidelinesCategory.objects.filter(Q(status=0) | Q(status=1)).order_by('-id')
        
        languages = Languages.objects.filter(status=0).order_by('id')
        context = {
            'languages': languages,
            'category': category, 
            'can_add_guidelines_category': manage_user.can_add_guidelines_category if manage_user else False,
            'can_view_guidelines_category': manage_user.can_view_guidelines_category if manage_user else False,
            'can_edit_guidelines_category': manage_user.can_edit_guidelines_category if manage_user else False,
            'can_delete_guidelines_category': manage_user.can_delete_guidelines_category if manage_user else False,
            'can_update_guidelines_category_status': manage_user.can_update_guidelines_category_status if manage_user else False,
        }
        return render(request,'layout/partials/super_admin/layout/header/_menu/data/guidelines_category/list.html', context)
    
    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')

            # Check if the guidelinestype already exists
            if GuidelinesCategory.objects.filter(name=name).exists():
                guidelineCategoryStatusChange = get_object_or_404(GuidelinesCategory, name=name)
                guidelineCategoryStatusChange.status = 0  
                guidelineCategoryStatusChange.description = description
                guidelineCategoryStatusChange.updated_by = user
                guidelineCategoryStatusChange.save()
                messages.success(request, "Guidelines Category created successfully.")
                return redirect('sa_guidelines_category')
            else:
                #Create the guidelinestype if it doesn't exist  
                GuidelinesCategory.objects.create(name=name, description=description, status=0, created_by=user)
                messages.success(request, "Guidelines Category created successfully.")
                return redirect('sa_guidelines_category')

        elif action == 'update':
            pk = request.POST.get('id')
            guidelinescategory = get_object_or_404(GuidelinesCategory, pk=pk)
            translated_json = guidelinescategory.translate_json or {
                "name": {},
                "description": {}
            }
            name = request.POST.get('name')
            description = request.POST.get('description')
            language = request.POST.get('language')

            if name:
                # guidelinescategory.name = name
                # guidelinescategory.description = description
                guidelinescategory.updated_by = user

                if language == "en":
                    if guidelinescategory.name != name:
                        guidelinescategory.name = name
                        try:
                            for lang in target_language:
                                translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                                translated_json["name"][lang] = translated_text
                        except Exception as e:
                            print(e)
                            print("Error in translating ")
                    if guidelinescategory.description != description:
                        guidelinescategory.description = description
                        try:
                            for lang in target_language:
                                translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                                translated_json["description"][lang] = translated_text
                        except Exception as e:
                            print(e)
                            print("Error in translating ")
                else:
                    translated_json["name"][language] = name
                    if description:
                        translated_json["description"][language] = description  
                
                guidelinescategory.translate_json = translated_json
                guidelinescategory.save()
                messages.success(request, "Guidelines Category updated successfully.")
            else:
                messages.error(request, "Guidelines Category name cannot be empty.")

            return redirect('sa_guidelines_category') 

        elif action == 'update_status':
            pk = request.POST.get('id')
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                category = get_object_or_404(GuidelinesCategory, pk=pk)
                status = request.POST.get('status')

                if status == '0':
                    category.status = 0  
                    category.updated_by = user
                    category.save()
                    messages.success(request, "Guidelines Category has been activated.")
                elif status == '1':
                    category.status = 1  
                    category.updated_by = user
                    category.save()
                    messages.success(request, "Guidelines Category has been deactivated.")
                else:
                    messages.error(request, "Invalid status value.")
                
            return redirect('sa_guidelines_category')

        elif action == 'delete':
            pk = request.POST.get('id')
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                category = get_object_or_404(GuidelinesCategory, pk=pk)
                category.status = 2 
                category.updated_by = user
                category.save() 
                messages.success(request, "Guidelines Category deleted successfully.")
            return redirect('sa_guidelines_category')  

        return redirect('sa_guidelines_category')

class ManageGuidelinesView(LoginRequiredMixin, View):
    def get(self, request): 
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_guidelines': True,
                'can_view_guidelines': True,
                'can_edit_guidelines': True,
                'can_delete_guidelines': True,  
                'can_update_guidelines_status': True, 
                'can_view_unique_guidelines':True,
                'can_export_guidelines':True,
                'can_filter_guidelines':True,
   
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_guidelines:
                return redirect('user_not_allowed')  


        guidelinestype = request.GET.get('guidelinestype', '')
        guidelinescategory = request.GET.get('guidelinescategory', '')
        croptype = request.GET.get('croptype', '')
        crop_id = request.GET.get('crop', '')
        guideline_id = request.GET.get('guideline', '')
        status = request.GET.get('status', '')

        date_filter = request.GET.get('dt_fill_issue_rpt', 'all')
        custom_start_date = request.GET.get('custom_start_date', '')
        custom_end_date = request.GET.get('custom_end_date', '')
        month = request.GET.get('month', '')
        start_of_week = ''
        end_of_week = ''
        if month:
            try:
                # Try parsing the 'MM-YYYY' format (e.g., '11-2024')
                # print('Trying MM-YYYY format')
                month, year = map(int, month.split('-'))
                start_of_month = timezone.datetime(year, month, 1).date()
            except ValueError:
                try:
                    # Try parsing the 'MMM-YYYY' format (e.g., 'Dec-2024')
                    # print('Trying MMM-YYYY format')
                    month_name, year = month.split('-')
                    month = datetime.strptime(month_name, '%b').month  # Convert month name to month number
                    start_of_month = timezone.datetime(int(year), month, 1).date()
                except ValueError:
                    # Handle the case where the input is neither a valid 'MM-YYYY' nor 'MMM-YYYY'
                    start_of_month = ''
                    end_of_month = ''
                    # print('Invalid month format')
            # After we successfully get the start date, calculate the end date
            last_day_of_month = calendar.monthrange(start_of_month.year, start_of_month.month)[1]
            end_of_month = timezone.datetime(start_of_month.year, start_of_month.month, last_day_of_month, 23, 59, 59).date()

        else:
            start_of_month = ''
            end_of_month = ''

        guidelines = Guidelines.objects.filter(status__in=[0, 1]).prefetch_related('guidelinescategory', 'guidelinestype', 'crop').order_by('-id')
        
        if guidelinestype:
            guidelines = guidelines.filter(guidelinestype__code=guidelinestype)
        if guidelinescategory:
            guidelines = guidelines.filter(guidelinescategory__id=guidelinescategory)
        if croptype:
             guidelines = guidelines.filter(crop__croptype__id=croptype)
        if crop_id:
            guidelines = guidelines.filter(crop__id=crop_id)
        if guideline_id:
            guidelines = guidelines.filter(id=guideline_id)
        if status:
            guidelines = guidelines.filter(status=status)
        


        # Handle the date filter logic
        if date_filter == 'today':
            today = timezone.now().date()
            guidelines = guidelines.filter(created_at__date=today)
        elif date_filter == 'week':
            today = timezone.now().date()
            start_of_week = today - timedelta(days=today.weekday())  # Monday
            end_of_week = start_of_week + timedelta(days=6)  # Sunday
            guidelines = guidelines.filter(
                created_at__date__gte=start_of_week,
                created_at__date__lte=end_of_week
            )
        elif date_filter == 'monthly':
            guidelines = guidelines.filter(
                created_at__date__gte=start_of_month,
                created_at__date__lte=end_of_month
            )
        elif date_filter == 'custom_date' and custom_start_date and custom_end_date:
            try:
                start_date = timezone.datetime.strptime(custom_start_date, '%d-%m-%Y').date()  # Updated format
                end_date = timezone.datetime.strptime(custom_end_date, '%d-%m-%Y').date()  # Updated format
                guidelines = guidelines.filter(
                    created_at__date__gte=start_date,
                    created_at__date__lte=end_date
                )
            except ValueError:
                pass 

        guidelinestypes = GuidelinesType.objects.filter(status=0)
        guidelinescategories = GuidelinesCategory.objects.filter(status=0)
        crop = Crop.objects.filter(status=0)
        crop_type = CropType.objects.filter(status=0)
        imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp']
        all_guidelines = Guidelines.objects.filter(status__in=[0, 1])

        show_per_page = request.GET.get('show',25)
        show_per_page = int(show_per_page)  # Convert it to an integer

        # Pagination setup
        paginator = Paginator(guidelines, show_per_page)  # Show the selected number of farmers per page 
        page_number = request.GET.get('page')  # Get the page number from the request
        page_obj = paginator.get_page(page_number)
        guidelines_count = 0
        for i in page_obj:
            guidelines_count += 1
        
        context = {
            'all_guidelines' : all_guidelines,
            'guidelines': page_obj,
            'entries_count': guidelines_count,
            'show_per_page': show_per_page,
            'guidelinestypes': guidelinestypes,
            'guidelinescategories': guidelinescategories, 
            'crop':crop,
            'crop_type' : crop_type,
            'imageext' : imageExtensions,
            'filter_type': guidelinestype if guidelinestype else '',
            'filter_catego': guidelinescategory if guidelinescategory else '',
            'filter_crop_typ': croptype if croptype else '',
            'filter_crop_id': int(crop_id) if crop_id else '',
            'filter_guideline_id': int(guideline_id) if guideline_id else '',
            'filter_status' : status if status else '',
            'date_filter' : date_filter,
            'can_add_guidelines': manage_user.can_add_guidelines if manage_user else False,
            'can_view_guidelines': manage_user.can_view_guidelines if manage_user else False,
            'can_edit_guidelines': manage_user.can_edit_guidelines if manage_user else False,
            'can_delete_guidelines': manage_user.can_delete_guidelines if manage_user else False,
            'can_update_guidelines_status': manage_user.can_update_guidelines_status if manage_user else False,
            'can_view_unique_guidelines': manage_user.can_view_unique_guidelines if manage_user else False,
            'can_export_guidelines': manage_user.can_export_guidelines if manage_user else False,
            'can_filter_guidelines': manage_user.can_filter_guidelines if manage_user else False,
        }

        return render(request, 'pages/super_admin/guidelines_management/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action') 

        # if action == 'create':
        #     name = request.POST.get('name')
        #     guidelinestype_id = request.POST.get('guidelinestype') 
        #     guidelinescategory_id = request.POST.get('guidelinescategory')
        #     description = request.POST.get('description')
        #     status = request.POST.get('status', 0) 
        #     media_type = request.POST.get('media_type')
            
        #     # Handle media fields (either video or document)
        #     video_url = request.POST.get('video_url', None)
        #     document = request.FILES.get('document', None)
            
        #     # Retrieve related objects
        #     guidelinestype = GuidelinesType.objects.get(code=guidelinestype_id) if guidelinestype_id else None
        #     guidelinescategory = GuidelinesCategory.objects.get(id=guidelinescategory_id) if guidelinescategory_id else None
            
        #     # Logic to handle the crop field based on guidelines type  
        #     if guidelinestype_id == '0':  # General
        #         crop = None  # No crop needed for General
        #     elif guidelinestype_id == '1':  # Based on Crop
        #         crop_id = request.POST.get('crop')
        #         crop = Crop.objects.get(id=crop_id) if crop_id else None
        #     else:
        #         return HttpResponse("Invalid Guidelines Type", status=400)

        #     # Validation: Ensure either video or document is provided, but not both
        #     if media_type == 'video' and not video_url:
        #         return HttpResponse("Video URL is required when media type is 'video'.", status=400)
        #     elif media_type == 'document' and not document:
        #         return HttpResponse("Document is required when media type is 'document'.", status=400)
        #     if media_type == 'video' and document:
        #         return HttpResponse("Please provide either a video URL or a document, not both.", status=400)

        #     # Validation for guidelines type and crop
        #     if guidelinestype_id == '0' and crop:  # General should not have a crop
        #         return HttpResponse("Crop should not be specified for general guidelines.", status=400)
            
        #     # Create the Guidelines object and save
        #     try:
        #         guideline = Guidelines(
        #             name=name,
        #             guidelinestype=guidelinestype,
        #             guidelinescategory=guidelinescategory,
        #             crop=crop,  # Crop will be None for General, else it will be based on the selected crop
        #             description=description,
        #             status=status,
        #             media_type=media_type,
        #             video_url=video_url if media_type == 'video' else None,
        #             document=document if media_type == 'document' else None,
        #             created_by=user
        #         )
        #         guideline.save()
        #         messages.success(request, "Guidelines Created Successfully.")
        #         return redirect('sa_manage_guidelines')  # Replace with your success page URL or name
        #     except Exception as e:
        #         return HttpResponse(f"Error while saving the guideline: {e}", status=500)

        if action == 'create':
            name = request.POST.get('name')
            guidelinestype_id = request.POST.get('guidelinestype') 
            guidelinescategory_id = request.POST.get('guidelinescategory')
            description = request.POST.get('description')
            status = request.POST.get('status', 0) 
            media_type = request.POST.get('media_type')
            
            # Handle media fields (either video or document)
            video_url = request.POST.get('video_url', None)
            document = request.FILES.get('document', None)
            
            # Retrieve related objects
            guidelinestype = GuidelinesType.objects.get(code=guidelinestype_id) if guidelinestype_id else None
            guidelinescategory = GuidelinesCategory.objects.get(id=guidelinescategory_id) if guidelinescategory_id else None
            
            # Logic to handle the crop field based on guidelines type  
            if guidelinestype_id == '0':  # General
                crop = None  # No crop needed for General
            elif guidelinestype_id == '1':  # Based on Crop
                crop_id = request.POST.get('crop')
                crop = Crop.objects.get(id=crop_id) if crop_id else None
            else:
                return HttpResponse("Invalid Guidelines Type", status=400)

            # Validation: Ensure either video or document is provided, but not both
            if media_type == 'video' and not video_url:
                return HttpResponse("Video URL is required when media type is 'video'.", status=400)
            elif media_type == 'document' and not document:
                return HttpResponse("Document is required when media type is 'document'.", status=400)
            if media_type == 'video' and document:
                return HttpResponse("Please provide either a video URL or a document, not both.", status=400)

            # Validation for guidelines type and crop
            if guidelinestype_id == '0' and crop:  # General should not have a crop
                return HttpResponse("Crop should not be specified for general guidelines.", status=400)
            
            # Convert document if needed
            def convert_uploaded_file(file):
                filename = file.name
                ext = filename.split('.')[-1].lower()

                if ext == 'csv':
                    # CSV → XLSX
                    df = pd.read_csv(file)
                    output = BytesIO()
                    df.to_excel(output, index=False, engine='openpyxl')
                    new_filename = filename.rsplit('.', 1)[0] + '.xlsx'
                    return ContentFile(output.getvalue(), new_filename)

                elif ext in ['docx', 'doc']:
                    # DOCX → PDF
                    temp_docx = f'/tmp/{filename}'
                    with open(temp_docx, 'wb') as f:
                        f.write(file.read())
                    pdf_filename = filename.rsplit('.', 1)[0] + '.pdf'
                    temp_pdf = f'/tmp/{pdf_filename}'
                    docx2pdf_convert(temp_docx, temp_pdf)
                    with open(temp_pdf, 'rb') as f:
                        pdf_file = ContentFile(f.read(), pdf_filename)
                    os.remove(temp_docx)
                    os.remove(temp_pdf)
                    return pdf_file
                else:
                    return file  # No conversion needed

            if document:
                document = convert_uploaded_file(document)

            # Create the Guidelines object and save
            try:
                guideline = Guidelines(
                    name=name,
                    guidelinestype=guidelinestype,
                    guidelinescategory=guidelinescategory,
                    crop=crop,  # Crop will be None for General
                    description=description,
                    status=status,
                    media_type=media_type,
                    video_url=video_url if media_type == 'video' else None,
                    document=document if media_type == 'document' else None,
                    created_by=user
                )
                guideline.save()
                messages.success(request, "Guidelines Created Successfully.")
                return redirect('sa_manage_guidelines')
            except Exception as e:
                return HttpResponse(f"Error while saving the guideline: {e}", status=500)

        elif action == 'update_status':
            pk = request.POST.get('id')
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                guidelinestatus = get_object_or_404(Guidelines, pk=pk)
                status = request.POST.get('status')

                if status == '0':
                    guidelinestatus.status = 0  
                    guidelinestatus.updated_by = user
                    guidelinestatus.save()
                    messages.success(request, "Guidelines Category has been activated.")
                elif status == '1':
                    guidelinestatus.status = 1  
                    guidelinestatus.updated_by = user
                    guidelinestatus.save()
                    messages.success(request, "Guidelines Category has been deactivated.")
                else:
                    messages.error(request, "Invalid status value.")
                
            return redirect('sa_manage_guidelines')
        
        elif action == 'delete':
            pk = request.POST.get('id')
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                guidelines = get_object_or_404(Guidelines, pk=pk)
                guidelines.status = 2  
                guidelines.updated_by = user
                guidelines.save() 
                messages.success(request, "Guidelines deleted successfully.")
            
            return redirect('sa_manage_guidelines')

        elif action == 'filter':
            user = request.user
            manage_user = None
            if user.is_superuser:
                context = {
                    'can_add_guidelines': True,
                    'can_view_guidelines': True,
                    'can_edit_guidelines': True,
                    'can_delete_guidelines': True,  
                    'can_update_guidelines_status': True, 
                    'can_view_unique_guidelines':True,
                    'can_export_guidelines':True,
                    'can_filter_guidelines':True,
    
                }
            else:
                try:
                    manage_user = ManageUser.objects.get(custom_user_id=user.id)
                except ManageUser.DoesNotExist:
                    manage_user = None

                if manage_user and not manage_user.can_view_guidelines:
                    return redirect('user_not_allowed')  

            guidelinestype = request.POST.get('guidelinestype', '')
            guidelinescategory = request.POST.get('guidelinescategory', '')
            croptype = request.POST.get('croptype', '')
            crop_id = request.POST.get('crop', '')
            guideline_id = request.POST.get('guideline', '')
            status = request.POST.get('status', '')
            date_filter = request.POST.get('dt_fill_issue_rpt', 'all')

            if not guidelinestype and not guidelinescategory and not croptype and not crop_id and not guideline_id and not status and date_filter == 'all':
                return redirect('sa_manage_guidelines')

            custom_start_date = request.POST.get('custom_start_date', '')
            custom_end_date = request.POST.get('custom_end_date', '')
            month = request.POST.get('month', '')
            start_of_week = ''
            end_of_week = ''
            if month:
                try:
                    # Try parsing the 'MM-YYYY' format (e.g., '11-2024')
                    # print('Trying MM-YYYY format')
                    month, year = map(int, month.split('-'))
                    start_of_month = timezone.datetime(year, month, 1).date()
                except ValueError:
                    try:
                        # Try parsing the 'MMM-YYYY' format (e.g., 'Dec-2024')
                        # print('Trying MMM-YYYY format')
                        month_name, year = month.split('-')
                        month = datetime.strptime(month_name, '%b').month  # Convert month name to month number
                        start_of_month = timezone.datetime(int(year), month, 1).date()
                    except ValueError:
                        # Handle the case where the input is neither a valid 'MM-YYYY' nor 'MMM-YYYY'
                        start_of_month = ''
                        end_of_month = ''
                        # print('Invalid month format')
                # After we successfully get the start date, calculate the end date
                last_day_of_month = calendar.monthrange(start_of_month.year, start_of_month.month)[1]
                end_of_month = timezone.datetime(start_of_month.year, start_of_month.month, last_day_of_month, 23, 59, 59).date()

            else:
                start_of_month = ''
                end_of_month = ''

            guidelines = Guidelines.objects.filter(status__in=[0, 1]).prefetch_related('guidelinescategory', 'guidelinestype', 'crop').order_by('-id')
            
            if guidelinestype:
                guidelines = guidelines.filter(guidelinestype__code=guidelinestype)
            if guidelinescategory:
                guidelines = guidelines.filter(guidelinescategory__id=guidelinescategory)
            if croptype:
                guidelines = guidelines.filter(crop__croptype__id=croptype)
            if crop_id:
                guidelines = guidelines.filter(crop__id=crop_id)
            if guideline_id:
                guidelines = guidelines.filter(id=guideline_id)
            if status:
                guidelines = guidelines.filter(status=status)
            


            # Handle the date filter logic
            if date_filter == 'today':
                today = timezone.now().date()
                guidelines = guidelines.filter(created_at__date=today)
            elif date_filter == 'week':
                today = timezone.now().date()
                start_of_week = today - timedelta(days=today.weekday())  # Monday
                end_of_week = start_of_week + timedelta(days=6)  # Sunday
                guidelines = guidelines.filter(
                    created_at__date__gte=start_of_week,
                    created_at__date__lte=end_of_week
                )
            elif date_filter == 'monthly':
                guidelines = guidelines.filter(
                    created_at__date__gte=start_of_month,
                    created_at__date__lte=end_of_month
                )
            elif date_filter == 'custom_date' and custom_start_date and custom_end_date:
                try:
                    start_date = timezone.datetime.strptime(custom_start_date, '%d-%m-%Y').date()  # Updated format
                    end_date = timezone.datetime.strptime(custom_end_date, '%d-%m-%Y').date()  # Updated format
                    guidelines = guidelines.filter(
                        created_at__date__gte=start_date,
                        created_at__date__lte=end_date
                    )
                except ValueError:
                    pass 

            guidelinestypes = GuidelinesType.objects.filter(status=0)
            guidelinescategories = GuidelinesCategory.objects.filter(status=0)
            crop = Crop.objects.filter(status=0)
            crop_type = CropType.objects.filter(status=0)
            imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp']
            all_guidelines = Guidelines.objects.filter(status__in=[0, 1])
            context = {
                'all_guidelines' : all_guidelines,
                'guidelines': guidelines,  
                'guidelinestypes': guidelinestypes,
                'guidelinescategories': guidelinescategories, 
                'crop':crop,
                'crop_type' : crop_type,
                'imageext' : imageExtensions,
                'filter_type': guidelinestype if guidelinestype else '',
                'filter_catego': guidelinescategory if guidelinescategory else '',
                'filter_crop_typ': croptype if croptype else '',
                'filter_crop_id': int(crop_id) if crop_id else '',
                'filter_guideline_id': int(guideline_id) if guideline_id else '',
                'filter_status' : status if status else '',
                'date_filter' : date_filter,
                'can_add_guidelines': manage_user.can_add_guidelines if manage_user else False,
                'can_view_guidelines': manage_user.can_view_guidelines if manage_user else False,
                'can_edit_guidelines': manage_user.can_edit_guidelines if manage_user else False,
                'can_delete_guidelines': manage_user.can_delete_guidelines if manage_user else False,
                'can_update_guidelines_status': manage_user.can_update_guidelines_status if manage_user else False,
                'can_view_unique_guidelines': manage_user.can_view_unique_guidelines if manage_user else False,
                'can_export_guidelines': manage_user.can_export_guidelines if manage_user else False,
                'can_filter_guidelines': manage_user.can_filter_guidelines if manage_user else False,
            }

            return render(request, 'pages/super_admin/guidelines_management/list.html', context)




def update_guideline(request):
    if request.method == 'POST':
        user_id = request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        # Print the POST data to check what is being submitted
        # print("POST Data:", request.POST)
        # print("FILES Data:", request.FILES)

        # Get the form data from the POST request
        guideline_id = request.POST.get('guideline_id')
        name = request.POST.get('name')
        description = request.POST.get('description')
        guidelinestype_code = request.POST.get('guidelinestype_edit')  # This should be the code, like "general" or "based_on_crop"
        guidelinescategory_id = request.POST.get('guidelinescategory')
        media_type = request.POST.get('guideline_upl_edit')  # Ensure media_type is correctly captured
        video_url = request.POST.get('video_url', None)
        document = request.FILES.get('document', None)
        crop_id = request.POST.get('crop', None)

        # Print the captured values to debug
        # print("Guideline ID:", guideline_id)
        # print("Name:", name)
        # print("Description:", description)
        # print("Guideline Type Code:", guidelinestype_code)
        # print("Guideline Category ID:", guidelinescategory_id)
        # print("Media Type:", media_type)
        # print("Video URL:", video_url)
        # print("Document:", document)
        # print("Crop ID:", crop_id)

        try:
            # Ensure the GuidelinesType exists
            try:
                guidelinestype = GuidelinesType.objects.get(code=guidelinestype_code)
                # print("Guideline Type:", guidelinestype)
            except GuidelinesType.DoesNotExist:
                return JsonResponse({"error": f"GuidelinesType with code {guidelinestype_code} does not exist."}, status=400)

            # Retrieve the guideline object to update
            guideline = get_object_or_404(Guidelines, id=guideline_id)
            # print("Existing Guideline:", guideline)

            # Retrieve related objects
            guidelinescategory = GuidelinesCategory.objects.get(id=guidelinescategory_id) if guidelinescategory_id else None
            crop = Crop.objects.get(id=crop_id) if crop_id else None

            # print("Guidelines Category:", guidelinescategory)
            # print("Crop:", crop)

            # Validation: Ensure either video or document is provided, but not both
            if media_type == 'video' and not video_url:
                return JsonResponse({"error": "Video URL is required when media type is 'video'."}, status=400)
            # elif media_type == 'document' and not document:
            #     return JsonResponse({"error": "Document is required when media type is 'document'."}, status=400)
            if media_type == 'video' and document:
                return JsonResponse({"error": "Please provide either a video URL or a document, not both."}, status=400)

            # Validation for guidelines type and crop
            if guidelinestype_code == 'general' and crop:  # General should not have a crop
                return JsonResponse({"error": "Crop should not be specified for general guidelines."}, status=400)

            if guidelinestype_code == 'based_on_crop' and not crop:  # Based on crop should have a crop
                return JsonResponse({"error": "Crop is required for 'based_on_crop' guidelines."}, status=400)

            # Update the guideline
            guideline.name = name
            guideline.description = description
            guideline.guidelinestype = guidelinestype
            guideline.guidelinescategory = guidelinescategory
            guideline.crop = crop  # Crop will be None for General, else it will be based on the selected crop
            guideline.media_type = media_type  # Ensure media_type is set here
            guideline.updated_by = user
            # Handle the media type (video/document)
            if media_type == 'video':
                guideline.video_url = video_url
                guideline.document = None  # Ensure document is None if it's a video
            elif media_type == 'document':
                guideline.video_url = None  # Ensure video_url is None if it's a document
                if document:
                    guideline.document = document

            guideline.save()

            messages.success(request, "Guideline updated successfully.")
            return JsonResponse({"message": "Guideline updated successfully."}, status=200)

        except ValidationError as e:
            # Handle validation error
            return JsonResponse({"error": str(e)}, status=400)
        except Exception as e:
            print("Error during guideline update:", e)
            return JsonResponse({"error": f"Error while updating the guideline: {e}"}, status=500)

    # Fetch categories and crops to pass to the template
    categories = GuidelinesCategory.objects.all()
    crops = Crop.objects.all()

    # Print categories and crops to debug
    # print("Categories:", categories)
    # print("Crops:", crops)

    # Retrieve existing guideline object (if in edit mode) to pre-fill the form
    guideline_id = request.GET.get('guideline_id')  # Assuming you pass the guideline_id in the URL
    guideline = get_object_or_404(Guidelines, id=guideline_id)

    # print("Guideline for Editing:", guideline)

    # Render the template and pass the categories, crops, and guideline to it
    return render(request, 'pages/super_admin/guidelines_management/manage_guidelines/list.html', {
        'categories': categories,
        'crops': crops,
        'guideline': guideline  # Pass the guideline object to pre-fill the form
    })

def get_guideline_data(request):
    # Ensure you're getting the 'id' from the query parameters
    guideline_id = request.GET.get('id')

    # Ensure 'id' exists in the query parameters
    if guideline_id is None:
        return JsonResponse({'success': False, 'message': 'ID parameter is required.'}, status=400)

    try:
        # Retrieve the guideline by its ID
        guideline = Guidelines.objects.get(id=guideline_id)

        # Prepare the data for response
        data = {
            'id': guideline.id,
            'name': guideline.name,
            'description': guideline.description,
            'guidelinestype': guideline.guidelinestype.name,
            'guidelinescategory': guideline.guidelinescategory.name,
            'crop': guideline.crop.name if guideline.crop else None,
            'media_type': guideline.media_type,
            'video_url': guideline.video_url,
            'document': guideline.document.url if guideline.document else None
        }

        # Print the data for debugging
        print(data)

        # Return the JSON response with success
        return JsonResponse({'success': True, 'data': data})

    except Guidelines.DoesNotExist:
        # Return an error message if the guideline is not found
        return JsonResponse({'success': False, 'message': 'Guideline not found.'}, status=404)

def get_guidelines_data(request):
    # Ensure you're getting the 'id' from the query parameters
    guideline_id = request.GET.get('id')

    # Ensure 'id' exists in the query parameters
    if guideline_id is None:
        return JsonResponse({'success': False, 'message': 'ID parameter is required.'}, status=400)

    try:
        # Retrieve the guideline by its ID
        guideline = Guidelines.objects.get(id=guideline_id)

        # Prepare the data for response
        data = {
            'id': guideline.id,
            'name': guideline.name,
            'description': guideline.description,
            'guidelinestype': guideline.guidelinestype.name,
            'guidelinescategory': guideline.guidelinescategory.name,
            'crop': guideline.crop.name if guideline.crop else None,
            'media_type': guideline.media_type,
            'video_url': guideline.video_url,
            'document': guideline.document.url if guideline.document else None
        }

        # Print the data for debugging
        print(data)

        # Return the JSON response with success
        return JsonResponse({'success': True, 'data': data})

    except Guidelines.DoesNotExist:
        # Return an error message if the guideline is not found
        return JsonResponse({'success': False, 'message': 'Guideline not found.'}, status=404)

# ----------------------------------------------------------------------- Near by Locations ----------------------------------------------

def get_location_category_translation(request, pk):
    language = request.GET.get('lang', 'en')
    try:
        soil_type = NearByLocationCategory.objects.get(pk=pk)
    except NearByLocationCategory.DoesNotExist:
        return JsonResponse({'error': 'data not found'}, status=404)

    if language == 'en':
        name = soil_type.name
        description = soil_type.description
    else:
        name = soil_type.get_translated_value('name', language)
        description = soil_type.get_translated_value('description', language)
    
    return JsonResponse({
        'name': name,
        'description': description
    })

class NearByLocationCategoryView(LoginRequiredMixin,View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_near_by_location_category': True,
                'can_view_near_by_location_category': True,
                'can_edit_near_by_location_category': True,
                'can_delete_near_by_location_category': True,  
                'can_status_near_by_location_category': True,  

            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_near_by_location_category:
                return redirect('user_not_allowed') 
            
        nearby_locations = NearByLocationCategory.objects.filter(Q(status=0) | Q(status=1)).order_by('-created_at')
        languages = Languages.objects.filter(status=0).order_by('id')
        context = {
            'languages': languages,
            'nearby_locations': nearby_locations,
            'messages': messages.get_messages(request),
            'can_add_near_by_location_category': manage_user.can_add_near_by_location_category if manage_user else False,
            'can_view_near_by_location_category': manage_user.can_view_near_by_location_category if manage_user else False,
            'can_edit_near_by_location_category': manage_user.can_edit_near_by_location_category if manage_user else False,
            'can_delete_near_by_location_category': manage_user.can_delete_near_by_location_category if manage_user else False,
            'can_status_near_by_location_category': manage_user.can_status_near_by_location_category if manage_user else False,
        }
        return render(request, 'layout/partials/super_admin/layout/header/_menu/data/near_by_locations_category/list.html', context)

    def post(self, request):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        action = request.POST.get('action')

        if action == 'create':
            name = request.POST.get('name')
            description = request.POST.get('description')

            # Validate name
            if not name:
                messages.error(request, 'This Field is Required.')
                return redirect('sa_manage_near_by_locations_category')

            # Check for duplicates
            if NearByLocationCategory.objects.filter(name=name, status__in=[0,1]).exists():
                messages.error(request, 'Nearby Location Already Exists.')
                return redirect('sa_manage_near_by_locations_category')

            # Create the Nearby Location Category
            NearByLocationCategory.objects.create(name=name, description=description,status=0,created_by=user, created_at=timezone.now()
            )
            messages.success(request, 'Nearby location created successfully.')
            return redirect('sa_manage_near_by_locations_category')

        elif action == 'update':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, 'No ID provided for update.')
                return redirect('sa_manage_near_by_locations_category')
            
            nearby_location = get_object_or_404(NearByLocationCategory, pk=pk)
            translated_json = nearby_location.translate_json or {
                'name' : {},
                'description': {}
            }
            name = request.POST.get('name')
            description = request.POST.get('description')
            language = request.POST.get('language')

            if not name:
                messages.error(request, 'Name is required.')
                return redirect('sa_manage_near_by_locations_category')
            
            if language == "en":
                if nearby_location.name != name:
                    nearby_location.name = name
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                            translated_json["name"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translating Location")
                if nearby_location.description != description:
                    nearby_location.description = description
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                            translated_json["description"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translating Location")
            else:
                translated_json["name"][language] = name
                if description:
                    translated_json["description"][language] = description 
            
            nearby_location.updated_by = user
            nearby_location.translate_json = translated_json
            nearby_location.save()
            
            messages.success(request, 'Nearby location updated successfully.')
            return redirect('sa_manage_near_by_locations_category')

        elif action == 'update_status':
            pk = request.POST.get('id')

            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                nearby_location_category = get_object_or_404(NearByLocationCategory, pk=pk)

                status = request.POST.get('status')

                if status == '0':
                    nearby_location_category.status = 0
                    nearby_location_category.updated_by = user
                    nearby_location_category.save()
                    messages.success(request, "Nearby Location Category has been activated.")
                elif status == '1':
                    nearby_location_category.status = 1
                    nearby_location_category.updated_by = user
                    nearby_location_category.save()
                    messages.success(request, "Nearby Location Category has been deactivated.")
                else:
                    messages.error(request, "Invalid status value.")

            return redirect('sa_manage_near_by_locations_category')  
        
        elif action == 'delete':
            pk = request.POST.get('id')  # This will fetch the ID from the form

            if not pk:
                messages.error(request, "ID cannot be empty.")  # Error message if ID is not passed
            else:
                try:
                    nearby_location_category = get_object_or_404(NearByLocationCategory, pk=pk)
                    nearby_location_category.status = 2  # Set status to 2 (assuming 2 is the status for deleted workers)
                    nearby_location_category.updated_by = user
                    nearby_location_category.save()

                    messages.success(request, "Nearby Location Category has been deleted successfully.")
                except NearByLocationCategory.DoesNotExist:
                    messages.error(request, "Nearby Location Category not found.")

            return redirect('sa_manage_near_by_locations_category')

class NearByLocationView(LoginRequiredMixin, View):
    def get(self, request):
        trigger_subscription()
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_add_near_by_locations': True,
                'can_view_near_by_locations': True,
                'can_edit_near_by_locations': True,
                'can_delete_near_by_locations': True,  
                'can_status_near_by_locations': True,  
                'can_export_near_by_locations': True,
                'can_filter_near_by_locations': True,  
                'can_view_unique_near_by_locations': True,  
        
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None
                return redirect('sa_login')

            if manage_user and not manage_user.can_view_near_by_locations:
                return redirect('user_not_allowed') 
            
        search_query = request.GET.get('search', '')
        all_location = ManageNearByLocations.objects.all()
        locations = ManageNearByLocations.objects.filter(
            Q(status=0) | Q(status=1),
            Q(name__icontains=search_query) | Q(description__icontains=search_query)
        ).order_by('-id')

        category = NearByLocationCategory.objects.filter(Q(status=0)).order_by('-created_at')
        days = Days.objects.filter(Q(status=0) | Q(status=1))

        filter_category = request.GET.get('filter_category', '')
        filter_id = request.GET.get('filter_id', '')
        filter_day = request.GET.get('filter_day', '')
        filter_status = request.GET.get('filter_status', '')

        if filter_category:
            locations = locations.filter(category__id=filter_category)
        if filter_id:
            locations = locations.filter(id=filter_id)

        if filter_day:
            locations = locations.filter(days__code=filter_day).distinct()
        if filter_status in ['0', '1']:
            locations = locations.filter(status=filter_status)

        date_filter = request.GET.get('dt_fill_issue_rpt', 'all')
        custom_start_date = request.GET.get('custom_start_date', '')
        custom_end_date = request.GET.get('custom_end_date', '')
        month = request.GET.get('month', '')
        start_of_week = ''
        end_of_week = ''
        if month:
            try:
                # Try parsing the 'MM-YYYY' format (e.g., '11-2024')
                # print('Trying MM-YYYY format')
                month, year = map(int, month.split('-'))
                start_of_month = timezone.datetime(year, month, 1).date()
            except ValueError:
                try:
                    # Try parsing the 'MMM-YYYY' format (e.g., 'Dec-2024')
                    # print('Trying MMM-YYYY format')
                    month_name, year = month.split('-')
                    month = datetime.strptime(month_name, '%b').month  # Convert month name to month number
                    start_of_month = timezone.datetime(int(year), month, 1).date()
                except ValueError:
                    # Handle the case where the input is neither a valid 'MM-YYYY' nor 'MMM-YYYY'
                    start_of_month = ''
                    end_of_month = ''
                    # print('Invalid month format')
            # After we successfully get the start date, calculate the end date
            last_day_of_month = calendar.monthrange(start_of_month.year, start_of_month.month)[1]
            end_of_month = timezone.datetime(start_of_month.year, start_of_month.month, last_day_of_month, 23, 59, 59).date()

        else:
            start_of_month = ''
            end_of_month = ''

        # Handle the date filter logic
        if date_filter == 'today':
            today = timezone.now().date()
            locations = locations.filter(created_at__date=today)
        elif date_filter == 'week':
            today = timezone.now().date()
            start_of_week = today - timedelta(days=today.weekday())  # Monday
            end_of_week = start_of_week + timedelta(days=6)  # Sunday
            locations = locations.filter(
                created_at__date__gte=start_of_week,
                created_at__date__lte=end_of_week
            )
        elif date_filter == 'monthly':
            locations = locations.filter(
                created_at__date__gte=start_of_month,
                created_at__date__lte=end_of_month
            )
        elif date_filter == 'custom_date' and custom_start_date and custom_end_date:
            try:
                start_date = timezone.datetime.strptime(custom_start_date, '%d-%m-%Y').date()  # Updated format
                end_date = timezone.datetime.strptime(custom_end_date, '%d-%m-%Y').date()  # Updated format
                locations = locations.filter(
                    created_at__date__gte=start_date,
                    created_at__date__lte=end_date
                )
            except ValueError:
                pass 

        show_per_page = request.GET.get('show',25)
        show_per_page = int(show_per_page)  # Convert it to an integer

        paginator = Paginator(locations, show_per_page)
        page_number = request.GET.get('page')
        page_obj = paginator.get_page(page_number)
        locations_count = 0
        for i in page_obj:
            locations_count += 1

        context = {
            'all_location' : all_location,
            'locations': page_obj,
            'entries_count': locations_count,
            'show_per_page': show_per_page,
            'category': category,
            'days': days,  
            'filter_category': filter_category if filter_category else '',
            'filter_id': int(filter_id) if filter_id else '',
            'filter_day': int(filter_day) if filter_day else '',
            'filter_status' : filter_status if filter_status else '',
            'date_filter' : date_filter if date_filter else '', 
            'custom_start_date': custom_start_date if custom_start_date else '',
            'custom_end_date': custom_end_date if custom_end_date else '',
            'month': month if month else '',
            'countries': list(Country.objects.values('id', 'name')),
            'states': list(State.objects.values('id', 'name')),
            'cities': list(City.objects.values('id', 'name')),
            'taluks' : list(Taluk.objects.values('id', 'name')),
            'villages' : list(Village.objects.values('id', 'name')),
            'can_add_near_by_locations': manage_user.can_add_near_by_locations if manage_user else False,
            'can_view_near_by_locations': manage_user.can_view_near_by_locations if manage_user else False,
            'can_edit_near_by_locations': manage_user.can_edit_near_by_locations if manage_user else False,
            'can_delete_near_by_locations': manage_user.can_delete_near_by_locations if manage_user else False,
            'can_status_near_by_locations': manage_user.can_status_near_by_locations if manage_user else False,
            'can_export_near_by_locations': manage_user.can_export_near_by_locations if manage_user else False,
            'can_filter_near_by_locations': manage_user.can_filter_near_by_locations if manage_user else False,
            'can_view_unique_near_by_locations': manage_user.can_view_unique_near_by_locations if manage_user else False,
        }
        return render(request, 'pages/super_admin/near_by_locations/list.html', context)
    
    def post(self, request, *args, **kwargs):
        user_id = self.request.user.id
        user = get_object_or_404(CustomUser, id=user_id)
        locations = ManageNearByLocations.objects.filter(Q(status=0) | Q(status=1))
        category = NearByLocationCategory.objects.filter(Q(status=0))
        days = Days.objects.filter(Q(status=0))
        action = request.POST.get('action')
        lat_log = ['°','N', 'E', 'S', 'W']

        if action == 'update_status':
            pk = request.POST.get('id')
            
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                locations = get_object_or_404(ManageNearByLocations, pk=pk) 
                status = request.POST.get('status') 
                if status == '0':
                    locations.status = 0   
                    locations.updated_by = user
                    locations.save()
                    messages.success(request, "Location has been activated.") 
                elif status == '1':
                    locations.status = 1  
                    locations.updated_by = user
                    locations.save()
                    messages.success(request, "Location has been deactivated.")  
                else:
                    messages.error(request, "Invalid status value.")  
                
            return redirect('sa_manage_near_by_locations')   
        
        elif action == 'delete':
            pk = request.POST.get('id')
            if not pk:
                messages.error(request, "ID cannot be empty.")
            else:
                locations = get_object_or_404(ManageNearByLocations, pk=pk)
                locations.status = 2  
                locations.updated_by = user
                locations.save() 
                messages.success(request, "Locations deleted successfully.")
            
            return redirect('sa_manage_near_by_locations')
        
        elif action == 'update':
            pk = request.POST.get('id')
            location = get_object_or_404(ManageNearByLocations, pk=pk)
            translated_json = location.translate_json or {
                "name": {},
                "door_no": {},
                "description": {}
            }
            name = request.POST.get('name')
            description = request.POST.get('description')

            location_catego = request.POST.get('category')

            if location_catego:
                cato =  get_object_or_404(NearByLocationCategory, id=location_catego)
            
            open_time = request.POST.get('openingtime')
            try:
                parsed_time = parse_time(open_time)
                formatted_Otime = parsed_time.strftime("%H:%M:%S")
            except ValueError as e:
                # Handle the error (e.g., log it, return a message to the user, etc.)
                # print(e)
                pass
            
            close_time = request.POST.get('closingtime')
            try:
                parsed_time = parse_time(close_time)
                formatted_Ctime = parsed_time.strftime("%H:%M:%S")
            except ValueError as e:
                # Handle the error (e.g., log it, return a message to the user, etc.)
                # print(e)
                pass

            add_days = request.POST.getlist('update_days')
            # add_latitude = request.POST.get('latitude')
            # add_longitude = request.POST.get('longitude')
            # if contains_lat_log(lat_log, add_latitude) == False and contains_lat_log(lat_log, add_longitude) == False:
            #     add_latitude, add_longitude = convert_to_simplified_format(add_latitude, add_longitude)
            loca_image = request.FILES.get('img')
            add_phone = request.POST.get('contact')
            add_address = request.POST.get('address')

            door_no = request.POST.get('door_no')
            village_id = request.POST.get('edit_village')
            taluk_id = request.POST.get('edit_taluk')
            city_id = request.POST.get('edit_city')
            state_id = request.POST.get('edit_state')
            country_id = request.POST.get('edit_country')
            pincode = request.POST.get('pincode')

            village = Village.objects.get(id=village_id)
            taluk = Taluk.objects.get(id=taluk_id)
            city = City.objects.get(id=city_id)
            state = State.objects.get(id=state_id)
            country = Country.objects.get(id=country_id) 
            if location.name != name:
                location.name = name
                try:
                    for lang in target_language:
                        translated_text = GoogleTranslator(source='auto', target=lang).translate(name)
                        translated_json["name"][lang] = translated_text
                except Exception as e:
                    print(e)
                    print("Error in translating Location")
            location.category = cato
            location.contact = add_phone
            location.address = add_address
            location.openingtime = formatted_Otime
            location.closingtime = formatted_Ctime
            if location.description != description:
                location.description = description
                try:
                    for lang in target_language:
                        translated_text = GoogleTranslator(source='auto', target=lang).translate(description)
                        translated_json["description"][lang] = translated_text
                except Exception as e:
                    print(e)
                    print("Error in translating Location")
            location.status = 0
            # location.latitude = add_latitude
            # location.longitude = add_longitude
            location.updated_by = user

            if door_no:
                if location.door_no != door_no:
                    location.door_no = door_no
                    try:
                        for lang in target_language:
                            translated_text = GoogleTranslator(source='auto', target=lang).translate(door_no)
                            translated_json["door_no"][lang] = translated_text
                    except Exception as e:
                        print(e)
                        print("Error in translating Location")
            else:
                location.door_no = ''
            location.country = country
            location.village = village
            location.taluk = taluk
            location.city = city
            location.state = state
            location.pincode = pincode
            location.translate_json = translated_json
            location.save()

            location.days.clear()
            for day_code in add_days:
                day = Days.objects.get(code=day_code)
                location.days.add(day)
            if loca_image:
                location.img =loca_image
                location.save()

            address_parts = []
            if location.door_no:
                address_parts.append(door_no)
            if location.village:
                address_parts.append(village.name)
            if location.taluk:
                address_parts.append(taluk.name)
            if location.city:
                address_parts.append(city.name)
            if location.state:
                address_parts.append(state.name)
            if location.country:
                address_parts.append(country.name)
            if location.pincode:
                address_parts.append(pincode)

            full_address = ', '.join(address_parts)
            location.address = full_address
            location.save()

            messages.success(request, 'Nearby Location Updated successfully.')
            return redirect('sa_manage_near_by_locations')
        
        elif action == 'create':
            # Get form data from POST
            name = request.POST.get('name')
            description = request.POST.get('description')
            category_code = request.POST.get('category')
            contact = request.POST.get('contact')
            # address = request.POST.get('address')
            opening_time = request.POST.get('openingtime')
            closing_time = request.POST.get('closingtime')
            # latitude = request.POST.get('latitude')
            # longitude = request.POST.get('longitude')
            # if contains_lat_log(lat_log,  latitude) == False and contains_lat_log(lat_log,  longitude) == False:
            #     latitude,  longitude = convert_to_simplified_format( latitude,  longitude)
            days = request.POST.getlist('days')
            img = request.FILES.get('img')

            # Get the category object
            category = get_object_or_404(NearByLocationCategory, id=category_code)

            # Parse opening and closing times
            try:
                open_time = parse_time(opening_time).strftime("%H:%M:%S")
            except ValueError:
                open_time = None  # Handle invalid time if needed

            try:
                close_time = parse_time(closing_time).strftime("%H:%M:%S")
            except ValueError:
                close_time = None  # Handle invalid time if needed

            door_no = request.POST.get('door_no', '')
            pincode = request.POST.get('pincode', '')
            village_id = request.POST.get('village')
            if not village_id:
                return redirect('sa_manage_market')
            try:
                village = Village.objects.get(id=village_id)
            except Village.DoesNotExist:
                messages.error(request, "The selected village does not exist.")
                return redirect('sa_manage_market')

            taluk_id = request.POST.get('taluk')
            city_id = request.POST.get('city')
            state_id = request.POST.get('state')
            country_id = request.POST.get('country')

            if not taluk_id or not city_id or not state_id or not country_id:
                messages.error(request, "Taluk, city, state, and country are required.")
                return redirect('sa_manage_market')

            try:
                taluk = Taluk.objects.get(id=taluk_id)
                city = City.objects.get(id=city_id)
                state = State.objects.get(id=state_id)
                country = Country.objects.get(id=country_id)
            except (Taluk.DoesNotExist, City.DoesNotExist, State.DoesNotExist, Country.DoesNotExist):
                messages.error(request, "Invalid taluk, city, state, or country.")
                return redirect('sa_manage_market')


            # Create the new location object
            location = ManageNearByLocations.objects.create(
                name=name,
                description=description,
                contact=contact,
                # address=address,
                city=city,
                state=state,
                country=country,
                village=village,
                taluk=taluk,
                door_no=door_no,
                pincode=pincode,
                openingtime=open_time,
                closingtime=close_time,
                # latitude=latitude,
                # longitude=longitude,
                category=category,
                status=0,
                created_by = user , created_at=timezone.now()
            )

            # Add days to location (if days are selected)
            for day_code in days:
                day = get_object_or_404(Days, code=day_code)
                location.days.add(day)

            # Handle image upload (optional)
            if img:
                location.img = img
                location.save()

            address_parts = []
            if location.door_no:
                address_parts.append(door_no)
            if location.village:
                address_parts.append(village.name)
            if location.taluk:
                address_parts.append(taluk.name)
            if location.city:
                address_parts.append(city.name)
            if location.state:
                address_parts.append(state.name)
            if location.country:
                address_parts.append(country.name)
            if location.pincode:
                address_parts.append(pincode)

            full_address = ', '.join(address_parts)
            location.address = full_address
            location.save()

            messages.success(request, 'Nearby Location created successfully.')
            return redirect('sa_manage_near_by_locations')
 
        elif action == 'filter':
            user = request.user
            manage_user = None
            if user.is_superuser:
                context = {
                    'can_add_near_by_locations': True,
                    'can_view_near_by_locations': True,
                    'can_edit_near_by_locations': True,
                    'can_delete_near_by_locations': True,  
                    'can_status_near_by_locations': True,  
                    'can_export_near_by_locations': True,
                    'can_filter_near_by_locations': True,  
                    'can_view_unique_near_by_locations': True,  
            
                }
            else:
                try:
                    manage_user = ManageUser.objects.get(custom_user_id=user.id)
                except ManageUser.DoesNotExist:
                    manage_user = None

                if manage_user and not manage_user.can_view_near_by_locations:
                    return redirect('user_not_allowed') 
                
            search_query = request.GET.get('search', '')
            all_location = ManageNearByLocations.objects.all()
            locations = ManageNearByLocations.objects.filter(
                Q(status=0) | Q(status=1),
                Q(name__icontains=search_query) | Q(description__icontains=search_query)
            ).order_by('-id')

            category = NearByLocationCategory.objects.filter(Q(status=0)).order_by('-created_at')
            days = Days.objects.filter(Q(status=0) | Q(status=1))

            filter_category = request.POST.get('filter_category', '')
            filter_id = request.POST.get('filter_id', '')
            filter_day = request.POST.get('filter_day', '')
            filter_status = request.POST.get('filter_status', '')

            if filter_category:
                locations = locations.filter(category__id=filter_category)
            if filter_id:
                locations = locations.filter(id=filter_id)

            if filter_day:
                locations = locations.filter(days__code=filter_day).distinct()
            if filter_status in ['0', '1']:
                locations = locations.filter(status=filter_status)

            date_filter = request.POST.get('dt_fill_issue_rpt', 'all')
            custom_start_date = request.POST.get('custom_start_date', '')
            custom_end_date = request.POST.get('custom_end_date', '')
            month = request.POST.get('month', '')
            start_of_week = ''
            end_of_week = ''

            if not filter_category and not filter_id and not filter_day and not filter_status and date_filter == "all":
                return redirect('sa_manage_near_by_locations')

            if month:
                try:
                    # Try parsing the 'MM-YYYY' format (e.g., '11-2024')
                    # print('Trying MM-YYYY format')
                    month, year = map(int, month.split('-'))
                    start_of_month = timezone.datetime(year, month, 1).date()
                except ValueError:
                    try:
                        # Try parsing the 'MMM-YYYY' format (e.g., 'Dec-2024')
                        # print('Trying MMM-YYYY format')
                        month_name, year = month.split('-')
                        month = datetime.strptime(month_name, '%b').month  # Convert month name to month number
                        start_of_month = timezone.datetime(int(year), month, 1).date()
                    except ValueError:
                        # Handle the case where the input is neither a valid 'MM-YYYY' nor 'MMM-YYYY'
                        start_of_month = ''
                        end_of_month = ''
                        # print('Invalid month format')
                # After we successfully get the start date, calculate the end date
                last_day_of_month = calendar.monthrange(start_of_month.year, start_of_month.month)[1]
                end_of_month = timezone.datetime(start_of_month.year, start_of_month.month, last_day_of_month, 23, 59, 59).date()

            else:
                start_of_month = ''
                end_of_month = ''

            # Handle the date filter logic
            if date_filter == 'today':
                today = timezone.now().date()
                locations = locations.filter(created_at__date=today)
            elif date_filter == 'week':
                today = timezone.now().date()
                start_of_week = today - timedelta(days=today.weekday())  # Monday
                end_of_week = start_of_week + timedelta(days=6)  # Sunday
                locations = locations.filter(
                    created_at__date__gte=start_of_week,
                    created_at__date__lte=end_of_week
                )
            elif date_filter == 'monthly':
                locations = locations.filter(
                    created_at__date__gte=start_of_month,
                    created_at__date__lte=end_of_month
                )
            elif date_filter == 'custom_date' and custom_start_date and custom_end_date:
                try:
                    start_date = timezone.datetime.strptime(custom_start_date, '%d-%m-%Y').date()  # Updated format
                    end_date = timezone.datetime.strptime(custom_end_date, '%d-%m-%Y').date()  # Updated format
                    locations = locations.filter(
                        created_at__date__gte=start_date,
                        created_at__date__lte=end_date
                    )
                except ValueError:
                    pass 

            paginator = Paginator(locations, 10) 
            page_number = request.GET.get('page')
            page_obj = paginator.get_page(page_number)

            context = {
                'all_location' : all_location,
                'locations': page_obj,
                'category': category,
                'days': days,  
                'filter_category': filter_category if filter_category else '',
                'filter_id': int(filter_id) if filter_id else '',
                'filter_day': int(filter_day) if filter_day else '',
                'filter_status' : filter_status if filter_status else '',
                'date_filter' : date_filter if date_filter else '', 
                'custom_start_date': custom_start_date if custom_start_date else '',
                'custom_end_date': custom_end_date if custom_end_date else '',
                'month': month if month else '',
                'countries': list(Country.objects.values('id', 'name')),
                'states': list(State.objects.values('id', 'name')),
                'cities': list(City.objects.values('id', 'name')),
                'taluks' : list(Taluk.objects.values('id', 'name')),
                'villages' : list(Village.objects.values('id', 'name')),
                'can_add_near_by_locations': manage_user.can_add_near_by_locations if manage_user else False,
                'can_view_near_by_locations': manage_user.can_view_near_by_locations if manage_user else False,
                'can_edit_near_by_locations': manage_user.can_edit_near_by_locations if manage_user else False,
                'can_delete_near_by_locations': manage_user.can_delete_near_by_locations if manage_user else False,
                'can_status_near_by_locations': manage_user.can_status_near_by_locations if manage_user else False,
                'can_export_near_by_locations': manage_user.can_export_near_by_locations if manage_user else False,
                'can_filter_near_by_locations': manage_user.can_filter_near_by_locations if manage_user else False,
                'can_view_unique_near_by_locations': manage_user.can_view_unique_near_by_locations if manage_user else False,
            }
            
            return render(request, 'pages/super_admin/near_by_locations/list.html', context)

def export_nearby_locations(request):
    # Get the list of locations
    filter_category = request.GET.get('filter_category', '')
    filter_id = request.GET.get('filter_id', '')
    filter_day = request.GET.get('filter_day', '')
    filter_status = request.GET.get('filter_status', '')

    locations = ManageNearByLocations.objects.filter(Q(status=0) | Q(status=1)).order_by('-id')

    if filter_category:
        locations = locations.filter(category__id=filter_category)
    if filter_id:
        locations = locations.filter(id=filter_id)

    if filter_day:
        locations = locations.filter(days__code=filter_day).distinct()
    if filter_status in ['0', '1']:
        locations = locations.filter(status=filter_status)

    date_filter = request.GET.get('dt_fill_issue_rpt', 'all')
    custom_start_date = request.GET.get('custom_start_date', '')
    custom_end_date = request.GET.get('custom_end_date', '')
    month = request.GET.get('month', '')
    start_of_week = ''
    end_of_week = ''

    if month:
        try:
            # Try parsing the 'MM-YYYY' format (e.g., '11-2024')
            # print('Trying MM-YYYY format')
            month, year = map(int, month.split('-'))
            start_of_month = timezone.datetime(year, month, 1).date()
        except ValueError:
            try:
                # Try parsing the 'MMM-YYYY' format (e.g., 'Dec-2024')
                # print('Trying MMM-YYYY format')
                month_name, year = month.split('-')
                month = datetime.strptime(month_name, '%b').month  # Convert month name to month number
                start_of_month = timezone.datetime(int(year), month, 1).date()
            except ValueError:
                # Handle the case where the input is neither a valid 'MM-YYYY' nor 'MMM-YYYY'
                start_of_month = ''
                end_of_month = ''
                # print('Invalid month format')
        # After we successfully get the start date, calculate the end date
        last_day_of_month = calendar.monthrange(start_of_month.year, start_of_month.month)[1]
        end_of_month = timezone.datetime(start_of_month.year, start_of_month.month, last_day_of_month, 23, 59, 59).date()

    else:
        start_of_month = ''
        end_of_month = ''


    # Handle the date filter logic
    if date_filter == 'today':
        today = timezone.now().date()
        locations = locations.filter(created_at__date=today)
    elif date_filter == 'week':
        today = timezone.now().date()
        start_of_week = today - timedelta(days=today.weekday())  # Monday
        end_of_week = start_of_week + timedelta(days=6)  # Sunday
        locations = locations.filter(
            created_at__date__gte=start_of_week,
            created_at__date__lte=end_of_week
        )
    elif date_filter == 'monthly':
        locations = locations.filter(
            created_at__date__gte=start_of_month,
            created_at__date__lte=end_of_month
        )
    elif date_filter == 'custom_date' and custom_start_date and custom_end_date:
        try:
            start_date = timezone.datetime.strptime(custom_start_date, '%d-%m-%Y').date()  # Updated format
            end_date = timezone.datetime.strptime(custom_end_date, '%d-%m-%Y').date()  # Updated format
            locations = locations.filter(
                created_at__date__gte=start_date,
                created_at__date__lte=end_date
            )
        except ValueError:
            pass 


    # Create the HTTP response with CSV format
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename=nearby_locations.csv'

    # Create a CSV writer object
    writer = csv.writer(response)

    # Write the header row with column names
    writer.writerow([
        'Category', 'Name', 'Contact', 'Address', 'Description', 'Opening Time', 'Closing Time', 'Days', 'Status'
    ])

    # Write data rows for each location
    for location in locations:
        writer.writerow([ 
            location.category.name if location.category else '',
            location.name,
            location.contact if location.contact else '',
            location.address if location.address else '',
            location.description if location.description else '',
            location.openingtime if location.openingtime else '',
            location.closingtime if location.closingtime else '',
            ', '.join([day.name for day in location.days.all()]) if location.days.exists() else '',
            'Active' if location.status == 0 else 'In-Active',
        ])

    return response

def contains_lat_log(symbol_list, value):
    for symbol in symbol_list:
        if symbol in value:
            return True
    return False

def convert_to_simplified_format(latitude, longitude):
    # Round latitude and longitude to 4 decimal places
    # latitude_simplified = round(latitude, 4)
    # longitude_simplified = round(longitude, 4)

    # Prepare the formatted string
    latitude_result = f"{latitude}° N"
    longitude_result = f"{longitude}° E"

    return latitude_result, longitude_result

# ---------------------------------------------------------------------------- Rental --------------------------------------------------------

class RentalAvailabilityView(LoginRequiredMixin,View):
    def get(self, request):
        user = request.user
        manage_user = None
        if user.is_superuser:
            context = {
                'can_view_rental_availability': True,
                'can_filter_rental_availability': True,
                'can_export_rental_availability': True,
            }
        else:
            try:
                manage_user = ManageUser.objects.get(custom_user_id=user.id)
            except ManageUser.DoesNotExist:
                manage_user = None

            if manage_user and not manage_user.can_view_rental_availability:
                return redirect('user_not_allowed')
            
        latest_inventory = MyInventory.objects.filter(rental=0, status=0) \
            .values('farmer', 'inventory_items') \
            .annotate(latest_created_at=Max('created_at'))
        rent = MyInventory.objects.filter(
            rental=0,
            status=0,
            created_at__in=[entry['latest_created_at'] for entry in latest_inventory]
        ).order_by('-updated_at')
       
        items = InventoryItems.objects.filter(inventory_type__code__in=[0, 1, 2])
        filter_type = request.GET.get('filter_type', '')
        filter_item = request.GET.get('filter_item', '')
        date_filter = request.GET.get('dt_fill_issue_rpt', 'all')

        custom_start_date = request.GET.get('custom_start_date', '')
        custom_end_date = request.GET.get('custom_end_date', '')
        month = request.GET.get('month', '')
        start_of_week = ''
        end_of_week = ''
        if month:
            try:
                month, year = map(int, month.split('-'))
                start_of_month = timezone.datetime(year, month, 1).date()
            except ValueError:
                try:
                    month_name, year = month.split('-')
                    month = datetime.strptime(month_name, '%b').month  # Convert month name to month number
                    start_of_month = timezone.datetime(int(year), month, 1).date()
                except ValueError:
                    start_of_month = ''
                    end_of_month = ''
            last_day_of_month = calendar.monthrange(start_of_month.year, start_of_month.month)[1]
            end_of_month = timezone.datetime(start_of_month.year, start_of_month.month, last_day_of_month, 23, 59, 59).date()

        else:
            start_of_month = ''
            end_of_month = ''

        if filter_type:
            rent = rent.filter(inventory_type__code=filter_type)
        
        if filter_item:
            rent = rent.filter(inventory_items=get_object_or_404(InventoryItems, pk=filter_item))

        if date_filter == 'today':
            today = timezone.now().date()
            rent = rent.filter(created_at__date=today)
        elif date_filter == 'week':
            today = timezone.now().date()
            start_of_week = today - timedelta(days=today.weekday())  # Monday
            end_of_week = start_of_week + timedelta(days=6)  # Sunday
            rent = rent.filter(
                created_at__date__gte=start_of_week,
                created_at__date__lte=end_of_week
            )
        elif date_filter == 'monthly':
            rent = rent.filter(
                created_at__date__gte=start_of_month,
                created_at__date__lte=end_of_month
            )
        elif date_filter == 'custom_date' and custom_start_date and custom_end_date:
            try:
                start_date = timezone.datetime.strptime(custom_start_date, '%d-%m-%Y').date()  # Updated format
                end_date = timezone.datetime.strptime(custom_end_date, '%d-%m-%Y').date()  # Updated format
                rent = rent.filter(
                    created_at__date__gte=start_date,
                    created_at__date__lte=end_date
                )
            except ValueError:
                pass 
        
        show_per_page = request.GET.get('show',25)
        show_per_page = int(show_per_page)  # Convert it to an integer

        # Pagination setup
        paginator = Paginator(rent, show_per_page)  # Show the selected number of farmers per page 
        page_number = request.GET.get('page')  # Get the page number from the request
        page_obj = paginator.get_page(page_number)
        rental_count = 0
        for i in page_obj:
            rental_count += 1

        context = {
            'rental' : page_obj,
            'entries_count': rental_count,
            'show_per_page': show_per_page,
            'items' : items,
            'filter_type': filter_type if filter_type else '',
            'filter_item': int(filter_item) if filter_item else '',
            'date_filter': date_filter if date_filter else 'all',
            'can_view_rental_availability': manage_user.can_view_rental_availability if manage_user else False,
            'can_filter_rental_availability': manage_user.can_filter_rental_availability if manage_user else False,
            'can_export_rental_availability': manage_user.can_export_rental_availability if manage_user else False,
        }
        return render(request, 'pages/super_admin/rental_availability/list.html', context)

    def post(self, request):
        action = request.POST.get('action')

        if action == 'filter':
            user = request.user
            manage_user = None
            if user.is_superuser:
                context = {
                    'can_view_rental_availability': True,
                    'can_filter_rental_availability': True,
                    'can_export_rental_availability': True, 
                }
            else:
                try:
                    manage_user = ManageUser.objects.get(custom_user_id=user.id)
                except ManageUser.DoesNotExist:
                    manage_user = None

                if manage_user and not manage_user.can_view_rental_availability:
                    return redirect('user_not_allowed')
                
            latest_inventory = MyInventory.objects.filter(rental=0, status=0) \
                .values('farmer', 'inventory_items') \
                .annotate(latest_created_at=Max('created_at'))
            rent = MyInventory.objects.filter(
                rental=0,
                status=0,
                created_at__in=[entry['latest_created_at'] for entry in latest_inventory]
            )
            items = InventoryItems.objects.filter(inventory_type__code__in=[0, 1, 2])
            filter_type = request.POST.get('filter_type', '')
            filter_item = request.POST.get('filter_item', '')
            date_filter = request.POST.get('dt_fill_issue_rpt', 'all')

            if not filter_type and not filter_item and date_filter == 'all':
                return redirect('sa_rental_availability')
        
            custom_start_date = request.POST.get('custom_start_date', '')
            custom_end_date = request.POST.get('custom_end_date', '')
            month = request.POST.get('month', '')
            start_of_week = ''
            end_of_week = ''
            if month:
                try:
                    month, year = map(int, month.split('-'))
                    start_of_month = timezone.datetime(year, month, 1).date()
                except ValueError:
                    try:
                        month_name, year = month.split('-')
                        month = datetime.strptime(month_name, '%b').month  # Convert month name to month number
                        start_of_month = timezone.datetime(int(year), month, 1).date()
                    except ValueError:
                        start_of_month = ''
                        end_of_month = ''
                last_day_of_month = calendar.monthrange(start_of_month.year, start_of_month.month)[1]
                end_of_month = timezone.datetime(start_of_month.year, start_of_month.month, last_day_of_month, 23, 59, 59).date()

            else:
                start_of_month = ''
                end_of_month = ''

            if filter_type:
                rent = rent.filter(inventory_type__code=filter_type)
            
            if filter_item:
                rent = rent.filter(inventory_items=get_object_or_404(InventoryItems, pk=filter_item))

            if date_filter == 'today':
                today = timezone.now().date()
                rent = rent.filter(created_at__date=today)
            elif date_filter == 'week':
                today = timezone.now().date()
                start_of_week = today - timedelta(days=today.weekday())  # Monday
                end_of_week = start_of_week + timedelta(days=6)  # Sunday
                rent = rent.filter(
                    created_at__date__gte=start_of_week,
                    created_at__date__lte=end_of_week
                )
            elif date_filter == 'monthly':
                rent = rent.filter(
                    created_at__date__gte=start_of_month,
                    created_at__date__lte=end_of_month
                )
            elif date_filter == 'custom_date' and custom_start_date and custom_end_date:
                try:
                    start_date = timezone.datetime.strptime(custom_start_date, '%d-%m-%Y').date()  # Updated format
                    end_date = timezone.datetime.strptime(custom_end_date, '%d-%m-%Y').date()  # Updated format
                    rent = rent.filter(
                        created_at__date__gte=start_date,
                        created_at__date__lte=end_date
                    )
                except ValueError:
                    pass 

            
            context = {
                'rental' : rent,
                'items' : items,
                'filter_type': filter_type if filter_type else '',
                'filter_item': int(filter_item) if filter_item else '',
                'date_filter': date_filter if date_filter else 'all',
                'can_view_rental_availability': manage_user.can_view_rental_availability if manage_user else False,
                'can_filter_rental_availability': manage_user.can_filter_rental_availability if manage_user else False,
                'can_export_rental_availability': manage_user.can_export_rental_availability if manage_user else False,
                
            }
            return render(request, 'pages/super_admin/rental_availability/list.html', context)

        return redirect('sa_rental_availability')

def get_inventory_items(request):
    filter_type = request.GET.get('filter_type', None)
    
    if filter_type is None or filter_type == "":  # No filter, return all items
        items = InventoryItems.objects.filter(inventory_type__code__in=[0, 1, 2])
    else:
        items = InventoryItems.objects.filter(inventory_type__code=filter_type)
    
    items_data = []
    for item in items:
        items_data.append({
            'id': item.id,
            'name': item.name,
        })
    
    return JsonResponse({'items': items_data})




# def handler404(request,exception):
#     return render(request, 'pages/system/not-found.html', status=404)\


# This is the actual 404 handler used by Django (DO NOT call directly via path())
def handler400(request, exception):
    return render(request, 'pages/system/not-found.html', status=400)

def handler403(request, exception):
    return render(request, 'pages/system/not-found.html', status=403)

def handler404(request, exception):
    if isinstance(exception, Http404):
        print("This is a 404 error")
    return render(request, 'pages/system/not-found.html', status=404)

def handler500(request):
    return render(request, 'pages/system/not-found.html', status=500)

# This is a test view you can call manually at /SuperAdmin/test-404/
def test_404_view(request):
    return render(request, 'pages/system/not-found.html', status=404)