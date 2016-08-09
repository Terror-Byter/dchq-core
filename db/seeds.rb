AdminUser.create!([
  {email: "admin@example.com", password: "changeme"}
])
CertificationAgency.create!([
  {name: "PADI"},
  {name: "BSAC"},
  {name: "NAUI"},
  {name: "SSI"},
  {name: "CMAS"},
  {name: "GUE"},
  {name: "SDI"},
  {name: "TDI"},
  {name: "Apnea Australia"},
  {name: "IANTD"},
  {name: "NASDS"},
  {name: "MDEA"},
  {name: "IDEA"},
  {name: "ACUC"},
  {name: "YMCA"},
  {name: "Custom Courses"}
])
Currency.create!([
  {name: "US Dollar", unit: "$", code: "USD", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "British Pound", unit: "£", code: "GBP", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "Euro", unit: "€", code: "EUR", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "Canadian Dollars", unit: "CA$", code: "CAD", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "Australian Dollar", unit: "AU$", code: "AUD", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "New Zealand Dollar", unit: "NZ$", code: "NZD", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "Mexican Peso", unit: "$", code: "MXN", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "Indonesian Rupiah", unit: "Rp", code: "IRD", separator: ".", delimiter: ",", format: "%n%u", precision: 2},
  {name: "Philippine Peso", unit: "P", code: "PHP", separator: ".", delimiter: ",", format: "%n%u", precision: 2},
  {name: "Viet Nam Dong", unit: "VND", code: "VND", separator: ".", delimiter: ",", format: "%u%n", precision: 0},
  {name: "Belize Dollar", unit: "BZD", code: "BZD", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "Mauritian Rupee", unit: "Rs", code: "MUR", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "South African Rand", unit: "R", code: "ZAR", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "Indian Rupees", unit: "Rp", code: "INR", separator: ".", delimiter: ",", format: "%n%u", precision: 2},
  {name: "Singapore Dollar", unit: "S$", code: "SGD", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "UAE Dirham", unit: "AED", code: "AED", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "Danish Krone", unit: "kr.", code: "DKK", separator: ".", delimiter: ",", format: "%n%u", precision: 2},
  {name: "Swedish Krona", unit: "SEK", code: "SEK", separator: ".", delimiter: ",", format: "%n%u", precision: 2},
  {name: "Thai Baht", unit: "THB", code: "THB", separator: ".", delimiter: ",", format: "%n%u", precision: 0},
  {name: "Norwegian Krone", unit: "NOK", code: "NOK", separator: ".", delimiter: ",", format: "%n%u", precision: 2},
  {name: "Kenya Shillings", unit: "KSh", code: "KES", separator: ".", delimiter: ",", format: "%u%n", precision: 4},
  {name: "Eastern Caribbean Dollars", unit: "XCD", code: "XCD", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "Swiss Franc", unit: "CHF", code: "CHF", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "Brazilian Real", unit: "R$", code: "BRL", separator: ".", delimiter: ",", format: "%u%n", precision: 2},
  {name: "Chinese Yuan Renminbi", unit: "CN¥", code: "CNY", separator: ".", delimiter: ",", format: "%u%n", precision: 4}
])
DiverType.create!([
  {name: "Infrequent"},
  {name: "Regular"},
  {name: "New"}
])
EventType.create!([
  {name: "Social"},
  {name: "Meeting"},
  {name: "Other"},
  {name: "Trip"},
  {name: "Course"}
])
