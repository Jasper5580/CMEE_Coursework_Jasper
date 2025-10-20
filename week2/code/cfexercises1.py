
def foo_1(x):
    return x ** 0.5

def foo_2(x, y):
    if x > y:
        return x
    return y

def foo_3(x, y, z):
    if x > y:
        x, y = y, x
    if x > z:
        x, z = z, x
    if y > z:
        y, z = z, y
    return [x, y, z]

def foo_4(x):
    result = 1
    for i in range(1, x + 1):
        result = result * i
    return result

def foo_5(x):
    if x < 0:
        raise ValueError("x must be non-negative")
    if x in (0, 1):
        return 1
    return x * foo_5(x - 1)
     
def foo_6(x):
    if x < 0:
        raise ValueError("x must be non-negative")
    facto = 1
    while x >= 1:
        facto *= x
        x -= 1
    return facto

import sys

def main (argv=None):
    argv = argv if argv is not None else sys.argv[1:]

    print("foo_1(9)        ->", foo_1(9))
    print("foo_2(10, 3)    ->", foo_2(10, 3))
    print("foo_3(9, 2, 5)  ->", foo_3(9, 2, 5))
    print("foo_4(5)        ->", foo_4(5))
    print("foo_5(6)        ->", foo_5(6))
    print("foo_6(7)        ->", foo_6(7))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())