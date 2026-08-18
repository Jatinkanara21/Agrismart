class MarketPricePoint {
  final DateTime date;
  final double price;

  const MarketPricePoint(this.date, this.price);
}

class MarketCropPrice {
  final String crop;
  final String unit;
  final double currentPrice;
  final double changePercent;
  final List<MarketPricePoint> trend;

  const MarketCropPrice({
    required this.crop,
    required this.unit,
    required this.currentPrice,
    required this.changePercent,
    required this.trend,
  });
}
