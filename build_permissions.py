def build_permissions(selected):
    """
    Convert various input formats into the flat permission dict used by storage.
    Supported `selected` formats:
      - nested/grouped dict: {"land": {"add":1, "view":0}, "dashboard":{"view":1}}
      - flat dict: {"land_add":1, "land_view":0}
      - list of keys: ["land_add","dashboard_view"]
      - list of numeric ids or numeric strings: [2, "3", 63]
      - None or empty -> returns default all-zero map
    Returns:
      dict with all base permission keys (from 1..90 mapping) set 0/1 and the derived/group flags:
      my_land, my_crop, my_schedule, my_best_schedule, my_farms,
      my_expense, my_vendor, expenses,
      my_sales, my_customer, sales,
      fuel, vehicle, machinery, tools, pesticides, fertilizer, seeds, consumption,
      employee, attendance, payouts, advance, employee_management,
      users, role, user_management
    """

    # --- ID -> key mapping (1..90) EXACT as your web code expects ---
    id_to_key = {
        '1': 'dashboard_view',
        '2': 'land_list',
        '3': 'land_add',
        '4': 'land_edit',
        '5': 'land_view',
        '6': 'land_delete',
        '7': 'land_location',
        '8': 'crop_list',
        '9': 'crop_add',
        '10': 'crop_edit',
        '11': 'crop_view',
        '12': 'crop_delete',
        '13': 'crop_schedule',
        '14': 'schedule_list',
        '15': 'schedule_add',
        '16': 'schedule_edit',
        '17': 'schedule_view',
        '18': 'schedule_delete',
        '19': 'best_schedule_list',
        '20': 'best_schedule_view',
        '21': 'expense_list',
        '22': 'expense_add',
        '23': 'expense_edit',
        '24': 'expense_view',
        '25': 'expense_delete',
        '26': 'vendor_list',
        '27': 'vendor_add',
        '28': 'vendor_edit',
        '29': 'vendor_view',
        '30': 'vendor_delete',
        '31': 'sales_list',
        '32': 'sales_add',
        '33': 'sales_edit',
        '34': 'sales_view',
        '35': 'sales_delete',
        '36': 'customer_list',
        '37': 'customer_add',
        '38': 'customer_edit',
        '39': 'customer_view',
        '40': 'customer_delete',
        '41': 'fuel_list',
        '42': 'fuel_consuption',       # keep original spelling (typo) to match DB
        '43': 'fuel_view',
        '44': 'vehicle_list',
        '45': 'vehicle_consumption',
        '46': 'vehicle_view',
        '47': 'machinery_list',
        '48': 'machinery_consumption',
        '49': 'machinery_view',
        '50': 'tools_list',
        '51': 'tools_consumption',
        '52': 'tools_view',
        '53': 'pesticides_list',
        '54': 'pesticides_consumption',
        '55': 'pesticides_view',
        '56': 'fertilizer_list',
        '57': 'fertilizer_consumption',
        '58': 'fertilizer_view',
        '59': 'seeds_list',
        '60': 'seeds_consumption',
        '61': 'seeds_view',
        '62': 'employee_list',
        '63': 'employee_add',
        '64': 'employee_edit',
        '65': 'employee_view',
        '66': 'employee_delete',
        '67': 'attendance_list',
        '68': 'attendance_add',
        '69': 'attendance_edit',
        '70': 'attendance_view',
        '71': 'payouts_list',
        '72': 'payouts_add',
        '73': 'payouts_edit',
        '74': 'payouts_view',
        '75': 'payouts_delete',
        '76': 'advance_list',
        '77': 'advance_add',
        '78': 'advance_edit',
        '79': 'advance_view',
        '80': 'advance_delete',
        '81': 'users_list',
        '82': 'users_add',
        '83': 'users_edit',
        '84': 'users_view',
        '85': 'users_delete',
        '86': 'role_list',
        '87': 'role_add',
        '88': 'role_edit',
        '89': 'role_view',
        '90': 'role_delete',
    }

    # --- permission groups (explicit — prevents wrong splitting like best_schedule) ---
    permission_groups = {
        'dashboard': ['view'],
        'land': ['list', 'add', 'edit', 'view', 'delete', 'location'],
        'crop': ['list', 'add', 'edit', 'view', 'delete', 'schedule'],
        'schedule': ['list', 'add', 'edit', 'view', 'delete'],
        'best_schedule': ['list', 'view'],
        'expense': ['list', 'add', 'edit', 'view', 'delete'],
        'vendor': ['list', 'add', 'edit', 'view', 'delete'],
        'sales': ['list', 'add', 'edit', 'view', 'delete'],
        'customer': ['list', 'add', 'edit', 'view', 'delete'],
        'fuel': ['list', 'consuption', 'view'],   # consuption -> matches id_to_key (typo preserved)
        'vehicle': ['list', 'consumption', 'view'],
        'machinery': ['list', 'consumption', 'view'],
        'tools': ['list', 'consumption', 'view'],
        'pesticides': ['list', 'consumption', 'view'],
        'fertilizer': ['list', 'consumption', 'view'],
        'seeds': ['list', 'consumption', 'view'],
        'employee': ['list', 'add', 'edit', 'view', 'delete'],
        'attendance': ['list', 'add', 'edit', 'view'],
        'payouts': ['list', 'add', 'edit', 'view', 'delete'],
        'advance': ['list', 'add', 'edit', 'view', 'delete'],
        'users': ['list', 'add', 'edit', 'view', 'delete'],
        'role': ['list', 'add', 'edit', 'view', 'delete'],
    }

    # --- helper: all base keys set to 0 initially ---
    all_base_keys = set(id_to_key.values())
    permissions = {k: 0 for k in all_base_keys}

    # ensure derived keys exist (initialize to 0)
    derived_keys = [
        'my_land', 'my_crop', 'my_schedule', 'my_best_schedule', 'my_farms',
        'my_expense', 'my_vendor', 'expenses',
        'my_sales', 'my_customer', 'sales',
        'fuel', 'vehicle', 'machinery', 'tools', 'pesticides', 'fertilizer', 'seeds', 'consumption',
        'employee', 'attendance', 'payouts', 'advance', 'employee_management',
        'users', 'role', 'user_management'
    ]
    for dk in derived_keys:
        permissions.setdefault(dk, 0)

    # helper to determine truthiness from various input types
    def _truthy(v):
        if isinstance(v, bool):
            return v
        if v is None:
            return False
        if isinstance(v, (int, float)):
            return v != 0
        if isinstance(v, str):
            s = v.strip().lower()
            return s in ('1', 'true', 'yes', 'on')
        # fallback
        return bool(v)

    # --- normalize selected into a set of base keys to enable ---
    selected_keys = set()

    if not selected:
        selected = []  # treat as empty

    # 1) If selected is a dict: could be grouped nested OR flat dict
    if isinstance(selected, dict):
        # grouped nested, e.g., {"land": {"add":1, "view":1}}
        # or flat dict, e.g., {"land_add":1, "land_view":0}
        is_grouped = any(k in permission_groups for k in selected.keys())
        if is_grouped:
            for group, actions in selected.items():
                if group not in permission_groups:
                    # maybe someone sent flat keys inside dict; handle below
                    continue
                if not isinstance(actions, dict):
                    continue
                for action, val in actions.items():
                    key = f"{group}_{action}"
                    # special-case: 'crop_schedule' stored as 'crop_schedule' (action 'schedule')
                    if key in permissions:
                        if _truthy(val):
                            selected_keys.add(key)
                # continue - next group
        # also accept flat dict entries like {"land_add":1}
        for k, v in selected.items():
            if isinstance(k, str) and k in permissions and _truthy(v):
                selected_keys.add(k)

    # 2) If selected is a list/tuple -> could be numeric ids or key names
    elif isinstance(selected, (list, tuple, set)):
        for item in selected:
            if item is None:
                continue
            # numeric id (int or numeric string)
            if isinstance(item, int) or (isinstance(item, str) and item.isdigit()):
                key = id_to_key.get(str(item))
                if key:
                    selected_keys.add(key)
                    continue
            # string key like 'land_add' or 'attendance_view'
            if isinstance(item, str):
                s = item.strip()
                # if it's of the form "group: {..}" - ignore
                if s in permissions:
                    selected_keys.add(s)
                    continue
                # sometimes client may send 'land.add' or 'land-add' (try basic normalization)
                normalized = s.replace('.', '_').replace('-', '_')
                if normalized in permissions:
                    selected_keys.add(normalized)
                    continue
                # maybe it's 'group' -> all actions? (not expected) skip
            # ignore other types

    # 3) If selected is a single primitive (int/str) treat similarly
    else:
        if isinstance(selected, (int, float)) or (isinstance(selected, str) and selected.isdigit()):
            key = id_to_key.get(str(selected))
            if key:
                selected_keys.add(key)
        elif isinstance(selected, str):
            if selected in permissions:
                selected_keys.add(selected)

    # --- apply selected_keys to permissions ---
    for k in selected_keys:
        permissions[k] = 1

    # --- Derived / grouped flags (same logic as web code) ---
    # my_land, my_crop, my_schedule, my_best_schedule, my_farms
    permissions['my_land'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('land_')) else 0
    permissions['my_crop'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('crop_')) else 0
    permissions['my_schedule'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('schedule_')) else 0
    permissions['my_best_schedule'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('best_schedule_')) else 0
    permissions['my_farms'] = 1 if any([
        permissions['my_land'],
        permissions['my_crop'],
        permissions['my_schedule'],
        permissions['my_best_schedule']
    ]) else 0

    # expenses grouping
    permissions['my_expense'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('expense_')) else 0
    permissions['my_vendor'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('vendor_')) else 0
    permissions['expenses'] = 1 if any([permissions['my_expense'], permissions['my_vendor']]) else 0

    # sales grouping
    permissions['my_sales'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('sales_')) else 0
    permissions['my_customer'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('customer_')) else 0
    permissions['sales'] = 1 if any([permissions['my_sales'], permissions['my_customer']]) else 0

    # consumption grouping across many modules
    permissions['fuel'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('fuel_')) else 0
    permissions['vehicle'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('vehicle_')) else 0
    permissions['machinery'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('machinery_')) else 0
    permissions['tools'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('tools_')) else 0
    permissions['pesticides'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('pesticides_')) else 0
    permissions['fertilizer'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('fertilizer_')) else 0
    permissions['seeds'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('seeds_')) else 0

    permissions['consumption'] = 1 if any([
        permissions['fuel'], permissions['vehicle'], permissions['machinery'],
        permissions['tools'], permissions['pesticides'], permissions['fertilizer'], permissions['seeds']
    ]) else 0

    # employee management grouping
    permissions['employee'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('employee_')) else 0
    permissions['attendance'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('attendance_')) else 0
    permissions['payouts'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('payouts_')) else 0
    permissions['advance'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('advance_')) else 0
    permissions['employee_management'] = 1 if any([
        permissions['employee'], permissions['attendance'], permissions['payouts'], permissions['advance']
    ]) else 0

    # user management grouping
    permissions['users'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('users_')) else 0
    permissions['role'] = 1 if any(permissions.get(k, 0) for k in permissions if k.startswith('role_')) else 0
    permissions['user_management'] = 1 if any([permissions['users'], permissions['role']]) else 0

    return permissions


