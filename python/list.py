a=[1,2,3]

print(a)

a.append(4)

print(a)

print [3*x for x in a]

print [[x, x**2] for x in a]

print [3*x for x in a if x%2 ==0]

print [(x, x**2) for x in a]

vec1 = [2, 4, 6]
vec2 = [4, 3, -9]
print [x*y for x in vec1 for y in vec2]
print [vec1[i]*vec2[i] for i in range(len(vec1))]

print [str(round(355/113, i)) for i in range(1, 6)]
