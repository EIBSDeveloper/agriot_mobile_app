abstract class Routes {
  // Auth routes
  static const splash = '/splash';
  static const walkthrough = '/walkthrough';
  static const login = '/login';
  static const otp = '/otp';
  static const register = '/register';
  
  // Main app routes
  static const home = '/home';
  
  // Land management
  static const addLand = '/add-land';
  static const landDetail = '/land-detail';
  
  // Crop management
  static const addCrop = '/add-crop';
  static const cropOverview = '/crop-overview';
  static const cropDetail = '/crop-detail';

  
  // Sales
   static const sales = '/sales';
  static const String salesDetails = '/fuel/sales-details';

  //temp
  static const SALES_DETAILS = '/sales-details';
  static const NEW_SALES = '/new-sales';
  static const ADD_DEDUCTION = '/add-deduction';


  // Expenses
  static const expense = '/expense';
  static const addExpense = '/addExpense';
  static const purchaseItems = '/purchaseItems';
  
  // Vendor/Customer
  static const vendorCustomer = '/vendor-customer';
  static const addVendorCustomer = '/add-vendor-customer';
  static const vendorCustomerDetails = '/vendor-customer-details';
  
  // Other features
  static const notification = '/notification';
  static const locationViewer = '/location-viewer';
  static const docViewer = '/document-viewer';
  static const nearMe = '/near-me';
  static const marketList = '/market-list';
  static const placeDetailsList = '/place-list';
  static const workersList = '/man-power-workers';
  static const rentalDetailsList = '/rental-list';
  
  // Profile
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  
  // Tasks
  static const task = '/task';
  static const taskDetail = '/task-detail';
  
  // Subscription
  static const subscriptionUsage = '/subscription/usage';
  static const subscriptionPlans = '/subscription/plans';
  static const subscriptionPayment = '/subscription/payment';
  static const paymentSuccess = '/subscription/payment/success';
  static const paymentFailed = '/subscription/payment/failed';

  //
   static const guidelines = '/guidelines';

   //
  static const INVENTORY = '/inventory';
  static const ADD_INVENTORY = '/add-inventory';
  
    static const String fuelList = '/fuel-list';
  static const String fuelPurchaseList = '/fuel-purchase-list';
  static const String addFuelPurchase = '/add-fuel-purchase';
  static const String editFuelPurchase = '/edit-fuel-purchase';
  static const String fuelPurchaseDetails = '/fuel-purchase-details';
    static const String landEdit = '/land/edit';
    static const String fuelConsumption = '/fuel-consumption';

    static const String landMapView = '/land-map';
}