def permissions_to_input_format(flat_permissions: dict) -> dict:
    """
    Convert flat stored permissions into grouped/nested input format.
    Example:
      flat_permissions = {"land_add":1,"land_edit":0,"dashboard_view":1}
      returns: {"dashboard":{"view":1},"land":{"add":1,"edit":0,"view":0,"delete":0,"location":0}}
    """
    # Define permission groups exactly like build_permissions
    permission_groups = {
        'dashboard': ['view'],
        'land': ['list', 'add', 'edit', 'view', 'delete', 'location'],
        'crop': ['list', 'add', 'edit', 'view', 'delete', 'schedule'],
        'schedule': ['list', 'add', 'edit', 'view', 'delete'],
        'best_schedule': ['list', 'view'],
        'expense': ['list', 'add', 'edit', 'view', 'delete'],
        'vendor': ['list', 'add', 'edit', 'view', 'delete'],
        'sales': ['list', 'add', 'edit', 'view', 'delete'],
        'customer': ['list', 'add', 'edit', 'view', 'delete'],
        'fuel': ['list', 'consuption', 'view'],
        'vehicle': ['list', 'consumption', 'view'],
        'machinery': ['list', 'consumption', 'view'],
        'tools': ['list', 'consumption', 'view'],
        'pesticides': ['list', 'consumption', 'view'],
        'fertilizer': ['list', 'consumption', 'view'],
        'seeds': ['list', 'consumption', 'view'],
        'employee': ['list', 'add', 'edit', 'view', 'delete'],
        'attendance': ['list', 'add', 'edit', 'view'],
        'payouts': ['list', 'add', 'edit', 'view', 'delete'],
        'advance': ['list', 'add', 'edit', 'view', 'delete'],
        'users': ['list', 'add', 'edit', 'view', 'delete'],
        'role': ['list', 'add', 'edit', 'view', 'delete'],
    }

    grouped = {}
    for group, actions in permission_groups.items():
        grouped[group] = {}
        for action in actions:
            key = f"{group}_{action}"
            grouped[group][action] = flat_permissions.get(key, 0)
    return grouped


