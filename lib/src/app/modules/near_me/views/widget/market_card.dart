// widgets/search_bar.dart

import 'package:argiot/src/app/modules/near_me/model/models.dart';
import 'package:argiot/src/app/widgets/my_network_image.dart';
import 'package:flutter/material.dart';

class MarketCard extends StatelessWidget {
  final Market market;

  const MarketCard({super.key, required this.market});

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (market.marketImg.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: MyNetworkImage(
                    market.marketImg,
                    height: 100,
                    width: 100,
                    fit: BoxFit.fill,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            market.address,
                            style: const TextStyle(color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${market.openingTime} - ${market.closingTime}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: market.products.take(3).map((product) => Chip(
                label: Text(product),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
          ),
          // if (market.products.length > 3)
          //   Align(
          //     alignment: Alignment.centerRight,
          //     child: Text(
          //       '+${market.products.length - 3} more',
          //       style: TextStyle(color: Colors.grey),
          //     ),
          //   ),
        ],
      ),
    );
}
