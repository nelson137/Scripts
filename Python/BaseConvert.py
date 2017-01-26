def convert_stable():
	_bin = ['2', 'b', 'bi', 'bin', 'bina', 'binar', 'binary']
	_oct = ['8', 'o', 'oc', 'oct', 'octa', 'octal']
	_dec = ['10', 'd', 'de', 'dec', 'deci', 'decim', 'decima', 'decimal']
	_hex = ['16', 'x', 'h', 'he', 'hex', 'hexa', 'hexad', 'hexade', 'hexadec', 'hexadeci', 'hexadecim', 'hexadecima', 'hexadecimal']

	num = raw_input('Number: ')
	base = num[0]

	if base in _bin: base = 2
	elif base in _oct: base = 8
	elif base in _dec: base = 10
	elif base in _hex: base = 16
	else:
		print("Error: Invalid Base of Number")
		return

	if base == 10: num = num[1:]
	else: num = int('0' + num, base)

	to_base = raw_input('Convert to Base: ')

	if to_base in _bin: to_base = ('b', 2)
	elif to_base in _oct: to_base = ('o', 8)
	elif to_base in _dec: to_base = ('d', 10)
	elif to_base in _hex: to_base = ('x', 16)

	if base == 'd': print(int(num, to_base[1]))
	else: print(format(num, to_base[0]))

def convert():
	_bin = ['2', 'b', 'bi', 'bin', 'bina', 'binar', 'binary']
	_oct = ['8', 'o', 'oc', 'oct', 'octa', 'octal']
	_dec = ['10', 'd', 'de', 'dec', 'deci', 'decim', 'decima', 'decimal']
	_hex = ['16', 'x', 'h', 'he', 'hex', 'hexa', 'hexad', 'hexade', 'hexadec', 'hexadeci', 'hexadecim', 'hexadecima', 'hexadecimal']

	num = raw_input('Number: ')
	base = num[0]

	if base in _bin: base = 2
	elif base in _oct: base = 8
	elif base in _dec: base = 10
	elif base in _hex: base = 16
	else:
		print("Error: Invalid Base of Number")
		return

	if base == 10: num = num[1:]
	else: num = int('0' + num, base)

	to_base = raw_input('Convert to Base: ')

	if to_base in _bin: to_base = ('b', 2)
	elif to_base in _oct: to_base = ('o', 8)
	elif to_base in _dec: to_base = ('d', 10)
	elif to_base in _hex: to_base = ('x', 16)

	if base == 'd': print(format(num, to_base[0]))
	else: print(int(num, to_base[1]))

convert()