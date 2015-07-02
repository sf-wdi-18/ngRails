# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Receipt.destroy_all
Receipt.create(
  store_id: 5,
  customer_info: {
                    "first_name": "Jane",
                    "last_name": "Doe",
                    "member_id": "xxxx"
                  },
  items: [
              {
                "sku": "ABC123",
                "description": "Super Computer",
                "upc": "012345678901",
                "serial_number": "123ABC123",
                "price": "1000.00",
                "taxcode": "A"
              },
              {
                "sku": "CDE456",
                "description": "t-shirt",
                "upc": "222333222333",
                "price": "12.00",
                "qty": "4",
                "taxcode": "A"
              },
              {
                "plu": "4135",
                "description": "Gala Apples",
                "weight": "4.1 lb",
                "rate": "1.00 / 1 lb",
                "price": "4.10",
                "taxcode": "B"
              },
              {
                "description": "soda can",
                "price": "1.00",
                "taxcode": "A"
              }
           ],
  subtotal: 1017.10,
  taxes: 81.04,
  tip: 200.00,
  total: 1298.14,
  payment_method: 'CARD ENDING in XXXX',
  tender_amount: '1298.14',
  change_due: 0.00,
  transaction_number: 'XXXXX',
  item_count: 7
)
