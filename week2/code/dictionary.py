taxa = [ ('Myotis lucifugus','Chiroptera'),
         ('Gerbillus henleyi','Rodentia',),
         ('Peromyscus crinitus', 'Rodentia'),
         ('Mus domesticus', 'Rodentia'),
         ('Cleithrionomys rutilus', 'Rodentia'),
         ('Microgale dobsoni', 'Afrosoricida'),
         ('Microgale talazaci', 'Afrosoricida'),
         ('Lyacon pictus', 'Carnivora'),
         ('Arctocephalus gazella', 'Carnivora'),
         ('Canis lupus', 'Carnivora'),
        ]

# Write a python script to populate a dictionary called taxa_dic derived from
# taxa so that it maps order names to sets of taxa and prints it to screen.
# 
# An example output is:
#  
# 'Chiroptera' : set(['Myotis lucifugus']) ... etc. 
# OR, 
# 'Chiroptera': {'Myotis  lucifugus'} ... etc

#### Your solution here #### 

taxa_dic = {}

for species, order in taxa:
    taxa_dic.setdefault(order, set()).add(species)

print("Loop dict:")
for order in sorted(taxa_dic):
    print(f"{order}: {sorted(taxa_dic[order])}")


# Now write a list comprehension that does the same (including the printing after the dictionary has been created)  
 
#### Your solution here #### 

orders = {order for _, order in taxa} 
taxa_dic_comp = {
    order: {sp for sp, od in taxa if od == order}
    for order in orders
}

print("Comprehension dict:")
for order in sorted(taxa_dic_comp):
    print(f"{order}: {sorted(taxa_dic_comp[order])}")
