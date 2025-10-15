from rest_framework import serializers
from datetime import date
from.models import *

class FarmerSerializer(serializers.ModelSerializer):
    created_at = serializers.DateTimeField(format='%Y-%m-%dT%H:%M:%S')
    updated_at = serializers.DateTimeField(format='%Y-%m-%dT%H:%M:%S')
    subscription_end_date = serializers.DateField(format='%Y-%m-%d')

    class Meta:
        model = Farmer
        fields = '__all__'
