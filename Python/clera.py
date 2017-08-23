# -*- coding: utf-8 -*-

import re, string
from binascii import hexlify
from collections import OrderedDict
from subprocess import Popen, PIPE


def flatten(l):
    return [item for sublist in l for item in sublist]


choices = [
"""
  #####  #       ####### ######     #    
 #     # #       #       #     #   # #   
 #       #       #       #     #  #   #  
 #       #       #####   ######  #     # 
 #       #       #       #   #   ####### 
 #     # #       #       #    #  #     # 
  #####  ####### ####### #     # #     # 
""",

"""
  ######  ##       ######## ########     ###    
 ##    ## ##       ##       ##     ##   ## ##   
 ##       ##       ##       ##     ##  ##   ##  
 ##       ##       ######   ########  ##     ## 
 ##       ##       ##       ##   ##   ######### 
 ##    ## ##       ##       ##    ##  ##     ## 
  ######  ######## ######## ##     ## ##     ## 
""",

"""
   _____ _      ______ _____             
  / ____| |    |  ____|  __ \     /\     
 | |    | |    | |__  | |__) |   /  \    
 | |    | |    |  __| |  _  /   / /\ \   
 | |____| |____| |____| | \ \  / ____ \  
  \_____|______|______|_|  \_\/_/    \_\ 
""",

"""
      ___           ___       ___           ___           ___      
     /\  \         /\__\     /\  \         /\  \         /\  \     
    /::\  \       /:/  /    /::\  \       /::\  \       /::\  \    
   /:/\:\  \     /:/  /    /:/\:\  \     /:/\:\  \     /:/\:\  \   
  /:/  \:\  \   /:/  /    /::\~\:\  \   /::\~\:\  \   /::\~\:\  \  
 /:/__/ \:\__\ /:/__/    /:/\:\ \:\__\ /:/\:\ \:\__\ /:/\:\ \:\__\ 
 \:\  \  \/__/ \:\  \    \:\~\:\ \/__/ \/_|::\/:/  / \/__\:\/:/  / 
  \:\  \        \:\  \    \:\ \:\__\      |:|::/  /       \::/  /  
   \:\  \        \:\  \    \:\ \/__/      |:|\/__/        /:/  /   
    \:\__\        \:\__\    \:\__\        |:|  |         /:/  /    
     \/__/         \/__/     \/__/         \|__|         \/__/     
""",

"""
   ____ _     _____ ____      _     
  / ___| |   | ____|  _ \    / \    
 | |   | |   |  _| | |_) |  / _ \   
 | |___| |___| |___|  _ <  / ___ \  
  \____|_____|_____|_| \_\/_/   \_\ 
""",

'''
   ,ad8888ba,  88          88888888888 88888888ba         db        
  d8"'    `"8b 88          88          88      "8b       d88b       
 d8'           88          88          88      ,8P      d8'`8b      
 88            88          88aaaaa     88aaaaaa8P'     d8'  `8b     
 88            88          88"""""     88""""88'      d8YaaaaY8b    
 Y8,           88          88          88    `8b     d8""""""""8b   
  Y8a.    .a8P 88          88          88     `8b   d8'        `8b  
   `"Y8888Y"'  88888888888 88888888888 88      `8b d8'          `8b 
''',

"""
   /$$$$$$  /$$       /$$$$$$$$ /$$$$$$$   /$$$$$$  
  /$$__  $$| $$      | $$_____/| $$__  $$ /$$__  $$ 
 | $$  \__/| $$      | $$      | $$  \ $$| $$  \ $$ 
 | $$      | $$      | $$$$$   | $$$$$$$/| $$$$$$$$ 
 | $$      | $$      | $$__/   | $$__  $$| $$__  $$ 
 | $$    $$| $$      | $$      | $$  \ $$| $$  | $$ 
 |  $$$$$$/| $$$$$$$$| $$$$$$$$| $$  | $$| $$  | $$ 
  \______/ |________/|________/|__/  |__/|__/  |__/ 
""",

"""
  ██████╗██╗     ███████╗██████╗  █████╗  
 ██╔════╝██║     ██╔════╝██╔══██╗██╔══██╗ 
 ██║     ██║     █████╗  ██████╔╝███████║ 
 ██║     ██║     ██╔══╝  ██╔══██╗██╔══██║ 
 ╚██████╗███████╗███████╗██║  ██║██║  ██║ 
  ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ 
""",

"""
 ╔═╗╦  ╔═╗╦═╗╔═╗ 
 ║  ║  ║╣ ╠╦╝╠═╣ 
 ╚═╝╩═╝╚═╝╩╚═╩ ╩ 
"""
]
choices = [c[1:-1] for c in choices]  # remove leading and trainling newlines

choices_hexes = [re.findall('\w{2}', hexlify(choice)) for choice in choices]
all_hexes = flatten(choices_hexes)
unique_hexes = set(all_hexes)
repeats = OrderedDict()
optimized_choices = []

i = 0
for uh in unique_hexes:
    if all_hexes.count(uh) > 20:
        repeats[uh] = string.ascii_lowercase[i]
        i += 1

for ch in choices_hexes:
    optimized_c = ''
    for h in ch:
        if h in repeats.keys():
            optimized_c += '$' + repeats[h]
        else:
            optimized_c += r'\x%s' % h
    optimized_choices.append(optimized_c)

variables = '; '.join([r'%s="\x%s"' % (v, k) for k, v in repeats.items()])

# print variables and optimized hexes
#print(variables)
#print('\n\n'.join(optimized_choices))

# print printf statements
#print([r'printf "\n%s\n\n"' % oc for oc in optimized_choices])

# print choices
print('\n\n\n'.join(Popen('%s; printf "%s"' % (variables, choice), stdout=PIPE, stderr=PIPE, shell=True).communicate()[0] for choice in optimized_choices))
