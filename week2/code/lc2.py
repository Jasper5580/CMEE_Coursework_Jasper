# Average UK Rainfall (mm) for 1910 by month
# http://www.metoffice.gov.uk/climate/uk/datasets
rainfall = (('JAN',111.4),
            ('FEB',126.1),
            ('MAR', 49.9),
            ('APR', 95.3),
            ('MAY', 71.8),
            ('JUN', 70.2),
            ('JUL', 97.1),
            ('AUG',140.2),
            ('SEP', 27.0),
            ('OCT', 89.4),
            ('NOV',128.4),
            ('DEC',142.2),
           )

# (1) Use a list comprehension to create a list of month,rainfall tuples where
# the amount of rain was greater than 100 mm.
 
over_100_comp = [(m,v) for (m,v) in rainfall if v>100]
print(" >100mm:", over_100_comp)

# (2) Use a list comprehension to create a list of just month names where the
# amount of rain was less than 50 mm. 

under_50_comp = [m for (m, v) in rainfall if v < 50] 
print(" <50mm months:", under_50_comp)
# (3) Now do (1) and (2) using conventional loops (you can choose to do 
# this before 1 and 2 !). 
over_100_loop = []
under_50_loop = []

for m, v in rainfall:
    if v > 100:
        over_100_loop.append((m,v))
    if v < 50:
        under_50_loop.append(m)

print(" >100mm:", over_100_loop)
print(" <50mm months:", under_50_loop)
# A good example output is:
#
# Step #1:
# Months and rainfall values when the amount of rain was greater than 100mm:
# [('JAN', 111.4), ('FEB', 126.1), ('AUG', 140.2), ('NOV', 128.4), ('DEC', 142.2)]
# ... etc.

