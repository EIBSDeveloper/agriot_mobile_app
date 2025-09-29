
    # def post(self, request):

    #     user_id = self.request.user.id
    #     user = get_object_or_404(CustomUser, id=user_id)

    #     if user.farmer_user:
    #         try:
    #             farmer = get_object_or_404(Farmer, farmer_user=user)
    #         except Exception as e:
    #             farmer = get_object_or_404(Farmer, sub_admin_user=user)
    #     else:
    #         try:
    #             employee = get_object_or_404(ManagerUser, manager_user=user)
    #             farmer = employee.farmer
    #         except Exception as e:
    #             logout(request)
    #             return redirect('fm_login')

    #     action = request.POST.get('action')

    #     if action == "create":
    #         name = request.POST.get('add_name')
    #         dob_str = request.POST.get('add_dob')
    #         formatted_dob = None
    #         if dob_str:
    #             try:
    #                 dob = datetime.strptime(dob_str, '%d-%m-%Y')
    #                 formatted_dob = dob.strftime('%Y-%m-%d')
    #             except ValueError:
    #                 return redirect('error_page')

    #         gender_code = request.POST.get('add_gender')
    #         gender = get_object_or_404(Gender, id=gender_code)
            
    #         mob_no = request.POST.get('add_phone')
    #         altt_mob_no = request.POST.get('add_alt_phone')
    #         email = request.POST.get('add_email')

    #         doj_str = request.POST.get('add_doj')
    #         formatted_doj = None
    #         if doj_str:
    #             try:
    #                 doj = datetime.strptime(doj_str, '%d-%m-%Y')
    #                 formatted_doj = doj.strftime('%Y-%m-%d')
    #             except ValueError:
    #                 return redirect('error_page')

    #         emp_type_id = request.POST.get('add_emp_type')
    #         emp_type = get_object_or_404(EmployeeType, id=emp_type_id)

    #         img = request.FILES.get('add_img')  # Image field
    #         print(img, type(img))

    #         role_id = request.POST.get('add_role')
    #         role = get_object_or_404(ManagerUserRole, id=role_id)  # Get the selected role
    #         address = request.POST.get('add_address')
    #         locations = request.POST.get('locations')
    #         latitude = request.POST.get('latitude')
    #         longitude = request.POST.get('longitude')
    #         selected_permissions = request.POST.getlist('permissions')      
    #         permission_map = {
    #             '1': 'dashboard_view',
    #             '2': 'land_list',
    #             '3': 'land_add',
    #             '4': 'land_edit',
    #             '5': 'land_view',
    #             '6': 'land_delete',
    #             '7': 'land_location',
    #             '8': 'crop_list',
    #             '9': 'crop_add',
    #             '10': 'crop_edit',
    #             '11': 'crop_view',
    #             '12': 'crop_delete',
    #             '13': 'crop_schedule',
    #             '14': 'schedule_list',
    #             '15': 'schedule_add',
    #             '16': 'schedule_edit',
    #             '17': 'schedule_view',
    #             '18': 'schedule_delete',
    #             '19': 'best_schedule_list',
    #             '20': 'best_schedule_view',
    #             '21': 'expense_list',
    #             '22': 'expense_add',
    #             '23': 'expense_edit',
    #             '24': 'expense_view',
    #             '25': 'expense_delete',
    #             '26': 'vendor_list',
    #             '27': 'vendor_add',
    #             '28': 'vendor_edit',
    #             '29': 'vendor_view',
    #             '30': 'vendor_delete',
    #             '31': 'sales_list',
    #             '32': 'sales_add',
    #             '33': 'sales_edit',
    #             '34': 'sales_view',
    #             '35': 'sales_delete',
    #             '36': 'customer_list',
    #             '37': 'customer_add',
    #             '38': 'customer_edit',
    #             '39': 'customer_view',
    #             '40': 'customer_delete',
    #             '41': 'fuel_list',
    #             '42': 'fuel_consuption',
    #             '43': 'fuel_view',
    #             '44': 'vehicle_list',
    #             '45': 'vehicle_consumption',
    #             '46': 'vehicle_view',
    #             '47': 'machinery_list',
    #             '48': 'machinery_consumption',
    #             '49': 'machinery_view',
    #             '50': 'tools_list',
    #             '51': 'tools_consumption',
    #             '52': 'tools_view',
    #             '53': 'pesticides_list',
    #             '54': 'pesticides_consumption',
    #             '55': 'pesticides_view',
    #             '56': 'fertilizer_list', 
    #             '57': 'fertilizer_consumption',
    #             '58': 'fertilizer_view',
    #             '59': 'seeds_list',
    #             '60': 'seeds_consumption',
    #             '61': 'seeds_view',
    #             '62': 'employee_list',
    #             '63': 'employee_add',
    #             '64': 'employee_edit',
    #             '65': 'employee_view',
    #             '66': 'employee_delete',
    #             '67': 'attendance_list',
    #             '68': 'attendance_add',
    #             '69': 'attendance_edit',
    #             '70': 'attendance_view',
    #             '71': 'payouts_list',
    #             '72': 'payouts_add',
    #             '73': 'payouts_edit',
    #             '74': 'payouts_view',
    #             '75': 'payouts_delete',
    #             '76': 'advance_list',
    #             '77': 'advance_add',
    #             '78': 'advance_edit',
    #             '79': 'advance_view',
    #             '80': 'advance_delete',
    #             '81': 'users_list',
    #             '82': 'users_add',
    #             '83': 'users_edit',
    #             '84': 'users_view',
    #             '85': 'users_delete',
    #             '86': 'role_list',
    #             '87': 'role_add',
    #             '88': 'role_edit',
    #             '89': 'role_view',
    #             '90': 'role_delete',
    #         }
    #         # Initialize all permissions to 0
    #         permissions = {key: 0 for key in permission_map.values()}
    #         # Set only the selected permissions to 1
    #         for permission_id in selected_permissions:
    #             key = permission_map.get(permission_id)
    #             if key:
    #                 permissions[key] = 1
    #         # Group-wise checks
    #         permissions['my_land'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('land_')
    #         ) else 0
    #         permissions['my_crop'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('crop_')
    #         ) else 0
    #         permissions['my_schedule'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('schedule_')
    #         ) else 0
    #         permissions['my_best_schedule'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('best_schedule_')
    #         ) else 0
    #         # Top-level 'farms' permission: include all related modules
    #         permissions['my_farms'] = 1 if any([
    #             permissions['my_land'],
    #             permissions['my_crop'],
    #             permissions['my_schedule'],
    #             permissions['my_best_schedule']
    #         ]) else 0
    #         permissions['my_expense'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('expense_')
    #         ) else 0
    #         permissions['my_vendor'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('vendor_')
    #         ) else 0
    #         # Top-level 'farms' permission: include all related modules
    #         permissions['expenses'] = 1 if any([
    #             permissions['my_expense'],
    #             permissions['my_vendor']
    #         ]) else 0
    #         permissions['my_sales'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('sales_')
    #         ) else 0
    #         permissions['my_customer'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('customer_')
    #         ) else 0
    #         # Top-level 'farms' permission: include all related modules
    #         permissions['sales'] = 1 if any([
    #             permissions['my_sales'],
    #             permissions['my_customer']
    #         ]) else 0      
    #         permissions['fuel'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('fuel_')
    #         ) else 0
    #         permissions['vehicle'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('vehicle_')
    #         ) else 0
    #         permissions['machinery'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('machinery_')
    #         ) else 0
    #         permissions['tools'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('tools_')
    #         ) else 0
    #         permissions['pesticides'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('pesticides_')
    #         ) else 0
    #         permissions['fertilizer'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('fertilizer_')
    #         ) else 0
    #         permissions['seeds'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('seeds_')
    #         ) else 0
    #         # Top-level 'farms' permission: include all related modules
    #         permissions['consumption'] = 1 if any([
    #             permissions['fuel'],
    #             permissions['vehicle'],
    #             permissions['machinery'],
    #             permissions['tools'],
    #             permissions['pesticides'],
    #             permissions['fertilizer'],
    #             permissions['seeds']
    #         ]) else 0  
    #         permissions['employee'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('employee_')
    #         ) else 0
    #         permissions['attendance'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('attendance_')
    #         ) else 0
    #         permissions['payouts'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('payouts_')
    #         ) else 0
    #         permissions['advance'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('advance_')
    #         ) else 0
    #         # Top-level 'farms' permission: include all related modules
    #         permissions['employee_management'] = 1 if any([
    #             permissions['employee'],
    #             permissions['attendance'],
    #             permissions['payouts'],
    #             permissions['advance']
    #         ]) else 0
    #         permissions['users'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('users_')
    #         ) else 0
    #         permissions['role'] = 1 if any(
    #             permissions[k] for k in permissions if k.startswith('role_')
    #         ) else 0
    #         # Top-level 'farms' permission: include all related modules
    #         permissions['user_management'] = 1 if any([
    #             permissions['users'],
    #             permissions['role']
    #         ]) else 0            
    #         new_user = ManagerUser(
    #             name=name,
    #             farmer=farmer,
    #             email=email,
    #             gender=gender,
    #             mobile_no=mob_no,
    #             employee_type=emp_type,
    #             role=role,
    #             date_of_birth=formatted_dob,
    #             alter_no=int(altt_mob_no) if altt_mob_no else None,
    #             date_of_join=formatted_doj,
    #             # image=img if img else None,
    #             address=address,
    #             locations=locations,
    #             latitude=latitude,
    #             longitude=longitude,
    #             created_by = user,
    #             created_at=timezone.now(),
    #             permissions=permissions
    #         )
    #         new_user.save()    
    #         if img:
    #             new_user.image = img
    #             new_user.save()
    #         auth_user = CustomUser(
    #             email = email,
    #             image = img if img else None,
    #             name = name,
    #             phone_number = mob_no,
    #             is_active = True,
    #             employee_user = True,
    #         )
    #         auth_user.save()
    #         new_user.manager_user = auth_user
    #         new_user.save()
    #         messages.success(request, "Manager User Created Successfully.") 
    #     return redirect('fm_manage_users')
