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

  // Sales
  static const sales = '/sales';

  //temp
  static const salesDetails = '/sales-details';
  static const newSales = '/new-sales';
  static const addDeduction = '/add-deduction';

  // Expenses
  static const expense = '/expense';

  static const purchaseItems = '/purchaseItems';
  static const addExpense = '/addExpense';

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

  //add inventory item
  static const addFuel = '/fuel-expenses-entry';
  static const addMachinery = '/machinery_entry';
  static const addVehicle = '/vehicle_entry';
  static const addInventoryItem = '/fertilizer_entry';

  static const schedules = '/schedules';
  static const scheduleDeatils = '/schedule-details';

  //
  static const inventory = '/inventory';
  static const consumptionPurchaseList = '/consumption-purchase';
  static const inventoryPurchaseDetail = '/inventory_purchase_detail';
  static const inventoryConsumptionDetails = '/inventory_consumption_detail';
  static const employeeManager = '/employee-manager';
  static const employeeDetails = '/employee-details';
  static const employeeAdd = '/employee-add';

  static const String addAttendence = '/addAttendence';
  static const String attendencelistscreen = '/Attendencelistscreen';
static const bot = '/smart_farm';

  static const addDocument = '/addDocument';
  static const fuelConsumption = '/fuel-consumption';
  static const String updateEmployeePayouts = '/update_employee_payouts';
  static const String updateEmployeeAdvance = '/update_employee_advance';
  static const landMapView = '/land-map';
  static const String addPayout = '/addPayout';
  static const String payoutlistscreen = '/Payoutlistscreen';

}
