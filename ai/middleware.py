from django.utils import timezone
import pytz
from .models import GeneralSetting

class TimezoneMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        try:
            settings_obj = GeneralSetting.objects.first()
            if settings_obj and settings_obj.time_format:
                timezone.activate(pytz.timezone(settings_obj.time_format))
            else:
                timezone.activate(pytz.UTC)
        except Exception as e:
            print(f"Error activating timezone: {e}")
            timezone.activate(pytz.UTC)  # Fallback in case of error
        
        response = self.get_response(request)
        return response