def get_default_input_permissions() -> dict:
    """
    Returns grouped/nested input format with all keys set to 0.
    Example:
      {"dashboard":{"view":0},"land":{"list":0,"add":0,"edit":0,...}}
    """
    permission_groups = {
        'dashboard': ['view'],
        'land': ['list', 'add', 'edit', 'view', 'delete', 'location'],
        'crop': ['list', 'add', 'edit', 'view', 'delete', 'schedule'],
        'schedule': ['list', 'add', 'edit', 'view', 'delete'],
        'best_schedule': ['list', 'view'],
        'expense': ['list', 'add', 'edit', 'view', 'delete'],
        'vendor': ['list', 'add', 'edit', 'view', 'delete'],
        'sales': ['list', 'add', 'edit', 'view', 'delete'],
        'customer': ['list', 'add', 'edit', 'view', 'delete'],
        'fuel': ['list', 'consuption', 'view'],
        'vehicle': ['list', 'consumption', 'view'],
        'machinery': ['list', 'consumption', 'view'],
        'tools': ['list', 'consumption', 'view'],
        'pesticides': ['list', 'consumption', 'view'],
        'fertilizer': ['list', 'consumption', 'view'],
        'seeds': ['list', 'consumption', 'view'],
        'employee': ['list', 'add', 'edit', 'view', 'delete'],
        'attendance': ['list', 'add', 'edit', 'view'],
        'payouts': ['list', 'add', 'edit', 'view', 'delete'],
        'advance': ['list', 'add', 'edit', 'view', 'delete'],
        'users': ['list', 'add', 'edit', 'view', 'delete'],
        'role': ['list', 'add', 'edit', 'view', 'delete'],
    }

    grouped = {}
    for group, actions in permission_groups.items():
        grouped[group] = {action: 0 for action in actions}
    return grouped
