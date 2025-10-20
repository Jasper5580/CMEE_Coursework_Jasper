birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7),
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2),
         )

#(1) Write three separate list comprehensions that create three different
# lists containing the latin names, common names and mean body masses for
# each species in birds, respectively. 

latin_lc = [lat for (lat, _, _) in birds]
common_lc = [com for (_, com, _) in birds]
mass_lc   = [mass for (_,  _,  mass) in birds]

print("Latin names  (lc):", latin_lc)
print("Common names (lc):", common_lc)
print("Masses (lc)      :", mass_lc)

# (2) Now do the same using conventional loops (you can choose to do this 
# before 1 !). 
latin_for, common_for, mass_for = [], [], []
for lat, com, mass in birds:
    latin_for.append(lat)
    common_for.append(com)
    mass_for.append(mass)

print("Latin names  (for):", latin_for)
print("Common names (for):", common_for)
print("Masses (for)      :", mass_for)

# A nice example out out is:
# Step #1:
# Latin names:
# ['Passerculus sandwichensis', 'Delichon urbica', 'Junco phaeonotus', 'Junco hyemalis', 'Tachycineata bicolor']
# ... etc.
 