from django.apps import AppConfig


class AgriiotConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'ai'

    def ready(self):
        import ai.signals 