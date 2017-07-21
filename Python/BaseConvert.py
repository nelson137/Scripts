from collections import OrderedDict

def convert(num, num_base, to_base):
	bases = {'2':2, 'b':2, 'bin':2, 'binary':2,
			 '8':8, 'o':8, 'oct':8, 'octal':8,
			 '10':10, 'd':10, 'dec':10, 'decimal':10,
			 '16':16, 'x':16, 'hex':16, 'hexadecimal':16}

	try:
		for c in num:
			if c not in '0123456789abcdef':
				raise ValueError

		try:
			num_base = bases[num_base]

			try:
				to_base = bases[to_base]

				if to_base == 10: # anything to dec
					return int(num, base=num_base)
				else: # dec to anything
					dec = int(num, base=num_base)
					return {2:bin, 8:oct, 16:hex}[to_base](dec)[2:]

			except KeyError:
				print('Invalid base')

		except KeyError:
			print('Invalid base')

	except ValueError:
		print('Invalid number')

if __name__ == '__main__':
	test_nums = OrderedDict([('1111 ', '2  '), ('23   ', '8  '),
		                     ('15   ', '10 '), ('1a   ', '16 ')])

	for num in test_nums.keys():
		for to_base in test_nums.values():
			print('num:', num, 'from base:', test_nums[num],
				  'to base:', to_base, 'equals:',
				  convert(num.strip(), test_nums[num].strip(), to_base.strip()))
