#!/usr/bin/python
# Filename: while.py

num = 23
run = True

while run:
        guess = int (raw_input("Enter an integer : "))
        if guess == num:
                print 'ok'
                run =False
        elif guess < num:
                print 'higher'
        else:
                print 'lower'
else:
        print 'over'
