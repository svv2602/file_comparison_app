VALUE_MANUFACTURER = ["michelin", "bridgestone", "goodyear"]
VALUE_SPEED = ('A'..'Y').to_a << "ZR"
VALUE_CURRENCY = ['US\$|US|EUR', '\$', '€']
VALUE_COST = '(|\s+)\d{1,3}(?:(|,| )\d{3})*(?:(|(\.|,)\d{2}))'
VALUE_OTHER = ['(RF|XRP|Run Flat)', 'XL', 'ZP', 'TL', '(AD|BD|DD|MD|OD|SD)']
VALUE_SERVICE_PARTS = ['(PROFORMA|INVOICE)']
VALUE_SERVICE_PARTS_LEFT = ['(TOTAL|ADDRESS|CONTACTS|E-MAIL|WEBSITE|Tel|Fax)(|No\.)(|:)']
VALUE_SERVICE_PARTS_RIGTH = ['PCS', "\b#{VALUE_CURRENCY}\b"]
VALUE_SERVICE_PARTS_ALL = (VALUE_SERVICE_PARTS + VALUE_SERVICE_PARTS_LEFT + VALUE_SERVICE_PARTS_RIGTH).join("|")

#=======================================================
REG_VALUE_SIZE_TYPE1 = /\d{3}\/\d{2}(|\s+)(|R|r)(|\s+)\d{2}(|(\.|,)5)/ # 225/75R19,5 || 225/75R17.5  || 175/70r13
REG_VALUE_SIZE_TYPE2 = /\d{2,3}(?:\.\d+)?x\d{1,2}\.\d{1,2}\s?R\d{2}/ # 31x10.5 R15 || 31.5x10.5 R15  || 31.5x10.5R17
REG_VALUE_SIZE_TYPE3 = /\d{1,2}(?:\.\d+)?(?:[-x]\d{1,2}(?:\.\d+)?)?(?:\s?[Rr]\d{2})?/ # 10.00R20  || 15.5-38  || 12R42

REG_VALUE_MANUFACTURER = /#{VALUE_MANUFACTURER.join("|")}/
REG_VALUE_SPEED = /#{VALUE_SPEED.join("|")}/
REG_VALUE_LOAD_AND_SPEED = /\d{2,3}(|\/\d{2,3})(#{VALUE_SPEED.join("|")})/
REG_VALUE_COST_WITH_CURRENCY = /(#{VALUE_CURRENCY.join("|")})(#{VALUE_COST})|((#{VALUE_COST})(| )(#{VALUE_SERVICE_PARTS_RIGTH.join("|")}))/
REG_VALUE_COST = /#{VALUE_COST}/
REG_VALUE_OTHER = /#{VALUE_OTHER.join("|")}/
REG_VALUE_SERVICE_PARTS = /#{VALUE_SERVICE_PARTS_ALL}/


HASH_PROPERTIES = [
  { size_type1: /^#{REG_VALUE_SIZE_TYPE1}$/ },
  { size_type2: /^#{REG_VALUE_SIZE_TYPE2}$/ },
  { size_type3: /^#{REG_VALUE_SIZE_TYPE3}$/ },
  { load_and_speed: /^#{REG_VALUE_LOAD_AND_SPEED}$/ },
  { manufacturer: /^#{REG_VALUE_MANUFACTURER}$/ },
  { cost: /^#{REG_VALUE_COST_WITH_CURRENCY}$/ },
  { number: /^#{REG_VALUE_COST}$/ },
  { other: /^#{REG_VALUE_OTHER}$/ },
  { service_parts: /#{REG_VALUE_SERVICE_PARTS}/ },
]
