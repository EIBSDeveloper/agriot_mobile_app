import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CropDetailCard extends StatelessWidget {
  final Map<String, dynamic> crop;

  const CropDetailCard({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: (crop['img'] != null)
              ? CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(crop['img']),
                )
              : null,
          title: Text(
            crop['crop']['name'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(crop['crop_type']['name']),
          childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildDetailItem(
                  'Plantation Date',
                  DateFormat('dd MMM yyyy').format(
                    DateTime.parse(crop['plantation_date']),
                  ),
                ),
                _buildDetailItem('Harvest Type', crop['harvesting_type']['name']),
                _buildDetailItem('Measurement',
                    '${crop['measurement_value']} ${crop['measurement_unit']['name']}'),
                _buildDetailItem(
                    'Status', crop['status'] == 0 ? 'Active' : 'Inactive'),
              ],
            ),
            if (crop['description'] != null && crop['description'].isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  crop['description'],
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
