# -*- coding: utf-8 -*-

import random
import Sort.BubbleSort
import Sort.InsertionSort
import Sort.ShellSort
import Sort.SelectionSort
import Sort.MergeSort
import Sort.QuickSort
import Sort.HeapSort

arry = [random.randint(1,99) for i in range(20)]

print("排序前："+str(arry))

sorted_arry = Sort.HeapSort.heap_sort(arry)

print("排序后："+str(sorted_arry))
