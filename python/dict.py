def invert_dict(d):
    """Inverts a dictionary, returning a map from val to a list of keys.

    If the mapping key->val appears in d, then in the new dictionary
    val maps to a list that includes key.

    d: dict

    Returns: dict
    """
    inverse = {}
    for key, val in d.iteritems():
        inverse.setdefault(val, []).append(key)
    return inverse


if __name__ == '__main__':

    print dict([('name','aa'),('age',18)])
    print dict(name='aa',age=18)

    d = dict(a=1, b=2, c=3, z=1)
    inverse = invert_dict(d)
    for val, keys in inverse.iteritems():
        print val, keys
