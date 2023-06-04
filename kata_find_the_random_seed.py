import random

def find_random_seed(lst):
    for i in range(10000):
        random.seed(i)
        generated_integers = [random.randint(0, 100) for _ in range(10)]
        if generated_integers == lst:
            return i
    return None