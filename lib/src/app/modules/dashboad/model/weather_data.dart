class WeatherData {
  final String condition;
  final double temperature;
  final String iconCode;
  final int humidity;

  WeatherData({
    required this.condition,
    required this.temperature,
    required this.iconCode,
    required this.humidity,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
    condition: json['weather'][0]['main'],
    humidity: json['main']['humidity'],
    temperature: json['main']['temp'],
    iconCode: json['weather'][0]['icon'],
  );
}
