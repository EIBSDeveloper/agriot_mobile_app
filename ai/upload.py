from django.views.generic import TemplateView
from django.http import HttpResponse
from django.conf import settings
from django.urls import resolve
from _keenthemes.__init__ import KTLayout
from _keenthemes.libs.theme import KTTheme
from pprint import pprint
from django.shortcuts import render, redirect
import os

"""
This file is a view controller for multiple pages as a module.
Here you can override the page view layout.
Refer to dashboards/urls.py file for more pages.
"""
    def handle_uploaded_file(file):
        upload_dir = './upload'
        filename = os.path.join(upload_dir, f'{str(int(time.time()))}-{file.name}')
        with open(filename, 'wb+') as destination:
            for chunk in file.chunks():
                destination.write(chunk)
