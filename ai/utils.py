# users/utils.py
from django.utils import timezone
from datetime import timedelta
from django.contrib.auth.models import Permission
from cryptography.fernet import Fernet
from ai.models import AddSubcription, Notification, PackageManagement
from auth.models import CustomUser
from dashboards.models import FarmerNotification

def assign_permissions(user, usertype):
    """Assign specific permissions to the user based on their usertype."""
    
    permissions_map = {
        0: ['can_add_farmer', 'can_view_farmer', 'can_edit_farmer', 'can_delete_farmer'],  # Staff permissions
        1: ['can_add_package', 'can_view_package', 'can_edit_package', 'can_delete_package'],  # Worker permissions
        2: ['can_add_subscription', 'can_view_subscription', 'can_edit_subscription', 'can_delete_subscription'],  # Market permissions
    }

    # Get the permission codes for the given usertype
    permission_codes = permissions_map.get(usertype.code, [])
    
    for codename in permission_codes:
        permission = Permission.objects.get(codename=codename)
        if not user.has_perm(codename):
            user.user_permissions.add(permission)

    user.save()  # Don't forget to save user after assigning permissions


def create_or_update_user(user_data):
    user = CustomUser.objects.get(id=user_data.get('user_id')) if user_data.get('user_id') else CustomUser()

    # Set user fields (email, phone, etc.)
    user.email = user_data.get('email')
    user.name = user_data.get('name')
    user.phone_number = user_data.get('phone_number')
    
    # Assign usertype-based permissions
    assign_permissions(user, user_data.get('usertype'))

    user.save()





# Generate a key for encryption/decryption (do this once and save the key safely)
def generate_key():
    key = Fernet.generate_key()
    print("key: ",key.decode())  # Save this key somewhere secure

# Use the key to encrypt and decrypt
class IDEncryptor:
    def __init__(self, key):
        self.cipher = Fernet(key)

    def encrypt(self, raw_id):
        return self.cipher.encrypt(str(raw_id).encode()).decode()

    def decrypt(self, encrypted_id):
        return int(self.cipher.decrypt(encrypted_id.encode()).decode())


def create_default_subscription(farmer):
    # Create a default subscription for the farmer
    package = PackageManagement.objects.first()  # Example: Get the first available package as the default
    if package:
        # Calculate start and end dates for the subscription
        start_date = timezone.now().date()
        end_date = start_date + timedelta(days=package.package_validity)  # Example: adding package validity in days
        remaining_days = (end_date - start_date).days

        # Create the subscription for the farmer
        subscription = AddSubcription.objects.create(
            farmers=farmer,
            packages=package,
            status=0,  # Default status (active)
            startdate=start_date,
            enddate=end_date,
            remainingdays=remaining_days,
            renewal=False,  # Not a renewal, it's the initial subscription
            created_by=None,  # Assuming no user is creating it at this stage
            created_at=timezone.now()
        )

        # Update farmer details with subscription info
        farmer.subscription_package = package
        farmer.subscription_start_date = start_date
        farmer.subscription_end_date = end_date
        farmer.remaining_days = remaining_days
        farmer.save()  # Save the farmer with updated subscription information

        # Create a notification for the newly created farmer
        notification = FarmerNotification.objects.create(
            farmer=farmer,
            name="New Farmer Created",
            type="Creation",
            message=f"A new farmer named {farmer.name} has been created.",
        )
        notification.save()

        # Fetch the superadmin user (you can modify this part as needed)
        superadmin_user = CustomUser.objects.filter(is_superuser=True).first()
        if superadmin_user:
            # Create a notification for the superadmin about the new farmer
            superadmin_notification = Notification.objects.create(
                user=superadmin_user,
                name="New Farmer Created",
                message=f"A new farmer named {farmer.name} has been created.",
            )
            superadmin_notification.save()

from django.core.mail import send_mail
from django.conf import settings

def send_otp_email(email, otp_value):
    subject = "Your OTP Code"
    message = f"Your OTP code is {otp_value}."
    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [email],
        fail_silently=False,
    )


def send_notification_email(email, subject, message):
    from django.core.mail import send_mail
    from django.conf import settings

    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [email],
        fail_silently=False,
    )
