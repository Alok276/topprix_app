import 'package:flutter/material.dart';
import 'package:topprix/theme/app_theme.dart';

class AntiWasteTabBar extends StatefulWidget {
  const AntiWasteTabBar({super.key});

  @override
  State<AntiWasteTabBar> createState() => _AntiWasteTabBarState();
}

class _AntiWasteTabBarState extends State<AntiWasteTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Anti-Waste Deals',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Header description
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Special offers on products close to expiry, surplus stock, and seasonal items. Save money while reducing food waste!',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Tab bar
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.successColor,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.successColor,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.access_time),
                      text: 'Expiring Soon',
                    ),
                    Tab(
                      icon: Icon(Icons.inventory_2),
                      text: 'Surplus Stock',
                    ),
                    Tab(
                      icon: Icon(Icons.calendar_today),
                      text: 'Seasonal',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpiringSoonTab(),
          _buildSurplusStockTab(),
          _buildSeasonalTab(),
        ],
      ),
    );
  }

  Widget _buildExpiringSoonTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Expires Today', AppTheme.errorColor),
        const SizedBox(height: 8),
        _buildProductCard(
          'Fresh Bread Variety Pack',
          'Originally \$4.99',
          '\$1.99',
          '60% OFF',
          'Expires in 2 hours',
          AppTheme.errorColor,
          Icons.bakery_dining,
        ),
        _buildProductCard(
          'Organic Milk 1L',
          'Originally \$3.49',
          '\$1.75',
          '50% OFF',
          'Expires today',
          AppTheme.errorColor,
          Icons.local_drink,
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('Expires Tomorrow', AppTheme.secondaryColor),
        const SizedBox(height: 8),
        _buildProductCard(
          'Fresh Salad Mix',
          'Originally \$2.99',
          '\$1.49',
          '50% OFF',
          'Expires tomorrow',
          AppTheme.secondaryColor,
          Icons.eco,
        ),
        _buildProductCard(
          'Greek Yogurt 500g',
          'Originally \$5.99',
          '\$2.99',
          '50% OFF',
          'Expires tomorrow',
          AppTheme.secondaryColor,
          Icons.breakfast_dining,
        ),
      ],
    );
  }

  Widget _buildSurplusStockTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Bulk Deals', AppTheme.primaryColor),
        const SizedBox(height: 8),
        _buildProductCard(
          'Pasta Variety Pack (6 boxes)',
          'Originally \$18.99',
          '\$12.99',
          '32% OFF',
          'Bulk discount available',
          AppTheme.primaryColor,
          Icons.restaurant,
        ),
        _buildProductCard(
          'Canned Tomatoes (12 pack)',
          'Originally \$24.99',
          '\$15.99',
          '36% OFF',
          'Surplus inventory',
          AppTheme.primaryColor,
          Icons.food_bank,
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('Overstock Items', Colors.teal),
        const SizedBox(height: 8),
        _buildProductCard(
          'Premium Olive Oil 500ml',
          'Originally \$12.99',
          '\$8.99',
          '31% OFF',
          'Limited time offer',
          Colors.teal[100]!,
          Icons.opacity,
        ),
      ],
    );
  }

  Widget _buildSeasonalTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Winter Clearance', AppTheme.primaryColor),
        const SizedBox(height: 8),
        _buildProductCard(
          'Hot Chocolate Mix',
          'Originally \$8.99',
          '\$4.99',
          '44% OFF',
          'End of season sale',
          AppTheme.primaryColor,
          Icons.local_cafe,
        ),
        _buildProductCard(
          'Winter Soup Varieties',
          'Originally \$15.99',
          '\$9.99',
          '38% OFF',
          'Seasonal clearance',
          AppTheme.primaryColor,
          Icons.soup_kitchen,
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('Spring Preview', AppTheme.successColor),
        const SizedBox(height: 8),
        _buildProductCard(
          'Fresh Herbs Collection',
          'Originally \$6.99',
          '\$4.99',
          '29% OFF',
          'Early spring special',
          AppTheme.successColor,
          Icons.grass,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color? color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    String title,
    String originalPrice,
    String salePrice,
    String discount,
    String subtitle,
    Color backgroundColor,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.textPrimary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        originalPrice,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        salePrice,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Discount badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                discount,
                style: const TextStyle(
                  color: AppTheme.surfaceColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
