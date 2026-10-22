class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = "https://drz.yuvatejasainadh.me";

  // Authentication
  static const String login = "/api/auth/login";
  static const String register = "/api/auth/register";
  static const String checkEmail = "/api/auth/check-email";
  static const String resetPassword = "/api/auth/reset-password";
  static const String googleLogin = "/api/auth/google";
  static const String googleMobileLogin = "/api/auth/google/mobile";
  static const String sendOtp = "/api/send-otp";
  static const String verifyOtp = "/api/verify-otp";

  // User
  static const String me = "/api/auth/me";
  static const String logout = "/api/auth/logout";
  static const String updateProfile = "/api/users"; // will append /:id
  static const String changePassword = "/api/account/change-password";
  static const String uploadProfileImage = "/api/users/profile-image";
  static const String deleteProfileImage = "/api/users/profile-image";
  static const String deleteAccount = "/api/users/account";

  // Home & Products
  static const String publicSlides = "/api/public/slides";
  static const String categories = "/api/products/categories";
  static const String featuredProducts = "/api/featured";
  static const String trendingProducts = "/api/trending";
  static const String products = "/api/products";
  static const String searchProducts = "/api/products/search";

  // Cart
  static const String cart = "/api/cart";

  // Wishlist
  static const String wishlist = "/api/wishlist";

  // Addresses
  static const String addresses = "/api/addresses";

  // Orders
  static const String orders = "/api/orders";
  static const String placeOrder = "/api/orders/place-order";

  // Payments
  static const String razorpayCreateOrder = "/api/payments/razorpay/create-order";
  static const String razorpayVerify = "/api/payments/razorpay/verify";
}
